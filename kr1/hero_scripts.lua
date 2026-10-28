require("lib.klua.table")
require("i18n")

local scripts = require("scripts")
local log = require("lib.klua.log"):new("hero_scripts")
local A = require("animation_db")
local km = require("lib.klua.macros")
local signal = require("lib.hump.signal")
local E = require("entity_db")
local GR = require("grid_db")
local GS = require("kr1.game_settings")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local LU = require("level_utils")
local UP = require("kr1.upgrades")
local SH = require("klove.shader_db")
local V = require("lib.klua.vector")
local W = require("wave_db")
local bit = require("bit")
require("table.clear")
local band = bit.band
local bor = bit.bor

local fts = U.fts
local queue_damage = U.queue_damage
local HU = require("hero_utils")
local update_hp = HU.update_hp

-- 兽王-恢复
scripts.aura_beastmaster_regeneration = {
	update = function(this, store)
		local hps = this.hps
		local hero = store.entities[this.aura.source_id]

		if not hero then
			return
		end

		while true do
			if not hero.health.dead and store.tick_ts - hps.ts >= hps.heal_every then
				hps.ts = store.tick_ts
				U.heal(hero, hps.heal_max)
			end

			coroutine.yield()
		end
	end
}
-- 但丁-光明信标
scripts.mod_van_helsing_beacon = {
	insert = function(this, store)
		local m = this.modifier
		local target = store.entities[m.target_id]

		if not target or not target.health or target.health.dead then
			return false
		end

		SU.insert_unit_damage_factor_by_factor(target, this.inflicted_damage_factor)

		return true
	end,
	remove = function(this, store)
		local m = this.modifier
		local target = store.entities[m.target_id]

		if target then
			SU.remove_unit_damage_factor_by_factor(target, this.inflicted_damage_factor)
		end

		return true
	end
}
-- 德得尔-塔buff
scripts.mod_priest_consecrate = {
	update = function(this, store)
		local m = this.modifier
		local target = store.entities[m.target_id]

		if not target then
			simulation:queue_remove_entity(this)

			return
		end

		this.pos = V.vclone(target.pos)
		m.ts = store.tick_ts
		this.tween.disabled = false
		this.tween.ts = store.tick_ts

		SU.insert_tower_damage_factor_buff(target, this.extra_damage)

		while store.tick_ts - m.ts < m.duration do
			coroutine.yield()

			target = store.entities[m.target_id]

			if not target then
				goto label_374_0
			end
		end

		SU.remove_tower_damage_factor_buff(target, this.extra_damage)

		::label_374_0::

		this.tween.reverse = true
		this.tween.ts = store.tick_ts
		this.tween.remove = true

		simulation:queue_remove_entity(this)
	end
}
scripts.aura_fiery_mist_ashbite = {}

function scripts.aura_fiery_mist_ashbite.update(this, store)
	local a = this.aura

	a.ts = store.tick_ts

	local last_cycle_ts = store.tick_ts - a.cycle_time

	while true do
		if store.tick_ts - a.ts > a.duration then
			break
		end

		if store.tick_ts - last_cycle_ts > a.cycle_time then
			last_cycle_ts = store.tick_ts

			local targets = U.find_enemies_in_range_filter_off(this.pos, a.radius, a.vis_flags, a.vis_bans)

			if targets then
				for _, target in ipairs(targets) do
					local m = E:create_entity(a.mod)

					m.modifier.target_id = target.id
					m.modifier.source_id = this.id
					m.modifier.level = a.level

					simulation:queue_insert_entity(m)

					local d = E.assign_damage(a.damage_type, math.random(a.damage_min, a.damage_max), this.id, target.id)

					queue_damage(store, d)
				end
			end
		end

		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

-- 艾利丹 - 大招箭矢
scripts.arrow_hero_elves_archer_ultimate = {
	update = function(this, store)
		local b = this.bullet
		local speed = b.max_speed

		while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) >= 2 * (speed * store.tick_length) do
			b.speed.x, b.speed.y = V.mul(speed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
			this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
			this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

			coroutine.yield()
		end

		local targets

		if band(b.damage_bans, F_FRIEND) ~= 0 then
			targets = U.find_enemies_in_range_filter_off(b.to, b.damage_radius, b.damage_flags, b.damage_bans)
		else
			targets = U.find_soldiers_in_range(store.soldiers, b.to, 0, b.damage_radius, b.damage_flags, b.damage_bans)
		end

		if targets then
			for _, target in ipairs(targets) do
				local d = E.assign_damage(b.damage_type, b.damage_max * b.damage_factor, this.id, target.id)

				queue_damage(store, d)

				if b.mod then
					local mod = E:create_entity(b.mod)

					mod.modifier.target_id = target.id

					simulation:queue_insert_entity(mod)
				end
			end
		end

		if b.hit_fx then
			SU.insert_sprite(store, b.hit_fx, this.pos)
		end

		if b.arrive_decal then
			local decal = E:create_entity(b.arrive_decal)

			decal.pos:copy(b.to)
			decal.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(decal)
		end

		simulation:queue_remove_entity(this)
	end
}
-- 艾利丹 - 大招箭矢 - 特效
scripts.decal_hero_elves_archer_ultimate = {
	insert = function(this, store)
		this.render.sprites[1].ts = store.tick_ts
		this.render.sprites[1].r = U.frandom(-10, 5) * math.pi / 180
		this.render.sprites[2].ts = store.tick_ts

		return true
	end
}

scripts.mod_lynn_ultimate = {}

function scripts.mod_lynn_ultimate.insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead then
		return false
	end

	if not U.flags_pass(target.vis, this.modifier) then
		return false
	end

	this.dps.ts = store.tick_ts - this.dps.damage_every
	this.modifier.ts = store.tick_ts
	this.tween.ts = store.tick_ts
	this.pos = target.pos

	signal.emit("mod-applied", this, target)

	return true
end

function scripts.mod_lynn_ultimate.update(this, store)
	local target
	local m = this.modifier
	local dps = this.dps
	local s_top, s_over = this.render.sprites[1], this.render.sprites[3]

	while store.tick_ts - m.ts < m.duration do
		target = store.entities[m.target_id]

		if not target then
			break
		end

		if target.health.dead then
			local p

			if U.flag_has(target.vis.flags, F_FLYING) then
				p = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
			else
				p = V.v(target.pos.x, target.pos.y)
			end

			SU.insert_sprite(store, this.explode_fx, p)

			local targets = U.find_enemies_in_range_filter_off(target.pos, this.explode_range, this.explode_vis_flags, this.explode_vis_bans)

			if targets then
				for _, t in ipairs(targets) do
					local new_mod = E:create_entity("mod_lynn_ultimate")

					new_mod.modifier.source_id = this.id
					new_mod.modifier.target_id = t.id
					new_mod.modifier.damage_factor = this.modifier.damage_factor * 0.6

					simulation:queue_insert_entity(new_mod)

					local d = E.assign_damage(this.explode_damage_type, this.explode_damage * this.modifier.damage_factor, this.id, t.id)

					queue_damage(store, d)
				end
			end

			break
		end

		s_top.offset.x = target.health_bar.offset.x + m.health_bar_offset.x
		s_top.offset.y = target.health_bar.offset.y + m.health_bar_offset.y
		s_over.offset.x = target.unit.mod_offset.x
		s_over.offset.y = target.unit.mod_offset.y

		if dps.damage_every and store.tick_ts - dps.ts >= dps.damage_every then
			dps.ts = dps.ts + dps.damage_every

			local d = E.assign_damage(dps.damage_type, dps.damage_max * this.modifier.damage_factor, this.id, target.id)

			queue_damage(store, d)
		end

		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

scripts.rabbit_kamihare = {}

function scripts.rabbit_kamihare.update(this, store)
	local start_ts = store.tick_ts
	local a = this.custom_attack
	local s = this.render.sprites[1]

	s.ts = store.tick_ts + (s.random_ts and U.frandom(-s.random_ts, 0) or 0)

	while true do
		local targets = U.find_enemies_in_range_filter_off(this.pos, a.max_range, a.vis_flags, a.vis_bans)

		if targets or store.tick_ts - start_ts > this.duration or not P:is_node_valid(this.nav_path.pi, this.nav_path.ni) or not SU.y_enemy_walk_step_default(store, this) then
			break
		end
	end

	local aura = E:create_entity(a.aura)

	aura.pos:copy(this.pos)
	aura.aura.damage_factor = this.damage_factor or 1

	simulation:queue_insert_entity(aura)

	if a.hit_fx then
		local fx = E:create_entity(a.hit_fx)

		fx.pos:copy(this.pos)
		fx.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(fx)
	end

	if A:has_animation(s.prefix .. "_" .. "death") then
		U.y_animation_play(this, "death", nil, store.tick_ts)
	end

	simulation:queue_remove_entity(this)
end

scripts.soldier_hero_space_elf_astral_reflection = {}

function scripts.soldier_hero_space_elf_astral_reflection.update(this, store)
	local brk, stam, star

	this.reinforcement.ts = store.tick_ts
	this.render.sprites[1].ts = store.tick_ts

	if this.reinforcement.fade or this.reinforcement.fade_in then
		SU.y_reinforcement_fade_in(store, this)
	elseif this.render.sprites[1].name == "in" then
		if this.sound_events and this.sound_events.raise then
			S:queue(this.sound_events.raise)
		end

		this.health_bar.hidden = true
		U.y_animation_play(this, "in", nil, store.tick_ts, 1)

		if not this.health.dead then
			this.health_bar.hidden = nil
		end
	end

	this.render.sprites[1].hidden = true

	local spawn_fx = E:create_entity(this.spawn_fx)

	spawn_fx.pos:copy(this.pos)
	spawn_fx.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(spawn_fx)
	U.y_wait_unconditional(store, fts(23))

	this.render.sprites[1].hidden = false

	while true do
		if this.health.dead or this.reinforcement.duration and store.tick_ts - this.reinforcement.ts > this.reinforcement.duration then
			if this.health.hp > 0 then
				this.reinforcement.hp_before_timeout = this.health.hp
			end

			this.health.hp = 0

			SU.y_soldier_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			if this.melee then
				brk, stam = SU.y_soldier_melee_block_and_attacks(store, this)

				if brk or stam == A_DONE or stam == A_IN_COOLDOWN and not this.melee.continue_in_cooldown then
					goto label_249_1
				end
			end

			if this.ranged then
				brk, star = SU.y_soldier_ranged_attacks(store, this)

				if brk or star == A_DONE then
					goto label_249_1
				elseif star == A_IN_COOLDOWN then
					goto label_249_0
				end
			end

			if this.melee.continue_in_cooldown and stam == A_IN_COOLDOWN then
				goto label_249_1
			end

			if SU.soldier_go_back_step(store, this) then
				goto label_249_1
			end

			::label_249_0::

			SU.soldier_idle(store, this)
			SU.soldier_regen(store, this)
		end

		::label_249_1::

		coroutine.yield()
	end
