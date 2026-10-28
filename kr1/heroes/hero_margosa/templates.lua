local scripts = require("scripts")
local E = require("entity_db")
local GR = require("grid_db")
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

local function mod_hero_margosa_teleport_remove(this, store)
	local target = store.entities[this.modifier.target_id]

	if target then
		target.health.ignore_damage = false

		SU.stun_dec(target)

		local mod_stun = E:create_entity(this.end_mod)

		mod_stun.modifier.target_id = target.id
		mod_stun.modifier.source_id = this.modifier.source_id

		simulation:queue_insert_entity(mod_stun)
	end

	return true
end

local function shadow_bat_update(this, store)
	local sp = this.render.sprites[1]
	local fm = this.force_motion
	local ca = this.custom_attack
	local dest = V.vclone(this.idle_pos)
	local mytarget
	local chasing
	local seek_ts = 0
	local seek_interval = 0.2
	local hit_range = 6

	this.dead = false

	U.y_animation_play(this, "summon", nil, store.tick_ts, 1)
	U.y_animation_wait(this, 1)

	-- 直线匀速飞向目标（不走弹簧-阻尼，确保实际速度达到 flight_speed_busy）
	local function fly_to(pos, max_speed)
		local dx, dy = V.sub(pos.x, pos.y, this.pos.x, this.pos.y)
		local dist = V.len(dx, dy)

		if dist > 0 then
			local step = math.min(dist, max_speed * store.tick_length)

			this.pos.x, this.pos.y = this.pos.x + dx / dist * step, this.pos.y + dy / dist * step
		end

		fm.a.x, fm.a.y = 0, 0
		fm.v.x, fm.v.y = 0, 0
		sp.flip_x = this.pos.x < pos.x
	end

	sp.offset.y = this.flight_height

	while true do
		this.idle_pos = V.vclone(this.owner.pos)

		if (this.owner.health.dead or this.owner.health.hp == 0) and this.dead == false then
			U.y_animation_play(this, "death", nil, store.tick_ts, 1)
			U.y_animation_wait(this, 1)

			this.dead = true
		end

		if not this.owner.health.dead and this.dead == true then
			U.y_animation_play(this, "summon", nil, store.tick_ts, 1)
			U.y_animation_wait(this, 1)

			this.dead = false
		end

		if not this.dead then
			-- 目标失效：目标死亡，或已离开主人索敌范围，立即放弃换目标
			if mytarget and (mytarget.health.dead or V.dist(this.owner.pos.x, this.owner.pos.y, mytarget.pos.x, mytarget.pos.y) > ca.range) then
				mytarget = nil
			end

			-- 无目标：只在主人周围索敌；空索敌时降低频率（不每帧查询）
			if not mytarget and store.tick_ts - seek_ts >= seek_interval then
				seek_ts = store.tick_ts
				mytarget = U.find_nearest_enemy(store, this.owner.pos, 0, ca.range, ca.vis_flags, ca.vis_bans)
			end

			if mytarget then
				local target = mytarget
				local dist = V.dist(this.pos.x, this.pos.y, target.pos.x, target.pos.y)

				if dist > hit_range then
					if not chasing then
						chasing = true

						U.animation_start_default(this, "idle", nil, store.tick_ts, true)
					end

					fly_to(target.pos, this.flight_speed_busy)
				elseif ready_to_attack(ca, store, this.owner.unit.cooldown_factor) then
					U.animation_start_default(this, "attack", nil, store.tick_ts, true)

					local d = E.assign_damage(ca.damage_type, math.random(ca.damage_min, ca.damage_max) * this.owner.unit.damage_factor, this.id, target.id)

					queue_damage(store, d)

					if target.unit.blood_color ~= BLOOD_NONE then
						local fx = E:create_entity(ca.hit_fx)

						fx.pos:set(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)

						fx.render.sprites[1].ts = store.tick_ts
						fx.render.sprites[1].name = target.unit.blood_color

						simulation:queue_insert_entity(fx)
					end

					ca.ts = store.tick_ts
					chasing = false

					if this.custom_attack.sound_chance > math.random() then
						S:queue(this.custom_attack.sound)
					end
				else
					-- 已贴近目标但冷却未好：跟随目标保持贴近
					fly_to(target.pos, this.flight_speed_busy * 0.4)
				end
			else
				chasing = false

				if V.dist(dest.x, dest.y, this.pos.x, this.pos.y) < 10 then
					U.animation_start_default(this, "idle", nil, store.tick_ts, true)

					dest = U.point_on_ellipse(this.idle_pos, 30, U.frandom(0, 2 * math.pi))
				end

				fly_to(dest, this.flight_speed_idle)
			end
		end

		coroutine.yield()
	end
