local NS = require("heroes.name_style")

return {
	name = "hero_dragon_bone",
	room = {
		available = {
			mode = "level",
			gen = "kr5",
			level = 16
		},
		stats = {6, 0, 5, 5},
		portrait_image = "kr5_portrait_notxt_0014",
		thumb_image = "kr5_hero_room_thumbs_0014",
		icon_image = "kr5_mapButtons_portrait_hero_0014"
	},
	room_special_order = {"BERSERKER", "BERSERKER_2", "BERSERKER_3", "BERSERKER_4", "BERSERKER_5", "BERSERKER_6"},
	resources = {
		game = {
			required_textures = {"go_hero_dragon_bone"},
			plugin_required_textures = {},
			required_sounds = {"hero_dragon_bone"},
			plugin_required_sounds = {},
			required_exoskeletons = {},
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
	templates = {"heroes.hero_dragon_bone.templates"},
	animations = {"heroes.hero_dragon_bone.animations"},
	sounds = {"heroes.hero_dragon_bone.sounds"},
	groups = {"heroes.hero_dragon_bone.groups"},

	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 0},
		c2 = {228, 255, 95, 255},
		c3 = {107, 173, 0, 255},
		outline = {29, 51, 1, 255},
		outline_thickness = 4.5,
		glow = {29, 51, 1, 255},
		glow_thickness = 1.5
	}
}
