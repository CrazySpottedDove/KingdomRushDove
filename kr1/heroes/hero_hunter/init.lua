local NS = require("heroes.name_style")

return {
	name = "hero_hunter",
	room = {
		available_level = 107,
		stats = {6, 5, 6, 7},
		portrait_image = "kr5_portrait_notxt_0006",
		thumb_image = "kr5_hero_room_thumbs_0006",
		icon_image = "kr5_mapButtons_portrait_hero_0006"
	},
	room_special_order = {"BERSERKER", "BERSERKER_2", "BERSERKER_3", "BERSERKER_4", "BERSERKER_5"},
	required_textures = {"go_hero_hunter"},
	plugin_required_textures = {},
	required_sounds = {"hero_hunter"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_hunter.templates"},
	animations = {"heroes.hero_hunter.animations"},
	sounds = {"heroes.hero_hunter.sounds"},
	groups = {"heroes.hero_hunter.groups"},

	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 0},
		c2 = {255, 179, 175, 255},
		c3 = {212, 68, 83, 255},
		outline = {100, 0, 16, 255},
		outline_thickness = 4.5,
		glow = {100, 0, 16, 255},
		glow_thickness = 1.5
	}
}
