-- chunkname: @./all/storage_mappings.lua
local log = require("lib.klua.log"):new("storage_mappings")

require("lib.klua.string")

local bit = require("bit")
local GS = require("game_settings")
local sm = {}

function sm:append_pp_token(src, dst)
	for _, row in pairs(self.pp_token) do
		self:do_row(row, src, dst)
	end
end

function sm:append_global(src, dst)
	for _, row in pairs(self.global) do
		self:do_row(row, src, dst)
	end
end

function sm:append_slot(src, dst)
	for _, row in pairs(self.slot_common) do
		self:do_row(row, src, dst)
	end

	local items = {"slot_" .. KR_GAME, "slot_" .. KR_GAME .. "_endless"}

	for _, item in pairs(items) do
		for _, row in pairs(self[item]) do
			self:do_row(row, src, dst)
		end
	end
end

function sm:do_row(row, src, dst)
	local src_k, dst_k, fn, fn_args = unpack(row)

	if not src_k or not dst_k then
		log.error("src_k or dst_k are nil")

		return
	end

	local s_expr = "return src." .. src_k
	local fs, err = loadstring(s_expr)

	if not fs then
		log.error("error: parsing src_k. err:%s src_k:%s", err, src_k)

		return
	end

	local env = {}

	env.src = src

	setfenv(fs, env)

	local ok, s_val = pcall(fs)

	if not ok then
		log.error("error evaluating source key %s expresion %s", src_k, s_expr)

		return
	end

	if not s_val then
		log.debug("source key %s is nil, skipping.", src_k)

		return
	end

	local d_parts = string.split(string.gsub(string.gsub(dst_k, "]", ""), "%[", "."), ".")

	if not d_parts or #d_parts == 0 then
		log.error("error splitting dest key %s", dst_k)

		return
	end

	local t = dst

	for i = 1, #d_parts - 1 do
		local v = d_parts[i]
		local vn = tonumber(v)

		log.debug("  creating table tree key %s", v)

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
	local d_val

	if fn then
		d_val = fn(s_val, t[last_k], fn_args)
	else
		d_val = s_val
	end

	t[last_k] = d_val

	log.debug("  setting last table tree value %s = %s (source val:%s)", last_k, d_val, s_val)
end

function sm.parse_levels(input, output, args)
	if not output or type(output) ~= "table" then
		output = {}
	end

	for i = 1, GS.last_level do
		local l = input[i]

		if not l or l[12] < 1 then
			output[i] = nil
		elseif l[12] < 3 then
			output[i] = {}
		else
			local o = {}

			if l[1] then
				o[1] = l[6] + 1
			end

			if l[2] then
				o[2] = l[7] + 1
			end

			if l[3] then
				o[3] = l[8] + 1
			end

			if l[9] and l[9] > 0 then
				o.stars = l[9]
			end

			if o[1] and not o.stars then
				o.stars = 1
			end

			if #o > 0 then
				output[i] = o
			end
		end
	end

	return output
end

function sm.parse_endless_levels(input, output, args)
	if not output or type(output) ~= "table" then
		output = {}
	end

	local BASE_IDX = 80

	for i = 1, GS.endless_levels_count do
		local l = input[i]

		if not l or l[1] < 1 then
			output[BASE_IDX + i] = nil
		else
			output[BASE_IDX + i] = {}
		end
	end

	return output
end

function sm.set_flag(input, output, args)
	output = output or 0

	if input and type(input) == "number" and input > 0 then
		output = bit.bor(output, args)
	end

	return output
end

function sm.bool(input, output, args)
	if not input then
		return nil
	elseif type(input) == "boolean" then
		return input
	elseif not tonumber(input) or tonumber(input) == 0 then
		return nil
	else
		return true
	end
end

function sm.add(input, output, args)
	return input + args
end

function sm.table_append(input, output, args)
	output = output or {}

	if input then
		table.insert(output, args)
	end

	return output
end

function sm.hero_code_to_name(input, output, args)
	local map = {
		"hero_gerald",
		"hero_alleria",
		"hero_bolin",
		"hero_magnus",
		"hero_malik",
		"hero_ignus",
		"hero_denas",
		"hero_elora",
		"hero_ingvar",
		"hero_oni",
		"hero_hacksaw",
		"hero_thor",
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		"hero_alric",
		"hero_mirage",
		"hero_pirate",
		"hero_priest",
		"hero_beastmaster",
		"hero_giant",
		"hero_wizard",
		"hero_alien",
		"hero_dragon",
		"hero_crab",
		"hero_monk",
		"hero_van_helsing",
		"hero_dracolich",
		"hero_voodoo_witch",
		"hero_minotaur",
		"hero_monkey_god",
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		"hero_elves_archer",
		"hero_arivan",
		"hero_catha",
		"hero_regson",
		"hero_elves_denas",
		"hero_bravebark",
		"hero_faustus",
		"hero_veznan",
		nil,
		nil,
		nil,
		"hero_xin",
		"hero_rag",
		"hero_phoenix",
		nil,
		"hero_durax",
		"hero_lynn",
		"hero_bruce",
		"hero_lilith",
		"hero_wilbur"
	}

	return map[input]
end

