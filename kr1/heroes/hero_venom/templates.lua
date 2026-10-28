local scripts = require("scripts")
local E = require("entity_db")
local GR = require("grid_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local bit = require("bit")
local HU = require("hero_utils")
local signal = require("lib.hump.signal")
local band = bit.band
local bor = bit.bor
local find_target_at_critical_moment = HU.find_target_at_critical_moment
local fts = U.fts
local level_up_basic = HU.level_up_basic
local queue_damage = U.queue_damage
local ready_to_attack = U.ready_to_attack
local ready_to_use_skill = HU.ready_to_use_skill
local tpos = U.tpos
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local tt

local function bullet_hero_venom_ranged_tentacle_insert(this, store)
	if not this.bullet.mods then
		this.bullet.mods = {"mod_bullet_hero_venom_ranged_tentacle_stun"}
	else
		table.insert(this.bullet.mods, "mod_bullet_hero_venom_ranged_tentacle_stun")
	end

	return true
end

local function hero_venom_level_up(this, store, initial)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
	this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

	upgrade_skill(this, "ranged_tentacle", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]

		local b = E:get_template(a.bullet)

		b.bullet.damage_min = s.damage_min[s.level]
		b.bullet.damage_max = s.damage_max[s.level]

		local m = E:get_template(b.bullet.mods[1])

		m.dps.damage_min = s.bleed_damage_min[s.level]
		m.dps.damage_max = s.bleed_damage_max[s.level]
		m.dps.damage_every = s.bleed_every[s.level]
		m.modifier.duration = s.bleed_duration[s.level]
	end)
	upgrade_skill(this, "inner_beast", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]

		local damage_min = ls.melee_damage_min[hl] * s.damage_factor[s.level]
		local damage_max = ls.melee_damage_max[hl] * s.damage_factor[s.level]

		this.melee.attacks[3].damage_min = damage_min
		this.melee.attacks[3].damage_max = damage_max
		this.melee.attacks[4].damage_min = damage_min
		this.melee.attacks[4].damage_max = damage_max
		this.melee.attacks[5].damage_min = damage_min
		this.melee.attacks[5].damage_max = damage_max
	end)
	upgrade_skill(this, "floor_spikes", function(this, s)
		local a = this.timed_attacks.list[3]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]
		a.spikes = s.spikes[s.level]

		local sp = E:get_template(a.spike_template[1])

		sp.damage_min = s.damage_min[s.level]
		sp.damage_max = s.damage_max[s.level]

		local sp = E:get_template(a.spike_template[2])

		sp.damage_min = s.damage_min[s.level]
		sp.damage_max = s.damage_max[s.level]
	end)
	upgrade_skill(this, "eat_enemy", function(this, s)
		local a = this.timed_attacks.list[4]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]
		a.regen = s.regen[s.level] * this.health.hp_max
		a.damage = s.damage[s.level]
	end)

	local s = this.hero.skills.eat_enemy

	if s.level > 0 then
		this.timed_attacks.list[4].regen = s.regen[s.level] * this.health.hp_max
	end

	upgrade_skill(this, "ultimate", function(this, s)
		local uc = E:get_template(s.controller_name)

		this.ultimate.cooldown = s.cooldown[s.level]
		this.ultimate.disabled = nil

		local aura = E:get_template(uc.aura)

		aura.end_damage_min = s.damage_min[s.level]
		aura.end_damage_max = s.damage_max[s.level]
		aura.aura.duration = s.duration[s.level]
	end)
	update_hp(this)
end

