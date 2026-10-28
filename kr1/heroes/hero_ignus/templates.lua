local bit = require("bit")
local E = require("entity_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")

require("lib.klua.table")
require("all.constants")

local bor = bit.bor
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local update_hp = HU.update_hp
local queue_damage = U.queue_damage

local function aura_ignus_particles_update(this, store)
	local source = store.entities[this.aura.source_id]

	if not source then
		simulation:queue_remove_entity(this)

		return
	end

	this.pos = source.pos

	local particles = {}
	local s = source.render.sprites[1]
	local h = source.health
	local flip = s.flip_x

	for i, o in ipairs(this.particle_offsets) do
		local ps = E:create_entity(this.particles_name)

		ps.particle_system.track_id = source.id
		ps.particle_system.track_offset = o
		ps.particle_system.ts_offset = fts(2 * i)

		simulation:queue_insert_entity(ps)
		table.insert(particles, ps)
	end

	::label_209_0::

	while h.dead or not table.contains(this.emit_states, s.name) do
		coroutine.yield()
	end

	for i, p in pairs(particles) do
		p.particle_system.emit = true
	end

	while table.contains(this.emit_states, s.name) and not h.dead do
		if s.flip_x ~= flip then
			flip = s.flip_x

			for i, p in pairs(particles) do
				p.particle_system.emit_offset = s.flip_x and this.flip_offset or nil
			end
		end

		coroutine.yield()
	end

	for _, p in pairs(particles) do
		p.particle_system.emit = false
	end

	goto label_209_0
end

local function aura_ignus_surge_of_flame_update(this, store)
	local source = store.entities[this.aura.source_id]

	if not source then
		simulation:queue_remove_entity(this)

		return
	end

	this.pos = source.pos

	local s = source.render.sprites[1]
	local ps = E:create_entity(this.particles_name)

	ps.particle_system.track_id = source.id
	ps.particle_system.emit = true

	simulation:queue_insert_entity(ps)

	local a = this.aura
	local ts = 0
	local targets

	while s.name == this.damage_state do
		if store.tick_ts - ts + 1e-09 <= a.cycle_time then
		-- block empty
		else
			targets = U.find_enemies_in_range_filter_off(this.pos, a.damage_radius, a.damage_flags or 0, a.damage_bans or 0) or {}
			ts = store.tick_ts

			for _, t in ipairs(targets) do
				local d = E.assign_damage(a.damage_type, math.random(a.damage_min, a.damage_max), this.id, t.id)

				queue_damage(store, d)

				local fx = E:create_entity(a.hit_fx)

				fx.pos:copy(t.pos)

				if t.unit and t.unit.mod_offset then
					fx.pos.x, fx.pos.y = fx.pos.x + t.unit.mod_offset.x, fx.pos.y + t.unit.mod_offset.y
				end

				for i = 1, #fx.render.sprites do
					fx.render.sprites[i].ts = store.tick_ts
				end

				simulation:queue_insert_entity(fx)
			end
		end

		coroutine.yield()
	end

	ps.particle_system.emit = false
	simulation:queue_remove_entity(ps)
	simulation:queue_remove_entity(this)
end

local function hero_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
	this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

	if hl == 2 then
		this.melee.attacks[2].mod = "mod_ignus_burn_1"
		this.melee.attacks[2].chance = 0.4
	elseif hl == 5 then
		this.melee.attacks[2].mod = "mod_ignus_burn_2"
		this.melee.attacks[2].chance = 0.5
	elseif hl == 8 then
		this.melee.attacks[2].mod = "mod_ignus_burn_3"
		this.melee.attacks[2].chance = 0.6
	end

	upgrade_skill(this, "flaming_frenzy", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.damage_min = s.damage_min[s.level]
		a.damage_max = s.damage_max[s.level]
	end)
	upgrade_skill(this, "surge_of_flame", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil

		local aura = E:get_template("aura_ignus_surge_of_flame")

		aura.aura.damage_min = s.damage_min[s.level]
		aura.aura.damage_max = s.damage_max[s.level]
	end)

	update_hp(this)
end

