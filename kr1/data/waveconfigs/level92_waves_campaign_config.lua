-- 用于生成出怪文件的初稿
local data = {
	max_waves = 15,
	-- 最大波数
	initial_cash = 1500,
	-- 初始资金
	initial_interval = 800,
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
		[6] = {3, 4, 5, 6, 11},
		[7] = {3, 4, 7, 8, 5, 6, 9, 10},
		[8] = {1, 2, 7, 8, 9, 10},
		[9] = {1, 2, 5, 6, 11},
		[10] = {3, 4, 7, 8, 9, 10},
		[11] = {1, 2, 3, 4, 9, 10},
		[12] = {5, 6, 7, 8, 11},
		[13] = {1, 2, 3, 4, 5, 6, 9, 10},
		[14] = {3, 4, 5, 6, 7, 8, 9, 10},
		[15] = {
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
		}
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
		[1] = { -- 野蛮人
			"enemy_cannibal",
			"enemy_cannibal_volcano_normal", -- 野蛮人狂战士
			"enemy_hunter", -- 野蛮人猎手
			"enemy_shaman_priest", -- 恢复萨满
			"enemy_shaman_magic", -- 法抗萨满
			"enemy_shaman_necro", -- 拉尸体萨满
			"enemy_jungle_spider_tiny", -- 丛林小蜘蛛
			"enemy_jungle_spider_small", -- 丛林蜘蛛
			"enemy_jungle_spider_big", -- 大丛林蜘蛛
			"enemy_gorilla", -- 大猩猩
			"enemy_savage_bird_rider", -- 巨鸟骑士,
			"enemy_shaman_gravity" -- 反重力萨满
		},
		[2] = { -- 野蛮人
			"enemy_cannibal",
			"enemy_cannibal_volcano_normal", -- 野蛮人狂战士
			"enemy_hunter", -- 野蛮人猎手
			"enemy_shaman_priest", -- 恢复萨满
			"enemy_shaman_rage", -- 加伤加速萨满
			"enemy_jungle_spider_tiny", -- 丛林小蜘蛛
			"enemy_jungle_spider_small", -- 丛林蜘蛛
			"enemy_jungle_spider_big", -- 大丛林蜘蛛
			"enemy_gorilla", -- 大猩猩
			"enemy_savage_bird_rider", -- 巨鸟骑士,
			"enemy_shaman_gravity" -- 反重力萨满
		},
		[3] = {"enemy_cannibal", "enemy_cannibal_volcano_normal", "enemy_hunter", "enemy_shaman_priest", "enemy_shaman_magic", "enemy_cannibal_zombie", "enemy_alien_breeder", "enemy_alien_reaper", "enemy_savage_bird", "enemy_savage_bird_rider"},
		-- 野蛮人
		-- 野蛮人狂战士
		-- 野蛮人猎手
		-- 恢复萨满
		-- 法抗萨满
		-- 野蛮人僵尸
		-- 抱脸虫
		-- 抱脸虫生出来的
		-- 巨鸟
		-- 巨鸟骑士
		[4] = { -- 野蛮人
			"enemy_cannibal",
			"enemy_cannibal_volcano_normal", -- 野蛮人狂战士
			"enemy_hunter", -- 野蛮人猎手
			"enemy_shaman_priest", -- 恢复萨满
			"enemy_shaman_rage", -- 加伤加速萨满
			"enemy_shaman_necro", -- 拉尸体萨满
			"enemy_cannibal_zombie", -- 野蛮人僵尸
			"enemy_alien_breeder", -- 抱脸虫
			"enemy_alien_reaper", -- 抱脸虫生出来的
			"enemy_savage_bird", -- 巨鸟
			"enemy_savage_bird_rider" -- 巨鸟骑士
		},
		[5] = { -- 野蛮人
			"enemy_cannibal",
			"enemy_cannibal_volcano_normal", -- 野蛮人狂战士
			"enemy_hunter", -- 野蛮人猎手
			"enemy_shaman_priest", -- 恢复萨满
			"enemy_shaman_shield", -- 物抗萨满
			"enemy_shaman_necro", -- 拉尸体萨满
			"enemy_jungle_spider_tiny", -- 丛林小蜘蛛
			"enemy_jungle_spider_small", -- 丛林蜘蛛
			"enemy_jungle_spider_big", -- 大丛林蜘蛛
			"enemy_gorilla", -- 大猩猩
			"enemy_savage_bird_rider" -- 巨鸟骑士
		},
		[6] = {"enemy_cannibal", "enemy_cannibal_volcano_normal", "enemy_hunter", "enemy_shaman_priest", "enemy_shaman_gravity", "enemy_jungle_spider_tiny", "enemy_jungle_spider_small", "enemy_jungle_spider_big", "enemy_gorilla", "enemy_savage_bird_rider"},
		-- 野蛮人
		-- 野蛮人狂战士
		-- 野蛮人猎手
		-- 恢复萨满
		-- 反重力萨满
		-- 丛林小蜘蛛
		-- 丛林蜘蛛
		-- 大丛林蜘蛛
		-- 大猩猩
		-- 巨鸟骑士
		[7] = {"enemy_cannibal", "enemy_cannibal_volcano_normal", "enemy_hunter", "enemy_shaman_priest", "enemy_shaman_shield", "enemy_cannibal_zombie", "enemy_alien_breeder", "enemy_alien_reaper", "enemy_savage_bird", "enemy_savage_bird_rider"},
		-- 野蛮人
		-- 野蛮人狂战士
		-- 野蛮人猎手
		-- 恢复萨满
		-- 物抗萨满
		-- 野蛮人僵尸
		-- 抱脸虫
		-- 抱脸虫生出来的
		-- 巨鸟
		-- 巨鸟骑士
		[8] = { -- 野蛮人
			"enemy_cannibal",
			"enemy_cannibal_volcano_normal", -- 野蛮人狂战士
			"enemy_hunter", -- 野蛮人猎手
			"enemy_shaman_priest", -- 恢复萨满
			"enemy_shaman_gravity", -- 加伤加速萨满
			"enemy_shaman_necro", -- 拉尸体萨满
			"enemy_cannibal_zombie", -- 野蛮人僵尸
			"enemy_alien_breeder", -- 抱脸虫
			"enemy_alien_reaper", -- 抱脸虫生出来的
			"enemy_savage_bird", -- 巨鸟
			"enemy_savage_bird_rider" -- 巨鸟骑士
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
		["enemy_jungle_spider_tiny"] = 0.35,
		["enemy_jungle_spider_small"] = 1,
		["enemy_jungle_spider_big"] = 7,
		["enemy_gorilla"] = 12,
		["enemy_alien_breeder"] = 3,
		["enemy_alien_reaper"] = 3,
		["enemy_savage_bird"] = 3,
		["enemy_savage_bird_rider"] = 8,
		["enemy_shaman_gravity"] = 9
	},
	-- 敌人的权重
	enemy_comeout_wave_map = {
		["enemy_cannibal"] = 1,
		["enemy_cannibal_volcano_normal"] = 4,
		["enemy_hunter"] = 1,
		["enemy_shaman_priest"] = 3,
		["enemy_shaman_magic"] = 5,
		["enemy_shaman_rage"] = 7,
		["enemy_shaman_shield"] = 6,
		["enemy_shaman_necro"] = 8,
		["enemy_cannibal_zombie"] = 2,
		["enemy_jungle_spider_tiny"] = 2,
		["enemy_jungle_spider_small"] = 1,
		["enemy_jungle_spider_big"] = 4,
		["enemy_gorilla"] = 10,
		["enemy_alien_breeder"] = 10,
		["enemy_alien_reaper"] = 9,
		["enemy_savage_bird"] = 5,
		["enemy_savage_bird_rider"] = 10,
		["enemy_shaman_gravity"] = 9
	}, -- 敌人首次出现的波次
	enemy_delete_wave_map = {
		[1] = {
			[6] = {"enemy_jungle_spider_tiny"}
		},
		[2] = {
			[6] = {"enemy_jungle_spider_tiny"}
		},
		[3] = {
			[10] = {"enemy_savage_bird"}
		},
		[4] = {
			[10] = {"enemy_savage_bird"}
		},
		[5] = {
			[6] = {"enemy_jungle_spider_tiny"}
		},
		[6] = {
			[6] = {"enemy_jungle_spider_tiny"}
		},
		[7] = {
			[10] = {"enemy_savage_bird"}
		},
		[8] = {
			[10] = {"enemy_savage_bird"}
		},
		[9] = {},
		[10] = {},
		[11] = {}
	}, -- 每一条路径在哪些波次删除哪些敌人
	wave_weight_function = function(wave_number, total_gold)
		return (50 + (total_gold ^ 0.7) / 18 + wave_number ^ 2.25) * 0.4
	end,
	interval_next_factor = 0.1, -- interval_next = interval * interval_next_factor
	min_spawn_weight = 1, -- 每个 spawn 的出怪最少总权重,
	max_spawn_weight = 20, -- 每个 spawn 的出怪最大总权重,
	interval_function = function(weight, e, wave_number)
		return (25 + 160 * math.log(weight)) * 20 / e.motion.max_speed * (1 - wave_number / 15 * 0.6)
	end, -- 某权重怪物对应的 spawn 内 interval，允许上下 10% 浮动。interval_next 统一等于 interval * 0.2
	-- fixed_sub_path 始终赋 0
	-- delay 始终赋 0
	-- 如果怪物的 vis.flags 中含有 F_FLYING，就要为 wave 添加 some_flying = true
	gap_count_range = {0, 1, 2}, -- 每个 wave 中可接受 gap 数量的值，随机选取
	wave_max_types = 8 -- 每个 wave 最多不同种类敌人数量
}

return data
