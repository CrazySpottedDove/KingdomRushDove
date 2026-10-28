local scripts = require("scripts")
local E = require("entity_db")
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
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local valid_land_node_nearby = HU.valid_land_node_nearby
local tt

local function mod_catha_curse_insert(this, store)
	if math.random() < this.chance and scripts.mod_stun.insert(this, store) then
		return true
	else
		return false
	end
end

local function hero_catha_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local e = E:get_template(this.timed_attacks.list[3].entity)

	e.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	e.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local bt = E:get_template(this.ranged.attacks[1].bullet)

	bt.bullet.damage_min = ls.ranged_damage_min[hl]
	bt.bullet.damage_max = ls.ranged_damage_max[hl]
	bt = E:get_template("knife_soldier_catha")
	bt.bullet.damage_min = ls.ranged_damage_min[hl]
	bt.bullet.damage_max = ls.ranged_damage_max[hl]

	upgrade_skill(this, "soul", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil

		local m = E:get_template(a.mod)

		m.hps.heal_min = s.heal_hp[s.level]
		m.hps.heal_max = s.heal_hp[s.level]
	end)
	upgrade_skill(this, "tale", function(this, s)
		local a = this.timed_attacks.list[3]

		a.disabled = nil
		a.max_count = s.max_count[s.level]

		local e = E:get_template(a.entity)

		e.health.hp_max = s.hp_max[s.level]
	end)
	upgrade_skill(this, "fury", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil

		local b = E:get_template("catha_fury")

		b.bullet.damage_min = s.damage_min[s.level]
		b.bullet.damage_max = s.damage_max[s.level]
	end)
	upgrade_skill(this, "curse", function(this, s)
		local m = E:get_template("mod_catha_curse")

		m.chance = s.chance[s.level]
		m.modifier.duration = s.duration[s.level]
		this.melee.attacks[1].mod = "mod_catha_curse"

		local m = E:get_template("mod_soldier_catha_curse")

		m.chance = s.chance[s.level] * s.chance_factor_tale
		m.modifier.duration = s.duration[s.level]
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		this.ultimate.disabled = nil

		local u = E:get_template("hero_catha_ultimate")

		u.duration = s.duration[s.level]
		u.duration_boss = s.duration_boss[s.level]
		u.range = s.range[s.level]
		this.ultimate.range = s.range[s.level]
	end)
	update_hp(this)
end

