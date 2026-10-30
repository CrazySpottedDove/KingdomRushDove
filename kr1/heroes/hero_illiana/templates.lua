local bit = require("bit")
local signal = require("lib.hump.signal")
local E = require("entity_db")
local GR = require("grid_db")
local scripts = require("scripts")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")

require("all.constants")
require("lib.klua.table")

local band = bit.band
local bor = bit.bor
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local queue_damage = U.queue_damage
local fts = U.fts

local function illiana_damage(this, base)
	return math.ceil((base + this.unit.damage_buff) * this.unit.damage_factor)
end

local function restore_bans(vis, bans)
	U.bans_remove(vis, F_ALL)
	U.bans_add(vis, bans)
end

local function find_center_of_group(targets, node_prediction)
	if not targets then
		return nil
	end

	local np = node_prediction or 1
	local ax, ay = 0, 0

	for _, v in pairs(targets) do
		if v.__ffe_pos then
			ax, ay = ax + v.__ffe_pos.x, ay + v.__ffe_pos.y
		else
			local node_offset = P:predict_enemy_node_advance(v, np)
			local v_pos = P:node_pos(v.nav_path.pi, v.nav_path.spi, v.nav_path.ni + node_offset)

			ax, ay = ax + v_pos.x, ay + v_pos.y
		end
	end

	return V.v(ax / #targets, ay / #targets)
end

local function illiana_bolt_insert(this, store)
	local b = this.bullet

	if b.target_id then
		local target = store.entities[b.target_id]

		if not target or band(target.vis.bans, F_RANGED) ~= 0 then
			return false
		end
	end

	b.speed.x, b.speed.y = V.normalize(b.to.x - b.from.x, b.to.y - b.from.y)

	local s = this.render.sprites[1]

	if not b.ignore_rotation then
		s.r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)
	end

	S:queue(this.sound_events.insert)

	return true
end

local function illiana_bolt_update(this, store)
	local b = this.bullet
	local mspeed = b.min_speed
	local tl = store.tick_length
	local ps
	local flight_time = b.flight_time or 0.5
	local match_flip = this.pos.x > b.to.x

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id

		simulation:queue_insert_entity(ps)
	end

	local target = store.entities[b.target_id]

	if target then
		if b.flight_time then
			flight_time = b.flight_time
		else
			local flight_to_x, flight_to_y = target.pos.x, target.pos.y

			if band(target.vis.flags, F_FLYING) ~= 0 and target.unit and target.unit.hit_offset then
				flight_to_x, flight_to_y = flight_to_x + target.unit.hit_offset.x, flight_to_y + target.unit.hit_offset.y
			end

			flight_time = V.dist(this.pos.x, this.pos.y, flight_to_x, flight_to_y) / mspeed
		end

		if b.node_prediction then
			local node_offset = P:predict_enemy_node_advance(target, flight_time)

			b.to = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + node_offset)

			if band(target.vis.flags, F_FLYING) ~= 0 and target.unit and target.unit.hit_offset then
				b.to.x, b.to.y = b.to.x + target.unit.hit_offset.x, b.to.y + target.unit.hit_offset.y
			end
		end
	end

	if b.emit_decal then
		local d = E:create_entity(b.emit_decal)

		d.source_id = b.source_id
		d.pos.x, d.pos.y = this.pos.x, this.pos.y
		d.to = V.vclone(b.to)
		d.flight_time = flight_time

		simulation:queue_insert_entity(d)
	end

	if b.g then
		b.speed = SU.initial_parabola_speed(b.from, b.to, flight_time, b.g)
		b.ts = store.tick_ts
		b.last_pos = V.vclone(b.from)

		while flight_time > store.tick_ts - b.ts + store.tick_length do
			coroutine.yield()

			b.last_pos.x, b.last_pos.y = this.pos.x, this.pos.y
			this.pos.x, this.pos.y = SU.position_in_parabola(store.tick_ts - b.ts, b.from, b.speed, b.g)

			if this.render and b.align_with_trajectory then
				this.render.sprites[1].r = V.angleTo(this.pos.x - b.last_pos.x, this.pos.y - b.last_pos.y)
			end
		end
	else
		while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * tl do
			b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
			this.pos.x, this.pos.y = this.pos.x + b.speed.x * tl, this.pos.y + b.speed.y * tl

			if this.render and b.align_with_trajectory then
				this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)
			end

			coroutine.yield()
		end
	end

	if target and target.health and not target.health.dead and (not b.damage_radius or b.damage_radius == 0) then
		local d = SU.create_bullet_damage(b, target.id, this.id)

		queue_damage(store, d)
	elseif b.damage_radius and b.damage_radius > 0 then
		local target_pos = target and V.vclone(target.pos) or b.to
		local targets = U.find_enemies_in_range(store, target_pos, 0, b.damage_radius, b.vis_flags, b.vis_bans)

		if targets then
			for _, t in ipairs(targets) do
				local d = SU.create_bullet_damage(b, t.id, this.id)

				queue_damage(store, d)
			end
		end
	end

	S:queue(this.sound_events.hit)

	local fx

	if b.hit_fx_air and target and target.vis and band(target.vis.flags, F_FLYING) ~= 0 then
		fx = E:create_entity(b.hit_fx_air)
	elseif b.hit_fx then
		fx = E:create_entity(b.hit_fx)
	end

	if fx then
		fx.pos.x, fx.pos.y = b.to.x, b.to.y
		fx.render.sprites[1].ts = store.tick_ts

		if b.hit_fx_match_flip then
			fx.render.sprites[1].flip_x = match_flip
		end

		simulation:queue_insert_entity(fx)
	end

	if b.hit_decal then
		fx = E:create_entity(b.hit_decal)
		fx.pos.x, fx.pos.y = b.to.x, b.to.y

		if fx.render then
			fx.render.sprites[1].ts = store.tick_ts
		end

		if fx.aura then
			fx.aura.level = b.level
		end

		if fx.tween then
			fx.tween.ts = store.tick_ts
		end

		simulation:queue_insert_entity(fx)
	end

	simulation:queue_remove_entity(this)
end

