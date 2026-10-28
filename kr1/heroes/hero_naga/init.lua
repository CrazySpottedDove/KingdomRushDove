local NS = require("heroes.name_style")

return {
	name = "hero_naga",
	room = {
		available_level = 1,
		starting_level = 1,
		from_kr = 4,
		stats = {6, 6, 5, 5},
		portrait = 10,
		thumb = 10,
		icon = 10,
		portrait_image = "kr4_portrait_notxt_0010",
		thumb_image = "kr4_hero_room_thumbs_0010",
		icon_image = "kr4_mapButtons_portrait_hero_0010"
	},
	room_special_order = {"PASSIVE", "SPLASH", "WAVE", "BANNER_ALLIES", "GAZE", "ULTIMATE"},
	required_textures = {"go_hero_naga"},
	plugin_required_textures = {},
	required_sounds = {"hero_naga"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_naga.templates"},
	animations = {"heroes.hero_naga.animations"},
	sounds = {"heroes.hero_naga.sounds"},
	groups = {"heroes.hero_naga.groups"},

	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {10, 221, 230, 255},
		c3 = {4, 154, 181, 255},
		outline = {0, 86, 131, 255},
		outline_thickness = 2.5,
		glow = {0, 86, 131, 255},
		glow_thickness = 1
	}
}
