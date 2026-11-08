local common = require("kr1.generations.common")

return common.standard({
	name = "kr1",
	resource_root = "kr1/generations/kr1",
	label_key = "MAP_UI_GEN_1",
	hotkey = "1",
	background = "map_background_kr1",
	music = "MusicMap1",
	points = require("kr1.generations.kr1.data.map_points"),
	map_animations = require("kr1.generations.kr1.data.map_animations"),
	map_decos = require("kr1.generations.kr1.data.map_decos"),
	level_data = require("kr1.generations.kr1.data.level_data"),
	ranges = {{1, 12}, {13}, {14}, {15}, {16, 17}, {18, 19}, {20, 21}, {22}, {23, 26}, {27}},
	required_textures = {"screen_map_animations"}
})
