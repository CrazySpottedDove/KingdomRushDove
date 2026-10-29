local scripts = require("scripts")
local E = require("entity_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local bit = require("bit")
local HU = require("hero_utils")
local anchor_y = 0
local bor = bit.bor
local find_target_at_critical_moment = HU.find_target_at_critical_moment
local fts = U.fts
local level_up_basic = HU.level_up_basic
local queue_damage = U.queue_damage
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local tt

local function mod_elves_denas_sybarite_insert(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or not target.health or target.health.dead then
		return false
	end

	SU.insert_unit_damage_factor_by_factor(target, this.inflicted_damage_factor)
	U.heal(target, this.heal_hp)

	this.render.sprites[1].ts = store.tick_ts

	return true
end

local function mod_elves_denas_sybarite_remove(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if target then
		SU.remove_unit_damage_factor_by_factor(target, this.inflicted_damage_factor)
	end

	return true
end

local function shield_elves_denas_update(this, store)
	local b = this.bullet
	local mspeed = b.max_speed
	local target = store.entities[b.target_id]
	local ps
	local bounce_count = 0
	local visited = {}

	U.animation_start_default(this, nil, nil, store.tick_ts, true)

	b.speed.x, b.speed.y = V.normalize(b.to.x - b.from.x, b.to.y - b.from.y)

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id

		simulation:queue_insert_entity(ps)
	end

	::label_75_0::

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
		target = store.entities[b.target_id]

		if target and target.health and not target.health.dead then
			b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
		end

		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
		this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

		coroutine.yield()
	end

	if target and not target.health.dead then
		table.insert(visited, target.id)

		local d = SU.create_bullet_damage(b, target.id, this.id)

		queue_damage(store, d)

		if b.hit_blood_fx and target.unit.blood_color ~= BLOOD_NONE then
			local sfx = E:create_entity(b.hit_blood_fx)

			sfx.pos.x, sfx.pos.y = b.to.x, b.to.y
			sfx.render.sprites[1].ts = store.tick_ts

			if sfx.use_blood_color and target.unit.blood_color then
				sfx.render.sprites[1].name = target.unit.blood_color
				sfx.render.sprites[1].r = this.render.sprites[1].r
			end

			simulation:queue_insert_entity(sfx)
		end
	end

	if b.hit_fx then
		local sfx = E:create_entity(b.hit_fx)

		sfx.pos.x, sfx.pos.y = b.to.x, b.to.y
		sfx.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(sfx)
	end

	if bounce_count < this.max_rebounds then
		target = U.find_random_enemy(store, this.pos, 0, this.rebound_range, b.vis_flags, b.vis_bans, function(v)
			return not table.contains(visited, v.id)
		end)

		if target then
			S:queue(this.sound_events.bounce)

			bounce_count = bounce_count + 1
			b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
			b.target_id = target.id

			goto label_75_0
		end
	end

	simulation:queue_remove_entity(this)
end

local function hero_elves_denas_ultimate_update(this, store)
	local nearest = P:nearest_nodes(this.pos.x, this.pos.y)

	if #nearest > 1 then
		local pi, _, ni = unpack(nearest[1])
		local pos = P:node_pos(pi, 1, ni)
		local count = this.guards_count[this.level]

		for i = 1, count do
			local p = U.point_on_ellipse(pos, 25, i * 2 * math.pi / count)
			local e = E:create_entity(this.guards_template)

			e.pos = p
			e.nav_rally.center = V.vclone(e.pos)
			e.nav_rally.pos = V.vclone(e.pos)
			e.melee.attacks[1].xp_dest_id = this.owner.id
			e.melee.attacks[2].xp_dest_id = this.owner.id

			simulation:queue_insert_entity(e)
		end
	end

	simulation:queue_remove_entity(this)
end

local function hero_elves_denas_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
	this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

	upgrade_skill(this, "sybarite", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil

		local m = E:get_template("mod_elves_denas_sybarite")

		m.heal_hp = s.heal_hp[s.level]
	end)
	upgrade_skill(this, "celebrity", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.max_targets = s.max_targets[s.level]

		local m = E:get_template("mod_elves_denas_celebrity")

		m.modifier.duration = s.stun_duration[s.level]
	end)
	upgrade_skill(this, "mighty", function(this, s)
		local a = this.melee.attacks[3]

		a.disabled = nil
		a.damage_min = s.damage_min[s.level]
		a.damage_max = s.damage_max[s.level]
	end)
	upgrade_skill(this, "shield_strike", function(this, s)
		local a = this.ranged.attacks[1]

		a.disabled = nil

		local b = E:get_template("shield_elves_denas")

		b.max_rebounds = s.rebounds[s.level]
		b.bullet.damage_min = s.damage_min[s.level]
		b.bullet.damage_max = s.damage_max[s.level]
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		this.ultimate.disabled = nil
		this.ultimate.cooldown = s.cooldown[s.level]
	end)
	update_hp(this)
end

local function hero_elves_denas_update(this, store)
	local h = this.health
	local a, skill, brk, sta

	local function shield_strike_filter_fn(e, origin)
		local a = this.ranged.attacks[1]
		local targets = U.find_enemies_in_range_filter_off(e.pos, a.rebound_range, a.vis_flags, a.vis_bans)

		return targets and #targets > 1
	end

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
					goto label_66_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.celebrity

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local target = U.find_random_enemy(store, this.pos, 0, a.range, a.vis_flags, a.vis_bans, function(e)
					return e.unit and not e.unit.is_stunned
				end)

				if not target then
					a.ts = a.ts + 0.13333333333333333
				else
					a.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, skill)
					U.animation_start_default(this, a.animation, nil, store.tick_ts)
					U.y_wait_unconditional(store, fts(22))
					S:queue(a.sound)

					local total_time = fts(52)
					local flash_every = 1

					for i = 1, 9 do
						if SU.hero_interrupted(this) then
							a.ts = a.ts - 0.1 * (9 - i) * a.cooldown

							goto label_66_0
						end

						if i % flash_every == 0 then
							local sfx = E:create_entity("fx_elves_denas_flash")

							sfx.pos.x, sfx.pos.y = this.pos.x + math.random(-25, 25), this.pos.y + math.random(5, 40)
							sfx.render.sprites[1].ts = store.tick_ts
							sfx.render.sprites[1].flip_x = math.random() < 0.5

							simulation:queue_insert_entity(sfx)
						end

						if i <= a.max_targets then
							target = U.find_random_enemy(store, this.pos, 0, a.range, a.vis_flags, a.vis_bans, function(e)
								return e.unit and not e.unit.is_stunned
							end)
							target = target or U.find_random_enemy(store, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

							if target then
								local mod = E:create_entity("mod_elves_denas_celebrity")

								mod.modifier.target_id = target.id

								simulation:queue_insert_entity(mod)
							end
						end

						U.y_wait_unconditional(store, total_time / 9)
					end

					U.y_animation_wait_default(this)
				end
			end

			if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
				local target = find_target_at_critical_moment(this, this.ranged.attacks[1].max_range, F_RANGED, F_NONE)

				if target and target.pos and U.has_valid_rally_node_nearby(target.pos) then
					U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
					S:queue(this.sound_events.change_rally_point)

					local e = E:create_entity(this.hero.skills.ultimate.controller_name)

					e.level = this.hero.skills.ultimate.level
					e.pos = V.vclone(target.pos)
					e.owner = this

					simulation:queue_insert_entity(e)

					this.ultimate.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
				else
					this.ultimate.ts = this.ultimate.ts + 1
				end
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.sybarite

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) and this.health.hp <= this.health.hp_max - a.lost_health then
				U.animation_start_default(this, a.animation, nil, store.tick_ts)

				if SU.y_soldier_wait(store, this, a.hit_time) then
					goto label_66_0
				end

				a.ts = store.tick_ts

				S:queue(a.sound)

				local mod = E:create_entity(a.mod)

				mod.modifier.target_id = this.id
				mod.modifier.source_id = this.id

				simulation:queue_insert_entity(mod)
				U.y_animation_wait_default(this)
				SU.hero_gain_xp_from_skill(this, skill)
			end

			a = this.ranged.attacks[1]
			skill = this.hero.skills.shield_strike

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local target, _, pred_pos = U.find_foremost_enemy_between_range_filter_on(this.pos, a.min_range, a.max_range, a.node_prediction, a.vis_flags, a.vis_bans, shield_strike_filter_fn)

				if target then
					local start_ts = store.tick_ts
					local attack_done = SU.y_soldier_do_ranged_attack(store, this, target, a, pred_pos)

					if attack_done then
						a.ts = start_ts
					else
						goto label_66_0
					end
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
			-- block empty
			elseif SU.soldier_go_back_step(store, this) then
			-- block empty
			else
				a = this.wealthy

				if store.wave_group_number > a.last_wave then
					a.last_wave = store.wave_group_number

					S:queue(a.sound)

					store.player_gold = store.player_gold + a.gold

					U.animation_start_default(this, "coinThrow", nil, store.tick_ts)
					U.y_wait_unconditional(store, a.hit_time)

					local fx = E:create_entity(a.fx)

					fx.render.sprites[1].ts = store.tick_ts
					fx.pos.x, fx.pos.y = this.pos.x + (this.render.sprites[1].flip_x and 1 or -1) * 20, this.pos.y
					fx.tween.props[2] = E:clone_c("tween_prop")
					fx.tween.props[2].name = "offset"
					fx.tween.props[2].keys = {{0, V.v(0, 40)}, {0.5, V.v(0, 50)}}

					simulation:queue_insert_entity(fx)
					U.y_animation_wait_default(this)
				end

				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_66_0::

		coroutine.yield()
	end
end

tt = RT("hero_elves_denas", "hero")

AC(tt, "melee", "ranged", "timed_attacks")

tt.hero.level_stats.armor = {0.38, 0.41, 0.44, 0.47, 0.5, 0.53, 0.56, 0.59, 0.62, 0.65}
tt.hero.level_stats.hp_max = {308, 324, 343, 357, 374, 390, 407, 423, 440, 456}
tt.hero.level_stats.melee_damage_max = {14, 17, 19, 21, 23, 25, 27, 30, 32, 34}
tt.hero.level_stats.melee_damage_min = {10, 11, 12, 14, 15, 17, 18, 20, 21, 23}
tt.hero.skills.celebrity = CC("hero_skill")
tt.hero.skills.celebrity.max_targets = {6, 8, 10}
tt.hero.skills.celebrity.stun_duration = {1, 2, 3}
tt.hero.skills.celebrity.xp_gain = {100, 200, 300}
tt.hero.skills.celebrity.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.mighty = CC("hero_skill")
tt.hero.skills.mighty.damage_max = {134, 226, 320}
tt.hero.skills.mighty.damage_min = {70, 122, 171}
tt.hero.skills.mighty.xp_gain = {70, 140, 210}
tt.hero.skills.mighty.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.shield_strike = CC("hero_skill")
tt.hero.skills.shield_strike.damage_max = {36, 46, 56, 66}
tt.hero.skills.shield_strike.damage_min = {20, 26, 32, 38}
tt.hero.skills.shield_strike.rebounds = {3, 4, 5, 5}
tt.hero.skills.shield_strike.xp_gain = {50, 100, 150, 200}
tt.hero.skills.shield_strike.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.sybarite = CC("hero_skill")
tt.hero.skills.sybarite.heal_hp = {80, 160, 240}
tt.hero.skills.sybarite.xp_gain = {75, 150, 225}
tt.hero.skills.sybarite.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_elves_denas_ultimate"
tt.hero.skills.ultimate.xp_gain_factor = 48
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.ultimate.cooldown = {48, 43.2, 38.88, 34.992}
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, 46)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_elves_denas_level_up
tt.hero.tombstone_show_time = fts(90)
tt.info.hero_portrait = "kr3_hero_portraits_0005"
tt.info.portrait = "kr3_info_portraits_heroes_0005"
tt.main_script.update = hero_elves_denas_update
tt.motion.max_speed = 2.75 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.21111111111111
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_elves_denas"
tt.soldier.melee_slot_offset = vec_2(10, 0)
tt.sound_events.change_rally_point = "ElvesHeroDenasTaunt"
tt.sound_events.death = "ElvesHeroDenasDeath"
tt.sound_events.respawn = "ElvesHeroDenasTauntIntro"
tt.sound_events.insert = "ElvesHeroDenasTauntIntro"
tt.sound_events.hero_room_select = "ElvesHeroDenasTauntSelect"
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.mod_offset = vec_2(0, 13)
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].cooldown = 1.2
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].xp_gain_factor = 4
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].chance = 0.5
tt.melee.attacks[3] = CC("melee_attack")
tt.melee.attacks[3].animation = "specialAttack"
tt.melee.attacks[3].cooldown = 15
tt.melee.attacks[3].disabled = true
tt.melee.attacks[3].damage_type = DAMAGE_TRUE
tt.melee.attacks[3].hit_time = fts(25)
tt.melee.attacks[3].sound = "ElvesHeroDenasMighty"
tt.melee.attacks[3].sound_args = {
	delay = fts(17)
}
tt.melee.attacks[3].xp_from_skill = "mighty"
tt.melee.range = 72.5
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].disabled = true
tt.ranged.attacks[1].bullet = "shield_elves_denas"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(22, 16)}
tt.ranged.attacks[1].cooldown = 12
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].rebound_range = 125
tt.ranged.attacks[1].shoot_time = fts(13)
tt.ranged.attacks[1].animation = "shieldThrow"
tt.ranged.attacks[1].xp_from_skill = "shield_strike"
tt.timed_attacks.list[1] = CC("mod_attack")
tt.timed_attacks.list[1].animation = "showOff"
tt.timed_attacks.list[1].cooldown = 21
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].hit_time = fts(9)
tt.timed_attacks.list[1].mod = "mod_elves_denas_celebrity"
tt.timed_attacks.list[1].range = 100
tt.timed_attacks.list[1].sound = "ElvesHeroDenasCelebrity"
tt.timed_attacks.list[1].vis_bans = bor(F_BOSS)
tt.timed_attacks.list[1].vis_flags = bor(F_MOD, F_RANGED, F_STUN)
tt.timed_attacks.list[1].xp_from_skill = "celebrity"
tt.timed_attacks.list[2] = CC("mod_attack")
tt.timed_attacks.list[2].animation = "eat"
tt.timed_attacks.list[2].cooldown = 16
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].hit_time = fts(37)
tt.timed_attacks.list[2].lost_health = 100
tt.timed_attacks.list[2].mod = "mod_elves_denas_sybarite"
tt.timed_attacks.list[2].sound = "ElvesHeroDenasSybarite"
tt.wealthy = {}
tt.wealthy.animation = "coinThrow"
tt.wealthy.gold = 30
tt.wealthy.sound = "ElvesHeroDenasWealthy"
tt.wealthy.last_wave = 1
tt.wealthy.hit_time = fts(9)
tt.wealthy.fx = "fx_coin_jump"
tt.ultimate = {
	ts = 0,
	cooldown = 48,
	disabled = true
}
tt = RT("hero_elves_denas_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.cooldown = 48
tt.guards_count = {2, 3, 4, 5}
tt.guards_template = "soldier_elves_denas_guard"
tt.main_script.update = hero_elves_denas_ultimate_update
tt.sound_events.insert = "ElvesHeroDenasKingsguardTaunt"
tt = RT("shield_elves_denas", "bullet")
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.particles_name = "ps_shield_elves_denas"
tt.bullet.max_speed = 10 * FPS
tt.bullet.hit_blood_fx = "fx_blood_splat"
tt.bullet.hit_fx = "fx_shield_elves_denas_hit"
tt.main_script.update = shield_elves_denas_update
tt.render.sprites[1].name = "shield_elves_denas_loop"
tt.rebound_range = 125
tt = RT("soldier_elves_denas_guard", "soldier_militia")

AC(tt, "reinforcement", "tween", "nav_grid")
anchor_y = 12 / 80

tt.health.armor = 0.4
tt.health.hp_max = 200
tt.health_bar.offset = vec_2(0, 40)
tt.controable = true
tt.controable_other = true
tt.info.portrait = "kr3_info_portraits_soldiers_0005"
tt.info.random_name_count = 15
tt.info.random_name_format = "ELVES_SOLDIER_IMPERIAL_%i_NAME"
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.soldier_reinforcement.update
tt.melee.attacks[1].damage_max = 12
tt.melee.attacks[1].damage_min = 4
tt.melee.attacks[1].hit_time = fts(13)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].chance = 0.5
tt.melee.attacks[1].xp_gain_factor = 0
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.cooldown = 1
tt.melee.range = 72.5
tt.reinforcement.duration = 25
tt.reinforcement.fade = nil
tt.reinforcement.fade_out = true
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "elves_denas_guard"
tt.render.sprites[1].name = "raise"
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
tt.tween.props[1].name = "alpha"
tt.tween.remove = false
tt.tween.disabled = true
tt.vis.bans = bor(F_SKELETON, F_LYCAN)
tt = RT("mod_elves_denas_celebrity", "mod_stun")
tt.modifier.duration = nil
tt = RT("mod_elves_denas_sybarite", "modifier")

AC(tt, "render")

tt.inflicted_damage_factor = 2.5
tt.main_script.insert = mod_elves_denas_sybarite_insert
tt.main_script.remove = mod_elves_denas_sybarite_remove
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.bans = {"mod_son_of_mactans_poison", "mod_drider_poison", "mod_dark_spitters", "mod_balrog"}
tt.modifier.duration = 8
tt.render.sprites[1].name = "fx_elves_denas_heal"
tt = RT("ps_shield_elves_denas")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "shield_elves_denas_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(12), fts(12)}
tt.particle_system.emission_rate = 60
tt.particle_system.scales_y = {1.5, 0.5}
tt.particle_system.scales_y = {1.5, 0.5}
tt.particle_system.track_rotation = true
tt.particle_system.z = Z_BULLETS
tt = RT("fx_elves_denas_flash", "fx")
tt.render.sprites[1].name = "fx_elves_denas_flash"
tt = RT("fx_shield_elves_denas_hit", "fx")
tt.render.sprites[1].name = "fx_shield_elves_denas_hit"
tt.render.sprites[1].z = Z_EFFECTS - 1
