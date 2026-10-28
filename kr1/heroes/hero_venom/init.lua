local NS = require("heroes.name_style")

return {
	name = "hero_venom",
	room = {
		available_level = 108,
		starting_level = 1,
		from_kr = 5,
		stats = {5, 5, 5, 6},
		portrait = 4,
		thumb = 4,
		icon = 4,
		portrait_image = "kr5_portrait_notxt_0004",
		thumb_image = "kr5_hero_room_thumbs_0004",
		icon_image = "kr5_mapButtons_portrait_hero_0004"
	},
	required_textures = {"go_hero_venom"},
	plugin_required_textures = {},
	required_sounds = {"hero_venom"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},

	name_style = {
		margin = 2,
		p1 = NS.p21,
		p2 = NS.p22,
		c1 = {231, 192, 255, 0},
		c2 = {209, 136, 255, 255},
		c3 = {128, 68, 190, 255},
		outline = {61, 27, 86, 255},
		outline_thickness = 4.5,
		glow = {61, 27, 86, 255},
		glow_thickness = 1.5
	}
}
