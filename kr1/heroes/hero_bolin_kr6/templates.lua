local bit = require("bit")
local E = require("entity_db")
local scripts = require("scripts")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local km = require("lib.klua.macros")
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

local function bolin_find_valid_node(pi, start_ni, dir)
	local path = P.paths[pi][1]
	local ni = start_ni

	repeat
		if ni >= 1 and ni <= #path and P:is_node_valid(pi, ni) then
			return ni
		end

		ni = ni + dir
	until ni < 1 or ni > #path
end

local function bolin_mortar_positions(first_enemy, bullet_count, node_gap, pred_time)
	local fpos = P:predict_enemy_pos(first_enemy, pred_time)
	local nearest = P:nearest_nodes(fpos.x, fpos.y, {first_enemy.nav_path.pi}, {1})[1]

	if not nearest then
		return nil
	end

	local pi, ni = nearest[1], nearest[3]

	if ni - node_gap * 2 < 0 then
		ni = node_gap * 2 + 1
	end

	local ret = {}

	for i = 1, bullet_count do
		local dir = i == 1 and -1 or 1
		local valid_ni = bolin_find_valid_node(pi, ni, dir)

		if not valid_ni then
			break
		end

		ret[#ret + 1] = P:node_pos(pi, 1, valid_ni)
		ni = valid_ni - node_gap
	end

	return ret
end

local function bolin_mine_pos(this, near_mines, a)
	local positions = P:get_all_valid_pos(this.pos.x, this.pos.y, a.min_range, a.max_range, TERRAIN_LAND, function(x, y)
		for _, mine in ipairs(near_mines) do
			if V.dist(mine.pos.x, mine.pos.y, x, y) <= a.min_dist_between_mines then
				return false
			end
		end

		return true
	end, nil)

	if not positions or #positions == 0 then
		return nil
	end

	return positions[math.random(1, #positions)]
end

local function bolin_find_mines(store)
	local mines = {}

	for _, e in pairs(store.entities) do
		if e.template_name == "aura_bolin_skill_b_trigger" then
			mines[#mines + 1] = e
		end
	end

	return mines
end

local function bolin_skip_ultimate(targets, sua)
	if targets and #targets >= sua.min_targets then
		return false
	end

	for _, t in ipairs(targets or {}) do
		if t.health.hp >= sua.min_hp then
			return false
		end
	end

	return true
end

local function bolin_area_damage_update(this, store)
	local source = store.entities[this.source_id or this.aura.source_id]

	if source and source.bullet then
		source = store.entities[source.bullet.source_id]
	end

	local buff = source and source.unit.damage_buff or 0
	local factor = source and source.unit.damage_factor or 1
	local enemies = U.find_enemies_in_range(store, this.pos, 0, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans)

	if enemies then
		for _, enemy in ipairs(enemies) do
			local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, this.pos, this.aura.radius)
			local value = math.floor(this.aura.damage_max - (this.aura.damage_max - this.aura.damage_min) * dist_factor)
			local d = E.assign_damage(this.aura.damage_type, math.ceil((value + buff) * factor), this.id, enemy.id)

			queue_damage(store, d)
		end
	end

	simulation:queue_remove_entity(this)
end

local function controller_bolin_death_explosion_update(this, store)
	U.y_wait(store, this.time_to_spawn)

	local source = store.entities[this.source_id]

	if not source then
		simulation:queue_remove_entity(this)

		return
	end

	local exp = E:create_entity(this.aura)

	exp.pos = V.vclone(source.pos)
	exp.source_id = this.source_id

	simulation:queue_insert_entity(exp)
	simulation:queue_remove_entity(this)
end

local function controller_bolin_spawn_casing_update(this, store)
	local source = store.entities[this.source_id]

	if not source then
		simulation:queue_remove_entity(this)

		return
	end

	local source_spr = source.render.sprites[this.sprite_id]
	local max = 4

	U.y_wait(store, this.time_to_spawn, function(s, t)
		return not table.contains(this.animation_names, source_spr.name)
	end)

	if table.contains(this.animation_names, source_spr.name) then
		if this.amount_to_spawn > 1 then
			S:queue(this.sound)
		end

		for i = 1, math.min(this.amount_to_spawn, max) do
			local casing = E:create_entity(this.casing)
			local random_y = 3 * (i - 2) + U.frandom(-3, 3)

			casing.pos.x = this.spawn_origin.x + this.spawn_offset.x
			casing.pos.y = this.spawn_origin.y + this.spawn_offset.y + random_y
			casing.y_origin = this.spawn_origin.y + random_y

			if not source_spr.flip_x then
				casing.initial_direction_v.x = casing.initial_direction_v.x * -1
			end

			simulation:queue_insert_entity(casing)
		end
	end

	simulation:queue_remove_entity(this)
end

local function fx_bolin_bullet_casing_update(this, store)
	local ps

	if this.particles_name then
		ps = E:create_entity(this.particles_name)
		ps.particle_system.track_id = this.id

		simulation:queue_insert_entity(ps)
	end

	local nvx, nvy = V.normalize(this.initial_direction_v.x + U.frandom(-0.02, 0.02), this.initial_direction_v.y + U.frandom(-0.06, 0.06))
	local conserved_speed = this.initial_speed * U.frandom(0.9, 1.1)
	local cvx, cvy = V.mul(conserved_speed, nvx, nvy)
	local dt = fts(1)
	local last_ts = store.tick_ts
	local spr = this.render.sprites[1]
	local bounces = 0

	while not V.eq(cvx, cvy, 0, 0) do
		this.pos.x, this.pos.y = this.pos.x + cvx * dt, this.pos.y + cvy * dt
		spr.r = spr.r + -km.sign(nvx) * 20 * dt

		if this.pos.y <= this.y_origin then
			if bounces == this.bounces then
				cvx, cvy = 0, 0
				spr.r = 0
				spr.z = Z_DECALS

				U.y_animation_play(this, this.rest_anim, nil, store.tick_ts)

				break
			end

			bounces = bounces + 1
			this.pos.y = this.y_origin
			conserved_speed = conserved_speed * this.elasticity
			cvy = conserved_speed * nvy
			cvx = conserved_speed * nvx

			if bounces == this.bounces and ps and ps.particle_system.emit then
				ps.particle_system.emit = false
			end
		end

		cvy = cvy + this.g * dt
		dt = store.tick_ts - last_ts
		last_ts = store.tick_ts

		coroutine.yield()
	end

	U.y_wait(store, 2)

	this.tween.ts = store.tick_ts
	this.tween.disabled = false
end

local function bullet_bolin_update(this, store)
	local b = this.bullet
	local source = store.entities[b.source_id]
	local target = store.entities[b.target_id]

	local function create_fx(hfx)
		local sfx = E:create_entity(hfx)

		sfx.render.sprites[1].ts = store.tick_ts

		local is_air = target and band(target.vis.flags, F_FLYING) ~= 0

		if b.hit_fx_ignore_hit_offset and target and not is_air then
			sfx.pos.x, sfx.pos.y = target.pos.x, target.pos.y
		else
			local hoffset = V.vclone(target.unit.hit_offset)

			sfx.pos.x, sfx.pos.y = target.pos.x + hoffset.x, target.pos.y + hoffset.y
		end

		if sfx.allow_rotation and source then
			local vx, vy = V.sub(target.pos.x, target.pos.y, source.pos.x, source.pos.y)
			local r = km.unroll(V.angleTo(vx, vy))

			sfx.render.sprites[1].r = r
		end

		simulation:queue_insert_entity(sfx)
	end

	if target and not target.health.dead then
		local buff = source and source.unit.damage_buff or 0
		local factor = source and source.unit.damage_factor or 1
		local d = E.assign_damage(b.damage_type, math.max(1, (U.frandom(b.damage_min, b.damage_max) + buff) * factor), this.id, target.id)

		d.reduce_armor = b.reduce_armor
		d.xp_gain_factor = b.xp_gain_factor
		d.xp_dest_id = b.xp_dest_id
		d.pop = b.pop
		d.pop_conds = b.pop_conds

		queue_damage(store, d)

		if b.hit_fxs and #b.hit_fxs > 0 then
			for i = 1, #b.hit_fxs do
				create_fx(b.hit_fxs[i])
			end
		elseif b.hit_fx then
			create_fx(b.hit_fx)
		end

		if b.hit_payload then
			local hp = E:create_entity(b.hit_payload)

			hp.source_id = b.source_id
			hp.pos = V.vclone(target.pos)

			simulation:queue_insert_entity(hp)
		end
	end

	simulation:queue_remove_entity(this)
end

local function bullet_bolin_skills_parabola_insert(this, store)
	local b = this.bullet

	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	b.last_pos = V.vclone(b.from)

	if b.rotation_speed then
		this.render.sprites[1].r = 0
		b.rotation_speed = b.rotation_speed * (b.to.x > b.from.x and -1 or 1)
	end

	this.render.sprites[1].hidden = false

	return true
end

local function bullet_bolin_skills_parabola_update(this, store)
	local ps
	local b = this.bullet

	this.render.sprites[1].hidden = false

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.pos.x, ps.pos.y = this.pos.x, this.pos.y
		ps.particle_system.track_id = this.id

		simulation:queue_insert_entity(ps)
	end

	while store.tick_ts - b.ts + store.tick_length < b.flight_time do
		coroutine.yield()

		b.last_pos.x, b.last_pos.y = this.pos.x, this.pos.y
		this.pos.x, this.pos.y = SU.position_in_parabola(store.tick_ts - b.ts, b.from, b.speed, b.g)

		if b.rotation_speed then
			this.render.sprites[1].r = this.render.sprites[1].r + b.rotation_speed * store.tick_length
		end

		if this.change_z_midflight and store.tick_ts - b.ts > this.change_z_time then
			this.render.sprites[1].z = this.change_z_midflight
		end
	end

	if b.payload then
		local hp = E:create_entity(b.payload)

		hp.pos = V.vclone(b.to)
		hp.source_id = b.source_id

		if hp.render then
			hp.render.sprites[1].ts = store.tick_ts
		end

		if hp.aura then
			hp.aura.level = this.bullet.level

			if b.payload_damage_min then
				hp.damage_min = b.payload_damage_min
				hp.damage_max = b.payload_damage_max
			end
		end

		simulation:queue_insert_entity(hp)
	end

	if b.hit_fx then
		local hfx = E:create_entity(b.hit_fx)

		hfx.pos = V.vclone(b.to)

		simulation:queue_insert_entity(hfx)
	end

	if b.hit_decal then
		local decal = E:create_entity(b.hit_decal)

		decal.pos = V.vclone(this.pos)
		decal.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(decal)
	end

	if ps then
		ps.particle_system.emit = false
	end

	if b.damage_min and b.damage_max then
		local source = store.entities[b.source_id]
		local buff = source and source.unit.damage_buff or 0
		local factor = source and source.unit.damage_factor or 1
		local enemies = U.find_enemies_in_range(store, b.to, 0, b.damage_radius, b.damage_flags, b.damage_bans)

		if enemies then
			for _, enemy in ipairs(enemies) do
				local d = E.assign_damage(b.damage_type, math.ceil((math.random(b.damage_min, b.damage_max) + buff) * factor), this.id, enemy.id)

				if b.xp_gain_factor and b.xp_dest_id then
					d.xp_gain_factor = b.xp_gain_factor
					d.xp_dest_id = b.source_id
				end

				queue_damage(store, d)
			end
		end
	end

	if this.exit_animation then
		this.render.sprites[1].r = 0

		if this.exit_z then
			this.render.sprites[1].z = this.exit_z
		end

		U.y_animation_play(this, this.exit_animation, nil, store.tick_ts, 1, 1)
	end

	simulation:queue_remove_entity(this)
end

local function aura_bolin_skill_b_trigger_update(this, store)
	local function do_damage()
		local source = store.entities[this.source_id]
		local buff = source and source.unit.damage_buff or 0
		local factor = source and source.unit.damage_factor or 1
		local enemies = U.find_enemies_in_range(store, this.pos, 0, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans)

		if enemies then
			for _, enemy in ipairs(enemies) do
				local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, this.pos, this.aura.radius)
				local value = math.floor(this.damage_max - (this.damage_max - this.damage_min) * dist_factor)
				local d = E.assign_damage(this.damage_type, math.ceil((value + buff) * factor), this.id, enemy.id)

				queue_damage(store, d)
			end
		end
	end

	U.y_animation_wait(this, 1)
	U.animation_start(this, "idle", nil, store.tick_ts, true)

	local targets

	repeat
		targets = U.find_enemies_in_range(store, this.pos, 0, this.trigger_radius, this.aura.vis_flags, this.aura.vis_bans_trigger)

		coroutine.yield()
	until targets and #targets > 0 or this.trigger

	U.animation_start(this, "explode", nil, store.tick_ts, false)

	this.render.sprites[1].z = Z_OBJECTS

	S:queue(this.sound_hit)
	do_damage()

	local hd = E:create_entity(this.hit_decal)

	hd.pos = V.vclone(this.pos)

	simulation:queue_insert_entity(hd)

	local source = store.entities[this.source_id]

	if source then
		source.max_mines_near = false
	end

	U.y_animation_wait(this, nil)
	simulation:queue_remove_entity(this)
end

local function bullet_bolin_skill_c_update(this, store, script)
	local b = this.bullet
	local target = store.entities[b.target_id]

	if not target then
		return false
	end

	local source = store.entities[b.source_id]

	if target.health then
		local hp_pctg = this.boss_hp_pctg

		if band(target.vis.flags, bor(F_BOSS, F_MINIBOSS)) == 0 then
			hp_pctg = this.hp_pctg
		end

		b.damage_min = b.damage_min + target.health.hp_max * hp_pctg
		b.damage_max = b.damage_max + target.health.hp_max * hp_pctg

		if this.damage_cap then
			b.damage_min = math.max(b.damage_min, this.damage_cap)
			b.damage_max = math.max(b.damage_max, this.damage_cap)
		end
	end

	if source then
		local st_1 = source.hero.skills.talent_1

		if st_1.level > 0 then
			b.reduce_armor = st_1.reduce_armor
		end

		b.damage_min = b.damage_min + source.unit.damage_buff
		b.damage_max = b.damage_max + source.unit.damage_buff
		b.damage_factor = source.unit.damage_factor
	end

	scripts.ray5_simple.update(this, store, script)
end

local function bullet_bolin_ultimate_update(this, store, script)
	local b = this.bullet
	local source = store.entities[b.source_id]

	if source then
		local st_1 = source.hero.skills.talent_1

		if st_1.level > 0 then
			b.reduce_armor = st_1.reduce_armor
		end

		b.damage_min = b.damage_min + source.unit.damage_buff
		b.damage_max = b.damage_max + source.unit.damage_buff
		b.damage_factor = source.unit.damage_factor
	end

	scripts.ray5_simple.update(this, store, script)
end

local function hero_bolin_kr6_level_up(this, store)
	if this.hero.level > 1 then
		S:queue(this.sound_events.level_up)
	end

	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
	this.ranged.attacks[1].damage_min = ls.ranged_damage_min[hl]
	this.ranged.attacks[1].damage_max = ls.ranged_damage_max[hl]

	upgrade_skill(this, "skill_a", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.cooldown = s.cooldown
		a.damage_min = s.damage_min[s.level]
		a.damage_max = s.damage_max[s.level]
	end)
	upgrade_skill(this, "skill_b", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.cooldown = s.cooldown
		a.max_mines = s.max_mines[s.level]
	end)
	upgrade_skill(this, "skill_c", function(this, s)
		this.hero.skills.skill_c.disabled = nil
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		local a = this.timed_attacks.list[3]

		a.disabled = nil
		a.cooldown = s.cooldown
	end)
	upgrade_skill(this, "talent_1", function(this, s)
		this.hero.skills.talent_1.disabled = nil
	end)
	upgrade_skill(this, "talent_2", function(this, s)
		this.hero.skills.talent_2.disabled = nil
	end)
	update_hp(this)
end

local function hero_bolin_kr6_update(this, store)
	local h = this.health
	local skills = this.hero.skills
	local sa, sb, sc, su = skills.skill_a, skills.skill_b, skills.skill_c, skills.ultimate
	local st1, st2 = skills.talent_1, skills.talent_2
	local asa = this.melee.attacks[1]
	local aa = this.ranged.attacks[1]
	local saa = this.timed_attacks.list[1]
	local sba = this.timed_attacks.list[2]
	local sua = this.timed_attacks.list[3]
	local brk, sta
	local shot_count = 0
	local area_damage_active = false
	local ult_start_cd = store.wave_group_number == 0
	local old_tombstone_time = this.hero.tombstone_show_time
	local old_tombstone_respawn_animation = this.hero.tombstone_respawn_animation

	this.health_bar.hidden = false

	asa.ts = store.tick_ts - asa.cooldown * (this.unit.cooldown_factor or 1)
	aa.ts = store.tick_ts - aa.cooldown * (this.unit.cooldown_factor or 1)
	saa.ts = store.tick_ts - saa.cooldown * (this.unit.cooldown_factor or 1)
	sba.ts = store.tick_ts - sba.cooldown * (this.unit.cooldown_factor or 1)
	sua.ts = store.tick_ts - sua.cooldown * (this.unit.cooldown_factor or 1)

	local function shoot_bullet(target, bullet_t, af, ai, xp_gain_factor)
		local bullet = E:create_entity(bullet_t)

		bullet.pos = V.vclone(this.pos)

		local offset = sua.bullet_start_offset[ai]

		bullet.pos.x = bullet.pos.x + (af and -1 or 1) * offset.x
		bullet.pos.y = bullet.pos.y + offset.y
		bullet.bullet.from = V.vclone(bullet.pos)
		bullet.bullet.to = V.vclone(target.pos)
		bullet.bullet.to.x = bullet.bullet.to.x + target.unit.hit_offset.x
		bullet.bullet.to.y = bullet.bullet.to.y + target.unit.hit_offset.y
		bullet.bullet.target_id = target.id
		bullet.bullet.source_id = this.id
		bullet.bullet.xp_dest_id = this.id
		bullet.bullet.xp_gain_factor = xp_gain_factor
		bullet.bullet.level = sua.level
		bullet.bullet.damage_min = aa.damage_min
		bullet.bullet.damage_max = aa.damage_max
		bullet.bullet.damage_factor = this.unit.damage_factor

		if st1.level > 0 then
			bullet.bullet.reduce_armor = st1.reduce_armor
		end

		if bullet_t == sc.bullet or bullet_t == su.bullet_skill_c then
			bullet.hp_pctg = sc.hp_pctg[sc.level]
			bullet.boss_hp_pctg = sc.boss_hp_pctg[sc.level]
			bullet.damage_cap = sc.damage_cap[sc.level]
		end

		if area_damage_active and shot_count >= st2.shot_count then
			shot_count = 0
			bullet.bullet.hit_payload = st2.aura
		end

		simulation:queue_insert_entity(bullet)
	end

	local function spawn_casings(attack)
		local c = E:create_entity(this.casing_controller)

		c.time_to_spawn = attack.casing_spawn_time
		c.amount_to_spawn = attack.casings_to_spawn
		c.animation_names = attack.animations_for_casings
		c.source_id = this.id
		c.sprite_id = 1
		c.spawn_origin = V.vclone(this.pos)

		simulation:queue_insert_entity(c)
	end

	while true do
		if ult_start_cd and store.wave_group_number > 0 then
			ult_start_cd = false
			sua.ts = store.tick_ts
		end

		if h.dead then
			local ddc = E:create_entity(this.death_dmg_controller)

			ddc.source_id = this.id

			simulation:queue_insert_entity(ddc)

			if band(h.last_damage_types, bor(DAMAGE_EAT)) ~= 0 then
				this.hero.tombstone_show_time = nil
				this.hero.tombstone_respawn_animation = nil
			end

			SU.y_hero_death_and_respawn(store, this)

			this.hero.tombstone_show_time = old_tombstone_time
			this.hero.tombstone_respawn_animation = old_tombstone_respawn_animation
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					break
				end

				this.max_mines_near = false
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			area_damage_active = st2.level > 0

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
			-- blocking
			elseif SU.soldier_go_back_step(store, this) then
			-- returning to slot
			else
				local acted = false

				if ready_to_use_skill(sua, store, this.unit.cooldown_factor) and this.soldier.target_id == nil then
					local trigger_target, targets = U.find_foremost_enemy(store, this.pos, 0, sua.max_range, 0, sua.vis_flags, sua.vis_bans)

					if not trigger_target or bolin_skip_ultimate(targets, sua) then
						SU.delay_attack(store, sua, fts(10))
					else
						local ultimate_aura = E:create_entity(su.aura_decal)

						ultimate_aura.pos = V.vclone(this.pos)
						ultimate_aura.target_id = this.id

						simulation:queue_insert_entity(ultimate_aura)

						local af = not (trigger_target.pos.x > this.pos.x)

						U.animation_start(this, sua.animations[1], af, store.tick_ts, false)

						local start_ts = store.tick_ts
						local sound_played = false

						sua.ts = start_ts

						repeat
							while not U.animation_finished(this, 1) do
								if this.unit.is_stunned or this.health.dead or this.nav_rally.new then
									SU.delay_attack(store, sua, fts(10))

									break
								end

								if store.tick_ts - start_ts > sua.sound_time and not sound_played then
									sound_played = true

									S:queue(sua.sound_taunt)
									S:queue(sua.sound)
								end

								coroutine.yield()
							end

							if this.unit.is_stunned or this.health.dead or this.nav_rally.new then
								break
							end

							local bullet_t = sc.level > 0 and su.bullet_skill_c or su.bullet
							local aborted = false

							for i = 1, sua.shot_count do
								local j = i

								if i ~= 1 and i ~= sua.shot_count then
									j = 2
								elseif i == sua.shot_count then
									j = 3
								end

								local target = U.find_foremost_enemy(store, this.pos, 0, sua.max_range, 0, sua.vis_flags, sua.vis_bans)

								if not target then
									sua.ts = store.tick_ts
									aborted = true

									break
								end

								local an, flip, ai = U.animation_name_facing_point(this, sua.animation, target.pos, 1)

								an = "powershoot" .. an .. j

								U.animation_start(this, an, flip, store.tick_ts, false, 1)

								if i == 1 then
									U.y_wait(store, sua.shoot_time)
								end

								shoot_bullet(target, bullet_t, flip, ai, nil)

								if area_damage_active then
									shot_count = shot_count + 1
								end

								while not U.animation_finished(this, 1) do
									if this.unit.is_stunned or this.health.dead or this.nav_rally.new then
										sua.ts = store.tick_ts
										aborted = true

										break
									end

									coroutine.yield()
								end

								if aborted then
									break
								end
							end

							if not aborted then
								spawn_casings(sua)

								SU.hero_gain_xp_from_skill(this, su)

								sua.ts = store.tick_ts
							end
						until true

						simulation:queue_remove_entity(ultimate_aura)

						acted = true
					end
				end

				if not acted and ready_to_use_skill(saa, store, this.unit.cooldown_factor) then
					local pred_time = 2 * math.sqrt(2 * 170 * 1000) / 1000
					local first, targets = U.find_foremost_enemy(store, this.pos, saa.min_range, saa.max_range, pred_time, saa.vis_flags, saa.vis_bans)
					local destinations = first and bolin_mortar_positions(first, saa.bullet_count, saa.mortar_gap, pred_time)

					if not first or #targets < saa.min_targets or not destinations or #destinations == 0 then
						SU.delay_attack(store, saa, fts(10))
					else
						local af = not (first.pos.x > this.pos.x)

						U.animation_start(this, saa.animation, af, store.tick_ts, false)
						U.y_wait(store, saa.shoot_time)
						S:queue(saa.sound)
						S:queue(saa.sound_hit, {
							delay = pred_time
						})

						local shooting_right = not this.render.sprites[1].flip_x
						local boffset = saa.bullet_start_offset

						for i = 1, saa.bullet_count do
							local b = E:create_entity(saa.bullet)

							b.bullet.damage_min = saa.damage_min
							b.bullet.damage_max = saa.damage_max
							b.bullet.damage_factor = this.unit.damage_factor
							b.bullet.flight_time = pred_time + 0.18 * (i - 1)
							b.pos.x = this.pos.x + boffset.x * (shooting_right and 1 or -1)
							b.pos.y = this.pos.y + boffset.y
							b.bullet.from = V.vclone(b.pos)
							b.bullet.to = destinations[i] or destinations[1]
							b.bullet.source_id = this.id

							simulation:queue_insert_entity(b)
						end

						while not U.animation_finished(this, 1) and not this.nav_rally.new do
							coroutine.yield()
						end

						SU.hero_gain_xp_from_skill(this, sa)

						saa.ts = store.tick_ts
						acted = true
					end
				end

				if not acted and ready_to_use_skill(aa, store, this.unit.cooldown_factor) and this.soldier.target_id == nil then
					local trigger_target, targets, pred_pos = U.find_foremost_enemy(store, this.pos, 0, aa.max_range, 0, aa.vis_flags, aa.vis_bans)

					if not trigger_target then
						SU.delay_attack(store, aa, fts(10))
					else
						local target_pos = V.vclone(pred_pos)
						local aborted = false

						spawn_casings(aa)

						local an, af, ai = U.animation_name_facing_point(this, aa.animation, trigger_target.pos, 1)

						U.animation_start(this, an, af, store.tick_ts, false, 1)

						local start_ts = store.tick_ts

						while store.tick_ts - start_ts < aa.shoot_time do
							if this.unit.is_stunned or this.health.dead or this.nav_rally.new then
								SU.delay_attack(store, aa, fts(10))
								aborted = true

								break
							end

							coroutine.yield()
						end

						if aborted then
						-- interrupted
						else
							if not store.entities[trigger_target.id] or trigger_target.health.dead then
								trigger_target, targets, pred_pos = U.find_foremost_enemy(store, this.pos, 0, aa.max_range, 0, aa.vis_flags, aa.vis_bans)

								if not trigger_target then
									SU.delay_attack(store, aa, fts(10))
									aborted = true
								else
									target_pos = V.vclone(pred_pos)
								end
							end
						end

						if not aborted then
							local bullet_t = sc.level > 0 and sc.bullet or aa.bullet
							local bullet = E:create_entity(bullet_t)

							bullet.pos = V.vclone(this.pos)

							local offset = aa.bullet_start_offset[ai]

							bullet.pos.x = bullet.pos.x + (af and -1 or 1) * offset.x
							bullet.pos.y = bullet.pos.y + offset.y
							bullet.bullet.from = V.vclone(bullet.pos)
							bullet.bullet.to = vec_2(target_pos.x + trigger_target.unit.hit_offset.x, target_pos.y + trigger_target.unit.hit_offset.y)
							bullet.bullet.target_id = trigger_target.id
							bullet.bullet.source_id = this.id
							bullet.bullet.xp_dest_id = this.id
							bullet.bullet.xp_gain_factor = 1.6
							bullet.bullet.level = aa.level
							bullet.bullet.damage_min = aa.damage_min
							bullet.bullet.damage_max = aa.damage_max
							bullet.bullet.damage_factor = this.unit.damage_factor

							if st1.level > 0 then
								bullet.bullet.reduce_armor = st1.reduce_armor
							end

							if bullet_t == sc.bullet then
								bullet.hp_pctg = sc.hp_pctg[sc.level]
								bullet.boss_hp_pctg = sc.boss_hp_pctg[sc.level]
								bullet.damage_cap = sc.damage_cap[sc.level]
							end

							if area_damage_active and shot_count >= st2.shot_count then
								shot_count = 0
								bullet.bullet.hit_payload = st2.aura
							end

							simulation:queue_insert_entity(bullet)

							if area_damage_active then
								shot_count = shot_count + 1
							end

							aa.ts = store.tick_ts

							while not U.animation_finished(this, 1) do
								if this.unit.is_stunned or this.health.dead or this.nav_rally.new then
									SU.delay_attack(store, aa, fts(10))

									break
								end

								coroutine.yield()
							end

							acted = true
						end
					end
				end

				if not acted and not sba.disabled and ready_to_use_skill(sba, store, this.unit.cooldown_factor) and this.soldier.target_id == nil and not this.max_mines_near and store.wave_group_number > 0 then
					local target = U.find_foremost_enemy(store, this.pos, 0, sba.max_range, 0, sba.vis_flags, sba.vis_bans)

					if target then
						SU.delay_attack(store, sba, fts(10))
					else
						local near_mines = table.filter(store.entities, function(k, v)
							return v.template_name == "aura_bolin_skill_b_trigger" and V.dist2(v.pos.x, v.pos.y, this.pos.x, this.pos.y) <= sba.max_range * sba.max_range
						end)

						if #near_mines >= sba.max_mines then
							this.max_mines_near = true

							SU.delay_attack(store, sba, fts(10))
						else
							local mine_pos = bolin_mine_pos(this, near_mines, sba)

							if not mine_pos then
								this.max_mines_near = true

								SU.delay_attack(store, sba, fts(10))
							else
								local all_mines = bolin_find_mines(store)

								if #all_mines >= sba.max_mines then
									local far_mines = table.filter(all_mines, function(k, v)
										return V.dist2(v.pos.x, v.pos.y, this.pos.x, this.pos.y) > sba.max_range * sba.max_range
									end)

									table.sort(far_mines, function(e1, e2)
										return V.dist2(e1.pos.x, e1.pos.y, this.pos.x, this.pos.y) > V.dist2(e2.pos.x, e2.pos.y, this.pos.x, this.pos.y)
									end)

									if far_mines[1] then
										far_mines[1].trigger = true
									end
								end

								local start_ts = store.tick_ts

								U.y_animation_play(this, sba.animations[1], nil, store.tick_ts, 1, nil)
								U.animation_start(this, sba.animations[2], nil, store.tick_ts, false, nil)

								if not SU.y_hero_wait(store, this, sba.throw_time) then
									local b = E:create_entity(sba.bullet)

									b.pos = V.vclone(this.pos)
									b.bullet.from = vec_2(this.pos.x + sba.bullet_start_offset.x, this.pos.y + sba.bullet_start_offset.y)
									b.bullet.to = V.vclone(mine_pos)
									b.bullet.source_id = this.id
									b.payload_damage_min = sb.damage_min[sb.level]
									b.payload_damage_max = sb.damage_max[sb.level]

									simulation:queue_insert_entity(b)
									SU.y_hero_animation_wait(this)
									U.y_animation_play(this, sba.animations[3], nil, store.tick_ts, 1, nil)

									sba.ts = start_ts

									SU.hero_gain_xp_from_skill(this, sb)
								end

								acted = true
							end
						end
					end
				end

				if not acted then
					SU.soldier_idle(store, this)
					SU.soldier_regen(store, this)
				end
			end
		end

		coroutine.yield()
	end
end

local tt

tt = RT("hero_bolin_kr6", "hero")

AC(tt, "melee", "ranged", "timed_attacks")

tt.hero.level_stats.armor = {0.05, 0.06, 0.07, 0.08, 0.09, 0.1, 0.11, 0.12, 0.13, 0.15}
tt.hero.level_stats.hp_max = {170, 180, 190, 200, 210, 220, 230, 240, 250, 260}
tt.hero.level_stats.melee_damage_min = {8, 9, 10, 10, 11, 12, 13, 14, 14, 15}
tt.hero.level_stats.melee_damage_max = {12, 13, 14, 16, 17, 18, 19, 20, 22, 23}
tt.hero.level_stats.ranged_damage_min = {20, 22, 24, 26, 28, 30, 32, 34, 36, 38}
tt.hero.level_stats.ranged_damage_max = {30, 33, 36, 39, 42, 45, 48, 52, 54, 57}
tt.hero.skills.skill_a = CC("hero_skill")
tt.hero.skills.skill_a.cooldown = 16
tt.hero.skills.skill_a.damage_min = {10, 15, 20}
tt.hero.skills.skill_a.damage_max = {15, 20, 25}
tt.hero.skills.skill_a.slow_factor = 0.6
tt.hero.skills.skill_a.xp_gain = {64, 128, 192}
tt.hero.skills.skill_a.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.skill_b = CC("hero_skill")
tt.hero.skills.skill_b.cooldown = 6
tt.hero.skills.skill_b.damage_min = {12, 17, 24}
tt.hero.skills.skill_b.damage_max = {18, 28, 36}
tt.hero.skills.skill_b.max_mines = {4, 6, 8}
tt.hero.skills.skill_b.xp_gain = {24, 24, 24}
tt.hero.skills.skill_b.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.skill_c = CC("hero_skill")
tt.hero.skills.skill_c.disabled = true
tt.hero.skills.skill_c.bullet = "bullet_bolin_skill_c"
tt.hero.skills.skill_c.hp_pctg = {0.01, 0.02, 0.03}
tt.hero.skills.skill_c.boss_hp_pctg = {0.002, 0.004, 0.006}
tt.hero.skills.skill_c.damage_cap = {50, 50, 50}
tt.hero.skills.skill_c.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.cooldown = 35
tt.hero.skills.ultimate.level = 1
tt.hero.skills.ultimate.min_targets = 3
tt.hero.skills.ultimate.min_hp = 500
tt.hero.skills.ultimate.range = 200
tt.hero.skills.ultimate.shot_count = 8
tt.hero.skills.ultimate.aura_decal = "decal_bolin_ultimate"
tt.hero.skills.ultimate.bullet = "bullet_bolin_ultimate"
tt.hero.skills.ultimate.bullet_skill_c = "bullet_bolin_ultimate_skill_c"
tt.hero.skills.ultimate.xp_gain = {140}
tt.hero.skills.ultimate.xp_level_steps = {
	[5] = 1
}
tt.hero.skills.talent_1 = CC("hero_skill")
tt.hero.skills.talent_1.reduce_armor = 0.25
tt.hero.skills.talent_1.disabled = true
tt.hero.skills.talent_1.xp_level_steps = {
	[1] = 1
}
tt.hero.skills.talent_2 = CC("hero_skill")
tt.hero.skills.talent_2.shot_count = 5
tt.hero.skills.talent_2.aura = "aura_bolin_talent_2_area_damage"
tt.hero.skills.talent_2.disabled = true
tt.hero.skills.talent_2.xp_level_steps = {
	[1] = 1
}
tt.health.armor = nil
tt.health.dead_lifetime = 15
tt.health.hp_max = nil
tt.health_bar.offset = vec_2(0, 39)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_bolin_kr6_level_up
tt.hero.respawn_animation = "levelup"
tt.info.hero_portrait = "kr6_hero_portraits_0003"
tt.info.portrait = "kr6_info_portraits_heroes_0004"
tt.main_script.update = hero_bolin_kr6_update
tt.motion.max_speed = 60
tt.regen.cooldown = 1
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].angles.shoot = {"shoot", "shootup", "shootdown"}
tt.render.sprites[1].angles.powershoot = {"", "up", "down"}
tt.render.sprites[1].angles_custom = {
	shoot = {35, 145, 215, 325},
	powershoot = {35, 145, 215, 325}
}
tt.render.sprites[1].angles_flip_vertical = {
	powershoot = true,
	shoot = true
}
tt.render.sprites[1].prefix = "bolinDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].draw_order = DO_HEROES
tt.render.sprites[1].scale = vec_2(1, 1)
tt.sound_events.change_rally_point = "HeroBolinTaunt"
tt.sound_events.death = "HeroBolinDeath"
tt.sound_events.respawn = "HeroBolinTauntIntro"
tt.sound_events.hero_room_select = "HeroBolinTauntSelect"
tt.sound_events.level_up = "HeroBolinTauntLevelUp"
tt.soldier.melee_slot_offset = vec_2(5, 0)
tt.ui.click_rect = r(-19, -5, 40, 35)
tt.unit.hit_offset = vec_2(0, 12)
tt.unit.marker_offset = vec_2(0, -1)
tt.unit.mod_offset = vec_2(0, 19.9)
tt.unit.pop_offset = vec_2(0, 15)
tt.casing_controller = "controller_bolin_spawn_casing"
tt.death_dmg_controller = "controller_bolin_death_explosion"
tt.max_mines_near = false
tt.melee.cooldown = 1
tt.melee.range = 40
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].animation = "melee"
tt.melee.attacks[1].loops = false
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 2
tt.melee.attacks[1].hit_offset = vec_2(30, 20)
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animation = "shoot"
tt.ranged.attacks[1].bullet = "bullet_bolin"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(20, 15), vec_2(8, 8), vec_2(4, 0)}
tt.ranged.attacks[1].cooldown = 2.75
tt.ranged.attacks[1].min_range = 70
tt.ranged.attacks[1].max_range = 200
tt.ranged.attacks[1].shoot_time = fts(19)
tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
tt.ranged.attacks[1].shared_cooldown = true
tt.ranged.attacks[1].chance = 1
tt.ranged.attacks[1].node_prediction = fts(8) + fts(15)
tt.ranged.attacks[1].casings_to_spawn = 1
tt.ranged.attacks[1].casing_spawn_time = fts(47)
tt.ranged.attacks[1].animations_for_casings = {"shoot", "shootup", "shootdown"}
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].animation = "mortarskill"
tt.timed_attacks.list[1].bullet_count = 3
tt.timed_attacks.list[1].bullet = "bullet_bolin_skill_a"
tt.timed_attacks.list[1].bullet_start_offset = vec_2(12, 32)
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[1].vis_flags = 0
tt.timed_attacks.list[1].cooldown = 16
tt.timed_attacks.list[1].min_targets = 3
tt.timed_attacks.list[1].min_range = 200
tt.timed_attacks.list[1].max_range = 300
tt.timed_attacks.list[1].damage_min = 10
tt.timed_attacks.list[1].damage_max = 15
tt.timed_attacks.list[1].mortar_gap = 10
tt.timed_attacks.list[1].sound = "HeroBolinSmokeMortarCast"
tt.timed_attacks.list[1].sound_hit = "HeroBolinSmokeMortarTripleImpact"
tt.timed_attacks.list[1].shoot_time = fts(45)
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].animations = {"mineskillstart", "mineskillloop", "mineskillend"}
tt.timed_attacks.list[2].bullet = "bullet_bolin_skill_b"
tt.timed_attacks.list[2].bullet_start_offset = vec_2(8, 35)
tt.timed_attacks.list[2].cooldown = 6
tt.timed_attacks.list[2].min_range = 40
tt.timed_attacks.list[2].max_range = 120
tt.timed_attacks.list[2].throw_time = fts(16)
tt.timed_attacks.list[2].max_mines = 4
tt.timed_attacks.list[2].min_dist_between_mines = 30
tt.timed_attacks.list[3] = CC("custom_attack")
tt.timed_attacks.list[3].animation = "powershoot"
tt.timed_attacks.list[3].animations = {"powerstart", "powershoot"}
tt.timed_attacks.list[3].bullet_start_offset = {vec_2(20, 15), vec_2(8, 8), vec_2(4, 0)}
tt.timed_attacks.list[3].cooldown = 35
tt.timed_attacks.list[3].min_targets = 3
tt.timed_attacks.list[3].min_hp = 500
tt.timed_attacks.list[3].max_range = 200
tt.timed_attacks.list[3].sound = "HeroBolinSuppresiveFireCastDrink"
tt.timed_attacks.list[3].sound_taunt = "HeroBolinTauntUltimate"
tt.timed_attacks.list[3].sound_time = fts(11)
tt.timed_attacks.list[3].shoot_time = fts(6)
tt.timed_attacks.list[3].shot_count = 8
tt.timed_attacks.list[3].casings_to_spawn = 8
tt.timed_attacks.list[3].casing_spawn_time = fts(18)
tt.timed_attacks.list[3].animations_for_casings = {"powershoot3", "powershootup3", "powershootdown3"}
tt.timed_attacks.list[3].vis_flags = F_RANGED
tt.timed_attacks.list[3].vis_bans = 0
tt.timed_attacks.list[3].disabled = true

