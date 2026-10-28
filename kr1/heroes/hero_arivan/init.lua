local NS = require("heroes.name_style")

return {
	name = "hero_arivan",
	room = {
		available_level = 51,
		starting_level = 3,
		from_kr = 3,
		stats = {5, 6, 6, 6},
		portrait = 2,
		thumb = 2,
		icon = 2,
		portrait_image = "kr3_portrait_notxt_0002",
		thumb_image = "kr3_hero_room_thumbs_0002",
		icon_image = "kr3_mapButtons_portrait_hero_0002"
	},
	room_special_order = {"LIGHTNING_ROD", "STONE_DANCE", "SEAL_OF_FIRE", "ICY_PRISON", "ULTIMATE"},
	required_textures = {"go_hero_arivan"},
	plugin_required_textures = {},
	required_sounds = {"hero_arivan"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_arivan.templates"},
	animations = {"heroes.hero_arivan.animations"},
	sounds = {"heroes.hero_arivan.sounds"},
	groups = {"heroes.hero_arivan.groups"},

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
