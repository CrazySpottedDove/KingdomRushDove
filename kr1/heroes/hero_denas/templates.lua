local bit = require("bit")
local E = require("entity_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")

require("lib.klua.table")
require("all.constants")

local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp

local function catapult_controller_update(this, store)
	local w = store.visible_coords.right - store.visible_coords.left
	local rock_x = this.pos.x > w * 0.5 and store.visible_coords.right + this.rock_offset.x or store.visible_coords.left - this.rock_offset.x
	local rock_y = this.pos.y + this.rock_offset.y
	local a = this.initial_angle

	U.y_wait_unconditional(store, this.initial_delay)

	local delay = 0

	for i = 1, math.random(2, 4) do
		S:queue(this.sound_events.shoot, {
			delay = delay
		})

		delay = delay + U.frandom(0.1, 0.3)
	end

	for i = 1, this.count do
		U.y_wait_unconditional(store, U.frandom(unpack(this.rock_delay)))

		local r = U.frandom(0, 1) * 40 + 20
		local bullet = E:create_entity(this.bullet)

		bullet.pos = V.v(rock_x, rock_y)
		bullet.bullet.from:copy(bullet.pos)
		bullet.bullet.to = U.point_on_ellipse(this.pos, r, a)
		bullet.bullet.target_id = nil
		bullet.bullet.source_id = this.id
		bullet.bullet.damage_factor = this.damage_factor

		simulation:queue_insert_entity(bullet)

		a = a + this.angle_increment
	end

	U.y_wait_unconditional(store, this.exit_time)

	this.tween.reverse = true
	this.tween.remove = true
	this.tween.ts = store.tick_ts
end
-- 迪纳斯-施加buff特效
local function cursing_update(this, store)
	this.render.sprites[1].ts = store.tick_ts

	local source = store.entities[this.source_id]
	local source_pos = source and V.vclone(source.pos) or nil
	local ts = store.tick_ts

	if not source or not source.health or source.health.dead then
	-- block empty
	else
		this.pos = V.vclone(source.pos)
		this.pos.x = this.pos.x + this.offset.x
		this.pos.y = this.pos.y + this.offset.y
		this.render.sprites[1].flip_x = source.render.sprites[1].flip_x

		while store.tick_ts - ts < this.duration do
			if source.pos.x ~= source_pos.x or source.pos.y ~= source_pos.y or source.health.death then
				break
			end

			coroutine.yield()
		end
	end

	simulation:queue_remove_entity(this)
end
-- 迪纳斯-被buff塔特效
local function buff_aura_update(this, store)
	local target = store.entities[this.aura.target_id]
	local ts = store.tick_ts - this.aura.cycle_time
	local start_ts = store.tick_ts
	local inserted_entities = {}
	local force_remove = false

	if not target then
	-- block empty
	else
		this.pos = V.vclone(target.pos)
		this.tween.disabled = false
		this.tween.props[1].ts = store.tick_ts

		while true do
			if store.tick_ts - start_ts >= this.aura.duration then
				break
			end

			if target.pos.x ~= this.pos.x or target.pos.y ~= this.pos.y or target.health.death then
				force_remove = true

				break
			end

			if store.tick_ts - ts >= this.aura.cycle_time then
				ts = store.tick_ts

				local e = E:create_entity(this.entity)

				e.pos = V.vclone(this.pos)
				e.tween.disabled = false

				for i, t in ipairs(e.tween.props) do
					e.tween.props[i].ts = store.tick_ts
				end

				table.insert(inserted_entities, e)
				simulation:queue_insert_entity(e)
			end

			coroutine.yield()
		end
	end

	if force_remove then
		for _, e in pairs(inserted_entities) do
			simulation:queue_remove_entity(e)
		end
	end

	simulation:queue_remove_entity(this)
