local stage_02_arborean_baby2
local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local tt
stage_02_arborean_baby2 = {}

function stage_02_arborean_baby2.update(this, store)
	local is_standup = true

	this.is_hidden = false

	local is_clicked = false
	local last_change = store.tick_ts
	local next_cd = math.random(this.change_anim_cd_min, this.change_anim_cd_max)

	while true do
		if is_clicked and store.tick_ts - last_change > this.hidden_cd then
			S:queue(this.sound_out)
			U.y_animation_play(this, "easter_egg_out", nil, store.tick_ts, 1)

			is_clicked = false
			is_standup = true
			this.ui.can_click = true
			last_change = store.tick_ts
			this.is_hidden = false
		end

		if this.ui.clicked then
			S:queue(this.sound_in)

			this.ui.clicked = nil
			is_clicked = true
			last_change = store.tick_ts
			this.ui.can_click = false

			if is_standup then
				U.y_animation_play(this, "easter_egg_sitting_in", nil, store.tick_ts, 1)
			else
				U.y_animation_play(this, "easter_egg_in", nil, store.tick_ts, 1)
			end

			this.is_hidden = true
		end

		if not is_clicked then
			if next_cd < store.tick_ts - last_change then
				if is_standup then
					U.animation_start_default(this, "sit_down", nil, store.tick_ts, false)

					while not U.animation_finished_default(this) do
						coroutine.yield()
					end

					is_standup = false
				else
					U.animation_start_default(this, "sit_up", nil, store.tick_ts, false)

					while not U.animation_finished_default(this) do
						coroutine.yield()
					end

					is_standup = true
				end

				next_cd = math.random(this.change_anim_cd_min, this.change_anim_cd_max)
				last_change = store.tick_ts
			elseif is_standup then
				U.animation_start_default(this, "idle1", nil, store.tick_ts, false)
			else
				U.animation_start_default(this, "idle_sit", nil, store.tick_ts, false)
			end
		end

		coroutine.yield()
	end
end

tt = E:register_t_hot("decal_arborean_baby_clickeable", "decal_scripted", true)
E:add_comps(tt, "editor", "editor_script", "ui")
tt.render.sprites[1].prefix = "arborean_baby"
tt.main_script.update = stage_02_arborean_baby2.update
tt.ui.can_click = true
tt.ui.click_rect = r(-15, -5, 30, 30)
tt.hidden_cd = 7
tt.change_anim_cd_min = 5
tt.change_anim_cd_max = 10
tt.sound_in = "Terrain1CommonArboreanTapIn"
tt.sound_out = "Terrain1CommonArboreanTapOut"
tt.is_hidden = false

