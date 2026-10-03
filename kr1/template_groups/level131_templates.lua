local E = require("entity_db")
local U = require("utils")
local V = require("lib.klua.vector")
local P = require("path_db")
local S = require("sound_db")
require("lib.klua.table")
local scripts = require("scripts")
local v = V.v
local vv = V.vv
local r = V.r
local decal_stage_31_easter_egg_oogway_update
local decal_stage_31_easter_egg_littledragon_update
decal_stage_31_easter_egg_oogway_update = function(this, store)
	U.animation_start_default(this, "idle1", nil, store.tick_ts, true)
	local next_idle_ts = store.tick_ts + this.idle_cooldown_min + (this.idle_cooldown_max - this.idle_cooldown_min) * math.random()
	local clicks = 0
	::label_1875_0::
	while true do
		if this.ui.clicked then
			clicks = clicks + 1
			this.ui.clicked = nil
			this.ui.can_click = false
			if clicks == 1 then
				U.y_animation_play(this, "tap1", nil, store.tick_ts)
				U.animation_start_default(this, "idle3", nil, store.tick_ts, true)
				this.ui.can_click = true
			elseif clicks == 2 then
				U.y_animation_play(this, "tap2", nil, store.tick_ts)
				U.animation_start_default(this, "idle4", nil, store.tick_ts, true)
				this.ui.can_click = true
			elseif clicks == 3 then
				U.y_animation_play(this, "tap3", nil, store.tick_ts)
				this.ui.can_click = true
			elseif clicks == 4 then
				U.y_animation_play(this, "tap4", nil, store.tick_ts)
				simulation:queue_remove_entity(this)
			end
		end
		if clicks == 0 and next_idle_ts < store.tick_ts then
			next_idle_ts = store.tick_ts + this.idle_cooldown_min + (this.idle_cooldown_max - this.idle_cooldown_min) * math.random()
			U.animation_start_default(this, "idle_2", nil, store.tick_ts, false)
			while not U.animation_finished_default(this) do
				if this.ui.clicked then
					goto label_1875_0
				end
				coroutine.yield()
			end
			U.animation_start_default(this, "idle1", nil, store.tick_ts, true)
		end
		coroutine.yield()
	end
end
decal_stage_31_easter_egg_littledragon_update = function(this, store)
	U.animation_start_default(this, "idle_1", nil, store.tick_ts, true)
	local clicks = 0
	while true do
		if this.ui.clicked and not this.render.sprites[1].hidden then
			clicks = clicks + 1
			this.ui.clicked = nil
			this.ui.can_click = false
			if clicks == 1 then
				U.y_animation_play(this, "tap_1", nil, store.tick_ts, 1, 1)
				U.animation_start(this, "idle_2", nil, store.tick_ts, true, 1, true)
				this.ui.can_click = true
			elseif clicks == 2 then
				U.y_animation_play(this, "tap_2", nil, store.tick_ts, 1, 1)
				U.sprites_hide(this, 1, 1, false)
				return
			end
		end
		coroutine.yield()
	end
end
local tt

