local bit = require("bit")
local E = require("entity_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")
local scripts = require("scripts")

require("all.constants")

local bor = bit.bor
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local queue_damage = U.queue_damage

local function magnus_arcane_rain_controller_update(this, store)
	this.tween.disabled = false
	this.tween.ts = store.tick_ts

	local range_factor = this.render.sprites[1].scale.x
	local a = this.initial_angle

	for i = 1, this.count do
		U.y_wait_unconditional(store, this.spawn_time)

		local r = (U.frandom(0, 1) * 40 + 15) * range_factor
		local pos = U.point_on_ellipse(this.pos, r, a)
		local e = E:create_entity(this.entity)

		e.pos = V.vclone(pos)

		if this.is_illusion then
			e.damage_type = DAMAGE_MAGICAL
			e.damage_radius = e.damage_radius * range_factor
			e.render.sprites[1].scale = V.vv(range_factor)
		end

		e.damage_factor = this.damage_factor

		simulation:queue_insert_entity(e)

		a = a + this.angle_increment

		if a > 2 * math.pi then
			a = a - 2 * math.pi
		end
	end

	U.y_wait_unconditional(store, 0.5)

	this.tween.reverse = true
	this.tween.remove = true
	this.tween.ts = store.tick_ts
end

local function magnus_arcane_rain_update(this, store)
	this.render.sprites[1].ts = store.tick_ts

	U.animation_start_default(this, "drop", nil, store.tick_ts, false)
	S:queue(this.sound)
	U.y_wait_unconditional(store, this.hit_time)

	local targets = U.find_enemies_in_range_filter_off(this.pos, this.damage_radius, this.damage_flags, this.damage_bans or 0)

	if targets then
		for _, target in ipairs(targets) do
			local d = E.assign_damage(this.damage_type, math.random(this.damage_min, this.damage_max) * this.damage_factor, this.id, target.id)

			queue_damage(store, d)
		end
	end

	U.y_animation_wait_default(this)
	simulation:queue_remove_entity(this)
end

local function soldier_magnus_illusion_update(this, store)
	-- as a soldier
	local brk, stam, star

	this.reinforcement.ts = store.tick_ts
	this.render.sprites[1].ts = store.tick_ts

	if this.sound_events and this.sound_events.raise then
		S:queue(this.sound_events.raise)
	end

	this.health_bar.hidden = true
	U.y_animation_play(this, "raise", nil, store.tick_ts, 1)

	if not this.health.dead then
		this.health_bar.hidden = nil
	end

	local arcane_rain = this.timed_attacks.list[1]

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
			-- enable arcane rain attack
			if ready_to_use_skill(arcane_rain, store, this.unit.cooldown_factor) then
				local target = U.find_random_enemy(store, this.pos, arcane_rain.min_range, arcane_rain.max_range, arcane_rain.vis_flags, arcane_rain.vis_bans)

				if not target then
					arcane_rain.ts = arcane_rain.ts + 0.13333333333333333
				else
					S:queue(arcane_rain.sound)

					local flip = target.pos.x < this.pos.x

					this.render.sprites[1].prefix = "hero_magnus"

					U.animation_start_default(this, arcane_rain.animation, flip, store.tick_ts)

					if U.y_wait_conditional(store, arcane_rain.cast_time, function()
						return SU.soldier_interrupted(this)
					end) then
						goto label_34_0
					end

					arcane_rain.ts = store.tick_ts

					local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni

					if #target.enemy.blockers == 0 and P:is_node_valid(pi, ni + 5) then
						ni = ni + 5
					end

					local pos = P:node_pos(pi, spi, ni)
					local e = E:create_entity(arcane_rain.entity)

					e.is_illusion = true
					e.pos = pos
					e.damage_factor = this.unit.damage_factor * this.skill_damage_factor
					e.render.sprites[1].scale = V.v(this.skill_radius_factor, this.skill_radius_factor)

					simulation:queue_insert_entity(e)

					if not U.y_animation_wait_default(this) then
						this.render.sprites[1].prefix = "soldier_magnus_illusion"

						goto label_34_0
					end
				end
			end

			if this.melee then
				brk, stam = SU.y_soldier_melee_block_and_attacks(store, this)

				if brk or stam == A_DONE or stam == A_IN_COOLDOWN and not this.melee.continue_in_cooldown then
					goto label_34_1
				end
			end

			if this.ranged then
				brk, star = SU.y_soldier_ranged_attacks(store, this)

				if brk or star == A_DONE then
					goto label_34_1
				elseif star == A_IN_COOLDOWN then
					goto label_34_0
				end
			end

			if this.melee.continue_in_cooldown and stam == A_IN_COOLDOWN then
				goto label_34_1
			end

			if SU.soldier_go_back_step(store, this) then
				goto label_34_1
			end

			::label_34_0::

			SU.soldier_idle(store, this)
			SU.soldier_regen(store, this)
		end

		::label_34_1::

		coroutine.yield()
	end
