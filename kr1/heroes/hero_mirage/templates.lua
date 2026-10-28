local bit = require("bit")
local E = require("entity_db")
local GR = require("grid_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")

require("all.constants")

local band = bit.band
local bor = bit.bor
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local queue_damage = U.queue_damage

local function mirage_shadow_insert(this, store)
	local b = this.bullet
	local target = store.entities[b.target_id]

	if not target then
		return false
	end

	b.to:copy(target.pos)

	return true
end

local function mirage_shadow_update(this, store)
	local b = this.bullet
	local target = store.entities[b.target_id]
	local mspeed = U.frandom(b.min_speed, b.max_speed)

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
		target = store.entities[b.target_id]

		if not target or target.health.dead then
			U.animation_start_default(this, "death", nil, store.tick_ts)
			S:queue(this.sound_events.death)

			local smoke = E:create_entity("fx_mirage_smoke")

			smoke.pos = V.vclone(this.pos)
			smoke.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(smoke)
			U.y_animation_wait_default(this)
			simulation:queue_remove_entity(this)

			return
		end

		b.to.x, b.to.y = target.pos.x, target.pos.y
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length

		if V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) < mspeed * fts(8) then
			if this.render.sprites[1].name ~= "attack" then
				local an, af = U.animation_name_facing_point(this, "attack", b.to)

				U.animation_start_default(this, an, af, store.tick_ts, false)
			end
		else
			local an, af = U.animation_name_facing_point(this, "running", b.to)

			U.animation_start_default(this, an, af, store.tick_ts, true)
		end

		coroutine.yield()
	end

	S:queue(this.sound_events.hit)

	if target and not target.health.dead then
		local d = SU.create_bullet_damage(b, target.id, this.id)

		queue_damage(store, d)
	end

	if b.hit_fx and target.unit.blood_color then
		local fx = E:create_entity(b.hit_fx)

		fx.pos:copy(target.pos)

		if target.unit.hit_offset then
			fx.pos.x, fx.pos.y = fx.pos.x + target.unit.hit_offset.x, fx.pos.y + target.unit.hit_offset.y
		end

		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].flip_x = this.render.sprites[1].flip_x

		if fx.use_blood_color then
			fx.render.sprites[1].name = target.unit.blood_color
		end

		simulation:queue_insert_entity(fx)
	end

	simulation:queue_remove_entity(this)
end

-- 幻影-闪避影子
local function soldier_mirage_illusion_insert(this, store)
	this.lifespan.ts = store.tick_ts
	this.melee.order = U.attack_order(this.melee.attacks)

	return true
end

local function soldier_mirage_illusion_update(this, store)
	local attack = this.melee.attacks[1]

	U.y_wait_unconditional(store, attack.cooldown - fts(23))

	while true do
		if this.health.dead or store.tick_ts - this.lifespan.ts > this.lifespan.duration then
			this.health.hp = 0

			U.unblock_target(store, this)
			U.animation_start_default(this, "idle", nil, store.tick_ts)
			S:queue(this.sound_events.death)

			local smoke = E:create_entity("fx_mirage_smoke")

			smoke.pos = V.vclone(this.pos)
			smoke.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(smoke)

			local enemies = U.find_enemies_in_range_filter_off(this.pos, this.melee.attacks[1].damage_radius, F_AREA, 0)

			if enemies then
				for _, e in ipairs(enemies) do
					if e.health and not e.health.dead then
						local d = SU.create_attack_damage(this.melee.attacks[1], e.id, this)

						queue_damage(store, d)
					end
				end
			end

			U.y_wait_unconditional(store, fts(4))
			simulation:queue_remove_entity(this)

			return
		end

		SU.y_soldier_melee_block_and_attacks(store, this)
		coroutine.yield()
	end
end

