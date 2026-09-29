local signal = require("lib.hump.signal")
local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local V = require("lib.klua.vector")
require("lib.klua.table")
local scripts = require("scripts")
local r = V.r
local decal_stage_15_easter_egg_goblin_update
local power_stage_15_denas_control_insert
decal_stage_15_easter_egg_goblin_update = function(this, store)
	local portal_spawned = false
	local decal_portal
	local function check_click_and_spawn_portal()
		if not portal_spawned and this.ui.clicked then
			this.ui.clicked = nil
			decal_portal = E:create_entity("decal_stage_15_easter_egg_goblin_portal")
			decal_portal.pos = V.vclone(this.pos)
			simulation:queue_insert_entity(decal_portal)
			U.animation_start_default(decal_portal, "in", nil, store.tick_ts, false)
			portal_spawned = true
		end
		if decal_portal and U.animation_finished_default(decal_portal) then
			U.animation_start_default(decal_portal, "loop", nil, store.tick_ts, true)
		end
	end
	if store.level_mode == GAME_MODE_CAMPAIGN then
		this.render.sprites[1].hidden = true
		while not this.cult_leader_tower.boss_fight_started do
			coroutine.yield()
		end
		local out_ts = store.tick_ts
		local is_out = false
		local sweep_ts = store.tick_ts
		while true do
			if is_out then
				if portal_spawned then
					U.animation_start_default(this, "tap", nil, store.tick_ts, false)
					U.y_wait_unconditional(store, 0.2)
					S:queue("Stage15RiffPortalOpen")
					U.y_wait_unconditional(store, 0.3)
					simulation:queue_remove_entity(decal_portal)
					U.y_wait_unconditional(store, 2.7)
					S:queue("Stage15RiffPortalBroom")
					U.y_wait_unconditional(store, 2.6)
					S:queue("Stage15RiffPortalClose")
					U.y_animation_wait_default(this)
					break
				else
					check_click_and_spawn_portal()
				end
				if store.tick_ts - sweep_ts >= this.sweep_cooldown then
					sweep_ts = store.tick_ts
					U.animation_start_default(this, "sweeping", nil, store.tick_ts, false)
				end
				if store.tick_ts - out_ts >= this.time_to_in_cooldown then
					U.y_animation_play(this, "leave", nil, store.tick_ts)
					this.render.sprites[1].hidden = true
					is_out = false
					out_ts = store.tick_ts
				end
			elseif store.tick_ts - out_ts >= this.out_cooldown then
				out_ts = store.tick_ts
				this.render.sprites[1].hidden = false
				U.animation_start_default(this, "in", nil, store.tick_ts, false)
				local min_time_in_ts = store.tick_ts
				local min_time_cooldown = 2
				while not U.animation_finished_default(this) do
					if min_time_cooldown <= store.tick_ts - min_time_in_ts then
						check_click_and_spawn_portal()
					end
					coroutine.yield()
				end
				this.ui.clicked = nil
				is_out = true
				sweep_ts = store.tick_ts
			end
			coroutine.yield()
		end
	end
	signal.emit("goblintap-stage15")
	simulation:queue_remove_entity(this)
end
power_stage_15_denas_control_insert = function(this, store)
	local denas = E:create_entity(this.denas_t)
	denas.pos = V.vclone(this.pos)
	denas.nav_rally.center = V.vclone(this.pos)
	denas.nav_rally.pos = V.vclone(denas.pos)
	denas.reinforcement.squad_id = this.id
	simulation:queue_insert_entity(denas)
	return true
