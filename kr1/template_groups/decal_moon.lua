local E = require("entity_db")
local scripts = require("game_scripts")
local tt
local decal_moon_activated = {}

function decal_moon_activated.update(this, store)
	local last_state = false

	while true do
		if store.level and store.level.moon_controller then
			local state = store.level.moon_controller.moon_active

			if last_state ~= state then
				this.tween.reverse = not state
				this.tween.ts = store.tick_ts
				last_state = state
			end
		end

		coroutine.yield()
	end
end

tt = E:register_t_hot("decal_moon_dark", "decal_tween", true)
tt.pos.x = REF_W * 0.5
tt.pos.y = REF_H + 1 + 77
tt.render.sprites[1].name = "moon_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_SCREEN_FIXED + 3
tt.render.sprites[1].anchor.x = 3.6666666666666665
tt.tween.props[1].name = "r"
tt.tween.props[1].keys = {{0, math.pi / 5}, {0, math.pi * 0.5}}
tt.tween.disabled = true
tt.tween.remove = false

tt = E:register_t_hot("decal_moon_light", "decal_tween", true)
tt.pos.x = REF_W * 0.5
tt.pos.y = REF_H + 1 + 77
tt.render.sprites[1].name = "moon_0002"
tt.render.sprites[1].animated = false
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_SCREEN_FIXED + 4
tt.render.sprites[1].r = math.pi * 0.5
tt.render.sprites[1].anchor.x = 3.6666666666666665
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "moon_0003"
tt.tween.props[1].keys = {{0, 0}, {0.25, 255}, {0.5, 255}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].keys = {{0, 0}, {0.25, 0}, {0.5, 255}}
tt.tween.props[2].sprite_id = 2
tt.tween.remove = false
tt.tween.reverse = true
tt.tween.ts = -1

tt = E:register_t_hot("decal_moon_overlay", "decal_tween", true)
tt.pos.x = REF_W * 0.5
tt.pos.y = REF_H * 0.5
tt.render.sprites[1].name = "moon_overlay"
tt.render.sprites[1].animated = false
tt.render.sprites[1].scale = vec_2(REF_H * MAX_SCREEN_ASPECT * 1.5 / 64, REF_H * 1.5 / 64)
tt.render.sprites[1].z = Z_SCREEN_FIXED + 1
tt.tween.props[1].keys = {{0, 0}, {0.5, 44}}
tt.tween.remove = false
tt.tween.reverse = true
tt.tween.ts = -1

tt = E:register_t_hot("decal_moon_activated", "decal_scripted", true)
AC(tt, "tween")
tt.main_script.update = decal_moon_activated.update
tt.render.sprites[1].animated = false
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.tween.remove = false
tt.tween.reverse = true
tt.tween.ts = -1
tt.tween.props[1].sprite_id = 2
tt.tween.props[1].keys = {{0, 0}, {1, 255}}