local function hero_venom_update(this, store)
	local h = this.health
	local a, skill, brk, sta
	local ranged_tentacle_attack = this.timed_attacks.list[1]
	local inner_beast_attack = this.timed_attacks.list[2]
	local floor_spikes_attack = this.timed_attacks.list[3]
	local eat_enemy_attack = this.timed_attacks.list[4]
	local last_ts = store.tick_ts
	local base_speed = this.motion.max_speed

	this.is_transformed = false
	this.melee._range = this.melee.range

	local function play_level_up_animation()
		if this.is_transformed then
			local fx = E:create_entity(this.beast.lvl_up_fx)

			fx.pos:copy(this.pos)

			for i = 1, #fx.render.sprites do
				fx.render.sprites[i].ts = store.tick_ts
			end

			simulation:queue_insert_entity(fx)
		else
			U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
		end
	end

	local function y_transform_in()
		local a = inner_beast_attack
		local start_ts = store.tick_ts

		this.health.immune_to = F_ALL

		S:queue(a.sound_in, {
			delay = fts(10)
		})
		SU.insert_unit_cooldown_buff(store.tick_ts, this, 0.5)
		U.y_animation_play(this, a.animation_in, nil, store.tick_ts)
		SU.remove_unit_cooldown_buff(store.tick_ts, this, 0.5)

		a.ts = start_ts
		last_ts = start_ts

		SU.hero_gain_xp_from_skill(this, skill)

		this.melee.attacks[1].disabled = true
		this.melee.attacks[2].disabled = true
		this.melee.attacks[3].disabled = false
		this.melee.attacks[4].disabled = false
		this.melee.attacks[5].disabled = false
		eat_enemy_attack.hp_trigger = eat_enemy_attack.hp_trigger_normal * 1.5
		eat_enemy_attack.disabled = true
		this._bar_offset = V.vclone(this.health_bar.offset)
		this._bar_type = this.health_bar.type
		this._click_rect = table.deepclone(this.ui.click_rect)
		this._hit_mod_offset = V.vclone(this.unit.hit_offset)

		U.change_health_bar_offset_run_time(this.health_bar, this.beast.health_bar_offset.y)

		this.health_bar.type = this.beast.health_bar_type
		this.ui.click_rect = table.deepclone(this.beast.click_rect)
		this.unit.hit_offset = V.vclone(this.beast.hit_mod_offset)
		this.unit.mod_offset = V.vclone(this.beast.hit_mod_offset)
		this.render.sprites[1].prefix = "hero_venom_hero_beast"
		this.unit.size = UNIT_SIZE_MEDIUM
		this.is_transformed = true
		this.health.immune_to = 0
	end

	local function y_transform_out()
		this.health.immune_to = F_ALL

		local a = inner_beast_attack

		S:queue(a.sound_out, {
			delay = fts(10)
		})
		SU.insert_unit_cooldown_buff(store.tick_ts, this, 0.5)
		U.y_animation_play(this, a.animation_out, nil, store.tick_ts)
		SU.remove_unit_cooldown_buff(store.tick_ts, this, 0.5)

		this.melee.attacks[1].disabled = false
		this.melee.attacks[2].disabled = false
		this.melee.attacks[3].disabled = true
		this.melee.attacks[4].disabled = true
		this.melee.attacks[5].disabled = true
		eat_enemy_attack.disabled = false

		U.change_health_bar_offset_run_time(this.health_bar, this._bar_offset.y)

		this.health_bar.type = this._bar_type
		this.ui.click_rect = table.deepclone(this._click_rect)
		this.unit.hit_offset = V.vclone(this._hit_mod_offset)
		this.unit.mod_offset = V.vclone(this._hit_mod_offset)
		this.render.sprites[1].prefix = "hero_venom_hero"
		this.unit.size = UNIT_SIZE_SMALL
		this.is_transformed = false
		this.health.immune_to = 0
	end

	this.health_bar.hidden = false

	play_level_up_animation()

	while true do
		if h.dead then
			if this.is_transformed then
				y_transform_out()
			end

			local d = E:create_entity(this.death_decal)

			d.pos.x, d.pos.y = this.pos.x, this.pos.y
			d.hero_venom = this

			simulation:queue_insert_entity(d)
			SU.y_hero_death_and_respawn(store, this)
			U.update_max_speed(this, base_speed)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				local r = this.nav_rally
				local tw = this.slimewalk
				local force_slimewalk = false

				for _, p in pairs(this.nav_grid.waypoints) do
					if GR:cell_is(p.x, p.y, bor(TERRAIN_WATER, TERRAIN_SHALLOW, TERRAIN_NOWALK)) then
						force_slimewalk = true

						break
					end
				end

				if not this.is_transformed and (force_slimewalk or V.dist2(this.pos.x, this.pos.y, r.pos.x, r.pos.y) > tw.min_distance * tw.min_distance) then
					r.new = false

					U.unblock_target(store, this)
					U.bans_add(this.vis, F_ALL)

					this.health.immune_to = F_ALL

					U.speed_inc_self(this, tw.extra_speed)

					this.unit.marker_hidden = true
					this.health_bar.hidden = true

					S:queue(this.sound_events.change_rally_point)
					S:queue(this.slimewalk.sound)

					local an, af = U.animation_name_facing_point(this, tw.animations[1], r.pos)

					U.y_animation_play(this, an, af, store.tick_ts)

					::label_294_0::

					local dest = r.pos
					local n = this.nav_grid
					local an, af = U.animation_name_facing_point(this, tw.animations[2], r.pos)

					U.animation_start(this, an, af, store.tick_ts, true, 1, true)

					while not V.veq(this.pos, dest) do
						local w = table.remove(n.waypoints, 1) or dest

						U.set_destination(this, w)

						local runs = this.render.sprites[1].runs - 1

						while not this.motion.arrived do
							if r.new then
								r.new = false

								goto label_294_0
							end

							U.walk_off__accel__unsnapped(this, store.tick_length)
							coroutine.yield()

							this.motion.speed.x, this.motion.speed.y = 0, 0

							if this.render.sprites[1].runs ~= runs then
								local slimewalk_decal = E:create_entity(this.slimewalk.decal)

								slimewalk_decal.ts = store.tick_ts
								slimewalk_decal.pos = V.vclone(this.pos)

								U.animation_start_default(slimewalk_decal, "idle", false, store.tick_ts)
								simulation:queue_insert_entity(slimewalk_decal)

								runs = this.render.sprites[1].runs
							end
						end
					end

					S:stop(this.slimewalk.sound)
					SU.hide_modifiers(store, this, true)
					U.y_animation_play(this, tw.animations[3], nil, store.tick_ts)
					SU.show_modifiers(store, this, true)
					U.speed_dec_self(this, tw.extra_speed)
					U.bans_remove(this.vis, F_ALL)

					this.health.immune_to = 0
					this.unit.marker_hidden = nil
					this.health_bar.hidden = nil
				elseif SU.y_hero_new_rally(store, this) then
					goto label_294_2
				end
			end

			if SU.hero_level_up(store, this) then
				play_level_up_animation()
			end

			skill = this.hero.skills.eat_enemy
			a = eat_enemy_attack

			if (not ready_to_use_skill(eat_enemy_attack, store, this.unit.cooldown_factor) or this.soldier.target_id == nil) or not this.motion.arrived then
			-- block empty
			else
				local target = store.entities[this.soldier.target_id]

				if not target or target.health.dead or band(target.vis.flags, F_BOSS) ~= 0 or band(target.vis.bans, F_INSTAKILL) ~= 0 then
				-- block empty
				else
					local function do_eat_enemy_attack()
						local start_ts = store.tick_ts
						local an, af = U.animation_name_facing_point(this, a.animation, target.pos)

						U.animation_start_default(this, an, af, store.tick_ts, false)
						S:queue(eat_enemy_attack.sound, eat_enemy_attack.sound_args)

						while store.tick_ts - start_ts < eat_enemy_attack.hit_time do
							coroutine.yield()
						end

						S:queue(eat_enemy_attack.sound_hit, eat_enemy_attack.sound_hit_args)

						eat_enemy_attack.ts = start_ts - eat_enemy_attack.cooldown

						local center = target.pos
						local eat_targets = table.filter(store.enemies, function(k, v)
							return not v.health.dead and band(v.vis.flags, F_BOSS) == 0 and band(v.vis.bans, F_INSTAKILL) == 0 and U.is_inside_ellipse(v.pos, center, eat_enemy_attack.radius)
						end)

						if eat_targets then
							for _, eat_target in ipairs(eat_targets) do
								local d = E.assign_damage(DAMAGE_TRUE, 0, this.id, eat_target.id)

								if eat_target.health.hp <= eat_target.health.hp_max * eat_enemy_attack.hp_trigger then
									d.damage_type = DAMAGE_EAT
									d.value = 1
									eat_enemy_attack.ts = eat_enemy_attack.ts + (target.health.hp - 100) / target.health.hp_max * eat_enemy_attack.cooldown

									U.heal(this, eat_enemy_attack.regen)
								else
									d.damage_type = DAMAGE_RUDE
									d.value = (eat_enemy_attack.damage + this.unit.damage_buff) * this.unit.damage_factor
								end

								queue_damage(store, d)
								SU.hero_gain_xp_from_skill(this, skill)
							end

							if eat_enemy_attack.ts > start_ts then
								eat_enemy_attack.ts = start_ts
							end

							if this.health.hp > 0 and this.health.dead then
								this.health.dead = false
							end

							local mod = E:create_entity(eat_enemy_attack.mod_regen)

							mod.modifier.target_id = this.id

							simulation:queue_insert_entity(mod)
						end

						while not U.animation_finished_default(this) do
							if this.health.dead or this.unit.is_stunned then
								break
							end

							coroutine.yield()
						end

						S:stop(eat_enemy_attack.sound)

						eat_enemy_attack.hp_trigger = eat_enemy_attack.hp_trigger_normal
					end

					-- 此时必为人形
					if target.health.hp <= target.health.hp_max * eat_enemy_attack.hp_trigger then
						do_eat_enemy_attack()
					elseif ready_to_use_skill(inner_beast_attack, store, this.unit.cooldown_factor) and target.health.hp <= target.health.hp_max * eat_enemy_attack.hp_trigger_normal * 1.5 then
						inner_beast_attack.ts = store.tick_ts - 0.5 * inner_beast_attack.cooldown
						eat_enemy_attack.hp_trigger = eat_enemy_attack.hp_trigger_normal * 1.5

						do_eat_enemy_attack()
					end
				end
			end

			if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
				local target = find_target_at_critical_moment(this, 160, F_RANGED, F_FLYING, nil, false, true)

				if target and U.has_valid_rally_node_nearby(target.pos) then
					play_level_up_animation()
					S:queue(this.sound_events.change_rally_point)

					local e = E:create_entity(this.hero.skills.ultimate.controller_name)

					e.pos.x, e.pos.y = target.pos.x, target.pos.y
					e.damage_factor = this.unit.damage_factor
					e.level = this.hero.skills.ultimate.level

					simulation:queue_insert_entity(e)

					this.ultimate.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
				else
					this.ultimate.ts = this.ultimate.ts + 1
				end
			end

			a = inner_beast_attack
			skill = this.hero.skills.inner_beast

			if not this.is_transformed and ready_to_use_skill(a, store, this.unit.cooldown_factor) and this.health.hp <= this.health.hp_max * skill.trigger_hp and store.tick_ts - last_ts > a.min_cooldown and this.soldier.target_id and store.entities[this.soldier.target_id] and not store.entities[this.soldier.target_id].health.dead and this.motion.arrived then
				y_transform_in()
			end

			if this.is_transformed then
				if this.soldier.target_id and store.tick_ts - a.ts > skill.duration * 0.5 then
					local target = store.entities[this.soldier.target_id]

					if target and target.health.hp <= target.health.hp_max * eat_enemy_attack.hp_trigger and ready_to_attack(eat_enemy_attack, store) then
						a.ts = a.ts - a.cooldown * 0.5

						y_transform_out()

						goto label_294_2
					end
				elseif store.tick_ts - a.ts > skill.duration then
					y_transform_out()
				end
			end

			skill = this.hero.skills.floor_spikes
			a = floor_spikes_attack

			if not this.is_transformed and ready_to_use_skill(a, store, this.unit.cooldown_factor) and store.tick_ts - last_ts > a.min_cooldown then
				local enemies = U.find_enemies_between_range_filter_off(this.pos, a.range_trigger_min, a.range_trigger_max, a.vis_flags, a.vis_bans)

				if not enemies or #enemies < a.min_targets then
					a.ts = a.ts + fts(10)

					goto label_294_1
				end

				local targets = table.filter(enemies, function(k, v)
					local vpi = v.nav_path.pi
					local nearest = P:nearest_nodes(this.pos.x, this.pos.y, {vpi})
					local _, _, ni = unpack(nearest[1])

					return ni > v.nav_path.ni
				end)

				if not targets or #targets < a.min_targets then
					a.ts = a.ts + fts(10)

					goto label_294_1
				end

				local path = targets[1].nav_path.pi
				local start_ts = store.tick_ts

				S:queue(a.sound_in, {
					delay = fts(10)
				})

				local flip = targets[1].pos.x < this.pos.x

				U.animation_start_default(this, a.animation_in, flip, store.tick_ts, false)

				if SU.y_soldier_wait(store, this, a.cast_time) then
					goto label_294_2
				end

				a.ts = start_ts
				last_ts = start_ts

				SU.hero_gain_xp_from_skill(this, skill)

				local nodes_between_spikes = 2
				local spikes = {}

				local function spawn_spike(pi, spi, ni, spike_id)
					local pos = P:node_pos(pi, spi, ni)

					pos.x = pos.x + math.random(-4, 4)
					pos.y = pos.y + math.random(-5, 5)

					local s = E:create_entity(a.spike_template[math.random(1, #a.spike_template)])

					s.pos = V.vclone(pos)

					simulation:queue_insert_entity(s)

					spikes[spike_id] = s
				end

				local nearest = P:nearest_nodes(this.pos.x, this.pos.y, {path})

				if #nearest > 0 then
					local pi, _, ni = unpack(nearest[1])
					local initial_offset = 1

					ni = ni - initial_offset

					local count = a.spikes / 3
					local ni_aux
					local spike_id = 1

					for i = 1, count do
						ni_aux = ni - i * nodes_between_spikes

						if P:is_node_valid(pi, ni_aux) then
							spawn_spike(pi, 1, ni_aux, spike_id)

							spike_id = spike_id + 1

							U.y_wait_unconditional(store, fts(1))
						end

						ni_aux = ni - i * (nodes_between_spikes + 1)

						if P:is_node_valid(pi, ni_aux) then
							spawn_spike(pi, 2, ni_aux, spike_id)

							spike_id = spike_id + 1

							U.y_wait_unconditional(store, fts(1))
							spawn_spike(pi, 3, ni_aux, spike_id)

							spike_id = spike_id + 1

							U.y_wait_unconditional(store, fts(1))
						end
					end
				end

				U.animation_start_default(this, a.animation_idle, nil, store.tick_ts, true)
				U.y_wait_unconditional(store, fts(10))
				S:queue(a.sound_out)

				for i = #spikes, 1, -1 do
					spikes[i].hide = true

					U.y_wait_unconditional(store, fts(1))
				end

				U.animation_start_default(this, a.animation_out, nil, store.tick_ts, false)
				SU.y_hero_animation_wait(this)

				goto label_294_2
			end

			skill = this.hero.skills.ranged_tentacle
			a = ranged_tentacle_attack

			if not this.is_transformed and ready_to_use_skill(a, store, this.unit.cooldown_factor) and store.tick_ts - last_ts > a.min_cooldown then
				local target = U.find_foremost_enemy_between_range_filter_off(tpos(this), a.min_range, a.max_range, a.node_prediction, a.vis_flags, a.vis_bans)

				if not target then
					a.ts = a.ts + fts(10)
				else
					local enemy_id = target.id
					local enemy_pos = target.pos

					last_ts = store.tick_ts

					local an, af = U.animation_name_facing_point(this, a.animation, enemy_pos)

					U.animation_start_default(this, an, af, store.tick_ts, false)
					S:queue(a.sound)

					local start_offset = V.vclone(a.bullet_start_offset)

					if af then
						start_offset.x = start_offset.x * -1
					end

					U.y_wait_unconditional(store, a.shoot_time)

					if SU.soldier_interrupted(this) then
					-- block empty
					else
						local target, _, pred_pos = U.find_foremost_enemy_between_range_filter_off(tpos(this), a.min_range, a.max_range, a.shoot_time, a.vis_flags, a.vis_bans)

						if target then
							enemy_id = target.id
							enemy_pos = target.pos
						end

						if not target then
						-- block empty
						else
							a.ts = last_ts

							local b = E:create_entity(a.bullet)

							b.pos.x, b.pos.y = this.pos.x + start_offset.x, this.pos.y + start_offset.y

							b.bullet.from:copy(b.pos)
							b.bullet.to:copy(pred_pos)

							b.bullet.to.x = b.bullet.to.x + target.unit.hit_offset.x
							b.bullet.to.y = b.bullet.to.y + target.unit.hit_offset.y
							b.bullet.target_id = enemy_id
							b.bullet.source_id = this.id
							b.bullet.level = this.hero.level
							b.bullet.damage_factor = this.unit.damage_factor

							simulation:queue_insert_entity(b)
							SU.hero_gain_xp_from_skill(this, skill)
							U.y_animation_wait_default(this)

							goto label_294_2
						end
					end
				end
			end

			::label_294_1::

			if not this.soldier.target_id and ready_to_use_skill(eat_enemy_attack, store, this.unit.cooldown_factor) then
				local targets = U.find_enemies_in_range_filter_on(this.nav_rally.center, this.melee.range, F_BLOCK, F_CLIFF, function(e)
					return band(GR:cell_type(e.pos.x, e.pos.y), TERRAIN_NOWALK) == 0 and e.health.hp < e.health.hp_max * eat_enemy_attack.hp_trigger
				end)

				if targets then
					local target = table.find_best(targets, function(v)
						return v.health.hp
					end)

					U.block_enemy(store, this, target)

					this.melee.range = 0
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)
			this.melee.range = this.melee._range

			if sta == A_DONE then
				if this.is_transformed then
					U.heal(this, this.health.hp_max * this.beast.regen_health)

					if this.health.dead and this.health.hp > 0 then
						this.health.dead = false
					end
				end
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

		::label_294_2::

		coroutine.yield()
	end
end

local function hero_venom_ultimate_update(this, store)
	local nearest = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)

	if #nearest > 0 then
		local pi, _, ni = unpack(nearest[1])

		if P:is_node_valid(pi, ni) then
			S:queue(this.sound)

			local aura = E:create_entity(this.aura)

			aura.aura.damage_factor = this.damage_factor
			aura.aura.source_id = this.id
			aura.aura.ts = store.tick_ts

			local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)

			if #nodes < 1 then
				return nil
			end

			local pi, _, ni = unpack(nodes[1])
			local npos = P:node_pos(pi, 1, ni)

			aura.pos = npos
			aura.pos_pi = pi
			aura.pos_ni = ni

			S:queue(this.sound)
			simulation:queue_insert_entity(aura)
		end
	end

	simulation:queue_remove_entity(this)
