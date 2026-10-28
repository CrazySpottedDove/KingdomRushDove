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
local band = bit.band
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
local tt

local function fireball_eiskalt_remove(this, store)
	local target = store.entities[this.bullet.target_id]

	if not target or band(target.vis.flags, F_FLYING) == 0 then
		for i = 1, 3 do
			local fx = E:create_entity(this.bullet.hit_fx)
			local angle = 2 * math.pi * i / 3

			fx.pos:set(this.bullet.to.x + this.bullet.damage_radius * 0.25 * math.cos(angle), this.bullet.to.y + this.bullet.damage_radius * 0.25 * math.sin(angle))

			fx.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(fx)
		end
	else
		for i = 1, 3 do
			local fx = E:create_entity(this.bullet.hit_fx_air)
			local angle = 2 * math.pi * i / 3

			fx.pos:set(this.bullet.to.x + this.bullet.damage_radius * 0.25 * math.cos(angle), this.bullet.to.y + this.bullet.damage_radius * 0.25 * math.sin(angle))

			fx.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(fx)
		end
	end

	return true
end

local function aura_eiskalt_skill_rider_update(this, store)
	local last_hit_ts = 0
	local sid_rider = 1
	local target_pos = this.pos
	local path_ni = 1
	local path_spi = 1
	local path_pi = 1
	local available_paths = {}

	for k, v in pairs(P.paths) do
		table.insert(available_paths, k)
	end

	if store.level.ignore_walk_backwards_paths then
		available_paths = table.filter(available_paths, function(k, v)
			return not table.contains(store.level.ignore_walk_backwards_paths, v)
		end)
	end

	local nearest = P:nearest_nodes(this.pos.x, this.pos.y, available_paths)

	if #nearest > 0 then
		path_pi, path_spi, path_ni = unpack(nearest[1])

		for _, n in ipairs(nearest) do
			local _path_pi, _path_spi, _path_ni = unpack(n)

			if _path_pi == this.path_id then
				path_pi, path_spi, path_ni = _path_pi, _path_spi, _path_ni

				break
			end
		end
	end

	path_spi = 1
	path_ni = path_ni - 3

	local distance = 0

	last_hit_ts = store.tick_ts - this.aura.cycle_time

	if this.aura.apply_delay then
		last_hit_ts = last_hit_ts + this.aura.apply_delay
	end

	local function hit_enemies()
		local targets = U.find_enemies_in_range_filter_off(this.pos, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans)

		if targets then
			for i, target in ipairs(targets) do
				local d = E.assign_damage(this.damage_type, math.random(this.aura.damage_min, this.aura.damage_max) * this.aura.damage_factor, this.id, target.id)

				queue_damage(store, d)

				if target.unit.blood_color ~= BLOOD_NONE then
					local sfx = E:create_entity(this.hit_blood_fx)

					sfx.pos:set(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)

					sfx.render.sprites[1].ts = store.tick_ts

					if sfx.use_blood_color and target.unit.blood_color then
						sfx.render.sprites[1].name = target.unit.blood_color
						sfx.render.sprites[1].r = this.render.sprites[1].r
					end

					sfx.sound_events = nil

					simulation:queue_insert_entity(sfx)
				end
			end
		end
	end

	path_ni = path_ni - 3
	target_pos = P:node_pos(path_pi, path_spi, path_ni)

	local flip_x = target_pos.x < this.pos.x

	U.animation_start(this, "spawn", flip_x, store.tick_ts, false, sid_rider)
	hit_enemies()

	local psA = E:create_entity(this.particles_name_A)

	psA.particle_system.track_id = this.id
	psA.particle_system.emit = true

	simulation:queue_insert_entity(psA)

	local psB = E:create_entity(this.particles_name_B)

	psB.particle_system.track_id = this.id
	psB.particle_system.emit = true

	simulation:queue_insert_entity(psB)

	local function rider_go_back_step()
		if V.veq(this.pos, target_pos) then
			this.motion.arrived = true

			return false
		else
			U.set_destination(this, target_pos)

			if U.walk(this, store.tick_length) then
				return false
			else
				local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)

				U.animation_start(this, an, af, store.tick_ts, true, sid_rider)

				return true
			end
		end
	end

	local function run_backwards()
		local last_pos = this.pos

		distance = V.dist2(target_pos.x, target_pos.y, this.pos.x, this.pos.y)

		if distance < 25 then
			path_ni = path_ni - 3
			target_pos = P:node_pos(path_pi, path_spi, path_ni)
		end

		rider_go_back_step()

		local r = V.angleTo(target_pos.x - last_pos.x, target_pos.y - last_pos.y)

		psA.particle_system.emit_offset.x, psA.particle_system.emit_offset.y = V.rotate(r, psA.emit_offset_relative.x, psA.emit_offset_relative.y)
		psB.particle_system.emit_offset.x, psB.particle_system.emit_offset.y = V.rotate(r, psB.emit_offset_relative.x, psB.emit_offset_relative.y)
	end

	local function no_available_nodes()
		local nearest = P:nearest_nodes(this.pos.x, this.pos.y, available_paths)

		if #nearest > 0 then
			path_pi, path_spi, path_ni = unpack(nearest[1])

			return path_ni < 2
		else
			return false
		end
	end

	while true do
		this.render.sprites[1].offset.y = 0

		if this.aura.duration >= 0 and store.tick_ts - this.aura.ts > this.actual_duration or no_available_nodes() then
			break
		end

		if store.tick_ts - last_hit_ts >= this.aura.cycle_time then
			last_hit_ts = store.tick_ts

			hit_enemies()
		end

		run_backwards()

		::label_651_0::

		coroutine.yield()
	end

	psA.particle_system.emit = false
	psB.particle_system.emit = false

	U.y_animation_play(this, "death", nil, store.tick_ts, 1, sid_rider)

	this.tween.disabled = false
	this.tween.ts = store.tick_ts