tt = RT("ps_bullet_bolin_casing", "particle_system")
tt.particle_system.name = "bolin_casing_trail_animations_trail"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.z = Z_BULLET_PARTICLES
tt.particle_system.particle_lifetime = {fts(13), fts(13)}
tt.particle_system.emission_rate = 10
tt.particle_system.emit_rotation_spread = math.pi
tt.particle_system.emit_area_spread = vec_2(3, 3)

tt = RT("ps_bullet_bolin_skill_a", "particle_system")
tt.particle_system.name = "bolin_mortar_trail_animations_trail"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.z = Z_BULLET_PARTICLES
tt.particle_system.particle_lifetime = {fts(16), fts(16)}
tt.particle_system.emission_rate = 15
tt.particle_system.emit_rotation_spread = math.pi / 2
tt.particle_system.emit_area_spread = vec_2(3, 3)

tt = RT("fx_bullet_bolin", "fx")
tt.render.sprites[1].prefix = "bolin_hitfxDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].draw_order = 4
tt.allow_rotation = true

tt = RT("fx_bolin_bullet_casing")
AC(tt, "pos", "render", "main_script", "tween")
tt.render.sprites[1].prefix = "bolin_casing_animations"
tt.render.sprites[1].name = "spin"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[1].draw_order = DO_MOD_FX
tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
tt.tween.props[1].keys = {{0, 255}, {1, 0}}
tt.tween.props[1].loop = false
tt.tween.props[1].name = "alpha"
tt.tween.remove = true
tt.tween.disabled = true
tt.particles_name = "ps_bullet_bolin_casing"
tt.rest_anim = "land"
tt.initial_direction_v = vec_2(0.27, 1)
tt.initial_speed = 220
tt.g = -1000
tt.elasticity = 0.8
tt.bounces = 1
tt.friction_threshold = 10
tt.main_script.update = fx_bolin_bullet_casing_update
tt.y_origin = 0

