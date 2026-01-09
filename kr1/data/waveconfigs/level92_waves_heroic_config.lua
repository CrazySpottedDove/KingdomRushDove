-- 用于生成出怪文件的初稿
local data = {
	max_waves = 6,
	-- 最大波数
	initial_cash = 2500,
	-- 初始资金
	initial_inverval = 800,
	-- 初始每大波持续时间
	final_interval = 1600,
	-- 最终每大波持续时间
	paths = { -- 允许的路径
		1,
		2,
		3,
		4,
		5,
		6,
		7,
		8,
		9,
		10,
		11
	},
	path_active_map = {
		[1] = {1, 2},
		[2] = {1, 2},
		[3] = {7, 8},
		[4] = {1, 2, 7, 8, 9, 10},
		[5] = {3, 4, 9, 10},
		[6] = {1, 2, 3, 4, 5, 6, 11}
	},
	path_weight_map = {
		[1] = 3,
		[2] = 3,
		[3] = 3,
		[4] = 3,
		[5] = 3,
		[6] = 3,
		[7] = 3,
		[8] = 3,
		[9] = 1.5,
		[10] = 1.5,
		[11] = 3
	}, -- 每一个路径分配出怪权重时的权重。每次出怪时，取活跃路径的权重相加，然后再根据各路径权重分配出怪权重
	path_enemy_map = {
		[1] = {
			"enemy_cannibal",
			"enemy_cannibal_volcano_normal",
			"enemy_hunter",
			"enemy_shaman_priest",
			"enemy_shaman_magic",
			"enemy_shaman_necro",
			"enemy_gorilla",
			"enemy_shaman_gravity",
			"enemy_shaman_rage",
			"enemy_shaman_shield",
			"enemy_cannibal_zombie"
		},
		[2] = {
			"enemy_cannibal",
			"enemy_cannibal_volcano_normal",
			"enemy_hunter",
			"enemy_shaman_priest",
			"enemy_shaman_magic",
			"enemy_shaman_necro",
			"enemy_gorilla",
			"enemy_shaman_gravity",
			"enemy_shaman_rage",
			"enemy_shaman_shield",
			"enemy_cannibal_zombie"
		},
		[3] = {
			"enemy_cannibal",
			"enemy_cannibal_volcano_normal",
			"enemy_hunter",
			"enemy_shaman_priest",
			"enemy_shaman_magic",
			"enemy_shaman_necro",
			"enemy_gorilla",
			"enemy_shaman_gravity",
			"enemy_shaman_rage",
			"enemy_shaman_shield",
			"enemy_cannibal_zombie"
		},
		[4] = {
			"enemy_cannibal",
			"enemy_cannibal_volcano_normal",
			"enemy_hunter",
			"enemy_shaman_priest",
			"enemy_shaman_magic",
			"enemy_shaman_necro",
			"enemy_gorilla",
			"enemy_shaman_gravity",
			"enemy_shaman_rage",
			"enemy_shaman_shield",
			"enemy_cannibal_zombie"
		},
		[5] = {
			"enemy_cannibal",
			"enemy_cannibal_volcano_normal",
			"enemy_hunter",
			"enemy_shaman_priest",
			"enemy_shaman_magic",
			"enemy_shaman_necro",
			"enemy_gorilla",
			"enemy_shaman_gravity",
			"enemy_shaman_rage",
			"enemy_shaman_shield",
			"enemy_cannibal_zombie"
		},
		[6] = {
			"enemy_cannibal",
			"enemy_cannibal_volcano_normal",
			"enemy_hunter",
			"enemy_shaman_priest",
			"enemy_shaman_magic",
			"enemy_shaman_necro",
			"enemy_gorilla",
			"enemy_shaman_gravity",
			"enemy_shaman_rage",
			"enemy_shaman_shield",
			"enemy_cannibal_zombie"
		},
		[7] = {
			"enemy_cannibal",
			"enemy_cannibal_volcano_normal",
			"enemy_hunter",
			"enemy_shaman_priest",
			"enemy_shaman_magic",
			"enemy_shaman_necro",
			"enemy_gorilla",
			"enemy_shaman_gravity",
			"enemy_shaman_rage",
			"enemy_shaman_shield",
			"enemy_cannibal_zombie"
		},
		[8] = {
			"enemy_cannibal",
			"enemy_cannibal_volcano_normal",
			"enemy_hunter",
			"enemy_shaman_priest",
			"enemy_shaman_magic",
			"enemy_shaman_necro",
			"enemy_gorilla",
			"enemy_shaman_gravity",
			"enemy_shaman_rage",
			"enemy_shaman_shield",
			"enemy_cannibal_zombie"
		},
		[9] = {"enemy_cannibal", "enemy_hunter"},
		[10] = {"enemy_cannibal", "enemy_hunter"},
		[11] = {"enemy_shaman_priest", "enemy_shaman_magic", "enemy_shaman_rage", "enemy_shaman_shield", "enemy_shaman_necro", "enemy_shaman_gravity"}
	},
	-- 每条路径允许出哪些敌人
	enemy_weight_map = {
		["enemy_cannibal"] = 1,
		["enemy_cannibal_volcano_normal"] = 3,
		["enemy_hunter"] = 1.5,
		["enemy_shaman_priest"] = 6,
		["enemy_shaman_magic"] = 6,
		["enemy_shaman_rage"] = 9,
		["enemy_shaman_shield"] = 8,
		["enemy_shaman_necro"] = 9,
		["enemy_cannibal_zombie"] = 1.2,
		["enemy_gorilla"] = 12,
		["enemy_shaman_gravity"] = 9
	},
	-- 敌人的权重
	enemy_comeout_wave_map = {
		["enemy_cannibal"] = 1,
		["enemy_cannibal_volcano_normal"] = 3,
		["enemy_hunter"] = 1,
		["enemy_shaman_priest"] = 2,
		["enemy_shaman_magic"] = 3,
		["enemy_shaman_rage"] = 1,
		["enemy_shaman_shield"] = 3,
		["enemy_shaman_necro"] = 5,
		["enemy_cannibal_zombie"] = 1,
		["enemy_gorilla"] = 5,
		["enemy_shaman_gravity"] = 5
	}, -- 敌人首次出现的波次
	enemy_delete_wave_map = {
		[1] = {
			[4] = {"enemy_cannibal"}
		},
		[2] = {
			[4] = {"enemy_cannibal"}
		},
		[3] = {
			[4] = {"enemy_cannibal"}
		},
		[4] = {
			[4] = {"enemy_cannibal"}
		},
		[5] = {
			[4] = {"enemy_cannibal"}
		},
		[6] = {
			[4] = {"enemy_cannibal"}
		},
		[7] = {
			[4] = {"enemy_cannibal"}
		},
		[8] = {
			[4] = {"enemy_cannibal"}
		},
		[9] = {},
		[10] = {},
		[11] = {}
	}, -- 每一条路径在哪些波次删除哪些敌人
	wave_weight_function = function(wave_number, total_gold)
		return (70 + (total_gold ^ 0.75) / 18 + 4 * wave_number ^ 2.25) * 0.4
	end,
	interval_next_factor = 0.1, -- interval_next = interval * interval_next_factor
	min_spawn_weight = 1, -- 每个 spawn 的出怪最少总权重,
	max_spawn_weight = 20, -- 每个 spawn 的出怪最大总权重,
	interval_function = function(weight, e, wave_number)
		return (25 + 160 * math.log(weight)) * 30 / e.motion.max_speed * (1 - wave_number / 15 * 0.6)
	end, -- 某权重怪物对应的 spawn 内 interval，允许上下 10% 浮动。interval_next 统一等于 interval * 0.2
	-- fixed_sub_path 始终赋 0
	-- delay 始终赋 0
	-- 如果怪物的 vis.flags 中含有 F_FLYING，就要为 wave 添加 some_flying = true
	gap_count_range = {1, 2, 3}, -- 每个 wave 中可接受 gap 数量的值，随机选取
	wave_max_types = 6 -- 每个 wave 最多不同种类敌人数量
}

return data
