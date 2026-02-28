-- chunkname: @./kr1/data/tower_menus_data.lua
local tpl = require("data.tower_menus_data_templates")
local scripts = require("kr1.data.tower_menus_data_scripts")
local M = scripts.merge
local i18n = require("i18n")

return {
	-- 塔位
	holder = {{M(tpl.upgrade, {
		action_arg = "tower_build_archer",
		image = "main_icons_0001",
		place = 1,
		preview = "archer",
		tt_title = _("TOWER_ARCHER_1_NAME"),
		tt_desc = _("TOWER_ARCHER_1_DESCRIPTION")
	}), M(tpl.upgrade, {
		action_arg = "tower_build_barrack",
		image = "main_icons_0002",
		place = 2,
		preview = "barrack",
		tt_title = _("TOWER_BARRACK_1_NAME"),
		tt_desc = _("TOWER_BARRACK_1_DESCRIPTION")
	}), M(tpl.upgrade, {
		action_arg = "tower_build_mage",
		image = "main_icons_0003",
		place = 3,
		preview = "mage",
		tt_title = _("TOWER_MAGE_1_NAME"),
		tt_desc = _("TOWER_MAGE_1_DESCRIPTION")
	}), M(tpl.upgrade, {
		action_arg = "tower_build_engineer",
		image = "main_icons_0004",
		place = 4,
		preview = "engineer",
		tt_title = _("TOWER_ENGINEER_1_NAME"),
		tt_desc = _("TOWER_ENGINEER_1_DESCRIPTION")
	})}},
	holder_blocked_jungle = {{M(tpl.unblock, {
		action_arg = "tower_holder",
		image = "main_icons_0037",
		tt_title = _("SPECIAL_REPAIR_HOLDER_JUNGLE_NAME"),
		tt_desc = _("SPECIAL_REPAIR_HOLDER_JUNGLE_DESCRIPTION")
	})}},
	holder_blocked_underground = {{M(tpl.unblock, {
		action_arg = "tower_holder",
		image = "main_icons_0037",
		tt_title = _("SPECIAL_REPAIR_HOLDER_UNDERGROUND_NAME"),
		tt_desc = _("SPECIAL_REPAIR_HOLDER_UNDERGROUND_DESCRIPTION")
	})}},
	holder_blocked_sea_of_trees = {{M(tpl.unblock, {
		action_arg = "tower_holder",
		image = "main_icons_0037",
		tt_title = _("SPECIAL_REPAIR_HOLDER_SEA_OF_TREES_NAME"),
		tt_desc = _("SPECIAL_REPAIR_HOLDER_SEA_OF_TREES_DESCRIPTION")
	})}},
	-- 法师塔
	mage = {{M(tpl.common_upgrade, {
		-- 二级法师塔
		action_arg = "tower_mage_2",
		tt_title = _("TOWER_MAGE_2_NAME"),
		tt_desc = _("TOWER_MAGE_2_DESCRIPTION")
	}), tpl.sell}, {M(tpl.common_upgrade, {
		-- 三级法师塔
		action_arg = "tower_mage_3",
		tt_title = _("TOWER_MAGE_3_NAME"),
		tt_desc = _("TOWER_MAGE_3_DESCRIPTION")
	}), tpl.sell}, {
		-- 四级法师塔
		M(tpl.upgrade, {
			action_arg = "tower_arcane_wizard",
			image = "main_icons_0006",
			place = 5,
			tt_title = _("TOWER_ARCANE_NAME"),
			tt_desc = _("TOWER_ARCANE_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_sorcerer",
			image = "main_icons_0007",
			place = 6,
			tt_title = _("TOWER_SORCERER_NAME"),
			tt_desc = _("TOWER_SORCERER_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_sunray",
			image = "main_icons_0018",
			place = 7,
			tt_title = _("TOWER_SUNRAY_NAME"),
			tt_desc = _("TOWER_SUNRAY_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_necromancer",
			image = "main_icons_0021",
			place = 10,
			tt_title = _("TOWER_NECROMANCER_NAME"),
			tt_desc = _("TOWER_NECROMANCER_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_high_elven",
			image = "kr3_main_icons_0004",
			place = 11,
			tt_title = _("TOWER_MAGE_HIGH_ELVEN_NAME"),
			tt_desc = _("TOWER_MAGE_HIGH_ELVEN_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_archmage",
			image = "main_icons_0022",
			place = 12,
			tt_title = _("TOWER_ARCHMAGE_NAME"),
			tt_desc = _("TOWER_ARCHMAGE_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_wild_magus",
			image = "kr3_main_icons_0003",
			place = 13,
			tt_title = _("TOWER_MAGE_WILD_MAGUS_NAME"),
			tt_desc = _("TOWER_MAGE_WILD_MAGUS_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_faerie_dragon",
			image = "kr3_main_icons_0013",
			place = 14,
			tt_title = _("TOWER_FAERIE_DRAGON_NAME"),
			tt_desc = _("TOWER_FAERIE_DRAGON_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_pixie",
			image = "kr3_main_icons_0012",
			place = 15,
			tt_title = _("TOWER_PIXIE_NAME"),
			tt_desc = _("TOWER_PIXIE_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_necromancer_lvl4",
			image = "kr5_main_icons_0011",
			place = 16,
			tt_title = _("TOWER_NECROMANCER_NAME"),
			tt_desc = _("TOWER_NECROMANCER_4_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_ray_lvl4",
			image = "kr5_main_icons_0018",
			place = 17,
			tt_title = _("TOWER_RAY_NAME"),
			tt_desc = _("TOWER_RAY_4_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_elven_stargazers_lvl4",
			image = "kr5_main_icons_0008",
			place = 18,
			tt_title = _("TOWER_ELVEN_STARGAZERS_NAME"),
			tt_desc = _("TOWER_STARGAZER_4_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_arcane_wizard_lvl4",
			image = "kr5_main_icons_0003",
			place = 19,
			tt_title = _("TOWER_ARCANE_WIZARD_NAME"),
			tt_desc = _("TOWER_ARCANE_WIZARD_4_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_hermit_toad_lvl4",
			image = "kr5_main_icons_0034",
			place = 20,
			tt_title = _("TOWER_HERMIT_TOAD_NAME"),
			tt_desc = _("TOWER_HERMIT_TOAD_4_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_arborean_emissary_lvl4",
			image = "kr5_main_icons_0006",
			type = "arborean_emissary",
			place = 21,
			tt_title = _("TOWER_ARBOREAN_EMISSARY_1_NAME"),
			tt_desc = _("TOWER_ARBOREAN_EMISSARY_1_DESCRIPTION")
		}),
		tpl.sell
	}},
	-- 炮塔
	engineer = {{M(tpl.common_upgrade, {
		-- 二级炮塔
		action_arg = "tower_engineer_2",
		tt_title = _("TOWER_ENGINEER_2_NAME"),
		tt_desc = _("TOWER_ENGINEER_2_DESCRIPTION")
	}), tpl.sell}, {M(tpl.common_upgrade, {
		-- 三级炮塔
		action_arg = "tower_engineer_3",
		tt_title = _("TOWER_ENGINEER_3_NAME"),
		tt_desc = _("TOWER_ENGINEER_3_DESCRIPTION")
	}), tpl.sell}, {
		-- 四级炮塔
		M(tpl.upgrade, {
			action_arg = "tower_bfg",
			image = "main_icons_0013",
			place = 5,
			tt_title = _("TOWER_BFG_NAME"),
			tt_desc = _("TOWER_BFG_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_tesla",
			image = "main_icons_0012",
			place = 6,
			tt_title = _("TOWER_TESLA_NAME"),
			tt_desc = _("TOWER_TESLA_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_dwaarp",
			image = "main_icons_0027",
			place = 7,
			tt_title = _("TOWER_DWAARP_NAME"),
			tt_desc = _("TOWER_DWAARP_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_mech",
			image = "main_icons_0028",
			place = 10,
			tt_title = _("TOWER_MECH_NAME"),
			tt_desc = _("TOWER_MECH_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_frankenstein",
			image = "main_icons_0039",
			place = 11,
			tt_title = _("SPECIAL_TOWER_FRANKENSTEIN_NAME"),
			tt_desc = _("SPECIAL_TOWER_FRANKENSTEIN_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_druid",
			image = "kr3_main_icons_0008",
			place = 12,
			tt_title = _("TOWER_STONE_DRUID_NAME"),
			tt_desc = _("TOWER_STONE_DRUID_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_entwood",
			image = "kr3_main_icons_0007",
			place = 13,
			tt_title = _("TOWER_ENTWOOD_NAME"),
			tt_desc = _("TOWER_ENTWOOD_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_tricannon_lvl4",
			image = "kr5_main_icons_0004",
			tt_title = _("TOWER_TRICANNON_NAME"),
			tt_desc = _("TOWER_TRICANNON_1_DESCRIPTION"),
			place = 14
		}),
		M(tpl.upgrade, {
			action_arg = "tower_demon_pit_lvl4",
			image = "kr5_main_icons_0007",
			tt_title = _("TOWER_DEMON_PIT_NAME"),
			tt_desc = _("TOWER_DEMON_PIT_1_DESCRIPTION"),
			place = 15
		}),
		M(tpl.upgrade, {
			action_arg = "tower_flamespitter_lvl4",
			image = "kr5_main_icons_0012",
			place = 16,
			tt_title = _("TOWER_FLAMESPITTER_NAME"),
			tt_desc = _("TOWER_FLAMESPITTER_1_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_barrel_lvl4",
			image = "kr5_main_icons_0017",
			place = 17,
			tt_title = _("TOWER_BARREL_NAME"),
			tt_desc = _("TOWER_BARREL_1_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_sparking_geode_lvl4",
			image = "kr5_main_icons_0042",
			type = "sparking_geode",
			place = 18,
			tt_title = _("TOWER_SPARKING_GEODE_1_NAME"),
			tt_desc = _("TOWER_SPARKING_GEODE_1_DESCRIPTION")
		}),
		tpl.sell
	}},
	-- 箭塔
	archer = {{M(tpl.common_upgrade, {
		-- 二级箭塔
		action_arg = "tower_archer_2",
		tt_title = _("TOWER_ARCHER_2_NAME"),
		tt_desc = _("TOWER_ARCHER_2_DESCRIPTION")
	}), tpl.sell}, {M(tpl.common_upgrade, {
		-- 三级箭塔
		action_arg = "tower_archer_3",
		tt_title = _("TOWER_ARCHER_3_NAME"),
		tt_desc = _("TOWER_ARCHER_3_DESCRIPTION")
	}), tpl.sell}, {
		-- 四级箭塔
		M(tpl.upgrade, {
			action_arg = "tower_ranger",
			image = "main_icons_0011",
			place = 5,
			tt_title = _("TOWER_RANGERS_NAME"),
			tt_desc = _("TOWER_RANGERS_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_musketeer",
			image = "main_icons_0010",
			place = 6,
			tt_title = _("TOWER_MUSKETEERS_NAME"),
			tt_desc = _("TOWER_MUSKETEERS_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_crossbow",
			image = "main_icons_0025",
			place = 7,
			tt_title = _("TOWER_CROSSBOW_NAME"),
			tt_desc = _("TOWER_CROSSBOW_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_totem",
			image = "main_icons_0026",
			place = 10,
			tt_title = _("TOWER_TOTEM_NAME"),
			tt_desc = _("TOWER_TOTEM_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_archer_dwarf",
			image = "main_icons_0034",
			place = 11,
			tt_title = _("TOWER_ARCHER_DWARF_NAME"),
			tt_desc = _("TOWER_ARCHER_DWARF_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_pirate_watchtower",
			image = "main_icons_0032",
			place = 12,
			tt_title = _("TOWER_PIRATE_WATCHTOWER_NAME"),
			tt_desc = _("TOWER_PIRATE_WATCHTOWER_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_arcane",
			image = "kr3_main_icons_0005",
			place = 13,
			tt_title = _("TOWER_ARCANE_ARCHER_NAME"),
			tt_desc = _("TOWER_ARCANE_ARCHER_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_silver",
			image = "kr3_main_icons_0006",
			place = 14,
			tt_title = _("TOWER_SILVER_NAME"),
			tt_desc = _("TOWER_SILVER_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_dark_elf_lvl4",
			image = "kr5_main_icons_0032",
			place = 15,
			tt_title = _("TOWER_DARK_ELF_NAME"),
			tt_desc = _("TOWER_DARK_ELF_1_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_sand_lvl4",
			image = "kr5_main_icons_0013",
			place = 16,
			tt_title = _("TOWER_SAND_NAME"),
			tt_desc = _("TOWER_SAND_1_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_royal_archers_lvl4",
			image = "kr5_main_icons_0002",
			place = 17,
			tt_title = _("TOWER_ROYAL_ARCHERS_NAME"),
			tt_desc = _("TOWER_ROYAL_ARCHERS_1_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_ballista_lvl4",
			image = "kr5_main_icons_0010",
			place = 18,
			tt_title = _("TOWER_BALLISTA_NAME"),
			tt_desc = _("TOWER_BALLISTA_1_DESCRIPTION")
		}),
		tpl.sell
	}},
	-- 兵营
	barrack = {{M(tpl.common_upgrade, {
		-- 二级兵营
		action_arg = "tower_barrack_2",
		tt_title = _("TOWER_BARRACK_2_NAME"),
		tt_desc = _("TOWER_BARRACK_2_DESCRIPTION")
	}), tpl.rally, tpl.sell}, {M(tpl.common_upgrade, {
		-- 三级兵营
		action_arg = "tower_barrack_3",
		tt_title = _("TOWER_BARRACK_3_NAME"),
		tt_desc = _("TOWER_BARRACK_3_DESCRIPTION")
	}), tpl.rally, tpl.sell}, {
		-- 四级兵营
		M(tpl.upgrade, {
			action_arg = "tower_paladin",
			image = "main_icons_0008",
			place = 5,
			tt_title = _("TOWER_PALADINS_NAME"),
			tt_desc = _("TOWER_PALADINS_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_barbarian",
			image = "main_icons_0009",
			place = 6,
			tt_title = _("TOWER_BARBARIANS_NAME"),
			tt_desc = _("TOWER_BARBARIANS_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_elf",
			image = "main_icons_0011",
			place = 7,
			tt_title = _("TOWER_ELF_NAME"),
			tt_desc = _("TOWER_ELF_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_templar",
			image = "main_icons_0023",
			place = 10,
			tt_title = _("TOWER_TEMPLAR_NAME"),
			tt_desc = _("TOWER_TEMPLAR_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_assassin",
			image = "main_icons_0024",
			place = 11,
			tt_title = _("TOWER_ASSASSIN_NAME"),
			tt_desc = _("TOWER_ASSASSIN_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_barrack_dwarf",
			image = "main_icons_0015",
			place = 12,
			tt_title = _("TOWER_BARRACK_DWARF_NAME"),
			tt_desc = _("TOWER_BARRACK_DWARF_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_barrack_amazonas",
			image = "main_icons_0033",
			place = 13,
			tt_title = _("TOWER_BARRACK_AMAZONAS_NAME"),
			tt_desc = _("TOWER_BARRACK_AMAZONAS_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_barrack_mercenaries",
			image = "main_icons_0030",
			place = 14,
			tt_title = _("SPECIAL_DJINN_NAME"),
			tt_desc = _("SPECIAL_DJINN_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_barrack_pirates",
			image = "main_icons_0032",
			place = 15,
			tt_title = _("TOWER_BARRACK_PIRATES_NAME"),
			tt_desc = _("TOWER_BARRACK_PIRATES_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_blade",
			image = "kr3_main_icons_0001",
			place = 16,
			tt_title = _("TOWER_BARRACKS_BLADE_NAME"),
			tt_desc = _("TOWER_BARRACKS_BLADE_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_forest",
			image = "kr3_main_icons_0002",
			place = 17,
			tt_title = _("TOWER_FOREST_KEEPERS_NAME"),
			tt_desc = _("TOWER_FOREST_KEEPERS_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_drow",
			image = "kr3_main_icons_0014",
			place = 18,
			tt_title = _("TOWER_DROW_NAME"),
			tt_desc = _("TOWER_DROW_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_ewok",
			image = "kr3_main_icons_0009",
			place = 19,
			tt_title = _("ELVES_EWOK_NAME"),
			tt_desc = _("ELVES_EWOK_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_baby_ashbite",
			image = "kr3_main_icons_0010",
			place = 20,
			tt_title = _("TOWER_BABY_ASHBITE_BROKEN_NAME"),
			tt_desc = _("TOWER_BABY_ASHBITE_BROKEN_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_pandas_lvl4",
			image = "kr5_main_icons_0049",
			place = 21,
			tt_title = _("TOWER_PANDAS_NAME"),
			tt_desc = _("TOWER_PANDAS_1_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_rocket_gunners_lvl4",
			type = "rocket_gunners",
			image = "kr5_main_icons_0009",
			place = 22,
			tt_title = _("TOWER_ROCKET_GUNNERS_NAME"),
			tt_desc = _("TOWER_ROCKET_GUNNERS_1_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_dwarf_lvl4",
			type = "dwarf",
			image = "kr5_main_icons_0039",
			place = 23,
			tt_title = _("TOWER_DWARF_1_NAME"),
			tt_desc = _("TOWER_DWARF_1_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_ghost_lvl4",
			type = "ghost",
			image = "kr5_main_icons_0016",
			place = 24,
			tt_title = _("TOWER_GHOST_1_NAME"),
			tt_desc = _("TOWER_GHOST_1_DESCRIPTION")
		}),
		M(tpl.upgrade, {
			action_arg = "tower_paladin_covenant_lvl4",
			type = "paladin_covenant",
			image = "kr5_main_icons_0001",
			place = 25,
			tt_title = _("TOWER_PALADIN_COVENANT_1_NAME"),
			tt_desc = _("TOWER_PALADIN_COVENANT_1_DESCRIPTION")
		}),
		tpl.rally,
		tpl.sell
	}},
	ranger = {{M(tpl.upgrade_power, {
		action_arg = "poison",
		image = "special_icons_0008",
		place = 1,
		sounds = {"ArcherRangerPoisonTaunt"},
		tt_phrase = _("TOWER_RANGERS_POISON_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_RANGERS_POISON_NAME_1"),
			tt_desc = _("TOWER_RANGERS_POISON_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_RANGERS_POISON_NAME_2"),
			tt_desc = _("TOWER_RANGERS_POISON_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_RANGERS_POISON_NAME_3"),
			tt_desc = _("TOWER_RANGERS_POISON_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "thorn",
		image = "special_icons_0002",
		place = 2,
		sounds = {"ArcherRangerThornTaunt"},
		tt_phrase = _("TOWER_RANGERS_THORNS_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_RANGERS_THORNS_NAME_1"),
			tt_desc = _("TOWER_RANGERS_THORNS_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_RANGERS_THORNS_NAME_2"),
			tt_desc = _("TOWER_RANGERS_THORNS_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_RANGERS_THORNS_NAME_3"),
			tt_desc = _("TOWER_RANGERS_THORNS_DESCRIPTION_3")
		}}
	}), tpl.sell}},
	musketeer = {{M(tpl.upgrade_power, {
		action_arg = "sniper",
		image = "special_icons_0003",
		place = 1,
		sounds = {"ArcherMusketeerSniperTaunt"},
		tt_phrase = _("TOWER_MUSKETEERS_SNIPER_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_MUSKETEERS_SNIPER_NAME_1"),
			tt_desc = _("TOWER_MUSKETEERS_SNIPER_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_MUSKETEERS_SNIPER_NAME_2"),
			tt_desc = _("TOWER_MUSKETEERS_SNIPER_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_MUSKETEERS_SNIPER_NAME_3"),
			tt_desc = _("TOWER_MUSKETEERS_SNIPER_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "shrapnel",
		image = "special_icons_0005",
		place = 2,
		sounds = {"ArcherMusketeerShrapnelTaunt"},
		tt_phrase = _("TOWER_MUSKETEERS_SHRAPNEL_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_MUSKETEERS_SHRAPNEL_NAME_1"),
			tt_desc = _("TOWER_MUSKETEERS_SHRAPNEL_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_MUSKETEERS_SHRAPNEL_NAME_2"),
			tt_desc = _("TOWER_MUSKETEERS_SHRAPNEL_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_MUSKETEERS_SHRAPNEL_NAME_3"),
			tt_desc = _("TOWER_MUSKETEERS_SHRAPNEL_DESCRIPTION_3")
		}}
	}), tpl.sell}},
	crossbow = {{M(tpl.upgrade_power, {
		action_arg = "multishot",
		image = "special_icons_0028",
		place = 1,
		sounds = {"CrossbowTauntMultishoot"},
		tt_phrase = _("TOWER_CROSSBOW_BARRAGE_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_CROSSBOW_BARRAGE_NAME_1"),
			tt_desc = _("TOWER_CROSSBOW_BARRAGE_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_CROSSBOW_BARRAGE_NAME_2"),
			tt_desc = _("TOWER_CROSSBOW_BARRAGE_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_CROSSBOW_BARRAGE_NAME_3"),
			tt_desc = _("TOWER_CROSSBOW_BARRAGE_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "eagle",
		image = "special_icons_0029",
		place = 2,
		sounds = {"CrossbowTauntEagle"},
		tt_phrase = _("TOWER_CROSSBOW_FALCONER_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_CROSSBOW_FALCONER_NAME_1"),
			tt_desc = _("TOWER_CROSSBOW_FALCONER_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_CROSSBOW_FALCONER_NAME_2"),
			tt_desc = _("TOWER_CROSSBOW_FALCONER_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_CROSSBOW_FALCONER_NAME_3"),
			tt_desc = _("TOWER_CROSSBOW_FALCONER_DESCRIPTION_3")
		}}
	}), tpl.sell}},
	totem = {{M(tpl.upgrade_power, {
		action_arg = "weakness",
		image = "special_icons_0030",
		place = 1,
		sounds = {"TotemTauntTotemOne"},
		tt_phrase = _("TOWER_TOTEM_WEAKNESS_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_TOTEM_WEAKNESS_NAME_1"),
			tt_desc = _("TOWER_TOTEM_WEAKNESS_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_TOTEM_WEAKNESS_NAME_2"),
			tt_desc = _("TOWER_TOTEM_WEAKNESS_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_TOTEM_WEAKNESS_NAME_3"),
			tt_desc = _("TOWER_TOTEM_WEAKNESS_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "silence",
		image = "special_icons_0031",
		place = 2,
		sounds = {"TotemTauntTotemTwo"},
		tt_phrase = _("TOWER_TOTEM_SPIRITS_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_TOTEM_SPIRITS_NAME_1"),
			tt_desc = _("TOWER_TOTEM_SPIRITS_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_TOTEM_SPIRITS_NAME_2"),
			tt_desc = _("TOWER_TOTEM_SPIRITS_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_TOTEM_SPIRITS_NAME_3"),
			tt_desc = _("TOWER_TOTEM_SPIRITS_DESCRIPTION_3")
		}}
	}), tpl.sell}},
	archer_dwarf = {{M(tpl.upgrade_power, {
		action_arg = "barrel",
		image = "special_icons_0044",
		place = 1,
		sounds = {"DwarfArcherTaunt1"},
		tt_phrase = _("TOWER_ARCHER_DWARF_BARREL_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_ARCHER_DWARF_BARREL_NAME_1"),
			tt_desc = _("TOWER_ARCHER_DWARF_BARREL_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_ARCHER_DWARF_BARREL_NAME_2"),
			tt_desc = _("TOWER_ARCHER_DWARF_BARREL_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_ARCHER_DWARF_BARREL_NAME_3"),
			tt_desc = _("TOWER_ARCHER_DWARF_BARREL_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "extra_damage",
		image = "special_icons_0043",
		place = 2,
		sounds = {"DwarfArcherTaunt2"},
		tt_phrase = _("TOWER_ARCHER_DWARF_EXTRA_DAMAGE_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_ARCHER_DWARF_EXTRA_DAMAGE_NAME_1"),
			tt_desc = _("TOWER_ARCHER_DWARF_EXTRA_DAMAGE_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_ARCHER_DWARF_EXTRA_DAMAGE_NAME_2"),
			tt_desc = _("TOWER_ARCHER_DWARF_EXTRA_DAMAGE_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_ARCHER_DWARF_EXTRA_DAMAGE_NAME_3"),
			tt_desc = _("TOWER_ARCHER_DWARF_EXTRA_DAMAGE_DESCRIPTION_3")
		}}
	}), tpl.sell}},
	arcane_wizard = {{M(tpl.upgrade_power, {
		action_arg = "disintegrate",
		image = "special_icons_0015",
		place = 1,
		sounds = {"MageArcaneDesintegrateTaunt"},
		tt_phrase = _("TOWER_ARCANE_DESINTEGRATE_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_ARCANE_DESINTEGRATE_NAME_1"),
			tt_desc = _("TOWER_ARCANE_DESINTEGRATE_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_ARCANE_DESINTEGRATE_NAME_2"),
			tt_desc = _("TOWER_ARCANE_DESINTEGRATE_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_ARCANE_DESINTEGRATE_NAME_3"),
			tt_desc = _("TOWER_ARCANE_DESINTEGRATE_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "teleport",
		image = "special_icons_0016",
		place = 2,
		sounds = {"MageArcaneTeleporthTaunt"},
		tt_phrase = _("TOWER_ARCANE_TELEPORT_NOTE_1"),
		tt_list = {{
			tt_title = _("TOWER_ARCANE_TELEPORT_NAME_1"),
			tt_desc = _("TOWER_ARCANE_TELEPORT_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_ARCANE_TELEPORT_NAME_2"),
			tt_desc = _("TOWER_ARCANE_TELEPORT_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_ARCANE_TELEPORT_NAME_3"),
			tt_desc = _("TOWER_ARCANE_TELEPORT_DESCRIPTION_3")
		}}
	}), tpl.sell}},
	sorcerer = {{M(tpl.upgrade_power, {
		action_arg = "polymorph",
		image = "special_icons_0001",
		place = 1,
		sounds = {"Sheep"},
		tt_phrase = _("TOWER_SORCERER_POLIMORPH_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_SORCERER_POLIMORPH_NAME_1"),
			tt_desc = _("TOWER_SORCERER_POLIMORPH_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_SORCERER_POLIMORPH_NAME_2"),
			tt_desc = _("TOWER_SORCERER_POLIMORPH_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_SORCERER_POLIMORPH_NAME_3"),
			tt_desc = _("TOWER_SORCERER_POLIMORPH_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "elemental",
		image = "special_icons_0004",
		place = 2,
		tt_phrase = _("TOWER_SORCERER_ELEMENTAL_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_SORCERER_ELEMENTAL_NAME_1"),
			tt_desc = _("TOWER_SORCERER_ELEMENTAL_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_SORCERER_ELEMENTAL_NAME_2"),
			tt_desc = _("TOWER_SORCERER_ELEMENTAL_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_SORCERER_ELEMENTAL_NAME_3"),
			tt_desc = _("TOWER_SORCERER_ELEMENTAL_DESCRIPTION_3")
		}}
	}), tpl.rally, tpl.sell}},
	archmage = {{M(tpl.upgrade_power, {
		action_arg = "twister",
		image = "special_icons_0032",
		place = 1,
		sounds = {"ArchmageTauntTwister"},
		tt_phrase = _("TOWER_ARCHMAGE_TWISTER_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_ARCHMAGE_TWISTER_NAME_1"),
			tt_desc = _("TOWER_ARCHMAGE_TWISTER_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_ARCHMAGE_TWISTER_NAME_2"),
			tt_desc = _("TOWER_ARCHMAGE_TWISTER_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_ARCHMAGE_TWISTER_NAME_3"),
			tt_desc = _("TOWER_ARCHMAGE_TWISTER_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "blast",
		image = "special_icons_0033",
		place = 2,
		sounds = {"ArchmageTauntExplosion"},
		tt_phrase = _("TOWER_ARCHMAGE_CRITICAL_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_ARCHMAGE_CRITICAL_NAME_1"),
			tt_desc = _("TOWER_ARCHMAGE_CRITICAL_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_ARCHMAGE_CRITICAL_NAME_2"),
			tt_desc = _("TOWER_ARCHMAGE_CRITICAL_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_ARCHMAGE_CRITICAL_NAME_3"),
			tt_desc = _("TOWER_ARCHMAGE_CRITICAL_DESCRIPTION_3")
		}}
	}), tpl.sell}},
	necromancer = {{M(tpl.upgrade_power, {
		action_arg = "pestilence",
		image = "special_icons_0035",
		place = 1,
		sounds = {"NecromancerTauntPestilence"},
		tt_phrase = _("TOWER_NECROMANCER_PESTILENCE_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_NECROMANCER_PESTILENCE_NAME_1"),
			tt_desc = _("TOWER_NECROMANCER_PESTILENCE_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_NECROMANCER_PESTILENCE_NAME_2"),
			tt_desc = _("TOWER_NECROMANCER_PESTILENCE_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_NECROMANCER_PESTILENCE_NAME_3"),
			tt_desc = _("TOWER_NECROMANCER_PESTILENCE_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "rider",
		image = "special_icons_0034",
		place = 2,
		sounds = {"NecromancerTauntDeath_Knight"},
		tt_phrase = _("TOWER_NECROMANCER_RIDER_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_NECROMANCER_RIDER_NAME_1"),
			tt_desc = _("TOWER_NECROMANCER_RIDER_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_NECROMANCER_RIDER_NAME_2"),
			tt_desc = _("TOWER_NECROMANCER_RIDER_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_NECROMANCER_RIDER_NAME_3"),
			tt_desc = _("TOWER_NECROMANCER_RIDER_DESCRIPTION_3")
		}}
	}), tpl.rally, tpl.sell}},
	bfg = {{M(tpl.upgrade_power, {
		action_arg = "missile",
		image = "special_icons_0017",
		place = 1,
		sounds = {"EngineerBfgMissileTaunt"},
		tt_phrase = _("TOWER_BFG_MISSILE_NOTE_1"),
		tt_list = {{
			tt_title = _("TOWER_BFG_MISSILE_NAME_1"),
			tt_desc = _("TOWER_BFG_MISSILE_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_BFG_MISSILE_NAME_2"),
			tt_desc = _("TOWER_BFG_MISSILE_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_BFG_MISSILE_NAME_3"),
			tt_desc = _("TOWER_BFG_MISSILE_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "cluster",
		image = "special_icons_0018",
		place = 2,
		sounds = {"EngineerBfgClusterTaunt"},
		tt_phrase = _("TOWER_BFG_CLUSTER_NOTE_1"),
		tt_list = {{
			tt_title = _("TOWER_BFG_CLUSTER_NAME_1"),
			tt_desc = _("TOWER_BFG_CLUSTER_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_BFG_CLUSTER_NAME_2"),
			tt_desc = _("TOWER_BFG_CLUSTER_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_BFG_CLUSTER_NAME_3"),
			tt_desc = _("TOWER_BFG_CLUSTER_DESCRIPTION_3")
		}}
	}), tpl.sell}},
	tesla = {{M(tpl.upgrade_power, {
		action_arg = "bolt",
		image = "special_icons_0011",
		place = 1,
		sounds = {"EngineerTeslaChargedBoltTaunt"},
		tt_phrase = _("TOWER_TESLA_CHARGED_BOLT_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_TESLA_CHARGED_BOLT_NAME_1"),
			tt_desc = _("TOWER_TESLA_CHARGED_BOLT_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_TESLA_CHARGED_BOLT_NAME_2"),
			tt_desc = _("TOWER_TESLA_CHARGED_BOLT_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_TESLA_CHARGED_BOLT_NAME_3"),
			tt_desc = _("TOWER_TESLA_CHARGED_BOLT_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "overcharge",
		image = "special_icons_0010",
		place = 2,
		sounds = {"EngineerTeslaOverchargeTaunt"},
		tt_phrase = _("TOWER_TESLA_OVERCHARGE_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_TESLA_OVERCHARGE_NAME_1"),
			tt_desc = _("TOWER_TESLA_OVERCHARGE_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_TESLA_OVERCHARGE_NAME_2"),
			tt_desc = _("TOWER_TESLA_OVERCHARGE_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_TESLA_OVERCHARGE_NAME_3"),
			tt_desc = _("TOWER_TESLA_OVERCHARGE_DESCRIPTION_3")
		}}
	}), tpl.sell}},
	dwaarp = {{M(tpl.upgrade_power, {
		action_arg = "drill",
		image = "special_icons_0036",
		place = 1,
		sounds = {"EarthquakeTauntDrill"},
		tt_phrase = _("TOWER_DWAARP_DRILL_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_DWAARP_DRILL_NAME_1"),
			tt_desc = _("TOWER_DWAARP_DRILL_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_DWAARP_DRILL_NAME_2"),
			tt_desc = _("TOWER_DWAARP_DRILL_DESCRIPTION_2_NOFMT")
		}, {
			tt_title = _("TOWER_DWAARP_DRILL_NAME_3"),
			tt_desc = _("TOWER_DWAARP_DRILL_DESCRIPTION_3_NOFMT")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "lava",
		image = "special_icons_0037",
		place = 2,
		sounds = {"EarthquakeTauntScorched"},
		tt_phrase = _("TOWER_DWAARP_BLAST_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_DWAARP_BLAST_NAME_1"),
			tt_desc = _("TOWER_DWAARP_BLAST_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_DWAARP_BLAST_NAME_2"),
			tt_desc = _("TOWER_DWAARP_BLAST_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_DWAARP_BLAST_NAME_3"),
			tt_desc = _("TOWER_DWAARP_BLAST_DESCRIPTION_3")
		}}
	}), tpl.sell}},
	mecha = {{M(tpl.upgrade_power, {
		action_arg = "missile",
		image = "special_icons_0038",
		place = 1,
		sounds = {"MechTauntMissile"},
		tt_phrase = _("TOWER_MECH_MISSILE_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_MECH_MISSILE_NAME_1"),
			tt_desc = _("TOWER_MECH_MISSILE_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_MECH_MISSILE_NAME_2"),
			tt_desc = _("TOWER_MECH_MISSILE_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_MECH_MISSILE_NAME_3"),
			tt_desc = _("TOWER_MECH_MISSILE_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "oil",
		image = "special_icons_0039",
		place = 2,
		sounds = {"MechTauntSlow"},
		tt_phrase = _("TOWER_MECH_WASTE_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_MECH_WASTE_NAME_1"),
			tt_desc = _("TOWER_MECH_WASTE_DESCRIPTION_1_NOFMT")
		}, {
			tt_title = _("TOWER_MECH_WASTE_NAME_2"),
			tt_desc = _("TOWER_MECH_WASTE_DESCRIPTION_2_NOFMT")
		}, {
			tt_title = _("TOWER_MECH_WASTE_NAME_3"),
			tt_desc = _("TOWER_MECH_WASTE_DESCRIPTION_3_NOFMT")
		}}
	}), tpl.rally, tpl.sell}},
	paladin = {{M(tpl.upgrade_power, {
		action_arg = "healing",
		image = "special_icons_0007",
		place = 6,
		sounds = {"BarrackPaladinHealingTaunt"},
		tt_phrase = _("TOWER_PALADINS_HEALING_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_PALADINS_HEALING_NAME_1"),
			tt_desc = _("TOWER_PALADINS_HEALING_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_PALADINS_HEALING_NAME_2"),
			tt_desc = _("TOWER_PALADINS_HEALING_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_PALADINS_HEALING_NAME_3"),
			tt_desc = _("TOWER_PALADINS_HEALING_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "shield",
		image = "special_icons_0009",
		place = 5,
		sounds = {"BarrackPaladinShieldTaunt"},
		tt_phrase = _("TOWER_PALADINS_SHIELD_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_PALADINS_SHIELD_NAME_1"),
			tt_desc = _("TOWER_PALADINS_SHIELD_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_PALADINS_SHIELD_NAME_2"),
			tt_desc = _("TOWER_PALADINS_SHIELD_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_PALADINS_SHIELD_NAME_3"),
			tt_desc = _("TOWER_PALADINS_SHIELD_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "holystrike",
		image = "special_icons_0006",
		place = 7,
		sounds = {"BarrackPaladinHolyStrikeTaunt"},
		tt_phrase = _("TOWER_PALADINS_HOLY_STRIKE_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_PALADINS_HOLY_STRIKE_NAME_1"),
			tt_desc = _("TOWER_PALADINS_HOLY_STRIKE_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_PALADINS_HOLY_STRIKE_NAME_2"),
			tt_desc = _("TOWER_PALADINS_HOLY_STRIKE_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_PALADINS_HOLY_STRIKE_NAME_3"),
			tt_desc = _("TOWER_PALADINS_HOLY_STRIKE_DESCRIPTION_3")
		}}
	}), tpl.rally, tpl.sell}},
	barbarian = {{M(tpl.upgrade_power, {
		action_arg = "dual",
		image = "special_icons_0012",
		place = 6,
		sounds = {"BarrackBarbarianDoubleAxesTaunt"},
		tt_phrase = _("TOWER_BARBARIANS_DOUBLE_AXE_NOTE_1"),
		tt_list = {{
			tt_title = _("TOWER_BARBARIANS_DOUBLE_AXE_NAME_1"),
			tt_desc = _("TOWER_BARBARIANS_DOUBLE_AXE_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_BARBARIANS_DOUBLE_AXE_NAME_2"),
			tt_desc = _("TOWER_BARBARIANS_DOUBLE_AXE_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_BARBARIANS_DOUBLE_AXE_NAME_3"),
			tt_desc = _("TOWER_BARBARIANS_DOUBLE_AXE_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "twister",
		image = "special_icons_0013",
		place = 5,
		sounds = {"BarrackBarbarianTwisterTaunt"},
		tt_phrase = _("TOWER_BARBARIANS_TWISTER_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_BARBARIANS_TWISTER_NAME_1"),
			tt_desc = _("TOWER_BARBARIANS_TWISTER_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_BARBARIANS_TWISTER_NAME_2"),
			tt_desc = _("TOWER_BARBARIANS_TWISTER_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_BARBARIANS_TWISTER_NAME_3"),
			tt_desc = _("TOWER_BARBARIANS_TWISTER_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "throwing",
		image = "special_icons_0019",
		place = 7,
		sounds = {"BarrackBarbarianThrowingAxesTaunt"},
		tt_phrase = _("TOWER_BARBARIANS_THROWING_AXES_NOTE_1"),
		tt_list = {{
			tt_title = _("TOWER_BARBARIANS_THROWING_AXES_NAME_1"),
			tt_desc = _("TOWER_BARBARIANS_THROWING_AXES_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_BARBARIANS_THROWING_AXES_NAME_2"),
			tt_desc = _("TOWER_BARBARIANS_THROWING_AXES_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_BARBARIANS_THROWING_AXES_NAME_3"),
			tt_desc = _("TOWER_BARBARIANS_THROWING_AXES_DESCRIPTION_3")
		}}
	}), tpl.rally, tpl.sell}},
	holder_elf = {{M(tpl.upgrade, {
		action_arg = "tower_elf",
		image = "main_icons_0015",
		place = 5,
		tt_title = _("TOWER_ELF_REPAIR_NAME"),
		tt_desc = _("TOWER_ELF_REPAIR_DESCRIPTION")
	}), tpl.sell}},
	elf = {{M(tpl.upgrade_power, {
		action_arg = "bleed",
		image = "special_icons_0014",
		place = 7,
		sounds = {"ElfBleed"},
		tt_phrase = _("TOWER_ELF_BLEEDING_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_ELF_BLEEDING_NAME_1"),
			tt_desc = _("TOWER_ELF_BLEEDING_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_ELF_BLEEDING_NAME_2"),
			tt_desc = _("TOWER_ELF_BLEEDING_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_ELF_BLEEDING_NAME_3"),
			tt_desc = _("TOWER_ELF_BLEEDING_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "cripple",
		image = "special_icons_0024",
		place = 6,
		sounds = {"ElfCripple"},
		tt_phrase = _("TOWER_ELF_CRIPPLE_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_ELF_CRIPPLE_NAME_1"),
			tt_desc = _("TOWER_ELF_CRIPPLE_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_ELF_CRIPPLE_NAME_2"),
			tt_desc = _("TOWER_ELF_CRIPPLE_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_ELF_CRIPPLE_NAME_3"),
			tt_desc = _("TOWER_ELF_CRIPPLE_DESCRIPTION_3")
		}}
	}), M(tpl.buy_soldier, {
		action_arg = "soldier_elf",
		image = "main_icons_0016",
		tt_title = _("TOWER_ELF_NAME"),
		tt_desc = _("TOWER_ELF_DESCRIPTION")
	}), tpl.rally, tpl.sell}},
	templar = {{M(tpl.upgrade_power, {
		action_arg = "holygrail",
		image = "special_icons_0025",
		place = 7,
		sounds = {"TemplarTauntTauntOne"},
		tt_phrase = _("TOWER_TEMPLAR_HOLY_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_TEMPLAR_HOLY_NAME_1"),
			tt_desc = _("TOWER_TEMPLAR_HOLY_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_TEMPLAR_HOLY_NAME_2"),
			tt_desc = _("TOWER_TEMPLAR_HOLY_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_TEMPLAR_HOLY_NAME_3"),
			tt_desc = _("TOWER_TEMPLAR_HOLY_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "extralife",
		image = "special_icons_0027",
		place = 6,
		sounds = {"TemplarTauntTauntTwo"},
		tt_phrase = _("TOWER_TEMPLAR_TOUGHNESS_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_TEMPLAR_TOUGHNESS_NAME_1"),
			tt_desc = _("TOWER_TEMPLAR_TOUGHNESS_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_TEMPLAR_TOUGHNESS_NAME_2"),
			tt_desc = _("TOWER_TEMPLAR_TOUGHNESS_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_TEMPLAR_TOUGHNESS_NAME_3"),
			tt_desc = _("TOWER_TEMPLAR_TOUGHNESS_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "blood",
		image = "special_icons_0026",
		place = 5,
		sounds = {"TemplarTauntThree"},
		tt_phrase = _("TOWER_TEMPLAR_ARTERIAL_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_TEMPLAR_ARTERIAL_NAME_1"),
			tt_desc = _("TOWER_TEMPLAR_ARTERIAL_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_TEMPLAR_ARTERIAL_NAME_2"),
			tt_desc = _("TOWER_TEMPLAR_ARTERIAL_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_TEMPLAR_ARTERIAL_NAME_3"),
			tt_desc = _("TOWER_TEMPLAR_ARTERIAL_DESCRIPTION_3")
		}}
	}), tpl.rally, tpl.sell}},
	assassin = {{M(tpl.upgrade_power, {
		action_arg = "sneak",
		image = "special_icons_0024",
		place = 6,
		sounds = {"AssassinTauntSneak"},
		tt_phrase = _("TOWER_ASSASSIN_SNEAK_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_ASSASSIN_SNEAK_NAME_1"),
			tt_desc = _("TOWER_ASSASSIN_SNEAK_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_ASSASSIN_SNEAK_NAME_2"),
			tt_desc = _("TOWER_ASSASSIN_SNEAK_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_ASSASSIN_SNEAK_NAME_3"),
			tt_desc = _("TOWER_ASSASSIN_SNEAK_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "pickpocket",
		image = "special_icons_0022",
		place = 7,
		sounds = {"AssassinTauntGold"},
		tt_phrase = _("TOWER_ASSASSIN_PICK_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_ASSASSIN_PICK_NAME_1"),
			tt_desc = _("TOWER_ASSASSIN_PICK_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_ASSASSIN_PICK_NAME_2"),
			tt_desc = _("TOWER_ASSASSIN_PICK_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_ASSASSIN_PICK_NAME_3"),
			tt_desc = _("TOWER_ASSASSIN_PICK_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "counter",
		image = "special_icons_0023",
		place = 5,
		sounds = {"AssassinTauntCounter"},
		tt_phrase = _("TOWER_ASSASSIN_COUNTER_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_ASSASSIN_COUNTER_NAME_1"),
			tt_desc = _("TOWER_ASSASSIN_COUNTER_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_ASSASSIN_COUNTER_NAME_2"),
			tt_desc = _("TOWER_ASSASSIN_COUNTER_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_ASSASSIN_COUNTER_NAME_3"),
			tt_desc = _("TOWER_ASSASSIN_COUNTER_DESCRIPTION_3")
		}}
	}), tpl.rally, tpl.sell}},
	barrack_dwarf = {{M(tpl.upgrade_power, {
		action_arg = "hammer",
		image = "special_icons_0040",
		place = 5,
		sounds = {"DwarfTaunt"},
		tt_phrase = _("TOWER_BARRACK_DWARF_HAMMER_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_BARRACK_DWARF_HAMMER_NAME_1"),
			tt_desc = _("TOWER_BARRACK_DWARF_HAMMER_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_BARRACK_DWARF_HAMMER_NAME_2"),
			tt_desc = _("TOWER_BARRACK_DWARF_HAMMER_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_BARRACK_DWARF_HAMMER_NAME_3"),
			tt_desc = _("TOWER_BARRACK_DWARF_HAMMER_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "armor",
		image = "special_icons_0041",
		place = 6,
		sounds = {"DwarfTaunt"},
		tt_phrase = _("TOWER_BARRACK_DWARF_ARMOR_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_BARRACK_DWARF_ARMOR_NAME_1"),
			tt_desc = _("TOWER_BARRACK_DWARF_ARMOR_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_BARRACK_DWARF_ARMOR_NAME_2"),
			tt_desc = _("TOWER_BARRACK_DWARF_ARMOR_DESCRIPTION_2")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "beer",
		image = "special_icons_0042",
		place = 7,
		sounds = {"DwarfTaunt"},
		tt_phrase = _("TOWER_BARRACK_DWARF_BEER_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_BARRACK_DWARF_BEER_NAME_1"),
			tt_desc = _("TOWER_BARRACK_DWARF_BEER_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_BARRACK_DWARF_BEER_NAME_2"),
			tt_desc = _("TOWER_BARRACK_DWARF_BEER_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_BARRACK_DWARF_BEER_NAME_3"),
			tt_desc = _("TOWER_BARRACK_DWARF_BEER_DESCRIPTION_3")
		}}
	}), tpl.rally, tpl.sell}},
	mercenaries_amazonas = {{M(tpl.upgrade_power, {
		action_arg = "valkyrie",
		image = "special_icons_0014",
		place = 7,
		sounds = {"AmazonTaunt"},
		tt_phrase = _("TOWER_BARRACK_AMAZONAS_VALKYRIE_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_BARRACK_AMAZONAS_VALKYRIE_NAME_1"),
			tt_desc = _("TOWER_BARRACK_AMAZONAS_VALKYRIE_DESCRIPTION_1")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "whirlwind",
		image = "special_icons_0013",
		place = 6,
		sounds = {"AmazonTaunt"},
		tt_phrase = _("TOWER_BARRACK_AMAZONAS_WHIRLWIND_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_BARRACK_AMAZONAS_WHIRLWIND_NAME_1"),
			tt_desc = _("TOWER_BARRACK_AMAZONAS_WHIRLWIND_DESCRIPTION_1")
		}}
	}), M(tpl.buy_soldier, {
		action_arg = "soldier_amazona",
		image = "main_icons_0033",
		tt_title = _("TOWER_BARRACK_AMAZONAS_WARRIOR_NAME"),
		tt_desc = _("TOWER_BARRACK_AMAZONAS_WARRIOR_DESCRIPTION")
	}), tpl.rally, tpl.sell}},
	holder_sasquash = {{{
		halo = "glow_ico_main",
		action = "tw_none",
		image = "main_icons_0017",
		place = 5,
		tt_title = _("TOWER_ELF_REPAIR_NAME"),
		tt_desc = _("TOWER_ELF_REPAIR_DESCRIPTION")
	}}},
	sasquash = {{M(tpl.buy_soldier, {
		action_arg = "soldier_sasquash",
		image = "main_icons_0017",
		place = 5,
		tt_title = _("SPECIAL_SASQUASH_NAME"),
		tt_desc = _("SPECIAL_SASQUASH_DESCRIPTION")
	}), tpl.rally}},
	sunray = {{M(tpl.upgrade_power, {
		no_upgrade_lights = true,
		image = "main_icons_0018",
		action_arg = "ray",
		place = 5,
		sounds = {"MageSorcererAshesToAshesTaunt"},
		tt_phrase = _("TOWER_SUNRAY_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_SUNRAY_RAY_NAME_1"),
			tt_desc = _("TOWER_SUNRAY_RAY_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_SUNRAY_RAY_NAME_2"),
			tt_desc = _("TOWER_SUNRAY_RAY_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_SUNRAY_RAY_NAME_3"),
			tt_desc = _("TOWER_SUNRAY_RAY_DESCRIPTION_3")
		}, {
			tt_title = _("TOWER_SUNRAY_RAY_NAME_4"),
			tt_desc = _("TOWER_SUNRAY_RAY_DESCRIPTION_4")
		}}
	}), M(tpl.upgrade_power, {
		image = "special_icons_0022",
		action_arg = "gold",
		place = 6,
		sounds = {"MageSorcererAshesToAshesTaunt"},
		tt_phrase = _("TOWER_SUNRAY_GOLD_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_SUNRAY_GOLD_NAME_1"),
			tt_desc = _("TOWER_SUNRAY_GOLD_DESCRIPTION_1")
		}}
	}), M(tpl.upgrade_power, {
		image = "special_icons_0015",
		action_arg = "charge",
		place = 7,
		sounds = {"MageSorcererAshesToAshesTaunt"},
		tt_phrase = _("TOWER_SUNRAY_CHARGE_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_SUNRAY_CHARGE_NAME_1"),
			tt_desc = _("TOWER_SUNRAY_CHARGE_DESCRIPTION_1")
		}}
	}), tpl.sell}},
	mercenaries_desert = {{M(tpl.buy_soldier, {
		action_arg = "soldier_djinn",
		image = "main_icons_0030",
		place = 5,
		tt_title = _("SPECIAL_DJINN_NAME"),
		tt_desc = _("SPECIAL_DJINN_DESCRIPTION")
	}), M(tpl.upgrade_power, {
		action_arg = "djspell",
		image = "special_icons_0025",
		place = 7,
		sounds = {"GenieTaunt"},
		tt_phrase = _("TOWER_BARRACK_MERCENARIES_DJSPELL_NOTE_1"),
		tt_list = {{
			tt_title = _("TOWER_BARRACK_MERCENARIES_DJSPELL_NAME_1"),
			tt_desc = _("TOWER_BARRACK_MERCENARIES_DJSPELL_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_BARRACK_MERCENARIES_DJSPELL_NAME_2"),
			tt_desc = _("TOWER_BARRACK_MERCENARIES_DJSPELL_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_BARRACK_MERCENARIES_DJSPELL_NAME_3"),
			tt_desc = _("TOWER_BARRACK_MERCENARIES_DJSPELL_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "djshock",
		image = "special_icons_0016",
		place = 6,
		sounds = {"GenieTaunt"},
		tt_phrase = _("TOWER_BARRACK_MERCENARIES_DJSHOCK_NOTE_1"),
		tt_list = {{
			tt_title = _("TOWER_BARRACK_MERCENARIES_DJSHOCK_NAME_1"),
			tt_desc = _("TOWER_BARRACK_MERCENARIES_DJSHOCK_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_BARRACK_MERCENARIES_DJSHOCK_NAME_2"),
			tt_desc = _("TOWER_BARRACK_MERCENARIES_DJSHOCK_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_BARRACK_MERCENARIES_DJSHOCK_NAME_3"),
			tt_desc = _("TOWER_BARRACK_MERCENARIES_DJSHOCK_DESCRIPTION_3")
		}}
	}), tpl.rally, tpl.sell}},
	mercenaries_pirates = {{M(tpl.upgrade_power, {
		action_arg = "bigbomb",
		image = "special_icons_0018",
		place = 6,
		sounds = {"PiratesTaunt"},
		tt_phrase = _("TOWER_BARRACK_PIRATES_BIGBOMB_NOTE_1"),
		tt_list = {{
			tt_title = _("TOWER_BARRACK_PIRATES_BIGBOMB_NAME_1"),
			tt_desc = _("TOWER_BARRACK_PIRATES_BIGBOMB_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_BARRACK_PIRATES_BIGBOMB_NAME_2"),
			tt_desc = _("TOWER_BARRACK_PIRATES_BIGBOMB_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_BARRACK_PIRATES_BIGBOMB_NAME_3"),
			tt_desc = _("TOWER_BARRACK_PIRATES_BIGBOMB_DESCRIPTION_3")
		}}
	}), M(tpl.buy_soldier, {
		action_arg = "soldier_pirate_flamer",
		image = "main_icons_0032",
		place = 5,
		tt_title = _("SPECIAL_PIRATE_FLAMER_NAME"),
		tt_desc = _("SPECIAL_PIRATE_FLAMER_DESCRIPTION")
	}), M(tpl.upgrade_power, {
		action_arg = "quickup",
		image = "special_icons_0025",
		place = 7,
		sounds = {"PiratesTaunt"},
		tt_phrase = _("TOWER_BARRACK_PIRATES_QUICKUP_NOTE_1"),
		tt_list = {{
			tt_title = _("TOWER_BARRACK_PIRATES_QUICKUP_NAME_1"),
			tt_desc = _("TOWER_BARRACK_PIRATES_QUICKUP_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_BARRACK_PIRATES_QUICKUP_NAME_2"),
			tt_desc = _("TOWER_BARRACK_PIRATES_QUICKUP_DESCRIPTION_2")
		}}
	}), tpl.rally, tpl.sell}},
	pirate_watchtower = {{M(tpl.upgrade_power, {
		action_arg = "reduce_cooldown",
		image = "special_icons_0045",
		place = 1,
		sounds = {"PirateTowerTaunt1"},
		tt_phrase = _("TOWER_PIRATE_WATCHTOWER_REDUCE_COOLDOWN_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_PIRATE_WATCHTOWER_REDUCE_COOLDOWN_NAME_1"),
			tt_desc = _("TOWER_PIRATE_WATCHTOWER_REDUCE_COOLDOWN_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_PIRATE_WATCHTOWER_REDUCE_COOLDOWN_NAME_2"),
			tt_desc = _("TOWER_PIRATE_WATCHTOWER_REDUCE_COOLDOWN_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_PIRATE_WATCHTOWER_REDUCE_COOLDOWN_NAME_3"),
			tt_desc = _("TOWER_PIRATE_WATCHTOWER_REDUCE_COOLDOWN_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "parrot",
		image = "special_icons_0046",
		place = 2,
		sounds = {"PirateTowerTaunt2"},
		tt_phrase = _("TOWER_PIRATE_WATCHTOWER_PARROT_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_PIRATE_WATCHTOWER_PARROT_NAME_1"),
			tt_desc = _("TOWER_PIRATE_WATCHTOWER_PARROT_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_PIRATE_WATCHTOWER_PARROT_NAME_2"),
			tt_desc = _("TOWER_PIRATE_WATCHTOWER_PARROT_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_PIRATE_WATCHTOWER_PARROT_NAME_3"),
			tt_desc = _("TOWER_PIRATE_WATCHTOWER_PARROT_DESCRIPTION_3")
		}}
	}), tpl.sell}},
	holder_neptune = {{M(tpl.upgrade, {
		action_arg = "tower_neptune",
		image = "main_icons_0015",
		place = 5,
		tt_title = _("SPECIAL_NEPTUNE_BROKEN_TOWER_FIX_NAME"),
		tt_desc = _("SPECIAL_NEPTUNE_BROKEN_TOWER_FIX_DESCRIPTION")
	}), tpl.sell}},
	neptune = {{M(tpl.upgrade_power, {
		action_arg = "ray",
		image = "special_icons_0047",
		place = 5,
		tt_list = {{
			tt_title = _("SPECIAL_NEPTUNE_TOWER_UPGRADE_NAME"),
			tt_desc = _("SPECIAL_NEPTUNE_TOWER_UPGRADE_DESCRIPTION_1")
		}, {
			tt_title = _("SPECIAL_NEPTUNE_TOWER_UPGRADE_NAME"),
			tt_desc = _("SPECIAL_NEPTUNE_TOWER_UPGRADE_DESCRIPTION_1")
		}, {
			tt_title = _("SPECIAL_NEPTUNE_TOWER_UPGRADE_NAME"),
			tt_desc = _("SPECIAL_NEPTUNE_TOWER_UPGRADE_DESCRIPTION_1")
		}}
	}), tpl.point, tpl.sell}},
	frankenstein = {{M(tpl.upgrade_power, {
		action_arg = "lightning",
		image = "special_icons_0048",
		place = 1,
		sounds = {"HWFrankensteinUpgradeLightning"},
		tt_phrase = _("SPECIAL_TOWER_FRANKENSTEIN_UPGRADE_1_NOTE"),
		tt_list = {{
			tt_title = _("SPECIAL_TOWER_FRANKENSTEIN_UPGRADE_1_NAME"),
			tt_desc = _("SPECIAL_TOWER_FRANKENSTEIN_UPGRADE_1_DESCRIPTION_1")
		}, {
			tt_title = _("SPECIAL_TOWER_FRANKENSTEIN_UPGRADE_1_NAME"),
			tt_desc = _("SPECIAL_TOWER_FRANKENSTEIN_UPGRADE_1_DESCRIPTION_2")
		}, {
			tt_title = _("SPECIAL_TOWER_FRANKENSTEIN_UPGRADE_1_NAME"),
			tt_desc = _("SPECIAL_TOWER_FRANKENSTEIN_UPGRADE_1_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "frankie",
		image = "special_icons_0049",
		place = 2,
		sounds = {"HWFrankensteinUpgradeFrankenstein"},
		tt_phrase = _("SPECIAL_TOWER_FRANKENSTEIN_UPGRADE_2_NOTE"),
		tt_list = {{
			tt_title = _("SPECIAL_TOWER_FRANKENSTEIN_UPGRADE_2_NAME"),
			tt_desc = _("SPECIAL_TOWER_FRANKENSTEIN_UPGRADE_2_DESCRIPTION_1")
		}, {
			tt_title = _("SPECIAL_TOWER_FRANKENSTEIN_UPGRADE_2_NAME"),
			tt_desc = _("SPECIAL_TOWER_FRANKENSTEIN_UPGRADE_2_DESCRIPTION_2")
		}, {
			tt_title = _("SPECIAL_TOWER_FRANKENSTEIN_UPGRADE_2_NAME"),
			tt_desc = _("SPECIAL_TOWER_FRANKENSTEIN_UPGRADE_2_DESCRIPTION_3")
		}}
	}), tpl.rally, tpl.sell}},
	--
	--         三代
	--     --
	blade = {{M(tpl.upgrade_power, {
		action_arg = "perfect_parry",
		image = "kr3_special_icons_0006",
		place = 6,
		sounds = {"ElvesBarrackBladesingerPerfectParryTaunt"},
		tt_phrase = _("TOWER_BLADE_PERFECT_PARRY_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_BLADE_PERFECT_PARRY_NAME_1"),
			tt_desc = _("TOWER_BLADE_PERFECT_PARRY_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_BLADE_PERFECT_PARRY_NAME_2"),
			tt_desc = _("TOWER_BLADE_PERFECT_PARRY_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_BLADE_PERFECT_PARRY_NAME_3"),
			tt_desc = _("TOWER_BLADE_PERFECT_PARRY_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "blade_dance",
		image = "kr3_special_icons_0005",
		place = 7,
		sounds = {"ElvesBarrackBladesingerBladeDanceTaunt"},
		tt_phrase = _("TOWER_BLADE_BLADE_DANCE_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_BLADE_BLADE_DANCE_NAME_1"),
			tt_desc = _("TOWER_BLADE_BLADE_DANCE_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_BLADE_BLADE_DANCE_NAME_2"),
			tt_desc = _("TOWER_BLADE_BLADE_DANCE_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_BLADE_BLADE_DANCE_NAME_3"),
			tt_desc = _("TOWER_BLADE_BLADE_DANCE_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "swirling",
		image = "kr3_special_icons_0007",
		place = 5,
		sounds = {"ElvesBarrackBladesingerSwirlingEdge"},
		tt_phrase = _("TOWER_BLADE_SWIRLING_EDGE_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_BLADE_SWIRLING_EDGE_NAME_1"),
			tt_desc = _("TOWER_BLADE_SWIRLING_EDGE_DESCRIPTION_1")
		}}
	}), tpl.rally, tpl.sell}},
	forest = {{M(tpl.upgrade_power, {
		action_arg = "circle",
		image = "kr3_special_icons_0008",
		place = 6,
		sounds = {"ElvesBarrackForestKeeperCircleOfLifeTaunt"},
		tt_phrase = _("TOWER_FOREST_KEEPERS_CIRCLE_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_FOREST_KEEPERS_CIRCLE_NAME_1"),
			tt_desc = _("TOWER_FOREST_KEEPERS_CIRCLE_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_FOREST_KEEPERS_CIRCLE_NAME_2"),
			tt_desc = _("TOWER_FOREST_KEEPERS_CIRCLE_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_FOREST_KEEPERS_CIRCLE_NAME_3"),
			tt_desc = _("TOWER_FOREST_KEEPERS_CIRCLE_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "eerie",
		image = "kr3_special_icons_0009",
		place = 5,
		sounds = {"ElvesBarrackForestKeeperEerieTaunt"},
		tt_phrase = _("TOWER_FOREST_KEEPERS_EERIE_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_FOREST_KEEPERS_EERIE_NAME_1"),
			tt_desc = _("TOWER_FOREST_KEEPERS_EERIE_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_FOREST_KEEPERS_EERIE_NAME_2"),
			tt_desc = _("TOWER_FOREST_KEEPERS_EERIE_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_FOREST_KEEPERS_EERIE_NAME_3"),
			tt_desc = _("TOWER_FOREST_KEEPERS_EERIE_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "oak",
		image = "kr3_special_icons_0010",
		place = 7,
		sounds = {"ElvesBarrackForestKeeperOakSpearTaunt"},
		tt_phrase = _("TOWER_FOREST_KEEPERS_OAK_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_FOREST_KEEPERS_OAK_NAME_1"),
			tt_desc = _("TOWER_FOREST_KEEPERS_OAK_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_FOREST_KEEPERS_OAK_NAME_2"),
			tt_desc = _("TOWER_FOREST_KEEPERS_OAK_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_FOREST_KEEPERS_OAK_NAME_3"),
			tt_desc = _("TOWER_FOREST_KEEPERS_OAK_DESCRIPTION_3")
		}}
	}), tpl.rally, tpl.sell}},
	druid = {{M(tpl.upgrade_power, {
		action_arg = "sylvan",
		image = "kr3_special_icons_0012",
		place = 1,
		sounds = {"ElvesRockHengeSylvanCurseTaunt"},
		tt_phrase = _("TOWER_STONE_DRUID_SYLVAN_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_STONE_DRUID_SYLVAN_NAME_1"),
			tt_desc = _("TOWER_STONE_DRUID_SYLVAN_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_STONE_DRUID_SYLVAN_NAME_2"),
			tt_desc = _("TOWER_STONE_DRUID_SYLVAN_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_STONE_DRUID_SYLVAN_NAME_3"),
			tt_desc = _("TOWER_STONE_DRUID_SYLVAN_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "nature",
		image = "kr3_special_icons_0011",
		place = 2,
		sounds = {"SoldierDruidBearRallyChange"},
		tt_phrase = _("TOWER_STONE_DRUID_NATURES_FRIEND_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_STONE_DRUID_NATURES_FRIEND_NAME_1"),
			tt_desc = _("TOWER_STONE_DRUID_NATURES_FRIEND_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_STONE_DRUID_NATURES_FRIEND_NAME_2"),
			tt_desc = _("TOWER_STONE_DRUID_NATURES_FRIEND_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_STONE_DRUID_NATURES_FRIEND_NAME_3"),
			tt_desc = _("TOWER_STONE_DRUID_NATURES_FRIEND_DESCRIPTION_3")
		}}
	}), tpl.rally, tpl.sell}},
	entwood = {{M(tpl.upgrade_power, {
		action_arg = "clobber",
		image = "kr3_special_icons_0013",
		place = 2,
		sounds = {"ElvesRockEntwoodClobberingTaunt"},
		tt_phrase = _("TOWER_ENTWOOD_CLOBBER_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_ENTWOOD_CLOBBER_NAME_1"),
			tt_desc = _("TOWER_ENTWOOD_CLOBBER_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_ENTWOOD_CLOBBER_NAME_2"),
			tt_desc = _("TOWER_ENTWOOD_CLOBBER_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_ENTWOOD_CLOBBER_NAME_3"),
			tt_desc = _("TOWER_ENTWOOD_CLOBBER_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "fiery_nuts",
		image = "kr3_special_icons_0014",
		place = 1,
		sounds = {"ElvesRockEntwoodFieryNutsTaunt"},
		tt_phrase = _("TOWER_ENTWOOD_FIERY_NUTS_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_ENTWOOD_FIERY_NUTS_NAME_1"),
			tt_desc = _("TOWER_ENTWOOD_FIERY_NUTS_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_ENTWOOD_FIERY_NUTS_NAME_2"),
			tt_desc = _("TOWER_ENTWOOD_FIERY_NUTS_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_ENTWOOD_FIERY_NUTS_NAME_3"),
			tt_desc = _("TOWER_ENTWOOD_FIERY_NUTS_DESCRIPTION_3")
		}}
	}), tpl.sell}},
	arcane = {{M(tpl.upgrade_power, {
		action_arg = "burst",
		image = "kr3_special_icons_0002",
		place = 1,
		sounds = {"ElvesArcherArcaneBurstTaunt"},
		tt_phrase = _("TOWER_ARCANE_ARCHER_BURST_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_ARCANE_ARCHER_BURST_NAME_1"),
			tt_desc = _("TOWER_ARCANE_ARCHER_BURST_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_ARCANE_ARCHER_BURST_NAME_2"),
			tt_desc = _("TOWER_ARCANE_ARCHER_BURST_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_ARCANE_ARCHER_BURST_NAME_3"),
			tt_desc = _("TOWER_ARCANE_ARCHER_BURST_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "slumber",
		image = "kr3_special_icons_0001",
		place = 2,
		sounds = {"ElvesArcherArcaneSleepTaunt"},
		tt_phrase = _("TOWER_ARCANE_ARCHER_SLUMBER_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_ARCANE_ARCHER_SLUMBER_NAME_1"),
			tt_desc = _("TOWER_ARCANE_ARCHER_SLUMBER_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_ARCANE_ARCHER_SLUMBER_NAME_2"),
			tt_desc = _("TOWER_ARCANE_ARCHER_SLUMBER_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_ARCANE_ARCHER_SLUMBER_NAME_3"),
			tt_desc = _("TOWER_ARCANE_ARCHER_SLUMBER_DESCRIPTION_3")
		}}
	}), tpl.sell}},
	silver = {{M(tpl.upgrade_power, {
		action_arg = "sentence",
		image = "kr3_special_icons_0003",
		place = 1,
		sounds = {"ElvesArcherGoldenBowCrimsonTaunt"},
		tt_phrase = _("TOWER_SILVER_SENTENCE_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_SILVER_SENTENCE_NAME_1"),
			tt_desc = _("TOWER_SILVER_SENTENCE_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_SILVER_SENTENCE_NAME_2"),
			tt_desc = _("TOWER_SILVER_SENTENCE_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_SILVER_SENTENCE_NAME_3"),
			tt_desc = _("TOWER_SILVER_SENTENCE_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "mark",
		image = "kr3_special_icons_0004",
		place = 2,
		sounds = {"ElvesArcherGoldenBowMarkTaunt"},
		tt_phrase = _("TOWER_SILVER_MARK_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_SILVER_MARK_NAME_1"),
			tt_desc = _("TOWER_SILVER_MARK_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_SILVER_MARK_NAME_2"),
			tt_desc = _("TOWER_SILVER_MARK_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_SILVER_MARK_NAME_3"),
			tt_desc = _("TOWER_SILVER_MARK_DESCRIPTION_3")
		}}
	}), tpl.sell}},
	wild_magus = {{M(tpl.upgrade_power, {
		action_arg = "eldritch",
		image = "kr3_special_icons_0015",
		place = 1,
		sounds = {"ElvesMageWildMagusDoomTaunt"},
		tt_phrase = _("TOWER_MAGE_WILD_MAGUS_ELDRITCH_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_MAGE_WILD_MAGUS_ELDRITCH_NAME_1"),
			tt_desc = _("TOWER_MAGE_WILD_MAGUS_ELDRITCH_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_MAGE_WILD_MAGUS_ELDRITCH_NAME_2"),
			tt_desc = _("TOWER_MAGE_WILD_MAGUS_ELDRITCH_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_MAGE_WILD_MAGUS_ELDRITCH_NAME_3"),
			tt_desc = _("TOWER_MAGE_WILD_MAGUS_ELDRITCH_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "ward",
		image = "kr3_special_icons_0016",
		place = 2,
		sounds = {"ElvesMageWildMagusSilenceTaunt"},
		tt_phrase = _("TOWER_MAGE_WILD_MAGUS_WARD_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_MAGE_WILD_MAGUS_WARD_NAME_1"),
			tt_desc = _("TOWER_MAGE_WILD_MAGUS_WARD_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_MAGE_WILD_MAGUS_WARD_NAME_2"),
			tt_desc = _("TOWER_MAGE_WILD_MAGUS_WARD_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_MAGE_WILD_MAGUS_WARD_NAME_3"),
			tt_desc = _("TOWER_MAGE_WILD_MAGUS_WARD_DESCRIPTION_3")
		}}
	}), tpl.sell}},
	high_elven = {{M(tpl.upgrade_power, {
		action_arg = "timelapse",
		image = "kr3_special_icons_0017",
		place = 1,
		sounds = {"ElvesMageHighElvenTimelapseTaunt"},
		tt_phrase = _("TOWER_MAGE_HIGH_ELVEN_TIMELAPSE_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_MAGE_HIGH_ELVEN_TIMELAPSE_NAME_1"),
			tt_desc = _("TOWER_MAGE_HIGH_ELVEN_TIMELAPSE_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_MAGE_HIGH_ELVEN_TIMELAPSE_NAME_2"),
			tt_desc = _("TOWER_MAGE_HIGH_ELVEN_TIMELAPSE_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_MAGE_HIGH_ELVEN_TIMELAPSE_NAME_3"),
			tt_desc = _("TOWER_MAGE_HIGH_ELVEN_TIMELAPSE_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "sentinel",
		image = "kr3_special_icons_0018",
		place = 2,
		sounds = {"ElvesMageHighElvenSentinelTaunt"},
		tt_phrase = _("TOWER_MAGE_HIGH_ELVEN_SENTINEL_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_MAGE_HIGH_ELVEN_SENTINEL_NAME_1"),
			tt_desc = _("TOWER_MAGE_HIGH_ELVEN_SENTINEL_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_MAGE_HIGH_ELVEN_SENTINEL_NAME_2"),
			tt_desc = _("TOWER_MAGE_HIGH_ELVEN_SENTINEL_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_MAGE_HIGH_ELVEN_SENTINEL_NAME_3"),
			tt_desc = _("TOWER_MAGE_HIGH_ELVEN_SENTINEL_DESCRIPTION_3")
		}}
	}), tpl.sell}},
	holder_ewok = {{M(tpl.upgrade, {
		action_arg = "tower_ewok",
		image = "main_icons_0015",
		place = 5,
		tt_title = _("ELVES_EWOK_TOWER_BROKEN_NAME"),
		tt_desc = _("ELVES_EWOK_TOWER_BROKEN_DESCRIPTION")
	})}},
	ewok = {{M(tpl.upgrade_power, {
		action_arg = "armor",
		image = "special_icons_0041",
		place = 6,
		sounds = {"ElvesEwokTaunt"},
		tt_phrase = _("TOWER_EWOK_ARMOR_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_EWOK_ARMOR_NAME_1"),
			tt_desc = _("TOWER_EWOK_ARMOR_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_EWOK_ARMOR_NAME_2"),
			tt_desc = _("TOWER_EWOK_ARMOR_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_EWOK_ARMOR_NAME_3"),
			tt_desc = _("TOWER_EWOK_ARMOR_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "shield",
		image = "special_icons_0009",
		place = 5,
		sounds = {"ElvesEwokTaunt"},
		tt_phrase = _("TOWER_EWOK_SHIELD_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_EWOK_SHIELD_NAME_1"),
			tt_desc = _("TOWER_EWOK_SHIELD_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_EWOK_SHIELD_NAME_2"),
			tt_desc = _("TOWER_EWOK_SHIELD_DESCRIPTION_2")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "tear",
		image = "kr3_special_icons_0010",
		place = 7,
		sounds = {"ElvesEwokTaunt"},
		tt_phrase = _("TOWER_EWOK_TEAR_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_EWOK_TEAR_NAME_1"),
			tt_desc = _("TOWER_EWOK_TEAR_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_EWOK_TEAR_NAME_2"),
			tt_desc = _("TOWER_EWOK_TEAR_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_EWOK_TEAR_NAME_3"),
			tt_desc = _("TOWER_EWOK_TEAR_DESCRIPTION_3")
		}}
	}), tpl.rally, tpl.sell}},
	faerie_dragon = {{M(tpl.upgrade_power, {
		action_arg = "more_dragons",
		image = "kr3_special_icons_0024",
		place = 1,
		sounds = {"ElvesFaeryDragonDragonBuy"},
		tt_phrase = _("TOWER_FAERIE_DRAGON_MORE_DRAGONS_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_FAERIE_DRAGON_MORE_DRAGONS_NAME_1"),
			tt_desc = _("TOWER_FAERIE_DRAGON_MORE_DRAGONS_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_FAERIE_DRAGON_MORE_DRAGONS_NAME_2"),
			tt_desc = _("TOWER_FAERIE_DRAGON_MORE_DRAGONS_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_FAERIE_DRAGON_MORE_DRAGONS_NAME_3"),
			tt_desc = _("TOWER_FAERIE_DRAGON_MORE_DRAGONS_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "improve_shot",
		image = "kr3_special_icons_0025",
		place = 2,
		sounds = {"ElvesFaeryDragonExtraAbility"},
		tt_phrase = _("TOWER_FAERIE_DRAGON_IMPROVE_SHOT_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_FAERIE_DRAGON_IMPROVE_SHOT_NAME_1"),
			tt_desc = _("TOWER_FAERIE_DRAGON_IMPROVE_SHOT_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_FAERIE_DRAGON_IMPROVE_SHOT_NAME_2"),
			tt_desc = _("TOWER_FAERIE_DRAGON_IMPROVE_SHOT_DESCRIPTION_2")
		}}
	}), tpl.sell}},
	pixie = {{M(tpl.upgrade_power, {
		action_arg = "cream",
		image = "kr3_special_icons_0022",
		place = 1,
		sounds = {"ElvesGnomeNew"},
		tt_phrase = _("TOWER_PIXIE_CREAM_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_PIXIE_CREAM_NAME_1"),
			tt_desc = _("TOWER_PIXIE_CREAM_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_PIXIE_CREAM_NAME_2"),
			tt_desc = _("TOWER_PIXIE_CREAM_DESCRIPTION_2")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "total",
		image = "kr3_special_icons_0023",
		place = 2,
		sounds = {"ElvesGnomePower"},
		tt_phrase = _("TOWER_PIXIE_TOTAL_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_PIXIE_TOTAL_NAME_1"),
			tt_desc = _("TOWER_PIXIE_TOTAL_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_PIXIE_TOTAL_NAME_2"),
			tt_desc = _("TOWER_PIXIE_TOTAL_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_PIXIE_TOTAL_NAME_3"),
			tt_desc = _("TOWER_PIXIE_TOTAL_DESCRIPTION_3")
		}}
	}), tpl.sell}},
	baby_black_dragon = {{M(tpl.buy_attack, {
		action_arg = 1,
		image = "kr3_main_icons_0011",
		tt_title = _("ELVES_BABY_BERESAD_SPECIAL_NAME_1"),
		tt_desc = _("ELVES_BABY_BERESAD_SPECIAL_DESCRIPTION_1")
	})}},
	holder_baby_ashbite = {{M(tpl.upgrade, {
		action_arg = "tower_baby_ashbite",
		image = "kr3_main_icons_0010",
		place = 5,
		tt_title = _("TOWER_BABY_ASHBITE_BROKEN_NAME"),
		tt_desc = _("TOWER_BABY_ASHBITE_BROKEN_DESCRIPTION")
	})}},
	baby_ashbite = {{M(tpl.upgrade_power, {
		action_arg = "blazing_breath",
		image = "kr3_special_icons_0026",
		place = 1,
		sounds = {"ElvesAshbiteConfirm"},
		tt_phrase = _("TOWER_BABY_ASHBITE_BLAZING_BREATH_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_BABY_ASHBITE_BLAZING_BREATH_NAME_1"),
			tt_desc = _("TOWER_BABY_ASHBITE_BLAZING_BREATH_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_BABY_ASHBITE_BLAZING_BREATH_NAME_2"),
			tt_desc = _("TOWER_BABY_ASHBITE_BLAZING_BREATH_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_BABY_ASHBITE_BLAZING_BREATH_NAME_3"),
			tt_desc = _("TOWER_BABY_ASHBITE_BLAZING_BREATH_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "fiery_mist",
		image = "kr3_special_icons_0027",
		place = 2,
		sounds = {"ElvesAshbiteConfirm"},
		tt_phrase = _("TOWER_BABY_ASHBITE_FIERY_MIST_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_BABY_ASHBITE_FIERY_MIST_NAME_1"),
			tt_desc = _("TOWER_BABY_ASHBITE_FIERY_MIST_DESCRIPTION_1")
		}}
	}), tpl.rally, tpl.sell}},
	drow = {{M(tpl.upgrade_power, {
		action_arg = "life_drain",
		image = "kr3_special_icons_0020",
		place = 6,
		sounds = {"ElvesSpecialDrowLifeDrain"},
		tt_phrase = _("TOWER_DROW_LIFE_DRAIN_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_DROW_LIFE_DRAIN_NAME_1"),
			tt_desc = _("TOWER_DROW_LIFE_DRAIN_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_DROW_LIFE_DRAIN_NAME_2"),
			tt_desc = _("TOWER_DROW_LIFE_DRAIN_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_DROW_LIFE_DRAIN_NAME_3"),
			tt_desc = _("TOWER_DROW_LIFE_DRAIN_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "blade_mail",
		image = "kr3_special_icons_0019",
		place = 7,
		sounds = {"ElvesSpecialDrowBlademail"},
		tt_phrase = _("TOWER_DROW_BLADE_MAIL_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_DROW_BLADE_MAIL_NAME_1"),
			tt_desc = _("TOWER_DROW_BLADE_MAIL_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_DROW_BLADE_MAIL_NAME_2"),
			tt_desc = _("TOWER_DROW_BLADE_MAIL_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_DROW_BLADE_MAIL_NAME_3"),
			tt_desc = _("TOWER_DROW_BLADE_MAIL_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "double_dagger",
		image = "kr3_special_icons_0021",
		place = 5,
		sounds = {"ElvesSpecialDrowDaggers"},
		tt_phrase = _("TOWER_DROW_DOUBLE_DAGGER_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_DROW_DOUBLE_DAGGER_NAME_1"),
			tt_desc = _("TOWER_DROW_DOUBLE_DAGGER_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_DROW_DOUBLE_DAGGER_NAME_2"),
			tt_desc = _("TOWER_DROW_DOUBLE_DAGGER_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_DROW_DOUBLE_DAGGER_NAME_3"),
			tt_desc = _("TOWER_DROW_DOUBLE_DAGGER_DESCRIPTION_3")
		}}
	}), tpl.rally, tpl.sell}},
	holder_bastion = {{M(tpl.upgrade, {
		action_arg = "tower_bastion",
		image = "main_icons_0015",
		place = 5,
		tt_title = _("ELVES_TOWER_BASTION_BROKEN_NAME"),
		tt_desc = _("ELVES_TOWER_BASTION_BROKEN_DESCRIPTION")
	})}},
	bastion = {{M(tpl.upgrade_power, {
		action_arg = "razor_edge",
		image = "kr3_special_icons_0028",
		place = 5,
		sounds = {"ElvesTowerBastionRazorEdge"},
		tt_phrase = _("ELVES_TOWER_BASTION_RAZOR_EDGE_NOTE"),
		tt_list = {{
			tt_title = _("ELVES_TOWER_BASTION_RAZOR_EDGE_NAME_1"),
			tt_desc = _("ELVES_TOWER_BASTION_RAZOR_EDGE_DESCRIPTION_1")
		}, {
			tt_title = _("ELVES_TOWER_BASTION_RAZOR_EDGE_NAME_2"),
			tt_desc = _("ELVES_TOWER_BASTION_RAZOR_EDGE_DESCRIPTION_2")
		}}
	})}},
	--
	--         五代
	--     --
	-- 三管加农炮
	tricannon = {{M(tpl.upgrade_power, {
		action_arg = "bombardment",
		image = "kr5_special_icons_0007",
		place = 6,
		sounds = {"TowerTricannonSkillATaunt"},
		tt_phrase = _("TOWER_TRICANNON_4_BOMBARDMENT_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_TRICANNON_4_BOMBARDMENT_1_NAME"),
			tt_desc = _("TOWER_TRICANNON_4_BOMBARDMENT_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_TRICANNON_4_BOMBARDMENT_2_NAME"),
			tt_desc = _("TOWER_TRICANNON_4_BOMBARDMENT_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_TRICANNON_4_BOMBARDMENT_3_NAME"),
			tt_desc = _("TOWER_TRICANNON_4_BOMBARDMENT_3_DESCRIPTION")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "overheat",
		image = "kr5_special_icons_0008",
		place = 7,
		sounds = {"TowerTricannonSkillBTaunt"},
		tt_phrase = _("TOWER_TRICANNON_4_OVERHEAT_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_TRICANNON_4_OVERHEAT_1_NAME"),
			tt_desc = _("TOWER_TRICANNON_4_OVERHEAT_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_TRICANNON_4_OVERHEAT_2_NAME"),
			tt_desc = _("TOWER_TRICANNON_4_OVERHEAT_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_TRICANNON_4_OVERHEAT_3_NAME"),
			tt_desc = _("TOWER_TRICANNON_4_OVERHEAT_3_DESCRIPTION")
		}}
	}), tpl.sell}},
	-- 暮光长弓
	dark_elf = {{M(tpl.change_mode, {
		image = "kr5_quickmenu_action_icons_0005",
		image_mode0 = "kr5_quickmenu_action_icons_0005",
		image_mode1 = "kr5_quickmenu_action_icons_0004",
		tt_title_mode0 = _("TOWER_DARK_ELF_CHANGE_MODE_FOREMOST_NAME"),
		tt_desc_mode0 = _("TOWER_DARK_ELF_CHANGE_MODE_FOREMOST_DESCRIPTION"),
		tt_phrase_mode0 = _("TOWER_DARK_ELF_CHANGE_MODE_FOREMOST_NOTE"),
		tt_title_mode1 = _("TOWER_DARK_ELF_CHANGE_MODE_MAXHP_NAME"),
		tt_desc_mode1 = _("TOWER_DARK_ELF_CHANGE_MODE_MAXHP_DESCRIPTION"),
		tt_phrase_mode1 = _("TOWER_DARK_ELF_CHANGE_MODE_MAXHP_NOTE")
	}), M(tpl.upgrade_power, {
		action_arg = "skill_soldiers",
		image = "kr5_special_icons_0032",
		place = 6,
		sounds = {"TowerDarkElfSkillATaunt"},
		tt_phrase = _("TOWER_DARK_ELF_4_SKILL_SOLDIERS_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_DARK_ELF_4_SKILL_SOLDIERS_1_NAME"),
			tt_desc = _("TOWER_DARK_ELF_4_SKILL_SOLDIERS_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_DARK_ELF_4_SKILL_SOLDIERS_2_NAME"),
			tt_desc = _("TOWER_DARK_ELF_4_SKILL_SOLDIERS_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_DARK_ELF_4_SKILL_SOLDIERS_3_NAME"),
			tt_desc = _("TOWER_DARK_ELF_4_SKILL_SOLDIERS_3_DESCRIPTION")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "skill_buff",
		image = "kr5_special_icons_0033",
		place = 7,
		sounds = {"TowerDarkElfSkillBTaunt"},
		tt_phrase = _("TOWER_DARK_ELF_4_SKILL_BUFF_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_DARK_ELF_4_SKILL_BUFF_1_NAME"),
			tt_desc = _("TOWER_DARK_ELF_4_SKILL_BUFF_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_DARK_ELF_4_SKILL_BUFF_2_NAME"),
			tt_desc = _("TOWER_DARK_ELF_4_SKILL_BUFF_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_DARK_ELF_4_SKILL_BUFF_3_NAME"),
			tt_desc = _("TOWER_DARK_ELF_4_SKILL_BUFF_3_DESCRIPTION")
		}}
	}), tpl.rally, tpl.sell}},
	-- 恶魔澡坑
	demon_pit = {{M(tpl.upgrade_power, {
		action_arg = "master_exploders",
		image = "kr5_special_icons_0011",
		place = 6,
		sounds = {"TowerDemonPitSkillATaunt"},
		tt_phrase = _("TOWER_DEMON_PIT_4_MASTER_EXPLODERS_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_DEMON_PIT_4_MASTER_EXPLODERS_1_NAME"),
			tt_desc = _("TOWER_DEMON_PIT_4_MASTER_EXPLODERS_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_DEMON_PIT_4_MASTER_EXPLODERS_2_NAME"),
			tt_desc = _("TOWER_DEMON_PIT_4_MASTER_EXPLODERS_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_DEMON_PIT_4_MASTER_EXPLODERS_3_NAME"),
			tt_desc = _("TOWER_DEMON_PIT_4_MASTER_EXPLODERS_3_DESCRIPTION")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "big_guy",
		image = "kr5_special_icons_0012",
		place = 7,
		sounds = {"TowerDemonPitSkillBTaunt"},
		tt_phrase = _("TOWER_DEMON_PIT_4_BIG_DEMON_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_DEMON_PIT_4_BIG_DEMON_1_NAME"),
			tt_desc = _("TOWER_DEMON_PIT_4_BIG_DEMON_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_DEMON_PIT_4_BIG_DEMON_2_NAME"),
			tt_desc = _("TOWER_DEMON_PIT_4_BIG_DEMON_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_DEMON_PIT_4_BIG_DEMON_3_NAME"),
			tt_desc = _("TOWER_DEMON_PIT_4_BIG_DEMON_3_DESCRIPTION")
		}}
	}), tpl.sell}},
	-- 死灵法师
	necromancer_lvl4 = {{M(tpl.upgrade_power, {
		action_arg = "skill_debuff",
		image = "kr5_special_icons_0017",
		place = 6,
		sounds = {"TowerNecromancerSkillATaunt"},
		tt_phrase = _("TOWER_NECROMANCER_4_SKILL_DEBUFF_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_NECROMANCER_4_SKILL_DEBUFF_1_NAME"),
			tt_desc = _("TOWER_NECROMANCER_4_SKILL_DEBUFF_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_NECROMANCER_4_SKILL_DEBUFF_2_NAME"),
			tt_desc = _("TOWER_NECROMANCER_4_SKILL_DEBUFF_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_NECROMANCER_4_SKILL_DEBUFF_3_NAME"),
			tt_desc = _("TOWER_NECROMANCER_4_SKILL_DEBUFF_3_DESCRIPTION")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "skill_rider",
		image = "kr5_special_icons_0018",
		place = 7,
		sounds = {"TowerNecromancerSkillBTaunt"},
		tt_phrase = _("TOWER_NECROMANCER_4_SKILL_RIDER_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_NECROMANCER_4_SKILL_RIDER_1_NAME"),
			tt_desc = _("TOWER_NECROMANCER_4_SKILL_RIDER_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_NECROMANCER_4_SKILL_RIDER_2_NAME"),
			tt_desc = _("TOWER_NECROMANCER_4_SKILL_RIDER_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_NECROMANCER_4_SKILL_RIDER_3_NAME"),
			tt_desc = _("TOWER_NECROMANCER_4_SKILL_RIDER_3_DESCRIPTION")
		}}
	}), tpl.sell}},
	-- 熊猫
	pandas = {{M(tpl.upgrade_power, {
		action_arg = "thunder",
		image = "kr5_special_icons_0041",
		place = 6,
		sounds = {i18n:cjk("TowerPandasSkillATaunt", "TowerPandasSkillATauntZH", nil, nil)},
		tt_phrase = _("TOWER_PANDAS_4_THUNDER"),
		tt_list = {{
			tt_title = _("TOWER_PANDAS_4_THUNDER_1_NAME"),
			tt_desc = _("TOWER_PANDAS_4_THUNDER_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_PANDAS_4_THUNDER_2_NAME"),
			tt_desc = _("TOWER_PANDAS_4_THUNDER_2_DESCRIPTION")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "hat",
		image = "kr5_special_icons_0040",
		place = 5,
		sounds = {i18n:cjk("TowerPandasSkillBTaunt", "TowerPandasSkillBTauntZH", nil, nil)},
		tt_phrase = _("TOWER_PANDAS_4_HAT"),
		tt_list = {{
			tt_title = _("TOWER_PANDAS_4_HAT_1_NAME"),
			tt_desc = _("TOWER_PANDAS_4_HAT_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_PANDAS_4_HAT_2_NAME"),
			tt_desc = _("TOWER_PANDAS_4_HAT_2_DESCRIPTION")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "teleport",
		image = "kr5_special_icons_0042",
		place = 7,
		sounds = {i18n:cjk("TowerPandasSkillCTaunt", "TowerPandasSkillCTauntZH", nil, nil)},
		tt_phrase = _("TOWER_PANDAS_4_FIERY"),
		tt_list = {{
			tt_title = _("TOWER_PANDAS_4_FIERY_1_NAME"),
			tt_desc = _("TOWER_PANDAS_4_FIERY_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_PANDAS_4_FIERY_2_NAME"),
			tt_desc = _("TOWER_PANDAS_4_FIERY_2_DESCRIPTION")
		}}
	}), M(tpl.change_mode, {
		check = "kr5_special_icons_0020",
		action_arg = "pandas_retreat",
		image = "kr5_quickmenu_action_icons_0006",
		tt_title = _("TOWER_PANDAS_RETREAT_NAME"),
		tt_desc = _("TOWER_PANDAS_RETREAT_DESCRIPTION")
	}), tpl.rally, tpl.sell}},
	-- 红法
	ray = {{M(tpl.upgrade_power, {
		action_arg = "chain",
		image = "kr5_special_icons_0030",
		place = 6,
		sounds = {"TowerRaySkillATaunt"},
		tt_phrase = _("TOWER_RAY_4_CHAIN_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_RAY_4_CHAIN_1_NAME"),
			tt_desc = _("TOWER_RAY_4_CHAIN_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_RAY_4_CHAIN_2_NAME"),
			tt_desc = _("TOWER_RAY_4_CHAIN_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_RAY_4_CHAIN_3_NAME"),
			tt_desc = _("TOWER_RAY_4_CHAIN_3_DESCRIPTION")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "sheep",
		image = "kr5_special_icons_0031",
		place = 7,
		sounds = {"TowerRaySkillBTaunt"},
		tt_phrase = _("TOWER_RAY_4_SHEEP_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_RAY_4_SHEEP_1_NAME"),
			tt_desc = _("TOWER_RAY_4_SHEEP_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_RAY_4_SHEEP_2_NAME"),
			tt_desc = _("TOWER_RAY_4_SHEEP_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_RAY_4_SHEEP_3_NAME"),
			tt_desc = _("TOWER_RAY_4_SHEEP_3_DESCRIPTION")
		}}
	}), tpl.sell}},
	elven_stargazers = {{M(tpl.upgrade_power, {
		action_arg = "teleport",
		image = "kr5_special_icons_0013",
		place = 6,
		sounds = {"TowerElvenStargazersSkillATaunt"},
		tt_phrase = _("TOWER_STARGAZER_4_EVENT_HORIZON_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_STARGAZER_4_EVENT_HORIZON_1_NAME"),
			tt_desc = _("TOWER_STARGAZER_4_EVENT_HORIZON_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_STARGAZER_4_EVENT_HORIZON_2_NAME"),
			tt_desc = _("TOWER_STARGAZER_4_EVENT_HORIZON_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_STARGAZER_4_EVENT_HORIZON_3_NAME"),
			tt_desc = _("TOWER_STARGAZER_4_EVENT_HORIZON_3_DESCRIPTION")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "stars_death",
		image = "kr5_special_icons_0014",
		place = 7,
		sounds = {"TowerElvenStargazersSkillBTaunt"},
		tt_phrase = _("TOWER_STARGAZER_4_RISING_STAR_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_STARGAZER_4_RISING_STAR_1_NAME"),
			tt_desc = _("TOWER_STARGAZER_4_RISING_STAR_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_STARGAZER_4_RISING_STAR_2_NAME"),
			tt_desc = _("TOWER_STARGAZER_4_RISING_STAR_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_STARGAZER_4_RISING_STAR_3_NAME"),
			tt_desc = _("TOWER_STARGAZER_4_RISING_STAR_3_DESCRIPTION")
		}}
	}), tpl.sell}},
	sand = {{M(tpl.upgrade_power, {
		action_arg = "skill_gold",
		image = "kr5_special_icons_0028",
		place = 6,
		sounds = {"TowerSandSkillATaunt"},
		tt_phrase = _("TOWER_SAND_4_SKILL_GOLD_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_SAND_4_SKILL_GOLD_1_NAME"),
			tt_desc = _("TOWER_SAND_4_SKILL_GOLD_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_SAND_4_SKILL_GOLD_2_NAME"),
			tt_desc = _("TOWER_SAND_4_SKILL_GOLD_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_SAND_4_SKILL_GOLD_3_NAME"),
			tt_desc = _("TOWER_SAND_4_SKILL_GOLD_3_DESCRIPTION")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "skill_big_blade",
		image = "kr5_special_icons_0029",
		place = 7,
		sounds = {"TowerSandSkillBTaunt"},
		tt_phrase = _("TOWER_SAND_4_SKILL_BIG_BLADE_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_SAND_4_SKILL_BIG_BLADE_1_NAME"),
			tt_desc = _("TOWER_SAND_4_SKILL_BIG_BLADE_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_SAND_4_SKILL_BIG_BLADE_2_NAME"),
			tt_desc = _("TOWER_SAND_4_SKILL_BIG_BLADE_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_SAND_4_SKILL_BIG_BLADE_3_NAME"),
			tt_desc = _("TOWER_SAND_4_SKILL_BIG_BLADE_3_DESCRIPTION")
		}}
	}), tpl.sell}},
	royal_archers = {{M(tpl.upgrade_power, {
		action_arg = "armor_piercer",
		image = "kr5_special_icons_0003",
		place = 6,
		sounds = {"TowerRoyalArchersSkillATaunt"},
		tt_phrase = _("TOWER_ROYAL_ARCHERS_4_ARMOR_PIERCER_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_ROYAL_ARCHERS_4_ARMOR_PIERCER_1_NAME"),
			tt_desc = _("TOWER_ROYAL_ARCHERS_4_ARMOR_PIERCER_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_ROYAL_ARCHERS_4_ARMOR_PIERCER_2_NAME"),
			tt_desc = _("TOWER_ROYAL_ARCHERS_4_ARMOR_PIERCER_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_ROYAL_ARCHERS_4_ARMOR_PIERCER_3_NAME"),
			tt_desc = _("TOWER_ROYAL_ARCHERS_4_ARMOR_PIERCER_3_DESCRIPTION")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "rapacious_hunter",
		image = "kr5_special_icons_0004",
		place = 7,
		sounds = {"TowerRoyalArchersSkillBTaunt"},
		tt_phrase = _("TOWER_ROYAL_ARCHERS_4_RAPACIOUS_HUNTER_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_ROYAL_ARCHERS_4_RAPACIOUS_HUNTER_1_NAME"),
			tt_desc = _("TOWER_ROYAL_ARCHERS_4_RAPACIOUS_HUNTER_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_ROYAL_ARCHERS_4_RAPACIOUS_HUNTER_2_NAME"),
			tt_desc = _("TOWER_ROYAL_ARCHERS_4_RAPACIOUS_HUNTER_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_ROYAL_ARCHERS_4_RAPACIOUS_HUNTER_3_NAME"),
			tt_desc = _("TOWER_ROYAL_ARCHERS_4_RAPACIOUS_HUNTER_3_DESCRIPTION")
		}}
	}), tpl.sell}},
	arcane_wizard_five = {{M(tpl.upgrade_power, {
		action_arg = "disintegrate",
		image = "kr5_special_icons_0005",
		place = 6,
		sounds = {"TowerArcaneWizardSkillATaunt"},
		tt_phrase = _("TOWER_ARCANE_WIZARD_4_DISINTEGRATE_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_ARCANE_WIZARD_4_DISINTEGRATE_1_NAME"),
			tt_desc = _("TOWER_ARCANE_WIZARD_4_DISINTEGRATE_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_ARCANE_WIZARD_4_DISINTEGRATE_2_NAME"),
			tt_desc = _("TOWER_ARCANE_WIZARD_4_DISINTEGRATE_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_ARCANE_WIZARD_4_DISINTEGRATE_3_NAME"),
			tt_desc = _("TOWER_ARCANE_WIZARD_4_DISINTEGRATE_3_DESCRIPTION")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "empowerment",
		image = "kr5_special_icons_0006",
		place = 7,
		sounds = {"TowerArcaneWizardSkillBTaunt"},
		tt_phrase = _("TOWER_ARCANE_WIZARD_4_EMPOWERMENT_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_ARCANE_WIZARD_4_EMPOWERMENT_1_NAME"),
			tt_desc = _("TOWER_ARCANE_WIZARD_4_EMPOWERMENT_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_ARCANE_WIZARD_4_EMPOWERMENT_2_NAME"),
			tt_desc = _("TOWER_ARCANE_WIZARD_4_EMPOWERMENT_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_ARCANE_WIZARD_4_EMPOWERMENT_3_NAME"),
			tt_desc = _("TOWER_ARCANE_WIZARD_4_EMPOWERMENT_3_DESCRIPTION")
		}}
	}), tpl.sell}},
	rocket_gunners = {{M(tpl.upgrade_power, {
		action_arg = "sting_missiles",
		image = "kr5_special_icons_0015",
		place = 6,
		sounds = {"TowerRocketGunnersSkillATaunt"},
		tt_phrase = _("TOWER_ROCKET_GUNNERS_4_STING_MISSILES_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_ROCKET_GUNNERS_4_STING_MISSILES_1_NAME"),
			tt_desc = _("TOWER_ROCKET_GUNNERS_4_STING_MISSILES_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_ROCKET_GUNNERS_4_STING_MISSILES_2_NAME"),
			tt_desc = _("TOWER_ROCKET_GUNNERS_4_STING_MISSILES_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_ROCKET_GUNNERS_4_STING_MISSILES_3_NAME"),
			tt_desc = _("TOWER_ROCKET_GUNNERS_4_STING_MISSILES_3_DESCRIPTION")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "phosphoric",
		image = "kr5_special_icons_0016",
		place = 7,
		sounds = {"TowerRocketGunnersSkillBTaunt"},
		tt_phrase = _("TOWER_ROCKET_GUNNERS_4_PHOSPHORIC_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_ROCKET_GUNNERS_4_PHOSPHORIC_1_NAME"),
			tt_desc = _("TOWER_ROCKET_GUNNERS_4_PHOSPHORIC_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_ROCKET_GUNNERS_4_PHOSPHORIC_2_NAME"),
			tt_desc = _("TOWER_ROCKET_GUNNERS_4_PHOSPHORIC_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_ROCKET_GUNNERS_4_PHOSPHORIC_3_NAME"),
			tt_desc = _("TOWER_ROCKET_GUNNERS_4_PHOSPHORIC_3_DESCRIPTION")
		}}
	}), tpl.rally, tpl.sell, M(tpl.change_mode, {
		image = "kr5_quickmenu_action_icons_0002",
		image_mode0 = "kr5_quickmenu_action_icons_0002",
		image_mode1 = "kr5_quickmenu_action_icons_0001",
		tt_title_mode0 = _("TOWER_ROCKET_GUNNERS_CHANGE_MODE_GROUND_NAME"),
		tt_desc_mode0 = _("TOWER_ROCKET_GUNNERS_CHANGE_MODE_GROUND_DESCRIPTION"),
		tt_phrase_mode0 = _("TOWER_ROCKET_GUNNERS_CHANGE_MODE_GROUND_NOTE"),
		tt_title_mode1 = _("TOWER_ROCKET_GUNNERS_CHANGE_MODE_FLY_NAME"),
		tt_desc_mode1 = _("TOWER_ROCKET_GUNNERS_CHANGE_MODE_FLY_DESCRIPTION"),
		tt_phrase_mode1 = _("TOWER_ROCKET_GUNNERS_CHANGE_MODE_FLY_NOTE"),
		sounds = {"TowerRocketGunnersLiftoffTaunt", "TowerRocketGunnersTouchdownTaunt"}
	})}},
	flamespitter = {{M(tpl.upgrade_power, {
		action_arg = "skill_bomb",
		image = "kr5_special_icons_0022",
		place = 7,
		sounds = {"TowerFlamespitterSkillATaunt"},
		tt_phrase = _("TOWER_FLAMESPITTER_4_SKILL_BOMB_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_FLAMESPITTER_4_SKILL_BOMB_1_NAME"),
			tt_desc = _("TOWER_FLAMESPITTER_4_SKILL_BOMB_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_FLAMESPITTER_4_SKILL_BOMB_2_NAME"),
			tt_desc = _("TOWER_FLAMESPITTER_4_SKILL_BOMB_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_FLAMESPITTER_4_SKILL_BOMB_3_NAME"),
			tt_desc = _("TOWER_FLAMESPITTER_4_SKILL_BOMB_3_DESCRIPTION")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "skill_columns",
		image = "kr5_special_icons_0023",
		place = 6,
		sounds = {"TowerFlamespitterSkillBTaunt"},
		tt_phrase = _("TOWER_FLAMESPITTER_4_SKILL_COLUMNS_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_FLAMESPITTER_4_SKILL_COLUMNS_1_NAME"),
			tt_desc = _("TOWER_FLAMESPITTER_4_SKILL_COLUMNS_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_FLAMESPITTER_4_SKILL_COLUMNS_2_NAME"),
			tt_desc = _("TOWER_FLAMESPITTER_4_SKILL_COLUMNS_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_FLAMESPITTER_4_SKILL_COLUMNS_3_NAME"),
			tt_desc = _("TOWER_FLAMESPITTER_4_SKILL_COLUMNS_3_DESCRIPTION")
		}}
	}), tpl.sell}},
	ballista = {{M(tpl.upgrade_power, {
		action_arg = "skill_final_shot",
		image = "kr5_special_icons_0019",
		place = 6,
		sounds = {"TowerBallistaSkillATaunt"},
		tt_phrase = _("TOWER_BALLISTA_4_SKILL_FINAL_SHOT_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_BALLISTA_4_SKILL_FINAL_SHOT_1_NAME"),
			tt_desc = _("TOWER_BALLISTA_4_SKILL_FINAL_SHOT_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_BALLISTA_4_SKILL_FINAL_SHOT_2_NAME"),
			tt_desc = _("TOWER_BALLISTA_4_SKILL_FINAL_SHOT_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_BALLISTA_4_SKILL_FINAL_SHOT_3_NAME"),
			tt_desc = _("TOWER_BALLISTA_4_SKILL_FINAL_SHOT_3_DESCRIPTION")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "skill_bomb",
		image = "kr5_special_icons_0021",
		place = 7,
		sounds = {"TowerBallistaSkillBTaunt"},
		tt_phrase = _("TOWER_BALLISTA_4_SKILL_BOMB_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_BALLISTA_4_SKILL_BOMB_1_NAME"),
			tt_desc = _("TOWER_BALLISTA_4_SKILL_BOMB_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_BALLISTA_4_SKILL_BOMB_2_NAME"),
			tt_desc = _("TOWER_BALLISTA_4_SKILL_BOMB_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_BALLISTA_4_SKILL_BOMB_3_NAME"),
			tt_desc = _("TOWER_BALLISTA_4_SKILL_BOMB_3_DESCRIPTION")
		}}
	}), tpl.sell}},
	barrel = {{M(tpl.upgrade_power, {
		action_arg = "skill_warrior",
		image = "kr5_special_icons_0026",
		place = 6,
		sounds = {"TowerBarrelSkillATaunt"},
		tt_phrase = _("TOWER_BARREL_4_SKILL_WARRIOR_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_BARREL_4_SKILL_WARRIOR_1_NAME"),
			tt_desc = _("TOWER_BARREL_4_SKILL_WARRIOR_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_BARREL_4_SKILL_WARRIOR_2_NAME"),
			tt_desc = _("TOWER_BARREL_4_SKILL_WARRIOR_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_BARREL_4_SKILL_WARRIOR_3_NAME"),
			tt_desc = _("TOWER_BARREL_4_SKILL_WARRIOR_3_DESCRIPTION")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "skill_barrel",
		image = "kr5_special_icons_0027",
		place = 7,
		sounds = {"TowerBarrelSkillBTaunt"},
		tt_phrase = _("TOWER_BARREL_4_SKILL_BARREL_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_BARREL_4_SKILL_BARREL_1_NAME"),
			tt_desc = _("TOWER_BARREL_4_SKILL_BARREL_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_BARREL_4_SKILL_BARREL_2_NAME"),
			tt_desc = _("TOWER_BARREL_4_SKILL_BARREL_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_BARREL_4_SKILL_BARREL_3_NAME"),
			tt_desc = _("TOWER_BARREL_4_SKILL_BARREL_3_DESCRIPTION")
		}}
	}), tpl.rally, tpl.sell}},
	hermit_toad = {{M(tpl.upgrade_power, {
		action_arg = "jump",
		image = "kr5_special_icons_0035",
		place = 6,
		sounds = {"TowerHermitToadSkillATaunt"},
		tt_phrase = _("TOWER_HERMIT_TOAD_4_SKILL_JUMP_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_HERMIT_TOAD_4_SKILL_JUMP_1_NAME"),
			tt_desc = _("TOWER_HERMIT_TOAD_4_SKILL_JUMP_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_HERMIT_TOAD_4_SKILL_JUMP_2_NAME"),
			tt_desc = _("TOWER_HERMIT_TOAD_4_SKILL_JUMP_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_HERMIT_TOAD_4_SKILL_JUMP_3_NAME"),
			tt_desc = _("TOWER_HERMIT_TOAD_4_SKILL_JUMP_3_DESCRIPTION")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "instakill",
		place = 7,
		image = "kr5_special_icons_0034",
		sounds = {"TowerHermitToadSkillBTaunt"},
		tt_phrase = _("TOWER_HERMIT_TOAD_4_SKILL_INSTAKILL_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_HERMIT_TOAD_4_SKILL_INSTAKILL_1_NAME"),
			tt_desc = _("TOWER_HERMIT_TOAD_4_SKILL_INSTAKILL_1_DESCRIPTION")
		}}
	}), M(tpl.change_mode, {
		image = "kr5_quickmenu_action_icons_0008",
		image_mode0 = "kr5_quickmenu_action_icons_0008",
		image_mode1 = "kr5_quickmenu_action_icons_0007",
		tt_title_mode0 = _("TOWER_HERMIT_TOAD_CHANGE_MODE_ENGINEER_NAME"),
		tt_desc_mode0 = _("TOWER_HERMIT_TOAD_CHANGE_MODE_ENGINEER_DESCRIPTION"),
		tt_phrase_mode0 = _("TOWER_HERMIT_TOAD_CHANGE_MODE_ENGINEER_NOTE"),
		tt_title_mode1 = _("TOWER_HERMIT_TOAD_CHANGE_MODE_MAGE_NAME"),
		tt_desc_mode1 = _("TOWER_HERMIT_TOAD_CHANGE_MODE_MAGE_DESCRIPTION"),
		tt_phrase_mode1 = _("TOWER_HERMIT_TOAD_CHANGE_MODE_MAGE_NOTE"),
		sounds = {"TowerHermitToadSwitchToArtillery", "TowerHermitToadSwitchToMage"}
	}), tpl.sell}},
	sparking_geode = {{M(tpl.upgrade_power, {
		check = "special_icons_0020",
		action_arg = "crystalize",
		image = "kr5_special_icons_0038",
		place = 6,
		sounds = {"TowerSparkingGeodeSkillATaunt"},
		tt_phrase = _("TOWER_SPARKING_GEODE_4_CRYSTALIZE"),
		tt_list = {{
			tt_title = _("TOWER_SPARKING_GEODE_4_CRYSTALIZE_1_NAME"),
			tt_desc = _("TOWER_SPARKING_GEODE_4_CRYSTALIZE_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_SPARKING_GEODE_4_CRYSTALIZE_2_NAME"),
			tt_desc = _("TOWER_SPARKING_GEODE_4_CRYSTALIZE_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_SPARKING_GEODE_4_CRYSTALIZE_3_NAME"),
			tt_desc = _("TOWER_SPARKING_GEODE_4_CRYSTALIZE_3_DESCRIPTION")
		}}
	}), M(tpl.upgrade_power, {
		check = "special_icons_0020",
		action_arg = "spike_burst",
		image = "kr5_special_icons_0039",
		place = 7,
		sounds = {"TowerSparkingGeodeSkillBTaunt"},
		tt_phrase = _("TOWER_SPARKING_GEODE_4_SPIKE_BURST"),
		tt_list = {{
			tt_title = _("TOWER_SPARKING_GEODE_4_SPIKE_BURST_1_NAME"),
			tt_desc = _("TOWER_SPARKING_GEODE_4_SPIKE_BURST_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_SPARKING_GEODE_4_SPIKE_BURST_2_NAME"),
			tt_desc = _("TOWER_SPARKING_GEODE_4_SPIKE_BURST_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_SPARKING_GEODE_4_SPIKE_BURST_3_NAME"),
			tt_desc = _("TOWER_SPARKING_GEODE_4_SPIKE_BURST_3_DESCRIPTION")
		}}
	}), tpl.sell}},
	dwarf = {{M(tpl.upgrade_power, {
		check = "special_icons_0020",
		action_arg = "formation",
		image = "kr5_special_icons_0036",
		place = 6,
		sounds = {"TowerDwarfSkillATaunt"},
		tt_phrase = _("TOWER_DWARF_4_FORMATION_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_DWARF_4_FORMATION_1_NAME"),
			tt_desc = _("TOWER_DWARF_4_FORMATION_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_DWARF_4_FORMATION_2_NAME"),
			tt_desc = _("TOWER_DWARF_4_FORMATION_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_DWARF_4_FORMATION_3_NAME"),
			tt_desc = _("TOWER_DWARF_4_FORMATION_3_DESCRIPTION")
		}}
	}), M(tpl.upgrade_power, {
		check = "special_icons_0020",
		action_arg = "incendiary_ammo",
		image = "kr5_special_icons_0037",
		place = 7,
		sounds = {"TowerDwarfSkillBTaunt"},
		tt_phrase = _("TOWER_DWARF_4_INCENDIARY_AMMO_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_DWARF_4_INCENDIARY_AMMO_1_NAME"),
			tt_desc = _("TOWER_DWARF_4_INCENDIARY_AMMO_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_DWARF_4_INCENDIARY_AMMO_2_NAME"),
			tt_desc = _("TOWER_DWARF_4_INCENDIARY_AMMO_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_DWARF_4_INCENDIARY_AMMO_3_NAME"),
			tt_desc = _("TOWER_DWARF_4_INCENDIARY_AMMO_3_DESCRIPTION")
		}}
	}), tpl.rally, tpl.sell}},
	ghost = {{M(tpl.upgrade_power, {
		action_arg = "extra_damage",
		image = "kr5_special_icons_0024",
		place = 6,
		sounds = {"TowerGhostSkillATaunt"},
		tt_phrase = _("TOWER_GHOST_4_EXTRA_DAMAGE_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_GHOST_4_EXTRA_DAMAGE_1_NAME"),
			tt_desc = _("TOWER_GHOST_4_EXTRA_DAMAGE_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_GHOST_4_EXTRA_DAMAGE_2_NAME"),
			tt_desc = _("TOWER_GHOST_4_EXTRA_DAMAGE_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_GHOST_4_EXTRA_DAMAGE_3_NAME"),
			tt_desc = _("TOWER_GHOST_4_EXTRA_DAMAGE_3_DESCRIPTION")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "soul_attack",
		image = "kr5_special_icons_0025",
		place = 7,
		sounds = {"TowerGhostSkillBTaunt"},
		tt_phrase = _("TOWER_GHOST_4_SOUL_ATTACK_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_GHOST_4_SOUL_ATTACK_1_NAME"),
			tt_desc = _("TOWER_GHOST_4_SOUL_ATTACK_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_GHOST_4_SOUL_ATTACK_2_NAME"),
			tt_desc = _("TOWER_GHOST_4_SOUL_ATTACK_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_GHOST_4_SOUL_ATTACK_3_NAME"),
			tt_desc = _("TOWER_GHOST_4_SOUL_ATTACK_3_DESCRIPTION")
		}}
	}), tpl.rally, tpl.sell, M(tpl.change_mode, {
		image = "kr5_quickmenu_action_icons_0003",
		tt_title = _("TOWER_GHOST_SWAP_MODE_NAME"),
		tt_desc = _("TOWER_GHOST_SWAP_MODE_DESCRIPTION"),
		tt_phrase = _("TOWER_GHOST_SWAP_MODE_NODE")
	})}},
	paladin_covenant = {{M(tpl.upgrade_power, {
		action_arg = "lead",
		image = "kr5_special_icons_0002",
		place = 6,
		sounds = {"TowerPaladinCovenantSkillATaunt"},
		tt_phrase = _("TOWER_PALADIN_COVENANT_4_LEAD_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_PALADIN_COVENANT_4_LEAD_1_NAME"),
			tt_desc = _("TOWER_PALADIN_COVENANT_4_LEAD_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_PALADIN_COVENANT_4_LEAD_2_NAME"),
			tt_desc = _("TOWER_PALADIN_COVENANT_4_LEAD_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_PALADIN_COVENANT_4_LEAD_3_NAME"),
			tt_desc = _("TOWER_PALADIN_COVENANT_4_LEAD_3_DESCRIPTION")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "healing_prayer",
		image = "kr5_special_icons_0001",
		place = 7,
		sounds = {"TowerPaladinCovenantSkillBTaunt"},
		tt_phrase = _("TOWER_PALADIN_COVENANT_4_HEALING_PRAYER_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_PALADIN_COVENANT_4_HEALING_PRAYER_1_NAME"),
			tt_desc = _("TOWER_PALADIN_COVENANT_4_HEALING_PRAYER_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_PALADIN_COVENANT_4_HEALING_PRAYER_2_NAME"),
			tt_desc = _("TOWER_PALADIN_COVENANT_4_HEALING_PRAYER_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_PALADIN_COVENANT_4_HEALING_PRAYER_3_NAME"),
			tt_desc = _("TOWER_PALADIN_COVENANT_4_HEALING_PRAYER_3_DESCRIPTION")
		}}
	}), tpl.rally, tpl.sell}},
	arborean_emissary = {{M(tpl.upgrade_power, {
		action_arg = "gift_of_nature",
		image = "kr5_special_icons_0010",
		place = 6,
		sounds = {"TowerArboreanEmissarySkillATaunt"},
		tt_phrase = _("TOWER_ARBOREAN_EMISSARY_4_GIFT_OF_NATURE_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_ARBOREAN_EMISSARY_4_GIFT_OF_NATURE_1_NAME"),
			tt_desc = _("TOWER_ARBOREAN_EMISSARY_4_GIFT_OF_NATURE_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_ARBOREAN_EMISSARY_4_GIFT_OF_NATURE_2_NAME"),
			tt_desc = _("TOWER_ARBOREAN_EMISSARY_4_GIFT_OF_NATURE_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_ARBOREAN_EMISSARY_4_GIFT_OF_NATURE_3_NAME"),
			tt_desc = _("TOWER_ARBOREAN_EMISSARY_4_GIFT_OF_NATURE_3_DESCRIPTION")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "wave_of_roots",
		image = "kr5_special_icons_0009",
		place = 7,
		sounds = {"TowerArboreanEmissarySkillBTaunt"},
		tt_phrase = _("TOWER_ARBOREAN_EMISSARY_4_WAVE_OF_ROOTS_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_ARBOREAN_EMISSARY_4_WAVE_OF_ROOTS_1_NAME"),
			tt_desc = _("TOWER_ARBOREAN_EMISSARY_4_WAVE_OF_ROOTS_1_DESCRIPTION")
		}, {
			tt_title = _("TOWER_ARBOREAN_EMISSARY_4_WAVE_OF_ROOTS_2_NAME"),
			tt_desc = _("TOWER_ARBOREAN_EMISSARY_4_WAVE_OF_ROOTS_2_DESCRIPTION")
		}, {
			tt_title = _("TOWER_ARBOREAN_EMISSARY_4_WAVE_OF_ROOTS_3_NAME"),
			tt_desc = _("TOWER_ARBOREAN_EMISSARY_4_WAVE_OF_ROOTS_3_DESCRIPTION")
		}}
	}), tpl.sell}},
	holder_blocked_elemental_wood = {{M(tpl.unblock, {
		action_arg = "tower_holder_elemental_wood",
		image = "kr5_main_icons_0045",
		tt_title = _("SPECIAL_REPAIR_HOLDER_ELEMENTAL_WOOD_NAME"),
		tt_desc = _("SPECIAL_REPAIR_HOLDER_ELEMENTAL_WOOD_DESCRIPTION")
	})}},
	holder_blocked_elemental_wood_enhance = {{M(tpl.unblock, {
		action_arg = "tower_holder_elemental_wood_enhance",
		image = "kr5_main_icons_0045",
		tt_title = _("SPECIAL_REPAIR_HOLDER_ELEMENTAL_WOOD_NAME"),
		tt_desc = _("SPECIAL_REPAIR_HOLDER_ELEMENTAL_WOOD_DESCRIPTION")
	})}},
	holder_blocked_elemental_fire = {{M(tpl.unblock, {
		action_arg = "tower_holder_elemental_fire",
		image = "kr5_main_icons_0044",
		tt_title = _("SPECIAL_REPAIR_HOLDER_ELEMENTAL_FIRE_NAME"),
		tt_desc = _("SPECIAL_REPAIR_HOLDER_ELEMENTAL_FIRE_DESCRIPTION")
	})}},
	holder_blocked_elemental_water = {{M(tpl.unblock, {
		action_arg = "tower_holder_elemental_water",
		image = "kr5_main_icons_0046",
		tt_title = _("SPECIAL_REPAIR_HOLDER_ELEMENTAL_WATER_NAME"),
		tt_desc = _("SPECIAL_REPAIR_HOLDER_ELEMENTAL_WATER_DESCRIPTION")
	})}},
	holder_blocked_elemental_earth = {{M(tpl.unblock, {
		action_arg = "tower_holder_elemental_earth",
		image = "kr5_main_icons_0050",
		tt_title = _("SPECIAL_REPAIR_HOLDER_ELEMENTAL_EARTH_NAME"),
		tt_desc = _("SPECIAL_REPAIR_HOLDER_ELEMENTAL_EARTH_DESCRIPTION")
	})}},
	holder_blocked_elemental_metal = {{M(tpl.unblock, {
		action_arg = "tower_holder_elemental_metal",
		image = "kr5_main_icons_0047",
		tt_title = _("SPECIAL_REPAIR_HOLDER_ELEMENTAL_METAL_NAME"),
		tt_desc = _("SPECIAL_REPAIR_HOLDER_ELEMENTAL_METAL_DESCRIPTION")
	})}},
	tower_arborean_sentinels = {{M(tpl.buy_soldier, {
		action_arg = "soldier_arborean_sentinels_spearmen",
		image = "kr5_main_icons_0105",
		tt_title = _("SPECIAL_ARBOREAN_SENTINELS_SPEARMEN_NAME"),
		tt_desc = _("SPECIAL_ARBOREAN_SENTINELS_SPEARMEN_DESCRIPTION")
	}), tpl.rally, tpl.sell}},
	stage_11_veznan = {{{
		action_arg = 1,
		action = "tw_free_action",
		halo = "glow_ico_main",
		image = "veznan_skill_icons_ingame_skill_veznan_icon_01",
		place = 6,
		tt_title = _("SPECIAL_STAGE_11_VEZNAN_ABILITY_NAME_1"),
		tt_desc = _("SPECIAL_STAGE_11_VEZNAN_ABILITY_DESCRIPTION_1")
	}, {
		action_arg = 2,
		action = "tw_free_action",
		halo = "glow_ico_main",
		image = "veznan_skill_icons_ingame_skill_veznan_icon_02",
		place = 5,
		tt_title = _("SPECIAL_STAGE_11_VEZNAN_ABILITY_NAME_2"),
		tt_desc = _("SPECIAL_STAGE_11_VEZNAN_ABILITY_DESCRIPTION_2")
	}, {
		action_arg = 3,
		action = "tw_free_action",
		halo = "glow_ico_main",
		image = "veznan_skill_icons_ingame_skill_veznan_icon_03",
		place = 7,
		tt_title = _("SPECIAL_STAGE_11_VEZNAN_ABILITY_NAME_3"),
		tt_desc = _("SPECIAL_STAGE_11_VEZNAN_ABILITY_DESCRIPTION_3")
	}}},
	tower_stage_13_sunray = {{{
		action_arg = "",
		action = "tw_repair",
		halo = "glow_ico_main",
		image = "kr5_main_icons_0030",
		place = 5,
		tt_title = _("TOWER_STAGE_13_SUNRAY_REPAIR_NAME"),
		tt_desc = _("TOWER_STAGE_13_SUNRAY_REPAIR_DESCRIPTION")
	}}},
	tower_stage_18_elven_barrack = {{{
		check = "main_icons_0019",
		action_arg = "soldier_tower_stage_18_elven_barrack",
		action = "tw_buy_soldier",
		halo = "glow_ico_main",
		image = "kr5_main_icons_0033",
		place = 5,
		tt_title = _("SPECIAL_SOLDIER_TOWER_ELVEN_BARRACK_NAME"),
		tt_desc = _("SPECIAL_SOLDIER_TOWER_ELVEN_BARRACK_DESCRIPTION")
	}, tpl.rally}},
	arborean_oldtree = {{{
		check = "main_icons_0019",
		action_arg = 1,
		action = "tw_buy_attack",
		halo = "glow_ico_main",
		image = "kr5_main_icons_0038",
		place = 5,
		tt_title = _("SPECIAL_ARBOREAN_OLDTREE_NAME"),
		tt_desc = _("SPECIAL_ARBOREAN_OLDTREE_DESCRIPTION")
	}}},
	arborean_barrack = {{{
		check = "main_icons_0019",
		action_arg = 1,
		action = "tw_buy_attack",
		halo = "glow_ico_main",
		image = "kr5_main_icons_0036",
		place = 5,
		tt_title = _("SPECIAL_ARBOREAN_BARRACK_NAME"),
		tt_desc = _("SPECIAL_ARBOREAN_BARRACK_DESCRIPTION")
	}}},
	arborean_honey = {{{
		check = "main_icons_0019",
		action_arg = "",
		action = "tw_repair",
		halo = "glow_ico_main",
		image = "kr5_main_icons_0037",
		place = 5,
		tt_title = _("SPECIAL_ARBOREAN_HONEY_NAME"),
		tt_desc = _("SPECIAL_ARBOREAN_HONEY_DESCRIPTION")
	}}},
	tower_broken_stage_22 = {{{
		check = "main_icons_0019",
		action_arg = "",
		action = "tw_repair",
		halo = "glow_ico_main",
		image = "kr5_main_icons_0015",
		place = 5,
		tt_title = _("TOWER_CROCS_EATEN_NAME"),
		tt_desc = _("TOWER_CROCS_EATEN_DESCRIPTION")
	}}},
	tower_priests_barrack = {{M(tpl.buy_soldier, {
		image = "kr5_main_icons_0041",
		action_arg = "soldier_priests_barrack",
		tt_title = _("SPECIAL_PRIESTS_SOLDIERS_NAME"),
		tt_desc = _("TOWER_STAGE_28_PRIESTS_BARRACK_DESCRIPTION")
	}), tpl.rally, tpl.sell}},
	holder_blocked_spiders = {{M(tpl.unblock, {
		action_arg = "tower_holder",
		image = "main_icons_0037",
		tt_title = _("SPECIAL_REPAIR_HOLDER_SPIDERS_NAME"),
		tt_desc = _("SPECIAL_REPAIR_HOLDER_SPIDERS_DESCRIPTION")
	})}},
	tower_broken_stage_32 = {{{
		check = "main_icons_0019",
		action_arg = "",
		action = "tw_repair",
		halo = "glow_ico_main",
		image = "kr5_main_icons_0035",
		place = 5,
		tt_title = _("SPECIAL_REPAIR_HOLDER_DRAGON_NAME"),
		tt_desc = _("SPECIAL_REPAIR_HOLDER_DRAGON_DESCRIPTION")
	}}}
}
