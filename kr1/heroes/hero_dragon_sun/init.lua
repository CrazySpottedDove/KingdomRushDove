local NS = require("heroes.name_style")

return {
	name = "hero_dragon_sun",
	room = {
		available_level = 116,
		starting_level = 1,
		from_kr = 5,
		stats = {9, 0, 9, 5},
		portrait = 19,
		thumb = 19,
		icon = 19,
		portrait_image = "kr5_portrait_notxt_0019",
		thumb_image = "kr5_hero_room_thumbs_0019",
		icon_image = "kr5_mapButtons_portrait_hero_0019"
	},
	room_special_order = {"WORTHY_FOE", "SOLAR_CLEANSING", "OVERCHARGE", "SOLAR_STONES", "ULTIMATE"},
	required_textures = {"go_hero_dragon_sun"},
	plugin_required_textures = {},
	required_sounds = {"hero_dragon_sun"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_dragon_sun.templates"},
	animations = {"heroes.hero_dragon_sun.animations"},
	sounds = {"heroes.hero_dragon_sun.sounds"},
	groups = {"heroes.hero_dragon_sun.groups"},

	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {255, 137, 33, 255},
		c3 = {176, 80, 22, 255},
		outline = {127, 42, 11, 255},
		outline_thickness = 2.5,
		glow = {127, 42, 11, 255},
		glow_thickness = 1
	}
}
