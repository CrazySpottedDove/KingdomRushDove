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
local bor = bit.bor
local find_target_at_critical_moment = HU.find_target_at_critical_moment
local fts = U.fts
local level_up_basic = HU.level_up_basic
local ready_to_attack = U.ready_to_attack
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local v = V.v
local tt

local function hero_dianyun_lightning_ricochet_update(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local source = store.entities[b.source_id]
	local dest = b.to

	s.scale = V.v(1, 1)

	if not target then
		simulation:queue_remove_entity(this)

		return
	end

	local function update_sprite()
		if target then
			dest:set(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
		end

		if source then
			this.pos:set(source.pos.x + source.unit.hit_offset.x, source.pos.y + source.unit.hit_offset.y)
		end

		local angle = V.angleTo(dest.x - this.pos.x, dest.y - this.pos.y)

		s.r = angle
		s.scale.x = V.dist(dest.x, dest.y, this.pos.x, this.pos.y) / this.image_width
	end

	s.ts = store.tick_ts

	update_sprite()

	while store.tick_ts - s.ts < b.hit_time do
		coroutine.yield()
		update_sprite()

		if target and target.health.dead then
			target = nil
		end
	end

	if target then
		SU.apply_single_bullet_simulation(this, target, store)
	end

	SU.insert_sprite(store, b.hit_fx, dest)

	while store.tick_ts - s.ts < this.bounce_delay do
		coroutine.yield()
		update_sprite()

		if target and target.health.dead then
			target = nil
		end
	end

	if target then
		table.insert(this.seen_targets, target.id)
	end

	if this.bounce > 0 then
		local bounce_target = U.find_nearest_enemy(store, dest, 0, this.bounce_range, this.bounce_vis_flags, this.bounce_vis_bans, function(v)
			return not table.contains(this.seen_targets, v.id)
		end)

		if bounce_target then
			local bounceBullet = E:create_entity(this.template_name)

			bounceBullet.bullet.damage_factor = b.damage_factor
			bounceBullet.pos = V.vclone(dest)
			bounceBullet.bullet.from = V.vclone(bounceBullet.pos)
			bounceBullet.bullet.to = V.vclone(bounce_target.pos)

			if target then
				bounceBullet.bullet.source_id = target.id
			end

			bounceBullet.bullet.target_id = bounce_target.id
			bounceBullet.bounce = this.bounce - 1
			bounceBullet.seen_targets = this.seen_targets

			simulation:queue_insert_entity(bounceBullet)
		end
	end

	while not U.animation_finished(this) do
		coroutine.yield()
		update_sprite()
	end

	simulation:queue_remove_entity(this)
end

local function hero_dianyun_lightning_ricochet_cloud_update(this, store)
	local bullet = this.bullet
	local target = store.entities[bullet.target_id]

	if not target then
		simulation:queue_remove_entity(this)

		return
	end

	this.pos = target.pos
	this.render.sprites[1].offset.x = target.unit.hit_offset.x
	this.render.sprites[1].offset.y = target.unit.hit_offset.y + 81
	this.render.sprites[1].ts = store.tick_ts

	U.y_wait_unconditional(store, bullet.hit_time)

	local b = E:create_entity(bullet.payload)

	b.bullet.target_id = target.id
	b.bullet.source_id = target.id

	b.pos:set(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)

	b.bullet.damage_factor = bullet.damage_factor

	simulation:queue_insert_entity(b)
	U.y_animation_wait_default(this)
	simulation:queue_remove_entity(this)
end

local function mod_dianyun_passive_insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead then
		return false
	end

	return true
end

local function mod_dianyun_passive_remove(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	local aura = store.entities[m.source_id]

	if not aura or not target or not target.health.dead then
		return true
	end

	local fx = E:create_entity(this.fx)

	fx.pos:copy(target.pos)

	fx.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(fx)

	store.player_gold = store.player_gold + this.gold_reward

	return true
end

local function hero_dianyun_ultimate_update(this, store)
	local son = E:create_entity("hero_dianyun_electric_son")

	son.pos = V.vclone(this.pos)
	son.damage_factor = this.damage_factor

	simulation:queue_insert_entity(son)
	simulation:queue_remove_entity(this)
end

local function hero_dianyun_level_up(this, store)
	local hl, ls = level_up_basic(this)
	local b = E:get_template(this.ranged.attacks[1].bullet)

	b.bullet.damage_max = ls.ranged_damage_max[hl]
	b.bullet.damage_min = ls.ranged_damage_min[hl]

	upgrade_skill(this, "ricochet", function(this, s)
		this.ranged.attacks[2].disabled = nil

		local cloud = E:get_template("hero_dianyun_lightning_ricochet_cloud")
		local bounce = E:get_template(cloud.bullet.payload)

		bounce.bullet.damage_min = s.damage_min[s.level]
		bounce.bullet.damage_max = s.damage_max[s.level]
		bounce.bounce = s.bounce[s.level]
	end)
	upgrade_skill(this, "lord_storm", function(this, s)
		this.ranged.attacks[1].max_targets = s.max_targets[s.level]
	end)
	upgrade_skill(this, "divine_rain", function(this, s)
		this.timed_attacks.list[1].disabled = nil

		local aura = E:get_template("aura_hero_dianyun_divine_rain")
		local mod = E:get_template(aura.aura.mods[1])

		mod.hps.heal_min = s.healing_points_tick[s.level]
		mod.hps.heal_max = s.healing_points_tick[s.level]
	end)
	upgrade_skill(this, "supreme_wave", function(this, s)
		this.timed_attacks.list[2].disabled = nil

		local aura = E:get_template("aura_hero_dianyun_supreme_wave")
		local mod = E:get_template(aura.aura.mods[1])

		mod.modifier.duration = s.stun[s.level]
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		this.ultimate.disabled = nil

		local u = E:get_template("hero_dianyun_ultimate")
		local entity = E:get_template(u.entity)

		entity.bullets_to_death = s.bullets_to_death[s.level]
	end)
	update_hp(this)
end

local function hero_dianyun_insert(this, store)
	this.hero.fn_level_up(this, store)

	this.ranged.order = U.attack_order(this.ranged.attacks)

	local e = E:create_entity("aura_dianyun_passive")

	e.pos:copy(this.pos)

	e.aura.source_id = this.id
	e.aura.ts = store.tick_ts

	simulation:queue_insert_entity(e)

	e = E:create_entity("controller_lord_storm")
	e.source_id = this.id

	simulation:queue_insert_entity(e)

	return true
end

local function hero_dianyun_update(this, store)
	local h = this.health
	local divine_rain_attack = this.timed_attacks.list[1]
	local supreme_wave_attack = this.timed_attacks.list[2]

	U.y_animation_play_once_specific(this, "levelup", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	local score_fn = function(e)
		return -e.pos:dist2(this.pos)
	end

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)

			-- 恢复 aura。
			local e = E:create_entity("aura_dianyun_passive")

			e.pos:copy(this.pos)

			e.aura.source_id = this.id
			e.aura.ts = store.tick_ts

			simulation:queue_insert_entity(e)
		end

		while this.nav_rally.new do
			if SU.y_hero_new_rally(store, this) then
				goto label_dianyun_0
			end
		end

		if SU.hero_level_up(store, this) then
			U.y_animation_play_once_specific(this, "levelup", nil, store.tick_ts, 1)
		end

		if ready_to_use_skill(divine_rain_attack, store, this.unit.cooldown_factor) then
			if U.is_soldiers_around_need_heal(store.soldiers, this.pos, divine_rain_attack.health_trigger_factor, divine_rain_attack.max_range) then
				local start_ts = store.tick_ts

				U.animation_start_once_specific(this, divine_rain_attack.animation, nil, store.tick_ts, 1)

				if SU.y_hero_wait(store, this, divine_rain_attack.cast_time) then
					goto label_dianyun_0
				end

				divine_rain_attack.ts = start_ts

				SU.hero_gain_xp_from_skill(this, this.hero.skills.divine_rain)

				local e = U.is_soldiers_around_need_heal(store.soldiers, this.pos, divine_rain_attack.health_trigger_factor, divine_rain_attack.max_range)
				local aura = E:create_entity(divine_rain_attack.aura)

				if e then
					aura.pos:copy(e.pos)
				else
					aura.pos:copy(this.pos)
				end

				aura.aura.source_id = this.id

				simulation:queue_insert_entity(aura)

				if SU.y_hero_animation_wait(this) then
					goto label_dianyun_0
				end
			else
				divine_rain_attack.ts = divine_rain_attack.ts + 0.1
			end
		end

		if ready_to_use_skill(supreme_wave_attack, store, this.unit.cooldown_factor) then
			local targets = U.find_enemies_between_range_filter_off(this.pos, supreme_wave_attack.min_range, supreme_wave_attack.max_range, supreme_wave_attack.vis_flags, supreme_wave_attack.vis_bans)

			if targets and #targets >= supreme_wave_attack.min_targets then
				local start_ts = store.tick_ts
				local target = table.find_best(targets, score_fn)
				local an, af = U.animation_name_facing_point_simple(this, supreme_wave_attack.animation, target.pos, 1)

				U.animation_start_once_specific(this, an, af, store.tick_ts, 1)

				if SU.y_hero_wait(store, this, supreme_wave_attack.cast_time) then
					goto label_dianyun_0
				end

				supreme_wave_attack.ts = start_ts

				SU.hero_gain_xp_from_skill(this, this.hero.skills.supreme_wave)

				local ni = P:nearest_node_with_nav_path_info(this.pos, target.nav_path)
				local controller = E:create_entity(supreme_wave_attack.controller)

				controller.nav_path.pi = target.nav_path.pi
				controller.nav_path.spi = target.nav_path.spi
				controller.nav_path.ni = ni

				simulation:queue_insert_entity(controller)

				if SU.y_hero_animation_wait(this) then
					goto label_dianyun_0
				end
			else
				supreme_wave_attack.ts = supreme_wave_attack.ts + 0.1
			end
		end

		if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
			local enemy = find_target_at_critical_moment(this, this.ranged.attacks[1].max_range, F_RANGED, F_NONE)

			if enemy then
				this.ultimate.ts = store.tick_ts

				U.y_animation_play_once_specific(this, "levelup", nil, store.tick_ts, 1)
				S:queue(this.sound_events.change_rally_point)

				local ni = P:nearest_node_with_nav_path_info(this.pos, enemy.nav_path)
				local e = E:create_entity(this.hero.skills.ultimate.controller_name)

				e.damage_factor = this.unit.damage_factor

				e.pos:copy(P:node_pos_ref(enemy.nav_path.pi, enemy.nav_path.spi, ni))

				e.level = this.hero.skills.ultimate.level

				simulation:queue_insert_entity(e)
				SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
			else
				this.ultimate.ts = this.ultimate.ts + 1
			end
		end

		SU.soldier_idle(store, this)
		SU.soldier_regen(store, this)

		::label_dianyun_0::

		coroutine.yield()
	end
end

local function hero_dianyun_electric_son_update(this, store)
	local attack = this.ranged.attacks[1]

	local function idle()
		U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, 1)

		if store.tick_ts - this.idle_flip.ts > 2 * store.tick_length then
			this.idle_flip.ts_counter = 0
		end

		this.idle_flip.ts = store.tick_ts
		this.idle_flip.ts_counter = this.idle_flip.ts_counter + store.tick_length

		if this.idle_flip.ts_counter > this.idle_flip.cooldown then
			this.idle_flip.ts_counter = 0

			if math.random() < this.idle_flip.chance then
				this.render.sprites[1].flip_x = not this.render.sprites[1].flip_x
			end

			if this.idle_flip.animations then
				this.idle_flip.last_animation = table.random(this.idle_flip.animations)
			end
		end
	end

	U.y_animation_play(this, "spawn", nil, store.tick_ts)

	attack.ts = store.tick_ts - attack.cooldown

	local start_ts = store.tick_ts
	local bullets_shot = 0

	while true do
		if store.tick_ts - start_ts > this.duration or bullets_shot >= (this.bullets_to_death) then
			U.y_animation_play(this, "death", nil, store.tick_ts)

			break
		end

		if store.tick_ts - attack.ts >= attack.cooldown then
			local target = U.find_foremost_enemy(store, this.pos, attack.min_range, attack.max_range, nil, attack.vis_flags, attack.vis_bans)

			if target then
				local ts = store.tick_ts
				local an, af = U.animation_name_facing_point(this, attack.animation, target.pos)

				U.animation_start(this, an, af, store.tick_ts, false, 1)
				U.y_wait_unconditional(store, attack.shoot_time)

				local b = E:create_entity(attack.bullet)
				local flipSign = af and -1 or 1

				b.bullet.from = V.v(this.pos.x + attack.bullet_start_offset.x * flipSign, this.pos.y + attack.bullet_start_offset.y)
				b.bullet.to = V.v(target.pos.x, target.pos.y)

				if target.unit and target.unit.hit_offset then
					b.bullet.to.x = target.pos.x + target.unit.hit_offset.x
					b.bullet.to.y = target.pos.y + target.unit.hit_offset.y
				end

				b.bullet.target_id = target.id
				b.bullet.source_id = this.id
				b.bullet.damage_factor = this.damage_factor

				b.pos:copy(b.bullet.from)
				simulation:queue_insert_entity(b)

				bullets_shot = bullets_shot + 1
				attack.ts = ts

				U.y_animation_wait(this)
			else
				attack.ts = attack.ts + 0.2 * FPS
			end
		end

		idle()
		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

local function controller_decal_hero_dianyun_supreme_wave_spawner_update(this, store)
	local pi, spi, ni = this.nav_path.pi, this.nav_path.spi, this.nav_path.ni
	local npos, e

	for i = 1, this.max_objects * 3 do
		spi = km.zmod(this.nav_path.spi + 2 * i, 3)
		ni = this.nav_path.ni + i * 2

		if not P:is_node_valid(pi, ni) then
			goto wave_mid
		end

		npos = P:node_pos_ref(pi, spi, ni)
		e = E:create_entity(this.entity)

		e.pos:copy(npos)
		simulation:queue_insert_entity(e)

		e = E:create_entity(this.floor_decal)

		e.pos:copy(npos)

		e.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(e)

		::wave_mid::

		spi = km.zmod(this.nav_path.spi - 2 * i, 3)
		ni = this.nav_path.ni - i * 2

		if not P:is_node_valid(pi, ni) then
			goto wave_end
		end

		npos = P:node_pos_ref(pi, spi, ni)
		e = E:create_entity(this.entity)

		e.pos:copy(npos)
		simulation:queue_insert_entity(e)

		e = E:create_entity(this.floor_decal)

		e.pos:copy(npos)

		e.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(e)
		U.y_wait_unconditional(store, this.delay_between_objects)

		::wave_end::
	end

	simulation:queue_remove_entity(this)
end

local function controller_lord_storm_update(this, store)
	local hitted_targets = {}
	local ricochet_decal = nil

	local function filter_fn(e)
		return not table.arraycontains(hitted_targets, e.id)
	end

	while true do
		local hero = store.entities[this.source_id]

		if not hero then
			simulation:queue_remove_entity(this)

			return
		end

		if not hero.health.dead then
			local a = hero.ranged.attacks[1]

			if ready_to_attack(a, store, hero.unit.cooldown_factor) then
				if U.find_first_enemy_in_range_filter_off(hero.pos, a.max_range, a.vis_flags, a.vis_bans) then
					a.ts = store.tick_ts

					for i = 1, a.max_targets do
						local target = U.detect_foremost_enemy_in_range_filter_on(hero.pos, a.max_range, a.vis_flags, a.vis_bans, filter_fn)

						if target then
							local bullet = E:create_entity(a.bullet)

							bullet.bullet.source_id = hero.id
							bullet.bullet.target_id = target.id
							bullet.bullet.xp_dest_id = hero.id
							bullet.bullet.damage_factor = hero.unit.damage_factor

							simulation:queue_insert_entity(bullet)

							hitted_targets[#hitted_targets + 1] = target.id

							U.y_wait_unconditional(store, 0.5 * hero.unit.cooldown_factor)
						else
							break
						end
					end

					table.clear(hitted_targets)
				else
					a.ts = a.ts + 0.1
				end
			end

			local ricochet_attack = hero.ranged.attacks[2]

			if not ricochet_decal then
				if ready_to_use_skill(ricochet_attack, store, hero.unit.cooldown_factor) then
					ricochet_decal = E:create_entity("decal_hero_dianyun_lightning_ricochet")
					ricochet_decal.pos = hero.pos

					for _, sprite in ipairs(ricochet_decal.render.sprites) do
						sprite.ts = store.tick_ts
						sprite.flip_x = hero.render.sprites[1].flip_x
						sprite.offset = ricochet_attack.start_offset
					end

					simulation:queue_insert_entity(ricochet_decal)
				end
			else
				if ready_to_use_skill(ricochet_attack, store, hero.unit.cooldown_factor) then
					local target, targets = U.find_foremost_enemy_with_max_coverage_in_range_filter_off(hero.pos, ricochet_attack.max_range, nil, ricochet_attack.vis_flags, ricochet_attack.vis_bans, ricochet_attack.crowds_range)

					if target and #targets > ricochet_attack.min_targets then
						local bullet = E:create_entity(ricochet_attack.bullet)

						bullet.pos = target.pos
						bullet.bullet.source_id = hero.id
						bullet.bullet.target_id = target.id
						bullet.bullet.damage_factor = hero.unit.damage_factor

						simulation:queue_insert_entity(bullet)

						ricochet_attack.ts = store.tick_ts

						SU.hero_gain_xp_from_skill(hero, hero.hero.skills.ricochet)
						simulation:queue_remove_entity(ricochet_decal)

						ricochet_decal = nil
					else
						ricochet_attack.ts = ricochet_attack.ts + 0.1
					end
				end
			end
		else
			if ricochet_decal then
				simulation:queue_remove_entity(ricochet_decal)

				ricochet_decal = nil
			end
		end

		coroutine.yield()
	end
end

local function hero_dianyun_lightning_update(this, store)
	local b = this.bullet
	local target = store.entities[b.target_id]

	if not target then
		simulation:queue_remove_entity(this)

		return
	end

	-- const&
	this.pos = target.pos
	this.render.sprites[1].offset.x = target.unit.hit_offset.x
	this.render.sprites[1].offset.y = target.unit.hit_offset.y + 81
	this.render.sprites[1].ts = store.tick_ts

	U.y_wait_unconditional(store, b.hit_time)

	if not target.health.dead then
		SU.apply_single_bullet_simulation(this, target, store)
	end

	S:queue("WarmongerMageAttack")

	local e = E:create_entity(b.hit_fx)

	e.pos:set(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)

	e.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(e)
	U.y_animation_wait_default(this)
	simulation:queue_remove_entity(this)
end

tt = RT("hero_dianyun", "hero")

AC(tt, "ranged", "timed_attacks")

tt.ui.click_rect = r(-25, 70, 60, 60)
tt.hero.level_stats.hp_max = {320, 338, 356, 374, 392, 410, 428, 446, 464, 482}
tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.ranged_damage_min = {6, 7, 8, 9, 10, 11, 13, 15, 17, 19}
tt.hero.level_stats.ranged_damage_max = {6, 10, 14, 18, 22, 27, 31, 35, 39, 43}
tt.hero.skills.ricochet = CC("hero_skill")
tt.hero.skills.ricochet.damage_min = {30, 40, 50}
tt.hero.skills.ricochet.damage_max = {30, 40, 50}
tt.hero.skills.ricochet.bounce = {3, 5, 6}
tt.hero.skills.ricochet.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.ricochet.xp_gain = {100, 200, 300}
tt.hero.skills.lord_storm = CC("hero_skill")
tt.hero.skills.lord_storm.max_targets = {2, 3, 4}
tt.hero.skills.lord_storm.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.lord_storm.xp_gain = {80, 160, 240}
tt.hero.skills.divine_rain = CC("hero_skill")
tt.hero.skills.divine_rain.duration = 5
tt.hero.skills.divine_rain.healing_points_tick = {8, 16, 24}
tt.hero.skills.divine_rain.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.divine_rain.xp_gain = {100, 200, 300}
tt.hero.skills.supreme_wave = CC("hero_skill")
tt.hero.skills.supreme_wave.stun = {2, 3, 4}
tt.hero.skills.supreme_wave.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.supreme_wave.xp_gain = {120, 240, 360}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_dianyun_ultimate"
tt.hero.skills.ultimate.cooldown = {32, 32, 32, 32}
tt.hero.skills.ultimate.bullets_to_death = {3, 5, 10, 15}
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.ultimate.xp_gain = {100, 200, 300, 400}
tt.health.dead_lifetime = 15
tt.regen.cooldown = 1
tt.health_bar.offset = v(0, 130)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.hero.fn_level_up = hero_dianyun_level_up
tt.hero.tombstone_show_time = fts(90)
tt.info.hero_portrait = "kr4_hero_portraits_0013"
tt.info.portrait = "kr4_info_portraits_heroes_0014"
tt.main_script.insert = hero_dianyun_insert
tt.main_script.update = hero_dianyun_update
tt.motion.max_speed = 55
tt.nav_rally.requires_node_nearby = false
tt.nav_grid.ignore_waypoints = true
tt.nav_grid.valid_terrains = TERRAIN_ALL_MASK
tt.nav_grid.valid_terrains_dest = TERRAIN_ALL_MASK
tt.render.sprites[1].anchor.y = 0.04
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_dianyun"
tt.render.sprites[1].angles.walk = {"idle"}
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.render.sprites[1].exo = true
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "hero_dianyun_shadow"
tt.render.sprites[2].z = Z_DECALS + 1
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].prefix = "hero_storm_dragon_cloud_l1"
tt.render.sprites[3].offset = v(15, 50)
tt.render.sprites[3].alpha = 204
tt.render.sprites[3].z = Z_FLYING_HEROES + 1
tt.render.sprites[4] = CC("sprite")
tt.render.sprites[4].prefix = "hero_storm_dragon_cloud_l2"
tt.render.sprites[4].offset = v(15, 50)
tt.render.sprites[4].alpha = 204
tt.render.sprites[4].z = Z_FLYING_HEROES + 1
tt.render.sprites[5] = CC("sprite")
tt.render.sprites[5].prefix = "hero_storm_dragon_cloud_l3"
tt.render.sprites[5].offset = v(15, 50)
tt.render.sprites[5].alpha = 204
tt.render.sprites[5].z = Z_FLYING_HEROES + 1
tt.render.sprites[6] = CC("sprite")
tt.render.sprites[6].prefix = "hero_storm_dragon_cloud_l1"
tt.render.sprites[6].scale = v(0.75, 0.75)
tt.render.sprites[6].offset = v(-20, 60)
tt.render.sprites[6].alpha = 204
tt.render.sprites[6].z = Z_FLYING_HEROES
tt.render.sprites[7] = CC("sprite")
tt.render.sprites[7].prefix = "hero_storm_dragon_cloud_l1"
tt.render.sprites[7].scale = v(0.666, 0.666)
tt.render.sprites[7].offset = v(5, 70)
tt.render.sprites[7].alpha = 204
tt.render.sprites[7].z = Z_FLYING_HEROES + 1
tt.render.sprites[8] = CC("sprite")
tt.render.sprites[8].prefix = "hero_storm_dragon_cloud_l1"
tt.render.sprites[8].scale = v(0.6, 0.6)
tt.render.sprites[8].offset = v(-5, 83)
tt.render.sprites[8].alpha = 204
tt.render.sprites[8].z = Z_FLYING_HEROES
tt.render.sprites[9] = CC("sprite")
tt.render.sprites[9].prefix = "hero_storm_dragon_cloud_l1"
tt.render.sprites[9].scale = v(0.666, 0.666)
tt.render.sprites[9].offset = v(50, 60)
tt.render.sprites[9].alpha = 204
tt.render.sprites[9].z = Z_FLYING_HEROES - 2
tt.render.sprites[10] = CC("sprite")
tt.render.sprites[10].prefix = "hero_storm_dragon_cloud_l1"
tt.render.sprites[10].scale = v(0.6, 0.6)
tt.render.sprites[10].offset = v(57, 70)
tt.render.sprites[10].alpha = 204
tt.render.sprites[10].z = Z_FLYING_HEROES - 1
tt.render.sprites[11] = CC("sprite")
tt.render.sprites[11].prefix = "hero_storm_dragon_cloud_l1"
tt.render.sprites[11].scale = v(0.75, 0.75)
tt.render.sprites[11].offset = v(40, 80)
tt.render.sprites[11].alpha = 204
tt.render.sprites[11].z = Z_FLYING_HEROES - 2
tt.render.sprites[12] = CC("sprite")
tt.render.sprites[12].prefix = "hero_storm_dragon_cloud_l1"
tt.render.sprites[12].scale = v(0.6, 0.6)
tt.render.sprites[12].offset = v(-40, 75)
tt.render.sprites[12].alpha = 204
tt.render.sprites[12].z = Z_FLYING_HEROES
tt.render.sprites[13] = CC("sprite")
tt.render.sprites[13].prefix = "hero_storm_dragon_cloud_l1"
tt.render.sprites[13].scale = v(0.6, 0.6)
tt.render.sprites[13].offset = v(-40, 88)
tt.render.sprites[13].alpha = 204
tt.render.sprites[13].z = Z_FLYING_HEROES
tt.render.sprites[14] = CC("sprite")
tt.render.sprites[14].prefix = "hero_storm_dragon_cloud_l1"
tt.render.sprites[14].scale = v(0.6, 0.6)
tt.render.sprites[14].offset = v(-55, 88)
tt.render.sprites[14].alpha = 204
tt.render.sprites[14].z = Z_FLYING_HEROES + 1
tt.sound_events.change_rally_point = "HeroDianyunTaunt"
tt.sound_events.death = "HeroDianyunTauntDeath"
tt.sound_events.respawn = "HeroLevelUp"
tt.sound_events.hero_room_select = "HeroDianyunTauntSelect"
tt.unit.mod_offset = v(0, 90)
tt.unit.hit_offset = v(0, 85)
tt.vis.flags = bor(tt.vis.flags, F_FLYING)
tt.vis.bans = bor(tt.vis.bans, F_EAT, F_NET)
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].cooldown = 2
tt.ranged.attacks[1].bullet = "hero_dianyun_lightning"
tt.ranged.attacks[1].max_range = 200
tt.ranged.attacks[1].max_targets = 1
tt.ranged.attacks[1].xp_gain_factor = 2
-- ricochet
tt.ranged.attacks[2] = CC("bullet_attack")
tt.ranged.attacks[2].disabled = true
tt.ranged.attacks[2].cooldown = 18
tt.ranged.attacks[2].max_range = 200
tt.ranged.attacks[2].bullet = "hero_dianyun_lightning_ricochet_cloud"
tt.ranged.attacks[2].start_fx = "fx_hero_dianyun_lightning_ricochet"
tt.ranged.attacks[2].start_offset = v(0, 90)
tt.ranged.attacks[2].min_targets = 2
tt.ranged.attacks[2].crowds_range = 90
tt.ranged.attacks[2].xp_from_skill = "ricochet"
-- divine rain
tt.timed_attacks.list[1] = CC("aura_attack")
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].aura = "aura_hero_dianyun_divine_rain"
tt.timed_attacks.list[1].min_targets = 2
tt.timed_attacks.list[1].crowds_range = 50
tt.timed_attacks.list[1].health_trigger_factor = 0.75
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].max_range = 110
tt.timed_attacks.list[1].cast_time = fts(20)
tt.timed_attacks.list[1].animation = "healingRain"
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[1].vis_bans = bor(F_ENEMY)
tt.timed_attacks.list[1].xp_from_skill = "divine_rain"
tt.timed_attacks.list[1].cooldown = 18
-- supreme wave
tt.timed_attacks.list[2] = CC("aura_attack")
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].cast_time = fts(24)
tt.timed_attacks.list[2].entity = "aura_hero_dianyun_supreme_wave"
tt.timed_attacks.list[2].floor_decal = "floor_decal_hero_dianyun_supreme_wave"
tt.timed_attacks.list[2].controller = "controller_decal_hero_dianyun_supreme_wave_spawner"
tt.timed_attacks.list[2].animation = "supremeWave"
tt.timed_attacks.list[2].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[2].vis_bans = bor(F_CLIFF, F_BOSS)
tt.timed_attacks.list[2].min_range = 22.5
tt.timed_attacks.list[2].max_range = 100
tt.timed_attacks.list[2].min_targets = 3
tt.timed_attacks.list[2].crowds_range = 150
tt.timed_attacks.list[2].max_objects = 5
tt.timed_attacks.list[2].xp_from_skill = "supreme_wave"
tt.timed_attacks.list[2].cooldown = 21
tt._aura_lantern = nil
tt.ultimate = {
	ts = 0,
	cooldown = 32,
	disabled = true
}
tt = RT("hero_dianyun_lightning", "bullet")
tt.main_script.update = hero_dianyun_lightning_update
tt.render.sprites[1].name = "hero_storm_dragon_lightning"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = v(0, 0.5)
tt.render.sprites[1].r = -math.pi / 2
tt.bullet.hit_time = fts(3)
tt.bullet.hit_fx = "fx_hero_dianyun_lightning_hit"
tt.bullet.mods = {"mod_hero_dianyun_lightning"}
tt.bullet.xp_gain_factor = 2
tt.bullet.damage_type = DAMAGE_MAGICAL
tt = RT("fx_hero_dianyun_lightning_hit", "fx")
tt.render.sprites[1].name = "hero_storm_dragon_lightning_hit"
tt = RT("mod_hero_dianyun_lightning", "mod_stun")

