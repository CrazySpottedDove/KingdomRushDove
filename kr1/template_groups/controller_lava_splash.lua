local scripts = require("game_scripts")
local E = require("entity_db")
local P = require("path_db")
local U = require("utils")
local SU = require("script_utils")
local function fts(t)
	return t / 30
end
local vv = vec_1
local tt = E:register_t_tmp("mod_stage_32_lava_splash", "modifier")
tt.main_script.insert = scripts.mod_track_target.insert
tt.main_script.update = function(this, store)
	local m = this.modifier

	this.modifier.ts = store.tick_ts

	local target = store.entities[m.target_id]

	if not target or not target.pos then
		simulation:queue_remove_entity(this)

		return
	end

	this.pos = target.pos

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead or m.duration >= 0 and store.tick_ts - m.ts > m.duration or m.last_node and target.nav_path.ni > m.last_node or not this.paths_y[target.nav_path.pi] then
			simulation:queue_remove_entity(this)

			return
		end

		local frames_anticipation = target.unit.size > UNIT_SIZE_MEDIUM and 10 or 5
		local predict_pos = P:predict_enemy_pos(target, fts(frames_anticipation))
		local do_splash = predict_pos.y < this.paths_y[target.nav_path.pi]

		if do_splash then
			local fx = E:create_entity(target.unit.size > UNIT_SIZE_MEDIUM and this.fx_big or this.fx)

			fx.pos = predict_pos

			if target.unit and target.unit.mod_offset then
				fx.pos.y = fx.pos.y + target.unit.mod_offset.y
				fx.render.sprites[1].sort_y_offset = fx.render.sprites[1].sort_y_offset - target.unit.mod_offset.y
			end

			fx.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(fx)
			simulation:queue_remove_entity(this)

			return
		end

		coroutine.yield()
	end
end
tt.paths_y = {
	[2] = 555
}
tt.paths_y_big = {
	[2] = 555
}
tt.modifier.duration = 1e+99
tt.fx = "fx_stage_32_lava_splash"
tt.fx_big = "fx_stage_32_lava_splash_big"

tt = E:register_t_tmp("mod_stage_32_lava_splash_2", "mod_stage_32_lava_splash")
tt.paths_y = {
	[3] = 555
}
tt.paths_y_big = {
	[3] = 555
}
tt.fx = "fx_stage_32_lava_splash_2"
tt.fx_big = "fx_stage_32_lava_splash_big_2"

