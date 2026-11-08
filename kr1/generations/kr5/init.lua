local common = require("kr1.generations.common")

return common.standard({
	name = "kr5",
	resource_root = "kr1/generations/kr5",
	label_key = "MAP_UI_GEN_5",
	hotkey = "5",
	background = "map_background_kr5",
	music = "MusicMap5",
	points = require("kr1.generations.kr5.data.map_points"),
	map_animations = require("kr1.generations.kr5.data.map_animations"),
	map_decos = require("kr1.generations.kr5.data.map_decos"),
	level_data = require("kr1/generations.kr5.data.level_data"),
	ranges = {{1, 16}, {17, 19}, {20, 22}, {23, 27}, {28, 30}, {31, 35}, {36, 40}}
})
