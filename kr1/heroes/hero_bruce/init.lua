local NS = require("heroes.name_style")

return {
	name = "hero_bruce",
	room = {
		available_level = 64,
		stats = {6, 6, 0, 5},
		portrait_image = "kr3_portrait_notxt_0013",
		thumb_image = "kr3_hero_room_thumbs_0013",
		icon_image = "kr3_mapButtons_portrait_hero_0013"
	},
	room_special_order = {"SHARP_CLAWS", "KINGS_ROAR", "GRIEVOUS_BITES", "ULTIMATE"},
	required_textures = {"go_hero_bruce"},
	plugin_required_textures = {},
	required_sounds = {"hero_bruce"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_bruce.templates"},
	animations = {"heroes.hero_bruce.animations"},
	sounds = {"heroes.hero_bruce.sounds"},
	groups = {"heroes.hero_bruce.groups"},

	name_style = {
		margin = 1.5,
		p1 = NS.p21,
		p2 = NS.p22,
		c1 = {255, 255, 255, 255},
		c2 = {192, 253, 254, 255},
		c3 = {90, 168, 186, 255},
		outline = {30, 72, 88, 255},
		outline_thickness = 2,
		glow = {30, 72, 88, 255},
		glow_thickness = 1
	}
}
