local common = require("kr1.generations.common")

return common.standard({
	name = "kr2",
	order = 20,
	label_key = "MAP_UI_GEN_2",
	hotkey = "2",
	legacy = {
		level_from = 26,
		last_level = 22,
		extra_from = 1999,
		extra_count = 0
	},
	background = "map_background_kr2",
	music = "MusicMap2",
	points_path = "data.map_points2",
	data_key = 2,
	count = 22,
	main_campaign_last = 15,
	ranges = {{1, 15}, {16, 18}, {19, 21}, {22}},
	required_textures = {"kr2_screen_map_animations"}
})
