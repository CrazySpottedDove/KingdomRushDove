-- chunkname: @./kr1/game_settings.lua
require("all.constants")
local GS = {}

GS.archer_towers = {
	"tower_archer_1",
	"tower_archer_2",
	"tower_archer_3",
	"tower_ranger",
	"tower_musketeer",
	"tower_crossbow",
	"tower_totem",
	"tower_archer_dwarf",
	"tower_pirate_watchtower",
	"tower_arcane",
	"tower_silver",
	"tower_dark_elf_lvl4",
	"tower_sand_lvl4",
	"tower_royal_archers_lvl4",
	"tower_ballista_lvl4",
	"tower_shadow_archer",
	"tower_bone_flingers",
	"tower_ogre_shipwreck",
	"tower_goblirang",
	"tower_shaolin",
	"tower_swamp_monster",
	"tower_archers",
	"tower_elf_ranger",
	"tower_crossbows",
	"tower_sentry"
}
GS.mage_towers = {
	"tower_mage_1",
	"tower_mage_2",
	"tower_mage_3",
	"tower_arcane_wizard",
	"tower_sorcerer",
	"tower_sunray",
	"tower_archmage",
	"tower_necromancer",
	"tower_high_elven",
	"tower_wild_magus",
	"tower_faerie_dragon",
	"tower_pixie",
	"tower_necromancer_lvl4",
	"tower_ray_lvl4",
	"tower_elven_stargazers_lvl4",
	"tower_arcane_wizard_lvl4",
	"tower_hermit_toad_lvl4",
	"tower_arborean_emissary_lvl4",
	"tower_dragons_lvl4",
	"tower_infernal_mage",
	"tower_orc_shaman",
	"tower_spirit_mausoleum",
	"tower_deep_devils",
	"tower_blazing_watcher",
	"tower_wicked_sisters",
	"tower_wizard",
	"tower_sunray_master",
	"tower_light_priestess",
	"tower_forger"
}
GS.engineer_towers = {
	"tower_engineer_1",
	"tower_engineer_2",
	"tower_engineer_3",
	"tower_bfg",
	"tower_tesla",
	"tower_dwaarp",
	"tower_mech",
	"tower_frankenstein",
	"tower_druid",
	"tower_entwood",
	"tower_tricannon_lvl4",
	"tower_demon_pit_lvl4",
	"tower_flamespitter_lvl4",
	"tower_barrel_lvl4",
	"tower_sparking_geode_lvl4",
	"tower_rotten_forest",
	"tower_rocket_riders",
	"tower_balloon",
	"tower_ignis_altar",
	"tower_melting_furnace",
	"tower_sandworm",
	"tower_catapult",
	"tower_culverine",
	"tower_alchemist",
	"tower_tree"
}
GS.barrack_towers = {
	"tower_barrack_1",
	"tower_barrack_2",
	"tower_barrack_3",
	"tower_paladin",
	"tower_barbarian",
	"tower_elf",
	"tower_templar",
	"tower_assassin",
	"tower_barrack_dwarf",
	"tower_barrack_amazonas",
	"tower_barrack_mercenaries",
	"tower_barrack_pirates",
	"tower_blade",
	"tower_forest",
	"tower_drow",
	"tower_ewok",
	"tower_baby_ashbite",
	"tower_pandas_lvl4",
	"tower_ghost_lvl4",
	"tower_dwarf_lvl4",
	"tower_rocket_gunners_lvl4",
	"tower_paladin_covenant_lvl4",
	"tower_orc_warriors",
	"tower_dark_knights",
	"tower_grim_cemetery",
	"tower_twilight_elves_barrack",
	"tower_stage_28_priests_barrack",
	"tower_knights",
	"tower_wildcat",
	"tower_miners"
}
GS.advanced_towers = {}
for i = 4, #GS.archer_towers do
	table.insert(GS.advanced_towers, GS.archer_towers[i])
end
for i = 4, #GS.mage_towers do
	table.insert(GS.advanced_towers, GS.mage_towers[i])
end
for i = 4, #GS.engineer_towers do
	table.insert(GS.advanced_towers, GS.engineer_towers[i])
end
for i = 4, #GS.barrack_towers do
	table.insert(GS.advanced_towers, GS.barrack_towers[i])
end

GS.soldier_regen_factor = 0.2
GS.gameplay_tips_count = 51
GS.early_wave_reward_per_second = 1
GS.max_upgrade_level = 6
GS.max_difficulty = DIFFICULTY_IMPOSSIBLE
GS.difficulty_soldier_hp_max_factor = {1, 1, 1, 1}
GS.difficulty_enemy_hp_max_factor = {1.3, 1.65, 1.65, 2}
GS.difficulty_enemy_speed_factor = {1.20, 1.20, 1.25, 1.25}
GS.difficulty_enemy_gold_factor = {1.0, 1.0, 0.9, 1}
GS.difficulty_tower_gold_factor = {1.0, 1.0, 1.05, 1}
GS.difficulty_enemy_ranged_attack_cooldown_factor = {1.0, 0.9, 0.9, 0.8}
GS.difficulty_enemy_timed_attack_cooldown_factor = {1.0, 0.9, 0.9, 0.7}
GS.difficulty_enemy_armor_factor = {0, 0, 0.1, 0.1}
GS.hero_xp_gain_per_difficulty_mode = {
	[DIFFICULTY_EASY] = 1,
	[DIFFICULTY_NORMAL] = 0.75,
	[DIFFICULTY_HARD] = 0.65,
	[DIFFICULTY_IMPOSSIBLE] = 0.75
}

GS.hero_xp_thresholds = {300, 900, 2000, 4000, 8000, 12000, 16000, 20000, 26000}

GS.wraith = {
	soldier_skeleton = true,
	soldier_skeleton_knight = true,
	soldier_sand_warrior = true,
	soldier_dracolich_golem = true,
	soldier_frankenstein = true,
	hero_vampiress = true,
	hero_dracolich = true,
	hero_dragon_bone = true,
	hero_hunter = true,
	soldier_death_rider = true,
	soldier_tower_necromancer_skeleton_lvl4 = true,
	soldier_tower_necromancer_skeleton_golem_lvl4 = true,
	soldier_dragon_bone_ultimate_dog = true,
	soldier_flingers_skeleton = true,
	soldier_flingers_skeleton_warrior = true,
	soldier_bone_golem = true,
	soldier_zombie = true,
	soldier_zombie_medium = true,
	soldier_zombie_big = true,
	soldier_gargoyle = true,
	soldier_tower_ghost_lvl4 = true,
	hero_margosa = true,
	hero_mortemis = true,
	hero_mortemis_zombie = true,
	hero_mortemis_golem = true,
	soldier_crossbows_ult = true
}

return GS
