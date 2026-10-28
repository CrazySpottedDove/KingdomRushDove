local bit = require("bit")
local E = require("entity_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")
local scripts = require("scripts")

require("lib.klua.table")
require("all.constants")

local band = bit.band
local bor = bit.bor
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local update_hp = HU.update_hp
local queue_damage = U.queue_damage

local function hero_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
	this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]
	this.melee.attacks[3].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[3].damage_max = ls.melee_damage_max[hl]

	upgrade_skill(this, "snakestyle", function(this, s)
		local a = this.melee.attacks[4]

		a.disabled = nil
		a.damage_max = s.damage[s.level]
		a.damage_min = s.damage[s.level]

		local m = E:get_template("mod_monk_damage_reduction")

		m.reduction_factor = s.damage_reduction_factor[s.level]
	end)
	upgrade_skill(this, "dragonstyle", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.damage_min = s.damage_min[s.level]
		a.damage_max = s.damage_max[s.level]
	end)
	upgrade_skill(this, "tigerstyle", function(this, s)
		local a = this.melee.attacks[5]

		a.disabled = nil
		a.damage_max = s.damage[s.level]
		a.damage_min = s.damage[s.level]
	end)
	upgrade_skill(this, "leopardstyle", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.damage_max = s.damage_max[s.level]
		a.damage_min = s.damage_min[s.level]
		a.loops = s.loops[s.level]
	end)
	upgrade_skill(this, "cranestyle", function(this, s)
		this.dodge.disabled = nil
		this.dodge.chance = s.chance[s.level]
		this.dodge.damage = s.damage[s.level]
		this.dodge.cooldown = s.cooldown[s.level]
	end)
	update_hp(this)

	this.melee.attacks[4].ts = -this.melee.attacks[4].cooldown
	this.melee.attacks[5].ts = -this.melee.attacks[5].cooldown
	this.timed_attacks.list[1].ts = -this.timed_attacks.list[1].cooldown
	this.timed_attacks.list[2].ts = -this.timed_attacks.list[2].cooldown
end

local function hero_insert(this, store)
	this.hero.fn_level_up(this, store)

	this.melee.order = {
		[1] = 4,
		[2] = 5,
		[3] = 2,
		[4] = 3,
		[5] = 1
	}

	return true
end

