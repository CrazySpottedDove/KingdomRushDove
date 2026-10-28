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
local km = require("lib.klua.macros")
local log = require("lib.klua.log"):new("hero_scripts")
local bor = bit.bor
local find_target_at_critical_moment = HU.find_target_at_critical_moment
local fts = U.fts
local level_up_basic = HU.level_up_basic
local queue_damage = U.queue_damage
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local valid_land_node_nearby = HU.valid_land_node_nearby
local v = V.v
local vv = V.vv
local tt

local function aura_totem_naga_update(this, store)
	local last_hit_ts = 0
	local a = this.aura
	local ring_sid = 1
	local ground_sid = 2
	local totem_sid = 3

	if GR:cell_is(this.pos.x, this.pos.y, TERRAIN_WATER) then
		local fx = E:create_entity("fx")

		fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
		fx.render.sprites[1].name = "totem_water_fx_enter"
		fx.render.sprites[1].anchor.y = 0.09
		fx.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(fx)
	end

	this.render.sprites[ring_sid].ts = store.tick_ts

	U.animation_start(this, "start", nil, store.tick_ts, false, totem_sid)

	while not U.animation_finished(this, totem_sid) do
		coroutine.yield()
	end

	U.animation_start(this, "run", nil, store.tick_ts, true, totem_sid)

	this.aura.ts = store.tick_ts

	while store.tick_ts - this.aura.ts < a.duration do
		local soldiers = U.find_soldiers_in_range(store.soldiers, this.pos, 0, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans)

		if soldiers then
			for _, soldier in ipairs(soldiers) do
				local new_mod = E:create_entity(this.aura.mod)

				new_mod.modifier.level = this.aura.level
				new_mod.modifier.target_id = soldier.id
				new_mod.modifier.source_id = this.id

				simulation:queue_insert_entity(new_mod)
			end
		end

		last_hit_ts = store.tick_ts

		while store.tick_ts - last_hit_ts < this.aura.cycle_time do
			coroutine.yield()
		end
	end

	if GR:cell_is(this.pos.x, this.pos.y, TERRAIN_WATER) then
		local fx = E:create_entity("fx")

		fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
		fx.render.sprites[1].name = "totem_water_fx_exit"
		fx.render.sprites[1].anchor.y = 0.09
		fx.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(fx)
	end

	this.render.sprites[ground_sid].hidden = true
	this.render.sprites[ring_sid].hidden = true

	S:queue("TotemVanish")
	U.animation_start(this, "end", nil, store.tick_ts, false, totem_sid)

	while not U.animation_finished(this, totem_sid) do
		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

local function controller_hero_naga_ultimate_update(this, store)
	local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true, NF_POWER_3)

	if #nodes < 1 then
		log.error("controller_hero_naga_ultimate: could not find valid node")
		simulation:queue_remove_entity(this)

		return
	end

	local pi, _, ni = unpack(nodes[1])
	local pos = P:node_pos(pi, 1, ni)

	this.pos.x, this.pos.y = pos.x, pos.y

	U.animation_start_group(this, "in", nil, store.tick_ts, false, "layers")
	U.y_animation_wait(this)
	U.animation_start_group(this, "run", nil, store.tick_ts, true, "layers")

	local start_ts = store.tick_ts

	S:queue(this.sound_events.insert)

	for t = 1, this.duration * 5 do
		while store.tick_ts < start_ts + 0.2 * t do
			coroutine.yield()
		end

		local targets = U.find_enemies_in_range_filter_off(this.pos, this.damage_radius, this.damage_flags, this.damage_bans)

		if targets then
			for _, e in ipairs(targets) do
				local d = E.assign_damage(this.damage_type, this.damage * this.damage_factor, this.id, e.id)

				queue_damage(store, d)
			end
		end
	end

	U.animation_start_group(this, "out", nil, store.tick_ts, false, "layers")
	U.y_animation_wait(this)
	simulation:queue_remove_entity(this)
end

local function controller_hero_naga_fight_to_win_or_die_update(this, store)
	while true do
		local e = store.entities[this.target_id]

		if e then
			if e.health.hp / e.health.hp_max < this.hp_threshold then
				if not this.enabled then
					this.enabled = true

					SU.insert_unit_damage_factor_by_factor(e, this.damage_factor)
				end
			else
				if this.enabled then
					this.enabled = false

					SU.remove_unit_damage_factor_by_factor(e, this.damage_factor)
				end
			end
		end

		coroutine.yield()
	end
