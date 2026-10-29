local NS = require("heroes.name_style")

return {
	name = "hero_van_helsing",
	room = {
		available_level = 45,
		stats = {6, 7, 5, 6},
		portrait_image = "kr2_portrait_notxt_0013",
		thumb_image = "kr2_hero_room_thumbs_0013",
		icon_image = "kr2_mapButtons_portrait_hero_0013"
	},
	room_special_order = {"SILVERBULLET", "MULTISHOOT", "RELICOFPOWER", "HOLYGRENADE", "BEACONOFLIGHT"},
	required_textures = {"go_hero_van_helsing"},
	plugin_required_textures = {},
	required_sounds = {"hero_van_helsing"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_van_helsing.templates"},
	animations = {"heroes.hero_van_helsing.animations"},
	sounds = {"heroes.hero_van_helsing.sounds"},
	groups = {"heroes.hero_van_helsing.groups"},
	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 0},
		c2 = {255, 179, 175, 255},
		c3 = {212, 68, 83, 255},
		outline = {100, 0, 16, 255},
		outline_thickness = 4.5,
		glow = {100, 0, 16, 255},
		glow_thickness = 1.5
	}
}