sm.pp_token = {{"deviceId", "privacy_policy_token.deviceId"}, {"bundleId", "privacy_policy_token.bundleId"}, {"age", "privacy_policy_token.age"}, {"birthdate", "privacy_policy_token.birthdate"}, {"dateOfConsent", "privacy_policy_token.dateOfConsent"}}
sm.global = {
	{"in_apps.hasHeroReinforcement", "purchased_heroes", sm.table_append, "hero_gerald"},
	{"in_apps.hasHeroDwarf", "purchased_heroes", sm.table_append, "hero_bolin"},
	{"in_apps.hasHeroMage", "purchased_heroes", sm.table_append, "hero_magnus"},
	{"in_apps.hasHeroFire", "purchased_heroes", sm.table_append, "hero_ignus"},
	{"in_apps.hasHeroDenas", "purchased_heroes", sm.table_append, "hero_denas"},
	{"in_apps.hasHeroFrost", "purchased_heroes", sm.table_append, "hero_elora"},
	{"in_apps.hasHeroViking", "purchased_heroes", sm.table_append, "hero_ingvar"},
	{"in_apps.hasHeroSamurai", "purchased_heroes", sm.table_append, "hero_oni"},
	{"in_apps.hasHeroRobot", "purchased_heroes", sm.table_append, "hero_hacksaw"},
	{"in_apps.hasHeroThor", "purchased_heroes", sm.table_append, "hero_thor"},
	{"in_apps.hasHeroAlien", "purchased_heroes", sm.table_append, "hero_alien"},
	{"in_apps.hasHeroCrab", "purchased_heroes", sm.table_append, "hero_crab"},
	{"in_apps.hasHeroDracolich", "purchased_heroes", sm.table_append, "hero_dracolich"},
	{"in_apps.hasHeroDragon", "purchased_heroes", sm.table_append, "hero_dragon"},
	{"in_apps.hasHeroGolem", "purchased_heroes", sm.table_append, "hero_golem"},
	{"in_apps.hasHeroMinotaur", "purchased_heroes", sm.table_append, "hero_minotaur"},
	{"in_apps.hasHeroMonk", "purchased_heroes", sm.table_append, "hero_monk"},
	{"in_apps.hasHeroMonkeyGod", "purchased_heroes", sm.table_append, "hero_monkey_god"},
	{"in_apps.hasHeroPirate", "purchased_heroes", sm.table_append, "hero_pirate"},
	{"in_apps.hasHeroPriest", "purchased_heroes", sm.table_append, "hero_priest"},
	{"in_apps.hasHeroVanHelsing", "purchased_heroes", sm.table_append, "hero_van_helsing"},
	{"in_apps.hasHeroWizard", "purchased_heroes", sm.table_append, "hero_wizard"},
	{"in_apps.elves_hero_eldritch", "purchased_heroes", sm.table_append, "hero_regson"},
	{"in_apps.elves_hero_panda", "purchased_heroes", sm.table_append, "hero_xin"},
	{"in_apps.elves_hero_veznan", "purchased_heroes", sm.table_append, "hero_veznan"},
	{"in_apps.elves_hero_denas", "purchased_heroes", sm.table_append, "hero_elves_denas"},
	{"in_apps.elves_hero_forest_elemental", "purchased_heroes", sm.table_append, "hero_bravebark"},
	{"in_apps.elves_hero_faustus", "purchased_heroes", sm.table_append, "hero_faustus"},
	{"in_apps.elves_hero_phoenix", "purchased_heroes", sm.table_append, "hero_phoenix"},
	{"in_apps.elves_hero_durax", "purchased_heroes", sm.table_append, "hero_durax"},
	{"in_apps.elves_hero_lynn", "purchased_heroes", sm.table_append, "hero_lynn"},
	{"in_apps.elves_hero_bruce", "purchased_heroes", sm.table_append, "hero_bruce"},
	{"in_apps.elves_hero_gyro", "purchased_heroes", sm.table_append, "hero_wilbur"}
}
sm.slot_common = {
	{"campaign_levels", "levels", sm.parse_levels},
	{"endless_levels", "levels", sm.parse_endless_levels},
	{"heroes_selected", "heroes.selected", sm.hero_code_to_name},
	{"selectedDifficulty", "difficulty", sm.add, 1},
	{"backPack.currentGems", "gems"},
	{"backPack.currentAtomicBombs", "bag.atomic_bomb"},
	{"backPack.currentAtomicFreeze", "bag.atomic_freeze"},
	{"backPack.currentDynamites", "bag.dynamite"},
	{"backPack.currentExtraGold", "bag.coins"},
	{"backPack.currentFreeze", "bag.freeze"},
	{"backPack.currentHearts", "bag.hearts"},
	{"backPack.currentWrathOfElynia", "bag.wrath_of_elynia"},
	{"backPack.currentTeleportScrolls", "bag.teleport_scroll"},
	{"backPack.currentHornsHeroism", "bag.horn_heroism"},
	{"backPack.currentTimewarp", "bag.gem_timewarp"},
	{"backPack.currentRodDragonFire", "bag.rod_dragon_fire"},
	{"backPack.currentHandOfMidas", "bag.hand_midas"},
	{"upgrades.archersUpLevel", "upgrades.archers"},
	{"upgrades.barracksUpLevel", "upgrades.barracks"},
	{"upgrades.engineersUpLevel", KR_GAME == "kr3" and "upgrades.rocks" or "upgrades.engineers"},
	{"upgrades.magesUpLevel", "upgrades.mages"},
	{"upgrades.rainUpLevel", KR_GAME == "kr3" and "upgrades.thunder" or "upgrades.rain"},
	{"upgrades.reinforcementLevel", "upgrades.reinforcements"},
	{"inAppHelpShow", "seen.shop_help"},
	{"heroRoomFirstTimeSelect", "seen.hero_room_sel_help"},
	{"heroRoomHelpShown", "seen.hero_room_help"},
	{"alreadyShowedHeroLevelUpBalloon", "seen.map_balloon_level_up_view"},
	{"endlessStageUnlockedShown", "seen.map_balloon_endless_view"},
	{"challengeTipShowedNew", "seen.TIP_UPGRADES"},
	{"endlessHelpShowed", "seen.TIP_SURVIVAL"}
}
sm.slot_kr1 = {
	{"achievements.armyOfOneCounter", "achievement_counters.ARMY_OF_ONE"},
	{"achievements.dineInHellCounter", "achievement_counters.WE_DINE_IN_HELL"},
	{"achievements.holyChorusCount", "achievement_counters.HOLY_CHORUS"},
	{"achievements.sporeCount", "achievement_counters.SPORE"},
	{"achievements.stillCountsAsOneCount", "achievement_counters.STILL_COUNTS_AS_ONE"},
	{"achievements.wereratKillCount", "achievement_counters.RATATOUILLE"},
	{"achievements.acdcKills", "achievement_counters.ACDC"},
	{"achievements.mageBeamMeUpEnemies", "achievement_counters.BEAM_ME_UP"},
	{"achievements.clustersFire", "achievement_counters.CLUSTERED"},
	{"achievements.coolRunningKilledTrolls", "achievement_counters.DEFEAT_COOL_RUNNING"},
	{"achievements.desintegrateKills", "achievement_counters.DUST_TO_DUST"},
	{"achievements.earlyWavesCalled", "achievement_counters.DARING"},
	{"achievements.fireballKills", "achievement_counters.DEATH_FROM_ABOVE"},
	{"achievements.missilesFire", "achievement_counters.ROCKETEER"},
	{"achievements.paladinHeals", "achievement_counters.MEDIC"},
	{"achievements.poisonKills", "achievement_counters.TOXICITY"},
	{"achievements.polymorphKills", "achievement_counters.SHEPARD"},
	{"achievements.rallyChanges", "achievement_counters.TACTICIAN"},
	{"achievements.sellTowers", "achievement_counters.REAL_STATE"},
	{"achievements.sheepsKilled", "achievement_counters.SHEEP_KILLER"},
	{"achievements.sniperKills", "achievement_counters.SNIPER"},
	{"achievements.soldiersKilled", "achievement_counters.CANNON_FODDER"},
	{"achievements.soldiersRegeneration", "achievement_counters.DIE_HARD"},
	{"achievements.soldiersTrained", "achievement_counters.GI_JOE"},
	{"achievements.sunrayShots", "achievement_counters.SUN_BURNER"},
	{"achievements.thornsEnemies", "achievement_counters.ENTANGLED"},
	{"achievements.axesFire", "achievement_counters.AXE_RAINER"},
	{"achievements.archersTowerUpgradeLevel3", "achievement_counters.UPGRADE_LEVEL3", sm.set_flag, 1},
	{"achievements.soldiersTowerUpgradeLevel3", "achievement_counters.UPGRADE_LEVEL3", sm.set_flag, 2},
	{"achievements.engineersTowerUpgradeLevel3", "achievement_counters.UPGRADE_LEVEL3", sm.set_flag, 4},
	{"achievements.magesTowerUpgradeLevel3", "achievement_counters.UPGRADE_LEVEL3", sm.set_flag, 8},
	{"achievements.buildArcanes", "achievement_counters.SPECIALIZATION", sm.set_flag, 1},
	{"achievements.buildSorcerers", "achievement_counters.SPECIALIZATION", sm.set_flag, 2},
	{"achievements.buildBfg", "achievement_counters.SPECIALIZATION", sm.set_flag, 4},
	{"achievements.buildTesla", "achievement_counters.SPECIALIZATION", sm.set_flag, 8},
	{"achievements.buildRangers", "achievement_counters.SPECIALIZATION", sm.set_flag, 16},
	{"achievements.buildMusketeers", "achievement_counters.SPECIALIZATION", sm.set_flag, 32},
	{"achievements.buildPaladins", "achievement_counters.SPECIALIZATION", sm.set_flag, 64},
	{"achievements.buildBarbarians", "achievement_counters.SPECIALIZATION", sm.set_flag, 128},
	{"achievements.killedEnemies", "achievement_counters.BLOODLUST"},
	{"achievements.killedEnemies", "achievement_counters.SLAYER"},
	{"achievements.killedEnemies", "achievement_counters.MULTIKILL"},
	{"achievements.towerBuilded", "achievement_counters.EASY_TOWER_BUILDER"},
	{"achievements.towerBuilded", "achievement_counters.MEDIC_TOWER_BUILDER"},
	{"achievements.towerBuilded", "achievement_counters.HARD_TOWER_BUILDER"},
	{"achievements.acdc", "achievements.ACDC", sm.bool},
	{"achievements.acorn", "achievements.DEFEAT_ACORN", sm.bool},
	{"achievements.armaggedon", "achievements.ARMAGGEDON", sm.bool},
	{"achievements.armyOfOne", "achievements.ARMY_OF_ONE", sm.bool},
	{"achievements.axeRainer", "achievements.AXE_RAINER", sm.bool},
	{"achievements.barbarianRush", "achievements.BARBARIAN_RUSH", sm.bool},
	{"achievements.mageBeamMeUp", "achievements.BEAM_ME_UP", sm.bool},
	{"achievements.bloodlust", "achievements.BLOODLUST", sm.bool},
	{"achievements.cannonFodder", "achievements.CANNON_FODDER", sm.bool},
	{"achievements.fisherman", "achievements.CATCH_A_FISH", sm.bool},
	{"achievements.clusterRain", "achievements.CLUSTERED", sm.bool},
	{"achievements.daring", "achievements.DARING", sm.bool},
	{"achievements.deathFromAbove", "achievements.DEATH_FROM_ABOVE", sm.bool},
	{"achievements.completeHardMode", "achievements.DEFEAT_COMPLETE_HARD", sm.bool},
	{"achievements.coolRunning", "achievements.DEFEAT_COOL_RUNNING", sm.bool},
	{"achievements.killEndBoss", "achievements.DEFEAT_END_BOSS", sm.bool},
	{"achievements.killGulThak", "achievements.DEFEAT_GULTHAK_BOSS", sm.bool},
	{"achievements.killJuggernaut", "achievements.DEFEAT_JUGGERNAUT", sm.bool},
	{"achievements.killKingping", "achievements.DEFEAT_KINGPING_BOSS", sm.bool},
	{"achievements.killMountainBoss", "achievements.DEFEAT_MOUNTAIN_BOSS", sm.bool},
	{"achievements.killMushroom", "achievements.SUPER_MUSHROOM", sm.bool},
	{"achievements.killSarelgaz", "achievements.DEFEAT_SARELGAZ", sm.bool},
	{"achievements.killTreant", "achievements.DEFEAT_TREANT_BOSS", sm.bool},
	{"achievements.killTrollBoss", "achievements.DEFEAT_TROLL_BOSS", sm.bool},
	{"achievements.dieHard", "achievements.DIE_HARD", sm.bool},
	{"achievements.dustToDust", "achievements.DUST_TO_DUST", sm.bool},
	{"achievements.earn15Stars", "achievements.EARN15_STARS", sm.bool},
	{"achievements.earn30Stars", "achievements.EARN30_STARS", sm.bool},
	{"achievements.earn45Stars", "achievements.EARN45_STARS", sm.bool},
	{"achievements.easyTowerBuilder", "achievements.EASY_TOWER_BUILDER", sm.bool},
	{"achievements.elementalist", "achievements.ELEMENTALIST", sm.bool},
	{"achievements.energyNetwork", "achievements.ENERGY_NETWORK", sm.bool},
	{"achievements.entangled", "achievements.ENTANGLED", sm.bool},
	{"achievements.fearless", "achievements.FEARLESS", sm.bool},
	{"achievements.firstBlood", "achievements.FIRST_BLOOD", sm.bool},
	{"achievements.freeFredo", "achievements.FREE_FREDO", sm.bool},
	{"achievements.giJoe", "achievements.GI_JOE", sm.bool},
	{"achievements.goc", "achievements.GOC", sm.bool},
	{"achievements.greatDefender", "achievements.GREAT_DEFENDER", sm.bool},
	{"achievements.hardTowerBuilder", "achievements.HARD_TOWER_BUILDER", sm.bool},
	{"achievements.killDemon", "achievements.HELL_O", sm.bool},
	{"achievements.henderson", "achievements.HENDERSON", sm.bool},
	{"achievements.greatDefenderHeroic", "achievements.HEROIC_DEFENDER", sm.bool},
	{"achievements.levelHeroMax", "achievements.HERO_HARD", sm.bool},
	{"achievements.levelHeroMedium", "achievements.HERO_MEDIUM", sm.bool},
	{"achievements.holyChorus", "achievements.HOLY_CHORUS", sm.bool},
	{"achievements.impatient", "achievements.IMPATIENT", sm.bool},
	{"achievements.imperialSaviour", "achievements.IMPERIAL_SAVIOUR", sm.bool},
	{"achievements.indecisive", "achievements.INDECISIVE", sm.bool},
	{"achievements.greatDefenderIron", "achievements.IRON_DEFENDER", sm.bool},
	{"achievements.maxElves", "achievements.MAX_ELVES", sm.bool},
	{"achievements.medic", "achievements.MEDIC", sm.bool},
	{"achievements.mediumTowerBuilder", "achievements.MEDIUM_TOWER_BUILDER", sm.bool},
	{"achievements.multiKill", "achievements.MULTIKILL", sm.bool},
	{"achievements.nessie", "achievements.NESSIE", sm.bool},
	{"achievements.nevermore", "achievements.NEVERMORE", sm.bool},
	{"achievements.ratatouille", "achievements.RATATOUILLE", sm.bool},
	{"achievements.realEstate", "achievements.REAL_STATE", sm.bool},
	{"achievements.rocketeer", "achievements.ROCKETEER", sm.bool},
	{"achievements.sheepKiller", "achievements.SHEEP_KILLER", sm.bool},
	{"achievements.shepard", "achievements.SHEPARD", sm.bool},
	{"achievements.slayer", "achievements.SLAYER", sm.bool},
	{"achievements.sniper", "achievements.SNIPER", sm.bool},
	{"achievements.specialization", "achievements.SPECIALIZATION", sm.bool},
	{"achievements.splinter", "achievements.SPLINTER", sm.bool},
	{"achievements.spore", "achievements.SPORE", sm.bool},
	{"achievements.stillCountsAsOne", "achievements.STILL_COUNTS_AS_ONE", sm.bool},
	{"achievements.sunburner", "achievements.SUN_BURNER", sm.bool},
	{"achievements.mushroom", "achievements.DEFEAT_MUSHROOM", sm.bool},
	{"achievements.tactician", "achievements.TACTICIAN", sm.bool},
	{"achievements.toxicity", "achievements.TOXICITY", sm.bool},
	{"achievements.towerUpgradeLevel3", "achievements.UPGRADE_LEVEL3", sm.bool},
	{"achievements.dineInHell", "achievements.WE_DINE_IN_HELL", sm.bool},
	{"achievements.whatsThat", "achievements.WHATS_THAT", sm.bool},
	{"notifications.notificationEnemyGoblin", "seen.enemy_goblin"},
	{"notifications.notificationEnemyFatOrc", "seen.enemy_fat_orc"},
	{"notifications.notificationEnemyShaman", "seen.enemy_shaman"},
	{"notifications.notificationEnemyOgre", "seen.enemy_ogre"},
	{"notifications.notificationEnemyBandit", "seen.enemy_bandit"},
	{"notifications.notificationEnemyBrigand", "seen.enemy_brigand"},
	{"notifications.notificationEnemyMarauder", "seen.enemy_marauder"},
	{"notifications.notificationEnemySpider", "seen.enemy_spider_big"},
	{"notifications.notificationEnemySpiderSmall", "seen.enemy_spider_small"},
	{"notifications.notificationEnemyGargoyle", "seen.enemy_gargoyle"},
	{"notifications.notificationEnemyShadowArcher", "seen.enemy_shadow_archer"},
	{"notifications.notificationEnemyDarkKnight", "seen.enemy_dark_knight"},
	{"notifications.notificationEnemySmallWolf", "seen.enemy_wolf_small"},
	{"notifications.notificationEnemyWolf", "seen.enemy_wolf"},
	{"notifications.notificationEnemyGolemHead", "seen.enemy_golem_head"},
	{"notifications.notificationEnemyWhiteWolf", "seen.enemy_whitewolf"},
	{"notifications.notificationEnemyTroll", "seen.enemy_troll"},
	{"notifications.notificationEnemyTrollAxeThrower", "seen.enemy_troll_axe_thrower"},
	{"notifications.notificationEnemyTrollChieftain", "seen.enemy_troll_chieftain"},
	{"notifications.notificationEnemyYeti", "seen.enemy_yeti"},
	{"notifications.notificationEnemyRocketeer", "seen.enemy_rocketeer"},
	{"notifications.notificationEnemyDarkSlayer", "seen.enemy_slayer"},
	{"notifications.notificationEnemyDemon", "seen.enemy_demon"},
	{"notifications.notificationEnemyDemonMage", "seen.enemy_demon_mage"},
	{"notifications.notificationEnemyDemonWolf", "seen.enemy_demon_wolf"},
	{"notifications.notificationEnemyDemonImp", "seen.enemy_demon_imp"},
	{"notifications.notificationEnemySkeletor", "seen.enemy_skeleton"},
	{"notifications.notificationEnemySkeletorBig", "seen.enemy_skeleton_big"},
	{"notifications.notificationEnemyNecromancer", "seen.enemy_necromancer"},
	{"notifications.notificationEnemyLavaElemental", "seen.enemy_lava_elemental"},
	{"notifications.notificationEnemySarelgazSmall", "seen.enemy_sarelgaz_small"},
	{"notifications.notificationEnemyJuggernaut", "seen.eb_juggernaut"},
	{"notifications.notificationEnemyYetiBoss", "seen.eb_jt"},
	{"notifications.notificationEnemyVeznan", "seen.eb_veznan"},
	{"notifications.notificationEnemySarelgaz", "seen.eb_sarelgaz"},
	{"notifications.notificationEnemyGoblinZapper", "seen.enemy_goblin_zapper"},
	{"notifications.notificationEnemyOrcRider", "seen.enemy_orc_rider"},
	{"notifications.notificationEnemyOrcArmored", "seen.enemy_orc_armored"},
	{"notifications.notificationEnemyForestTroll", "seen.enemy_forest_troll"},
	{"notifications.notificationEnemyGulThak", "seen.eb_gulthak"},
	{"notifications.notificationEnemyZombie", "seen.enemy_zombie"},
	{"notifications.notificationEnemyRottenSpider", "seen.enemy_spider_rotten"},
	{"notifications.notificationEnemyRottenTree", "seen.enemy_rotten_tree"},
	{"notifications.notificationEnemySwampThing", "seen.enemy_swamp_thing"},
	{"notifications.notificationEnemyBossTreant", "seen.eb_greenmuck"},
	{"notifications.notificationEnemyRaider", "seen.enemy_raider"},
	{"notifications.notificationEnemyPillager", "seen.enemy_pillager"},
	{"notifications.notificationEnemyBossBandit", "seen.eb_kingpin"},
	{"notifications.notificationEnemyTrollSkater", "seen.enemy_troll_skater"},
	{"notifications.notificationEnemyTrollBrute", "seen.enemy_troll_brute"},
	{"notifications.notificationEnemyTrollBoss", "seen.eb_ulgukhai"},
	{"notifications.notificationEnemyDemonLegion", "seen.enemy_demon_legion"},
	{"notifications.notificationEnemyDemonFlareon", "seen.enemy_demon_flareon"},
	{"notifications.notificationEnemyDemonGulaemon", "seen.enemy_demon_gulaemon"},
	{"notifications.notificationEnemyDemonCerberus", "seen.enemy_demon_cerberus"},
	{"notifications.notificationEnemyDemonMoloch", "seen.eb_moloch"},
	{"notifications.notificationEnemyRottenLesser", "seen.enemy_rotten_lesser"},
	{"notifications.notificationEnemyMyconidBoss", "seen.eb_myconid"},
	{"notifications.notificationEnemyHalloweenZombie", "seen.enemy_halloween_zombie"},
	{"notifications.notificationEnemyGiantRat", "seen.enemy_giant_rat"},
	{"notifications.notificationEnemyFallenKnight", "seen.enemy_fallen_knight"},
	{"notifications.notificationEnemySpectralKnight", "seen.enemy_spectral_knight"},
	{"notifications.notificationEnemyHalloweenAbomination", "seen.enemy_abomination"},
	{"notifications.notificationEnemyWererat", "seen.enemy_wererat"},
	{"notifications.notificationEnemyWitch", "seen.enemy_witch"},
	{"notifications.notificationEnemyHalloweenWerewolf", "seen.enemy_werewolf"},
	{"notifications.notificationEnemyHalloweenLycan", "seen.enemy_lycan"},
	{"notifications.notificationEnemyBossBlackburn", "seen.eb_blackburn"},
	{"notifications.notificationTowerArchersLevel2", "seen.tower_archer_2"},
	{"notifications.notificationTowerArchersLevel3", "seen.tower_archer_3"},
	{"notifications.notificationTowerEngineersLevel2", "seen.tower_engineer_2"},
	{"notifications.notificationTowerEngineersLevel3", "seen.tower_engineer_3"},
	{"notifications.notificationTowerMagesLevel2", "seen.tower_mage_2"},
	{"notifications.notificationTowerMagesLevel3", "seen.tower_mage_3"},
	{"notifications.notificationTowerSoldiersLevel2", "seen.tower_barrack_2"},
	{"notifications.notificationTowerSoldiersLevel3", "seen.tower_barrack_3"},
	{"notifications.notificationTowerArchersRanger", "seen.tower_ranger"},
	{"notifications.notificationTowerSoldiersPaladin", "seen.tower_paladin"},
	{"notifications.notificationTowerMagesArcane", "seen.tower_arcane_wizard"},
	{"notifications.notificationTowerEngineersBfg", "seen.tower_bfg"},
	{"notifications.notificationTowerArchersMusketeer", "seen.tower_musketeer"},
	{"notifications.notificationTowerSoldiersBarbarian", "seen.tower_barbarian"},
	{"notifications.notificationTowerMagesSorcerer", "seen.tower_sorcerer"},
	{"notifications.notificationTowerEngineersTesla", "seen.tower_tesla"},
	{"notifications.notificationTipHeroes", "seen.TIP_HEROES"}
}

