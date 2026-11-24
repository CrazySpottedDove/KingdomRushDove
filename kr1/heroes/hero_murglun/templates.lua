local E = require("entity_db")
local HU = require("hero_utils")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local bit = require("bit")
local km = require("lib.klua.macros")
local signal = require("lib.hump.signal")
local scripts = require("scripts")

local bor = bit.bor
local fts = U.fts
local level_up_basic = HU.level_up_basic
local queue_damage = U.queue_damage
local ready_to_attack = U.ready_to_attack
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local v = V.v
local tt

---普攻弹道：复用飞龙弹道脚本，命中后留下熔岩池
---@param this table 弹道实体
---@param store table game.store
local function bolt_murglun_update(this, store)
	local b = this.bullet

	scripts.fireball_dragon.update(this, store)

	if b.hit_payload then
		local target = store.entities[b.target_id]

		if not (target and U.flag_has(target.vis.flags, F_FLYING)) then
			local payload = E:create_entity(b.hit_payload)

			payload.pos.x, payload.pos.y = b.to.x, b.to.y
			payload.aura.source_id = this.id
			payload.aura.damage_factor = b.damage_factor

			simulation:queue_insert_entity(payload)
		end
	end
end

---岩浆血：从空中落到地面并结算范围真实伤害
---@param this table 弹道实体
---@param store table game.store
local function lava_blood_murglun_update(this, store)
	local b = this.bullet
	local mspeed = b.min_speed
	local tl = store.tick_length

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * tl do
		mspeed = mspeed + FPS * math.ceil(mspeed * (1 / FPS) * b.acceleration_factor)
		mspeed = km.clamp(b.min_speed, b.max_speed, mspeed)

		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * tl, this.pos.y + b.speed.y * tl
		this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

		coroutine.yield()
	end

	local targets = U.find_enemies_in_range_filter_off(b.to, b.damage_radius, F_NONE, F_NONE)

	if targets then
		for _, e in ipairs(targets) do
			local d = SU.create_bullet_damage(b, e.id, this.id)

			d.xp_dest_id = b.source_id

			queue_damage(store, d)
		end
	end

	local fx = E:create_entity(b.hit_fx)

	fx.pos.x, fx.pos.y = b.to.x, b.to.y
	fx.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(fx)
	simulation:queue_remove_entity(this)
end

---岩浆血控制器：按 0.3–0.6 秒的随机间隔在英雄脚下滴落岩浆
---@param this table 控制器实体
---@param store table game.store
local function lava_blood_murglun_controller_update(this, store)
	local owner_id = this.owner_id

	this.ts = store.tick_ts
	this.next = U.frandom(this.cooldown_min, this.cooldown_max)

	while true do
		local owner = store.entities[owner_id]

		if not owner then
			simulation:queue_remove_entity(this)

			return
		end

		if not owner.health.dead and store.tick_ts - this.ts >= this.next then
			this.ts = store.tick_ts
			this.next = U.frandom(this.cooldown_min, this.cooldown_max)

			local b = E:create_entity("lava_blood_murglun")
			local tx = owner.pos.x + math.random(-20, 20)

			b.pos.x, b.pos.y = tx, owner.pos.y + 130
			b.bullet.from = V.vclone(b.pos)
			b.bullet.to = V.v(tx, owner.pos.y)
			b.bullet.source_id = owner_id
			b.bullet.damage_factor = owner.unit.damage_factor

			simulation:queue_insert_entity(b)
		end

		coroutine.yield()
	end
end

---焦油制造者控制器：周期给英雄附近的防御塔挂增伤
---@param this table 控制器实体
---@param store table game.store
local function tar_maker_murglun_controller_update(this, store)
	local owner_id = this.owner_id

	this.ts = store.tick_ts

	while true do
		local owner = store.entities[owner_id]

		if not owner then
			simulation:queue_remove_entity(this)

			return
		end

		local skill = owner.hero.skills.tar_maker

		if not owner.health.dead and skill.level > 0 and store.tick_ts - this.ts >= this.cooldown then
			this.ts = store.tick_ts

			for _, e in pairs(store.towers) do
				if e.tower.can_be_mod and U.is_inside_ellipse(e.pos, owner.pos, this.range) then
					local m = E:create_entity(this.mod)

					m.modifier.level = skill.level
					m.modifier.target_id = e.id
					m.modifier.source_id = owner_id
					m.modifier.duration = 1
					m.pos.x, m.pos.y = e.pos.x, e.pos.y

					simulation:queue_insert_entity(m)
				end
			end

		end

		coroutine.yield()
	end
