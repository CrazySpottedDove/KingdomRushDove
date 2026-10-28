local scripts = require("scripts")
local E = require("entity_db")
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
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local valid_land_node_nearby = HU.valid_land_node_nearby
local v = V.v
local tt

local function decal_minidragon_faustus_update(this, store)
	local a = this.attacks.list[1]
	local af = this.pos.x > this.attack_pos.x
	local emit_angle = math.pi / 8
	local loop_duration = fts(18)
	local vx = this.motion.real_speed
	local attack_w = loop_duration * vx
	local emit_x = this.attack_pos.x + (af and 1 or -1) * (attack_w * 0.5 + this.emit_ox)
	local cast_x = this.attack_pos.x + (af and 1 or -1) * (attack_w * 0.5 + this.cast_ox)
	local emit_ts, cast_ts, emitting, casting
	local dest = v(0, this.pos.y)

	if af then
		this.pos.x = emit_x + math.ceil((store.visible_coords.right - emit_x + this.image_w) / attack_w) * attack_w
		dest.x = store.visible_coords.left - this.image_w
	else
		this.pos.x = emit_x - math.ceil((emit_x - store.visible_coords.left + this.image_w) / attack_w) * attack_w
		dest.x = store.visible_coords.right + this.image_w
	end

	local ps = E:create_entity("ps_minidragon_faustus_fire")

	ps.particle_system.track_id = this.id
	ps.particle_system.emit_direction = af and math.pi + emit_angle or -emit_angle
	ps.particle_system.emit_offset = v(a.bullet_start_offset.x * (af and -1 or 1), a.bullet_start_offset.y)
	ps.particle_system.emit = false

	simulation:queue_insert_entity(ps)
	U.set_destination(this, dest)
	U.animation_start(this, "idle", af, store.tick_ts, true, nil, true)

	while not this.motion.arrived do
		if not emit_ts and (af and emit_x >= this.pos.x or not af and emit_x <= this.pos.x) then
			S:queue(a.sound)
			U.animation_start(this, "fire", nil, store.tick_ts, false, 2)

			ps.particle_system.emit = true
			emit_ts = store.tick_ts
			emitting = true
		end

		if not cast_ts and (af and cast_x >= this.pos.x or not af and cast_x <= this.pos.x) then
			a.disabled = nil
			a.ts = store.tick_ts - a.cooldown
			cast_ts = store.tick_ts
			casting = true
		end

		if emitting and loop_duration < store.tick_ts - emit_ts then
			U.animation_start(this, "idle", nil, store.tick_ts, false, 2)

			ps.particle_system.emit = false
			emitting = false
		end

		if casting and loop_duration < store.tick_ts - cast_ts then
			a.disabled = true
			casting = false
		end

		if casting and store.tick_ts - a.ts > a.cooldown then
			local o_x = (af and -1 or 1) * this.cast_ox
			local o_y = table.random({-10, -5, 5, 10})
			local e = E:create_entity(a.bullet)

			e.pos.x, e.pos.y = this.pos.x + o_x, this.pos.y + o_y
			e.aura.ts = store.tick_ts

			simulation:queue_insert_entity(e)

			a.ts = store.tick_ts
		end

		U.walk_off__accel__unsnapped(this, store.tick_length)
		coroutine.yield()
	end

	simulation:queue_remove_entity(ps)
	simulation:queue_remove_entity(this)
end

