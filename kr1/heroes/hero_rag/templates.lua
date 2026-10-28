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
local band = bit.band
local bor = bit.bor
local find_target_at_critical_moment = HU.find_target_at_critical_moment
local fts = U.fts
local level_up_basic = HU.level_up_basic
local queue_damage = U.queue_damage
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local valid_land_node_nearby = HU.valid_land_node_nearby
local tt

local function mod_rag_raggified_update(this, store)
	local function add_fx(target, pos)
		local fx = E:create_entity(this.fx)
		local s = fx.render.sprites[1]

		s.ts = store.tick_ts

		if s.size_scales then
			s.scale = s.size_scales[target.unit.size]
		end

		fx.pos:copy(pos)

		if target.unit.hit_offset then
			fx.pos.x, fx.pos.y = fx.pos.x + target.unit.hit_offset.x, fx.pos.y + target.unit.hit_offset.y
		end

		simulation:queue_insert_entity(fx)
	end

	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or target.health.dead or band(target.vis.bans, F_RAGGIFY) ~= 0 then
		simulation:queue_remove_entity(this)

		return
	end

	U.bans_add(target.vis, F_RAGGIFY)
	add_fx(target, target.pos)
	SU.remove_modifiers(store, target, nil, "mod_rag_raggified")
	SU.remove_auras(store, target)
	simulation:queue_remove_entity(target)

	target.health.dead = true
	target.main_script.co = nil
	target.main_script.runs = 0

	U.unblock_all(store, target)

	if target.ui then
		target.ui.can_click = false
	end

	if target.count_group then
		target.count_group.in_limbo = true
	end

	local e = E:create_entity(this.entity_name)

	e.pos = V.vclone(target.pos)

	if target.melee then
		e.melee.attacks[1].damage_max = target.melee.attacks[1].damage_max
		e.melee.attacks[1].damage_min = target.melee.attacks[1].damage_min
	end

	e.health.hp_max = target.health.hp
	e.health.hp = target.health.hp
	e.nav_rally.center = V.vclone(target.pos)
	e.nav_rally.pos = V.vclone(target.pos)
	e.render.sprites[1].flip_x = target.render.sprites[1].flip_x
	e.render.sprites[1].scale = target.unit.size == UNIT_SIZE_SMALL and V.vv(0.75) or V.vv(1)

	simulation:queue_insert_entity(e)

	local start_ts = store.tick_ts

	while (not e.health.dead) and (e.health.hp_max - e.health.hp < e.health.hp_max * this.break_factor or store.tick_ts - start_ts < this.doll_duration) do
		coroutine.yield()
	end

	if not e.health.dead then
		local hp = e.health.hp

		e.health.dead = true

		simulation:queue_remove_entity(e)

		local nodes = P:nearest_nodes(e.pos.x, e.pos.y, {target.nav_path.pi}, nil)

		if #nodes > 0 then
			target.nav_path.ni = nodes[1][3] + 1
		end

		target.pos = V.vclone(e.pos)
		target.main_script.runs = 1
		target.health.dead = false
		target.health.hp = hp

		if target.ui then
			target.ui.can_click = true
		end

		if target.count_group then
			target.count_group.in_limbo = nil
		end

		U.bans_remove(target.vis, F_RAGGIFY)
		simulation:queue_insert_entity(target)
	else
		store.player_gold = store.player_gold + target.enemy.gold
	end

	add_fx(target, e.pos)
	simulation:queue_remove_entity(this)
end

local function hero_rag_ultimate_update(this, store)
	SU.insert_sprite(store, this.hit_fx, this.pos)
	SU.insert_sprite(store, this.hit_decal, this.pos)
	U.y_wait_unconditional(store, this.hit_time)

	local targets = U.find_enemies_in_range_filter_on(this.pos, this.range, this.vis_flags, this.vis_bans, function(e)
		return GR:cell_is_only(e.pos.x, e.pos.y, bor(TERRAIN_LAND, TERRAIN_ICE))
	end)

	if targets then
		for i, target in ipairs(targets) do
			if i > this.max_count then
				break
			end

			local m = E:create_entity(this.mod)

			m.modifier.source_id = this.id
			m.modifier.target_id = target.id
			m.doll_duration = this.doll_duration * U.frandom(0.97, 1.03)

			simulation:queue_insert_entity(m)
		end
	end

	simulation:queue_remove_entity(this)
