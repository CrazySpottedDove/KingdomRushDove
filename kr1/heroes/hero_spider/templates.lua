local scripts = require("scripts")
local E = require("entity_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local bit = require("bit")
local HU = require("hero_utils")
local log = require("lib.klua.log"):new("hero_scripts")
local band = bit.band
local bor = bit.bor
local fts = U.fts
local level_up_basic = HU.level_up_basic
local queue_damage = U.queue_damage
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local v = V.v
local vv = V.vv
local tt

local function mod_hero_spider_skill_instakill_melee_insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target then
		return false
	end

	if band(target.vis.flags, this.modifier.vis_bans) ~= 0 then
		return false
	end

	if band(target.vis.bans, this.modifier.vis_flags) ~= 0 then
		return false
	end

	SU.stun_inc(target)
	U.bans_add(target.vis, F_ALL)

	target.ui.can_click = false
	target.ui.can_select = false
	target.health_bar.hidden = true

	return true
end

local function mod_hero_spider_skill_instakill_melee_update(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if not target then
		simulation:queue_remove_entity(this)

		return
	end

	this.pos = target.pos

	local d = E.assign_damage(bor(DAMAGE_INSTAKILL, DAMAGE_FX_NOT_EXPLODE, DAMAGE_NO_SPAWNS, DAMAGE_IGNORE_SHIELD), 0, this.id, target.id)

	queue_damage(store, d)

	this._not_interrupted = true
	this.pos = target.pos

	local source = store.entities[this.modifier.source_id]

	if source then
		U.heal(source, source.health.hp_max * this.heal_factor)
	end

	U.y_animation_play(this, "run", nil, store.tick_ts, 1)
	simulation:queue_remove_entity(this)
end

local function hero_spider_level_up(this, store, initial)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local bt = E:get_template(this.ranged.attacks[1].bullet)

	bt.bullet.damage_min = ls.ranged_damage_min[hl]
	bt.bullet.damage_max = ls.ranged_damage_max[hl]

	local melee_dot = E:get_template(this.melee.attacks[1].mod)

	melee_dot.dps.damage_min = ls.melee_dot_damage_min[hl]
	melee_dot.dps.damage_max = ls.melee_dot_damage_max[hl]

	upgrade_skill(this, "instakill_melee", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]
		a.life_threshold = s.life_threshold[s.level]
	end)
	upgrade_skill(this, "area_attack", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]
	end)
	upgrade_skill(this, "tunneling", function(this, s)
		local a = this.timed_attacks.list[3]

		a.disabled = nil
	end)
	upgrade_skill(this, "supreme_hunter", function(this, s)
		local a = this.timed_attacks.list[4]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]
		a.damage_min = s.damage_min[s.level]
		a.damage_max = s.damage_max[s.level]

		local m = E:get_template(a.mod)

		m.dps.damage_min = m.damage_min_config[s.level]
		m.dps.damage_max = m.damage_max_config[s.level]
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		this.ultimate.disabled = nil
		this.ultimate.cooldown = s.cooldown[s.level]

		local uc = E:get_template(s.controller_name)

		uc.cooldown = s.cooldown[s.level]
		uc.spawn_amount = s.spawn_amount[s.level]

		local spider = E:get_template(uc.spider)

		spider.reinforcement.duration = s.duration[s.level]
		spider.health.hp_max = s.hp[s.level]
		spider.melee.attacks[1].damage_min = s.damage_min[s.level]
		spider.melee.attacks[1].damage_max = s.damage_max[s.level]
	end)
	update_hp(this)

	this.hero.melee_active_status = {}

	for index, attack in ipairs(this.melee.attacks) do
		this.hero.melee_active_status[index] = attack.disabled
	end
end

