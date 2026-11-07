return {
	name = "hero_bolverk",
	room = {
		available_level = 70,
		stats = {5, 5, 0, 6},
		thumb_image = "kr3_hero_room_thumbs_0019",
		icon_image = "kr3_mapButtons_portrait_hero_0019"
	},
	room_special_order = {"SLASH", "SCREAM", "BERSERKER"},
	resources = {
		game = {
			required_textures = {"go_hero_bolverk"},
			plugin_required_textures = {},
			required_sounds = {"hero_bolverk"},
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
	templates = {"heroes.hero_bolverk.templates"},
	animations = {"heroes.hero_bolverk.animations"},
	sounds = {"heroes.hero_bolverk.sounds"},
	groups = {"heroes.hero_bolverk.groups"}
}
