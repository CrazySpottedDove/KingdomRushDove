local NS = require("heroes.name_style")

return {
	name = "hero_vesper",
	room = {
		available_level = 101,
		starting_level = 1,
		from_kr = 5,
		stats = {5, 5, 4, 5},
		portrait = 1,
		thumb = 1,
		icon = 1,
		portrait_image = "kr5_portrait_notxt_0001",
		thumb_image = "kr5_hero_room_thumbs_0001",
		icon_image = "kr5_mapButtons_portrait_hero_0001"
	},
	required_textures = {"go_hero_vesper"},
	plugin_required_textures = {},
	required_sounds = {"hero_vesper"},
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
		c2 = {182, 232, 240, 255},
		c3 = {65, 178, 220, 255},
		outline = {0, 69, 100, 255},
		outline_thickness = 2.5,
		glow = {0, 69, 100, 255},
		glow_thickness = 1
	}
}
