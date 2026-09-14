-- 文案内嵌表达式静态检查（CI）
--
-- 用法（必须在仓库根目录执行）：
--   luajit scripts/ci/check_text_expr.lua
--   make check-text
--
-- 为什么要真的加载 entity_db：文案里的 T("模板名") 直接取实体模板，
-- 只有 Load 过一遍才能验证模板/字段是否真的存在、数值是否求得出。
-- entity_db:Load() 会摸到 love 的一小部分接口，这里按
-- .agents/skills/port-hero-from-fl/scripts/test_hero_room_special.lua 的做法打桩，
-- 于是纯 LuaJIT 就能跑（不需要窗口/GPU，CI 里也能用）。
--
-- 检查内容（对 i18n.supported_locales 里每种语言、每条含 %$...%$ 的文案）：
--   1. 每个 %$...%$ 都能展开：balance 路径命中，或表达式编译 + 求值成功
--   2. 表达式里 T("模板名") 引用的模板真实存在（给出精确报错）
--   3. 在 level = 1/2/3 下求值都不为 nil
--   4. 展开结果非空，且没有残留的 %$
--   5. 代入的数字按 U.format_text_number 规则显示（整数原样 / 至多两位小数）

package.path = './?.lua;./kr1/?.lua;./all/?.lua;./lib/?.lua;./kr1-desktop/?.lua;' .. './all-desktop/?.lua;./_assets/?.lua;./_assets/kr1-desktop/?.lua;' .. package.path

-- ── 加载实体库（love 打桩见 scripts/ci/love_stub.lua）──
local E = require('scripts.ci.love_stub').load_entity_db()

local U = require('utils')
local i18n = require('i18n')

-- ── 检查 ──────────────────────────────────────────────────────
local LEVELS = {1, 2, 3}
local errors = {}
local checked_strings = 0
local checked_exprs = 0

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

	for _, span in ipairs(spans) do
		checked_exprs = checked_exprs + 1

		-- T("模板名") 引用的模板是否存在（精确报错，胜过求值失败的 backtrace）
		for tpl in span.body:gmatch("T%s*%(%s*'(.-)'%s*%)") do
			if not E:get_template(tpl) then
				err('%s/%s: [%s] 模板 %q 不存在', locale, key, span.body, tpl)
			end
		end

		for tpl in span.body:gmatch('T%s*%(%s*"(.-)"%s*%)') do
			if not E:get_template(tpl) then
				err('%s/%s: [%s] 模板 %q 不存在', locale, key, span.body, tpl)
			end
		end

		for _, level in ipairs(levels) do
			local out = U.format_text_expr(span.text, {
				level = level
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

	-- 整串展开：确认没有任何未配对的标记被漏掉
	local whole = U.format_text_expr(s, {
		level = 1
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

print(string.format('OK: %d 条文案 / %d 个表达式全部通过', checked_strings, checked_exprs))
os.exit(0)
