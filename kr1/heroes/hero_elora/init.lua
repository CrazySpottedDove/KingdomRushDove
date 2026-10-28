local NS = require("heroes.name_style")

return {
	name = "hero_elora",
	room = {
		available_level = 9,
		starting_level = 1,
		stats = {4, 3, 6, 7},
		portrait = 8,
		thumb = 8,
		icon = 8,
		portrait_image = "portrait_notxt_0008",
		thumb_image = "hero_room_thumbs_0008",
		icon_image = "mapButtons_portrait_hero_0008"
	},
	required_textures = {"go_hero_elora"},
	plugin_required_textures = {},
	required_sounds = {"hero_elora"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},

	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {255, 255, 255, 255},
		c3 = {150, 237, 245, 255},
		outline = {17, 108, 119, 255},
		outline_thickness = 1.5,
		glow = {17, 108, 119, 255},
		glow_thickness = 1
	}
}
