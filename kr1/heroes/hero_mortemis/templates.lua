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
local band = bit.band
local bor = bit.bor
local find_target_at_critical_moment = HU.find_target_at_critical_moment
local fts = U.fts
local level_up_basic = HU.level_up_basic
local queue_damage = U.queue_damage
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local v = V.v
local tt

local function aura_mortemis_zombie_update(this, store)
	local last_ts = store.tick_ts
	local zombies = {}

	local function filter_fn(v)
		return v.health.dead and band(v.vis.bans, F_SKELETON) == 0 and band(v.health.last_damage_types, DAMAGE_EAT) == 0 and store.tick_ts - v.health.death_ts >= v.health.dead_lifetime - this.aura.cycle_time
	end

	while true do
		local source = store.entities[this.aura.source_id]

		if not source then
			simulation:queue_remove_entity(this)

			return
		end

		if not source.health.dead then
			if store.tick_ts - last_ts >= this.aura.cycle_time then
				last_ts = store.tick_ts

				local zombies_count = 0

				for i = #zombies, 1, -1 do
					local e = zombies[i]

					if e.health.dead then
						table.remove(zombies, i)
					else
						if U.is_inside_ellipse(e.pos, source.pos, this.aura.radius) then
							zombies_count = zombies_count + 1
						end
					end
				end

				local max_spawns = this.max_count - zombies_count

				if max_spawns < 1 then
				-- block empty
				else
					local dead_enemies = U.find_enemies_in_range_filter_override(source.pos, this.aura.radius, filter_fn)

					if #dead_enemies > 0 then
						dead_enemies = table.slice(dead_enemies, 1, max_spawns)

						for _, dead in ipairs(dead_enemies) do
							U.bans_add(dead.vis, F_SKELETON)

							dead.health.delete_after = 0

							local e = E:create_entity(this.spawn_name)

							e.pos:copy(dead.pos)

							if dead.enemy.necromancer_offset then
								e.pos.x = e.pos.x + dead.enemy.necromancer_offset.x * (dead.render.sprites[1].flip_x and -1 or 1)
								e.pos.y = e.pos.y + dead.enemy.necromancer_offset.y
							end

							e.nav_rally.center:copy(e.pos)
							e.nav_rally.pos:copy(e.pos)

							zombies[#zombies + 1] = e

							simulation:queue_insert_entity(e)
						end
					end
				end
			end
		end

		coroutine.yield()
	end
end

local function mortemis_poisonpool_insert(this, store)
	if not scripts.aura_apply_mod.insert(this, store) then
		return false
	end

	local duration = this.actual_duration
	local smoke_offsets = {v(-17, 5), v(6, 13), v(3, -5), v(23, 3)}

	for i = 1, 4 do
		local decal = E:create_entity("decal_tween")

		decal.pos:set(this.pos.x + smoke_offsets[i].x, this.pos.y + smoke_offsets[i].y)

		decal.tween.props[1].keys = {{0, 0}, {0.5, 255}, {duration - 0.5, 255}, {duration, 0}}
		decal.tween.props[1].name = "alpha"
		decal.render.sprites[1].z = Z_OBJECTS
		decal.render.sprites[1].ts = store.tick_ts
		decal.render.sprites[1].time_offset = i * 6 / FPS
		decal.render.sprites[1].name = "hero_mortemis_fumes_fx_run"

		simulation:queue_insert_entity(decal)
	end

	return true
end

local function hero_mortemis_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local bt = E:get_template(this.ranged.attacks[1].bullet)

	bt.bullet.damage_min = ls.ranged_damage_min[hl]
	bt.bullet.damage_max = ls.ranged_damage_max[hl]

	-- 1技能 恐吓
	upgrade_skill(this, "call_haunted", function(this, s)
		this.timed_attacks.list[1].disabled = nil

		local e = E:get_template(this.timed_attacks.list[1].mod)

		e.modifier.duration = s.duration[s.level]
	end)
	-- 2技能 毒池
	upgrade_skill(this, "deadly_fumes", function(this, s)
		this.timed_attacks.list[2].disabled = nil

		local e = E:get_template("mod_mortemis_magma")

		e.dps.damage_min = s.damage_config[s.level]
		e.dps.damage_max = s.damage_config[s.level]
	end)
	-- 3技能 削甲
	upgrade_skill(this, "grim_presence", function(this, s)
		this.render.sprites[2].name = "hero_mortemis_aura"
		this.render.sprites[2].offset = v(0, 0)

		local e1 = E:get_template("mod_mortemis_curse_armor")

		e1.armor_buff.max_factor = s.armor_reduction[s.level]
	end)
	-- 4技能 不死人之奴
	upgrade_skill(this, "undead_servitude", function(this, s)
		local e = E:get_template("hero_mortemis_zombie")

		e.health.hp_max = s.hp_max[s.level]
		e.melee.attacks[1].damage_min = s.damage_min[s.level]
		e.melee.attacks[1].damage_max = s.damage_max[s.level]
	end)
	-- 大招 腐朽近卫
	upgrade_skill(this, "ultimate", function(this, s)
		this.ultimate.disabled = nil

		local e = E:get_template("hero_mortemis_golem")

		e.health.hp_max = s.hp_max[s.level]
		e.melee.attacks[1].damage_min = s.damage_min[s.level]
		e.melee.attacks[1].damage_max = s.damage_max[s.level]
	end)
	update_hp(this)
end

local function hero_mortemis_update(this, store)
	local h = this.health
	local a, skill, brk, sta

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			local ds = this.death_spawns

			for i = 1, ds.quantity do
				local e = E:create_entity(ds.name)
				local angle = 2 * math.pi * (i - 1) / ds.quantity

				e.pos:set(this.pos.x + ds.spawn_radius * math.cos(angle), this.pos.y + ds.spawn_radius * math.sin(angle))
				e.nav_rally.pos:copy(e.pos)
				e.nav_rally.center:copy(e.pos)
				simulation:queue_insert_entity(e)
			end

			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_2791_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			-- 1技能 恐吓
			a = this.timed_attacks.list[1]
			skill = this.hero.skills.call_haunted

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local target = U.find_first_enemy_in_range_filter_on(this.pos, a.max_range, a.vis_flags, a.vis_bans, SU.is_valid_scare_target)

				if target then
					U.animation_start_default(this, a.animation, nil, store.tick_ts, false)
					S:queue(a.sound)

					if SU.y_hero_wait(store, this, a.cast_time) then
						goto label_2791_0
					end

					local _, targets = U.find_foremost_enemy_in_range_filter_on(this.pos, a.max_range, nil, a.vis_flags, a.vis_bans, SU.is_valid_scare_target)

					if targets then
						a.ts = store.tick_ts

						SU.hero_gain_xp_from_skill(this, skill)

						for i = 1, math.min(a.max_target, #targets) do
							local mod = E:create_entity(a.mod)

							mod.modifier.target_id = targets[i].id
							mod.modifier.source_id = this.id
							mod.modifier.level = skill.level

							simulation:queue_insert_entity(mod)
							SU.scare_enemy(targets[i], {
								duration = mod.modifier.duration,
								friend_mod = mod.template_name
							})
						end
					else
						a.ts = a.ts + 5
					end

					if SU.y_hero_animation_wait(this) then
						goto label_2791_0
					end
				else
					a.ts = a.ts + 0.1
				end
			end

			-- 2技能 毒池
			a = this.timed_attacks.list[2]
			skill = this.hero.skills.deadly_fumes

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local target = U.find_random_enemy(store, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if not target then
					a.ts = a.ts + 0.1
				else
					local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni
					local nodes = P:nearest_nodes(this.pos.x, this.pos.y, {pi}, nil, nil, NF_RALLY)

					if #nodes < 1 then
						a.ts = a.ts + 0.1
					else
						local s_pi, _, s_ni = unpack(nodes[1])
						local flip = target.pos.x < this.pos.x

						S:queue(a.sound)
						U.animation_start_once_specific(this, a.animation, flip, store.tick_ts, 1)

						if SU.y_hero_wait(store, this, a.spawn_time) then
							goto label_2791_0
						end

						a.ts = store.tick_ts

						SU.hero_gain_xp_from_skill(this, skill)

						local n_step = ni < s_ni and -4 or 4

						ni = km.clamp(1, #P:path(s_pi), ni < s_ni and ni + 6 or ni)

						for i = 1, skill.count[skill.level] do
							local e = E:create_entity(a.entity)

							e.pos = P:node_pos(pi, spi, ni)
							e.render.sprites[1].flip_x = not flip
							e.render.sprites[1].ts = store.tick_ts
							e.aura.damage_factor = this.unit.damage_factor

							simulation:queue_insert_entity(e)

							ni = ni + n_step
							spi = km.zmod(spi + math.random(1, 2), 3)

							U.y_wait_unconditional(store, fts(5 * this.unit.cooldown_factor))
						end

						if SU.y_hero_animation_wait(this) then
							goto label_2791_0
						end
					end
				end
			end

			-- 大招 腐朽近卫
			skill = this.hero.skills.ultimate

			if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
				local target = find_target_at_critical_moment(this, this.ranged.attacks[1].max_range, F_BLOCK, F_FLYING, nil, nil, true)

				if target then
					U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
					S:queue(this.sound_events.change_rally_point)

					local e = E:create_entity(this.hero.skills.ultimate.controller_name)

					e.pos = target.pos:clone()

					simulation:queue_insert_entity(e)

					this.ultimate.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, skill)
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

		::label_2791_0::

		coroutine.yield()
	end
end

local function controller_hero_mortemis_ultimate_update(this, store)
	local e = E:create_entity(this.entity)

	e.pos:copy(this.pos)
	e.nav_rally.pos:copy(e.pos)
	e.nav_rally.center:copy(e.pos)
	simulation:queue_insert_entity(e)
	S:queue(this.sound)
	simulation:queue_remove_entity(this)
end

local function bolt_mortemis_update(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local mspeed = b.min_speed
	local target = store.entities[b.target_id]
	local ps = E:create_entity(b.particles_name)

	ps.particle_system.track_id = this.id

	simulation:queue_insert_entity(ps)
	S:queue(this.sound_events.travel)
	U.animation_start_default(this, "flying", nil, store.tick_ts, s.loop)

	ps.particle_system.emit = true

	local damage_value

	-- 先结算
	if target then
		this.pos:set(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)

		local d = SU.create_bullet_damage(b, target.id, this.id)

		d.xp_dest_id = b.source_id
		damage_value = d.value

		queue_damage(store, d)

		local mods = b.mods or {b.mod}

		if mods then
			for _, mod_name in ipairs(mods) do
				local m = E:create_entity(mod_name)

				m.modifier.damage_factor = b.damage_factor
				m.modifier.target_id = b.target_id
				m.modifier.level = b.level

				simulation:queue_insert_entity(m)
			end
		end

		local sfx = E:create_entity(b.hit_fx)

		sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
		sfx.render.sprites[1].ts = store.tick_ts
		sfx.render.sprites[1].runs = 0

		simulation:queue_insert_entity(sfx)
	else
		this.pos:copy(b.to)
	end

	local source = store.entities[b.source_id]

	if source then
		b.to:set(source.pos.x + source.unit.hit_offset.x, source.pos.y + source.unit.hit_offset.y)

		while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
			mspeed = mspeed + FPS * math.ceil(mspeed * (1 / FPS) * b.acceleration_factor)
			mspeed = km.clamp(b.min_speed, b.max_speed, mspeed)
			b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
			this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
			s.r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)
			ps.particle_system.emit_direction = s.r

			coroutine.yield()
			b.to:set(source.pos.x + source.unit.hit_offset.x, source.pos.y + source.unit.hit_offset.y)
		end

		this.pos:set(source.pos.x + source.unit.hit_offset.x, source.pos.y + source.unit.hit_offset.y)

		if not source.health.dead and damage_value ~= nil then
			local sfx = E:create_entity(b.hit_fx)

			sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
			sfx.render.sprites[1].ts = store.tick_ts
			sfx.render.sprites[1].runs = 0

			simulation:queue_insert_entity(sfx)
			U.heal(source, damage_value * b.heal_factor)
		end
	end

	ps.particle_system.emit = false

	simulation:queue_remove_entity(this)
end

tt = RT("hero_mortemis", "hero")

AC(tt, "melee", "ranged", "timed_attacks", "death_spawns", "auras")

tt.melee.range = 45
tt.regen.cooldown = 1
tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.hp_max = {140, 160, 180, 200, 220, 240, 270, 300, 330, 360}
tt.hero.level_stats.melee_damage_max = {9, 10, 11, 12, 13, 14, 16, 18, 19, 21}
tt.hero.level_stats.melee_damage_min = {5, 6, 6, 7, 7, 8, 9, 9, 10, 11}
tt.hero.level_stats.ranged_damage_min = {9, 10, 11, 12, 13, 14, 16, 18, 19, 21}
tt.hero.level_stats.ranged_damage_max = {48, 54, 60, 69, 75, 81, 92, 103, 115, 120}
tt.hero.skills.call_haunted = CC("hero_skill")
tt.hero.skills.call_haunted.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.call_haunted.xp_gain = {150, 300, 450}
tt.hero.skills.call_haunted.duration = {4, 6, 8}
tt.hero.skills.deadly_fumes = CC("hero_skill")
tt.hero.skills.deadly_fumes.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.deadly_fumes.xp_gain = {100, 200, 300}
tt.hero.skills.deadly_fumes.count = {1, 1, 1}
tt.hero.skills.deadly_fumes.damage_config = {1, 2, 3}
tt.hero.skills.grim_presence = CC("hero_skill")
tt.hero.skills.grim_presence.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.grim_presence.armor_reduction = {-0.1, -0.2, -0.3}
tt.hero.skills.undead_servitude = CC("hero_skill")
tt.hero.skills.undead_servitude.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.undead_servitude.hp_max = {60, 110, 160}
tt.hero.skills.undead_servitude.damage_min = {2, 4, 6}
tt.hero.skills.undead_servitude.damage_max = {4, 6, 8}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.ultimate.controller_name = "hero_mortemis_ultimate"
tt.hero.skills.ultimate.hp_max = {500, 600, 700, 800}
tt.hero.skills.ultimate.damage_min = {5, 8, 16, 25}
tt.hero.skills.ultimate.damage_max = {13, 25, 50, 75}
tt.hero.skills.ultimate.xp_gain = {120, 240, 360, 480}
tt.ultimate = {
	ts = 0,
	cooldown = 48,
	disabled = true
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = v(0, 36)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.tombstone_show_time = fts(90)
tt.main_script.update = hero_mortemis_update
tt.hero.fn_level_up = hero_mortemis_level_up
tt.info.portrait = "kr4_info_portraits_heroes_0005"
tt.info.hero_portrait = "kr4_hero_portraits_0004"
tt.motion.max_speed = 60
tt.soldier.melee_slot_offset = v(5, 0)
tt.sound_events.change_rally_point = "group_mortemis_taunt"
tt.sound_events.death = "hero_mortemis_death"
tt.sound_events.hero_room_select = "hero_mortemis_taunt_1"
tt.sound_events.insert = "hero_mortemis_taunt_1"
tt.sound_events.respawn = "HeroPaladinTauntIntro"
tt.unit.mod_offset = v(0, 20)
tt.death_spawns.name = "hero_mortemis_zombie"
tt.death_spawns.quantity = 3
tt.death_spawns.spawn_radius = 20
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.delay = fts(19)
tt.render.sprites[1].anchor = v(0.5, 0.04)
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].offset = v(0, -25)
tt.render.sprites[1].prefix = "hero_mortemis"
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].offset = v(0, 20)
tt.render.sprites[2].name = "hero_mortemis_zombie_golem_shadow"
tt.render.sprites[2].z = Z_DECALS + 1
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(17)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 2.5
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].cooldown = 1.8
tt.ranged.attacks[1].min_range = 25
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].check_target_before_shot = true
tt.ranged.attacks[1].bullet = "bolt_mortemis"
tt.ranged.attacks[1].shoot_time = fts(25)
tt.ranged.attacks[1].bullet_start_offset = {v(-12, 36)}
tt.timed_attacks.list[1] = CC("mod_attack")
tt.timed_attacks.list[1].xp_from_skill = "call_haunted"
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].mod = "hero_mortemis_modifier_fear"
tt.timed_attacks.list[1].max_target = 3
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].max_range = 120
tt.timed_attacks.list[1].cooldown = 27
tt.timed_attacks.list[1].cast_time = fts(19)
tt.timed_attacks.list[1].animation = "callHunted"
tt.timed_attacks.list[1].sound = "hero_mortemis_call"
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED, F_SCARE, F_MOD)
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING, F_CLIFF, F_WATER)
tt.timed_attacks.list[2] = CC("spawn_attack")
tt.timed_attacks.list[2].xp_from_skill = "deadly_fumes"
tt.timed_attacks.list[2].animation = "deadlyFumes"
tt.timed_attacks.list[2].sound = "hero_mortemis_rotten"
tt.timed_attacks.list[2].cooldown = 20
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].entity = "mortemis_poisonpool"
tt.timed_attacks.list[2].spawn_time = fts(16)
tt.timed_attacks.list[2].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[2].min_range = 0
tt.timed_attacks.list[2].max_range = 150
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "aura_mortemis_curse_armor"
tt.auras.list[1].cooldown = 0
tt.auras.list[2] = CC("aura_attack")
tt.auras.list[2].name = "aura_mortemis_zombie"
tt.auras.list[2].cooldown = 0
tt = RT("bolt_mortemis", "bolt")
tt.main_script.update = bolt_mortemis_update
tt.render.sprites[1].prefix = "bolt_necromancer"
tt.bullet.damage_min = 20
tt.bullet.damage_max = 70
tt.bullet.xp_gain_factor = 2
tt.bullet.hit_fx = "fx_bolt_mortemis_hit"
tt.bullet.particles_name = "ps_bolt_mortemis_trail"
tt.bullet.pop = {"pop_sishh"}
tt.sound_events.insert = "NecromancerBolt"
tt.bullet.heal_factor = 0.5
tt = RT("fx_bolt_mortemis_hit", "fx")
tt.render.sprites[1].name = "hero_mortemis_soul_proyectile_hit"
tt = RT("ps_bolt_mortemis_trail")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "hero_mortemis_soul_proyectile_travel"
tt.particle_system.animated = true
tt.particle_system.particle_lifetime = {0.4, 2}
tt.particle_system.alphas = {255, 0}
tt.particle_system.scales_x = {1, 3.5}
tt.particle_system.scales_y = {1, 3.5}
tt.particle_system.scale_var = {0.45, 0.9}
tt.particle_system.emit_spread = math.pi
tt.particle_system.emission_rate = 30
tt = RT("hero_mortemis_modifier_fear", "modifier")

