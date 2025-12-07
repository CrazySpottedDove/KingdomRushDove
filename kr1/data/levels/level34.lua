-- chunkname: @/var/folders/r9/xbxmw8n51957gv9ggzrytvf80000gp/T/com.ironhidegames.frontiers.windows.steam.ep3S4swo/kr2/data/levels/level08.lua
local log = require("lib.klua.log"):new("level08")
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
level.required_sounds = {"music_stage34", "FrontiersJungleAmbienceSounds", "PiratesSounds", "SpecialCarnivorePlantSounds", "SpecialMermaid"}
level.required_textures = {"go_enemies_jungle", "go_stages_jungle", "go_stage34", "go_stage34_bg"}

function level:init(store)
	store.level_terrain_type = TERRAIN_STYLE_JUNGLE
	self.locations = LU.load_locations(store, self)
	P:deactivate_path(4)
	P:add_invalid_range(3, 1, 40)

	if store.level_mode == GAME_MODE_CAMPAIGN then
		self.locked_hero = false
		self.locked_powers = {}
		self.max_upgrade_level = 6
		self.locked_towers = {}
	elseif store.level_mode == GAME_MODE_HEROIC then
		self.locked_hero = false
		self.locked_powers = {}
		self.max_upgrade_level = 4
		self.locked_towers = {}
	elseif store.level_mode == GAME_MODE_IRON then
		self.locked_hero = false
		self.locked_powers = {}
		self.max_upgrade_level = 4
		self.locked_towers = {"tower_build_mage", "tower_build_mage", "tower_build_engineer"}
	end

	self.unlock_towers = {"tower_totem"}
end

