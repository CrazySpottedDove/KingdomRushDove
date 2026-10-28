local scripts = require("scripts")
local E = require("entity_db")
local LU = require("level_utils")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local bit = require("bit")
local km = require("lib.klua.macros")
local HU = require("hero_utils")
local band = bit.band
local bor = bit.bor
local fts = U.fts
local level_up_basic = HU.level_up_basic
local queue_damage = U.queue_damage
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local tt

local function drone_wilbur_update(this, store)
	local sd = this.render.sprites[1]
	local ss = this.render.sprites[2]
	local ca = this.custom_attack
	local fm = this.force_motion

	local function find_target(range)
		local target, targets

		for _, set in pairs(ca.range_sets) do
			local min_range, max_range = unpack(set)

			target, targets = U.find_nearest_enemy(store, this.pos, min_range, max_range, ca.vis_flags, ca.vis_bans)

			if target then
				break
			end
		end

		if not target then
			return nil
		end

		local drones = LU.list_entities(store.entities, this.template_name)
		local drone_target_ids = table.map(drones, function(k, v)
			return v._chasing_target_id or 0
		end)
		local untargeted = table.filter(targets, function(k, v)
			return not table.contains(drone_target_ids, v.id)
		end)

		for _, nt in ipairs(targets) do
			if table.contains(untargeted, nt) then
				return nt
			end
		end

		return target
	end

	local shoot_ts, search_ts, shots = 0, 0, 0
	local target, dist
	local dest = V.v(this.pos.x, this.pos.y)

	this.start_ts = store.tick_ts
	fm.a_step = fm.a_step + math.random(-3, 3)
	this.tween.ts = U.frandom(0, 1)

	local oos = {V.v(-6, 0), V.v(6, 2), V.v(2, 6), V.v(0, -6)}
	local oo = oos[this.spawn_index]

	U.animation_start_default(this, "idle", nil, store.tick_ts, true)

	while store.tick_ts - this.start_ts <= this.duration do
		search_ts = store.tick_ts

		if shots < ca.max_shots then
			target = find_target(ca.max_range)
		else
			target = nil
		end

		this._chasing_target_id = target and target.id or nil

		if target then
			repeat
				dest.x, dest.y = target.pos.x + oo.x, target.pos.y + oo.y
				sd.flip_x = this.pos.x < dest.x

				U.force_motion_step(this, store.tick_length, dest)
				coroutine.yield()

				dist = V.dist(this.pos.x, this.pos.y, dest.x, dest.y)
			until dist < ca.shoot_range or target.health.dead or band(ca.vis_flags, target.vis.bans) ~= 0

			if shots < ca.max_shots and store.entities[target.id] and not target.health.dead and band(ca.vis_flags, target.vis.bans) == 0 and store.tick_ts - shoot_ts > ca.cooldown then
				shots = shots + 1

				if math.random() < ca.sound_chance then
					S:queue(ca.sound)
				end

				U.animation_start_default(this, "shoot", this.pos.x < target.pos.x, store.tick_ts, false)

				for i = 1, ca.hit_cycles do
					local hit_ts = store.tick_ts

					while store.tick_ts - hit_ts < ca.hit_time do
						U.force_motion_step(this, store.tick_length, dest)

						sd.flip_x = this.pos.x < target.pos.x

						coroutine.yield()
					end

					local d = SU.create_attack_damage(ca, target.id, this)

					queue_damage(store, d)
				end

				while not U.animation_finished_default(this) do
					U.force_motion_step(this, store.tick_length, dest)

					sd.flip_x = this.pos.x < target.pos.x

					coroutine.yield()
				end

				U.animation_start_default(this, "idle", nil, store.tick_ts, true)

				shoot_ts = store.tick_ts
			end

			U.animation_start_default(this, "idle", nil, store.tick_ts, true)
		end

		while store.tick_ts - search_ts < ca.search_cooldown do
			U.force_motion_step(this, store.tick_length, dest)
			coroutine.yield()
		end
	end

	U.y_ease_keys(store, {sd, sd.offset, ss}, {"alpha", "y", "alpha"}, {255, 50, 255}, {0, 85, 0}, 0.4)
	simulation:queue_remove_entity(this)
end

