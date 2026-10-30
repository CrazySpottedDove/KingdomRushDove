local bit = require("bit")
local E = require("entity_db")
local GR = require("grid_db")
local scripts = require("scripts")
local km = require("lib.klua.macros")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")

require("all.constants")

local band = bit.band
local bor = bit.bor
local fts = U.fts
local queue_damage = U.queue_damage
local ready_to_use_skill = HU.ready_to_use_skill
local upgrade_skill = HU.upgrade_skill

local function shuffle(t)
	for i = #t, 2, -1 do
		local j = math.random(i)

		t[i], t[j] = t[j], t[i]
	end
end

local function set_hero_height(this, height)
	this._current_height = height
	this.drag_line_origin_offset.y = height
	this.render.sprites[1].offset.y = height
	U.change_health_bar_offset_run_time(this.health_bar, height + 80)
	this.ui.click_rect.pos.y = height - 20
	this.unit.hit_offset.y = height + 10
	this.unit.mod_offset.y = height + 10
end

local function aura_drakkan_skill_a_update(this, store)
	local next_ts = store.tick_ts
	local end_ts = store.tick_ts + this.aura.duration

	while store.tick_ts < end_ts do
		if store.tick_ts >= next_ts then
			next_ts = next_ts + this.aura.cycle_time

			local source = store.entities[this.aura.source_id]
			local buff = source and source.unit.damage_buff or 0
			local factor = source and source.unit.damage_factor or 1
			local targets = U.find_enemies_in_range(store, this.pos, 0, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans)

			if targets then
				for _, target in ipairs(targets) do
					local d = E.assign_damage(this.aura.damage_type, (math.random(this.aura.damage_min, this.aura.damage_max) + buff) * factor, this.aura.source_id, target.id)

					queue_damage(store, d)

					local mod = E:create_entity(this.aura.mod)

					mod.modifier.target_id = target.id
					mod.modifier.source_id = this.aura.source_id
					mod.modifier.duration = this.aura.silence_duration
					mod.modifier.damage_factor = factor

					simulation:queue_insert_entity(mod)
				end
			end
		end

		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

local function aura_drakkan_skill_b_update(this, store)
	local source = store.entities[this.aura.source_id]
	local buff = source and source.unit.damage_buff or 0
	local factor = source and source.unit.damage_factor or 1
	local targets = U.find_enemies_in_range(store, this.pos, 0, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans)

	if targets then
		for _, target in ipairs(targets) do
			local d = E.assign_damage(this.aura.damage_type, (math.random(this.aura.damage_min, this.aura.damage_max) + buff) * factor, this.aura.source_id, target.id)

			queue_damage(store, d)

			local fx = E:create_entity(this.aura.hit_fx)

			fx.pos = V.vclone(target.pos)
			fx.pos.x, fx.pos.y = fx.pos.x + target.unit.hit_offset.x, fx.pos.y + target.unit.hit_offset.y
			fx.render.sprites[1].ts = store.tick_ts

			if fx.render.sprites[1].size_names then
				fx.render.sprites[1].name = fx.render.sprites[1].size_names[target.unit.size]
			end

			simulation:queue_insert_entity(fx)
		end
	end

	simulation:queue_remove_entity(this)
end

local function bullet_drakkan_ultimate_update(this, store)
	local b = this.bullet
	local dist_y = math.abs(b.from.y - b.to.y)
	local mspeed = dist_y / b.travel_time - b.acceleration * b.travel_time * 0.5
	local particle = E:create_entity(b.particles_name)

	particle.particle_system.track_id = this.id

	simulation:queue_insert_entity(particle)

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
		mspeed = mspeed + 1 / FPS * b.acceleration
		mspeed = km.clamp(b.min_speed, b.max_speed, mspeed)
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
		this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

		coroutine.yield()
	end

	this.pos.x, this.pos.y = b.to.x, b.to.y
	particle.particle_system.source_lifetime = 0

	local source = store.entities[b.source_id]
	local buff = source and source.unit.damage_buff or 0
	local factor = source and source.unit.damage_factor or 1
	local damage_value = math.ceil((math.random(b.damage_min, b.damage_max) + buff) * factor)
	local enemies = U.find_enemies_in_range(store, b.to, 0, b.damage_radius, b.damage_flags or F_AREA, b.damage_bans or 0)

	if enemies then
		for _, enemy in ipairs(enemies) do
			local d = E.assign_damage(b.damage_type, damage_value, this.id, enemy.id)

			queue_damage(store, d)
		end
	end

	S:queue(this.sound_events.remove)

	local cell_type = GR:cell_type(b.to.x, b.to.y)

	if band(cell_type, TERRAIN_WATER) ~= 0 then
		local fx = E:create_entity("fx_explosion_water")

		fx.pos.x, fx.pos.y = b.to.x, b.to.y
		fx.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(fx)
	else
		if b.hit_decal then
			local decal = E:create_entity(b.hit_decal)

			decal.pos.x, decal.pos.y = b.to.x, b.to.y
			decal.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(decal)
		end

		if b.hit_fx then
			local fx = E:create_entity(b.hit_fx)

			fx.pos.x, fx.pos.y = b.to.x, b.to.y
			fx.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(fx)
		end
	end

	simulation:queue_remove_entity(this)
end

local function hero_drakkan_get_info(this)
	local hl = this.hero.level
	local ls = this.hero.level_stats
	local min = (ls.ranged_damage_min[hl] + this.unit.damage_buff) * this.unit.damage_factor
	local max = (ls.ranged_damage_max[hl] + this.unit.damage_buff) * this.unit.damage_factor

	return {
		type = STATS_TYPE_SOLDIER,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		damage_type = DAMAGE_MAGICAL,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor,
		range = this.ranged.attacks[1].max_range,
		cooldown = this.ranged.attacks[1].cooldown * this.unit.cooldown_factor
	}
