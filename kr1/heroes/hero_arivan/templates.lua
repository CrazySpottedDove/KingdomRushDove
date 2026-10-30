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
local anchor_y = 0
local band = bit.band
local bor = bit.bor
local find_target_at_critical_moment = HU.find_target_at_critical_moment
local fts = U.fts
local level_up_basic = HU.level_up_basic
local queue_damage = U.queue_damage
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local valid_twister_node_nearby = HU.valid_twister_node_nearby
local tt

local function fireball_arivan_update(this, store)
	local b = this.bullet
	local mspeed = b.min_speed
	local ps

	S:queue(this.sound_events.summon)
	U.animation_start_default(this, "idle", nil, store.tick_ts, false)
	U.y_wait_unconditional(store, this.idle_time)

	ps = E:create_entity(b.particles_name)
	ps.particle_system.track_id = this.id

	simulation:queue_insert_entity(ps)
	S:queue(this.sound_events.travel)

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > 2 * (mspeed * store.tick_length) do
		coroutine.yield()

		mspeed = mspeed + FPS * math.ceil(mspeed * (1 / FPS) * b.acceleration_factor)
		mspeed = km.clamp(b.min_speed, b.max_speed, mspeed)
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
		this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

		if ps then
			ps.particle_system.emit_direction = this.render.sprites[1].r
		end
	end

	local targets = U.find_enemies_in_range_filter_off(b.to, b.damage_radius, b.damage_flags, b.damage_bans)

	if targets then
		for _, target in ipairs(targets) do
			local d = E.assign_damage(b.damage_type, U.frandom(b.damage_min, b.damage_max) * b.damage_factor, this.id, target.id)

			queue_damage(store, d)
		end
	end

	S:queue(this.sound_events.hit)

	if b.hit_fx then
		local fx = E:create_entity(b.hit_fx)

		fx.pos:copy(b.to)

		fx.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(fx)
	end

	coroutine.yield()
	simulation:queue_remove_entity(this)
end

local function aura_arivan_stone_dance_update(this, store)
	local rot_phase = 0
	local owner = store.entities[this.aura.source_id]

	if not owner then
		log.error("aura_arivan_stone_dance owner is missing.")
		simulation:queue_remove_entity(this)

		return
	end

	while true do
		if owner.health.dead and #this.stones > 1 then
			for i = #this.stones, 1, -1 do
				local stone = this.stones[i]
				local fx = E:create_entity("fx_arivan_stone_explosion")

				fx.pos = stone.pos
				fx.render.sprites[1].ts = store.tick_ts

				simulation:queue_insert_entity(fx)
				simulation:queue_remove_entity(stone)
				table.remove(this.stones, i)
			end
		end

		if this.shield_active then
			this.shield_active = false

			local s = this.render.sprites[1]

			s.hidden = false
			s.ts = store.tick_ts
			s.runs = 0
			s.flip_x = owner.render.sprites[1].flip_x
		end

		if store.tick_ts - this.aura.ts > fts(13) then
			rot_phase = rot_phase + this.rot_speed * store.tick_length
		end

		for i, t in ipairs(this.stones) do
			local a = (i * 2 * math.pi / this.max_stones + rot_phase) % (2 * math.pi)

			t.pos = U.point_on_ellipse(this.pos, this.rot_radius, a)
		end

		if #this.stones < 1 then
			U.bans_remove(owner.vis, this.owner_vis_bans)
		else
			U.bans_add(owner.vis, this.owner_vis_bans)
		end

		coroutine.yield()
	end
end

