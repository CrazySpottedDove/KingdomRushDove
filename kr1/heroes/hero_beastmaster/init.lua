local NS = require("heroes.name_style")

return {
	name = "hero_beastmaster",
	room = {
		available = {
			mode = "level",
			gen = "kr2",
			level = 7
		},
		stats = {7, 5, 0, 3},
		portrait_image = "kr2_portrait_notxt_0004",
		thumb_image = "kr2_hero_room_thumbs_0004",
		icon_image = "kr2_mapButtons_portrait_hero_0004"
	},
	room_special_order = {"BOARMASTER", "FALCONER", "STAMPEDE", "DEEPLASHES", "DEEPLASHES_2"},
	resources = {
		game = {
			required_textures = {"go_hero_beastmaster"},
			plugin_required_textures = {},
			required_sounds = {"hero_beastmaster"},
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
	templates = {"heroes.hero_beastmaster.templates"},
	animations = {"heroes.hero_beastmaster.animations"},
	sounds = {"heroes.hero_beastmaster.sounds"},
	groups = {"heroes.hero_beastmaster.groups"},
	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 0},
		c2 = {228, 255, 95, 255},
		c3 = {107, 189, 0, 255},
		outline = {32, 58, 0, 255},
		outline_thickness = 4.5,
		glow = {32, 58, 0, 255},
		glow_thickness = 1.5
	}
}
