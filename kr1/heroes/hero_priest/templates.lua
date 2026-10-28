local bit = require("bit")
local E = require("entity_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")
local scripts = require("scripts")
local signal = require("lib.hump.signal")

require("lib.klua.table")
require("all.constants")

local band = bit.band
local bor = bit.bor
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local ready_to_use_skill = HU.ready_to_use_skill
local ready_to_attack = U.ready_to_attack
local update_regen = HU.update_regen
local inc_armor_by_skill = HU.inc_armor_by_skill
local update_hp = HU.update_hp

local function mod_priest_armor_insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead then
		return false
	end

	if band(this.modifier.vis_flags, target.vis.bans) ~= 0 or band(this.modifier.vis_bans, target.vis.flags) ~= 0 then
		return false
	end

	local rate = this.armor_rate

	local function calc_inc(is_magic)
		if is_magic then
			return rate * (1 - target.health.magic_armor)
		else
			return rate * (1 - target.health.armor)
		end
	end

	this.armor_inc = calc_inc(false)
	this.magic_armor_inc = calc_inc(true)

	SU.armor_inc(target, this.armor_inc)
	SU.magic_armor_inc(target, this.magic_armor_inc)
	SU.insert_unit_damage_factor_buff(target, this.damage_rate)
	SU.insert_unit_cooldown_buff(store.tick_ts, target, this.cooldown_rate)
	signal.emit("mod-applied", this, target)

	return true
end

local function mod_priest_armor_remove(this, store)
	local target = store.entities[this.modifier.target_id]

	if target then
		SU.armor_dec(target, this.armor_inc)
		SU.magic_armor_dec(target, this.magic_armor_inc)
		SU.remove_unit_damage_factor_buff(target, this.damage_rate)
		SU.remove_unit_cooldown_buff(store.tick_ts, target, this.cooldown_rate)
	end

	return true
end

local function mod_priest_armor_update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target then
		simulation:queue_remove_entity(this)

		return
	end

	this.pos = target.pos

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead or store.tick_ts - m.ts >= m.duration then
			simulation:queue_remove_entity(this)

			return
		end

		if this.render and m.use_mod_offset and target.unit.mod_offset then
			this.render.sprites[1].offset.x, this.render.sprites[1].offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
		end

		coroutine.yield()
	end
end

local function hero_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local b = E:get_template("bolt_priest")

	b.bullet.damage_max = ls.ranged_damage_max[hl]
	b.bullet.damage_min = ls.ranged_damage_min[hl]

	upgrade_skill(this, "holylight", function(this, s)
		local a = this.timed_attacks.list[1]

		a.max_per_cast = s.heal_count[s.level]
		a.revive_chance = s.revive_chance[s.level]

		local m = E:get_template(a.mod)

		m.hps.heal_min = s.heal_hp[s.level]
		m.hps.heal_max = s.heal_hp[s.level]
	end)
	upgrade_skill(this, "consecrate", function(this, s)
		this.timed_attacks.list[2].disabled = nil

		local m = E:get_template("mod_priest_consecrate")

		m.modifier.duration = s.duration[s.level]
		m.extra_damage = s.extra_damage[s.level]
	end)
	upgrade_skill(this, "wingsoflight", function(this, s)
		this.teleport.disabled = nil

		local m = E:get_template("mod_priest_armor")

		m.modifier.duration = s.duration[s.level]
		m.armor_rate = s.armor_rate[s.level]
		m.damage_rate = s.damage_rate[s.level]
	end)
	upgrade_skill(this, "blessedarmor", function(this, s)
		this.blessedarmor_extra = s.armor[s.level]
	end)
	upgrade_skill(this, "divinehealth", function(this, s)
		this.divinehealth_extra_hp = s.extra_hp[s.level]
		this.divinehealth_regen_factor = s.regen_factor[s.level]
	end)

	this.health.hp_max = this.health.hp_max + this.divinehealth_extra_hp

	update_regen(this)
	inc_armor_by_skill(this, this.blessedarmor_extra)
	update_hp(this)
end