local function hero_spider_update(this, store)
	local h = this.health
	local brk, sta
	local last_ts = store.tick_ts
	local a, skill
	local instakill_on_melee_attack = this.timed_attacks.list[1]
	local area_attack_attack = this.timed_attacks.list[2]
	local tunneling_attack = this.timed_attacks.list[3]
	local supreme_hunter_attack = this.timed_attacks.list[4]

	if not instakill_on_melee_attack.disabled then
		instakill_on_melee_attack.ts = store.tick_ts - instakill_on_melee_attack.cooldown
	end

	if not area_attack_attack.disabled then
		area_attack_attack.ts = store.tick_ts - area_attack_attack.cooldown
	end

	if not supreme_hunter_attack.disabled then
		supreme_hunter_attack.ts = store.tick_ts - supreme_hunter_attack.cooldown
	end

	local function y_hero_spider_new_rally(store, this)
		local r = this.nav_rally

		if r.new then
			r.new = false

			U.unblock_target(store, this)

			if this.sound_events then
				S:queue(this.sound_events.change_rally_point)
			end

			if SU.hero_will_teleport(this, r.pos) then
				local tp = this.teleport

				U.bans_add(this.vis, F_ALL)

				this.health.ignore_damage = true
				this.health_bar.hidden = true

				local an, af = U.animation_name_facing_point(this, tp.animations[1], r.pos)

				U.animation_start(this, an, af, store.tick_ts, false, nil)
				U.y_wait_unconditional(store, fts(8))
				S:queue(tp.sound_in)

				local fx = E:create_entity(tp.fx_out)

				fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
				fx.render.sprites[1].ts = store.tick_ts
				fx.render.sprites[2].ts = store.tick_ts

				if fx.tween then
					fx.tween.ts = store.tick_ts
				end

				simulation:queue_insert_entity(fx)
				SU.y_hero_animation_wait(this)

				skill = this.hero.skills.tunneling
				a = tunneling_attack

				U.sprites_hide(this, nil, nil, true)

				if tp.delay > 0 then
					U.y_wait_unconditional(store, tp.delay)
				end

				S:queue(tp.sound_appear)

				local fx_approach = E:create_entity("fx_hero_spider_teleport_approach")

				fx_approach.pos.x, fx_approach.pos.y = r.pos.x, r.pos.y
				fx_approach.render.sprites[1].ts = store.tick_ts

				if r.pos.x < this.pos.x then
					fx_approach.render.sprites[1].flip_x = true
				end

				simulation:queue_insert_entity(fx_approach)
				U.y_wait_unconditional(store, tp.duration)

				fx_approach.leave = true

				U.sprites_show(this, nil, nil, true)

				this.pos.x, this.pos.y = r.pos.x, r.pos.y

				U.set_destination(this, this.pos)

				this.motion.speed.x, this.motion.speed.y = 0, 0

				local fx = E:create_entity(tp.fx_in)

				fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
				fx.render.sprites[1].ts = store.tick_ts
				fx.render.sprites[2].ts = store.tick_ts

				if fx.tween then
					fx.tween.ts = store.tick_ts
				end

				simulation:queue_insert_entity(fx)
				S:queue(tp.sound_out)

				if not a.disabled then
					local decal = E:create_entity(a.hit_decal)

					decal.pos.x, decal.pos.y = this.pos.x, this.pos.y
					decal.render.sprites[1].ts = store.tick_ts

					simulation:queue_insert_entity(decal)

					local target, targets = U.find_foremost_enemy_in_range_filter_off(this.pos, a.damage_radius, 0, a.vis_flags, a.vis_bans_damage)

					if target and targets then
						for _, enemy in ipairs(targets) do
							if enemy and not enemy.dead then
								local d = E.assign_damage(a.damage_type, math.random(a.damage_min[skill.level], a.damage_max[skill.level]), this.id, enemy.id)

								queue_damage(store, d)

								if band(enemy.vis.bans, bor(F_MOD, F_STUN)) == 0 then
									local m = E:create_entity("mod_hero_spider_tunneling_stun")

									m.modifier.source_id = this.id
									m.modifier.target_id = enemy.id

									simulation:queue_insert_entity(m)
								end
							end
						end
					end

					SU.hero_gain_xp_from_skill(this, skill)
				end

				U.y_animation_play(this, tp.animations[2], nil, store.tick_ts)

				this.health_bar.hidden = false

				U.bans_remove(this.vis, F_ALL)

				this.health.ignore_damage = false

				return true
			else
				local prev_immune = this.health.immune_to

				U.bans_add(this.vis, F_ALL)

				this.health.immune_to = r.immune_to

				local out = SU.y_hero_walk_waypoints(store, this)

				U.animation_start_default(this, "idle", nil, store.tick_ts, true)
				U.bans_remove(this.vis, F_ALL)

				this.health.immune_to = prev_immune

				return out
			end
		end
	end

	U.animation_start_default(this, "idle", nil, store.tick_ts, true)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if y_hero_spider_new_rally(store, this) then
					goto label_1340_1
				end
			end

			skill = this.hero.skills.instakill_melee
			a = instakill_on_melee_attack

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				if this.soldier.target_id == nil then
					a.ts = a.ts + fts(5)
				elseif not this.motion.arrived then
				-- a.ts = a.ts + fts(5)
				else
					local target = store.entities[this.soldier.target_id]

					if not target then
						a.ts = a.ts + fts(5)
					else
						local is_boss = U.flag_has(target.vis.flags, bor(F_BOSS, F_MINIBOSS))

						if is_boss then
							a.ts = a.ts + fts(5)
						elseif target.health.dead then
							a.ts = a.ts + fts(5)
						elseif not target.unit.is_stunned then
							a.ts = a.ts + fts(5)
						else
							if target.health.hp > a.life_threshold then
								a.ts = a.ts + fts(5)
							else
								last_ts = store.tick_ts

								local an, af = U.animation_name_facing_point(this, a.animation, target.pos)

								U.animation_start_default(this, an, af, store.tick_ts, false)
								S:queue("HeroSpiderInstakill")
								U.y_wait_unconditional(store, a.shoot_time)

								local m = E:create_entity(a.mod)

								m.modifier.target_id = target.id
								m.modifier.source_id = this.id

								simulation:queue_insert_entity(m)

								a.ts = last_ts

								SU.hero_gain_xp_from_skill(this, skill)
								U.y_animation_wait_default(this)

								goto label_1340_1
							end
						end
					end
				end
			end

			a = this.timed_attacks.list[4]
			skill = this.hero.skills.supreme_hunter

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local blocked_enemy = this.soldier.target_id and store.entities[this.soldier.target_id]

				if not blocked_enemy and SU.soldier_pick_melee_target(store, this) then
					a.ts = a.ts + 0.3333333333333333

					goto label_1340_0
				end

				local targets = U.find_enemies_in_range_filter_on(this.pos, a.max_range, a.vis_flags, a.vis_bans, function(e)
					local ni_s = P:get_visible_start_node(e.nav_path.pi)
					local ni_e = P:get_visible_end_node(e.nav_path.pi)

					return e ~= blocked_enemy and e.nav_path.ni > ni_s + a.node_margin and e.nav_path.ni < ni_e - a.node_margin
				end)

				if not targets then
					a.ts = a.ts + 0.3333333333333333

					goto label_1340_0
				end

				table.sort(targets, function(e1, e2)
					return e1.health.hp > e2.health.hp
				end)

				local target = targets[1]
				local initial_pos = V.vclone(this.pos)
				local initial_flip = this.render.sprites[1].flip_x

				U.bans_add(this.vis, F_ALL)

				this.health.ignore_damage = true

				S:queue(a.sound_supreme)
				U.animation_start_default(this, a.animations[1], nil, store.tick_ts)
				U.y_wait_unconditional(store, fts(14))

				this.health_bar.hidden = true

				U.y_wait_unconditional(store, fts(3))

				if U.is_blocked_valid(store, this) then
					local blocked = store.entities[this.soldier.target_id]
					local m = E:create_entity("mod_hero_spider_stun")

					m.modifier.target_id = blocked.id
					m.modifier.source_id = this.id

					simulation:queue_insert_entity(m)
				end

				U.y_animation_wait_default(this)

				local m = E:create_entity("mod_hero_spider_stun")

				m.modifier.target_id = target.id
				m.modifier.source_id = this.id

				simulation:queue_insert_entity(m)

				local lpos, lflip = U.melee_slot_position(this, target, 2)

				this.pos.x, this.pos.y = lpos.x, lpos.y

				U.animation_start_default(this, a.animations[2], lflip, store.tick_ts)
				U.y_wait_unconditional(store, fts(20))

				this.health_bar.hidden = nil

				queue_damage(store, SU.create_attack_damage(a, target.id, this))

				if band(target.vis.bans, bor(F_MOD, F_POISON)) == 0 then
					local mod = E:create_entity(a.mod)

					mod.modifier.target_id = target.id
					mod.modifier.source_id = this.id

					simulation:queue_insert_entity(mod)
				end

				U.y_animation_wait_default(this)

				if this.nav_rally.new then
					this.nav_rally.new = false
					this.pos.x, this.pos.y = this.nav_rally.pos.x, this.nav_rally.pos.y
				else
					this.pos.x, this.pos.y = initial_pos.x, initial_pos.y
				end

				U.animation_start_default(this, a.animations[3], initial_flip, store.tick_ts)
				U.y_wait_unconditional(store, fts(5))

				this.health_bar.hidden = nil

				U.bans_remove(this.vis, F_ALL)

				this.health.ignore_damage = nil

				U.y_animation_wait_default(this)
				SU.hero_gain_xp_from_skill(this, skill)

				a.ts = store.tick_ts
			end

			::label_1340_0::

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
				local target = U.find_foremost_enemy_in_range_filter_off(this.pos, 200, 0, F_AREA, 0)

				if target and target.pos then
					local e = E:create_entity(this.hero.skills.ultimate.controller_name)

					e.level = this.hero.skills.ultimate.level
					e.pos = V.vclone(target.pos)

					simulation:queue_insert_entity(e)

					this.ultimate.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
				else
					this.ultimate.ts = this.ultimate.ts + 1
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
				-- block empty
				a = this.timed_attacks.list[2]
				skill = this.hero.skills.area_attack

				if not a.disabled and store.tick_ts - a.ts > a.cooldown and store.tick_ts - last_ts > a.min_cooldown then
					local _, targets, pred_pos = U.find_foremost_enemy_in_range_filter_off(this.pos, a.damage_radius, 0, a.vis_flags, a.vis_bans_trigger)

					if not targets or #targets < a.min_targets or not pred_pos then
						a.ts = a.ts + fts(10)
					else
						local start_ts = store.tick_ts
						local an, af = U.animation_name_facing_point(this, a.animation, pred_pos)

						U.animation_start(this, an, af, store.tick_ts, false, nil)
						S:queue(a.sound)

						if SU.y_hero_wait(store, this, a.cast_time) then
							goto label_1340_1
						end

						local target, targets = U.find_foremost_enemy_in_range_filter_off(this.pos, a.damage_radius, 0, a.vis_flags, a.vis_bans_damage)

						if target and targets then
							for _, enemy in ipairs(targets) do
								if enemy and not enemy.dead then
									local d = E.assign_damage(a.damage_type, math.random(a.damage_min[skill.level], a.damage_max[skill.level]), this.id, enemy.id)

									queue_damage(store, d)

									local mod = E:create_entity(a.mod)

									mod.modifier.target_id = enemy.id
									mod.modifier.source_id = this.id
									mod.modifier.duration = fts(skill.stun_time[skill.level])

									simulation:queue_insert_entity(mod)

									local decal = E:create_entity(a.hit_decal)

									decal.pos:copy(this.pos)

									decal.render.sprites[1].ts = store.tick_ts

									simulation:queue_insert_entity(decal)
								end
							end
						end

						SU.y_hero_animation_wait(this)

						a.ts = start_ts
						last_ts = a.ts

						SU.hero_gain_xp_from_skill(this, skill)

						if not this.timed_attacks.list[4].disabled and this.timed_attacks.list[4].cooldown - (store.tick_ts - this.timed_attacks.list[4].ts) < 1 then
							this.timed_attacks.list[4].ts = store.tick_ts - this.timed_attacks.list[4].cooldown + 1
						end

						goto label_1340_1
					end
				end
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

		::label_1340_1::

		coroutine.yield()
	end