local function missile_wilbur_insert(this, store)
	local b = this.bullet

	b.to.x = this.pos.x
	b.to.y = this.pos.y + math.random(70, 110)

	if b.shot_index ~= 1 then
		local o_target = store.entities[b.target_id]
		local o = o_target and o_target.pos or this.pos
		local _, targets = U.find_foremost_enemy_in_range_filter_on(o, b.first_retarget_range, false, b.vis_flags, b.vis_bans, function(e)
			return e.id ~= b.target_id
		end)

		if targets then
			local target = targets[b.shot_index - 1] or table.random(targets)

			b.target_id = target.id
		end
	end

	return scripts.missile.insert(this, store)
end

local function hero_wilbur_missile_filter_fn(e, origin)
	local pp = P:predict_enemy_pos(e, 2)
	local allow = math.abs(pp.y - origin.y) < 80

	return allow
end

local function hero_wilbur_level_up(this, store)
	local hl, ls = level_up_basic(this)
	local b = E:get_template(this.ranged.attacks[1].bullet)

	b.bullet.damage_max = ls.ranged_damage_max[hl]
	b.bullet.damage_min = ls.ranged_damage_min[hl]

	upgrade_skill(this, "missile", function(this, s)
		local a = this.ranged.attacks[2]

		a.disabled = nil

		local b = E:get_template(a.bullet)

		b.bullet.damage_max = s.damage_max[s.level]
		b.bullet.damage_min = s.damage_min[s.level]
	end)
	upgrade_skill(this, "smoke", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil

		local au = E:get_template(a.bullet)

		au.aura.duration = s.duration[s.level]

		local m = E:get_template(au.aura.mod)

		m.slow.factor = s.slow_factor[s.level]
	end)
	upgrade_skill(this, "box", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil

		local pl = E:get_template(a.payload)

		pl.spawner.count = s.count[s.level]
	end)
	upgrade_skill(this, "engine", function(this, s)
		this.engine_factor = s.speed_factor[s.level]
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		this.ultimate.disabled = nil

		local m = E:get_template("drone_wilbur")

		m.custom_attack.damage_max = s.damage[s.level] - 1
		m.custom_attack.damage_min = -1
	end)
	U.update_max_speed(this, this.motion.max_speed_base * this.engine_factor)
	update_hp(this)
end

local function hero_wilbur_insert(this, store)
	this.hero.fn_level_up(this, store)

	this.ranged.order = U.attack_order(this.ranged.attacks)

	local a = E:create_entity("aura_bobbing_wilbur")

	a.aura.source_id = this.id
	a.aura.ts = store.tick_ts
	a.pos = this.pos

	simulation:queue_insert_entity(a)

	return true
end

