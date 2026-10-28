local bit = require("bit")
local E = require("entity_db")
local GR = require("grid_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")
local scripts = require("scripts")
local log = require("lib.klua.log"):new("hero_minotaur")

require("lib.klua.table")
require("all.constants")

local band = bit.band
local bnot = bit.bnot
local bor = bit.bor
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local queue_damage = U.queue_damage

local function mod_minotaur_daedalus_insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target then
		return false
	end

	U.bans_add(target.vis, F_ALL)
	SU.stun_inc(target)

	local s = this.render.sprites[1]

	s.prefix = s.prefix .. "_" .. s.size_names[target.unit.size]

	if target.unit.mod_offset then
		s.offset.x, s.offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
	end

	return true
end

local function mod_minotaur_daedalus_remove(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target then
		return true
	end

	SU.stun_dec(target)

	return true
end

local function mod_minotaur_daedalus_update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target then
		simulation:queue_remove_entity(this)

		return
	end

	local fx = E:create_entity("decal_minotaur_daedalus")

	fx.pos:copy(target.pos)

	fx.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(fx)
	U.y_wait_unconditional(store, 0.5)

	local es = E:create_entity("daedalus_enemy_decal")

	es.pos.x, es.pos.y = target.pos.x, target.pos.y
	es.render = U.render_clone(target.render)
	es.tween.ts = store.tick_ts

	simulation:queue_insert_entity(es)
	coroutine.yield()
	U.sprites_hide(target)

	target.health_bar.hidden = true

	U.y_wait_unconditional(store, 0.5)

	target.nav_path.pi = this.dest_pi
	target.nav_path.spi = this.dest_spi
	target.nav_path.ni = this.dest_ni

	local pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni)

	target.pos.x, target.pos.y = pos.x, pos.y
	es.pos = V.vclone(pos)
	this.pos = V.vclone(pos)
	es.tween.reverse = true
	es.tween.ts = store.tick_ts
	fx = E:create_entity("decal_minotaur_daedalus")

	fx.pos:copy(target.pos)

	fx.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(fx)
	U.y_wait_unconditional(store, 0.5)
	simulation:queue_remove_entity(es)
	U.sprites_show(target)

	target.health_bar.hidden = nil

	local s = this.render.sprites[1]

	s.hidden = nil
	s.flip_x = target.render.sprites[1].flip_x
	m.ts = store.tick_ts

	U.bans_remove(target.vis, F_ALL)

	while store.tick_ts - m.ts < m.duration and target and not target.health.dead do
		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

local function hero_level_up(this, store)
	local hl, ls = level_up_basic(this)
	local a = this.melee.attacks[1]

	a.damage_max = ls.damage_max[hl]
	a.damage_min = ls.damage_min[hl]

	upgrade_skill(this, "bullrush", function(this, s)
		local a = this.timed_attacks.list[3]

		a.disabled = nil
		a.damage_min = s.damage_min[s.level]
		a.damage_max = s.damage_max[s.level]
		a.run_damage_min = s.run_damage_min[s.level]
		a.run_damage_max = s.run_damage_max[s.level]

		local m = E:get_template(a.mod)

		m.modifier.duration = s.duration[s.level]
	end)
	upgrade_skill(this, "bloodaxe", function(this, s)
		local a = this.melee.attacks[2]

		a.disabled = nil
		a.damage_max = ls.damage_max[hl] * s.damage_factor[s.level]
		a.damage_min = ls.damage_min[hl] * s.damage_factor[s.level]
	end)
	upgrade_skill(this, "daedalusmaze", function(this, s)
		local a = this.timed_attacks.list[4]

		a.disabled = nil

		local m = E:get_template(a.mod)

		m.modifier.duration = s.duration[s.level]
	end)
	upgrade_skill(this, "roaroffury", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil

		local m = E:get_template(a.mod)

		m.extra_damage = s.extra_damage[s.level]
	end)
	upgrade_skill(this, "doomspin", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.damage_min = s.damage_min[s.level]
		a.damage_max = s.damage_max[s.level]
	end)
	update_hp(this)
end

