local V = require("lib.klua.vector")
local E = require("entity_db")
local U = require("utils")
require("all.constants")
require("lib.klua.table")
local r = V.r
local function AC(tpl, ...)
	return E:add_comps(tpl, ...)
end
local function decal_indiana_boulder_update(this, store)
	while not U.walk_off__accel__unsnapped(this, store.tick_length) do
		coroutine.yield()
	end
	simulation:queue_remove_entity(this)
end
local tt
tt = E:register_t_hot("decal_monkey_corps_1", "decal_tween", true)
tt.render.sprites[1].name = "decal_monkey_corps_1"
tt.tween.remove = false
tt.tween.props[1].loop = true
tt.tween.props[1].name = "flip_x"
tt.tween.props[1].keys = {{0, false}, {3, true}, {6, false}}
tt = E:register_t_hot("decal_monkey_corps_2", "decal", true)
tt.render.sprites[1].name = "decal_monkey_corps_2"
tt = E:register_t_hot("decal_monkey_corps_3", "decal_delayed_sequence", true)
tt.render.sprites[1].prefix = "decal_monkey_corps_3"
tt.render.sprites[1].name = "idle"
tt.delayed_sequence.animations = {"jump", "jump", "jump", "idle"}
tt.delayed_sequence.min_delay = 0
tt.delayed_sequence.max_delay = 1
tt = E:register_t_hot("indiana_puzzle_button_a", "decal", true)
AC(tt, "ui")
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "indiana_puzzle_button_a"
tt.render.sprites[1].z = Z_DECALS + 6
tt.ui.can_click = false
tt.ui.click_rect = r(-22, -22, 44, 44)
tt.puzzle_value = 1
tt = E:register_t_hot("indiana_puzzle_button_b", "indiana_puzzle_button_a", true)
tt.render.sprites[1].prefix = "indiana_puzzle_button_b"
tt.puzzle_value = 2
tt = E:register_t_hot("indiana_puzzle_button_c", "indiana_puzzle_button_a", true)
tt.render.sprites[1].prefix = "indiana_puzzle_button_c"
tt.puzzle_value = 3
tt = E:register_t_hot("decal_indiana", "decal_tween", true)
tt.render.sprites[1].prefix = "decal_indiana"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_DECALS + 4
tt.tween.disabled = true
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 255}, {1, 0}}
tt = E:register_t_hot("decal_indiana_question_marks", "decal_timed", true)
tt.render.sprites[1].name = "decal_indiana_question_marks"
tt.timed.runs = 5
tt = E:register_t_hot("decal_indiana_boulder", "decal_scripted", true)
AC(tt, "motion")
tt.render.sprites[1].name = "decal_indiana_boulder"
tt.render.sprites[1].z = Z_DECALS + 4
tt.motion.max_speed = 3.9 * FPS
tt.main_script.update = decal_indiana_boulder_update