end

local function aura_hero_venom_ultimate_update(this, store)
	local first_hit_ts
	local last_hit_ts = 0
	local cycles_count = 0
	local victims_count = 0

	if this.aura.track_source and this.aura.source_id then
		local te = store.entities[this.aura.source_id]

		if te and te.pos then
			this.pos = te.pos
		end
	end

	U.animation_start_default(this, "in", false, store.tick_ts, false)
	U.y_wait_unconditional(store, this.slow_delay)

	last_hit_ts = store.tick_ts - this.aura.cycle_time

	if this.aura.apply_delay then
		last_hit_ts = last_hit_ts + this.aura.apply_delay
	end

	while true do
		if this.render.sprites[1].name == "in" and U.animation_finished_default(this) then
			U.animation_start_default(this, "idle", false, store.tick_ts, true)
		end

		if this.interrupt then
			last_hit_ts = 1e+99
		end

		if this.aura.cycles and cycles_count >= this.aura.cycles or this.aura.duration >= 0 and store.tick_ts - this.aura.ts > this.actual_duration + this.slow_delay then
			U.animation_start_default(this, "attack", false, store.tick_ts, false)
			S:queue(this.sound_attack)
			U.y_wait_unconditional(store, fts(10))

			local targets = table.filter(store.enemies, function(k, v)
				return not v.health.dead and band(v.vis.flags, this.aura.vis_bans) == 0 and band(v.vis.bans, this.aura.vis_flags) == 0 and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius) and (not this.aura.allowed_templates or table.contains(this.aura.allowed_templates, v.template_name)) and (not this.aura.excluded_templates or not table.contains(this.aura.excluded_templates, v.template_name)) and (not this.aura.filter_source or this.aura.source_id ~= v.id)
			end)

			for i, target in ipairs(targets) do
				local d = E.assign_damage(this.end_damage_type, math.random(this.end_damage_min, this.end_damage_max) * this.aura.damage_factor, this.id, target.id)

				queue_damage(store, d)
			end

			U.y_animation_wait_default(this)

			break
		end

		if this.aura.stop_on_max_count and this.aura.max_count and victims_count >= this.aura.max_count then
			break
		end

		if this.aura.track_source and this.aura.source_id then
			local te = store.entities[this.aura.source_id]

			if not te or te.health and te.health.dead and not this.aura.track_dead then
				break
			end
		end

		if this.aura.source_vis_flags and this.aura.source_id then
			local te = store.entities[this.aura.source_id]

			if te and te.vis and band(te.vis.bans, this.aura.source_vis_flags) ~= 0 then
				goto label_305_0
			end
		end

		if this.aura.requires_alive_source and this.aura.source_id then
			local te = store.entities[this.aura.source_id]

			if te and te.health and te.health.dead then
				goto label_305_0
			end
		end

		if not (store.tick_ts - last_hit_ts >= this.aura.cycle_time) or this.aura.apply_duration and first_hit_ts and store.tick_ts - first_hit_ts > this.aura.apply_duration then
		-- block empty
		else
			if this.render and this.aura.cast_resets_sprite_id then
				this.render.sprites[this.aura.cast_resets_sprite_id].ts = store.tick_ts
			end

			first_hit_ts = first_hit_ts or store.tick_ts
			last_hit_ts = store.tick_ts
			cycles_count = cycles_count + 1

			local targets = table.filter(store.enemies, function(k, v)
				return not v.health.dead and band(v.vis.flags, this.aura.vis_bans) == 0 and band(v.vis.bans, this.aura.vis_flags) == 0 and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius) and (not this.aura.allowed_templates or table.contains(this.aura.allowed_templates, v.template_name)) and (not this.aura.excluded_templates or not table.contains(this.aura.excluded_templates, v.template_name)) and (not this.aura.filter_source or this.aura.source_id ~= v.id)
			end)

			for i, target in ipairs(targets) do
				if this.aura.targets_per_cycle and i > this.aura.targets_per_cycle then
					break
				end

				if this.aura.max_count and victims_count >= this.aura.max_count then
					break
				end

				local mods = this.aura.mods or {this.aura.mod}

				for _, mod_name in ipairs(mods) do
					local new_mod = E:create_entity(mod_name)

					new_mod.modifier.level = this.aura.level
					new_mod.modifier.target_id = target.id
					new_mod.modifier.source_id = this.id

					if this.aura.hide_source_fx and target.id == this.aura.source_id then
						new_mod.render = nil
					end

					simulation:queue_insert_entity(new_mod)

					victims_count = victims_count + 1
				end
			end
		end

		::label_305_0::

		coroutine.yield()
	end

	signal.emit("aura-apply-mod-victims", this, victims_count)
	simulation:queue_remove_entity(this)
