local bit = require("bit")
local E = require("entity_db")
local S = require("sound_db")
local scripts = require("scripts")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")

require("all.constants")
require("lib.klua.table")

local band = bit.band
local bor = bit.bor
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local queue_damage = U.queue_damage
local fts = U.fts

local THROTTLE_CD = 1

local function apply_delayed_cooldowns(store, attacks)
	for _, a in ipairs(attacks) do
		if a.throttle_cooldown_on_skill_use and a.cooldown and store.tick_ts - a.ts >= a.cooldown then
			a.ts = store.tick_ts - a.cooldown + THROTTLE_CD
		end
	end
end

local function aura_oni_ult_update(this, store)
	local a = this.aura

	a.ts = store.tick_ts

	local last_hit_ts = 0
	local cycles_count = 0

	while true do
		if a.cycles and cycles_count >= a.cycles then
			break
		end

		local source = store.entities[a.source_id]

		if not source or source.health.dead then
			simulation:queue_remove_entity(this)

			return
		end

		if store.tick_ts - last_hit_ts >= a.cycle_time then
			cycles_count = cycles_count + 1
			last_hit_ts = store.tick_ts

			local targets = U.find_enemies_in_range(store, this.pos, 0, a.radius, a.vis_flags, a.vis_bans)

			if targets then
				local buff = source.unit.damage_buff or 0
				local factor = source.unit.damage_factor

				for _, target in ipairs(targets) do
					local d = E.assign_damage(a.damage_type, math.ceil((math.random(a.damage_min, a.damage_max) + buff) * factor), this.id, target.id)

					d.xp_dest_id = a.xp_dest_id
					d.xp_gain_factor = a.xp_gain_factor
					queue_damage(store, d)
				end
			end
		end

		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

local function decal_oni_skill_c_update(this, store)
	local source = store.entities[this.source_id]
	local target = store.entities[this.target_id]

	if not source or not target then
		if source then
			source.end_skill_c = true
		end

		simulation:queue_remove_entity(this)

		return
	end

	U.animation_start(this, this.render.sprites[1].name, this.pos.x > target.pos.x, store.tick_ts, false, 1, true)

	local first = true

	for i, v in ipairs(this.hit_times) do
		U.y_wait(store, v)

		if first then
			first = false

			local mod = E:create_entity(this.mod_stun)

			mod.modifier.source_id = this.source_id
			mod.modifier.target_id = this.target_id
			mod.modifier.duration = fts(26)

			simulation:queue_insert_entity(mod)
			S:queue(this.sound_hit)
		end

		local buff = source.unit.damage_buff or 0
		local factor = source.unit.damage_factor
		local d = E.assign_damage(this.damage_type, math.ceil((math.random(this.damage_min[i], this.damage_max[i]) + buff) * factor), this.source_id, this.target_id)

		queue_damage(store, d)

		local sunder = E:create_entity(this.mod_armor_sunder)

		sunder.modifier.source_id = this.source_id
		sunder.modifier.target_id = this.target_id
		sunder.modifier.armor_red_factor = this.armor_red

		simulation:queue_insert_entity(sunder)

		local fx = E:create_entity(this.hit_fx)

		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].flip_x = this.render.sprites[1].flip_x
		fx.pos.x, fx.pos.y = V.add(this.pos.x, this.pos.y, this.hit_offset.x * (this.render.sprites[1].flip_x and -1 or 1), this.hit_offset.y)

		simulation:queue_insert_entity(fx)
	end

	S:queue(this.sound_out)
	U.y_animation_wait(this)

	source.end_skill_c = true

	simulation:queue_remove_entity(this)
end

local function decal_oni_respawn_update(this, store)
	local oni = store.entities[this.source_id]

	if this.delay then
		U.y_wait(store, this.delay)
	end

	for _, name in ipairs(this.decals) do
		local d = E:create_entity(name)

		d.render.sprites[1].ts = store.tick_ts

		if oni then
			d.render.sprites[1].flip_x = oni.render.sprites[1].flip_x
		end

		d.pos = V.vclone(this.pos)

		simulation:queue_insert_entity(d)
	end

	simulation:queue_remove_entity(this)