end

local function hero_rag_level_up(this, store, initial)
	local hl, ls = level_up_basic(this, store)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local bt = E:get_template(this.ranged.attacks[1].bullet)

	bt.bullet.damage_min = ls.ranged_damage_min[hl]
	bt.bullet.damage_max = ls.ranged_damage_max[hl]

	upgrade_skill(this, "raggified", function(this, s)
		local a = this.timed_attacks.list[4]

		a.disabled = nil
		a.max_target_hp = s.max_target_hp[s.level]

		local m = E:get_template("mod_rag_raggified")

		m.doll_duration = s.doll_duration[s.level]
		m.break_factor = s.break_factor[s.level]
	end)
	upgrade_skill(this, "kamihare", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.count = s.count[s.level]
	end)
	upgrade_skill(this, "angry_gnome", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil

		for _, n in pairs(a.things) do
			local b = E:get_template(a.bullet_prefix .. n)

			b.bullet.damage_max = s.damage_max[s.level]
			b.bullet.damage_min = s.damage_min[s.level]
		end
	end)
	upgrade_skill(this, "hammer_time", function(this, s)
		local a = this.timed_attacks.list[3]

		a.disabled = nil
		a.duration = s.duration[s.level]
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		this.ultimate.disabled = nil

		local u = E:get_template(s.controller_name)

		u.max_count = s.max_count[s.level]
	end)
	update_hp(this)
end