local function hero_update(this, store)
	local h = this.health
	local a, skill, brk

	local function do_armor_buff(pos, out)
		local skill = this.hero.skills.wingsoflight
		local targets = U.find_soldiers_in_range(store.soldiers, pos, 0, skill.range, 0, 0)

		if targets then
			local count = math.min(#targets, skill.count[skill.level])

			for i = 1, count do
				local target = targets[i]
				local m = E:create_entity("mod_priest_armor")

				m.modifier.target_id = target.id
				m.render.sprites[1].ts = store.tick_ts
				m.render.sprites[2].ts = store.tick_ts
				m.render.sprites[2].offset.y = target.health_bar.offset.y + 7

				simulation:queue_insert_entity(m)
			end
		end

		local fx = E:create_entity("fx_priest_wave_" .. (out and "out" or "in"))

		fx.pos:copy(pos)

		fx.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(fx)
	end

	U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				this.nav_rally.new = false

				U.unblock_target(store, this)
				S:queue(this.sound_events.change_rally_point)

				if SU.hero_will_teleport(this, this.nav_rally.pos) then
					U.bans_add(this.vis, F_ALL)

					this.health_bar.hidden = true
					this.health.ignore_damage = true

					local tp = this.teleport

					S:queue(tp.sound)
					do_armor_buff(this.pos, true)
					U.y_animation_play(this, tp.animations[1], nil, store.tick_ts)

					this.pos.x, this.pos.y = this.nav_rally.pos.x, this.nav_rally.pos.y

					U.set_destination(this, this.pos)
					do_armor_buff(this.pos, false)
					U.y_animation_play(this, tp.animations[2], nil, store.tick_ts)

					this.health.ignore_damage = false
					this.health_bar.hidden = nil

					U.bans_remove(this.vis, F_ALL)

					goto label_365_0
				else
					U.bans_add(this.vis, F_ALL)

					local out = SU.y_hero_walk_waypoints(store, this)

					U.animation_start_default(this, "idle", nil, store.tick_ts, true)
					U.bans_remove(this.vis, F_ALL)

					if out == true then
						goto label_365_0
					end
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.holylight

			if ready_to_attack(a, store) then
				local targets = table.filter(store.soldiers, function(k, v)
					return v.health.hp < 0.7 * v.health.hp_max and U.is_inside_ellipse(v.pos, this.pos, a.range)
				end)

				if #targets < 1 then
					a.ts = a.ts + 0.13333333333333333
				else
					local dead_targets = table.filter(targets, function(k, v)
						return v.health and v.health.dead
					end)
					local could_revive = false

					for _, t in ipairs(dead_targets) do
						if not t.reinforcement and not U.is_wraith(t.template_name) then
							could_revive = true

							break
						end
					end

					if #dead_targets == #targets and not could_revive then
						a.ts = a.ts + 0.13333333333333333
					else
						could_revive = false

						table.sort(targets, function(e1, e2)
							if e1.health.dead and e2.health.dead then
								return false
							elseif e1.health.dead then
								return true
							elseif e2.health.dead then
								return false
							else
								return e1.health.hp_max - e1.health.hp > e2.health.hp_max - e2.health.hp
							end
						end)

						if skill.level == 0 then
							SU.hero_gain_xp(this, 7, "holylight level 0")
						else
							SU.hero_gain_xp_from_skill(this, skill)
						end

						S:queue(a.sound)
						U.animation_start_default(this, a.animation, nil, store.tick_ts)
						U.y_wait_unconditional(store, a.shoot_time)

						local count = 0

						for _, s in ipairs(targets) do
							-- 复活
							if s.health.dead and not s.unit.hide_during_death and (math.random() < a.revive_chance) and not s.reinforcement and not s.hero and not U.is_wraith(s.template_name) then
								U.soldier_revive(s)

								local fx = E:create_entity("fx_priest_revive")

								fx.pos:copy(s.pos)

								fx.render.sprites[1].ts = store.tick_ts

								simulation:queue_insert_entity(fx)

								count = count + 1
							-- 治疗
							elseif not s.health.dead then
								local m = E:create_entity(a.mod)

								m.modifier.target_id = s.id
								m.modifier.source_id = this.id

								simulation:queue_insert_entity(m)

								count = count + 1
							end

							if count >= a.max_per_cast then
								break
							end
						end

						a.ts = store.tick_ts

						U.y_animation_wait_default(this)

						goto label_365_0
					end
				end
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.consecrate

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local towers = table.filter(store.towers, function(_, e)
					return e.tower and e.tower.can_be_mod and not e.tower.blocked and V.dist(e.pos.x, e.pos.y, this.pos.x, this.pos.y) < a.range
				end)

				if #towers < 1 then
					a.ts = a.ts + 0.13333333333333333
				else
					a.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, skill)
					S:queue(a.sound)
					U.animation_start_default(this, a.animation, nil, store.tick_ts)
					U.y_wait_unconditional(store, a.shoot_time)

					local buffed_tower_ids = {}

					for _, e in pairs(store.modifiers) do
						if e.template_name == "mod_priest_consecrate" then
							table.insert(buffed_tower_ids, e.modifier.target_id)
						end
					end

					local towers = table.filter(store.towers, function(_, e)
						return e.tower.can_be_mod and not e.tower.blocked and V.dist(e.pos.x, e.pos.y, this.pos.x, this.pos.y) < a.range
					end)

					table.sort(towers, function(e1, e2)
						return V.dist2(e1.pos.x, e1.pos.y, this.pos.x, this.pos.y) < V.dist2(e2.pos.x, e2.pos.y, this.pos.x, this.pos.y)
					end)

					local buffed_tower, unbuffed_tower

					for _, t in pairs(towers) do
						if not buffed_tower and table.contains(buffed_tower_ids, t.id) then
							buffed_tower = t
						else
							unbuffed_tower = unbuffed_tower or t
						end
					end

					local tower = unbuffed_tower or buffed_tower

					if tower then
						local m = E:create_entity("mod_priest_consecrate")

						m.modifier.target_id = tower.id

						simulation:queue_insert_entity(m)
					end

					U.y_animation_wait_default(this)

					goto label_365_0
				end
			end

			if this.soldier.target_id then
				brk = SU.y_soldier_ranged_attacks(store, this)

				if brk then
					goto label_365_0
				end
			end

			brk = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or U.is_blocked_valid(store, this) then
				goto label_365_0
			end

			brk = SU.y_soldier_ranged_attacks(store, this)

			if brk then
				goto label_365_0
			end

			if SU.soldier_go_back_step(store, this) then
				goto label_365_0
			end

			SU.soldier_idle(store, this)
			SU.soldier_regen(store, this)
		end

		::label_365_0::

		coroutine.yield()
	end