end

local function hero_naga_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local b = E:get_template(this.ranged.attacks[1].bullet)

	b.bullet.damage_min = ls.ranged_damage_min[hl]
	b.bullet.damage_max = ls.ranged_damage_max[hl]

	-- 1技能 潮汐
	upgrade_skill(this, "wave", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.count = s.count[s.level]

		local e = E:get_template(a.hit_aura)

		e.aura.damage_min = s.damage_config[s.level]
		e.aura.damage_max = s.damage_config[s.level]
	end)
	-- 2技能 勇气旗帜
	upgrade_skill(this, "banner_allies", function(this, s)
		local a = this.timed_attacks.list[3]

		a.disabled = nil

		local e = E:get_template(a.entity)

		e.aura.duration = s.duration[s.level]

		local m = E:get_template(e.aura.mod)

		m.hps.heal_min = s.heal[s.level]
		m.hps.heal_max = s.heal[s.level]
	end)
	-- 3技能 那伽之凝视
	upgrade_skill(this, "gaze", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.max_targets = s.max_targets[s.level]

		local e = E:get_template("mod_naga_gaze_slow")

		e.modifier.duration = s.duration[s.level]
	end)
	-- 4技能 水花四溅
	upgrade_skill(this, "splash", function(this, s)
		local a = this.melee.attacks[2]

		a.damage_min = s.damage_config[s.level]
		a.damage_max = s.damage_config[s.level]
		a.disabled = nil
	end)
	-- 大招 深渊恐怖
	upgrade_skill(this, "ultimate", function(this, s)
		this.ultimate.disabled = nil

		local u = E:get_template(s.controller_name)

		u.cooldown = s.cooldown[s.level]
		u.damage = s.damage_config[s.level]
	end)
	update_hp(this)
end

