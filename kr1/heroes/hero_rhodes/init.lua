local NS = require("heroes.name_style")

return {
	name = "hero_rhodes",
	room = {
		available_level = 207,
		stats = {7, 5, 3, 5.5},
		portrait_image = "hero_rhodes_kr6_portrait",
		thumb_image = "hero_rhodes_kr6_thumb",
		icon_image = "hero_rhodes_kr6_icon"
	},
	room_special_order = {"SUNBEAM", "STRONG_CRUST", "TWISTING_TOP", "IMPERVIOUS", "UNSTOPPABLE", "SOLAR_FLARE"},
	required_textures = {"go_hero_rhodes"},
	plugin_required_textures = {},
	required_sounds = {"hero_rhodes"},
	plugin_required_sounds = {},
	required_exoskeletons = {"hero_rhodesDef"},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_rhodes.templates"},
	animations = {"heroes.hero_rhodes.animations"},
	sounds = {"heroes.hero_rhodes.sounds"},
	groups = {"heroes.hero_rhodes.groups"},
	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {255, 226, 168, 255},
		c3 = {214, 148, 62, 255},
		outline = {85, 48, 8, 255},
		outline_thickness = 2.5,
		glow = {85, 48, 8, 255},
		glow_thickness = 1
	}
}
