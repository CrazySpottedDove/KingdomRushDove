local E = require("entity_db")
local scripts = require("game_scripts")
local tt
local U = require("utils")
local ACH = require("achievements")
local decal_rabbit = {}

function decal_rabbit.update(this, store)

	local function clicked()
		if this.ui.clicked then
			this.ui.clicked = nil

			return true
		end
	end

	local ani, tmin, tmax, hide_ani

	::label_510_0::

	while true do
		for _, s in pairs(this.ani_sequence) do
			ani, tmin, tmax, hide_ani = unpack(s, 1, 4)

			if ani then
				if this.tween.reverse then
					this.tween.reverse = nil
					this.tween.ts = 0
				end

				U.animation_start_default(this, ani, nil, store.tick_ts)
			else
				this.tween.reverse = true
				this.tween.ts = store.tick_ts
			end

			if tmin and tmax then
				this.ui.clicked = nil

				if U.y_wait(store, math.random(tmin, tmax), hide_ani and clicked or nil) then
					goto label_510_1
				end
			else
				U.y_animation_wait_default(this)
			end
		end
	end

	::label_510_1::

	U.y_animation_play(this, hide_ani, nil, store.tick_ts)

	this.tween.reverse = true
	this.tween.ts = store.tick_ts

	-- ACH:inc_check("FOLLOW_RABBIT")
	U.y_wait_unconditional(store, math.random(tmin, tmax))

	goto label_510_0
end

tt = E:register_t_hot("decal_rabbit", "decal_scripted", true)
AC(tt, "ui", "tween")
tt.render.sprites[1].prefix = "decal_rabbit"
tt.render.sprites[1].name = "ears"
tt.render.sprites[1].loop = false
tt.ui.click_rect = r(-20, -20, 40, 30)
tt.ui.can_select = false
tt.main_script.update = decal_rabbit.update
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {0.25, 255}}
tt.tween.ts = 0
tt.ani_sequence = {{"ears", 5, 15}, {"popout", 1, 3, "hide1"}, {"travel1", 1, 3, "hide2"}, {"travel2", 1.5, 3, "hide3"}, {"travel3", 1, 3, "hide1"}, {"hide1"}, {nil, 10, 20}}

