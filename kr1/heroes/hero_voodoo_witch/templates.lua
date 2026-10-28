local bit = require("bit")
local E = require("entity_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")
local scripts = require("scripts")
local log = require("lib.klua.log"):new("hero_voodoo_witch")

require("lib.klua.table")
require("all.constants")

local band = bit.band
local bor = bit.bor
local v = V.v
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local update_hp = HU.update_hp
local queue_damage = U.queue_damage

local function hero_level_up(this, store)
	local hl, ls = level_up_basic(this)
	local a = this.melee.attacks[1]

	a.damage_max = ls.damage_max[hl]
	a.damage_min = ls.damage_min[hl]

	local b = E:get_template("bolt_voodoo_witch")

	b.bullet.damage_max = ls.ranged_damage_max[hl]
	b.bullet.damage_min = ls.ranged_damage_min[hl]

	upgrade_skill(this, "laughingskulls", function(this, s)
		local b = E:get_template("bolt_voodoo_witch_skull")

		b.bullet.damage_min = b.bullet.damage_min + s.extra_damage[s.level]
		b.bullet.damage_max = b.bullet.damage_max + s.extra_damage[s.level]
	end)
	upgrade_skill(this, "deathskull", function(this, s)
		local sk = E:get_template("voodoo_witch_skull")

		sk.sacrifice.disabled = nil
		sk.sacrifice.damage = s.damage[s.level]
	end)
	upgrade_skill(this, "bonedance", function(this, s)
		local a = E:get_template("voodoo_witch_skull_aura")

		a.skull_count = s.skull_count[s.level]

		local sp = E:get_template("mod_voodoo_witch_skull_spawn")

		sp.skull_count = s.skull_count[s.level]
	end)
	upgrade_skill(this, "deathaura", function(this, s)
		local m = E:get_template("mod_voodoo_witch_aura_slow")

		m.slow.factor = s.slow_factor[s.level]
	end)
	upgrade_skill(this, "voodoomagic", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.damage = s.damage[s.level]
		a.count = s.count[s.level]
	end)
	update_hp(this)
end

local function hero_insert(this, store)
	this.hero.fn_level_up(this, store)

	this.ranged.order = U.attack_order(this.ranged.attacks)
	this.melee.order = U.attack_order(this.melee.attacks)

	local e = E:create_entity("voodoo_witch_death_aura")

	e.aura.source_id = this.id
	e.aura.ts = store.tick_ts

	simulation:queue_insert_entity(e)

	local e = E:create_entity("voodoo_witch_skull_aura")

	e.aura.source_id = this.id
	e.aura.ts = store.tick_ts

	simulation:queue_insert_entity(e)

	return true
end

