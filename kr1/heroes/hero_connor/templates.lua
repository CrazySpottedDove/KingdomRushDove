local bit = require("bit")
local E = require("entity_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")

require("all.constants")
require("lib.klua.table")

local bor = bit.bor
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local queue_damage = U.queue_damage
local fts = U.fts

---天赋生效时的技能伤害倍率
---@param this table 英雄实体
---@return number
local function connor_skill_factor(this)
	local t = this.hero.skills.talent_1

	if t.level > 0 and this.health.hp <= this.health.hp_max * t.hp_ptg_to_trigger then
		return t.skill_damage_factor
	end

	return 1
end

---按英雄实时伤害属性结算技能伤害
---@param this table 英雄实体
---@param base number 基础伤害
---@return number
local function connor_skill_damage(this, base)
	return math.ceil((base + this.unit.damage_buff) * this.unit.damage_factor * connor_skill_factor(this))
end

local function aura_connor_damage_update(this, store)
	local a = this.aura
	local source = store.entities[a.source_id]

	if not source then
		simulation:queue_remove_entity(this)

		return
	end

	a.ts = store.tick_ts

	local last_hit_ts = 0
	local cycles = 0

	while true do
		if a.cycles and cycles >= a.cycles then
			break
		end

		if a.track_source then
			source = store.entities[a.source_id]

			if not source or source.health and source.health.dead then
				break
			end

			this.pos.x, this.pos.y = source.pos.x, source.pos.y
		end

		if store.tick_ts - last_hit_ts >= a.cycle_time then
			last_hit_ts = store.tick_ts
			cycles = cycles + 1

			local factor = 1

			if source.hero and not a.no_talent_buff then
				factor = connor_skill_factor(source)
			end

			local targets = U.find_enemies_in_range(store, this.pos, 0, a.radius, a.vis_flags, a.vis_bans)

			if targets then
				for _, target in ipairs(targets) do
					local value = (math.random(a.damage_min, a.damage_max) + source.unit.damage_buff) * source.unit.damage_factor * factor
					local d = E.assign_damage(a.damage_type, math.ceil(value), this.id, target.id)

					queue_damage(store, d)

					if a.mod then
						local mod = E:create_entity(a.mod)

						mod.modifier.source_id = this.id
						mod.modifier.target_id = target.id

						simulation:queue_insert_entity(mod)
					end
				end
			end
		end

		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

local function controller_connor_ultimate_sparks_update(this, store)
	local target = store.entities[this.source_id]

	if not target then
		simulation:queue_remove_entity(this)

		return
	end

	local last_ts = 0

	while true do
		target = store.entities[this.source_id]

		if not target or target.health.dead then
			simulation:queue_remove_entity(this)

			return
		end

		if store.tick_ts - last_ts >= fts(3) and target.render.sprites[1].name and string.sub(target.render.sprites[1].name, 1, 6) == "attack" then
			last_ts = store.tick_ts

			local fx = E:create_entity(this.fx_t)

			fx.pos.x, fx.pos.y = target.pos.x, target.pos.y
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].flip_x = target.render.sprites[1].flip_x

			simulation:queue_insert_entity(fx)
		end

		coroutine.yield()
	end
end

local function mod_connor_ultimate_buff_insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead then
		return false
	end

	this._old_damage_factor = target.unit.damage_factor
	target.unit.damage_factor = this.base_damage_factor
	this._old_melee_cooldown = target.melee.cooldown
	target.melee.cooldown = this.ultimate_melee_cooldown

	return true
end

local function mod_connor_ultimate_buff_remove(this, store)
	local target = store.entities[this.modifier.target_id]

	if target then
		target.unit.damage_factor = this._old_damage_factor
		target.melee.cooldown = this._old_melee_cooldown
	end

	return true
end

local function mod_connor_talent_1_update(this, store)
	local target = store.entities[this.modifier.source_id]

	if not target then
		simulation:queue_remove_entity(this)

		return
	end

	local shown = false

	while true do
		target = store.entities[this.modifier.source_id]

		if not target or target.health.dead then
			simulation:queue_remove_entity(this)

			return
		end

		this.pos = target.pos

		local active = target.health.hp <= target.health.hp_max * this.hp_ptg_to_trigger

		if active and not shown then
			this.render.sprites[1].hidden = false

			U.animation_start(this, "in", nil, store.tick_ts, false)
			U.animation_start(this, "loop", nil, store.tick_ts, true)

			shown = true
		elseif not active and shown then
			U.animation_start(this, "out", nil, store.tick_ts, false)
			shown = false
		end

		coroutine.yield()
	end
