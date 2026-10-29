local NS = require("heroes.name_style")

return {
	name = "hero_builder",
	room = {
		available_level = 105,
		starting_level = 1,
		stats = {7, 5, 6, 4},
		portrait_image = "kr5_portrait_notxt_0005",
		thumb_image = "kr5_hero_room_thumbs_0005",
		icon_image = "kr5_mapButtons_portrait_hero_0005"
	},
	room_special_order = {"BERSERKER", "BERSERKER_2", "BERSERKER_3", "BERSERKER_4", "BERSERKER_5"},
	required_textures = {"go_hero_builder"},
	plugin_required_textures = {},
	required_sounds = {"hero_builder"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_builder.templates"},
	animations = {"heroes.hero_builder.animations"},
	sounds = {"heroes.hero_builder.sounds"},
	groups = {"heroes.hero_builder.groups"},

	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {255, 183, 95, 255},
		c3 = {255, 98, 0, 255},
		outline = {88, 19, 0, 255},
		outline_thickness = 2.5,
		glow = {88, 19, 0, 255},
		glow_thickness = 1.5
	}
}
