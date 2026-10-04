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
local r = V.r
local LU = require("level_utils")
local P = require("path_db")
local GR = require("grid_db")
local UP = require("kr1.upgrades")
local SH = require("klove.shader_db")
local bit = require("bit")
local band = bit.band
local signal = require("lib.hump.signal")

local function queue_damage(store, damage)
	store.damage_queue[#store.damage_queue + 1] = damage
end

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

-- 大眼关卡独占脚本

local decal_stage_16_overseer_blood = {}

function decal_stage_16_overseer_blood.update(this, store)
	for i, v in ipairs(this.blood_pos) do
		local blood = E:create_entity(this.fx_template)

		blood.pos.x, blood.pos.y = this.pos.x + v.x, this.pos.y + v.y
		blood.render.sprites[1].ts = store.tick_ts
		blood.tween.ts = store.tick_ts

		simulation:queue_insert_entity(blood)
		U.y_wait_unconditional(store, fts(1))
	end

	simulation:queue_remove_entity(this)
end

-- 大眼的触手嘴巴

local controller_stage_16_overseer_tentacle_mouth = {}

function controller_stage_16_overseer_tentacle_mouth.update(this, store)
	this.render.sprites[1].hidden = true

	while true do
		if this.anim_free then
			this.render.sprites[1].hidden = false

			U.y_animation_play(this, "free", nil, store.tick_ts, false)
			U.animation_start(this, "idlemouth", nil, store.tick_ts, true, 1, true)

			this.anim_free = nil
		end

		if this.anim_shot then
			U.y_animation_play(this, "spawnenemies", nil, store.tick_ts, false)
			U.animation_start(this, "idlemouth", nil, store.tick_ts, true, 1, true)

			this.anim_shot = nil
		end

		coroutine.yield()
	end
end

local mod_slow_overseer = {}

function mod_slow_overseer.insert(this, store)
	local target = store.towers[this.modifier.target_id]
	if not target then
		return false
	end
	-- insert_tower_cooldown_buff 会做 divider += (1 - c)，而攻击间隔 = base * (1/divider)。
	-- 想减速到 1/slow_factor（即 divider 变为 slow_factor），需要 c = 2 - slow_factor。
	SU.insert_tower_cooldown_buff(store.tick_ts, target, 2 - this.slow_factor)
	U.entity_insert_shader(target, SH:get(this.shader), this.shader_args, this.id)
	return true
end

function mod_slow_overseer.update(this, store)
	local target = store.towers[this.modifier.target_id]
	if not target then
		simulation:queue_remove_entity(this)
		return
	end

	local stop_time = store.tick_ts + this.modifier.duration
	while store.tick_ts < stop_time do
		coroutine.yield()
	end

	SU.remove_tower_cooldown_buff(store.tick_ts, target, 2 - this.slow_factor)
	U.entity_remove_shader(target, this.id)

	simulation:queue_remove_entity(this)
end

-- 受击点
local enemy_overseer_hit_point = {}

function enemy_overseer_hit_point.update(this, store)
	local nearest = P:nearest_nodes(this.pos.x, this.pos.y)
	local path_pi, path_spi, path_ni
	if #nearest > 0 then
		path_pi, path_spi, path_ni = unpack(nearest[1])
	end

	this.nav_path.pi = path_pi
	this.nav_path.spi = path_spi
	this.nav_path.ni = path_ni

	U.bans_add(this.vis, F_ALL)
	this._bans_added = true

	while store.wave_group_number == 0 do
		coroutine.yield()
	end

	U.y_wait_unconditional(store, fts(60))

	U.bans_remove(this.vis, F_ALL)
	this._bans_added = nil

	local overseer = this.boss

	while true do
		if overseer.health.dead then
			break
		end

		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

function enemy_overseer_hit_point.on_damage(this, store, damage)
	local d = E.assign_damage(damage.damage_type, damage.value, damage.source_id, this.boss.id)
	queue_damage(store, d)

	if damage.value >= 600 then
		this.boss._greatly_hurt = true
	end

	return true
end

local bullet_stage_16_overseer_tentacle_spawn = {}

function bullet_stage_16_overseer_tentacle_spawn.update(this, store)
	local b = this.bullet
	local dmin, dmax = b.damage_min, b.damage_max
	local dradius = b.damage_radius

	if b.level and b.level > 0 then
		if b.damage_radius_inc then
			dradius = dradius + b.level * b.damage_radius_inc
		end

		if b.damage_min_inc then
			dmin = dmin + b.level * b.damage_min_inc
		end

		if b.damage_max_inc then
			dmax = dmax + b.level * b.damage_max_inc
		end
	end

	local ps

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id

		simulation:queue_insert_entity(ps)
	end

	while store.tick_ts - b.ts + store.tick_length < b.flight_time do
		coroutine.yield()

		b.last_pos.x, b.last_pos.y = this.pos.x, this.pos.y
		this.pos.x, this.pos.y = SU.position_in_parabola(store.tick_ts - b.ts, b.from, b.speed, b.g)

		if b.align_with_trajectory then
			this.render.sprites[1].r = V.angleTo(this.pos.x - b.last_pos.x, this.pos.y - b.last_pos.y)
		elseif b.rotation_speed then
			this.render.sprites[1].r = this.render.sprites[1].r + b.rotation_speed * store.tick_length
		end

		if b.hide_radius then
			this.render.sprites[1].hidden = V.dist(this.pos.x, this.pos.y, b.from.x, b.from.y) < b.hide_radius or V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) < b.hide_radius
		end
	end

	local enemies = table.filter(store.entities, function(k, v)
		return v.enemy and v.vis and v.health and not v.health.dead and band(v.vis.flags, b.damage_bans) == 0 and band(v.vis.bans, b.damage_flags) == 0 and U.is_inside_ellipse(v.pos, b.to, dradius)
	end)

	for _, enemy in ipairs(enemies) do
		local d = E.assign_damage(b.damage_type, 0, this.id, enemy.id)
		d.reduce_armor = b.reduce_armor
		d.reduce_magic_armor = b.reduce_magic_armor

		if b.damage_decay_random then
			d.value = U.frandom(dmin, dmax)
		elseif this.up_alchemical_powder_chance and math.random() < this.up_alchemical_powder_chance or UP:get_upgrade("engineer_efficiency") then
			d.value = dmax
		else
			local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, dradius)

			d.value = math.floor(dmax - (dmax - dmin) * dist_factor)
		end

		d.value = math.ceil(b.damage_factor * d.value)

		queue_damage(store, d)

		if b.mod then
			local mod = E:create_entity(b.mod)

			mod.modifier.target_id = enemy.id
			mod.modifier.source_id = this.id

			simulation:queue_insert_entity(mod)
		end
	end

	local p = SU.create_bullet_pop(store, this)

	if p then
		simulation:queue_insert_entity(p)

	end

	local cell_type = GR:cell_type(b.to.x, b.to.y)

	if b.hit_fx_water and band(cell_type, TERRAIN_WATER) ~= 0 then
		S:queue(this.sound_events.hit_water)

		local water_fx = E:create_entity(b.hit_fx_water)

		water_fx.pos.x, water_fx.pos.y = b.to.x, b.to.y
		water_fx.render.sprites[1].ts = store.tick_ts
		water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset

		simulation:queue_insert_entity(water_fx)
	elseif b.hit_fx then
		S:queue(this.sound_events.hit)

		local sfx = E:create_entity(b.hit_fx)

		sfx.pos = V.vclone(b.to)
		sfx.render.sprites[1].ts = store.tick_ts
		sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset

		simulation:queue_insert_entity(sfx)
	end

	if b.hit_decal and band(cell_type, TERRAIN_WATER) == 0 then
		local decal = E:create_entity(b.hit_decal)

		decal.pos = V.vclone(b.to)
		decal.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(decal)
	end

	local enemy_template = "enemy_glareling"
	local path_pi, path_spi, path_ni

	for i = 1, this.spawn_amounts_per_phase[this.overseer.phase] do
		local enemy = E:create_entity(enemy_template)
		local enemy_pos = V.v(b.to.x + this.spawn_offset[i].x, b.to.y + this.spawn_offset[i].y)
		local nearest = P:nearest_nodes(enemy_pos.x, enemy_pos.y, {this.spawn_path}, {1, 2, 3})

		if #nearest > 0 then
			path_pi, path_spi, path_ni = unpack(nearest[1])
			enemy_pos = P:node_pos(path_pi, path_spi, path_ni)
		end

		enemy.pos.x, enemy.pos.y = enemy_pos.x, enemy_pos.y
		enemy.nav_path.pi = path_pi
		enemy.nav_path.spi = path_spi
		enemy.nav_path.ni = path_ni
		enemy.nav_path_data = nearest[1]

		simulation:queue_insert_entity(enemy)
	end

	local soldiers = U.find_soldiers_in_range(store.soldiers, b.to, 0, this.explosion_damage.range, this.explosion_damage.vis_flags, this.explosion_damage.vis_bans)

	if soldiers then
		for _, soldier in ipairs(soldiers) do
			local dist_factor = U.dist_factor_inside_ellipse(soldier.pos, b.to, this.explosion_damage.range)
			local d = E.assign_damage(this.explosion_damage.damage_type, math.floor(this.explosion_damage.damage_max - (this.explosion_damage.damage_max - this.explosion_damage.damage_min) * dist_factor), this.id, soldier.id)

			queue_damage(store, d)
		end
	end

	simulation:queue_remove_entity(this)
