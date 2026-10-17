local M = {}

M.id = "teleportation_sigil"
M.i18n = "POWER_TELEPORTATION_SIGIL"
M.control = "power_teleportation_sigil_control"
M.button_icon = "in_game_icon_power_teleportation_sigil"
M.pointer_icon = "pointer_power_teleportation_sigil"
M.portrait = "power_portraits_big_teleportation_sigil"
M.name_style = {
	font_name = "h",
	font_size = 30,
	color = {206, 180, 255, 255},
	shaders = {"p_outline", "p_glow"},
	shader_args = {{
		thickness = 3,
		outline_color = {0.12, 0.05, 0.28, 1}
	}, {
		thickness = 2,
		glow_color = {0.62, 0.38, 1, 0.75}
	}},
	shader_margin = 16
}
M.required_textures = {"go_power_teleportation_sigil"}
M.plugin_required_textures = {}
M.required_sounds = {"spell_teleportation_sigil"}
M.plugin_required_sounds = {}
M.required_exoskeletons = {"sigil_lvl1Def", "sigil_lvl2Def", "sigil_lvl3Def", "portal_particlesDef", "tp_fx_defaultDef", "tp_fx_fuerteDef", "fx_instakillDef", "desintegration_smallDef"}
M.plugin_required_exoskeletons = {}