end

local function eiskalt_icepeaks_update(this, store)
	local b = this.bullet

	U.sprites_hide(this)

	if this.delay then
		U.y_wait_unconditional(store, this.delay)
	end

	U.sprites_show(this)

	local start_ts = store.tick_ts

	S:queue(this.sound_events.delayed_insert)
	U.animation_start_default(this, "in", nil, store.tick_ts, false)

	this.tween.ts = store.tick_ts

	U.y_wait_unconditional(store, b.hit_time)

	local targets = U.find_enemies_in_range_filter_off(this.pos, b.damage_radius, b.damage_flags, b.damage_bans)

	if targets then
		for _, target in ipairs(targets) do
			if target._icepeak_timestamp ~= this._icepeak_timestamp then
				target._icepeak_timestamp = this._icepeak_timestamp

				local d = E.assign_damage(b.damage_type, target.health.hp_max * 0.1 * b.level, this.id, target.id)

				queue_damage(store, d)

				for i = 1, #b.mods do
					local mod_name = b.mods[i]

					if U.flags_pass(target.vis, E:get_template(mod_name).modifier) then
						local m = E:create_entity(mod_name)

						m.modifier.target_id = target.id
						m.modifier.level = b.level
						m.modifier.damage_factor = b.damage_factor

						simulation:queue_insert_entity(m)
					end
				end
			end
		end
	end

	U.y_wait_unconditional(store, b.duration - (store.tick_ts - start_ts))
	U.y_animation_play(this, "out", nil, store.tick_ts, false)
	simulation:queue_remove_entity(this)
end

local function eiskalt_cold_fury_smoke_update(this, store)
	U.sprites_hide(this)

	if this.delay then
		U.y_wait_unconditional(store, this.delay)
	end

	for _, s in ipairs(this.render.sprites) do
		s.ts = store.tick_ts
	end

	U.sprites_show(this)

	this.tween.disabled = false
	this.tween.ts = store.tick_ts
end

local function hero_eiskalt_level_up(this, store)
	local hl, ls = level_up_basic(this)
	local b = E:get_template(this.ranged.attacks[1].bullet)

	b.bullet.damage_max = ls.ranged_damage_max[hl]
	b.bullet.damage_min = ls.ranged_damage_min[hl]

	upgrade_skill(this, "explosion", function(this, s)
		local b = E:get_template("fireball_eiskalt")

		b.bullet.damage_radius = s.damage_radius[s.level]
		b.bullet.xp_gain_factor = 1.08
	end)
	upgrade_skill(this, "coldfury", function(this, s)
		this.timed_attacks.list[3].disabled = nil
		this.timed_attacks.list[3].cooldown = s.cooldown_time[s.level]
	end)
	upgrade_skill(this, "frosty", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil

		local e = E:get_template("aura_eiskalt_rider")

		e.aura.damage_min = s.damage_min[s.level]
		e.aura.damage_max = s.damage_max[s.level]
	end)
	upgrade_skill(this, "icepeak", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		this.ultimate.disabled = nil

		local u = E:get_template("hero_eiskalt_ultimate")

		u.duration = s.duration[s.level]
	end)
	update_hp(this)
