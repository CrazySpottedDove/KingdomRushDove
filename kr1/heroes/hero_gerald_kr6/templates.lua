local bit = require("bit")
local signal = require("lib.hump.signal")
local E = require("entity_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")

require("all.constants")
require("lib.klua.table")

local band = bit.band
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local queue_damage = U.queue_damage
local fts = U.fts

local function mod_gerald_kr6_courage_insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead then
		return false
	end

	if band(this.modifier.vis_flags, target.vis.bans) ~= 0 or band(this.modifier.vis_bans, target.vis.flags) ~= 0 then
		return false
	end

	SU.armor_inc(target, this.armor_inc)
	SU.magic_armor_inc(target, this.armor_inc)
	signal.emit("mod-applied", this, target)

	return true
end

local function mod_gerald_kr6_courage_update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target then
		simulation:queue_remove_entity(this)

		return
	end

	this.pos = target.pos

	local fx = E:create_entity(this.fx)

	fx.pos = V.vclone(this.pos)
	fx.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(fx)
	U.y_animation_play(this, "start", nil, store.tick_ts, 1)
	U.animation_start(this, "idle", nil, store.tick_ts, true)

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead or store.tick_ts - m.ts >= m.duration then
			U.y_animation_play(this, "end", nil, store.tick_ts, 1)
			simulation:queue_remove_entity(this)

			return
		end

		coroutine.yield()
	end
end

local function mod_gerald_kr6_courage_remove(this, store)
	local target = store.entities[this.modifier.target_id]

	if target then
		SU.armor_dec(target, this.armor_inc)
		SU.magic_armor_dec(target, this.armor_inc)
	end

	return true
end

local function mod_gerald_kr6_shield_insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead then
		return false
	end

	if band(this.modifier.vis_flags, target.vis.bans) ~= 0 or band(this.modifier.vis_bans, target.vis.flags) ~= 0 then
		return false
	end

	SU.armor_inc(target, this.armor_inc)
	SU.magic_armor_inc(target, this.armor_inc)
	SU.spiked_armor_inc(target, this.spiked_armor)
	signal.emit("mod-applied", this, target)

	return true
end

local function mod_gerald_kr6_shield_update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target then
		simulation:queue_remove_entity(this)

		return
	end

	this.pos = target.pos

	U.y_animation_play(this, "start", nil, store.tick_ts, 1)
	U.animation_start(this, "loop", nil, store.tick_ts, true)

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead or store.tick_ts - m.ts >= m.duration then
			this.tween.disabled = false
			this.tween.ts = store.tick_ts

			return
		end

		coroutine.yield()
	end
end

local function mod_gerald_kr6_shield_remove(this, store)
	local target = store.entities[this.modifier.target_id]

	if target then
		SU.armor_dec(target, this.armor_inc)
		SU.magic_armor_dec(target, this.armor_inc)
		SU.spiked_armor_dec(target, this.spiked_armor)
	end

	return true
end

local function hero_gerald_kr6_level_up(this, store)
	if this.hero.level > 1 then
		S:queue(this.sound_events.level_up)
	end

	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
	this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

	upgrade_skill(this, "inspire_courage", function(this, s)
		this.timed_attacks.list[1].disabled = nil
	end)
	upgrade_skill(this, "shield_of_retribution", function(this, s)
		this.timed_attacks.list[2].disabled = nil
		this.timed_attacks.list[2].cooldown = s.cooldown[s.level]
	end)
	upgrade_skill(this, "fated_survivor", function(this, s)
		this.timed_attacks.list[3].disabled = nil
		this.timed_attacks.list[3].cooldown = s.cooldown[s.level]
		this.timed_attacks.list[3].hp_ptg = s.hp_ptg[s.level]
	end)
	upgrade_skill(this, "hardened_steel", function(this, s)
		this.dodge.chance = s.chance
	end)
	upgrade_skill(this, "divine_blade", function(this, s)
		this.timed_attacks.list[4].disabled = nil
	end)
	upgrade_skill(this, "battle_vigor", function(this, s)
		this.hero.skills.battle_vigor.ts = store.tick_ts
	end)
	update_hp(this)
