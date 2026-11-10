local NS = require("heroes.name_style")

return {
	name = "hero_raelyn",
	room = {
		available = {
			mode = "level",
			gen = "kr5",
			level = 2
		},
		stats = {7, 6, 0, 3},
		portrait_image = "kr5_portrait_notxt_0002",
		thumb_image = "kr5_hero_room_thumbs_0002",
		icon_image = "kr5_mapButtons_portrait_hero_0002"
	},
	room_special_order = {"BERSERKER", "BERSERKER_2", "BERSERKER_3", "BERSERKER_4", "BERSERKER_5"},
	resources = {
		game = {
			required_textures = {"go_hero_raelyn"},
			plugin_required_textures = {},
			required_sounds = {"hero_raelyn"},
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
	templates = {"heroes.hero_raelyn.templates"},
	animations = {"heroes.hero_raelyn.animations"},
	sounds = {"heroes.hero_raelyn.sounds"},
	groups = {"heroes.hero_raelyn.groups"},

	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 0},
		c2 = {255, 183, 95, 255},
		c3 = {255, 98, 0, 255},
		outline = {88, 19, 0, 255},
		outline_thickness = 4.5,
		glow = {88, 19, 0, 255},
		glow_thickness = 1.5
	}
}