local function illiana_tag_bullet_update(this, store)
	local b = this.bullet
	local ps
	local already_hit = {}

	this.bounces = 0

	b.speed.x, b.speed.y = V.normalize(b.to.x - b.from.x, b.to.y - b.from.y)

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id

		simulation:queue_insert_entity(ps)
	end

	S:queue(this.sound_events.insert)

	::label_tag_0::

	while V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) > b.fixed_speed * store.tick_length * (b.fixed_speed * store.tick_length) do
		local target = store.entities[b.target_id]

		if target and target.health and not target.health.dead then
			b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
		end

		b.speed.x, b.speed.y = V.mul(b.fixed_speed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
		this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

		coroutine.yield()
	end

	local target = store.entities[b.target_id]

	if target and not target.health.dead then
		local d = SU.create_bullet_damage(b, target.id, this.id)

		queue_damage(store, d)

		table.insert(already_hit, target.id)

		local mods = b.mods or {b.mod}

		for _, mod_name in pairs(mods) do
			local new_mod = E:create_entity(mod_name)

			new_mod.modifier.level = b.level
			new_mod.modifier.target_id = target.id
			new_mod.modifier.source_id = b.source_id

			simulation:queue_insert_entity(new_mod)
		end
	end

	if b.hit_fx then
		local sfx = E:create_entity(b.hit_fx)

		sfx.pos = V.vclone(b.to)
		sfx.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(sfx)
	end

	if this.bounces < this.max_bounces then
		local targets = U.find_enemies_in_range(store, this.pos, 0, this.bounce_range, b.vis_flags, b.vis_bans, function(v)
			return not table.contains(already_hit, v.id)
		end)

		if targets then
			table.sort(targets, function(e1, e2)
				return V.dist2(this.pos.x, this.pos.y, e1.pos.x, e1.pos.y) < V.dist2(this.pos.x, this.pos.y, e2.pos.x, e2.pos.y)
			end)

			local next_target = targets[1]

			this.bounces = this.bounces + 1
			b.target_id = next_target.id
			b.from = V.vclone(this.pos)
			b.to = V.v(next_target.pos.x + next_target.unit.hit_offset.x, next_target.pos.y + next_target.unit.hit_offset.y)
			S:queue(this.sound_bounce)

			goto label_tag_0
		end
	end

	if ps then
		ps.particle_system.emit = false
	end

	simulation:queue_remove_entity(this)
end

local function aura_illiana_fire_update(this, store)
	local a = this.aura

	a.ts = store.tick_ts

	local last_hit_ts = 0
	local cycles = 0

	while true do
		if a.cycles and cycles >= a.cycles then
			break
		end

		if a.duration >= 0 and store.tick_ts - a.ts >= a.duration then
			break
		end

		if store.tick_ts - last_hit_ts >= a.cycle_time then
			last_hit_ts = store.tick_ts
			cycles = cycles + 1

			local source = store.entities[this.damage_source_id]
			local buff = source and source.unit and source.unit.damage_buff or 0
			local factor = source and source.unit and source.unit.damage_factor or 1
			local targets = U.find_enemies_in_range(store, this.pos, 0, a.radius, a.vis_flags, a.vis_bans) or {}

			for _, target in ipairs(targets) do
				local d = E.assign_damage(a.damage_type, math.ceil((math.random(a.damage_min, a.damage_max) + buff) * factor), this.damage_source_id or this.id, target.id)

				queue_damage(store, d)
			end
		end

		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

local function mod_illiana_tag_skill_a_insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead or not target.enemy then
		return false
	end

	local s = this.render.sprites[1]

	if s and s.prefix_names then
		s.prefix = s.prefix_names[target.unit.size]
	end

	SU.armor_dec(target, this.armor_red)
	SU.magic_armor_dec(target, this.magic_armor_red)
	signal.emit("mod-applied", this, target)

	return true
end

local function mod_illiana_tag_skill_a_remove(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if target then
		SU.armor_inc(target, this.armor_red)
		SU.magic_armor_inc(target, this.magic_armor_red)
	end

	return scripts.tween_utils.reverse_remove
end

local function mod_illiana_skill_b_stun_insert(this, store)
	this.modifier.duration = this.duration_levels[this.modifier.level or 1]

	return scripts.mod_stun.insert(this, store)
end

local function hero_illiana_level_up(this, store, initial)
	if not initial then
		S:queue(this.sound_events.level_up)
	end

	local hl, ls = level_up_basic(this)
	local skills = this.hero.skills

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
	this.ranged.attacks[1].damage_min = ls.ranged_damage_min[hl]
	this.ranged.attacks[1].damage_max = ls.ranged_damage_max[hl]

	this.hero.melee_active_status = {}

	for index, attack in ipairs(this.melee.attacks) do
		this.hero.melee_active_status[index] = attack.disabled
	end

	upgrade_skill(this, "skill_a", function(this, s)
		this.timed_attacks.list[1].disabled = nil

		if this.dragon then
			this.dragon.ranged.attacks[2].disabled = nil
		end
	end)
	upgrade_skill(this, "skill_b", function(this, s)
		this.timed_attacks.list[2].disabled = nil
	end)
	upgrade_skill(this, "skill_c", function(this, s)
		if this.dragon then
			this.dragon.timed_attacks.list[1].disabled = nil
			this.dragon.timed_attacks.list[1].damage_min = s.damage_min[s.level]
			this.dragon.timed_attacks.list[1].damage_max = s.damage_max[s.level]
		end
	end)
	upgrade_skill(this, "talent_1", function(this, s)
		s.disabled = nil
		this.dodge.chance = s.dodge_chance
	end)
	upgrade_skill(this, "talent_2", function(this, s)
		s.disabled = nil
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		s.active = true
		this.timed_attacks.list[3].disabled = nil
	end)

	this.health.hp = this.health.hp_max

	update_hp(this)
end

local function hero_illiana_insert(this, store)
	this.dragon = E:create_entity(this.dragon_t)
	this.dragon.id_illiana = this.id
	this.dragon.pos = V.vclone(this.pos)

	simulation:queue_insert_entity(this.dragon)

	this.hero.fn_level_up(this, store, true)

	this.melee.order = U.attack_order(this.melee.attacks)
	this.ranged.order = U.attack_order(this.ranged.attacks)
	this.timed_attacks.list[3].disabled = not this.hero.skills.ultimate.active

	return true
end

local function illiana_do_ranged_attack(store, this, attack, target, pred_pos)
	local start_ts = store.tick_ts
	local bullet_to = pred_pos or target.pos
	local an, af, ai = U.animation_name_facing_point(this, attack.animation, bullet_to)

	U.animation_start(this, an, af, store.tick_ts, false)
	S:queue(attack.sound)

	while store.tick_ts - start_ts < attack.shoot_time do
		if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
			return false
		end

		coroutine.yield()
	end

	local b = E:create_entity(attack.bullet)
	local bt = b.bullet

	b.pos = V.vclone(this.pos)

	if attack.bullet_start_offset then
		local offset = attack.bullet_start_offset[ai] or attack.bullet_start_offset[1]

		b.pos.x, b.pos.y = b.pos.x + (af and -1 or 1) * offset.x, b.pos.y + offset.y
	end

	bt.from:copy(b.pos)
	bt.to:copy(bullet_to)

	if not attack.ignore_hit_offset then
		bt.to.x = bt.to.x + target.unit.hit_offset.x
		bt.to.y = bt.to.y + target.unit.hit_offset.y
	end

	bt.target_id = target.id
	bt.source_id = this.id
	bt.xp_dest_id = this.id
	bt.level = this.hero.skills.skill_a.level
	bt.damage_factor = this.unit.damage_factor
	bt.damage_min = attack.damage_min + this.unit.damage_buff
	bt.damage_max = attack.damage_max + this.unit.damage_buff

	simulation:queue_insert_entity(b)

	while not U.animation_finished(this) do
		if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
			break
		end

		coroutine.yield()
	end

	return true
end

local function hero_illiana_update(this, store)
	local h = this.health
	local brk, sta
	local casting_ult = false
	local tr = this.transfer
	local ps
	local transfering = false
	local idle_damage_factor = this.unit.damage_factor
	local og_z = this.render.sprites[1].z
	local og_animation = this.ranged.attacks[1].animation
	local n = this.nav_grid
	local skills = this.hero.skills
	local skb = not this.timed_attacks.list[2].disabled and this.timed_attacks.list[2] or nil
	local ult = not this.timed_attacks.list[3].disabled and this.timed_attacks.list[3] or nil

	this.health_bar.hidden = false

	if skb then
		skb.ts = store.tick_ts - skb.cooldown
	end

	if ult then
		ult.ts = store.tick_ts - ult.cooldown
	end

	local ult_start_cd = ult ~= nil and store.wave_group_number == 0
	local t2 = not skills.talent_2.disabled and skills.talent_2 or nil

	this.can_transfer = true
	this.teleport.disabled = false

	local function find_most_populated_path(enemies)
		local paths_count = {}
		local found_paths = {}

		for _, enemy in pairs(enemies) do
			if not table.contains(found_paths, enemy.nav_path.pi) then
				table.insert(found_paths, enemy.nav_path.pi)
				table.insert(paths_count, {enemy.nav_path.pi, 1})
			else
				for _, entry in ipairs(paths_count) do
					if entry[1] == enemy.nav_path.pi then
						entry[2] = entry[2] + 1

						break
					end
				end
			end
		end

		table.sort(paths_count, function(v1, v2)
			return v1[2] > v2[2]
		end)

		return paths_count
	end

	local function sort_paths_by_distance(paths, min_distance)
		return table.filter(paths, function(k, v)
			local count = 0
			local nearest = P:nearest_nodes(this.pos.x, this.pos.y, {v[1]})[1][3]
			local first_node = P:get_visible_start_node(v[1])

			for i = 0, min_distance do
				if first_node <= nearest - i then
					return true
				end

				if P:is_node_valid(v[1], math.max(first_node, nearest - i), 0) and (not store.level.ignore_walk_backwards_paths or not table.contains(store.level.ignore_walk_backwards_paths, v[1])) then
					count = count + 1

					if count >= min_distance then
						return true
					end
				else
					return false
				end
			end
		end)
	end

	local function y_illiana_death_and_respawn(store, this)
		local h = this.health
		local he = this.hero

		this.ui.can_click = false

		local death_ts = store.tick_ts
		local dead_lifetime = h.dead_lifetime
		local normal_death = band(h.last_damage_types, DAMAGE_EAT) == 0

		U.unblock_target(store, this)
		S:queue(this.sound_events.death, this.sound_events.death_args)

		if normal_death then
			U.animation_start(this, this.unit.death_animation, nil, store.tick_ts, false)
			U.y_animation_wait(this)
		else
			this.unit.hide_after_death = true
		end

		this.health.death_finished_ts = store.tick_ts

		while dead_lifetime > store.tick_ts - death_ts do
			if this.trigger_death_animation then
				U.animation_start(this, "death_dragon_in", nil, store.tick_ts, false, 1)

				this.trigger_death_animation = false
			end

			if this.force_respawn then
				this.force_respawn = nil

				break
			end

			coroutine.yield()
		end

		this.health.death_finished_ts = nil

		if he.respawn_point then
			local p = he.respawn_point

			this.pos.x, this.pos.y = p.x, p.y
			this.nav_rally.pos.x, this.nav_rally.pos.y = p.x, p.y
			this.nav_rally.center.x, this.nav_rally.center.y = p.x, p.y
			this.nav_rally.new = false
		end

		for _, s in pairs(this.render.sprites) do
			if this.use_hidden_count_on_respawn and s.hidden_count then
				s.hidden = s.hidden_count > 0
			else
				s.hidden = false
			end
		end

		h.ignore_damage = true
		S:queue(this.sound_events.respawn)

		h.dead = false

		U.animation_start(this, this.respawn_animation, nil, store.tick_ts, false, 1)

		this.dragon.trigger_respawn_animation = normal_death
		this.trigger_death_animation = false
		this.health_bar.hidden = false
		this.ui.can_click = true
		this.force_respawn = nil
		h.hp = h.hp_max
		h.ignore_damage = false

		U.y_animation_wait(this)
	end

	local function illiana_will_transfer(this, new_rally_pos)
		local r = new_rally_pos

		return tr and not tr.disabled and V.dist(r.x, r.y, this.pos.x, this.pos.y) > tr.min_distance
	end

	local function mount_start()
		U.animation_start(this, "walk_2_in", this.dragon.render.sprites[1].flip_x, this.mount_ts - this.dragon.pickup_contact_time, false, 1, true)
	end

	local function mount_finish()
		this.render.sprites[1].hidden = true
		this.pos = this.dragon.pos
		this.motion.speed.x, this.motion.speed.y = 0, 0
		n.waypoints = {}

		if tr.particles_name then
			ps = E:create_entity(tr.particles_name)
			ps.particle_system.track_id = this.id

			simulation:queue_insert_entity(ps)
		end

		if t2 then
			this.unit.damage_factor = t2.damage_factor
		end

		this.ranged.attacks[1].animation = "walk_2_attack"
		transfering = true
	end

	local function ride_begin()
		this.render.sprites[1].prefix = "hero_illiana_walk2Def"
		this.render.sprites[1].offset = V.v(0, this.dragon.flight_height)
		this.render.sprites[1].z = Z_FLYING_HEROES
		this.dragon.render.sprites[1].z = Z_FLYING_HEROES

		U.animation_start(this, "walk_2", nil, this.ride_anim_ts, true, 1, true)

		this.render.sprites[1].hidden = false
	end

	local function mount_abort()
		this.mount_ts = nil
		this.ride_anim_ts = nil
		this.render.sprites[1].hidden = false
		this.dragon.cancel_transfer = true
	end

	local function transfer_out()
		if not transfering then
			return
		end

		this.pos = V.vclone(this.pos)
		this.unit.damage_factor = idle_damage_factor
		this.ride_anim_ts = nil

		if tr.particles_name then
			ps.particle_system.emit = false
			ps.particle_system.source_lifetime = 1
		end

		this.render.sprites[1].prefix = "hero_illianaDef"
		this.render.sprites[1].offset = V.v(0, 0)
		this.render.sprites[1].z = og_z
		this.render.sprites[1].hidden = false
		this.dragon.render.sprites[1].z = og_z
		this.ranged.attacks[1].animation = og_animation
		transfering = false

		U.animation_start(this, "walk_2_out", nil, store.tick_ts, false, 1, true)

		while not U.animation_finished(this, 1) do
			if this.nav_rally.new or this.health.dead and not this.health.ignore_damage then
				break
			end

			coroutine.yield()
		end
	end

	local function y_illiana_walk()
		local animation = "walk"
		local r = this.nav_rally
		local dest = r.pos
		local want_ride = false
		local mounting = false
		local last_af, w, unsnap
		local og_vis_bans = this.vis.bans
		local og_immune_to = this.health.immune_to

		::label_walk_0::

		dest = r.pos
		r.new = false
		w, unsnap = nil, nil
		this.transfer_arrived = false

		U.unblock_target(store, this)

		if this.sound_events then
			S:queue(this.sound_events.change_rally_point)
		end

		U.bans_add(this.vis, F_ALL)
		this.health.immune_to = r.immune_to

		if transfering then
			this.dragon.ride_to = dest
			this.dragon.carry_to = dest
		else
			want_ride = illiana_will_transfer(this, dest)

			local wp = GR:find_waypoints(this.pos, nil, dest, n.valid_terrains, true)

			n.waypoints = wp and table.deepclone(wp) or {}

			if mounting and not want_ride then
				mounting = false

				mount_abort()
			end

			if mounting then
				this.dragon.ride_to = dest
			else
				this.dragon.ride_to = want_ride and dest or nil
				this.dragon.chase = want_ride

				if not want_ride then
					this.dragon.cancel_transfer = true
				end
			end
		end

		while not V.veq(this.pos, dest) and not this.transfer_arrived do
			if this.health.dead and not this.health.ignore_damage then
				break
			end

			if r.new then
				goto label_walk_0
			end

			if this.mount_ts and not mounting then
				mounting = true

				mount_start()
			end

			if transfering then
				if this.ride_anim_ts and store.tick_ts >= this.ride_anim_ts then
					ride_begin()

					this.ride_anim_ts = nil
				end

				if not this.render.sprites[1].hidden then
					local target, attack, pred_pos = SU.soldier_pick_ranged_target_and_attack(store, this)

					if target and attack then
						illiana_do_ranged_attack(store, this, attack, target, pred_pos)
					end
				end
			elseif mounting and store.tick_ts >= this.mount_ts then
				mounting = false
				this.mount_ts = nil

				mount_finish()
			else
				if not w or this.motion.arrived then
					w = table.remove(n.waypoints, 1) or dest
					unsnap = #n.waypoints > 0

					U.set_destination(this, w)

					if not mounting then
						local an, af = U.animation_name_facing_point(this, animation, this.motion.dest)
						local new_af = af

						if last_af and math.abs(this.pos.x - this.motion.dest.x) < 2 then
							new_af = last_af
						end

						U.animation_start(this, an, new_af, store.tick_ts, true)

						last_af = new_af
					end
				end

				U.walk(this, store.tick_length, nil, unsnap)

				this.motion.speed.x, this.motion.speed.y = 0, 0

				if this.motion.arrived and #n.waypoints == 0 then
					if mounting then
						mounting = false

						mount_abort()
						U.animation_start(this, "idle", nil, store.tick_ts, true)
					end

					break
				end
			end

			coroutine.yield()
		end

		this.dragon.chase = false

		if mounting then
			mounting = false

			mount_abort()
		end

		if not transfering or this.health.dead then
			this.dragon.cancel_transfer = true
		end

		transfer_out()

		this.motion.speed.x, this.motion.speed.y = 0, 0
		this.motion.arrived = false
		restore_bans(this.vis, og_vis_bans)
		this.health.immune_to = og_immune_to
	end

	local function y_illiana_walk_waypoints(store, this, animation)
		local animation = animation or "walk"
		local r = this.nav_rally
		local dest = r.pos
		local old_damage_factor = this.unit.damage_factor

		if t2 then
			this.unit.damage_factor = t2.damage_factor
		end

		local og_animation = this.ranged.attacks[1].animation

		this.ranged.attacks[1].animation = "walk_2_attack"
		this.pos = this.dragon.pos

		local function update_shadow()
			local has_no_shadow = GR:cell_is(this.pos.x, this.pos.y, TERRAIN_NO_SHADOW)

			this.render.sprites[this.render.sid_shadow].hidden = has_no_shadow
		end

		::label_waypoints_0::

		dest = r.pos
		this.dragon.transfer_dest = dest
		this.transfer_arrived = false

		while not this.transfer_arrived do
			if this.health.dead and not this.health.ignore_damage then
				break
			end

			if r.new then
				r.new = false

				goto label_waypoints_0
			end

			if this.render.sid_shadow then
				update_shadow()
			end

			local target, attack, pred_pos = SU.soldier_pick_ranged_target_and_attack(store, this)

			if target and attack then
				illiana_do_ranged_attack(store, this, attack, target, pred_pos)
			end

			coroutine.yield()
		end

		this.motion.speed.x, this.motion.speed.y = 0, 0
		this.motion.arrived = false
		r.new = false
		this.unit.damage_factor = old_damage_factor
		this.ranged.attacks[1].animation = og_animation
		this.pos = V.vclone(this.dragon.pos)
	end

	local function y_illiana_new_rally(store, this)
		local r = this.nav_rally

		if r.new then
			r.new = false

			U.unblock_target(store, this)

			if this.sound_events then
				S:queue(this.sound_events.change_rally_point)
			end

			if illiana_will_transfer(this, r.pos) then
				local tr = this.transfer
				local interrupt = false
				local ps
				local vis_bans = this.vis.bans

				U.bans_add(this.vis, F_ALL)
				this.health.ignore_damage = true
				this.dragon.transfer = true

				while not this.begin_transfer do
					coroutine.yield()
				end

				this.begin_transfer = false
				this.dragon.start_transfer_anim = true

				U.y_animation_play(this, "walk_2_in", this.dragon.flip_x, store.tick_ts, 1, 1)

				this.render.sprites[1].prefix = "hero_illiana_walk2Def"

				U.animation_start(this, "walk_2", nil, store.tick_ts, true, 1)

				this.render.sprites[1].offset = V.v(0, this.dragon.flight_height)

				local og_z = this.render.sprites[1].z

				this.render.sprites[1].z = Z_FLYING_HEROES
				this.dragon.render.sprites[1].z = Z_FLYING_HEROES

				if tr.particles_name then
					ps = E:create_entity(tr.particles_name)
					ps.particle_system.track_id = this.id

					simulation:queue_insert_entity(ps)
				end

				y_illiana_walk_waypoints(store, this, "walk_2")

				if tr.particles_name then
					ps.particle_system.emit = false
					ps.particle_system.source_lifetime = 1
				end

				this.render.sprites[1].prefix = "hero_illianaDef"
				this.render.sprites[1].offset = V.v(0, 0)
				this.render.sprites[1].z = og_z
				this.dragon.render.sprites[1].z = og_z

				U.y_animation_play(this, "walk_2_out", nil, store.tick_ts, 1, 1)

				restore_bans(this.vis, vis_bans)
				this.health.ignore_damage = false

				return interrupt
			else
				local vis_bans = this.vis.bans
				local prev_immune = this.health.immune_to

				U.bans_add(this.vis, F_ALL)
				this.health.immune_to = r.immune_to

				local out = SU.y_hero_walk_waypoints(store, this)

				U.animation_start(this, "idle", nil, store.tick_ts, true)

				restore_bans(this.vis, vis_bans)
				this.health.immune_to = prev_immune

				return out
			end
		end
	end

	local function should_block()
		return SU.soldier_pick_melee_target(store, this) ~= nil
	end

	while true do
		if ult_start_cd and store.wave_group_number > 0 then
			ult_start_cd = false
			ult.ts = store.tick_ts
		end

		if h.dead then
			if band(h.last_damage_types, DAMAGE_EAT) ~= 0 then
				this.respawn_animation = "respawn_instakill"
			else
				this.unit.hide_after_death = false
				this.respawn_animation = "respawn"
			end

			y_illiana_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if y_illiana_walk(store, this) then
					goto label_continue
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "lvl_up", nil, store.tick_ts, 1)
			end

			if ult and store.tick_ts - ult.ts > ult.cooldown and not this.dragon_skill_c_in_progress then
				local nearest = P:nearest_nodes(this.pos.x, this.pos.y)
				local targets = U.find_enemies_in_range(store, this.pos, 0, ult.detection_range, ult.flags, ult.bans, function(v)
					for _, p in pairs(nearest) do
						return p[1] == v.nav_path.pi and v.nav_path.ni < p[3]
					end
				end)

				if not targets or #targets < ult.min_targets then
					SU.delay_attack(store, ult, fts(10))

					goto label_ult_0
				end

				local paths = find_most_populated_path(targets)

				paths = sort_paths_by_distance(paths, ult.distance)

				if #paths == 0 then
					SU.delay_attack(store, ult, fts(10))

					goto label_ult_0
				end

				this.dragon.cast_ult = true
				casting_ult = true

				while not this.cast_ult do
					if SU.soldier_interrupted(this) or should_block() then
						this.dragon.cast_ult = false
						casting_ult = false
						this.cast_ult = false

						SU.delay_attack(store, ult, 1)

						goto label_continue
					end

					SU.soldier_idle(store, this)
					coroutine.yield()
				end

				S:queue(ult.taunt)
				U.animation_start(this, ult.animation, nil, store.tick_ts, false, 1)

				local start_ts = store.tick_ts

				while store.tick_ts - start_ts < ult.shoot_time do
					if SU.soldier_interrupted(this) then
						this.dragon.cast_ult = false
						casting_ult = false
						this.cast_ult = false

						SU.delay_attack(store, ult, 1)

						goto label_continue
					end

					coroutine.yield()
				end

				S:queue(ult.sound)

				local nearest_path = P:nearest_nodes(this.pos.x, this.pos.y, {paths[1][1]})

				this.dragon.ult_path = {}
				this.dragon.ult_path.pi = nearest_path[1][1]
				this.dragon.ult_path.spi = 1
				this.dragon.ult_path.ni = nearest_path[1][3] - 3

				local flip = this.render.sprites[1].flip_x and -1 or 1
				local dragon_flip = this.dragon.render.sprites[1].flip_x and -1 or 1
				local treat = E:create_entity(ult.bullet)

				treat.pos.x, treat.pos.y = this.pos.x + ult.shoot_offset.x * flip, this.pos.y + ult.shoot_offset.y
				treat.bullet.from = V.vclone(treat.pos)
				treat.bullet.to = V.v(this.dragon.pos.x + this.dragon.mouth_offset.x * dragon_flip, this.dragon.pos.y + this.dragon.flight_height)
				treat.bullet.source_id = this.id
				this.dragon.treat = treat

				simulation:queue_insert_entity(treat)
				SU.y_soldier_animation_wait(this)

				casting_ult = false
				this.cast_ult = false
				ult.ts = store.tick_ts
			end

			::label_ult_0::

			if skb and store.tick_ts - skb.ts > skb.cooldown and not casting_ult then
				local _, targets = U.find_foremost_enemy(store, this.pos, 0, skb.max_range, 0, skb.flags, skb.bans)

				if not targets or #targets < skb.min_targets then
					SU.delay_attack(store, skb, fts(5))
				else
					local flight_time = E:get_template(skb.bullet).bullet.flight_time
					local shoot_pos_prev = find_center_of_group(targets, flight_time)
					local f = this.pos.x > shoot_pos_prev.x

					U.animation_start(this, skb.animation, f, store.tick_ts, false, 1)

					if SU.y_hero_wait(store, this, skb.shoot_time) then
						goto label_continue
					end

					local shoot_pos = find_center_of_group(targets, flight_time)
					local flip = this.render.sprites[1].flip_x and -1 or 1
					local b = E:create_entity(skb.bullet)

					b.pos.x, b.pos.y = this.pos.x + skb.offset.x * flip, this.pos.y + skb.offset.y
					b.bullet.from = V.vclone(b.pos)
					b.bullet.to = shoot_pos
					b.bullet.source_id = this.id
					b.bullet.level = skills.skill_b.level

					simulation:queue_insert_entity(b)
					SU.hero_gain_xp_from_skill(this, skills.skill_b)
					SU.y_hero_animation_wait(this)

					skb.ts = store.tick_ts

					goto label_continue
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
			elseif SU.soldier_go_back_step(store, this) then
			else
				local target, attack, pred_pos = SU.soldier_pick_ranged_target_and_attack(store, this)

				if target and attack then
					illiana_do_ranged_attack(store, this, attack, target, pred_pos)
				else
					SU.soldier_idle(store, this)
					SU.soldier_regen(store, this)
				end
			end
		end

		::label_continue::

		coroutine.yield()
	end
end

local function decal_illiana_dragon_update(this, store)
	local sd = this.render.sprites[1]
	local ba = this.ranged.attacks[1]
	local illiana = store.entities[this.id_illiana]
	local fm = this.force_motion
	local dest = V.v(this.pos.x, this.pos.y)
	local dist
	local death_anim_flag = true
	local og_max_v = fm.max_v
	local og_a_step = fm.a_step
	local og_max_a = fm.max_a

	if not illiana then
		simulation:queue_remove_entity(this)

		return
	end

	ba.ts = store.tick_ts - ba.cooldown

	local sa = not this.ranged.attacks[2].disabled and this.ranged.attacks[2] or nil

	if sa then
		sa.ts = store.tick_ts - sa.cooldown
	end

	local sc = not this.timed_attacks.list[1].disabled and this.timed_attacks.list[1] or nil

	if sc then
		sc.ts = store.tick_ts - sc.cooldown
		sc.damage_min = illiana.hero.skills.skill_c.damage_min[illiana.hero.skills.skill_c.level]
		sc.damage_max = illiana.hero.skills.skill_c.damage_max[illiana.hero.skills.skill_c.level]
	end

	local ult = not this.timed_attacks.list[2].disabled and this.timed_attacks.list[2] or nil

	fm.a_step = fm.a_step + math.random(-3, 3)

	local function hold_position()
		fm.v.x, fm.v.y = 0, 0
		fm.a.x, fm.a.y = 0, 0
	end

	local function shoot(attack)
		local target, targets, pred_pos = U.find_foremost_enemy(store, this.pos, 0, attack.max_range, attack.node_prediction, attack.vis_flags, attack.vis_bans)

		if store.tick_ts - attack.ts > attack.cooldown and target and not target.health.dead and (not attack.min_targets or #targets >= attack.min_targets) then
			local start_ts = store.tick_ts

			hold_position()

			local an, af = U.animation_name_facing_point(this, attack.animation, pred_pos)

			U.animation_start(this, an, af, store.tick_ts)
			S:queue(attack.start_sound, attack.start_sound_args)

			if U.y_wait(store, attack.shoot_time, function(store, time)
				return this.chase
			end) then
				return
			end

			S:queue(attack.sound)

			local hoffset = target and V.vclone(target.unit.hit_offset) or V.v(0, 0)
			local b = E:create_entity(attack.bullet)
			local dmin, dmax

			if attack == sa then
				dmin = illiana.hero.skills.skill_a.damage_min[illiana.hero.skills.skill_a.level]
				dmax = illiana.hero.skills.skill_a.damage_max[illiana.hero.skills.skill_a.level]
				b.bullet.level = illiana.hero.skills.skill_a.level
			else
				dmin = illiana.dragon_ranged_damage_min[illiana.hero.level]
				dmax = illiana.dragon_ranged_damage_max[illiana.hero.level]
				b.bullet.level = illiana.hero.level
				b.bullet.xp_gain_factor = attack.xp_gain_factor
			end

			b.bullet.target_id = target.id
			b.bullet.source_id = illiana.id
			b.bullet.xp_dest_id = illiana.id
			b.bullet.damage_factor = illiana.unit.damage_factor
			b.bullet.damage_min = dmin + illiana.unit.damage_buff
			b.bullet.damage_max = dmax + illiana.unit.damage_buff
			b.pos = V.vclone(this.pos)
			b.pos.x = b.pos.x + (af and -1 or 1) * attack.bullet_start_offset.x
			b.pos.y = b.pos.y + attack.bullet_start_offset.y + this.flight_height
			b.bullet.from = V.vclone(b.pos)
			b.bullet.to = V.v(pred_pos.x + hoffset.x, pred_pos.y + hoffset.y)

			simulation:queue_insert_entity(b)

			while not U.animation_finished(this) do
				if this.chase then
					return
				end

				coroutine.yield()
			end

			if attack == sa then
				SU.hero_gain_xp_from_skill(illiana, illiana.hero.skills.skill_a)
			end

			attack.ts = store.tick_ts

			U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)
		end
	end

	local function spawn_ground_fire(pi, pos, fires_spawned)
		local start_i, end_i

		if fires_spawned % 2 == 0 then
			start_i, end_i = 1, 1
		else
			start_i, end_i = 2, 3
		end

		for i = start_i, end_i do
			local nearest = P:nearest_nodes(pos.x, pos.y, {pi})
			local npi, nspi, ni = unpack(nearest[1])
			local fire_pos = P:node_pos(npi, i, ni + math.random(-ult.random_for_node, ult.random_for_node))
			local decal = E:create_entity(ult.decal_fire_ground)

			decal.render.sprites[1].ts = store.tick_ts
			decal.pos = fire_pos

			simulation:queue_insert_entity(decal)

			local aura = E:create_entity(ult.decal_fire_ground_aura)

			aura.pos = fire_pos
			aura.damage_source_id = illiana.id

			simulation:queue_insert_entity(aura)
		end
	end

	while true do
		if illiana.health.dead then
			local normal_death = band(illiana.health.last_damage_types, DAMAGE_EAT) == 0

			if normal_death and death_anim_flag then
				U.y_animation_play(this, "death_in", nil, store.tick_ts, 1, 1)

				this.force_motion.max_v = og_max_v / 4
				this.force_motion.a_step = og_a_step / 4
				this.force_motion.max_a = og_max_a / 4

				repeat
					U.animation_start(this, "death_walk", nil, store.tick_ts, true)

					dest.x, dest.y = illiana.pos.x, illiana.pos.y
					sd.flip_x = dest.x < this.pos.x

					U.force_motion_step(this, store.tick_length, dest)
					coroutine.yield()

					dist = V.dist(this.pos.x, this.pos.y, dest.x, dest.y)
				until dist < 5

				this.force_motion.max_v = og_max_v
				this.force_motion.a_step = og_a_step
				this.force_motion.max_a = og_max_a

				U.y_wait(store, fts(10))
				U.y_animation_play(this, "death_out", nil, store.tick_ts, 1, 1)

				illiana.trigger_death_animation = true
				this.render.sprites[1].hidden = true
				death_anim_flag = false
			elseif not normal_death then
				repeat
					U.animation_start(this, "death_walk", nil, store.tick_ts, true)

					dest.x, dest.y = illiana.pos.x, illiana.pos.y
					sd.flip_x = dest.x < this.pos.x

					U.force_motion_step(this, store.tick_length, dest)
					coroutine.yield()

					dist = V.dist(this.pos.x, this.pos.y, dest.x, dest.y)
				until dist < 5
			end
		else
			if this.trigger_respawn_animation and death_anim_flag == false then
				U.animation_start(this, "respawn", not illiana.render.sprites[1].flip_x, store.tick_ts, false, 1)

				this.render.sprites[1].hidden = false
				this.trigger_respawn_animation = false

				U.y_animation_wait(this)
			end

			death_anim_flag = true

			if this.chase then
				this.cancel_transfer = false

				local contact_time = this.pickup_contact_time

				fm.max_v = og_max_v * 2
				fm.a_step = og_a_step * 2
				fm.max_a = og_max_a * 2

				local cancelled = false

				repeat
					U.animation_start(this, "walk_1", nil, store.tick_ts, true)

					dest.x, dest.y = illiana.pos.x, illiana.pos.y
					sd.flip_x = dest.x < this.pos.x

					U.force_motion_step(this, store.tick_length, dest)
					coroutine.yield()

					dist = V.dist(this.pos.x, this.pos.y, dest.x, dest.y)
					cancelled = this.cancel_transfer or illiana.health.dead or not this.ride_to
				until cancelled or dist < 5 or dist <= V.len(fm.v.x, fm.v.y) * contact_time

				this.chase = false

				if cancelled then
					this.cancel_transfer = false
					fm.max_v = og_max_v
					fm.a_step = og_a_step
					fm.max_a = og_max_a

					goto label_dragon_504_0
				end

				local carry_v = og_max_v * 1.5
				local exit_speed = math.min(carry_v, math.max(V.len(fm.v.x, fm.v.y), illiana.motion.max_speed))
				local contact_ts = store.tick_ts + contact_time
				local ride_anim_ts = store.tick_ts + this.pickup_anim_time
				local cx, cy = this.pos.x, this.pos.y

				illiana.mount_ts = contact_ts
				illiana.ride_anim_ts = ride_anim_ts
				sd.flip_x = this.ride_to.x < this.pos.x

				U.animation_start(this, "walk_2_in", sd.flip_x, store.tick_ts, false, 1, true)

				while contact_ts > store.tick_ts do
					local dt = store.tick_length
					local rem = contact_ts - store.tick_ts
					local ivx, ivy = 0, 0

					if not illiana.motion.arrived then
						ivx, ivy = V.mul(illiana.motion.max_speed, V.normalize(V.sub(illiana.motion.dest.x, illiana.motion.dest.y, illiana.pos.x, illiana.pos.y)))
					end

					cx, cy = illiana.pos.x + ivx * rem, illiana.pos.y + ivy * rem

					local evx, evy = V.mul(exit_speed, V.normalize(V.sub(this.ride_to.x, this.ride_to.y, cx, cy)))

					if rem <= dt then
						this.pos.x, this.pos.y = cx, cy
						fm.v.x, fm.v.y = evx, evy
					else
						local s = dt / rem
						local s2 = s * s
						local s3 = s2 * s
						local h00 = 2 * s3 - 3 * s2 + 1
						local h10 = s3 - 2 * s2 + s
						local h01 = -2 * s3 + 3 * s2
						local h11 = s3 - s2
						local nx = h00 * this.pos.x + h10 * rem * fm.v.x + h01 * cx + h11 * rem * evx
						local ny = h00 * this.pos.y + h10 * rem * fm.v.y + h01 * cy + h11 * rem * evy

						fm.v.x, fm.v.y = (nx - this.pos.x) / dt, (ny - this.pos.y) / dt
						this.pos.x, this.pos.y = nx, ny
					end

					fm.a.x, fm.a.y = 0, 0

					coroutine.yield()

					if this.cancel_transfer or illiana.health.dead then
						illiana.mount_ts = nil
						illiana.ride_anim_ts = nil
						this.cancel_transfer = false
						fm.max_v = og_max_v
						fm.a_step = og_a_step
						fm.max_a = og_max_a

						goto label_dragon_504_0
					end
				end

				this.carry_to = this.ride_to
				fm.max_v = carry_v
				fm.a_step = og_a_step * 1.5
				fm.max_a = og_max_a * 1.5

				while ride_anim_ts > store.tick_ts do
					if this.cancel_transfer or illiana.health.dead then
						break
					end

					dest.x, dest.y = this.carry_to.x, this.carry_to.y
					sd.flip_x = dest.x < this.pos.x

					U.force_motion_step(this, store.tick_length, dest)
					coroutine.yield()
				end

				U.animation_start(this, "walk_2", nil, ride_anim_ts, true, 1, true)
			end

			if this.carry_to then
				this.force_motion.max_v = og_max_v * 1.5
				this.force_motion.a_step = og_a_step * 1.5
				this.force_motion.max_a = og_max_a * 1.5

				repeat
					U.animation_start(this, "walk_2", nil, store.tick_ts, true)

					dest.x, dest.y = this.carry_to.x, this.carry_to.y
					sd.flip_x = dest.x < this.pos.x

					U.force_motion_step(this, store.tick_length, dest)
					coroutine.yield()

					dist = V.dist(this.pos.x, this.pos.y, dest.x, dest.y)
				until dist < 5 or this.cancel_transfer

				this.force_motion.max_v = og_max_v
				this.force_motion.a_step = og_a_step
				this.force_motion.max_a = og_max_a
				this.carry_to = nil
				this.ride_to = nil

				if this.cancel_transfer then
					this.cancel_transfer = false
				else
					illiana.transfer_arrived = true
				end
			end

			repeat
				U.animation_start(this, "walk_1", nil, store.tick_ts, true)

				dest.x, dest.y = illiana.pos.x + this.offset.x, illiana.pos.y + this.offset.y
				sd.flip_x = dest.x < this.pos.x

				U.force_motion_step(this, store.tick_length, dest)
				coroutine.yield()

				dist = V.dist(this.pos.x, this.pos.y, dest.x, dest.y)
			until dist < this.follow_distance or this.cast_ult or this.chase

			illiana.can_transfer = true
			illiana.teleport.disabled = false

			if this.chase then
			else
				if sa then
					shoot(sa)
				end

				if sc and store.tick_ts - sc.ts > sc.cooldown then
					local targets = U.find_enemies_in_range(store, this.pos, 0, sc.detection_range, 0, 0, function(v)
						return v.unit.is_stunned
					end)

					if not targets or #targets == 0 then
						SU.delay_attack(store, sc, fts(10))
					else
						illiana.dragon_skill_c_in_progress = true

						local s = this.render.sprites[1]
						local target = targets[1]
						local og_speed = this.force_motion.max_v
						local flip = this.pos.x < target.pos.x and -1 or 1

						this.force_motion.max_v = this.force_motion.max_v * 2

						repeat
							U.animation_start(this, "walk_1", nil, store.tick_ts, true)

							dest.x, dest.y = target.pos.x + target.enemy.melee_slot.x * flip, target.pos.y
							sd.flip_x = dest.x < this.pos.x

							U.force_motion_step(this, store.tick_length, dest)
							coroutine.yield()

							dist = V.dist(this.pos.x, this.pos.y, dest.x, dest.y)

							if this.chase then
								SU.delay_attack(store, sc, fts(10))

								goto label_dragon_504_0
							end
						until dist < 10

						hold_position()
						U.animation_start(this, sc.animation, this.pos.x > target.pos.x, store.tick_ts, false, 1)

						if U.y_wait(store, sc.lower_time, function(store, time)
							return this.chase
						end) then
							SU.delay_attack(store, sc, fts(10))

							illiana.dragon_skill_c_in_progress = false

							goto label_dragon_504_0
						end

						illiana.can_transfer = false
						illiana.teleport.disabled = true
						s.offset = V.v(0, sc.flight_heights[2])

						U.y_wait(store, sc.bite_time)

						s.offset = V.v(0, sc.flight_heights[3])

						S:queue(sc.sound)

						local d = E:create_entity("damage")

						d.source_id = this.id
						d.target_id = target.id
						d.value = illiana_damage(illiana, U.frandom(sc.damage_min, sc.damage_max))
						d.damage_type = sc.damage_type

						queue_damage(store, d)

						flip = this.pos.x < target.pos.x and 1 or -1

						local fx = E:create_entity(sc.hit_fx)

						fx.render.sprites[1].ts = store.tick_ts
						fx.pos.x, fx.pos.y = this.pos.x + sc.hit_fx_offset.x * flip, this.pos.y + sc.hit_fx_offset.y

						simulation:queue_insert_entity(fx)
						U.y_wait(store, sc.return_time)
						U.y_ease_key(store, s.offset, "y", s.offset.y, sc.flight_heights[1], sc.return_duration, sc.easing)
						illiana.dragon_skill_c_in_progress = false

						this.force_motion.max_v = og_speed
						illiana.can_transfer = true
						illiana.teleport.disabled = false
						sc.ts = store.tick_ts

						goto label_dragon_504_0
					end
				end

				if this.cast_ult and ult then
					illiana.can_transfer = false
					illiana.teleport.disabled = true

					U.y_animation_play(this, ult.anim_in, nil, store.tick_ts, 1, 1)
					U.animation_start(this, ult.anim_wait, nil, store.tick_ts, true, 1)

					local s = this.render.sprites[1]

					illiana.cast_ult = true

					while not this.treat and not this.ult_path do
						if illiana.health.dead or not this.cast_ult then
							this.cast_ult = false

							goto label_dragon_504_0
						end

						coroutine.yield()
					end

					U.animation_start(this, ult.anim_bite, nil, store.tick_ts, false, 1)
					U.y_wait(store, ult.bite_time)

					local flip = s.flip_x and -1 or 1
					local fx = E:create_entity(ult.bite_fx)

					fx.pos.x, fx.pos.y = this.pos.x + this.mouth_offset.x * flip, this.pos.y + this.flight_height + this.mouth_offset.y
					fx.render.sprites[1].ts = store.tick_ts

					simulation:queue_insert_entity(fx)
					U.y_wait(store, ult.fire_start_fx_time)

					local fire_start_fx = E:create_entity(ult.fire_start_fx)

					fire_start_fx.pos.x, fire_start_fx.pos.y = this.pos.x + this.mouth_offset.x * flip, this.pos.y + this.flight_height + this.mouth_offset.y
					fire_start_fx.render.sprites[1].ts = store.tick_ts

					simulation:queue_insert_entity(fire_start_fx)
					U.y_animation_wait(this)

					local n = P:node_pos(this.ult_path.pi, this.ult_path.spi, this.ult_path.ni)
					local flip_x = n.x < this.pos.x

					U.animation_start(this, ult.anim_walk, flip_x, store.tick_ts, true, 1)

					local ps_fire = E:create_entity(ult.fire_particles)

					ps_fire.particle_system.track_id = this.id

					simulation:queue_insert_entity(ps_fire)

					local ps_breath = E:create_entity(ult.breath_particles)

					ps_breath.particle_system.track_id = this.id

					simulation:queue_insert_entity(ps_breath)

					local dfsh = E:create_entity(ult.decal_fire_stream_hit)

					dfsh.render.sprites[1].ts = store.tick_ts
					dfsh.pos = V.v(this.pos.x + ult.fire_stream_hit_offset.x * (flip_x and -1 or 1), this.pos.y + ult.fire_stream_hit_offset.y)

					simulation:queue_insert_entity(dfsh)

					local aura = E:create_entity(ult.stream_aura)

					aura.pos = V.v(this.pos.x + ult.fire_stream_hit_offset.x * (flip_x and -1 or 1), this.pos.y + ult.fire_stream_hit_offset.y)
					aura.damage_source_id = illiana.id

					simulation:queue_insert_entity(aura)
					S:queue(ult.sound)

					local fire_spawn_delay = fts(7)
					local start_ts = store.tick_ts
					local dbn = ult.distance_between_nodes
					local last_node_spawned = -1
					local fires_spawned = 0
					local node_pos, particle_node_pos, angle
					local traversed = 0
					local distance = 0
					local fire_spawn_pos
					local end_flag = true
					local emit_direction, track_offset

					while traversed < ult.distance do
						U.animation_start(this, ult.anim_walk, nil, store.tick_ts, true)

						node_pos = P:node_pos(this.ult_path.pi, this.ult_path.spi, this.ult_path.ni)
						dest = node_pos
						sd.flip_x = dest.x < this.pos.x

						U.force_motion_step(this, store.tick_length, dest)

						local nearest = P:nearest_nodes(this.pos.x + ult.fire_stream_hit_offset.x * (s.flip_x and -1 or 1), this.pos.y + ult.fire_stream_hit_offset.y, {this.ult_path.pi})[1]

						aura.pos = P:node_pos(nearest[1], nearest[2], nearest[3])
						particle_node_pos = P:node_pos(this.ult_path.pi, this.ult_path.spi, this.ult_path.ni - 10)
						angle = V.angleTo(particle_node_pos.x - this.pos.x, particle_node_pos.y - (this.pos.y + this.flight_height))
						emit_direction = angle
						track_offset = V.v(ult.fire_stream_cast_offset.x * (s.flip_x and -1 or 1), ult.fire_stream_cast_offset.y)
						ps_fire.particle_system.emit_direction = emit_direction
						ps_fire.particle_system.track_offset = track_offset
						ps_breath.particle_system.emit_direction = emit_direction
						ps_breath.particle_system.track_offset = track_offset

						if fire_spawn_delay <= store.tick_ts - start_ts and dbn <= math.abs(this.ult_path.ni - last_node_spawned) then
							fire_spawn_pos = P:node_pos(this.ult_path.pi, this.ult_path.spi, this.ult_path.ni - 2)

							spawn_ground_fire(this.ult_path.pi, fire_spawn_pos, fires_spawned)

							fires_spawned = fires_spawned + 1
							last_node_spawned = this.ult_path.ni
						end

						distance = V.dist2(node_pos.x, node_pos.y, this.pos.x, this.pos.y)

						if distance < 400 then
							this.ult_path.ni = this.ult_path.ni - 3
							traversed = traversed + 3
						end

						if ult.distance - traversed <= 9 and end_flag then
							ps_fire.particle_system.emit = false
							ps_breath.particle_system.emit = false
							aura.aura.duration = 0
							fire_spawn_delay = 1e+99
							end_flag = false

							break
						end

						coroutine.yield()
					end

					local ts = store.tick_ts

					U.animation_start(this, ult.anim_end, nil, store.tick_ts, false, 1)

					this.force_motion.max_v = og_max_v / 4
					this.force_motion.a_step = og_a_step / 4
					this.force_motion.max_a = og_max_a / 4

					local ps_smoke = E:create_entity(ult.smoke_particles)

					ps_smoke.particle_system.track_id = this.id
					ps_smoke.particle_system.emit = false

					simulation:queue_insert_entity(ps_smoke)

					repeat
						node_pos = P:node_pos(this.ult_path.pi, this.ult_path.spi, this.ult_path.ni)
						dest = node_pos
						sd.flip_x = dest.x < this.pos.x

						U.force_motion_step(this, store.tick_length, dest)

						distance = V.dist2(node_pos.x, node_pos.y, this.pos.x, this.pos.y)

						if distance < 400 then
							this.ult_path.ni = this.ult_path.ni - 3
						end

						if store.tick_ts - ts > fts(18) then
							ps_smoke.particle_system.emit = true
							ps_smoke.particle_system.emit_direction = s.flip_x and math.pi or 2 * math.pi
							ps_smoke.particle_system.track_offset = V.v(ult.smoke_offset.x * (s.flip_x and -1 or 1), ult.smoke_offset.y)
						end

						if store.tick_ts - ts > fts(30) then
							ps_smoke.particle_system.emit = false
						end

						coroutine.yield()
					until store.tick_ts - ts > fts(39)

					this.force_motion.max_v = og_max_v
					this.force_motion.a_step = og_a_step
					this.force_motion.max_a = og_max_a

					simulation:queue_remove_entity(ps_fire)
					simulation:queue_remove_entity(ps_breath)
					simulation:queue_remove_entity(ps_smoke)
					SU.hero_gain_xp_from_skill(illiana, illiana.hero.skills.ultimate)

					this.cast_ult = false
					this.ult_path = nil
					this.treat = nil
					illiana.can_transfer = true
					illiana.teleport.disabled = false

					goto label_dragon_504_0
				end

				shoot(ba)
				U.animation_start(this, "idle", nil, store.tick_ts, true)
			end
		end

		::label_dragon_504_0::

		coroutine.yield()
	end
end

local tt

tt = RT("hero_illiana", "hero")
AC(tt, "melee", "ranged", "timed_attacks", "transfer", "teleport", "dodge")
tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.hp_max = {140, 150, 160, 170, 180, 190, 200, 210, 220, 230}
tt.hero.level_stats.melee_damage_min = {4, 4, 5, 5, 6, 7, 8, 8, 9, 10}
tt.hero.level_stats.melee_damage_max = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16}
tt.hero.level_stats.ranged_damage_min = {4, 7, 8, 9, 10, 12, 13, 14, 15, 16}
tt.hero.level_stats.ranged_damage_max = {10, 13, 15, 17, 20, 22, 24, 26, 29, 31}
tt.dragon_ranged_damage_min = {4, 5, 5, 6, 7, 8, 9, 10, 11, 12}
tt.dragon_ranged_damage_max = {7, 8, 9, 11, 12, 14, 15, 17, 18, 20}
tt.dragon_t = "decal_illiana_dragon"
tt.hero.skills.skill_a = CC("hero_skill")
tt.hero.skills.skill_a.damage_min = {20, 45, 75}
tt.hero.skills.skill_a.damage_max = {40, 70, 105}
tt.hero.skills.skill_a.damage_type = DAMAGE_TRUE
tt.hero.skills.skill_a.cooldown = 12
tt.hero.skills.skill_a.max_bounces = 2
tt.hero.skills.skill_a.bounce_range = 75
tt.hero.skills.skill_a.min_targets = 3
tt.hero.skills.skill_a.tag_duration = 4
tt.hero.skills.skill_a.armor_red = 0.25
tt.hero.skills.skill_a.magic_armor_red = 0
tt.hero.skills.skill_a.key = "TAG"
tt.hero.skills.skill_a.xp_gain = {48, 96, 144}
tt.hero.skills.skill_a.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.skill_b = CC("hero_skill")
tt.hero.skills.skill_b.cooldown = 15
tt.hero.skills.skill_b.min_targets = 3
tt.hero.skills.skill_b.detection_radius = 165
tt.hero.skills.skill_b.stun_radius = 100
tt.hero.skills.skill_b.stun_duration = {2, 4, 6}
tt.hero.skills.skill_b.key = "GLITTER_BOMB"
tt.hero.skills.skill_b.xp_gain = {60, 120, 180}
tt.hero.skills.skill_b.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.skill_c = CC("hero_skill")
tt.hero.skills.skill_c.cooldown = 1
tt.hero.skills.skill_c.damage_min = {42, 62, 92}
tt.hero.skills.skill_c.damage_max = {58, 88, 134}
tt.hero.skills.skill_c.damage_type = DAMAGE_PHYSICAL
tt.hero.skills.skill_c.detection_range = 165
tt.hero.skills.skill_c.key = "EASY_PREY"
tt.hero.skills.skill_c.xp_gain = {32, 64, 96}
tt.hero.skills.skill_c.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.cooldown = 35
tt.hero.skills.ultimate.detection_range = 200
tt.hero.skills.ultimate.min_targets = 3
tt.hero.skills.ultimate.distance = 50
tt.hero.skills.ultimate.key = "SPARKY_INCINERATE"
tt.hero.skills.ultimate.xp_gain = {140}
tt.hero.skills.ultimate.xp_level_steps = {
	[5] = 1
}
tt.hero.skills.ultimate.active = false
tt.hero.skills.talent_1 = CC("hero_skill")
tt.hero.skills.talent_1.dodge_chance = 0.4
tt.hero.skills.talent_1.key = "TEAMWORK"
tt.hero.skills.talent_1.disabled = true
tt.hero.skills.talent_1.xp_level_steps = {
	[1] = 1
}
tt.hero.skills.talent_2 = CC("hero_skill")
tt.hero.skills.talent_2.damage_factor = 2
tt.hero.skills.talent_2.key = "AIRBORNE_BLISS"
tt.hero.skills.talent_2.disabled = true
tt.hero.skills.talent_2.xp_level_steps = {
	[1] = 1
}
tt.health.dead_lifetime = 15
tt.health.hp_max = nil
tt.health.armor = nil
tt.health_bar.offset = vec_2(0, 39)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_illiana_level_up
tt.hero.respawn_animation = "respawn"
tt.info.hero_portrait = "kr6_hero_portraits_0012"
tt.info.portrait = "kr6_info_portraits_heroes_0014"
tt.main_script.insert = hero_illiana_insert
tt.main_script.update = hero_illiana_update
tt.motion.max_speed = 70
tt.regen.cooldown = 1
tt.transfer.extra_speed = 25
tt.transfer.min_distance = 160
tt.teleport.min_distance = 160
tt.teleport.disabled = false
tt.dodge.chance = 0
tt.dodge.show_pop = true
tt.dodge.silent = true
tt.dodge.pop = "pop_miss"
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].prefix = "hero_illianaDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk_1"}
tt.render.sprites[1].draw_order = DO_HEROES
tt.render.sprites[1].scale = vec_2(1.15, 1.15)
tt.sound_events.change_rally_point = "HeroIllianaTaunt"
tt.sound_events.death = "HeroIllianaDeath"
tt.sound_events.respawn = "HeroIllianaTauntIntro"
tt.sound_events.room_select = "HeroIllianaTauntSelect"
tt.sound_events.hero_room_select = "HeroIllianaTauntSelect"
tt.sound_events.level_up = "HeroIllianaTauntLevelUp"
tt.soldier.melee_slot_offset = vec_2(5, 0)
tt.ui.click_rect = r(-19, -5, 38, 43)
tt.unit.hit_offset = vec_2(0, 12)
tt.unit.marker_offset = vec_2(0, -1)
tt.unit.mod_offset = vec_2(0, 19.9)
tt.unit.hide_after_death = false
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].animation = "melee_attack"
tt.melee.attacks[1].damage_min = 4
tt.melee.attacks[1].damage_max = 7
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 1.5
tt.melee.attacks[1].hit_fx = "fx_illiana_basic_melee_hit"
tt.melee.attacks[1].hit_offset = vec_2(30, 20)
tt.melee.range = 60
tt.melee.cooldown = 1
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animation = "range_attack"
tt.ranged.attacks[1].bullet = "bullet_illiana_basic"
tt.ranged.attacks[1].cooldown = 1
tt.ranged.attacks[1].min_range = 70
tt.ranged.attacks[1].max_range = 165
tt.ranged.attacks[1].damage_min = 4
tt.ranged.attacks[1].damage_max = 10
tt.ranged.attacks[1].xp_gain_factor = 1.5
tt.ranged.attacks[1].shoot_time = fts(11)
tt.ranged.attacks[1].bullet_start_offset = {vec_2(5, 20)}
tt.ranged.attacks[1].ignore_hit_offset = false
tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
tt.ranged.attacks[1].node_prediction = fts(15)
tt.ranged.attacks[1].sound = "HeroIllianaBasicAttackCast"
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].basic_range = 165
tt.timed_attacks.list[1].cooldown = 12
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].bullet = "bullet_illiana_skill_b"
tt.timed_attacks.list[2].animation = "skill_b"
tt.timed_attacks.list[2].shoot_time = fts(27)
tt.timed_attacks.list[2].max_range = 165
tt.timed_attacks.list[2].min_targets = 3
tt.timed_attacks.list[2].cooldown = 15
tt.timed_attacks.list[2].offset = vec_2(-10, 5)
tt.timed_attacks.list[2].flags = 0
tt.timed_attacks.list[2].bans = bor(F_BOSS, F_FLYING)
tt.timed_attacks.list[3] = CC("custom_attack")
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].cooldown = 35
tt.timed_attacks.list[3].detection_range = 200
tt.timed_attacks.list[3].min_targets = 3
tt.timed_attacks.list[3].animation = "ulti"
tt.timed_attacks.list[3].bullet = "bullet_illiana_ulti_treat"
tt.timed_attacks.list[3].shoot_time = fts(21)
tt.timed_attacks.list[3].shoot_offset = vec_2(15, 15)
tt.timed_attacks.list[3].flags = 0
tt.timed_attacks.list[3].bans = bor(F_FLYING, F_HERO, F_FRIEND)
tt.timed_attacks.list[3].distance = 50
tt.timed_attacks.list[3].taunt = "HeroIllianaTauntUltimate"
tt.timed_attacks.list[3].sound = "HeroIllianaSparkyIncinerateCast"
tt.timed_attacks.list[3].fire_stream = {
	damage_min = 55,
	damage_max = 85,
	damage_type = DAMAGE_TRUE,
	cycle_time = 0.25,
	damage_radius = 60
}
tt.timed_attacks.list[3].fire_decal = {
	damage_min = 3,
	damage_max = 5,
	damage_type = DAMAGE_TRUE,
	duration = 3,
	cycle_time = 0.25,
	damage_radius = 50
}

