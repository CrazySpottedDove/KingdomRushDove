local NS = require("heroes.name_style")

return {
	name = "hero_thor",
	room = {
		available_level = 10,
		stats = {7, 5, 0, 6},
		portrait_image = "portrait_notxt_0012",
		thumb_image = "hero_room_thumbs_0012",
		icon_image = "mapButtons_portrait_hero_0012"
	},
	room_special_order = {"THUNDERCLAP", "CHAINLIGHTNING", "CHAINLIGHTNING_2"},
	required_textures = {"go_hero_thor"},
	plugin_required_textures = {},
	required_sounds = {"hero_thor"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_thor.templates"},
	animations = {"heroes.hero_thor.animations"},
	sounds = {"heroes.hero_thor.sounds"},
	groups = {"heroes.hero_thor.groups"},

	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {222, 248, 255, 255},
		c3 = {34, 185, 210, 255},
		outline = {0, 69, 93, 255},
		outline_thickness = 2,
		glow = {0, 69, 93, 255},
		glow_thickness = 1.5
	}
}
