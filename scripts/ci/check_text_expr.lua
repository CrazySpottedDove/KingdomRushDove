-- 文案内嵌表达式静态检查（CI）
--
-- 用法（必须在仓库根目录执行）：
--   luajit scripts/ci/check_text_expr.lua
--   make check-text
--
-- 为什么要真的加载 entity_db：文案里的模板引用（T("模板名") 与裸模板名）
-- 直接取实体模板，只有 Load 过一遍才能验证模板/字段是否真的存在、数值是否求得出。
-- entity_db:Load() 会摸到 love 的一小部分接口，这里按
-- .agents/skills/port-hero-from-fl/scripts/test_hero_room_special.lua 的做法打桩，
-- 于是纯 LuaJIT 就能跑（不需要窗口/GPU，CI 里也能用）。
--
-- 检查内容（对 i18n.supported_locales 里每种语言、每条含 %$...%$ 的文案）：
--   1. 每个 %$...%$ 都能展开：表达式形式或语句块形式编译 + 求值成功
--   2. T("模板名") 引用的模板真实存在（给出精确报错）
--   3. 自由标识符必须属于「运行期短名 ∪ Lua 关键字 ∪ 本段 local ∪ 模板名」，
--      否则视为拼错的模板名/短名报错（裸模板名方案的唯一防线）
--   4. 用到 this/tdmg/tcd 的文案，必须能从本文案里推出上下文对象；
--      求值时用「文案里第一个带 tower 组件的模板」充当 this
--   5. 在 level = 1/2/3 下求值都不为 nil
--   6. 展开结果非空，且没有残留的 %$
--   7. 代入的数字按 U.format_text_number 规则显示（整数原样 / 至多两位小数）

package.path = './?.lua;./kr1/?.lua;./all/?.lua;./lib/?.lua;./kr1-desktop/?.lua;' .. './all-desktop/?.lua;./_assets/?.lua;./_assets/kr1-desktop/?.lua;' .. package.path

-- ── 加载实体库（love 打桩见 scripts/ci/love_stub.lua）──
local E = require('scripts.ci.love_stub').load_entity_db()

local U = require('utils')
local i18n = require('i18n')

-- ── 运行期短名白名单（与 all/utils.lua 的 expr_env 保持一致）──
local ENV_NAMES = {
	T = true,
	E = true,
	_G = true,
	math = true,
	string = true,
	table = true,
	tostring = true,
	tonumber = true,
	type = true,
	ipairs = true,
	pairs = true,
	select = true,
	floor = true,
	ceil = true,
	min = true,
	max = true,
	abs = true,
	FPS = true,
	BIG_ENEMY_HP = true,
	level = true,
	this = true,
	tdmg = true,
	tcd = true,
	grow = true
}

local KEYWORDS = {
	["and"] = true,
	["break"] = true,
	["do"] = true,
	["else"] = true,
	["elseif"] = true,
	["end"] = true,
	["false"] = true,
	["for"] = true,
	["function"] = true,
	["if"] = true,
	["in"] = true,
	["local"] = true,
	["nil"] = true,
	["not"] = true,
	["or"] = true,
	["repeat"] = true,
	["return"] = true,
	["then"] = true,
	["true"] = true,
	["until"] = true,
	["while"] = true
}

-- ── 检查 ──────────────────────────────────────────────────────
local LEVELS = {1, 2, 3}
local errors = {}
local checked_strings = 0
local checked_exprs = 0
local bare_names = 0

