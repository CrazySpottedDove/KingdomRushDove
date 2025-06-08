﻿-- chunkname: @./kr1/data/waves/level81_waves_endless.lua

return {
	interval_less_needed = 0,
	nextWaveRewardMoneyMultiplier = 3.5,
	gold = 340,
	interval_less_cut = 0,
	lifes = 10,
	waves_to_increment = 10,
	max_paths = 5,
	bossConfig = {
		powerConfig = {
			powerProgressionWaveStart = 11,
			damage = {
				damagePerTickIncrement = 1,
				range = 150,
				damageDurationIncrement = 0,
				damagePerTick = 4,
				damageDuration = 1,
				durationIncrement = 0.05,
				duration = 6,
				tickTime = 15,
				pathNodesConfig = {
					{
						nodesBeforeEnd = 25,
						nodesAfterStart = 60
					},
					{
						nodesBeforeEnd = 25,
						nodesAfterStart = 55
					},
					{
						nodesBeforeEnd = 25,
						nodesAfterStart = 50
					},
					{
						nodesBeforeEnd = 30,
						nodesAfterStart = 50
					},
					{
						nodesBeforeEnd = 30,
						nodesAfterStart = 45
					}
				}
			},
			healing = {
				durationIncrement = 0.25,
				range = 150,
				healthPerTickIncrement = 2,
				tickTime = 15,
				duration = 6,
				healthPerTick = 7,
				pathNodesConfig = {
					{
						nodesBeforeEnd = 25,
						nodesAfterStart = 50
					},
					{
						nodesBeforeEnd = 25,
						nodesAfterStart = 50
					},
					{
						nodesBeforeEnd = 25,
						nodesAfterStart = 50
					},
					{
						nodesBeforeEnd = 30,
						nodesAfterStart = 50
					},
					{
						nodesBeforeEnd = 30,
						nodesAfterStart = 35
					}
				}
			},
			speed = {
				durationIncrement = 0.5,
				range = 150,
				speedModifierDuration = 3,
				speedModifierIncrement = 0.015,
				duration = 10,
				speedModifier = 1.5,
				pathNodesConfig = {
					{
						nodesBeforeEnd = 60,
						nodesAfterStart = 30
					},
					{
						nodesBeforeEnd = 54,
						nodesAfterStart = 30
					},
					{
						nodesBeforeEnd = 56,
						nodesAfterStart = 45
					},
					{
						nodesBeforeEnd = 74,
						nodesAfterStart = 38
					},
					{
						nodesBeforeEnd = 64,
						nodesAfterStart = 35
					}
				}
			}
		}
	},
	chancesToUseNextDifficulty = {
		0.1,
		0.2,
		0.2,
		0.3,
		0.5
	},
	difficulties = {
		{
			multiple_paths_chance_increment = 3,
			multiple_paths_chance = 0,
			max_paths = 2,
			bossConfig = {
				powerCooldownMin = 10,
				powerCooldownMax = 15,
				powerMultiChance = 0,
				powerChance = 0,
				powerChanceIncrement = 0,
				powerDistribution = {
					0.4,
					0.3,
					0.3
				}
			},
			bossWaves = {
				{
					next_wave_interval = 1000,
					name = "T1-Boss",
					spawns = {
						{
							interval = 0,
							max_same = 0,
							cant_cicle = 1,
							creep = "enemy_hobgoblin",
							cant = 1,
							cant_increment = 0,
							interval_next = 0,
							path = 0
						}
					}
				}
			},
			waves = {
				{
					next_wave_interval = 300,
					name = "T0-Gobs-a",
					spawns = {
						{
							interval = 20,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_goblin",
							cant = 5,
							cant_increment = 1,
							interval_next = 30,
							path = 0
						},
						{
							interval = 20,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_goblin",
							cant = "5",
							cant_increment = 1,
							interval_next = 50,
							path = 0
						}
					}
				},
				{
					next_wave_interval = 300,
					name = "T0-GobsOrcs-b",
					spawns = {
						{
							interval = 20,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_goblin",
							cant = 5,
							cant_increment = 1,
							interval_next = 30,
							path = 0
						},
						{
							interval = 30,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_fat_orc",
							cant = 4,
							cant_increment = 1,
							interval_next = 60,
							path = 0
						}
					}
				},
				{
					next_wave_interval = 500,
					name = "T0-OrcsGobs",
					spawns = {
						{
							interval = 30,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_fat_orc",
							cant = 4,
							cant_increment = 1,
							interval_next = 150,
							path = 2
						},
						{
							interval = 20,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_goblin",
							cant = 6,
							cant_increment = 1,
							interval_next = 20,
							path = 0
						}
					}
				},
				{
					next_wave_interval = 300,
					name = "T0-Wulf",
					spawns = {
						{
							interval = 20,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_wolf_small",
							cant = 6,
							cant_increment = 1,
							interval_next = 90,
							path = 0
						}
					}
				},
				{
					next_wave_interval = 500,
					name = "T0-Orcs",
					spawns = {
						{
							interval = 30,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_fat_orc",
							cant = 5,
							cant_increment = 1,
							interval_next = 50,
							path = 2
						}
					}
				},
				{
					next_wave_interval = 500,
					name = "T0-OrcsSham",
					spawns = {
						{
							interval = 25,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_fat_orc",
							cant = 2,
							cant_increment = 1,
							interval_next = 50,
							path = 2
						},
						{
							interval = 30,
							max_same = 0,
							cant_cicle = 4,
							creep = "enemy_shaman",
							cant = 1,
							cant_increment = 1,
							interval_next = 20,
							path = 2
						},
						{
							interval = 30,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_fat_orc",
							cant = 2,
							cant_increment = 1,
							interval_next = 60,
							path = 2
						}
					}
				}
			}
		},
		{
			multiple_paths_chance_increment = 5,
			multiple_paths_chance = 0,
			max_paths = 4,
			bossConfig = {
				powerCooldownMin = 6,
				powerCooldownMax = 12,
				powerMultiChance = 0,
				powerChance = 0.1,
				powerChanceIncrement = 0.02,
				powerDistribution = {
					1,
					0,
					0
				}
			},
			bossWaves = {
				{
					next_wave_interval = 2000,
					name = "T1-Boss",
					spawns = {
						{
							interval = 0,
							max_same = 0,
							cant_cicle = 1,
							creep = "enemy_hobgoblin",
							cant = 1,
							cant_increment = 0,
							interval_next = 0,
							path = 0
						}
					}
				}
			},
			waves = {
				{
					next_wave_interval = 450,
					name = "T1-Gobs-a",
					spawns = {
						{
							interval = 15,
							max_same = 0,
							cant_cicle = 1,
							creep = "enemy_goblin",
							cant = 5,
							cant_increment = 1,
							interval_next = 50,
							path = 0
						},
						{
							interval = 12,
							max_same = 0,
							cant_cicle = 1,
							creep = "enemy_goblin",
							cant = "5",
							cant_increment = 1,
							interval_next = 50,
							path = 0
						},
						{
							interval = 15,
							max_same = 0,
							cant_cicle = 1,
							creep = "enemy_goblin",
							cant = 5,
							cant_increment = 1,
							interval_next = 50,
							path = 0
						},
						{
							interval = 12,
							max_same = 0,
							cant_cicle = 1,
							creep = "enemy_goblin",
							cant = 5,
							cant_increment = 1,
							interval_next = 30,
							path = 0
						}
					}
				},
				{
					next_wave_interval = 450,
					name = "T1-GobsOrcs-b",
					spawns = {
						{
							interval = 15,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_goblin",
							cant = 5,
							cant_increment = 1,
							interval_next = 30,
							path = 0
						},
						{
							interval = 12,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_goblin",
							cant = 5,
							cant_increment = 1,
							interval_next = 0,
							path = 0
						},
						{
							interval = 25,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_fat_orc",
							cant = 5,
							cant_increment = 3,
							interval_next = 60,
							path = 0
						}
					}
				},
				{
					next_wave_interval = 600,
					name = "T1-OrcsGobs",
					spawns = {
						{
							interval = 0,
							max_same = 0,
							cant_cicle = 0,
							creep = "enemy_fat_orc",
							cant = 1,
							cant_increment = 0,
							interval_next = 0,
							path = 1
						},
						{
							interval = 0,
							max_same = 0,
							cant_cicle = 0,
							creep = "enemy_fat_orc",
							cant = 1,
							cant_increment = 0,
							interval_next = 150,
							path = 2
						},
						{
							interval = 15,
							max_same = 0,
							cant_cicle = 1,
							creep = "enemy_goblin",
							cant = 10,
							cant_increment = 2,
							interval_next = 0,
							path = 0
						},
						{
							interval = 25,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_fat_orc",
							cant = 3,
							cant_increment = 3,
							interval_next = 60,
							path = 2
						}
					}
				},
				{
					next_wave_interval = 450,
					name = "T1-Wulf",
					spawns = {
						{
							interval = 15,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_wolf_small",
							cant = 4,
							cant_increment = 1,
							interval_next = 90,
							path = 0
						},
						{
							interval = 15,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_wolf_small",
							cant = 4,
							cant_increment = 1,
							interval_next = 40,
							path = 0
						}
					}
				},
				{
					next_wave_interval = 650,
					name = "T1-Orcs",
					spawns = {
						{
							interval = 0,
							max_same = 0,
							cant_cicle = 0,
							creep = "enemy_fat_orc",
							cant = 1,
							cant_increment = 0,
							interval_next = 25,
							path = 0
						},
						{
							interval = 0,
							max_same = 0,
							cant_cicle = 0,
							creep = "enemy_fat_orc",
							cant = 1,
							cant_increment = 0,
							interval_next = 0,
							path = 1
						},
						{
							interval = 0,
							max_same = 0,
							cant_cicle = 0,
							creep = "enemy_fat_orc",
							cant = 1,
							cant_increment = 0,
							interval_next = 50,
							path = 2
						},
						{
							interval = 30,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_fat_orc",
							cant = 4,
							cant_increment = 3,
							interval_next = 50,
							path = 2
						}
					}
				},
				{
					next_wave_interval = 650,
					name = "T1-OrcsSham",
					spawns = {
						{
							interval = 30,
							max_same = 0,
							cant_cicle = 1,
							creep = "enemy_fat_orc",
							cant = 2,
							cant_increment = 1,
							interval_next = 50,
							path = 2
						},
						{
							interval = 30,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_shaman",
							cant = 1,
							cant_increment = 1,
							interval_next = 20,
							path = 2
						},
						{
							interval = 30,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_fat_orc",
							cant = 3,
							cant_increment = 1,
							interval_next = 60,
							path = 2
						}
					}
				},
				{
					next_wave_interval = 600,
					name = "T2-Gargoyle",
					spawns = {
						{
							interval = 35,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_gargoyle",
							cant = 4,
							cant_increment = 1,
							interval_next = 100,
							path = 0
						}
					}
				}
			}
		},
		{
			multiple_paths_chance_increment = 6,
			multiple_paths_chance = 10,
			max_paths = 3,
			bossConfig = {
				powerCooldownMin = 6,
				powerCooldownMax = 12,
				powerMultiChance = 0.4,
				powerChance = 0.2,
				powerChanceIncrement = 0.02,
				powerDistribution = {
					0.4,
					0.3,
					0.3
				}
			},
			bossWaves = {
				{
					next_wave_interval = 2000,
					name = "T1-Boss",
					spawns = {
						{
							interval = 0,
							max_same = 0,
							cant_cicle = 1,
							creep = "enemy_hobgoblin",
							cant = 1,
							cant_increment = 0,
							interval_next = 0,
							path = 0
						}
					}
				}
			},
			waves = {
				{
					next_wave_interval = 800,
					name = "T2-OrcSham",
					spawns = {
						{
							interval = 0,
							max_same = 0,
							cant_cicle = 0,
							creep = "enemy_fat_orc",
							cant = 1,
							cant_increment = 0,
							interval_next = 30,
							path = 1
						},
						{
							interval = 0,
							max_same = 0,
							cant_cicle = 0,
							creep = "enemy_fat_orc",
							cant = 1,
							cant_increment = 0,
							interval_next = 0,
							path = 2
						},
						{
							interval = 0,
							max_same = 0,
							cant_cicle = 0,
							creep = "enemy_fat_orc",
							cant = 1,
							cant_increment = 0,
							interval_next = 30,
							path = 1
						},
						{
							interval = 30,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_shaman",
							cant = 2,
							cant_increment = 1,
							interval_next = 50,
							path = 0
						},
						{
							interval = 25,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_fat_orc",
							cant = 6,
							cant_increment = 3,
							interval_next = 30,
							path = 2
						},
						{
							interval = 30,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_shaman",
							cant = 2,
							cant_increment = 1,
							interval_next = 50,
							path = 0
						}
					}
				},
				{
					next_wave_interval = 800,
					name = "T2-OgreShamOrc",
					spawns = {
						{
							interval = 80,
							max_same = 0,
							cant_cicle = 5,
							creep = "enemy_ogre",
							cant = 2,
							cant_increment = 1,
							interval_next = 100,
							path = 0
						},
						{
							interval = 30,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_shaman",
							cant = 3,
							cant_increment = 1,
							interval_next = 50,
							path = 0
						},
						{
							interval = 25,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_fat_orc",
							cant = 5,
							cant_increment = 1,
							interval_next = 50,
							path = 2
						}
					}
				},
				{
					next_wave_interval = 600,
					name = "T2-WolfWorg",
					spawns = {
						{
							interval = 15,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_wolf_small",
							cant = 8,
							cant_increment = 1,
							interval_next = 35,
							path = 0
						},
						{
							interval = 25,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_wolf",
							cant = 4,
							cant_increment = 1,
							interval_next = 50,
							path = 0
						},
						{
							interval = 25,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_wolf",
							cant = 4,
							cant_increment = 1,
							interval_next = 50,
							path = 0
						}
					}
				},
				{
					next_wave_interval = 800,
					name = "T2-OrcsGobsZapp",
					spawns = {
						{
							interval = 15,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_goblin",
							cant = 4,
							cant_increment = 1,
							interval_next = 40,
							path = 2
						},
						{
							interval = 20,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_goblin_zapper",
							cant = 2,
							cant_increment = 1,
							interval_next = 60,
							path = 2
						},
						{
							interval = 15,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_goblin",
							cant = 6,
							cant_increment = 1,
							interval_next = 20,
							path = 2
						},
						{
							interval = 70,
							max_same = 0,
							cant_cicle = 5,
							creep = "enemy_ogre",
							cant = 1,
							cant_increment = 1,
							interval_next = 100,
							path = 2
						},
						{
							interval = 25,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_fat_orc",
							cant = 6,
							cant_increment = 1,
							interval_next = 50,
							path = 2
						}
					}
				},
				{
					next_wave_interval = 900,
					name = "T2-Ogre",
					spawns = {
						{
							interval = 80,
							max_same = 0,
							cant_cicle = 4,
							creep = "enemy_ogre",
							cant = 3,
							cant_increment = 1,
							interval_next = 150,
							path = 2
						},
						{
							interval = 25,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_fat_orc",
							cant = 4,
							cant_increment = 1,
							interval_next = 50,
							path = 2
						}
					}
				},
				{
					next_wave_interval = 700,
					name = "T2-Gargoyle",
					spawns = {
						{
							interval = 20,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_gargoyle",
							cant = 3,
							cant_increment = 1,
							interval_next = 60,
							path = 0
						},
						{
							interval = 20,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_gargoyle",
							cant = 3,
							cant_increment = 1,
							interval_next = 60,
							path = 0
						}
					}
				}
			}
		},
		{
			multiple_paths_chance_increment = 5,
			multiple_paths_chance = 35,
			max_paths = 3,
			bossConfig = {
				powerCooldownMin = 7,
				powerCooldownMax = 14,
				powerMultiChance = 0.5,
				powerChance = 0.3,
				powerChanceIncrement = 0.02,
				powerDistribution = {
					0.34,
					0.33,
					0.33
				}
			},
			bossWaves = {
				{
					next_wave_interval = 1250,
					name = "T1-Boss",
					spawns = {
						{
							interval = 0,
							max_same = 0,
							cant_cicle = 1,
							creep = "enemy_hobgoblin",
							cant = 1,
							cant_increment = 0,
							interval_next = 0,
							path = 0
						}
					}
				}
			},
			waves = {
				{
					next_wave_interval = 700,
					name = "T3-OrcArmSham",
					spawns = {
						{
							interval = 35,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_orc_armored",
							cant = 3,
							cant_increment = 1,
							interval_next = 100,
							path = 0
						},
						{
							interval = 30,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_shaman",
							cant = 2,
							cant_increment = 1,
							interval_next = 50,
							path = 2
						},
						{
							interval = 35,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_orc_armored",
							cant = 3,
							cant_increment = 1,
							interval_next = 100,
							path = 0
						},
						{
							interval = 30,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_shaman",
							cant = 2,
							cant_increment = 1,
							interval_next = 50,
							path = 2
						}
					}
				},
				{
					next_wave_interval = 1000,
					name = "T3-OrcArmOgre",
					spawns = {
						{
							interval = 0,
							max_same = 0,
							cant_cicle = 0,
							creep = "enemy_orc_armored",
							cant = 1,
							cant_increment = 0,
							interval_next = 25,
							path = 0
						},
						{
							interval = 0,
							max_same = 0,
							cant_cicle = 0,
							creep = "enemy_orc_armored",
							cant = 1,
							cant_increment = 0,
							interval_next = 0,
							path = 1
						},
						{
							interval = 0,
							max_same = 0,
							cant_cicle = 0,
							creep = "enemy_orc_armored",
							cant = 1,
							cant_increment = 0,
							interval_next = 20,
							path = 2
						},
						{
							interval = 70,
							max_same = 0,
							cant_cicle = 4,
							creep = "enemy_ogre",
							cant = 2,
							cant_increment = 1,
							interval_next = 100,
							path = 2
						},
						{
							interval = 35,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_orc_armored",
							cant = 3,
							cant_increment = 1,
							interval_next = 60,
							path = 0
						}
					}
				},
				{
					next_wave_interval = 750,
					name = "T3-WorgOrcRider",
					spawns = {
						{
							interval = 20,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_wolf",
							cant = 5,
							cant_increment = 1,
							interval_next = 20,
							path = 0
						},
						{
							interval = 40,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_orc_rider",
							cant = 2,
							cant_increment = 1,
							interval_next = 200,
							path = 2
						},
						{
							interval = 20,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_wolf",
							cant = 5,
							cant_increment = 1,
							interval_next = 20,
							path = 0
						}
					}
				},
				{
					next_wave_interval = 850,
					name = "T3-OrcRiderZapp",
					spawns = {
						{
							interval = 40,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_orc_rider",
							cant = 4,
							cant_increment = 1,
							interval_next = 40,
							path = 2
						},
						{
							interval = 25,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_goblin_zapper",
							cant = 3,
							cant_increment = 1,
							interval_next = 100,
							path = 2
						},
						{
							interval = 25,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_goblin_zapper",
							cant = 3,
							cant_increment = 1,
							interval_next = 50,
							path = 2
						}
					}
				},
				{
					next_wave_interval = 950,
					name = "T3-OrcArmShamOgre",
					spawns = {
						{
							interval = 35,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_orc_armored",
							cant = 3,
							cant_increment = 1,
							interval_next = 60,
							path = 2
						},
						{
							interval = 30,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_shaman",
							cant = 3,
							cant_increment = 1,
							interval_next = 50,
							path = 2
						},
						{
							interval = 70,
							max_same = 0,
							cant_cicle = 4,
							creep = "enemy_ogre",
							cant = 2,
							cant_increment = 1,
							interval_next = 150,
							path = 2
						},
						{
							interval = 30,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_shaman",
							cant = 3,
							cant_increment = 1,
							interval_next = 50,
							path = 2
						}
					}
				},
				{
					next_wave_interval = 950,
					name = "T3-OrcArmOrcrider",
					spawns = {
						{
							interval = 0,
							max_same = 0,
							cant_cicle = 0,
							creep = "enemy_orc_armored",
							cant = 1,
							cant_increment = 0,
							interval_next = 35,
							path = 0
						},
						{
							interval = 0,
							max_same = 0,
							cant_cicle = 0,
							creep = "enemy_orc_armored",
							cant = 1,
							cant_increment = 0,
							interval_next = 0,
							path = 1
						},
						{
							interval = 0,
							max_same = 0,
							cant_cicle = 0,
							creep = "enemy_orc_armored",
							cant = 1,
							cant_increment = 0,
							interval_next = 60,
							path = 2
						},
						{
							interval = 35,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_orc_armored",
							cant = 3,
							cant_increment = 1,
							interval_next = 200,
							path = 2
						},
						{
							interval = 40,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_orc_rider",
							cant = 2,
							cant_increment = 1,
							interval_next = 60,
							path = 2
						}
					}
				},
				{
					next_wave_interval = 800,
					name = "T3-ZappOgre",
					spawns = {
						{
							interval = 35,
							max_same = 0,
							cant_cicle = 4,
							creep = "enemy_goblin_zapper",
							cant = 2,
							cant_increment = 1,
							interval_next = 20,
							path = 0
						},
						{
							interval = 70,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_ogre",
							cant = 3,
							cant_increment = 1,
							interval_next = 200,
							path = 1
						},
						{
							interval = 35,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_orc_armored",
							cant = 4,
							cant_increment = 1,
							interval_next = 120,
							path = 2
						},
						{
							interval = 35,
							max_same = 0,
							cant_cicle = 5,
							creep = "enemy_goblin_zapper",
							cant = 3,
							cant_increment = 2,
							interval_next = 60,
							path = 2
						}
					}
				},
				{
					next_wave_interval = 700,
					name = "T3-Gargoyle",
					spawns = {
						{
							interval = 20,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_gargoyle",
							cant = 4,
							cant_increment = 1,
							interval_next = 60,
							path = 0
						},
						{
							interval = 20,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_gargoyle",
							cant = 4,
							cant_increment = 1,
							interval_next = 60,
							path = 0
						},
						{
							interval = 20,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_gargoyle",
							cant = 4,
							cant_increment = 1,
							interval_next = 60,
							path = 0
						},
						{
							interval = 20,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_gargoyle",
							cant = 4,
							cant_increment = 1,
							interval_next = 60,
							path = 0
						}
					}
				}
			}
		},
		{
			multiple_paths_chance_increment = 5,
			multiple_paths_chance = 40,
			max_paths = 4,
			bossConfig = {
				powerCooldownMin = 6,
				powerCooldownMax = 12,
				powerMultiChance = 0.6,
				powerChance = 0.5,
				powerChanceIncrement = 0.02,
				powerDistribution = {
					0.34,
					0.33,
					0.33
				}
			},
			bossWaves = {
				{
					next_wave_interval = 1000,
					name = "T1-Boss",
					spawns = {
						{
							interval = 0,
							max_same = 0,
							cant_cicle = 1,
							creep = "enemy_hobgoblin",
							cant = 1,
							cant_increment = 0,
							interval_next = 0,
							path = 0
						}
					}
				}
			},
			waves = {
				{
					next_wave_interval = 750,
					name = "T4-OrcArmShOgre",
					spawns = {
						{
							interval = 25,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_orc_armored",
							cant = 6,
							cant_increment = 1,
							interval_next = 70,
							path = 0
						},
						{
							interval = 20,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_shaman",
							cant = 5,
							cant_increment = 1,
							interval_next = 30,
							path = 2
						},
						{
							interval = 60,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_ogre",
							cant = 3,
							cant_increment = 1,
							interval_next = 100,
							path = 0
						},
						{
							interval = 20,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_shaman",
							cant = 5,
							cant_increment = 1,
							interval_next = 50,
							path = 2
						}
					}
				},
				{
					next_wave_interval = 950,
					name = "T4-OrcArmOgreOrcRider",
					spawns = {
						{
							interval = 40,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_orc_rider",
							cant = 3,
							cant_increment = 1,
							interval_next = 200,
							path = 0
						},
						{
							interval = 30,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_orc_armored",
							cant = 5,
							cant_increment = 1,
							interval_next = 60,
							path = 2
						},
						{
							interval = 60,
							max_same = 0,
							cant_cicle = 4,
							creep = "enemy_ogre",
							cant = 3,
							cant_increment = 1,
							interval_next = 100,
							path = 0
						}
					}
				},
				{
					next_wave_interval = 800,
					name = "T4-OrcRider",
					spawns = {
						{
							interval = 40,
							max_same = 0,
							cant_cicle = 4,
							creep = "enemy_orc_rider",
							cant = 3,
							cant_increment = 1,
							interval_next = 150,
							path = 0
						},
						{
							interval = 40,
							max_same = 0,
							cant_cicle = 4,
							creep = "enemy_orc_rider",
							cant = 3,
							cant_increment = 1,
							interval_next = 150,
							path = 0
						},
						{
							interval = 40,
							max_same = 0,
							cant_cicle = 5,
							creep = "enemy_orc_rider",
							cant = 3,
							cant_increment = 1,
							interval_next = 150,
							path = 0
						}
					}
				},
				{
					next_wave_interval = 850,
					name = "T4-GobTrollOrcZapp",
					spawns = {
						{
							interval = 15,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_goblin",
							cant = 12,
							cant_increment = 1,
							interval_next = 40,
							path = 2
						},
						{
							interval = 150,
							max_same = 0,
							cant_cicle = 5,
							creep = "enemy_forest_troll",
							cant = 1,
							cant_increment = 1,
							interval_next = 200,
							path = 2
						},
						{
							interval = 25,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_fat_orc",
							cant = 15,
							cant_increment = 1,
							interval_next = 100,
							path = 2
						},
						{
							interval = 20,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_goblin_zapper",
							cant = 4,
							cant_increment = 1,
							interval_next = 50,
							path = 2
						}
					}
				},
				{
					next_wave_interval = 1100,
					name = "T4-FTrollOgre",
					spawns = {
						{
							interval = 150,
							max_same = 0,
							cant_cicle = 5,
							creep = "enemy_forest_troll",
							cant = 1,
							cant_increment = 1,
							interval_next = 250,
							path = 2
						},
						{
							interval = 15,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_goblin",
							cant = 6,
							cant_increment = 1,
							interval_next = 10,
							path = 2
						},
						{
							interval = 70,
							max_same = 0,
							cant_cicle = 4,
							creep = "enemy_ogre",
							cant = 4,
							cant_increment = 1,
							interval_next = 150,
							path = 2
						}
					}
				},
				{
					next_wave_interval = 950,
					name = "T3-OrcArmOrcrider",
					spawns = {
						{
							interval = 0,
							max_same = 0,
							cant_cicle = 0,
							creep = "enemy_orc_armored",
							cant = 1,
							cant_increment = 0,
							interval_next = 30,
							path = 0
						},
						{
							interval = 0,
							max_same = 0,
							cant_cicle = 0,
							creep = "enemy_orc_armored",
							cant = 1,
							cant_increment = 0,
							interval_next = 0,
							path = 1
						},
						{
							interval = 0,
							max_same = 0,
							cant_cicle = 0,
							creep = "enemy_orc_armored",
							cant = 1,
							cant_increment = 0,
							interval_next = 60,
							path = 2
						},
						{
							interval = 30,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_orc_armored",
							cant = 5,
							cant_increment = 1,
							interval_next = 200,
							path = 2
						},
						{
							interval = 40,
							max_same = 0,
							cant_cicle = 4,
							creep = "enemy_orc_rider",
							cant = 4,
							cant_increment = 1,
							interval_next = 60,
							path = 2
						}
					}
				},
				{
					next_wave_interval = 750,
					name = "T4-OrcZappOrcArmOgre",
					spawns = {
						{
							interval = 25,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_fat_orc",
							cant = 15,
							cant_increment = 1,
							interval_next = 10,
							path = 0
						},
						{
							interval = 70,
							max_same = 0,
							cant_cicle = 4,
							creep = "enemy_ogre",
							cant = 3,
							cant_increment = 1,
							interval_next = 200,
							path = 1
						},
						{
							interval = 30,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_orc_armored",
							cant = 5,
							cant_increment = 1,
							interval_next = 120,
							path = 2
						},
						{
							interval = 20,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_goblin_zapper",
							cant = 4,
							cant_increment = 1,
							interval_next = 60,
							path = 2
						}
					}
				},
				{
					next_wave_interval = 700,
					name = "T4-Gargoyle",
					spawns = {
						{
							interval = 20,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_gargoyle",
							cant = 8,
							cant_increment = 1,
							interval_next = 80,
							path = 0
						},
						{
							interval = 20,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_gargoyle",
							cant = 6,
							cant_increment = 1,
							interval_next = 60,
							path = 0
						},
						{
							interval = 20,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_gargoyle",
							cant = 6,
							cant_increment = 1,
							interval_next = 60,
							path = 0
						},
						{
							interval = 20,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_gargoyle",
							cant = 8,
							cant_increment = 1,
							interval_next = 60,
							path = 0
						}
					}
				},
				{
					next_wave_interval = 800,
					name = "T4-OrcArmor",
					spawns = {
						{
							interval = 30,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_orc_armored",
							cant = 4,
							cant_increment = 1,
							interval_next = 100,
							path = 0
						},
						{
							interval = 30,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_orc_armored",
							cant = 5,
							cant_increment = 1,
							interval_next = 100,
							path = 0
						},
						{
							interval = 30,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_orc_armored",
							cant = 6,
							cant_increment = 1,
							interval_next = 100,
							path = 0
						}
					}
				},
				{
					next_wave_interval = 1000,
					name = "T4-Ftroll",
					spawns = {
						{
							interval = 150,
							max_same = 0,
							cant_cicle = 5,
							creep = "enemy_forest_troll",
							cant = 1,
							cant_increment = 1,
							interval_next = 200,
							path = 0
						},
						{
							interval = 25,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_fat_orc",
							cant = 6,
							cant_increment = 1,
							interval_next = 10,
							path = 0
						},
						{
							interval = 30,
							max_same = 0,
							cant_cicle = 4,
							creep = "enemy_orc_armored",
							cant = 4,
							cant_increment = 1,
							interval_next = 100,
							path = 0
						},
						{
							interval = 30,
							max_same = 0,
							cant_cicle = 5,
							creep = "enemy_orc_armored",
							cant = 4,
							cant_increment = 1,
							interval_next = 100,
							path = 0
						}
					}
				},
				{
					next_wave_interval = 750,
					name = "T3-WorgOrcRider",
					spawns = {
						{
							interval = 20,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_wolf",
							cant = 8,
							cant_increment = 1,
							interval_next = 20,
							path = 0
						},
						{
							interval = 40,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_orc_rider",
							cant = 5,
							cant_increment = 1,
							interval_next = 200,
							path = 2
						},
						{
							interval = 20,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_wolf",
							cant = 8,
							cant_increment = 1,
							interval_next = 20,
							path = 0
						}
					}
				},
				{
					next_wave_interval = 550,
					name = "T2-WolfWorg",
					spawns = {
						{
							interval = 15,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_wolf_small",
							cant = 12,
							cant_increment = 1,
							interval_next = 35,
							path = 0
						},
						{
							interval = 25,
							max_same = 0,
							cant_cicle = 2,
							creep = "enemy_wolf",
							cant = 8,
							cant_increment = 1,
							interval_next = 50,
							path = 0
						},
						{
							interval = 25,
							max_same = 0,
							cant_cicle = 3,
							creep = "enemy_wolf",
							cant = 8,
							cant_increment = 2,
							interval_next = 50,
							path = 0
						}
					}
				}
			}
		}
	},
	enemyProgression = {
		DEFAULT = {
			armor = {
				factor = 1,
				cicle = 1
			},
			damage = {
				limit = 3,
				cicle = 1,
				factor = 1.05
			},
			gold = {
				limit = 0.3,
				cicle = 1,
				factor = 0.96
			},
			health = {
				limit = 3,
				cicle = 1,
				factor = 1.05
			},
			magicArmor = {
				factor = 1,
				cicle = 1
			},
			megaHealth = {
				activeAfterWave = 50,
				cicle = 1,
				factor = 1.05
			}
		},
		enemy_fat_orc = {
			armor = {
				factor = 1.05,
				limit_value = 0.6
			},
			damage = {
				limit = 5
			},
			health = {
				factor = 1.05,
				limit = 4
			}
		},
		enemy_forest_troll = {
			health = {
				factor = 1.02,
				limit = 2
			}
		},
		enemy_gargoyle = {
			gold = {
				factor = 0.95
			},
			health = {
				factor = 1.015
			}
		},
		enemy_goblin = {
			gold = {
				limit = 0
			},
			health = {
				factor = 1.05,
				limit = 4
			}
		},
		enemy_goblin_zapper = {
			health = {
				factor = 1.025,
				limit = 2
			},
			rangedDamage = {
				limit = 4,
				cicle = 1,
				factor = 1.05
			}
		},
		enemy_hobgoblin = {
			damage = {
				limit = 5
			},
			gold = {
				factor = 1.07,
				limit = 4
			},
			health = {
				limit = 1,
				cicle = 10,
				factor = 1,
				factor_steps = {
					1,
					2,
					4,
					6,
					10,
					15
				}
			}
		},
		enemy_ogre = {
			damage = {
				limit = 3
			},
			health = {
				factor = 1.02,
				limit = 2
			}
		},
		enemy_orc_armored = {
			armor = {
				factor = 1.01,
				limit_value = 0.9
			},
			damage = {
				factor = 1.025
			},
			health = {
				factor = 1.03,
				limit = 2.5
			}
		},
		enemy_orc_rider = {
			damage = {
				factor = 1.025
			},
			health = {
				factor = 1.03,
				limit = 2.5
			},
			magicArmor = {
				factor = 1.01,
				limit_value = 0.9
			}
		},
		enemy_shaman = {
			healPoints = {
				limit = 3,
				cicle = 1,
				factor = 1.05
			},
			health = {
				factor = 1.04
			},
			magicArmor = {
				factor = 1.005,
				limit_value = 0.95
			}
		},
		enemy_wolf = {
			damage = {
				factor = 1.025
			},
			gold = {
				factor = 0.95
			},
			health = {
				factor = 1.035
			},
			magicArmor = {
				factor = 1.025,
				limit_value = 0.8
			}
		},
		enemy_wolf_small = {
			health = {
				factor = 1.03,
				limit = 2.5
			}
		}
	},
	inapps = {
		atomicBomb = 1,
		bomb = 10,
		atomicFreeze = 5,
		freeze = 10
	},
	pathConfig = {
		{
			0,
			1
		},
		{
			2,
			3
		},
		{
			4
		}
	},
	score = {
		scorePerWave = 100,
		scoreNextWaveMultiplier = 1,
		scoreEnemyMultiplier = 0.05
	}
}
