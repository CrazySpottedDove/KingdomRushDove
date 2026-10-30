local NS = require("heroes.name_style")

return {
	name = "hero_illiana",
	room = {
		available_level = 212,
		stats = {4, 6, 5, 3},
		portrait_image = "hero_illiana_kr6_portrait",
		thumb_image = "hero_illiana_kr6_thumb",
		icon_image = "hero_illiana_kr6_icon"
	},
	room_special_order = {"TAG", "GLITTER_BOMB", "EASY_PREY", "TEAMWORK", "AIRBORNE_BLISS", "SPARKY_INCINERATE"},
	required_textures = {"go_hero_illiana"},
	plugin_required_textures = {},
	required_sounds = {"hero_illiana"},
	plugin_required_sounds = {},
	required_exoskeletons = {"hero_illianaDef", "hero_illiana_dragonDef", "hero_illiana_walk2Def", "hero_illiana_dragon_fire_fxDef"},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_illiana.templates"},
	animations = {"heroes.hero_illiana.animations"},
	sounds = {"heroes.hero_illiana.sounds"},
	groups = {"heroes.hero_illiana.groups"},
	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {214, 178, 255, 255},
		c3 = {139, 92, 246, 255},
		outline = {49, 20, 98, 255},
		outline_thickness = 2.5,
		glow = {49, 20, 98, 255},
		glow_thickness = 1
	}
}
