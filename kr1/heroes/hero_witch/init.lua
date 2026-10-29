local NS = require("heroes.name_style")

return {
	name = "hero_witch",
	room = {
		available_level = 116,
		starting_level = 1,
		from_kr = 5,
		stats = {5, 4, 5, 7},
		portrait_image = "kr5_portrait_notxt_0013",
		thumb_image = "kr5_hero_room_thumbs_0013",
		icon_image = "kr5_mapButtons_portrait_hero_0013"
	},
	room_special_order = {"BERSERKER", "BERSERKER_2", "BERSERKER_3", "BERSERKER_4", "BERSERKER_5"},
	required_textures = {"go_hero_witch"},
	plugin_required_textures = {},
	required_sounds = {"hero_witch"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_witch.templates"},
	animations = {"heroes.hero_witch.animations"},
	sounds = {"heroes.hero_witch.sounds"},
	groups = {"heroes.hero_witch.groups"},

	name_style = {
		margin = 1,
		p1 = NS.p21,
		p2 = NS.p22,
		c1 = {255, 204, 241, 255},
		c2 = {255, 132, 186, 255},
		c3 = {206, 0, 119, 255},
		outline = {140, 0, 81, 255},
		outline_thickness = 1.5,
		glow = {140, 0, 81, 255},
		glow_thickness = 0.2,
		single_line = true
	}
}
