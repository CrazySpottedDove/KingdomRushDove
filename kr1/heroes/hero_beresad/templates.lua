local scripts = require("scripts")
local E = require("entity_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local bit = require("bit")
local HU = require("hero_utils")
local bor = bit.bor
local find_target_at_critical_moment = HU.find_target_at_critical_moment
local fts = U.fts
local level_up_basic = HU.level_up_basic
local queue_damage = U.queue_damage
local ready_to_attack = U.ready_to_attack
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local v = V.v
local tt

local function controller_beresad_ultimate_update(this, store)
	local begin_ts = store.tick_ts
	local overlay = E:create_entity("decal")

	overlay.pos = V.v(REF_W * 0.5, REF_H * 0.5)
	overlay.render.sprites[1].name = "square_ffffff"
	overlay.render.sprites[1].animated = false
	overlay.render.sprites[1].scale = V.v(math.ceil(REF_H * MAX_SCREEN_ASPECT * 2 / 64), math.ceil(REF_H * 2 / 64))
	overlay.render.sprites[1].z = Z_SCREEN_FIXED
	overlay.render.sprites[1].alpha = 0
	overlay.render.sprites[1].ts = store.tick_ts
	overlay.render.sprites[1].color = {100, 255, 100}

	simulation:queue_insert_entity(overlay)

	local rain = this.rain
	local alpha_min = this.overlay_alpha_min
	local alpha_max = this.overlay_alpha_max
	local breath_period = 2

	while begin_ts + this.duration > store.tick_ts do
		local elapsed = store.tick_ts - begin_ts
		local breath = (math.sin(elapsed / breath_period * 2 * math.pi) + 1) * 0.5

		overlay.render.sprites[1].alpha = alpha_min + (alpha_max - alpha_min) * breath

		if store.tick_ts - rain.ts >= rain.cooldown then
			rain.ts = store.tick_ts

			local angle = U.frandom(rain.angle_min, rain.angle_max)

			for i = 1, rain.count do
				angle = angle + U.frandom(-rain.angle_between, rain.angle_between)

				local dist = math.random(rain.distance_min, rain.distance_max)
				local ox, oy = V.rotate(angle, dist, 0)
				local pos = V.v(math.random(-100, 1920 + 100), math.random(0, 1080))
				local e = E:create_entity(rain.drop)

				e.pos.x, e.pos.y = pos.x, pos.y
				e.render.sprites[1].offset = V.v(-ox, -oy)
				e.render.sprites[1].r = angle
				e.render.sprites[1].alpha = math.random(rain.alpha_min, rain.alpha_max)
				e.tween.props[1].keys = {{0, 0}, {0.001, 255}}
				e.tween.props[2] = CC("tween_prop")
				e.tween.props[2].keys = {{0, V.v(-ox, -oy)}, {0.001, V.v(-ox, -oy)}, {rain.duration, V.v(0, 0)}}
				e.tween.props[2].name = "offset"
				e.tween.ts = store.tick_ts

				simulation:queue_insert_entity(e)
			end
		end

		if store.tick_ts % this.mod_cooldown < store.tick_length then
			local enemies = U.find_enemies_in_range_filter_off(this.pos, this.damage_radius, F_RANGED, 0)

			if enemies then
				for _, enemy in ipairs(enemies) do
					local mod = E:create_entity(this.mod)

					mod.modifier.target_id = enemy.id
					mod.modifier.damage_factor = this.damage_factor

					simulation:queue_insert_entity(mod)
				end
			end
		end

		coroutine.yield()
	end

	simulation:queue_remove_entity(overlay)
	simulation:queue_remove_entity(this)
end

local function flame_insert(this, store)
	local b = this.bullet

	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, 0)
	b.ts = store.tick_ts

	if this.flame_bullet then
		this.flame_bullets = {}

		for i = 1, this.flames_count do
			local flame_bullet = E:create_entity(this.flame_bullet)

			flame_bullet.start_ts = b.ts + this.delay_betweeen_flames * (i - 1)
			flame_bullet.ts = nil
			flame_bullet.pos = V.vclone(b.from)

			table.insert(this.flame_bullets, flame_bullet)
		end
	end

	return true
end

