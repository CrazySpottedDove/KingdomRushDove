local M = {
	main_script_backup = {},
	warned = {}
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
	for key, value in pairs(entry) do
		if type(value) == "function" then
			self:set_and_backup(e, key, value)
		end
	end
	self:set_and_backup(e, "type", entry.type or 0)
end

function M:runtime_compile(e)
	local items = specs.for_entity(e)
	if #items == 0 then
		return
	end

	local source = require("precompile.frontend.source")
	local specialize = require("precompile.stage.specialize")
	local whitelists = require("precompile.whitelists")

	for _, item in ipairs(items) do
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
				file = file.path,
				whitelist = item.spec.family and whitelists[item.spec.family] or nil,
				nullable = item.spec.family and whitelists.nullable and whitelists.nullable[item.spec.family] or nil,
				globals = self.env,
				helper_prefix = "__pc_h_"
			})
			if not ok then
				print("precompile: 特化失败 " .. e.template_name .. " " .. item.spec.group .. "." .. item.spec.key .. ": " .. tostring(result))
			else
				local source_code = result.code
				if result.helpers_code and result.helpers_code ~= "" then
					source_code = result.helpers_code .. "\n" .. source_code
				end
				local chunk, load_err = load(source_code, "@precompile/generated/" .. e.template_name .. "." .. item.spec.key, "t", self.env)
				if not chunk then
					print("precompile: 生成代码无法加载 " .. e.template_name .. ": " .. tostring(load_err))
				else
					self:set_and_backup(e, item.key, chunk())
					self:set_and_backup(e, "type", item.spec.state_machine and 1 or 0)
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
