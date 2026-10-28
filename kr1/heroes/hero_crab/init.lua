local NS = require("heroes.name_style")

return {
	name = "hero_crab",
	room = {
		available_level = 42,
		starting_level = 5,
		from_kr = 2,
		stats = {7, 5, 0, 6},
		portrait = 11,
		thumb = 11,
		icon = 11,
		portrait_image = "kr2_portrait_notxt_0011",
		thumb_image = "kr2_hero_room_thumbs_0011",
		icon_image = "kr2_mapButtons_portrait_hero_0011"
	},
	required_textures = {"go_hero_crab"},
	plugin_required_textures = {},
	required_sounds = {"hero_crab"},
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
		c1 = {0, 0, 0, 0},
		c2 = {226, 255, 123, 255},
		c3 = {133, 170, 0, 255},
		outline = {56, 72, 0, 255},
		outline_thickness = 4.5,
		glow = {56, 72, 0, 255},
		glow_thickness = 1.5
	}
}
