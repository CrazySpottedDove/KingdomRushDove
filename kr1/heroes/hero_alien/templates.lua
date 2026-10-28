local bit = require("bit")
local E = require("entity_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")
local km = require("lib.klua.macros")

require("lib.klua.table")
require("all.constants")

local band = bit.band
local bor = bit.bor
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local update_hp = HU.update_hp
local queue_damage = U.queue_damage

local function hero_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	upgrade_skill(this, "energyglaive", function(this, s)
		local a = this.ranged.attacks[1]

		a.disabled = nil

		local b = E:get_template(a.bullet)

		b.bullet.damage_min = s.damage[s.level]
		b.bullet.damage_max = s.damage[s.level]
		b.bounce_chance = s.bounce_chance[s.level]
	end)
	upgrade_skill(this, "purificationprotocol", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil

		local e = E:get_template(a.entity)

		e.duration = s.duration[s.level]
	end)
	upgrade_skill(this, "abduction", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.total_hp = s.total_hp[s.level]
		a.total_targets = s.total_targets[s.level]
	end)
	upgrade_skill(this, "vibroblades", function(this, s)
		this.vibroblades_extra = s.extra_damage[s.level]
	end)
	upgrade_skill(this, "finalcountdown", function(this, s)
		this.selfdestruct.disabled = nil
		this.selfdestruct.damage = s.damage[s.level]
	end)
	update_hp(this)

	this.ranged.attacks[1].ts = -this.ranged.attacks[1].cooldown
	this.timed_attacks.list[1].ts = -this.timed_attacks.list[1].cooldown
	this.timed_attacks.list[2].ts = -this.timed_attacks.list[2].cooldown
end

local function hero_vibroblades_side_effect(this, store, damage, target)
	local d = E.assign_damage(this.hero.skills.vibroblades.damage_type, this.vibroblades_extra * this.unit.damage_factor, this.id, damage.target_id)

	queue_damage(store, d)
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
					goto label_353_1
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.abduction

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local trigger = U.find_random_enemy(store, this.pos, 0, a.range, a.vis_flags, a.vis_bans, function(v)
					return not table.contains(a.invalid_templates, v.template_name) and (skill.level == 3 or v.health.hp <= a.total_hp) and P:is_node_valid(v.nav_path.pi, v.nav_path.ni + 10) and P:is_node_valid(v.nav_path.pi, v.nav_path.ni - 10)
				end)

				if not trigger then
					a.ts = a.ts + 0.13333333333333333

					goto label_353_0
				end

				a.ts = store.tick_ts

				SU.hero_gain_xp_from_skill(this, skill)
				S:queue(a.sound)
				U.animation_start_default(this, a.animation, nil, store.tick_ts)
				U.y_wait_unconditional(store, a.spawn_time)

				local abduction_hp, abduction_count = trigger.health.hp, 1
				local targets = U.find_enemies_in_range_filter_on(trigger.pos, a.attack_radius, a.vis_flags, a.vis_bans, function(v)
					local ok = v ~= trigger and abduction_hp + v.health.hp <= a.total_hp and abduction_count < a.total_targets and not table.contains(a.invalid_templates, v.template_name) and P:is_node_valid(v.nav_path.pi, v.nav_path.ni + 10) and P:is_node_valid(v.nav_path.pi, v.nav_path.ni - 10)

					if ok then
						abduction_hp = abduction_hp + v.health.hp
						abduction_count = abduction_count + 1
					end

					return ok
				end)

				if targets then
					table.insert(targets, trigger)
				else
					targets = {trigger}
				end

				if targets then
					local e = E:create_entity(a.entity)

					e.pos = V.vclone(trigger.pos)
					e.targets = targets

					simulation:queue_insert_entity(e)

					e.owner = this
				end

				U.y_animation_wait_default(this)

				goto label_353_1
			end

			::label_353_0::

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.purificationprotocol

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local target = U.find_foremost_enemy_in_range_filter_off(this.pos, a.range, nil, a.vis_flags, a.vis_bans)

				if not target then
					a.ts = a.ts + 0.13333333333333333
				else
					a.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, skill)
					S:queue(a.sound)
					U.animation_start_default(this, a.animation, nil, store.tick_ts)
					U.y_wait_unconditional(store, a.spawn_time)

					local e = E:create_entity(a.entity)

					e.pos = V.vclone(target.pos)
					e.target_id = target.id

					simulation:queue_insert_entity(e)

					e.owner = this

					U.y_animation_wait_default(this)

					goto label_353_1
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

		::label_353_1::

		coroutine.yield()
	end
