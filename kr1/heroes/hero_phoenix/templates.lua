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
local bor = bit.bor
local fts = U.fts
local level_up_basic = HU.level_up_basic
local queue_damage = U.queue_damage
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local valid_land_node_nearby = HU.valid_land_node_nearby
local v = V.v
local tt

local function aura_ray_phoenix_insert(this, store)
	local bullet = store.entities[this.aura.source_id]

	this.aura.xp_dest_id = bullet and bullet.bullet.source_id or nil

	return true
end

local function aura_phoenix_egg_update(this, store)
	local ca = this.custom_attack
	local a = this.aura

	a.ts = store.tick_ts

	local last_hit_ts = store.tick_ts

	U.y_wait_unconditional(store, this.show_delay)
	U.sprites_show(this)
	U.y_animation_play(this, "spawn", nil, store.tick_ts, 1)
	U.animation_start_default(this, "idle", nil, store.tick_ts, true)

	while true do
		if store.tick_ts - a.ts > a.duration then
			break
		end

		if store.tick_ts - last_hit_ts >= a.cycle_time then
			last_hit_ts = store.tick_ts

			local targets = U.find_enemies_in_range_filter_off(this.pos, a.radius, a.vis_flags, a.vis_bans)

			if targets then
				for _, t in ipairs(targets) do
					local m = E:create_entity(a.mod)

					m.modifier.target_id = t.id
					m.modifier.source_id = this.id

					simulation:queue_insert_entity(m)
				end
			end
		end

		coroutine.yield()
	end

	SU.insert_sprite(store, ca.hit_fx, this.pos)

	local targets = U.find_enemies_in_range_filter_off(this.pos, ca.radius, ca.vis_flags, ca.vis_bans)

	if targets then
		for _, t in ipairs(targets) do
			local d = E.assign_damage(ca.damage_type, math.random(ca.damage_min, ca.damage_max), this.id, t.id)

			queue_damage(store, d)
		end
	end

	simulation:queue_remove_entity(this)
end

local function missile_phoenix_insert(this, store)
	local b = this.bullet
	local flip = this.pos.x > b.to.x and -1 or 1
	local shot_index = b.shot_index or 0

	b.max_speed = U.frandom(b.max_speed - b.speed_var, b.max_speed + b.speed_var)
	b.min_speed = U.frandom(b.min_speed - b.speed_var, b.min_speed + b.speed_var)

	if shot_index > 0 then
		b.to = v(this.pos.x + 30 * flip + shot_index * 5, this.pos.y - 70 + shot_index * 5)
	end

	if shot_index > 1 then
		local targets = U.find_enemies_in_range_filter_off(this.pos, b.first_retarget_range, b.vis_flags, b.vis_bans)

		if targets then
			local target = table.random(targets)

			b.target_id = target.id
		end
	end

	return scripts.missile.insert(this, store)
end

local function mod_phoenix_purification_update(this, store)
	local m = this.modifier
	local target

	m.ts = store.tick_ts

	while true do
		target = store.entities[m.target_id]

		if not target or store.tick_ts - m.ts > m.duration then
			break
		end

		if target.health.dead then
			SU.insert_sprite(store, this.fx, target.pos)
			U.y_wait_unconditional(store, fts(2))

			local e = E:create_entity(this.entity)

			e.pos = V.vclone(target.pos)

			e.bullet.from:copy(e.pos)

			e.bullet.to = v(target.pos.x, target.pos.y + 100)

			local aura = store.entities[m.source_id]

			e.bullet.source_id = this.id
			e.bullet.xp_dest_id = aura and aura.aura.source_id or nil
			e.bullet.shot_index = 0

			simulation:queue_insert_entity(e)

			break
		end

		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

