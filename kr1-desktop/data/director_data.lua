-- chunkname: @./kr1-desktop/data/director_data.lua
local d = {}

d.item_props = {
	splash = {
		src = "screen_splash",
		next = "slots",
		type = "screen"
	},
	slots = {
		src = "screen_slots",
		show_loading = false,
		type = "screen"
	},
	credits = {
		src = "screen_credits",
		next = "slots",
		type = "screen"
	},
	map = {
		src = "screen_map",
		show_loading = true,
		type = "screen"
	},
	game = {
		show_loading = true,
		next = "map",
		type = "game"
	},
	kr1_end = {
		src = "screen_kr1_end",
		next = "map",
		type = "screen"
	},
	kr2_end = {
		src = "screen_kr2_end",
		next = "map",
		type = "screen"
	},
	game_editor = {
		src = "game_editor",
		show_loading = false,
		scissor = false,
		type = "screen"
	}
}
d.loading_image_name = {
	{"loading_grass", {1, 2, 3, 4, 5, 6, 14, 16, 17}},
	{"loading_ice", {7, 8, 9, 13, 18, 19}},
	{"loading_wasteland", {10, 11, 12, 15, 20, 21, 22}},
	{"loading_blackburn", {23, 24, 25, 26}},
	default = "loading_grass"
}

return d