end

local function alien_glaive_update(this, store)
	local b = this.bullet
	local mspeed = b.min_speed
	local target, ps
	local bounce_count = 0

	U.animation_start_default(this, "alien_glaive", nil, store.tick_ts, true)

	b.speed.x, b.speed.y = V.normalize(b.to.x - b.from.x, b.to.y - b.from.y)

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id

		simulation:queue_insert_entity(ps)
	end

	::label_356_0::

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
		target = store.entities[b.target_id]

		if target and target.health and not target.health.dead then
			b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
		end

		mspeed = mspeed + FPS * math.ceil(mspeed * (1 / FPS) * b.acceleration_factor)
		mspeed = km.clamp(b.min_speed, b.max_speed, mspeed)
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
		this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

		coroutine.yield()
	end

	if target and not target.health.dead then
		local d = SU.create_bullet_damage(b, target.id, this.id)

		queue_damage(store, d)

		if band(target.vis.bans, F_MOD) == 0 then
			local mod = E:create_entity(b.mod)

			mod.modifier.source_id = b.source_id
			mod.modifier.target_id = target.id
			mod.modifier.ts = store.tick_ts

			simulation:queue_insert_entity(mod)
		end
	end

	if b.hit_fx then
		local sfx = E:create_entity(b.hit_fx)

		sfx.pos.x, sfx.pos.y = b.to.x, b.to.y
		sfx.render.sprites[1].ts = store.tick_ts
		sfx.render.sprites[1].runs = 0

		simulation:queue_insert_entity(sfx)
	end

	if bounce_count == 0 or math.random() < this.bounce_chance then
		local target = U.find_foremost_enemy_with_flying_preference_in_range_filter_on(this.pos, this.bounce_range, b.vis_flags, b.vis_bans, function(v)
			return v ~= target
		end)

		if target then
			S:queue("HeroAlienDiscoBounce")

			bounce_count = bounce_count + 1
			b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
			b.target_id = target.id

			goto label_356_0
		end
	end

	simulation:queue_remove_entity(this)
end

local function alien_purification_drone_update(this, store)
	local sid = 2
	local attacking = false
	local target = store.entities[this.target_id]
	local start_ts, switch_ts

	local function y_switch_target(new_target)
		this.target_id = new_target.id
		attacking = false

		S:stop(this.sound_events.loop)

		this.render.sprites[1].hidden = true
		this.render.sprites[3].hidden = true

		U.y_animation_play(this, "disappear_short", nil, store.tick_ts, 1, sid)

		this.pos = new_target.pos

		U.y_animation_play(this, "appear_short", nil, store.tick_ts, 1, sid)

		switch_ts = store.tick_ts
	end

	if target and not target.health.dead then
		this.pos = target.pos
		this.render.sprites[2].flip_x = target.render.sprites[1].flip_x
	end

	U.y_animation_play(this, "appear_long", nil, store.tick_ts, 1, sid)

	start_ts = store.tick_ts
	switch_ts = store.tick_ts

	while true do
		if store.tick_ts - start_ts > this.duration + 1e-06 then
			break
		end

		target = store.entities[this.target_id]

		if target and store.tick_ts - switch_ts > this.switch_targets_every then
			local new_target = U.find_random_enemy(store, this.pos, 0, this.jump_range, this.vis_flags, this.vis_bans, function(v)
				return v.id ~= target.id
			end)

			if new_target then
				target = new_target

				y_switch_target(new_target)
			end
		end

		if not target or store.tick_ts - switch_ts > 0.3 and (target.health.dead or band(this.vis_flags, target.vis.bans) ~= 0 or band(this.vis_bans, target.vis.flags) ~= 0) then
			target = U.find_random_enemy(store, this.pos, 0, this.jump_range, this.vis_flags, this.vis_bans)

			if target then
				y_switch_target(target)
			else
				break
			end
		end

		if not attacking then
			attacking = true

			S:queue(this.sound_events.loop)

			this.pos = target.pos
			this.render.sprites[1].hidden = false
			this.render.sprites[3].hidden = false

			U.animation_start(this, "idle", target.render.sprites[1].flip_x, store.tick_ts, true, sid)
		end

		this.render.sprites[2].flip_x = target.render.sprites[1].flip_x

		if store.tick_ts - this.dps.ts >= this.dps.damage_every then
			this.dps.ts = store.tick_ts

			local d = E.assign_damage(this.dps.damage_type, this.dps.damage_max, this.id, target.id)

			queue_damage(store, d)

			if band(target.vis.flags, F_BOSS) == 0 and band(target.vis.bans, F_STUN) == 0 then
				local m = E:create_entity(this.mod)

				m.modifier.target_id = target.id
				m.modifier.source_id = this.id
				m.modifier.ts = store.tick_ts

				simulation:queue_insert_entity(m)
			end
		end

		coroutine.yield()
	end

	S:stop(this.sound_events.loop)
	S:queue(this.sound_events.finish)

	this.render.sprites[1].hidden = true
	this.render.sprites[3].hidden = true

	U.y_animation_play(this, "disappear_long", nil, store.tick_ts, 1, sid)
	simulation:queue_remove_entity(this)
