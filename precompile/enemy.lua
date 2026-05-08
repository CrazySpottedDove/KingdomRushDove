local M = {}

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

local env = setmetatable({
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

local binkey = require("lib.binkey")

function M:precompile(e)
	local m = e.main_script

	if m.insert then
		if m.insert == scripts.enemy_basic.insert then
			m.insert = self.enemy_basic.insert.compile(e)
		end
	end

-- if m.update then
-- 	if m.update == scripts.enemy_mixed.update then
-- 		m.update = self.enemy_mixed.update.compile(e)
-- 	end
-- end
end

M.enemy_basic = {
	insert = {
		binkey = binkey.new(),
		cache = {}
	}
}

M.enemy_basic.insert.template = [[
return function(this, store)
	local next, new = P:next_entity_node(this, store.tick_length)

	if not next then
		return false
	end

	U.set_destination(this, next)
	U.set_heading(this, next)

	if this.pos.x == 0 and this.pos.y == 0 then
		this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	end

    -- render_1
    %s

    -- melee_1
    %s

    -- ranged_1
    %s

    -- auras_1
    %s

	this.enemy.gold_bag = this.enemy.gold

    -- water_1
    %s

	return true
end
]]

M.enemy_basic.insert.render = {[[
    for i = 1, #this.render.sprites do
        this.render.sprites[i].ts = store.tick_ts
    end
]]}

M.enemy_basic.insert.melee = {[[
    this.melee.order = U.attack_order(this.melee.attacks)
    for i = 1, #this.melee.attacks do
        this.melee.attacks[i].ts = store.tick_ts
    end
]]}

M.enemy_basic.insert.ranged = {[[
    this.ranged.order = U.attack_order(this.ranged.attacks)
    for i = 1, #this.ranged.attacks do
        this.ranged.attacks[i].ts = store.tick_ts
    end
]]}

M.enemy_basic.insert.auras = {[[
    for i = 1, #this.auras.list do
        local a = this.auras.list[i]
        a.ts = store.tick_ts

        if a.cooldown == 0 then
            local e = E:create_entity(a.name)

            e.pos.x = this.pos.x
            e.pos.y = this.pos.y
            e.aura.level = this.unit.level
            e.aura.source_id = this.id
            e.aura.ts = store.tick_ts

            queue_insert(store, e)
        end
    end
]]}

M.enemy_basic.insert.water = {[[
    if this.spawn_data and this.spawn_data.water_ignore_pi then
        this.water.ignore_pi = this.spawn_data.water_ignore_pi
    end
]]}

M.enemy_basic.insert.binkey:define_keys({"render", "melee", "ranged", "auras", "water"})

function M.enemy_basic.insert.compile(e)
	local template_key = M.enemy_basic.insert.binkey:calculate_key(e)
	local fn = M.enemy_basic.insert.cache[template_key]

	if not fn then
		local render_1 = e.render and M.enemy_basic.insert.render[1] or ""
		local melee_1 = e.melee and M.enemy_basic.insert.melee[1] or ""
		local ranged_1 = e.ranged and M.enemy_basic.insert.ranged[1] or ""
		local auras_1 = e.auras and M.enemy_basic.insert.auras[1] or ""
		local water_1 = e.water and M.enemy_basic.insert.water[1] or ""
		local code = string.format(M.enemy_basic.insert.template, render_1, melee_1, ranged_1, auras_1, water_1)
		local chunk, err = load(code, "enemy_basic.insert" .. template_key, "t", env)

		if not chunk then
			error(err)
		end

		fn = chunk()

		if type(fn) ~= "function" then
			error("enemy_basic.insert precompile did not return a function")
		end

		M.enemy_basic.insert.cache[template_key] = fn
	end

	return fn
end

return M
