local M = {}
local CU = require("precompile.compile_utils")
local _fn_cache = {}
------- 提供环境变量

local scripts = require("scripts")
require("lib.klua.table")

local km = require("lib.klua.macros")
local signal = require("lib.hump.signal")
local AC = require("achievements")
local E = require("entity_db")
local GR = require("grid_db")
local GS = require("kr1.game_settings")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local LU = require("level_utils")
local UP = require("kr1.upgrades")

local V = require("lib.klua.vector")
local bit = require("bit")
local band = bit.band
local bor = bit.bor
local bnot = bit.bnot

local function is_file(path)
	local info = love.filesystem.getInfo(path)

	return info and info.type == "file"
end

require("i18n")

local function queue_insert(store, e)
	simulation:queue_insert_entity(e)
end

local function queue_remove(store, e)
	simulation:queue_remove_entity(e)
end

local function queue_damage(store, damage)
	store.damage_queue[#store.damage_queue + 1] = damage
end

local function fts(v)
	return v / FPS
end

local function tpos(e)
	return e.tower and e.tower.range_offset and V.v(e.pos.x + e.tower.range_offset.x, e.pos.y + e.tower.range_offset.y) or e.pos
end

M.env = setmetatable({
	scripts = scripts,
	km = km,
	signal = signal,
	AC = AC,
	E = E,
	GR = GR,
	GS = GS,
	P = P,
	S = S,
	SU = SU,
	U = U,
	LU = LU,
	UP = UP,
	V = V,
	bit = bit,
	band = band,
	bor = bor,
	bnot = bnot,
	is_file = is_file,
	queue_insert = queue_insert,
	queue_remove = queue_remove,
	queue_damage = queue_damage,
	fts = fts,
	tpos = tpos
}, {
	__index = _G
})

----------

-- 组件克隆函数编译器
local GenCC = require("precompile.gen_component_cloner")

local function _context_lines(lines, err_ln, label, around)
	around = around or 2
	local out = {}
	out[#out + 1] = "--- " .. label .. " ---"
	local start = math.max(1, err_ln - around)
	local stop = math.min(#lines, err_ln + around)
	for ln = start, stop do
		local marker = (ln == err_ln) and ">>> " or "    "
		out[#out + 1] = string.format("%s%5d | %s", marker, ln, lines[ln])
	end
	return table.concat(out, "\n")
end

local function _match_template_line(lines, text)
	-- 在模板行中定位与出错行最匹配的行号
	-- 先后尝试：去空格精确匹配 -> 前30字符模糊匹配
	local s = text:match("^%s*(.-)%s*" .. "$") or text
	for i, line in ipairs(lines) do
		local ls = line:match("^%s*(.-)%s*" .. "$") or line
		if ls == s then
			return i
		end
	end
	if #s >= 30 then
		local p = s:sub(1, 30)
		for i, line in ipairs(lines) do
			local ls = line:match("^%s*(.-)%s*" .. "$") or line
			if ls:sub(1, 30) == p then
				return i
			end
		end
	end
	return nil
end

function M:_compile(e, template)
	local code = CU.process(template, self.env, e)
	-- if e.template_name == "enemy_goblin" then
	-- print(code)
	-- end

	-- 相同代码字符串 ⇒ 函数必然相同，直接复用
	local t_cache = _fn_cache[template]
	if t_cache then
		local fn = t_cache[code]
		if fn then
			return fn
		end
	else
		t_cache = {}
		_fn_cache[template] = t_cache
	end

	local chunk, err = load(code, nil, "t", self.env)
	if not chunk then
		-- 提取出错行号（err 格式："[string "..."]:行号: 错误信息"）
		local err_ln = tonumber(err:match(":(%d+):")) or 0
		local msg = {""}
		msg[#msg + 1] = "=== 编译错误 ==="
		msg[#msg + 1] = "实体模板: " .. tostring(e.template_name)
		msg[#msg + 1] = ""

		-- 从生成的代码里找上下文
		local code_lines = {}
		for line in code:gmatch("([^\n]*)\n?") do
			code_lines[#code_lines + 1] = line
		end
		if err_ln > 0 and err_ln <= #code_lines then
			msg[#msg + 1] = _context_lines(code_lines, err_ln, "生成的代码（出错位置）")
		else
			msg[#msg + 1] = "生成的代码（前30行）："
			for i = 1, math.min(30, #code_lines) do
				msg[#msg + 1] = string.format("    %5d | %s", i, code_lines[i])
			end
		end
		msg[#msg + 1] = ""

		-- 模板源码上下文（用出错行的前几个非空格字符匹配）
		local template_lines = {}
		for line in template:gmatch("([^\n]*)\n?") do
			template_lines[#template_lines + 1] = line
		end
		if err_ln > 0 and err_ln <= #code_lines then
			local err_line_text = code_lines[err_ln]
			-- 取生成的代码出错行的前 20 个非空白字符
			local sig = err_line_text:match("%s*(.-)%s*$")
			if sig and #sig > 20 then
				sig = sig:sub(1, 20)
			end
			local tpl_ln = _match_template_line(template_lines, sig)
			if tpl_ln then
				msg[#msg + 1] = _context_lines(template_lines, tpl_ln, "编译模板（对应位置）")
			else
				-- 退而用代码行的关键字匹配
				local keyword = err_line_text:match("(%w+)")
				if keyword then
					tpl_ln = _match_template_line(code_lines, keyword)
				end
				if tpl_ln and tpl_ln <= #template_lines then
					msg[#msg + 1] = _context_lines(template_lines, tpl_ln, "编译模板（可能位置）")
				end
			end
		end

		msg[#msg + 1] = ""
		msg[#msg + 1] = "错误：" .. err
		msg[#msg + 1] = ""
		msg[#msg + 1] = "提示：检查编译模板（precompile/templates/）中的 constif/constvar/constfor 语法是否正确"
		error(table.concat(msg, "\n"))
	end
	local ok, runtime_err = pcall(chunk)
	if not ok then
		local msg = {""}
		msg[#msg + 1] = "=== 编译后函数运行错误 ==="
		msg[#msg + 1] = "实体模板: " .. tostring(e.template_name)
		msg[#msg + 1] = "错误发生于编译生成的 Lua chunk 执行时，请检查模板逻辑。"
		msg[#msg + 1] = ""
		msg[#msg + 1] = tostring(runtime_err)
		msg[#msg + 1] = ""
		msg[#msg + 1] = "模板名称：" .. tostring(e.template_name)
		msg[#msg + 1] = "错误来源：编译生成的代码（非模板源码）"
		error(table.concat(msg, "\n"))
	end
	local result = chunk()
	t_cache[code] = result
	return result
end

-- 引入所有的编译器规则
function M:init()
	self.enemy_basic = require("precompile.templates.enemy_basic")
	self.enemy_mixed = require("precompile.templates.enemy_mixed")
	self.enemy_passive = require("precompile.templates.enemy_passive")
	self.aura_apply_mod = require("precompile.templates.aura_apply_mod")
	self.aura_apply_damage = require("precompile.templates.aura_apply_damage")
	self.mod_dps = require("precompile.templates.mod_dps")
	-- self.soldier_reinforcement = require("precompile.templates.soldier_reinforcement")
	self.soldier_barrack = require("precompile.templates.soldier_barrack")
	self.mod_track_target = require("precompile.templates.mod_track_target")
	self.arrow = require("precompile.templates.arrow")
	self.bomb = require("precompile.templates.bomb")
	self.bolt = require("precompile.templates.bolt")
end

function M:compile(e)
	if e.main_script then
		local m = e.main_script

		-- === 敌人 ===
		if e.enemy then
			if m.insert == scripts.enemy_basic.insert then
				m.insert = self:_compile(e, self.enemy_basic.insert)
			end

			if m.update == scripts.enemy_mixed.update then
				if e.melee or e.ranged then
					m.update = self:_compile(e, self.enemy_mixed.update)
				end
			elseif m.update == scripts.enemy_passive.update then
				m.update = self:_compile(e, self.enemy_passive.update)
			end
		end

		-- === 投射物 ===
		if e.bullet then
			if m.insert == scripts.arrow.insert then
				m.insert = self:_compile(e, self.arrow.insert)
			elseif m.insert == scripts.bomb.insert then
				m.insert = self:_compile(e, self.bomb.insert)
			elseif m.insert == scripts.bolt.insert then
				m.insert = self:_compile(e, self.bolt.insert)
			end

			if m.update == scripts.arrow.update then
				m.update = self:_compile(e, self.arrow.update)
				m.type = 1
			elseif m.update == scripts.bomb.update then
				m.update = self:_compile(e, self.bomb.update)
				m.type = 1
			elseif m.update == scripts.bolt.update then
				m.update = self:_compile(e, self.bolt.update)
				m.type = 1
			end
		end

		-- === 士兵（兵营/援军）===
		if e.soldier then
			if m.insert == scripts.soldier_barrack.insert then
				m.insert = self:_compile(e, self.soldier_barrack.insert)
			-- 	elseif m.insert == scripts.soldier_reinforcement.insert then
			-- 		m.insert = self:_compile(e, self.soldier_reinforcement.insert)
			end

			if m.update == scripts.soldier_barrack.update then
				m.update = self:_compile(e, self.soldier_barrack.update)
			-- 	elseif m.update == scripts.soldier_reinforcement.update then
			-- 		m.update = self:_compile(e, self.soldier_reinforcement.update)
			end
		end

		if e.modifier then
			if m.insert == scripts.mod_dps.insert then
				m.insert = self:_compile(e, self.mod_dps.insert)
			elseif m.insert == scripts.mod_track_target.insert then
				m.insert = self:_compile(e, self.mod_track_target.insert)
			end
			if m.update == scripts.mod_dps.update then
				m.update = self:_compile(e, self.mod_dps.update)
				m.type = 1
			elseif m.update == scripts.mod_track_target.update then
				if e.modifier.duration then
					m.update = self:_compile(e, self.mod_track_target.update)
					m.type = 1
				end
			end
		end

		-- === 光环 ===
		if e.aura then
			if m.insert == scripts.aura_apply_mod.insert then
				m.insert = self:_compile(e, self.aura_apply_mod.insert)
			end

			if m.update == scripts.aura_apply_mod.update then
				if e.aura.duration then
					m.update = self:_compile(e, self.aura_apply_mod.update)
					m.type = 1
				end
			elseif m.update == scripts.aura_apply_damage.update then
				if e.aura.duration then
					m.update = self:_compile(e, self.aura_apply_damage.update)
					m.type = 1
				end
			end
		end
	end
end

--- 为所有 components 生成优化的克隆函数
function M:compile_component_cloners()
	return GenCC.compile_all(E.components, self.env)
end

return M