end

local function soldier_drakkan_clone_get_info(this)
	local b = E:get_template(this.ranged.attacks[1].bullet)
	local min = (b.bullet.damage_min + this.unit.damage_buff) * this.unit.damage_factor
	local max = (b.bullet.damage_max + this.unit.damage_buff) * this.unit.damage_factor

	return {
		type = STATS_TYPE_SOLDIER,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		damage_type = b.bullet.damage_type,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor
	}
end

local function hero_drakkan_level_up(this, store)
	if this.hero.level > 1 then
		S:queue(this.sound_events.level_up)
	end

	HU.level_up_basic(this)

	local talent_2 = this.hero.skills.talent_2
	local cooldown_factor = 1 - (talent_2.level > 0 and talent_2.skills_cd_red or 0)

	upgrade_skill(this, "skill_a", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.ts = store.tick_ts
		a.cooldown = s.cooldown * cooldown_factor
	end)
	upgrade_skill(this, "skill_b", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.ts = store.tick_ts
		a.cooldown = s.cooldown * cooldown_factor
	end)
	upgrade_skill(this, "skill_c", function(this, s)
		local a = this.timed_attacks.list[3]

		a.disabled = nil
		a.ts = store.tick_ts
		a.cooldown = s.cooldown * cooldown_factor
		a.duration = s.duration[s.level]
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		local a = this.timed_attacks.list[4]

		a.disabled = nil
		a.ts = store.tick_ts
		a.cooldown = s.cooldown * cooldown_factor
	end)
	upgrade_skill(this, "talent_1", function(this, s)
		this.teleport.disabled = false
	end)
	upgrade_skill(this, "talent_2", function(this, s)
		this.timed_attacks.list[1].cooldown = this.timed_attacks.list[1].cooldown * cooldown_factor
		this.timed_attacks.list[2].cooldown = this.timed_attacks.list[2].cooldown * cooldown_factor
		this.timed_attacks.list[3].cooldown = this.timed_attacks.list[3].cooldown * cooldown_factor
		this.timed_attacks.list[4].cooldown = this.timed_attacks.list[4].cooldown * cooldown_factor
	end)

	HU.update_hp(this)
end

local function hero_drakkan_insert(this, store)
	this.hero.fn_level_up(this, store)

	this.ranged.order = U.attack_order(this.ranged.attacks)

	return true
end

local function hero_drakkan_death_and_respawn(store, this)
	local h = this.health
	local death_ts = store.tick_ts

	this.ui.can_click = false

	U.unblock_target(store, this)
	S:queue(this.sound_events.death)
	U.y_animation_play(this, this.unit.death_animation, nil, store.tick_ts, 1)

	for _, s in ipairs(this.render.sprites) do
		s.hidden = true
	end

	local tombstone = E:create_entity(this.hero.tombstone_decal)
	local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, {1, 2, 3}, true)

	if nodes and nodes[1] then
		local pi, spi, ni = unpack(nodes[1])

		tombstone.pos = P:node_pos(pi, spi, ni)
	else
		tombstone.pos = V.vclone(this.pos)
	end

	simulation:queue_insert_entity(tombstone)

	while h.dead_lifetime > store.tick_ts - death_ts and not this.force_respawn do
		coroutine.yield()
	end

	this.pos.x, this.pos.y = tombstone.pos.x, tombstone.pos.y
	this.nav_rally.pos.x, this.nav_rally.pos.y = this.pos.x, this.pos.y
	this.nav_rally.center.x, this.nav_rally.center.y = this.pos.x, this.pos.y
	this.nav_rally.new = false

	simulation:queue_remove_entity(tombstone)

	for _, s in ipairs(this.render.sprites) do
		s.hidden = false
	end

	this.render.sprites[1].z = Z_FLYING_HEROES
	set_hero_height(this, this.flight_height)

	h.ignore_damage = true

	S:queue(this.sound_events.respawn)
	U.y_animation_play(this, this.hero.respawn_animation, nil, store.tick_ts, 1)

	this.health_bar.hidden = false
	this.ui.can_click = true
	h.dead = false
	h.hp = h.hp_max
	h.ignore_damage = false
	this.force_respawn = false
end

local function hero_drakkan_basic_attack(this, store, attack)
	local hl = this.hero and this.hero.level or 1
	local ls = this.hero and this.hero.level_stats
	local pos_offset = V.v(this.pos.x + attack.ignore_offset.x, this.pos.y + attack.ignore_offset.y)
	local target = U.find_foremost_enemy(store, this.pos, attack.min_range, attack.max_range, attack.node_prediction, attack.vis_flags, attack.vis_bans, function(e)
		return V.dist2(pos_offset.x, pos_offset.y, e.pos.x, e.pos.y) > attack.radius * attack.radius
	end)

	if not target then
		return false
	end

	local start_ts = store.tick_ts
	local node_offset = P:predict_enemy_node_advance(target, attack.node_prediction)
	local target_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + node_offset)
	local an, af = U.animation_name_facing_point(this, attack.animation, target_pos)

	U.animation_start_default(this, an, af, store.tick_ts)

	while store.tick_ts - start_ts < attack.shoot_time do
		if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
			attack.ts = start_ts

			return true
		end

		coroutine.yield()
	end

	S:queue(attack.sound)

	local bullet = E:create_entity(attack.bullet)

	bullet.bullet.target_id = target.id
	bullet.bullet.source_id = this.id
	bullet.bullet.xp_dest_id = this.id
	bullet.pos = V.vclone(this.pos)

	local offset = V.v(0, 0)

	if attack.bullet_start_offset then
		offset = attack.bullet_start_offset[af and 2 or 1]
	end

	bullet.pos.x = bullet.pos.x + (af and -1 or 1) * offset.x
	bullet.pos.y = bullet.pos.y + offset.y
	bullet.bullet.from = V.vclone(bullet.pos)

	if bullet.bullet.ignore_hit_offset then
		bullet.bullet.to = V.v(target.pos.x, target.pos.y)
	else
		bullet.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
	end

	if this.is_clone then
		local bt = E:get_template(attack.bullet)

		bullet.bullet.damage_min = bt.bullet.damage_min + this.unit.damage_buff
		bullet.bullet.damage_max = bt.bullet.damage_max + this.unit.damage_buff
	else
		bullet.bullet.damage_min = ls.ranged_damage_min[hl] + this.unit.damage_buff
		bullet.bullet.damage_max = ls.ranged_damage_max[hl] + this.unit.damage_buff
	end

	bullet.bullet.damage_factor = this.unit.damage_factor

	simulation:queue_insert_entity(bullet)

	attack.ts = start_ts

	while not U.animation_finished_default(this) do
		if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
			break
		end

		coroutine.yield()
	end

	U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)

	return true
