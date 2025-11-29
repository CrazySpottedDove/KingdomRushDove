-- chunkname: @/var/folders/r9/xbxmw8n51957gv9ggzrytvf80000gp/T/com.ironhidegames.frontiers.windows.steam.ep3S4swo/kr2/data/levels/level07.lua

local log = require("lib.klua.log"):new("level07")
local signal = require("hump.signal")
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
	"music_stage33",
	"FrontiersJungleAmbienceSounds",
	"AmazonSounds",
	"SpecialCutTreeSounds"
}
level.required_textures = {
	"go_enemies_jungle",
	"go_stages_jungle",
	"go_stage33",
	"go_stage33_bg"
}
level.show_comic_idx = 11

function level:init(store)
	store.level_terrain_type = TERRAIN_STYLE_JUNGLE
	self.locations = LU.load_locations(store, self)

	if store.level_mode == GAME_MODE_CAMPAIGN then
		self.locked_hero = false
		self.locked_powers = {}
		self.max_upgrade_level = 6
		self.locked_towers = {
		}
	elseif store.level_mode == GAME_MODE_HEROIC then
		self.locked_hero = false
		self.locked_powers = {}
		self.max_upgrade_level = 4
		self.locked_towers = {
		}
	elseif store.level_mode == GAME_MODE_IRON then
		self.locked_hero = false
		self.locked_powers = {}
		self.max_upgrade_level = 4
		self.locked_towers = {
			"tower_build_archer",
			"tower_build_engineer",
			"tower_build_archer",
		}
	end
    self.unlock_towers = {"tower_barrack_amazonas","tower_templar"}
end

function level:load(store)
	LU.insert_background(store, "Stage07_0001", Z_BACKGROUND)
	LU.insert_background(store, "Stage07_0002", Z_OBJECTS, 200)
	LU.insert_background(store, "Stage07_0003", Z_OBJECTS, 130)
	LU.insert_background(store, "Stage07_0004", Z_OBJECTS, 25)
	LU.insert_background(store, "Stage07_0005", Z_OBJECTS, 600)
	LU.insert_defend_points(store, self.locations.exits, store.level_terrain_type)

	self.hidden_holders = {}

	if store.level_mode == GAME_MODE_CAMPAIGN then
		for _, h in pairs(self.locations.holders) do
			if h.id == "5" then
				LU.insert_tower(store, "tower_barrack_amazonas", h.style, h.pos, h.rally_pos, nil, h.id)
			elseif h.id == "1" or h.id == "4" or h.id == "31" then
				e = LU.insert_tower(store, "tower_holder_blocked_jungle", h.style, h.pos, h.rally_pos, nil, h.id)
			elseif h.id == "18" then
				e = LU.insert_tower(store, "tower_holder", h.style, h.pos, h.rally_pos, nil, h.id)
				e.ui.can_click = false
				e.tower.can_hover = false

				table.insert(self.hidden_holders, e)
			else
				LU.insert_tower(store, "tower_holder", h.style, h.pos, h.rally_pos, nil, h.id)
			end
		end
	elseif store.level_mode == GAME_MODE_HEROIC then
		for _, h in pairs(self.locations.holders) do
			if h.id == "5" then
				LU.insert_tower(store, "tower_barrack_amazonas", h.style, h.pos, h.rally_pos, nil, h.id)
			elseif h.id == "2" or h.id == "4" or h.id == "9" or h.id == "17" then
				e = LU.insert_tower(store, "tower_holder_blocked_jungle", h.style, h.pos, h.rally_pos, nil, h.id)
			else
				LU.insert_tower(store, "tower_holder", h.style, h.pos, h.rally_pos, nil, h.id)
			end
		end
	else
		for _, h in pairs(self.locations.holders) do
			if h.id == "3" then
				LU.insert_tower(store, "tower_barrack_amazonas", h.style, h.pos, h.rally_pos, nil, h.id)
			elseif h.id == "2" or h.id == "4" or h.id == "5" or h.id == "8" or h.id == "9" or h.id == "17" then
				e = LU.insert_tower(store, "tower_holder_blocked_jungle", h.style, h.pos, h.rally_pos, nil, h.id)
			else
				LU.insert_tower(store, "tower_holder", h.style, h.pos, h.rally_pos, nil, h.id)
			end
		end
	end

	local x

	self.nav_mesh = {
		{
			31,
			17,
			10,
			x
		},
		{
			15,
			8,
			9,
			4
		},
		{
			30,
			4,
			17,
			31
		},
		{
			30,
			2,
			17,
			3
		},
		{
			x,
			6,
			8,
			15
		},
		{
			5,
			x,
			7,
			5
		},
		{
			6,
			x,
			12,
			8
		},
		{
			5,
			7,
			9,
			2
		},
		{
			8,
			7,
			11,
			17
		},
		{
			17,
			11,
			18,
			1
		},
		{
			9,
			12,
			13,
			18
		},
		{
			7,
			x,
			14,
			11
		},
		{
			11,
			14,
			x,
			18
		},
		{
			12,
			x,
			x,
			13
		},
		{
			x,
			5,
			2,
			30
		},
		[17] = {
			3,
			9,
			10,
			1
		},
		[18] = {
			10,
			13,
			x,
			x
		},
		[30] = {
			x,
			15,
			3,
			x
		},
		[31] = {
			x,
			3,
			1,
			x
		}
	}

	local e

	-- e = E:create_entity("decal_monkey_banana")
	-- e.pos = V.v(488, 580)

	-- LU.queue_insert(store, e)

	-- e = E:create_entity("decal_monkey_run")
	-- e.pos = V.v(798, 643)
	-- e.tween.props[1].keys = {
	-- 	{
	-- 		0,
	-- 		v(0, 0)
	-- 	},
	-- 	{
	-- 		3,
	-- 		v(-387, 27)
	-- 	}
	-- }

	-- LU.queue_insert(store, e)

	-- e = E:create_entity("decal_monkey_run")
	-- e.pos = V.v(686, 40)
	-- e.tween.props[1].keys = {
	-- 	{
	-- 		0,
	-- 		v(0, 0)
	-- 	},
	-- 	{
	-- 		3,
	-- 		v(-377, 15)
	-- 	}
	-- }

	-- LU.queue_insert(store, e)

	-- e = E:create_entity("decal_bird_blue")
	-- e.pos = V.v(-100, 300)
	-- e.tween.props[1].keys = {
	-- 	{
	-- 		0,
	-- 		v(0, 0)
	-- 	},
	-- 	{
	-- 		5,
	-- 		v(400, 600)
	-- 	}
	-- }

	-- LU.queue_insert(store, e)

	-- e = E:create_entity("decal_bird_multicolor")
	-- e.pos = V.v(1100 + REF_OX, 400)
	-- e.tween.props[1].keys = {
	-- 	{
	-- 		0,
	-- 		v(0, 0)
	-- 	},
	-- 	{
	-- 		5,
	-- 		v(-700, 500)
	-- 	}
	-- }
	-- e.render.sprites[1].flip_x = true

	-- LU.queue_insert(store, e)

	-- e = E:create_entity("decal_predator")
	-- e.pos = V.v(98, 576)
	-- e.click_play.achievement_flag = {
	-- 	"YOUAREONEUGLYMOTHERFUCKER",
	-- 	1
	-- }

	-- LU.queue_insert(store, e)

	if store.level_mode == GAME_MODE_CAMPAIGN then
		P:deactivate_path(3)
		P:deactivate_path(4)
		self:load_palms(store)
	end

	e = E:create_entity("background_sounds_jungle")

	LU.queue_insert(store, e)