tt = RT("decal_illiana_dragon", "decal")
AC(tt, "main_script", "force_motion", "ranged", "idle_flip", "timed_attacks")
tt.flight_height = 60
tt.mouth_offset = vec_2(10, 0)
tt.pickup_anim_time = fts(10)
tt.pickup_contact_time = fts(8)
tt.follow_distance = 25
tt.force_motion.max_a = 600
tt.force_motion.max_v = 360
tt.force_motion.ramp_radius = 30
tt.force_motion.fr = 0.05
tt.force_motion.a_step = 20
tt.offset = vec_2(10, 0)
tt.render.sprites[1].prefix = "hero_illiana_dragonDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].offset = vec_2(0, 60)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].alpha = 100
tt.render.sprites[2].name = "decal_flying_shadow"
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animation = "attack"
tt.ranged.attacks[1].cooldown = 1
tt.ranged.attacks[1].max_range = 165
tt.ranged.attacks[1].bullet = "bullet_illiana_dragon_basic"
tt.ranged.attacks[1].shoot_time = fts(14)
tt.ranged.attacks[1].bullet_start_offset = vec_2(10, -5)
tt.ranged.attacks[1].node_prediction = fts(22)
tt.ranged.attacks[1].xp_gain_factor = 1.5
tt.ranged.attacks[1].damage_type = DAMAGE_MAGICAL
tt.ranged.attacks[2] = table.deepclone(tt.ranged.attacks[1])
tt.ranged.attacks[2].bullet = "bullet_illiana_skill_a"
tt.ranged.attacks[2].animation = "skill_a"
tt.ranged.attacks[2].shoot_time = fts(17)
tt.ranged.attacks[2].max_range = 165
tt.ranged.attacks[2].disabled = true
tt.ranged.attacks[2].min_targets = 3
tt.ranged.attacks[2].cooldown = 12
tt.ranged.attacks[2].damage_type = DAMAGE_TRUE
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].animation = "skill_c"
tt.timed_attacks.list[1].cooldown = 1
tt.timed_attacks.list[1].damage_min = 42
tt.timed_attacks.list[1].damage_max = 58
tt.timed_attacks.list[1].damage_type = DAMAGE_PHYSICAL
tt.timed_attacks.list[1].detection_range = 165
tt.timed_attacks.list[1].lower_time = fts(17)
tt.timed_attacks.list[1].bite_time = fts(2)
tt.timed_attacks.list[1].return_time = fts(13)
tt.timed_attacks.list[1].return_duration = fts(5)
tt.timed_attacks.list[1].easing = "quad-in"
tt.timed_attacks.list[1].flight_heights = {60, 30, 20}
tt.timed_attacks.list[1].hit_fx = "fx_illiana_dragon_skill_c_hit"
tt.timed_attacks.list[1].hit_fx_offset = vec_2(25, 20)
tt.timed_attacks.list[1].sound = "HeroIllianaEasyPrey"
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].anim_in = "ulti_in"
tt.timed_attacks.list[2].anim_wait = "ulti_loop_wait"
tt.timed_attacks.list[2].anim_bite = "ulti_bite"
tt.timed_attacks.list[2].anim_walk = "ulti_walk"
tt.timed_attacks.list[2].anim_end = "ulti_end"
tt.timed_attacks.list[2].bite_time = fts(10)
tt.timed_attacks.list[2].fire_start_fx_time = fts(8)
tt.timed_attacks.list[2].distance = 50
tt.timed_attacks.list[2].distance_between_nodes = 4
tt.timed_attacks.list[2].random_for_node = 4
tt.timed_attacks.list[2].bite_fx = "fx_illiana_dragon_skill_c_hit"
tt.timed_attacks.list[2].fire_start_fx = "fx_illiana_ult_fire_start"
tt.timed_attacks.list[2].fire_stream_cast_offset = vec_2(8, 55)
tt.timed_attacks.list[2].decal_fire_stream_hit = "decal_illiana_ult_stream_hit"
tt.timed_attacks.list[2].fire_stream_hit_offset = vec_2(70, 0)
tt.timed_attacks.list[2].stream_aura = "aura_illiana_ult_fire_stream"
tt.timed_attacks.list[2].decal_fire_ground = "decal_illiana_ult_ground_fire"
tt.timed_attacks.list[2].decal_fire_ground_aura = "aura_illiana_ult_ground_fire"
tt.timed_attacks.list[2].breath_particles = "ps_illiana_ult_breath"
tt.timed_attacks.list[2].fire_particles = "ps_illiana_ult_fire"
tt.timed_attacks.list[2].smoke_particles = "ps_illiana_ult_smoke"
tt.timed_attacks.list[2].smoke_offset = vec_2(30, 63)
tt.timed_attacks.list[2].sound = "HeroIllianaSparkyIncinerateFire"
tt.main_script.update = decal_illiana_dragon_update

