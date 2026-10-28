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
local tpos = U.tpos
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local tt

local function arrow_hero_hunter_ricochet_trail_update(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local dest = V.vclone(b.to)

	local function update_sprite()
		if this.track_target and target and target.motion then
			local tpx, tpy = target.pos.x, target.pos.y

			if not b.ignore_hit_offset then
				tpx, tpy = tpx + target.unit.hit_offset.x, tpy + target.unit.hit_offset.y
			end

			local d = math.max(math.abs(tpx - b.to.x), math.abs(tpy - b.to.y))

			if d > b.max_track_distance then
				target = nil
			else
				dest.x, dest.y = target.pos.x, target.pos.y

				if target.unit and target.unit.hit_offset then
					dest.x, dest.y = dest.x + target.unit.hit_offset.x, dest.y + target.unit.hit_offset.y
				end
			end
		end

		local angle = V.angleTo(dest.x - this.pos.x, dest.y - this.pos.y)

		s.r = angle

		local dist_offset = 0

		if this.dist_offset then
			dist_offset = this.dist_offset
		end

		s.scale.x = (V.dist(dest.x, dest.y, this.pos.x, this.pos.y) + dist_offset) / this.image_width
	end

	if not b.ignore_hit_offset and this.track_target and target and target.motion then
		b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
	end

	s.scale = s.scale or V.v(1, 1)
	s.ts = store.tick_ts

	if this.ray_duration then
		while store.tick_ts - s.ts < this.ray_duration do
			update_sprite()
			coroutine.yield()
		end
	end

	simulation:queue_remove_entity(this)
end

local function soldier_hero_hunter_ultimate_update(this, store)
	local brk, star

	this.reinforcement.ts = store.tick_ts
	this.render.sprites[1].ts = store.tick_ts
	this.ranged.attacks[1].level = this.level
	this.hero_hunter_ref = nil

	for _, e in pairs(store.soldiers) do
		if e.template_name == "hero_hunter" then
			this.hero_hunter_ref = e

			break
		end
	end

	this.ranged.attacks[1].level = this.hero_hunter_ref.hero.skills.ultimate.level

	U.y_animation_play(this, "summon", nil, store.tick_ts, 1)

	while true do
		if this.hero_hunter_ref then
			local dist2 = V.dist2(this.pos.x, this.pos.y, this.hero_hunter_ref.pos.x, this.hero_hunter_ref.pos.y)

			if dist2 <= this.distance_to_revive * this.distance_to_revive and this.hero_hunter_ref.health.dead then
				this.hero_hunter_ref.force_respawn = true
			end
		end

		if this.health.dead or this.reinforcement.duration and store.tick_ts - this.reinforcement.ts > this.reinforcement.duration then
			if this.health.hp > 0 then
				this.reinforcement.hp_before_timeout = this.health.hp
			end

			if this.health.dead then
				this.reinforcement.fade = nil
			-- this.tween = nil
			else
				this.reinforcement.fade = true
			end

			this.health.hp = 0

			SU.remove_modifiers(store, this)

			this.ui.can_click = false

			SU.y_soldier_death(store, this)

			return
		end

		while this.nav_rally.new do
			if SU.y_hero_new_rally(store, this) then
				goto label_367_0
			end
		end

		if this.ranged then
			brk, star = SU.y_soldier_ranged_attacks(store, this)

			if brk or star == A_DONE then
				goto label_367_0
			elseif star == A_IN_COOLDOWN then
			-- block empty
			end
		end

		SU.soldier_idle(store, this)
		SU.soldier_regen(store, this)

		::label_367_0::

		coroutine.yield()
	end
end

local function arrow_hero_hunter_ricochet_update(this, store)
	local b = this.bullet
	local target = store.entities[b.target_id]
	local bounce_count = 0
	local already_hit = {}
	local last_target
	local start_ts = store.tick_ts

	this.end_bounces = false

	local function create_arrow_trail(from, target)
		local bullet = E:create_entity(this.trail_arrow)

		bullet.pos:copy(this.pos)
		bullet.bullet.from:copy(from)
		bullet.bullet.to:copy(target.pos)

		bullet.bullet.to.x = bullet.bullet.to.x + target.unit.hit_offset.x
		bullet.bullet.to.y = bullet.bullet.to.y + target.unit.hit_offset.y
		bullet.bullet.target_id = target.id
		bullet.bullet.source_id = this.id
		bullet.bullet.xp_dest_id = this.id
		bullet.bullet.damage_factor = this.bullet.damage_factor

		simulation:queue_insert_entity(bullet)
	end

	::label_346_0::

	if not b.ignore_hit_offset and this.track_target and target and target.motion then
		b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
	end

	if last_target ~= nil then
		this.pos = V.vclone(last_target.pos)

		if last_target.unit.hit_offset then
			this.pos.x, this.pos.y = this.pos.x + last_target.unit.hit_offset.x, this.pos.y + last_target.unit.hit_offset.y
		end
	end

	while store.tick_ts - start_ts < b.hit_time do
		coroutine.yield()

		if target and U.flag_has(target.vis.bans, F_RANGED) then
			target = nil
		end
	end

	if target then
		create_arrow_trail(this.pos, target)
	end

	while store.tick_ts - start_ts < this.ray_duration do
		coroutine.yield()
	end

	if target and not target.health.dead then
		S:queue(this.sound_bounce)

		local mods = b.mods

		for _, mod_name in ipairs(mods) do
			local m = E:create_entity(mod_name)

			m.modifier.source_id = this.id
			m.modifier.target_id = target.id
			m.modifier.damage_factor = this.bullet.damage_factor
			m.bounce_count = bounce_count

			simulation:queue_insert_entity(m)
		end

		table.insert(already_hit, target.id)

		last_target = target
	end

	S:queue(this.sound)
	U.y_wait_unconditional(store, this.time_between_bounces)

	if target then
		if bounce_count < this.bounces then
			local targets = U.find_enemies_in_range_filter_on(target.pos, this.bounce_range, b.vis_flags, b.vis_bans, function(v)
				return not table.contains(already_hit, v.id)
			end)

			if targets then
				table.sort(targets, function(e1, e2)
					return V.dist2(this.pos.x, this.pos.y, e1.pos.x, e1.pos.y) < V.dist2(this.pos.x, this.pos.y, e2.pos.x, e2.pos.y)
				end)

				target = targets[1]
				bounce_count = bounce_count + 1
				b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
				b.target_id = target.id

				goto label_346_0
			end
		end
	end

	-- 添加一个返回攻击效果
	if target then
		local source = store.entities[b.source_id]

		if source then
			U.y_wait_unconditional(store, E:get_template("mod_hero_hunter_ricochet_attack").modifier.duration)
			create_arrow_trail(target.pos, source)

			local targets = U.find_enemies_around_line(target.pos.x, target.pos.y, source.pos.x, source.pos.y, this.back_radius, b.vis_flags, b.vis_bans)

			if targets then
				S:queue(this.sound_bounce)

				local mods = b.mods

				for _, t in ipairs(targets) do
					bounce_count = bounce_count + 1

					for _, mod_name in ipairs(mods) do
						local m = E:create_entity(mod_name)

						m.modifier.source_id = this.id
						m.modifier.target_id = t.id
						m.modifier.damage_factor = this.bullet.damage_factor
						m.bounce_count = bounce_count
						m.back_attack = true

						simulation:queue_insert_entity(m)
					end
				end
			end

			U.y_wait_unconditional(store, this.time_between_bounces)
		end
	end

	this.end_bounces = true

	simulation:queue_remove_entity(this)
end

local function aura_hero_hunter_shoot_around_update(this, store)
	this.aura.ts = store.tick_ts

	local last_hit_ts = 0
	local cycles_count = 0
	local last_fx = store.tick_ts

	local function distribute_fx(x, y, qty)
		if qty < 1 then
			return nil
		end

		local nodes = P:nearest_nodes(x, y, nil, nil, true)

		if #nodes < 1 then
			log.debug("cannot insert fx, no valid nodes nearby %s,%s", x, y)
		end

		local opi, ospi, oni = unpack(nodes[1])
		local offset_options = {-2, -4, -6, 2, 4, 6}
		local positions = {}

		for i, offset in ipairs(offset_options) do
			if qty <= #positions then
				break
			end

			local ni = oni + offset
			local spi = km.zmod(ospi + i, 3)
			local npos = P:node_pos(opi, spi, ni)

			if P:is_node_valid(opi, ni) and band(GR:cell_type(npos.x, npos.y), bor(TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK)) == 0 then
				table.insert(positions, npos)
			end
		end

		return positions
	end

	while true do
		if this.aura.cycles then
			if cycles_count >= this.aura.cycles then
				break
			end
		elseif this.aura.duration >= 0 and store.tick_ts - this.aura.ts >= this.aura.duration + this.aura.level * this.aura.duration_inc then
			break
		end

		if this.aura.track_source and this.aura.source_id then
			local te = store.entities[this.aura.source_id]

			if not te or te.health and te.health.dead then
				simulation:queue_remove_entity(this)

				return
			end

			if te and te.pos then
				this.pos.x, this.pos.y = te.pos.x, te.pos.y
			end
		end

		if store.tick_ts - last_hit_ts >= this.aura.cycle_time then
			cycles_count = cycles_count + 1
			last_hit_ts = store.tick_ts

			local targets = U.find_enemies_in_range_filter_on(this.pos, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans, function(v)
				return (not this.aura.allowed_templates or table.contains(this.aura.allowed_templates, v.template_name)) and (not this.aura.excluded_templates or not table.contains(this.aura.excluded_templates, v.template_name)) and (not this.aura.excluded_entities or not table.contains(this.aura.excluded_entities, v.id))
			end) or {}

			for _, target in ipairs(targets) do
				local dmin, dmax = this.aura.damage_min, this.aura.damage_max

				if this.aura.damage_inc then
					dmin = dmin + this.aura.damage_inc * this.aura.level
					dmax = dmax + this.aura.damage_inc * this.aura.level
				end

				local d = E.assign_damage(this.aura.damage_type, math.random(dmin, dmax) * this.aura.damage_factor, this.id, target.id)

				d.track_damage = this.aura.track_damage
				d.xp_dest_id = this.aura.xp_dest_id
				d.xp_gain_factor = this.aura.xp_gain_factor

				queue_damage(store, d)

				local mods = this.aura.mods or {this.aura.mod}

				for _, mod_name in ipairs(mods) do
					local m = E:create_entity(mod_name)

					m.modifier.level = this.aura.level
					m.modifier.target_id = target.id
					m.modifier.source_id = this.id

					if this.aura.hide_source_fx and target.id == this.aura.source_id then
						m.render = nil
					end

					simulation:queue_insert_entity(m)
				end
			end
		end

		if store.tick_ts - last_fx >= this.fx_every then
			local positions = distribute_fx(this.pos.x, this.pos.y, 9)

			positions = table.random_order(positions)

			for i = 1, this.fx_amount do
				if i <= #positions then
					local fx = E:create_entity(this.fx)

					fx.pos = positions[i]
					fx.render.sprites[1].ts = store.tick_ts

					simulation:queue_insert_entity(fx)
				end
			end

			last_fx = store.tick_ts
		end

		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

local function bullet_hero_hunter_ranged_attack_update(this, store)
	local b = this.bullet
	local target = store.entities[b.target_id]

	U.y_wait_unconditional(store, b.flight_time)

	if target then
		local d = SU.create_bullet_damage(b, target.id, this.id)

		queue_damage(store, d)

		if b.hit_fx then
			local fx = E:create_entity(b.hit_fx)

			fx.pos = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
			fx.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(fx)
		end

		if b.floor_fx and band(target.vis.flags, F_CLIFF) == 0 then
			local fx = E:create_entity(b.floor_fx)

			fx.pos.x, fx.pos.y = target.pos.x, target.pos.y
			fx.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(fx)
		end
	end

	simulation:queue_remove_entity(this)
end

local function hero_hunter_ultimate_update(this, store)
	local x, y = this.pos.x, this.pos.y
	local has_dante = false

	for _, s in pairs(store.soldiers) do
		if s.template_name == "hero_van_helsing" then
			has_dante = true

			break
		end
	end

	if has_dante then
		if store.entities[this.owner_id].health.dead then
			store.entities[this.owner_id].force_respawn = true
		end

		local mod = E:create_entity("mod_anya_ultimate_beacon")

		mod.modifier.source_id = this.id
		mod.modifier.target_id = this.owner_id

		simulation:queue_insert_entity(mod)
	else
		local e = E:create_entity(this.entity)

		e.pos.x = x
		e.pos.y = y

		SU.insert_unit_damage_factor_buff(e, this.damage_factor - e.unit.damage_factor)

		e.nav_rally.center = V.v(x, y)
		e.nav_rally.pos = V.vclone(e.pos)
		e.level = this.level

		simulation:queue_insert_entity(e)

		local a = E:create_entity(this.aura)

		a.pos = e.pos
		a.level = this.level
		a.aura.source_id = e.id

		simulation:queue_insert_entity(a)
		S:queue(this.sound)
		simulation:queue_remove_entity(this)
	end
end

local function soldier_hero_hunter_beast_update(this, store)
	local sf = this.render.sprites[1]
	local attack = this.attacks.list[1]
	local target = this.enemy_target
	local move_to_owner = false

	sf.offset.y = this.flight_height
	attack.ts = store.tick_ts

	local last_time_change_pos = store.tick_ts
	local idle_change_pos = V.v(0, 0)

	local function move(dest)
		sf.flip_x = dest.x < this.pos.x

		U.force_motion_step(this, store.tick_length, dest)

		return V.dist(this.pos.x, this.pos.y, dest.x, dest.y)
	end

	local function do_attack()
		local target_h = target.unit.hit_offset.y
		local target_pos = V.v(target.pos.x, target.pos.y)

		if target.unit.head_offset then
			target_pos.x, target_pos.y = target_pos.x + target.unit.head_offset.x, target_pos.y + target.unit.head_offset.y
		elseif target.unit.hit_offset then
			target_pos.x, target_pos.y = target_pos.x + target.unit.hit_offset.x, target_pos.y + target.unit.hit_offset.y
		end

		local dist = V.dist(this.pos.x, this.pos.y, target_pos.x, target_pos.y)

		while true do
			if target.health.dead then
				break
			end

			if dist < 5 and math.abs(sf.offset.y - target_h) < 5 then
				break
			end

			dist = move(target_pos)

			local move_height = target_h > sf.offset.y and 2 or -2

			sf.offset.y = km.clamp(0, this.flight_height * 1.5, sf.offset.y + move_height)

			coroutine.yield()
		end

		if target.health.dead then
			attack.ts = store.tick_ts

			return false
		end

		this.pos.x, this.pos.y = target_pos.x, target_pos.y - 1
		sf.offset.y = target_h

		U.animation_start_default(this, "attack", nil, store.tick_ts, false)

		attack.ts = store.tick_ts

		local already_hit = false
		local start_attack_ts = store.tick_ts

		this.force_motion.max_a = this.force_motion.max_a * 1.5
		this.force_motion.max_v = this.force_motion.max_v * 1.5

		while not U.animation_finished_default(this) do
			if not already_hit and store.tick_ts - start_attack_ts >= attack.shoot_time then
				already_hit = true

				local d = E.assign_damage(attack.damage_type, math.random(attack.damage_min, attack.damage_max), this.id, target.id)

				queue_damage(store, d)

				if math.random() <= this.chance_to_steal then
					local fx = E:create_entity(this.steal_fx)

					fx.pos:copy(target.pos)

					fx.pos.y = fx.pos.y + this.fx_offset_y
					fx.render.sprites[1].ts = store.tick_ts

					simulation:queue_insert_entity(fx)

					store.player_gold = store.player_gold + this.gold_to_steal
				end
			end

			move(target.pos)
			coroutine.yield()
		end

		this.force_motion.max_a = this.force_motion.max_a / 1.5
		this.force_motion.max_v = this.force_motion.max_v / 1.5

		U.animation_start_default(this, "fly", nil, store.tick_ts, true)

		return true
	end

	U.y_animation_play(this, "spawn", nil, store.tick_ts, 1)
	U.animation_start_default(this, "fly", nil, store.tick_ts, true)

	local start_ts = store.tick_ts

	while true do
		if store.tick_ts - start_ts >= this.duration then
			break
		end

		-- 目标不可用，置空
		if target and (not store.entities[target.id] or target.health.dead or not P:is_node_valid(target.nav_path.pi, target.nav_path.ni)) then
			target = nil
		end

		-- 需要和安雅保持距离
		local distance_from_owner = V.dist(this.owner.pos.x, this.owner.pos.y, this.pos.x, this.pos.y)

		if distance_from_owner > this.max_distance_from_owner then
			if target then
				local new_target = U.detect_foremost_enemy_in_range_filter_off(this.owner.pos, attack.range, attack.vis_flags, attack.vis_bans)

				if new_target then
					target = new_target
				else
					move_to_owner = true
				end
			else
				move_to_owner = true
			end
		end

		if target then
			if store.tick_ts - attack.ts > attack.cooldown and V.dist(this.pos.x, this.pos.y, target.pos.x, target.pos.y) < this.min_distance_to_attack then
				do_attack()
			end
		else
			local new_target = U.detect_foremost_enemy_in_range_filter_off(this.owner.pos, attack.range, attack.vis_flags, attack.vis_bans)

			if new_target then
				target = new_target
			end
		end

		if move_to_owner then
			local owner_pos = {}

			if store.tick_ts - last_time_change_pos >= this.idle_change_pos_cd then
				last_time_change_pos = store.tick_ts
				idle_change_pos.x = math.random(0, this.idle_change_pos_offset.x) - this.idle_change_pos_offset.x * 0.5
				idle_change_pos.y = math.random(0, this.idle_change_pos_offset.y) - this.idle_change_pos_offset.y * 0.5
			end

			owner_pos.x = this.owner.pos.x + this.owner_offset.x + idle_change_pos.x
			owner_pos.y = this.owner.pos.y + this.owner_offset.y + idle_change_pos.y

			move(owner_pos)

			local move_height = sf.offset.y < this.flight_height and 2 or -2

			sf.offset.y = km.clamp(0, this.flight_height * 1.5, sf.offset.y + move_height)
		elseif target then
			local pos = V.vclone(target.pos)

			move(pos)
		else
			move_to_owner = true

			local owner_pos = {}

			if store.tick_ts - last_time_change_pos >= this.idle_change_pos_cd then
				last_time_change_pos = store.tick_ts
				idle_change_pos.x = math.random(0, this.idle_change_pos_offset.x) - this.idle_change_pos_offset.x * 0.5
				idle_change_pos.y = math.random(0, this.idle_change_pos_offset.y) - this.idle_change_pos_offset.y * 0.5
			end

			owner_pos.x = this.owner.pos.x + this.owner_offset.x + idle_change_pos.x
			owner_pos.y = this.owner.pos.y + this.owner_offset.y + idle_change_pos.y

			move(owner_pos)

			local move_height = sf.offset.y < this.flight_height and 2 or -2

			sf.offset.y = km.clamp(0, this.flight_height * 1.5, sf.offset.y + move_height)
		end

		coroutine.yield()
	end

	U.y_animation_play(this, "leave", nil, store.tick_ts, 1)
	simulation:queue_remove_entity(this)
end

local function hero_hunter_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local b = E:get_template(this.ranged.attacks[1].bullet)

	b.bullet.damage_max = ls.ranged_damage_max[hl]
	b.bullet.damage_min = ls.ranged_damage_min[hl]

	upgrade_skill(this, "heal_strike", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.damage_min = s.damage_min[s.level]
		a.damage_max = s.damage_max[s.level]
		a.heal_factor = s.heal_factor[s.level]
	end)
	upgrade_skill(this, "ricochet", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]

		local b = E:get_template(a.bullet)

		b.bounces = s.bounces[s.level]

		local m = E:get_template(b.bullet.mods[1])

		m.damage_min = s.damage_min[s.level]
		m.damage_max = s.damage_max[s.level]
	end)
	upgrade_skill(this, "shoot_around", function(this, s)
		local a = this.timed_attacks.list[3]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]

		local aura = E:get_template(a.aura)

		aura.aura.damage_min = s.damage_min[s.level]
		aura.aura.damage_max = s.damage_max[s.level]
		aura.aura.duration = s.duration[s.level]
	end)
	upgrade_skill(this, "beasts", function(this, s)
		local a = this.timed_attacks.list[4]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]

		local entity = E:get_template(a.entity)

		entity.duration = s.duration[s.level]
		entity.attacks.list[1].damage_min = s.damage_min[s.level]
		entity.attacks.list[1].damage_max = s.damage_max[s.level]
		entity.gold_to_steal = s.gold_to_steal[s.level]
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		local a = this.ultimate

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]
		a.cooldown_death_trigger = a.cooldown * 2

		local uc = E:get_template(s.controller_name)
		local entity = E:get_template(uc.entity)
		local bullet = E:get_template(entity.ranged.attacks[1].bullet)

		bullet.bullet.damage_min = s.damage_min[s.level]
		bullet.bullet.damage_max = s.damage_max[s.level]
		uc.level = s.level

		local mod = E:get_template("mod_anya_ultimate_beacon")

		mod.inflicted_damage_factor = s.damage_factor[s.level]
	end)
	update_hp(this)

	this.hero.melee_active_status = {}

	for index, attack in ipairs(this.melee.attacks) do
		this.hero.melee_active_status[index] = attack.disabled
	end
