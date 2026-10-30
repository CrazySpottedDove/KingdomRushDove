local NS = require("heroes.name_style")

return {
	name = "hero_malik_kr6",
	room = {
		available_level = 206,
		stats = {9, 0, 3, 5.5},
		portrait_image = "hero_malik_kr6_portrait",
		thumb_image = "hero_malik_kr6_thumb",
		icon_image = "hero_malik_kr6_icon"
	},
	room_special_order = {"UNBREAKABLE", "EARTHQUAKE", "OBLITERATE", "FOEHAMMER", "LONE_WULF", "HAMMERNADO"},
	required_textures = {"go_hero_malik_kr6"},
	plugin_required_textures = {},
	required_sounds = {"hero_malik_kr6"},
	plugin_required_sounds = {},
	required_exoskeletons = {"malikDef", "malik_hitfxDef", "malik_shieldDef", "malik_stundecalDef", "malik_areadecalDef"},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_malik_kr6.templates"},
	sounds = {"heroes.hero_malik_kr6.sounds"},
	groups = {"heroes.hero_malik_kr6.groups"},
	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {255, 246, 126, 255},
		c3 = {255, 168, 0, 255},
		outline = {135, 74, 0, 255},
		outline_thickness = 2.5,
		glow = {135, 74, 0, 255},
		glow_thickness = 1
	}
}