AC(tt, "render")

tt.main_script.insert = scripts.mod_track_target.insert
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.duration = 6
tt.modifier.vis_bans = bor(F_BOSS)
tt.render.sprites[1].name = "hero_mortemis_call_of_the_haunted_run"
tt.render.sprites[1].draw_order = DO_MOD_FX
tt = RT("mortemis_poisonpool", "aura")

AC(tt, "render", "tween")

tt.aura.cycle_time = 0.3
tt.aura.duration = 10
tt.aura.mod = "mod_mortemis_magma"
tt.aura.radius = 60
tt.aura.vis_bans = bor(F_FRIEND, F_FLYING)
tt.aura.vis_flags = bor(F_MOD)
tt.main_script.insert = mortemis_poisonpool_insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.render.sprites[1].name = "hero_mortemis_fumes_decal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {0.5, 255}, {"this.aura.duration-0.5", 255}, {"this.aura.duration", 0}}
tt = RT("mod_mortemis_magma", "mod_poison")
tt.dps.damage_min = 1
tt.dps.damage_max = 1
tt.dps.damage_every = fts(4)
tt.dps.kill = true
tt.modifier.duration = 1
tt = RT("mod_mortemis_curse_armor", "modifier")

AC(tt, "armor_buff", "render")

tt.modifier.duration = 2
tt.modifier.vis_flags = F_MOD
tt.armor_buff.both = true
tt.armor_buff.max_factor = -0.1
tt.armor_buff.cycle_time = 1e+99
tt.main_script.insert = scripts.mod_armor_buff.insert
tt.main_script.remove = scripts.mod_armor_buff.remove
tt.main_script.update = scripts.mod_armor_buff.update
tt.render.sprites[1].name = "hero_mortemis_aura"
tt.render.sprites[1].animated = false
tt.render.sprites[1].scale = v(0.9, 0.9)
tt.render.sprites[1].z = Z_DECALS
tt.modifier.use_mod_offset = false
tt = RT("aura_mortemis_curse_armor", "aura")
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.aura.duration = -1
tt.aura.radius = 150
tt.aura.mods = {"mod_mortemis_curse_armor"}
tt.aura.requires_alive_source = true
tt.aura.track_source = true
tt.aura.track_dead = true
tt.aura.vis_bans = F_FRIEND
tt.aura.vis_flags = bor(F_MOD, F_AREA)
tt = RT("aura_mortemis_zombie", "aura")
tt.spawn_name = "hero_mortemis_zombie"
tt.main_script.update = aura_mortemis_zombie_update
tt.aura.duration = -1
tt.aura.radius = 150
tt.max_count = 6
tt = RT("hero_mortemis_zombie", "soldier_militia")

