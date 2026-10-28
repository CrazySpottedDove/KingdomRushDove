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
local km = require("lib.klua.macros")
local log = require("lib.klua.log"):new("hero_scripts")
local bor = bit.bor
local find_target_at_critical_moment = HU.find_target_at_critical_moment
local fts = U.fts
local level_up_basic = HU.level_up_basic
local queue_damage = U.queue_damage
local ready_to_attack = U.ready_to_attack
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local v = V.v
local vv = V.vv
local tt

local function aura_tank_skill2_bomb_update(this, store)
	local a = this.aura

	local function do_attack(pos, last_attack)
		local fx = E:create_entity(a.fx)

		fx.pos.x, fx.pos.y = pos.x, pos.y

		if not last_attack then
			fx.render.sprites[2].scale = V.v(0.8, 0.8)
		end

		fx.render.sprites[2].ts = store.tick_ts
		fx.tween.ts = store.tick_ts

		simulation:queue_insert_entity(fx)

		local radius = last_attack and a.last_attack_damage_radius or a.damage_radius
		local targets = U.find_enemies_in_range_filter_off(pos, radius, a.vis_flags, a.vis_bans)

		if targets then
			S:queue(this.sound)

			for _, t in ipairs(targets) do
				local d = E.assign_damage(a.damage_type, math.random(a.damage_min, a.damage_max) * a.damage_factor, this.id, t.id)

				queue_damage(store, d)

				if (last_attack or math.random() < a.stun_chance) and U.flags_pass(t.vis, this.stun) then
					local m = E:create_entity(this.stun.mod)

					m.modifier.source_id = this.id
					m.modifier.target_id = t.id

					simulation:queue_insert_entity(m)
				end
			end
		end
	end

	local pi, spi, ni, tni, target, origin
	local target_info = U.find_enemies_in_paths(store.enemies, this.pos, a.min_nodes, a.max_nodes, nil, a.vis_flags, a.vis_bans)

	if not target_info or #target_info < a.min_count then
		log.error("aura_tank_skill2_bomb could not find valid enemies in the hero paths")
	else
		target = target_info[1].enemy
		origin = target_info[1].origin
		pi, spi, ni = unpack(origin)
		tni = target.nav_path.ni

		for i = 1, a.steps do
			local nni = ni + i * a.step_nodes * km.sign(tni - ni)
			local oni = ni + i * a.step_nodes * km.sign(tni - ni) * -1

			spi = i == a.steps and 1 or (spi == 2 or spi == 3) and 1 or math.random() < 0.5 and 2 or 3

			U.y_wait(store, a.step_delay)

			local spos = P:node_pos(pi, spi, nni)

			do_attack(spos, i == a.steps)

			if i == 1 then
				local opos = P:node_pos(pi, spi, oni)

				do_attack(opos, false)
			end

			local nni = ni - i * a.step_nodes * km.sign(tni - ni)
			local oni = ni - i * a.step_nodes * km.sign(tni - ni) * -1

			spi = i == a.steps and 1 or (spi == 2 or spi == 3) and 1 or math.random() < 0.5 and 2 or 3

			U.y_wait(store, a.step_delay)

			local spos = P:node_pos(pi, spi, nni)

			do_attack(spos, i == a.steps)

			if i == 1 then
				local opos = P:node_pos(pi, spi, oni)

				do_attack(opos, false)
			end
		end
	end

	simulation:queue_remove_entity(this)
end

local function zeppelin_hero_tank_update(this, store)
	local a = this.ranged.attacks[1]
	local fps_normal = 30
	local fps_slow = 20
	local margin = this.flight_height + 100

	if this.pos.y > 768 - margin then
		this.pos.y = 768 - margin
		this.exit_pos.y = 768 - margin
		this.target_pos.y = 768 - margin
	end

	U.animation_start_group(this, "idle", this.exit_pos.x < this.pos.x, store.tick_ts, true, "layers")

	while math.abs(this.pos.x - this.target_pos.x) > this.attack_radius * 1.75 do
		U.force_motion_step(this, store.tick_length, this.target_pos)
		coroutine.yield()
	end

	local b = E:create_entity(a.bullet)

	b.bullet.from = V.v(this.pos.x + a.bullet_start_offset[1].x, this.pos.y + a.bullet_start_offset[1].y + this.render.sprites[1].offset.y)

	b.bullet.to:copy(this.target_pos)

	b.bullet.source_id = this.id

	b.pos:copy(b.bullet.from)

	b.bullet.level = this.level
	b.bullet.damage_factor = this.damage_factor
	b.bullet.hit_payload = E:create_entity(b.bullet.hit_payload)
	b.bullet.hit_payload.damage_factor = this.damage_factor

	simulation:queue_insert_entity(b)

	while not U.animation_finished(this, 1) do
		U.force_motion_step(this, store.tick_length, this.exit_pos)
		coroutine.yield()
	end

	U.animation_start(this, "idle", this.exit_pos.x < this.pos.x, store.tick_ts, true, 1)

	this.force_motion.max_v = this.speed_out_of_range * 0.7

	while math.abs(this.pos.x - this.exit_pos.x) > 10 do
		if this.render.sprites[1].fps == fps_slow and this.render.sprites[1].sync_flag then
			this.render.sprites[1].fps = fps_normal

			for i = 1, #this.render.sprites do
				if this.render.sprites[i].group == "layers" then
					U.animation_start(this, "idle", this.exit_pos.x < this.pos.x, store.tick_ts, true, i, true)
				end
			end
		end

		U.force_motion_step(this, store.tick_length, this.exit_pos)

		local height_factor = (this.render.sprites[1].offset.y - this.flight_height_attack) / (this.flight_height - this.flight_height_attack)

		this.force_motion.max_v = this.speed_in_range + (this.speed_out_of_range - this.speed_in_range) * height_factor

		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