end
-- 迪纳斯-buff
local function mod_tower_insert(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or not target.tower then
		return false
	end

	SU.insert_tower_cooldown_buff(store.tick_ts, target, this.cooldown_factor)
	SU.insert_tower_range_buff(target, this.range_factor, true)

	for i = 1, #this.render.sprites do
		local s = this.render.sprites[i]

		s.ts = store.tick_ts
	end

	return true
end

local function mod_tower_update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if target then
		this.pos = target.pos
	end

	m.ts = store.tick_ts
	this.tween.ts = store.tick_ts

	while store.tick_ts - m.ts < m.duration - 0.5 do
		coroutine.yield()
	end

	this.tween.reverse = true
	this.tween.ts = store.tick_ts

	U.y_wait_unconditional(store, 0.5)
	simulation:queue_remove_entity(this)
end

local function mod_tower_remove(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or not target.tower then
		return true
	end

	SU.remove_tower_cooldown_buff(store.tick_ts, target, this.cooldown_factor)
	SU.remove_tower_range_buff(target, this.range_factor, true)

	return true
end
-- 迪纳斯
local function hero_level_up(this, store)
	local hl, ls = level_up_basic(this)

	for _, b in pairs(this.timed_attacks.list[1].bullets) do
		local bt = E:get_template(b)

		bt.bullet.damage_min = ls.ranged_damage_min[hl]
		bt.bullet.damage_max = ls.ranged_damage_max[hl]
	end

	for _, b in pairs(this.ranged.attacks[1].bullets) do
		local bt = E:get_template(b)

		bt.bullet.damage_min = ls.ranged_damage_min[hl]
		bt.bullet.damage_max = ls.ranged_damage_max[hl]
	end

	upgrade_skill(this, "tower_buff", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil

		local m = E:get_template(a.mod)

		m.modifier.duration = s.duration[s.level]
	end)
	upgrade_skill(this, "catapult", function(this, s)
		local a = this.timed_attacks.list[3]

		a.disabled = nil

		local c = E:get_template(a.entity)

		c.count = s.count[s.level]

		local r = E:get_template(c.bullet)

		r.bullet.damage_min = s.damage_min[s.level]
		r.bullet.damage_max = s.damage_max[s.level]
	end)

	update_hp(this)
end

local function hero_update(this, store)
	local h = this.health
	local a, skill, target, pred_pos
	local rock_flight_time = E:get_template("denas_catapult_rock").bullet.flight_time

	U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)

	this.health_bar.hidden = false
	for _, t in pairs(E:filter_templates("tower")) do
		t.tower.price = math.floor(t.tower.price * this.tower_price_factor)
	end

	local function do_denas_attack(target, attack, pred_pos)
		local bullet
		local bullet_to = pred_pos or target.pos

		local bidx = math.random(1, #a.animations)
		local animation = attack.animations[bidx]
		local bullet_name = attack.bullets[bidx]
		local an, af, ai = U.animation_name_facing_point(this, animation, bullet_to)

		U.animation_start_default(this, an, af, store.tick_ts, false)

		if SU.y_soldier_wait(store, this, a.shoot_time) then
			return
		end

		bullet = E:create_entity(bullet_name)
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
		bullet.bullet.level = attack.level
		bullet.bullet.damage_factor = this.unit.damage_factor
		bullet.bullet.damage_min = bullet.bullet.damage_min + this.unit.damage_buff
		bullet.bullet.damage_max = bullet.bullet.damage_max + this.unit.damage_buff

		simulation:queue_insert_entity(bullet)

		if U.y_animation_wait_default(this) then
			return
		end

		return true
	end

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_54_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.tower_buff

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local towers = U.find_towers_in_range(store.towers, this.pos, a, function(t)
					return t.tower.can_be_mod
				end)

				if not towers or #towers <= 0 then
					a.ts = a.ts + 0.134
				else
					local start_ts = store.tick_ts

					S:queue(a.sound)
					U.animation_start_default(this, a.animation, nil, store.tick_ts, false)

					if SU.y_soldier_wait(store, this, a.curse_time) then
						goto label_54_0
					end

					local curse = E:create_entity("denas_cursing")

					curse.source_id = this.id

					simulation:queue_insert_entity(curse)

					if SU.y_soldier_wait(store, this, a.cast_time - a.curse_time) then
						goto label_54_0
					end

					a.ts = start_ts

					SU.hero_gain_xp_from_skill(this, skill)

					local au = E:create_entity(a.aura)

					au.aura.target_id = this.id
					au.aura.source_id = this.id

					simulation:queue_insert_entity(au)

					for _, t in ipairs(towers) do
						local m = E:create_entity(a.mod)

						m.modifier.source_id = this.id
						m.modifier.target_id = t.id

						simulation:queue_insert_entity(m)
					end

					SU.y_hero_animation_wait(this)

					goto label_54_0
				end
			end

			a = this.timed_attacks.list[3]
			skill = this.hero.skills.catapult

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local target = U.find_random_enemy(store, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if not target then
					a.ts = a.ts + 0.134
				else
					local start_ts = store.tick_ts
					local flip = target.pos.x < this.pos.x

					S:queue(a.sound)
					U.animation_start_default(this, a.animation, flip, store.tick_ts)

					if SU.y_soldier_wait(store, this, a.cast_time) then
						goto label_54_0
					end

					a.ts = start_ts

					SU.hero_gain_xp_from_skill(this, skill)

					local pi, _, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni
					local n_off = P:predict_enemy_node_advance(target, rock_flight_time)

					if P:is_node_valid(pi, ni + n_off) then
						ni = ni + n_off
					end

					local pos = P:node_pos(pi, 1, ni)
					local e = E:create_entity(a.entity)

					e.damage_factor = this.unit.damage_factor
					e.pos = pos

					simulation:queue_insert_entity(e)
					SU.y_hero_animation_wait(this)

					goto label_54_0
				end
			end

			a = this.timed_attacks.list[1]
			target = SU.soldier_pick_melee_target(store, this)

			if target then
				if SU.soldier_move_to_slot_step(store, this, target) then
				-- block empty
				elseif store.tick_ts - a.ts < a.cooldown then
				-- block empty
				else
					a.ts = store.tick_ts

					do_denas_attack(target, a)
				end
			else
				target, a, pred_pos = SU.soldier_pick_ranged_target_and_attack(store, this)

				if target and a then
					U.set_destination(this, this.pos)

					a.ts = store.tick_ts

					if not do_denas_attack(target, a, pred_pos) then
						goto label_54_0
					end
				end

				if SU.soldier_go_back_step(store, this) then
				-- block empty
				else
					SU.soldier_idle(store, this)
					SU.soldier_regen(store, this)
				end
			end
		end

		::label_54_0::

		coroutine.yield()
	end
end

local anchor_x, anchor_y = 0.5, 0.26
local tt

tt = RT("hero_denas", "hero")
AC(tt, "melee", "ranged", "timed_attacks")
tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.hp_max = {300, 340, 380, 420, 450, 480, 510, 530, 550, 570}
tt.hero.level_stats.melee_damage_max = {19, 23, 28, 33, 38, 42, 47, 52, 56, 61}
tt.hero.level_stats.melee_damage_min = {11, 14, 17, 20, 23, 25, 28, 31, 34, 37}
tt.hero.level_stats.ranged_damage_max = {19, 23, 28, 33, 38, 42, 47, 52, 56, 61}
tt.hero.level_stats.ranged_damage_min = {11, 14, 17, 20, 23, 25, 28, 31, 34, 37}
tt.hero.skills.tower_buff = CC("hero_skill")
tt.hero.skills.tower_buff.duration = {5, 8, 11}
tt.hero.skills.tower_buff.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.tower_buff.xp_gain = {75, 125, 175}
tt.hero.skills.catapult = CC("hero_skill")
tt.hero.skills.catapult.count = {4, 6, 8, 10}
tt.hero.skills.catapult.damage_min = {15, 17, 19, 21}
tt.hero.skills.catapult.damage_max = {30, 34, 38, 42}
tt.hero.skills.catapult.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.catapult.xp_gain = {50, 100, 200, 300}
tt.tower_price_factor = 0.95
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, 60)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_level_up
tt.hero.tombstone_show_time = fts(60)
tt.info.hero_portrait = "hero_portraits_0007"
tt.info.portrait = "info_portraits_heroes_0007"
tt.main_script.update = hero_update
tt.motion.max_speed = 2.7 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "hero_denas"
tt.soldier.melee_slot_offset = vec_2(22, 0)
tt.sound_events.change_rally_point = "HeroDenasTaunt"
tt.sound_events.death = "HeroDenasDeath"
tt.sound_events.hero_room_select = "HeroDenasTauntSelect"
tt.sound_events.insert = "HeroRainOfFireTauntIntro"
tt.sound_events.respawn = "HeroRainOfFireTauntIntro"
tt.ui.click_rect = r(-22, 15, 44, 32)
tt.unit.hit_offset = vec_2(0, 31)
tt.unit.mod_offset = vec_2(0, 30)
tt.melee.range = 45
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animations = {"attack", "attackBarrell", "attackChicken", "attackBottle"}
tt.ranged.attacks[1].bullet = "projectile_denas"
tt.ranged.attacks[1].bullets = {"projectile_denas", "projectile_denas_barrell", "projectile_denas_chicken", "projectile_denas_bottle"}
tt.ranged.attacks[1].bullet_start_offset = {vec_2(10, 36)}
tt.ranged.attacks[1].cooldown = fts(19)
tt.ranged.attacks[1].max_range = 175
tt.ranged.attacks[1].min_range = 45
tt.ranged.attacks[1].node_prediction = fts(10)
tt.ranged.attacks[1].shoot_time = fts(7)
tt.timed_attacks.list[1] = table.deepclone(tt.ranged.attacks[1])
tt.timed_attacks.list[1].bullets = {"projectile_denas_melee", "projectile_denas_melee_barrell", "projectile_denas_melee_chicken", "projectile_denas_melee_bottle"}
tt.timed_attacks.list[1].cooldown = 1.5
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[2] = CC("mod_attack")
tt.timed_attacks.list[2].animation = "buffTowers"
tt.timed_attacks.list[2].cooldown = 10 + fts(51)
tt.timed_attacks.list[2].cast_time = fts(13)
tt.timed_attacks.list[2].curse_time = fts(2)
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].max_range = 200
tt.timed_attacks.list[2].min_range = 0
tt.timed_attacks.list[2].mod = "mod_denas_tower"
tt.timed_attacks.list[2].aura = "denas_buff_aura"
tt.timed_attacks.list[2].sound = "HeroDenasBuff"
tt.timed_attacks.list[2].xp_from_skill = "buff_towers"
tt.timed_attacks.list[3] = CC("spawn_attack")
tt.timed_attacks.list[3].animation = "catapult"
tt.timed_attacks.list[3].entity = "denas_catapult_controller"
tt.timed_attacks.list[3].cooldown = 10 + fts(40)
tt.timed_attacks.list[3].cast_time = fts(15)
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].max_range = 165
tt.timed_attacks.list[3].min_range = 50
tt.timed_attacks.list[3].sound = "HeroDenasAttack"
tt.timed_attacks.list[3].vis_bans = F_FRIEND
tt.timed_attacks.list[3].vis_flags = F_RANGED
tt.timed_attacks.list[3].xp_from_skill = "catapult"