function M.register_templates(E)
	local V = require("lib.klua.vector")
	local v = V.v
	local vv = V.vv
	local bit = require("bit")
	local band = bit.band
	local bor = bit.bor
	local U = require("utils")
	local S = require("sound_db")
	local SU = require("script_utils")
	local GR = require("grid_db")
	local P = require("path_db")
	local signal = require("lib.hump.signal")
	local scripts = require("game_scripts")

	require("lib.klua.table")

	local function fts(x)
		return x / FPS
	end

	local function queue_damage(store, damage)
		store.damage_queue[#store.damage_queue + 1] = damage
	end

	local tt

	tt = E:register_t_tmp(M.control, "power_control_custom")
	tt.main_script.insert = function(this, store)
		local nearest = P:nearest_nodes(this.pos.x, this.pos.y)[1]

		if not nearest then
			return false
		end

		local pi, _, ni = unpack(nearest)
		local pos = P:node_pos(pi, 1, ni)
		local e = E:create_entity(this.teleportation_controller)

		this.pos.x, this.pos.y = pos.x, pos.y
		e.pos.x, e.pos.y = pos.x, pos.y

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
	tt.cooldown = 45
	tt.user_power.xp_per_use = 280
	tt.teleportation_controller = "aura_teleportation_sigil"
	tt.sound_cast = "PowersRoyalDecreeCastLvl1"
	tt.sound_cast_upgraded = "PowersRoyalDecreeCastLvl6"

	E:set_template("user_power_3", tt)

	tt = E:register_t_tmp("aura_teleportation_sigil")
	E:add_comps(tt, "main_script", "pos")
	tt.main_script.update = function(this, store)
		local max_times_applied = E:get_template(this.mod_teleport).max_times_applied
		local count = 0

		this.ts = store.tick_ts

		S:queue(this.sound_in_out)

		local decal

		if this.portal_decal then
			decal = E:create_entity(this.portal_decal)
			decal.pos.x, decal.pos.y = this.pos.x, this.pos.y
			decal.render.sprites[1].ts = store.tick_ts
			decal.duration = this.duration

			simulation:queue_insert_entity(decal)
		end

		local ps

		if this.portal_fx then
			ps = E:create_entity(this.portal_fx)
			ps.pos.x, ps.pos.y = this.pos.x, this.pos.y - 20
			ps.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(ps)
		end

		if ps then
			U.animation_start(ps, "idle", nil, store.tick_ts, true, 1)
		end

		if this.wait_before_teleport then
			U.y_wait_unconditional(store, this.wait_before_teleport)
		end

		while true do
			if store.tick_ts - this.ts >= this.duration or count >= this.max_count then
				S:queue(this.sound_in_out)

				if ps then
					U.y_animation_play(ps, "out", nil, store.tick_ts, 1, 1)
					simulation:queue_remove_entity(ps)
				end

				if decal then
					decal.duration = 0
				end

				simulation:queue_remove_entity(this)

				return
			end

			local targets = U.find_enemies_in_range(store, this.pos, 0, this.range, F_TELEPORT, this.vis_bans)

			if targets and #targets > 0 then
				for _, target in pairs(targets) do
					if count >= this.max_count then
						break
					end

					if target and target.health and not target.health.dead and (not target.enemy.counts or not target.enemy.counts.mod_teleport or max_times_applied > target.enemy.counts.mod_teleport) then
						local mod_teleport = E:create_entity(this.mod_teleport)

						mod_teleport.modifier.target_id = target.id
						mod_teleport.modifier.source_id = this.id

						simulation:queue_insert_entity(mod_teleport)

						count = count + 1

						U.y_wait_unconditional(store, fts(2))
					end
				end
			end

			coroutine.yield()
		end
	end
	tt.mod_teleport = "mod_teleportation_sigil_teleport"
	tt.duration = 40
	tt.range = 50
	tt.max_count = 4
	tt.vis_bans = bor(F_FRIEND, F_HERO, F_BOSS)
	tt.wait_before_teleport = nil
	tt.portal_decal = "decal_teleportation_sigil"
	tt.portal_fx = "decal_teleportation_sigil_fx"
	tt.sound_in_out = "PowersTeleportSigilInOut"

	tt = E:register_t_tmp("decal_teleportation_sigil", "decal_scripted")
	tt.render.sprites[1].prefix = "sigil_lvl1Def"
	tt.render.sprites[1].name = "in"
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_DECALS
	tt.render.sprites[1].scale = vv(0.8)
	tt.animation_start = "in"
	tt.animation_idle = "loop"
	tt.animation_end = "out"
	tt.idle_force_ts = true
	tt.main_script.update = scripts.decal_utils.animation_in_loop_out.update

	tt = E:register_t_tmp("decal_teleportation_sigil_fx", "decal")
	tt.render.sprites[1].prefix = "portal_particlesDef"
	tt.render.sprites[1].name = "in"
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_DECALS + 1
	tt.render.sprites[1].scale = vv(0.8)

	tt = E:register_t_tmp("fx_mod_teleport_sigil_default", "fx")
	tt.render.sprites[1].prefix = "tp_fx_defaultDef"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].offset = v(0, 15)
	tt.render.sprites[1].z = Z_DECALS + 1

	tt = E:register_t_tmp("fx_mod_teleport_sigil_instakill", "fx")
	tt.render.sprites[1].prefix = "fx_instakillDef"
	tt.render.sprites[1].name = "instakill_in"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_DECALS + 1

	tt = E:register_t_tmp("fx_mod_teleport_sigil_instakill_ashes", "fx")
	tt.render.sprites[1].prefix = "desintegration_smallDef"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_DECALS + 1

	tt = E:register_t_tmp("fx_mod_teleport_sigil_second_tp", "fx")
	tt.render.sprites[1].prefix = "tp_fx_fuerteDef"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_DECALS + 1

	tt = E:register_t_tmp("mod_teleportation_sigil_teleport", "mod_teleport")
	tt.modifier.vis_flags = bor(F_MOD)
	tt.modifier.vis_bans = bor(F_BOSS)
	tt.modifier.duration = 1
	tt.modifier.use_mod_offset = true
	tt.modifier.allows_duplicates = false
	tt.nodes_offset = -50
	tt.max_times_applied = 4
	tt.nodeslimit = 10
	tt.dest_valid_node = true
	tt.dest_node_valid_flags = NF_NO_BACKWARDS
	tt.delay_start = fts(3)
	tt.hold_time = 0.34
	tt.delay_end = fts(3)
	tt.fx_instakill = "fx_mod_teleport_sigil_instakill"
	tt.fx_instakill_ashes = "fx_mod_teleport_sigil_instakill_ashes"
	tt.fx_second_tp = "fx_mod_teleport_sigil_second_tp"
	tt.fx_default = "fx_mod_teleport_sigil_default"
	tt.instakill_sound = "PowersTeleportSigilInstakillCast"
	tt.main_script.update = function(this, store)
		local m = this.modifier
		local should_stun = false
		local instakill = false
		local second_tp = false

		if this.begin_wait then
			U.y_wait_unconditional(store, this.begin_wait)
		end

		local target = store.entities[m.target_id]

		if not target or not target.health or target.health.dead then
			simulation:queue_remove_entity(this)

			return
		end

		if this.instakill_chance and target.health.hp >= this.instakill_min_hp and band(target.vis.flags, F_BOSS) == 0 then
			if math.random() < this.instakill_chance then
				instakill = true
			end
		end

		if not instakill and this.second_tp_chance then
			if math.random() < this.second_tp_chance then
				should_stun = true
				second_tp = true
			end
		end

		if this.max_times_applied then
			target.enemy.counts.mod_teleport = (target.enemy.counts.mod_teleport or 0) + 1

			if target.enemy.counts.mod_teleport > this.max_times_applied then
				simulation:queue_remove_entity(this)

				return
			end
		end

		local fx

		if instakill and not second_tp and this.fx_instakill then
			fx = E:create_entity(this.fx_instakill)
			fx.render.sprites[1].name = "instakill_in"

			S:queue(this.instakill_sound)
		elseif second_tp and not instakill and this.fx_second_tp then
			fx = E:create_entity(this.fx_second_tp)
		elseif this.fx_default then
			fx = E:create_entity(this.fx_default)
		end

		if fx then
			fx.pos.x, fx.pos.y = target.pos.x, target.pos.y

			if m.use_mod_offset and target.unit.mod_offset then
				fx.pos.x = fx.pos.x + target.unit.mod_offset.x
				fx.pos.y = fx.pos.y + target.unit.mod_offset.y
			end

			fx.render.sprites[1].ts = store.tick_ts

			if band(target.vis.flags, F_FLYING) ~= 0 then
				fx.render.sprites[1].z = Z_FLYING_HEROES
			end

			simulation:queue_insert_entity(fx)
		end

		if this.delay_start then
			U.y_wait_unconditional(store, this.delay_start)
		end

		local health_bar_hidden

		U.unblock_all(store, target)

		if target.ui then
			target.ui.can_click = false
		end

		if target.health_bar then
			health_bar_hidden = target.health_bar.hidden
			target.health_bar.hidden = true
		end

		U.sprites_hide(target, nil, nil, true)
		SU.hide_modifiers(store, target, true)
		SU.hide_auras(store, target, true)
		U.y_wait_unconditional(store, this.hold_time)

		if target.motion then
			target.motion.forced_waypoint = nil
		end

		local n_off = U.flag_has(target.vis.flags, F_BOSS) and this.boss_nodes_offset or this.nodes_offset

		if second_tp and not instakill then
			n_off = n_off * 2
		end

		local n_ni = target.nav_path.ni + n_off

		if n_ni < 1 then
			local prev_pi = P:get_prev_pi(target.nav_path.pi)

			if prev_pi then
				target.nav_path.pi = prev_pi
				n_ni = P:get_end_node(prev_pi) + n_ni
			end
		end

		local end_node = P:get_end_node(target.nav_path.pi)

		n_ni = math.max(1, math.min(end_node, n_ni))

		if this.dest_valid_node then
			local search_dir = this.dest_node_valid_dir or 1
			local flags = this.dest_node_valid_flags or NF_ALL
			local ni = n_ni

			while ni >= 1 and ni <= end_node do
				if P:is_node_valid(target.nav_path.pi, ni, flags) then
					n_ni = ni

					break
				end

				ni = ni + search_dir
			end
		else
			n_ni = math.max(end_node - this.nodeslimit, n_ni)
		end

		target.nav_path.ni = n_ni

		local npos = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni)

		target.pos.x, target.pos.y = npos.x, npos.y

		if instakill and not second_tp and this.fx_instakill then
			local out_fx = E:create_entity(this.fx_instakill)

			out_fx.render.sprites[1].name = "instakill_out"
			out_fx.render.sprites[1].ts = store.tick_ts

			if m.use_mod_offset and target.unit.mod_offset then
				out_fx.pos.x = target.pos.x + target.unit.mod_offset.x
				out_fx.pos.y = target.pos.y + target.unit.mod_offset.y
			else
				out_fx.pos.x, out_fx.pos.y = target.pos.x, target.pos.y
			end

			if band(target.vis.flags, F_FLYING) ~= 0 then
				out_fx.render.sprites[1].z = Z_FLYING_HEROES
			end

			simulation:queue_insert_entity(out_fx)

			U.y_wait_unconditional(store, fts(44))

			local ashes = E:create_entity(this.fx_instakill_ashes)

			ashes.render.sprites[1].ts = store.tick_ts
			ashes.pos.x, ashes.pos.y = target.pos.x, target.pos.y

			simulation:queue_insert_entity(ashes)

			target.health.ignore_damage = false
			target.unit.show_blood_pool = false

			local d = E:create_entity("damage")

			d.source_id = this.id
			d.target_id = target.id
			d.damage_type = bor(DAMAGE_INSTAKILL, DAMAGE_DISINTEGRATE, DAMAGE_NO_SPAWNS)
			d.value = 1e99

			queue_damage(store, d)
			signal.emit("mod-applied", this, target)
			simulation:queue_remove_entity(this)

			return
		end

		if second_tp and not instakill and this.fx_second_tp then
			local second_fx = E:create_entity(this.fx_second_tp)

			second_fx.render.sprites[1].ts = store.tick_ts

			if m.use_mod_offset and target.unit.mod_offset then
				second_fx.pos.x = target.pos.x + target.unit.mod_offset.x
				second_fx.pos.y = target.pos.y + target.unit.mod_offset.y
			else
				second_fx.pos.x, second_fx.pos.y = target.pos.x, target.pos.y
			end

			if band(target.vis.flags, F_FLYING) ~= 0 then
				second_fx.render.sprites[1].z = Z_FLYING_HEROES
			end

			simulation:queue_insert_entity(second_fx)
		elseif this.fx_default then
			local default_fx = E:create_entity(this.fx_default)

			default_fx.render.sprites[1].ts = store.tick_ts

			if m.use_mod_offset and target.unit.mod_offset then
				default_fx.pos.x = target.pos.x + target.unit.mod_offset.x
				default_fx.pos.y = target.pos.y + target.unit.mod_offset.y
			else
				default_fx.pos.x, default_fx.pos.y = target.pos.x, target.pos.y
			end

			if band(target.vis.flags, F_FLYING) ~= 0 then
				default_fx.render.sprites[1].z = Z_FLYING_HEROES
			end

			simulation:queue_insert_entity(default_fx)
		end

		if this.delay_end then
			U.y_wait_unconditional(store, this.delay_end)
		end

		if target.ui then
			target.ui.can_click = true
		end

		if target.health_bar then
			target.health_bar.hidden = health_bar_hidden
		end

		U.sprites_show(target, nil, nil, true)
		SU.show_modifiers(store, target, true)
		SU.show_auras(store, target, true)

		local nn = P:next_entity_node(target, store.tick_length)

		if nn then
			local vx, vy = V.sub(nn.x, nn.y, target.pos.x, target.pos.y)
			local v_angle = V.angleTo(vx, vy)

			if target.heading then
				target.heading.angle = v_angle
			end
		end

		if this.mod_slow then
			local mod_slow = E:create_entity(this.mod_slow)

			mod_slow.modifier.target_id = target.id
			mod_slow.modifier.source_id = this.id

			simulation:queue_insert_entity(mod_slow)
		end

		if this.mod_silence and this.mod_damage_red then
			local mod_silence = E:create_entity(this.mod_silence)

			mod_silence.modifier.target_id = target.id
			mod_silence.modifier.source_id = this.id

			simulation:queue_insert_entity(mod_silence)

			local mod_damage_red = E:create_entity(this.mod_damage_red)

			mod_damage_red.modifier.target_id = target.id
			mod_damage_red.modifier.source_id = this.id

			simulation:queue_insert_entity(mod_damage_red)
		end

		if should_stun and this.mod_stun then
			local mod_stun = E:create_entity(this.mod_stun)

			mod_stun.modifier.target_id = target.id
			mod_stun.modifier.source_id = this.id

			simulation:queue_insert_entity(mod_stun)
		end

		signal.emit("mod-applied", this, target)
		simulation:queue_remove_entity(this)
	end

	tt = E:register_t_tmp("mod_power_teleportation_sigil_slow", "mod_slow")
	tt.slow.factor = 0.7
	tt.modifier.duration = 4
	tt.modifier.vis_flags = bor(F_MOD)

	tt = E:register_t_tmp("mod_teleportation_sigil_silence", "modifier")
	E:add_comps(tt, "render")
	tt.render.sprites[1].prefix = "sigil_lvl1Def"
	tt.render.sprites[1].name = "loop"
	tt.render.sprites[1].hidden = true
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].animated = true
	tt.main_script.insert = scripts.mod_silence.insert
	tt.main_script.update = scripts.mod_track_target.update
	tt.main_script.remove = scripts.mod_silence.remove
	tt.modifier.duration = 5

	tt = E:register_t_tmp("mod_teleportation_sigil_damage_red", "modifier")
	tt.main_script.insert = scripts.mod_damage_factors.insert
	tt.main_script.update = scripts.mod_track_target.update
	tt.main_script.remove = scripts.mod_damage_factors.remove
	tt.inflicted_damage_factor = 0.5
	tt.modifier.duration = 5

	tt = E:register_t_tmp("mod_teleportation_sigil_stun", "mod_stun")
	tt.modifier.vis_flags = bor(F_MOD, F_STUN)
	tt.modifier.duration = 3
