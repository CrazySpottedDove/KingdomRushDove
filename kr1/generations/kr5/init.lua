local common = require("kr1.generations.common")

return common.standard({
	name = "kr5",
	resource_root = "kr1/generations/kr5",
	order = 40,
	label_key = "MAP_UI_GEN_5",
	hotkey = "5",
	legacy = {
		level_from = 100,
		last_level = 40,
		extra_from = 4999,
		extra_count = 0
	},
	background = "map_background_kr5",
	music = "MusicMap5",
	points_path = "data.map_points5",
	data_key = 5,
	count = 40,
	main_campaign_last = 16,
	ranges = {{1, 16}, {17, 19}, {20, 22}, {23, 27}, {28, 30}, {31, 35}, {36, 40}}
})
