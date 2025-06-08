﻿-- chunkname: @./kr1-desktop/data/platform_services_ids.lua

require("constants")
require("version")

local ids = {}

ids.steam = {}
ids.steam.achievements = {
	RATATOUILLE = "ACH_RATATOUILLE",
	HELL_O = "ACH_KILLDEMON",
	DEFEAT_TROLL_BOSS = "ACH_TROLL_BOSS",
	SPECIALIZATION = "ACH_SPECIALIST",
	HERO_HARD = "ACH_LEGEND",
	DEFEAT_SARELGAZ = "ACH_ARACHNOPHOBIA",
	DEFEAT_COMPLETE_HARD = "ACH_SUPREME_DEFENDER",
	DEFEAT_ACORN = "ACH_ACORN",
	DIE_HARD = "ACH_DIE_HARD",
	DEATH_FROM_ABOVE = "ACH_DEATH_FROM_ABOVE",
	FREE_FREDO = "ACH_FREDO",
	ACDC = "ACH_ACDC",
	TOXICITY = "ACH_TOXICITY",
	DEFEAT_TREANT_BOSS = "ACH_LUMBERJACK",
	ENTANGLED = "ACH_ENTANGLED",
	DEFEAT_END_BOSS = "ACH_VEZNAN",
	HOLY_CHORUS = "ACH_HOLY_CHORUS",
	EARN30_STARS = "ACH_SUPER_MARIO",
	HEROIC_DEFENDER = "ACH_HEROIC",
	GI_JOE = "ACH_GI_JOE",
	GREAT_DEFENDER = "ACH_GREAT_DEFENDER",
	DEFEAT_MOUNTAIN_BOSS = "ACH_KILL_JT",
	SPORE = "ACH_SPORE",
	CANNON_FODDER = "ACH_CANNON_FODDER",
	SPLINTER = "ACH_SPLINTER",
	DARING = "ACH_DARING",
	SUN_BURNER = "ACH_SUN_BURNER",
	BEAM_ME_UP = "ACH_BEAM_ME_UP",
	UPGRADE_LEVEL3 = "ACH_HOME_IMPROVEMENT",
	DEFEAT_JUGGERNAUT = "ACH_NUTS_AND_BOLTS",
	EASY_TOWER_BUILDER = "ACH_CONSTRUCTOR",
	MEDIC = "ACH_MEDIC",
	GOC = "ACH_GOC",
	SNIPER = "ACH_SNIPER",
	NESSIE = "ACH_NESSIE",
	DEFEAT_COOL_RUNNING = "ACH_COOLRUNNING",
	SHEPARD = "ACH_SHEPHERD",
	STILL_COUNTS_AS_ONE = "ACH_STILLCOUNTSASONE",
	AXE_RAINER = "ACH_AXE_RAIN",
	BARBARIAN_RUSH = "ACH_NOT_ENTERTAINED",
	ARMY_OF_ONE = "ACH_ARMYOFONE",
	DEFEAT_GULTHAK_BOSS = "ACH_ORCS",
	DUST_TO_DUST = "ACH_DUST_TO_DUST",
	IMPERIAL_SAVIOUR = "ACH_IMPERIAL_SAVIOUR",
	IRON_DEFENDER = "ACH_IRON",
	REAL_STATE = "ACH_REAL_ESTATE",
	HARD_TOWER_BUILDER = "ACH_THE_ARCHITECT",
	FEARLESS = "ACH_FEARLESS",
	TACTICIAN = "ACH_TACTICIAN",
	CLUSTERED = "ACH_CLUSTERED",
	ELEMENTALIST = "ACH_ELEMENTALIST",
	SHEEP_KILLER = "ACH_OVINOPHOBIA",
	EARN45_STARS = "ACH_SUPERSTAR",
	FIRST_BLOOD = "ACH_FIRST_BLOOD",
	HERO_MEDIUM = "ACH_CHAMPION",
	SLAYER = "ACH_SLAYER",
	HENDERSON = "ACH_HENDERSON",
	CATCH_A_FISH = "ACH_TWIN_RIVERS",
	MULTIKILL = "ACH_TERMINATOR",
	WE_DINE_IN_HELL = "ACH_DINEINHELL",
	ARMAGGEDON = "ACH_ARMAGEDDON",
	WHATS_THAT = "ACH_WHATS_THAT",
	INDECISIVE = "ACH_INDECISIVE",
	BLOODLUST = "ACH_BLOODLUST",
	IMPATIENT = "ACH_IMPATIENT",
	EARN15_STARS = "ACH_STARRY",
	DEFEAT_KINGPING_BOSS = "ACH_LAW",
	SUPER_MUSHROOM = "ACH_KILLMUSHROOM",
	ROCKETEER = "ACH_ROCKETEER",
	MAX_ELVES = "ACH_FOREST_DIPLOMACY",
	DEFEAT_MUSHROOM = "ACH_PLANTS_TROLLS",
	NEVERMORE = "ACH_NEVERMORE",
	MEDIUM_TOWER_BUILDER = "ACH_ENGINEER",
	ENERGY_NETWORK = "ACH_ENERGY_NETWORK"
}
ids.gamecenter = {}
ids.gamecenter.achievements = {
	RATATOUILLE = "kr1.mac.RATATOUILLE",
	HELL_O = "kr1.mac.HELL_O",
	DEFEAT_TROLL_BOSS = "kr1.mac.DEFEAT_TROLL_BOSS",
	SPECIALIZATION = "kr1.mac.SPECIALIZATION",
	ENTANGLED = "kr1.mac.ENTANGLED",
	DEFEAT_SARELGAZ = "kr1.mac.DEFEAT_SARELGAZ",
	HENDERSON = "kr1.mac.HENDERSON",
	SLAYER = "kr1.mac.SLAYER",
	ROCKETEER = "kr1.mac.ROCKETEER",
	HOLY_CHORUS = "kr1.mac.HOLY_CHORUS",
	FREE_FREDO = "kr1.mac.FREE_FREDO",
	DEATH_FROM_ABOVE = "kr1.mac.DEATH_FROM_ABOVE",
	TOXICITY = "kr1.mac.TOXICITY",
	DEFEAT_TREANT_BOSS = "kr1.mac.DEFEAT_TREANT_BOSS",
	UPGRADE_LEVEL3 = "kr1.mac.UPGRADE_LEVEL3",
	ACDC = "kr1.mac.ACDC",
	DEFEAT_MOUNTAIN_BOSS = "kr1.mac.DEFEAT_MOUNTAIN_BOSS",
	DEFEAT_END_BOSS = "kr1.mac.DEFEAT_END_BOSS",
	HEROIC_DEFENDER = "kr1.mac.HEROIC_DEFENDER",
	GI_JOE = "kr1.mac.GI_JOE",
	GREAT_DEFENDER = "kr1.mac.GREAT_DEFENDER",
	BEAM_ME_UP = "kr1.mac.BEAM_ME_UP",
	SUN_BURNER = "kr1.mac.SUN_BURNER",
	CANNON_FODDER = "kr1.mac.CANNON_FODDER",
	SPLINTER = "kr1.mac.SPLINTER",
	DARING = "kr1.mac.DARING",
	DEFEAT_MUSHROOM = "kr1.mac.DEFEAT_MUSHROOM",
	DEFEAT_KINGPING_BOSS = "kr1.mac.DEFEAT_KINGPING_BOSS",
	DEFEAT_COMPLETE_HARD = "kr1.mac.DEFEAT_COMPLETE_HARD",
	DEFEAT_JUGGERNAUT = "kr1.mac.DEFEAT_JUGGERNAUT",
	EASY_TOWER_BUILDER = "kr1.mac.EASY_TOWER_BUILDER",
	MEDIC = "kr1.mac.MEDIC",
	GOC = "kr1.mac.GOC",
	SNIPER = "kr1.mac.SNIPER",
	NESSIE = "kr1.mac.NESSIE",
	DEFEAT_COOL_RUNNING = "kr1.mac.DEFEAT_COOL_RUNNING",
	SHEPARD = "kr1.mac.SHEPARD",
	STILL_COUNTS_AS_ONE = "kr1.mac.STILL_COUNTS_AS_ONE",
	AXE_RAINER = "kr1.mac.AXE_RAINER",
	BARBARIAN_RUSH = "kr1.mac.BARBARIAN_RUSH",
	ARMY_OF_ONE = "kr1.mac.ARMY_OF_ONE",
	DEFEAT_GULTHAK_BOSS = "kr1.mac.DEFEAT_GULTHAK_BOSS",
	DUST_TO_DUST = "kr1.mac.DUST_TO_DUST",
	IMPERIAL_SAVIOUR = "kr1.mac.IMPERIAL_SAVIOUR",
	IRON_DEFENDER = "kr1.mac.IRON_DEFENDER",
	REAL_STATE = "kr1.mac.REAL_STATE",
	HARD_TOWER_BUILDER = "kr1.mac.HARD_TOWER_BUILDER",
	FEARLESS = "kr1.mac.FEARLESS",
	TACTICIAN = "kr1.mac.TACTICIAN",
	CLUSTERED = "kr1.mac.CLUSTERED",
	ELEMENTALIST = "kr1.mac.ELEMENTALIST",
	SHEEP_KILLER = "kr1.mac.SHEEP_KILLER",
	EARN45_STARS = "kr1.mac.EARN45_STARS",
	FIRST_BLOOD = "kr1.mac.FIRST_BLOOD",
	HERO_MEDIUM = "kr1.mac.HERO_MEDIUM",
	DIE_HARD = "kr1.mac.DIE_HARD",
	DEFEAT_ACORN = "kr1.mac.DEFEAT_ACORN",
	CATCH_A_FISH = "kr1.mac.CATCH_A_FISH",
	MULTIKILL = "kr1.mac.MULTIKILL",
	WE_DINE_IN_HELL = "kr1.mac.WE_DINE_IN_HELL",
	ARMAGGEDON = "kr1.mac.ARMAGGEDON",
	WHATS_THAT = "kr1.mac.WHATS_THAT",
	INDECISIVE = "kr1.mac.INDECISIVE",
	BLOODLUST = "kr1.mac.BLOODLUST",
	IMPATIENT = "kr1.mac.IMPATIENT",
	EARN15_STARS = "kr1.mac.EARN15_STARS",
	HERO_HARD = "kr1.mac.HERO_HARD",
	SUPER_MUSHROOM = "kr1.mac.SUPER_MUSHROOM",
	EARN30_STARS = "kr1.mac.EARN30_STARS",
	MAX_ELVES = "kr1.mac.MAX_ELVES",
	SPORE = "kr1.mac.SPORE",
	NEVERMORE = "kr1.mac.NEVERMORE",
	MEDIUM_TOWER_BUILDER = "kr1.mac.MEDIUM_TOWER_BUILDER",
	ENERGY_NETWORK = "kr1.mac.ENERGY_NETWORK"
}
ids.gamecenter.achievements_metadata = {
	FIRST_BLOOD = {
		5,
		false
	},
	DARING = {
		5,
		false
	},
	EASY_TOWER_BUILDER = {
		5,
		false
	},
	BLOODLUST = {
		10,
		false
	},
	ARMAGGEDON = {
		10,
		false
	},
	UPGRADE_LEVEL3 = {
		10,
		false
	},
	EARN15_STARS = {
		10,
		false
	},
	WHATS_THAT = {
		5,
		false
	},
	EARN30_STARS = {
		15,
		false
	},
	DEFEAT_JUGGERNAUT = {
		25,
		false
	},
	MEDIUM_TOWER_BUILDER = {
		15,
		false
	},
	DEFEAT_MOUNTAIN_BOSS = {
		25,
		false
	},
	SLAYER = {
		15,
		false
	},
	DEATH_FROM_ABOVE = {
		10,
		false
	},
	TACTICIAN = {
		10,
		false
	},
	EARN45_STARS = {
		20,
		false
	},
	HARD_TOWER_BUILDER = {
		20,
		false
	},
	DEFEAT_END_BOSS = {
		25,
		false
	},
	MULTIKILL = {
		20,
		false
	},
	DIE_HARD = {
		20,
		false
	},
	GI_JOE = {
		15,
		false
	},
	CANNON_FODDER = {
		15,
		false
	},
	FEARLESS = {
		10,
		false
	},
	REAL_STATE = {
		5,
		false
	},
	INDECISIVE = {
		5,
		false
	},
	IMPATIENT = {
		10,
		false
	},
	MAX_ELVES = {
		10,
		false
	},
	HENDERSON = {
		10,
		false
	},
	CATCH_A_FISH = {
		10,
		false
	},
	IMPERIAL_SAVIOUR = {
		15,
		false
	},
	SPECIALIZATION = {
		10,
		false
	},
	SNIPER = {
		10,
		false
	},
	TOXICITY = {
		10,
		false
	},
	ENTANGLED = {
		10,
		false
	},
	DUST_TO_DUST = {
		10,
		false
	},
	BEAM_ME_UP = {
		10,
		false
	},
	SHEPARD = {
		10,
		false
	},
	ELEMENTALIST = {
		10,
		false
	},
	AXE_RAINER = {
		10,
		false
	},
	BARBARIAN_RUSH = {
		15,
		false
	},
	MEDIC = {
		10,
		false
	},
	HOLY_CHORUS = {
		10,
		false
	},
	ROCKETEER = {
		10,
		false
	},
	CLUSTERED = {
		10,
		false
	},
	ENERGY_NETWORK = {
		15,
		false
	},
	ACDC = {
		10,
		false
	},
	SHEEP_KILLER = {
		10,
		false
	},
	FREE_FREDO = {
		10,
		false
	},
	DEFEAT_SARELGAZ = {
		25,
		false
	},
	DEFEAT_GULTHAK_BOSS = {
		25,
		false
	},
	DEFEAT_TREANT_BOSS = {
		25,
		false
	},
	HERO_MEDIUM = {
		10,
		false
	},
	HERO_HARD = {
		15,
		false
	},
	DEFEAT_KINGPING_BOSS = {
		25,
		false
	},
	DEFEAT_COOL_RUNNING = {
		25,
		false
	},
	DEFEAT_ACORN = {
		10,
		false
	},
	DEFEAT_MUSHROOM = {
		10,
		false
	},
	DEFEAT_TROLL_BOSS = {
		25,
		false
	},
	WE_DINE_IN_HELL = {
		5,
		false
	},
	ARMY_OF_ONE = {
		5,
		false
	},
	HELL_O = {
		10,
		false
	},
	SUPER_MUSHROOM = {
		5,
		false
	},
	SPORE = {
		5,
		false
	},
	STILL_COUNTS_AS_ONE = {
		5,
		false
	},
	RATATOUILLE = {
		2,
		false
	},
	NEVERMORE = {
		2,
		false
	},
	NESSIE = {
		2,
		false
	},
	SPLINTER = {
		2,
		false
	},
	GOC = {
		7,
		false
	},
	SUN_BURNER = {
		5,
		false
	},
	GREAT_DEFENDER = {
		25,
		false
	},
	HEROIC_DEFENDER = {
		50,
		false
	},
	IRON_DEFENDER = {
		50,
		false
	},
	DEFEAT_COMPLETE_HARD = {
		50,
		false
	}
}

return ids
