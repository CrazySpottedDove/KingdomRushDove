local NS = require("heroes.name_style")

return {
	name = "hero_alien",
	room = {
		available_level = 35,
		starting_level = 1,
		from_kr = 2,
		stats = {4, 5, 0, 6},
		portrait = 9,
		thumb = 9,
		icon = 9,
		portrait_image = "kr2_portrait_notxt_0009",
		thumb_image = "kr2_hero_room_thumbs_0009",
		icon_image = "kr2_mapButtons_portrait_hero_0009"
	},
	room_special_order = {"ENERGYGLAIVE", "PURIFICATIONPROTOCOL", "ABDUCTION", "VIBROBLADES", "FINALCOUNTDOWN"},
	required_textures = {"go_hero_alien"},
	plugin_required_textures = {},
	required_sounds = {"hero_alien"},
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
		c2 = {222, 180, 255, 255},
		c3 = {117, 65, 215, 255},
		outline = {70, 20, 109, 255},
		outline_thickness = 4.5,
		glow = {70, 20, 109, 255},
		glow_thickness = 1.5
	}
}