local function mod_phoenix_flaming_path_update(this, store)
	local m = this.modifier
	local ca = this.custom_attack
	local target = store.entities[m.target_id]
	local ending, fx_pos

	if not target or not target.tower then
	-- block empty
	else
		m.ts = store.tick_ts
		ca.ts = store.tick_ts
		fx_pos = V.vclone(target.pos)

		if this.custom_offsets and this.custom_offsets[target.template_name] then
			local o = this.custom_offsets[target.template_name]

			for _, s in ipairs(this.render.sprites) do
				s.offset.x = s.offset.x + o.x
				s.offset.y = s.offset.y + o.y
			end

			fx_pos.x, fx_pos.y = fx_pos.x + o.x, fx_pos.y + o.y
		end

		SU.insert_sprite(store, ca.fx_start, fx_pos)

		while true do
			target = store.entities[m.target_id]

			if not target or store.tick_ts - m.ts > m.duration then
				break
			end

			if target and not ending and store.tick_ts - m.ts >= m.duration - 0.3 then
				ending = true

				SU.insert_sprite(store, ca.fx_end, fx_pos)
			end

			if store.tick_ts - ca.ts > ca.cooldown then
				ca.ts = store.tick_ts

				SU.insert_sprite(store, ca.fx, fx_pos)
				U.y_wait_unconditional(store, ca.hit_time)

				local targets = U.find_enemies_in_range_filter_off(target.pos, ca.radius, ca.vis_flags, ca.vis_bans)

				if targets then
					for _, t in ipairs(targets) do
						local d = E.assign_damage(ca.damage_type, ca.damage, this.id, t.id)

						queue_damage(store, d)

						local m = E:create_entity(ca.mod)

						m.modifier.source_id = this.id
						m.modifier.target_id = t.id

						simulation:queue_insert_entity(m)
					end
				end
			end

			coroutine.yield()
		end
	end

	simulation:queue_remove_entity(this)
end

local function hero_phoenix_ultimate_update(this, store)
	local a = this.aura

	a.ts = store.tick_ts

	local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, {1, 2, 3}, true)

	if #nodes < 1 then
		log.error("hero_phoenix_ultimate: could not find valid node")
		simulation:queue_remove_entity(this)

		return
	end

	local node = {
		pi = nodes[1][1],
		spi = nodes[1][2],
		ni = nodes[1][3]
	}

	this.pos = P:node_pos(node.pi, node.spi, node.ni)

	U.y_animation_play(this, "place", nil, store.tick_ts)
	U.y_wait_unconditional(store, this.activate_delay)
	S:queue(this.sound_events.activate)
	U.y_animation_play(this, "activate", nil, store.tick_ts)

	this.tween.disabled = nil

	local targets

	while store.tick_ts - a.ts < a.duration and not targets do
		U.y_wait_unconditional(store, 0.2)
		coroutine.yield()

		targets = U.find_enemies_in_range_filter_off(this.pos, a.radius, a.vis_flags, a.vis_bans)
	end

	this.tween.disabled = true

	U.y_ease_key(store, this.render.sprites[2], "alpha", this.render.sprites[2].alpha, 255, 0.2)
	SU.insert_sprite(store, a.hit_fx, this.pos)
	SU.insert_sprite(store, a.hit_decal, this.pos)

	targets = U.find_enemies_in_range_filter_off(this.pos, a.radius, a.vis_flags, a.damage_vis_bans)

	if targets then
		for _, t in ipairs(targets) do
			local d = E.assign_damage(a.damage_type, math.random(a.damage_min, a.damage_max) * this.damage_factor, this.id, t.id)

			queue_damage(store, d)
		end
	end

	S:queue(this.sound_events.explode)
	simulation:queue_remove_entity(this)
end

