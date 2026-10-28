local bit = require("bit")
local E = require("entity_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")
local km = require("lib.klua.macros")
local scripts = require("scripts")
local log = require("lib.klua.log"):new("hero_pirate")

require("lib.klua.table")
require("all.constants")

local bor = bit.bor
local v = V.v
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local update_regen = HU.update_regen
local update_hp = HU.update_hp

local function kraken_aura_insert(this, store)
	scripts.aura_apply_mod.insert(this, store)

	local e = E:create_entity("decal_kraken")

	e.pos.x, e.pos.y = this.pos.x, this.pos.y

	simulation:queue_insert_entity(e)

	return true
end

local function decal_kraken_update(this, store)
	local start_ts = store.tick_ts

	U.y_animation_play(this, "start", nil, store.tick_ts)
	U.animation_start_default(this, "loop", nil, store.tick_ts, true)

	while store.tick_ts - start_ts < this.duration do
		coroutine.yield()
	end

	U.y_animation_play(this, "end", nil, store.tick_ts, 1)
	simulation:queue_remove_entity(this)
end

local function pirate_exploding_barrel_update(this, store)
	local b = this.bullet

	this.render.sprites[1].r = 20 * math.pi / 180 * (b.to.x > b.from.x and 1 or -1)

	while store.tick_ts - b.ts < b.flight_time do
		b.last_pos.x, b.last_pos.y = this.pos.x, this.pos.y
		this.pos.x, this.pos.y = SU.position_in_parabola(store.tick_ts - b.ts, b.from, b.speed, b.g)

		if b.align_with_trajectory then
			this.render.sprites[1].r = V.angleTo(this.pos.x - b.last_pos.x, this.pos.y - b.last_pos.y)
		elseif b.rotation_speed then
			this.render.sprites[1].r = this.render.sprites[1].r + b.rotation_speed * store.tick_length
		end

		coroutine.yield()
	end

	if b.hit_fx then
		S:queue(this.sound_events.hit)

		local sfx = E:create_entity(b.hit_fx)

		sfx.pos:copy(b.to)

		sfx.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(sfx)
	end

	local center = v(this.pos.x, this.pos.y - 80)

	center.x, center.y = center.x + math.random(-4, 4), center.y + math.random(-4, 4)

	local angle = 0
	local min_angle = 2 * math.pi / this.fragments

	for i = 1, this.fragments do
		angle = angle + min_angle + U.frandom(0, math.pi / 6)

		local bf = E:create_entity("barrel_fragment")

		bf.bullet.from:copy(this.pos)

		bf.bullet.to = U.point_on_ellipse(center, (50 * math.random() + 45) * 0.5, angle)
		bf.bullet.flight_time = U.frandom(fts(16), fts(20))
		bf.render.sprites[1].r = 100 * math.random() * (math.pi / 180)

		if i > 1 then
			bf.sound_events.hit = nil
		end

		simulation:queue_insert_entity(bf)
	end

	simulation:queue_remove_entity(this)
end

local function mod_pirate_loot_insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or not target.health or target.health.dead then
		return false
	end

	this.extra_loot = math.ceil(target.enemy.gold * this.percent)
	target.enemy.gold = target.enemy.gold + this.extra_loot

	return true
end

local function mod_pirate_loot_update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	while store.tick_ts - m.ts < m.duration and target and not target.health.dead do
		coroutine.yield()
	end

	if target then
		if target.health.dead and target.enemy.gold > 0 then
			local fx = E:create_entity("fx_coin_jump")

			fx.pos.x, fx.pos.y = target.pos.x, target.pos.y
			fx.render.sprites[1].ts = store.tick_ts

			if target.health_bar then
				fx.render.sprites[1].offset.y = target.health_bar.offset.y
			end

			simulation:queue_insert_entity(fx)
		else
			target.enemy.gold = km.clamp(0, target.enemy.gold, target.enemy.gold - this.extra_loot)
		end
	end

	simulation:queue_remove_entity(this)
end

local function mod_stun_kraken_insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead then
		return false
	end

	local ka = store.entities[this.modifier.source_id]

	if ka and ka.max_active_targets and ka.active_targets_count >= ka.max_active_targets then
		return false
	end

	if target and target.unit and this.render then
		local s = this.render.sprites[1]

		if s.size_names then
			s.prefix = s.prefix .. "_" .. s.size_names[target.unit.size]
			s.flip_x = target.render.sprites[1].flip_x
		end

		if this.modifier.use_mod_offset and target.unit.mod_offset then
			s.offset.x, s.offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
		end

		s.flip_x = false
	end

	this.modifier.duration = ka.aura.duration - (store.tick_ts - ka.aura.ts)
	ka.active_targets_count = ka.active_targets_count + 1
	this.modifier.ts = store.tick_ts

	log.paranoid("aura: %s, mod duration ttl: %f", ka.id, this.modifier.duration)

	local target = store.entities[this.modifier.target_id]

	if target and not target.health.dead then
		SU.stun_inc(target)
	end

	return true