end

local function hero_drakkan_skill_a(this, store, attack, skill)
	local pos_offset = V.v(this.pos.x + attack.ignore_offset.x, this.pos.y + attack.ignore_offset.y)
	local target, targets = U.find_foremost_enemy(store, this.pos, attack.min_range, attack.max_range, nil, attack.vis_flags, attack.vis_bans, function(e)
		return GR:cell_is(e.pos.x, e.pos.y, bor(TERRAIN_LAND, TERRAIN_ICE)) and V.dist2(pos_offset.x, pos_offset.y, e.pos.x, e.pos.y) > attack.radius * attack.radius
	end)
	local magic_targets = 0

	if targets then
		for _, e in ipairs(targets) do
			if e.enemy and e.enemy.has_magic then
				magic_targets = magic_targets + 1
			end
		end
	end

	if not targets or #targets < attack.min_targets and magic_targets == 0 then
		SU.delay_attack(store, attack, fts(10))

		return
	end

	this.render.sprites[1].flip_x = target.pos.x < this.pos.x

	U.animation_start_default(this, attack.animation, this.render.sprites[1].flip_x, store.tick_ts)
	S:queue(attack.sound)

	if SU.y_hero_wait(store, this, attack.cast_time) then
		return
	end

	local direction = this.render.sprites[1].flip_x and -1 or 1
	local offset = V.v(attack.offset.x * direction, attack.offset.y)
	local fx = E:create_entity(attack.fx_t)

	fx.pos = V.v(this.pos.x + offset.x, this.pos.y + this.flight_height + offset.y)
	fx.render.sprites[1].ts = store.tick_ts
	fx.render.sprites[1].r = V.angleTo(target.pos.x - fx.pos.x, target.pos.y - fx.pos.y)
	fx.render.sprites[1].scale = V.v(km.clamp(attack.min_scale_x, 1.5, V.dist(fx.pos.x, fx.pos.y, target.pos.x, target.pos.y) / attack.image_width), 1)

	simulation:queue_insert_entity(fx)
	U.y_wait_unconditional(store, attack.hit_time)

	local aura = E:create_entity(attack.aura_t)

	aura.render.sprites[1].ts = store.tick_ts
	aura.pos = V.vclone(target.pos)
	aura.aura.source_id = this.id
	aura.aura.damage_min = skill.aura.damage_min[skill.level]
	aura.aura.damage_max = skill.aura.damage_max[skill.level]
	aura.aura.damage_factor = this.unit.damage_factor
	aura.aura.damage_buff = this.unit.damage_buff
	aura.aura.silence_duration = skill.silence.duration[skill.level]
	aura.aura.duration = skill.aura.duration

	simulation:queue_insert_entity(aura)

	attack.ts = store.tick_ts

	SU.hero_gain_xp_from_skill(this, skill)

	this.nav_rally.new = nil

	SU.y_hero_animation_wait(this)
	U.animation_start(this, "walk", nil, store.tick_ts, true)
end

local function hero_drakkan_skill_b(this, store, attack, skill)
	local _, targets = U.find_foremost_enemy(store, this.pos, attack.min_range, attack.max_range, attack.node_prediction, attack.vis_flags, attack.vis_bans)

	if not targets or #targets < attack.min_targets then
		SU.delay_attack(store, attack, fts(10))

		return
	end

	U.animation_start_default(this, attack.animation_lower, nil, store.tick_ts)
	S:queue(attack.sound)
	U.y_wait_unconditional(store, attack.wait_to_lower)

	this.render.sprites[1].z = Z_OBJECTS

	local start_ts = store.tick_ts

	while true do
		local p = math.min(1, (store.tick_ts - start_ts) / attack.lower_duration)
		local height = attack.floor_height + (this.flight_height - attack.floor_height) * (1 - p)

		set_hero_height(this, height)

		if p >= 1 then
			break
		end

		coroutine.yield()
	end

	local aura = E:create_entity(attack.aura_t)

	aura.pos = V.vclone(this.pos)
	aura.aura.source_id = this.id
	aura.aura.damage_min = skill.aura.damage_min[skill.level]
	aura.aura.damage_max = skill.aura.damage_max[skill.level]
	aura.aura.damage_factor = this.unit.damage_factor
	aura.aura.damage_buff = this.unit.damage_buff

	simulation:queue_insert_entity(aura)

	U.animation_start_default(this, attack.animation_rise, nil, store.tick_ts)

	this.render.sprites[1].z = Z_FLYING_HEROES

	set_hero_height(this, attack.floor_height)

	local rise_ts = store.tick_ts

	while true do
		local p = math.min(1, (store.tick_ts - rise_ts) / attack.lower_duration)
		local height = attack.floor_height + (this.flight_height - attack.floor_height) * p

		set_hero_height(this, height)

		if p >= 1 then
			break
		end

		coroutine.yield()
	end

	set_hero_height(this, this.flight_height)

	attack.ts = store.tick_ts

	SU.hero_gain_xp_from_skill(this, skill)

	this.nav_rally.new = nil

	SU.y_hero_animation_wait(this)
