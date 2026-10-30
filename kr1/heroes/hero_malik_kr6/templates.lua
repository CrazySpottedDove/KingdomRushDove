local bit = require("bit")
local E = require("entity_db")
local scripts = require("scripts")
local S = require("sound_db")
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

local mod_malik_skill_a_on_damage

local function mod_malik_skill_a_insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead then
		return false
	end

	if band(this.modifier.vis_flags, target.vis.bans) ~= 0 or band(this.modifier.vis_bans, target.vis.flags) ~= 0 then
		return false
	end

	this.modifier.ts = store.tick_ts
	this.on_damage_index = U.insert_on_damage(target, mod_malik_skill_a_on_damage)
	this._blood_color = target.unit.blood_color
	target.unit.blood_color = BLOOD_NONE
	target._shield_mod = this
	this.health.hp = this.shield_max_damage
	this.health.hp_max = this.shield_max_damage

	return true
end

local function mod_malik_skill_a_remove(this, store)
	local target = store.entities[this.modifier.target_id]

	if target then
		U.remove_on_damage(target, this.on_damage_index)

		if target._shield_mod == this then
			target._shield_mod = nil
		end

		target.unit.blood_color = this._blood_color
	end

	return true
end

local function mod_malik_skill_a_update(this, store)
	local m = this.modifier

	this.modifier.ts = store.tick_ts

	local target = store.entities[m.target_id]

	if not target or not target.pos then
		simulation:queue_remove_entity(this)

		return
	end

	this.pos = target.pos

	U.y_animation_play(this, this.animation_start, nil, store.tick_ts, 1)

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead or this.shield_broken or m.duration and store.tick_ts - m.ts > m.duration then
			this.tween.disabled = false
			this.tween.ts = store.tick_ts

			U.y_wait(store, this.tween.props[1].keys[2][1])
			simulation:queue_remove_entity(this)

			return
		end

		U.animation_start(this, this.animation_loop, nil, store.tick_ts, true)
		coroutine.yield()
	end
end

mod_malik_skill_a_on_damage = function(this, store, damage)
	local mod = this._shield_mod

	if not mod or mod.shield_broken then
		return true
	end

	if U.flag_has(damage.damage_type, bor(DAMAGE_INSTAKILL, DAMAGE_DISINTEGRATE, DAMAGE_EAT, DAMAGE_IGNORE_SHIELD)) then
		mod.shield_broken = true
		mod.health.hp = 0

		return true
	end

	mod.damage_taken = mod.damage_taken + damage.value
	mod.health.hp = math.max(mod.shield_max_damage - mod.damage_taken, 0)

	if mod.damage_taken >= mod.shield_max_damage then
		mod.shield_broken = true

		if mod.damage_taken - mod.shield_max_damage > 0 then
			damage.value = mod.damage_taken - mod.shield_max_damage

			return true
		end
	end

	return false
end

local function mod_malik_skill_c_insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target then
		return false
	end

	if band(target.vis.flags, this.modifier.vis_bans) ~= 0 or band(target.vis.bans, this.modifier.vis_flags) ~= 0 then
		return false
	end

	this._entity_frame_names = {}
	this.modifier.ts = store.tick_ts

	for _, es in pairs(target.render.sprites) do
		if es.animated then
			table.insert(this._entity_frame_names, es.frame_name)
		else
			table.insert(this._entity_frame_names, es.name)
		end
	end

	SU.stun_inc(target)

	U.bans_add(target.vis, F_ALL)

	target.ui.can_click = false
	target.ui.can_select = false
	target.health_bar.hidden = true
	target.unit.show_blood_pool = false

	return true
end

local function mod_malik_skill_c_remove(this, store)
	local target = store.entities[this.modifier.target_id]

	if target then
		U.bans_remove(target.vis, F_ALL)
		SU.stun_dec(target)
	end

	return true
end

