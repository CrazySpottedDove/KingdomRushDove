-- chunkname: @./kr3/data/levels/level20_spawner.lua
return {
	groups = {
		{1},
		{2},
		{3},
		[0] = {0}
	},
	points = {
		{
			path = 2
		},
		{
			path = 3
		},
		{
			path = 4
		},
		[0] = {
			path = 1
		}
	},
	waves = {{
		Boss_Path_1 = {{0, 0, 0, 0, 1, false, false, 0, 0, "enemy_twilight_avenger"}, {2, 0, 0, -1, 2, false, false, 0, 1, "enemy_blood_servant"}, {2, 0, 0, -1, 3, false, false, 1, 1, "enemy_screecher_bat"}, {5, 0, 1, 0, 1, false, false, 1, 1, "enemy_twilight_golem"}, {1, 0, 2, 1, 5, false, false, 2, 2, "enemy_twilight_elf_harasser"}, {7, 0, 2, 1, 2, false, false, 2, 2, "enemy_twilight_avenger"}, {1, 0, 2, 2, 5, false, false, 2, 2, "enemy_twilight_elf_harasser"}, {7, 0, 2, 2, 2, false, false, 2, 2, "enemy_twilight_avenger"}},
		Boss_Path_2 = {{2, 0, 1, -1, 2, false, false, 2, 3, "enemy_twilight_avenger"}, {5, 0, 1, -1, 5, false, false, 1, 1, "enemy_blood_servant"}, {4, 0, 1, -1, 5, false, false, 1, 1, "enemy_screecher_bat"}},
		Boss_Path_3 = {{5.333333333333333, 0, 1, 0, 1, false, false, 3, 3, "enemy_twilight_golem"}, {6.333333333333333, 0, 1, 1, 3, false, false, 3, 3, "enemy_twilight_scourger"}, {6.333333333333333, 0, 1, 2, 3, false, false, 3, 3, "enemy_twilight_scourger"}, {12.333333333333334, 0, 1, 0, 1, false, false, 3, 3, "enemy_twilight_golem"}, {1.3333333333333333, 0, 2, 1, 2, false, false, 3, 3, "enemy_mounted_avenger"}, {12.333333333333334, 0, 2, 0, 1, false, false, 1, 1, "enemy_twilight_heretic"}, {1.3333333333333333, 0, 2, 2, 2, false, false, 3, 3, "enemy_mounted_avenger"}},
		Boss_Path_4 = {{0, 0, 3, -1, 0, false, false, 3, 4, "enemy_screecher_bat"}, {0, 0, 0, -1, 0, false, false, 3, 4, "enemy_screecher_bat"}}
	}, {}, {}}
}
