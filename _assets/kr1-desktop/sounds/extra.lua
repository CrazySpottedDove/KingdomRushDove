-- chunkname: @./_assets/kr1-desktop/sounds/extra.lua
local kr1_groups = {
    music_screen_map = {
        sounds = {"MusicMap1","MusicMap2","MusicMap3"}
    },
    music_screen_slots = {
        sounds = {"MusicMainMenu"}
    },
    music_screen_credits = {
        sounds = {"MusicEndCredits"}
    },
    music_screen_kr1_end = {
        sounds = {"MusicEndCredits", "MusicSuspense"}
    },
    music_stage01 = {
        sounds = {"MusicBattlePrep_01", "MusicBattle_01"}
    },
    music_stage02 = {
        sounds = {"MusicBattlePrep_02", "MusicBattle_02"}
    },
    music_stage03 = {
        sounds = {"MusicBattlePrep_03", "MusicBattle_03"}
    },
    music_stage04 = {
        sounds = {"MusicBattlePrep_04", "MusicBattle_04"}
    },
    music_stage05 = {
        sounds = {"MusicBattlePrep_05", "MusicBattle_05"}
    },
    music_stage06 = {
        sounds = {"MusicBattlePrep_06", "MusicBattle_06", "MusicBossFight"}
    },
    music_stage07 = {
        sounds = {"MusicBattlePrep_07", "MusicBattle_07"}
    },
    music_stage08 = {
        sounds = {"MusicBattlePrep_08", "MusicBattle_08"}
    },
    music_stage09 = {
        sounds = {"MusicBattlePrep_09", "MusicBattle_09", "MusicBossFight"}
    },
    music_stage10 = {
        sounds = {"MusicBattlePrep_10", "MusicBattle_10"}
    },
    music_stage11 = {
        sounds = {"MusicBattlePrep_11", "MusicBattle_11"}
    },
    music_stage12 = {
        sounds = {"MusicBattlePrep_12", "MusicBattle_12", "MusicBossFight"}
    },
    music_stage13 = {
        sounds = {"MusicBattlePrep_13", "MusicBattle_13", "MusicBossFight"}
    },
    music_stage14 = {
        sounds = {"MusicBattlePrep_14", "MusicBattle_14", "MusicBossFight"}
    },
    music_stage15 = {
        sounds = {"MusicBattlePrep_15", "MusicBattle_15", "MusicBossFight"}
    },
    music_stage16 = {
        sounds = {"MusicBattlePrep_16", "MusicBattle_16"}
    },
    music_stage17 = {
        sounds = {"MusicBattlePrep_17", "MusicBattle_17", "MusicBossFight"}
    },
    music_stage18 = {
        sounds = {"MusicBattlePrep_18", "MusicBattle_18"}
    },
    music_stage19 = {
        sounds = {"MusicBattlePrep_19", "MusicBattle_19", "MusicBossFight"}
    },
    music_stage20 = {
        sounds = {"MusicBattlePrep_20", "MusicBattle_20"}
    },
    music_stage21 = {
        sounds = {"MusicBattlePrep_21", "MusicBattle_21", "MusicBossFight"}
    },
    music_stage22 = {
        sounds = {"MusicBattlePrep_22", "MusicBattle_22", "MusicBossFight"}
    },
    music_stage23 = {
        sounds = {"MusicBattlePrep_23", "MusicBattle_23"}
    },
    music_stage24 = {
        sounds = {"MusicBattlePrep_24", "MusicBattle_24"}
    },
    music_stage25 = {
        sounds = {"MusicBattlePrep_25", "MusicBattle_25"}
    },
    music_stage26 = {
        sounds = {"MusicBattlePrep_26", "MusicBattle_26", "MusicBossFight"}
    },
    music_stage71 = {
        sounds = {"MusicBattlePrep_71", "MusicBattle_71", "MusicBossFight"}
    },
    music_stage1000 = {
        sounds = {"MusicBattlePrep_01", "MusicBattle_01"}
    },
    common = {
        append = true,
        sounds = {"MeleeSword", "swamp_thing_bomb_shot", "swamp_thing_bomb_explosion", "DeathEplosionShort",
                  "DeathEplosionShortA", "juggernaut_punch", "TenShiTauntSelect"}
    },
    hero_alleria = {
        alias = "HeroArcher"
    },
    hero_denas = {
        alias = "HeroDenas"
    },
    hero_elora = {
        alias = "HeroFrost"
    },
    hero_magnus = {
        alias = "HeroMage"
    },
    hero_gerald = {
        alias = "HeroPaladin"
    },
    hero_ignus = {
        alias = "HeroRainOfFire"
    },
    hero_malik = {
        alias = "HeroReinforcement"
    },
    hero_bolin = {
        alias = "HeroRifleman"
    },
    hero_hacksaw = {
        alias = "HeroRobot"
    },
    hero_oni = {
        alias = "HeroSamurai"
    },
    hero_thor = {
        alias = "HeroThor"
    },
    hero_ingvar = {
        alias = "HeroViking"
    },
    hero_10yr = {
        sounds = {"TenShiTaunt", "TenShiTauntBuffed", "TenShiTauntIntro", "TenShiTauntSelect", "TenShiRespawn",
                  "TenShiTransformToBuffed", "TenShiTransformToNormal", "TenShiAttack1", "TenShiAttack2",
                  "TenShiRainOfFireStart", "TenShiRainOfFireEnd", "TenShiBuffedSpinAttack", "TenShiBuffedBombAttack",
                  "TenShiBuffedBombAttackLong", "TenShiTransformToBuffedSfx", "TenShiTransformToNormalSfx",
                  "TenShiDeathSfx", "TenShiTeleportSfx"}
    },
    MushroomSounds = {
        append = true,
        sounds = {"MushroomPoof"}
    },
    BlackburnSounds = {
        append = true,
        sounds = {"HWZombieAmbient", "kr4_tower_wickedsisters_attack_v1", "CBSpectralKnight"}
    },
    HeroViking = {
        append = true,
        sounds = {"HeroVikingTaunt"}
    }
}
local kr1_sounds = {
    MeleeSword = {
        ignore = 0.45,
        gain = 0.2,
        mode = "sequence",
        source_group = "SWORDS",
        loop = false,
        files = {"Sound_SoldiersFighting-01.ogg", "Sound_SoldiersFighting-02.ogg", "Sound_SoldiersFighting-03.ogg",
                 "Sound_SoldiersFighting-04.ogg", "Sound_SoldiersFighting-05.ogg"}
    },
    MusicMainMenu = {
        source_group = "MUSIC",
        gain = 1,
        loop = true,
        stream = true,
        files = {"MusicMainMenu.ogg"}
    },
    MusicMap1 = {
        source_group = "MUSIC",
        gain = 0.8,
        loop = true,
        stream = true,
        files = {"MusicMap.ogg"}
    },
    MusicEndCredits = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"MusicEndCredits.ogg"}
    },
    MusicSuspense = {
        source_group = "MUSIC",
        gain = 0.7,
        stream = true,
        files = {"MusicSuspense.ogg"}
    },
    MusicBossFight = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"MusicBossFight.ogg"}
    },
    MusicBattlePrep_01 = {
        source_group = "MUSIC",
        gain = 0.8,
        loop = true,
        stream = true,
        files = {"MusicBattlePreparationsForest.ogg"}
    },
    MusicBattlePrep_02 = {
        source_group = "MUSIC",
        gain = 0.8,
        loop = true,
        stream = true,
        files = {"MusicBattlePreparationsForest.ogg"}
    },
    MusicBattlePrep_03 = {
        source_group = "MUSIC",
        gain = 0.8,
        loop = true,
        stream = true,
        files = {"MusicBattlePreparationsForest.ogg"}
    },
    MusicBattlePrep_04 = {
        source_group = "MUSIC",
        gain = 0.8,
        loop = true,
        stream = true,
        files = {"MusicBattlePreparationsForest.ogg"}
    },
    MusicBattlePrep_05 = {
        source_group = "MUSIC",
        gain = 0.8,
        loop = true,
        stream = true,
        files = {"MusicBattlePreparationsForest.ogg"}
    },
    MusicBattlePrep_06 = {
        source_group = "MUSIC",
        gain = 0.8,
        loop = true,
        stream = true,
        files = {"MusicBattlePreparationsForest.ogg"}
    },
    MusicBattlePrep_07 = {
        source_group = "MUSIC",
        gain = 0.8,
        loop = true,
        stream = true,
        files = {"MusicBattlePreparationsMountain.ogg"}
    },
    MusicBattlePrep_08 = {
        source_group = "MUSIC",
        gain = 0.8,
        loop = true,
        stream = true,
        files = {"MusicBattlePreparationsMountain.ogg"}
    },
    MusicBattlePrep_09 = {
        source_group = "MUSIC",
        gain = 0.8,
        loop = true,
        stream = true,
        files = {"MusicBattlePreparationsMountain.ogg"}
    },
    MusicBattlePrep_10 = {
        source_group = "MUSIC",
        gain = 0.9,
        loop = true,
        stream = true,
        files = {"MusicBattlePreparationsWastelands.ogg"}
    },
    MusicBattlePrep_11 = {
        source_group = "MUSIC",
        gain = 0.9,
        loop = true,
        stream = true,
        files = {"MusicBattlePreparationsWastelands.ogg"}
    },
    MusicBattlePrep_12 = {
        source_group = "MUSIC",
        gain = 0.9,
        loop = true,
        stream = true,
        files = {"MusicBattlePreparationsWastelands.ogg"}
    },
    MusicBattlePrep_13 = {
        source_group = "MUSIC",
        gain = 0.8,
        loop = true,
        stream = true,
        files = {"MusicBattlePreparationsMountain.ogg"}
    },
    MusicBattlePrep_14 = {
        source_group = "MUSIC",
        gain = 0.8,
        loop = true,
        stream = true,
        files = {"MusicBattlePreparationsForest.ogg"}
    },
    MusicBattlePrep_15 = {
        source_group = "MUSIC",
        gain = 0.9,
        loop = true,
        stream = true,
        files = {"MusicBattlePreparationsWastelands.ogg"}
    },
    MusicBattlePrep_16 = {
        source_group = "MUSIC",
        gain = 0.8,
        loop = true,
        stream = true,
        files = {"MusicBattlePreparationsForest.ogg"}
    },
    MusicBattlePrep_17 = {
        source_group = "MUSIC",
        gain = 0.8,
        loop = true,
        stream = true,
        files = {"MusicBattlePreparationsForest.ogg"}
    },
    MusicBattlePrep_18 = {
        source_group = "MUSIC",
        gain = 0.8,
        loop = true,
        stream = true,
        files = {"MusicBattlePreparationsMountain.ogg"}
    },
    MusicBattlePrep_19 = {
        source_group = "MUSIC",
        gain = 0.8,
        loop = true,
        stream = true,
        files = {"MusicBattlePreparationsMountain.ogg"}
    },
    MusicBattlePrep_20 = {
        source_group = "MUSIC",
        gain = 0.9,
        loop = true,
        stream = true,
        files = {"MusicBattlePreparationsWastelands.ogg"}
    },
    MusicBattlePrep_21 = {
        source_group = "MUSIC",
        gain = 0.9,
        loop = true,
        stream = true,
        files = {"MusicBattlePreparationsWastelands.ogg"}
    },
    MusicBattlePrep_22 = {
        source_group = "MUSIC",
        gain = 0.9,
        loop = true,
        stream = true,
        files = {"MusicBattlePreparationsWastelands.ogg"}
    },
    MusicBattlePrep_23 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"CB_PreBattle.ogg"}
    },
    MusicBattlePrep_24 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"CB_PreBattle.ogg"}
    },
    MusicBattlePrep_25 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"CB_PreBattle.ogg"}
    },
    MusicBattlePrep_26 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"CB_PreBattle.ogg"}
    },
    MusicBattlePrep_71 = {
        source_group = "MUSIC",
        gain = 0.8,
        loop = true,
        stream = true,
        files = {"MusicBattlePreparationsMountain.ogg"}
    },
    MusicBattlePrep_1000 = {
        source_group = "MUSIC",
        gain = 0.8,
        loop = true,
        stream = true,
        files = {"MusicBattlePreparationsForest.ogg"}
    },
    MusicBattle_01 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"MusicBattleUnderAttackForest1.ogg"}
    },
    MusicBattle_02 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"MusicBattleUnderAttackForest2.ogg"}
    },
    MusicBattle_03 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"MusicBattleUnderAttackForest1.ogg"}
    },
    MusicBattle_04 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"MusicBattleUnderAttackForest2.ogg"}
    },
    MusicBattle_05 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"MusicBattleUnderAttackForest1.ogg"}
    },
    MusicBattle_06 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"MusicBattleUnderAttackForest1.ogg"}
    },
    MusicBattle_07 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"MusicBattleUnderAttackMountain.ogg"}
    },
    MusicBattle_08 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"MusicBattleUnderAttackMountain.ogg"}
    },
    MusicBattle_09 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"MusicBattleUnderAttackMountain.ogg"}
    },
    MusicBattle_10 = {
        source_group = "MUSIC",
        gain = 0.9,
        loop = true,
        stream = true,
        files = {"MusicBattleUnderAttackWastelands.ogg"}
    },
    MusicBattle_11 = {
        source_group = "MUSIC",
        gain = 0.9,
        loop = true,
        stream = true,
        files = {"MusicBattleUnderAttackWastelands.ogg"}
    },
    MusicBattle_12 = {
        source_group = "MUSIC",
        gain = 1,
        loop = true,
        stream = true,
        files = {"KingdomRushWastelandVeznanCastle.ogg"}
    },
    MusicBattle_13 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"MusicBattleUnderAttackMountain.ogg"}
    },
    MusicBattle_14 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"MusicBattleUnderAttackForest1.ogg"}
    },
    MusicBattle_15 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"MusicBattleUnderAttackWastelands.ogg"}
    },
    MusicBattle_16 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"MusicBattleUnderAttackForest1.ogg"}
    },
    MusicBattle_17 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"MusicBattleUnderAttackForest2.ogg"}
    },
    MusicBattle_18 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"MusicBattleUnderAttackMountain.ogg"}
    },
    MusicBattle_19 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"MusicBattleUnderAttackMountain.ogg"}
    },
    MusicBattle_20 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"MusicBattleUnderAttackWastelands.ogg"}
    },
    MusicBattle_21 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"MusicBattleUnderAttackWastelands.ogg"}
    },
    MusicBattle_22 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"MusicBattleUnderAttackWastelands.ogg"}
    },
    MusicBattle_23 = {
        source_group = "MUSIC",
        gain = 0.5,
        loop = true,
        stream = true,
        files = {"CB_Battle.ogg"}
    },
    MusicBattle_24 = {
        source_group = "MUSIC",
        gain = 0.5,
        loop = true,
        stream = true,
        files = {"CB_Battle.ogg"}
    },
    MusicBattle_25 = {
        source_group = "MUSIC",
        gain = 0.5,
        loop = true,
        stream = true,
        files = {"CB_Battle.ogg"}
    },
    MusicBattle_26 = {
        source_group = "MUSIC",
        gain = 0.5,
        loop = true,
        stream = true,
        files = {"CB_Battle.ogg"}
    },
    MusicBattle_71 = {
        source_group = "MUSIC",
        gain = 0.8,
        loop = true,
        stream = true,
        files = {"MusicBattleUnderAttackMountain.ogg"}
    },
    MusicBattle_1000 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"MusicBattleUnderAttackForest1.ogg"}
    },
    SasquashRally = {
        loop = false,
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"Sound_TowerSoldierSasquashRally.ogg"}
    },
    SasquashReady = {
        loop = false,
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"Sound_TowerSoldierSasquashReady.ogg"}
    },
    ReinforcementTaunt = {
        ignore = 1,
        gain = 0.6,
        mode = "sequence",
        source_group = "TAUNTS",
        loop = false,
        files = {"Reinforcements_Event1.ogg", "Reinforcements_Event2.ogg", "Reinforcements_Event3.ogg",
                 "Reinforcements_Event4.ogg"}
    },
    ArrowSound = {
        source_group = "BULLETS",
        loop = false,
        files = {"Sound_ArrowRelease2.ogg", "Sound_ArrowRelease3.ogg"},
        gain = {0.65, 0.8}
    },
    AxeSound = {
        source_group = "BULLETS",
        loop = false,
        files = {"Sound_BattleAxe.ogg"},
        gain = {0.3, 0.5}
    },
    DeathBig = {
        source_group = "DEATH",
        loop = false,
        files = {"Sound_EnemyBigDead.ogg"},
        gain = {0.6, 0.9}
    },
    ShotgunSound = {
        source_group = "BULLETS",
        loop = false,
        files = {"Sound_Shootgun.ogg"},
        gain = {0.65, 0.8}
    },
    MushroomPoof = {
        source_group = "SFX",
        loop = false,
        files = {"KR_sfx_mushroomcreep_muerte_edit_vanzen.ogg"},
        gain = {0.2, 0.3}
    },
    HeroThorDeath = {
        source_group = "TAUNTS",
        gain = 1,
        loop = false,
        mode = "concurrent",
        files = {"Thor_05c.ogg", "KR_sfx_thor_muerte.ogg"}
    },
    EnemyBlackburnWitchDeath = {
        loop = false,
        gain = 0.2,
        source_group = "SFX",
        files = {"kr_sfx_cb_witchdeath.ogg"}
    },
    HeroVikingTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Viking-01b.ogg", "Viking-02c.ogg", "Viking-03b.ogg", "Viking-04c.ogg"}
    },
    HWZombieAmbient = {
        loop = false,
        gain = 0.6,
        ignore = 3,
        mode = "random",
        source_group = "SFX",
        files = {"canibal_zombie_one.ogg", "canibal_zombie_two.ogg", "canibal_zombie_three.ogg"}
    },
    ShrapnelSound = {
        loop = false,
        source_group = "BULLETS",
        gain = 0.12,
        files = {"Sound_Shrapnel.ogg"}
    },
    swamp_thing_bomb_shot = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"swamp-thing-shot.ogg"}
    },
    swamp_thing_bomb_explosion = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"Hero_Karkinos_Cannon_explosion.ogg"}
    },
    DeathEplosionShort = {
        loop = false,
        gain = 0.6,
        source_group = "DEATH",
        files = {"Sound_EnemyExplode1Short.ogg"}
    },
    DeathEplosionShortA = {
        loop = false,
        gain = 0.2,
        source_group = "DEATH",
        files = {"Sound_EnemyExplode1ShortA.ogg"}
    },
    kr4_tower_wickedsisters_attack_v1 = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kr4_tower_wickedsisters_attack_v1.ogg"}
    },
    CBSpectralKnight = {
        loop = false,
        gain = 0.6,
        source_group = "SFX",
        files = {"kr_sfx_cb_spectralknight[horn+organ].ogg"}
    },
    juggernaut_punch = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kr4_sfx_juggernaut_punch_var1_v1.ogg"}
    },
    TenShiTaunt = {
        source_group = "TAUNTS",
        mode = "random",
        gain = 0.7,
        loop = false,
        ignore = 1,
        files = {"TenShi_02c.ogg", "TenShi_01c_and_a.ogg", "TenShi_01a_mmh.ogg", "TenShi_01a_mmh.ogg",
                 "TenShi_01a_mmh.ogg"}
    },
    TenShiTauntBuffed = {
        source_group = "TAUNTS",
        mode = "random",
        gain = 0.7,
        loop = false,
        ignore = 1,
        files = {"TenShi_buffed_01c.ogg", "TenShi_buffed_02b.ogg", "TenShi_buffed_01a_laugh_only.ogg"}
    },
    TenShiTauntIntro = {
        loop = false,
        gain = 0.7,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    TenShiTauntSelect = {
        loop = false,
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"TenShi_02c.ogg"}
    },
    TenShiRespawn = {
        loop = false,
        gain = 0.7,
        source_group = "TAUNTS",
        files = {"TenShi_respawn_01d.ogg"}
    },
    TenShiTransformToBuffed = {
        source_group = "TAUNTS",
        mode = "sequence",
        gain = 1,
        loop = false,
        files = {"TenShi_transformation_01d.ogg", "TenShi_transformation_02c.ogg"}
    },
    TenShiTransformToNormal = {
        source_group = "TAUNTS",
        mode = "sequence",
        gain = 1,
        loop = false,
        files = {"TenShi_01a_mmh.ogg"}
    },
    TenShiAttack1 = {
        source_group = "BULLETS",
        mode = "random",
        gain = 0.6,
        loop = false,
        files = {"kr1_sfx_tenshi_basicAttack1_var1_v1.ogg", "kr1_sfx_tenshi_basicAttack1_var2_v1.ogg",
                 "kr1_sfx_tenshi_basicAttack1_var3_v1.ogg"}
    },
    TenShiAttack2 = {
        loop = false,
        gain = 0.6,
        source_group = "BULLETS",
        files = {"kr1_sfx_tenshi_attack2_v1.ogg"}
    },
    TenShiRainOfFireStart = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kr1_sfx_tenshi_rainOfFire_start_mix.ogg"}
    },
    TenShiRainOfFireEnd = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kr1_sfx_tenshi_rainOfFire_loop-End_v1_10db.ogg"}
    },
    TenShiBuffedSpinAttack = {
        source_group = "SFX",
        mode = "random",
        gain = 1,
        loop = false,
        files = {"kr1_sfx_tenshi_buffedSpinAttack_2hits_v1.ogg", "kr1_sfx_tenshi_buffedSpinAttack_3hits_v1.ogg"}
    },
    TenShiBuffedBombAttack = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kr1_sfx_tenshi_buffedBombAttack_3hits_v1_op2.ogg"}
    },
    TenShiBuffedBombAttackLong = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kr1_sfx_tenshi_buffedBombAttack_6hits_v1_op2.ogg"}
    },
    TenShiTransformToBuffedSfx = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kr1_sfx_tenshi_transformToBuffed_op1_v1.ogg"}
    },
    TenShiTransformToNormalSfx = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kr1_sfx_tenshi_transformToNormal_v1.ogg"}
    },
    TenShiDeathSfx = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kr1_sfx_tenshi_death_v1.ogg"}
    },
    TenShiTeleportSfx = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kr1_sfx_tenshi_teleport_v1_15db.ogg"}
    }
}