end

scripts.hero_raelyn_command_orders_dark_knight = {}

function scripts.hero_raelyn_command_orders_dark_knight.update(this, store)
	local brk, stam, star

	this.reinforcement.ts = store.tick_ts
	this.render.sprites[1].ts = store.tick_ts

	if this.reinforcement.fade or this.reinforcement.fade_in then
		SU.y_reinforcement_fade_in(store, this)
	elseif this.render.sprites[1].name == "raise" then
		if this.sound_events and this.sound_events.raise then
			S:queue(this.sound_events.raise)
		end

		this.health_bar.hidden = true
		U.y_animation_play(this, "raise", nil, store.tick_ts, 1)

		if not this.health.dead then
			this.health_bar.hidden = nil
		end
	end

	while true do
		if this.health.dead or this.reinforcement.duration and store.tick_ts - this.reinforcement.ts > this.reinforcement.duration then
			if this.health.hp > 0 then
				this.reinforcement.hp_before_timeout = this.health.hp
			end

			if this.health.dead then
				this.reinforcement.fade = nil
			-- this.tween = nil
			else
				this.reinforcement.fade = true
			end

			this.health.hp = 0

			SU.remove_modifiers(store, this)

			this.ui.can_click = false

			SU.y_soldier_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_229_1
				end
			end

			if this.melee then
				brk, stam = SU.y_soldier_melee_block_and_attacks(store, this)

				if brk or stam == A_DONE or stam == A_IN_COOLDOWN and not this.melee.continue_in_cooldown then
					goto label_229_1
				end
			end

			if this.ranged then
				brk, star = SU.y_soldier_ranged_attacks(store, this)

				if brk or star == A_DONE then
					goto label_229_1
				elseif star == A_IN_COOLDOWN then
					goto label_229_0
				end
			end

			if this.melee.continue_in_cooldown and stam == A_IN_COOLDOWN then
				goto label_229_1
			end

			if SU.soldier_go_back_step(store, this) then
				goto label_229_1
			end

			::label_229_0::

			SU.soldier_idle(store, this)
			SU.soldier_regen(store, this)
		end

		::label_229_1::

		coroutine.yield()
	end
end

scripts.bolt_lumenir = {}

function scripts.bolt_lumenir.update(this, store)
	local b = this.bullet
	local fm = this.force_motion
	local target = store.entities[b.target_id]
	local ps

	local function move_step(dest)
		local dx, dy = V.sub(dest.x, dest.y, this.pos.x, this.pos.y)
		local dist = V.len(dx, dy)
		local nx, ny = V.mul(fm.max_v, V.normalize(dx, dy))
		local stx, sty = V.sub(nx, ny, fm.v.x, fm.v.y)

		if dist <= 4 * fm.max_v * store.tick_length then
			stx, sty = V.mul(fm.max_a, V.normalize(stx, sty))
		end

		fm.a.x, fm.a.y = V.add(fm.a.x, fm.a.y, V.trim(fm.max_a, V.mul(fm.a_step, stx, sty)))
		fm.v.x, fm.v.y = V.trim(fm.max_v, V.add(fm.v.x, fm.v.y, V.mul(store.tick_length, fm.a.x, fm.a.y)))
		this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, V.mul(store.tick_length, fm.v.x, fm.v.y))
		fm.a.x, fm.a.y = 0, 0

		return dist <= fm.max_v * store.tick_length
	end

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.emit = true
		ps.particle_system.track_id = this.id

		simulation:queue_insert_entity(ps)
	end

	local pred_pos

	if target then
		pred_pos = P:predict_enemy_pos(target, fts(5))
	else
		pred_pos = b.to
	end

	local iix, iiy = V.normalize(pred_pos.x - this.pos.x, pred_pos.y - this.pos.y)
	local last_pos = V.vclone(this.pos)

	b.ts = store.tick_ts

	while true do
		target = store.entities[b.target_id]

		if target and target.health and not target.health.dead and band(target.vis.bans, F_RANGED) == 0 then
			local d = math.max(math.abs(target.pos.x + target.unit.hit_offset.x - b.to.x), math.abs(target.pos.y + target.unit.hit_offset.y - b.to.y))

			if d > b.max_track_distance then
				log.debug("BOLT MAX DISTANCE FAIL. (%s) %s / dist:%s target.pos:%s,%s b.to:%s,%s", this.id, this.template_name, d, target.pos.x, target.pos.y, b.to.x, b.to.y)

				target = nil
				b.target_id = nil
			else
				b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
			end
		end

		if this.initial_impulse and store.tick_ts - b.ts < this.initial_impulse_duration then
			local t = store.tick_ts - b.ts

			if this.initial_impulse_angle_abs then
				fm.a.x, fm.a.y = V.mul((1 - t) * this.initial_impulse, V.rotate(this.initial_impulse_angle_abs, 1, 0))
			else
				fm.a.x, fm.a.y = V.mul((1 - t) * this.initial_impulse, V.rotate(this.initial_impulse_angle * (b.shot_index % 2 == 0 and 1 or -1), iix, iiy))
			end
		end

		last_pos.x, last_pos.y = this.pos.x, this.pos.y

		if move_step(b.to) then
			break
		end

		if b.align_with_trajectory then
			this.render.sprites[1].r = V.angleTo(this.pos.x - last_pos.x, this.pos.y - last_pos.y)
		end

		coroutine.yield()
	end

	if target and not target.health.dead then
		local d = SU.create_bullet_damage(b, target.id, this.id)

		queue_damage(store, d)

		if b.mod or b.mods then
			local mods = b.mods or {b.mod}

			for _, mod_name in ipairs(mods) do
				local m = E:create_entity(mod_name)

				m.modifier.target_id = b.target_id
				m.modifier.level = b.level

				simulation:queue_insert_entity(m)
			end
		end
	end

	this.render.sprites[1].hidden = true

	if b.hif_fx_air and target and band(target.vis.flags, F_FLYING) ~= 0 then
		local fx = E:create_entity(b.hif_fx_air)
		fx.pos:copy(b.to)
		fx.render.sprites[1].ts = store.tick_ts
		simulation:queue_insert_entity(fx)
	elseif b.hit_fx then
		local fx = E:create_entity(b.hit_fx)

		fx.pos.x, fx.pos.y = b.to.x, b.to.y
		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].runs = 0

		simulation:queue_insert_entity(fx)
	end

	if b.hit_decal then
		local decal = E:create_entity(b.hit_decal)

		decal.pos:copy(b.to)
		decal.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(decal)
	end

	if ps and ps.particle_system.emit then
		ps.particle_system.emit = false

		U.y_wait_unconditional(store, ps.particle_system.particle_lifetime[2])
	end

	simulation:queue_remove_entity(this)
end

scripts.soldier_hero_wukong_zhu_apprentice = {}

function scripts.soldier_hero_wukong_zhu_apprentice.insert(this, store)
	this.melee.order = U.attack_order(this.melee.attacks)

	if this.ranged then
		this.ranged.order = U.attack_order(this.ranged.attacks)
	end
	return true
end

function scripts.soldier_hero_wukong_zhu_apprentice.update(this, store)
	local brk, stam, star

	this.render.sprites[1].ts = store.tick_ts

	if this.respawn_fx then
		local respawn_fx = E:create_entity(this.respawn_fx)

		respawn_fx.pos:copy(this.pos)
		respawn_fx.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(respawn_fx)
		U.y_wait_unconditional(store, this.respawn_fx_timing)
	else
		U.y_animation_play_default(this, "spawn", nil, store.tick_ts, 1)
	end

	local function y_zhu_apprentice_death_and_respawn(store, this)
		local h = this.health

		this.ui.can_click = false

		local death_ts = store.tick_ts
		local dead_lifetime = h.dead_lifetime

		U.unblock_target(store, this)

		if band(h.last_damage_types, bor(DAMAGE_DISINTEGRATE_BOSS)) ~= 0 then
			this.unit.hide_after_death = true

			local fx = E:create_entity("fx_soldier_desintegrate")

			fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
			fx.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(fx)
		elseif band(h.last_damage_types, bor(DAMAGE_EAT)) ~= 0 then
			this.unit.hide_after_death = true
		elseif band(h.last_damage_types, bor(DAMAGE_HOST)) ~= 0 then
			this.unit.hide_after_death = true

			S:queue("DeathEplosion")

			local fx = E:create_entity("fx_unit_explode")

			fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].name = fx.render.sprites[1].size_names[this.unit.size]

			simulation:queue_insert_entity(fx)

			if this.unit.show_blood_pool and this.unit.blood_color ~= BLOOD_NONE then
				local decal = E:create_entity("decal_blood_pool")

				decal.pos:copy(this.pos)
				decal.render.sprites[1].ts = store.tick_ts
				decal.render.sprites[1].name = this.unit.blood_color

				simulation:queue_insert_entity(decal)
			end
		else
			S:queue(this.sound_events.death, this.sound_events.death_args)

			if this.unit.death_animation then
				U.animation_start_default(this, this.unit.death_animation, nil, store.tick_ts, false)
			else
				U.animation_start_default(this, "death", nil, store.tick_ts, false)
			end
		end

		if this.unit.hide_after_death then
			for _, s in ipairs(this.render.sprites) do
				s.hidden = true
			end
		end

		while dead_lifetime > store.tick_ts - death_ts do
			if this.force_respawn then
				this.force_respawn = nil

				break
			end

			coroutine.yield()
		end

		this.pos:copy(this.nav_rally.pos)

		this.health.death_finished_ts = nil

		for _, s in ipairs(this.render.sprites) do
			if this.use_hidden_count_on_respawn and s.hidden_count then
				s.hidden = s.hidden_count > 0
			else
				s.hidden = false
			end
		end

		h.ignore_damage = true

		S:queue(this.sound_events.respawn)

		if this.respawn_fx then
			local respawn_fx = E:create_entity(this.respawn_fx)

			respawn_fx.pos:copy(this.pos)
			respawn_fx.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(respawn_fx)
			U.y_wait_unconditional(store, this.respawn_fx_timing)
		else
			U.y_animation_play_default(this, "spawn", nil, store.tick_ts, 1)
		end

		this.health_bar.hidden = false
		this.ui.can_click = true
		h.dead = false
		this.force_respawn = nil
		h.hp = h.hp_max
		h.ignore_damage = false
	end

	while true do
		if this.health.dead then
			y_zhu_apprentice_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_895_0
				end
			end

			if this.dodge and this.dodge.active then
				this.dodge.active = false

				if this.dodge.animation then
					U.animation_start_default(this, this.dodge.animation, nil, store.tick_ts, false)

					while not U.animation_finished_default(this) do
						coroutine.yield()
					end
				end

				signal.emit("soldier-dodge", this)
			end

			if this.melee then
				brk, stam = SU.y_soldier_melee_block_and_attacks(store, this)

				if brk or stam == A_DONE or stam == A_IN_COOLDOWN and not this.melee.continue_in_cooldown then
					goto label_895_0
				end
			end

			if this.ranged then
				brk, star = SU.y_soldier_ranged_attacks(store, this)

				if brk or star == A_DONE then
					goto label_895_0
				elseif star == A_IN_COOLDOWN then
					goto label_895_1
				end
			end

			if this.melee.continue_in_cooldown and stam == A_IN_COOLDOWN then
				goto label_895_0
			end
			if SU.soldier_go_back_step(store, this) then
				goto label_895_0
			end

			::label_895_1::

			SU.soldier_idle(store, this)
			SU.soldier_regen(store, this)
		end

		::label_895_0::

		coroutine.yield()
	end
