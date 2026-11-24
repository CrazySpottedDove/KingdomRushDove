local NS = require("heroes.name_style")

return {
	name = "hero_murglun",
	room = {
		available = {
			mode = "level",
			gen = "kr1",
			level = 1
		},
		stats = {8, 3, 6, 4},
		portrait_image = "kr4_portrait_notxt_0012",
		thumb_image = "kr4_hero_room_thumbs_0012",
		icon_image = "kr4_mapButtons_portrait_hero_0012"
	},
	room_special_order = {"PASSIVE", "MAGMA_POOL", "TAR_MAKER", "GEYSER", "INFERNAL_HEAT", "ULTIMATE"},
	resources = {
		game = {
			required_textures = {"go_hero_murglun"},
			plugin_required_textures = {},
			required_sounds = {"hero_murglun"},
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
	templates = {"heroes.hero_murglun.templates"},
	animations = {"heroes.hero_murglun.animations"},
	sounds = {"heroes.hero_murglun.sounds"},
	groups = {"heroes.hero_murglun.groups"},
	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {255, 108, 0, 255},
		c3 = {206, 70, 0, 255},
		outline = {147, 32, 0, 255},
		outline_thickness = 2.5,
		glow = {147, 32, 0, 255},
		glow_thickness = 1
	}
}