end

---大招陨石：落地后秒杀范围内敌人，Boss 改为真实伤害
---@param this table 弹道实体
---@param store table game.store
local function fireball_murglun_ultimate_update(this, store)
	local b = this.bullet
	local mspeed = 10 * FPS
	local particle = E:create_entity("ps_power_fireball")

	particle.particle_system.track_id = this.id

	simulation:queue_insert_entity(particle)

	local shadow = E:create_entity("decal_fireball_shadow")

	shadow.pos.x, shadow.pos.y = b.to.x, b.to.y
	shadow.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(shadow)

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
		mspeed = mspeed + FPS * math.ceil(mspeed * (1 / FPS) * b.acceleration_factor)
		mspeed = km.clamp(b.min_speed, b.max_speed, mspeed)

		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
		this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

		coroutine.yield()
	end

	particle.particle_system.source_lifetime = 0

	local targets = U.find_enemies_in_range_filter_off(b.to, b.damage_radius, F_NONE, F_NONE)

	if targets then
		for _, e in ipairs(targets) do
			local d = SU.create_bullet_damage(b, e.id, b.source_id or this.id)

			if U.flag_has(e.vis.flags, bor(F_BOSS, F_MINIBOSS)) then
				d.damage_type = DAMAGE_TRUE
			end

			queue_damage(store, d)
		end
	end

	S:queue(this.sound_events.hit)

	local decal = E:create_entity(b.hit_decal)

	decal.pos.x, decal.pos.y = b.to.x, b.to.y
	decal.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(decal)

	local fx = E:create_entity(b.hit_fx)

	fx.pos.x, fx.pos.y = b.to.x, b.to.y
	fx.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(fx)
	simulation:queue_remove_entity(shadow)
	simulation:queue_remove_entity(this)
end

---大招控制器：在目标周围依次落下陨石
---@param this table 控制器实体
---@param store table game.store
local function hero_murglun_ultimate_update(this, store)
	local start_y = store.visible_coords and store.visible_coords.top or REF_H
	local a = this.aura
	local owner_pos = V.vclone(this.pos)

	for _ = 1, a.loops do
		local b = E:create_entity(a.entity)
		local tx = owner_pos.x + math.random(-35, 35)
		local ty = owner_pos.y + math.random(-35, 35)
		local dx = (start_y - ty) * 0.4

		b.pos.x, b.pos.y = tx + dx, start_y
		b.bullet.from = V.vclone(b.pos)
		b.bullet.to = V.v(tx, ty)
		b.bullet.source_id = this.source_id or this.id
		b.bullet.damage_factor = this.damage_factor

		simulation:queue_insert_entity(b)

		U.y_wait(store, a.delay)
	end

	simulation:queue_remove_entity(this)
end

---塔增伤：给范围内可被增益的防御塔挂上增伤修饰器
---@param this table 修饰器实体
---@param store table game.store
local function range_mod_murglun_insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or not target.tower then
		return false
	end

	SU.insert_tower_damage_factor_buff(target, this.damage_bonus)

	signal.emit("mod-applied", this, target)

	return true
end

---塔增伤：移除修饰器时还原伤害系数
---@param this table 修饰器实体
---@param store table game.store
local function range_mod_murglun_remove(this, store)
	local target = store.entities[this.modifier.target_id]

	if target and target.tower then
		SU.remove_tower_damage_factor_buff(target, this.damage_bonus)
	end

	return true
end