end

local function hero_hunter_update(this, store)
	local h = this.health
	local a, skill, brk, sta
	local last_ts = store.tick_ts
	local base_speed = this.motion.max_speed
	local melee_attack = this.melee.attacks[1]
	local ranged_attack = this.ranged.attacks[1]
	local melee_hits = 0
	local heal_strike_ready = false
	local last_attack_ranged = false
	local shooting_state = false
	local heal_strike_attack = this.timed_attacks.list[1]
	local ricochet_attack = this.timed_attacks.list[2]
	local shoot_around_attack = this.timed_attacks.list[3]
	local beasts_attack = this.timed_attacks.list[4]
	local start_ts = 0

	ricochet_attack.ts = store.tick_ts - ricochet_attack.cooldown
	shoot_around_attack.ts = store.tick_ts - shoot_around_attack.cooldown
	beasts_attack.ts = store.tick_ts - beasts_attack.cooldown

	local function shoot_ricochet_arrow(store, this, target, attack, pred_pos)
		local attack_done = false
		local start_ts = store.tick_ts
		local bullet
		local bullet_to = pred_pos or target.pos

		while store.tick_ts - start_ts < attack.shoot_time do
			if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
				goto label_338_0
			end

			coroutine.yield()
		end

		S:queue(attack.sound_shoot)

		bullet = E:create_entity(attack.bullet)

		bullet.pos:copy(this.pos)
		bullet.bullet.from:copy(bullet.pos)
		bullet.bullet.to:copy(bullet_to)

		bullet.bullet.to.x = bullet.bullet.to.x + target.unit.hit_offset.x
		bullet.bullet.to.y = bullet.bullet.to.y + target.unit.hit_offset.y
		bullet.bullet.target_id = target.id
		bullet.bullet.source_id = this.id
		bullet.bullet.xp_dest_id = this.id
		bullet.bullet.level = attack.level
		bullet.bullet.damage_factor = this.unit.damage_factor

		simulation:queue_insert_entity(bullet)
		SU.hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill])

		attack_done = true

		::label_338_0::

		return attack_done, bullet
	end

	local function animation_name_facing_angle_hero_hunter(group, angle_deg)
		local a = this.render.sprites[1]
		local o_name, o_flip, o_idx
		local a1, a2, a3, a4, a5, a6, a7, a8 = 22.5, 67.5, 112.5, 157.5, 202.5, 247.5, 292.5, 337.5
		local angles = a.angles[group]

		if a1 <= angle_deg and angle_deg < a2 then
			o_name, o_flip, o_idx = angles[3], false, 3
		elseif a2 <= angle_deg and angle_deg < a3 then
			o_name, o_flip, o_idx = angles[4], false, 4
		elseif a3 <= angle_deg and angle_deg < a4 then
			o_name, o_flip, o_idx = angles[3], true, 3
		elseif a4 <= angle_deg and angle_deg < a5 then
			o_name, o_flip, o_idx = angles[2], true, 2
		elseif a5 <= angle_deg and angle_deg < a6 then
			o_name, o_flip, o_idx = angles[1], true, 1
		elseif a6 <= angle_deg and angle_deg < a7 then
			o_name, o_flip, o_idx = angles[5], false, 5
		elseif a7 <= angle_deg and angle_deg < a8 then
			o_name, o_flip, o_idx = angles[1], false, 1
		else
			o_name, o_flip, o_idx = angles[2], false, 2
		end

		return o_name, o_flip, o_idx
	end

	local function animation_name_facing_point_hero_hunter(e, group, point, idx, offset, use_path)
		local fx, fy

		if e.nav_path and use_path then
			local npos = P:node_pos(e.nav_path.pi, e.nav_path.spi, e.nav_path.ni)

			fx, fy = npos.x, npos.y
		else
			fx, fy = e.pos.x, e.pos.y
		end

		if offset then
			fx, fy = fx + offset.x, fy + offset.y
		end

		local vx, vy = V.sub(point.x, point.y, fx, fy)
		local v_angle = V.angleTo(vx, vy)
		local angle = km.unroll(v_angle)
		local angle_deg = km.rad2deg(angle)

		return animation_name_facing_angle_hero_hunter(group, angle_deg)
	end

	local function y_soldier_do_ranged_attack_hero_hunter(store, this, target, attack, pred_pos)
		local attack_done = false

		start_ts = store.tick_ts

		local bullet
		local bullet_to = pred_pos or target.pos

		if not shooting_state then
			local an, af = U.animation_name_facing_point(this, attack.animation_prepare, bullet_to)

			U.y_animation_play(this, an, af, store.tick_ts, 1)

			local an, af = animation_name_facing_point_hero_hunter(this, attack.animation_aim, bullet_to)

			U.y_animation_play(this, an, af, store.tick_ts, 1)

			shooting_state = true
			start_ts = store.tick_ts
		end

		local an, af, ai = animation_name_facing_point_hero_hunter(this, attack.animation, bullet_to)

		U.animation_start_default(this, an, af, store.tick_ts, false)
		S:queue(attack.sound, attack.sound_args)

		while store.tick_ts - start_ts < attack.shoot_time do
			if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
				goto label_343_0
			end

			coroutine.yield()
		end

		S:queue(attack.sound_shoot)

		bullet = E:create_entity(attack.bullet)

		bullet.pos:copy(this.pos)

		if attack.bullet_start_offset then
			local offset = attack.bullet_start_offset[ai]

			bullet.pos.x, bullet.pos.y = bullet.pos.x + (af and -1 or 1) * offset.x, bullet.pos.y + offset.y
		end

		bullet.bullet.from:copy(bullet.pos)
		bullet.bullet.to:copy(bullet_to)

		bullet.bullet.to.x = bullet.bullet.to.x + target.unit.hit_offset.x
		bullet.bullet.to.y = bullet.bullet.to.y + target.unit.hit_offset.y
		bullet.bullet.target_id = target.id
		bullet.bullet.source_id = this.id
		bullet.bullet.xp_dest_id = this.id
		bullet.bullet.level = this.hero.level
		bullet.bullet.damage_factor = this.unit.damage_factor
		bullet.bullet.damage_min = bullet.bullet.damage_min + this.unit.damage_buff
		bullet.bullet.damage_max = bullet.bullet.damage_max + this.unit.damage_buff

		simulation:queue_insert_entity(bullet)

		if attack.xp_from_skill then
			SU.hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill])
		end

		attack_done = true

		while not U.animation_finished_default(this) do
			if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
				break
			end

			coroutine.yield()
		end

		::label_343_0::

		return attack_done
	end

	local function y_hero_ranged_attack_hero_hunter(store, hero)
		local target, attack, pred_pos = SU.soldier_pick_ranged_target_and_attack(store, hero)

		if not target then
			return false, A_NO_TARGET
		end

		if not attack then
			return false, A_IN_COOLDOWN
		end

		local attack_done

		U.set_destination(hero, hero.pos)

		attack_done = y_soldier_do_ranged_attack_hero_hunter(store, hero, target, attack, pred_pos)

		if attack_done then
			attack.ts = start_ts

			if attack.shared_cooldown then
				for _, aa in ipairs(hero.ranged.attacks) do
					if aa ~= attack and aa.shared_cooldown then
						aa.ts = attack.ts
					end
				end
			end

			if hero.ranged.forced_cooldown then
				hero.ranged.forced_ts = start_ts
			end
		end

		if attack_done then
			return false, A_DONE
		else
			return true
		end
	end

	local function quit_shooting_state()
		if shooting_state then
			shooting_state = false

			U.y_animation_play(this, "shoot_backtoidle", nil, store.tick_ts, 1)
		end
	end

	this.health_bar.hidden = false

	U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

	while true do
		if h.dead then
			if store.tick_ts - this.ultimate.death_trigger_ts > this.ultimate.cooldown_death_trigger then
				local revive = true

				for _, s in pairs(store.soldiers) do
					if s.template_name == "soldier_hero_hunter_ultimate" then
						revive = false

						break
					end
				end

				if revive then
					S:queue(this.sound_events.change_rally_point)

					local ultimate_entity = E:create_entity(this.hero.skills.ultimate.controller_name)

					ultimate_entity.pos = V.vclone(this.pos)
					ultimate_entity.level = this.hero.skills.ultimate.level
					ultimate_entity.damage_factor = this.unit.damage_factor
					ultimate_entity.owner_id = this.id

					simulation:queue_insert_entity(ultimate_entity)

					this.ultimate.death_trigger_ts = store.tick_ts
				end
			end

			shooting_state = false

			SU.y_hero_death_and_respawn(store, this)
			U.update_max_speed(this, base_speed)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)

			shooting_state = false
		else
			while this.nav_rally.new do
				local r = this.nav_rally
				local tw = this.flywalk
				local force_flywalk = false

				-- quit_shooting_state()
				shooting_state = false

				for _, p in pairs(this.nav_grid.waypoints) do
					if GR:cell_is(p.x, p.y, bor(TERRAIN_WATER, TERRAIN_SHALLOW, TERRAIN_NOWALK)) then
						force_flywalk = true

						break
					end
				end

				if force_flywalk or V.dist2(this.pos.x, this.pos.y, r.pos.x, r.pos.y) > tw.min_distance * tw.min_distance then
					r.new = false

					U.unblock_target(store, this)
					U.bans_add(this.vis, F_ALL)

					this.health.immune_to = F_ALL

					local original_speed = this.motion.max_speed

					U.speed_inc_self(this, tw.extra_speed)

					this.unit.marker_hidden = true
					this.health_bar.hidden = true

					S:queue(this.sound_events.change_rally_point)
					S:queue(this.flywalk.sound)

					local an, af = U.animation_name_facing_point(this, tw.animations[1], r.pos)

					U.animation_start_default(this, an, af, store.tick_ts)

					local ps

					::label_337_0::

					local dest = r.pos
					local n = this.nav_grid

					if ps ~= nil then
						ps.particle_system.emit = false

						simulation:queue_remove_entity(ps)

						ps = nil
					end

					while not V.veq(this.pos, dest) do
						local w = table.remove(n.waypoints, 1) or dest

						U.set_destination(this, w)

						local runs = this.render.sprites[1].runs

						while not this.motion.arrived do
							if r.new then
								r.new = false

								goto label_337_0
							end

							if w.x < this.pos.x then
								this.render.sprites[1].flip_x = true
							else
								this.render.sprites[1].flip_x = false
							end

							if ps ~= nil then
								local offset_index = this.pos.x > w.x and 1 or 2

								ps.particle_system.emit_offset = ps.particle_system.emit_offsets[offset_index]
							end

							U.walk_off__accel__unsnapped(this, store.tick_length)
							coroutine.yield()

							this.motion.speed.x, this.motion.speed.y = 0, 0

							if this.render.sprites[1].runs ~= runs then
								local an, af = U.animation_name_facing_point(this, tw.animations[2], w)

								U.animation_start(this, an, af, store.tick_ts, true, 1, true)

								runs = this.render.sprites[1].runs

								if ps == nil then
									ps = E:create_entity(this.flywalk.trail)
									ps.particle_system.emit = true
									ps.particle_system.track_id = this.id

									local offset_index = this.pos.x > r.pos.x and 1 or 2

									ps.particle_system.emit_offset = ps.particle_system.emit_offsets[offset_index]

									simulation:queue_insert_entity(ps)
								end
							end
						end
					end

					if ps ~= nil then
						ps.particle_system.emit = false

						simulation:queue_remove_entity(ps)
					end

					SU.hide_modifiers(store, this, true)
					U.y_animation_play(this, tw.animations[3], nil, store.tick_ts)
					SU.show_modifiers(store, this, true)
					U.update_max_speed(this, original_speed)
					U.bans_remove(this.vis, F_ALL)

					this.health.immune_to = 0
					this.unit.marker_hidden = nil
					this.health_bar.hidden = nil
				elseif SU.y_hero_new_rally(store, this) then
					goto label_337_1
				end
			end

			if SU.hero_level_up(store, this) then
				quit_shooting_state()
				U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)
			end

			if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
				local enemy = find_target_at_critical_moment(this, this.ranged.attacks[1].max_range, F_RANGED, F_NONE)

				if enemy and enemy.pos and U.has_valid_rally_node_nearby(enemy.pos) then
					shooting_state = false

					U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)
					S:queue(this.sound_events.change_rally_point)

					local ultimate_entity = E:create_entity(this.hero.skills.ultimate.controller_name)

					ultimate_entity.pos = V.vclone(enemy.pos)
					ultimate_entity.level = this.hero.skills.ultimate.level
					ultimate_entity.damage_factor = this.unit.damage_factor
					ultimate_entity.owner_id = this.id

					simulation:queue_insert_entity(ultimate_entity)

					this.ultimate.ts = store.tick_ts
					melee_hits = melee_hits + 1

					SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
				else
					this.ultimate.ts = this.ultimate.ts + 1
				end
			end

			skill = this.hero.skills.heal_strike
			a = heal_strike_attack

			if not heal_strike_ready or this.soldier.target_id == nil then
			-- block empty
			elseif not this.motion.arrived then
			-- block empty
			else
				local target = store.entities[this.soldier.target_id]

				if not target then
				-- block empty
				elseif target.health.dead then
				-- block empty
				else
					last_ts = store.tick_ts

					local an, af = U.animation_name_facing_point(this, a.animation, target.pos)

					shooting_state = false

					U.animation_start_default(this, an, af, store.tick_ts, false)
					U.y_wait_unconditional(store, fts(18))
					S:queue(a.sound)
					U.y_wait_unconditional(store, fts(7))

					local fx = E:create_entity(a.hit_fx)

					fx.render.sprites[1].pos = V.vclone(this.pos)
					fx.render.sprites[1].offset = V.v(a.hit_offset.x, a.hit_offset.y)
					fx.render.sprites[1].ts = store.tick_ts

					simulation:queue_insert_entity(fx)
					queue_damage(store, SU.create_attack_damage(a, target.id, this))
					U.heal(this, target.health.hp_max * a.heal_factor)

					if this.health.hp > 0 and this.health.dead then
						this.health.dead = false
					end

					heal_strike_ready = false
					melee_hits = 0
					a.ts = last_ts

					SU.hero_gain_xp_from_skill(this, skill)
					U.y_animation_wait_default(this)

					goto label_337_1
				end
			end

			skill = this.hero.skills.ricochet
			a = ricochet_attack

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local enemy, enemies = U.find_foremost_enemy_between_range_filter_off(tpos(this), a.min_range, a.max_range_trigger, a.node_prediction, a.vis_flags, a.vis_bans)

				if not enemy then
					a.ts = a.ts + fts(10)
				elseif enemy and #enemies >= ricochet_attack.min_targets then
					shooting_state = false

					local start_ts = store.tick_ts
					local an, af = U.animation_name_facing_point(this, "mist_run_in", enemy.pos, 1)

					U.animation_start_default(this, an, af, store.tick_ts, false)
					S:queue(a.sound)
					U.y_animation_play(this, "mist_run_in", nil, store.tick_ts, 1)

					local attack_done, bullet = shoot_ricochet_arrow(store, this, enemy, a, V.vclone(enemy.pos))

					U.animation_start_default(this, "mist_run_loop", nil, store.tick_ts, true)

					melee_hits = melee_hits + 1

					if attack_done then
						while not bullet.end_bounces do
							coroutine.yield()
						end
					end

					U.y_animation_play(this, "mist_run_end", nil, store.tick_ts, 1)

					ricochet_attack.ts = start_ts
					last_ts = start_ts

					if shooting_state then
						ranged_attack.ts = store.tick_ts
					end

					goto label_337_1
				end
			end

			skill = this.hero.skills.shoot_around
			a = shoot_around_attack

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local enemies = U.find_enemies_in_range_filter_off(this.pos, a.max_range, a.vis_flags, a.vis_bans)

				if not enemies or #enemies < a.min_targets then
					a.ts = a.ts + fts(10)
				else
					local start_ts = store.tick_ts

					shooting_state = false

					U.animation_start_default(this, a.animations[1], nil, store.tick_ts, false)

					if SU.y_hero_animation_wait(this) then
					-- block empty
					else
						S:queue(a.sound)

						this.health.immune_to = F_ALL
						a.ts = start_ts
						melee_hits = melee_hits + 1
						last_ts = start_ts

						SU.hero_gain_xp_from_skill(this, skill)

						local aura = E:create_entity(a.aura)

						aura.aura.source_id = this.id
						aura.aura.ts = store.tick_ts
						aura.pos = this.pos
						aura.aura.damage_factor = this.unit.damage_factor

						simulation:queue_insert_entity(aura)
						U.animation_start_default(this, a.animations[2], nil, store.tick_ts, true)

						if SU.y_soldier_wait(store, this, aura.aura.duration - (store.tick_ts - a.ts)) then
							S:stop(a.sound)
							S:queue(a.sound_interrupt)

							a.ts = a.ts - (1 - (store.tick_ts - a.ts) / aura.aura.duration) * a.cooldown
						end

						S:stop(a.sound)
						S:queue(a.sound_interrupt)
						simulation:queue_remove_entity(aura)
						U.y_animation_play(this, a.animations[3], nil, store.tick_ts, 1)

						this.health.immune_to = F_NONE
						last_ts = start_ts

						goto label_337_1
					end
				end
			end

			skill = this.hero.skills.beasts
			a = beasts_attack

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local enemies = U.find_enemies_in_range_filter_off(this.pos, a.max_range, a.vis_flags, a.vis_bans)

				if not enemies or #enemies < 1 then
					a.ts = a.ts + fts(10)
				else
					local start_ts = store.tick_ts

					shooting_state = false

					S:queue(a.sound)
					U.animation_start_default(this, a.animation, nil, store.tick_ts, false)

					a.ts = start_ts
					last_ts = start_ts
					melee_hits = melee_hits + 1

					SU.hero_gain_xp_from_skill(this, skill)

					for i = 1, 2 do
						local offset_x = i == 1 and a.spawn_offset_x or a.spawn_offset_x * -1
						local offset_y = a.spawn_offset_y + math.random(1, 4) - 2
						local beast = E:create_entity(a.entity)

						beast.owner = this
						beast.pos = V.vclone(this.pos)
						beast.pos.x = beast.pos.x + offset_x
						beast.pos.y = beast.pos.y - offset_y
						beast.owner_offset = V.v(offset_x, offset_y)

						simulation:queue_insert_entity(beast)
						U.y_wait_unconditional(store, fts(2))
					end

					SU.y_hero_animation_wait(this)

					last_ts = start_ts

					goto label_337_1
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if not heal_strike_attack.disabled and sta == A_DONE and this.melee.last_attack.attack == melee_attack then
				melee_hits = melee_hits + 1

				if melee_hits >= heal_strike_attack.hits_to_trigger then
					heal_strike_ready = true
				end
			end

			if brk or sta ~= A_NO_TARGET then
				-- block empty
				shooting_state = false
			elseif SU.soldier_go_back_step(store, this) then
				-- block empty
				shooting_state = false
			else
				brk, sta = y_hero_ranged_attack_hero_hunter(store, this)

				if brk then
				-- block empty
				else
					if sta == A_DONE then
						last_attack_ranged = true
					end

					if last_attack_ranged then
						if store.tick_ts - ranged_attack.ts > 1.5 then
							last_attack_ranged = false

							quit_shooting_state()
						end
					else
						SU.soldier_idle(store, this)
					end

					SU.soldier_regen(store, this)
				end
			end
		end

		::label_337_1::

		coroutine.yield()
	end