end

local function mod_oni_skill_c_armor_sunder_insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.armor <= 0 then
		return false
	end

	SU.armor_dec(target, this.modifier.armor_red_factor)

	return false
end

local function mod_oni_talent_2_lifesteal_insert(this, store)
	local source = store.entities[this.modifier.source_id]

	if source and source.health and store.tick_ts - source.blocking_time_ts >= this.block_time then
		source.health.hp = math.min(source.health.hp_max, source.health.hp + this.heal_hp)
	end

	return false
end

local function fn_can_skill_a(this, store)
	return ready_to_use_skill(this.timed_attacks.list[1], store, this.unit.cooldown_factor)
end

local function fn_can_talent_1(this, store)
	if this.hero.skills.talent_1.disabled then
		return false
	end

	if this.used_skill then
		this.used_skill = false

		return true
	end

	return false
end

local function hero_oni_kr6_level_up(this, store, initial)
	if not initial then
		S:queue(this.sound_events.level_up)
	end

	local hl, ls = level_up_basic(this)
	local t1 = this.hero.skills.talent_1

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
	this.melee.attacks[2].damage_min = ls.melee_damage_min[hl] * t1.damage_factor
	this.melee.attacks[2].damage_max = ls.melee_damage_max[hl] * t1.damage_factor

	upgrade_skill(this, "talent_1", function(this, s)
		s.disabled = nil
	end)

	upgrade_skill(this, "talent_2", function(this, s)
		s.disabled = nil
	end)

	upgrade_skill(this, "skill_a", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		this.melee.attacks[3].disabled = nil
		this.melee.attacks[3].damage_min = s.damage_min[s.level]
		this.melee.attacks[3].damage_max = s.damage_max[s.level]

		if s.level == 1 then
			a.ts = store.tick_ts - a.cooldown * (this.unit.cooldown_factor or 1)
		end
	end)

	upgrade_skill(this, "skill_b", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil

		if s.level == 1 then
			a.ts = store.tick_ts - a.cooldown * (this.unit.cooldown_factor or 1)
		end
	end)

	upgrade_skill(this, "skill_c", function(this, s)
		local a = this.timed_attacks.list[3]

		a.disabled = nil

		if s.level == 1 then
			a.ts = store.tick_ts - a.cooldown * (this.unit.cooldown_factor or 1)
			this.end_skill_c = false
		end
	end)

	upgrade_skill(this, "ultimate", function(this, s)
		local a = this.timed_attacks.list[4]

		a.disabled = nil
		a.ts = store.tick_ts - a.cooldown * (this.unit.cooldown_factor or 1)
	end)

	local t2 = this.hero.skills.talent_2

	if not t2.disabled then
		this.melee.attacks[1].mod = t2.lifesteal_mod_pre .. hl
	end

	update_hp(this)
end

local function hero_oni_kr6_insert(this, store)
	this.hero.fn_level_up(this, store, true)

	this.melee.order = {3, 2, 1}
	this.timed_attacks.list[4].disabled = true

	return true
end

