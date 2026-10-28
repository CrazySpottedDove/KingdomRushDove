local NS = require("heroes.name_style")

return {
	name = "hero_beresad",
	room = {
		available_level = 1,
		starting_level = 1,
		from_kr = 4,
		stats = {9, 0, 9, 5},
		portrait = 8,
		thumb = 8,
		icon = 8,
		portrait_image = "kr4_portrait_notxt_0008",
		thumb_image = "kr4_hero_room_thumbs_0008",
		icon_image = "kr4_mapButtons_portrait_hero_0008"
	},
	room_special_order = {"ULTIMATE", "CONFLAGRATION", "FEAR_DRAGON", "DRAGON_SPAWN", "REMOVE_EXISTENCE", "ULTIMATE_2"},
	required_textures = {"go_hero_beresad"},
	plugin_required_textures = {},
	required_sounds = {"hero_beresad"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_beresad.templates"},
	animations = {"heroes.hero_beresad.animations"},
	sounds = {"heroes.hero_beresad.sounds"},
	groups = {"heroes.hero_beresad.groups"},

	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 102, 51, 255},
		c2 = {0, 178, 89, 255},
		c3 = {0, 51, 26, 255},
		outline = {0, 26, 13, 255},
		outline_thickness = 2.5,
		glow = {0, 26, 13, 255},
		glow_thickness = 1
	}
}
