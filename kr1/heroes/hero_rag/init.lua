local NS = require("heroes.name_style")

return {
	name = "hero_rag",
	room = {
		available_level = 56,
		starting_level = 5,
		from_kr = 3,
		stats = {5, 4, 4, 5},
		portrait_image = "kr3_portrait_notxt_0006",
		thumb_image = "kr3_hero_room_thumbs_0006",
		icon_image = "kr3_mapButtons_portrait_hero_0006"
	},
	room_special_order = {"KAMIHARE", "HAMMER_TIME", "ANGRY_GNOME", "RAGGIFIED", "ULTIMATE"},
	required_textures = {"go_hero_rag"},
	plugin_required_textures = {},
	required_sounds = {"hero_rag"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_rag.templates"},
	animations = {"heroes.hero_rag.animations"},
	sounds = {"heroes.hero_rag.sounds"},
	groups = {"heroes.hero_rag.groups"},

	name_style = {
		margin = 1,
		p1 = NS.p21,
		p2 = NS.p22,
		c1 = {255, 204, 241, 255},
		c2 = {255, 132, 186, 255},
		c3 = {206, 0, 119, 255},
		outline = {140, 0, 81, 255},
		outline_thickness = 1.5,
		glow = {140, 0, 81, 255},
		glow_thickness = 0.2,
		single_line = true
	}
}
