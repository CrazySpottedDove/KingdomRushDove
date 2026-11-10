local NS = require("heroes.name_style")

return {
	name = "hero_elves_archer",
	room = {
		available = {
			mode = "level",
			gen = "kr3",
			level = 1
		},
		stats = {6, 5, 6, 6},
		portrait_image = "kr3_portrait_notxt_0001",
		thumb_image = "kr3_hero_room_thumbs_0001",
		icon_image = "kr3_mapButtons_portrait_hero_0001"
	},
	room_special_order = {"NIMBLE_FENCER", "DOUBLE_STRIKE", "PORCUPINE", "MULTISHOT", "ULTIMATE", "GUARDS"},
	resources = {
		game = {
			required_textures = {"go_hero_elves_archer"},
			plugin_required_textures = {},
			required_sounds = {"hero_elves_archer"},
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
	templates = {"heroes.hero_elves_archer.templates"},
	animations = {"heroes.hero_elves_archer.animations"},
	sounds = {"heroes.hero_elves_archer.sounds"},
	groups = {"heroes.hero_elves_archer.groups"},

	name_style = {
		margin = 2.5,
		p1 = NS.p21,
		p2 = NS.p22,
		c1 = {253, 255, 222, 255},
		c2 = {221, 236, 110, 255},
		c3 = {124, 156, 43, 255},
		outline = {32, 41, 8, 255},
		outline_thickness = 2.5,
		glow = {32, 41, 8, 255},
		glow_thickness = 0.2
	}
}