function level:load(store)
	LU.insert_background(store, "Stage08_0001", Z_BACKGROUND)
	LU.insert_defend_points(store, self.locations.exits, store.level_terrain_type)
	self.hidden_holders = {}

	if store.level_mode == GAME_MODE_CAMPAIGN or store.level_mode == GAME_MODE_HEROIC then
		for _, h in pairs(self.locations.holders) do
			if h.id == "3" then
				LU.insert_tower(store, "tower_barrack_pirates", h.style, h.pos, h.rally_pos, nil, h.id)
			elseif h.id == "2" or h.id == "10" or h.id == "14" then
				e = LU.insert_tower(store, "tower_holder_blocked_jungle", h.style, h.pos, h.rally_pos, nil, h.id)
			else
				LU.insert_tower(store, "tower_holder", h.style, h.pos, h.rally_pos, nil, h.id)
			end
		end
	else
		for _, h in pairs(self.locations.holders) do
			if table.contains({"1", "2", "3", "10", "11"}, h.id) then
				e = LU.insert_tower(store, "tower_holder_blocked_jungle", h.style, h.pos, h.rally_pos, nil, h.id)
			else
				LU.insert_tower(store, "tower_holder", h.style, h.pos, h.rally_pos, nil, h.id)
			end
		end
	end

	local x
	self.nav_mesh = {
		{14, 14, x, 2},
		{10, 1, 1, 3},
		{4, 10, 2, 16},
		{15, 10, 3, 16},
		{6, 7, 15, x},
		{x, 7, 5, x},
		{x, 8, 9, 6},
		{7, x, 12, 9},
		{7, 8, 14, 11},
		{15, 11, 2, 4},
		{9, 9, 14, 10},
		{8, x, x, 14},
		[14] = {9, 12, 1, 11},
		[15] = {5, 9, 4, 16},
		[16] = {x, 4, x, x}
	}
	local carnivorous_plants = {}

	if store.level_mode == GAME_MODE_CAMPAIGN then
		carnivorous_plants = {{
			flipped = false,
			activates_on_wave = 10,
			pos = V.v(440, 588),
			attack_pos = V.v(483, 542)
		}, {
			flipped = false,
			activates_on_wave = 8,
			pos = V.v(558, 461),
			attack_pos = V.v(620, 523)
		}, {
			flipped = true,
			activates_on_wave = 2,
			pos = V.v(769, 586),
			attack_pos = V.v(725, 538)
		}, {
			flipped = true,
			activates_on_wave = 4,
			pos = V.v(575, 174),
			attack_pos = V.v(516, 217)
		}, {
			flipped = false,
			activates_on_wave = 6,
			pos = V.v(199, 200),
			attack_pos = V.v(266, 245)
		}}
	elseif store.level_mode == GAME_MODE_HEROIC then
		carnivorous_plants = {{
			flipped = false,
			activates_on_wave = 1,
			pos = V.v(440, 588),
			attack_pos = V.v(483, 542)
		}, {
			flipped = false,
			activates_on_wave = 6,
			pos = V.v(558, 461),
			attack_pos = V.v(620, 523)
		}, {
			flipped = true,
			activates_on_wave = 3,
			pos = V.v(769, 586),
			attack_pos = V.v(725, 538)
		}, {
			flipped = true,
			activates_on_wave = 5,
			pos = V.v(575, 174),
			attack_pos = V.v(516, 217)
		}, {
			flipped = false,
			activates_on_wave = 6,
			pos = V.v(199, 200),
			attack_pos = V.v(266, 245)
		}}
	end

	for _, item in pairs(carnivorous_plants) do
		e = E:create_entity("carnivorous_plant")
		e.pos = item.pos
		e.attack_pos = item.attack_pos
		e.activates_on_wave = item.activates_on_wave
		e.render.sprites[1].flip_x = item.flipped
		LU.queue_insert(store, e)
	end

	local e
	local water_sparks = {V.v(469, 700), V.v(500, 770), V.v(568, 673), V.v(658, 458), V.v(582, 390), V.v(674, 130), V.v(623, 60), V.v(717, 28), V.v(684, 380), V.v(386, 752)}

	for _, p in pairs(water_sparks) do
		e = E:create_entity("decal")
		e.render.sprites[1].name = "decal_water_sparks_idle"
		e.render.sprites[1].z = Z_DECALS
		e.pos = p
		LU.queue_insert(store, e)
	end

	local water_waves = {{V.v(636, 702), 33}, {V.v(559, 417), 0}, {V.v(606, 352), 201}, {V.v(590, 96), 300}}

	for _, item in pairs(water_waves) do
		e = E:create_entity("decal_water_wave")
		e.pos = item[1]
		e.render.sprites[1].r = math.pi * -1 * item[2] / 180
		LU.queue_insert(store, e)
	end

	-- e = E:create_entity("decal_crocodile")
	-- e.pos = V.v(600, 381)
	-- LU.queue_insert(store, e)
	-- e = E:create_entity("decal_crocodile")
	-- e.pos = V.v(550, 680)
	-- e.render.sprites[1].flip_x = true
	-- LU.queue_insert(store, e)
	-- local piranhas = {
	-- 	{
	-- 		V.v(534, 735),
	-- 		flip = false
	-- 	},
	-- 	{
	-- 		V.v(707, 656),
	-- 		flip = false
	-- 	},
	-- 	{
	-- 		V.v(700, 383),
	-- 		flip = false
	-- 	},
	-- 	{
	-- 		V.v(673, 147),
	-- 		flip = false
	-- 	},
	-- 	{
	-- 		V.v(716, 65),
	-- 		flip = false
	-- 	},
	-- 	{
	-- 		V.v(636, 105),
	-- 		flip = true
	-- 	},
	-- 	{
	-- 		V.v(652, 440),
	-- 		flip = true
	-- 	},
	-- 	{
	-- 		V.v(481, 685),
	-- 		flip = true
	-- 	}
	-- }
	-- for _, item in pairs(piranhas) do
	-- 	e = E:create_entity("decal_piranha")
	-- 	e.pos = item[1]
	-- 	e.render.sprites[1].flip_x = item[2]
	-- 	LU.queue_insert(store, e)
	-- end
	-- e = E:create_entity("decal_water_bottle")
	-- e.nav_path.pi = 4
	-- e.nav_path.spi = 1
	-- e.nav_path.ni = 1
	-- LU.queue_insert(store, e)
	e = E:create_entity("decal_bouncing_bridge")
	e.pos = V.v(646, 528)
	LU.queue_insert(store, e)
	-- e = E:create_entity("decal_predator")
	-- e.pos = V.v(910, 628)
	-- e.click_play.achievement_flag = {
	-- 	"YOUAREONEUGLYMOTHERFUCKER",
	-- 	2
	-- }
	-- LU.queue_insert(store, e)
	e = E:create_entity("background_sounds_jungle")
	LU.queue_insert(store, e)
end

function level:update(store)
	LU.insert_hero(store)

	while store.wave_group_number < 1 do
		coroutine.yield()
	end

	while not store.waves_finished or LU.has_alive_enemies(store) do
		coroutine.yield()
	end

	log.debug("-- WON")
end

return level
