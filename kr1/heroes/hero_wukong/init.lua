local NS = require("heroes.name_style")

return {
	name = "hero_wukong",
	room = {
		available_level = 116,
		starting_level = 1,
		from_kr = 5,
		stats = {5, 7, 4, 5},
		portrait = 18,
		thumb = 18,
		icon = 18,
		portrait_image = "kr5_portrait_notxt_0018",
		thumb_image = "kr5_hero_room_thumbs_0018",
		icon_image = "kr5_mapButtons_portrait_hero_0018"
	},
	room_special_order = {"BERSERKER", "BERSERKER_2", "BERSERKER_3", "BERSERKER_4", "BERSERKER_5"},
	required_textures = {"go_hero_wukong"},
	plugin_required_textures = {},
	required_sounds = {"hero_wukong"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_wukong.templates"},
	animations = {"heroes.hero_wukong.animations"},
	sounds = {"heroes.hero_wukong.sounds"},
	groups = {"heroes.hero_wukong.groups"},

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