AC(tt, "tween")

tt.modifier.vis_flags = bor(F_STUN, F_MOD)
tt.modifier.duration = 0.9
tt.render.sprites[1].prefix = "hero_storm_dragon_lightning_modifier"
tt.render.sprites[1].anchor = v(0.5, 0.625)
tt.render.sprites[1].size_names = nil
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{tt.modifier.duration - fts(8), 255}, {tt.modifier.duration, 0}}
tt = RT("controller_lord_storm")

AC(tt, "main_script")

tt.main_script.update = controller_lord_storm_update
tt = RT("hero_dianyun_lightning_ricochet_cloud", "bullet")
tt.main_script.update = hero_dianyun_lightning_ricochet_cloud_update
tt.render.sprites[1].name = "hero_storm_dragon_lightning_ricochet_cloud"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = v(0, 0.5)
tt.render.sprites[1].r = -math.pi / 2
tt.bullet.hit_time = fts(3)
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.payload = "hero_dianyun_lightning_ricochet"
tt = RT("fx_hero_dianyun_lightning_ricochet_hit", "fx")
tt.render.sprites[1].name = "hero_storm_dragon_lightning_ricochet_hit"
tt = RT("mod_hero_dianyun_storm_ray", "mod_hero_dianyun_lightning")
tt.render.sprites[1].prefix = "hero_storm_ray_modifier"
tt = RT("hero_dianyun_lightning_ricochet", "bullet")
tt.main_script.update = hero_dianyun_lightning_ricochet_update
tt.render.sprites[1].name = "hero_storm_dragon_lightning_ricochet"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = v(0, 0.5)
tt.bullet.hit_time = fts(2)
tt.bullet.hit_fx = "fx_hero_dianyun_lightning_ricochet_hit"
tt.bullet.mods = {"mod_hero_dianyun_storm_ray"}
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bounce = 0
tt.bounce_delay = fts(3)
tt.bounce_range = 120
tt.bounce_vis_flags = F_RANGED
tt.bounce_vis_bans = F_NONE
tt.image_width = 69
tt.sound_events.insert = "WarmongerMageAttack"
tt.seen_targets = {}
tt = RT("aura_hero_dianyun_divine_rain", "aura")

