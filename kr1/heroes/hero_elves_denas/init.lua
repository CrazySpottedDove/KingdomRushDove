local NS = require("heroes.name_style")

return {
	name = "hero_elves_denas",
	room = {
		available_level = 54,
		starting_level = 5,
		from_kr = 3,
		stats = {7, 4, 0, 4},
		portrait = 5,
		thumb = 5,
		icon = 5,
		portrait_image = "kr3_portrait_notxt_0005",
		thumb_image = "kr3_hero_room_thumbs_0005",
		icon_image = "kr3_mapButtons_portrait_hero_0005"
	},
	required_textures = {"go_hero_elves_denas"},
	plugin_required_textures = {},
	required_sounds = {"hero_elves_denas"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},

	name_style = {
		margin = 1,
		p1 = NS.p21,
		p2 = NS.p22,
		c1 = {255, 252, 222, 255},
		c2 = {250, 224, 76, 255},
		c3 = {209, 138, 48, 255},
		outline = {107, 65, 0, 255},
		outline_thickness = 2,
		glow = {107, 65, 0, 255},
		glow_thickness = 0.2
	}
}