tt = RT("ps_bullet_illiana_basic", "particle_system")
tt.particle_system.name = "hero_Illiana_FX_illiana_attack_projectile_particle_action"
tt.particle_system.particle_lifetime = {fts(8), fts(8)}
tt.particle_system.emission_rate = 30

tt = RT("ps_bullet_illiana_dragon_basic", "particle_system")
tt.particle_system.name = "hero_Illiana_FX_dragon_attack_particle"
tt.particle_system.particle_lifetime = {fts(8), fts(8)}
tt.particle_system.emission_rate = 30

tt = RT("ps_bullet_illiana_skill_a", "particle_system")
tt.particle_system.name = "hero_Illiana_FX_dragon_skill_a_particle_idle"
tt.particle_system.particle_lifetime = {fts(13), fts(13)}
tt.particle_system.emission_rate = 30

tt = RT("ps_bullet_illiana_skill_b", "particle_system")
tt.particle_system.name = "hero_Illiana_FX_illiana_skill_b_particle"
tt.particle_system.particle_lifetime = {fts(7), fts(7)}
tt.particle_system.emission_rate = 30

tt = RT("ps_illiana_ult_fire", "particle_system")
tt.particle_system.emission_rate = 10
tt.particle_system.emit_area_spread = vec_2(0, 0)
tt.particle_system.emit_direction = -math.pi / 4
tt.particle_system.emit_speed = {250, 250}
tt.particle_system.particle_lifetime = {fts(15), fts(15)}
tt.particle_system.name = "hero_Illiana_FX_dragon_ulti_fire_particle_in"
tt.particle_system.z = Z_OBJECTS
tt.particle_system.draw_order = 1