local function mod_malik_skill_c_update(this, store)
	local m = this.modifier
	local target = store.entities[this.modifier.target_id]

	if not target then
		simulation:queue_remove_entity(this)

		return
	end

	this.pos = target.pos

	local source = store.entities[this.modifier.source_id]
	local is_on_right = source and source.pos.x < this.pos.x
	local is_exo = false

	for _, v in pairs(target.render.sprites) do
		if v.exo then
			is_exo = true

			break
		end
	end

	local es = E:create_entity(this.clone_decal)

	es.pos = V.vclone(target.pos)
	es.pos.y = es.pos.y + this.enemy_move_offset.y

	if is_on_right then
		es.pos.x = es.pos.x + this.enemy_move_offset.x
	else
		es.pos.x = es.pos.x - this.enemy_move_offset.x
	end

	es.tween.ts = store.tick_ts

	local offset_to_center = target.unit.hit_offset.y / 2

	es.render.sprites[1].offset.y = offset_to_center * -1
	es.tween.props[1].keys[2][1] = this.modifier.duration - fts(6)
	es.tween.props[1].keys[3][1] = this.modifier.duration
	es.render.sprites[1].z = Z_BULLETS

	if not is_exo then
		this._decal_clone = es
		es.render = table.deepclone(target.render)

		for i, s in ipairs(es.render.sprites) do
			s.shader = es.shader
			s.shader_args = es.shader_args
			s.animated = false
			s.prefix = nil
			s.name = this._entity_frame_names[i]
		end

		simulation:queue_insert_entity(es)
		coroutine.yield()
		U.sprites_hide(target, nil, nil, true)
	end

	while store.tick_ts - m.ts < m.duration and target and not target.health.dead do
		if is_on_right then
			es.pos.x = es.pos.x + this.fly_speed.x
			es.render.sprites[1].r = es.render.sprites[1].r - this.rotation_speed
		else
			es.pos.x = es.pos.x - this.fly_speed.x
			es.render.sprites[1].r = es.render.sprites[1].r + this.rotation_speed
		end

		es.pos.y = es.pos.y + this.fly_speed.y

		coroutine.yield()
	end

	if target and target.sound_events then
		target.sound_events.death = nil
	end

	local d = E:create_entity("damage")

	d.damage_type = bor(DAMAGE_INSTAKILL, DAMAGE_FX_NOT_EXPLODE, DAMAGE_NO_SPAWNS, DAMAGE_IGNORE_SHIELD)
	d.source_id = this.id
	d.target_id = target.id

	queue_damage(store, d)

	if not is_exo then
		simulation:queue_remove_entity(es)
	end

	simulation:queue_remove_entity(this)
end