end

local function hero_connor_level_up(this, store)
	if this.hero.level > 1 then
		S:queue(this.sound_events.level_up)
	end

	local hl, ls = level_up_basic(this)
	local melee = this.melee.attacks[1]

	melee.damage_min = ls.melee_damage_min[hl]
	melee.damage_max = ls.melee_damage_max[hl]

	for i = 1, #this.ultimate_melee.attacks do
		local a = this.ultimate_melee.attacks[i]

		a.damage_min = ls.melee_damage_min[hl]
		a.damage_max = ls.melee_damage_max[hl]
	end

	upgrade_skill(this, "skill_a", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.damage_min = s.damage_min[s.level]
		a.damage_max = s.damage_max[s.level]
		a.bleed_duration = s.bleed_duration[s.level]
	end)
	upgrade_skill(this, "skill_b", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]
		a.damage_min = s.damage_min[s.level]
		a.damage_max = s.damage_max[s.level]
	end)
	upgrade_skill(this, "skill_c", function(this, s)
		local a = this.timed_attacks.list[3]

		a.disabled = nil
		a.aoe_count = s.aoe_count[s.level]
		a.damage_min = s.damage_min[s.level]
		a.damage_max = s.damage_max[s.level]
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		this.timed_attacks.list[4].disabled = nil
	end)
	update_hp(this)
end

