local NS = require("heroes.name_style")

return {
	name = "hero_bolin_kr6",
	room = {
		available_level = 203,
		stats = {4, 4, 8, 2},
		portrait_image = "hero_bolin_kr6_portrait",
		thumb_image = "hero_bolin_kr6_thumb",
		icon_image = "hero_bolin_kr6_icon"
	},
	room_special_order = {"SMOKE_MORTAR", "MINE_FIELD", "GIANT_SLAYER", "SHARPENED_ROUNDS", "EXPLOSIVE_ROUND", "SUPPRESSIVE_FIRE"},
	required_textures = {"go_hero_bolin_kr6"},
	plugin_required_textures = {},
	required_sounds = {"hero_bolin_kr6"},
	plugin_required_sounds = {},
	required_exoskeletons = {"bolinDef", "bolin_hitfxDef", "bolin_mineDef", "bolin_mortar_smokeDef", "bolin_ulti_decalDef"},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_bolin_kr6.templates"},
	animations = {"heroes.hero_bolin_kr6.animations"},
	sounds = {"heroes.hero_bolin_kr6.sounds"},
	groups = {"heroes.hero_bolin_kr6.groups"},
	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {255, 194, 79, 255},
		c3 = {255, 113, 25, 255},
		outline = {98, 37, 0, 255},
		outline_thickness = 2.5,
		glow = {98, 37, 0, 255},
		glow_thickness = 1
	}
}
