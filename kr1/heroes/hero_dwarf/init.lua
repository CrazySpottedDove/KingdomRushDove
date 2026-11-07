return {
	name = "hero_dwarf",
	room = {
		available_level = 40,
		stats = {7, 5, 0, 4},
		thumb_image = "kr2_hero_room_thumbs_0017",
		icon_image = "kr2_mapButtons_portrait_hero_0017"
	},
	room_special_order = {"RING", "GIANT", "GIANT_2"},
	resources = {
		game = {
			required_textures = {"go_hero_dwarf"},
			plugin_required_textures = {},
			required_sounds = {"hero_dwarf"},
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
	templates = {"heroes.hero_dwarf.templates"},
	animations = {"heroes.hero_dwarf.animations"},
	sounds = {"heroes.hero_dwarf.sounds"},
	groups = {"heroes.hero_dwarf.groups"}
}