end

local function mod_hero_hunter_ricochet_attack_update(this, store)
	local m = this.modifier
	local already_hit = false

	this.modifier.ts = store.tick_ts

	local target = store.entities[m.target_id]

	if not target or not target.pos then
		simulation:queue_remove_entity(this)

		return
	end

	this.pos = target.pos

	local anim_index = km.zmod(this.bounce_count + 1, #this.animations)

	this.render.sprites[1].name = this.animations[anim_index]
	this.render.sprites[1].ts = store.tick_ts

	while true do
		if not already_hit and store.tick_ts - m.ts >= this.hit_delay then
			local d = E.assign_damage(this.damage_type, math.random(this.damage_min, this.damage_max) * this.modifier.damage_factor, this.id, target.id)

			queue_damage(store, d)

			already_hit = true
		end

		target = store.entities[m.target_id]

		if not target or target.health.dead or m.duration >= 0 and store.tick_ts - m.ts > m.duration or m.last_node and target.nav_path.ni > m.last_node then
			simulation:queue_remove_entity(this)

			return
		end

		if target.unit then
			local s = this.render.sprites[1]
			local flip_sign = 1

			if target.render then
				flip_sign = target.render.sprites[1].flip_x and -1 or 1
			end

			if this.back_attack then
				flip_sign = -flip_sign
			end

			if target.unit.mod_offset then
				s.offset.x, s.offset.y = target.unit.mod_offset.x * flip_sign, target.unit.mod_offset.y

				if flip_sign == -1 then
					s.offset.x = s.offset.x - this.enemy_distance
				else
					s.offset.x = s.offset.x + this.enemy_distance
				end
			end

			s.flip_x = flip_sign == 1
		end

		coroutine.yield()
	end
end

tt = RT("soldier_hero_hunter_beast", "decal_scripted")

AC(tt, "attacks", "force_motion", "tween", "sound_events")

tt.flight_height = 50
tt.force_motion.max_a = 6000
tt.force_motion.max_v = 6000
tt.force_motion.ramp_radius = 30
tt.force_motion.a_step = 30
tt.main_script.update = soldier_hero_hunter_beast_update
tt.max_distance_from_owner = 250
tt.min_distance_to_attack = 50
tt.attacks.list[1] = CC("custom_attack")
tt.attacks.list[1].cooldown = 0.5
tt.attacks.list[1].shoot_time = fts(15)
tt.attacks.list[1].damage_type = DAMAGE_PHYSICAL
tt.attacks.list[1].vis_flags = F_RANGED
tt.attacks.list[1].range = 150
tt.render.sprites[1].prefix = "duskbeast"
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.tween.disabled = true
tt.tween.remove = false
tt.steal_fx = "fx_hero_hunter_steal"
tt.chance_to_steal = 0.25
tt.fx_offset_y = 60
tt.tween.props[1].name = "offset"
tt.tween.props[1].interp = "sine"
tt.tween.props[1].keys = {{0, vec_2(0, tt.flight_height)}, {nil, vec_2(0, tt.flight_height - 5)}, {nil, vec_2(0, tt.flight_height)}}
tt.tween.props[1].loop = true
tt.idle_change_pos_cd = fts(8)
tt.idle_change_pos_offset = vec_2(35, 35)
tt = RT("soldier_hero_hunter_ultimate", "soldier_militia")

AC(tt, "nav_grid", "ranged", "reinforcement", "tween")

tt.controable = true
tt.controable_other = true
tt.health_bar.offset = vec_2(0, 50)
tt.info.enc_icon = 12
tt.info.portrait = "kr5_info_portraits_soldiers_0013"
tt.info.random_name_format = nil
tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
tt.render.sprites[1].prefix = "dante"
tt.render.sprites[1].name = "Idle"
tt.render.sprites[1].draw_order = DO_SOLDIER_BIG
tt.render.sprites[1].angles.ranged = {"shoot", "shoot_diagonal_back", "shoot_diagonal"}
tt.render.sprites[1].angles_custom = {
	ranged = {45, 135, 210, 315}
}
tt.render.sprites[1].angles_flip_vertical = {
	ranged = true
}
tt.render.sprites[1].scale = vec_1(0.52 * 1080 / 768)
tt.unit.hit_offset = vec_2(0, 16)
tt.unit.size = UNIT_SIZE_LARGE
tt.unit.fade_time_after_death = tt.health.dead_lifetime
tt.soldier.melee_slot_offset = vec_2(20, 0)
tt.health_bar.hidden = true
tt.health.immune_to = F_ALL
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = soldier_hero_hunter_ultimate_update
tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE, F_BLOCK, F_RANGED, F_MOD)
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
tt.tween.props[1].name = "alpha"
tt.tween.remove = false
tt.tween.disabled = true
tt.melee = nil
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].cooldown = 1
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].bullet = "bullet_hero_hunter_ultimate_ranged_attack"
tt.ranged.attacks[1].sound = "HeroHunterUltimateAttack"
tt.ranged.attacks[1].shoot_times = {fts(2), fts(9), fts(16)}
tt.ranged.attacks[1].loops = 1
tt.ranged.attacks[1].animations = {nil, "ranged"}
tt.ranged.attacks[1].damage_type = DAMAGE_TRUE
tt.reinforcement.duration = 12
tt.reinforcement.fade = nil
tt.ui.click_rect = r(-20, -5, 40, 50)
tt.distance_to_revive = 150
tt = RT("hero_hunter", "hero")

