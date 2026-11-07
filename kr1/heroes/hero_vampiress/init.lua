return {
	name = "hero_vampiress",
	room = {
		available_level = 47,
		stats = {7, 6, 0, 6},
		thumb_image = "kr2_hero_room_thumbs_0018",
		icon_image = "kr2_mapButtons_portrait_hero_0018"
	},
	room_special_order = {"VAMPIRISM", "SLAYER", "SLAYER_2", "SLAYER_3"},
	resources = {
		game = {
			required_textures = {"go_hero_vampiress"},
			plugin_required_textures = {},
			required_sounds = {"hero_vampiress"},
			plugin_required_sounds = {},
			required_exoskeletons = {},
			plugin_required_exoskeletons = {}
		},
		map = {
			required_textures = {},
			plugin_required_textures = {},
			required_sounds = {},
			plugin_required_sounds = {},
			required_exoskeletons = {},
			plugin_required_exoskeletons = {}
		}
	},
	templates = {"heroes.hero_vampiress.templates"},
	animations = {"heroes.hero_vampiress.animations"},
	sounds = {"heroes.hero_vampiress.sounds"},
	groups = {"heroes.hero_vampiress.groups"}
}