local function decal_bullet_zeppelin_hero_tank_update(this, store)
	local nearest = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)
	local pi, spi, ni = unpack(nearest[1])
	local s_pi, _, s_ni = unpack(nearest[1])
	local delay = 0
	local n_step = ni < s_ni and -2 or 2
	local base_ni = km.clamp(1, #P:path(s_pi), ni < s_ni and ni + 6 or ni)

	ni = km.clamp(1, #P:path(s_pi), ni < s_ni and ni + 6 or ni)

	for i = 1, this.entity_count do
		local e = E:create_entity(this.aura_entity)

		ni = base_ni + n_step * (i - 1)
		ni = km.clamp(1, #P:path(s_pi), ni)
		e.pos = P:node_pos(pi, spi, ni)
		e.aura.source_id = this.id
		e.aura.damage_factor = this.damage_factor
		e.delay = delay

		simulation:queue_insert_entity(e)

		delay = delay + fts(U.frandom(2, 5))
		spi = km.zmod(spi + math.random(1, 2), 3)

		local e = E:create_entity(this.aura_entity)

		ni = base_ni - n_step * i
		ni = km.clamp(1, #P:path(s_pi), ni)
		e.pos = P:node_pos(pi, spi, ni)
		e.aura.source_id = this.id
		e.aura.damage_factor = this.damage_factor
		e.delay = delay

		simulation:queue_insert_entity(e)

		delay = delay + fts(U.frandom(2, 5))
		spi = km.zmod(spi + math.random(1, 2), 3)
	end

	simulation:queue_remove_entity(this)
end

local function controller_overwhelm_tank_update(this, store)
	while true do
		if not this.owner.health.dead and not this.owner.motion.arrived and ready_to_attack(this, store, this.owner.unit.cooldown_factor) then
			this.ts = store.tick_ts

			local targets = U.find_enemies_in_range_filter_off(this.owner.pos, this.damage_radius, this.damage_flags, this.damage_bans)

			if targets then
				for i = 1, #targets do
					local d = E.assign_damage(this.damage_type, this.damage[this.owner.hero.level] * this.owner.unit.damage_factor, this.owner.id, targets[i].id)

					d.xp_dest_id = this.owner.id
					d.xp_gain_factor = this.xp_gain_factor

					queue_damage(store, d)
				end
			end
		end

		coroutine.yield()
	end
end

local function hero_tank_level_up(this, store)
	local hl, ls = level_up_basic(this)
	local bt = E:get_template(this.ranged.attacks[1].bullet)

	bt.bullet.damage_min = ls.ranged_damage_min[hl]
	bt.bullet.damage_max = ls.ranged_damage_max[hl]

	-- 1技能 炽热导弹
	upgrade_skill(this, "heat_missiles", function(this, s)
		this.timed_attacks.list[1].disabled = nil

		local e1 = E:get_template(this.timed_attacks.list[1].bullet)

		e1.bullet.damage_min = s.damage_max_config[s.level]
		e1.bullet.damage_max = s.damage_max_config[s.level]
	end)
	-- 2技能 猛击地
	upgrade_skill(this, "ground_slam", function(this, s)
		this.timed_attacks.list[2].disabled = nil

		local e1 = E:get_template(this.timed_attacks.list[2].hit_aura)

		e1.aura.damage_min = s.damage_min_config[s.level]
		e1.aura.damage_max = s.damage_max_config[s.level]
	end)
	-- 3技能 敢死队
	upgrade_skill(this, "expendables", function(this, s)
		local e = E:get_template(s.entity)

		e.melee.attacks[1].damage_max = s.damage_max[s.level]
		e.melee.attacks[1].damage_min = s.damage_min[s.level]
		e.health.hp_max = s.hp_max[s.level]
		e = E:get_template(e.ranged.attacks[1].bullet)
		e.bullet.damage_max = s.damage_max[s.level] * 1.5
		e.bullet.damage_min = s.damage_min[s.level] * 1.5

		for i = 1, #this.expendables do
			local expendable = this.expendables[i]

			expendable.health.hp_max = s.hp_max[s.level]

			U.heal(expendable, expendable.health.hp_max)

			expendable.melee.attacks[1].damage_max = s.damage_max[s.level]
			expendable.melee.attacks[1].damage_min = s.damage_min[s.level]
		end
	end)
	-- 4技能 灼热大炮
	upgrade_skill(this, "scorching_cannon", function(this, s)
		this.timed_attacks.list[3].disabled = nil
		this.timed_attacks.list[3].cooldown = s.cooldown[s.level]

		local mod = E:get_template("mod_roundfire_hero_tank")

		mod.dps.damage_min = s.damage_config[s.level]
		mod.dps.damage_max = s.damage_config[s.level]
	end)
	-- 大招 女武神的呼唤
	upgrade_skill(this, "ultimate", function(this, s)
		this.ultimate.disabled = nil

		local u = E:get_template(s.controller_name)

		u.cooldown = s.cooldown[s.level]

		local mod = E:get_template("mod_bullet_zeppelin_hero_tank")

		mod.dps.damage_min = s.damage_config[s.level]
		mod.dps.damage_max = s.damage_config[s.level]
	end)
	update_hp(this)
end

local function hero_tank_update(this, store)
	local h = this.health
	local a, am, skill, force_idle_ts
	local zhu_apprentice_soldier_list = this.expendables
	local zhu_offset = {{-15, -10}, {-15, 10}, {15, 0}}
	local missle_attack = this.timed_attacks.list[1] -- 1技能 导弹
	local shake_attack = this.timed_attacks.list[2] -- 2技能 震地
	local fire_attack = this.timed_attacks.list[3] -- 4技能 喷火

	U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

	this.health_bar.hidden = false
	force_idle_ts = true

	local overwhelm = E:create_entity(this.overwhelm_entity)

	overwhelm.owner = this

	simulation:queue_insert_entity(overwhelm)

	local function rally_zhu_apprentice()
		if #zhu_apprentice_soldier_list <= 0 then
			return
		else
			local nearest = P:nearest_nodes(this.nav_rally.pos.x, this.nav_rally.pos.y, nil, nil, true)
			local rally_position

			if nearest then
				local pi, spi, ni = unpack(nearest[1])

				rally_position = P:node_pos(pi, spi, ni - 6)
			else
				rally_position = V.vclone(this.nav_rally.pos)
			end

			for count, zhu_apprentice_soldier in ipairs(zhu_apprentice_soldier_list) do
				zhu_apprentice_soldier.nav_rally.new = true

				zhu_apprentice_soldier.nav_rally.center:set(rally_position.x + zhu_offset[count][1], rally_position.y + zhu_offset[count][2])
				zhu_apprentice_soldier.nav_rally.pos:copy(zhu_apprentice_soldier.nav_rally.center)

				zhu_apprentice_soldier.nav_grid.waypoints = table.deepclone(this.nav_grid.waypoints)

				table.remove(zhu_apprentice_soldier.nav_grid.waypoints, #zhu_apprentice_soldier.nav_grid.waypoints)
			end
		end
	end

	local function create_soldiers()
		if this.hero.skills.expendables.count[this.hero.skills.expendables.level] > #zhu_apprentice_soldier_list then
			local nearest = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)
			local rally_position

			if nearest then
				local pi, spi, ni = unpack(nearest[1])

				rally_position = P:node_pos(pi, spi, ni - 6)
			else
				rally_position = V.vclone(this.nav_rally.pos)
			end

			for i = #zhu_apprentice_soldier_list + 1, this.hero.skills.expendables.count[this.hero.skills.expendables.level] do
				local e = E:create_entity(this.hero.skills.expendables.entity)

				e.pos:set(rally_position.x + zhu_offset[i][1], rally_position.y + zhu_offset[i][2])
				e.nav_rally.center:copy(e.pos)
				e.nav_rally.pos:copy(e.pos)
				simulation:queue_insert_entity(e)

				zhu_apprentice_soldier_list[i] = e
			end
		end
	end

	local function y_hero_walk_waypoints(store, this)
		local r = this.nav_rally
		local n = this.nav_grid
		local dest = r.pos

		while not V.veq(this.pos, dest) do
			local w = table.remove(n.waypoints, 1) or dest
			local unsnap = #n.waypoints > 0

			U.set_destination(this, w)

			local dx, dy = this.motion.dest.x - this.pos.x, this.motion.dest.y - this.pos.y
			local angle = math.atan2(dy, dx) % 6.2831853071795862 * 57.295779513082323
			local an, af

			if (0 <= angle and angle < 15) or (345 <= angle and angle < 360) then
				an = "walk_0"
				af = false
			elseif (165 <= angle and angle < 195) then
				an = "walk_0"
				af = true
			elseif (15 <= angle and angle < 45) then
				an = "walk_30"
				af = false
			elseif (135 <= angle and angle < 165) then
				an = "walk_30"
				af = true
			elseif (45 <= angle and angle < 75) then
				an = "walk_60"
				af = false
			elseif (105 <= angle and angle < 135) then
				an = "walk_60"
				af = true
			elseif (75 <= angle and angle < 105) then
				an = "walk_90"
				af = false
			elseif (255 <= angle and angle < 285) then
				an = "walk_270"
				af = false
			elseif (285 <= angle and angle < 315) then
				an = "walk_300"
				af = false
			elseif (225 <= angle and angle < 255) then
				an = "walk_300"
				af = true
			elseif (315 <= angle and angle < 345) then
				an = "walk_330"
				af = false
			elseif (195 <= angle and angle < 225) then
				an = "walk_330"
				af = true
			end

			U.animation_start_default(this, an, af, store.tick_ts, true)

			while not this.motion.arrived do
				if this.health.dead and not this.health.ignore_damage then
					return true
				end

				if r.new then
					return false
				end

				U.walk(this, store.tick_length, nil, unsnap)
				coroutine.yield()

				this.motion.speed.x, this.motion.speed.y = 0, 0
			end
		end
	end

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)

			force_idle_ts = true
		end

		while this.nav_rally.new do
			rally_zhu_apprentice()

			local r = this.nav_rally
			local out

			if r.new then
				r.new = false

				U.unblock_target(store, this)

				if this.sound_events then
					S:queue(this.sound_events.change_rally_point)
				end

				local prev_immune = this.health.immune_to

				U.bans_add(this.vis, F_ALL)

				this.health.immune_to = r.immune_to
				out = y_hero_walk_waypoints(store, this)

				U.animation_start_default(this, "idle", nil, store.tick_ts, true)
				U.bans_remove(this.vis, F_ALL)

				this.health.immune_to = prev_immune
			end

			if out then
				goto label_tank_attack_end
			end
		end

		create_soldiers()

		if SU.hero_level_up(store, this) then
			U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
		end

		-- 大招 女武神的呼唤
		if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
			local target = find_target_at_critical_moment(this, this.ultimate.range, F_RANGED, F_FLYING, nil, true)

			if target then
				this.ultimate.ts = store.tick_ts

				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
				S:queue(this.sound_events.change_rally_point)

				local e = E:create_entity(this.hero.skills.ultimate.controller_name)

				e.damage_factor = this.unit.damage_factor
				e.pos = V.vclone(target.pos)
				e.level = this.hero.skills.ultimate.level

				simulation:queue_insert_entity(e)
				SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
			else
				this.ultimate.ts = this.ultimate.ts + 1
			end
		end

		-- 1技能 导弹
		am = missle_attack
		skill = this.hero.skills.heat_missiles

		if ready_to_use_skill(am, store, this.unit.cooldown_factor) then
			local target = U.detect_foremost_enemy_between_range_filter_off(this.pos, am.min_range, am.max_range, am.vis_flags, am.vis_bans)

			if target then
				local an, af = U.animation_name_facing_point(this, am.animation_pre, target.pos)

				U.animation_start(this, an, af, store.tick_ts, false, 1)

				if SU.y_hero_animation_wait(this) then
					goto label_tank_attack_end
				end

				am.ts = store.tick_ts

				SU.hero_gain_xp_from_skill(this, skill)

				local burst_count = skill.count[skill.level]
				local fire_loops = burst_count / #am.hit_times

				for i = 1, fire_loops do
					local an, af

					if i == fire_loops then
						an, af = U.animation_name_facing_point(this, am.animation, target.pos)
					else
						an, af = U.animation_name_facing_point(this, am.animation_last, target.pos)
					end

					U.animation_start(this, an, af, store.tick_ts, false, 1)

					for hi, ht in ipairs(am.hit_times) do
						while ht > store.tick_ts - this.render.sprites[1].ts do
							if this.nav_rally.new then
								goto label_tank_missiles_end
							end

							coroutine.yield()
						end

						local b = E:create_entity(am.bullet)

						b.pos.x = this.pos.x + (af and -1 or 1) * am.start_offsets[km.zmod(hi, #am.start_offsets)].x
						b.pos.y = this.pos.y + am.start_offsets[hi].y
						b.bullet.level = skill.level

						b.bullet.from:copy(b.pos)

						b.bullet.to = V.v(b.pos.x + (af and -1 or 1) * am.launch_vector.x, b.pos.y + am.launch_vector.y)
						b.bullet.target_id = target.id
						b.bullet.source_id = this.id
						b.bullet.damage_factor = this.unit.damage_factor

						simulation:queue_insert_entity(b)

						target = U.detect_foremost_enemy_between_range_filter_off(this.pos, am.min_range, am.max_range, am.vis_flags, am.vis_bans)

						if not target then
							goto label_tank_missiles_end
						end
					end

					U.y_wait(store, fts(3) * this.unit.cooldown_factor)
				end

				::label_tank_missiles_end::

				U.animation_start(this, am.animation_post, nil, store.tick_ts, false, 1)

				if SU.y_hero_animation_wait(this) then
					goto label_tank_attack_end
				end
			else
				am.ts = am.ts + 0.1
			end
		end

		-- 2技能 捶地
		a = shake_attack
		skill = this.hero.skills.ground_slam

		if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
			local target_info = U.find_enemies_in_paths(store.enemies, this.pos, a.min_nodes, a.max_nodes, nil, a.vis_flags, a.vis_bans)

			if not target_info or #target_info < a.min_count then
				a.ts = a.ts + 0.1
			else
				local target = target_info[1].enemy

				S:queue(a.sound_pre)

				if not SU.y_soldier_do_single_area_attack(store, this, target, a) then
					goto label_tank_attack_end
				end

				SU.hero_gain_xp_from_skill(this, skill)
			end
		end

		-- 4技能 喷火
		am = fire_attack
		skill = this.hero.skills.scorching_cannon

		if ready_to_use_skill(am, store, this.unit.cooldown_factor) then
			if U.find_first_enemy_between_range_filter_off(this.pos, am.min_range, am.max_range, am.vis_flags, am.vis_bans) then
				local start_ts = store.tick_ts

				U.animation_start(this, am.animation_pre, nil, store.tick_ts, false, 1)
				S:queue(am.sound_pre)

				if SU.y_hero_animation_wait(this) then
					goto label_tank_attack_end
				end

				U.animation_start(this, am.animation, nil, store.tick_ts, false, 1)
				S:queue(am.sound)

				local points = {}
				local inner_fx_radius = 35

				for i = 1, 12 do
					local r = inner_fx_radius
					local p = {}

					p.pos = U.point_on_ellipse(this.pos, r, 2 * math.pi * (12 - i) / 12)
					p.terrain = GR:cell_type(p.pos.x, p.pos.y)

					if GR:cell_is(p.pos.x, p.pos.y, TERRAIN_WATER) or P:valid_node_nearby(p.pos.x, p.pos.y, 1) and not GR:cell_is(p.pos.x, p.pos.y, TERRAIN_CLIFF) then
						table.insert(points, p)
					end
				end

				am.ts = start_ts

				SU.hero_gain_xp_from_skill(this, skill)

				for _, p in ipairs(points) do
					local e = E:create_entity(am.entity)

					e.pos = V.vclone(p.pos)
					e.aura.source_id = this.id
					e.aura.ts = store.tick_ts
					e.aura.level = skill.level
					e.aura.damage_factor = this.unit.damage_factor

					simulation:queue_insert_entity(e)
					U.y_wait(store, fts(3) * this.unit.cooldown_factor)
				end

				if SU.y_hero_animation_wait(this) then
					goto label_tank_attack_end
				end

				while not U.animation_finished(this) do
					coroutine.yield()
				end

				U.animation_start(this, am.animation_post, nil, store.tick_ts, false, 1)
				S:queue(am.sound_post)

				if SU.y_hero_animation_wait(this) then
					goto label_tank_attack_end
				end
			else
				am.ts = am.ts + 0.1
			end
		end

		-- 普攻
		for _, i in pairs(this.ranged.order) do
			local a = this.ranged.attacks[i]

			if a.disabled then
			-- block empty
			elseif not ready_to_attack(a, store, this.unit.cooldown_factor) then
			-- block empty
			elseif math.random() > a.chance then
			-- block empty
			else
				local origin = V.v(this.pos.x, this.pos.y + a.bullet_start_offset[1].y)
				local bullet_t = E:get_template(a.bullet)
				local bullet_speed = bullet_t.bullet.min_speed
				local target = U.detect_foremost_enemy_in_range_filter_off(this.pos, a.max_range, a.vis_flags, a.vis_bans)

				if target then
					local start_ts = store.tick_ts
					local dist = V.dist(origin.x, origin.y, target.pos.x, target.pos.y)
					local node_offset = P:predict_enemy_node_advance(target, dist / bullet_speed)
					local t_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + node_offset)
					local an, af, ai = U.animation_name_facing_point(this, a.animation, t_pos)

					U.animation_start(this, an, af, store.tick_ts, false, 1)

					if SU.y_hero_wait(store, this, a.shoot_time) then
						goto label_tank_attack_end
					end

					local new_target = U.detect_foremost_enemy_in_range_filter_off(this.pos, a.max_range, a.vis_flags, a.vis_bans)

					if new_target then
						target = new_target
					end

					local b = E:create_entity(a.bullet)

					b.bullet.target_id = target.id
					b.bullet.source_id = this.id
					b.bullet.damage_factor = this.unit.damage_factor
					b.bullet.xp_dest_id = this.id

					b.pos:copy(this.pos)

					b.pos.x = b.pos.x + (af and -1 or 1) * a.bullet_start_offset[ai].x
					b.pos.y = b.pos.y + a.bullet_start_offset[ai].y

					b.bullet.from:copy(b.pos)

					b.bullet.to = U.calculate_enemy_ffe_pos(target, b.bullet.flight_time)

					simulation:queue_insert_entity(b)

					a.ts = start_ts

					if SU.y_hero_animation_wait(this) then
						goto label_tank_attack_end
					end

					force_idle_ts = true
				else
					a.ts = a.ts + 0.1
				end
			end
		end

		SU.soldier_idle(store, this, force_idle_ts)
		SU.soldier_regen(store, this)

		::label_tank_attack_end::

		force_idle_ts = nil

		coroutine.yield()
	end
end

local function hero_tank_ultimate_update(this, store)
	local function spawn_zeppelin(pi, spi, ni)
		local pos = P:node_pos(pi, spi, ni)
		local x_center = (store.visible_coords.left + store.visible_coords.right) / 2
		local spawn_pos = V.vclone(pos)
		local exit_pos = V.vclone(pos)
		local out_of_screen_offset = 100

		if x_center > spawn_pos.x then
			spawn_pos.x = store.visible_coords.left - out_of_screen_offset
			exit_pos.x = store.visible_coords.right + out_of_screen_offset
		else
			spawn_pos.x = store.visible_coords.right + out_of_screen_offset
			exit_pos.x = store.visible_coords.left - out_of_screen_offset
		end

		local zep = E:create_entity(this.entity)

		zep.pos = V.vclone(spawn_pos)
		zep.target_pos = V.vclone(pos)
		zep.exit_pos = V.vclone(exit_pos)
		zep.sound = this.sound
		zep.level = this.level
		zep.damage_factor = this.damage_factor

		simulation:queue_insert_entity(zep)
	end

	local nearest = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)

	if #nearest > 0 then
		local pi, _, ni = unpack(nearest[1])

		if P:is_node_valid(pi, ni) then
			S:queue(this.sound)
			spawn_zeppelin(pi, 1, ni)
		end
	end

	simulation:queue_remove_entity(this)
end

tt = RT("hero_tank", "hero")

AC(tt, "ranged", "timed_attacks", "auras")

tt.health.dead_lifetime = 15
tt.health_bar.draw_order = -1
tt.health_bar.offset = v(0, 80)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.ui.click_rect = r(-20, -5, 40, 60)
tt.hero.tombstone_show_time = fts(90)
tt.hero.fn_level_up = hero_tank_level_up
tt.main_script.update = hero_tank_update
tt.motion.max_speed = 75
tt.overwhelm_entity = "controller_overwhelm_tank"
tt.regen.cooldown = 1
tt.soldier.melee_slot_offset = v(5, 0)
tt.sound_events.change_rally_point = "group_tank_taunt"
tt.sound_events.death = "hero_tank_death"
tt.sound_events.hero_room_select = "hero_tank_taunt_1"
tt.sound_events.insert = "group_tank_taunt"
tt.sound_events.respawn = "group_tank_taunt"
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 30)
-- 1技能 炽热导弹
tt.hero.skills.heat_missiles = CC("hero_skill")
tt.hero.skills.heat_missiles.count = {4, 6, 8}
tt.hero.skills.heat_missiles.damage_min_config = {16, 22, 32}
tt.hero.skills.heat_missiles.damage_max_config = {24, 34, 48}
tt.hero.skills.heat_missiles.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.heat_missiles.xp_gain = {60, 120, 180}
-- 2技能 猛击地
tt.hero.skills.ground_slam = CC("hero_skill")
tt.hero.skills.ground_slam.damage_min_config = {21, 42, 63}
tt.hero.skills.ground_slam.damage_max_config = {39, 78, 117}
tt.hero.skills.ground_slam.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.ground_slam.xp_gain = {250, 500, 750}
-- 3技能 敢死队
tt.hero.skills.expendables = CC("hero_skill")
tt.hero.skills.expendables.count = {2, 3, 3}
tt.hero.skills.expendables.damage_min = {4, 6, 9}
tt.hero.skills.expendables.damage_max = {7, 10, 14}
tt.hero.skills.expendables.hp_max = {160, 200, 240}
tt.hero.skills.expendables.entity = "hero_tank_expendables"
tt.hero.skills.expendables.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
-- 4技能 灼热大炮
tt.hero.skills.scorching_cannon = CC("hero_skill")
tt.hero.skills.scorching_cannon.cooldown = {35, 33, 30}
tt.hero.skills.scorching_cannon.damage_config = {4, 7, 10}
tt.hero.skills.scorching_cannon.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.scorching_cannon.xp_gain = {200, 400, 600}
-- 大招 女武神的呼唤
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.cooldown = {48, 48, 48, 48}
tt.hero.skills.ultimate.damage_config = {3, 6, 9, 12}
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.ultimate.xp_gain = {120, 240, 360, 480}
tt.hero.skills.ultimate.controller_name = "controller_hero_tank_ultimate"
tt.ultimate = {
	ts = 0,
	cooldown = 48,
	disabled = true,
	range = 140
}
tt.hero.level_stats.hp_max = {264, 288, 312, 336, 360, 384, 408, 432, 456, 480}
tt.hero.level_stats.armor = {0.06, 0.12, 0.18, 0.24, 0.3, 0.36, 0.42, 0.48, 0.54, 0.6}
tt.hero.level_stats.ranged_damage_min = {15, 22, 29, 36, 43, 55, 63, 71, 80, 88}
tt.hero.level_stats.ranged_damage_max = {30, 44, 58, 72, 86, 101, 117, 133, 148, 164}
tt.expendables = {}
tt.info.hero_portrait = "kr4_hero_portraits_0009"
tt.info.portrait = "kr4_info_portraits_heroes_0009"
tt.render.sprites[1].anchor = v(0.5, 0.02)
tt.render.sprites[1].offset = v(0, -40)
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_tank"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "hero_tank_ultimate_plane_shadow"
tt.render.sprites[2].z = Z_DECALS + 1
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].cooldown = 3
tt.ranged.attacks[1].min_range = 0
tt.ranged.attacks[1].vis_bans = bor(F_FLYING)
tt.ranged.attacks[1].max_range = 140
tt.ranged.attacks[1].animation = "shoot"
tt.ranged.attacks[1].bullet = "bullet_tank"
tt.ranged.attacks[1].node_prediction = fts(25)
tt.ranged.attacks[1].shoot_time = fts(23)
tt.ranged.attacks[1].bullet_start_offset = {v(8, 48)}
tt.timed_attacks.list[1] = CC("bullet_attack")
tt.timed_attacks.list[1].animation_pre = "HeatMissilesIn"
tt.timed_attacks.list[1].animation = "HeatMissilesLoop"
tt.timed_attacks.list[1].animation_last = "HeatMissilesLastLoop"
tt.timed_attacks.list[1].animation_post = "HeatMissilesOut"
tt.timed_attacks.list[1].cooldown = 18
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].bullet = "missle_tank"
tt.timed_attacks.list[1].start_offsets = {v(4, 60)}
tt.timed_attacks.list[1].hit_times = {fts(3)}
tt.timed_attacks.list[1].launch_vector = v(math.random(10, 40), math.random(30, 120))
tt.timed_attacks.list[1].vis_flags = F_RANGED
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].max_range = 600
tt.timed_attacks.list[2] = CC("area_attack")
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].cooldown = 28
tt.timed_attacks.list[2].animation = "GroundSlam"
tt.timed_attacks.list[2].count = 10
tt.timed_attacks.list[2].sound_pre = "hero_tank_groundslam_lift"
tt.timed_attacks.list[2].sound = "hero_tank_groundslam_impact"
tt.timed_attacks.list[2].damage_max = 0
tt.timed_attacks.list[2].damage_min = 0
tt.timed_attacks.list[2].damage_radius = 50
tt.timed_attacks.list[2].damage_type = DAMAGE_TRUE
tt.timed_attacks.list[2].hit_decal = "decal_ground_hit"
tt.timed_attacks.list[2].hit_fx = "fx_ground_hit"
tt.timed_attacks.list[2].hit_offset = v(0, 0)
tt.timed_attacks.list[2].hit_time = fts(38)
tt.timed_attacks.list[2].hit_aura = "aura_tank_skill2_bomb"
tt.timed_attacks.list[2].min_count = 1
tt.timed_attacks.list[2].min_range = 20
tt.timed_attacks.list[2].max_range = 200
tt.timed_attacks.list[2].min_nodes = 5
tt.timed_attacks.list[2].max_nodes = 20
tt.timed_attacks.list[2].pop = {"pop_kapow", "pop_whaam"}
tt.timed_attacks.list[2].pop_chance = 0.3
tt.timed_attacks.list[2].pop_conds = DR_KILL
tt.timed_attacks.list[2].xp_from_skill = "ground_slam"
tt.timed_attacks.list[3] = CC("bullet_attack")
tt.timed_attacks.list[3].animation_pre = "scorchingCannonIn"
tt.timed_attacks.list[3].animation = "scorchingCannonLoop"
tt.timed_attacks.list[3].animation_post = "scorchingCannonOut"
tt.timed_attacks.list[3].cooldown = 35
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].entity = "aura_roundfire_hero_tank"
tt.timed_attacks.list[3].sound_pre = "hero_tank_scorching_loopstart"
tt.timed_attacks.list[3].sound = "hero_tank_scorching_loop"
tt.timed_attacks.list[3].sound_post = "hero_tank_scorching_loopend"
tt.timed_attacks.list[3].spawn_time = fts(10)
tt.timed_attacks.list[3].vis_flags = F_RANGED
tt.timed_attacks.list[3].vis_bans = F_FLYING
tt.timed_attacks.list[3].min_range = 0
tt.timed_attacks.list[3].max_range = 70
tt = RT("controller_overwhelm_tank")

