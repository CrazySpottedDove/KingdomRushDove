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
local v = V.v
local P = require("path_db")
local SU = require("script_utils")
local band = bit.band
local function fts(v)
	return v / FPS
end

local controller_stage_15_cult_leader_tower = {}

function controller_stage_15_cult_leader_tower.update(this, store)
	local last_wave_processed = 0
	local last_attack_ts = store.tick_ts
	local attack_cd

	U.animation_start_group(this, "idlenothing", nil, store.tick_ts, true, "layers")

	this.boss_fight_started = false
	this.soldiers_grabbed = 0

	while true do
		if store.wave_group_number == 0 then
		-- block empty
		else
			if store.wave_group_number ~= last_wave_processed then
				last_wave_processed = store.wave_group_number
				attack_cd = this.config_per_wave[store.wave_group_number].tentacle_cd

				if last_wave_processed == 1 then
					last_attack_ts = store.tick_ts
				end
			end

			if this.transform_out then
				this.transform_out = nil

				U.y_wait_unconditional(store, 2)
				signal.emit("show-curtains")
				signal.emit("pan-zoom-camera", 2, {
					x = 680,
					y = 860
				}, 2)
				signal.emit("hide-gui")
				signal.emit("start-cinematic")
				U.y_wait_unconditional(store, 2)
				S:queue("Stage15MydriasEnter")
				U.y_animation_play_group(this, "enter", nil, store.tick_ts, 1, "layers")
				U.animation_start_group(this, "idleup", nil, store.tick_ts, true, "layers")
				signal.emit("show-balloon_tutorial", "LV15_CULTIST03", false)
				U.y_wait_unconditional(store, 4)
				signal.emit("show-balloon_tutorial", "LV15_CULTIST04", false)
				U.y_wait_unconditional(store, 4)
				S:queue("Stage15MutatedMydriasEnter")
				U.y_animation_play_group(this, "transform", nil, store.tick_ts, 1, "layers")
				U.animation_start_group(this, "transformloop", nil, store.tick_ts, true, "layers")
				U.y_animation_play_group(this, "transform2", nil, store.tick_ts, 1, "layers")
				U.y_wait_unconditional(store, fts(60))

				local boss = E:create_entity(this.boss_to_spawn)

				simulation:queue_insert_entity(boss)
				U.y_wait_unconditional(store, 2)

				local denas = E:create_entity("soldier_reinforcement_stage_15_denas")

				denas.pos = v(560, 440)
				denas.nav_rally.center = V.vclone(denas.pos)
				denas.nav_rally.pos = V.vclone(denas.pos)
				denas.reinforcement.squad_id = denas.id

				simulation:queue_insert_entity(denas)
				U.y_wait_unconditional(store, 2)
				signal.emit("show-balloon_tutorial", "LV15_DENAS01", false)
				U.y_wait_unconditional(store, 4)
				S:stop_group("MUSIC")
				S:queue("MusicBossFight_115")
				signal.emit("hide-curtains")
				signal.emit("pan-zoom-camera", 2, {
					x = 400,
					y = 400
				}, 1.3)
				signal.emit("show-gui")
				signal.emit("end-cinematic")

				this.boss_fight_started = true
			end

			if this.boss_fight_started and this.boss_dead then
				simulation:queue_remove_entity(this)
			end

			if this.boss_fight_started and this.boss_teleport then
				this.boss_teleport = nil

				local soldiers = table.filter(store.entities, function(k, v)
					return not v.pending_removal and v.soldier and v.vis and v.health and not v.health.dead and band(v.vis.flags, this.bans) == 0 and band(v.vis.bans, this.flags) == 0
				end)
				local soldier_groups = {}

				local function closest_soldier_group(pos)
					local closest_group
					local closest_distance = 1e+99

					for _, soldier_group in ipairs(soldier_groups) do
						local soldier_distance = V.dist(soldier_group.pos.x, soldier_group.pos.y, pos.x, pos.y)

						if soldier_distance < closest_distance then
							closest_distance = soldier_distance
							closest_group = soldier_group
						end
					end

					return closest_group, closest_distance
				end

				if soldiers and #soldiers > 0 then
					for _, soldier in ipairs(soldiers) do
						local closest_group, closest_distance = closest_soldier_group(V.vclone(soldier.pos))

						if closest_group and closest_distance < this.distance_to_group then
							table.insert(closest_group.soldiers, soldier)
						else
							table.insert(soldier_groups, {
								soldiers = {soldier},
								pos = V.vclone(soldier.pos)
							})
						end
					end
				end

				if soldier_groups and #soldier_groups > 0 then
					for _, soldier_group in ipairs(soldier_groups) do
						local surrounded_soldier = U.find_entity_most_surrounded(soldier_group.soldiers)
						local aura = E:create_entity(this.aura)
						local nearest_nodes = P:nearest_nodes(surrounded_soldier.pos.x, surrounded_soldier.pos.y, nil, {1}, true)
						local pi, spi, ni = unpack(nearest_nodes[1])
						local npos = P:node_pos(pi, spi, ni)

						aura.pos = npos
						aura.aura.source_id = this.id
						aura.aura.ts = store.tick_ts
						aura.mod_duration = this.config_per_wave[store.wave_group_number].tentacle_duration

						simulation:queue_insert_entity(aura)
					end
				end
			end

			if not this.boss_fight_started and attack_cd <= store.tick_ts - last_attack_ts then
				U.y_animation_play_group(this, "enter", nil, store.tick_ts, 1, "layers")
				U.animation_start_group(this, "idleup", nil, store.tick_ts, true, "layers")
				SU.y_show_taunt_set(store, this.taunts, "in_bossfight", false)
				U.y_wait_unconditional(store, math.random(this.time_before_attack_min, this.time_before_attack_max))
				U.y_animation_wait_group(this, "layers")

				local start_ts = store.tick_ts

				U.y_animation_play_group(this, "attack", nil, store.tick_ts, 1, "layers")
				U.animation_start_group(this, "attackloop", nil, store.tick_ts, true, "layers")

				local soldiers = table.filter(store.entities, function(k, v)
					return not v.pending_removal and v.soldier and v.vis and v.health and not v.health.dead and band(v.vis.flags, this.bans) == 0 and band(v.vis.bans, this.flags) == 0
				end)
				local soldier_groups = {}

				local function closest_soldier_group(pos)
					local closest_group
					local closest_distance = 1e+99

					for _, soldier_group in ipairs(soldier_groups) do
						local soldier_distance = V.dist(soldier_group.pos.x, soldier_group.pos.y, pos.x, pos.y)

						if soldier_distance < closest_distance then
							closest_distance = soldier_distance
							closest_group = soldier_group
						end
					end

					return closest_group, closest_distance
				end

				if soldiers and #soldiers > 0 then
					for _, soldier in ipairs(soldiers) do
						local closest_group, closest_distance = closest_soldier_group(V.vclone(soldier.pos))

						if closest_group and closest_distance < this.distance_to_group then
							table.insert(closest_group.soldiers, soldier)
						else
							table.insert(soldier_groups, {
								soldiers = {soldier},
								pos = V.vclone(soldier.pos)
							})
						end
					end
				end

				if soldier_groups and #soldier_groups > 0 then
					soldier_groups = table.random_order(soldier_groups)
					soldier_groups = table.slice(soldier_groups, 1, this.config_per_wave[store.wave_group_number].targets_amount)

					for _, soldier_group in ipairs(soldier_groups) do
						local surrounded_soldier = U.find_entity_most_surrounded(soldier_group.soldiers)
						local aura = E:create_entity(this.aura)
						local nearest_nodes = P:nearest_nodes(surrounded_soldier.pos.x, surrounded_soldier.pos.y, nil, {1}, true)
						local pi, spi, ni = unpack(nearest_nodes[1])
						local npos = P:node_pos(pi, spi, ni)

						aura.pos = npos
						aura.aura.source_id = this.id
						aura.aura.ts = store.tick_ts
						aura.mod_duration = this.config_per_wave[store.wave_group_number].tentacle_duration

						simulation:queue_insert_entity(aura)
					end
				end

				U.y_wait_unconditional(store, fts(30))
				U.y_animation_wait_group(this, "layers")
				U.y_animation_play_group(this, "attackleave", nil, store.tick_ts, 1, "layers")

				last_attack_ts = start_ts

				U.animation_start_group(this, "idleup", nil, store.tick_ts, true, "layers")
				U.y_wait_unconditional(store, math.random(this.time_to_leave_after_attack_min, this.time_to_leave_after_attack_max))
				U.y_animation_play_group(this, "leave", nil, store.tick_ts, 1, "layers")
			end
		end

		coroutine.yield()
	end