local function flame_update(this, store)
	local b = this.bullet

	while true do
		for i, flame_bullet in ipairs(this.flame_bullets) do
			if flame_bullet.ts == false then
				if i == #this.flame_bullets then
					simulation:queue_remove_entity(this)

					return
				end
			elseif flame_bullet.ts then
				if store.tick_ts - flame_bullet.ts <= b.flight_time then
					flame_bullet.pos.x, flame_bullet.pos.y = SU.position_in_parabola(store.tick_ts - flame_bullet.ts, b.from, b.speed, 0)
				else
					simulation:queue_remove_entity(flame_bullet)

					flame_bullet.ts = false

					if i == 1 then
						local payload = E:create_entity(b.hit_payload)

						payload.pos = V.vclone(b.to)
						payload.aura.damage_factor = b.damage_factor

						simulation:queue_insert_entity(payload)
					end
				end
			elseif flame_bullet.start_ts and store.tick_ts >= flame_bullet.start_ts then
				flame_bullet.ts = store.tick_ts
				flame_bullet.start_ts = nil

				if flame_bullet.render and flame_bullet.render.sprites then
					for _, s in ipairs(flame_bullet.render.sprites) do
						s.ts = store.tick_ts
					end
				end

				simulation:queue_insert_entity(flame_bullet)
			end
		end

		coroutine.yield()
	end
end

local function fx_power_beresad_drop_remove(this, store)
	local fx = E:create_entity("fx_power_beresad_rain_splash")

	fx.pos:set(this.pos.x + this.render.sprites[1].offset.x, this.pos.y + this.render.sprites[1].offset.y)

	fx.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(fx)

	return true
end

local function bolt_beresad_remove(this, store)
	local target = store.entities[this.bullet.target_id]

	if target then
		if target.health.dead then
			local fx = E:create_entity("fx_coin_jump")

			fx.pos.x, fx.pos.y = target.pos.x, target.pos.y
			fx.render.sprites[1].ts = store.tick_ts

			if target.health_bar then
				fx.render.sprites[1].offset.y = target.health_bar.offset.y
			end

			simulation:queue_insert_entity(fx)

			store.player_gold = store.player_gold + 6
		end
	end

	return true
end

local function mod_ray_beresad_disintegrate_insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target then
		return false
	end

	local pos = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
	local targets = U.find_enemies_in_range_filter_off(pos, this.explode_radius, this.explode_vis_flags, this.explode_vis_bans)

	if targets then
		for i = 1, #targets do
			local d = E.assign_damage(this.explode_damage_type, math.random(this.explode_damage_min, this.explode_damage_max) * this.modifier.damage_factor, this.id, targets[i].id)

			queue_damage(store, d)
		end
	end

	return false
end

local function hero_beresad_level_up(this, store, initial)
	local hl, ls = level_up_basic(this)
	local b = E:get_template(this.ranged.attacks[1].bullet)

	b.bullet.damage_max = ls.ranged_damage_max[hl]
	b.bullet.damage_min = ls.ranged_damage_min[hl]

	upgrade_skill(this, "conflagration", function(this, s)
		this.ranged.attacks[2].disabled = nil
		this.ranged.attacks[2].cooldown = s.cooldown[s.level]

		local m = E:get_template("mod_beresad_firestorm")

		m.dps.damage_min = s.damage[s.level]
		m.dps.damage_max = s.damage[s.level]
	end)
	upgrade_skill(this, "fear_dragon", function(this, s)
		this.timed_attacks.list[1].disabled = nil

		local e = E:get_template(this.timed_attacks.list[1].mod)

		e.modifier.duration = s.duration[s.level]
	end)
	upgrade_skill(this, "dragon_spawn", function(this, s)
		this.ranged.attacks[4].disabled = nil
		this.ranged.attacks[4].cooldown = s.cooldown[s.level]

		local e = E:get_template("hero_beresad_golem")

		e.health.hp_max = s.hp[s.level]
		e.melee.attacks[1].damage_min = s.damage_min[s.level]
		e.melee.attacks[1].damage_max = s.damage_max[s.level]
		e.melee.attacks[2].damage_min = s.damage_min[s.level]
		e.melee.attacks[2].damage_max = s.damage_max[s.level]
		e = E:get_template("bomb_beresad_golem")
		e.bullet.damage_min = s.explode_damage_min[s.level]
		e.bullet.damage_max = s.explode_damage_max[s.level]
	end)
	upgrade_skill(this, "remove_existence", function(this, s)
		this.ranged.attacks[3].disabled = nil
		this.ranged.attacks[3].cooldown = s.cooldown[s.level]

		local m = E:get_template("mod_ray_beresad_disintegrate")

		m.explode_damage_min = s.damage_min[s.level]
		m.explode_damage_max = s.damage_max[s.level]
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		this.ultimate.disabled = nil

		local m = E:get_template("mod_beresad_ultimate")

		m.dps.damage_min = s.damage[s.level]
		m.dps.damage_max = s.damage[s.level]
	end)
	update_hp(this)