local function hero_connor_update(this, store)
	local h = this.health
	local sk = this.hero.skills
	local sa, sb, sc, su, st1, st2 = sk.skill_a, sk.skill_b, sk.skill_c, sk.ultimate, sk.talent_1, sk.talent_2
	local saa = this.timed_attacks.list[1]
	local sba = this.timed_attacks.list[2]
	local sca = this.timed_attacks.list[3]
	local ua = this.timed_attacks.list[4]
	local brk, sta

	this.health_bar.hidden = false

	U.animation_start(this, "idle", nil, store.tick_ts, true)

	local cdf = this.unit.cooldown_factor or 1

	saa.ts = store.tick_ts - saa.cooldown * cdf
	sba.ts = store.tick_ts - sba.cooldown * cdf
	sca.ts = store.tick_ts - sca.cooldown
	ua.ts = store.tick_ts - ua.cooldown * cdf

	local sba_ts = sba.ts
	local st2_ts = store.tick_ts - st2.cooldown + st2.starting_cd
	local ready_to_block = false
	local block_started_ts = 0
	local blocked = false
	local in_ult = false
	local ult_ts = 0
	local ult_mod, ult_spd_mod, ult_spark_c

	if st1.level > 0 and not this.hero.talent_1_mod then
		local mod = E:create_entity(st1.mod_t)

		mod.modifier.source_id = this.id
		mod.modifier.target_id = this.id

		simulation:queue_insert_entity(mod)

		this.hero.talent_1_mod = true
	end

	local function cancel_block()
		ready_to_block = false
		this.dodge.chance = 0
		sba_ts = store.tick_ts
		sba.ts = store.tick_ts
	end

	local function check_end_ult()
		if in_ult and store.tick_ts - ult_ts > ua.duration then
			U.y_animation_play(this, ua.animation_out, nil, store.tick_ts, 1)

			this.render.sprites[1].prefix = this._old_prefix
			this.melee.attacks = this._old_melee_attacks
			this.melee.order = U.attack_order(this.melee.attacks)
			this.melee.cooldown = this._old_melee_cooldown

			simulation:queue_remove_entity(ult_mod)
			simulation:queue_remove_entity(ult_spd_mod)
			simulation:queue_remove_entity(ult_spark_c)

			this.health.ignore_damage = false
			in_ult = false
			ua.ts = store.tick_ts

			U.animation_start(this, "idle", nil, store.tick_ts, true)

			return true
		end

		return false
	end

	while true do
		if h.dead then
			if st2.level > 0 and store.tick_ts - st2_ts > st2.cooldown and math.random() < st2.chance_to_revive then
				h.dead = false
				this.health_bar.hidden = false
				this.ui.can_click = true
				h.hp = h.hp_max * st2.hp_ptg_on_revive
				this.force_respawn = nil
				h.ignore_damage = false

				U.y_animation_play(this, "lvl_up", nil, store.tick_ts, 1)

				st2_ts = store.tick_ts
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
				U.y_animation_play(this, "lvl_up", nil, store.tick_ts, 1)
			end

			if not in_ult and not sba.disabled then
				if not ready_to_block and store.tick_ts - sba_ts > sba.cooldown * (this.unit.cooldown_factor or 1) and this.soldier.target_id ~= nil and this.motion.arrived then
					ready_to_block = true
					block_started_ts = store.tick_ts
					this.dodge.chance = 1
				end

				if ready_to_block and store.tick_ts - block_started_ts > sba.time_to_block then
					cancel_block()
				end

				blocked = ready_to_block and this.dodge.last_doge_ts ~= nil
			end

			if not in_ult and not ua.disabled and ready_to_use_skill(ua, store, this.unit.cooldown_factor) and h.hp < h.hp_max * ua.hp_ptg_to_trigger and this.soldier.target_id ~= nil and this.motion.arrived then
				local a = ua
				local start_ts = store.tick_ts
				local enemies = U.find_enemies_in_range(store, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if not enemies or #enemies < a.min_targets then
					ua.ts = ua.ts + fts(10)
				else
					cancel_block()
					this.health.ignore_damage = true

					U.animation_start(this, a.animation_in, nil, store.tick_ts, false)
					S:queue(a.sound, {
						delay = fts(11)
					})
					S:queue(a.ult_taunt)

					if SU.y_hero_wait(store, this, a.cast_time) then
						goto continue
					end

					S:queue(a.sound_hit)

					ua.ts = start_ts

					SU.hero_gain_xp_from_skill(this, su)

					local aura = E:create_entity(a.aura_t)

					aura.pos.x, aura.pos.y = this.pos.x, this.pos.y
					aura.aura.source_id = this.id
					aura.aura.ts = store.tick_ts

					simulation:queue_insert_entity(aura)

					local decal = E:create_entity(a.decal_t)

					decal.pos.x, decal.pos.y = this.pos.x, this.pos.y
					decal.render.sprites[1].ts = store.tick_ts
					decal.render.sprites[1].flip_x = this.render.sprites[1].flip_x

					simulation:queue_insert_entity(decal)
					SU.y_hero_animation_wait(this)

					this._old_prefix = this.render.sprites[1].prefix
					this.render.sprites[1].prefix = this.hero.ultimate_prefix
					this._old_melee_attacks = this.melee.attacks
					this._old_melee_cooldown = this.melee.cooldown
					this.melee.attacks = this.ultimate_melee.attacks
					this.melee.order = U.attack_order(this.melee.attacks)

					ult_mod = E:create_entity(a.mod)
					ult_mod.modifier.target_id = this.id
					simulation:queue_insert_entity(ult_mod)

					ult_spd_mod = E:create_entity(a.speed_mod)
					ult_spd_mod.modifier.target_id = this.id
					simulation:queue_insert_entity(ult_spd_mod)

					ult_spark_c = E:create_entity(this.hero.ultimate_sparks_controller_t)
					ult_spark_c.source_id = this.id
					simulation:queue_insert_entity(ult_spark_c)

					in_ult = true
					ult_ts = store.tick_ts

					U.animation_start(this, "idle", nil, store.tick_ts, true)

					goto continue
				end
			end

			if not in_ult and not ready_to_block and not sca.disabled and ready_to_use_skill(sca, store, this.unit.cooldown_factor) and this.soldier.target_id == nil then
				local a = sca
				local enemies = U.find_enemies_in_range(store, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if not enemies or #enemies < a.min_targets then
					sca.ts = sca.ts + fts(10)

					goto label_skills
				end

				local nearest = P:nearest_nodes(this.pos.x, this.pos.y)

				if not nearest or #nearest == 0 then
					sca.ts = sca.ts + fts(10)

					goto label_skills
				end

				local targets = table.filter(enemies, function(k, v)
					local vpi = v.nav_path.pi
					local vnearest = P:nearest_nodes(this.pos.x, this.pos.y, {vpi})
					local v_pi, v_spi, v_ni, v_distance = unpack(vnearest[1])

					if v_distance < 50 and (not store.level.ignore_walk_backwards_paths or not table.contains(store.level.ignore_walk_backwards_paths, vpi)) and P:is_path_active(vpi) and v_ni > v.nav_path.ni then
						return true
					end

					return false
				end)

				if not targets or #targets < a.min_targets then
					sca.ts = sca.ts + fts(10)

					goto label_skills
				end

				local start_ts = store.tick_ts

				S:queue(a.sound_jump)
				S:queue(a.sound_taunt)

				local flip = targets[1].pos.x < this.pos.x

				U.animation_start(this, a.animation, flip, store.tick_ts, false)

				if SU.y_hero_wait(store, this, a.cast_time) then
					goto continue
				end

				sca.ts = start_ts

				SU.hero_gain_xp_from_skill(this, sc)
				S:queue(a.sound_impact)

				local nodes_between_aoe = a.node_between_aoes
				local nearest_target = P:nearest_nodes(this.pos.x, this.pos.y, {targets[1].nav_path.pi})
				local pi, spi, ni = unpack(nearest_target[1])

				local function spawn_area_damage(pi, spi, ni)
					local pos = P:node_pos(pi, spi, ni)
					local mid_pos = P:node_pos(pi, 1, ni)
					local y_random = mid_pos.y > pos.y and math.random(5, 10) or math.random(-10, -5)

					pos.x = pos.x + math.random(-4, 4)
					pos.y = pos.y + y_random

					local au = E:create_entity(a.aura_t)

					au.pos = V.vclone(pos)
					au.aura.source_id = this.id
					au.aura.damage_min = a.damage_min
					au.aura.damage_max = a.damage_max

					simulation:queue_insert_entity(au)

					local d = E:create_entity(a.decal_t)

					d.pos = V.vclone(pos)
					d.render.sprites[1].flip_x = this.render.sprites[1].flip_x
					d.render.sprites[1].ts = store.tick_ts

					simulation:queue_insert_entity(d)
				end

				ni = ni - 2

				local count = a.aoe_count / 2
				local count_ceil = math.ceil(a.aoe_count / 2)
				local ni_aux
				local d = E:create_entity(a.decal_ground)

				d.pos = V.vclone(this.pos)
				d.render.sprites[1].ts = store.tick_ts

				simulation:queue_insert_entity(d)

				for i = 1, count_ceil do
					ni_aux = ni - i * nodes_between_aoe

					if P:is_node_valid(pi, ni_aux) then
						spawn_area_damage(pi, 2, ni_aux)
						U.y_wait(store, fts(1))
					end

					if count < i then
						break
					end

					ni_aux = ni - i * (nodes_between_aoe + 1)

					if P:is_node_valid(pi, ni_aux) then
						spawn_area_damage(pi, 3, ni_aux)
						U.y_wait(store, fts(1))
					end
				end

				S:queue(a.sound_out)

				SU.y_hero_animation_wait(this)
				U.animation_start(this, "idle", nil, store.tick_ts, true)

				goto continue
			end

			::label_skills::

			if not in_ult and not ready_to_block and not saa.disabled and ready_to_use_skill(saa, store, this.unit.cooldown_factor) and this.motion.arrived then
				local a = saa
				local start_ts = store.tick_ts
				local enemies = U.find_enemies_in_range(store, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if not enemies or #enemies < a.min_targets then
					saa.ts = saa.ts + fts(10)
				else
					U.animation_start(this, a.animation, nil, store.tick_ts, false)
					S:queue(a.sound)

					if SU.y_hero_wait(store, this, a.cast_time) then
						goto continue
					end

					saa.ts = start_ts

					SU.hero_gain_xp_from_skill(this, sa)

					local hit_pos = V.vclone(this.pos)

					local targets = U.find_enemies_in_range(store, hit_pos, 0, a.damage_radius, a.vis_flags, a.vis_bans)

					if targets then
						for _, target in ipairs(targets) do
							local d = E:create_entity("damage")

							d.source_id = this.id
							d.target_id = target.id
							d.damage_type = a.damage_type
							d.value = connor_skill_damage(this, math.random(a.damage_min, a.damage_max))

							queue_damage(store, d)

							local mod = E:create_entity(a.mod_bleed)

							mod.modifier.source_id = this.id
							mod.modifier.target_id = target.id
							mod.modifier.duration = a.bleed_duration
							mod.modifier.damage_factor = this.unit.damage_factor

							simulation:queue_insert_entity(mod)
						end
					end

					local decal = E:create_entity(a.decal)

					decal.pos = V.vclone(this.pos)

					for i = 1, #decal.render.sprites do
						decal.render.sprites[i].ts = store.tick_ts
						decal.render.sprites[i].flip_x = this.render.sprites[i].flip_x
					end

					simulation:queue_insert_entity(decal)

					SU.y_hero_animation_wait(this)
					U.animation_start(this, "idle", nil, store.tick_ts, true)

					goto continue
				end
			end

			if not in_ult and not sba.disabled and ready_to_block and blocked and this.soldier.target_id ~= nil and this.motion.arrived then
				blocked = false
				cancel_block()
				this.dodge.last_doge_ts = nil

				local a = sba
				local start_ts = store.tick_ts
				local target = store.entities[this.soldier.target_id]

				if target then
					U.animation_start(this, a.animation, target.pos.x < this.pos.x, store.tick_ts, false)
					S:queue(a.sound, {
						delay = fts(11)
					})

					if SU.y_hero_wait(store, this, a.cast_time) then
						goto continue
					end

					sba_ts = start_ts
					sba.ts = start_ts

					SU.hero_gain_xp_from_skill(this, sb)

					local d = E:create_entity("damage")

					d.source_id = this.id
					d.target_id = target.id
					d.damage_type = a.damage_type
					d.value = connor_skill_damage(this, math.random(a.damage_min, a.damage_max))

					queue_damage(store, d)

					if a.hit_fx then
						local fx = E:create_entity(a.hit_fx)

						fx.pos = V.vclone(this.pos)

						for i = 1, #fx.render.sprites do
							fx.render.sprites[i].ts = store.tick_ts
							fx.render.sprites[i].flip_x = this.render.sprites[1].flip_x
						end

						simulation:queue_insert_entity(fx)
					end

					SU.y_hero_animation_wait(this)
					U.animation_start(this, "idle", nil, store.tick_ts, true)

					goto continue
				end
			end

			if check_end_ult() then
			else
				brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

				if brk or sta ~= A_NO_TARGET then
				elseif SU.soldier_go_back_step(store, this) then
				else
					SU.soldier_idle(store, this)
					SU.soldier_regen(store, this)
				end
			end
		end

		::continue::

		coroutine.yield()
	end
end

local tt

tt = RT("hero_connor", "hero")
AC(tt, "melee", "timed_attacks", "dodge")
tt.hero.level_stats.armor = {0.07, 0.09, 0.11, 0.13, 0.15, 0.17, 0.19, 0.21, 0.23, 0.25}
tt.hero.level_stats.hp_max = {200, 215, 230, 245, 260, 275, 290, 305, 320, 335}
tt.hero.level_stats.melee_damage_min = {13, 14, 15, 17, 18, 20, 21, 22, 24, 25}
tt.hero.level_stats.melee_damage_max = {19, 21, 23, 25, 27, 29, 32, 34, 36, 38}
tt.hero.skills.skill_a = CC("hero_skill")
tt.hero.skills.skill_a.cooldown = 16
tt.hero.skills.skill_a.damage_min = {12, 32, 52}
tt.hero.skills.skill_a.damage_max = {18, 48, 78}
tt.hero.skills.skill_a.bleed_duration = {4, 6, 8}
tt.hero.skills.skill_a.xp_gain = {64, 128, 192}
tt.hero.skills.skill_a.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.skill_b = CC("hero_skill")
tt.hero.skills.skill_b.cooldown = {25, 22, 19}
tt.hero.skills.skill_b.damage_min = {64, 80, 96}
tt.hero.skills.skill_b.damage_max = {96, 120, 144}
tt.hero.skills.skill_b.xp_gain = {100, 200, 300}
tt.hero.skills.skill_b.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.skill_c = CC("hero_skill")
tt.hero.skills.skill_c.cooldown = 22
tt.hero.skills.skill_c.damage_min = {44, 54, 74}
tt.hero.skills.skill_c.damage_max = {68, 82, 106}
tt.hero.skills.skill_c.aoe_count = {4, 6, 8}
tt.hero.skills.skill_c.xp_gain = {88, 176, 264}
tt.hero.skills.skill_c.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.xp_gain = {120}
tt.hero.skills.ultimate.xp_level_steps = {
	[5] = 1
}
tt.hero.skills.talent_1 = CC("hero_skill")
tt.hero.skills.talent_1.hp_ptg_to_trigger = 0.4
tt.hero.skills.talent_1.skill_damage_factor = 1.4
tt.hero.skills.talent_1.mod_t = "mod_connor_talent_1"
tt.hero.skills.talent_1.xp_level_steps = {
	[1] = 1
}
tt.hero.skills.talent_2 = CC("hero_skill")
tt.hero.skills.talent_2.chance_to_revive = 1
tt.hero.skills.talent_2.cooldown = 180
tt.hero.skills.talent_2.hp_ptg_on_revive = 0.7
tt.hero.skills.talent_2.starting_cd = 0
tt.hero.skills.talent_2.xp_level_steps = {
	[1] = 1
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, 45)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_connor_level_up
tt.hero.respawn_animation = "respawn"
tt.hero.tombstone_show_time = fts(43)
tt.hero.tombstone_decal = "decal_connor_tombstone"
tt.hero.tombstone_concurrent_with_death = true
tt.hero.ultimate_prefix = "oconnor_ultDef"
tt.hero.ultimate_sparks_controller_t = "controller_connor_ultimate_sparks"
tt.info.hero_portrait = "kr6_hero_portraits_0004"
tt.info.portrait = "kr6_info_portraits_heroes_0010"
tt.main_script.update = hero_connor_update
tt.motion.max_speed = 70
tt.regen.cooldown = 1
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].prefix = "oconnorDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].draw_order = DO_HEROES
tt.render.sprites[1].scale = vec_2(1, 1)
tt.sound_events.change_rally_point = "HeroConnorTaunt"
tt.sound_events.death = "HeroConnorDeath"
tt.sound_events.insert = "HeroConnorTauntIntro"
tt.sound_events.level_up = "HeroConnorTauntLevelUp"
tt.sound_events.respawn = "HeroConnorTauntIntro"
tt.sound_events.hero_room_select = "HeroConnorTauntSelect"
tt.soldier.melee_slot_offset = vec_2(10, 0)
tt.ui.click_rect = r(-22, -5, 44, 43)
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 12)
tt.unit.marker_offset = vec_2(0, -1)
tt.unit.mod_offset = vec_2(0, 19.9)
tt.unit.pop_offset = vec_2(0, 15)
tt.dodge.chance = 0
tt.dodge.show_pop = true
tt.dodge.silent = true
tt.dodge.pop = "pop_zap"
tt.dodge.ranged = false
tt.melee.cooldown = 1.75
tt.melee.range = 78
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].animation = "attack_2"
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_time = fts(16)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 1.8
tt.melee.attacks[1].hit_fx = "fx_connor_hit"
tt.melee.attacks[1].hit_offset = vec_2(40, 15)
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].animation = "slash"
tt.timed_attacks.list[1].cooldown = 16
tt.timed_attacks.list[1].cast_time = fts(18)
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].max_range = 100
tt.timed_attacks.list[1].min_targets = 3
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[1].vis_flags = bor(F_AREA, F_ENEMY)
tt.timed_attacks.list[1].damage_min = 12
tt.timed_attacks.list[1].damage_max = 18
tt.timed_attacks.list[1].damage_radius = 170
tt.timed_attacks.list[1].damage_type = DAMAGE_PHYSICAL
tt.timed_attacks.list[1].mod_bleed = "mod_connor_skill_a_bleed"
tt.timed_attacks.list[1].decal = "decal_connor_skill_a"
tt.timed_attacks.list[1].sound = "HeroConnorArterialSlashCast"
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].animation = "retribution"
tt.timed_attacks.list[2].cooldown = 25
tt.timed_attacks.list[2].cast_time = fts(28)
tt.timed_attacks.list[2].time_to_block = 2
tt.timed_attacks.list[2].damage_min = 64
tt.timed_attacks.list[2].damage_max = 96
tt.timed_attacks.list[2].damage_type = DAMAGE_PHYSICAL
tt.timed_attacks.list[2].hit_fx = "fx_connor_skill_b_hit"
tt.timed_attacks.list[2].sound = "HeroConnorRetributionCast"
tt.timed_attacks.list[3] = CC("custom_attack")
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].animation = "earthshatter"
tt.timed_attacks.list[3].cooldown = 22
tt.timed_attacks.list[3].min_range = 0
tt.timed_attacks.list[3].max_range = 190
tt.timed_attacks.list[3].min_targets = 3
tt.timed_attacks.list[3].cast_time = fts(48)
tt.timed_attacks.list[3].aoe_count = 4
tt.timed_attacks.list[3].node_between_aoes = 5
tt.timed_attacks.list[3].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[3].vis_flags = bor(F_AREA)
tt.timed_attacks.list[3].aura_t = "aura_connor_skill_c"
tt.timed_attacks.list[3].decal_t = "decal_connor_skill_c"
tt.timed_attacks.list[3].decal_ground = "decal_connor_ultimate_stun"
tt.timed_attacks.list[3].sound_jump = "HeroConnorEarthshatterJump"
tt.timed_attacks.list[3].sound_impact = "HeroConnorEarthshatterImpact"
tt.timed_attacks.list[4] = CC("custom_attack")
tt.timed_attacks.list[4].disabled = true
tt.timed_attacks.list[4].animation_in = "ult_in"
tt.timed_attacks.list[4].animation_out = "ult_out"
tt.timed_attacks.list[4].cooldown = 30
tt.timed_attacks.list[4].min_range = 0
tt.timed_attacks.list[4].max_range = 120
tt.timed_attacks.list[4].min_targets = 1
tt.timed_attacks.list[4].duration = 10
tt.timed_attacks.list[4].hp_ptg_to_trigger = 0.8
tt.timed_attacks.list[4].cast_time = fts(2)
tt.timed_attacks.list[4].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[4].vis_flags = bor(F_AREA)
tt.timed_attacks.list[4].aura_t = "aura_connor_ultimate_stun"
tt.timed_attacks.list[4].decal_t = "decal_connor_ultimate_stun"
tt.timed_attacks.list[4].mod = "mod_connor_ultimate_buff"
tt.timed_attacks.list[4].speed_mod = "mod_connor_ultimate_speed_buff"
tt.timed_attacks.list[4].sound = "HeroConnorTemplarRageCast"
tt.timed_attacks.list[4].ult_taunt = "HeroConnorTauntUltimate"
tt.ultimate_melee = {}
tt.ultimate_melee.attacks = {}
tt.ultimate_melee.attacks[1] = CC("melee_attack")
tt.ultimate_melee.attacks[1].animation = "attack_1"
tt.ultimate_melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.ultimate_melee.attacks[1].hit_time = fts(6)
tt.ultimate_melee.attacks[1].shared_cooldown = true
tt.ultimate_melee.attacks[1].cooldown = 1
tt.ultimate_melee.attacks[1].sound = "HeroConnorTemplarRageBasicAttackCast"
tt.ultimate_melee.attacks[1].vis_bans = bor(F_CLIFF)
tt.ultimate_melee.attacks[1].vis_flags = F_BLOCK
tt.ultimate_melee.attacks[1].xp_gain_factor = 1.6
tt.ultimate_melee.attacks[1].hit_fx = "fx_connor_ultimate_hit"
tt.ultimate_melee.attacks[1].hit_offset = vec_2(40, 15)
tt.ultimate_melee.attacks[2] = table.deepclone(tt.ultimate_melee.attacks[1])
tt.ultimate_melee.attacks[2].animation = "attack_2"
tt.ultimate_melee.attacks[2].chance = 0.33
tt.ultimate_melee.attacks[2].hit_time = fts(10)
tt.ultimate_melee.attacks[3] = table.deepclone(tt.ultimate_melee.attacks[1])
tt.ultimate_melee.attacks[3].animation = "attack_3"
tt.ultimate_melee.attacks[3].chance = 0.33
tt.ultimate_melee.attacks[3].hit_time = fts(12)