local function hero_update(this, store)
	local h = this.health
	local a, skill, brk, sta

	U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			a = this.dodge
			skill = this.hero.skills.cranestyle

			if not a.disabled and a.active then
				a.active = false

				local target = store.entities[this.soldier.target_id]

				if not target or target.health.dead then
				-- block empty
				else
					U.bans_add(this.vis, F_ALL)

					this.health_bar.hidden = true

					SU.hide_modifiers(store, this, true)

					a.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, skill)
					S:queue(a.sound, {
						delay = fts(15)
					})
					U.animation_start_default(this, a.animation, nil, store.tick_ts)

					if SU.y_soldier_wait(store, this, a.hit_time) then
						U.bans_remove(this.vis, F_ALL)

						this.health_bar.hidden = this.health.dead

						goto label_393_2
					end

					local d = E.assign_damage(a.damage_type, (a.damage + this.unit.damage_buff) * this.unit.damage_factor, this.id, target.id)

					queue_damage(store, d)
					U.bans_remove(this.vis, F_ALL)

					this.health_bar.hidden = false

					SU.show_modifiers(store, this, true)

					if SU.y_hero_animation_wait(this) then
						goto label_393_2
					end
				end
			end

			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_393_2
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.dragonstyle

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local targets = U.find_enemies_between_range_filter_off(this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if not targets then
					a.ts = a.ts + 0.13333333333333333
				else
					local start_ts = store.tick_ts

					this.health.ignore_damage = true

					S:queue(a.sound, {
						delay = fts(5)
					})

					local an, af = U.animation_name_facing_point(this, a.animation, targets[1].pos)

					U.animation_start_default(this, an, af, store.tick_ts, false)

					while store.tick_ts - start_ts < a.hit_time do
						if SU.hero_interrupted(this) then
							this.health.ignore_damage = nil

							goto label_393_2
						end

						coroutine.yield()
					end

					a.ts = start_ts

					SU.hero_gain_xp_from_skill(this, skill)

					targets = U.find_enemies_in_range_filter_off(this.pos, a.damage_radius, a.damage_flags, a.damage_bans)

					if targets then
						for _, t in ipairs(targets) do
							local d = E.assign_damage(a.damage_type, (math.random(a.damage_min, a.damage_max) + this.unit.damage_buff) * this.unit.damage_factor, this.id, t.id)

							queue_damage(store, d)
						end
					end

					while not U.animation_finished_default(this) do
						if SU.hero_interrupted(this) then
							break
						end

						coroutine.yield()
					end

					this.health.ignore_damage = nil

					goto label_393_2
				end
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.leopardstyle

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local targets = U.find_enemies_in_range_filter_off(this.pos, a.range, a.vis_flags, a.vis_bans)

				if not targets then
					a.ts = a.ts + 0.13333333333333333

					goto label_393_1
				end

				U.unblock_target(store, this)

				this.health.ignore_damage = true
				this.health_bar.hidden = true

				local start_ts = store.tick_ts
				local start_pos = V.vclone(this.pos)
				local last_target
				local i = 1

				U.animation_start_default(this, "leopard_start", nil, store.tick_ts, false)

				while not U.animation_finished_default(this) do
					if SU.hero_interrupted(this) then
						goto label_393_0
					end

					coroutine.yield()
				end

				a.ts = start_ts

				SU.hero_gain_xp_from_skill(this, skill)

				while i <= a.loops do
					i = i + 1
					targets = U.find_enemies_in_range_filter_off(start_pos, a.range, a.vis_flags, a.vis_bans)

					if not targets then
						break
					end

					if #targets > 1 then
						targets = table.filter(targets, function(k, v)
							return v ~= last_target
						end)
					end

					local target = table.random(targets)

					last_target = target

					local animation, animation_idx = table.random(a.hit_animations)
					local hit_time = a.hit_times[animation_idx]
					local hit_pos = U.melee_slot_position(this, target, 1)
					local last_ts = store.tick_ts

					this.pos.x, this.pos.y = hit_pos.x, hit_pos.y

					if band(target.vis.bans, F_STUN) == 0 then
						SU.stun_inc(target)
					end

					local sound = (i - 1) % 3 == 0 and "HeroMonkMultihitScream" or "HeroMonkMultihitPunch"

					S:queue(sound)

					local an, af = U.animation_name_facing_point(this, animation, target.pos)

					U.animation_start_default(this, an, af, store.tick_ts)

					while hit_time > store.tick_ts - last_ts do
						if SU.hero_interrupted(this) then
							SU.stun_dec(target)

							goto label_393_0
						end

						coroutine.yield()
					end

					local d = E.assign_damage(a.damage_type, (math.random(a.damage_min, a.damage_max) + this.unit.damage_buff) * this.unit.damage_factor, this.id, target.id)

					queue_damage(store, d)

					local poff = a.particle_pos[animation_idx]
					local fx = E:create_entity("fx")

					fx.pos.x, fx.pos.y = (af and -1 or 1) * poff.x + this.pos.x, poff.y + this.pos.y
					fx.render.sprites[1].name = "fx_hero_monk_particle"
					fx.render.sprites[1].ts = store.tick_ts
					fx.render.sprites[1].sort_y_offset = -2

					simulation:queue_insert_entity(fx)

					while not U.animation_finished_default(this) do
						if SU.hero_interrupted(this) then
							SU.stun_dec(target)

							goto label_393_0
						end

						coroutine.yield()
					end

					SU.stun_dec(target)
				end

				::label_393_0::

				this.health.ignore_damage = nil
				this.health_bar.hidden = false
				this.pos.x, this.pos.y = start_pos.x, start_pos.y

				U.y_animation_play(this, "leopard_end", nil, store.tick_ts, 1)
			end

			::label_393_1::

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
				-- block empty
				if this.cooldown_factor_dec_count < 8 and sta == A_DONE then
					SU.insert_unit_cooldown_buff(store.tick_ts, this, 0.938)

					this.cooldown_factor_dec_count = this.cooldown_factor_dec_count + 1
				end
			elseif SU.soldier_go_back_step(store, this) then
			-- block empty
			else
				if this.cooldown_factor_dec_count > 0 then
					if this.cooldown_factor_dec_count <= 8 then
						SU.remove_unit_cooldown_buff(store.tick_ts, this, 0.938)
					end

					this.cooldown_factor_dec_count = this.cooldown_factor_dec_count - 1
				end

				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_393_2::

		coroutine.yield()
	end
end

local function mod_monk_damage_reduction_insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if target and target.unit then
		SU.insert_unit_damage_factor_mul_buff(target, 1 - this.reduction_factor)
	end

	return false
end

local tt

tt = RT("hero_monk", "hero")

AC(tt, "dodge", "melee", "timed_attacks")

tt.hero.level_stats.hp_max = {220, 240, 260, 280, 300, 320, 340, 360, 380, 400}
tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.melee_damage_min = {11, 13, 14, 16, 18, 19, 21, 22, 24, 26}
tt.hero.level_stats.melee_damage_max = {17, 19, 22, 24, 26, 29, 31, 34, 36, 38}
tt.hero.skills.snakestyle = CC("hero_skill")
tt.hero.skills.snakestyle.damage = {40, 60, 80, 100}
tt.hero.skills.snakestyle.damage_reduction_factor = {0.24, 0.36, 0.48, 0.64}
tt.hero.skills.snakestyle.xp_gain_factor = 42
tt.hero.skills.snakestyle.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.dragonstyle = CC("hero_skill")
tt.hero.skills.dragonstyle.damage_max = {75, 135, 195}
tt.hero.skills.dragonstyle.damage_min = {35, 65, 95}
tt.hero.skills.dragonstyle.xp_gain_factor = 108
tt.hero.skills.dragonstyle.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.tigerstyle = CC("hero_skill")
tt.hero.skills.tigerstyle.damage = {30, 60, 90, 120}
tt.hero.skills.tigerstyle.xp_gain_factor = 24
tt.hero.skills.tigerstyle.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.leopardstyle = CC("hero_skill")
tt.hero.skills.leopardstyle.loops = {4, 5, 6, 7, 8}
tt.hero.skills.leopardstyle.damage_max = {30, 33, 36, 39, 42}
tt.hero.skills.leopardstyle.damage_min = {10, 11, 12, 13, 14}
tt.hero.skills.leopardstyle.xp_gain_factor = 30
tt.hero.skills.leopardstyle.xp_level_steps = {
	[2] = 1,
	[4] = 2,
	[6] = 3,
	[8] = 4,
	[10] = 5
}
tt.hero.skills.cranestyle = CC("hero_skill")
tt.hero.skills.cranestyle.damage = {20, 40, 60, 80}
tt.hero.skills.cranestyle.chance = {0.4, 0.5, 0.6, 0.7}
tt.hero.skills.cranestyle.cooldown = {2, 1.5, 1, 0.5}
tt.hero.skills.cranestyle.xp_gain_factor = 18
tt.hero.skills.cranestyle.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.health.armor = nil
tt.health.dead_lifetime = 15
tt.health.hp_max = nil
tt.health_bar.offset = vec_2(0, 38)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_level_up
tt.hero.tombstone_show_time = fts(66)
tt.idle_flip.cooldown = 1
tt.info.hero_portrait = "kr2_hero_portraits_0012"
tt.info.portrait = "kr2_info_portraits_heroes_0012"
tt.main_script.insert = hero_insert
tt.main_script.update = hero_update
tt.motion.max_speed = 120
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.18446601941747573
tt.render.sprites[1].prefix = "hero_monk"
tt.soldier.melee_slot_offset.x = 5
tt.sound_events.change_rally_point = "HeroMonkTaunt"
tt.sound_events.death = "HeroMonkDeath"
tt.sound_events.respawn = "HeroMonkTauntIntro"
tt.sound_events.insert = "HeroMonkTauntIntro"
tt.sound_events.hero_room_select = "HeroMonkTauntSelect"
tt.unit.marker_offset = vec_2(0, -1)
tt.unit.mod_offset = vec_2(0, 18)
tt.dodge.disabled = true
tt.dodge.animation = "crane"
tt.dodge.cooldown = 2
tt.dodge.damage_type = DAMAGE_PHYSICAL
tt.dodge.ranged = true
tt.dodge.hit_time = fts(18)
tt.dodge.sound = "HeroMonkCounter"
tt.melee.cooldown = 0.8
tt.melee.range = 83.2
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].animation = "attack1"
tt.melee.attacks[1].hit_time = fts(18)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 3
tt.melee.attacks[1].side_effect = function(this, store, damage, target)
	SU.armor_dec(target, 0.1)
