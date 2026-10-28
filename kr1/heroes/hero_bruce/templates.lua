local scripts = require("scripts")
local E = require("entity_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local bit = require("bit")
local HU = require("hero_utils")
local km = require("lib.klua.macros")
local band = bit.band
local bor = bit.bor
local find_target_at_critical_moment = HU.find_target_at_critical_moment
local fts = U.fts
local level_up_basic = HU.level_up_basic
local queue_damage = U.queue_damage
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local update_regen = HU.update_regen
local upgrade_skill = HU.upgrade_skill
local tt

local function aura_bruce_hps_update(this, store)
	local owner = store.entities[this.aura.source_id]
	local hps = this.hps

	while true do
		if store.tick_ts - hps.ts > hps.heal_every then
			hps.ts = store.tick_ts

			U.heal(owner, hps.heal_max)
		end

		coroutine.yield()
	end
end

local function lion_bruce_insert(this, store)
	this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)

	if not this.pos then
		return false
	end

	return true
end

local function lion_bruce_update(this, store)
	local attack = this.custom_attack
	local start_ts = store.tick_ts
	local fading

	this.tween.ts = store.tick_ts

	while true do
		local next = P:next_entity_node(this, store.tick_length)

		if not fading and (not next or not P:is_node_valid(this.nav_path.pi, this.nav_path.ni) or store.tick_ts - start_ts >= this.duration) then
			fading = true
			this.tween.remove = true
			this.tween.reverse = true
			this.tween.ts = store.tick_ts

			S:queue(this.sound_events.custom_loop_end)
		end

		if next then
			U.set_destination(this, next)
		end

		local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)

		U.animation_start_default(this, an, af, store.tick_ts)
		U.walk_off__accel__unsnapped(this, store.tick_length)

		if not fading and store.tick_ts - attack.ts > attack.cooldown then
			attack.ts = store.tick_ts

			local targets = U.find_enemies_in_range_filter_off(this.pos, attack.range, attack.vis_flags, attack.vis_bans)

			if targets then
				for _, e in ipairs(targets) do
					if U.flag_has(e.vis.flags, F_BOSS) then
						local d = E.assign_damage(attack.damage_type, attack.damage_boss * this.damage_factor, this.id, e.id)

						queue_damage(store, d)

						this.render.sprites[1].loop_forced = false

						U.y_animation_play(this, "boom", nil, store.tick_ts)

						goto label_179_0
					elseif U.flags_pass(e.vis, attack) then
						for _, mn in ipairs(attack.mods) do
							local m = E:create_entity(mn)

							m.modifier.target_id = e.id
							m.modifier.source_id = this.id

							simulation:queue_insert_entity(m)
						end

						goto label_179_0
					end
				end
			end
		end

		coroutine.yield()
	end

	::label_179_0::

	simulation:queue_remove_entity(this)
end

local function hero_bruce_ultimate_update(this, store)
	local pi, spi, ni
	local target_info = U.find_enemies_in_paths(store.enemies, this.pos, this.range_nodes_min, this.range_nodes_max, nil, this.vis_flags, this.vis_bans, true, function(e)
		return not U.flag_has(P:path_terrain_props(e.nav_path.pi), TERRAIN_FAERIE)
	end)

	if target_info then
		local o = target_info[1].origin

		pi, spi, ni = o[1], o[2], o[3]
	else
		local nearest = P:nearest_nodes(this.pos.x, this.pos.y)

		if #nearest > 0 then
			for _, n in pairs(nearest) do
				if band(P:path_terrain_props(n[1]), TERRAIN_FAERIE) == 0 then
					pi, spi, ni = n[1], n[2], n[3]

					break
				end
			end
		end
	end

	if pi then
		for i = 1, this.count do
			local e = E:create_entity(this.entity)

			e.nav_path.pi = pi
			e.nav_path.spi = spi
			e.nav_path.ni = ni
			e.damage_factor = this.damage_factor

			simulation:queue_insert_entity(e)

			spi = km.zmod(spi + 1, 3)
			ni = ni - 2
		end
	end

	simulation:queue_remove_entity(this)
end

local function hero_bruce_fn_chance_sharp_claws(this, store, attack, target)
	return U.has_modifier_types(store, target, MOD_TYPE_BLEED, MOD_TYPE_POISON) or math.random() < attack.chance
