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
local v = V.v
local tt

local function decal_lilith_soul_eater_ball_update(this, store)
	local sp = this.render.sprites[1]
	local fm = this.force_motion
	local source = store.entities[this.source_id]
	local hero = store.entities[this.target_id]
	local initial_pos, initial_dest
	local initial_h = 0
	local dest_h = hero.unit.hit_offset.y
	local max_dist
	local last_pos = v(0, 0)

	local function move_step(dest)
		local dx, dy = V.sub(dest.x, dest.y, this.pos.x, this.pos.y)
		local dist = V.len(dx, dy)

		max_dist = math.max(dist, max_dist)

		local phase = km.clamp(0, 1, 1 - dist / max_dist)
		local df = (not fm.ramp_radius or dist > fm.ramp_radius) and 1 or math.max(dist / fm.ramp_radius, 0.1)

		fm.a.x, fm.a.y = V.add(fm.a.x, fm.a.y, V.trim(fm.max_a, V.mul(fm.a_step * df, dx, dy)))
		fm.v.x, fm.v.y = V.add(fm.v.x, fm.v.y, V.mul(store.tick_length, fm.a.x, fm.a.y))
		fm.v.x, fm.v.y = V.trim(fm.max_v, fm.v.x, fm.v.y)

		local sx, sy = V.mul(store.tick_length, fm.v.x, fm.v.y)

		this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, sx, sy)
		fm.a.x, fm.a.y = V.mul(-0.05 / store.tick_length, fm.v.x, fm.v.y)
		sp.offset.y = SU.parabola_y(phase, initial_h, dest_h, fm.max_flight_height)
		sp.r = V.angleTo(this.pos.x - last_pos.x, this.pos.y + sp.offset.y - last_pos.y)
		last_pos.x, last_pos.y = this.pos.x, this.pos.y + sp.offset.y

		return dist < 2 * fm.max_v * store.tick_length
	end

	if not source or not hero then
		log.debug("source or hero entity not found for decal_lilith_soul_eater_ball")
	else
		this.pos.x, this.pos.y = source.pos.x, source.pos.y

		if source.unit and source.unit.hit_offset then
			initial_h = source.unit.hit_offset.y
		end

		this.dest = hero.pos
		initial_pos = V.vclone(this.pos)
		initial_dest = V.vclone(hero.pos)
		initial_h = initial_h + 18
		fm.a.x, fm.a.y = 0, 3.5
		last_pos.x, last_pos.y = this.pos.x, this.pos.y + sp.offset.y
		max_dist = V.len(initial_dest.x - initial_pos.x, initial_dest.y - initial_pos.y)

		while not hero.health.dead and not move_step(this.dest) do
			coroutine.yield()
		end

		if not hero.health.dead then
			local ma = hero.melee.attacks[1]
			local hero_damage_avg = (ma.damage_min + ma.damage_max) * 0.5
			local m = E:create_entity(this.hit_mod)

			m.pos = hero.pos
			m.modifier.source_id = this.id
			m.modifier.target_id = hero.id
			m.inflicted_damage_factor = 1 + this.stolen_damage * m.soul_eater_factor / hero_damage_avg
			m.tween.ts = store.tick_ts

			simulation:queue_insert_entity(m)

			local fx = E:create_entity(this.hit_fx)

			fx.pos = hero.pos
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].offset = hero.unit.mod_offset

			simulation:queue_insert_entity(fx)
			SU.hero_gain_xp_from_skill(hero, hero.hero.skills.soul_eater)
		end
	end

	simulation:queue_remove_entity(this)
end

