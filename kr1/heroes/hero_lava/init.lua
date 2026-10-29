local NS = require("heroes.name_style")

return {
	name = "hero_lava",
	room = {
		available_level = 116,
		starting_level = 1,
		stats = {7, 5, 7, 4},
		portrait_image = "kr5_portrait_notxt_0016",
		thumb_image = "kr5_hero_room_thumbs_0016",
		icon_image = "kr5_mapButtons_portrait_hero_0016"
	},
	room_special_order = {"TEMPER_TANTRUM", "HEART", "DOUBLE_TROUBLE", "WILD_ERUPTION", "ULTIMATE"},
	required_textures = {"go_hero_lava"},
	plugin_required_textures = {},
	required_sounds = {"hero_lava"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_lava.templates"},
	animations = {"heroes.hero_lava.animations"},
	sounds = {"heroes.hero_lava.sounds"},
	groups = {"heroes.hero_lava.groups"},

	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {255, 140, 16, 255},
		c3 = {207, 76, 16, 255},
		outline = {135, 12, 16, 255},
		outline_thickness = 2.5,
		glow = {135, 12, 16, 255},
		glow_thickness = 1
	}
}