local function hero_phoenix_level_up(this, store, initiaal)
	local hl, ls = level_up_basic(this)
	local b = E:get_template(this.ranged.attacks[1].bullet)

	b.bullet.damage_max = ls.ranged_damage_max[hl] * 0.5
	b.bullet.damage_min = ls.ranged_damage_min[hl] * 0.5

	local ba = E:get_template(b.bullet.hit_payload)

	ba.aura.damage_max = ls.ranged_damage_max[hl]
	ba.aura.damage_min = ls.ranged_damage_min[hl]

	local a = E:get_template("aura_phoenix_egg")

	a.custom_attack.damage_max = ls.egg_explosion_damage_max[hl]
	a.custom_attack.damage_min = ls.egg_explosion_damage_min[hl]

	local m = E:get_template(a.aura.mod)

	m.dps.damage_min = ls.egg_damage[hl]
	m.dps.damage_max = ls.egg_damage[hl]

	upgrade_skill(this, "inmolate", function(this, s)
		local sd = this.selfdestruct

		sd.disabled = nil
		sd.damage_min = s.damage_min[s.level]
		sd.damage_max = s.damage_max[s.level]

		local a = this.timed_attacks.list[1]

		a.disabled = nil
	end)
	upgrade_skill(this, "purification", function(this, s)
		local b = E:get_template("missile_phoenix_small")

		b.bullet.damage_max = s.damage_max[s.level]
		b.bullet.damage_min = s.damage_min[s.level]
	end)
	upgrade_skill(this, "blazing_offspring", function(this, s)
		local a = this.ranged.attacks[2]

		a.disabled = nil
		a.shoot_times = {}

		for i = 1, s.count[s.level] do
			table.insert(a.shoot_times, fts(4))
		end

		local b = E:get_template(a.bullet)

		b.bullet.damage_max = s.damage_max[s.level]
		b.bullet.damage_min = s.damage_min[s.level]
	end)
	upgrade_skill(this, "flaming_path", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil

		local m = E:get_template(a.mod)

		m.custom_attack.damage = s.damage[s.level]
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		this.ultimate.disabled = nil

		local au = E:get_template(s.controller_name)

		au.aura.damage_max = s.damage_max[s.level]
		au.aura.damage_min = s.damage_min[s.level]
	end)
	update_hp(this)
end

local function hero_phoenix_insert(this, store)
	if not scripts.hero_basic.insert(this, store) then
		return false
	end

	local a = E:create_entity("aura_phoenix_purification")

	a.aura.source_id = this.id
	a.aura.ts = store.tick_ts
	a.pos = this.pos

	simulation:queue_insert_entity(a)

	return true
end