tt = RT("fx_aura_bolin_skill_a_slow", "fx")
AC(tt, "main_script", "tween")
tt.render.sprites[1].prefix = "bolin_mortar_smokeDef"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].offset = vec_2(-18, -15)
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[1].scale = vec_2(1.5, 1.5)
tt.tween.props[1].keys = {{0, 0}, {2, 255}}
tt.tween.props[1].loop = false
tt.tween.props[1].name = "alpha"
tt.tween.remove = true
tt.tween.disabled = true
tt.animation_in = "start"
tt.animation_loop = "loop"
tt.loop_time = 4
tt.main_script.update = scripts.fx_utils.in_loop_out
tt.main_script.remove = scripts.tween_utils.reverse_remove

tt = RT("fx_bullet_bolin_skill_c", "fx")
tt.render.sprites[1].prefix = "bolin_giantslayer_animations"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].draw_order = 5
tt.allow_rotation = false

tt = RT("decal_bolin_tombstone", "decal_tween")
tt.render.sprites[1].prefix = "bolinDef"
tt.render.sprites[1].name = "deathidle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true
tt.tween.props[1].keys = {{0, 0}, {fts(1), 0}}
tt.tween.disabled = true

tt = RT("decal_bolin_crater", "decal_tween")
AC(tt, "main_script")
tt.render.sprites[1].name = "bolin_mine_decal_animations"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 0}, {1, 255}}
tt.tween.remove = false
tt.tween.disabled = false
tt.tween.run_once = true
tt.wait_time = 4
tt.main_script.remove = scripts.tween_utils.reverse_remove
tt.main_script.update = scripts.tween_utils.wait_update