AC(tt, "render", "tween")

tt.render.sprites[1].prefix = "hero_dianyun_health_rain"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].anchor = v(0.5, 0)
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.render.sprites[1].exo = true
tt.aura.duration = 5
tt.aura.mods = {"mod_hero_dianyun_divine_rain"}
tt.aura.radius = 60
tt.aura.vis_bans = bor(F_ENEMY)
tt.aura.vis_flags = bor(F_MOD, F_AREA)
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 0}, {0.3, 255}, {tt.aura.duration - 0.3, 255}, {tt.aura.duration, 0}}
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt = RT("mod_hero_dianyun_divine_rain", "modifier")

AC(tt, "hps")

tt.hps.heal_every = 0.5
tt.modifier.duration = 0.6
tt.main_script.insert = scripts.mod_hps.insert
tt.main_script.update = scripts.mod_hps.update
tt = RT("aura_hero_dianyun_supreme_wave", "aura")

AC(tt, "render")

tt.render.sprites[1].name = "hero_storm_dragon_supreme_wave"
tt.render.sprites[1].anchor = v(0.5, 0.2)
tt.render.sprites[1].z = Z_DECALS + 1
tt.aura.duration = fts(70)
tt.aura.mods = {"mod_supreme_wave_stun"}
tt.aura.cycle_time = 10
tt.aura.radius = 50
tt.aura.vis_bans = bor(F_FRIEND)
tt.aura.vis_flags = bor(F_MOD, F_AREA)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt = RT("mod_supreme_wave_stun", "mod_stun")
tt = RT("floor_decal_hero_dianyun_supreme_wave", "decal_tween")
tt.render.sprites[1].name = "hero_storm_dragon_supreme_wave_decal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 0}, {fts(14), 0}, {fts(14), 255}, {fts(49), 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, v(0, 0)}, {fts(14), v(0, 0)}, {fts(14), v(0.7, 0.7)}, {fts(49), v(1, 1)}}
tt = RT("controller_decal_hero_dianyun_supreme_wave_spawner")

