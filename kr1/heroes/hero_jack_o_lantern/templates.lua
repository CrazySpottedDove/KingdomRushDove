local E = require("entity_db")
local GR = require("grid_db")
local HU = require("hero_utils")
local P = require("path_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local km = require("lib.klua.macros")
local scripts = require("scripts")
local bit = require("bit")
local bor = bit.bor
local fts = U.fts
local level_up_basic = HU.level_up_basic
local queue_damage = U.queue_damage
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local v = V.v
local tt

local INTIMIDATION = "mod_hero_jacko_horse_intimidation"

local function hero_jack_on_damage(this, store, damage)
	local h = this.health

	h.accumulated_damage = h.accumulated_damage + U.predict_damage(this, damage) * h.accumulated_damage_factor

	return true
end

local function hero_jack_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
	this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

	upgrade_skill(this, "explosive_head", function(this, s)
		local b = E:get_template(this.timed_attacks.list[1].bullet)

		b.bullet.damage_min = s.damage[s.level]
		b.bullet.damage_max = s.damage[s.level]

		this.timed_attacks.list[1].disabled = nil
	end)
	upgrade_skill(this, "haunted_blade", function(this, s)
		local a = this.melee.attacks[2]

		a.cooldown = s.cooldown[s.level]
		a.disabled = nil
	end)
	upgrade_skill(this, "hero_jacko_melee", function(this, s)
		this.health.accumulated_damage_factor = s.accumulated_damage_factor[s.level]
	end)
	upgrade_skill(this, "hero_jacko_thriller", function(this, s)
		local a = this.timed_attacks.list[2]

		a.max_bullets = s.max_bullets[s.level]
		a.disabled = nil
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		local h = E:get_template("hero_jacko_horse")

		h.aura.damage_min = s.damage_over_time[s.level]
		h.aura.damage_max = s.damage_over_time[s.level]

		this.ultimate.cooldown = s.cooldown[s.level]
		this.ultimate.disabled = nil
	end)

	update_hp(this)
end

local function hero_jack_update(this, store)
	local explosive_head = this.timed_attacks.list[1]
	local thriller = this.timed_attacks.list[2]

	this.health_bar.hidden = true

	U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)

	while true do
		if this.health.dead then
			SU.y_hero_death_and_respawn(store, this)

			U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)
		end

		while this.nav_rally.new do
			SU.y_hero_new_rally(store, this)
		end

		if SU.hero_level_up(store, this) then
			U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)
		end

		local skip

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)

			skip = true
		end

		if not skip and ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
			local u = this.hero.skills.ultimate
			local targets = U.find_enemies_in_paths(store.enemies, this.pos, 0, u.range_nodes_max, nil, 0, bor(F_FLYING, F_FRIEND), true) or {}

			if #targets < u.min_targets then
				this.ultimate.ts = this.ultimate.ts + 0.1
			else
				local target = targets[1].enemy

				if V.dist2(target.pos.x, target.pos.y, this.pos.x, this.pos.y) > u.max_range * u.max_range or not GR:cell_is_only(target.pos.x, target.pos.y, TERRAIN_LAND) or not P:valid_node_nearby(target.pos.x, target.pos.y, nil, NF_RALLY) then
					this.ultimate.ts = this.ultimate.ts + 0.1
				else
					HU.apply_ultimate(this, store, target.pos, "levelUp")
				end
			end
		end

		if not skip and ready_to_use_skill(explosive_head, store, this.unit.cooldown_factor) then
			local _, targets, pred_pos = U.find_foremost_enemy_in_range_filter_off(this.pos, explosive_head.max_range, explosive_head.node_prediction, explosive_head.vis_flags, explosive_head.vis_bans)

			if not targets then
				explosive_head.ts = explosive_head.ts + 0.1
			else
				local target = targets[1]
				local start_ts = store.tick_ts
				local an, af = U.animation_name_facing_point(this, explosive_head.animation, pred_pos)

				U.animation_start_default(this, an, af, store.tick_ts)

				if SU.y_soldier_wait(store, this, explosive_head.cast_time) then
					skip = true
				else
					local b = E:create_entity(explosive_head.bullet)
					local offset = explosive_head.bullet_start_offset[1]

					b.bullet.target_id = target.id
					b.bullet.source_id = this.id
					b.pos:copy(this.pos)
					b.pos.x = b.pos.x + (af and -1 or 1) * offset.x
					b.pos.y = b.pos.y + offset.y
					b.bullet.from:copy(b.pos)
					b.bullet.damage_min = b.bullet.damage_min + this.unit.damage_buff
					b.bullet.damage_max = b.bullet.damage_max + this.unit.damage_buff
					b.bullet.damage_factor = this.unit.damage_factor
					b.bullet.to:copy(pred_pos)

					if bit.band(target.vis.flags, F_FLYING) ~= 0 then
						b.bullet.to.x = b.bullet.to.x + target.unit.hit_offset.x
						b.bullet.to.y = b.bullet.to.y + target.unit.hit_offset.y
						b.bullet.use_hit_offset = true
						b.bullet.hit_decal = nil
					end

					simulation:queue_insert_entity(b)

					explosive_head.ts = start_ts

					SU.hero_gain_xp_from_skill(this, this.hero.skills[explosive_head.xp_from_skill])

					skip = SU.y_hero_animation_wait(this)
				end
			end
		end

		if not skip and ready_to_use_skill(thriller, store, this.unit.cooldown_factor) then
			local targets = U.find_enemies_in_paths(store.enemies, this.pos, 0, thriller.range_nodes, nil, 0, thriller.vis_bans, true) or {}

			if #targets < thriller.min_targets then
				thriller.ts = thriller.ts + 0.1
			else
				local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)

				if #nodes < 1 then
					thriller.ts = thriller.ts + 0.1
				else
					local tpi, _, tni = unpack(nodes[1])
					local end_node = P:get_end_node(tpi)
					local start_ts = store.tick_ts
					local flip = targets[1].enemy.pos.x < this.pos.x

					U.animation_start_default(this, thriller.animation, flip, store.tick_ts)

					if SU.y_soldier_wait(store, this, thriller.cast_time) then
						skip = true
					else
						for i = 1, thriller.max_bullets do
							local sign = i % 2 == 1 and 1 or -1
							local node = km.clamp(1, end_node, math.random(thriller.min_nodes, thriller.max_nodes) * sign + tni)
							local spi = math.random(1, math.min(3, #P.paths[tpi]))
							local pos = P:node_pos(tpi, spi, node)
							local b = E:create_entity(thriller.bullet)
							local ghoul = E:create_entity("hero_jacko_ghoul")

							ghoul.nav_path.pi, ghoul.nav_path.spi, ghoul.nav_path.ni = tpi, spi, node

							local controller = E:create_entity("hero_jacko_ghoul_spawner")

							controller.payload = ghoul
							controller.pos:copy(pos)

							b.bullet.source_id = this.id
							b.bullet.hit_payload = controller
							b.bullet.from:copy(this.pos)
							b.bullet.from.x = b.bullet.from.x + (flip and -1 or 1) * thriller.bullet_start_offset[1].x
							b.bullet.from.y = b.bullet.from.y + thriller.bullet_start_offset[1].y
							b.pos:copy(b.bullet.from)
							b.bullet.to:copy(pos)

							simulation:queue_insert_entity(b)
						end

						thriller.ts = start_ts

						SU.hero_gain_xp_from_skill(this, this.hero.skills[thriller.xp_from_skill])

						skip = SU.y_hero_animation_wait(this)
					end
				end
			end
		end

		if not skip then
			local brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if not brk and sta == A_NO_TARGET and not SU.soldier_go_back_step(store, this) then
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		coroutine.yield()
	end
end

local function hero_jacko_ghoul_update(this, store)
	local hover = this.hover

	hover.oni = this.nav_path.ni
	hover.ts = store.tick_ts
	hover.cooldown = U.frandom(hover.cooldown_min, hover.cooldown_max)
	this.reinforcement.ts = store.tick_ts

	U.set_destination(this, this.pos)

	this.tween.reverse = false
	this.tween.disabled = true

	while true do
		if this.health.dead or this.reinforcement.duration and store.tick_ts - this.reinforcement.ts > this.reinforcement.duration then
			if this.health.hp > 0 then
				this.reinforcement.hp_before_timeout = this.health.hp
			end

			this.health.hp = 0

			SU.y_soldier_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			local brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if not brk and sta == A_NO_TARGET then
				if V.veq(this.pos, this.motion.dest) then
					this.motion.arrived = true

					U.animation_start_default(this, "idle", nil, store.tick_ts, true)
					SU.soldier_regen(store, this)

					if store.tick_ts - hover.ts >= hover.cooldown then
						hover.ts = store.tick_ts
						hover.cooldown = U.frandom(hover.cooldown_min, hover.cooldown_max)
						this.nav_path.spi = hover.random_subpath and math.random(1, math.min(3, #P.paths[this.nav_path.pi])) or this.nav_path.spi
						this.nav_path.ni = hover.oni + math.random(-hover.random_ni, hover.random_ni)

						local next_pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)

						if P:is_node_valid(this.nav_path.pi, this.nav_path.ni) and GR:cell_is(next_pos.x, next_pos.y, TERRAIN_LAND) and not GR:cell_is(next_pos.x, next_pos.y, TERRAIN_NOWALK) then
							U.set_destination(this, next_pos)
						end
					end
				elseif not U.walk(this, store.tick_length) then
					local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)

					U.animation_start_default(this, an, af, store.tick_ts, true)
				end
			end
		end

		coroutine.yield()
	end
end

local function hero_jacko_horse_update(this, store)
	local aura = this.aura
	local last_hit_ts = store.tick_ts - aura.cycle_time
	local fear_duration = E:get_template(INTIMIDATION).modifier.duration
	local particles = {}

	this.aura.ts = store.tick_ts
	this.tween.reverse = false
	this.tween.remove = false

	if this.fade_in then
		this.tween.disabled = false
		this.tween.ts = store.tick_ts
	else
		this.tween.disabled = true
	end

	for _, name in ipairs(this.particle) do
		local p = E:create_entity(name)

		p.particle_system.emit = true
		p.particle_system.track_id = this.id

		simulation:queue_insert_entity(p)
		table.insert(particles, p)
	end

	while store.tick_ts - this.aura.ts < aura.duration do
		if store.tick_ts - last_hit_ts >= aura.cycle_time then
			last_hit_ts = store.tick_ts

			local targets = U.find_enemies_in_range_filter_off(this.pos, aura.radius, aura.vis_flags, aura.vis_bans)

			if targets then
				for _, target in ipairs(targets) do
					local d = E.assign_damage(aura.damage_type, math.random(aura.damage_min, aura.damage_max) * aura.damage_factor, this.id, target.id)

					queue_damage(store, d)

					if SU.is_valid_scare_target(target) and SU.scare_enemy(target, {
						duration = fear_duration,
						friend_mod = INTIMIDATION
					}) then
						local m = E:create_entity(INTIMIDATION)

						m.modifier.target_id = target.id
						m.modifier.source_id = this.id

						simulation:queue_insert_entity(m)
					end
				end
			end
		end

		local nearest = P:nearest_nodes(this.pos.x, this.pos.y, {this.nav_path.pi}, {this.nav_path.spi})

		if nearest[1] and nearest[1][3] < this.nav_path.ni then
			this.nav_path.ni = nearest[1][3]
		end

		local next_pos = P:next_entity_node(this, store.tick_length)

		if not next_pos or not P:is_node_valid(this.nav_path.pi, this.nav_path.ni) or not GR:cell_is(next_pos.x, next_pos.y, TERRAIN_LAND) or GR:cell_is(next_pos.x, next_pos.y, TERRAIN_NOWALK) then
			break
		end

		U.set_destination(this, next_pos)

		local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)

		U.animation_start_default(this, an, af, store.tick_ts, true)

		U.walk(this, store.tick_length)

		coroutine.yield()
	end

	for _, p in ipairs(particles) do
		p.particle_system.emit = nil
	end

	if this.fade_out then
		this.tween.reverse = true
		this.tween.remove = true
		this.tween.disabled = nil
		this.tween.ts = store.tick_ts
	end
end

local function hero_jacko_ultimate_update(this, store)
	local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, {1}, true)

	if #nodes < 1 then
		simulation:queue_remove_entity(this)

		return
	end

	local pi, _, ni = unpack(nodes[1])

	for spi = 1, math.min(3, #P.paths[pi]) do
		local horse = E:create_entity("hero_jacko_horse")

		horse.pos:copy(P:node_pos(pi, spi, ni))
		horse.nav_path.pi, horse.nav_path.spi, horse.nav_path.ni = pi, spi, ni
		horse.aura.damage_factor = this.damage_factor

		simulation:queue_insert_entity(horse)
	end

	simulation:queue_remove_entity(this)
end

local function hero_jacko_ghoul_spawner_update(this, store)
	U.y_wait_unconditional(store, this.delay)

	local ghoul = this.payload

	ghoul.pos.x, ghoul.pos.y = this.pos.x, this.pos.y
	ghoul.nav_rally.pos.x, ghoul.nav_rally.pos.y = this.pos.x, this.pos.y
	ghoul.nav_rally.center.x, ghoul.nav_rally.center.y = this.pos.x, this.pos.y

	simulation:queue_insert_entity(ghoul)
	simulation:queue_remove_entity(this)
end

tt = RT("mod_hero_jacko_reduce_armor", "mod_damage")
tt.damage_min = 1
tt.damage_max = 1
tt.damage_type = bor(DAMAGE_MAGICAL_ARMOR, DAMAGE_NO_SHIELD_HIT)

tt = RT("fx_hero_jack_o_lantern_explosion", "fx")
tt.render.sprites[1].name = "hero_jack_o_lantern_explotion_run"
tt.render.sprites[1].anchor.y = 0.169
tt.render.sprites[1].sort_y_offset = -2

tt = RT("bomb_explosive_head", "bomb")
tt.bullet.damage_min = 36
tt.bullet.damage_max = 36
tt.bullet.damage_radius = 75
tt.bullet.flight_time = fts(20)
tt.bullet.rotation_speed = 3 * FPS * math.pi / 20
tt.bullet.pop_chance = 0.1
tt.bullet.hit_fx = "fx_hero_jack_o_lantern_explosion"
tt.bullet.hit_fx_air = "fx_hero_jack_o_lantern_explosion"
tt.bullet.hit_fx_water = "fx_hero_jack_o_lantern_explosion"
tt.render.sprites[1].name = "hero_jack_o_lantern_head_proyectile"
tt.sound_events.insert = "ArrowSound"

tt = RT("fx_hero_jack_o_lantern_spawner_hit", "fx_fade")
tt.render.sprites[1].name = "hero_jack_o_lantern_spawner_hit_run"
tt.render.sprites[1].anchor.y = 0.5
tt.render.sprites[1].z = Z_OBJECTS
tt.tween.props[1].keys = {{0, 255}, {fts(56), 255}, {fts(71), 0}}

tt = RT("hero_jack_o_lantern_spawner_seed_decal", "decal_timed")
tt.render.sprites[1].name = "hero_jack_o_lantern_spawner_seed_decal_run"
tt.render.sprites[1].anchor.y = 0.5
tt.render.sprites[1].z = Z_DECALS

tt = RT("hero_jack_o_lantern_spawner_seed", "bomb")
tt.bullet.damage_min = 64
tt.bullet.damage_max = 64
tt.bullet.damage_radius = 50
tt.bullet.flight_time = fts(22)
tt.bullet.rotation_speed = 2 * FPS * math.pi / 22
tt.bullet.hit_fx = "fx_hero_jack_o_lantern_spawner_hit"
tt.bullet.hit_fx_water = "fx_hero_jack_o_lantern_spawner_hit"
tt.bullet.hit_decal = "hero_jack_o_lantern_spawner_seed_decal"
tt.render.sprites[1].name = "hero_jack_o_lantern_spawner_seed_travel"
tt.render.sprites[1].animated = true
tt.sound_events.hit = nil
tt.sound_events.hit_water = nil

tt = RT("hero_jacko_ghoul_spawner")
AC(tt, "pos", "main_script")
tt.delay = 1.2
tt.main_script.update = hero_jacko_ghoul_spawner_update

tt = RT("hero_jacko_ghoul", "soldier_militia")
AC(tt, "reinforcement", "nav_path", "tween")
tt.health.armor = 0.2
tt.health.magic_armor = 0
tt.health.hp_max = 320
tt.health_bar.offset = v(0, 32)
tt.hover = {}
tt.hover.cooldown_min = 5
tt.hover.cooldown_max = 15
tt.hover.random_ni = 6
tt.hover.random_subpath = true
tt.info.random_name_count = nil
tt.info.random_name_format = nil
tt.main_script.update = hero_jacko_ghoul_update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 25
tt.melee.attacks[1].damage_min = 15
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.range = 75
tt.motion.max_speed = 30
tt.regen.cooldown = 2
tt.regen.health = 0
tt.reinforcement.duration = 20
tt.reinforcement.fade = nil
tt.reinforcement.fade_out = true
tt.render.sprites[1].prefix = "hero_jack_o_lantern_ghoul"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.125
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "hero_jack_o_lantern_ghoul_shadow"
tt.render.sprites[2].anchor.y = 0.125
tt.render.sprites[2].z = Z_DECALS + 1
tt.soldier.melee_slot_offset = v(16, 0)
tt.tween.props[1].keys = {{0, 0}, {1, 255}}
tt.tween.disabled = true
tt.ui.click_rect = r(-20, -5, 40, 28)
tt.unit.head_offset = v(0, 29)
tt.unit.hit_offset = v(0, 16)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 16)

