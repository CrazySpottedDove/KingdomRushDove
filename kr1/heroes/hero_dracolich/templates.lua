local bit = require("bit")
local E = require("entity_db")
local GR = require("grid_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")
local km = require("lib.klua.macros")
local scripts = require("scripts")

require("lib.klua.table")
require("all.constants")

local band = bit.band
local bor = bit.bor
local v = V.v
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local update_hp = HU.update_hp
local queue_damage = U.queue_damage

local function hero_level_up(this, store)
	local hl, ls = level_up_basic(this)
	local b = E:get_template("fireball_dracolich")

	b.bullet.damage_max = ls.ranged_damage_max[hl]
	b.bullet.damage_min = ls.ranged_damage_min[hl]

	local m = E:get_template("mod_dracolich_disease")

	m.dps.damage_min = ls.disease_damage[hl]
	m.dps.damage_max = ls.disease_damage[hl]

	upgrade_skill(this, "spinerain", function(this, s)
		this.timed_attacks.list[2].disabled = nil
		b = E:get_template("dracolich_spine")
		b.bullet.damage_min = s.damage_min[s.level]
		b.bullet.damage_max = s.damage_max[s.level]
	end)
	upgrade_skill(this, "bonegolem", function(this, s)
		this.timed_attacks.list[1].disabled = nil

		local g = E:get_template("soldier_dracolich_golem")

		g.health.hp_max = s.hp_max[s.level]
		g.reinforcement.duration = s.duration[s.level]
		g.melee.attacks[1].damage_max = s.damage_max[s.level]
		g.melee.attacks[1].damage_min = s.damage_min[s.level]
	end)
	upgrade_skill(this, "plaguecarrier", function(this, s)
		this.timed_attacks.list[4].disabled = nil
		this.timed_attacks.list[4].count = s.count[s.level]

		local a = E:get_template("dracolich_plague_carrier")

		a.aura.duration = s.duration[s.level]
		E:get_template("dracolich_spine").bullet.mod = "mod_dracolich_disease"
		E:get_template("fireball_dracolich").bullet.mod = "mod_dracolich_disease"
	end)
	upgrade_skill(this, "diseasenova", function(this, s)
		local a = this.timed_attacks.list[3]

		a.disabled = nil
		a.damage_min = s.damage_min[s.level]
		a.damage_max = s.damage_max[s.level]
	end)
	upgrade_skill(this, "unstabledisease", function(this, s)
		local m = E:get_template("mod_dracolich_disease")

		m.spread_damage = s.spread_damage[s.level]
		m.spread_active = true
	end)
	update_hp(this)
end