tt = E:register_t_tmp("controller_stage_31_water_mechanic", "decal_scripted")
E:add_comps(tt, "ui", "editor")
tt.main_script.update = function(this, store)
	local explained_mechanic = false
	local used_times = 0
	local removing_water_end_ts

	this.removing_water = false

	if store.level_mode == GAME_MODE_HEROIC then
		U.animation_start(this, "empty_idle", nil, store.tick_ts, true, 1, true)

		this.render.sprites[2].hidden = true
		this.render.sprites[1].exo_hide_prefix = {}

		table.insert(this.render.sprites[1].exo_hide_prefix, "asst_fuente_monito")

		this.ui.can_click = false

		return
	elseif store.level_mode == GAME_MODE_IRON then
		used_times = 1e+99
		explained_mechanic = true

		U.animation_start(this, "idle", nil, store.tick_ts, true, 1, true)
	else
		U.animation_start(this, "idle_nomonkey", nil, store.tick_ts, true, 1, true)
	end

	for _, v in pairs(this.extra_ui_click_rects) do
		local extra_touch_object = E:create_entity("generic_extra_touch_controller")

		extra_touch_object.controller = this
		extra_touch_object.pos = V.vclone(this.pos)
		extra_touch_object.ui.click_rect = table.deepclone(v)

		simulation:queue_insert_entity(extra_touch_object)
	end

	local extra_touch_speach_bubble = E:create_entity("generic_extra_touch_controller")

	extra_touch_speach_bubble.controller = this
	extra_touch_speach_bubble.pos = V.vclone(this.pos)
	extra_touch_speach_bubble.ui.click_rect = table.deepclone(this.extra_ui_click_rect_speach_bubble)
	extra_touch_speach_bubble.ui.can_click = false

	simulation:queue_insert_entity(extra_touch_speach_bubble)

	local bloon_ts = store.tick_ts + math.random(10, 20)
	local cooldown_loop_times = math.ceil(this.cooldown / 5)
	local warning_check_ts = store.tick_ts + fts(10)
	local hand_check_ts = store.tick_ts + fts(10)
	local hand_id

	local function show_tap_hand()
		do
			return
		end

		if used_times > 1 then
			return
		end

		if not hand_check_ts then
			return
		end

		if store.tick_ts < hand_check_ts then
			return
		end

		if hand_id and store.entities[hand_id] then
			return
		end

		local hand = E:create_entity(this.hand_decal_t)

		hand.pos = V.v(this.pos.x, this.pos.y + 10)
		hand.render.sprites[1].ts = store.tick_ts
		hand.tween.ts = store.tick_ts
		hand.tween.disabled = true

		simulation:queue_insert_entity(hand)

		hand_id = hand.id
		hand_check_ts = store.tick_ts + fts(70)
	end

	local function stop_hand()
		if not hand_id then
			return
		end

		local hand = store.entities[hand_id]

		hand_id = nil

		if not hand then
			return
		end

		simulation:queue_remove_entity(hand)
	end

	local previous_enemies_ids = {}

	local function can_do_warning(ignore_ts)
		if used_times > 1 then
			return false
		end

		if not ignore_ts and warning_check_ts and store.tick_ts < warning_check_ts then
			return false
		end

		if store.wave_group_number < this.unlock_wave then
			if store.wave_group_number == this.unlock_wave - 1 then
				local targets = table.filter(store.entities, function(k, v)
					return v.pos and v.enemy
				end)

				previous_enemies_ids = {}

				for _, e in ipairs(targets) do
					table.insert(previous_enemies_ids, e.id)
				end

				warning_check_ts = store.tick_ts + fts(70)
			end

			return false
		end

		local targets = table.filter(store.entities, function(k, v)
			return v.pos and scripts.controller_stage_31_water_mechanic.is_in_water_range(this, v, true)
		end)

		if targets then
			local allow_amount = 0

			for _, t in ipairs(targets) do
				local allow = t.enemy and not table.contains(previous_enemies_ids, t.id) and table.contains(this.enemies_detection, t.template_name) or t.is_flaming_ground

				if allow then
					allow_amount = allow_amount + 1

					if explained_mechanic or allow_amount >= this.first_warn_minimum_targets then
						return true
					end
				end
			end
		end

		warning_check_ts = store.tick_ts + fts(10)

		return false
	end

	local function manage_warning()
		if can_do_warning() then
			show_tap_hand()

			if not explained_mechanic then
				U.y_animation_play(this, "monkey_in", nil, store.tick_ts, 1, 1)
			else
				U.y_animation_play(this, "idle_talk_in", nil, store.tick_ts, 1, 1)
			end

			explained_mechanic = true

			U.animation_start(this, "talk_loop", nil, store.tick_ts, true, 1, true)

			extra_touch_speach_bubble.ui.can_click = true

			while true do
				show_tap_hand()

				if not can_do_warning(true) then
					stop_hand()

					extra_touch_speach_bubble.ui.can_click = false

					U.y_animation_play(this, "talk_to_idle", nil, store.tick_ts, 1, 1)
					U.animation_start(this, "idle", nil, store.tick_ts, true, 1, true)

					break
				elseif this.ui.clicked then
					stop_hand()

					extra_touch_speach_bubble.ui.can_click = false

					U.y_animation_play(this, "talk_to_idol_off", nil, store.tick_ts, 1, 1)

					break
				end

				coroutine.yield()
			end
		end
	end

	local function removing_water_end()
		if this.render.sprites[2].name == "active_in" and U.animation_finished(this, 2, 1) then
			U.animation_start(this, "active_loop", nil, store.tick_ts, true, 2, true)
		elseif this.render.sprites[2].name == "active_loop" then
			U.animation_start(this, "active_end", nil, store.tick_ts, false, 2, true)
		elseif this.render.sprites[2].name == "active_end" and U.animation_finished(this, 2, 1) then
			U.animation_start(this, "idle", nil, store.tick_ts, true, 2, true)
		end

		if not removing_water_end_ts then
			return
		end

		if store.tick_ts < removing_water_end_ts then
			return
		end

		this.removing_water = false
		removing_water_end_ts = nil
	end

	while true do
		if this.ui.clicked then
			this.ui.clicked = nil
			this.ui.can_click = false

			if not explained_mechanic then
				S:queue("Stage31FountainTapoon")
				U.y_animation_play(this, "idle_shake", nil, store.tick_ts, 1, 1)
				U.animation_start(this, "idle_nomonkey", nil, store.tick_ts, true, 1, true)

				this.ui.clicked = nil
				this.ui.can_click = true
			else
				S:queue(this.sound_tap)

				used_times = used_times + 1
				hand_check_ts = nil

				if hand_id then
					local hand = store.entities[hand_id]

					if hand then
						simulation:queue_remove_entity(hand)
					end

					hand_id = nil
				end

				S:queue("Stage31FountainSplash")
				U.animation_start(this, "idol_off", nil, store.tick_ts, false, 1, true)
				U.y_wait_unconditional(store, fts(39))
				U.animation_start(this, "active_in", nil, store.tick_ts, false, 2, true)

				for i = 1, #this.path do
					local ni = this.nodes[i][1]

					while ni <= this.nodes[i][2] do
						local fx = E:create_entity(this.fx_entity)

						fx.pos = P:node_pos(this.path[i], 1, ni)

						simulation:queue_insert_entity(fx)

						local fx_decal = E:create_entity(this.fx_entity_decal)

						fx_decal.pos = fx.pos
						fx_decal.added_scale = 0.7 + 0.3 * math.random()

						simulation:queue_insert_entity(fx_decal)

						ni = ni + this.spawn_every_nodes
					end

					ni = this.nodes[i][1]

					while ni <= this.nodes[i][2] do
						local fx = E:create_entity(this.fx_entity)

						fx.pos = P:node_pos(this.path[i], table.random({2, 3}), ni)

						simulation:queue_insert_entity(fx)

						ni = ni + math.ceil(this.spawn_every_nodes * 0.5 + (this.spawn_every_nodes * 1.5 - this.spawn_every_nodes * 0.5) * math.random())
					end
				end

				U.y_wait_unconditional(store, fts(2))

				this.removing_water = true

				local targets = table.filter(store.entities, function(k, v)
					return v.pos and scripts.controller_stage_31_water_mechanic.is_in_water_range(this, v)
				end)
				local fire_buff_mods_cache = table.filter(store.entities, function(k, v)
					return v.modifier and v.modifier.is_fire_buff
				end)

				store.level.last_use_fountain_kills = 0

				for i, target in ipairs(targets) do
					if target.is_flaming_ground then
						target.duration = 0
					elseif target.enemy then
						for _, m in pairs(fire_buff_mods_cache) do
							if m.modifier.target_id == target.id then
								simulation:queue_remove_entity(m)
							end
						end

						for _, mod_name in pairs(this.mods) do
							local mod = E:create_entity(mod_name)

							mod.modifier.target_id = target.id
							mod.modifier.source_id = this.id

							simulation:queue_insert_entity(mod)
						end
					end
				end

				removing_water_end_ts = store.tick_ts + fts(6) + this.duration

				while not U.animation_finished_default(this) do
					removing_water_end()
					coroutine.yield()
				end

				U.animation_start(this, "attack", nil, store.tick_ts, false, 1, true)

				while not U.animation_finished_default(this) do
					removing_water_end()
					coroutine.yield()
				end

				U.animation_start(this, "cooldown_loop", nil, store.tick_ts, true, 1, true)

				while not U.animation_finished(this, 1, cooldown_loop_times) do
					removing_water_end()
					coroutine.yield()
				end

				S:queue("Stage31FountainRefill")
				U.y_animation_play(this, "cooldown_end", nil, store.tick_ts, 1, 1)

				this.ui.can_click = true
				bloon_ts = store.tick_ts + math.random(5, 30)

				U.animation_start(this, "idle", nil, store.tick_ts, true, 1, true)
			end
		end

		if explained_mechanic and bloon_ts < store.tick_ts then
			U.animation_start(this, "idle_bloons", nil, store.tick_ts, false, 1, true)

			while not U.animation_finished_default(this) and not this.ui.clicked do
				manage_warning()
				coroutine.yield()
			end

			if not this.ui.clicked then
				U.animation_start(this, "idle", nil, store.tick_ts, true, 1, true)
			end

			bloon_ts = store.tick_ts + math.random(20, 50)
		end

		manage_warning()
		coroutine.yield()
	end