AC(tt, "main_script")

tt.owner = nil
tt.cooldown = 0.2
tt.damage = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
tt.damage_type = DAMAGE_PHYSICAL
tt.damage_radius = 50
tt.damage_flags = F_AREA
tt.damage_bans = 0
tt.xp_gain_factor = 1
tt.ts = 0
tt.main_script.update = controller_overwhelm_tank_update
tt = RT("bullet_tank", "bomb")
tt.bullet.flight_time = fts(25)
tt.bullet.rotation_speed = 20 * FPS * math.pi / 180
tt.bullet.hit_fx = "fx_explosion_tank"
tt.bullet.hit_decal = "decal_bomb_crater"
tt.bullet.hit_fx_water = "fx_explosion_water"
tt.bullet.damage_type = DAMAGE_EXPLOSION
tt.bullet.damage_min = 40
tt.bullet.min_speed = 300
tt.bullet.damage_max = 40
tt.bullet.damage_radius = 40
tt.bullet.pop = nil
tt.bullet.to = v(0, 0)
tt.bullet.from = v(0, 0)
tt.bullet.damage_flags = F_AREA
tt.bullet.hide_radius = 8
tt.bullet.xp_gain_factor = 0.8
tt.render.sprites[1].name = "hero_tank_simple_proyectile"
tt.render.sprites[1].animated = false
tt.sound_events.insert = "BombShootSound"
tt.sound_events.hit = "BombExplosionSound"
tt.sound_events.hit_water = "RTWaterExplosion"
tt = RT("fx_explosion_tank", "fx")
tt.render.sprites[1].prefix = "hero_tank_hit"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].offset = v(0, 0)
tt.render.sprites[1].scale = v(1.2, 1.2)
tt.render.sprites[1].anchor = v(0.5, 0.13)
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = 0
tt = RT("fx_explosion_tank_air", "fx")
tt.render.sprites[1].prefix = "hero_tank_hit_air"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].offset = v(0, 0)
tt.render.sprites[1].scale = v(1.2, 1.2)
tt.render.sprites[1].anchor = v(0.5, 0.13)
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = 0
tt = RT("missle_tank", "bullet")
tt.render.sprites[1].name = "hero_tank_missile_proyectile"
tt.render.sprites[1].animated = false
tt.render.sprites[1].loop = true
tt.render.sprites[1].flip_x = true
tt.bullet.damage_type = DAMAGE_EXPLOSION
tt.bullet.min_speed = 300
tt.bullet.max_speed = 600
tt.bullet.turn_speed = 10 * math.pi / 180 * 30
tt.bullet.acceleration_factor = 0.2
tt.bullet.hit_fx = "fx_explosion_tank"
tt.bullet.hit_fx_air = "fx_explosion_tank_air"
tt.bullet.hit_fx_water = "fx_explosion_water"
tt.bullet.damage_min = 20
tt.bullet.damage_max = 80
tt.bullet.damage_radius = 40
tt.bullet.vis_flags = F_RANGED
tt.bullet.damage_flags = F_AREA
tt.bullet.particles_name = "ps_missile_tank"
tt.bullet.retarget_range = 99999
tt.bullet.pirates_pillage_rate = 0
tt.bullet.got_gold = 3
tt.main_script.insert = scripts.missile.insert
tt.main_script.update = scripts.missile.update
tt.sound_events.insert = "RocketLaunchSound"
tt.sound_events.hit = "BombExplosionSound"
tt.sound_events.hit_water = "RTWaterExplosion"
tt = RT("ps_missile_tank")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "hero_tank_missile_particle_run"
tt.particle_system.animated = true
tt.particle_system.animation_fps = 50
tt.particle_system.loop = false
tt.particle_system.alphas = {255, 0}
tt.particle_system.particle_lifetime = {fts(16), fts(16)}
tt.particle_system.track_rotation = true
tt.particle_system.scales_x = {1, 1.25}
tt.particle_system.scales_y = {1, 1.25}
tt.particle_system.emission_rate = 30
tt = RT("aura_tank_skill2_bomb", "aura")
tt.aura.fx = "decal_tank_spike"
tt.sound = "hero_tank_scorching_loop"
tt.aura.damage_radius = 50
tt.aura.last_attack_damage_radius = 60
tt.aura.damage_type = DAMAGE_PHYSICAL
tt.aura.vis_flags = bor(F_RANGED)
tt.aura.vis_bans = bor(F_FRIEND)
tt.aura.step_delay = fts(2)
tt.aura.step_nodes = 6
tt.aura.steps = 5
tt.main_script.update = aura_tank_skill2_bomb_update
tt.stun = {}
tt.stun.vis_flags = bor(F_RANGED, F_STUN)
tt.stun.vis_bans = bor(F_BOSS)
tt.stun.mod = "mod_tank_skill2_stun"
tt.aura.damage_min = 10
tt.aura.damage_max = 20
tt.aura.stun_chance = 1
tt.aura.min_nodes = 0
tt.aura.max_nodes = 25
tt.aura.min_count = 1
tt = RT("mod_tank_skill2_stun", "mod_stun")
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt.modifier.vis_bans = bor(F_FLYING, F_BOSS)
tt.modifier.duration = 2
tt = RT("decal_tank_spike", "decal_bomb_crater")
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "hero_tank_GroundSlam_decal_run"
tt.render.sprites[2].hide_after_runs = 1
tt.render.sprites[2].anchor = v(0.5, 0.24)
tt = RT("controller_hero_tank_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.cooldown = 48
tt.entity = "zeppelin_hero_tank"
tt.main_script.update = hero_tank_ultimate_update
tt.sound_events.insert = "hero_tank_ultimate"
tt = RT("zeppelin_hero_tank", "decal_scripted")

AC(tt, "force_motion", "ranged")

tt.decal = "decal_hero_tank_ultimate"
tt.main_script.update = zeppelin_hero_tank_update
tt.force_motion.max_a = 1500
tt.force_motion.max_v = 200
tt.force_motion.ramp_radius = 30
tt.force_motion.fr = 0.05
tt.force_motion.a_step = 40
tt.flight_height = 150
tt.flight_height_attack = 30
tt.duration = nil
tt.start_ts = nil
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].prefix = "hero_tank_ultimate_plane_fly"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].group = "layers"
tt.render.sprites[1].offset = v(0, tt.flight_height)
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animation = "attack"
tt.ranged.attacks[1].bullet = "bullet_zeppelin_hero_tank"
tt.ranged.attacks[1].bullet_start_offset = {v(0, 105)}
tt.ranged.attacks[1].cooldown = 0.5
tt.ranged.attacks[1].max_range = 200
tt.ranged.attacks[1].min_range = 10
tt.ranged.attacks[1].damage_type = DAMAGE_TRUE
tt.ranged.attacks[1].damage_min_config = {40, 48, 56, 64}
tt.ranged.attacks[1].damage_max_config = {60, 72, 84, 96}
tt.ranged.attacks[1].shoot_time = fts(4)
tt.ranged.attacks[1].sound_args = {
	delay = fts(14)
}
tt.ranged.attacks[1].sound_chance = 0.5
tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE, F_CLIFF)
tt.ranged.attacks[1].xp_gain_factor = nil
tt.ranged.attacks[1].basic_attack = true
tt.speed_out_of_range = 200
tt.speed_in_range = 30
tt.attack_radius = 125
tt = RT("decal_hero_tank_ultimate", "decal_tween")
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "hero_tank_ultimate_plane_shadow"
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{1, 255}, {9, 255}, {12, 0}}
tt.tween.run_once = true
tt = RT("bullet_zeppelin_hero_tank", "bomb")
tt.bullet.flight_time = fts(20)
tt.bullet.hit_fx = "fx_bullet_zeppelin_hero_tank"
tt.bullet.hit_payload = "controller_spread_aura_bullet_zeppelin_hero_tank"
tt.bullet.align_with_trajectory = false
tt.bullet.ignore_hit_offset = true
tt.bullet.pop_chance = 0.5
tt.bullet.rotation_speed = 10
tt.sound_events.hit = "hero_tank_ultimate_flame"
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "hero_tank_ultimate_proyectile"
tt = RT("fx_bullet_zeppelin_hero_tank", "fx")
tt.render.sprites[1].name = "hero_tank_ultimate_proyectile_explosion_run"
tt = RT("controller_spread_aura_bullet_zeppelin_hero_tank")

