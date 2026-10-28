local bit = require("bit")
local E = require("entity_db")
local GS = require("kr1.game_settings")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")
local km = require("lib.klua.macros")
local scripts = require("scripts")
local log = require("lib.klua.log"):new("hero_wizard")

require("all.constants")

local bor = bit.bor
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local queue_damage = U.queue_damage

local function ray_wizard_chain_insert(this, store)
	if not store.entities[this.bullet.target_id] then
		return false
	end

	return true
end

local function ray_wizard_chain_update(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local dest = b.to
	local ho = V.v(0, 0)

	s.scale = V.v(1, 1)

	local function update_sprite()
		if target and target.motion then
			if target.unit and target.unit.hit_offset and not b.ignore_hit_offset then
				ho.x, ho.y = target.unit.hit_offset.x, target.unit.hit_offset.y
			else
				ho.x, ho.y = 0, 0
			end

			local d = math.max(math.abs(target.pos.x + ho.x - dest.x), math.abs(target.pos.y + ho.y - dest.y))

			if d > b.max_track_distance then
				log.paranoid("(%s) ray_wizard_chain target (%s) out of max_track_distance", this.id, target.id)

				target = nil
			else
				dest.x, dest.y = target.pos.x + ho.x, target.pos.y + ho.y
			end
		end

		local angle = V.angleTo(dest.x - this.pos.x, dest.y - this.pos.y)

		s.r = angle
		s.scale.x = V.dist(dest.x, dest.y, this.pos.x, this.pos.y) / this.image_width
	end

	s.ts = store.tick_ts

	update_sprite()

	local fx = SU.insert_sprite(store, b.hit_fx, dest)

	if target then
		fx.pos = target.pos

		if target.unit and target.unit.hit_offset then
			fx.render.sprites[1].offset = V.vclone(target.unit.hit_offset)
		end
	end

	if target then
		if not b.mods then
			b.mods = {b.mod}
		end

		for _, modname in ipairs(b.mods) do
			local mod = E:create_entity(modname)

			mod.modifier.source_id = b.source_id
			mod.modifier.target_id = target.id
			mod.xp_gain_factor = b.xp_gain_factor
			mod.xp_dest_id = b.source_id
			mod.modifier.damage_factor = b.damage_factor

			simulation:queue_insert_entity(mod)
		end

		table.insert(this.seen_targets, target.id)

		if this.bounces > 0 then
			local bounce_target = U.find_nearest_enemy(store, target.pos, 0, this.bounce_range, this.bounce_vis_flags, this.bounce_vis_bans, function(v)
				return not table.contains(this.seen_targets, v.id)
			end)

			if bounce_target then
				log.paranoid("bounce from %s to %s dist:%s", target.id, bounce_target.id, V.dist(dest.x, dest.y, bounce_target.pos.x, bounce_target.pos.y))

				local r = E:create_entity(this.template_name)

				r.pos:copy(dest)
				r.bullet.to:copy(bounce_target.pos)

				if not b.ignore_hit_offset and bounce_target.unit and bounce_target.unit.hit_offset then
					r.bullet.to.x = r.bullet.to.x + bounce_target.unit.hit_offset.x
					r.bullet.to.y = r.bullet.to.y + bounce_target.unit.hit_offset.y
				end

				r.bullet.damage_factor = b.damage_factor
				r.bullet.target_id = bounce_target.id
				r.bullet.source_id = b.source_id
				r.bounces = this.bounces - 1
				r.seen_targets = this.seen_targets

				simulation:queue_insert_entity(r)
			end
		end
	end

	while not U.animation_finished_default(this) do
		update_sprite()
		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

local function mod_ray_wizard_insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or not target.health or target.health.dead then
		return false
	end

	this.modifier.ts = store.tick_ts

	return true
end

local function mod_ray_wizard_update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	local total_damage = math.random(this.damage_min, this.damage_max) * m.damage_factor
	local final_damage = km.clamp(0, total_damage, total_damage - target.health.hp)
	local steps = math.floor(m.duration / this.damage_every)
	local step_damage = (total_damage - final_damage) / steps
	local step = 0
	local last_ts = m.ts
	local tick_steps, cycle_damage, d

	if not target then
		simulation:queue_remove_entity(this)

		return
	end

	this.pos = target.pos

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead then
			simulation:queue_remove_entity(this)

			return
		end

		tick_steps = math.floor((store.tick_ts - last_ts) / this.damage_every)

		if tick_steps < 1 then
		-- block empty
		else
			step = step + tick_steps
			last_ts = last_ts + tick_steps * this.damage_every
			cycle_damage = step_damage * tick_steps

			if steps <= step then
				cycle_damage = cycle_damage + final_damage
			end

			d = E.assign_damage(this.damage_type, cycle_damage, this.id, target.id)
			d.pop = this.pop
			d.pop_chance = this.pop_chance
			d.pop_conds = this.pop_conds
			d.xp_gain_factor = this.xp_gain_factor
			d.xp_dest_id = this.xp_dest_id

			queue_damage(store, d)

			if steps <= step then
				simulation:queue_remove_entity(this)

				return
			end
		end

		coroutine.yield()
	end
end

local function missile_wizard_insert(this, store)
	local b = this.bullet

	if not store.entities[b.target_id] then
		return false
	end

	b.to = V.v(this.pos.x + math.random(10, 90) * (math.random() < 0.5 and -1 or 1), this.pos.y + math.random(100, 300))

	local ps = E:create_entity("ps_missile_wizard")

	ps.particle_system.track_id = this.id

	simulation:queue_insert_entity(ps)

	for i = 1, 3 do
		local pss = E:create_entity("ps_missile_wizard_sparks")

		pss.particle_system.name = "missile_wizard_sparks" .. i
		pss.particle_system.track_id = this.id
		pss.particle_system.ts_offset = i / (3 * pss.particle_system.emission_rate)

		simulation:queue_insert_entity(pss)
	end

	return true
end

local function hero_get_info(this)
	local m = E:get_template("mod_ray_wizard")
	local ranged_min, ranged_max = (m.damage_min + this.unit.damage_buff) * this.unit.damage_factor, (m.damage_max + this.unit.damage_buff) * this.unit.damage_factor
	local melee_min = (this.melee.attacks[1].damage_min + this.unit.damage_buff) * this.unit.damage_factor
	local melee_max = (this.melee.attacks[1].damage_max + this.unit.damage_buff) * this.unit.damage_factor
	local ranged_damage_type = DAMAGE_MAGICAL
	local melee_damage_type = this.melee.attacks[1].damage_type

	return {
		type = STATS_TYPE_SOLDIER,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = melee_min,
		damage_max = melee_max,
		damage_type = melee_damage_type,
		ranged_damage_min = ranged_min,
		ranged_damage_max = ranged_max,
		ranged_damage_type = ranged_damage_type,
		armor = this.health.armor,
		respawn = this.health.dead_lifetime
	}
end

local function hero_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	upgrade_skill(this, "magicmissile", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.loops = s.count[s.level]

		local b = E:get_template("missile_wizard")

		b.bullet.damage_max = s.damage[s.level]
		b.bullet.damage_min = s.damage[s.level]
	end)
	upgrade_skill(this, "chainspell", function(this, s)
		local a = this.ranged.attacks[2]

		a.disabled = nil

		local b = E:get_template("ray_wizard_chain")

		b.bounces = s.bounces[s.level]
	end)
	upgrade_skill(this, "disintegrate", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.total_damage = s.total_damage[s.level]
		a.count = s.count[s.level]
	end)
	upgrade_skill(this, "arcanereach", function(this, s)
		local factor = 1 + s.extra_range_factor[s.level]

		this.ranged.attacks[1].max_range = this.ranged.attacks[1].max_range * factor
		this.ranged.attacks[2].max_range = this.ranged.attacks[2].max_range * factor
	end)
	upgrade_skill(this, "arcanefocus", function(this, s)
		this.arcanefocus_extra = s.extra_damage[s.level]
	end)
	upgrade_skill(this, "arcanetorrent", function(this, s)
		this.arcanetorrent_factor_base = s.factor[s.level]
	end)

	local m = E:get_template("mod_ray_wizard")

	m.damage_max = ls.ranged_damage_max[hl] + this.arcanefocus_extra
	m.damage_min = ls.ranged_damage_min[hl] + this.arcanefocus_extra

	update_hp(this)
end

local function hero_update(this, store)
	local h = this.health
	local a, skill, brk
	local unit = this.unit
	local a_disintegrate = this.timed_attacks.list[1]
	local a_missile = this.timed_attacks.list[2]
	local skill_disintegrate = this.hero.skills.disintegrate
	local skill_missile = this.hero.skills.magicmissile

	U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	local arcane_torrent_ts = store.tick_ts

	local function filter_fn(v)
		return v.health.hp <= a_disintegrate.total_damage * unit.damage_factor
	end

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_326_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = a_disintegrate
			skill = skill_disintegrate

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local targets = U.find_enemies_in_range_filter_on(this.pos, a.max_range, a.vis_flags, a.vis_bans, filter_fn)

				if not targets then
					a.ts = a.ts + fts(10)
				else
					local remaining_damage = a.total_damage * unit.damage_factor

					a.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, skill)
					S:queue(a.sound)
					U.animation_start_default(this, a.animation, nil, store.tick_ts)
					U.y_wait_unconditional(store, a.hit_time)

					local count = a.count

					for _, t in ipairs(targets) do
						if remaining_damage <= 0 or count == 0 then
							break
						end

						if remaining_damage >= t.health.hp then
							remaining_damage = remaining_damage - t.health.hp
							count = count - 1

							local d = E.assign_damage(DAMAGE_EAT, 0, this.id, t.id)

							queue_damage(store, d)

							local fx = E:create_entity("fx_wizard_disintegrate")

							fx.pos.x, fx.pos.y = t.pos.x + t.unit.hit_offset.x, t.pos.y + t.unit.hit_offset.y
							fx.render.sprites[1].ts = store.tick_ts

							simulation:queue_insert_entity(fx)
						end
					end

					U.y_animation_wait_default(this)

					goto label_326_0
				end
			end

			a = a_missile
			skill = skill_missile

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local target = U.detect_foremost_enemy_in_range_filter_off(this.pos, a.max_range, a.vis_flags, a.vis_bans)

				if target then
					local start_ts = store.tick_ts

					this.health.immune_to = F_ALL

					if SU.y_soldier_do_loopable_ranged_attack(store, this, target, a) then
						a.ts = start_ts

						SU.hero_gain_xp_from_skill(this, skill)
					end

					this.health.immune_to = 0

					goto label_326_0
				end
			end

			if store.tick_ts - arcane_torrent_ts > 1 then
				arcane_torrent_ts = store.tick_ts

				local count = 0

				for _, t in pairs(store.towers) do
					if table.contains(GS.mage_towers, t.template_name) then
						count = count + 1
					end
				end

				local tmp = 1 + this.arcanetorrent_factor_base * count

				SU.insert_unit_damage_factor_buff(this, (tmp - 1) - this.arcanetorrent_factor)

				this.arcanetorrent_factor = tmp - 1
			end

			brk = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or U.is_blocked_valid(store, this) then
			-- block empty
			else
				brk = SU.y_soldier_ranged_attacks(store, this)

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

		::label_326_0::

		coroutine.yield()
	end
