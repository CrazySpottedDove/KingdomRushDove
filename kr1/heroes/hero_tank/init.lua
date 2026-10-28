local NS = require("heroes.name_style")

return {
	name = "hero_tank",
	room = {
		available_level = 1,
		starting_level = 1,
		from_kr = 4,
		stats = {8, 9, 4, 2},
		portrait = 9,
		thumb = 9,
		icon = 9,
		portrait_image = "kr4_portrait_notxt_0009",
		thumb_image = "kr4_hero_room_thumbs_0009",
		icon_image = "kr4_mapButtons_portrait_hero_0009"
	},
	room_special_order = {"ULTIMATE", "HEAT_MISSILES", "GROUND_SLAM", "EXPENDABLES", "SCORCHING_CANNON", "ULTIMATE_2"},
	required_textures = {"go_hero_tank"},
	plugin_required_textures = {},
	required_sounds = {"hero_tank"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_tank.templates"},
	animations = {"heroes.hero_tank.animations"},
	sounds = {"heroes.hero_tank.sounds"},
	groups = {"heroes.hero_tank.groups"},

	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {255, 153, 51, 255},
		c3 = {230, 76, 20, 255},
		outline = {128, 40, 8, 255},
		outline_thickness = 2.5,
		glow = {128, 40, 8, 255},
		glow_thickness = 1
	}
}