end

local function hero_gerald_kr6_update(this, store)
	local h = this.health
	local skills = this.hero.skills
	local inspire = this.timed_attacks.list[1]
	local shield = this.timed_attacks.list[2]
	local fated = this.timed_attacks.list[3]
	local ultimate = this.timed_attacks.list[4]
	local brk, sta

	U.y_animation_play(this, "level_up", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	local cdf = this.unit.cooldown_factor or 1

	inspire.ts = store.tick_ts - inspire.cooldown * cdf
	shield.ts = store.tick_ts - shield.cooldown * cdf
	fated.ts = store.tick_ts - fated.cooldown * cdf
	ultimate.ts = store.tick_ts - ultimate.cooldown * cdf

	while true do
		if h.dead then
			if ready_to_use_skill(fated, store, this.unit.cooldown_factor) then
				h.ignore_damage = true

				fated.ts = store.tick_ts

				U.animation_start(this, "fated_survivor", nil, store.tick_ts, false)
				S:queue(fated.sound)
				SU.y_hero_wait(store, this, fated.cast_time)

				local decal = E:create_entity(fated.decal)

				decal.pos = V.vclone(this.pos)
				decal.render.sprites[1].ts = store.tick_ts

				simulation:queue_insert_entity(decal)

				local attacker = this.soldier.target_id and store.entities[this.soldier.target_id]

				if attacker and not attacker.health.dead and band(attacker.vis.flags, fated.vis_bans) == 0 and band(attacker.vis.bans, fated.vis_flags) == 0 then
					local mod = E:create_entity(fated.mod)

					mod.modifier.target_id = attacker.id
					mod.modifier.source_id = this.id

					simulation:queue_insert_entity(mod)
				end

				SU.hero_gain_xp_from_skill(this, skills.fated_survivor)

				h.dead = false
				h.hp = h.hp_max * fated.hp_ptg
				h.ignore_damage = false
				this.health_bar.hidden = false
				this.ui.can_click = true
				this.force_respawn = nil
				this.health.death_finished_ts = nil

				SU.y_hero_animation_wait(this)
			else
				SU.y_hero_death_and_respawn(store, this)
			end
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					break
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "level_up", nil, store.tick_ts, 1)
			end

			if skills.battle_vigor.level > 0 and store.tick_ts - (skills.battle_vigor.ts or 0) >= 1 then
				skills.battle_vigor.ts = store.tick_ts
				U.heal(this, h.hp_max * skills.battle_vigor.regen_ptg)
			end

			if ready_to_use_skill(ultimate, store, this.unit.cooldown_factor) and this.soldier.target_id and this.motion.arrived then
				local target = store.entities[this.soldier.target_id]

				if target and not target.health.dead then
					local start_ts = store.tick_ts

					U.animation_start(this, ultimate.animation, nil, store.tick_ts, false)
					S:queue(ultimate.sound_cast)
					S:queue(ultimate.sound_taunt)

					if SU.y_hero_wait(store, this, fts(16)) then
						goto continue
					end

					local enemies = U.find_enemies_in_range(store, this.pos, 0, ultimate.initial_stun_radius, ultimate.vis_flags, F_BOSS) or {}

					if not table.contains(enemies, target) then
						table.insert(enemies, 1, target)
					end

					for _, enemy in ipairs(enemies) do
						local mod = E:create_entity(ultimate.mod_initial_stun)

						mod.modifier.source_id = this.id
						mod.modifier.target_id = enemy.id

						simulation:queue_insert_entity(mod)
					end

					S:queue(ultimate.sound_hit)

					local hit_start_ts = store.tick_ts

					while store.tick_ts - hit_start_ts < ultimate.hit_time - fts(16) do
						if SU.soldier_interrupted(this) then
							goto continue
						end

						coroutine.yield()
					end

					ultimate.ts = start_ts

					local d = E:create_entity("damage")

					d.source_id = this.id
					d.target_id = target.id
					d.damage_type = ultimate.damage_type
					d.value = math.ceil((math.random(ultimate.damage_min, ultimate.damage_max) + this.unit.damage_buff) * this.unit.damage_factor)

					queue_damage(store, d)

					local mod = E:create_entity(ultimate.mod_hit_stun)

					mod.modifier.source_id = this.id
					mod.modifier.target_id = target.id

					simulation:queue_insert_entity(mod)

					local hit_pos = V.vclone(this.pos)

					hit_pos.x = hit_pos.x + (this.render.sprites[1].flip_x and -1 or 1) * ultimate.hit_offset.x
					hit_pos.y = hit_pos.y + ultimate.hit_offset.y

					local others = U.find_enemies_in_range(store, hit_pos, 0, ultimate.splash_radius, F_AREA, F_FRIEND) or {}

					for _, enemy in ipairs(others) do
						if enemy.id ~= target.id then
							local splash = E:create_entity("damage")

							splash.source_id = this.id
							splash.target_id = enemy.id
							splash.damage_type = ultimate.damage_type
							splash.value = math.ceil((math.random(ultimate.splash_damage_min, ultimate.splash_damage_max) + this.unit.damage_buff) * this.unit.damage_factor)

							queue_damage(store, splash)

							local stun = E:create_entity(ultimate.mod_hit_stun)

							stun.modifier.source_id = this.id
							stun.modifier.target_id = enemy.id

							simulation:queue_insert_entity(stun)
						end
					end

					local decal = E:create_entity(ultimate.hit_decal)

					decal.pos = V.vclone(this.pos)

					for i = 1, #decal.render.sprites do
						decal.render.sprites[i].ts = store.tick_ts
						decal.render.sprites[i].flip_x = this.render.sprites[i].flip_x
					end

					simulation:queue_insert_entity(decal)
					SU.hero_gain_xp_from_skill(this, skills.divine_blade)
					SU.y_hero_animation_wait(this)
					U.animation_start(this, "idle", nil, store.tick_ts, true)

					goto continue
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
				if ready_to_use_skill(shield, store, this.unit.cooldown_factor) and this.soldier.target_id and this.motion.arrived then
					local target = store.entities[this.soldier.target_id]

					if target and not target.health.dead then
						local start_ts = store.tick_ts

						U.animation_start(this, shield.animation, nil, store.tick_ts, false)
						S:queue(shield.sound)

						if SU.y_hero_wait(store, this, shield.cast_time) then
							goto continue
						end

						shield.ts = start_ts

						SU.hero_gain_xp_from_skill(this, skills.shield_of_retribution)

						local mod = E:create_entity(shield.mod)

						mod.modifier.source_id = this.id
						mod.modifier.target_id = this.id
						mod.armor_inc = skills.shield_of_retribution.armor_inc[skills.shield_of_retribution.level]
						mod.spiked_armor = skills.shield_of_retribution.spiked_armor[skills.shield_of_retribution.level]

						simulation:queue_insert_entity(mod)
						SU.y_hero_animation_wait(this)
						U.animation_start(this, "idle", nil, store.tick_ts, true)
					end
				end
			else
				if ready_to_use_skill(inspire, store, this.unit.cooldown_factor) then
					local soldiers = U.find_soldiers_in_range(store.soldiers, this.pos, inspire.min_range, inspire.max_range, inspire.vis_flags, inspire.vis_bans, function(s)
						return s.soldier.target_id ~= nil
					end)

					if not soldiers or #soldiers < inspire.min_targets then
						inspire.ts = inspire.ts + fts(10)
					else
						local start_ts = store.tick_ts

						U.animation_start(this, inspire.animation, nil, store.tick_ts, false)
						S:queue(inspire.sound)

						if SU.y_hero_wait(store, this, inspire.cast_time) then
							goto continue
						end

						inspire.ts = start_ts

						SU.hero_gain_xp_from_skill(this, skills.inspire_courage)

						local decal = E:create_entity(inspire.decal)

						decal.pos = V.vclone(this.pos)
						decal.render.sprites[1].ts = store.tick_ts

						simulation:queue_insert_entity(decal)

						for _, soldier in ipairs(soldiers) do
							local mod = E:create_entity(inspire.mod)

							mod.modifier.source_id = this.id
							mod.modifier.target_id = soldier.id
							mod.armor_inc = skills.inspire_courage.armor_inc
							mod.modifier.duration = skills.inspire_courage.duration[skills.inspire_courage.level]

							simulation:queue_insert_entity(mod)
						end

						SU.y_hero_animation_wait(this)
						U.animation_start(this, "idle", nil, store.tick_ts, true)

						goto continue
					end
				end

				if SU.soldier_go_back_step(store, this) then
				-- block empty
				else
					SU.soldier_idle(store, this)
					SU.soldier_regen(store, this)
				end
			end

			::continue::

			coroutine.yield()
		end
	end