tt = RT("decal_bolin_ultimate", "decal_tween")
AC(tt, "main_script")
tt.render.sprites[1].prefix = "bolin_ulti_decalDef"
tt.render.sprites[1].name = "Idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}
tt.tween.props[1].name = "alpha"
tt.tween.props[1].reverse = false
tt.tween.disabled = false
tt.tween.remove = false
tt.tween.reverse = false
tt.tween.run_once = true
tt.main_script.remove = scripts.tween_utils.reverse_remove
tt.main_script.update = scripts.decal_utils.track_target_update

tt = RT("bullet_bolin", "bullet")
tt.main_script.update = bullet_bolin_update
tt.bullet.damage_min = nil
tt.bullet.damage_max = nil
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.reduce_armor = 0
tt.bullet.hit_blood_fx = nil
tt.bullet.hit_fx = "fx_bullet_bolin"
tt.sound_events.insert = "HeroBolinBasicAttackCast"

tt = RT("bullet_bolin_skill_a", "bomb")
tt.bullet.particles_name = "ps_bullet_bolin_skill_a"
tt.bullet.damage_min = nil
tt.bullet.damage_max = nil
tt.bullet.damage_type = DAMAGE_EXPLOSION
tt.bullet.damage_radius = 50
tt.bullet.damage_flags = 0
tt.bullet.g = -1000
tt.bullet.fixed_height = 170
tt.bullet.payload = "aura_bolin_skill_a_slow"
tt.bullet.hit_decal = "decal_bolin_crater"
tt.bullet.hit_fx = "fx_aura_bolin_skill_a_slow"
tt.bullet.hit_fx_water = nil
tt.bullet.hide_radius = nil
tt.bullet.pop = nil
tt.bullet.damage_decay_random = false
tt.sound_events.insert = nil
tt.render.sprites[1].prefix = "bolin_mortar_animations"
tt.render.sprites[1].name = "flyspin"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS
tt.main_script.insert = bullet_bolin_skills_parabola_insert
tt.main_script.update = bullet_bolin_skills_parabola_update
tt.exit_animation = "explode"
tt.exit_z = Z_OBJECTS
tt.change_z_midflight = Z_BULLETS
tt.change_z_time = fts(5)

