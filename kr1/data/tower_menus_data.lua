-- chunkname: @./kr1/data/tower_menus_data.lua
local templates = require("data.tower_menus_data_templates")
local scripts = require("kr1.data.tower_menus_data_scripts")
local merge = scripts.merge
local i18n = require("i18n")
return {
    -- 塔位
    holder = {
        {
            merge(templates.upgrade, {
                action_arg = "tower_build_archer",
                image = "main_icons_0001",
                place = 1,
                preview = "archer",
                tt_title = _("TOWER_ARCHER_1_NAME"),
                tt_desc = _("TOWER_ARCHER_1_DESCRIPTION")
            }),
            merge(templates.upgrade, {
                action_arg = "tower_build_barrack",
                image = "main_icons_0002",
                place = 2,
                preview = "barrack",
                tt_title = _("TOWER_BARRACK_1_NAME"),
                tt_desc = _("TOWER_BARRACK_1_DESCRIPTION")
            }),
            merge(templates.upgrade, {
                action_arg = "tower_build_mage",
                image = "main_icons_0003",
                place = 3,
                preview = "mage",
                tt_title = _("TOWER_MAGE_1_NAME"),
                tt_desc = _("TOWER_MAGE_1_DESCRIPTION")
            }),
            merge(templates.upgrade, {
                action_arg = "tower_build_engineer",
                image = "main_icons_0004",
                place = 4,
                preview = "engineer",
                tt_title = _("TOWER_ENGINEER_1_NAME"),
                tt_desc = _("TOWER_ENGINEER_1_DESCRIPTION")
            })
        }
    },
    holder_blocked_jungle = {
        {
            {
                action_arg = "tower_holder",
                action = "tw_unblock",
                halo = "glow_ico_main",
                image = "main_icons_0037",
                place = 5,
                tt_title = _("SPECIAL_REPAIR_HOLDER_JUNGLE_NAME"),
                tt_desc = _("SPECIAL_REPAIR_HOLDER_JUNGLE_DESCRIPTION")
            }
        }
    },
    holder_blocked_underground = {
        {
            {
                action_arg = "tower_holder",
                action = "tw_unblock",
                halo = "glow_ico_main",
                image = "main_icons_0037",
                place = 5,
                tt_title = _("SPECIAL_REPAIR_HOLDER_UNDERGROUND_NAME"),
                tt_desc = _("SPECIAL_REPAIR_HOLDER_UNDERGROUND_DESCRIPTION")
            }
        }
    },

    -- 法师塔
    mage = {
        -- 二级法师塔
        {
            merge(templates.common_upgrade, {
                action_arg = "tower_mage_2",
                tt_title = _("TOWER_MAGE_2_NAME"),
                tt_desc = _("TOWER_MAGE_2_DESCRIPTION")
            }),
            templates.sell
        },
        -- 三级法师塔
        {
            merge(templates.common_upgrade, {
                action_arg = "tower_mage_3",
                tt_title = _("TOWER_MAGE_3_NAME"),
                tt_desc = _("TOWER_MAGE_3_DESCRIPTION")
            }),
            templates.sell
        },
        -- 四级法师塔
        {
            merge(templates.upgrade, {
                action_arg = "tower_arcane_wizard",
                image = "main_icons_0006",
                place = 5,
                tt_title = _("TOWER_ARCANE_NAME"),
                tt_desc = _("TOWER_ARCANE_DESCRIPTION")
            }),
            merge(templates.upgrade, {
                action_arg = "tower_sorcerer",
                image = "main_icons_0007",
                place = 6,
                tt_title = _("TOWER_SORCERER_NAME"),
                tt_desc = _("TOWER_SORCERER_DESCRIPTION")
            }),
            merge(templates.upgrade, {
                action_arg = "tower_sunray",
                image = "main_icons_0018",
                place = 7,
                tt_title = _("日光之塔"),
                tt_desc = _("巫师能借助日光之塔瓦解敌人，并炼制成金，提取力量。")
            }),
            merge(templates.upgrade, {
                action_arg = "tower_necromancer",
                image = "main_icons_0021",
                place = 10,
                tt_title = _("TOWER_NECROMANCER_NAME"),
                tt_desc = _("TOWER_NECROMANCER_DESCRIPTION")
            }),
            merge(templates.upgrade3, {
                check = "kr3_main_icons_0019",
                action_arg = "tower_high_elven",
                image = "kr3_main_icons_0107",
                place = 11,
                tt_title = _("TOWER_MAGE_HIGH_ELVEN_NAME"),
                tt_desc = _("TOWER_MAGE_HIGH_ELVEN_DESCRIPTION"),
            }),
            merge(templates.upgrade, {
                action_arg = "tower_archmage",
                image = "main_icons_0022",
                place = 12,
                tt_title = _("TOWER_ARCHMAGE_NAME"),
                tt_desc = _("TOWER_ARCHMAGE_DESCRIPTION")
            }),
            merge(templates.upgrade3, {
                action_arg = "tower_wild_magus",
                image = "kr3_main_icons_0106",
                place = 13,
                tt_title = _("TOWER_MAGE_WILD_MAGUS_NAME"),
                tt_desc = _("TOWER_MAGE_WILD_MAGUS_DESCRIPTION"),
            }),
            merge(templates.upgrade3, {
                action_arg = "tower_faerie_dragon",
                image = "kr3_special_icons_0124",
                place = 14,
                tt_title = _("ELVES_TOWER_SPECIAL_FAERIE_DRAGONS_NAME"),
                tt_desc = _("ELVES_TOWER_SPECIAL_FAERIE_DRAGONS_DESCRIPTION"),
            }),
            merge(templates.upgrade3, {
                action_arg = "tower_pixie",
                image = "kr3_special_icons_0122",
                place = 15,
                tt_title = _("ELVES_TOWER_PIXIE_NAME"),
                tt_desc = _("ELVES_TOWER_PIXIE_DESCRIPTION"),
            }),
            merge(templates.upgrade3, {
                action_arg = "tower_necromancer_lvl4",
                image = "kr5_main_icons_0011",
                place = 16,
                tt_title = _("TOWER_NECROMANCER_NAME"),
                tt_desc = _("TOWER_NECROMANCER_1_DESCRIPTION"),
            }),
            templates.sell
        },
    },

    -- 炮塔
    engineer = {
        -- 二级炮塔
        {
            merge(templates.common_upgrade, {
                action_arg = "tower_engineer_2",
                tt_title = _("TOWER_ENGINEER_2_NAME"),
                tt_desc = _("TOWER_ENGINEER_2_DESCRIPTION")
            }),
            templates.sell
        },
        -- 三级炮塔
        {
            merge(templates.common_upgrade, {
                action_arg = "tower_engineer_3",
                tt_title = _("TOWER_ENGINEER_3_NAME"),
                tt_desc = _("TOWER_ENGINEER_3_DESCRIPTION")
            }),
            templates.sell
        },
        -- 四级炮塔
        {
            merge(templates.upgrade, {
                action_arg = "tower_bfg",
                image = "main_icons_0013",
                place = 5,
                tt_title = _("TOWER_BFG_NAME"),
                tt_desc = _("TOWER_BFG_DESCRIPTION")
            }),
            merge(templates.upgrade, {
                action_arg = "tower_tesla",
                image = "main_icons_0012",
                place = 6,
                tt_title = _("TOWER_TESLA_NAME"),
                tt_desc = _("TOWER_TESLA_DESCRIPTION")
            }),
            merge(templates.upgrade, {
                action_arg = "tower_dwaarp",
                image = "main_icons_0027",
                place = 7,
                tt_title = _("TOWER_DWAARP_NAME"),
                tt_desc = _("TOWER_DWAARP_DESCRIPTION")
            }),
            merge(templates.upgrade, {
                action_arg = "tower_mech",
                image = "main_icons_0028",
                place = 10,
                tt_title = _("TOWER_MECH_NAME"),
                tt_desc = _("TOWER_MECH_DESCRIPTION")
            }),
            merge(templates.upgrade, {
                action_arg = "tower_frankenstein",
                image = "main_icons_0039",
                place = 11,
                tt_title = _("SPECIAL_TOWER_FRANKENSTEIN_NAME"),
                tt_desc = _("SPECIAL_TOWER_FRANKENSTEIN_DESCRIPTION")
            }),
            merge(templates.upgrade3, {
                action_arg = "tower_druid",
                image = "kr3_main_icons_0111",
                place = 12,
                tt_title = _("TOWER_STONE_DRUID_NAME"),
                tt_desc = _("TOWER_STONE_DRUID_DESCRIPTION"),
            }),
            merge(templates.upgrade3, {
                action_arg = "tower_entwood",
                image = "kr3_main_icons_0110",
                place = 13,
                tt_title = _("TOWER_ENTWOOD_NAME"),
                tt_desc = _("TOWER_ENTWOOD_DESCRIPTION"),
            }),
            merge(templates.upgrade5, {
                action_arg = "tower_tricannon_lvl4",
                image = "kr5_main_icons_0004",
                tt_title = _("TOWER_TRICANNON_NAME"),
                tt_desc = _("TOWER_TRICANNON_1_DESCRIPTION"),
                place = 14,
            }),
            merge(templates.upgrade5, {
                action_arg = "tower_demon_pit_lvl4",
                image = "kr5_main_icons_0007",
                tt_title = _("TOWER_DEMON_PIT_NAME"),
                tt_desc = _("TOWER_DEMON_PIT_1_DESCRIPTION"),
                place = 16,
            }),
            templates.sell,
        }
    },

    -- 箭塔
    archer = {
        -- 二级箭塔
        {
            merge(templates.common_upgrade, {
                action_arg = "tower_archer_2",
                tt_title = _("TOWER_ARCHER_2_NAME"),
                tt_desc = _("TOWER_ARCHER_2_DESCRIPTION")
            }),
            templates.sell
        },
        -- 三级箭塔
        {
            merge(templates.common_upgrade, {
                action_arg = "tower_archer_3",
                tt_title = _("TOWER_ARCHER_3_NAME"),
                tt_desc = _("TOWER_ARCHER_3_DESCRIPTION")
            }),
            templates.sell
        },
        -- 四级箭塔
        {
            merge(templates.upgrade, {
                action_arg = "tower_ranger",
                image = "main_icons_0011",
                place = 5,
                tt_title = _("TOWER_RANGERS_NAME"),
                tt_desc = _("TOWER_RANGERS_DESCRIPTION")
            }),
            merge(templates.upgrade, {
                action_arg = "tower_musketeer",
                image = "main_icons_0010",
                place = 6,
                tt_title = _("TOWER_MUSKETEERS_NAME"),
                tt_desc = _("TOWER_MUSKETEERS_DESCRIPTION")
            }),
            merge(templates.upgrade, {
                action_arg = "tower_crossbow",
                image = "main_icons_0025",
                place = 7,
                tt_title = _("TOWER_CROSSBOW_NAME"),
                tt_desc = _("TOWER_CROSSBOW_DESCRIPTION")
            }),
            merge(templates.upgrade, {
                action_arg = "tower_totem",
                image = "main_icons_0026",
                place = 10,
                tt_title = _("TOWER_TOTEM_NAME"),
                tt_desc = _("TOWER_TOTEM_DESCRIPTION")
            }),
            merge(templates.upgrade, {
                action_arg = "tower_archer_dwarf",
                image = "main_icons_0034",
                place = 11,
                tt_title = _("SPECIAL_DWARF_TOWER1_NAME"),
                tt_desc = _("SPECIAL_DWARF_TOWER1_DESCRIPTION")
            }),
            merge(templates.upgrade, {
                action_arg = "tower_pirate_watchtower",
                image = "main_icons_0032",
                place = 12,
                tt_title = _("TOWER_PIRATE_WATCHTOWER_NAME"),
                tt_desc = _("TOWER_PIRATE_WATCHTOWER_DESCRIPTION")
            }),
            merge(templates.upgrade3, {
                action_arg = "tower_arcane",
                image = "kr3_main_icons_0108",
                place = 13,
                tt_title = _("TOWER_ARCANE_ARCHER_NAME"),
                tt_desc = _("TOWER_ARCANE_ARCHER_DESCRIPTION"),
            }),
            merge(templates.upgrade3, {
                action_arg = "tower_silver",
                image = "kr3_main_icons_0109",
                place = 14,
                tt_title = _("TOWER_SILVER_NAME"),
                tt_desc = _("TOWER_SILVER_DESCRIPTION"),
            }),
            merge(templates.upgrade5, {
                action_arg = "tower_dark_elf_lvl4",
                image = "kr5_main_icons_0032",
                place = 15,
                tt_title = _("TOWER_DARK_ELF_NAME"),
                tt_desc = _("TOWER_DARK_ELF_1_DESCRIPTION"),
            }),
            templates.sell
        }
    },

    -- 兵营
    barrack = {
        -- 二级兵营
        {
            merge(templates.common_upgrade, {
                action_arg = "tower_barrack_2",
                tt_title = _("TOWER_BARRACK_2_NAME"),
                tt_desc = _("TOWER_BARRACK_2_DESCRIPTION")
            }),
            templates.rally,
            templates.sell
        },
        -- 三级兵营
        {
            table.merge(templates.common_upgrade, {
                action_arg = "tower_barrack_3",
                tt_title = _("TOWER_BARRACK_3_NAME"),
                tt_desc = _("TOWER_BARRACK_3_DESCRIPTION")
            }),
            templates.rally,
            templates.sell
        },
        -- 四级兵营
        {
            merge(templates.upgrade, {
                action_arg = "tower_paladin",
                image = "main_icons_0008",
                place = 5,
                tt_title = _("TOWER_PALADINS_NAME"),
                tt_desc = _("TOWER_PALADINS_DESCRIPTION")
            }),
            merge(templates.upgrade, {
                action_arg = "tower_barbarian",
                image = "main_icons_0009",
                place = 6,
                tt_title = _("TOWER_BARBARIANS_NAME"),
                tt_desc = _("TOWER_BARBARIANS_DESCRIPTION")
            }),
            merge(templates.upgrade, {
                action_arg = "tower_elf",
                image = "main_icons_0011",
                place = 7,
                tt_title = _("精灵哨站"),
                tt_desc = _("训练精灵游侠，弓与剑的大师。脆弱无比，但也能迅捷地取敌性命。")
            }),
            merge(templates.upgrade, {
                action_arg = "tower_templar",
                image = "main_icons_0023",
                place = 10,
                tt_title = _("TOWER_TEMPLAR_NAME"),
                tt_desc = _("TOWER_TEMPLAR_DESCRIPTION")
            }),
            merge(templates.upgrade, {
                action_arg = "tower_assassin",
                image = "main_icons_0024",
                place = 11,
                tt_title = _("TOWER_ASSASSIN_NAME"),
                tt_desc = _("TOWER_ASSASSIN_DESCRIPTION")
            }),
            merge(templates.upgrade, {
                action_arg = "tower_barrack_dwarf",
                image = "main_icons_0015",
                place = 12,
                tt_title = _("TOWER_BARRACK_DWARF_NAME"),
                tt_desc = _("TOWER_BARRACK_DWARF_DESCRIPTION")
            }),
            merge(templates.upgrade, {
                action_arg = "tower_barrack_amazonas",
                image = "main_icons_0033",
                place = 13,
                tt_title = _("SPECIAL_AMAZONAS_NAME"),
                tt_desc = _("SPECIAL_AMAZONAS_DESCRIPTION")
            }),
            merge(templates.upgrade, {
                action_arg = "tower_barrack_mercenaries",
                image = "main_icons_0030",
                place = 14,
                tt_title = _("SPECIAL_DJINN_NAME"),
                tt_desc = _("SPECIAL_DJINN_DESCRIPTION")
            }),
            merge(templates.upgrade, {
                action_arg = "tower_barrack_pirates",
                image = "main_icons_0032",
                place = 15,
                tt_title = _("TOWER_BARRACK_PIRATES_NAME"),
                tt_desc = _("TOWER_BARRACK_PIRATES_DESCRIPTION")
            }),
            merge(templates.upgrade3, {
                action_arg = "tower_blade",
                image = "kr3_main_icons_0104",
                place = 16,
                tt_title = _("TOWER_BARRACKS_BLADE_NAME"),
                tt_desc = _("TOWER_BARRACKS_BLADE_DESCRIPTION"),
            }),
            merge(templates.upgrade3, {
                action_arg = "tower_forest",
                image = "kr3_main_icons_0105",
                place = 17,
                tt_title = _("TOWER_FOREST_KEEPERS_NAME"),
                tt_desc = _("TOWER_FOREST_KEEPERS_DESCRIPTION"),
            }),
            merge(templates.upgrade3, {
                action_arg = "tower_drow",
                image = "kr3_special_icons_0121",
                place = 18,
                tt_title = _("ELVES_TOWER_SPECIAL_DROW_NAME"),
                tt_desc = _("ELVES_TOWER_SPECIAL_DROW_DESCRIPTION"),
            }),
            merge(templates.upgrade3, {
                action_arg = "tower_ewok",
                image = "kr3_main_icons_0112",
                place = 19,
                tt_title = _("ELVES_EWOK_NAME"),
                tt_desc = _("ELVES_EWOK_DESCRIPTION"),
            }),
            merge(templates.upgrade3, {
                action_arg = "tower_baby_ashbite",
                image = "kr3_main_icons_0113",
                place = 20,
                tt_title = _("ELVES_BABY_ASHBITE_TOWER_BROKEN_NAME"),
                tt_desc = _("ELVES_BABY_ASHBITE_TOWER_BROKEN_DESCRIPTION"),
            }),
            merge(templates.upgrade5, {
                action_arg = "tower_pandas_lvl4",
                image = "kr5_main_icons_0049",
                place = 21,
                tt_title = _("TOWER_PANDAS_NAME"),
                tt_desc = _("TOWER_PANDAS_1_DESCRIPTION")
            }),
            templates.rally,
            templates.sell
        }
    },

    ranger = {
        {
            merge(templates.upgrade_power, {
                action_arg = "poison",
                image = "special_icons_0008",
                place = 1,
                sounds = { "ArcherRangerPoisonTaunt" },
                tt_phrase = _("TOWER_RANGERS_POISON_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_RANGERS_POISON_NAME_1"),
                        tt_desc = _("TOWER_RANGERS_POISON_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_RANGERS_POISON_NAME_2"),
                        tt_desc = _("TOWER_RANGERS_POISON_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_RANGERS_POISON_NAME_3"),
                        tt_desc = _("TOWER_RANGERS_POISON_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power, {
                action_arg = "thorn",
                image = "special_icons_0002",
                place = 2,
                sounds = { "ArcherRangerThornTaunt" },
                tt_phrase = _("TOWER_RANGERS_THORNS_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_RANGERS_THORNS_NAME_1"),
                        tt_desc = _("TOWER_RANGERS_THORNS_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_RANGERS_THORNS_NAME_2"),
                        tt_desc = _("TOWER_RANGERS_THORNS_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_RANGERS_THORNS_NAME_3"),
                        tt_desc = _("TOWER_RANGERS_THORNS_DESCRIPTION_3")
                    }
                }
            }),
            templates.sell
        }
    },

    musketeer = {
        {
            merge(templates.upgrade_power, {
                action_arg = "sniper",
                image = "special_icons_0003",
                place = 1,
                sounds = { "ArcherMusketeerSniperTaunt" },
                tt_phrase = _("TOWER_MUSKETEERS_SNIPER_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_MUSKETEERS_SNIPER_NAME_1"),
                        tt_desc = _("TOWER_MUSKETEERS_SNIPER_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_MUSKETEERS_SNIPER_NAME_2"),
                        tt_desc = _("TOWER_MUSKETEERS_SNIPER_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_MUSKETEERS_SNIPER_NAME_3"),
                        tt_desc = _("TOWER_MUSKETEERS_SNIPER_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power, {
                action_arg = "shrapnel",
                image = "special_icons_0005",
                place = 2,
                sounds = { "ArcherMusketeerShrapnelTaunt" },
                tt_phrase = _("TOWER_MUSKETEERS_SHRAPNEL_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_MUSKETEERS_SHRAPNEL_NAME_1"),
                        tt_desc = _("TOWER_MUSKETEERS_SHRAPNEL_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_MUSKETEERS_SHRAPNEL_NAME_2"),
                        tt_desc = _("TOWER_MUSKETEERS_SHRAPNEL_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_MUSKETEERS_SHRAPNEL_NAME_3"),
                        tt_desc = _("TOWER_MUSKETEERS_SHRAPNEL_DESCRIPTION_3")
                    }
                }
            }),
            templates.sell
        }
    },

    crossbow = {
        {
            merge(templates.upgrade_power, {
                action_arg = "multishot",
                image = "special_icons_0028",
                place = 1,
                sounds = { "CrossbowTauntMultishoot" },
                tt_phrase = _("TOWER_CROSSBOW_BARRAGE_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_CROSSBOW_BARRAGE_NAME_1"),
                        tt_desc = _("TOWER_CROSSBOW_BARRAGE_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_CROSSBOW_BARRAGE_NAME_2"),
                        tt_desc = _("TOWER_CROSSBOW_BARRAGE_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_CROSSBOW_BARRAGE_NAME_3"),
                        tt_desc = _("TOWER_CROSSBOW_BARRAGE_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power, {
                action_arg = "eagle",
                image = "special_icons_0029",
                place = 2,
                sounds = { "CrossbowTauntEagle" },
                tt_phrase = _("TOWER_CROSSBOW_FALCONER_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_CROSSBOW_FALCONER_NAME_1"),
                        tt_desc = _("TOWER_CROSSBOW_FALCONER_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_CROSSBOW_FALCONER_NAME_2"),
                        tt_desc = _("TOWER_CROSSBOW_FALCONER_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_CROSSBOW_FALCONER_NAME_3"),
                        tt_desc = _("TOWER_CROSSBOW_FALCONER_DESCRIPTION_3")
                    }
                }
            }),
            templates.sell
        }
    },

    totem = {
        {
            merge(templates.upgrade_power, {
                action_arg = "weakness",
                image = "special_icons_0030",
                place = 1,
                sounds = { "TotemTauntTotemOne" },
                tt_phrase = _("TOWER_TOTEM_WEAKNESS_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_TOTEM_WEAKNESS_NAME_1"),
                        tt_desc = _("TOWER_TOTEM_WEAKNESS_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_TOTEM_WEAKNESS_NAME_2"),
                        tt_desc = _("TOWER_TOTEM_WEAKNESS_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_TOTEM_WEAKNESS_NAME_3"),
                        tt_desc = _("TOWER_TOTEM_WEAKNESS_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power, {
                action_arg = "silence",
                image = "special_icons_0031",
                place = 2,
                sounds = { "TotemTauntTotemTwo" },
                tt_phrase = _("TOWER_TOTEM_SPIRITS_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_TOTEM_SPIRITS_NAME_1"),
                        tt_desc = _("TOWER_TOTEM_SPIRITS_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_TOTEM_SPIRITS_NAME_2"),
                        tt_desc = _("TOWER_TOTEM_SPIRITS_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_TOTEM_SPIRITS_NAME_3"),
                        tt_desc = _("TOWER_TOTEM_SPIRITS_DESCRIPTION_3")
                    }
                }
            }),
            templates.sell
        }
    },

    archer_dwarf = {
        {
            merge(templates.upgrade_power, {
                action_arg = "barrel",
                image = "special_icons_0044",
                place = 1,
                sounds = { "DwarfArcherTaunt1" },
                tt_phrase = _("SPECIAL_DWARF_TOWER1_UPGRADE_1_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("SPECIAL_DWARF_TOWER1_UPGRADE_1_NAME"),
                        tt_desc = _("SPECIAL_DWARF_TOWER1_UPGRADE_1_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("SPECIAL_DWARF_TOWER1_UPGRADE_1_NAME"),
                        tt_desc = _("SPECIAL_DWARF_TOWER1_UPGRADE_1_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("SPECIAL_DWARF_TOWER1_UPGRADE_1_NAME"),
                        tt_desc = _("SPECIAL_DWARF_TOWER1_UPGRADE_1_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power, {
                action_arg = "extra_damage",
                image = "special_icons_0043",
                place = 2,
                sounds = { "DwarfArcherTaunt2" },
                tt_phrase = _("SPECIAL_DWARF_TOWER1_UPGRADE_2_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("SPECIAL_DWARF_TOWER1_UPGRADE_2_NAME"),
                        tt_desc = _("SPECIAL_DWARF_TOWER1_UPGRADE_2_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("SPECIAL_DWARF_TOWER1_UPGRADE_2_NAME"),
                        tt_desc = _("SPECIAL_DWARF_TOWER1_UPGRADE_2_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("SPECIAL_DWARF_TOWER1_UPGRADE_2_NAME"),
                        tt_desc = _("SPECIAL_DWARF_TOWER1_UPGRADE_2_DESCRIPTION_3")
                    }
                }
            }),
            templates.sell
        }
    },

    arcane_wizard = {
        {
            merge(templates.upgrade_power, {
                action_arg = "disintegrate",
                image = "special_icons_0015",
                place = 1,
                sounds = { "MageArcaneDesintegrateTaunt" },
                tt_phrase = _("TOWER_ARCANE_DESINTEGRATE_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_ARCANE_DESINTEGRATE_NAME_1"),
                        tt_desc = _("TOWER_ARCANE_DESINTEGRATE_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_ARCANE_DESINTEGRATE_NAME_2"),
                        tt_desc = _("TOWER_ARCANE_DESINTEGRATE_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_ARCANE_DESINTEGRATE_NAME_3"),
                        tt_desc = _("TOWER_ARCANE_DESINTEGRATE_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power, {
                action_arg = "teleport",
                image = "special_icons_0016",
                place = 2,
                sounds = { "MageArcaneTeleporthTaunt" },
                tt_phrase = _("TOWER_ARCANE_TELEPORT_NOTE_1"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_ARCANE_TELEPORT_NAME_1"),
                        tt_desc = _("TOWER_ARCANE_TELEPORT_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_ARCANE_TELEPORT_NAME_2"),
                        tt_desc = _("TOWER_ARCANE_TELEPORT_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_ARCANE_TELEPORT_NAME_3"),
                        tt_desc = _("TOWER_ARCANE_TELEPORT_DESCRIPTION_3")
                    }
                }
            }),
            templates.sell
        }
    },

    sorcerer = {
        {
            merge(templates.upgrade_power, {
                action_arg = "polymorph",
                image = "special_icons_0001",
                place = 1,
                sounds = { "Sheep" },
                tt_phrase = _("TOWER_SORCERER_POLIMORPH_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_SORCERER_POLIMORPH_NAME_1"),
                        tt_desc = _("TOWER_SORCERER_POLIMORPH_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_SORCERER_POLIMORPH_NAME_2"),
                        tt_desc = _("TOWER_SORCERER_POLIMORPH_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_SORCERER_POLIMORPH_NAME_3"),
                        tt_desc = _("TOWER_SORCERER_POLIMORPH_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power, {
                action_arg = "elemental",
                image = "special_icons_0004",
                place = 2,
                tt_phrase = _("TOWER_SORCERER_ELEMENTAL_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_SORCERER_ELEMENTAL_NAME_1"),
                        tt_desc = _("TOWER_SORCERER_ELEMENTAL_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_SORCERER_ELEMENTAL_NAME_2"),
                        tt_desc = _("TOWER_SORCERER_ELEMENTAL_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_SORCERER_ELEMENTAL_NAME_3"),
                        tt_desc = _("TOWER_SORCERER_ELEMENTAL_DESCRIPTION_3")
                    }
                }
            }),
            templates.rally,
            templates.sell
        }
    },

    archmage = {
        {
            merge(templates.upgrade_power, {
                action_arg = "twister",
                image = "special_icons_0032",
                place = 1,
                sounds = { "ArchmageTauntTwister" },
                tt_phrase = _("TOWER_ARCHMAGE_TWISTER_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_ARCHMAGE_TWISTER_NAME_1"),
                        tt_desc = _("TOWER_ARCHMAGE_TWISTER_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_ARCHMAGE_TWISTER_NAME_2"),
                        tt_desc = _("TOWER_ARCHMAGE_TWISTER_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_ARCHMAGE_TWISTER_NAME_3"),
                        tt_desc = _("TOWER_ARCHMAGE_TWISTER_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power, {
                action_arg = "blast",
                image = "special_icons_0033",
                place = 2,
                sounds = { "ArchmageTauntExplosion" },
                tt_phrase = _("TOWER_ARCHMAGE_CRITICAL_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_ARCHMAGE_CRITICAL_NAME_1"),
                        tt_desc = _("TOWER_ARCHMAGE_CRITICAL_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_ARCHMAGE_CRITICAL_NAME_2"),
                        tt_desc = _("TOWER_ARCHMAGE_CRITICAL_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_ARCHMAGE_CRITICAL_NAME_3"),
                        tt_desc = _("TOWER_ARCHMAGE_CRITICAL_DESCRIPTION_3")
                    }
                }
            }),
            templates.sell
        }
    },

    necromancer = {
        {
            merge(templates.upgrade_power, {
                action_arg = "pestilence",
                image = "special_icons_0035",
                place = 1,
                sounds = { "NecromancerTauntPestilence" },
                tt_phrase = _("TOWER_NECROMANCER_PESTILENCE_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_NECROMANCER_PESTILENCE_NAME_1"),
                        tt_desc = _("TOWER_NECROMANCER_PESTILENCE_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_NECROMANCER_PESTILENCE_NAME_2"),
                        tt_desc = _("TOWER_NECROMANCER_PESTILENCE_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_NECROMANCER_PESTILENCE_NAME_3"),
                        tt_desc = _("TOWER_NECROMANCER_PESTILENCE_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power, {
                action_arg = "rider",
                image = "special_icons_0034",
                place = 2,
                sounds = { "NecromancerTauntDeath_Knight" },
                tt_phrase = _("TOWER_NECROMANCER_RIDER_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_NECROMANCER_RIDER_NAME_1"),
                        tt_desc = _("TOWER_NECROMANCER_RIDER_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_NECROMANCER_RIDER_NAME_2"),
                        tt_desc = _("TOWER_NECROMANCER_RIDER_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_NECROMANCER_RIDER_NAME_3"),
                        tt_desc = _("TOWER_NECROMANCER_RIDER_DESCRIPTION_3")
                    }
                }
            }),
            templates.rally,
            templates.sell
        }
    },

    bfg = {
        {
            merge(templates.upgrade_power, {
                action_arg = "missile",
                image = "special_icons_0017",
                place = 1,
                sounds = { "EngineerBfgMissileTaunt" },
                tt_phrase = _("TOWER_BFG_MISSILE_NOTE_1"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_BFG_MISSILE_NAME_1"),
                        tt_desc = _("TOWER_BFG_MISSILE_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_BFG_MISSILE_NAME_2"),
                        tt_desc = _("TOWER_BFG_MISSILE_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_BFG_MISSILE_NAME_3"),
                        tt_desc = _("TOWER_BFG_MISSILE_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power, {
                action_arg = "cluster",
                image = "special_icons_0018",
                place = 2,
                sounds = { "EngineerBfgClusterTaunt" },
                tt_phrase = _("TOWER_BFG_CLUSTER_NOTE_1"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_BFG_CLUSTER_NAME_1"),
                        tt_desc = _("TOWER_BFG_CLUSTER_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_BFG_CLUSTER_NAME_2"),
                        tt_desc = _("TOWER_BFG_CLUSTER_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_BFG_CLUSTER_NAME_3"),
                        tt_desc = _("TOWER_BFG_CLUSTER_DESCRIPTION_3")
                    }
                }
            }),
            templates.sell
        }
    },

    tesla = {
        {
            merge(templates.upgrade_power, {
                    action_arg = "bolt",
                    image = "special_icons_0011",
                    place = 1,
                    sounds = { "EngineerTeslaChargedBoltTaunt" },
                    tt_phrase = _("TOWER_TESLA_CHARGED_BOLT_NOTE"),
                    tt_list =
                    {
                        {
                            tt_title = _("TOWER_TESLA_CHARGED_BOLT_NAME_1"),
                            tt_desc = _("TOWER_TESLA_CHARGED_BOLT_DESCRIPTION_1")
                        },
                        {
                            tt_title = _("TOWER_TESLA_CHARGED_BOLT_NAME_2"),
                            tt_desc = _("TOWER_TESLA_CHARGED_BOLT_DESCRIPTION_2")
                        },
                        {
                            tt_title = _("TOWER_TESLA_CHARGED_BOLT_NAME_3"),
                            tt_desc = _("TOWER_TESLA_CHARGED_BOLT_DESCRIPTION_3")
                        }
                    }
                },
                {
                    action_arg = "overcharge",
                    image = "special_icons_0010",
                    place = 2,
                    sounds = { "EngineerTeslaOverchargeTaunt" },
                    tt_phrase = _("TOWER_TESLA_OVERCHARGE_NOTE"),
                    tt_list =
                    {
                        {
                            tt_title = _("TOWER_TESLA_OVERCHARGE_NAME_1"),
                            tt_desc = _("TOWER_TESLA_OVERCHARGE_DESCRIPTION_1")
                        },
                        {
                            tt_title = _("TOWER_TESLA_OVERCHARGE_NAME_2"),
                            tt_desc = _("TOWER_TESLA_OVERCHARGE_DESCRIPTION_2")
                        },
                        {
                            tt_title = _("TOWER_TESLA_OVERCHARGE_NAME_3"),
                            tt_desc = _("TOWER_TESLA_OVERCHARGE_DESCRIPTION_3")
                        }
                    }
                }),
            templates.sell
        }
    },

    dwaarp = {
        {
            merge(templates.upgrade_power, {
                action_arg = "drill",
                image = "special_icons_0036",
                place = 1,
                sounds = { "EarthquakeTauntDrill" },
                tt_phrase = _("TOWER_DWAARP_DRILL_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_DWAARP_DRILL_NAME_1"),
                        tt_desc = _("TOWER_DWAARP_DRILL_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_DWAARP_DRILL_NAME_2"),
                        tt_desc = _("TOWER_DWAARP_DRILL_DESCRIPTION_2_NOFMT")
                    },
                    {
                        tt_title = _("TOWER_DWAARP_DRILL_NAME_3"),
                        tt_desc = _("TOWER_DWAARP_DRILL_DESCRIPTION_3_NOFMT")
                    }
                }
            }),
            merge(templates.upgrade_power, {
                action_arg = "lava",
                image = "special_icons_0037",
                place = 2,
                sounds = { "EarthquakeTauntScorched" },
                tt_phrase = _("TOWER_DWAARP_BLAST_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_DWAARP_BLAST_NAME_1"),
                        tt_desc = _("TOWER_DWAARP_BLAST_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_DWAARP_BLAST_NAME_2"),
                        tt_desc = _("TOWER_DWAARP_BLAST_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_DWAARP_BLAST_NAME_3"),
                        tt_desc = _("TOWER_DWAARP_BLAST_DESCRIPTION_3")
                    }
                }
            }),
            templates.sell
        }
    },

    mecha = {
        {
            merge(templates.upgrade_power, {
                action_arg = "missile",
                image = "special_icons_0038",
                place = 1,
                sounds = { "MechTauntMissile" },
                tt_phrase = _("TOWER_MECH_MISSILE_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_MECH_MISSILE_NAME_1"),
                        tt_desc = _("TOWER_MECH_MISSILE_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_MECH_MISSILE_NAME_2"),
                        tt_desc = _("TOWER_MECH_MISSILE_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_MECH_MISSILE_NAME_3"),
                        tt_desc = _("TOWER_MECH_MISSILE_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power, {
                action_arg = "oil",
                image = "special_icons_0039",
                place = 2,
                sounds = { "MechTauntSlow" },
                tt_phrase = _("TOWER_MECH_WASTE_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_MECH_WASTE_NAME_1"),
                        tt_desc = _("TOWER_MECH_WASTE_DESCRIPTION_1_NOFMT")
                    },
                    {
                        tt_title = _("TOWER_MECH_WASTE_NAME_2"),
                        tt_desc = _("TOWER_MECH_WASTE_DESCRIPTION_2_NOFMT")
                    },
                    {
                        tt_title = _("TOWER_MECH_WASTE_NAME_3"),
                        tt_desc = _("TOWER_MECH_WASTE_DESCRIPTION_3_NOFMT")
                    }
                }
            }),
            templates.rally,
            templates.sell
        }
    },

    paladin = {
        {
            merge(templates.upgrade_power, {
                action_arg = "healing",
                image = "special_icons_0007",
                place = 6,
                sounds = { "BarrackPaladinHealingTaunt" },
                tt_phrase = _("TOWER_PALADINS_HEALING_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_PALADINS_HEALING_NAME_1"),
                        tt_desc = _("TOWER_PALADINS_HEALING_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_PALADINS_HEALING_NAME_2"),
                        tt_desc = _("TOWER_PALADINS_HEALING_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_PALADINS_HEALING_NAME_3"),
                        tt_desc = _("TOWER_PALADINS_HEALING_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power, {
                action_arg = "shield",
                image = "special_icons_0009",
                place = 5,
                sounds = { "BarrackPaladinShieldTaunt" },
                tt_phrase = _("TOWER_PALADINS_SHIELD_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_PALADINS_SHIELD_NAME_1"),
                        tt_desc = _("TOWER_PALADINS_SHIELD_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_PALADINS_SHIELD_NAME_2"),
                        tt_desc = _("TOWER_PALADINS_SHIELD_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_PALADINS_SHIELD_NAME_3"),
                        tt_desc = _("TOWER_PALADINS_SHIELD_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power, {
                action_arg = "holystrike",
                image = "special_icons_0006",
                place = 7,
                sounds = { "BarrackPaladinHolyStrikeTaunt" },
                tt_phrase = _("TOWER_PALADINS_HOLY_STRIKE_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_PALADINS_HOLY_STRIKE_NAME_1"),
                        tt_desc = _("TOWER_PALADINS_HOLY_STRIKE_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_PALADINS_HOLY_STRIKE_NAME_2"),
                        tt_desc = _("TOWER_PALADINS_HOLY_STRIKE_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_PALADINS_HOLY_STRIKE_NAME_3"),
                        tt_desc = _("TOWER_PALADINS_HOLY_STRIKE_DESCRIPTION_3")
                    }
                }
            }),
            templates.rally,
            templates.sell
        }
    },

    barbarian = {
        {
            merge(templates.upgrade_power, {
                action_arg = "dual",
                image = "special_icons_0012",
                place = 6,
                sounds = { "BarrackBarbarianDoubleAxesTaunt" },
                tt_phrase = _("TOWER_BARBARIANS_DOUBLE_AXE_NOTE_1"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_BARBARIANS_DOUBLE_AXE_NAME_1"),
                        tt_desc = _("TOWER_BARBARIANS_DOUBLE_AXE_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_BARBARIANS_DOUBLE_AXE_NAME_2"),
                        tt_desc = _("TOWER_BARBARIANS_DOUBLE_AXE_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_BARBARIANS_DOUBLE_AXE_NAME_3"),
                        tt_desc = _("TOWER_BARBARIANS_DOUBLE_AXE_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power, {
                action_arg = "twister",
                image = "special_icons_0013",
                place = 5,
                sounds = { "BarrackBarbarianTwisterTaunt" },
                tt_phrase = _("TOWER_BARBARIANS_TWISTER_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_BARBARIANS_TWISTER_NAME_1"),
                        tt_desc = _("TOWER_BARBARIANS_TWISTER_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_BARBARIANS_TWISTER_NAME_2"),
                        tt_desc = _("TOWER_BARBARIANS_TWISTER_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_BARBARIANS_TWISTER_NAME_3"),
                        tt_desc = _("TOWER_BARBARIANS_TWISTER_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power, {
                action_arg = "throwing",
                image = "special_icons_0019",
                place = 7,
                sounds = { "BarrackBarbarianThrowingAxesTaunt" },
                tt_phrase = _("TOWER_BARBARIANS_THROWING_AXES_NOTE_1"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_BARBARIANS_THROWING_AXES_NAME_1"),
                        tt_desc = _("TOWER_BARBARIANS_THROWING_AXES_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_BARBARIANS_THROWING_AXES_NAME_2"),
                        tt_desc = _("TOWER_BARBARIANS_THROWING_AXES_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_BARBARIANS_THROWING_AXES_NAME_3"),
                        tt_desc = _("TOWER_BARBARIANS_THROWING_AXES_DESCRIPTION_3")
                    }
                }
            }),
            templates.rally,
            templates.sell
        }
    },

    holder_elf = {
        {
            merge(templates.upgrade_power, {
                action_arg = "tower_elf",
                image = "main_icons_0015",
                place = 5,
                tt_title = _("SPECIAL_ELF_REPAIR_NAME"),
                tt_desc = _("SPECIAL_ELF_REPAIR_DESCRIPTION")
            }),
            templates.sell
        }
    },

    elf = {
        {
            merge(templates.upgrade_power, {
                action_arg = "bleed",
                image = "special_icons_0014",
                place = 7,
                sounds = { "ElfBleed" },
                tt_phrase = _("你会流血吗？"),
                tt_list =
                {
                    {
                        tt_title = _("血翎"),
                        tt_desc = _("使精灵的射击附带流血效果，在三秒内造成15点伤害")
                    },
                    {
                        tt_title = _("血翎Ⅱ"),
                        tt_desc = _("使精灵的射击附带流血效果，在三秒内造成30点伤害")
                    },
                    {
                        tt_title = _("血翎Ⅲ"),
                        tt_desc = _("使精灵的射击附带流血效果，在三秒内造成45点伤害")
                    }
                }
            }),
            merge(templates.upgrade_power, {
                action_arg = "cripple",
                image = "special_icons_0024",
                place = 6,
                sounds = { "ElfCripple" },
                tt_phrase = _("他们走不远的……"),
                tt_list =
                {
                    {
                        tt_title = _("残废"),
                        tt_desc = _("游侠有30%几率射出精灵箭矢，造成70点真实伤害与40%的减速，持续2.5秒。")
                    },
                    {
                        tt_title = _("残废Ⅱ"),
                        tt_desc = _("游侠有40%几率射出精灵箭矢，造成85点真实伤害与40%的减速，持续2.5秒。")
                    },
                    {
                        tt_title = _("残废Ⅲ"),
                        tt_desc = _("游侠有50%几率射出精灵箭矢，造成100点真实伤害与40%的减速，持续2.5秒。")
                    }
                }
            }),
            merge(templates.buy_soldier, {
                action_arg = "soldier_elf",
                image = "main_icons_0016",
                tt_title = _("SPECIAL_ELF_NAME"),
                tt_desc = _("SPECIAL_ELF_DESCRIPTION")
            }),
            templates.rally,
            templates.sell
        }
    },

    templar = {
        {
            merge(templates.upgrade_power, {
                action_arg = "holygrail",
                image = "special_icons_0025",
                place = 7,
                sounds = { "TemplarTauntTauntOne" },
                tt_phrase = _("TOWER_TEMPLAR_HOLY_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_TEMPLAR_HOLY_NAME_1"),
                        tt_desc = _("TOWER_TEMPLAR_HOLY_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_TEMPLAR_HOLY_NAME_2"),
                        tt_desc = _("TOWER_TEMPLAR_HOLY_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_TEMPLAR_HOLY_NAME_3"),
                        tt_desc = _("TOWER_TEMPLAR_HOLY_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power, {
                action_arg = "extralife",
                image = "special_icons_0027",
                place = 6,
                sounds = { "TemplarTauntTauntTwo" },
                tt_phrase = _("TOWER_TEMPLAR_TOUGHNESS_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_TEMPLAR_TOUGHNESS_NAME_1"),
                        tt_desc = _("TOWER_TEMPLAR_TOUGHNESS_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_TEMPLAR_TOUGHNESS_NAME_2"),
                        tt_desc = _("TOWER_TEMPLAR_TOUGHNESS_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_TEMPLAR_TOUGHNESS_NAME_3"),
                        tt_desc = _("TOWER_TEMPLAR_TOUGHNESS_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power, {
                action_arg = "blood",
                image = "special_icons_0026",
                place = 5,
                sounds = { "TemplarTauntThree" },
                tt_phrase = _("TOWER_TEMPLAR_ARTERIAL_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_TEMPLAR_ARTERIAL_NAME_1"),
                        tt_desc = _("TOWER_TEMPLAR_ARTERIAL_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_TEMPLAR_ARTERIAL_NAME_2"),
                        tt_desc = _("TOWER_TEMPLAR_ARTERIAL_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_TEMPLAR_ARTERIAL_NAME_3"),
                        tt_desc = _("TOWER_TEMPLAR_ARTERIAL_DESCRIPTION_3")
                    }
                }
            }),
            templates.rally,
            templates.sell
        }
    },

    assassin = {
        {
            merge(templates.upgrade_power, {
                action_arg = "sneak",
                image = "special_icons_0024",
                place = 6,
                sounds = { "AssassinTauntSneak" },
                tt_phrase = _("TOWER_ASSASSIN_SNEAK_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_ASSASSIN_SNEAK_NAME_1"),
                        tt_desc = _("TOWER_ASSASSIN_SNEAK_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_ASSASSIN_SNEAK_NAME_2"),
                        tt_desc = _("TOWER_ASSASSIN_SNEAK_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_ASSASSIN_SNEAK_NAME_3"),
                        tt_desc = _("TOWER_ASSASSIN_SNEAK_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power, {
                action_arg = "pickpocket",
                image = "special_icons_0022",
                place = 7,
                sounds = { "AssassinTauntGold" },
                tt_phrase = _("TOWER_ASSASSIN_PICK_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_ASSASSIN_PICK_NAME_1"),
                        tt_desc = _("TOWER_ASSASSIN_PICK_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_ASSASSIN_PICK_NAME_2"),
                        tt_desc = _("TOWER_ASSASSIN_PICK_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_ASSASSIN_PICK_NAME_3"),
                        tt_desc = _("TOWER_ASSASSIN_PICK_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power, {
                action_arg = "counter",
                image = "special_icons_0023",
                place = 5,
                sounds = { "AssassinTauntCounter" },
                tt_phrase = _("TOWER_ASSASSIN_COUNTER_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_ASSASSIN_COUNTER_NAME_1"),
                        tt_desc = _("TOWER_ASSASSIN_COUNTER_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_ASSASSIN_COUNTER_NAME_2"),
                        tt_desc = _("TOWER_ASSASSIN_COUNTER_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_ASSASSIN_COUNTER_NAME_3"),
                        tt_desc = _("TOWER_ASSASSIN_COUNTER_DESCRIPTION_3")
                    }
                }
            }),
            templates.rally,
            templates.sell
        }
    },

    barrack_dwarf = {
        {
            merge(templates.upgrade_power, {
                action_arg = "hammer",
                image = "special_icons_0040",
                place = 5,
                sounds = { "DwarfTaunt" },
                tt_phrase = _("SPECIAL_DWARF_BARRACKS_UPGRADE_1_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("SPECIAL_DWARF_BARRACKS_UPGRADE_1_NAME_1"),
                        tt_desc = _("SPECIAL_DWARF_BARRACKS_UPGRADE_1_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("SPECIAL_DWARF_BARRACKS_UPGRADE_1_NAME_2"),
                        tt_desc = _("SPECIAL_DWARF_BARRACKS_UPGRADE_1_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("SPECIAL_DWARF_BARRACKS_UPGRADE_1_NAME_3"),
                        tt_desc = _("SPECIAL_DWARF_BARRACKS_UPGRADE_1_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power, {
                action_arg = "armor",
                image = "special_icons_0041",
                place = 6,
                sounds = { "DwarfTaunt" },
                tt_phrase = _("SPECIAL_DWARF_BARRACKS_UPGRADE_2_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("SPECIAL_DWARF_BARRACKS_UPGRADE_2_NAME_1"),
                        tt_desc = _("SPECIAL_DWARF_BARRACKS_UPGRADE_2_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("SPECIAL_DWARF_BARRACKS_UPGRADE_2_NAME_2"),
                        tt_desc = _("SPECIAL_DWARF_BARRACKS_UPGRADE_2_DESCRIPTION_2")
                    }
                }
            }),
            merge(templates.upgrade_power, {
                action_arg = "beer",
                image = "special_icons_0042",
                place = 7,
                sounds = { "DwarfTaunt" },
                tt_phrase = _("SPECIAL_DWARF_BARRACKS_UPGRADE_3_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("SPECIAL_DWARF_BARRACKS_UPGRADE_3_NAME_1"),
                        tt_desc = _("SPECIAL_DWARF_BARRACKS_UPGRADE_3_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("SPECIAL_DWARF_BARRACKS_UPGRADE_3_NAME_2"),
                        tt_desc = _("SPECIAL_DWARF_BARRACKS_UPGRADE_3_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("SPECIAL_DWARF_BARRACKS_UPGRADE_3_NAME_3"),
                        tt_desc = _("SPECIAL_DWARF_BARRACKS_UPGRADE_3_DESCRIPTION_3")
                    }
                }
            }),
            templates.rally,
            templates.sell
        }
    },

    mercenaries_amazonas = {
        {
            merge(templates.upgrade_power, {
                action_arg = "valkyrie",
                image = "special_icons_0014",
                place = 7,
                sounds = { "AmazonTaunt" },
                tt_phrase = _("解脱敌人是一种荣耀。"),
                tt_list =
                {
                    {
                        tt_title = _("武神"),
                        tt_desc = _(
                            "女战士提升50点生命与10点攻击力，且每杀死一个敌人，提升2点攻击力、3点生命和1点移速，最高提升150点生命，60点攻击与50点移速，死亡后移除。")
                    }
                }
            }),
            merge(templates.upgrade_power, {
                action_arg = "whirlwind",
                image = "special_icons_0013",
                place = 6,
                sounds = { "AmazonTaunt" },
                tt_phrase = _("横扫六合！"),
                tt_list =
                {
                    {
                        tt_title = _("旋风"),
                        tt_desc = _("使女战士有30%几率释放旋风斩，造成24-46点范围伤害")
                    }
                }
            }),
            merge(templates.upgrade_power, {
                action_arg = "soldier_amazona",
                action = "tw_buy_soldier",
                halo = "glow_ico_main",
                image = "main_icons_0033",
                place = 5,
                tt_title = _("SPECIAL_AMAZONAS_WARRIOR_NAME"),
                tt_desc = _("SPECIAL_AMAZONAS_WARRIOR_DESCRIPTION")
            }),
            templates.rally,
            templates.sell
        }
    },

    holder_sasquash = {
        {
            {
                halo = "glow_ico_main",
                action = "tw_none",
                image = "main_icons_0017",
                place = 5,
                tt_title = _("SPECIAL_ELF_REPAIR_NAME"),
                tt_desc = _("SPECIAL_ELF_REPAIR_DESCRIPTION")
            }
        }
    },

    sasquash = {
        {
            merge(templates.buy_soldier, {
                action_arg = "soldier_sasquash",
                image = "main_icons_0017",
                place = 5,
                tt_title = _("SPECIAL_SASQUASH_NAME"),
                tt_desc = _("SPECIAL_SASQUASH_DESCRIPTION")
            }),
            templates.rally
        }
    },

    sunray = {
        {
            merge(templates.upgrade_power, {
                no_upgrade_lights = true,
                image = "main_icons_0018",
                action_arg = "ray",
                place = 5,
                sounds = { "MageSorcererAshesToAshesTaunt" },
                tt_phrase = _("SPECIAL_SUNRAY_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("SPECIAL_SUNRAY_UPGRADE_NAME"),
                        tt_desc = _("SPECIAL_SUNRAY_UPGRADE_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("SPECIAL_SUNRAY_UPGRADE_NAME"),
                        tt_desc = _("SPECIAL_SUNRAY_UPGRADE_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("SPECIAL_SUNRAY_UPGRADE_NAME"),
                        tt_desc = _("SPECIAL_SUNRAY_UPGRADE_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("SPECIAL_SUNRAY_UPGRADE_NAME"),
                        tt_desc = _("SPECIAL_SUNRAY_UPGRADE_DESCRIPTION_1")
                    }
                }
            }),
            merge(templates.upgrade_power, {
                image = "main_icons_0019",
                action_arg = "manual",
                place = 6,
                sounds = { "MageSorcererAshesToAshesTaunt" },
                tt_phrase = _("日光啊，听我号令！"),
                tt_list =
                {
                    {
                        tt_title = _("切换手动模式"),
                        tt_desc = _(
                            "手动模式无射程限制，且攻击附带最高额外200点伤害的10%斩杀效果。只有对单时，日光才能发挥全部威力。")
                    }
                }
            }),
            merge(templates.upgrade_power, {
                image = "main_icons_0020",
                action_arg = "auto",
                place = 7,
                sounds = { "MageSorcererAshesToAshesTaunt" },
                tt_phrase = _("日光啊，瓦解它们！"),
                tt_list =
                {
                    {
                        tt_title = _("切换自动模式"),
                        tt_desc = _(
                            "自动模式射程有限，且充能速度加快40%，伤害下降25%。只有对单时，日光才能发挥全部威力。")
                    }
                }
            }),
            templates.point,
            templates.sell
        }
    },

    mercenaries_desert = {
        {
            merge(templates.buy_soldier, {
                action_arg = "soldier_djinn",
                image = "main_icons_0030",
                place = 5,
                tt_title = _("SPECIAL_DJINN_NAME"),
                tt_desc = _("SPECIAL_DJINN_DESCRIPTION")
            }),
            merge(templates.upgrade_power, {
                action_arg = "djspell",
                image = "special_icons_0025",
                place = 7,
                sounds = { "GenieTaunt" },
                tt_phrase = _("TOWER_BARRACK_MERCENARIES_DJSPELL_NOTE_1"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_BARRACK_MERCENARIES_DJSPELL_NAME_1"),
                        tt_desc = _("TOWER_BARRACK_MERCENARIES_DJSPELL_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_BARRACK_MERCENARIES_DJSPELL_NAME_2"),
                        tt_desc = _("TOWER_BARRACK_MERCENARIES_DJSPELL_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_BARRACK_MERCENARIES_DJSPELL_NAME_3"),
                        tt_desc = _("TOWER_BARRACK_MERCENARIES_DJSPELL_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power, {
                action_arg = "djshock",
                image = "special_icons_0016",
                place = 6,
                sounds = { "GenieTaunt" },
                tt_phrase = _("TOWER_BARRACK_MERCENARIES_DJSHOCK_NOTE_1"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_BARRACK_MERCENARIES_DJSHOCK_NAME_1"),
                        tt_desc = _("TOWER_BARRACK_MERCENARIES_DJSHOCK_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_BARRACK_MERCENARIES_DJSHOCK_NAME_2"),
                        tt_desc = _("TOWER_BARRACK_MERCENARIES_DJSHOCK_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_BARRACK_MERCENARIES_DJSHOCK_NAME_3"),
                        tt_desc = _("TOWER_BARRACK_MERCENARIES_DJSHOCK_DESCRIPTION_3")
                    }
                }
            }),
            templates.rally,
            templates.sell
        }
    },

    mercenaries_pirates = {
        {
            merge(templates.upgrade_power, {
                action_arg = "bigbomb",
                image = "special_icons_0018",
                place = 6,
                sounds = { "PiratesTaunt" },
                tt_phrase = _("TOWER_BARRACK_PIRATES_BIGBOMB_NOTE_1"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_BARRACK_PIRATES_BIGBOMB_NAME_1"),
                        tt_desc = _("TOWER_BARRACK_PIRATES_BIGBOMB_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_BARRACK_PIRATES_BIGBOMB_NAME_2"),
                        tt_desc = _("TOWER_BARRACK_PIRATES_BIGBOMB_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_BARRACK_PIRATES_BIGBOMB_NAME_3"),
                        tt_desc = _("TOWER_BARRACK_PIRATES_BIGBOMB_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.buy_soldier, {
                action_arg = "soldier_pirate_flamer",
                image = "main_icons_0032",
                place = 5,
                tt_title = _("SPECIAL_PIRATE_FLAMER_NAME"),
                tt_desc = _("SPECIAL_PIRATE_FLAMER_DESCRIPTION")
            }),
            merge(templates.upgrade_power, {
                action_arg = "quickup",
                image = "special_icons_0025",
                place = 7,
                sounds = { "PiratesTaunt" },
                tt_phrase = _("TOWER_BARRACK_PIRATES_QUICKUP_NOTE_1"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_BARRACK_PIRATES_QUICKUP_NAME_1"),
                        tt_desc = _("TOWER_BARRACK_PIRATES_QUICKUP_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_BARRACK_PIRATES_QUICKUP_NAME_2"),
                        tt_desc = _("TOWER_BARRACK_PIRATES_QUICKUP_DESCRIPTION_2")
                    }
                }
            }),
            templates.rally,
            templates.sell
        }
    },

    pirate_watchtower = {
        {
            merge(templates.upgrade_power, {
                action_arg = "reduce_cooldown",
                image = "special_icons_0045",
                place = 1,
                sounds = { "PirateTowerTaunt1" },
                tt_phrase = _("SPECIAL_PIRATES_WATCHTOWER_UPGRADE_1_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("SPECIAL_PIRATES_WATCHTOWER_UPGRADE_1_NAME"),
                        tt_desc = _("SPECIAL_PIRATES_WATCHTOWER_UPGRADE_1_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("SPECIAL_PIRATES_WATCHTOWER_UPGRADE_1_NAME"),
                        tt_desc = _("SPECIAL_PIRATES_WATCHTOWER_UPGRADE_1_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("SPECIAL_PIRATES_WATCHTOWER_UPGRADE_1_NAME"),
                        tt_desc = _("SPECIAL_PIRATES_WATCHTOWER_UPGRADE_1_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power, {
                action_arg = "parrot",
                image = "special_icons_0046",
                place = 2,
                sounds = { "PirateTowerTaunt2" },
                tt_phrase = _("SPECIAL_PIRATES_WATCHTOWER_UPGRADE_2_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("SPECIAL_PIRATES_WATCHTOWER_UPGRADE_2_NAME"),
                        tt_desc = _("SPECIAL_PIRATES_WATCHTOWER_UPGRADE_2_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("SPECIAL_PIRATES_WATCHTOWER_UPGRADE_2_NAME"),
                        tt_desc = _("SPECIAL_PIRATES_WATCHTOWER_UPGRADE_2_DESCRIPTION_2")
                    }
                }
            }),
            templates.sell
        }
    },

    holder_neptune = {
        {
            merge(templates.upgrade_power, {
                action_arg = "tower_neptune",
                image = "main_icons_0015",
                place = 5,
                tt_title = _("SPECIAL_NEPTUNE_BROKEN_TOWER_FIX_NAME"),
                tt_desc = _("SPECIAL_NEPTUNE_BROKEN_TOWER_FIX_DESCRIPTION")
            })
        }
    },

    neptune = {
        {
            merge(templates.upgrade_power, {
                action_arg = "ray",
                image = "special_icons_0047",
                place = 5,
                tt_list =
                {
                    {
                        tt_title = _("SPECIAL_NEPTUNE_TOWER_UPGRADE_NAME"),
                        tt_desc = _("SPECIAL_NEPTUNE_TOWER_UPGRADE_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("SPECIAL_NEPTUNE_TOWER_UPGRADE_NAME"),
                        tt_desc = _("SPECIAL_NEPTUNE_TOWER_UPGRADE_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("SPECIAL_NEPTUNE_TOWER_UPGRADE_NAME"),
                        tt_desc = _("SPECIAL_NEPTUNE_TOWER_UPGRADE_DESCRIPTION_1")
                    }
                }
            }),
            templates.point
        }
    },

    frankenstein = {
        {
            merge(templates.upgrade_power, {
                action_arg = "lightning",
                image = "special_icons_0048",
                place = 1,
                sounds = { "HWFrankensteinUpgradeLightning" },
                tt_phrase = _("SPECIAL_TOWER_FRANKENSTEIN_UPGRADE_1_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("SPECIAL_TOWER_FRANKENSTEIN_UPGRADE_1_NAME"),
                        tt_desc = _("SPECIAL_TOWER_FRANKENSTEIN_UPGRADE_1_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("SPECIAL_TOWER_FRANKENSTEIN_UPGRADE_1_NAME"),
                        tt_desc = _("SPECIAL_TOWER_FRANKENSTEIN_UPGRADE_1_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("SPECIAL_TOWER_FRANKENSTEIN_UPGRADE_1_NAME"),
                        tt_desc = _("SPECIAL_TOWER_FRANKENSTEIN_UPGRADE_1_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power, {
                action_arg = "frankie",
                image = "special_icons_0049",
                place = 2,
                sounds = { "HWFrankensteinUpgradeFrankenstein" },
                tt_phrase = _("SPECIAL_TOWER_FRANKENSTEIN_UPGRADE_2_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("SPECIAL_TOWER_FRANKENSTEIN_UPGRADE_2_NAME"),
                        tt_desc = _("SPECIAL_TOWER_FRANKENSTEIN_UPGRADE_2_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("SPECIAL_TOWER_FRANKENSTEIN_UPGRADE_2_NAME"),
                        tt_desc = _("SPECIAL_TOWER_FRANKENSTEIN_UPGRADE_2_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("SPECIAL_TOWER_FRANKENSTEIN_UPGRADE_2_NAME"),
                        tt_desc = _("SPECIAL_TOWER_FRANKENSTEIN_UPGRADE_2_DESCRIPTION_3")
                    }
                }
            }),
            templates.rally,
            templates.sell
        }
    },

    --[[
        三代
    --]]

    blade = {
        {
            merge(templates.upgrade_power3, {
                action_arg = "perfect_parry",
                image = "kr3_special_icons_0105",
                place = 6,
                sounds = { "ElvesBarrackBladesingerPerfectParryTaunt" },
                tt_phrase = _("TOWER_BLADE_PERFECT_PARRY_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_BLADE_PERFECT_PARRY_NAME_1"),
                        tt_desc = _("TOWER_BLADE_PERFECT_PARRY_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_BLADE_PERFECT_PARRY_NAME_2"),
                        tt_desc = _("TOWER_BLADE_PERFECT_PARRY_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_BLADE_PERFECT_PARRY_NAME_3"),
                        tt_desc = _("TOWER_BLADE_PERFECT_PARRY_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power3, {
                action_arg = "blade_dance",
                image = "kr3_special_icons_0104",
                place = 7,
                sounds = { "ElvesBarrackBladesingerBladeDanceTaunt" },
                tt_phrase = _("TOWER_BLADE_BLADE_DANCE_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_BLADE_BLADE_DANCE_NAME_1"),
                        tt_desc = _("TOWER_BLADE_BLADE_DANCE_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_BLADE_BLADE_DANCE_NAME_2"),
                        tt_desc = _("TOWER_BLADE_BLADE_DANCE_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_BLADE_BLADE_DANCE_NAME_3"),
                        tt_desc = _("TOWER_BLADE_BLADE_DANCE_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power3, {
                action_arg = "swirling",
                image = "kr3_special_icons_0106",
                place = 5,
                sounds = { "ElvesBarrackBladesingerSwirlingEdge" },
                tt_phrase = _("TOWER_BLADE_SWIRLING_EDGE_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_BLADE_SWIRLING_EDGE_NAME_1"),
                        tt_desc = _("TOWER_BLADE_SWIRLING_EDGE_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_BLADE_SWIRLING_EDGE_NAME_2"),
                        tt_desc = _("TOWER_BLADE_SWIRLING_EDGE_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_BLADE_SWIRLING_EDGE_NAME_3"),
                        tt_desc = _("TOWER_BLADE_SWIRLING_EDGE_DESCRIPTION_3")
                    }
                }
            }),
            templates.rally,
            templates.sell
        }
    },

    forest = {
        {
            merge(templates.upgrade_power3, {
                action_arg = "circle",
                image = "kr3_special_icons_0107",
                place = 6,
                sounds = { "ElvesBarrackForestKeeperCircleOfLifeTaunt" },
                tt_phrase = _("TOWER_FOREST_KEEPERS_CIRCLE_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_FOREST_KEEPERS_CIRCLE_NAME_1"),
                        tt_desc = _("TOWER_FOREST_KEEPERS_CIRCLE_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_FOREST_KEEPERS_CIRCLE_NAME_2"),
                        tt_desc = _("TOWER_FOREST_KEEPERS_CIRCLE_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_FOREST_KEEPERS_CIRCLE_NAME_3"),
                        tt_desc = _("TOWER_FOREST_KEEPERS_CIRCLE_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power3, {
                action_arg = "eerie",
                image = "kr3_special_icons_0109",
                place = 5,
                sounds = { "ElvesBarrackForestKeeperEerieTaunt" },
                tt_phrase = _("TOWER_FOREST_KEEPERS_EERIE_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_FOREST_KEEPERS_EERIE_NAME_1"),
                        tt_desc = _("TOWER_FOREST_KEEPERS_EERIE_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_FOREST_KEEPERS_EERIE_NAME_2"),
                        tt_desc = _("TOWER_FOREST_KEEPERS_EERIE_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_FOREST_KEEPERS_EERIE_NAME_3"),
                        tt_desc = _("TOWER_FOREST_KEEPERS_EERIE_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power3, {
                action_arg = "oak",
                image = "kr3_special_icons_0110",
                place = 7,
                sounds = { "ElvesBarrackForestKeeperOakSpearTaunt" },
                tt_phrase = _("TOWER_FOREST_KEEPERS_OAK_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_FOREST_KEEPERS_OAK_NAME_1"),
                        tt_desc = _("TOWER_FOREST_KEEPERS_OAK_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_FOREST_KEEPERS_OAK_NAME_2"),
                        tt_desc = _("TOWER_FOREST_KEEPERS_OAK_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_FOREST_KEEPERS_OAK_NAME_3"),
                        tt_desc = _("TOWER_FOREST_KEEPERS_OAK_DESCRIPTION_3")
                    }
                }
            }),
            templates.rally,
            templates.sell
        }
    },

    druid = {
        {
            merge(templates.upgrade_power3, {
                action_arg = "sylvan",
                image = "kr3_special_icons_0112",
                place = 1,
                sounds = { "ElvesRockHengeSylvanCurseTaunt" },
                tt_phrase = _("TOWER_STONE_DRUID_SYLVAN_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_STONE_DRUID_SYLVAN_NAME_1"),
                        tt_desc = _("TOWER_STONE_DRUID_SYLVAN_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_STONE_DRUID_SYLVAN_NAME_2"),
                        tt_desc = _("TOWER_STONE_DRUID_SYLVAN_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_STONE_DRUID_SYLVAN_NAME_3"),
                        tt_desc = _("TOWER_STONE_DRUID_SYLVAN_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power3, {
                action_arg = "nature",
                image = "kr3_special_icons_0111",
                place = 2,
                sounds = { "SoldierDruidBearRallyChange" },
                tt_phrase = _("TOWER_STONE_DRUID_NATURES_FRIEND_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_STONE_DRUID_NATURES_FRIEND_NAME_1"),
                        tt_desc = _("TOWER_STONE_DRUID_NATURES_FRIEND_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_STONE_DRUID_NATURES_FRIEND_NAME_2"),
                        tt_desc = _("TOWER_STONE_DRUID_NATURES_FRIEND_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_STONE_DRUID_NATURES_FRIEND_NAME_3"),
                        tt_desc = _("TOWER_STONE_DRUID_NATURES_FRIEND_DESCRIPTION_3")
                    }
                }
            }),
            templates.rally,
            templates.sell
        }
    },

    entwood = {
        {
            merge(templates.upgrade_power3, {
                action_arg = "clobber",
                image = "kr3_special_icons_0113",
                place = 2,
                sounds = { "ElvesRockEntwoodClobberingTaunt" },
                tt_phrase = _("TOWER_ENTWOOD_CLOBBER_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_ENTWOOD_CLOBBER_NAME_1"),
                        tt_desc = _("TOWER_ENTWOOD_CLOBBER_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_ENTWOOD_CLOBBER_NAME_2"),
                        tt_desc = _("TOWER_ENTWOOD_CLOBBER_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_ENTWOOD_CLOBBER_NAME_3"),
                        tt_desc = _("TOWER_ENTWOOD_CLOBBER_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power3, {
                action_arg = "fiery_nuts",
                image = "kr3_special_icons_0114",
                place = 1,
                sounds = { "ElvesRockEntwoodFieryNutsTaunt" },
                tt_phrase = _("TOWER_ENTWOOD_FIERY_NUTS_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_ENTWOOD_FIERY_NUTS_NAME_1"),
                        tt_desc = _("TOWER_ENTWOOD_FIERY_NUTS_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_ENTWOOD_FIERY_NUTS_NAME_2"),
                        tt_desc = _("TOWER_ENTWOOD_FIERY_NUTS_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_ENTWOOD_FIERY_NUTS_NAME_3"),
                        tt_desc = _("TOWER_ENTWOOD_FIERY_NUTS_DESCRIPTION_3")
                    }
                }
            }),
            templates.sell
        }
    },

    arcane = {
        {
            merge(templates.upgrade_power3, {
                action_arg = "burst",
                image = "kr3_special_icons_0101",
                place = 1,
                sounds = { "ElvesArcherArcaneBurstTaunt" },
                tt_phrase = _("TOWER_ARCANE_ARCHER_BURST_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_ARCANE_ARCHER_BURST_NAME_1"),
                        tt_desc = _("TOWER_ARCANE_ARCHER_BURST_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_ARCANE_ARCHER_BURST_NAME_2"),
                        tt_desc = _("TOWER_ARCANE_ARCHER_BURST_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_ARCANE_ARCHER_BURST_NAME_3"),
                        tt_desc = _("TOWER_ARCANE_ARCHER_BURST_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power3, {
                action_arg = "slumber",
                image = "kr3_special_icons_0100",
                place = 2,
                sounds = { "ElvesArcherArcaneSleepTaunt" },
                tt_phrase = _("TOWER_ARCANE_ARCHER_SLUMBER_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_ARCANE_ARCHER_SLUMBER_NAME_1"),
                        tt_desc = _("TOWER_ARCANE_ARCHER_SLUMBER_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_ARCANE_ARCHER_SLUMBER_NAME_2"),
                        tt_desc = _("TOWER_ARCANE_ARCHER_SLUMBER_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_ARCANE_ARCHER_SLUMBER_NAME_3"),
                        tt_desc = _("TOWER_ARCANE_ARCHER_SLUMBER_DESCRIPTION_3")
                    }
                }
            }),
            templates.sell
        }
    },

    silver = {
        {
            merge(templates.upgrade_power3, {
                action_arg = "sentence",
                image = "kr3_special_icons_0102",
                place = 1,
                sounds = { "ElvesArcherGoldenBowCrimsonTaunt" },
                tt_phrase = _("TOWER_SILVER_SENTENCE_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_SILVER_SENTENCE_NAME_1"),
                        tt_desc = _("TOWER_SILVER_SENTENCE_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_SILVER_SENTENCE_NAME_2"),
                        tt_desc = _("TOWER_SILVER_SENTENCE_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_SILVER_SENTENCE_NAME_3"),
                        tt_desc = _("TOWER_SILVER_SENTENCE_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power3, {
                action_arg = "mark",
                image = "kr3_special_icons_0103",
                place = 2,
                sounds = { "ElvesArcherGoldenBowMarkTaunt" },
                tt_phrase = _("TOWER_SILVER_MARK_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_SILVER_MARK_NAME_1"),
                        tt_desc = _("TOWER_SILVER_MARK_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_SILVER_MARK_NAME_2"),
                        tt_desc = _("TOWER_SILVER_MARK_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_SILVER_MARK_NAME_3"),
                        tt_desc = _("TOWER_SILVER_MARK_DESCRIPTION_3")
                    }
                }
            }),
            templates.sell
        }
    },

    wild_magus = {
        {
            merge(templates.upgrade_power3, {
                action_arg = "eldritch",
                image = "kr3_special_icons_0115",
                place = 1,
                sounds = { "ElvesMageWildMagusDoomTaunt" },
                tt_phrase = _("TOWER_MAGE_WILD_MAGUS_ELDRITCH_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_MAGE_WILD_MAGUS_ELDRITCH_NAME_1"),
                        tt_desc = _("TOWER_MAGE_WILD_MAGUS_ELDRITCH_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_MAGE_WILD_MAGUS_ELDRITCH_NAME_2"),
                        tt_desc = _("TOWER_MAGE_WILD_MAGUS_ELDRITCH_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_MAGE_WILD_MAGUS_ELDRITCH_NAME_3"),
                        tt_desc = _("TOWER_MAGE_WILD_MAGUS_ELDRITCH_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power3, {
                action_arg = "ward",
                image = "kr3_special_icons_0116",
                place = 2,
                sounds = { "ElvesMageWildMagusSilenceTaunt" },
                tt_phrase = _("TOWER_MAGE_WILD_MAGUS_WARD_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_MAGE_WILD_MAGUS_WARD_NAME_1"),
                        tt_desc = _("TOWER_MAGE_WILD_MAGUS_WARD_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_MAGE_WILD_MAGUS_WARD_NAME_2"),
                        tt_desc = _("TOWER_MAGE_WILD_MAGUS_WARD_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_MAGE_WILD_MAGUS_WARD_NAME_3"),
                        tt_desc = _("TOWER_MAGE_WILD_MAGUS_WARD_DESCRIPTION_3")
                    }
                }
            }),
            templates.sell
        }
    },

    high_elven = {
        {
            merge(templates.upgrade_power3, {
                action_arg = "timelapse",
                image = "kr3_special_icons_0117",
                place = 1,
                sounds = { "ElvesMageHighElvenTimelapseTaunt" },
                tt_phrase = _("TOWER_MAGE_HIGH_ELVEN_TIMELAPSE_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_MAGE_HIGH_ELVEN_TIMELAPSE_NAME_1"),
                        tt_desc = _("TOWER_MAGE_HIGH_ELVEN_TIMELAPSE_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_MAGE_HIGH_ELVEN_TIMELAPSE_NAME_2"),
                        tt_desc = _("TOWER_MAGE_HIGH_ELVEN_TIMELAPSE_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_MAGE_HIGH_ELVEN_TIMELAPSE_NAME_3"),
                        tt_desc = _("TOWER_MAGE_HIGH_ELVEN_TIMELAPSE_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power3, {
                action_arg = "sentinel",
                image = "kr3_special_icons_0118",
                place = 2,
                sounds = { "ElvesMageHighElvenSentinelTaunt" },
                tt_phrase = _("TOWER_MAGE_HIGH_ELVEN_SENTINEL_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("TOWER_MAGE_HIGH_ELVEN_SENTINEL_NAME_1"),
                        tt_desc = _("TOWER_MAGE_HIGH_ELVEN_SENTINEL_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("TOWER_MAGE_HIGH_ELVEN_SENTINEL_NAME_2"),
                        tt_desc = _("TOWER_MAGE_HIGH_ELVEN_SENTINEL_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("TOWER_MAGE_HIGH_ELVEN_SENTINEL_NAME_3"),
                        tt_desc = _("TOWER_MAGE_HIGH_ELVEN_SENTINEL_DESCRIPTION_3")
                    }
                }
            }),
            templates.sell
        }
    },

    holder_ewok = {
        {
            merge(templates.upgrade_power3, {
                action_arg = "tower_ewok",
                image = "main_icons_0015",
                place = 5,
                tt_title = _("ELVES_EWOK_TOWER_BROKEN_NAME"),
                tt_desc = _("ELVES_EWOK_TOWER_BROKEN_DESCRIPTION"),
            })
        }
    },

    ewok = {
        {
            merge(templates.upgrade_power3, {
                action_arg = "armor",
                image = "special_icons_0041",
                place = 6,
                sounds = { "ElvesEwokTaunt" },
                tt_phrase = _("以树为甲……"),
                tt_list =
                {
                    {
                        tt_title = _("大树护甲"),
                        tt_desc = _("提升伊渥克士兵的护甲")
                    },
                    {
                        tt_title = _("大树护甲Ⅱ"),
                        tt_desc = _("进一步提升伊渥克士兵的护甲")
                    },
                    {
                        tt_title = _("大树护甲Ⅲ"),
                        tt_desc = _("进一步提升伊渥克士兵的护甲")
                    }
                }
            }),
            merge(templates.upgrade_power3, {
                action_arg = "shield",
                image = "special_icons_0009",
                place = 5,
                sounds = { "ElvesEwokTaunt" },
                tt_phrase = _("举盾，防御！"),
                tt_list =
                {
                    {
                        tt_title = _("盾势"),
                        tt_desc = _("提升伊渥克士兵盾牌格挡的时间，并附带恢复效果")
                    },
                    {
                        tt_title = _("盾势Ⅱ"),
                        tt_desc = _("提升伊渥克士兵盾牌格挡的时间和恢复效果")
                    }
                }
            }),
            merge(templates.upgrade_power3, {
                action_arg = "tear",
                image = "kr3_special_icons_0110",
                place = 7,
                sounds = { "ElvesEwokTaunt" },
                tt_phrase = _("撕碎他们的防御！"),
                tt_list =
                {
                    {
                        tt_title = _("碎甲投索"),
                        tt_desc = _("使投索获得削弱护甲的能力，并提升投索伤害")
                    },
                    {
                        tt_title = _("碎甲投索Ⅱ"),
                        tt_desc = _("提升投索碎甲能力和伤害")
                    },
                    {
                        tt_title = _("碎甲投索Ⅲ"),
                        tt_desc = _("提升投索碎甲能力和伤害")
                    }
                }
            }),
            templates.rally,
            templates.sell
        }
    },

    faerie_dragon = {
        {
            merge(templates.upgrade_power3, {
                action_arg = "more_dragons",
                image = "kr3_special_icons_0124",
                place = 1,
                sounds = { "ElvesFaeryDragonDragonBuy" },
                tt_phrase = _("ELVES_TOWER_SPECIAL_FAERIE_DRAGONS_UPGRADE_MORE_DRAGONS_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("ELVES_TOWER_SPECIAL_FAERIE_DRAGONS_UPGRADE_MORE_DRAGONS_NAME_1"),
                        tt_desc = _("ELVES_TOWER_SPECIAL_FAERIE_DRAGONS_UPGRADE_MORE_DRAGONS_SMALL_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("ELVES_TOWER_SPECIAL_FAERIE_DRAGONS_UPGRADE_MORE_DRAGONS_NAME_2"),
                        tt_desc = _("ELVES_TOWER_SPECIAL_FAERIE_DRAGONS_UPGRADE_MORE_DRAGONS_SMALL_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("ELVES_TOWER_SPECIAL_FAERIE_DRAGONS_UPGRADE_MORE_DRAGONS_NAME_3"),
                        tt_desc = _("ELVES_TOWER_SPECIAL_FAERIE_DRAGONS_UPGRADE_MORE_DRAGONS_SMALL_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power3, {
                action_arg = "improve_shot",
                image = "kr3_special_icons_0125",
                place = 2,
                sounds = { "ElvesFaeryDragonExtraAbility" },
                tt_phrase = _("ELVES_TOWER_SPECIAL_FAERIE_DRAGONS_UPGRADE_IMPROVE_SHOT_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("ELVES_TOWER_SPECIAL_FAERIE_DRAGONS_UPGRADE_IMPROVE_SHOT_NAME_1"),
                        tt_desc = _("ELVES_TOWER_SPECIAL_FAERIE_DRAGONS_UPGRADE_IMPROVE_SHOT_SMALL_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("ELVES_TOWER_SPECIAL_FAERIE_DRAGONS_UPGRADE_IMPROVE_SHOT_NAME_2"),
                        tt_desc = _("ELVES_TOWER_SPECIAL_FAERIE_DRAGONS_UPGRADE_IMPROVE_SHOT_SMALL_DESCRIPTION_2")
                    }
                }
            }),
            templates.sell
        }
    },

    pixie = {
        {
            merge(templates.upgrade_power3, {
                action_arg = "cream",
                image = "kr3_special_icons_0122",
                place = 1,
                sounds = { "ElvesGnomeNew" },
                tt_phrase = _("ELVES_TOWER_PIXIE_UPGRADE1_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("ELVES_TOWER_PIXIE_UPGRADE1_NAME_1"),
                        tt_desc = _("ELVES_TOWER_PIXIE_UPGRADE1_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("ELVES_TOWER_PIXIE_UPGRADE1_NAME_2"),
                        tt_desc = _("ELVES_TOWER_PIXIE_UPGRADE1_DESCRIPTION_2")
                    }
                }
            }),
            merge(templates.upgrade_power3, {
                action_arg = "total",
                image = "kr3_special_icons_0123",
                place = 2,
                sounds = { "ElvesGnomePower" },
                tt_phrase = _("ELVES_TOWER_PIXIE_UPGRADE2_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("ELVES_TOWER_PIXIE_UPGRADE2_NAME_1"),
                        tt_desc = _("ELVES_TOWER_PIXIE_UPGRADE2_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("ELVES_TOWER_PIXIE_UPGRADE2_NAME_2"),
                        tt_desc = _("ELVES_TOWER_PIXIE_UPGRADE2_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("ELVES_TOWER_PIXIE_UPGRADE2_NAME_3"),
                        tt_desc = _("ELVES_TOWER_PIXIE_UPGRADE2_DESCRIPTION_3")
                    }
                }
            }),
            templates.sell
        }
    },

    baby_black_dragon = {
        {
            merge(templates.buy_attack3, {
                action_arg = 1,
                image = "kr3_main_icons_0114",
                tt_title = _("ELVES_BABY_BERESAD_SPECIAL_NAME_1"),
                tt_desc = _("ELVES_BABY_BERESAD_SPECIAL_SMALL_DESCRIPTION_1"),
            })
        }
    },

    holder_baby_ashbite = {
        {
            merge(templates.upgrade_power3, {
                action_arg = "tower_baby_ashbite",
                image = "kr3_main_icons_0113",
                tt_title = _("ELVES_BABY_ASHBITE_TOWER_BROKEN_NAME"),
                tt_desc = _("ELVES_BABY_ASHBITE_TOWER_BROKEN_DESCRIPTION"),
            })
        }
    },

    baby_ashbite = {
        {
            merge(templates.upgrade_power3, {
                action_arg = "blazing_breath",
                image = "kr3_special_icons_0126",
                place = 1,
                sounds = { "ElvesAshbiteConfirm" },
                tt_phrase = _("ELVES_BABY_ASHBITE_FIREBREATH_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("ELVES_BABY_ASHBITE_FIREBREATH_NAME_1"),
                        tt_desc = _("ELVES_BABY_ASHBITE_FIREBREATH_SMALL_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("ELVES_BABY_ASHBITE_FIREBREATH_NAME_2"),
                        tt_desc = _("ELVES_BABY_ASHBITE_FIREBREATH_SMALL_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("ELVES_BABY_ASHBITE_FIREBREATH_NAME_3"),
                        tt_desc = _("ELVES_BABY_ASHBITE_FIREBREATH_SMALL_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power3, {
                action_arg = "fiery_mist",
                image = "kr3_special_icons_0127",
                place = 2,
                sounds = { "ElvesAshbiteConfirm" },
                tt_phrase = _("ELVES_BABY_ASHBITE_SMOKEBREATH_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("ELVES_BABY_ASHBITE_SMOKEBREATH_NAME_1"),
                        tt_desc = _("ELVES_BABY_ASHBITE_SMOKEBREATH_SMALL_DESCRIPTION_1")
                    }
                }
            }),
            templates.rally,
            templates.sell
        }
    },

    drow = {
        {
            merge(templates.upgrade_power3, {
                action_arg = "life_drain",
                image = "kr3_special_icons_0120",
                place = 6,
                sounds = { "ElvesSpecialDrowLifeDrain" },
                tt_phrase = _("ELVES_TOWER_DROW_LIFE_DRAIN_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("ELVES_TOWER_DROW_LIFE_DRAIN_NAME_1"),
                        tt_desc = _("ELVES_TOWER_DROW_LIFE_DRAIN_SMALL_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("ELVES_TOWER_DROW_LIFE_DRAIN_NAME_2"),
                        tt_desc = _("ELVES_TOWER_DROW_LIFE_DRAIN_SMALL_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("ELVES_TOWER_DROW_LIFE_DRAIN_NAME_3"),
                        tt_desc = _("ELVES_TOWER_DROW_LIFE_DRAIN_SMALL_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power3, {
                action_arg = "blade_mail",
                image = "kr3_special_icons_0119",
                place = 7,
                sounds = { "ElvesSpecialDrowBlademail" },
                tt_phrase = _("ELVES_TOWER_DROW_BLADE_MAIL_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("ELVES_TOWER_DROW_BLADE_MAIL_NAME_1"),
                        tt_desc = _("ELVES_TOWER_DROW_BLADE_MAIL_SMALL_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("ELVES_TOWER_DROW_BLADE_MAIL_NAME_2"),
                        tt_desc = _("ELVES_TOWER_DROW_BLADE_MAIL_SMALL_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("ELVES_TOWER_DROW_BLADE_MAIL_NAME_3"),
                        tt_desc = _("ELVES_TOWER_DROW_BLADE_MAIL_SMALL_DESCRIPTION_3")
                    }
                }
            }),
            merge(templates.upgrade_power3, {
                action_arg = "double_dagger",
                image = "kr3_special_icons_0121",
                place = 5,
                sounds = { "ElvesSpecialDrowDaggers" },
                tt_phrase = _("ELVES_TOWER_DROW_DOUBLE_DAGGER_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("ELVES_TOWER_DROW_DOUBLE_DAGGER_NAME_1"),
                        tt_desc = _("ELVES_TOWER_DROW_DOUBLE_DAGGER_SMALL_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("ELVES_TOWER_DROW_DOUBLE_DAGGER_NAME_2"),
                        tt_desc = _("ELVES_TOWER_DROW_DOUBLE_DAGGER_SMALL_DESCRIPTION_2")
                    },
                    {
                        tt_title = _("ELVES_TOWER_DROW_DOUBLE_DAGGER_NAME_3"),
                        tt_desc = _("ELVES_TOWER_DROW_DOUBLE_DAGGER_SMALL_DESCRIPTION_3")
                    }
                }
            }),
            templates.rally,
            templates.sell
        }
    },

    holder_bastion = {
        {
            merge(templates.upgrade_power3, {
                action_arg = "tower_bastion",
                image = "main_icons_0015",
                place = 5,
                tt_title = _("ELVES_TOWER_BASTION_BROKEN_NAME"),
                tt_desc = _("ELVES_TOWER_BASTION_BROKEN_DESCRIPTION")
            })
        }
    },

    bastion = {
        {
            merge(templates.upgrade_power3, {
                action_arg = "razor_edge",
                image = "kr3_special_icons_0128",
                place = 5,
                sounds = { "ElvesTowerBastionRazorEdge" },
                tt_phrase = _("ELVES_TOWER_BASTION_RAZOR_EDGE_NOTE"),
                tt_list =
                {
                    {
                        tt_title = _("ELVES_TOWER_BASTION_RAZOR_EDGE_NAME_1"),
                        tt_desc = _("ELVES_TOWER_BASTION_RAZOR_EDGE_SMALL_DESCRIPTION_1")
                    },
                    {
                        tt_title = _("ELVES_TOWER_BASTION_RAZOR_EDGE_NAME_2"),
                        tt_desc = _("ELVES_TOWER_BASTION_RAZOR_EDGE_SMALL_DESCRIPTION_2")
                    }
                }
            })
        }
    },

    --[[
        五代
    --]]

    -- 三管加农炮
    tricannon = {
        {
            merge(templates.upgrade_power5, {
                action_arg = "bombardment",
                image = "kr5_special_icons_0007",
                place = 6,
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
                }
            }),
            merge(templates.upgrade_power5, {
                action_arg = "overheat",
                image = "kr5_special_icons_0008",
                place = 7,
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
                }
            }),
            templates.sell
        }
    },

    -- 暮光长弓
    dark_elf = {
        {
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
                is_kr5_change_mode = true
            },
            merge(templates.upgrade_power5, {
                action_arg = "skill_soldiers",
                image = "kr5_special_icons_0032",
                place = 6,
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
                }
            }),
            merge(templates.upgrade_power5, {
                action_arg = "skill_buff",
                image = "kr5_special_icons_0033",
                place = 7,
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
                }
            }),
            templates.rally,
            templates.sell
        }
    },

    -- 恶魔澡坑
    demon_pit = {
        {
            merge(templates.upgrade_power5, {
                action_arg = "master_exploders",
                image = "kr5_special_icons_0011",
                place = 6,
                sounds = {
                    "TowerDemonPitSkillATaunt"
                },
                tt_phrase = _("TOWER_DEMON_PIT_4_MASTER_EXPLODERS_NOTE"),
                tt_list = {
                    {
                        tt_title = _("TOWER_DEMON_PIT_4_MASTER_EXPLODERS_1_NAME"),
                        tt_desc = _("TOWER_DEMON_PIT_4_MASTER_EXPLODERS_1_DESCRIPTION")
                    },
                    {
                        tt_title = _("TOWER_DEMON_PIT_4_MASTER_EXPLODERS_2_NAME"),
                        tt_desc = _("TOWER_DEMON_PIT_4_MASTER_EXPLODERS_2_DESCRIPTION")
                    },
                    {
                        tt_title = _("TOWER_DEMON_PIT_4_MASTER_EXPLODERS_3_NAME"),
                        tt_desc = _("TOWER_DEMON_PIT_4_MASTER_EXPLODERS_3_DESCRIPTION")
                    }
                }
            }),
            merge(templates.upgrade_power5, {
                action_arg = "big_guy",
                image = "kr5_special_icons_0012",
                place = 7,
                sounds = {
                    "TowerDemonPitSkillBTaunt"
                },
                tt_phrase = _("TOWER_DEMON_PIT_4_BIG_DEMON_NOTE"),
                tt_list = {
                    {
                        tt_title = _("TOWER_DEMON_PIT_4_BIG_DEMON_1_NAME"),
                        tt_desc = _("TOWER_DEMON_PIT_4_BIG_DEMON_1_DESCRIPTION")
                    },
                    {
                        tt_title = _("TOWER_DEMON_PIT_4_BIG_DEMON_2_NAME"),
                        tt_desc = _("TOWER_DEMON_PIT_4_BIG_DEMON_2_DESCRIPTION")
                    },
                    {
                        tt_title = _("TOWER_DEMON_PIT_4_BIG_DEMON_3_NAME"),
                        tt_desc = _("TOWER_DEMON_PIT_4_BIG_DEMON_3_DESCRIPTION")
                    }
                }
            }),
            templates.sell
        },
    },

    -- 死灵法师
    necromancer_lvl4 = {
        {
            merge(templates.upgrade_power5, {
                action_arg = "skill_debuff",
                image = "kr5_special_icons_0017",
                place = 6,
                sounds = {
                    "TowerNecromancerSkillATaunt"
                },
                tt_phrase = _("TOWER_NECROMANCER_4_SKILL_DEBUFF_NOTE"),
                tt_list = {
                    {
                        tt_title = _("TOWER_NECROMANCER_4_SKILL_DEBUFF_1_NAME"),
                        tt_desc = _("TOWER_NECROMANCER_4_SKILL_DEBUFF_1_DESCRIPTION")
                    },
                    {
                        tt_title = _("TOWER_NECROMANCER_4_SKILL_DEBUFF_2_NAME"),
                        tt_desc = _("TOWER_NECROMANCER_4_SKILL_DEBUFF_2_DESCRIPTION")
                    },
                    {
                        tt_title = _("TOWER_NECROMANCER_4_SKILL_DEBUFF_3_NAME"),
                        tt_desc = _("TOWER_NECROMANCER_4_SKILL_DEBUFF_3_DESCRIPTION")
                    }
                }
            }),
            merge(templates.upgrade_power5, {
                action_arg = "skill_rider",
                image = "kr5_special_icons_0018",
                place = 7,
                sounds = {
                    "TowerNecromancerSkillBTaunt"
                },
                tt_phrase = _("TOWER_NECROMANCER_4_SKILL_RIDER_NOTE"),
                tt_list = {
                    {
                        tt_title = _("TOWER_NECROMANCER_4_SKILL_RIDER_1_NAME"),
                        tt_desc = _("TOWER_NECROMANCER_4_SKILL_RIDER_1_DESCRIPTION")
                    },
                    {
                        tt_title = _("TOWER_NECROMANCER_4_SKILL_RIDER_2_NAME"),
                        tt_desc = _("TOWER_NECROMANCER_4_SKILL_RIDER_2_DESCRIPTION")
                    },
                    {
                        tt_title = _("TOWER_NECROMANCER_4_SKILL_RIDER_3_NAME"),
                        tt_desc = _("TOWER_NECROMANCER_4_SKILL_RIDER_3_DESCRIPTION")
                    }
                }
            }),
            templates.sell
        }
    },

    -- 熊猫
    pandas = {
        {
            merge(templates.upgrade_power5, {
                action_arg = "thunder",
                image = "kr5_special_icons_0041",
                place = 12,
                sounds = {
                    i18n:cjk("TowerPandasSkillATaunt", "TowerPandasSkillATauntZH", nil, nil)
                },
                tt_phrase = _("TOWER_PANDAS_4_THUNDER"),
                tt_list = {
                    {
                        tt_title = _("TOWER_PANDAS_4_THUNDER_1_NAME"),
                        tt_desc = _("TOWER_PANDAS_4_THUNDER_1_DESCRIPTION")
                    },
                    {
                        tt_title = _("TOWER_PANDAS_4_THUNDER_2_NAME"),
                        tt_desc = _("TOWER_PANDAS_4_THUNDER_2_DESCRIPTION")
                    }
                }
            }),
            merge(templates.upgrade_power5, {
                action_arg = "hat",
                image = "kr5_special_icons_0040",
                place = 14,
                sounds = {
                    i18n:cjk("TowerPandasSkillBTaunt", "TowerPandasSkillBTauntZH", nil, nil)
                },
                tt_phrase = _("TOWER_PANDAS_4_HAT"),
                tt_list = {
                    {
                        tt_title = _("TOWER_PANDAS_4_HAT_1_NAME"),
                        tt_desc = _("TOWER_PANDAS_4_HAT_1_DESCRIPTION")
                    },
                    {
                        tt_title = _("TOWER_PANDAS_4_HAT_2_NAME"),
                        tt_desc = _("TOWER_PANDAS_4_HAT_2_DESCRIPTION")
                    }
                }
            }),
            merge(templates.upgrade_power5, {
                action_arg = "teleport",
                image = "kr5_special_icons_0042",
                place = 15,
                sounds = {
                    i18n:cjk("TowerPandasSkillCTaunt", "TowerPandasSkillCTauntZH", nil, nil)
                },
                tt_phrase = _("TOWER_PANDAS_4_FIERY"),
                tt_list = {
                    {
                        tt_title = _("TOWER_PANDAS_4_FIERY_1_NAME"),
                        tt_desc = _("TOWER_PANDAS_4_FIERY_1_DESCRIPTION")
                    },
                    {
                        tt_title = _("TOWER_PANDAS_4_FIERY_2_NAME"),
                        tt_desc = _("TOWER_PANDAS_4_FIERY_2_DESCRIPTION")
                    }
                }
            }),
            {
                check = "kr5_special_icons_0020",
                action_arg = "pandas_retreat",
                action = "tw_free_action",
                halo = "glow_ico_main",
                image = "kr5_quickmenu_retreat_icons_tower_panda",
                place = 13,
                tt_title = _("TOWER_PANDAS_RETREAT_NAME"),
                tt_desc = _("TOWER_PANDAS_RETREAT_DESCRIPTION")
            },
            templates.rally,
            templates.sell
        }
    },
}
