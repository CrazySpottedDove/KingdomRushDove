local scripts = require("scripts")
local E = require("entity_db")
local GR = require("grid_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local bit = require("bit")
local HU = require("hero_utils")
local signal = require("lib.hump.signal")
local band = bit.band
local bor = bit.bor
local fts = U.fts
local level_up_basic = HU.level_up_basic
local queue_damage = U.queue_damage
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local tt

local function hero_durax_ultimate_can_fire_fn(this, x, y, store)
	for _, e in pairs(store.enemies) do
		if e.pos and e.ui and e.ui.can_click and e.nav_path and not e.health.dead and band(e.vis.flags, F_FLYING) == 0 and band(e.vis.bans, F_MOD) == 0 and U.is_inside_ellipse(V.v(e.pos.x + e.unit.hit_offset.x, e.pos.y + e.unit.hit_offset.y), V.v(x, y), 250) and P:is_node_valid(e.nav_path.pi, e.nav_path.ni, NF_POWER_1) then
			return true
		end
	end

	return false
end

local function hero_durax_ultimate_update(this, store)
	this.damage = this.damage * this.damage_factor

	local targets = U.find_enemies_in_range_filter_on(this.pos, this.range, this.vis_flags, this.vis_bans, function(e)
		return band(e.vis.flags, F_BOSS) ~= 0 or band(e.vis.bans, F_STUN) == 0
	end)

	if targets then
		local single = #targets == 1

		for i, target in ipairs(targets) do
			local d = E.assign_damage(this.damage_type, this.damage / #targets, this.id, target.id)

			queue_damage(store, d)

			if target.unit.blood_color ~= BLOOD_NONE then
				local sfx = E:create_entity(this.hit_blood_fx)

				sfx.pos.x, sfx.pos.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
				sfx.render.sprites[1].ts = store.tick_ts

				if sfx.use_blood_color and target.unit.blood_color then
					sfx.render.sprites[1].name = target.unit.blood_color
				end

				simulation:queue_insert_entity(sfx)
			end

			local m = E:create_entity(band(target.vis.flags, F_BOSS) ~= 0 and this.mod_slow or this.mod_stun)

			m.modifier.target_id = target.id
			m.modifier.source_id = this.id

			simulation:queue_insert_entity(m)

			local fx = SU.insert_sprite(store, "fx_durax_ultimate_fang_" .. (single and "1" or "2"), target.pos)

			fx.render.sprites[1].scale = fx.render.sprites[1].size_scales[target.unit.size]

			local spikes_count = single and 12 or 8
			local radius = single and 40 or 30
			local angle = U.frandom(0, math.pi)

			for j = 1, spikes_count do
				local p = U.point_on_ellipse(target.pos, U.frandom(0.5, 1) * radius, angle)

				angle = angle + math.pi / 4.2

				local fx = SU.insert_sprite(store, "fx_durax_ultimate_fang_extra_" .. math.random(1, 2), p, nil, U.frandom(0.1, 0.2))

				fx.render.sprites[1].scale = V.vv(U.frandom(0.8, 1.1))
			end
		end
	end

	simulation:queue_remove_entity(this)
end

local function hero_durax_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
	this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

	local upgrade_all_skill = function()
		upgrade_skill(this, "crystallites", function(this, s)
			local a = this.timed_attacks.list[2]

			a.disabled = nil
		end)
		upgrade_skill(this, "armsword", function(this, s)
			local a = this.melee.attacks[3]

			a.disabled = nil
			a.damage_min = s.damage[s.level]
			a.damage_max = s.damage[s.level]
		end)
		upgrade_skill(this, "lethal_prism", function(this, s)
			local a = this.timed_attacks.list[1]

			a.disabled = nil
			a.ray_count = s.ray_count[s.level]

			local b = E:get_template(a.bullet)

			b.bullet.damage_max = s.damage_max[s.level]
			b.bullet.damage_min = s.damage_min[s.level]
		end)
		upgrade_skill(this, "shardseed", function(this, s)
			local a = this.ranged.attacks[1]

			a.disabled = nil

			local b = E:get_template(a.bullet)

			b.bullet.damage_max = s.damage[s.level]
			b.bullet.damage_min = s.damage[s.level]
		end)
		upgrade_skill(this, "ultimate", function(this, s)
			this.ultimate.disabled = nil

			local u = E:get_template(s.controller_name)

			u.max_count = s.max_count[s.level]
			u.damage = s.damage[s.level]
		end)
	end

	if this.clone and not this.first_updated then
		local level = this.hero.level

		for i = 1, level do
			this.hero.level = i

			upgrade_all_skill()
		end

		this.first_updated = true
	else
		upgrade_all_skill()
	end

	update_hp(this)
end

local function hero_durax_update(this, store)
	local h = this.health
	local a, skill, brk, sta, decal

	this.health_bar.hidden = false

	if not this.clone then
		U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

		decal = E:create_entity("decal_durax")
		decal.pos = this.pos

		simulation:queue_insert_entity(decal)
	end

	while true do
		if h.dead or this.clone and store.tick_ts - this.clone.ts > this.clone.duration then
			if this.clone then
				this.ui.can_click = false
				this.health.hp = 0

				signal.emit("hero-removed-no-panel", this)
				SU.y_soldier_death(store, this)

				this.tween.disabled = nil
				this.tween.ts = store.tick_ts

				return
			else
				decal.render.sprites[1].hidden = true

				SU.y_hero_death_and_respawn(store, this)

				decal.render.sprites[1].hidden = nil
			end
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_161_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.lethal_prism

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local triggers = U.find_enemies_in_range_filter_off(this.pos, a.range, a.vis_flags, a.vis_bans)

				if not triggers then
					a.ts = a.ts + 0.3333333333333333
				else
					SU.remove_modifiers(store, this)

					this.health_bar.hidden = true
					this.health.ignore_damage = true

					U.flags_remove(this.vis, F_RANGED)
					U.bans_add(this.vis, F_ALL)
					U.y_animation_play(this, a.animations[1], nil, store.tick_ts)
					U.animation_start_default(this, a.animations[2], nil, store.tick_ts, true)

					for i = 1, a.ray_count do
						local target = U.find_random_enemy(store, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

						if target then
							local bo = a.bullet_start_offset[1]
							local b = E:create_entity(a.bullet)

							b.bullet.damage_factor = this.unit.damage_factor
							b.bullet.target_id = target.id
							b.bullet.source_id = this.id
							b.pos = V.v(this.pos.x + bo.x, this.pos.y + bo.y)

							b.bullet.from:copy(b.pos)
							b.bullet.to:copy(target.pos)
							simulation:queue_insert_entity(b)
						end

						U.y_wait_unconditional(store, a.ray_cooldown)
					end

					U.y_animation_play(this, a.animations[3], nil, store.tick_ts)
					U.flags_add(this.vis, F_RANGED)
					U.bans_remove(this.vis, F_ALL)

					this.health.ignore_damage = nil
					this.health_bar.hidden = nil
					a.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, skill)

					goto label_161_0
				end
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.crystallites

			if not this.clone and ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local nearest = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true, NF_RALLY)

				if #nearest < 1 then
					a.ts = a.ts + 0.3333333333333333
				else
					local ns = {}

					ns.pi = nearest[1][1]
					ns.spi = math.random(1, 3)
					ns.ni = nearest[1][3] - math.random(a.nodes_offset[1], a.nodes_offset[2])

					local node_pos = P:node_pos(ns.pi, ns.spi, ns.ni)

					if not P:is_node_valid(ns.pi, ns.ni, NF_RALLY) or band(GR:cell_type(node_pos.x, node_pos.y), bor(TERRAIN_NOWALK, TERRAIN_FAERIE)) ~= 0 then
						a.ts = a.ts + 0.3333333333333333
					else
						S:queue(a.sound)
						U.animation_start_default(this, a.animation, nil, store.tick_ts, false)
						U.y_wait_unconditional(store, a.spawn_time)

						local spawn_pos = V.v(this.pos.x + (this.render.sprites[1].flip_x and -1 or 1) * a.spawn_offset.x, this.pos.y + a.spawn_offset.y)
						local clone = E:create_entity(a.entity)

						clone.pos = spawn_pos
						clone.nav_rally.pos = node_pos
						clone.nav_rally.center = V.vclone(node_pos)
						clone.nav_rally.new = true
						clone.render.sprites[1].flip_x = this.render.sprites[1].flip_x
						clone.clone.ts = store.tick_ts
						clone.clone.duration = skill.duration[skill.level]
						clone.hero.level = this.hero.level
						clone.hero.xp = this.hero.xp

						SU.insert_unit_damage_factor_buff(clone, this.unit.damage_factor + this.hero.skills.crystallites.damage_factor - 1 - clone.unit.damage_factor)

						for sn, s in pairs(this.hero.skills) do
							clone.hero.skills[sn].level = s.level
						end

						simulation:queue_insert_entity(clone)
						signal.emit("hero-added-no-panel", clone)
						SU.hero_gain_xp_from_skill(this, skill)
						U.y_animation_wait_default(this)

						a.ts = store.tick_ts
					end
				end
			end

			if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
				local target = U.find_foremost_enemy_in_range_filter_off(this.pos, this.ranged.attacks[1].max_range, 0, F_RANGED, 0)

				if target and target.pos and hero_durax_ultimate_can_fire_fn(nil, target.pos.x, target.pos.y, store) then
					U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
					S:queue(this.sound_events.change_rally_point)

					local e = E:create_entity(this.hero.skills.ultimate.controller_name)

					e.level = this.hero.skills.ultimate.level
					e.pos = V.vclone(target.pos)
					e.damage_factor = this.unit.damage_factor

					simulation:queue_insert_entity(e)

					this.ultimate.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
				else
					this.ultimate.ts = this.ultimate.ts + 1
				end
			end

			if not this.ranged.attacks[1].disabled then
				brk, sta = SU.y_soldier_ranged_attacks(store, this)

				if brk then
					goto label_161_0
				end
			end

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

		::label_161_0::

		coroutine.yield()
	end
end

tt = RT("hero_durax", "hero")

AC(tt, "melee", "ranged", "timed_attacks", "transfer")

tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.hp_max = {280, 300, 320, 340, 360, 380, 400, 420, 440, 460}
tt.hero.level_stats.melee_damage_max = {13, 15, 16, 18, 19, 21, 22, 24, 25, 27}
tt.hero.level_stats.melee_damage_min = {9, 10, 11, 12, 13, 14, 15, 16, 17, 18}
tt.hero.skills.crystallites = CC("hero_skill")
tt.hero.skills.crystallites.duration = {50, 75, 100}
tt.hero.skills.crystallites.xp_gain = {225, 450, 675}
tt.hero.skills.crystallites.damage_factor = 0.8
tt.hero.skills.crystallites.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.hero.skills.armsword = CC("hero_skill")
tt.hero.skills.armsword.xp_gain = {40, 80, 120}
tt.hero.skills.armsword.damage = {80, 130, 180}
tt.hero.skills.armsword.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.lethal_prism = CC("hero_skill")
tt.hero.skills.lethal_prism.damage_max = {40, 45, 55}
tt.hero.skills.lethal_prism.damage_min = {25, 30, 35}
tt.hero.skills.lethal_prism.ray_count = {2, 4, 6}
tt.hero.skills.lethal_prism.xp_gain = {23, 46, 78}
tt.hero.skills.lethal_prism.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.shardseed = CC("hero_skill")
tt.hero.skills.shardseed.damage = {80, 130, 180}
tt.hero.skills.shardseed.xp_gain = {40, 80, 120}
tt.hero.skills.shardseed.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_durax_ultimate"
-- deprecated, default no count bound
tt.hero.skills.ultimate.max_count = {4, 6, 8, 10}
tt.hero.skills.ultimate.damage = {300, 400, 800, 1200}
tt.hero.skills.ultimate.xp_gain_factor = 36
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, 65)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_durax_level_up
tt.hero.tombstone_show_time = fts(90)
tt.info.hero_portrait = "kr3_hero_portraits_0011"
tt.info.portrait = "kr3_info_portraits_heroes_0011"
tt.main_script.update = hero_durax_update
tt.motion.max_speed = 2 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.2308
tt.render.sprites[1].prefix = "durax_hero"
tt.sound_events.change_rally_point = "ElvesHeroDuraxTaunt"
tt.sound_events.death = "ElvesHeroDuraxDeath"
tt.sound_events.insert = "ElvesHeroDuraxTauntIntro"
tt.sound_events.respawn = "ElvesHeroDuraxTauntIntro"
tt.sound_events.hero_room_select = "ElvesHeroDuraxTauntSelect"
tt.unit.hit_offset = vec_2(0, 23)
tt.unit.mod_offset = vec_2(0, 23)
tt.transfer.extra_speed = 5.5 * FPS
tt.transfer.sound_loop = "ElvesHeroDuraxWalkLoop"
tt.transfer.animations = {"lethalPrismStart", "specialwalkLoop", "lethalPrismEnd"}
tt.transfer.particles_name = "ps_durax_transfer"
tt.melee.attacks[1].hit_time = fts(8)
tt.melee.attacks[1].xp_gain_factor = 3.8
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].damage_type = DAMAGE_TRUE
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].chance = 0.5
tt.melee.attacks[3] = CC("melee_attack")
tt.melee.attacks[3].animation = "armblade"
tt.melee.attacks[3].cooldown = 17.5
tt.melee.attacks[3].damage_max = nil
tt.melee.attacks[3].damage_min = nil
tt.melee.attacks[3].damage_type = DAMAGE_TRUE
tt.melee.attacks[3].disabled = true
tt.melee.attacks[3].hit_time = fts(27)
tt.melee.attacks[3].sound = "ElvesHeroDuraxArmblade"
tt.melee.attacks[3].xp_from_skill = "armsword"
tt.melee.cooldown = 1
tt.melee.range = 75
tt.vis.bans = bor(tt.vis.bans, F_POISON)
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animation = "shardseed"
tt.ranged.attacks[1].disabled = true
tt.ranged.attacks[1].max_range = 250
tt.ranged.attacks[1].min_range = 75
tt.ranged.attacks[1].cooldown = 17.5
tt.ranged.attacks[1].bullet = "spear_durax"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(-17, 55)}
tt.ranged.attacks[1].shoot_time = fts(9)
tt.ranged.attacks[1].xp_from_skill = "shardseed"
tt.timed_attacks.list[1] = CC("bullet_attack")
tt.timed_attacks.list[1].animations = {"lethalPrismStart", "lethalPrismLoop", "lethalPrismEnd"}
tt.timed_attacks.list[1].bullet = "ray_durax"
tt.timed_attacks.list[1].bullet_start_offset = {vec_2(0, 20)}
tt.timed_attacks.list[1].cooldown = 17.5
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].range = 150
tt.timed_attacks.list[1].ray_cooldown = fts(10)
tt.timed_attacks.list[1].xp_from_skill = "lethal_prism"
tt.timed_attacks.list[2] = CC("spawn_attack")
tt.timed_attacks.list[2].animation = "crystallites"
tt.timed_attacks.list[2].cooldown = 50
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].entity = "hero_durax_clone"
tt.timed_attacks.list[2].nodes_offset = {5, 14}
tt.timed_attacks.list[2].sound = "ElvesHeroDuraxCrystallites"
tt.timed_attacks.list[2].spawn_offset = vec_2(22, 0)
tt.timed_attacks.list[2].spawn_time = fts(19)
tt.timed_attacks.list[2].xp_from_skill = "cristallites"
tt.ultimate = {
	ts = 0,
	cooldown = 36,
	disabled = true
}
tt = RT("hero_durax_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.can_fire_fn = hero_durax_ultimate_can_fire_fn
tt.cooldown = 36
tt.range = 75
tt.main_script.update = hero_durax_ultimate_update
tt.damage_type = DAMAGE_TRUE
tt.vis_flags = bor(F_MOD)
tt.vis_bans = bor(F_FLYING)
tt.sound_events.insert = "ElvesHeroDuraxUltimate"
tt.mod_slow = "mod_durax_slow"
tt.mod_stun = "mod_durax_stun"
tt.hit_blood_fx = "fx_blood_splat"
tt = RT("hero_durax_clone", "hero_durax")

AC(tt, "tween")

tt.clone = {}
tt.render.sprites[1].shader = "p_tint"
tt.render.sprites[1].shader_args = {
	tint_factor = 0.25,
	tint_color = {0, 0.75, 1, 1}
}
tt.health.dead_lifetime = 3
tt.sound_events.change_rally_point = "ElvesHeroDuraxTaunt"
tt.sound_events.death = "ElvesHeroDuraxDeath"
tt.sound_events.insert = nil
tt.ranged.attacks[1].bullet = "spear_durax_clone"
tt.tween.disabled = true
tt.tween.props[1].keys = {{2, 255}, {3, 0}}
tt.transfer.particles_name = "ps_durax_clone_transfer"
tt = RT("ps_durax_transfer")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "ps_durax_transfer"
tt.particle_system.animated = true
tt.particle_system.animation_fps = 15
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(12), fts(12)}
tt.particle_system.emission_rate = 30
tt.particle_system.emit_offset = vec_2(0, 16)
tt.particle_system.emit_rotation_spread = math.pi
tt.particle_system.sort_y_offset = 2
tt = RT("ps_durax_clone_transfer", "ps_durax_transfer")
tt.particle_system.alphas = {150}
tt = RT("fx_ray_durax_hit", "fx")
tt.render.sprites[1].name = "fx_ray_durax_hit"
tt = RT("fx_shardseed_hit", "fx")

