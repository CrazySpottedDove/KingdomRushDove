local NS = require("heroes.name_style")

return {
	name = "hero_ingvar",
	room = {
		available_level = 8,
		starting_level = 1,
		stats = {8, 6, 0, 5},
		portrait = 9,
		thumb = 9,
		icon = 9,
		portrait_image = "portrait_notxt_0009",
		thumb_image = "hero_room_thumbs_0009",
		icon_image = "mapButtons_portrait_hero_0009"
	},
	room_special_order = {"ICE_STORM", "ANCESTORS_CALL", "BEAR"},
	required_textures = {"go_hero_ingvar"},
	plugin_required_textures = {},
	required_sounds = {"hero_ingvar"},
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
		c2 = {255, 211, 159, 255},
		c3 = {255, 111, 0, 255},
		outline = {102, 33, 0, 255},
		outline_thickness = 2.5,
		glow = {102, 33, 0, 255},
		glow_thickness = 1
	}
}
