local M = {}

M.id = "reinforcements_kr6"
M.i18n = "POWER_REINFORCEMENTS_KR6"
M.control = "power_reinforcements_control_kr6"
M.button_icon = "in_game_icon_power_reinforcements"
M.pointer_icon = "pointer_power_reinforcements"
M.portrait = "power_portraits_big_reinforcements"
M.name_style = {
	font_name = "h",
	font_size = 30,
	color = {255, 255, 255, 255},
	shaders = {"p_outline", "p_glow"},
	shader_margin = 16
}
M.required_textures = {"go_power_reinforcements"}
M.plugin_required_textures = {}
M.required_sounds = {}
M.plugin_required_sounds = {}
M.required_exoskeletons = {}
M.plugin_required_exoskeletons = {}

function M.register_templates(E)
	local V = require("lib.klua.vector")
	local v = V.v
	local vv = V.vv
	local r = V.r
	local bor = require("bit").bor
	local U = require("utils")
	local S = require("sound_db")
	local SU = require("script_utils")
	local GR = require("grid_db")
	local P = require("path_db")
	local signal = require("lib.hump.signal")
	local scripts = require("game_scripts")

	local function fts(x)
		return x / FPS
	end

	local function soldier_update(this, store)
		local brk, stam, star

		this.reinforcement.ts = store.tick_ts
		this.render.sprites[1].ts = store.tick_ts

		signal.emit("spawned-reinforcement", this)

		if this.render.sprites[1].name == "in" then
			if this.sound_events and this.sound_events.raise then
				S:queue(this.sound_events.raise)
			end

			this.health_bar.hidden = true

			U.y_animation_play(this, "in", nil, store.tick_ts, 1)

			if not this.health.dead then
				this.health_bar.hidden = nil
			end
		elseif this.reinforcement.fade or this.reinforcement.fade_in then
			SU.y_reinforcement_fade_in(store, this)
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
						goto label_rally
					end
				end

				if this.dodge and this.dodge.active then
					this.dodge.active = false

					if this.dodge.animation then
						U.animation_start(this, this.dodge.animation, nil, store.tick_ts, false)

						while not U.animation_finished(this) do
							coroutine.yield()
						end
					end

					signal.emit("soldier-dodge", this)
				end

				if this.melee then
					brk, stam = SU.y_soldier_melee_block_and_attacks(store, this)

					if brk or stam == A_DONE or stam == A_IN_COOLDOWN and not this.melee.continue_in_cooldown then
						goto label_rally
					end
				end

				if this.ranged then
					brk, star = SU.y_soldier_ranged_attacks(store, this)

					if brk or star == A_DONE then
						goto label_rally
					elseif star == A_IN_COOLDOWN then
						goto label_idle
					end
				end

				if this.melee.continue_in_cooldown and stam == A_IN_COOLDOWN then
					goto label_rally
				end

				if SU.soldier_go_back_step(store, this) then
					goto label_rally
				end

				::label_idle::

				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end

			::label_rally::

			coroutine.yield()
		end
	end

	local tt

	tt = E:register_t(M.control, "power_control_custom")
	tt.main_script.insert = function(this, store)
		local function set_name_if_female(variant, e)
			if e.level == 1 and variant == 1 or (e.level == 2 or e.level == 3) and variant == 2 then
				e.info.random_name_format = "SOLDIER_REINFORCEMENTS_F_%i_NAME"
				e.info.random_name_count = 4
			end
		end

		local x, y = this.pos.x, this.pos.y
		local spawned_special = false
		local special_spawn_radius = 30
		local special_angle_offset = 15

		if this.upgrade_special_unit then
			local e = E:create_entity("soldier_reinforcement_special_kr6")
			local spawn_pos = U.point_on_ellipse(V.v(x, y), special_spawn_radius, -math.pi / 2 + special_angle_offset)

			e.pos = V.vclone(spawn_pos)
			e.nav_rally.center = V.v(x, y)
			e.nav_rally.pos = V.vclone(e.pos)
			e.reinforcement.squad_id = this.id

			simulation:queue_insert_entity(e)

			spawned_special = true
		end

		local variants = 3

		for j = 1, 2 do
			local i = math.random(1, variants)
			local e = E:create_entity("re_current_kr6")

			e.render.sprites[1].prefix = e.render.sprites[1].prefix .. i

			if spawned_special then
				local a = 2 * math.pi / 3
				local spawn_pos = U.point_on_ellipse(V.v(x, y), special_spawn_radius, (j == 1 and 1 or 2) * a - math.pi / 2 + special_angle_offset)

				e.pos = V.vclone(spawn_pos)
			else
				e.pos.x = j == 1 and x + 10 or x - 10
				e.pos.y = j == 1 and y - 10 or y + 10
			end

			e.info.portrait = string.format("kr6_info_portraits_soldiers_%04i", (e.level - 1) * #e.portrait_idxs + e.portrait_idxs[i])

			set_name_if_female(i, e)

			e.nav_rally.center = V.v(x, y)
			e.nav_rally.pos = V.vclone(e.pos)
			e.reinforcement.squad_id = this.id

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
	tt.cooldown = 15
	tt.upgrade_special_unit = false

	E:set_template("user_power_3", tt)

	tt = E:register_t("soldier_reinforcement_base_kr6", "soldier_militia")

	E:add_comps(tt, "reinforcement", "nav_grid", "tween")
	tt.controable = true
	tt.cooldown = 15
	tt.health.armor = 0
	tt.health.hp_max = 40
	tt.health.spiked_armor = 0
	tt.health_bar.offset = v(0, 30)
	tt.info.fn = scripts.soldier_reinforcement.get_info
	tt.info.random_name_format = "SOLDIER_REINFORCEMENTS_M_%i_NAME"
	tt.info.random_name_count = 6
	tt.main_script.insert = scripts.soldier_reinforcement.insert
	tt.main_script.update = soldier_update
	tt.melee.attacks[1].cooldown = 1
	tt.melee.attacks[1].damage_min = 2
	tt.melee.attacks[1].damage_max = 4
	tt.melee.attacks[1].hit_fx = "fx_soldier_reinforcement_lvl3_kr6"
	tt.melee.attacks[1].hit_time = fts(11)
	tt.melee.attacks[1].hit_offset = v(30, 10)
	tt.melee.range = 72
	tt.motion.max_speed = 64
	tt.regen.cooldown = 1
	tt.regen.health = 8
	tt.reinforcement.duration = 12
	tt.render.sprites[1].anchor = v(0.5, 0.5)
	tt.render.sprites[1].angles = {}
	tt.render.sprites[1].angles.walk = {"walk"}
	tt.render.sprites[1].scale = vv(1)
	tt.render.sprites[1].prefix = "denas_reinforcements_lvl1_"
	tt.render.sprites[1].name = "idle"
	tt.soldier.melee_slot_offset = v(3, 0)
	tt.sound_events.insert = "ReinforcementTaunt"
	tt.sound_events.change_rally_point = tt.sound_events.insert
	tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
	tt.tween.props[1].name = "alpha"
	tt.tween.remove = false
	tt.tween.reverse = false
	tt.unit.hit_offset = v(0, 5)
	tt.unit.mod_offset = v(0, 14)
	tt.unit.level = 0
	tt.unit.damage_factor = 1
	tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE, F_LYCAN)
	tt.vis.flags = bor(F_BLOCK, F_FRIEND)
	tt.ui.click_rect = r(-15, -5, 30, 35)
	tt.ui.click_rect_offset_y = -10
	tt.unit.marker_offset = v(0, 0)
	tt.level = 1
	tt.portrait_idxs = {1, 2, 3}

	E:set_template("re_current_kr6", tt)

	tt = E:register_t("soldier_reinforcement_special_kr6", "soldier_militia")

	E:add_comps(tt, "reinforcement", "nav_grid", "tween")
	tt.controable = true
	tt.health.armor = 0.4
	tt.health.hp_max = 140
	tt.health.spiked_armor = 0
	tt.health_bar.offset = v(3, 52)
	tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_MEDIUM
	tt.info.fn = scripts.soldier_reinforcement.get_info
	tt.info.portrait = "kr6_info_portraits_soldiers_0010"
	tt.info.random_name_format = "SOLDIER_REINFORCEMENTS_SPECIAL_LINIREA_%i_NAME"
	tt.info.random_name_count = 1
	tt.main_script.insert = scripts.soldier_reinforcement.insert
	tt.main_script.update = function(this, store)
		local e = E:create_entity(this.aura_in_t)

		e.render.sprites[1].ts = store.tick_ts
		e.pos.x, e.pos.y = this.pos.x, this.pos.y

		simulation:queue_insert_entity(e)

		e = E:create_entity(this.aura_buff_t)
		e.aura.source_id = this.id

		simulation:queue_insert_entity(e)
		soldier_update(this, store)
	end
	tt.melee.attacks[1].cooldown = 1
	tt.melee.attacks[1].damage_min = 10
	tt.melee.attacks[1].damage_max = 14
	tt.melee.attacks[1].loops = 1
	tt.melee.attacks[1].animations = {"attack_in", "attack_loop", "attack_out"}
	tt.melee.attacks[1].hit_time = fts(9)
	tt.melee.attacks[1].hit_fx = "fx_soldier_reinforcement_lvl3_kr6"
	tt.melee.attacks[1].hit_offset = v(45, 10)
	tt.melee.range = 72
	tt.motion.max_speed = 64
	tt.regen.cooldown = 1
	tt.regen.health = 11
	tt.reinforcement.duration = 12
	tt.render.sprites[1].prefix = "denas_reinforcements_lvl3_special_unit"
	tt.render.sprites[1].name = "in"
	tt.render.sprites[1].scale = vv(0.9)
	tt.render.sprites[1].anchor = v(0.5, 0.5)
	tt.render.sprites[1].angles = {}
	tt.render.sprites[1].angles.walk = {"walk"}
	tt.soldier.melee_slot_offset = v(18, 0)
	tt.sound_events.change_rally_point = tt.sound_events.insert
	tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
	tt.tween.props[1].name = "alpha"
	tt.tween.remove = false
	tt.tween.reverse = false
	tt.tween.disabled = true
	tt.unit.hit_offset = v(0, 5)
	tt.unit.mod_offset = v(0, 14)
	tt.unit.level = 0
	tt.unit.damage_factor = 1
	tt.unit.size = UNIT_SIZE_MEDIUM
	tt.vis.bans = bor(F_LYCAN)
	tt.vis.flags = bor(F_BLOCK, F_FRIEND)
	tt.aura_in_t = "decal_power_reinforcements_special_kr6"
	tt.aura_buff_t = "aura_power_reinforcement_special_kr6"

	tt = E:register_t("fx_soldier_reinforcement_lvl3_kr6", "fx")
	tt.render.sprites[1].prefix = "denas_reinforcements_lvl3_hit"
	tt.render.sprites[1].name = "hit"

	tt = E:register_t("decal_power_reinforcements_special_kr6", "decal_timed")
	tt.render.sprites[1].prefix = "denas_reinforcements_lvl3_in"
	tt.render.sprites[1].name = "decal"
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].z = Z_DECALS

	tt = E:register_t("aura_power_reinforcement_special_kr6", "aura")
	tt.aura.mods = {"mod_reinforcement_special_damage_kr6", "mod_reinforcement_special_armor_kr6"}
	tt.aura.cycle_time = 0.2
	tt.aura.duration = 0.2
	tt.aura.requires_alive_source = true
	tt.aura.radius = 70
	tt.aura.track_source = true
	tt.aura.track_dead = true
	tt.aura.vis_bans = bor(F_ENEMY)
	tt.aura.vis_flags = F_MOD
	tt.aura.use_mod_offset = false
	tt.main_script.insert = scripts.aura_apply_mod.insert
	tt.main_script.update = scripts.aura_apply_mod.update

	tt = E:register_t("mod_reinforcement_special_damage_kr6", "modifier")
	tt.modifier.duration = 12
	tt.modifier.vis_flags = bor(F_MOD)
	tt.modifier.use_mod_offset = false
	tt.inflicted_damage_factor = 1.1
	tt.main_script.insert = scripts.mod_damage_factors.insert
	tt.main_script.remove = scripts.mod_damage_factors.remove
	tt.main_script.update = scripts.mod_track_target.update

	tt = E:register_t("mod_reinforcement_special_armor_kr6", "modifier")
	E:add_comps(tt, "render", "armor_buff", "tween")
	tt.modifier.duration = 12
	tt.modifier.vis_flags = bor(F_MOD)
	tt.modifier.use_mod_offset = false
	tt.armor_buff.max_factor = 0.15
	tt.armor_buff.cycle_time = 1e99
	tt.main_script.insert = function(this, store)
		if not scripts.mod_armor_buff.insert(this, store) then
			return false
		end

		this.render.sprites[1].ts = store.tick_ts

		return true
	end
	tt.main_script.update = scripts.mod_track_target.update
	tt.main_script.remove = scripts.mod_armor_buff.remove
	tt.render.sprites[1].prefix = "denas_reinforcements_lvl3"
	tt.render.sprites[1].name = "buff_decal"
	tt.render.sprites[1].z = Z_DECALS
	tt.render.sprites[1].animated = true
	tt.tween.props[1].keys = {{0, 0}, {1, 255}}
	tt.tween.props[1].name = "alpha"
	tt.tween.remove = false
	tt.tween.reverse = false
	tt.tween.run_once = true
