local bit = require("bit")
local E = require("entity_db")
local P = require("path_db")
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
local ready_to_use_skill = HU.ready_to_use_skill
local ready_to_attack = U.ready_to_attack
local update_hp = HU.update_hp

local function van_helsing_grenade_update(this, store)
	local b = this.bullet

	while store.tick_ts - b.ts + store.tick_length < b.flight_time do
		coroutine.yield()

		b.last_pos.x, b.last_pos.y = this.pos.x, this.pos.y
		this.pos.x, this.pos.y = SU.position_in_parabola(store.tick_ts - b.ts, b.from, b.speed, b.g)
		this.render.sprites[1].r = this.render.sprites[1].r + b.rotation_speed * store.tick_length

		if b.hide_radius then
			this.render.sprites[1].hidden = V.dist(this.pos.x, this.pos.y, b.from.x, b.from.y) < b.hide_radius or V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) < b.hide_radius
		end
	end

	local targets = U.find_enemies_in_range_filter_off(this.pos, b.damage_radius, b.damage_flags, b.damage_bans)

	if targets then
		for _, t in ipairs(targets) do
			if t.health and not t.health.dead then
				local mod = E:create_entity(b.mod)

				mod.modifier.target_id = t.id

				simulation:queue_insert_entity(mod)
			end
		end
	end

	local fx = E:create_entity(b.hit_fx)

	fx.render.sprites[1].ts = store.tick_ts

	fx.pos:copy(b.to)
	simulation:queue_insert_entity(fx)
	simulation:queue_remove_entity(this)
end

local function mod_van_helsing_relic_update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	local factor = this.armor_reduce_factor

	if not target or not target.health or target.health.dead then
	-- block empty
	else
		for _, n in pairs(this.remove_mods) do
			SU.remove_modifiers(store, target, n)
		end

		if target.health.armor > 0 then
			SU.armor_dec(target, target.health.armor * factor)
		end

		if target.health.magic_armor > 0 then
			SU.magic_armor_dec(target, target.health.magic_armor * factor)
		end

		this.pos.x, this.pos.y = target.pos.x, target.pos.y
		this.render.sprites[1].offset.y = target.health_bar.offset.y
		this.render.sprites[1].ts = store.tick_ts

		U.y_animation_wait_default(this)
	end

	simulation:queue_remove_entity(this)
end

local function hero_level_up(this, store)
	local hl, ls = level_up_basic(this)
	local a = this.melee.attacks[1]

	a.damage_max = ls.damage_max[hl]
	a.damage_min = ls.damage_min[hl]

	local b = E:get_template("van_helsing_shotgun")

	b.bullet.damage_max = ls.ranged_damage_max[hl]
	b.bullet.damage_min = ls.ranged_damage_min[hl]

	upgrade_skill(this, "multishoot", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.loops = s.loops[s.level]
	end)
	upgrade_skill(this, "silverbullet", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil

		local b = E:get_template(a.bullet)

		b.bullet.damage_max = s.damage[s.level]
		b.bullet.damage_min = s.damage[s.level]
	end)
	upgrade_skill(this, "holygrenade", function(this, s)
		local a = this.timed_attacks.list[3]

		a.disabled = nil

		local m = E:get_template("mod_van_helsing_silence")

		m.modifier.duration = s.silence_duration[s.level]
	end)
	upgrade_skill(this, "relicofpower", function(this, s)
		local a = this.melee.attacks[2]

		a.disabled = nil

		local m = E:get_template("mod_van_helsing_relic")

		m.armor_reduce_factor = s.armor_reduce_factor[s.level]
	end)
	upgrade_skill(this, "beaconoflight", function(this, s)
		local m = E:get_template("mod_van_helsing_beacon")

		m.inflicted_damage_factor = s.inflicted_damage_factor[s.level]
		this.info.hero_portrait_always_on = true
	end)
	update_hp(this)
end