local function hero_wilbur_update(this, store)
	local h = this.health
	local a, skill, brk

	U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
			U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)
		end

		while this.nav_rally.new do
			SU.y_hero_new_rally(store, this)
		end

		if SU.hero_level_up(store, this) then
		-- block empty
		end

		if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
			local target = U.find_foremost_enemy_in_range_filter_off(this.pos, this.ranged.attacks[1].max_range, 0, F_RANGED, 0)

			if target and target.pos then
				S:queue(this.sound_events.change_rally_point)

				local e = E:create_entity(this.hero.skills.ultimate.controller_name)

				e.level = this.hero.skills.ultimate.level
				e.pos = V.vclone(target.pos)

				simulation:queue_insert_entity(e)
			end

			this.ultimate.ts = store.tick_ts

			SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
		end

		a = this.timed_attacks.list[1]
		skill = this.hero.skills.smoke

		if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
			local target = U.find_foremost_enemy_between_range_filter_off(this.pos, a.min_range, a.max_range, a.node_prediction, a.vis_flags, a.vis_bans)

			if not target then
				a.ts = a.ts + 0.06666666666666667
			else
				S:queue(a.sound, a.sound_args)
				U.y_animation_play(this, a.animations[1], nil, store.tick_ts)
				SU.hero_gain_xp_from_skill(this, skill)

				local au = E:create_entity(a.bullet)

				au.pos.x, au.pos.y = this.pos.x, this.pos.y

				simulation:queue_insert_entity(au)
				U.y_animation_play(this, a.animations[2], nil, store.tick_ts)
				U.animation_start_default(this, a.animations[3], nil, store.tick_ts, false)
				SU.y_hero_animation_wait(this)

				a.ts = store.tick_ts

				goto label_199_0
			end
		end

		a = this.timed_attacks.list[2]
		skill = this.hero.skills.box

		if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
			local target_info = U.find_enemies_in_paths(store.enemies, this.pos, a.range_nodes_min, a.range_nodes_max, a.max_path_dist, a.vis_flags, a.vis_bans, true, function(e)
				return not U.flag_has(P:path_terrain_props(e.nav_path.pi), TERRAIN_FAERIE)
			end)

			if not target_info then
				a.ts = a.ts + 0.16666666666666666
			else
				local origin = target_info[1].origin
				local bullet_to_ni = origin[3] - math.random(8, 13)

				bullet_to_ni = km.clamp(5, P:get_end_node(origin[1]), bullet_to_ni)

				local bullet_to = P:node_pos(origin[1], 1, bullet_to_ni)
				local flip = bullet_to.x < this.pos.x

				S:queue(a.sound)
				U.animation_start_default(this, a.animation, flip, store.tick_ts)

				if SU.y_soldier_wait(store, this, a.shoot_time) then
					goto label_199_0
				end

				SU.hero_gain_xp_from_skill(this, skill)

				a.ts = store.tick_ts

				local e = E:create_entity(a.payload)

				e.damage_factor = this.unit.damage_factor
				e.spawner.pi = origin[1]
				e.spawner.ni = bullet_to_ni
				e.pos = bullet_to

				local b = E:create_entity(a.bullet)

				b.pos.x = this.pos.x + (flip and -1 or 1) * a.bullet_start_offset.x
				b.pos.y = this.pos.y + a.bullet_start_offset.y

				b.bullet.from:copy(b.pos)
				b.bullet.to:copy(e.pos)

				b.bullet.hit_payload = e

				simulation:queue_insert_entity(b)
				SU.y_hero_animation_wait(this)

				a.ts = store.tick_ts

				goto label_199_0
			end
		end

		brk = SU.y_soldier_ranged_attacks(store, this)

		if brk then
		-- block empty
		else
			SU.soldier_idle(store, this)
			SU.soldier_regen(store, this)
		end

		::label_199_0::

		coroutine.yield()
	end
end

local function aura_box_wilbur_update(this, store)
	local sp = this.spawner

	this.render.sprites[1].ts = store.tick_ts

	SU.insert_sprite(store, "decal_rock_crater", this.pos)
	U.y_wait_unconditional(store, sp.spawn_time)

	this.render.sprites[1].z = Z_DECALS

	S:queue(sp.sound)

	for i = 1, sp.count do
		local e = E:create_entity(sp.entity)

		e.damage_factor = this.damage_factor
		e.pos.x, e.pos.y = this.pos.x, this.pos.y
		e.nav_path.pi = sp.pi
		e.nav_path.spi = km.zmod(i, 3)
		e.nav_path.ni = sp.ni

		simulation:queue_insert_entity(e)
	end

	SU.insert_sprite(store, "fx_box_wilbur_smoke_b", V.v(this.pos.x + 33 - 40, this.pos.y + 32 - 20))
	SU.insert_sprite(store, "fx_box_wilbur_smoke_a", V.v(this.pos.x + 60 - 40, this.pos.y + 32 - 22))
	SU.insert_sprite(store, "fx_box_wilbur_smoke_a", V.v(this.pos.x + 10 - 40, this.pos.y + 32 - 22), true)
	U.y_wait_unconditional(store, fts(10))
	U.y_ease_key(store, this.render.sprites[1], "alpha", 255, 0, 1)
	simulation:queue_remove_entity(this)
end

local function shot_wilbur_update(this, store)
	local b = this.bullet
	local target = store.entities[b.target_id]
	local source = store.entities[b.source_id]

	if b.shot_index < 3 then
		local flip_x = b.to.x < source.pos.x
		local sfx = E:create_entity(b.shoot_fx)

		sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
		sfx.render.sprites[1].flip_x = flip_x
		sfx.render.sprites[1].r = (flip_x and -1 or 1) * km.deg2rad(-30)
		sfx.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(sfx)
	end

	if b.shot_index == 1 and target and not U.flag_has(target.vis.flags, F_FLYING) then
		local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni

		ni = ni + 6

		for i = 1, 6 do
			local sign = i % 2 == 0 and 1 or -1
			local p = P:node_offset_pos(10 * sign, pi, spi, ni - i)
			local fx = E:create_entity(b.hit_fx)

			fx.pos.x, fx.pos.y = p.x, p.y
			fx.render.sprites[1].ts = store.tick_ts + fts(2 * i)

			simulation:queue_insert_entity(fx)
		end
	end

	U.y_wait_unconditional(store, b.flight_time)

	if target then
		local d = SU.create_bullet_damage(b, target.id, this.id)

		queue_damage(store, d)
	end

	simulation:queue_remove_entity(this)
