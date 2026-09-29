local P = require("path_db")
local U = require("utils")
local V = require("lib.klua.vector")
local log = require("lib.klua.log"):new("level215")
local signal = require("lib.hump.signal")
local function fts(v)
	return v / FPS
end
local function find_all_t(store, template_name, contains, fn)
	if not store or not store.entities then
		return {}
	end
	return table.filter(store.entities, function(k, val)
		return (contains and string.find(val.template_name, template_name) or val.template_name == template_name) and (not fn or fn(k, val))
	end)
end
local function get_random_round_robin(mutable_history, n, m)
	if not m then
		m = n
		n = 1
	end
	if #mutable_history == 0 then
		for i = n, m do
			table.insert(mutable_history, i)
		end
	end
	local pos = math.random(1, #mutable_history)
	local value = mutable_history[pos]
	table.remove(mutable_history, pos)
	return value
end
local function random_point_in_ellipse(cx, cy, a, b)
	local t = 2 * math.pi * math.random()
	local r = math.sqrt(math.random())
	local x = r * math.cos(t)
	local y = r * math.sin(t)
	return cx + x * a, cy + y * b
end
local function generate_blue_noise_cluster(count, candidates, random_fn, ...)
	local points = {}
	local x, y = random_fn(...)
	points[1] = {
		x = x,
		y = y
	}
	for i = 2, count do
		local best_candidate
		local best_distance2 = -1
		for c = 1, candidates do
			local px, py = random_fn(...)
			local min_dist2 = math.huge
			for _, p in ipairs(points) do
				local d2 = V.dist2(px, py, p.x, p.y)
				if d2 < min_dist2 then
					min_dist2 = d2
				end
			end
			if best_distance2 < min_dist2 then
				best_distance2 = min_dist2
				best_candidate = {
					x = px,
					y = py
				}
			end
		end
		points[i] = best_candidate
	end
	return points
end
local E = require("entity_db")
local scripts = require("scripts")
local S = require("sound_db")
local v = V.v
local r = V.r
local function AC(tpl, ...)
	return E:add_comps(tpl, ...)
end
local function queue_insert(store, e)
	simulation:queue_insert_entity(e)
end
local function queue_remove(store, e)
	simulation:queue_remove_entity(e)
end
local function witch_update(this, store, script)
	local cauldron = find_all_t(store, this.cauldron_t)[1]
	this.reaction = function()
		this.react = true
	end
	while true do
		if this.cinematic_start then
			this.cinematic_start = false
			U.animation_start(this, "dialog", nil, store.tick_ts, true, 1)
			U.y_wait(store, 9.5 + fts(1))
			U.animation_start(this, "run", nil, store.tick_ts, false, 1)
			U.y_wait(store, this.potion_time)
			S:queue(this.sound_conjure_potion)
			U.y_animation_wait(this, 1, 1)
			this.render.sprites[1].hidden = true
			U.y_animation_play(cauldron, "witchappears", nil, store.tick_ts, 1, 1)
			U.animation_start(cauldron, "idle", nil, store.tick_ts, true, 1)
			queue_remove(store, this)
			return
		end
		coroutine.yield()
	end
end
local function cauldron_update(this, store, script)
	while true do
		if this.ui and this.ui.clicked then
			U.y_animation_play(this, "tap", nil, store.tick_ts, 1, 1)
			U.animation_start(this, "idle", nil, store.tick_ts, true, 1)
			this.ui.clicked = false
		end
		coroutine.yield()
	end
end
local function swamp_spawner_update(this, store, script)
	local spawn_set = this.spawn_data
	local aux = {}
	for i = 1, spawn_set[2] do
		local e, s_pos, pi, spi, ni
		local spawn_points = store.entities[spawn_set[4]]
		if spawn_set[5] then
			s_pos = spawn_points.center_spawn
			pi, spi, ni = spawn_set[3], 1, 1
		else
			s_pos = spawn_points.graveyard.spawn_pos[get_random_round_robin(aux, #spawn_points.graveyard.spawn_pos)]
			local nearest_nodes = P:nearest_nodes(s_pos.x, s_pos.y, spawn_set[3] and {spawn_set[3]} or nil, {1, 2, 3})
			if #nearest_nodes < 1 then
				log.error("swamps controller %s could not spawn enemy. node not found near %s,%s", this.id, s_pos.x, s_pos.y)
				break
			end
			pi, spi, ni = unpack(nearest_nodes[1])
		end
		local enemy = spawn_set[1]
		if not U.is_seen(store, enemy) then
			signal.emit("wave-notification", "icon", enemy)
			U.mark_seen(store, enemy)
		end
		e = E:create_entity(enemy)
		e.nav_path.pi, e.nav_path.spi, e.nav_path.ni = pi, spi, ni
		e.pos = V.vclone(s_pos)
		e.render.sprites[1].name = "raise"
		e.motion.forced_waypoint = P:node_pos(e.nav_path.pi, e.nav_path.spi, e.nav_path.ni)
		queue_insert(store, e)
		U.y_wait(store, this.spawn_interval)
	end
	queue_remove(store, this)
end
local function swamps_spawn_event(this, store, spawn, path_id, amount, force_center)
	local int_pid = tonumber(path_id)
	local int_am = tonumber(amount)
	local swamp_id = this.path_spawner_map[int_pid]
	local swamp = find_all_t(store, this.swamp_t, false, function(k, value)
		return value.swamp_id == swamp_id
	end)[1]
	if not swamp then
		log.error("ERROR: No swamp found of id: %s", swamp_id)
		return
	end
	local spawner = E:create_entity(this.spawner_t)
	spawner.spawn_data = {spawn, int_am, int_pid, swamp.id, force_center}
	queue_insert(store, spawner)
end
local function swamps_on_event_1(this, store, action, path_id, amount)
	swamps_spawn_event(this, store, "enemy_swamp_husk", path_id, amount)
end
local function swamps_on_event_2(this, store, action, path_id)
	swamps_spawn_event(this, store, "enemy_swamp_thing_kr6", path_id, "1", true)
end
local function swamp_bubbles_on_start(this, store, action, path_id)
	local int_pid = tonumber(path_id)
	local swamp_id = this.path_spawner_map[int_pid]
	local bubbler = find_all_t(store, this.bubble_spawner_t, false, function(k, value)
		return value.swamp_id == swamp_id
	end)[1]
	if not bubbler then
		log.error("ERROR: No swamp found of id: %s", swamp_id)
		return
	end
	bubbler.bubble = true
	bubbler.spawn_data = {this.bubble_count, this.bubble_scales, this.bubble_intervals}
end
local function swamp_bubbles_on_end(this, store, action, path_id)
	local int_pid = tonumber(path_id)
	local swamp_id = this.path_spawner_map[int_pid]
	local bubbler = find_all_t(store, this.bubble_spawner_t, false, function(k, value)
		return value.swamp_id == swamp_id
	end)[1]
	if not bubbler then
		log.error("ERROR: No swamp found of id: %s", swamp_id)
		return
	end
	bubbler.bubble = false
end
local function swamp_bubbles_spawner_update(this, store, script)
	local bubble_positions = generate_blue_noise_cluster(8, 40, random_point_in_ellipse, this.pos.x, this.pos.y, this.radius, this.radius * 0.7)
	local bubbling = false
	local bubbles = {}
	local sound_ts
	while true do
		if this.bubble and not bubbling then
			bubbling = true
			sound_ts = store.tick_ts + U.frandom(this.bubble_sound_interval[1], this.bubble_sound_interval[2])
			local bubble_count_range = this.spawn_data[1]
			local bubble_scale_range = this.spawn_data[2]
			local bubble_interval_range = this.spawn_data[3]
			local aux = {}
			for i = 1, math.random(bubble_count_range[1], bubble_count_range[2]) do
				local scale = U.frandom(bubble_scale_range[1], bubble_scale_range[2])
				local bubble_pos = bubble_positions[get_random_round_robin(aux, 8)]
				local bubble = E:create_entity(this.bubble_t)
				bubble.duration = 1e+99
				bubble.pos = V.v(bubble_pos.x, bubble_pos.y)
				bubble.render.sprites[1].scale = V.vv(scale)
				queue_insert(store, bubble)
				table.insert(bubbles, bubble)
				U.y_wait(store, U.frandom(bubble_interval_range[1], bubble_interval_range[2]))
			end
		end
		if not this.bubble and bubbling then
			bubbling = false
			local bubble_interval_range = this.spawn_data[3]
			for i, b in ipairs(bubbles) do
				b.duration = 0
				U.y_wait(store, U.frandom(bubble_interval_range[1], bubble_interval_range[2]))
			end
			bubbles = {}
		end
		if bubbling and sound_ts <= store.tick_ts then
			S:queue(this.bubble_sound)
			sound_ts = store.tick_ts + U.frandom(this.bubble_sound_interval[1], this.bubble_sound_interval[2])
		end
		coroutine.yield()
	end
end
local function bubble_decorations_update(this, store, script)
	local decals = find_all_t(store, this.decal_t)
	if not decals or #decals == 0 then
		log.error("ERROR: No decals on stage to cause bubbles.")
		queue_remove(store, this)
		return
	end
	for i, d in ipairs(decals) do
		d.render.sprites[1].hidden = true
	end
	while this.disabled do
		coroutine.yield()
	end
	local temp = {}
	while true do
		U.y_wait(store, math.random(this.bubble_cd_min, this.bubble_cd_max))
		local bi = get_random_round_robin(temp, 1, #decals)
		decals[bi].render.sprites[1].hidden = false
		U.animation_start(decals[bi], "loop", nil, store.tick_ts, false, 1)
	end
end
local function accusation_update(this, store, script)
	local cauldron = find_all_t(store, this.cauldron_t)[1]
	while true do
		if this.cinematic_trigger then
			local bb = find_all_t(store, this.blackburn_t)[1]
			if bb.health.dead then
				bb.force_respawn = true
			end
			bb.unit.is_stunned = true
			U.animation_start(bb, "idle", nil, store.tick_ts, true, 1)
			signal.emit("show-curtains")
			signal.emit("hide-gui")
			signal.emit("start-cinematic")
			signal.emit("pan-zoom-camera", 2, {
				x = 300,
				y = 500
			}, 1.5)
			local mod = E:create_entity(this.mod_t)
			mod.modifier.target_id = bb.id
			mod.target_pos = this.target_pos
			queue_insert(store, mod)
			local pre_wait_ts = store.tick_ts
			U.y_wait(store, 1e+99, function()
				return math.abs(bb.pos.x - this.target_pos.x) < 1 and math.abs(bb.pos.y - this.target_pos.y) < 1
			end)
			bb.cutscene = true
			bb.health_bar.hidden = true
			if store.tick_ts - pre_wait_ts < 1.9 then
				U.y_wait(store, 1.9 - (store.tick_ts - pre_wait_ts))
			end
			S:queue(this.sound_energy)
			bb.render.sprites[1].flip_x = bb.pos.x > cauldron.pos.x + cauldron.ui.click_rect.pos.x
			bb.corrupt = true
			U.y_wait(store, fts(61) + 1)
			local bb_balloon_pos = V.v(bb.pos.x - 6, bb.pos.y + 60)
			signal.emit("show-balloon_tutorial-pos", "S15_MID_01", false, bb_balloon_pos)
			U.y_wait(store, 3.5)
			local witch_balloon_pos = cauldron.dialog_pos
			signal.emit("show-balloon_tutorial-pos", "S15_MID_02", false, witch_balloon_pos)
			U.y_wait(store, 3.5)
			signal.emit("show-balloon_tutorial-pos", "S15_MID_03", false, bb_balloon_pos)
			U.y_wait(store, 3.5)
			U.y_wait(store, fts(111) - 2)
			signal.emit("show-balloon_tutorial-pos", "S15_MID_04", false, witch_balloon_pos)
			U.y_wait(store, 3)
			S:queue(this.sound_boil, {
				delay = fts(14)
			})
			S:queue(this.sound_kick, {
				delay = 3.65
			})
			S:queue(this.sound_splash, {
				delay = 4.5
			})
			U.animation_start(cauldron, "cinematic", nil, store.tick_ts, false, 1)
			U.y_wait(store, fts(133))
			local bubbles_controller = find_all_t(store, this.bubbles_controller_t)[1]
			swamp_bubbles_on_start(bubbles_controller, store, nil, "5")
			local bubbles_random_controller = find_all_t(store, this.random_bubbles_controller_t)[1]
			bubbles_random_controller.disabled = false
			local new_mist = E:create_entity(this.mist_t)
			new_mist.pos.x, new_mist.pos.y = 512, 384
			new_mist.render.sprites[1].ts = store.tick_ts
			queue_insert(store, new_mist)
			local mask_1 = E:create_entity(this.swamp_mask_1_t)
			mask_1.pos.x, mask_1.pos.y = 512, 384
			mask_1.tween.ts = store.tick_ts
			queue_insert(store, mask_1)
			local mask_2 = E:create_entity(this.swamp_mask_2_t)
			mask_2.pos.x, mask_2.pos.y = 512, 384
			mask_2.tween.ts = store.tick_ts
			queue_insert(store, mask_2)
			U.y_wait(store, fts(15))
			U.animation_start(new_mist, "loop", nil, store.tick_ts, true, 1)
			U.y_wait(store, fts(24))
			swamp_bubbles_on_start(bubbles_controller, store, nil, "6")
			U.y_animation_wait(cauldron, 1)
			queue_remove(store, mod)
			signal.emit("hide-curtains")
			signal.emit("show-gui")
			signal.emit("end-cinematic")
			signal.emit("accusation_cinematic_end")
			bb.cutscene = false
			local p = V.v(320, 590)
			local swamp_thing_t = "enemy_swamp_thing_kr6"
			local swamp_thing = E:create_entity(swamp_thing_t)
			local nn = P:nearest_nodes(p.x, p.y, {5}, {1, 2, 3}, true)[1]
			swamp_thing.nav_path.pi = nn[1]
			swamp_thing.nav_path.spi = 1
			swamp_thing.nav_path.ni = nn[3]
			swamp_thing.pos.x, swamp_thing.pos.y = p.x, p.y
			queue_insert(store, swamp_thing)
			if not U.is_seen(store, swamp_thing_t) then
				signal.emit("wave-notification", "icon", swamp_thing_t)
				U.mark_seen(store, swamp_thing_t)
			end
			U.animation_start(cauldron, "cinematic2", nil, store.tick_ts, false, 1)
			U.y_animation_wait(cauldron, 1)
			cauldron.ui.can_click = false
			queue_remove(store, this)
			return
		end
		coroutine.yield()
	end
end
local function accusation_on_event(this, store, action)
	this.cinematic_trigger = true
end
local function ring_update(this, store, script)
	local loop_2_ts = store.tick_ts
	local function queue_tap_sounds()
		if this.sound_lid_open then
			S:queue(this.sound_lid_open, {
				delay = fts(this.sound_lid_open_frame)
			})
		end
		for i, id in ipairs(this.sound_samara_glitch or {}) do
			S:queue(id, {
				delay = fts(this.sound_samara_glitch_frames[i])
			})
		end
	end
	while true do
		if store.tick_ts - loop_2_ts > this.loop_2_cd then
			U.animation_start(this, "loop_2", nil, store.tick_ts, false, 1)
			while not U.animation_finished(this) do
				if this.ui and this.ui.clicked then
					this.ui.clicked = false
					queue_tap_sounds()
					U.y_animation_play(this, "tap", nil, store.tick_ts, 1, 1)
					U.animation_start(this, "loop_3", nil, store.tick_ts, true, 1)
					return
				end
				coroutine.yield()
			end
			loop_2_ts = store.tick_ts
			U.animation_start(this, "loop_1", nil, store.tick_ts, true, 1)
		end
		if this.ui and this.ui.clicked then
			this.ui.clicked = false
			queue_tap_sounds()
			U.y_animation_play(this, "tap", nil, store.tick_ts, 1, 1)
			U.animation_start(this, "loop_3", nil, store.tick_ts, true, 1)
			return
		end
		coroutine.yield()
	end
end
local function simpsons_fish_update(this, store, script)
	local clicks = 0
	local ts = store.tick_ts
	U.y_animation_wait(this)
	U.animation_start(this, "idle", nil, store.tick_ts, true)
	while true do
		::label_1400_0::
		if this.ui and this.ui.clicked then
			this.ui.clicked = false
			clicks = clicks + 1
			if clicks == 1 then
				S:queue(this.sound_tap_1)
				U.animation_start(this, "tap", nil, store.tick_ts, false)
				while not U.animation_finished(this) do
					if this.ui.clicked then
						goto label_1400_0
					end
					coroutine.yield()
				end
			elseif clicks == 2 then
				S:queue(this.sound_tap_2)
				U.y_animation_play(this, "tap_final", nil, store.tick_ts, 1)
				signal.emit("three-eyes-on-every-fish-stage15", this)
				queue_remove(store, this)
				return
			end
		end
		if store.tick_ts - ts > this.duration then
			U.y_animation_play(this, "disappear", nil, store.tick_ts, 1)
			queue_remove(store, this)
			return
		end
		coroutine.yield()
	end
end
local function simpsons_controller_update(this, store, script)
	while true do
		if store.wave_group_number > 6 then
			local random = math.random(this.min_time, this.max_time)
			U.y_wait(store, random)
			local f = E:create_entity(this.fish_t)
			f.pos = V.vclone(this.spawn_pos[math.random(1, #this.spawn_pos)])
			queue_insert(store, f)
		end
		coroutine.yield()
	end
end
local tt = E:register_t_hot("decal_stage_215_mask_1", "decal", true)
tt.render.sprites[1].name = "Stage_15_Mask_01"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = -110
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t_hot("decal_stage_215_mask_2", "decal", true)
tt.render.sprites[1].name = "Stage_15_Mask_02"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t_hot("decal_stage_215_mask_3", "decal", true)
tt.render.sprites[1].name = "Stage_15_Mask_03"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = 49
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t_hot("decal_stage_215_mask_4", "decal", true)
tt.render.sprites[1].name = "Stage_15_Mask_04"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = 268
tt = E:register_t_hot("decal_stage_215_mask_5", "decal_tween", true)
tt.render.sprites[1].name = "Stage_15_Mask_05"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS - 1
tt.tween.props[1].keys = {{0, 0}, {fts(28), 255}}
tt.tween.remove = false
tt.tween.reverse = false
tt.tween.run_once = true
tt = E:register_t_hot("decal_stage_215_mask_6", "decal_tween", true)
tt.render.sprites[1].name = "Stage_15_Mask_06"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS - 1
tt.tween.props[1].keys = {{0, 0}, {fts(28), 255}}
tt.tween.remove = false
tt.tween.reverse = false
tt.tween.run_once = true
tt = E:register_t_hot("decal_stage_215_water_ripples", "decal", true)
tt.render.sprites[1].prefix = "water_ripples_stg215Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t_hot("decal_stage_215_mist", "decal", true)
tt.render.sprites[1].prefix = "mist_stg215Def"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS + 1
tt = E:register_t_hot("decal_stage_215_bubbles", "decal", true)
tt.render.sprites[1].prefix = "stage_215_bubbles"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t_hot("decal_stage_215_ambient_bubbles", "decal", true)
tt.render.sprites[1].prefix = "bubbles_stg215Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS + 1
tt = E:register_t_hot("decal_stage_215_flags", "decal", true)
tt.render.sprites[1].prefix = "flags_stg215Def"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 1
tt = E:register_t_hot("decal_stage_215_cabin_smoke", "decal", true)
tt.render.sprites[1].prefix = "smoke_stg215Def"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t_hot("decal_stage_215_witch", "decal_scripted", true)
AC(tt, "editor")
tt.render.sprites[1].prefix = "witch_stg215_witchstartDef"
tt.render.sprites[1].name = "dialog"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS
tt.main_script.update = witch_update
tt.cauldron_t = "decal_stage_215_cauldron"
tt.dialog_pos = v(782, 388)
tt.cinematic_time = fts(230)
tt.sound_laugh = "Stage15WitchLaughter"
tt.sound_conjure_potion = "Stage15WitchConjurePotion"
tt.sound_movement = "Stage15WitchMovement"
tt.potion_time = fts(11)
tt.movement_time = fts(220)
tt.laugh_time = fts(80)
tt = E:register_t_hot("decal_stage_215_cauldron", "decal_scripted", true)
AC(tt, "ui", "editor")
tt.render.sprites[1].prefix = "witch_stg215Def"
tt.render.sprites[1].name = "cauldronloop"
tt.render.sprites[1].loop = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt.dialog_pos = v(105, 589)
tt.ui.click_rect = r(-433, 0, 0, 0)
tt.main_script.update = cauldron_update
tt = E:register_t_hot("controller_stage_215_bubble_decorations", nil, true)
AC(tt, "main_script")
tt.main_script.update = bubble_decorations_update
tt.decal_t = "decal_stage_215_ambient_bubbles"
tt.disabled = true
tt.bubble_cd_min = 0.75
tt.bubble_cd_max = 1.25
tt = E:register_t_hot("controller_stage_215_wave_report", nil, true)
AC(tt, "events")
tt.events.list[1].name = "end_wave_14"
tt.events.list[1].on_event = function(this, store, action)
	this.no_more_enemies = true
end
tt = E:register_t_hot("controller_stage_215_lord_blackburn_wp", nil, true)
AC(tt, "events")
tt.events.list[1].name = "blackburn_wp"
tt.events.list[1].on_event = function(this, store, action, x, y)
	local bb = find_all_t(store, "soldier_stage_215_lord_blackburn", true)[1]
	if bb then
		bb.waypoint(tonumber(x), tonumber(y))
	end
end
tt = E:register_t_hot("controller_stage_215_lord_blackburn", nil, true)
tt = E:register_t_hot("controller_stage_215_accusation_cinematic", nil, true)
AC(tt, "main_script", "events", "editor")
tt.main_script.update = accusation_update
tt.cauldron_t = "decal_stage_215_cauldron"
tt.swamps_t = "controller_swamps"
tt.mist_t = "decal_stage_215_mist"
tt.swamp_mask_1_t = "decal_stage_215_mask_5"
tt.swamp_mask_2_t = "decal_stage_215_mask_6"
tt.blackburn_t = "hero_stage_215_lord_blackburn"
tt.bubbles_controller_t = "controller_swamp_bubbles"
tt.random_bubbles_controller_t = "controller_stage_215_bubble_decorations"
tt.mod_t = "mod_stage_215_black_burn_mind_control"
tt.target_pos = v(522, 465)
tt.bubbles_pos = v(297, 547)
tt.events.list[1].name = "accusation_cinematic"
tt.events.list[1].on_event = accusation_on_event
tt.sound_boil = "Stage15WitchCauldronBoil"
tt.sound_kick = "Stage15WitchKickCauldronKick"
tt.sound_splash = "Stage15WitchKickCauldronSplash"
tt.sound_energy = "Stage15MidCinematicDarkEnergy"
tt = E:register_t_hot("decal_easter_egg_stage_215_the_ring", "decal_scripted", true)
AC(tt, "ui")
tt.render.sprites[1].prefix = "the_ring_the_ring"
tt.render.sprites[1].name = "loop_1"
tt.render.sprites[1].z = Z_DECALS
tt.main_script.update = ring_update
tt.sound_lid_open = "Stage15TheRingLidOpen"
tt.sound_lid_open_frame = 1
tt.sound_samara_glitch = {"Stage15TheRingSamaraGlitch1", "Stage15TheRingSamaraGlitch2", "Stage15TheRingSamaraGlitch3"}
tt.sound_samara_glitch_frames = {79, 121, 169}
tt.loop_2_cd = 10
tt.ui.click_rect = r(-18, -10, 35, 35)
tt = E:register_t_hot("decal_easter_egg_stage_215_the_simpsons", "decal_scripted", true)
AC(tt, "ui")
tt.render.sprites[1].prefix = "simpsons_fish_simpsons_fish"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].anchor = v(0.24, 0.58)
tt.main_script.update = simpsons_fish_update
tt.sound_tap_1 = "Stage15ThreeEyedFishTap1"
tt.sound_tap_2 = "Stage15ThreeEyedFishTap2"
tt.duration = 15
tt.ui.click_rect = r(-18, -10, 30, 30)
tt = E:register_t_hot("controller_stage_215_easter_egg_simpsons", nil, true)
AC(tt, "main_script")
tt.main_script.update = simpsons_controller_update
tt.min_time = 20
tt.max_time = 80
tt.fish_t = "decal_easter_egg_stage_215_the_simpsons"
tt.spawn_pos = {v(72, 290), v(97, 226), v(347, 637), v(236, 555)}