end

local function hero_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local ra = this.ranged.attacks[1]
	local b = E:get_template(ra.bullet)

	b.bullet.damage_min = ls.ranged_damage_min[hl]
	b.bullet.damage_max = ls.ranged_damage_max[hl]

	upgrade_skill(this, "mirage", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.count = s.count[s.level]

		local il = E:get_template(a.entity)

		il.level = hl
		il.health.hp_max = ls.hp_max[s.level] * s.health_factor
		il.melee.attacks[1].damage_min = ls.melee_damage_min[s.level] * s.damage_factor
		il.melee.attacks[1].damage_max = ls.melee_damage_max[s.level] * s.damage_factor

		local ira = il.ranged.attacks[1]
		local ib = E:get_template(ira.bullet)

		ib.bullet.damage_min = ls.ranged_damage_min[s.level] * s.damage_factor
		ib.bullet.damage_max = ls.ranged_damage_max[s.level] * s.damage_factor
		il.timed_attacks = il.timed_attacks or {}
		il.timed_attacks.list = il.timed_attacks.list or {}
		il.timed_attacks.list[1] = table.deepclone(this.timed_attacks.list[2])
	end)
	upgrade_skill(this, "arcane_rain", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil

		local c = E:get_template(a.entity)

		c.count = s.count[s.level]

		local r = E:get_template(c.entity)

		r.damage_min = s.damage[s.level]
		r.damage_max = s.damage[s.level]
	end)

	update_hp(this)
end

local function hero_update(this, store)
	local h = this.health
	local a, skill, brk, sta

	U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)

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
					goto label_75_0
				end
			end

			skill = this.hero.skills.mirage
			a = this.timed_attacks.list[1]

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				S:queue(a.sound)
				U.animation_start_default(this, a.animation, nil, store.tick_ts)

				if U.y_wait_conditional(store, a.cast_time, function()
					return SU.hero_interrupted(this)
				end) then
					goto label_75_0
				end

				SU.hero_gain_xp_from_skill(this, skill)

				a.ts = store.tick_ts

				for i = 1, a.count do
					local angle = 2 * math.pi * i / a.count
					local o = V.v(V.rotate(angle, a.initial_pos.x, a.initial_pos.y))
					local r = V.v(V.rotate(angle, a.initial_rally.x, a.initial_rally.y))
					local e = E:create_entity(a.entity)
					local rx, ry = this.pos.x + r.x, this.pos.y + r.y

					e.nav_rally.center = V.v(rx, ry)
					e.nav_rally.pos = V.v(rx, ry)
					e.pos.x, e.pos.y = this.pos.x + o.x, this.pos.y + o.y
					e.tween.ts = store.tick_ts
					e.tween.props[1].keys[1][2].x = -o.x
					e.tween.props[1].keys[1][2].y = -o.y
					e.render.sprites[1].flip_x = this.render.sprites[1].flip_x
					e.owner = this
					SU.insert_unit_damage_factor_buff(e, this.unit.damage_factor - e.unit.damage_factor)

					simulation:queue_insert_entity(e)
				end

				if not U.y_animation_wait_default(this) then
					goto label_75_0
				end
			end

			skill = this.hero.skills.arcane_rain
			a = this.timed_attacks.list[2]

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local target = U.find_random_enemy(store, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if not target then
					a.ts = a.ts + 0.13333333333333333
				else
					S:queue(a.sound)

					local flip = target.pos.x < this.pos.x

					U.animation_start_default(this, a.animation, flip, store.tick_ts)

					if U.y_wait_conditional(store, a.cast_time, function()
						return SU.hero_interrupted(this)
					end) then
						goto label_75_0
					end

					SU.hero_gain_xp_from_skill(this, skill)

					a.ts = store.tick_ts

					local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni

					if #target.enemy.blockers == 0 and P:is_node_valid(pi, ni + 5) then
						ni = ni + 5
					end

					local pos = P:node_pos(pi, spi, ni)
					local e = E:create_entity(a.entity)

					e.pos = pos
					e.source_id = this.id
					e.damage_factor = this.unit.damage_factor
					e.render.sprites[1].scale = V.v(1, 1)

					simulation:queue_insert_entity(e)

					if not U.y_animation_wait_default(this) then
						goto label_75_0
					end
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)
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

		::label_75_0::

		coroutine.yield()
	end