local function hero_arivan_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee_raw_min = ls.melee_damage_min[hl]
	this.melee_raw_max = ls.melee_damage_max[hl]

	local bt = E:get_template(this.ranged.attacks[1].bullet)

	bt.bullet.damage_min = ls.ranged_damage_min[hl]
	bt.bullet.damage_max = ls.ranged_damage_max[hl]

	upgrade_skill(this, "icy_prison", function(this, s)
		local a = this.ranged.attacks[3]

		a.disabled = nil

		local b = E:get_template(a.bullet)

		b.bullet.damage_min = s.damage[s.level]
		b.bullet.damage_max = s.damage[s.level]

		local m = E:get_template(b.bullet.mod)

		m.modifier.duration = s.duration[s.level]
	end)
	upgrade_skill(this, "lightning_rod", function(this, s)
		local a = this.ranged.attacks[2]

		a.disabled = nil

		local b = E:get_template(a.bullet)

		b.bullet.damage_min = s.damage_min[s.level]
		b.bullet.damage_max = s.damage_max[s.level]
	end)
	upgrade_skill(this, "seal_of_fire", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.loops = s.count[s.level]
	end)
	upgrade_skill(this, "stone_dance", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.ts = -a.cooldown + 2

		local aura = E:get_template("aura_arivan_stone_dance")

		aura.max_stones = s.count[s.level]
		this.stone_extra_per_stone = s.stone_extra[s.level]

		if a.aura then
			a.aura.max_stones = s.count[s.level]
			this.stone_extra = #a.aura.stones * this.stone_extra_per_stone
		end
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		this.ultimate.disabled = nil

		local u = E:get_template("hero_arivan_ultimate")
		local tal = u.timed_attacks.list
		local mf = E:get_template("mod_arivan_ultimate_freeze")

		u.aura.duration = s.duration[s.level]
		tal[2].damage_max = s.damage[s.level]
		tal[2].damage_min = s.damage[s.level]
		mf.modifier.duration = s.freeze_duration[s.level]
		tal[3].chance = s.freeze_chance[s.level]
		tal[4].cooldown = s.lightning_cooldown[s.level]
		tal[4].chance = s.lightning_chance[s.level]

		local thunder = E:get_template("lightning_arivan_ultimate")

		thunder.bullet.damage_min = s.damage[s.level]
		thunder.bullet.damage_max = s.damage[s.level]
	end)

	this.melee.attacks[1].damage_min = this.melee_raw_min + this.stone_extra
	this.melee.attacks[1].damage_max = this.melee_raw_max + this.stone_extra

	update_hp(this)
end