end

local function hero_eiskalt_update(this, store)
	local h = this.health

	local function icepeak_filter_fn(e)
		return e.health.hp_max >= BIG_ENEMY_HP
	end

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		while this.nav_rally.new do
			SU.y_hero_new_rally(store, this)
		end

		if SU.hero_level_up(store, this) then
			U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
		end

		-- 大招
		if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
			local enemy = find_target_at_critical_moment(this, this.ranged.attacks[1].max_range, F_RANGED, F_NONE)

			if enemy and enemy.pos then
				this.ultimate.ts = store.tick_ts

				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
				S:queue(this.sound_events.change_rally_point)

				local e = E:create_entity(this.hero.skills.ultimate.controller_name)

				e.damage_factor = this.unit.damage_factor
				e.pos = V.vclone(enemy.pos)
				e.level = this.hero.skills.ultimate.level

				simulation:queue_insert_entity(e)
				SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
			else
				this.ultimate.ts = this.ultimate.ts + 1
			end
		end

		-- 冰刺
		local a = this.timed_attacks.list[2]
		local skill = this.hero.skills.icepeak

		if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
			local target = U.find_nearest_enemy(store, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans, icepeak_filter_fn)

			if target then
				local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni
				local nodes = P:nearest_nodes(this.pos.x, this.pos.y, {pi}, nil, nil, NF_RALLY)

				if #nodes > 0 then
					local flip = target.pos.x < this.pos.x
					local start_ts = store.tick_ts

					U.animation_start_default(this, "icePeaks", flip, store.tick_ts)

					if SU.y_hero_wait(store, this, a.spawn_time) then
						goto eiskalt_attack_end
					end

					local n_step = ni < nodes[1][3] and -4 or 4

					ni = km.clamp(1, #P.paths[pi][spi], nodes[1][3] + n_step)

					for i = 1, skill.count[skill.level] do
						local e = E:create_entity(a.entity)

						e.pos:copy(P:node_pos_ref(pi, spi, ni))

						e.render.sprites[1].flip_x = math.random() > 0.5
						e.delay = (i - 1) * fts(U.frandom(2, 3))
						e.bullet.source_id = this.id
						e.bullet.level = skill.level
						e.bullet.damage_factor = this.unit.damage_factor
						e._icepeak_timestamp = store.tick_ts

						simulation:queue_insert_entity(e)

						ni = ni + n_step
						spi = km.zmod(spi + math.random(1, 2), 3)

						if ni < 1 or ni > #P.paths[pi][spi] then
							break
						end
					end

					a.ts = start_ts

					SU.hero_gain_xp_from_skill(this, skill)
					SU.y_hero_animation_wait(this)
				end
			else
				a.ts = a.ts + 0.1
			end
		end

		-- 冻土
		a = this.timed_attacks.list[3]
		skill = this.hero.skills.coldfury

		if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
			local target = U.detect_foremost_enemy_between_range_filter_off(this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

			if target then
				local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni
				local nodes = P:nearest_nodes(this.pos.x, this.pos.y, {pi}, nil, nil, NF_RALLY)

				if #nodes > 0 then
					local flip = target.pos.x < this.pos.x
					local start_ts = store.tick_ts

					U.animation_start_default(this, "coldFury", flip, store.tick_ts)
					S:queue(a.sound)

					if SU.y_hero_wait(store, this, a.cast_time) then
						goto eiskalt_attack_end
					end

					local delay = 0
					local n_step = ni < nodes[1][3] and -a.step or a.step

					ni = km.clamp(1, #P.paths[pi][spi], ni - n_step)

					for i = 1, 8 do
						local b = E:create_entity(a.bullet)

						b.pos:copy(P:node_pos_ref(pi, spi, ni))

						b.render.sprites[1].flip_x = not flip
						b.delay = delay

						simulation:queue_insert_entity(b)

						local fx = E:create_entity(b.aura.hit_decal)

						fx.pos:copy(b.pos)

						fx.delay = delay

						simulation:queue_insert_entity(fx)

						delay = delay + 0.05
						ni = ni + n_step
						spi = km.zmod(spi + 1, 3)

						if ni < 1 or ni > #P.paths[pi][spi] then
							break
						end
					end

					a.ts = start_ts

					SU.hero_gain_xp_from_skill(this, skill)
					SU.y_hero_animation_wait(this)
				end
			else
				a.ts = a.ts + 0.1
			end
		end

		-- 雪球
		a = this.timed_attacks.list[1]
		skill = this.hero.skills.frosty

		if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
			local targets_info = U.find_enemies_in_paths(store.enemies, this.pos, a.range_nodes_min, a.range_nodes_max, nil, a.vis_flags, a.vis_bans)

			if targets_info then
				local target

				for _, ti in ipairs(targets_info) do
					if GR:cell_is(ti.enemy.pos.x, ti.enemy.pos.y, TERRAIN_LAND) then
						target = ti.enemy

						break
					end
				end

				if target then
					local pi, _, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni
					local nodes = P:nearest_nodes(this.pos.x, this.pos.y, {pi}, {1}, nil, NF_RALLY)

					if #nodes > 0 then
						local start_ts = store.tick_ts
						local s_ni = km.clamp(1, #P:path(pi), ni + 4)
						local target_node = P:node_pos_ref(nodes[1][1], 1, s_ni)
						local flip = target_node.x < this.pos.x

						S:queue(a.sound)
						U.animation_start_default(this, "frosty", flip, store.tick_ts)

						if SU.y_hero_wait(store, this, a.spawn_time) then
							goto eiskalt_attack_end
						end

						local e = E:create_entity(a.entity)

						e.bullet.from = v(this.pos.x + (flip and -1 or 1) * a.spawn_offset.x, this.pos.y + a.spawn_offset.y)

						e.bullet.to:copy(target_node)

						e.bullet.level = skill.level
						e.bullet.damage_factor = this.unit.damage_factor

						simulation:queue_insert_entity(e)

						a.ts = start_ts

						SU.hero_gain_xp_from_skill(this, skill)
						SU.y_hero_animation_wait(this)
					end
				end
			else
				a.ts = a.ts + 0.1
			end
		end

		-- 普攻
		a = this.ranged.attacks[1]

		if ready_to_attack(a, store) then
			local target = U.detect_foremost_enemy_between_range_filter_off(this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

			if target then
				local start_ts = store.tick_ts
				local an, af = U.animation_name_facing_point(this, a.animation, target.pos)

				U.animation_start_default(this, an, af, store.tick_ts)

				if SU.y_hero_wait(store, this, a.shoot_time) then
					goto eiskalt_attack_end
				end

				S:queue(a.sound)

				local b = E:create_entity(a.bullet)

				b.bullet.source_id = this.id
				b.bullet.target_id = target.id

				b.pos:set(this.pos.x + (af and -1 or 1) * a.bullet_start_offset.x, this.pos.y + a.bullet_start_offset.y)
				b.bullet.from:copy(b.pos)
				b.bullet.to:copy(target.pos)

				b.bullet.xp_dest_id = this.id
				b.bullet.damage_factor = this.unit.damage_factor

				simulation:queue_insert_entity(b)

				a.ts = start_ts

				SU.y_hero_animation_wait(this)
			else
				a.ts = a.ts + 0.1
			end
		end

		SU.soldier_idle(store, this)
		SU.soldier_regen(store, this)

		::eiskalt_attack_end::

		coroutine.yield()
	end
end

local function hero_eiskalt_ultimate_update(this, store)
	for _, e in pairs(store.enemies) do
		if U.flags_pass(e.vis, this) and not table.arraycontains(this.excluded_templates, e.template_name) then
			local mod = E:create_entity(this.mod)

			mod.modifier.target_id = e.id
			mod.modifier.duration = this.duration

			simulation:queue_insert_entity(mod)
		end
	end

	local overlay = E:create_entity("overlay_eiskalt_whiteout")

	overlay.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(overlay)

	local begin_ts = store.tick_ts
	local breath_period = 3.5
	local alpha_min = this.freeze_alpha_min
	local alpha_max = this.freeze_alpha_max

	while begin_ts + this.duration > store.tick_ts do
		local elapsed = store.tick_ts - begin_ts
		local breath = (math.sin(elapsed / breath_period * 2 * math.pi) + 1) * 0.5

		overlay.render.sprites[1].alpha = alpha_min + (alpha_max - alpha_min) * breath

		local rain = this.rain

		if store.tick_ts - rain.ts >= rain.cooldown then
			rain.ts = store.tick_ts

			local angle = U.frandom(rain.angle_min, rain.angle_max)

			for i = 1, rain.count do
				angle = angle + U.frandom(-rain.angle_between, rain.angle_between)

				local dist = math.random(rain.distance_min, rain.distance_max)
				local ox, oy = V.rotate(angle, dist, 0)
				local pos = V.v(math.random(-100, 1920 + 100), math.random(0, 1080))
				local e = E:create_entity("fx_power_eiskalt_drop")

				e.pos.x, e.pos.y = pos.x, pos.y
				e.render.sprites[1].offset = V.v(-ox, -oy)
				e.render.sprites[1].r = angle
				e.render.sprites[1].alpha = math.random(rain.alpha_min, rain.alpha_max)
				e.tween.props[1].keys = {{0, 0}, {0.001, 255}}
				e.tween.props[2] = CC("tween_prop")
				e.tween.props[2].keys = {{0, V.v(-ox, -oy)}, {0.001, V.v(-ox, -oy)}, {rain.duration, V.v(0, 0)}}
				e.tween.props[2].name = "offset"
				e.tween.ts = store.tick_ts

				simulation:queue_insert_entity(e)
			end
		end

		coroutine.yield()
	end

	simulation:queue_remove_entity(overlay)
	simulation:queue_remove_entity(this)
end

tt = RT("hero_eiskalt", "hero")

AC(tt, "ranged", "timed_attacks")

tt.regen.cooldown = 1
tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.hp_max = {300, 325, 350, 375, 400, 425, 450, 475, 500, 525}
tt.hero.level_stats.ranged_damage_min = {17, 21, 25, 29, 33, 37, 42, 47, 52, 57}
tt.hero.level_stats.ranged_damage_max = {23, 29, 35, 42, 49, 56, 63, 70, 77, 84}
-- 1 爆炸
tt.hero.skills.explosion = CC("hero_skill")
tt.hero.skills.explosion.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.explosion.xp_gain = {80, 160, 240}
tt.hero.skills.explosion.damage_radius = {40, 60, 80}
-- 2 冻土
tt.hero.skills.coldfury = CC("hero_skill")
tt.hero.skills.coldfury.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.coldfury.xp_gain = {120, 240, 360}
tt.hero.skills.coldfury.cooldown_time = {20, 16, 12}
-- 3 雪球
tt.hero.skills.frosty = CC("hero_skill")
tt.hero.skills.frosty.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.frosty.xp_gain = {100, 200, 300}
tt.hero.skills.frosty.damage_min = {10, 20, 30}
tt.hero.skills.frosty.damage_max = {10, 20, 30}
-- 4 冰刺
tt.hero.skills.icepeak = CC("hero_skill")
tt.hero.skills.icepeak.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.icepeak.xp_gain = {160, 320, 480}
tt.hero.skills.icepeak.count = {8, 8, 8}
-- 大招
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.ultimate.xp_gain = {200, 400, 600, 800}
tt.hero.skills.ultimate.controller_name = "hero_eiskalt_ultimate"
tt.hero.skills.ultimate.duration = {3.5, 5, 6.5, 8}
tt.health.dead_lifetime = 15
tt.health_bar.offset = v(0, 157)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.health_bar.draw_order = -1
tt.health_bar.sort_y_offset = -200
tt.hero.fn_level_up = hero_eiskalt_level_up
tt.idle_flip.cooldown = 10
tt.info.hero_portrait = "kr4_hero_portraits_0012"
tt.info.portrait = "kr4_info_portraits_heroes_0012"
tt.main_script.update = hero_eiskalt_update
tt.motion.max_speed = 90
tt.nav_rally.requires_node_nearby = false
tt.nav_grid.ignore_waypoints = true
tt.nav_grid.valid_terrains = TERRAIN_ALL_MASK
tt.nav_grid.valid_terrains_dest = TERRAIN_ALL_MASK
tt.render.sprites[1].anchor.y = 0.1296
tt.render.sprites[1].prefix = "hero_eiskalt"
tt.render.sprites[1].angles.walk = {"idle"}
tt.render.sprites[1].sort_y_offset = -200
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "hero_eiskalt_shadow"
tt.render.sprites[2].z = Z_DECALS + 1
tt.sound_events.change_rally_point = "HeroEiskaltTaunt"
tt.sound_events.death = "HeroEiskaltTauntDeath"
tt.sound_events.respawn = "HeroEiskaltTaunt"
tt.sound_events.insert = "HeroEiskaltTaunt"
tt.sound_events.hero_room_select = "HeroEiskaltTauntSelect"
tt.ui.click_rect = r(-25, 70, 50, 45)
tt.unit.hit_offset = v(0, 98)
tt.unit.hide_after_death = true
tt.unit.marker_offset = v(0, -0.15)
tt.unit.mod_offset = v(0, 101)
tt.vis.bans = bor(F_EAT, F_NET, F_POISON)
tt.vis.flags = bor(tt.vis.flags, F_FLYING)
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].bullet = "fireball_eiskalt"
tt.ranged.attacks[1].bullet_start_offset = v(46, 52)
tt.ranged.attacks[1].cooldown = 2
tt.ranged.attacks[1].max_range = 220
tt.ranged.attacks[1].shoot_time = fts(13)
tt.ranged.attacks[1].ignore_hit_offset = true
tt.ranged.attacks[1].animation = "range_attack"
tt.ranged.attacks[1].estimated_flight_time = fts(24)
tt.ranged.attacks[1].sound = "HeroEiskaltAttack"
tt.timed_attacks.list[1] = CC("spawn_attack")
tt.timed_attacks.list[1].animation = "frosty"
tt.timed_attacks.list[1].cooldown = 18
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].entity = "bullet_eiskalt_frosty"
tt.timed_attacks.list[1].spawn_offset = v(12, 60)
tt.timed_attacks.list[1].spawn_time = fts(20)
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[1].range_nodes_max = 50
tt.timed_attacks.list[1].range_nodes_min = 10
tt.timed_attacks.list[1].sound = "HeroEiskaltFrosty"
tt.timed_attacks.list[2] = CC("spawn_attack")
tt.timed_attacks.list[2].animation = "icePeaks"
tt.timed_attacks.list[2].cooldown = 21
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].entity = "eiskalt_icepeaks"
tt.timed_attacks.list[2].spawn_time = fts(8)
tt.timed_attacks.list[2].vis_flags = bor(F_RANGED, F_AREA)
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING, F_BOSS)
tt.timed_attacks.list[2].min_range = 22.5
tt.timed_attacks.list[2].max_range = 200
tt.timed_attacks.list[3] = CC("aura_attack")
tt.timed_attacks.list[3].animation = "coldFury"
tt.timed_attacks.list[3].bullet = "aura_chill_eiskalt"
tt.timed_attacks.list[3].cast_time = fts(25)
tt.timed_attacks.list[3].cooldown = 20
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].max_range = 125
tt.timed_attacks.list[3].min_range = 20
tt.timed_attacks.list[3].sound = "HeroEiskaltColdFury"
tt.timed_attacks.list[3].step = 3
tt.timed_attacks.list[3].nodes_offset = 6
tt.timed_attacks.list[3].vis_bans = bor(F_FLYING, F_CLIFF, F_BOSS)
tt.timed_attacks.list[3].vis_flags = bor(F_RANGED, F_MOD, F_AREA)
tt.timed_attacks.list[3].xp_from_skill = "coldfury"
tt.ultimate = {
	ts = 0,
	cooldown = 50,
	disabled = true
}
tt = RT("mod_eiskalt_chill", "mod_eiskalt_cold")
tt.modifier.duration = 0.3
tt.slow.factor = 0.5
tt = RT("mod_eiskalt_cold_icepeak", "mod_eiskalt_cold")
tt.modifier.duration = 2
tt = RT("fx_aura_chill_eiskalt_smoke", "decal_scripted")