end
tt.duration = 4
tt.cooldown = 50
tt.path = {1, 4}
tt.nodes = {{46, 138}, {50, 130}}
tt.warn_duration = 5
tt.unlock_wave = 4
tt.spawn_every_nodes = 9
tt.check_every = 3
tt.check_radius = 60
tt.first_warn_minimum_targets = 3
tt.fx_entity = "stage_31_water_mechanic_fx"
tt.fx_entity_decal = "stage_31_water_mechanic_fx_decal"
tt.hand_decal_t = "dlc2_generic_tap_hand"
tt.render.sprites[1].prefix = "fuente_unitDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "water_cracksDef"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].exo = true
tt.render.sprites[2].sort_y_offset = 0
tt.render.sprites[2].z = Z_DECALS - 1
tt.render.sprites[2].pos = v(512, 384)
tt.ui.has_nav_mesh = true
tt.ui.click_rect = r(-50, -90, 103, 190)
tt.extra_ui_click_rects = {r(-120, -60, 243, 120), r(-85, -80, 173, 160)}
tt.extra_ui_click_rect_speach_bubble = r(50, 58, 78, 67)
tt.mods = {"mod_stage31_water_mechanic_dps"}
tt.enemies_detection = {"enemy_fire_phoenix", "enemy_fire_fox", "enemy_nine_tailed_fox", "enemy_burning_treant", "enemy_ash_spirit"}

