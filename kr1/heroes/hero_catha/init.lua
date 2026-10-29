local NS = require("heroes.name_style")

return {
	name = "hero_catha",
	room = {
		available_level = 58,
		stats = {5, 3, 6, 6},
		portrait_image = "kr3_portrait_notxt_0003",
		thumb_image = "kr3_hero_room_thumbs_0003",
		icon_image = "kr3_mapButtons_portrait_hero_0003"
	},
	room_special_order = {"ULTIMATE", "CURSE", "SOUL", "TALE", "FURY"},
	required_textures = {"go_hero_catha"},
	plugin_required_textures = {},
	required_sounds = {"hero_catha"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_catha.templates"},
	animations = {"heroes.hero_catha.animations"},
	sounds = {"heroes.hero_catha.sounds"},
	groups = {"heroes.hero_catha.groups"},

	name_style = {
		margin = 1.5,
		p1 = NS.p21,
		p2 = NS.p22,
		c1 = {253, 243, 212, 255},
		c2 = {245, 242, 128, 255},
		c3 = {213, 119, 44, 255},
		outline = {89, 29, 0, 255},
		outline_thickness = 2.5,
		glow = {89, 29, 0, 255},
		glow_thickness = 0.2
	}
}