end

local tt

tt = RT("hero_priest", "hero")

AC(tt, "melee", "ranged", "teleport", "timed_attacks")

tt.hero.level_stats.hp_max = {180, 200, 220, 240, 260, 280, 300, 320, 340, 360}
tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.melee_damage_min = {4, 5, 6, 7, 8, 9, 10, 11, 12, 13}
tt.hero.level_stats.melee_damage_max = {12, 14, 17, 19, 21, 23, 26, 28, 30, 33}
tt.hero.level_stats.ranged_damage_min = {4, 5, 6, 7, 8, 9, 10, 11, 12, 13}
tt.hero.level_stats.ranged_damage_max = {12, 14, 17, 19, 21, 23, 26, 28, 30, 33}
tt.hero.skills.holylight = CC("hero_skill")
tt.hero.skills.holylight.heal_hp = {40, 60, 80}
tt.hero.skills.holylight.heal_count = {4, 7, 10}
tt.hero.skills.holylight.revive_chance = {0.15, 0.25, 0.35}
tt.hero.skills.holylight.xp_gain_factor = 50
tt.hero.skills.holylight.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.consecrate = CC("hero_skill")
tt.hero.skills.consecrate.duration = {8, 15, 22}
tt.hero.skills.consecrate.extra_damage = {0.18, 0.24, 0.3}
tt.hero.skills.consecrate.xp_gain_factor = 50
tt.hero.skills.consecrate.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.wingsoflight = CC("hero_skill")
tt.hero.skills.wingsoflight.range = 120
tt.hero.skills.wingsoflight.duration = {10, 20, 30}
tt.hero.skills.wingsoflight.armor_rate = {0.2, 0.3, 0.4}
tt.hero.skills.wingsoflight.damage_rate = {0.15, 0.25, 0.35}
tt.hero.skills.wingsoflight.count = {9, 12, 15}
tt.hero.skills.wingsoflight.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.blessedarmor = CC("hero_skill")
tt.hero.skills.blessedarmor.armor = {0.25, 0.5, 0.75}
tt.hero.skills.blessedarmor.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.divinehealth = CC("hero_skill")
tt.hero.skills.divinehealth.extra_hp = {60, 120, 180}
tt.hero.skills.divinehealth.regen_factor = {1.1, 1.3, 1.5}
tt.hero.skills.divinehealth.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.health.armor = nil
tt.health.dead_lifetime = 15
tt.health.hp_max = nil
tt.health_bar.offset = vec_2(0, 37)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_level_up
tt.hero.tombstone_show_time = fts(60)
tt.idle_flip.cooldown = 1
tt.info.hero_portrait = "kr2_hero_portraits_0007"
tt.info.portrait = "kr2_info_portraits_heroes_0007"
tt.main_script.update = hero_update
tt.motion.max_speed = 90
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.18
tt.render.sprites[1].prefix = "hero_priest"
tt.soldier.melee_slot_offset.x = 5
tt.sound_events.change_rally_point = "HeroPriestTaunt"
tt.sound_events.death = "HeroPriestDeath"
tt.sound_events.respawn = "HeroPriestTauntIntro"
tt.sound_events.insert = "HeroPriestTauntIntro"
tt.sound_events.hero_room_select = "HeroPriestTauntSelect"
tt.teleport.min_distance = 51.2
tt.teleport.sound = "HeroPriestWings"
tt.teleport.disabled = true
tt.unit.marker_offset = vec_2(0, -1)
tt.unit.mod_offset = vec_2(0, 13.88)
tt.melee.range = 51.2
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 4
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].bullet = "bolt_priest"
tt.ranged.attacks[1].cooldown = 0.8 + fts(13)
tt.ranged.attacks[1].min_range = 25
tt.ranged.attacks[1].max_range = 160
tt.ranged.attacks[1].shoot_time = fts(13)
tt.ranged.attacks[1].bullet_start_offset = {vec_2(-8, 34)}
tt.ranged.attacks[1].check_target_before_shot = true
tt.timed_attacks.list[1] = CC("mod_attack")
tt.timed_attacks.list[1].animation = "holylight"
tt.timed_attacks.list[1].cooldown = 6
tt.timed_attacks.list[1].max_per_cast = 1
tt.timed_attacks.list[1].mod = "mod_priest_heal"
tt.timed_attacks.list[1].revive_chance = 0
tt.timed_attacks.list[1].range = 160
tt.timed_attacks.list[1].shoot_time = fts(4)
tt.timed_attacks.list[1].sound = "HeroPriestHolyLight"
tt.timed_attacks.list[2] = CC("mod_attack")
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].animation = "consecrate"
tt.timed_attacks.list[2].cooldown = 8
tt.timed_attacks.list[2].mod = "mod_priest_consecrate"
tt.timed_attacks.list[2].range = 160
tt.timed_attacks.list[2].shoot_time = fts(15)
tt.timed_attacks.list[2].sound = "HeroPriestConsecrate"
tt.blessedarmor_extra = 0
tt.divinehealth_extra_hp = 0
tt.divinehealth_regen_factor = 0
tt = RT("bolt_priest", "bolt")
tt.bullet.xp_gain_factor = 4
tt.render.sprites[1].prefix = "bolt_priest"
tt.bullet.damage_min = nil
tt.bullet.damage_max = nil
tt = RT("mod_priest_heal", "modifier")