local kr2_groups = {
    music_screen_slots = {
        sounds = {"MusicMainMenu"}
    },
    music_screen_credits = {
        sounds = {"MusicEndVictory"}
    },
    music_screen_kr2_end = {
        sounds = {"MusicEndVictory", "MusicEndCredits", "MusicSuspense"}
    },
    music_stage27 = {
        sounds = {"MusicBattlePrep_27", "MusicBattle_27", "MusicBossPreFight"}
    },
    music_stage28 = {
        sounds = {"MusicBattlePrep_28", "MusicBattle_28"}
    },
    music_stage29 = {
        sounds = {"MusicBattlePrep_29", "MusicBattle_29"}
    },
    music_stage30 = {
        sounds = {"MusicBattlePrep_30", "MusicBattle_30"}
    },
    music_stage31 = {
        sounds = {"MusicBattlePrep_31", "MusicBattle_31"}
    },
    music_stage32 = {
        sounds = {"MusicBattlePrep_32", "MusicBattle_32", "MusicBossFight"}
    },
    music_stage33 = {
        sounds = {"MusicBattlePrep_33", "MusicBattle_33"}
    },
    music_stage34 = {
        sounds = {"MusicBattlePrep_34", "MusicBattle_34"}
    },
    music_stage35 = {
        sounds = {"MusicBattlePrep_35", "MusicBattle_35"}
    },
    music_stage36 = {
        sounds = {"MusicBattlePrep_36", "MusicBattle_36"}
    },
    music_stage37 = {
        sounds = {"MusicBattlePrep_37", "MusicBattle_37", "MusicBossPreFight", "MusicBossFight"}
    },
    music_stage38 = {
        sounds = {"MusicBattlePrep_38", "MusicBattle_38"}
    },
    music_stage39 = {
        sounds = {"MusicBattlePrep_39", "MusicBattle_39"}
    },
    music_stage40 = {
        sounds = {"MusicBattlePrep_40", "MusicBattle_40"}
    },
    music_stage41 = {
        sounds = {"MusicBattlePrep_41", "MusicBattle_41", "MusicBossPreFight", "MusicBossFight"}
    },
    music_stage42 = {
        sounds = {"MusicBattlePrep_42", "MusicBattle_42"}
    },
    music_stage43 = {
        sounds = {"MusicBattlePrep_43", "MusicBattle_43"}
    },
    music_stage44 = {
        sounds = {"MusicBattlePrep_44", "MusicBattle_44", "MusicBossPreFightEnd", "MusicBossFight"}
    },
    music_stage45 = {
        sounds = {"MusicBattlePrep_45", "MusicBattle_45", "MusicHalloweenMoon"}
    },
    music_stage46 = {
        sounds = {"MusicBattlePrep_46", "MusicBattle_46", "MusicHalloweenMoon"}
    },
    music_stage47 = {
        sounds = {"MusicBattlePrep_47", "MusicBattle_47", "MusicHalloweenMoon", "MusicBossFight"}
    },
    music_stage48 = {
        sounds = {"MusicBattlePrep_48", "MusicBattle_48", "MusicBossFight"}
    },
    music_stage90 = {
        sounds = { "MusicBattlePrep_90", "MusicBattle_90", "MusicBossFight" }
    },
    common = {
        append = true,
        sounds = {"MeleeSword"}
    },
    HeroCrab = {
        append = true,
        sounds = {"HeroGiantExplosionRock"}
    },
    HeroDracolich = {
        append = true,
        sounds = {"HeroDragonAttackHit"}
    },
    HeroMirage = {
        append = true,
        sounds = {"HeroMirageDeath"}
    },
    hero_alien = {
        alias = "HeroAlien"
    },
    hero_alric = {
        alias = "HeroAlric"
    },
    hero_beastmaster = {
        alias = "HeroBeastMaster"
    },
    hero_crab = {
        alias = "HeroCrab"
    },
    hero_dracolich = {
        alias = "HeroDracolich"
    },
    hero_dragon = {
        alias = "HeroDragon"
    },
    hero_giant = {
        alias = "HeroGiant"
    },
    hero_minotaur = {
        alias = "HeroMinotaur"
    },
    hero_mirage = {
        alias = "HeroMirage"
    },
    hero_monk = {
        alias = "HeroMonk"
    },
    hero_monkey_god = {
        alias = "HeroMonkeyGod"
    },
    hero_pirate = {
        alias = "HeroPirate"
    },
    hero_dwarf = {
        alias = "HeroDwarf"
    },
    hero_priest = {
        alias = "HeroPriest"
    },
    hero_van_helsing = {
        alias = "HeroVanHelsing"
    },
    hero_voodoo_witch = {
        alias = "HeroVoodooWitch"
    },
    hero_wizard = {
        alias = "HeroWizard"
    },
    hero_vampiress = {
        alias = "HWVampiress"
    }
}
local kr2_sounds = {
    MeleeSword = {
        ignore = 0.45,
        gain = 0.2,
        mode = "sequence",
        source_group = "SWORDS",
        loop = false,
        files = {"Sound_SoldiersFighting-01.ogg", "Sound_SoldiersFighting-02.ogg", "Sound_SoldiersFighting-03.ogg",
                 "Sound_SoldiersFighting-04.ogg", "Sound_SoldiersFighting-05.ogg"}
    },
    MusicMainMenu = {
        source_group = "MUSIC",
        gain = 0.8,
        loop = true,
        stream = true,
        files = {"savage_music_theme.mp3"}
    },
    MusicMap2 = {
        source_group = "MUSIC",
        gain = 0.6,
        loop = true,
        stream = true,
        files = {"Map_Theme_1.mp3"}
    },
    MusicEndCredits = {
        source_group = "MUSIC",
        gain = 0.6,
        loop = true,
        stream = true,
        files = {"Map_Theme_1_alias.mp3"}
    },
    MusicBattlePrep_27 = {
        source_group = "MUSIC",
        gain = 0.4,
        loop = true,
        stream = true,
        files = {"savage_music_desert_preparation.mp3"}
    },
    MusicBattlePrep_28 = {
        source_group = "MUSIC",
        gain = 0.6,
        loop = true,
        stream = true,
        files = {"Desert_Prep.mp3"}
    },
    MusicBattlePrep_29 = {
        source_group = "MUSIC",
        gain = 0.4,
        loop = true,
        stream = true,
        files = {"savage_music_desert_preparation.mp3"}
    },
    MusicBattlePrep_30 = {
        source_group = "MUSIC",
        gain = 0.6,
        loop = true,
        stream = true,
        files = {"Desert_Prep.mp3"}
    },
    MusicBattlePrep_31 = {
        source_group = "MUSIC",
        gain = 0.4,
        loop = true,
        stream = true,
        files = {"savage_music_desert_preparation.mp3"}
    },
    MusicBattlePrep_32 = {
        source_group = "MUSIC",
        gain = 0.6,
        loop = true,
        stream = true,
        files = {"Desert_Prep.mp3"}
    },
    MusicBattlePrep_33 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"savage_music_jungle_preparation.mp3"}
    },
    MusicBattlePrep_34 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"Jungle_Prep.mp3"}
    },
    MusicBattlePrep_35 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"savage_music_jungle_preparation.mp3"}
    },
    MusicBattlePrep_36 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"Jungle_Prep.mp3"}
    },
    MusicBattlePrep_37 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"savage_music_jungle_preparation.mp3"}
    },
    MusicBattlePrep_38 = {
        source_group = "MUSIC",
        gain = 0.5,
        loop = true,
        stream = true,
        files = {"savage_music_underground_preparation.mp3"}
    },
    MusicBattlePrep_39 = {
        source_group = "MUSIC",
        gain = 0.6,
        loop = true,
        stream = true,
        files = {"Underground_Prep.mp3"}
    },
    MusicBattlePrep_40 = {
        source_group = "MUSIC",
        gain = 0.5,
        loop = true,
        stream = true,
        files = {"savage_music_underground_preparation.mp3"}
    },
    MusicBattlePrep_41 = {
        source_group = "MUSIC",
        gain = 0.6,
        loop = true,
        stream = true,
        files = {"Underground_Prep.mp3"}
    },
    MusicBattlePrep_42 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"Prebattle_Rising_Tides.mp3"}
    },
    MusicBattlePrep_43 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"Prebattle_Rising_Tides.mp3"}
    },
    MusicBattlePrep_44 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"Prebattle_Rising_Tides.mp3"}
    },
    MusicBattlePrep_45 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"Halloween_PreBattle.mp3"}
    },
    MusicBattlePrep_46 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"Halloween_PreBattle.mp3"}
    },
    MusicBattlePrep_47 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"Halloween_PreBattle.mp3"}
    },
    MusicBattlePrep_48 = {
        source_group = "MUSIC",
        gain = 0.6,
        loop = true,
        stream = true,
        files = {"Underground_Prep.mp3"}
    },
    MusicBattlePrep_90 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = { "savage_music_jungle_preparation.mp3" }
    },
    MusicBattle_27 = {
        source_group = "MUSIC",
        gain = 0.4,
        loop = true,
        stream = true,
        files = {"savage_music_desert_battle.mp3"}
    },
    MusicBattle_28 = {
        source_group = "MUSIC",
        gain = 0.4,
        loop = true,
        stream = true,
        files = {"Desert_Battle.mp3"}
    },
    MusicBattle_29 = {
        source_group = "MUSIC",
        gain = 0.4,
        loop = true,
        stream = true,
        files = {"savage_music_desert_battle.mp3"}
    },
    MusicBattle_30 = {
        source_group = "MUSIC",
        gain = 0.4,
        loop = true,
        stream = true,
        files = {"Desert_Battle.mp3"}
    },
    MusicBattle_31 = {
        source_group = "MUSIC",
        gain = 0.4,
        loop = true,
        stream = true,
        files = {"savage_music_desert_battle.mp3"}
    },
    MusicBattle_32 = {
        source_group = "MUSIC",
        gain = 0.4,
        loop = true,
        stream = true,
        files = {"Desert_Battle.mp3"}
    },
    MusicBattle_33 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"Jungle_Battle.mp3"}
    },
    MusicBattle_34 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"savage_music_jungle_battle.mp3"}
    },
    MusicBattle_35 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"Jungle_Battle.mp3"}
    },
    MusicBattle_36 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"savage_music_jungle_battle.mp3"}
    },
    MusicBattle_37 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"Jungle_Battle.mp3"}
    },
    MusicBattle_38 = {
        source_group = "MUSIC",
        gain = 0.6,
        loop = true,
        stream = true,
        files = {"savage_music_underground_battle.mp3"}
    },
    MusicBattle_39 = {
        source_group = "MUSIC",
        gain = 0.3,
        loop = true,
        stream = true,
        files = {"Underground_Battle.mp3"}
    },
    MusicBattle_40 = {
        source_group = "MUSIC",
        gain = 0.6,
        loop = true,
        stream = true,
        files = {"savage_music_underground_battle.mp3"}
    },
    MusicBattle_41 = {
        source_group = "MUSIC",
        gain = 0.3,
        loop = true,
        stream = true,
        files = {"Underground_Battle.mp3"}
    },
    MusicBattle_42 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"Battle_Rising_Tides.mp3"}
    },
    MusicBattle_43 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"Battle_Rising_Tides.mp3"}
    },
    MusicBattle_44 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"Battle_Rising_Tides.mp3"}
    },
    MusicBattle_45 = {
        source_group = "MUSIC",
        gain = 0.5,
        loop = true,
        stream = true,
        files = {"Halloween_Battle.mp3"}
    },
    MusicBattle_46 = {
        source_group = "MUSIC",
        gain = 0.5,
        loop = true,
        stream = true,
        files = {"Halloween_Battle.mp3"}
    },
    MusicBattle_47 = {
        source_group = "MUSIC",
        gain = 0.5,
        loop = true,
        stream = true,
        files = {"Halloween_Battle.mp3"}
    },
    MusicBattle_48 = {
        source_group = "MUSIC",
        gain = 0.3,
        loop = true,
        stream = true,
        files = {"Underground_Battle.mp3"}
    },
    MusicBattle_90 = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = { "Jungle_Battle.mp3" }
    },
    MusicHalloweenMoon = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"Halloween_Moon.mp3"}
    },
    MusicBossPreFight = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"boss_prefight.mp3"}
    },
    MusicBossPreFightEnd = {
        source_group = "MUSIC",
        gain = 0.7,
        stream = true,
        files = {"Finalboss_prefight.mp3"}
    },
    MusicBossFight = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"Finalboss_fight.mp3"}
    },
    MusicEndVictory = {
        source_group = "MUSIC",
        gain = 0.7,
        stream = true,
        files = {"Victory_Theme.mp3"}
    },
    MusicSuspense = {
        source_group = "MUSIC",
        gain = 0.7,
        stream = true,
        files = {"MusicSuspense.mp3"}
    },
    MechWalk = {
        source_group = "SPECIALS",
        gain = 0.2,
        loop = true,
        files = {"mecha_walk.ogg"}
    },
    ReinforcementTaunt = {
        ignore = 1,
        gain = 0.6,
        mode = "sequence",
        source_group = "TAUNTS",
        loop = false,
        files = {"Reinforcements_Event1.ogg", "Reinforcements_Event2.ogg", "Reinforcements_Event3.ogg",
                 "Reinforcements_Event4.ogg"}
    },
    DwarfArcherTaunt1 = {
        source_group = "TAUNTS",
        gain = 1,
        loop = false,
        files = {"dwarfArcher_taunt_1.ogg"}
    },
    DwarfArcherTaunt2 = {
        source_group = "TAUNTS",
        gain = 1,
        loop = false,
        files = {"dwarfArcher_taunt_2.ogg"}
    },
    DwarfHeroTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HWVampiressTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    PirateTowerTaunt1 = {
        source_group = "TAUNTS",
        gain = 1,
        loop = false,
        files = {"Pirate_Tower_01a.ogg"}
    },
    PirateTowerTaunt2 = {
        source_group = "TAUNTS",
        gain = 1,
        loop = false,
        files = {"Pirate_Tower_02b.ogg"}
    },
    BossMonkeyMonkeysScreams = {
        source_group = "SFX",
        mode = "random",
        every = 4,
        loop = false,
        gain = 1,
        files = {"boss_mono_chimps_1.ogg", "boss_mono_chimps_2.ogg", "boss_mono_chimps_3.ogg"}
    },
    HeroMonkMultihitScream = {
        source_group = "SPECIALS",
        mode = "random",
        gain = 1,
        loop = false,
        files = {"Hero_Monk_Multihit_scream_1.ogg", "Hero_Monk_Multihit_scream_2.ogg"}
    },
    ArrowSound = {
        source_group = "BULLETS",
        loop = false,
        files = {"Sound_ArrowRelease2.ogg", "Sound_ArrowRelease3.ogg"},
        gain = {0.65, 0.8}
    },
    AxeSound = {
        source_group = "BULLETS",
        loop = false,
        files = {"Sound_BattleAxe.ogg"},
        gain = {0.3, 0.5}
    },
    DeathBig = {
        source_group = "DEATH",
        loop = false,
        files = {"Sound_EnemyBigDead.ogg"},
        gain = {0.6, 0.9}
    },
    DeathSkeleton = {
        source_group = "DEATH",
        loop = false,
        files = {"Sound_EnemySkeletonBreak2.ogg"},
        gain = {0.6, 0.9}
    },
    ShotgunSound = {
        source_group = "BULLETS",
        loop = false,
        files = {"Sound_Shootgun.ogg"},
        gain = {0.65, 0.8}
    },
    HWVampiressTaunt = {
        source_group = "TAUNTS",
        mode = "random",
        gain = 1,
        loop = false,
        files = {"Vampiress-01c.ogg", "Vampiress-02c.ogg", "Vampiress-03c.ogg"}
    },
    HWVampiressTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Vampiress-01c.ogg"}
    },
    HWFrankensteinTaunt = {
        source_group = "TAUNTS",
        mode = "random",
        gain = 1,
        loop = false,
        files = {"FrankyTower-03c.ogg", "FrankyTower-04a.ogg"}
    },
    SaurianSavantPortalLoop = {
        loop = true,
        gain = 0.3,
        ref_counted = true,
        source_group = "REFCOUNTED",
        files = {"savant_portal_loop.ogg"}
    },
    ArchmageTwisterTravel = {
        loop = true,
        gain = 0.3,
        ref_counted = true,
        source_group = "REFCOUNTED",
        files = {"archmage_twister.ogg"}
    },
    HeroMirageDeath = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"assassinHero_taunt_death.ogg"}
    },
    HWFrankensteinUpgradeFrankenstein = {
        loop = false,
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"FrankyTower-02f.ogg"}
    },
    HWFrankensteinUpgradeLightning = {
        loop = false,
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"FrankyTower-01d.ogg"}
    }
}

