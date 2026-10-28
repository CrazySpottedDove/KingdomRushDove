local NS = require("heroes.name_style")

return {
	name = "hero_orc",
	room = {
		available_level = 1,
		starting_level = 1,
		from_kr = 4,
		stats = {9, 0, 9, 5},
		portrait = 1,
		thumb = 1,
		icon = 1,
		portrait_image = "kr4_portrait_notxt_0001",
		thumb_image = "kr4_hero_room_thumbs_0001",
		icon_image = "kr4_mapButtons_portrait_hero_0001"
	},
	room_special_order = {"DUELIST", "BRUTE_FORCE", "INSPIRING_LEADER", "ULTIMATE", "ULTIMATE_2", "AIMED_SLASH"},
	required_textures = {"go_hero_orc"},
	plugin_required_textures = {},
	required_sounds = {"hero_orc"},
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
		c2 = {165, 212, 58, 255},
		c3 = {130, 172, 30, 255},
		outline = {95, 132, 1, 255},
		outline_thickness = 2.5,
		glow = {95, 132, 1, 255},
		glow_thickness = 1
	}
}
