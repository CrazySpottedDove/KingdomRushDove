local NS = require("heroes.name_style")

return {
	name = "hero_durax",
	room = {
		available_level = 57,
		starting_level = 5,
		from_kr = 3,
		stats = {5, 8, 0, 7},
		portrait = 11,
		thumb = 11,
		icon = 11,
		portrait_image = "kr3_portrait_notxt_0011",
		thumb_image = "kr3_hero_room_thumbs_0011",
		icon_image = "kr3_mapButtons_portrait_hero_0011"
	},
	room_special_order = {"SHARDSEED", "LETHAL_PRISM", "ARMSWORD", "CRYSTALLITES", "ULTIMATE"},
	required_textures = {"go_hero_durax"},
	plugin_required_textures = {},
	required_sounds = {"hero_durax"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},

	name_style = {
		margin = 1.5,
		p1 = NS.p21,
		p2 = NS.p22,
		c1 = {160, 255, 252, 255},
		c2 = {0, 156, 189, 255},
		c3 = {0, 74, 90, 255},
		outline = {165, 235, 233, 255},
		outline_thickness = 2,
		glow = {165, 235, 233, 255},
		glow_thickness = 1
	}
}
