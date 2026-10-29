local NS = require("heroes.name_style")

return {
	name = "hero_pirate",
	room = {
		available_level = 31,
		starting_level = 1,
		stats = {5, 5, 5, 5},
		portrait_image = "kr2_portrait_notxt_0003",
		thumb_image = "kr2_hero_room_thumbs_0003",
		icon_image = "kr2_mapButtons_portrait_hero_0003"
	},
	room_special_order = {"SCATTERSHOT", "KRAKEN", "LOOTING"},
	required_textures = {"go_hero_pirate"},
	plugin_required_textures = {},
	required_sounds = {"hero_pirate"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_pirate.templates"},
	animations = {"heroes.hero_pirate.animations"},
	sounds = {"heroes.hero_pirate.sounds"},
	groups = {"heroes.hero_pirate.groups"},
	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 0},
		c2 = {215, 253, 255, 255},
		c3 = {29, 203, 217, 255},
		outline = {0, 81, 84, 255},
		outline_thickness = 2.5,
		glow = {0, 81, 84, 255},
		glow_thickness = 1.5
	}
}