end

-- 悟空_END

scripts.hero_muyrn_ranged_attack_bullet = {}

function scripts.hero_muyrn_ranged_attack_bullet.update(this, store)
	local b = this.bullet
	local fm = this.force_motion
	local target = store.entities[b.target_id]
	local ps

	local function move_step(dest)
		local dx, dy = V.sub(dest.x, dest.y, this.pos.x, this.pos.y)
		local dist = V.len(dx, dy)
		local nx, ny = V.mul(fm.max_v, V.normalize(dx, dy))
		local stx, sty = V.sub(nx, ny, fm.v.x, fm.v.y)

		if dist <= 4 * fm.max_v * store.tick_length then
			stx, sty = V.mul(fm.max_a, V.normalize(stx, sty))
		end

		fm.a.x, fm.a.y = V.add(fm.a.x, fm.a.y, V.trim(fm.max_a, V.mul(fm.a_step, stx, sty)))
		fm.v.x, fm.v.y = V.trim(fm.max_v, V.add(fm.v.x, fm.v.y, V.mul(store.tick_length, fm.a.x, fm.a.y)))
		this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, V.mul(store.tick_length, fm.v.x, fm.v.y))
		fm.a.x, fm.a.y = 0, 0

		return dist <= fm.max_v * store.tick_length
	end

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.emit = true
		ps.particle_system.track_id = this.id

		simulation:queue_insert_entity(ps)
	end

	local pred_pos

	if target then
		pred_pos = P:predict_enemy_pos(target, fts(5))
	else
		pred_pos = b.to
	end

	local iix, iiy = V.normalize(pred_pos.x - this.pos.x, pred_pos.y - this.pos.y)
	local last_pos = V.vclone(this.pos)

	b.ts = store.tick_ts

	while true do
		target = store.entities[b.target_id]

		if target and target.health and not target.health.dead and band(target.vis.bans, F_RANGED) == 0 then
			local hit_offset = V.v(0, 0)

			if not b.ignore_hit_offset then
				hit_offset.x = target.unit.hit_offset.x
				hit_offset.y = target.unit.hit_offset.y
			end

			local d = math.max(math.abs(target.pos.x + hit_offset.x - b.to.x), math.abs(target.pos.y + hit_offset.y - b.to.y))

			if d > b.max_track_distance then
				log.debug("BOLT MAX DISTANCE FAIL. (%s) %s / dist:%s target.pos:%s,%s b.to:%s,%s", this.id, this.template_name, d, target.pos.x, target.pos.y, b.to.x, b.to.y)

				target = nil
				b.target_id = nil
			else
				b.to.x, b.to.y = target.pos.x + hit_offset.x, target.pos.y + hit_offset.y
			end
		end

		if this.initial_impulse and store.tick_ts - b.ts < this.initial_impulse_duration then
			local t = store.tick_ts - b.ts

			if this.initial_impulse_angle_abs then
				fm.a.x, fm.a.y = V.mul((1 - t) * this.initial_impulse, V.rotate(this.initial_impulse_angle_abs, 1, 0))
			else
				local angle = this.initial_impulse_angle

				if iix < 0 then
					angle = angle * -1
				end

				fm.a.x, fm.a.y = V.mul((1 - t) * this.initial_impulse, V.rotate(angle, iix, iiy))
			end
		end

		last_pos.x, last_pos.y = this.pos.x, this.pos.y

		if move_step(b.to) then
			break
		end

		if b.align_with_trajectory then
			this.render.sprites[1].r = V.angleTo(this.pos.x - last_pos.x, this.pos.y - last_pos.y)
		end

		coroutine.yield()
	end

	if target and not target.health.dead then
		local d = SU.create_bullet_damage(b, target.id, this.id)

		queue_damage(store, d)
	elseif b.damage_radius and b.damage_radius > 0 then
		local targets = U.find_enemies_in_range_filter_off(this.pos, b.damage_radius, b.vis_flags, b.vis_bans)

		if targets then
			for _, target in ipairs(targets) do
				local d = SU.create_bullet_damage(b, target.id, this.id)

				queue_damage(store, d)
			end
		end
	end

	this.render.sprites[1].hidden = true

	if b.hit_fx then
		local fx = E:create_entity(b.hit_fx)

		fx.pos.x, fx.pos.y = b.to.x, b.to.y
		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].runs = 0

		simulation:queue_insert_entity(fx)
	end

	if b.hit_decal then
		local decal = E:create_entity(b.hit_decal)

		decal.pos:copy(b.to)
		decal.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(decal)
	end

	if ps and ps.particle_system.emit then
		ps.particle_system.emit = false

		U.y_wait_unconditional(store, ps.particle_system.particle_lifetime[2])
	end

	simulation:queue_remove_entity(this)
end

scripts.hero_muyrn_root_defender_root_decal = {}

function scripts.hero_muyrn_root_defender_root_decal.update(this, store)
	if this.delay then
		U.y_wait_unconditional(store, this.delay)
	end

	local start_ts = store.tick_ts

	this.render.sprites[1].hidden = nil

	U.y_animation_play(this, "start", nil, store.tick_ts)

	while store.tick_ts - start_ts < this.duration do
		if U.find_first_target(store.entities, this.pos, 0, 25, this.vis_flags, this.vis_bans) then
			U.y_animation_play(this, "loop", nil, store.tick_ts, 1)
		end

		coroutine.yield()
	end

	U.y_animation_play(this, "end", nil, store.tick_ts)
	simulation:queue_remove_entity(this)
end

scripts.decal_hero_dragon_arb_passive_plant = {}

function scripts.decal_hero_dragon_arb_passive_plant.update(this, store)
	if this.delay then
		U.y_wait_unconditional(store, this.delay)
	end

	this.render.sprites[1].hidden = nil

	U.y_animation_play(this, "start", nil, store.tick_ts)

	while not this.destroy_plant do
		if U.find_first_target(store.entities, this.pos, 0, 25, this.vis_flags, this.vis_bans) then
			U.y_animation_play(this, "loop", nil, store.tick_ts, 1)
		end

		coroutine.yield()
	end

	U.y_wait_unconditional(store, this.destroy_plant)
	U.y_animation_play(this, "end", nil, store.tick_ts)
	simulation:queue_remove_entity(this)
end

scripts.mod_soldier_hero_spider_ultimate_stun = {}

function scripts.mod_soldier_hero_spider_ultimate_stun.insert(this, store, script)
	if math.random(0, 100) > this.stun_chance * 100 then
		return false
	end

	return scripts.mod_stun.insert(this, store, script)
end

scripts.ps_hero_mecha_smoke = {}

function scripts.ps_hero_mecha_smoke.update(this, store)
	local source_sprite = store.entities[this.particle_system.track_id].render.sprites[1]

	while true do
		if source_sprite.flip_x then
			this.particle_system.emit_offset.x = math.abs(this.particle_system.emit_offset.x)
			this.particle_system.emit_direction = this.emit_direction_sides[2]
		else
			this.particle_system.emit_offset.x = -math.abs(this.particle_system.emit_offset.x)
			this.particle_system.emit_direction = this.emit_direction_sides[1]
		end

		coroutine.yield()
	end

	return true
end

scripts.mod_eiskalt_cold = {
	insert = function(this, store)
		if not scripts.mod_slow.insert(this, store) then
			return false
		end
		local target = store.entities[this.modifier.target_id]
		U.entity_insert_shader(target, SH:get(this.shader), this.shader_args, this.id)
		return true
	end,
	remove = function(this, store)
		if not scripts.mod_slow.remove(this, store) then
			return false
		end
		local target = store.entities[this.modifier.target_id]
		if target then
			U.entity_remove_shader(target, this.id)
		end
		return true
	end
}

--#region hero_isfet
scripts.hero_isfet = {}

function scripts.hero_isfet.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats
	local s, a

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = math.ceil(this.health.hp_max * GS.soldier_regen_factor)
	this.health.raw_armor = ls.armor[hl]

	SU.update_armor(this)

	if this.melee then
		this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
		this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
	end

	if this.ranged then
		local bt = E:get_template(this.ranged.attacks[1].bullet)
		bt.bullet.damage_min = ls.ranged_damage_min[hl]
		bt.bullet.damage_max = ls.ranged_damage_max[hl]
	end

	s = this.hero.skills.black_cloud
	a = this.timed_attacks.list[1]
	if s.level > 0 then
		a.disabled = nil
		local damage_mod = E:get_template("mod_isfet_locust_damage")
		damage_mod.dps.damage_min = s.damage[s.level]
		damage_mod.dps.damage_max = s.damage[s.level]
	end

	s = this.hero.skills.frog_curse
	a = this.timed_attacks.list[2]
	if s.level > 0 then
		a.disabled = nil
		a.health_threshold = s.health_threshold[s.level]
	end

	s = this.hero.skills.rain
	a = this.timed_attacks.list[3]
	if s.level > 0 then
		a.disabled = nil
		a.count = s.count[s.level]
	end

	s = this.hero.skills.blood_pool
	a = this.timed_attacks.list[4]
	if s.level > 0 then
		a.disabled = nil
		a.damage_factor = s.damage_factor[s.level]
		E:get_template(a.entity).aura.level = s.level
		E:get_template(E:get_template(a.entity).aura.mod).received_damage_factor = a.damage_factor
	end

	s = this.hero.skills.ultimate
	local controller = E:get_template(s.controller_name)
	controller.cooldown = s.cooldown[s.level]

	if initial then
		update_hp(this)
	end
end

local function isfet_frog_target(this, store, attack)
	if attack.disabled or store.tick_ts - attack.ts < attack.cooldown or not attack.health_threshold then
		return nil
	end

	local targets = U.find_enemies_in_range(store, this.pos, attack.min_range, attack.max_range, attack.vis_flags, attack.vis_bans, function(e)
		return e.health.hp < attack.health_threshold
	end)

	if not targets then
		return nil
	end

	table.sort(targets, function(e1, e2)
		return e1.health.hp > e2.health.hp
	end)

	return targets[1]