---技能与等级数值
---@param this table 英雄实体
---@param store table game.store
local function hero_murglun_level_up(this, store)
	local hl, ls = level_up_basic(this)
	local bullet_t = E:get_template(this.ranged.attacks[1].bullet)

	bullet_t.bullet.damage_min = ls.ranged_damage_min[hl]
	bullet_t.bullet.damage_max = ls.ranged_damage_max[hl]

	upgrade_skill(this, "magma_pool", function(this, s)
		local aura = E:get_template("aura_basic_attack_murglun")
		local mod = E:get_template(aura.aura.mod)

		aura.aura.duration = s.duration[s.level]
		mod.dps.damage_min = s.damage[s.level]
		mod.dps.damage_max = s.damage[s.level]
		bullet_t.bullet.hit_payload = "aura_basic_attack_murglun"
	end)

	upgrade_skill(this, "tar_maker", function(this, s)
		E:get_template("range_mod_murglun").damage_bonus = s.bonus[s.level]
	end)

	upgrade_skill(this, "geyser", function(this, s)
		local a = this.timed_attacks.list[1]

		a.cooldown = s.cooldown[s.level]
		a.disabled = nil
	end)

	upgrade_skill(this, "infernal_heat", function(this, s)
		local a = this.timed_attacks.list[2]

		a.cooldown = s.cooldown[s.level]
		a.disabled = nil
	end)

	upgrade_skill(this, "ultimate", function(this, s)
		local b = E:get_template("fireball_murglun_ultimate")

		this.ultimate.disabled = nil
		this.ultimate.cooldown = s.cooldown[s.level]
		b.bullet.damage_min = s.boss_damage[s.level]
		b.bullet.damage_max = s.boss_damage[s.level]
	end)

	update_hp(this)
end

