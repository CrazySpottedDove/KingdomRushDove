local E = require("entity_db")
local scripts = require("game_scripts")
local tt
local U = require("utils")
local ACH = require("achievements")
local decal_fish = {}

function decal_fish.update(this, store)
	while true do
		this.render.sprites[1].hidden = true

		U.y_wait_unconditional(store, math.random(5, 10))

		this.render.sprites[1].hidden = false

		U.animation_start_default(this, "jump", nil, store.tick_ts, false)

		this.ui.clicked = nil

		while not U.animation_finished_default(this) do
			if this.ui.clicked then
				ACH:got(this.achievement_id)

				this.ui.clicked = nil
			end

			coroutine.yield()
		end
	end
end

tt = E:register_t_hot("decal_fish", "decal_scripted", true)
AC(tt, "ui")
tt.render.sprites[1].prefix = "decal_fish"
tt.render.sprites[1].name = "jump"
tt.render.sprites[1].loop = false
tt.render.sprites[1].hidden = true
tt.main_script.update = decal_fish.update
tt.ui.can_select = false
tt.ui.click_rect = r(-24, -17, 48, 34)
tt.achievement_id = "CATCH_A_FISH"