local function hero_oni_kr6_update(this, store)
	local h = this.health
	local skills = this.hero.skills
	local list = this.timed_attacks.list
	local sa, sb, sc, ult = list[1], list[2], list[3], list[4]
	local brk, sta
	local blocked_id
	local old_tombstone_time = this.hero.tombstone_show_time
	local old_tombstone_respawn_animation = this.hero.tombstone_respawn_animation
	local ult_start_cd = store.wave_group_number == 0

	this.health_bar.hidden = false
	this.blocking_time_ts = store.tick_ts

	local function spawn_swords(count, center, radius, angle, decal)
		for i = 1, count do
			local p = U.point_on_ellipse(center, radius - math.random(0, 5), angle + i * 2 * math.pi / count)
			local e = E:create_entity(decal)

			e.pos.x, e.pos.y = p.x, p.y
			e.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(e)
		end
	end

	while true do
		if ult_start_cd and store.wave_group_number > 0 then
			ult_start_cd = false
			ult.ts = store.tick_ts
		end

		if h.dead then
			local spawn_decal = true

			if band(h.last_damage_types, bor(DAMAGE_EAT)) ~= 0 then
				this.hero.tombstone_show_time = nil
				this.hero.tombstone_respawn_animation = nil
				spawn_decal = false
			end

			if spawn_decal then
				local decal_respawn = E:create_entity(this.decal_respawn)

				decal_respawn.pos = V.vclone(this.pos)
				decal_respawn.source_id = this.id
				decal_respawn.delay = this.health.dead_lifetime + fts(25)

				simulation:queue_insert_entity(decal_respawn)
			end

			SU.y_hero_death_and_respawn(store, this)

			this.hero.tombstone_show_time = old_tombstone_time
			this.hero.tombstone_respawn_animation = old_tombstone_respawn_animation
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
				U.y_animation_play(this, "lvlup", nil, store.tick_ts, 1)
			end

			this.melee.attacks[3].disabled = sa.disabled
			this.melee.attacks[2].disabled = skills.talent_1.disabled

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if sta == A_DONE and this.melee.last_attack and this.melee.last_attack.attack == this.melee.attacks[3] then
				sa.ts = store.tick_ts

				apply_delayed_cooldowns(store, list)

				this.used_skill = true
			end

			if ready_to_use_skill(ult, store, this.unit.cooldown_factor) then
				local _, triggers = U.find_foremost_enemy(store, this.pos, 0, ult.max_range, ult.prediction, ult.flags, ult.bans)

				if not triggers or #triggers < ult.min_targets then
					SU.delay_attack(store, ult, fts(10))
				else
					S:queue(ult.sound)
					S:queue(ult.taunt)
					U.animation_start(this, ult.animation_in, this.render.sprites[1].flip_x, store.tick_ts, false, 1)

					if SU.y_hero_wait(store, this, ult.cast_time) then
						S:stop(ult.sound)

						goto continue
					end

					U.animation_start(this, ult.animation_loop, this.render.sprites[1].flip_x, store.tick_ts, true, 1)

					local flip = this.render.sprites[1].flip_x and -1 or 1
					local pos_x, pos_y = this.pos.x + ult.offset * flip, this.pos.y
					local decal_ground = E:create_entity(ult.decal_ground)

					decal_ground.pos = vec_2(pos_x, pos_y)
					decal_ground.render.sprites[1].ts = store.tick_ts

					simulation:queue_insert_entity(decal_ground)

					local decal_aura = E:create_entity(ult.decal_aura)

					decal_aura.pos = vec_2(pos_x, pos_y)
					decal_aura.render.sprites[1].ts = store.tick_ts

					simulation:queue_insert_entity(decal_aura)
					U.y_wait(store, fts(2))

					local aura = E:create_entity(ult.aura)

					aura.pos = V.vclone(this.pos)
					aura.aura.source_id = this.id

					simulation:queue_insert_entity(aura)

					for _, s in pairs(ult.torment_swords) do
						local _, radius, count = unpack(s)

						spawn_swords(count, vec_2(pos_x, pos_y), radius, math.random(0, 2) * math.pi, ult.decal_swords[math.random(1, 2)])
						U.y_wait(store, fts(1))
					end

					U.y_wait(store, ult.duration)
					SU.hero_gain_xp_from_skill(this, skills.ultimate)
					U.y_animation_play(this, ult.animation_out, this.render.sprites[1].flip_x, store.tick_ts, 1, 1)

					ult.ts = store.tick_ts

					apply_delayed_cooldowns(store, list)

					this.used_skill = true

					goto continue
				end
			end

			if ready_to_use_skill(sb, store, this.unit.cooldown_factor) and h.hp <= h.hp_max * sb.threshold then
				S:queue(sb.sound, sb.sound_args)
				U.animation_start(this, sb.animation, this.render.sprites[1].flip_x, store.tick_ts, false, 1)

				local ts = store.tick_ts

				if SU.y_hero_wait(store, this, sb.cast_time) then
					goto continue
				end

				local mod = E:create_entity(sb.mod)
				local heal = h.hp_max * skills.skill_b.heal_ptg[skills.skill_b.level]

				mod.modifier.source_id = this.id
				mod.modifier.target_id = this.id
				mod.hps.heal_min = heal
				mod.hps.heal_max = heal

				simulation:queue_insert_entity(mod)
				SU.hero_gain_xp_from_skill(this, skills.skill_b)

				local heal_start_ts = store.tick_ts

				while store.tick_ts - ts < sb.duration - sb.cast_time do
					if SU.soldier_interrupted(this) then
						if store.entities[mod.id] then
							simulation:queue_remove_entity(mod)
						end

						if store.tick_ts - heal_start_ts < sb.cancel_time_refund then
							goto skill_b_stop
						else
							goto skill_b_finish
						end
					end

					coroutine.yield()
				end

				U.animation_start(this, "idle", this.render.sprites[1].flip_x, store.tick_ts, true, 1)

				::skill_b_finish::

				sb.ts = store.tick_ts

				::skill_b_stop::

				apply_delayed_cooldowns(store, list)

				this.used_skill = true

				goto continue
			end

			if ready_to_use_skill(sc, store, this.unit.cooldown_factor) then
				local target = U.find_foremost_enemy(store, this.pos, sc.min_detection_range, sc.detection_range, sc.prediction, sc.flags, sc.bans)

				if not target then
					SU.delay_attack(store, sc, fts(10))
				else
					U.animation_start(this, sc.animation_in, this.pos.x > target.pos.x, store.tick_ts, false, 1)

					this.health_bar.hidden = true

					S:queue(sc.sound)

					if SU.y_hero_wait(store, this, sc.decal_cast_time) then
						goto continue
					end

					local stun

					if this.soldier.target_id ~= nil then
						stun = E:create_entity(sc.mod_stun)
						stun.modifier.source_id = this.id
						stun.modifier.target_id = this.soldier.target_id

						simulation:queue_insert_entity(stun)
					end

					U.bans_add(this.vis, F_ALL)
					this.health.ignore_damage = true

					local decal_cast = E:create_entity(sc.decal_cast)

					decal_cast.render.sprites[1].ts = store.tick_ts
					decal_cast.pos = V.vclone(this.pos)

					simulation:queue_insert_entity(decal_cast)
					U.y_wait(store, sc.disappear_time)

					local flip = target.pos.x < this.pos.x and 1 or -1
					local decal = E:create_entity(sc.decal)
					local skill_c = skills.skill_c

					decal.pos = vec_2(target.pos.x + flip * (target.unit.hit_offset.x + 50), target.pos.y)
					decal.source_id = this.id
					decal.target_id = target.id
					decal.damage_min = skill_c.damage_min
					decal.damage_max = skill_c.damage_max
					decal.armor_red = skill_c.armor_red[skill_c.level]
					decal.render.sprites[1].ts = store.tick_ts

					simulation:queue_insert_entity(decal)

					while not this.end_skill_c do
						coroutine.yield()
					end

					SU.hero_gain_xp_from_skill(this, skill_c)

					this.end_skill_c = false
					this.health_bar.hidden = false
					U.bans_remove(this.vis, F_ALL)
					this.health.ignore_damage = false

					U.animation_start(this, sc.animation_out, nil, store.tick_ts, false, 1)
					U.y_wait(store, sc.invincible_time)

					if stun and store.entities[stun.id] then
						store.entities[stun.id].modifier.duration = 0
					end

					U.y_animation_wait(this)

					this.used_skill = true
					sc.ts = store.tick_ts

					apply_delayed_cooldowns(store, list)

					goto continue
				end
			end

			if this.soldier.target_id ~= nil then
				if blocked_id == nil then
					blocked_id = this.soldier.target_id
				end

				if blocked_id ~= this.soldier.target_id then
					this.blocking_time_ts = store.tick_ts
					blocked_id = this.soldier.target_id
				end
			else
				blocked_id = nil
				this.blocking_time_ts = store.tick_ts
			end

			if brk or sta ~= A_NO_TARGET then
			-- block empty
			elseif SU.soldier_go_back_step(store, this) then
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