end

local function hero_beresad_update(this, store)
	local h = this.health
	local fear_attack = this.timed_attacks.list[1]

	U.y_animation_play(this, "respawn", nil, store.tick_ts, 1, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		while this.nav_rally.new do
			SU.y_hero_new_rally(store, this)
		end

		if SU.hero_level_up(store, this) then
			U.y_animation_play(this, "levelup", nil, store.tick_ts, 1, 1)
		end

		if ready_to_use_skill(fear_attack, store, this.unit.cooldown_factor) then
			local _, enemies = U.find_foremost_enemy_in_range_filter_on(this.pos, fear_attack.max_range, nil, fear_attack.vis_flags, fear_attack.vis_bans, SU.is_valid_scare_target)

			if enemies then
				U.animation_start_once_specific(this, fear_attack.animation, nil, store.tick_ts, 1)
				S:queue(fear_attack.sound)

				if SU.y_hero_wait(store, this, fear_attack.cast_time) then
					goto label_beresad_0
				end

				_, enemies = U.find_foremost_enemy_in_range_filter_on(this.pos, fear_attack.max_range, nil, fear_attack.vis_flags, fear_attack.vis_bans, SU.is_valid_scare_target)

				if enemies then
					local count = math.min(#enemies, fear_attack.max_targets)

					for i = 1, count do
						local target = enemies[i]

						if SU.scare_enemy(target, {
							duration = E:get_template(fear_attack.mod).modifier.duration,
							friend_mod = fear_attack.mod
						}) then
							local mod = E:create_entity(fear_attack.mod)

							mod.modifier.target_id = target.id
							mod.modifier.source_id = this.id

							simulation:queue_insert_entity(mod)
						end
					end

					fear_attack.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, this.hero.skills.fear_dragon)
				end

				if SU.y_hero_animation_wait(this) then
					goto label_beresad_0
				end
			else
				fear_attack.ts = fear_attack.ts + 0.1
			end
		end

		if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
			local enemy = find_target_at_critical_moment(this, this.ranged.attacks[1].max_range, F_RANGED, F_NONE)

			if enemy and enemy.pos then
				this.ultimate.ts = store.tick_ts

				U.y_animation_play_once_specific(this, "levelup", nil, store.tick_ts, 1)
				S:queue(this.sound_events.change_rally_point)

				local e = E:create_entity(this.hero.skills.ultimate.controller_name)

				e.damage_factor = this.unit.damage_factor
				e.pos = V.vclone(enemy.pos)
				e.level = this.hero.skills.ultimate.level

				simulation:queue_insert_entity(e)
				SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
			else
				this.ultimate.ts = this.ultimate.ts + 1
			end
		end

		for _, i in ipairs(this.ranged.order) do
			local a = this.ranged.attacks[i]

			if a.disabled then
			-- block empty
			elseif a.sync_animation and not this.render.sprites[1].sync_flag then
			-- block empty
			elseif ready_to_attack(a, store, this.unit.cooldown_factor) then
				local origin = V.v(this.pos.x, this.pos.y + a.bullet_start_offset[1].y)
				local bullet_t = E:get_template(a.bullet)
				local bullet_speed = bullet_t.bullet.min_speed or 390
				local flight_time = bullet_t.bullet.flight_time
				local target, targets = U.find_foremost_enemy_between_range_filter_off(this.pos, a.min_range, a.max_range, nil, a.vis_flags, a.vis_bans)

				-- 秒杀添加血量过滤
				if i == 3 and target then
					target = nil

					for i = 1, #targets do
						local t = targets[i]

						if t.health.hp > BIG_ENEMY_HP then
							target = t

							break
						end
					end
				end

				if target then
					local start_ts = store.tick_ts
					local node_offset

					if flight_time then
						node_offset = P:predict_enemy_node_advance(target, flight_time + a.shoot_time)
					else
						local dist = V.dist(origin.x, origin.y, target.pos.x, target.pos.y)

						node_offset = P:predict_enemy_node_advance(target, dist / bullet_speed)
					end

					local t_pos

					if i == 2 then
						t_pos = P:node_pos(target.nav_path.pi, 1, target.nav_path.ni + node_offset)
					else
						t_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + node_offset)
					end

					local an, af, ai = U.animation_name_facing_point(this, a.animation, t_pos)

					U.animation_start_default(this, an, af, store.tick_ts)

					while store.tick_ts - start_ts < a.shoot_time do
						if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
							goto label_beresad_0
						end

						coroutine.yield()
					end

					-- 重新索敌，以找到更好的敌人
					local new_target, new_targets = U.find_foremost_enemy_between_range_filter_off(this.pos, a.min_range, a.max_range, nil, a.vis_flags, a.vis_bans)

					if new_target then
						target = new_target

						if i == 3 then
							for i = 1, #new_targets do
								local t = new_targets[i]

								if t.health.hp > BIG_ENEMY_HP then
									target = t

									break
								end
							end
						end
					end

					local b, emit_fx, emit_ps

					S:queue(a.sound)

					b = E:create_entity(a.bullet)
					b.bullet.target_id = target.id
					b.bullet.source_id = this.id
					b.bullet.damage_factor = this.unit.damage_factor
					b.bullet.damage_min = b.bullet.damage_min + this.unit.damage_buff
					b.bullet.damage_max = b.bullet.damage_max + this.unit.damage_buff

					b.pos:copy(this.pos)

					b.pos.x = b.pos.x + (af and -1 or 1) * a.bullet_start_offset[ai].x
					b.pos.y = b.pos.y + a.bullet_start_offset[ai].y

					b.bullet.from:copy(b.pos)

					b.bullet.to = V.v(t_pos.x, t_pos.y)

					simulation:queue_insert_entity(b)

					if a.xp_from_skill then
						SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
					end

					a.ts = start_ts

					if a.emit_ps and b.bullet.flight_time then
						local dest = V.vclone(b.bullet.to)

						if i == 2 then
							dest.y = dest.y + 15
						end

						local ps = E:create_entity(a.emit_ps)
						local mspeed = V.dist(dest.x, dest.y, b.bullet.from.x, b.bullet.from.y) / b.bullet.flight_time

						ps.particle_system.emit_direction = V.angleTo(dest.x - b.bullet.from.x, dest.y - b.bullet.from.y)
						ps.particle_system.emit_speed = {mspeed, mspeed}
						ps.particle_system.flip_x = af
						ps.pos.x, ps.pos.y = b.bullet.from.x, b.bullet.from.y

						simulation:queue_insert_entity(ps)

						emit_ps = ps
					end

					if a.emit_fx then
						local fx = E:create_entity(a.emit_fx)

						fx.pos.x, fx.pos.y = b.bullet.from.x, b.bullet.from.y
						fx.render.sprites[1].ts = store.tick_ts
						fx.render.sprites[1].flip_x = af

						if af and fx.render.sprites[1].offset.x then
							fx.render.sprites[1].offset.x = -1 * fx.render.sprites[1].offset.x
						end

						simulation:queue_insert_entity(fx)

						emit_fx = fx
					end

					while not U.animation_finished_default(this) do
						if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
							goto label_383_0
						end

						coroutine.yield()
					end

					::label_383_0::

					if emit_ps then
						emit_ps.particle_system.emit = false
						emit_ps.particle_system.source_lifetime = 0
					end

					if emit_fx then
						emit_fx.render.sprites[1].hidden = true
					end

					goto label_beresad_0
				end
			end
		end

		SU.soldier_idle(store, this)
		SU.soldier_regen(store, this)

		::label_beresad_0::

		coroutine.yield()
	end