AC(tt, "tween")

tt.main_script.update = eiskalt_cold_fury_smoke_update
tt.render.sprites[1].name = "hero_eiskalt_cold_fury_smoke_run"
tt.tween.disabled = true
tt.tween.props[1].keys = {{fts(20), 255}, {fts(40), 0}}
tt = RT("aura_chill_eiskalt", "aura")

AC(tt, "render", "tween")

tt.aura.cycle_time = 0.2
tt.aura.duration = 5
tt.aura.mod = "mod_eiskalt_chill"
tt.aura.radius = 50
tt.aura.vis_bans = bor(F_FLYING, F_BOSS)
tt.aura.vis_flags = bor(F_MOD)
tt.aura.hit_decal = "fx_aura_chill_eiskalt_smoke"
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_chill_elora.update
tt.render.sprites[1].name = "hero_eiskalt_cold_fury_ice"
tt.render.sprites[1].loop = false
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {0.2, 0}}
tt = RT("fireball_eiskalt", "bullet")
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "hero_eiskalt_proyectile_0001"
tt.render.sprites[1].anchor.x = 0.69
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.min_speed = 390
tt.bullet.max_speed = 390
tt.bullet.hit_fx = "fx_fireball_eiskalt_ground"
tt.bullet.hit_fx_air = "fx_fireball_eiskalt_air"
tt.bullet.hit_decal = "fx_fireball_eiskalt_decal"
tt.bullet.xp_gain_factor = 1.62
tt.bullet.particles_name = "ps_fireball_eiskalt"
tt.bullet.mods = {"mod_eiskalt_cold"}
tt.main_script.update = scripts.fireball_dragon.update
tt.main_script.remove = fireball_eiskalt_remove
tt.sound_events.hit = "HeroEiskaltAttackHit"
tt = RT("eiskalt_icepeaks", "bullet")

