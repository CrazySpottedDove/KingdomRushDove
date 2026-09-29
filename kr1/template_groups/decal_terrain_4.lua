local controller_terrain_4_animated_armor_achievement
local decal_terrain_4_cheshire_cat_easter_egg
local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local signal = require("lib.hump.signal")
local LU = require("level_utils")
local tt
controller_terrain_4_animated_armor_achievement = {}

function controller_terrain_4_animated_armor_achievement.update(this, store)
	while not store.waves_finished or LU.has_alive_enemies(store) do
		coroutine.yield()
	end

	if this.revived == 0 then
		signal.emit("no-anim-armored-respawn", nil)
	end
end

decal_terrain_4_cheshire_cat_easter_egg = {}

function decal_terrain_4_cheshire_cat_easter_egg.update(this, store)
	local last_ts = store.tick_ts
	local appear_cd = math.random(this.appear_cd_min, this.appear_cd_max)
	local appear_duration = math.random(this.appear_duration_min, this.appear_duration_max)
	local is_showing = false
	local tap_animation = this.animations_tap[this.level_index + 1]

	this.ui.can_click = is_showing
	this.render.sprites[1].alpha = is_showing and 255 or 0

	local function click_and_die()
		if this.ui.clicked then
			this.ui.clicked = nil
			this.ui.can_click = false

			S:queue(this.sound_in)
			S:queue(this.sound_out)
			U.y_animation_play(this, tap_animation, nil, store.tick_ts, 1)
			U.y_wait_unconditional(store, 0.4)

			return true
		end

		return false
	end

	while store.wave_group_number == 0 do
		coroutine.yield()
	end

	last_ts = store.tick_ts

	while true do
		if click_and_die() then
			break
		end

		if is_showing then
			if appear_duration < store.tick_ts - last_ts then
				this.ui.can_click = false

				U.y_animation_play(this, "out", nil, store.tick_ts, 1)

				is_showing = false
				last_ts = store.tick_ts
				appear_cd = math.random(this.appear_cd_min, this.appear_cd_max)
			end
		elseif appear_cd < store.tick_ts - last_ts then
			this.render.sprites[1].alpha = 255

			U.y_animation_play(this, "in", nil, store.tick_ts, 1)
			U.animation_start_default(this, "idle", nil, store.tick_ts, false)

			is_showing = true
			this.ui.can_click = true
			last_ts = store.tick_ts
			appear_duration = math.random(this.appear_duration_min, this.appear_duration_max)
		end

		coroutine.yield()
	end

	signal.emit("cheshine-cat-terrain4", this.level_index)
	simulation:queue_remove_entity(this)
end

tt = E:register_t_hot("decal_terrain_4_cheshire_cat_easter_egg", "decal_scripted", true)
E:add_comps(tt, "ui")
tt.render.sprites[1].prefix = "cheshire_cat_easter_egg_cat"
tt.render.sprites[1].name = "idle"
tt.ui.click_rect = r(-30, -30, 60, 60)
tt.main_script.update = decal_terrain_4_cheshire_cat_easter_egg.update
tt.animations_tap = {"action_1", "action_2", "action_3"}
tt.appear_cd_min = 7
tt.appear_cd_max = 14
tt.appear_duration_min = 3
tt.appear_duration_max = 7
tt.sound_in = "Terrain4CheshireCatIn"
tt.sound_out = "Terrain4CheshireCatOut"

tt = E:register_t_hot("controller_terrain_4_animated_armor_achievement", nil, true)
E:add_comps(tt, "main_script")
tt.main_script.update = controller_terrain_4_animated_armor_achievement.update
tt.revived = 0

