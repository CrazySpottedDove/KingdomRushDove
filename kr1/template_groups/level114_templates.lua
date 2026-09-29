local E = require("entity_db")
local U = require("utils")
require("lib.klua.table")
local scripts = require("scripts")
local aura_stage_14_prevent_polymorph_update
aura_stage_14_prevent_polymorph_update = function(this, store)
	local first_hit_ts
	local last_hit_ts = 0
	local cycles_count = 0
	last_hit_ts = store.tick_ts - this.aura.cycle_time
	while true do
		if store.tick_ts - last_hit_ts >= this.aura.cycle_time then
			first_hit_ts = first_hit_ts or store.tick_ts
			last_hit_ts = store.tick_ts
			cycles_count = cycles_count + 1
			local targets = table.filter(store.enemies, function(k, v)
				return v.unit and v.health and not v.health.dead and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius) and not U.flag_has(v.vis.bans, F_POLYMORPH) and (v.nav_path.pi == 2 or v.nav_path.pi == 3) and (not this.aura.allowed_templates or table.contains(this.aura.allowed_templates, v.template_name))
			end)
			for i, target in ipairs(targets) do
				target.vis.bans = U.flag_set(target.vis.bans, F_POLYMORPH)
			end
		end
		coroutine.yield()
	end
	simulation:queue_remove_entity(this)
end
local tt
local decal_stage_14_easter_egg_rickmorty
local v = V.v
local S = require("sound_db")
local signal = require("lib.hump.signal")
decal_stage_14_easter_egg_rickmorty = {}

function decal_stage_14_easter_egg_rickmorty.update(this, store)
	local idle_cooldown = math.random(this.idle_cooldown_min, this.idle_cooldown_max)
	local idle_ts = store.tick_ts
	local click_amounts = 1

	while true do
		if this.ui.clicked then
			this.ui.clicked = nil

			if click_amounts == 3 then
				S:queue("Stage14RickPortal3Out")
				U.y_animation_play(this, "portal_open", nil, store.tick_ts, 1)

				break
			end

			S:queue("Stage14RickPortal12Open")
			S:queue("Stage14RickPortal12Open")
			U.animation_start_default(this, "portal_open", nil, store.tick_ts, false)
			U.y_wait_unconditional(store, 3)
			S:queue("Stage14RickPortal12Pass")
			U.y_wait_unconditional(store, 0.9)
			S:queue("Stage14RickPortal12Pass")
			U.y_wait_unconditional(store, 1)
			S:queue("Stage14RickPortal12Close")
			U.y_animation_wait_default(this)

			this.pos = this.pos_spawn[click_amounts]
			this.render.sprites[1].prefix = this.prefix_names[click_amounts]
			click_amounts = click_amounts + 1

			U.animation_start_default(this, "start", nil, store.tick_ts, false)
			U.y_wait_unconditional(store, 0)
			S:queue("Stage14RickPortalOpenNoLaser")
			U.y_wait_unconditional(store, 1)
			S:queue("Stage14RickPortal12Pass")
			U.y_wait_unconditional(store, 0.9)
			S:queue("Stage14RickPortal12Pass")

			if click_amounts == 3 then
				U.y_wait_unconditional(store, 0.7)
				S:queue("Stage14RickPortal12Pass")
				U.y_wait_unconditional(store, 0.4)
			else
				U.y_wait_unconditional(store, 1)
			end

			S:queue("Stage14RickPortal12Close")
			U.y_animation_wait_default(this)
			U.animation_start_default(this, "idle", nil, store.tick_ts, true)
		end

		if idle_cooldown <= store.tick_ts - idle_ts then
			U.y_animation_play(this, "idle_2", nil, store.tick_ts, 1)

			idle_cooldown = math.random(this.idle_cooldown_min, this.idle_cooldown_max)
			idle_ts = store.tick_ts

			U.animation_start_default(this, "idle", nil, store.tick_ts, false)
		end

		coroutine.yield()
	end

	signal.emit("rickmorty-stage14")
	simulation:queue_remove_entity(this)