local function hero_rag_update(this, store)
	local h = this.health
	local a, skill, brk, sta, ranged_done

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
					goto label_144_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[4]
			skill = this.hero.skills.raggified

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local target = U.find_random_enemy(store, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans, function(e)
					return e.health.hp < a.max_target_hp * this.unit.damage_factor and GR:cell_is_only(e.pos.x, e.pos.y, bor(TERRAIN_LAND, TERRAIN_ICE))
				end)

				if not target then
					a.ts = a.ts + 0.16666666666666666
				else
					a.ts = store.tick_ts

					if not SU.y_soldier_do_ranged_attack(store, this, target, a) then
						goto label_144_0
					end
				end
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.kamihare

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local target_info = U.find_enemies_in_paths(store.enemies, this.pos, a.range_nodes_min, a.range_nodes_max, nil, a.vis_flags, a.vis_bans, true, function(e)
					return not U.flag_has(P:path_terrain_props(e.nav_path.pi), bor(TERRAIN_FAERIE, TERRAIN_WATER))
				end)

				if not target_info then
					a.ts = a.ts + 0.16666666666666666
				else
					local origin = target_info[1].origin
					local bullet_to_ni = origin[3] - 5
					local bullet_to = P:node_pos(origin[1], 1, bullet_to_ni)
					local flip = bullet_to.x < this.pos.x

					S:queue(a.sound, {
						delay = a.sound_delay
					})
					U.animation_start_default(this, a.animations[1], flip, store.tick_ts)

					if SU.y_soldier_wait(store, this, a.spawn_time) then
					-- block empty
					else
						SU.hero_gain_xp_from_skill(this, skill)

						a.ts = store.tick_ts

						for i = 1, a.count do
							SU.y_soldier_wait(store, this, fts(2))

							local pi, spi, ni = origin[1], km.zmod(i, 3), bullet_to_ni + math.random(-10, 0)

							if not P:is_node_valid(pi, ni) then
								log.debug("cannot spawn kamihare in invalid node: %s,%s,%s", pi, spi, ni)
							else
								local e = E:create_entity(a.entity)

								e.pos = P:node_pos(pi, spi, ni)
								e.nav_path.pi = pi
								e.nav_path.spi = spi
								e.nav_path.ni = ni
								e.damage_factor = this.unit.damage_factor

								local b = E:create_entity(a.bullet)

								b.pos.x = this.pos.x + math.random(-3, 3) + a.spawn_offset.x
								b.pos.y = this.pos.y + math.random(0, 3) + a.spawn_offset.y

								b.bullet.from:copy(b.pos)
								b.bullet.to:copy(e.pos)

								b.bullet.hit_payload = e
								b.bullet.damage_factor = this.unit.damage_factor
								b.render.sprites[1].flip_x = flip
								b.render.sprites[1].ts = store.tick_ts

								simulation:queue_insert_entity(b)
							end
						end

						U.animation_start_default(this, a.animations[2], nil, store.tick_ts)
						SU.y_hero_animation_wait(this)

						a.ts = store.tick_ts
					end

					goto label_144_0
				end
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.angry_gnome

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local target = U.find_random_enemy(store, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if not target then
					a.ts = a.ts + 0.13333333333333333
				else
					local pred_pos = P:predict_enemy_pos(target, fts(12))
					local thing = table.random(a.things)

					a.animation = "throw_" .. thing
					a.bullet = a.bullet_prefix .. thing
					a.ts = store.tick_ts

					if not SU.y_soldier_do_ranged_attack(store, this, target, a, pred_pos) then
						goto label_144_0
					end
				end
			end

			a = this.timed_attacks.list[3]
			skill = this.hero.skills.hammer_time

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local nodes, start_node, end_node, next_node, damage_ts
				local target, targets = U.find_nearest_enemy(store, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans)
				local total_hp = not targets and 0 or table.reduce(targets, function(e, hp_sum)
					return e.health.hp + hp_sum
				end)

				if not target or total_hp < a.trigger_hp then
					a.ts = a.ts + 0.13333333333333333
				else
					U.unblock_target(store, this)
					S:queue(a.sound_loop)
					U.y_animation_play(this, a.animations[1], nil, store.tick_ts)

					if SU.hero_interrupted(this) then
					-- block empty
					else
						SU.hero_gain_xp_from_skill(this, skill)

						a.ts = store.tick_ts
						nodes = P:nearest_nodes(this.pos.x, this.pos.y, {target.nav_path.pi}, nil, true)

						if #nodes == 0 then
							log.error("hammer_time could not find a valid node near %s,%s", this.pos.x, this.pos.y)

							goto label_144_0
						end

						start_node = {
							pi = nodes[1][1],
							spi = nodes[1][2],
							ni = nodes[1][3]
						}
						end_node = table.deepclone(target.nav_path)
						next_node = table.deepclone(start_node)
						next_node.dir = start_node.ni > end_node.ni and -1 or 1
						end_node.ni = next_node.dir * a.nodes_range + start_node.ni

						U.animation_start_default(this, a.animations[2], nil, store.tick_ts, true)

						damage_ts = store.tick_ts - a.damage_every

						while store.tick_ts - a.ts < a.duration and not SU.hero_interrupted(this) do
							if U.walk_off__accel__unsnapped(this, store.tick_length) then
								if math.abs(next_node.ni - start_node.ni) == a.nodes_range then
									next_node.dir = next_node.dir * -1
								end

								next_node.ni = next_node.ni + next_node.dir
								next_node.spi = next_node.spi == 3 and 2 or 3

								U.set_destination(this, P:node_pos(next_node.pi, next_node.spi, next_node.ni))

								this.render.sprites[1].flip_x = this.motion.dest.x < this.pos.x
							end

							if store.tick_ts - damage_ts >= a.damage_every then
								damage_ts = store.tick_ts

								S:queue(a.sound_hit)

								local targets = U.find_enemies_in_range_filter_off(this.pos, a.damage_radius, a.vis_flags, a.vis_bans)

								if targets then
									for _, t in ipairs(targets) do
										local d = SU.create_attack_damage(a, t.id, this)

										queue_damage(store, d)

										local m = E:create_entity(a.mod)

										m.modifier.source_id = this.id
										m.modifier.target_id = t.id

										simulation:queue_insert_entity(m)
									end
								end
							end

							coroutine.yield()
						end
					end

					a.ts = store.tick_ts - (1 - km.clamp(0, 1, (store.tick_ts - a.ts) / a.duration)) * a.cooldown

					S:stop(a.sound_loop)
					U.y_animation_play(this, a.animations[3], nil, store.tick_ts)

					goto label_144_0
				end
			end

			if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
				local target = find_target_at_critical_moment(this, this.ranged.attacks[1].max_range, F_RANGED, bor(F_FLYING, F_BOSS), nil, false, false)

				if target and target.pos and valid_land_node_nearby(target.pos) then
					this.health.ignore_damage = true

					U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

					this.health.ignore_damage = false

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

			if not ranged_done then
				brk, sta = SU.y_soldier_ranged_attacks(store, this)

				if brk then
					goto label_144_0
				end

				if sta == A_DONE then
					ranged_done = true
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta == A_DONE or sta == A_NO_TARGET then
				ranged_done = nil
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

		::label_144_0::

		coroutine.yield()
	end
end

tt = RT("hero_rag", "hero")

AC(tt, "melee", "ranged", "timed_attacks")

tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.hp_max = {380, 405, 440, 465, 490, 515, 550, 575, 600, 625}
tt.hero.level_stats.melee_damage_max = {12, 14, 16, 17, 19, 21, 23, 25, 26, 28}
tt.hero.level_stats.melee_damage_min = {8, 9, 10, 12, 13, 14, 15, 16, 18, 19}
tt.hero.level_stats.ranged_damage_max = {12, 14, 16, 17, 19, 21, 23, 25, 26, 28}
tt.hero.level_stats.ranged_damage_min = {8, 9, 10, 12, 13, 14, 15, 16, 18, 19}
tt.hero.skills.raggified = CC("hero_skill")
tt.hero.skills.raggified.max_target_hp = {600, 1500, 10000}
tt.hero.skills.raggified.xp_gain = {94, 188, 282}
tt.hero.skills.raggified.doll_duration = {5, 7, 9}
tt.hero.skills.raggified.break_factor = {0.25, 0.375, 0.5}
tt.hero.skills.raggified.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.kamihare = CC("hero_skill")
tt.hero.skills.kamihare.count = {4, 8, 12}
tt.hero.skills.kamihare.xp_gain = {70, 140, 210}
tt.hero.skills.kamihare.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.angry_gnome = CC("hero_skill")
tt.hero.skills.angry_gnome.damage_max = {75, 150, 225}
tt.hero.skills.angry_gnome.damage_min = {35, 70, 105}
tt.hero.skills.angry_gnome.xp_gain = {21, 42, 63}
tt.hero.skills.angry_gnome.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.hammer_time = CC("hero_skill")
tt.hero.skills.hammer_time.duration = {3, 4, 5}
tt.hero.skills.hammer_time.xp_gain = {105, 210, 315}
tt.hero.skills.hammer_time.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_rag_ultimate"
tt.hero.skills.ultimate.max_count = {2, 4, 6, 8}
tt.hero.skills.ultimate.xp_gain_factor = 48
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, 58)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_rag_level_up
tt.hero.tombstone_show_time = fts(90)
tt.info.hero_portrait = "kr3_hero_portraits_0006"
tt.info.portrait = "kr3_info_portraits_heroes_0006"
tt.main_script.update = hero_rag_update
tt.motion.max_speed = 2.2 * FPS
tt.regen.cooldown = 1