end

local function hero_margosa_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	-- 1 熟吸蝙蝠
	upgrade_skill(this, "bat_familiar", function(this, s)
		local t = E:get_template(this.crow_entity)

		t.custom_attack.damage_min = s.damage_min_config[s.level]
		t.custom_attack.damage_max = s.damage_max_config[s.level]

		for _, t in pairs(store.entities) do
			if t.template_name == this.crow_entity then
				t.custom_attack.damage_min = s.damage_min_config[s.level]
				t.custom_attack.damage_max = s.damage_max_config[s.level]
			end
		end
	end)
	-- 2 绝望迷雾
	upgrade_skill(this, "myst_form", function(this, s)
		this.timed_attacks.list[1].disabled = nil

		local e = E:get_template("mod_dmg_fog_hero_margosa")

		e.dps.damage_min = s.damage_config[s.level]
		e.dps.damage_max = s.damage_config[s.level]

		local e2 = E:get_template("mod_err_fog_hero_margosa")

		e2.inflicted_damage_factor = s.damage_factor[s.level]
		e2.modifier.level = s.level
	end)
	-- 3 黑暗呼唤
	upgrade_skill(this, "dark_call", function(this, s)
		this.timed_attacks.list[2].disabled = nil

		local e = E:get_template("mod_hero_margosa_stun")

		e.modifier.duration = s.duration[s.level]
	end)
	-- 4 吸血鬼之触
	upgrade_skill(this, "vampiric_touch", function(this, s)
		if not this.is_buffed then
			this.vampiric_touch_rate = s.track_rate[s.level]
		end
	end)
	-- 大招
	upgrade_skill(this, "ultimate", function(this, s)
		this.ultimate.disabled = nil
		this.ultimate.duration = s.duration[s.level]
	end)
	update_hp(this)
end

local function hero_margosa_melee_side_effect(this, store, damage, target)
	local value = U.predict_damage(target, damage)

	if this.is_buffed then
		U.heal_with_overflow(this, value * this.vampiric_touch_rate, 2)
	else
		U.heal(this, value * this.vampiric_touch_rate)
	end
end

