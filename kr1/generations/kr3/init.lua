local common = require("kr1.generations.common")

return common.standard({
	name = "kr3",
	resource_root = "kr1/generations/kr3",
	label_key = "MAP_UI_GEN_3",
	hotkey = "3",
	background = "map_background_kr3",
	music = "MusicMap3",
	points = require("kr1.generations.kr3.data.map_points"),
	map_animations = require("kr1.generations.kr3.data.map_animations"),
	map_decos = require("kr1.generations.kr3.data.map_decos"),
	level_data = require("kr1.generations.kr3.data.level_data"),
	ranges = {{1, 15}, {16, 18}, {19, 20}, {21, 22}},
	required_textures = {"kr3_screen_map_animations"}
})
