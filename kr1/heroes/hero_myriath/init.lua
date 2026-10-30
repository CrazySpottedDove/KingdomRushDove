local NS = require("heroes.name_style")

return {
	name = "hero_myriath",
	room = {
		available_level = 205,
		stats = {2, 0, 5, 6},
		portrait_image = "hero_myriath_kr6_portrait",
		thumb_image = "hero_myriath_kr6_thumb",
		icon_image = "hero_myriath_kr6_icon"
	},
	room_special_order = {"FORWARD_ILLUSION", "GUARDING_DECOY", "MIRROR_MISSILES", "SOLID_LIGHT", "LAST_EFFORT", "I_AM_LEGION"},
	required_textures = {"go_hero_myriath"},
	plugin_required_textures = {},
	required_sounds = {"hero_myriath"},
	plugin_required_sounds = {},
	required_exoskeletons = {"hero_myriathDef", "hero_myriath_illusionDef"},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_myriath.templates"},
	animations = {"heroes.hero_myriath.animations"},
	sounds = {"heroes.hero_myriath.sounds"},
	groups = {"heroes.hero_myriath.groups"},
	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {255, 177, 252, 255},
		c3 = {140, 46, 212, 255},
		outline = {55, 0, 60, 255},
		outline_thickness = 2.5,
		glow = {55, 0, 60, 255},
		glow_thickness = 1
	}
}
