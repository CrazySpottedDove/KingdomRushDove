local scripts = require("scripts")
local A = require("animation_db")
local E = require("entity_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")
local bit = require("bit")
local apply_ultimate = HU.apply_ultimate
local bor = bit.bor
local find_target_at_critical_moment = HU.find_target_at_critical_moment
local fts = U.fts
local level_up_basic = HU.level_up_basic
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local v = V.v
local tt

local function decal_hero_asra_ultimate_insert(this, store)
	this.render.sprites[1].ts = store.tick_ts
	this.render.sprites[1].r = U.frandom(-10, 5) * math.pi / 180

	return true
end

local function arrow_hero_asra_ultimate_update(this, store)
	local b = this.bullet
	local speed = b.max_speed
	local ps = E:create_entity(b.particles_name)

	ps.particle_system.track_id = this.id
	ps.particle_system.emit = true

	simulation:queue_insert_entity(ps)

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) >= 2 * (speed * store.tick_length) do
		b.speed.x, b.speed.y = V.mul(speed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
		this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

		coroutine.yield()
	end

	local targets = U.find_enemies_in_range_filter_off(b.to, b.damage_radius, b.damage_flags, b.damage_bans)

	if targets then
		SU.apply_batch_bullet_simulation(this, targets, store)
	end

	local decal = E:create_entity(b.arrive_decal)

	decal.pos:copy(b.to)

	decal.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(decal)

	ps.particle_system.emit = false

	simulation:queue_remove_entity(this)
end

local function hero_asra_unreakable_mod_remove(this, store)
	if not scripts.mod_shield.remove(this, store) then
		return false
	end

	local target = store.entities[this.modifier.target_id]

	if target then
		local mod = E:create_entity("mod_hero_asra_unbreakable_broken")

		mod.modifier.target_id = target.id
		mod.modifier.source_id = target.id

		simulation:queue_insert_entity(mod)
	end

	return true
end

local function hero_asra_level_up(this, store)
	local hl, ls = level_up_basic(this)
	local b = E:get_template(this.ranged.attacks[1].bullet)

	b.bullet.damage_max = ls.ranged_damage_max[hl]
	b.bullet.damage_min = ls.ranged_damage_min[hl]
	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
	this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

	upgrade_skill(this, "spider_bite", function(this, s)
		this.melee.attacks[2].disabled = nil

		local e = E:get_template(this.melee.attacks[2].mod)

		e.dps.damage_max = s.damage_config[s.level]
		e.dps.damage_min = s.damage_config[s.level]
	end)
	upgrade_skill(this, "onix_arrows", function(this, s)
		this.ranged.attacks[2].disabled = nil
		this.ranged.attacks[2].max_loops = s.loops[s.level]
		this.ranged.attacks[2].loops = s.loops[s.level]

		local e = E:get_template(this.ranged.attacks[2].bullet)

		e.bullet.damage_max = s.damage_max[s.level]
		e.bullet.damage_min = s.damage_min[s.level]
	end)
	upgrade_skill(this, "quiver_of_sorrow", function(this, s)
		local e = E:get_template("mod_arrow_asra")

		e.damage_min = s.damage_armor[s.level]
		e.damage_max = s.damage_armor[s.level]
	end)
	upgrade_skill(this, "shield_of_shadows", function(this, s)
		this.unbreakable.disabled = nil
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		this.ultimate.disabled = nil

		local e = E:get_template("mod_hero_asra_ultimate_poison")

		e.dps.damage_min = s.damage_poison_config[s.level]
		e.dps.damage_max = s.damage_poison_config[s.level]
		e = E:get_template("arrow_hero_asra_ultimate")
		e.bullet.damage_min = s.damage_config[s.level]
		e.bullet.damage_max = s.damage_config[s.level]
	end)
	update_hp(this)
end

local function hero_asra_teleport_side_effect(this, store)
	SU.remove_modifiers(store, this, nil, "mod_hero_asra_unbreakable_broken")

	local m = E:create_entity("mod_hero_asra_shadow_dance")

	m.modifier.source_id = this.id
	m.modifier.target_id = this.id

	simulation:queue_insert_entity(m)
end

local function hero_asra_update(this, store)
	local h = this.health

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
					goto label_asra_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			local brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
				local enemy = find_target_at_critical_moment(this, this.ranged.attacks[1].max_range, F_RANGED, F_NONE, nil, true)

				if enemy and enemy.pos then
					apply_ultimate(this, store, enemy.pos, "special")
				else
					this.ultimate.ts = this.ultimate.ts + 1
				end
			end

			if brk or sta ~= A_NO_TARGET then
			-- handled
			else
				brk, sta = SU.y_soldier_ranged_attacks(store, this)

				if not brk then
					if SU.soldier_go_back_step(store, this) then
					-- handled
					else
						SU.soldier_idle(store, this)
						SU.soldier_regen(store, this)
					end
				end
			end
		end

		::label_asra_0::

		coroutine.yield()
	end
end

local function hero_asra_on_damage(this, store, damage)
	if ready_to_use_skill(this.unbreakable, store, this.unit.cooldown_factor) then
		this.unbreakable.ts = store.tick_ts

		local m = E:create_entity(this.unbreakable.mod)

		m.modifier.target_id = this.id
		m.modifier.source_id = this.id

		simulation:queue_insert_entity(m)
		S:queue(this.unbreakable.sound)
		SU.hero_gain_xp_from_skill(this, this.hero.skills.shield_of_shadows)

		return false
	end

	return true
end

local function hero_asra_ultimate_update(this, store)
	local function spawn_arrow(pi, spi, ni)
		spi = spi or math.random(1, 3)

		local pos = P:node_pos(pi, spi, ni)

		pos.x = pos.x + math.random(-4, 4)
		pos.y = pos.y + math.random(-5, 5)

		local b = E:create_entity(this.bullet)

		b.bullet.damage_factor = this.damage_factor
		b.bullet.from = V.v(pos.x + math.random(-170, -140), pos.y + REF_H)
		b.bullet.to = pos

		b.pos:copy(b.bullet.from)
		simulation:queue_insert_entity(b)
	end

	S:queue(this.sound)

	local nearest = P:nearest_nodes(this.pos.x, this.pos.y)

	if #nearest > 0 then
		local pi, spi, ni = unpack(nearest[1])

		spawn_arrow(pi, spi, ni)

		local count = this.spread
		local sequence = {}

		for i = 1, count do
			sequence[i] = i
		end

		while #sequence > 0 do
			local i = table.remove(sequence, math.random(1, #sequence))
			local delay = U.frandom(0, 1 / count)

			U.y_wait_unconditional(store, delay / 2)

			if P:is_node_valid(pi, ni + i) then
				spawn_arrow(pi, nil, ni + i)
			else
				spawn_arrow(pi, nil, ni - i)
			end

			U.y_wait_unconditional(store, delay / 2)

			if P:is_node_valid(pi, ni - i) then
				spawn_arrow(pi, nil, ni - i)
			else
				spawn_arrow(pi, nil, ni + i)
			end
		end
	end

	simulation:queue_remove_entity(this)
end

tt = RT("hero_asra", "hero")

AC(tt, "melee", "ranged", "teleport")

tt.hero.level_stats.armor = {0.07, 0.075, 0.08, 0.09, 0.10, 0.11, 0.12, 0.13, 0.14, 0.15}
tt.hero.level_stats.hp_max = {140, 160, 180, 200, 220, 240, 260, 280, 290, 300}
tt.hero.level_stats.melee_damage_max = {12, 14, 16, 18, 20, 22, 24, 26, 28, 30}
tt.hero.level_stats.melee_damage_min = {8, 10, 11, 12, 13, 15, 16, 17, 18, 19}
tt.hero.level_stats.ranged_damage_max = {16, 18, 20, 23, 25, 28, 30, 32, 34, 36}
tt.hero.level_stats.ranged_damage_min = {10, 12, 14, 15, 17, 18, 20, 22, 24, 26}
tt.hero.skills.spider_bite = CC("hero_skill")
tt.hero.skills.spider_bite.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.spider_bite.xp_gain = {300, 600, 900}
tt.hero.skills.spider_bite.damage_config = {20, 35, 50}
tt.hero.skills.onix_arrows = CC("hero_skill")
tt.hero.skills.onix_arrows.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.onix_arrows.loops = {4, 5, 6}
tt.hero.skills.onix_arrows.damage_min = {20, 35, 50}
tt.hero.skills.onix_arrows.damage_max = {30, 50, 70}
tt.hero.skills.quiver_of_sorrow = CC("hero_skill")
tt.hero.skills.quiver_of_sorrow.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.quiver_of_sorrow.damage_armor = {0.01, 0.02, 0.03}
tt.hero.skills.shield_of_shadows = CC("hero_skill")
tt.hero.skills.shield_of_shadows.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.shield_of_shadows.xp_gain = {120, 240, 360}
tt.hero.skills.shield_of_shadows.shield_max_damage = {200, 400, 600}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.ultimate.xp_gain = {100, 200, 300, 400}
tt.hero.skills.ultimate.controller_name = "hero_asra_ultimate"
tt.hero.skills.ultimate.damage_poison_config = {20, 30, 40, 50}
tt.hero.skills.ultimate.damage_config = {15, 25, 35, 45}
tt.health.dead_lifetime = 15
tt.health.on_damage = hero_asra_on_damage
tt.regen.cooldown = 1
tt.health_bar.offset = v(0, 36)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_asra_level_up
tt.hero.tombstone_show_time = fts(90)
tt.info.hero_portrait = "kr4_hero_portraits_0002"
tt.info.portrait = "kr4_info_portraits_heroes_0002"
tt.main_script.update = hero_asra_update
tt.motion.max_speed = FPS * 2.5
tt.soldier.melee_slot_offset = v(5, 0)
tt.sound_events.change_rally_point = "group_asra_taunt"
tt.sound_events.death = "hero_asra_death"
tt.sound_events.hero_room_select = "hero_asra_taunt_1"
tt.sound_events.insert = "hero_asra_taunt_1"
tt.sound_events.respawn = "HeroPaladinTauntIntro"
tt.unit.mod_offset = v(0, 20)
tt.teleport.min_distance = 120
tt.teleport.sound = "hero_asra_teleport"
tt.teleport.animations = {"teleportOut", "teleportIn"}
tt.teleport.side_effect = hero_asra_teleport_side_effect
tt.render.sprites[1].anchor.y = 0.12
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].scale = v(1, 1)
tt.render.sprites[1].prefix = "hero_asra"
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "hero_asra_shadow"
tt.render.sprites[2].anchor.y = 0.12
tt.render.sprites[2].z = Z_DECALS + 1
tt.melee.range = 60
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].cooldown = 0.8
tt.melee.attacks[1].damage_max = 10
tt.melee.attacks[1].damage_min = 5
tt.melee.attacks[1].animation = "melee"
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 2.2
tt.melee.attacks[2] = CC("melee_attack")
tt.melee.attacks[2].cooldown = 40
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].sound = "hero_asra_spiderbite"
tt.melee.attacks[2].damage_max = 1
tt.melee.attacks[2].damage_min = 1
tt.melee.attacks[2].animation = "meleePoison"
tt.melee.attacks[2].hit_time = fts(31)
tt.melee.attacks[2].mod = "mod_asra_poison"
tt.melee.attacks[2].vis_bans = bor(F_FLYING, F_CLIFF, F_BOSS)
tt.melee.attacks[2].vis_flags = bor(F_BLOCK, F_MOD, F_POISON)
tt.melee.attacks[2].xp_from_skill = "spider_bite"
tt.ranged.attacks[1] = CC("bullet_attack")
-- 实际攻速受动画限制为 1 秒, 但允许玩家通过走 A 到达极限攻速
tt.ranged.attacks[1].cooldown = 0.5
tt.ranged.attacks[1].min_range = 25
tt.ranged.attacks[1].max_range = 200
tt.ranged.attacks[1].animation = "shoot"
tt.ranged.attacks[1].bullet = "bullet_asra"
tt.ranged.attacks[1].shoot_time = fts(11)
tt.ranged.attacks[1].bullet_start_offset = {v(12, 12)}
tt.ranged.attacks[1].check_target_before_shot = true
tt.ranged.attacks[2] = CC("bullet_attack")
tt.ranged.attacks[2].cooldown = 13.5
tt.ranged.attacks[2].min_range = 25
tt.ranged.attacks[2].max_range = 200
tt.ranged.attacks[2].bullet = "bullet_onix_asra"
tt.ranged.attacks[2].max_loops = 3
tt.ranged.attacks[2].xp_gain = 90
tt.ranged.attacks[2].disabled = true
tt.ranged.attacks[2].shoot_times = {fts(5)}
tt.ranged.attacks[2].bullet_start_offset = {v(12, 12)}
tt.ranged.attacks[2].check_target_before_shot = true
tt.ranged.attacks[2].animations = {"multishotIn", "multishotLoop", "multishotOut"}
tt.ultimate = {
	ts = 0,
	cooldown = 40,
	disabled = true
}
tt.unbreakable = {
	cooldown = 20,
	ts = 0,
	mod = "hero_asra_unbreakable_mod",
	sound = "hero_asra_shield",
	xp_from_skill = "shield_of_shadows",
	disabled = true
}
tt = RT("bullet_asra", "arrow")
tt.bullet.xp_gain_factor = 2.4
tt.bullet.flight_time = fts(8)
tt.bullet.flight_time_factor = fts(1 / 60)
tt.bullet.g = 0
tt.bullet.hit_distance = 50
tt.bullet.hit_fx = "fx_arrow_asra_hit"
tt.bullet.mods = {"mod_arrow_asra"}
tt.bullet.miss_decal = "hero_asra_projectile_decal"
tt.render.sprites[1].name = "hero_asra_projectile"
tt.render.sprites[1].flip_x = true
tt = RT("bullet_onix_asra", "arrow")
tt.bullet.flight_time = fts(6)
tt.bullet.g = 0
tt.bullet.hit_fx = "fx_arrow_asra_hit"
tt.bullet.mods = {"mod_arrow_asra"}
tt.bullet.damage_type = DAMAGE_AGAINST_MAGIC_ARMOR
tt.bullet.miss_decal = "hero_asra_multishot_arrow_decal"
tt.bullet.miss_decal_rotation = math.pi
tt.render.sprites[1].name = "hero_asra_multishot_arrow"
tt.bullet.xp_gain_factor = 2.4
tt = RT("mod_hero_asra_shadow_dance", "mod_soldier_cooldown")
tt.modifier.duration = 8
tt.cooldown_factor = 0.75
tt = RT("fx_arrow_asra_hit", "fx")
tt.render.sprites[1].name = "hero_asra_multishot_arrow_hit_run"
tt = RT("mod_arrow_asra", "mod_damage")
tt.damage_type = DAMAGE_ARMOR
tt = RT("mod_asra_poison", "mod_poison")
tt.modifier.duration = 99999
tt.dps.damage_max = 20
tt.dps.damage_min = 20
tt.dps.damage_every = 0.5
tt.dps.kill = true
tt.dps.damage_type = bor(DAMAGE_POISON, DAMAGE_NO_SHIELD_HIT)
tt = RT("hero_asra_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.bullet = "arrow_hero_asra_ultimate"
tt.sound = "hero_asra_ultimate_poison"
tt.spread = 8
tt.main_script.update = hero_asra_ultimate_update
tt = RT("arrow_hero_asra_ultimate", "bullet")
tt.main_script.update = arrow_hero_asra_ultimate_update
tt.bullet.damage_radius = 50
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_bans = F_FRIEND
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.damage_min = 10
tt.bullet.damage_max = 10
tt.bullet.arrive_decal = "decal_hero_asra_ultimate"
tt.bullet.max_speed = 1500
tt.bullet.mods = {"mod_hero_asra_ultimate_poison"}
tt.render.sprites[1].name = "hero_asra_special_arrow"
tt.render.sprites[1].animated = false
tt.render.sprites[1].scale = v(-1, 1)
tt.render.sprites[1].anchor.x = 0.9629629629629629
tt.sound_events.insert = "ArrowSound"
tt.bullet.particles_name = "ps_arrow_hero_asra_ultimate"
tt = RT("ps_arrow_hero_asra_ultimate")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "hero_asra_special_arrow_particle"
tt.particle_system.alphas = {255, 0}
tt.particle_system.emission_rate = 60
tt.particle_system.particle_lifetime = {fts(6), fts(6)}
tt = RT("mod_hero_asra_ultimate_poison", "mod_poison")
tt.modifier.duration = 2
tt.dps.damage_max = 10
tt.dps.damage_min = 10
tt.dps.damage_every = 0.5
tt.dps.kill = true
tt.dps.damage_type = bor(DAMAGE_POISON, DAMAGE_NO_SHIELD_HIT)
tt = RT("decal_hero_asra_ultimate", "decal_tween")

AC(tt, "main_script")

tt.main_script.insert = decal_hero_asra_ultimate_insert
tt.tween.props[1].keys = {{0, 255}, {1, 255}, {4, 0}}
tt.render.sprites[1].name = "hero_asra_special_poison_explosion_run"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt = RT("hero_asra_unbreakable_mod", "modifier")

AC(tt, "render", "health_bar", "health")

tt.modifier.vis_flags = bor(F_MOD)
tt.modifier.duration = 6
tt.modifier.use_mod_offset = false
tt.shield_max_damage = 200
tt.damage_taken = 0
tt.main_script.insert = scripts.mod_shield.insert
tt.main_script.update = scripts.mod_shield.update
tt.main_script.remove = hero_asra_unreakable_mod_remove
tt.health_bar.offset = v(0, 42)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.colors = {}
tt.health_bar.colors.fg = {128, 0, 255, 255}
tt.health_bar.colors.bg = {0, 0, 0, 255}
tt.health_bar.sort_y_offset = -2
tt.health_bar.disable_fade = true
tt.animation_start = "start"
tt.animation_loop = "idle"
tt.animation_end = "end"
tt.render.sprites[1].prefix = "hero_asra_shield"
tt.render.sprites[1].offset = v(0, 20)
tt.render.sprites[1].name = "idle"
tt = RT("mod_hero_asra_unbreakable_broken", "modifier")

AC(tt, "render")

tt.modifier.duration = 6
tt.modifier.vis_flags = F_MOD
tt.render.sprites[1].name = "paladin_soldiers_lvl4_captain_armor_mod_decal"
tt.render.sprites[1].loop = false
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].scale = v(1.1, 1.1)
tt.modifier.use_mod_offset = false
tt.inflicted_damage_factor = 1.5
tt.main_script.insert = scripts.mod_damage_factors.insert
tt.main_script.remove = scripts.mod_damage_factors.remove
tt.main_script.update = scripts.mod_track_target.update