---英雄主循环
---@param this table 英雄实体
---@param store table game.store
local function hero_murglun_update(this, store)
	local h = this.health
	local he = this.hero
	local attack = this.ranged.attacks[1]
	local geyser_attack = this.timed_attacks.list[1]
	local heat_attack = this.timed_attacks.list[2]

	attack.ts = store.tick_ts
	geyser_attack.ts = store.tick_ts
	heat_attack.ts = store.tick_ts

	U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)
	this.health_bar.hidden = false

	local lava_blood = E:create_entity("decal_lava_blood_murglun")
	local tar_maker = E:create_entity("decal_tar_maker_murglun")

	lava_blood.owner_id = this.id
	tar_maker.owner_id = this.id

	simulation:queue_insert_entity(lava_blood)
	simulation:queue_insert_entity(tar_maker)

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		while this.nav_rally.new do
			SU.y_hero_new_rally(store, this)
		end

		if SU.hero_level_up(store, this) then
			U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
		end

		if ready_to_use_skill(geyser_attack, store, this.unit.cooldown_factor) then
			local target = U.find_nearest_enemy(store, this.pos, geyser_attack.min_range, geyser_attack.max_range, geyser_attack.vis_flags, geyser_attack.vis_bans)

			if target then
				local start_ts = store.tick_ts

				S:queue(geyser_attack.sound)
				U.animation_start_default(this, geyser_attack.animation, nil, store.tick_ts, false)

				if SU.y_hero_wait(store, this, attack.shoot_time) then
					goto next_tick
				end

				geyser_attack.ts = start_ts
				SU.hero_gain_xp_from_skill(this, he.skills.geyser)

				local fx = E:create_entity("fx_murglun_geiser")

				fx.pos.x, fx.pos.y = target.pos.x, target.pos.y
				fx.render.sprites[1].ts = store.tick_ts

				simulation:queue_insert_entity(fx)

				local decal = E:create_entity("fx_murglun_geiser_death")

				decal.pos.x, decal.pos.y = target.pos.x, target.pos.y
				decal.render.sprites[1].ts = store.tick_ts

				simulation:queue_insert_entity(decal)
				queue_damage(store, E.assign_damage(DAMAGE_INSTAKILL, 1, this.id, target.id))
				SU.y_hero_animation_wait(this)
			else
				geyser_attack.ts = geyser_attack.ts + 0.1
			end
		end

		if ready_to_attack(attack, store, this.unit.cooldown_factor) then
			local target = U.find_random_enemy(store, this.pos, attack.min_range, attack.max_range, attack.vis_flags, attack.vis_bans)

			if target then
				local start_ts = store.tick_ts
				local an, af = U.animation_name_facing_point(this, attack.animation, target.pos)

				U.animation_start_default(this, an, af, store.tick_ts)

				if SU.y_hero_wait(store, this, attack.shoot_time) then
					goto next_tick
				end

				S:queue(attack.sound)

				local b = E:create_entity(attack.bullet)

				b.bullet.source_id = this.id
				b.bullet.target_id = target.id
				b.bullet.xp_dest_id = this.id
				b.bullet.damage_factor = this.unit.damage_factor
				b.pos.x, b.pos.y = this.pos.x + (af and -1 or 1) * attack.bullet_start_offset[1].x, this.pos.y + attack.bullet_start_offset[1].y
				b.bullet.from = V.vclone(b.pos)
				b.bullet.to = V.vclone(target.pos)

				simulation:queue_insert_entity(b)

				attack.ts = start_ts

				SU.y_hero_animation_wait(this)
			else
				attack.ts = attack.ts + 0.1
			end
		end

		if ready_to_use_skill(heat_attack, store, this.unit.cooldown_factor) then
			local target = U.find_nearest_enemy(store, this.pos, heat_attack.min_range, heat_attack.max_range, heat_attack.vis_flags, heat_attack.vis_bans)

			if target then
				local start_ts = store.tick_ts
				S:queue(heat_attack.sound)
				U.animation_start_default(this, heat_attack.animation, nil, store.tick_ts, false)

				if SU.y_hero_wait(store, this, heat_attack.shoot_time) then
					goto next_tick
				end

				heat_attack.ts = start_ts
				SU.hero_gain_xp_from_skill(this, he.skills.infernal_heat)

				local new_target = U.find_nearest_enemy(store, this.pos, heat_attack.min_range, heat_attack.max_range, heat_attack.vis_flags, heat_attack.vis_bans)
				if new_target then
					target = new_target
				end
				local aura = E:create_entity(heat_attack.aura)

				aura.pos:copy(target.pos)
				aura.aura.source_id = this.id
				aura.aura.damage_factor = this.unit.damage_factor

				simulation:queue_insert_entity(aura)
				SU.y_hero_animation_wait(this)
			else
				heat_attack.ts = heat_attack.ts + 0.1
			end
		end

		if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
			local enemy = U.find_biggest_enemy_in_range_filter_off(this.pos, attack.max_range, F_RANGED, F_NONE)

			if enemy and enemy.pos and enemy.health.hp > BIG_ENEMY_HP then
				HU.apply_ultimate(this, store, enemy.pos, "levelup")
			else
				this.ultimate.ts = this.ultimate.ts + 1
			end
		end

		SU.soldier_idle(store, this)
		SU.soldier_regen(store, this)

		::next_tick::

		coroutine.yield()
	end
end

tt = RT("bolt_murglun", "bullet")
AC(tt, "force_motion")
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.damage_radius = 40
tt.bullet.max_speed = 390
tt.bullet.min_speed = 390
tt.bullet.hit_fx = "hero_murglun_attack_explotion_run"
tt.bullet.hit_fx_air = "hero_murglun_attack_explotion_run"
tt.bullet.vis_flags = F_RANGED
tt.bullet.xp_gain_factor = 1.8
tt.main_script.update = bolt_murglun_update
tt.render.sprites[1].anchor.x = 0.69
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "hero_murglun_attack_proy"
tt.render.sprites[1].z = Z_BULLETS
tt.sound_events.hit = "HeroDragonAttackHit"

tt = RT("hero_murglun_attack_explotion_run", "fx")
tt.render.sprites[1].anchor.y = 0.13
tt.render.sprites[1].name = "run"
tt.render.sprites[1].prefix = "hero_murglun_attack_explotion"
tt.render.sprites[1].sort_y_offset = -2
tt.render.sprites[1].z = Z_OBJECTS

tt = RT("decal_lava_blood_murglun")
AC(tt, "main_script", "pos")
tt.main_script.update = lava_blood_murglun_controller_update
tt.cooldown_min = 0.3
tt.cooldown_max = 0.6