local tt

tt = RT("hero_oni_kr6", "hero")
AC(tt, "melee", "timed_attacks")
tt.hero.level_stats.armor = {0.1, 0.13, 0.16, 0.19, 0.22, 0.25, 0.28, 0.31, 0.34, 0.37}
tt.hero.level_stats.hp_max = {180, 195, 210, 225, 240, 255, 270, 285, 300, 315}
tt.hero.level_stats.melee_damage_min = {5, 7, 9, 10, 12, 13, 15, 17, 18, 20}
tt.hero.level_stats.melee_damage_max = {8, 11, 13, 15, 18, 20, 23, 25, 27, 30}
tt.hero.skills.skill_a = CC("hero_skill")
tt.hero.skills.skill_a.cooldown = 24
tt.hero.skills.skill_a.damage_min = {95, 165, 235}
tt.hero.skills.skill_a.damage_max = {105, 175, 245}
tt.hero.skills.skill_a.damage_type = DAMAGE_TRUE
tt.hero.skills.skill_a.xp_gain = {96, 192, 288}
tt.hero.skills.skill_a.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.skill_b = CC("hero_skill")
tt.hero.skills.skill_b.cooldown = 20
tt.hero.skills.skill_b.duration = 3
tt.hero.skills.skill_b.cancel_time_refund = 0.5
tt.hero.skills.skill_b.trigger_threshold = 0.5
tt.hero.skills.skill_b.heal_ptg = {0.0208, 0.0333, 0.0458}
tt.hero.skills.skill_b.heal_every = 0.25
tt.hero.skills.skill_b.xp_gain = {80, 160, 240}
tt.hero.skills.skill_b.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.skill_c = CC("hero_skill")
tt.hero.skills.skill_c.cooldown = 18
tt.hero.skills.skill_c.min_detection_range = 100
tt.hero.skills.skill_c.detection_range = 250
tt.hero.skills.skill_c.damage_min = {40, 52, 64}
tt.hero.skills.skill_c.damage_max = {60, 78, 96}
tt.hero.skills.skill_c.damage_type = DAMAGE_PHYSICAL
tt.hero.skills.skill_c.armor_red = {0.05, 0.07, 0.1}
tt.hero.skills.skill_c.xp_gain = {72, 144, 216}
tt.hero.skills.skill_c.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.level = 1
tt.hero.skills.ultimate.cooldown = 38
tt.hero.skills.ultimate.damage_min = 160
tt.hero.skills.ultimate.damage_max = 180
tt.hero.skills.ultimate.damage_type = DAMAGE_TRUE
tt.hero.skills.ultimate.xp_gain = {152}
tt.hero.skills.ultimate.xp_level_steps = {
	[5] = 1
}
tt.hero.skills.talent_1 = CC("hero_skill")
tt.hero.skills.talent_1.damage_factor = 2
tt.hero.skills.talent_1.damage_type = DAMAGE_PHYSICAL
tt.hero.skills.talent_1.disabled = true
tt.hero.skills.talent_1.xp_level_steps = {
	[1] = 1
}
tt.hero.skills.talent_2 = CC("hero_skill")
tt.hero.skills.talent_2.lifesteal = 0.5
tt.hero.skills.talent_2.block_time = 4
tt.hero.skills.talent_2.lifesteal_mod_pre = "mod_oni_talent_2_lifesteal_"
tt.hero.skills.talent_2.disabled = true
tt.hero.skills.talent_2.xp_level_steps = {
	[1] = 1
}
tt.decal_respawn = "decal_oni_respawn"
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, 45)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_oni_kr6_level_up
tt.hero.respawn_animation = "respawn"
tt.hero.tombstone_concurrent_with_death = true
tt.hero.tombstone_decal = "decal_oni_tombstone"
tt.hero.tombstone_show_time = fts(39)
tt.info.hero_portrait = "kr6_hero_portraits_0011"
tt.info.portrait = "kr6_info_portraits_heroes_0013"
tt.main_script.insert = hero_oni_kr6_insert
tt.main_script.update = hero_oni_kr6_update
tt.motion.max_speed = 70
tt.regen.cooldown = 1
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].prefix = "OniDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].draw_order = DO_HEROES
tt.sound_events.change_rally_point = "HeroOniTaunt"
tt.sound_events.death = "HeroOniDeath"
tt.sound_events.hero_room_select = "HeroOniTauntSelect"
tt.sound_events.level_up = "HeroOniTauntLevelUp"
tt.sound_events.respawn = "HeroOniTauntIntro"
tt.soldier.melee_slot_offset = vec_2(15, 0)
tt.ui.click_rect = r(-22, -5, 44, 43)
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 12)
tt.unit.marker_offset = vec_2(0, -1)
tt.unit.mod_offset = vec_2(0, 19.9)
tt.unit.pop_offset = vec_2(0, 15)
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].animations = {nil, "attack"}
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_min = 5
tt.melee.attacks[1].damage_max = 8
tt.melee.attacks[1].hit_fx = "fx_oni_hit"
tt.melee.attacks[1].hit_offset = vec_2(30, 15)
tt.melee.attacks[1].hit_times = {fts(12), fts(24)}
tt.melee.attacks[1].loops = 1
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 1.4
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animations = {nil, "attack_strong"}
tt.melee.attacks[2].cooldown = 0
tt.melee.attacks[2].damage_min = 10
tt.melee.attacks[2].damage_max = 16
tt.melee.attacks[2].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].fn_can = fn_can_talent_1
tt.melee.attacks[3] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[3].animation = "skill_01"
tt.melee.attacks[3].cooldown = 0
tt.melee.attacks[3].damage_min = 95
tt.melee.attacks[3].damage_max = 105
tt.melee.attacks[3].damage_type = DAMAGE_TRUE
tt.melee.attacks[3].disabled = true
tt.melee.attacks[3].fn_can = fn_can_skill_a
tt.melee.attacks[3].hit_decal = "decal_oni_skill_a_hit"
tt.melee.attacks[3].hit_fx = nil
tt.melee.attacks[3].hit_offset = vec_2(30, 0)
tt.melee.attacks[3].hit_time = fts(35)
tt.melee.attacks[3].loops = nil
tt.melee.attacks[3].sound = "HeroOniDeathStrikeCast"
tt.melee.attacks[3].xp_from_skill = "skill_a"
tt.melee.cooldown = 2
tt.melee.range = 60
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].cooldown = 24
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].throttle_cooldown_on_skill_use = true
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].animation = "skill_02"
tt.timed_attacks.list[2].cancel_time_refund = 0.5
tt.timed_attacks.list[2].cast_time = fts(19)
tt.timed_attacks.list[2].cooldown = 20
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].duration = 3
tt.timed_attacks.list[2].mod = "mod_oni_skill_b_heal"
tt.timed_attacks.list[2].sound = "HeroOniNetherfocusCast"
tt.timed_attacks.list[2].threshold = 0.5
tt.timed_attacks.list[2].throttle_cooldown_on_skill_use = true
tt.timed_attacks.list[3] = CC("custom_attack")
tt.timed_attacks.list[3].animation_in = "skill_03_in"
tt.timed_attacks.list[3].animation_out = "skill_03_out"
tt.timed_attacks.list[3].bans = F_FLYING
tt.timed_attacks.list[3].cooldown = 18
tt.timed_attacks.list[3].decal = "decal_oni_hit_skill_c"
tt.timed_attacks.list[3].decal_cast = "decal_oni_skill_c_cast"
tt.timed_attacks.list[3].decal_cast_time = fts(20)
tt.timed_attacks.list[3].detection_range = 250
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].disappear_time = fts(8)
tt.timed_attacks.list[3].flags = F_RANGED
tt.timed_attacks.list[3].fx_stun = "fx_oni_hit"
tt.timed_attacks.list[3].invincible_time = fts(14)
tt.timed_attacks.list[3].min_detection_range = 100
tt.timed_attacks.list[3].mod_stun = "mod_oni_skill_c_stun"
tt.timed_attacks.list[3].sound = "HeroOniHellishStrikeCast"
tt.timed_attacks.list[3].throttle_cooldown_on_skill_use = true
tt.timed_attacks.list[4] = CC("custom_attack")
tt.timed_attacks.list[4].animation_in = "ulti_in"
tt.timed_attacks.list[4].animation_loop = "ulti_loop"
tt.timed_attacks.list[4].animation_out = "ulti_out"
tt.timed_attacks.list[4].aura = "aura_oni_ult"
tt.timed_attacks.list[4].bans = bor(F_FLYING)
tt.timed_attacks.list[4].cast_time = fts(28)
tt.timed_attacks.list[4].cooldown = 38
tt.timed_attacks.list[4].decal_aura = "decal_oni_ult_aura"
tt.timed_attacks.list[4].decal_ground = "decal_oni_ult_ground_crack"
tt.timed_attacks.list[4].decal_swords = {"decal_oni_ult_sword_1", "decal_oni_ult_sword_2"}
tt.timed_attacks.list[4].disabled = true
tt.timed_attacks.list[4].duration = fts(10)
tt.timed_attacks.list[4].flags = 0
tt.timed_attacks.list[4].max_range = 70
tt.timed_attacks.list[4].min_targets = 2
tt.timed_attacks.list[4].offset = 0
tt.timed_attacks.list[4].prediction = 0
tt.timed_attacks.list[4].sound = "HeroOniSwordTormentOneShot"
tt.timed_attacks.list[4].taunt = "HeroOniTauntUltimate"
tt.timed_attacks.list[4].throttle_cooldown_on_skill_use = true
tt.timed_attacks.list[4].torment_swords = {{0.01, 20, 8}, {0.2, 37.5, 8}, {0.3, 55, 8}}

