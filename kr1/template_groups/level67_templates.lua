local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
require("all.constants")
require("lib.klua.table")
local function fts(t)
	return t / FPS
end
local function AC(tpl, ...)
	return E:add_comps(tpl, ...)
end
local function decal_s19_drizzt_update(this, store)
	local idle_ts = 0
	local idle_cooldown = math.random(this.idle_cooldown[1], this.idle_cooldown[2])
	local gnoll
	while true do
		if this.ui.clicked then
			this.ui.clicked = nil
			if gnoll and gnoll.phase == "joke" then
				gnoll.set_phase = "scared"
				S:queue(this.sound_chase, this.sound_chase_params)
				U.y_animation_play(this, "alert", nil, store.tick_ts)
				U.y_animation_play(this, "run", nil, store.tick_ts)
				break
			else
				S:queue(this.sound_clicked)
				U.y_animation_play(this, "alert", nil, store.tick_ts)
			end
		end
		if idle_cooldown < store.tick_ts - idle_ts then
			idle_ts = store.tick_ts
			this.render.sprites[1].ts = store.tick_ts
			if math.random() < 0.5 then
				idle_cooldown = math.random(this.idle_cooldown[1], this.idle_cooldown[2])
			else
				idle_cooldown = math.random(this.spawn_cooldown[1], this.spawn_cooldown[2])
				gnoll = E:create_entity("decal_s19_drizzt_gnoll")
				gnoll.pos.x, gnoll.pos.y = this.pos.x - 70, this.pos.y - 10
				simulation:queue_insert_entity(gnoll)
			end
		end
		coroutine.yield()
	end
	simulation:queue_remove_entity(this)
end
local tt
tt = E:register_t_hot("decal_s19_drizzt", "decal_scripted", true)
AC(tt, "editor", "ui")
tt.render.sprites[1].prefix = "decal_s19_drizzt"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].loop = false
tt.main_script.update = decal_s19_drizzt_update
tt.idle_cooldown = {3, 5}
tt.spawn_cooldown = {10, 15}
tt.sound_clicked = "ElvesDrizztGrowl"
tt.sound_chase = "ElvesDrizztUnsheathe"
tt.sound_chase_params = {
	delay = fts(23)
}
tt.ui.click_rect = r(90, -30, 40, 30)
tt.ui.can_select = false