local function hero_naga_update(this, store)
	local h = this.health
	local a, skill, brk, sta
	local gaze_attack = this.timed_attacks.list[1]
	local wave_attack = this.timed_attacks.list[2]
	local totem_attack = this.timed_attacks.list[3]

	gaze_attack.ts = 0
	wave_attack.ts = 0
	totem_attack.ts = 0
	this.melee.attacks[1].ts = 0
	this.ranged.attacks[1].ts = 0

	do
		local e = E:create_entity("controller_hero_naga_fight_to_win_or_die")

		e.target_id = this.id
		this.fight_to_win_or_die_controller_id = e.id

		simulation:queue_insert_entity(e)
	end

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_naga_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			-- 3技能 那伽之凝视
			skill = this.hero.skills.gaze
			a = gaze_attack

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local enemy = U.detect_foremost_enemy_in_range_filter_off(this.pos, a.max_range_trigger, a.vis_flags, a.vis_bans)

				if not enemy then
					a.ts = a.ts + fts(10)
				else
					local start_ts = store.tick_ts
					local af = enemy.pos.x < this.pos.x

					S:queue(a.sound)
					U.animation_start_default(this, a.animation, af, store.tick_ts, false)

					if SU.y_hero_wait(store, this, a.cast_time) then
						goto label_naga_0
					end

					local enemies = U.find_enemies_in_range_filter_off(this.pos, a.max_range_effect, a.vis_flags, a.vis_bans)

					SU.hero_gain_xp_from_skill(this, skill)

					a.ts = start_ts

					if enemies then
						table.sort(enemies, function(a, b)
							if U.enemy_is_silent_target(a) and not U.enemy_is_silent_target(b) then
								return true
							elseif not U.enemy_is_silent_target(a) and U.enemy_is_silent_target(b) then
								return false
							end

							local p1 = a.nav_path
							local p2 = b.nav_path

							return P:nodes_to_goal(p1.pi, p1.spi, p1.ni) < P:nodes_to_goal(p2.pi, p2.spi, p2.ni)
						end)

						for i = 1, #enemies do
							for _, mod in ipairs(a.mods) do
								local m = E:create_entity(mod)

								m.modifier.source_id = this.id
								m.modifier.target_id = enemies[i].id

								simulation:queue_insert_entity(m)
							end

							if i >= a.max_targets then
								break
							end
						end
					end

					if SU.y_hero_animation_wait(this) then
						goto label_naga_0
					end
				end
			end

			-- 1技能 潮汐
			a = wave_attack
			skill = this.hero.skills.wave

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local target_info = U.find_enemies_in_paths(store.enemies, this.pos, a.min_nodes, a.max_nodes, nil, a.vis_flags, a.vis_bans)

				if not target_info or #target_info < a.min_count then
					a.ts = a.ts + 0.2
				else
					local target = target_info[1].enemy

					S:queue(a.sound_pre)

					if not SU.y_soldier_do_single_area_attack(store, this, target, a) then
						goto label_naga_0
					end

					SU.hero_gain_xp_from_skill(this, skill)
				end
			end

			-- 2技能 勇气旗帜
			skill = this.hero.skills.banner_allies
			a = totem_attack

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local soldier = U.is_soldiers_around_need_heal(store.soldiers, this.pos, a.hp_threshold, a.max_range)

				if not soldier then
					a.ts = a.ts + fts(10)
				else
					local start_ts = store.tick_ts
					local af = soldier.pos.x < this.pos.x

					S:queue(a.sound)
					U.animation_start_default(this, a.animation, af, store.tick_ts, false)

					if SU.y_hero_wait(store, this, a.cast_time) then
						goto label_naga_0
					end

					a.ts = start_ts

					SU.hero_gain_xp_from_skill(this, skill)

					local e = E:create_entity(a.entity)
					local nearest_node = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, false)[1]
					local pi, spi, ni = unpack(nearest_node)

					e.pos = P:node_pos(pi, spi, ni)

					simulation:queue_insert_entity(e)

					if SU.y_hero_animation_wait(this) then
						goto label_naga_0
					end
				end
			end

			-- 大招 深渊恐怖
			skill = this.hero.skills.ultimate

			if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
				local enemy = find_target_at_critical_moment(this, this.ultimate.range, F_RANGED, F_NONE, function(e)
					return valid_land_node_nearby(e.pos)
				end, true)

				if enemy and enemy.pos then
					U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
					S:queue(this.sound_events.change_rally_point)

					local e = E:create_entity(this.hero.skills.ultimate.controller_name)

					e.pos = V.vclone(enemy.pos)
					e.level = this.hero.skills.ultimate.level
					e.damage_factor = this.unit.damage_factor

					simulation:queue_insert_entity(e)

					this.ultimate.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, skill)
				else
					this.ultimate.ts = this.ultimate.ts + 1
				end
			end

			brk, sta = SU.y_soldier_ranged_attacks(store, this)

			if brk then
				goto label_naga_0
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
				goto label_naga_0
			end

			if SU.soldier_go_back_step(store, this) then
				goto label_naga_0
			end

			SU.soldier_idle(store, this)
			SU.soldier_regen(store, this)
		end

		::label_naga_0::

		coroutine.yield()
	end
end

local function hero_naga_remove(this, store)
	if this.fight_to_win_or_die_controller_id then
		local e = store.entities[this.fight_to_win_or_die_controller_id]

		if e then
			if e.enabled then
				SU.remove_unit_damage_factor_by_factor(this, e.damage_factor)

				e.enabled = false

				simulation:queue_remove_entity(e)
			end
		end
	end

	return true
end