local function hero_margosa_update(this, store)
	local h = this.health
	local am = this.timed_attacks.list[1]
	local ad = this.timed_attacks.list[2]
	local ultimate = this.ultimate
	local skill, brk, sta

	local function go_buffed()
		U.heal_with_overflow(this, this.health.hp_max, 2)

		this.melee.attacks[1].cooldown = 0.8
		this.melee.attacks[1].damage_type = DAMAGE_TRUE

		SU.insert_unit_damage_factor_by_factor(this, ultimate.damage_factor)

		this.vampiric_touch_rate = 0.8

		U.speed_mul_self(this, ultimate.speed_factor)

		this.is_buffed = true

		U.y_animation_play(this, "toBeast", nil, store.tick_ts, 1)
		U.y_animation_wait(this, 1)

		this.render.sprites[1].prefix = "hero_lady_margosa_beast"

		U.change_health_bar_offset_run_time(this.health_bar, this.health_bar.offset_buffed.y)
	end

	local function go_normal()
		U.heal(this, this.health.hp_max)

		this.melee.attacks[1].cooldown = 1.2
		this.melee.attacks[1].damage_type = DAMAGE_RUDE

		SU.remove_unit_damage_factor_by_factor(this, ultimate.damage_factor)

		this.vampiric_touch_rate = this.hero.skills.vampiric_touch.track_rate[this.hero.skills.vampiric_touch.level]

		U.speed_div_self(this, ultimate.speed_factor)

		ultimate.ts = ultimate.ts - ultimate.cooldown * (1 - math.max((store.tick_ts - ultimate.ts) / ultimate.duration, 1))
		this.is_buffed = false

		U.y_animation_play(this, "toMargosa", nil, store.tick_ts, 1)
		U.y_animation_wait(this, 1)

		this.render.sprites[1].prefix = "hero_lady_margosa"

		U.change_health_bar_offset_run_time(this.health_bar, this.health_bar.offset_normal.y)
	end

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	do
		local e = E:create_entity(this.crow_entity)

		e.pos = V.vclone(this.pos)
		e.idle_pos = V.v(this.pos.x + 20, this.pos.y + 6)
		e.owner = this

		simulation:queue_insert_entity(e)
	end

	while true do
		if h.dead then
			if not this.is_buffed and ready_to_use_skill(ultimate, store, this.unit.cooldown_factor) then
				h.dead = false

				go_buffed()
			elseif this.is_buffed then
				h.dead = false

				go_normal()
			else
				SU.y_hero_death_and_respawn(store, this)
			end
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				local r = this.nav_rally
				local tw = this.treewalk
				local force_treewalk = false

				for _, p in ipairs(this.nav_grid.waypoints) do
					if GR:cell_is(p.x, p.y, bor(TERRAIN_WATER, TERRAIN_SHALLOW, TERRAIN_NOWALK)) then
						force_treewalk = true

						break
					end
				end

				if (force_treewalk or V.dist(this.pos.x, this.pos.y, r.pos.x, r.pos.y) > tw.min_distance) and not this.is_buffed then
					r.new = false

					U.unblock_target(store, this)
					U.bans_add(this.vis, F_ALL)

					this.health.immune_to = F_ALL

					U.speed_mul_self(this, tw.speed_factor)

					this.unit.marker_hidden = true
					this.health_bar.hidden = true

					S:queue(this.sound_events.change_rally_point)
					U.y_animation_play(this, tw.animations[1], nil, store.tick_ts)
					U.y_animation_wait(this, 1)

					::label_45283_0::

					local dest = r.pos
					local n = this.nav_grid

					while not V.veq(this.pos, dest) do
						local w = table.remove(n.waypoints, 1) or dest

						U.set_destination(this, w)

						local an, af = U.animation_name_facing_point(this, tw.animations[2], this.motion.dest)

						U.animation_start_default(this, an, af, store.tick_ts, true)

						while not this.motion.arrived do
							if r.new then
								r.new = false

								goto label_45283_0
							end

							U.walk(this, store.tick_length)
							coroutine.yield()

							this.motion.speed.x, this.motion.speed.y = 0, 0
						end
					end

					SU.hide_modifiers(store, this, true)
					U.y_animation_play(this, tw.animations[3], nil, store.tick_ts)
					U.y_animation_wait(this, 1)
					SU.show_modifiers(store, this, true)
					U.speed_div_self(this, tw.speed_factor)
					U.bans_remove(this.vis, F_ALL)

					this.health.immune_to = 0
					this.unit.marker_hidden = nil
					this.health_bar.hidden = nil
				elseif SU.y_hero_new_rally(store, this) then
					goto label_4590_1
				end
			end

			if SU.hero_level_up(store, this) and not this.is_buffed then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			-- 2技能 绝望迷雾
			skill = this.hero.skills.myst_form

			if ready_to_use_skill(am, store, this.unit.cooldown_factor) then
				if U.find_first_enemy_in_range_filter_off(this.pos, am.max_range, am.vis_flags, am.vis_bans) then
					local start_ts = store.tick_ts

					if this.is_buffed then
						go_normal()
					end

					U.animation_start(this, am.animation, nil, store.tick_ts, false, 1)
					S:queue(am.sound)

					if SU.y_hero_wait(store, this, am.spawn_time) then
						goto label_4590_1
					end

					am.ts = start_ts

					SU.hero_gain_xp_from_skill(this, skill)

					local inner_fx_radius = 35

					for i = 1, 6 do
						local r = inner_fx_radius
						local pos = U.point_on_ellipse(this.pos, r, 2 * math.pi * (6 - i) / 6)

						if GR:cell_is(pos.x, pos.y, TERRAIN_WATER) or P:valid_node_nearby(pos.x, pos.y, 1) and not GR:cell_is(pos.x, pos.y, TERRAIN_CLIFF) then
							local e = E:create_entity(am.entity)

							e.pos = pos
							e.aura.source_id = this.id
							e.aura.ts = store.tick_ts

							simulation:queue_insert_entity(e)
						end
					end

					if SU.y_hero_animation_wait(this) then
						goto label_4590_1
					end
				else
					am.ts = am.ts + 0.1
				end
			end

			-- 3技能 黑暗呼唤
			skill = this.hero.skills.dark_call

			if ready_to_use_skill(ad, store, this.unit.cooldown_factor) then
				if U.find_first_enemy_between_range_filter_off(this.pos, 150, 9999, ad.vis_flags, ad.vis_bans) then
					local start_ts = store.tick_ts

					if this.is_buffed then
						go_normal()
					end

					U.animation_start_once_specific_no_flip(this, ad.animation, store.tick_ts, 1)

					if SU.y_hero_wait(store, this, ad.cast_time) then
						goto label_4590_1
					end

					local _, targets = U.find_foremost_enemy_between_range_filter_off(this.pos, 150, 9999, nil, ad.vis_flags, ad.vis_bans)
					local count = 0

					if targets then
						for _, target in ipairs(targets) do
							if count >= ad.max_count then
								break
							end

							local expect_pos = U.melee_slot_enemy_position(target, this, count + 1)
							local nearest = P:nearest_nodes(expect_pos.x, expect_pos.y, nil, nil, true)

							if nearest[1] then
								local pi, spi, ni = unpack(nearest[1])
								local nav_path = E:clone_c("nav_path")

								nav_path.pi = pi
								nav_path.spi = spi
								nav_path.ni = ni

								local target_reset_nearest = P:nearest_node_with_nav_path_info(target.pos, nav_path)

								target.nav_path.pi = pi
								target.nav_path.spi = spi
								target.nav_path.ni = target_reset_nearest

								local offset = P:nodes_to_goal(pi, spi, ni) - P:nodes_to_goal(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni)
								local mod_teleport = E:create_entity(ad.mod_teleport)

								mod_teleport.nodes_offset = -offset
								mod_teleport.modifier.target_id = target.id
								mod_teleport.modifier.source_id = this.id

								simulation:queue_insert_entity(mod_teleport)

								count = count + 1
							end
						end
					end

					if count > 0 then
						SU.hero_gain_xp_from_skill(this, skill)

						ad.ts = start_ts
					else
						ad.ts = ad.ts + 4
					end

					if SU.y_hero_animation_wait(this) then
						goto label_4590_1
					end
				else
					ad.ts = ad.ts + 0.1
				end
			end

			-- 大招 野兽形态
			skill = this.hero.skills.ultimate

			if this.is_buffed then
				if store.tick_ts - ultimate.ts >= ultimate.duration then
					go_normal()
				end
			else
				if ready_to_use_skill(ultimate, store, this.unit.cooldown_factor) then
					local t = find_target_at_critical_moment(this, ultimate.range, F_RANGED, F_FLYING, nil, nil, nil)

					if t then
						go_buffed()

						ultimate.ts = store.tick_ts

						SU.hero_gain_xp_from_skill(this, skill)
					else
						ultimate.ts = ultimate.ts + 1
					end
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
			-- block empty
			elseif SU.soldier_go_back_step(store, this) then
			-- block empty
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_4590_1::

		coroutine.yield()
	end
