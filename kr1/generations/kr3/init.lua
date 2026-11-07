local common = require("kr1.generations.common")

return common.standard({
	name = "kr3",
	resource_root = "kr1/generations/kr3",
	order = 30,
	label_key = "MAP_UI_GEN_3",
	hotkey = "3",
	legacy = {
		level_from = 48,
		last_level = 22,
		extra_from = 2999,
		extra_count = 0
	},
	background = "map_background_kr3",
	music = "MusicMap3",
	points_path = "data.map_points3",
	data_key = 3,
	count = 22,
	main_campaign_last = 15,
	ranges = {{1, 15}, {16, 18}, {19, 20}, {21, 22}},
	required_textures = {"kr3_screen_map_animations"}
})