for i = 1, 2 do
	tt.render.sprites[i] = CC("sprite")
	tt.render.sprites[i].anchor.y = 0.239
	tt.render.sprites[i].prefix = "hero_rag_layer" .. i
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].angles = {}
	tt.render.sprites[i].angles.walk = {"running"}
end

tt.soldier.melee_slot_offset = vec_2(7, 0)
tt.sound_events.change_rally_point = "ElvesHeroRagTaunt"
tt.sound_events.death = "ElvesHeroRagDeath"
tt.sound_events.insert = "ElvesHeroRagTauntIntro"
tt.sound_events.respawn = "ElvesHeroRagTauntIntro"
tt.sound_events.hero_room_select = "ElvesHeroRagTauntSelect"
tt.unit.hit_offset = vec_2(0, 16)
tt.unit.mod_offset = vec_2(6, 20)
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].hit_offset = vec_2(32, -5)
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].hit_time = fts(11)
tt.melee.attacks[1].damage_radius = 75
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].count = 5
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].xp_gain_factor = 2
tt.melee.attacks[1].sound_hit = "ElvesHeroRagGroundStomp"
tt.melee.range = 50
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].max_range = 110
tt.ranged.attacks[1].min_range = 45
tt.ranged.attacks[1].cooldown = 1
tt.ranged.attacks[1].bullet = "bullet_rag"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(3, 80)}
tt.ranged.attacks[1].shoot_time = fts(5)
tt.timed_attacks.list[1] = CC("bullet_attack")
tt.timed_attacks.list[1].animation = "throw"
tt.timed_attacks.list[1].bullet_prefix = "bullet_rag_throw_"
tt.timed_attacks.list[1].bullet_start_offset = {vec_2(3, 80)}
tt.timed_attacks.list[1].cooldown = 15
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].max_range = 125
tt.timed_attacks.list[1].min_range = 45
tt.timed_attacks.list[1].shoot_time = fts(20)
tt.timed_attacks.list[1].sound = "ElvesHeroRagSpawn"
tt.timed_attacks.list[1].things = {"bolso", "anchor", "fungus", "pan", "chair"}
tt.timed_attacks.list[1].xp_from_skill = "angry_gnome"
tt.timed_attacks.list[2] = CC("spawn_attack")
tt.timed_attacks.list[2].animations = {"rabbitCall", "rabbitCallEnd"}
tt.timed_attacks.list[2].bullet = "bullet_kamihare"
tt.timed_attacks.list[2].cooldown = 32
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].entity = "rabbit_kamihare"
tt.timed_attacks.list[2].range_nodes_max = 200
tt.timed_attacks.list[2].range_nodes_min = 50
tt.timed_attacks.list[2].sound = "ElvesHeroRagKamihare"
tt.timed_attacks.list[2].sound_delay = fts(12)
tt.timed_attacks.list[2].spawn_offset = vec_2(0, 31)
tt.timed_attacks.list[2].spawn_time = fts(15)
tt.timed_attacks.list[2].vis_flags = bor(F_RANGED, F_BLOCK)
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[2].xp_from_skill = "kamihare"
tt.timed_attacks.list[3] = CC("area_attack")
tt.timed_attacks.list[3].animations = {"hammer_start", "hammer_walk", "hammer_end"}
tt.timed_attacks.list[3].cooldown = 32
tt.timed_attacks.list[3].damage_every = fts(10)
tt.timed_attacks.list[3].damage_max = 15
tt.timed_attacks.list[3].damage_min = 10
tt.timed_attacks.list[3].damage_radius = 65
tt.timed_attacks.list[3].damage_type = DAMAGE_PHYSICAL
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].max_range = 100
tt.timed_attacks.list[3].mod = "mod_rag_hammer_time_stun"
tt.timed_attacks.list[3].nodes_range = 5
tt.timed_attacks.list[3].sound_hit = "ElvesHeroRagHammer"
tt.timed_attacks.list[3].sound_loop = "ElvesHeroRagHammerTime"
tt.timed_attacks.list[3].speed_factor = 1.25
tt.timed_attacks.list[3].trigger_hp = 600
tt.timed_attacks.list[3].xp_from_skill = "hammer_time"
tt.timed_attacks.list[4] = CC("bullet_attack")
tt.timed_attacks.list[4].animation = "polymorph"
tt.timed_attacks.list[4].bullet = "ray_rag"
tt.timed_attacks.list[4].bullet_start_offset = {vec_2(5, 77)}
tt.timed_attacks.list[4].cooldown = 23
tt.timed_attacks.list[4].disabled = true
tt.timed_attacks.list[4].max_range = 125
tt.timed_attacks.list[4].min_range = 60
tt.timed_attacks.list[4].shoot_time = fts(17)
tt.timed_attacks.list[4].sound = "ElvesHeroRagAttack"
tt.timed_attacks.list[4].vis_bans = bor(F_FLYING, F_BOSS)
tt.timed_attacks.list[4].vis_flags = bor(F_RANGED, F_MOD, F_RAGGIFY)
tt.timed_attacks.list[4].xp_from_skill = "raggified"
tt.ultimate = {
	ts = 0,
	cooldown = 48,
	disabled = true
}
tt = RT("hero_rag_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.range = 100
tt.doll_duration = 10
tt.mod = "mod_rag_raggified"
tt.hit_fx = "fx_rag_ultimate"
tt.hit_decal = "decal_rag_ultimate"
tt.main_script.update = hero_rag_ultimate_update
tt.vis_flags = bor(F_RANGED, F_MOD, F_RAGGIFY)
tt.vis_bans = bor(F_BOSS, F_FLYING)
tt.hit_time = fts(2)
tt = RT("bullet_rag", "arrow")
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.flight_time = fts(18)
tt.bullet.hit_blood_fx = nil
tt.bullet.hit_fx = "fx_bullet_rag_hit"
tt.bullet.miss_decal = nil
tt.bullet.miss_fx = "fx_bullet_rag_hit"
tt.bullet.miss_fx_water = nil
tt.bullet.particles_name = "ps_bullet_rag_trail"
tt.bullet.pop = nil
tt.bullet.xp_gain_factor = 2
tt.render.sprites[1].name = "razzAndRaggs_hero_proy-f"
tt.sound_events.insert = "ElvesHeroRagGnomeShot"
tt = RT("mod_rag_raggified", "modifier")
tt.main_script.update = mod_rag_raggified_update
tt.modifier.bans = {"mod_twilight_avenger_last_service"}
tt.modifier.remove_banned = true
tt.entity_name = "soldier_rag"
tt.fx = "fx_rag_raggified"
tt = RT("ps_bullet_rag_trail")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "razzAndRaggs_hero_proy_particle"
tt.particle_system.particle_lifetime = {0.2, 0.2}
tt.particle_system.alphas = {255, 12}
tt.particle_system.scales_y = {0.8, 0.05}
tt.particle_system.emission_rate = 30
tt = RT("fx_rag_ultimate", "fx")
tt.render.sprites[1].name = "fx_rag_ultimate"
tt.render.sprites[1].anchor.y = 0.2
tt = RT("fx_rag_raggified", "fx")

AC(tt, "sound_events")

tt.render.sprites[1].name = "rag_polymorphed_fx"
tt.render.sprites[1].size_scales = {vec_1(0.75), vec_1(1), vec_1(1)}
tt.sound_events.insert = "ElvesHeroRagTransform"
tt = RT("fx_bullet_rag_hit", "fx")
tt.render.sprites[1].name = "fx_bullet_rag_hit"
tt = RT("decal_rag_ultimate", "fx")
tt.render.sprites[1].name = "decal_rag_ultimate"
tt.render.sprites[1].z = Z_DECALS
tt = RT("ray_rag", "bullet")
tt.image_width = 164
tt.main_script.update = scripts.ray_simple.update
tt.render.sprites[1].name = "ray_rag"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = vec_2(0, 0.5)
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.hit_time = fts(5)
tt.bullet.mod = "mod_rag_raggified"
tt = RT("bullet_kamihare", "bomb")
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.flight_time = fts(17)
tt.bullet.hide_radius = nil
tt.bullet.pop = nil
tt.bullet.hit_fx = nil
tt.bullet.hit_decal = nil
tt.bullet.g = -1.25 / (fts(1) * fts(1))
tt.bullet.rotation_speed = nil
tt.sound_events.insert = nil
tt.sound_events.hit = nil
tt.render.sprites[1].name = "bullet_kamihare"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor.y = 0.20512820512820512
tt = RT("mod_rag_hammer_time_stun", "mod_stun")
tt.modifier.duration = 2
tt.modifier.vis_bans = F_BOSS