local function hero_phoenix_update(this, store)
	local h = this.health
	local a, skill, brk

	U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)

	while true do
		if h.dead then
			local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)
			local respawn_point

			if #nodes < 1 then
				respawn_point = store.level.custom_spawn_pos or store.level.locations.exits[1].pos
				this.selfdestruct.disabled = true
			else
				local pi, spi, ni, dist = unpack(nodes[1])

				respawn_point = P:node_pos(pi, spi, ni)

				if dist > 30 then
					this.selfdestruct.disabled = true
				end
			end

			local egg = E:create_entity("aura_phoenix_egg")

			if this.selfdestruct.disabled then
				this.hero.respawn_point = respawn_point
				egg.pos = V.vclone(respawn_point)
				egg.show_delay = fts(15)
			else
				egg.pos = V.vclone(this.pos)
				egg.show_delay = fts(28)
			end

			simulation:queue_insert_entity(egg)
			U.sprites_hide(this, 2, 2)
			SU.y_hero_death_and_respawn(store, this)

			this.selfdestruct.disabled = this.hero.skills.inmolate.level < 1

			U.sprites_show(this, 2, 2)

			this.hero.respawn_point = nil

			U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)
		end

		while this.nav_rally.new do
			SU.y_hero_new_rally(store, this)
		end

		if SU.hero_level_up(store, this) then
		-- block empty
		end

		if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
			local targets = U.find_enemies_in_range_filter_off(this.pos, this.ranged.attacks[1].max_range, this.ranged.attacks[1].vis_flags, this.ranged.attacks[1].vis_bans)

			if targets and valid_land_node_nearby(this.pos) then
				S:queue(this.sound_events.change_rally_point)

				local e = E:create_entity(this.hero.skills.ultimate.controller_name)

				e.level = this.hero.skills.ultimate.level
				e.pos = V.vclone(this.pos)
				e.owner = this
				e.damage_factor = this.unit.damage_factor

				simulation:queue_insert_entity(e)

				this.ultimate.ts = store.tick_ts

				SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
			else
				this.ultimate.ts = this.ultimate.ts + 1
			end
		end

		a = this.timed_attacks.list[1]
		skill = this.hero.skills.inmolate

		if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
			local targets = U.find_enemies_in_range_filter_off(this.pos, a.range, a.vis_flags, a.vis_bans)

			if not targets or #targets < a.min_count then
				a.ts = a.ts + 0.16666666666666666
			else
				a.ts = store.tick_ts
				h.dead = true
				h.hp = 0
				this.health_bar.hidden = true

				goto label_190_0
			end
		end

		a = this.timed_attacks.list[2]
		skill = this.hero.skills.flaming_path

		if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
			local targets = U.find_towers_in_range(store.towers, this.pos, a, function(e, o)
				local enemies = U.find_enemies_in_range_filter_off(e.pos, a.enemies_range, a.enemies_vis_flags, a.enemies_vis_bans)

				return e.tower.can_be_mod and enemies and #enemies >= a.enemies_min_count
			end)

			if not targets then
				a.ts = a.ts + 0.16666666666666666
			else
				S:queue(a.sound, a.sound_args)
				U.animation_start_default(this, a.animation, nil, store.tick_ts)

				if SU.y_soldier_wait(store, this, a.hit_time) then
				-- block empty
				else
					a.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, skill)
					table.sort(targets, function(e1, e2)
						return V.dist(e1.pos.x, e1.pos.y, this.pos.x, this.pos.y) < V.dist(e2.pos.x, e2.pos.y, this.pos.x, this.pos.y)
					end)

					for i, target in ipairs(targets) do
						if i > a.max_count then
							break
						end

						local mod = E:create_entity(a.mod)

						mod.modifier.target_id = target.id
						mod.modifier.source_id = this.id
						mod.pos.x, mod.pos.y = target.pos.x, target.pos.y

						simulation:queue_insert_entity(mod)
					end

					SU.y_hero_animation_wait(this)
				end

				goto label_190_0
			end
		end

		brk = SU.y_soldier_ranged_attacks(store, this)

		if brk then
		-- block empty
		else
			SU.soldier_idle(store, this)
			SU.soldier_regen(store, this)
		end

		::label_190_0::

		coroutine.yield()
	end
end

tt = RT("hero_phoenix", "hero")

AC(tt, "ranged", "timed_attacks", "selfdestruct")

tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.hp_max = {530, 510, 490, 470, 450, 430, 410, 390, 370, 350}
tt.hero.level_stats.melee_damage_max = {1, 2, 4, 4, 5, 6, 7, 8, 9, 10}
tt.hero.level_stats.melee_damage_min = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
tt.hero.level_stats.ranged_damage_min = {16, 19, 22, 24, 27, 30, 33, 35, 38, 41}
tt.hero.level_stats.ranged_damage_max = {24, 29, 33, 37, 41, 45, 49, 53, 57, 61}
tt.hero.level_stats.egg_damage = {4, 5, 5, 6, 7, 7, 8, 9, 9, 10}
tt.hero.level_stats.egg_explosion_damage_max = {72, 84, 96, 108, 120, 132, 144, 156, 168, 180}
tt.hero.level_stats.egg_explosion_damage_min = {48, 56, 64, 72, 80, 88, 96, 104, 112, 120}
tt.hero.skills.inmolate = CC("hero_skill")
tt.hero.skills.inmolate.damage_max = {115, 235, 350}
tt.hero.skills.inmolate.damage_min = {65, 125, 190}
tt.hero.skills.inmolate.xp_gain = {170, 340, 510}
tt.hero.skills.inmolate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.purification = CC("hero_skill")
tt.hero.skills.purification.damage_min = {15, 25, 35}
tt.hero.skills.purification.damage_max = {15, 25, 35}
tt.hero.skills.purification.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.blazing_offspring = CC("hero_skill")
tt.hero.skills.blazing_offspring.damage_max = {55, 70, 80}
tt.hero.skills.blazing_offspring.damage_min = {30, 40, 45}
tt.hero.skills.blazing_offspring.count = {2, 3, 4}
tt.hero.skills.blazing_offspring.xp_gain = {36, 72, 108}
tt.hero.skills.blazing_offspring.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.flaming_path = CC("hero_skill")
tt.hero.skills.flaming_path.damage = {30, 60, 90}
tt.hero.skills.flaming_path.xp_gain = {75, 150, 225}
tt.hero.skills.flaming_path.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.damage_max = {45, 105, 220, 400}
tt.hero.skills.ultimate.damage_min = {25, 55, 120, 200}
tt.hero.skills.ultimate.xp_gain_factor = 14.4
tt.hero.skills.ultimate.controller_name = "hero_phoenix_ultimate"
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.health.dead_lifetime = 5
tt.health_bar.draw_order = -1
tt.health_bar.offset = vec_2(0, 160)
tt.health_bar.sort_y_offset = -200
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.hero.fn_level_up = hero_phoenix_level_up
tt.idle_flip.cooldown = 10
tt.info.hero_portrait = "kr3_hero_portraits_0010"
tt.info.portrait = "kr3_info_portraits_heroes_0010"
tt.main_script.insert = hero_phoenix_insert
tt.main_script.update = hero_phoenix_update
tt.motion.max_speed = 3.5 * FPS
tt.nav_rally.requires_node_nearby = false
tt.nav_grid.ignore_waypoints = true
tt.nav_grid.valid_terrains = TERRAIN_ALL_MASK
tt.nav_grid.valid_terrains_dest = TERRAIN_ALL_MASK
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.19411764705882
tt.render.sprites[1].prefix = "hero_phoenix"
tt.render.sprites[1].angles.walk = {"idle"}
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "phoenix_hero_0192"
tt.render.sprites[2].anchor.y = 0.19117647058823528
tt.render.sprites[2].alpha = 90
tt.sound_events.change_rally_point = "ElvesHeroPhoenixTaunt"
tt.sound_events.death = "ElvesHeroPhoenixDeath"
tt.sound_events.hero_room_select = "ElvesHeroPhoenixTauntSelect"
tt.sound_events.insert = "ElvesHeroPhoenixTauntIntro"
tt.sound_events.respawn = "ElvesHeroPhoenixTauntIntro"
tt.ui.click_rect = r(-25, 80, 50, 55)
tt.unit.hit_offset = vec_2(0, 100)
tt.unit.hide_after_death = true
tt.unit.mod_offset = vec_2(0, 134)
tt.vis.bans = bor(tt.vis.bans, F_EAT, F_NET, F_POISON, F_BURN)
tt.vis.flags = bor(tt.vis.flags, F_FLYING)
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].bullet = "ray_phoenix"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(0, 100)}
tt.ranged.attacks[1].cooldown = 1 + fts(17)
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].shoot_time = fts(23)
-- tt.ranged.attacks[1].sync_animation = true
tt.ranged.attacks[1].animation = "attack"
tt.ranged.attacks[1].sound_shoot = "ElvesHeroPhoenixAttack"
tt.ranged.attacks[2] = CC("bullet_attack")
tt.ranged.attacks[2].bullet = "missile_phoenix"
tt.ranged.attacks[2].bullet_start_offset = {vec_2(5, 115)}
tt.ranged.attacks[2].cooldown = 22
tt.ranged.attacks[2].disabled = true
tt.ranged.attacks[2].max_range = 300
tt.ranged.attacks[2].shoot_times = {}
-- tt.ranged.attacks[2].sync_animation = true
tt.ranged.attacks[2].animations = {nil, "birdThrow"}
tt.ranged.attacks[2].sound = "ElvesHeroPhoenixBlazingOffspringShoot"
tt.ranged.attacks[2].loops = 1
tt.ranged.attacks[2].xp_from_skill_once = "blazing_offspring"
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].cooldown = 45
tt.timed_attacks.list[1].min_count = 3
tt.timed_attacks.list[1].range = 60
tt.timed_attacks.list[1].vis_flags = F_RANGED
tt.timed_attacks.list[2] = CC("mod_attack")
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].animation = "birdThrow"
tt.timed_attacks.list[2].cooldown = 30
tt.timed_attacks.list[2].max_count = 1
tt.timed_attacks.list[2].max_range = 150
tt.timed_attacks.list[2].min_range = 0
tt.timed_attacks.list[2].mod = "mod_phoenix_flaming_path"
tt.timed_attacks.list[2].hit_time = fts(4)
tt.timed_attacks.list[2].sound = "ElvesHeroPhoenixRingOfFireSpawn"
tt.timed_attacks.list[2].enemies_min_count = 2
tt.timed_attacks.list[2].enemies_range = 125
tt.timed_attacks.list[2].enemies_vis_flags = F_RANGED
tt.timed_attacks.list[2].enemies_vis_bans = bor(F_FLYING)
tt.selfdestruct.animation = "suicide"
tt.selfdestruct.damage_radius = 80
tt.selfdestruct.disabled = true
tt.selfdestruct.hit_time = fts(29)
tt.selfdestruct.hit_fx = "fx_phoenix_inmolation"
tt.selfdestruct.sound = "ElvesHeroPhoenixImmolation"
tt.selfdestruct.sound_args = {
	delay = fts(10)
}
tt.selfdestruct.dead_lifetime = 5
tt.selfdestruct.xp_from_skill = "inmolate"
tt.ultimate = {
	ts = 0,
	cooldown = 14.4,
	disabled = true
}
tt = RT("hero_phoenix_ultimate", "aura")

