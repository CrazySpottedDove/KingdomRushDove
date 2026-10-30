local NS = require("heroes.name_style")

return {
	name = "hero_drakkan",
	room = {
		available_level = 209,
		stats = {9, 2, 8, 4},
		portrait_image = "hero_drakkan_kr6_portrait",
		thumb_image = "hero_drakkan_kr6_thumb",
		icon_image = "hero_drakkan_kr6_icon"
	},
	room_special_order = {"NULLIFYING_PULSE", "DECONSTRUCT", "DOUBLE_DRAGON", "MAGIC_PHASING", "ARCANE_AFFINITY", "ARCANE_STORM"},
	required_textures = {"go_hero_drakkan"},
	plugin_required_textures = {},
	required_sounds = {"hero_drakkan"},
	plugin_required_sounds = {},
	required_exoskeletons = {"hero_drakkanDef", "hero_drakkan_doubleDef"},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_drakkan.templates"},
	animations = {"heroes.hero_drakkan.animations"},
	sounds = {"heroes.hero_drakkan.sounds"},
	groups = {"heroes.hero_drakkan.groups"},
	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {196, 160, 255, 255},
		c3 = {128, 70, 214, 255},
		outline = {36, 0, 66, 255},
		outline_thickness = 2.5,
		glow = {36, 0, 66, 255},
		glow_thickness = 1
	}
}