end

local function hero_bruce_level_up(this, store)
	local hl, ls = level_up_basic(this, store)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
	this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]
	this.melee.attacks[3].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[3].damage_max = ls.melee_damage_max[hl]

	upgrade_skill(this, "sharp_claws", function(this, s)
		local a = this.melee.attacks[3]

		a.disabled = nil

		local m = E:get_template(a.mod)

		m.dps.damage_min = s.damage[s.level]
		m.dps.damage_max = s.damage[s.level]
		m.extra_bleeding_damage = s.extra_damage[s.level]
	end)
	upgrade_skill(this, "kings_roar", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil

		local m = E:get_template(a.mod)

		m.modifier.duration = s.stun_duration[s.level]
	end)
	upgrade_skill(this, "lions_fur", function(this, s)
		this.lion_fur_extra = s.extra_hp[s.level]
	end)
	upgrade_skill(this, "grievous_bites", function(this, s)
		local a = this.melee.attacks[4]

		a.disabled = nil
		a.damage_max = s.damage[s.level]
		a.damage_min = s.damage[s.level]
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		this.ultimate.disabled = nil

		local u = E:get_template(s.controller_name)

		u.count = s.count[s.level]

		local e = E:get_template(u.entity)

		e.custom_attack.damage_boss = s.damage_boss[s.level]

		local m = E:get_template("mod_lion_bruce_damage")

		m.dps.damage_max = s.damage_per_tick[s.level]
		m.dps.damage_min = s.damage_per_tick[s.level]
	end)

	this.health.hp_max = this.health.hp_max + this.lion_fur_extra

	update_regen(this)
	update_hp(this)
end

local function hero_bruce_insert(this, store)
	if not scripts.hero_basic.insert(this, store) then
		return false
	end

	local a = E:create_entity("aura_bruce_hps")

	a.aura.source_id = this.id
	a.aura.ts = store.tick_ts
	a.pos = this.pos

	simulation:queue_insert_entity(a)

	return true
end

local function hero_bruce_update(this, store)
	local h = this.health
	local a, skill, brk, sta

	this.health_bar.hidden = false

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_174_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.kings_roar

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local targets = U.find_enemies_in_range_filter_off(this.pos, a.range, a.vis_flags, a.vis_bans)

				if not targets or #targets < a.min_count then
					a.ts = a.ts + 0.13333333333333333
				else
					S:queue(a.sound, a.sound_args)
					U.animation_start_default(this, a.animation, nil, store.tick_ts)

					if SU.y_soldier_wait(store, this, a.hit_time) then
					-- block empty
					else
						SU.hero_gain_xp_from_skill(this, skill)

						a.ts = store.tick_ts
						targets = U.find_enemies_in_range_filter_off(this.pos, a.range, a.vis_flags, a.vis_bans)

						if targets then
							for i, target in ipairs(targets) do
								local m = E:create_entity(a.mod)

								m.modifier.source_id = this.id
								m.modifier.target_id = target.id

								simulation:queue_insert_entity(m)
							end
						end

						SU.y_hero_animation_wait(this)
					end

					goto label_174_0
				end
			end

			if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
				local target = find_target_at_critical_moment(this, 150, F_RANGED, F_NONE)

				if target and target.pos and U.has_valid_rally_node_nearby(target.pos) then
					S:queue(this.sound_events.change_rally_point)

					local e = E:create_entity(this.hero.skills.ultimate.controller_name)

					e.pos = V.vclone(target.pos)
					e.damage_factor = this.unit.damage_factor

					simulation:queue_insert_entity(e)

					this.ultimate.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, this.ultimate)
				else
					this.ultimate.ts = this.ultimate.ts + 1
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

		::label_174_0::

		coroutine.yield()
	end
end

tt = RT("hero_bruce", "hero")

AC(tt, "melee", "timed_attacks")

