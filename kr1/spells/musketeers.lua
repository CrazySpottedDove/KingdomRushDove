local M = {}

M.id = "musketeers"
M.i18n = "POWER_MUSKETEERS"
M.control = "power_musketeers_control"
M.button_icon = "in_game_icon_power_musketeers"
M.pointer_icon = "pointer_power_musketeers"
M.portrait = "power_portraits_big_musketeers"
M.name_style = {
	font_name = "h",
	font_size = 30,
	color = {255, 206, 122, 255},
	shaders = {"p_outline", "p_glow"},
	shader_args = {{
		thickness = 3,
		outline_color = {0.34, 0.14, 0.03, 1}
	}, {
		thickness = 2,
		glow_color = {0.95, 0.56, 0.16, 0.75}
	}},
	shader_margin = 16
}
M.required_textures = {"go_power_musketeers"}
M.plugin_required_textures = {}
M.required_sounds = {"spell_musketeers"}
M.plugin_required_sounds = {}
M.required_exoskeletons = {}
M.plugin_required_exoskeletons = {}

local BASE = {
	cooldown = 20,
	duration = 12,
	hp_max = 30,
	max_speed = 80,
	range = 220,
	attack_cooldown = 1.5,
	damage_min = 10,
	damage_max = 16
}

function M.register_templates(E)
	local V = require("lib.klua.vector")
	local v = V.v
	local vv = V.vv
	local r = V.r
	local bit = require("bit")
	local band = bit.band
	local bor = bit.bor
	local U = require("utils")
	local SU = require("script_utils")
	local GR = require("grid_db")
	local P = require("path_db")
	local signal = require("lib.hump.signal")
	local scripts = require("game_scripts")
	local km = require("lib.klua.macros")

	require("lib.klua.table")

	local function fts(x)
		return x / FPS
	end

	local function is_disabled(store, target)
		if target.enemy and target.enemy.blockers and #target.enemy.blockers > 0 then
			return true
		end

		return target.unit and target.unit.is_stunned or false
	end

	local tt

	tt = E:register_t_tmp(M.control, "power_control_custom")
	tt.main_script.insert = function(this, store)
		local x, y = this.pos.x, this.pos.y

		for j = 1, 2 do
			local e = E:create_entity("soldier_musketeers")

			e.pos.x = j == 1 and x + 10 or x - 10
			e.pos.y = j == 1 and y - 10 or y + 10
			e.nav_rally.center = v(x, y)
			e.nav_rally.pos = V.vclone(e.pos)
			e.reinforcement.squad_id = this.id

			if j == 1 then
				e.wait_time = fts(5)
			end

			simulation:queue_insert_entity(e)
		end

		return true
	end
	tt.main_script.update = function(this, store)
		coroutine.yield()
		simulation:queue_remove_entity(this)
	end
	tt.user_selection.can_select_point_fn = function(this, x, y, store)
		return GR:cell_is(x, y, bor(TERRAIN_LAND, TERRAIN_ICE)) and not GR:cell_is(x, y, bor(TERRAIN_NOWALK)) and P:valid_node_nearby(x, y, nil, NF_RALLY)
	end
	tt.cooldown = BASE.cooldown

	E:set_template("user_power_3", tt)

	tt = E:register_t_tmp("bullet_power_musketeers", "bullet")
	tt.render.sprites[1].prefix = "Musketeers_Trail"
	tt.render.sprites[1].name = "laser"
	tt.render.sprites[1].draw_order = 4
	tt.bullet.damage_min = BASE.damage_min
	tt.bullet.damage_max = BASE.damage_max
	tt.bullet.damage_type = DAMAGE_SHOT
	tt.bullet.reduce_armor = 0
	tt.bullet.hit_blood_fx = nil
	tt.bullet.hit_fx = "fx_bullet_musketeers"
	tt.bullet.hit_time = fts(1)
	tt.bullet.ignore_hit_offset = true
	tt.main_script.update = scripts.ray5_simple.update
	tt.sound_events.insert = "PowersMusketeersBasicAttackCast"
	tt.image_width = 100
	tt.ray_duration = fts(30)

	tt = E:register_t_tmp("bullet_power_musketeers_l4a", "bullet_power_musketeers")
	tt.bullet.hit_fx = "fx_bullet_musketeers_l4a"
	tt.bullet.damage_min = BASE.damage_min * 1.35
	tt.bullet.damage_max = BASE.damage_max * 1.35

	tt = E:register_t_tmp("bullet_power_musketeers_l5b", "bullet_power_musketeers")
	tt.render.sprites[1].prefix = nil
	tt.render.sprites[1].name = "Musketeers_TrailInstakill"
	tt.render.sprites[1].animated = true
	tt.bullet.hit_fx = nil
	tt.bullet.damage_min = 1e99
	tt.bullet.damage_max = 1e99
	tt.bullet.damage_type = DAMAGE_INSTAKILL
	tt.bullet.pop = {"pop_headshot"}
	tt.image_width = 212.5
	tt.ray_duration = fts(10)

	tt = E:register_t_tmp("bullet_power_musketeers_l6", "bullet_power_musketeers")
	tt.render.sprites[1].prefix = "Musketeers_TrailUlti"
	tt.render.sprites[1].name = "laser"
	tt.bullet.hit_fx = "fx_bullet_musketeers_l6"
	tt.bullet.hit_payload = "aura_power_musketeers_bullet_l6"
	tt.bullet.damage_min = 0
	tt.bullet.damage_max = 0
	tt.bullet.damage_type = DAMAGE_NONE
	tt.image_width = 212.5
	tt.ray_duration = fts(20)
	tt.main_script.update = function(this, store)
		local b = this.bullet
		local s = this.render.sprites[1]
		local target = store.entities[b.target_id]
		local dest = V.vclone(b.to)

		local function update_sprite()
			if this.track_target and target and target.motion then
				dest.x, dest.y = target.pos.x, target.pos.y

				if target.unit and target.unit.hit_offset then
					dest.x, dest.y = dest.x + target.unit.hit_offset.x, dest.y + target.unit.hit_offset.y
				end
			end

			s.r = V.angleTo(dest.x - this.pos.x, dest.y - this.pos.y)
			s.scale = s.scale or v(1, 1)
			s.scale.x = V.dist(dest.x, dest.y, this.pos.x, this.pos.y) / this.image_width
		end

		update_sprite()

		s.ts = store.tick_ts
		s.hidden = true

		if b.hit_time and b.hit_time > fts(1) then
			local hit_ts = store.tick_ts

			while store.tick_ts - hit_ts < b.hit_time do
				coroutine.yield()

				if this.track_target then
					update_sprite()
				end
			end
		end

		local fx = E:create_entity(b.hit_fx)

		fx.pos.x, fx.pos.y = dest.x, dest.y

		fx.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(fx)

		local hp = E:create_entity(b.hit_payload)

		if target then
			hp.pos:copy(target.pos)
		else
			hp.pos:copy(dest)
		end

		hp.aura.level = b.level or 1
		hp.aura.source_id = this.id
		hp.aura.damage_factor = b.damage_factor

		simulation:queue_insert_entity(hp)

		if target and not U.flag_has(target.vis.flags, F_FLYING) then
			for _ = 1, math.random(3, 5) do
				local decal = E:create_entity(math.random(1, 2) == 1 and "decal_power_musketeers_fire_1" or "decal_power_musketeers_fire_2")
				local angle = math.random() * math.pi * 2
				local radius = math.sqrt(math.random()) * 20

				decal.pos = v(dest.x + math.cos(angle) * radius, dest.y + math.sin(angle) * radius - 10)
				decal.render.sprites[1].ts = store.tick_ts
				decal.duration = math.random(3, 5)

				simulation:queue_insert_entity(decal)
			end
		end

		local ray_ts = store.tick_ts

		while store.tick_ts - ray_ts < this.ray_duration do
			if this.track_target then
				update_sprite()
			end

			coroutine.yield()

			s.hidden = false
		end

		simulation:queue_remove_entity(this)
	end

	tt = E:register_t_tmp("fx_bullet_musketeers", "fx")
	tt.render.sprites[1].prefix = "Musketeers_HitFX"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].scale = vv(1.2)

	tt = E:register_t_tmp("fx_bullet_musketeers_l4a", "fx")
	tt.render.sprites[1].prefix = "Musketeers_HitFXExtraDMG"
	tt.render.sprites[1].name = "run"

	tt = E:register_t_tmp("fx_bullet_musketeers_l6", "fx")
	tt.render.sprites[1].prefix = "Musketeers_ExplosionUlti"
	tt.render.sprites[1].name = "explode"
	tt.render.sprites[1].anchor = v(0.5, 0.35)

	tt = E:register_t_tmp("ps_bullet_musketeers_casing", "particle_system")
	tt.particle_system.name = "Musketeers_TrailBala_trail"
	tt.particle_system.particle_lifetime = {fts(20), fts(20)}
	tt.particle_system.emission_rate = 1

	tt = E:register_t_tmp("fx_bullet_musketeer_casing")
	E:add_comps(tt, "pos", "render", "main_script", "tween")
	tt.render.sprites[1].prefix = "Musketeers_Bala"
	tt.render.sprites[1].name = "spin"
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].z = Z_BULLETS
	tt.render.sprites[1].draw_order = DO_MOD_FX
	tt.render.sprites[1].anchor = v(0.5, 0.5)
	tt.tween.props[1].keys = {{0, 255}, {1, 0}}
	tt.tween.props[1].loop = false
	tt.tween.props[1].name = "alpha"
	tt.tween.remove = true
	tt.tween.disabled = true
	tt.rest_anim = "land"
	tt.initial_direction_v = v(0.27, 1)
	tt.initial_speed = 220
	tt.g = -1000
	tt.elasticity = 0.8
	tt.bounces = 1
	tt.friction_threshold = 10
	tt.y_origin = 0
	tt.particles_name = "ps_bullet_musketeers_casing"
	tt.main_script.update = function(this, store)
		local ps

		if this.particles_name then
			ps = E:create_entity(this.particles_name)
			ps.particle_system.track_id = this.id

			simulation:queue_insert_entity(ps)
		end

		local nvx, nvy = V.normalize(this.initial_direction_v.x + U.frandom(-0.02, 0.02), this.initial_direction_v.y + U.frandom(-0.06, 0.06))
		local conserved_speed = this.initial_speed * U.frandom(0.9, 1.1)
		local cvx, cvy = V.mul(conserved_speed, nvx, nvy)
		local dt = fts(1)
		local last_ts = store.tick_ts
		local spr = this.render.sprites[1]
		local bounces = 0

		while not V.eq(cvx, cvy, 0, 0) do
			this.pos.x, this.pos.y = this.pos.x + cvx * dt, this.pos.y + cvy * dt
			spr.r = spr.r + -km.sign(nvx) * 20 * dt

			if this.pos.y <= this.y_origin then
				if bounces == this.bounces then
					cvx, cvy = 0, 0
					spr.r = 0
					spr.z = Z_DECALS

					U.y_animation_play(this, this.rest_anim, nil, store.tick_ts)

					break
				end

				bounces = bounces + 1
				this.pos.y = this.y_origin
				conserved_speed = conserved_speed * this.elasticity
				cvy = conserved_speed * nvy
				cvx = conserved_speed * nvx

				if bounces == this.bounces and ps and ps.particle_system.emit then
					ps.particle_system.emit = false
				end
			end

			cvy = cvy + this.g * dt
			dt = store.tick_ts - last_ts
			last_ts = store.tick_ts

			coroutine.yield()
		end

		U.y_wait(store, 2)

		this.tween.ts = store.tick_ts
		this.tween.disabled = false
	end

	tt = E:register_t_tmp("decal_power_musketeers_fire_1", "decal_scripted")
	E:add_comps(tt, "tween")
	tt.render.sprites[1].prefix = "Musketeers_UltiRandomDecal"
	tt.render.sprites[1].name = "loop"
	tt.animation_idle = "loop"
	tt.duration = 3
	tt.main_script.update = scripts.decal_utils.animation_in_loop_out.update
	tt.main_script.remove = scripts.tween_utils.reverse_remove
	tt.tween.props[1].keys = {{0, 0}, {1, 255}}
	tt.tween.props[1].name = "alpha"
	tt.tween.props[1].reverse = false
	tt.tween.disabled = true

	tt = E:register_t_tmp("decal_power_musketeers_fire_2", "decal_power_musketeers_fire_1")
	tt.render.sprites[1].prefix = "Musketeers_UltiRandomDecal2"

	tt = E:register_t_tmp("aura_power_musketeers_bullet_l6", "aura")
	tt.aura.radius = 50
	tt.aura.vis_flags = bor(F_AREA)
	tt.aura.vis_bans = bor(F_FRIEND, F_HERO)
	tt.aura.cycles = 1
	tt.aura.cycle_time = 0
	tt.aura.duration = 1e99
	tt.aura.damage_min = 56
	tt.aura.damage_max = 80
	tt.aura.damage_type = DAMAGE_EXPLOSION
	tt.aura.mod = "mod_power_musketeers_stun"
	tt.main_script.update = scripts.aura_apply_damage.update

	tt = E:register_t_tmp("mod_power_musketeers_stun", "mod_stun")
	tt.modifier.vis_flags = bor(F_MOD, F_STUN)
	tt.modifier.duration = 2

	tt = E:register_t_tmp("mod_power_musketeers_instakill_aim", "modifier")
	E:add_comps(tt, "render")
	tt.render.sprites[1].prefix = "Musketeers_MiraInstakill"
	tt.render.sprites[1].name = "in"
	tt.render.sprites[1].z = Z_EFFECTS
	tt.render.sprites[1].loop = false
	tt.modifier.duration = 1e99
	tt.main_script.insert = scripts.mod_track_target.insert
	tt.main_script.update = scripts.mod_track_target.update
	tt.main_script.remove = scripts.mod_track_target.remove

	tt = E:register_t_tmp("soldier_musketeers", "soldier_militia")
	E:add_comps(tt, "reinforcement", "nav_grid", "tween", "ranged")
	tt.health.armor = 0
	tt.health.hp_max = BASE.hp_max
	tt.health_bar.offset = v(0, 30)
	tt.info.portrait = "kr6_info_portraits_soldiers_0066"
	tt.info.random_name_format = "SOLDIER_MUSKETEERS_%i_NAME"
	tt.info.random_name_count = 8
	tt.render.sprites[1].prefix = "Musketeers_Mosq1"
	tt.render.sprites[1].anchor = v(0.5, 0.5)
	tt.render.sprites[1].angles = {}
	tt.render.sprites[1].angles.walk = {"walk"}
	tt.render.sprites[1].angles.ranged_attack = {"shoot", "shootup", "shootdown"}
	tt.render.sprites[1].angles.special_attack = {"special", "specialup", "specialdown"}
	tt.render.sprites[1].angles_flip_vertical = {
		special_attack = true,
		ranged_attack = true
	}
	tt.render.sprites[1].angles_custom = {
		ranged_attack = {35, 145, 215, 325},
		special_attack = {35, 145, 215, 325}
	}
	tt.render.sprites[1].scale = vv(1.1)
	tt.main_script.insert = scripts.soldier_reinforcement.insert
	tt.melee.range = 50
	tt.melee.attacks[1].cooldown = 1.5
	tt.melee.attacks[1].damage_min = 2
	tt.melee.attacks[1].damage_max = 4
	tt.melee.attacks[1].hit_time = fts(10)
	tt.melee.attacks[1].animation = "melee"
	tt.ranged.attacks[1] = E:clone_c("bullet_attack")
	tt.ranged.attacks[1].animation = "ranged_attack"
	tt.ranged.attacks[1].bullet = "bullet_power_musketeers"
	tt.ranged.attacks[1].cooldown = BASE.attack_cooldown
	tt.ranged.attacks[1].min_range = 20
	tt.ranged.attacks[1].max_range = BASE.range
	tt.ranged.attacks[1].shoot_time = fts(15)
	tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
	tt.ranged.attacks[1].node_prediction = fts(15)
	tt.ranged.attacks[1].bullet_start_offset = {v(14, 7), v(15, 25), v(10, -1)}
	tt.ranged.attacks[1].check_target_before_shot = true
	tt.ranged.attacks[1].side_effect = function(this, store, attack, target)
		if this.casing then
			local casing = E:create_entity(this.casing)

			casing.pos = v(this.pos.x, this.pos.y)
			casing.pos.y = casing.pos.y + U.frandom(-3, 3)
			casing.y_origin = this.pos.y

			if not this.render.sprites[1].flip_x then
				casing.initial_direction_v.x = casing.initial_direction_v.x * -1
			end

			simulation:queue_insert_entity(casing)
		end

		local bt = E:get_template(attack.bullet)

		if bt and bt.bullet.damage_type == DAMAGE_INSTAKILL then
			local mod = E:create_entity(this.instakill_aim)

			mod.render.sprites[1].ts = store.tick_ts
			mod.modifier.target_id = target.id

			simulation:queue_insert_entity(mod)
		end
	end
	tt.motion.max_speed = BASE.max_speed
	tt.regen.cooldown = 1
	tt.reinforcement.duration = BASE.duration
	tt.soldier.melee_slot_offset = v(3, 0)
	tt.sound_events.insert = "PowersMusketeersSummonTaunt"
	tt.sound_events.change_rally_point = "PowersMusketeersMoveTaunt"
	tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
	tt.tween.props[1].name = "alpha"
	tt.tween.remove = false
	tt.tween.reverse = false
	tt.unit.hit_offset = v(0, 5)
	tt.unit.mod_offset = v(0, 14)
	tt.unit.level = 0
	tt.unit.marker_offset = v(0, 0)
	tt.controable = true
	tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE, F_LYCAN)
	tt.vis.flags = bor(F_BLOCK, F_FRIEND)
	tt.ui.click_rect = r(-15, -5, 30, 35)
	tt.ui.click_rect_offset_y = -10
	tt.level = 1
	tt.bullet_basic = "bullet_power_musketeers"
	tt.bullet_l4a = "bullet_power_musketeers_l4a"
	tt.bullet_l5b = "bullet_power_musketeers_l5b"
	tt.bullet_l6 = "bullet_power_musketeers_l6"
	tt.l4a_active = false
	tt.l4b_active = false
	tt.l5b_active = false
	tt.l6_active = false
	tt.instakill_chance = 0.18
	tt.instakill_threshold = 0.25
	tt.instakill_aim = "mod_power_musketeers_instakill_aim"
	tt.casing = "fx_bullet_musketeer_casing"
	tt.casing_spawn_pos = {v(0, 0), v(0, 0), v(0, 0)}
	tt._l6_shot = false

	tt.main_script.update = function(this, store)
		this.reinforcement.ts = store.tick_ts
		this.render.sprites[1].ts = store.tick_ts

		signal.emit("spawned-reinforcement", this)
		SU.y_reinforcement_fade_in(store, this)

		local ra = this.ranged.attacks[1]

		local function y_ranged_attacks(store, this)
			local target, attack, pred_pos = SU.soldier_pick_ranged_target_and_attack(store, this)

			if not target then
				return false, A_NO_TARGET
			end

			if not attack then
				return false, A_IN_COOLDOWN
			end

			local start_ts = store.tick_ts

			U.set_destination(this, this.pos)

			if this.l6_active and not this._l6_shot then
				ra.animation = "special_attack"
				ra.bullet = this.bullet_l6
			elseif this.l4a_active and is_disabled(store, target) then
				ra.bullet = this.bullet_l4a
			elseif this.l5b_active and band(target.vis.flags, F_MINIBOSS) == 0 and band(target.vis.flags, F_BOSS) == 0 and band(target.vis.flags, F_INSTAKILL) == 0 and target.health.hp <= target.health.hp_max * this.instakill_threshold and math.random() <= this.instakill_chance then
				ra.bullet = this.bullet_l5b
			else
				ra.bullet = this.bullet_basic
			end

			local attack_done = SU.y_soldier_do_ranged_attack(store, this, target, attack, pred_pos)

			if attack_done then
				attack.ts = start_ts

				if this.l6_active and not this._l6_shot then
					this._l6_shot = true
					ra.animation = "ranged_attack"
				end

				return false, A_DONE
			end

			return true
		end

		if this.wait_time then
			U.y_wait(store, this.wait_time)
		end

		while true do
			if this.health.dead then
				this.reinforcement.fade = false
				this.reinforcement.fade_out = false
				this.ui.can_click = false

				SU.y_soldier_death(store, this)

				return
			end

			if this.reinforcement.duration and store.tick_ts - this.reinforcement.ts > this.reinforcement.duration then
				if this.health.hp > 0 then
					this.reinforcement.hp_before_timeout = this.health.hp
				end

				this.health.hp = 0
				this.ui.can_click = false

				SU.remove_modifiers(store, this)
				SU.y_soldier_death(store, this)

				return
			end

			if this.unit.is_stunned then
				SU.soldier_idle(store, this)
			else
				while this.nav_rally.new do
					if SU.y_controable_new_rally(store, this) then
						goto label_musketeers_1
					end
				end

				if this.melee then
					local brk, stam = SU.y_soldier_melee_block_and_attacks(store, this)

					if brk or stam == A_DONE or stam == A_IN_COOLDOWN and not this.melee.continue_in_cooldown then
						goto label_musketeers_1
					end
				end

				if this.ranged then
					local brk, star = y_ranged_attacks(store, this)

					if brk or star == A_DONE then
						goto label_musketeers_1
					elseif star == A_IN_COOLDOWN then
						goto label_musketeers_0
					end
				end

				if SU.soldier_go_back_step(store, this) then
					goto label_musketeers_1
				end

				::label_musketeers_0::

				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end

			::label_musketeers_1::

			coroutine.yield()
		end
	end