AC(tt, "reinforcement")

tt.health_bar.offset = v(0, 35)
tt.health.dead_lifetime = 2
tt.unit.hit_offset = v(0, 16)
tt.unit.head_offset = v(0, 29)
tt.unit.mod_offset = v(0, 16)
tt.unit.marker_offset = v(0, 0)
tt.info.portrait = "kr4_info_portraits_soldiers_0021"
tt.info.random_name_format = nil
tt.info.random_name_count = nil
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.soldier_reinforcement.update
tt.motion.max_speed = 45
tt.render.sprites[1].prefix = "hero_mortemis_zombie"
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].offset.y = -10
tt.render.sprites[1].anchor.y = 0.125
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "hero_mortemis_zombie_shadow"
tt.render.sprites[2].anchor.y = 0.125
tt.render.sprites[2].offset.y = -10
tt.render.sprites[2].z = Z_DECALS + 1
tt.soldier.melee_slot_offset = v(16, 0)
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 3
tt.melee.attacks[1].damage_min = 1
tt.melee.attacks[1].hit_time = fts(17)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].sound_args = {
	delay = fts(13)
}
tt.regen.health = 0
tt.regen.cooldown = 9999
tt.reinforcement.duration = 32
tt.reinforcement.fade = false
tt.reinforcement.fade_in = false
tt.reinforcement.fade_out = false
tt.ui.click_rect = r(-20, -5, 40, 28)
tt = RT("hero_mortemis_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.cooldown = 48
tt.main_script.update = controller_hero_mortemis_ultimate_update
tt.sound_events.insert = "hero_mortemis_bodyguard"
tt.entity = "hero_mortemis_golem"
tt.vis_flags = bor(F_RANGED, F_BLOCK)
tt.vis_bans = F_FLYING
tt.sound = "hero_mortemis_bodyguard"
tt = RT("hero_mortemis_golem", "soldier_militia")

AC(tt, "reinforcement", "nav_grid")

tt.controable = true
tt.controable_other = true
tt.health.dead_lifetime = 2
tt.health.hp_max = 500
tt.health_bar.offset = v(0, 52)
tt.unit.hit_offset = v(0, 16)
tt.unit.head_offset = v(0, 29)
tt.unit.mod_offset = v(0, 16)
tt.unit.marker_offset = v(0, 0)
tt.info.portrait = "kr4_info_portraits_soldiers_0022"
tt.info.random_name_format = nil
tt.info.random_name_count = nil
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.soldier_reinforcement.update
tt.motion.max_speed = 45
tt.render.sprites[1].prefix = "hero_mortemis_zombie_golem"
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].offset.y = -10
tt.render.sprites[1].anchor.y = 0.125
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "hero_mortemis_zombie_golem_shadow"
tt.render.sprites[2].anchor.y = 0.125
tt.render.sprites[2].offset.y = -10
tt.render.sprites[2].z = Z_DECALS + 1
tt.soldier.melee_slot_offset = v(16, 0)
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 1.4
tt.melee.attacks[1].count = 99
tt.melee.attacks[1].damage_max = 10
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].damage_radius = 40
tt.melee.attacks[1].mod = "hero_mortemis_golem_stun"
tt.melee.attacks[1].damage_type = DAMAGE_TRUE
tt.melee.attacks[1].hit_decal = "decal_ground_hit"
tt.melee.attacks[1].hit_fx = "hero_mortemis_zombie_golem_attack_rocks"
tt.melee.attacks[1].hit_offset = v(30, 0)
tt.melee.attacks[1].hit_time = fts(23)
tt.melee.attacks[1].sound = "AreaAttack"
tt.melee.attacks[1].sound_args = {
	delay = fts(13)
}
tt.regen.health = 0
tt.regen.cooldown = 2
tt.reinforcement.duration = 20
tt.reinforcement.fade = false
tt.reinforcement.fade_in = false
tt.reinforcement.fade_out = false
tt.ui.click_rect = r(-20, -5, 40, 28)
tt = RT("hero_mortemis_zombie_golem_attack_rocks", "fx")
tt.render.sprites[1].name = "hero_mortemis_zombie_golem_attack_rocks"
tt = RT("hero_mortemis_golem_stun", "mod_stun")
tt.modifier.duration = 1.2
-- ======== 极狗 ========
anchor_x, anchor_y = 0.5, 0.12
image_x, image_y = 92, 110
