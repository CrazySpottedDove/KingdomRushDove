local NS = require("heroes.name_style")

return {
	name = "hero_malik",
	room = {
		available_level = 3,
		stats = {8, 6, 0, 3},
		portrait_image = "portrait_notxt_0003",
		thumb_image = "hero_room_thumbs_0003",
		icon_image = "mapButtons_portrait_hero_0003"
	},
	room_special_order = {"SURGE_OF_FLAME", "SMASH", "FISSURE"},
	required_textures = {"go_hero_malik"},
	plugin_required_textures = {},
	required_sounds = {"hero_malik"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_malik.templates"},
	animations = {"heroes.hero_malik.animations"},
	groups = {"heroes.hero_malik.groups"},

	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {255, 246, 126, 255},
		c3 = {255, 168, 0, 255},
		outline = {135, 74, 0, 255},
		outline_thickness = 2.5,
		glow = {135, 74, 0, 255},
		glow_thickness = 1
	}
}