end

local function fx_hero_spider_ultimate_spawn_update(this, store)
	U.y_animation_play(this, "in", nil, store.tick_ts)
	U.animation_start_default(this, "loop", false, store.tick_ts, true)
	U.y_wait_unconditional(store, 0.5)
	U.animation_start_default(this, "out", nil, store.tick_ts)
	S:queue(this.spawn_sound)

	local fx = E:create_entity(this.spawn_fx_decal)

	fx.pos:copy(this.pos)

	fx.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(fx)

	local e = E:create_entity(this.spider)

	e.pos = V.vclone(this.pos)
	e.nav_rally.center = V.vclone(this.nav_rally)
	e.nav_rally.pos = V.vclone(e.pos)
	e.reinforcement.squad_id = this.squad_id

	simulation:queue_insert_entity(e)

	while not U.animation_finished_default(this) do
		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

local function fx_hero_spider_teleport_approach_update(this, store)
	U.y_animation_play(this, "in", nil, store.tick_ts)
	U.animation_start(this, "loop", nil, store.tick_ts, true, 1, true)

	while not this.leave do
		coroutine.yield()
	end

	U.y_animation_play(this, "run", nil, store.tick_ts)
	simulation:queue_remove_entity(this)
end

local function controller_hero_spider_ultimate_update(this, store)
	local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true, NF_POWER_3)

	if #nodes < 1 then
		log.error("controller_hero_spider_ultimate: could not find valid node")
		simulation:queue_remove_entity(this)

		return
	end

	local x, y = this.pos.x, this.pos.y
	local spawn_formations = {{V.v(x, y)}, {V.v(x + 12, y - 12), V.v(x - 12, y + 12)}, {V.v(x + 14, y - 12), V.v(x - 14, y - 12), V.v(x, y + 12)}, {V.v(x + 12, y - 12), V.v(x - 12, y + 12), V.v(x - 16, y - 12), V.v(x + 16, y + 12)}, {V.v(x, y), V.v(x + 14, y - 17), V.v(x - 14, y + 17), V.v(x - 22, y - 13), V.v(x + 22, y + 13)}}

	if this.spawn_amount > #spawn_formations then
		this.spawn_amount = #spawn_formations
	end

	local spawn_positions = spawn_formations[this.spawn_amount]

	if this.spawn_fx then
		for _, pos in pairs(spawn_positions) do
			local fx = E:create_entity(this.spawn_fx)

			fx.pos:copy(pos)

			fx.render.sprites[1].ts = store.tick_ts
			fx.nav_rally = V.v(x, y)
			fx.squad_id = this.id

			simulation:queue_insert_entity(fx)
			U.y_wait_unconditional(store, U.frandom(0, 0.2))
		end

		U.y_wait_unconditional(store, 0.4)
		S:queue(this.spawn_sound)
		U.y_wait_unconditional(store, 0.4)
	end

	simulation:queue_remove_entity(this)
