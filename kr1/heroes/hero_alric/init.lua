local NS = require("heroes.name_style")

return {
	name = "hero_alric",
	room = {
		available_level = 27,
		starting_level = 1,
		from_kr = 2,
		stats = {6, 5, 0, 4},
		portrait_image = "kr2_portrait_notxt_0001",
		thumb_image = "kr2_hero_room_thumbs_0001",
		icon_image = "kr2_mapButtons_portrait_hero_0001"
	},
	room_special_order = {"FLURRY", "SANDWARRIORS", "SANDWARRIORS_2", "SPIKEDARMOR"},
	required_textures = {"go_hero_alric"},
	plugin_required_textures = {},
	required_sounds = {"hero_alric"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_alric.templates"},
	animations = {"heroes.hero_alric.animations"},
	sounds = {"heroes.hero_alric.sounds"},
	groups = {"heroes.hero_alric.groups"},
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