end

local function isfet_blood_pool_target(this, store, attack)
	local candidates = U.find_enemies_in_range(store, this.pos, attack.min_range, attack.max_range, attack.vis_flags, attack.vis_bans)

	if not candidates then
		return nil
	end

	local best, best_count

	for _, candidate in ipairs(candidates) do
		local crowd = U.find_enemies_in_range_filter_off(candidate.pos, attack.crowd_range, attack.vis_flags, attack.vis_bans)
		local count = crowd and #crowd or 0

		if count >= attack.min_targets and (not best_count or count > best_count) then
			best = candidate
			best_count = count
		end
	end

	return best
end

function scripts.hero_isfet.update(this, store)
	local h = this.health
	local black_cloud_attack = this.timed_attacks.list[1]
	local frog_attack = this.timed_attacks.list[2]
	local rain_attack = this.timed_attacks.list[3]
	local blood_pool_attack = this.timed_attacks.list[4]
	local brk, sta

	local necromancy = E:create_entity("aura_isfet_necromancy")
	necromancy.source_id = this.id
	necromancy.range = this.isfet_necromancy.range
	necromancy.chance = this.isfet_necromancy.chance
	necromancy.max_units = this.isfet_necromancy.max_units
	necromancy.cycle_time = this.isfet_necromancy.cycle_time
	necromancy.entity = this.isfet_necromancy.entity
	simulation:queue_insert_entity(necromancy)

	this.melee.attacks[1].ts = store.tick_ts
	this.ranged.attacks[1].ts = store.tick_ts
	black_cloud_attack.ts = store.tick_ts
	frog_attack.ts = store.tick_ts
	rain_attack.ts = store.tick_ts
	blood_pool_attack.ts = store.tick_ts

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
	this.health_bar.hidden = false

	local function cast_frog(target)
		local start_ts = store.tick_ts
		local skill = this.hero.skills.frog_curse

		frog_attack.ts = start_ts
		SU.hero_gain_xp_from_skill(this, skill)
		S:queue(frog_attack.sound)
		U.animation_start_default(this, frog_attack.animation, target.pos.x < this.pos.x, store.tick_ts, false)
		U.y_wait_unconditional(store, frog_attack.cast_time)

		local projectile = E:create_entity(frog_attack.projectile)
		local offset = target.pos.x < this.pos.x and V.v(-13, 27) or V.v(13, 27)

		projectile.pos = V.v(this.pos.x + offset.x, this.pos.y + offset.y)
		projectile.source_id = this.id
		projectile.target_id = target.id
		simulation:queue_insert_entity(projectile)
		SU.y_hero_animation_wait(this)
	end

	local function y_move_until_frog()
		local rally = this.nav_rally
		local grid = this.nav_grid
		local destination = rally.pos
		local immune_to = this.health.immune_to

		rally.new = false
		U.unblock_target(store, this)
		S:queue(this.sound_events.change_rally_point)
		U.bans_add(this.vis, F_ALL)
		this.health.immune_to = rally.immune_to

		while not V.veq(this.pos, destination) do
			local waypoint = table.remove(grid.waypoints, 1) or destination
			local unsnap = #grid.waypoints > 0

			U.set_destination(this, waypoint)
			local animation, flip = U.animation_name_facing_point(this, "walk", this.motion.dest)
			U.animation_start_default(this, animation, flip, store.tick_ts, true)

			while not this.motion.arrived do
				if h.dead and not h.ignore_damage then
					U.bans_remove(this.vis, F_ALL)
					this.health.immune_to = immune_to
					return "dead"
				end

				if rally.new then
					U.bans_remove(this.vis, F_ALL)
					this.health.immune_to = immune_to
					return "new_rally"
				end

				if isfet_frog_target(this, store, frog_attack) then
					rally.new = true
					U.bans_remove(this.vis, F_ALL)
					this.health.immune_to = immune_to
					return "frog"
				end

				U.walk(this, store.tick_length, nil, unsnap)
				coroutine.yield()
				this.motion.speed.x, this.motion.speed.y = 0, 0
			end
		end

		U.animation_start_default(this, "idle", nil, store.tick_ts, true)
		U.bans_remove(this.vis, F_ALL)
		this.health.immune_to = immune_to

		return "arrived"
	end

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			if SU.hero_level_up(store, this) then
				S:queue("HeroLevelUp")
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			local frog_target = isfet_frog_target(this, store, frog_attack)

			if frog_target then
				cast_frog(frog_target)
				goto label_isfet_end
			end

			if this.nav_rally.new then
				local move_result = y_move_until_frog()

				if move_result == "frog" then
					frog_target = isfet_frog_target(this, store, frog_attack)
					if frog_target then
						cast_frog(frog_target)
					end
				end

				goto label_isfet_end
			end

			if not black_cloud_attack.disabled and store.tick_ts - black_cloud_attack.ts >= black_cloud_attack.cooldown then
				local enemies = U.find_enemies_in_range_filter_off(this.pos, black_cloud_attack.trigger_range, black_cloud_attack.vis_flags, black_cloud_attack.vis_bans)

				if not enemies or #enemies < black_cloud_attack.min_targets then
					black_cloud_attack.ts = black_cloud_attack.ts + 0.2
				else
					local start_ts = store.tick_ts
					local skill = this.hero.skills.black_cloud
					local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true, NF_RALLY)
					local cast_flip = false

					if nodes and nodes[1] then
						local pi, spi, ni = unpack(nodes[1])
						local road_pos = P:node_pos(pi, spi, math.max(1, ni - 1))
						cast_flip = road_pos and road_pos.x < this.pos.x or false
					end

					black_cloud_attack.ts = start_ts
					SU.hero_gain_xp_from_skill(this, skill)
					S:queue(black_cloud_attack.sound, {
						delay = black_cloud_attack.sound_delay
					})
					U.animation_start_default(this, black_cloud_attack.animation, cast_flip, store.tick_ts, false)
					if not SU.y_hero_wait(store, this, black_cloud_attack.cast_time) then
						local cloud = E:create_entity(black_cloud_attack.entity)
						local offset = black_cloud_attack.spawn_offset

						cloud.pos = V.v(this.pos.x + (cast_flip and -1 or 1) * offset.x, this.pos.y + offset.y)
						cloud.source_id = this.id
						cloud.aura.level = skill.level
						if nodes and nodes[1] then
							cloud.nav_path.pi, cloud.nav_path.spi, cloud.nav_path.ni = unpack(nodes[1])
						end
						simulation:queue_insert_entity(cloud)
						SU.y_hero_animation_wait(this)
					end
					goto label_isfet_end
				end
			end

			if not rain_attack.disabled and store.tick_ts - rain_attack.ts >= rain_attack.cooldown then
				local enemies = U.find_enemies_in_range_filter_off(this.pos, rain_attack.range, rain_attack.vis_flags, rain_attack.vis_bans)

				if not enemies then
					rain_attack.ts = rain_attack.ts + 0.2
				else
					rain_attack.ts = store.tick_ts
					SU.hero_gain_xp_from_skill(this, this.hero.skills.rain)
					S:queue(rain_attack.sound, {
						delay = rain_attack.sound_delay
					})
					U.y_animation_play(this, rain_attack.animation_in, nil, store.tick_ts, 1)
					U.animation_start_default(this, rain_attack.animation_loop, nil, store.tick_ts, true)

					local controller = E:create_entity(rain_attack.entity)
					controller.pos = V.vclone(this.pos)
					controller.source_id = this.id
					controller.count = rain_attack.count
					simulation:queue_insert_entity(controller)
					U.y_wait_unconditional(store, rain_attack.loop_duration)
					U.y_animation_play(this, rain_attack.animation_out, nil, store.tick_ts, 1)
					goto label_isfet_end
				end
			end

			if not blood_pool_attack.disabled and store.tick_ts - blood_pool_attack.ts >= blood_pool_attack.cooldown then
				local target = isfet_blood_pool_target(this, store, blood_pool_attack)

				if not target then
					blood_pool_attack.ts = blood_pool_attack.ts + 0.2
				else
					blood_pool_attack.ts = store.tick_ts
					SU.hero_gain_xp_from_skill(this, this.hero.skills.blood_pool)
					S:queue(blood_pool_attack.sound, {
						delay = blood_pool_attack.sound_delay
					})
					U.animation_start_default(this, blood_pool_attack.animation, target.pos.x < this.pos.x, store.tick_ts, false)
					if not SU.y_hero_wait(store, this, blood_pool_attack.cast_time) then
						local pool = E:create_entity(blood_pool_attack.entity)
						pool.pos = V.vclone(target.pos)
						pool.aura.source_id = this.id
						pool.aura.level = this.hero.skills.blood_pool.level
						S:queue(pool.sound)
						simulation:queue_insert_entity(pool)
						SU.y_hero_animation_wait(this)
					end
					goto label_isfet_end
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if not brk and sta == A_NO_TARGET then
				brk, sta = SU.y_soldier_ranged_attacks(store, this)
				if not brk and not SU.soldier_go_back_step(store, this) then
					SU.soldier_idle(store, this)
					SU.soldier_regen(store, this)
				end
			end
		end

		::label_isfet_end::
		coroutine.yield()
	end
end

scripts.hero_isfet_bolt = {}