tt = RT("ps_illiana_ult_breath", "particle_system")
tt.particle_system.emission_rate = 15
tt.particle_system.emit_area_spread = vec_2(0, 0)
tt.particle_system.emit_direction = -math.pi / 4
tt.particle_system.emit_speed = {250, 250}
tt.particle_system.particle_lifetime = {fts(16), fts(16)}
tt.particle_system.name = "hero_Illiana_FX_dragon_ulti_breath_particle_in"
tt.particle_system.z = Z_OBJECTS

tt = RT("ps_illiana_ult_smoke", "particle_system")
tt.particle_system.emission_rate = 10
tt.particle_system.emit_area_spread = vec_2(0, 0)
tt.particle_system.emit_direction = -math.pi / 4
tt.particle_system.emit_speed = {100, 100}
tt.particle_system.particle_lifetime = {fts(12), fts(12)}
tt.particle_system.name = "hero_Illiana_FX_dragon_ulti_smoke_particle_in"
tt.particle_system.z = Z_OBJECTS

tt = RT("fx_bullet_illiana_basic_ranged_hit", "fx")
tt.render.sprites[1].name = "hero_Illiana_FX_illiana_attack_hit"
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[1].animated = true

tt = RT("fx_illiana_basic_melee_hit", "fx")
tt.render.sprites[1].prefix = "hero_Illiana_FX_illiana_melee_attack_hit"
tt.render.sprites[1].name = "hit"
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[1].animated = true