end

local function mod_stun_kraken_remove(this, store)
	local ka = store.entities[this.modifier.source_id]

	if ka and ka.max_active_targets and ka.active_targets_count > 0 then
		ka.active_targets_count = ka.active_targets_count - 1
	end

	local target = store.entities[this.modifier.target_id]

	if target then
		SU.stun_dec(target)
	end

	return true
end

local function mod_stun_kraken_update(this, store)
	local m = this.modifier
	local target = store.entities[this.modifier.target_id]

	if target and not target.health.dead then
		this.pos = target.pos

		local s = this.render.sprites[1]

		s.anchor.y = s.size_anchors_y[target.unit.size]

		local dpsmod = E:create_entity("mod_dps_kraken")

		dpsmod.modifier.target_id = m.target_id

		simulation:queue_insert_entity(dpsmod)
		U.animation_start_default(this, "grab", nil, store.tick_ts)

		while store.tick_ts - m.ts < m.duration - fts(10) and target and not target.health.dead do
			coroutine.yield()
		end

		U.y_animation_play(this, "end", nil, store.tick_ts, 1)
		simulation:queue_remove_entity(dpsmod)
	end

	simulation:queue_remove_entity(this)
end

local function hero_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local bt = E:get_template(this.ranged.attacks[1].bullet)

	bt.bullet.damage_min = ls.ranged_damage_min[hl]
	bt.bullet.damage_max = ls.ranged_damage_max[hl]

	upgrade_skill(this, "swordsmanship", function(this, s)
		this.swordsmanship_extra = s.extra_damage[s.level]
	end)
	upgrade_skill(this, "looting", function(this, s)
		local m = E:get_template("mod_pirate_loot")

		m.percent = s.percent[s.level]
	end)
	upgrade_skill(this, "kraken", function(this, s)
		this.timed_attacks.list[1].disabled = nil

		local ka = E:get_template("kraken_aura")

		ka.max_active_targets = s.max_enemies[s.level]

		local m = E:get_template("mod_slow_kraken")

		m.slow.factor = s.slow_factor[s.level]
	end)
	upgrade_skill(this, "scattershot", function(this, s)
		this.timed_attacks.list[2].disabled = nil

		local b = E:get_template("pirate_exploding_barrel")

		b.fragments = s.fragments[s.level]

		local bf = E:get_template("barrel_fragment")

		bf.bullet.damage_min = s.fragment_damage[s.level]
		bf.bullet.damage_max = bf.bullet.damage_min
	end)
	upgrade_skill(this, "toughness", function(this, s)
		this.toughness_extra_hp = s.hp_max[s.level]
	end)

	this.melee.attacks[1].damage_min = this.melee.attacks[1].damage_min + this.swordsmanship_extra
	this.melee.attacks[1].damage_max = this.melee.attacks[1].damage_max + this.swordsmanship_extra
	this.health.hp_max = this.health.hp_max + this.toughness_extra_hp

	update_regen(this)
	update_hp(this)
end

local function hero_insert(this, store)
	this.hero.fn_level_up(this, store)

	this.melee.order = U.attack_order(this.melee.attacks)
	this.ranged.order = U.attack_order(this.ranged.attacks)

	if this.hero.skills.looting.level > 0 then
		local a = E:create_entity("pirate_loot_aura")

		a.aura.source_id = this.id

		simulation:queue_insert_entity(a)
	end

	return true
end