end

local decal_stage_16_holder_destroy_crater = {}

function decal_stage_16_holder_destroy_crater.update(this, store)
	U.y_animation_play(this, "start", nil, store.tick_ts)
	U.animation_start_default(this, "loop", false, store.tick_ts, true)

	while true do
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

tt = E:register_t_hot("mod_heal_overseer", "modifier", true)
E:add_comps(tt, "hps")
tt.main_script.insert = scripts.mod_hps.insert
tt.main_script.update = scripts.mod_hps.update

tt = E:register_t_hot("mod_slow_overseer", "modifier", true)
tt.main_script.insert = mod_slow_overseer.insert
tt.main_script.update = mod_slow_overseer.update
tt.shader = "p_tint"
tt.shader_args = {
	tint_factor = 0.5,
	tint_color = {0.5, 0, 0.5, 1}
}
tt.slow_factor = 0.5
tt.modifier.duration = 12

tt = E:register_t_hot("bullet_stage_16_overseer_destroy_holders", "bullet", true)
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.hit_time = fts(2)
tt.hit_fx_only_no_target = true
tt.image_width = 381
tt.main_script.update = scripts.ray5_simple.update
tt.render.sprites[1].name = "overseer_fx_overseer_destroyray_loop"
tt.render.sprites[1].loop = false
tt.sound_events.insert = "TowerArcaneWizardBasicAttack"
tt.track_target = true
tt.ray_duration = fts(26)

