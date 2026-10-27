-- chunkname: @./kr1/upgrades.lua
local GS = require("kr1.game_settings")

local upgrades = {}

upgrades.max_level = nil
upgrades.levels = {}
upgrades.levels.archers = 0
upgrades.levels.barracks = 0
upgrades.levels.mages = 0
upgrades.levels.engineers = 0
upgrades.levels.rain = 0
upgrades.levels.reinforcements = 0
upgrades.display_order = {"archers", "barracks", "mages", "engineers", "rain", "reinforcements"}
upgrades.list_id = 1
local line1 = require("kr1.upgrades.line1")
local line2 = require("kr1.upgrades.line2")
local line3 = require("kr1.upgrades.line3")
local line4 = require("kr1.upgrades.line4")

upgrades.list = {line1, line2, line3, line4}

function upgrades:set_list_id(id)
	self.list_id = id or 1
end

function upgrades:set_levels(levels)
	for k, v in pairs(levels) do
		self.levels[k] = v
	end
end

function upgrades:get_techs(id)
	return self.list[id or self.list_id].techs
end

function upgrades:has_upgrade(name)
	local u = self:get_techs()[name]

	return u and u.level <= self.levels[u.class] and (not self.max_level or u.level <= self.max_level)
end

function upgrades:get_upgrade(name)
	local u = self:get_techs()[name]

	if not u or u.level > self.levels[u.class] or not self.max_level or u.level > self.max_level then
		return nil
	else
		return u
	end
end

function upgrades:get_total_stars()
	local total = 0

	for k, v in pairs(self:get_techs()) do
		total = total + v.price
	end

	return total
end

upgrades.archer_towers = GS.archer_towers
upgrades.barrack_towers = GS.barrack_towers

upgrades.arrows = {
	"arrow_1",
	"arrow_2",
	"arrow_3",
	"arrow_ranger",
	"shotgun_musketeer",
	"shotgun_musketeer_sniper",
	"shotgun_musketeer_sentry_instakill",
	"arrow_crossbow",
	"axe_totem",
	"dwarf_shotgun",
	"pirate_watchtower_shotgun",
	"arrow_arcane",
	"arrow_arcane_slumber",
	"arrow_silver",
	"arrow_silver_long",
	"arrow_silver_sentence",
	"arrow_silver_mark",
	"arrow_silver_mark_long",
	"arrow_hero_elves_archer",
	"arrow_hero_alleria",
	"bullet_asra",
	"bullet_onix_asra",
	"multishot_crossbow",
	"knife_catha",
	"bullet_tower_dark_elf_lvl4",
	"bullet_tower_sand_lvl4",
	"bullet_tower_sand_skill_gold",
	"arrow_armor_piercer_royal_archers",
	"tower_royal_archers_arrow_lvl4",
	"bullet_tower_ballista_lvl4",
	"bullet_tower_ballista_skill_final_shot",
	"arrow_hero_vesper_long_arrow",
	"arrow_hero_vesper_short_arrow",
	"arrow_tower_shadow_archer",
	"arrow_tower_shadow_archer_mark",
	"bone_flingers_bone",
	"bone_flingers_bone_golem",
	"bullet_ogre_shipwreck_musket",
	"bullet_ogre_shipwreck_musket_volley_lvl1",
	"bullet_ogre_shipwreck_musket_volley_lvl2",
	"goblirang",
	"goblirang_big",
	"bullet_shaolin",
	"bullet_swamp_monster",
	"bullet_swamp_monster_bomb",
	"bullet_swamp_monster_bomb_tosky",
	"bullet_archers",
	"bullet_archers_skill_a",
	"bullet_elf_ranger",
	"bullet_elf_ranger_skill_a",
	"bullet_elf_ranger_skill_b",
	"bullet_elf_ranger_skill_c",
	"bullet_elf_ranger_skill_c_bounce_clone",
	"bullet_crossbows",
	"bullet_crossbows_skill_a",
	"bullet_crossbows_skill_c",
	"bullet_sentry_basic",
	"bullet_sentry_skill_b",
	"bullet_sentry_ult"
}