local function aura_malik_talent_2_buff_update(this, store)
	local source = store.entities[this.aura.source_id]

	if not source then
		simulation:queue_remove_entity(this)

		return
	end

	local buff_active = false

	local function apply_buff()
		buff_active = true

		local a = source.melee.attacks[1]

		a.damage_min = a.damage_min * this.dmg_factor
		a.damage_max = a.damage_max * this.dmg_factor

		local ls = source.hero.level_stats

		for i = 1, #ls.melee_damage_min do
			ls.melee_damage_min[i] = ls.melee_damage_min[i] * this.dmg_factor
			ls.melee_damage_max[i] = ls.melee_damage_max[i] * this.dmg_factor
		end
	end

	local function remove_buff()
		buff_active = false

		local a = source.melee.attacks[1]

		a.damage_min = a.damage_min / this.dmg_factor
		a.damage_max = a.damage_max / this.dmg_factor

		local ls = source.hero.level_stats

		for i = 1, #ls.melee_damage_min do
			ls.melee_damage_min[i] = ls.melee_damage_min[i] / this.dmg_factor
			ls.melee_damage_max[i] = ls.melee_damage_max[i] / this.dmg_factor
		end
	end

	while true do
		source = store.entities[this.aura.source_id]

		if not source then
			simulation:queue_remove_entity(this)

			return
		end

		this.pos = source.pos

		if not source.health.dead then
			local targets = U.find_targets_in_range(store.entities, source.pos, 0, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans, function(v)
				return v.id ~= source.id
			end)

			if not buff_active and (not targets or #targets == 0) then
				apply_buff()
			end

			if buff_active and targets and #targets > 0 then
				remove_buff()
			end
		end

		coroutine.yield()
	end
end

local function aura_malik_ultimate_update(this, store)
	local a = this.aura

	a.ts = store.tick_ts

	local last_hit_ts = 0

	while store.tick_ts - a.ts < a.duration do
		local source = store.entities[a.source_id]

		if not source or source.health.dead then
			simulation:queue_remove_entity(this)

			return
		end

		this.pos = source.pos

		if store.tick_ts - last_hit_ts >= a.cycle_time then
			last_hit_ts = store.tick_ts

			local targets = U.find_enemies_in_range(store, this.pos, 0, a.radius, a.vis_flags, a.vis_bans)

			if targets then
				for _, target in ipairs(targets) do
					local d = E:create_entity("damage")

					d.source_id = source.id
					d.target_id = target.id
					d.damage_type = a.damage_type
					d.value = math.ceil((math.random(a.damage_min, a.damage_max) + source.unit.damage_buff) * source.unit.damage_factor)

					queue_damage(store, d)

					if a.hit_fx then
						local fx = E:create_entity(a.hit_fx)

						fx.pos = V.vclone(target.pos)
						fx.pos.x, fx.pos.y = fx.pos.x + target.unit.hit_offset.x, fx.pos.y + target.unit.hit_offset.y
						fx.render.sprites[1].ts = store.tick_ts

						simulation:queue_insert_entity(fx)
					end

					if a.mod then
						local mod = E:create_entity(a.mod)

						mod.modifier.source_id = source.id
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

local function hero_malik_level_up(this, store, initial)
	if not initial and this.hero.level > 1 then
		S:queue(this.sound_events.level_up)
	end

	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	upgrade_skill(this, "skill_a", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.cooldown = s.cooldown
		a.duration = s.duration
		a.hp_increase_ptg = s.hp_increase_ptg[s.level]
	end)
	upgrade_skill(this, "skill_b", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.cooldown = s.cooldown
		a.damage_radius = s.damage_radius[s.level]
		a.stun_duration = s.stun_duration[s.level]
	end)
	upgrade_skill(this, "skill_c", function(this, s)
		local a = this.timed_attacks.list[3]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		this.timed_attacks.list[4].disabled = nil
	end)
	upgrade_skill(this, "talent_1", function(this, s)
		local a = this.melee.attacks[1]

		a.type = "area"
		a.hit_decal = s.decal
		a.damage_flags = bor(a.damage_flags, F_AREA)
		a.damage_radius = s.damage_radius
	end)
	upgrade_skill(this, "talent_2", function(this, s)
		this.hero.skills.talent_2.ts = store.tick_ts
	end)
	update_hp(this)
end

local function hero_malik_insert(this, store)
	this.hero.fn_level_up(this, store, true)

	this.melee.order = U.attack_order(this.melee.attacks)

	return true
end

local function hero_malik_update(this, store)
	local h = this.health
	local skills = this.hero.skills
	local sa, sb, sc, su = skills.skill_a, skills.skill_b, skills.skill_c, skills.ultimate
	local saa = this.timed_attacks.list[1]
	local sba = this.timed_attacks.list[2]
	local sca = this.timed_attacks.list[3]
	local ua = this.timed_attacks.list[4]
	local brk, sta, blocker
	local old_tombstone_time = this.hero.tombstone_show_time
	local old_tombstone_respawn_animation = this.hero.tombstone_respawn_animation

	this.health_bar.hidden = false

	U.y_animation_play(this, "lvlup", nil, store.tick_ts, 1)

	saa.ts = store.tick_ts - saa.cooldown * (this.unit.cooldown_factor or 1)
	sba.ts = store.tick_ts - sba.cooldown * (this.unit.cooldown_factor or 1)
	sca.ts = store.tick_ts - sca.cooldown * (this.unit.cooldown_factor or 1)
	ua.ts = store.tick_ts - ua.cooldown * (this.unit.cooldown_factor or 1)

	if skills.talent_2.level > 0 and not this.hero.talent_2_aura then
		local aura = E:create_entity(skills.talent_2.aura)

		aura.pos = V.vclone(this.pos)
		aura.aura.source_id = this.id

		simulation:queue_insert_entity(aura)

		this.hero.talent_2_aura = aura.id
	end

	local function y_malik_new_rally_ultimate(store, anim)
		local r = this.nav_rally

		if r.new then
			r.new = false

			U.unblock_target(store, this)

			if this.sound_events then
				S:queue(this.sound_events.change_rally_point)
			end

			return SU.y_hero_walk_waypoints(store, this, anim)
		end
	end

	while true do
		if h.dead then
			if band(h.last_damage_types, bor(DAMAGE_EAT)) ~= 0 then
				this.hero.tombstone_show_time = nil
				this.hero.tombstone_respawn_animation = nil
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

			if ready_to_use_skill(ua, store, this.unit.cooldown_factor) and this.motion.arrived then
				local a = ua
				local enemies = U.find_enemies_in_range(store, this.pos, 0, a.damage_radius, a.vis_flags, a.vis_bans)

				if not enemies or #enemies < a.min_targets then
					SU.delay_attack(store, a, fts(10))
				else
					S:queue(a.sound_cast)
					S:queue(a.sound_loop, {
						delay = fts(24)
					})
					S:queue(a.sound_taunt)
					U.unblock_target(store, this)
					U.animation_start(this, a.animation_start, nil, store.tick_ts, false)

					if SU.y_hero_wait(store, this, a.cast_time) then
						S:stop(a.sound_loop)

						goto continue
					end

					local ts = store.tick_ts
					local prev_immune = this.health.immune_to

					U.bans_add(this.vis, F_ALL)

					this.health.immune_to = this.nav_rally.immune_to

					local sm = E:create_entity(a.speed_mod)

					sm.modifier.target_id = this.id
					sm.modifier.source_id = this.id

					simulation:queue_insert_entity(sm)

					local au = E:create_entity(a.aura_t)

					au.aura.source_id = this.id
					au.pos = V.vclone(this.pos)

					simulation:queue_insert_entity(au)

					local ps = E:create_entity(a.ps_t)

					ps.pos = V.vclone(this.pos)
					ps.particle_system.track_id = this.id

					simulation:queue_insert_entity(ps)
					U.animation_start(this, a.animation_loop, nil, store.tick_ts, true)

					while store.tick_ts - ts < a.duration do
						if this.nav_rally.new then
							y_malik_new_rally_ultimate(store, a.animation_loop)
						end

						coroutine.yield()
					end

					simulation:queue_remove_entity(ps)
					simulation:queue_remove_entity(au)
					simulation:queue_remove_entity(sm)
					S:stop(a.sound_loop)
					S:queue(a.sound_end)
					SU.hero_gain_xp_from_skill(this, su)
					U.y_animation_play(this, a.animation_end, nil, store.tick_ts, false)

					U.bans_remove(this.vis, F_ALL)

					this.health.immune_to = prev_immune
					a.ts = store.tick_ts

					SU.y_hero_animation_wait(this)
					U.animation_start(this, "idle", nil, store.tick_ts, true)

					goto continue
				end
			end

			blocker = store.entities[this.soldier.target_id]

			if ready_to_use_skill(sca, store, this.unit.cooldown_factor) and this.soldier.target_id ~= nil and this.motion.arrived and blocker and blocker.health and not blocker.health.dead and blocker.health.hp_max <= sca.hp_threshold and blocker.health.hp >= sca.current_hp_threshold and band(blocker.vis.flags, sca.vis_bans) == 0 and band(blocker.vis.bans, sca.vis_flags) == 0 then
				local a = sca
				local start_ts = store.tick_ts

				U.animation_start(this, a.animation, nil, store.tick_ts, false)
				S:queue(a.sound)

				if SU.y_hero_wait(store, this, a.cast_time) then
					goto continue
				end

				if not blocker or not U.is_blocked_valid(store, this) then
					this.soldier.target_id = nil
				else
					a.ts = start_ts

					SU.hero_gain_xp_from_skill(this, sc)

					local mod = E:create_entity(a.mod)

					mod.modifier.source_id = this.id
					mod.modifier.target_id = blocker.id
					mod.enemy_move_offset = a.enemy_move_offset

					simulation:queue_insert_entity(mod)
					SU.y_hero_animation_wait(this)
					U.animation_start(this, "idle", nil, store.tick_ts, true)

					this.soldier.target_id = nil

					goto continue
				end
			end

			if ready_to_use_skill(saa, store, this.unit.cooldown_factor) and this.soldier.target_id ~= nil and this.motion.arrived then
				local blocker = store.entities[this.soldier.target_id]
				local a = saa
				local start_ts = store.tick_ts

				U.animation_start(this, a.animation, nil, store.tick_ts, false)
				S:queue(a.sound)

				if SU.y_hero_wait(store, this, a.cast_time) then
					goto continue
				end

				if not blocker then
					this.soldier.target_id = nil
				else
					a.ts = start_ts

					SU.hero_gain_xp_from_skill(this, sa)

					local mod = E:create_entity(a.mod)

					mod.modifier.duration = a.duration
					mod.modifier.source_id = this.id
					mod.modifier.target_id = this.id
					mod.shield_max_damage = a.shield_base + blocker.health.hp_max * a.hp_increase_ptg

					simulation:queue_insert_entity(mod)
					SU.y_hero_animation_wait(this)
					U.animation_start(this, "idle", nil, store.tick_ts, true)

					goto continue
				end
			end

			if ready_to_use_skill(sba, store, this.unit.cooldown_factor) and this.soldier.target_id ~= nil and this.motion.arrived then
				local a = sba
				local start_ts = store.tick_ts
				local enemies = U.find_enemies_in_range(store, this.pos, 0, a.damage_radius, a.vis_flags, a.vis_bans)

				if not enemies or #enemies < a.min_targets then
					SU.delay_attack(store, a, fts(10))
				else
					U.animation_start(this, a.animation, nil, store.tick_ts, false)
					S:queue(a.sound, {
						delay = fts(11)
					})

					a.ts = start_ts

					if SU.y_hero_wait(store, this, a.cast_time) then
						goto continue
					end

					SU.hero_gain_xp_from_skill(this, sb)

					local hit_pos = V.vclone(this.pos)

					if a.hit_offset then
						hit_pos.x = hit_pos.x + (this.render.sprites[1].flip_x and -1 or 1) * a.hit_offset.x
						hit_pos.y = hit_pos.y + a.hit_offset.y
					end

					local enemies = U.find_enemies_in_range(store, hit_pos, 0, a.damage_radius, a.vis_flags, a.vis_bans)

					if enemies and #enemies > 0 then
						for _, target in ipairs(enemies) do
							local d = E:create_entity("damage")

							d.source_id = this.id
							d.target_id = target.id
							d.damage_type = a.damage_type
							d.value = math.ceil((math.random(a.damage_min, a.damage_max) + this.unit.damage_buff) * this.unit.damage_factor)

							queue_damage(store, d)

							local mod = E:create_entity(a.mod_stun)

							mod.modifier.source_id = this.id
							mod.modifier.target_id = target.id
							mod.modifier.duration = a.stun_duration

							simulation:queue_insert_entity(mod)
						end
					end

					local decal = E:create_entity(a.hit_decal)

					decal.pos = V.vclone(hit_pos)

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

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if this.health.dead then
			-- block empty
			elseif brk or sta ~= A_NO_TARGET then
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

tt = RT("hero_malik_kr6", "hero")
AC(tt, "melee", "timed_attacks")
tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.hp_max = {200, 230, 260, 290, 320, 350, 380, 410, 440, 470}
tt.hero.level_stats.melee_damage_min = {10, 11, 12, 13, 14, 16, 17, 18, 19, 20}
tt.hero.level_stats.melee_damage_max = {14, 16, 18, 20, 22, 23, 25, 27, 29, 31}
tt.hero.skills.skill_a = CC("hero_skill")
tt.hero.skills.skill_a.cooldown = 18
tt.hero.skills.skill_a.duration = 6
tt.hero.skills.skill_a.hp_increase_ptg = {0.3, 0.4, 0.5}
tt.hero.skills.skill_a.xp_gain = {72, 144, 216}
tt.hero.skills.skill_a.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.skill_b = CC("hero_skill")
tt.hero.skills.skill_b.cooldown = 20
tt.hero.skills.skill_b.damage_min = 48
tt.hero.skills.skill_b.damage_max = 72
tt.hero.skills.skill_b.damage_radius = {50, 50, 120}
tt.hero.skills.skill_b.stun_duration = {2, 4, 4}
tt.hero.skills.skill_b.xp_gain = {80, 160, 240}
tt.hero.skills.skill_b.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.skill_c = CC("hero_skill")
tt.hero.skills.skill_c.cooldown = {40, 34, 28}
tt.hero.skills.skill_c.hp_threshold = 1500
tt.hero.skills.skill_c.current_hp_threshold = 80
tt.hero.skills.skill_c.xp_gain = {160, 320, 480}
tt.hero.skills.skill_c.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.cooldown = 28
tt.hero.skills.ultimate.duration = 5
tt.hero.skills.ultimate.min_targets = 3
tt.hero.skills.ultimate.xp_gain = {112}
tt.hero.skills.ultimate.xp_level_steps = {
	[5] = 1
}
tt.hero.skills.talent_1 = CC("hero_skill")
tt.hero.skills.talent_1.damage_radius = 70
tt.hero.skills.talent_1.decal = "decal_malik_talent_hit"
tt.hero.skills.talent_1.xp_level_steps = {
	[1] = 1
}
tt.hero.skills.talent_2 = CC("hero_skill")
tt.hero.skills.talent_2.aura = "aura_malik_talent_2_buff"
tt.hero.skills.talent_2.dmg_factor = 1.25
tt.hero.skills.talent_2.detection_radius = 150
tt.hero.skills.talent_2.xp_level_steps = {
	[1] = 1
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, 53)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_malik_level_up
tt.hero.respawn_animation = "lvlup"
tt.hero.tombstone_show_time = fts(67)
tt.hero.tombstone_decal = "decal_malik_tombstone"
tt.hero.tombstone_concurrent_with_death = true
tt.info.hero_portrait = "kr6_hero_portraits_0006"
tt.info.portrait = "kr6_info_portraits_heroes_0005"
tt.main_script.insert = hero_malik_insert
tt.main_script.update = hero_malik_update
tt.motion.max_speed = 60
tt.regen.cooldown = 1
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].prefix = "malikDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].draw_order = DO_HEROES
tt.render.sprites[1].scale = vec_2(1, 1)
tt.sound_events.change_rally_point = "HeroMalikTaunt"
tt.sound_events.death = "HeroMalikDeath"
tt.sound_events.respawn = "HeroMalikTauntIntro"
tt.sound_events.hero_room_select = "HeroMalikTauntSelect"
tt.sound_events.level_up = "HeroMalikTauntLevelUp"
tt.soldier.melee_slot_offset = vec_2(12, 0)
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 12)
tt.unit.marker_offset = vec_2(0, -1)
tt.unit.mod_offset = vec_2(0, 19.9)
tt.unit.pop_offset = vec_2(0, 15)
tt.melee.cooldown = 1.5
tt.melee.range = 78
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].cooldown = 1.5
tt.melee.attacks[1].damage_flags = 0
tt.melee.attacks[1].damage_radius = 70
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_fx = "fx_malik_hit"
tt.melee.attacks[1].hit_offset = vec_2(45, 0)
tt.melee.attacks[1].hit_time = fts(14)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].sound = "HeroMalikBasicAttackCast"
tt.melee.attacks[1].sound_args = {
	delay = fts(13)
}
tt.melee.attacks[1].vis_bans = bor(F_CLIFF)
tt.melee.attacks[1].xp_gain_factor = 1.8
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].animation = "buff"
tt.timed_attacks.list[1].cast_time = fts(9)
tt.timed_attacks.list[1].cooldown = 18
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].duration = 6
tt.timed_attacks.list[1].hp_increase_ptg = 0.3
tt.timed_attacks.list[1].mod = "mod_malik_skill_a"
tt.timed_attacks.list[1].shield_base = 50
tt.timed_attacks.list[1].sound = "HeroMalikUnbreakableCast"
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].animation = "stun"
tt.timed_attacks.list[2].cast_time = fts(30)
tt.timed_attacks.list[2].cooldown = 20
tt.timed_attacks.list[2].damage_max = 72
tt.timed_attacks.list[2].damage_min = 48
tt.timed_attacks.list[2].damage_radius = 50
tt.timed_attacks.list[2].damage_type = DAMAGE_PHYSICAL
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].hit_decal = "decal_malik_skill_b"
tt.timed_attacks.list[2].hit_offset = vec_2(45, 0)
tt.timed_attacks.list[2].min_targets = 1
tt.timed_attacks.list[2].mod_stun = "mod_malik_skill_b_stun"
tt.timed_attacks.list[2].sound = "HeroMalikEarthquakeCast"
tt.timed_attacks.list[2].stun_duration = 2
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[2].vis_flags = bor(F_AREA)
tt.timed_attacks.list[3] = CC("custom_attack")
tt.timed_attacks.list[3].animation = "instakill"
tt.timed_attacks.list[3].cast_time = fts(35)
tt.timed_attacks.list[3].cooldown = 40
tt.timed_attacks.list[3].current_hp_threshold = 80
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].enemy_move_offset = vec_2(10, 40)
tt.timed_attacks.list[3].hp_threshold = 1500
tt.timed_attacks.list[3].mod = "mod_malik_skill_c_instakill"
tt.timed_attacks.list[3].sound = "HeroMalikObliterateCast"
tt.timed_attacks.list[3].vis_bans = bor(F_FLYING, F_BOSS, F_MINIBOSS)
tt.timed_attacks.list[4] = CC("custom_attack")
tt.timed_attacks.list[4].animation_end = "tornadostop"
tt.timed_attacks.list[4].animation_loop = "tornadoloop"
tt.timed_attacks.list[4].animation_start = "tornadostart"
tt.timed_attacks.list[4].aura_t = "aura_malik_ultimate"
tt.timed_attacks.list[4].cast_time = fts(25)
tt.timed_attacks.list[4].cooldown = 28
tt.timed_attacks.list[4].damage_radius = 80
tt.timed_attacks.list[4].disabled = true
tt.timed_attacks.list[4].duration = 5
tt.timed_attacks.list[4].hit_offset = vec_2(20, 5)
tt.timed_attacks.list[4].min_targets = 3
tt.timed_attacks.list[4].ps_t = "ps_malik_ultimate"
tt.timed_attacks.list[4].sound_cast = "HeroMalikHammernadoCastLoopStart"
tt.timed_attacks.list[4].sound_end = "HeroMalikHammernadoCastLoopEnd"
tt.timed_attacks.list[4].sound_loop = "HeroMalikHammernadoCastLoop"
tt.timed_attacks.list[4].sound_taunt = "HeroMalikTauntUltimate"
tt.timed_attacks.list[4].speed_mod = "mod_malik_ultimate_self_speed"
tt.timed_attacks.list[4].vis_bans = bor(F_FLYING)
tt.ui.click_rect = r(-22, -5, 44, 43)

