local bit = require("bit")
local E = require("entity_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")
local log = require("lib.klua.log"):new("hero_ingvar")
local scripts = require("scripts")

require("all.constants")

local bor = bit.bor
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local anchor_y = 0.19
local image_y = 116

local function ady(v)
	return v - anchor_y * image_y
end

local function get_info(this)
	local info = scripts.soldier_barrack.get_info(this)

	if this.is_bear then
		info.ranged_damage_max = nil
		info.ranged_damage_min = nil
		info.ranged_damage_type = nil
		info.damage_min = (this.melee.attacks[3].damage_min + this.unit.damage_buff) * this.unit.damage_factor
		info.damage_max = (this.melee.attacks[3].damage_max + this.unit.damage_buff) * this.unit.damage_factor
		info.damage_type = this.melee.attacks[3].damage_type
	end

	return info
end

local function level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
	this.melee.attacks[2].damage_min = ls.melee_damage_min[hl] * this.melee.attacks[2].damage_factor
	this.melee.attacks[2].damage_max = ls.melee_damage_max[hl] * this.melee.attacks[2].damage_factor

	upgrade_skill(this, "ancestors_call", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.count = s.count[s.level]

		local e = E:get_template(a.entity)

		e.health.hp_max = s.hp_max[s.level]
		e.melee.attacks[1].damage_min = s.damage_min[s.level]
		e.melee.attacks[1].damage_max = s.damage_max[s.level]

		U.update_max_speed(e, s.max_speed[s.level])
	end)
	upgrade_skill(this, "bear", function(this, s)
		local a = this.timed_attacks.list[2]

		a.duration = s.duration[s.level]
		a.disabled = nil

		local a = this.melee.attacks[3]

		a.damage_min = s.damage_min[s.level]
		a.damage_max = s.damage_max[s.level]
	end)
	update_hp(this)
end

local function update(this, store)
	local h = this.health
	local ba = this.timed_attacks.list[2]
	local a, skill, brk, sta

	local function go_bear()
		this.sound_events.change_rally_point = this.sound_events.change_rally_point_bear

		for i = 1, 2 do
			this.melee.attacks[i].disabled = true
		end

		this.melee.attacks[3].disabled = false
		this.health.immune_to = ba.immune_to

		S:queue(ba.sound)
		U.y_animation_play(this, "toBear", nil, store.tick_ts, 1)

		this.render.sprites[1].prefix = "hero_ingvar_bear"
		ba.ts = store.tick_ts
		this.is_bear = true
	end

	local function go_viking()
		this.sound_events.change_rally_point = this.sound_events.change_rally_point_viking

		for i = 1, 2 do
			this.melee.attacks[i].disabled = false
		end

		this.melee.attacks[3].disabled = true
		this.is_bear = false

		U.y_animation_play(this, "toViking", nil, store.tick_ts, 1)

		this.render.sprites[1].prefix = "hero_ingvar"
		this.health.immune_to = DAMAGE_NONE
		ba.ts = store.tick_ts
	end

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			if this.is_bear then
				go_viking()
			end

			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_67_0
				end
			end

			if SU.hero_level_up(store, this) and not this.is_bear then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = ba
			skill = this.hero.skills.bear

			if not this.is_bear and ready_to_use_skill(a, store, this.unit.cooldown_factor) and this.health.hp < this.health.hp_max * a.transform_health_factor then
				SU.hero_gain_xp_from_skill(this, skill)
				go_bear()
			elseif this.is_bear and store.tick_ts - a.ts >= a.duration then
				go_viking()
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.ancestors_call

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				if this.is_bear then
					local compensation = ba.duration - (store.tick_ts - ba.ts)

					go_viking()

					ba.ts = ba.ts - compensation
				end

				local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, nil, NF_RALLY)

				if #nodes < 1 then
					a.ts = a.ts + 0.4
				else
					U.animation_start_default(this, a.animation, nil, store.tick_ts, false)
					S:queue(a.sound, a.sound_args)

					if SU.y_soldier_wait(store, this, a.cast_time) then
						goto label_67_0
					end

					SU.hero_gain_xp_from_skill(this, skill)

					a.ts = store.tick_ts

					local pi, _, ni = unpack(nodes[1])
					local no_min, no_max = unpack(a.nodes_offset)
					local no

					for i = 1, a.count do
						local e = E:create_entity(a.entity)
						local e_spi, e_ni = math.random(1, 3), ni

						no = math.random(no_min, no_max) * U.random_sign()

						if P:is_node_valid(pi, e_ni + no) then
							e_ni = e_ni + no
						end

						e.nav_rally.center = P:node_pos(pi, e_spi, e_ni)
						e.nav_rally.pos = V.vclone(e.nav_rally.center)
						e.pos = V.vclone(e.nav_rally.center)
						e.render.sprites[1].name = "raise"
						e.owner = this

						simulation:queue_insert_entity(e)
					end

					SU.y_hero_animation_wait(this)

					goto label_67_0
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

		::label_67_0::

		coroutine.yield()
	end