end

local function alien_abduction_ship_update(this, store)
	local enemy_decals = {}

	for _, e in pairs(this.targets) do
		U.animation_start_default(e, "idle", nil, store.tick_ts, true)

		local es = E:create_entity("abducted_enemy_decal")

		es.pos.x, es.pos.y = e.pos.x, e.pos.y
		es.render = table.deepclone(e.render)
		es.tween.disabled = true

		simulation:queue_insert_entity(es)
		table.insert(enemy_decals, es)

		local d = E.assign_damage(DAMAGE_EAT, 0, this.id, e.id)

		queue_damage(store, d)
	end

	this.tween.ts = store.tick_ts

	U.y_wait_unconditional(store, 1.5)

	this.render.sprites[3].hidden = nil
	this.render.sprites[3].ts = store.tick_ts

	U.y_wait_unconditional(store, fts(10))

	for i, ed in ipairs(enemy_decals) do
		ed.tween.disabled = nil
		ed.tween.ts = store.tick_ts + (i - 1) * 0.1
	end

	U.y_animation_wait(this, 3)

	this.render.sprites[3].hidden = true
end

local tt

tt = RT("hero_alien", "hero")

AC(tt, "melee", "ranged", "selfdestruct", "timed_attacks")

tt.hero.level_stats.hp_max = {220, 240, 260, 280, 300, 320, 340, 360, 380, 400}
tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.melee_damage_min = {10, 12, 14, 16, 18, 20, 22, 24, 26, 28}
tt.hero.level_stats.melee_damage_max = {16, 19, 22, 25, 28, 31, 34, 37, 40, 43}
tt.hero.skills.energyglaive = CC("hero_skill")
tt.hero.skills.energyglaive.damage = {22, 34, 46}
tt.hero.skills.energyglaive.bounce_chance = {0.4, 0.5, 0.6}
tt.hero.skills.energyglaive.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.purificationprotocol = CC("hero_skill")
tt.hero.skills.purificationprotocol.duration = {1, 2, 3}
tt.hero.skills.purificationprotocol.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.purificationprotocol.xp_gain = {50, 100, 150}
tt.hero.skills.abduction = CC("hero_skill")
tt.hero.skills.abduction.total_targets = {1, 2, 3}
tt.hero.skills.abduction.total_hp = {500, 1000, 1500}
tt.hero.skills.abduction.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.abduction.xp_gain = {100, 150, 200}
tt.hero.skills.vibroblades = CC("hero_skill")
tt.hero.skills.vibroblades.extra_damage = {10, 20, 30}
tt.hero.skills.vibroblades.damage_type = DAMAGE_TRUE
tt.hero.skills.vibroblades.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.finalcountdown = CC("hero_skill")
tt.hero.skills.finalcountdown.damage = {100, 200, 300}
tt.hero.skills.finalcountdown.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.vibroblades_extra = 10
tt.hero.skills.finalcountdown.xp_gain = {100, 200, 300}
tt.health.armor = nil
tt.health.dead_lifetime = 6
tt.health.hp_max = nil
tt.health_bar.offset = vec_2(0, 41)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_level_up
tt.hero.tombstone_show_time = fts(66)
tt.idle_flip.cooldown = 1
tt.info.hero_portrait = "kr2_hero_portraits_0009"
tt.info.portrait = "kr2_info_portraits_heroes_0009"
tt.main_script.update = hero_update
tt.motion.max_speed = 100
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.31
tt.render.sprites[1].prefix = "hero_alien"
tt.soldier.melee_slot_offset.x = 13
tt.sound_events.change_rally_point = "HeroAlienTaunt"
tt.sound_events.death = "HeroAlienDeath"
tt.sound_events.respawn = "HeroAlienTauntIntro"
tt.sound_events.insert = "HeroAlienTauntIntro"
tt.sound_events.hero_room_select = "HeroAlienTauntSelect"
tt.unit.mod_offset = vec_2(0, 15.28)
tt.melee.range = 75
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 2.7
tt.melee.attacks[1].side_effect = hero_vibroblades_side_effect
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].disabled = true
tt.ranged.attacks[1].bullet = "alien_glaive"
tt.ranged.attacks[1].cooldown = 4.8 + fts(28)
tt.ranged.attacks[1].max_range = 125
tt.ranged.attacks[1].shoot_time = fts(13)
tt.ranged.attacks[1].bullet_start_offset = {vec_2(22, 16)}
tt.timed_attacks.list[1] = CC("spawn_attack")
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].animation = "abduction"
tt.timed_attacks.list[1].cooldown = 20
tt.timed_attacks.list[1].entity = "alien_abduction_ship"
tt.timed_attacks.list[1].range = 200
tt.timed_attacks.list[1].attack_radius = 40
tt.timed_attacks.list[1].spawn_time = fts(10)
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING, F_CLIFF, F_WATER, F_BOSS)
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[1].sound = "HeroAlienAbduction"
tt.timed_attacks.list[1].invalid_templates = {"enemy_umbra_piece", "enemy_jungle_spider_tiny"}
tt.timed_attacks.list[2] = CC("spawn_attack")
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].animation = "purification"
tt.timed_attacks.list[2].cooldown = 12.8
tt.timed_attacks.list[2].entity = "alien_purification_drone"
tt.timed_attacks.list[2].range = 125
tt.timed_attacks.list[2].spawn_time = fts(34)
tt.timed_attacks.list[2].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[2].invalid_templates = {"enemy_umbra_piece", "enemy_jungle_spider_tiny"}
tt.selfdestruct.damage_radius = 90
tt.selfdestruct.damage_type = DAMAGE_TRUE
tt.selfdestruct.disabled = true
tt.selfdestruct.hit_time = fts(48)
tt.selfdestruct.sound_hit = "HeroAlienExplosion"
tt.selfdestruct.xp_from_skill = "finalcountdown"
tt.selfdestruct.mod = "mod_alien_selfdestruct"
tt = RT("mod_slow_alien_glaive", "mod_slow")
tt.modifier.duration = 2
tt.slow.factor = 0.65
tt = RT("mod_alien_selfdestruct", "mod_stun")
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt.modifier.duration = 1.5
tt = RT("alien_glaive", "bullet")
tt.main_script.update = alien_glaive_update
tt.render.sprites[1].name = "alien_glaive"
tt.bullet.particles_name = "ps_alien_glaive_trail"
tt.bullet.hit_fx = "fx_alien_glaive_hit"
tt.bullet.acceleration_factor = 0.05
tt.bullet.min_speed = 150
tt.bullet.max_speed = 300
tt.bullet.xp_gain_factor = 2.5
tt.bounce_range = 150
tt.bullet.mod = "mod_slow_alien_glaive"
tt.sound_events.insert = "HeroAlienDiscoThrow"
tt = RT("fx_alien_glaive_hit", "fx")
tt.render.sprites[1].name = "alien_glaive_hit"
tt = RT("ps_alien_glaive_trail")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "alien_glaive_trail"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(12), fts(12)}
tt.particle_system.scales_x = {1.5, 1.5}
tt.particle_system.scales_y = {1.5, 0.5}
tt.particle_system.emission_rate = 40
tt.particle_system.track_rotation = true
tt = RT("alien_abduction_ship", "decal_scripted")