end

local function hero_drakkan_skill_c(this, store, attack, skill)
	local targets = U.find_enemies_in_range(store, this.pos, 0, attack.range, attack.vis_flags, attack.vis_bans)

	if not targets or #targets == 0 then
		SU.delay_attack(store, attack, fts(10))

		return
	end

	U.animation_start_default(this, attack.animation, nil, store.tick_ts)
	U.y_wait_unconditional(store, attack.cast_time)
	S:queue(attack.sound)

	local clone = E:create_entity(attack.clone_t)

	clone.pos.x, clone.pos.y = this.pos.x + attack.spawn_offset.x, this.pos.y + attack.spawn_offset.y
	clone.nav_rally.center = V.vv(0)
	clone.is_clone = true
	clone.reinforcement.duration = attack.duration
	clone.render.sprites[1].flip_x = this.render.sprites[1].flip_x

	simulation:queue_insert_entity(clone)

	SU.hero_gain_xp_from_skill(this, skill)

	attack.ts = store.tick_ts

	SU.y_hero_animation_wait(this)
end

local function find_ultimate_targets(this, store, attack)
	local _, targets = U.find_foremost_enemy(store, this.pos, 0, attack.max_range, 0, attack.vis_flags, attack.vis_bans, function(e)
		return e.nav_path and GR:cell_type(e.pos.x, e.pos.y) == TERRAIN_LAND and P:is_node_valid(e.nav_path.pi, e.nav_path.ni)
	end)

	if not targets or #targets < attack.min_targets then
		return nil
	end

	shuffle(targets)

	local out = {}

	for i = 1, math.min(attack.shots, #targets) do
		out[i] = targets[i]
	end

	return out
end

local function hero_drakkan_ultimate(this, store, attack, skill, start_y)
	local targets = find_ultimate_targets(this, store, attack)

	if not targets then
		SU.delay_attack(store, attack, fts(10))

		return
	end

	U.animation_start_default(this, attack.animation, nil, store.tick_ts)
	S:queue(attack.sound_cast)
	S:queue(attack.sound_taunt)

	if SU.y_hero_wait(store, this, attack.cast_time) then
		return
	end

	attack.ts = store.tick_ts

	SU.hero_gain_xp_from_skill(this, skill)

	for i = 1, attack.shots do
		local target = targets[(i - 1) % #targets + 1]
		local node_offset = P:predict_enemy_node_advance(target, attack.node_prediction)
		local pred_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + node_offset)
		local bullet = E:create_entity(attack.bullet_t)

		bullet.bullet.target_id = target.id
		bullet.bullet.source_id = this.id
		bullet.bullet.xp_dest_id = this.id
		bullet.pos = V.v(pred_pos.x, start_y)
		bullet.bullet.from = V.vclone(bullet.pos)
		bullet.bullet.to = V.v(pred_pos.x, pred_pos.y)

		simulation:queue_insert_entity(bullet)

		U.y_wait_unconditional(store, U.frandom(attack.delay_between_shots_min, attack.delay_between_shots_max))
	end

	SU.y_hero_animation_wait(this)
	U.animation_start(this, "walk", nil, store.tick_ts, true)
end

local function hero_drakkan_update(this, store)
	local h = this.health
	local is_clone = this.is_clone == true
	local skills = this.hero and this.hero.skills
	local attack = this.ranged.attacks[1]
	local skill_a = this.timed_attacks.list[1]
	local skill_b = this.timed_attacks.list[2]
	local skill_c = this.timed_attacks.list[3]
	local ultimate = this.timed_attacks.list[4]
	local spawn_ts = store.tick_ts
	local start_y = store.visible_coords and store.visible_coords.top or REF_H

	this.tween.disabled = false
	this.tween.ts = store.tick_ts
	this.health_bar.hidden = false

	if is_clone then
		U.animation_start_default(this, "in", nil, store.tick_ts)
		U.y_animation_wait(this)
	else
		U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts - fts(4), this.idle_flip.loop, nil, true)
	end

	local cooldown_factor = this.unit.cooldown_factor or 1

	attack.ts = store.tick_ts - attack.cooldown * cooldown_factor

	if skill_a and not skill_a.disabled then
		skill_a.ts = store.tick_ts - skill_a.cooldown * cooldown_factor
	end

	if skill_b and not skill_b.disabled then
		skill_b.ts = store.tick_ts - skill_b.cooldown * cooldown_factor
	end

	if skill_c and not skill_c.disabled then
		skill_c.ts = store.tick_ts - skill_c.cooldown * cooldown_factor
	end

	if ultimate and not ultimate.disabled then
		ultimate.ts = store.tick_ts - ultimate.cooldown * cooldown_factor
	end

	while true do
		if h.dead then
			if is_clone then
				SU.y_soldier_death(store, this)

				return
			else
				hero_drakkan_death_and_respawn(store, this)
				U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)
			end
		end

		if is_clone and store.tick_ts - spawn_ts > this.reinforcement.duration then
			if this.health.hp > 0 then
				this.reinforcement.hp_before_timeout = this.health.hp
			end

			this.health.hp = 0
			this.ui.can_click = false

			SU.remove_modifiers(store, this)
			SU.y_soldier_death(store, this)

			return
		end

		while this.nav_rally.new do
			if SU.y_hero_new_rally(store, this) then
				break
			end
		end

		if not is_clone and SU.hero_level_up(store, this) then
			U.y_animation_play(this, "lvl_up", nil, store.tick_ts, 1)
		end

		if not is_clone and ready_to_use_skill(ultimate, store, this.unit.cooldown_factor) then
			hero_drakkan_ultimate(this, store, ultimate, skills.ultimate, start_y)
		end

		if not is_clone and skill_c and ready_to_use_skill(skill_c, store, this.unit.cooldown_factor) then
			hero_drakkan_skill_c(this, store, skill_c, skills.skill_c)
		end

		if not is_clone and skill_b and ready_to_use_skill(skill_b, store, this.unit.cooldown_factor) then
			hero_drakkan_skill_b(this, store, skill_b, skills.skill_b)
		end

		if not is_clone and skill_a and ready_to_use_skill(skill_a, store, this.unit.cooldown_factor) then
			hero_drakkan_skill_a(this, store, skill_a, skills.skill_a)
		end

		if store.tick_ts - attack.ts >= attack.cooldown * (this.unit.cooldown_factor or 1) then
			hero_drakkan_basic_attack(this, store, attack)
		end

		SU.soldier_idle(store, this)
		SU.soldier_regen(store, this)

		coroutine.yield()
	end