local function hero_update(this, store)
	local h = this.health
	local a, skill, brk, sta
	local ps = E:create_entity("ps_minotaur_bullrush")

	ps.particle_system.track_id = this.id
	ps.particle_system.emit = false

	simulation:queue_insert_entity(ps)

	local function do_rush_damage(target, a, final_hit)
		local dval

		if final_hit then
			dval = (math.random(a.damage_min, a.damage_max) + this.unit.damage_buff) * this.unit.damage_factor
		else
			dval = (math.random(a.run_damage_min, a.run_damage_max) + this.unit.damage_buff) * this.unit.damage_factor
		end

		local d = E.assign_damage(a.damage_type, dval, this.id, target.id)

		queue_damage(store, d)
	end

	local function do_rush_stun(target, a)
		local m = E:create_entity(a.mod)

		m.modifier.target_id = target.id
		m.modifier.source_id = this.id

		simulation:queue_insert_entity(m)
	end

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_437_2
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.doomspin

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local targets = U.find_enemies_between_range_filter_off(this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if not targets or #targets < a.min_count then
					a.ts = a.ts + 0.2
				else
					local target = targets[1]

					S:queue(a.sound)

					local an, af = U.animation_name_facing_point(this, a.animation, target.pos)

					U.animation_start_default(this, an, af, store.tick_ts, false)

					if U.y_wait_conditional(store, a.hit_time, function()
						return SU.hero_interrupted(this)
					end) then
					-- block empty
					else
						a.ts = store.tick_ts

						SU.hero_gain_xp_from_skill(this, skill)

						local heal = 0

						for _, e in ipairs(targets) do
							local d = E.assign_damage(a.damage_type, (math.random(a.damage_min, a.damage_max) + this.unit.damage_buff) * this.unit.damage_factor, this.id, e.id)

							heal = heal + d.value * 0.25

							queue_damage(store, d)
						end

						U.heal(this, heal)

						while not U.animation_finished_default(this) and not SU.hero_interrupted(this) do
							coroutine.yield()
						end

						goto label_437_2
					end
				end
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.roaroffury

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local towers = table.filter(store.towers, function(_, e)
					return e.tower and e.tower.can_be_mod and not e.tower.blocked and not table.contains(a.excluded_templates, e.template_name)
				end)

				if #towers < 1 then
					a.ts = a.ts + 0.2
				else
					S:queue(a.sound)
					U.animation_start_default(this, a.animation, nil, store.tick_ts)

					if U.y_wait_conditional(store, a.shoot_time, function()
						return SU.hero_interrupted(this)
					end) then
					-- block empty
					else
						a.ts = store.tick_ts

						SU.hero_gain_xp_from_skill(this, skill)

						local fx = E:create_entity(a.shoot_fx)

						fx.pos:copy(this.pos)

						fx.render.sprites[1].anchor = V.vclone(this.render.sprites[1].anchor)
						fx.render.sprites[1].ts = store.tick_ts
						fx.render.sprites[1].flip_x = this.render.sprites[1].flip_x

						simulation:queue_insert_entity(fx)

						for _, t in pairs(towers) do
							local m = E:create_entity(a.mod)

							m.modifier.target_id = t.id

							simulation:queue_insert_entity(m)
						end

						while not U.animation_finished_default(this) and not SU.hero_interrupted(this) do
							coroutine.yield()
						end

						fx.render.sprites[1].hidden = true

						goto label_437_2
					end
				end
			end

			a = this.timed_attacks.list[3]
			skill = this.hero.skills.bullrush

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local target = U.find_first_enemy(store, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans, function(e)
					if not e.heading or not e.nav_path then
						return false
					end

					local dist = V.dist(e.pos.x, e.pos.y, this.pos.x, this.pos.y)
					local ftime = dist / (this.motion.real_speed * a.speed_factor)
					local pni = e.nav_path.ni + P:predict_enemy_node_advance(e, ftime)
					local ppos = P:predict_enemy_pos(e, ftime)
					local slot_pos = U.melee_slot_position(this, e, 1)

					return P:nodes_to_goal(e.nav_path.pi, e.nav_path.spi, e.nav_path.ni) > a.nodes_limit and P:is_node_valid(e.nav_path.pi, e.nav_path.ni) and P:is_node_valid(e.nav_path.pi, pni) and GR:cell_is_only(slot_pos.x, slot_pos.y, this.nav_grid.valid_terrains_dest) and GR:cell_is_only(ppos.x, ppos.y, this.nav_grid.valid_terrains_dest) and GR:find_line_waypoints(this.pos, ppos, this.nav_grid.valid_terrains) ~= nil
				end)

				if not target then
					a.ts = a.ts + 0.2

					goto label_437_0
				end

				local damaged_enemies = {}

				U.unblock_target(store, this)

				this.health_bar.hidden = true
				this.health.ignore_damage = true

				U.bans_add(this.vis, F_ALL)
				U.speed_mul_self(this, a.speed_factor)

				local an, af = U.animation_name_facing_point(this, a.animations[1], target.pos)

				U.y_animation_play(this, an, af, store.tick_ts, 1)

				ps.particle_system.emit = true

				local dust = E:create_entity("mod_minotaur_dust")

				dust.modifier.target_id = this.id

				simulation:queue_insert_entity(dust)

				local interrupted = false

				S:queue(a.sound)
				U.animation_start_default(this, a.animations[2], nil, store.tick_ts, true)

				local slot_pos = U.melee_slot_position(this, target, 1)

				U.set_destination(this, slot_pos)

				while not U.walk_off__accel__unsnapped(this, store.tick_length) do
					local targets = U.find_enemies_in_range_filter_on(this.pos, a.stun_range, a.stun_vis_flags, a.stun_vis_bans, function(v)
						return not table.contains(damaged_enemies, v)
					end)

					if targets then
						for _, t in ipairs(targets) do
							table.insert(damaged_enemies, t)
							do_rush_damage(t, a, false)
							do_rush_stun(t, a)
						end
					end

					coroutine.yield()

					slot_pos = U.melee_slot_position(this, target, 1)

					if not GR:cell_is_only(slot_pos.x, slot_pos.y, this.nav_grid.valid_terrains_dest) or not P:is_node_valid(target.nav_path.pi, target.nav_path.ni) then
						log.debug("bullrush interrupted")

						interrupted = true

						break
					end

					U.set_destination(this, slot_pos)
				end

				this.nav_rally.center = V.vclone(this.pos)
				this.nav_rally.pos = V.vclone(this.pos)

				simulation:queue_remove_entity(dust)

				ps.particle_system.emit = false
				an, af = U.animation_name_facing_point(this, a.animations[3], target.pos)

				U.animation_start_default(this, an, af, store.tick_ts, false)
				U.y_wait_unconditional(store, fts(5))

				if not interrupted then
					do_rush_damage(target, a, true)

					if target.health and not target.health.dead and band(target.vis.flags, a.stun_vis_bans) == 0 and band(target.vis.bans, a.stun_vis_flags) == 0 then
						do_rush_stun(target, a)
					end
				end

				this.health_bar.hidden = nil
				this.health.ignore_damage = false

				U.bans_remove(this.vis, F_ALL)
				U.speed_div_self(this, a.speed_factor)

				a.ts = store.tick_ts
				this.timed_attacks.list[1].ts = 0

				SU.hero_gain_xp_from_skill(this, skill)
				U.y_animation_wait_default(this)

				goto label_437_2
			end

			::label_437_0::

			a = this.timed_attacks.list[4]
			skill = this.hero.skills.daedalusmaze

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local nearest_nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, {1, 2, 3}, true, NF_NO_EXIT)

				if #nearest_nodes < 1 then
					a.ts = a.ts + 0.2

					goto label_437_1
				end

				local pi, spi, ni = unpack(nearest_nodes[1])

				ni = ni + a.node_offset

				local n_pos = P:node_pos(pi, spi, ni)

				if not U.is_inside_ellipse(this.pos, n_pos, this.melee.range) or not P:is_node_valid(pi, ni) or P:nodes_to_defend_point(pi, spi, ni) < a.nodes_limit or band(GR:cell_type(n_pos.x, n_pos.y), a.invalid_terrains) ~= 0 then
					a.ts = a.ts + 0.2

					goto label_437_1
				end

				local terrains = P:path_terrain_types(pi)

				terrains = band(terrains, bnot(TERRAIN_CLIFF, TERRAIN_FAERIE))

				local target = U.find_foremost_enemy_between_range_filter_on(this.pos, a.min_range, a.max_range, false, a.vis_flags, a.vis_bans, function(v)
					return (band(bnot(v.enemy.valid_terrains), terrains) == 0) and v.health.hp > this.health.hp * 2
				end)

				if not target then
					a.ts = a.ts + 0.2

					goto label_437_1
				end

				SU.remove_modifiers(store, target)

				local m = E:create_entity(a.mod)

				m.modifier.target_id = target.id
				m.modifier.source_id = this.id
				m.dest_pi = pi
				m.dest_spi = spi
				m.dest_ni = ni

				simulation:queue_insert_entity(m)
				S:queue(a.sound)

				local an, af = U.animation_name_facing_point(this, a.animation, target.pos)

				U.y_animation_play(this, an, af, store.tick_ts, 1)

				a.ts = store.tick_ts
				this.timed_attacks.list[1].ts = 0
				this.timed_attacks.list[2].ts = 0

				SU.hero_gain_xp_from_skill(this, skill)

				goto label_437_2
			end

			::label_437_1::

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

		::label_437_2::

		coroutine.yield()
	end