AC(tt, "tween")

tt.main_script.update = eiskalt_icepeaks_update
tt.bullet.damage_radius = 50
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_bans = F_BOSS
tt.bullet.hit_time = fts(4)
tt.bullet.duration = 2
tt.bullet.mods = {"mod_eiskalt_cold_icepeak"}
tt.render.sprites[1].prefix = "hero_eiskalt_ice_peaks"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].anchor.y = 0.0903
tt.render.sprites[1].z = Z_OBJECTS
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {fts(3), 0}, {fts(6), 255}, {tt.bullet.duration, 255}, {tt.bullet.duration + fts(10), 0}}
tt.sound_events.delayed_insert = "HeroEiskaltPeak"
tt = RT("ps_eiskalt_rider_trail_A")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "hero_eiskalt_particle_run"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 6
tt.particle_system.emit_area_spread = v(15, 15)
tt.particle_system.z = Z_OBJECTS
tt.particle_system.particle_lifetime = {fts(13), fts(13)}
tt.particle_system.emit_offset = v(0, 0)
tt.emit_offset_relative = v(-10, 0)
tt = RT("ps_eiskalt_rider_trail_B")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "hero_eiskalt_particle_run"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 8
tt.particle_system.emit_area_spread = v(15, 15)
tt.particle_system.z = Z_OBJECTS + 1
tt.particle_system.particle_lifetime = {fts(9), fts(9)}
tt.particle_system.emit_offset = v(0, 0)
tt.emit_offset_relative = v(-10, 0)
tt = RT("fx_eiskalt_frosty_spawn", "fx")
tt.render.sprites[1].name = "hero_eiskalt_frosty_spawn"
tt.render.sprites[1].anchor.y = 0.4
tt = RT("bullet_eiskalt_frosty", "bomb")
tt.bullet.flight_time = fts(30)
tt.bullet.hit_fx = "fx_eiskalt_frosty_spawn"
tt.bullet.pop_chance = 0
tt.bullet.damage_radius = 0
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.rotation_speed = 4 * math.pi
tt.bullet.hit_payload = "aura_eiskalt_rider"
tt.render.sprites[1].name = "hero_eiskalt_frosty_projectile"
tt = RT("aura_eiskalt_rider", "aura")