tt = RT("aura_oni_ult", "aura")
tt.aura.cycles = 1
tt.aura.damage_max = 180
tt.aura.damage_min = 160
tt.aura.damage_type = DAMAGE_TRUE
tt.aura.duration = 1e+99
tt.aura.radius = 70
tt.aura.vis_bans = bor(F_FRIEND, F_HERO, F_FLYING)
tt.aura.vis_flags = bor(F_AREA)
tt.main_script.update = aura_oni_ult_update

tt = RT("fx_oni_hit", "fx")
tt.render.sprites[1].name = "oni_multi_hit"

tt = RT("decal_oni_skill_a_hit", "decal_scripted")
AC(tt, "tween")
tt.main_script.remove = scripts.tween_utils.reverse_remove
tt.main_script.update = scripts.tween_utils.wait_update
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "oni_multi_fx_skill_1_decal"
tt.render.sprites[1].z = Z_DECALS
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 0}, {1, 255}}
tt.tween.props[1].name = "alpha"
tt.tween.props[1].sprite_id = 1
tt.wait_time = 2

tt = RT("decal_oni_skill_c_cast", "decal_timed")
tt.render.sprites[1].name = "oni_multi_fx_skill_3"
tt.render.sprites[1].z = Z_DECALS

tt = RT("decal_oni_hit_skill_c", "decal_scripted")
tt.damage_max = 60
tt.damage_min = 40
tt.damage_type = DAMAGE_PHYSICAL
tt.hit_fx = "fx_oni_hit"
tt.hit_offset = vec_2(30, 15)
tt.hit_times = {fts(9), fts(10), fts(10)}
tt.main_script.update = decal_oni_skill_c_update
tt.mod_armor_sunder = "mod_oni_skill_c_armor_sunder"
tt.mod_stun = "mod_oni_skill_c_stun"
tt.render.sprites[1].exo = true
tt.render.sprites[1].name = "skill_03_attack"
tt.render.sprites[1].prefix = "OniDef"
tt.render.sprites[1].sort_y_offset = -1
tt.render.sprites[1].z = Z_OBJECTS
tt.sound_hit = "HeroOniHellishStrikeHits"
tt.sound_out = "HeroOniHellishStrikePhaseOut"

