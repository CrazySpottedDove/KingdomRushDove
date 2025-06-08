﻿-- chunkname: @./kr1/data/waves/level06_waves_campaign.lua

return {
	lives = 20,
	cash = 700,
	groups = {
		{
			interval = 600,
			waves = {
				{
					delay = 0,
					path_index = 3,
					notification = "TOWER_PALADIN",
					spawns = {
						{
							interval = 77,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_bandit",
							path = 1,
							interval_next = 200,
							max = 7
						}
					}
				},
				{
					delay = 0,
					path_index = 4,
					spawns = {
						{
							interval = 77,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_bandit",
							path = 1,
							interval_next = 200,
							max = 7
						}
					}
				}
			}
		},
		{
			interval = 600,
			waves = {
				{
					delay = 0,
					path_index = 1,
					spawns = {
						{
							interval = 77,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_brigand",
							path = 1,
							interval_next = 300,
							max = 5
						}
					}
				},
				{
					delay = 0,
					path_index = 2,
					spawns = {
						{
							interval = 77,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_brigand",
							path = 1,
							interval_next = 300,
							max = 5
						}
					}
				}
			}
		},
		{
			interval = 800,
			waves = {
				{
					delay = 0,
					path_index = 3,
					notification_second_level = "TIP_ARMOR_HARD",
					spawns = {
						{
							interval = 77,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_dark_knight",
							path = 1,
							interval_next = 300,
							max = 1
						}
					}
				},
				{
					delay = 0,
					path_index = 4,
					spawns = {
						{
							interval = 77,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_dark_knight",
							path = 1,
							interval_next = 300,
							max = 1
						}
					}
				}
			}
		},
		{
			interval = 1000,
			waves = {
				{
					delay = 0,
					path_index = 1,
					spawns = {
						{
							interval = 13,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_goblin",
							path = 1,
							interval_next = 30,
							max = 12
						},
						{
							interval = 50,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_fat_orc",
							path = 1,
							interval_next = 60,
							max = 12
						},
						{
							interval = 60,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_shaman",
							path = 1,
							interval_next = 100,
							max = 5
						}
					}
				},
				{
					delay = 0,
					path_index = 2,
					spawns = {
						{
							interval = 13,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_goblin",
							path = 1,
							interval_next = 30,
							max = 12
						},
						{
							interval = 50,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_fat_orc",
							path = 1,
							interval_next = 60,
							max = 12
						},
						{
							interval = 60,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_shaman",
							path = 1,
							interval_next = 100,
							max = 5
						}
					}
				}
			}
		},
		{
			interval = 800,
			waves = {
				{
					delay = 0,
					path_index = 3,
					some_flying = true,
					spawns = {
						{
							interval = 120,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_gargoyle",
							path = 1,
							interval_next = 200,
							max = 5
						}
					}
				},
				{
					delay = 0,
					path_index = 4,
					some_flying = true,
					spawns = {
						{
							interval = 120,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_gargoyle",
							path = 1,
							interval_next = 200,
							max = 5
						}
					}
				}
			}
		},
		{
			interval = 800,
			waves = {
				{
					delay = 0,
					path_index = 1,
					spawns = {
						{
							interval = 50,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_brigand",
							path = 1,
							interval_next = 50,
							max = 7
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_marauder",
							path = 1,
							interval_next = 250,
							max = 1
						}
					}
				},
				{
					delay = 0,
					path_index = 2,
					spawns = {
						{
							interval = 50,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_brigand",
							path = 1,
							interval_next = 50,
							max = 7
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_marauder",
							path = 1,
							interval_next = 250,
							max = 1
						}
					}
				}
			}
		},
		{
			interval = 1600,
			waves = {
				{
					delay = 0,
					path_index = 3,
					spawns = {
						{
							interval = 35,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_bandit",
							path = 1,
							interval_next = 80,
							max = 6
						},
						{
							interval = 25,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_shadow_archer",
							path = 1,
							interval_next = 200,
							max = 3
						}
					}
				},
				{
					delay = 0,
					path_index = 4,
					spawns = {
						{
							interval = 35,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_bandit",
							path = 1,
							interval_next = 80,
							max = 6
						},
						{
							interval = 25,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_shadow_archer",
							path = 1,
							interval_next = 200,
							max = 3
						}
					}
				}
			}
		},
		{
			interval = 800,
			waves = {
				{
					delay = 0,
					path_index = 1,
					spawns = {
						{
							interval = 35,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_shadow_archer",
							path = 1,
							interval_next = 250,
							max = 3
						},
						{
							interval = 35,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_shadow_archer",
							path = 1,
							interval_next = 250,
							max = 3
						}
					}
				},
				{
					delay = 0,
					path_index = 2,
					spawns = {
						{
							interval = 35,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_shadow_archer",
							path = 1,
							interval_next = 250,
							max = 3
						},
						{
							interval = 35,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_shadow_archer",
							path = 1,
							interval_next = 250,
							max = 3
						}
					}
				},
				{
					delay = 0,
					path_index = 3,
					spawns = {
						{
							interval = 40,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_wolf",
							path = 1,
							interval_next = 450,
							max = 3
						},
						{
							interval = 40,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_wolf",
							path = 1,
							interval_next = 450,
							max = 3
						}
					}
				},
				{
					delay = 0,
					path_index = 4,
					spawns = {
						{
							interval = 40,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_wolf",
							path = 1,
							interval_next = 450,
							max = 3
						},
						{
							interval = 40,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_wolf",
							path = 1,
							interval_next = 450,
							max = 3
						}
					}
				}
			}
		},
		{
			interval = 700,
			waves = {
				{
					delay = 0,
					path_index = 3,
					some_flying = true,
					spawns = {
						{
							interval = 90,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_gargoyle",
							path = 1,
							interval_next = 200,
							max = 12
						}
					}
				},
				{
					delay = 0,
					path_index = 4,
					some_flying = true,
					spawns = {
						{
							interval = 90,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_gargoyle",
							path = 1,
							interval_next = 200,
							max = 12
						}
					}
				}
			}
		},
		{
			interval = 600,
			waves = {
				{
					delay = 0,
					path_index = 1,
					spawns = {
						{
							interval = 13,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_goblin",
							path = 1,
							interval_next = 0,
							max = 15
						},
						{
							interval = 40,
							creep_aux = "enemy_shaman",
							fixed_sub_path = 0,
							creep = "enemy_fat_orc",
							max_same = 9,
							path = 1,
							interval_next = 80,
							max = 10
						},
						{
							interval = 40,
							creep_aux = "enemy_shaman",
							fixed_sub_path = 0,
							creep = "enemy_fat_orc",
							max_same = 8,
							path = 1,
							interval_next = 50,
							max = 10
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_ogre",
							path = 1,
							interval_next = 200,
							max = 1
						},
						{
							interval = 70,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_shaman",
							path = 1,
							interval_next = 100,
							max = 3
						}
					}
				},
				{
					delay = 0,
					path_index = 2,
					spawns = {
						{
							interval = 13,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_goblin",
							path = 1,
							interval_next = 0,
							max = 15
						},
						{
							interval = 40,
							creep_aux = "enemy_shaman",
							fixed_sub_path = 0,
							creep = "enemy_fat_orc",
							max_same = 9,
							path = 1,
							interval_next = 80,
							max = 10
						},
						{
							interval = 40,
							creep_aux = "enemy_shaman",
							fixed_sub_path = 0,
							creep = "enemy_fat_orc",
							max_same = 8,
							path = 1,
							interval_next = 50,
							max = 10
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_ogre",
							path = 1,
							interval_next = 200,
							max = 1
						},
						{
							interval = 70,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_shaman",
							path = 1,
							interval_next = 100,
							max = 3
						}
					}
				}
			}
		},
		{
			interval = 1000,
			waves = {
				{
					delay = 0,
					path_index = 1,
					spawns = {
						{
							interval = 60,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_dark_knight",
							path = 1,
							interval_next = 150,
							max = 2
						},
						{
							interval = 60,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_dark_knight",
							path = 1,
							interval_next = 150,
							max = 3
						}
					}
				},
				{
					delay = 0,
					path_index = 2,
					spawns = {
						{
							interval = 60,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_dark_knight",
							path = 1,
							interval_next = 150,
							max = 2
						},
						{
							interval = 60,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_dark_knight",
							path = 1,
							interval_next = 150,
							max = 3
						}
					}
				}
			}
		},
		{
			interval = 1000,
			waves = {
				{
					delay = 0,
					path_index = 1,
					spawns = {
						{
							interval = 50,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_dark_knight",
							path = 1,
							interval_next = 150,
							max = 3
						},
						{
							interval = 50,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_dark_knight",
							path = 1,
							interval_next = 150,
							max = 4
						}
					}
				},
				{
					delay = 0,
					path_index = 2,
					spawns = {
						{
							interval = 50,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_dark_knight",
							path = 1,
							interval_next = 150,
							max = 3
						},
						{
							interval = 60,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_dark_knight",
							path = 1,
							interval_next = 150,
							max = 4
						}
					}
				},
				{
					delay = 0,
					path_index = 3,
					spawns = {
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_shadow_archer",
							path = 1,
							interval_next = 150,
							max = 0
						},
						{
							interval = 25,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_shadow_archer",
							path = 1,
							interval_next = 300,
							max = 4
						}
					}
				},
				{
					delay = 0,
					path_index = 4,
					spawns = {
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_shadow_archer",
							path = 1,
							interval_next = 150,
							max = 0
						},
						{
							interval = 25,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_shadow_archer",
							path = 1,
							interval_next = 300,
							max = 4
						}
					}
				}
			}
		},
		{
			interval = 1000,
			waves = {
				{
					delay = 0,
					path_index = 1,
					spawns = {
						{
							interval = 35,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_marauder",
							path = 1,
							interval_next = 200,
							max = 1
						},
						{
							interval = 50,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_dark_knight",
							path = 1,
							interval_next = 200,
							max = 3
						},
						{
							interval = 50,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_dark_knight",
							path = 1,
							interval_next = 200,
							max = 3
						}
					}
				},
				{
					delay = 0,
					path_index = 2,
					spawns = {
						{
							interval = 35,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_marauder",
							path = 1,
							interval_next = 200,
							max = 1
						},
						{
							interval = 50,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_dark_knight",
							path = 1,
							interval_next = 200,
							max = 3
						},
						{
							interval = 50,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_dark_knight",
							path = 1,
							interval_next = 200,
							max = 3
						}
					}
				},
				{
					delay = 0,
					path_index = 3,
					spawns = {
						{
							interval = 25,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_shadow_archer",
							path = 1,
							interval_next = 350,
							max = 3
						},
						{
							interval = 25,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_shadow_archer",
							path = 1,
							interval_next = 300,
							max = 3
						}
					}
				},
				{
					delay = 0,
					path_index = 4,
					spawns = {
						{
							interval = 25,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_shadow_archer",
							path = 1,
							interval_next = 350,
							max = 3
						},
						{
							interval = 25,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_shadow_archer",
							path = 1,
							interval_next = 300,
							max = 3
						}
					}
				}
			}
		},
		{
			interval = 2000,
			waves = {
				{
					delay = 0,
					path_index = 3,
					spawns = {
						{
							interval = 125,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_ogre",
							path = 1,
							interval_next = 250,
							max = 3
						},
						{
							interval = 15,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_goblin",
							path = 1,
							interval_next = 40,
							max = 5
						},
						{
							interval = 15,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_goblin",
							path = 1,
							interval_next = 100,
							max = 5
						},
						{
							interval = 12,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_wolf_small",
							path = 1,
							interval_next = 100,
							max = 5
						},
						{
							interval = 15,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_goblin",
							path = 1,
							interval_next = 40,
							max = 5
						},
						{
							interval = 15,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_goblin",
							path = 1,
							interval_next = 100,
							max = 5
						},
						{
							interval = 10,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_wolf_small",
							path = 1,
							interval_next = 100,
							max = 5
						}
					}
				},
				{
					delay = 0,
					path_index = 4,
					spawns = {
						{
							interval = 125,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_ogre",
							path = 1,
							interval_next = 250,
							max = 3
						},
						{
							interval = 15,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_goblin",
							path = 1,
							interval_next = 40,
							max = 5
						},
						{
							interval = 15,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_goblin",
							path = 1,
							interval_next = 100,
							max = 5
						},
						{
							interval = 12,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_wolf_small",
							path = 1,
							interval_next = 100,
							max = 5
						},
						{
							interval = 15,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_goblin",
							path = 1,
							interval_next = 40,
							max = 5
						},
						{
							interval = 15,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_goblin",
							path = 1,
							interval_next = 100,
							max = 5
						},
						{
							interval = 10,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_wolf_small",
							path = 1,
							interval_next = 100,
							max = 5
						}
					}
				}
			}
		},
		{
			interval = 800,
			waves = {
				{
					delay = 0,
					path_index = 1,
					some_flying = true,
					spawns = {
						{
							interval = 60,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_gargoyle",
							path = 1,
							interval_next = 60,
							max = 15
						}
					}
				},
				{
					delay = 0,
					path_index = 2,
					some_flying = true,
					spawns = {
						{
							interval = 60,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_gargoyle",
							path = 1,
							interval_next = 60,
							max = 15
						}
					}
				}
			}
		},
		{
			interval = 800,
			waves = {
				{
					delay = 0,
					path_index = 4,
					spawns = {
						{
							interval = 35,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_dark_knight",
							path = 1,
							interval_next = 100,
							max = 3
						},
						{
							interval = 100,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_marauder",
							path = 1,
							interval_next = 150,
							max = 3
						},
						{
							interval = 35,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_dark_knight",
							path = 1,
							interval_next = 100,
							max = 3
						},
						{
							interval = 25,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_shadow_archer",
							path = 1,
							interval_next = 350,
							max = 4
						}
					}
				},
				{
					delay = 0,
					path_index = 3,
					spawns = {
						{
							interval = 35,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_dark_knight",
							path = 1,
							interval_next = 100,
							max = 3
						},
						{
							interval = 100,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_marauder",
							path = 1,
							interval_next = 150,
							max = 3
						},
						{
							interval = 35,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_dark_knight",
							path = 1,
							interval_next = 100,
							max = 3
						},
						{
							interval = 25,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_shadow_archer",
							path = 1,
							interval_next = 350,
							max = 4
						}
					}
				}
			}
		},
		{
			interval = 2000,
			waves = {
				{
					delay = 0,
					path_index = 5,
					spawns = {
						{
							interval = 192,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "eb_juggernaut",
							path = 1,
							interval_next = 100,
							max = 1
						}
					}
				}
			}
		}
	}
}