end

local V = require("lib.klua.vector")
local controller_stage_14_amalgam = {}

function controller_stage_14_amalgam.update(this, store)
	local amalgams_spawned = 0
	local path_to_spawn = 7
	local change_path = false

	for _, v in pairs(store.entities) do
		if v.template_name == this.aura_t then
			this.aura_ref = v
			v.controller_ref = this

			break
		end
	end

	local function check_notify_achievement()
		if store.game_outcome and store.game_outcome.victory and amalgams_spawned == 0 then
			signal.emit("no_amalgams_spawned-stage14", this)
		end
	end

	::label_1255_0::

	this.sacrifices = 0

	while this.sacrifices < this.sacrifices_to_show_1 do
		check_notify_achievement()
		coroutine.yield()
	end

	local decal = E:create_entity(this.amalgam_decal_t)

	decal.render.sprites[1].ts = store.tick_ts
	decal.pos = V.vclone(this.amalgam_spawn_pos)

	simulation:queue_insert_entity(decal)
	S:queue(this.sound_1)
	U.y_animation_play(decal, "state_1", nil, store.tick_ts)
	U.animation_start_default(decal, "state_1_loop", nil, store.tick_ts, true)

	while this.sacrifices < this.sacrifices_to_show_2 do
		check_notify_achievement()
		coroutine.yield()
	end

	S:queue(this.sound_2)
	U.y_animation_play(decal, "state_2", nil, store.tick_ts)
	U.animation_start_default(decal, "state_2_loop", nil, store.tick_ts, true)

	while this.sacrifices < this.sacrifices_to_spawn do
		check_notify_achievement()
		coroutine.yield()
	end

	S:queue(this.sound_spawn)
	U.y_animation_play(decal, "spawn", nil, store.tick_ts)

	if amalgams_spawned == 0 then
		path_to_spawn = 7
	elseif change_path then
		if path_to_spawn == 6 then
			path_to_spawn = 7
		else
			path_to_spawn = 6
		end
	else
		local last_path = path_to_spawn

		path_to_spawn = math.random(6, 7)

		if path_to_spawn == last_path then
			change_path = true
		end
	end

	local amalgam = E:create_entity(this.amalgam_t)

	amalgam.pos = V.vclone(this.amalgam_spawn_pos)
	amalgam.nav_path.pi = path_to_spawn
	amalgam.source_id = this.id
	amalgam.render.sprites[1].hidden = true
	amalgam.spawned_from_lake = true

	local original_speed = amalgam.motion.max_speed

	amalgam.motion.max_speed = 0

	simulation:queue_insert_entity(amalgam)

	amalgam.motion.max_speed = original_speed

	simulation:queue_remove_entity(decal)

	amalgam.render.sprites[1].hidden = false

	amalgams_spawned = amalgams_spawned + 1

	goto label_1255_0
end

tt = E:register_t_hot("decal_terrain_3_glare_eye_big_stage_14", "decal_terrain_3_glare_eye_big", true)
tt.render.sprites[1].name = "glare_stage_14_eye_2_big"
tt.render.sprites[2].prefix = "glare_stage_14_eyelid_2_big"
tt.render.sprites[3].prefix = "glare_stage_14_eye_2_big_pupil"

tt = E:register_t_hot("decal_stage_14_glare_1", "decal_stage_12_glare", true)
tt.render.sprites[1].prefix = "stage_14_glare_1Def"

tt = E:register_t_hot("decal_terrain_3_glare_eye_small_3_stage_14", "decal_terrain_3_glare_eye_small", true)
tt.render.sprites[1].prefix = "glare_stage_14_eye_2_3"
tt.render.sprites[2].prefix = "glare_stage_14_eyelid_2_3"

tt = E:register_t_hot("decal_stage_14_glare_2", "decal_stage_12_glare", true)
tt.render.sprites[1].prefix = "stage_14_glare_2Def"