local function hero_arivan_on_damage(this, store, damage)
	local function quick_cooldown(a)
		a.ts = a.ts - 1
	end

	local at = this.timed_attacks.list[2]
	local a = at.aura

	if not a or #a.stones < 1 then
		return true
	end

	local stone = a.stones[#a.stones]

	stone.hp = stone.hp - damage.value

	if stone.hp <= 0 then
		local fx = E:create_entity("fx_arivan_stone_explosion")

		fx.pos = stone.pos
		fx.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(fx)
		simulation:queue_remove_entity(stone)
		table.remove(a.stones, #a.stones)
		quick_cooldown(this.ranged.attacks[2])
		quick_cooldown(this.ranged.attacks[3])
		quick_cooldown(this.timed_attacks.list[1])
		quick_cooldown(this.ultimate)

		this.stone_extra = #a.stones * this.stone_extra_per_stone
		this.melee.attacks[1].damage_min = this.melee_raw_min + this.stone_extra
		this.melee.attacks[1].damage_max = this.melee_raw_max + this.stone_extra
	end

	a.shield_active = true

	return false
end

local function hero_arivan_insert(this, store)
	this.hero.fn_level_up(this, store)

	this.melee.order = U.attack_order(this.melee.attacks)
	this.ranged.order = U.attack_order(this.ranged.attacks)

	local a = E:create_entity("aura_arivan_stone_dance")

	a.aura.source_id = this.id
	a.aura.ts = store.tick_ts
	a.pos = this.pos
	this.timed_attacks.list[2].aura = a

	simulation:queue_insert_entity(a)

	return true
end

local function hero_arivan_generate_stone_effect(this, store, damage, target)
	local a = this.timed_attacks.list[2]
	local stone_chance = 0.2

	if target and target.vis and band(target.vis.flags, F_BOSS) ~= 0 then
		stone_chance = 0.1
	end

	if #a.aura.stones < a.aura.max_stones and math.random(0, 1) < stone_chance then
		S:queue(a.sound)

		local stone = E:create_entity("arivan_stone")
		local i = #a.aura.stones + 1
		local aura = a.aura
		local angle = i * 2 * math.pi / aura.max_stones % (2 * math.pi)

		stone.pos = U.point_on_ellipse(this.pos, aura.rot_radius, angle)
		stone.render.sprites[1].name = string.format(stone.render.sprites[1].name, i)
		stone.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(stone)
		table.insert(aura.stones, stone)

		aura.aura.ts = store.tick_ts
		this.stone_extra = #a.aura.stones * this.stone_extra_per_stone
		this.melee.attacks[1].damage_min = this.melee_raw_min + this.stone_extra
		this.melee.attacks[1].damage_max = this.melee_raw_max + this.stone_extra
	end
end

local function hero_arivan_update(this, store)
	local h = this.health
	local a, skill, brk, sta

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
					goto label_90_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.stone_dance

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) and #a.aura.stones < a.aura.max_stones then
				S:queue(a.sound)
				U.animation_start_default(this, a.animation, nil, store.tick_ts)
				U.y_wait_unconditional(store, a.hit_time)

				local aura = a.aura

				for i = #a.aura.stones + 1, aura.max_stones do
					local stone = E:create_entity("arivan_stone")
					local angle = i * 2 * math.pi / aura.max_stones % (2 * math.pi)

					stone.pos = U.point_on_ellipse(this.pos, aura.rot_radius, angle)
					stone.render.sprites[1].name = string.format(stone.render.sprites[1].name, i)
					stone.render.sprites[1].ts = store.tick_ts

					simulation:queue_insert_entity(stone)
					table.insert(aura.stones, stone)
				end

				aura.aura.ts = store.tick_ts
				this.stone_extra = #a.aura.stones * this.stone_extra_per_stone
				this.melee.attacks[1].damage_min = this.melee_raw_min + this.stone_extra
				this.melee.attacks[1].damage_max = this.melee_raw_max + this.stone_extra

				U.y_animation_wait_default(this)

				a.ts = store.tick_ts

				goto label_90_0
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.seal_of_fire

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local target = U.find_nearest_enemy(store, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if not target then
					a.ts = a.ts + 0.26666666666666666
				else
					local pred_pos = target.pos
					local an, af = U.animation_name_facing_point(this, a.animations[1], pred_pos)

					U.y_animation_play(this, an, af, store.tick_ts, 1)

					for i = 1, a.loops do
						an, af = U.animation_name_facing_point(this, a.animations[2], pred_pos)

						U.animation_start_default(this, an, af, store.tick_ts, false)

						for si, st in pairs(a.shoot_times) do
							while st > store.tick_ts - this.render.sprites[1].ts do
								if SU.hero_interrupted(this) then
									goto label_90_0
								end

								coroutine.yield()
							end

							local offset = a.bullet_start_offset[si]
							local b = E:create_entity(a.bullet)

							target = U.find_nearest_enemy(store, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

							if target then
								local dist = V.dist(this.pos.x, this.pos.y + offset.y, target.pos.x, target.pos.y)

								pred_pos = P:predict_enemy_pos(target, dist / b.bullet.min_speed)
							end

							a.ts = store.tick_ts

							b.pos:copy(this.pos)

							b.pos.x, b.pos.y = b.pos.x + (af and -1 or 1) * offset.x, b.pos.y + offset.y

							b.bullet.from:copy(b.pos)
							b.bullet.to:copy(pred_pos)

							b.bullet.to.x, b.bullet.to.y = b.bullet.to.x + U.frandom(-1, 1), b.bullet.to.y + U.frandom(-1, 1)
							b.bullet.source_id = this.id
							b.bullet.xp_dest_id = this.id
							b.bullet.damage_factor = this.unit.damage_factor
							b.bullet.damage_min = b.bullet.damage_min + this.unit.damage_buff
							b.bullet.damage_max = b.bullet.damage_max + this.unit.damage_buff

							simulation:queue_insert_entity(b)
						end

						while not U.animation_finished_default(this) do
							if SU.hero_interrupted(this) then
								goto label_90_0
							end

							coroutine.yield()
						end
					end

					SU.hero_gain_xp_from_skill(this, skill)
					U.animation_start_default(this, a.animations[3], nil, store.tick_ts, false)

					while not U.animation_finished_default(this) do
						if SU.hero_interrupted(this) then
							break
						end

						coroutine.yield()
					end

					goto label_90_0
				end
			end

			if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
				local target = find_target_at_critical_moment(this, this.ranged.attacks[1].max_range, F_RANGED, F_NONE, nil, true, true)

				if target and target.pos and valid_twister_node_nearby(target.pos) then
					U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
					S:queue(this.sound_events.change_rally_point)

					local e = E:create_entity(this.hero.skills.ultimate.controller_name)

					e.level = this.hero.skills.ultimate.level
					e.pos = V.vclone(target.pos)
					e.owner = this

					simulation:queue_insert_entity(e)

					this.ultimate.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
				else
					this.ultimate.ts = this.ultimate.ts + 1
				end
			end

			if this.soldier.target_id then
				brk, sta = SU.y_soldier_ranged_attacks(store, this)

				if brk then
					goto label_90_0
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
				goto label_90_0
			end

			brk, sta = SU.y_soldier_ranged_attacks(store, this)

			if brk then
				goto label_90_0
			end

			if SU.soldier_go_back_step(store, this) then
				goto label_90_0
			end

			SU.soldier_idle(store, this)
			SU.soldier_regen(store, this)
		end

		::label_90_0::

		coroutine.yield()
	end
end

local function hero_arivan_ultimate_update(this, store)
	local np = this.nav_path
	local nodes_step = this.aura.nodes_step
	local last_freeze_target
	local targets = U.find_enemies_in_paths(store.enemies, this.pos, 0, this.aura.range_nodes, nil, this.aura.vis_flags, this.aura.vis_bans, true)

	if targets then
		local o = targets[1].origin

		np.pi, np.spi, np.ni = o[1], 1, o[3] + 3
	else
		local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true, NF_TWISTER)

		if #nodes < 1 then
			coroutine.yield()

			goto label_95_1
		end

		local o = nodes[1]

		np.pi, np.spi, np.ni = o[1], 1, o[3]
	end

	this.pos = P:node_pos(np.pi, np.spi, np.ni)

	U.y_animation_play(this, "start", nil, store.tick_ts)
	U.animation_start_default(this, "travel", nil, store.tick_ts, true)

	this.aura.ts = store.tick_ts

	while true do
		local next_pos = P:node_pos(np.pi, np.spi, np.ni + nodes_step)

		if P:is_node_valid(np.pi, np.ni + nodes_step, NF_TWISTER) and band(GR:cell_type(next_pos.x, next_pos.y), TERRAIN_CLIFF) == 0 then
			np.ni = np.ni + nodes_step
		end

		np.spi = np.spi == 2 and 3 or 2

		U.set_destination(this, P:node_pos(np.pi, np.spi, np.ni))

		while not this.motion.arrived do
			if store.tick_ts - this.aura.ts > this.aura.duration or band(GR:cell_type(this.pos.x, this.pos.y), TERRAIN_CLIFF) ~= 0 then
				goto label_95_0
			end

			U.walk_off__accel__unsnapped(this, store.tick_length)

			for ai, a in ipairs(this.timed_attacks.list) do
				if store.tick_ts - a.ts < a.cooldown then
				-- block empty
				else
					a.ts = store.tick_ts

					if a.chance and (a.chance == 0 or math.random() >= a.chance) then
					-- block empty
					else
						local targets = U.find_enemies_in_range_filter_off(this.pos, a.max_range, a.vis_flags, a.vis_bans)

						if not targets then
							if ai == 3 then
								last_freeze_target = nil
							end
						elseif ai == 1 then
							for _, target in ipairs(targets) do
								local mod = E:create_entity(a.mod)

								mod.modifier.target_id = target.id

								simulation:queue_insert_entity(mod)
							end
						elseif ai == 2 then
							for _, target in ipairs(targets) do
								local d = E.assign_damage(a.damage_type, a.damage_max, this.id, target.id)

								queue_damage(store, d)
							end
						elseif ai == 3 then
							local mod = E:create_entity(a.mod)

							mod.modifier.target_id = targets[1].id

							simulation:queue_insert_entity(mod)

							last_freeze_target = targets[1].id
						elseif a.type == "bullet" then
							if #targets > 1 and last_freeze_target then
								table.removeobject(targets, last_freeze_target)
							end

							local target = table.random(targets)
							local b = E:create_entity(a.bullet)

							b.pos:copy(this.pos)

							b.pos.x = b.pos.x + (target.pos.x > this.pos.x and 1 or -1) * a.bullet_start_offset[1].x
							b.pos.y = b.pos.y + a.bullet_start_offset[1].y

							b.bullet.from:copy(b.pos)

							b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
							b.bullet.target_id = target.id
							b.bullet.source_id = this.id

							simulation:queue_insert_entity(b)
						end
					end
				end
			end

			coroutine.yield()
		end
	end

	::label_95_0::

	U.y_animation_play(this, "end", nil, store.tick_ts)

	::label_95_1::

	simulation:queue_remove_entity(this)
end

tt = RT("hero_arivan", "hero")

AC(tt, "melee", "ranged", "timed_attacks")

tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.hp_max = {115, 130, 145, 160, 175, 190, 205, 220, 235, 250}
tt.hero.level_stats.melee_damage_max = {27, 30, 34, 37, 41, 44, 47, 51, 54, 57}
tt.hero.level_stats.melee_damage_min = {9, 10, 11, 12, 14, 15, 16, 17, 18, 19}
tt.hero.level_stats.ranged_damage_min = {9, 10, 11, 12, 14, 15, 16, 17, 18, 19}
tt.hero.level_stats.ranged_damage_max = {27, 30, 34, 37, 41, 44, 47, 51, 54, 57}
tt.hero.skills.icy_prison = CC("hero_skill")
tt.hero.skills.icy_prison.damage = {40, 60, 80}
tt.hero.skills.icy_prison.duration = {2, 4, 6}
tt.hero.skills.icy_prison.xp_gain = {40, 80, 120}
tt.hero.skills.icy_prison.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.lightning_rod = CC("hero_skill")
tt.hero.skills.lightning_rod.damage_max = {120, 240, 360}
tt.hero.skills.lightning_rod.damage_min = {60, 120, 180}
tt.hero.skills.lightning_rod.xp_gain = {50, 100, 150}
tt.hero.skills.lightning_rod.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.seal_of_fire = CC("hero_skill")
tt.hero.skills.seal_of_fire.count = {1, 2, 3}
tt.hero.skills.seal_of_fire.xp_gain = {62, 125, 187}
tt.hero.skills.seal_of_fire.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.stone_dance = CC("hero_skill")
tt.hero.skills.stone_dance.count = {1, 2, 3}
tt.hero.skills.stone_dance.stone_extra = {12, 17, 22}
tt.hero.skills.stone_dance.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_arivan_ultimate"
tt.hero.skills.ultimate.damage = {7, 8, 9, 10}
tt.hero.skills.ultimate.duration = {5.5, 7, 8.5, 10}
tt.hero.skills.ultimate.freeze_chance = {0.5, 0.6, 0.7, 0.8}
tt.hero.skills.ultimate.freeze_duration = {1.25, 1.5, 1.75, 2}
tt.hero.skills.ultimate.xp_gain_factor = 64
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.ultimate.lightning_chance = {0.35, 0.5, 0.65, 0.8}
tt.hero.skills.ultimate.lightning_cooldown = {fts(30), fts(30), fts(24), fts(21)}
tt.health.dead_lifetime = 15
tt.health.on_damage = hero_arivan_on_damage
tt.health_bar.offset = vec_2(0, 39)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_arivan_level_up
tt.hero.tombstone_show_time = fts(90)
tt.info.hero_portrait = "kr3_hero_portraits_0002"
tt.info.portrait = "kr3_info_portraits_heroes_0002"
tt.main_script.insert = hero_arivan_insert
tt.main_script.update = hero_arivan_update
tt.motion.max_speed = 3 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.083333333333333
tt.render.sprites[1].prefix = "hero_arivan"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].fps = 35
tt.soldier.melee_slot_offset = vec_2(4, 0)
tt.sound_events.change_rally_point = "ElvesHeroArivanTaunt"
tt.sound_events.death = "ElvesHeroArivanDeath"
tt.sound_events.respawn = "ElvesHeroArivanTauntIntro"
tt.sound_events.insert = "ElvesHeroArivanTauntIntro"
tt.sound_events.hero_room_select = "ElvesHeroArivanTauntSelect"
tt.unit.hit_offset = vec_2(0, 13)
tt.unit.mod_offset = vec_2(0, 13)
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].xp_gain_factor = 2.1
tt.melee.attacks[1].damage_type = DAMAGE_MAGICAL
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].side_effect = hero_arivan_generate_stone_effect
tt.melee.range = 50
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].cooldown = 1.5
tt.ranged.attacks[1].min_range = 20
tt.ranged.attacks[1].max_range = 160
tt.ranged.attacks[1].node_prediction = fts(11 * 6 / 7)
tt.ranged.attacks[1].bullet = "ray_arivan_simple"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(0, 35)}
tt.ranged.attacks[1].shoot_time = fts(11 * 6 / 7)
tt.ranged.attacks[1].side_effect = hero_arivan_generate_stone_effect
tt.ranged.attacks[2] = CC("bullet_attack")
tt.ranged.attacks[2].animation = "rayShoot"
tt.ranged.attacks[2].cooldown = 16.2
tt.ranged.attacks[2].disabled = true
tt.ranged.attacks[2].max_range = 175
tt.ranged.attacks[2].node_prediction = fts(19 * 6 / 7)
tt.ranged.attacks[2].bullet = "lightning_arivan"
tt.ranged.attacks[2].bullet_start_offset = {vec_2(1, 39)}
tt.ranged.attacks[2].shoot_time = fts(19 * 6 / 7)
tt.ranged.attacks[2].sound = "ElvesHeroArivanLightingBolt"
tt.ranged.attacks[2].xp_from_skill = "lightning_rod"
tt.ranged.attacks[3] = CC("bullet_attack")
tt.ranged.attacks[3].animation = "freezeBall"
tt.ranged.attacks[3].cooldown = 12.6
tt.ranged.attacks[3].disabled = true
tt.ranged.attacks[3].max_range = 130
tt.ranged.attacks[3].node_prediction = fts(25 * 6 / 7)
tt.ranged.attacks[3].bullet = "bolt_freeze_arivan"
tt.ranged.attacks[3].bullet_start_offset = {vec_2(1, 40)}
tt.ranged.attacks[3].shoot_time = fts(25 * 6 / 7)
tt.ranged.attacks[3].sound = "ElvesHeroArivanIceShoot"
tt.ranged.attacks[3].xp_from_skill = "icy_prison"
tt.timed_attacks.list[1] = CC("bullet_attack")
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].cooldown = 21.7
tt.timed_attacks.list[1].max_range = 160
tt.timed_attacks.list[1].bullet = "fireball_arivan"
tt.timed_attacks.list[1].bullet_start_offset = {vec_2(-7, 50), vec_2(7, 50)}
tt.timed_attacks.list[1].shoot_times = {fts(4), fts(14)}
tt.timed_attacks.list[1].animations = {"multiShootStart", "multiShootLoop", "multiShootEnd"}
tt.timed_attacks.list[1].loops = 0
tt.timed_attacks.list[1].xp_from_skill = "seal_of_fire"
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].animation = "stoneCast"
tt.timed_attacks.list[2].cooldown = 20
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].hit_time = fts(13 * 6 / 7)
tt.timed_attacks.list[2].sound = "ElvesHeroArivanSummonRocks"
tt.ultimate = {
	ts = 0,
	cooldown = 64,
	disabled = true
}
tt.stone_extra = 0
tt.stone_extra_per_stone = 0
tt.melee_raw_min = 0
tt.melee_raw_max = 0
tt = RT("ray_arivan_simple", "bullet")
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.hit_fx = "fx_ray_arivan_simple_hit"
tt.bullet.hit_time = fts(5)
tt.bullet.xp_gain_factor = 2.7
tt.image_width = 60
tt.track_target = true
tt.main_script.update = scripts.ray_simple.update
tt.render.sprites[1].anchor = vec_2(0, 0.5)
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "arivan_ray_simple"
tt.sound_events.insert = "ElvesHeroArivanRegularRay"
tt = RT("fx_ray_arivan_simple_hit", "fx")
tt.render.sprites[1].name = "arivan_ray_simple_hit"
tt = RT("lightning_arivan", "bullet")
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.hit_fx = "fx_lighting_arivan_hit"
tt.bullet.hit_time = fts(5)
tt.image_width = 90
tt.track_target = true
tt.main_script.update = scripts.ray_simple.update
tt.render.sprites[1].anchor = vec_2(0, 0.5)
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "arivan_lightning"
tt = RT("fx_lighting_arivan_hit", "fx")
tt.render.sprites[1].name = "arivan_lightning_hit"
tt = RT("bolt_freeze_arivan", "bolt")
tt.bullet.acceleration_factor = 0.3
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.hit_fx = "fx_bolt_freeze_arivan_hit"
tt.bullet.max_speed = 450
tt.bullet.min_speed = 150
tt.bullet.mod = "mod_arivan_freeze"
tt.bullet.particles_name = "ps_freeze_arivan"
tt.bullet.pop = nil
tt.render.sprites[1].prefix = "arivan_freeze"
tt.render.sprites[1].name = "travel"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
tt.sound_events.insert = "ElvesHeroArivanLightingBolt"
tt = RT("fx_bolt_freeze_arivan_hit", "fx")