if KR_PLATFORM == "android" then
	sm.slot_kr1_endless = {{"leaderboards.savedScores.CgkI58SFtpQCEAIQSQ.maxWave", "levels[81][1].waves_survived"}, {"leaderboards.savedScores.CgkI58SFtpQCEAIQSQ.score", "levels[81][1].high_score"}, {"leaderboards.savedScores.CgkI58SFtpQCEAIQSg.maxWave", "levels[81][2].waves_survived"}, {"leaderboards.savedScores.CgkI58SFtpQCEAIQSg.score", "levels[81][2].high_score"}, {"leaderboards.savedScores.CgkI58SFtpQCEAIQSw.maxWave", "levels[81][3].waves_survived"}, {"leaderboards.savedScores.CgkI58SFtpQCEAIQSw.score", "levels[81][3].high_score"}}
elseif KR_PLATFORM == "ios" and KR_TARGET == "phone" then
	sm.slot_kr1_endless = {{"leaderboards.savedScores.endless_orcs_casual_iphone.maxWave", "levels[81][1].waves_survived"}, {"leaderboards.savedScores.endless_orcs_casual_iphone.score", "levels[81][1].high_score"}, {"leaderboards.savedScores.endless_orcs_normal_iphone.maxWave", "levels[81][2].waves_survived"}, {"leaderboards.savedScores.endless_orcs_normal_iphone.score", "levels[81][2].high_score"}, {"leaderboards.savedScores.endless_orcs_veteran_iphone.maxWave", "levels[81][3].waves_survived"}, {"leaderboards.savedScores.endless_orcs_veteran_iphone.score", "levels[81][3].high_score"}}
elseif KR_PLATFORM == "ios" and KR_TARGET == "tablet" then
	sm.slot_kr1_endless = {{"leaderboards.savedScores.endless_orcs_casual.maxWave", "levels[81][1].waves_survived"}, {"leaderboards.savedScores.endless_orcs_casual.score", "levels[81][1].high_score"}, {"leaderboards.savedScores.endless_orcs_normal.maxWave", "levels[81][2].waves_survived"}, {"leaderboards.savedScores.endless_orcs_normal.score", "levels[81][2].high_score"}, {"leaderboards.savedScores.endless_orcs_veteran.maxWave", "levels[81][3].waves_survived"}, {"leaderboards.savedScores.endless_orcs_veteran.score", "levels[81][3].high_score"}}
end