tt = RT("decal_tar_maker_murglun")
AC(tt, "main_script", "pos")
tt.main_script.update = tar_maker_murglun_controller_update
tt.range = 200
tt.cooldown = 0.5
tt.mod = "range_mod_murglun"

tt = RT("fx_murglun_geiser", "fx")
tt.render.sprites[1].anchor.y = 0.13
tt.render.sprites[1].name = "hero_murglun_geiser_run"
tt.render.sprites[1].z = Z_OBJECTS

tt = RT("fx_murglun_geiser_death", "decal_tween")
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "hero_murglun_geiser_death_run"
tt.tween.props[1].keys = {{fts(17), 255}, {fts(27), 0}}

tt = RT("lava_blood_murglun", "bullet")
tt.bullet.acceleration_factor = 0.05
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_max = 23
tt.bullet.damage_min = 23
tt.bullet.damage_radius = 50
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.hit_fx = "fx_murglun_lavablood_explosion"
tt.bullet.max_speed = 18 * FPS
tt.bullet.min_speed = 18 * FPS
tt.main_script.update = lava_blood_murglun_update
tt.render.sprites[1].animated = false
tt.render.sprites[1].flip_x = true
tt.render.sprites[1].name = "hero_murglun_lava_blood_proy"
tt.scorch_earth = false

tt = RT("fx_murglun_lavablood_explosion", "fx")
tt.render.sprites[1].anchor.y = 0.13
tt.render.sprites[1].name = "run"
tt.render.sprites[1].prefix = "hero_murglun_lava_blood_explotion"
tt.render.sprites[1].sort_y_offset = -2
tt.render.sprites[1].z = Z_OBJECTS

tt = RT("aura_basic_attack_murglun", "aura")

AC(tt, "render", "tween")

tt.aura.cycle_time = 0.3
tt.aura.duration = 5
tt.aura.mod = "mod_basic_attack_murglun"
tt.aura.radius = 33
tt.aura.use_mod_offset = false
tt.aura.vis_bans = bor(F_FRIEND, F_FLYING)
tt.aura.vis_flags = bor(F_MOD)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "hero_murglun_attack_decals_0001"
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 255}, {"this.aura.duration-1", 255}, {"this.aura.duration", 0}}
tt.tween.remove = false

tt = RT("mod_basic_attack_murglun", "modifier")

AC(tt, "dps", "render")

tt.dps.damage_every = fts(6)
tt.dps.damage_max = 0
tt.dps.damage_min = 0
tt.dps.damage_type = DAMAGE_TRUE
tt.dps.kill = true
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt.modifier.duration = 1
tt.render.sprites[1].draw_order = 10
tt.render.sprites[1].name = "small"
tt.render.sprites[1].prefix = "fire"
tt.render.sprites[1].size_names = {"small", "medium", "large"}

tt = RT("range_mod_murglun", "modifier")
AC(tt, "render", "tween")
tt.main_script.insert = range_mod_murglun_insert
tt.main_script.update = scripts.mod_tower_factors.update
tt.main_script.remove = range_mod_murglun_remove
tt.modifier.duration = 1
tt.damage_bonus = 0.05
tt.render.sprites[1].anchor.y = 0.21
tt.render.sprites[1].animated = true
tt.render.sprites[1].name = "hero_murglun_tower_fx_run"
tt.render.sprites[1].z = Z_TOWER_BASES + 1
tt.tween.props[1].keys = {{0, v(1, 1)}, {0.5, v(0.9, 0.9)}, {1, v(1, 1)}}
tt.tween.props[1].loop = true
tt.tween.props[1].name = "scale"
tt.tween.remove = false