local function hero_update(this, store)
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
					goto label_458_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.voodoomagic

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local targets_in_range = U.find_enemies_between_range_filter_off(this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if not targets_in_range then
					a.ts = a.ts + 0.267
				else
					local targets_per_type = {}

					for _, t in pairs(store.enemies) do
						if not t.health.dead then
							if not targets_per_type[t.template_name] then
								targets_per_type[t.template_name] = {t}
							else
								table.insert(targets_per_type[t.template_name], t)
							end
						end
					end

					local targets

					for _, t in pairs(targets_in_range) do
						local v = targets_per_type[t.template_name]

						if v and #v >= a.min_count then
							targets = v

							break
						end
					end

					if not targets then
						a.ts = a.ts + 0.267
					else
						table.sort(targets, function(e1, e2)
							return V.dist(e1.pos.x, e1.pos.y, this.pos.x, this.pos.y) < V.dist(e2.pos.x, e2.pos.y, this.pos.x, this.pos.y)
						end)

						targets = table.slice(targets, 1, a.count)

						S:queue(a.sound)
						U.animation_start_default(this, a.animation, nil, store.tick_ts)

						local start_ts = store.tick_ts

						while store.tick_ts - start_ts < fts(10) do
							if SU.hero_interrupted(this) then
								goto label_458_0
							end

							coroutine.yield()
						end

						a.ts = store.tick_ts

						SU.hero_gain_xp_from_skill(this, skill)

						for _, t in ipairs(targets) do
							if not t.health.dead and store.entities[t.id] then
								local m = E:create_entity(a.mod_fx)

								m.modifier.target_id = t.id
								m.modifier.source_id = this.id

								simulation:queue_insert_entity(m)
							end
						end

						U.y_wait_unconditional(store, fts(16))

						for _, t in ipairs(targets) do
							if not t.health.dead and store.entities[t.id] then
								local d = E.assign_damage(a.damage_type, a.damage, this.id, t.id)

								queue_damage(store, d)

								local m = E:create_entity(a.mod_slow)

								m.modifier.target_id = t.id
								m.modifier.source_id = this.id

								simulation:queue_insert_entity(m)
							end
						end

						while not U.animation_finished_default(this) do
							if SU.hero_interrupted(this) then
								break
							end

							coroutine.yield()
						end

						goto label_458_0
					end
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

		::label_458_0::

		coroutine.yield()
	end
end

local function voodoo_witch_skull_aura_update(this, store)
	local a = this.aura

	a.ts = store.tick_ts

	local last_ts = store.tick_ts
	local source = store.entities[a.source_id]
	local rot_phase = 0

	this.pos = source.pos

	local last_pos = V.vclone(this.pos)

	while true do
		if not source.health.dead and store.tick_ts - last_ts >= a.cycle_time then
			last_ts = store.tick_ts

			local targets = U.find_targets_in_range(store.entities, this.pos, 0, a.radius, F_NONE, a.vis_bans)

			if targets then
				for _, target in ipairs(targets) do
					if target.enemy or (target.soldier and band(target.vis.bans, a.vis_flags) == 0) then
						local m = E:create_entity("mod_voodoo_witch_skull_spawn")

						m.modifier.source_id = this.id
						m.modifier.target_id = target.id

						simulation:queue_insert_entity(m)
					end
				end
			end
		end

		if V.veq(source.pos, last_pos) then
			rot_phase = rot_phase + this.rot_speed * store.tick_length
		end

		last_pos.x, last_pos.y = this.pos.x, this.pos.y

		for i, t in ipairs(this.skulls) do
			local a = (i * 2 * math.pi / #this.skulls + rot_phase) % (2 * math.pi)

			t.rot_dest = U.point_on_ellipse(this.pos, this.rot_radius, a)
			t.rot_flip = source.render.sprites[1].flip_x
		end

		coroutine.yield()
	end
end

local function mod_voodoo_witch_skull_spawn_update(this, store)
	this.modifier.ts = store.tick_ts

	local cg = store.count_groups[this.count_group_type]

	while true do
		local target = store.entities[this.modifier.target_id]

		if not target or store.tick_ts - this.modifier.ts > this.modifier.duration then
			break
		end

		if target.health.dead and (not cg[this.count_group_name] or cg[this.count_group_name] < this.skull_count) then
			local s = E:create_entity("voodoo_witch_skull")

			s.owner_id = this.modifier.source_id
			s.spawner_id = target.id

			simulation:queue_insert_entity(s)

			break
		end

		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

local function voodoo_witch_skull_update(this, store)
	local spawner = store.entities[this.spawner_id]
	local owner = store.entities[this.owner_id]

	if not owner or not spawner then
		log.debug("no owner or spawner. removing skull")
		simulation:queue_remove_entity(this)

		return
	end

	table.insert(owner.skulls, this)

	this.pos = V.vclone(spawner.pos)

	local hero = store.entities[owner.aura.source_id]
	local skill = hero.hero.skills[this.sacrifice.xp_from_skill]
	local s = this.render.sprites[1]

	s.offset.x = spawner.unit.mod_offset.x
	s.offset.y = spawner.unit.mod_offset.y

	local fm = this.force_motion
	local fl_dh = this.max_flight_height - this.min_flight_height
	local fl_h = this.min_flight_height + fl_dh * 0.5
	local fl_step = this.flight_speed * store.tick_length
	local fl_dest = fl_h
	local ps = E:create_entity("ps_voodoo_witch_skull")

	ps.particle_system.track_id = this.id
	ps.particle_system.emit = false
	ps.particle_system.track_offset = v(s.offset.x, s.offset.y)

	simulation:queue_insert_entity(ps)

	local function move_step(dest, bob)
		local dx, dy = V.sub(dest.x, dest.y, this.pos.x, this.pos.y)
		local dist = V.len(dx, dy)
		local df = (not fm.ramp_radius or dist > fm.ramp_radius) and 1 or math.max(dist / fm.ramp_radius, 0.1)

		fm.a.x, fm.a.y = V.add(fm.a.x, fm.a.y, V.trim(fm.max_a, V.mul(fm.a_step * df, dx, dy)))
		fm.v.x, fm.v.y = V.add(fm.v.x, fm.v.y, V.mul(store.tick_length, fm.a.x, fm.a.y))
		fm.v.x, fm.v.y = V.trim(fm.max_v, fm.v.x, fm.v.y)

		local sx, sy = V.mul(store.tick_length, fm.v.x, fm.v.y)

		this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, sx, sy)
		fm.a.x, fm.a.y = V.mul(-0.05 / store.tick_length, fm.v.x, fm.v.y)

		if bob then
			fl_dest = fl_h + 0.5 * fl_dh * math.sin(2 * math.pi * store.tick_ts / this.flight_period)
		end

		if math.abs(fl_dest - s.offset.y) < fl_step then
			s.offset.y = fl_dest
		else
			s.offset.y = s.offset.y + (fl_dest > s.offset.y and 1 or -1) * fl_step
		end

		ps.particle_system.track_offset.x = s.offset.x
		ps.particle_system.track_offset.y = s.offset.y

		return dist < fm.max_v * store.tick_length
	end

	while true do
		if hero.health.dead then
			break
		end

		if this.max_shots <= 0 then
			local sa = this.sacrifice

			if sa.disabled then
				break
			end

			local target = U.find_nearest_enemy(store, this.pos, sa.min_range, sa.max_range, sa.vis_flags, sa.vis_bans)

			if not target then
			-- block empty
			else
				S:queue(sa.sound)

				fm.max_v = sa.max_v
				fm.max_a = sa.max_a
				fm.ramp_radius = nil
				fm.a_step = sa.a_step
				fl_dest = target.unit.hit_offset.y
				ps.particle_system.emit = true

				while not move_step(target.pos, false) do
					s.flip_x = this.pos.x > target.pos.x

					coroutine.yield()
				end

				S:queue(sa.sound_hit)

				local d = E.assign_damage(sa.damage_type, sa.damage, this.id, target.id)

				queue_damage(store, d)

				if hero and skill then
					SU.hero_gain_xp_from_skill(hero, skill)
				end

				break
			end
		end

		local a = this.ranged.attacks[1]

		if store.tick_ts - a.ts > a.cooldown then
			local target = U.find_nearest_enemy(store, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

			if not target then
			-- block empty
			else
				a.ts = store.tick_ts

				local an, af = U.animation_name_facing_point(this, a.animation, target.pos)

				U.animation_start_default(this, an, af, store.tick_ts, false)
				S:queue(a.sound)

				while store.tick_ts - a.ts < a.shoot_time do
					move_step(this.rot_dest, true)
					coroutine.yield()
				end

				local b = E:create_entity(a.bullet)

				b.pos.x, b.pos.y = this.pos.x, this.pos.y + this.render.sprites[1].offset.y

				b.bullet.from:copy(b.pos)
				b.bullet.to:copy(target.pos)

				b.bullet.to.x = b.bullet.to.x + target.unit.hit_offset.x
				b.bullet.to.y = b.bullet.to.y + target.unit.hit_offset.y
				b.bullet.target_id = target.id
				b.bullet.source_id = this.id
				b.render.sprites[1].scale.x = 0.75
				b.render.sprites[1].scale.y = 0.75
				b.bullet.xp_dest_id = hero.id

				simulation:queue_insert_entity(b)

				this.max_shots = this.max_shots - 1

				while not U.animation_finished_default(this) do
					move_step(this.rot_dest, true)
					coroutine.yield()
				end
			end
		end

		U.animation_start_default(this, "idle", this.rot_flip, store.tick_ts, true)
		move_step(this.rot_dest, true)
		coroutine.yield()
	end

	table.removeobject(owner.skulls, this)

	s.hidden = true

	local fx = E:create_entity("fx_voodoo_witch_skull_explosion")

	fx.pos.x, fx.pos.y = this.pos.x, this.pos.y + this.render.sprites[1].offset.y
	fx.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(fx)

	if ps.particle_system.emit then
		ps.particle_system.emit = false

		U.y_wait_unconditional(store, ps.particle_system.particle_lifetime[2])
	end

	simulation:queue_remove_entity(this)
end

local function voodoo_witch_death_aura_update(this, store)
	local a = this.aura

	a.ts = store.tick_ts

	local last_ts = store.tick_ts
	local source = store.entities[a.source_id]
	local inflicted_damage = 0

	this.pos = source.pos

	while true do
		if not source.health.dead and store.tick_ts - last_ts >= a.cycle_time then
			last_ts = store.tick_ts

			local targets = U.find_enemies_in_range_filter_off(this.pos, a.radius, a.vis_flags, a.vis_bans)

			if targets then
				for _, target in ipairs(targets) do
					local d = E.assign_damage(a.damage_type, a.damage, this.id, target.id)

					queue_damage(store, d)

					inflicted_damage = inflicted_damage + a.damage

					local m = E:create_entity(this.mod_slow)

					m.modifier.source_id = this.id
					m.modifier.target_id = target.id
					m.render.sprites[1].name = m.render.sprites[1].size_names[target.unit.size]
					m.render.sprites[1].flip_x = target.render.sprites[1].flip_x
					m.tween.ts = store.tick_ts

					simulation:queue_insert_entity(m)
				end
			end
		end

		if inflicted_damage * a.xp_gain_factor > 1 then
			SU.hero_gain_xp(source, inflicted_damage * a.xp_gain_factor, this.template_name)

			inflicted_damage = 0
		end

		this.render.sprites[1].hidden = source.health.dead
		this.render.sprites[2].hidden = source.health.dead

		coroutine.yield()
	end
end

local function mod_voodoo_witch_magic_insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead then
		return false
	end

	this.render.sprites[1].ts = store.tick_ts
	this.render.sprites[1].flip_x = not target.render.sprites[1].flip_x

	return true
end

local tt

tt = RT("hero_voodoo_witch", "hero")

AC(tt, "melee", "ranged", "timed_attacks")

tt.hero.level_stats.hp_max = {175, 200, 225, 250, 275, 300, 325, 350, 375, 400}
tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.damage_min = {4, 5, 7, 8, 10, 11, 13, 14, 16, 17}
tt.hero.level_stats.damage_max = {11, 16, 20, 25, 29, 34, 38, 43, 47, 52}
tt.hero.level_stats.ranged_damage_min = {4, 5, 7, 8, 10, 11, 13, 14, 16, 17}
tt.hero.level_stats.ranged_damage_max = {11, 16, 20, 25, 29, 34, 38, 43, 47, 52}
tt.hero.skills.laughingskulls = CC("hero_skill")
tt.hero.skills.laughingskulls.extra_damage = {2, 4, 6, 8}
tt.hero.skills.laughingskulls.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.deathskull = CC("hero_skill")
tt.hero.skills.deathskull.damage = {25, 50, 75}
tt.hero.skills.deathskull.xp_gain_factor = 24
tt.hero.skills.deathskull.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.bonedance = CC("hero_skill")
tt.hero.skills.bonedance.skull_count = {4, 5, 6, 7}
tt.hero.skills.bonedance.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.deathaura = CC("hero_skill")
tt.hero.skills.deathaura.slow_factor = {0.9, 0.8, 0.7, 0.6}
tt.hero.skills.deathaura.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.voodoomagic = CC("hero_skill")
tt.hero.skills.voodoomagic.damage = {60, 120, 180}
tt.hero.skills.voodoomagic.count = {5, 7, 9}
tt.hero.skills.voodoomagic.xp_gain_factor = 168
tt.hero.skills.voodoomagic.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.health.armor = nil
tt.health.dead_lifetime = 15
tt.health.hp_max = nil
tt.health_bar.offset = vec_2(0, 39)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_level_up
tt.hero.tombstone_show_time = fts(90)
tt.idle_flip.cooldown = 2
tt.info.hero_portrait = "kr2_hero_portraits_0005"
tt.info.portrait = "kr2_info_portraits_heroes_0005"
tt.main_script.insert = hero_insert
tt.main_script.update = hero_update
tt.motion.max_speed = 90
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.21212121212121213
tt.render.sprites[1].prefix = "hero_voodoo_witch"
tt.soldier.melee_slot_offset.x = 5
tt.sound_events.change_rally_point = "HeroVoodooWitchTaunt"
tt.sound_events.death = "HeroVoodooWitchDeath"
tt.sound_events.respawn = "HeroVoodooWitchTauntIntro"
tt.sound_events.insert = "HeroVoodooWitchTauntIntro"
tt.sound_events.hero_room_select = "HeroVoodooWitchTauntSelect"
tt.unit.hit_offset = vec_2(0, 13)
tt.unit.mod_offset = vec_2(0, 13)
tt.melee.attacks[1].hit_time = fts(13)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 2.7
tt.melee.attacks[1].cooldown = 1.45
tt.melee.range = 51.2
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].cooldown = 1.45
tt.ranged.attacks[1].min_range = 25
tt.ranged.attacks[1].max_range = 140
tt.ranged.attacks[1].bullet = "bolt_voodoo_witch"
tt.ranged.attacks[1].shoot_time = fts(13)
tt.ranged.attacks[1].bullet_start_offset = {vec_2(-8, 24)}
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].animation = "magic"
tt.timed_attacks.list[1].mod_fx = "mod_voodoo_witch_magic"
tt.timed_attacks.list[1].mod_slow = "mod_voodoo_witch_magic_slow"
tt.timed_attacks.list[1].cooldown = 18
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].max_range = 100
tt.timed_attacks.list[1].min_count = 3
tt.timed_attacks.list[1].count = 5
tt.timed_attacks.list[1].sound = "HeroVoodooWitchVoodooMagic"
tt.timed_attacks.list[1].damage_type = DAMAGE_TRUE
tt.timed_attacks.list[1].vis_flags = F_RANGED
tt.timed_attacks.list[1].vis_bans = bor(F_BOSS)
tt = RT("voodoo_witch_skull_aura", "aura")
tt.aura.cycle_time = 0.267
tt.aura.duration = -1
tt.aura.radius = 150
tt.aura.vis_flags = F_SKELETON
tt.main_script.update = voodoo_witch_skull_aura_update
tt.skull_count = 2
tt.skulls = {}
tt.rot_speed = 2 * math.pi / 8
tt.rot_radius = 40
tt = RT("mod_voodoo_witch_skull_spawn", "modifier")
tt.modifier.duration = fts(10)
tt.main_script.update = mod_voodoo_witch_skull_spawn_update
tt.count_group_type = COUNT_GROUP_CONCURRENT
tt.count_group_name = "voodoo_witch_skulls"
tt.skull_count = 2
tt = RT("voodoo_witch_skull", "decal_scripted")