local function hero_insert(this, store)
	this.hero.fn_level_up(this, store)

	this.ranged.order = U.attack_order(this.ranged.attacks)
	this.melee.order = U.attack_order(this.melee.attacks)

	local a = E:create_entity("van_helsing_beacon_aura")

	a.aura.source_id = this.id

	simulation:queue_insert_entity(a)

	this._beaconoflight_aura = a

	return true
end

local function hero_update(this, store)
	local h = this.health
	local ra = this.ranged.attacks[1]
	local a, skill, brk, sta

	local function is_werewolf(e)
		local t1 = e.template_name

		return t1 == "enemy_lycan" or t1 == "enemy_lycan_werewolf" or t1 == "enemy_werewolf"
	end

	local function shot_ready()
		return ready_to_attack(this.ranged.attacks[1], store)
	end

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			if band(this.health.last_damage_types, bor(DAMAGE_EAT, DAMAGE_HOST, DAMAGE_DISINTEGRATE)) == 0 then
				S:queue(this.sound_events.death)
				U.unblock_target(store, this)

				local death_ts = store.tick_ts
				local flags = this.vis.flags
				local prefix = this.render.sprites[1].prefix

				U.bans_add(this.vis, F_ALL)
				U.flags_remove(this.vis, flags)

				this.render.sprites[1].prefix = prefix .. "_ghost"
				this.health.ignore_damage = true
				this.info.hero_portrait = this.info.hero_portrait_dead
				this.info.portrait = this.info.portrait_dead

				U.y_animation_play(this, "start", nil, store.tick_ts)
				U.animation_start_default(this, "idle", nil, store.tick_ts, true)

				while store.tick_ts - death_ts < this.health.dead_lifetime and not this.force_respawn do
					SU.y_hero_new_rally(store, this)

					this.health.ignore_damage = true

					coroutine.yield()
				end

				U.bans_remove(this.vis, F_ALL)

				this.force_respawn = false

				U.flags_add(this.vis, flags)

				this.render.sprites[1].prefix = prefix

				update_hp(this)

				this.health.dead = false
				this.health.ignore_damage = false
				this.info.hero_portrait = this.info.hero_portrait_alive
				this.info.portrait = this.info.portrait_alive

				S:queue(this.sound_events.respawn)
				U.y_animation_play(this, "respawn", nil, store.tick_ts)

				this.health_bar.hidden = false
			else
				local a = this._beaconoflight_aura

				if a then
					a.aura.requires_alive_source = true
				end

				SU.y_hero_death_and_respawn(store, this)

				if a then
					a.aura.requires_alive_source = false
				end
			end
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_419_2
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.multishoot

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) and not shot_ready() then
				local target, targets = U.find_foremost_enemy_between_range_filter_off(this.pos, a.min_range, a.max_range, a.shoot_time, a.vis_flags, a.vis_bans)

				if not target then
					a.ts = a.ts + 0.2
				else
					local an, af = U.animation_name_facing_point(this, a.animations[1], target.pos)
					local aidx

					U.animation_start_default(this, an, af, store.tick_ts, false)

					while not U.animation_finished_default(this) do
						if SU.hero_interrupted(this) then
							goto label_419_1
						end

						coroutine.yield()
					end

					for i = 1, a.loops * 0.5 do
						an, af, aidx = U.animation_name_facing_point(this, a.animations[2], target.pos)

						U.animation_start_default(this, an, af, store.tick_ts, false)

						for i = 1, 2 do
							U.y_wait_unconditional(store, fts(2))

							local b = E:create_entity(a.bullet)

							b.pos.x = this.pos.x + (af and -1 or 1) * a.bullet_start_offset[aidx].x
							b.pos.y = this.pos.y + a.bullet_start_offset[aidx].y

							b.bullet.from:copy(b.pos)
							b.bullet.to:copy(target.pos)

							b.bullet.target_id = target.id
							b.bullet.damage_factor = this.unit.damage_factor

							simulation:queue_insert_entity(b)
						end

						while not U.animation_finished_default(this) do
							if SU.hero_interrupted(this) then
								goto label_419_0
							end

							coroutine.yield()
						end

						target = table.random(targets)

						if target.health.dead then
							local center_pos = P:node_pos(target.nav_path.pi, 1, target.nav_path.ni)
							local nearby = U.find_nearest_enemy(store, center_pos, 0, a.search_range, a.vis_flags, a.vis_bans)

							if nearby then
								table.removeobject(targets, target)
								table.insert(targets, nearby)

								target = nearby
							end
						end
					end

					an, af = U.animation_name_facing_point(this, a.animations[3], target.pos)

					U.animation_start_default(this, an, af, store.tick_ts, false)

					while not U.animation_finished_default(this) and not SU.hero_interrupted(this) do
						coroutine.yield()
					end

					::label_419_0::

					a.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, skill)

					ra.ts = store.tick_ts

					goto label_419_2
				end
			end

			::label_419_1::

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.silverbullet

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local target = U.find_foremost_enemy_between_range_filter_on(this.pos, a.min_range, a.max_range, a.shoot_time, a.vis_flags, a.vis_bans, function(e)
					return math.abs(P:nodes_to_defend_point(e.nav_path.pi, e.nav_path.spi, e.nav_path.ni)) < a.nodes_to_defend
				end)

				if not target then
					local targets = U.find_enemies_between_range_filter_off(this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

					if targets then
						table.sort(targets, function(e1, e2)
							local h1 = e1.health.hp / (1 - e1.health.armor)
							local h2 = e2.health.hp / (1 - e2.health.armor)
							local df = a.werewolf_damage_factor

							return h1 * (is_werewolf(e1) and df or 1) > h2 * (is_werewolf(e2) and df or 1)
						end)

						if #targets > 0 then
							target = targets[1]
						end
					end
				end

				if not target then
					a.ts = a.ts + 0.2
				else
					local an, af, aidx = U.animation_name_facing_point(this, a.animation, target.pos)

					U.animation_start_default(this, an, af, store.tick_ts, false)

					if U.y_wait_conditional(store, a.crosshair_time, function()
						return SU.hero_interrupted(this)
					end) then
					-- block empty
					else
						local m = E:create_entity(a.crosshair_name)

						m.modifier.source_id = this.id
						m.modifier.target_id = target.id
						m.render.sprites[1].ts = store.tick_ts

						simulation:queue_insert_entity(m)

						if U.y_wait_conditional(store, a.shoot_time - a.crosshair_time, function()
							return SU.hero_interrupted(this)
						end) then
							simulation:queue_remove_entity(m)
						else
							local b = E:create_entity(a.bullet)

							b.pos.x = this.pos.x + (af and -1 or 1) * a.bullet_start_offset[aidx].x
							b.pos.y = this.pos.y + a.bullet_start_offset[aidx].y

							b.bullet.from:copy(b.pos)
							b.bullet.to:copy(target.pos)

							b.bullet.target_id = target.id
							b.bullet.damage_factor = (is_werewolf(target) and a.werewolf_damage_factor or 1) * this.unit.damage_factor

							simulation:queue_insert_entity(b)

							while not U.animation_finished_default(this) and not SU.hero_interrupted(this) do
								coroutine.yield()
							end

							a.ts = store.tick_ts

							SU.hero_gain_xp_from_skill(this, skill)

							ra.ts = store.tick_ts

							goto label_419_2
						end
					end
				end
			end

			a = this.timed_attacks.list[3]
			skill = this.hero.skills.holygrenade

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) and not shot_ready() then
				local g = E:get_template("van_helsing_grenade")
				local target, _, pred_pos = U.find_foremost_enemy_between_range_filter_on(this.pos, a.min_range, a.max_range, a.shoot_time + g.bullet.flight_time, a.vis_flags, a.vis_bans, U.enemy_is_silent_target)

				if not target then
					a.ts = a.ts + 0.2
				else
					local an, af = U.animation_name_facing_point(this, a.animation, target.pos)

					U.animation_start_default(this, an, af, store.tick_ts, false)

					if U.y_wait_conditional(store, a.shoot_time, function()
						return SU.hero_interrupted(this)
					end) then
					-- block empty
					else
						local b = E:create_entity(a.bullet)

						b.pos.x = this.pos.x + (af and -1 or 1) * a.bullet_start_offset[1].x
						b.pos.y = this.pos.y + a.bullet_start_offset[1].y

						b.bullet.from:copy(b.pos)
						b.bullet.to:copy(pred_pos)

						b.bullet.target_id = target.id

						simulation:queue_insert_entity(b)

						while not U.animation_finished_default(this) and not SU.hero_interrupted(this) do
							coroutine.yield()
						end

						a.ts = store.tick_ts

						SU.hero_gain_xp_from_skill(this, skill)

						goto label_419_2
					end
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

		::label_419_2::

		coroutine.yield()
	end