tt = RT("mod_malik_skill_a", "modifier")
AC(tt, "render", "health_bar", "health", "tween")
tt.animation_loop = "loop"
tt.animation_start = "start"
tt.damage_taken = 0
tt.health_bar.colors = {}
tt.health_bar.colors.bg = {0, 0, 0, 255}
tt.health_bar.colors.fg = {255, 255, 0, 255}
tt.health_bar.disable_fade = true
tt.health_bar.offset = vec_2(0, 53)
tt.health_bar.sort_y_offset = 0
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.main_script.insert = mod_malik_skill_a_insert
tt.main_script.remove = mod_malik_skill_a_remove
tt.main_script.update = mod_malik_skill_a_update
tt.modifier.use_mod_offset = false
tt.modifier.vis_bans = 0
tt.modifier.vis_flags = bor(F_MOD)
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].name = "start"
tt.render.sprites[1].prefix = "malik_shieldDef"
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {1, 0}}
tt.tween.props[1].name = "alpha"
tt.tween.run_once = true

tt = RT("mod_malik_skill_b_stun", "mod_stun")
tt.modifier.duration = 2
tt.modifier.vis_bans = bor(F_BOSS)
tt.modifier.vis_flags = bor(F_MOD, F_STUN)

tt = RT("mod_malik_skill_c_instakill", "mod_stun")
tt.clone_decal = "decal_malik_skill_c_clone"
tt.fly_speed = vec_2(7, 8)
tt.main_script.insert = mod_malik_skill_c_insert
tt.main_script.remove = mod_malik_skill_c_remove
tt.main_script.update = mod_malik_skill_c_update
tt.modifier.duration = fts(10)
tt.modifier.vis_flags = bor(F_MOD, F_INSTAKILL)
tt.render = nil
tt.rotation_speed = 0.17