tt = RT("fx_connor_hit", "fx")
tt.render.sprites[1].prefix = "connor_fx_hit_comun"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].z = Z_EFFECTS

tt = RT("fx_connor_skill_b_hit", "fx")
tt.render.sprites[1].prefix = "connor_fx_retribution"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].z = Z_EFFECTS

tt = RT("fx_connor_ultimate_sparks", "fx")
tt.render.sprites[1].prefix = "connor_fx_chispas"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].z = Z_EFFECTS

tt = RT("fx_connor_ultimate_hit", "fx")
tt.render.sprites[1].prefix = "connor_fx_hit_ult"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].z = Z_EFFECTS

tt = RT("decal_connor_tombstone", "decal")
tt.render.sprites[1].prefix = "oconnorDef"
tt.render.sprites[1].name = "death_idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].scale = vec_2(1, 1)

tt = RT("decal_connor_skill_a", "decal_timed")
tt.render.sprites[1].prefix = "connor_fx_slash"
tt.render.sprites[1].name = "run"
tt.timed.runs = 1

tt = RT("decal_connor_skill_c", "decal_timed")
tt.render.sprites[1].prefix = "connor_fx_terremoto_decal"
tt.render.sprites[1].name = "run"
tt.timed.runs = 1

tt = RT("decal_connor_ultimate_stun", "decal_timed")
tt.render.sprites[1].prefix = "connor_fx_stun"
tt.render.sprites[1].name = "run"
tt.timed.runs = 1