end

local function hero_can_relic(this, store, attack, target)
	return (target.health.armor > 0 or target.health.magic_armor > 0) and target.health.hp_max > 500
end

local tt

tt = RT("hero_van_helsing", "hero")

AC(tt, "melee", "ranged", "timed_attacks")

tt.hero.level_stats.hp_max = {300, 325, 350, 375, 400, 425, 450, 475, 500, 525}
tt.hero.level_stats.armor = {0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05}
tt.hero.level_stats.damage_min = {16, 19, 21, 24, 26, 29, 31, 34, 37, 40}
tt.hero.level_stats.damage_max = {24, 29, 33, 37, 42, 46, 51, 55, 59, 64}
tt.hero.level_stats.ranged_damage_min = {16, 19, 21, 24, 26, 29, 31, 34, 37, 40}
tt.hero.level_stats.ranged_damage_max = {24, 29, 33, 37, 42, 46, 51, 55, 59, 64}
tt.hero.skills.multishoot = CC("hero_skill")
tt.hero.skills.multishoot.loops = {4, 6, 8}
tt.hero.skills.multishoot.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.multishoot.xp_gain = {75, 125, 175}
tt.hero.skills.silverbullet = CC("hero_skill")
tt.hero.skills.silverbullet.damage = {200, 275, 350}
tt.hero.skills.silverbullet.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.silverbullet.xp_gain = {75, 125, 175}
tt.hero.skills.holygrenade = CC("hero_skill")
tt.hero.skills.holygrenade.silence_duration = {5, 10, 15}
tt.hero.skills.holygrenade.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.hero.skills.holygrenade.xp_gain = {50, 100, 150}
tt.hero.skills.relicofpower = CC("hero_skill")
tt.hero.skills.relicofpower.armor_reduce_factor = {0.25, 0.5, 1}
tt.hero.skills.relicofpower.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.relicofpower.xp_gain = {50, 100, 150}
tt.hero.skills.beaconoflight = CC("hero_skill")
tt.hero.skills.beaconoflight.inflicted_damage_factor = {1.2, 1.32, 1.45}
tt.hero.skills.beaconoflight.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.health.armor = nil
tt.health.dead_lifetime = 15
tt.health.hp_max = nil
tt.health_bar.offset = vec_2(0, 39)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_level_up
tt.hero.tombstone_show_time = fts(60)
tt.idle_flip.cooldown = 10
tt.info.hero_portrait = "kr2_hero_portraits_0013"
tt.info.hero_portrait_alive = "kr2_hero_portraits_0013"
tt.info.hero_portrait_dead = "kr2_hero_portraits_0013_dead"
tt.info.portrait = "kr2_info_portraits_heroes_0013"
tt.info.portrait_alive = "kr2_info_portraits_heroes_0013"
tt.info.portrait_dead = "kr2_info_portraits_heroes_0013_dead"
tt.main_script.insert = hero_insert
tt.main_script.update = hero_update
tt.motion.max_speed = 105
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.2857142857142857
tt.render.sprites[1].prefix = "hero_vanhelsing"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"running"}
tt.render.sprites[1].angles.ranged = {"ranged_side", "ranged_up", "ranged_down"}
tt.render.sprites[1].angles.multi_start = {"multi_start_side", "multi_start_up", "multi_start_down"}
tt.render.sprites[1].angles.multi_loop = {"multi_loop_side", "multi_loop_up", "multi_loop_down"}
tt.render.sprites[1].angles.multi_end = {"multi_end_side", "multi_end_up", "multi_end_down"}
tt.render.sprites[1].angles.silverbullet = {"silver_side", "silver_up", "silver_down"}
tt.render.sprites[1].angles_custom = {
	silverbullet = {35, 145, 210, 335}
}
tt.render.sprites[1].angles_flip_vertical = {
	silverbullet = true,
	multi_start = true,
	multi_loop = true,
	ranged = true,
	multi_end = true
}
tt.soldier.melee_slot_offset = vec_2(5, 0)
tt.sound_events.change_rally_point = "HeroVanHelsingTaunt"
tt.sound_events.death = "HeroVanHelsingDeath"
tt.sound_events.respawn = "HeroVanHelsingTauntIntro"
tt.sound_events.insert = "HeroVanHelsingTauntIntro"
tt.sound_events.hero_room_select = "HeroVanHelsingTauntSelect"
tt.unit.hit_offset = vec_2(0, 15)
tt.unit.mod_offset = vec_2(0, 15)
tt.melee.range = 51.2
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].cooldown = 1.45 - fts(23) + fts(9)
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 2.5
tt.melee.attacks[2] = CC("melee_attack")
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].animation = "relic"
tt.melee.attacks[2].cooldown = 20
tt.melee.attacks[2].mod = "mod_van_helsing_relic"
tt.melee.attacks[2].xp_from_skill = "relicofpower"
tt.melee.attacks[2].sound = "HeroVanHelsingRelic"
tt.melee.attacks[2].hit_time = fts(13)
tt.melee.attacks[2].vis_flags = F_BLOCK
tt.melee.attacks[2].vis_bans = bor(F_FLYING, F_CLIFF, F_BOSS)
tt.melee.attacks[2].fn_can = hero_can_relic
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animation = "ranged"
tt.ranged.attacks[1].bullet = "van_helsing_shotgun"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(24, 16), vec_2(18, 40), vec_2(16, -2)}
tt.ranged.attacks[1].max_range = 140
tt.ranged.attacks[1].min_range = 50
tt.ranged.attacks[1].shoot_time = fts(8)
tt.ranged.attacks[1].cooldown = 1.45
tt.timed_attacks.list[1] = CC("bullet_attack")
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].animations = {"multi_start", "multi_loop", "multi_end"}
tt.timed_attacks.list[1].bullet = "van_helsing_shotgun"
tt.timed_attacks.list[1].bullet_start_offset = tt.ranged.attacks[1].bullet_start_offset
tt.timed_attacks.list[1].shoot_time = fts(39)
tt.timed_attacks.list[1].max_range = 160
tt.timed_attacks.list[1].cooldown = 12
tt.timed_attacks.list[1].search_range = 75
tt.timed_attacks.list[2] = CC("bullet_attack")
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].animation = "silverbullet"
tt.timed_attacks.list[2].bullet = "van_helsing_silverbullet"
tt.timed_attacks.list[2].bullet_start_offset = {vec_2(24, 14), vec_2(22, 34), vec_2(12, -6)}
tt.timed_attacks.list[2].crosshair_time = fts(12)
tt.timed_attacks.list[2].crosshair_name = "mod_van_helsing_crosshair"
tt.timed_attacks.list[2].shoot_time = fts(23)
tt.timed_attacks.list[2].max_range = 210
tt.timed_attacks.list[2].cooldown = 10.8
tt.timed_attacks.list[2].nodes_to_defend = 20
tt.timed_attacks.list[2].werewolf_damage_factor = 2
tt.timed_attacks.list[3] = CC("bullet_attack")
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].animation = "grenade"
tt.timed_attacks.list[3].bullet = "van_helsing_grenade"
tt.timed_attacks.list[3].bullet_start_offset = {vec_2(16, 26)}
tt.timed_attacks.list[3].shoot_time = fts(16)
tt.timed_attacks.list[3].max_range = 160
tt.timed_attacks.list[3].cooldown = 8
tt = RT("van_helsing_shotgun", "shotgun")
tt.bullet.damage_min = 30
tt.bullet.damage_max = 30
tt.bullet.damage_type = DAMAGE_SHOT
tt.bullet.min_speed = 40 * FPS
tt.bullet.max_speed = 40 * FPS
tt.bullet.hit_blood_fx = "fx_blood_splat"
tt.bullet.miss_fx = "fx_smoke_bullet"
tt.bullet.miss_fx_water = "fx_splash_small"
tt.sound_events.insert = "ShotgunSound"
tt.bullet.xp_gain_factor = 3
tt.bullet.pop = nil
tt = RT("van_helsing_silverbullet", "van_helsing_shotgun")
tt.bullet.damage_type = bor(DAMAGE_TRUE, DAMAGE_FX_EXPLODE)
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.sound_events.insert = "SniperSound"
tt.bullet.xp_gain_factor = nil
tt = RT("van_helsing_grenade", "bullet")
tt.bullet.damage_radius = 80
tt.bullet.flight_time = fts(25)
tt.bullet.hide_radius = 4
tt.bullet.hit_fx = "van_helsing_grenade_explosion"
tt.bullet.mod = "mod_van_helsing_silence"
tt.bullet.rotation_speed = 20 * FPS * math.pi / 180
tt.main_script.insert = scripts.bomb.insert
tt.main_script.update = van_helsing_grenade_update
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "Halloween_hero_vhelsing_water"
tt = RT("mod_van_helsing_silence", "modifier")

