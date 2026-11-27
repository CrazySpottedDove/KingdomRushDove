local NS = require("heroes.name_style")

return {
	name = "hero_jack_o_lantern",
	room = {
		available = {
			mode = "level",
			gen = "kr1",
			level = 1
		},
		stats = {8, 6, 0, 5},
		portrait_image = "kr4_portrait_notxt_0014",
		thumb_image = "kr4_hero_room_thumbs_0014",
		icon_image = "kr4_mapButtons_portrait_hero_0014"
	},
	room_special_order = {"PASSIVE", "EXPLOSIVE_HEAD", "HAUNTED_BLADE", "HERO_JACKO_MELEE", "HERO_JACKO_THRILLER", "ULTIMATE"},
	resources = {
		game = {
			required_textures = {"go_hero_jack_o_lantern"},
			plugin_required_textures = {},
			required_sounds = {"hero_jack_o_lantern"},
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
	templates = {"heroes.hero_jack_o_lantern.templates"},
	animations = {"heroes.hero_jack_o_lantern.animations"},
	sounds = {"heroes.hero_jack_o_lantern.sounds"},
	groups = {"heroes.hero_jack_o_lantern.groups"},
	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {128, 64, 32, 255},
		c2 = {224, 128, 48, 255},
		c3 = {64, 24, 8, 255},
		outline = {48, 16, 8, 255},
		outline_thickness = 2.5,
		glow = {96, 32, 8, 255},
		glow_thickness = 1
	}
}
