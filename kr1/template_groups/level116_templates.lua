local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local function fts(v)
	return v / FPS
end
require("lib.klua.table")
local V = require("lib.klua.vector")
local SU = require("script_utils")
local scripts = require("scripts")
local v = V.v
local controller_terrain_3_stage_16_glare_update
local controller_stage_16_overseer_tentacle_update
local controller_stage_16_tentacle_bottom_update
controller_terrain_3_stage_16_glare_update = function(this, store)
	local overseer = table.filter(store.entities, function(k, v)
		return v.template_name == "controller_stage_16_overseer"
	end)[1]
	local last_phase = 0
	while true do
		if overseer.phase == last_phase or #this.phase_config < overseer.phase then
		elseif not this.phase_config[overseer.phase] then
		elseif this.phase_config[overseer.phase][1] < 0 then
		else
			last_phase = overseer.phase
			local phase_start_ts = store.tick_ts
			local d_delay, d_duration = unpack(this.phase_config[overseer.phase])
			local delay = d_delay - (store.tick_ts - phase_start_ts)
			local aura, decal
			local start_ts = store.tick_ts
			for i = 1, #this.eyes do
				while store.tick_ts - start_ts < delay - 2 * (#this.eyes - i) do
					if last_phase ~= overseer.phase then
						goto label_1238_0
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
				if last_phase ~= overseer.phase then
					break
				end
				if store.tick_ts - start_ts > d_duration - 1 and not this.eyes[1].dont_blink then
					for _, eye in pairs(this.eyes) do
						eye.dont_blink = true
					end
				end
				coroutine.yield()
			end
			::label_1238_0::
			S:queue(this.sound_off)
			for i = 1, #this.eyes do
				U.y_wait_unconditional(store, fts(math.random(0, 5)))
				U.y_animation_play(this.eyes[#this.eyes + 1 - i], "close", nil, store.tick_ts, 1, this.sid_eyelids)
				U.animation_start(this.eyes[#this.eyes + 1 - i], "idle_close", nil, store.tick_ts, true, this.sid_eyelids)
				this.eyes[#this.eyes + 1 - i].dont_blink = false
			end
			this.glare_active = false
			if aura then
				simulation:queue_remove_entity(aura)
			end
			if decal then
				U.y_animation_play(decal, "out", nil, store.tick_ts)
				simulation:queue_remove_entity(decal)
			end
		end
		coroutine.yield()
	end
end
controller_stage_16_overseer_tentacle_update = function(this, store)
	local can_spawn_enemies = false
	local last_shot_ts = store.tick_ts
	local last_shot_attack_soldiers_ts = store.tick_ts
	local overseer = table.filter(store.entities, function(k, v)
		return v.template_name == "controller_stage_16_overseer"
	end)[1]
	U.animation_start_default(this, "idletrapped", nil, store.tick_ts, true)
	this.tentacle_mouth = E:create_entity(this.tentacle_mouth_template)
	this.tentacle_mouth.pos = this.pos
	simulation:queue_insert_entity(this.tentacle_mouth)
	local hit_point = E:create_entity("enemy_overseer_hit_point")
	hit_point.pos = V.v(this.pos.x + this.spawn_offset.x + (this.spawn_offset.x < 0 and 35 or -35), this.pos.y + this.spawn_offset.y)
	hit_point.boss = overseer
	simulation:queue_insert_entity(hit_point)
	while true do
		if overseer.health.dead then
		else
			if this.config.cooldown[overseer.phase] ~= nil then
				if not can_spawn_enemies then
					U.y_animation_wait_default(this)
					S:queue(this.sound_rumble)
					local shake = E:create_entity("aura_screen_shake")
					shake.aura.amplitude = 0.3
					shake.aura.duration = fts(120)
					shake.aura.freq_factor = 3
					simulation:queue_insert_entity(shake)
					S:queue(this.sound_unchain)
					U.y_animation_play(this, "shake", nil, store.tick_ts, 1)
					this.tentacle_mouth.anim_free = true
					U.animation_start(this, "free", nil, store.tick_ts, false, 1)
					U.y_wait_unconditional(store, fts(50))
					S:queue(this.sound_rumble)
					local shake = E:create_entity("aura_screen_shake")
					shake.aura.amplitude = 0.7
					shake.aura.duration = fts(10)
					shake.aura.freq_factor = 3
					simulation:queue_insert_entity(shake)
					U.y_animation_wait_default(this)
					U.animation_start(this, "idlemouth", nil, store.tick_ts, true, 1, true)
					can_spawn_enemies = true
					last_shot_ts = store.tick_ts - this.first_cooldown
				end
				if store.tick_ts - last_shot_ts >= this.config.cooldown[overseer.phase] then
					local start_ts = store.tick_ts
					local shoot_count = 1
					local hp_rate = overseer.health.hp / overseer.health.hp_max
					if hp_rate < 0.25 then
						shoot_count = 3
					elseif hp_rate < 0.4 then
						shoot_count = 2
					end
					local speed_factor = 0.5 * (shoot_count + 1)
					if speed_factor ~= 1 then
						SU.change_fps(store.tick_ts, this, speed_factor)
						SU.change_fps(store.tick_ts, this.tentacle_mouth, speed_factor)
					end
					for i = 1, shoot_count do
						this.tentacle_mouth.anim_shot = true
						S:queue(this.sound_spawn)
						U.animation_start_default(this, "spawnenemies", nil, store.tick_ts, false)
						U.y_wait_unconditional(store, this.shot_delay / speed_factor)
						local spawn_pos_i = math.random(1, #this.spawn_pos)
						local b = E:create_entity(this.bullet)
						b.pos.x, b.pos.y = this.pos.x + this.spawn_offset.x, this.pos.y + this.spawn_offset.y
						b.bullet.from = V.vclone(b.pos)
						b.bullet.to = this.spawn_pos[spawn_pos_i]
						b.bullet.source_id = this.id
						b.path_to_spawn = this.spawn_path
						b.overseer = overseer
						b.spawn_path = this.spawn_path[spawn_pos_i]
						simulation:queue_insert_entity(b)
						U.y_animation_wait_default(this)
						U.y_animation_wait_default(this.tentacle_mouth)
						coroutine.yield()
					end
					if speed_factor ~= 1 then
						SU.change_fps(store.tick_ts, this, 1 / speed_factor)
						SU.change_fps(store.tick_ts, this.tentacle_mouth, 1 / speed_factor)
					end
					U.animation_start(this, "idlemouth", nil, store.tick_ts, true, 1, true)
					last_shot_ts = start_ts
				end
			end
			if this.config.cooldown_attack_soldiers[overseer.phase] ~= nil then
				if store.tick_ts - last_shot_attack_soldiers_ts >= this.config.cooldown_attack_soldiers[overseer.phase] then
					local start_ts = store.tick_ts
					local shoot_count = 1
					local hp_rate = overseer.health.hp / overseer.health.hp_max
					if hp_rate < 0.15 then
						shoot_count = 3
					elseif hp_rate < 0.3 then
						shoot_count = 2
					end
					local speed_factor = 0.5 * (shoot_count + 1)
					if speed_factor ~= 1 then
						SU.change_fps(store.tick_ts, this, speed_factor)
						SU.change_fps(store.tick_ts, this.tentacle_mouth, speed_factor)
					end
					for i = 1, shoot_count do
						this.tentacle_mouth.anim_shot = true
						S:queue(this.sound_spawn)
						U.animation_start_default(this, "spawnenemies", nil, store.tick_ts, false)
						U.y_wait_unconditional(store, this.shot_delay / speed_factor)
						local soldier = U.find_nearest_soldier(store.soldiers, this.pos, 0, 225, bor(F_AREA, F_RANGED), F_NONE)
						local spawn_pos = soldier and V.vclone(soldier.pos) or V.vclone(this.spawn_pos[math.random(1, #this.spawn_pos)])
						local b = E:create_entity(this.bullet)
						b.pos.x, b.pos.y = this.pos.x + this.spawn_offset.x, this.pos.y + this.spawn_offset.y
						b.bullet.from = V.vclone(b.pos)
						b.bullet.to = spawn_pos
						b.bullet.source_id = this.id
						b.path_to_spawn = this.spawn_path[1]
						b.overseer = overseer
						b.spawn_path = this.spawn_path[1]
						simulation:queue_insert_entity(b)
						U.y_animation_wait_default(this)
						U.y_animation_wait_default(this.tentacle_mouth)
						coroutine.yield()
					end
					if speed_factor ~= 1 then
						SU.change_fps(store.tick_ts, this, 1 / speed_factor)
						SU.change_fps(store.tick_ts, this.tentacle_mouth, 1 / speed_factor)
					end
					U.animation_start(this, "idlemouth", nil, store.tick_ts, true, 1, true)
					last_shot_attack_soldiers_ts = start_ts
				end
			end
		end
		coroutine.yield()
	end
end
controller_stage_16_tentacle_bottom_update = function(this, store)
	local overseer = table.filter(store.entities, function(k, v)
		return v.template_name == "controller_stage_16_overseer"
	end)[1]
	local is_free = false
	while true do
		if not is_free and overseer.phase == this.phase_to_free then
			is_free = true
			S:queue(this.sound_unchain)
			U.animation_start(this, "free", nil, store.tick_ts, false, 1)
			S:queue(this.sound_rumble)
			local shake = E:create_entity("aura_screen_shake")
			shake.aura.amplitude = 0.3
			shake.aura.duration = fts(35)
			shake.aura.freq_factor = 3
			simulation:queue_insert_entity(shake)
			U.y_wait_unconditional(store, fts(40))
			local shake = E:create_entity("aura_screen_shake")
			shake.aura.amplitude = 0.7
			shake.aura.duration = fts(20)
			shake.aura.freq_factor = 3
			simulation:queue_insert_entity(shake)
			U.y_animation_wait_default(this)
			U.animation_start_specific(this, "idle2", false, store.tick_ts, true, 1)
		end
		coroutine.yield()
	end
end
local tt
local controller_stage_16_overseer_eye = {}

function controller_stage_16_overseer_eye.update(this, store)
	local blink_cooldown = math.random(this.blink_min_cooldown, this.blink_max_cooldown)
	local last_blink = store.tick_ts
	local overseer = table.filter(store.entities, function(k, v)
		return v.template_name == "controller_stage_16_overseer"
	end)[1]
	local damaged = false

	this.idle_anims = this.idle_not_damaged

	local function check_change_damaged_state()
		if not damaged then
			local life_percentage = overseer.health.hp * 100 / overseer.health.hp_max

			if life_percentage < this.life_hurt_threshold then
				U.y_animation_play(this, "eyehurt", nil, store.tick_ts)

				this.idle_anims = this.idle_damaged
				damaged = true
			end
		end
	end

	while true do
		if blink_cooldown <= store.tick_ts - last_blink then
			U.y_animation_play(this, this.idle_anims[math.random(1, #this.idle_anims)], nil, store.tick_ts)

			blink_cooldown = math.random(this.blink_min_cooldown, this.blink_max_cooldown)
			last_blink = store.tick_ts
		end

		check_change_damaged_state()
		coroutine.yield()
	end
end

local controller_stage_16_overseer_mouth_door = {}

function controller_stage_16_overseer_mouth_door.update(this, store)
	local last_check_enemy = store.tick_ts
	local is_open = false

	U.animation_start_default(this, "closeidle", nil, store.tick_ts, true)

	while store.wave_group_number == 0 do
		coroutine.yield()
	end

	local function search_enemies_nearby()
		local targets = U.find_enemies_in_range_filter_on(this.check_pos, this.check_radius, this.check_vis_flags, this.check_vis_bans, function(e)
			return e.enemy and e.health and not e.health.dead
		end)

		if targets and #targets > 0 then
			if not is_open then
				U.y_animation_wait_default(this)
				U.y_animation_play(this, "open", nil, store.tick_ts)
				U.animation_start(this, "openidle", nil, store.tick_ts, true, 1, true)

				is_open = true
			end
		elseif is_open then
			U.y_animation_wait_default(this)
			U.y_animation_play(this, "close", nil, store.tick_ts)
			U.animation_start_default(this, "closeidle", nil, store.tick_ts, true)

			is_open = false
		end
	end

	last_check_enemy = store.tick_ts

	while true do
		if store.tick_ts - last_check_enemy >= this.check_cooldown then
			search_enemies_nearby()

			last_check_enemy = store.tick_ts
		end

		coroutine.yield()
	end
end

-- 大眼的触手控制

tt = E:register_t_hot("controller_stage_16_tentacle_bottom_left", nil, true)
E:add_comps(tt, "editor", "pos", "render", "main_script")
tt.main_script.update = controller_stage_16_tentacle_bottom_update
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].prefix = "overseer_undertent1Def"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND_COVERS + 1
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "overseer_underbacktents1Def"
tt.render.sprites[2].name = "loop"
tt.render.sprites[2].exo = true
tt.render.sprites[2].z = Z_BACKGROUND_COVERS - 1
tt.render.sprites[2].offset = v(-140, -350)
tt.phase_to_free = 4
tt.sound_rumble = "Stage16OverseerRumble"
tt.sound_unchain = "Stage16OverseerUnchainDown"

tt = E:register_t_hot("controller_stage_16_tentacle_bottom_right", "controller_stage_16_tentacle_bottom_left", true)
tt.render.sprites[1].prefix = "overseer_undertent2Def"
tt.render.sprites[2].prefix = "overseer_underbacktents2Def"
tt.render.sprites[2].offset = v(350, -20)
tt.phase_to_free = 5

tt = E:register_t_hot("controller_stage_16_tentacle_left", nil, true)
E:add_comps(tt, "editor", "pos", "main_script", "render")
tt.main_script.update = controller_stage_16_overseer_tentacle_update
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].prefix = "overseer_tentacleDef"
tt.render.sprites[1].name = "idletrapped"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND_COVERS - 5
tt.config = {
	cooldown = {nil, nil, nil, 40, 30, 20},
	cooldown_attack_soldiers = {nil, nil, nil, nil, 35, 25}
}
tt.shot_delay = fts(24)
tt.bullet = "bullet_stage_16_overseer_tentacle_spawn"
tt.spawn_offset = v(90, -130)
tt.spawn_pos = {v(76, 332), v(218, 424)}
tt.spawn_path = {1, 2}
tt.tentacle_mouth_template = "controller_stage_16_tentacle_mouth_left"
tt.first_cooldown = 5
tt.sound_rumble = "Stage16OverseerRumble"
tt.sound_unchain = "Stage16OverseerUnchainLeftRight"
tt.sound_spawn = "Stage16OverseerSpawnerCast"

tt = E:register_t_hot("controller_stage_16_tentacle_right", "controller_stage_16_tentacle_left", true)
tt.render.sprites[1].flip_x = true
tt.config = {
	cooldown = {nil, nil, 45, 45, 35, 25},
	cooldown_attack_soldiers = {nil, nil, nil, 40, 30, 20}
}
tt.is_right = true
tt.spawn_offset = v(-80, -150)
tt.spawn_pos = {v(850, 446), v(860, 206)}
tt.spawn_path = {3, 4}
tt.tentacle_mouth_template = "controller_stage_16_tentacle_mouth_right"

tt = E:register_t_hot("decal_terrain_3_floating_rock_1", "decal_terrain_3_floating_rock", true)
tt.render.sprites[1].name = "t3_crater_asst_crater_rock1"

tt = E:register_t_hot("decal_terrain_3_floating_rock_5", "decal_terrain_3_floating_rock", true)
tt.render.sprites[1].name = "t3_crater_asst_crater_rock5"

tt = E:register_t_hot("decal_stage_16_mask_4", "decal", true)
tt.render.sprites[1].name = "stage16_mask4"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BACKGROUND_COVERS

tt = E:register_t_hot("decal_terrain_3_floating_rock_3", "decal_terrain_3_floating_rock", true)
tt.render.sprites[1].name = "t3_crater_asst_crater_rock3"

tt = E:register_t_hot("controller_terrain_3_stage_16_glare1", "controller_terrain_3_local_glare", true)
tt.main_script.update = controller_terrain_3_stage_16_glare_update
tt.phase_config = {{-1, 0}, {-1, 0}, {-1, 0}, {6, 30}, {6, 20}, {60, 30}}
tt.decal_ground = "decal_stage_16_glare_1"
tt.eyes_t = {"decal_stage_16_glare_eye_big", "decal_stage_16_glare_eye_small_1", "decal_stage_16_glare_eye_small_2", "decal_stage_16_glare_eye_small_3"}

tt = E:register_t_hot("decal_stage_16_mask_2", "decal", true)
tt.render.sprites[1].name = "stage16_mask2"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BACKGROUND_COVERS

tt = E:register_t_hot("controller_terrain_3_stage_16_glare2", "controller_terrain_3_local_glare", true)
tt.main_script.update = controller_terrain_3_stage_16_glare_update
tt.phase_config = {{-1, 0}, {8, 25}, {6, 30}, {-1, 0}, {-1, 0}, {6, 30}}
tt.decal_ground = "decal_stage_16_glare_2"

tt = E:register_t_hot("decal_stage_16_mask_3", "decal", true)
tt.render.sprites[1].name = "stage16_mask3"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BACKGROUND_COVERS

tt = E:register_t_hot("decal_terrain_3_floating_rock_4", "decal_terrain_3_floating_rock", true)
tt.render.sprites[1].name = "t3_crater_asst_crater_rock4"

tt = E:register_t_hot("decal_terrain_3_floating_rock_2", "decal_terrain_3_floating_rock", true)
tt.render.sprites[1].name = "t3_crater_asst_crater_rock2"

tt = E:register_t_hot("decal_stage_16_mask_1", "decal", true)
tt.render.sprites[1].name = "stage16_mask1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BACKGROUND_COVERS

tt = E:register_t_hot("controller_stage_16_mouth_left", nil, true)
E:add_comps(tt, "editor", "pos", "main_script", "render")
tt.main_script.update = controller_stage_16_overseer_mouth_door.update
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].prefix = "overseer_mouthDef"
tt.render.sprites[1].name = "closeidle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].sort_y_offset = 4
tt.check_pos = v(282, 556)
tt.check_cooldown = fts(5)
tt.check_radius = 150
tt.check_vis_flags = F_ENEMY
tt.check_vis_bans = F_BOSS

tt = E:register_t_hot("controller_stage_16_overseer_eye1", nil, true)
E:add_comps(tt, "editor", "pos", "main_script", "render")
tt.main_script.update = controller_stage_16_overseer_eye.update
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].prefix = "overseer_minieye1Def"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].sort_y_offset = -10
tt.blink_min_cooldown = 3
tt.blink_max_cooldown = 5
tt.idle_not_damaged = {"anim1", "anim2", "anim3"}
tt.idle_damaged = {"eyehurttwitch"}
tt.life_hurt_threshold = 66

tt = E:register_t_hot("controller_stage_16_overseer_eye3", "controller_stage_16_overseer_eye1", true)
tt.render.sprites[1].prefix = "overseer_minieye3Def"
tt.life_hurt_threshold = 33

tt = E:register_t_hot("controller_stage_16_overseer_eye4", "controller_stage_16_overseer_eye1", true)
tt.render.sprites[1].prefix = "overseer_minieye4Def"

tt = E:register_t_hot("controller_stage_16_mouth_right", "controller_stage_16_mouth_left", true)
tt.render.sprites[1].flip_x = true
tt.check_pos = v(721, 553)

tt = E:register_t_hot("controller_stage_16_overseer_eye2", "controller_stage_16_overseer_eye1", true)
tt.render.sprites[1].prefix = "overseer_minieye2Def"
tt.life_hurt_threshold = 33

