local bit = require("bit")
local signal = require("lib.hump.signal")
local E = require("entity_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")
local scripts = require("game_scripts")

require("all.constants")

local band = bit.band
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local scripts = require("scripts")
local anchor_x, anchor_y = 0, 0
local image_x, image_y

local function adx(v)
	return v - anchor_x * image_x
end

local function ady(v)
	return v - anchor_y * image_y
end

local hero_script = {
	level_up = function(this, store)
		local hl, ls = level_up_basic(this)

		this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
		this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
		this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
		this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

		upgrade_skill(this, "block_counter", function(this, s)
			this.dodge.chance = this.dodge.chance_base + this.dodge.chance_inc * s.level
		end)
		upgrade_skill(this, "courage", function(this, s)
			this.timed_attacks.list[1].disabled = nil
		end)
		upgrade_skill(this, "paladin", function(this, s)
			local a = this.timed_attacks.list[2]

			a.disabled = nil

			local e = E:get_template(a.entity)

			e.health.hp_max = s.hp_max[s.level]
			a = e.melee.attacks[1]
			a.damage_min = s.melee_damage_min[s.level]
			a.damage_max = s.melee_damage_max[s.level]
			a = e.melee.attacks[2]
			a.damage_min = s.melee_damage_min[s.level]
			a.damage_max = s.melee_damage_max[s.level]
			e.motion.max_speed = s.max_speed[s.level]
		end)
		upgrade_skill(this, "holy_strike", function(this, s)
			local a = this.melee.attacks[3]

			a.disabled = nil
			a.damage_min = s.damage_min[s.level]
			a.damage_max = s.damage_max[s.level]
		end)
		update_hp(this)
	end,
	fn_can_dodge = function(store, this, ranged_attack, attack, source)
		if (source and source.vis and band(source.vis.flags, F_BOSS) ~= 0) and math.random() > this.dodge.low_chance_factor then
			return false
		end

		return true
	end,
	update = function(this, store)
		local h = this.health
		local courage = this.timed_attacks.list[1]
		local paladin = this.timed_attacks.list[2]
		local skill, brk, sta

		U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

		this.health_bar.hidden = false

		while true do
			if h.dead then
				SU.y_hero_death_and_respawn(store, this)
			end

			if this.unit.is_stunned then
				SU.soldier_idle(store, this)
			else
				skill = this.hero.skills.block_counter

				if skill.level > 0 and this.dodge and this.dodge.active then
					this.dodge.active = false
					this.dodge.counter_attack_pending = true

					local la = this.dodge.last_attack
					local ca = this.dodge.counter_attack

					if la then
						ca.damage_max = (la.damage_max or 1) * (ca.reflected_damage_factor + ca.reflected_damage_factor_inc * skill.level) * this.unit.damage_factor
						ca.damage_min = (la.damage_min or 1) * (ca.reflected_damage_factor + ca.reflected_damage_factor_inc * skill.level) * this.unit.damage_factor
					end

					SU.hero_gain_xp_from_skill(this, skill)

					goto label_39_0
				end

				while this.nav_rally.new do
					if SU.y_hero_new_rally(store, this) then
						goto label_39_1
					end
				end

				if SU.hero_level_up(store, this) then
					U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
				end

				skill = this.hero.skills.paladin

				if ready_to_use_skill(paladin, store, this.unit.cooldown_factor) then
					local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, nil, NF_RALLY)

					if #nodes < 1 then
						paladin.ts = paladin.ts + 0.4
					else
						U.animation_start_default(this, paladin.animation, nil, store.tick_ts)
						S:queue(paladin.sound)
						SU.hero_gain_xp_from_skill(this, skill)

						paladin.ts = store.tick_ts

						local pi, _, ni = unpack(nodes[1])
						local new_soldier = E:create_entity(paladin.entity)
						local e_spi, e_ni = math.random(1, 3), ni

						new_soldier.nav_rally.center = P:node_pos(pi, e_spi, e_ni)
						new_soldier.nav_rally.pos = V.vclone(new_soldier.nav_rally.center)
						new_soldier.pos = V.vclone(new_soldier.nav_rally.center)
						new_soldier.owner = this

						simulation:queue_insert_entity(new_soldier)
					end

					SU.y_hero_animation_wait(this)

					goto label_39_1
				end

				skill = this.hero.skills.courage

				if ready_to_use_skill(courage, store, this.unit.cooldown_factor) then
					local triggers = U.find_soldiers_in_range(store.soldiers, this.pos, 0, courage.range, courage.vis_flags, courage.vis_bans)

					if not triggers or #triggers < courage.min_count then
						courage.ts = courage.ts + 0.13333333333333333
					else
						local start_ts = store.tick_ts

						S:queue(courage.sound)
						U.animation_start_default(this, courage.animation, nil, store.tick_ts)

						if SU.y_soldier_wait(store, this, courage.shoot_time) then
						-- block empty
						else
							local targets = U.find_soldiers_in_range(store.soldiers, this.pos, 0, courage.range, courage.vis_flags, courage.vis_bans)

							if not targets then
							-- block empty
							else
								courage.ts = start_ts

								SU.hero_gain_xp_from_skill(this, skill)

								for _, e in ipairs(targets) do
									local mod = E:create_entity(courage.mod)

									mod.modifier.target_id = e.id
									mod.modifier.source_id = this.id
									mod.modifier.level = skill.level

									simulation:queue_insert_entity(mod)
								end

								SU.y_hero_animation_wait(this)

								goto label_39_1
							end
						end
					end
				end

				::label_39_0::

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

			::label_39_1::

			coroutine.yield()
		end
	end
}
local courage_script = {}