sm.slot_kr2 = {
	{"achievements.svAlienKilledCount", "achievement_counters.COLONIALMARINE"},
	{"achievements.svAssassinDodgeCount", "achievement_counters.DODGETHIS"},
	{"achievements.svCleanedHoldersCount", "achievement_counters.LANDMANAGER"},
	{"achievements.svDeviltideSharksKilledCounter", "achievement_counters.JAWS"},
	{"achievements.svEnemiesFallenCount", "achievement_counters.ISTHATWILHELM"},
	{"achievements.svEnemiesSilencedCount", "achievement_counters.SILENCEPLEASE"},
	{"achievements.svEnemyGunboatsKilledCounter", "achievement_counters.INTHENAVY"},
	{"achievements.svEnemyKilledBySnapvineCount", "achievement_counters.FEEDMESEYMOUR"},
	{"achievements.svEnemyKilledWithPirateCannonCount", "achievement_counters.THEBLACKPEARL"},
	{"achievements.svHiredMercenariesCount", "achievement_counters.MONEYTALKS"},
	{"achievements.svPerfectStormBluegaleKilledCounter", "achievement_counters.PERFECTSTORM"},
	{"achievements.svTribalZombiesKilledCount", "achievement_counters.THEWALKINGDEAD"},
	{"achievements.svWantPieceOfMeCount", "achievement_counters.WANT_PIECE_OF_ME"},
	{"achievements.svWaterworldEnemiesKilledCount", "achievement_counters.WATERWORLD"},
	{"achievements.svWeakenedEnemiesCount", "achievement_counters.NOCOUNTRYFORWEAKMAN"},
	{"achievements.svWhirlwindsPerformedCount", "achievement_counters.TWISTANDSHOUT"},
	{"achievements.svPredator1Found", "achievement_counters.YOUAREONEUGLYMOTHERFUCKER", sm.set_flag, 1},
	{"achievements.svPredator2Found", "achievement_counters.YOUAREONEUGLYMOTHERFUCKER", sm.set_flag, 2},
	{"achievements.svPredator3Found", "achievement_counters.YOUAREONEUGLYMOTHERFUCKER", sm.set_flag, 4},
	{"achievements.svZombiesKilled", "achievement_counters.ZOMBIE_WALK"},
	{"achievements.svEnemiesDeadByBleed", "achievement_counters.LETITBLEED"},
	{"achievements.svEnemiesPickedUpByTwister", "achievement_counters.FUJITA5"},
	{"achievements.svDeathKnightKills", "achievement_counters.GRIMREAPER"},
	{"achievements.svSurvivedMoons", "achievement_counters.MOONWALKER"},
	{"achievements.svPhantomsKilled", "achievement_counters.DEAD_PEOPLE"},
	{"achievements.svMechKills", "achievement_counters.OPTIMUSPRIME"},
	{"achievements.svGoldStolen", "achievement_counters.ALIBABA"},
	{"achievements.svFiredCrossbowBolts", "achievement_counters.BOLTOFTHESUN"},
	{"achievements.svDrillKills", "achievement_counters.DEADFROMBELOW"},
	{"achievements.svCriticalMassExplosionDamage", "achievement_counters.OVERCHARGED"},
	{"achievements.svAliBaba", "achievements.ALIBABA", sm.bool},
	{"achievements.svAndSoItBegins", "achievements.ANDSOITBEGINS", sm.bool},
	{"achievements.armaggedon", "achievements.ARMAGGEDON", sm.bool},
	{"achievements.bloodlust", "achievements.BLOODLUST", sm.bool},
	{"achievements.svBoltOfTheSun", "achievements.BOLTOFTHESUN", sm.bool},
	{"achievements.cannonFodder", "achievements.CANNON_FODDER", sm.bool},
	{"achievements.svCaveman", "achievements.CAVEMAN", sm.bool},
	{"achievements.svColonialMarine", "achievements.COLONIALMARINE", sm.bool},
	{"achievements.svComeOnYouApes", "achievements.COME_ON_YOU_APES", sm.bool},
	{"achievements.daring", "achievements.DARING", sm.bool},
	{"achievements.svDeadFromBelow", "achievements.DEADFROMBELOW", sm.bool},
	{"achievements.svDeadAndLovingIt", "achievements.DEAD_AND_LOVING_IT", sm.bool},
	{"achievements.svISeeDeadPeople", "achievements.DEAD_PEOPLE", sm.bool},
	{"achievements.deathFromAbove", "achievements.DEATH_FROM_ABOVE", sm.bool},
	{"achievements.completeHardMode", "achievements.DEFEAT_COMPLETE_HARD", sm.bool},
	{"achievements.dieHard", "achievements.DIE_HARD", sm.bool},
	{"achievements.svDivideAndConquer", "achievements.DIVIDEANDCONQUER", sm.bool},
	{"achievements.svDodgeThis", "achievements.DODGETHIS", sm.bool},
	{"achievements.earn15Stars", "achievements.EARN15_STARS", sm.bool},
	{"achievements.earn30Stars", "achievements.EARN30_STARS", sm.bool},
	{"achievements.earn45Stars", "achievements.EARN45_STARS", sm.bool},
	{"achievements.easyTowerBuilder", "achievements.EASY_TOWER_BUILDER", sm.bool},
	{"achievements.fearless", "achievements.FEARLESS", sm.bool},
	{"achievements.svFeedMeSeymour", "achievements.FEEDMESEYMOUR", sm.bool},
	{"achievements.firstBlood", "achievements.FIRST_BLOOD", sm.bool},
	{"achievements.svYouHaveFoundMe", "achievements.FOUND_ME", sm.bool},
	{"achievements.svFujita5", "achievements.FUJITA5", sm.bool},
	{"achievements.svGenieInABottle", "achievements.GENIEINABOTTLE", sm.bool},
	{"achievements.svGhosbusters", "achievements.GHOSTBUSTERS", sm.bool},
	{"achievements.giJoe", "achievements.GI_JOE", sm.bool},
	{"achievements.greatDefender", "achievements.GREAT_DEFENDER", sm.bool},
	{"achievements.svGrimReaper", "achievements.GRIMREAPER", sm.bool},
	{"achievements.hardTowerBuilder", "achievements.HARD_TOWER_BUILDER", sm.bool},
	{"achievements.svHawkEye", "achievements.HAWKEYE", sm.bool},
	{"achievements.greatDefenderHeroic", "achievements.HEROIC_DEFENDER", sm.bool},
	{"achievements.svHeroLeveUp", "achievements.HEROLEVELUP", sm.bool},
	{"achievements.levelHeroMedium", "achievements.HERO_OF_THE_DAY", sm.bool},
	{"achievements.svHighlander", "achievements.HIGHLANDER", sm.bool},
	{"achievements.impatient", "achievements.IMPATIENT", sm.bool},
	{"achievements.svIndianaJones", "achievements.INDIANAJONES", sm.bool},
	{"achievements.svInTheNavy", "achievements.INTHENAVY", sm.bool},
	{"achievements.greatDefenderIron", "achievements.IRON_DEFENDER", sm.bool},
	{"achievements.svIsThatWilhelm", "achievements.ISTHATWILHELM", sm.bool},
	{"achievements.svJaws", "achievements.JAWS", sm.bool},
	{"achievements.svKongicide", "achievements.KONGICIDE", sm.bool},
	{"achievements.svLandManager", "achievements.LANDMANAGER", sm.bool},
	{"achievements.svLandOwner", "achievements.LANDOWNER", sm.bool},
	{"achievements.levelHeroMax", "achievements.LEGENDARY", sm.bool},
	{"achievements.svLetItBleed", "achievements.LETITBLEED", sm.bool},
	{"achievements.svKillLizard", "achievements.LIZARD_KING", sm.bool},
	{"achievements.svMechwarrior", "achievements.MECHWARRIOR", sm.bool},
	{"achievements.mediumTowerBuilder", "achievements.MEDIUM_TOWER_BUILDER", sm.bool},
	{"achievements.svMoneyTalks", "achievements.MONEYTALKS", sm.bool},
	{"achievements.svMoonwalker", "achievements.MOONWALKER", sm.bool},
	{"achievements.svMuadib", "achievements.MUADIB", sm.bool},
	{"achievements.multiKill", "achievements.MULTIKILL", sm.bool},
	{"achievements.svMummyAtTheGates", "achievements.MUMMYATTHEGATES", sm.bool},
	{"achievements.svNecropolis", "achievements.NECROPOLIS", sm.bool},
	{"achievements.svNoCountryForWeakMen", "achievements.NOCOUNTRYFORWEAKMAN", sm.bool},
	{"achievements.svOakenshield", "achievements.OAKENSHIELD", sm.bool},
	{"achievements.svOneFroggyEvening", "achievements.ONEFROGGYEVENING", sm.bool},
	{"achievements.svOptimusPrime", "achievements.OPTIMUSPRIME", sm.bool},
	{"achievements.svOrganicPropulsion", "achievements.ORGANICPROPULSION", sm.bool},
	{"achievements.svOvercharged", "achievements.OVERCHARGED", sm.bool},
	{"achievements.svPerfectStorm", "achievements.PERFECTSTORM", sm.bool},
	{"achievements.svPopularBBQ", "achievements.POPULARBBQ", sm.bool},
	{"achievements.svSandWarrior", "achievements.SANDWARRIOR", sm.bool},
	{"achievements.svSaveThePrincess", "achievements.SAVETHEPRINCESS", sm.bool},
	{"achievements.svSilencePlease", "achievements.SILENCEPLEASE", sm.bool},
	{"achievements.slayer", "achievements.SLAYER", sm.bool},
	{"achievements.svSosToTheWorld", "achievements.SOSTOTHEWORLD", sm.bool},
	{"achievements.specialization", "achievements.SPECIALIZATION", sm.bool},
	{"achievements.svSplash", "achievements.SPLASH", sm.bool},
	{"achievements.svSquidInItsInk", "achievements.SQUIDINITSINK", sm.bool},
	{"achievements.svStuffOMaker", "achievements.STUFFOMAKER", sm.bool},
	{"achievements.tactician", "achievements.TACTICIAN", sm.bool},
	{"achievements.svTarzanBoy", "achievements.TARZANBOY", sm.bool},
	{"achievements.svTheBlackPearl", "achievements.THEBLACKPEARL", sm.bool},
	{"achievements.svTheWalkingDead", "achievements.THEWALKINGDEAD", sm.bool},
	{"achievements.svTwistAndShout", "achievements.TWISTANDSHOUT", sm.bool},
	{"achievements.towerUpgradeLevel3", "achievements.UPGRADE_LEVEL3", sm.bool},
	{"achievements.svWantPieceOfMe", "achievements.WANT_PIECE_OF_ME", sm.bool},
	{"achievements.svWaterworld", "achievements.WATERWORLD", sm.bool},
	{"achievements.whatsThat", "achievements.WHATS_THAT", sm.bool},
	{"achievements.svYouAreOneUglyMotherfucker", "achievements.YOUAREONEUGLYMOTHERFUCKER", sm.bool},
	{"achievements.svYouShallNotPass", "achievements.YOUSHALLNOTPASS", sm.bool},
	{"achievements.svZombieWalk", "achievements.ZOMBIE_WALK", sm.bool},
	{"heroes_config.hero_alric.currentXP", "heroes.status.hero_alric.xp"},
	{"heroes_config.hero_alric.skills[1]", "heroes.status.hero_alric.skills.swordsmanship"},
	{"heroes_config.hero_alric.skills[2]", "heroes.status.hero_alric.skills.spikedarmor"},
	{"heroes_config.hero_alric.skills[3]", "heroes.status.hero_alric.skills.toughness"},
	{"heroes_config.hero_alric.skills[4]", "heroes.status.hero_alric.skills.flurry"},
	{"heroes_config.hero_alric.skills[5]", "heroes.status.hero_alric.skills.sandwarriors"},
	{"heroes_config.hero_pirate.currentXP", "heroes.status.hero_pirate.xp"},
	{"heroes_config.hero_pirate.skills[1]", "heroes.status.hero_pirate.skills.swordsmanship"},
	{"heroes_config.hero_pirate.skills[2]", "heroes.status.hero_pirate.skills.looting"},
	{"heroes_config.hero_pirate.skills[3]", "heroes.status.hero_pirate.skills.toughness"},
	{"heroes_config.hero_pirate.skills[4]", "heroes.status.hero_pirate.skills.scattershot"},
	{"heroes_config.hero_pirate.skills[5]", "heroes.status.hero_pirate.skills.kraken"},
	{"heroes_config.hero_mirage.currentXP", "heroes.status.hero_mirage.xp"},
	{"heroes_config.hero_mirage.skills[1]", "heroes.status.hero_mirage.skills.precision"},
	{"heroes_config.hero_mirage.skills[2]", "heroes.status.hero_mirage.skills.shadowdodge"},
	{"heroes_config.hero_mirage.skills[3]", "heroes.status.hero_mirage.skills.swiftness"},
	{"heroes_config.hero_mirage.skills[4]", "heroes.status.hero_mirage.skills.shadowdance"},
	{"heroes_config.hero_mirage.skills[5]", "heroes.status.hero_mirage.skills.lethalstrike"},
	{"heroes_config.hero_priest.currentXP", "heroes.status.hero_priest.xp"},
	{"heroes_config.hero_priest.skills[1]", "heroes.status.hero_priest.skills.holylight"},
	{"heroes_config.hero_priest.skills[2]", "heroes.status.hero_priest.skills.consecrate"},
	{"heroes_config.hero_priest.skills[3]", "heroes.status.hero_priest.skills.wingsoflight"},
	{"heroes_config.hero_priest.skills[4]", "heroes.status.hero_priest.skills.blessedarmor"},
	{"heroes_config.hero_priest.skills[5]", "heroes.status.hero_priest.skills.divinehealth"},
	{"heroes_config.hero_beastmaster.currentXP", "heroes.status.hero_beastmaster.xp"},
	{"heroes_config.hero_beastmaster.skills[1]", "heroes.status.hero_beastmaster.skills.boarmaster"},
	{"heroes_config.hero_beastmaster.skills[2]", "heroes.status.hero_beastmaster.skills.stampede"},
	{"heroes_config.hero_beastmaster.skills[3]", "heroes.status.hero_beastmaster.skills.falconer"},
	{"heroes_config.hero_beastmaster.skills[4]", "heroes.status.hero_beastmaster.skills.deeplashes"},
	{"heroes_config.hero_beastmaster.skills[5]", "heroes.status.hero_beastmaster.skills.regeneration"},
	{"heroes_config.hero_giant.currentXP", "heroes.status.hero_giant.xp"},
	{"heroes_config.hero_giant.skills[1]", "heroes.status.hero_giant.skills.boulderthrow"},
	{"heroes_config.hero_giant.skills[2]", "heroes.status.hero_giant.skills.stomp"},
	{"heroes_config.hero_giant.skills[3]", "heroes.status.hero_giant.skills.bastion"},
	{"heroes_config.hero_giant.skills[4]", "heroes.status.hero_giant.skills.massivedamage"},
	{"heroes_config.hero_giant.skills[5]", "heroes.status.hero_giant.skills.hardrock"},
	{"heroes_config.hero_wizard.currentXP", "heroes.status.hero_wizard.xp"},
	{"heroes_config.hero_wizard.skills[1]", "heroes.status.hero_wizard.skills.magicmissile"},
	{"heroes_config.hero_wizard.skills[2]", "heroes.status.hero_wizard.skills.chainspell"},
	{"heroes_config.hero_wizard.skills[3]", "heroes.status.hero_wizard.skills.disintegrate"},
	{"heroes_config.hero_wizard.skills[4]", "heroes.status.hero_wizard.skills.arcanereach"},
	{"heroes_config.hero_wizard.skills[5]", "heroes.status.hero_wizard.skills.arcanefocus"},
	{"heroes_config.hero_alien.currentXP", "heroes.status.hero_alien.xp"},
	{"heroes_config.hero_alien.skills[1]", "heroes.status.hero_alien.skills.energyglaive"},
	{"heroes_config.hero_alien.skills[2]", "heroes.status.hero_alien.skills.purificationprotocol"},
	{"heroes_config.hero_alien.skills[3]", "heroes.status.hero_alien.skills.abduction"},
	{"heroes_config.hero_alien.skills[4]", "heroes.status.hero_alien.skills.vibroblades"},
	{"heroes_config.hero_alien.skills[5]", "heroes.status.hero_alien.skills.finalcountdown"},
	{"heroes_config.hero_dragon.currentXP", "heroes.status.hero_dragon.xp"},
	{"heroes_config.hero_dragon.skills[1]", "heroes.status.hero_dragon.skills.blazingbreath"},
	{"heroes_config.hero_dragon.skills[2]", "heroes.status.hero_dragon.skills.feast"},
	{"heroes_config.hero_dragon.skills[3]", "heroes.status.hero_dragon.skills.fierymist"},
	{"heroes_config.hero_dragon.skills[4]", "heroes.status.hero_dragon.skills.wildfirebarrage"},
	{"heroes_config.hero_dragon.skills[5]", "heroes.status.hero_dragon.skills.reignoffire"},
	{"heroes_config.hero_crab.currentXP", "heroes.status.hero_crab.xp"},
	{"heroes_config.hero_crab.skills[1]", "heroes.status.hero_crab.skills.hookedclaw"},
	{"heroes_config.hero_crab.skills[2]", "heroes.status.hero_crab.skills.battlehardened"},
	{"heroes_config.hero_crab.skills[3]", "heroes.status.hero_crab.skills.pincerattack"},
	{"heroes_config.hero_crab.skills[4]", "heroes.status.hero_crab.skills.shouldercannon"},
	{"heroes_config.hero_crab.skills[5]", "heroes.status.hero_crab.skills.burrow"},
	{"heroes_config.hero_monk.currentXP", "heroes.status.hero_monk.xp"},
	{"heroes_config.hero_monk.skills[1]", "heroes.status.hero_monk.skills.snakestyle"},
	{"heroes_config.hero_monk.skills[2]", "heroes.status.hero_monk.skills.dragonstyle"},
	{"heroes_config.hero_monk.skills[3]", "heroes.status.hero_monk.skills.tigerstyle"},
	{"heroes_config.hero_monk.skills[4]", "heroes.status.hero_monk.skills.leopardstyle"},
	{"heroes_config.hero_monk.skills[5]", "heroes.status.hero_monk.skills.cranestyle"},
	{"heroes_config.hero_vanhelsing.currentXP", "heroes.status.hero_van_helsing.xp"},
	{"heroes_config.hero_vanhelsing.skills[1]", "heroes.status.hero_van_helsing.skills.multishoot"},
	{"heroes_config.hero_vanhelsing.skills[2]", "heroes.status.hero_van_helsing.skills.silverbullet"},
	{"heroes_config.hero_vanhelsing.skills[3]", "heroes.status.hero_van_helsing.skills.holygrenade"},
	{"heroes_config.hero_vanhelsing.skills[4]", "heroes.status.hero_van_helsing.skills.relicofpower"},
	{"heroes_config.hero_vanhelsing.skills[5]", "heroes.status.hero_van_helsing.skills.beaconoflight"},
	{"heroes_config.hero_dracolich.currentXP", "heroes.status.hero_dracolich.xp"},
	{"heroes_config.hero_dracolich.skills[1]", "heroes.status.hero_dracolich.skills.spinerain"},
	{"heroes_config.hero_dracolich.skills[2]", "heroes.status.hero_dracolich.skills.bonegolem"},
	{"heroes_config.hero_dracolich.skills[3]", "heroes.status.hero_dracolich.skills.plaguecarrier"},
	{"heroes_config.hero_dracolich.skills[4]", "heroes.status.hero_dracolich.skills.diseasenova"},
	{"heroes_config.hero_dracolich.skills[5]", "heroes.status.hero_dracolich.skills.unstabledisease"},
	{"heroes_config.hero_voodoowitch.currentXP", "heroes.status.hero_voodoo_witch.xp"},
	{"heroes_config.hero_voodoowitch.skills[1]", "heroes.status.hero_voodoo_witch.skills.laughingskulls"},
	{"heroes_config.hero_voodoowitch.skills[2]", "heroes.status.hero_voodoo_witch.skills.deathskull"},
	{"heroes_config.hero_voodoowitch.skills[3]", "heroes.status.hero_voodoo_witch.skills.bonedance"},
	{"heroes_config.hero_voodoowitch.skills[4]", "heroes.status.hero_voodoo_witch.skills.deathaura"},
	{"heroes_config.hero_voodoowitch.skills[5]", "heroes.status.hero_voodoo_witch.skills.voodoomagic"},
	{"heroes_config.hero_minotaur.currentXP", "heroes.status.hero_minotaur.xp"},
	{"heroes_config.hero_minotaur.skills[1]", "heroes.status.hero_minotaur.skills.bullrush"},
	{"heroes_config.hero_minotaur.skills[2]", "heroes.status.hero_minotaur.skills.bloodaxe"},
	{"heroes_config.hero_minotaur.skills[3]", "heroes.status.hero_minotaur.skills.daedalusmaze"},
	{"heroes_config.hero_minotaur.skills[4]", "heroes.status.hero_minotaur.skills.roaroffury"},
	{"heroes_config.hero_minotaur.skills[5]", "heroes.status.hero_minotaur.skills.doomspin"},
	{"heroes_config.hero_monkey_god.currentXP", "heroes.status.hero_monkey_god.xp"},
	{"heroes_config.hero_monkey_god.skills[1]", "heroes.status.hero_monkey_god.skills.spinningpole"},
	{"heroes_config.hero_monkey_god.skills[2]", "heroes.status.hero_monkey_god.skills.tetsubostorm"},
	{"heroes_config.hero_monkey_god.skills[3]", "heroes.status.hero_monkey_god.skills.monkeypalm"},
	{"heroes_config.hero_monkey_god.skills[4]", "heroes.status.hero_monkey_god.skills.angrygod"},
	{"heroes_config.hero_monkey_god.skills[5]", "heroes.status.hero_monkey_god.skills.divinenature"},
	{"notifications.notificationEnemyBouncer", "seen.enemy_bouncer"},
	{"notifications.notificationEnemyDesertRaider", "seen.enemy_desert_raider"},
	{"notifications.notificationEnemyDesertArcher", "seen.enemy_desert_archer"},
	{"notifications.notificationEnemyDesertWolfSmall", "seen.enemy_desert_wolf_small"},
	{"notifications.notificationEnemyDesertWolf", "seen.enemy_desert_wolf"},
	{"notifications.notificationEnemyImmortal", "seen.enemy_immortal"},
	{"notifications.notificationEnemyFallen", "seen.enemy_fallen"},
	{"notifications.notificationEnemyExecutioner", "seen.enemy_executioner"},
	{"notifications.notificationEnemyScorpion", "seen.enemy_scorpion"},
	{"notifications.notificationEnemyWasp", "seen.enemy_wasp"},
	{"notifications.notificationEnemyWaspQueen", "seen.enemy_wasp_queen"},
	{"notifications.notificationEnemyTremor", "seen.enemy_tremor"},
	{"notifications.notificationEnemyMunra", "seen.enemy_munra"},
	{"notifications.notificationEnemyJungleSpiderSmall", "seen.enemy_jungle_spider_small"},
	{"notifications.notificationEnemyJungleSpiderBig", "seen.enemy_jungle_spider_big"},
	{"notifications.notificationEnemyCannibal", "seen.enemy_cannibal"},
	{"notifications.notificationEnemyCannibalHunter", "seen.enemy_hunter"},
	{"notifications.notificationEnemyCannibalShamanPriest", "seen.enemy_shaman_priest"},
	{"notifications.notificationEnemyCannibalShamanShield", "seen.enemy_shaman_shield"},
	{"notifications.notificationEnemyCannibalShamanMagic", "seen.enemy_shaman_magic"},
	{"notifications.notificationEnemyCannibalNecromancer", "seen.enemy_shaman_necro"},
	{"notifications.notificationEnemyCanibalZombie", "seen.enemy_cannibal_zombie"},
	{"notifications.notificationEnemyGorilla", "seen.enemy_gorilla"},
	{"notifications.notificationEnemyCannibalWingRider", "seen.enemy_savage_bird_rider"},
	{"notifications.notificationEnemyAlienBreeder", "seen.enemy_alien_breeder"},
	{"notifications.notificationEnemyAlienReaper", "seen.enemy_alien_reaper"},
	{"notifications.notificationEnemySaurianRazorwing", "seen.enemy_razorwing"},
	{"notifications.notificationEnemySaurianQuetzal", "seen.enemy_quetzal"},
	{"notifications.notificationEnemySaurianBroodguard", "seen.enemy_broodguard"},
	{"notifications.notificationEnemySaurianMyrmidon", "seen.enemy_myrmidon"},
	{"notifications.notificationEnemySaurianBlazefang", "seen.enemy_blazefang"},
	{"notifications.notificationEnemySaurianNightscale", "seen.enemy_nightscale"},
	{"notifications.notificationEnemySaurianDarter", "seen.enemy_darter"},
	{"notifications.notificationEnemySaurianBrute", "seen.enemy_brute"},
	{"notifications.notificationEnemySaurianSavant", "seen.enemy_savant"},
	{"notifications.notificationEnemyEfreetiSmall", "seen.enemy_efreeti_small"},
	{"notifications.notificationEnemyEfreeti", "seen.eb_efreeti"},
	{"notifications.notificationEnemyGorillaSmall", "seen.enemy_gorilla_small"},
	{"notifications.notificationEnemyGorillaBoss", "seen.eb_gorilla"},
	{"notifications.notificationEnemyUndergroundBossMinion", "seen.enemy_umbra_minion"},
	{"notifications.notificationEnemyUndergoundBoss", "seen.eb_umbra"},
	{"notifications.notificationEnemyAquaticGreenfin", "seen.enemy_greenfin"},
	{"notifications.notificationEnemyAquaticDeviltide", "seen.enemy_deviltide"},
	{"notifications.notificationEnemyAquaticRedspine", "seen.enemy_redspine"},
	{"notifications.notificationEnemyAquaticBlacksurge", "seen.enemy_blacksurge"},
	{"notifications.notificationEnemyAquaticBluegale", "seen.enemy_bluegale"},
	{"notifications.notificationEnemyAquaticBloodshell", "seen.enemy_bloodshell"},
	{"notifications.notificationEnemyLeviathanBoss", "seen.eb_leviathan"},
	{"notifications.notificationEnemyHalloweenZombie", "seen.enemy_halloween_zombie"},
	{"notifications.notificationEnemyHalloweenGhoul", "seen.enemy_ghoul"},
	{"notifications.notificationEnemyHalloweenBat", "seen.enemy_bat"},
	{"notifications.notificationEnemyHalloweenWerewolf", "seen.enemy_werewolf"},
	{"notifications.notificationEnemyHalloweenAbomination", "seen.enemy_abomination"},
	{"notifications.notificationEnemyHalloweenLycan", "seen.enemy_lycan"},
	{"notifications.notificationEnemyHalloweenGhost", "seen.enemy_ghost"},
	{"notifications.notificationEnemyHalloweenPhantomWarrior", "seen.enemy_phantom_warrior"},
	{"notifications.notificationEnemyHalloweenElvira", "seen.enemy_elvira"},
	{"notifications.notificationEnemyHalloweenDracul", "seen.eb_dracula"},
	{"notifications.notificationEnemySaurianSniper", "seen.enemy_sniper"},
	{"notifications.notificationEnemySaurianKingBoss", "seen.eb_saurian_king"},
	{"notifications.notificationTowerArchersLevel2", "seen.tower_archer_2"},
	{"notifications.notificationTowerArchersLevel3", "seen.tower_archer_3"},
	{"notifications.notificationTowerEngineersLevel2", "seen.tower_engineer_2"},
	{"notifications.notificationTowerEngineersLevel3", "seen.tower_engineer_3"},
	{"notifications.notificationTowerMagesLevel2", "seen.tower_mage_2"},
	{"notifications.notificationTowerMagesLevel3", "seen.tower_mage_3"},
	{"notifications.notificationTowerSoldiersLevel2", "seen.tower_barrack_2"},
	{"notifications.notificationTowerSoldiersLevel3", "seen.tower_barrack_3"},
	{"notifications.notificationTowerSoldiersAssassins", "seen.tower_assassin"},
	{"notifications.notificationTowerArchersCrossbow", "seen.tower_crossbow"},
	{"notifications.notificationTowerEngineersDwaarp", "seen.tower_dwaarp"},
	{"notifications.notificationTowerMagesArchmage", "seen.tower_archmage"},
	{"notifications.notificationTowerSoldiersTemplars", "seen.tower_templar"},
	{"notifications.notificationTowerArchersTotem", "seen.tower_totem"},
	{"notifications.notificationTowerMagesNecromancer", "seen.tower_necromancer"},
	{"notifications.notificationTowerEngineersMech", "seen.tower_mech"}
}