end

local function aura_wilbur_bobbing_update(this, store)
	local hero = store.entities[this.aura.source_id]
	local s3 = hero.render.sprites[3]
	local nr = hero.nav_rally
	local layers = {hero.render.sprites[3], hero.render.sprites[4]}
	local dist_th = 40
	local max_angle = km.deg2rad(5)
	local angle_step = km.deg2rad(20) * store.tick_length
	local h_max = 4
	local h_step = 20 * store.tick_length
	local h_ts = store.tick_ts

	while true do
		local dx = this.pos.x - nr.center.x
		local dest_angle = km.clamp(-max_angle, max_angle, max_angle * dx / dist_th)

		for _, s in pairs(layers) do
			local da = km.clamp(-angle_step, angle_step, dest_angle - s.r)

			s.r = s.r + da
		end

		for _, s in pairs(layers) do
			local o = s.offset

			if s3.name == "idle" then
				o.y = h_max * math.sin(2 * math.pi * (store.tick_ts - h_ts))
			else
				local dy = km.clamp(-h_step, h_step, -o.y)

				o.y = o.y + dy
				h_ts = store.tick_ts
			end
		end

		coroutine.yield()
	end
end

local function hero_wilbur_ultimate_update(this, store)
	for i, o in ipairs(this.spawn_offsets) do
		local e = E:create_entity(this.entity)

		e.pos.x, e.pos.y = this.pos.x + o.x, this.pos.y + o.y
		e.spawn_index = i

		simulation:queue_insert_entity(e)
	end

	simulation:queue_remove_entity(this)
end

tt = RT("hero_wilbur", "hero")

AC(tt, "ranged", "timed_attacks")

tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.hp_max = {300, 330, 360, 390, 420, 450, 480, 510, 540, 570}
tt.hero.level_stats.melee_damage_max = {8, 10, 11, 12, 13, 14, 16, 17, 18, 19}
tt.hero.level_stats.melee_damage_min = {6, 6, 7, 8, 9, 10, 10, 11, 12, 13}
tt.hero.level_stats.ranged_damage_max = {14, 16, 18, 20, 22, 24, 26, 28, 30, 32}
tt.hero.level_stats.ranged_damage_min = {10, 11, 12, 13, 15, 16, 17, 19, 20, 21}
tt.hero.skills.missile = CC("hero_skill")
tt.hero.skills.missile.damage_max = {40, 80, 120}
tt.hero.skills.missile.damage_min = {30, 60, 90}
tt.hero.skills.missile.xp_gain = {100, 150, 225}
tt.hero.skills.missile.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.smoke = CC("hero_skill")
tt.hero.skills.smoke.duration = {3, 4, 5}
tt.hero.skills.smoke.slow_factor = {0.8, 0.6, 0.4}
tt.hero.skills.smoke.xp_gain = {50, 75, 100}
tt.hero.skills.smoke.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.box = CC("hero_skill")
tt.hero.skills.box.count = {1, 2, 3}
tt.hero.skills.box.xp_gain = {50, 100, 200}
tt.hero.skills.box.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.hero.skills.engine = CC("hero_skill")
tt.hero.skills.engine.speed_factor = {1.2, 1.4, 1.6}
tt.hero.skills.engine.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_wilbur_ultimate"
tt.hero.skills.ultimate.damage = {4, 8, 12, 16}
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.ultimate.xp_gain_factor = 32
tt.health.dead_lifetime = 15
tt.health_bar.draw_order = -1
tt.health_bar.offset = vec_2(0, 140)
tt.health_bar.sort_y_offset = -200
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.hero.fn_level_up = hero_wilbur_level_up
tt.idle_flip.cooldown = 10
tt.info.hero_portrait = "kr3_hero_portraits_0015"
tt.info.portrait = "kr3_info_portraits_heroes_0015"
tt.main_script.insert = hero_wilbur_insert
tt.main_script.update = hero_wilbur_update
tt.motion.max_speed = 1.8 * FPS
tt.motion.max_speed_base = 1.8 * FPS
tt.nav_rally.requires_node_nearby = false
tt.nav_grid.ignore_waypoints = true
tt.nav_grid.valid_terrains = TERRAIN_ALL_MASK
tt.nav_grid.valid_terrains_dest = TERRAIN_ALL_MASK
tt.regen.cooldown = 1