AC(tt, "sound_events")

tt.render.sprites[1].name = "arivan_freeze_hit"
tt.sound_events.insert = "ElvesHeroArivanIceShootHit"
tt = RT("fireball_arivan", "bullet")
tt.bullet.acceleration_factor = 0.15
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_max = 40
tt.bullet.damage_min = 20
tt.bullet.damage_radius = 70
tt.bullet.damage_type = bor(DAMAGE_MAGICAL_EXPLOSION, DAMAGE_FX_NOT_EXPLODE)
tt.bullet.hit_fx = "fx_fireball_arivan_hit"
tt.bullet.max_speed = 450
tt.bullet.min_speed = 150
tt.bullet.particles_name = "ps_fireball_arivan"
tt.idle_time = fts(10)
tt.main_script.update = fireball_arivan_update
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "arivan_fireball"
tt.sound_events.hit = "ElvesHeroArivanFireballExplode"
tt.sound_events.insert = "ElvesHeroArivanFireballSummon"
tt.sound_events.travel = "ElvesHeroArivanFireball"
tt = RT("fx_fireball_arivan_hit", "fx")
tt.render.sprites[1].name = "arivan_fireball_hit"
tt.render.sprites[1].sort_y_offset = -5
tt.render.sprites[1].anchor.y = 0.20930232558139536
tt.render.sprites[1].z = Z_OBJECTS
tt = RT("aura_arivan_stone_dance", "aura")