end
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].chance = 0.33
tt.melee.attacks[2].hit_time = fts(14)
tt.melee.attacks[2].side_effect = function(this, store, damage, target)
	this.melee.attacks[4].ts = this.melee.attacks[4].ts - 1
	this.melee.attacks[5].ts = this.melee.attacks[5].ts - 1
end
tt.melee.attacks[3] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[3].animation = "attack3"
tt.melee.attacks[3].chance = 0.5
tt.melee.attacks[3].hit_time = fts(5)
tt.melee.attacks[3].side_effect = function(this, store, damage, target)
	this.timed_attacks.list[1].ts = this.timed_attacks.list[1].ts - 1
	this.timed_attacks.list[2].ts = this.timed_attacks.list[2].ts - 1
end
tt.melee.attacks[4] = CC("melee_attack")
tt.melee.attacks[4].disabled = true
tt.melee.attacks[4].animation = "snake"
tt.melee.attacks[4].cooldown = 11.2
tt.melee.attacks[4].damage_max = nil
tt.melee.attacks[4].damage_min = nil
tt.melee.attacks[4].hit_time = fts(10)
tt.melee.attacks[4].mod = "mod_monk_damage_reduction"
tt.melee.attacks[4].sound = "HeroMonkSnakeAttack"
tt.melee.attacks[4].vis_bans = bor(F_FLYING, F_CLIFF, F_BOSS)
tt.melee.attacks[4].vis_flags = F_BLOCK
tt.melee.attacks[4].xp_from_skill = "snakestyle"
tt.melee.attacks[5] = CC("melee_attack")
tt.melee.attacks[5].disabled = true
tt.melee.attacks[5].animation = "tiger"
tt.melee.attacks[5].cooldown = 6.4
tt.melee.attacks[5].damage_max = nil
tt.melee.attacks[5].damage_min = nil
tt.melee.attacks[5].damage_type = DAMAGE_TRUE
tt.melee.attacks[5].hit_time = fts(6)
tt.melee.attacks[5].sound = "HeroMonkHadoken"
tt.melee.attacks[5].xp_from_skill = "tigerstyle"
tt.melee.attacks[5].side_effect = function(this, store, damage, target)
	U.heal(this, 30)