end

function level:update(store)
	LU.insert_hero(store)

	while store.wave_group_number < 1 do
		coroutine.yield()
	end

	if store.level_mode == GAME_MODE_CAMPAIGN then
		while store.wave_group_number < 6 do
			coroutine.yield()
		end

		self:y_cut_palms_left(store)
		P:activate_path(3)

		for _, e in pairs(self.hidden_holders) do
			e.ui.can_click = true
			e.tower.can_hover = true
		end

		while store.wave_group_number < 10 do
			coroutine.yield()
		end

		self:y_cut_palms_right(store)
		P:activate_path(4)
	end

	while not store.waves_finished or LU.has_alive_enemies(store) do
		coroutine.yield()
	end

	log.debug("-- WON")
end

function level:load_palms(store)
	self.palm_land_groups_left = {}
	self.palm_land_groups_right = {}

	for i = 6, 10 do
		local e = E:create_entity("decal_palm_land")

		e.render.sprites[1].name = string.format("Stage07_00%02i", i)
		e.render.sprites[1].animated = false

		LU.queue_insert(store, e)
		table.insert(self.palm_land_groups_left, e)
	end

	for i = 11, 13 do
		local e = E:create_entity("decal_palm_land")

		e.render.sprites[1].name = string.format("Stage07_00%02i", i)
		e.render.sprites[1].animated = false

		LU.queue_insert(store, e)
		table.insert(self.palm_land_groups_right, e)
	end

	local function _cc(x, y)
		local KA = 1.28
		local OFX = (1100 * KA - 1024) * 0.5

		return v(x * KA - OFX, 768 - KA * y)
	end

	local palm_tree_coords_right = {
		{
			_cc(1014, 241),
			_cc(1039, 212),
			_cc(1048, 260),
			_cc(1095, 213),
			_cc(1098, 281),
			_cc(1115, 238)
		},
		{
			_cc(1192, 193),
			_cc(993, 192),
			_cc(967, 220),
			_cc(946, 252),
			_cc(893, 236),
			_cc(980, 273),
			_cc(1022, 292)
		},
		{
			_cc(919, 208),
			_cc(902, 270),
			_cc(938, 295)
		}
	}
	local palm_tree_coords_left = {
		{
			_cc(-10, 460),
			_cc(65, 466),
			_cc(39, 431),
			_cc(-9, 408),
			_cc(60, 395),
			_cc(114, 440)
		},
		{
			_cc(159, 456),
			_cc(118, 408),
			_cc(179, 424),
			_cc(183, 389),
			_cc(134, 367),
			_cc(233, 445)
		},
		{
			_cc(236, 409),
			_cc(206, 356),
			_cc(261, 343)
		},
		{
			_cc(294, 435),
			_cc(299, 399),
			_cc(250, 378),
			_cc(160, 339)
		},
		{
			_cc(363, 408),
			_cc(359, 382),
			_cc(318, 354),
			_cc(218, 318)
		}
	}

	self.palm_tree_groups_left = {}

	for _, g in pairs(palm_tree_coords_left) do
		local tg = {}

		for _, c in pairs(g) do
			local e = E:create_entity("decal_palm_tree")

			e.pos = c

			LU.queue_insert(store, e)
			table.insert(tg, e)
		end

		table.insert(self.palm_tree_groups_left, tg)
	end

	self.palm_tree_groups_right = {}

	for _, g in pairs(palm_tree_coords_right) do
		local tg = {}

		for _, c in pairs(g) do
			local e = E:create_entity("decal_palm_tree")

			e.pos = c

			LU.queue_insert(store, e)
			table.insert(tg, e)
		end

		table.insert(self.palm_tree_groups_right, tg)
	end