AC(tt, "render")

tt.aura.duration = -1
tt.main_script.update = aura_arivan_stone_dance_update
tt.stones = {}
tt.max_stones = 0
tt.shield_active = false
tt.render.sprites[1].name = "arivan_shield"
tt.render.sprites[1].hide_after_runs = 1
tt.render.sprites[1].hidden = true
tt.render.sprites[1].anchor.y = 0.083333333333333
tt.owner_vis_bans = bor(F_BURN, F_POISON, F_STUN, F_NET, F_BLOOD)
tt.rot_speed = 3 * FPS * math.pi / 180
tt.rot_radius = 25
tt = RT("arivan_stone", "decal_tween")
anchor_y = 0.11666666666666667
tt.render.sprites[1].name = "arivan_stone_%d"
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].loop = false
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "arivan_stone_1_0014"
tt.render.sprites[2].anchor.y = anchor_y
tt.render.sprites[2].z = Z_DECALS
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {{0, vec_2(0, 0)}, {0.5, vec_2(0, 3)}, {1, vec_2(0, 0)}, {1.5, vec_2(0, -3)}, {2, vec_2(0, 0)}}
tt.tween.props[1].loop = true
tt.tween.remove = false
tt.hp = 75
tt = RT("fx_arivan_stone_explosion", "fx")
tt.render.sprites[1].name = "arivan_stone_explosion"
tt.render.sprites[1].anchor.y = 0.11666666666666667
tt = RT("hero_arivan_ultimate", "aura")