for i = 1, 4 do
	tt.render.sprites[i] = CC("sprite")
	tt.render.sprites[i].anchor.y = 0.065
	tt.render.sprites[i].prefix = "hero_wilbur_layer" .. i
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].angles = {}
	tt.render.sprites[i].angles.walk = {"idle"}
	tt.render.sprites[i].group = i == 3 and "gun" or nil
	tt.render.sprites[i].z = Z_FLYING_HEROES
end

tt.render.sprites[5] = CC("sprite")
tt.render.sprites[5].alpha = 150
tt.render.sprites[5].anchor.y = 0.04032258064516129
tt.render.sprites[5].animated = false
tt.render.sprites[5].name = "decal_wilbur_shadow"
tt.sound_events.change_rally_point = "ElvesHeroGyroTaunt"
tt.sound_events.death = "ElvesHeroGyroDeath"
tt.sound_events.hero_room_select = "ElvesHeroGyroTauntSelect"
tt.sound_events.insert = "ElvesHeroGyroTauntIntro"
tt.sound_events.respawn = "ElvesHeroGyroTauntIntro"
tt.ui.click_rect = r(-25, 50, 50, 55)
tt.unit.hit_offset = vec_2(0, 90)
tt.unit.hide_after_death = true
tt.unit.mod_offset = vec_2(0, 80)
tt.vis.bans = bor(tt.vis.bans, F_EAT, F_NET)
tt.vis.flags = bor(tt.vis.flags, F_FLYING)
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animations = {nil, "shoot"}
tt.ranged.attacks[1].bullet = "shot_wilbur"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(19, 44)}
tt.ranged.attacks[1].cooldown = 0.8
tt.ranged.attacks[1].loops = 1
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].shoot_times = {0, fts(6), fts(12)}
tt.ranged.attacks[1].sprite_group = "gun"
tt.ranged.attacks[1].sound = "ElvesHeroGyroAttack"
tt.ranged.attacks[2] = CC("bullet_attack")
tt.ranged.attacks[2].animations = {nil, "projectile"}
tt.ranged.attacks[2].bullet = "missile_wilbur"
tt.ranged.attacks[2].bullet_shot_start_offset = {vec_2(-24, 87), vec_2(-5, 123)}
tt.ranged.attacks[2].cooldown = 25
tt.ranged.attacks[2].disabled = true
tt.ranged.attacks[2].filter_fn = hero_wilbur_missile_filter_fn
tt.ranged.attacks[2].loops = 1
tt.ranged.attacks[2].max_range = 500
tt.ranged.attacks[2].node_prediction = 2
tt.ranged.attacks[2].shoot_times = {fts(5), fts(8)}
tt.ranged.attacks[2].xp_from_skill_once = "missile"
tt.timed_attacks.list[1] = CC("aura_attack")
tt.timed_attacks.list[1].animations = {"smokeStart", "smokeLoop", "smokeEnd"}
tt.timed_attacks.list[1].bullet = "aura_smoke_wilbur"
tt.timed_attacks.list[1].cooldown = 15
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].max_range = 20
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].node_prediction = fts(24) + 0.25
tt.timed_attacks.list[1].sound = "ElvesHeroGyroSmokeLaunch"
tt.timed_attacks.list[1].vis_flags = F_RANGED
tt.timed_attacks.list[1].vis_bans = F_FLYING
tt.timed_attacks.list[1].xp_from_skill = "smoke"
tt.timed_attacks.list[2] = CC("bullet_attack")
tt.timed_attacks.list[2].animation = "box"
tt.timed_attacks.list[2].bullet = "box_wilbur"
tt.timed_attacks.list[2].bullet_start_offset = vec_2(35, 115)
tt.timed_attacks.list[2].cooldown = 22
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].payload = "aura_box_wilbur"
tt.timed_attacks.list[2].range_nodes_max = 200
tt.timed_attacks.list[2].range_nodes_min = 10
tt.timed_attacks.list[2].max_path_dist = 50
tt.timed_attacks.list[2].shoot_time = fts(12)
tt.timed_attacks.list[2].sound = "ElvesHeroGyroBoombBox"
tt.timed_attacks.list[2].vis_flags = bor(F_RANGED, F_BLOCK)
tt.timed_attacks.list[2].vis_bans = F_FLYING
tt.timed_attacks.list[2].xp_from_skill = "box"
tt.ultimate = {
	ts = 0,
	cooldown = 32,
	disabled = true
}
tt.engine_factor = 1
tt = RT("aura_smoke_wilbur", "aura")