local function bullet_liquid_fire_faustus_update(this, store)
	local b = this.bullet
	local tl = store.tick_length
	local node
	local target = store.entities[b.target_id]
	local mspeed = V.dist(b.to.x, b.to.y, b.from.x, b.from.y) / b.flight_time

	if not target then
		simulation:queue_remove_entity(this)

		return
	end

	local nodes = P:nearest_nodes(b.to.x, b.to.y, {target.nav_path.pi}, {target.nav_path.spi}, true)

	if #nodes > 0 then
		node = {
			pi = nodes[1][1],
			spi = nodes[1][2],
			ni = nodes[1][3]
		}
	end

	if not node then
		log.debug("cannot deploy bullet_liquid_fire_faustus: no destination node")
		simulation:queue_remove_entity(this)

		return
	end

	local node_pos = P:node_pos(node.pi, node.spi, node.ni)
	local dist = V.dist(node_pos.x, node_pos.y, b.from.x, b.from.y)
	local ps = E:create_entity(b.particles_name)

	ps.pos.x, ps.pos.y = b.from.x, b.from.y
	ps.particle_system.emit_direction = V.angleTo(node_pos.x - b.from.x, node_pos.y - b.from.y)
	ps.particle_system.emit_rotation = ps.particle_system.emit_direction
	ps.particle_system.emit_speed = {dist / fts(10), dist / fts(10)}

	simulation:queue_insert_entity(ps)

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * tl do
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * tl, this.pos.y + b.speed.y * tl

		coroutine.yield()
	end

	local fx = E:create_entity("fx_bullet_liquid_fire_faustus_hit")

	fx.pos.x, fx.pos.y = node_pos.x, node_pos.y
	fx.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(fx)

	local nn, a

	for i = 1, this.flames_count do
		nn = {
			pi = node.pi,
			spi = km.zmod(node.spi + 2 * (i - 1), 3),
			ni = node.ni + (i - 1) * 2
		}

		if not P:is_node_valid(nn.pi, nn.ni) then
			goto flame_mid
		end

		a = E:create_entity("aura_liquid_fire_flame_faustus")
		a.pos = P:node_pos(nn.pi, nn.spi, nn.ni)
		a.pos.x = a.pos.x + math.random(-8, 8)
		a.aura.ts = store.tick_ts

		simulation:queue_insert_entity(a)

		::flame_mid::

		if i == 1 then
			goto flame_end
		end

		nn = {
			pi = node.pi,
			spi = km.zmod(node.spi + 2 * (i - 1), 3),
			ni = node.ni - (i - 1) * 2
		}

		if not P:is_node_valid(nn.pi, nn.ni) then
			break
		end

		a = E:create_entity("aura_liquid_fire_flame_faustus")
		a.pos = P:node_pos(nn.pi, nn.spi, nn.ni)
		a.pos.x = a.pos.x + math.random(-8, 8)
		a.aura.ts = store.tick_ts

		simulation:queue_insert_entity(a)

		::flame_end::

		U.y_wait_unconditional(store, 0.25)
	end

	simulation:queue_remove_entity(this)
end

local function hero_faustus_level_up(this, store)
	local hl, ls = level_up_basic(this)
	local b = E:get_template(this.ranged.attacks[1].bullet)

	b.bullet.damage_max = ls.ranged_damage_max[hl]
	b.bullet.damage_min = ls.ranged_damage_min[hl]

	upgrade_skill(this, "dragon_lance", function(this, s)
		local a = this.ranged.attacks[2]

		a.disabled = nil

		local b = E:get_template(a.bullet)

		b.bullet.damage_max = s.damage_max[s.level]
		b.bullet.damage_min = s.damage_min[s.level]
	end)
	upgrade_skill(this, "teleport_rune", function(this, s)
		local a = this.ranged.attacks[3]

		a.disabled = nil

		local aura = E:get_template(a.bullet)

		aura.aura.targets_per_cycle = s.max_targets[s.level]
	end)
	upgrade_skill(this, "enervation", function(this, s)
		local a = this.ranged.attacks[4]

		a.disabled = nil

		local aura = E:get_template(a.bullet)

		aura.aura.targets_per_cycle = s.max_targets[s.level]

		local mod = E:get_template(aura.aura.mod)

		mod.modifier.duration = s.duration[s.level]
	end)
	upgrade_skill(this, "liquid_fire", function(this, s)
		local a = this.ranged.attacks[5]

		a.disabled = nil

		local b = E:get_template(a.bullet)

		b.flames_count = s.flames_count[s.level]

		local m = E:get_template("mod_liquid_fire_faustus")

		m.dps.damage_max = s.mod_damage[s.level]
		m.dps.damage_min = s.mod_damage[s.level]
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		this.ultimate.disabled = nil

		local m = E:get_template("mod_minidragon_faustus")

		m.dps.damage_max = s.mod_damage[s.level]
		m.dps.damage_min = s.mod_damage[s.level]
	end)
	upgrade_skill(this, "urination", function(this, s)
		this.ranged.attacks[1].bullet_count = s.count[s.level]
		this.ranged.attacks[2].bullet_count = s.count[s.level]
	end)
	update_hp(this)
