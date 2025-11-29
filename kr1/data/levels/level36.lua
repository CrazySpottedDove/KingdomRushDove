-- chunkname: @/var/folders/r9/xbxmw8n51957gv9ggzrytvf80000gp/T/com.ironhidegames.frontiers.windows.steam.ep3S4swo/kr2/data/levels/level10.lua

local log = require("lib.klua.log"):new("level10")
local signal = require("hump.signal")
local km = require("lib.klua.macros")
local bit = require("bit")
local bor = bit.bor
local band = bit.band
local bnot = bit.bnot
local A = require("achievements")
local E = require("entity_db")
local P = require("path_db")
local S = require("sound_db")
local U = require("utils")
local LU = require("level_utils")
local V = require("lib.klua.vector")

require("constants")

local function fts(v)
	return v / FPS
end

local v = V.v
local level = {}

level.required_sounds = {
	"music_stage36",
	"FrontiersJungleAmbienceSounds",
	"SpecialVolcanoSounds"
}
level.required_textures = {
	"go_enemies_jungle",
	"go_stages_jungle",
	"go_stage36",
	"go_stage36_bg"
}

function level:init(store)
	store.level_terrain_type = TERRAIN_STYLE_JUNGLE
	self.locations = LU.load_locations(store, self)

	if store.level_mode == GAME_MODE_CAMPAIGN then
		self.locked_hero = false
		self.locked_powers = {}
		self.max_upgrade_level = 6
		self.locked_towers = {}
	elseif store.level_mode == GAME_MODE_HEROIC then
		self.locked_hero = false
		self.locked_powers = {}
		self.max_upgrade_level = 5
		self.locked_towers = {}
	elseif store.level_mode == GAME_MODE_IRON then
		self.locked_hero = false
		self.locked_powers = {}
		self.max_upgrade_level = 5
		self.locked_towers = {
			"tower_build_mage",
			"tower_build_engineer",
		}
	end
    self.unlock_towers = {"tower_mech"}
end

