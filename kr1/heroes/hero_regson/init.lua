local NS = require("heroes.name_style")

return {
	name = "hero_regson",
	room = {
		available_level = 59,
		stats = {7, 5, 0, 6},
		portrait_image = "kr3_portrait_notxt_0004",
		thumb_image = "kr3_hero_room_thumbs_0004",
		icon_image = "kr3_mapButtons_portrait_hero_0004"
	},
	room_special_order = {"SLASH", "SLASH_2", "HEAL", "BLADE", "ULTIMATE"},
	required_textures = {"go_hero_regson"},
	plugin_required_textures = {},
	required_sounds = {"hero_regson"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_regson.templates"},
	animations = {"heroes.hero_regson.animations"},
	sounds = {"heroes.hero_regson.sounds"},
	groups = {"heroes.hero_regson.groups"},

	name_style = {
		margin = 1,
		p1 = NS.p21,
		p2 = NS.p22,
		c1 = {212, 225, 255, 255},
		c2 = {156, 165, 255, 255},
		c3 = {76, 74, 224, 255},
		outline = {47, 31, 124, 255},
		outline_thickness = 2,
		glow = {47, 31, 124, 255},
		glow_thickness = 0.2
	}
}