local function aura_lilith_soul_eater_update(this, store)
	local a = this.aura
	local hero = store.entities[a.source_id]
	local last_ts = store.tick_ts

	if not hero then
		log.error("hero not found for aura_lilith_soul_eater")
		simulation:queue_remove_entity(this)

		return
	end

	while true do
		hero.soul_eater.active = store.tick_ts - hero.soul_eater.last_ts >= a.cooldown

		if not hero.health.dead and hero.soul_eater.active and store.tick_ts - last_ts >= a.cycle_time then
			last_ts = store.tick_ts

			local targets = U.find_enemies_in_range_filter_on(hero.pos, a.radius, a.vis_flags, a.vis_bans, function(e)
				return not table.contains(a.excluded_templates, e.template_name)
			end)

			if targets then
				for _, target in ipairs(targets) do
					local m = E:create_entity(a.mod)

					m.modifier.source_id = hero.id
					m.modifier.target_id = target.id

					simulation:queue_insert_entity(m)
				end
			end
		end

		coroutine.yield()
	end
end

local function mod_lilith_soul_eater_track_update(this, store)
	local hero = store.entities[this.modifier.source_id]

	if not hero then
		log.error("hero not found for mod_lilith_soul_eater")
	else
		this.modifier.ts = store.tick_ts

		while true do
			local target = store.entities[this.modifier.target_id]

			if not target or store.tick_ts - this.modifier.ts > this.modifier.duration then
				break
			end

			if target.health.dead and hero.soul_eater.active and target.melee and target.melee.attacks and not U.flag_has(target.health.last_damage_types, DAMAGE_NO_LIFESTEAL) then
				local ma = target.melee.attacks[1]
				local stolen_damage = (ma.damage_min + ma.damage_max) * 0.5
				local s = E:create_entity("decal_lilith_soul_eater_ball")

				s.target_id = hero.id
				s.source_id = target.id
				s.stolen_damage = stolen_damage

				simulation:queue_insert_entity(s)

				hero.soul_eater.last_ts = store.tick_ts

				break
			end

			coroutine.yield()
		end
	end

	simulation:queue_remove_entity(this)
end