AC(tt, "render", "tween")

tt.aura.duration = 180
tt.aura.vis_flags = F_RANGED
tt.aura.vis_bans = F_FLYING
tt.aura.damage_vis_bans = 0
tt.aura.radius = 55
tt.aura.hit_fx = "fx_phoenix_explosion"
tt.aura.hit_decal = "decal_phoenix_ultimate"
tt.aura.damage_type = DAMAGE_TRUE
tt.cooldown = 14.4
tt.main_script.update = hero_phoenix_ultimate_update
tt.sound_events.insert = "ElvesHeroPhoenixFireEggDrop"
tt.sound_events.activate = "ElvesHeroPhoenixFireEggActivate"
tt.sound_events.explode = "ElvesHeroPhoenixFireEggExplosion"
tt.render.sprites[1].prefix = "phoenix_ultimate"
tt.render.sprites[1].name = "place"
tt.render.sprites[1].anchor.y = 0.45
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "phoenix_hero_egg_0016"
tt.render.sprites[2].animated = false
tt.render.sprites[2].alpha = 0
tt.render.sprites[2].anchor.y = 0.45
tt.activate_delay = 2
tt.tween.remove = false
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 0}, {0.9, 255}, {1.1, 255}, {2, 0}}
tt.tween.props[1].sprite_id = 2
tt.tween.props[1].loop = true
tt = RT("ray_phoenix", "bullet")
tt.image_width = 120
tt.main_script.update = scripts.ray_simple.update
tt.render.sprites[1].name = "ray_phoenix"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = vec_2(0, 0.5)
tt.bullet.hit_fx = "fx_ray_phoenix_hit"
tt.bullet.hit_fx_ignore_hit_offset = true
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.damage_min = 8
tt.bullet.damage_max = 12
tt.bullet.hit_time = fts(4)
tt.bullet.hit_payload = "aura_ray_phoenix"
tt.bullet.xp_gain_factor = 1.5
tt.track_target = true
tt = RT("aura_ray_phoenix", "aura")
tt.main_script.insert = aura_ray_phoenix_insert
tt.main_script.update = scripts.aura_apply_damage.update
tt.aura.cycles = 1
tt.aura.damage_type = DAMAGE_TRUE
tt.aura.radius = 45
tt.aura.vis_bans = bor(F_FRIEND)
tt.aura.mod = "mod_veznan_demon_fire"
tt.aura.xp_gain_factor = 1.5
tt = RT("missile_phoenix", "bullet")
tt.bullet.acceleration_factor = 0.05
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.damage_radius = nil
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.first_retarget_range = 300
tt.bullet.hit_fx = "fx_ray_phoenix_hit"
tt.bullet.hit_fx_ignore_hit_offset = true
tt.bullet.max_speed = 540
tt.bullet.min_speed = 420
tt.bullet.particles_name = "ps_missile_phoenix"
tt.bullet.retarget_range = math.huge
tt.bullet.speed_var = 60
tt.bullet.turn_speed = 10 * math.pi / 180 * 30
tt.bullet.xp_gain_factor = 0.6
tt.main_script.insert = missile_phoenix_insert
tt.main_script.update = scripts.missile.update
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "phoenix_hero_bird"
tt.sound_events.hit = "ElvesHeroPhoenixBlazingOffspringHit"
tt = RT("missile_phoenix_small", "missile_phoenix")
tt.bullet.particles_name = "ps_missile_phoenix_small"
tt.bullet.xp_gain_factor = 0.12
tt.render.sprites[1].scale = vec_1(0.65)
tt = RT("mod_phoenix_purification", "modifier")
tt.modifier.duration = 1
tt.fx = "fx_ray_phoenix_hit"
tt.entity = "missile_phoenix_small"
tt.main_script.update = mod_phoenix_purification_update
tt = RT("mod_phoenix_egg", "mod_lava")
tt.dps.damage_min = nil
tt.dps.damage_max = nil
tt.dps.damage_inc = 0
tt = RT("mod_phoenix_flaming_path", "modifier")