AC(tt, "render", "nav_path", "tween", "motion")

tt.aura.radius = 75
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans = bor(F_FLYING)
tt.aura.duration = 6
tt.aura.cycle_time = 0.25
tt.aura.damage_min = 9
tt.aura.damage_max = 9
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].prefix = "hero_eiskalt_frosty"
tt.render.sprites[1].sort_y_offset = -60
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk", "walkUp", "walkDown"}
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = aura_eiskalt_skill_rider_update
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 255}, {1, 0}}
tt.tween.disabled = true
tt.motion.max_speed = 60
tt.damage_type = DAMAGE_PHYSICAL
tt.hit_blood_fx = "fx_blood_splat"
tt.particles_name_A = "ps_eiskalt_rider_trail_A"
tt.particles_name_B = "ps_eiskalt_rider_trail_B"
tt.sound_events.insert = "HeroEiskaltFrosty"
tt = RT("mod_eiskalt_freeze", "mod_freeze")

AC(tt, "render")

tt.modifier.duration = 12
tt.render.sprites[1].prefix = "freeze_creep"
tt.render.sprites[1].sort_y_offset = -2
tt.custom_offsets = {
	flying = vec_2(-5, 32)
}
tt.custom_suffixes = {
	flying = "_air"
}
tt.custom_animations = {"start", "end"}
tt = RT("fx_power_eiskalt_drop", "fx")

