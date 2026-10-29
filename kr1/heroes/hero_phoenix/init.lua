local NS = require("heroes.name_style")

return {
	name = "hero_phoenix",
	room = {
		available_level = 61,
		starting_level = 5,
		from_kr = 3,
		stats = {5, 6, 0, 6},
		portrait_image = "kr3_portrait_notxt_0010",
		thumb_image = "kr3_hero_room_thumbs_0010",
		icon_image = "kr3_mapButtons_portrait_hero_0010"
	},
	room_special_order = {"PURIFICATION", "INMOLATE", "BLAZING_OFFSPRING", "FLAMING_PATH", "ULTIMATE"},
	required_textures = {"go_hero_phoenix"},
	plugin_required_textures = {},
	required_sounds = {"hero_phoenix"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_phoenix.templates"},
	animations = {"heroes.hero_phoenix.animations"},
	sounds = {"heroes.hero_phoenix.sounds"},
	groups = {"heroes.hero_phoenix.groups"},

	name_style = {
		margin = 2.5,
		p1 = 0.5,
		p2 = 0.5,
		c1 = {255, 255, 218, 255},
		c2 = {255, 254, 104, 255},
		c3 = {255, 255, 218, 255},
		outline = {236, 121, 48, 255},
		outline_thickness = 2,
		glow = {112, 42, 15, 200},
		glow_thickness = 3
	}
}