AC(tt, "melee", "ranged", "timed_attacks")

tt.hero.level_stats.armor = {0.12, 0.14, 0.16, 0.18, 0.2, 0.22, 0.24, 0.26, 0.28, 0.3}
tt.hero.level_stats.hp_max = {195, 213, 234, 252, 273, 291, 312, 330, 351, 364}
tt.hero.level_stats.melee_damage_min = {4, 5, 6, 7, 8, 9, 10, 11, 12, 13}
tt.hero.level_stats.melee_damage_max = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16}
tt.hero.level_stats.ranged_damage_max = {24, 29, 35, 40, 45, 50, 56, 61, 66, 70}
tt.hero.level_stats.ranged_damage_min = {16, 20, 23, 27, 30, 34, 37, 41, 44, 48}
tt.hero.skills.heal_strike = CC("hero_skill")
tt.hero.skills.heal_strike.damage_min = {28, 40, 52}
tt.hero.skills.heal_strike.damage_max = {40, 52, 64}
tt.hero.skills.heal_strike.heal_factor = {0.08, 0.12, 0.16}
tt.hero.skills.heal_strike.xp_gain = {40, 80, 100}
tt.hero.skills.heal_strike.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.ricochet = CC("hero_skill")
tt.hero.skills.ricochet.cooldown = {15, 15, 15}
tt.hero.skills.ricochet.damage_min = {27, 52, 72}
tt.hero.skills.ricochet.damage_max = {43, 77, 105}
tt.hero.skills.ricochet.bounces = {2, 3, 4}
tt.hero.skills.ricochet.xp_gain = {120, 240, 360}
tt.hero.skills.ricochet.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.shoot_around = CC("hero_skill")
tt.hero.skills.shoot_around.cooldown = {20, 20, 20}
tt.hero.skills.shoot_around.damage_min = {3, 4, 5}
tt.hero.skills.shoot_around.damage_max = {6, 7, 8}
tt.hero.skills.shoot_around.duration = {3, 3.5, 4}
tt.hero.skills.shoot_around.xp_gain = {160, 320, 480}
tt.hero.skills.shoot_around.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.beasts = CC("hero_skill")
tt.hero.skills.beasts.cooldown = {18, 18, 18}
tt.hero.skills.beasts.damage_min = {6, 12, 18}
tt.hero.skills.beasts.damage_max = {10, 20, 30}
tt.hero.skills.beasts.gold_to_steal = {1, 2, 3}
tt.hero.skills.beasts.duration = {8, 10, 12}
tt.hero.skills.beasts.xp_gain = {144, 288, 432}
tt.hero.skills.beasts.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.controller_name = "controller_hero_hunter_ultimate"
tt.hero.skills.ultimate.cooldown = {50, 50, 50, 50}
tt.hero.skills.ultimate.damage_min = {7, 14, 19, 28}
tt.hero.skills.ultimate.damage_max = {11, 19, 30, 42}
tt.hero.skills.ultimate.damage_factor = {2, 2.5, 3, 3.5}
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.ultimate.xp_gain_factor = 50
tt.hero.fn_level_up = hero_hunter_level_up
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, 40)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.hero_portrait = "kr5_hero_portraits_0006"
tt.info.portrait = "kr5_info_portraits_heroes_0006"
tt.main_script.update = hero_hunter_update
tt.motion.max_speed = 75
tt.regen.cooldown = 1
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"run"}
tt.render.sprites[1].angles.shot = {"shoot_diagonal", "shoot_side", "shoot_diagonal_up", "shoot_up", "shoot_down"}
tt.render.sprites[1].angles.aim = {"aim_diagonal", "aim_side", "aim_diagonal_up", "aim_up", "aim_down"}
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "anya"
tt.render.sprites[1].draw_order = DO_HEROES
tt.soldier.melee_slot_offset = vec_2(20, 0)
tt.sound_events.change_rally_point = "HeroHunterTaunt"
tt.sound_events.death = "HeroHunterDeath"
tt.sound_events.respawn = "HeroHunterTauntIntro"
tt.sound_events.hero_room_select = "HeroHunterTauntSelect"
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.mod_offset = vec_2(0, 14)
tt.melee.range = 72
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].animations = {nil, "melee_loop"}
tt.melee.attacks[1].cooldown = 0.8
tt.melee.attacks[1].shared_cooldown = 0.8
tt.melee.attacks[1].hit_times = {fts(7), fts(15)}
tt.melee.attacks[1].loops = 1
tt.melee.attacks[1].hit_offset = vec_2(45, 15)
tt.melee.attacks[1].xp_gain_factor = 1.45
tt.melee.attacks[1].basic_attack = true
tt.melee.attacks[1].sound = "MeleeSword"
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animation = "shot"
tt.ranged.attacks[1].animation_aim = "aim"
tt.ranged.attacks[1].animation_prepare = "aim_start"
tt.ranged.attacks[1].bullet = "bullet_hero_hunter_ranged_attack"
tt.ranged.attacks[1].cooldown = 1
tt.ranged.attacks[1].max_range = 250
tt.ranged.attacks[1].min_range = 72
tt.ranged.attacks[1].shoot_time = fts(4)
tt.ranged.attacks[1].shared_cooldown = true
tt.ranged.attacks[1].basic_attack = true
tt.ranged.attacks[1].sound = "HeroHunterBasicAttack"
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].animation = "skill1"
tt.timed_attacks.list[1].shoot_time = fts(4)
tt.timed_attacks.list[1].damage_type = DAMAGE_TRUE
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].hits_to_trigger = 6
tt.timed_attacks.list[1].hit_fx = "fx_hero_hunter_skill_heal_strike_hit"
tt.timed_attacks.list[1].hit_offset = vec_2(45, 15)
tt.timed_attacks.list[1].sound = "HeroHunterHealStrikeCast"
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].animation = "idle"
tt.timed_attacks.list[2].bullet = "arrow_hero_hunter_ricochet"
tt.timed_attacks.list[2].cooldown = tt.hero.skills.ricochet.cooldown[1]
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].xp_from_skill = "ricochet"
tt.timed_attacks.list[2].shoot_time = fts(0)
tt.timed_attacks.list[2].min_targets = 2
tt.timed_attacks.list[2].max_range_trigger = 200
tt.timed_attacks.list[2].min_range = 0
tt.timed_attacks.list[2].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[2].node_prediction = fts(10)
-- tt.timed_attacks.list[2].min_cooldown = 5
tt.timed_attacks.list[2].entity_waiting = "decal_hero_hunter_skill_ricochet_entity"
tt.timed_attacks.list[2].sound = "HeroHunterRicochetCast"
tt.timed_attacks.list[3] = CC("custom_attack")
tt.timed_attacks.list[3].animations = {"argent_storm_in", "argent_storm_loop", "argent_storm_out"}
tt.timed_attacks.list[3].cooldown = tt.hero.skills.shoot_around.cooldown[1]
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].cast_time = fts(15)
tt.timed_attacks.list[3].max_range = 78
tt.timed_attacks.list[3].min_targets = 3
tt.timed_attacks.list[3].aura = "aura_hero_hunter_shoot_around"
tt.timed_attacks.list[3].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[3].fx = "fx_hero_builder_demolition_man"
tt.timed_attacks.list[3].min_fight_cooldown = 2
tt.timed_attacks.list[3].sound = "HeroHunterShootAroundCast"
tt.timed_attacks.list[3].sound_interrupt = "HeroHunterShootAroundInterrupt"
tt.timed_attacks.list[4] = CC("custom_attack")
tt.timed_attacks.list[4].animation = "dusk_beasts"
tt.timed_attacks.list[4].cooldown = tt.hero.skills.beasts.cooldown[1]
tt.timed_attacks.list[4].disabled = true
tt.timed_attacks.list[4].cast_time = fts(15)
tt.timed_attacks.list[4].max_range = 78
tt.timed_attacks.list[4].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[4].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[4].entity = "soldier_hero_hunter_beast"
tt.timed_attacks.list[4].spawn_offset_y = 0
tt.timed_attacks.list[4].spawn_offset_x = 30
tt.timed_attacks.list[4].sound = "HeroHunterBeastsCast"
tt.ui.click_rect = r(-20, -5, 40, 40)
tt.vis.bans = bor(F_POLYMORPH, F_DISINTEGRATED, F_CANNIBALIZE, F_SKELETON, F_BLOOD, F_POISON)
tt.flywalk = {}
tt.flywalk.min_distance = 90
tt.flywalk.extra_speed = 95
tt.flywalk.animations = {"mist_run_in", "mist_run_loop", "mist_run_end"}
tt.flywalk.sound = "HeroHunterRicochetCast"
tt.flywalk.trail = "ps_hero_hunter_walk_trail"
tt.ultimate = {
	ts = 0,
	death_trigger_ts = 0,
	cooldown = nil,
	cooldown_death_trigger = nil,
	disabled = true
}
tt = RT("bullet_hero_hunter_ranged_attack", "bullet")
tt.bullet.hit_fx = "fx_hero_hunter_skill_heal_strike_hit"
tt.bullet.flight_time = fts(2)
tt.bullet.damage_type = DAMAGE_SHOT
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.level = 1
tt.bullet.xp_gain_factor = 1.8
tt.render = nil
tt.main_script.update = bullet_hero_hunter_ranged_attack_update
tt = RT("arrow_hero_hunter_ricochet", "bullet")
tt.main_script.update = arrow_hero_hunter_ricochet_update
tt.bullet.damage_type = DAMAGE_RUDE
tt.bullet.damage_min = nil
tt.bullet.damage_max = nil
tt.bullet.hit_time = fts(2)
tt.render = nil
tt.bounce_range = 120
tt.track_target = true
tt.ray_duration = fts(3)
tt.time_between_bounces = fts(2)
tt.bullet.mods = {"mod_hero_hunter_ricochet_attack", "mod_hero_hunter_ricochet_stun"}
tt.trail_arrow = "arrow_hero_hunter_ricochet_trail"
tt.sound_bounce = "HeroHunterRicochetBounce"
tt.back_radius = 60
tt = RT("arrow_hero_hunter_ricochet_trail", "bullet")
tt.main_script.update = arrow_hero_hunter_ricochet_trail_update
tt.image_width = 137
tt.render.sprites[1].name = "mistystep_trailbetweenclones_run"
tt.render.sprites[1].loop = false
tt.track_target = true
tt.ray_duration = fts(12)
tt = RT("bullet_hero_hunter_ultimate_ranged_attack", "bullet")
tt.bullet.hit_fx = "fx_hero_hunter_ultimate_hit"
tt.bullet.flight_time = fts(2)
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.damage_max_config = {11, 19, 30, 42}
tt.bullet.damage_min_config = {7, 14, 19, 28}
tt.bullet.level = 1
tt.render = nil
tt.main_script.update = bullet_hero_hunter_ranged_attack_update
tt = RT("aura_hero_hunter_shoot_around", "aura")
tt.aura.duration = nil
tt.aura.damage_type = DAMAGE_TRUE
tt.aura.track_source = true
tt.aura.cycle_time = fts(3)
tt.aura.radius = 80
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.aura.vis_flags = F_RANGED
tt.main_script.update = aura_hero_hunter_shoot_around_update
tt.aura.mods = {"mod_hero_hunter_skill_shoot_around_hit_fx", "mod_hero_hunter_shoot_around_slow"}
tt.fx = "fx_hero_hunter_skill_shoot_around_decal"
tt.fx_every = fts(15)
tt.fx_amount = 3
tt = RT("mod_hero_hunter_shoot_around_slow", "mod_slow")
tt.slow.factor = 0.7
tt.modifier.duration = 2
tt = RT("aura_hero_hunter_ultimate", "aura")

