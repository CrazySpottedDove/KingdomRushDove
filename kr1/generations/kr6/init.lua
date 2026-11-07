local common = require("kr1.generations.common")

return common.standard({
	name = "kr6",
	resource_root = "kr1/generations/kr6",
	order = 50,
	label_key = "MAP_UI_GEN_6",
	hotkey = "6",
	legacy = {
		level_from = 200,
		last_level = 18,
		extra_from = 5999,
		extra_count = 0
	},
	background = "map_background_kr6",
	music = "MusicMap6",
	points = require("kr1.generations.kr6.data.map_points"),
	map_animations = require("kr1.generations.kr6.data.map_animations"),
	map_decos = require("kr1.generations.kr6.data.map_decos"),
	level_data = require("kr1.generations.kr6.data.level_data"),
	count = 18,
	main_campaign_last = 18,
	ranges = {{1, 18}},
	flag_anchor = {
		mode = "insertion",
		px = 43.95,
		py = 106.55,
		src_w = 96,
		src_h = 132
	}
})