AC(tt, "custom_attack", "render", "tween")

tt.main_script.update = mod_phoenix_flaming_path_update
tt.modifier.duration = 6.5
tt.custom_attack = CC("custom_attack")
tt.custom_attack.cooldown = 2
tt.custom_attack.fx = "decal_phoenix_flaming_path_pulse"
tt.custom_attack.fx_start = "fx_flaming_path_start"
tt.custom_attack.fx_end = "fx_flaming_path_end"
tt.custom_attack.hit_time = 0.1
tt.custom_attack.mod = "mod_veznan_demon_fire"
tt.custom_attack.radius = 125
tt.custom_attack.damage_type = DAMAGE_TRUE
tt.custom_attack.sound = "ElvesHeroPhoenixRingOfFireExplode"
tt.custom_attack.vis_flags = F_RANGED
tt.custom_attack.vis_bans = F_FLYING
tt.custom_offsets = {}
tt.custom_offsets.tower_pixie = vec_2(0, -10)
tt.render.sprites[1].name = "phoenix_hero_towerBurn_towerFx"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.19166666666666668
tt.render.sprites[1].offset.y = -5
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "decal_flaming_path_fire"
tt.render.sprites[2].anchor.y = 0.19166666666666668
tt.render.sprites[2].offset.y = -5
tt.render.sprites[2].draw_order = 20
tt.tween.remove = false
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {{0, vec_2(1, 1)}, {0.5, vec_2(1.05, 1.05)}, {1, vec_2(1, 1)}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].keys = {{0, 0}, {0.3, 255}, {"this.modifier.duration-0.3", 255}, {"this.modifier.duration", 0}}
tt.tween.props[3] = table.deepclone(tt.tween.props[2])
tt.tween.props[3].sprite_id = 2
tt = RT("aura_phoenix_egg", "aura")

AC(tt, "render")

