local NS = require("heroes.name_style")

return {
	name = "hero_osnir",
	room = {
		available = {
			mode = "level",
			gen = "kr6",
			level = 19
		},
		stats = {7, 4, 6, 5},
		portrait_image = "hero_osnir_kr6_portrait",
		thumb_image = "hero_osnir_kr6_thumb",
		icon_image = "hero_osnir_kr6_icon"
	},
	room_special_order = {"HIT_AND_RUN", "ANTLER_SLAM", "STAMPEDE", "HARDENED_HUNTER", "SECOND_WIND", "DEER_GUARDIAN"},
	resources = {
		game = {
			required_textures = {"go_hero_osnir"},
			plugin_required_textures = {},
			required_sounds = {"hero_osnir"},
			plugin_required_sounds = {},
			required_exoskeletons = {
				"hero_osnir_unitDef",
				"hero_osnir_hitDef",
				"hero_osnir_projectileDef",
				"hero_osnir_projectile_hitDef",
				"hero_osnir_projectile_floorDef",
				"hero_osnir_spawn_unitDef",
				"hero_osnir_unit_ultiDef",
				"hero_osnir_ulti_area_attackDef",
				"hero_osnir_ulti_area_crackDef",
				"hero_osnir_ulti_area_fireDef",
				"hero_osnir_ulti_cornada_attackDef",
				"hero_osnir_ulti_spawn_decoDef",
				"hero_osnir_ulti_spawn_explosionDef",
				"hero_osnir_ulti_spawn_rayDef"
			},
			plugin_required_exoskeletons = {}
		},
		map = {
			required_textures = {},
			plugin_required_textures = {},
			required_sounds = {},
			plugin_required_sounds = {},
			required_exoskeletons = {},
			plugin_required_exoskeletons = {}
		}
	},
	templates = {"heroes.hero_osnir.templates"},
	sounds = {"heroes.hero_osnir.sounds"},
	groups = {"heroes.hero_osnir.groups"},
	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {196, 232, 168, 255},
		c3 = {120, 184, 96, 255},
		outline = {24, 52, 20, 255},
		outline_thickness = 2.5,
		glow = {24, 52, 20, 255},
		glow_thickness = 1
	}
}