local function hero_update(this, store)
	local h = this.health
	local he = this.hero
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
					goto label_317_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = he.skills.kraken

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local targets = U.find_enemies_between_range_filter_off(this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				targets = targets and table.filter(targets, function(_, e)
					local neighbors = U.find_enemies_in_range_filter_on(e.pos, a.nearby_range, a.vis_flags, a.vis_bans, function(oe)
						return e.id ~= oe.id
					end)

					return neighbors and #neighbors >= a.min_enemies_nearby
				end)

				if targets and targets[1] then
					local target = targets[1]
					local start_ts = store.tick_ts
					local flip = target.pos.x < this.pos.x

					U.animation_start_default(this, a.animation, flip, store.tick_ts)
					S:queue(a.sound)

					while store.tick_ts - start_ts < a.shoot_time do
						if this.nav_rally.new then
							goto label_317_0
						end

						if this.health.dead then
							goto label_317_0
						end

						if this.unit.is_stunned then
							goto label_317_0
						end

						coroutine.yield()
					end

					a.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, skill)

					local k_aura = E:create_entity(a.bullet)

					k_aura.aura.source_id = this.id
					k_aura.aura.ts = store.tick_ts

					local ni = target.nav_path.ni + P:predict_enemy_node_advance(target, fts(8))

					k_aura.pos = P:node_pos(target.nav_path.pi, 1, ni)

					simulation:queue_insert_entity(k_aura)

					local ks_aura = E:create_entity("kraken_aura_slow")

					ks_aura.aura.source_id = this.id
					ks_aura.aura.ts = store.tick_ts
					ks_aura.pos = k_aura.pos

					simulation:queue_insert_entity(ks_aura)

					while not U.animation_finished_default(this) do
						if this.nav_rally.new then
							goto label_317_0
						end

						if this.health.dead then
							goto label_317_0
						end

						if this.unit.is_stunned then
							goto label_317_0
						end

						coroutine.yield()
					end

					a.ts = store.tick_ts
				end
			end

			a = this.timed_attacks.list[2]
			skill = he.skills.scattershot

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local targets = U.find_enemies_between_range_filter_off(this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if targets then
					a.ts = store.tick_ts

					local target = targets[1]
					local pi = target.nav_path.pi
					local spi = target.nav_path.spi
					local ni = target.nav_path.ni + P:predict_enemy_node_advance(target, a.shoot_time + fts(20) + fts(18))
					local npos = P:node_pos(pi, spi, ni)

					npos.y = npos.y + 80

					local an, af, ai = U.animation_name_facing_point(this, a.animation, npos)

					U.animation_start_default(this, an, af, store.tick_ts, false)

					while store.tick_ts - a.ts < a.shoot_time do
						if this.health.dead then
							goto label_317_0
						end

						coroutine.yield()
					end

					SU.hero_gain_xp_from_skill(this, skill)

					local bullet = E:create_entity(a.bullet)

					bullet.pos:copy(this.pos)

					if a.bullet_start_offset then
						local offset = a.bullet_start_offset[ai]

						bullet.pos.x, bullet.pos.y = bullet.pos.x + (af and -1 or 1) * offset.x, bullet.pos.y + offset.y
					end

					bullet.bullet.from:copy(bullet.pos)

					bullet.bullet.to = npos

					simulation:queue_insert_entity(bullet)

					while not U.animation_finished_default(this) do
						if this.nav_rally.new then
							goto label_317_0
						end

						if this.health.dead then
							goto label_317_0
						end

						if this.unit.is_stunned then
							goto label_317_0
						end

						coroutine.yield()
					end
				end
			end

			brk, sta = SU.y_soldier_ranged_attacks(store, this)

			if brk then
			-- block empty
			else
				brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

				if brk or sta ~= A_NO_TARGET then
				-- block empty
				elseif SU.soldier_go_back_step(store, this) then
				-- block empty
				else
					SU.soldier_idle(store, this)
					SU.soldier_regen(store, this)
				end
			end
		end

		::label_317_0::

		coroutine.yield()
	end
end

local tt

tt = RT("hero_pirate", "hero")

AC(tt, "melee", "ranged", "timed_attacks", "pickpocket")

tt.hero.level_stats.hp_max = {225, 250, 275, 300, 325, 350, 375, 400, 425, 450}
tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.melee_damage_min = {8, 10, 12, 13, 15, 17, 18, 20, 22, 24}
tt.hero.level_stats.melee_damage_max = {16, 19, 22, 25, 28, 31, 34, 37, 41, 45}
tt.hero.level_stats.ranged_damage_min = {29, 35, 41, 47, 53, 59, 65, 71, 76, 81}
tt.hero.level_stats.ranged_damage_max = {55, 66, 76, 87, 98, 109, 120, 131, 142, 153}
tt.hero.fn_level_up = hero_level_up
tt.hero.tombstone_show_time = fts(60)
tt.hero.skills.swordsmanship = CC("hero_skill")
tt.hero.skills.swordsmanship.extra_damage = {8, 16, 24}
tt.hero.skills.swordsmanship.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.looting = CC("hero_skill")
tt.hero.skills.looting.percent = {0.15, 0.225, 0.3}
tt.hero.skills.looting.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.toughness = CC("hero_skill")
tt.hero.skills.toughness.hp_max = {80, 160, 240}
tt.hero.skills.toughness.regen = {20, 40, 60}
tt.hero.skills.toughness.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.kraken = CC("hero_skill")
tt.hero.skills.kraken.slow_factor = {0.75, 0.5, 0.25}
tt.hero.skills.kraken.max_enemies = {4, 5, 6}
tt.hero.skills.kraken.xp_gain = {50, 100, 150}
tt.hero.skills.kraken.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.scattershot = CC("hero_skill")
tt.hero.skills.scattershot.fragments = {4, 6, 8}
tt.hero.skills.scattershot.fragment_damage = {15, 20, 25}
tt.hero.skills.scattershot.xp_gain = {40, 80, 120}
tt.hero.skills.scattershot.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.health.dead_lifetime = 15
tt.health.hp_max = tt.hero.level_stats.hp_max[1]
tt.health_bar.offset = vec_2(0, 38.16)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.idle_flip.cooldown = 1
tt.info.hero_portrait = "kr2_hero_portraits_0003"
tt.info.portrait = "kr2_info_portraits_heroes_0003"
tt.main_script.insert = hero_insert
tt.main_script.update = hero_update
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 2.5
tt.melee.range = 83.2
tt.motion.max_speed = 80
tt.pickpocket.chance = 0.3
tt.pickpocket.fx = "fx_coin_jump"
tt.pickpocket.steal_max = 10
tt.pickpocket.steal_min = 5
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animation = "shoot"
tt.ranged.attacks[1].bullet = "pirate_shotgun"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(0, 18), vec_2(15, 10), vec_2(19, 20)}
tt.ranged.attacks[1].cooldown = 5.4
tt.ranged.attacks[1].max_range = 140
tt.ranged.attacks[1].min_range = 25
tt.ranged.attacks[1].shoot_time = fts(15)
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.18
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.shoot = {"shoot", "shootUp", "shootDown"}
tt.render.sprites[1].angles.walk = {"running"}
tt.render.sprites[1].angles_custom = {45, 135, 210, 315}
tt.render.sprites[1].angles_flip_vertical = {
	shoot = true
}
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_pirate"
tt.soldier.melee_slot_offset.x = 5
tt.sound_events.change_rally_point = "HeroPirateTaunt"
tt.sound_events.death = "HeroPirateDeath"
tt.sound_events.respawn = "HeroPirateTauntIntro"
tt.sound_events.insert = "HeroPirateTauntIntro"
tt.sound_events.hero_room_select = "HeroPirateTauntSelect"
tt.timed_attacks.list[1] = CC("aura_attack")
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].cooldown = 14.4
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].max_range = 200
tt.timed_attacks.list[1].bullet = "kraken_aura"
tt.timed_attacks.list[1].animation = "kraken"
tt.timed_attacks.list[1].shoot_time = fts(15)
tt.timed_attacks.list[1].sound = "HeroPirateKraken"
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING, F_CLIFF, F_WATER, F_BOSS)
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[1].min_enemies_nearby = 1
tt.timed_attacks.list[1].nearby_range = 60
tt.timed_attacks.list[2] = CC("bullet_attack")
tt.timed_attacks.list[2].animation = "bombing"
tt.timed_attacks.list[2].bullet = "pirate_exploding_barrel"
tt.timed_attacks.list[2].bullet_start_offset = {vec_2(-5, 16)}
tt.timed_attacks.list[2].cooldown = 10.8
tt.timed_attacks.list[2].max_range = 140.8
tt.timed_attacks.list[2].shoot_time = fts(9.5)
tt.timed_attacks.list[2].disabled = true
tt.unit.marker_offset = vec_2(0, -0.84)
tt.unit.mod_offset = vec_2(0, 14.16)
tt.swordsmanship_extra = 0
tt.toughness_extra_hp = 0
tt = RT("pirate_shotgun", "shotgun")
tt.bullet.damage_min = nil
tt.bullet.damage_max = nil
tt.bullet.damage_type = DAMAGE_SHOT
tt.bullet.min_speed = 40 * FPS
tt.bullet.max_speed = 40 * FPS
tt.bullet.hit_blood_fx = "fx_blood_splat"
tt.bullet.miss_fx = "fx_smoke_bullet"
tt.bullet.miss_fx_water = "fx_splash_small"
tt.bullet.xp_gain_factor = 2.5
tt.render.sprites[1].hidden = true
tt.sound_events.insert = "ShotgunSound"
tt = RT("pirate_loot_aura", "aura")
tt.aura.mod = "mod_pirate_loot"
tt.aura.cycle_time = fts(10)
tt.aura.requires_alive_source = true
tt.aura.duration = -1
tt.aura.radius = 90
tt.aura.track_source = true
tt.aura.track_dead = true
tt.aura.filter_source = true
tt.aura.vis_bans = bor(F_FRIEND, F_BOSS)
tt.aura.vis_flags = bor(F_MOD, F_RANGED)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt = RT("mod_pirate_loot", "modifier")
tt.modifier.duration = fts(13)
tt.main_script.insert = mod_pirate_loot_insert
tt.main_script.update = mod_pirate_loot_update
tt.extra_loot = 0
tt = RT("kraken_aura", "aura")
tt.main_script.insert = kraken_aura_insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.aura.mod = "mod_stun_kraken"
tt.aura.cycle_time = fts(10)
tt.aura.duration = 3
tt.aura.radius = 40
tt.aura.vis_flags = bor(F_RANGED)
tt.aura.vis_bans = bor(F_BOSS, F_FLYING, F_WATER, F_CLIFF, F_FRIEND, F_HERO)
tt.max_active_targets = 2
tt.active_targets_count = 0
tt = RT("kraken_aura_slow", "aura")
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.aura.mod = "mod_slow_kraken"
tt.aura.cycle_time = fts(10)
tt.aura.duration = 3
tt.aura.radius = 40
tt.aura.vis_flags = bor(F_RANGED)
tt.aura.vis_bans = bor(F_BOSS, F_FLYING, F_WATER, F_CLIFF, F_FRIEND, F_HERO)
tt = RT("mod_stun_kraken", "modifier")