function level:load(store)
	LU.insert_background(store, "Stage10_0001", Z_BACKGROUND)
	LU.insert_background(store, "Stage10_0002", Z_OBJECTS, 114)
	LU.insert_background(store, "Stage10_0003", Z_OBJECTS, 632)
	LU.insert_background(store, "Stage10_0004", Z_OBJECTS, 650)
	LU.insert_defend_points(store, self.locations.exits, store.level_terrain_type)

	self.hidden_holders = {}

	if store.level_mode == GAME_MODE_CAMPAIGN or store.level_mode == GAME_MODE_IRON then
		for _, h in pairs(self.locations.holders) do
			if table.contains({
				"2",
				"9",
				"10",
				"14",
				"16"
			}, h.id) then
				LU.insert_tower(store, "tower_holder_blocked_jungle", h.style, h.pos, h.rally_pos, nil, h.id)
			else
				LU.insert_tower(store, "tower_holder", h.style, h.pos, h.rally_pos, nil, h.id)
			end
		end
	elseif store.level_mode == GAME_MODE_HEROIC then
		for _, h in pairs(self.locations.holders) do
			if table.contains({
				"2",
				"4",
				"9",
				"10",
				"13",
				"15"
			}, h.id) then
				LU.insert_tower(store, "tower_holder_blocked_jungle", h.style, h.pos, h.rally_pos, nil, h.id)
			else
				LU.insert_tower(store, "tower_holder", h.style, h.pos, h.rally_pos, nil, h.id)
			end
		end
	end

	local x

	self.nav_mesh = {
		{
			10,
			13,
			x,
			9
		},
		{
			10,
			10,
			1,
			11
		},
		{
			x,
			17,
			6,
			x
		},
		{
			12,
			10,
			11,
			6
		},
		{
			x,
			8,
			14,
			17
		},
		{
			3,
			11,
			9,
			x
		},
		[8] = {
			5,
			x,
			13,
			14
		},
		[9] = {
			11,
			1,
			x,
			6
		},
		[10] = {
			15,
			15,
			1,
			2
		},
		[11] = {
			4,
			2,
			9,
			6
		},
		[12] = {
			16,
			14,
			4,
			6
		},
		[13] = {
			8,
			x,
			1,
			15
		},
		[14] = {
			5,
			8,
			15,
			12
		},
		[15] = {
			14,
			13,
			10,
			10
		},
		[16] = {
			17,
			5,
			12,
			3
		},
		[17] = {
			x,
			5,
			16,
			3
		}
	}

	P:set_path_width(3, 10)
	P:set_path_width(4, 10)
	P:add_invalid_range(3, nil, nil, NF_NO_EXIT)
	P:add_invalid_range(4, nil, nil, NF_NO_EXIT)

	if store.level_mode == GAME_MODE_CAMPAIGN then
		self.sacrifice_delays = {
			nil,
			nil,
			52,
			nil,
			27,
			nil,
			20,
			nil,
			nil,
			72,
			nil,
			nil,
			24,
			1
		}
		self.volcano_bomb_delay = 3
	elseif store.level_mode == GAME_MODE_HEROIC then
		self.sacrifice_delays = {
			10,
			10,
			10,
			10,
			10,
			10
		}
		self.volcano_bomb_delay = 3
	else
		self.sacrifice_delays = {
			[1] = 2
		}
		self.volcano_bomb_delay = 8
	end

	local e
	local volcano_fires = {
		V.v(867, 469),
		V.v(872, 411),
		V.v(986, 414),
		V.v(976, 470)
	}

	for _, pos in pairs(volcano_fires) do
		e = E:create_entity("decal")
		e.render.sprites[1].name = "decal_volcano_fire"
		e.render.sprites[1].loop = true
		e.render.sprites[1].ts = U.frandom(0, 0.3)
		e.pos = pos

		LU.queue_insert(store, e)
	end

	self.deco_volcano_lava = E:create_entity("decal")
	self.deco_volcano_lava.render.sprites[1].name = "volcano_lava_waves"
	self.deco_volcano_lava.render.sprites[1].loop = true
	self.deco_volcano_lava.render.sprites[1].hidden = true
	self.deco_volcano_lava.pos = V.v(622, 443)

	LU.queue_insert(store, self.deco_volcano_lava)

	local smoke_positions = {
		{
			delay = 0.5,
			pos = V.v(598, 457)
		},
		{
			delay = 1.1,
			pos = V.v(621, 448)
		},
		{
			delay = 1.7,
			pos = V.v(642, 455)
		}
	}
	local bubble_positions = {
		{
			delay = 0.5,
			pos = V.v(579, 440)
		},
		{
			delay = 1.5,
			pos = V.v(600, 430)
		},
		{
			delay = 2.5,
			pos = V.v(599, 448)
		},
		{
			delay = 2.5,
			pos = V.v(631, 451)
		},
		{
			delay = 3,
			pos = V.v(623, 433)
		},
		{
			delay = 3.5,
			pos = V.v(648, 431)
		},
		{
			delay = 4.5,
			pos = V.v(656, 445)
		}
	}

	self.volcano_bubbles = {}

	for _, item in pairs(bubble_positions) do
		e = E:create_entity("decal_volcano_bubble")
		e.pos = item.pos
		e.delayed_play.min_delay = 5
		e.delayed_play.max_delay = 5
		e.render.sprites[1].hidden = true
		e.render.sprites[1].ts = store.tick_ts - 5 + item.delay

		LU.queue_insert(store, e)
		table.insert(self.volcano_bubbles, e)
	end

	self.volcano_smokes = {}

	for _, item in pairs(smoke_positions) do
		e = E:create_entity("decal_volcano_smoke")
		e.pos = item.pos
		e.delayed_play.min_delay = 3
		e.delayed_play.max_delay = 3
		e.delayed_play.disabled = true
		e.render.sprites[1].hidden = true
		e.render.sprites[1].ts = store.tick_ts + item.delay

		LU.queue_insert(store, e)
		table.insert(self.volcano_smokes, e)
	end

	e = E:create_entity("background_sounds_jungle")

	LU.queue_insert(store, e)