AC(tt, "render")

tt.modifier.bans = {"mod_shaman_armor", "mod_shaman_magic_armor", "mod_shaman_priest_heal"}
tt.modifier.remove_banned = true
tt.main_script.insert = scripts.mod_silence.insert
tt.main_script.remove = scripts.mod_silence.remove
tt.main_script.update = scripts.mod_track_target.update
tt.render.sprites[1].prefix = "vanhelsing_silence"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.render.sprites[1].name = "small"
tt.render.sprites[1].sort_y_offset = -2
tt = RT("van_helsing_grenade_explosion", "fx")

AC(tt, "sound_events")

tt.render.sprites[1].name = "vanhelsing_grenade_explosion"
tt.render.sprites[1].sort_y_offset = -4
tt.render.sprites[1].anchor.y = 0.25
tt.render.sprites[1].z = Z_OBJECTS
tt.sound_events.insert = "HeroVanHelsingHolyWater"
tt = RT("mod_van_helsing_relic", "modifier")

AC(tt, "render")

tt.render.sprites[1].name = "vanhelsing_relic"
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[1].anchor.y = 0
tt.main_script.update = mod_van_helsing_relic_update
tt.remove_mods = {"mod_shaman_magic_armor", "mod_shaman_armor"}
tt = RT("van_helsing_beacon_aura", "aura")
tt.aura.mod = "mod_van_helsing_beacon"
tt.aura.duration = -1
tt.aura.radius = 150
tt.aura.track_source = true
tt.aura.track_dead = true
tt.aura.filter_source = false
tt.aura.vis_bans = bor(F_ENEMY)
tt.aura.vis_flags = F_MOD
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