local function aura_naga_skill1_bomb_update(this, store)
	local a = this.aura

	local function do_attack(pos, last_attack)
		local fx = E:create_entity(a.fx)

		fx.pos.x, fx.pos.y = pos.x, pos.y

		if not last_attack then
			fx.render.sprites[2].scale = V.v(0.8, 0.8)
		end

		fx.render.sprites[2].ts = store.tick_ts
		fx.tween.ts = store.tick_ts

		simulation:queue_insert_entity(fx)

		local radius = last_attack and a.last_attack_damage_radius or a.damage_radius
		local targets = U.find_enemies_in_range_filter_off(pos, radius, a.vis_flags, a.vis_bans)

		if targets then
			S:queue(this.sound)

			for _, t in ipairs(targets) do
				local d = E.assign_damage(a.damage_type, math.random(a.damage_min, a.damage_max) * a.damage_factor, this.id, t.id)

				queue_damage(store, d)

				if (last_attack or math.random() < a.stun_chance) and U.flags_pass(t.vis, this.stun) then
					local m = E:create_entity(this.stun.mod)

					m.modifier.source_id = this.id
					m.modifier.target_id = t.id

					simulation:queue_insert_entity(m)
				end
			end
		end
	end

	local pi, spi, ni, tni, target, origin
	local target_info = U.find_enemies_in_paths(store.enemies, this.pos, a.min_nodes, a.max_nodes, nil, a.vis_flags, a.vis_bans)

	if not target_info or #target_info < a.min_count then
		log.error("aura_naga_skill1_bomb could not find valid enemies in the hero paths")
	else
		target = target_info[1].enemy
		origin = target_info[1].origin
		pi, spi, ni = unpack(origin)
		tni = target.nav_path.ni

		for i = 1, a.steps do
			local nni = ni + i * a.step_nodes * km.sign(tni - ni)
			local oni = ni + i * a.step_nodes * km.sign(tni - ni) * -1

			spi = i == a.steps and 1 or (spi == 2 or spi == 3) and 1 or math.random() < 0.5 and 2 or 3

			U.y_wait(store, a.step_delay)

			local spos = P:node_pos(pi, spi, nni)

			do_attack(spos, i == a.steps)

			if i == 1 then
				local opos = P:node_pos(pi, spi, oni)

				do_attack(opos, false)
			end
		end
	end

	simulation:queue_remove_entity(this)
end

tt = RT("hero_naga", "hero")

AC(tt, "melee", "ranged", "timed_attacks")