tt = RT("ps_hero_jack_o_lantern_ultimate_particle")
AC(tt, "pos", "particle_system")
tt.particle_system.name = "hero_jack_o_lantern_ultimate_particle_run"
tt.particle_system.anchor = v(0.5, 0.5)
tt.particle_system.track_offset = v(0, 29)
tt.particle_system.emission_rate = 3
tt.particle_system.animation_fps = 30
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.z = Z_OBJECTS + 1

tt = RT("ps_hero_jack_o_lantern_ultimate_smoke")
AC(tt, "pos", "particle_system")
tt.particle_system.name = "hero_jack_o_lantern_ultimate_smoke_run"
tt.particle_system.anchor = v(0.5, 0.5)
tt.particle_system.track_offset = v(0, 29)
tt.particle_system.emission_rate = 2
tt.particle_system.animation_fps = 46
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.z = Z_OBJECTS + 2

tt = RT("mod_hero_jacko_horse_intimidation", "modifier")
AC(tt, "render", "slow")
tt.modifier.duration = 3
tt.modifier.health_bar_offset = v(0, -8)
tt.slow.factor = 1.2
tt.main_script.insert = scripts.mod_slow.insert
tt.main_script.update = scripts.mod_track_target.update
tt.main_script.remove = scripts.mod_slow.remove
tt.render.sprites[1].name = "hero_jack_o_lantern_ultimate_fear_modifier_run"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].loop = true
tt.render.sprites[1].draw_order = DO_MOD_FX
tt.render.sprites[1].size_scales = {V.vv(1), V.vv(1.3), V.vv(1.5)}

