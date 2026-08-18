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
	"tower_swamp_monster"
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
	"tower_wicked_sisters"
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
	"tower_sandworm"
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
	"tower_twilight_elves_barrack"
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
GS.gameplay_tips_count = 52
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

GS.main_campaign_levels = 12
GS.main_campaign_levels2 = 41
GS.main_campaign_levels3 = 63
GS.main_campaign_levels1 = 12
GS.main_campaign_levels5 = 116
GS.last_level = 26
GS.level1_from = 0
GS.level2_from = 26
GS.level3_from = 48
GS.level5_from = 100
GS.last_level1 = 26
GS.last_level2 = 22
GS.last_level3 = 22
GS.last_level5 = 40
GS.extra_level1_from = 999
GS.extra_level1 = 3
GS.extra_level2_from = 1999
GS.extra_level2 = 5
GS.extra_level3_from = 2999
GS.extra_level3 = 1
GS.extra_level5_from = 4999
GS.extra_level5 = 0
GS.endless_levels_count = 1
GS.level_ranges1 = {
	{1, 12},
	{13},
	{14},
	{15},
	{16, 17},
	{18, 19},
	{20, 21},
	{22},
	{23, 26},
	{1000},
	{1001},
	{1002}
}
GS.level_ranges2 = {{27, 41}, {42, 44}, {45, 47}, {48}, {2000}, {2001}, {2002}, {2003}, {2004}}
GS.level_ranges3 = {{49, 63}, {64, 66}, {67, 68}, {69, 70}, {3000}}
GS.level_ranges5 = {{101, 116}, {117, 119}, {120, 122}, {123, 127}, {128, 130}, {131, 135}, {136, 140}}
GS.max_stars = 0

for _, range in ipairs(GS.level_ranges1) do
	if #range == 2 then
		GS.max_stars = GS.max_stars + (range[2] - range[1] + 1) * 5
	else
		GS.max_stars = GS.max_stars + 5
	end
end

for _, range in ipairs(GS.level_ranges2) do
	if #range == 2 then
		GS.max_stars = GS.max_stars + (range[2] - range[1] + 1) * 5
	else
		GS.max_stars = GS.max_stars + 5
	end
end

for _, range in ipairs(GS.level_ranges3) do
	if #range == 2 then
		GS.max_stars = GS.max_stars + (range[2] - range[1] + 1) * 5
	else
		GS.max_stars = GS.max_stars + 5
	end
end

for _, range in ipairs(GS.level_ranges5) do
	if #range == 2 then
		GS.max_stars = GS.max_stars + (range[2] - range[1] + 1) * 5
	else
		GS.max_stars = GS.max_stars + 5
	end
end

GS.hero_xp_thresholds = {300, 900, 2000, 4000, 8000, 12000, 16000, 20000, 26000}

