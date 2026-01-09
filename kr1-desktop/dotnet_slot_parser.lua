-- chunkname: @./kr1-desktop/dotnet_slot_parser.lua
local _TESTING

if ... == "dotnet_slot_parser" then
-- block empty
else
	_TESTING = true
	package.path = package.path .. ";" .. "src/lib/?.lua"
end

local log = require("lib.klua.log"):new("dotnet_slot_parser")

require("lib.klua.string")
require("lib.klua.table")
require("lib.klua.dump")

local bit = require("bit")
local bf = require("lib.klua.dotnet_bfds")
local sm = {}

function sm.map_difficulty(input, output, args)
	local m = {
		[0] = 2,
		1,
		3
	}

	return m[input]
end

function sm.set_flag(input, output, args)
	output = output or 0

	if input and type(input) == "number" and input > 0 then
		output = bit.bor(output, args)
	end

	return output
end

sm.maps = {}
sm.maps.SaveGame = {
	{"difficulty", "difficulty", sm.map_difficulty},
	{"selectedHero", "heroes.selected", {
		{0},
		{1, "hero_gerald"},
		{2, "hero_alleria"},
		{5, "hero_malik"},
		{3, "hero_bolin"},
		{4, "hero_magnus"},
		{6, "hero_ignus"},
		{7, "hero_denas"},
		{8, "hero_elora"},
		{9, "hero_ingvar"},
		{12, "hero_hacksaw"},
		{11, "hero_oni"},
		{10, "hero_thor"}
	}},
	{"archersUpLevel", "upgrades.archers"},
	{"barracksUpLevel", "upgrades.barracks"},
	{"engineersUpLevel", "upgrades.engineers"},
	{"magesUpLevel", "upgrades.mages"},
	{"rainUpLevel", "upgrades.rain"},
	{"reinforcementLevel", "upgrades.reinforcements"},
	{"acdc", "achievements.ACDC"},
	{"acorn", "achievements.DEFEAT_ACORN"},
	{"armaggedon", "achievements.ARMAGGEDON"},
	{"armyOfOne", "achievements.ARMY_OF_ONE"},
	{"axeRainer", "achievements.AXE_RAINER"},
	{"barbarianRush", "achievements.BARBARIAN_RUSH"},
	{"bloodlust", "achievements.BLOODLUST"},
	{"cannonFodder", "achievements.CANNON_FODDER"},
	{"clusterRain", "achievements.CLUSTERED"},
	{"coolRunning", "achievements.DEFEAT_COOL_RUNNING"},
	{"daring", "achievements.DARING"},
	{"deathFromAbove", "achievements.DEATH_FROM_ABOVE"},
	{"dieHard", "achievements.DIE_HARD"},
	{"dineInHell", "achievements.WE_DINE_IN_HELL"},
	{"dustToDust", "achievements.DUST_TO_DUST"},
	{"earn15Stars", "achievements.EARN15_STARS"},
	{"earn30Stars", "achievements.EARN30_STARS"},
	{"earn45Stars", "achievements.EARN45_STARS"},
	{"easyTowerBuilder", "achievements.EASY_TOWER_BUILDER"},
	{"elementalist", "achievements.ELEMENTALIST"},
	{"energyNetwork", "achievements.ENERGY_NETWORK"},
	{"entangled", "achievements.ENTANGLED"},
	{"fearless", "achievements.FEARLESS"},
	{"firstBlood", "achievements.FIRST_BLOOD"},
	{"fisherman", "achievements.CATCH_A_FISH"},
	{"freeFredo", "achievements.FREE_FREDO"},
	{"giJoe", "achievements.GI_JOE"},
	{"goc", "achievements.GOC"},
	{"greatDefender", "achievements.GREAT_DEFENDER"},
	{"greatDefenderHeroic", "achievements.HEROIC_DEFENDER"},
	{"greatDefenderIron", "achievements.IRON_DEFENDER"},
	{"hardTowerBuilder", "achievements.HARD_TOWER_BUILDER"},
	{"henderson", "achievements.HENDERSON"},
	{"holyChorus", "achievements.HOLY_CHORUS"},
	{"impatient", "achievements.IMPATIENT"},
	{"imperialSaviour", "achievements.IMPERIAL_SAVIOUR"},
	{"indecisive", "achievements.INDECISIVE"},
	{"killDemon", "achievements.HELL_O"},
	{"killEndBoss", "achievements.DEFEAT_END_BOSS"},
	{"killGulThak", "achievements.DEFEAT_GULTHAK_BOSS"},
	{"killJuggernaut", "achievements.DEFEAT_JUGGERNAUT"},
	{"killKingping", "achievements.DEFEAT_KINGPING_BOSS"},
	{"killMountainBoss", "achievements.DEFEAT_MOUNTAIN_BOSS"},
	{"killMushroom", "achievements.DEFEAT_MUSHROOM"},
	{"killSarelgaz", "achievements.DEFEAT_SARELGAZ"},
	{"killTreant", "achievements.DEFEAT_TREANT_BOSS"},
	{"killTrollBoss", "achievements.DEFEAT_TROLL_BOSS"},
	{"levelHeroMax", "achievements.HERO_HARD"},
	{"levelHeroMedium", "achievements.HERO_MEDIUM"},
	{"mageBeamMeUp", "achievements.BEAM_ME_UP"},
	{"maxElves", "achievements.MAX_ELVES"},
	{"medic", "achievements.MEDIC"},
	{"mediumTowerBuilder", "achievements.MEDIUM_TOWER_BUILDER"},
	{"multiKill", "achievements.MULTIKILL"},
	{"mushroom", "achievements.SUPER_MUSHROOM"},
	{"nessie", "achievements.NESSIE"},
	{"nevermore", "achievements.NEVERMORE"},
	{"ratatouille", "achievements.RATATOUILLE"},
	{"realEstate", "achievements.REAL_STATE"},
	{"rocketeer", "achievements.ROCKETEER"},
	{"sheepKiller", "achievements.SHEEP_KILLER"},
	{"shepard", "achievements.SHEPARD"},
	{"slayer", "achievements.SLAYER"},
	{"sniper", "achievements.SNIPER"},
	{"specialization", "achievements.SPECIALIZATION"},
	{"splinter", "achievements.SPLINTER"},
	{"spore", "achievements.SPORE"},
	{"stillCountsAsOne", "achievements.STILL_COUNTS_AS_ONE"},
	{"sunburner", "achievements.SUN_BURNER"},
	{"tactician", "achievements.TACTICIAN"},
	{"towerUpgradeLevel3", "achievements.UPGRADE_LEVEL3"},
	{"toxicity", "achievements.TOXICITY"},
	{"whatsThat", "achievements.WHATS_THAT"},
	{"acdcKills", "achievement_counters.ACDC"},
	{"archersTowerUpgradeLevel3", "achievement_counters.UPGRADE_LEVEL3", sm.set_flag, 1},
	{"armyOfOneCounter", "achievement_counters.ARMY_OF_ONE"},
	{"axesFire", "achievement_counters.AXE_RAINER"},
	{"buildArcanes", "achievement_counters.SPECIALIZATION", sm.set_flag, 1},
	{"buildBarbarians", "achievement_counters.SPECIALIZATION", sm.set_flag, 128},
	{"buildBfg", "achievement_counters.SPECIALIZATION", sm.set_flag, 4},
	{"buildMusketeers", "achievement_counters.SPECIALIZATION", sm.set_flag, 32},
	{"buildPaladins", "achievement_counters.SPECIALIZATION", sm.set_flag, 64},
	{"buildRangers", "achievement_counters.SPECIALIZATION", sm.set_flag, 16},
	{"buildSorcerers", "achievement_counters.SPECIALIZATION", sm.set_flag, 2},
	{"buildTesla", "achievement_counters.SPECIALIZATION", sm.set_flag, 8},
	{"clustersFire", "achievement_counters.CLUSTERED"},
	{"coolRunningKilledTrolls", "achievement_counters.DEFEAT_COOL_RUNNING"},
	{"desintegrateKills", "achievement_counters.DUST_TO_DUST"},
	{"dineInHellCounter", "achievement_counters.WE_DINE_IN_HELL"},
	{"earlyWavesCalled", "achievement_counters.IMPATIENT"},
	{"engineersTowerUpgradeLevel3", "achievement_counters.UPGRADE_LEVEL3", sm.set_flag, 4},
	{"fireballKills", "achievement_counters.DEATH_FROM_ABOVE"},
	{"holyChorusCount", "achievement_counters.HOLY_CHORUS"},
	{"killedEnemies", "achievement_counters.FIRST_BLOOD"},
	{"killedEnemies", "achievement_counters.BLOODLUST"},
	{"killedEnemies", "achievement_counters.SLAYER"},
	{"killedEnemies", "achievement_counters.MULTIKILL"},
	{"mageBeamMeUpEnemies", "achievement_counters.BEAM_ME_UP"},
	{"magesTowerUpgradeLevel3", "achievement_counters.UPGRADE_LEVEL3", sm.set_flag, 8},
	{"missilesFire", "achievement_counters.ROCKETEER"},
	{"notificationEnemy", "achievement_counters.WHATS_THAT"},
	{"paladinHeals", "achievement_counters.MEDIC"},
	{"poisonKills", "achievement_counters.TOXICITY"},
	{"polymorphKills", "achievement_counters.SHEPARD"},
	{"rallyChanges", "achievement_counters.TACTICIAN"},
	{"sellTowers", "achievement_counters.REAL_STATE"},
	{"sheepsKilled", "achievement_counters.SHEEP_KILLER"},
	{"sniperKills", "achievement_counters.SNIPER"},
	{"soldiersKilled", "achievement_counters.CANNON_FODDER"},
	{"soldiersRegeneration", "achievement_counters.DIE_HARD"},
	{"soldiersTowerUpgradeLevel3", "achievement_counters.UPGRADE_LEVEL3", sm.set_flag, 2},
	{"soldiersTrained", "achievement_counters.GI_JOE"},
	{"sporeCount", "achievement_counters.SPORE"},
	{"stillCountsAsOneCount", "achievement_counters.STILL_COUNTS_AS_ONE"},
	{"sunrayShots", "achievement_counters.SUN_BURNER"},
	{"thornsEnemies", "achievement_counters.ENTANGLED"},
	{"towerBuilded", "achievement_counters.EASY_TOWER_BUILDER"},
	{"towerBuilded", "achievement_counters.MEDIUM_TOWER_BUILDER"},
	{"towerBuilded", "achievement_counters.HARD_TOWER_BUILDER"},
	{"wereratKillCount", "achievement_counters.RATATOUILLE"},
	{"challengeTipShowed", "seen.TIP_UPGRADES"},
	{"notificationEnemyAbomination", "seen.enemy_abomination"},
	{"notificationEnemyBandit", "seen.enemy_bandit"},
	{"notificationEnemyBrigand", "seen.enemy_brigand"},
	{"notificationEnemyCerberus", "seen.enemy_demon_cerberus"},
	{"notificationEnemyDarkKnight", "seen.enemy_dark_knight"},
	{"notificationEnemyDarkSlayer", "seen.enemy_slayer"},
	{"notificationEnemyDemon", "seen.enemy_demon"},
	{"notificationEnemyDemonImp", "seen.enemy_demon_imp"},
	{"notificationEnemyDemonMage", "seen.enemy_demon_mage"},
	{"notificationEnemyDemonWolf", "seen.enemy_demon_wolf"},
	{"notificationEnemyFallenKnight", "seen.enemy_fallen_knight"},
	{"notificationEnemyFatOrc", "seen.enemy_fat_orc"},
	{"notificationEnemyFlareon", "seen.enemy_demon_flareon"},
	{"notificationEnemyForestTroll", "seen.enemy_forest_troll"},
	{"notificationEnemyGargoyle", "seen.enemy_gargoyle"},
	{"notificationEnemyGiantRat", "seen.enemy_giant_rat"},
	{"notificationEnemyGoblin", "seen.enemy_goblin"},
	{"notificationEnemyGoblinZapper", "seen.enemy_goblin_zapper"},
	{"notificationEnemyGolemHead", "seen.enemy_golem_head"},
	{"notificationEnemyGulaemon", "seen.enemy_demon_gulaemon"},
	{"notificationEnemyLavaElemental", "seen.enemy_lava_elemental"},
	{"notificationEnemyLegion", "seen.enemy_demon_legion"},
	{"notificationEnemyLycan", "seen.enemy_lycan"},
	{"notificationEnemyMarauder", "seen.enemy_marauder"},
	{"notificationEnemyNecromancer", "seen.enemy_necromancer"},
	{"notificationEnemyOgre", "seen.enemy_ogre"},
	{"notificationEnemyOrcArmored", "seen.enemy_orc_armored"},
	{"notificationEnemyOrcRider", "seen.enemy_orc_rider"},
	{"notificationEnemyPillager", "seen.enemy_pillager"},
	{"notificationEnemyRaider", "seen.enemy_raider"},
	{"notificationEnemyRocketeer", "seen.enemy_rocketeer"},
	{"notificationEnemyRottenLesser", "seen.enemy_rotten_lesser"},
	{"notificationEnemyRottenSpider", "seen.enemy_spider_rotten"},
	{"notificationEnemyRottenTree", "seen.enemy_rotten_tree"},
	{"notificationEnemySarelgazSmall", "seen.enemy_sarelgaz_small"},
	{"notificationEnemyShadowArcher", "seen.enemy_shadow_archer"},
	{"notificationEnemyShaman", "seen.enemy_shaman"},
	{"notificationEnemySkeletor", "seen.enemy_skeleton"},
	{"notificationEnemySkeletorBig", "seen.enemy_skeleton_big"},
	{"notificationEnemySmallWolf", "seen.enemy_wolf_small"},
	{"notificationEnemySpectralKnight", "seen.enemy_spectral_knight"},
	{"notificationEnemySpider", "seen.enemy_spider_big"},
	{"notificationEnemySpiderSmall", "seen.enemy_spider_small"},
	{"notificationEnemySwampThing", "seen.enemy_swamp_thing"},
	{"notificationEnemyTroll", "seen.enemy_troll"},
	{"notificationEnemyTrollAxeThrower", "seen.enemy_troll_axe_thrower"},
	{"notificationEnemyTrollBrute", "seen.enemy_troll_brute"},
	{"notificationEnemyTrollChieftain", "seen.enemy_troll_chieftain"},
	{"notificationEnemyTrollSkater", "seen.enemy_troll_skater"},
	{"notificationEnemyWererat", "seen.enemy_wererat"},
	{"notificationEnemyWerewolf", "seen.enemy_werewolf"},
	{"notificationEnemyWhiteWolf", "seen.enemy_whitewolf"},
	{"notificationEnemyWitch", "seen.enemy_witch"},
	{"notificationEnemyWolf", "seen.enemy_wolf"},
	{"notificationEnemyYeti", "seen.enemy_yeti"},
	{"notificationEnemyZombie", "seen.enemy_zombie"},
	{"notificationEnemyZombieBlackburn", "seen.enemy_halloween_zombie"},
	{"notificationTipHeroes", "seen.TIP_HEROES"},
	{"notificationEnemyBlackburn", "seen.eb_blackburn"},
	{"notificationEnemyBossBandit", "seen.eb_kingpin"},
	{"notificationEnemyBossDemonMoloch", "seen.eb_moloch"},
	{"notificationEnemyBossMyconid", "seen.eb_myconid"},
	{"notificationEnemyBossTreant", "seen.eb_greenmuck"},
	{"notificationEnemyGulThak", "seen.eb_gulthak"},
	{"notificationEnemyJuggernaut", "seen.eb_juggernaut"},
	{"notificationEnemySarelgaz", "seen.eb_sarelgaz"},
	{"notificationEnemyTrollBoss", "seen.eb_ulgukhai"},
	{"notificationEnemyVeznan", "seen.eb_veznan"},
	{"notificationEnemyYetiBoss", "seen.eb_jt"},
	{"notificationTowerArchersLevel2", "seen.tower_archer_2"},
	{"notificationTowerArchersLevel3", "seen.tower_archer_3"},
	{"notificationTowerArchersMusketeer", "seen.tower_musketeer"},
	{"notificationTowerArchersRanger", "seen.tower_ranger"},
	{"notificationTowerEngineersBfg", "seen.tower_bfg"},
	{"notificationTowerEngineersLevel2", "seen.tower_engineer_2"},
	{"notificationTowerEngineersLevel3", "seen.tower_engineer_3"},
	{"notificationTowerEngineersTesla", "seen.tower_tesla"},
	{"notificationTowerMagesArcane", "seen.tower_arcane_wizard"},
	{"notificationTowerMagesLevel2", "seen.tower_mage_2"},
	{"notificationTowerMagesLevel3", "seen.tower_mage_3"},
	{"notificationTowerMagesSorcerer", "seen.tower_sorcerer"},
	{"notificationTowerSoldiersBarbarian", "seen.tower_barbarian"},
	{"notificationTowerSoldiersLevel2", "seen.tower_barrack_2"},
	{"notificationTowerSoldiersLevel3", "seen.tower_barrack_3"},
	{"notificationTowerSoldiersPaladin", "seen.tower_paladin"}
}