end

local function mod_beresad_ultimate_remove(this, store)
	local target = store.entities[this.modifier.target_id]

	if target then
		if target.health.dead then
			local fx = E:create_entity("fx_coin_jump")

			fx.pos.x, fx.pos.y = target.pos.x, target.pos.y
			fx.render.sprites[1].ts = store.tick_ts

			if target.health_bar then
				fx.render.sprites[1].offset.y = target.health_bar.offset.y
			end

			simulation:queue_insert_entity(fx)

			store.player_gold = store.player_gold + 3
		end
	end

	return true
end

tt = RT("hero_beresad", "hero")

AC(tt, "ranged", "timed_attacks")

tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.hp_max = {375, 400, 425, 450, 475, 500, 525, 550, 575, 600}
tt.hero.level_stats.ranged_damage_min = {23, 25, 27, 29, 31, 33, 35, 37, 39, 41}
tt.hero.level_stats.ranged_damage_max = {31, 36, 41, 46, 51, 56, 61, 66, 71, 76}
tt.hero.skills.conflagration = CC("hero_skill")
tt.hero.skills.conflagration.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.conflagration.xp_gain = {100, 200, 300}
tt.hero.skills.conflagration.cooldown = {28, 24, 20}
tt.hero.skills.conflagration.damage = {3, 5, 7}
tt.hero.skills.fear_dragon = CC("hero_skill")
tt.hero.skills.fear_dragon.duration = {3, 5, 7}
tt.hero.skills.fear_dragon.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.fear_dragon.xp_gain = {100, 200, 300}
tt.hero.skills.dragon_spawn = CC("hero_skill")
tt.hero.skills.dragon_spawn.cooldown = {45, 40, 35}
tt.hero.skills.dragon_spawn.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.dragon_spawn.xp_gain = {160, 320, 480}
tt.hero.skills.dragon_spawn.hp = {300, 400, 500}
tt.hero.skills.dragon_spawn.damage_min = {18, 30, 42}
tt.hero.skills.dragon_spawn.damage_max = {27, 45, 63}
tt.hero.skills.dragon_spawn.explode_damage_min = {20, 30, 40}
tt.hero.skills.dragon_spawn.explode_damage_max = {30, 45, 60}
tt.hero.skills.remove_existence = CC("hero_skill")
tt.hero.skills.remove_existence.cooldown = {70, 60, 50}
tt.hero.skills.remove_existence.damage_min = {40, 60, 80}
tt.hero.skills.remove_existence.damage_max = {60, 90, 120}
tt.hero.skills.remove_existence.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.remove_existence.xp_gain = {210, 420, 630}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.ultimate.xp_gain = {240, 480, 720, 960}
tt.hero.skills.ultimate.controller_name = "controller_beresad_ultimate"
tt.hero.skills.ultimate.damage = {3, 5, 7, 9}
tt.health.dead_lifetime = 15
tt.regen.cooldown = 1
tt.health_bar.offset = v(0, 145)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.ui.click_rect = r(-25, 70, 60, 60)
tt.unit.hit_offset = v(0, 98)
tt.unit.marker_offset = v(0, -0.15)
tt.unit.mod_offset = v(0, 101)
tt.hero.fn_level_up = hero_beresad_level_up
tt.info.hero_portrait = "kr4_hero_portraits_0008"
tt.info.portrait = "kr4_info_portraits_heroes_0008"
tt.main_script.update = hero_beresad_update
tt.motion.max_speed = 90
tt.nav_rally.requires_node_nearby = false
tt.nav_grid.ignore_waypoints = true
tt.nav_grid.valid_terrains = TERRAIN_ALL_MASK
tt.nav_grid.valid_terrains_dest = TERRAIN_ALL_MASK
tt.render.sprites[1].anchor.y = 0.04
tt.render.sprites[1].prefix = "hero_beresad"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].angles.walk = {"idle"}
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "hero_beresad_shadow"
tt.render.sprites[2].z = Z_DECALS + 1
tt.sound_events.change_rally_point = "group_beresad_taunt"
tt.sound_events.death = "hero_beresad_death"
tt.sound_events.hero_room_select = "hero_beresad_taunt_1"
tt.sound_events.insert = "hero_beresad_taunt_1"
tt.sound_events.respawn = "group_beresad_taunt"
tt.vis.bans = bor(tt.vis.bans, F_BURN)
tt.vis.flags = bor(tt.vis.flags, F_FLYING)
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].bullet = "bolt_beresad"
tt.ranged.attacks[1].bullet_start_offset = {v(45, 85)}
tt.ranged.attacks[1].cooldown = 1.5
tt.ranged.attacks[1].max_range = 175
tt.ranged.attacks[1].shoot_time = fts(10)
tt.ranged.attacks[1].animation = "attack"
tt.ranged.attacks[1].sound = "hero_beresad_attack_shot"
tt.ranged.attacks[1].ignore_hit_offset = true
tt.ranged.attacks[1].estimated_flight_time = 1
tt.ranged.attacks[2] = CC("bullet_attack")
tt.ranged.attacks[2].disabled = true
tt.ranged.attacks[2].bullet = "controller_aura_beresad_firestorm"
tt.ranged.attacks[2].bullet_start_offset = {v(45, 85)}
tt.ranged.attacks[2].cooldown = 28
tt.ranged.attacks[2].min_range = 25
tt.ranged.attacks[2].max_range = 130
tt.ranged.attacks[2].shoot_time = fts(13)
tt.ranged.attacks[2].animation = "conflagration"
tt.ranged.attacks[2].sound = "hero_beresad_conflagration"
tt.ranged.attacks[2].xp_from_skill = "conflagration"
tt.ranged.attacks[2].vis_bans = F_FLYING
tt.ranged.attacks[2].vis_flags = bor(F_RANGED, F_AREA)
tt.ranged.attacks[3] = CC("bullet_attack")
tt.ranged.attacks[3].disabled = true
tt.ranged.attacks[3].bullet = "ray_beresad_disintegrate"
tt.ranged.attacks[3].bullet_start_offset = {v(45, 85)}
tt.ranged.attacks[3].cooldown = 70
tt.ranged.attacks[3].max_range = 175
tt.ranged.attacks[3].shoot_time = fts(23)
tt.ranged.attacks[3].animation = "remove"
tt.ranged.attacks[3].xp_from_skill = "remove_existence"
tt.ranged.attacks[3].sound = "hero_beresad_remove"
tt.ranged.attacks[3].vis_bans = bor(F_BOSS)
tt.ranged.attacks[3].vis_flags = bor(F_RANGED, F_INSTAKILL)
tt.ranged.attacks[4] = CC("bullet_attack")
tt.ranged.attacks[4].disabled = true
tt.ranged.attacks[4].bullet = "bomb_beresad_golem"
tt.ranged.attacks[4].bullet_start_offset = {v(40, 100)}
tt.ranged.attacks[4].max_range = 100
tt.ranged.attacks[4].cooldown = 45
tt.ranged.attacks[4].shoot_time = fts(15)
tt.ranged.attacks[4].animation = "golem"
tt.ranged.attacks[4].sound = "hero_beresad_spawn_spit"
tt.ranged.attacks[4].vis_flags = bor(F_RANGED, F_BLOCK, F_AREA)
tt.ranged.attacks[4].vis_bans = bor(F_FRIEND, F_FLYING, F_CLIFF, F_WATER)
tt.ranged.attacks[4].xp_from_skill = "dragon_spawn"
tt.timed_attacks.list[1] = CC("mod_attack")
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].mod = "mod_beresad_fear_indicator"
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].max_range = 150
tt.timed_attacks.list[1].max_targets = 6
tt.timed_attacks.list[1].cooldown = 22
tt.timed_attacks.list[1].cast_time = fts(20)
tt.timed_attacks.list[1].animation = "fear"
tt.timed_attacks.list[1].sound = "hero_beresad_fear"
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[1].vis_bans = bor(F_FRIEND, F_FLYING, F_CLIFF, F_WATER)
tt.timed_attacks.list[1].xp_from_skill = "fear_dragon"
tt.ultimate = {
	ts = 0,
	cooldown = 56,
	disabled = true
}
tt = RT("bolt_beresad", "bullet")
tt.render.sprites[1].name = "hero_beresad_attack_proyectile_travel"
tt.render.sprites[1].anchor.x = 0.69
tt.bullet.min_speed = 390
tt.bullet.max_speed = 390
tt.bullet.xp_gain_factor = 2.5
tt.bullet.hit_fx = "hero_beresad_attack_explosion"
tt.bullet.hit_fx_air = "hero_beresad_attack_explosion_air"
tt.bullet.particles_name = "hero_beresad_attack_particle"
tt.main_script.update = scripts.fireball_dragon.update
tt.main_script.remove = bolt_beresad_remove
tt.sound_events.hit = "hero_beresad_attack_impact"
tt = RT("hero_beresad_attack_particle")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "hero_beresad_attack_proyectile_particle_run"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.alphas = {255, 0}
tt.particle_system.particle_lifetime = {fts(12), fts(12)}
tt.particle_system.scales_x = {1, 1.25}
tt.particle_system.scales_y = {1, 1.25}
tt.particle_system.emission_rate = 30
tt = RT("hero_beresad_attack_explosion", "fx")
tt.render.sprites[1].name = "hero_beresad_attack_explosion_run"
tt.render.sprites[1].anchor.y = 0.13
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -2
tt = RT("hero_beresad_attack_explosion_air", "fx")
tt.render.sprites[1].name = "hero_beresad_attack_explosion_air_run"
tt.render.sprites[1].anchor.y = 0.13
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -2
tt = RT("controller_aura_beresad_firestorm", "bullet")
tt.render = nil
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.damage_radius = 65
tt.bullet.hit_payload = "aura_beresad_firestorm"
tt.bullet.flight_time = fts(12)
tt.bullet.ignore_hit_offset = true
tt.delay_betweeen_flames = fts(2)
tt.flame_bullet = "beresad_breath_flame"
tt.flames_count = 12
tt.main_script.insert = flame_insert
tt.main_script.update = flame_update
tt = RT("beresad_breath_flame")

