local NS = require("heroes.name_style")

return {
	name = "hero_connor",
	room = {
		available_level = 204,
		stats = {5, 3, 5, 5},
		portrait_image = "hero_connor_kr6_portrait",
		thumb_image = "hero_connor_kr6_thumb",
		icon_image = "hero_connor_kr6_icon"
	},
	room_special_order = {"ARTERIAL_SLASH", "RETRIBUTION", "EARTHSHATTER", "BATTLEBORN", "HOLY_GRAIL", "TEMPLAR_RAGE"},
	required_textures = {"go_hero_connor"},
	plugin_required_textures = {},
	required_sounds = {"hero_connor"},
	plugin_required_sounds = {},
	required_exoskeletons = {"oconnorDef", "oconnor_ultDef"},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_connor.templates"},
	animations = {"heroes.hero_connor.animations"},
	sounds = {"heroes.hero_connor.sounds"},
	groups = {"heroes.hero_connor.groups"},
	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {255, 232, 180, 255},
		c3 = {229, 178, 65, 255},
		outline = {100, 69, 0, 255},
		outline_thickness = 2.5,
		glow = {100, 69, 0, 255},
		glow_thickness = 1
	}
}