end

local function hero_faustus_update(this, store)
	local h = this.health

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
			local target = find_target_at_critical_moment(this, this.ranged.attacks[1].max_range, F_RANGED, F_NONE, nil, true)

			if target and target.pos and valid_land_node_nearby(target.pos) then
				S:queue(this.sound_events.change_rally_point)

				local e = E:create_entity(this.hero.skills.ultimate.controller_name)

				e.pos = V.vclone(target.pos)

				simulation:queue_insert_entity(e)

				this.ultimate.ts = store.tick_ts

				SU.hero_gain_xp_from_skill(this, this.ultimate)
			else
				this.ultimate.ts = this.ultimate.ts + 1
			end
		end

		for _, i in ipairs(this.ranged.order) do
			local a = this.ranged.attacks[i]

			if a.disabled then
			-- block empty
			elseif a.sync_animation and not this.render.sprites[1].sync_flag then
			-- block empty
			elseif store.tick_ts - a.ts < a.cooldown * this.unit.cooldown_factor then
			-- block empty
			else
				local flight_time = a.estimated_flight_time or 1
				local target = U.find_random_enemy(store, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans, function(e)
					if i == 4 and not U.enemy_is_silent_target(e) then
						return false
					end

					if a.target_offset_rect then
						local node_offset = P:predict_enemy_node_advance(e, a.shoot_time + flight_time)
						local e_pos = P:node_pos(e.nav_path.pi, e.nav_path.spi, e.nav_path.ni + node_offset)
						local is_inside = V.is_inside(V.v(math.abs(e_pos.x - this.pos.x), e_pos.y - this.pos.y), a.target_offset_rect)

						if not is_inside then
							return false
						end

						if a.max_count_range and a.min_count then
							local min_count_pos = P:node_pos(e.nav_path.pi, e.nav_path.spi, e.nav_path.ni - a.min_count_nodes_offset)
							local nearby = U.find_enemies_in_range_filter_off(min_count_pos, a.max_count_range, a.vis_flags, a.vis_bans)

							return nearby and #nearby >= a.min_count
						end

						return true
					else
						return true
					end
				end)

				if target then
					local start_ts = store.tick_ts
					local start_fx, b, targets
					local node_offset = P:predict_enemy_node_advance(target, flight_time)
					local t_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + node_offset)
					local an, af, ai = U.animation_name_facing_point(this, a.animation, t_pos)

					U.animation_start_default(this, an, af, store.tick_ts)
					S:queue(a.start_sound, a.start_sound_args)

					if a.start_fx then
						local fx = E:create_entity(a.start_fx)

						fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
						fx.render.sprites[1].ts = store.tick_ts
						fx.render.sprites[1].flip_x = af

						simulation:queue_insert_entity(fx)

						start_fx = fx
					end

					while store.tick_ts - start_ts < a.shoot_time do
						if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
							goto label_112_0
						end

						coroutine.yield()
					end

					S:queue(a.sound)

					targets = {}

					if a.bullet_count then
						local extra_targets = U.find_enemies_in_range_filter_off(target.pos, a.extra_range, a.vis_flags, a.vis_bans)

						if not extra_targets then
							goto label_112_0
						end

						for i = 1, a.bullet_count do
							table.insert(targets, extra_targets[km.zmod(i, #extra_targets)])
						end
					else
						targets = {target}
					end

					for i, t in ipairs(targets) do
						b = E:create_entity(a.bullet)

						if a.type == "aura" then
							b.pos.x, b.pos.y = target.pos.x, target.pos.y
							b.aura.ts = store.tick_ts
						else
							b.bullet.target_id = t.id
							b.bullet.source_id = this.id
							b.bullet.xp_dest_id = this.id
							b.bullet.damage_factor = this.unit.damage_factor

							b.pos:copy(this.pos)

							b.pos.x = b.pos.x + (af and -1 or 1) * a.bullet_start_offset[ai].x
							b.pos.y = b.pos.y + a.bullet_start_offset[ai].y

							b.bullet.from:copy(b.pos)

							b.bullet.to = V.v(t.pos.x + t.unit.hit_offset.x, t.pos.y + t.unit.hit_offset.y)
							b.bullet.shot_index = i

							if i == 1 then
								b.initial_impulse = 0
							end
						end

						simulation:queue_insert_entity(b)
					end

					if a.xp_from_skill then
						SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
					end

					a.ts = start_ts

					while not U.animation_finished_default(this) do
						if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
							goto label_112_0
						end

						coroutine.yield()
					end

					U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)

					::label_112_0::

					if start_fx then
						start_fx.render.sprites[1].hidden = true
					end

					goto label_112_1
				end
			end
		end

		SU.soldier_idle(store, this)
		SU.soldier_regen(store, this)

		::label_112_1::

		coroutine.yield()
	end
end

local function hero_faustus_ultimate_update(this, store)
	local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)

	if #nodes < 1 then
		log.error("hero_faustus_ultimate: could not find valid node")
		simulation:queue_remove_entity(this)

		return
	end

	local node = {
		spi = 1,
		pi = nodes[1][1],
		ni = nodes[1][3]
	}
	local node_offsets = {0, -this.separation_nodes, this.separation_nodes}
	local node_pos = P:node_pos(node.pi, node.spi, node.ni)
	local from_y = node_pos.y

	for i = 1, 3 do
		if P:is_node_valid(node.pi, node.ni + node_offsets[i]) then
			node_pos = P:node_pos(node.pi, node.spi, node.ni + node_offsets[i])
			from_y = node_pos.y
		end

		local e = E:create_entity("decal_minidragon_faustus")

		e.attack_pos = node_pos
		e.pos.x, e.pos.y = i % 2 == 0 and 2 * REF_W or -REF_W, from_y

		simulation:queue_insert_entity(e)
		U.y_wait_unconditional(store, this.show_delay)
	end

	simulation:queue_remove_entity(this)
end

tt = RT("hero_faustus", "hero")

AC(tt, "ranged")

tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.hp_max = {400, 425, 450, 475, 500, 525, 550, 575, 600, 625}
tt.hero.level_stats.melee_damage_max = {1, 2, 4, 4, 5, 6, 7, 8, 9, 10}
tt.hero.level_stats.melee_damage_min = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
tt.hero.level_stats.ranged_damage_min = {9, 11, 13, 15, 16, 18, 20, 22, 24, 25}
tt.hero.level_stats.ranged_damage_max = {14, 16, 19, 22, 24, 27, 30, 33, 35, 38}
tt.hero.skills.dragon_lance = CC("hero_skill")
tt.hero.skills.dragon_lance.damage_min = {53, 93, 135}
tt.hero.skills.dragon_lance.damage_max = {98, 173, 250}
tt.hero.skills.dragon_lance.xp_gain = {50, 100, 150}
tt.hero.skills.dragon_lance.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.teleport_rune = CC("hero_skill")
tt.hero.skills.teleport_rune.xp_gain = {75, 150, 225}
tt.hero.skills.teleport_rune.max_targets = {3, 5, 7}
tt.hero.skills.teleport_rune.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.enervation = CC("hero_skill")
tt.hero.skills.enervation.duration = {6, 9, 12}
tt.hero.skills.enervation.max_targets = {1, 2, 3}
tt.hero.skills.enervation.xp_gain = {30, 90, 180}
tt.hero.skills.enervation.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.liquid_fire = CC("hero_skill")
tt.hero.skills.liquid_fire.flames_count = {6, 12, 18}
tt.hero.skills.liquid_fire.mod_damage = {4, 6, 8}
tt.hero.skills.liquid_fire.xp_gain = {120, 240, 360}
tt.hero.skills.liquid_fire.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.xp_gain_factor = 32
tt.hero.skills.ultimate.mod_damage = {2, 3, 5, 7}
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.urination = CC("hero_skill")
tt.hero.skills.urination.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.urination.count = {3, 4, 5}
tt.hero.skills.ultimate.controller_name = "hero_faustus_ultimate"
tt.health.dead_lifetime = 15
tt.health_bar.draw_order = -1
tt.health_bar.offset = vec_2(0, 189)
tt.health_bar.sort_y_offset = -200
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.hero.fn_level_up = hero_faustus_level_up
tt.idle_flip.cooldown = 10
tt.info.hero_portrait = "kr3_hero_portraits_0016"
tt.info.portrait = "kr3_info_portraits_heroes_0016"
tt.main_script.update = hero_faustus_update
tt.motion.max_speed = 6.6 * FPS
tt.nav_rally.requires_node_nearby = false
tt.nav_grid.ignore_waypoints = true
tt.nav_grid.valid_terrains = TERRAIN_ALL_MASK
tt.nav_grid.valid_terrains_dest = TERRAIN_ALL_MASK
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.065
tt.render.sprites[1].prefix = "hero_faustus"
tt.render.sprites[1].angles.walk = {"idle"}
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "faustus_hero_0233"
tt.render.sprites[2].anchor.y = 0.045
tt.render.sprites[2].alpha = 90
tt.sound_events.change_rally_point = "ElvesHeroFaustusTaunt"
tt.sound_events.death = "ElvesHeroFaustusDeath"
tt.sound_events.respawn = "ElvesHeroFaustusTauntIntro"
tt.sound_events.insert = "ElvesHeroFaustusTauntIntro"
tt.sound_events.hero_room_select = "ElvesHeroFaustusTauntSelect"
tt.ui.click_rect = r(-25, 100, 50, 55)
tt.unit.hit_offset = vec_2(0, 135)
tt.unit.hide_after_death = true
tt.unit.mod_offset = vec_2(0, 134)
tt.vis.bans = bor(tt.vis.bans, F_EAT, F_NET, F_POISON)
tt.vis.flags = bor(tt.vis.flags, F_FLYING)
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].bullet = "bolt_faustus"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(26, 80)}
tt.ranged.attacks[1].cooldown = 1
tt.ranged.attacks[1].bullet_count = 3
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].extra_range = 80
tt.ranged.attacks[1].shoot_time = fts(12)
tt.ranged.attacks[1].sync_animation = true
tt.ranged.attacks[1].animation = "attackBase"
tt.ranged.attacks[1].start_fx = "fx_faustus_start_attack"
tt.ranged.attacks[1].sound = "ElvesHeroFaustusAttack"
tt.ranged.attacks[2] = CC("bullet_attack")
tt.ranged.attacks[2].disabled = true
tt.ranged.attacks[2].bullet = "bolt_lance_faustus"
tt.ranged.attacks[2].bullet_count = 3
tt.ranged.attacks[2].bullet_start_offset = {vec_2(22, 110)}
tt.ranged.attacks[2].cooldown = 24
tt.ranged.attacks[2].max_range = 150
tt.ranged.attacks[2].extra_range = 80
tt.ranged.attacks[2].shoot_time = fts(22)
tt.ranged.attacks[2].sync_animation = true
tt.ranged.attacks[2].animation = "altAttackBase"
tt.ranged.attacks[2].start_fx = "fx_faustus_start_lance"
tt.ranged.attacks[2].start_sound = "ElvesHeroFaustusRayKill"
tt.ranged.attacks[2].start_sound_args = {
	delay = fts(12)
}
tt.ranged.attacks[2].target_offset_rect = r(40, -80, 110, 160)
tt.ranged.attacks[2].estimated_flight_time = 1
tt.ranged.attacks[2].xp_from_skill = "dragon_lance"
tt.ranged.attacks[3] = CC("aura_attack")
tt.ranged.attacks[3].disabled = true
tt.ranged.attacks[3].bullet = "aura_teleport_faustus"
tt.ranged.attacks[3].cooldown = 27
tt.ranged.attacks[3].min_range = 0
tt.ranged.attacks[3].max_range = 100
tt.ranged.attacks[3].shoot_time = fts(16)
tt.ranged.attacks[3].sync_animation = true
tt.ranged.attacks[3].animation = "altAttackBase"
tt.ranged.attacks[3].start_fx = "fx_faustus_start_teleport"
tt.ranged.attacks[3].start_sound = "ElvesHeroFaustusTeleport"
tt.ranged.attacks[3].start_sound_args = {
	delay = fts(12)
}
tt.ranged.attacks[3].estimated_flight_time = 1
tt.ranged.attacks[3].vis_flags = bor(F_RANGED, F_TELEPORT)
tt.ranged.attacks[3].vis_bans = bor(F_BOSS)
tt.ranged.attacks[3].xp_from_skill = "teleport_rune"
tt.ranged.attacks[4] = CC("aura_attack")
tt.ranged.attacks[4].disabled = true
tt.ranged.attacks[4].bullet = "aura_enervation_faustus"
tt.ranged.attacks[4].cooldown = 19
tt.ranged.attacks[4].min_range = 25
tt.ranged.attacks[4].max_range = 100
tt.ranged.attacks[4].shoot_time = fts(4)
tt.ranged.attacks[4].sync_animation = true
tt.ranged.attacks[4].animation = "idle"
tt.ranged.attacks[4].start_fx = "fx_faustus_start_enervation"
tt.ranged.attacks[4].start_sound = "ElvesHeroFaustusEnervation"
tt.ranged.attacks[4].estimated_flight_time = 0
tt.ranged.attacks[4].vis_flags = bor(F_RANGED)
tt.ranged.attacks[4].vis_bans = bor(F_BOSS)
tt.ranged.attacks[4].xp_from_skill = "enervation"
tt.ranged.attacks[5] = CC("bullet_attack")
tt.ranged.attacks[5].animation = "attackBase"
tt.ranged.attacks[5].bullet = "bullet_liquid_fire_faustus"
tt.ranged.attacks[5].bullet_start_offset = {vec_2(30, 86)}
tt.ranged.attacks[5].cooldown = 38
tt.ranged.attacks[5].disabled = true
tt.ranged.attacks[5].estimated_flight_time = fts(10)
tt.ranged.attacks[5].max_range = 180
tt.ranged.attacks[5].min_range = 50
tt.ranged.attacks[5].min_count = 3
tt.ranged.attacks[5].max_count_range = 120
tt.ranged.attacks[5].min_count_nodes_offset = -5
tt.ranged.attacks[5].shoot_time = fts(12)
tt.ranged.attacks[5].start_fx = "fx_faustus_start_liquid_fire"
tt.ranged.attacks[5].start_sound = "ElvesHeroFaustusFire"
tt.ranged.attacks[5].sync_animation = true
tt.ranged.attacks[5].target_offset_rect = r(50, -80, 130, 160)
tt.ranged.attacks[5].vis_bans = bor(F_FLYING)
tt.ranged.attacks[5].xp_from_skill = "liquid_fire"
tt.ultimate = {
	ts = 0,
	cooldown = 32,
	disabled = true
}
tt = RT("bolt_faustus", "bolt_elves")
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.hit_fx = "fx_bolt_faustus_hit"
tt.bullet.particles_name = "ps_bolt_faustus"
tt.bullet.xp_gain_factor = 1.9
tt.initial_impulse = 2100
tt.render.sprites[1].prefix = "bolt_faustus"
tt.sound_events.insert = nil
tt.upgrades_disabled = true
tt = RT("bolt_lance_faustus", "bolt")
tt.bullet.acceleration_factor = 0.25
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.hit_fx = "fx_bolt_lance_faustus_hit"
tt.bullet.ignore_hit_offset = true
tt.bullet.max_speed = 600
tt.bullet.min_speed = 600
tt.bullet.pop = nil
tt.bullet.particles_name = "ps_bolt_lance_faustus"
tt.render.sprites[1].prefix = "bolt_lance_faustus"
tt.render.sprites[1].hidden = true
tt.sound_events.insert = nil
tt = RT("bullet_liquid_fire_faustus", "bullet")
tt.main_script.update = bullet_liquid_fire_faustus_update
tt.render = nil
tt.bullet.particles_name = "ps_bullet_liquid_fire_faustus"
tt.bullet.flight_time = fts(10)
tt.bullet.hit_fx = "fx_bullet_liquid_fire_faustus_hit"
tt = RT("aura_liquid_fire_flame_faustus", "aura")

