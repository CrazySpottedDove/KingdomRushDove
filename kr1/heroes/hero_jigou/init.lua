local NS = require("heroes.name_style")

return {
	name = "hero_jigou",
	room = {
		available_level = 1,
		starting_level = 1,
		stats = {8, 7, 0, 3},
		portrait_image = "kr4_portrait_notxt_0007",
		thumb_image = "kr4_hero_room_thumbs_0007",
		icon_image = "kr4_mapButtons_portrait_hero_0007"
	},
	room_special_order = {"UNDEAD_SERVITUDE", "ICE_SHARD", "FROZEN_BREATH", "EARTHSHAKE", "GLACIAL_FORM", "ULTIMATE"},
	required_textures = {"go_hero_jigou"},
	plugin_required_textures = {},
	required_sounds = {"hero_jigou"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_jigou.templates"},
	animations = {"heroes.hero_jigou.animations"},
	sounds = {"heroes.hero_jigou.sounds"},
	groups = {"heroes.hero_jigou.groups"},

	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {102, 204, 255, 255},
		c2 = {51, 153, 255, 255},
		c3 = {0, 102, 204, 255},
		outline = {0, 51, 102, 255},
		outline_thickness = 2.5,
		glow = {0, 51, 102, 255},
		glow_thickness = 1
	}
}
