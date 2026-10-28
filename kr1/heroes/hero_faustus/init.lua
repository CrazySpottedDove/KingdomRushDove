local NS = require("heroes.name_style")

return {
	name = "hero_faustus",
	room = {
		available_level = 62,
		starting_level = 5,
		from_kr = 3,
		stats = {6, 6, 6, 6},
		portrait = 16,
		thumb = 16,
		icon = 16,
		portrait_image = "kr3_portrait_notxt_0016",
		thumb_image = "kr3_hero_room_thumbs_0016",
		icon_image = "kr3_mapButtons_portrait_hero_0016"
	},
	room_special_order = {"TELEPORT_RUNE", "ULTIMATE", "DRAGON_LANCE", "LIQUID_FIRE", "ENERVATION", "URINATION"},
	required_textures = {"go_hero_faustus"},
	plugin_required_textures = {},
	required_sounds = {"hero_faustus"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_faustus.templates"},
	animations = {"heroes.hero_faustus.animations"},
	sounds = {"heroes.hero_faustus.sounds"},
	groups = {"heroes.hero_faustus.groups"},

	name_style = {
		margin = 1,
		p1 = NS.p21,
		p2 = NS.p22,
		c1 = {206, 204, 249, 255},
		c2 = {169, 135, 245, 255},
		c3 = {96, 68, 153, 255},
		outline = {56, 38, 80, 255},
		outline_thickness = 2,
		glow = {56, 38, 80, 255},
		glow_thickness = 0.2
	}
}