function scripts.hero_isfet_bolt.update(this, store)
	local b = this.bullet
	local fm = this.force_motion
	local target = store.entities[b.target_id]
	local ps

	local function move_step(dest)
		local dx, dy = V.sub(dest.x, dest.y, this.pos.x, this.pos.y)
		local dist = V.len(dx, dy)
		local nx, ny = V.mul(fm.max_v, V.normalize(dx, dy))
		local stx, sty = V.sub(nx, ny, fm.v.x, fm.v.y)

		if dist <= 4 * fm.max_v * store.tick_length then
			stx, sty = V.mul(fm.max_a, V.normalize(stx, sty))
		end

		fm.a.x, fm.a.y = V.add(fm.a.x, fm.a.y, V.trim(fm.max_a, V.mul(fm.a_step, stx, sty)))
		fm.v.x, fm.v.y = V.trim(fm.max_v, V.add(fm.v.x, fm.v.y, V.mul(store.tick_length, fm.a.x, fm.a.y)))
		this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, V.mul(store.tick_length, fm.v.x, fm.v.y))
		fm.a.x, fm.a.y = 0, 0

		return dist <= fm.max_v * store.tick_length
	end

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.emit = true
		ps.particle_system.track_id = this.id
		simulation:queue_insert_entity(ps)
	end

	local pred_pos
	if target then
		pred_pos = P:predict_enemy_pos(target, fts(5))
	else
		pred_pos = b.to
	end

	local iix, iiy = V.normalize(pred_pos.x - this.pos.x, pred_pos.y - this.pos.y)
	local last_pos = V.vclone(this.pos)

	b.ts = store.tick_ts

	while true do
		target = store.entities[b.target_id]

		if target and target.health and not target.health.dead and band(target.vis.bans, F_RANGED) == 0 then
			local hit_offset = V.v(0, 0)

			if not b.ignore_hit_offset then
				hit_offset.x = target.unit.hit_offset.x
				hit_offset.y = target.unit.hit_offset.y
			end

			local d = math.max(math.abs(target.pos.x + hit_offset.x - b.to.x), math.abs(target.pos.y + hit_offset.y - b.to.y))

			if d > b.max_track_distance then
				log.debug("BOLT MAX DISTANCE FAIL. (%s) %s / dist:%s target.pos:%s,%s b.to:%s,%s", this.id, this.template_name, d, target.pos.x, target.pos.y, b.to.x, b.to.y)
				target = nil
				b.target_id = nil
			else
				b.to.x, b.to.y = target.pos.x + hit_offset.x, target.pos.y + hit_offset.y
			end
		end

		if this.initial_impulse and store.tick_ts - b.ts < this.initial_impulse_duration then
			local t = store.tick_ts - b.ts

			if this.initial_impulse_angle_abs then
				fm.a.x, fm.a.y = V.mul((1 - t) * this.initial_impulse, V.rotate(this.initial_impulse_angle_abs, 1, 0))
			else
				local angle = this.initial_impulse_angle

				if iix < 0 then
					angle = angle * -1
				end

				fm.a.x, fm.a.y = V.mul((1 - t) * this.initial_impulse, V.rotate(angle, iix, iiy))
			end
		end

		last_pos.x, last_pos.y = this.pos.x, this.pos.y

		if move_step(b.to) then
			break
		end

		if b.align_with_trajectory then
			this.render.sprites[1].r = V.angleTo(this.pos.x - last_pos.x, this.pos.y - last_pos.y)
		end

		coroutine.yield()
	end

	if target and not target.health.dead then
		local d = SU.create_bullet_damage(b, target.id, this.id)
		queue_damage(store, d)

		if b.mod or b.mods then
			local mods = b.mods or {b.mod}

			for _, mod_name in ipairs(mods) do
				local m = E:create_entity(mod_name)
				m.modifier.target_id = b.target_id
				m.modifier.level = b.level
				simulation:queue_insert_entity(m)
			end
		end
	elseif b.damage_radius and b.damage_radius > 0 then
		local targets = U.find_enemies_in_range_filter_off(this.pos, b.damage_radius, b.vis_flags, b.vis_bans)

		if targets then
			for _, target in ipairs(targets) do
				local d = SU.create_bullet_damage(b, target.id, this.id)
				queue_damage(store, d)
			end
		end
	end

	this.render.sprites[1].hidden = true

	if b.hit_fx then
		local fx = E:create_entity(b.hit_fx)
		fx.pos.x, fx.pos.y = b.to.x, b.to.y
		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].runs = 0
		simulation:queue_insert_entity(fx)
	end

	if b.hit_decal then
		local decal = E:create_entity(b.hit_decal)
		decal.pos:copy(b.to)
		decal.render.sprites[1].ts = store.tick_ts
		simulation:queue_insert_entity(decal)
	end

	if ps and ps.particle_system.emit then
		ps.particle_system.emit = false
		U.y_wait_unconditional(store, ps.particle_system.particle_lifetime[2])
	end

	simulation:queue_remove_entity(this)
end

scripts.aura_isfet_necromancy = {}

function scripts.aura_isfet_necromancy.update(this, store)
	local last_ts = store.tick_ts - this.cycle_time

	while true do
		local source = store.entities[this.source_id]

		if not source or source.pending_removal then
			simulation:queue_remove_entity(this)
			return
		end

		this.pos = source.pos

		if not source.health.dead and store.tick_ts - last_ts >= this.cycle_time then
			last_ts = store.tick_ts
			local mummy_count = 0

			for _, entity in pairs(store.entities) do
				if entity.owner_id == source.id and entity.template_name == this.entity and entity.health and not entity.health.dead then
					mummy_count = mummy_count + 1
				end
			end

			if mummy_count < this.max_units then
				for _, dead in pairs(store.entities) do
					local damage_types = dead.health and dead.health.last_damage_types or 0
					local valid = dead.enemy and dead.health and dead.health.dead and dead.vis and not dead.pending_removal and not dead._isfet_necromancy_checked and band(dead.vis.flags, bor(F_FLYING, F_BOSS)) == 0 and band(damage_types, bor(DAMAGE_EAT, DAMAGE_NO_SPAWNS)) == 0 and U.is_inside_ellipse(dead.pos, source.pos, this.range)

					if valid then
						dead._isfet_necromancy_checked = true

						if math.random() < this.chance then
							U.bans_add(dead.vis, F_SKELETON)
							dead.health.delete_after = 0

							local mummy = E:create_entity(this.entity)
							mummy.pos = V.vclone(dead.pos)
							mummy.default_rally_pos = V.vclone(dead.pos)
							mummy.nav_rally.center = V.vclone(dead.pos)
							mummy.nav_rally.pos = V.vclone(dead.pos)
							mummy.owner_id = source.id
							mummy.health.hp = mummy.health.hp_max
							simulation:queue_insert_entity(mummy)

							mummy_count = mummy_count + 1
							if mummy_count >= this.max_units then
								break
							end
						end
					end
				end
			end
		end

		coroutine.yield()
	end
end

scripts.hero_isfet_mummy = {}

function scripts.hero_isfet_mummy.update(this, store)
	local spawn_ts = store.tick_ts
	local nearest = P:nearest_nodes(this.pos.x, this.pos.y)

	if nearest and nearest[1] then
		this.nav_path.pi, this.nav_path.spi, this.nav_path.ni = unpack(nearest[1])
	end

	this.health_bar.hidden = true
	S:queue(this.spawn_sound, {
		delay = this.spawn_sound_delay
	})
	U.y_animation_play(this, "spawn", nil, store.tick_ts, 1)
	this.health_bar.hidden = false

	while true do
		if not this.health.dead and store.tick_ts - spawn_ts >= this.lifetime then
			this.health.dead = true
			this.health.death_ts = store.tick_ts
		end

		if this.health.dead then
			U.unblock_target(store, this)
			this.health_bar.hidden = true
			this.render.sprites[2].hidden = true
			U.y_animation_play(this, "death", nil, store.tick_ts, 1)
			simulation:queue_remove_entity(this)
			return
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			local brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if not brk and sta == A_NO_TARGET then
				local next_pos = this.nav_path.pi and P:next_entity_node(this, store.tick_length)

				if not next_pos or not P:is_node_valid(this.nav_path.pi, this.nav_path.ni) then
					this.health.dead = true
					this.health.death_ts = store.tick_ts
				else
					U.set_destination(this, next_pos)
					local animation, flip = U.animation_name_facing_point(this, "walk", this.motion.dest)
					U.animation_start_default(this, animation, flip, store.tick_ts, true)
					U.walk(this, store.tick_length)
					this.motion.speed.x, this.motion.speed.y = 0, 0
				end
			end
		end

		coroutine.yield()
	end
end

scripts.aura_isfet_locust_swarm = {}

function scripts.aura_isfet_locust_swarm.update(this, store)
	local start_ts = store.tick_ts

	U.y_animation_play(this, "spawn", nil, store.tick_ts, 1)

	local infection = E:create_entity(this.infection_aura)
	infection.aura.source_id = this.id
	infection.aura.level = this.aura.level
	simulation:queue_insert_entity(infection)

	while store.tick_ts - start_ts < this.aura.duration do
		if this.nav_path.pi then
			local nearest = P:nearest_nodes(this.pos.x, this.pos.y, {this.nav_path.pi}, {this.nav_path.spi})

			if nearest and nearest[1] and nearest[1][3] < this.nav_path.ni then
				this.nav_path.ni = nearest[1][3]
			end

			local next_pos = P:next_entity_node(this, store.tick_length)

			if next_pos and P:is_node_valid(this.nav_path.pi, this.nav_path.ni) then
				U.set_destination(this, next_pos)
				local animation, flip = U.animation_name_facing_point(this, "walk", this.motion.dest)
				U.animation_start_default(this, animation, flip, store.tick_ts, true)
				U.walk(this, store.tick_length)
				this.motion.speed.x, this.motion.speed.y = 0, 0
			end
		end

		coroutine.yield()
	end

	U.y_animation_play(this, "death", nil, store.tick_ts, 1)
	simulation:queue_remove_entity(this)
end

scripts.projectile_isfet_frog_curse = {}

function scripts.projectile_isfet_frog_curse.update(this, store)
	local target = store.entities[this.target_id]

	if not target or target.health.dead then
		simulation:queue_remove_entity(this)
		return
	end

	local start_ts = store.tick_ts
	local from = V.vclone(this.pos)

	while store.tick_ts - start_ts < this.duration do
		target = store.entities[this.target_id]
		if not target or target.health.dead then
			simulation:queue_remove_entity(this)
			return
		end

		local to = V.v(target.pos.x, target.pos.y + (target.unit and target.unit.hit_offset.y or 0))
		local phase = km.clamp(0, 1, (store.tick_ts - start_ts) / this.duration)

		this.pos.x = from.x + (to.x - from.x) * phase
		this.pos.y = from.y + (to.y - from.y) * phase
		this.render.sprites[1].r = V.angleTo(to.x - from.x, to.y - from.y)
		coroutine.yield()
	end

	target = store.entities[this.target_id]
	if target and not target.health.dead then
		S:queue(this.sound_hit)
		S:queue(this.sound_frog)

		local damage = E.assign_damage(DAMAGE_INSTAKILL, target.health.hp_max, this.source_id, target.id)
		queue_damage(store, damage)

		local smoke = E:create_entity("fx_isfet_frog_smoke")
		smoke.pos = V.vclone(target.pos)
		simulation:queue_insert_entity(smoke)

		local frog = E:create_entity("decal_isfet_frog")
		frog.pos = V.vclone(target.pos)
		if target.render then
			frog.render.sprites[1].flip_x = target.render.sprites[1].flip_x
		end
		simulation:queue_insert_entity(frog)
	end

	simulation:queue_remove_entity(this)
end

scripts.decal_isfet_frog = {}

function scripts.decal_isfet_frog.update(this, store)
	local start_ts = store.tick_ts

	U.animation_start_default(this, "idle", nil, store.tick_ts, true)
	while store.tick_ts - start_ts < this.lifetime do
		if store.tick_ts - start_ts > this.lifetime * 0.5 and this.render.sprites[1].name ~= "talk" then
			U.animation_start_default(this, "talk", nil, store.tick_ts, true)
		end
		coroutine.yield()
	end

	U.y_animation_play(this, "death", nil, store.tick_ts, 1)
	simulation:queue_remove_entity(this)