function sm:do_row(src_o, dst_o, row)
	local src_k, dst_k, vmap, vmap_args = unpack(row)
	local sv = src_o[src_k]
	local d_parts = string.split(string.gsub(string.gsub(dst_k, "]", ""), "%[", "."), ".")

	if not d_parts or #d_parts == 0 then
		log.error("error splitting dest key %s", dst_k)

		return
	end

	local t = dst_o

	for i = 1, #d_parts - 1 do
		local v = d_parts[i]
		local vn = tonumber(v)

		log.paranoid("  creating table tree key %s", v)

		if vn then
			if not t[vn] then
				t[vn] = {}
			end

			t = t[vn]
		else
			if not t[v] then
				t[v] = {}
			end

			t = t[v]
		end
	end

	local last_k = d_parts[#d_parts]
	local dv = sv

	if vmap and type(vmap) == "table" then
		for _, item in pairs(vmap) do
			if item[1] == sv then
				dv = item[2]

				log.paranoid("   mapped %s=%s to %s=%s", src_k, sv, dst_k, dv)

				break
			end
		end
	elseif vmap and type(vmap) == "function" then
		dv = vmap(sv, t[last_k], vmap_args)

		log.paranoid("   function mapped %s=%s to %s=%s", src_k, sv, dst_k, dv)
	end

	t[last_k] = dv
end

function sm:parse(buf)
	local t = bf:parse(buf)

	if not t then
		return nil
	end

	local o = {}
	local rsg, sg, k, v

	for k, v in pairs(t.object_index) do
		if v.Name and v.Name == "SaveGame" then
			rsg = v
		end
	end

	if not rsg then
		log.error("Could not find SaveGame object")

		return nil, "SaveGame object not found"
	end

	local sg = bf:flatten(t, rsg)

	if not sg.slotUsed then
		log.info("SaveGame is empty. Skipping import")

		return nil, "empty slot"
	end

	for _, row in pairs(sm.maps.SaveGame) do
		self:do_row(sg, o, row)
	end

	local levels = {}

	for i, v in ipairs(sg.campaignLevels) do
		local l = {}

		if v.campaignWin then
			l.stars = v.starsWon
		end

		if v.campaignWin then
			l[1] = sm.map_difficulty(v.campaignDifficulty)
		end

		if v.heroicModeWin then
			l[2] = sm.map_difficulty(v.heroicDifficulty)
		end

		if v.ironModeWin then
			l[3] = sm.map_difficulty(v.ironDifficulty)
		end

		if v.status ~= 0 then
			levels[i] = l
		end
	end

	o.levels = levels

	return o
end

if _TESTING then
	log.level = log.DEBUG_LEVEL

	local args = {...}
	local fn = args[1]

	print(fn)

	local f = io.open(fn, "r")
	local fs = f:read("*a")

	f:close()

	local o = sm:parse(fs)

	require("lib.klua.dump")
	log.error("table: %s", getfulldump(o))
else
	return sm
end