AC(tt, "sound_events", "tween")

tt.main_script.update = alien_abduction_ship_update
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].draw_order = 2
tt.render.sprites[1].anchor.y = 0.12
tt.render.sprites[1].name = "hero_alien_motherShip_0002"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].draw_order = 3
tt.render.sprites[2].name = "hero_alien_motherShip_0001"
tt.render.sprites[2].animated = false
tt.render.sprites[2].anchor.y = 0.12
tt.render.sprites[2].z = Z_BULLETS
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].draw_order = 1
tt.render.sprites[3].hidden = true
tt.render.sprites[3].loop = false
tt.render.sprites[3].name = "alien_abduction_ship_beam"
tt.render.sprites[3].anchor.y = 0.12
tt.render.sprites[3].offset.y = 20
tt.render.sprites[4] = CC("sprite")
tt.render.sprites[4].z = Z_DECALS
tt.render.sprites[4].name = "hero_alien_motherShip_0003"
tt.render.sprites[4].animated = false
tt.render.sprites[4].anchor.y = 0.12
tt.tween.props[1].loop = true
tt.tween.props[1].interp = "sine"
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {{0, vec_2(0, -4)}, {0.5, vec_2(0, 4)}, {1, vec_2(0, -4)}}
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.props[3] = CC("tween_prop")
tt.tween.props[3].name = "hidden"
tt.tween.props[4] = CC("tween_prop")
tt.tween.props[4].sprite_id = 2
tt.tween.props[5] = CC("tween_prop")
tt.tween.props[5].sprite_id = 4