tt = E:register_t_hot("bullet_stage_16_overseer_downgrade_towers", "bullet_stage_16_overseer_destroy_holders", true)

tt = E:register_t_hot("enemy_overseer_hit_point", "enemy", true)
E:add_comps(tt, "glare_kr5")
tt.enemy.gold = 250
tt.enemy.melee_slot = v(0, 0)
tt.health.hp_max = 40000
tt.unit.blood_color = BLOOD_VIOLET
tt.main_script.update = enemy_overseer_hit_point.update
tt.health.on_damage = enemy_overseer_hit_point.on_damage
tt.render = nil
tt.glare_kr5.regen_hp = 15
tt.ui.click_rect = r(-30, -3, 60, 65)
tt.ui.can_click = false
tt.ui.can_select = false
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.vis.bans = bor(F_BLOCK, F_FREEZE, F_STUN) --bor(F_MOD, F_BLOCK)
tt.move_bounds = v(25, 25)
tt.move_speed = v(0.2, 0.2)

tt = E:register_t_hot("bullet_stage_16_overseer_tentacle_spawn", "bomb", true)
tt.sound_events.hit_water = nil
tt.render.sprites[1].name = "overseer_fx_overseer_proyectile"
tt.bullet.hit_fx = "fx_stage_16_overseer_tentacle_hit_decal"
tt.bullet.hit_decal = "decal_stage_16_overseer_tentacle_projectile"
tt.bullet.particles_name = "ps_bullet_stage_16_overseer_tentacle_spawn"
tt.bullet.rotation_speed = 5
tt.bullet.pop = nil
tt.bullet.damage_min = 0
tt.bullet.damage_max = 0
tt.main_script.update = bullet_stage_16_overseer_tentacle_spawn.update
tt.spawn_offset = {v(-40, 0), v(0, 20), v(30, 0), v(0, -30), v(-20, 0)}
tt.explosion_damage = {}
tt.explosion_damage.range = 70
tt.explosion_damage.vis_flags = bor(F_RANGED)
tt.explosion_damage.vis_bans = bor(F_ENEMY)
tt.explosion_damage.damage_type = DAMAGE_PHYSICAL
tt.explosion_damage.damage_min = 120
tt.explosion_damage.damage_max = 180
tt.spawn_amounts_per_phase = {0, 0, 3, 3, 4, 5}
tt.sound_events.insert = nil
tt.sound_events.hit = "Stage16OverseerSpawnerImpact"