end

local function cut_group(store, tree_groups, land_groups, i)
	for _, palm in pairs(tree_groups[i]) do
		palm.timed.disabled = nil

		U.animation_start(palm, "cut", nil, store.tick_ts, false)
	end

	S:queue("SpecialCutTrees")

	local land = land_groups[i]

	land.tween.disabled = nil
	land.render.sprites[1].ts = store.tick_ts
end

local function y_walk(store, entity, to, speed)
	local from = V.vclone(entity.pos)
	local duration = V.dist(from.x, from.y, to.x, to.y) / speed
	local start_ts = store.tick_ts
	local phase = 0
	local eased_phase = 0

	while phase < 1 do
		phase = math.min(1, (store.tick_ts - start_ts) / duration)
		entity.pos.x = U.ease_value(from.x, to.x, phase, easing)
		entity.pos.y = U.ease_value(from.y, to.y, phase, easing)

		coroutine.yield()
	end
end

function level:y_cut_palms_right(store)
	local lumberjack = E:create_entity("decal_lumberjack_shaman")

	lumberjack.render.sprites[1].flip_x = true

	LU.queue_insert(store, lumberjack)

	lumberjack.pos = v(1180, 436)

	local cut_steps = {
		{
			x = 1130,
			y = 438
		},
		{
			x = 1063,
			y = 438
		},
		{
			x = 1000,
			y = 440
		}
	}

	for i, step in ipairs(cut_steps) do
		U.animation_start(lumberjack, "cut", nil, store.tick_ts, false)
		U.y_wait(store, 0.5)
		cut_group(store, self.palm_tree_groups_right, self.palm_land_groups_right, i)
		U.y_wait(store, 0.4)
		U.animation_start(lumberjack, "walk", nil, store.tick_ts, true)
		y_walk(store, lumberjack, step, 1.024 * FPS)
	end

	LU.queue_remove(store, lumberjack)

	local nodes = P:nearest_nodes(lumberjack.pos.x, lumberjack.pos.y)
	local node = nodes[1]
	local e = E:create_entity("enemy_shaman_priest")

	e.pos = lumberjack.pos
	e.nav_path.pi = node[1]
	e.nav_path.spi = 1
	e.nav_path.ni = node[3] + 3

	LU.queue_insert(store, e)
end

function level:y_cut_palms_left(store)
	local lumberjack = E:create_entity("decal_lumberjack_shaman")

	lumberjack.render.sprites[1].flip_x = false

	LU.queue_insert(store, lumberjack)

	lumberjack.pos = v(-160, 200)

	local cut_steps = {
		{
			x = -108,
			y = 222
		},
		{
			x = 26,
			y = 252
		},
		{
			x = 57,
			y = 266
		},
		{
			x = 142,
			y = 294
		},
		{
			x = 192,
			y = 310
		}
	}

	for i, step in ipairs(cut_steps) do
		U.animation_start(lumberjack, "cut", nil, store.tick_ts, false)
		U.y_wait(store, 0.5)
		cut_group(store, self.palm_tree_groups_left, self.palm_land_groups_left, i)
		U.y_wait(store, 0.4)
		U.animation_start(lumberjack, "walk", nil, store.tick_ts, true)
		y_walk(store, lumberjack, step, 1.024 * FPS)
	end

	LU.queue_remove(store, lumberjack)

	local nodes = P:nearest_nodes(lumberjack.pos.x, lumberjack.pos.y)
	local node = nodes[1]
	local e = E:create_entity("enemy_shaman_priest")

	e.pos = lumberjack.pos
	e.nav_path.pi = node[1]
	e.nav_path.spi = 1
	e.nav_path.ni = node[3] + 3

	LU.queue_insert(store, e)
end

return level