end

local tt

tt = RT("hero_drakkan", "hero")
AC(tt, "melee", "ranged", "timed_attacks", "tween", "teleport")
tt.hero.level_stats.armor = {0, 0.02, 0.04, 0.06, 0.08, 0.1, 0.12, 0.14, 0.16, 0.18}
tt.hero.level_stats.hp_max = {230, 255, 280, 305, 330, 355, 380, 405, 430, 455}
tt.hero.level_stats.melee_damage_min = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
tt.hero.level_stats.melee_damage_max = {1, 2, 4, 4, 5, 6, 7, 8, 9, 10}
tt.hero.level_stats.ranged_damage_min = {13, 16, 19, 22, 26, 29, 32, 35, 38, 42}
tt.hero.level_stats.ranged_damage_max = {19, 24, 29, 34, 38, 43, 48, 53, 58, 62}
tt.hero.skills.skill_a = CC("hero_skill")
tt.hero.skills.skill_a.cooldown = 15
tt.hero.skills.skill_a.xp_gain = {60, 120, 180}
tt.hero.skills.skill_a.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.skill_a.key = "NULLIFYING_PULSE"
tt.hero.skills.skill_a.aura = {}
tt.hero.skills.skill_a.aura.duration = fts(45)
tt.hero.skills.skill_a.aura.damage_min = {6, 8, 12}
tt.hero.skills.skill_a.aura.damage_max = {9, 12, 18}
tt.hero.skills.skill_a.aura.damage_type = DAMAGE_MAGICAL
tt.hero.skills.skill_a.aura.damage_every = 0.25
tt.hero.skills.skill_a.aura.damage_radius = 75
tt.hero.skills.skill_a.silence = {}
tt.hero.skills.skill_a.silence.duration = {8, 10, 12}
tt.hero.skills.skill_b = CC("hero_skill")
tt.hero.skills.skill_b.cooldown = 18
tt.hero.skills.skill_b.xp_gain = {72, 144, 216}
tt.hero.skills.skill_b.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.skill_b.key = "DECONSTRUCT"
tt.hero.skills.skill_b.aura = {}
tt.hero.skills.skill_b.aura.damage_min = {24, 48, 82}
tt.hero.skills.skill_b.aura.damage_max = {36, 72, 114}
tt.hero.skills.skill_b.aura.damage_type = DAMAGE_MAGICAL
tt.hero.skills.skill_b.aura.damage_radius = 90
tt.hero.skills.skill_c = CC("hero_skill")
tt.hero.skills.skill_c.cooldown = 28
tt.hero.skills.skill_c.xp_gain = {112, 224, 336}
tt.hero.skills.skill_c.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.hero.skills.skill_c.key = "DOUBLE_DRAGON"
tt.hero.skills.skill_c.duration = {10, 13, 16}
tt.hero.skills.skill_c.range = 220
tt.hero.skills.skill_c.spawn_offset = vec_2(-50, 15)
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.cooldown = 40
tt.hero.skills.ultimate.xp_gain = {160}
tt.hero.skills.ultimate.xp_level_steps = {
	[5] = 1
}
tt.hero.skills.ultimate.key = "ARCANE_STORM"
tt.hero.skills.ultimate.shots = 7
tt.hero.skills.ultimate.min_targets = 7
tt.hero.skills.ultimate.max_range = 2000
tt.hero.skills.ultimate.damage_min = 40
tt.hero.skills.ultimate.damage_max = 60
tt.hero.skills.ultimate.damage_type = DAMAGE_MAGICAL
tt.hero.skills.ultimate.damage_radius = 70
tt.hero.skills.talent_1 = CC("hero_skill")
tt.hero.skills.talent_1.key = "MAGIC_PHASING"
tt.hero.skills.talent_1.xp_level_steps = {
	[1] = 1
}
tt.hero.skills.talent_2 = CC("hero_skill")
tt.hero.skills.talent_2.key = "ARCANE_AFFINITY"
tt.hero.skills.talent_2.skills_cd_red = 0.2
tt.hero.skills.talent_2.xp_level_steps = {
	[1] = 1
}
tt.health.dead_lifetime = 15
tt.health_bar.draw_order = -1
tt.health_bar.offset = vec_2(0, 160)
tt.health_bar.sort_y_offset = -161
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.health_bar.z = Z_FLYING_HEROES
tt.hero.fn_level_up = hero_drakkan_level_up
tt.hero.respawn_animation = "respawn_dragon"
tt.hero.tombstone_show_time = fts(1)
tt.hero.tombstone_decal = "decal_drakkan_tombstone"
tt.hero.tombstone_concurrent_with_death = true
tt.hero.tombstone_respawn_animation = "respawn_grave"
tt.hero.use_custom_spawn_point = true
tt.flight_height = 80
tt.idle_flip.last_animation = "walk"
tt.idle_flip.cooldown = 10
tt.info.fn = hero_drakkan_get_info
tt.info.hero_portrait = "kr6_hero_portraits_0009"
tt.info.portrait = "kr6_info_portraits_heroes_0008"
tt.main_script.insert = hero_drakkan_insert
tt.main_script.update = hero_drakkan_update
tt.motion.max_speed = 100
tt.nav_rally.requires_node_nearby = false
tt.nav_grid.ignore_waypoints = true
tt.nav_grid.valid_terrains = bor(TERRAIN_NONE, TERRAIN_LAND, TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK, TERRAIN_SHALLOW, TERRAIN_FAERIE, TERRAIN_ICE)
tt.nav_grid.valid_terrains_dest = tt.nav_grid.valid_terrains
tt.drag_line_origin_offset = vec_2(0, tt.flight_height)
tt.regen.cooldown = 1
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].prefix = "hero_drakkanDef"
tt.render.sprites[1].name = "respawn_dragon"
tt.render.sprites[1].exo = true
tt.render.sprites[1].draw_order = DO_HEROES
tt.render.sprites[1].offset.y = tt.flight_height
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].offset = vec_2(0, 0)
tt.render.sprites[2].scale = vec_2(1, 1)
tt.render.sprites[2].z = Z_DECALS + 1
tt.sound_events.change_rally_point = "HeroDrakkanTaunt"
tt.sound_events.death = "HeroDrakkanDeath"
tt.sound_events.hero_room_select = "HeroDrakkanTauntSelect"
tt.sound_events.level_up = "HeroDrakkanTauntLevelUp"
tt.sound_events.respawn = "HeroDrakkanTauntIntro"
tt.teleport.animations = {"teleport_in", "teleport_out"}
tt.teleport.disabled = true
tt.teleport.min_distance = 250
tt.teleport.sound = "HeroDrakkanTalentTeleportOut"
tt.text_balloon_offset = vec_2(47, 55)
tt.ui.click_rect = r(-37, tt.flight_height - 20, 90, 85)
tt.unit.death_animation = "death_dragon"
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, tt.flight_height + 10)
tt.unit.mod_offset = vec_2(0, tt.flight_height + 10)
tt.vis.bans = bor(tt.vis.bans, F_EAT, F_NET, F_POISON, F_MOD)
tt.vis.feeding_bans = bor(tt.vis.bans, F_STUN)
tt.vis.feeding_flags = tt.vis.flags
tt.vis.flags = bor(tt.vis.flags, F_FLYING)
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animation = "attack"
tt.ranged.attacks[1].bullet = "bullet_drakkan"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(46, tt.flight_height - 23), vec_2(50, tt.flight_height - 23)}
tt.ranged.attacks[1].cooldown = 2
tt.ranged.attacks[1].ignore_offset = vec_2(0, tt.flight_height + 10)
tt.ranged.attacks[1].max_range = 220
tt.ranged.attacks[1].min_range = 50
tt.ranged.attacks[1].node_prediction = fts(15)
tt.ranged.attacks[1].radius = 80
tt.ranged.attacks[1].shared_cooldown = true
tt.ranged.attacks[1].shoot_time = fts(14)
tt.ranged.attacks[1].sound = "HeroDrakkanBasicAttackCast"
tt.ranged.attacks[1].sync_animation = true
tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].animation = "skill_1"
tt.timed_attacks.list[1].aura_t = "aura_drakkan_skill_a"
tt.timed_attacks.list[1].cast_time = fts(14)
tt.timed_attacks.list[1].cooldown = 15
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].fx_t = "fx_drakkan_skill_a"
tt.timed_attacks.list[1].height_tolerance = 20
tt.timed_attacks.list[1].hit_time = fts(1)
tt.timed_attacks.list[1].ignore_offset = vec_2(0, tt.flight_height + 30)
tt.timed_attacks.list[1].image_width = 145
tt.timed_attacks.list[1].max_range = 160
tt.timed_attacks.list[1].min_range = 50
tt.timed_attacks.list[1].min_scale_x = 0.7
tt.timed_attacks.list[1].min_targets = 3
tt.timed_attacks.list[1].offset = vec_2(37, -6)
tt.timed_attacks.list[1].radius = 125
tt.timed_attacks.list[1].sound = "HeroDrakkanNullifyingPulseCast"
tt.timed_attacks.list[1].vis_bans = bor(F_FRIEND, F_FLYING)
tt.timed_attacks.list[1].vis_flags = bor(F_AREA)
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].animation_lower = "skill_2_deconstruct"
tt.timed_attacks.list[2].animation_rise = "skill_2_reform"
tt.timed_attacks.list[2].aura_t = "aura_drakkan_skill_b"
tt.timed_attacks.list[2].cast_time = fts(18)
tt.timed_attacks.list[2].cooldown = 18
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].ease_down = "expo-in"
tt.timed_attacks.list[2].floor_height = 15
tt.timed_attacks.list[2].ignore_offset = vec_2(0, tt.flight_height + 30)
tt.timed_attacks.list[2].lower_duration = fts(6)
tt.timed_attacks.list[2].max_range = 90
tt.timed_attacks.list[2].min_range = 50
tt.timed_attacks.list[2].min_targets = 3
tt.timed_attacks.list[2].offset = vec_2(37, -6)
tt.timed_attacks.list[2].radius = 125
tt.timed_attacks.list[2].shadow_max_scale = 1.7
tt.timed_attacks.list[2].sound = "HeroDrakkanDeconstructCast"
tt.timed_attacks.list[2].vis_bans = bor(F_FRIEND, F_FLYING)
tt.timed_attacks.list[2].vis_flags = bor(F_AREA)
tt.timed_attacks.list[2].wait_to_lower = fts(12)
tt.timed_attacks.list[3] = CC("custom_attack")
tt.timed_attacks.list[3].animation = "skill_3"
tt.timed_attacks.list[3].cast_time = fts(6)
tt.timed_attacks.list[3].clone_t = "soldier_drakkan_clone"
tt.timed_attacks.list[3].cooldown = 28
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].duration = 10
tt.timed_attacks.list[3].range = 220
tt.timed_attacks.list[3].sound = "HeroDrakkanDoubleDragonCast"
tt.timed_attacks.list[3].spawn_offset = vec_2(-50, 15)
tt.timed_attacks.list[3].vis_bans = bor(F_FRIEND, F_FLYING)
tt.timed_attacks.list[3].vis_flags = bor(F_AREA)
tt.timed_attacks.list[4] = CC("custom_attack")
tt.timed_attacks.list[4].animation = "ultimate"
tt.timed_attacks.list[4].bullet_t = "bullet_drakkan_ultimate"
tt.timed_attacks.list[4].cast_time = fts(18)
tt.timed_attacks.list[4].cooldown = 40
tt.timed_attacks.list[4].delay_between_shots_max = fts(3)
tt.timed_attacks.list[4].delay_between_shots_min = fts(1)
tt.timed_attacks.list[4].disabled = true
tt.timed_attacks.list[4].max_range = 2000
tt.timed_attacks.list[4].min_targets = 7
tt.timed_attacks.list[4].node_prediction = fts(7)
tt.timed_attacks.list[4].shots = 7
tt.timed_attacks.list[4].sound_cast = "HeroDrakkanArcaneStormCast"
tt.timed_attacks.list[4].sound_taunt = "HeroDrakkanTauntUltimate"
tt.timed_attacks.list[4].vis_bans = bor(F_FRIEND)
tt.timed_attacks.list[4].vis_flags = bor(F_AREA)
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}
tt.tween.props[1].name = "alpha"
tt.tween.props[1].sprite_id = 2
tt.tween.remove = false

