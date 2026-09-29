local E = require("entity_db")
local U = require("utils")
local S = require("sound_db")
local P = require("path_db")
local log = require("lib.klua.log"):new("templates")
local decal_whale = {}

function decal_whale.insert(this, store)
	this.pos = P:node_pos(this.nav_path.pi, 1, 1)
	this.pos.x = this.pos.x + this.path_origin_offset.x
	this.pos.y = this.pos.y + this.path_origin_offset.y

	if not this.spawn_data then
		log.error("spawn_data required for decal_whale")

		return false
	end

	return true
end

function decal_whale.update(this, store)
	log.debug("whale starting")

	local cover_s = this.render.sprites[4]
	local eye_s = this.render.sprites[5]
	local blink_cooldown = math.random(2, 4)
	local fx = E:create_entity("fx_whale_incoming")

	fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
	fx.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(fx)

	local wait_ts = store.tick_ts + 3.5

	while wait_ts > store.tick_ts do
		coroutine.yield()
	end

	S:queue("RTWhaleSpawn")

	for i = 1, 3 do
		this.render.sprites[i].hidden = false

		U.animation_start(this, "show", nil, store.tick_ts, false, i)
	end

	while not U.animation_finished_default(this) do
		coroutine.yield()
	end

	for i = 1, 3 do
		this.render.sprites[i].hidden = false

		U.animation_start(this, "idle", nil, store.tick_ts, true, i)
	end

	cover_s.hidden = false
	eye_s.hidden = false

	while not store.wave_signals[this.spawn_data.whale_hide_signal] do
		if blink_cooldown < store.tick_ts - eye_s.ts then
			blink_cooldown = math.random(2, 4)

			U.animation_start(this, "blink", nil, store.tick_ts, false, 5)
		end

		coroutine.yield()
	end

	cover_s.hidden = true
	eye_s.hidden = true

	for i = 1, 3 do
		this.render.sprites[i].hidden = false

		U.animation_start(this, "hide", nil, store.tick_ts, false, i)
	end

	while not U.animation_finished_default(this) do
		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
	log.debug("whale ended")
end

local tt = E:register_t_hot("decal_whale", "decal_scripted", true)
AC(tt, "nav_path")
tt.path_origin_offset = vec_2(36, 36)
tt.main_script.insert = decal_whale.insert
tt.main_script.update = decal_whale.update

for i = 1, 3 do
	tt.render.sprites[i] = CC("sprite")
	tt.render.sprites[i].prefix = "decal_whale_l" .. i
	tt.render.sprites[i].name = "show"
	tt.render.sprites[i].hidden = true
end

tt.render.sprites[4] = CC("sprite")
tt.render.sprites[4].name = "Cachalote_layer1_0090"
tt.render.sprites[4].animated = false
tt.render.sprites[4].hidden = true
tt.render.sprites[4].sort_y_offset = -1 * tt.path_origin_offset.y - 2
tt.render.sprites[5] = CC("sprite")
tt.render.sprites[5].prefix = "decal_whale_eye"
tt.render.sprites[5].name = "idle"
tt.render.sprites[5].hidden = true
tt.render.sprites[5].sort_y_offset = -1 * tt.path_origin_offset.y - 3

