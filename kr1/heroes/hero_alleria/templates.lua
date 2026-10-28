local bit = require("bit")
local E = require("entity_db")
local GR = require("grid_db")
local GS = require("kr1.game_settings")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")
local scripts = require("scripts")

require("lib.klua.table")
require("all.constants")

local bor = bit.bor
local anchor_y = 0.28
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp

local function wildcat_level_up(this, store, skill)
	local hp_factor = GS.difficulty_soldier_hp_max_factor[store.level_difficulty]

	this.health.hp_max = skill.hp_base + skill.hp_inc * skill.level * hp_factor

	update_hp(this)

	local at = this.melee.attacks[1]

	at.damage_max = skill.damage_max_base + skill.damage_inc * skill.level
	at.damage_min = skill.damage_min_base + skill.damage_inc * skill.level
end

local function wildcat_get_info(this)
	local min, max = this.melee.attacks[1].damage_min * this.unit.damage_factor, this.melee.attacks[1].damage_max * this.unit.damage_factor

	return {
		type = STATS_TYPE_SOLDIER,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		armor = this.health.armor,
		respawn = this.owner.timed_attacks.list[1].cooldown
	}
end

local function wildcat_insert(this, store)
	this.melee.order = U.attack_order(this.melee.attacks)

	return true
end

local function wildcat_update(this, store)
	local brk, sta

	U.y_animation_play(this, "spawn", nil, store.tick_ts)

	while true do
		if this.health.dead then
			this.owner.timed_attacks.list[1].pet = nil
			this.owner.timed_attacks.list[1].ts = store.tick_ts

			SU.y_soldier_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				this.nav_grid.waypoints = GR:find_waypoints(this.pos, nil, this.nav_rally.pos, this.nav_grid.valid_terrains)

				if SU.y_hero_new_rally(store, this) then
					goto label_35_0
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
				goto label_35_0
			end

			if SU.soldier_go_back_step(store, this) then
			-- block empty
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_35_0::

		coroutine.yield()
	end
end

-- 艾莉瑞亚-分裂箭
local function arrow_multishot_insert(this, store)
	if this.extra_arrows > 0 then
		local _, targets = U.find_foremost_enemy_in_range_filter_off(this.bullet.to, this.extra_arrows_range, nil, F_RANGED, F_NONE)

		if targets then
			local rate

			if #targets > this.extra_arrows then
				rate = this.extra_arrows
			else
				rate = #targets
			end

			this.bullet.flight_time = fts(3 + 3 * rate)

			local j = 1
			local predicted_health = {}

			for i = 1, this.extra_arrows do
				local b = E:clone_entity(this)

				b.extra_arrows = 0

				local t

				if i <= #targets then
					t = targets[i]
				else
					while j < #targets and predicted_health[targets[j].id] <= 0 do
						j = j + 1
					end

					t = targets[j]
					b.bullet.damage_max = b.bullet.damage_max - 20
				end

				b.bullet.target_id = t.id
				b.bullet.to = V.v(t.pos.x + t.unit.hit_offset.x, t.pos.y + t.unit.hit_offset.y)

				local d = SU.create_bullet_damage(b.bullet, t.id, this.id)

				if not predicted_health[t.id] then
					predicted_health[t.id] = t.health.hp
				end

				predicted_health[t.id] = predicted_health[t.id] - U.predict_damage(t, d)

				simulation:queue_insert_entity(b)
			end
		else
			if store.entities[this.bullet.target_id] then
				for i = 1, this.extra_arrows do
					local b = E:clone_entity(this)

					b.extra_arrows = 0
					b.bullet.damage_max = b.bullet.damage_max - 20

					simulation:queue_insert_entity(b)
				end
			end
		end
	end

	return scripts.arrow.insert(this, store)
end

-- 艾莉瑞亚
local function hero_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local bt = E:get_template(this.ranged.attacks[1].bullet)

	bt.bullet.damage_min = ls.ranged_damage_min[hl]
	bt.bullet.damage_max = ls.ranged_damage_max[hl]

	upgrade_skill(this, "multishot", function(this, s)
		local a = this.ranged.attacks[2]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]

		local b = E:get_template(a.bullet)

		b.extra_arrows = s.count_base + s.count_inc * s.level
	end)
	upgrade_skill(this, "callofwild", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil

		if a.pet then
			a.pet.level = s.level

			a.pet.fn_level_up(a.pet, store, s)
		end
	end)
	upgrade_skill(this, "missileshot", function(this, s)
		local a = this.ranged.attacks[3]

		a.disabled = nil

		local b = E:get_template(a.bullet)

		b.bullet.target_num = s.count_base + s.count_inc * s.level
	end)
	update_hp(this)
end