local function meteor_lilith_update(this, store)
	local b = this.bullet
	local speed = b.max_speed

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) >= 2 * (speed * store.tick_length) do
		b.speed.x, b.speed.y = V.mul(speed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
		this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

		coroutine.yield()
	end

	local targets = U.find_enemies_in_range_filter_off(b.to, b.damage_radius, b.damage_flags, b.damage_bans)

	if targets then
		for _, target in ipairs(targets) do
			local d = E.assign_damage(b.damage_type, b.damage_max, this.id, target.id)

			queue_damage(store, d)
		end
	end

	S:queue(this.sound_events.hit)
	SU.insert_sprite(store, b.arrive_fx, b.to)
	SU.insert_sprite(store, b.arrive_decal, b.to)
	simulation:queue_remove_entity(this)
end

local function hero_lilith_ultimate_update(this, store)
	local function spawn_meteor(pi, spi, ni)
		spi = spi or math.random(1, 3)

		local pos = P:node_pos(pi, spi, ni)

		pos.x = pos.x + math.random(-4, 4)
		pos.y = pos.y + math.random(-5, 5)

		local b = E:create_entity(this.meteor_bullet)

		b.bullet.from = V.v(pos.x + math.random(140, 170), pos.y + REF_H)
		b.bullet.to = pos

		b.pos:copy(b.bullet.from)

		b.bullet.damage_factor = this.damage_factor

		simulation:queue_insert_entity(b)
	end

	local pi, spi, ni
	local nearest = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)

	if #nearest < 1 then
		log.error("could not find node to fire lilith ultimate")
	else
		pi, spi, ni = unpack(nearest[1])

		if this.is_meteor then
			local seq = {}

			for i = 1, this.meteor_node_spread do
				seq[i] = i
			end

			spawn_meteor(pi, spi, ni)

			while #seq > 0 do
				local delay = U.frandom(0.15, 0.3)
				local i = table.remove(seq, math.random(1, #seq))
				local can_up, can_down = P:is_node_valid(pi, ni + i), P:is_node_valid(pi, ni - i)

				U.y_wait_unconditional(store, delay * 0.5)

				if can_up then
					spawn_meteor(pi, nil, ni + i)
				elseif can_down then
					spawn_meteor(pi, nil, ni - i)
				end

				U.y_wait_unconditional(store, delay * 0.5)

				if can_down then
					spawn_meteor(pi, nil, ni - i)
				elseif can_up then
					spawn_meteor(pi, nil, ni + i)
				end
			end
		else
			local node = {
				spi = 1,
				pi = nearest[1][1],
				ni = nearest[1][3]
			}
			local node_pos = P:node_pos(node.pi, node.spi, node.ni)
			local target, targets = U.find_foremost_enemy_in_range_filter_off(this.pos, this.angel_range, fts(10), this.angel_vis_flags, this.angel_vis_bans)
			local idx = 1

			for i = 1, this.angel_count do
				local e = E:create_entity(this.angel_entity)

				if targets then
					target = targets[km.zmod(idx, #targets)]
					idx = idx + 1

					if band(target.vis.bans, F_STUN) == 0 and band(target.vis.flags, F_BOSS) == 0 then
						local m = E:create_entity(this.angel_mod)

						m.modifier.target_id = target.id
						m.modifier.source_id = this.id

						simulation:queue_insert_entity(m)
					end

					if band(target.vis.flags, F_BLOCK) ~= 0 then
						U.block_enemy(store, e, target)
					else
						e.unblocked_target_id = target.id
					end

					local lpos, lflip = U.melee_slot_position(e, target, 1, math.random() < 0.5)

					e.pos.x, e.pos.y = lpos.x, lpos.y
					e.render.sprites[1].flip_x = lflip
				else
					local nni = node.ni + math.random(-10, 10)
					local nspi = math.random(1, 3)
					local npos = P:node_pos(node.pi, nspi, nni)

					if not P:is_node_valid(node.pi, nni) or GR:cell_is(node_pos.x, node_pos.y, TERRAIN_FAERIE) then
						npos = node_pos
					end

					e.pos.x, e.pos.y = npos.x, npos.y
				end

				e.nav_rally.center = V.vclone(e.pos)
				e.nav_rally.pos = V.vclone(e.pos)

				simulation:queue_insert_entity(e)
				U.y_wait_unconditional(store, this.angel_delay)
			end
		end
	end

	simulation:queue_remove_entity(this)
end

local function hero_lilith_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
	this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

	local bt = E:get_template(this.ranged.attacks[1].bullet)

	bt.bullet.damage_min = ls.ranged_damage_min[hl]
	bt.bullet.damage_max = ls.ranged_damage_max[hl]

	upgrade_skill(this, "reapers_harvest", function(this, s)
		local a = this.melee.attacks[3]

		a.disabled = nil
		a.damage_min = s.damage[s.level]
		a.damage_max = s.damage[s.level]
		a = this.melee.attacks[4]
		a.disabled = nil
		a.damage_min = s.damage[s.level]
		a.damage_max = s.damage[s.level]
		a.chance = s.instakill_chance[s.level]
		a.origin_chance = s.instakill_chance[s.level]
	end)
	upgrade_skill(this, "soul_eater", function(this, s)
		local m = E:get_template("mod_lilith_soul_eater_damage_factor")

		m.soul_eater_factor = s.damage_factor[s.level]
	end)
	upgrade_skill(this, "infernal_wheel", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil

		local au = E:get_template(a.bullet)
		local m = E:get_template(au.aura.mod)

		m.dps.damage_min = s.damage[s.level]
		m.dps.damage_max = s.damage[s.level]
	end)
	upgrade_skill(this, "resurrection", function(this, s)
		local a = this.revive

		a.disabled = nil
		a.chance = s.chance[s.level]
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		this.ultimate.disabled = nil

		local u = E:get_template(s.controller_name)

		u.angel_count = s.angel_count[s.level]

		local e = E:get_template(u.angel_entity)

		e.melee.attacks[1].damage_max = s.angel_damage[s.level] * 2
		e.melee.attacks[1].damage_min = s.angel_damage[s.level] * 2

		local b = E:get_template(u.meteor_bullet)

		b.bullet.damage_max = s.meteor_damage[s.level]
	end)
	update_hp(this)
end

local function hero_lilith_insert(this, store)
	scripts.hero_basic.insert(this, store)

	local a = E:create_entity("aura_lilith_soul_eater")

	a.aura.source_id = this.id
	a.aura.ts = store.tick_ts
	a.pos = this.pos

	simulation:queue_insert_entity(a)

	return true
end

local function hero_lilith_update(this, store)
	local h = this.health
	local a, skill, brk, sta

	this.health_bar.hidden = false

	local function skill_come_into_cooldown(skill_attack, is_ultimate)
		if is_ultimate then
			skill_attack.ts = store.tick_ts - km.clamp(0, 1, this.revive.protect) * skill_attack.cooldown * 0.15
		else
			skill_attack.ts = store.tick_ts - km.clamp(0, 1, this.revive.protect) * skill_attack.cooldown * 0.4
		end
	end

	local function inc_instakill_chance()
		this.melee.attacks[4].chance = this.melee.attacks[4].origin_chance + 0.2 * km.clamp(0, 1, this.revive.protect)
	end

	local function update_color()
		local revive_rate = km.clamp(0, 1, this.revive.protect) * 100

		this.render.sprites[1].alpha = 155 + revive_rate
		this.render.sprites[1].color[3] = 255 - revive_rate
	end

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	while true do
		if h.dead then
			local chance_pass = math.random() < (this.revive.chance + this.revive.protect)

			if not this.revive.disabled and not U.flag_has(h.last_damage_types, bor(DAMAGE_EAT, DAMAGE_HOST, DAMAGE_DISINTEGRATE)) and chance_pass then
				h.ignore_damage = true
				h.dead = false
				h.hp = h.hp_max

				for _, s in ipairs(this.render.sprites) do
					s.hidden = false
				end

				S:queue(this.revive.sound)
				U.y_animation_play(this, this.revive.animation, nil, store.tick_ts, 1)

				this.health_bar.hidden = false
				this.ui.can_click = true
				h.ignore_damage = nil
				this.revive.protect = this.revive.protect * 0.5

				SU.hero_gain_xp_from_skill(this, this.hero.skills.resurrection)

				this.melee.attacks[3].ts = 0
				this.melee.attacks[4].ts = 0
				this.timed_attacks.list[1].ts = 0
			else
				SU.y_hero_death_and_respawn(store, this)
			end

			this.revive.ts = store.tick_ts
		end

		scripts.soldier_revive_resist(this, store)
		inc_instakill_chance()
		update_color()

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_167_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.infernal_wheel

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local target = U.find_random_enemy(store, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

				if not target then
					a.ts = a.ts + 0.13333333333333333
				else
					S:queue(a.sound)
					U.animation_start_default(this, a.animation, nil, store.tick_ts)

					if SU.y_soldier_wait(store, this, a.shoot_time) then
						goto label_167_0
					end

					SU.hero_gain_xp_from_skill(this, skill)
					skill_come_into_cooldown(a)

					local pos
					local nodes = P:nearest_nodes(target.pos.x, target.pos.y, nil, nil, true)

					if #nodes == 0 then
						pos = V.vclone(this.pos)
					else
						pos = P:node_pos(nodes[1][1], 1, nodes[1][3])
					end

					local b = E:create_entity(a.bullet)

					b.pos.x, b.pos.y = pos.x, pos.y
					b.aura.ts = store.tick_ts

					simulation:queue_insert_entity(b)
					SU.y_hero_animation_wait(this)

					goto label_167_0
				end
			end

			if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
				local target, target_num = find_target_at_critical_moment(this, this.ranged.attacks[1].max_range, F_RANGED, F_NONE)

				if target and target.pos and valid_land_node_nearby(target.pos) then
					U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
					S:queue(this.sound_events.change_rally_point)

					local e = E:create_entity(this.hero.skills.ultimate.controller_name)

					e.pos = V.vclone(target.pos)

					if target_num <= 1 then
						e.is_meteor = false
					else
						e.is_meteor = true
					end

					simulation:queue_insert_entity(e)
					skill_come_into_cooldown(this.ultimate, true)
					SU.hero_gain_xp_from_skill(this, this.ultimate)
				else
					this.ultimate.ts = this.ultimate.ts + 1
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
			-- block empty
			else
				brk, sta = SU.y_soldier_ranged_attacks(store, this)

				if brk then
				-- block empty
				elseif SU.soldier_go_back_step(store, this) then
				-- block empty
				else
					SU.soldier_idle(store, this)
					SU.soldier_regen(store, this)
				end
			end
		end

		::label_167_0::

		coroutine.yield()
	end
end

tt = RT("hero_lilith", "hero")

AC(tt, "melee", "ranged", "timed_attacks", "revive")

tt.hero.level_stats.armor = {0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55}
tt.hero.level_stats.hp_max = {240, 260, 280, 300, 320, 340, 360, 380, 400, 420}
tt.hero.level_stats.melee_damage_max = {14, 16, 17, 18, 19, 20, 22, 23, 24, 25}
tt.hero.level_stats.melee_damage_min = {10, 10, 11, 12, 13, 14, 14, 15, 16, 17}
tt.hero.level_stats.ranged_damage_max = {28, 32, 34, 36, 38, 40, 44, 46, 48, 50}
tt.hero.level_stats.ranged_damage_min = {20, 21, 22, 24, 26, 28, 29, 30, 32, 34}
tt.hero.skills.reapers_harvest = CC("hero_skill")
tt.hero.skills.reapers_harvest.damage = {110, 220, 330}
tt.hero.skills.reapers_harvest.instakill_chance = {0.1, 0.2, 0.3}
tt.hero.skills.reapers_harvest.xp_gain = {105, 210, 315}
tt.hero.skills.reapers_harvest.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.soul_eater = CC("hero_skill")
tt.hero.skills.soul_eater.damage_factor = {0.3, 0.6, 0.9}
tt.hero.skills.soul_eater.xp_gain = {10, 20, 30}
tt.hero.skills.soul_eater.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.infernal_wheel = CC("hero_skill")
tt.hero.skills.infernal_wheel.damage = {6, 12, 18}
tt.hero.skills.infernal_wheel.xp_gain = {30, 60, 120}
tt.hero.skills.infernal_wheel.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.resurrection = CC("hero_skill")
tt.hero.skills.resurrection.chance = {0.1, 0.2, 0.3}
tt.hero.skills.resurrection.xp_gain = {60, 120, 180}
tt.hero.skills.resurrection.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_lilith_ultimate"
tt.hero.skills.ultimate.angel_damage = {25, 32, 40, 50}
tt.hero.skills.ultimate.angel_count = {3, 4, 5, 6}
tt.hero.skills.ultimate.meteor_damage = {40, 80, 120, 160}
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.ultimate.xp_gain_factor = 40
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, 54)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_lilith_level_up
tt.hero.tombstone_show_time = fts(90)
tt.info.hero_portrait = "kr3_hero_portraits_0014"
tt.info.portrait = "kr3_info_portraits_heroes_0014"
tt.main_script.insert = hero_lilith_insert
tt.main_script.update = hero_lilith_update
tt.motion.max_speed = 3.3 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.1666
tt.render.sprites[1].prefix = "hero_lilith"
tt.render.sprites[1].alpha = 128
tt.render.sprites[1].color = {255, 255, 155}
tt.sound_events.change_rally_point = "ElvesHeroLilithTaunt"
tt.sound_events.death = "ElvesHeroLilithDeath"
tt.sound_events.insert = "ElvesHeroLilithTauntIntro"
tt.sound_events.respawn = "ElvesHeroLilithTauntIntro"
tt.sound_events.hero_room_select = "ElvesHeroLilithTauntSelect"
tt.unit.hit_offset = vec_2(0, 16)
tt.unit.mod_offset = vec_2(0, 22)
tt.revive.animation = "resurrection"
tt.revive.sound = "ElvesHeroLilithResurrection"
tt.revive.protect = 0.1
tt.revive.resist = {
	bans = bor(F_STUN, F_BLOOD, F_POISON, F_BURN),
	duration = 8,
	cost = 0.06,
	side_effect = function(this, store)
		this.melee.attacks[3].ts = 0
		this.melee.attacks[4].ts = 0
	end
}
tt.soul_eater = {}
tt.soul_eater.last_ts = 0
tt.soul_eater.active = true
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(14)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].xp_gain_factor = 3.2
tt.melee.attacks[1].side_effect = function(this, store, damage, target)
	this.revive.protect = this.revive.protect + 0.01
end
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[3] = CC("melee_attack")
tt.melee.attacks[3].side_effect = function(this, store, damage, target)
	this.revive.protect = this.revive.protect + 0.01
end
tt.melee.attacks[3].disabled = true
tt.melee.attacks[3].cooldown = 20
tt.melee.attacks[3].damage_type = bor(DAMAGE_TRUE, DAMAGE_NO_DODGE)
tt.melee.attacks[3].animation = "reapersHarvest"
tt.melee.attacks[3].hit_time = fts(30)
tt.melee.attacks[3].sound = "ElvesHeroLilithReapersHarvest"
tt.melee.attacks[3].sound_args = {
	delay = fts(7)
}
tt.melee.attacks[3].cooldown_group = "reapers_harvest"
tt.melee.attacks[3].xp_from_skill = "reapers_harvest"
tt.melee.attacks[3].hit_decal = "decal_lilith_reapers_harvest"
tt.melee.attacks[3].hit_offset = vec_2(30, 0)
tt.melee.attacks[4] = table.deepclone(tt.melee.attacks[3])
tt.melee.attacks[4].side_effect = function(this, store, damage, target)
	this.revive.protect = this.revive.protect + 0.02
	this.soul_eater.last_ts = store.tick_ts - E:get_template("aura_lilith_soul_eater").aura.cooldown

	U.heal(this, this.health.hp_max * 0.2)
end
tt.melee.attacks[4].damage_type = DAMAGE_INSTAKILL
tt.melee.attacks[4].chance = 0.1
tt.melee.attacks[4].origin_chance = 0.1
tt.melee.attacks[4].vis_bans = bor(F_BOSS)
tt.melee.attacks[4].vis_flags = bor(F_INSTAKILL)
tt.melee.cooldown = 1
tt.melee.range = 57.5
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animation = "throw"
tt.ranged.attacks[1].max_range = 170
tt.ranged.attacks[1].min_range = 20
tt.ranged.attacks[1].cooldown = 2
tt.ranged.attacks[1].bullet = "bullet_lilith"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(5, 40)}
tt.ranged.attacks[1].shoot_time = fts(28)
tt.ranged.attacks[1].node_prediction = fts(28)
tt.ranged.attacks[1].side_effect = function(this, store, attack, target)
	this.revive.protect = this.revive.protect + 0.015
end
tt.timed_attacks.list[1] = CC("aura_attack")
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].animation = "infernalWheel"
tt.timed_attacks.list[1].bullet = "aura_lilith_infernal_wheel"
tt.timed_attacks.list[1].cooldown = 22
tt.timed_attacks.list[1].shoot_time = fts(12)
tt.timed_attacks.list[1].range = 175
tt.timed_attacks.list[1].sound = "ElvesHeroLilithInfernalWheel"
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED)
tt.ultimate = {
	ts = 0,
	cooldown = 44,
	disabled = true
}
tt = RT("hero_lilith_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.main_script.update = hero_lilith_ultimate_update
tt.cooldown = 40
tt.angel_range = 125
tt.angel_entity = "soldier_lilith_angel"
tt.angel_mod = "mod_lilith_angel_stun"
tt.angel_delay = 0.5
tt.angel_vis_flags = bor(F_RANGED)
tt.angel_vis_bans = bor(F_FRIEND, F_FLYING)
tt.meteor_bullet = "meteor_lilith"
tt.meteor_chance = 0.5
tt.meteor_node_spread = 5
tt = RT("aura_lilith_infernal_wheel", "aura")

AC(tt, "render", "tween")

tt.aura.duration = 5
tt.aura.cycle_time = fts(10)
tt.aura.mod = "mod_lilith_infernal_wheel"
tt.aura.vis_flags = bor(F_RANGED, F_MOD)
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.aura.radius = 50
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.render.sprites[1].name = "lilith_infernal_base_decal_loop"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].loop = false
tt.render.sprites[2].name = "lilith_infernal_base_fireIn_loop"
tt.render.sprites[2].hide_after_runs = 1
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {fts(5), 255}, {"this.aura.duration-0.5", 255}, {"this.aura.duration", 0}}
tt = RT("mod_lilith_soul_eater_damage_factor", "modifier")

