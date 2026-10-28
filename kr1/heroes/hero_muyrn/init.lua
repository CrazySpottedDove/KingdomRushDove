local NS = require("heroes.name_style")

return {
	name = "hero_muyrn",
	room = {
		available_level = 103,
		starting_level = 1,
		from_kr = 5,
		stats = {6, 5, 5, 6},
		portrait = 3,
		thumb = 3,
		icon = 3,
		portrait_image = "kr5_portrait_notxt_0003",
		thumb_image = "kr5_hero_room_thumbs_0003",
		icon_image = "kr5_mapButtons_portrait_hero_0003"
	},
	required_textures = {"go_hero_muyrn"},
	plugin_required_textures = {},
	required_sounds = {"hero_muyrn"},
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
		c2 = {238, 255, 93, 255},
		c3 = {145, 215, 0, 255},
		outline = {37, 93, 0, 255},
		outline_thickness = 2.5,
		glow = {37, 93, 0, 255},
		glow_thickness = 1
	}
}
