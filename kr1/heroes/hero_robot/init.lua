local NS = require("heroes.name_style")

return {
	name = "hero_robot",
	room = {
		available_level = 114,
		stats = {6, 4, 8, 5},
		portrait_image = "kr5_portrait_notxt_0010",
		thumb_image = "kr5_hero_room_thumbs_0010",
		icon_image = "kr5_mapButtons_portrait_hero_0010"
	},
	room_special_order = {"BERSERKER", "BERSERKER_2", "BERSERKER_3", "BERSERKER_4", "BERSERKER_5"},
	required_textures = {"go_hero_robot"},
	plugin_required_textures = {},
	required_sounds = {"hero_robot"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_robot.templates"},
	animations = {"heroes.hero_robot.animations"},
	sounds = {"heroes.hero_robot.sounds"},
	groups = {"heroes.hero_robot.groups"},

	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {255, 115, 47, 255},
		c3 = {189, 71, 28, 255},
		outline = {123, 27, 9, 255},
		outline_thickness = 2.5,
		glow = {123, 27, 9, 255},
		glow_thickness = 1
	}
}