tt = RT("bullet_bolin_skill_b", "bomb")
tt.bullet.level = 1
tt.bullet.damage_min = nil
tt.bullet.damage_max = nil
tt.bullet.damage_type = nil
tt.bullet.g = -1000
tt.bullet.fixed_height = 20
tt.bullet.payload = "aura_bolin_skill_b_trigger"
tt.bullet.hit_decal = nil
tt.bullet.hit_fx = nil
tt.bullet.hit_fx_water = nil
tt.bullet.pop = nil
tt.render.sprites[1].prefix = "bolin_mineDef"
tt.render.sprites[1].name = "flying"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.sound_events.insert = "HeroBolinMinefieldCastThrow"
tt.main_script.insert = bullet_bolin_skills_parabola_insert
tt.main_script.update = bullet_bolin_skills_parabola_update

tt = RT("bullet_bolin_skill_c", "bullet_bolin")
AC(tt, "render")
tt.main_script.update = bullet_bolin_skill_c_update
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].prefix = "bolin_giantslayer_trail_animations"
tt.render.sprites[1].name = "laser"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = vec_2(0.2, 0.5)
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.hit_fxs = {"fx_bullet_bolin", "fx_bullet_bolin_skill_c"}
tt.bullet.hit_time = fts(1)
tt.bullet.ignore_hit_offset = true
tt.sound_events.insert = "HeroBolinGiantSlayerAttack"
tt.hp_pctg = 0.01
tt.boss_hp_pctg = 0.002
tt.image_width = 110
tt.ray_duration = fts(33)
tt.hit_delay = fts(1)

