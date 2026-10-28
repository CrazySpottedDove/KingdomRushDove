local NS = require("heroes.name_style")

return {
	name = "hero_space_elf",
	room = {
		available_level = 111,
		starting_level = 1,
		from_kr = 5,
		stats = {4, 4, 6, 8},
		portrait = 7,
		thumb = 7,
		icon = 7,
		portrait_image = "kr5_portrait_notxt_0007",
		thumb_image = "kr5_hero_room_thumbs_0007",
		icon_image = "kr5_mapButtons_portrait_hero_0007"
	},
	room_special_order = {"BERSERKER", "BERSERKER_2", "BERSERKER_3", "BERSERKER_4", "BERSERKER_5"},
	required_textures = {"go_hero_space_elf"},
	plugin_required_textures = {},
	required_sounds = {"hero_space_elf"},
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
		c1 = {230, 216, 247, 255},
		c2 = {176, 148, 248, 255},
		c3 = {94, 78, 204, 255},
		outline = {51, 22, 127, 255},
		outline_thickness = 2.5,
		glow = {51, 22, 127, 255},
		glow_thickness = 0.2
	}
}
