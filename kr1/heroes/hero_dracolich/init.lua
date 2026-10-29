local NS = require("heroes.name_style")

return {
	name = "hero_dracolich",
	room = {
		available_level = 46,
		starting_level = 1,
		from_kr = 2,
		stats = {7, 5, 5, 6},
		portrait_image = "kr2_portrait_notxt_0014",
		thumb_image = "kr2_hero_room_thumbs_0014",
		icon_image = "kr2_mapButtons_portrait_hero_0014"
	},
	room_special_order = {"SPINERAIN", "DISEASENOVA", "PLAGUECARRIER", "BONEGOLEM", "UNSTABLEDISEASE"},
	required_textures = {"go_hero_dracolich"},
	plugin_required_textures = {},
	required_sounds = {"hero_dracolich"},
	plugin_required_sounds = {},
	required_exoskeletons = {},
	plugin_required_exoskeletons = {},
	screen_map_required_textures = {},
	screen_map_plugin_required_textures = {},
	screen_map_required_sounds = {},
	screen_map_plugin_required_sounds = {},
	templates = {"heroes.hero_dracolich.templates"},
	animations = {"heroes.hero_dracolich.animations"},
	sounds = {"heroes.hero_dracolich.sounds"},
	groups = {"heroes.hero_dracolich.groups"},
	name_style = {
		margin = 0,
		p1 = NS.p11,
		p2 = NS.p12,
		c1 = {0, 0, 0, 0},
		c2 = {228, 255, 95, 255},
		c3 = {107, 173, 0, 255},
		outline = {29, 51, 1, 255},
		outline_thickness = 4.5,
		glow = {29, 51, 1, 255},
		glow_thickness = 1.5
	}
}