end

function level:update(store)
	LU.insert_hero(store)

	while store.wave_group_number < 1 do
		coroutine.yield()
	end

	while not store.waves_finished do
		local wave_number = store.wave_group_number
		local sacrifice_delay = self.sacrifice_delays[wave_number]

		if sacrifice_delay then
			U.y_wait(store, sacrifice_delay)
			self:y_do_sacrifice(store)
		end

		while wave_number == store.wave_group_number and not store.waves_finished do
			coroutine.yield()
		end
	end

	while not store.waves_finished or LU.has_alive_enemies(store) do
		coroutine.yield()
	end

	log.debug("-- WON")
end

function level:y_do_sacrifice(store, delay)
	local e

	if store.level_mode ~= GAME_MODE_IRON then
		e = E:create_entity("enemy_cannibal_volcano")
		e.nav_path.pi = 3

		LU.queue_insert(store, e)

		while not e.phase do
			coroutine.yield()
		end
	end

	if store.level_mode == GAME_MODE_IRON or e and e.phase == "princess_thrown" then
		self.deco_volcano_lava.render.sprites[1].hidden = false

		for _, e in pairs(self.volcano_bubbles) do
			e.delayed_play.delay = e.delayed_play.delay * 0.5

			local rem = e.render.sprites[1].ts - store.tick_ts

			e.render.sprites[1].ts = store.tick_ts + rem * 0.5
		end

		for _, e in pairs(self.volcano_smokes) do
			e.delayed_play.disabled = nil
		end

		::label_5_0::

		local bomb_origins = {
			V.v(595, 446),
			V.v(623, 459),
			V.v(634, 442)
		}
		local bomb_count = 0
		local start_ts = store.tick_ts

		while store.tick_ts - start_ts < 30 do
			if U.y_wait(store, self.volcano_bomb_delay, function(store)
				return store.waves_finished and not LU.has_alive_enemies(store)
			end) then
				return
			end

			local targets = U.find_soldiers_in_range(store.soldiers, V.v(0, 0), 0, 1000000000, F_RANGED, F_FLYING)

			if not targets or #targets < 1 then
				-- block empty
			else
				local target = targets[math.random(1, #targets)]

				bomb_count = bomb_count + 1

				local bomb = E:create_entity("bomb_volcano")

				bomb.bullet.to = V.vclone(target.pos)
				bomb.bullet.from = bomb_origins[km.zmod(bomb_count, 3)]
				bomb.pos = V.vclone(bomb.bullet.from)

				LU.queue_insert(store, bomb)

				local fx = E:create_entity("fx")

				fx.render.sprites[1].name = "volcano_shot_fx"
				fx.render.sprites[1].ts = store.tick_ts
				fx.render.sprites[1].z = Z_BULLETS
				fx.pos = V.v(bomb.pos.x, bomb.pos.y)

				LU.queue_insert(store, fx)

				fx = E:create_entity("fx")
				fx.render.sprites[1].name = "volcano_shot_splash"
				fx.render.sprites[1].ts = store.tick_ts
				fx.render.sprites[1].z = Z_BULLETS
				fx.pos = V.v(bomb.pos.x, bomb.pos.y - 1)

				LU.queue_insert(store, fx)
			end
		end

		if store.level_mode == GAME_MODE_IRON then
			goto label_5_0
		else
			self.deco_volcano_lava.render.sprites[1].hidden = true

			for _, e in pairs(self.volcano_bubbles) do
				e.delayed_play.delay = e.delayed_play.delay * 2

				local rem = e.render.sprites[1].ts - store.tick_ts

				e.render.sprites[1].ts = store.tick_ts + rem * 2
			end

			for _, e in pairs(self.volcano_smokes) do
				e.delayed_play.disabled = true
			end
		end
	end
end

return level