local function hero_update(this, store)
	local h = this.health
	local a, skill, brk, sta

	U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)

	this.health_bar.hidden = false
	local aura = E:create_entity(this.particles_aura)

	aura.aura.source_id = this.id

	simulation:queue_insert_entity(aura)

	local ps = E:create_entity(this.run_particles_name)

	ps.particle_system.track_id = this.id
	ps.particle_system.emit = false

	simulation:queue_insert_entity(ps)

	local function apply_fire(target)
		local m = E:create_entity(this.melee.attacks[2].mod)

		m.modifier.source_id = this.id
		m.modifier.target_id = target.id
		m.modifier.damage_factor = this.unit.damage_factor

		simulation:queue_insert_entity(m)
	end

	while true do
		ps.particle_system.emit = false

		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				ps.particle_system.emit = true

				if SU.y_hero_new_rally(store, this) then
					goto label_71_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or h.dead then
			-- block empty
			else
				a = this.timed_attacks.list[2]
				skill = this.hero.skills.surge_of_flame

				if sta ~= A_NO_TARGET and not a.disabled and store.tick_ts - a.ts >= a.cooldown then
					local function find_surge_target()
						return U.find_first_enemy(store, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans, function(e)
							if not e.nav_path or not e.nav_path.pi then
								return false
							end

							local ps, pe = P:get_visible_start_node(e.nav_path.pi), P:get_visible_end_node(e.nav_path.pi)

							return (#e.enemy.blockers or 0) == 0 and e.nav_path.ni > ps + a.nodes_margin and e.nav_path.ni < pe - a.nodes_margin
						end)
					end

					local target = find_surge_target()

					if not target then
					-- block empty
					else
						local bans_added = false
						local function surge(target)
							U.unblock_target(store, this)
							U.block_enemy(store, this, target)
							SU.hero_gain_xp_from_skill(this, skill)

							local slot_pos = U.melee_slot_position(this, target, 1)

							if not bans_added then
								U.bans_add(this.vis, F_ALL)
								bans_added = true
							end
							this.health.ignore_damage = true

							U.speed_mul(this, a.speed_factor)
							U.set_destination(this, slot_pos)
							S:queue(a.sound)
							U.y_animation_play(this, a.animations[1], nil, store.tick_ts)

							local aura = E:create_entity(a.aura)

							aura.aura.source_id = this.id
							aura.aura.damage_factor = this.unit.damage_factor

							simulation:queue_insert_entity(aura)

							while not this.motion.arrived do
								U.walk(this, store.tick_length, nil, true)
								coroutine.yield()
							end

							if math.random() < this.melee.attacks[2].chance then
								apply_fire(target)
							end

							this.nav_rally.center = V.vclone(this.pos)
							this.nav_rally.pos = V.vclone(this.pos)

							U.speed_div(this, a.speed_factor)
						end

						local function surge_end()
							S:queue(a.sound_end)
							U.y_animation_play(this, a.animations[2], nil, store.tick_ts)

							a.ts = store.tick_ts
							if bans_added then
								U.bans_remove(this.vis, F_ALL)
								bans_added = false
							end
							this.health.ignore_damage = nil
						end

						local last_target_id = this.soldier.target_id

						surge(target)

						target = store.entities[last_target_id]

						if target and not target.health.dead then
							surge(target)
						end

						while target and target.health.dead do
							target = find_surge_target()

							if not target then
								break
							end

							surge(target)
						end

						surge_end()

						goto label_71_0
					end
				end

				a = this.timed_attacks.list[1]
				skill = this.hero.skills.flaming_frenzy

				if sta ~= A_NO_TARGET and not a.disabled and store.tick_ts - a.ts >= a.cooldown then
					if U.frandom(0, 1) >= a.chance then
						goto label_71_0
					end

					local targets = U.find_enemies_in_range_filter_off(this.pos, a.max_range, a.vis_flags, a.vis_bans)

					if not targets then
					-- block empty
					else
						local start_ts = store.tick_ts
						local flip = targets[1].pos.x < this.pos.x

						U.animation_start_default(this, a.animation, flip, store.tick_ts)
						S:queue(a.sound)

						if U.y_wait_conditional(store, a.cast_time, function()
							return SU.hero_interrupted(this)
						end) then
							goto label_71_0
						end

						SU.hero_gain_xp_from_skill(this, skill)

						a.ts = start_ts
						targets = U.find_enemies_in_range_filter_off(this.pos, a.max_range, a.vis_flags, a.vis_bans)

						if targets then
							for _, t in ipairs(targets) do
								local fx = E:create_entity(a.hit_fx)

								fx.pos:copy(t.pos)

								if t.unit and t.unit.mod_offset then
									fx.pos.x, fx.pos.y = fx.pos.x + t.unit.mod_offset.x, fx.pos.y + t.unit.mod_offset.y
								end

								for i = 1, #fx.render.sprites do
									fx.render.sprites[i].ts = store.tick_ts
								end

								simulation:queue_insert_entity(fx)

								local d = E.assign_damage(a.damage_type, (math.random(a.damage_min, a.damage_max) + this.unit.damage_buff) * this.unit.damage_factor, this.id, t.id)

								queue_damage(store, d)

								if math.random() < this.melee.attacks[2].chance then
									apply_fire(t)
								end
							end
						end

						U.heal(this, this.health.hp_max * a.heal_factor)

						local e = E:create_entity(a.decal)

						e.pos = V.vclone(this.pos)
						e.render.sprites[1].ts = store.tick_ts

						simulation:queue_insert_entity(e)

						if not U.y_animation_wait_default(this) then
						-- block empty
						end

						goto label_71_0
					end
				end

				if sta ~= A_NO_TARGET then
				-- block empty
				elseif SU.soldier_go_back_step(store, this) then
				-- block empty
				else
					SU.soldier_idle(store, this)
					SU.soldier_regen(store, this)
				end
			end
		end

		::label_71_0::

		coroutine.yield()
	end
end

local anchor_x, anchor_y = 0.5, 0.1
local tt

tt = RT("ps_hero_ignus_idle", "particle_system")
tt.particle_system.name = "ps_hero_ignus_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {0.5, 0.5}
tt.particle_system.alphas = {255, 255}
tt.particle_system.emit_direction = d2r(90)
tt.particle_system.emit_speed = {30, 30}
tt.particle_system.emission_rate = 2.5
tt.particle_system.z = Z_OBJECTS

tt = RT("ps_ignus_run")
AC(tt, "pos", "particle_system")
tt.particle_system.alphas = {255, 200, 0}
tt.particle_system.anchor = vec_2(0.5, 0.1)
tt.particle_system.animated = true
tt.particle_system.emission_rate = 10
tt.particle_system.loop = false
tt.particle_system.z = Z_DECALS + 1
tt.particle_system.name = "ps_hero_ignus_run"
tt.particle_system.particle_lifetime = {0.6, 0.8}

tt = RT("ps_hero_ignus_smoke", "ps_power_fireball")
tt.particle_system.scales_x = {2, 3}
tt.particle_system.scales_y = {2, 3}
tt.particle_system.emission_rate = 30
tt.particle_system.emit_offset = vec_2(0, 17)
tt.particle_system.name = "ps_hero_ignus_smoke"
tt.particle_system.sort_y_offset = -16
tt.particle_system.z = Z_OBJECTS

tt = RT("fx_ignus_burn", "fx")
tt.render.sprites[1].prefix = "fx_burn"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {"small", "big", "big"}

tt = RT("decal_ignus_flaming", "decal_timed")
tt.render.sprites[1].name = "decal_ignus_flaming"
tt.render.sprites[1].z = Z_DECALS

tt = RT("aura_ignus_idle", "aura")
tt.particles_name = "ps_hero_ignus_idle"
tt.emit_states = {"idle", "attack"}
tt.main_script.update = aura_ignus_particles_update
tt.particle_offsets = {vec_2(-17, 16), vec_2(-12, 27), vec_2(4, 37), vec_2(2, 35), vec_2(12, 22), vec_2(14, 13)}
tt.flip_offset = vec_2(3, 0)

tt = RT("hero_ignus", "hero")
AC(tt, "melee", "timed_attacks")
tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.hp_max = {400, 430, 460, 490, 520, 550, 580, 620, 660, 700}
tt.hero.level_stats.melee_damage_max = {30, 33, 35, 38, 40, 43, 45, 48, 50, 53}
tt.hero.level_stats.melee_damage_min = {18, 20, 21, 23, 24, 26, 27, 29, 30, 32}
tt.hero.skills.flaming_frenzy = CC("hero_skill")
tt.hero.skills.flaming_frenzy.damage_max = {30, 50, 70}
tt.hero.skills.flaming_frenzy.damage_min = {20, 40, 60}
tt.hero.skills.flaming_frenzy.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.hero.skills.flaming_frenzy.xp_gain = {100, 200, 300}
tt.hero.skills.surge_of_flame = CC("hero_skill")
tt.hero.skills.surge_of_flame.damage_max = {10, 15, 30}
tt.hero.skills.surge_of_flame.damage_min = {5, 10, 20}
tt.hero.skills.surge_of_flame.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.surge_of_flame.xp_gain = {40, 80, 120}
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, 41)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_level_up
tt.hero.tombstone_show_time = fts(60)
tt.info.hero_portrait = "hero_portraits_0006"
tt.info.portrait = "info_portraits_heroes_0006"
tt.main_script.update = hero_update
tt.motion.max_speed = 4 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "hero_ignus"
tt.run_particles_name = "ps_ignus_run"
tt.particles_aura = "aura_ignus_idle"
tt.soldier.melee_slot_offset = vec_2(6, 0)
tt.sound_events.change_rally_point = "HeroRainOfFireTaunt"
tt.sound_events.death = "HeroRainOfFireDeath"
tt.sound_events.hero_room_select = "HeroRainOfFireTauntSelect"
tt.sound_events.insert = "HeroRainOfFireTauntIntro"
tt.sound_events.respawn = "HeroRainOfFireTauntIntro"
tt.unit.hit_offset = vec_2(0, 19)
tt.unit.mod_offset = vec_2(0, 20)
tt.vis.bans = bor(tt.vis.bans, F_BURN, F_POISON)
tt.melee.range = 70
tt.melee.attacks[1].cooldown = 0.8
tt.melee.attacks[1].damage_type = DAMAGE_TRUE
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].xp_gain_factor = 2
tt.melee.attacks[1].sound_hit = "HeroReinforcementHit"
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].chance = 0
-- this attack is unlocked by level up, with mod_ignus_burn attached
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].animation = "flamingFrenzy"
tt.timed_attacks.list[1].cast_time = fts(8)
tt.timed_attacks.list[1].chance = 0.25
tt.timed_attacks.list[1].cooldown = 4 + fts(24)
tt.timed_attacks.list[1].damage_type = DAMAGE_TRUE
tt.timed_attacks.list[1].decal = "decal_ignus_flaming"
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].heal_factor = 0.25
tt.timed_attacks.list[1].hit_fx = "fx_ignus_burn"
tt.timed_attacks.list[1].max_range = 90
tt.timed_attacks.list[1].sound = "HeroRainOfFireArea"
tt.timed_attacks.list[1].vis_bans = bor(F_FRIEND)
tt.timed_attacks.list[1].vis_flags = bor(F_AREA)
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].animations = {"surgeOfFlame", "surgeOfFlame_end"}
tt.timed_attacks.list[2].aura = "aura_ignus_surge_of_flame"
tt.timed_attacks.list[2].cooldown = 3.5
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].nodes_margin = 8
tt.timed_attacks.list[2].min_range = 40
tt.timed_attacks.list[2].max_range = 130
tt.timed_attacks.list[2].speed_factor = 3.3333333333333335
tt.timed_attacks.list[2].sound = "HeroRainOfFireFireball1"
tt.timed_attacks.list[2].sound_end = "HeroRainOfFireFireball2"
tt.timed_attacks.list[2].vis_bans = bor(F_FRIEND)
tt.timed_attacks.list[2].vis_flags = bor(F_ENEMY, F_BLOCK)

