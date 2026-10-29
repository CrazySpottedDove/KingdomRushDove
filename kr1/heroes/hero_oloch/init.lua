local NS = require("heroes.name_style")

return {
	name = "hero_oloch",
	room = {
		available_level = 1,
		stats = {9, 0, 9, 5},
		portrait_image = "kr4_portrait_notxt_0003",
		thumb_image = "kr4_hero_room_thumbs_0003",
		icon_image = "kr4_mapButtons_portrait_hero_0003"
	},
	room_special_order = {"DUPLICATION", "MAGMA_ERUPTION", "HELLISH_INFUSION", "DEMONIC_BLAST", "ULTIMATE", "ULTIMATE_2"},
	required_textures = {"go_hero_oloch"},
	plugin_required_textures = {},
	required_sounds = {"hero_oloch"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_oloch.templates"},
	animations = {"heroes.hero_oloch.animations"},
	sounds = {"heroes.hero_oloch.sounds"},
	groups = {"heroes.hero_oloch.groups"},

	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {255, 94, 71, 255},
		c3 = {230, 66, 38, 255},
		outline = {193, 38, 5, 255},
		outline_thickness = 2.5,
		glow = {193, 38, 5, 255},
		glow_thickness = 1
	}
}