local function hero_catha_update(this, store)
	local h = this.health
	local a, skill, brk, sta

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
					goto label_133_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.fury

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local targets = U.find_enemies_between_range_filter_off(this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if not targets then
					a.ts = a.ts + 0.3333333333333333
				else
					S:queue(a.sound)
					U.animation_start_default(this, a.animation, nil, store.tick_ts)

					if U.y_wait_conditional(store, a.shoot_time, function()
						return SU.hero_interrupted(this)
					end) then
					-- block empty
					else
						a.ts = store.tick_ts

						SU.hero_gain_xp_from_skill(this, skill)

						local targets = U.find_enemies_between_range_filter_off(this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

						if targets then
							for i = 1, skill.count[skill.level] do
								local target = table.random(targets)
								local b = E:create_entity(a.bullet)

								b.pos.x, b.pos.y = this.pos.x, this.pos.y
								b.bullet.target_id = target.id
								b.bullet.source_id = this.id
								b.bullet.level = a.level

								simulation:queue_insert_entity(b)
							end
						end

						SU.y_hero_animation_wait(this)

						a.ts = store.tick_ts

						goto label_133_0
					end
				end
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.soul

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local targets = U.find_soldiers_in_range(store.soldiers, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans, function(e)
					return e.health.hp / e.health.hp_max < a.max_hp_factor and not table.contains(a.excluded_templates, e.template_name)
				end)

				if not targets then
					a.ts = a.ts + 0.3333333333333333
				else
					S:queue(a.sound)
					U.animation_start_default(this, a.animation, nil, store.tick_ts)

					if U.y_wait_conditional(store, a.shoot_time, function()
						return SU.hero_interrupted(this)
					end) then
					-- block empty
					else
						a.ts = store.tick_ts

						SU.hero_gain_xp_from_skill(this, skill)

						local targets = U.find_soldiers_in_range(store.soldiers, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans, function(e)
							return not table.contains(a.excluded_templates, e.template_name) and e.health.hp < e.health.hp_max
						end)

						if targets then
							table.sort(targets, function(e1, e2)
								return e1.health.hp < e2.health.hp
							end)

							for i = 1, math.min(#targets, a.max_count) do
								local target = targets[i]
								local m = E:create_entity(a.mod)

								m.modifier.source_id = this.id
								m.modifier.target_id = target.id

								simulation:queue_insert_entity(m)
							end
						end

						local fx = E:create_entity(a.shoot_fx)

						fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
						fx.render.sprites[1].ts = store.tick_ts

						simulation:queue_insert_entity(fx)
						SU.y_hero_animation_wait(this)

						a.ts = store.tick_ts

						goto label_133_0
					end
				end
			end

			a = this.timed_attacks.list[3]
			skill = this.hero.skills.tale

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local targets = U.find_enemies_in_range_filter_off(this.pos, a.max_range, a.vis_flags, a.vis_bans)

				if not targets then
					a.ts = a.ts + 0.3333333333333333
				else
					S:queue(a.sound, a.sound_args)
					U.animation_start_default(this, a.animation, nil, store.tick_ts)

					if U.y_wait_conditional(store, a.spawn_time, function()
						return SU.hero_interrupted(this)
					end) then
					-- block empty
					else
						a.ts = store.tick_ts

						SU.hero_gain_xp_from_skill(this, skill)

						for i = 1, a.max_count do
							local o = a.entity_offsets[i]
							local e = E:create_entity(a.entity)

							e.pos.x, e.pos.y = this.pos.x + o.x, this.pos.y + o.y
							e.nav_rally.center = V.vclone(e.pos)
							e.nav_rally.pos = V.vclone(e.pos)
							e.tween.ts = store.tick_ts
							e.tween.props[1].keys[1][2].x = -o.x
							e.tween.props[1].keys[1][2].y = -o.y
							e.render.sprites[1].flip_x = this.render.sprites[1].flip_x
							e.owner = this

							simulation:queue_insert_entity(e)
						end

						SU.y_hero_animation_wait(this)

						a.ts = store.tick_ts

						goto label_133_0
					end
				end
			end

			if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
				local target = find_target_at_critical_moment(this, this.ranged.attacks[1].max_range, F_RANGED, F_NONE)
				local target_found = false

				if target then
					target = U.find_foremost_enemy_with_max_coverage_in_range_filter_off(this.pos, this.ranged.attacks[1].max_range, 0, bor(F_RANGED, F_MOD), 0, this.ultimate.range)

					if target and target.pos and valid_land_node_nearby(target.pos) then
						target_found = true
					end
				end

				if target_found then
					U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
					S:queue(this.sound_events.change_rally_point)

					local e = E:create_entity(this.hero.skills.ultimate.controller_name)

					e.pos = V.vclone(target.pos)

					simulation:queue_insert_entity(e)

					this.ultimate.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, this.ultimate)
				else
					this.ultimate.ts = this.ultimate.ts + 1
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

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

		::label_133_0::

		coroutine.yield()
	end
end

local function hero_catha_ultimate_update(this, store)
	U.animation_start_default(this, nil, nil, store.tick_ts, false)
	U.y_wait_unconditional(store, this.hit_time)

	local fx = E:create_entity(this.hit_fx)

	fx.pos.x, fx.pos.y = this.pos.x, this.pos.y

	U.animation_start_default(fx, nil, nil, store.tick_ts, false)
	simulation:queue_insert_entity(fx)

	local targets = U.find_enemies_in_range_filter_on(this.pos, this.range, this.vis_flags, this.vis_bans, function(e)
		return U.flag_has(e.vis.flags, F_BOSS) or not U.flag_has(e.vis.bans, F_STUN)
	end)

	if targets then
		for _, target in ipairs(targets) do
			local m = E:create_entity(this.mod)

			m.modifier.source_id = this.id
			m.modifier.target_id = target.id

			if U.flag_has(target.vis.flags, F_BOSS) then
				m.modifier.duration = this.duration_boss
				m.modifier.vis_flags = U.flag_clear(m.modifier.vis_flags, F_STUN)
			else
				m.modifier.duration = this.duration
			end

			simulation:queue_insert_entity(m)
		end
	end

	U.y_animation_wait_default(this)
	simulation:queue_remove_entity(this)
end

tt = RT("hero_catha", "hero")

AC(tt, "melee", "ranged", "timed_attacks")

tt.hero.level_stats.armor = {0, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45}
tt.hero.level_stats.hp_max = {210, 220, 230, 240, 250, 260, 270, 280, 290, 300}
tt.hero.level_stats.melee_damage_max = {8, 9, 10, 12, 13, 14, 16, 17, 18, 20}
tt.hero.level_stats.melee_damage_min = {4, 5, 6, 6, 7, 8, 8, 9, 10, 11}
tt.hero.level_stats.ranged_damage_min = {5, 6, 7, 7, 8, 9, 9, 10, 11, 12}
tt.hero.level_stats.ranged_damage_max = {9, 10, 11, 13, 14, 15, 17, 18, 19, 22}
tt.hero.skills.soul = CC("hero_skill")
tt.hero.skills.soul.xp_gain_factor = 75
tt.hero.skills.soul.heal_hp = {50, 100, 150}
tt.hero.skills.soul.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.tale = CC("hero_skill")
tt.hero.skills.tale.max_count = {2, 3, 4}
tt.hero.skills.tale.hp_max = {40, 70, 100}
tt.hero.skills.tale.xp_gain_factor = 75
tt.hero.skills.tale.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.fury = CC("hero_skill")
tt.hero.skills.fury.count = {2, 3, 4}
tt.hero.skills.fury.damage_min = {20, 25, 30}
tt.hero.skills.fury.damage_max = {30, 40, 50}
tt.hero.skills.fury.xp_gain_factor = 32
tt.hero.skills.fury.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.curse = CC("hero_skill")
tt.hero.skills.curse.chance = {0.2, 0.2, 0.2}
tt.hero.skills.curse.duration = {0.5, 1, 1.5}
tt.hero.skills.curse.chance_factor_tale = 0.5
tt.hero.skills.curse.xp_gain = {0, 0, 0}
tt.hero.skills.curse.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_catha_ultimate"
tt.hero.skills.ultimate.duration = {1.5, 3, 4.5, 6}
tt.hero.skills.ultimate.duration_boss = {0.75, 1.5, 2.25, 3}
tt.hero.skills.ultimate.range = {160, 180, 200, 220}
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.ultimate.xp_gain_factor = 25
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, 45)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_catha_level_up
tt.hero.tombstone_show_time = fts(90)
tt.info.hero_portrait = "kr3_hero_portraits_0003"
tt.info.portrait = "kr3_info_portraits_heroes_0003"
tt.main_script.update = hero_catha_update
tt.motion.max_speed = 3.5 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.37301587301587
tt.render.sprites[1].prefix = "hero_catha"
tt.render.sprites[1].angles.ranged = {"shoot", "shootUp", "shoot"}
tt.render.sprites[1].angles_custom = {
	ranged = {45, 135, 210, 315}
}
tt.render.sprites[1].angles_flip_vertical = {
	ranged = true
}
tt.soldier.melee_slot_offset = vec_2(2, 0)
tt.sound_events.change_rally_point = "ElvesHeroCathaTaunt"
tt.sound_events.death = "ElvesHeroCathaDeath"
tt.sound_events.respawn = "ElvesHeroCathaTauntIntro"
tt.sound_events.insert = "ElvesHeroCathaTauntIntro"
tt.sound_events.hero_room_select = "ElvesHeroCathaTauntSelect"
tt.unit.hit_offset = vec_2(0, 16)
tt.unit.mod_offset = vec_2(0, 22)
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].xp_gain_factor = 4
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.range = 40
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].max_range = 175
tt.ranged.attacks[1].min_range = 20
tt.ranged.attacks[1].cooldown = 0.95
tt.ranged.attacks[1].bullet = "knife_catha"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(9, 27)}
tt.ranged.attacks[1].shoot_time = fts(7)
tt.timed_attacks.list[1] = CC("bullet_attack")
tt.timed_attacks.list[1].animation = "explode"
tt.timed_attacks.list[1].bullet = "catha_fury"
tt.timed_attacks.list[1].cooldown = 9.5
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].max_range = 150
tt.timed_attacks.list[1].min_range = 40
tt.timed_attacks.list[1].shoot_time = fts(13)
tt.timed_attacks.list[1].sound = "ElvesHeroCathaFurySummon"
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING, F_CLIFF, F_WATER)
tt.timed_attacks.list[2] = CC("mod_attack")
tt.timed_attacks.list[2].animation = "cloudSpell"
tt.timed_attacks.list[2].mod = "mod_catha_soul"
tt.timed_attacks.list[2].cooldown = 11.4
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].max_range = 100
tt.timed_attacks.list[2].max_count = 6
tt.timed_attacks.list[2].vis_flags = bor(F_FRIEND)
tt.timed_attacks.list[2].sound = "ElvesHeroCathaSoul"
tt.timed_attacks.list[2].shoot_time = fts(30)
tt.timed_attacks.list[2].shoot_fx = "fx_catha_soul"
tt.timed_attacks.list[2].excluded_templates = {"soldier_xin_shadow", "soldier_xin_ultimate"}
tt.timed_attacks.list[2].max_hp_factor = 0.7
tt.timed_attacks.list[3] = CC("spawn_attack")
tt.timed_attacks.list[3].animation = "cloneSpell"
tt.timed_attacks.list[3].cooldown = 15.2
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].entity = "soldier_catha"
tt.timed_attacks.list[3].entity_offsets = {vec_2(30, 30), vec_2(-30, -30), vec_2(30, -30), vec_2(-30, 30)}
tt.timed_attacks.list[3].max_range = 150
tt.timed_attacks.list[3].min_range = 20
tt.timed_attacks.list[3].sound = "ElvesHeroCathaTaleSummon"
tt.timed_attacks.list[3].sound_args = {
	delay = fts(15)
}
tt.timed_attacks.list[3].spawn_time = fts(26)
tt.timed_attacks.list[3].vis_flags = F_RANGED
tt.ultimate = {
	ts = 0,
	cooldown = 20,
	disabled = true,
	range = 80
}
tt = RT("hero_catha_ultimate")

