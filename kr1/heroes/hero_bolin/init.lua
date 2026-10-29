local NS = require("heroes.name_style")

return {
	name = "hero_bolin",
	room = {
		available_level = 7,
		starting_level = 1,
		stats = {7, 5, 4, 3},
		portrait_image = "portrait_notxt_0004",
		thumb_image = "hero_room_thumbs_0004",
		icon_image = "mapButtons_portrait_hero_0004"
	},
	room_special_order = {"MINES", "TAR", "TAR_2", "TAR_3"},
	required_textures = {"go_hero_bolin"},
	plugin_required_textures = {},
	required_sounds = {"hero_bolin"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_bolin.templates"},
	animations = {"heroes.hero_bolin.animations"},
	sounds = {"heroes.hero_bolin.sounds"},
	groups = {"heroes.hero_bolin.groups"},

	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {255, 194, 79, 255},
		c3 = {255, 113, 25, 255},
		outline = {98, 37, 0, 255},
		outline_thickness = 2.5,
		glow = {98, 37, 0, 255},
		glow_thickness = 1
	}
}