end

local tt

tt = RT("hero_gerald_kr6", "hero")
AC(tt, "melee", "timed_attacks", "dodge")
tt.hero.level_stats.armor = {0.23, 0.26, 0.29, 0.32, 0.35, 0.38, 0.41, 0.44, 0.47, 0.5}
tt.hero.level_stats.hp_max = {240, 260, 280, 300, 320, 340, 360, 380, 400, 450}
tt.hero.level_stats.melee_damage_min = {14, 16, 18, 19, 21, 22, 24, 26, 28, 30}
tt.hero.level_stats.melee_damage_max = {22, 24, 26, 29, 31, 34, 36, 39, 41, 44}
tt.hero.skills.inspire_courage = CC("hero_skill")
tt.hero.skills.inspire_courage.armor_inc = 0.4
tt.hero.skills.inspire_courage.duration = {5, 7.5, 10}
tt.hero.skills.inspire_courage.xp_gain = {64, 128, 192}
tt.hero.skills.inspire_courage.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.shield_of_retribution = CC("hero_skill")
tt.hero.skills.shield_of_retribution.armor_inc = {0.4, 0.4, 0.4}
tt.hero.skills.shield_of_retribution.spiked_armor = {0.5, 1, 1.5}
tt.hero.skills.shield_of_retribution.cooldown = {20, 20, 20}
tt.hero.skills.shield_of_retribution.xp_gain = {96, 192, 288}
tt.hero.skills.shield_of_retribution.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.fated_survivor = CC("hero_skill")
tt.hero.skills.fated_survivor.cooldown = {40, 40, 40}
tt.hero.skills.fated_survivor.hp_ptg = {0.4, 0.7, 1}
tt.hero.skills.fated_survivor.xp_gain = {200, 400, 600}
tt.hero.skills.fated_survivor.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.hero.skills.divine_blade = CC("hero_skill")
tt.hero.skills.divine_blade.xp_gain = {100}
tt.hero.skills.divine_blade.xp_level_steps = {
	[5] = 1
}
tt.hero.skills.hardened_steel = CC("hero_skill")
tt.hero.skills.hardened_steel.chance = 0.35
tt.hero.skills.hardened_steel.xp_level_steps = {
	[1] = 1
}
tt.hero.skills.battle_vigor = CC("hero_skill")
tt.hero.skills.battle_vigor.regen_ptg = 0.03
tt.hero.skills.battle_vigor.xp_level_steps = {
	[1] = 1
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, 39)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_gerald_kr6_level_up
tt.hero.respawn_animation = "level_up"
tt.hero.tombstone_show_time = fts(90)
tt.info.hero_portrait = "kr6_hero_portraits_0001"
tt.info.portrait = "kr6_info_portraits_heroes_0001"
tt.main_script.update = hero_gerald_kr6_update
tt.motion.max_speed = 65
tt.regen.cooldown = 1
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].prefix = "hero_geraldDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].draw_order = DO_HEROES
tt.render.sprites[1].scale = vec_2(1.1, 1.1)
tt.render.sprites[1].fps = 36
tt.sound_events.change_rally_point = "HeroGeraldTaunt"
tt.sound_events.death = "HeroGeraldDeath"
tt.sound_events.insert = "HeroGeraldTauntIntro"
tt.sound_events.level_up = "HeroGeraldTauntLevelUp"
tt.sound_events.respawn = "HeroGeraldTauntIntro"
tt.sound_events.hero_room_select = "HeroGeraldTauntSelect"
tt.soldier.melee_slot_offset = vec_2(15, 0)
tt.ui.click_rect = r(-22, -5, 44, 43)
tt.unit.hit_offset = vec_2(0, 12)
tt.unit.marker_offset = vec_2(0, -1)
tt.unit.mod_offset = vec_2(0, 19.9)
tt.unit.pop_offset = vec_2(0, 15)
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].animation = "attack_1"
tt.melee.attacks[1].cooldown = 1.67
tt.melee.attacks[1].hit_time = fts(12.5)
tt.melee.attacks[1].hit_fx = "fx_gerald_kr6_hit"
tt.melee.attacks[1].hit_offset = vec_2(30, 15)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 2.5
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack_2"
tt.melee.attacks[2].chance = 0.5
tt.melee.attacks[2].hit_time = fts(10)
tt.melee.range = 60
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].animation = "inspire_courage"
tt.timed_attacks.list[1].cast_time = fts(16.666)
tt.timed_attacks.list[1].cooldown = 15
tt.timed_attacks.list[1].decal = "decal_gerald_kr6_courage"
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].max_range = 105
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].min_targets = 1
tt.timed_attacks.list[1].mod = "mod_gerald_kr6_courage"
tt.timed_attacks.list[1].sound = "HeroGeraldInspireCourageCast"
tt.timed_attacks.list[1].vis_bans = bor(F_ENEMY)
tt.timed_attacks.list[1].vis_flags = bor(F_AREA)
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].animation = "shield_of_retribution"
tt.timed_attacks.list[2].cast_time = fts(14.167)
tt.timed_attacks.list[2].cooldown = 24
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].mod = "mod_gerald_kr6_shield"
tt.timed_attacks.list[2].sound = "HeroGeraldShieldOfRetributionCast"
tt.timed_attacks.list[3] = CC("custom_attack")
tt.timed_attacks.list[3].animation = "fated_survivor"
tt.timed_attacks.list[3].cast_time = fts(50)
tt.timed_attacks.list[3].cooldown = 50
tt.timed_attacks.list[3].decal = "decal_gerald_kr6_fated"
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].hp_ptg = 0.4
tt.timed_attacks.list[3].mod = "mod_gerald_kr6_teleport"
tt.timed_attacks.list[3].sound = "HeroGeraldFatedSurvivorCast"
tt.timed_attacks.list[3].vis_bans = F_BOSS
tt.timed_attacks.list[3].vis_flags = F_TELEPORT
tt.timed_attacks.list[4] = CC("custom_attack")
tt.timed_attacks.list[4].animation = "ultimate"
tt.timed_attacks.list[4].cooldown = 25
tt.timed_attacks.list[4].damage_min = 500
tt.timed_attacks.list[4].damage_max = 500
tt.timed_attacks.list[4].damage_type = DAMAGE_TRUE
tt.timed_attacks.list[4].disabled = true
tt.timed_attacks.list[4].hit_decal = "decal_gerald_kr6_ultimate"
tt.timed_attacks.list[4].hit_offset = vec_2(20, 5)
tt.timed_attacks.list[4].hit_time = fts(50)
tt.timed_attacks.list[4].initial_stun_radius = 60
tt.timed_attacks.list[4].mod_hit_stun = "mod_gerald_kr6_ultimate_hit_stun"
tt.timed_attacks.list[4].mod_initial_stun = "mod_gerald_kr6_ultimate_initial_stun"
tt.timed_attacks.list[4].shared_cooldown = true
tt.timed_attacks.list[4].sound_cast = "HeroGeraldDivineBladeCast"
tt.timed_attacks.list[4].sound_hit = "HeroDivineBladeImpact"
tt.timed_attacks.list[4].sound_taunt = "HeroGeraldTauntUltimate"
tt.timed_attacks.list[4].splash_damage_min = 250
tt.timed_attacks.list[4].splash_damage_max = 250
tt.timed_attacks.list[4].splash_radius = 50
tt.timed_attacks.list[4].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[4].vis_flags = bor(F_AREA)
tt.dodge.chance = 0
tt.dodge.ranged = true
tt.dodge.silent = true

