local NS = require("heroes.name_style")

return {
	name = "hero_mecha",
	room = {
		available_level = 112,
		stats = {6, 4, 7, 5},
		portrait_image = "kr5_portrait_notxt_0009",
		thumb_image = "kr5_hero_room_thumbs_0009",
		icon_image = "kr5_mapButtons_portrait_hero_0009"
	},
	room_special_order = {"GOBLIDRONES", "TAR_BOMB", "POWER_SLAM", "MINE_DROP", "ULTIMATE"},
	required_textures = {"go_hero_mecha"},
	plugin_required_textures = {},
	required_sounds = {"hero_mecha"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_mecha.templates"},
	animations = {"heroes.hero_mecha.animations"},
	sounds = {"heroes.hero_mecha.sounds"},
	groups = {"heroes.hero_mecha.groups"},

	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {252, 142, 18, 255},
		c3 = {194, 102, 30, 255},
		outline = {136, 61, 42, 255},
		outline_thickness = 2.5,
		glow = {136, 61, 42, 255},
		glow_thickness = 1
	}
}
