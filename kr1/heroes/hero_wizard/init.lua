local NS = require("heroes.name_style")

return {
	name = "hero_wizard",
	room = {
		available_level = 32,
		stats = {3, 2, 6, 8},
		portrait_image = "kr2_portrait_notxt_0006",
		thumb_image = "kr2_hero_room_thumbs_0006",
		icon_image = "kr2_mapButtons_portrait_hero_0006"
	},
	room_special_order = {"MAGICMISSILE", "CHAINSPELL", "DISINTEGRATE", "ARCANETORRENT"},
	required_textures = {"go_hero_wizard"},
	plugin_required_textures = {},
	required_sounds = {"hero_wizard"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_wizard.templates"},
	animations = {"heroes.hero_wizard.animations"},
	sounds = {"heroes.hero_wizard.sounds"},
	groups = {"heroes.hero_wizard.groups"},
	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 0},
		c2 = {255, 246, 83, 255},
		c3 = {255, 129, 5, 255},
		outline = {79, 44, 26, 255},
		outline_thickness = 4.5,
		glow = {79, 44, 26, 255},
		glow_thickness = 1.5
	}
}