local function hero_update(this, store)
	local h = this.health
	local a, skill, force_idle_ts

	local function skeleton_glow_fx()
		local fx = E:create_entity("fx_dracolich_skeleton_glow")

		fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].flip_x = this.render.sprites[1].flip_x
		fx.render.sprites[1].anchor.y = this.render.sprites[1].anchor.y

		simulation:queue_insert_entity(fx)
	end

	U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

	this.health_bar.hidden = false
	force_idle_ts = true

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)

			force_idle_ts = true
		end

		while this.nav_rally.new do
			SU.y_hero_new_rally(store, this)
		end

		if SU.hero_level_up(store, this) then
			U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
		end

		a = this.timed_attacks.list[1]
		skill = this.hero.skills.bonegolem

		if not a.disabled and store.tick_ts - a.ts > a.cooldown then
			local target = U.find_random_enemy(store, this.pos, a.min_range, a.max_range * 1.5, a.vis_flags, a.vis_bans, function(v)
				local offset = P:predict_enemy_node_advance(v, a.spawn_time)
				local ppos = P:node_pos(v.nav_path.pi, v.nav_path.spi, v.nav_path.ni + offset)

				return P:is_node_valid(v.nav_path.pi, v.nav_path.ni + offset, NF_RALLY) and GR:cell_is_only(ppos.x, ppos.y, TERRAIN_LAND)
			end)
			local spawn_pos

			if target then
				local offset = P:predict_enemy_node_advance(target, a.spawn_time)

				spawn_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + offset)
			else
				local positions = P:get_all_valid_pos(this.pos.x, this.pos.y, a.min_range, a.max_range, TERRAIN_LAND, nil, NF_RALLY)

				spawn_pos = table.random(positions)
			end

			if not spawn_pos then
				a.ts = a.ts + 0.4
			else
				S:queue(a.sound)
				U.animation_start_default(this, "golem", nil, store.tick_ts)
				skeleton_glow_fx()
				U.y_wait_unconditional(store, a.spawn_time)

				local e = E:create_entity(a.entity)

				e.pos = V.vclone(spawn_pos)
				e.nav_rally.pos = V.vclone(spawn_pos)
				e.nav_rally.center = V.vclone(spawn_pos)
				e.render.sprites[1].flip_x = math.random() < 0.5

				simulation:queue_insert_entity(e)

				e.owner = this

				U.y_animation_wait_default(this)

				force_idle_ts = true
				a.ts = store.tick_ts

				SU.hero_gain_xp_from_skill(this, skill)

				goto label_407_1
			end
		end

		a = this.timed_attacks.list[2]
		skill = this.hero.skills.spinerain

		if not a.disabled and store.tick_ts - a.ts > a.cooldown then
			local target = U.find_random_enemy(store, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

			if not target then
				a.ts = a.ts + 0.4
			else
				local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni
				local nodes = P:nearest_nodes(this.pos.x, this.pos.y, {pi}, nil, nil, NF_RALLY)

				if #nodes < 1 then
					a.ts = a.ts + 0.4
				else
					local s_pi, _, s_ni = unpack(nodes[1])
					local flip = target.pos.x < this.pos.x

					U.animation_start_default(this, "spinerain", flip, store.tick_ts)
					skeleton_glow_fx()
					U.y_wait_unconditional(store, a.spawn_time)

					local delay = 0
					local n_step = ni < s_ni and -2 or 2

					ni = km.clamp(1, #P:path(s_pi), ni < s_ni and ni + 6 or ni)

					for i = 1, skill.count[skill.level] do
						local e = E:create_entity(a.entity)

						e.pos = P:node_pos(pi, spi, ni)
						e.render.sprites[1].prefix = e.render.sprites[1].prefix .. math.random(1, 3)
						e.render.sprites[1].flip_x = not flip
						e.delay = delay
						e.bullet.source_id = this.id

						simulation:queue_insert_entity(e)

						delay = delay + fts(U.frandom(1, 3))
						ni = ni + n_step
						spi = km.zmod(spi + math.random(1, 2), 3)
					end

					U.y_animation_wait_default(this)

					force_idle_ts = true
					a.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, skill)

					goto label_407_1
				end
			end
		end

		a = this.timed_attacks.list[3]
		skill = this.hero.skills.diseasenova

		if not a.disabled and store.tick_ts - a.ts > a.cooldown then
			local targets = U.find_enemies_between_range_filter_off(this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

			if not targets or #targets < a.min_count then
				a.ts = a.ts + 0.4
			else
				this.health_bar.hidden = true
				this.health.ignore_damage = true

				U.animation_start_default(this, "nova", nil, store.tick_ts)
				S:queue(a.sound, {
					delay = fts(10)
				})
				U.y_wait_unconditional(store, a.hit_time)

				for _, target in ipairs(targets) do
					local d = E.assign_damage(a.damage_type, math.random(a.damage_min, a.damage_max), this.id, target.id)

					queue_damage(store, d)

					if a.mod then
						local m = E:create_entity(a.mod)

						m.modifier.source_id = this.id
						m.modifier.target_id = target.id
						m.modifier.xp_dest_id = this.id

						simulation:queue_insert_entity(m)
					end
				end

				local fi, fo = 10, 35

				for i = 1, 6 do
					local rx, ry = V.rotate(2 * math.pi * i / 6, 1, 0)
					local fx = E:create_entity("fx_dracolich_nova_cloud")

					fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
					fx.tween.props[2].keys = {{0, V.v(rx * fi, ry * fi)}, {fts(20), V.v(rx * fo, ry * fo)}}
					fx.tween.ts = store.tick_ts

					simulation:queue_insert_entity(fx)
				end

				local fx = E:create_entity("fx_dracolich_nova_explosion")

				fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
				fx.render.sprites[1].ts = store.tick_ts

				simulation:queue_insert_entity(fx)

				local fx = E:create_entity("fx_dracolich_nova_decal")

				fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
				fx.render.sprites[1].ts = store.tick_ts

				simulation:queue_insert_entity(fx)
				U.y_animation_wait_default(this)

				this.render.sprites[1].hidden = true

				U.y_wait_unconditional(store, a.respawn_delay)

				this.render.sprites[1].hidden = nil

				S:queue(a.respawn_sound)
				U.y_animation_play(this, "respawn", nil, store.tick_ts)

				this.health_bar.hidden = false
				this.health.ignore_damage = false
				force_idle_ts = true
				a.ts = store.tick_ts

				SU.hero_gain_xp_from_skill(this, skill)
			end
		end

		a = this.timed_attacks.list[4]
		skill = this.hero.skills.plaguecarrier

		if not a.disabled and store.tick_ts - a.ts > a.cooldown then
			local targets_info = U.find_enemies_in_paths(store.enemies, this.pos, a.range_nodes_min, a.range_nodes_max, nil, a.vis_flags, a.vis_bans)

			if not targets_info then
				a.ts = a.ts + 0.4
			else
				local target

				for _, ti in ipairs(targets_info) do
					if GR:cell_is(ti.enemy.pos.x, ti.enemy.pos.y, TERRAIN_LAND) then
						target = ti.enemy

						break
					end
				end

				if not target then
					a.ts = a.ts + 0.4
				else
					local pi, _, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni
					local nodes = P:nearest_nodes(this.pos.x, this.pos.y, {pi}, nil, nil, NF_RALLY)

					if #nodes < 1 then
						a.ts = a.ts + 0.4
					else
						local s_pi, s_spi, s_ni = unpack(nodes[1])
						local dir = ni < s_ni and -1 or 1
						local offset = math.random(a.range_nodes_min, a.range_nodes_min + 5)

						s_ni = km.clamp(1, #P:path(s_pi), s_ni + (dir > 0 and offset or -offset))

						local flip = P:node_pos(s_pi, s_spi, s_ni, true).x < this.pos.x

						S:queue(a.sound)
						U.animation_start_default(this, "plague", flip, store.tick_ts)
						U.y_wait_unconditional(store, a.spawn_time)

						local delay = 0

						for i = 1, a.count do
							local e = E:create_entity(a.entity)

							e.pos.x, e.pos.y = this.pos.x + (flip and -1 or 1) * a.spawn_offset.x, this.pos.y + a.spawn_offset.y
							e.nav_path.pi = s_pi
							e.nav_path.spi = math.random(1, 3)
							e.nav_path.ni = s_ni
							e.nav_path.dir = dir
							e.delay = delay
							e.aura.source_id = this.id

							simulation:queue_insert_entity(e)

							delay = delay + fts(U.frandom(1, 3))
						end

						U.y_animation_wait_default(this)

						force_idle_ts = true
						a.ts = store.tick_ts

						SU.hero_gain_xp_from_skill(this, skill)

						goto label_407_1
					end
				end
			end
		end

		for _, i in pairs(this.ranged.order) do
			local a = this.ranged.attacks[i]

			if a.disabled then
			-- block empty
			elseif a.sync_animation and not this.render.sprites[1].sync_flag then
			-- block empty
			elseif store.tick_ts - a.ts < a.cooldown then
			-- block empty
			elseif math.random() > a.chance then
			-- block empty
			else
				local origin = V.v(this.pos.x, this.pos.y + a.bullet_start_offset[1].y)
				local bullet_t = E:get_template(a.bullet)
				local bullet_speed = bullet_t.bullet.min_speed
				local target = U.find_random_enemy(store, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if target then
					local start_ts = store.tick_ts
					local b, _, _
					local dist = V.dist(origin.x, origin.y, target.pos.x, target.pos.y)
					local node_offset = P:predict_enemy_node_advance(target, dist / bullet_speed)
					local t_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + node_offset)
					local an, af, ai = U.animation_name_facing_point(this, a.animation, t_pos)

					U.animation_start_default(this, an, af, store.tick_ts)

					while store.tick_ts - start_ts < a.shoot_time do
						if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
							goto label_407_0
						end

						coroutine.yield()
					end

					S:queue(a.sound)

					b = E:create_entity(a.bullet)
					b.bullet.target_id = target.id
					b.bullet.source_id = this.id

					b.pos:copy(this.pos)

					b.pos.x = b.pos.x + (af and -1 or 1) * a.bullet_start_offset[ai].x
					b.pos.y = b.pos.y + a.bullet_start_offset[ai].y

					b.bullet.from:copy(b.pos)

					b.bullet.to = V.v(t_pos.x, t_pos.y)

					simulation:queue_insert_entity(b)

					a.ts = start_ts

					while not U.animation_finished_default(this) do
						if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
							goto label_407_0
						end

						coroutine.yield()
					end

					force_idle_ts = true

					::label_407_0::

					goto label_407_1
				end
			end
		end

		SU.soldier_idle(store, this, force_idle_ts)
		SU.soldier_regen(store, this)

		force_idle_ts = nil

		::label_407_1::

		coroutine.yield()
	end
end

local function mod_dracolich_disease_remove(this, store)
	local target = store.entities[this.modifier.target_id]

	if this.spread_active and target and target.health.dead and band(target.health.last_damage_types, DAMAGE_EAT) == 0 then
		local targets = U.find_enemies_in_range_filter_off(this.pos, this.spread_radius, this.modifier.vis_flags, this.modifier.vis_bans)

		if targets then
			for _, t in ipairs(targets) do
				local m = E:create_entity(this.template_name)

				m.modifier.target_id = t.id
				m.modifier.source_id = this.modifier.source_id
				m.modifier.xp_dest_id = this.modifier.xp_dest_id

				simulation:queue_insert_entity(m)

				local d = E.assign_damage(this.dps.damage_type, this.spread_damage, this.id, t.id)

				queue_damage(store, d)

				local h = store.entities[this.modifier.xp_dest_id]

				if h and h.hero then
					SU.hero_gain_xp_from_skill(h, h.hero.skills.unstabledisease)
				end
			end
		end

		local fx = E:create_entity(this.spread_fx)

		fx.pos:copy(this.pos)

		if target and this.modifier.use_mod_offset and target.unit.mod_offset then
			local mo = target.unit.mod_offset

			fx.pos.x, fx.pos.y = fx.pos.x + mo.x, fx.pos.y + mo.y
		end

		fx.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(fx)
	end

	return true
end

local function dracolich_spine_update(this, store)
	local b = this.bullet

	U.sprites_hide(this)

	if this.delay then
		U.y_wait_unconditional(store, this.delay)
	end

	U.sprites_show(this)

	local start_ts = store.tick_ts

	this.pos.x = this.pos.x + math.random(-4, 4)
	this.pos.y = this.pos.y + math.random(-5, 5)

	S:queue(this.sound_events.delayed_insert)
	U.animation_start(this, "start", nil, store.tick_ts, false, 1)

	this.tween.ts = store.tick_ts

	U.y_wait_unconditional(store, b.hit_time)

	local targets = U.find_enemies_in_range_filter_off(this.pos, b.damage_radius, b.damage_flags, b.damage_bans)

	if targets then
		for _, target in ipairs(targets) do
			local d = E.assign_damage(b.damage_type, math.random(b.damage_min, b.damage_max), this.id, target.id)

			queue_damage(store, d)

			if b.mod then
				local m = E:create_entity(b.mod)

				m.modifier.source_id = this.id
				m.modifier.target_id = target.id
				m.modifier.xp_dest_id = b.source_id

				simulation:queue_insert_entity(m)
			end
		end
	end

	U.y_wait_unconditional(store, b.duration - (store.tick_ts - start_ts))
	U.y_animation_play(this, "end", nil, store.tick_ts, 1, 1)
	simulation:queue_remove_entity(this)
end

local function dracolich_plague_carrier_insert(this, store)
	local next_pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)

	if not next_pos then
		return false
	end

	return true
end

local function dracolich_plague_carrier_update(this, store)
	local y_off = 20
	local a = this.aura
	local m = this.motion
	local nav = this.nav_path
	local dt = store.tick_length
	local start_ts = store.tick_ts
	local hit_ts = 0

	a.duration = a.duration + U.frandom(-a.duration_var, 0)
	m.max_speed = m.max_speed + math.random(0, m.max_speed_var)

	local step = this.motion.real_speed * dt
	local next_pos = P:node_pos(nav.pi, nav.spi, nav.ni)

	next_pos.y = next_pos.y + y_off

	U.set_destination(this, next_pos)

	local v_heading = v(0, 0)

	v_heading.x, v_heading.y = V.normalize(next_pos.x - this.pos.x, next_pos.y - this.pos.y)

	local th_dist = 25
	local turn_speed = math.pi * 1.5
	local enemies_hit = {}

	if this.delay then
		this.render.sprites[1].hidden = true

		U.y_wait_unconditional(store, this.delay)

		this.render.sprites[1].hidden = nil
	end

	local ps = E:create_entity("ps_dracolich_plague")

	ps.particle_system.track_id = this.id

	simulation:queue_insert_entity(ps)

	while true do
		if this.tween.disabled and store.tick_ts - start_ts > a.duration then
			this.tween.disabled = nil
			this.tween.ts = store.tick_ts
			ps.particle_system.emit = false
		end

		if th_dist > V.len(m.dest.x - this.pos.x, m.dest.y - this.pos.y) then
			nav.ni = nav.ni + math.random(6, 11) * nav.dir

			local p_len = #P:path(nav.pi)

			if nav.ni <= 1 or p_len <= nav.ni then
				a.duration = 0
			end

			nav.ni = km.clamp(1, p_len, nav.ni)
			nav.spi = km.zmod(nav.spi + math.random(1, 2), 3)
			next_pos = P:node_pos(nav.pi, nav.spi, nav.ni)
			next_pos.y = next_pos.y + y_off

			U.set_destination(this, next_pos)
		end

		local dx, dy = V.sub(m.dest.x, m.dest.y, this.pos.x, this.pos.y)
		local sa = km.short_angle(V.angleTo(dx, dy), V.angleTo(v_heading.x, v_heading.y))
		local angle_step = math.min(turn_speed * dt, math.abs(sa)) * km.sign(sa) * -1

		v_heading.x, v_heading.y = V.rotate(angle_step, v_heading.x, v_heading.y)

		local sx, sy = V.mul(step, v_heading.x, v_heading.y)

		this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, sx, sy)
		m.speed.x, m.speed.y = sx / dt, sy / dt
		this.render.sprites[1].r = V.angleTo(v_heading.x, v_heading.y)

		if store.tick_ts - hit_ts > a.damage_cycle then
			hit_ts = store.tick_ts

			local targets = U.find_enemies_in_range_filter_on(this.pos, a.damage_radius, a.damage_flags, a.damage_bans, function(v)
				return not table.contains(enemies_hit, v)
			end)

			if not targets then
			-- block empty
			else
				for _, e in ipairs(targets) do
					local d = E.assign_damage(a.damage_type, math.random(a.damage_min, a.damage_max), this.id, e.id)

					queue_damage(store, d)

					if a.mod then
						local m = E:create_entity(a.mod)

						m.modifier.source_id = this.id
						m.modifier.target_id = e.id
						m.modifier.xp_dest_id = a.source_id

						simulation:queue_insert_entity(m)
					end

					table.insert(enemies_hit, e)
				end
			end
		end

		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

local tt

tt = RT("hero_dracolich", "hero")

AC(tt, "ranged", "timed_attacks")

tt.hero.level_stats.hp_max = {425, 450, 475, 500, 525, 550, 575, 600, 625, 650}
tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.ranged_damage_min = {6, 8, 9, 11, 12, 14, 15, 17, 18, 20}
tt.hero.level_stats.ranged_damage_max = {18, 23, 27, 32, 36, 41, 45, 50, 54, 59}
tt.hero.level_stats.disease_damage = {2, 2, 3, 3, 4, 4, 5, 5, 6, 6}
tt.hero.skills.spinerain = CC("hero_skill")
tt.hero.skills.spinerain.count = {6, 8, 10}
tt.hero.skills.spinerain.damage_min = {12, 16, 20}
tt.hero.skills.spinerain.damage_max = {36, 40, 44}
tt.hero.skills.spinerain.xp_gain = {20, 35, 50}
tt.hero.skills.spinerain.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.hero.skills.bonegolem = CC("hero_skill")
tt.hero.skills.bonegolem.hp_max = {80, 120, 160}
tt.hero.skills.bonegolem.damage_min = {2, 4, 6}
tt.hero.skills.bonegolem.damage_max = {6, 8, 10}
tt.hero.skills.bonegolem.duration = {20, 30, 40}
tt.hero.skills.bonegolem.xp_gain = {20, 35, 50}
tt.hero.skills.bonegolem.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.plaguecarrier = CC("hero_skill")
tt.hero.skills.plaguecarrier.xp_gain = {20, 35, 50}
tt.hero.skills.plaguecarrier.count = {6, 8, 10}
tt.hero.skills.plaguecarrier.duration = {4, 5, 6}
tt.hero.skills.plaguecarrier.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.diseasenova = CC("hero_skill")
tt.hero.skills.diseasenova.xp_gain = {20, 35, 50}
tt.hero.skills.diseasenova.damage_min = {50, 100, 150}
tt.hero.skills.diseasenova.damage_max = {50, 100, 150}
tt.hero.skills.diseasenova.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.unstabledisease = CC("hero_skill")
tt.hero.skills.unstabledisease.spread_damage = {30, 60, 90}
tt.hero.skills.unstabledisease.xp_gain = {20, 35, 50}
tt.hero.skills.unstabledisease.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.health.armor = nil
tt.health.dead_lifetime = 15
tt.health.hp_max = nil
tt.health_bar.offset = vec_2(0, 157)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.health_bar.draw_order = -1
tt.health_bar.sort_y_offset = -200
tt.hero.fn_level_up = hero_level_up
tt.idle_flip.cooldown = 10
tt.info.hero_portrait = "kr2_hero_portraits_0014"
tt.info.portrait = "kr2_info_portraits_heroes_0014"
tt.main_script.update = hero_update
tt.motion.max_speed = 100
tt.nav_rally.requires_node_nearby = false
tt.nav_grid.ignore_waypoints = true
tt.nav_grid.valid_terrains = TERRAIN_ALL_MASK
tt.nav_grid.valid_terrains_dest = TERRAIN_ALL_MASK
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.12962962962962962
tt.render.sprites[1].prefix = "hero_dracolich"
tt.render.sprites[1].angles.walk = {"idle"}
tt.render.sprites[1].sort_y_offset = -200
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "Halloween_hero_bones_layer1_0160"
tt.render.sprites[2].anchor.y = 0.12962962962962962
tt.render.sprites[2].alpha = 100
tt.sound_events.change_rally_point = "HeroDracolichTaunt"
tt.sound_events.death = "HeroDracolichDeath"
tt.sound_events.respawn = "HeroDracolichRespawn"
tt.sound_events.insert = "HeroDracolichTauntIntro"
tt.sound_events.hero_room_select = "HeroDracolichTauntSelect"
tt.ui.click_rect = r(-25, 70, 50, 45)
tt.unit.blood_color = BLOOD_GRAY
tt.unit.hit_offset = vec_2(0, 98)
tt.unit.hide_after_death = true
tt.unit.marker_offset = vec_2(0, -0.15)
tt.unit.mod_offset = vec_2(0, 101)
tt.vis.bans = bor(tt.vis.bans, F_EAT, F_NET, F_POISON)
tt.vis.flags = bor(tt.vis.flags, F_FLYING)
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].bullet = "fireball_dracolich"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(35, 85)}
tt.ranged.attacks[1].cooldown = 1.3
tt.ranged.attacks[1].max_range = 120
tt.ranged.attacks[1].shoot_time = fts(16)
tt.ranged.attacks[1].sync_animation = true
tt.ranged.attacks[1].ignore_hit_offset = true
tt.ranged.attacks[1].animation = "range_attack"
tt.ranged.attacks[1].estimated_flight_time = 1
tt.ranged.attacks[1].sound = "HeroDracolichAttack"
tt.timed_attacks.list[1] = CC("spawn_attack")
tt.timed_attacks.list[1].animation = "golem"
tt.timed_attacks.list[1].cooldown = 13.5
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].entity = "soldier_dracolich_golem"
tt.timed_attacks.list[1].sound = "HeroDracolichSpawnDog"
tt.timed_attacks.list[1].spawn_time = fts(10)
tt.timed_attacks.list[1].vis_flags = F_BLOCK
tt.timed_attacks.list[1].min_range = 25
tt.timed_attacks.list[1].max_range = 75
tt.timed_attacks.list[2] = CC("spawn_attack")
tt.timed_attacks.list[2].animation = "spinerain"
tt.timed_attacks.list[2].cooldown = 18
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].entity = "dracolich_spine"
tt.timed_attacks.list[2].spawn_time = fts(11)
tt.timed_attacks.list[2].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[2].min_range = 0
tt.timed_attacks.list[2].max_range = 125
tt.timed_attacks.list[3] = CC("area_attack")
tt.timed_attacks.list[3].animation = "nova"
tt.timed_attacks.list[3].cooldown = 26.1
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].damage_max = nil
tt.timed_attacks.list[3].damage_min = nil
tt.timed_attacks.list[3].damage_type = DAMAGE_TRUE
tt.timed_attacks.list[3].hit_time = fts(20)
tt.timed_attacks.list[3].max_range = 75
tt.timed_attacks.list[3].min_count = 3
tt.timed_attacks.list[3].sound = "HeroDracolichKamikaze"
tt.timed_attacks.list[3].respawn_delay = 1
tt.timed_attacks.list[3].respawn_sound = "HeroDracolichRespawn"
tt.timed_attacks.list[3].mod = "mod_dracolich_disease"
tt.timed_attacks.list[4] = CC("spawn_attack")
tt.timed_attacks.list[4].animation = "plague"
tt.timed_attacks.list[4].cooldown = 18
tt.timed_attacks.list[4].disabled = true
tt.timed_attacks.list[4].entity = "dracolich_plague_carrier"
tt.timed_attacks.list[4].spawn_offset = vec_2(43, 81)
tt.timed_attacks.list[4].spawn_time = fts(11)
tt.timed_attacks.list[4].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[4].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[4].range_nodes_max = 50
tt.timed_attacks.list[4].range_nodes_min = 10
tt.timed_attacks.list[4].sound = "HeroDracolichSoulsPlague"
tt = RT("fx_fireball_dracolich_decal", "decal_tween")
tt.render.sprites[1].name = "Halloween_hero_bones_proyExplosion_decal"
tt.render.sprites[1].animated = false
tt.tween.props[1].keys = {{fts(17), 255}, {fts(27), 0}}
tt = RT("fx_fireball_dracolich_ground", "fx")
tt.render.sprites[1].name = "fx_dracolich_fireball_explosion_ground"
tt.render.sprites[1].anchor.y = 0.20512820512820512
tt.render.sprites[1].sort_y_offset = -5
tt = RT("fx_fireball_dracolich_air", "fx")
tt.render.sprites[1].name = "fx_dracolich_fireball_explosion_air"
tt.render.sprites[1].anchor.y = 0.24
tt.render.sprites[1].scale = vec_2(0.7, 0.7)
tt = RT("ps_fireball_dracolich")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "dracolich_fireball_particle_1"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(10), fts(16)}
tt.particle_system.scale_var = {0.78, 1.43}
tt.particle_system.scales_x = {1, 1.25}
tt.particle_system.scales_y = {1, 1.25}
tt.particle_system.emission_rate = 20
tt.particle_system.emit_rotation_spread = math.pi
tt.particle_system.alphas = {255, 0}
tt = RT("fireball_dracolich", "bullet")
tt.render.sprites[1].name = "Halloween_hero_bones_proy"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.x = 0.69
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.min_speed = 390
tt.bullet.max_speed = 390
tt.bullet.hit_fx = "fx_fireball_dracolich_ground"
tt.bullet.hit_fx_air = "fx_fireball_dracolich_air"
tt.bullet.hit_decal = "fx_fireball_dracolich_decal"
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.damage_radius = 40
tt.bullet.xp_gain_factor = 2.5
tt.bullet.particles_name = "ps_fireball_dracolich"
tt.main_script.update = scripts.fireball_dragon.update
tt.sound_events.hit = "HeroDragonAttackHit"
tt = RT("mod_dracolich_disease", "modifier")