tt = RT("fx_bullet_illiana_dragon_basic_hit", "fx")
tt.render.sprites[1].prefix = "hero_Illiana_FX_dragon_attack_hit"
tt.render.sprites[1].name = "hit"
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[1].animated = true

tt = RT("fx_bullet_illiana_skill_a_hit", "fx")
tt.render.sprites[1].prefix = "hero_Illiana_FX_dragon_skill_a_hit"
tt.render.sprites[1].name = "hit"
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[1].animated = true

tt = RT("fx_bullet_illiana_skill_b_hit", "fx")
tt.render.sprites[1].prefix = "hero_Illiana_FX_illiana_skill_b_hit"
tt.render.sprites[1].name = "hit"
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[1].animated = true

tt = RT("fx_illiana_dragon_skill_c_hit", "fx")
tt.render.sprites[1].prefix = "hero_Illiana_FX_dragon_bite_fx"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[1].animated = true

tt = RT("fx_illiana_ult_fire_start", "decal_timed")
tt.render.sprites[1].prefix = "hero_illiana_dragon_fire_fxDef"
tt.render.sprites[1].name = "ulti_bite"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_EFFECTS

tt = RT("decal_illiana_skill_b_hit_decal", "decal_timed")
tt.render.sprites[1].prefix = "hero_Illiana_FX_illiana_skill_b_hit_decal"
tt.render.sprites[1].name = "hit"

