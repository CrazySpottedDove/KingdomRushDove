local NS = require("heroes.name_style")

return {
	name = "hero_veznan",
	room = {
		available_level = 63,
		starting_level = 5,
		stats = {3, 5, 0, 8},
		portrait_image = "kr3_portrait_notxt_0008",
		thumb_image = "kr3_hero_room_thumbs_0008",
		icon_image = "kr3_mapButtons_portrait_hero_0008"
	},
	room_special_order = {"SOULBURN", "SHACKLES", "ARCANENOVA", "ULTIMATE"},
	required_textures = {"go_hero_veznan"},
	plugin_required_textures = {},
	required_sounds = {"hero_veznan"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_veznan.templates"},
	animations = {"heroes.hero_veznan.animations"},
	sounds = {"heroes.hero_veznan.sounds"},
	groups = {"heroes.hero_veznan.groups"},

	name_style = {
		margin = 1,
		p1 = NS.p21,
		p2 = NS.p22,
		c1 = {230, 216, 247, 255},
		c2 = {176, 148, 248, 255},
		c3 = {94, 78, 204, 255},
		outline = {51, 22, 127, 255},
		outline_thickness = 2.5,
		glow = {51, 22, 127, 255},
		glow_thickness = 0.2
	}
}