upgrades.soldiers = {
	"soldier_militia",
	"soldier_footmen",
	"soldier_knight",
	"soldier_paladin",
	"soldier_barbarian",
	"soldier_elf",
	"soldier_elemental",
	"soldier_skeleton",
	"soldier_skeleton_knight",
	"soldier_death_rider",
	"soldier_templar",
	"soldier_assassin",
	"soldier_dwarf",
	"soldier_amazona",
	"soldier_djinn",
	"soldier_pirate_flamer",
	"soldier_frankenstein",
	"soldier_blade",
	"soldier_forest",
	"soldier_druid_bear",
	"soldier_drow",
	"soldier_ewok",
	"soldier_baby_ashbite",
	"soldier_tower_dark_elf",
	"soldier_tower_barrel_skill_warrior",
	"soldier_tower_demon_pit_basic_attack_lvl4",
	"big_guy_tower_demon_pit_lvl4",
	"soldier_tower_necromancer_skeleton_lvl4",
	"soldier_tower_necromancer_skeleton_golem_lvl4",
	"soldier_tower_pandas_green_lvl4",
	"soldier_tower_pandas_red_lvl4",
	"soldier_tower_pandas_blue_lvl4",
	"soldier_tower_rocket_gunners_lvl4",
	"soldier_tower_ghost_lvl4",
	"soldier_tower_dwarf_lvl4",
	"tower_paladin_covenant_soldier_lvl4",
	"soldier_bone_golem",
	"soldier_flingers_skeleton",
	"soldier_flingers_skeleton_warrior",
	"soldier_ogre_shipwreck_cook",
	"soldier_ogre_shipwreck_deckhand",
	"soldier_ogre_shipwreck_red_goblin",
	"soldier_ogre_shipwreck_red_goblin_elite",
	"soldier_orc_warrior",
	"soldier_orc_warrior_captain",
	"soldier_dark_knight",
	"soldier_zombie",
	"soldier_zombie_medium",
	"soldier_zombie_big",
	"soldier_gargoyle",
	"soldier_elves_harasser",
	"soldier_elves_espectral_harasser",
	"soldier_deep_devils",
	"soldier_deep_devils_chosen",
	"soldier_ignis_altar_elemental",
	"soldier_dragon",
	"soldier_swamp_monster",
	"soldier_tower_sandworm_1",
	"soldier_tower_sandworm_2",
	"soldier_priests_barrack",
	"soldier_abomination_priests_barrack",
	"soldier_knights",
	"soldier_wildcat",
	"soldier_miners",
	"soldier_miners_skill_a",
	"soldier_sunray_master",
	"soldier_alchemist",
	"soldier_crossbows_ult",
	"soldier_tree",
	"soldier_tree_ultimate_seedling"
}

upgrades.barrack_soldiers = {
	"soldier_militia",
	"soldier_footmen",
	"soldier_knight",
	"soldier_paladin",
	"soldier_barbarian",
	"soldier_elf",
	"soldier_templar",
	"soldier_assassin",
	"soldier_dwarf",
	"soldier_amazona",
	"soldier_djinn",
	"soldier_pirate_flamer",
	"soldier_blade",
	"soldier_forest",
	"soldier_drow",
	"soldier_ewok",
	"soldier_baby_ashbite",
	"soldier_tower_pandas_green_lvl4",
	"soldier_tower_pandas_red_lvl4",
	"soldier_tower_pandas_blue_lvl4",
	"soldier_tower_rocket_gunners_lvl4",
	"soldier_tower_ghost_lvl4",
	"soldier_tower_dwarf_lvl4",
	"tower_paladin_covenant_soldier_lvl4",
	"soldier_ogre_shipwreck_cook",
	"soldier_ogre_shipwreck_deckhand",
	"soldier_ogre_shipwreck_red_goblin",
	"soldier_ogre_shipwreck_red_goblin_elite",
	"soldier_orc_warrior",
	"soldier_orc_warrior_captain",
	"soldier_dark_knight",
	"soldier_zombie",
	"soldier_zombie_medium",
	"soldier_zombie_big",
	"soldier_elves_harasser",
	"soldier_elves_espectral_harasser",
	"soldier_swamp_monster",
	"soldier_priests_barrack",
	"soldier_abomination_priests_barrack",
	"soldier_knights",
	"soldier_wildcat",
	"soldier_miners",
	"soldier_miners_skill_a",
	"soldier_tree"
}

upgrades.towers_with_barrack = {
	"tower_barrack_1",
	"tower_barrack_2",
	"tower_barrack_3",
	"tower_paladin",
	"tower_barbarian",
	"tower_sorcerer",
	"tower_elf",
	"tower_templar",
	"tower_assassin",
	"tower_mech",
	"tower_necromancer",
	"tower_barrack_dwarf",
	"tower_barrack_amazonas",
	"tower_barrack_mercenaries",
	"tower_barrack_pirates",
	"tower_frankenstein",
	"tower_blade",
	"tower_forest",
	"tower_druid",
	"tower_drow",
	"tower_ewok",
	"tower_baby_ashbite",
	"tower_dark_elf_lvl4",
	"tower_pandas_lvl4",
	"tower_rocket_gunners_lvl4",
	"tower_ghost_lvl4",
	"tower_dwarf_lvl4",
	"tower_barrel_lvl4",
	"tower_paladin_covenant_lvl4",
	"tower_bone_flingers",
	"tower_ogre_shipwreck",
	"tower_orc_warriors",
	"tower_dark_knights",
	"tower_grim_cemetery",
	"tower_twilight_elves_barrack",
	"tower_swamp_monster",
	"tower_wicked_sisters",
	"tower_balloon",
	"tower_spirit_mausoleum",
	"tower_deep_devils",
	"tower_ignis_altar",
	"tower_shaolin",
	"tower_stage_28_priests_barrack",
	"tower_knights",
	"tower_wildcat",
	"tower_miners",
	"tower_sunray_master",
	"tower_tree"
}

