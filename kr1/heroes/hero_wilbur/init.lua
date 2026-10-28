local NS = require("heroes.name_style")

return {
	name = "hero_wilbur",
	room = {
		available_level = 69,
		starting_level = 5,
		from_kr = 3,
		stats = {6, 7, 5, 5},
		portrait = 15,
		thumb = 15,
		icon = 15,
		portrait_image = "kr3_portrait_notxt_0015",
		thumb_image = "kr3_hero_room_thumbs_0015",
		icon_image = "kr3_mapButtons_portrait_hero_0015"
	},
	required_textures = {"go_hero_wilbur"},
	plugin_required_textures = {},
	required_sounds = {"hero_wilbur"},
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
		c1 = {255, 255, 203, 255},
		c2 = {255, 254, 84, 255},
		c3 = {237, 132, 50, 255},
		outline = {67, 20, 5, 255},
		outline_thickness = 3,
		glow = {67, 20, 5, 255},
		glow_thickness = 0.4
	}
}