end

function M.apply(level)
	local E = require("entity_db")
	local ctrl = E:get_template(M.control)
	local tt = E:get_template("soldier_musketeers")
	local basic = E:get_template("bullet_power_musketeers")
	local l4a = E:get_template("bullet_power_musketeers_l4a")

	ctrl.cooldown = BASE.cooldown
	tt.reinforcement.duration = BASE.duration
	tt.ranged.attacks[1].max_range = BASE.range
	tt.ranged.attacks[1].cooldown = BASE.attack_cooldown
	tt.motion.max_speed = BASE.max_speed
	tt.render.sprites[1].prefix = "Musketeers_Mosq1"
	tt.info.portrait = "kr6_info_portraits_soldiers_0066"
	tt.l4a_active = false
	tt.l4b_active = false
	tt.l5b_active = false
	tt.l6_active = false
	basic.bullet.damage_min = BASE.damage_min
	basic.bullet.damage_max = BASE.damage_max
	basic.bullet.reduce_armor = 0
	l4a.bullet.damage_min = BASE.damage_min * 1.35
	l4a.bullet.damage_max = BASE.damage_max * 1.35

	if level >= 2 then
		tt.reinforcement.duration = BASE.duration + 4
		tt.ranged.attacks[1].max_range = BASE.range * 1.2
		tt.motion.max_speed = BASE.max_speed * 1.2
	end

	if level >= 3 then
		tt.render.sprites[1].prefix = "Musketeers_Mosq2"
		tt.info.portrait = "kr6_info_portraits_soldiers_0067"
		tt.ranged.attacks[1].cooldown = 1.3
		basic.bullet.damage_min = BASE.damage_min * 1.5
		basic.bullet.damage_max = BASE.damage_max * 1.5
		l4a.bullet.damage_min = BASE.damage_min * 1.35 * 1.5
		l4a.bullet.damage_max = BASE.damage_max * 1.35 * 1.5
	end

	if level >= 4 then
		tt.l4a_active = true
		tt.l4b_active = true
		basic.bullet.reduce_armor = 0.5
	end

	if level >= 5 then
		ctrl.cooldown = 18
		tt.ranged.attacks[1].cooldown = 1.25
		tt.l5b_active = true
	end

	if level >= 6 then
		tt.render.sprites[1].prefix = "Musketeers_Mosq3"
		tt.info.portrait = "kr6_info_portraits_soldiers_0068"
		tt.l6_active = true
	end
end

return M
