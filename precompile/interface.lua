local M = {}
local CU = require("precompile.compile_utils")
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

-- 引入所有的编译器规则
function M:init()
	self.enemy_basic = require("precompile.templates.enemy_basic")
	self.enemy_mixed = require("precompile.templates.enemy_mixed")
end

-- local compiled_templates = {}

function M:_compile(e, template)
	local code = CU.process(template, self.env, e)
	-- if not compiled_templates[template] then
	-- print(code)
	-- compiled_templates[template] = code
	-- end
	local chunk, err = load(code, nil, "t", self.env)
	if not chunk then
		error("Error compiling script: " .. err)
	end
	return chunk()
end

function M:compile(e)
	if e.main_script then
		local m = e.main_script

		if e.enemy then
			if m.insert == scripts.enemy_basic.insert then
				-- m.insert = self.enemy_basic.insert.compile(e)
				m.insert = self:_compile(e, self.enemy_basic.insert)
			end

			if m.update == scripts.enemy_mixed.update then
				-- m.update = self.enemy_mixed.update.compile(e)
				if e.melee or e.ranged then
					m.update = self:_compile(e, self.enemy_mixed.update)
				end
			end
		end

	-- if e.aura then
	-- 	if m.insert == scripts.aura_apply_mod.insert then
	-- 		m.insert = self.aura_apply_mod.insert.compile(e)
	-- 	end
	-- end
	end
end

return M
