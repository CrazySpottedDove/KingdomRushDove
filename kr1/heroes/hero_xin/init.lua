local NS = require("heroes.name_style")

return {
	name = "hero_xin",
	room = {
		available_level = 53,
		starting_level = 5,
		from_kr = 3,
		stats = {6, 4, 0, 8},
		portrait = 9,
		thumb = 9,
		icon = 9,
		portrait_image = "kr3_portrait_notxt_0009",
		thumb_image = "kr3_hero_room_thumbs_0009",
		icon_image = "kr3_mapButtons_portrait_hero_0009"
	},
	required_textures = {"go_hero_xin"},
	plugin_required_textures = {},
	required_sounds = {"hero_xin"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},

	name_style = {
		margin = 1,
		p1 = NS.p21,
		p2 = NS.p22,
		c1 = {252, 240, 196, 255},
		c2 = {242, 176, 65, 255},
		c3 = {187, 86, 34, 255},
		outline = {89, 29, 0, 255},
		outline_thickness = 2.5,
		glow = {89, 29, 0, 255},
		glow_thickness = 0.2
	}
}