tt = RT("aura_murglun_firestorm", "aura")
AC(tt, "render", "tween")
tt.aura.cycle_time = 0.2
tt.aura.duration = 5
tt.aura.mod = "mod_murglun_firestorm"
tt.aura.radius = 60
tt.aura.use_mod_offset = false
tt.aura.vis_bans = bor(F_FRIEND, F_FLYING)
tt.aura.vis_flags = bor(F_MOD)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.render.sprites[1].loop = true
tt.render.sprites[1].prefix = "hero_murglun_heat_wave_decal"
tt.render.sprites[1].scale = v(1, 0.5)
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].loop = true
tt.render.sprites[2].prefix = "hero_murglun_heat_wave_fx1"
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].loop = true
tt.render.sprites[3].prefix = "hero_murglun_heat_wave_fx2"
tt.render.sprites[3].z = Z_DECALS
tt.tween.props[1].keys = {{0, 255}, {"this.aura.duration-1", 255}, {"this.aura.duration", 0}}
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[3] = table.deepclone(tt.tween.props[1])
tt.tween.remove = false

tt = RT("mod_murglun_firestorm", "modifier")
AC(tt, "dps", "render")
tt.dps.damage_every = 0.2
tt.dps.damage_max = 5
tt.dps.damage_min = 5
tt.dps.damage_type = DAMAGE_TRUE
tt.dps.kill = true
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt.modifier.allows_duplicates = true
tt.modifier.duration = 0.2
tt.render.sprites[1].draw_order = 10
tt.render.sprites[1].name = "small"
tt.render.sprites[1].prefix = "fire"
tt.render.sprites[1].size_names = {"small", "medium", "large"}

tt = RT("hero_murglun_ultimate_rocks_run", "decal_tween")
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "hero_murglun_ultimate_rocks_run"
tt.tween.props[1].keys = {{fts(17), 255}, {fts(27), 0}}

tt = RT("fx_murglun_fireball_explosion", "fx")
tt.render.sprites[1].anchor.y = 0.15
tt.render.sprites[1].name = "hero_murglun_ultimate_explotion_run"
tt.render.sprites[1].z = Z_OBJECTS

tt = RT("fireball_murglun_ultimate", "bullet")
tt.bullet.acceleration_factor = 0.05
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_max = 250
tt.bullet.damage_min = 250
tt.bullet.damage_radius = 50
tt.bullet.damage_type = DAMAGE_INSTAKILL
tt.bullet.hit_decal = "hero_murglun_ultimate_rocks_run"
tt.bullet.hit_fx = "fx_murglun_fireball_explosion"
tt.bullet.max_speed = 24 * FPS
tt.bullet.min_speed = 24 * FPS
tt.main_script.update = fireball_murglun_ultimate_update
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "hero_murglun_ultimate_proy"
tt.sound_events.hit = "FireballHit"
tt.sound_events.insert = "FireballRelease"

tt = RT("hero_murglun_ultimate")

AC(tt, "aura", "main_script", "pos", "sound_events")

tt.aura.delay = fts(15)
tt.aura.entity = "fireball_murglun_ultimate"
tt.aura.loops = 6
tt.main_script.update = hero_murglun_ultimate_update

