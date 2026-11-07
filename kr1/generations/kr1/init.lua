local common = require("kr1.generations.common")

return common.standard({
	name = "kr1",
	resource_root = "kr1/generations/kr1",
	order = 10,
	label_key = "MAP_UI_GEN_1",
	hotkey = "1",
	legacy = {
		level_from = 0,
		last_level = 26,
		extra_from = 999,
		extra_count = 1
	},
	background = "map_background_kr1",
	music = "MusicMap1",
	points_path = "data.map_points",
	data_key = 1,
	count = 27,
	main_campaign_last = 12,
	ranges = {{1, 12}, {13}, {14}, {15}, {16, 17}, {18, 19}, {20, 21}, {22}, {23, 26}, {27}},
	required_textures = {"screen_map_animations"}
})