end

local tt

tt = RT("fx_bolt_magnus_hit", "fx")
tt.render.sprites[1].name = "bolt_magnus_hit"

tt = RT("bolt_magnus", "bolt")
tt.render.sprites[1].prefix = "bolt_magnus"
tt.bullet.hit_fx = "fx_bolt_magnus_hit"
tt.bullet.pop = nil
tt.bullet.pop_conds = nil
tt.bullet.acceleration_factor = 0.1
tt.bullet.damage_min = 9
tt.bullet.damage_max = 27
tt.bullet.max_speed = 360
tt.bullet.xp_gain_factor = 2.2

tt = RT("bolt_magnus_illusion", "bolt_magnus")
tt.bullet.damage_min = nil
tt.bullet.damage_max = nil
tt.bullet.xp_gain_factor = nil

tt = RT("hero_magnus", "hero")
AC(tt, "melee", "ranged", "timed_attacks", "teleport")
tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.hp_max = {170, 190, 210, 230, 250, 270, 290, 310, 330, 350}
tt.hero.level_stats.melee_damage_max = {2, 4, 5, 6, 7, 8, 10, 11, 12, 13}
tt.hero.level_stats.melee_damage_min = {1, 2, 2, 3, 4, 5, 6, 6, 7, 8}
tt.hero.level_stats.ranged_damage_max = {27, 32, 36, 41, 45, 50, 54, 59, 63, 68}
tt.hero.level_stats.ranged_damage_min = {9, 11, 12, 14, 15, 17, 18, 20, 21, 23}
tt.hero.skills.mirage = CC("hero_skill")
tt.hero.skills.mirage.count = {1, 2, 3, 4, 5, 6}
tt.hero.skills.mirage.health_factor = 0.15
tt.hero.skills.mirage.damage_factor = 0.3
tt.hero.skills.mirage.xp_level_steps = {
	[2] = 1,
	[3] = 2,
	[5] = 3,
	[6] = 4,
	[8] = 5,
	[9] = 6
}
tt.hero.skills.mirage.xp_gain = {75, 100, 125, 150, 175, 175}
tt.hero.skills.arcane_rain = CC("hero_skill")
tt.hero.skills.arcane_rain.count = {8, 12, 16}
tt.hero.skills.arcane_rain.damage = {25, 25, 25}
tt.hero.skills.arcane_rain.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.hero.skills.arcane_rain.xp_gain = {75, 100, 150}
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, 33)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_level_up
tt.hero.tombstone_show_time = fts(60)
tt.info.hero_portrait = "hero_portraits_0005"
tt.info.portrait = "info_portraits_heroes_0005"
tt.main_script.update = hero_update
tt.motion.max_speed = 1.2 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = vec_2(0.5, 0.14)
tt.render.sprites[1].prefix = "hero_magnus"
tt.soldier.melee_slot_offset = vec_2(4, 0)
tt.sound_events.death = "HeroMageDeath"
tt.sound_events.insert = "HeroMageTauntIntro"
tt.sound_events.respawn = "HeroMageTauntIntro"
tt.sound_events.change_rally_point = "HeroMageTaunt"
tt.sound_events.hero_room_select = "HeroMageTauntSelect"
tt.teleport.min_distance = 45
tt.teleport.sound = "TeleporthSound"
tt.ui.click_rect = r(-13, -5, 26, 32)
tt.unit.mod_offset = vec_2(0, 15)
tt.melee.range = 45
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].xp_gain_factor = 2.5
tt.melee.attacks[1].damage_type = DAMAGE_MAGICAL
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].bullet = "bolt_magnus"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(0, 23)}
tt.ranged.attacks[1].max_range = 175
tt.ranged.attacks[1].min_range = 50
tt.ranged.attacks[1].shoot_time = fts(18)
tt.ranged.attacks[1].cooldown = fts(33)
tt.timed_attacks.list[1] = CC("spawn_attack")
tt.timed_attacks.list[1].animation = "mirage"
tt.timed_attacks.list[1].cooldown = 10 + fts(29)
tt.timed_attacks.list[1].cast_time = fts(12)
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].entity = "soldier_magnus_illusion"
tt.timed_attacks.list[1].sound = "HeroMageShadows"
tt.timed_attacks.list[1].spawn_time = fts(19)
tt.timed_attacks.list[1].initial_rally = vec_2(0, 30)
tt.timed_attacks.list[1].initial_pos = vec_2(0, 33)
tt.timed_attacks.list[1].radius = 30
tt.timed_attacks.list[1].xp_from_skill = "mirage"
tt.timed_attacks.list[2] = CC("spawn_attack")
tt.timed_attacks.list[2].animation = "arcaneRain"
tt.timed_attacks.list[2].entity = "magnus_arcane_rain_controller"
tt.timed_attacks.list[2].cooldown = 14 + fts(25)
tt.timed_attacks.list[2].cast_time = fts(15)
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].max_range = 200
tt.timed_attacks.list[2].min_range = 0
tt.timed_attacks.list[2].sound = "HeroMageRainCharge"
tt.timed_attacks.list[2].vis_bans = bor(F_FRIEND)
tt.timed_attacks.list[2].vis_flags = F_RANGED
tt.timed_attacks.list[2].xp_from_skill = "arcane_rain"