if KR_PLATFORM == "android" then
	sm.slot_kr2_endless = {
		{"leaderboards.savedScores.CgkIio3Ql5UKEAIQWw.maxWave", "levels[81][1].waves_survived"},
		{"leaderboards.savedScores.CgkIio3Ql5UKEAIQWw.score", "levels[81][1].high_score"},
		{"leaderboards.savedScores.CgkIio3Ql5UKEAIQXA.maxWave", "levels[81][2].waves_survived"},
		{"leaderboards.savedScores.CgkIio3Ql5UKEAIQXA.score", "levels[81][2].high_score"},
		{"leaderboards.savedScores.CgkIio3Ql5UKEAIQXQ.maxWave", "levels[81][3].waves_survived"},
		{"leaderboards.savedScores.CgkIio3Ql5UKEAIQXQ.score", "levels[81][3].high_score"},
		{"leaderboards.savedScores.CgkIio3Ql5UKEAIQXg.maxWave", "levels[82][1].waves_survived"},
		{"leaderboards.savedScores.CgkIio3Ql5UKEAIQXg.score", "levels[82][1].high_score"},
		{"leaderboards.savedScores.CgkIio3Ql5UKEAIQXw.maxWave", "levels[82][2].waves_survived"},
		{"leaderboards.savedScores.CgkIio3Ql5UKEAIQXw.score", "levels[82][2].high_score"},
		{"leaderboards.savedScores.CgkIio3Ql5UKEAIQYA.maxWave", "levels[82][3].waves_survived"},
		{"leaderboards.savedScores.CgkIio3Ql5UKEAIQYA.score", "levels[82][3].high_score"}
	}
elseif KR_PLATFORM == "ios" then
	sm.slot_kr2_endless = {
		{"leaderboards.savedScores[\"grp.endless_desert_casual\"].maxWave", "levels[81][1].waves_survived"},
		{"leaderboards.savedScores[\"grp.endless_desert_casual\"].score", "levels[81][1].high_score"},
		{"leaderboards.savedScores[\"grp.endless_desert_normal\"].maxWave", "levels[81][2].waves_survived"},
		{"leaderboards.savedScores[\"grp.endless_desert_normal\"].score", "levels[81][2].high_score"},
		{"leaderboards.savedScores[\"grp.endless_desert_veteran\"].maxWave", "levels[81][3].waves_survived"},
		{"leaderboards.savedScores[\"grp.endless_desert_veteran\"].score", "levels[81][3].high_score"},
		{"leaderboards.savedScores[\"grp.endless_jungle_casual\"].maxWave", "levels[82][1].waves_survived"},
		{"leaderboards.savedScores[\"grp.endless_jungle_casual\"].score", "levels[82][1].high_score"},
		{"leaderboards.savedScores[\"grp.endless_jungle_normal\"].maxWave", "levels[82][2].waves_survived"},
		{"leaderboards.savedScores[\"grp.endless_jungle_normal\"].score", "levels[82][2].high_score"},
		{"leaderboards.savedScores[\"grp.endless_jungle_veteran\"].maxWave", "levels[82][3].waves_survived"},
		{"leaderboards.savedScores[\"grp.endless_jungle_veteran\"].score", "levels[82][3].high_score"}
	}