tt.melee.range = 60
tt.health_bar.offset = v(0, 53)
tt.health.dead_lifetime = 15
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.tombstone_show_time = fts(90)
tt.info.portrait = "kr4_info_portraits_heroes_0011"
tt.info.hero_portrait = "kr4_hero_portraits_0010"
tt.main_script.update = hero_naga_update
tt.main_script.remove = hero_naga_remove
tt.hero.fn_level_up = hero_naga_level_up
tt.motion.max_speed = 2.7 * FPS
tt.regen.cooldown = 1
tt.soldier.melee_slot_offset = v(5, 0)
tt.sound_events.change_rally_point = "group_naga_taunt"
tt.sound_events.death = "hero_naga_death"
tt.sound_events.hero_room_select = "hero_naga_taunt_1"
tt.sound_events.insert = "HeroPaladinTauntIntro"
tt.sound_events.respawn = "HeroPaladinTauntIntro"
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 20)
-- 1技能 潮汐
tt.hero.skills.wave = CC("hero_skill")
tt.hero.skills.wave.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.wave.xp_gain = {60, 120, 180}
tt.hero.skills.wave.count = {5, 7, 10}
tt.hero.skills.wave.damage_config = {12, 24, 36}
-- 2技能 勇气旗帜
tt.hero.skills.banner_allies = CC("hero_skill")
tt.hero.skills.banner_allies.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.banner_allies.xp_gain = {60, 120, 180}
tt.hero.skills.banner_allies.duration = {3, 5, 7}
tt.hero.skills.banner_allies.heal = {4, 6, 8}
-- 3技能 那伽之凝视
tt.hero.skills.gaze = CC("hero_skill")
tt.hero.skills.gaze.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.gaze.xp_gain = {60, 120, 180}
tt.hero.skills.gaze.duration = {3, 5, 7}
tt.hero.skills.gaze.max_targets = {3, 5, 6}
-- 4技能 水花四溅
tt.hero.skills.splash = CC("hero_skill")
tt.hero.skills.splash.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.hero.skills.splash.xp_gain = {60, 120, 180}
tt.hero.skills.splash.damage_config = {30, 60, 90}
-- 大招 深渊恐怖
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.ultimate.xp_gain = {120, 240, 360, 480}
tt.hero.skills.ultimate.controller_name = "controller_hero_naga_ultimate"
tt.hero.skills.ultimate.cooldown = {32, 32, 32, 32}
tt.hero.skills.ultimate.damage_config = {6, 10, 20, 30}
tt.ultimate = {
	ts = 0,
	cooldown = 32,
	disabled = true,
	range = 180
}
tt.hero.level_stats.armor = {0.03, 0.06, 0.09, 0.12, 0.15, 0.18, 0.21, 0.24, 0.27, 0.30}
tt.hero.level_stats.hp_max = {264, 294, 324, 354, 384, 414, 444, 474, 504, 534}
tt.hero.level_stats.melee_damage_max = {13, 17, 21, 26, 30, 34, 39, 42, 47, 50}
tt.hero.level_stats.melee_damage_min = {10, 12, 15, 18, 20, 23, 25, 28, 31, 34}
tt.hero.level_stats.ranged_damage_max = {26, 34, 42, 52, 60, 68, 78, 84, 94, 100}
tt.hero.level_stats.ranged_damage_min = {20, 24, 30, 36, 40, 46, 50, 56, 62, 68}
tt.render.sprites[1].anchor.y = 0.04
tt.render.sprites[1].offset = v(0, -18)
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_naga"
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].offset = v(0, 31)
tt.render.sprites[2].name = "hero_naga_shadow"
tt.render.sprites[2].z = Z_DECALS + 1
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 2
tt.melee.attacks[2] = CC("area_attack")
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].cooldown = 9
tt.melee.attacks[2].count = 8
tt.melee.attacks[2].damage_inc = 0
tt.melee.attacks[2].damage_max = 30
tt.melee.attacks[2].damage_min = 30
tt.melee.attacks[2].damage_radius = 75
tt.melee.attacks[2].damage_type = DAMAGE_MAGICAL
tt.melee.attacks[2].hit_decal = "decal_hero_naga_area_ring"
tt.melee.attacks[2].hit_fx = "fx_naga_ground_hit"
tt.melee.attacks[2].hit_offset = v(0, 0)
tt.melee.attacks[2].hit_time = fts(14)
tt.melee.attacks[2].pop = {"pop_whaam", "pop_kapow"}
tt.melee.attacks[2].pop_chance = 0.3
tt.melee.attacks[2].sound_hit = "hero_junpai_tridenthit"
tt.melee.attacks[2].xp_from_skill = "splash"
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].cooldown = 2.2
tt.ranged.attacks[1].min_range = 0
tt.ranged.attacks[1].max_range = 175
tt.ranged.attacks[1].bullet = "bullet_naga"
tt.ranged.attacks[1].shoot_time = fts(9)
tt.ranged.attacks[1].bullet_start_offset = {v(-8, 24)}
tt.timed_attacks.list[1] = CC("mod_attack")
tt.timed_attacks.list[1].animation = "silence"
tt.timed_attacks.list[1].cooldown = 22
tt.timed_attacks.list[1].max_range_trigger = 150
tt.timed_attacks.list[1].max_range_effect = 150
tt.timed_attacks.list[1].max_targets = 3
tt.timed_attacks.list[1].mods = {"mod_naga_silence", "mod_naga_gaze_slow"}
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].cast_time = fts(6)
tt.timed_attacks.list[1].xp_from_skill = "gaze"
tt.timed_attacks.list[1].sound = "hero_junpai_tridenthit"
tt.timed_attacks.list[2] = CC("area_attack")
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].cooldown = 18
tt.timed_attacks.list[2].animation = "attackSpecial"
tt.timed_attacks.list[2].count = 5
tt.timed_attacks.list[2].sound_pre = "hero_junpai_karkan_loop_start"
tt.timed_attacks.list[2].sound = nil
tt.timed_attacks.list[2].damage_max = 0
tt.timed_attacks.list[2].damage_min = 0
tt.timed_attacks.list[2].damage_radius = 50
tt.timed_attacks.list[2].damage_type = DAMAGE_TRUE
tt.timed_attacks.list[2].hit_offset = v(0, 0)
tt.timed_attacks.list[2].hit_time = fts(12)
tt.timed_attacks.list[2].hit_aura = "aura_naga_skill1_bomb"
tt.timed_attacks.list[2].min_count = 1
tt.timed_attacks.list[2].min_range = 20
tt.timed_attacks.list[2].max_range = 200
tt.timed_attacks.list[2].min_nodes = 5
tt.timed_attacks.list[2].max_nodes = 20
tt.timed_attacks.list[2].pop = {"pop_kapow", "pop_whaam"}
tt.timed_attacks.list[2].pop_chance = 0.3
tt.timed_attacks.list[2].pop_conds = DR_KILL
tt.timed_attacks.list[2].xp_from_skill = "wave"
tt.timed_attacks.list[3] = CC("aura_attack")
tt.timed_attacks.list[3].animation = "banner"
tt.timed_attacks.list[3].cooldown = 10
tt.timed_attacks.list[3].min_targets = 2
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].xp_from_skill = "splash"
tt.timed_attacks.list[3].entity = "totem_naga"
tt.timed_attacks.list[3].sound = "hero_junpai_banner_impact"
tt.timed_attacks.list[3].cast_time = fts(10)
tt.timed_attacks.list[3].vis_flags = F_RANGED
tt.timed_attacks.list[3].min_range = 0
tt.timed_attacks.list[3].max_range = 150
tt.timed_attacks.list[3].hp_threshold = 0.5
tt = RT("controller_hero_naga_fight_to_win_or_die")

