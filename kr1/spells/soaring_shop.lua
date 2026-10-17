local M = {}

M.id = "soaring_shop"
M.i18n = "POWER_SOARING_SHOP"
M.control = "power_soaring_shop_control"
M.button_icon = "in_game_icon_power_soaring_shop"
M.pointer_icon = "pointer_power_soaring_shop"
M.portrait = "power_portraits_big_soaring_shop"
M.name_style = {
	font_name = "h",
	font_size = 30,
	color = {255, 214, 140, 255},
	shaders = {"p_outline", "p_glow"},
	shader_args = {{
		thickness = 3,
		outline_color = {0.32, 0.15, 0.05, 1}
	}, {
		thickness = 2,
		glow_color = {0.92, 0.60, 0.20, 0.7}
	}},
	shader_margin = 16
}
M.required_textures = {"go_power_soaring_shop"}
M.plugin_required_textures = {}
M.required_sounds = {"spell_soaring_shop"}
M.plugin_required_sounds = {}
M.required_exoskeletons = {"spell_shop_lvl1Def", "spell_shop_lvl3Def", "spell_shop_lvl6Def"}
M.plugin_required_exoskeletons = {}

function M.register_templates(E)
	local V = require("lib.klua.vector")
	local v = V.v
	local vv = V.vv
	local r = V.r
	local bit = require("bit")
	local bor = bit.bor
	local U = require("utils")
	local SU = require("script_utils")
	local GR = require("grid_db")
	local P = require("path_db")
	local signal = require("lib.hump.signal")
	local scripts = require("game_scripts")

	require("lib.klua.table")

	local function fts(x)
		return x / FPS
	end

	local tt

	tt = E:register_t_tmp(M.control, "power_control_custom")
	tt.main_script.insert = function(this, store)
		local e = E:create_entity("soldier_soaring_shop")

		e.pos = v(this.pos.x, this.pos.y)
		e.nav_rally.center = v(this.pos.x, this.pos.y)
		e.nav_rally.pos = V.vclone(e.pos)

		simulation:queue_insert_entity(e)

		return true
	end
	tt.main_script.update = function(this, store)
		coroutine.yield()
		simulation:queue_remove_entity(this)
	end
	tt.user_selection.can_select_point_fn = function(this, x, y, store)
		return GR:cell_is(x, y, bor(TERRAIN_LAND, TERRAIN_ICE)) and not GR:cell_is(x, y, bor(TERRAIN_NOWALK)) and P:valid_node_nearby(x, y, nil, NF_RALLY)
	end
	tt.cooldown = 50

	E:set_template("user_power_3", tt)

	tt = E:register_t_tmp("bullet_power_soaring_shop_attack_1", "bomb")
	tt.render.sprites[1].name = "power_globo_FX_attack_projectile"
	tt.bullet.min_speed = 5 * FPS
	tt.bullet.max_speed = 15 * FPS
	tt.bullet.acceleration_factor = 0.2
	tt.bullet.hit_fx = "fx_power_soaring_shop_attack_1_hit"
	tt.bullet.hit_decal = "decal_power_soaring_shop_attack_1_crack"
	tt.bullet.damage_type = DAMAGE_EXPLOSION
	tt.bullet.damage_radius = 50
	tt.bullet.damage_min = 15
	tt.bullet.damage_max = 25
	tt.bullet.flight_time = fts(15)
	tt.bullet.align_with_trajectory = true
	tt.bullet.damage_flags = bor(F_AREA)
	tt.bullet.damage_bans = 0
	tt.sound_events.insert = nil
	tt.sound_events.hit = "PowersSoaringShopBasicAttack"

	tt = E:register_t_tmp("bullet_power_soaring_shop_special_1", "bullet_power_soaring_shop_attack_1")
	tt.render.sprites[1].name = "power_globo_FX_attack_special_projectile1"

	tt = E:register_t_tmp("bullet_power_soaring_shop_special_2", "bullet_power_soaring_shop_attack_1")
	tt.render.sprites[1].name = "power_globo_FX_attack_special_projectile2"

	tt = E:register_t_tmp("bullet_power_soaring_shop_attack_2", "bullet_power_soaring_shop_attack_1")
	tt.render.sprites[1].name = "power_globo_FX_attack2_projectile"
	tt.bullet.hit_fx = "fx_power_soaring_shop_attack_2_hit"
	tt.bullet.mod = "mod_power_soaring_shop_stun"
	tt.bullet.damage_type = DAMAGE_EXPLOSION
	tt.bullet.damage_radius = 75
	tt.bullet.damage_min = 10
	tt.bullet.damage_max = 20
	tt.sound_events.hit = "PowersSoaringShopFrozotov"
	tt.bullet.damage_bans = bor(F_FLYING)

	tt = E:register_t_tmp("bullet_power_soaring_shop_attack_3", "bullet_power_soaring_shop_attack_1")
	tt.render.sprites[1].name = "power_globo_FX_attack3_projectile"
	tt.bullet.hit_fx = "fx_power_soaring_shop_attack_3_hit"
	tt.bullet.hit_decal = "decal_power_soaring_shop_attack_3_crack"
	tt.bullet.ignore_rotation = true
	tt.bullet.damage_type = DAMAGE_EXPLOSION
	tt.bullet.damage_radius = 90
	tt.bullet.damage_min = 100
	tt.bullet.damage_max = 300
	tt.bullet.align_with_trajectory = false
	tt.bullet.rotation_speed = nil
	tt.bullet.flight_time = fts(30)
	tt.sound_events.insert = "PowersSoaringShopFatBoy"

	tt = E:register_t_tmp("fx_power_soaring_shop_attack_1_hit", "fx")
	tt.render.sprites[1].name = "hit"
	tt.render.sprites[1].prefix = "power_globo_FX_attack_hit"
	tt.render.sprites[1].z = Z_OBJECTS
	tt.render.sprites[1].sort_y_offset = -1

	tt = E:register_t_tmp("fx_power_soaring_shop_attack_2_hit", "fx")
	tt.render.sprites[1].name = "hit"
	tt.render.sprites[1].prefix = "power_globo_FX_attack2_hit"
	tt.render.sprites[1].z = Z_OBJECTS
	tt.render.sprites[1].sort_y_offset = -1

	tt = E:register_t_tmp("fx_power_soaring_shop_attack_3_hit", "fx")
	tt.render.sprites[1].name = "hit"
	tt.render.sprites[1].prefix = "power_globo_FX_attack3_hit"
	tt.render.sprites[1].z = Z_OBJECTS
	tt.render.sprites[1].sort_y_offset = -1

	tt = E:register_t_tmp("decal_power_soaring_shop_attack_1_crack", "decal_tween")
	tt.render.sprites[1].name = "power_globo_FX_attack_decal"
	tt.render.sprites[1].animated = false
	tt.tween.props[1].keys = {{1, 255}, {2.5, 0}}

	tt = E:register_t_tmp("decal_power_soaring_shop_attack_3_crack", "decal_tween")
	tt.render.sprites[1].name = "power_globo_FX_attack3_decal"
	tt.render.sprites[1].animated = false
	tt.tween.props[1].keys = {{1, 255}, {2.5, 0}}

	tt = E:register_t_tmp("mod_power_soaring_shop_stun", "mod_stun")
	E:add_comps(tt, "render")
	tt.modifier.vis_flags = bor(F_MOD, F_STUN)
	tt.modifier.duration = 1.5
	tt.modifier.use_mod_offset = false
	tt.modifier.animation_phases = true
	tt.render.sprites[1].prefix = "power_globo_FX_attack2_stun"
	tt.render.sprites[1].sort_y_offset = -1

	tt = E:register_t_tmp("controller_soaring_shop_float_anim")
	E:add_comps(tt, "main_script")
	tt.main_script.insert = function(this, store)
		return true
	end
	tt.main_script.update = function(this, store)
		while true do
			if not this.moving then
				this.sprite.offset = v(V.add(this.sprite.offset.x, this.sprite.offset.y, 0, this.speed))

				if this.sprite.offset.y - this.flight_height <= this.min_y or this.sprite.offset.y - this.flight_height >= this.max_y then
					this.speed = this.speed * -1
				end
			end

			coroutine.yield()
		end
	end
	tt.min_y = -5
	tt.max_y = 5
	tt.speed = 0.2

	tt = E:register_t_tmp("soldier_soaring_shop", "soldier_militia")

	E:add_comps(tt, "reinforcement", "nav_grid", "ranged", "timed_attacks")

	tt.info.fn = scripts.soldier_reinforcement.get_info
	tt.info.portrait = "kr6_info_portraits_soldiers_0048"
	tt.info.i18n_key = "POWER_SOARING_SHOP"
	tt.stats = {
		hp = 10,
		hp_max = 10,
		damage_min = 15,
		damage_max = 25,
		armor = 1,
		respawn = 50
	}
	tt.main_script.insert = scripts.soldier_reinforcement.insert
	tt.main_script.update = function(this, store)
		this.ts = store.tick_ts
		this.reinforcement.ts = store.tick_ts
		this.render.sprites[1].ts = store.tick_ts

		local attack = this.ranged.attacks[1]
		local attack2 = this.timed_attacks.list[1]
		local attack3 = this.timed_attacks.list[2]

		attack.ts = store.tick_ts - attack.cooldown
		attack2.ts = store.tick_ts - attack2.cooldown
		attack3.ts = store.tick_ts

		local basic_flight_time = E:get_template(this.attack_bullets.attack).bullet.flight_time + attack.prediction
		local attack_3_flight_time = E:get_template(attack3.bullet).bullet.flight_time + attack3.prediction
		local attacks = 1

		local function get_attack_bullet_and_anim()
			if attacks % this.special_1_rate == 0 then
				return this.attack_bullets.attack_special_1, "attack_special_1"
			elseif attacks % this.special_2_rate == 0 then
				return this.attack_bullets.attack_special_2, "attack_special_2"
			else
				return this.attack_bullets.attack, "attack"
			end
		end

		local s = this.render.sprites[1]

		s.offset = v(s.offset.x, s.offset.y + this.spawn_flight_height)

		U.animation_start(this, "in", nil, store.tick_ts, false, 1)

		while not U.animation_finished(this, 1) do
			s.offset = v(s.offset.x, s.offset.y - this.spawn_speed)

			coroutine.yield()
		end

		U.animation_start(this, "idle", nil, store.tick_ts, true, 1)

		this.controller = E:create_entity(this.controller_float_anim)
		this.controller.sprite = s
		this.controller.flight_height = this.flight_height

		simulation:queue_insert_entity(this.controller)

		while true do
			if this.reinforcement.duration and store.tick_ts - this.ts > this.reinforcement.duration then
				this.health.dead = true

				U.animation_start(this, "out", nil, store.tick_ts, false, 1)

				while not U.animation_finished(this, 1) do
					s.offset = v(s.offset.x, s.offset.y + this.spawn_speed)

					coroutine.yield()
				end

				simulation:queue_remove_entity(this)

				return
			end

			while this.nav_rally.new do
				if this.controller then
					this.controller.moving = true
				end

				if SU.y_hero_new_rally(store, this) then
					break
				end
			end

			if this.controller then
				this.controller.moving = false
			end

			if not attack3.disabled and not this.nav_rally.new and store.tick_ts - attack3.ts > attack3.cooldown then
				local enemy, enemies, enemy_pos = U.find_foremost_enemy(store, this.pos, 0, attack3.range, attack_3_flight_time, attack.vis_flags, attack.vis_bans)

				if enemy and not enemy.health.dead then
					s.flip_x = enemy.pos.x < this.pos.x

					local flip = s.flip_x and -1 or 1

					U.animation_start(this, "attack_3", nil, store.tick_ts, false, 1)
					U.y_wait(store, attack3.hit_time)

					local b = E:create_entity(attack3.bullet)

					b.pos.x, b.pos.y = this.pos.x + attack3.offset.x * flip, this.pos.y + attack3.offset.y
					b.bullet.from = V.vclone(b.pos)
					b.bullet.to = V.vclone(enemy_pos)
					b.bullet.target_id = enemy.id
					b.bullet.source_id = this.id
					b.render.sprites[1].flip_x = s.flip_x

					simulation:queue_insert_entity(b)

					while not U.animation_finished(this, 1) do
						coroutine.yield()
					end

					attack3.ts = store.tick_ts
				end
			end

			if not attack2.disabled and not this.nav_rally.new and store.tick_ts - attack2.ts > attack2.cooldown then
				local enemy, enemies, enemy_pos = U.find_foremost_enemy(store, this.pos, 0, attack.range, basic_flight_time, attack.vis_flags, attack.vis_bans)

				if enemy and not enemy.health.dead then
					U.animation_start(this, "attack_2", nil, store.tick_ts, false, 1)

					for i = 0, #attack2.hit_times - 1 do
						U.y_wait(store, attack2.hit_times[i + 1])

						if P:is_node_valid(enemy.nav_path.pi, enemy.nav_path.ni - i * 10) then
							local e_pos = P:node_pos(enemy.nav_path.pi, enemy.nav_path.spi, enemy.nav_path.ni - i * 10)

							s.flip_x = e_pos.x < this.pos.x

							local flip = s.flip_x and -1 or 1
							local b = E:create_entity(attack2.bullet)

							b.pos.x, b.pos.y = this.pos.x + attack.offset.x * flip, this.pos.y + s.offset.y
							b.bullet.from = V.vclone(b.pos)
							b.bullet.to = V.vclone(e_pos)
							b.bullet.target_id = enemy.id
							b.bullet.source_id = this.id

							simulation:queue_insert_entity(b)
						end
					end

					while not U.animation_finished(this, 1) do
						coroutine.yield()
					end

					attack2.ts = store.tick_ts
				end
			end

			if not this.nav_rally.new and store.tick_ts - attack.ts > attack.cooldown then
				local enemy, enemies, enemy_pos = U.find_foremost_enemy(store, this.pos, 0, attack.range, basic_flight_time, attack.vis_flags, attack.vis_bans)

				if enemy and not enemy.health.dead then
					s.flip_x = enemy.pos.x < this.pos.x

					local bullet, anim = get_attack_bullet_and_anim()
					local flip = s.flip_x and -1 or 1

					attacks = attacks + 1

					U.animation_start(this, anim, nil, store.tick_ts, false, 1)
					U.y_wait(store, attack.hit_time)

					local b = E:create_entity(bullet)

					b.pos.x, b.pos.y = this.pos.x + attack.offset.x * flip, this.pos.y + s.offset.y
					b.bullet.from = V.vclone(b.pos)
					b.bullet.to = V.vclone(enemy_pos)
					b.bullet.target_id = enemy.id
					b.bullet.source_id = this.id

					simulation:queue_insert_entity(b)

					while not U.animation_finished(this, 1) do
						coroutine.yield()
					end

					attack.ts = store.tick_ts
				end
			end

			SU.soldier_idle(store, this)
			coroutine.yield()
		end
	end
	tt.main_script.remove = function(this, store)
		if this.controller and store.entities[this.controller.id] then
			simulation:queue_remove_entity(this.controller)
		end

		if game.game_gui.selected_entity and game.game_gui.selected_entity.id == this.id then
			signal.emit("hide-bottom-info")
		end

		return true
	end
	tt.motion.max_speed = 64
	tt.reinforcement.duration = 20
	tt.health_bar = nil
	tt.flight_height = 130
	tt.spawn_flight_height = 8.1
	tt.spawn_speed = 0.2
	tt.nav_rally.requires_node_nearby = false
	tt.nav_grid.ignore_waypoints = true
	tt.nav_grid.valid_terrains = bor(TERRAIN_NONE, TERRAIN_LAND, TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK, TERRAIN_SHALLOW, TERRAIN_FAERIE, TERRAIN_ICE)
	tt.nav_grid.valid_terrains_dest = tt.nav_grid.valid_terrains
	tt.drag_line_origin_offset = v(0, tt.flight_height - 40)
	tt.render.sprites[1].prefix = "spell_shop_lvl1Def"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].offset.y = tt.flight_height
	tt.render.sprites[1].angles = {}
	tt.render.sprites[1].angles.walk = {"walk"}
	tt.render.sprites[1].z = Z_FLYING_HEROES
	tt.render.sprites[2] = E:clone_c("sprite")
	tt.render.sprites[2].name = "decal_flying_shadow"
	tt.render.sprites[2].animated = false
	tt.render.sprites[2].offset = v(0, 0)
	tt.render.sprites[2].scale = vv(4.5)
	tt.render.sprites[2].z = Z_DECALS + 1
	tt.render.sid_shadow = 2
	tt.sound_events.insert = {"PowersSoaringShopSummon", "PowersSoaringShopSummonTaunt"}
	tt.sound_events.change_rally_point = "PowersSoaringShopMoveTaunt"
	tt.ranged.attacks[1].cooldown = 0.64
	tt.ranged.attacks[1].damage_min = 15
	tt.ranged.attacks[1].damage_max = 25
	tt.ranged.attacks[1].damage_type = DAMAGE_EXPLOSION
	tt.ranged.attacks[1].hit_fx = "fx_soldier_reinforcement_lvl3"
	tt.ranged.attacks[1].hit_time = fts(22)
	tt.ranged.attacks[1].range = 200
	tt.ranged.attacks[1].offset = v(20, tt.flight_height)
	tt.ranged.attacks[1].prediction = fts(10)
	tt.ranged.attacks[1].vis_bans = F_FLYING
	tt.attack_bullets = {
		attack = "bullet_power_soaring_shop_attack_1",
		attack_special_2 = "bullet_power_soaring_shop_special_2",
		attack_special_1 = "bullet_power_soaring_shop_special_1"
	}
	tt.special_1_rate = 3
	tt.special_2_rate = 5
	tt.timed_attacks.list[1] = E:clone_c("custom_attack")
	tt.timed_attacks.list[1].cooldown = 20
	tt.timed_attacks.list[1].bullet = "bullet_power_soaring_shop_attack_2"
	tt.timed_attacks.list[1].range = 200
	tt.timed_attacks.list[1].hit_times = {fts(24), fts(8), fts(8)}
	tt.timed_attacks.list[1].disabled = true
	tt.timed_attacks.list[1].vis_bans = F_FLYING
	tt.timed_attacks.list[2] = E:clone_c("custom_attack")
	tt.timed_attacks.list[2].cooldown = 10
	tt.timed_attacks.list[2].bullet = "bullet_power_soaring_shop_attack_3"
	tt.timed_attacks.list[2].offset = v(15, tt.flight_height - 70)
	tt.timed_attacks.list[2].hit_time = fts(8)
	tt.timed_attacks.list[2].range = 60
	tt.timed_attacks.list[2].disabled = true
	tt.timed_attacks.list[2].prediction = fts(6)
	tt.timed_attacks.list[2].vis_bans = F_FLYING
	tt.ui.click_rect = r(-30, tt.flight_height - 50, 60, 100)
	tt.ui.click_rect_offset_y = -10
	tt.unit.marker_offset = v(0, 0)
	tt.vis.bans = F_ALL
	tt.controller_float_anim = "controller_soaring_shop_float_anim"
