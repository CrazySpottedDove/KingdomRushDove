﻿-- chunkname: @./kr1/game_settings.lua

local GS = {}
GS.soldier_regen_factor = 0.2
GS.gameplay_tips_count = 21
GS.early_wave_reward_per_second = 1
GS.max_stars = 350
GS.max_difficulty = DIFFICULTY_IMPOSSIBLE
GS.difficulty_soldier_hp_max_factor = {
	1,
	1,
    1,
    1
}
GS.difficulty_enemy_hp_max_factor = {
	1.2,
    1.5,
    1.5,
    1.8
}
GS.difficulty_enemy_speed_factor = {
	1.20,
	1.20,
	1.25,
    1.25
}
GS.difficulty_enemy_gold_factor = {
    1.0,
    1.0,
    0.9,
    1
}
GS.difficulty_tower_gold_factor = {
    1.0,
    1.0,
    1.05,
    1
}
GS.difficulty_enemy_ranged_attack_cooldown_factor = {
    1.0,
    0.9,
    0.9,
    0.8
}
GS.difficulty_enemy_timed_attack_cooldown_factor = {
    1.0,
    0.9,
    0.9,
    0.8
}
GS.difficulty_enemy_armor_factor = {
    0,
    0,
    0.1,
    0.1
}

GS.hero_xp_gain_per_difficulty_mode = {
    [DIFFICULTY_EASY] = 1,
    [DIFFICULTY_NORMAL] = 0.75,
    [DIFFICULTY_HARD] = 0.65,
    [DIFFICULTY_IMPOSSIBLE] = 0.75
}

GS.kr3_towers = {
    "arcane",
    "silver",
    "wild_magus",
    "druid",
    "entwood",
    "blade",
    "forest",
    "drow",
    "holder_bastion",
    "bastion",
    "holder_ewok",
    "ewok",
    "faerie_dragon",
    "pixie",
    "baby_black_dragon",
    "holder_baby_ashbite",
    "baby_ashbite",
    "high_elven"
}
GS.main_campaign_levels = 12
GS.main_campaign_levels2 = 41
GS.main_campaign_levels3 = 63
GS.main_campaign_levels1 = 12
GS.last_level = 26
GS.last_level1 = 26
GS.last_level2 = 48
GS.last_level3 = 70
GS.endless_levels_count = 1
GS.level_ranges = {
	{
		1,
		12
	},
	{
		13
	},
	{
		14
	},
	{
		15,
		22,
		list = true
	},
	{
		16,
		17
	},
	{
		18,
		19
	},
	{
		20,
		21
	},
	{
		23,
		26
	}
}
GS.level_ranges1 = {{1, 12}, {13}, {14}, {
    15,
    22,
    list = true
}, {16, 17}, {18, 19}, {20, 21}, {23, 26}}
GS.level_ranges2 = {{27, 41}, {42, 44}, {45, 47}, {
    48
}}
GS.level_ranges3 = {{49, 63},{64,66},{67,68},{69,70}}

GS.default_hero = nil
GS.hero_xp_thresholds = {
	300,
	900,
	2000,
	4000,
	8000,
	12000,
	16000,
	20000,
	26000
}
GS.hero_xp_ephemeral = true

GS.skill_points_for_hero_level = {
	0,
	4,
	8,
	12,
	16,
	20,
	24,
	28,
	32,
	36
}
GS.endless_gems_for_wave = 1
GS.gems_factor_per_mode = {
	0.8,
	0.48,
	0.48,
    0
}
GS.gems_per_level = {
	100,
	150,
	200,
	250,
	250,
	300,
	300,
	300,
	400,
	400,
	400,
	500,
	500,
	500,
	500,
	500,
	500,
	500,
	500,
	500,
	500,
	500,
	500,
	500,
	500,
	500,
    100,
	150,
	200,
	250,
	250,
	300,
	300,
	300,
	400,
	400,
	400,
	500,
	500,
	500,
	500,
	500,
	500,
	500,
	500,
	500,
	500,
	500,
	500,
	500,
	500,
	500,
    500,
	500,
	500,
	500,
	500,
	500,
	500,
	500,
	500,
	500,
	500,
	500,
	500,
	500,
	500,
    0,
    0,
    0,
    0,
    0,
    0,
    0
}
GS.encyclopedia_tower_fmt = "encyclopedia_towers_00%02i"
GS.encyclopedia_tower_fmt2 = "encyclopedia_towers_02%02i"
GS.encyclopedia_tower_fmt3 = "encyclopedia_towers_03%02i"
GS.encyclopedia_tower_thumb_fmt = "encyclopedia_tower_thumbs_00%02i"
GS.encyclopedia_tower_thumb_fmt2 = "encyclopedia_tower_thumbs_02%02i"
GS.encyclopedia_tower_thumb_fmt3 = "encyclopedia_tower_thumbs_03%02i"
GS.encyclopedia_enemy_fmt = "encyclopedia_creeps_00%02i"
GS.encyclopedia_enemy_fmt2 = "encyclopedia_creeps_02%02i"
GS.encyclopedia_enemy_fmt3 = "encyclopedia_creeps_03%02i"
GS.encyclopedia_enemy_thumb_fmt = "encyclopedia_creep_thumbs_00%02i"
GS.encyclopedia_enemy_thumb_fmt2 = "encyclopedia_creep_thumbs_02%02i"
GS.encyclopedia_enemy_thumb_fmt3 = "encyclopedia_creep_thumbs_03%02i"
GS.encyclopedia_tower_specials_fmt= "encyclopedia_tower_specials_00%02i"
GS.encyclopedia_tower_specials_fmt2 = "encyclopedia_tower_specials_02%02i"
GS.encyclopedia_tower_specials_fmt3 = "encyclopedia_tower_specials_03%02i"
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
		target = "phone",
		name = "enemy_gnoll_warleader"
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
		target = "phone",
		name = "enemy_twilight_brute"
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
	}
}

for i = #GS.encyclopedia_enemies, 1, -1 do
	if GS.encyclopedia_enemies[i].target and GS.encyclopedia_enemies[i].target ~= KR_TARGET then
		table.remove(GS.encyclopedia_enemies, i)
	end
end



return GS
