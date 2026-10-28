local scripts = require("scripts")
local E = require("entity_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")
local bit = require("bit")
local km = require("lib.klua.macros")
local apply_ultimate = HU.apply_ultimate
local bor = bit.bor
local find_target_at_critical_moment = HU.find_target_at_critical_moment
local fts = U.fts
local level_up_basic = HU.level_up_basic
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local v = V.v
local tt

local function bomb_tramin_skill1_insert(this, store)
	local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)

	if #nodes < 1 then
		return false
	end

	this.nav_path.pi = nodes[1][1]
	this.nav_path.spi = nodes[1][2]
	this.nav_path.ni = nodes[1][3]

	return true
end

local function hero_tramin_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local b = E:get_template(this.ranged.attacks[1].bullet)

	b.bullet.damage_min = ls.ranged_damage_min[hl]
	b.bullet.damage_max = ls.ranged_damage_max[hl]
	b = E:get_template(this.ranged.attacks[3].bullet)
	b.bullet.damage_min = ls.ranged_damage_min[hl]
	b.bullet.damage_max = ls.ranged_damage_max[hl]

	-- 1技能 自爆机器人
	upgrade_skill(this, "bombots", function(this, s)
		this.ranged.attacks[2].disabled = nil

		local a = E:get_template("aura_bomb_tramin_skill1")

		a.aura.damage_min = s.damage_min[s.level]
		a.aura.damage_max = s.damage_max[s.level]

		local b = E:get_template("bullet_tramin_robot")

		b.bullet.damage_min = s.damage_min[s.level]
		b.bullet.damage_max = s.damage_max[s.level]
	end)
	-- 2技能 饮硝狂奔
	upgrade_skill(this, "nitro_rush", function(this, s)
		this.timed_attacks.list[2].disabled = nil
	end)
	-- 3技能 闪光弹
	upgrade_skill(this, "flashbang", function(this, s)
		this.ranged.attacks[3].disabled = nil

		local m = E:get_template("mod_tramin_stun")

		m.modifier.duration = s.duration[s.level]
	end)
	-- 4技能 火箭弹幕
	upgrade_skill(this, "rocket_barrage", function(this, s)
		this.timed_attacks.list[1].disabled = nil

		local b = E:get_template(this.timed_attacks.list[1].bullet)

		b.bullet.damage_min = s.damage_min[s.level]
		b.bullet.damage_max = s.damage_max[s.level]
	end)
	-- 大招 疯狂炸弹人
	upgrade_skill(this, "ultimate", function(this, s)
		this.ultimate.disabled = nil

		local e = E:get_template("aura_box_tramin")

		e.spawner.count = s.entity_count[s.level]

		local e = E:get_template("aura_bomb_tramin_ultimate")

		e.aura.damage_min = s.damage_config[s.level]
		e.aura.damage_max = s.damage_config[s.level]
	end)
	update_hp(this)
end