tt = RT("bullet_bolin_ultimate", "bullet_bolin")
AC(tt, "render")
tt.main_script.update = bullet_bolin_ultimate_update
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].prefix = "bolin_ulti_trail_animations"
tt.render.sprites[1].name = "laser"
tt.render.sprites[1].loop = false
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.hit_fxs = {"fx_bullet_bolin"}
tt.bullet.hit_time = fts(1)
tt.sound_events.insert = "HeroBolinBasicAttackCast"
tt.image_width = 165
tt.ray_duration = fts(33)
tt.hit_delay = fts(1)

tt = RT("bullet_bolin_ultimate_skill_c", "bullet_bolin")
AC(tt, "render")
tt.main_script.update = bullet_bolin_skill_c_update
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].prefix = "bolin_ulti_trail_animations"
tt.render.sprites[1].name = "laser"
tt.render.sprites[1].loop = false
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.hit_fxs = {"fx_bullet_bolin", "fx_bullet_bolin_skill_c"}
tt.bullet.hit_time = fts(1)
tt.sound_events.insert = "HeroBolinGiantSlayerAttack"
tt.hp_pctg = 0.01
tt.boss_hp_pctg = 0.002
tt.image_width = 165
tt.ray_duration = fts(33)
tt.hit_delay = fts(1)