AC(tt, "ranged", "count_group", "force_motion")

tt.count_group.name = "voodoo_witch_skulls"
tt.flight_period = 3
tt.flight_speed = 40
tt.force_motion.max_a = 525
tt.force_motion.max_v = 135
tt.force_motion.ramp_radius = 50
tt.main_script.update = voodoo_witch_skull_update
tt.max_flight_height = 25
tt.max_shots = 10
tt.min_flight_height = 15
tt.ranged.attacks[1].bullet = "bolt_voodoo_witch_skull"
tt.ranged.attacks[1].cooldown = 1.1
tt.ranged.attacks[1].max_range = 120
tt.ranged.attacks[1].shoot_time = fts(6)
tt.render.sprites[1].anchor.y = 0.4
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "voodoo_witch_skull"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.sacrifice = {}
tt.sacrifice.damage_type = DAMAGE_PHYSICAL
tt.sacrifice.damage_radius = 25
tt.sacrifice.disabled = true
tt.sacrifice.min_range = 0
tt.sacrifice.max_range = 150
tt.sacrifice.max_v = 4 * tt.force_motion.max_v
tt.sacrifice.max_a = 2 * tt.force_motion.max_a
tt.sacrifice.a_step = 20
tt.sacrifice.vis_flags = F_RANGED
tt.sacrifice.vis_bans = 0
tt.sacrifice.xp_from_skill = "deathskull"
tt.sacrifice.sound = "HeroVoodooWitchSacrificeStart"
tt.sacrifice.sound_hit = "HeroVoodooWitchSacrificeHit"
tt.rot_dest = vec_2(0, 0)
tt = RT("fx_voodoo_witch_skull_explosion", "fx")
tt.render.sprites[1].name = "fx_voodoo_witch_skull_explosion"
tt = RT("ps_voodoo_witch_skull")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "voodoo_skull_particle"
tt.particle_system.loop = false
tt.particle_system.animated = true
tt.particle_system.particle_lifetime = {fts(10), fts(12)}
tt.particle_system.alphas = {255, 0}
tt.particle_system.scales_y = {0.85, 0.15}
tt.particle_system.emit_rotation_spread = math.pi
tt.particle_system.emission_rate = 60
tt = RT("voodoo_witch_death_aura", "aura")