tt = E:register_t_tmp("mod_stage_35_lava_splash", "mod_stage_32_lava_splash")
tt.main_script.insert = function(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or target.health.dead then
		return false
	end

	if band(this.modifier.vis_flags, target.vis.bans) ~= 0 or band(this.modifier.vis_bans, target.vis.flags) ~= 0 then
		return false
	end

	if target then
		SU.hide_modifiers(store, target, true)
		SU.hide_auras(store, target, true)
		U.sprites_hide(target, nil, nil, true)
	end

	return true
end
tt.main_script.update = function(this, store)
	local m = this.modifier

	this.modifier.ts = store.tick_ts

	local target = store.entities[m.target_id]

	if not target or not target.pos then
		simulation:queue_remove_entity(this)

		return
	end

	this.pos = target.pos

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead or m.duration >= 0 and store.tick_ts - m.ts > m.duration or m.last_node and target.nav_path.ni > m.last_node then
			simulation:queue_remove_entity(this)

			return
		end

		local frames_anticipation = target.unit.size > UNIT_SIZE_MEDIUM and 10 or 5
		local predict_pos = P:predict_enemy_pos(target, fts(frames_anticipation))
		local do_splash = false

		if this.apply_if_enemy_is_to_right then
			do_splash = predict_pos.x > this.paths_x[target.nav_path.pi]
		else
			do_splash = predict_pos.x < this.paths_x[target.nav_path.pi]
		end

		if do_splash then
			local fx = E:create_entity(target.unit.size > UNIT_SIZE_MEDIUM and this.fx_big or this.fx)

			fx.pos = predict_pos

			if target.unit and target.unit.mod_offset then
				fx.pos.y = fx.pos.y + target.unit.mod_offset.y
				fx.render.sprites[1].sort_y_offset = fx.render.sprites[1].sort_y_offset - target.unit.mod_offset.y
			end

			fx.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(fx)
			U.y_wait_unconditional(store, fts(7))
			simulation:queue_remove_entity(this)

			return
		end

		coroutine.yield()
	end
end
tt.main_script.remove = function(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if target then
		SU.show_modifiers(store, target, true)
		SU.show_auras(store, target, true)
		U.sprites_show(target, nil, nil, true)
	end

	return true
end
tt.apply_if_enemy_is_to_right = true
tt.paths_x = {
	[15] = 0,
	[7] = 0
}
tt.paths_x_big = {
	[15] = 0,
	[7] = 0
}
tt.fx = "fx_stage_35_lava_splash"
tt.fx_big = "fx_stage_35_lava_splash_big"

tt = E:register_t_tmp("mod_stage_35_water_splash", "mod_stage_35_lava_splash")
tt.apply_if_enemy_is_to_right = false
tt.paths_x = {
	[8] = 1025
}
tt.paths_x_big = {
	[8] = 1025
}
tt.fx = "fx_stage_35_water_splash"
tt.fx_big = "fx_stage_35_water_splash_big"

tt = E:register_t_hot("controller_stage_32_lava_splash", nil, true)
E:add_comps(tt, "main_script")
tt.main_script.update = function(this, store)
	while true do
		local enemies = table.filter(store.enemies, function(k, v)
			if v.pending_removal then
				return false
			end

			if not v.pos then
				return false
			end

			if band(v.vis.flags, this.vis_bans) ~= 0 then
				return false
			end

			if band(v.vis.bans, this.vis_flags) ~= 0 then
				return false
			end

			if not this.paths_y[v.nav_path.pi] then
				return false
			end

			if v.pos.y < this.paths_y[v.nav_path.pi] then
				return false
			end

			if v.passed_lava_tunnel then
				return false
			end

			if v.template_name == "boss_redboy_teen" then
				return false
			end

			return true
		end)

		if #enemies > 0 then
			for _, e in ipairs(enemies) do
				local mod = E:create_entity(this.mod)

				mod.modifier.target_id = e.id
				mod.modifier.source_id = this.id

				simulation:queue_insert_entity(mod)

				e.passed_lava_tunnel = true
			end
		end

		coroutine.yield()
	end
end
tt.mod = "mod_stage_32_lava_splash"
tt.paths_y = {
	[2] = 560
}
tt.vis_flags = 0
tt.vis_bans = 0

tt = E:register_t_hot("controller_stage_35_lava_splash", "controller_stage_32_lava_splash", true)
tt.main_script.update = function(this, store)
	while true do
		local enemies = table.filter(store.entities, function(k, v)
			if v.pending_removal then
				return false
			end

			if not v.enemy or not v.vis or not v.nav_path then
				return false
			end

			if not v.pos then
				return false
			end

			if band(v.vis.flags, this.vis_bans) ~= 0 then
				return false
			end

			if band(v.vis.bans, this.vis_flags) ~= 0 then
				return false
			end

			if not this.paths_x[v.nav_path.pi] then
				return false
			end

			if this.apply_if_enemy_is_to_right then
				if v.pos.x < this.paths_x[v.nav_path.pi] then
					return false
				end
			elseif v.pos.x > this.paths_x[v.nav_path.pi] then
				return false
			end

			if v.passed_lava_tunnel then
				return false
			end

			if v.template_name == "boss_redboy_teen" then
				return false
			end

			return true
		end)

		if #enemies > 0 then
			for _, e in ipairs(enemies) do
				local mod = E:create_entity(this.mod)

				mod.modifier.target_id = e.id
				mod.modifier.source_id = this.id

				simulation:queue_insert_entity(mod)

				e.passed_lava_tunnel = true
			end
		end

		coroutine.yield()
	end
end
tt.apply_if_enemy_is_to_right = false
tt.mod = "mod_stage_35_lava_splash"
tt.paths_x = {
	[15] = 0,
	[7] = 0
}

tt = E:register_t_hot("controller_stage_35_water_splash", "controller_stage_35_lava_splash", true)
tt.apply_if_enemy_is_to_right = true
tt.mod = "mod_stage_35_water_splash"
tt.paths_x = {
	[8] = 1025
}

tt = E:register_t_tmp("fx_stage_32_lava_splash", "fx")
tt.render.sprites[1].prefix = "stage_32_lava_splashDef"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].exo = true
tt.render.sprites[1].sort_y_offset = -40
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].scale = vv(0.5599999999999999)

tt = E:register_t_tmp("fx_stage_32_lava_splash_2", "fx_stage_32_lava_splash")
tt.render.sprites[1].flip_x = true

tt = E:register_t_tmp("fx_stage_32_lava_splash_big", "fx")
tt.render.sprites[1].prefix = "stage_32_lava_splash_bigDef"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].exo = true
tt.render.sprites[1].sort_y_offset = -40
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].scale = vv(0.7)

tt = E:register_t_tmp("fx_stage_32_lava_splash_big_2", "fx_stage_32_lava_splash_big")
tt.render.sprites[1].flip_x = true

tt = E:register_t_tmp("fx_stage_35_lava_splash", "fx")
tt.render.sprites[1].prefix = "stage_5_splash_lavaDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].sort_y_offset = -40
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].scale = vv(0.5599999999999999)

tt = E:register_t_tmp("fx_stage_35_lava_splash_big", "fx_stage_35_lava_splash")
tt.render.sprites[1].scale = vv(1)

tt = E:register_t_tmp("fx_stage_35_water_splash", "fx_stage_35_lava_splash")
tt.render.sprites[1].prefix = "stage_5_splash_aguaDef"

tt = E:register_t_tmp("fx_stage_35_water_splash_big", "fx_stage_35_water_splash")
tt.render.sprites[1].scale = vv(1)
