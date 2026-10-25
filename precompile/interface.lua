local M = {
	main_script_backup = {},
	warned = {},
	script_types = setmetatable({}, {
		__mode = "k"
	})
}
local GenCC = require("precompile.gen_component_cloner")
local loader = require("precompile.loader")

local scripts = require("scripts")
local specs = require("precompile.specs")
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

local file_utils = require("all.file_utils")
local is_file = file_utils.is_file
local log = require("lib.klua.log"):new("precompile")
require("i18n")

local queue_damage = U.queue_damage
local fts = U.fts
local tpos = U.tpos

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
	queue_damage = queue_damage,
	fts = fts,
	tpos = tpos,
	log = log
}, {
	__index = _G
})

local NIL = {}

local loader_ready = false

for _, spec in ipairs(specs.list()) do
	M.script_types[spec.source] = spec.source_state_machine and 1 or 0
	if spec.compile_source then
		M.script_types[spec.compile_source] = spec.state_machine and 1 or 0
	end
end

function M:mark_script(fn, script_type)
	self.script_types[fn] = script_type
end

function M:script_type(fn)
	return self.script_types[fn]
end

function M:ensure_entity_type(e)
	local s = e.main_script
	if not s or not s.update then
		return
	end

	local fn = s.update
	local script_type = self.script_types[fn]
	if script_type == nil then
		script_type = 0
		if not s.context then
			s.context = E:clone_c("context")
		end
	end

	if s.type ~= script_type or s._pc_update ~= fn then
		s.co = nil
		s.type = script_type
	end

	if script_type == 1 and not s.context then
		s.context = E:clone_c("context")
	end

	s._pc_update = fn
end

function M:set_and_backup(e, key, value)
	local name = e.template_name
	local backup = self.main_script_backup[name]
	if not backup then
		backup = {}
		self.main_script_backup[name] = backup
	end
	if backup[key] == nil then
		local current = e.main_script[key]
		backup[key] = current == nil and NIL or current
	end
	e.main_script[key] = value
end

function M:restore_main_script(e, base)
	local backup = self.main_script_backup[base or e.template_name]
	if not backup then
		return
	end
	for key, value in pairs(backup) do
		if value == NIL then
			e.main_script[key] = nil
		else
			e.main_script[key] = value
		end
	end
end

function M:apply_generated(e, entry)
	local script_type = entry.type == 1 and 1 or 0
	for key, value in pairs(entry) do
		if type(value) == "function" then
			self.script_types[value] = script_type
			self:set_and_backup(e, key, value)
		end
	end
	self:set_and_backup(e, "type", entry.type or 0)
end

function M:runtime_compile(e)
	local specs = require("precompile.specs")
	local source = require("precompile.frontend.source")
	local specialize = require("precompile.stage.specialize")

	for _, item in ipairs(specs.for_entity(e)) do
		local compile_source = item.spec.compile_source or item.source
		local func, file, err = source.find_function(compile_source)
		if not func then
			local key = e.template_name .. "." .. item.spec.group .. "." .. item.spec.key
			if not self.warned[key] then
				self.warned[key] = true
				print("precompile: 跳过无法定位源码的脚本 " .. key .. ": " .. tostring(err))
			end
		else
			local ok, result = pcall(specialize.specialize, func, e, {
				file = file.path
			})
			if not ok then
				print("precompile: 特化失败 " .. e.template_name .. " " .. item.spec.group .. "." .. item.spec.key .. ": " .. tostring(result))
			else
				local chunk, load_err = load(result.code, "@precompile/generated/" .. e.template_name .. "." .. item.spec.key, "t", self.env)
				if not chunk then
					print("precompile: 生成代码无法加载 " .. e.template_name .. ": " .. tostring(load_err))
				else
					local fn = chunk()
					local script_type = item.spec.state_machine and 1 or 0
					self.script_types[fn] = script_type
					self:set_and_backup(e, item.key, fn)
					self:set_and_backup(e, "type", script_type)
				end
			end
		end
	end
end

function M:compile(e)
	if not loader_ready then
		loader_ready = true
		loader.load(self.env)
	end

	local entry = loader.get(e.template_name)
	if entry then
		self:apply_generated(e, entry)
	else
		self:runtime_compile(e)
	end
end

--- 为所有 components 生成优化的克隆函数
function M:compile_component_cloners(components)
	return GenCC.compile_all(components, self.env)
end

return M