AC(tt, "render")

tt.aura.cycle_time = 1
tt.aura.duration = -1
tt.aura.radius = 120
tt.aura.vis_bans = bor(F_FRIEND)
tt.aura.vis_flags = F_MOD
tt.aura.damage_type = DAMAGE_TRUE
tt.aura.damage = 1
tt.aura.xp_gain_factor = 0.09
tt.mod_slow = "mod_voodoo_witch_aura_slow"
tt.main_script.update = voodoo_witch_death_aura_update
tt.render.sprites[1].name = "decal_voodoo_witch_death_aura"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "voodoo_buff_top"
tt.render.sprites[2].anchor.y = 0.22727272727272727
tt = RT("mod_voodoo_witch_aura_slow", "mod_slow")

AC(tt, "render", "tween")

tt.slow.factor = nil
tt.modifier.duration = 1.1
tt.modifier.use_mod_offset = false
tt.render.sprites[1].size_names = {"voodoo_aura_small", "voodoo_aura_small", "voodoo_aura_big"}
tt.render.sprites[1].name = "voodoo_aura_small"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].animated = false
tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}
tt.tween.remove = false
tt = RT("bolt_voodoo_witch", "bolt")
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.max_speed = 450
tt.bullet.min_speed = 150
tt.bullet.particles_name = "ps_bolt_voodoo_witch"
tt.bullet.xp_gain_factor = 2.7
tt.render.sprites[1].prefix = "bolt_voodoo_witch"
tt.sound_events.insert = "HeroVoodooWitchAttack"
tt = RT("bolt_voodoo_witch_skull", "bolt_voodoo_witch")
tt.bullet.damage_max = 5
tt.bullet.damage_min = 5
tt.bullet.particles_name = "ps_bolt_voodoo_witch_skull"
tt.bullet.xp_gain_factor = 1.8
tt.render.sprites[1].scale = vec_2(0.75, 0.75)
tt.sound_events.insert = "HeroVoodooWitchSkullAttack"
tt = RT("ps_bolt_voodoo_witch")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "voodoo_proy_particle"
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.alphas = {255, 0}
tt.particle_system.scales_y = {0.75, 0.15}
tt.particle_system.emission_rate = 60
tt = RT("ps_bolt_voodoo_witch_skull", "ps_bolt_voodoo_witch")
tt.particle_system.scales_y = {0.5, 0.1}
tt.particle_system.particle_lifetime = {fts(6), fts(6)}
tt = RT("mod_voodoo_witch_magic", "modifier")

AC(tt, "render")

tt.modifier.duration = fts(61)
tt.main_script.insert = mod_voodoo_witch_magic_insert
tt.main_script.update = scripts.mod_track_target.update
tt.render.sprites[1].name = "mod_voodoo_witch_magic"
tt.render.sprites[1].loop = false
tt = RT("mod_voodoo_witch_magic_slow", "mod_slow")
tt.slow.factor = 0.3
tt.modifier.duration = 0.4