local fd, ad = 0.65, fts(34)
local ti1, ti2, ti3 = 0, fd, 2 * fd
local to1, to2, to3 = ti3 + ad, ti3 + ad + fd, ti3 + ad + 2 * fd

tt.tween.props[3].keys = {{ti1, true}, {ti2, false}, {to2, true}}
tt.tween.props[4].keys = {{ti1, 0}, {ti2, 255}, {ti3, 0}, {to1, 0}, {to2, 255}, {to3, 0}}
tt.tween.props[5].keys = {{ti1, 0}, {ti2, 255}, {to2, 255}, {to3, 0}}

local ox, oy = 100, 28
local rays = {{vec_2(47 - ox, 152 - oy), fts(0), "1"}, {vec_2(106 - ox, 175 - oy), fts(5), "1"}, {vec_2(49 - ox, 170 - oy), fts(10), "1"}, {vec_2(84 - ox, 146 - oy), fts(10), "2"}, {vec_2(142 - ox, 157 - oy), fts(15), "2"}, {vec_2(58 - ox, 181 - oy), fts(20), "2"}}

for _, r in pairs(rays) do
	local poff, tdel, name = unpack(r)
	local s = CC("sprite")

	s.loop = true
	s.animated = true
	s.prefix = "alien_abduction_ship_lightning"
	s.name = name
	s.z = Z_BULLETS

	table.insert(tt.render.sprites, s)

	local t = CC("tween_prop")

	t.keys = {{ti1, 0}, {ti1 + tdel, 0}, {ti1 + tdel + 0.2, 255}, {ti1 + tdel + 0.45, 255}, {ti1 + tdel + 0.65, 0}, {to1, 0}, {to1 + tdel, 0}, {to1 + tdel + 0.2, 255}, {to1 + tdel + 0.45, 255}, {to1 + tdel + 0.65, 0}}
	t.sprite_id = #tt.render.sprites

	table.insert(tt.tween.props, t)

	local tb = table.deepclone(tt.tween.props[1])

	tb.keys = {{0, vec_2(poff.x, poff.y - 4)}, {0.5, vec_2(poff.x, poff.y + 4)}, {1, vec_2(poff.x, poff.y - 4)}}
	tb.sprite_id = #tt.render.sprites

	table.insert(tt.tween.props, tb)
end

tt = RT("abducted_enemy_decal", "decal_tween")
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 200}, {0.25, 178}, {0.55, 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "offset"
tt.tween.props[2].keys = {{0, vec_2(0, 0)}, {"U.frandom(0.1,0.2)", vec_2(0, 10)}, {0.55, vec_2(0, 60)}}
tt.tween.props[3] = CC("tween_prop")
tt.tween.props[3].name = "r"
tt.tween.props[3].keys = {{0, 0}, {0.55, "math.random(-20,20)*math.pi/180"}}
tt = RT("alien_purification_drone", "decal_scripted")

AC(tt, "sound_events", "dps")

tt.render.sprites[1].name = "alien_drone_attack_beam"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].anchor.y = 0.08
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "alien_drone"
tt.render.sprites[2].name = "appear_long"
tt.render.sprites[2].anchor.y = 0.08
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].name = "alien_drone_attack_decal"
tt.render.sprites[3].hidden = true
tt.render.sprites[3].anchor.y = 0.17
tt.sound_events.insert = "HeroAlienDrone"
tt.sound_events.finish = "HeroAlienDroneLeave"
tt.sound_events.loop = "HeroAlienDroneLoop"
tt.main_script.update = alien_purification_drone_update
tt.dps.damage_max = 16
tt.dps.damage_min = 16
tt.dps.damage_every = fts(6)
tt.dps.damage_type = DAMAGE_TRUE
tt.mod = "mod_stun"
tt.jump_range = 150
tt.switch_targets_every = fts(31)
tt.vis_bans = bor(F_BOSS)
tt.vis_flags = bor(F_RANGED)