end

tt = RT("ps_hero_spider_basic_attack_trail")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "hero_spider_05_trail_run"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 12
tt.particle_system.track_rotation = true
tt.particle_system.particle_lifetime = {fts(18), fts(18)}
tt = RT("fx_hero_spider_ranged_hit", "fx")
tt.render.sprites[1].name = "hero_spider_05_hitfx_run"
tt = RT("fx_hero_spider_area_attack", "fx")
tt.render.sprites[1].name = "hero_spider_05_stomp_run"
tt.render.sprites[1].z = Z_DECALS
tt = RT("fx_hero_spider_teleport_fx", "decal_timed")
tt.render.sprites[1].name = "hero_spider_05_hole_run"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "hero_spider_05_dirt_explosion_teleport"
tt.render.sprites[2].loop = false
tt.render.sprites[2].sort_y_offset = -10
tt.render.sprites[2].scale = vv(1.5)
tt = RT("fx_hero_spider_teleport_approach", "fx")

AC(tt, "main_script")

tt.main_script.update = fx_hero_spider_teleport_approach_update
tt.render.sprites[1].prefix = "hero_spider_05_hole"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].z = Z_DECALS
tt = RT("fx_hero_spider_teleport_explosion", "decal_timed")
tt.render.sprites[1].name = "hero_spider_05_dirt_explosion_spawn"
tt.render.sprites[1].sort_y_offset = -10
tt.render.sprites[1].scale = vv(1.5)
tt = RT("fx_hero_spider_ultimate_spawn_decal", "decal_timed")
tt.render.sprites[1].name = "hero_spider_05_mancha_spider"
tt.render.sprites[1].z = Z_DECALS
tt = RT("fx_hero_spider_ultimate_spawn", "decal_scripted")
tt.main_script.update = fx_hero_spider_ultimate_spawn_update
tt.spawn_fx_decal = "fx_hero_spider_ultimate_spawn_decal"
tt.spider = "soldier_hero_spider_ultimate"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].prefix = "hero_spider_05_spider_in"
tt.render.sprites[1].loop = false
tt.render.sprites[1].sort_y_offset = -5
tt = RT("hero_spider", "hero")

