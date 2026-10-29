local NS = require("heroes.name_style")

return {
	name = "hero_dianyun",
	room = {
		available_level = 1,
		starting_level = 1,
		from_kr = 4,
		stats = {9, 0, 9, 5},
		portrait_image = "kr4_portrait_notxt_0013",
		thumb_image = "kr4_hero_room_thumbs_0013",
		icon_image = "kr4_mapButtons_portrait_hero_0013"
	},
	room_special_order = {"RICOCHET", "LORD_STORM", "DIVINE_RAIN", "SUPREME_WAVE", "ULTIMATE", "ULTIMATE_2"},
	required_textures = {"go_hero_dianyun"},
	plugin_required_textures = {},
	required_sounds = {"hero_dianyun"},
	plugin_required_sounds = {},
	required_exoskeletons = {"hero_dianyun", "hero_dianyun_health_rain"},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_dianyun.templates"},
	animations = {"heroes.hero_dianyun.animations"},
	sounds = {"heroes.hero_dianyun.sounds"},
	groups = {"heroes.hero_dianyun.groups"},
	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {255, 204, 0, 255},
		c2 = {255, 230, 102, 255},
		c3 = {179, 143, 0, 255},
		outline = {102, 82, 0, 255},
		outline_thickness = 2.5,
		glow = {102, 82, 0, 255},
		glow_thickness = 1
	}
}
