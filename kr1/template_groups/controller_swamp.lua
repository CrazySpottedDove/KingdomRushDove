local E = require("entity_db")
local scripts = require("game_scripts")
local tt
local U = require("utils")
local S = require("sound_db")
local log = require("lib.klua.log"):new("templates")

local function queue_insert(store, e)
	simulation:queue_insert_entity(e)
end

local function get_random_round_robin(mutable_history, n, m)
	if not m then
		m = n
		n = 1
	end

	if m < n then
		log.error("ERROR: Random round robin needs M to be bigger or equal than N")
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

local function find_all_t(store, template_name, contains, fn)
	if not store or not store.entities then
		return {}
	end

	return table.filter(store.entities, function(k, val)
		return (contains and string.find(val.template_name, template_name) or val.template_name == template_name) and (not fn or fn(k, val))
	end)
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

local controller_swamp_bubbles = {}

function controller_swamp_bubbles.on_start(this, store, action, path_id)
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

function controller_swamp_bubbles.on_end(this, store, action, path_id)
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

local controller_swamp_bubbles_spawner = {}

function controller_swamp_bubbles_spawner.update(this, store, script)
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

local controller_swamps = {}

function controller_swamps.spawn_husks(this, store, action, path_id, amount)
	swamps_spawn_event(this, store, "enemy_swamp_husk", path_id, amount)
end

function controller_swamps.spawn_thing(this, store, action, path_id)
	swamps_spawn_event(this, store, "enemy_swamp_thing_kr6", path_id, "1", true)
end

tt = E:register_t_hot("controller_swamp_spawn_points", nil, true)
AC(tt, "pos", "graveyard")
tt.swamp_id = nil
tt.interrupt = true

tt = E:register_t_hot("controller_swamps", nil, true)
AC(tt, "pos", "events")
tt.path_spawner_map = {
	[6] = 2,
	[5] = 1
}
tt.swamp_t = "controller_swamp_spawn_points"
tt.spawner_t = "controller_swamp_spawner"
tt.events.list[1].name = "spawn_swamp_husks"
tt.events.list[1].on_event = controller_swamps.spawn_husks
tt.events.list[2] = E:clone_c("event")
tt.events.list[2].name = "spawn_swamp_thing"
tt.events.list[2].on_event = controller_swamps.spawn_thing

tt = E:register_t_hot("controller_swamp_bubbles_spawner", nil, true)
AC(tt, "main_script", "pos")
tt.swamp_id = nil
tt.bubble_t = "decal_swamp_bubbles_in_loop_out"
tt.bubble_sound = "Stage15SwampBubbling"
tt.bubble_sound_interval = {3, 7}
tt.radius = 30
tt.main_script.update = controller_swamp_bubbles_spawner.update

tt = E:register_t_hot("controller_swamp_bubbles", nil, true)
AC(tt, "events")
tt.spawn_interval = 1
tt.bubble_spawner_t = "controller_swamp_bubbles_spawner"
tt.bubble_count = {5, 6}
tt.bubble_scales = {0.4, 1}
tt.bubble_intervals = {fts(5), fts(10)}
tt.path_spawner_map = {
	[6] = 2,
	[5] = 1
}
tt.events.list[1].name = "start_bubbles"
tt.events.list[1].on_event = controller_swamp_bubbles.on_start
tt.events.list[2] = E:clone_c("event")
tt.events.list[2].name = "end_bubbles"
tt.events.list[2].on_event = controller_swamp_bubbles.on_end