AC(tt, "pos", "render")

tt.render.sprites[1].name = "hero_beresad_conflagration_particle_travel"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[1].fps = 15
tt = RT("aura_beresad_firestorm", "aura")

AC(tt, "render", "tween")

tt.sound_events.insert = "hero_beresad_flameloop"
tt.aura.cycle_time = 0.2
tt.aura.duration = 5
tt.aura.mod = "mod_beresad_firestorm"
tt.aura.radius = 50
tt.aura.vis_bans = bor(F_FRIEND, F_FLYING)
tt.aura.vis_flags = bor(F_MOD)
tt.aura.use_mod_offset = false
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.render.sprites[1].name = "hero_beresad_conflagration_fire_idle"
tt.render.sprites[1].z = Z_DECALS
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 255}, {"this.aura.duration-1", 255}, {"this.aura.duration", 0}}
tt = RT("mod_beresad_firestorm", "modifier")

AC(tt, "dps", "render")

tt.dps.damage_min = 2
tt.dps.damage_max = 2
tt.dps.damage_type = DAMAGE_TRUE
tt.dps.damage_every = 0.2
tt.modifier.duration = 1
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt.render.sprites[1].name = "hero_beresad_conflagration_modifier_run"
tt.render.sprites[1].draw_order = 10
tt = RT("mod_beresad_fear_indicator", "modifier")