end

local function aura_update(this, store)
	local hero = store.entities[this.aura.source_id]

	if not hero then
		log.error("hero not found for aura_ingvar_bear_regenerate")
		simulation:queue_remove_entity(this)

		return
	end

	this.aura.ts = store.tick_ts

	while true do
		if not hero.is_bear or hero.health.dead then
		-- block empty
		elseif store.tick_ts - this.aura.ts >= this.regen.cooldown then
			this.aura.ts = store.tick_ts

			U.heal(hero, this.regen.health)
		end

		coroutine.yield()
	end
end

local tt

tt = RT("hero_ingvar", "hero")

AC(tt, "melee", "timed_attacks", "auras")

tt.hero.level_stats.armor = {0.13, 0.16, 0.19, 0.22, 0.25, 0.28, 0.31, 0.34, 0.37, 0.4}
tt.hero.level_stats.hp_max = {430, 460, 490, 520, 550, 580, 610, 640, 670, 670}
tt.hero.level_stats.melee_damage_max = {45, 49, 54, 58, 63, 67, 72, 76, 81, 85}
tt.hero.level_stats.melee_damage_min = {27, 30, 32, 34, 38, 40, 43, 45, 49, 51}
tt.hero.skills.ancestors_call = CC("hero_skill")
tt.hero.skills.ancestors_call.count = {1, 2, 3, 4}
tt.hero.skills.ancestors_call.hp_max = {150, 200, 250, 300}
tt.hero.skills.ancestors_call.damage_min = {2, 4, 6, 8}
tt.hero.skills.ancestors_call.damage_max = {6, 8, 10, 12}
tt.hero.skills.ancestors_call.max_speed = {69, 72, 75, 78}
tt.hero.skills.ancestors_call.xp_level_steps = {
	[2] = 1,
	[4] = 2,
	[6] = 3,
	[8] = 4
}
tt.hero.skills.ancestors_call.xp_gain = {100, 200, 300, 350}
tt.hero.skills.bear = CC("hero_skill")
tt.hero.skills.bear.damage_min = {24, 42, 60}
tt.hero.skills.bear.damage_max = {50, 66, 86}
tt.hero.skills.bear.duration = {10, 12, 14}
tt.hero.skills.bear.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.hero.skills.bear.xp_gain = {100, 200, 300}
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "aura_ingvar_bear_regenerate"
tt.auras.list[1].cooldown = 0
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, ady(68))
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = level_up
tt.hero.tombstone_show_time = fts(60)
tt.info.hero_portrait = "hero_portraits_0009"
tt.info.fn = get_info
tt.info.portrait = "info_portraits_heroes_0009"
tt.main_script.update = update
tt.motion.max_speed = 3.2 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = vec_2(0.5, 0.19)
tt.render.sprites[1].prefix = "hero_ingvar"
tt.soldier.melee_slot_offset = vec_2(14, 0)
tt.sound_events.change_rally_point = "HeroVikingTaunt"
tt.sound_events.change_rally_point_viking = "HeroVikingTaunt"
tt.sound_events.change_rally_point_bear = "HeroVikingBearTransform"
tt.sound_events.death = "HeroVikingDeath"
tt.sound_events.hero_room_select = "HeroVikingTauntSelect"
tt.sound_events.insert = "HeroVikingTauntIntro"
tt.sound_events.respawn = "HeroVikingTauntIntro"
tt.unit.mod_offset = vec_2(0, 20)
tt.unit.hit_offset = vec_2(0, 20)
tt.melee.range = 83.2
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].sound_hit = "HeroVikingAttackHit"
tt.melee.attacks[1].hit_decal = "decal_ingvar_attack"
tt.melee.attacks[1].hit_offset = vec_2(48, -1)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].xp_gain_factor = 1.2
tt.melee.attacks[2] = CC("area_attack")
tt.melee.attacks[2].cooldown = 1
tt.melee.attacks[2].sound_hit = "HeroVikingAttackHit"
tt.melee.attacks[2].hit_decal = "decal_ingvar_attack"
tt.melee.attacks[2].shared_cooldown = true
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].chance = 0.4
tt.melee.attacks[2].xp_gain_factor = 1.6
tt.melee.attacks[2].damage_factor = 1.2
tt.melee.attacks[2].hit_time = fts(15)
tt.melee.attacks[2].hit_offset = vec_2(0, 2)
tt.melee.attacks[2].damage_radius = 70
tt.melee.attacks[2].damage_type = DAMAGE_RUDE
tt.melee.attacks[3] = CC("melee_attack")
tt.melee.attacks[3].animations = {nil, "attack"}
tt.melee.attacks[3].cooldown = 3
tt.melee.attacks[3].disabled = true
tt.melee.attacks[3].damage_min = nil
tt.melee.attacks[3].damage_max = nil
tt.melee.attacks[3].hit_times = {fts(10), fts(25), fts(41)}
tt.melee.attacks[3].loopable = true
tt.melee.attacks[3].loops = 1
tt.melee.attacks[3].sound_hit = "HeroVikingAttackHit"
tt.melee.attacks[3].sound = "HeroVikingBearAttackStart"
tt.melee.attacks[3].vis_flags = F_BLOCK
tt.melee.attacks[3].xp_gain_factor = 2
tt.timed_attacks.list[1] = CC("spawn_attack")
tt.timed_attacks.list[1].animation = "ancestors"
tt.timed_attacks.list[1].cooldown = 12
tt.timed_attacks.list[1].cast_time = fts(15)
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].entity = "soldier_ingvar_ancestor"
tt.timed_attacks.list[1].sound = "HeroVikingCall"
tt.timed_attacks.list[1].sound_args = {
	delay = fts(5)
}
tt.timed_attacks.list[1].nodes_offset = {4, 8}
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].cooldown = 10
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].transform_health_factor = 0.5
tt.timed_attacks.list[2].immune_to = DAMAGE_BASE_TYPES
tt.timed_attacks.list[2].sound = "HeroVikingBearTransform"
tt = RT("soldier_ingvar_ancestor", "soldier_militia")

AC(tt, "reinforcement", "nav_grid")

tt.controable = true
tt.controable_other = true
tt.health.armor = 0.25
tt.health.hp_max = nil
tt.health_bar.offset = vec_2(0, 46)
tt.health.dead_lifetime = fts(30)
tt.info.portrait = "info_portraits_soldiers_0023"
tt.info.random_name_format = nil
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.soldier_reinforcement.update
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.range = 128
tt.motion.max_speed = 69
tt.reinforcement.duration = 14
tt.reinforcement.fade = nil
tt.render.sprites[1].prefix = "soldier_ingvar_ancestor"
tt.ui.click_rect = r(-13, 0, 26, 30)
tt.unit.mod_offset = vec_2(0, 15)
tt.vis.bans = bor(F_LYCAN, F_SKELETON, F_CANNIBALIZE)
tt = RT("aura_ingvar_bear_regenerate", "aura")

AC(tt, "regen")

tt.main_script.update = aura_update
tt.regen.cooldown = 1
tt.regen.health = 5
tt = RT("decal_ingvar_attack", "decal_tween")
tt.render.sprites[1].name = "hero_viking_axeDecal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 200}, {1, 200}, {1.5, 0}}