AC(tt, "render", "tween")

tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.aura.mod = "mod_liquid_fire_faustus"
tt.aura.duration = 8
tt.aura.cycle_time = fts(10)
tt.aura.radius = 35
tt.aura.vis_flags = bor(F_RANGED)
tt.aura.vis_bans = bor(F_FRIEND)
tt.render.sprites[1].name = "aura_liquid_fire_flame_faustus"
tt.sound_events.insert = "ElvesHeroFaustusFireLoop"
tt.sound_events.remove_stop = "ElvesHeroFaustusFireLoop"
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {0.25, 255}, {"this.aura.duration-1", 255}, {"this.aura.duration", 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_1(0.5)}, {0.5, vec_1(1)}}
tt = RT("aura_minidragon_faustus", "aura_liquid_fire_flame_faustus")
tt.aura.mod = "mod_minidragon_faustus"
tt.tween.props[1].keys = {{0, 0}, {0.05, 255}, {"this.aura.duration-1", 255}, {"this.aura.duration", 0}}
tt.tween.props[2] = nil
tt = RT("aura_teleport_faustus", "aura")

AC(tt, "render", "tween")

tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.aura.mod = "mod_teleport_faustus"
tt.aura.cycle_time = 1000000000
tt.aura.duration = fts(50)
tt.aura.radius = 75
tt.aura.vis_flags = bor(F_RANGED, F_TELEPORT)
tt.aura.vis_bans = bor(F_BOSS, F_FRIEND, F_HERO, F_FREEZE)
tt.render.sprites[1].name = "aura_teleport_faustus"
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 55}, {fts(10), 255}, {fts(40), 255}, {fts(50), 0}}
tt.render.sprites[1].scale = vec_1(1.45)
tt = RT("mod_teleport_faustus", "mod_teleport")
tt.modifier.vis_flags = bor(F_MOD, F_TELEPORT)
tt.modifier.vis_bans = bor(F_BOSS)
tt.max_times_applied = nil
tt.nodes_offset = -35
-- tt.delay_start = fts(2)
tt.delay_start = fts(32)
tt.hold_time = 0.4
tt.delay_end = fts(2)
tt.fx_start = "fx_teleport_faustus"
tt.fx_end = "fx_teleport_faustus"
tt.damage_base = 50
tt.damage_inc = 25
tt = RT("hero_faustus_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.main_script.update = hero_faustus_ultimate_update
tt.sound_events.insert = "ElvesHeroFaustusUltimate"
tt.separation_nodes = 20
tt.show_delay = 0.5
tt = RT("ps_bolt_faustus")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "bolt_faustus_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.emission_rate = 30
tt.particle_system.emit_rotation_spread = math.pi
tt = RT("ps_bolt_lance_faustus")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "bolt_lance_faustus_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.emission_rate = 90
tt.particle_system.emit_rotation_spread = math.pi
tt = RT("ps_bullet_liquid_fire_faustus")

AC(tt, "pos", "particle_system")

tt.particle_system.emission_rate = 20
tt.particle_system.emit_duration = fts(10)
tt.particle_system.emit_speed = {250, 250}
tt.particle_system.emit_rotation_spread = math.pi / 4
tt.particle_system.animated = true
tt.particle_system.animation_fps = 18
tt.particle_system.loop = false
tt.particle_system.name = "bullet_liquid_fire_faustus_particle"
tt.particle_system.particle_lifetime = {fts(9), fts(11)}
tt.particle_system.alphas = {255, 255, 50}
tt.particle_system.scales_x = {1, 1, 1.5}
tt.particle_system.scales_y = {1, 1, 1.5}
tt.particle_system.spin = {-math.pi * 0.5, math.pi * 0.5}
tt.particle_system.sort_y_offsets = {-100, 0}
tt = RT("ps_minidragon_faustus_fire", "ps_bullet_liquid_fire_faustus")
tt.particle_system.emit_duration = nil
tt.particle_system.emit_speed = {500, 500}
tt.particle_system.emit_rotation_spread = math.pi / 8
tt = RT("fx_faustus_start_attack", "fx")
tt.render.sprites[1].name = "fx_faustus_attack"
tt.render.sprites[1].anchor.y = 0.065
tt = RT("fx_faustus_start_lance", "fx")
tt.render.sprites[1].name = "hero_faustus_rayShoot"
tt.render.sprites[1].anchor.y = 0.065
tt.render.sprites[1].sort_y_offset = -1
tt = RT("fx_faustus_start_teleport", "fx")
tt.render.sprites[1].name = "hero_faustus_teleport"
tt.render.sprites[1].anchor.y = 0.065
tt.render.sprites[1].sort_y_offset = -1
tt = RT("fx_faustus_start_enervation", "fx")
tt.render.sprites[1].name = "hero_faustus_silence"
tt.render.sprites[1].anchor.y = 0.065
tt.render.sprites[1].sort_y_offset = -1
tt = RT("fx_faustus_start_liquid_fire", "fx")
tt.render.sprites[1].name = "fx_faustus_start_liquid_fire"
tt.render.sprites[1].anchor.y = 0.065
tt.render.sprites[1].sort_y_offset = -1
tt = RT("fx_bolt_faustus_hit", "fx")
tt.render.sprites[1].name = "bolt_faustus_hit"
tt = RT("fx_bolt_lance_faustus_hit", "fx")
tt.render.sprites[1].anchor.y = 0.21428571428571427
tt.render.sprites[1].prefix = "fx_bolt_lance_faustus_hit"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt = RT("fx_teleport_faustus", "fx")
tt.render.sprites[1].name = "fx_teleport_faustus"
tt.render.sprites[1].size_scales = {vec_1(0.83), vec_1(1), vec_1(1)}
tt = RT("fx_bullet_liquid_fire_faustus_hit", "decal_tween")
tt.render.sprites[1].name = "fx_bullet_liquid_fire_faustus_hit"
tt.render.sprites[1].anchor.y = 0.16666666666666666
tt.tween.props[1].keys = {{0, 0}, {0.1, 255}, {2, 0}}
tt = RT("decal_minidragon_faustus", "decal_scripted")

AC(tt, "motion", "attacks")

tt.main_script.update = decal_minidragon_faustus_update
tt.motion.max_speed = 10 * FPS
tt.attacks.list[1] = CC("aura_attack")
tt.attacks.list[1].disabled = true
tt.attacks.list[1].bullet = "aura_minidragon_faustus"
tt.attacks.list[1].bullet_start_offset = vec_2(25, 70)
tt.attacks.list[1].cooldown = fts(2)
tt.attacks.list[1].sound = "ElvesHeroFaustusFire"
tt.render.sprites[1].prefix = "minidragon_faustus_l1"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[1].offset = vec_2(0, 70)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "minidragon_faustus_l2"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].z = Z_BULLETS
tt.render.sprites[2].offset = vec_2(0, 70)
tt.emit_ox = 180
tt.cast_ox = 80
tt.image_w = 40
tt = RT("aura_enervation_faustus", "aura")
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.aura.mod = "mod_enervation_faustus"
tt.aura.cycle_time = 0
tt.aura.cycles = 1
tt.aura.radius = 100
tt.aura.vis_flags = bor(F_RANGED)
tt.aura.vis_bans = bor(F_BOSS, F_FRIEND, F_HERO)
tt = RT("mod_enervation_faustus", "modifier")

AC(tt, "render", "tween")

tt.main_script.insert = scripts.mod_silence.insert
tt.main_script.remove = scripts.mod_silence.remove
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.duration = nil
tt.render.sprites[1].prefix = "mod_enervation_faustus"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {0.25, 255}}
tt = RT("mod_liquid_fire_faustus", "modifier")

AC(tt, "dps", "render")

tt.dps.damage_max = nil
tt.dps.damage_min = nil
tt.dps.damage_type = DAMAGE_TRUE
tt.dps.damage_every = fts(6)
tt.dps.kill = true
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt.modifier.duration = 1
tt.render.sprites[1].prefix = "mod_liquid_fire_faustus"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.render.sprites[1].draw_order = 10
tt = RT("mod_minidragon_faustus", "mod_liquid_fire_faustus")