end

tt = RT("hero_margosa", "hero")

AC(tt, "melee", "timed_attacks")

tt.melee.range = 80
tt.regen.cooldown = 1
tt.hero.level_stats.armor = {0.06, 0.07, 0.08, 0.09, 0.10, 0.11, 0.12, 0.13, 0.14, 0.15}
tt.hero.level_stats.hp_max = {300, 324, 348, 372, 396, 420, 444, 468, 492, 516}
tt.hero.level_stats.melee_damage_min = {15, 17, 20, 23, 25, 28, 31, 33, 35, 39}
tt.hero.level_stats.melee_damage_max = {26, 30, 33, 36, 39, 42, 46, 52, 54, 57}
-- 1 熟吸蝙蝠
tt.hero.skills.bat_familiar = CC("hero_skill")
tt.hero.skills.bat_familiar.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.bat_familiar.damage_min_config = {3, 6, 9, 12}
tt.hero.skills.bat_familiar.damage_max_config = {7, 14, 21, 28}
-- 2 绝望迷雾
tt.hero.skills.myst_form = CC("hero_skill")
tt.hero.skills.myst_form.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.myst_form.xp_gain = {150, 300, 450}
tt.hero.skills.myst_form.damage_factor = {0.75, 0.5, 0.25}
tt.hero.skills.myst_form.damage_config = {3, 5, 7}
-- 3 黑暗呼唤
tt.hero.skills.dark_call = CC("hero_skill")
tt.hero.skills.dark_call.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.dark_call.xp_gain = {180, 360, 540}
tt.hero.skills.dark_call.duration = {3, 4.5, 6}
-- 4 吸血鬼之触
tt.hero.skills.vampiric_touch = CC("hero_skill")
tt.hero.skills.vampiric_touch.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.vampiric_touch.track_rate = {0.3, 0.4, 0.5}
-- 大招 野兽形态
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.ultimate.xp_gain = {160, 320, 480, 640}
tt.hero.skills.ultimate.duration = {11, 14, 17, 20}
tt.health.dead_lifetime = 15
tt.health_bar.offset = v(0, 36)
tt.health_bar.offset_normal = v(0, 36)
tt.health_bar.offset_buffed = v(0, 44)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.tombstone_show_time = fts(90)
tt.vampiric_touch_rate = tt.hero.skills.vampiric_touch.track_rate[1]
tt.info.hero_portrait = "kr4_hero_portraits_0006"
tt.info.portrait = "kr4_info_portraits_heroes_0004"
tt.main_script.update = hero_margosa_update
tt.hero.fn_level_up = hero_margosa_level_up
tt.motion.max_speed = 2.2 * FPS
tt.nav_grid.valid_terrains = bor(TERRAIN_LAND, TERRAIN_WATER, TERRAIN_SHALLOW, TERRAIN_NOWALK, TERRAIN_ICE)
tt.render.sprites[1].anchor = v(0.5, 0.04)
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_lady_margosa"
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].offset = v(0, 28)
tt.render.sprites[2].name = "hero_lady_margosa_shadow"
tt.render.sprites[2].z = Z_DECALS + 1
tt.soldier.melee_slot_offset = v(5, 0)
tt.sound_events.change_rally_point = "group_margosa_taunt"
tt.sound_events.death = "hero_margosa_death"
tt.sound_events.hero_room_select = "hero_margosa_taunt_1"
tt.sound_events.insert = "hero_margosa_taunt_1"
tt.sound_events.respawn = "HeroPaladinTauntIntro"
tt.treewalk = {}
tt.treewalk.min_distance = 120
tt.treewalk.speed_factor = 2.5
tt.treewalk.animations = {"toBat", "fly", "toHuman"}
tt.unit.marker_offset = v(0, 8)
tt.unit.mod_offset = v(0, 20)
tt.crow_entity = "bat_reinforcement_special_dark_army"
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].cooldown = 1.2
tt.melee.attacks[1].damage_max = 1
tt.melee.attacks[1].damage_min = 1
tt.melee.attacks[1].damage_type = DAMAGE_RUDE
tt.melee.attacks[1].hit_time = fts(18)
tt.melee.attacks[1].hit_decal = "decal_hero_lady_margosa_beast_attack_effect"
tt.melee.attacks[1].hit_offset = v(1, 16)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 2
tt.melee.attacks[1].side_effect = hero_margosa_melee_side_effect
tt.timed_attacks.list[1] = CC("spawn_attack")
tt.timed_attacks.list[1].animation = "mystForm"
tt.timed_attacks.list[1].cooldown = 20
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].entity = "aura_fog_hero_margosa"
tt.timed_attacks.list[1].sound = "hero_margosa_ancientform"
tt.timed_attacks.list[1].spawn_time = fts(13)
tt.timed_attacks.list[1].vis_flags = F_RANGED
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].max_range = 100
tt.timed_attacks.list[2] = CC("mod_attack")
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].animation = "darkCall"
tt.timed_attacks.list[2].sound = "hero_margosa_darkcall"
tt.timed_attacks.list[2].cooldown = 21
tt.timed_attacks.list[2].cast_time = fts(27)
tt.timed_attacks.list[2].max_count = 3
tt.timed_attacks.list[2].vis_flags = bor(F_TELEPORT, F_STUN)
tt.timed_attacks.list[2].vis_bans = bor(F_BOSS, F_FLYING)
tt.timed_attacks.list[2].mod_teleport = "mod_hero_margosa_teleport"
tt.ultimate = {
	ts = 0,
	cooldown = 40,
	disabled = true,
	range = 150,
	duration = tt.hero.skills.ultimate.duration[1],
	damage_factor = 2.75,
	speed_factor = 1.5
}
tt.vis.bans = bor(tt.vis.bans, F_POISON)
tt = RT("decal_hero_lady_margosa_beast_attack_effect", "fx")
tt.render.sprites[1].name = "hero_lady_margosa_beast_attack_effect_run"
tt = RT("mod_hero_margosa_stun", "mod_stun")
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt.modifier.vis_bans = bor(F_FLYING, F_BOSS)
tt = RT("mod_hero_margosa_teleport", "mod_teleport")
tt.main_script.remove = mod_hero_margosa_teleport_remove
tt.modifier.vis_flags = bor(F_MOD)
tt.modifier.vis_bans = bor(F_BOSS)
tt.modifier.duration = 1
tt.nodes_offset = 0
tt.dest_valid_node = true
tt.max_times_applied = 10
tt.delay_start = fts(3)
tt.hold_time = 0.34
tt.delay_end = fts(3)
tt.fx_start = "hero_lady_margosa_teleport_effect_in"
tt.fx_end = "hero_lady_margosa_teleport_effect_out"
tt.end_mod = "mod_hero_margosa_stun"
tt = RT("hero_lady_margosa_teleport_effect_in", "fx")
tt.render.sprites[1].name = "hero_lady_margosa_teleport_effect_in"
tt = RT("hero_lady_margosa_teleport_effect_out", "fx")
tt.render.sprites[1].name = "hero_lady_margosa_teleport_effect_out"
tt = RT("aura_fog_hero_margosa", "aura")

