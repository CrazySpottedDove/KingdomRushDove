local NS = require("heroes.name_style")

return {
	name = "hero_gerald_kr6",
	room = {
		available_level = 1,
		starting_level = 1,
		stats = {7, 5, 4, 4},
		from_kr = 6,
		portrait_image = "hero_gerald_kr6_portrait",
		thumb_image = "hero_gerald_kr6_thumb",
		icon_image = "hero_gerald_kr6_icon"
	},
	room_special_order = {"INSPIRE_COURAGE", "SHIELD_OF_RETRIBUTION", "FATED_SURVIVOR", "HARDENED_STEEL", "BATTLE_VIGOR", "DIVINE_BLADE"},
	required_textures = {"go_hero_gerald_kr6"},
	plugin_required_textures = {},
	required_sounds = {"hero_gerald_kr6"},
	plugin_required_sounds = {},
	required_exoskeletons = {"hero_geraldDef", "hero_gerald_hit_fxDef", "hero_gerald_inspire_courage_buff_fxDef", "hero_gerald_inspire_courage_fxDef", "hero_gerald_inspire_courage_buff_decalDef", "hero_gerald_shield_of_retribution_fxDef", "hero_gerald_fated_survivor_teleportDef", "hero_gerald_fated_survivor_decalDef", "hero_gerald_ultimate_decalDef"},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_gerald_kr6.templates"},
	sounds = {"heroes.hero_gerald_kr6.sounds"},
	groups = {"heroes.hero_gerald_kr6.groups"},
	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {182, 232, 255, 255},
		c3 = {65, 178, 229, 255},
		outline = {0, 69, 100, 255},
		outline_thickness = 2.5,
		glow = {0, 69, 100, 255},
		glow_thickness = 1
	}
}
