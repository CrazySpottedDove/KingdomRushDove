-- 用于生成出怪文件的初稿
local data = {
	max_waves = 13,
	-- 最大波数
	initial_cash = 1500,
	-- 初始资金
	initial_inverval = 1000,
	-- 初始每大波持续时间
	final_interval = 2000,
	-- 最终每大波持续时间
	paths = {1, 2, 3, 4, 5, 6, 7, 8, 9},
	-- 允许的路径
	-- path1: 最短左路
	-- path2: 左路从下方绕到右路，长
	-- path3: 同 path2
	-- path4: 左路从上方绕到右路，中
	-- path5: 同 path4
	-- path6: 左路从上方绕到右路，又从下方绕到左路，长
	-- path7: 右路从上方绕到左路
	-- path8: 右路短路径
	-- path9: 右路较短路径
	path_active_map = {
		[1] = {2},
		[2] = {3},
		[3] = {2, 3},
		[4] = {7, 6},
		[5] = {1, 7},
		[6] = {1, 7, 6},
		[7] = {1, 4},
		[8] = {4, 5},
		[9] = {2, 3},
		[10] = {2, 3, 4, 5},
		[11] = {1},
		[12] = {8, 9},
		[13] = {1, 2, 8, 9}
	},
	path_weight_map = {
		[1] = 2,
		[2] = 4,
		[3] = 4,
		[4] = 3,
		[5] = 3,
		[6] = 4,
		[7] = 3,
		[8] = 2,
		[9] = 3
	}, -- 每一个路径分配出怪权重时的权重。每次出怪时，取活跃路径的权重相加，然后再根据各路径权重分配出怪权重
	path_enemy_map = {
		[1] = {"enemy_immortal", "enemy_tremor"},
		[2] = {"enemy_bouncer", "enemy_desert_raider", "enemy_desert_wolf_small", "enemy_desert_wolf", "enemy_executioner", "enemy_immortal", "enemy_munra"},
		[3] = {"enemy_bouncer", "enemy_desert_raider", "enemy_desert_wolf_small", "enemy_desert_wolf", "enemy_executioner", "enemy_immortal", "enemy_munra"},
		[4] = {"enemy_bouncer", "enemy_desert_raider", "enemy_desert_wolf_small", "enemy_desert_wolf", "enemy_executioner", "enemy_immortal", "enemy_munra"},
		[5] = {"enemy_bouncer", "enemy_desert_raider", "enemy_desert_wolf_small", "enemy_desert_wolf", "enemy_executioner", "enemy_immortal", "enemy_munra"},
		[6] = {"enemy_bouncer", "enemy_desert_raider", "enemy_desert_wolf_small", "enemy_desert_wolf", "enemy_executioner", "enemy_immortal", "enemy_munra", "enemy_tremor", "enemy_desert_archer", "enemy_wasp"},
		[7] = {"enemy_bouncer", "enemy_wasp", "enemy_wasp_queen", "enemy_scorpion", "enemy_executioner"},
		[8] = {"enemy_fallen", "enemy_wasp_queen", "enemy_scorpion", "enemy_tremor"},
		[9] = {"enemy_fallen", "enemy_wasp_queen", "enemy_scorpion", "enemy_tremor", "enemy_munra"}
	},
	-- 每条路径允许出哪些敌人
	enemy_weight_map = {
		["enemy_bouncer"] = 1,
		["enemy_desert_raider"] = 3,
		["enemy_desert_wolf_small"] = 1.5,
		["enemy_desert_wolf"] = 3,
		["enemy_immortal"] = 7,
		["enemy_fallen"] = 3,
		["enemy_desert_archer"] = 4,
		["enemy_scorpion"] = 8,
		["enemy_tremor"] = 2.5,
		["enemy_wasp"] = 2.5,
		["enemy_wasp_queen"] = 7,
		["enemy_executioner"] = 12,
		["enemy_munra"] = 15
	},
	-- 敌人的权重
	enemy_comeout_wave_map = {
		["enemy_bouncer"] = 1,
		["enemy_desert_raider"] = 1,
		["enemy_desert_wolf_small"] = 1,
		["enemy_desert_wolf"] = 2,
		["enemy_immortal"] = 3,
		["enemy_fallen"] = 2,
		["enemy_desert_archer"] = 4,
		["enemy_scorpion"] = 8,
		["enemy_tremor"] = 4,
		["enemy_wasp"] = 5,
		["enemy_wasp_queen"] = 7,
		["enemy_executioner"] = 9,
		["enemy_munra"] = 10
	}, -- 敌人首次出现的波次
	enemy_delete_wave_map = {
		[1] = {
			[7] = {"enemy_bouncer"},
			[10] = {"enemy_tremor"}
		},
		[2] = {
			[8] = {"enemy_bouncer", "enemy_desert_raider"},
			[11] = {"enemy_desert_wolf_small"}
		},
		[3] = {
			[8] = {"enemy_bouncer", "enemy_desert_raider"},
			[11] = {"enemy_desert_wolf_small"}
		},
		[4] = {
			[9] = {"enemy_bouncer"},
			[12] = {"enemy_desert_raider"}
		},
		[5] = {
			[9] = {"enemy_bouncer"},
			[12] = {"enemy_desert_raider"}
		},
		[6] = {
			[10] = {"enemy_bouncer", "enemy_desert_raider"},
			[12] = {"enemy_desert_wolf_small"}
		},
		[7] = {
			[10] = {"enemy_bouncer"},
			[12] = {"enemy_wasp"}
		},
		[8] = {
			[10] = {"enemy_fallen"},
			[12] = {"enemy_wasp"}
		},
		[9] = {
			[10] = {"enemy_fallen"},
			[12] = {"enemy_wasp"}
		}
	},
	-- 后面参数建议
	wave_weight_function = function(wave_number, total_gold)
		-- 随波次和总金币递增，后期增长更快
		return (60 + (total_gold ^ 0.7) / 15 + wave_number ^ 2.3) * 0.45
	end,
	interval_next_factor = 0.12, -- 稍微加快后续出怪节奏
	min_spawn_weight = 1.2, -- 每组最少权重略提升
	max_spawn_weight = 22, -- 每组最大权重略提升
	interval_function = function(weight, e, wave_number)
		-- 高权重怪物间隔更大，随波次递减
		return (30 + 150 * math.log(weight)) * 18 / e.motion.max_speed * (1 - wave_number / 15 * 0.55)
	end,
	gap_count_range = {0, 1, 2, 3}, -- 增加一个gap选项，提升变化
	wave_max_types = 4 -- 每波最多4种敌人
}

return data