-- 幻影
local function hero_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local bt = E:get_template(this.ranged.attacks[1].bullet)

	bt.bullet.damage_min = ls.ranged_damage_min[hl]
	bt.bullet.damage_max = ls.ranged_damage_max[hl]

	upgrade_skill(this, "precision", function(this, s)
		this.unit.damage_buff = this.unit.damage_buff + s.extra_buff[s.level]
	end)
	upgrade_skill(this, "shadowdodge", function(this, s)
		this.dodge.chance = s.dodge_chance[s.level]
		this.reward_shadowdance = s.reward_shadowdance[s.level]
		this.reward_lethalstrike = s.reward_lethalstrike[s.level]

		local e = E:get_template("soldier_mirage_illusion")

		e.lifespan.duration = s.lifespan[s.level]
	end)
	upgrade_skill(this, "swiftness", function(this, s)
		U.speed_mul_self(this, s.max_speed_factor[s.level])

		this.melee.range = this.melee.range * s.max_speed_factor[s.level]

		SU.change_fps(store.tick_ts, this, s.fps_factor[s.level])
	end)
	upgrade_skill(this, "shadowdance", function(this, s)
		this.timed_attacks.list[1].disabled = nil
		this.timed_attacks.list[1].burst = s.copies[s.level]
	end)
	upgrade_skill(this, "lethalstrike", function(this, s)
		local la = this.timed_attacks.list[2]

		la.disabled = nil
		la.instakill_chance = s.instakill_chance[s.level]
		la.damage_min = s.damage_min[s.level]
		la.damage_max = s.damage_max[s.level]
	end)
	update_hp(this)
end