AC(tt, "sound_events")

tt.render.sprites[1].name = "fx_shardseed_hit"
tt.render.sprites[1].anchor.y = 0.46296296296296297
tt.sound_events.insert = "ElvesHeroDuraxShardSpearHit"
tt = RT("decal_durax", "decal")
tt.render.sprites[1].name = "aura_durax"
tt.render.sprites[1].scale = vec_1(1.3)
tt.render.sprites[1].z = Z_DECALS
tt = RT("ray_durax", "bullet")
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.hit_fx = "fx_ray_durax_hit"
tt.bullet.hit_time = fts(5)
tt.image_width = 164
tt.track_target = true
tt.main_script.update = scripts.ray_simple.update
tt.render.sprites[1].anchor = vec_2(0, 0.5)
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "ray_durax"
tt.sound_events.insert = "ElvesHeroDuraxLethalPrismShoot"
tt = RT("spear_durax", "arrow")
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.flight_time = fts(16)
tt.bullet.hide_radius = 1
tt.bullet.hit_fx = "fx_shardseed_hit"
tt.bullet.miss_decal = "durax_hero_proy_0002-f"
tt.bullet.miss_decal_anchor = vec_2(1, 0.5)
tt.bullet.reset_to_target_pos = true
tt.bullet.xp_gain_factor = 0.35
tt.render.sprites[1].anchor.x = 0.8214285714285714
tt.render.sprites[1].name = "durax_hero_proy_0001-f"
tt.sound_events.insert = "ElvesHeroDuraxShardSpearThrow"
tt = RT("spear_durax_clone", "spear_durax")
tt.render.sprites[1].shader = "p_tint"
tt.render.sprites[1].shader_args = {
	tint_color = {0, 1, 1, 1}
}
tt = RT("mod_durax_slow", "mod_slow")
tt.modifier.duration = fts(15)
tt.slow.factor = 0.9
tt = RT("mod_durax_stun", "mod_stun")
tt.modifier.duration = fts(20)
tt.modifier.vis_bans = F_BOSS
