local M = {}

M.id = "wintersongs_wrath"
M.i18n = "POWER_WINTERSONGS_WRATH"
M.control = "power_wintersongs_wrath_control"
M.button_icon = "in_game_icon_power_wintersongs_wrath"
M.pointer_icon = "pointer_power_wintersongs_wrath"
M.portrait = "power_portraits_big_wintersongs_wrath"
M.name_style = {
	font_name = "h",
	font_size = 30,
	color = {180, 224, 255, 255},
	shaders = {"p_outline", "p_glow"},
	shader_args = {{
		thickness = 3,
		outline_color = {0.03, 0.13, 0.28, 1}
	}, {
		thickness = 2,
		glow_color = {0.42, 0.76, 1, 0.75}
	}},
	shader_margin = 16
}
M.required_textures = {"go_power_wintersongs_wrath"}
M.plugin_required_textures = {}
M.required_sounds = {"spell_wintersongs_wrath"}
M.plugin_required_sounds = {}
M.required_exoskeletons = {"eloraDef", "fumeDef"}
M.plugin_required_exoskeletons = {}

function M.register_templates(E)
	local V = require("lib.klua.vector")
	local v = V.v
	local vv = V.vv
	local bit = require("bit")
	local bor = bit.bor
	local U = require("utils")
	local S = require("sound_db")
	local P = require("path_db")
	local signal = require("lib.hump.signal")
	local scripts = require("game_scripts")

	require("lib.klua.table")

	local function fts(x)
		return x / FPS
	end

	local function point_in_valid_path(x, y, path_indexes)
		for _, pi in ipairs(path_indexes) do
			local width = P:path_width(pi)

			for spi = 1, #P.paths[pi] do
				local path = P.paths[pi][spi]

				for ni = 1, #path do
					local node = path[ni]

					if V.dist(node.x, node.y, x, y) < width then
						return true
					end
				end
			end
		end

		return false
	end

	local tt

	tt = E:register_t_tmp(M.control, "power_control_custom")
	tt.main_script.insert = function(this, store)
		local nearest = P:nearest_nodes(this.pos.x, this.pos.y)[1]
		local pi, _, ni = unpack(nearest)
		local pos = P:node_pos(pi, 1, ni)
		local e = E:create_entity(this.decal_elora)

		e.pos.x, e.pos.y = pos.x, pos.y + 30
		e.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(e)

		return false
	end
	tt.main_script.update = nil
	tt.user_selection.can_select_point_fn = scripts.user_power_3.can_select_point
	tt.cooldown = 40
	tt.decal_elora = "decal_power_wintersongs_wrath_elora"

	E:set_template("user_power_3", tt)

	tt = E:register_t_tmp("decal_power_wintersongs_wrath_elora", "decal_scripted")
	E:add_comps(tt, "sound_events")
	tt.main_script.update = function(this, store)
		local spikes = {}
		local ts = store.tick_ts

		local function spike_too_close(new_pos)
			for _, spike in ipairs(spikes) do
				if V.dist(new_pos.x, new_pos.y, spike.x, spike.y) < 20 then
					return true
				end
			end

			return false
		end

		local function create_spike(entity, pi, spi, ni, random_x, random_y)
			local pos = P:node_pos(pi, spi, ni)
			local final_pos = v(pos.x + U.frandom(-random_x, random_x), pos.y + U.frandom(-random_y, random_y))

			if point_in_valid_path(final_pos.x, final_pos.y, {pi}) then
				local random_scale = U.frandom(0.9, 1)
				local spike = E:create_entity(entity)
				local random_angle = 5 * math.pi / 180
				local angle = U.frandom(-random_angle, random_angle)

				spike.pos = final_pos
				spike.render.sprites[1].ts = store.tick_ts
				spike.render.sprites[1].flip_x = this.pos.x > spike.pos.x
				spike.render.sprites[1].r = angle
				spike.render.sprites[1].scale = v(random_scale, random_scale)

				simulation:queue_insert_entity(spike)
				table.insert(spikes, final_pos)

				local spike_aura = E:create_entity(this.aura_l3)

				spike_aura.pos = P:node_pos(pi, 1, ni)
				spike_aura.aura.cycle_time = fts(12)

				simulation:queue_insert_entity(spike_aura)
			end
		end

		if this.l6_disabled then
			S:queue(this.sound_cast_base, this.sound_cast_base_args)
		else
			S:queue(this.sound_cast_l6, this.sound_cast_l6_args)
		end

		local slow_aura = E:create_entity(this.aura)

		slow_aura.pos = V.vclone(this.pos)
		slow_aura.aura.source_id = this.id
		slow_aura.aura.track_source = true
		slow_aura.aura.duration = this.duration

		simulation:queue_insert_entity(slow_aura)

		local ps_wind, ps_snow

		if not this.l6_disabled then
			local global_aura = E:create_entity(this.aura_l6)

			global_aura.pos = V.vclone(this.pos)
			global_aura.aura.source_id = this.id
			global_aura.aura.track_source = true

			simulation:queue_insert_entity(global_aura)

			this.aura_l6_entity = global_aura
			signal.emit("wintersongs-ice-sequence-start")

			ps_wind = E:create_entity(this.ps_wind_l6)
			ps_wind.pos = v(-800, REF_H / 2)

			simulation:queue_insert_entity(ps_wind)

			ps_snow = E:create_entity(this.ps_snow_l6)
			ps_snow.pos = v(-50, REF_H / 2)

			simulation:queue_insert_entity(ps_snow)
		end

		local d = E:create_entity(this.decal_tornado[1])

		d.pos.x, d.pos.y = V.add(this.pos.x, this.pos.y, this.decal_tornado[2].x, this.decal_tornado[2].y)
		d.render.sprites[1].ts = store.tick_ts
		d.duration = this.duration

		simulation:queue_insert_entity(d)

		d = E:create_entity(this.decal_ice_ground[1])
		d.pos.x, d.pos.y = V.add(this.pos.x, this.pos.y, this.decal_ice_ground[2].x, this.decal_ice_ground[2].y)
		d.render.sprites[1].ts = store.tick_ts
		d.duration = this.duration

		simulation:queue_insert_entity(d)

		if this.l6_disabled then
			S:queue(this.sound_loop_base, this.sound_loop_base_args)
		else
			S:queue(this.sound_loop_l6, this.sound_loop_l6_args)
		end

		if not this.l3_disabled then
			U.y_wait(store, this.delay_cast)

			local available_paths = {}

			for k in pairs(P.paths) do
				table.insert(available_paths, k)
			end

			if store.level.ignore_walk_backwards_paths then
				available_paths = table.filter(available_paths, function(_, pi)
					return not table.contains(store.level.ignore_walk_backwards_paths, pi)
				end)
			end

			local nearest = P:nearest_nodes(this.pos.x, this.pos.y, available_paths, nil, nil, NF_RALLY)
			local dbn = this.distance_between_spikes

			for i = 1, this.spike_count do
				for _, node in pairs(nearest) do
					local pi, ni, dist = node[1], node[3], node[4]

					if dist < 100 then
						local spike = this.spikes[i <= 2 and 1 or i <= 4 and 2 or 3]
						local positions = {}
						local path_ni_forward = ni + dbn * i
						local path_ni_backward = ni - dbn * i

						if i % 2 == 0 then
							table.insert(positions, {
								path_spi = 1,
								path_ni = path_ni_forward
							})
							table.insert(positions, {
								path_spi = 1,
								path_ni = path_ni_backward
							})
						else
							table.insert(positions, {
								path_spi = 2,
								path_ni = path_ni_forward
							})
							table.insert(positions, {
								path_spi = 2,
								path_ni = path_ni_backward
							})
							table.insert(positions, {
								path_spi = 3,
								path_ni = path_ni_forward
							})
							table.insert(positions, {
								path_spi = 3,
								path_ni = path_ni_backward
							})
						end

						for _, position in ipairs(positions) do
							create_spike(spike, pi, position.path_spi, position.path_ni, 10, 10)
						end

						S:queue(this.sound_spike_cast)
					end
				end

				U.y_wait(store, this.delay_between_spikes)
			end
		end

		U.y_animation_wait(this)
		U.animation_start(this, this.animation_idle, nil, store.tick_ts, true, 1, true)

		d = E:create_entity(this.decal_fume[1])
		d.pos.x, d.pos.y = V.add(this.pos.x, this.pos.y, this.decal_fume[2].x, this.decal_fume[2].y)
		d.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(d)

		local ui_flag = false

		while true do
			if store.tick_ts - ts > this.duration then
				if this.l6_disabled then
					S:stop(this.sound_loop_base)
					S:queue(this.sound_end_base, this.sound_end_base_args)
				else
					S:stop(this.sound_loop_l6)
					S:queue(this.sound_end_l6, this.sound_end_l6_args)
				end

				U.y_animation_play(this, this.animation_end, nil, store.tick_ts, 1, 1)
				simulation:queue_remove_entity(this)

				return
			end

			if not this.l6_disabled and store.entities[this.aura_l6_entity.id] == nil and not ui_flag then
				signal.emit("wintersongs-ice-sequence-end")

				if ps_wind then
					ps_wind.particle_system.emit = false
				end

				if ps_snow then
					ps_snow.particle_system.emit = false
				end

				ui_flag = true
			end

			coroutine.yield()
		end
	end
	tt.duration = 8
	tt.animation_idle = "loop"
	tt.animation_end = "out"
	tt.aura = "aura_power_wintersongs_wrath_slow"
	tt.decal_tornado = {"decal_power_wintersongs_wrath_tornado", v(-3, -23)}
	tt.decal_fume = {"decal_power_wintersongs_wrath_fume", v(0, 10), 0}
	tt.decal_ice_ground = {"decal_power_wintersongs_wrath_ice_ground", v(-3, -28)}
	tt.render.sprites[1].prefix = "eloraDef"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].loop = false
	tt.render.sprites[1].z = Z_OBJECTS
	tt.render.sprites[1].sort_y_offset = tt.decal_tornado[2].y - 2
	tt.render.sprites[1].name = "in"
	tt.l3_disabled = true
	tt.spikes = {"decal_power_wintersongs_wrath_spike_1", "decal_power_wintersongs_wrath_spike_2", "decal_power_wintersongs_wrath_spike_3"}
	tt.aura_l3 = "aura_power_wintersongs_wrath_spike"
	tt.spike_count = 3
	tt.distance_between_spikes = 5
	tt.delay_between_spikes = fts(3)
	tt.delay_cast = 0.05
	tt.l6_disabled = true
	tt.aura_l6 = "aura_power_wintersongs_wrath_global_slow"
	tt.ps_snow_l6 = "ps_power_wintersongs_wrath_snow"
	tt.ps_wind_l6 = "ps_power_wintersongs_wrath_wind"
	tt.sound_events.insert = "PowersWintersongsWrathSummonTaunt"
	tt.sound_cast_base = "PowersWintersongsWrathBaseCast"
	tt.sound_cast_base_args = {
		delay = fts(10)
	}
	tt.sound_cast_l6 = "PowersWintersongsWrathGlobalCastLoopStart"
	tt.sound_cast_l6_args = {
		delay = fts(10)
	}
	tt.sound_loop_base = "PowersWintersongsWrathBaseLoop"
	tt.sound_loop_base_args = {}
	tt.sound_loop_l6 = "PowersWintersongsWrathGlobalCastLoop"
	tt.sound_loop_l6_args = {}
	tt.sound_end_base = "PowersWintersongsWrathBaseLoopEnd"
	tt.sound_end_base_args = {}
	tt.sound_end_l6 = "PowersWintersongsWrathGlobalCastLoopEnd"
	tt.sound_end_l6_args = {}
	tt.sound_spike_cast = "PowersWintersongsWrathSpikesCast"

	tt = E:register_t_tmp("decal_power_wintersongs_wrath_tornado", "decal_scripted")
	tt.render.sprites[1].prefix = "elora_multi_tornado"
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].z = Z_OBJECTS
	tt.render.sprites[1].name = "in"
	tt.render.sprites[1].hidden = true
	tt.main_script.update = scripts.decal_utils.animation_in_loop_out.update
	tt.animation_start = "in"
	tt.animation_idle = "loop"
	tt.animation_end = "out"
	tt.delay_animation_start = fts(1)
	tt.duration = 8

	tt = E:register_t_tmp("decal_power_wintersongs_wrath_fume", "decal_scripted")
	E:add_comps(tt, "tween")
	tt.render.sprites[1].prefix = "fumeDef"
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_OBJECTS
	tt.render.sprites[1].sort_y_offset = -34
	tt.render.sprites[1].name = "loop"
	tt.render.sprites[1].hidden = true
	tt.main_script.update = function(this, store)
		this.tween.disabled = false
		this.tween.ts = store.tick_ts
		this.tween.run_once = false
		this.tween.remove = false

		for i = 1, #this.tween.props do
			this.tween.props[i].disabled = false
		end

		local ts = store.tick_ts

		while store.tick_ts - ts < this.duration do
			coroutine.yield()
		end

		this.tween.disabled = true

		simulation:queue_remove_entity(this)
	end
	tt.main_script.remove = scripts.tween_utils.reverse_remove
	tt.animation_idle = "loop"
	tt.tween.props[1].keys = {{0, 0}, {1, 255}}
	tt.tween.props[1].loop = false
	tt.tween.props[1].name = "alpha"
	tt.tween.disabled = true
	tt.duration = 8

	tt = E:register_t_tmp("decal_power_wintersongs_wrath_ice_ground", "decal_scripted")
	tt.render.sprites[1].prefix = "elora_multi_decal_elora"
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].z = Z_OBJECTS
	tt.render.sprites[1].sort_y_offset = 8
	tt.render.sprites[1].scale = vv(0.75)
	tt.render.sprites[1].name = "in"
	tt.render.sprites[1].hidden = true
	tt.main_script.update = scripts.decal_utils.animation_in_loop_out.update
	tt.animation_idle = "loop"
	tt.animation_end = "out"
	tt.delay_animation_start = fts(15)
	tt.duration = 8

	tt = E:register_t_tmp("decal_power_wintersongs_wrath_spike_1", "decal_timed")
	tt.render.sprites[1].prefix = "elora_multi_spiker_1"
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].z = Z_OBJECTS
	tt.render.sprites[1].name = "in"

	tt = E:register_t_tmp("decal_power_wintersongs_wrath_spike_2", "decal_power_wintersongs_wrath_spike_1")
	tt.render.sprites[1].prefix = "elora_multi_spiker_2"

	tt = E:register_t_tmp("decal_power_wintersongs_wrath_spike_3", "decal_power_wintersongs_wrath_spike_1")
	tt.render.sprites[1].prefix = "elora_multi_spiker_3"

	tt = E:register_t_tmp("aura_power_wintersongs_wrath_slow", "aura")
	tt.aura.mods = {"mod_power_wintersongs_wrath_slow", "mod_power_wintersongs_wrath_slow_2", "mod_power_wintersongs_wrath_slow_3"}
	tt.aura.radius = 120
	tt.aura.vis_flags = bor(F_AREA)
	tt.aura.vis_bans = bor(F_HERO, F_FRIEND)
	tt.aura.cycle_time = 0.1
	tt.aura.cycles = nil
	tt.aura.duration = 1e99
	tt.main_script.insert = scripts.aura_apply_mod.insert
	tt.main_script.update = scripts.aura_apply_mod.update

	tt = E:register_t_tmp("aura_power_wintersongs_wrath_spike", "aura")
	tt.aura.radius = 32
	tt.aura.vis_flags = bor(F_AREA)
	tt.aura.vis_bans = bor(F_HERO, F_FRIEND, F_FLYING)
	tt.aura.cycles = 1
	tt.aura.duration = 1e99
	tt.aura.damage_min = 24
	tt.aura.damage_max = 36
	tt.aura.damage_type = DAMAGE_MAGICAL
	tt.aura.hit_fx = "fx_power_wintersongs_wrath_hit"
	tt.main_script.update = scripts.aura_apply_damage.update

	tt = E:register_t_tmp("aura_power_wintersongs_wrath_global_slow", "aura")
	tt.aura.mods = {"mod_power_wintersongs_wrath_global_slow", "mod_power_wintersongs_wrath_slow_2", "mod_power_wintersongs_wrath_slow_3"}
	tt.aura.radius = 2000
	tt.aura.vis_flags = bor(F_AREA, F_STUN)
	tt.aura.vis_bans = bor(F_HERO, F_FRIEND)
	tt.aura.cycle_time = 0.25
	tt.aura.duration = 6
	tt.main_script.insert = scripts.aura_apply_mod.insert
	tt.main_script.update = scripts.aura_apply_mod.update

	tt = E:register_t_tmp("mod_power_wintersongs_wrath_slow", "mod_slow")
	E:add_comps(tt, "render")
	tt.slow.factor = 0.6
	tt.modifier.duration = 0.35
	tt.modifier.vis_flags = bor(F_MOD)
	tt.modifier.use_mod_offset = true
	tt.main_script.insert = scripts.mod_slow.insert
	tt.main_script.update = scripts.mod_track_target.update
	tt.main_script.remove = scripts.mod_slow.remove
	tt.render.sprites[1].prefix = "elora_multi_modifier_slow1"
	tt.render.sprites[1].name = "loop"
	tt.render.sprites[1].loop = true
	tt.render.sprites[1].z = Z_EFFECTS

	tt = E:register_t_tmp("mod_power_wintersongs_wrath_slow_2", "mod_slow")
	E:add_comps(tt, "render")
	tt.slow.factor = 1
	tt.modifier.duration = 0.35
	tt.modifier.vis_flags = bor(F_MOD)
	tt.modifier.vis_bans = bor(F_FLYING)
	tt.modifier.use_mod_offset = false
	tt.main_script.insert = scripts.mod_slow.insert
	tt.main_script.update = scripts.mod_track_target.update
	tt.main_script.remove = scripts.mod_slow.remove
	tt.render.sprites[1].prefix = "elora_multi_modifier_slow2"
	tt.render.sprites[1].name = "loop"
	tt.render.sprites[1].loop = true
	tt.render.sprites[1].z = Z_EFFECTS

	tt = E:register_t_tmp("mod_power_wintersongs_wrath_slow_3", "mod_slow")
	E:add_comps(tt, "render")
	tt.slow.factor = 1
	tt.modifier.duration = 0.35
	tt.modifier.vis_flags = bor(F_MOD)
	tt.modifier.use_mod_offset = false
	tt.main_script.insert = scripts.mod_slow.insert
	tt.main_script.update = scripts.mod_track_target.update
	tt.main_script.remove = scripts.mod_slow.remove
	tt.render.sprites[1].name = "elora_multi_deca_modifier_slow"
	tt.render.sprites[1].animated = false
	tt.render.sprites[1].z = Z_EFFECTS

	tt = E:register_t_tmp("mod_power_wintersongs_wrath_freeze", "mod_stun")
	tt.modifier.duration = 4
	tt.modifier.animation_phases = true
	tt.modifier.use_mod_offset = false
	tt.modifier.vis_flags = bor(F_MOD, F_STUN)
	tt.modifier.vis_bans = bor(F_BOSS)
	tt.render = nil
	tt.main_script.insert = scripts.mod_freeze.insert
	tt.main_script.update = scripts.mod_freeze.update
	tt.main_script.remove = scripts.mod_freeze.remove
	tt.freeze_decal_name = "decal_freeze_enemy"

	tt = E:register_t_tmp("mod_power_wintersongs_wrath_global_slow", "mod_slow")
	E:add_comps(tt, "render")
	tt.slow.factor = 0.5
	tt.modifier.duration = 0.35
	tt.modifier.vis_flags = bor(F_MOD)
	tt.modifier.use_mod_offset = true
	tt.main_script.insert = scripts.mod_slow.insert
	tt.main_script.update = scripts.mod_track_target.update
	tt.main_script.remove = scripts.mod_slow.remove
	tt.render.sprites[1].prefix = "elora_multi_modifier_slow1"
	tt.render.sprites[1].name = "loop"
	tt.render.sprites[1].loop = true
	tt.render.sprites[1].z = Z_EFFECTS

	tt = E:register_t_tmp("fx_power_wintersongs_wrath_hit", "fx")
	tt.render.sprites[1].prefix = "elora_multi_hit"
	tt.render.sprites[1].name = "in"
	tt.render.sprites[1].z = Z_BULLETS

	tt = E:register_t_tmp("ps_power_wintersongs_wrath_snow", "particle_system")
	tt.particle_system.emission_rate = 20
	tt.particle_system.emit_area_spread = v(1200, 400)
	tt.particle_system.emit_speed = {300, 300}
	tt.particle_system.emit_spread = 0.7563093425308761
	tt.particle_system.name = "elora_multi_snowflake_small"
	tt.particle_system.particle_lifetime = {3, 5}
	tt.particle_system.z = 3500
	tt.particle_system.animated = false
	tt.particle_system.source_lifetime = 30

	tt = E:register_t_tmp("ps_power_wintersongs_wrath_wind", "particle_system")
	tt.particle_system.emission_rate = 2
	tt.particle_system.emit_area_spread = v(1200, 700)
	tt.particle_system.emit_speed = {800, 200}
	tt.particle_system.emit_spread = 0.17453292519943295
	tt.particle_system.name = "elora_multi_gust"
	tt.particle_system.particle_lifetime = {10, 10}
	tt.particle_system.z = 3500
	tt.particle_system.animated = false
	tt.particle_system.source_lifetime = 30
end

function M.apply(level)
	local E = require("entity_db")
	local ctrl = E:get_template(M.control)
	local elora = E:get_template("decal_power_wintersongs_wrath_elora")
	local slow_aura = E:get_template("aura_power_wintersongs_wrath_slow")
	local slow_mod = E:get_template("mod_power_wintersongs_wrath_slow")
	local spike_aura = E:get_template("aura_power_wintersongs_wrath_spike")

	elora.l3_disabled = level < 3
	elora.l6_disabled = level < 6

	if level >= 2 then
		elora.duration = 8 * 1.5
		slow_aura.aura.radius = 120 * 1.35
	end

	if level >= 4 then
		elora.spike_count = 6
		slow_mod.slow.factor = 0.3
	end

	if level >= 5 then
		spike_aura.aura.damage_min = 24 * 1.3
		spike_aura.aura.damage_max = 36 * 1.3
		spike_aura.aura.mod = "mod_power_wintersongs_wrath_freeze"
	end

	ctrl.cooldown = 40
end

return M
