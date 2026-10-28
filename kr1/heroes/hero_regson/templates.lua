local E = require("entity_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local bit = require("bit")
local km = require("lib.klua.macros")
local HU = require("hero_utils")
local log = require("lib.klua.log"):new("hero_scripts")
local band = bit.band
local bor = bit.bor
local fts = U.fts
local level_up_basic = HU.level_up_basic
local queue_damage = U.queue_damage
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local update_regen = HU.update_regen
local upgrade_skill = HU.upgrade_skill
local tt

local function hero_regson_level_up(this, store)
	local hl, ls = level_up_basic(this)

	for i = 1, 2 do
		this.melee.attacks[i].damage_min = ls.melee_damage_min[hl]
		this.melee.attacks[i].damage_max = ls.melee_damage_max[hl]
	end

	upgrade_skill(this, "blade", function(this, s)
		this.melee.attacks[3].damage_max = s.damage[s.level] * 0.5
		this.melee.attacks[3].damage_min = s.damage[s.level] * 0.5
		this.melee.attacks[4].chance = s.instakill_chance[s.level]
		this.melee.attacks[4].damage_max = s.damage[s.level] * 0.5
		this.melee.attacks[4].damage_min = s.damage[s.level] * 0.5
	end)
	upgrade_skill(this, "heal", function(this, s)
		local hb = E:get_template("decal_regson_heal_ball")

		hb.hp_factor = s.heal_factor[s.level]
	end)
	upgrade_skill(this, "path", function(this, s)
		this.path_extra = s.extra_hp[s.level]
	end)
	upgrade_skill(this, "slash", function(this, s)
		local a = this.melee.attacks[5]

		a.disabled = nil

		local m = E:get_template(a.mod)

		m.damage_max = s.damage_max[s.level]
		m.damage_min = s.damage_min[s.level]
		a = this.timed_attacks.list[1]
		a.disabled = nil
		a.loops = s.loops[s.level]
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		this.ultimate.disabled = nil
		this.ultimate.cooldown = s.cooldown[s.level]

		local u = E:get_template("hero_regson_ultimate")

		u.damage_boss = s.damage_boss[s.level]
	end)

	this.health.hp_max = this.health.hp_max + this.path_extra

	update_regen(this)
	update_hp(this)
end

local function hero_regson_insert(this, store)
	this.hero.fn_level_up(this, store)

	this.melee.order = U.attack_order(this.melee.attacks)

	local a = E:create_entity("aura_regson_blade")

	a.aura.source_id = this.id
	a.aura.ts = store.tick_ts
	a.pos = this.pos

	simulation:queue_insert_entity(a)

	this.aura_blade = a

	local a = E:create_entity("aura_regson_heal")

	a.aura.source_id = this.id
	a.aura.ts = store.tick_ts
	a.pos = this.pos

	simulation:queue_insert_entity(a)

	return true
end

local function hero_regson_update(this, store)
	local h = this.health
	local brk, sta

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	local fade_start_time
	local origin_pos
	local aura_blade = this.aura_blade

	local function exit_whirlwind_mirage()
		this.pos.x = origin_pos.x
		this.pos.y = origin_pos.y
		fade_start_time = store.tick_ts

		U.animation_start_default(this, this.timed_attacks.list[1].animation .. "_end", nil, store.tick_ts, false)

		while not U.animation_finished_default(this) do
			if store.tick_ts - fade_start_time < this.timed_attacks.list[1].fade_start_end_time then
				this.render.sprites[1].alpha = 255 * (store.tick_ts - fade_start_time) / this.timed_attacks.list[1].fade_start_end_time
			end

			coroutine.yield()
		end

		this.render.sprites[1].alpha = 255
		this.health_bar.hidden = false
	end

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_98_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			local a = this.timed_attacks.list[1]

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local targets = U.find_enemies_in_range_filter_off(this.pos, 200, a.vis_flags, a.vis_bans)

				if targets and #targets > a.min_count then
					this.health_bar.hidden = true
					fade_start_time = store.tick_ts

					-- 隐形
					S:queue(this.sound_events.change_rally_point)
					U.animation_start_default(this, a.animation .. "_start", nil, store.tick_ts, false)

					while not U.animation_finished_default(this) do
						if store.tick_ts - fade_start_time < a.fade_start_end_time then
							this.render.sprites[1].alpha = 255 * (1 - (store.tick_ts - fade_start_time) / a.fade_start_end_time)
						end

						if SU.hero_interrupted(this) then
							this.render.sprites[1].alpha = 255
							this.health_bar.hidden = false

							goto label_98_0
						end

						coroutine.yield()
					end

					a.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, this.hero.skills.slash)

					origin_pos = V.vclone(this.pos)

					for i = 1, a.loops do
						local target = targets[km.zmod(i, #targets)]

						if not target or target.health.dead then
							break
						end

						S:queue(a.sound)

						this.pos.x = target.pos.x
						this.pos.y = target.pos.y

						U.animation_start_default(this, a.animation, nil, store.tick_ts, false)

						fade_start_time = store.tick_ts

						local damage_applied = false
						local fade_out_start_time

						while not U.animation_finished_default(this) do
							-- 显形
							if store.tick_ts - fade_start_time < a.fade_time then
								this.render.sprites[1].alpha = 255 * (store.tick_ts - fade_start_time) / a.fade_time
							else
								if not damage_applied then
									this.render.sprites[1].alpha = 255
									damage_applied = true

									local whirlwind_targets = U.find_enemies_in_range_filter_off(this.pos, a.damage_radius, a.vis_flags, a.vis_bans)

									if whirlwind_targets then
										for _, target in ipairs(whirlwind_targets) do
											local m = E:create_entity(a.mod)

											m.modifier.target_id = target.id
											m.modifier.source_id = this.id
											m.render.sprites[1].ts = store.tick_ts
											m.modifier.damage_factor = this.unit.damage_factor

											simulation:queue_insert_entity(m)
										end
									end

									fade_out_start_time = store.tick_ts
								end

								-- 隐形
								if store.tick_ts - fade_out_start_time < a.fade_time then
									this.render.sprites[1].alpha = 255 * (1 - (store.tick_ts - fade_out_start_time) / a.fade_time)
								else
									this.render.sprites[1].alpha = 0
								end
							end

							if SU.hero_interrupted(this) then
								exit_whirlwind_mirage()

								a.ts = a.ts - a.cooldown * (a.loops - i) / a.loops

								goto label_98_0
							end

							coroutine.yield()
						end
					end

					exit_whirlwind_mirage()

					aura_blade.blade_ts = store.tick_ts - aura_blade.blade_cooldown
					aura_blade.blade_active_ts = store.tick_ts
				else
					a.ts = a.ts + 1
				end
			end

			if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
				local enemy = U.find_biggest_enemy_in_range_filter_off(this.pos, 200, F_RANGED, F_NONE)

				if enemy and enemy.pos and enemy.health.hp > BIG_ENEMY_HP then
					U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
					S:queue(this.sound_events.change_rally_point)

					local ultimate_entity = E:create_entity(this.hero.skills.ultimate.controller_name)

					ultimate_entity.level = this.hero.skills.ultimate.level
					ultimate_entity.damage_factor = this.unit.damage_factor
					ultimate_entity.pos = V.vclone(enemy.pos)
					ultimate_entity.target_id = enemy.id

					simulation:queue_insert_entity(ultimate_entity)

					this.ultimate.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
				else
					this.ultimate.ts = this.ultimate.ts + 1
				end
			end

			if this.blade_pending then
				this.blade_pending = nil

				S:queue("ElvesHeroEldritchBladeCharge")
				U.y_animation_play(this, "goBerserk", nil, store.tick_ts, 1)
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

		::label_98_0::

		coroutine.yield()
	end
end

local function mod_regson_slash_update(this, store)
	local m = this.modifier
	local sp = this.render.sprites[1]
	local target = store.entities[m.target_id]

	if not target or not target.pos or target.health.dead then
		simulation:queue_remove_entity(this)

		return
	end

	sp.hidden = true
	m.ts = store.tick_ts
	this.pos = target.pos

	if target.unit and target.unit.mod_offset then
		sp.offset.x, sp.offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y + 5
		sp.flip_x = not target.render.sprites[1].flip_x
	end

	local delay = (m.target_idx or 0) * this.delay_per_idx

	U.y_wait_unconditional(store, delay)

	sp.hidden = nil

	U.animation_start_default(this, this.name, nil, store.tick_ts)
	U.y_wait_unconditional(store, this.hit_time)

	local d = E.assign_damage(this.damage_type, math.random(this.damage_min, this.damage_max) * m.damage_factor, this.id, target.id)

	queue_damage(store, d)
	U.y_animation_wait_default(this)
	simulation:queue_remove_entity(this)
end

local function aura_regson_blade_update(this, store)
	local hero = store.entities[this.aura.source_id]

	if not hero then
		log.error("hero not found for aura_regson_blade")
		simulation:queue_remove_entity(this)

		return
	end

	this.blade_ts = store.tick_ts

	while true do
		if this.blade_active and store.tick_ts - this.blade_active_ts > this.blade_duration then
			this.blade_active = false
			this.blade_ts = store.tick_ts

			for i = 1, 2 do
				hero.melee.attacks[i].disabled = nil
			end

			hero.melee.attacks[5].disabled = hero.hero.skills.slash.level < 1

			for i = 3, 4 do
				hero.melee.attacks[i].disabled = true
			end

			hero.idle_flip.animations[1] = "idle"
			hero.render.sprites[1].angles.walk[1] = "run"
		elseif not this.blade_active and U.is_blocked_valid(store, hero) and store.tick_ts - this.blade_ts > this.blade_cooldown then
			hero.blade_pending = true
			this.blade_active = true
			this.blade_active_ts = store.tick_ts

			for i = 1, 2 do
				hero.melee.attacks[i].disabled = true
			end

			hero.melee.attacks[5].disabled = true

			for i = 3, 4 do
				hero.melee.attacks[i].disabled = nil
			end

			hero.idle_flip.animations[1] = "berserk_idle"
			hero.render.sprites[1].angles.walk[1] = "berserk_run"
		end

		coroutine.yield()
	end
end

local function aura_regson_heal_update(this, store)
	local a = this.aura
	local hero = store.entities[a.source_id]
	local last_ts = store.tick_ts

	if not hero then
		simulation:queue_remove_entity(this)

		return
	end

	while true do
		if not hero.health.dead and store.tick_ts - last_ts >= a.cycle_time then
			last_ts = store.tick_ts

			local targets = U.find_enemies_in_range_filter_off(hero.pos, a.radius, a.vis_flags, a.vis_bans)

			if targets then
				for _, target in ipairs(targets) do
					local m = E:create_entity("mod_regson_heal")

					m.modifier.source_id = hero.id
					m.modifier.target_id = target.id

					simulation:queue_insert_entity(m)
				end
			end
		end

		coroutine.yield()
	end
end

local function hero_regson_ultimate_update(this, store)
	local is_boss
	local sp = this.render.sprites[1]
	local target = store.entities[this.target_id]

	if not target then
		local targets = table.filter(store.enemies, function(_, e)
			return e.pos and e.ui and e.ui.can_click and e.nav_path and not e.health.dead and band(e.vis.flags, this.vis_bans) == 0 and band(e.vis.bans, this.vis_flags) == 0 and U.is_inside_ellipse(V.v(e.pos.x + e.unit.hit_offset.x, e.pos.y + e.unit.hit_offset.y), V.v(this.pos.x, this.pos.y), this.range) and P:is_node_valid(e.nav_path.pi, e.nav_path.ni, NF_POWER_1)
		end)

		table.sort(targets, function(e1, e2)
			return V.dist(e1.pos.x + e1.unit.hit_offset.x, e1.pos.y + e1.unit.hit_offset.y, this.pos.x, this.pos.y) < V.dist(e2.pos.x + e2.unit.hit_offset.x, e2.pos.y + e2.unit.hit_offset.y, this.pos.x, this.pos.y)
		end)

		target = targets[1]
	end

	if not target then
	-- block empty
	else
		is_boss = band(target.vis.flags, F_BOSS) ~= 0

		if not is_boss then
			U.bans_add(target.vis, F_ALL)
		end

		SU.stun_inc(target)

		this.pos = target.pos
		sp.offset.x, sp.offset.y = target.unit.hit_offset.x, target.unit.hit_offset.y

		U.animation_start_default(this, sp.name, nil, store.tick_ts)
		U.y_wait_unconditional(store, this.hit_time)

		do
			local d = E.assign_damage(DAMAGE_TRUE, 0, this.id, target.id)

			if is_boss then
				d.damage_type = DAMAGE_TRUE
				d.value = this.damage_boss * this.damage_factor
			else
				d.damage_type = bor(DAMAGE_INSTAKILL, DAMAGE_FX_NOT_EXPLODE)
			end

			queue_damage(store, d)
		end

		U.y_animation_wait_default(this)
		SU.stun_dec(target)

		if not is_boss then
			U.bans_remove(target.vis, F_ALL)
		end
	end

	simulation:queue_remove_entity(this)
end

local function mod_regson_heal_update(this, store)
	this.modifier.ts = store.tick_ts

	while true do
		local target = store.entities[this.modifier.target_id]

		if not target or store.tick_ts - this.modifier.ts > this.modifier.duration then
			break
		end

		if target.health.dead and not U.flag_has(target.health.last_damage_types, DAMAGE_NO_LIFESTEAL) then
			local s = E:create_entity("decal_regson_heal_ball")

			s.target_id = this.modifier.source_id
			s.source_id = target.id
			s.source_hp = target.health.hp_max

			simulation:queue_insert_entity(s)

			break
		end

		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

tt = RT("hero_regson", "hero")

AC(tt, "melee", "timed_attacks")

tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.hp_max = {330, 352, 374, 396, 418, 440, 462, 484, 504, 528}
tt.hero.level_stats.melee_damage_max = {11, 12, 13, 14, 15, 16, 17, 18, 19, 20}
tt.hero.level_stats.melee_damage_min = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16}
tt.hero.skills.blade = CC("hero_skill")
tt.hero.skills.blade.damage = {60, 100, 140}
tt.hero.skills.blade.instakill_chance = {0.015, 0.03, 0.045}
tt.hero.skills.blade.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.blade.xp_gain = {90, 180, 270}
tt.hero.skills.heal = CC("hero_skill")
tt.hero.skills.heal.heal_factor = {0.1, 0.2, 0.3}
tt.hero.skills.heal.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.path = CC("hero_skill")
tt.hero.skills.path.extra_hp = {40, 80, 120}
tt.hero.skills.path.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.slash = CC("hero_skill")
tt.hero.skills.slash.damage_max = {60, 120, 180}
tt.hero.skills.slash.damage_min = {30, 60, 90}
tt.hero.skills.slash.xp_gain = {28, 84, 168}
tt.hero.skills.slash.loops = {3, 4, 5}
tt.hero.skills.slash.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_regson_ultimate"
tt.hero.skills.ultimate.cooldown = {160, 80, 56, 40}
tt.hero.skills.ultimate.damage_boss = {500, 1000, 1500, 2000}
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.ultimate.xp_gain_factor = 84
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, 39)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_regson_level_up
tt.hero.tombstone_show_time = fts(90)
tt.idle_flip.animations = {"idle"}
tt.info.hero_portrait = "kr3_hero_portraits_0004"
tt.info.portrait = "kr3_info_portraits_heroes_0004"
tt.main_script.insert = hero_regson_insert
tt.main_script.update = hero_regson_update
tt.motion.max_speed = 3.8 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.3
tt.render.sprites[1].prefix = "hero_regson"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"run"}
tt.render.sprites[1].name = "idle"
tt.soldier.melee_slot_offset = vec_2(2, 0)
tt.sound_events.change_rally_point = "ElvesHeroEldritchTaunt"
tt.sound_events.death = "ElvesHeroEldritchDeath"
tt.sound_events.respawn = "ElvesHeroEldritchTauntIntro"
tt.sound_events.insert = "ElvesHeroEldritchTauntIntro"
tt.sound_events.hero_room_select = "ElvesHeroEldritchTauntSelect"
tt.unit.hit_offset = vec_2(0, 16)
tt.unit.mod_offset = vec_2(0, 14)
tt.melee.attacks[1].animation = "attack3"
tt.melee.attacks[1].damage_type = DAMAGE_TRUE
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].xp_gain_factor = 2.8
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].chance = 0.5
tt.melee.attacks[3] = CC("melee_attack")
tt.melee.attacks[3].animations = {nil, "berserk_attack"}
tt.melee.attacks[3].damage_type = bor(DAMAGE_TRUE, DAMAGE_NO_DODGE, DAMAGE_FX_EXPLODE)
tt.melee.attacks[3].disabled = true
tt.melee.attacks[3].hit_times = {fts(10), fts(24)}
tt.melee.attacks[3].interrupt_on_dead_target = true
tt.melee.attacks[3].loops = 1
tt.melee.attacks[3].shared_cooldown = true
tt.melee.attacks[3].sound_hit = "ElvesHeroEldritchBlade"
tt.melee.attacks[3].xp_from_skill = "blade"
tt.melee.attacks[4] = table.deepclone(tt.melee.attacks[3])
tt.melee.attacks[4].chance = nil
tt.melee.attacks[4].damage_type = DAMAGE_INSTAKILL
tt.melee.attacks[4].vis_bans = bor(F_BOSS)
tt.melee.attacks[4].vis_flags = bor(F_INSTAKILL)
tt.melee.attacks[5] = CC("area_attack")
tt.melee.attacks[5].animation = "whirlwind"
tt.melee.attacks[5].cooldown = 12
tt.melee.attacks[5].count = 100
tt.melee.attacks[5].damage_radius = 100
tt.melee.attacks[5].damage_type = DAMAGE_NONE
tt.melee.attacks[5].disabled = true
tt.melee.attacks[5].hit_time = fts(5)
tt.melee.attacks[5].mod = "mod_regson_slash"
tt.melee.attacks[5].sound = "ElvesHeroEldritchSlash"
tt.melee.attacks[5].xp_from_skill = "slash"
tt.melee.cooldown = 0.6
tt.melee.range = 65
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].animation = "whirlwind_mirage"
tt.timed_attacks.list[1].cooldown = 30
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].fade_time = fts(4)
tt.timed_attacks.list[1].fade_start_end_time = fts(7)
tt.timed_attacks.list[1].sound = "ElvesHeroEldritchSlash"
tt.timed_attacks.list[1].loops = 3
tt.timed_attacks.list[1].min_count = 3
tt.timed_attacks.list[1].range = 160
tt.timed_attacks.list[1].damage_radius = 100
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED, F_AREA)
tt.timed_attacks.list[1].vis_bans = F_FLYING
tt.timed_attacks.list[1].mod = "mod_regson_slash"
tt.ultimate = {
	ts = 0,
	cooldown = 32,
	disabled = true,
	range = 160
}
tt.path_extra = 0
tt = RT("aura_regson_blade", "aura")
tt.aura.duration = -1
tt.main_script.update = aura_regson_blade_update
tt.blade_cooldown = 25
tt.blade_duration = 6
tt = RT("aura_regson_heal", "aura")
tt.aura.duration = -1
tt.aura.radius = 150
tt.aura.cycle_time = fts(12)
tt.aura.vis_bans = bor(F_BOSS)
tt.aura.vis_flags = bor(F_RANGED)
tt.main_script.update = aura_regson_heal_update
tt = RT("mod_regson_heal", "modifier")
tt.modifier.duration = fts(40)
tt.main_script.update = mod_regson_heal_update
tt = RT("mod_regson_slash", "modifier")

AC(tt, "render")

tt.damage_type = DAMAGE_PHYSICAL
tt.delay_per_idx = 0.13
tt.hit_time = fts(4)
tt.main_script.update = mod_regson_slash_update
tt.modifier.duration = fts(11)
tt.render.sprites[1].name = "fx_regson_slash"
tt.render.sprites[1].sort_y_offset = -2
tt.render.sprites[1].loop = false
tt.modifier.allows_duplicates = true
tt = RT("hero_regson_ultimate")

AC(tt, "pos", "main_script", "sound_events", "render")

tt.main_script.update = hero_regson_ultimate_update
tt.render.sprites[1].name = "fx_regson_ultimate"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_EFFECTS
tt.sound_events.insert = "ElvesHeroEldritchVindicator"
tt.range = 50
tt.vis_flags = F_RANGED
tt.vis_bans = 0
tt.hit_time = fts(20)