end

local tt

tt = RT("hero_minotaur", "hero")

AC(tt, "melee", "timed_attacks")

tt.hero.level_stats.hp_max = {325, 350, 375, 400, 425, 450, 475, 500, 525, 550}
tt.hero.level_stats.armor = {0.13, 0.16, 0.19, 0.22, 0.25, 0.28, 0.31, 0.34, 0.37, 0.4}
tt.hero.level_stats.damage_min = {15, 17, 19, 21, 23, 25, 27, 29, 32, 34}
tt.hero.level_stats.damage_max = {27, 31, 35, 39, 43, 47, 51, 55, 59, 62}
tt.hero.skills.bullrush = CC("hero_skill")
tt.hero.skills.bullrush.xp_gain_factor = 30
tt.hero.skills.bullrush.damage_min = {10, 20, 30}
tt.hero.skills.bullrush.damage_max = {30, 60, 90}
tt.hero.skills.bullrush.run_damage_min = {10, 15, 20}
tt.hero.skills.bullrush.run_damage_max = {20, 35, 50}
tt.hero.skills.bullrush.duration = {2, 3, 4}
tt.hero.skills.bullrush.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.bloodaxe = CC("hero_skill")
tt.hero.skills.bloodaxe.damage_factor = {2, 3, 4}
tt.hero.skills.bloodaxe.xp_gain_factor = 25
tt.hero.skills.bloodaxe.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.daedalusmaze = CC("hero_skill")
tt.hero.skills.daedalusmaze.xp_gain_factor = 120
tt.hero.skills.daedalusmaze.duration = {2, 4, 6}
tt.hero.skills.daedalusmaze.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.hero.skills.roaroffury = CC("hero_skill")
tt.hero.skills.roaroffury.extra_damage = {0.25, 0.5, 0.75}
tt.hero.skills.roaroffury.xp_gain_factor = 35
tt.hero.skills.roaroffury.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.doomspin = CC("hero_skill")
tt.hero.skills.doomspin.damage_min = {16, 32, 48}
tt.hero.skills.doomspin.damage_max = {48, 96, 144}
tt.hero.skills.doomspin.xp_gain_factor = 25
tt.hero.skills.doomspin.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.health.armor = nil
tt.health.dead_lifetime = 15
tt.health.hp_max = nil
tt.health_bar.offset = vec_2(0, 56)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_level_up
tt.hero.tombstone_show_time = fts(90)
tt.idle_flip.cooldown = 10
tt.info.hero_portrait = "kr2_hero_portraits_0015"
tt.info.portrait = "kr2_info_portraits_heroes_0015"
tt.main_script.update = hero_update
tt.motion.max_speed = 90
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.2545454545454545
tt.render.sprites[1].prefix = "hero_minotaur"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"running"}
tt.soldier.melee_slot_offset = vec_2(20, 0)
tt.sound_events.change_rally_point = "HeroMinotaurTaunt"
tt.sound_events.death = "HeroMinotaurDeath"
tt.sound_events.respawn = "HeroMinotaurTauntIntro"
tt.sound_events.insert = "HeroMinotaurTauntIntro"
tt.sound_events.hero_room_select = "HeroMinotaurTauntSelect"
tt.unit.hit_offset = vec_2(0, 20)
tt.unit.mod_offset = vec_2(0, 20)
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].hit_time = fts(8)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 3
tt.melee.attacks[2] = CC("melee_attack")
tt.melee.attacks[2].animation = "axe"
tt.melee.attacks[2].chance = 0.1
tt.melee.attacks[2].damage_type = bor(DAMAGE_FX_EXPLODE, DAMAGE_TRUE, DAMAGE_NO_DODGE, DAMAGE_IGNORE_SHIELD)
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].hit_decal = "decal_minotaur_bloodaxe"
tt.melee.attacks[2].hit_offset = vec_2(40, -5)
tt.melee.attacks[2].hit_time = fts(18)
tt.melee.attacks[2].shared_cooldown = true
tt.melee.attacks[2].sound = "HeroMinotaurBloodAxe"
tt.melee.attacks[2].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[2].vis_flags = F_BLOCK
tt.melee.attacks[2].xp_from_skill = "bloodaxe"
tt.melee.range = 64
tt.melee.cooldown = 1.5 - fts(21) + fts(8)
tt.timed_attacks.list[1] = CC("area_attack")
tt.timed_attacks.list[1].animation = "spin"
tt.timed_attacks.list[1].cooldown = 10
tt.timed_attacks.list[1].damage_radius = 75
tt.timed_attacks.list[1].damage_type = DAMAGE_PHYSICAL
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].hit_time = fts(14)
tt.timed_attacks.list[1].max_range = tt.timed_attacks.list[1].damage_radius
tt.timed_attacks.list[1].min_count = 1
tt.timed_attacks.list[1].sound = "HeroMinotaurDoomSpin"
tt.timed_attacks.list[2] = CC("mod_attack")
tt.timed_attacks.list[2].animation = "roar"
tt.timed_attacks.list[2].cooldown = 15
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].excluded_templates = {}
tt.timed_attacks.list[2].mod = "mod_minotaur_roaroffury"
tt.timed_attacks.list[2].sound = "HeroMinotaurRoarOfFury"
tt.timed_attacks.list[2].shoot_time = fts(9)
tt.timed_attacks.list[2].shoot_fx = "fx_minotaur_roarofury_scream"
tt.timed_attacks.list[3] = CC("custom_attack")
tt.timed_attacks.list[3].animations = {"rush_start", "rush_loop", "rush_end"}
tt.timed_attacks.list[3].cooldown = 16
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].damage_type = DAMAGE_RUDE
tt.timed_attacks.list[3].max_range = 350
tt.timed_attacks.list[3].min_range = 150
tt.timed_attacks.list[3].mod = "mod_minotaur_stun"
tt.timed_attacks.list[3].sound = "HeroMinotaurBullRush"
tt.timed_attacks.list[3].speed_factor = 4
tt.timed_attacks.list[3].stun_range = 50
tt.timed_attacks.list[3].stun_vis_bans = bor(F_FLYING, F_CLIFF, F_WATER, F_FRIEND, F_BOSS, F_HERO)
tt.timed_attacks.list[3].stun_vis_flags = bor(F_RANGED, F_STUN)
tt.timed_attacks.list[3].vis_bans = bor(F_FLYING, F_CLIFF, F_WATER, F_FRIEND, F_HERO)
tt.timed_attacks.list[3].vis_flags = bor(F_BLOCK, F_RANGED)
tt.timed_attacks.list[3].nodes_limit = 20
tt.timed_attacks.list[4] = CC("custom_attack")
tt.timed_attacks.list[4].animation = "daedalus"
tt.timed_attacks.list[4].cooldown = 25
tt.timed_attacks.list[4].disabled = true
tt.timed_attacks.list[4].invalid_terrains = bor(TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK)
tt.timed_attacks.list[4].max_range = 9000
tt.timed_attacks.list[4].min_range = 200
tt.timed_attacks.list[4].mod = "mod_minotaur_daedalus"
tt.timed_attacks.list[4].nodes_limit = 10
tt.timed_attacks.list[4].node_offset = -5
tt.timed_attacks.list[4].sound = "HeroMinotaurDaedalusMaze"
tt.timed_attacks.list[4].vis_flags = bor(F_BLOCK, F_RANGED, F_TELEPORT)
tt.timed_attacks.list[4].vis_bans = bor(F_BOSS, F_FLYING, F_CLIFF, F_WATER, F_STUN)
tt = RT("daedalus_enemy_decal", "decal_tween")
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 255}, {0.5, 0}}
tt = RT("mod_minotaur_daedalus", "modifier")