AC(tt, "pos", "main_script", "sound_events", "render")

tt.cooldown = 20
tt.range = 80
tt.duration = 0
tt.duration_boss = 0
tt.mod = "mod_catha_ultimate"
tt.hit_fx = "fx_catha_ultimate"
tt.main_script.update = hero_catha_ultimate_update
tt.sound_events.insert = "ElvesHeroCathaDust"
tt.vis_flags = bor(F_RANGED, F_MOD)
tt.vis_bans = 0
tt.render.sprites[1].name = "hero_catha_ultimate"
tt.render.sprites[1].anchor.y = 0.373
tt.hit_time = fts(22)
tt = RT("knife_catha", "arrow")
tt.render.sprites[1].name = "catha_hero_proy_0001"
tt.bullet.flight_time = fts(9)
tt.bullet.hit_fx = "fx_knife_catha_hit"
tt.bullet.miss_decal = nil
tt.bullet.mod = "mod_catha_curse"
tt.bullet.xp_gain_factor = 4
tt = RT("soldier_catha", "soldier_militia")

AC(tt, "reinforcement", "ranged", "tween")

tt.health.hp_max = nil
tt.health_bar.offset = vec_2(0, 45)
tt.info.portrait = "kr3_info_portraits_soldiers_0010"
tt.info.random_name_count = nil
tt.info.random_name_format = nil
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.soldier_reinforcement.update
tt.melee.attacks[1].damage_max = 7
tt.melee.attacks[1].damage_min = 3
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 90
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].max_range = 175
tt.ranged.attacks[1].min_range = 20
tt.ranged.attacks[1].cooldown = 1
tt.ranged.attacks[1].bullet = "knife_soldier_catha"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(9, 27)}
tt.ranged.attacks[1].shoot_time = fts(7)
tt.regen.health = 10
tt.reinforcement.duration = 10
tt.reinforcement.fade = nil
tt.render.sprites[1].anchor.y = 0.373
tt.render.sprites[1].prefix = "soldier_catha"
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].angles.ranged = {"shoot", "shootUp", "shoot"}
tt.render.sprites[1].angles_custom = {
	ranged = {45, 135, 210, 315}
}
tt.render.sprites[1].angles_flip_vertical = {
	ranged = true
}
tt.soldier.melee_slot_offset = vec_2(3, 0)
tt.sound_events.death = "ElvesHeroCathaTaleDeath"
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {{0, vec_2(0, 0)}, {fts(6), vec_2(0, 0)}}
tt.tween.remove = false
tt.tween.run_once = true
tt.ui.click_rect = r(-10, 0, 20, 30)
tt.unit.hit_offset = vec_2(0, 16)
tt.unit.mod_offset = vec_2(0, 22)
tt.unit.hide_after_death = true
tt = RT("fx_catha_ultimate", "fx")
tt.render.sprites[1].name = "fx_catha_soul"
tt.render.sprites[1].anchor.y = 0.373015873015873
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "fx_catha_ultimate"
tt.render.sprites[2].z = Z_DECALS
tt = RT("fx_catha_soul", "fx")
tt.render.sprites[1].name = "fx_catha_soul"
tt.render.sprites[1].anchor.y = 0.373015873015873
tt = RT("fx_knife_catha_hit", "fx")
tt.render.sprites[1].name = "fx_knife_catha_hit"
tt = RT("catha_fury", "bullet")
tt.animations = {
	loop = "dashLoop",
	start = "dashStart",
	attack = "dashHit"
}
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.max_speed = 240
tt.bullet.min_speed = 210
tt.bullet.mod = "mod_catha_curse"
tt.lead_time = fts(12)
tt.main_script.insert = scripts.bullet_illusion.insert
tt.main_script.update = scripts.bullet_illusion.update
tt.render.sprites[1].anchor.y = 0.373015873015873
tt.render.sprites[1].name = "dashStart"
tt.render.sprites[1].prefix = "hero_catha"
tt.render.sprites[1].z = Z_OBJECTS
tt.sound_events.hit = "ElvesHeroCathaFuryHit"
tt = RT("knife_soldier_catha", "knife_catha")
tt.bullet.xp_gain_factor = nil
tt.bullet.mod = "mod_soldier_catha_curse"
tt = RT("mod_catha_curse", "mod_stun")
tt.main_script.insert = mod_catha_curse_insert
tt.modifier.vis_bans = bor(F_BOSS)
tt.modifier.vis_flags = bor(F_STUN, F_MOD)
tt.modifier.duration = nil
tt.modifier.resets_same = false
tt.render.sprites[1].keep_flip_x = true
tt.render.sprites[1].size_names = nil
tt.render.sprites[1].prefix = "mod_catha_curse"
tt.render.sprites[1].name = "loop"
tt.chance = 0
tt.xp_from_skill = "curse"
tt = RT("mod_soldier_catha_curse", "mod_catha_curse")
tt.xp_from_skill = nil
tt = RT("mod_catha_ultimate", "mod_catha_curse")
tt.main_script.insert = scripts.mod_stun.insert
tt.modifier.vis_bans = 0
tt.xp_from_skill = nil
tt = RT("mod_catha_soul", "modifier")

AC(tt, "render", "hps")

tt.hps.heal_every = 9e+99
tt.hps.heal_max = nil
tt.hps.heal_min = nil
tt.main_script.insert = scripts.mod_hps.insert
tt.main_script.update = scripts.mod_hps.update
tt.modifier.duration = fts(25)
tt.modifier.bans = {"mod_son_of_mactans_poison", "mod_drider_poison", "mod_dark_spitters", "mod_balrog"}
tt.modifier.remove_banned = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "mod_catha_soul"
tt.render.sprites[1].anchor.y = 0.2631578947368421