end
tt.timed_attacks.list[1] = CC("area_attack")
tt.timed_attacks.list[1].animation = "dragon"
tt.timed_attacks.list[1].cooldown = 12.8
tt.timed_attacks.list[1].damage_max = nil
tt.timed_attacks.list[1].damage_min = nil
tt.timed_attacks.list[1].damage_radius = 55
tt.timed_attacks.list[1].damage_type = DAMAGE_TRUE
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].hit_time = fts(14)
tt.timed_attacks.list[1].sound = "HeroMonkFiredragon"
tt.timed_attacks.list[1].xp_from_skill = "dragonstyle"
tt.timed_attacks.list[1].max_range = 37.5
tt.timed_attacks.list[1].vis_bans = 0
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].cooldown = 8
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].hit_animations = {"leopard_hit1", "leopard_hit2", "leopard_hit3", "leopard_hit4"}
tt.timed_attacks.list[2].hit_times = {fts(3), fts(3), fts(3), fts(3)}
tt.timed_attacks.list[2].particle_pos = {vec_2(20, 14), vec_2(24, 22), vec_2(18, 14), vec_2(21, 18)}
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING, F_BOSS, F_WATER, F_CLIFF)
tt.timed_attacks.list[2].vis_flags = bor(F_STUN, F_RANGED)
tt.timed_attacks.list[2].damage_type = DAMAGE_RUDE
tt.timed_attacks.list[2].range = 100
tt.timed_attacks.list[2].xp_from_skill = "leopardstyle"
tt.cooldown_factor_dec_count = 0
tt = RT("mod_monk_damage_reduction", "modifier")
tt.main_script.insert = mod_monk_damage_reduction_insert