tt = RT("mod_gerald_kr6_courage", "modifier")
AC(tt, "render")
tt.armor_inc = 0.4
tt.fx = "fx_gerald_kr6_courage"
tt.main_script.insert = mod_gerald_kr6_courage_insert
tt.main_script.remove = mod_gerald_kr6_courage_remove
tt.main_script.update = mod_gerald_kr6_courage_update
tt.modifier.duration = 4
tt.modifier.use_mod_offset = false
tt.modifier.vis_bans = 0
tt.modifier.vis_flags = bor(F_MOD)
tt.render.sprites[1].prefix = "hero_gerald_inspire_courage_buff_decalDef"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS

tt = RT("mod_gerald_kr6_shield", "modifier")
AC(tt, "render", "tween")
tt.armor_inc = 0.3
tt.main_script.insert = mod_gerald_kr6_shield_insert
tt.main_script.remove = mod_gerald_kr6_shield_remove
tt.main_script.update = mod_gerald_kr6_shield_update
tt.modifier.duration = 8
tt.modifier.use_mod_offset = false
tt.modifier.vis_bans = 0
tt.modifier.vis_flags = bor(F_MOD)
tt.render.sprites[1].prefix = "hero_gerald_shield_of_retribution_fxDef"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].exo = true
tt.spiked_armor = 0.3
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {1, 0}}
tt.tween.remove = true

