local NS = require("heroes.name_style")

return {
	name = "hero_ashbite",
	room = {
		available_level = 208,
		stats = {10, 3, 10, 4},
		portrait_image = "hero_ashbite_kr6_portrait",
		thumb_image = "hero_ashbite_kr6_thumb",
		icon_image = "hero_ashbite_kr6_icon"
	},
	room_special_order = {"BLAZING_BREATH", "SEARING_SNEEZE", "FEEDING_TIME", "SPITFIRE", "MELTING_FURY", "WILDFIRE_BARRAGE"},
	required_textures = {"go_hero_ashbite"},
	plugin_required_textures = {},
	required_sounds = {"hero_ashbite"},
	plugin_required_sounds = {},
	required_exoskeletons = {"hero_ashbiteDef"},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_ashbite.templates"},
	animations = {"heroes.hero_ashbite.animations"},
	sounds = {"heroes.hero_ashbite.sounds"},
	groups = {"heroes.hero_ashbite.groups"},
	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {255, 214, 170, 255},
		c3 = {226, 96, 52, 255},
		outline = {84, 20, 12, 255},
		outline_thickness = 2.5,
		glow = {84, 20, 12, 255},
		glow_thickness = 1
	}
}
