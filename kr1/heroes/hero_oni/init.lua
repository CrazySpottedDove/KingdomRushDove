local NS = require("heroes.name_style")

return {
	name = "hero_oni",
	room = {
		available_level = 20,
		starting_level = 1,
		stats = {7, 8, 0, 6},
		portrait = 11,
		thumb = 11,
		icon = 11,
		portrait_image = "portrait_notxt_0011",
		thumb_image = "hero_room_thumbs_0011",
		icon_image = "mapButtons_portrait_hero_0011"
	},
	room_special_order = {"DEATH_STRIKE", "TORMENT", "RAGE"},
	required_textures = {"go_hero_oni"},
	plugin_required_textures = {},
	required_sounds = {"hero_oni"},
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
		c2 = {255, 167, 98, 255},
		c3 = {224, 44, 0, 255},
		outline = {114, 18, 0, 255},
		outline_thickness = 1.5,
		glow = {114, 18, 0, 255},
		glow_thickness = 1
	}
}