local function hero_tramin_update(this, store)
	local h = this.health
	local nitro_mod
	local a, skill, brk, sta
	local missle_attack = this.timed_attacks.list[1]
	local drink_attack = this.timed_attacks.list[2]
	local drink_stage = 0
	local drink_ts = 0
	local r = this.nav_rally

	this.health_bar.hidden = true

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			if r.new then
				r.new = false

				U.unblock_target(store, this)
				U.set_destination(this, r.pos)

				local offset = V.v(r.pos.x - r.center.x, r.pos.y - r.center.y)
				local old_center = V.v(this.pos.x - offset.x, this.pos.y - offset.y)
				local af = this.motion.dest.x < this.pos.x

				if V.dist2(r.center.x, r.center.y, old_center.x, old_center.y) < this.max_dist_walk * this.max_dist_walk then
					U.animation_start_loop_specific(this, "running", af, store.tick_ts, 1)

					while not this.motion.arrived do
						if this.health.dead or this.unit.is_stunned then
							break
						end

						if r.new then
							break
						end

						U.walk_off__accel__unsnapped(this, store.tick_length)
						coroutine.yield()

						this.motion.speed.x, this.motion.speed.y = 0, 0
					end

					U.animation_start_loop_specific(this, "idle", af, store.tick_ts, 1)
				else
					-- 火箭跳
					S:queue("hero_tramin_jump")
					SU.remove_modifiers(store, this, nil, "mod_tramin_drink")
					U.y_animation_play_default(this, "toJetpack", af, store.tick_ts)
					U.animation_start_loop_specific(this, "jetpack", af, store.tick_ts, 1)

					local ps = E:create_entity("ps_jatpack_tramin")

					ps.particle_system.track_id = this.id
					ps.particle_system.emit = true

					simulation:queue_insert_entity(ps)

					local g = -2 / (fts(1) * fts(1))
					local flight_time = this.flight_time
					local speed = SU.initial_parabola_speed(this.pos, this.nav_rally.pos, flight_time, g)
					local from = V.vclone(this.pos)
					local ts = store.tick_ts
					local fpos = V.vclone(this.nav_rally.pos)
					local dist = V.dist(fpos.x, fpos.y, from.x, from.y)
					local dir = V.v((fpos.x - from.x) / dist, (fpos.y - from.y) / dist)

					this.motion.speed.x, this.motion.speed.y = 0, 0

					local shadow = this.render.sprites[2]
					local orig_offset_y = shadow.offset.y

					while flight_time > store.tick_ts - ts do
						this.pos.x, this.pos.y = SU.position_in_parabola(store.tick_ts - ts, from, speed, g)

						local dis_floor = (this.pos.x - from.x) / dir.x
						local height = this.pos.y - (dir.y * dis_floor + from.y)

						this.render.sprites[1].sort_y_offset = -height
						shadow.offset.y = -height + orig_offset_y

						local s = km.clamp(0.5, 1, 40 / height)

						shadow.scale:set(s, s)
						coroutine.yield()
					end

					this.render.sprites[1].sort_y_offset = 0

					this.pos:copy(fpos)

					shadow.offset.y = orig_offset_y
					ps.particle_system.emit = false

					simulation:queue_remove_entity(ps)
					S:queue("hero_tramin_land")

					local fx = E:create_entity("fx")

					fx.pos:copy(this.pos)

					fx.render.sprites[1].name = "hero_tramin_jetpack_floor_run"
					fx.render.sprites[1].ts = store.tick_ts
					fx.render.sprites[1].z = Z_DECALS
					fx.render.sprites[1].offset = v(0, 20)

					simulation:queue_insert_entity(fx)
					U.y_animation_play(this, "outJetpack", af, store.tick_ts, 1)
					U.animation_start_default(this, "idle", af, store.tick_ts, false)
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)
			-- 2技能 饮硝狂奔
			a = drink_attack
			skill = this.hero.skills.nitro_rush

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local target = U.detect_foremost_enemy_between_range_filter_off(this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if not target then
					a.ts = a.ts + 0.1
				else
					S:queue(a.sound)

					local an, af = U.animation_name_facing_point(this, a.animation, target.pos)

					U.animation_start(this, an, af, store.tick_ts, false, 1)

					if SU.y_hero_animation_wait(this) then
						goto label_40244_0
					end

					drink_stage = 1
					drink_ts = store.tick_ts
					this.ranged.attacks[1].cooldown = this.ranged.attacks[1].cooldown / 2
					this.flight_time = this.flight_time * 0.8
					a.ts = store.tick_ts

					SU.insert_unit_cooldown_buff(store.tick_ts, this, a.cooldown_factor)

					nitro_mod = E:create_entity("mod_tramin_drink")
					nitro_mod.render.sprites[1].ts = store.tick_ts
					nitro_mod.modifier.source_id = this.id
					nitro_mod.modifier.target_id = this.id

					simulation:queue_insert_entity(nitro_mod)
					SU.hero_gain_xp_from_skill(this, skill)
				end
			end

			if drink_stage == 1 and store.tick_ts - drink_ts >= skill.duration[skill.level] then
				this.ranged.attacks[1].cooldown = this.ranged.attacks[1].cooldown * 2
				this.flight_time = this.flight_time / 0.8

				SU.remove_unit_cooldown_buff(store.tick_ts, this, a.cooldown_factor)

				drink_stage = 0

				simulation:queue_remove_entity(nitro_mod)

				nitro_mod = nil
			end

			-- 4技能 火箭弹幕
			a = missle_attack
			skill = this.hero.skills.rocket_barrage

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local target = U.detect_foremost_enemy_between_range_filter_off(this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if not target then
					a.ts = a.ts + 0.1
				else
					local start_ts = store.tick_ts
					local an, af = U.animation_name_facing_point(this, a.animation_pre, target.pos)

					U.animation_start(this, an, af, store.tick_ts, false, 1)

					if SU.y_hero_animation_wait(this) then
						goto label_40244_0
					end

					a.ts = start_ts

					SU.hero_gain_xp_from_skill(this, skill)

					local burst_count = skill.count[skill.level]
					local fire_loops = burst_count / #a.hit_times
					local new_target = U.detect_foremost_enemy_between_range_filter_off(this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

					if new_target then
						target = new_target
					end

					for i = 1, fire_loops do
						local an, af

						if i == fire_loops then
							an, af = U.animation_name_facing_point(this, a.animation, target.pos)
						else
							an, af = U.animation_name_facing_point(this, a.animation_last, target.pos)
						end

						U.animation_start(this, an, af, store.tick_ts, false, 1)

						for hi, ht in ipairs(a.hit_times) do
							while ht > store.tick_ts - this.render.sprites[1].ts do
								if this.nav_rally.new then
									goto label_40244_1
								end

								coroutine.yield()
							end

							local b = E:create_entity(a.bullet)

							b.pos.x = this.pos.x + (af and -1 or 1) * a.start_offsets[km.zmod(hi, #a.start_offsets)].x
							b.pos.y = this.pos.y + a.start_offsets[hi].y
							b.bullet.level = skill.level

							b.bullet.from:copy(b.pos)

							b.bullet.to = V.v(b.pos.x + (af and -1 or 1) * a.launch_vector.x, b.pos.y + a.launch_vector.y)
							b.bullet.target_id = target.id
							b.bullet.damage_factor = this.unit.damage_factor
							b.bullet.source_id = this.id

							simulation:queue_insert_entity(b)

							local new_target = U.detect_foremost_enemy_between_range_filter_off(this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

							if new_target then
								target = new_target
							end
						end
					end

					::label_40244_1::

					U.animation_start(this, a.animation_post, nil, store.tick_ts, false, 1)

					if SU.y_hero_animation_wait(this) then
						goto label_40244_0
					end
				end
			end

			-- 大招 疯狂炸弹人
			if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
				local enemy = find_target_at_critical_moment(this, this.ranged.attacks[1].max_range, F_RANGED, F_FLYING, nil, nil, true)

				if enemy then
					apply_ultimate(this, store, this.pos, "levelup")
				else
					this.ultimate.ts = this.ultimate.ts + 1
				end
			end

			if brk or sta ~= A_NO_TARGET then
			-- block empty
			else
				brk, sta = SU.y_soldier_ranged_attacks(store, this)

				if brk then
				-- block empty
				elseif SU.soldier_go_back_step(store, this) then
				-- block empty
				else
					SU.soldier_idle(store, this)
					SU.soldier_regen(store, this)
				end
			end
		end

		::label_40244_0::

		coroutine.yield()
	end
end

local function hero_tramin_ultimate_update(this, store)
	local target_info = U.find_enemies_in_paths(store.enemies, this.pos, this.range_nodes_min, this.range_nodes_max, this.max_path_dist, this.vis_flags, this.vis_bans, true, function(e)
		return not U.flag_has(P:path_terrain_props(e.nav_path.pi), TERRAIN_FAERIE)
	end)
	local origin

	if not target_info then
		local nearest_nodes = P:nearest_nodes(this.pos.x, this.pos.y)

		origin = nearest_nodes[1]
	else
		origin = target_info[1].origin
	end

	local bullet_to_ni = origin[3] - math.random(8, 13)

	bullet_to_ni = km.clamp(5, P:get_end_node(origin[1]), bullet_to_ni)

	local bullet_to = P:node_pos(origin[1], 1, bullet_to_ni)
	local flip = bullet_to.x < this.pos.x
	-- S:queue(this.sound)
	local e = E:create_entity(this.payload)

	e.spawner.pi = origin[1]
	e.spawner.ni = bullet_to_ni
	e.pos = bullet_to
	e.damage_factor = this.damage_factor

	local b = E:create_entity(this.bullet)

	b.pos.x = this.pos.x + (flip and -1 or 1) * this.bullet_start_offset.x
	b.pos.y = this.pos.y + this.bullet_start_offset.y

	b.bullet.from:copy(b.pos)
	b.bullet.to:copy(e.pos)

	b.bullet.hit_payload = e

	simulation:queue_insert_entity(b)
	simulation:queue_remove_entity(this)
end

local function aura_box_tramin_update(this, store)
	local sp = this.spawner

	this.render.sprites[1].ts = store.tick_ts

	SU.insert_sprite(store, "decal_rock_crater", this.pos)
	U.y_wait_unconditional(store, sp.spawn_time)

	this.render.sprites[1].z = Z_DECALS

	S:queue(sp.sound)

	for i = 1, sp.count do
		local e = E:create_entity(sp.entity .. "_" .. math.random(1, 6))

		e.damage_factor = this.damage_factor
		e.pos.x, e.pos.y = this.pos.x, this.pos.y
		e.nav_path.pi = sp.pi
		e.nav_path.spi = km.zmod(i, 3)
		e.nav_path.ni = sp.ni

		simulation:queue_insert_entity(e)
		U.y_wait_unconditional(store, fts(10))
	end

	U.y_ease_key(store, this.render.sprites[1], "alpha", 255, 0, 1)
	simulation:queue_remove_entity(this)
end

tt = RT("bullet_tramin", "bomb")
tt.bullet.flight_time = fts(18)
tt.bullet.hit_fx = "fx_explosion_tramin"
tt.bullet.hit_decal = nil
tt.bullet.damage_min = 40
tt.bullet.damage_max = 40
tt.bullet.damage_radius = 36
tt.bullet.xp_gain_factor = 1.6
tt.bullet.use_hit_offset = true
tt.render.sprites[1].name = "hero_tramin_bomb_proyectile"
tt = RT("bullet_tramin_flashlight", "bomb")
tt.bullet.flight_time = fts(18)
tt.bullet.hit_fx = "fx_explosion_tramin_flashlight"
tt.bullet.hit_decal = nil
tt.bullet.hit_fx_water = nil
tt.bullet.damage_radius = 65
tt.bullet.mod = "mod_tramin_stun"
tt.bullet.pop = nil
tt.bullet.use_hit_offset = true
tt.render.sprites[1].name = "hero_tramin_bombot_proyectile"
tt = RT("hero_tramin", "hero")

AC(tt, "melee", "ranged", "timed_attacks")

tt.melee.range = 25
tt.health_bar.offset = v(0, 40)
tt.health.dead_lifetime = 15
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.tombstone_show_time = fts(90)
tt.hero.skills.bombots = CC("hero_skill")
tt.hero.skills.bombots.xp_gain = {60, 120, 180}
tt.hero.skills.bombots.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.bombots.damage_min = {28, 42, 56}
tt.hero.skills.bombots.damage_max = {52, 78, 104}
tt.hero.skills.nitro_rush = CC("hero_skill")
tt.hero.skills.nitro_rush.xp_gain = {100, 200, 300}
tt.hero.skills.nitro_rush.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.nitro_rush.duration = {10, 16, 22}
tt.hero.skills.flashbang = CC("hero_skill")
tt.hero.skills.flashbang.xp_gain = {60, 120, 180}
tt.hero.skills.flashbang.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.flashbang.duration = {1, 2, 3}
tt.hero.skills.rocket_barrage = CC("hero_skill")
tt.hero.skills.rocket_barrage.xp_gain = {80, 160, 240, 320}
tt.hero.skills.rocket_barrage.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.rocket_barrage.count = {2, 4, 6, 8}
tt.hero.skills.rocket_barrage.damage_min = {25, 32, 39, 40}
tt.hero.skills.rocket_barrage.damage_max = {46, 59, 72, 80}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_tramin_ultimate"
tt.hero.skills.ultimate.entity_count = {4, 6, 8, 10}
tt.hero.skills.ultimate.damage_config = {80, 120, 170, 200}
tt.hero.skills.ultimate.xp_gain = {150, 300, 450, 600}
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.ultimate = {
	ts = 0,
	cooldown = 56,
	disabled = true
}
tt.hero.level_stats.armor = {0.02, 0.04, 0.06, 0.08, 0.11, 0.14, 0.16, 0.19, 0.21, 0.24}
tt.hero.level_stats.hp_max = {180, 204, 228, 252, 276, 300, 324, 348, 372, 396}
tt.hero.level_stats.melee_damage_min = {4, 5, 5, 6, 6, 7, 7, 8, 8, 9}
tt.hero.level_stats.melee_damage_max = {11, 12, 13, 15, 16, 17, 19, 20, 23, 24}
tt.hero.level_stats.ranged_damage_min = {9, 10, 11, 12, 12, 13, 14, 15, 16, 16}
tt.hero.level_stats.ranged_damage_max = {16, 18, 20, 23, 26, 29, 32, 35, 36, 39}
tt.regen.cooldown = 1
tt.max_dist_walk = 160
tt.info.hero_portrait = "kr4_hero_portraits_0005"
tt.info.portrait = "kr4_info_portraits_heroes_0006"
tt.main_script.update = hero_tramin_update
tt.hero.fn_level_up = hero_tramin_level_up
tt.motion.max_speed = 2.7 * FPS
tt.soldier.melee_slot_offset = v(5, 0)
tt.sound_events.change_rally_point = "group_tramin_taunt"
tt.sound_events.death = "hero_tramin_death"
tt.sound_events.hero_room_select = "hero_tramin_taunt_1"
tt.sound_events.insert = "HeroPaladinTauntIntro"
tt.sound_events.respawn = "HeroPaladinTauntIntro"
tt.unit.mod_offset = v(0, 20)
tt.nav_grid.ignore_waypoints = true
tt.flight_time = 0.9
tt.render.sprites[1].anchor = v(0.5, 0.04)
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_tramin"
tt.render.sprites[1].offset = v(0, -27)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].offset = v(0, 17)
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "hero_tramin_shadow"
tt.render.sprites[2].scale = v(1, 1)
tt.render.sprites[2].z = Z_DECALS + 1
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 1
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].cooldown = 1.5
tt.ranged.attacks[1].min_range = 25
tt.ranged.attacks[1].max_range = 180
tt.ranged.attacks[1].bullet = "bullet_tramin"
tt.ranged.attacks[1].shoot_time = fts(11)
tt.ranged.attacks[1].check_target_before_shot = true
tt.ranged.attacks[1].animation = "throwBomb"

update_node_prediction(tt.ranged.attacks[1])

tt.ranged.attacks[1].bullet_start_offset = {v(-8, 24)}
-- 1技能 自爆机器人
tt.ranged.attacks[2] = CC("bullet_attack")
tt.ranged.attacks[2].cooldown = 20
tt.ranged.attacks[2].min_range = 25
tt.ranged.attacks[2].max_range = 180
tt.ranged.attacks[2].xp_from_skill = "bombots"
tt.ranged.attacks[2].disabled = true
tt.ranged.attacks[2].bullet = "bullet_tramin_robot"
tt.ranged.attacks[2].animation = "throwBombot"
tt.ranged.attacks[2].node_prediction = fts(35)
tt.ranged.attacks[2].shoot_time = fts(11)
tt.ranged.attacks[2].bullet_start_offset = {v(-8, 24)}
-- 3技能 闪光弹
tt.ranged.attacks[3] = CC("bullet_attack")
tt.ranged.attacks[3].cooldown = 24
tt.ranged.attacks[3].disabled = true
tt.ranged.attacks[3].min_range = 25
tt.ranged.attacks[3].max_range = 180
tt.ranged.attacks[3].xp_from_skill = "flashbang"
tt.ranged.attacks[3].bullet = "bullet_tramin_flashlight"
tt.ranged.attacks[3].animation = "throwFlashbang"
tt.ranged.attacks[3].shoot_time = fts(11)
tt.ranged.attacks[3].bullet_start_offset = {v(-8, 24)}
tt.ranged.attacks[3].check_target_before_shot = true

update_node_prediction(tt.ranged.attacks[3])

-- 4技能 火箭弹幕
tt.timed_attacks.list[1] = CC("bullet_attack")
tt.timed_attacks.list[1].animation_pre = "toRocketRain"
tt.timed_attacks.list[1].animation = "RocketRain"
tt.timed_attacks.list[1].animation_last = "RocketRain"
tt.timed_attacks.list[1].animation_post = "outRocketRain"
tt.timed_attacks.list[1].cooldown = 18
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].xp_from_skill = "rocket_barrage"
tt.timed_attacks.list[1].bullet = "missle_tramin"
tt.timed_attacks.list[1].start_offsets = {v(4, 40)}
tt.timed_attacks.list[1].hit_times = {fts(3)}
tt.timed_attacks.list[1].launch_vector = v(math.random(10, 40), math.random(30, 120))
tt.timed_attacks.list[1].max_range = 375
-- 2技能 饮硝狂奔
tt.timed_attacks.list[2] = CC("aura_attack")
tt.timed_attacks.list[2].animation = "drink"
tt.timed_attacks.list[2].cooldown = 40
tt.timed_attacks.list[2].cooldown_factor = 0.75
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].xp_from_skill = "nitro_rush"
tt.timed_attacks.list[2].sound = "hero_tramin_nitro"
tt.timed_attacks.list[2].hit_times = {fts(3)}
tt.timed_attacks.list[2].vis_flags = F_RANGED
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[2].min_range = 0
tt.timed_attacks.list[2].max_range = 180
tt = RT("fx_explosion_tramin", "fx")
tt.render.sprites[1].prefix = "hero_tramin_basic_melee_explotion"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].scale = v(1.2, 1.2)
tt.render.sprites[1].anchor.y = 0.13
tt = RT("bullet_tramin_robot", "bomb")
tt.bullet.flight_time = fts(25)
tt.bullet.hit_fx = "fx_explosion_tramin_robot"
tt.bullet.hit_decal = nil
tt.bullet.hit_fx_water = nil
tt.bullet.damage_min = 40
tt.bullet.min_speed = 300
tt.bullet.damage_max = 40
tt.bullet.damage_radius = 40
tt.bullet.hit_payload = "bomb_tramin_skill1"
tt.bullet.pop = nil
tt.render.sprites[1].name = "hero_tramin_bombot_proyectile"
tt.sound_events.hit = nil
tt = RT("fx_explosion_tramin_robot", "fx")
tt.render.sprites[1].name = "hero_tramin_bombot_landing"
tt.render.sprites[1].anchor.y = 0.13
tt = RT("aura_bomb_tramin_skill1", "aura_rabbit_kamihare")
tt.aura.damage_min = 110
tt.aura.damage_max = 155
tt.aura.radius = 30
tt.aura.damage_type = DAMAGE_EXPLOSION
tt.sound_events.insert = "BombExplosionSound"
tt = RT("mod_tramin_stun", "mod_stun")
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt.modifier.vis_bans = bor(F_FLYING, F_BOSS)
tt.modifier.duration = 1
tt = RT("fx_explosion_tramin_flashlight", "fx")
tt.render.sprites[1].prefix = "hero_tramin_flashbang_explotion"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].scale = v(1, 1)
tt.render.sprites[1].anchor.y = 0.13
tt = RT("missle_tramin", "bullet")
tt.render.sprites[1].name = "hero_tramin_misil_proyectile"
tt.render.sprites[1].animated = false
tt.render.sprites[1].flip_x = true
tt.bullet.damage_type = DAMAGE_EXPLOSION
tt.bullet.min_speed = 300
tt.bullet.max_speed = 600
tt.bullet.turn_speed = 10 * math.pi / 180 * 30
tt.bullet.acceleration_factor = 0.2
tt.bullet.hit_fx = "hero_tramin_tnt_proyectile_hit"
tt.bullet.hit_fx_air = "hero_tramin_tnt_proyectile_hit"
tt.bullet.hit_fx_water = "fx_explosion_water"
tt.bullet.damage_min = 25
tt.bullet.damage_max = 46
tt.bullet.damage_radius = 40
tt.bullet.damage_flags = F_AREA
tt.bullet.particles_name = "ps_missile_tramin"
tt.bullet.retarget_range = 99999
tt.main_script.insert = scripts.missile.insert
tt.main_script.update = scripts.missile.update
tt.sound_events.insert = "RocketLaunchSound"
tt.sound_events.hit = "BombExplosionSound"
tt.sound_events.hit_water = "RTWaterExplosion"
tt = RT("ps_missile_tramin")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "hero_tramin_misil_proyectile_particle_run"
tt.particle_system.animated = true
tt.particle_system.animation_fps = 50
tt.particle_system.loop = false
tt.particle_system.alphas = {255, 0}
tt.particle_system.particle_lifetime = {fts(8), fts(8)}
tt.particle_system.track_rotation = true
tt.particle_system.scales_x = {1, 1.25}
tt.particle_system.scales_y = {1, 1.25}
tt.particle_system.emission_rate = 30
tt = RT("ps_jatpack_tramin", "ps_missile_tramin")
tt.particle_system.name = "hero_tramin_jetpack_particle_run"
tt = RT("hero_tramin_tnt_proyectile_hit", "fx")
tt.render.sprites[1].prefix = "hero_tramin_tnt_proyectile_hit"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].anchor.y = 0.13
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = 0
tt = RT("mod_tramin_drink", "modifier")