AC(tt, "render")

tt.modifier.replaces_lower = false
tt.modifier.resets_same = false
tt.modifier.use_mod_offset = false
tt.render.sprites[1].prefix = "kraken_tentacle"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.render.sprites[1].name = "grab"
tt.render.sprites[1].size_anchors_y = {0.325, 0.28, 0.28}
tt.main_script.insert = mod_stun_kraken_insert
tt.main_script.remove = mod_stun_kraken_remove
tt.main_script.update = mod_stun_kraken_update
tt = RT("mod_dps_kraken", "modifier")

AC(tt, "dps")

tt.modifier.duration = 3
tt.dps.damage_min = 3
tt.dps.damage_max = 3
tt.dps.damage_every = fts(10)
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt = RT("mod_slow_kraken", "mod_slow")
tt.modifier.duration = fts(10)
tt = RT("pirate_exploding_barrel", "bomb")
tt.bullet.flight_time = fts(20)
tt.bullet.damage_min = 0
tt.bullet.damage_max = 0
tt.bullet.hide_radius = nil
tt.bullet.hit_fx = "fx_barrel_explosion"
tt.sound_events.hit = nil
tt.sound_events.insert = "HeroPirateExplosiveBarrel"
tt.render.sprites[1].name = "hero_pirate_barrelProyectile"
tt.main_script.update = pirate_exploding_barrel_update
tt.fragments = 0
tt = RT("fx_barrel_explosion", "fx")
tt.render.sprites[1].name = "barrel_explosion"
tt.render.sprites[1].z = Z_BULLETS
tt = RT("barrel_fragment", "bomb")
tt.bullet.align_with_trajectory = true
tt.bullet.flight_time = fts(16)
tt.bullet.damage_min = 0
tt.bullet.damage_max = 0
tt.bullet.damage_radius = 38.4
tt.bullet.hit_fx = "fx_fragment_ground_explosion"
tt.bullet.hit_decal = "decal_bomb_crater"
tt.bullet.particles_name = "ps_barrel_fragment"
tt.bullet.pop = nil
tt.sound_events.insert = nil
tt.render.sprites[1].name = "barrel_fragment"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor.x = 0.68
tt = RT("ps_barrel_fragment")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "barrel_fragment_trail"
tt.particle_system.animated = true
tt.particle_system.animation_fps = 60
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {0.2, 0.4}
tt.particle_system.emission_rate = 60
tt.particle_system.scale_var = {0.4, 1}
tt.particle_system.scales_x = {1, 1.5}
tt.particle_system.scales_y = {1, 1.5}
tt.particle_system.alphas = {255, 0}
tt.particle_system.emit_rotation_spread = math.pi
tt = RT("fx_fragment_ground_explosion", "fx")
tt.render.sprites[1].name = "barrel_fragment_ground_explosion"
tt.render.sprites[1].anchor = vec_2(0.5, 0.22)
tt.render.sprites[1].z = Z_OBJECTS
tt = RT("decal_kraken", "decal_scripted")

AC(tt, "sound_events")

tt.main_script.update = decal_kraken_update
tt.render.sprites[1].prefix = "kraken_water"
tt.render.sprites[1].z = Z_DECALS
tt.duration = 3
