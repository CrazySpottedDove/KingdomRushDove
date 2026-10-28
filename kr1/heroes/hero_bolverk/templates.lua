local scripts = require("scripts")
local E = require("entity_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local bit = require("bit")
local HU = require("hero_utils")
local bor = bit.bor
local fts = U.fts
local level_up_basic = HU.level_up_basic
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local tt

local function hero_bolverk_level_up(this, store)
	local hl, ls = level_up_basic(this, store)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	upgrade_skill(this, "slash", function(this, s)
		this.melee.attacks[2].disabled = nil
		this.melee.attacks[2].damage_min = s.damage_min[s.level]
		this.melee.attacks[2].damage_max = s.damage_max[s.level]
	end)
	upgrade_skill(this, "scream", function(this, s)
		this.timed_attacks.list[1].disabled = nil

		local mod = E:get_template("mod_bolverk_fire")

		mod.dps.damage_min = s.fire_damage[s.level]
		mod.dps.damage_max = s.fire_damage[s.level]
	end)
	upgrade_skill(this, "berserker", function(this, s)
		this.berserker_factor = s.factor[s.level]
	end)
	update_hp(this)
end

local function hero_bolverk_update(this, store)
	local h = this.health
	local brk, sta, a

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
				if SU.y_hero_new_rally(store, this) then
					goto label_223_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "respawn", nil, store.tick_ts)
			end

			local factor = (this.health.hp / this.health.hp_max) * (1 - this.berserker_factor) + this.berserker_factor

			this.timed_attacks.list[1].cooldown = this.timed_attacks.list[1].raw_cooldown * factor
			this.melee.attacks[1].cooldown = this.melee.attacks[1].raw_cooldown * factor
			this.melee.attacks[2].cooldown = this.melee.attacks[2].raw_cooldown * factor
			a = this.timed_attacks.list[1]

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local targets = U.find_enemies_between_range_filter_off(this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if not targets or #targets < a.min_count then
					a.ts = a.ts + 0.13333333333333333
				else
					S:queue(a.sound, a.sound_args)
					U.animation_start_default(this, a.animation, nil, store.tick_ts)

					if SU.y_soldier_wait(store, this, a.hit_time) then
					-- block empty
					else
						targets = U.find_enemies_between_range_filter_off(this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

						if targets then
							for _, target in ipairs(targets) do
								local m1 = E:create_entity(a.mods[1])

								m1.modifier.target_id = target.id
								m1.modifier.source_id = this.id

								simulation:queue_insert_entity(m1)

								local m2 = E:create_entity(a.mods[2])

								m2.modifier.target_id = target.id
								m2.modifier.source_id = this.id

								simulation:queue_insert_entity(m2)
							end
						end

						U.heal(this, (this.health.hp_max - this.health.hp) * 0.06)
						SU.y_hero_animation_wait(this)
						SU.hero_gain_xp_from_skill(this, this.hero.skills.scream)

						a.ts = store.tick_ts
					end

					goto label_223_0
				end
			end

			if this.melee then
				brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

				if brk or sta ~= A_NO_TARGET then
					goto label_223_0
				end
			end

			if SU.soldier_go_back_step(store, this) then
			-- block empty
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_223_0::

		coroutine.yield()
	end
end

tt = RT("hero_bolverk", "hero")

AC(tt, "melee", "timed_attacks")

tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.hp_max = {410, 425, 440, 455, 470, 485, 500, 515, 530, 545}
tt.hero.level_stats.melee_damage_max = {23, 25, 27, 29, 31, 33, 35, 37, 39, 41}
tt.hero.level_stats.melee_damage_min = {18, 19, 20, 21, 22, 23, 24, 25, 26, 27}
tt.hero.skills.slash = CC("hero_skill")
tt.hero.skills.slash.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.slash.damage_max = {120, 160, 200}
tt.hero.skills.slash.damage_min = {80, 120, 160}
tt.hero.skills.scream = CC("hero_skill")
tt.hero.skills.scream.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.scream.fire_damage = {5, 10, 15}
tt.hero.skills.scream.xp_gain_factor = 60
tt.hero.skills.berserker = CC("hero_skill")
tt.hero.skills.berserker.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.berserker.factor = {0.45, 0.36, 0.27, 0.18}
tt.health.dead_lifetime = 15
tt.health.hp_max = 545
tt.health_bar.offset = vec_2(0, 43)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.tombstone_show_time = fts(90)
tt.info.hero_portrait = "kr3_hero_portraits_0019"
tt.info.portrait = "kr3_info_portraits_heroes_0019"
tt.hero.fn_level_up = hero_bolverk_level_up
tt.main_script.update = hero_bolverk_update
tt.motion.max_speed = 3.3 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.22727272727273
tt.render.sprites[1].prefix = "hero_bolverk"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].name = "idle"
tt.soldier.melee_slot_offset = vec_2(2, 0)
tt.sound_events.change_rally_point = "ElvesHeroBolverkTaunt"
tt.sound_events.death = "ElvesHeroBolverkDeath"
tt.sound_events.insert = "ElvesHeroBolverkTauntIntro"
tt.sound_events.respawn = "ElvesHeroBolverkTauntIntro"
tt.sound_events.hero_room_select = "ElvesHeroBolverkTauntSelect"
tt.unit.hit_offset = vec_2(0, 20)
tt.unit.mod_offset = vec_2(0, 20)
tt.melee.attacks[1].damage_max = 41
tt.melee.attacks[1].damage_min = 27
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].raw_cooldown = 1
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].xp_gain_factor = 3.5
tt.melee.attacks[2] = CC("melee_attack")
tt.melee.attacks[2].animation = "hit"
tt.melee.attacks[2].cooldown = 20
tt.melee.attacks[2].raw_cooldown = 20
tt.melee.attacks[2].damage_max = 100
tt.melee.attacks[2].damage_min = 80
tt.melee.attacks[2].damage_type = DAMAGE_RUDE
tt.melee.attacks[2].hit_time = fts(9)
tt.melee.attacks[2].sound = "ElvesHeroBolverkSlash"
tt.melee.attacks[2].xp_gain_factor = 1.8
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].side_effect = function(this, store, damage, target)
	U.heal(this, (this.health.hp_max - this.health.hp) * 0.12)