end

local tt

tt = RT("hero_wizard", "hero")

AC(tt, "teleport", "melee", "ranged", "timed_attacks")

tt.hero.level_stats.hp_max = {130, 145, 160, 175, 190, 205, 220, 235, 250, 265}
tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.melee_damage_min = {4, 5, 5, 6, 6, 7, 7, 8, 8, 9}
tt.hero.level_stats.melee_damage_max = {12, 14, 15, 17, 18, 20, 21, 23, 25, 27}
tt.hero.level_stats.ranged_damage_min = {14, 15, 17, 18, 20, 21, 23, 25, 27, 29}
tt.hero.level_stats.ranged_damage_max = {41, 45, 50, 54, 59, 63, 68, 72, 77, 81}
tt.hero.skills.magicmissile = CC("hero_skill")
tt.hero.skills.magicmissile.count = {5, 9, 13}
tt.hero.skills.magicmissile.damage = {20, 25, 30}
tt.hero.skills.magicmissile.xp_gain = {20, 35, 50}
tt.hero.skills.magicmissile.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.chainspell = CC("hero_skill")
tt.hero.skills.chainspell.bounces = {1, 2, 3}
tt.hero.skills.chainspell.xp_gain = {20, 35, 50}
tt.hero.skills.chainspell.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.disintegrate = CC("hero_skill")
tt.hero.skills.disintegrate.total_damage = {300, 600, 900}
tt.hero.skills.disintegrate.count = {4, 6, 8}
tt.hero.skills.disintegrate.xp_gain = {20, 35, 50}
tt.hero.skills.disintegrate.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[10] = 3
}
tt.hero.skills.arcanereach = CC("hero_skill")
tt.hero.skills.arcanereach.extra_range_factor = {0.25, 0.23, 0.2}
tt.hero.skills.arcanereach.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.arcanefocus = CC("hero_skill")
tt.hero.skills.arcanefocus.extra_damage = {15, 30, 45}
tt.hero.skills.arcanefocus.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.arcanetorrent = CC("hero_skill")
tt.hero.skills.arcanetorrent.factor = {0.04, 0.05, 0.06, 0.07}
tt.hero.skills.arcanetorrent.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.health.armor = nil
tt.health.dead_lifetime = 15
tt.health.hp_max = nil
tt.health_bar.offset = vec_2(0, 36)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_level_up
tt.hero.tombstone_show_time = fts(60)
tt.idle_flip.cooldown = 1
tt.info.fn = hero_get_info
tt.info.hero_portrait = "kr2_hero_portraits_0006"
tt.info.portrait = "kr2_info_portraits_heroes_0006"
tt.main_script.update = hero_update
tt.motion.max_speed = 45
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.22
tt.render.sprites[1].prefix = "hero_wizard"
tt.soldier.melee_slot_offset.x = 5
tt.sound_events.change_rally_point = "HeroWizardTaunt"
tt.sound_events.death = "HeroWizardDeath"
tt.sound_events.respawn = "HeroWizardTauntIntro"
tt.sound_events.insert = "HeroWizardTauntIntro"
tt.sound_events.hero_room_select = "HeroWizardTauntSelect"
tt.teleport.min_distance = 45
tt.teleport.sound = "HeroWizardTeleport"
tt.unit.marker_offset = vec_2(0, -0.16)
tt.unit.mod_offset = vec_2(0, 12.84)
tt.melee.range = 45
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 2.5
tt.timed_attacks.list[1] = CC("area_attack")
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].animation = "disintegrate"
tt.timed_attacks.list[1].hit_time = fts(15)
tt.timed_attacks.list[1].max_range = 150
tt.timed_attacks.list[1].damage_radius = 120
tt.timed_attacks.list[1].cooldown = 25
tt.timed_attacks.list[1].vis_bans = bor(F_CLIFF, F_BOSS)
tt.timed_attacks.list[1].sound = "HeroWizardDesintegrate"
tt.timed_attacks.list[2] = CC("bullet_attack")
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].bullet = "missile_wizard"
tt.timed_attacks.list[2].bullet_start_offset = {vec_2(-16, 36)}
tt.timed_attacks.list[2].shoot_times = {fts(3)}
tt.timed_attacks.list[2].animations = {"missile_start", "missile_loop", "missile_end"}
tt.timed_attacks.list[2].cooldown = 12
tt.timed_attacks.list[2].max_range = 250
tt.timed_attacks.list[2].sound = "HeroWizardMissileSummon"
tt.timed_attacks.list[2].xp_from_skill = "magicmissile"
tt.ranged.forced_cooldown = 1.5
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].bullet = "ray_wizard"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(17, 35)}
tt.ranged.attacks[1].check_target_before_shot = true
tt.ranged.attacks[1].cooldown = 1.5
tt.ranged.attacks[1].max_range = 130
tt.ranged.attacks[1].min_range = 25
tt.ranged.attacks[1].node_prediction = fts(19)
tt.ranged.attacks[1].shoot_time = fts(19)
tt.ranged.attacks[2] = table.deepclone(tt.ranged.attacks[1])
tt.ranged.attacks[2].disabled = true
tt.ranged.attacks[2].cooldown = 3
tt.ranged.attacks[2].bullet = "ray_wizard_chain"
tt.ranged.attacks[2].xp_from_skill = "chainspell"
tt.arcanefocus_extra = 0
tt.arcanetorrent_factor = 0
tt.arcanetorrent_factor_base = 0.04
tt = RT("fx_wizard_disintegrate", "fx")
tt.render.sprites[1].name = "fx_wizard_disintegrate"
tt.render.sprites[1].z = Z_OBJECTS
tt = RT("ray_wizard", "bullet")
tt.bullet.xp_gain_factor = 2.5
tt.bullet.mod = "mod_ray_wizard"
tt.bullet.hit_time = fts(1)
tt.bullet.hit_fx = "fx_ray_wizard"
tt.image_width = 114
tt.render.sprites[1].anchor = vec_2(0, 0.5)
tt.render.sprites[1].name = "ray_wizard"
tt.render.sprites[1].loop = false
tt.sound_events.insert = "HeroWizardShoot"
tt.bounces = 0
tt.seen_targets = {}
tt.main_script.insert = ray_wizard_chain_insert
tt.main_script.update = ray_wizard_chain_update
tt = RT("ray_wizard_chain", "ray_wizard")
tt.bounces = nil
tt.bounce_range = 75
tt.bounce_vis_flags = F_RANGED
tt.bounce_vis_bans = 0
tt.bullet.xp_gain_factor = nil
tt = RT("mod_ray_wizard", "modifier")
tt.modifier.duration = fts(18)
tt.damage_type = DAMAGE_MAGICAL
tt.damage_every = 0.03
tt.pop = {"pop_bzzt"}
tt.pop_chance = 1
tt.pop_conds = DR_KILL
tt.main_script.insert = mod_ray_wizard_insert
tt.main_script.update = mod_ray_wizard_update
tt = RT("fx_ray_wizard", "fx")
tt.render.sprites[1].name = "ray_wizard_ball"
tt.render.sprites[1].z = Z_BULLETS + 1
tt = RT("missile_wizard", "bullet")
tt.render.sprites[1].prefix = "missile_wizard"
tt.bullet.retarget_range = math.huge
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.min_speed = 270
tt.bullet.max_speed = 330
tt.bullet.turn_speed = 20 * math.pi / 180 * 30
tt.bullet.acceleration_factor = 0.1
tt.bullet.hit_fx = "fx_missile_wizard_hit"
tt.bullet.hit_fx_air = "fx_missile_wizard_hit"
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.main_script.update = scripts.missile.update
tt.main_script.insert = missile_wizard_insert
tt.sound_events.hit = "HeroWizardMissileHit"
tt = RT("fx_missile_wizard_hit", "fx")
tt.render.sprites[1].name = "missile_wizard_hit"
tt.render.sprites[1].z = Z_BULLETS
tt = RT("ps_missile_wizard")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "missile_wizard_trail"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.track_rotation = true
tt.particle_system.particle_lifetime = {0.3, 0.3}
tt.particle_system.emission_rate = 50
tt = RT("ps_missile_wizard_sparks")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "missile_wizard_sparks1"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.track_rotation = true
tt.particle_system.particle_lifetime = {0.35, 0.35}
tt.particle_system.emission_rate = 20
