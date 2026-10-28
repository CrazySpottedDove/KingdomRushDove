local NS = require("heroes.name_style")

return {
	name = "hero_alleria",
	room = {
		available_level = 5,
		starting_level = 1,
		stats = {4, 3, 5, 7},
		portrait = 2,
		thumb = 2,
		icon = 2,
		portrait_image = "portrait_notxt_0002",
		thumb_image = "hero_room_thumbs_0002",
		icon_image = "mapButtons_portrait_hero_0002"
	},
	room_special_order = {"MULTISHOT", "CALLOFWILD", "MISSILESHOT"},
	required_textures = {"go_hero_alleria"},
	plugin_required_textures = {},
	required_sounds = {"hero_alleria"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_alleria.templates"},
	animations = {"heroes.hero_alleria.animations"},
	sounds = {"heroes.hero_alleria.sounds"},
	groups = {"heroes.hero_alleria.groups"},

	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {238, 255, 93, 255},
		c3 = {145, 215, 0, 255},
		outline = {37, 93, 0, 255},
		outline_thickness = 2.5,
		glow = {37, 93, 0, 255},
		glow_thickness = 1
	}
}
