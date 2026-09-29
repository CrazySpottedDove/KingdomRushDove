local decal_terrain_6_exodia_part
local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local signal = require("lib.hump.signal")
local tt
decal_terrain_6_exodia_part = {}

function decal_terrain_6_exodia_part.update(this, store)
	local shine_ts = store.tick_ts
	local shine_cd = math.random(10, 15)

	while true do
		if this.ui.clicked then
			this.ui.clicked = nil
			this.ui.can_click = false

			S:queue(this.sound_click)
			U.y_animation_play(this, "action", nil, store.tick_ts, 1)
			signal.emit("exodia-terrain6", store.level_idx - 23)
			simulation:queue_remove_entity(this)

			return
		end

		if shine_cd < store.tick_ts - shine_ts then
			shine_ts = store.tick_ts
			shine_cd = math.random(10, 15)

			U.animation_start_default(this, "shine", nil, store.tick_ts, false)
		end

		if this.render.sprites[1].name == "shine" and U.animation_finished_default(this) then
			U.animation_start_default(this, "idle", nil, store.tick_ts, true)
		end

		coroutine.yield()
	end
end

tt = E:register_t_hot("decal_terrain_6_exodia_arm", "decal_scripted", true)
E:add_comps(tt, "ui")
tt.render.sprites[1].prefix = "DLC_enanos_easter_egg_exodia_arm"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].z = Z_DECALS
tt.main_script.update = decal_terrain_6_exodia_part.update
tt.ui.click_rect = r(-15, -5, 30, 20)
tt.sound_click = "Terrain6ExodiaPart"

tt = E:register_t_hot("decal_terrain_6_exodia_head", "decal_terrain_6_exodia_arm", true)
tt.render.sprites[1].prefix = "DLC_enanos_easter_egg_exodia_head"

tt = E:register_t_hot("decal_terrain_6_exodia_leg", "decal_terrain_6_exodia_arm", true)
tt.render.sprites[1].prefix = "DLC_enanos_easter_egg_exodia_leg"
tt.ui.click_rect = r(-15, -5, 30, 30)

tt = E:register_t_hot("decal_terrain_6_exodia_leg_2", "decal_terrain_6_exodia_arm", true)
tt.render.sprites[1].prefix = "DLC_enanos_easter_egg_exodia_leg"
tt.render.sprites[1].flip_x = true
tt.ui.click_rect = r(-15, -5, 30, 30)