tt = RT("hero_murglun", "hero")
AC(tt, "ranged", "timed_attacks")
tt.health.dead_lifetime = 15
tt.health_bar.draw_order = 10
tt.health_bar.offset = v(0, 157)
tt.health_bar.sort_y_offset = -200
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.hero.fn_level_up = hero_murglun_level_up
tt.hero.level_stats.armor = {0.04, 0.06, 0.08, 0.1, 0.12, 0.14, 0.16, 0.18, 0.2, 0.22}
tt.hero.level_stats.hp_max = {320, 345, 370, 395, 420, 445, 470, 495, 520, 545}
tt.hero.level_stats.ranged_damage_max = {25, 33, 41, 49, 57, 65, 73, 81, 88, 96}
tt.hero.level_stats.ranged_damage_min = {15, 19, 23, 27, 31, 35, 39, 43, 48, 52}
tt.info.hero_portrait = "kr4_hero_portraits_0011"
tt.info.portrait = "kr4_info_portraits_heroes_0013"
tt.main_script.update = hero_murglun_update
tt.motion.max_speed = 3 * FPS
tt.nav_grid.ignore_waypoints = true
tt.nav_grid.valid_terrains = bor(TERRAIN_NONE, TERRAIN_LAND, TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK, TERRAIN_SHALLOW, TERRAIN_FAERIE, TERRAIN_ICE)
tt.nav_grid.valid_terrains_dest = tt.nav_grid.valid_terrains
tt.nav_rally.requires_node_nearby = false
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.04
tt.render.sprites[1].angles.walk = {"idle"}
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_murglun"
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "hero_murglun_shadow"
tt.render.sprites[2].z = Z_DECALS + 1
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animation = "attack"
tt.ranged.attacks[1].bullet = "bolt_murglun"
tt.ranged.attacks[1].bullet_start_offset = {v(45, 85)}
tt.ranged.attacks[1].cooldown = 2
tt.ranged.attacks[1].estimated_flight_time = 1
tt.ranged.attacks[1].ignore_hit_offset = true
tt.ranged.attacks[1].max_range = 175
tt.ranged.attacks[1].min_range = 20
tt.ranged.attacks[1].shoot_time = fts(16)
tt.ranged.attacks[1].sound = "hero_murglun_attack"
tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
tt.ranged.attacks[1].vis_flags = bor(F_RANGED)
tt.sound_events.change_rally_point = "group_murglun_taunt"
tt.sound_events.death = "hero_murglun_death"
tt.sound_events.hero_room_select = "hero_murglun_taunt_1"
tt.sound_events.insert = "hero_murglun_taunt_1"
tt.sound_events.respawn = "group_murglun_taunt"
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].animation = "geiser"
tt.timed_attacks.list[1].cooldown = 70
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].max_range = 175
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].shoot_time = fts(0)
tt.timed_attacks.list[1].sound = "hero_murglun_attack"
tt.timed_attacks.list[1].vis_bans = bor(F_FRIEND, F_NIGHTMARE, F_FLYING, F_CLIFF, F_BOSS, F_MINIBOSS)
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].animation = "heatWave"
tt.timed_attacks.list[2].cooldown = 22
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].max_range = 175
tt.timed_attacks.list[2].min_range = 0
tt.timed_attacks.list[2].shoot_time = fts(20)
tt.timed_attacks.list[2].sound = "hero_murglun_pool_taunt"
tt.timed_attacks.list[2].aura = "aura_murglun_firestorm"
tt.timed_attacks.list[2].vis_bans = bor(F_FRIEND, F_NIGHTMARE, F_CLIFF, F_FLYING)
tt.timed_attacks.list[2].vis_flags = bor(F_RANGED)
tt.ui.click_rect = r(-45, 70, 90, 50)
tt.ultimate = {
	ts = 0,
	cooldown = 96,
	disabled = true
}
tt.unit.head_offset = v(0, 130)
tt.unit.hit_offset = v(0, 92)
tt.unit.marker_offset = v(0, 130)
tt.unit.mod_offset = v(0, 150)
tt.vis.bans = bor(tt.vis.bans, F_EAT, F_NET, F_BURN)
tt.vis.flags = bor(tt.vis.flags, F_FLYING)
tt.hero.skills.geyser = CC("hero_skill")
tt.hero.skills.geyser.cooldown = {70, 60, 50}
tt.hero.skills.geyser.xp_gain = {300, 400, 500}
tt.hero.skills.geyser.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.hero.skills.infernal_heat = CC("hero_skill")
tt.hero.skills.infernal_heat.cooldown = {22, 18, 14}
tt.hero.skills.infernal_heat.xp_gain = {180, 240, 300}
tt.hero.skills.infernal_heat.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.magma_pool = CC("hero_skill")
tt.hero.skills.magma_pool.damage = {2, 4, 6}
tt.hero.skills.magma_pool.duration = {5, 5, 6}
tt.hero.skills.magma_pool.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.tar_maker = CC("hero_skill")
tt.hero.skills.tar_maker.bonus = {0.05, 0.1, 0.2}
tt.hero.skills.tar_maker.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.boss_damage = {250, 300, 350, 400}
tt.hero.skills.ultimate.controller_name = "hero_murglun_ultimate"
tt.hero.skills.ultimate.cooldown = {96, 88, 80, 72}
tt.hero.skills.ultimate.xp_gain = {200, 400, 600, 800}
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