end

local function decal_hero_venom_death_update(this, store)
	U.y_wait_unconditional(store, fts(19))

	this.render.sprites[1].hidden = false

	U.animation_start_default(this, "idle", false, store.tick_ts, false)

	while true do
		if this.tween.disabled and this.hero_venom.render.sprites[1].name == "respawn" then
			this.tween.disabled = false
			this.tween.remove = true
		end

		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

local function decal_hero_venom_spike_update(this, store)
	U.y_animation_play(this, "in", false, store.tick_ts)
	U.animation_start_default(this, "idle", false, store.tick_ts, true)

	local enemies = U.find_enemies_in_range_filter_off(this.pos, this.damage_radius, this.vis_flags, this.vis_bans)

	if enemies and #enemies > 0 then
		for i = 1, #enemies do
			local d = E.assign_damage(this.damage_type, math.random(this.damage_min, this.damage_max), this.id, enemies[i].id)

			queue_damage(store, d)
		end
	end

	while true do
		if this.hide then
			U.y_animation_play(this, "out", false, store.tick_ts)

			this.render.sprites[1].hidden = true

			break
		end

		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

local function mod_hero_venom_eat_enemy_regen_update(this, store)
	local m = this.modifier

	this.modifier.ts = store.tick_ts

	local target = store.entities[m.target_id]

	if not target or not target.pos then
		simulation:queue_remove_entity(this)

		return
	end

	this.pos = target.pos

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead or m.duration >= 0 and store.tick_ts - m.ts > m.duration or m.last_node and target.nav_path.ni > m.last_node then
			simulation:queue_remove_entity(this)

			return
		end

		if this.render and target.unit then
			for _, s in ipairs(this.render.sprites) do
				local flip_sign = 1

				if target.render then
					flip_sign = target.render.sprites[1].flip_x and -1 or 1
				end

				s.offset.x, s.offset.y = target.render.sprites[1].offset.x * flip_sign, target.render.sprites[1].offset.y
			end
		end

		coroutine.yield()
	end