end
tt.melee.range = 55
tt.timed_attacks.list[1] = CC("mod_attack")
tt.timed_attacks.list[1].animation = "scream"
tt.timed_attacks.list[1].cooldown = 10
tt.timed_attacks.list[1].raw_cooldown = 10
tt.timed_attacks.list[1].max_range = 65
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].min_count = 1
tt.timed_attacks.list[1].mods = {"mod_bolverk_scream", "mod_bolverk_fire"}
tt.timed_attacks.list[1].hit_time = fts(9)
tt.timed_attacks.list[1].sound = "ElvesHeroBolverkCry"
tt.timed_attacks.list[1].vis_flags = F_RANGED
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[1].disabled = true
tt.vis.bans = bor(tt.vis.bans, F_BURN)
tt.berserker_factor = 0.5
tt = RT("mod_bolverk_scream", "modifier")

AC(tt, "render")

tt.received_damage_factor = 1.5
tt.inflicted_damage_factor = 0.7
tt.modifier.duration = 20
tt.modifier.resets_same = false
tt.modifier.use_mod_offset = false
tt.main_script.insert = scripts.mod_damage_factors.insert
tt.main_script.remove = scripts.mod_damage_factors.remove
tt.main_script.update = scripts.mod_track_target.update
tt.render.sprites[1].prefix = "mod_weakness"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.render.sprites[1].name = "small"
tt.render.sprites[1].z = Z_DECALS
tt = RT("mod_bolverk_fire", "modifier")

AC(tt, "render", "dps")

tt.explode_fx = "fx_unit_explode"
tt.modifier.duration = 7
tt.modifier.vis_flags = bor(F_MOD, F_BURN)
tt.nodes_limit = 20
tt.render.sprites[1].name = "mod_dark_spitters"
tt.render.sprites[1].draw_order = 10
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt.dps.damage_every = 0.5
tt.dps.damage_max = 5
tt.dps.damage_min = 5
tt.dps.damage_type = DAMAGE_POISON