tt = RT("magnus_arcane_rain_controller", "decal_scripted")
AC(tt, "tween")
tt.main_script.update = magnus_arcane_rain_controller_update
tt.spawn_time = fts(6)
tt.initial_angle = d2r(0)
tt.angle_increment = d2r(70)
tt.entity = "magnus_arcane_rain"
tt.decal = "decal_magnus_arcane_rain"
tt.render.sprites[1].name = "hero_mage_rain_decal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}
tt.tween.remove = false
tt.tween.disabled = true

tt = RT("magnus_arcane_rain")
AC(tt, "render", "main_script", "pos")
tt.damage_type = DAMAGE_TRUE
tt.damage_radius = 40
tt.damage_min = 20
tt.damage_max = 20
tt.hit_time = fts(10)
tt.damage_flags = F_AREA
tt.main_script.update = magnus_arcane_rain_update
tt.render.sprites[1].prefix = "magnus_arcane_rain"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = vec_2(0.5, 0.07)
tt.sound = "HeroMageRainDrop"

tt = RT("soldier_magnus_illusion", "soldier_militia")
AC(tt, "reinforcement", "ranged", "tween")
tt.health.hp_max = nil
tt.health_bar.offset = vec_2(0, 33)
tt.health.dead_lifetime = fts(14)
tt.info.portrait = "info_portraits_heroes_0005"
tt.info.random_name_format = nil
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = soldier_magnus_illusion_update
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.range = 45
tt.skill_radius_factor = 0.8
tt.skill_damage_factor = 0.4
tt.reinforcement.duration = 10
tt.reinforcement.fade = nil
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].bullet = "bolt_magnus_illusion"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(0, 23)}
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].min_range = 50
tt.ranged.attacks[1].shoot_time = fts(18)
tt.ranged.attacks[1].cooldown = fts(33)
tt.render.sprites[1].prefix = "soldier_magnus_illusion"
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].alpha = 180
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {{0, vec_2(0, 0)}, {fts(6), vec_2(0, 0)}}
tt.tween.remove = false
tt.tween.run_once = true
tt.ui.click_rect = r(-13, -5, 26, 32)
tt.unit.mod_offset = vec_2(0, 15)
tt.vis.bans = bor(F_LYCAN, F_SKELETON, F_CANNIBALIZE)
