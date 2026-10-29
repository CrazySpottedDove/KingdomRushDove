local NS = require("heroes.name_style")

return {
	name = "hero_zefira",
	room = {
		available_level = 202,
		stats = {6, 5, 7, 4},
		portrait_image = "hero_zefira_kr6_portrait",
		thumb_image = "hero_zefira_kr6_thumb",
		icon_image = "hero_zefira_kr6_icon"
	},
	room_special_order = {"DAZZLING_HAMMER", "SHIELDING_BLADES", "ASTRAL_BLINK", "WEAKENING_AURA", "SPELL_PROFICIENCY", "ETHEREAL_SPEARS"},
	required_textures = {"go_hero_zefira"},
	plugin_required_textures = {},
	required_sounds = {"hero_zefira"},
	plugin_required_sounds = {},
	required_exoskeletons = {
		"hero_zefiraDef",
		"hero_zefira_attack2_hitDef",
		"hero_zefira_attack_hitDef",
		"hero_zefira_attack_projectileDef",
		"hero_zefira_skill1_decalDef",
		"hero_zefira_skill1_decalfxDef",
		"hero_zefira_skill1_hitDef",
		"hero_zefira_skill2Def",
		"hero_zefira_skill2_hitDef",
		"hero_zefira_talent_decalDef",
		"hero_zefira_talent_decal_bigDef",
		"hero_zefira_talent_modDef",
		"hero_zefira_talent_mod_bigDef",
		"hero_zefira_teleport_buffDef",
		"hero_zefira_teleport_decalDef",
		"hero_zefira_ultimateDef",
		"hero_zefira_ultimate_decalDef"
	},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_zefira.templates"},
	sounds = {"heroes.hero_zefira.sounds"},
	groups = {"heroes.hero_zefira.groups"},
	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {180, 255, 230, 255},
		c3 = {70, 190, 160, 255},
		outline = {0, 70, 60, 255},
		outline_thickness = 2.5,
		glow = {0, 70, 60, 255},
		glow_thickness = 1
	}
}
