local NS = require("heroes.name_style")

return {
	name = "hero_monk",
	room = {
		available_level = 36,
		starting_level = 1,
		from_kr = 2,
		stats = {6, 5, 0, 6},
		portrait = 12,
		thumb = 12,
		icon = 12,
		portrait_image = "kr2_portrait_notxt_0012",
		thumb_image = "kr2_hero_room_thumbs_0012",
		icon_image = "kr2_mapButtons_portrait_hero_0012"
	},
	required_textures = {"go_hero_monk"},
	plugin_required_textures = {},
	required_sounds = {"hero_monk"},
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
		c1 = {251, 255, 184, 0},
		c2 = {255, 214, 28, 255},
		c3 = {255, 126, 0, 255},
		outline = {98, 47, 0, 255},
		outline_thickness = 4.5,
		glow = {98, 47, 0, 255},
		glow_thickness = 1.5
	}
}