end

function M.apply(level)
	local E = require("entity_db")
	local ctrl = E:get_template(M.control)
	local aura = E:get_template("aura_teleportation_sigil")
	local mod = E:get_template("mod_teleportation_sigil_teleport")
	local decal = E:get_template("decal_teleportation_sigil")

	ctrl.cooldown = 45
	aura.duration = 40
	aura.range = 50
	aura.max_count = 4
	mod.modifier.duration = 1
	mod.hold_time = 1
	mod.second_tp_chance = nil
	mod.instakill_chance = nil
	mod.instakill_min_hp = nil
	mod.mod_slow = nil
	mod.mod_silence = nil
	mod.mod_damage_red = nil
	mod.mod_stun = nil
	decal.render.sprites[1].prefix = "sigil_lvl1Def"

	if level >= 2 then
		mod.modifier.duration = 2
		mod.hold_time = 2
		mod.mod_slow = "mod_power_teleportation_sigil_slow"
	end

	if level >= 3 then
		mod.second_tp_chance = 0.3
		decal.render.sprites[1].prefix = "sigil_lvl2Def"
	end

	if level >= 4 then
		ctrl.cooldown = 40
		aura.max_count = 6
	end

	if level >= 5 then
		mod.mod_silence = "mod_teleportation_sigil_silence"
		mod.mod_damage_red = "mod_teleportation_sigil_damage_red"
		mod.mod_stun = "mod_teleportation_sigil_stun"
	end

	if level >= 6 then
		mod.instakill_chance = 0.2
		mod.instakill_min_hp = 50
		decal.render.sprites[1].prefix = "sigil_lvl3Def"
	end
end

return M
