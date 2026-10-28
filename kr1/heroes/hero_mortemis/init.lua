local NS = require("heroes.name_style")

return {
	name = "hero_mortemis",
	room = {
		available_level = 1,
		starting_level = 1,
		from_kr = 4,
		stats = {6, 8, 9, 3},
		portrait = 5,
		thumb = 5,
		icon = 5,
		portrait_image = "kr4_portrait_notxt_0005",
		thumb_image = "kr4_hero_room_thumbs_0005",
		icon_image = "kr4_mapButtons_portrait_hero_0005"
	},
	room_special_order = {"ULTIMATE", "CALL_HAUNTED", "DEADLY_FUMES", "GRIM_PRESENCE", "UNDEAD_SERVITUDE", "ULTIMATE_2", "UNDEAD_SERVITUDE_2"},
	required_textures = {"go_hero_mortemis"},
	plugin_required_textures = {},
	required_sounds = {"hero_mortemis"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_mortemis.templates"},
	animations = {"heroes.hero_mortemis.animations"},
	sounds = {"heroes.hero_mortemis.sounds"},
	groups = {"heroes.hero_mortemis.groups"},

	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {110, 217, 100, 255},
		c3 = {44, 162, 77, 255},
		outline = {0, 106, 54, 255},
		outline_thickness = 2.5,
		glow = {0, 106, 54, 255},
		glow_thickness = 1
	}
}