end

sm.slot_kr3 = {
	{"achievements.elvesBoljarkCounter", "achievement_counters.BOLJARK"},
	{"achievements.elvesCollateralDamageCount", "achievement_counters.COLLATERAL_DAMAGE"},
	{"achievements.elvesComeAndGetThemCount", "achievement_counters.COME_AND_GET_THEM"},
	{"achievements.elvesCounterMasterCount", "achievement_counters.COUNTER_MASTER"},
	{"achievements.elvesDandDCount", "achievement_counters.DND"},
	{"achievements.elvesDoesntCountCounter", "achievement_counters.DOESNT_COUNT"},
	{"achievements.elvesDogFightCount", "achievement_counters.DOGFIGHT_ACE"},
	{"achievements.elvesEldritchDoomCount", "achievement_counters.ELDRITCH_DOOM"},
	{"achievements.elvesFrozenCount", "achievement_counters.FROZEN"},
	{"achievements.elvesGloomicideCount", "achievement_counters.GLOOMICIDE"},
	{"achievements.elvesGnollumCount", "achievement_counters.GNOLLUM"},
	{"achievements.elvesHeroSurviveCount", "achievement_counters.NOT_TODAY"},
	{"achievements.elvesItsaTrapCount", "achievement_counters.ITS_A_TRAP"},
	{"achievements.elvesJaggedAllianceCount", "achievement_counters.JAGGED_ALLIANCE"},
	{"achievements.elvesKilltacularCount", "achievement_counters.KILLTACULAR"},
	{"achievements.elvesLastServiceCreepCount", "achievement_counters.LAST_SERVICE"},
	{"achievements.elvesLightningCastCount", "achievement_counters.LIGHTNING_CAST"},
	{"achievements.elvesLightningKillCount", "achievement_counters.LIGHTNING_KILL"},
	{"achievements.elvesMrPigCount", "achievement_counters.CALL_ME_MR_PIG"},
	{"achievements.elvesNimlothCount", "achievement_counters.NIMLOTH"},
	{"achievements.elvesNoPainGainCount", "achievement_counters.NO_PAIN_NO_GAIN"},
	{"achievements.elvesPestControlCount", "achievement_counters.PEST_CONTROL"},
	{"achievements.elvesPhantomZonedCount", "achievement_counters.PHANTOM_ZONED"},
	{"achievements.elvesTheBiggerTheyAreCount", "achievement_counters.THE_BIGGER_THEY_ARE"},
	{"achievements.elvesVolunteerTributeCount", "achievement_counters.VOLUNTEER_AS_TRIBUTE"},
	{"achievements.elvesVorpalBladeCount", "achievement_counters.VORPAL_BLADE"},
	{"achievements.elvesWildfireHarvestCount", "achievement_counters.WILDFIRE_HARVEST"},
	{"achievements.elvesWithYourShieldCount", "achievement_counters.WITH_YOUR_SHIELD"},
	{"achievements.elvesArtOfWarTipArmor", "achievement_counters.ART_OF_WAR", sm.set_flag, 1},
	{"achievements.elvesArtOfWarTipMagicArmor", "achievement_counters.ART_OF_WAR", sm.set_flag, 2},
	{"achievements.elvesArtOfWarTipRallyPoint", "achievement_counters.ART_OF_WAR", sm.set_flag, 4},
	{"achievements.elvesArtOfWarTipStrategy", "achievement_counters.ART_OF_WAR", sm.set_flag, 8},
	{"achievements.elvesArcaneBurstFlyingKills", "achievement_counters.ARCANE_BURST"},
	{"achievements.elvesBladeDanceTimes", "achievement_counters.BLADE_DANCE"},
	{"achievements.elvesEerieGardenerTimes", "achievement_counters.EERIE_GARDENER"},
	{"achievements.elvesGargamelExploded", "achievement_counters.GARGAMEL"},
	{"achievements.elvesKilltacularWave", "achievement_counters.KILLTACULAR"},
	{"achievements.elvesMitchellHedgesOne", "achievement_counters.MITCHELL_HEDGES", sm.set_flag, 1},
	{"achievements.elvesMitchellHedgesTwo", "achievement_counters.MITCHELL_HEDGES", sm.set_flag, 2},
	{"achievements.elvesMitchellHedgesThree", "achievement_counters.MITCHELL_HEDGES", sm.set_flag, 4},
	{"achievements.elvesPeekabooFriend1", "achievement_counters.PEEKABOO", sm.set_flag, 1},
	{"achievements.elvesPeekabooFriend2", "achievement_counters.PEEKABOO", sm.set_flag, 2},
	{"achievements.elvesPeekabooFriend3", "achievement_counters.PEEKABOO", sm.set_flag, 4},
	{"achievements.elvesSorcerersApprenticeRelic1", "achievement_counters.SORCERERS_APPRENTICE", sm.set_flag, 1},
	{"achievements.elvesSorcerersApprenticeRelic2", "achievement_counters.SORCERERS_APPRENTICE", sm.set_flag, 2},
	{"achievements.elvesSorcerersApprenticeRelic3", "achievement_counters.SORCERERS_APPRENTICE", sm.set_flag, 3},
	{"achievements.elvesSlumberArrowsKills", "achievement_counters.SLUMBER_ARROWS"},
	{"achievements.elvesPerfectParryDamage", "achievement_counters.PERFECT_PARRY"},
	{"achievements.elvesRabbitsBuried", "achievement_counters.FOLLOW_RABBIT"},
	{"achievements.elvesSoldiersKilled", "achievement_counters.WAR_NEVER_CHANGES"},
	{"achievements.elvesDwarfsSaved", "achievement_counters.DWARF_FALLS"},
	{"achievements.elvesGoldCollected", "achievement_counters.BONE_COLLECTOR"},
	{"achievements.elvesGreenArrowKilled", "achievement_counters.GREEN_ARROW"},
	{"achievements.completeHardMode", "achievements.HARD_MODE", sm.bool},
	{"achievements.elvesAceOfSpades", "achievements.ACE_SPADES", sm.bool},
	{"achievements.elvesArcaneBurst", "achievements.ARCANE_BURST", sm.bool},
	{"achievements.elvesArtOfWar", "achievements.ART_OF_WAR", sm.bool},
	{"achievements.elvesBagOfRice", "achievements.BAG_OF_RICE", sm.bool},
	{"achievements.elvesBeans", "achievements.BEANS", sm.bool},
	{"achievements.elvesBeornings", "achievements.BEORNINGS", sm.bool},
	{"achievements.elvesBladeDance", "achievements.BLADE_DANCE", sm.bool},
	{"achievements.elvesBoljark", "achievements.KILL_BOLJARK", sm.bool},
	{"achievements.elvesBoneCollector", "achievements.BONE_COLLECTOR", sm.bool},
	{"achievements.elvesCandyRush", "achievements.CANDY_RUSH", sm.bool},
	{"achievements.elvesComeAndGetThem", "achievements.COME_AND_GET_THEM", sm.bool},
	{"achievements.elvesCounterMaster", "achievements.COUNTERMASTER", sm.bool},
	{"achievements.elvesDandD", "achievements.DND", sm.bool},
	{"achievements.elvesDarkCrystal", "achievements.DARK_CRYSTAL", sm.bool},
	{"achievements.elvesDefeatMalicia", "achievements.MALICIA", sm.bool},
	{"achievements.elvesDingDing", "achievements.DING_DING", sm.bool},
	{"achievements.elvesDoesntCount", "achievements.DOESNT_COUNT", sm.bool},
	{"achievements.elvesDogFight", "achievements.DOGFIGHT", sm.bool},
	{"achievements.elvesDwarfFall", "achievements.DWARF_FALL", sm.bool},
	{"achievements.elvesEerieGardener", "achievements.EERIE_GARDENER", sm.bool},
	{"achievements.elvesEldritchDoom", "achievements.ELDRITCH_DOOM", sm.bool},
	{"achievements.elvesFollowRabbit", "achievements.FOLLOW_RABBIT", sm.bool},
	{"achievements.elvesForbiddenRuins", "achievements.FORBIDDEN_RUINS", sm.bool},
	{"achievements.elvesFreedomFighter", "achievements.FREEDOM_FIGHTER", sm.bool},
	{"achievements.elvesFrozen", "achievements.FROZEN", sm.bool},
	{"achievements.elvesGardenSong", "achievements.GARDEN_SONG", sm.bool},
	{"achievements.elvesGargamel", "achievements.GARGAMEL", sm.bool},
	{"achievements.elvesGatheringTheMagic", "achievements.GATHERING_MAGIC", sm.bool},
	{"achievements.elvesGeorgeFall", "achievements.GEORGE_FALL", sm.bool},
	{"achievements.elvesGetPartyStarted", "achievements.GET_PARTY_STARTED", sm.bool},
	{"achievements.elvesGloomicide", "achievements.GLOOMICIDE", sm.bool},
	{"achievements.elvesGnollbuster", "achievements.GNOLLBUSTER", sm.bool},
	{"achievements.elvesGnollum", "achievements.GNOLLUM", sm.bool},
	{"achievements.elvesGreenArrow", "achievements.GREEN_ARROW", sm.bool},
	{"achievements.elvesHeavyWeight", "achievements.HEAVY_WEIGHT", sm.bool},
	{"achievements.elvesHeroHoldingOut", "achievements.HOLDING_OUT", sm.bool},
	{"achievements.elvesHeroNotToday", "achievements.NOT_TODAY", sm.bool},
	{"achievements.elvesHoldTheLine", "achievements.HOLD_THE_LINE", sm.bool},
	{"achievements.elvesItsaTrap", "achievements.ITS_A_TRAP", sm.bool},
	{"achievements.elvesJaggedAlliance", "achievements.JAGGED_ALLIANCE", sm.bool},
	{"achievements.elvesKillBalrog", "achievements.KILL_BALROG", sm.bool},
	{"achievements.elvesKillerTomatoes", "achievements.KILLER_TOMATOES", sm.bool},
	{"achievements.elvesKilltacular", "achievements.KILLTACULAR", sm.bool},
	{"achievements.elvesKingfoil", "achievements.KINGSFOIL", sm.bool},
	{"achievements.elvesLastService", "achievements.LAST_SERVICE", sm.bool},
	{"achievements.elvesLightningCast", "achievements.LIGHTNING_CAST", sm.bool},
	{"achievements.elvesLightningKill", "achievements.LIGHTNING_KILL", sm.bool},
	{"achievements.elvesLikeToMoveIt", "achievements.LIKE_TO_MOVE_IT", sm.bool},
	{"achievements.elvesLittleTailor", "achievements.BRAVE_TAILOR", sm.bool},
	{"achievements.elvesMitchellHedges", "achievements.MITCHELL_HEDGES", sm.bool},
	{"achievements.elvesMrPig", "achievements.CALL_ME_PIG", sm.bool},
	{"achievements.elvesNeverTellMeTheOdds", "achievements.THE_ODDS", sm.bool},
	{"achievements.elvesNimloth", "achievements.NIMLOTH", sm.bool},
	{"achievements.elvesNoPainGain", "achievements.NOPAINGAIN", sm.bool},
	{"achievements.elvesNotYet", "achievements.NOT_YET", sm.bool},
	{"achievements.elvesOffHead", "achievements.OFF_HEAD", sm.bool},
	{"achievements.elvesPeekaboo", "achievements.PEEKABOO", sm.bool},
	{"achievements.elvesPerfectParry", "achievements.PERFECT_PARRY", sm.bool},
	{"achievements.elvesPestControl", "achievements.PEST_CONTROL", sm.bool},
	{"achievements.elvesPhantomZoned", "achievements.PHANTOMZONED", sm.bool},
	{"achievements.elvesRedSun", "achievements.RED_SUN", sm.bool},
	{"achievements.elvesRobinOfSherwood", "achievements.ROBIN_OF_SHERWOOD", sm.bool},
	{"achievements.elvesRockstar", "achievements.ROCKSTAR", sm.bool},
	{"achievements.elvesScissorFinger", "achievements.SCISSOR_FINGER", sm.bool},
	{"achievements.elvesSentinel", "achievements.SENTINEL", sm.bool},
	{"achievements.elvesShenziBanzaiEd", "achievements.SHEZI_BANZAI_ED", sm.bool},
	{"achievements.elvesSimcity", "achievements.SIMCITY", sm.bool},
	{"achievements.elvesSimon", "achievements.SIMON", sm.bool},
	{"achievements.elvesSlumberArrows", "achievements.SLUMBER_ARROWS", sm.bool},
	{"achievements.elvesSorcerersApprentice", "achievements.SORCERERS_APPRENTICE", sm.bool},
	{"achievements.elvesStandYourGround", "achievements.STAND_YOUR_GROUND", sm.bool},
	{"achievements.elvesStardust", "achievements.STARDUST", sm.bool},
	{"achievements.elvesStarfield", "achievements.STARFIELD", sm.bool},
	{"achievements.elvesStargazer", "achievements.STARGAZER", sm.bool},
	{"achievements.elvesTheBiggerTheyAre", "achievements.BIGGER_THEY_ARE", sm.bool},
	{"achievements.elvesTheChampions", "achievements.WE_ARE_CHAMPIONS", sm.bool},
	{"achievements.elvesTinkerbell", "achievements.TINKERBELL", sm.bool},
	{"achievements.elvesTruthDare", "achievements.TRUTH_DARE", sm.bool},
	{"achievements.elvesValarMorghulis", "achievements.VALAR_MORGHULIS", sm.bool},
	{"achievements.elvesVolunteerTribute", "achievements.VOLUNTEER_TRIBUTE", sm.bool},
	{"achievements.elvesVorpalBlade", "achievements.VORPAL_BLADE", sm.bool},
	{"achievements.elvesWarNeverChanges", "achievements.WAR_NEVER_CHANGES", sm.bool},
	{"achievements.elvesWhySerious", "achievements.SERIOUS", sm.bool},
	{"achievements.elvesWildfireHarvest", "achievements.WILDFIRE_HARVEST", sm.bool},
	{"achievements.elvesWile", "achievements.WILE", sm.bool},
	{"achievements.elvesWithYourShield", "achievements.WITH_YOUR_SHIELD", sm.bool},
	{"achievements.greatDefender", "achievements.GREAT_DEFENDER", sm.bool},
	{"achievements.greatDefenderHeroic", "achievements.GREAT_DEFENDER_HEROIC", sm.bool},
	{"achievements.greatDefenderIron", "achievements.GREAT_DEFENDER_IRON", sm.bool},
	{"heroes_config.elves_hero_archer.currentXP", "heroes.status.hero_elves_archer.xp"},
	{"heroes_config.elves_hero_archer.skills[1]", "heroes.status.hero_elves_archer.skills.multishot"},
	{"heroes_config.elves_hero_archer.skills[2]", "heroes.status.hero_elves_archer.skills.porcupine"},
	{"heroes_config.elves_hero_archer.skills[3]", "heroes.status.hero_elves_archer.skills.nimble_fencer"},
	{"heroes_config.elves_hero_archer.skills[4]", "heroes.status.hero_elves_archer.skills.double_strike"},
	{"heroes_config.elves_hero_archer.skills[5]", "heroes.status.hero_elves_archer.skills.ultimate"},
	{"heroes_config.elves_hero_elementalist.currentXP", "heroes.status.hero_arivan.xp"},
	{"heroes_config.elves_hero_elementalist.skills[1]", "heroes.status.hero_arivan.skills.seal_of_fire"},
	{"heroes_config.elves_hero_elementalist.skills[2]", "heroes.status.hero_arivan.skills.lightning_rod"},
	{"heroes_config.elves_hero_elementalist.skills[3]", "heroes.status.hero_arivan.skills.icy_prison"},
	{"heroes_config.elves_hero_elementalist.skills[4]", "heroes.status.hero_arivan.skills.stone_dance"},
	{"heroes_config.elves_hero_elementalist.skills[5]", "heroes.status.hero_arivan.skills.ultimate"},
	{"heroes_config.elves_hero_pixie.currentXP", "heroes.status.hero_catha.xp"},
	{"heroes_config.elves_hero_pixie.skills[1]", "heroes.status.hero_catha.skills.soul"},
	{"heroes_config.elves_hero_pixie.skills[2]", "heroes.status.hero_catha.skills.tale"},
	{"heroes_config.elves_hero_pixie.skills[3]", "heroes.status.hero_catha.skills.fury"},
	{"heroes_config.elves_hero_pixie.skills[4]", "heroes.status.hero_catha.skills.curse"},
	{"heroes_config.elves_hero_pixie.skills[5]", "heroes.status.hero_catha.skills.ultimate"},
	{"heroes_config.elves_hero_eldritch.currentXP", "heroes.status.hero_regson.xp"},
	{"heroes_config.elves_hero_eldritch.skills[1]", "heroes.status.hero_regson.skills.heal"},
	{"heroes_config.elves_hero_eldritch.skills[2]", "heroes.status.hero_regson.skills.blade"},
	{"heroes_config.elves_hero_eldritch.skills[3]", "heroes.status.hero_regson.skills.slash"},
	{"heroes_config.elves_hero_eldritch.skills[4]", "heroes.status.hero_regson.skills.path"},
	{"heroes_config.elves_hero_eldritch.skills[5]", "heroes.status.hero_regson.skills.ultimate"},
	{"heroes_config.elves_hero_denas.currentXP", "heroes.status.hero_elves_denas.xp"},
	{"heroes_config.elves_hero_denas.skills[1]", "heroes.status.hero_elves_denas.skills.sybarite"},
	{"heroes_config.elves_hero_denas.skills[2]", "heroes.status.hero_elves_denas.skills.celebrity"},
	{"heroes_config.elves_hero_denas.skills[3]", "heroes.status.hero_elves_denas.skills.mighty"},
	{"heroes_config.elves_hero_denas.skills[4]", "heroes.status.hero_elves_denas.skills.shield_strike"},
	{"heroes_config.elves_hero_denas.skills[5]", "heroes.status.hero_elves_denas.skills.ultimate"},
	{"heroes_config.elves_hero_forest_elemental.currentXP", "heroes.status.hero_bravebark.xp"},
	{"heroes_config.elves_hero_forest_elemental.skills[1]", "heroes.status.hero_bravebark.skills.rootspikes"},
	{"heroes_config.elves_hero_forest_elemental.skills[2]", "heroes.status.hero_bravebark.skills.oakseeds"},
	{"heroes_config.elves_hero_forest_elemental.skills[3]", "heroes.status.hero_bravebark.skills.branchball"},
	{"heroes_config.elves_hero_forest_elemental.skills[4]", "heroes.status.hero_bravebark.skills.springsap"},
	{"heroes_config.elves_hero_forest_elemental.skills[5]", "heroes.status.hero_bravebark.skills.ultimate"},
	{"heroes_config.elves_hero_faustus.currentXP", "heroes.status.hero_faustus.xp"},
	{"heroes_config.elves_hero_faustus.skills[1]", "heroes.status.hero_faustus.skills.dragon_lance"},
	{"heroes_config.elves_hero_faustus.skills[2]", "heroes.status.hero_faustus.skills.teleport_rune"},
	{"heroes_config.elves_hero_faustus.skills[3]", "heroes.status.hero_faustus.skills.enervation"},
	{"heroes_config.elves_hero_faustus.skills[4]", "heroes.status.hero_faustus.skills.liquid_fire"},
	{"heroes_config.elves_hero_faustus.skills[5]", "heroes.status.hero_faustus.skills.ultimate"},
	{"heroes_config.elves_hero_veznan.currentXP", "heroes.status.hero_veznan.xp"},
	{"heroes_config.elves_hero_veznan.skills[1]", "heroes.status.hero_veznan.skills.soulburn"},
	{"heroes_config.elves_hero_veznan.skills[2]", "heroes.status.hero_veznan.skills.shackles"},
	{"heroes_config.elves_hero_veznan.skills[3]", "heroes.status.hero_veznan.skills.hermeticinsight"},
	{"heroes_config.elves_hero_veznan.skills[4]", "heroes.status.hero_veznan.skills.arcanenova"},
	{"heroes_config.elves_hero_veznan.skills[5]", "heroes.status.hero_veznan.skills.ultimate"},
	{"heroes_config.elves_hero_panda.currentXP", "heroes.status.hero_xin.xp"},
	{"heroes_config.elves_hero_panda.skills[1]", "heroes.status.hero_xin.skills.daring_strike"},
	{"heroes_config.elves_hero_panda.skills[2]", "heroes.status.hero_xin.skills.inspire"},
	{"heroes_config.elves_hero_panda.skills[3]", "heroes.status.hero_xin.skills.mind_over_body"},
	{"heroes_config.elves_hero_panda.skills[4]", "heroes.status.hero_xin.skills.panda_style"},
	{"heroes_config.elves_hero_panda.skills[5]", "heroes.status.hero_xin.skills.ultimate"},
	{"heroes_config.elves_hero_phoenix.currentXP", "heroes.status.hero_phoenix.xp"},
	{"heroes_config.elves_hero_phoenix.skills[1]", "heroes.status.hero_phoenix.skills.inmolate"},
	{"heroes_config.elves_hero_phoenix.skills[2]", "heroes.status.hero_phoenix.skills.purification"},
	{"heroes_config.elves_hero_phoenix.skills[3]", "heroes.status.hero_phoenix.skills.blazing_offspring"},
	{"heroes_config.elves_hero_phoenix.skills[4]", "heroes.status.hero_phoenix.skills.flaming_path"},
	{"heroes_config.elves_hero_phoenix.skills[5]", "heroes.status.hero_phoenix.skills.ultimate"},
	{"heroes_config.elves_hero_rag.currentXP", "heroes.status.hero_rag.xp"},
	{"heroes_config.elves_hero_rag.skills[1]", "heroes.status.hero_rag.skills.raggified"},
	{"heroes_config.elves_hero_rag.skills[2]", "heroes.status.hero_rag.skills.kamihare"},
	{"heroes_config.elves_hero_rag.skills[3]", "heroes.status.hero_rag.skills.angry_gnome"},
	{"heroes_config.elves_hero_rag.skills[4]", "heroes.status.hero_rag.skills.hammer_time"},
	{"heroes_config.elves_hero_rag.skills[5]", "heroes.status.hero_rag.skills.ultimate"},
	{"heroes_config.elves_hero_durax.currentXP", "heroes.status.hero_durax.xp"},
	{"heroes_config.elves_hero_durax.skills[1]", "heroes.status.hero_durax.skills.crystallites"},
	{"heroes_config.elves_hero_durax.skills[2]", "heroes.status.hero_durax.skills.armsword"},
	{"heroes_config.elves_hero_durax.skills[3]", "heroes.status.hero_durax.skills.lethal_prism"},
	{"heroes_config.elves_hero_durax.skills[4]", "heroes.status.hero_durax.skills.shardseed"},
	{"heroes_config.elves_hero_durax.skills[5]", "heroes.status.hero_durax.skills.ultimate"},
	{"heroes_config.elves_hero_lynn.currentXP", "heroes.status.hero_lynn.xp"},
	{"heroes_config.elves_hero_lynn.skills[1]", "heroes.status.hero_lynn.skills.hexfury"},
	{"heroes_config.elves_hero_lynn.skills[2]", "heroes.status.hero_lynn.skills.despair"},
	{"heroes_config.elves_hero_lynn.skills[3]", "heroes.status.hero_lynn.skills.weakening"},
	{"heroes_config.elves_hero_lynn.skills[4]", "heroes.status.hero_lynn.skills.charm_of_unluck"},
	{"heroes_config.elves_hero_lynn.skills[5]", "heroes.status.hero_lynn.skills.ultimate"},
	{"heroes_config.elves_hero_bruce.currentXP", "heroes.status.hero_bruce.xp"},
	{"heroes_config.elves_hero_bruce.skills[1]", "heroes.status.hero_bruce.skills.sharp_claws"},
	{"heroes_config.elves_hero_bruce.skills[2]", "heroes.status.hero_bruce.skills.kings_roar"},
	{"heroes_config.elves_hero_bruce.skills[3]", "heroes.status.hero_bruce.skills.lions_fur"},
	{"heroes_config.elves_hero_bruce.skills[4]", "heroes.status.hero_bruce.skills.grievous_bites"},
	{"heroes_config.elves_hero_bruce.skills[5]", "heroes.status.hero_bruce.skills.ultimate"},
	{"heroes_config.elves_hero_fallen_angel.currentXP", "heroes.status.hero_lilith.xp"},
	{"heroes_config.elves_hero_fallen_angel.skills[1]", "heroes.status.hero_lilith.skills.reapers_harvest"},
	{"heroes_config.elves_hero_fallen_angel.skills[2]", "heroes.status.hero_lilith.skills.soul_eater"},
	{"heroes_config.elves_hero_fallen_angel.skills[3]", "heroes.status.hero_lilith.skills.infernal_wheel"},
	{"heroes_config.elves_hero_fallen_angel.skills[4]", "heroes.status.hero_lilith.skills.resurrection"},
	{"heroes_config.elves_hero_fallen_angel.skills[5]", "heroes.status.hero_lilith.skills.ultimate"},
	{"heroes_config.elves_hero_gyro.currentXP", "heroes.status.hero_wilbur.xp"},
	{"heroes_config.elves_hero_gyro.skills[1]", "heroes.status.hero_wilbur.skills.missile"},
	{"heroes_config.elves_hero_gyro.skills[2]", "heroes.status.hero_wilbur.skills.smoke"},
	{"heroes_config.elves_hero_gyro.skills[3]", "heroes.status.hero_wilbur.skills.box"},
	{"heroes_config.elves_hero_gyro.skills[4]", "heroes.status.hero_wilbur.skills.engine"},
	{"heroes_config.elves_hero_gyro.skills[5]", "heroes.status.hero_wilbur.skills.ultimate"},
	{"notifications.notificationElvesEnemyArachnomancer", "seen.enemy_arachnomancer"},
	{"notifications.notificationElvesEnemyBandersnatch", "seen.enemy_bandersnatch"},
	{"notifications.notificationElvesEnemyBloodServant", "seen.enemy_blood_servant"},
	{"notifications.notificationElvesEnemyBloodsydianWarlock", "seen.enemy_bloodsydian_warlock"},
	{"notifications.notificationElvesEnemyBoomshrooms", "seen.enemy_boomshrooms"},
	{"notifications.notificationElvesEnemyBossBajNimen", "seen.eb_bajnimen"},
	{"notifications.notificationElvesEnemyBossBalrog", "seen.eb_balrog"},
	{"notifications.notificationElvesEnemyBossBram", "seen.eb_bram"},
	{"notifications.notificationElvesEnemyBossGnoll", "seen.eb_gnoll"},
	{"notifications.notificationElvesEnemyDarkSpitters", "seen.enemy_dark_spitters"},
	{"notifications.notificationElvesEnemyDrider", "seen.enemy_drider"},
	{"notifications.notificationElvesEnemyDrowQueen", "seen.eb_drow_queen"},
	{"notifications.notificationElvesEnemyEndBoss", "seen.eb_spider"},
	{"notifications.notificationElvesEnemyEttin", "seen.enemy_ettin"},
	{"notifications.notificationElvesEnemyEvoker", "seen.enemy_twilight_evoker"},
	{"notifications.notificationElvesEnemyGloomy", "seen.enemy_gloomy"},
	{"notifications.notificationElvesEnemyGnollBlighter", "seen.enemy_gnoll_blighter"},
	{"notifications.notificationElvesEnemyGnollBloodsydian", "seen.enemy_gnoll_bloodsydian"},
	{"notifications.notificationElvesEnemyGnollBurner", "seen.enemy_gnoll_burner"},
	{"notifications.notificationElvesEnemyGnollGnawer", "seen.enemy_gnoll_gnawer"},
	{"notifications.notificationElvesEnemyGnollReaver", "seen.enemy_gnoll_reaver"},
	{"notifications.notificationElvesEnemyGrimDevourers", "seen.enemy_grim_devourers"},
	{"notifications.notificationElvesEnemyHyena", "seen.enemy_hyena"},
	{"notifications.notificationElvesEnemyMantaRay", "seen.enemy_mantaray"},
	{"notifications.notificationElvesEnemyMountedAvenger", "seen.enemy_mounted_avenger"},
	{"notifications.notificationElvesEnemyMunchshrooms", "seen.enemy_munchshrooms"},
	{"notifications.notificationElvesEnemyOgreMagi", "seen.enemy_ogre_magi"},
	{"notifications.notificationElvesEnemyOgreMagiCustodyEttin", "seen.enemy_ogre_magi_custody_ettin"},
	{"notifications.notificationElvesEnemyOgreMagiCustodyGnollGnawer", "seen.enemy_ogre_magi_custody_gnoll_gnawer"},
	{"notifications.notificationElvesEnemyOgreMagiCustodyWarlock", "seen.enemy_ogre_magi_custody_warlock"},
	{"notifications.notificationElvesEnemyPerython", "seen.enemy_perython"},
	{"notifications.notificationElvesEnemyPerythonGnollGnawer", "seen.enemy_perython_gnoll_gnawer"},
	{"notifications.notificationElvesEnemyPerythonRockthrower", "seen.enemy_perython_rock_thrower"},
	{"notifications.notificationElvesEnemyRabbit", "seen.enemy_rabbit"},
	{"notifications.notificationElvesEnemyRazorboar", "seen.enemy_razorboar"},
	{"notifications.notificationElvesEnemyRedcap", "seen.enemy_redcap"},
	{"notifications.notificationElvesEnemySatyrCutthroat", "seen.enemy_satyr_cutthroat"},
	{"notifications.notificationElvesEnemySatyrHoplite", "seen.enemy_satyr_hoplite"},
	{"notifications.notificationElvesEnemyScreecherBat", "seen.enemy_screecher_bat"},
	{"notifications.notificationElvesEnemyShadowChampion", "seen.enemy_shadow_champion"},
	{"notifications.notificationElvesEnemyShadowsSpawns", "seen.enemy_shadows_spawns"},
	{"notifications.notificationElvesEnemyShroomBreeder", "seen.enemy_shroom_breeder"},
	{"notifications.notificationElvesEnemySonOfMactans", "seen.enemy_spider_son_of_mactans"},
	{"notifications.notificationElvesEnemySpiderArachnomancer", "seen.enemy_spider_arachnomancer"},
	{"notifications.notificationElvesEnemySwordSpider", "seen.enemy_sword_spider"},
	{"notifications.notificationElvesEnemyTwilightAvenger", "seen.enemy_twilight_avenger"},
	{"notifications.notificationElvesEnemyTwilightElfHarasser", "seen.enemy_twilight_elf_harasser"},
	{"notifications.notificationElvesEnemyTwilightEvoker", "seen.enemy_twilight_evoker"},
	{"notifications.notificationElvesEnemyTwilightGolem", "seen.enemy_twilight_golem"},
	{"notifications.notificationElvesEnemyTwilightHeretic", "seen.enemy_twilight_heretic"},
	{"notifications.notificationElvesEnemyTwilightScourger", "seen.enemy_twilight_scourger"},
	{"notifications.notificationElvesEnemyWebspittingSpider", "seen.enemy_webspitting_spider"},
	{"notifications.notificationEndlessMiniBossGnoll", "seen.enemy_gnoll_warleader"},
	{"notifications.notificationEndlessMiniBossTwilight", "seen.enemy_twilight_brute"},
	{"notifications.notificationElvesTowerArchersArcane", "seen.tower_arcane"},
	{"notifications.notificationElvesTowerArchersLevel2", "seen.tower_archer_2"},
	{"notifications.notificationElvesTowerArchersLevel3", "seen.tower_archer_3"},
	{"notifications.notificationElvesTowerArchersSilver", "seen.tower_silver"},
	{"notifications.notificationElvesTowerBarracksBlade", "seen.tower_blade"},
	{"notifications.notificationElvesTowerBarracksForest", "seen.tower_forest"},
	{"notifications.notificationElvesTowerBarracksLevel2", "seen.tower_barrack_2"},
	{"notifications.notificationElvesTowerBarracksLevel3", "seen.tower_barrack_3"},
	{"notifications.notificationElvesTowerMagesHighElven", "seen.tower_high_elven"},
	{"notifications.notificationElvesTowerMagesLevel2", "seen.tower_mage_2"},
	{"notifications.notificationElvesTowerMagesLevel3", "seen.tower_mage_3"},
	{"notifications.notificationElvesTowerMagesWildMagus", "seen.tower_wild_magus"},
	{"notifications.notificationElvesTowerRockThrowerEntwood", "seen.tower_entwood"},
	{"notifications.notificationElvesTowerRockThrowerLevel2", "seen.tower_engineer_2"},
	{"notifications.notificationElvesTowerRockThrowerLevel3", "seen.tower_engineer_3"},
	{"notifications.notificationElvesTowerRockThrowerStoneDruid", "seen.tower_druid"},
	{"notifications.notificationPlant1", "seen.PLANT_MAGIC_BLOSSOM"},
	{"notifications.notificationPlant2", "seen.PLANT_VENOM"},
	{"notifications.notificationPlant3", "seen.ARCANE_CRYSTAL"},
	{"notifications.notificationPlant4", "seen.PARALYZING_TREE"}
}

