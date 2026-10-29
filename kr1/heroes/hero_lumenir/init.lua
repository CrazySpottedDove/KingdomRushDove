local NS = require("heroes.name_style")

return {
	name = "hero_lumenir",
	room = {
		available_level = 115,
		starting_level = 1,
		from_kr = 5,
		stats = {7, 0, 5, 5},
		portrait_image = "kr5_portrait_notxt_0011",
		thumb_image = "kr5_hero_room_thumbs_0011",
		icon_image = "kr5_mapButtons_portrait_hero_0011"
	},
	room_special_order = {"BERSERKER", "BERSERKER_2", "BERSERKER_3", "BERSERKER_4", "BERSERKER_5"},
	required_textures = {"go_hero_lumenir"},
	plugin_required_textures = {},
	required_sounds = {"hero_lumenir"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_lumenir.templates"},
	animations = {"heroes.hero_lumenir.animations"},
	sounds = {"heroes.hero_lumenir.sounds"},
	groups = {"heroes.hero_lumenir.groups"},

	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {182, 232, 255, 255},
		c3 = {65, 178, 229, 255},
		outline = {0, 69, 100, 255},
		outline_thickness = 2.5,
		glow = {0, 69, 100, 255},
		glow_thickness = 1
	}
}
