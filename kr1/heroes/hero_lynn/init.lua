local NS = require("heroes.name_style")

return {
	name = "hero_lynn",
	room = {
		available_level = 67,
		starting_level = 5,
		from_kr = 3,
		stats = {6, 6, 0, 5},
		portrait = 12,
		thumb = 12,
		icon = 12,
		portrait_image = "kr3_portrait_notxt_0012",
		thumb_image = "kr3_hero_room_thumbs_0012",
		icon_image = "kr3_mapButtons_portrait_hero_0012"
	},
	required_textures = {"go_hero_lynn"},
	plugin_required_textures = {},
	required_sounds = {"hero_lynn"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},

	name_style = {
		margin = 2.5,
		p1 = 0.5,
		p2 = 0.5,
		c1 = {252, 239, 254, 255},
		c2 = {229, 118, 246, 255},
		c3 = {252, 239, 254, 255},
		outline = {104, 21, 127, 255},
		outline_thickness = 3,
		glow = {150, 135, 190, 155},
		glow_thickness = 2
	}
}