end

function M.apply(level)
	local E = require("entity_db")
	local ctrl = E:get_template(M.control)
	local soldier = E:get_template("soldier_soaring_shop")

	local bullet_names = {"bullet_power_soaring_shop_attack_1", "bullet_power_soaring_shop_attack_2", "bullet_power_soaring_shop_attack_3", "bullet_power_soaring_shop_special_1", "bullet_power_soaring_shop_special_2"}
	local base_radius = {50, 75, 90, 50, 50}
	local base_damage_min = {15, 10, 100, 15, 15}
	local base_damage_max = {25, 20, 300, 25, 25}
	local radius_factor = level >= 2 and 1.2 or 1
	local damage_factor = level >= 4 and 1.1 or 1

	for i = 1, #bullet_names do
		local bt = E:get_template(bullet_names[i])

		bt.bullet.damage_radius = base_radius[i] * radius_factor
		bt.bullet.damage_min = base_damage_min[i] * damage_factor
		bt.bullet.damage_max = base_damage_max[i] * damage_factor
	end

	ctrl.cooldown = level >= 2 and 40 or 50

	soldier.reinforcement.duration = level >= 5 and 24 or 20
	soldier.ranged.attacks[1].cooldown = level >= 5 and 0.14 or 0.64
	soldier.timed_attacks.list[1].disabled = level < 3
	soldier.timed_attacks.list[1].cooldown = level >= 4 and 15 or 20
	soldier.timed_attacks.list[2].disabled = level < 6

	if level >= 6 then
		soldier.render.sprites[1].prefix = "spell_shop_lvl6Def"
		soldier.info.portrait = "kr6_info_portraits_soldiers_0050"
	elseif level >= 3 then
		soldier.render.sprites[1].prefix = "spell_shop_lvl3Def"
		soldier.info.portrait = "kr6_info_portraits_soldiers_0049"
	else
		soldier.render.sprites[1].prefix = "spell_shop_lvl1Def"
		soldier.info.portrait = "kr6_info_portraits_soldiers_0048"
	end
end

return M