upgrades.non_barrack_towers_with_barrack_attribute = {
	"tower_sorcerer",
	"tower_mech",
	"tower_necromancer",
	"tower_frankenstein",
	"tower_druid",
	"tower_dark_elf_lvl4",
	"tower_bone_flingers",
	"tower_balloon",
	"tower_spirit_mausoleum",
	"tower_deep_devils",
	"tower_ignis_altar",
	"tower_shaolin",
	"tower_swamp_monster",
	"tower_wicked_sisters",
	"tower_sunray_master"
}

upgrades.mage_towers = GS.mage_towers

upgrades.mage_tower_bolts = {
	"bolt_1",
	"bolt_2",
	"bolt_3",
	"ray_arcane",
	"bolt_sorcerer",
	"bolt_archmage",
	"ray_sunray",
	"bolt_necromancer_tower",
	"bolt_high_elven_strong",
	"bolt_high_elven_weak",
	"bolt_wild_magus",
	"bolt_faerie_dragon",
	"bullet_tower_necromancer_lvl4",
	"bullet_tower_necromancer_deathspawn",
	"bullet_tower_ray_lvl4",
	"bullet_tower_ray_chain",
	"tower_elven_stargazers_ray",
	"tower_arcane_wizard5_ray",
	"bullet_tower_hermit_toad_mage_basic_lvl4",
	"tower_arborean_emissary_bolt_lvl4",
	"bolt_faerie_dragon_lvl4",
	"bolt_infernal_mage",
	"bolt_orc_shaman",
	"bolt_tower_spirit_mausoleum",
	"bolt_tower_deep_devils",
	"ray_deep_devils",
	"bullet_tower_blazing_watcher",
	"wicked_sisters_proy_green",
	"wicked_sisters_proy_pink",
	"bolt_tower_wizard",
	"bullet_sunray_master_rapid_fire",
	"bullet_sunray_master_skill_c",
	"bullet_light_priestess",
	"bullet_light_priestess_ult",
	"bullet_forger_basic"
}

local other_bolts = {
	"bolt_elora_freeze",
	"bolt_elora_slow",
	"bolt_magnus",
	"bolt_magnus_illusion",
	"bolt_priest",
	"bolt_voodoo_witch",
	"bolt_veznan",
	"ray_arivan_simple",
	"bullet_rag",
	"ray_wizard",
	"ray_wizard_chain",
	"bolt_hero_space_elf_basic_attack",
	"bullet_hero_witch_basic_1",
	"bullet_hero_witch_basic_2",
	"bolt_lumenir",
	"bullet_tower_pandas_ray_lvl4",
	"bullet_tower_pandas_fire_lvl4",
	"bullet_tower_pandas_air_lvl4",
	"tower_arcane_wizard5_ray_disintegrate",
	"hero_muyrn_bullet",
	"bolt_hero_spider_basic_attack",
	"bolt_oloch",
	"bolt_oloch_big",
	"bolt_oloch_duplication",
	"bolt_mortemis"
}

upgrades.bolts = table.append(other_bolts, upgrades.mage_tower_bolts)

upgrades.engineer_towers = GS.engineer_towers

upgrades.engineer_bombs = {
	"bomb",
	"bomb_dynamite",
	"bomb_black",
	"bomb_bfg",
	"bomb_mecha",
	"rock_druid",
	"rock_entwood",
	"rock_firey_nut",
	"tower_tricannon_bomb",
	"bullet_tower_demon_pit_basic_attack_lvl4",
	"bullet_tower_demon_pit_big_guy_lvl4",
	"bullet_tower_barrel_lvl4",
	"bullet_tower_hermit_toad_engineer_basic_lvl4",
	"tower_sparking_geode_ray_lvl4",
	"bomb_ogre_shipwreck_goblin",
	"bomb_ogre_shipwreck_goblin_skill1",
	"bomb_ogre_shipwreck_goblin_skill2",
	"missile_rr",
	"missile_rr_nitro",
	"bomb_balloon",
	"bullet_balloon_oil",
	"bullet_catapult",
	"bullet_catapult_skill_a",
	"bullet_catapult_ultimate",
	"bullet_culverine_air",
	"bullet_culverine_skill_b_air",
	"bullet_alchemist_basic",
	"bullet_alchemist_skill_c"
}

upgrades.engineer_advanced_tower = {
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
	"tower_sandworm",
	"tower_catapult",
	"tower_culverine",
	"tower_alchemist",
	"tower_tree"
}

function upgrades:patch_templates(max_level)
	if max_level then
		self.max_level = max_level
	end

	local line = self.list[self.list_id]

	line.patch(self)

	local ordered = {}

	for name, tech in pairs(line.techs) do
		if tech.patch then
			ordered[#ordered + 1] = {
				name = name,
				tech = tech
			}
		end
	end

	table.sort(ordered, function(a, b)
		if a.tech.level ~= b.tech.level then
			return a.tech.level < b.tech.level
		end

		return a.name < b.name
	end)

	for _, item in ipairs(ordered) do
		local u = item.tech

		if u.level <= self.levels[u.class] and (not self.max_level or u.level <= self.max_level) then
			u.patch(self, u)
		end
	end
end

return upgrades