if KR_PLATFORM == "android" then
	sm.slot_kr3_endless = {
		{"leaderboards.savedScores.CgkIio3Ql5UKEAIQWw.maxWave", "levels[81][1].waves_survived"},
		{"leaderboards.savedScores.CgkIio3Ql5UKEAIQWw.score", "levels[81][1].high_score"},
		{"leaderboards.savedScores.CgkIio3Ql5UKEAIQXA.maxWave", "levels[81][2].waves_survived"},
		{"leaderboards.savedScores.CgkIio3Ql5UKEAIQXA.score", "levels[81][2].high_score"},
		{"leaderboards.savedScores.CgkIio3Ql5UKEAIQXQ.maxWave", "levels[81][3].waves_survived"},
		{"leaderboards.savedScores.CgkIio3Ql5UKEAIQXQ.score", "levels[81][3].high_score"},
		{"leaderboards.savedScores.CgkIio3Ql5UKEAIQXg.maxWave", "levels[82][1].waves_survived"},
		{"leaderboards.savedScores.CgkIio3Ql5UKEAIQXg.score", "levels[82][1].high_score"},
		{"leaderboards.savedScores.CgkIio3Ql5UKEAIQXw.maxWave", "levels[82][2].waves_survived"},
		{"leaderboards.savedScores.CgkIio3Ql5UKEAIQXw.score", "levels[82][2].high_score"},
		{"leaderboards.savedScores.CgkIio3Ql5UKEAIQYA.maxWave", "levels[82][3].waves_survived"},
		{"leaderboards.savedScores.CgkIio3Ql5UKEAIQYA.score", "levels[82][3].high_score"}
	}
