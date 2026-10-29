local NS = require("heroes.name_style")

return {
	name = "hero_mirage",
	room = {
		available_level = 30,
		starting_level = 1,
		from_kr = 2,
		stats = {4, 3, 5, 7},
		portrait_image = "kr2_portrait_notxt_0002",
		thumb_image = "kr2_hero_room_thumbs_0002",
		icon_image = "kr2_mapButtons_portrait_hero_0002"
	},
	room_special_order = {"SHADOWDODGE", "SHADOWDANCE", "LETHALSTRIKE"},
	required_textures = {"go_hero_mirage"},
	plugin_required_textures = {},
	required_sounds = {"hero_mirage"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_mirage.templates"},
	animations = {"heroes.hero_mirage.animations"},
	sounds = {"heroes.hero_mirage.sounds"},
	groups = {"heroes.hero_mirage.groups"},
	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 0},
		c2 = {255, 177, 252, 255},
		c3 = {140, 46, 212, 255},
		outline = {77, 0, 75, 255},
		outline_thickness = 4.5,
		glow = {77, 0, 75, 255},
		glow_thickness = 1.5
	}
}
