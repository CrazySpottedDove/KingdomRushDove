local NS = require("heroes.name_style")

return {
	name = "hero_dragon_gem",
	room = {
		available_level = 115,
		starting_level = 1,
		from_kr = 5,
		stats = {7, 6, 5, 5},
		portrait = 12,
		thumb = 12,
		icon = 12,
		portrait_image = "kr5_portrait_notxt_0012",
		thumb_image = "kr5_hero_room_thumbs_0012",
		icon_image = "kr5_mapButtons_portrait_hero_0012"
	},
	room_special_order = {"BERSERKER", "BERSERKER_2", "BERSERKER_3", "BERSERKER_4", "BERSERKER_5", "BERSERKER_6"},
	required_textures = {"go_hero_dragon_gem"},
	plugin_required_textures = {},
	required_sounds = {"hero_dragon_gem"},
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
		c1 = {255, 215, 154, 255},
		c2 = {255, 141, 98, 255},
		c3 = {175, 45, 0, 255},
		outline = {91, 24, 0, 255},
		outline_thickness = 2.5,
		glow = {91, 24, 0, 255},
		glow_thickness = 0.2
	}
}