local function err(fmt, ...)
	errors[#errors + 1] = string.format(fmt, ...)
end

--- 取出文案里所有 %$...%$（含可选的收尾 %）片段。
--- 只认 "%$" 这个真正的标记，避免把 _manually_included_characters 里的裸 $ 当表达式。
local function find_spans(s)
	local spans = {}
	local pos = 1

	while true do
		local i = s:find('%%%$', pos)

		if not i then
			return spans
		end

		local j = s:find('%%%$', i + 2)

		if not j then
			return spans, string.format('第 %d 个 %%$ 没有配对的收尾 %%$', #spans + 1)
		end

		local pct = s:sub(j + 2, j + 2) == '%'

		spans[#spans + 1] = {
			body = s:sub(i + 2, j - 1),
			text = s:sub(i, j + (pct and 2 or 1))
		}
		pos = j + 1
	end
end

--- 去掉字符串字面量，返回可用于标识符扫描的文本。
--- 表达式里的字符串字面量只有模板名与 grow 的属性名，非贪婪匹配就够。
local function strip_strings(body)
	return (body:gsub("'[^']*'", "''"):gsub('"[^"]*"', '""'))
end

--- 收集「自由标识符」：不是跟在 . 或 : 后面的名字（即排除字段访问）。
--- 同时返回本段声明过的 local，供白名单判断。
local function free_identifiers(body)
	local s = strip_strings(body)
	local out = {}
	local pos = 1

	while true do
		local a, b = s:find('[%a_][%w_]*', pos)

		if not a then
			break
		end

		local prev = a > 1 and s:sub(a - 1, a - 1) or ''

		if prev ~= '.' and prev ~= ':' then
			out[#out + 1] = s:sub(a, b)
		end

		pos = b + 1
	end

	local declared = {}

	for name in s:gmatch('local%s+([%a_][%w_]*)') do
		declared[name] = true
	end

	return out, declared, s
end

--- 检查展开出来的单个数是否按 format_text_number 的规则显示
local function check_number_format(key, body, expanded)
	for num in expanded:gmatch('%d+%.%d+') do
		local decimals = num:match('%.(%d+)')

		if #decimals > 2 then
			err('%s: [%s] 展开出 %s，小数超过 2 位', key, body, num)
		end
	end

	if expanded:match('%-?%d+%.0+$') then
		err('%s: [%s] 展开出 %s，整数不该带小数点', key, body, expanded)
	end
end

--- 文案 key 里编码的技能等级。
--- 运行时不变量：tt_list[i] 的那条文案一定以 level = i 渲染
--- （game_gui.lua 的 upgrade_power 分支、screen_map.lua 的技能页），
--- 所以 key 尾 _N_ / _DESCRIPTION_N 就等于它被渲染时的 level。
--- 这样 2 级技能（如 sparking_geode）不会因为 level=3 取不到值而误报。
local function key_level(key)
	local n = key:match('_(%d)_DESCRIPTION$') or key:match('_DESCRIPTION_(%d)$')

	return n and tonumber(n) or nil
end

--- 该模板能否充当文案上下文（this）：需要有 tower 组件，tdmg/tcd 才取得到值。
local function is_context_template(name)
	local t = E:get_template(name)

	return (t and t.tower) and true or false
end

--- 从整条文案里推一个上下文对象：
--- 取「第一个带 tower 组件的模板引用」。它的 tower.damage_factor 就是文案里
--- 一直在用的那个倍率（全语料核查：499 处引用 499 处同源）。
--- 先按 T('模板名') 扫（这是绝对多数写法），再退回裸模板名。
local function pick_context(value)
	for name in value:gmatch("T%s*%(%s*['\"]([%w_]+)['\"]%s*%)") do
		if is_context_template(name) then
			return E:get_template(name)
		end
	end

	local body = strip_strings(value)
	local pos = 1

	while true do
		local a, b = body:find('[%a_][%w_]*', pos)

		if not a then
			return nil
		end

		local prev = a > 1 and body:sub(a - 1, a - 1) or ''
		local name = body:sub(a, b)

		if prev ~= '.' and prev ~= ':' and not ENV_NAMES[name] and not KEYWORDS[name] and is_context_template(name) then
			return E:get_template(name)
		end

		pos = b + 1
	end
end

--- 兜底：文案正文里没有 tower_* 锚点时，从 key 名反推塔模板。
--- 做法：把 key 切成词，枚举所有连续词窗口（长窗口优先），
--- 并对 soldier_x 额外试一次 tower_x（兵营士兵的文案属于它的塔）。
--- 例：
---   TOWER_ROTTEN_FOREST_WARP_DESCRIPTION_1     -> tower_rotten_forest（丢掉 warp）
---   ELVES_TOWER_BASTION_RAZOR_EDGE_DESCRIPTION -> tower_bastion（取中段）
---   SOLDIER_BABY_ASHBITE_FIERY_MIST_DESCRIPTION -> tower_baby_ashbite（前缀替换）
--- 之所以需要它：damage_factor 改用 tdmg 之后，正文里原本唯一的那处
--- T('tower_x') 锚点就消失了，光看正文再也认不出这座塔。
local function pick_context_from_key(key)
	local base = key:lower():gsub('_description_%d+$', ''):gsub('_description$', ''):gsub('_%d+$', '')
	local parts = {}

	for w in base:gmatch('[^_]+') do
		parts[#parts + 1] = w
	end

	local n = #parts

	for len = n, 1, -1 do
		for i = 1, n - len + 1 do
			local win = {}

			for j = i, i + len - 1 do
				win[#win + 1] = parts[j]
			end

			local name = table.concat(win, '_')

			if is_context_template(name) then
				return E:get_template(name)
			end

			if name:sub(1, 8) == 'soldier_' then
				name = 'tower_' .. name:sub(9)

				if is_context_template(name) then
					return E:get_template(name)
				end
			end
		end
	end
end

--- 整条文案里是否用到了依赖上下文对象的短名
local function uses_context(body)
	return body:find('tdmg', 1, true) or body:find('tcd', 1, true) or body:find('this', 1, true)
end

local function check_string(locale, key, s)
	checked_strings = checked_strings + 1

	local levels = LEVELS
	local lv = key_level(key)

	if lv then
		levels = {lv}
	end

	local spans, spans_err = find_spans(s)

	if spans_err then
		err('%s/%s: %s', locale, key, spans_err)
	end

	local ctx_obj = pick_context(s) or pick_context_from_key(key)
	local needs_ctx = false

	for _, span in ipairs(spans) do
		if uses_context(span.body) then
			needs_ctx = true
		end

		checked_exprs = checked_exprs + 1

		-- T("模板名") 引用的模板是否存在（精确报错，胜过求值失败的 backtrace）
		for tpl in span.body:gmatch("T%s*%(s*'(.-)'%s*%)") do
			if not E:get_template(tpl) then
				err('%s/%s: [%s] 模板 %q 不存在', locale, key, span.body, tpl)
			end
		end

		for tpl in span.body:gmatch('T%s*%(s*"(.-)"%s*%)') do
			if not E:get_template(tpl) then
				err('%s/%s: [%s] 模板 %q 不存在', locale, key, span.body, tpl)
			end
		end

		-- 塔的伤害倍率必须用 tdmg（读 ctx.ent 的局内活值）。
		-- 写 T('x').tower.damage_factor 读到的是模板基准值，局内 BUFF 不会反映到
		-- 技能文案上 —— 这个坑踩过一次，这里设成硬错误挡住复发。
		if span.body:find('%.tower%.damage_factor') then
			err('%s/%s: [%s] 请改用 tdmg（T(...).tower.damage_factor 读模板基准值，局内加成不生效）', locale, key, span.body)
		end

		-- 自由标识符白名单：裸模板名拼错时这里报错
		local ids, declared = free_identifiers(span.body)

		for _, name in ipairs(ids) do
			if not ENV_NAMES[name] and not KEYWORDS[name] and not declared[name] then
				if E:get_template(name) then
					bare_names = bare_names + 1
				else
					err('%s/%s: [%s] 未知标识符 %q（既不是运行期短名，也不是模板名）', locale, key, span.body, name)
				end
			end
		end

		for _, level in ipairs(levels) do
			local out = U.format_text_expr(span.text, {
				level = level,
				ent = ctx_obj
			})

			if out:find('%%%$') then
				err('%s/%s: [%s] level=%d 展开后仍残留 %%$', locale, key, span.body, level)
			elseif out == '' then
				err('%s/%s: [%s] level=%d 展开为空（求值失败或值为 nil）', locale, key, span.body, level)
			else
				check_number_format(string.format('%s/%s', locale, key), span.body, out)
			end
		end
	end

	-- 用了 this/tdmg/tcd 却推不出上下文对象：运行时整段会渲染成空串
	if needs_ctx and not ctx_obj then
		err('%s/%s: 用到 this/tdmg/tcd，但整条文案里找不到带 tower 组件的模板可充当上下文', locale, key)
	end

	-- 整串展开：确认没有任何未配对的标记被漏掉
	local whole = U.format_text_expr(s, {
		level = 1,
		ent = ctx_obj
	})

	if whole:find('%%%$') then
		err('%s/%s: 整串展开后仍残留 %%$', locale, key)
	end
end

for _, locale in ipairs(i18n.supported_locales) do
	local strings = require('strings.' .. locale)

	for key, value in pairs(strings) do
		if type(value) == 'string' and value:find('%%%$') then
			check_string(locale, key, value)
		end
	end
end

-- ── 结果 ──────────────────────────────────────────────────────
-- 同一条问题会在 level = 1/2/3 各报一次，输出前按内容去重（保留首次出现的顺序）
local unique = {}
local seen = {}

for _, e in ipairs(errors) do
	if not seen[e] then
		seen[e] = true
		unique[#unique + 1] = e
	end
end

if #unique > 0 then
	print(string.format('FAIL: %d 条问题（检查了 %d 条文案 / %d 个表达式）', #unique, checked_strings, checked_exprs))

	for _, e in ipairs(unique) do
		print('  ' .. e)
	end

	os.exit(1)
end

print(string.format('OK: %d 条文案 / %d 个表达式全部通过（裸模板名引用 %d 处）', checked_strings, checked_exprs, bare_names))
os.exit(0)