tt = RT("decal_illiana_ult_stream_hit", "decal_scripted")
tt.render.sprites[1].prefix = "hero_Illiana_FX_dragon_ulti_breath_hit"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].z = Z_OBJECTS
tt.main_script.update = scripts.decal_utils.animation_in_loop_out.update
tt.animation_start = "run"
tt.delay_animation_start = fts(4)

tt = RT("decal_illiana_ult_ground_fire", "decal_scripted")
AC(tt, "tween")
tt.render.sprites[1].prefix = "hero_Illiana_FX_ulti_fire_decal"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].loop = true
tt.render.sprites[1].scale = vec_2(0.75, 0.75)
tt.main_script.update = scripts.decal_utils.animation_in_loop_out.update
tt.main_script.remove = scripts.tween_utils.reverse_remove
tt.tween.props[1].keys = {{0, 0}, {fts(6), 255}}
tt.tween.props[1].name = "alpha"
tt.tween.disabled = false
tt.tween.run_once = true
tt.tween.remove = false
tt.duration = 3
tt.animation_idle = "loop"

tt = RT("bullet_illiana_basic", "bolt")
tt.bullet.damage_min = 4
tt.bullet.damage_max = 10
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.hit_fx = "fx_bullet_illiana_basic_ranged_hit"
tt.bullet.particles_name = "ps_bullet_illiana_basic"
tt.bullet.xp_gain_factor = 1.5
tt.bullet.min_speed = 500
tt.bullet.max_speed = 500
tt.bullet.align_with_trajectory = true
tt.bullet.ignore_hit_offset = false
tt.bullet.pop = nil
tt.bullet.pop_chance = 0
tt.bullet.g = nil
tt.bullet.max_track_distance = REF_H / 6
tt.render.sprites[1].name = "hero_Illiana_FX_illiana_attack_projectile"
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[1].animated = false
tt.main_script.insert = illiana_bolt_insert
tt.main_script.update = illiana_bolt_update
tt.sound_events.insert = nil