end
local tt
tt = E:register_t_hot("decal_terrain_3_glare_eye_small_2_stage_15", "decal_terrain_3_glare_eye_small", true)
tt.render.sprites[1].prefix = "glare_stage_15_eyes_2"
tt.render.sprites[2].prefix = "glare_stage_15_eyelids_2"
tt = E:register_t_hot("decal_stage_15_easter_egg_goblin", "decal_scripted", true)
E:add_comps(tt, "ui")
tt.main_script.update = decal_stage_15_easter_egg_goblin_update
tt.render.sprites[1].prefix = "t3stage15_eastereggDef"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 10
tt.out_cooldown = 5
tt.sweep_cooldown = 2
tt.time_to_in_cooldown = 20
tt.ui.click_rect = r(-10, -30, 50, 50)
tt = E:register_t_hot("decal_stage_15_tentacles", "decal_stage_12_tentacles", true)
tt.render.sprites[1].prefix = "BKtentacle_S15Def"
tt = E:register_t_hot("decal_terrain_3_glare_eye_small_1_stage_15", "decal_terrain_3_glare_eye_small", true)
tt.render.sprites[1].prefix = "glare_stage_15_eyes_1"
tt.render.sprites[2].prefix = "glare_stage_15_eyelids_1"
tt = E:register_t_hot("decal_stage_15_mask_1", "decal", true)
tt.render.sprites[1].name = "T3_15_mask_01"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t_hot("decal_stage_15_mask_2", "decal_stage_15_mask_1", true)
tt.render.sprites[1].name = "T3_15_mask_02"
tt = E:register_t_hot("power_denas_control", "power_reinforcements_control", true)
tt.main_script.insert = power_stage_15_denas_control_insert
tt.denas_t = "soldier_reinforcement_stage_15_denas"
function tt.power_cooldown_fn()
	return E:get_template("soldier_reinforcement_stage_15_denas").power_cooldown
end
tt = E:register_t_hot("decal_terrain_3_glare_eye_small_3_stage_15", "decal_terrain_3_glare_eye_small", true)
tt.render.sprites[1].prefix = "glare_stage_15_eyes_3"
tt.render.sprites[2].prefix = "glare_stage_15_eyelids_3"
tt = E:register_t_hot("decal_stage_15_mask_5", "decal_stage_15_mask_1", true)
tt.render.sprites[1].name = "T3_15_mask_05"
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t_hot("decal_stage_15_mask_modes", "decal", true)
E:add_comps(tt, "editor")
tt.render.sprites[1].name = "stage15modos"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 20
tt = E:register_t_hot("decal_stage_15_mask_3", "decal_stage_15_mask_1", true)
tt.render.sprites[1].name = "T3_15_mask_03"
tt = E:register_t_hot("decal_terrain_3_glare_eye_big_stage_15", "decal_terrain_3_glare_eye_big", true)
tt.render.sprites[1].name = "glare_stage_15_eye_big"
tt.render.sprites[2].prefix = "glare_stage_15_eyelids_big"
tt.render.sprites[3].prefix = "glare_stage_15_eye_big_pupil"
tt = E:register_t_hot("decal_stage_15_mask_4", "decal_stage_15_mask_1", true)
tt.render.sprites[1].name = "T3_15_mask_04"
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t_hot("decal_stage_15_cult_leader_tower_mask", "decal", true)
E:add_comps(tt, "editor")
tt.render.sprites[1].name = "mutamydrias_fx_Mutamydrias_balcon"
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 15
tt.render.sprites[1].animated = false
tt = E:register_t_hot("taunts_s115_controller", nil, true)
E:add_comps(tt, "main_script", "taunts", "editor")
tt.load_file = "level115_taunts"
tt.main_script.insert = scripts.taunts_controller.insert
tt.main_script.update = scripts.taunts_controller.update
tt.taunts.delay_min = 10
tt.taunts.sets = {}
tt.taunts.sets.stage_15_cult_leader_greetings = CC("taunt_set")
tt.taunts.sets.stage_15_cult_leader_greetings.format = "TAUNT_STAGE15_CULTIST_%04i"
tt.taunts.sets.stage_15_cult_leader_greetings.decal_name = "decal_stage15_cultist_shoutbox"
tt.taunts.sets.in_bossfight = CC("taunt_set")
tt.taunts.sets.in_bossfight.format = "LV15_CULTIST01_BOSSFIGHT_%02i"
tt.taunts.sets.in_bossfight.decal_name = "decal_stage11_cultist_shoutbox"
tt.taunts.sets.in_bossfight.end_idx = 6
