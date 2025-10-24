
-- chunkname: @/var/folders/r9/xbxmw8n51957gv9ggzrytvf80000gp/T/com.ironhidegames.frontiers.windows.steam.ep3S4swo/kr2/data/levels/level15.lua

local log = require("klua.log"):new("level15")
local signal = require("hump.signal")
local km = require("klua.macros")
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
local V = require("klua.vector")

require("constants")

local function fts(v)
	return v / FPS
end

local v = V.v
local OX = -27
local level = {}

level.required_sounds = {
	"music_stage41",
	"FrontiersUndergroundAmbienceSounds",
	"FrontiersFinalBoss"
}
level.required_textures = {
	"go_enemies_underground",
	"go_stages_underground",
	"go_stage41",
	"go_stage41_bg"
}
level.show_comic_idx = 13
level.pan_extension = not (KR_TARGET ~= "phone" and KR_TARGET ~= "tablet") and {
	top = 48
} or nil

function level:init(store)
	store.level_terrain_type = TERRAIN_STYLE_UNDERGROUND
	self.locations = LU.load_locations(store, self)
	self.locked_hero = false
	self.locked_powers = {}
	self.max_upgrade_level = 6
	self.locked_towers = {}

	if store.level_mode == GAME_MODE_IRON then
		self.locked_towers = {
			"tower_build_mage",
		}
	end
end

function level:load(store)
	local bg_prefix = not (KR_TARGET ~= "phone" and KR_TARGET ~= "tablet") and "Stage15_tall_" or "Stage15_"
	local bg_offset = not (KR_TARGET ~= "phone" and KR_TARGET ~= "tablet") and 24 or 0
	local bg1 = LU.insert_background(store, bg_prefix .. "0001", Z_BACKGROUND)
	local bg2 = LU.insert_background(store, bg_prefix .. "0002", Z_OBJECTS, 580)
	local bg3 = LU.insert_background(store, bg_prefix .. "0003", Z_OBJECTS, 615)

	bg1.pos.y = bg1.pos.y + bg_offset
	bg2.pos.y = bg2.pos.y + bg_offset
	bg3.pos.y = bg3.pos.y + bg_offset

	LU.insert_defend_points(store, self.locations.exits, store.level_terrain_type)

	if store.level_mode == GAME_MODE_CAMPAIGN or store.level_mode == GAME_MODE_HEROIC then
		for _, h in pairs(self.locations.holders) do
			if table.contains({
				"6",
				"3",
				"14",
				"11",
				"10"
			}, h.id) then
				LU.insert_tower(store, "tower_holder_blocked_underground", h.style, h.pos, h.rally_pos, nil, h.id, nil, h.id)
			else
				LU.insert_tower(store, "tower_holder", h.style, h.pos, h.rally_pos, nil, h.id, nil, h.id)
			end
		end
	else
		for _, h in pairs(self.locations.holders) do
			LU.insert_tower(store, "tower_holder", h.style, h.pos, h.rally_pos, nil, h.id, nil, h.id)
		end
	end

	local x

	self.nav_mesh = {
		{
			10,
			x,
			x,
			2
		},
		{
			5,
			1,
			17,
			5
		},
		{
			4,
			x,
			5,
			8
		},
		{
			11,
			10,
			3,
			13
		},
		{
			3,
			2,
			2,
			6
		},
		{
			8,
			5,
			17,
			16
		},
		{
			9,
			8,
			16,
			x
		},
		{
			13,
			3,
			6,
			7
		},
		{
			15,
			13,
			7,
			x
		},
		{
			11,
			x,
			1,
			4
		},
		{
			12,
			10,
			4,
			12
		},
		{
			x,
			11,
			13,
			15
		},
		{
			12,
			4,
			8,
			14
		},
		{
			12,
			13,
			9,
			15
		},
		{
			12,
			14,
			9,
			x
		},
		{
			7,
			6,
			17,
			x
		},
		{
			6,
			2,
			x,
			16
		},
		{
			x,
			x,
			x,
			x
		},
		{
			x,
			x,
			x,
			x
		},
		{
			x,
			x,
			x,
			x
		},
		{
			x,
			x,
			x,
			x
		},
		{
			x,
			x,
			x,
			x
		}
	}

	P:add_invalid_range(1, 1, 15)
	P:add_invalid_range(2, 1, 15)
	P:add_invalid_range(3, 1, 18)
	P:add_invalid_range(4, 1, 18)

	for i = 5, 9 do
		local home_enter_node = P:get_end_node(i) - 30

		P:add_invalid_range(i, home_enter_node, nil)
		P:add_invalid_range(i, nil, nil, NF_NO_EXIT)
	end

	local e
	-- local v_left = store.visible_coords.left
	-- local v_right = store.visible_coords.right
	-- local bats = {
	-- 	v(v_left, 0),
	-- 	v(0, 0),
	-- 	v(v_right - REF_W, 0),
	-- 	v(v_right - REF_W, 0),
	-- 	v(0, 0),
	-- 	v(v_left, 0)
	-- }

	-- for i, b in ipairs(bats) do
	-- 	e = E:create_entity("decal_bat_flying_" .. i)
	-- 	e.pos = b

	-- 	LU.queue_insert(store, e)
	-- end

	local home_pi = 9
	local home_node = {
		spi = 1,
		dir = 1,
		pi = home_pi,
		ni = P:get_end_node(home_pi) - 1
	}
	local home_pos = P:node_pos(home_node)

	self.home_node = home_node
	self.home_pos = home_pos

	local CRYSTAL_OFF_Y = 45

	if store.level_mode ~= GAME_MODE_CAMPAIGN then
		e = E:create_entity("decal")
		e.render.sprites[1].name = "boss_corps_thing_0001"
		e.render.sprites[1].animated = false
		e.pos.x, e.pos.y = 306, 581

		LU.queue_insert(store, e)

		e = E:create_entity("decal")
		e.render.sprites[1].name = "boss_corps_thing_0002"
		e.render.sprites[1].animated = false
		e.pos.x, e.pos.y = 873, 497

		LU.queue_insert(store, e)

		e = E:create_entity("umbra_crystals_broken")
		e.pos.x, e.pos.y = self.home_pos.x, self.home_pos.y + CRYSTAL_OFF_Y

		LU.queue_insert(store, e)
	else
		self.crystals = E:create_entity("umbra_crystals")
		self.crystals.pos = table.deepclone(home_pos)
		self.crystals.pos.y = self.crystals.pos.y + CRYSTAL_OFF_Y

		LU.queue_insert(store, self.crystals)

		local OFF_GUY = v(-3, -75)
		local OFF_FF = v(-2, -47)

		e = E:create_entity("umbra_guy_force_field")
		e.pos.x, e.pos.y = home_pos.x + OFF_FF.x, home_pos.y + OFF_FF.y

		LU.queue_insert(store, e)

		self.guy_force_field = e
		e = E:create_entity("umbra_guy")
		e.pos.x, e.pos.y = home_pos.x + OFF_GUY.x, home_pos.y + OFF_GUY.y

		LU.queue_insert(store, e)

		self.guy = e
	end

	e = E:create_entity("background_sounds_underground")

	LU.queue_insert(store, e)