tt = RT("decal_oni_ult_sword_1", "decal_timed")
tt.render.sprites[1].name = "oni_multi_sword_1"
tt.render.sprites[1].z = Z_DECALS

tt = RT("decal_oni_ult_sword_2", "decal_timed")
tt.render.sprites[1].name = "oni_multi_sword_2"
tt.render.sprites[1].z = Z_DECALS

tt = RT("decal_oni_ult_ground_crack", "decal_timed")
tt.render.sprites[1].name = "oni_multi_decal_skill_3"
tt.render.sprites[1].z = Z_DECALS - 1

tt = RT("decal_oni_ult_aura", "decal_timed")
tt.render.sprites[1].name = "oni_multi_aura_skill_3"
tt.render.sprites[1].z = Z_DECALS

tt = RT("decal_oni_respawn_dust", "decal_timed")
tt.render.sprites[1].name = "oni_multi_fx_respawn_1"
tt.render.sprites[1].z = Z_DECALS

tt = RT("decal_oni_respawn_aura", "decal_timed")
tt.render.sprites[1].name = "oni_multi_fx_respawn_2"
tt.render.sprites[1].z = Z_DECALS

tt = RT("decal_oni_respawn_ground", "decal_timed")
tt.render.sprites[1].name = "oni_multi_fx_respawn_decal"
tt.render.sprites[1].z = Z_DECALS