AC(tt, "render")

tt.main_script.insert = mod_minotaur_daedalus_insert
tt.main_script.update = mod_minotaur_daedalus_update
tt.main_script.remove = mod_minotaur_daedalus_remove
tt.render.sprites[1].prefix = "stun"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].sort_y_offset = -1
tt.render.sprites[1].hidden = true
tt = RT("decal_minotaur_daedalus", "decal_tween")
tt.tween.props[1].keys = {{0, 0}, {0.5, 255}, {1, 0}}
tt.render.sprites[1].name = "minotaur_decal_"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt = RT("mod_minotaur_stun", "mod_stun")
tt.modifier.duration = nil
tt = RT("mod_minotaur_dust", "modifier")

AC(tt, "render")

tt.modifier.use_mod_offset = false
tt.modifier.duration = 999
tt.main_script.update = scripts.mod_track_target.update
tt.render.sprites[1].name = "fx_minotaur_dust"
tt = RT("ps_minotaur_bullrush")

AC(tt, "pos", "particle_system")

tt.particle_system.alphas = {0, 255, 255, 0}
tt.particle_system.emission_rate = 30
tt.particle_system.emit_area_spread = vec_2(4, 4)
tt.particle_system.emit_rotation_spread = math.pi
tt.particle_system.emit_speed = {15, 30}
tt.particle_system.emit_spread = math.pi
tt.particle_system.name = "minotaur_particle1"
tt.particle_system.particle_lifetime = {fts(8), fts(12)}
tt.particle_system.scale_var = {0.8, 1.2}
tt.particle_system.scales_x = {0.5, 1.5}
tt.particle_system.scales_y = {0.5, 1.5}
tt = RT("mod_minotaur_roaroffury", "modifier")

AC(tt, "render", "tween")

tt.render.sprites[1].name = "minotaur_towerBuff_base_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.19166666666666668
tt.render.sprites[1].sort_y_offset = -1
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "decal_minotaur_roaroffury_horns"
tt.render.sprites[2].anchor.y = 0.19166666666666668
tt.render.sprites[2].sort_y_offset = -1
tt.main_script.update = scripts.mod_priest_consecrate.update
tt.modifier.duration = 4
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].keys = {{0, 0}, {0.5, 255}}
tt.tween.props[2].sprite_id = 2
tt.tween.props[3] = CC("tween_prop")
tt.tween.props[3].loop = true
tt.tween.props[3].name = "scale"
tt.tween.props[3].keys = {{0, vec_2(1, 1)}, {0.5, vec_2(0.9, 0.9)}, {1, vec_2(1, 1)}}
tt = RT("fx_minotaur_roarofury_scream", "fx")
tt.render.sprites[1].name = "fx_minotaur_roarofury_scream"
tt = RT("decal_minotaur_bloodaxe", "decal_tween")
tt.tween.props[1].keys = {{fts(50), 255}, {fts(60), 0}}
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "minotaur_axeDecal"
