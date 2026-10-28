local NS = require("heroes.name_style")

return {
	name = "hero_priest",
	room = {
		available_level = 40,
		starting_level = 1,
		from_kr = 2,
		stats = {6, 3, 5, 8},
		portrait = 7,
		thumb = 7,
		icon = 7,
		portrait_image = "kr2_portrait_notxt_0007",
		thumb_image = "kr2_hero_room_thumbs_0007",
		icon_image = "kr2_mapButtons_portrait_hero_0007"
	},
	room_special_order = {"HOLYLIGHT", "CONSECRATE", "WINGSOFLIGHT"},
	required_textures = {"go_hero_priest"},
	plugin_required_textures = {},
	required_sounds = {"hero_priest"},
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
		c2 = {215, 251, 255, 255},
		c3 = {81, 202, 255, 255},
		outline = {0, 97, 121, 255},
		outline_thickness = 4.5,
		glow = {0, 97, 121, 255},
		glow_thickness = 1.5
	}
}
