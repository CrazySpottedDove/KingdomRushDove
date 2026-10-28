local NS = require("heroes.name_style")

return {
	name = "hero_spider",
	room = {
		available_level = 116,
		starting_level = 1,
		from_kr = 5,
		stats = {6, 8, 6, 4},
		portrait = 17,
		thumb = 17,
		icon = 17,
		portrait_image = "kr5_portrait_notxt_0017",
		thumb_image = "kr5_hero_room_thumbs_0017",
		icon_image = "kr5_mapButtons_portrait_hero_0017"
	},
	room_special_order = {"INSTAKILL_MELEE", "AREA_ATTACK", "TUNNELING", "SUPREME_HUNTER", "ULTIMATE"},
	required_textures = {"go_hero_spider"},
	plugin_required_textures = {},
	required_sounds = {"hero_spider"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_spider.templates"},
	animations = {"heroes.hero_spider.animations"},
	sounds = {"heroes.hero_spider.sounds"},
	groups = {"heroes.hero_spider.groups"},

	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {255, 73, 240, 255},
		c3 = {174, 48, 162, 255},
		outline = {89, 23, 84, 255},
		outline_thickness = 2.5,
		glow = {89, 23, 84, 255},
		glow_thickness = 1
	}
}
