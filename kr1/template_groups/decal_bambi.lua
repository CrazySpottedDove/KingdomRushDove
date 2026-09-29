local scripts = require("game_scripts")
local tt
local E = require("entity_db")
local U = require("utils")
local S = require("sound_db")
local V = require("lib.klua.vector")
local v = V.v
local decal_bambi = {}

function decal_bambi.update(this, store)
	local clicks = 0
	local max_clicks = math.random(3, 6)
	local idle_ts, idle_time = store.tick_ts, 1
	local pos1, pos2

	if this.run_offset then
		pos1 = V.vclone(this.pos)
		pos2 = v(this.pos.x + this.run_offset.x, this.pos.y + this.run_offset.y)
	end

	while true do
		if this.ui.clicked then
			clicks = clicks + 1

			if max_clicks < clicks then
				S:queue("DeathEplosion")

				local fx = E:create_entity("fx_unit_explode")

				fx.pos = V.vclone(this.pos)
				fx.render.sprites[1].ts = store.tick_ts
				fx.render.sprites[1].name = "small"

				simulation:queue_insert_entity(fx)

				local blood = E:create_entity("decal_blood_pool")

				blood.render.sprites[1].ts = store.tick_ts
				blood.pos = V.vclone(this.pos)

				simulation:queue_insert_entity(blood)
				simulation:queue_remove_entity(this)

				return
			else
				U.y_animation_play(this, "touch", nil, store.tick_ts)
			end

			this.ui.clicked = nil
		end

		if idle_time < store.tick_ts - idle_ts then
			idle_ts = store.tick_ts
			idle_time = U.frandom(1, 3)

			if math.random() < 0.8 then
				U.animation_start_default(this, "eat", nil, store.tick_ts)
			elseif pos1 and pos2 then
				local dest = V.veq(this.pos, pos1) and pos2 or pos1
				local af = dest.x < this.pos.x

				U.animation_start_default(this, "run", af, store.tick_ts, true)
				U.set_destination(this, dest)

				while not this.motion.arrived do
					U.walk_off__accel__unsnapped(this, store.tick_length)
					coroutine.yield()
				end

				U.animation_start_default(this, "idle", nil, store.tick_ts)

				this.ui.clicked = nil
			end
		end

		coroutine.yield()
	end
end

tt = E:register_t_hot("decal_bambi", "decal_scripted", true)
AC(tt, "ui", "motion")
tt.render.sprites[1].prefix = "decal_bambi"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor.y = 0.1
tt.main_script.update = decal_bambi.update
tt.ui.click_rect = r(-15, 0, 30, 30)
tt.ui.can_select = false
tt.motion.max_speed = 99.9