AC(tt, "render")

tt.render.sprites[1].prefix = "hero_lady_margosa_myst_form_effect"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].scale = v(2, 2)
tt.render.sprites[1].anchor = v(0.5, 0.2)
tt.render.sprites[1].z = Z_DECALS + 1
tt.aura.duration = 8
tt.aura.mods = {"mod_dmg_fog_hero_margosa", "mod_err_fog_hero_margosa", "mod_slow_fog_hero_margosa"}
tt.aura.cycle_time = 0.2
tt.aura.radius = 55
tt.aura.vis_bans = bor(F_FRIEND)
tt.aura.vis_flags = bor(F_MOD, F_AREA)
tt.aura.with_fade = true
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt = RT("mod_err_fog_hero_margosa", "modifier")
tt.modifier.duration = 2
tt.modifier.vis_flags = F_MOD
tt.modifier.type = MOD_TYPE_POISON
tt.inflicted_damage_factor = 0.75
tt.main_script.insert = scripts.mod_damage_factors.insert
tt.main_script.remove = scripts.mod_damage_factors.remove
tt.main_script.update = scripts.mod_track_target.update
tt = RT("mod_slow_fog_hero_margosa", "mod_slow")
tt = RT("mod_dmg_fog_hero_margosa", "modifier")

AC(tt, "dps")

