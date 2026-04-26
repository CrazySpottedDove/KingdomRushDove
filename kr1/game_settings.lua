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
	"tower_bone_flingers"
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
	"tower_infernal_mage"
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
	"tower_rotten_forest"
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
	"tower_druid",
	"tower_drow",
	"tower_ewok",
	"tower_baby_ashbite",
	"tower_pandas_lvl4",
	"tower_ghost_lvl4",
	"tower_dwarf_lvl4",
	"tower_rocket_gunners_lvl4",
	"tower_paladin_covenant_lvl4"
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
GS.gameplay_tips_count = 21
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
	{
		always_shown = true,
		name = "enemy_goblin"
	},
	{
		name = "enemy_fat_orc"
	},
	{
		name = "enemy_shaman"
	},
	{
		name = "enemy_ogre"
	},
	{
		name = "enemy_bandit"
	},
	{
		name = "enemy_brigand"
	},
	{
		name = "enemy_marauder"
	},
	{
		name = "enemy_spider_small"
	},
	{
		name = "enemy_spider_big"
	},
	{
		name = "enemy_gargoyle"
	},
	{
		name = "enemy_shadow_archer"
	},
	{
		name = "enemy_dark_knight"
	},
	{
		name = "enemy_wolf_small"
	},
	{
		name = "enemy_wolf"
	},
	{
		name = "enemy_golem_head"
	},
	{
		name = "enemy_whitewolf"
	},
	{
		name = "enemy_troll"
	},
	{
		name = "enemy_troll_axe_thrower"
	},
	{
		name = "enemy_troll_chieftain"
	},
	{
		name = "enemy_yeti"
	},
	{
		name = "enemy_rocketeer"
	},
	{
		name = "enemy_slayer"
	},
	{
		name = "enemy_demon"
	},
	{
		name = "enemy_demon_mage"
	},
	{
		name = "enemy_demon_wolf"
	},
	{
		name = "enemy_demon_imp"
	},
	{
		name = "enemy_skeleton"
	},
	{
		name = "enemy_skeleton_big"
	},
	{
		name = "enemy_necromancer"
	},
	{
		name = "enemy_lava_elemental"
	},
	{
		name = "enemy_sarelgaz_small"
	},
	{
		name = "eb_juggernaut"
	},
	{
		name = "eb_jt"
	},
	{
		name = "eb_veznan"
	},
	{
		name = "eb_sarelgaz"
	},
	{
		name = "enemy_goblin_zapper"
	},
	{
		name = "enemy_orc_armored"
	},
	{
		name = "enemy_orc_rider"
	},
	{
		name = "enemy_forest_troll"
	},
	{
		name = "eb_gulthak"
	},
	{
		name = "enemy_zombie"
	},
	{
		name = "enemy_spider_rotten"
	},
	{
		name = "enemy_rotten_tree"
	},
	{
		name = "enemy_swamp_thing"
	},
	{
		name = "eb_greenmuck"
	},
	{
		name = "enemy_raider"
	},
	{
		name = "enemy_pillager"
	},
	{
		name = "eb_kingpin"
	},
	{
		name = "enemy_troll_skater"
	},
	{
		name = "enemy_troll_brute"
	},
	{
		name = "eb_ulgukhai"
	},
	{
		name = "enemy_demon_legion"
	},
	{
		name = "enemy_demon_flareon"
	},
	{
		name = "enemy_demon_gulaemon"
	},
	{
		name = "enemy_demon_cerberus"
	},
	{
		name = "eb_moloch"
	},
	{
		name = "enemy_rotten_lesser"
	},
	{
		name = "eb_myconid"
	},
	{
		name = "enemy_halloween_zombie"
	},
	{
		name = "enemy_giant_rat"
	},
	{
		name = "enemy_wererat"
	},
	{
		name = "enemy_fallen_knight"
	},
	{
		name = "enemy_spectral_knight"
	},
	{
		name = "enemy_abomination"
	},
	{
		name = "enemy_witch"
	},
	{
		name = "enemy_werewolf"
	},
	{
		name = "enemy_lycan"
	},
	{
		name = "eb_blackburn"
	},
	{
		always_shown = true,
		name = "enemy_bouncer"
	},
	{
		name = "enemy_desert_raider"
	},
	{
		name = "enemy_desert_archer"
	},
	{
		name = "enemy_desert_wolf_small"
	},
	{
		name = "enemy_desert_wolf"
	},
	{
		name = "enemy_immortal"
	},
	{
		name = "enemy_fallen"
	},
	{
		name = "enemy_executioner"
	},
	{
		name = "enemy_scorpion"
	},
	{
		name = "enemy_wasp"
	},
	{
		name = "enemy_wasp_queen"
	},
	{
		name = "enemy_tremor"
	},
	{
		name = "enemy_munra"
	},
	{
		name = "enemy_jungle_spider_small"
	},
	{
		name = "enemy_jungle_spider_big"
	},
	{
		name = "enemy_cannibal"
	},
	{
		name = "enemy_hunter"
	},
	{
		name = "enemy_shaman_priest"
	},
	{
		name = "enemy_shaman_shield"
	},
	{
		name = "enemy_shaman_magic"
	},
	{
		name = "enemy_shaman_necro"
	},
	{
		name = "enemy_cannibal_zombie"
	},
	{
		name = "enemy_gorilla"
	},
	{
		name = "enemy_savage_bird_rider"
	},
	{
		name = "enemy_alien_breeder"
	},
	{
		name = "enemy_alien_reaper"
	},
	{
		name = "enemy_razorwing"
	},
	{
		name = "enemy_quetzal"
	},
	{
		name = "enemy_broodguard"
	},
	{
		name = "enemy_myrmidon"
	},
	{
		name = "enemy_blazefang"
	},
	{
		name = "enemy_nightscale"
	},
	{
		name = "enemy_darter"
	},
	{
		name = "enemy_brute"
	},
	{
		name = "enemy_savant"
	},
	{
		name = "enemy_efreeti_small"
	},
	{
		name = "eb_efreeti"
	},
	{
		name = "enemy_gorilla_small"
	},
	{
		name = "eb_gorilla"
	},
	{
		name = "enemy_umbra_minion"
	},
	{
		name = "eb_umbra"
	},
	{
		name = "enemy_greenfin"
	},
	{
		name = "enemy_deviltide"
	},
	{
		name = "enemy_redspine"
	},
	{
		name = "enemy_blacksurge"
	},
	{
		name = "enemy_bluegale"
	},
	{
		name = "enemy_bloodshell"
	},
	{
		name = "eb_leviathan"
	},
	{
		name = "enemy_halloween_zombie"
	},
	{
		name = "enemy_ghoul"
	},
	{
		name = "enemy_bat"
	},
	{
		name = "enemy_werewolf"
	},
	{
		name = "enemy_abomination"
	},
	{
		name = "enemy_lycan"
	},
	{
		name = "enemy_ghost"
	},
	{
		name = "enemy_phantom_warrior"
	},
	{
		name = "enemy_elvira"
	},
	{
		name = "eb_dracula"
	},
	{
		name = "enemy_sniper"
	},
	{
		name = "eb_saurian_king"
	},
	{
		always_shown = true,
		name = "enemy_gnoll_reaver"
	},
	{
		name = "enemy_gnoll_burner"
	},
	{
		name = "enemy_gnoll_gnawer"
	},
	{
		name = "enemy_hyena"
	},
	{
		name = "enemy_perython"
	},
	{
		name = "enemy_gnoll_blighter"
	},
	{
		name = "enemy_ettin"
	},
	{
		name = "enemy_twilight_elf_harasser"
	},
	{
		name = "eb_gnoll"
	},
	{
		name = "enemy_sword_spider"
	},
	{
		name = "enemy_satyr_cutthroat"
	},
	{
		name = "enemy_satyr_hoplite"
	},
	{
		name = "enemy_webspitting_spider"
	},
	{
		name = "enemy_gloomy"
	},
	{
		name = "enemy_twilight_scourger"
	},
	{
		name = "enemy_bandersnatch"
	},
	{
		name = "enemy_redcap"
	},
	{
		name = "enemy_twilight_avenger"
	},
	{
		name = "enemy_boomshrooms"
	},
	{
		name = "enemy_munchshrooms"
	},
	{
		name = "enemy_shroom_breeder"
	},
	{
		name = "eb_drow_queen"
	},
	{
		name = "enemy_razorboar"
	},
	{
		name = "enemy_twilight_evoker"
	},
	{
		name = "enemy_twilight_golem"
	},
	{
		name = "enemy_mantaray"
	},
	{
		name = "enemy_spider_arachnomancer"
	},
	{
		name = "enemy_twilight_heretic"
	},
	{
		name = "enemy_spider_son_of_mactans"
	},
	{
		name = "enemy_arachnomancer"
	},
	{
		name = "enemy_drider"
	},
	{
		name = "eb_spider"
	},
	{
		name = "enemy_gnoll_bloodsydian"
	},
	{
		name = "enemy_bloodsydian_warlock"
	},
	{
		name = "enemy_ogre_magi"
	},
	{
		name = "eb_bram"
	},
	{
		name = "enemy_blood_servant"
	},
	{
		name = "enemy_screecher_bat"
	},
	{
		name = "enemy_mounted_avenger"
	},
	{
		name = "eb_bajnimen"
	},
	{
		name = "enemy_shadows_spawns"
	},
	{
		name = "enemy_grim_devourers"
	},
	{
		name = "enemy_dark_spitters"
	},
	{
		name = "enemy_shadow_champion"
	},
	{
		name = "eb_balrog"
	},
	{
		always_shown = true,
		name = "enemy_hog_invader"
	},
	{
		name = "enemy_tusked_brawler"
	},
	{

		name = "enemy_cutthroat_rat"
	},
	{

		name = "enemy_bear_vanguard"
	},
	{

		name = "enemy_turtle_shaman"
	},
	{

		name = "enemy_surveyor_harpy"
	},
	{

		name = "enemy_dreadeye_viper"
	},
	{

		name = "enemy_hyena5"
	},
	{

		name = "enemy_skunk_bombardier"
	},
	{

		name = "enemy_bear_woodcutter"
	},
	{

		name = "enemy_rhino"
	},
	{

		name = "boss_pig"
	},
	{

		name = "enemy_acolyte"
	},
	{

		name = "enemy_acolyte_tentacle"
	},
	{

		name = "enemy_small_stalker"
	},
	{

		name = "enemy_lesser_sister"
	},
	{

		name = "enemy_lesser_sister_nightmare"
	},
	{

		name = "enemy_spiderling"
	},
	{

		name = "enemy_unblinded_priest"
	},
	{

		name = "enemy_unblinded_abomination"
	},
	{

		name = "enemy_unblinded_abomination_stage_8"
	},
	{

		name = "enemy_armored_nightmare"
	},
	{

		name = "enemy_unblinded_shackler"
	},
	{

		name = "enemy_corrupted_stalker"
	},
	{

		name = "enemy_stage_11_cult_leader_illusion"
	},
	{

		name = "enemy_blinker"
	},
	{

		name = "enemy_crystal_golem"
	},
	{

		name = "enemy_glareling"
	},
	{

		name = "boss_corrupted_denas"
	},
	{

		name = "enemy_mindless_husk"
	},
	{

		name = "enemy_vile_spawner"
	},
	{

		name = "enemy_lesser_eye"
	},
	{

		name = "enemy_noxious_horror"
	},
	{

		name = "enemy_hardened_horror"
	},
	{

		name = "enemy_amalgam"
	},
	{

		name = "enemy_evolving_scourge"
	},
	{

		name = "boss_cult_leader"
	},
	{

		name = "controller_stage_16_overseer"
	},
	{

		name = "enemy_corrupted_elf"
	},
	{

		name = "enemy_specter"
	},
	{

		name = "enemy_bane_wolf"
	},
	{

		name = "enemy_dust_cryptid"
	},
	{

		name = "enemy_deathwood"
	},
	{

		name = "enemy_revenant_soulcaller"
	},
	{

		name = "enemy_animated_armor"
	},
	{

		name = "enemy_revenant_harvester"
	},
	{

		name = "boss_navira"
	},
	{

		name = "enemy_crocs_basic"
	},
	{

		name = "enemy_crocs_basic_egg"
	},
	{

		name = "enemy_crocs_ranged"
	},
	{

		name = "enemy_crocs_flier"
	},
	{

		name = "enemy_killertile"
	},
	{

		name = "enemy_quickfeet_gator"
	},
	{

		name = "enemy_crocs_egg_spawner"
	},
	{

		name = "enemy_crocs_shaman"
	},
	{

		name = "enemy_crocs_hydra"
	},
	{

		name = "enemy_crocs_tank"
	},
	{

		name = "boss_crocs_lvl1"
	},
	{

		name = "enemy_darksteel_hammerer"
	},
	{

		name = "enemy_scrap_speedster"
	},
	{

		name = "enemy_darksteel_shielder"
	},
	{

		name = "enemy_darksteel_guardian"
	},
	{

		name = "enemy_surveillance_sentry"
	},
	{

		name = "enemy_rolling_sentry"
	},
	{

		name = "enemy_brute_welder"
	},
	{

		name = "enemy_darksteel_fist"
	},
	{

		name = "enemy_machinist"
	},
	{

		name = "enemy_mad_tinkerer"
	},
	{

		name = "enemy_scrap_drone"
	},
	{

		name = "boss_machinist"
	},
	{

		name = "enemy_darksteel_anvil"
	},
	{

		name = "enemy_common_clone"
	},
	{

		name = "enemy_darksteel_hulk"
	},
	{

		name = "enemy_deformed_grymbeard_clone"
	},
	{

		name = "boss_grymbeard"
	},
	{

		name = "enemy_ballooning_spider"
	},
	{

		name = "enemy_glarenwarden"
	},
	{

		name = "enemy_spider_sister"
	},
	{

		name = "enemy_spider_priest"
	},
	{

		name = "enemy_drainbrood"
	},
	{

		name = "enemy_cultbrood"
	},
	{

		name = "enemy_spidead"
	},
	{

		name = "boss_spider_queen"
	},
	{

		name = "enemy_flame_guard"
	},
	{

		name = "enemy_blaze_raider"
	},
	{

		name = "enemy_fire_fox"
	},
	{

		name = "enemy_fire_phoenix"
	},
	{

		name = "enemy_nine_tailed_fox"
	},
	{

		name = "enemy_wuxian"
	},
	{

		name = "enemy_burning_treant"
	},
	{

		name = "enemy_ash_spirit"
	},
	{

		name = "boss_redboy_teen"
	},
	{

		name = "enemy_citizen_1"
	},
	{

		name = "enemy_gale_warrior"
	},
	{

		name = "enemy_water_spirit"
	},
	{

		name = "enemy_storm_spirit"
	},
	{

		name = "enemy_storm_elemental"
	},
	{

		name = "enemy_qiongqi"
	},
	{

		name = "enemy_water_sorceress"
	},
	{

		name = "enemy_palace_guard"
	},
	{

		name = "enemy_fan_guard"
	},
	{

		name = "boss_princess_iron_fan"
	},
	{

		name = "enemy_doom_bringer"
	},
	{

		name = "enemy_demon_minotaur"
	},
	{

		name = "enemy_golden_eyed"
	},
	{

		name = "enemy_hellfire_warlock"
	},
	{

		name = "boss_bull_king"
	},
	{

		name = "enemy_tower_ray_sheep"
	},
	{

		name = "enemy_pumpkin_witch"
	},
	{

		name = "enemy_basic_lava"
	},
	{

		name = "enemy_evolved_lava"
	},
	{

		name = "enemy_alfa_lava"
	},
	{

		name = "enemy_basic_acid"
	},
	{

		name = "enemy_evolved_acid"
	},
	{

		name = "enemy_alfa_acid"
	},
	{

		name = "enemy_basic_shadow"
	},
	{

		name = "enemy_evolved_shadow"
	},
	{

		name = "enemy_alfa_shadow"
	},
	{

		name = "enemy_basic_storm"
	},
	{

		name = "enemy_evolved_storm"
	},
	{

		name = "enemy_alfa_storm"
	},
	{

		name = "enemy_executioner_storm"
	},
	{

		name = "boss_murglum"
	},
	{

		name = "enemy_miniboss_stage_39"
	},
	{

		name = "controller_stage_39_boss"
	},
	{

		name = "controller_stage_40_boss"
	}
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
	soldier_death_rider = true,
	soldier_tower_necromancer_skeleton_lvl4 = true,
	soldier_tower_necromancer_skeleton_golem_lvl4 = true,
	soldier_dragon_bone_ultimate_dog = true,
	soldier_flingers_skeleton = true,
	soldier_flingers_skeleton_warrior = true,
	soldier_bone_golem = true
}

return GS