tt = E:register_t_tmp("stage_31_water_mechanic_fx", "decal_scripted")
tt.main_script.update = function(this, store)
	U.sprites_hide(this, nil, nil)
	U.y_wait_unconditional(store, math.random() * fts(8))
	U.sprites_show(this, nil, nil)
	U.y_animation_play(this, "run", nil, store.tick_ts, 1, 1)
	simulation:queue_remove_entity(this)
end
tt.render.sprites[1].prefix = "water_splash_unitDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true

tt = E:register_t_tmp("stage_31_water_mechanic_fx_decal", "decal_tween")
E:add_comps(tt, "main_script")
tt.render.sprites[1].prefix = "charco_unitDef"
tt.render.sprites[1].name = "Idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.duration = 4
tt.added_scale = 1

function tt.main_script.insert(this, store)
	this.render.sprites[1].ts = store.tick_ts
	this.tween.ts = store.tick_ts
	this.render.sprites[1].flip_x = math.random() > 0.5

	local start_delay = math.random() * fts(8)

	this.tween.props[1].keys = {{0, 0}, {start_delay, 0}, {start_delay + fts(7), 255}, {start_delay + fts(7) + this.duration, 255}, {start_delay + fts(7) + this.duration + fts(27), 0}}
	this.tween.props[2].keys = {{0, vv(0.8 * this.added_scale)}, {start_delay, vv(0.8 * this.added_scale)}, {start_delay + fts(7), vv(1 * this.added_scale)}, {start_delay + fts(7) + this.duration, vv(1 * this.added_scale)}, {start_delay + fts(7) + this.duration + fts(27), vv(0.8 * this.added_scale)}}

	return true
end

tt.tween.props[1].keys = {{0, 0}, {fts(2), 0}, {fts(7), 255}, {fts(7) + tt.duration, 255}, {fts(7) + tt.duration + fts(27), 0}}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].keys = {{0, vv(0.8)}, {fts(2), vv(0.8)}, {fts(7), vv(1)}, {fts(7) + tt.duration, vv(1)}, {fts(7) + tt.duration + fts(27), vv(0.8)}}
tt.tween.props[2].name = "scale"

for i = 1, 3 do
	tt = E:register_t_tmp("stage_31_exo_forest_" .. i, "decal")
	E:add_comps(tt, "editor_script")
	tt.render.sprites[1].prefix = "stage_31_forest_0" .. i .. "Def"
	tt.render.sprites[1].name = "loop"
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].exo = true
	tt.show_in_editor = false
	tt.editor_script.insert = scripts.editor_mask.insert

	if i == 3 then
		tt.render.sprites[1].z = Z_OBJECTS + 1
		tt.render.sprites[1].sort_y_offset = -700
	else
		tt.render.sprites[1].z = Z_DECALS
	end
end