tt = RT("aura_ignus_surge_of_flame", "aura")
tt.aura.cycle_time = fts(1)
tt.aura.damage_type = DAMAGE_TRUE
tt.aura.damage_radius = 25
tt.aura.hit_fx = "fx_ignus_burn"
tt.damage_state = "surgeOfFlame"
tt.main_script.update = aura_ignus_surge_of_flame_update
tt.particles_name = "ps_hero_ignus_smoke"

tt = RT("mod_ignus_burn_1", "mod_lava")
tt.dps.damage_min = 5
tt.dps.damage_max = 5
tt.dps.damage_inc = 0
tt.dps.damage_every = fts(11)
tt.modifier.duration = 4
tt.modifier.vis_flags = bor(F_MOD, F_BURN)
tt.render.sprites[1].prefix = "fx_burn"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {"small", "big", "big"}

tt = RT("mod_ignus_burn_2", "mod_lava")
tt.dps.damage_min = 8
tt.dps.damage_max = 8
tt.dps.damage_inc = 0
tt.dps.damage_every = fts(11)
tt.modifier.duration = 5
tt.modifier.vis_flags = bor(F_MOD, F_BURN)
tt.render.sprites[1].prefix = "fx_burn"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {"small", "big", "big"}

tt = RT("mod_ignus_burn_3", "mod_lava")
tt.dps.damage_min = 10
tt.dps.damage_max = 10
tt.dps.damage_inc = 0
tt.dps.damage_every = fts(11)
tt.modifier.duration = 6
tt.modifier.vis_flags = bor(F_MOD, F_BURN)
tt.render.sprites[1].prefix = "fx_burn"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {"small", "big", "big"}

