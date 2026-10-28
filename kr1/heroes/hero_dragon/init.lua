local NS = require("heroes.name_style")

return {
	name = "hero_dragon",
	room = {
		available_level = 39,
		starting_level = 1,
		from_kr = 2,
		stats = {7, 6, 5, 6},
		portrait = 10,
		thumb = 10,
		icon = 10,
		portrait_image = "kr2_portrait_notxt_0010",
		thumb_image = "kr2_hero_room_thumbs_0010",
		icon_image = "kr2_mapButtons_portrait_hero_0010"
	},
	room_special_order = {"BLAZINGBREATH", "FEAST", "FIERYMIST", "WILDFIREBARRAGE", "REIGNOFFIRE"},
	required_textures = {"go_hero_dragon"},
	plugin_required_textures = {},
	required_sounds = {"hero_dragon"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_dragon.templates"},
	animations = {"heroes.hero_dragon.animations"},
	sounds = {"heroes.hero_dragon.sounds"},
	groups = {"heroes.hero_dragon.groups"},
	name_style = {
		margin = 0,
		p1 = NS.p21,
		p2 = NS.p22,
		c1 = {255, 210, 0, 0},
		c2 = {255, 151, 25, 255},
		c3 = {222, 77, 22, 255},
		outline = {98, 20, 0, 255},
		outline_thickness = 4.5,
		glow = {98, 20, 0, 255},
		glow_thickness = 1.5
	}
}