tt = RT("soldier_drakkan_clone", "soldier_militia")
AC(tt, "melee", "ranged", "timed_attacks", "tween", "nav_grid", "reinforcement")
tt.flight_height = 80
tt.health.armor = 0.06
tt.health.hp_max = 240
tt.health.dead_lifetime = fts(25)
tt.health_bar.draw_order = -1
tt.health_bar.offset = vec_2(0, 160)
tt.health_bar.sort_y_offset = -161
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.health_bar.z = Z_FLYING_HEROES
tt.reinforcement.duration = 10
tt.reinforcement.fade = false
tt.idle_flip.last_animation = "walk"
tt.idle_flip.cooldown = 10
tt.info.fn = soldier_drakkan_clone_get_info
tt.info.i18n_key = "HERO_DRAKKAN_CLONE"
tt.info.portrait = "info_portraits_soldiers_0020"
tt.info.random_name_count = nil
tt.info.random_name_format = nil
tt.main_script.update = hero_drakkan_update
tt.motion.max_speed = 100
tt.nav_rally.requires_node_nearby = false
tt.nav_grid.ignore_waypoints = true
tt.nav_grid.valid_terrains = bor(TERRAIN_NONE, TERRAIN_LAND, TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK, TERRAIN_SHALLOW, TERRAIN_FAERIE, TERRAIN_ICE)
tt.nav_grid.valid_terrains_dest = tt.nav_grid.valid_terrains
tt.drag_line_origin_offset = vec_2(0, tt.flight_height)
tt.regen.cooldown = 1
tt.regen.health = 19
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].name = "in"
tt.render.sprites[1].exo = true
tt.render.sprites[1].offset.y = tt.flight_height
tt.render.sprites[1].prefix = "hero_drakkan_doubleDef"
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.render.sprites[1].draw_order = DO_HEROES
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].offset = vec_2(0, 0)
tt.render.sprites[2].scale = vec_2(1, 1)
tt.render.sprites[2].z = Z_DECALS + 1
tt.sound_events.death = "HeroDrakkanDoubleDragonDisappear"
tt.ui.click_rect = r(-37, tt.flight_height - 20, 90, 85)
tt.unit.death_animation = "death"
tt.unit.hide_after_death = false
tt.unit.hit_offset = vec_2(0, tt.flight_height + 10)
tt.unit.mod_offset = vec_2(0, tt.flight_height + 10)
tt.vis.bans = bor(tt.vis.bans, F_EAT, F_NET, F_POISON, F_MOD)
tt.vis.feeding_bans = bor(tt.vis.bans, F_STUN)
tt.vis.feeding_flags = tt.vis.flags
tt.vis.flags = bor(tt.vis.flags, F_FLYING)
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animation = "attack"
tt.ranged.attacks[1].bullet = "bullet_drakkan_clone"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(46, tt.flight_height - 23), vec_2(50, tt.flight_height - 23)}
tt.ranged.attacks[1].cooldown = 2
tt.ranged.attacks[1].ignore_offset = vec_2(0, tt.flight_height + 30)
tt.ranged.attacks[1].max_range = 220
tt.ranged.attacks[1].min_range = 50
tt.ranged.attacks[1].node_prediction = fts(15)
tt.ranged.attacks[1].radius = 125
tt.ranged.attacks[1].shared_cooldown = true
tt.ranged.attacks[1].shoot_time = fts(14)
tt.ranged.attacks[1].sound = "HeroDrakkanBasicAttackCast"
tt.ranged.attacks[1].sync_animation = true
tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}
tt.tween.props[1].name = "alpha"
tt.tween.props[1].sprite_id = 2
tt.tween.remove = false