tt = RT("aura_bolin_death_damage", "aura")
tt.aura.radius = 70
tt.aura.vis_flags = bor(F_AREA, F_ENEMY)
tt.aura.vis_bans = bor(F_FRIEND)
tt.aura.damage_min = 20
tt.aura.damage_max = 30
tt.aura.damage_type = DAMAGE_EXPLOSION
tt.main_script.update = bolin_area_damage_update

tt = RT("aura_bolin_skill_a_slow", "aura")
tt.aura.mod = "mod_bolin_skill_a_slow"
tt.aura.radius = 60
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.aura.cycle_time = 0.5
tt.aura.duration_conf = 0.5
tt.aura.duration = 4
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update

tt = RT("aura_bolin_skill_b_trigger", "aura")
AC(tt, "render")
tt.aura.level = 1
tt.aura.radius = 45
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans_trigger = bor(F_FLYING, F_FRIEND)
tt.aura.vis_bans = bor(F_FRIEND)
tt.aura.mod = nil
tt.render.sprites[1].prefix = "bolin_mineDef"
tt.render.sprites[1].name = "spawn"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = false
tt.trigger = false
tt.damage_min = 12
tt.damage_max = 18
tt.trigger_radius = 30
tt.damage_type = DAMAGE_EXPLOSION
tt.main_script.update = aura_bolin_skill_b_trigger_update
tt.hit_decal = "decal_bolin_crater"
tt.sound_hit = "HeroBolinMinefieldExplosion"
tt.sound_events.insert = "HeroBolinMinefieldCastArmed"
tt.sound_events.insert_args = {
	delay = fts(30)
}