AC(tt, "main_script")

tt.main_script.update = controller_hero_naga_fight_to_win_or_die_update
tt.hp_threshold = 0.8
tt.damage_factor = 1.5
tt.enabled = false
tt = RT("bullet_naga", "arrow")
tt.bullet.hit_distance = 50
tt.bullet.flight_time = fts(9)
tt.bullet.flight_time_factor = fts(1 / 60)
tt.bullet.damage_max = 16
tt.bullet.damage_min = 10
tt.bullet.xp_gain_factor = 2
tt.bullet.miss_decal = "hero_naga_proyectile_miss_0006"
tt.render.sprites[1].name = "hero_naga_proyectile"
tt.render.sprites[1].animated = false
tt.render.sprites[1].flip_x = true
tt = RT("controller_hero_naga_ultimate")

AC(tt, "pos", "main_script", "sound_events", "render")

tt.main_script.update = controller_hero_naga_ultimate_update
tt.damage_radius = 80
tt.damage = 6
tt.duration = 8
tt.cooldown = 32
tt.damage_type = DAMAGE_PHYSICAL
tt.damage_flags = bor(F_AREA)
tt.damage_bans = 0
tt.sound_events.insert = "hero_junpai_ultimate_start"
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].prefix = "hero_naga_kraken_water"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].group = "layers"
tt.render.sprites[1].loop = true
tt.render.sprites[1].offset = v(0, -15)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "hero_naga_kraken_tentacle"
tt.render.sprites[2].name = "in"
tt.render.sprites[2].loop = true
tt.render.sprites[2].group = "layers"
tt.render.sprites[2].flip_x = true
tt.render.sprites[2].scale = v(0.9, 0.9)
tt.render.sprites[2].offset = v(0, 25)
tt.render.sprites[3] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[3].offset = v(40, 10)
tt.render.sprites[3].flip_x = true
tt.render.sprites[4] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[4].offset = v(40, -10)
tt.render.sprites[4].flip_x = true
tt.render.sprites[5] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[5].offset = v(0, -25)
tt.render.sprites[5].flip_x = false
tt.render.sprites[6] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[6].offset = v(-40, -10)
tt.render.sprites[6].flip_x = false
tt.render.sprites[7] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[7].offset = v(-40, 10)
tt.render.sprites[7].flip_x = false
tt = RT("aura_naga_skill1_bomb", "aura")
tt.aura.fx = "decal_naga_spike"
tt.sound = "hero_junpai_karkan_loop"
tt.aura.damage_radius = 45
tt.aura.last_attack_damage_radius = 45
tt.aura.damage_type = DAMAGE_PHYSICAL
tt.aura.vis_flags = bor(F_RANGED)
tt.aura.vis_bans = bor(F_FRIEND)
tt.aura.step_delay = fts(2)
tt.aura.step_nodes = 3
tt.aura.steps = 5
tt.main_script.update = aura_naga_skill1_bomb_update
tt.stun = {}
tt.stun.vis_flags = bor(F_RANGED, F_STUN)
tt.stun.vis_bans = bor(F_BOSS)
tt.stun.mod = "mod_naga_skill1_stun"
tt.aura.damage_min = 10
tt.aura.damage_max = 10
tt.aura.stun_chance = 1
tt.aura.min_nodes = 0
tt.aura.max_nodes = 25
tt.aura.min_count = 1
tt = RT("mod_naga_skill1_stun", "mod_stun")
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt.modifier.vis_bans = bor(F_FLYING, F_BOSS)
tt.modifier.duration = 2
tt = RT("decal_naga_spike", "decal_bomb_crater")
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "hero_naga_tidal_wave_run"
tt.render.sprites[2].hide_after_runs = 1
tt.render.sprites[2].anchor.y = 0.24
tt = RT("mod_naga_gaze_slow", "mod_slow")
tt.modifier.duration = 3
tt.slow.factor = 0.5
tt = RT("mod_naga_silence", "modifier")

