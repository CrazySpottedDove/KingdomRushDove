local NS = require("heroes.name_style")

return {
	name = "hero_giant",
	room = {
		available_level = 38,
		starting_level = 5,
		from_kr = 2,
		stats = {7, 5, 0, 2},
		portrait = 8,
		thumb = 8,
		icon = 8,
		portrait_image = "kr2_portrait_notxt_0008",
		thumb_image = "kr2_hero_room_thumbs_0008",
		icon_image = "kr2_mapButtons_portrait_hero_0008"
	},
	room_special_order = {"BOULDERTHROW", "MASSIVEDAMAGE", "STOMP", "HARDROCK"},
	required_textures = {"go_hero_giant"},
	plugin_required_textures = {},
	required_sounds = {"hero_giant"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},

	name_style = {
		margin = 2,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 0},
		c2 = {187, 251, 255, 255},
		c3 = {0, 177, 172, 255},
		outline = {0, 83, 86, 255},
		outline_thickness = 4.5,
		glow = {0, 83, 86, 255},
		glow_thickness = 1.5
	}
}