AC(tt, "pos", "main_script")

tt.aura_entity = "aura_bullet_zeppelin_hero_tank"
tt.entity_count = 6
tt.main_script.update = decal_bullet_zeppelin_hero_tank_update
tt = RT("aura_bullet_zeppelin_hero_tank", "aura")

AC(tt, "render")

tt.render.sprites[1].prefix = "hero_tank_ultimate_fire"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].scale = v(1.3, 1.3)
tt.render.sprites[1].anchor = v(0.5, 0.2)
tt.render.sprites[1].z = Z_DECALS + 1
tt.aura.duration = 4
tt.aura.mods = {"mod_bullet_zeppelin_hero_tank"}
tt.aura.cycle_time = 0.1
tt.aura.radius = 70
tt.aura.vis_bans = bor(F_FRIEND, F_FLYING)
tt.aura.vis_flags = bor(F_MOD, F_AREA)
tt.aura.with_fade = true
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt = RT("mod_bullet_zeppelin_hero_tank", "modifier")

AC(tt, "dps", "render")

tt.modifier.allows_duplicates = false
tt.modifier.duration = 0.4
tt.modifier.vis_flags = F_MOD
tt.modifier.vis_bans = bor(F_FRIEND, F_FLYING)
tt.dps.damage_min = 7
tt.dps.damage_max = 7
tt.dps.damage_inc = 0
tt.dps.damage_type = DAMAGE_PHYSICAL
tt.dps.damage_every = 0.03
tt.render.sprites[1].prefix = "hero_tank_ultimate_fire_modifier"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].size_names = {"run", "run", "run"}
tt.render.sprites[1].size_scales = {vv(1), vv(1.4), vv(1.8)}
tt.render.sprites[1].draw_order = 2
tt.render.sprites[1].loop = true
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt = RT("aura_roundfire_hero_tank", "aura")