AC(tt, "render")

tt.modifier.duration = -1
tt.modifier.use_mod_offset = false
tt.main_script.insert = scripts.mod_track_target.insert
tt.main_script.update = scripts.mod_track_target.update
tt.render.sprites[1].name = "hero_tramin_drink_decal"
tt.render.sprites[1].z = Z_DECALS
tt = RT("hero_tramin_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.cooldown = 56
tt.main_script.update = hero_tramin_ultimate_update
tt.bullet = "box_tramin"
tt.bullet_start_offset = v(35, 115)
tt.payload = "aura_box_tramin"
tt.range_nodes_max = 200
tt.range_nodes_min = 10
tt.max_path_dist = 50
tt.vis_flags = bor(F_RANGED, F_BLOCK)
tt.vis_bans = F_FLYING
tt = RT("box_tramin", "bomb")
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.flight_time = fts(30)
tt.bullet.hide_radius = nil
tt.bullet.pop = nil
tt.bullet.hit_fx = nil
tt.bullet.hit_decal = nil
tt.bullet.rotation_speed = -15 * FPS * math.pi / 180
tt.sound_events.insert = nil
tt.render.sprites[1].name = "hero_tramin_ultimate_box_0001"
tt = RT("aura_box_tramin", "decal_scripted")

AC(tt, "spawner", "sound_events")

tt.render.sprites[1].anchor.y = 0.25
tt.render.sprites[1].name = "hero_tramin_ultimate_box_open"
tt.render.sprites[1].loop = false
tt.spawner.entity = "bomb_tramin_ultimate"
tt.spawner.spawn_time = fts(10)
tt.spawner.count = 3
tt.main_script.update = aura_box_tramin_update
tt = RT("bomb_tramin_skill1", "bomb_wilbur")
tt.main_script.insert = bomb_tramin_skill1_insert
tt.render.sprites[1].prefix = "hero_tramin_bombot"
tt.render.sprites[1].name = "walk"
tt.render.sprites[1].angles.walk = {"walk"}
tt.custom_attack.aura = "aura_bomb_tramin_skill1"
tt.sound_events.insert = nil
tt.sound_events.remove_stop = nil
