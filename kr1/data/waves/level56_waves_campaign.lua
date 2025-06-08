﻿-- chunkname: @./kr3/data/waves/level08_waves_campaign.lua

return {
	cash = 1000,
	groups = {
		{
			interval = 9800,
			waves = {
				{
					delay = 0,
					path_index = 4,
					notification = "TOWER_ARCHER_SILVER",
					spawns = {
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 1,
							interval_next = 30,
							max = 1
						},
						{
							interval = 50,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 1,
							interval_next = 150,
							max = 3
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 1,
							interval_next = 35,
							max = 1
						},
						{
							interval = 45,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 1,
							interval_next = 130,
							max = 4
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 1,
							interval_next = 25,
							max = 1
						},
						{
							interval = 40,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 1,
							interval_next = 110,
							max = 4
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 1,
							interval_next = 25,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_hoplite",
							path = 1,
							interval_next = 170,
							max = 1
						}
					}
				}
			}
		},
		{
			interval = 1200,
			waves = {
				{
					delay = 0,
					path_index = 4,
					spawns = {
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_hoplite",
							path = 1,
							interval_next = 250,
							max = 0
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_hoplite",
							path = 1,
							interval_next = 350,
							max = 1
						},
						{
							interval = 80,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 1,
							interval_next = 400,
							max = 4
						},
						{
							interval = 70,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 1,
							interval_next = 150,
							max = 5
						}
					}
				},
				{
					delay = 0,
					path_index = 5,
					spawns = {
						{
							interval = 70,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 1,
							interval_next = 500,
							max = 7
						},
						{
							interval = 30,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 1,
							interval_next = 500,
							max = 7
						},
						{
							interval = 70,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 1,
							interval_next = 150,
							max = 4
						}
					}
				}
			}
		},
		{
			interval = 900,
			waves = {
				{
					delay = 0,
					path_index = 4,
					some_flying = true,
					spawns = {
						{
							interval = 50,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_gloomy",
							path = 1,
							interval_next = 220,
							max = 3
						},
						{
							interval = 40,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_gloomy",
							path = 1,
							interval_next = 200,
							max = 4
						},
						{
							interval = 40,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_gloomy",
							path = 1,
							interval_next = 180,
							max = 5
						},
						{
							interval = 30,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_gloomy",
							path = 1,
							interval_next = 250,
							max = 5
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
					path_index = 2,
					spawns = {
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 1,
							interval_next = 50,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 2,
							interval_next = 0,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 3,
							interval_next = 300,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 1,
							interval_next = 50,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 2,
							interval_next = 0,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 3,
							interval_next = 500,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 1,
							interval_next = 50,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 2,
							interval_next = 0,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 3,
							interval_next = 50,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 1,
							interval_next = 50,
							max = 1
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
							fixed_sub_path = 0,
							creep = "enemy_satyr_hoplite",
							path = 1,
							interval_next = 400,
							max = 0
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_hoplite",
							path = 1,
							interval_next = 350,
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
					path_index = 4,
					spawns = {
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_scourger",
							path = 1,
							interval_next = 200,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 25,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 3,
							interval_next = 25,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 25,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 3,
							interval_next = 20,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 20,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 3,
							interval_next = 400,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_scourger",
							path = 1,
							interval_next = 150,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 20,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 3,
							interval_next = 20,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 20,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 3,
							interval_next = 20,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 20,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 3,
							interval_next = 20,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_scourger",
							path = 3,
							interval_next = 400,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 25,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 3,
							interval_next = 25,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 25,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 3,
							interval_next = 200,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 25,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 3,
							interval_next = 25,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 25,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 3,
							interval_next = 100,
							max = 1
						}
					}
				}
			}
		},
		{
			interval = 650,
			waves = {
				{
					delay = 0,
					path_index = 2,
					spawns = {
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 1,
							interval_next = 850,
							max = 0
						},
						{
							interval = 25,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_twilight_elf_harasser",
							path = 1,
							interval_next = 350,
							max = 4
						},
						{
							interval = 75,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_twilight_elf_harasser",
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
							creep = "enemy_satyr_hoplite",
							path = 2,
							interval_next = 350,
							max = 1
						},
						{
							interval = 50,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 3,
							interval_next = 450,
							max = 5
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_hoplite",
							path = 1,
							interval_next = 20,
							max = 1
						}
					}
				},
				{
					delay = 0,
					path_index = 5,
					spawns = {
						{
							interval = 70,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 150,
							max = 5
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 200,
							max = 4
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 100,
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
					path_index = 3,
					spawns = {
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 1,
							interval_next = 500,
							max = 5
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 1,
							interval_next = 200,
							max = 4
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 1,
							interval_next = 200,
							max = 4
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 1,
							interval_next = 300,
							max = 4
						}
					}
				},
				{
					delay = 0,
					path_index = 4,
					some_flying = true,
					spawns = {
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_gloomy",
							path = 1,
							interval_next = 500,
							max = 0
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_gloomy",
							path = 1,
							interval_next = 20,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_gloomy",
							path = 2,
							interval_next = 0,
							max = 1
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_gloomy",
							path = 3,
							interval_next = 20,
							max = 3
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_gloomy",
							path = 3,
							interval_next = 600,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_gloomy",
							path = 1,
							interval_next = 20,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_gloomy",
							path = 2,
							interval_next = 0,
							max = 1
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_gloomy",
							path = 3,
							interval_next = 20,
							max = 4
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_gloomy",
							path = 3,
							interval_next = 250,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_gloomy",
							path = 1,
							interval_next = 20,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_gloomy",
							path = 2,
							interval_next = 0,
							max = 1
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_gloomy",
							path = 3,
							interval_next = 20,
							max = 5
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_gloomy",
							path = 3,
							interval_next = 300,
							max = 1
						}
					}
				}
			}
		},
		{
			interval = 900,
			waves = {
				{
					delay = 0,
					path_index = 5,
					spawns = {
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_hoplite",
							path = 1,
							interval_next = 210,
							max = 1
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 3,
							interval_next = 240,
							max = 3
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_hoplite",
							path = 3,
							interval_next = 290,
							max = 1
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 3,
							interval_next = 400,
							max = 4
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 3,
							interval_next = 150,
							max = 4
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 3,
							interval_next = 400,
							max = 4
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_hoplite",
							path = 1,
							interval_next = 50,
							max = 1
						},
						{
							interval = 40,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 3,
							interval_next = 400,
							max = 5
						}
					}
				},
				{
					delay = 0,
					path_index = 6,
					spawns = {
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 3,
							interval_next = 150,
							max = 0
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 3,
							interval_next = 250,
							max = 3
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 3,
							interval_next = 240,
							max = 3
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 3,
							interval_next = 230,
							max = 3
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 3,
							interval_next = 400,
							max = 4
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 3,
							interval_next = 150,
							max = 4
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 3,
							interval_next = 400,
							max = 4
						},
						{
							interval = 40,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 3,
							interval_next = 400,
							max = 9
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
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 1,
							interval_next = 400,
							max = 0
						},
						{
							interval = 30,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 1,
							interval_next = 300,
							max = 4
						},
						{
							interval = 30,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 1,
							interval_next = 400,
							max = 4
						},
						{
							interval = 30,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 1,
							interval_next = 200,
							max = 4
						},
						{
							interval = 30,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 1,
							interval_next = 240,
							max = 4
						}
					}
				},
				{
					delay = 0,
					path_index = 4,
					some_flying = true,
					spawns = {
						{
							interval = 15,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_gloomy",
							path = 1,
							interval_next = 200,
							max = 5
						},
						{
							interval = 15,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_gloomy",
							path = 1,
							interval_next = 200,
							max = 5
						},
						{
							interval = 15,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_gloomy",
							path = 1,
							interval_next = 200,
							max = 5
						},
						{
							interval = 15,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_gloomy",
							path = 1,
							interval_next = 200,
							max = 6
						},
						{
							interval = 15,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_gloomy",
							path = 1,
							interval_next = 200,
							max = 6
						},
						{
							interval = 15,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_gloomy",
							path = 1,
							interval_next = 175,
							max = 6
						},
						{
							interval = 15,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_gloomy",
							path = 1,
							interval_next = 200,
							max = 6
						}
					}
				}
			}
		},
		{
			interval = 550,
			waves = {
				{
					delay = 0,
					path_index = 1,
					spawns = {
						{
							interval = 15,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 400,
							max = 4
						},
						{
							interval = 15,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 750,
							max = 4
						},
						{
							interval = 70,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 200,
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
							creep = "enemy_twilight_scourger",
							path = 2,
							interval_next = 0,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_scourger",
							path = 3,
							interval_next = 40,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_scourger",
							path = 1,
							interval_next = 350,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_scourger",
							path = 2,
							interval_next = 0,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_scourger",
							path = 3,
							interval_next = 40,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_scourger",
							path = 1,
							interval_next = 200,
							max = 1
						},
						{
							interval = 15,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 300,
							max = 5
						},
						{
							interval = 15,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 200,
							max = 6
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_scourger",
							path = 1,
							interval_next = 40,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_scourger",
							path = 2,
							interval_next = 0,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_scourger",
							path = 3,
							interval_next = 40,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_scourger",
							path = 1,
							interval_next = 250,
							max = 1
						},
						{
							interval = 15,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 100,
							max = 6
						}
					}
				},
				{
					delay = 0,
					path_index = 6,
					spawns = {
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 1,
							interval_next = 400,
							max = 0
						},
						{
							interval = 15,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 350,
							max = 4
						},
						{
							interval = 15,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 300,
							max = 4
						},
						{
							interval = 70,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 200,
							max = 4
						}
					}
				}
			}
		},
		{
			interval = 850,
			waves = {
				{
					delay = 0,
					path_index = 3,
					spawns = {
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 200,
							max = 0
						},
						{
							interval = 100,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 220,
							max = 5
						},
						{
							interval = 50,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 180,
							max = 5
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
							creep = "enemy_bandersnatch",
							path = 1,
							interval_next = 800,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_bandersnatch",
							path = 1,
							interval_next = 1000,
							max = 1
						}
					}
				},
				{
					delay = 0,
					path_index = 5,
					spawns = {
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 200,
							max = 0
						},
						{
							interval = 100,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 220,
							max = 5
						},
						{
							interval = 50,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 180,
							max = 5
						}
					}
				}
			}
		},
		{
			interval = 1200,
			waves = {
				{
					delay = 0,
					path_index = 3,
					spawns = {
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 150,
							max = 0
						},
						{
							interval = 30,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 650,
							max = 10
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 200,
							max = 5
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 200,
							max = 5
						}
					}
				},
				{
					delay = 0,
					path_index = 4,
					spawns = {
						{
							interval = 80,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_twilight_scourger",
							path = 2,
							interval_next = 500,
							max = 5
						},
						{
							interval = 50,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_twilight_scourger",
							path = 2,
							interval_next = 180,
							max = 3
						},
						{
							interval = 30,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_twilight_scourger",
							path = 2,
							interval_next = 180,
							max = 3
						}
					}
				},
				{
					delay = 0,
					path_index = 5,
					spawns = {
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_hoplite",
							path = 2,
							interval_next = 250,
							max = 0
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_hoplite",
							path = 1,
							interval_next = 600,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_hoplite",
							path = 1,
							interval_next = 600,
							max = 1
						}
					}
				},
				{
					delay = 0,
					path_index = 6,
					spawns = {
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 280,
							max = 0
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 250,
							max = 3
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 250,
							max = 3
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 250,
							max = 3
						}
					}
				}
			}
		},
		{
			interval = 550,
			waves = {
				{
					delay = 0,
					path_index = 2,
					spawns = {
						{
							interval = 30,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_twilight_elf_harasser",
							path = 2,
							interval_next = 400,
							max = 5
						},
						{
							interval = 30,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_twilight_elf_harasser",
							path = 2,
							interval_next = 250,
							max = 5
						},
						{
							interval = 30,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_twilight_elf_harasser",
							path = 2,
							interval_next = 100,
							max = 5
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
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 100,
							max = 0
						},
						{
							interval = 30,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 300,
							max = 5
						},
						{
							interval = 30,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 200,
							max = 5
						},
						{
							interval = 30,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 150,
							max = 4
						},
						{
							interval = 30,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 100,
							max = 7
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
							creep = "enemy_bandersnatch",
							path = 2,
							interval_next = 500,
							max = 0
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_bandersnatch",
							path = 2,
							interval_next = 850,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_bandersnatch",
							path = 2,
							interval_next = 300,
							max = 1
						}
					}
				}
			}
		},
		{
			interval = 750,
			waves = {
				{
					delay = 0,
					path_index = 1,
					spawns = {
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 200,
							max = 0
						},
						{
							interval = 80,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 200,
							max = 10
						},
						{
							interval = 60,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 200,
							max = 10
						},
						{
							interval = 40,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 300,
							max = 7
						}
					}
				},
				{
					delay = 0,
					path_index = 4,
					spawns = {
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 1,
							interval_next = 20,
							max = 1
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 2,
							interval_next = 0,
							max = 1
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 3,
							interval_next = 20,
							max = 1
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 1,
							interval_next = 20,
							max = 1
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 2,
							interval_next = 0,
							max = 1
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 3,
							interval_next = 350,
							max = 1
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 1,
							interval_next = 20,
							max = 1
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 2,
							interval_next = 0,
							max = 1
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 3,
							interval_next = 20,
							max = 1
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 1,
							interval_next = 20,
							max = 1
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 2,
							interval_next = 0,
							max = 1
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 3,
							interval_next = 200,
							max = 1
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_scourger",
							path = 2,
							interval_next = 0,
							max = 1
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_scourger",
							path = 3,
							interval_next = 20,
							max = 1
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_scourger",
							path = 2,
							interval_next = 0,
							max = 1
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_scourger",
							path = 3,
							interval_next = 200,
							max = 1
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 1,
							interval_next = 20,
							max = 1
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 2,
							interval_next = 0,
							max = 1
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 3,
							interval_next = 20,
							max = 1
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 1,
							interval_next = 20,
							max = 1
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 2,
							interval_next = 0,
							max = 1
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 3,
							interval_next = 150,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 1,
							interval_next = 20,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 2,
							interval_next = 0,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 3,
							interval_next = 20,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 1,
							interval_next = 20,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 2,
							interval_next = 0,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 3,
							interval_next = 150,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 2,
							interval_next = 0,
							max = 1
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 3,
							interval_next = 20,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 2,
							interval_next = 0,
							max = 1
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 3,
							interval_next = 20,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 2,
							interval_next = 0,
							max = 1
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 3,
							interval_next = 20,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 2,
							interval_next = 0,
							max = 1
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_elf_harasser",
							path = 3,
							interval_next = 200,
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
							interval = 0,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_satyr_cutthroat",
							path = 1,
							interval_next = 1200,
							max = 0
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 250,
							max = 3
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 3,
							interval_next = 250,
							max = 3
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 3,
							interval_next = 250,
							max = 3
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 3,
							interval_next = 250,
							max = 3
						}
					}
				},
				{
					delay = 0,
					path_index = 2,
					some_flying = true,
					spawns = {
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_gloomy",
							path = 1,
							interval_next = 500,
							max = 5
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_gloomy",
							path = 1,
							interval_next = 600,
							max = 5
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_bandersnatch",
							path = 1,
							interval_next = 1100,
							max = 0
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_gloomy",
							path = 1,
							interval_next = 100,
							max = 5
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_bandersnatch",
							path = 1,
							interval_next = 700,
							max = 1
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
							creep = "enemy_satyr_hoplite",
							path = 1,
							interval_next = 600,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_hoplite",
							path = 1,
							interval_next = 700,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_hoplite",
							path = 1,
							interval_next = 700,
							max = 1
						}
					}
				},
				{
					delay = 0,
					path_index = 4,
					some_flying = true,
					spawns = {
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_gloomy",
							path = 1,
							interval_next = 100,
							max = 5
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_bandersnatch",
							path = 1,
							interval_next = 400,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_scourger",
							path = 1,
							interval_next = 50,
							max = 0
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_scourger",
							path = 2,
							interval_next = 50,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_scourger",
							path = 3,
							interval_next = 600,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_scourger",
							path = 1,
							interval_next = 50,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_scourger",
							path = 2,
							interval_next = 50,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_twilight_scourger",
							path = 3,
							interval_next = 900,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_bandersnatch",
							path = 1,
							interval_next = 200,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_bandersnatch",
							path = 2,
							interval_next = 200,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_bandersnatch",
							path = 3,
							interval_next = 150,
							max = 1
						}
					}
				},
				{
					delay = 0,
					path_index = 5,
					spawns = {
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_hoplite",
							path = 1,
							interval_next = 1200,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_hoplite",
							path = 2,
							interval_next = 300,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_hoplite",
							path = 3,
							interval_next = 200,
							max = 1
						},
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_hoplite",
							path = 3,
							interval_next = 100,
							max = 1
						}
					}
				},
				{
					delay = 0,
					path_index = 6,
					spawns = {
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 1,
							interval_next = 400,
							max = 0
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 2,
							interval_next = 300,
							max = 4
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 3,
							interval_next = 300,
							max = 4
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 3,
							interval_next = 700,
							max = 4
						},
						{
							interval = 20,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_satyr_cutthroat",
							path = 3,
							interval_next = 700,
							max = 4
						}
					}
				}
			}
		}
	}
}