end

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

local controller_terrain_3_stage_15_glare = {}

function controller_terrain_3_stage_15_glare.insert(this, store)
	return true
end

function controller_terrain_3_stage_15_glare.update(this, store)
	local waves_glare = table.filter(store.entities, function(k, v)
		return v.template_name == "controller_terrain_3_local_glare"
	end)[1]

	while not this.phase do
		coroutine.yield()
	end

	waves_glare.force_finish = true
	this.eyes = {}

	for _, v in pairs(this.eyes_t) do
		local eye = E:create_entity(v)

		eye.ts = store.tick_ts
		eye.pos = this.pos
		eye.controller_ref = this

		simulation:queue_insert_entity(eye)
		U.animation_start(eye, "idle_close", nil, store.tick_ts, true, this.sid_eyelids)
		table.insert(this.eyes, eye)
	end

	local last_phase = 0

	while true do
		if this.phase == last_phase or #this.phases < this.phase then
		-- block empty
		elseif not this.phases[this.phase] then
		-- block empty
		elseif this.phases[this.phase][1] < 0 then
		-- block empty
		else
			last_phase = this.phase

			local phase_start_ts = store.tick_ts
			local d_delay, d_duration = unpack(this.phases[this.phase])
			local delay = d_delay - (store.tick_ts - phase_start_ts)
			local aura, decal
			local start_ts = store.tick_ts

			for i = 1, #this.eyes do
				while store.tick_ts - start_ts < delay - 2 * (#this.eyes - i) do
					if last_phase ~= this.phase then
						goto label_1236_skip
					end

					coroutine.yield()
				end

				if i == 1 then
					U.animation_start(this.eyes[1], "loop", nil, store.tick_ts, true, this.sid_eyelids)
				end

				if i == 1 or i == 2 then
					S:queue(this.sound_small_eye_1)
				elseif i == 3 then
					S:queue(this.sound_small_eye_2)
				elseif i == 4 then
					S:queue(this.sound_big_eye)
				end

				U.y_animation_play(this.eyes[#this.eyes + 1 - i], "open", nil, store.tick_ts, 1, this.sid_eyelids)
				U.animation_start(this.eyes[#this.eyes + 1 - i], "idle_open", nil, store.tick_ts, true, this.sid_eyelids)
			end

			this.glare_active = true
			aura = E:create_entity(this.aura_glare)
			aura.aura.ts = store.tick_ts
			aura.pos = V.vclone(this.pos)
			aura.render.sprites[1].scale.x = aura.aura.radius / 137
			aura.render.sprites[1].scale.y = ASPECT * aura.aura.radius / 137
			aura.render.sprites[1].hidden = true

			simulation:queue_insert_entity(aura)

			decal = E:create_entity(this.decal_ground)
			decal.pos = V.vclone(this.pos)

			simulation:queue_insert_entity(decal)
			U.y_animation_play(decal, "in", nil, store.tick_ts)
			U.animation_start_default(decal, "idle", nil, store.tick_ts, true)

			start_ts = store.tick_ts

			while d_duration > store.tick_ts - start_ts do
				if last_phase ~= this.phase then
					break
				end

				if store.tick_ts - start_ts > d_duration - 1 and not this.eyes[1].dont_blink then
					for _, eye in pairs(this.eyes) do
						eye.dont_blink = true
					end
				end

				coroutine.yield()
			end

			::label_1236_0::

			S:queue(this.sound_off)

			for i = 1, #this.eyes do
				U.y_wait_unconditional(store, fts(math.random(0, 5)))
				U.y_animation_play(this.eyes[#this.eyes + 1 - i], "close", nil, store.tick_ts, 1, this.sid_eyelids)
				U.animation_start(this.eyes[#this.eyes + 1 - i], "idle_close", nil, store.tick_ts, true, this.sid_eyelids)

				this.eyes[#this.eyes + 1 - i].dont_blink = false
			end

			this.glare_active = false

			simulation:queue_remove_entity(aura)
			U.y_animation_play(decal, "out", nil, store.tick_ts)
			simulation:queue_remove_entity(decal)

			::label_1236_skip::
		end

		coroutine.yield()
	end
end

tt = E:register_t_hot("controller_terrain_3_stage_15_glare", "controller_terrain_3_local_glare", true)
tt.main_script.insert = controller_terrain_3_stage_15_glare.insert
tt.main_script.update = controller_terrain_3_stage_15_glare.update

tt = E:register_t_hot("controller_stage_15_cult_leader_tower", nil, true)
E:add_comps(tt, "editor", "pos", "main_script", "render")
tt.main_script.update = controller_stage_15_cult_leader_tower.update
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].prefix = "mydrias_finalstage_bottomDef"
tt.render.sprites[1].name = "idleup"
tt.render.sprites[1].exo = true
tt.render.sprites[1].group = "layers"
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 10
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "mydrias_finalstage_topDef"
tt.render.sprites[2].name = "idleup"
tt.render.sprites[2].exo = true
tt.render.sprites[2].group = "layers"
tt.render.sprites[2].z = Z_OBJECTS_COVERS + 20
tt.render.sprites[2].offset = v(-2, 2)
tt.config_per_wave = {
	{
		tentacle_duration = 6,
		targets_amount = 1,
		tentacle_cd = 30
	},
	{
		tentacle_duration = 6,
		targets_amount = 1,
		tentacle_cd = 30
	},
	{
		tentacle_duration = 6,
		targets_amount = 1,
		tentacle_cd = 40
	},
	{
		tentacle_duration = 6,
		targets_amount = 1,
		tentacle_cd = 30
	},
	{
		tentacle_duration = 6,
		targets_amount = 1,
		tentacle_cd = 25
	},
	{
		tentacle_duration = 6,
		targets_amount = 1,
		tentacle_cd = 30
	},
	{
		tentacle_duration = 6,
		targets_amount = 1,
		tentacle_cd = 30
	},
	{
		tentacle_duration = 6,
		targets_amount = 1,
		tentacle_cd = 30
	},
	{
		tentacle_duration = 6,
		targets_amount = 1,
		tentacle_cd = 30
	},
	{
		tentacle_duration = 6,
		targets_amount = 2,
		tentacle_cd = 30
	},
	{
		tentacle_duration = 6,
		targets_amount = 2,
		tentacle_cd = 30
	},
	{
		tentacle_duration = 6,
		targets_amount = 2,
		tentacle_cd = 30
	},
	{
		tentacle_duration = 6,
		targets_amount = 2,
		tentacle_cd = 30
	},
	{
		tentacle_duration = 6,
		targets_amount = 2,
		tentacle_cd = 30
	},
	{
		tentacle_duration = 6,
		targets_amount = 2,
		tentacle_cd = 30
	},
	{
		tentacle_duration = 6,
		targets_amount = 2,
		tentacle_cd = 30
	},
	{
		tentacle_duration = 6,
		targets_amount = 2,
		tentacle_cd = 30
	}
}
tt.time_to_leave_after_attack_min = 2
tt.time_to_leave_after_attack_max = 4
tt.time_before_attack_min = 2
tt.time_before_attack_max = 4
tt.distance_to_group = 100
tt.bans = bor(F_FLYING)
tt.flags = bor(F_FRIEND, F_MOD)
tt.aura = "aura_stage_15_cult_leader_tower_stun"
tt.boss_to_spawn = "boss_cult_leader"

tt = E:register_t_hot("decal_stage_15_glare", "decal_stage_12_glare", true)
tt.render.sprites[1].prefix = "stage_15_glareDef"