tt.modifier.duration = 2
tt.dps.damage_min = 2
tt.dps.damage_max = 2
tt.dps.damage_type = DAMAGE_TRUE
tt.dps.damage_every = 0.2
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt = RT("bat_reinforcement_special_dark_army", "decal_scripted")

AC(tt, "force_motion", "custom_attack")

tt.flight_height = 50
tt.flight_speed_idle = 100
tt.ramp_dist_idle = 0
tt.flight_speed_busy = 150
tt.ramp_dist_busy = 10
tt.main_script.update = shadow_bat_update
tt.custom_attack.min_range = 10
tt.custom_attack.max_range = 10
tt.custom_attack.range = 165
tt.custom_attack.damage_min = 2
tt.custom_attack.damage_max = 2
tt.custom_attack.hit_fx = "fx_hero_lady_margosa_bat_hit_blood"
tt.custom_attack.cooldown = 0.5
tt.custom_attack.damage_type = DAMAGE_PHYSICAL
tt.custom_attack.vis_flags = F_RANGED
tt.custom_attack.sound_chance = 0
tt.custom_attack.sound = "ShadowArcherCrowAttack"
tt.render.sprites[1].prefix = "hero_lady_margosa_bat"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].draw_order = 2
tt.render.sprites[1].sort_y_offset = -12
tt.render.sprites[1].scale = v(-0.7, 0.7)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt = RT("fx_hero_lady_margosa_bat_hit_blood", "fx")
tt.render.sprites[1].prefix = "hero_lady_margosa_bat_hit_blood"
tt.render.sprites[1].name = "red"
-- ======== hero_mortemis(墨忒弥斯) ========
anchor_x, anchor_y = 0.5, 0.12
image_x, image_y = 92, 110