function courage_script.insert(this, store)
	local m = this.modifier
	local buff = this.courage
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead or not target.unit then
		return false
	end

	local heal = (buff.heal_once_factor + m.level * buff.heal_inc) * target.health.hp_max

	if band(target.vis.flags, F_HERO) ~= 0 then
		SU.magic_armor_inc(target, buff.magic_armor_inc * m.level * 0.5)
		SU.armor_inc(target, buff.armor_inc * m.level * 0.5)
		U.heal(target, heal * 0.5)
		SU.damage_inc(target, buff.damage_inc * m.level + buff.damage_inc_base)
	else
		SU.magic_armor_inc(target, buff.magic_armor_inc * m.level)
		SU.armor_inc(target, buff.armor_inc * m.level)
		U.heal(target, heal)
		SU.damage_inc(target, buff.damage_inc * m.level + buff.damage_inc_base)
	end

	if this.render then
		for _, s in ipairs(this.render.sprites) do
			s.ts = store.tick_ts

			if s.size_names then
				s.name = s.size_names[target.unit.size]
			end
		end
	end

	signal.emit("mod-applied", this, target)

	return true
end

function courage_script.remove(this, store)
	local m = this.modifier
	local buff = this.courage
	local target = store.entities[this.modifier.target_id]

	if target then
		if band(target.vis.flags, F_HERO) ~= 0 then
			SU.magic_armor_dec(target, buff.magic_armor_inc * m.level * 0.5)
			SU.armor_dec(target, buff.armor_inc * m.level * 0.5)
			SU.damage_dec(target, buff.damage_inc * m.level + buff.damage_inc_base)
		else
			SU.magic_armor_dec(target, buff.magic_armor_inc * m.level)
			SU.armor_dec(target, buff.armor_inc * m.level)
			SU.damage_dec(target, buff.damage_inc * m.level + buff.damage_inc_base)
		end
	end

	return true
end

local tt

tt = RT("hero_gerald", "hero")

AC(tt, "melee", "timed_attacks", "dodge")