end

function level:update(store)
	LU.insert_hero(store)

	if store.level_mode == GAME_MODE_CAMPAIGN then
		U.y_wait(store, 2)

		self.guy.phase = "intro"

		while store.wave_group_number < 1 do
			coroutine.yield()
		end

		while self.guy.phase ~= "intro-finished" do
			coroutine.yield()
		end

		while not store.waves_finished or LU.has_alive_enemies(store) do
			coroutine.yield()
		end

		U.y_wait(store, 3)
		signal.emit("show-curtains")
		signal.emit("pan-zoom-camera", 2.5, {
			x = 560,
			y = 600
		}, 1.5)
		signal.emit("hide-gui")
		S:queue("MusicBossPreFight")

		self.guy.phase = "death"

		while self.guy.phase ~= "death-started" do
			coroutine.yield()
		end

		self.crystals.phase = "crack"

		U.y_wait(store, 4.1)
		LU.queue_remove(store, self.guy_force_field)
		U.y_wait(store, 0.3)

		self.boss = E:create_entity("eb_umbra")
		self.boss.home_node = table.deepclone(self.home_node)

		LU.queue_insert(store, self.boss)

		while self.boss.phase ~= "loop" do
			coroutine.yield()
		end

		signal.emit("hide-curtains")
		signal.emit("pan-zoom-camera", 2, {
			x = 512,
			y = 384
		}, 1)
		signal.emit("show-gui")
		S:queue("MusicBossFight2")

		while self.boss.phase ~= "death-animation" do
			coroutine.yield()
		end

		signal.emit("hide-gui", true)

		for _, e in pairs(store.entities) do
			if e and e.tower then
				e.tower.blocked = true
			end
		end

		while self.boss.phase ~= "dead" do
			coroutine.yield()
		end

		store.custom_game_outcome = {
			next_item_name = "kr2_end"
		}
	else
		while store.wave_group_number < 1 do
			coroutine.yield()
		end

		while not store.waves_finished or LU.has_alive_enemies(store) do
			coroutine.yield()
		end
	end

	log.debug("-- WON")
end

return level