AC(tt, "melee", "ranged", "teleport", "timed_attacks")

tt.hero.level_stats.armor = {0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1}
tt.hero.level_stats.magic_armor = {0.34, 0.38, 0.42, 0.46, 0.5, 0.54, 0.58, 0.62, 0.66, 0.7}
tt.hero.level_stats.hp_max = {245, 259, 273, 286, 300, 313, 327, 341, 354, 368}
tt.hero.level_stats.melee_damage_max = {12, 14, 16, 18, 20, 23, 25, 27, 29, 33}
tt.hero.level_stats.melee_damage_min = {10, 11, 13, 15, 17, 18, 20, 23, 24, 26}
tt.hero.level_stats.ranged_damage_max = {22, 24, 27, 30, 34, 37, 40, 44, 48, 52}
tt.hero.level_stats.ranged_damage_min = {12, 13, 15, 16, 18, 19, 22, 24, 26, 28}
tt.hero.level_stats.melee_dot_damage_min = {2, 2, 2, 3, 3, 3, 4, 4, 4, 5}
tt.hero.level_stats.melee_dot_damage_max = {2, 2, 2, 3, 3, 3, 4, 4, 4, 5}
tt.hero.skills.instakill_melee = CC("hero_skill")
tt.hero.skills.instakill_melee.cooldown = {5, 4, 3}
tt.hero.skills.instakill_melee.life_threshold = {1000, 1500, 2000}
tt.hero.skills.instakill_melee.xp_gain = {160, 320, 480}
tt.hero.skills.instakill_melee.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.area_attack = CC("hero_skill")
tt.hero.skills.area_attack.cooldown = {18, 16, 14}
tt.hero.skills.area_attack.damage_type = DAMAGE_PHYSICAL
tt.hero.skills.area_attack.damage_radius = 85
tt.hero.skills.area_attack.damage_min = {25, 50, 75}
tt.hero.skills.area_attack.damage_max = {50, 75, 100}
tt.hero.skills.area_attack.stun_time = {90, 120, 150}
tt.hero.skills.area_attack.xp_gain = {144, 272, 384}
tt.hero.skills.area_attack.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.tunneling = CC("hero_skill")
tt.hero.skills.tunneling.damage_type = DAMAGE_PHYSICAL
tt.hero.skills.tunneling.damage_radius = 85
tt.hero.skills.tunneling.damage_min = {30, 45, 60}
tt.hero.skills.tunneling.damage_max = {40, 70, 100}
tt.hero.skills.tunneling.xp_gain = {56, 56, 56}
tt.hero.skills.tunneling.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.supreme_hunter = CC("hero_skill")
tt.hero.skills.supreme_hunter.cooldown = {25, 25, 25}
tt.hero.skills.supreme_hunter.damage_max = {168, 336, 504}
tt.hero.skills.supreme_hunter.damage_min = {112, 224, 336}
tt.hero.skills.supreme_hunter.xp_gain = {200, 400, 600}
tt.hero.skills.supreme_hunter.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.cooldown = {28, 28, 28, 28}
tt.hero.skills.ultimate.duration = {5, 7, 8, 10}
tt.hero.skills.ultimate.spawn_amount = {2, 3, 4, 5}
tt.hero.skills.ultimate.hp = {150, 150, 150, 150}
tt.hero.skills.ultimate.damage_min = {8, 8, 8, 8}
tt.hero.skills.ultimate.damage_max = {12, 12, 12, 12}
tt.hero.skills.ultimate.controller_name = "controller_hero_spider_ultimate"
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.ultimate = {
	ts = 0,
	cooldown = 28
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = v(0, 85)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_MEDIUM
tt.hero.fn_level_up = hero_spider_level_up
tt.info.hero_portrait = "kr5_hero_portraits_0017"
tt.info.portrait = "kr5_info_portraits_heroes_0017"
tt.main_script.update = hero_spider_update
tt.motion.max_speed = 90
tt.regen.cooldown = 1
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_spider_05_hero"
tt.render.sprites[1].draw_order = DO_HEROES
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].min_cooldown = 3
tt.timed_attacks.list[1].animation = "kill"
tt.timed_attacks.list[1].shoot_time = fts(15)
tt.timed_attacks.list[1].enemy_move_offset = v(10, 40)
tt.timed_attacks.list[1].mod = "mod_hero_spider_skill_instakill_melee"
tt.timed_attacks.list[1].sound = "HeroRobotUppercutCast"
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].animation = "ability1"
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].cast_time = fts(37)
tt.timed_attacks.list[2].damage_type = DAMAGE_PHYSICAL
tt.timed_attacks.list[2].damage_radius = 85
tt.timed_attacks.list[2].damage_max = {50, 75, 100}
tt.timed_attacks.list[2].damage_min = {25, 50, 75}
tt.timed_attacks.list[2].min_targets = 2
tt.timed_attacks.list[2].mod = "mod_hero_spider_area_attack_stun"
tt.timed_attacks.list[2].vis_bans_trigger = bor(F_FLYING)
tt.timed_attacks.list[2].vis_bans_damage = bor(F_FLYING)
tt.timed_attacks.list[2].sound = "HeroSpiderAreaDamage"
tt.timed_attacks.list[2].min_cooldown = 5
tt.timed_attacks.list[2].hit_decal = "fx_hero_spider_area_attack"
tt.timed_attacks.list[3] = CC("custom_attack")
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].damage_type = DAMAGE_PHYSICAL
tt.timed_attacks.list[3].damage_radius = 85
tt.timed_attacks.list[3].damage_max = {40, 70, 100}
tt.timed_attacks.list[3].damage_min = {30, 45, 60}
tt.timed_attacks.list[3].min_targets = 1
tt.timed_attacks.list[3].vis_bans_trigger = bor(F_FLYING)
tt.timed_attacks.list[3].vis_bans_damage = bor(F_FLYING)
tt.timed_attacks.list[3].hit_decal = "fx_hero_spider_teleport_explosion"
tt.timed_attacks.list[4] = CC("custom_attack")
tt.timed_attacks.list[4].animations = {"hunter_in", "hunter", "hunter_out"}
tt.timed_attacks.list[4].sound_supreme = "HeroSpiderSupremeHunter"
tt.timed_attacks.list[4].disabled = true
tt.timed_attacks.list[4].vis_flags = bor(F_RANGED, F_BLOCK)
tt.timed_attacks.list[4].vis_bans = bor(F_FLYING, F_BOSS)
tt.timed_attacks.list[4].max_range = 9999
tt.timed_attacks.list[4].min_range = 0
tt.timed_attacks.list[4].node_margin = 10
tt.timed_attacks.list[4].damage_type = DAMAGE_RUDE
tt.timed_attacks.list[4].mod = "mod_hero_spider_supreme_poison"
tt.sound_events.change_rally_point = "HeroSpiderTaunt"
tt.sound_events.death = "HeroSpiderDeath"
tt.sound_events.respawn = "HeroSpiderTauntIntro"
tt.sound_events.hero_room_select = "HeroSpiderTauntSelect"
tt.teleport.min_distance = 180
tt.teleport.sound_in = "HeroSpiderTunnelingIn"
tt.teleport.sound_out = "HeroSpiderTunnelingOut"
tt.teleport.sound_appear = "HeroSpiderTunnelingAppear"
tt.teleport.animations = {"teleport_in", "teleport_out"}
tt.teleport.delay = 0.4
tt.teleport.duration = 0.35
tt.teleport.fx_in = "fx_hero_spider_teleport_fx"
tt.teleport.fx_out = "fx_hero_spider_teleport_fx"
tt.soldier.melee_slot_offset = v(35, 0)
tt.unit.hit_offset = v(0, 23)
tt.unit.mod_offset = v(0, 23)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.ui.click_rect = r(-35, -5, 61, 75)
tt.melee.range = 75
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].shared_cooldown = 1
tt.melee.attacks[1].hit_time = fts(18)
tt.melee.attacks[1].sound = "HeroSpiderBasicAttack"
tt.melee.attacks[1].sound_args = {
	delay = fts(14)
}
tt.melee.attacks[1].xp_gain_factor = 2.36
tt.melee.attacks[1].hit_offset = v(27, 15)
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].basic_attack = true
tt.melee.attacks[1].mod = "mod_hero_spider_melee_dot"
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animation = "spell"
tt.ranged.attacks[1].bullet = "bolt_hero_spider_basic_attack"
tt.ranged.attacks[1].bullet_start_offset = {v(-9, 100), v(9, 100)}
tt.ranged.attacks[1].cooldown = 1.5
tt.ranged.attacks[1].max_range = 160
tt.ranged.attacks[1].min_range = 68
tt.ranged.attacks[1].shoot_time = fts(17)
tt.ranged.attacks[1].vis_bans = bor(F_WATER)
tt.vis.bans = bor(tt.vis.bans, F_POISON)
tt = RT("mod_hero_spider_tunneling_stun", "mod_stun")
tt.modifier.duration = 0.35
tt = RT("controller_hero_spider_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.main_script.update = controller_hero_spider_ultimate_update
tt.spawn_delay = fts(0)
tt.vis_flags = bor(F_RANGED)
tt.vis_bans = bor(F_FLYING)
tt.spider = "soldier_hero_spider_ultimate"
tt.spawn_fx = "fx_hero_spider_ultimate_spawn"
tt.spawn_sound = "HeroSpiderGlobalSpawn"
tt.prediction_nodes = fts(15)
tt.sound_events.insert = "HeroSpiderGlobalCocoons"
tt = RT("mod_hero_spider_stun", "mod_stun")
tt.modifier.duration = 1.3
tt = RT("bolt_hero_spider_basic_attack", "bolt")
tt.render.sprites[1].prefix = "hero_spider_05_projectile"
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.acceleration_factor = 0.1
tt.bullet.align_with_trajectory = true
tt.bullet.hit_fx = "fx_hero_spider_ranged_hit"
tt.bullet.xp_gain_factor = 1.5
tt.sound_events.insert = "HeroSpiderAttackRanged"
tt.bullet.particles_name = "ps_hero_spider_basic_attack_trail"
tt = RT("mod_hero_spider_area_attack_stun", "mod_stun")
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt.modifier.vis_bans = bor(F_BOSS, F_FLYING)
tt = RT("mod_hero_spider_skill_instakill_melee", "modifier")

AC(tt, "dps", "render")

tt.modifier.duration = fts(2)
tt.main_script.insert = mod_hero_spider_skill_instakill_melee_insert
tt.main_script.update = mod_hero_spider_skill_instakill_melee_update
tt.heal_factor = 0.4
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].prefix = "hero_spider_05_instakill"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].draw_order = DO_MOD_FX
tt = RT("mod_hero_spider_melee_dot", "modifier")

AC(tt, "dps", "render", "tween")

tt.dps.damage_min = nil
tt.dps.damage_max = nil
tt.dps.damage_type = DAMAGE_POISON
tt.dps.damage_every = 0.25
tt.modifier.duration = 1.5
tt.modifier.use_mod_offset = false
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt.render.sprites[1].prefix = "hero_spider_05_modifier"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].z = Z_EFFECTS
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}, {tt.modifier.duration - fts(10), 255}, {tt.modifier.duration, 0}}
tt = RT("mod_hero_spider_supreme_poison", "mod_hero_spider_melee_dot")
tt.tween = nil
tt.damage_min_config = {8, 12, 16}
tt.damage_max_config = {8, 12, 16}
tt.dps.damage_min = 8
tt.dps.damage_max = 8
tt.modifier.duration = 1e9