AC(tt, "timed_attacks", "motion", "nav_path", "render")

tt.aura.duration = nil
tt.aura.range_nodes = 60
tt.aura.nodes_step = -5
tt.aura.vis_bans = bor(F_CLIFF, F_WATER)
tt.cooldown = 64
tt.main_script.update = hero_arivan_ultimate_update
tt.motion.max_speed = 0.5 * FPS
tt.render.sprites[1].prefix = "arivan_twister"
tt.render.sprites[1].anchor.y = 0.15853658536585366
tt.sound_events.insert = "ElvesHeroArivanStorm"
tt.sound_events.remove_stop = "ElvesHeroArivanStorm"
tt.timed_attacks.list[1] = CC("mod_attack")
tt.timed_attacks.list[1].cooldown = fts(5)
tt.timed_attacks.list[1].mod = "mod_slow"
tt.timed_attacks.list[1].max_range = 80
tt.timed_attacks.list[2] = CC("area_attack")
tt.timed_attacks.list[2].cooldown = fts(6)
tt.timed_attacks.list[2].max_range = 80
tt.timed_attacks.list[2].damage_max = nil
tt.timed_attacks.list[2].damage_min = nil
tt.timed_attacks.list[2].damage_type = DAMAGE_TRUE
tt.timed_attacks.list[2].vis_bans = 0
tt.timed_attacks.list[3] = CC("mod_attack")
tt.timed_attacks.list[3].cooldown = fts(30)
tt.timed_attacks.list[3].max_range = 80
tt.timed_attacks.list[3].mod = "mod_arivan_ultimate_freeze"
tt.timed_attacks.list[3].chance = nil
tt.timed_attacks.list[3].vis_bans = F_BOSS
tt.timed_attacks.list[4] = CC("bullet_attack")
tt.timed_attacks.list[4].bullet = "lightning_arivan_ultimate"
tt.timed_attacks.list[4].bullet_start_offset = {vec_2(6, 36)}
tt.timed_attacks.list[4].max_range = 100
tt.timed_attacks.list[4].chance = nil
tt = RT("lightning_arivan_ultimate", "bullet")
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.mod = "fx_lighting_arivan_ultimate_hit"
tt.bullet.hit_time = fts(4)
tt.image_width = 40
tt.track_target = true
tt.main_script.update = scripts.ray_simple.update
tt.render.sprites[1].anchor = vec_2(0, 0.5)
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "arivan_twister_ray"
tt.sound_events.insert = "ElvesHeroArivanRegularRay"
tt = RT("fx_lighting_arivan_ultimate_hit", "modifier")

AC(tt, "render")

tt.render.sprites[1].name = "arivan_twister_ray_hit"
tt.main_script.insert = scripts.mod_track_target.insert
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.duration = fts(12)
tt = RT("ps_freeze_arivan")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "arivan_freeze_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(8), fts(8)}
tt.particle_system.emission_rate = 30
tt.particle_system.z = Z_BULLETS