AC(tt, "hps", "render")

tt.modifier.duration = fts(24)
tt.modifier.remove_banned = true
tt.modifier.ban_types = {MOD_TYPE_POISON, MOD_TYPE_STUN, MOD_TYPE_BLEED}
tt.hps.heal_min = 25
tt.hps.heal_max = 25
tt.hps.heal_every = 9e+99
tt.render.sprites[1].name = "fx_priest_heal"
tt.render.sprites[1].loop = false
tt.main_script.insert = scripts.mod_hps.insert
tt.main_script.update = scripts.mod_hps.update
tt = RT("fx_priest_revive", "fx")
tt.render.sprites[1].name = "fx_priest_revive"
tt.render.sprites[1].anchor.y = 0.15
tt = RT("fx_priest_wave_out", "decal_tween")
tt.render.sprites[1].name = "hero_priest_healWave"
tt.render.sprites[1].animated = false
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {{0, vec_2(2.4, 2.4)}, {0.32, vec_2(1, 1)}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].keys = {{0, 255}, {0.32, 0}}
tt = RT("fx_priest_wave_in", "fx_priest_wave_out")
tt.tween.props[1].keys = {{0, vec_2(1, 1)}, {0.32, vec_2(2.4, 2.4)}}
tt = RT("mod_priest_armor", "modifier")

AC(tt, "render", "armor_buff")

tt.modifier.use_mod_offset = false
tt.armor_rate = 0.3
tt.damage_rate = 0.1
tt.cooldown_rate = 0.9
tt.main_script.insert = mod_priest_armor_insert
tt.main_script.remove = mod_priest_armor_remove
tt.main_script.update = mod_priest_armor_update
tt.render.sprites[1].name = "decal_priest_armor"
tt.render.sprites[1].anchor = vec_2(0.51, 0.17307692307692307)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "fx_priest_armor"
tt.render.sprites[2].anchor.x = 0.51
tt.render.sprites[2].loop = false
tt.render.sprites[2].hide_after_runs = 1
tt = RT("mod_priest_consecrate", "modifier")

AC(tt, "render", "tween")

tt.render.sprites[1].name = "decal_priest_consecrate"
tt.render.sprites[1].draw_order = 2
tt.render.sprites[1].anchor.y = 0.32
tt.render.sprites[1].offset.y = 7
tt.main_script.update = scripts.mod_priest_consecrate.update
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}
