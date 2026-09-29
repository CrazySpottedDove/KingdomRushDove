local scripts = require("game_scripts")
local tt
local E = require("entity_db")
local U = require("utils")
local km = require("lib.klua.macros")
local V = require("lib.klua.vector")
local v = V.v
local birds_controller = {}

function birds_controller.update(this, store)
	local i = 1

	while true do
		local delay = U.frandom(this.delay[1], this.delay[2])

		U.y_wait_unconditional(store, delay)

		for j = 1, this.batch_count do
			local batch_delay = U.frandom(this.batch_delay[1], this.batch_delay[2])

			U.y_wait_unconditional(store, batch_delay)

			local e = E:create_entity(table.random(this.bird_templates))
			local o, d = this.origins[km.zmod(i, #this.origins)], this.destinations[km.zmod(i, #this.destinations)]
			local fly_time = V.dist(o.x, o.y, d.x, d.y) / this.fly_speed

			e.pos = v(o.x, o.y)
			e.tween.props[1].keys = {{0, v(0, 0)}, {fly_time, v(d.x, d.y)}}
			e.render.sprites[1].ts = store.tick_ts
			e.render.sprites[1].flip_x = o.x > d.x

			simulation:queue_insert_entity(e)

			i = i + 1
		end
	end
end

local birds_formation_controller = {}

function birds_formation_controller.update(this, store)
	while true do
		U.y_wait_unconditional(store, U.frandom(this.wait_time[1], this.wait_time[2]))

		for ii, n in ipairs(this.names) do
			local o = this.offsets and this.offsets[ii] or v(0, 0)
			local from = v(this.from.x + o.x, this.from.y + o.y)
			local to = v(this.to.x + o.x, this.to.y + o.y)
			local e = E:create_entity(this.bird_template)

			e.render.sprites[1].name = n
			e.render.sprites[1].ts = U.frandom(0, 1)
			e.render.sprites[1].flip_x = from.x > to.x
			e.tween.props[1].keys = {{0, from}, {this.time, to}}
			e.tween.ts = store.tick_ts

			simulation:queue_insert_entity(e)
		end
	end
end

tt = E:register_t_hot("birds_controller", nil, true)
AC(tt, "main_script")
tt.main_script.update = birds_controller.update
tt.origins = {}
tt.destinations = {}
tt.bird_templates = {"decal_bird_1", "decal_bird_2"}
tt.delay = {20, 40}
tt.batch_count = 2
tt.batch_delay = {1, 5}
tt.fly_speed = 116

tt = E:register_t_hot("birds_formation_controller", nil, true)
AC(tt, "main_script")
tt.main_script.update = birds_formation_controller.update
tt.wait_time = {20, 60}
tt.bird_template = "decal_bird_formation"

