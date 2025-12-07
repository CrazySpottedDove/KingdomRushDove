-- chunkname: @./kr3/data/levels/level22_spawner.lua
return {
	groups = {
		{1},
		{2},
		{3},
		{4},
		{5},
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
		{
			path = 5
		},
		{
			path = 6
		},
		[0] = {
			path = 1
		}
	},
	waves = {{
		Boss_Path_1 = {{0, 0, 2, -1, 5, false, false, 1, 1, "enemy_shadows_spawns"}, {3, 0, 2, -1, 3, false, false, 1, 2, "enemy_grim_devourers"}, {4, 0, 2, -1, 5, false, false, 1, 1, "enemy_shadows_spawns"}, {5, 0, 2, 0, 1, false, false, 1, 2, "enemy_grim_devourers"}, {5, 0, 4, -1, 1, false, false, 1, 1, "enemy_dark_spitters"}, {6, 0, 4, -1, 2, false, false, 1, 1, "enemy_grim_devourers"}},
		Boss_Path_2 = {{0, 0, 1, -1, 3, false, false, 1, 2, "enemy_shadows_spawns"}, {3, 0, 1, -1, 3, false, false, 1, 2, "enemy_grim_devourers"}, {0, 5, 1, -1, 5, false, false, 1, 2, "enemy_shadows_spawns"}, {5, 0, 4, -1, 5, false, false, 1, 2, "enemy_shadows_spawns"}, {8, 0, 4, -1, 1, false, false, 1, 2, "enemy_shadow_champion"}},
		Boss_Path_3 = {{0.3333333333333333, 0, 1, -1, 5, false, false, 1, 2, "enemy_shadows_spawns"}, {3.3333333333333335, 0, 1, -1, 1, false, false, 1, 2, "enemy_shadow_champion"}, {0.3333333333333333, 0, 4, -1, 3, false, false, 1, 2, "enemy_shadows_spawns"}, {3.3333333333333335, 0, 4, -1, 1, false, false, 1, 4, "enemy_shadow_champion"}},
		Boss_Path_4 = {{0, 0, 1, -1, 5, false, false, 1, 2, "enemy_shadows_spawns"}, {3, 0, 1, -1, 1, false, false, 1, 4, "enemy_dark_spitters"}, {0, 0, 4, -1, 5, false, false, 1, 2, "enemy_shadows_spawns"}, {12, 0, 4, -1, 2, false, false, 1, 4, "enemy_shadow_champion"}, {12, 0, 1, -1, 2, false, false, 1, 4, "enemy_shadow_champion"}}
	}, {}, {}}
}
