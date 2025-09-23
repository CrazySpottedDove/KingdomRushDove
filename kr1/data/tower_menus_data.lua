-- chunkname: @./kr1/data/tower_menus_data.lua
return {
    holder = {{{
        check = "main_icons_0019",
        action_arg = "tower_build_archer",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0001",
        place = 1,
        preview = "archer",
        tt_title = _("TOWER_ARCHER_1_NAME"),
        tt_desc = _("TOWER_ARCHER_1_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_build_barrack",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0002",
        place = 2,
        preview = "barrack",
        tt_title = _("TOWER_BARRACK_1_NAME"),
        tt_desc = _("TOWER_BARRACK_1_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_build_mage",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0003",
        place = 3,
        preview = "mage",
        tt_title = _("TOWER_MAGE_1_NAME"),
        tt_desc = _("TOWER_MAGE_1_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_build_engineer",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0004",
        place = 4,
        preview = "engineer",
        tt_title = _("TOWER_ENGINEER_1_NAME"),
        tt_desc = _("TOWER_ENGINEER_1_DESCRIPTION")
    }}},
    holder_blocked_jungle = {{{
        check = "main_icons_0019",
        action_arg = "tower_holder",
        action = "tw_unblock",
        halo = "glow_ico_main",
        image = "main_icons_0037",
        place = 5,
        tt_title = _("SPECIAL_REPAIR_HOLDER_JUNGLE_NAME"),
        tt_desc = _("SPECIAL_REPAIR_HOLDER_JUNGLE_DESCRIPTION")
    }}},
    holder_blocked_underground = {{{
        check = "main_icons_0019",
        action_arg = "tower_holder",
        action = "tw_unblock",
        halo = "glow_ico_main",
        image = "main_icons_0037",
        place = 5,
        tt_title = _("SPECIAL_REPAIR_HOLDER_UNDERGROUND_NAME"),
        tt_desc = _("SPECIAL_REPAIR_HOLDER_UNDERGROUND_DESCRIPTION")
    }}},
    mage = {{{
        check = "main_icons_0019",
        action_arg = "tower_mage_2",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0005",
        place = 5,
        tt_title = _("TOWER_MAGE_2_NAME"),
        tt_desc = _("TOWER_MAGE_2_DESCRIPTION")
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}, {{
        check = "main_icons_0019",
        action_arg = "tower_mage_3",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0005",
        place = 5,
        tt_title = _("TOWER_MAGE_3_NAME"),
        tt_desc = _("TOWER_MAGE_3_DESCRIPTION")
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}, {{
        check = "main_icons_0019",
        action_arg = "tower_arcane_wizard",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0006",
        place = 5,
        tt_title = _("TOWER_ARCANE_NAME"),
        tt_desc = _("TOWER_ARCANE_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_sorcerer",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0007",
        place = 6,
        tt_title = _("TOWER_SORCERER_NAME"),
        tt_desc = _("TOWER_SORCERER_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_sunray",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0018",
        place = 7,
        tt_title = _("日光之塔"),
        tt_desc = _("巫师能借助日光之塔瓦解敌人，并炼制成金，提取力量。")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_necromancer",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0021",
        place = 10,
        tt_title = _("TOWER_NECROMANCER_NAME"),
        tt_desc = _("TOWER_NECROMANCER_DESCRIPTION")
    }, {
        check = "kr3_main_icons_0019",
        action_arg = "tower_high_elven",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "kr3_main_icons_0107",
        place = 11,
        tt_title = _("TOWER_MAGE_HIGH_ELVEN_NAME"),
        tt_desc = _("TOWER_MAGE_HIGH_ELVEN_DESCRIPTION"),
        is_kr3 = true
    }, {
        check = "main_icons_0019",
        action_arg = "tower_archmage",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0022",
        place = 12,
        tt_title = _("TOWER_ARCHMAGE_NAME"),
        tt_desc = _("TOWER_ARCHMAGE_DESCRIPTION")
    }, {
        check = "kr3_main_icons_0019",
        action_arg = "tower_wild_magus",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "kr3_main_icons_0106",
        place = 13,
        tt_title = _("TOWER_MAGE_WILD_MAGUS_NAME"),
        tt_desc = _("TOWER_MAGE_WILD_MAGUS_DESCRIPTION"),
        is_kr3 = true
    }, {
        check = "kr3_main_icons_0019",
        action_arg = "tower_faerie_dragon",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "kr3_special_icons_0124",
        place = 14,
        tt_title = _("ELVES_TOWER_SPECIAL_FAERIE_DRAGONS_NAME"),
        tt_desc = _("ELVES_TOWER_SPECIAL_FAERIE_DRAGONS_DESCRIPTION"),
        is_kr3 = true
    }, {
        check = "kr3_main_icons_0019",
        action_arg = "tower_pixie",
        action = "tw_upgrade",
        image = "kr3_special_icons_0122",
        place = 15,
        halo = "glow_ico_main",
        tt_title = _("ELVES_TOWER_PIXIE_NAME"),
        tt_desc = _("ELVES_TOWER_PIXIE_DESCRIPTION"),
        is_kr3 = true
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    engineer = {{{
        check = "main_icons_0019",
        action_arg = "tower_engineer_2",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0005",
        place = 5,
        tt_title = _("TOWER_ENGINEER_2_NAME"),
        tt_desc = _("TOWER_ENGINEER_2_DESCRIPTION")
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}, {{
        check = "main_icons_0019",
        action_arg = "tower_engineer_3",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0005",
        place = 5,
        tt_title = _("TOWER_ENGINEER_3_NAME"),
        tt_desc = _("TOWER_ENGINEER_3_DESCRIPTION")
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}, {{
        check = "main_icons_0019",
        action_arg = "tower_bfg",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0013",
        place = 5,
        tt_title = _("TOWER_BFG_NAME"),
        tt_desc = _("TOWER_BFG_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_tesla",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0012",
        place = 6,
        tt_title = _("TOWER_TESLA_NAME"),
        tt_desc = _("TOWER_TESLA_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_dwaarp",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0027",
        place = 7,
        tt_title = _("TOWER_DWAARP_NAME"),
        tt_desc = _("TOWER_DWAARP_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_mech",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0028",
        place = 10,
        tt_title = _("TOWER_MECH_NAME"),
        tt_desc = _("TOWER_MECH_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_frankenstein",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0039",
        place = 11,
        tt_title = _("SPECIAL_TOWER_FRANKENSTEIN_NAME"),
        tt_desc = _("SPECIAL_TOWER_FRANKENSTEIN_DESCRIPTION")
    }, {
        check = "kr3_main_icons_0019",
        action_arg = "tower_druid",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "kr3_main_icons_0111",
        place = 12,
        tt_title = _("TOWER_STONE_DRUID_NAME"),
        tt_desc = _("TOWER_STONE_DRUID_DESCRIPTION"),
        is_kr3 = true
    }, {
        check = "kr3_main_icons_0019",
        action_arg = "tower_entwood",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "kr3_main_icons_0110",
        place = 13,
        tt_title = _("TOWER_ENTWOOD_NAME"),
        tt_desc = _("TOWER_ENTWOOD_DESCRIPTION"),
        is_kr3 = true
    }, {
        check = "main_icons_0019",
        halo = "glow_ico_main",
        action_arg = "tower_tricannon_lvl4",
        action = "tw_upgrade",
        image = "kr5_main_icons_0004",
        tt_title = _("三管加农炮"),
        tt_desc = _("TOWER_TRICANNON_1_DESCRIPTION"),
        place = 14,
        is_kr3 = true
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    archer = {{{
        check = "main_icons_0019",
        action_arg = "tower_archer_2",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0005",
        place = 5,
        tt_title = _("TOWER_ARCHER_2_NAME"),
        tt_desc = _("TOWER_ARCHER_2_DESCRIPTION")
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}, {{
        check = "main_icons_0019",
        action_arg = "tower_archer_3",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0005",
        place = 5,
        tt_title = _("TOWER_ARCHER_3_NAME"),
        tt_desc = _("TOWER_ARCHER_3_DESCRIPTION")
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}, {{
        check = "main_icons_0019",
        action_arg = "tower_ranger",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0011",
        place = 5,
        tt_title = _("TOWER_RANGERS_NAME"),
        tt_desc = _("TOWER_RANGERS_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_musketeer",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0010",
        place = 6,
        tt_title = _("TOWER_MUSKETEERS_NAME"),
        tt_desc = _("TOWER_MUSKETEERS_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_crossbow",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0025",
        place = 7,
        tt_title = _("TOWER_CROSSBOW_NAME"),
        tt_desc = _("TOWER_CROSSBOW_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_totem",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0026",
        place = 10,
        tt_title = _("TOWER_TOTEM_NAME"),
        tt_desc = _("TOWER_TOTEM_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_archer_dwarf",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0034",
        place = 11,
        tt_title = _("SPECIAL_DWARF_TOWER1_NAME"),
        tt_desc = _("SPECIAL_DWARF_TOWER1_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_pirate_watchtower",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0032",
        place = 12,
        tt_title = _("TOWER_PIRATE_WATCHTOWER_NAME"),
        tt_desc = _("TOWER_PIRATE_WATCHTOWER_DESCRIPTION")
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }, {
        check = "kr3_main_icons_0019",
        action_arg = "tower_arcane",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "kr3_main_icons_0108",
        place = 13,
        tt_title = _("TOWER_ARCANE_ARCHER_NAME"),
        tt_desc = _("TOWER_ARCANE_ARCHER_DESCRIPTION"),
        is_kr3 = true
    }, {
        check = "kr3_main_icons_0019",
        action_arg = "tower_silver",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "kr3_main_icons_0109",
        place = 14,
        tt_title = _("TOWER_SILVER_NAME"),
        tt_desc = _("TOWER_SILVER_DESCRIPTION"),
        is_kr3 = true
    }, {
        check = "main_icons_0019",
        action_arg = "tower_dark_elf_lvl4",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "kr5_main_icons_0032",
        tt_title = _("暮光长弓"),
        tt_desc = _("TOWER_DARK_ELF_1_DESCRIPTION"),
        place = 15,
        is_kr3 = true
    }}},
    barrack = {{{
        check = "main_icons_0019",
        action_arg = "tower_barrack_2",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0005",
        place = 5,
        tt_title = _("TOWER_BARRACK_2_NAME"),
        tt_desc = _("TOWER_BARRACK_2_DESCRIPTION")
    }, {
        check = "sub_icons_0003",
        action = "tw_rally",
        halo = "glow_ico_sub",
        image = "sub_icons_0001",
        place = 8
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}, {{
        check = "main_icons_0019",
        action_arg = "tower_barrack_3",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0005",
        place = 5,
        tt_title = _("TOWER_BARRACK_3_NAME"),
        tt_desc = _("TOWER_BARRACK_3_DESCRIPTION")
    }, {
        check = "sub_icons_0003",
        action = "tw_rally",
        halo = "glow_ico_sub",
        image = "sub_icons_0001",
        place = 8
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}, {{
        check = "main_icons_0019",
        action_arg = "tower_paladin",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0008",
        place = 5,
        tt_title = _("TOWER_PALADINS_NAME"),
        tt_desc = _("TOWER_PALADINS_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_barbarian",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0009",
        place = 6,
        tt_title = _("TOWER_BARBARIANS_NAME"),
        tt_desc = _("TOWER_BARBARIANS_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_elf",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0011",
        place = 7,
        tt_title = _("精灵哨站"),
        tt_desc = _("训练精灵游侠，弓与剑的大师。脆弱无比，但也能迅捷地取敌性命。")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_templar",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0023",
        place = 10,
        tt_title = _("TOWER_TEMPLAR_NAME"),
        tt_desc = _("TOWER_TEMPLAR_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_assassin",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0024",
        place = 11,
        tt_title = _("TOWER_ASSASSIN_NAME"),
        tt_desc = _("TOWER_ASSASSIN_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_barrack_dwarf",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0015",
        place = 12,
        tt_title = _("TOWER_BARRACK_DWARF_NAME"),
        tt_desc = _("TOWER_BARRACK_DWARF_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_barrack_amazonas",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0033",
        place = 13,
        tt_title = _("SPECIAL_AMAZONAS_NAME"),
        tt_desc = _("SPECIAL_AMAZONAS_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_barrack_mercenaries",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0030",
        place = 14,
        tt_title = _("SPECIAL_DJINN_NAME"),
        tt_desc = _("SPECIAL_DJINN_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_barrack_pirates",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0032",
        place = 15,
        tt_title = _("TOWER_BARRACK_PIRATES_NAME"),
        tt_desc = _("TOWER_BARRACK_PIRATES_DESCRIPTION")
    }, {
        check = "kr3_main_icons_0019",
        action_arg = "tower_blade",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "kr3_main_icons_0104",
        place = 16,
        tt_title = _("TOWER_BARRACKS_BLADE_NAME"),
        tt_desc = _("TOWER_BARRACKS_BLADE_DESCRIPTION"),
        is_kr3 = true
    }, {
        check = "kr3_main_icons_0019",
        action_arg = "tower_forest",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "kr3_main_icons_0105",
        place = 17,
        tt_title = _("TOWER_FOREST_KEEPERS_NAME"),
        tt_desc = _("TOWER_FOREST_KEEPERS_DESCRIPTION"),
        is_kr3 = true
    }, {
        check = "kr3_main_icons_0019",
        action_arg = "tower_drow",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "kr3_special_icons_0121",
        place = 18,
        tt_title = _("ELVES_TOWER_SPECIAL_DROW_NAME"),
        tt_desc = _("ELVES_TOWER_SPECIAL_DROW_DESCRIPTION"),
        is_kr3 = true
    }, {
        check = "kr3_main_icons_0019",
        action_arg = "tower_ewok",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "kr3_main_icons_0112",
        place = 19,
        tt_title = _("ELVES_EWOK_NAME"),
        tt_desc = _("ELVES_EWOK_DESCRIPTION"),
        is_kr3 = true
    }, {
        check = "main_icons_0019",
        action_arg = "tower_baby_ashbite",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "kr3_main_icons_0113",
        place = 20,
        tt_title = _("ELVES_BABY_ASHBITE_TOWER_BROKEN_NAME"),
        tt_desc = _("ELVES_BABY_ASHBITE_TOWER_BROKEN_DESCRIPTION"),
        is_kr3 = true
    }, {
        check = "sub_icons_0003",
        action = "tw_rally",
        halo = "glow_ico_sub",
        image = "sub_icons_0001",
        place = 8
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    ranger = {{{
        check = "special_icons_0020",
        action_arg = "poison",
        action = "upgrade_power",
        image = "special_icons_0008",
        place = 1,
        halo = "glow_ico_special",
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
    }, {
        check = "special_icons_0020",
        action_arg = "thorn",
        action = "upgrade_power",
        image = "special_icons_0002",
        place = 2,
        halo = "glow_ico_special",
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
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    musketeer = {{{
        check = "special_icons_0020",
        action_arg = "sniper",
        action = "upgrade_power",
        image = "special_icons_0003",
        place = 1,
        halo = "glow_ico_special",
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
    }, {
        check = "special_icons_0020",
        action_arg = "shrapnel",
        action = "upgrade_power",
        image = "special_icons_0005",
        place = 2,
        halo = "glow_ico_special",
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
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    crossbow = {{{
        check = "special_icons_0020",
        action_arg = "multishot",
        action = "upgrade_power",
        image = "special_icons_0028",
        place = 1,
        halo = "glow_ico_special",
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
    }, {
        check = "special_icons_0020",
        action_arg = "eagle",
        action = "upgrade_power",
        image = "special_icons_0029",
        place = 2,
        halo = "glow_ico_special",
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
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    totem = {{{
        check = "special_icons_0020",
        action_arg = "weakness",
        action = "upgrade_power",
        image = "special_icons_0030",
        place = 1,
        halo = "glow_ico_special",
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
    }, {
        check = "special_icons_0020",
        action_arg = "silence",
        action = "upgrade_power",
        image = "special_icons_0031",
        place = 2,
        halo = "glow_ico_special",
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
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    archer_dwarf = {{{
        check = "special_icons_0020",
        action_arg = "barrel",
        action = "upgrade_power",
        image = "special_icons_0044",
        place = 1,
        halo = "glow_ico_special",
        sounds = {"DwarfArcherTaunt1"},
        tt_phrase = _("SPECIAL_DWARF_TOWER1_UPGRADE_1_NOTE"),
        tt_list = {{
            tt_title = _("SPECIAL_DWARF_TOWER1_UPGRADE_1_NAME"),
            tt_desc = _("SPECIAL_DWARF_TOWER1_UPGRADE_1_DESCRIPTION_1")
        }, {
            tt_title = _("SPECIAL_DWARF_TOWER1_UPGRADE_1_NAME"),
            tt_desc = _("SPECIAL_DWARF_TOWER1_UPGRADE_1_DESCRIPTION_2")
        }, {
            tt_title = _("SPECIAL_DWARF_TOWER1_UPGRADE_1_NAME"),
            tt_desc = _("SPECIAL_DWARF_TOWER1_UPGRADE_1_DESCRIPTION_3")
        }}
    }, {
        check = "special_icons_0020",
        action_arg = "extra_damage",
        action = "upgrade_power",
        image = "special_icons_0043",
        place = 2,
        halo = "glow_ico_special",
        sounds = {"DwarfArcherTaunt2"},
        tt_phrase = _("SPECIAL_DWARF_TOWER1_UPGRADE_2_NOTE"),
        tt_list = {{
            tt_title = _("SPECIAL_DWARF_TOWER1_UPGRADE_2_NAME"),
            tt_desc = _("SPECIAL_DWARF_TOWER1_UPGRADE_2_DESCRIPTION_1")
        }, {
            tt_title = _("SPECIAL_DWARF_TOWER1_UPGRADE_2_NAME"),
            tt_desc = _("SPECIAL_DWARF_TOWER1_UPGRADE_2_DESCRIPTION_2")
        }, {
            tt_title = _("SPECIAL_DWARF_TOWER1_UPGRADE_2_NAME"),
            tt_desc = _("SPECIAL_DWARF_TOWER1_UPGRADE_2_DESCRIPTION_3")
        }}
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    arcane_wizard = {{{
        check = "special_icons_0020",
        action_arg = "disintegrate",
        action = "upgrade_power",
        image = "special_icons_0015",
        place = 1,
        halo = "glow_ico_special",
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
    }, {
        check = "special_icons_0020",
        action_arg = "teleport",
        action = "upgrade_power",
        image = "special_icons_0016",
        place = 2,
        halo = "glow_ico_special",
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
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    sorcerer = {{{
        check = "special_icons_0020",
        action_arg = "polymorph",
        action = "upgrade_power",
        image = "special_icons_0001",
        place = 1,
        halo = "glow_ico_special",
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
    }, {
        check = "special_icons_0020",
        action = "upgrade_power",
        halo = "glow_ico_special",
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
    }, {
        check = "sub_icons_0003",
        action = "tw_rally",
        halo = "glow_ico_sub",
        image = "sub_icons_0001",
        place = 8
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    archmage = {{{
        check = "special_icons_0020",
        action_arg = "twister",
        action = "upgrade_power",
        image = "special_icons_0032",
        place = 1,
        halo = "glow_ico_special",
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
    }, {
        check = "special_icons_0020",
        action_arg = "blast",
        action = "upgrade_power",
        image = "special_icons_0033",
        place = 2,
        halo = "glow_ico_special",
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
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    necromancer = {{{
        check = "special_icons_0020",
        action_arg = "pestilence",
        action = "upgrade_power",
        image = "special_icons_0035",
        place = 1,
        halo = "glow_ico_special",
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
    }, {
        check = "special_icons_0020",
        action_arg = "rider",
        action = "upgrade_power",
        image = "special_icons_0034",
        place = 2,
        halo = "glow_ico_special",
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
    }, {
        check = "sub_icons_0003",
        action = "tw_rally",
        halo = "glow_ico_sub",
        image = "sub_icons_0001",
        place = 8
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    bfg = {{{
        check = "special_icons_0020",
        action_arg = "missile",
        action = "upgrade_power",
        image = "special_icons_0017",
        place = 1,
        halo = "glow_ico_special",
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
    }, {
        check = "special_icons_0020",
        action_arg = "cluster",
        action = "upgrade_power",
        image = "special_icons_0018",
        place = 2,
        halo = "glow_ico_special",
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
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    tesla = {{{
        check = "special_icons_0020",
        action_arg = "bolt",
        action = "upgrade_power",
        image = "special_icons_0011",
        place = 1,
        halo = "glow_ico_special",
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
    }, {
        check = "special_icons_0020",
        action_arg = "overcharge",
        action = "upgrade_power",
        image = "special_icons_0010",
        place = 2,
        halo = "glow_ico_special",
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
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    dwaarp = {{{
        check = "special_icons_0020",
        action_arg = "drill",
        action = "upgrade_power",
        image = "special_icons_0036",
        place = 1,
        halo = "glow_ico_special",
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
    }, {
        check = "special_icons_0020",
        action_arg = "lava",
        action = "upgrade_power",
        image = "special_icons_0037",
        place = 2,
        halo = "glow_ico_special",
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
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    mecha = {{{
        check = "special_icons_0020",
        action_arg = "missile",
        action = "upgrade_power",
        image = "special_icons_0038",
        place = 1,
        halo = "glow_ico_special",
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
    }, {
        check = "special_icons_0020",
        action_arg = "oil",
        action = "upgrade_power",
        image = "special_icons_0039",
        place = 2,
        halo = "glow_ico_special",
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
    }, {
        check = "sub_icons_0003",
        action = "tw_rally",
        halo = "glow_ico_sub",
        image = "sub_icons_0001",
        place = 8
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    paladin = {{{
        check = "special_icons_0020",
        action_arg = "healing",
        action = "upgrade_power",
        image = "special_icons_0007",
        place = 6,
        halo = "glow_ico_special",
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
    }, {
        check = "special_icons_0020",
        action_arg = "shield",
        action = "upgrade_power",
        image = "special_icons_0009",
        place = 5,
        halo = "glow_ico_special",
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
    }, {
        check = "special_icons_0020",
        action_arg = "holystrike",
        action = "upgrade_power",
        image = "special_icons_0006",
        place = 7,
        halo = "glow_ico_special",
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
    }, {
        check = "sub_icons_0003",
        action = "tw_rally",
        halo = "glow_ico_sub",
        image = "sub_icons_0001",
        place = 8
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    barbarian = {{{
        check = "special_icons_0020",
        action_arg = "dual",
        action = "upgrade_power",
        image = "special_icons_0012",
        place = 6,
        halo = "glow_ico_special",
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
    }, {
        check = "special_icons_0020",
        action_arg = "twister",
        action = "upgrade_power",
        image = "special_icons_0013",
        place = 5,
        halo = "glow_ico_special",
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
    }, {
        check = "special_icons_0020",
        action_arg = "throwing",
        action = "upgrade_power",
        image = "special_icons_0019",
        place = 7,
        halo = "glow_ico_special",
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
    }, {
        check = "sub_icons_0003",
        action = "tw_rally",
        halo = "glow_ico_sub",
        image = "sub_icons_0001",
        place = 8
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    holder_elf = {{{
        check = "main_icons_0019",
        action_arg = "tower_elf",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0015",
        place = 5,
        tt_title = _("SPECIAL_ELF_REPAIR_NAME"),
        tt_desc = _("SPECIAL_ELF_REPAIR_DESCRIPTION")
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    elf = {{{
        check = "special_icons_0020",
        action_arg = "bleed",
        action = "upgrade_power",
        image = "special_icons_0014",
        place = 7,
        halo = "glow_ico_special",
        sounds = {"ElfBleed"},
        tt_phrase = _("你会流血吗？"),
        tt_list = {{
            tt_title = _("血翎"),
            tt_desc = _("使精灵的射击附带流血效果，在三秒内造成15点伤害")
        }, {
            tt_title = _("血翎Ⅱ"),
            tt_desc = _("使精灵的射击附带流血效果，在三秒内造成30点伤害")
        }, {
            tt_title = _("血翎Ⅲ"),
            tt_desc = _("使精灵的射击附带流血效果，在三秒内造成45点伤害")
        }}
    }, {
        check = "special_icons_0020",
        action_arg = "cripple",
        action = "upgrade_power",
        image = "special_icons_0024",
        place = 6,
        halo = "glow_ico_special",
        sounds = {"ElfCripple"},
        tt_phrase = _("他们走不远的……"),
        tt_list = {{
            tt_title = _("残废"),
            tt_desc = _("游侠有30%几率射出精灵箭矢，造成70点真实伤害与40%的减速，持续2.5秒。")
        }, {
            tt_title = _("残废Ⅱ"),
            tt_desc = _("游侠有40%几率射出精灵箭矢，造成85点真实伤害与40%的减速，持续2.5秒。")
        }, {
            tt_title = _("残废Ⅲ"),
            tt_desc = _("游侠有50%几率射出精灵箭矢，造成100点真实伤害与40%的减速，持续2.5秒。")
        }}
    }, {
        check = "main_icons_0019",
        action_arg = "soldier_elf",
        action = "tw_buy_soldier",
        halo = "glow_ico_main",
        image = "main_icons_0016",
        place = 5,
        tt_title = _("SPECIAL_ELF_NAME"),
        tt_desc = _("SPECIAL_ELF_DESCRIPTION")
    }, {
        halo = "glow_ico_sub",
        image = "sub_icons_0001",
        action = "tw_rally",
        place = 8
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    templar = {{{
        check = "special_icons_0020",
        action_arg = "holygrail",
        action = "upgrade_power",
        image = "special_icons_0025",
        place = 7,
        halo = "glow_ico_special",
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
    }, {
        check = "special_icons_0020",
        action_arg = "extralife",
        action = "upgrade_power",
        image = "special_icons_0027",
        place = 6,
        halo = "glow_ico_special",
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
    }, {
        check = "special_icons_0020",
        action_arg = "blood",
        action = "upgrade_power",
        image = "special_icons_0026",
        place = 5,
        halo = "glow_ico_special",
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
    }, {
        check = "sub_icons_0003",
        action = "tw_rally",
        halo = "glow_ico_sub",
        image = "sub_icons_0001",
        place = 8
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    assassin = {{{
        check = "special_icons_0020",
        action_arg = "sneak",
        action = "upgrade_power",
        image = "special_icons_0024",
        place = 6,
        halo = "glow_ico_special",
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
    }, {
        check = "special_icons_0020",
        action_arg = "pickpocket",
        action = "upgrade_power",
        image = "special_icons_0022",
        place = 7,
        halo = "glow_ico_special",
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
    }, {
        check = "special_icons_0020",
        action_arg = "counter",
        action = "upgrade_power",
        image = "special_icons_0023",
        place = 5,
        halo = "glow_ico_special",
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
    }, {
        check = "sub_icons_0003",
        action = "tw_rally",
        halo = "glow_ico_sub",
        image = "sub_icons_0001",
        place = 8
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    barrack_dwarf = {{{
        check = "special_icons_0020",
        action_arg = "hammer",
        action = "upgrade_power",
        image = "special_icons_0040",
        place = 5,
        halo = "glow_ico_special",
        sounds = {"DwarfTaunt"},
        tt_phrase = _("SPECIAL_DWARF_BARRACKS_UPGRADE_1_NOTE"),
        tt_list = {{
            tt_title = _("SPECIAL_DWARF_BARRACKS_UPGRADE_1_NAME_1"),
            tt_desc = _("SPECIAL_DWARF_BARRACKS_UPGRADE_1_DESCRIPTION_1")
        }, {
            tt_title = _("SPECIAL_DWARF_BARRACKS_UPGRADE_1_NAME_2"),
            tt_desc = _("SPECIAL_DWARF_BARRACKS_UPGRADE_1_DESCRIPTION_2")
        }, {
            tt_title = _("SPECIAL_DWARF_BARRACKS_UPGRADE_1_NAME_3"),
            tt_desc = _("SPECIAL_DWARF_BARRACKS_UPGRADE_1_DESCRIPTION_3")
        }}
    }, {
        check = "special_icons_0020",
        action_arg = "armor",
        action = "upgrade_power",
        image = "special_icons_0041",
        place = 6,
        halo = "glow_ico_special",
        sounds = {"DwarfTaunt"},
        tt_phrase = _("SPECIAL_DWARF_BARRACKS_UPGRADE_2_NOTE"),
        tt_list = {{
            tt_title = _("SPECIAL_DWARF_BARRACKS_UPGRADE_2_NAME_1"),
            tt_desc = _("SPECIAL_DWARF_BARRACKS_UPGRADE_2_DESCRIPTION_1")
        }, {
            tt_title = _("SPECIAL_DWARF_BARRACKS_UPGRADE_2_NAME_2"),
            tt_desc = _("SPECIAL_DWARF_BARRACKS_UPGRADE_2_DESCRIPTION_2")
        }}
    }, {
        check = "special_icons_0020",
        action_arg = "beer",
        action = "upgrade_power",
        image = "special_icons_0042",
        place = 7,
        halo = "glow_ico_special",
        sounds = {"DwarfTaunt"},
        tt_phrase = _("SPECIAL_DWARF_BARRACKS_UPGRADE_3_NOTE"),
        tt_list = {{
            tt_title = _("SPECIAL_DWARF_BARRACKS_UPGRADE_3_NAME_1"),
            tt_desc = _("SPECIAL_DWARF_BARRACKS_UPGRADE_3_DESCRIPTION_1")
        }, {
            tt_title = _("SPECIAL_DWARF_BARRACKS_UPGRADE_3_NAME_2"),
            tt_desc = _("SPECIAL_DWARF_BARRACKS_UPGRADE_3_DESCRIPTION_2")
        }, {
            tt_title = _("SPECIAL_DWARF_BARRACKS_UPGRADE_3_NAME_3"),
            tt_desc = _("SPECIAL_DWARF_BARRACKS_UPGRADE_3_DESCRIPTION_3")
        }}
    }, {
        check = "sub_icons_0003",
        action = "tw_rally",
        halo = "glow_ico_sub",
        image = "sub_icons_0001",
        place = 8
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    mercenaries_amazonas = {{{
        check = "special_icons_0020",
        action_arg = "valkyrie",
        action = "upgrade_power",
        image = "special_icons_0014",
        place = 7,
        halo = "glow_ico_special",
        sounds = {"AmazonTaunt"},
        tt_phrase = _("解脱敌人是一种荣耀。"),
        tt_list = {{
            tt_title = _("武神"),
            tt_desc = _(
                "女战士提升50点生命与10点攻击力，且每杀死一个敌人，提升2点攻击力、3点生命和1点移速，最高提升150点生命，60点攻击与50点移速，死亡后移除。")
        }}
    }, {
        check = "special_icons_0020",
        action_arg = "whirlwind",
        action = "upgrade_power",
        image = "special_icons_0013",
        place = 6,
        halo = "glow_ico_special",
        sounds = {"AmazonTaunt"},
        tt_phrase = _("横扫六合！"),
        tt_list = {{
            tt_title = _("旋风"),
            tt_desc = _("使女战士有30%几率释放旋风斩，造成24-46点范围伤害")
        }}
    }, {
        check = "main_icons_0019",
        action_arg = "soldier_amazona",
        action = "tw_buy_soldier",
        halo = "glow_ico_main",
        image = "main_icons_0033",
        place = 5,
        tt_title = _("SPECIAL_AMAZONAS_WARRIOR_NAME"),
        tt_desc = _("SPECIAL_AMAZONAS_WARRIOR_DESCRIPTION")
    }, {
        check = "sub_icons_0003",
        action = "tw_rally",
        halo = "glow_ico_sub",
        image = "sub_icons_0001",
        place = 8
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    holder_sasquash = {{{
        check = "main_icons_0019",
        halo = "glow_ico_main",
        action = "tw_none",
        image = "main_icons_0017",
        place = 5,
        tt_title = _("SPECIAL_ELF_REPAIR_NAME"),
        tt_desc = _("SPECIAL_ELF_REPAIR_DESCRIPTION")
    }}},
    sasquash = {{{
        check = "main_icons_0019",
        action_arg = "soldier_sasquash",
        action = "tw_buy_soldier",
        halo = "glow_ico_main",
        image = "main_icons_0017",
        place = 5,
        tt_title = _("SPECIAL_SASQUASH_NAME"),
        tt_desc = _("SPECIAL_SASQUASH_DESCRIPTION")
    }, {
        halo = "glow_ico_sub",
        image = "sub_icons_0001",
        action = "tw_rally",
        place = 8
    }}},
    sunray = {{{
        check = "main_icons_0019",
        action = "upgrade_power",
        no_upgrade_lights = true,
        image = "main_icons_0018",
        action_arg = "ray",
        place = 5,
        halo = "glow_ico_main",
        sounds = {"MageSorcererAshesToAshesTaunt"},
        tt_phrase = _("SPECIAL_SUNRAY_NOTE"),
        tt_list = {{
            tt_title = _("SPECIAL_SUNRAY_UPGRADE_NAME"),
            tt_desc = _("SPECIAL_SUNRAY_UPGRADE_DESCRIPTION_1")
        }, {
            tt_title = _("SPECIAL_SUNRAY_UPGRADE_NAME"),
            tt_desc = _("SPECIAL_SUNRAY_UPGRADE_DESCRIPTION_1")
        }, {
            tt_title = _("SPECIAL_SUNRAY_UPGRADE_NAME"),
            tt_desc = _("SPECIAL_SUNRAY_UPGRADE_DESCRIPTION_1")
        }, {
            tt_title = _("SPECIAL_SUNRAY_UPGRADE_NAME"),
            tt_desc = _("SPECIAL_SUNRAY_UPGRADE_DESCRIPTION_1")
        }}
    }, {
        check = "main_icons_0019",
        action = "upgrade_power",
        image = "main_icons_0019",
        action_arg = "manual",
        place = 6,
        halo = "glow_ico_main",
        sounds = {"MageSorcererAshesToAshesTaunt"},
        tt_phrase = _("日光啊，听我号令！"),
        tt_list = {{
            tt_title = _("切换手动模式"),
            tt_desc = _(
                "手动模式无射程限制，且攻击附带最高额外200点伤害的10%斩杀效果。只有对单时，日光才能发挥全部威力。")
        }}
    }, {
        check = "main_icons_0019",
        action = "upgrade_power",
        image = "main_icons_0020",
        action_arg = "auto",
        place = 7,
        halo = "glow_ico_main",
        sounds = {"MageSorcererAshesToAshesTaunt"},
        tt_phrase = _("日光啊，瓦解它们！"),
        tt_list = {{
            tt_title = _("切换自动模式"),
            tt_desc = _(
                "自动模式射程有限，且充能速度加快40%，伤害下降25%。只有对单时，日光才能发挥全部威力。")
        }}
    }, {
        check = "sub_icons_0002",
        action = "tw_point",
        halo = "glow_ico_sub",
        image = "sub_icons_0002",
        place = 8
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    mercenaries_desert = {{{
        check = "main_icons_0019",
        action_arg = "soldier_djinn",
        action = "tw_buy_soldier",
        halo = "glow_ico_main",
        image = "main_icons_0030",
        place = 5,
        tt_title = _("SPECIAL_DJINN_NAME"),
        tt_desc = _("SPECIAL_DJINN_DESCRIPTION")
    }, {
        check = "special_icons_0020",
        action_arg = "djspell",
        action = "upgrade_power",
        image = "special_icons_0025",
        place = 7,
        halo = "glow_ico_special",
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
    }, {
        check = "special_icons_0020",
        action_arg = "djshock",
        action = "upgrade_power",
        image = "special_icons_0016",
        place = 6,
        halo = "glow_ico_special",
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
    }, {
        check = "sub_icons_0003",
        action = "tw_rally",
        halo = "glow_ico_sub",
        image = "sub_icons_0001",
        place = 8
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    mercenaries_pirates = {{{
        check = "special_icons_0020",
        action_arg = "bigbomb",
        action = "upgrade_power",
        image = "special_icons_0018",
        place = 6,
        halo = "glow_ico_special",
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
    }, {
        check = "main_icons_0019",
        action_arg = "soldier_pirate_flamer",
        action = "tw_buy_soldier",
        halo = "glow_ico_main",
        image = "main_icons_0032",
        place = 5,
        tt_title = _("SPECIAL_PIRATE_FLAMER_NAME"),
        tt_desc = _("SPECIAL_PIRATE_FLAMER_DESCRIPTION")
    }, {
        check = "special_icons_0020",
        action_arg = "quickup",
        action = "upgrade_power",
        image = "special_icons_0025",
        place = 7,
        halo = "glow_ico_special",
        sounds = {"PiratesTaunt"},
        tt_phrase = _("TOWER_BARRACK_PIRATES_QUICKUP_NOTE_1"),
        tt_list = {{
            tt_title = _("TOWER_BARRACK_PIRATES_QUICKUP_NAME_1"),
            tt_desc = _("TOWER_BARRACK_PIRATES_QUICKUP_DESCRIPTION_1")
        }, {
            tt_title = _("TOWER_BARRACK_PIRATES_QUICKUP_NAME_2"),
            tt_desc = _("TOWER_BARRACK_PIRATES_QUICKUP_DESCRIPTION_2")
        }}
    }, {
        check = "sub_icons_0003",
        action = "tw_rally",
        halo = "glow_ico_sub",
        image = "sub_icons_0001",
        place = 8
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    pirate_watchtower = {{{
        check = "special_icons_0020",
        action_arg = "reduce_cooldown",
        action = "upgrade_power",
        image = "special_icons_0045",
        place = 1,
        halo = "glow_ico_special",
        sounds = {"PirateTowerTaunt1"},
        tt_phrase = _("SPECIAL_PIRATES_WATCHTOWER_UPGRADE_1_NOTE"),
        tt_list = {{
            tt_title = _("SPECIAL_PIRATES_WATCHTOWER_UPGRADE_1_NAME"),
            tt_desc = _("SPECIAL_PIRATES_WATCHTOWER_UPGRADE_1_DESCRIPTION_1")
        }, {
            tt_title = _("SPECIAL_PIRATES_WATCHTOWER_UPGRADE_1_NAME"),
            tt_desc = _("SPECIAL_PIRATES_WATCHTOWER_UPGRADE_1_DESCRIPTION_2")
        }, {
            tt_title = _("SPECIAL_PIRATES_WATCHTOWER_UPGRADE_1_NAME"),
            tt_desc = _("SPECIAL_PIRATES_WATCHTOWER_UPGRADE_1_DESCRIPTION_3")
        }}
    }, {
        check = "special_icons_0020",
        action_arg = "parrot",
        action = "upgrade_power",
        image = "special_icons_0046",
        place = 2,
        halo = "glow_ico_special",
        sounds = {"PirateTowerTaunt2"},
        tt_phrase = _("SPECIAL_PIRATES_WATCHTOWER_UPGRADE_2_NOTE"),
        tt_list = {{
            tt_title = _("SPECIAL_PIRATES_WATCHTOWER_UPGRADE_2_NAME"),
            tt_desc = _("SPECIAL_PIRATES_WATCHTOWER_UPGRADE_2_DESCRIPTION_1")
        }, {
            tt_title = _("SPECIAL_PIRATES_WATCHTOWER_UPGRADE_2_NAME"),
            tt_desc = _("SPECIAL_PIRATES_WATCHTOWER_UPGRADE_2_DESCRIPTION_2")
        }}
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    holder_neptune = {{{
        check = "main_icons_0019",
        action_arg = "tower_neptune",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0015",
        place = 5,
        tt_title = _("SPECIAL_NEPTUNE_BROKEN_TOWER_FIX_NAME"),
        tt_desc = _("SPECIAL_NEPTUNE_BROKEN_TOWER_FIX_DESCRIPTION")
    }}},
    neptune = {{{
        check = "special_icons_0020",
        action_arg = "ray",
        action = "upgrade_power",
        halo = "glow_ico_special",
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
    }, {
        check = "sub_icons_0003",
        action = "tw_point",
        halo = "glow_ico_sub",
        image = "sub_icons_0002",
        place = 8
    }}},
    frankenstein = {{{
        check = "special_icons_0020",
        action_arg = "lightning",
        action = "upgrade_power",
        image = "special_icons_0048",
        place = 1,
        halo = "glow_ico_special",
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
    }, {
        check = "special_icons_0020",
        action_arg = "frankie",
        action = "upgrade_power",
        image = "special_icons_0049",
        place = 2,
        halo = "glow_ico_special",
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
    }, {
        check = "sub_icons_0003",
        action = "tw_rally",
        halo = "glow_ico_sub",
        image = "sub_icons_0001",
        place = 8
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    -- kr3 waited
    blade = {{{
        check = "kr3_special_icons_0020",
        action_arg = "perfect_parry",
        action = "upgrade_power",
        image = "kr3_special_icons_0105",
        place = 6,
        halo = "glow_ico_special",
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
        }},
        is_kr3 = true
    }, {
        check = "kr3_special_icons_0020",
        action_arg = "blade_dance",
        action = "upgrade_power",
        image = "kr3_special_icons_0104",
        place = 7,
        halo = "glow_ico_special",
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
        }},
        is_kr3 = true
    }, {
        check = "kr3_special_icons_0020",
        action_arg = "swirling",
        action = "upgrade_power",
        image = "kr3_special_icons_0106",
        place = 5,
        halo = "glow_ico_special",
        sounds = {"ElvesBarrackBladesingerSwirlingEdge"},
        tt_phrase = _("TOWER_BLADE_SWIRLING_EDGE_NOTE"),
        tt_list = {{
            tt_title = _("TOWER_BLADE_SWIRLING_EDGE_NAME_1"),
            tt_desc = _("TOWER_BLADE_SWIRLING_EDGE_DESCRIPTION_1")
        }, {
            tt_title = _("TOWER_BLADE_SWIRLING_EDGE_NAME_2"),
            tt_desc = _("TOWER_BLADE_SWIRLING_EDGE_DESCRIPTION_2")
        }, {
            tt_title = _("TOWER_BLADE_SWIRLING_EDGE_NAME_3"),
            tt_desc = _("TOWER_BLADE_SWIRLING_EDGE_DESCRIPTION_3")
        }},
        is_kr3 = true
    }, {
        halo = "glow_ico_sub",
        image = "sub_icons_0001",
        action = "tw_rally",
        place = 8
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    forest = {{{
        check = "kr3_special_icons_0020",
        action_arg = "circle",
        action = "upgrade_power",
        image = "kr3_special_icons_0107",
        place = 6,
        halo = "glow_ico_special",
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
        }},
        is_kr3 = true
    }, {
        check = "kr3_special_icons_0020",
        action_arg = "eerie",
        action = "upgrade_power",
        image = "kr3_special_icons_0109",
        place = 5,
        halo = "glow_ico_special",
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
        }},
        is_kr3 = true
    }, {
        check = "kr3_special_icons_0020",
        action_arg = "oak",
        action = "upgrade_power",
        image = "kr3_special_icons_0110",
        place = 7,
        halo = "glow_ico_special",
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
        }},
        is_kr3 = true
    }, {
        halo = "glow_ico_sub",
        image = "sub_icons_0001",
        action = "tw_rally",
        place = 8
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    druid = {{{
        check = "kr3_special_icons_0020",
        action_arg = "sylvan",
        action = "upgrade_power",
        image = "kr3_special_icons_0112",
        place = 1,
        halo = "glow_ico_special",
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
        }},
        is_kr3 = true
    }, {
        check = "kr3_special_icons_0020",
        action_arg = "nature",
        action = "upgrade_power",
        image = "kr3_special_icons_0111",
        place = 2,
        halo = "glow_ico_special",
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
        }},
        is_kr3 = true
    }, {
        halo = "glow_ico_sub",
        image = "sub_icons_0001",
        action = "tw_rally",
        place = 8
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    entwood = {{{
        check = "kr3_special_icons_0020",
        action_arg = "clobber",
        action = "upgrade_power",
        image = "kr3_special_icons_0113",
        place = 2,
        halo = "glow_ico_special",
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
        }},
        is_kr3 = true
    }, {
        check = "kr3_special_icons_0020",
        action_arg = "fiery_nuts",
        action = "upgrade_power",
        image = "kr3_special_icons_0114",
        place = 1,
        halo = "glow_ico_special",
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
        }},
        is_kr3 = true
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    arcane = {{{
        check = "kr3_special_icons_0020",
        action_arg = "burst",
        action = "upgrade_power",
        image = "kr3_special_icons_0101",
        place = 1,
        halo = "glow_ico_special",
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
        }},
        is_kr3 = true
    }, {
        check = "kr3_special_icons_0020",
        action_arg = "slumber",
        action = "upgrade_power",
        image = "kr3_special_icons_0100",
        place = 2,
        halo = "glow_ico_special",
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
        }},
        is_kr3 = true
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    silver = {{{
        check = "kr3_special_icons_0020",
        action_arg = "sentence",
        action = "upgrade_power",
        image = "kr3_special_icons_0102",
        place = 1,
        halo = "glow_ico_special",
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
        }},
        is_kr3 = true
    }, {
        check = "kr3_special_icons_0020",
        action_arg = "mark",
        action = "upgrade_power",
        image = "kr3_special_icons_0103",
        place = 2,
        halo = "glow_ico_special",
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
        }},
        is_kr3 = true
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    wild_magus = {{{
        check = "kr3_special_icons_0020",
        action_arg = "eldritch",
        action = "upgrade_power",
        image = "kr3_special_icons_0115",
        place = 1,
        halo = "glow_ico_special",
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
        }},
        is_kr3 = true
    }, {
        check = "kr3_special_icons_0020",
        action_arg = "ward",
        action = "upgrade_power",
        image = "kr3_special_icons_0116",
        place = 2,
        halo = "glow_ico_special",
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
        }},
        is_kr3 = true
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    high_elven = {{{
        check = "kr3_special_icons_0020",
        action_arg = "timelapse",
        action = "upgrade_power",
        image = "kr3_special_icons_0117",
        place = 1,
        halo = "glow_ico_special",
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
        }},
        is_kr3 = true
    }, {
        check = "kr3_special_icons_0020",
        action_arg = "sentinel",
        action = "upgrade_power",
        image = "kr3_special_icons_0118",
        place = 2,
        halo = "glow_ico_special",
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
        }},
        is_kr3 = true
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    holder_ewok = {{{
        check = "main_icons_0019",
        action_arg = "tower_ewok",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0015",
        place = 5,
        tt_title = _("ELVES_EWOK_TOWER_BROKEN_NAME"),
        tt_desc = _("ELVES_EWOK_TOWER_BROKEN_DESCRIPTION"),
        is_kr3 = true
    }}},
    ewok = {{{
        check = "special_icons_0020",
        action_arg = "armor",
        action = "upgrade_power",
        image = "special_icons_0041",
        place = 6,
        halo = "glow_ico_special",
        sounds = {"ElvesEwokTaunt"},
        tt_phrase = _("以树为甲……"),
        tt_list = {{
            tt_title = _("大树护甲"),
            tt_desc = _("提升伊渥克士兵的护甲")
        }, {
            tt_title = _("大树护甲Ⅱ"),
            tt_desc = _("进一步提升伊渥克士兵的护甲")
        }, {
            tt_title = _("大树护甲Ⅲ"),
            tt_desc = _("进一步提升伊渥克士兵的护甲")
        }},
        is_kr3 = true
    }, {
        check = "special_icons_0020",
        action_arg = "shield",
        action = "upgrade_power",
        image = "special_icons_0009",
        place = 5,
        halo = "glow_ico_special",
        sounds = {"ElvesEwokTaunt"},
        tt_phrase = _("举盾，防御！"),
        tt_list = {{
            tt_title = _("盾势"),
            tt_desc = _("提升伊渥克士兵盾牌格挡的时间，并附带恢复效果")
        }, {
            tt_title = _("盾势Ⅱ"),
            tt_desc = _("提升伊渥克士兵盾牌格挡的时间和恢复效果")
        }},
        is_kr3 = true
    }, {
        check = "kr3_special_icons_0020",
        action_arg = "tear",
        action = "upgrade_power",
        image = "kr3_special_icons_0110",
        place = 7,
        halo = "glow_ico_special",
        sounds = {"ElvesEwokTaunt"},
        tt_phrase = _("撕碎他们的防御！"),
        tt_list = {{
            tt_title = _("碎甲投索"),
            tt_desc = _("使投索获得削弱护甲的能力，并提升投索伤害")
        }, {
            tt_title = _("碎甲投索Ⅱ"),
            tt_desc = _("提升投索碎甲能力和伤害")
        }, {
            tt_title = _("碎甲投索Ⅲ"),
            tt_desc = _("提升投索碎甲能力和伤害")
        }},
        is_kr3 = true
    }, {
        halo = "glow_ico_sub",
        image = "sub_icons_0001",
        action = "tw_rally",
        place = 8
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    faerie_dragon = {{{
        check = "special_icons_0020",
        action_arg = "more_dragons",
        action = "upgrade_power",
        image = "kr3_special_icons_0124",
        place = 1,
        halo = "glow_ico_special",
        sounds = {"ElvesFaeryDragonDragonBuy"},
        tt_phrase = _("ELVES_TOWER_SPECIAL_FAERIE_DRAGONS_UPGRADE_MORE_DRAGONS_NOTE"),
        tt_list = {{
            tt_title = _("ELVES_TOWER_SPECIAL_FAERIE_DRAGONS_UPGRADE_MORE_DRAGONS_NAME_1"),
            tt_desc = _("ELVES_TOWER_SPECIAL_FAERIE_DRAGONS_UPGRADE_MORE_DRAGONS_SMALL_DESCRIPTION_1")
        }, {
            tt_title = _("ELVES_TOWER_SPECIAL_FAERIE_DRAGONS_UPGRADE_MORE_DRAGONS_NAME_2"),
            tt_desc = _("ELVES_TOWER_SPECIAL_FAERIE_DRAGONS_UPGRADE_MORE_DRAGONS_SMALL_DESCRIPTION_2")
        }, {
            tt_title = _("ELVES_TOWER_SPECIAL_FAERIE_DRAGONS_UPGRADE_MORE_DRAGONS_NAME_3"),
            tt_desc = _("ELVES_TOWER_SPECIAL_FAERIE_DRAGONS_UPGRADE_MORE_DRAGONS_SMALL_DESCRIPTION_3")
        }},
        is_kr3 = true
    }, {
        check = "special_icons_0020",
        action_arg = "improve_shot",
        action = "upgrade_power",
        image = "kr3_special_icons_0125",
        place = 2,
        halo = "glow_ico_special",
        sounds = {"ElvesFaeryDragonExtraAbility"},
        tt_phrase = _("ELVES_TOWER_SPECIAL_FAERIE_DRAGONS_UPGRADE_IMPROVE_SHOT_NOTE"),
        tt_list = {{
            tt_title = _("ELVES_TOWER_SPECIAL_FAERIE_DRAGONS_UPGRADE_IMPROVE_SHOT_NAME_1"),
            tt_desc = _("ELVES_TOWER_SPECIAL_FAERIE_DRAGONS_UPGRADE_IMPROVE_SHOT_SMALL_DESCRIPTION_1")
        }, {
            tt_title = _("ELVES_TOWER_SPECIAL_FAERIE_DRAGONS_UPGRADE_IMPROVE_SHOT_NAME_2"),
            tt_desc = _("ELVES_TOWER_SPECIAL_FAERIE_DRAGONS_UPGRADE_IMPROVE_SHOT_SMALL_DESCRIPTION_2")
        }},
        is_kr3 = true
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    pixie = {{{
        check = "special_icons_0020",
        action_arg = "cream",
        action = "upgrade_power",
        image = "kr3_special_icons_0122",
        place = 1,
        halo = "glow_ico_special",
        sounds = {"ElvesGnomeNew"},
        tt_phrase = _("ELVES_TOWER_PIXIE_UPGRADE1_NOTE"),
        tt_list = {{
            tt_title = _("ELVES_TOWER_PIXIE_UPGRADE1_NAME_1"),
            tt_desc = _("ELVES_TOWER_PIXIE_UPGRADE1_DESCRIPTION_1")
        }, {
            tt_title = _("ELVES_TOWER_PIXIE_UPGRADE1_NAME_2"),
            tt_desc = _("ELVES_TOWER_PIXIE_UPGRADE1_DESCRIPTION_2")
        }},
        is_kr3 = true
    }, {
        check = "special_icons_0020",
        action_arg = "total",
        action = "upgrade_power",
        image = "kr3_special_icons_0123",
        place = 2,
        halo = "glow_ico_special",
        sounds = {"ElvesGnomePower"},
        tt_phrase = _("ELVES_TOWER_PIXIE_UPGRADE2_NOTE"),
        tt_list = {{
            tt_title = _("ELVES_TOWER_PIXIE_UPGRADE2_NAME_1"),
            tt_desc = _("ELVES_TOWER_PIXIE_UPGRADE2_DESCRIPTION_1")
        }, {
            tt_title = _("ELVES_TOWER_PIXIE_UPGRADE2_NAME_2"),
            tt_desc = _("ELVES_TOWER_PIXIE_UPGRADE2_DESCRIPTION_2")
        }, {
            tt_title = _("ELVES_TOWER_PIXIE_UPGRADE2_NAME_3"),
            tt_desc = _("ELVES_TOWER_PIXIE_UPGRADE2_DESCRIPTION_3")
        }},
        is_kr3 = true
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    baby_black_dragon = {{{
        check = "main_icons_0019",
        action_arg = 1,
        action = "tw_buy_attack",
        halo = "glow_ico_main",
        image = "kr3_main_icons_0114",
        place = 5,
        tt_title = _("ELVES_BABY_BERESAD_SPECIAL_NAME_1"),
        tt_desc = _("ELVES_BABY_BERESAD_SPECIAL_SMALL_DESCRIPTION_1"),
        is_kr3 = true

    }}},
    holder_baby_ashbite = {{{
        check = "main_icons_0019",
        action_arg = "tower_baby_ashbite",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "kr3_main_icons_0113",
        place = 5,
        tt_title = _("ELVES_BABY_ASHBITE_TOWER_BROKEN_NAME"),
        tt_desc = _("ELVES_BABY_ASHBITE_TOWER_BROKEN_DESCRIPTION"),
        is_kr3 = true

    }}},
    baby_ashbite = {{{
        check = "special_icons_0020",
        action_arg = "blazing_breath",
        action = "upgrade_power",
        image = "kr3_special_icons_0126",
        place = 1,
        halo = "glow_ico_special",
        sounds = {"ElvesAshbiteConfirm"},
        tt_phrase = _("ELVES_BABY_ASHBITE_FIREBREATH_NOTE"),
        tt_list = {{
            tt_title = _("ELVES_BABY_ASHBITE_FIREBREATH_NAME_1"),
            tt_desc = _("ELVES_BABY_ASHBITE_FIREBREATH_SMALL_DESCRIPTION_1")
        }, {
            tt_title = _("ELVES_BABY_ASHBITE_FIREBREATH_NAME_2"),
            tt_desc = _("ELVES_BABY_ASHBITE_FIREBREATH_SMALL_DESCRIPTION_2")
        }, {
            tt_title = _("ELVES_BABY_ASHBITE_FIREBREATH_NAME_3"),
            tt_desc = _("ELVES_BABY_ASHBITE_FIREBREATH_SMALL_DESCRIPTION_3")
        }},
        is_kr3 = true
    }, {
        check = "special_icons_0020",
        action_arg = "fiery_mist",
        action = "upgrade_power",
        image = "kr3_special_icons_0127",
        place = 2,
        halo = "glow_ico_special",
        sounds = {"ElvesAshbiteConfirm"},
        tt_phrase = _("ELVES_BABY_ASHBITE_SMOKEBREATH_NOTE"),
        tt_list = {{
            tt_title = _("ELVES_BABY_ASHBITE_SMOKEBREATH_NAME_1"),
            tt_desc = _("ELVES_BABY_ASHBITE_SMOKEBREATH_SMALL_DESCRIPTION_1")
        }},
        is_kr3 = true
    }, {
        halo = "glow_ico_sub",
        image = "sub_icons_0001",
        action = "tw_rally",
        place = 8
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    drow = {{{
        check = "special_icons_0020",
        action_arg = "life_drain",
        action = "upgrade_power",
        image = "kr3_special_icons_0120",
        place = 6,
        halo = "glow_ico_special",
        sounds = {"ElvesSpecialDrowLifeDrain"},
        tt_phrase = _("ELVES_TOWER_DROW_LIFE_DRAIN_NOTE"),
        tt_list = {{
            tt_title = _("ELVES_TOWER_DROW_LIFE_DRAIN_NAME_1"),
            tt_desc = _("ELVES_TOWER_DROW_LIFE_DRAIN_SMALL_DESCRIPTION_1")
        }, {
            tt_title = _("ELVES_TOWER_DROW_LIFE_DRAIN_NAME_2"),
            tt_desc = _("ELVES_TOWER_DROW_LIFE_DRAIN_SMALL_DESCRIPTION_2")
        }, {
            tt_title = _("ELVES_TOWER_DROW_LIFE_DRAIN_NAME_3"),
            tt_desc = _("ELVES_TOWER_DROW_LIFE_DRAIN_SMALL_DESCRIPTION_3")
        }},
        is_kr3 = true

    }, {
        check = "special_icons_0020",
        action_arg = "blade_mail",
        action = "upgrade_power",
        image = "kr3_special_icons_0119",
        place = 7,
        halo = "glow_ico_special",
        sounds = {"ElvesSpecialDrowBlademail"},
        tt_phrase = _("ELVES_TOWER_DROW_BLADE_MAIL_NOTE"),
        tt_list = {{
            tt_title = _("ELVES_TOWER_DROW_BLADE_MAIL_NAME_1"),
            tt_desc = _("ELVES_TOWER_DROW_BLADE_MAIL_SMALL_DESCRIPTION_1")
        }, {
            tt_title = _("ELVES_TOWER_DROW_BLADE_MAIL_NAME_2"),
            tt_desc = _("ELVES_TOWER_DROW_BLADE_MAIL_SMALL_DESCRIPTION_2")
        }, {
            tt_title = _("ELVES_TOWER_DROW_BLADE_MAIL_NAME_3"),
            tt_desc = _("ELVES_TOWER_DROW_BLADE_MAIL_SMALL_DESCRIPTION_3")
        }},
        is_kr3 = true

    }, {
        check = "special_icons_0020",
        action_arg = "double_dagger",
        action = "upgrade_power",
        image = "kr3_special_icons_0121",
        place = 5,
        halo = "glow_ico_special",
        sounds = {"ElvesSpecialDrowDaggers"},
        tt_phrase = _("ELVES_TOWER_DROW_DOUBLE_DAGGER_NOTE"),
        tt_list = {{
            tt_title = _("ELVES_TOWER_DROW_DOUBLE_DAGGER_NAME_1"),
            tt_desc = _("ELVES_TOWER_DROW_DOUBLE_DAGGER_SMALL_DESCRIPTION_1")
        }, {
            tt_title = _("ELVES_TOWER_DROW_DOUBLE_DAGGER_NAME_2"),
            tt_desc = _("ELVES_TOWER_DROW_DOUBLE_DAGGER_SMALL_DESCRIPTION_2")
        }, {
            tt_title = _("ELVES_TOWER_DROW_DOUBLE_DAGGER_NAME_3"),
            tt_desc = _("ELVES_TOWER_DROW_DOUBLE_DAGGER_SMALL_DESCRIPTION_3")
        }},
        is_kr3 = true

    }, {
        halo = "glow_ico_sub",
        image = "sub_icons_0001",
        action = "tw_rally",
        place = 8
    }, {
        check = "ico_sell_0002",
        action = "tw_sell",
        halo = "glow_ico_sell",
        image = "ico_sell_0001",
        place = 9
    }}},
    holder_bastion = {{{
        check = "main_icons_0019",
        action_arg = "tower_bastion",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0015",
        place = 5,
        tt_title = _("ELVES_TOWER_BASTION_BROKEN_NAME"),
        tt_desc = _("ELVES_TOWER_BASTION_BROKEN_DESCRIPTION"),
        is_kr3 = true

    }}},
    bastion = {{{
        check = "special_icons_0020",
        action_arg = "razor_edge",
        action = "upgrade_power",
        image = "kr3_special_icons_0128",
        place = 5,
        halo = "glow_ico_special",
        sounds = {"ElvesTowerBastionRazorEdge"},
        tt_phrase = _("ELVES_TOWER_BASTION_RAZOR_EDGE_NOTE"),
        tt_list = {{
            tt_title = _("ELVES_TOWER_BASTION_RAZOR_EDGE_NAME_1"),
            tt_desc = _("ELVES_TOWER_BASTION_RAZOR_EDGE_SMALL_DESCRIPTION_1")
        }, {
            tt_title = _("ELVES_TOWER_BASTION_RAZOR_EDGE_NAME_2"),
            tt_desc = _("ELVES_TOWER_BASTION_RAZOR_EDGE_SMALL_DESCRIPTION_2")
        }},
        is_kr3 = true
    }}},
    tricannon = {
        {
			{
				check = "special_icons_0020",
				action_arg = "bombardment",
				action = "upgrade_power",
				image = "kr5_special_icons_0007",
				place = 6,
				halo = "glow_ico_special",
				sounds = {
					"TowerTricannonSkillATaunt"
				},
				tt_phrase = _("TOWER_TRICANNON_4_BOMBARDMENT_NOTE"),
				tt_list = {
					{
						tt_title = _("TOWER_TRICANNON_4_BOMBARDMENT_1_NAME"),
						tt_desc = _("TOWER_TRICANNON_4_BOMBARDMENT_1_DESCRIPTION")
					},
					{
						tt_title = _("TOWER_TRICANNON_4_BOMBARDMENT_2_NAME"),
						tt_desc = _("TOWER_TRICANNON_4_BOMBARDMENT_2_DESCRIPTION")
					},
					{
						tt_title = _("TOWER_TRICANNON_4_BOMBARDMENT_3_NAME"),
						tt_desc = _("TOWER_TRICANNON_4_BOMBARDMENT_3_DESCRIPTION")
					}
				},
                is_kr3 = true,
                is_kr5 = true
			},
			{
				check = "special_icons_0020",
				action_arg = "overheat",
				action = "upgrade_power",
				image = "kr5_special_icons_0008",
				place = 7,
				halo = "glow_ico_special",
				sounds = {
					"TowerTricannonSkillBTaunt"
				},
				tt_phrase = _("TOWER_TRICANNON_4_OVERHEAT_NOTE"),
				tt_list = {
					{
						tt_title = _("TOWER_TRICANNON_4_OVERHEAT_1_NAME"),
						tt_desc = _("TOWER_TRICANNON_4_OVERHEAT_1_DESCRIPTION")
					},
					{
						tt_title = _("TOWER_TRICANNON_4_OVERHEAT_2_NAME"),
						tt_desc = _("TOWER_TRICANNON_4_OVERHEAT_2_DESCRIPTION")
					},
					{
						tt_title = _("TOWER_TRICANNON_4_OVERHEAT_3_NAME"),
						tt_desc = _("TOWER_TRICANNON_4_OVERHEAT_3_DESCRIPTION")
					}
				},
                is_kr3 = true,
                is_kr5 = true
			},
			{
                check = "ico_sell_0002",
                action = "tw_sell",
                halo = "glow_ico_sell",
                image = "ico_sell_0001",
                place = 9
            }
		}
    },
    dark_elf = {
        {
            {
                check = "ico_sell_0002",
                action = "tw_sell",
                halo = "glow_ico_sell",
                image = "ico_sell_0001",
                place = 9
            },
            {
                check = "kr5_quickmenu_action_icons_0003",
                action = "tw_change_mode",
                image = "kr5_quickmenu_action_icons_0005",
                place = 3,
                halo = "kr5_quickmenu_action_icons_0001_hover",
                tt_title_mode1 = _("TOWER_DARK_ELF_CHANGE_MODE_MAXHP_NAME"),
                tt_desc_mode1 = _("TOWER_DARK_ELF_CHANGE_MODE_MAXHP_DESCRIPTION"),
                tt_phrase_mode1 = _("TOWER_DARK_ELF_CHANGE_MODE_MAXHP_NOTE"),
                tt_title_mode0 = _("TOWER_DARK_ELF_CHANGE_MODE_FOREMOST_NAME"),
                tt_desc_mode0 = _("TOWER_DARK_ELF_CHANGE_MODE_FOREMOST_DESCRIPTION"),
                tt_phrase_mode0 = _("TOWER_DARK_ELF_CHANGE_MODE_FOREMOST_NOTE"),
                is_kr5 = true
            },
            {
                check = "kr5_special_icons_0020",
                action_arg = "skill_soldiers",
                action = "upgrade_power",
                image = "kr5_special_icons_0032",
                place = 6,
                halo = "glow_ico_special",
                sounds = {
                    "TowerDarkElfSkillATaunt"
                },
                tt_phrase = _("TOWER_DARK_ELF_4_SKILL_SOLDIERS_NOTE"),
                tt_list = {
                    {
                        tt_title = _("TOWER_DARK_ELF_4_SKILL_SOLDIERS_1_NAME"),
                        tt_desc = _("TOWER_DARK_ELF_4_SKILL_SOLDIERS_1_DESCRIPTION")
                    },
                    {
                        tt_title = _("TOWER_DARK_ELF_4_SKILL_SOLDIERS_2_NAME"),
                        tt_desc = _("TOWER_DARK_ELF_4_SKILL_SOLDIERS_2_DESCRIPTION")
                    },
                    {
                        tt_title = _("TOWER_DARK_ELF_4_SKILL_SOLDIERS_3_NAME"),
                        tt_desc = _("TOWER_DARK_ELF_4_SKILL_SOLDIERS_3_DESCRIPTION")
                    }
                },
                is_kr5 = true
            },
            {
                check = "kr5_special_icons_0020",
                action_arg = "skill_buff",
                action = "upgrade_power",
                image = "kr5_special_icons_0033",
                place = 7,
                halo = "glow_ico_special",
                sounds = {
                    "TowerDarkElfSkillBTaunt"
                },
                tt_phrase = _("TOWER_DARK_ELF_4_SKILL_BUFF_NOTE"),
                tt_list = {
                    {
                        tt_title = _("TOWER_DARK_ELF_4_SKILL_BUFF_1_NAME"),
                        tt_desc = _("TOWER_DARK_ELF_4_SKILL_BUFF_1_DESCRIPTION")
                    },
                    {
                        tt_title = _("TOWER_DARK_ELF_4_SKILL_BUFF_2_NAME"),
                        tt_desc = _("TOWER_DARK_ELF_4_SKILL_BUFF_2_DESCRIPTION")
                    },
                    {
                        tt_title = _("TOWER_DARK_ELF_4_SKILL_BUFF_3_NAME"),
                        tt_desc = _("TOWER_DARK_ELF_4_SKILL_BUFF_3_DESCRIPTION")
                    }
                },
                is_kr5 = true
            },
            {
                halo = "glow_ico_sub",
                image = "sub_icons_0001",
                action = "tw_rally",
                place = 8
            }
        }
    }
}
