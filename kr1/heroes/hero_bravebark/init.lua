local NS = require("heroes.name_style")

return {
	name = "hero_bravebark",
	room = {
		available_level = 52,
		starting_level = 5,
		stats = {6, 5, 0, 7},
		portrait_image = "kr3_portrait_notxt_0007",
		thumb_image = "kr3_hero_room_thumbs_0007",
		icon_image = "kr3_mapButtons_portrait_hero_0007"
	},
	room_special_order = {"ULTIMATE", "SPRINGSAP", "OAKSEEDS", "ROOTSPIKES", "BRANCHBALL"},
	required_textures = {"go_hero_bravebark"},
	plugin_required_textures = {},
	required_sounds = {"hero_bravebark"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_bravebark.templates"},
	animations = {"heroes.hero_bravebark.animations"},
	sounds = {"heroes.hero_bravebark.sounds"},
	groups = {"heroes.hero_bravebark.groups"},

	name_style = {
		margin = 1,
		p1 = NS.p21,
		p2 = NS.p22,
		c1 = {255, 249, 180, 255},
		c2 = {202, 216, 78, 255},
		c3 = {114, 113, 34, 255},
		outline = {60, 56, 0, 255},
		outline_thickness = 2,
		glow = {60, 56, 0, 255},
		glow_thickness = 0.2
	}
}