tt.hero.level_stats.armor = {0.14, 0.18, 0.22, 0.26, 0.3, 0.34, 0.38, 0.42, 0.46, 0.5}
tt.hero.level_stats.hp_max = {365, 390, 415, 440, 465, 490, 515, 540, 565, 590}
tt.hero.level_stats.melee_damage_max = {27, 31, 34, 38, 41, 45, 49, 52, 56, 59}
tt.hero.level_stats.melee_damage_min = {18, 20, 23, 25, 28, 30, 32, 35, 37, 40}
tt.hero.skills.sharp_claws = CC("hero_skill")
tt.hero.skills.sharp_claws.damage = {3, 6, 9}
tt.hero.skills.sharp_claws.extra_damage = {25, 50, 75}
tt.hero.skills.sharp_claws.xp_gain = {10, 20, 30}
tt.hero.skills.sharp_claws.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.kings_roar = CC("hero_skill")
tt.hero.skills.kings_roar.stun_duration = {2, 2.75, 3.5}
tt.hero.skills.kings_roar.xp_gain = {100, 120, 150}
tt.hero.skills.kings_roar.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.lions_fur = CC("hero_skill")
tt.hero.skills.lions_fur.extra_hp = {50, 100, 150}
tt.hero.skills.lions_fur.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.grievous_bites = CC("hero_skill")
tt.hero.skills.grievous_bites.damage = {35, 70, 105}
tt.hero.skills.grievous_bites.xp_gain = {30, 60, 90}
tt.hero.skills.grievous_bites.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_bruce_ultimate"
tt.hero.skills.ultimate.damage_per_tick = {11, 14, 17, 20}
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.ultimate.damage_boss = {150, 200, 350, 500}
tt.hero.skills.ultimate.count = {2, 3, 4, 5}
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, 53)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_bruce_level_up
tt.hero.tombstone_show_time = fts(90)
tt.info.hero_portrait = "kr3_hero_portraits_0013"
tt.info.portrait = "kr3_info_portraits_heroes_0013"
tt.main_script.insert = hero_bruce_insert
tt.main_script.update = hero_bruce_update
tt.motion.max_speed = 3.3 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.16666666666667
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_bruce"
tt.soldier.melee_slot_offset = vec_2(12, -1)
tt.sound_events.change_rally_point = "ElvesHeroBruceTaunt"
tt.sound_events.death = "ElvesHeroBruceDeath"
tt.sound_events.hero_room_select = "ElvesHeroBruceTauntSelect"
tt.sound_events.insert = "ElvesHeroBruceTauntIntro"
tt.sound_events.respawn = "ElvesHeroBruceTauntIntro"
tt.unit.hit_offset = vec_2(0, 16)
tt.unit.mod_offset = vec_2(0, 22)
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].xp_gain_factor = 3.1
tt.melee.attacks[1].damage_type = DAMAGE_RUDE
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].chance = 0.5
tt.melee.attacks[3] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[3].animation = "attack3"
tt.melee.attacks[3].chance = 0.2
tt.melee.attacks[3].fn_chance = hero_bruce_fn_chance_sharp_claws
tt.melee.attacks[3].disabled = true
tt.melee.attacks[3].mod = "mod_bruce_sharp_claws"
tt.melee.attacks[4] = CC("melee_attack")
tt.melee.attacks[4].animations = {nil, "eat"}
tt.melee.attacks[4].cooldown = 16
tt.melee.attacks[4].damage_max = nil
tt.melee.attacks[4].damage_min = nil
tt.melee.attacks[4].damage_type = DAMAGE_TRUE
tt.melee.attacks[4].disabled = true
tt.melee.attacks[4].hit_times = {fts(8), fts(16), fts(25)}
tt.melee.attacks[4].interrupt_on_dead_target = true
tt.melee.attacks[4].loops = 1
tt.melee.attacks[4].sound = "ElvesHeroBruceGriveousBites"
tt.melee.attacks[4].sound_args = {
	delay = fts(3)
}
tt.melee.attacks[4].xp_from_skill = "grievous_bites"
tt.melee.attacks[4].xp_gain_factor = 5
tt.melee.attacks[4].mod = "mod_bruce_sharp_claws"
tt.melee.cooldown = 1
tt.melee.range = 55
tt.timed_attacks.list[1] = CC("mod_attack")
tt.timed_attacks.list[1].animation = "specialAttack"
tt.timed_attacks.list[1].cooldown = 20
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].hit_time = fts(17)
tt.timed_attacks.list[1].min_count = 2
tt.timed_attacks.list[1].mod = "mod_bruce_kings_roar"
tt.timed_attacks.list[1].range = 125
tt.timed_attacks.list[1].sound = "ElvesHeroBruceKingsRoar"
tt.timed_attacks.list[1].sound_args = {
	delay = fts(9)
}
tt.timed_attacks.list[1].vis_bans = bor(F_BOSS)
tt.timed_attacks.list[1].vis_flags = bor(F_MOD, F_STUN, F_RANGED)
tt.timed_attacks.list[1].xp_from_skill = "kings_roar"
tt.ultimate = {
	ts = 0,
	cooldown = 36,
	disabled = true
}
tt = RT("hero_bruce_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.cooldown = 36
tt.main_script.update = hero_bruce_ultimate_update
tt.sound_events.insert = "ElvesHeroBruceGuardianLionsCast"
tt.entity = "lion_bruce"
tt.range_nodes_min = 0
tt.range_nodes_max = 999
tt.vis_flags = bor(F_RANGED)
tt.vis_bans = bor(F_FLYING)
tt = RT("lion_bruce", "decal_scripted")

AC(tt, "nav_path", "motion", "custom_attack", "sound_events", "tween")

tt.custom_attack.cooldown = fts(6)
tt.custom_attack.mods = {"mod_lion_bruce_stun", "mod_lion_bruce_damage"}
tt.custom_attack.range = 40
tt.custom_attack.vis_flags = bor(F_RANGED, F_STUN, F_CUSTOM)
tt.custom_attack.vis_bans = bor(F_FLYING)
tt.custom_attack.damage_type = DAMAGE_TRUE
tt.duration = 10
tt.motion.max_speed = 150
tt.main_script.insert = lion_bruce_insert
tt.main_script.update = lion_bruce_update
tt.nav_path.dir = -1
tt.render.sprites[1].anchor.y = 0.22058823529411764
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walkingRightLeft", "walkingUp", "walkingDown"}
tt.render.sprites[1].angles_custom = {
	walk = {55, 135, 240, 315}
}
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].loop_forced = true
tt.render.sprites[1].prefix = "bruce_ultimate"
tt.sound_events.custom_loop_end = "ElvesHeroBruceGuardianLionsLoopEnd"
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}
tt = RT("mod_lion_bruce_stun", "mod_stun")
tt.modifier.duration = 3
tt.modifier.animation_phases = true
tt.modifier.use_mod_offset = false
tt.render.sprites[1].size_names = nil
tt.render.sprites[1].anchor.y = 0.0975609756097561
tt.render.sprites[1].prefix = "bruce_ultimate_twister"
tt.sound_events.insert_args = {
	ignore = 1
}
tt.sound_events.insert = {"ElvesHeroBruceGuardianLionsLoopStart", "ElvesHeroBruceGuardianLionsLoop"}
tt.sound_events.remove_stop = "ElvesHeroBruceGuardianLionsLoop"
tt.sound_events.remove = "ElvesHeroBruceGuardianLionsLoopEnd"
tt = RT("mod_lion_bruce_damage", "modifier")

AC(tt, "dps", "mark_flags")

tt.dps.damage_min = nil
tt.dps.damage_max = nil
tt.dps.damage_every = fts(10)
tt.dps.damage_type = DAMAGE_TRUE
tt.mark_flags.vis_bans = F_CUSTOM
tt.modifier.duration = 3
tt.main_script.insert = fn_group(scripts.mod_dps.insert, scripts.mod_mark_flags.insert)
tt.main_script.update = scripts.mod_dps.update
tt.main_script.remove = scripts.mod_mark_flags.remove
tt = RT("aura_bruce_hps", "aura")

AC(tt, "hps")

tt.aura.duration = -1
tt.main_script.update = aura_bruce_hps_update
tt.hps.heal_max = 3
tt = RT("mod_bruce_kings_roar", "mod_stun")
tt.modifier.duration = nil
tt.modifier.vis_bans = F_BOSS
tt.modifier.health_bar_offset = vec_2(0, -3)
tt.modifier.use_mod_offset = false
tt.render.sprites[1].prefix = "mod_bruce_kings_roar"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].size_names = nil