tt = RT("mod_malik_ultimate_slow", "mod_slow")
tt.modifier.duration = 0.5
tt.modifier.vis_flags = bor(F_MOD)
tt.slow.factor = 0.6

tt = RT("mod_malik_ultimate_self_speed", "mod_slow")
tt.modifier.duration = 1e+99
tt.modifier.vis_flags = bor(F_MOD)
tt.slow.factor = 1.17

tt = RT("aura_malik_talent_2_buff", "aura")
tt.aura.radius = 150
tt.aura.vis_bans = bor(F_ENEMY)
tt.aura.vis_flags = bor(F_FRIEND)
tt.dmg_factor = 1.25
tt.main_script.update = aura_malik_talent_2_buff_update

tt = RT("aura_malik_ultimate", "aura")
tt.aura.cycle_time = 0.5
tt.aura.damage_max = 24
tt.aura.damage_min = 16
tt.aura.damage_type = DAMAGE_PHYSICAL
tt.aura.duration = 5
tt.aura.hit_fx = "fx_malik_hit"
tt.aura.mod = "mod_malik_ultimate_slow"
tt.aura.radius = 80
tt.aura.track_source = true
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.aura.vis_flags = bor(F_AREA)
tt.main_script.update = aura_malik_ultimate_update

tt = RT("fx_malik_hit", "fx")
tt.render.sprites[1].exo = true
tt.render.sprites[1].name = "run"
tt.render.sprites[1].prefix = "malik_hitfxDef"
tt.render.sprites[1].sort_y_offset = -1
tt.render.sprites[1].z = Z_OBJECTS

