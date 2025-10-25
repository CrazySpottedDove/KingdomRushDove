-- chunkname: @/var/folders/r9/xbxmw8n51957gv9ggzrytvf80000gp/T/com.ironhidegames.frontiers.windows.steam.ep3S4swo/kr2/data/levels/level01.lua

local log = require("klua.log"):new("level01")
local signal = require("hump.signal")
local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local LU = require("level_utils")
local V = require("klua.vector")
local P = require("path_db")

require("constants")

local function fts(v)
	return v / FPS
end

local level = {}

level.required_sounds = {
	"music_stage27",
	"Level1SpecialEnding"
}
level.required_textures = {
	"go_enemies_desert",
	"go_stages_desert",
	"go_stage27",
	"go_stage27_bg"
}
level.show_comic_idx = 10

function level:init(store)
	store.level_terrain_type = TERRAIN_STYLE_DESERT
	self.locations = LU.load_locations(store, self)

	if store.level_mode == GAME_MODE_CAMPAIGN then
		self.locked_powers = {
			-- true,
			-- true
		}
		self.locked_hero = false
		self.max_upgrade_level = 6
		self.locked_towers = {
			"tower_archer_2",
			"tower_barrack_2",
			"tower_engineer_2",
			"tower_mage_2",
		}
	elseif store.level_mode == GAME_MODE_HEROIC then
		self.locked_hero = true
		self.max_upgrade_level = 2
		self.locked_towers = {
			"tower_archer_2",
			"tower_barrack_2",
			"tower_engineer_2",
			"tower_mage_2",
		}
	elseif store.level_mode == GAME_MODE_IRON then
		self.locked_hero = true
		self.max_upgrade_level = 2
		self.locked_towers = {
			"tower_barrack_2",
			"tower_build_archer",
			"tower_build_mage",
			"tower_engineer_2",
		}
	end

	-- self.show_next_wave_balloon = nil
end

function level:load(store)
	LU.insert_background(store, "Stage01_0001", Z_BACKGROUND)
	LU.insert_background(store, "Stage01_0002", Z_OBJECTS, 356)
	LU.insert_defend_points(store, self.locations.exits, store.level_terrain_type)

	for _, h in pairs(self.locations.holders) do
		if h.id == "5" or h.id == "10" then
			LU.insert_tower(store, "tower_archer_hammerhold", h.style, h.pos, h.rally_pos, nil, h.id)
		else
			LU.insert_tower(store, "tower_holder", h.style, h.pos, h.rally_pos, nil, h.id)
		end
	end

	local x

	self.nav_mesh = {
		{
			4,
			8,
			x,
			2
		},
		{
			3,
			1,
			12,
			31
		},
		{
			x,
			4,
			2,
			31
		},
		{
			x,
			7,
			1,
			3
		},
		{
			x,
			4,
			3,
			31
		},
		[7] = {
			x,
			71,
			8,
			4
		},
		[8] = {
			7,
			71,
			9,
			1
		},
		[9] = {
			71,
			x,
			x,
			8
		},
		[10] = {
			8,
			9,
			x,
			12
		},
		[12] = {
			31,
			2,
			x,
			x
		},
		[31] = {
			x,
			3,
			12,
			x
		},
		[71] = {
			x,
			x,
			9,
			7
		}
	}

	P:add_invalid_range(1, 191, nil)
	P:add_invalid_range(2, 191, nil)

	local e

	e = E:create_entity("decal")
	e.render.sprites[1].name = "Stage1_Hammer"
	e.render.sprites[1].animated = false
	e.pos.x, e.pos.y = 507, 428

	LU.queue_insert(store, e)

	e = E:create_entity("decal")
	e.render.sprites[1].name = "decal_stage01_flag"
	e.pos.x, e.pos.y = -126, 474

	LU.queue_insert(store, e)

	e = E:create_entity("decal")
	e.render.sprites[1].name = "decal_stage01_flag"
	e.render.sprites[1].ts = 0.34
	e.pos.x, e.pos.y = -110, 584

	LU.queue_insert(store, e)
end

