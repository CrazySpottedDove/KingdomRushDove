local NS = require("heroes.name_style")

return {
	name = "hero_princess",
	room = {
		available = {
			mode = "level",
			gen = "kr6",
			level = 19
		},
		stats = {5, 3, 7, 6},
		portrait_image = "hero_princess_kr6_portrait",
		thumb_image = "hero_princess_kr6_thumb",
		icon_image = "hero_princess_kr6_icon"
	},
	room_special_order = {"REGAL_FIST", "CRAMMED_PURSE", "DIAMOND_DROP", "SWIFT_DEFENSE", "REGAL_PRECISION", "CROWNING_SLASHES"},
	resources = {
		game = {
			required_textures = {"go_hero_princess"},
			plugin_required_textures = {},
			required_sounds = {"hero_princess"},
			plugin_required_sounds = {},
			required_exoskeletons = {"hero_princessDef"},
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
	templates = {"heroes.hero_princess.templates"},
	animations = {"heroes.hero_princess.animations"},
	sounds = {"heroes.hero_princess.sounds"},
	groups = {"heroes.hero_princess.groups"},
	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {232, 196, 255, 255},
		c3 = {184, 96, 224, 255},
		outline = {52, 16, 70, 255},
		outline_thickness = 2.5,
		glow = {52, 16, 70, 255},
		glow_thickness = 1
	}
}
