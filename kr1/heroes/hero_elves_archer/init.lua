local NS = require("heroes.name_style")

return {
	name = "hero_elves_archer",
	room = {
		available_level = 49,
		starting_level = 1,
		from_kr = 3,
		stats = {6, 5, 6, 6},
		portrait = 1,
		thumb = 1,
		icon = 1,
		portrait_image = "kr3_portrait_notxt_0001",
		thumb_image = "kr3_hero_room_thumbs_0001",
		icon_image = "kr3_mapButtons_portrait_hero_0001"
	},
	room_special_order = {"NIMBLE_FENCER", "DOUBLE_STRIKE", "PORCUPINE", "MULTISHOT", "ULTIMATE", "GUARDS"},
	required_textures = {"go_hero_elves_archer"},
	plugin_required_textures = {},
	required_sounds = {"hero_elves_archer"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_elves_archer.templates"},
	animations = {"heroes.hero_elves_archer.animations"},
	sounds = {"heroes.hero_elves_archer.sounds"},
	groups = {"heroes.hero_elves_archer.groups"},

	name_style = {
		margin = 2.5,
		p1 = NS.p21,
		p2 = NS.p22,
		c1 = {253, 255, 222, 255},
		c2 = {221, 236, 110, 255},
		c3 = {124, 156, 43, 255},
		outline = {32, 41, 8, 255},
		outline_thickness = 2.5,
		glow = {32, 41, 8, 255},
		glow_thickness = 0.2
	}
}