anchor_y = 0.12
anchor_x = 0.5
image_y = 110
image_x = 92
tt.hero.level_stats.armor = {0.34, 0.38, 0.42, 0.46, 0.50, 0.54, 0.58, 0.62, 0.66, 0.7}
tt.hero.level_stats.hp_max = {400, 425, 450, 475, 500, 525, 550, 575, 600, 625}
tt.hero.level_stats.melee_damage_max = {20, 23, 27, 30, 34, 37, 41, 45, 48, 50}
tt.hero.level_stats.melee_damage_min = {12, 14, 15, 17, 19, 21, 23, 25, 27, 29}
tt.hero.skills.block_counter = CC("hero_skill")
tt.hero.skills.block_counter.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.hero.skills.block_counter.xp_gain = {100, 200, 300}
tt.hero.skills.courage = CC("hero_skill")
tt.hero.skills.courage.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.courage.xp_gain = {60, 120, 180}
tt.hero.skills.paladin = CC("hero_skill")
tt.hero.skills.paladin.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.paladin.xp_gain = {60, 120, 180}
tt.hero.skills.paladin.hp_max = {150, 200, 250}
tt.hero.skills.paladin.melee_damage_min = {6, 8, 10}
tt.hero.skills.paladin.melee_damage_max = {20, 25, 30}
tt.hero.skills.paladin.max_speed = {60, 65, 70}
tt.hero.skills.holy_strike = CC("hero_skill")
tt.hero.skills.holy_strike.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.holy_strike.xp_gain = {80, 160, 240}
tt.hero.skills.holy_strike.damage_min = {36, 72, 108}
tt.hero.skills.holy_strike.damage_max = {60, 120, 180}
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, 36)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_script.level_up
tt.hero.tombstone_show_time = fts(90)
tt.info.hero_portrait = "hero_portraits_0001"
tt.info.portrait = "info_portraits_heroes_0001"
tt.main_script.update = hero_script.update
tt.motion.max_speed = 3 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = vec_2(0.5, 0.12)
tt.render.sprites[1].prefix = "hero_gerald"
tt.soldier.melee_slot_offset = vec_2(5, 0)
tt.sound_events.change_rally_point = "HeroPaladinTaunt"
tt.sound_events.death = "HeroPaladinDeath"
tt.sound_events.hero_room_select = "HeroPaladinTauntSelect"
tt.sound_events.insert = "HeroPaladinTauntIntro"
tt.sound_events.respawn = "HeroPaladinTauntIntro"
tt.unit.mod_offset = vec_2(0, 20)
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].xp_gain_factor = 2
tt.melee.attacks[1].hit_time = fts(5)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].chance = 0.5
tt.melee.attacks[2].xp_gain_factor = 5
tt.melee.attacks[3] = CC("area_attack")
tt.melee.attacks[3].damage_radius = 55
tt.melee.attacks[3].damage_type = DAMAGE_MAGICAL
tt.melee.attacks[3].animation = "strike"
tt.melee.attacks[3].cooldown = 8
tt.melee.attacks[3].hit_decal = "decal_paladin_holystrike"
tt.melee.attacks[3].hit_offset = vec_2(25, 0)
tt.melee.attacks[3].hit_time = fts(27)
tt.melee.attacks[3].mod = "mod_paladin_silence"
tt.melee.attacks[3].vis_flags = F_BLOCK
tt.melee.attacks[3].disabled = true
tt.melee.attacks[3].never_interrupt = true
tt.melee.attacks[3].xp_from_skill = "holy_strike"
tt.melee.range = 65
tt.timed_attacks.list[1] = CC("mod_attack")
tt.timed_attacks.list[1].animation = "courage"
tt.timed_attacks.list[1].cooldown = 6.5 + fts(55)
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].min_count = 2
tt.timed_attacks.list[1].mod = "mod_gerald_courage"
tt.timed_attacks.list[1].range = 120
tt.timed_attacks.list[1].shoot_time = fts(17)
tt.timed_attacks.list[1].sound = "HeroPaladinValor"
tt.timed_attacks.list[1].sound_args = {
	delay = fts(3)
}
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED, F_MOD)
tt.timed_attacks.list[2] = CC("spawn_attack")
tt.timed_attacks.list[2].animation = "levelup"
tt.timed_attacks.list[2].cooldown = 13
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].entity = "soldier_gerald_paladin"
tt.timed_attacks.list[2].sound = "HeroPaladinTauntSelect"
tt.timed_attacks.list[2].min_range = 45
tt.timed_attacks.list[2].max_range = 85
tt.dodge.animation = "counter"
tt.dodge.can_dodge = hero_script.fn_can_dodge
tt.dodge.chance_base = 0.15
tt.dodge.chance_inc = 0.2
tt.dodge.time_before_hit = fts(4)
tt.dodge.low_chance_factor = 0.5
tt.dodge.counter_attack = CC("melee_attack")
tt.dodge.counter_attack.animation = "counter"
tt.dodge.counter_attack.damage_type = DAMAGE_TRUE
tt.dodge.counter_attack.reflected_damage_factor = 0.5
tt.dodge.counter_attack.reflected_damage_factor_inc = 0.5
tt.dodge.counter_attack.hit_time = fts(5)
tt.dodge.counter_attack.sound = "HeroPaladinDeflect"
tt = RT("mod_gerald_courage", "modifier")

AC(tt, "render")

tt.courage = {
	heal_once_factor = 0.12,
	heal_inc = 0.06,
	damage_inc = 5,
	damage_inc_base = 1,
	armor_inc = 0.05,
	magic_armor_inc = 0.05
}
tt.modifier.duration = 6
tt.modifier.use_mod_offset = false
tt.main_script.insert = courage_script.insert
tt.main_script.remove = courage_script.remove
tt.main_script.update = scripts.mod_track_target.update
tt.render.sprites[1].name = "mod_gerald_courage"
tt.render.sprites[1].anchor = vec_2(0.51, 0.17307692307692307)
tt.render.sprites[1].draw_order = 2
tt = RT("soldier_gerald_paladin", "soldier_militia")

AC(tt, "reinforcement", "tween", "nav_grid")

anchor_y = 0.15
anchor_x = 0.5
image_y = 41
image_x = 58
tt.controable = true
tt.controable_other = true
tt.health.armor = 0.4
tt.health.dead_lifetime = 3
tt.health.hp_max = nil
tt.health_bar.offset = vec_2(adx(28), ady(40))
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.soldier_reinforcement.update
tt.info.portrait = "info_portraits_soldiers_0007"
tt.info.random_name_count = 20
tt.info.random_name_format = "SOLDIER_PALADIN_RANDOM_%i_NAME"
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].chance = 0.5
tt.melee.attacks[2].hit_time = fts(6)
tt.melee.cooldown = 1
tt.melee.range = 72.5
tt.motion.max_speed = 60
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "soldier_s6_imperial_guard"
tt.soldier.melee_slot_offset = vec_2(8, 0)
tt.unit.mod_offset = vec_2(adx(27), ady(22))
tt.reinforcement.duration = 14
tt.vis.bans = bor(F_LYCAN, F_SKELETON, F_CANNIBALIZE)
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
tt.tween.props[1].name = "alpha"
tt.tween.remove = false
