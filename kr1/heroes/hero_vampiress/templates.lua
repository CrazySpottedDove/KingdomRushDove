local bit = require("bit")
local E = require("entity_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")
local scripts = require("scripts")

require("all.constants")

local bor = bit.bor
local v = V.v
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local update_regen = HU.update_regen
local inc_armor_by_skill = HU.inc_armor_by_skill
local inc_magic_armor_by_skill = HU.inc_magic_armor_by_skill
local update_hp = HU.update_hp
local queue_damage = U.queue_damage

local function mod_vampiress_gain_update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	this.pos = target.pos
	target.gain_count = 0

	local max_gain_count = this.max_gain_count

	while true do
		local has_kills = false

		for _, kid in pairs(target.track_kills.killed) do
			if target.gain_count < max_gain_count then
				target.health.hp_max = target.health.hp_max + this.gain.hp
				target.melee.attacks[1].damage_min = target.melee.attacks[1].damage_min + this.gain.damage
				target.melee.attacks[1].damage_max = target.melee.attacks[1].damage_max + this.gain.damage
				target.health.armor = target.health.armor + this.gain.armor
				target.health.magic_armor = target.health.magic_armor + this.gain.magic_armor

				if not target.render.sprites[1].scale then
					target.render.sprites[1].scale = v(1 + this.gain.size, 1 + this.gain.size)
				else
					target.render.sprites[1].scale.x = target.render.sprites[1].scale.x + this.gain.size
					target.render.sprites[1].scale.y = target.render.sprites[1].scale.y + this.gain.size
				end

				target.melee.attacks[2].cooldown = target.melee.attacks[2].cooldown - this.gain.cooldown
				target.timed_attacks.list[1].cooldown = target.timed_attacks.list[1].cooldown - this.gain.cooldown
				target.timed_attacks.list[1].damage_radius = target.timed_attacks.list[1].damage_radius + this.gain.radius
				target.motion.max_speed_bat = target.motion.max_speed_bat + this.gain.speed

				U.speed_inc_self(target, this.gain.speed)

				target.gain_count = target.gain_count + 1
			end

			U.heal(target, this.gain.heal)

			has_kills = true
		end

		if has_kills then
			target.track_kills.killed = {}
		end

		coroutine.yield()
	end
end

local function hero_level_up(this, store)
	local hl, ls = level_up_basic(this)

	upgrade_skill(this, "vampirism", function(this, s)
		local a = this.melee.attacks[2]

		a.disabled = nil
		a.damage_min = s.damage[s.level]
		a.damage_max = s.damage[s.level]

		local m = E:get_template("mod_vampiress_lifesteal")

		m.heal_hp = s.damage[s.level]
	end)
	upgrade_skill(this, "slayer", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.damage_min = s.damage_min[s.level]
		a.damage_max = s.damage_max[s.level]
	end)

	local gain = E:get_template("mod_vampiress_gain").gain

	this.health.hp_max = this.health.hp_max + this.gain_count * gain.hp

	update_regen(this)
	inc_armor_by_skill(this, this.gain_count * gain.armor)
	inc_magic_armor_by_skill(this, this.gain_count * gain.magic_armor)

	local a = this.melee.attacks[1]

	a.damage_min = ls.melee_damage_min[hl] + this.gain_count * gain.damage
	a.damage_max = ls.melee_damage_max[hl] + this.gain_count * gain.damage

	update_hp(this)
end

local function hero_insert(this, store)
	this.hero.fn_level_up(this, store)

	this.melee.order = U.attack_order(this.melee.attacks)

	local mod_name = this.track_kills.mod
	local m = E:create_entity(mod_name)

	m.modifier.target_id = this.id
	m.modifier.source_id = this.id

	m.pos:copy(this.pos)
	simulation:queue_insert_entity(m)

	return true
end

