﻿-- chunkname: @./kr1/data/waves/level07_waves_campaign.lua

return {
	lives = 20,
	cash = 700,
	groups = {
		{
			interval = 1000,
			waves = {
				{
					delay = 0,
					path_index = 1,
					notification = "TOWER_MUSKETEER",
					spawns = {
						{
							interval = 38,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_bandit",
							path = 1,
							interval_next = 60,
							max = 5
						},
						{
							interval = 38,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_bandit",
							path = 1,
							interval_next = 60,
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
							interval = 77,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_brigand",
							path = 1,
							interval_next = 60,
							max = 4
						},
						{
							interval = 77,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_bandit",
							path = 1,
							interval_next = 60,
							max = 4
						}
					}
				},
				{
					delay = 0,
					path_index = 2,
					spawns = {
						{
							interval = 51,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_bandit",
							path = 1,
							interval_next = 100,
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
							interval = 77,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_brigand",
							path = 1,
							interval_next = 60,
							max = 6
						}
					}
				},
				{
					delay = 0,
					path_index = 3,
					spawns = {
						{
							interval = 51,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_bandit",
							path = 1,
							interval_next = 100,
							max = 1
						},
						{
							interval = 51,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_bandit",
							path = 1,
							interval_next = 100,
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
					some_flying = true,
					spawns = {
						{
							interval = 26,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_gargoyle",
							path = 1,
							interval_next = 60,
							max = 4
						},
						{
							interval = 26,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_gargoyle",
							path = 1,
							interval_next = 60,
							max = 4
						},
						{
							interval = 26,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_gargoyle",
							path = 1,
							interval_next = 60,
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
							interval = 13,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_wolf_small",
							path = 1,
							interval_next = 60,
							max = 6
						},
						{
							interval = 13,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_wolf",
							path = 1,
							interval_next = 60,
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
							creep = "enemy_wolf_small",
							path = 1,
							interval_next = 200,
							max = 2
						},
						{
							interval = 13,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_wolf_small",
							path = 1,
							interval_next = 60,
							max = 3
						},
						{
							interval = 13,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_wolf",
							path = 1,
							interval_next = 60,
							max = 2
						}
					}
				},
				{
					delay = 0,
					path_index = 3,
					spawns = {
						{
							interval = 13,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_wolf_small",
							path = 1,
							interval_next = 200,
							max = 2
						},
						{
							interval = 13,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_wolf_small",
							path = 1,
							interval_next = 60,
							max = 2
						},
						{
							interval = 13,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_wolf",
							path = 1,
							interval_next = 60,
							max = 1
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
							interval = 51,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_troll",
							path = 1,
							interval_next = 200,
							max = 3
						},
						{
							interval = 51,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_troll",
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
							interval = 13,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_wolf",
							path = 1,
							interval_next = 500,
							max = 1
						},
						{
							interval = 13,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_wolf",
							path = 1,
							interval_next = 100,
							max = 2
						}
					}
				},
				{
					delay = 0,
					path_index = 3,
					spawns = {
						{
							interval = 13,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_wolf",
							path = 1,
							interval_next = 500,
							max = 1
						},
						{
							interval = 13,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_wolf",
							path = 1,
							interval_next = 100,
							max = 2
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
							interval = 38,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_troll",
							path = 1,
							interval_next = 200,
							max = 4
						},
						{
							interval = 38,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_wolf",
							path = 1,
							interval_next = 200,
							max = 3
						},
						{
							interval = 38,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_troll",
							path = 1,
							interval_next = 200,
							max = 4
						},
						{
							interval = 38,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_wolf",
							path = 1,
							interval_next = 200,
							max = 3
						}
					}
				}
			}
		},
		{
			interval = 1500,
			waves = {
				{
					delay = 0,
					path_index = 1,
					spawns = {
						{
							interval = 38,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_wolf_small",
							path = 1,
							interval_next = 60,
							max = 6
						},
						{
							interval = 38,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_wolf",
							path = 1,
							interval_next = 60,
							max = 3
						},
						{
							interval = 13,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_whitewolf",
							path = 1,
							interval_next = 60,
							max = 2
						},
						{
							interval = 13,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_whitewolf",
							path = 1,
							interval_next = 30,
							max = 2
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
					path_index = 1,
					some_flying = true,
					spawns = {
						{
							interval = 26,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_gargoyle",
							path = 1,
							interval_next = 150,
							max = 7
						},
						{
							interval = 26,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_gargoyle",
							path = 1,
							interval_next = 150,
							max = 6
						},
						{
							interval = 26,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_gargoyle",
							path = 1,
							interval_next = 150,
							max = 7
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
					path_index = 1,
					spawns = {
						{
							interval = 64,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_marauder",
							path = 1,
							interval_next = 300,
							max = 5
						},
						{
							interval = 26,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_shadow_archer",
							path = 1,
							interval_next = 150,
							max = 8
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
							interval = 51,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_dark_knight",
							path = 1,
							interval_next = 200,
							max = 2
						},
						{
							interval = 38,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_bandit",
							path = 1,
							interval_next = 100,
							max = 10
						},
						{
							interval = 51,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_shadow_archer",
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
							interval = 38,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_dark_knight",
							path = 1,
							interval_next = 200,
							max = 1
						},
						{
							interval = 38,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_bandit",
							path = 1,
							interval_next = 60,
							max = 5
						},
						{
							interval = 51,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_shadow_archer",
							path = 1,
							interval_next = 150,
							max = 3
						}
					}
				},
				{
					delay = 0,
					path_index = 3,
					spawns = {
						{
							interval = 38,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_dark_knight",
							path = 1,
							interval_next = 200,
							max = 1
						},
						{
							interval = 38,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_bandit",
							path = 1,
							interval_next = 60,
							max = 5
						},
						{
							interval = 51,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_shadow_archer",
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
							interval = 51,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_marauder",
							path = 1,
							interval_next = 100,
							max = 6
						},
						{
							interval = 38,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_dark_knight",
							path = 1,
							interval_next = 100,
							max = 6
						},
						{
							interval = 38,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_shadow_archer",
							path = 1,
							interval_next = 100,
							max = 6
						}
					}
				}
			}
		},
		{
			interval = 1500,
			waves = {
				{
					delay = 0,
					path_index = 1,
					spawns = {
						{
							interval = 38,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_whitewolf",
							path = 1,
							interval_next = 200,
							max = 3
						},
						{
							interval = 38,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_whitewolf",
							path = 1,
							interval_next = 30,
							max = 3
						}
					}
				},
				{
					delay = 0,
					path_index = 2,
					spawns = {
						{
							interval = 51,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_whitewolf",
							path = 1,
							interval_next = 150,
							max = 2
						}
					}
				},
				{
					delay = 0,
					path_index = 3,
					spawns = {
						{
							interval = 51,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_whitewolf",
							path = 1,
							interval_next = 150,
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
							interval = 38,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_troll",
							path = 1,
							interval_next = 100,
							max = 4
						},
						{
							interval = 38,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_troll",
							path = 1,
							interval_next = 100,
							max = 4
						},
						{
							interval = 38,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_troll",
							path = 1,
							interval_next = 100,
							max = 4
						},
						{
							interval = 38,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_troll",
							path = 1,
							interval_next = 100,
							max = 4
						}
					}
				},
				{
					delay = 0,
					path_index = 2,
					spawns = {
						{
							interval = 51,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_whitewolf",
							path = 1,
							interval_next = 320,
							max = 2
						},
						{
							interval = 51,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_whitewolf",
							path = 1,
							interval_next = 200,
							max = 2
						}
					}
				},
				{
					delay = 0,
					path_index = 3,
					spawns = {
						{
							interval = 51,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_whitewolf",
							path = 1,
							interval_next = 320,
							max = 2
						},
						{
							interval = 51,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_whitewolf",
							path = 1,
							interval_next = 200,
							max = 1
						}
					}
				}
			}
		},
		{
			interval = 1500,
			waves = {
				{
					delay = 0,
					path_index = 1,
					some_flying = true,
					spawns = {
						{
							interval = 13,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_gargoyle",
							path = 1,
							interval_next = 80,
							max = 10
						},
						{
							interval = 13,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_gargoyle",
							path = 1,
							interval_next = 80,
							max = 10
						},
						{
							interval = 13,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_gargoyle",
							path = 1,
							interval_next = 80,
							max = 10
						},
						{
							interval = 13,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_gargoyle",
							path = 1,
							interval_next = 80,
							max = 10
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
							interval = 26,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_troll",
							path = 1,
							interval_next = 60,
							max = 4
						},
						{
							interval = 26,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_whitewolf",
							path = 1,
							interval_next = 200,
							max = 3
						},
						{
							interval = 26,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_troll",
							path = 1,
							interval_next = 60,
							max = 4
						},
						{
							interval = 26,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_whitewolf",
							path = 1,
							interval_next = 200,
							max = 3
						},
						{
							interval = 26,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_troll",
							path = 1,
							interval_next = 60,
							max = 4
						},
						{
							interval = 26,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_whitewolf",
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
							interval = 26,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_whitewolf",
							path = 1,
							interval_next = 60,
							max = 2
						},
						{
							interval = 38,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_troll",
							path = 1,
							interval_next = 200,
							max = 2
						},
						{
							interval = 26,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_whitewolf",
							path = 1,
							interval_next = 60,
							max = 2
						},
						{
							interval = 38,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_troll",
							path = 1,
							interval_next = 30,
							max = 2
						}
					}
				},
				{
					delay = 0,
					path_index = 3,
					spawns = {
						{
							interval = 26,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_whitewolf",
							path = 1,
							interval_next = 60,
							max = 1
						},
						{
							interval = 38,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_troll",
							path = 1,
							interval_next = 200,
							max = 2
						},
						{
							interval = 26,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_whitewolf",
							path = 1,
							interval_next = 60,
							max = 1
						},
						{
							interval = 38,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_troll",
							path = 1,
							interval_next = 30,
							max = 2
						}
					}
				}
			}
		}
	}
}