AC(tt, "render")

tt.modifier.duration = -1
tt.modifier.use_mod_offset = false
tt.modifier.bans = {"mod_shaman_armor", "mod_shaman_magic_armor", "mod_shaman_priest_heal", "mod_shaman_rage"}
tt.modifier.remove_banned = true
tt.custom_offsets = {}
tt.custom_offsets.default = v(0, 0)
tt.main_script.insert = scripts.mod_silence.insert
tt.main_script.remove = scripts.mod_silence.remove
tt.main_script.update = scripts.mod_track_target.update
tt.render.sprites[1].prefix = "hero_naga_silence_modifier"
tt.render.sprites[1].size_names = {"run", "run", "run"}
tt.render.sprites[1].size_scales = {vv(1), vv(1.3), vv(1.5)}
tt.render.sprites[1].name = "run"
tt.render.sprites[1].loop = true
tt.render.sprites[1].draw_order = 1
tt.render.sprites[1].z = Z_DECALS - 200
tt = RT("totem_naga", "aura")

AC(tt, "render", "tween")

tt.aura.mod = "mod_totem_naga"
tt.aura.cycle_time = 0.3
tt.aura.duration = 4
tt.aura.duration_inc = 0
tt.aura.radius = 87.5
tt.aura.vis_bans = F_ENEMY
tt.aura.vis_flags = F_MOD
tt.render.sprites[1].name = "hero_naga_banner_effect_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].scale = v(0.64, 0.64)
tt.render.sprites[1].hidden = true
tt.render.sprites[1].alpha = 50
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "hero_naga_banner_effect_0001"
tt.render.sprites[2].animated = false
tt.render.sprites[2].hidden = true
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].prefix = "hero_naga_banner_courage"
tt.render.sprites[3].name = "end"
tt.render.sprites[3].loop = true
tt.render.sprites[3].anchor = v(0.5, 0.11)
tt.main_script.update = aura_totem_naga_update
tt.sound_events.insert = "hero_junpai_banner_impact"
tt.tween.remove = false
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {{0, v(0.64, 0.64)}, {fts(15), v(1, 1)}, {fts(30), v(1.6, 1.6)}}
tt.tween.props[1].loop = true
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].keys = {{0, 50}, {fts(10), 255}, {fts(20), 255}, {fts(30), 0}}
tt.tween.props[2].loop = true
tt = RT("mod_totem_naga", "modifier")

AC(tt, "hps", "render")

tt.render.sprites[1].name = "hero_naga_banner_courage_modifier_loop"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].offset = v(0, 20)
tt.excluded_templates = {"hero_naga"}
tt.modifier.duration = 1
tt.modifier.use_mod_offset = false
tt.modifier.bans = {"mod_son_of_mactans_poison", "mod_drider_poison", "mod_dark_spitters", "mod_balrog", "mod_poison_giant_rat"}
tt.modifier.remove_banned = true
tt.hps.heal_min = 3
tt.hps.heal_max = 3
tt.hps.heal_inc = 0
tt.hps.heal_every = 0.2
tt.main_script.insert = scripts.mod_hps.insert
tt.main_script.update = scripts.mod_hps.update
tt = RT("decal_hero_naga_area_ring", "decal_tween")
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {{0, v(0.6, 0.6)}, {0.32, v(2, 2)}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "alpha"
tt.tween.props[2].keys = {{0, 255}, {0.32, 0}}
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "hero_naga_area_ring"
tt.render.sprites[1].z = Z_DECALS
tt = RT("fx_naga_ground_hit", "fx")
tt.render.sprites[1].name = "hero_naga_area_fx_run"
tt.render.sprites[1].scale = v(1, 1)
tt.render.sprites[1].anchor.y = 0.27