tt = RT("denas_cursing", "decal_scripted")
tt.render.sprites[1].name = "hero_denas_cursing"
tt.duration = fts(36)
tt.offset = vec_2(0, 25)
tt.main_script.update = cursing_update

tt = RT("denas_catapult_controller", "decal_scripted")
AC(tt, "tween", "sound_events")
tt.bullet = "denas_catapult_rock"
tt.main_script.update = catapult_controller_update
tt.initial_angle = d2r(0)
tt.initial_delay = 0.25
tt.rock_delay = {fts(2), fts(8)}
tt.angle_increment = d2r(60)
tt.rock_offset = vec_2(90, 100)
tt.exit_time = 0.5 + fts(45)
tt.render.sprites[1].name = "hero_king_catapultDecal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 0}, {0.2, 255}}
tt.tween.remove = false
tt.sound_events.shoot = "BombShootSound"

tt = RT("denas_buffing_circle", "decal_timed")
AC(tt, "tween")
tt.render.sprites[1].name = "hero_king_glow"
tt.render.sprites[1].anchor = vec_2(0.5, 0.26)
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.disabled = false
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 25.5}, {0.33, 255}, {1, 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_2(0.7, 0.7)}, {1, vec_2(1.8, 1.8)}}

tt = RT("mod_denas_tower", "modifier")
AC(tt, "render", "tween")
tt.range_factor = 1.25
tt.cooldown_factor = 0.75
tt.main_script.insert = mod_tower_insert
tt.main_script.remove = mod_tower_remove
tt.main_script.update = mod_tower_update
tt.modifier.use_mod_offset = false
tt.render.sprites[1].draw_order = 11
tt.render.sprites[1].name = "mod_denas_tower"
tt.render.sprites[1].anchor = vec_2(0.5, 0.32)
tt.render.sprites[1].offset.y = 7
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}
tt.tween.remove = false