for lyr_nmbr = 1, 7 do
	tt = E:register_t_tmp("stage_31_exo_waterfall_layer_" .. lyr_nmbr, "decal")
	tt.render.sprites[1].prefix = "stage_31_waterfall_layer_" .. lyr_nmbr .. "Def"
	tt.render.sprites[1].name = "loop"
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_OBJECTS

	if lyr_nmbr == 1 then
		tt.render.sprites[1].sort_y_offset = -201
	elseif lyr_nmbr == 2 then
		tt.render.sprites[1].sort_y_offset = -200
	elseif lyr_nmbr == 3 then
		tt.render.sprites[1].sort_y_offset = 3
	elseif lyr_nmbr == 4 then
		tt.render.sprites[1].sort_y_offset = 4
	elseif lyr_nmbr == 5 then
		tt.render.sprites[1].sort_y_offset = 5
	elseif lyr_nmbr == 6 then
		tt.render.sprites[1].sort_y_offset = 220
	elseif lyr_nmbr == 7 then
		tt.render.sprites[1].sort_y_offset = 2001
	end
end

tt = E:register_t_hot("decal_stage_31_easter_egg_oogway", "decal_scripted", true)
E:add_comps(tt, "ui", "editor")
tt.main_script.update = decal_stage_31_easter_egg_oogway_update
tt.render.sprites[1].prefix = "stage_31_oogwayDef"
tt.render.sprites[1].name = "idle1"
tt.render.sprites[1].exo = true
tt.idle_cooldown_max = 20
tt.idle_cooldown_min = 5
tt.ui.click_rect = r(-30, -20, 60, 60)

tt = E:register_t_hot("fx_stage_31_fireball_b", "fx", true)
tt.render.sprites[1].prefix = "stage_31_fireball_BDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.kill_area_id = 2

tt = E:register_t_hot("decal_stage_31_easter_egg_littledragon", "decal_scripted", true)
E:add_comps(tt, "ui", "editor")
tt.main_script.update = decal_stage_31_easter_egg_littledragon_update
tt.render.sprites[1].prefix = "littledragon_easteregg_stage1_easteregg"
tt.render.sprites[1].name = "idle_1"
tt.render.sprites[1].sort_y_offset = -30
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "littledragon_easteregg_stage1_easter_egg_dead"
tt.render.sprites[2].animated = false
tt.render.sprites[2].offset = v(5, -30)
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].name = "littledragon_easteregg_stage1_tree"
tt.render.sprites[3].animated = false
tt.render.sprites[3].anchor = v(0, 0)
tt.render.sprites[3].offset = v(-69, -23)
tt.ui.click_rect = r(-30, -20, 60, 60)

tt = E:register_t_hot("stage_31_mask_shadow_top", "decal", true)
tt.render.sprites[1].prefix = "stage_31_shadowDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_SKY

tt = E:register_t_hot("fx_stage_31_fireball_a", "fx", true)
tt.render.sprites[1].prefix = "stage_31_fireball_ADef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.kill_area_id = 1

tt = E:register_t_hot("fx_stage_31_fireball_c", "fx", true)
tt.render.sprites[1].prefix = "stage_31_fireball_CDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.kill_area_id = 3

tt = E:register_t_hot("stage_31_mask_burned_01", "decal", true)
E:add_comps(tt, "editor", "editor_script")
tt.render.sprites[1].name = "stage_31_mask_burned_01"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = -60
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt.render.sprites[1].hidden = true
tt.show_in_editor = true
tt.editor_script.insert = scripts.editor_mask.insert

tt = E:register_t_hot("stage_31_mask_burned_02", "stage_31_mask_burned_01", true)
tt.render.sprites[1].name = "stage_31_mask_burned_02"
tt.render.sprites[1].sort_y_offset = -112

tt = E:register_t_hot("stage_31_mask_burned_03", "stage_31_mask_burned_01", true)
tt.render.sprites[1].name = "stage_31_mask_burned_03"
tt.render.sprites[1].sort_y_offset = -80

tt = E:register_t_hot("stage_31_exo_fire_a", "decal", true)
E:add_comps(tt, "editor", "editor_script")
tt.render.sprites[1].prefix = "stage_31_fire_ADef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].sort_y_offset = 0
tt.render.sprites[1].z = Z_BACKGROUND_COVERS + 1
tt.render.sprites[1].hidden = true
tt.show_in_editor = true
tt.editor_script.insert = scripts.editor_mask.insert

tt = E:register_t_hot("stage_31_exo_fire_c", "stage_31_exo_fire_a", true)
tt.render.sprites[1].prefix = "stage_31_fire_CDef"

tt = E:register_t_hot("stage_31_exo_fire_b", "stage_31_exo_fire_a", true)
tt.render.sprites[1].prefix = "stage_31_fire_BDef"