tt = RT("hero_jacko_horse", "aura")
AC(tt, "render", "nav_path", "motion", "tween")
tt.aura.duration = 4.75
tt.aura.cycle_time = 0.25
tt.aura.radius = 65
tt.aura.damage_min = 12
tt.aura.damage_max = 12
tt.aura.damage_type = DAMAGE_EXPLOSION
tt.aura.damage_factor = 1
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.fade_in = true
tt.fade_out = true
tt.main_script.update = hero_jacko_horse_update
tt.motion.max_speed = 90
tt.nav_path.dir = -1
tt.particle = {"ps_hero_jack_o_lantern_ultimate_particle", "ps_hero_jack_o_lantern_ultimate_smoke"}
tt.render.sprites[1].prefix = "hero_jack_o_lantern_ultimate_horse"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.3
tt.render.sprites[1].sort_y_offset = -32
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk", "walkUp", "walkDown"}
tt.tween.props[1].keys = {{0, 0}, {1, 255}}
tt.tween.disabled = true

tt = RT("hero_jack_o_lantern_ultimate")
AC(tt, "pos", "main_script", "sound_events")
tt.main_script.update = hero_jacko_ultimate_update
tt.sound_events.insert = "hero_jacko_horses"

tt = RT("hero_jack_o_lantern_teleportfx", "fx")
tt.render.sprites[1].name = "hero_jack_o_lantern_teleportfx_run"
tt.render.sprites[1].anchor.y = 0.281

