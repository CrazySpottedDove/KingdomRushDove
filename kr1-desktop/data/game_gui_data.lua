-- chunkname: @./kr1-desktop/data/game_gui_data.lua

local V = require("klua.vector")
local v = V.v
local i18n = require("i18n")

local function CJK(default, zh, ja, kr)
	return i18n.cjk(i18n, default, zh, ja, kr)
end

return {
	notifications = {
		enemy_goblin = {
			icon = "alert_creep_notxt_0001",
			image = "encyclopedia_creeps_0001",
			i18n_key = "ENEMY_GOBLIN",
			layout = N_ENEMY,
			icon_signals = {
				{
					"show-balloon",
					"TB_NOTI",
					1
				}
			}
		},
		enemy_fat_orc = {
			icon = "alert_creep_notxt_0002",
			i18n_key = "ENEMY_FAT_ORC",
			image = "encyclopedia_creeps_0002",
			layout = N_ENEMY
		},
		enemy_shaman = {
			icon = "alert_creep_notxt_0003",
			i18n_key = "ENEMY_SHAMAN",
			image = "encyclopedia_creeps_0003",
			layout = N_ENEMY
		},
		enemy_ogre = {
			icon = "alert_creep_notxt_0004",
			i18n_key = "ENEMY_OGRE",
			image = "encyclopedia_creeps_0004",
			layout = N_ENEMY
		},
		enemy_bandit = {
			icon = "alert_creep_notxt_0005",
			i18n_key = "ENEMY_BANDIT",
			image = "encyclopedia_creeps_0005",
			layout = N_ENEMY
		},
		enemy_brigand = {
			icon = "alert_creep_notxt_0006",
			i18n_key = "ENEMY_BRIGAND",
			image = "encyclopedia_creeps_0006",
			layout = N_ENEMY
		},
		enemy_marauder = {
			icon = "alert_creep_notxt_0007",
			i18n_key = "ENEMY_MARAUDER",
			image = "encyclopedia_creeps_0007",
			layout = N_ENEMY
		},
		enemy_spider_small = {
			icon = "alert_creep_notxt_0008",
			i18n_key = "ENEMY_SPIDERSMALL",
			image = "encyclopedia_creeps_0008",
			layout = N_ENEMY
		},
		enemy_spider_big = {
			icon = "alert_creep_notxt_0009",
			i18n_key = "ENEMY_SPIDER",
			image = "encyclopedia_creeps_0009",
			layout = N_ENEMY
		},
		enemy_gargoyle = {
			icon = "alert_creep_notxt_0010",
			i18n_key = "ENEMY_GARGOYLE",
			image = "encyclopedia_creeps_0010",
			layout = N_ENEMY
		},
		enemy_shadow_archer = {
			icon = "alert_creep_notxt_0011",
			i18n_key = "ENEMY_SHADOW_ARCHER",
			image = "encyclopedia_creeps_0011",
			layout = N_ENEMY
		},
		enemy_dark_knight = {
			icon = "alert_creep_notxt_0012",
			i18n_key = "ENEMY_DARK_KNIGHT",
			image = "encyclopedia_creeps_0012",
			layout = N_ENEMY
		},
		enemy_wolf_small = {
			icon = "alert_creep_notxt_0013",
			i18n_key = "ENEMY_WULF",
			image = "encyclopedia_creeps_0013",
			layout = N_ENEMY
		},
		enemy_wolf = {
			icon = "alert_creep_notxt_0014",
			i18n_key = "ENEMY_WORG",
			image = "encyclopedia_creeps_0014",
			layout = N_ENEMY
		},
		enemy_whitewolf = {
			icon = "alert_creep_notxt_0015",
			i18n_key = "ENEMY_WHITE_WOLF",
			image = "encyclopedia_creeps_0016",
			layout = N_ENEMY
		},
		enemy_troll = {
			icon = "alert_creep_notxt_0016",
			i18n_key = "ENEMY_TROLL",
			image = "encyclopedia_creeps_0017",
			layout = N_ENEMY
		},
		enemy_troll_axe_thrower = {
			icon = "alert_creep_notxt_0017",
			i18n_key = "ENEMY_TROLL_AXE_THROWER",
			image = "encyclopedia_creeps_0018",
			layout = N_ENEMY
		},
		enemy_troll_chieftain = {
			icon = "alert_creep_notxt_0018",
			i18n_key = "ENEMY_TROLL_CHIEFTAIN",
			image = "encyclopedia_creeps_0019",
			layout = N_ENEMY
		},
		enemy_yeti = {
			icon = "alert_creep_notxt_0019",
			i18n_key = "ENEMY_YETI",
			image = "encyclopedia_creeps_0020",
			layout = N_ENEMY
		},
		enemy_rocketeer = {
			icon = "alert_creep_notxt_0020",
			i18n_key = "ENEMY_ROCKETEER",
			image = "encyclopedia_creeps_0021",
			layout = N_ENEMY
		},
		enemy_slayer = {
			icon = "alert_creep_notxt_0021",
			i18n_key = "ENEMY_SLAYER",
			image = "encyclopedia_creeps_0022",
			layout = N_ENEMY
		},
		enemy_demon = {
			icon = "alert_creep_notxt_0022",
			i18n_key = "ENEMY_DEMON",
			image = "encyclopedia_creeps_0023",
			layout = N_ENEMY
		},
		enemy_demon_mage = {
			icon = "alert_creep_notxt_0023",
			i18n_key = "ENEMY_DEMON_MAGE",
			image = "encyclopedia_creeps_0024",
			layout = N_ENEMY
		},
		enemy_demon_wolf = {
			icon = "alert_creep_notxt_0024",
			i18n_key = "ENEMY_DEMON_WOLF",
			image = "encyclopedia_creeps_0025",
			layout = N_ENEMY
		},
		enemy_demon_imp = {
			icon = "alert_creep_notxt_0025",
			i18n_key = "ENEMY_DEMON_IMP",
			image = "encyclopedia_creeps_0026",
			layout = N_ENEMY
		},
		enemy_necromancer = {
			icon = "alert_creep_notxt_0028",
			i18n_key = "ENEMY_NECROMANCER",
			image = "encyclopedia_creeps_0029",
			layout = N_ENEMY
		},
		enemy_lava_elemental = {
			icon = "alert_creep_notxt_0029",
			i18n_key = "ENEMY_LAVA_ELEMENTAL",
			image = "encyclopedia_creeps_0030",
			layout = N_ENEMY
		},
		enemy_sarelgaz_small = {
			icon = "alert_creep_notxt_0030",
			i18n_key = "ENEMY_SARELGAZ_SMALL",
			image = "encyclopedia_creeps_0031",
			layout = N_ENEMY
		},
		enemy_orc_armored = {
			icon = "alert_creep_notxt_0031",
			i18n_key = "ENEMY_ORC_ARMORED",
			image = "encyclopedia_creeps_0036",
			layout = N_ENEMY
		},
		enemy_orc_rider = {
			icon = "alert_creep_notxt_0032",
			i18n_key = "ENEMY_ORC_RIDER",
			image = "encyclopedia_creeps_0037",
			layout = N_ENEMY
		},
		enemy_goblin_zapper = {
			icon = "alert_creep_notxt_0033",
			i18n_key = "ENEMY_GOBLIN_ZAPPER",
			image = "encyclopedia_creeps_0038",
			layout = N_ENEMY
		},
		enemy_forest_troll = {
			icon = "alert_creep_notxt_0034",
			i18n_key = "ENEMY_FOREST_TROLL",
			image = "encyclopedia_creeps_0039",
			layout = N_ENEMY
		},
		enemy_zombie = {
			icon = "alert_creep_notxt_0035",
			i18n_key = "ENEMY_ZOMBIE",
			image = "encyclopedia_creeps_0041",
			layout = N_ENEMY
		},
		enemy_spider_rotten = {
			icon = "alert_creep_notxt_0036",
			i18n_key = "ENEMY_SPIDER_ROTTEN",
			image = "encyclopedia_creeps_0042",
			layout = N_ENEMY
		},
		enemy_rotten_tree = {
			icon = "alert_creep_notxt_0037",
			i18n_key = "ENEMY_ROTTEN_TREE",
			image = "encyclopedia_creeps_0043",
			layout = N_ENEMY
		},
		enemy_swamp_thing = {
			icon = "alert_creep_notxt_0038",
			i18n_key = "ENEMY_SWAMP_THING",
			image = "encyclopedia_creeps_0044",
			layout = N_ENEMY
		},
		enemy_raider = {
			icon = "alert_creep_notxt_0039",
			i18n_key = "ENEMY_RAIDER",
			image = "encyclopedia_creeps_0046",
			layout = N_ENEMY
		},
		enemy_pillager = {
			icon = "alert_creep_notxt_0040",
			i18n_key = "ENEMY_PILLAGER",
			image = "encyclopedia_creeps_0047",
			layout = N_ENEMY
		},
		enemy_troll_skater = {
			icon = "alert_creep_notxt_0041",
			i18n_key = "ENEMY_TROLL_SKATER",
			image = "encyclopedia_creeps_0050",
			layout = N_ENEMY
		},
		enemy_troll_brute = {
			icon = "alert_creep_notxt_0042",
			i18n_key = "ENEMY_TROLL_BRUTE",
			image = "encyclopedia_creeps_0051",
			layout = N_ENEMY
		},
		enemy_demon_gulaemon = {
			icon = "alert_creep_notxt_0043",
			i18n_key = "ENEMY_DEMON_GULAEMON",
			image = "encyclopedia_creeps_0053",
			layout = N_ENEMY
		},
		enemy_demon_flareon = {
			icon = "alert_creep_notxt_0044",
			i18n_key = "ENEMY_DEMON_FLAREON",
			image = "encyclopedia_creeps_0054",
			layout = N_ENEMY
		},
		enemy_demon_cerberus = {
			icon = "alert_creep_notxt_0045",
			i18n_key = "ENEMY_DEMON_CERBERUS",
			image = "encyclopedia_creeps_0055",
			layout = N_ENEMY
		},
		enemy_demon_legion = {
			icon = "alert_creep_notxt_0046",
			i18n_key = "ENEMY_DEMON_LEGION",
			image = "encyclopedia_creeps_0056",
			layout = N_ENEMY
		},
		enemy_rotten_lesser = {
			icon = "alert_creep_notxt_0047",
			i18n_key = "ENEMY_ROTTEN_LESSER",
			image = "encyclopedia_creeps_0058",
			layout = N_ENEMY
		},
		enemy_halloween_zombie = {
			icon = "alert_creep_notxt_0048",
			i18n_key = "ENEMY_HALLOWEEN_ZOMBIE",
			image = "encyclopedia_creeps_0060",
			layout = N_ENEMY
		},
		enemy_giant_rat = {
			icon = "alert_creep_notxt_0049",
			i18n_key = "ENEMY_GIANT_RAT",
			image = "encyclopedia_creeps_0061",
			layout = N_ENEMY
		},
		enemy_wererat = {
			icon = "alert_creep_notxt_0050",
			i18n_key = "ENEMY_WERERAT",
			image = "encyclopedia_creeps_0062",
			layout = N_ENEMY
		},
		enemy_fallen_knight = {
			icon = "alert_creep_notxt_0051",
			i18n_key = "ENEMY_FALLEN_KNIGHT",
			image = "encyclopedia_creeps_0063",
			layout = N_ENEMY
		},
		enemy_spectral_knight = {
			icon = "alert_creep_notxt_0052",
			i18n_key = "ENEMY_SPECTRAL_KNIGHT",
			image = "encyclopedia_creeps_0064",
			layout = N_ENEMY
		},
		enemy_abomination = {
			icon = "alert_creep_notxt_0053",
			i18n_key = "ENEMY_ABOMINATION",
			image = "encyclopedia_creeps_0065",
			layout = N_ENEMY
		},
		enemy_witch = {
			icon = "alert_creep_notxt_0054",
			i18n_key = "ENEMY_WITCH",
			image = "encyclopedia_creeps_0066",
			layout = N_ENEMY
		},
		enemy_werewolf = {
			icon = "alert_creep_notxt_0055",
			i18n_key = "ENEMY_WEREWOLF",
			image = "encyclopedia_creeps_0067",
			layout = N_ENEMY
		},
		enemy_lycan = {
			icon = "alert_creep_notxt_0056",
			i18n_key = "ENEMY_LYCAN",
			image = "encyclopedia_creeps_0068",
			layout = N_ENEMY
		},
        		enemy_bouncer = {
			image = "encyclopedia_creeps_0201",
			icon = "kr2_alert_creep_notxt_0001",
			layout = N_ENEMY,
			icon_signals = {
				{
					"show-balloon",
					"TB_NOTI"
				}
			}
		},
		enemy_desert_raider = {
			image = "encyclopedia_creeps_0202",
			icon = "kr2_alert_creep_notxt_0002",
			layout = N_ENEMY
		},
		enemy_immortal = {
			image = "encyclopedia_creeps_0203",
			icon = "kr2_alert_creep_notxt_0003",
			layout = N_ENEMY
		},
		enemy_desert_wolf = {
			image = "encyclopedia_creeps_0209",
			icon = "kr2_alert_creep_notxt_0008",
			layout = N_ENEMY
		},
		enemy_desert_wolf_small = {
			image = "encyclopedia_creeps_0208",
			icon = "kr2_alert_creep_notxt_0007",
			layout = N_ENEMY
		},
		enemy_executioner = {
			image = "encyclopedia_creeps_0205",
			icon = "kr2_alert_creep_notxt_0005",
			layout = N_ENEMY
		},
		enemy_scorpion = {
			image = "encyclopedia_creeps_0211",
			icon = "kr2_alert_creep_notxt_0010",
			layout = N_ENEMY
		},
		enemy_wasp = {
			image = "encyclopedia_creeps_0212",
			icon = "kr2_alert_creep_notxt_0011",
			layout = N_ENEMY
		},
		enemy_wasp_queen = {
			image = "encyclopedia_creeps_0213",
			icon = "kr2_alert_creep_notxt_0012",
			layout = N_ENEMY
		},
		enemy_munra = {
			image = "encyclopedia_creeps_0206",
			icon = "kr2_alert_creep_notxt_0006",
			layout = N_ENEMY
		},
		enemy_tremor = {
			image = "encyclopedia_creeps_0210",
			icon = "kr2_alert_creep_notxt_0009",
			layout = N_ENEMY
		},
		enemy_desert_archer = {
			image = "encyclopedia_creeps_0204",
			icon = "kr2_alert_creep_notxt_0004",
			layout = N_ENEMY
		},
		enemy_jungle_spider_small = {
			image = "encyclopedia_creeps_0216",
			icon = "kr2_alert_creep_notxt_0013",
			layout = N_ENEMY
		},
		enemy_jungle_spider_big = {
			image = "encyclopedia_creeps_0217",
			icon = "kr2_alert_creep_notxt_0014",
			layout = N_ENEMY
		},
		enemy_jungle_spider_tiny = {
			image = "encyclopedia_creeps_0217",
			icon = "kr2_alert_creep_notxt_0001",
			layout = N_ENEMY
		},
		enemy_gorilla = {
			image = "encyclopedia_creeps_0225",
			icon = "kr2_alert_creep_notxt_0021",
			layout = N_ENEMY
		},
		enemy_savage_bird = {
			image = "encyclopedia_creeps_0226",
			icon = "kr2_alert_creep_notxt_0022",
			layout = N_ENEMY
		},
		enemy_savage_bird_rider = {
			image = "encyclopedia_creeps_0226",
			icon = "kr2_alert_creep_notxt_0022",
			layout = N_ENEMY
		},
		enemy_cannibal = {
			image = "encyclopedia_creeps_0218",
			icon = "kr2_alert_creep_notxt_0015",
			layout = N_ENEMY
		},
		enemy_hunter = {
			image = "encyclopedia_creeps_0219",
			icon = "kr2_alert_creep_notxt_0016",
			layout = N_ENEMY
		},
		enemy_shaman_necro = {
			image = "encyclopedia_creeps_0223",
			icon = "kr2_alert_creep_notxt_0020",
			layout = N_ENEMY
		},
		enemy_shaman_priest = {
			image = "encyclopedia_creeps_0220",
			icon = "kr2_alert_creep_notxt_0017",
			layout = N_ENEMY
		},
		enemy_shaman_magic = {
			image = "encyclopedia_creeps_0222",
			icon = "kr2_alert_creep_notxt_0019",
			layout = N_ENEMY
		},
		enemy_shaman_shield = {
			image = "encyclopedia_creeps_0221",
			icon = "kr2_alert_creep_notxt_0018",
			layout = N_ENEMY
		},
		enemy_alien_breeder = {
			image = "encyclopedia_creeps_0227",
			icon = "kr2_alert_creep_notxt_0023",
			layout = N_ENEMY
		},
		enemy_alien_reaper = {
			image = "encyclopedia_creeps_0228",
			icon = "kr2_alert_creep_notxt_0024",
			layout = N_ENEMY
		},
		enemy_brute = {
			image = "encyclopedia_creeps_0232",
			icon = "kr2_alert_creep_notxt_0028",
			layout = N_ENEMY
		},
		enemy_broodguard = {
			image = "encyclopedia_creeps_0229",
			icon = "kr2_alert_creep_notxt_0025",
			layout = N_ENEMY
		},
		enemy_darter = {
			image = "encyclopedia_creeps_0231",
			icon = "kr2_alert_creep_notxt_0027",
			layout = N_ENEMY
		},
		enemy_myrmidon = {
			image = "encyclopedia_creeps_0233",
			icon = "kr2_alert_creep_notxt_0029",
			layout = N_ENEMY
		},
		enemy_razorwing = {
			image = "encyclopedia_creeps_0236",
			icon = "kr2_alert_creep_notxt_0033",
			layout = N_ENEMY
		},
		enemy_quetzal = {
			image = "encyclopedia_creeps_0235",
			icon = "kr2_alert_creep_notxt_0031",
			layout = N_ENEMY
		},
		enemy_nightscale = {
			image = "encyclopedia_creeps_0234",
			icon = "kr2_alert_creep_notxt_0030",
			layout = N_ENEMY
		},
		enemy_savant = {
			image = "encyclopedia_creeps_0237",
			icon = "kr2_alert_creep_notxt_0032",
			layout = N_ENEMY
		},
		enemy_blazefang = {
			image = "encyclopedia_creeps_0230",
			icon = "kr2_alert_creep_notxt_0026",
			layout = N_ENEMY
		},
		enemy_greenfin = {
			image = "encyclopedia_creeps_0244",
			icon = "kr2_alert_creep_notxt_0034",
			layout = N_ENEMY
		},
		enemy_redspine = {
			image = "encyclopedia_creeps_0246",
			icon = "kr2_alert_creep_notxt_0038",
			layout = N_ENEMY
		},
		enemy_blacksurge = {
			image = "encyclopedia_creeps_0245",
			icon = "kr2_alert_creep_notxt_0037",
			layout = N_ENEMY
		},
		enemy_deviltide_shark = {
			image = "encyclopedia_creeps_0247",
			icon = "kr2_alert_creep_notxt_0039",
			layout = N_ENEMY
		},
		enemy_bluegale = {
			image = "encyclopedia_creeps_0243",
			icon = "kr2_alert_creep_notxt_0036",
			layout = N_ENEMY
		},
		enemy_bloodshell = {
			image = "encyclopedia_creeps_0242",
			icon = "kr2_alert_creep_notxt_0035",
			layout = N_ENEMY
		},
		enemy_ghoul = {
			image = "encyclopedia_creeps_0256",
			icon = "kr2_alert_creep_notxt_0048",
			layout = N_ENEMY
		},
		enemy_bat = {
			image = "encyclopedia_creeps_0249",
			icon = "kr2_alert_creep_notxt_0041",
			layout = N_ENEMY
		},
		enemy_ghost = {
			image = "encyclopedia_creeps_0252",
			icon = "kr2_alert_creep_notxt_0044",
			layout = N_ENEMY
		},
		enemy_phantom_warrior = {
			image = "encyclopedia_creeps_0251",
			icon = "kr2_alert_creep_notxt_0043",
			layout = N_ENEMY
		},
		enemy_elvira = {
			image = "encyclopedia_creeps_0258",
			icon = "kr2_alert_creep_notxt_0049",
			layout = N_ENEMY
		},
		enemy_sniper = {
			image = "encyclopedia_creeps_0259",
			icon = "kr2_alert_creep_notxt_0050",
			layout = N_ENEMY
		},
        		enemy_gnoll_reaver = {
			image = "encyclopedia_creeps_0301",
			icon = "kr3_alert_creep_notxt_0001",
			layout = N_ENEMY,
			icon_signals = {
				{
					"show-balloon",
					"TB_NOTI",
					1
				}
			}
		},
		enemy_gnoll_burner = {
			image = "encyclopedia_creeps_0302",
			icon = "kr3_alert_creep_notxt_0002",
			layout = N_ENEMY
		},
		enemy_gnoll_gnawer = {
			image = "encyclopedia_creeps_0303",
			icon = "kr3_alert_creep_notxt_0003",
			layout = N_ENEMY
		},
		enemy_hyena = {
			image = "encyclopedia_creeps_0307",
			icon = "kr3_alert_creep_notxt_0007",
			layout = N_ENEMY
		},
		enemy_perython = {
			image = "encyclopedia_creeps_0306",
			icon = "kr3_alert_creep_notxt_0006",
			layout = N_ENEMY
		},
		enemy_gnoll_blighter = {
			image = "encyclopedia_creeps_0304",
			icon = "kr3_alert_creep_notxt_0004",
			layout = N_ENEMY
		},
		enemy_ettin = {
			image = "encyclopedia_creeps_0305",
			icon = "kr3_alert_creep_notxt_0005",
			layout = N_ENEMY
		},
		enemy_twilight_elf_harasser = {
			image = "encyclopedia_creeps_0308",
			icon = "kr3_alert_creep_notxt_0008",
			layout = N_ENEMY
		},
		enemy_sword_spider = {
			image = "encyclopedia_creeps_0310",
			icon = "kr3_alert_creep_notxt_0010",
			layout = N_ENEMY
		},
		enemy_satyr_cutthroat = {
			image = "encyclopedia_creeps_0312",
			icon = "kr3_alert_creep_notxt_0012",
			layout = N_ENEMY
		},
		enemy_satyr_hoplite = {
			image = "encyclopedia_creeps_0313",
			icon = "kr3_alert_creep_notxt_0013",
			layout = N_ENEMY
		},
		enemy_webspitting_spider = {
			image = "encyclopedia_creeps_0318",
			icon = "kr3_alert_creep_notxt_0018",
			layout = N_ENEMY
		},
		enemy_gloomy = {
			image = "encyclopedia_creeps_0317",
			icon = "kr3_alert_creep_notxt_0017",
			layout = N_ENEMY
		},
		enemy_twilight_scourger = {
			image = "encyclopedia_creeps_0311",
			icon = "kr3_alert_creep_notxt_0011",
			layout = N_ENEMY
		},
		enemy_bandersnatch = {
			image = "encyclopedia_creeps_0316",
			icon = "kr3_alert_creep_notxt_0016",
			layout = N_ENEMY
		},
		enemy_redcap = {
			image = "encyclopedia_creeps_0314",
			icon = "kr3_alert_creep_notxt_0014",
			layout = N_ENEMY
		},
		enemy_twilight_avenger = {
			image = "encyclopedia_creeps_0309",
			icon = "kr3_alert_creep_notxt_0009",
			layout = N_ENEMY
		},
		enemy_boomshrooms = {
			image = "encyclopedia_creeps_0332",
			icon = "kr3_alert_creep_notxt_0030",
			layout = N_ENEMY
		},
		enemy_munchshrooms = {
			image = "encyclopedia_creeps_0331",
			icon = "kr3_alert_creep_notxt_0029",
			layout = N_ENEMY
		},
		enemy_shroom_breeder = {
			image = "encyclopedia_creeps_0315",
			icon = "kr3_alert_creep_notxt_0015",
			layout = N_ENEMY
		},
		enemy_razorboar = {
			image = "encyclopedia_creeps_0323",
			icon = "kr3_alert_creep_notxt_0023",
			layout = N_ENEMY
		},
		enemy_twilight_evoker = {
			image = "encyclopedia_creeps_0321",
			icon = "kr3_alert_creep_notxt_0021",
			layout = N_ENEMY
		},
		enemy_twilight_golem = {
			image = "encyclopedia_creeps_0325",
			icon = "kr3_alert_creep_notxt_0025",
			layout = N_ENEMY
		},
		enemy_mantaray = {
			image = "encyclopedia_creeps_0328",
			icon = "kr3_alert_creep_notxt_0026",
			layout = N_ENEMY
		},
		enemy_spider_arachnomancer = {
			image = "encyclopedia_creeps_0330",
			icon = "kr3_alert_creep_notxt_0028",
			layout = N_ENEMY
		},
		enemy_twilight_heretic = {
			image = "encyclopedia_creeps_0324",
			icon = "kr3_alert_creep_notxt_0024",
			layout = N_ENEMY
		},
		enemy_spider_son_of_mactans = {
			image = "encyclopedia_creeps_0329",
			icon = "kr3_alert_creep_notxt_0027",
			layout = N_ENEMY
		},
		enemy_arachnomancer = {
			image = "encyclopedia_creeps_0322",
			icon = "kr3_alert_creep_notxt_0022",
			layout = N_ENEMY
		},
		enemy_drider = {
			image = "encyclopedia_creeps_0320",
			icon = "kr3_alert_creep_notxt_0020",
			layout = N_ENEMY
		},
		enemy_gnoll_bloodsydian = {
			image = "encyclopedia_creeps_0335",
			icon = "kr3_alert_creep_notxt_0031",
			layout = N_ENEMY
		},
		enemy_bloodsydian_warlock = {
			image = "encyclopedia_creeps_0337",
			icon = "kr3_alert_creep_notxt_0033",
			layout = N_ENEMY
		},
		enemy_ogre_magi = {
			image = "encyclopedia_creeps_0336",
			icon = "kr3_alert_creep_notxt_0032",
			layout = N_ENEMY
		},
		enemy_blood_servant = {
			image = "encyclopedia_creeps_0339",
			icon = "kr3_alert_creep_notxt_0034",
			layout = N_ENEMY
		},
		enemy_screecher_bat = {
			image = "encyclopedia_creeps_0341",
			icon = "kr3_alert_creep_notxt_0036",
			layout = N_ENEMY
		},
		enemy_mounted_avenger = {
			image = "encyclopedia_creeps_0340",
			icon = "kr3_alert_creep_notxt_0035",
			layout = N_ENEMY
		},
		enemy_shadows_spawns = {
			image = "encyclopedia_creeps_0344",
			icon = "kr3_alert_creep_notxt_0037",
			layout = N_ENEMY
		},
		enemy_grim_devourers = {
			image = "encyclopedia_creeps_0346",
			icon = "kr3_alert_creep_notxt_0039",
			layout = N_ENEMY
		},
		enemy_dark_spitters = {
			image = "encyclopedia_creeps_0345",
			icon = "kr3_alert_creep_notxt_0038",
			layout = N_ENEMY
		},
		enemy_shadow_champion = {
			image = "encyclopedia_creeps_0347",
			icon = "kr3_alert_creep_notxt_0040",
			layout = N_ENEMY
		},
		TOWER_ARCHER_ARCANE = {
			prefix = "TOWER_ARCANE",
			always = true,
			sub = "TOWER_ARCHERS_SUBTITLE",
			image = "encyclopedia_towers_0317",
			layout = N_TOWER,
			seen = {
				"tower_arcane"
			}
		},
		TOWER_BARRACK_BLADE = {
			prefix = "TOWER_BARRACKS_BLADE",
			always = true,
			sub = "TOWER_BARRACKS_SUBTITLE",
			image = "encyclopedia_towers_0320",
			layout = N_TOWER,
			seen = {
				"tower_blade"
			}
		},
		TOWER_MAGE_WILD_MAGUS = {
			prefix = "TOWER_MAGE_WILD_MAGUS",
			always = true,
			sub = "TOWER_MAGES_SUBTITLE",
			image = "encyclopedia_towers_0316",
			layout = N_TOWER,
			seen = {
				"tower_wild_magus"
			}
		},
		TOWER_ROCK_THROWER_STONE_DRUID = {
			prefix = "TOWER_STONE_DRUID",
			always = true,
			sub = "TOWER_ROCK_THROWER_SUBTITLE",
			image = "encyclopedia_towers_0313",
			layout = N_TOWER,
			seen = {
				"tower_druid"
			}
		},
		TOWER_MAGE_HIGH_ELVEN = {
			prefix = "TOWER_MAGE_HIGH_ELVEN",
			always = true,
			sub = "TOWER_MAGES_SUBTITLE",
			image = "encyclopedia_towers_0315",
			layout = N_TOWER,
			seen = {
				"tower_high_elven"
			}
		},
		TOWER_ROCK_THROWER_ENTWOOD = {
			prefix = "TOWER_ENTWOOD",
			always = true,
			sub = "TOWER_ROCK_THROWER_SUBTITLE",
			image = "encyclopedia_towers_0314",
			layout = N_TOWER,
			seen = {
				"tower_entwood"
			}
		},
		TOWER_ARCHER_SILVER = {
			always = true,
			layout = N_TOWER_2,
			images = {
				"encyclopedia_towers_0318",
				"encyclopedia_towers_0319"
			},
			prefixes = {
				"TOWER_SILVER",
				"TOWER_FOREST_KEEPERS"
			},
			subs = {
				"TOWER_ARCHERS_SUBTITLE",
				"TOWER_BARRACKS_SUBTITLE"
			},
			seen = {
				"tower_silver",
				"tower_forest"
			}
		},
		TOWER_DWAARP = {
			prefix = "TOWER_DWAARP",
			always = true,
			sub = "TOWER_ENGINEERS_SUBTITLE",
			image = "encyclopedia_towers_0216",
			layout = N_TOWER,
			seen = {
				"tower_dwaarp"
			}
		},
		TOWER_ARCHMAGE = {
			prefix = "TOWER_ARCHMAGE",
			always = true,
			sub = "TOWER_MAGES_SUBTITLE",
			image = "encyclopedia_towers_0215",
			layout = N_TOWER,
			seen = {
				"tower_archmage"
			}
		},
		TOWER_TEMPLARS = {
			prefix = "TOWER_TEMPLAR",
			always = true,
			sub = "TOWER_BARRACKS_SUBTITLE",
			image = "encyclopedia_towers_0218",
			layout = N_TOWER,
			seen = {
				"tower_templar"
			}
		},
		TOWER_TOTEM = {
			prefix = "TOWER_TOTEM",
			always = true,
			sub = "TOWER_ARCHERS_SUBTITLE",
			image = "encyclopedia_towers_0217",
			layout = N_TOWER,
			seen = {
				"tower_totem"
			}
		},
		TOWER_NECROMANCER = {
			prefix = "TOWER_NECROMANCER",
			always = true,
			sub = "TOWER_MAGES_SUBTITLE",
			image = "encyclopedia_towers_0219",
			layout = N_TOWER,
			seen = {
				"tower_necromancer"
			}
		},
		TOWER_MECH = {
			prefix = "TOWER_MECH",
			always = true,
			sub = "TOWER_ENGINEERS_SUBTITLE",
			image = "encyclopedia_towers_0220",
			layout = N_TOWER,
			seen = {
				"tower_mech"
			}
		},
		TOWER_ASSASINS_CROSSBOW = {
			always = true,
			layout = N_TOWER_2,
			images = {
				"encyclopedia_towers_0214",
				"encyclopedia_towers_0213"
			},
			prefixes = {
				"TOWER_ASSASSIN",
				"TOWER_CROSSBOW"
			},
			subs = {
				"TOWER_BARRACKS_SUBTITLE",
				"TOWER_ARCHERS_SUBTITLE"
			},
			seen = {
				"tower_assassin",
				"tower_crossbow"
			}
		},
		TOWER_MUSKETEER = {
			prefix = "TOWER_MUSKETEERS",
			always = true,
			sub = "TOWER_ARCHERS_SUBTITLE",
			image = "encyclopedia_towers_0017",
			layout = N_TOWER,
			seen = {
				"tower_musketeer"
			}
		},
		TOWER_RANGER = {
			prefix = "TOWER_RANGERS",
			always = true,
			sub = "TOWER_ARCHERS_SUBTITLE",
			image = "encyclopedia_towers_0013",
			layout = N_TOWER,
			seen = {
				"tower_ranger"
			}
		},
		TOWER_SORCERER = {
			prefix = "TOWER_SORCERER",
			always = true,
			sub = "TOWER_MAGES_SUBTITLE",
			image = "encyclopedia_towers_0019",
			layout = N_TOWER,
			seen = {
				"tower_sorcerer"
			}
		},
		TOWER_TESLA = {
			prefix = "TOWER_TESLA",
			always = true,
			sub = "TOWER_ENGINEERS_SUBTITLE",
			image = "encyclopedia_towers_0020",
			layout = N_TOWER,
			seen = {
				"tower_tesla"
			}
		},
		TOWER_BARBARIAN_BGF = {
			always = true,
			layout = N_TOWER_2,
			images = {
				"encyclopedia_towers_0018",
				"encyclopedia_towers_0016"
			},
			prefixes = {
				"TOWER_BARBARIANS",
				"TOWER_BFG"
			},
			subs = {
				"TOWER_BARRACKS_SUBTITLE",
				"TOWER_ENGINEERS_SUBTITLE"
			},
			seen = {
				"tower_barbarian",
				"tower_bgf"
			}
		},
		TOWER_PALADIN = {
			always = true,
			layout = N_TOWER_2,
			images = {
				"encyclopedia_towers_0015",
				"encyclopedia_towers_0014"
			},
			prefixes = {
				"TOWER_ARCANE",
				"TOWER_PALADINS"
			},
			subs = {
				"TOWER_MAGES_SUBTITLE",
				"TOWER_BARRACKS_SUBTITLE"
			},
			seen = {
				"tower_arcane",
				"tower_paladins"
			}
		},
		TOWER_LEVEL2 = {
			always = true,
			level = 2,
			layout = N_TOWER_4,
			images = {
				"encyclopedia_towers_0006",
				"encyclopedia_towers_0005",
				"encyclopedia_towers_0007",
				"encyclopedia_towers_0008"
			},
			seen = {
				"tower_barrack_2",
				"tower_archer_2",
				"tower_mage_2",
				"tower_engineer_2"
			}
		},
		TOWER_LEVEL3 = {
			always = true,
			level = 3,
			layout = N_TOWER_4,
			images = {
				"encyclopedia_towers_0010",
				"encyclopedia_towers_0009",
				"encyclopedia_towers_0011",
				"encyclopedia_towers_0012"
			},
			seen = {
				"tower_barrack_3",
				"tower_archer_3",
				"tower_mage_3",
				"tower_engineer_3"
			}
		},
		TIP_ARMOR = {
			paper = "notifications_tips_slides_notxt_0001",
			always = true,
			ach_flag = 1,
			icon = "alert_tip_notxt_0002",
			layout = N_TIP
		},
		TIP_RALLY = {
			paper = "notifications_tips_slides_notxt_0003",
			always = true,
			ach_flag = 2,
			icon = "alert_tip_notxt_0001",
			layout = N_TIP
		},
		TIP_ARMOR_MAGIC = {
			paper = "notifications_tips_slides_notxt_0002",
			always = true,
			ach_flag = 4,
			icon = "alert_tip_notxt_0003",
			layout = N_TIP
		},
		TIP_STRATEGY = {
			paper = "notifications_tips_slides_notxt_0004",
			always = true,
			ach_flag = 8,
			icon = "alert_tip_notxt_0004",
			layout = N_TIP
		},
		TIP_ARMOR_HARD = {
			paper = "notifications_tips_slides_notxt_0005",
			always = true,
			ach_flag = 4,
			icon = "alert_tip_notxt_0005",
			layout = N_TIP
		},
		TIP_HEROES = {
			icon = "alert_tip_notxt_0006",
			paper = "notifications_tips_slides_notxt_0007",
			always = true,
			layout = N_TIP
		},
		TIP_UPGRADES = {
			icon = "alert_tip_notxt_0005",
			paper = "notifications_tips_slides_notxt_0006",
			layout = N_TIP
		},
		TIP_ELITE = {
			icon = "alert_tip_notxt_0005",
			paper = "notifications_tips_slides_notxt_0008",
			layout = N_TIP
		},
		POWER_FIREBALL = {
			prefix = "POWER_FIREBALL",
			always = true,
			image = "tutorial_powers_polaroids_0002",
			layout = N_POWER,
			signals = {
				{
					"show-balloon",
					"TB_POWER1"
				},
				{
					"unlock-user-power",
					1
				}
			}
		},
		POWER_REINFORCEMENT = {
			prefix = "POWER_REINFORCEMENTS",
			always = true,
			image = "tutorial_powers_polaroids_0001",
			layout = N_POWER,
			signals = {
				{
					"show-balloon",
					"TB_POWER2"
				},
				{
					"unlock-user-power",
					2
				}
			}
		},
		TUTORIAL_1 = {
			next = "TUTORIAL_2",
			paper = "tutorial_slide1_notxt",
			always = true,
			layout = N_TUTORIAL
		},
		TUTORIAL_2 = {
			next = "TUTORIAL_3",
			paper = "tutorial_slide2_notxt",
			always = true,
			layout = N_TUTORIAL
		},
		TUTORIAL_3 = {
			always = true,
			paper = "tutorial_slide3_notxt",
			layout = N_TUTORIAL
		}
	},
	tutorial_balloons = {
		TB_BUILD = {
			origin = "world",
			image = "balloon_buildhere_bg",
			hide_cond = "tower_built",
			offset = v(383, 440)
		},
		TB_POWER1 = {
			hide_cond = "power_selected_1",
			balloon = "TB_ROAD",
			origin = "bottom-left",
			image = "balloon_newpower_bg",
			offset = v(251, -104)
		},
		TB_POWER2 = {
			hide_cond = "power_selected_2",
			balloon = "TB_ROAD",
			origin = "bottom-left",
			image = "balloon_newpower_bg",
			offset = v(317, -104)
		},
		TB_ROAD = {
			origin = "world",
			image = "balloon_taphere_bg",
			hide_cond = "power_used",
			offset = v(283, 350)
		},
		TB_NOTI = {
			origin = "top-left",
			image = "balloon_clickhere_bg",
			hide_cond = "noti_shown",
			offset = v(238, 105)
		},
		TB_START = {
			origin = "bottom-right",
			image = "balloon_startbattle_bg",
			hide_cond = "wave_sent",
			offset = v(-120, -88)
		},
		TB_WAVE = {
			origin = "world",
			image = "balloon_nextwave_bg",
			hide_cond = "wave_sent",
			offset = v(650, 720)
		}
	},
	notification_slides = {
		TB_BUILD = {
			{
				vertical_align = "middle",
				fit_lines = 1,
				text = "BUILD HERE!",
				text_align = "center",
				pos = v(10, 6),
				size = v(160, 36),
				font_size = CJK(20, 24, nil, 28)
			}
		},
		TB_POWER1 = {
			{
				vertical_align = "middle",
				fit_lines = 1,
				text = "NEW POWER!",
				text_align = "center",
				pos = v(13, 6),
				size = v(156, 36),
				font_size = CJK(20, 24, nil, 28)
			}
		},
		TB_POWER2 = {
			{
				vertical_align = "middle",
				fit_lines = 1,
				text = "NEW POWER!",
				text_align = "center",
				pos = v(13, 6),
				size = v(156, 36),
				font_size = CJK(20, 24, nil, 28)
			}
		},
		TB_POWER3 = {
			{
				vertical_align = "middle",
				fit_lines = 1,
				text = "NEW POWER!",
				text_align = "center",
				pos = v(13, 6),
				size = v(156, 36),
				font_size = CJK(20, 24, nil, 28)
			}
		},
		TB_ROAD = {
			{
				vertical_align = "middle",
				fit_lines = 1,
				text = "CLICK ON THE ROAD",
				text_align = "center",
				pos = v(7, 6),
				size = v(176, 36),
				font_size = CJK(18, 21, nil, 25)
			}
		},
		TB_NOTI = {
			{
				vertical_align = "middle",
				fit_lines = 1,
				text = "CLICK HERE!",
				text_align = "center",
				pos = v(27, 7),
				size = v(155, 36),
				font_size = CJK(20, 24, nil, 28)
			}
		},
		TB_START = {
			{
				vertical_align = "middle",
				fit_lines = 2,
				line_height = 0.8,
				text_align = "center",
				text = "START BATTLE!",
				pos = v(8, 6),
				size = v(150, 36),
				font_size = CJK(18, 21, nil, 25)
			}
		},
		TB_WAVE = {
			{
				vertical_align = "middle",
				fit_lines = 1,
				text = "INCOMING NEXT WAVE!",
				text_align = "left",
				pos = v(28, 6),
				size = v(234, 34),
				font_size = CJK(18, 21, nil, 25)
			},
			{
				vertical_align = "middle",
				fit_lines = 1,
				text = "CLICK TO CALL IT EARLY",
				text_align = "left",
				pos = v(28, 40),
				size = v(234, 18),
				font_size = CJK(10, 14, nil, 20)
			}
		},
		TUTORIAL_1 = {
			{
				vertical_align = "middle",
				text = "Objective",
				font_size = 22,
				text_align = "center",
				pos = v(52, 60),
				size = v(380, 30),
				anchor = {
					y = 30
				}
			},
			{
				vertical_align = "middle",
				fit_lines = 1,
				text = "protect your lands from the enemy attacks.",
				font_size = 16,
				text_align = "center",
				line_height = 0.8,
				color = "gray",
				pos = v(47, 58),
				size = v(390, 18)
			},
			{
				vertical_align = "middle",
				fit_lines = 2,
				text = "build defensive towers along the road to stop them.",
				font_size = 12,
				text_align = "center",
				line_height = 0.8,
				color = "gray",
				pos = v(47, 78),
				size = v(390, 26)
			},
			{
				vertical_align = "middle",
				color = "black",
				font_size = 12,
				text_align = "center",
				text = "don't let enemies past this point.",
				pos = v(220, 123),
				size = v(148, 36),
				line_height = CJK(0.8, nil, 1.1)
			},
			{
				vertical_align = "middle",
				color = "black",
				font_size = 10,
				text_align = "center",
				text = "build towers to defend the road.",
				pos = v(270, 231),
				size = v(117, 27),
				line_height = CJK(0.8, nil, 1.1)
			},
			{
				vertical_align = "middle",
				color = "black",
				font_size = 11,
				text_align = "center",
				text = "earn gold by killing enemies.",
				pos = v(178, 274),
				size = v(117, 27),
				line_height = CJK(0.8, nil, 1.1)
			}
		},
		TUTORIAL_2 = {
			{
				text = "Tower construction",
				text_align = "center",
				r = 0,
				font_size = 22,
				pos = v(38, 50),
				size = v(389, 30),
				anchor = {
					y = 30
				}
			},
			{
				text = "Build towers on strategic points to stop the enemy hordes from getting through.",
				color = "gray",
				text_align = "center",
				r = 0,
				font_size = 14,
				pos = v(46, 52),
				size = v(373, 52)
			},
			{
				vertical_align = "middle",
				text_align = "center",
				text = "click these!",
				r = 0.17453292519943,
				font_size = 13,
				color = "dark_red",
				pos = v(26, 126),
				size = v(135, 30),
				line_height = CJK(0.8, nil, 1.1)
			},
			{
				vertical_align = "middle",
				text_align = "center",
				text = "this is a strategic point.",
				r = 0,
				font_size = 11,
				line_height = 0.8,
				color = "dark_red",
				pos = v(35, 195),
				size = v(123, 30)
			},
			{
				vertical_align = "middle",
				text_align = "center",
				text = "select the tower you want to build!",
				r = 0.087266462599716,
				font_size = 10,
				line_height = 0.8,
				color = "dark_red",
				pos = v(154, 244),
				size = v(154, 34)
			},
			{
				vertical_align = "middle",
				text_align = "center",
				text = "wOOt!",
				r = 0.17453292519943,
				font_size = 11,
				line_height = 0.8,
				color = "dark_red",
				pos = v(310, 126),
				size = v(135, 30)
			},
			{
				vertical_align = "middle",
				text_align = "center",
				text = "ready for action!",
				r = 0.17453292519943,
				font_size = 12,
				line_height = 0.8,
				color = "dark_red",
				pos = v(310, 221),
				size = v(135, 30)
			}
		},
		TUTORIAL_3 = {
			{
				text = "Basic Tower Types",
				font_size = 22,
				text_align = "center",
				pos = v(54, 55),
				size = v(482, 28),
				anchor = {
					y = 30
				}
			},
			{
				text = "There are four basic types of towers available.",
				color = "gray",
				fit_lines = 1,
				font_size = 16,
				text_align = "center",
				pos = v(54, 55),
				size = v(482, 22)
			},
			{
				text = "ARCHER TOWER",
				color = "dark_red",
				fit_lines = 1,
				font_size = 14,
				text_align = "center",
				pos = v(24, 94),
				size = v(127, 30)
			},
			{
				text = "BARRACKS",
				color = "dark_red",
				fit_lines = 1,
				font_size = 14,
				text_align = "center",
				pos = v(162, 94),
				size = v(127, 30)
			},
			{
				text = "MAGES’ GUILD",
				color = "dark_red",
				fit_lines = 1,
				font_size = 14,
				text_align = "center",
				pos = v(301, 94),
				size = v(127, 30)
			},
			{
				text = "ARTILLERY",
				color = "dark_red",
				fit_lines = 1,
				font_size = 14,
				text_align = "center",
				pos = v(441, 94),
				size = v(126, 30)
			},
			{
				vertical_align = "middle",
				fit_lines = 3,
				text = "good rate of fire",
				font_size = 12,
				text_align = "center",
				color = "gray",
				pos = v(33, 219),
				size = v(108, 30),
				line_height = CJK(0.7, nil, 1)
			},
			{
				vertical_align = "middle",
				fit_lines = 3,
				text = "soldiers block enemies",
				font_size = 12,
				text_align = "center",
				color = "gray",
				pos = v(170, 218),
				size = v(113, 32),
				line_height = CJK(0.7, nil, 1)
			},
			{
				vertical_align = "middle",
				fit_lines = 3,
				text = "high damage, armor piercing",
				font_size = 12,
				text_align = "center",
				color = "gray",
				pos = v(310, 219),
				size = v(110, 31),
				line_height = CJK(0.7, nil, 1)
			},
			{
				vertical_align = "middle",
				fit_lines = 3,
				text = "deals area damage",
				font_size = 12,
				text_align = "center",
				color = "gray",
				pos = v(450, 218),
				size = v(109, 31),
				line_height = CJK(0.7, nil, 1)
			}
		},
		TIP_ARMOR = {
			{
				text = "ARMORED ENEMIES!",
				fit_lines = 1,
				font_size = 24,
				pos = v(130, 50),
				size = v(320, 30)
			},
			{
				text = "some enemies wear armor of different strengths that protects them against non-magical attacks.",
				font_size = 16,
				fit_lines = 4,
				color = "gray",
				pos = v(130, CJK(80, nil, nil, 91)),
				size = v(320, 80)
			},
			{
				text = "resists damage from",
				text_align = "center",
				font_size = 15,
				color = "red",
				pos = v(113, 170),
				size = v(117, 42)
			},
			{
				text = "Armored enemies take less damage from marksmen, soldiers and artilleries.",
				text_align = "center",
				fit_lines = 3,
				font_size = 18,
				color = "gray",
				pos = v(44, 286),
				size = v(416, 70)
			}
		},
		TIP_ARMOR_MAGIC = {
			{
				text = "MAGIC RESISTANT ENEMIES!",
				fit_lines = 1,
				font_size = 24,
				pos = v(118, 81),
				size = v(337, 30),
				anchor = {
					y = 30
				}
			},
			{
				color = "gray",
				fit_lines = 4,
				text = "some enemies enjoy different levels of magic resistance that protects them against magical attacks.",
				font_size = 16,
				pos = v(118, CJK(78, 84, nil, 91)),
				size = v(338, 80),
				line_height = CJK(0.9, nil, 1)
			},
			{
				text = "resist damage from",
				text_align = "center",
				font_size = 15,
				color = "red",
				pos = v(196, 169),
				size = v(117, 42)
			},
			{
				text = "Magic resistant enemies take less damage from wizards.",
				text_align = "center",
				fit_lines = 3,
				font_size = 18,
				color = "gray",
				pos = v(54, 286),
				size = v(400, 70)
			}
		},
		TIP_RALLY = {
			{
				text = "COMMAND YOUR TROOPS!",
				fit_lines = 1,
				font_size = 24,
				pos = v(118, 83),
				size = v(337, 30),
				anchor = {
					y = 30
				}
			},
			{
				color = "gray",
				fit_lines = 4,
				text = "you can adjust your soldiers rally point to make them defend a different area.",
				font_size = 16,
				pos = v(118, CJK(80, 86, nil, 91)),
				size = v(338, 80),
				line_height = CJK(0.9, nil, 1.1)
			},
			{
				text = "rally range",
				color = "blue",
				font_size = 13,
				text_align = "center",
				pos = v(254, 139),
				size = v(168, 21)
			},
			{
				color = "red",
				text = "select the rally point control",
				font_size = 12,
				text_align = "center",
				pos = v(71, 319),
				size = v(202, 42),
				line_height = CJK(0.9, nil, 1.1)
			},
			{
				color = "red",
				text = "select where you want to move your soldiers",
				font_size = 12,
				text_align = "center",
				pos = v(292, 319),
				size = v(173, 42),
				line_height = CJK(0.9, nil, 1.1)
			}
		},
		TIP_STRATEGY = {
			{
				text = "STRATEGY BASICS!",
				font_size = 24,
				text_align = "center",
				pos = v(53, 64),
				size = v(408, 34),
				anchor = {
					y = 34
				}
			},
			{
				color = "gray",
				fit_lines = 4,
				text = "Barracks are good for blocking the enemy but lack in attack power. Make sure you have enough firepower to support them!",
				font_size = 16,
				pos = v(60, 66),
				size = v(399, 66),
				line_height = CJK(0.9, nil, 1.1)
			},
			{
				vertical_align = "middle",
				text_align = "center",
				text = "Support your soldiers with ranged towers!",
				r = 0.176,
				font_size = 13,
				color = "black",
				pos = v(245, 281),
				size = v(133, 54),
				line_height = CJK(0.8, nil, 1.1)
			}
		},
		TIP_ARMOR_HARD = {
			{
				vertical_align = "middle",
				text = "HEAVILY ARMORED ENEMIES!",
				font_size = 22,
				text_align = "center",
				pos = v(60, 30),
				size = v(392, 54)
			},
			{
				text = "Some enemies wear heavy armor and are almost impervious to physical damage. In order to kill them hit them with magic attacks!",
				font_size = 18,
				text_align = "center",
				pos = v(60, 75),
				size = v(392, 60)
			},
			{
				text = "Use the highest levels of wizards available!",
				font_size = 16,
				text_align = "center",
				pos = v(196, 287),
				size = v(141, 59)
			}
		},
		TIP_HEROES = {
			{
				vertical_align = "middle",
				text = "Hero at your command!",
				font_size = 23,
				text_align = "center",
				pos = v(53, 60),
				size = v(408, 38),
				anchor = {
					y = 38
				}
			},
			{
				fit_lines = 3,
				color = "gray",
				font_size = 15,
				text_align = "center",
				text = "Heroes are elite units that can face strong enemies and support your forces.",
				pos = v(50, 62),
				size = v(408, 44),
				line_height = CJK(0.75, nil, 1.1)
			},
			{
				vertical_align = "middle",
				color = "black",
				font_size = 14,
				text_align = "center",
				text = "Select by clicking on the portrait or hero unit. Hotkey: space bar",
				pos = v(136, 118),
				size = v(189, 49),
				line_height = CJK(0.8, nil, 1.1)
			},
			{
				vertical_align = "middle",
				color = "black",
				font_size = 14,
				text_align = "center",
				text = "Click on the path to move the hero.",
				pos = v(296, 255),
				size = v(146, 40),
				line_height = CJK(0.8, nil, 1.1)
			},
			{
				color = "black",
				text = "Shows level, health and experience.",
				font_size = 15,
				text_align = "center",
				pos = v(37, 224),
				size = v(102, 68),
				line_height = CJK(0.8, nil, 1.1)
			},
			{
				fit_lines = 2,
				color = "gray",
				font_size = 17,
				text_align = "center",
				text = "Heroes gain experience every time they damage an enemy or use an ability.",
				pos = v(54, 310),
				size = v(405, 54),
				line_height = CJK(0.75, nil, 1.1)
			}
		},
		TIP_UPGRADES = {
			{
				vertical_align = "middle",
				text = "UPGRADES AND HEROES RESTRICTIONS!",
				font_size = 25,
				text_align = "left",
				pos = v(114, 35),
				size = v(331, 52)
			},
			{
				text = "iron and heroic challenges may have restrictions on upgrades!",
				font_size = 18,
				text_align = "center",
				pos = v(40, 108),
				size = v(194, 100)
			},
			{
				text = "check the stage description to see:",
				font_size = 17,
				text_align = "left",
				pos = v(48, 288),
				size = v(314, 26)
			},
			{
				text = "- max upgrade level allowed",
				font_size = 16,
				text_align = "left",
				pos = v(50, 310),
				size = v(286, 24)
			},
			{
				text = "- if heroes are allowed",
				font_size = 16,
				text_align = "left",
				pos = v(50, 328),
				size = v(286, 24)
			},
			{
				color = "red",
				text = "max lvl allowed",
				font_size = 10,
				text_align = "center",
				pos = v(400, 316),
				size = v(68, 20),
				line_height = CJK(0.8, nil, 1.1)
			},
			{
				color = "red",
				text = "no heroes",
				font_size = 10,
				text_align = "center",
				pos = v(406, 335),
				size = v(57, 19),
				line_height = CJK(0.8, nil, 1.1)
			}
		},
		TIP_ELITE = {
			{
				vertical_align = "middle",
				color = "red",
				text = "ELITE STAGE!",
				font_size = 28,
				text_align = "center",
				pos = v(60, 37),
				size = v(392, 50)
			},
			{
				text = "This is a stage of extreme difficulty.",
				font_size = 23,
				text_align = "center",
				pos = v(60, 86),
				size = v(392, 60)
			},
			{
				text = "Over 50 stars are recommended to face this stage.",
				font_size = 18,
				text_align = "left",
				pos = v(243, 231),
				size = v(218, 108)
			}
		}
	},
    -- 5,6,7,10,11,12,13,14,15,16,17,18,19,20
	tower_menu_button_places = {
        v(24, 20),
        v(124, 20),
        v(24, 120),
        v(124, 120),
        v(74, 2),
        v(12, 34),
        v(136, 34),
        v(128, 118),
        v(74, 140),
        v(-50, 2),   -- 10
        v(198, 2),
        v(-50, 66),  -- 12
        v(198, 66),
        v(-112,34),
        v(260, 34),
        v(12,-30),
        v(136,-30),
        v(-112, -30),
        v(260, -30),
        v(74, -62),  -- 20
        v(24, 180),
        v(124, 180),
        v(-50, 120),
        v(198, 120),
        v(-112, 90),
        v(260, 90),
        v(74, 200),
        v(12, 200),
        v(136, 200),
        v(-112, 150),
        v(260, 150)  -- 30
    },
	tower_menu_power_places = {
		v(29, 3),
		v(47, 10),
		v(53, 27)
	},
	range_center_offset = v(0, -12),
	damage_icons = {
		default = "base_info_icons_0001",
		magic = "base_info_icons_0002",
		sword = "base_info_icons_0001",
		fireball = "base_info_icons_0002",
		arrow = "base_info_icons_0010",
		shot = "base_info_icons_0011",
		[DAMAGE_TRUE] = "damage_true_icon",
        -- 远程的物理攻击在 game_gui 中额外处理，显示为箭伤
		[DAMAGE_PHYSICAL] = "base_info_icons_0001",
		[DAMAGE_MAGICAL] = "base_info_icons_0002",
        [DAMAGE_MAGICAL_EXPLOSION] = "base_info_icons_0002",
		[DAMAGE_EXPLOSION] = "base_info_icons_0012",
        [DAMAGE_ELECTRICAL] = "base_info_icons_0012",
        [DAMAGE_SHOT] = "base_info_icons_0011",
        [DAMAGE_RUDE] = "damage_rude_icon",
        [DAMAGE_STAB] = "base_info_icons_0010",
        [DAMAGE_MIXED] = "base_info_icons_0001",
	}
}
