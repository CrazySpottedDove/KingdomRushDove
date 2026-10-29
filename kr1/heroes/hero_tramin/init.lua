local NS = require("heroes.name_style")

return {
	name = "hero_tramin",
	room = {
		available_level = 1,
		stats = {5, 8, 6, 7},
		portrait_image = "kr4_portrait_notxt_0006",
		thumb_image = "kr4_hero_room_thumbs_0006",
		icon_image = "kr4_mapButtons_portrait_hero_0006"
	},
	room_special_order = {"ULTIMATE", "BOMBOTS", "NITRO_RUSH", "FLASHBANG", "ROCKET_BARRAGE", "ULTIMATE_2"},
	required_textures = {"go_hero_tramin"},
	plugin_required_textures = {},
	required_sounds = {"hero_tramin"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_tramin.templates"},
	animations = {"heroes.hero_tramin.animations"},
	sounds = {"heroes.hero_tramin.sounds"},
	groups = {"heroes.hero_tramin.groups"},

	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {255, 183, 95, 255},
		c3 = {255, 98, 0, 255},
		outline = {88, 19, 0, 255},
		outline_thickness = 2.5,
		glow = {88, 19, 0, 255},
		glow_thickness = 1
	}
}