tt = RT("decal_oni_respawn", "decal_scripted")
tt.decals = {"decal_oni_respawn_dust", "decal_oni_respawn_aura", "decal_oni_respawn_ground"}
tt.main_script.update = decal_oni_respawn_update

tt = RT("decal_oni_tombstone", "decal_tween")
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].name = "death_loop"
tt.render.sprites[1].prefix = "OniDef"
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 0}, {fts(1), 0}}

tt = RT("mod_oni_skill_b_heal", "modifier")
AC(tt, "hps")
tt.hps.heal_every = 0.25
tt.main_script.insert = scripts.mod_hps.insert
tt.main_script.update = scripts.mod_hps.update
tt.modifier.duration = 3
tt.modifier.resets_same = true

tt = RT("mod_oni_skill_c_stun", "mod_stun")
tt.modifier.duration = 1e+99
tt.modifier.resets_same = true
tt.modifier.vis_bans = bor(F_BOSS)
tt.modifier.vis_flags = bor(F_MOD, F_STUN)

tt = RT("mod_oni_skill_c_armor_sunder", "modifier")
tt.main_script.insert = mod_oni_skill_c_armor_sunder_insert
tt.modifier.armor_red_factor = 0.05
tt.modifier.vis_bans = 0

tt = RT("mod_oni_talent_2_lifesteal_1", "modifier")
tt.block_time = 4
tt.heal_hp = 3.25
tt.main_script.insert = mod_oni_talent_2_lifesteal_insert
tt.modifier.vis_bans = 0

for i = 2, 10 do
	tt = RT("mod_oni_talent_2_lifesteal_" .. i, "mod_oni_talent_2_lifesteal_1")
	tt.heal_hp = 0.5 * (({5, 7, 9, 10, 12, 13, 15, 17, 18, 20})[i] + ({8, 11, 13, 15, 18, 20, 23, 25, 27, 30})[i]) / 2
end