tt = RT("bullet_illiana_dragon_basic", "bolt")
tt.bullet.damage_min = 4
tt.bullet.damage_max = 7
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.hit_fx = "fx_bullet_illiana_dragon_basic_hit"
tt.bullet.particles_name = "ps_bullet_illiana_dragon_basic"
tt.bullet.min_speed = 500
tt.bullet.max_speed = 500
tt.bullet.align_with_trajectory = true
tt.bullet.ignore_hit_offset = false
tt.bullet.pop = nil
tt.bullet.pop_chance = 0
tt.bullet.g = nil
tt.bullet.max_track_distance = REF_H / 6
tt.render.sprites[1].name = "hero_Illiana_FX_dragon_attack_projectile"
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[1].animated = false
tt.main_script.insert = illiana_bolt_insert
tt.main_script.update = illiana_bolt_update
tt.sound_events.insert = "HeroIllianaSparkyBasicAttackCast"

tt = RT("bullet_illiana_skill_a", "bullet")
tt.bullet.damage_min = 20
tt.bullet.damage_max = 40
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.g = 0
tt.bullet.fixed_speed = FPS * 12
tt.bullet.hide_radius = 0
tt.bullet.hit_fx = "fx_bullet_illiana_skill_a_hit"
tt.bullet.particles_name = "ps_bullet_illiana_skill_a"
tt.bullet.mod = "mod_illiana_tag_skill_a"
tt.bullet.vis_flags = F_RANGED
tt.render.sprites[1].prefix = "hero_Illiana_FX_dragon_skill_a_projectile"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].loop = true
tt.sound_bounce = "HeroIllianaTagBounce"
tt.main_script.update = illiana_tag_bullet_update
tt.max_bounces = 2
tt.bounce_range = 75
tt.sound_events.insert = "HeroIllianaTagCast"

tt = RT("bullet_illiana_skill_b", "bomb")
tt.bullet.damage_min = 0
tt.bullet.damage_max = 0
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.flight_time = fts(20)
tt.bullet.hit_fx = "fx_bullet_illiana_skill_b_hit"
tt.bullet.hit_decal = "decal_illiana_skill_b_hit_decal"
tt.bullet.particles_name = "ps_bullet_illiana_skill_b"
tt.bullet.align_with_trajectory = true
tt.bullet.hit_payload = "aura_illiana_skill_b_stun"
tt.render.sprites[1].prefix = "hero_Illiana_FX_illiana_skill_b_projectile"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].loop = true
tt.render.sprites[1].animated = true
tt.bullet.g = -1.5 / (fts(1) * fts(1))
tt.main_script.insert = scripts.bomb_kr6.insert
tt.main_script.update = scripts.bomb_kr6.update
tt.sound_events.hit_water = nil
tt.sound_events.insert = nil
tt.sound_events.hit = "HeroIllianaGlitterBombImpact"

tt = RT("bullet_illiana_ulti_treat", "bomb")
tt.bullet.damage_min = 0
tt.bullet.damage_max = 0
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.flight_time = fts(9)
tt.bullet.hit_fx = nil
tt.bullet.hit_decal = nil
tt.bullet.particles_name = nil
tt.bullet.align_with_trajectory = true
tt.bullet.hit_payload = nil
tt.bullet.hide_radius = nil
tt.bullet.prediction_error = false
tt.bullet.predict_target_pos = false
tt.main_script.insert = scripts.bomb_kr6.insert
tt.main_script.update = scripts.bomb_kr6.update
tt.sound_events.hit_water = nil
tt.sound_events.insert = nil
tt.sound_events.hit = nil
tt.render.sprites[1].prefix = "hero_Illiana_FX_ulti_projectile"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_BULLETS

tt = RT("aura_illiana_skill_b_stun", "aura")
tt.aura.mod = "mod_illiana_skill_b_stun"
tt.aura.radius = 100
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND, F_HERO)
tt.aura.cycles = 1
tt.aura.duration = 1e+99
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update

tt = RT("aura_illiana_ult_fire_stream", "aura")
tt.aura.vis_bans = bor(F_FRIEND, F_HERO, F_FLYING)
tt.aura.vis_flags = bor(F_AREA)
tt.aura.cycle_time = 0.25
tt.aura.duration = 1e+99
tt.aura.damage_min = 55
tt.aura.damage_max = 85
tt.aura.damage_type = DAMAGE_TRUE
tt.aura.radius = 60
tt.main_script.update = aura_illiana_fire_update

tt = RT("aura_illiana_ult_ground_fire", "aura")
tt.aura.vis_bans = bor(F_FRIEND, F_HERO, F_FLYING)
tt.aura.vis_flags = bor(F_AREA)
tt.aura.cycle_time = 0.25
tt.aura.duration = 3
tt.aura.damage_min = 3
tt.aura.damage_max = 5
tt.aura.damage_type = DAMAGE_TRUE
tt.aura.radius = 50
tt.main_script.update = aura_illiana_fire_update

tt = RT("mod_illiana_tag_skill_a", "modifier")
AC(tt, "render", "tween")
tt.modifier.duration = 4
tt.modifier.use_mod_offset = false
tt.modifier.vis_bans = 0
tt.modifier.vis_flags = bor(F_MOD)
tt.main_script.insert = mod_illiana_tag_skill_a_insert
tt.main_script.update = scripts.mod_track_target.update
tt.main_script.remove = mod_illiana_tag_skill_a_remove
tt.armor_red = 0.25
tt.magic_armor_red = 0
tt.tween.disabled = true
tt.tween.props[1].name = "alpha"
tt.tween.props[1].sprite_id = 1
tt.tween.props[1].keys = {{0, 0}, {1, 255}}
tt.render.sprites[1].prefix = "hero_Illiana_FX_skill_a_tag_decal"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].prefix_names = {"hero_Illiana_FX_skill_a_tag_decal", "hero_Illiana_FX_skill_a_tag_decal", "hero_Illiana_FX_skill_a_tag_decal_big"}

tt = RT("mod_illiana_skill_b_stun", "mod_stun")
tt.duration_levels = {2, 4, 6}
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt.main_script.insert = mod_illiana_skill_b_stun_insert
tt.render.sprites[1].prefix = "hero_Illiana_FX_illiana_stun_fx"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].size_names = nil