tt = RT("aura_drakkan_skill_a", "aura")
AC(tt, "render")
tt.aura.cycle_time = 0.25
tt.aura.damage_type = DAMAGE_MAGICAL
tt.aura.duration = fts(45)
tt.aura.mod = "mod_drakkan_skill_a_silence"
tt.aura.radius = 75
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.aura.vis_flags = bor(F_AREA)
tt.main_script.update = aura_drakkan_skill_a_update
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "run"
tt.render.sprites[1].prefix = "drakkan_fx_skill1_decal"
tt.render.sprites[1].z = Z_DECALS

tt = RT("aura_drakkan_skill_b", "aura")
tt.aura.damage_type = DAMAGE_MAGICAL
tt.aura.hit_fx = "fx_drakkan_skill_b_hit"
tt.aura.radius = 90
tt.aura.vis_bans = bor(F_FRIEND, F_FLYING)
tt.aura.vis_flags = bor(F_AREA)
tt.main_script.update = aura_drakkan_skill_b_update

tt = RT("mod_drakkan_skill_a_silence", "modifier")
AC(tt, "render", "tween")
tt.main_script.insert = scripts.mod_silence.insert
tt.main_script.remove = scripts.mod_silence.remove
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.duration = 8
tt.modifier.vis_bans = 0
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "drakkan_fx_skill1_silence"
tt.render.sprites[1].size_names = {"idle", "big_idle", "big_idle"}
tt.tween.props[1].keys = {{0, 0}, {0.25, 255}}
tt.tween.remove = false