end

scripts.controller_isfet_fire_ice_rain = {}

function scripts.controller_isfet_fire_ice_rain.update(this, store)
	for i = 1, this.count do
		local angle = math.random() * math.pi * 2
		local radius = math.sqrt(math.random()) * this.radius
		local destination = V.v(this.pos.x + math.cos(angle) * radius, this.pos.y + math.sin(angle) * radius)
		local projectile = E:create_entity(this.projectiles[math.random(1, #this.projectiles)])
		local scale = this.scale_min + math.random() * (this.scale_max - this.scale_min)

		projectile.pos = V.v(destination.x + math.random(-40, 40), destination.y + 120)
		projectile.to = destination
		projectile.source_id = this.source_id
		projectile.render.sprites[1].scale = V.v(scale, scale)
		S:queue(projectile.release_sound)
		simulation:queue_insert_entity(projectile)
		U.y_wait_unconditional(store, this.spawn_delay)
	end

	simulation:queue_remove_entity(this)
end

scripts.projectile_isfet_rain = {}

function scripts.projectile_isfet_rain.update(this, store)
	local start_ts = store.tick_ts
	local from = V.vclone(this.pos)

	this.render.sprites[1].r = V.angleTo(this.to.x - from.x, this.to.y - from.y)
	while store.tick_ts - start_ts < this.flight_time do
		local phase = km.clamp(0, 1, (store.tick_ts - start_ts) / this.flight_time)

		this.pos.x = from.x + (this.to.x - from.x) * phase
		this.pos.y = from.y + (this.to.y - from.y) * phase
		coroutine.yield()
	end

	this.pos = V.vclone(this.to)
	S:queue(this.hit_sound)
	local fx = E:create_entity(this.hit_fx)
	fx.pos:copy(this.to)
	simulation:queue_insert_entity(fx)

	local targets = U.find_enemies_in_range_filter_off(this.to, this.damage_radius, this.vis_flags, this.vis_bans)
	if targets then
		for _, target in ipairs(targets) do
			local damage = E.assign_damage(this.damage_type, this.damage, this.source_id, target.id)
			damage.xp_dest_id = this.source_id
			queue_damage(store, damage)

			local mod = E:create_entity(this.mod)
			mod.modifier.source_id = this.source_id
			mod.modifier.target_id = target.id
			mod.modifier.level = 1
			simulation:queue_insert_entity(mod)
		end
	end

	simulation:queue_remove_entity(this)
end

scripts.controller_hero_isfet_ultimate = {}

function scripts.controller_hero_isfet_ultimate.update(this, store)
	local level = this.level or 0
	local damage_value = this.damage[level]
	local ticks = math.floor(this.duration / this.tick_time + 0.5)

	S:queue(this.sound)
	U.y_animation_play(this, "in", nil, store.tick_ts, 1)
	U.animation_start_default(this, "run", nil, store.tick_ts, true)

	local slow_aura = E:create_entity(this.slow_aura)
	slow_aura.aura.source_id = this.id
	simulation:queue_insert_entity(slow_aura)

	local start_ts = store.tick_ts
	for tick = 1, ticks do
		while store.tick_ts < start_ts + tick * this.tick_time do
			coroutine.yield()
		end

		local cloud_targets = U.find_enemies_in_range_filter_off(this.pos, this.cloud_radius, this.damage_flags, this.damage_bans)
		local impact_pos

		if cloud_targets then
			impact_pos = V.vclone(cloud_targets[math.random(1, #cloud_targets)].pos)
		else
			local angle = math.random() * math.pi * 2
			local radius = math.sqrt(math.random()) * this.cloud_radius
			impact_pos = V.v(this.pos.x + math.cos(angle) * radius, this.pos.y + math.sin(angle) * radius)
		end

		local lightning = E:create_entity(this.lightning_fx)
		lightning.pos = V.v(impact_pos.x, impact_pos.y + this.lightning_origin_y)
		simulation:queue_insert_entity(lightning)

		local hit_fx = E:create_entity(this.lightning_hit_fx)
		hit_fx.pos = V.v(impact_pos.x, impact_pos.y + this.lightning_destination_y)
		simulation:queue_insert_entity(hit_fx)

		local damaged_targets = U.find_enemies_in_range_filter_off(impact_pos, this.damage_radius, this.damage_flags, this.damage_bans)
		if damaged_targets then
			for _, target in ipairs(damaged_targets) do
				local damage = E.assign_damage(this.damage_type, damage_value, this.id, target.id)
				queue_damage(store, damage)
			end
		end
	end

	U.y_animation_play(this, "out", nil, store.tick_ts, 1)
	simulation:queue_remove_entity(this)
end
--#endregion hero_isfet

--#endregion hero_orc

--#endregion hero_oloch

--#region hero_margosa

--#endregion hero_margosa

--#endregion hero_mortemis

--#endregion hero_jigou

--#region hero_tramin

--#endregion hero_tramin

-- ======== 毁灭坦克 SG-11 ========

-- ======== 银橡村关卡自带英雄（KR6 level05 stage hero）========
scripts.hero_stage_205_alleria = {}

function scripts.hero_stage_205_alleria.insert(this, store)
	this.melee.order = U.attack_order(this.melee.attacks)
	this.ranged.order = U.attack_order(this.ranged.attacks)

	return true
end

function scripts.hero_stage_205_alleria.update(this, store)
	local h = this.health
	local brk, sta
	local old_tombstone_time = this.hero.tombstone_show_time
	local old_tombstone_respawn_animation = this.hero.tombstone_respawn_animation

	this.health_bar.hidden = false

	local ma = this.timed_attacks.list[1]

	ma.ts = store.tick_ts - ma.cooldown

	local wa = this.timed_attacks.list[2]

	wa.ts = store.tick_ts - wa.cooldown

	if not this.ignore_in_animation then
		U.y_animation_play(this, "in", this.in_cinematic, store.tick_ts, 1)
	end

	U.animation_start_default(this, "idle", this.in_cinematic, store.tick_ts, true)

	while this.in_cinematic do
		coroutine.yield()
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
					goto label_stage_205_alleria_0
				end
			end

			if store.tick_ts - ma.ts > ma.cooldown and this.soldier.target_id == nil then
				local enemies = U.find_enemies_in_range(store, this.pos, ma.min_range, ma.max_range, ma.vis_flags, ma.vis_bans)

				if not enemies or #enemies < ma.min_targets then
					SU.delay_attack(store, ma, 1.5)
				else
					ma.ts = store.tick_ts

					local an, af = U.animation_name_facing_point(this, ma.animations[1], enemies[1].pos)

					U.y_animation_play(this, an, af, store.tick_ts, 1)

					local enemy_idx = 1

					for i = 1, ma.shots do
						S:queue(ma.sound)
						U.animation_start_default(this, ma.animations[2], nil, store.tick_ts, false)
						U.y_wait(store, ma.shoot_time)

						local target = enemies[enemy_idx]
						local bullet = E:create_entity(ma.bullet)

						bullet.pos:copy(this.pos)

						if ma.bullet_start_offset then
							local offset = ma.bullet_start_offset

							bullet.pos.x, bullet.pos.y = bullet.pos.x + (this.render.sprites[1].flip_x and -1 or 1) * offset.x, bullet.pos.y + offset.y
						end

						bullet.bullet.from:copy(bullet.pos)
						bullet.bullet.to:copy(target.pos)

						if not ma.ignore_hit_offset then
							bullet.bullet.to.x = bullet.bullet.to.x + target.unit.hit_offset.x
							bullet.bullet.to.y = bullet.bullet.to.y + target.unit.hit_offset.y
						end

						bullet.bullet.target_id = target.id
						bullet.bullet.source_id = this.id

						simulation:queue_insert_entity(bullet)

						enemy_idx = enemy_idx + 1

						if enemy_idx > #enemies then
							enemy_idx = 1
						end

						U.y_animation_wait(this)
					end

					U.y_animation_play(this, ma.animations[3], nil, store.tick_ts, 1)
				end
			end

			if store.tick_ts - wa.ts > wa.cooldown and this.soldier.target_id == nil then
				local enemies = U.find_enemies_in_range_filter_off(this.pos, wa.range_check, wa.vis_flags, wa.vis_bans)

				if not enemies or #enemies < wa.min_targets then
				-- block empty
				else
					wa.ts = store.tick_ts

					local an, af = U.animation_name_facing_point(this, wa.animation, enemies[1].pos)

					U.animation_start_default(this, an, af, store.tick_ts, false)
					U.y_wait(store, wa.cast_time)

					local e = E:create_entity(wa.entity)

					e.pos.x = this.pos.x + wa.spawn_offset.x
					e.pos.y = this.pos.y + wa.spawn_offset.y
					e.nav_rally.center = e.pos
					e.nav_rally.pos = V.vclone(e.pos)

					local has_mod, mods = U.has_modifiers(store, this, "mod_stage_205_tree_buff")

					if has_mod then
						e.health.hp_max = e.health.hp_max * mods[1].cat_hp_buff
						e.health.hp = e.health.hp_max
						e.melee.attacks[1].damage_min = e.melee.attacks[1].damage_min * mods[1].cat_dmg_buff
						e.melee.attacks[1].damage_max = e.melee.attacks[1].damage_max * mods[1].cat_dmg_buff
					end

					simulation:queue_insert_entity(e)
					S:queue(wa.sound)
					U.animation_start_default(e, "in", nil, store.tick_ts, false)
					U.y_animation_wait(this)
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
			-- block empty
			elseif SU.soldier_go_back_step(store, this) then
			-- block empty
			else
				brk, sta = SU.y_soldier_ranged_attacks(store, this)

				if brk then
				-- block empty
				else
					SU.soldier_idle(store, this)
					SU.soldier_regen(store, this)
				end
			end
		end

		::label_stage_205_alleria_0::

		coroutine.yield()
	end
end

-- ======== KR6 level215 特殊关卡英雄 Lord Blackburn ========
scripts.hero_stage_215_lord_blackburn = {}

function scripts.hero_stage_215_lord_blackburn.insert(this, store)
	this.melee.order = U.attack_order(this.melee.attacks)

	return true
end

function scripts.hero_stage_215_lord_blackburn.update(this, store)
	local brk, stam, blocked_enemy, counted_id
	this.health_bar.hidden = false

	local function do_corruption(count)
		this.render.sprites[1].prefix = this.corruption.renders[count]
		this.info.portrait = this.corruption.portraits[count]
		this.info.hero_portrait = this.corruption.hero_portraits[count]
		this.ui.click_rect = this.corruption.click_rects[count]
		this.soldier.melee_slot_offset = this.corruption.melee_offsets[count]
		local hb_offset = this.corruption.health_bar_offsets[count]
		U.change_health_bar_offset_x_run_time(this.health_bar, hb_offset.x)
		U.change_health_bar_offset_run_time(this.health_bar, hb_offset.y)
		this.hero.tombstone_decal = this.corruption.tombstones[count]
		this.health.hp_max = this.corruption.hp_max[count]
		this.health.hp = this.corruption.hp_max[count]
		this.health.armor = this.corruption.armor[count]
		this.health.magic_armor = this.corruption.magic_armor[count]
		this.regen.health = this.corruption.regen_health[count]
		this.melee.attacks[1].damage_min = this.corruption.damage_min[count]
		this.melee.attacks[1].damage_max = this.corruption.damage_max[count]
		this.melee.attacks[2].damage_min = this.corruption.damage_min[count]
		this.melee.attacks[2].damage_max = this.corruption.damage_max[count]
		this.melee.attacks[1].hit_fx = this.corruption.hit_fx[count]
		this.melee.attacks[2].hit_fx = this.corruption.hit_fx[count]

		signal.emit("change-stage-hero-image", this)
	end

	local function y_corrupt(count)
		this.corrupting = true
		this.ui.can_click = false
		this.health_bar.hidden = true
		this.health.ignore_damage = true

		local old_vis_bans = this.vis.bans

		U.bans_add(this.vis, F_ALL)

		U.unblock_target(store, this)
		SU.remove_modifiers(store, this, nil, "mod_stage_215_black_burn_mind_control")

		if count == 4 then
			S:queue(this.sound_energy)
		end

		if count == 2 then
			U.animation_start(this, "cinematic", nil, store.tick_ts, false, 1)
			U.y_wait(store, fts(50))
		else
			U.animation_start(this, "transform", nil, store.tick_ts, false, 1)
			S:queue(this.sound_energy)
			U.y_wait(store, fts(52))
		end

		if count == 2 then
			U.y_wait(store, fts(19))
			U.animation_start(this, "cinematictalkloop2", nil, store.tick_ts, true, 1)
			U.y_wait(store, store.level_mode ~= GAME_MODE_KR1 and 10.5 or 0)
			U.animation_start(this, "cinematiccontinue2", nil, store.tick_ts, false, 1)
			U.y_wait(store, fts(29))

			local decal = E:create_entity(this.explosion_ground_decal)

			decal.pos:copy(this.pos)
			decal.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(decal)
			S:queue(this.sound_power_up)
			U.y_wait(store, fts(82))
		elseif count == 4 then
			U.y_wait(store, fts(18))
			U.animation_start(this, "transformtalk", nil, store.tick_ts, true, 1)
			U.y_wait(store, 0.5)
			signal.emit("show-balloon_tutorial-pos", "S15_PRE_BOSS_01", false, V.v(this.pos.x - 6, this.pos.y + 60))
			U.y_wait(store, 3)
			U.animation_start(this, "transform2", nil, store.tick_ts, false, 1)
			S:queue(this.sound_power_up, {
				delay = 0.85
			})
			U.y_wait(store, fts(33))
			signal.emit("show-balloon_tutorial-pos", "S15_PRE_BOSS_02", false, V.v(this.pos.x - 6, this.pos.y + 85))
			S:queue(this.sound_jump, {
				delay = 4
			})
			U.y_wait(store, fts(73))
		else
			U.y_wait(store, fts(66))

			local decal = E:create_entity(this.explosion_ground_decal)

			decal.pos:copy(this.pos)
			decal.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(decal)
			S:queue(this.sound_power_up)
			U.y_wait(store, fts(82))
		end

		if count >= 4 then
			local boss = E:create_entity(this.corruption.boss)

			boss.pos.x, boss.pos.y = this.pos.x, this.pos.y
			boss.render.sprites[1].flip_x = this.render.sprites[1].flip_x
			boss.render.sprites[1].hidden = true

			simulation:queue_insert_entity(boss)
			coroutine.yield()

			boss.render.sprites[1].hidden = false
			this.render.sprites[1].hidden = true

			signal.emit("hide-stage-hero", this.id)
			simulation:queue_remove_entity(this)

			return
		end

		this.health_bar.hidden = false
		this.ui.can_click = true
		this.health.ignore_damage = false
		U.bans_remove(this.vis, F_ALL)

		if old_vis_bans ~= 0 then
			U.bans_add(this.vis, old_vis_bans)
		end

		this.unit.is_stunned = false

		U.animation_start(this, "idle", nil, store.tick_ts, true, 1)
		do_corruption(count)

		this.corrupting = false
	end

	if not this.skip_cutscene then
		while not this.start_intro do
			coroutine.yield()
		end

		if string.find(this.render.sprites[1].prefix, "1") then
			U.y_wait(store, this.intro_drink_time)
			S:queue(this.sound_drink)
			U.y_wait(store, this.intro_explosion_time)
			S:queue(this.sound_power_up)
		end

		while not U.animation_finished(this, 1) do
			coroutine.yield()
		end
	end

	U.animation_start(this, "idle", nil, store.tick_ts, false, 1)
	do_corruption(this.corrupt_count)

	while true do
		if blocked_enemy then
			if this.soldier.target_id ~= blocked_enemy.id then
				blocked_enemy = nil
			elseif blocked_enemy.health.dead then
				signal.emit("lord-of-destruction-stage215")

				counted_id = blocked_enemy.id
				blocked_enemy = nil
			end
		end

		if not blocked_enemy and this.soldier.target_id and this.soldier.target_id ~= counted_id then
			blocked_enemy = store.entities[this.soldier.target_id]
		end

		if this.corrupt then
			this.corrupt_count = this.corrupt_count + 1

			y_corrupt(this.corrupt_count)

			this.corrupt = false
		end

		if this.cutscene then
		-- block empty
		else
			if this.health.dead then
				SU.y_hero_death_and_respawn(store, this)
			end

			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_stage_215_lord_blackburn_0
				end
			end

			if this.melee then
				brk, stam = SU.y_soldier_melee_block_and_attacks(store, this)

				if brk or stam == A_DONE or stam == A_IN_COOLDOWN and not this.melee.continue_in_cooldown then
					goto label_stage_215_lord_blackburn_0
				end
			end

			if this.melee.continue_in_cooldown and stam == A_IN_COOLDOWN then
			-- block empty
			elseif SU.soldier_go_back_step(store, this) then
			-- block empty
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_stage_215_lord_blackburn_0::

		coroutine.yield()
	end
end

scripts.stage_215_lord_blackburn_ray = {}

function scripts.stage_215_lord_blackburn_ray.update(this, store)
	U.y_wait(store, this.hit_time)

	local explosion = E:create_entity(this.decal_explosion_ground)

	explosion.render.sprites[1].ts = store.tick_ts
	explosion.pos:copy(this.pos)

	simulation:queue_insert_entity(explosion)

	local aura = E:create_entity(this.aura)

	aura.pos = this.pos

	simulation:queue_insert_entity(aura)

	if this._tower then
		SU.remove_modifiers(store, this._tower)
		simulation:queue_remove_entity(store.entities[this._tower.id])

		local holder = table.filter(store.entities, function(k, v)
			return v.tower and v.tower.type == "holder" and v.tower_holder.holder_id == this._tower.tower.holder_id
		end)[1]

		if holder then
			simulation:queue_remove_entity(store.entities[holder.id])
		end
	end

	while not U.animation_finished(this, 1) do
		coroutine.yield()
	end

	signal.emit("hide-stage-hero", this.id)
	simulation:queue_remove_entity(this)
end

scripts.mod_stage_215_black_burn_mind_control = {}

function scripts.mod_stage_215_black_burn_mind_control.insert(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if target.sound_events then
		this.saved_rally_sound = target.sound_events.change_rally_point
		target.sound_events.change_rally_point = nil
	end

	target.nav_rally.new = true
	target.nav_rally.pos = this.target_pos
	target.nav_rally.center = this.target_pos
	target.nav_grid.waypoints = GR:find_waypoints(target.pos, this.target_pos, this.target_pos, target.nav_grid.valid_terrains, true) or {}
	U.speed_mul(target, this.modifier.speed_factor)
	target.ui.can_click = false
	target.ui.can_select = false
	target.ui.can_hover = false
	target.ui.can_drag = false
	this.inserted = true

	return true
end

function scripts.mod_stage_215_black_burn_mind_control.remove(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if target.sound_events then
		target.sound_events.change_rally_point = this.saved_rally_sound
	end

	target.nav_grid.waypoints = {}
	U.speed_div(target, this.modifier.speed_factor)
	target.ui.can_click = true
	target.ui.can_select = true
	target.ui.can_hover = true
	target.ui.can_drag = true

	return true
end

-- ============================================================
-- KR6 stage 18（最终关）英雄 Denas
-- ============================================================
scripts.hero_stage_218_denas = {}

local function denas_spawn_guard_squad(store, dg, spawn_pos, entity_name, walk_from, turn_y)
	local squad_id
	local out = {}

	for j = 1, 2 do
		local e = E:create_entity(entity_name or dg.entity)

		squad_id = squad_id or e.id
		e.reinforcement.squad_id = squad_id
		e.render.sprites[1].prefix = e.render.sprites[1].prefix .. j
		e.pos.x = j == 1 and spawn_pos.x + 10 or spawn_pos.x - 10
		e.pos.y = j == 1 and spawn_pos.y - 10 or spawn_pos.y + 10

		if j == 2 then
			e.info.random_name_format = "SOLDIER_REINFORCEMENTS_F_%i_NAME"
			e.info.random_name_count = 4
		end

		e.info.portrait = string.format("kr6_info_portraits_soldiers_%04i", 6 + j)
		e.nav_rally.center = V.vclone(spawn_pos)

		if walk_from then
			e.nav_rally.pos = V.v(e.pos.x, e.pos.y)
			e.pos.x = walk_from.x + (j == 1 and 12 or -12)
			e.pos.y = walk_from.y + (j == 1 and -8 or 8)
			e.nav_grid.waypoints = turn_y and {V.v(e.pos.x, turn_y)} or {}
			e.nav_rally.new = true
			e.sound_events.change_rally_point = nil
		else
			e.nav_rally.pos = V.vclone(e.pos)
		end

		simulation:queue_insert_entity(e)

		out[#out + 1] = e
	end

	return out
end

function scripts.hero_stage_218_denas.insert(this, store)
	this.melee.order = U.attack_order(this.melee.attacks)

	return true
end

local function denas_find_bomb_cluster(store, this, ba, predict_time)
	local enemies = U.find_enemies_in_range_filter_off(this.pos, ba.max_range, ba.vis_flags, ba.vis_bans)

	if not enemies then
		return nil, 0
	end

	local pos = {}

	for i = 1, #enemies do
		local e = enemies[i]
		local p = e.pos

		if predict_time and e.motion and e.motion.speed then
			if e.motion.forced_waypoint then
				p = V.v(e.pos.x + predict_time * e.motion.speed.x, e.pos.y + predict_time * e.motion.speed.y)
			else
				local node_offset = P:predict_enemy_node_advance(e, predict_time)

				p = P:node_pos(e.nav_path.pi, e.nav_path.spi, e.nav_path.ni + node_offset)
			end
		end

		pos[i] = p
	end

	local vc = store.visible_coords
	local best, best_count = nil, 0

	for i = 1, #enemies do
		local epos = pos[i]

		if epos.x > vc.left + ba.edge_margin and epos.x < vc.right - ba.edge_margin and not U.is_inside_ellipse(epos, this.pos, ba.hero_margin) then
			local count = 0

			for j = 1, #enemies do
				if U.is_inside_ellipse(pos[j], epos, ba.cluster_radius) then
					count = count + 1
				end
			end

			if best_count < count then
				best, best_count = epos, count
			end
		end
	end

	return best, best_count
end

function scripts.hero_stage_218_denas.y_bombardement(store, this)
	local ba = this.timed_attacks.list[1]

	if store.tick_ts - ba.ts <= ba.cooldown then
		return false
	end

	local best, best_count = denas_find_bomb_cluster(store, this, ba, nil)

	if not best or best_count < ba.min_targets then
		SU.delay_attack(store, ba, 1.5)

		return false
	end

	local target_pos = V.vclone(best)
	local start_ts = store.tick_ts
	local flip = target_pos.x < this.pos.x

	U.animation_start_default(this, ba.animation, flip, store.tick_ts)

	while store.tick_ts - start_ts < ba.cast_time do
		if this.nav_rally.new or this.health.dead or this.unit.is_stunned then
			SU.delay_attack(store, ba, 1.5)

			return true
		end

		coroutine.yield()
	end

	ba.ts = store.tick_ts

	local flight_time = E:get_template(ba.bullet).bullet.flight_time
	local pbest, pcount = denas_find_bomb_cluster(store, this, ba, flight_time)

	if pbest and pcount >= ba.min_targets then
		target_pos = V.vclone(pbest)
	end

	local vc = store.visible_coords
	local mid_x = (vc.left + vc.right) / 2
	local offset_border = 50
	local from_x = mid_x > target_pos.x and vc.left + offset_border or vc.right - offset_border
	local from_y = vc.bottom - 60

	for i = 1, ba.shots do
		local e = E:create_entity(ba.bullet)
		local p

		if i == 1 then
			p = V.v(target_pos.x, target_pos.y)
		else
			local spread = math.random(ba.min_spread, ba.max_spread)

			p = V.v(target_pos.x + math.random(-spread, spread), target_pos.y + math.random(-spread, spread))
		end

		e.pos.x, e.pos.y = from_x, from_y
		e.bullet.from:copy(e.pos)
		e.bullet.to = p
		e.bullet.source_id = this.id
		e.bullet.damage_factor = 1

		simulation:queue_insert_entity(e)

		local ts = store.tick_ts

		while store.tick_ts - ts < ba.burst_interval do
			if this.nav_rally.new or this.health.dead or this.unit.is_stunned then
				return true
			end

			coroutine.yield()
		end
	end

	while not U.animation_finished(this) do
		if this.nav_rally.new or this.health.dead or this.unit.is_stunned then
			return true
		end

		coroutine.yield()
	end

	return true
end

function scripts.hero_stage_218_denas.y_denas_guards(store, this)
	local dg = this.timed_attacks.list[2]

	if store.tick_ts - dg.ts <= dg.cooldown then
		return false
	end

	local info = U.find_enemies_in_paths(store.enemies, this.pos, dg.range_nodes_min, dg.range_nodes_max, dg.max_path_dist, 0, bor(F_FLYING, F_WATER, F_CLIFF), nil)

	if not info then
		SU.delay_attack(store, dg, 1.5)

		return false
	end

	local target = info[1].enemy
	local spawn_pos = P:node_pos(target.nav_path.pi, 1, target.nav_path.ni + dg.ahead_nodes)
	local start_ts = store.tick_ts

	U.animation_start_default(this, dg.animation, spawn_pos.x < this.pos.x, store.tick_ts)

	while store.tick_ts - start_ts < dg.cast_time do
		if this.nav_rally.new or this.health.dead or this.unit.is_stunned then
			SU.delay_attack(store, dg, 1.5)

			return true
		end

		coroutine.yield()
	end

	dg.ts = store.tick_ts

	denas_spawn_guard_squad(store, dg, spawn_pos)

	while not U.animation_finished(this) do
		if this.nav_rally.new or this.health.dead or this.unit.is_stunned then
			return true
		end

		coroutine.yield()
	end

	return true
end

function scripts.hero_stage_218_denas.y_cinematic_entrance(store, this)
	local dest = this.cinematic_entrance_to
	local entry = V.v(this.pos.x, this.pos.y)
	local speed = this.motion.max_speed
	local dg = this.timed_attacks.list[2]

	local function dist_left()
		return V.dist(this.pos.x, this.pos.y, dest.x, dest.y)
	end

	local taunted = false
	local gallop_ts
	local gallop_y = store.visible_coords.bottom - speed * (this.cinematic_gallop_lead or 0)

	local function y_walk_while(cond)
		while cond() do
			U.walk(this, store.tick_length)

			if not gallop_ts and this.pos.y >= gallop_y then
				gallop_ts = store.tick_ts

				S:queue(this.sound_events.cinematic_gallop)
				S:queue(this.sound_events.cinematic_neigh, {
					delay = this.cinematic_neigh_delay
				})
			end

			if not taunted and this.pos.y >= store.visible_coords.bottom then
				taunted = true

				S:queue(this.sound_events.cinematic_entrance)
			end

			coroutine.yield()
		end
	end

	U.set_destination(this, dest)
	U.animation_start_default(this, "cinematic_walk_up", nil, store.tick_ts, true)
	y_walk_while(function()
		return dist_left() > speed * fts(22)
	end)
	U.animation_start_default(this, "cinematic_drift_in", nil, store.tick_ts, false)
	y_walk_while(function()
		return not U.animation_finished(this)
	end)
	U.animation_start_default(this, "cinematic_drift_loop", nil, store.tick_ts, true)

	while not U.walk(this, store.tick_length) do
		coroutine.yield()
	end

	this.pos.x, this.pos.y = dest.x, dest.y
	this.nav_rally.center = V.vclone(dest)
	this.nav_rally.pos = V.vclone(dest)
	this.nav_rally.new = false

	U.animation_start_default(this, "cinematic_drift_out", nil, store.tick_ts, false)
	U.y_animation_wait(this)
	U.animation_start_default(this, "summon_royal_guard", nil, store.tick_ts, false)
	U.y_wait(store, dg.cast_time)
	signal.emit("show-balloon_tutorial-pos", "S18_TRANS_01", false, V.v(this.pos.x, this.pos.y + 80))

	local turn_y = dest.y + (entry.y > dest.y and 50 or -50)
	local guards = {}

	for _, sp in ipairs(this.initial_squads_pos or {}) do
		local from = V.v(entry.x + sp.entry_offset.x, entry.y + sp.entry_offset.y)

		for _, g in ipairs(denas_spawn_guard_squad(store, dg, sp.pos, dg.initial_entity, from, turn_y)) do
			guards[#guards + 1] = g
		end

		U.y_wait(store, 0.25)
	end

	U.y_animation_wait(this)
	U.animation_start_default(this, "idle", nil, store.tick_ts, true)

	local deadline = store.tick_ts + 12

	local function arrived(g)
		if not store.entities[g.id] then
			return true
		end

		if g.health and g.health.dead then
			return true
		end

		return not g.nav_rally.new and V.dist(g.pos.x, g.pos.y, g.nav_rally.pos.x, g.nav_rally.pos.y) <= 8
	end

	while deadline > store.tick_ts do
		local all = true

		for _, g in ipairs(guards) do
			if not arrived(g) then
				all = false

				break
			end
		end

		if all then
			break
		end

		coroutine.yield()
	end

	this.cinematic_entrance_done = true

	U.animation_start_default(this, "idle", nil, store.tick_ts, true)

	while not this.cinematic_look_start do
		coroutine.yield()
	end

	U.y_animation_play(this, "look_around_in", nil, store.tick_ts, 1)
	U.animation_start_default(this, "look_around_loop", nil, store.tick_ts, true)

	while not this.cinematic_look_end do
		coroutine.yield()
	end

	U.y_animation_play(this, "look_around_out", nil, store.tick_ts, 1)
	U.animation_start_default(this, "idle", nil, store.tick_ts, true)

	this.cinematic_look_done = true
end

function scripts.hero_stage_218_denas.update(this, store)
	local h = this.health
	local brk, sta

	this.health_bar.hidden = false

	local ba = this.timed_attacks.list[1]

	SU.delay_attack(store, ba, 2)

	local dg = this.timed_attacks.list[2]

	SU.delay_attack(store, dg, 4)

	if not this.ignore_in_animation then
		U.y_animation_play(this, "revive", this.in_cinematic, store.tick_ts, 1)
	end

	U.animation_start_default(this, "idle", this.in_cinematic, store.tick_ts, true)

	if not this.cinematic_entrance_to then
		for _, sp in ipairs(this.initial_squads_pos or {}) do
			denas_spawn_guard_squad(store, dg, sp.pos, dg.initial_entity)
		end
	end

	if this.cinematic_entrance_to then
		scripts.hero_stage_218_denas.y_cinematic_entrance(store, this)
	end

	while this.in_cinematic do
		coroutine.yield()
	end

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				local rsb = this.rally_speed_boost
				local walk_angles = this.render.sprites[1].angles.walk
				local boosted = false

				if V.dist(this.pos.x, this.pos.y, this.nav_rally.pos.x, this.nav_rally.pos.y) > rsb.min_dist then
					U.speed_mul(this, rsb.speed_factor)
					walk_angles[1] = "walk"
					boosted = true
				end

				local out = SU.y_hero_new_rally(store, this)

				if boosted then
					U.speed_div(this, rsb.speed_factor)
				end

				walk_angles[1] = "walk_slow"

				if out then
					goto label_308_0
				end
			end

			do
				local target = SU.soldier_pick_melee_target(store, this)

				if not target or this.soldier.target_id == target.id and this.motion.arrived then
					if scripts.hero_stage_218_denas.y_bombardement(store, this) then
						goto label_308_0
					end

					if scripts.hero_stage_218_denas.y_denas_guards(store, this) then
						goto label_308_0
					end
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

		::label_308_0::

		coroutine.yield()
	end
end

scripts.decal_regson_heal_ball = {}

return scripts
