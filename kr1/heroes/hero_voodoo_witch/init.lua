local NS = require("heroes.name_style")

return {
	name = "hero_voodoo_witch",
	room = {
		available_level = 34,
		starting_level = 4,
		stats = {6, 5, 6, 5},
		portrait_image = "kr2_portrait_notxt_0005",
		thumb_image = "kr2_hero_room_thumbs_0005",
		icon_image = "kr2_mapButtons_portrait_hero_0005"
	},
	room_special_order = {"LAUGHINGSKULLS", "DEATHSKULL", "BONEDANCE", "DEATHAURA", "VOODOOMAGIC"},
	required_textures = {"go_hero_voodoo_witch"},
	plugin_required_textures = {},
	required_sounds = {"hero_voodoo_witch"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_voodoo_witch.templates"},
	animations = {"heroes.hero_voodoo_witch.animations"},
	sounds = {"heroes.hero_voodoo_witch.sounds"},
	groups = {"heroes.hero_voodoo_witch.groups"},
	name_style = {
		margin = 2,
		p1 = NS.p21,
		p2 = NS.p22,
		c1 = {231, 192, 255, 0},
		c2 = {209, 136, 255, 255},
		c3 = {128, 68, 190, 255},
		outline = {61, 27, 86, 255},
		outline_thickness = 4.5,
		glow = {61, 27, 86, 255},
		glow_thickness = 1.5
	}
}