tt = RT("aura_connor_skill_c", "aura")
tt.main_script.update = aura_connor_damage_update
tt.aura.duration = 1
tt.aura.cycle_time = 0.9
tt.aura.cycles = 1
tt.aura.damage_type = DAMAGE_PHYSICAL
tt.aura.damage_min = 44
tt.aura.damage_max = 68
tt.aura.radius = 40
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)

tt = RT("aura_connor_ultimate_stun", "aura")
tt.main_script.update = aura_connor_damage_update
tt.aura.duration = 1
tt.aura.cycle_time = 0.9
tt.aura.cycles = 1
tt.aura.no_talent_buff = true
tt.aura.mod = "mod_connor_ultimate_stun"
tt.aura.damage_type = DAMAGE_PHYSICAL
tt.aura.damage_min = 20
tt.aura.damage_max = 20
tt.aura.radius = 100
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)

tt = RT("mod_connor_skill_a_bleed", "mod_blood")
tt.dps.damage_every = 0.25
tt.dps.damage_min = 1
tt.dps.damage_max = 1
tt.dps.damage_inc = 0
tt.dps.kill = true
tt.modifier.duration = 4
tt.modifier.vis_flags = bor(F_MOD, F_BLOOD)
tt.modifier.vis_bans = 0

tt = RT("mod_connor_ultimate_stun", "mod_stun")
tt.modifier.duration = 1
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt.modifier.vis_bans = bor(F_BOSS)

