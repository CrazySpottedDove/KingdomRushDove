local NS = require("heroes.name_style")

return {
	name = "hero_asra",
	room = {
		available_level = 1,
		starting_level = 1,
		from_kr = 4,
		stats = {8, 3, 4, 7},
		portrait = 2,
		thumb = 2,
		icon = 2,
		portrait_image = "kr4_portrait_notxt_0002",
		thumb_image = "kr4_hero_room_thumbs_0002",
		icon_image = "kr4_mapButtons_portrait_hero_0002"
	},
	room_special_order = {"ULTIMATE", "SPIDER_BITE", "ONIX_ARROWS", "QUIVER_OF_SORROW", "SHIELD_OF_SHADOWS", "ULTIMATE_2"},
	required_textures = {"go_hero_asra"},
	plugin_required_textures = {},
	required_sounds = {"hero_asra"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_asra.templates"},
	animations = {"heroes.hero_asra.animations"},
	sounds = {"heroes.hero_asra.sounds"},
	groups = {"heroes.hero_asra.groups"},

	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {153, 50, 204, 255},
		c2 = {204, 50, 255, 255},
		c3 = {102, 50, 128, 255},
		outline = {60, 20, 80, 255},
		outline_thickness = 2.5,
		glow = {60, 20, 80, 255},
		glow_thickness = 1
	}
}