-- chunkname: @./kr3-desktop/assets/sounds/extra.lua
local kr3_groups = {
    music_screen_slots = {
        sounds = {"MusicMainMenu"}
    },
    music_screen_credits = {
        sounds = {"MusicCredits"}
    },
    music_screen_kr3_end = {
        sounds = {"MusicEndVictory", "MusicSuspense", "MusicCredits"}
    },
    music_stage49 = {
        sounds = {"MusicBattlePrep_49", "MusicBattle_49"}
    },
    music_stage50 = {
        sounds = {"MusicBattlePrep_50", "MusicBattle_50"}
    },
    music_stage51 = {
        sounds = {"MusicBattlePrep_51", "MusicBattle_51"}
    },
    music_stage52 = {
        sounds = {"MusicBattlePrep_52", "MusicBattle_52"}
    },
    music_stage53 = {
        sounds = {"MusicBattlePrep_53", "MusicBattle_53"}
    },
    music_stage54 = {
        sounds = {"MusicBattlePrep_54", "MusicBattle_54"}
    },
    music_stage55 = {
        sounds = {"MusicBattlePrep_55", "MusicBattle_55"}
    },
    music_stage56 = {
        sounds = {"MusicBattlePrep_56", "MusicBattle_56"}
    },
    music_stage57 = {
        sounds = {"MusicBattlePrep_57", "MusicBattle_57"}
    },
    music_stage58 = {
        sounds = {"MusicBattlePrep_58", "MusicBattle_58"}
    },
    music_stage59 = {
        sounds = {"MusicBattlePrep_59", "MusicBattle_59"}
    },
    music_stage60 = {
        sounds = {"MusicBattlePrep_60", "MusicBattle_60"}
    },
    music_stage61 = {
        sounds = {"MusicBattlePrep_61", "MusicBattle_61"}
    },
    music_stage62 = {
        sounds = {"MusicBattlePrep_62", "MusicBattle_62"}
    },
    music_stage63 = {
        sounds = {"MusicBattlePrep_63", "MusicBattle_63", "MusicBossPreFight63", "MusicBossFight"}
    },
    music_stage64 = {
        sounds = {"MusicBattlePrep_64", "MusicBattle_64"}
    },
    music_stage65 = {
        sounds = {"MusicBattlePrep_65", "MusicBattle_65"}
    },
    music_stage66 = {
        sounds = {"MusicBattlePrep_66", "MusicBattle_66"}
    },
    music_stage67 = {
        sounds = {"MusicBattlePrep_67", "MusicBattle_67"}
    },
    music_stage68 = {
        sounds = {"MusicBattlePrep_68", "MusicBattle_68"}
    },
    music_stage69 = {
        sounds = {"MusicBattlePrep_69", "MusicBattle_69"}
    },
    music_stage70 = {
        sounds = {"MusicBattlePrep_70", "MusicBattle_70"}
    },
    -- hero_alleria = {
    --     alias = "ElvesHeroAlleria"
    -- },
    hero_arivan = {
        alias = "ElvesHeroArivan"
    },
    hero_elves_archer = {
        alias = "ElvesHeroEridan"
    },
    hero_elves_denas = {
        alias = "ElvesHeroDenas"
    },
    hero_regson = {
        alias = "ElvesHeroEldritch"
    },
    hero_faustus = {
        alias = "ElvesHeroFaustus"
    },
    hero_xin = {
        alias = "ElvesHeroXin"
    },
    hero_bravebark = {
        alias = "ElvesHeroForestElemental"
    },
    hero_catha = {
        alias = "ElvesHeroCatha"
    },
    hero_veznan = {
        alias = "ElvesHeroVeznan"
    },
    hero_baby_malik = {
        alias = "ElvesHeroBabyMalik"
    },
    hero_rag = {
        alias = "ElvesHeroRag"
    },
    hero_lilith = {
        alias = "ElvesHeroLilith"
    },
    hero_bolverk = {
        alias = "ElvesHeroBolverk"
    },
    hero_bruce = {
        alias = "ElvesHeroBruce"
    },
    hero_durax = {
        alias = "ElvesHeroDurax"
    },
    hero_wilbur = {
        alias = "ElvesHeroGyro"
    },
    hero_lynn = {
        alias = "ElvesHeroLynn"
    },
    hero_phoenix = {
        alias = "ElvesHeroPhoenix"
    },
    common = {
        append = true,
        sounds = {"MeleeSword", "ReinforcementTaunt"},
        files = {"kre_sfx_arivan_fireballsummon[op2].ogg", "kre_sfx_arivan_fireballshot_v2.ogg"}
    },
    ElvesCommonSounds = {
        append = true,
        files = {"assassin_gold.ogg", "Viking_Transform.ogg"}
    },
    ElvesHeroArivan = {
        append = true,
        files = {"archmage_attack.ogg"}
    },
    ElvesHeroAlleria = {
        append = true,
        files = {"Aleria_special_arrow.ogg", "Aleria_wildcat_hit.ogg"}
    },
    ElvesLevelHRSounds = {
        append = true,
        files = {"GalhadriansBastion-01c.ogg", "GalhadriansBastion-02c.ogg"}
    },
    ElvesDrizzt = {
        append = true,
        files = {"kro_sfx_bitteringrancor_drizzt.ogg"}
    },
    ElvesLevelThreeSounds = {
        append = true,
        files = {"mermaid.ogg"}
    },
    ElvesLevelNineSounds = {
        append = true,
        files = {"mermaid.ogg"}
    }
}
local kr3_sounds = {
    MusicMainMenu = {
        source_group = "MUSIC",
        gain = 0.4,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_maintheme[master_25-08].mp3"}
    },
    MusicMap3 = {
        source_group = "MUSIC",
        gain = 0.6,
        loop = true,
        stream = true,
        files = {"kre_bgmusic_map[master_25-08].mp3"}
    },
    MusicCredits = {
        source_group = "MUSIC",
        gain = 0.7,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_creditos[master].mp3"}
    },
    MusicBattlePrep_49 = {
        source_group = "MUSIC",
        gain = 0.6,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t1_prebattle1_[master_25-08].mp3"}
    },
    MusicBattlePrep_50 = {
        source_group = "MUSIC",
        gain = 0.5,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t1_prebattle2[master_30-09].mp3"}
    },
    MusicBattlePrep_51 = {
        source_group = "MUSIC",
        gain = 0.6,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t1_prebattle1_[master_25-08].mp3"}
    },
    MusicBattlePrep_52 = {
        source_group = "MUSIC",
        gain = 0.5,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t1_prebattle2[master_30-09].mp3"}
    },
    MusicBattlePrep_53 = {
        source_group = "MUSIC",
        gain = 0.6,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t1_prebattle1_[master_25-08].mp3"}
    },
    MusicBattlePrep_54 = {
        source_group = "MUSIC",
        gain = 0.5,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t1_prebattle2[master_30-09].mp3"}
    },
    MusicBattlePrep_55 = {
        source_group = "MUSIC",
        gain = 0.5,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t2_prebattle1[master_30-09].mp3"}
    },
    MusicBattlePrep_56 = {
        source_group = "MUSIC",
        gain = 0.3,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t2_prebattle2[master_25-08].mp3"}
    },
    MusicBattlePrep_57 = {
        source_group = "MUSIC",
        gain = 0.5,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t2_prebattle1[master_30-09].mp3"}
    },
    MusicBattlePrep_58 = {
        source_group = "MUSIC",
        gain = 0.3,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t2_prebattle2[master_25-08].mp3"}
    },
    MusicBattlePrep_59 = {
        source_group = "MUSIC",
        gain = 0.5,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t2_prebattle1[master_30-09].mp3"}
    },
    MusicBattlePrep_60 = {
        source_group = "MUSIC",
        gain = 0.3,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t3_prebattle1[master_01-11].mp3"}
    },
    MusicBattlePrep_61 = {
        source_group = "MUSIC",
        gain = 0.3,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t3_prebattle2[master_25-08].mp3"}
    },
    MusicBattlePrep_62 = {
        source_group = "MUSIC",
        gain = 0.3,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t3_prebattle1[master_01-11].mp3"}
    },
    MusicBattlePrep_63 = {
        source_group = "MUSIC",
        gain = 0.3,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t3_prebattle2[master_25-08].mp3"}
    },
    MusicBattlePrep_64 = {
        source_group = "MUSIC",
        gain = 0.6,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t1_prebattle1_[master_25-08].mp3"}
    },
    MusicBattlePrep_65 = {
        source_group = "MUSIC",
        gain = 0.5,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t1_prebattle2[master_30-09].mp3"}
    },
    MusicBattlePrep_66 = {
        source_group = "MUSIC",
        gain = 0.6,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t1_prebattle1_[master_25-08].mp3"}
    },
    MusicBattlePrep_67 = {
        source_group = "MUSIC",
        gain = 0.6,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t1_prebattle1_[master_25-08].mp3"}
    },
    MusicBattlePrep_68 = {
        source_group = "MUSIC",
        gain = 0.6,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t1_prebattle1_[master_25-08].mp3"}
    },
    MusicBattlePrep_69 = {
        source_group = "MUSIC",
        gain = 0.5,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t2_prebattle1[master_30-09].mp3"}
    },
    MusicBattlePrep_70 = {
        source_group = "MUSIC",
        gain = 0.3,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t2_prebattle2[master_25-08].mp3"}
    },
    MusicBattle_49 = {
        source_group = "MUSIC",
        gain = 0.2,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t1_battle1_v4[master_03-11].mp3"}
    },
    MusicBattle_50 = {
        source_group = "MUSIC",
        gain = 0.2,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t1_battle2[master_25-08].mp3"}
    },
    MusicBattle_51 = {
        source_group = "MUSIC",
        gain = 0.2,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t1_battle1_v4[master_03-11].mp3"}
    },
    MusicBattle_52 = {
        source_group = "MUSIC",
        gain = 0.2,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t1_battle2[master_25-08].mp3"}
    },
    MusicBattle_53 = {
        source_group = "MUSIC",
        gain = 0.2,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t1_battle1_v4[master_03-11].mp3"}
    },
    MusicBattle_54 = {
        source_group = "MUSIC",
        gain = 0.2,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t1_battle2[master_25-08].mp3"}
    },
    MusicBattle_55 = {
        source_group = "MUSIC",
        gain = 0.2,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t2_battle1.mp3"}
    },
    MusicBattle_56 = {
        source_group = "MUSIC",
        gain = 0.3,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t2_battle2[master_03-09].mp3"}
    },
    MusicBattle_57 = {
        source_group = "MUSIC",
        gain = 0.2,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t2_battle1.mp3"}
    },
    MusicBattle_58 = {
        source_group = "MUSIC",
        gain = 0.3,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t2_battle2[master_03-09].mp3"}
    },
    MusicBattle_59 = {
        source_group = "MUSIC",
        gain = 0.2,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t2_battle1.mp3"}
    },
    MusicBattle_60 = {
        source_group = "MUSIC",
        gain = 0.3,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t3_battle1[master_03-11].mp3"}
    },
    MusicBattle_61 = {
        source_group = "MUSIC",
        gain = 0.3,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t3_battle2[master_30-10].mp3"}
    },
    MusicBattle_62 = {
        source_group = "MUSIC",
        gain = 0.3,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t3_battle1[master_03-11].mp3"}
    },
    MusicBattle_63 = {
        source_group = "MUSIC",
        gain = 0.3,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t3_battle2[master_30-10].mp3"}
    },
    MusicBattle_64 = {
        source_group = "MUSIC",
        gain = 0.2,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t1_battle1_v4[master_03-11].mp3"}
    },
    MusicBattle_65 = {
        source_group = "MUSIC",
        gain = 0.2,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t1_battle2[master_25-08].mp3"}
    },
    MusicBattle_66 = {
        source_group = "MUSIC",
        gain = 0.2,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t1_battle1_v4[master_03-11].mp3"}
    },
    MusicBattle_67 = {
        source_group = "MUSIC",
        gain = 0.2,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t1_battle1_v4[master_03-11].mp3"}
    },
    MusicBattle_68 = {
        source_group = "MUSIC",
        gain = 0.2,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t1_battle1_v4[master_03-11].mp3"}
    },
    MusicBattle_69 = {
        source_group = "MUSIC",
        gain = 0.2,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t2_battle1.mp3"}
    },
    MusicBattle_70 = {
        source_group = "MUSIC",
        gain = 0.3,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_t2_battle2[master_03-09].mp3"}
    },
    MusicBossPreFight63 = {
        source_group = "MUSIC",
        gain = 0.7,
        stream = true,
        files = {"kro_bgmusic_bossfight_prebattle_v2[master_03-11].mp3"}
    },
    MusicBossFight = {
        source_group = "MUSIC",
        gain = 0.4,
        loop = true,
        stream = true,
        files = {"kro_bgmusic_bossfight[master].mp3"}
    },
    MusicEndVictory = {
        source_group = "MUSIC",
        gain = 0.7,
        stream = true,
        files = {"kro_bgmusic_victory[master_03-11].mp3"}
    },
    MusicEndCredits = {
        source_group = "MUSIC",
        gain = 0.7,
        stream = true,
        files = {"kro_bgmusic_creditos[master].mp3"}
    },
    MusicSuspense = {
        source_group = "MUSIC",
        gain = 0.7,
        stream = true,
        files = {"MusicSuspense.mp3"}
    },
    MeleeSword = {
        ignore = 0.45,
        gain = 0.2,
        mode = "sequence",
        source_group = "SWORDS",
        loop = false,
        files = {"Sound_SoldiersFighting-01.ogg", "Sound_SoldiersFighting-02.ogg", "Sound_SoldiersFighting-03.ogg",
                 "Sound_SoldiersFighting-04.ogg", "Sound_SoldiersFighting-05.ogg"}
    },
    ReinforcementTaunt = {
        ignore = 1,
        gain = 0.35,
        mode = "sequence",
        source_group = "TAUNTS",
        loop = false,
        files = {"Reinforcements_01b.ogg", "Reinforcements_02a.ogg", "Reinforcements_03c.ogg"}
    },
    ElvesFinalBossCastSpell = {
        source_group = "SFX",
        gain = 1,
        loop = false,
        mode = "random",
        files = {"kro_sfx_spidergoddess_castspell.ogg", "kro_sfx_spidergoddess_castspellwithlaughter.ogg"}
    },
    SoldierDruidBearRallyChange = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Viking_Transform.ogg"}
    },
    ElvesHeroAlleriaShoot = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Aleria_special_arrow.ogg"}
    },
    ElvesAlleriaCatHit = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Aleria_wildcat_hit.ogg"}
    },
    ElvesBajNimenBossShadowImpact = {
        source_group = "BULLETS",
        gain = 0.3,
        loop = false,
        ignore = 0.25,
        files = {"kro_sfx_bitteringrancor_boss-shadowstorm[impact].ogg"}
    },
    ElvesBajNimenBossShadowTravel = {
        source_group = "BULLETS",
        gain = 0.5,
        loop = false,
        ignore = 0.25,
        files = {"kro_sfx_bitteringrancor_boss-shadowstorm[travel].ogg"}
    },
    ElvesHeroGyroBombsMarch = {
        loop = true,
        gain = 0.8,
        ref_counted = true,
        source_group = "SFX",
        files = {"kro_sfx_wilbur_bombsmarch[op1].ogg"}
    },
    ElvesTowerBastionInsertTaunt = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"GalhadriansBastion-01c.ogg"}
    },
    ElvesTowerBastionRazorEdge = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"GalhadriansBastion-02c.ogg"}
    },
    ArrowSound = {
        source_group = "BULLETS",
        loop = false,
        files = {"Sound_ArrowRelease2.ogg", "Sound_ArrowRelease3.ogg"},
        gain = {0.65, 0.8}
    },
    AxeSound = {
        source_group = "BULLETS",
        loop = false,
        files = {"Sound_BattleAxe.ogg"},
        gain = {0.3, 0.5}
    },
    DeathBig = {
        source_group = "DEATH",
        loop = false,
        files = {"Sound_EnemyBigDead.ogg"},
        gain = {0.6, 0.9}
    },
    ShotgunSound = {
        source_group = "BULLETS",
        loop = false,
        files = {"Sound_Shootgun.ogg"},
        gain = {0.65, 0.8}
    },
    ElvesCreepHoplite = {
        loop = false,
        gain = 0.5,
        source_group = "SFX",
        files = {"kro_sfx_hoplite_summon_v3[singrowl].ogg"}
    },
    GoldCoin = {
        loop = false,
        gain = 0.6,
        source_group = "SPECIALS",
        files = {"assassin_gold.ogg"}
    },
    ElvesGoldCoin = {
        loop = false,
        gain = 0.6,
        source_group = "SPECIALS",
        files = {"assassin_gold.ogg"}
    },
    AssassinGold = {
        loop = false,
        gain = 0.6,
        source_group = "SPECIALS",
        files = {"assassin_gold.ogg"}
    },
    ElvesHeroArivanRegularRay = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"archmage_attack.ogg"}
    },
    ElvesDrizztUnsheathe = {
        loop = false,
        gain = 0.5,
        source_group = "SFX",
        files = {"kro_sfx_bitteringrancor_drizzt.ogg"}
    },
    ElvesWaterfallMid = {
        loop = false,
        gain = 0.6,
        source_group = "SFX",
        files = {"mermaid.ogg"}
    },
    ElvesFinalBossWebspin = {
        source_group = "SFX",
        gain = 1,
        loop = false,
        interruptible = true,
        files = {"kro_sfx_mactans_webspin[towers].ogg"}
    },
    ElvesFinalBossWebground = {
        source_group = "SFX",
        gain = 1,
        loop = false,
        interruptible = true,
        files = {"kro_sfx_mactans_webground[conhissing].ogg"}
    },
    ElvenWoodsAmbienceSound = {
        loop = false,
        mode = "random",
        gain = 0.3,
        source_group = "SFX",
        files = {"kre_sfx_ambience_singlebirdandstream.ogg"}
    },
    FaerieGroveAmbienceSound = {
        loop = false,
        mode = "random",
        gain = 0.8,
        source_group = "SFX",
        files = {"kro_sfx_ambience_windandowls1.ogg"}
    },
    FaerieGroveAmbienceTenElevenSound = {
        loop = false,
        mode = "random",
        gain = 0.8,
        source_group = "SFX",
        files = {"kro_sfx_ambience_windandowls1.ogg", "kro_sfx_ambience_branchesandfaery1.ogg",
                 "kro_sfx_ambience_branchesandfaery2.ogg"}
    },
    MetropolisAmbienceSound = {
        loop = false,
        mode = "random",
        gain = 0.3,
        source_group = "SFX",
        files = {"kro_sfx_ambience_winds[op1].ogg", "kro_sfx_ambience_winds[op2].ogg"}
    },
    MetropolisAmbienceSoundFourteenFifteen = {
        loop = false,
        mode = "random",
        gain = 0.3,
        source_group = "SFX",
        files = {"kro_sfx_ambience_winds[op1].ogg", "kro_sfx_ambience_winds[op2].ogg",
                 "kro_sfx_ambience_spiders_v2[op1].ogg"}
    },
    ElvenWoodsAmbienceEndlessSound = {
        loop = false,
        mode = "random",
        gain = 0.3,
        source_group = "SFX",
        files = {"kre_sfx_ambience_singlebirdandstream.ogg", "kro_sfx_ambience_wardrums[op1].ogg",
                 "kro_sfx_ambience_wardrums[op2].ogg", "kro_sfx_ambience_wardrums[op3].ogg"}
    },
    HulkingRageAmbienceSound = {
        loop = false,
        mode = "random",
        gain = 0.3,
        source_group = "SFX",
        files = {"kre_sfx_ambience_singlebirdandstream.ogg", "kro_sfx_hulkingrage_mining_v2[op1].ogg",
                 "kro_sfx_hulkingrage_mining_v2[op2].ogg"}
    }
}

-- local kr5_groups =  {
--     hero_hunter = {
--         alias = "hero_hunter"
--     },
--     hero_space_elf = {
--         alias = "hero_space_elf"
--     },
--     hero_raelyn = {
--         alias = "hero_raelyn"
--     },
--     hero_dragon_gem = {
--         alias = "hero_dragon_gem"
--     },
--     hero_witch = {
--         alias = "hero_witch"
--     },
--     hero_venom = {
--         alias = "hero_venom"
--     },
--     hero_dragon_bone = {
--         alias = "hero_dragon_bone"
--     }
-- }

local merge_conflict_tables = require("script_utils").merge_conflict_tables

local sounds = merge_conflict_tables(kr1_sounds, kr2_sounds)
sounds = merge_conflict_tables(sounds, kr3_sounds)
local groups = merge_conflict_tables(kr1_groups, kr2_groups)
groups = merge_conflict_tables(groups, kr3_groups)
-- groups = merge_conflict_tables(groups, kr5_groups)
return {
    sounds = sounds,
    groups = groups
}
