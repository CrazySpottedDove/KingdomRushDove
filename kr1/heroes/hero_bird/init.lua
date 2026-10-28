local NS = require("heroes.name_style")

return {
	name = "hero_bird",
	room = {
		available_level = 109,
		starting_level = 1,
		from_kr = 5,
		stats = {5, 7, 6, 5},
		portrait = 8,
		thumb = 8,
		icon = 8,
		portrait_image = "kr5_portrait_notxt_0008",
		thumb_image = "kr5_hero_room_thumbs_0008",
		icon_image = "kr5_mapButtons_portrait_hero_0008"
	},
	required_textures = {"go_hero_bird"},
	plugin_required_textures = {},
	required_sounds = {"hero_bird"},
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
		c2 = {255, 81, 59, 255},
		c3 = {201, 43, 46, 255},
		outline = {133, 5, 33, 255},
		outline_thickness = 2.5,
		glow = {133, 5, 33, 255},
		glow_thickness = 1
	}
}