local function hero_update(this, store)
	local h = this.health
	local a_sd = this.timed_attacks.list[1]
	local s_sd = this.hero.skills.shadowdance
	local a_l = this.timed_attacks.list[2]
	local s_l = this.hero.skills.lethalstrike
	local brk, sta

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			if this.dodge.active then
				this.dodge.active = false
				this.health.immune_to = F_ALL

				S:queue("HeroMirageShadowDodge")
				U.animation_start_default(this, "disappear", nil, store.tick_ts, false)
				U.y_wait_unconditional(store, fts(3))

				local smoke = E:create_entity("fx_mirage_smoke")

				smoke.pos = V.vclone(this.pos)
				smoke.render.sprites[1].ts = store.tick_ts

				simulation:queue_insert_entity(smoke)
				U.y_animation_wait_default(this)

				local enemy = store.entities[this.soldier.target_id]

				if enemy and not enemy.health.dead then
					local illu = E:create_entity("soldier_mirage_illusion")

					illu.pos = V.vclone(this.pos)

					simulation:queue_insert_entity(illu)
					U.replace_blocker(store, this, illu)

					local enp = enemy.nav_path
					local new_ni = enp.ni
					local node_limit = 20
					local node_jump = 12
					local range

					if node_jump < P:nodes_to_goal(enp.pi, enp.spi, enp.ni) - node_limit then
						range = {new_ni + node_jump, new_ni, -1}
					elseif node_jump < P:nodes_from_start(enp.pi, enp.spi, enp.ni) - node_limit then
						range = {new_ni - node_jump, new_ni, 1}
					else
						goto label_296_0
					end

					for i = range[1], range[2], range[3] do
						local n_pos = P:node_pos(enp.pi, enp.spi, i)

						if P:is_node_valid(enp.pi, i) and GR:cell_is_only(n_pos.x, n_pos.y, TERRAIN_LAND) then
							new_ni = i

							break
						end
					end

					::label_296_0::

					local new_pos = P:node_pos(enp.pi, enp.spi, new_ni)

					this.pos.x, this.pos.y = new_pos.x, new_pos.y
					this.nav_rally.center = V.vclone(this.pos)
					this.nav_rally.pos = V.vclone(this.pos)
				end

				U.y_animation_play(this, "appear", nil, store.tick_ts)

				this.health.immune_to = 0

				if not this.dodge.from_ranged_attack then
					if a_sd.ts then
						a_sd.ts = a_sd.ts - a_sd.cooldown * this.reward_shadowdance
					end

					if a_l.ts then
						a_l.ts = a_l.ts - a_l.cooldown * this.reward_lethalstrike
					end
				end

				local mods = U.find_modifiers_with_flags(this, bor(F_BLOOD, F_BURN, F_POISON))

				for i = 1, #mods do
					local mod = mods[i]

					mod.modifier.removed_by_ban = true

					simulation:queue_remove_entity(mod)
				end

				U.heal(this, this.health.hp_max * 0.1)

				goto label_296_1
			end

			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_296_1
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			if ready_to_use_skill(a_l, store, this.unit.cooldown_factor) then
				local target

				if U.blocker_rank(store, this) ~= nil and U.is_blocked_valid(store, this) and band(store.entities[this.soldier.target_id].vis.bans, a_l.vis_flags) == 0 then
					target = store.entities[this.soldier.target_id]
				else
					target = U.find_random_enemy(store, this.pos, 0, a_l.range, a_l.vis_flags, a_l.vis_bans)
				end

				if not target or target.health.dead then
					a_l.ts = a_l.ts + 0.13333333333333333
				else
					SU.hero_gain_xp_from_skill(this, s_l)
					SU.stun_inc(target)
					S:queue(this.sound_events.lethal_vanish)

					this.health.immune_to = F_ALL

					U.y_animation_play(this, "lethal_out", nil, store.tick_ts)

					local initial_pos = V.vclone(this.pos)
					local lpos, lflip = U.melee_slot_position(this, target, 1, true)

					this.pos.x, this.pos.y = lpos.x, lpos.y

					S:queue(a_l.sound)
					U.animation_start_default(this, "lethal_attack", not lflip, store.tick_ts)
					U.y_wait_unconditional(store, a_l.hit_time)

					if target and not target.health.dead then
						local d = E.assign_damage(DAMAGE_TRUE, 0, this.id, target.id)

						if math.random() < a_l.instakill_chance then
							if band(target.vis.flags, F_BOSS) ~= 0 then
								d.damage_type = a_l.damage_type
								d.value = 2 * a_l.damage_max
							else
								d.pop = {"pop_instakill"}
								d.damage_type = DAMAGE_INSTAKILL
							end
						else
							d.damage_type = a_l.damage_type
							d.value = a_l.damage_max
						end

						d.value = d.value * this.unit.damage_factor

						queue_damage(store, d)

						if d.damage_type ~= DAMAGE_INSTAKILL and a_l.hit_fx and target.unit.blood_color then
							local fx = E:create_entity(a_l.hit_fx)

							fx.pos:copy(target.pos)

							if target.unit.hit_offset then
								fx.pos.x = fx.pos.x + target.unit.hit_offset.x
								fx.pos.y = fx.pos.y + target.unit.hit_offset.y
							end

							fx.render.sprites[1].ts = store.tick_ts
							fx.render.sprites[1].flip_x = this.render.sprites[1].flip_x

							if fx.use_blood_color then
								fx.render.sprites[1].name = target.unit.blood_color
							end

							simulation:queue_insert_entity(fx)
						end
					end

					U.y_animation_wait_default(this)
					SU.stun_dec(target)
					S:queue(this.sound_events.lethal_vanish)

					this.pos.x, this.pos.y = initial_pos.x, initial_pos.y

					U.y_animation_play(this, "lethal_in", lflip, store.tick_ts)

					this.health.immune_to = 0
					a_l.ts = store.tick_ts

					goto label_296_1
				end
			end

			if ready_to_use_skill(a_sd, store, this.unit.cooldown_factor) then
				local targets = U.find_enemies_between_range_filter_on(this.pos, a_sd.min_range, a_sd.max_range, a_sd.vis_flags, a_sd.vis_bans, function(v)
					return (not GR:cell_is(v.pos.x, v.pos.y, TERRAIN_WATER)) and (not GR:cell_is(v.pos.x, v.pos.y, TERRAIN_FAERIE))
				end)

				if targets then
					a_sd.ts = store.tick_ts

					S:queue(a_sd.sound)

					this.health.immune_to = F_ALL

					U.animation_start_default(this, a_sd.animation, nil, store.tick_ts)

					while store.tick_ts - a_sd.ts < a_sd.shoot_time do
						if this.nav_rally.new then
							goto label_296_1
						end

						if this.health.dead then
							goto label_296_1
						end

						if this.unit.is_stunned then
							goto label_296_1
						end

						coroutine.yield()
					end

					SU.hero_gain_xp_from_skill(this, s_sd)

					local targets = U.find_enemies_in_range_filter_on(this.pos, a_sd.max_range * 1.5, a_sd.vis_flags, a_sd.vis_bans, function(v)
						return (not GR:cell_is(v.pos.x, v.pos.y, TERRAIN_WATER)) and (not GR:cell_is(v.pos.x, v.pos.y, TERRAIN_FAERIE))
					end)

					if targets then
						for i = 1, a_sd.burst do
							local target = table.random(targets)
							local b = E:create_entity(a_sd.bullet)

							b.bullet.damage_factor = this.unit.damage_factor
							b.pos.x, b.pos.y = this.pos.x, this.pos.y
							b.bullet.target_id = target.id
							b.bullet.source_id = this.id
							b.bullet.level = s_sd.level

							simulation:queue_insert_entity(b)
						end
					end

					while not U.animation_finished_default(this) do
						if this.nav_rally.new then
							goto label_296_1
						end

						if this.health.dead then
							goto label_296_1
						end

						if this.unit.is_stunned then
							goto label_296_1
						end

						coroutine.yield()
					end

					this.health.immune_to = 0
					a_sd.ts = store.tick_ts

					goto label_296_1
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if sta ~= A_IN_COOLDOWN and (brk or sta ~= A_NO_TARGET) then
			-- block empty
			else
				brk, sta = SU.y_soldier_ranged_attacks(store, this)

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

		::label_296_1::

		coroutine.yield()
	end