tt = E:register_t_hot("controller_stage_16_tentacle_mouth_left", nil, true)
E:add_comps(tt, "editor", "pos", "main_script", "render")
tt.main_script.update = controller_stage_16_overseer_tentacle_mouth.update
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].prefix = "overseer_tentacle2Def"
tt.render.sprites[1].name = "free"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND_COVERS + 1

tt = E:register_t_hot("controller_stage_16_tentacle_mouth_right", "controller_stage_16_tentacle_mouth_left", true)
tt.render.sprites[1].flip_x = true

tt = E:register_t_hot("decal_stage_16_holder_destroy_fx", "decal", true)
tt.render.sprites[1].name = "overseer_fx_overseer_crater_run"
tt.render.sprites[1].loop = false
tt.render.sprites[1].offset.y = 10
tt.render.sprites[1].sort_y_offset = -1

tt = E:register_t_hot("decal_stage_16_holder_destroy_crater", "decal_scripted", true)
tt.render.sprites[1].prefix = "t3_craterDef"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false
tt.main_script.update = decal_stage_16_holder_destroy_crater.update

tt = E:register_t_hot("decal_stage_16_tower_change_fx", "decal_tween", true)
tt.render.sprites[1].prefix = "overseer_fx_overseer_teleportdecal"
tt.render.sprites[1].name = "decalin"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].offset = v(-2, 5)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "overseer_fx_overseer_teleportdecal"
tt.render.sprites[2].name = "decalactivate"
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[2].offset = v(-2, 5)
tt.duration = 2.8 + fts(60)
tt.tween.props[1].keys = {{0, 0}, {0.25, 255}, {"this.duration-0.25", 255}, {"this.duration", 0}}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].sprite_id = 2
tt.tween.props[2].name = "alpha"
tt.tween.props[2].keys = {{0, 0}, {1, 255}, {"this.duration-0.25", 255}, {"this.duration", 0}}

tt = E:register_t_hot("decal_stage_16_overseer_tentacle_projectile", "decal_tween", true)
tt.render.sprites[1].name = "overseer_fx_overseer_proyectile_decal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.duration = 2.5
tt.tween.props[1].keys = {{0, 0}, {0.25, 255}, {"this.duration-0.5", 255}, {"this.duration", 0}}

tt = E:register_t_hot("decal_stage_16_glare_1", "decal_stage_12_glare", true)
tt.render.sprites[1].prefix = "stage_16_glare_1Def"

tt = E:register_t_hot("decal_stage_16_glare_2", "decal_stage_12_glare", true)
tt.render.sprites[1].prefix = "stage_16_glare_2Def"

