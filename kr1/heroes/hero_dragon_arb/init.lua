local NS = require("heroes.name_style")

return {
	name = "hero_dragon_arb",
	room = {
		available_level = 116,
		starting_level = 1,
		from_kr = 5,
		stats = {8, 4, 7, 5},
		portrait_image = "kr5_portrait_notxt_0015",
		thumb_image = "kr5_hero_room_thumbs_0015",
		icon_image = "kr5_mapButtons_portrait_hero_0015"
	},
	room_special_order = {"BERSERKER", "BERSERKER_2", "BERSERKER_3", "BERSERKER_4", "BERSERKER_5"},
	required_textures = {"go_hero_dragon_arb"},
	plugin_required_textures = {},
	required_sounds = {"hero_dragon_arb"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_dragon_arb.templates"},
	animations = {"heroes.hero_dragon_arb.animations"},
	sounds = {"heroes.hero_dragon_arb.sounds"},
	groups = {"heroes.hero_dragon_arb.groups"},

	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {112, 217, 96, 255},
		c3 = {45, 162, 76, 255},
		outline = {0, 106, 56, 255},
		outline_thickness = 2.5,
		glow = {0, 106, 56, 255},
		glow_thickness = 1
	}
}
