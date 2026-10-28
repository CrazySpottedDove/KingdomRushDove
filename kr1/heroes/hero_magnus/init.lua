local NS = require("heroes.name_style")

return {
	name = "hero_magnus",
	room = {
		available_level = 6,
		starting_level = 1,
		stats = {3, 2, 7, 8},
		portrait = 5,
		thumb = 5,
		icon = 5,
		portrait_image = "portrait_notxt_0005",
		thumb_image = "hero_room_thumbs_0005",
		icon_image = "mapButtons_portrait_hero_0005"
	},
	room_special_order = {"MIRAGE", "MIRAGE_2", "ARCANE_RAIN"},
	required_textures = {"go_hero_magnus"},
	plugin_required_textures = {},
	required_sounds = {"hero_magnus"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_magnus.templates"},
	animations = {"heroes.hero_magnus.animations"},
	sounds = {"heroes.hero_magnus.sounds"},
	groups = {"heroes.hero_magnus.groups"},
	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {255, 222, 254, 255},
		c3 = {200, 86, 255, 255},
		outline = {69, 0, 112, 255},
		outline_thickness = 2.5,
		glow = {69, 0, 112, 255},
		glow_thickness = 1
	}
}