AC(tt, "main_script", "nav_path")

tt.main_script.update = controller_decal_hero_dianyun_supreme_wave_spawner_update
tt.entity = "aura_hero_dianyun_supreme_wave"
tt.floor_decal = "floor_decal_hero_dianyun_supreme_wave"
tt.delay_between_objects = fts(3)
tt.max_objects = 5
tt = RT("aura_dianyun_passive", "aura")
tt.aura.mod = "mod_dianyun_passive"
tt.aura.cycle_time = fts(3)
tt.aura.duration = -1
tt.aura.radius = 200
tt.aura.track_source = true
tt.aura.track_dead = true
tt.aura.vis_flags = F_MOD
tt.aura.vis_bans = F_FRIEND
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt = RT("mod_dianyun_passive", "modifier")
tt.modifier.duration = 1
tt.modifier.vis_flags = F_MOD
tt.main_script.insert = mod_dianyun_passive_insert
tt.main_script.remove = mod_dianyun_passive_remove
tt.main_script.update = scripts.mod_track_target.update
tt.fx = "fx_hero_dianyun_lantern"
tt.gold_reward = 1
tt = RT("fx_hero_dianyun_lantern", "fx")
tt.render.sprites[1].name = "hero_storm_dragon_lantern"
tt.render.sprites[1].anchor = v(0.5, 0.111)
tt.render.sprites[1].draw_order = DO_MOD_FX
tt = RT("hero_dianyun_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.main_script.update = hero_dianyun_ultimate_update
tt.entity = "hero_dianyun_electric_son"
tt.sound_events.insert = "HeroDianyunSon"
tt = RT("hero_dianyun_electric_son", "decal_scripted")

AC(tt, "ranged", "idle_flip")

tt.main_script.update = hero_dianyun_electric_son_update
tt.duration = 180
tt.bullets_to_death = 3
tt.render.sprites[1].prefix = "hero_storm_dragon_electric_son"
tt.render.sprites[1].anchor = v(0.5, 0.16)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "hero_storm_dragon_electric_son_shadow"
tt.render.sprites[2].animated = false
tt.render.sprites[2].anchor = v(0.5, 0.16)
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animation = "attack"
tt.ranged.attacks[1].cooldown = 2
tt.ranged.attacks[1].bullet = "bolt_hero_dianyun_electric_son"
tt.ranged.attacks[1].shoot_time = 0.4
tt.ranged.attacks[1].max_range = 160
tt.ranged.attacks[1].bullet_start_offset = v(10, 40)
tt = RT("bolt_hero_dianyun_electric_son", "bolt")
tt.bullet.damage_min = 120
tt.bullet.damage_max = 180
tt.bullet.hit_fx = "fx_hero_dianyun_lightning_hit"
tt.bullet.max_speed = 600
tt.bullet.align_with_trajectory = true
tt.bullet.pop_chance = 0
tt.render.sprites[1].name = "hero_storm_dragon_electric_son_bolt"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].animated = false
tt.main_script.insert = nil
tt.sound_events.insert = "BoltSound"
tt = RT("decal_hero_dianyun_lightning_ricochet", "decal")

for i = 1, 3 do
	if i > 1 then
		tt.render.sprites[i] = CC("sprite")
	end

	tt.render.sprites[i].name = "hero_storm_dragon_lightning_ricochet_fx_layer" .. i
	tt.render.sprites[i].anchor = v(0.5, 0.5)
	tt.render.sprites[i].z = Z_FLYING_HEROES + 1
end
