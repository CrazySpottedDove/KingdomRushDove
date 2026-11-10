local NS = require("heroes.name_style")

return {
	name = "hero_eiskalt",
	room = {
		available = {
			mode = "level",
			gen = "kr1",
			level = 1
		},
		stats = {9, 0, 9, 5},
		portrait_image = "kr4_portrait_notxt_0011",
		thumb_image = "kr4_hero_room_thumbs_0011",
		icon_image = "kr4_mapButtons_portrait_hero_0011"
	},
	room_special_order = {"ULTIMATE", "EXPLOSION", "COLDFURY", "FROSTY", "ICEPEAK", "ULTIMATE_2"},
	resources = {
		game = {
			required_textures = {"go_hero_eiskalt"},
			plugin_required_textures = {},
			required_sounds = {"hero_eiskalt"},
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
	templates = {"heroes.hero_eiskalt.templates"},
	animations = {"heroes.hero_eiskalt.animations"},
	sounds = {"heroes.hero_eiskalt.sounds"},
	groups = {"heroes.hero_eiskalt.groups"},

	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {102, 204, 255, 255},
		c2 = {51, 153, 255, 255},
		c3 = {0, 102, 204, 255},
		outline = {0, 51, 102, 255},
		outline_thickness = 2.5,
		glow = {0, 51, 102, 255},
		glow_thickness = 1
	}
}
