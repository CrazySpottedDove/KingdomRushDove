local NS = require("heroes.name_style")

return {
	name = "hero_10yr",
	room = {
		available_level = 16,
		stats = {6, 5, 0, 8},
		portrait_image = "portrait_notxt_0013",
		thumb_image = "hero_room_thumbs_0013",
		icon_image = "mapButtons_portrait_hero_0013"
	},
	room_special_order = {"BUFFED", "BUFFED_2", "RAIN"},
	required_textures = {"go_hero_10yr"},
	plugin_required_textures = {},
	required_sounds = {"hero_10yr"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_10yr.templates"},
	animations = {"heroes.hero_10yr.animations"},
	sounds = {"heroes.hero_10yr.sounds"},
	groups = {"heroes.hero_10yr.groups"},

	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {255, 242, 63, 255},
		c3 = {255, 126, 0, 255},
		outline = {105, 40, 0, 255},
		outline_thickness = 2.5,
		glow = {105, 40, 0, 255},
		glow_thickness = 1
	}
}