local function hero_update(this, store)
	local h = this.health
	local r = this.nav_rally
	local brk, sta, should_fly, already_flying
	local orig_prefix = this.render.sprites[1].prefix
	local orig_speed = this.motion.max_speed
	local a, skill

	U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while r.new do
				if not already_flying then
					should_fly = V.dist2(this.pos.x, this.pos.y, r.pos.x, r.pos.y) > this.fly_to.min_distance * this.fly_to.min_distance

					if should_fly then
						already_flying = true

						U.bans_add(this.vis, F_ALL)

						this.health.ignore_damage = true
						this.render.sprites[1].prefix = this.fly_to.animation_prefix
						this.render.sprites[2].hidden = false
						orig_speed = this.motion.max_speed

						U.update_max_speed(this, this.motion.max_speed_bat)
						U.animation_start_default(this, "enter", nil, store.tick_ts)

						-- U.y_wait_unconditional(store, fts(7))
						local fx = E:create_entity("fx_vampiress_transform")

						fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
						fx.render.sprites[1].ts = store.tick_ts

						simulation:queue_insert_entity(fx)
						U.y_animation_wait_default(this)
					end
				end

				if SU.y_hero_new_rally(store, this) then
					goto label_477_0
				end

				if already_flying and not r.new then
					already_flying = nil
					this.render.sprites[2].hidden = true

					U.y_animation_play(this, "exit", nil, store.tick_ts)
					U.y_animation_wait_default(this)

					this.render.sprites[1].prefix = orig_prefix

					U.update_max_speed(this, orig_speed)
					U.bans_remove(this.vis, F_ALL)

					this.health.ignore_damage = false
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.slayer

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local targets = U.find_enemies_in_range_filter_off(this.pos, a.trigger_radius, a.vis_flags, a.vis_bans)

				if not targets then
					a.ts = a.ts + 0.13333333333333333
				else
					local start_ts = store.tick_ts

					S:queue(a.sound)
					U.animation_start_default(this, a.animation, nil, store.tick_ts, false)

					a.ts = store.tick_ts

					while store.tick_ts - start_ts < a.hit_time do
						if SU.hero_interrupted(this) then
							goto label_477_0
						end

						coroutine.yield()
					end

					targets = U.find_enemies_in_range_filter_off(this.pos, a.damage_radius, a.vis_flags, a.vis_bans)

					if targets then
						for _, e in ipairs(targets) do
							local d = E.assign_damage(a.damage_type, (math.random(a.damage_min, a.damage_max) + this.unit.damage_buff) * this.unit.damage_factor, this.id, e.id)

							d.track_kills = true

							if table.contains(a.extra_damage_templates, e.template_name) then
								d.value = d.value * a.extra_damage_factor
							end

							queue_damage(store, d)
						end
					end

					while not U.animation_finished_default(this) do
						if SU.hero_interrupted(this) then
							goto label_477_0
						end

						coroutine.yield()
					end

					SU.hero_gain_xp_from_skill(this, skill)
				end
			end

			if this.melee then
				brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

				if brk or sta ~= A_NO_TARGET then
					goto label_477_0
				end
			end

			if SU.soldier_go_back_step(store, this) then
			-- block empty
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_477_0::

		coroutine.yield()
	end
end

local tt

tt = RT("hero_vampiress", "hero")

AC(tt, "melee", "timed_attacks", "track_kills")

