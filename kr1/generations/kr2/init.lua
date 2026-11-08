local common = require("kr1.generations.common")

return common.standard({
	name = "kr2",
	resource_root = "kr1/generations/kr2",
	label_key = "MAP_UI_GEN_2",
	hotkey = "2",
	background = "map_background_kr2",
	music = "MusicMap2",
	points = require("kr1.generations.kr2.data.map_points"),
	map_animations = require("kr1.generations.kr2.data.map_animations"),
	map_decos = require("kr1.generations.kr2.data.map_decos"),
	level_data = require("kr1.generations.kr2.data.level_data"),
	ranges = {{1, 15}, {16, 18}, {19, 21}, {22}},
	required_textures = {"kr2_screen_map_animations"}
})