tt = RT("mod_gerald_kr6_teleport", "mod_teleport")

tt.delay_end = fts(3)
tt.delay_start = fts(3)
tt.fx_end = "fx_gerald_kr6_teleport"
tt.fx_start = "fx_gerald_kr6_teleport"
tt.hold_time = fts(50)
tt.max_times_applied = 5
tt.modifier.allows_duplicates = false
tt.modifier.duration = 1
tt.modifier.vis_bans = bor(F_BOSS)
tt.modifier.vis_flags = bor(F_MOD)
tt.nodes_offset = -30

tt = RT("mod_gerald_kr6_ultimate_initial_stun", "mod_stun")
tt.modifier.duration = 0.5
tt.modifier.vis_bans = bor(F_BOSS)
tt.modifier.vis_flags = bor(F_MOD, F_STUN)

tt = RT("mod_gerald_kr6_ultimate_hit_stun", "mod_stun")
tt.modifier.duration = 1
tt.modifier.vis_bans = bor(F_BOSS)
tt.modifier.vis_flags = bor(F_MOD, F_STUN)

tt = RT("fx_gerald_kr6_hit", "fx")
tt.render.sprites[1].prefix = "hero_gerald_hit_fxDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true

tt = RT("fx_gerald_kr6_courage", "fx")
tt.render.sprites[1].prefix = "hero_gerald_inspire_courage_buff_fxDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true

tt = RT("fx_gerald_kr6_teleport", "fx")
tt.render.sprites[1].offset = vec_2(0, -20)
tt.render.sprites[1].prefix = "hero_gerald_fated_survivor_teleportDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true

tt = RT("decal_gerald_kr6_courage", "decal_timed")
tt.render.sprites[1].prefix = "hero_gerald_inspire_courage_fxDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.timed.runs = 1

tt = RT("decal_gerald_kr6_fated", "decal_timed")
tt.render.sprites[1].prefix = "hero_gerald_fated_survivor_decalDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.timed.runs = 1

tt = RT("decal_gerald_kr6_ultimate", "decal_timed")
tt.render.sprites[1].prefix = "hero_gerald_ultimate_decalDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.timed.runs = 1