GS.encyclopedia_enemies = {
	"enemy_goblin",
	"enemy_fat_orc",
	"enemy_shaman",
	"enemy_ogre",
	"enemy_bandit",
	"enemy_brigand",
	"enemy_marauder",
	"enemy_spider_small",
	"enemy_spider_big",
	"enemy_gargoyle",
	"enemy_shadow_archer",
	"enemy_dark_knight",
	"enemy_wolf_small",
	"enemy_wolf",
	"enemy_golem_head",
	"enemy_whitewolf",
	"enemy_troll",
	"enemy_troll_axe_thrower",
	"enemy_troll_chieftain",
	"enemy_yeti",
	"enemy_rocketeer",
	"enemy_slayer",
	"enemy_demon",
	"enemy_demon_mage",
	"enemy_demon_wolf",
	"enemy_demon_imp",
	"enemy_skeleton",
	"enemy_skeleton_big",
	"enemy_necromancer",
	"enemy_lava_elemental",
	"enemy_sarelgaz_small",
	"eb_juggernaut",
	"eb_jt",
	"eb_veznan",
	"eb_sarelgaz",
	"enemy_goblin_zapper",
	"enemy_orc_armored",
	"enemy_orc_rider",
	"enemy_forest_troll",
	"eb_gulthak",
	"enemy_zombie",
	"enemy_spider_rotten",
	"enemy_rotten_tree",
	"enemy_swamp_thing",
	"eb_greenmuck",
	"enemy_raider",
	"enemy_pillager",
	"eb_kingpin",
	"enemy_troll_skater",
	"enemy_troll_brute",
	"eb_ulgukhai",
	"enemy_demon_legion",
	"enemy_demon_flareon",
	"enemy_demon_gulaemon",
	"enemy_demon_cerberus",
	"eb_moloch",
	"enemy_rotten_lesser",
	"eb_myconid",
	"enemy_halloween_zombie",
	"enemy_giant_rat",
	"enemy_wererat",
	"enemy_fallen_knight",
	"enemy_spectral_knight",
	"enemy_abomination",
	"enemy_witch",
	"enemy_werewolf",
	"enemy_lycan",
	"eb_blackburn",
	"enemy_bouncer",
	"enemy_desert_raider",
	"enemy_desert_archer",
	"enemy_desert_wolf_small",
	"enemy_desert_wolf",
	"enemy_immortal",
	"enemy_fallen",
	"enemy_executioner",
	"enemy_scorpion",
	"enemy_wasp",
	"enemy_wasp_queen",
	"enemy_tremor",
	"enemy_munra",
	"enemy_jungle_spider_small",
	"enemy_jungle_spider_big",
	"enemy_cannibal",
	"enemy_hunter",
	"enemy_shaman_priest",
	"enemy_shaman_shield",
	"enemy_shaman_magic",
	"enemy_shaman_necro",
	"enemy_cannibal_zombie",
	"enemy_gorilla",
	"enemy_savage_bird_rider",
	"enemy_alien_breeder",
	"enemy_alien_reaper",
	"enemy_razorwing",
	"enemy_quetzal",
	"enemy_broodguard",
	"enemy_myrmidon",
	"enemy_blazefang",
	"enemy_nightscale",
	"enemy_darter",
	"enemy_brute",
	"enemy_savant",
	"enemy_efreeti_small",
	"eb_efreeti",
	"enemy_gorilla_small",
	"eb_gorilla",
	"enemy_umbra_minion",
	"eb_umbra",
	"enemy_greenfin",
	"enemy_deviltide",
	"enemy_redspine",
	"enemy_blacksurge",
	"enemy_bluegale",
	"enemy_bloodshell",
	"eb_leviathan",
	"enemy_halloween_zombie",
	"enemy_ghoul",
	"enemy_bat",
	"enemy_werewolf",
	"enemy_abomination",
	"enemy_lycan",
	"enemy_ghost",
	"enemy_phantom_warrior",
	"enemy_elvira",
	"eb_dracula",
	"enemy_sniper",
	"eb_saurian_king",
	"enemy_gnoll_reaver",
	"enemy_gnoll_burner",
	"enemy_gnoll_gnawer",
	"enemy_hyena",
	"enemy_perython",
	"enemy_gnoll_blighter",
	"enemy_ettin",
	"enemy_twilight_elf_harasser",
	"eb_gnoll",
	"enemy_sword_spider",
	"enemy_satyr_cutthroat",
	"enemy_satyr_hoplite",
	"enemy_webspitting_spider",
	"enemy_gloomy",
	"enemy_twilight_scourger",
	"enemy_bandersnatch",
	"enemy_redcap",
	"enemy_twilight_avenger",
	"enemy_boomshrooms",
	"enemy_munchshrooms",
	"enemy_shroom_breeder",
	"eb_drow_queen",
	"enemy_razorboar",
	"enemy_twilight_evoker",
	"enemy_twilight_golem",
	"enemy_mantaray",
	"enemy_spider_arachnomancer",
	"enemy_twilight_heretic",
	"enemy_spider_son_of_mactans",
	"enemy_arachnomancer",
	"enemy_drider",
	"eb_spider",
	"enemy_gnoll_bloodsydian",
	"enemy_bloodsydian_warlock",
	"enemy_ogre_magi",
	"eb_bram",
	"enemy_blood_servant",
	"enemy_screecher_bat",
	"enemy_mounted_avenger",
	"eb_bajnimen",
	"enemy_shadows_spawns",
	"enemy_grim_devourers",
	"enemy_dark_spitters",
	"enemy_shadow_champion",
	"eb_balrog",
	"enemy_hog_invader",
	"enemy_tusked_brawler",
	"enemy_cutthroat_rat",
	"enemy_bear_vanguard",
	"enemy_turtle_shaman",
	"enemy_surveyor_harpy",
	"enemy_dreadeye_viper",
	"enemy_hyena5",
	"enemy_skunk_bombardier",
	"enemy_bear_woodcutter",
	"enemy_rhino",
	"boss_pig",
	"enemy_acolyte",
	"enemy_acolyte_tentacle",
	"enemy_small_stalker",
	"enemy_lesser_sister",
	"enemy_lesser_sister_nightmare",
	"enemy_spiderling",
	"enemy_unblinded_priest",
	"enemy_unblinded_abomination",
	"enemy_unblinded_abomination_stage_8",
	"enemy_armored_nightmare",
	"enemy_unblinded_shackler",
	"enemy_corrupted_stalker",
	"enemy_stage_11_cult_leader_illusion",
	"enemy_blinker",
	"enemy_crystal_golem",
	"enemy_glareling",
	"boss_corrupted_denas",
	"enemy_mindless_husk",
	"enemy_vile_spawner",
	"enemy_lesser_eye",
	"enemy_noxious_horror",
	"enemy_hardened_horror",
	"enemy_amalgam",
	"enemy_evolving_scourge",
	"boss_cult_leader",
	"controller_stage_16_overseer",
	"enemy_corrupted_elf",
	"enemy_specter",
	"enemy_bane_wolf",
	"enemy_dust_cryptid",
	"enemy_deathwood",
	"enemy_revenant_soulcaller",
	"enemy_animated_armor",
	"enemy_revenant_harvester",
	"boss_navira",
	"enemy_crocs_basic",
	"enemy_crocs_basic_egg",
	"enemy_crocs_ranged",
	"enemy_crocs_flier",
	"enemy_killertile",
	"enemy_quickfeet_gator",
	"enemy_crocs_egg_spawner",
	"enemy_crocs_shaman",
	"enemy_crocs_hydra",
	"enemy_crocs_tank",
	"boss_crocs_lvl1",
	"enemy_darksteel_hammerer",
	"enemy_scrap_speedster",
	"enemy_darksteel_shielder",
	"enemy_darksteel_guardian",
	"enemy_surveillance_sentry",
	"enemy_rolling_sentry",
	"enemy_brute_welder",
	"enemy_darksteel_fist",
	"enemy_machinist",
	"enemy_mad_tinkerer",
	"enemy_scrap_drone",
	"boss_machinist",
	"enemy_darksteel_anvil",
	"enemy_common_clone",
	"enemy_darksteel_hulk",
	"enemy_deformed_grymbeard_clone",
	"boss_grymbeard",
	"enemy_ballooning_spider",
	"enemy_glarenwarden",
	"enemy_spider_sister",
	"enemy_spider_priest",
	"enemy_drainbrood",
	"enemy_cultbrood",
	"enemy_spidead",
	"boss_spider_queen",
	"enemy_flame_guard",
	"enemy_blaze_raider",
	"enemy_fire_fox",
	"enemy_fire_phoenix",
	"enemy_nine_tailed_fox",
	"enemy_wuxian",
	"enemy_burning_treant",
	"enemy_ash_spirit",
	"boss_redboy_teen",
	"enemy_citizen_1",
	"enemy_gale_warrior",
	"enemy_water_spirit",
	"enemy_storm_spirit",
	"enemy_storm_elemental",
	"enemy_qiongqi",
	"enemy_water_sorceress",
	"enemy_palace_guard",
	"enemy_fan_guard",
	"boss_princess_iron_fan",
	"enemy_doom_bringer",
	"enemy_demon_minotaur",
	"enemy_golden_eyed",
	"enemy_hellfire_warlock",
	"boss_bull_king",
	"enemy_tower_ray_sheep",
	"enemy_pumpkin_witch",
	"enemy_basic_lava",
	"enemy_evolved_lava",
	"enemy_tanky_draconian",
	"enemy_alfa_lava",
	"enemy_basic_acid",
	"enemy_evolved_acid",
	"enemy_alfa_acid",
	"enemy_basic_shadow",
	"enemy_evolved_shadow",
	"enemy_alfa_shadow",
	"enemy_basic_storm",
	"enemy_evolved_storm",
	"enemy_alfa_storm",
	"enemy_executioner_storm",
	"boss_murglum",
	"enemy_miniboss_stage_39",
	"controller_stage_39_boss",
	"controller_stage_40_boss"
}

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
	hero_mortemis_golem = true
}

GS.hero_exoskeletons = {
	hero_dianyun = {"hero_dianyun", "hero_dianyun_health_rain"}
-- hero_beresad = {"hero_beresad_ultimate_particles_animations"}
}

return GS