end

function M.apply(level)
	local E = require("entity_db")
	local V = require("lib.klua.vector")
	local U = require("utils")
	local ctrl = E:get_template(M.control)
	local normal = E:get_template("soldier_reinforcement_base_kr6")
	local special = E:get_template("soldier_reinforcement_special_kr6")
	local aura = E:get_template("aura_power_reinforcement_special_kr6")
	local mod_damage = E:get_template("mod_reinforcement_special_damage_kr6")
	local mod_armor = E:get_template("mod_reinforcement_special_armor_kr6")

	ctrl.cooldown = 15
	ctrl.upgrade_special_unit = level >= 6

	normal.health.hp_max = 40
	normal.health.armor = 0
	normal.health.spiked_armor = 0
	U.update_max_speed(normal, 64)
	normal.unit.damage_factor = 1
	normal.reinforcement.duration = 12
	normal.level = 1
	normal.render.sprites[1].prefix = "denas_reinforcements_lvl1_"
	normal.render.sprites[1].scale = V.vv(1)

	special.health.hp_max = 140
	special.health.armor = 0.4
	special.health.spiked_armor = 0
	U.update_max_speed(special, 64)
	special.unit.damage_factor = 1
	special.reinforcement.duration = 12

	aura.aura.duration = 0.2

	mod_damage.modifier.duration = 12
	mod_damage.inflicted_damage_factor = 1.1

	mod_armor.modifier.duration = 12
	mod_armor.armor_buff.max_factor = 0.15

	if level >= 2 then
		normal.reinforcement.duration = 17
		normal.unit.damage_factor = 1.5
		special.reinforcement.duration = 17
		special.unit.damage_factor = 1.5
		aura.aura.duration = 5.2
	end

	if level >= 3 then
		normal.health.hp_max = 46
		normal.health.armor = 0.4
		normal.level = 2
		normal.render.sprites[1].prefix = "denas_reinforcements_lvl2_"
	end

	if level >= 4 then
		ctrl.cooldown = 12
		U.update_max_speed(normal, 76.8)
		normal.health.armor = 0.55
		U.update_max_speed(special, 76.8)
		special.health.armor = 0.55
	end

	if level >= 5 then
		normal.health.hp_max = 52.9
		normal.health.spiked_armor = 0.2
		normal.unit.damage_factor = 2.25
		normal.level = 3
		normal.render.sprites[1].prefix = "denas_reinforcements_lvl3_"
		normal.render.sprites[1].scale = V.vv(0.9)
		special.health.hp_max = 161
		special.health.spiked_armor = 0.2
		special.unit.damage_factor = 2.25
	end
end

return M