tt.hero.level_stats.hp_max = {270, 280, 290, 300, 310, 320, 330, 340, 350, 360}
tt.hero.level_stats.armor = {0.34, 0.38, 0.42, 0.46, 0.5, 0.54, 0.58, 0.62, 0.66, 0.7}
tt.hero.level_stats.magic_armor = {0.17, 0.19, 0.21, 0.23, 0.25, 0.27, 0.29, 0.31, 0.33, 0.35}
tt.hero.level_stats.melee_damage_min = {10, 11, 12, 13, 14, 15, 16, 17, 18, 19}
tt.hero.level_stats.melee_damage_max = {20, 22, 24, 26, 28, 30, 32, 34, 36, 38}
tt.hero.skills.vampirism = CC("hero_skill")
tt.hero.skills.vampirism.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.vampirism.xp_gain_factor = 50
tt.hero.skills.vampirism.damage = {100, 140, 180, 220}
tt.hero.skills.slayer = CC("hero_skill")
tt.hero.skills.slayer.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.slayer.xp_gain_factor = 60
tt.hero.skills.slayer.damage_min = {40, 80, 120}
tt.hero.skills.slayer.damage_max = {80, 160, 240}
tt.hero.fn_level_up = hero_level_up
tt.track_kills.mod = "mod_vampiress_gain"
tt.health.armor = nil
tt.health.dead_lifetime = 15
tt.health.hp_max = nil
tt.health_bar.offset = vec_2(0, 34)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.tombstone_show_time = fts(90)
tt.health_bar.draw_order = -1
tt.idle_flip.cooldown = 1
tt.info.hero_portrait = "kr2_hero_portraits_0019"
tt.info.portrait = "kr2_info_portraits_heroes_0019"
tt.main_script.insert = hero_insert
tt.main_script.update = hero_update
tt.motion.max_speed = 2 * FPS
tt.motion.max_speed_bat = 4.5 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.32432432432432434
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_vampiress"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"running"}
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].hidden = true
tt.soldier.melee_slot_offset.x = 5
tt.sound_events.change_rally_point = "HWVampiressTaunt"
tt.sound_events.death = "HWVampiressDeath"
tt.sound_events.respawn = "HWVampiressTauntIntro"
tt.sound_events.insert = "HWVampiressTauntIntro"
tt.sound_events.hero_room_select = "HWVampiressTauntSelect"
tt.unit.mod_offset = vec_2(0, 12)
tt.fly_to = {}
tt.fly_to.min_distance = 80
tt.fly_to.animation_prefix = "hero_vampiress_bat"
tt.melee.attacks[1].cooldown = 0.9
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].damage_type = DAMAGE_TRUE
tt.melee.attacks[1].xp_gain_factor = 2.5
tt.melee.attacks[1].side_effect = function(this, store, damage, target)
	U.heal(this, 3)
end
tt.melee.attacks[2] = CC("melee_attack")
tt.melee.attacks[2].animation = "vampirism"
tt.melee.attacks[2].cooldown = 15
tt.melee.attacks[2].damage_type = DAMAGE_TRUE
tt.melee.attacks[2].mods = {"mod_vampiress_lifesteal", "mod_vampiress_blood"}
tt.melee.attacks[2].sound = "HWVampiressLifesteal"
tt.melee.attacks[2].hit_time = fts(9)
tt.melee.attacks[2].xp_gain_factor = 2
tt.melee.attacks[2].disabled = true
tt.melee.range = 80
tt.nav_grid.ignore_waypoints = true
tt.timed_attacks.list[1] = CC("area_attack")
tt.timed_attacks.list[1].animation = "slayer"
tt.timed_attacks.list[1].cooldown = 10
tt.timed_attacks.list[1].trigger_radius = 50
tt.timed_attacks.list[1].damage_radius = 65
tt.timed_attacks.list[1].damage_type = DAMAGE_TRUE
tt.timed_attacks.list[1].hit_time = fts(10)
tt.timed_attacks.list[1].sound = "HWVampiressAreaAttack"
tt.timed_attacks.list[1].extra_damage_templates = {"enemy_elvira"}
tt.timed_attacks.list[1].extra_damage_factor = 10
tt.timed_attacks.list[1].disabled = true
tt.vis.bans = bor(tt.vis.bans, F_POISON)
tt.gain_count = 0
tt = RT("fx_vampiress_transform", "fx")
tt.render.sprites[1].name = "fx_vampiress_transform"
tt.render.sprites[1].anchor.y = 0.32432432432432434
tt = RT("mod_vampiress_lifesteal", "modifier")
tt.heal_hp = 100
tt.main_script.insert = scripts.mod_simple_lifesteal.insert
tt = RT("mod_vampiress_blood", "mod_blood")
tt.modifier.duration = 6
tt.dps.damage_min = 5
tt.dps.damage_max = 5
tt.dps.damage_inc = 5
tt = RT("mod_vampiress_gain", "modifier")
tt.gain = {
	damage = 0.8,
	hp = 2,
	magic_armor = 0.004,
	armor = 0.002,
	heal = 30,
	size = 0.005,
	cooldown = 0.02,
	radius = 0.3,
	speed = 0.5
}
tt.max_gain_count = 75
tt.main_script.insert = scripts.mod_gain_on_kill.insert
tt.main_script.update = mod_vampiress_gain_update