end

tt = RT("decal_hero_venom_spike_a", "decal_scripted")
tt.render.sprites[1].prefix = "hero_venom_spike_a"
tt.render.sprites[1].name = "in"
tt.main_script.update = decal_hero_venom_spike_update
tt.damage_type = DAMAGE_TRUE
tt.damage_radius = 35
tt.vis_flags = bor(F_AREA)
tt.vis_bans = bor(F_FLYING)
tt = RT("hero_venom", "hero")

AC(tt, "melee", "timed_attacks")

tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.hp_max = {234, 266, 299, 341, 364, 396, 429, 461, 494, 520}
tt.hero.level_stats.melee_damage_min = {10, 11, 13, 15, 16, 18, 19, 20, 23, 26}
tt.hero.level_stats.melee_damage_max = {15, 18, 20, 22, 24, 27, 29, 31, 33, 36}
tt.hero.skills.ranged_tentacle = CC("hero_skill")
tt.hero.skills.ranged_tentacle.cooldown = {10, 9, 8}
tt.hero.skills.ranged_tentacle.damage_min = {30, 60, 90}
tt.hero.skills.ranged_tentacle.damage_max = {30, 60, 90}
tt.hero.skills.ranged_tentacle.bleed_damage_min = {3, 4, 5}
tt.hero.skills.ranged_tentacle.bleed_damage_max = {3, 4, 5}
tt.hero.skills.ranged_tentacle.bleed_every = {0.25, 0.25, 0.25}
tt.hero.skills.ranged_tentacle.bleed_duration = {4, 4, 4}
tt.hero.skills.ranged_tentacle.xp_gain = {80, 160, 240}
tt.hero.skills.ranged_tentacle.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.inner_beast = CC("hero_skill")
tt.hero.skills.inner_beast.cooldown = {35, 35, 35}
tt.hero.skills.inner_beast.duration = 10
tt.hero.skills.inner_beast.damage_factor = {1.25, 1.5, 1.75}
tt.hero.skills.inner_beast.trigger_hp = 0.5
tt.hero.skills.inner_beast.xp_gain = {0, 0, 0}
tt.hero.skills.inner_beast.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.floor_spikes = CC("hero_skill")
tt.hero.skills.floor_spikes.cooldown = {30, 30, 30}
tt.hero.skills.floor_spikes.damage_type = DAMAGE_TRUE
tt.hero.skills.floor_spikes.damage_radius = 35
tt.hero.skills.floor_spikes.damage_min = {20, 40, 60}
tt.hero.skills.floor_spikes.damage_max = {20, 40, 60}
tt.hero.skills.floor_spikes.spikes = {15, 15, 15}
tt.hero.skills.floor_spikes.xp_gain = {240, 480, 720}
tt.hero.skills.floor_spikes.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.eat_enemy = CC("hero_skill")
tt.hero.skills.eat_enemy.hp_trigger = 0.3
tt.hero.skills.eat_enemy.regen = {0.1, 0.15, 0.2}
tt.hero.skills.eat_enemy.cooldown = {55, 50, 45}
tt.hero.skills.eat_enemy.xp_gain = {100, 200, 300}
tt.hero.skills.eat_enemy.damage = {40, 50, 60}
tt.hero.skills.eat_enemy.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.controller_name = "controller_hero_venom_ultimate"
tt.hero.skills.ultimate.cooldown = {50, 50, 50, 50}
tt.hero.skills.ultimate.duration = {3, 3, 3, 3}
tt.hero.skills.ultimate.damage_min = {190, 250, 315, 370}
tt.hero.skills.ultimate.damage_max = {190, 250, 315, 370}
tt.hero.skills.ultimate.xp_gain_factor = 40
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.fn_level_up = hero_venom_level_up
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, 40)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health.hp_max = 234
tt.info.hero_portrait = "kr5_hero_portraits_0004"
tt.info.portrait = "kr5_info_portraits_heroes_0004"
tt.main_script.update = hero_venom_update
tt.motion.max_speed = 75
tt.regen.cooldown = 1
tt.slimewalk = {}
tt.slimewalk.min_distance = 72
tt.slimewalk.extra_speed = 95
tt.slimewalk.animations = {"run_in", "run", "run_out"}
tt.slimewalk.decal = "decal_hero_venom_slimewalk"
tt.beast = {}
tt.beast.health_bar_offset = vec_2(0, 55)
tt.beast.health_bar_type = HEALTH_BAR_SIZE_MEDIUM
tt.beast.click_rect = r(-30, -5, 60, 60)
tt.beast.hit_mod_offset = vec_2(0, 25)
tt.beast.regen_health = 0.1
tt.beast.lvl_up_fx = "fx_hero_venom_beast_lvl_up"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_venom_hero"
tt.render.sprites[1].draw_order = DO_HEROES
tt.soldier.melee_slot_offset = vec_2(20, 0)
tt.sound_events.change_rally_point = "HeroVenomTaunt"
tt.sound_events.death = "HeroVenomDeath"
tt.sound_events.respawn = "HeroVenomTauntIntro"
tt.sound_events.hero_room_select = "HeroVenomTauntSelect"
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.mod_offset = vec_2(0, 14)
tt.melee.range = 72
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].animation = "attack_1"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].shared_cooldown = 1
tt.melee.attacks[1].hit_time = fts(16)
tt.melee.attacks[1].hit_fx = "fx_hero_venom_melee_attack_hit"
tt.melee.attacks[1].hit_offset = vec_2(45, 15)
tt.melee.attacks[1].sound = "HeroVenomBasicAttack"
tt.melee.attacks[1].sound_args = {
	delay = fts(14)
}
tt.melee.attacks[1].xp_gain_factor = 1.55
tt.melee.attacks[1].basic_attack = true
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack_2"
tt.melee.attacks[2].chance = 0.2
tt.melee.attacks[2].hit_time = fts(20)
tt.melee.attacks[3] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[3].animation = "attack_1"
tt.melee.attacks[3].cooldown = 2.1
tt.melee.attacks[3].shared_cooldown = nil
tt.melee.attacks[3].hit_time = fts(10)
tt.melee.attacks[3].disabled = true
tt.melee.attacks[3].xp_gain_factor = 1
tt.melee.attacks[3].damage_type = DAMAGE_RUDE
tt.melee.attacks[4] = table.deepclone(tt.melee.attacks[3])
tt.melee.attacks[4].animation = "attack_2"
tt.melee.attacks[4].hit_time = fts(8)
tt.melee.attacks[5] = table.deepclone(tt.melee.attacks[3])
tt.melee.attacks[5].animation = "attack_3"
tt.melee.attacks[5].hit_time = fts(8)
tt.timed_attacks.list[1] = CC("bullet_attack")
tt.timed_attacks.list[1].animation = "ranged_skill"
tt.timed_attacks.list[1].min_range = 50
tt.timed_attacks.list[1].max_range = 150
tt.timed_attacks.list[1].bullet = "bullet_hero_venom_ranged_tentacle"
tt.timed_attacks.list[1].shoot_time = fts(4)
tt.timed_attacks.list[1].bullet_start_offset = vec_2(8, 15)
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].sound = "HeroVenomHeartseekerCast"
tt.timed_attacks.list[1].min_cooldown = 3
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].animation_in = "beast_in"
tt.timed_attacks.list[2].animation_out = "out"
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[2].sound_in = "HeroVenomInnerBeastCast"
tt.timed_attacks.list[2].sound_out = "HeroVenomInnerBeastOut"
tt.timed_attacks.list[2].min_cooldown = 3
tt.timed_attacks.list[3] = CC("custom_attack")
tt.timed_attacks.list[3].animation_in = "spikes_in"
tt.timed_attacks.list[3].animation_idle = "spikes_idle"
tt.timed_attacks.list[3].animation_out = "spikes_out"
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].cast_time = fts(8)
tt.timed_attacks.list[3].damage_type = DAMAGE_TRUE
tt.timed_attacks.list[3].range_trigger_min = 20
tt.timed_attacks.list[3].range_trigger_max = 100
tt.timed_attacks.list[3].spikes = {15, 15, 15}
tt.timed_attacks.list[3].min_targets = 3
tt.timed_attacks.list[3].vis_bans = bor(F_FLYING, F_CLIFF)
tt.timed_attacks.list[3].vis_flags = bor(F_AREA)
tt.timed_attacks.list[3].sound_in = "HeroVenomDeadlySpikesCast"
tt.timed_attacks.list[3].sound_out = "HeroVenomDeadlySpikesOut"
tt.timed_attacks.list[3].min_cooldown = 3
tt.timed_attacks.list[3].spike_template = {"decal_hero_venom_spike_a", "decal_hero_venom_spike_b"}
tt.timed_attacks.list[4] = CC("custom_attack")
tt.timed_attacks.list[4].animation = "instakill"
tt.timed_attacks.list[4].cooldown = 55
tt.timed_attacks.list[4].hp_trigger = 0.3
-- tt.melee.attacks[6].hit_time = fts(23)
tt.timed_attacks.list[4].hit_time = fts(12)
tt.timed_attacks.list[4].sound_hit_args = {
	-- delay = fts(14)
	delay = fts(7)
}
tt.timed_attacks.list[4].xp_from_skill = "eat_enemy"
tt.timed_attacks.list[4].disabled = true
tt.timed_attacks.list[4].hp_trigger_normal = 0.3
tt.timed_attacks.list[4].mod_regen = "mod_hero_venom_eat_enemy_regen"
tt.timed_attacks.list[4].sound = "HeroVenomRenewFleshCast"
tt.timed_attacks.list[4].sound_args = {
	-- delay = fts(10)
	delay = fts(5)
}
tt.timed_attacks.list[4].radius = 65
tt.timed_attacks.list[4].regen = 0.1 * tt.health.hp_max
tt.ui.click_rect = r(-27, -5, 54, 50)
tt.death_decal = "decal_hero_venom_death"
tt.ultimate = {
	ts = 0,
	cooldown = 40,
	disabled = true
}
tt.vis.bans = bor(tt.vis.bans, F_POISON)
tt = RT("bullet_hero_venom_ranged_tentacle", "bullet")
tt.bullet.damage_type = DAMAGE_RUDE
tt.bullet.damage_min = nil
tt.bullet.damage_max = nil
tt.bullet.hit_time = fts(4)
tt.bullet.mods = {"mod_bullet_hero_venom_ranged_tentacle_bleed", "mod_bullet_hero_venom_ranged_tentacle_stun"}
tt.bullet.hit_fx = "fx_hero_venom_melee_attack_hit"
tt.image_width = 179
tt.dist_offset = 70
tt.main_script.insert = bullet_hero_venom_ranged_tentacle_insert
tt.main_script.update = scripts.ray5_simple.update
tt.render.sprites[1].name = "hero_venom_ranged_skill_tentacle_idle"
tt.render.sprites[1].loop = false
tt.track_target = false
tt.ray_duration = fts(20)
tt = RT("aura_hero_venom_ultimate", "aura")