end

local tt

tt = RT("hero_mirage", "hero")

AC(tt, "dodge", "melee", "ranged", "timed_attacks")

tt.hero.level_stats.hp_max = {195, 210, 225, 240, 255, 270, 285, 300, 315, 330}
tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.melee_damage_min = {7, 8, 10, 11, 12, 13, 14, 16, 18, 20}
tt.hero.level_stats.melee_damage_max = {11, 13, 14, 16, 18, 20, 22, 24, 26, 28}
tt.hero.level_stats.ranged_damage_min = {7, 8, 10, 11, 12, 13, 14, 16, 18, 20}
tt.hero.level_stats.ranged_damage_max = {11, 13, 14, 16, 18, 20, 22, 23, 25, 27}
tt.hero.skills.precision = CC("hero_skill")
tt.hero.skills.precision.extra_buff = {5, 5, 5}
tt.hero.skills.precision.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.shadowdodge = CC("hero_skill")
tt.hero.skills.shadowdodge.dodge_chance = {0.5, 0.6, 0.7}
tt.hero.skills.shadowdodge.reward_shadowdance = {0.6, 0.8, 1.0}
tt.hero.skills.shadowdodge.reward_lethalstrike = {0.06, 0.12, 0.18}
tt.hero.skills.shadowdodge.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.shadowdodge.lifespan = {1.2, 1.4, 1.6}
tt.hero.skills.swiftness = CC("hero_skill")
tt.hero.skills.swiftness.max_speed_factor = {1.4, 1.3, 1.2}
tt.hero.skills.swiftness.fps_factor = {1.1, 1.09, 1.08}
tt.hero.skills.swiftness.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.shadowdance = CC("hero_skill")
tt.hero.skills.shadowdance.copies = {4, 5, 6}
tt.hero.skills.shadowdance.xp_gain_factor = 20
tt.hero.skills.shadowdance.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.lethalstrike = CC("hero_skill")
tt.hero.skills.lethalstrike.instakill_chance = {0.1, 0.17, 0.25}
tt.hero.skills.lethalstrike.xp_gain_factor = 50
tt.hero.skills.lethalstrike.damage_min = {240, 360, 480}
tt.hero.skills.lethalstrike.damage_max = {240, 360, 480}
tt.hero.skills.lethalstrike.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.dodge.animation = "disappear"
tt.dodge.chance = 0.5
tt.dodge.ranged = true
tt.reward_shadowdance = 0.6
tt.reward_lethalstrike = 0.06
tt.health.dead_lifetime = 15
tt.health.hp_max = tt.hero.level_stats.hp_max[1]
tt.health_bar.offset = vec_2(0, 34)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_level_up
tt.hero.tombstone_show_time = fts(60)
tt.idle_flip.cooldown = 1
tt.info.hero_portrait = "kr2_hero_portraits_0002"
tt.info.portrait = "kr2_info_portraits_heroes_0002"
tt.main_script.update = hero_update
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].cooldown = 0.9
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 3
tt.melee.range = 45
tt.motion.max_speed = 75
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animation = "ranged"
tt.ranged.attacks[1].bullet = "bullet_mirage"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(12, 12), vec_2(12, 12), vec_2(12, 12)}
tt.ranged.attacks[1].cooldown = 0.5
tt.ranged.attacks[1].max_range = 140
tt.ranged.attacks[1].min_range = 25
tt.ranged.attacks[1].shoot_time = fts(4)
tt.regen.cooldown = 1
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].anchor.y = 0.14
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.ranged = {"shoot", "shoot_up", "shoot"}
tt.render.sprites[1].angles.walk = {"running"}
tt.render.sprites[1].angles_custom = {
	ranged = {45, 135, 210, 315}
}
tt.render.sprites[1].angles_flip_vertical = {
	ranged = true
}
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_mirage"
tt.soldier.melee_slot_offset.x = 5
tt.sound_events.change_rally_point = "HeroMirageTaunt"
tt.sound_events.death = "HeroMirageDeath"
tt.sound_events.respawn = "HeroMirageTauntIntro"
tt.sound_events.insert = "HeroMirageTauntIntro"
tt.sound_events.hero_room_select = "HeroMirageTauntSelect"
tt.sound_events.lethal_vanish = "HeroMirageLethalStrikeCastVanish"
tt.timed_attacks.list[1] = CC("bullet_attack")
tt.timed_attacks.list[1].animation = "shadows"
tt.timed_attacks.list[1].bullet = "mirage_shadow"
tt.timed_attacks.list[1].cooldown = 9
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].max_range = 125
tt.timed_attacks.list[1].shoot_time = fts(7)
tt.timed_attacks.list[1].sound = "HeroMirageShadowDanceCast"
tt.timed_attacks.list[1].vis_bans = bor(F_CLIFF)
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].cooldown = 15
tt.timed_attacks.list[2].damage_max = 100
tt.timed_attacks.list[2].damage_min = 100
tt.timed_attacks.list[2].damage_type = DAMAGE_TRUE
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].hit_fx = "fx_mirage_blood"
tt.timed_attacks.list[2].hit_time = fts(7)
tt.timed_attacks.list[2].range = 130
tt.timed_attacks.list[2].sound = "HeroMirageLethalStrikeCastHit"
tt.timed_attacks.list[2].vis_bans = bor(F_CLIFF, F_WATER)
tt.timed_attacks.list[2].vis_flags = bor(F_LETHAL, F_RANGED)
tt.unit.marker_offset = vec_2(0, -1)
tt.unit.mod_offset = vec_2(0, 16)
tt = RT("bullet_mirage", "arrow")
tt.bullet.hit_blood_fx = "fx_blood_splat"
tt.bullet.hit_fx = "fx_bullet_mirage_hit"
tt.bullet.miss_fx = "fx_bullet_mirage_hit"
tt.bullet.miss_fx_water = "fx_bullet_mirage_hit"
tt.bullet.miss_decal = nil
tt.bullet.flight_time = fts(14)
tt.bullet.xp_gain_factor = 3
tt.bullet.damage_min = nil
tt.bullet.damage_max = nil
tt.bullet.hide_radius = 4
tt.bullet.pop = {"pop_shunt_violet"}
tt.render.sprites[1].name = "proy_mirage_0001"
tt = RT("fx_bullet_mirage_hit", "fx")
tt.render.sprites[1].name = "fx_bullet_mirage_hit"
tt = RT("fx_mirage_smoke", "fx")
tt.render.sprites[1].name = "fx_hero_mirage_smoke"
tt.render.sprites[1].anchor.y = 0.11
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -1
tt = RT("fx_mirage_blood", "fx")
tt.render.sprites[1].prefix = "mirage_blood"
tt.render.sprites[1].name = "red"
tt.use_blood_color = true
tt = RT("mirage_shadow", "bullet")
tt.bullet.damage_inc = 6
tt.bullet.damage_max = 22
tt.bullet.damage_min = 22
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.hit_fx = "fx_mirage_blood"
tt.bullet.max_speed = 180
tt.bullet.min_speed = 150
tt.main_script.insert = mirage_shadow_insert
tt.main_script.update = mirage_shadow_update
tt.render.sprites[1].name = "running"
tt.render.sprites[1].prefix = "mirage_shadow"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].anchor.y = 0.14
tt.sound_events.death = "HeroMirageShadowDodgePuff"
tt.sound_events.hit = "HeroMirageShadowDanceHit"
tt = RT("soldier_mirage_illusion", "unit")

AC(tt, "soldier", "motion", "nav_path", "main_script", "vis", "lifespan", "melee", "sound_events")

tt.ui = nil
tt.render.sprites[1].anchor.y = 0.14
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "soldier_mirage_illusion"
tt.render.sprites[1].alpha = 230
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"running"}
tt.health.hp_max = 60
tt.health_bar.offset = vec_2(0, 34)
tt.health_bar.hidden = true
tt.lifespan.duration = 1 + fts(6)
tt.melee.range = 64
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 10
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].damage_radius = 30
tt.melee.attacks[1].damage_type = DAMAGE_TRUE
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].sound = "MeleeSword"
tt.main_script.insert = soldier_mirage_illusion_insert
tt.main_script.update = soldier_mirage_illusion_update
tt.motion.max_speed = 90
tt.soldier.melee_slot_offset.x = 5
tt.sound_events.death = "HeroMirageShadowDodgePuff"
tt.unit.mod_offset = vec_2(0, 16)
tt.unit.hit_offset = vec_2(0, 12)
tt.vis.bans = bor(F_POISON, F_CANNIBALIZE, F_STUN, F_SKELETON, F_LYCAN)
tt.vis.flags = F_FRIEND