AC(tt, "render", "tween")

tt.aura.cycle_time = 0.2
tt.aura.duration = nil
tt.aura.mod = "mod_slow_wilbur"
tt.aura.radius = 60
tt.aura.vis_bans = bor(F_FRIEND)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update

for i, offset in ipairs({vec_2(25, -20), vec_2(-11, -20), vec_2(7, 5)}) do
	local s = CC("sprite")

	s.name = "decal_wilbur_smoke"
	s.offset = offset
	s.anchor.y = 0.15
	s.scale = vec_2(1, 1)
	tt.render.sprites[i] = s
	tt.tween.props[2 * i - 1] = CC("tween_prop")
	tt.tween.props[2 * i - 1].keys = {{0, 0}, {0.6, 255}, {"this.aura.duration-0.6", 255}, {"this.aura.duration", 0}}
	tt.tween.props[2 * i - 1].sprite_id = i
	tt.tween.props[2 * i] = CC("tween_prop")
	tt.tween.props[2 * i].keys = {{0, vec_1(0.3)}, {fts(13), vec_1(1.1)}, {fts(15), vec_1(1)}}
	tt.tween.props[2 * i].name = "scale"
	tt.tween.props[2 * i].sprite_id = i
end

tt.render.sprites[4] = CC("sprite")
tt.render.sprites[4].anchor.y = 0.14545454545454545
tt.render.sprites[4].name = "fx_wilbur_smoke_start"
tt.render.sprites[4].hide_after_runs = 1
tt.tween.remove = false
tt = RT("hero_wilbur_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.cooldown = 32
tt.main_script.update = hero_wilbur_ultimate_update
tt.sound_events.insert = "ElvesHeroGyroDronesSpawn"
tt.entity = "drone_wilbur"
tt.spawn_offsets = {vec_2(0, 25), vec_2(15, 0), vec_2(-15, 0), vec_2(0, -25)}
tt = RT("missile_wilbur", "bullet")
tt.bullet.acceleration_factor = 0.05
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.damage_radius = 60
tt.bullet.damage_type = DAMAGE_EXPLOSION
tt.bullet.first_retarget_range = 300
tt.bullet.hit_fx = "fx_missile_wilbur_hit"
tt.bullet.hit_fx_air = "fx_missile_wilbur_hit_air"
tt.bullet.max_speed = 360
tt.bullet.min_speed = 240
tt.bullet.particles_name = "ps_missile_wilbur"
tt.bullet.retarget_range = math.huge
tt.bullet.turn_speed = 10 * math.pi / 180 * 30
tt.bullet.damage_flags = F_AREA
tt.bullet.max_seek_angle = 0.2
tt.bullet.rot_dir_from_long_angle = true
tt.main_script.insert = missile_wilbur_insert
tt.main_script.update = scripts.missile.update
tt.render.sprites[1].prefix = "missile_wilbur"
tt.render.sprites[1].scale = vec_1(0.75)
tt.sound_events.hit = "BombExplosionSound"
tt.sound_events.insert = "RocketLaunchSound"
tt = RT("box_wilbur", "bomb")
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.flight_time = fts(30)
tt.bullet.hide_radius = nil
tt.bullet.pop = nil
tt.bullet.hit_fx = nil
tt.bullet.hit_decal = nil
tt.bullet.rotation_speed = -15 * FPS * math.pi / 180
tt.sound_events.insert = nil
tt.render.sprites[1].name = "hero_wilburg_box"
tt = RT("shot_wilbur", "bullet")
tt.bullet.hit_fx = "fx_shot_wilbur_hit"
tt.bullet.shoot_fx = "fx_shot_wilbur_flash"
tt.bullet.flight_time = fts(8)
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.xp_gain_factor = 1.6
tt.main_script.update = shot_wilbur_update
tt.render = nil
tt = RT("drone_wilbur", "decal_scripted")

AC(tt, "force_motion", "custom_attack", "sound_events", "tween")

tt.main_script.update = drone_wilbur_update
tt.flight_height = 70
tt.force_motion.max_a = 1200
tt.force_motion.max_v = 360
tt.force_motion.ramp_radius = 30
tt.force_motion.fr = 0.05
tt.force_motion.a_step = 20
tt.duration = 8
tt.render.sprites[1].prefix = "wilbur_drone"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[1].offset = vec_2(0, tt.flight_height)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.custom_attack.hit_time = fts(2)
tt.custom_attack.hit_cycles = 3
tt.custom_attack.hit_delay = fts(2)
tt.custom_attack.range_sets = {{0, 100}, {100, 1e+99}}
tt.custom_attack.max_shots = 16
tt.custom_attack.search_cooldown = 0.1
tt.custom_attack.cooldown = 0.25
tt.custom_attack.animation = "shoot"
tt.custom_attack.sound = "ElvesHeroGyroDronesAttack"
tt.custom_attack.sound_chance = 0.5
tt.custom_attack.damage_type = DAMAGE_TRUE
tt.custom_attack.vis_flags = F_RANGED
tt.custom_attack.shoot_range = 25
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].loop = true
tt.tween.props[1].keys = {{0, vec_2(0, tt.flight_height + 2)}, {0.4, vec_2(0, tt.flight_height - 2)}, {0.8, vec_2(0, tt.flight_height + 2)}}
tt.tween.props[1].interp = "sine"
tt = RT("ps_missile_wilbur")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "hero_wilburg_missile_particle"
tt.particle_system.particle_lifetime = {1.6, 1.8}
tt.particle_system.alphas = {255, 0}
tt.particle_system.scales_x = {1, 3}
tt.particle_system.scales_y = {1, 3}
tt.particle_system.scale_var = {0.4, 0.95}
tt.particle_system.emit_spread = math.pi
tt.particle_system.emission_rate = 30
tt = RT("fx_box_wilbur_smoke_a", "fx")
tt.render.sprites[1].name = "fx_box_wilbur_smoke_a"
tt.render.sprites[1].z = Z_OBJECTS
tt = RT("fx_box_wilbur_smoke_b", "fx")
tt.render.sprites[1].name = "fx_box_wilbur_smoke_b"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -5
tt = RT("fx_missile_wilbur_hit", "fx_fireball_veznan_demon_hit")
tt.render.sprites[1].scale = vec_1(1.4)
tt = RT("fx_missile_wilbur_hit_air", "fx_fireball_veznan_demon_hit_air")
tt.render.sprites[1].scale = vec_1(1.4)
tt = RT("fx_shot_wilbur_flash", "fx")
tt.render.sprites[1].name = "fx_shot_wilbur_flash"
tt = RT("fx_shot_wilbur_hit", "fx")
tt.render.sprites[1].name = "fx_shot_wilbur_hit"
tt.render.sprites[1].anchor.y = 0.19230769230769232
tt.render.sprites[1].z = Z_OBJECTS
tt = RT("aura_bobbing_wilbur", "aura")
tt.aura.duration = -1
tt.main_script.update = aura_wilbur_bobbing_update
tt = RT("aura_box_wilbur", "decal_scripted")

AC(tt, "spawner", "sound_events")

tt.render.sprites[1].anchor.y = 0.25
tt.render.sprites[1].name = "box_wilbur_open"
tt.render.sprites[1].loop = false
tt.spawner.entity = "bomb_wilbur"
tt.spawner.spawn_time = fts(10)
tt.spawner.count = nil
tt.sound_events.insert = "ElvesHeroGyroBoombBoxTouchdown"
tt.main_script.update = aura_box_wilbur_update
tt = RT("mod_slow_wilbur", "mod_slow")
tt.slow.factor = nil