AC(tt, "render")

tt.aura.mod = "mod_hero_venom_ultimate_slow"
tt.aura.radius = 70
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.aura.cycle_time = fts(5)
tt.aura.duration = nil
tt.render.sprites[1].prefix = "hero_venom_ultimate"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = false
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = aura_hero_venom_ultimate_update
tt.slow_delay = 0.5
tt.end_damage_type = DAMAGE_TRUE
tt.sound_attack = "HeroVenomRenewCreepingDeathSpikes"
tt = RT("mod_bullet_hero_venom_ranged_tentacle_bleed", "mod_blood")
tt.dps.damage_min = nil
tt.dps.damage_max = nil
tt.dps.damage_inc = 0
tt.dps.damage_every = nil
tt.dps.fx_every = fts(20)
tt.modifier.duration = nil
tt = RT("mod_bullet_hero_venom_ranged_tentacle_stun", "mod_stun")
tt.modifier.duration = fts(7)
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt = RT("mod_hero_venom_eat_enemy_regen", "modifier")

AC(tt, "render", "tween")

tt.modifier.duration = fts(43)
tt.main_script.insert = scripts.mod_track_target.insert
tt.main_script.update = mod_hero_venom_eat_enemy_regen_update
tt.render.sprites[1].prefix = "hero_venom_heal_fx_back"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "hero_venom_heal_fx_front"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].z = Z_DECALS
tt.tween.props[1].keys = {{0, 255}, {tt.modifier.duration - fts(10), 255}, {tt.modifier.duration, 0}}
tt = RT("mod_hero_venom_ultimate_slow", "mod_slow")
tt.slow.factor = 0.5
tt = RT("controller_hero_venom_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.aura = "aura_hero_venom_ultimate"
tt.main_script.update = hero_venom_ultimate_update
tt.sound = "HeroVenomRenewCreepingDeathCast"
tt = RT("fx_hero_venom_melee_attack_hit", "fx")
tt.render.sprites[1].name = "hero_venom_hit_fx_idle"
tt.render.sprites[1].z = Z_BULLETS + 1
tt = RT("fx_hero_venom_beast_lvl_up", "fx")
tt.render.sprites[1].name = "hero_venom_levelup_fx_idle"
tt = RT("decal_hero_venom_slimewalk", "decal_timed")
tt.render.sprites[1].prefix = "hero_venom_run_particle"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].fps = 15
tt.timed.duration = fts(20)
tt = RT("decal_hero_venom_spike_b", "decal_hero_venom_spike_a")
tt.render.sprites[1].prefix = "hero_venom_spike_b"
tt = RT("decal_hero_venom_death", "decal_scripted")

AC(tt, "tween")

tt.render.sprites[1].prefix = "hero_venom_death_decal"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_DECALS
tt.main_script.update = decal_hero_venom_death_update
tt.tween.disabled = true
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 0}, {1, 255}}
tt.tween.remove = false
