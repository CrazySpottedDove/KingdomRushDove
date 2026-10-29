local NS = require("heroes.name_style")

return {
	name = "hero_ignus",
	room = {
		available_level = 11,
		starting_level = 1,
		stats = {7, 7, 0, 7},
		portrait_image = "portrait_notxt_0006",
		thumb_image = "hero_room_thumbs_0006",
		icon_image = "mapButtons_portrait_hero_0006"
	},
	room_special_order = {"FLAMING_FRENZY", "SURGE_OF_FLAME", "SURGE_OF_FLAME_2"},
	required_textures = {"go_hero_ignus"},
	plugin_required_textures = {},
	required_sounds = {"hero_ignus"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_ignus.templates"},
	animations = {"heroes.hero_ignus.animations"},
	sounds = {"heroes.hero_ignus.sounds"},
	groups = {"heroes.hero_ignus.groups"},

	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {255, 242, 63, 255},
		c3 = {255, 126, 0, 255},
		outline = {105, 40, 0, 255},
		outline_thickness = 2.5,
		glow = {105, 40, 0, 255},
		glow_thickness = 1
	}
}
