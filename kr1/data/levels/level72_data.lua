return {
    entities_list = {{
        template = "decal_background",
        pos = {
            x = 512,
            y = 384
        },
        ["render.sprites[1].name"] = "stage72",
        ["render.sprites[1].z"] = 1000
    }},
    invalid_path_ranges = {},
    level_mode_overrides = {{
        locked_towers = {},
        max_upgrade_level = 6
    }, {
        locked_towers = {},
        max_upgrade_level = 6
    }, {
        locked_towers = {"tower_build_engineer", "tower_build_mage"},
        max_upgrade_level = 6
    }},
    level_terrain_type = 1,
    locked_hero = false,
    max_upgrade_level = 6,

    required_sounds = {"music_stage26", "BlackburnSounds"},
    required_textures = {"go_enemies_blackburn", "go_stages_blackburn", "go_stage72_bg"}
}