AC(tt, "render", "slow")

tt.modifier.duration = 3
-- 加速 50%
tt.slow.factor = 1.5
tt.main_script.insert = scripts.mod_slow.insert
tt.main_script.update = scripts.mod_track_target.update
tt.main_script.remove = scripts.mod_slow.remove
tt.render.sprites[1].name = "hero_beresad_modifier_fear_run"
tt.render.sprites[1].draw_order = DO_MOD_FX
tt = RT("bomb_beresad_golem", "bomb")
tt.bullet.damage_min = 1
tt.bullet.damage_max = 1
tt.bullet.damage_radius = 50
tt.bullet.hit_payload = "hero_beresad_golem"
tt.bullet.hit_fix = "hero_beresad_golemspawn_hit"
tt.bullet.hit_decal = "hero_beresad_golemspawn_explosion"
tt.bullet.particles_name = "hero_beresad_golemspawn_particle"
tt.render.sprites[1].name = "hero_beresad_golemspawn_proyectile"
tt.sound_events.insert = "FireballRelease"
tt.sound_events.hit = "hero_beresad_spawn_impact"
tt = RT("hero_beresad_golem", "soldier_militia")

AC(tt, "reinforcement")

tt.health_bar.offset = v(0, 50)
tt.health.hp_max = 300
tt.health.dead_lifetime = 4
tt.reinforcement.duration = 20
tt.regen.health = 0
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.soldier_reinforcement.update
tt.reinforcement.fade = false
tt.info.portrait = "kr4_info_portraits_soldiers_0012"
tt.info.random_name_format = nil
tt.info.random_name_count = nil
tt.motion.max_speed = 30
tt.melee.range = 50
tt.melee.attacks[1].cooldown = 1.5
tt.melee.attacks[1].damage_min = 18
tt.melee.attacks[1].damage_max = 27
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].chance = 0.5
tt.render.sprites[1].prefix = "hero_beresad_golem"
tt.render.sprites[1].name = "raise"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "hero_beresad_golem_shadow"
tt.render.sprites[2].z = Z_DECALS + 1
tt.render.sprites[2].anchor.y = 0.18
tt.vis.bans = bor(tt.vis.bans, F_POISON, F_BLOOD, F_BURN, F_SKELETON, F_CANNIBALIZE, F_LYCAN)
tt = RT("hero_beresad_golemspawn_hit", "fx")
tt.render.sprites[1].name = "hero_beresad_golemspawn_hit_run"
tt.render.sprites[1].anchor.y = 0.15
tt.render.sprites[1].z = Z_OBJECTS
tt = RT("hero_beresad_golemspawn_explosion", "decal_tween")
tt.render.sprites[1].name = "hero_beresad_golemspawn_explosion_run"
tt.render.sprites[1].loop = false
tt.tween.props[1].keys = {{fts(17), 255}, {fts(27), 0}}
tt = RT("hero_beresad_golemspawn_particle")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "hero_beresad_golemspawn_particle_run"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.alphas = {255, 0}
tt.particle_system.particle_lifetime = {fts(12), fts(12)}
tt.particle_system.scales_x = {1, 1.25}
tt.particle_system.scales_y = {1, 1.25}
tt.particle_system.emission_rate = 30
tt = RT("ray_beresad_disintegrate", "bullet")
tt.bullet.damage_type = bor(DAMAGE_DISINTEGRATE, DAMAGE_INSTAKILL, DAMAGE_NO_SPAWNS)
tt.bullet.hit_time = 0
tt.bullet.hit_fx = "fx_ray_beresad_disintegrate"
tt.bullet.pop = {"pop_zap_arcane"}
tt.bullet.pop_conds = DR_KILL
tt.main_script.update = scripts.ray_simple.update
tt.sound_events.insert = "ArcaneRaySound"
tt.track_target = true
tt.ray_duration = fts(8)
tt.bullet.mod = "mod_ray_beresad_disintegrate"
tt.image_width = 100
tt.render.sprites[1].anchor = vec_2(0, 0.5)
tt.render.sprites[1].name = "hero_beresad_remove_ray_run"
tt.render.sprites[1].loop = false
tt.sound_events.insert = "hero_beresad_remove"
tt = RT("fx_ray_beresad_disintegrate", "fx")
tt.render.sprites[1].name = "hero_beresad_remove_explosion_fx"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "hero_beresad_remove_explosion_run"
tt.render.sprites[2].z = Z_BULLETS
tt.render.sprites[2].anchor.y = 0.1
tt = RT("mod_ray_beresad_disintegrate", "modifier")
tt.main_script.insert = mod_ray_beresad_disintegrate_insert
tt.explode_radius = 50
tt.explode_damage_type = DAMAGE_TRUE
tt.explode_damage_min = 8
tt.explode_damage_max = 12
tt.explode_vis_flags = F_AREA
tt.explode_vis_bans = F_NONE
tt = RT("controller_beresad_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.duration = 4
tt.damage_radius = 9999
tt.main_script.update = controller_beresad_ultimate_update
tt.sound_events.insert = "hero_beresad_ultimate"
tt.mod = "mod_beresad_ultimate"
tt.mod_cooldown = 0.25
tt.rain = {}
tt.rain.alpha_max = 255
tt.rain.alpha_min = 150
tt.rain.angle_between = 2 * math.pi / 180
tt.rain.angle_max = -60 * math.pi / 180
tt.rain.angle_min = -80 * math.pi / 180
tt.rain.cooldown = 0.1
-- 50
tt.rain.count = 50
tt.rain.delay_max = 0.2
tt.rain.disabled = false
tt.rain.distance_max = 550
tt.rain.distance_min = 450
-- 0.2
tt.rain.duration = 0.2
tt.rain.ts = 0
tt.rain.drop = "fx_power_beresad_drop"
tt.overlay_alpha_min = 0
tt.overlay_alpha_max = 30
tt = RT("fx_power_beresad_drop", "fx")

AC(tt, "tween", "main_script")

tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "hero_beresad_ultimate_bolt"
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.main_script.remove = fx_power_beresad_drop_remove
tt = RT("fx_power_beresad_rain_splash", "fx")
tt.render.sprites[1].name = "hero_beresad_ultimate_hit_run"
tt = RT("mod_beresad_ultimate", "modifier")

AC(tt, "dps", "render")

tt.dps.damage_type = DAMAGE_TRUE
tt.dps.damage_every = 0.25
tt.modifier.duration = 4
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps_with_fade.update
tt.main_script.remove = mod_beresad_ultimate_remove
tt.render.sprites[1].prefix = "hero_beresad_ultimate_modifier"
tt.render.sprites[1].draw_order = 10
tt.render.sprites[1].name = "start"
tt.start_animation = "start"
tt.loop_animation = "loop"
tt.stop_animation = "stop"
