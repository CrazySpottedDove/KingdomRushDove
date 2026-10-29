local NS = require("heroes.name_style")

return {
	name = "hero_gerald",
	room = {
		available_level = 6,
		starting_level = 1,
		stats = {6, 5, 0, 4},
		portrait_image = "portrait_notxt_0001",
		thumb_image = "hero_room_thumbs_0001",
		icon_image = "mapButtons_portrait_hero_0001"
	},
	room_special_order = {"BLOCK_COUNTER", "HOLY_STRIKE", "COURAGE", "PALADIN"},
	required_textures = {"go_hero_gerald"},
	plugin_required_textures = {},
	required_sounds = {"hero_gerald"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_gerald.templates"},
	animations = {"heroes.hero_gerald.animations"},
	sounds = {"heroes.hero_gerald.sounds"},
	groups = {"heroes.hero_gerald.groups"},
	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {182, 232, 255, 255},
		c3 = {65, 178, 229, 255},
		outline = {0, 69, 100, 255},
		outline_thickness = 2.5,
		glow = {0, 69, 100, 255},
		glow_thickness = 1
	}
}