tt = RT("projectile_denas", "arrow")
tt.bullet.flight_time = fts(20)
tt.bullet.rotation_speed = 15 * FPS * math.pi / 180
tt.bullet.damage_min = 11
tt.bullet.damage_max = 19
tt.bullet.hit_blood_fx = "fx_blood_splat"
tt.bullet.miss_decal = nil
tt.bullet.miss_fx = "fx_smoke_bullet"
tt.bullet.track_kills = true
tt.bullet.xp_gain_factor = 2.42
tt.render.sprites[1].name = "hero_king_projectiles_0001"
tt.sound_events.insert = "AxeSound"

tt = RT("projectile_denas_barrell", "projectile_denas")
tt.render.sprites[1].name = "hero_king_projectiles_0002"

tt = RT("projectile_denas_chicken", "projectile_denas")
tt.render.sprites[1].name = "hero_king_projectiles_0003"

tt = RT("projectile_denas_bottle", "projectile_denas")
tt.render.sprites[1].name = "hero_king_projectiles_0004"

tt = RT("projectile_denas_melee", "projectile_denas")
tt.bullet.flight_time = fts(13)

tt = RT("projectile_denas_melee_barrell", "projectile_denas_barrell")
tt.bullet.flight_time = fts(13)

tt = RT("projectile_denas_melee_chicken", "projectile_denas_chicken")
tt.bullet.flight_time = fts(13)

tt = RT("projectile_denas_melee_bottle", "projectile_denas_bottle")
tt.bullet.flight_time = fts(13)

tt = RT("denas_catapult_rock", "bomb")
tt.bullet.flight_time = fts(45)
tt.bullet.damage_radius = 55
tt.bullet.damage_min = nil
tt.bullet.damage_max = nil
tt.bullet.g = -0.8 / (fts(1) * fts(1))
tt.bullet.particles_name = "ps_power_fireball"
tt.render.sprites[1].name = "hero_king_catapultProjectile"
tt.render.sprites[1].scale = vec_2(0.7, 0.7)
tt.sound_events.insert = nil

tt = RT("denas_buff_aura", "aura")
AC(tt, "render", "tween")
tt.aura.duration = 1.63
tt.entity = "denas_buffing_circle"
tt.main_script.update = buff_aura_update
tt.render.sprites[1].name = "hero_king_glowShadow"
tt.render.sprites[1].anchor = vec_2(0.5, 0.26)
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.disabled = true
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 0}, {0.13, 255}, {1.63, 255}, {2.76, 0}}