tt = RT("aura_bolin_talent_2_area_damage", "aura")
tt.aura.radius = 50
tt.aura.vis_flags = bor(F_AREA, F_ENEMY)
tt.aura.vis_bans = bor(F_FRIEND)
tt.aura.damage_min = 24
tt.aura.damage_max = 36
tt.aura.damage_type = DAMAGE_EXPLOSION
tt.main_script.update = bolin_area_damage_update

tt = RT("mod_bolin_skill_a_slow", "mod_slow")
tt.slow.factor = 0.6
tt.modifier.duration = 0.5
tt.modifier.vis_flags = bor(F_MOD)
tt.modifier.vis_bans = 0
tt.main_script.insert = scripts.mod_slow.insert

tt = RT("controller_bolin_spawn_casing")
AC(tt, "pos", "main_script")
tt.main_script.update = controller_bolin_spawn_casing_update
tt.casing = "fx_bolin_bullet_casing"
tt.sound = "HeroBolinSuppresiveFireCastReload"
tt.sprite_id = 0
tt.time_to_spawn = 0
tt.amount_to_spawn = 0
tt.source_id = nil
tt.spawn_origin = nil
tt.spawn_offset = vec_2(2, 4)

tt = RT("controller_bolin_death_explosion")
AC(tt, "main_script")
tt.main_script.update = controller_bolin_death_explosion_update
tt.aura = "aura_bolin_death_damage"
tt.source_id = nil
tt.time_to_spawn = fts(64)