AC(tt, "render", "tween")

tt.modifier.duration = 12
tt.modifier.use_mod_offset = false
tt.modifier.allows_duplicates = true
tt.main_script.insert = scripts.mod_damage_factors.insert
tt.main_script.remove = scripts.mod_damage_factors.remove
tt.main_script.update = scripts.mod_track_target.update
tt.render.sprites[1].name = "lilith_soul_eater_decal_loop"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "fallen_angel_hero_soul_eater_sword"
tt.render.sprites[2].animated = false
tt.render.sprites[2].offset = vec_2(0, 12)
tt.render.sprites[3] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[3].offset = vec_2(-18, 22)
tt.render.sprites[4] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[4].offset = vec_2(18, 22)
tt.tween.remove = false
tt.tween.props[1] = CC("tween_prop")
tt.tween.props[1].keys = {{0, 0}, {0.3, 255}, {"this.modifier.duration-0.3", 255}, {"this.modifier.duration", 0}}

for i = 2, 4 do
	tt.tween.props[i] = table.deepclone(tt.tween.props[1])
	tt.tween.props[i].sprite_id = i
end

tt.tween.props[5] = CC("tween_prop")
tt.tween.props[5].name = "anchor"
tt.tween.props[5].keys = {{0, vec_2(0.5, 0.6538461538461539)}, {fts(12), vec_2(0.5, 0.34615384615384615)}, {fts(24), vec_2(0.5, 0.6538461538461539)}}
tt.tween.props[5].loop = true
tt.tween.props[5].interp = "sine"
tt.tween.props[5].sprite_id = 2
tt.tween.props[6] = table.deepclone(tt.tween.props[5])
tt.tween.props[6].sprite_id = 3
tt.tween.props[7] = table.deepclone(tt.tween.props[5])
tt.tween.props[7].sprite_id = 4
tt = RT("mod_lilith_infernal_wheel", "mod_lava")
tt.modifier.duration = fts(31)
tt.dps.damage_min = nil
tt.dps.damage_max = nil
tt.dps.damage_inc = 0
tt.dps.damage_every = fts(10)
tt = RT("aura_lilith_soul_eater", "aura")
tt.aura.duration = -1
tt.aura.cooldown = 15
tt.aura.cycle_time = fts(5)
tt.aura.radius = 200
tt.aura.vis_bans = bor(F_BOSS, F_FLYING)
tt.aura.vis_flags = bor(F_MOD, F_RANGED)
tt.aura.excluded_templates = {"enemy_hyena"}
tt.aura.mod = "mod_lilith_soul_eater_track"
tt.main_script.update = aura_lilith_soul_eater_update
tt = RT("meteor_lilith", "bullet")
tt.main_script.update = meteor_lilith_update
tt.bullet.damage_max = nil
tt.bullet.damage_radius = 45
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.arrive_decal = "decal_meteor_lilith_explosion"
tt.bullet.arrive_fx = "fx_meteor_lilith_explosion"
tt.bullet.max_speed = 1050
tt.bullet.mod = "mod_hero_elves_archer_slow"
tt.render.sprites[1].name = "fallen_angel_hero_ultimate_meteor"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.x = 0.9166666666666666
tt.sound_events.hit = "ElvesHeroLilithMeteorsHit"
tt = RT("bullet_lilith", "arrow")
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.flight_time = fts(10)
tt.bullet.hide_radius = 1
tt.bullet.hit_fx = "fx_lilith_ranged_hit"
tt.bullet.miss_fx = "fx_lilith_ranged_hit"
tt.bullet.miss_decal = nil
tt.bullet.particles_name = "ps_bullet_lilith_trail"
tt.bullet.xp_gain_factor = 3.2
tt.render.sprites[1].name = "fallen_angel_hero_proy_0001-f"
tt.sound_events.insert = "ElvesHeroLilithRangeShoot"
tt = RT("soldier_lilith_angel", "soldier_xin_shadow")
tt.angel_damage_type = DAMAGE_TRUE
tt.sound_events.insert = "ElvesHeroLilithAngelsCast"
tt.render.sprites[1].prefix = "lilith_ultimate_angel"
tt.max_attack_count = 2
tt.min_wait = 0
tt.max_wait = 0
tt.soldier.melee_slot_offset = vec_2(-13, 0)
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].damage_type = DAMAGE_TRUE
tt.melee.attacks[1].sound = "ElvesHeroLilithAngelsHit"
tt.melee.attacks[2] = nil
tt.melee.attacks[3] = nil
tt.melee.attacks[4] = nil
tt.melee.cooldown = 0
tt = RT("ps_bullet_lilith_trail")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "fallen_angel_hero_proy_particle"
tt.particle_system.particle_lifetime = {0.2, 0.2}
tt.particle_system.alphas = {255, 12}
tt.particle_system.scales_y = {0.8, 0.05}
tt.particle_system.emission_rate = 30
tt = RT("fx_meteor_lilith_explosion", "fx")
tt.render.sprites[1].name = "lilith_ultimate_meteor_explosion"
tt.render.sprites[1].anchor.y = 0.20930232558139536
tt.render.sprites[1].z = Z_OBJECTS
tt = RT("fx_lilith_soul_eater_ball_hit", "fx")
tt.render.sprites[1].name = "lilith_soul_eater_explosion_anim"
tt = RT("fx_lilith_ranged_hit", "fx")
tt.render.sprites[1].name = "fx_lilith_ranged_hit"
tt = RT("decal_meteor_lilith_explosion", "decal_tween")
tt.render.sprites[1].name = "stage4_fire_decal_0002"
tt.render.sprites[1].animated = false
tt.render.sprites[1].scale = vec_1(0.6)
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 130}, {2.5, 130}, {3.25, 0}}
tt = RT("decal_lilith_soul_eater_ball", "decal_scripted")

AC(tt, "force_motion", "sound_events")

tt.render.sprites[1].name = "lilith_soul_eater_ball_loop"
tt.render.sprites[1].offset.y = 10
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_DECALS
tt.force_motion.max_a = 5400
tt.force_motion.max_v = 240
tt.force_motion.max_flight_height = 60
tt.main_script.update = decal_lilith_soul_eater_ball_update
tt.hit_fx = "fx_lilith_soul_eater_ball_hit"
tt.hit_mod = "mod_lilith_soul_eater_damage_factor"
tt.sound_events.insert = "ElvesHeroLilithSoulEater"
tt = RT("decal_lilith_reapers_harvest", "decal_timed")
tt.render.sprites[1].name = "lilith_reapers_harvest_decal_anim"
tt.render.sprites[1].z = Z_DECALS
tt = RT("mod_lilith_angel_stun", "mod_stun")
tt.modifier.duration = fts(34)
tt = RT("mod_lilith_soul_eater_track", "modifier")
tt.main_script.update = mod_lilith_soul_eater_track_update
tt.modifier.duration = fts(11)
