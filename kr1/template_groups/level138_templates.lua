local signal = require("lib.hump.signal")
local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local V = require("lib.klua.vector")
local function fts(v)
	return v / FPS
end
require("lib.klua.table")
local ACH = require("achievements")
local scripts = require("scripts")
local v = V.v
local r = V.r
local decal_stage_38_easter_ender_egg_insert
local decal_stage_38_easter_ender_egg_update
local decal_stage_38_to_the_stars_update
decal_stage_38_easter_ender_egg_insert = function(this, store, script)
	this.pos = this.positions[1][1]
	this.render.sprites[1].z = this.positions[1][2]
	return true
end
decal_stage_38_easter_ender_egg_update = function(this, store, script)
	local current_position = math.random(1, #this.positions - 1)
	this.pos = this.positions[current_position][1]
	local function teleport_random()
		local new_object_pos, new_object_z
		table.remove(this.positions, current_position)
		if #this.positions > 0 then
			current_position = math.random(1, #this.positions)
			new_object_pos = this.positions[current_position][1]
			new_object_z = this.positions[current_position][2]
		else
			new_object_pos = this.last_position[1]
			new_object_z = this.last_position[2]
		end
		local fx = E:create_entity(this.fx_normal)
		fx.pos = V.vclone(this.pos)
		fx.render.sprites[1].ts = store.tick_ts
		simulation:queue_insert_entity(fx)
		S:queue("Stage38EasterEggEnderEgg")
		U.y_animation_play(this, "tp_out", nil, store.tick_ts, 1, 1)
		this.pos = new_object_pos
		this.render.sprites[1].z = new_object_z
		U.animation_start(this, "tp_in", nil, store.tick_ts, false, 1, true)
		local fx = E:create_entity(this.fx_final)
		fx.pos.x, fx.pos.y = this.pos.x, this.pos.y + 30
		fx.render.sprites[1].ts = store.tick_ts
		simulation:queue_insert_entity(fx)
		U.y_animation_wait_default(this)
		U.animation_start(this, "idle", nil, store.tick_ts, true, 1, true)
	end
	local function teleport_last()
		local fx = E:create_entity(this.gold_fx)
		fx.pos = V.v(this.pos.x, this.pos.y + 20)
		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].z = this.render.sprites[1].z
		fx.render.sprites[1].sort_y_offset = -30
		simulation:queue_insert_entity(fx)
		S:queue("TerrainWukongElementalHolderMetalActive")
		store.player_gold = store.player_gold + this.gold_amount
		U.y_wait_unconditional(store, 0.5)
		local fx = E:create_entity(this.fx_normal)
		fx.pos = V.vclone(this.pos)
		fx.render.sprites[1].ts = store.tick_ts
		simulation:queue_insert_entity(fx)
		S:queue("Stage38EasterEggEnderEgg")
		U.y_animation_play(this, "tp_out", nil, store.tick_ts, 1, 1)
		U.sprites_hide(this, nil, nil, true)
		U.y_wait_unconditional(store, 0.2)
		ACH:got("DLC3_ENDER_EGG")
		simulation:queue_remove_entity(this)
	end
	while true do
		if this.ui.clicked then
			this.ui.clicked = nil
			this.ui.can_click = false
			if #this.positions > 0 then
				teleport_random()
				this.ui.can_click = true
			else
				teleport_last()
				simulation:queue_remove_entity(this)
			end
		end
		coroutine.yield()
	end
end
decal_stage_38_to_the_stars_update = function(this, store, script)
	local clics = 0
	local appear = false
	this.ui.can_click = false
	this.render.sprites[1].hidden = true
	while true do
		if not appear and store.wave_group_number >= 1 then
			appear = true
			this.render.sprites[1].hidden = false
			U.y_animation_play(this, "appear", nil, store.tick_ts, 1, 1)
			U.animation_start(this, "idle1", nil, store.tick_ts, true, 1, true)
			this.ui.can_click = true
		end
		if this.ui.clicked then
			this.ui.clicked = nil
			this.ui.can_click = false
			clics = clics + 1
			if clics == 1 then
				U.y_animation_play(this, "tap1", nil, store.tick_ts, 1, 1)
				U.animation_start(this, "idle2", nil, store.tick_ts, true, 1, true)
			elseif clics == 2 then
				signal.emit("dragon-lunar-stage38", nil)
				U.y_animation_play(this, "tap2", nil, store.tick_ts, 1, 1)
				local drake = E:create_entity("decal_stage_38_to_the_stars_drakefx")
				drake.pos.x, drake.pos.y = this.pos.x + 23, this.pos.y + 3
				drake.render.sprites[1].ts = store.tick_ts
				simulation:queue_insert_entity(drake)
				U.animation_start(this, "idle3", nil, store.tick_ts, true, 1, true)
				U.y_wait_unconditional(store, fts(40))
				local star = E:create_entity("decal_stage_38_to_the_stars_stars")
				star.pos.x, star.pos.y = this.pos.x + 23, this.pos.y + 3
				star.render.sprites[1].ts = store.tick_ts
				simulation:queue_insert_entity(star)
				U.y_wait_unconditional(store, fts(50))
				U.y_animation_play(this, "banish", nil, store.tick_ts, 1, 1)
				U.y_wait_unconditional(store, 0.2)
				ACH:got("DLC3_TOUCH_DRAGON")
				simulation:queue_remove_entity(this)
				return
			end
			this.ui.can_click = true
		end
		coroutine.yield()
	end
end
local tt
local P = require("path_db")
local GR = require("grid_db")
local function fts(v)
	return v / FPS
end

local controller_stage_38_cinematic = {}

function controller_stage_38_cinematic.update(this, store, script)
	this.last_taunt = nil
	this.current_taunt = nil

	local function manage_taunts()
		if not this.do_taunt then
			return false
		end

		local taunt = this.do_taunt

		this.do_taunt = nil
		this.last_taunt = this.current_taunt
		this.current_taunt = taunt

		signal.emit("show-balloon_tutorial", taunt, false)

		this.last_taunt = this.current_taunt
		this.current_taunt = nil

		return true
	end

	while store.wave_group_number < 1 do
		manage_taunts()
		coroutine.yield()
	end

	while true do
		manage_taunts()
		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

local decal_stage_36_mask_islas = {}

function decal_stage_36_mask_islas.insert(this, store, script)
	for _, p in ipairs(this.tween.props) do
		p.ts = store.tick_ts - p.keys[2][1] * math.random()
	end

	return true
end

local decal_stage_38_easter_egg_yamcha = {}

function decal_stage_38_easter_egg_yamcha.update(this, store, script)
	this.ui.can_click = false
	this.ui.clicked = nil

	while true do
		if this.ui.clicked then
			this.ui.clicked = nil
			this.ui.can_click = false

			U.y_animation_play(this, "tap", nil, store.tick_ts, 1, 1)
			U.animation_start(this, "run", nil, store.tick_ts, true, 1, true)

			this.ui.can_click = true
		end

		coroutine.yield()
	end
end

local stage_36_paths_controller = {}

function stage_36_paths_controller.update(this, store, script)
	local radius = 32

	if store.level_idx == 37 then
		radius = 16
	end

	local function set_pos_terrain(x, y, terrain_type, radius)
		radius = radius or GR.cell_size

		local i, j = GR:get_coords(x, y)

		GR:set_cell(i, j, terrain_type)

		if radius > GR.cell_size then
			local cells_radius = math.ceil(radius / GR.cell_size)

			for di = -cells_radius, cells_radius do
				for dj = -cells_radius, cells_radius do
					local ci, cj = i + di, j + dj

					if ci > 0 and ci <= GR.grid_w and cj > 0 and cj <= GR.grid_h then
						GR:set_cell(ci, cj, terrain_type)
					end
				end
			end
		end
	end

	local function set_path_cells_terrain(path_index, terrain_type, radius)
		radius = radius or GR.cell_size

		local subpath_indexes = {1, 2, 3}

		for _, spi in pairs(subpath_indexes) do
			local path = P.paths[path_index][spi]

			if path then
				for ni = 1, #path do
					local node = path[ni]

					set_pos_terrain(node.x, node.y, terrain_type, radius)
				end
			end
		end
	end

	local function instant_deploy_islands_1_and_2(this, store)
		local function dist2(ax, ay, bx, by)
			local dx, dy = ax - bx, ay - bx

			return dx * dx + dy * dy
		end

		local towers_cached

		local function get_towers()
			if towers_cached then
				return towers_cached
			end

			local out = {}

			for _, e in pairs(store.entities) do
				if e.tower and e.pos then
					out[#out + 1] = e
				end
			end

			towers_cached = out

			return out
		end

		local function tower_by_pos(pos)
			if not pos then
				return nil
			end

			local best, best_d2 = nil, math.huge

			for _, t in ipairs(get_towers()) do
				local dx, dy = pos.x - t.pos.x, pos.y - t.pos.y
				local d2 = dx * dx + dy * dy

				if d2 < best_d2 then
					best_d2 = d2
					best = t
				end
			end

			return best
		end

		this._left_island_up = true
		this._right_island_up = true

		U.sprites_show(this, 1, 1, true)

		if this.render.sprites[2] then
			U.sprites_show(this, 2, 2, true)
		end

		U.animation_start(this, "idle", nil, store.tick_ts, true, 1, true)

		if this.render.sprites[2] then
			U.animation_start(this, "idle", nil, store.tick_ts, true, 2, true)
		end

		local function reveal_group(holders_group)
			if not holders_group then
				return
			end

			for _, hcfg in pairs(holders_group) do
				if not hcfg.objects then
					local holder = hcfg.pos and tower_by_pos(hcfg.pos) or nil

					if holder then
						if U and U.sprites_show then
							U.sprites_show(holder, nil, nil, true)
						end

						if holder.ui then
							holder.ui.can_click = true
						end

						if holder.tower then
							holder.tower.can_hover = true
						end
					end
				else
					local hidden_objects_names = {}

					do
						local controller_upg

						for _, e in pairs(store.entities) do
							if e.template_name == "controller_upgrades_alliance" then
								controller_upg = e

								break
							end
						end

						if controller_upg then
							if controller_upg.coil then
								table.insert(hidden_objects_names, controller_upg.coil)
							end

							if controller_upg.seal then
								table.insert(hidden_objects_names, controller_upg.seal)
							end
						else
							table.insert(hidden_objects_names, "decal_defense_flag")
							table.insert(hidden_objects_names, "decal_defend_point")
						end
					end

					local hidden_objects_y_threshold = 384

					for _, e in pairs(store.entities) do
						if e.pos and hidden_objects_y_threshold <= e.pos.y and e.template_name and table.contains(hidden_objects_names, e.template_name) and U and U.sprites_show then
							U.sprites_show(e, nil, nil, true)
						end
					end
				end

				hcfg.done = true
			end
		end

		reveal_group(this.holders_list and this.holders_list[1])
		reveal_group(this.holders_list and this.holders_list[2])

		for k, unlock_cfg in pairs(this.path_unlocks) do
			for _, pi in pairs(unlock_cfg.paths) do
				P:activate_path(pi)
			end

			for _, pi in pairs(unlock_cfg.terrain_paths) do
				set_path_cells_terrain(pi, TERRAIN_LAND, radius)
			end

			for _, extra_cfg in pairs(unlock_cfg.extra_terrains) do
				set_pos_terrain(extra_cfg.x, extra_cfg.y, extra_cfg.terrain_type, extra_cfg.radius)
			end
		end
	end

	local islands_up = {}

	local function tower_by_pos(pos)
		local towers = table.filter(store.entities, function(k, e)
			return e.tower
		end)
		local min_distance = 9999999
		local tower

		for index, candidate in ipairs(towers) do
			local distance = V.dist(pos.x, pos.y, candidate.pos.x, candidate.pos.y)

			if distance < min_distance or not tower then
				min_distance = distance
				tower = candidate
			end
		end

		return tower
	end

	for _, v in pairs(this.holders_list) do
		for _, hcfg in pairs(v) do
			if hcfg.pos then
				local h = tower_by_pos(hcfg.pos)

				U.sprites_hide(h, nil, nil, true)

				h.ui.can_click = false
				h.tower.can_hover = false
			end
		end
	end

	local controller_upg

	for _, e in pairs(store.entities) do
		if e.template_name == "controller_upgrades_alliance" then
			controller_upg = e

			break
		end
	end

	local hidden_objects_names = {}
	local coil = "decal_defense_flag"
	local seal = "decal_defend_point"

	if controller_upg then
		if controller_upg.coil then
			coil = controller_upg.coil
		end

		if controller_upg.seal then
			seal = controller_upg.seal
		end
	end

	table.insert(hidden_objects_names, coil)
	table.insert(hidden_objects_names, seal)

	local path_flags = table.filter(store.entities, function(k, e)
		if not table.contains(hidden_objects_names, e.template_name) then
			return false
		end

		if not e.pos then
			return false
		end

		for _, rect in pairs(this.hide_exits_rects) do
			if V.is_inside(e.pos, rect) then
				return true
			end
		end

		return false
	end)

	for _, v in pairs(path_flags) do
		U.sprites_hide(v, nil, nil, true)
	end

	if this.modos and not this._deployed_once then
		instant_deploy_islands_1_and_2(this, store)

		this._deployed_once = true
	end

	while true do
		if this.show_path then
			if store.level_idx == 36 then
				for _, e in pairs(store.entities) do
					if e.template_name == "decal_stage_36_easter_egg_spyro" then
						e.leave = true

						break
					end
				end
			end

			table.insert(islands_up, this.show_path)

			local sprite_sid = this.show_path
			local holders_list = this.holders_list[this.show_path]
			local cinematic = this.cinematic[this.show_path]

			this.show_path = nil

			local camera_posX, camera_posY, zoom_value

			if cinematic then
				signal.emit("show-curtains")
				signal.emit("hide-gui")
				signal.emit("start-cinematic")

				--camera_posX = game.camera.x / game.game_scale
				--camera_posY = game.ref_h - game.camera.y / game.game_scale
				--zoom_value = game.camera.zoom

				U.y_wait_unconditional(store, 1.5)
				signal.emit("pan-zoom-camera", cinematic.time, {
					x = cinematic.pos.x,
					y = cinematic.pos.y
				}, cinematic.zoom)
				U.y_wait_unconditional(store, 1.5)
			end

			S:queue("Stage36PathOpen" .. sprite_sid)

			if store.level_idx == 38 then
				local options = {
					delay = 0.6
				}

				S:queue("Stage38OpenPath", options)
			end

			U.sprites_show(this, sprite_sid, sprite_sid, true)
			U.animation_start(this, "in", nil, store.tick_ts, false, sprite_sid)

			if not this.skip_shake then
				local shake = E:create_entity("aura_screen_shake")

				shake.aura.amplitude = 0.5
				shake.aura.duration = 4
				shake.aura.freq_factor = 2

				simulation:queue_insert_entity(shake)
			end

			local start_ts = store.tick_ts

			while true do
				local elapsed_time = store.tick_ts - start_ts
				local holders_yet_to_show = false

				for k, hcfg in pairs(holders_list) do
					if not hcfg.done then
						holders_yet_to_show = true
					end

					if elapsed_time >= hcfg.ts and not hcfg.done then
						if hcfg.shake then
							local shake = E:create_entity("aura_screen_shake")

							shake.aura.amplitude = 0.5
							shake.aura.duration = 1
							shake.aura.freq_factor = 2

							simulation:queue_insert_entity(shake)
						end

						if hcfg.objects then
							for _, v in pairs(path_flags) do
								local fx = E:create_entity(this.show_fx)

								fx.pos.x, fx.pos.y = v.pos.x, v.pos.y
								fx.render.sprites[1].ts = store.tick_ts

								simulation:queue_insert_entity(fx)

								if v.template_name == "decal_upgrade_alliance_seal_of_punishment" then
									fx.pos.y = fx.pos.y - 20
								end

								U.y_wait_unconditional(store, fts(6))
								U.sprites_show(v, nil, nil, true)
							end
						end

						if hcfg.pos then
							local holder = tower_by_pos(hcfg.pos)

							if holder then
								local fx = E:create_entity(this.show_fx)

								fx.pos.x, fx.pos.y = holder.pos.x, holder.pos.y
								fx.render.sprites[1].ts = store.tick_ts

								simulation:queue_insert_entity(fx)
								U.y_wait_unconditional(store, fts(6))
								U.sprites_show(holder, nil, nil, true)

								holder.ui.can_click = true
								holder.tower.can_hover = true
							end
						end

						hcfg.done = true
					end
				end

				if not holders_yet_to_show then
					break
				end

				coroutine.yield()
			end

			for k, unlock_cfg in pairs(this.path_unlocks) do
				local all_islands_up = true

				for _, island in pairs(unlock_cfg.islands_required) do
					if not table.contains(islands_up, island) then
						all_islands_up = false

						break
					end
				end

				if all_islands_up then
					for _, pi in pairs(unlock_cfg.paths) do
						P:activate_path(pi)
					end

					for _, pi in pairs(unlock_cfg.terrain_paths) do
						set_path_cells_terrain(pi, TERRAIN_LAND, radius)
					end

					for _, extra_cfg in pairs(unlock_cfg.extra_terrains) do
						set_pos_terrain(extra_cfg.x, extra_cfg.y, extra_cfg.terrain_type, extra_cfg.radius)
					end

					this.path_unlocks[k] = nil
				end
			end

			U.y_animation_wait_default(this)
			U.animation_start(this, "idle", nil, store.tick_ts, true, sprite_sid, true)

			if cinematic then
				U.y_wait_unconditional(store, 1)
				signal.emit("pan-zoom-camera", 1, {
					x = camera_posX,
					y = camera_posY
				}, zoom_value)
				U.y_wait_unconditional(store, 1)
				signal.emit("hide-curtains")
				signal.emit("show-gui")
				signal.emit("end-cinematic")
				U.y_wait_unconditional(store, 1)
			end
		end

		coroutine.yield()
	end
end

function stage_36_paths_controller.on_show_path(this, store, action, path)
	this.show_path = tonumber(path)
end

tt = E:register_t_hot("decal_stage_38_mask_08", "decal", true)
tt.render.sprites[1].name = "stage_38_mask_08"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_SKY

tt = E:register_t_hot("decal_stage_38_mask_10", "decal", true)
tt.render.sprites[1].name = "stage_38_mask_10"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_SKY

tt = E:register_t_hot("decal_stage_38_to_the_stars", "decal_scripted", true)
E:add_comps(tt, "ui", "editor")
tt.main_script.update = decal_stage_38_to_the_stars_update
tt.render.sprites[1].prefix = "to_the_stars_guy"
tt.render.sprites[1].name = "idle1"
tt.ui.click_rect = r(-60, -20, 70, 70)

tt = E:register_t_hot("decal_stage_38_easter_egg_ender_egg", "decal_scripted", true)
E:add_comps(tt, "ui", "editor")
tt.main_script.insert = decal_stage_38_easter_ender_egg_insert
tt.main_script.update = decal_stage_38_easter_ender_egg_update
tt.render.sprites[1].prefix = "ender_egg_egg"
tt.render.sprites[1].name = "idle"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "ender_egg_mask"
tt.render.sprites[2].ignore_start = true
tt.render.sprites[2].z = Z_OBJECTS_COVERS
tt.render.sprites[2].pos = v(811, 427)
tt.render.sprites[2].animated = false
tt.fx_normal = "fx_ender_egg_explosion_normal"
tt.fx_final = "fx_ender_egg_explosion_final"
tt.ui.click_rect = r(-20, -10, 40, 45)
tt.positions = {{v(621, 131), Z_OBJECTS}, {v(558, 680), Z_OBJECTS}, {v(1103, 603), Z_OBJECTS}, {v(305, 282), Z_OBJECTS}}
tt.last_position = {v(805, 554), Z_OBJECTS_COVERS}
tt.gold_fx = "fx_elemental_metal_holder_coins"
tt.gold_amount = 150

tt = E:register_t_hot("decal_stage_38_mask_02", "decal", true)
tt.render.sprites[1].name = "stage_38_mask_02"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = 106

tt = E:register_t_hot("decal_stage_38_mask_04", "decal", true)
tt.render.sprites[1].name = "stage_38_mask_04"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = -100

tt = E:register_t_hot("decal_stage_38_mask_09", "decal", true)
tt.render.sprites[1].name = "stage_38_mask_09"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_SKY

tt = E:register_t_hot("decal_stage_38_mask_01", "decal", true)
tt.render.sprites[1].name = "stage_38_mask_01"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = 142

tt = E:register_t_hot("decal_stage_38_mask_03", "decal", true)
tt.render.sprites[1].name = "stage_38_mask_03"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = -20

tt = E:register_t_hot("stage_38_paths_controller", "decal_scripted", true)
E:add_comps(tt, "events", "editor")
tt.main_script.update = stage_36_paths_controller.update
tt.render.sprites[1].prefix = "mecanica_camino_stage_3Def"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].exo = true
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_BACKGROUND_BETWEEN
tt.events.list[1].name = "show_path"
tt.events.list[1].on_event = stage_36_paths_controller.on_show_path
tt.skip_shake = true
tt.holders_list = {{{
	ts = fts(165),
	pos = v(235, 210)
}, {
	shake = true,
	ts = fts(165)
}}}
tt.path_unlocks = {{
	islands_required = {1},
	paths = {4},
	terrain_paths = {4},
	extra_terrains = {}
}}
tt.hide_exits_rects = {}
tt.cinematic = {{
	zoom = 1,
	time = fts(67),
	pos = v(200, 300)
}}
tt.show_fx = "fx_stage_36_path_dust"
tt.editor.overrides = {
	["render.sprites[1].hidden"] = false,
	["render.sprites[1].name"] = "idle"
}

tt = E:register_t_hot("decal_stage_38_mask_07", "decal", true)
tt.render.sprites[1].name = "stage_38_mask_07"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = -200

tt = E:register_t_hot("decal_stage_38_mask_islas", "decal_tween", true)
E:add_comps(tt, "main_script")
tt.main_script.insert = decal_stage_36_mask_islas.insert
tt.islas_levels = {
	TOP = Z_BACKGROUND_COVERS + 2,
	MID = Z_BACKGROUND_BETWEEN - 1,
	BACK = Z_BACKGROUND_BETWEEN - 2
}
tt.islas_settings = {
	{
		str = -6,
		z = "BACK",
		freq = 120
	},
	{
		str = -6,
		z = "BACK",
		freq = 120
	},
	{
		str = -6,
		z = "BACK",
		freq = 120
	},
	{
		str = -6,
		z = "BACK",
		freq = 120
	},
	{
		str = -6,
		z = "BACK",
		freq = 120
	},
	{
		str = -6,
		z = "BACK",
		freq = 120
	},
	{
		str = -6,
		z = "BACK",
		freq = 120
	},
	{
		str = -6,
		z = "BACK",
		freq = 120
	},
	{
		str = -6,
		z = "BACK",
		freq = 120
	},
	{
		str = -6,
		z = "BACK",
		freq = 120
	},
	{
		str = -6,
		z = "BACK",
		freq = 120
	}
}
tt.temp_i = 0
for i = 1, #tt.islas_settings do
	if not tt.islas_settings[i].skip then
		tt.temp_i = tt.temp_i + 1
		local str = tt.islas_settings[i].str
		local freq = tt.islas_settings[i].freq
		local z = tt.islas_levels[tt.islas_settings[i].z]
		freq = freq + math.random(-20, 20)
		tt.render.sprites[tt.temp_i] = E:clone_c("sprite")
		tt.render.sprites[tt.temp_i].name = "stage_03_islas_flotantes_00" .. (i < 10 and "0" or "") .. i
		tt.render.sprites[tt.temp_i].animated = false
		tt.render.sprites[tt.temp_i].z = z
		tt.tween.props[tt.temp_i] = E:clone_c("tween_prop")
		tt.tween.props[tt.temp_i].sprite_id = tt.temp_i
		tt.tween.props[tt.temp_i].name = "offset"
		tt.tween.props[tt.temp_i].interp = "sine"
		tt.tween.props[tt.temp_i].keys = {{fts(0), v(0, 0)}, {fts(freq), v(0, -str)}, {fts(freq * 2), v(0, 0)}}
		tt.tween.props[tt.temp_i].loop = true
	end
end
tt.temp_i = nil
tt.tween.remove = false

tt = E:register_t_hot("decal_stage_38_easter_egg_yamcha", "decal_scripted", true)
E:add_comps(tt, "ui", "editor")
tt.main_script.update = decal_stage_38_easter_egg_yamcha.update
tt.render.sprites[1].prefix = "yamcha_warlok"
tt.render.sprites[1].name = "run"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "yamcha_pozo"
tt.render.sprites[2].animated = false
tt.render.sprites[2].ignore_start = true
tt.render.sprites[2].z = Z_DECALS
tt.ui.click_rect = r(-25, -10, 50, 38)

tt = E:register_t_hot("decal_stage_38_fires_exo", "decal", true)
tt.spr_cfgs = {
	{
		sort_y_offset = 0
	},
	{
		sort_y_offset = 0
	},
	{
		sort_y_offset = 0
	},
	{
		sort_y_offset = 0
	},
	[7] = {
		sort_y_offset = 94
	},
	[8] = {
		sort_y_offset = 0
	},
	[9] = {
		sort_y_offset = -100
	}
}
tt.render.sprites[1] = nil

for k, v in pairs(tt.spr_cfgs) do
	local i = #tt.render.sprites + 1

	tt.render.sprites[i] = E:clone_c("sprite")
	tt.render.sprites[i].prefix = "fuego_fx_stage3_fire" .. k .. "Def"
	tt.render.sprites[i].name = "run"
	tt.render.sprites[i].animated = true
	tt.render.sprites[i].exo = true
	tt.render.sprites[i].z = Z_OBJECTS
	tt.render.sprites[i].sort_y_offset = v.sort_y_offset
end

tt = E:register_t_hot("controller_stage_38_cinematic", nil, true)
E:add_comps(tt, "editor", "main_script")
tt.main_script.update = controller_stage_38_cinematic.update