function level:update(store)
	if store.level_mode == GAME_MODE_CAMPAIGN then
		-- self.manual_hero_insertion = true

		-- signal.emit("show-balloon", "TB_START")
		-- signal.emit("show-balloon", "TB_BUILD")
		-- signal.emit("focus-holder", "4")
		-- coroutine.yield()
		-- signal.emit("wave-notification", "view", "TUTORIAL_1")

		-- if store.selected_hero and store.selected_hero ~= "hero_alric" then
		-- 	LU.insert_hero(store)
		-- end

		-- while store.wave_group_number < 1 do
		-- 	coroutine.yield()
		-- end

		-- self.show_next_wave_balloon = true

		-- while store.wave_group_number < 4 do
		-- 	coroutine.yield()
		-- end

		-- if store.selected_hero and store.selected_hero == "hero_alric" then
		-- 	S:queue("HeroAlricTaunt")
		-- 	signal.emit("wave-notification", "view", "TIP_HEROES")

		-- 	while store.paused do
		-- 		coroutine.yield()
		-- 	end

		-- 	log.debug("-- Move alric behind wall")

		-- 	local hero = LU.insert_hero(store)

		-- 	hero.pos = V.v(-120, 406)
		-- 	hero.nav_rally.center = V.v(246, 406)
		-- 	hero.nav_rally.pos = V.vclone(hero.nav_rally.center)
		-- end

		while not store.waves_finished or LU.has_alive_enemies(store) do
			coroutine.yield()
		end

		log.debug("-- WON")
		signal.emit("hide-gui")
		signal.emit("show-curtains")
		signal.emit("pan-zoom-camera", 1.5, V.v(341.3333333333333, 480), 1.4)
		U.y_wait(store, 1)
		self:y_end_cinematic(store)
		signal.emit("hide-curtains")
	end
end

function level:y_end_cinematic(store)
	local function y_move(store, entity, to, duration, easing)
		local from = V.vclone(entity.pos)
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

	local boss_pos_1 = V.v(-180, 394)
	local boss_pos_2 = V.v(130, 394)
	local boss_pos_3 = V.v(REF_H * 16 / 9 + 100, 394)
	local shoutbox_pos = V.v(193, 553)

	S:queue("MusicBossPreFight")

	local towers = E:filter(store.entities, "tower")
	local tower_blocks = {}

	for _, e in pairs(towers) do
		if not e.tower_holder then
			local block = E:create_entity("decal_stage01_tower_block")

			block.pos.x, block.pos.y = e.pos.x, e.pos.y

			LU.queue_insert(store, block)
			U.animation_start(block, "start", nil, store.tick_ts)
			table.insert(tower_blocks, block)
		end
	end

	if #tower_blocks > 0 then
		S:queue("Level1SpecialEndingHoldCast")
	end

	local boss = E:create_entity("decal_stage01_boss")

	boss.pos = boss_pos_1

	LU.queue_insert(store, boss)
	U.y_wait(store, fts(55))
	S:queue("Level1SpecialEndingCinematic")
	y_move(store, boss, boss_pos_2, fts(90), "quad-in")

	local shoutbox = E:create_entity("decal_stage01_shoutbox")

	shoutbox.pos = shoutbox_pos
	shoutbox.texts.list[1].text = _("resistance is futile!")

	LU.queue_insert(store, shoutbox)
	U.y_wait(store, fts(84))
	LU.queue_remove(store, shoutbox)

	shoutbox = E:create_entity("decal_stage01_shoutbox")
	shoutbox.pos = shoutbox_pos
	shoutbox.texts.list[1].text = _("Your end is coming soon!")

	LU.queue_insert(store, shoutbox)
	U.y_wait(store, fts(95))
	LU.queue_remove(store, shoutbox)

	shoutbox = E:create_entity("decal_stage01_shoutbox")
	shoutbox.pos = shoutbox_pos
	shoutbox.texts.list[1].text = _("Muahahahahahahahahaha!")

	LU.queue_insert(store, shoutbox)
	U.y_wait(store, fts(115))
	LU.queue_remove(store, shoutbox)
	U.y_wait(store, fts(10))
	y_move(store, boss, boss_pos_3, 2.25, "quad-out")
	LU.queue_remove(store, boss)

	for _, block in pairs(tower_blocks) do
		U.animation_start(block, "end", nil, store.tick_ts)
	end

	if #tower_blocks > 0 then
		S:queue("Level1SpecialEndingHoldDissipate")
		U.y_animation_wait(tower_blocks[1])
	end
end

return level