tt = E:register_t_hot("decal_terrain_3_glare_eye_small_2_stage_14", "decal_terrain_3_glare_eye_small", true)
tt.render.sprites[1].prefix = "glare_stage_14_eye_2_2"
tt.render.sprites[2].prefix = "glare_stage_14_eyelid_2_2"

tt = E:register_t_hot("decal_stage_14_hidden_path_dust", "decal", true)
tt.render.sprites[1].prefix = "dust_pathDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS

tt = E:register_t_hot("decal_stage_14_tentacles", "decal_stage_12_tentacles", true)
tt.render.sprites[1].prefix = "BKtentacle14Def"

tt = E:register_t_hot("aura_stage_14_prevent_polymorph", "aura", true)
tt.aura.duration = 1e+99
tt.aura.cycle_time = 0.25
tt.aura.radius = 100
tt.aura.allowed_templates = {"enemy_glareling"}
tt.main_script.update = aura_stage_14_prevent_polymorph_update

tt = E:register_t_hot("decal_terrain_3_glare_eye_small_1_stage_14", "decal_terrain_3_glare_eye_small", true)
tt.render.sprites[1].prefix = "glare_stage_14_eye_2_1"
tt.render.sprites[2].prefix = "glare_stage_14_eyelid_2_1"

tt = E:register_t_hot("decal_stage_14_hidden_path", "decal", true)
tt.render.sprites[1].prefix = "hidden_pathDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND_COVERS

tt = E:register_t_hot("decal_stage_14_easter_egg_rickmorty", "decal", true)
E:add_comps(tt, "editor", "main_script", "ui")
tt.main_script.update = decal_stage_14_easter_egg_rickmorty.update
tt.render.sprites[1].prefix = "Rick1Def"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS + 1
tt.idle_cooldown_min = 4
tt.idle_cooldown_max = 8
tt.ui.click_rect = r(-40, -30, 80, 50)
tt.pos_spawn = {v(130, 210), v(1033, 468)}
tt.prefix_names = {"Rick2Def", "Rick3Def"}

tt = E:register_t_hot("decal_stage_14_mask_1", "decal", true)
tt.render.sprites[1].name = "T3_S14_mask_01"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS

tt = E:register_t_hot("decal_controller_stage_14_amalgam", "decal_stage_14_mask_1", true)
tt.render.sprites[1].prefix = "Amalgam_dude"
tt.render.sprites[1].name = "state_1"
tt.render.sprites[1].animated = true

tt = E:register_t_hot("decal_stage_14_mask_amalgam", "decal_stage_14_mask_1", true)
tt.render.sprites[1].name = "T3_S14_mask_amalgam"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = 90

tt = E:register_t_hot("decal_stage_14_mask_3", "decal_stage_14_mask_1", true)
tt.render.sprites[1].name = "T3_S14_mask_03"

tt = E:register_t_hot("decal_stage_14_mask_2", "decal_stage_14_mask_1", true)
tt.render.sprites[1].name = "T3_S14_mask_02"

tt = E:register_t_hot("decal_stage_14_mask_4", "decal_stage_14_mask_1", true)
tt.render.sprites[1].name = "T3_S14_mask_04"

tt = E:register_t_hot("controller_stage_14_amalgam", nil, true)
E:add_comps(tt, "main_script")
tt.main_script.update = controller_stage_14_amalgam.update
tt.amalgam_t = "enemy_amalgam"
tt.amalgam_spawn_pos = v(501, 482)
tt.aura_t = "aura_controller_stage_14_amalgam"
tt.amalgam_decal_t = "decal_controller_stage_14_amalgam"
tt.sacrifices_to_show_1 = 1
tt.sacrifices_to_show_2 = 2
tt.sacrifices_to_spawn = 5
tt.sound_1 = "Stage14BehemothPoolSpawn1"
tt.sound_2 = "Stage14BehemothPoolSpawn2"
tt.sound_spawn = "Stage14BehemothPoolSpawn3"

