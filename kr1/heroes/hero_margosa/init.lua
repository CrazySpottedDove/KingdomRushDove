local NS = require("heroes.name_style")

return {
	name = "hero_margosa",
	room = {
		available_level = 1,
		stats = {9, 7, 0, 6},
		portrait_image = "kr4_portrait_notxt_0004",
		thumb_image = "kr4_hero_room_thumbs_0004",
		icon_image = "kr4_mapButtons_portrait_hero_0004"
	},
	room_special_order = {"ULTIMATE", "BAT_FAMILIAR", "MYST_FORM", "DARK_CALL", "VAMPIRIC_TOUCH", "ULTIMATE_2"},
	required_textures = {"go_hero_margosa"},
	plugin_required_textures = {},
	required_sounds = {"hero_margosa"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_margosa.templates"},
	animations = {"heroes.hero_margosa.animations"},
	sounds = {"heroes.hero_margosa.sounds"},
	groups = {"heroes.hero_margosa.groups"},

	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {192, 32, 32, 255},
		c2 = {224, 64, 64, 255},
		c3 = {96, 0, 0, 255},
		outline = {64, 0, 0, 255},
		outline_thickness = 2.5,
		glow = {64, 0, 0, 255},
		glow_thickness = 1
	}
}
