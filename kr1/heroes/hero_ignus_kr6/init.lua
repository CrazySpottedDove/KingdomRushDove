local NS = require("heroes.name_style")

return {
	name = "hero_ignus_kr6",
	room = {
		available_level = 210,
		stats = {2, 0, 7, 8},
		portrait_image = "hero_ignus_kr6_portrait",
		thumb_image = "hero_ignus_kr6_thumb",
		icon_image = "hero_ignus_kr6_icon"
	},
	room_special_order = {"FIREBALL", "HEAT_WAVE", "FLAME_RUSH", "MELTING_CORE", "REVERSE_ENTROPY", "SUPERNOVA"},
	required_textures = {"go_hero_ignus_kr6"},
	plugin_required_textures = {},
	required_sounds = {"hero_ignus_kr6"},
	plugin_required_sounds = {},
	required_exoskeletons = {"ignusDef", "skill01Def", "skill02Def", "skill03Def"},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_ignus_kr6.templates"},
	animations = {"heroes.hero_ignus_kr6.animations"},
	sounds = {"heroes.hero_ignus_kr6.sounds"},
	groups = {"heroes.hero_ignus_kr6.groups"},
	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {255, 242, 63, 255},
		c3 = {255, 126, 0, 255},
		outline = {105, 40, 0, 255},
		outline_thickness = 2.5,
		glow = {105, 40, 0, 255},
		glow_thickness = 1
	}
}