tt = E:register_t_hot("decal_stage_16_glare_eye_big", "decal_scripted", true)
tt.render.sprites[1].name = "glare_stage_16_eye_big"
tt.render.sprites[1].animated = false
tt.render.sprites[1].draw_order = 2
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "glare_stage_16_eyelids_big"
tt.render.sprites[2].name = "idle_close"
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[2].draw_order = 4
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "glare_stage_16_eye_big_pupil"
tt.render.sprites[3].name = "look"
tt.render.sprites[3].z = Z_DECALS
tt.render.sprites[3].draw_order = 3
tt.main_script.update = scripts.decal_terrain_3_glare_eye.update
tt.sid_eyelids = 2
tt.sid_pupil = 3
tt.is_big_eye = true

tt = E:register_t_hot("decal_stage_16_glare_eye_small_1", "decal_terrain_3_glare_eye_small", true)
tt.render.sprites[1].prefix = "glare_stage_16_eyes_1"
tt.render.sprites[2].prefix = "glare_stage_16_eyelids_1"

tt = E:register_t_hot("decal_stage_16_glare_eye_small_2", "decal_terrain_3_glare_eye_small", true)
tt.render.sprites[1].prefix = "glare_stage_16_eyes_2"
tt.render.sprites[2].prefix = "glare_stage_16_eyelids_2"

tt = E:register_t_hot("decal_stage_16_glare_eye_small_3", "decal_terrain_3_glare_eye_small", true)
tt.render.sprites[1].prefix = "glare_stage_16_eyes_3"
tt.render.sprites[2].prefix = "glare_stage_16_eyelids_3"

tt = E:register_t_hot("decal_stage_16_overseer_blood", nil, true)
E:add_comps(tt, "pos", "main_script")
tt.main_script.update = decal_stage_16_overseer_blood.update
tt.blood_pos = {v(20, 20), v(100, 100), v(-100, 100), v(-150, -30), v(150, -70), v(-30, 40)}
tt.fx_template = "decal_stage_16_overseer_single_blood_fx"

tt = E:register_t_hot("decal_stage_16_overseer_single_blood_fx", "decal_tween", true)
tt.render.sprites[1].name = "overseer_fx_overseer_blood"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt.render.sprites[1].offset = v(20, 20)
tt.tween.props[1].keys = {{0, 255}, {fts(13), 255}, {fts(16), 0}}

tt = E:register_t_hot("decal_stage_16_death_bright", "decal", true)
tt.render.sprites[1].prefix = "overseer_deathbrightDef"
tt.render.sprites[1].name = "areaattack"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_SKY + 1

tt = E:register_t_hot("decal_stage_16_overseer_destroy_holder_bright", "decal_tween", true)
tt.render.sprites[1].name = "overseer_fx_overseer_destroyray_bright_run"
tt.render.sprites[1].z = Z_BULLETS + 1
tt.tween.props[1].keys = {{0, 0}, {fts(5), 255}, {fts(25), 255}, {fts(26), 0}}

tt = E:register_t_hot("fx_stage_16_overseer_tentacle_hit_decal", "fx", true)
tt.render.sprites[1].prefix = "overseer_fx_overseer_proyectile_explosion"
tt.render.sprites[1].name = "run"

tt = E:register_t_hot("controller_tower_swap_overseer", "controller_tower_swap", true)
tt.fx_out = "decal_tower_swap_fx_in"
tt.fx_in = "decal_tower_swap_fx_in"
tt.fx_spawn_delay = 0
tt.fx_in_delay = 0
tt.fx_delay_between = fts(14)
tt.swap_sound = "Stage16OverseerTeleport"

tt = E:register_t_hot("decal_tower_swap_fx_in", "decal_timed", true)
tt.render.sprites[1].name = "overseer_fx_overseer_teleportfx_run"
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 1
tt.render.sprites[1].offset = v(0, 10)
tt.timed.duration = fts(20)

tt = E:register_t_hot("ps_bullet_stage_16_overseer_tentacle_spawn", nil, true)
E:add_comps(tt, "pos", "particle_system")
tt.particle_system.name = "overseer_fx_overseer_proyectile_trail_run"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.emission_rate = 15
tt.particle_system.emit_rotation_spread = math.pi / 2