tt = RT("decal_malik_skill_b", "decal_tween")
AC(tt, "main_script")
tt.main_script.remove = scripts.tween_utils.reverse_remove
tt.main_script.update = scripts.tween_utils.wait_update
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "run"
tt.render.sprites[1].prefix = "malik_stundecalDef"
tt.render.sprites[1].z = Z_DECALS
tt.tween.disabled = false
tt.tween.props[1].keys = {{0, 0}, {1, 255}}
tt.tween.remove = false
tt.tween.run_once = true
tt.wait_time = 1

tt = RT("decal_malik_talent_hit", "decal_tween")
AC(tt, "main_script")
tt.main_script.remove = scripts.tween_utils.reverse_remove
tt.main_script.update = scripts.tween_utils.wait_update
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "Idle"
tt.render.sprites[1].prefix = "malik_areadecalDef"
tt.render.sprites[1].z = Z_DECALS
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 0}, {1, 255}}
tt.tween.remove = false
tt.tween.run_once = true
tt.wait_time = 1

tt = RT("decal_malik_tombstone", "decal_tween")
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].name = "death_idle"
tt.render.sprites[1].prefix = "malikDef"
tt.render.sprites[1].scale = vec_2(1, 1)
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 0}, {fts(1), 0}}

tt = RT("decal_malik_skill_c_clone", "decal")
AC(tt, "tween")
tt.tween.props[1].keys = {{0, 255}, {0, 255}, {0, 0}}
tt.tween.props[1].name = "alpha"
tt.tween.props[1].sprite_id = 1
tt.tween.remove = true

tt = RT("ps_malik_ultimate", "particle_system")
tt.particle_system.alphas = {255, 0}
tt.particle_system.animated = false
tt.particle_system.cycle_names = true
tt.particle_system.emit_area_spread = vec_2(3, 3)
tt.particle_system.emit_rotation_spread = math.pi / 2
tt.particle_system.emission_rate = 15
tt.particle_system.loop = false
tt.particle_system.name = "Malik_Layers_malik_tornadotrail_0001"
tt.particle_system.names = {"Malik_Layers_malik_tornadotrail_0001", "Malik_Layers_malik_tornadotrail_0005", "Malik_Layers_malik_tornadotrail_0009", "Malik_Layers_malik_tornadotrail_0013", "Malik_Layers_malik_tornadotrail_0018", "Malik_Layers_malik_tornadotrail_0024", "Malik_Layers_malik_tornadotrail_0030", "Malik_Layers_malik_tornadotrail_0036"}
tt.particle_system.particle_lifetime = {fts(38), fts(38)}
tt.particle_system.z = Z_DECALS
