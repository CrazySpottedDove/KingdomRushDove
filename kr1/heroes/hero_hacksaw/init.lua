local NS = require("heroes.name_style")

return {
	name = "hero_hacksaw",
	room = {
		available = {
			mode = "level",
			gen = "kr1",
			level = 22
		},
		stats = {6, 5, 0, 2},
		portrait_image = "portrait_notxt_0010",
		thumb_image = "hero_room_thumbs_0010",
		icon_image = "mapButtons_portrait_hero_0010"
	},
	room_special_order = {"BEAR", "SAWBLADE", "TIMBER"},
	resources = {
		game = {
			required_textures = {"go_hero_hacksaw"},
			plugin_required_textures = {},
			required_sounds = {"hero_hacksaw"},
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
	templates = {"heroes.hero_hacksaw.templates"},
	animations = {"heroes.hero_hacksaw.animations"},
	sounds = {"heroes.hero_hacksaw.sounds"},
	groups = {"heroes.hero_hacksaw.groups"},

	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {205, 255, 70, 255},
		c3 = {85, 156, 11, 255},
		outline = {45, 88, 0, 255},
		outline_thickness = 1.5,
		glow = {45, 88, 0, 255},
		glow_thickness = 1
	}
}