tt = RT("hero_jack_o_lantern", "hero")
AC(tt, "melee", "timed_attacks", "teleport")
tt.hero.level_stats.hp_max = {175, 192, 210, 228, 245, 262, 280, 298, 315, 333}
tt.hero.level_stats.armor = {0.05, 0.09, 0.13, 0.17, 0.21, 0.25, 0.29, 0.33, 0.37, 0.41}
tt.hero.level_stats.melee_damage_min = {12, 15, 19, 22, 26, 30, 33, 37, 40, 44}
tt.hero.level_stats.melee_damage_max = {20, 27, 33, 40, 46, 52, 59, 65, 72, 72}
tt.hero.skills.explosive_head = CC("hero_skill")
tt.hero.skills.explosive_head.damage = {40, 80, 120}
tt.hero.skills.explosive_head.xp_gain = {60, 120, 180}
tt.hero.skills.explosive_head.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.haunted_blade = CC("hero_skill")
tt.hero.skills.haunted_blade.cooldown = {12, 8, 4}
tt.hero.skills.haunted_blade.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.hero_jacko_melee = CC("hero_skill")
tt.hero.skills.hero_jacko_melee.accumulated_damage_factor = {1, 1.35, 1.7, 2}
tt.hero.skills.hero_jacko_melee.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.hero_jacko_thriller = CC("hero_skill")
tt.hero.skills.hero_jacko_thriller.max_bullets = {2, 3, 4}
tt.hero.skills.hero_jacko_thriller.xp_gain = {150, 300, 450}
tt.hero.skills.hero_jacko_thriller.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_jack_o_lantern_ultimate"
tt.hero.skills.ultimate.cooldown = {40, 40, 40, 40}
tt.hero.skills.ultimate.damage_over_time = {12, 20, 40, 60}
tt.hero.skills.ultimate.max_range = 250
tt.hero.skills.ultimate.min_targets = 5
tt.hero.skills.ultimate.range_nodes_max = 45
tt.hero.skills.ultimate.xp_gain = {100, 200, 300, 400}
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.fn_level_up = hero_jack_level_up
tt.health.accumulated_damage = 0
tt.health.accumulated_damage_factor = 0
tt.health.dead_lifetime = 15
tt.health.on_damage = hero_jack_on_damage
tt.health_bar.draw_order = -1
tt.health_bar.offset = v(0, 53)
tt.health_bar.sort_y_offset = -200
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.z = Z_FLYING_HEROES
tt.idle_flip.chance = 0
tt.info.hero_portrait = "kr4_hero_portraits_0014"
tt.info.portrait = "kr4_info_portraits_heroes_0015"
tt.main_script.update = hero_jack_update
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_max = 20
tt.melee.attacks[1].damage_min = 12
tt.melee.attacks[1].hit_time = fts(7)
tt.melee.attacks[1].mod = "mod_hero_jacko_revenge"
tt.melee.attacks[1].xp_gain_factor = 2.1
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "hauntedBlade"
tt.melee.attacks[2].cooldown = 4
tt.melee.attacks[2].damage_type = DAMAGE_MAGICAL
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].hit_time = fts(15)
tt.melee.attacks[2].mods = {"mod_hero_jacko_reduce_armor", "mod_hero_jacko_revenge"}
tt.melee.range = 60
tt.motion.max_speed = 80
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.281
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_jack_o_lantern"
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "hero_jack_o_lantern_shadow"
tt.render.sprites[2].anchor.y = 0.281
tt.render.sprites[2].z = Z_DECALS + 1
tt.soldier.melee_slot_offset = v(25, 0)
tt.sound_events.change_rally_point = "group_hero_jacko_taunt"
tt.sound_events.death = "hero_jacko_taunt_death"
tt.sound_events.hero_room_select = "hero_jacko_taunt_1"
tt.sound_events.insert = "hero_jacko_taunt_1"
tt.sound_events.respawn = "HeroLevelUp"
tt.teleport.animations = {"teleportOut", "teleportIn"}
tt.teleport.delay = 0
tt.teleport.fx_out = "hero_jack_o_lantern_teleportfx"
tt.teleport.min_distance = 150
tt.teleport.sound = "group_hero_jacko_teleport"
tt.timed_attacks.list[1] = CC("bullet_attack")
tt.timed_attacks.list[1].animation = "explosiveHead"
tt.timed_attacks.list[1].bullet = "bomb_explosive_head"
tt.timed_attacks.list[1].bullet_start_offset = {v(22, 36)}
tt.timed_attacks.list[1].cast_time = fts(14)
tt.timed_attacks.list[1].cooldown = 4
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].max_range = 175
tt.timed_attacks.list[1].node_prediction = fts(22)
tt.timed_attacks.list[1].vis_bans = bor(F_FRIEND, F_NIGHTMARE, F_CLIFF)
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[1].xp_from_skill = "explosive_head"
tt.timed_attacks.list[2] = CC("bullet_attack")
tt.timed_attacks.list[2].animation = "spawnGhouls"
tt.timed_attacks.list[2].bullet = "hero_jack_o_lantern_spawner_seed"
tt.timed_attacks.list[2].bullet_start_offset = {v(19, 55)}
tt.timed_attacks.list[2].cast_time = fts(10)
tt.timed_attacks.list[2].cooldown = 30
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].max_bullets = 2
tt.timed_attacks.list[2].max_nodes = -1
tt.timed_attacks.list[2].min_nodes = -3
tt.timed_attacks.list[2].min_targets = 2
tt.timed_attacks.list[2].range_nodes = 25
tt.timed_attacks.list[2].vis_bans = bor(F_FRIEND, F_FLYING)
tt.timed_attacks.list[2].xp_from_skill = "hero_jacko_thriller"
tt.ui.click_rect = r(-29, -5, 58, 105)
tt.ultimate = {
	ts = 0,
	cooldown = 40,
	disabled = true
}
tt.unit.head_offset = v(0, 48)
tt.unit.hit_offset = v(0, 30)
tt.unit.mod_offset = v(0, 30)
tt.vis.bans = bor(tt.vis.bans, F_EAT, F_NET)

tt = E:register_t("mod_hero_jacko_revenge", "mod_damage")
tt.damage_type = DAMAGE_MAGICAL
tt.main_script.insert = function(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or not target.health or target.health.dead then
		return false
	end
	local source = store.entities[this.modifier.source_id]
	if not source then
		return false
	end

	local value = source.health.accumulated_damage
	if value <= 0 then
		return false
	end

	source.health.accumulated_damage = 0

	local d = E.assign_damage(this.damage_type, value * this.modifier.damage_factor, this.modifier.source_id, target.id)
	d.xp_gain_factor = source.melee.attacks[1].xp_gain_factor
	d.xp_dest_id = source.id

	queue_damage(store, d)

	return false
end