elseif KR_PLATFORM == "ios" and KR_TARGET == "phone" then
	sm.slot_kr3_endless = {
		{"leaderboards.savedScores.endless_gnolls_casual_iphone.maxWave", "levels[81][1].waves_survived"},
		{"leaderboards.savedScores.endless_gnolls_casual_iphone.score", "levels[81][1].high_score"},
		{"leaderboards.savedScores.endless_gnolls_normal_iphone.maxWave", "levels[81][2].waves_survived"},
		{"leaderboards.savedScores.endless_gnolls_normal_iphone.score", "levels[81][2].high_score"},
		{"leaderboards.savedScores.endless_gnolls_veteran_iphone.maxWave", "levels[81][3].waves_survived"},
		{"leaderboards.savedScores.endless_gnolls_veteran_iphone.score", "levels[81][3].high_score"},
		{"leaderboards.savedScores.endless_twilight_casual_iphone.maxWave", "levels[82][1].waves_survived"},
		{"leaderboards.savedScores.endless_twilight_casual_iphone.score", "levels[82][1].high_score"},
		{"leaderboards.savedScores.endless_twilight_normal_iphone.maxWave", "levels[82][2].waves_survived"},
		{"leaderboards.savedScores.endless_twilight_normal_iphone.score", "levels[82][2].high_score"},
		{"leaderboards.savedScores.endless_twilight_veteran_iphone.maxWave", "levels[82][3].waves_survived"},
		{"leaderboards.savedScores.endless_twilight_veteran_iphone.score", "levels[82][3].high_score"}
	}
elseif KR_PLATFORM == "ios" and KR_TARGET == "tablet" then
	sm.slot_kr3_endless = {
		{"leaderboards.savedScores.endless_gnolls_casual.maxWave", "levels[81][1].waves_survived"},
		{"leaderboards.savedScores.endless_gnolls_casual.score", "levels[81][1].high_score"},
		{"leaderboards.savedScores.endless_gnolls_normal.maxWave", "levels[81][2].waves_survived"},
		{"leaderboards.savedScores.endless_gnolls_normal.score", "levels[81][2].high_score"},
		{"leaderboards.savedScores.endless_gnolls_veteran.maxWave", "levels[81][3].waves_survived"},
		{"leaderboards.savedScores.endless_gnolls_veteran.score", "levels[81][3].high_score"},
		{"leaderboards.savedScores.endless_twilight_casual.maxWave", "levels[82][1].waves_survived"},
		{"leaderboards.savedScores.endless_twilight_casual.score", "levels[82][1].high_score"},
		{"leaderboards.savedScores.endless_twilight_normal.maxWave", "levels[82][2].waves_survived"},
		{"leaderboards.savedScores.endless_twilight_normal.score", "levels[82][2].high_score"},
		{"leaderboards.savedScores.endless_twilight_veteran.maxWave", "levels[82][3].waves_survived"},
		{"leaderboards.savedScores.endless_twilight_veteran.score", "levels[82][3].high_score"}
	}
end

return sm