tt.render.sprites[1].prefix = "hero_phoenix_egg"
tt.render.sprites[1].name = "spawn"
tt.render.sprites[1].anchor.y = 0.2
tt.render.sprites[1].hidden = true
tt.main_script.update = aura_phoenix_egg_update
tt.aura.cycle_time = fts(6)
tt.aura.radius = 50
tt.aura.vis_flags = F_RANGED
tt.aura.vis_bans = F_FLYING
tt.aura.mod = "mod_phoenix_egg"
tt.aura.duration = 5
tt.custom_attack = CC("custom_attack")
tt.custom_attack.radius = 90
tt.custom_attack.damage_type = DAMAGE_TRUE
tt.custom_attack.vis_flags = F_RANGED
tt.custom_attack.hit_fx = "fx_phoenix_explosion"
tt = RT("aura_phoenix_purification", "aura")
tt.aura.cycle_time = fts(9)
tt.aura.duration = -1
tt.aura.mod = "mod_phoenix_purification"
tt.aura.radius = 125
tt.aura.track_source = true
tt.aura.track_dead = true
tt.aura.vis_flags = bor(F_RANGED, F_MOD)
tt.aura.vis_bans = bor(F_FRIEND)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt = RT("ps_missile_phoenix")

AC(tt, "pos", "particle_system")

tt.particle_system.animated = true
tt.particle_system.animation_fps = 50
tt.particle_system.emission_rate = 50
tt.particle_system.emit_area_spread = vec_2(4, 4)
tt.particle_system.loop = false
tt.particle_system.name = "ps_missile_phoenix"
tt.particle_system.particle_lifetime = {0.14, 0.18}
tt.particle_system.spin = {-0.3, 0.3}
tt.particle_system.track_rotation = true
tt = RT("ps_missile_phoenix_small", "ps_missile_phoenix")
tt.particle_system.scale_var = {0.65, 0.65}
tt.particle_system.emit_area_spread = vec_2(2, 2)
tt = RT("fx_flaming_path_start", "fx")
tt.render.sprites[1].name = "fx_flaming_path_start"
tt.render.sprites[1].anchor.y = 0.26666666666666666
tt = RT("fx_flaming_path_end", "fx_flaming_path_start")
tt.render.sprites[1].name = "fx_flaming_path_end"
tt = RT("fx_phoenix_explosion", "fx")
tt.render.sprites[1].name = "hero_phoenix_explosion"
tt.render.sprites[1].anchor.y = 0.20588235294117646
tt = RT("fx_phoenix_inmolation", "decal_tween")
tt.render.sprites[1].name = "hero_phoenix_explosion"
tt.render.sprites[1].anchor.y = 0.20588235294117646
tt.render.sprites[1].loop = false
tt.render.sprites[1].hide_after_runs = 1
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "phoenix_hero_suicide_decals_0001"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].animated = false
tt.render.sprites[3].name = "phoenix_hero_suicide_decals_0002"
tt.render.sprites[3].z = Z_DECALS
tt.tween.props[1].sprite_id = 2
tt.tween.props[1].keys = {{fts(20), 255}, {fts(34), 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].sprite_id = 3
tt.tween.props[2].keys = {{fts(4), 255}, {fts(10), 0}}
tt = RT("fx_ray_phoenix_hit", "fx")
tt.render.sprites[1].name = "fx_ray_phoenix_hit"
tt.render.sprites[1].anchor.y = 0.16666666666666666
tt = RT("decal_phoenix_ultimate", "decal_rock_crater")
tt.render.sprites[1].name = "phoenix_hero_egg_decal"
tt = RT("decal_phoenix_flaming_path_pulse", "decal_tween")
tt.render.sprites[1].name = "phoenix_hero_towerBurn_Circle"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {{0, vec_2(1, 1)}, {0.32, vec_2(2.4, 2.4)}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "alpha"
tt.tween.props[2].keys = {{0, 255}, {0.32, 0}}
