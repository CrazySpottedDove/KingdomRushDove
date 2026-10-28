local NS = require("heroes.name_style")

return {
	name = "hero_monkey_god",
	room = {
		available_level = 37,
		starting_level = 5,
		from_kr = 2,
		stats = {5, 5, 0, 7},
		portrait = 16,
		thumb = 16,
		icon = 16,
		portrait_image = "kr2_portrait_notxt_0016",
		thumb_image = "kr2_hero_room_thumbs_0016",
		icon_image = "kr2_mapButtons_portrait_hero_0016"
	},
	room_special_order = {"SPINNINGPOLE", "TETSUBOSTORM", "MONKEYPALM", "ANGRYGOD", "ANGRYGOD_2"},
	required_textures = {"go_hero_monkey_god"},
	plugin_required_textures = {},
	required_sounds = {"hero_monkey_god"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},

	name_style = {
		margin = 2,
		p1 = NS.p21,
		p2 = NS.p22,
		c1 = {255, 255, 255, 0},
		c2 = {212, 255, 133, 255},
		c3 = {109, 212, 3, 255},
		outline = {49, 107, 6, 255},
		outline_thickness = 4.5,
		glow = {49, 107, 6, 255},
		glow_thickness = 1.5
	}
}
