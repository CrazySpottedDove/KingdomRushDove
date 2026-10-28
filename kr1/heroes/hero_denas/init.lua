local NS = require("heroes.name_style")

return {
	name = "hero_denas",
	room = {
		available_level = 12,
		starting_level = 1,
		stats = {5, 5, 8, 3},
		portrait = 7,
		thumb = 7,
		icon = 7,
		portrait_image = "portrait_notxt_0007",
		thumb_image = "hero_room_thumbs_0007",
		icon_image = "mapButtons_portrait_hero_0007"
	},
	room_special_order = {"TOWER_BUFF", "CATAPULT", "CATAPULT_2"},
	required_textures = {"go_hero_denas"},
	plugin_required_textures = {},
	required_sounds = {"hero_denas"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},

	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {255, 252, 219, 255},
		c3 = {255, 224, 0, 255},
		outline = {107, 65, 0, 255},
		outline_thickness = 2,
		glow = {107, 65, 0, 255},
		glow_thickness = 1
	}
}
