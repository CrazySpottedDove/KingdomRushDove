local NS = require("heroes.name_style")

return {
	name = "hero_lilith",
	room = {
		available_level = 60,
		starting_level = 5,
		from_kr = 3,
		stats = {6, 5, 5, 6},
		portrait = 14,
		thumb = 14,
		icon = 14,
		portrait_image = "kr3_portrait_notxt_0014",
		thumb_image = "kr3_hero_room_thumbs_0014",
		icon_image = "kr3_mapButtons_portrait_hero_0014"
	},
	room_special_order = {"INFERNAL_WHEEL", "REAPERS_HARVEST", "ULTIMATE", "SOUL_EATER", "RESURRECTION", "RESURRECTION_2"},
	required_textures = {"go_hero_lilith"},
	plugin_required_textures = {},
	required_sounds = {"hero_lilith"},
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
		c1 = {255, 225, 177, 255},
		c2 = {255, 171, 51, 255},
		c3 = {207, 73, 19, 255},
		outline = {107, 12, 3, 255},
		outline_thickness = 2.5,
		glow = {89, 29, 0, 255},
		glow_thickness = 0.2
	}
}