tt = RT("ps_bullet_drakkan", "particle_system")
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.z = Z_BULLET_PARTICLES
tt.particle_system.name = "drakkan_fx_attack_particle_idle"
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.emission_rate = 25
tt.particle_system.emit_area_spread = vec_2(3, 3)
tt.particle_system.track_rotation = true

tt = RT("ps_bullet_drakkan_ultimate", "particle_system")
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.z = Z_BULLET_PARTICLES
tt.particle_system.name = "drakkan_fx_ulti_particle_idle"
tt.particle_system.particle_lifetime = {fts(12), fts(12)}
tt.particle_system.emission_rate = 60
tt.particle_system.emit_rotation_spread = math.pi / 2
tt.particle_system.emit_area_spread = vec_2(20, 6)
tt.particle_system.scale_var = {0.8, 1}

tt = RT("fx_bullet_drakkan_hit_ground", "fx")
tt.render.sprites[1].prefix = "drakkan_fx_attack_hit"
tt.render.sprites[1].name = "hit"
tt.render.sprites[1].z = Z_EFFECTS

tt = RT("fx_bullet_drakkan_hit_air", "fx")
tt.render.sprites[1].prefix = "drakkan_fx_attack_hit_flying"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].z = Z_EFFECTS

tt = RT("fx_drakkan_skill_a", "fx")
tt.render.sprites[1].prefix = "drakkan_fx_skill1_wave"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].z = Z_EFFECTS

tt = RT("fx_drakkan_skill_b_hit", "fx")
tt.render.sprites[1].prefix = "drakkan_fx_skill2_hit"
tt.render.sprites[1].size_names = {"hit", "big_hit", "big_hit"}
tt.render.sprites[1].name = "hit"
tt.render.sprites[1].z = Z_EFFECTS

tt = RT("fx_bullet_drakkan_ultimate_hit_ground", "fx")
tt.render.sprites[1].prefix = "drakkan_fx_ulti_hit"
tt.render.sprites[1].name = "hit"
tt.render.sprites[1].z = Z_EFFECTS

tt = RT("decal_drakkan_tombstone", "decal")
tt.render.sprites[1].prefix = "hero_drakkanDef"
tt.render.sprites[1].name = "death_grave"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].scale = vec_2(1, 1)
tt.render.sprites[1].z = Z_DECALS

tt = RT("decal_bullet_drakkan", "decal_tween")
AC(tt, "main_script")
tt.render.sprites[1].name = "drakkan_fx_ulti_decal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 0}, {1, 255}}
tt.tween.remove = false
tt.tween.disabled = true
tt.tween.run_once = true
tt.wait_time = 1
tt.main_script.remove = scripts.tween_utils.reverse_remove
tt.main_script.update = scripts.tween_utils.wait_update

tt = RT("bullet_drakkan", "bolt")
tt.bullet.damage_min = nil
tt.bullet.damage_max = nil
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.damage_radius = 40
tt.bullet.hit_fx = "fx_bullet_drakkan_hit_ground"
tt.bullet.hit_fx_air = "fx_bullet_drakkan_hit_air"
tt.bullet.hit_decal = "decal_bullet_drakkan"
tt.bullet.particles_name = "ps_bullet_drakkan"
tt.bullet.max_speed = 600
tt.bullet.min_speed = 600
tt.bullet.xp_gain_factor = 1.2
tt.bullet.align_with_trajectory = true
tt.bullet.ignore_hit_offset = false
tt.bullet.pop_chance = 0
tt.bullet.g = nil
tt.bullet.use_unit_damage_factor = true
tt.render.sprites[1].prefix = "drakkan_fx_attack_projectile"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].z = Z_BULLETS
tt.sound_events.insert = nil

tt = RT("bullet_drakkan_clone", "bullet_drakkan")
tt.bullet.damage_min = 19
tt.bullet.damage_max = 29
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.damage_radius = 40
tt.bullet.xp_gain_factor = 1.2

tt = RT("bullet_drakkan_ultimate", "bullet")
AC(tt, "sound_events")
tt.bullet.min_speed = 0
tt.bullet.max_speed = 1e+99
tt.bullet.acceleration = 30
tt.bullet.travel_time = fts(7)
tt.bullet.hit_fx = "fx_bullet_drakkan_ultimate_hit_ground"
tt.bullet.hit_decal = "decal_bullet_drakkan"
tt.bullet.ignore_hit_offset = true
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.damage_radius = 70
tt.bullet.damage_min = 40
tt.bullet.damage_max = 60
tt.bullet.damage_flags = F_AREA
tt.bullet.particles_name = "ps_bullet_drakkan_ultimate"
tt.main_script.update = bullet_drakkan_ultimate_update
tt.render.sprites[1].name = "drakkan_fx_ulti_projectile_idle"
tt.sound_events.remove = "HeroDrakkanArcaneStormImpact"