AC(tt, "render")

tt.render.sprites[1].prefix = "hero_tank_fire_loop"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].anchor = v(0.5, 0.2)
tt.render.sprites[1].z = Z_DECALS + 1
tt.aura.duration = 4
tt.aura.mods = {"mod_roundfire_hero_tank"}
tt.aura.cycle_time = 0.2
tt.aura.radius = 65
tt.aura.vis_bans = bor(F_FRIEND, F_FLYING)
tt.aura.vis_flags = bor(F_MOD, F_AREA)
tt.aura.with_fade = true
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt = RT("mod_roundfire_hero_tank", "modifier")

AC(tt, "dps", "render")

tt.modifier.duration = 0.4
tt.modifier.vis_flags = F_MOD
tt.modifier.vis_bans = bor(F_FRIEND, F_FLYING)
tt.dps.damage_min = 2
tt.dps.damage_max = 2
tt.dps.damage_inc = 0
tt.dps.damage_type = DAMAGE_TRUE
tt.dps.damage_every = 0.2
tt.render.sprites[1].prefix = "hero_tank_fire"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].size_names = {"run", "run", "run"}
tt.render.sprites[1].size_scales = {vv(1), vv(1.4), vv(1.8)}
tt.render.sprites[1].draw_order = 2
tt.render.sprites[1].loop = true
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt = RT("hero_tank_expendables", "soldier_militia")