AC(tt, "tween")

tt.render.sprites[1].name = "hero_eiskalt_copo"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.x = 1
tt.render.sprites[1].scale = v(0.5, 0.5)
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt = RT("hero_eiskalt_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.duration = 3.5
tt.main_script.update = hero_eiskalt_ultimate_update
tt.excluded_templates = {"eb_umbra", "enemy_umbra_piece", "enemy_umbra_piece_flying", "enemy_tremor", "enemy_headless_horseman"}
tt.vis_flags = bor(F_MOD, F_FREEZE)
tt.vis_bans = F_BOSS
tt.mod = "mod_eiskalt_freeze"
tt.rain = {}
tt.rain.alpha_max = 255
tt.rain.alpha_min = 150
tt.rain.angle_between = 2 * math.pi / 180
tt.rain.angle_max = -60 * math.pi / 180
tt.rain.angle_min = -80 * math.pi / 180
tt.rain.cooldown = 0.25
tt.rain.count = 20
tt.rain.delay_max = 0.25
tt.rain.disabled = false
tt.rain.distance_max = 550
tt.rain.distance_min = 450
tt.rain.duration = 0.25
tt.rain.ts = 0
tt.freeze_alpha_min = 0
tt.freeze_alpha_max = 30
tt = RT("overlay_eiskalt_whiteout", "decal")
tt.pos = v(REF_W * 0.5, REF_H * 0.5)
tt.render.sprites[1].name = "square_ffffff"
tt.render.sprites[1].animated = false
tt.render.sprites[1].scale = vec_2(math.ceil(REF_H * MAX_SCREEN_ASPECT * 2 / 64), math.ceil(REF_H * 2 / 64))
tt.render.sprites[1].z = Z_SCREEN_FIXED
tt.render.sprites[1].alpha = 0
tt = RT("fx_fireball_eiskalt_decal", "decal_tween")
tt.render.sprites[1].name = "hero_eiskalt_proyectile_travel"
tt.tween.props[1].keys = {{fts(17), 255}, {fts(27), 0}}
tt = RT("fx_fireball_eiskalt_ground", "fx")
tt.render.sprites[1].name = "hero_eiskalt_explosion_run"
tt.render.sprites[1].anchor.y = 0.2051
tt.render.sprites[1].sort_y_offset = -5
tt = RT("fx_fireball_eiskalt_air", "fx")
tt.render.sprites[1].name = "hero_eiskalt_explosion_air_run"
tt.render.sprites[1].anchor.y = 0.24
tt.render.sprites[1].scale = v(0.7, 0.7)
tt = RT("ps_fireball_eiskalt")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "hero_eiskalt_particle_run"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(11), fts(16)}
tt.particle_system.scale_var = {0.78, 1.43}
tt.particle_system.scales_x = {1, 1.25}
tt.particle_system.scales_y = {1, 1.25}
tt.particle_system.emission_rate = 20
tt.particle_system.emit_rotation_spread = math.pi
tt.particle_system.alphas = {255, 0}
