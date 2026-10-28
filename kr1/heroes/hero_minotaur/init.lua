local NS = require("heroes.name_style")

return {
	name = "hero_minotaur",
	room = {
		available_level = 41,
		starting_level = 5,
		from_kr = 2,
		stats = {5, 5, 0, 5},
		portrait = 15,
		thumb = 15,
		icon = 15,
		portrait_image = "kr2_portrait_notxt_0015",
		thumb_image = "kr2_hero_room_thumbs_0015",
		icon_image = "kr2_mapButtons_portrait_hero_0015"
	},
	room_special_order = {"BULLRUSH", "BLOODAXE", "DAEDALUSMAZE", "ROAROFFURY", "DOOMSPIN"},
	required_textures = {"go_hero_minotaur"},
	plugin_required_textures = {},
	required_sounds = {"hero_minotaur"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_minotaur.templates"},
	animations = {"heroes.hero_minotaur.animations"},
	sounds = {"heroes.hero_minotaur.sounds"},
	groups = {"heroes.hero_minotaur.groups"},
	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 0},
		c2 = {255, 170, 88, 255},
		c3 = {255, 42, 0, 255},
		outline = {81, 17, 0, 255},
		outline_thickness = 4.5,
		glow = {81, 17, 0, 255},
		glow_thickness = 1.5
	}
}