AC(tt, "nav_grid", "ranged")

tt.info.portrait = "kr4_info_portraits_soldiers_0039"
tt.info.fn = scripts.soldier_reinforcement.get_info
tt.info.random_name_count = nil
tt.info.random_name_format = nil
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].offset = v(0, 13)
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_tank_expendable2"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].anchor = v(0.5, 0.5)
tt.render.sprites[2].offset = v(0, 13)
tt.render.sprites[2].name = "hero_tank_expendable2_shadow"
tt.render.sprites[2].z = Z_DECALS + 1
tt.unit.hit_offset = v(0, 16)
tt.health_bar.type = HEALTH_BAR_SIZE_SMALL
tt.health_bar.offset = v(0, 28)
tt.main_script.insert = scripts.soldier_hero_wukong_zhu_apprentice.insert
tt.main_script.update = scripts.soldier_hero_wukong_zhu_apprentice.update
tt.regen.cooldown = 1
tt.idle_flip.last_animation = "idle"
tt.melee.range = 60
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 7
tt.melee.attacks[1].damage_min = 4
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_time = fts(2)
tt.melee.attacks[1].animation = "melee"
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animation = "shoot"
tt.ranged.attacks[1].bullet = "shotgun_hero_tank_expendables"
tt.ranged.attacks[1].bullet_start_offset = {v(6, 12)}
tt.ranged.attacks[1].cooldown = 0.9
tt.ranged.attacks[1].max_range = 175
tt.ranged.attacks[1].min_range = 25
tt.ranged.attacks[1].shoot_time = fts(16)
tt.unit.fade_time_after_death = nil
tt.ui.click_rect = r(-12, -5, 24, 30)
tt.health.dead_lifetime = 15
tt.health.hp_max = 160
tt.health.ignore_delete_after = true
tt.motion.max_speed = 75
tt.soldier.melee_slot_offset = v(12, 0)
tt = RT("shotgun_hero_tank_expendables", "shotgun")
tt.bullet.damage_max = 13
tt.bullet.damage_min = 7
tt.bullet.hit_blood_fx = "fx_blood_splat"
tt.bullet.min_speed = 20 * FPS
tt.bullet.max_speed = 20 * FPS
tt.bullet.damage_type = DAMAGE_SHOT
tt.sound_events.insert = "ShotgunSound"
-- ======== 浚湃 ========
anchor_x, anchor_y = 0.5, 0.12
image_x, image_y = 92, 110