local function hero_update(this, store)
	local h = this.health
	local a, skill, brk, sta

	local function get_wildcat_pos()
		local positions = P:get_all_valid_pos(this.nav_rally.pos.x, this.nav_rally.pos.y, a.min_range, a.max_range, TERRAIN_LAND, nil, NF_RALLY)

		return positions[1]
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
				a = this.timed_attacks.list[1]

				if a.pet then
					local pos = get_wildcat_pos()

					if pos then
						a.pet.nav_rally.center = pos
						a.pet.nav_rally.pos = pos
						a.pet.nav_rally.new = true
					end
				end

				if SU.y_hero_new_rally(store, this) then
					goto label_43_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.callofwild

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				if a.pet then
					a.ts = a.ts + 0.25
				else
					local spawn_pos = get_wildcat_pos()

					if not spawn_pos then
						a.ts = a.ts + 0.25
					else
						S:queue(a.sound)

						this.health.immune_to = F_ALL

						U.animation_start_default(this, a.animation, nil, store.tick_ts)
						U.y_wait_unconditional(store, a.spawn_time)

						local e = E:create_entity(a.entity)

						e.pos = V.vclone(spawn_pos)
						e.nav_rally.pos = V.vclone(spawn_pos)
						e.nav_rally.center = V.vclone(spawn_pos)
						e.render.sprites[1].flip_x = math.random() < 0.5
						e.owner = this

						e.fn_level_up(e, store, skill)
						simulation:queue_insert_entity(e)

						a.pet = e

						U.y_animation_wait_default(this)

						a.ts = store.tick_ts
						this.health.immune_to = 0

						SU.hero_gain_xp_from_skill(this, skill)

						goto label_43_0
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

		::label_43_0::

		coroutine.yield()
	end
end

local tt

tt = RT("hero_alleria", "hero")

AC(tt, "melee", "ranged", "timed_attacks")

tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.hp_max = {200, 220, 240, 260, 280, 300, 320, 350, 380, 410}
tt.hero.level_stats.melee_damage_max = {5, 7, 9, 12, 15, 18, 22, 26, 30, 34}
tt.hero.level_stats.melee_damage_min = {3, 5, 7, 9, 11, 13, 15, 17, 19, 21}
tt.hero.level_stats.ranged_damage_max = {16, 19, 24, 27, 30, 36, 41, 47, 50, 55}
tt.hero.level_stats.ranged_damage_min = {4, 5, 6, 7, 8, 9, 10, 11, 12, 13}
tt.hero.skills.multishot = CC("hero_skill")
tt.hero.skills.multishot.count_base = 0
tt.hero.skills.multishot.count_inc = 2
tt.hero.skills.multishot.cooldown = {3 + fts(29), 2.9 + fts(29), 2.8 + fts(29), 2.7 + fts(29), 2.6 + fts(29)}
tt.hero.skills.multishot.xp_level_steps = {
	[2] = 1,
	[4] = 2,
	[6] = 3,
	[8] = 4,
	[10] = 5
}
tt.hero.skills.multishot.xp_gain = {20, 30, 40, 50, 60}
tt.hero.skills.missileshot = CC("hero_skill")
tt.hero.skills.missileshot.count_base = 2
tt.hero.skills.missileshot.count_inc = 1
tt.hero.skills.missileshot.xp_level_steps = {
	[2] = 1,
	[4] = 2,
	[6] = 3,
	[8] = 4,
	[10] = 5
}
tt.hero.skills.missileshot.xp_gain = {40, 60, 80, 100, 120}
tt.hero.skills.callofwild = CC("hero_skill")
tt.hero.skills.callofwild.damage_max_base = 4
tt.hero.skills.callofwild.damage_min_base = 2
tt.hero.skills.callofwild.damage_inc = 4
tt.hero.skills.callofwild.hp_base = -50
tt.hero.skills.callofwild.hp_inc = 250
tt.hero.skills.callofwild.xp_gain = {35, 70, 100}
tt.hero.skills.callofwild.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, 33)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_level_up
tt.hero.tombstone_show_time = fts(90)
tt.info.hero_portrait = "hero_portraits_0002"
tt.info.portrait = "info_portraits_heroes_0002"
tt.main_script.update = hero_update
tt.motion.max_speed = 4.8 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = vec_2(0.5, 0.14)
tt.render.sprites[1].prefix = "hero_alleria"
tt.soldier.melee_slot_offset = vec_2(4, 0)
tt.sound_events.change_rally_point = "HeroArcherTaunt"
tt.sound_events.death = "HeroArcherDeath"
tt.sound_events.hero_room_select = "HeroArcherTauntSelect"
tt.sound_events.insert = "HeroArcherTauntIntro"
tt.sound_events.respawn = "HeroArcherTauntIntro"
tt.unit.mod_offset = vec_2(0, 15)
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(8)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].xp_gain_factor = 2.5
tt.melee.range = 40
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].bullet = "arrow_hero_alleria"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(0, 12)}
tt.ranged.attacks[1].max_range = 185
tt.ranged.attacks[1].min_range = 40
tt.ranged.attacks[1].shoot_time = fts(5)
tt.ranged.attacks[1].cooldown = 0.4
tt.ranged.attacks[2] = CC("bullet_attack")
tt.ranged.attacks[2].animation = "multishot"
tt.ranged.attacks[2].bullet = "arrow_multishot_hero_alleria"
tt.ranged.attacks[2].bullet_start_offset = {vec_2(0, 12)}
tt.ranged.attacks[2].cooldown = 3 + fts(29)
tt.ranged.attacks[2].disabled = true
tt.ranged.attacks[2].max_range = 200
tt.ranged.attacks[2].min_range = 40
tt.ranged.attacks[2].node_prediction = fts(10)
tt.ranged.attacks[2].shoot_time = fts(12)
tt.ranged.attacks[2].sound = "HeroArcherShoot"
tt.ranged.attacks[2].xp_from_skill = "multishot"
tt.ranged.attacks[3] = CC("bullet_attack")
tt.ranged.attacks[3].animation = "multishot"
tt.ranged.attacks[3].bullet = "arrow_hero_alleria_missile"
tt.ranged.attacks[3].bullet_start_offset = {vec_2(0, 12)}
tt.ranged.attacks[3].cooldown = 8
tt.ranged.attacks[3].disabled = true
tt.ranged.attacks[3].max_range = 200
tt.ranged.attacks[3].min_range = 40
tt.ranged.attacks[3].node_prediction = fts(10)
tt.ranged.attacks[3].shoot_time = fts(12)
tt.ranged.attacks[3].sound = "HeroArcherShoot"
tt.ranged.attacks[3].xp_from_skill = "missileshot"
tt.timed_attacks.list[1] = CC("spawn_attack")
tt.timed_attacks.list[1].animation = "callofwild"
tt.timed_attacks.list[1].cooldown = 12
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].entity = "soldier_alleria_wildcat"
tt.timed_attacks.list[1].sound = "HeroArcherSummon"
tt.timed_attacks.list[1].spawn_time = fts(10)
tt.timed_attacks.list[1].min_range = 30
tt.timed_attacks.list[1].max_range = 50
tt = RT("arrow_hero_alleria", "arrow")
tt.bullet.xp_gain_factor = 2.9
tt.bullet.flight_time = fts(15)
tt = RT("arrow_multishot_hero_alleria", "arrow")
tt.bullet.particles_name = "ps_arrow_multishot_hero_alleria"
tt.bullet.damage_min = 15
tt.bullet.damage_max = 50
tt.bullet.damage_type = DAMAGE_TRUE
tt.extra_arrows_range = 100
tt.extra_arrows = 2
tt.main_script.insert = arrow_multishot_insert
tt.render.sprites[1].name = "hero_archer_arrow"
tt = RT("arrow_hero_alleria_missile", "arrow")
tt.bullet.particles_name = "ps_arrow_hero_alleria_missile"
tt.render.sprites[1].name = "hero_archer_arrow"
tt.bullet.flight_time = fts(10)
tt.bullet.damage_min = 60
tt.bullet.damage_max = 120
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.target_num = 5
tt.bullet.max_seek_angle = math.pi / 3
tt.main_script.update = scripts.arrow_missile.update
tt = RT("ps_arrow_hero_alleria_missile", "ps_arrow_multishot_hero_alleria")
tt.particle_system.particle_lifetime = {0.6, 0.6}
tt.particle_system.scales_y = {0.8, 0.2}
tt.particle_system.scales_x = {1.5, 0.3}
tt.particle_system.emission_rate = 60
tt = RT("soldier_alleria_wildcat", "soldier")

AC(tt, "melee", "nav_grid")

tt.fn_level_up = wildcat_level_up
tt.info.portrait = "info_portraits_soldiers_0022"
tt.health.hp_max = nil
tt.info.fn = wildcat_get_info
tt.main_script.insert = wildcat_insert
tt.main_script.update = wildcat_update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].vis_bans = bor(F_FLYING)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].sound = "HeroArcherWildCatHit"
tt.melee.range = 90
tt.motion.max_speed = 4.8 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].name = "spawn"
tt.render.sprites[1].prefix = "soldier_alleria"
tt.render.sprites[1].angles = {
	walk = {"running"}
}
tt.soldier.melee_slot_offset.x = 5
tt.ui.click_rect = r(-15, -5, 30, 30)
tt.unit.hit_offset = vec_2(0, 12)
tt.unit.mod_offset = vec_2(0, 14)
tt.unit.hide_after_death = true
tt.unit.explode_fx = nil
tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE)
-- 博林