tt = RT("mod_connor_ultimate_buff", "modifier")
AC(tt, "main_script")
tt.base_damage_factor = 2
tt.ultimate_melee_cooldown = 1
tt.main_script.insert = mod_connor_ultimate_buff_insert
tt.main_script.remove = mod_connor_ultimate_buff_remove
tt.modifier.vis_flags = bor(F_MOD, F_HERO)
tt.modifier.vis_bans = bor(F_BOSS, F_ENEMY)

tt = RT("mod_connor_ultimate_speed_buff", "mod_slow")
tt.slow.factor = 1.3
tt.modifier.duration = 1e+99
tt.modifier.vis_flags = bor(F_MOD, F_HERO)
tt.modifier.vis_bans = bor(F_BOSS, F_ENEMY)

tt = RT("mod_connor_talent_1", "modifier")
AC(tt, "main_script", "render")
tt.hp_ptg_to_trigger = 0.4
tt.skill_damage_factor = 1.4
tt.main_script.update = mod_connor_talent_1_update
tt.modifier.duration = 1e+99
tt.modifier.vis_flags = bor(F_MOD, F_HERO)
tt.modifier.vis_bans = bor(F_BOSS, F_ENEMY)
tt.render.sprites[1].prefix = "connor_fx_pasiva"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -1
tt.render.sprites[1].animated = true
tt.render.sprites[1].hidden = true

tt = RT("controller_connor_ultimate_sparks")
AC(tt, "main_script")
tt.fx_t = "fx_connor_ultimate_sparks"
tt.main_script.update = controller_connor_ultimate_sparks_update
