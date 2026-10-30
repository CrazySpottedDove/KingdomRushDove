local NS = require("heroes.name_style")

return {
	name = "hero_oni_kr6",
	room = {
		available_level = 211,
		stats = {4, 3.5, 8, 3.5},
		portrait_image = "hero_oni_kr6_portrait",
		thumb_image = "hero_oni_kr6_thumb",
		icon_image = "hero_oni_kr6_icon"
	},
	room_special_order = {"DEATH_STRIKE", "NETHERFOCUS", "HELLISH_BLINK", "LETHAL_COMBO", "DUEL_FERVOR", "SWORD_TORMENT"},
	required_textures = {"go_hero_oni_kr6"},
	plugin_required_textures = {},
	required_sounds = {"hero_oni_kr6"},
	plugin_required_sounds = {},
	required_exoskeletons = {"OniDef"},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_oni_kr6.templates"},
	animations = {"heroes.hero_oni_kr6.animations"},
	sounds = {"heroes.hero_oni_kr6.sounds"},
	groups = {"heroes.hero_oni_kr6.groups"},
	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 255},
		c2 = {255, 167, 98, 255},
		c3 = {224, 44, 0, 255},
		outline = {114, 18, 0, 255},
		outline_thickness = 1.5,
		glow = {114, 18, 0, 255},
		glow_thickness = 1
	}
}