AC(tt, "render")

tt.aura.mod = "mod_hero_hunter_ultimate_slow"
tt.aura.radius = 80
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.aura.vis_flags = F_RANGED
tt.aura.cycle_time = fts(5)
tt.aura.duration = 12
tt.aura.track_source = true
tt.aura.use_mod_offset = false
tt.render.sprites[1].name = "dante_decal_Idle"
tt.render.sprites[1].z = Z_DECALS
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt = RT("mod_hero_hunter_skill_shoot_around_hit_fx", "modifier")

AC(tt, "render")

tt.render.sprites[1].name = "shothit_run"
tt.main_script.insert = scripts.mod_track_target.insert
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.duration = fts(10)
tt = RT("mod_hero_hunter_ricochet_attack", "modifier")

AC(tt, "render", "tween")

tt.render.sprites[1].name = "mistystep_clone1_run"
tt.render.sprites[1].anchor = vec_2(0.5, 0.28)
tt.main_script.insert = scripts.mod_track_target.insert
tt.main_script.update = mod_hero_hunter_ricochet_attack_update
tt.modifier.duration = fts(8)
tt.animations = {"mistystep_clone1_run", "mistystep_clone2_run", "mistystep_clone3_run"}
tt.enemy_distance = 30
tt.hit_delay = fts(3)
tt.damage_type = DAMAGE_RUDE
tt.tween.props[1].keys = {{0, 255}, {tt.modifier.duration - fts(4), 255}, {tt.modifier.duration, 0}}
tt.back_attack = false
tt = RT("mod_hero_hunter_ricochet_stun", "mod_stun")
tt.modifier.duration = fts(9)
tt = RT("mod_hero_hunter_ultimate_slow", "mod_slow")
tt.slow.factor = 0.75
tt = RT("controller_hero_hunter_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.entity = "soldier_hero_hunter_ultimate"
tt.aura = "aura_hero_hunter_ultimate"
tt.main_script.update = hero_hunter_ultimate_update
tt.sound = "HeroHunterUltimateCast"
tt = RT("ps_hero_hunter_walk_trail")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "mist_run_trail_run"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 15
tt.particle_system.emit_rotation_spread = d2r(45)
tt.particle_system.emit_area_spread = vec_2(2, 2)
tt.particle_system.emit_speed = {5, 25}
tt.particle_system.emit_offsets = {vec_2(13, 12), vec_2(-13, 12)}
tt.particle_system.z = Z_OBJECTS
tt.particle_system.particle_lifetime = {fts(14), fts(14)}
tt.emit_direction = d2r(90)
tt = RT("fx_hero_hunter_skill_heal_strike_hit", "fx")
tt.render.sprites[1].name = "mistystep_hit_run"
tt = RT("fx_hero_hunter_skill_shoot_around_decal", "fx")
tt.render.sprites[1].name = "argent_storm_decal_run"
tt = RT("fx_hero_hunter_ultimate_hit", "fx")
tt.render.sprites[1].name = "hit_dante_run"
tt = RT("fx_hero_hunter_steal", "fx")
tt.render.sprites[1].name = "duskbeast_coin_run"
tt.render.sprites[1].z = Z_OBJECTS_COVERS