AC(tt, "render", "dps")

tt.modifier.duration = 4
tt.modifier.vis_flags = F_MOD
tt.render.sprites[1].prefix = "dracolich_disease"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.render.sprites[1].name = "small"
tt.render.sprites[1].draw_order = 2
tt.dps.damage_min = nil
tt.dps.damage_max = nil
tt.dps.damage_type = DAMAGE_TRUE
tt.spread_active = false
tt.spread_radius = 60
tt.spread_fx = "fx_dracolich_disease_explosion"
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt.main_script.remove = mod_dracolich_disease_remove
tt = RT("fx_dracolich_disease_explosion", "fx")
tt.render.sprites[1].name = "dracolich_disease_explosion"
tt = RT("fx_dracolich_skeleton_glow", "fx")
tt.render.sprites[1].name = "fx_dracolich_skeleton_glow"
tt = RT("dracolich_spine", "bullet")

AC(tt, "tween")

tt.main_script.update = dracolich_spine_update
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.damage_radius = 50
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_bans = F_FRIEND
tt.bullet.hit_time = fts(4)
tt.bullet.duration = 2
tt.render.sprites[1].prefix = "dracolich_spine"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].anchor.y = 0.09027777777777778
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "Halloween_hero_bones_attackDecal"
tt.render.sprites[2].z = Z_DECALS
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {fts(3), 0}, {fts(6), 255}, {tt.bullet.duration, 255}, {tt.bullet.duration + fts(10), 0}}
tt.tween.props[1].sprite_id = 2
tt.sound_events.delayed_insert = "HeroDracolichBoneRain"
tt = RT("fx_dracolich_nova_cloud", "decal_tween")
tt.render.sprites[1].name = "Halloween_hero_bones_particle"
tt.render.sprites[1].animated = false
tt.render.sprites[1].scale = vec_2(0.75, 0.75)
tt.tween.props[1].keys = {{0, 127}, {fts(20), 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "offset"
tt.tween.props[2].keys = {}
tt = RT("fx_dracolich_nova_explosion", "fx")
tt.render.sprites[1].name = "fx_dracolich_explosion"
tt.render.sprites[1].anchor.y = 0.2
tt.render.sprites[1].sort_y_offset = -1
tt = RT("fx_dracolich_nova_decal", "decal_tween")
tt.render.sprites[1].name = "Halloween_hero_bones_explosion_decal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{fts(40), 255}, {fts(45), 0}}
tt = RT("dracolich_plague_carrier", "aura")

AC(tt, "render", "nav_path", "motion", "tween")

tt.aura.duration = nil
tt.aura.duration_var = 0.5
tt.aura.damage_min = 10
tt.aura.damage_max = 15
tt.aura.damage_radius = 45
tt.aura.damage_type = DAMAGE_TRUE
tt.aura.damage_cycle = fts(3)
tt.aura.damage_flags = F_AREA
tt.aura.damage_bans = 0
tt.aura.mod = "mod_dracolich_disease"
tt.motion.max_speed = 3.5 * FPS
tt.motion.max_speed_var = 0.25 * FPS
tt.main_script.insert = dracolich_plague_carrier_insert
tt.main_script.update = dracolich_plague_carrier_update
tt.render.sprites[1].name = "dracolich_plague_carrier"
tt.render.sprites[1].sort_y_offset = -21
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {tt.aura.duration_var, 0}}
tt = RT("ps_dracolich_plague", "ps_bolt_necromancer_trail")
tt.particle_system.particle_lifetime = {fts(15), fts(25)}
tt.particle_system.scales_x = {0.75, 2.5}
tt.particle_system.scales_y = {0.75, 2.5}
tt.particle_system.scale_var = {0.5, 1}
tt.particle_system.emission_rate = 10
tt.particle_system.sort_y_offset = -20
tt.particle_system.z = Z_OBJECTS
tt = RT("soldier_dracolich_golem", "soldier")

AC(tt, "melee", "nav_grid", "reinforcement")

tt.info.portrait = "kr2_info_portraits_soldiers_0018"
tt.health.hp_max = 80
tt.health_bar.offset = vec_2(0, 36)
tt.reinforcement.duration = nil
tt.reinforcement.fade = false
tt.info.fn = scripts.soldier_barrack.get_info
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.soldier_reinforcement.update
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_max = 6
tt.melee.attacks[1].damage_min = 2
tt.melee.attacks[1].hit_time = fts(7)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF, F_WATER)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.range = 85
tt.motion.max_speed = 60
tt.render.sprites[1].anchor.y = 0.16666666666666666
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].prefix = "soldier_dracolich_golem"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"running"}
tt.soldier.melee_slot_offset.x = 20
tt.sound_events.death = "DeathSkeleton"
tt.unit.blood_color = BLOOD_GRAY
tt.unit.hit_offset = vec_2(0, 12)
tt.unit.mod_offset = vec_2(0, 18)
tt.unit.explode_fx = nil
tt.vis.bans = bor(F_POISON, F_SKELETON, F_LYCAN, F_CANNIBALIZE)
