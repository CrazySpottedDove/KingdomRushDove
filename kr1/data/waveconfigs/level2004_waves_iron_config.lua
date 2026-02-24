-- 用于生成出怪文件的初稿
local data = {
	max_waves = 1,
	-- 最大波数
	initial_cash = 2250,
	-- 初始资金
	initial_interval = 7200,
	-- 初始每大波持续时间
	final_interval = 7200,
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
		-- w1: 九路齐发 — 所有路径同时激活，无死角全面围攻，毫无喘息机会
		[1] = {1, 2, 4, 6, 8, 9}
	},
	path_weight_map = {
		[1] = 2,
		[2] = 4,
		[4] = 3,
		[6] = 4,
		[8] = 2,
		[9] = 3
	}, -- 每一个路径分配出怪权重时的权重。每次出怪时，取活跃路径的权重相加，然后再根据各路径权重分配出怪权重
	path_enemy_map = {
		[1] = {"enemy_bouncer", "enemy_desert_raider", "enemy_immortal"},
		[2] = {"enemy_desert_wolf_small", "enemy_desert_wolf", "enemy_desert_archer"},
		[4] = {"enemy_desert_raider", "enemy_immortal", "enemy_executioner"},
		[6] = {"enemy_fallen", "enemy_munra", "enemy_desert_spider"},
		[8] = {"enemy_wasp", "enemy_wasp_queen", "enemy_tremor"},
		[9] = {"enemy_fallen", "enemy_scorpion", "enemy_desert_spider", "enemy_desert_archer"}
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
		["enemy_wasp_queen"] = 10,
		["enemy_executioner"] = 15,
		["enemy_munra"] = 25,
		["enemy_desert_spider"] = 10
	},
	-- 敌人的权重
	enemy_comeout_wave_map = {
		-- 铁人模式：开局即巅峰，所有敌人第一波全部登场
		["enemy_bouncer"] = 1,
		["enemy_desert_raider"] = 1,
		["enemy_desert_wolf_small"] = 1,
		["enemy_desert_wolf"] = 1,
		["enemy_immortal"] = 1,
		["enemy_fallen"] = 1,
		["enemy_desert_archer"] = 1,
		["enemy_scorpion"] = 1,
		["enemy_tremor"] = 1,
		["enemy_wasp"] = 1,
		["enemy_wasp_queen"] = 1,
		["enemy_executioner"] = 1,
		["enemy_munra"] = 1,
		["enemy_desert_spider"] = 1
	}, -- 敌人首次出现的波次
	enemy_delete_wave_map = {}, -- 铁人模式只有一波，无敌人退场

	wave_weight_function = function(wave_number, total_gold)
		return 1000
	end,
	-- 出怪间隔极短，洪流般连绵不断
	interval_function = function(weight, e, wave_number)
		return (25 + 100 * math.log(weight)) * 21.5 / e.motion.max_speed * (1.3 - math.random())
	end,
	interval_next_factor = 1, -- 组间几乎无停顿，压迫感拉满
	min_spawn_weight = 15, -- 每组至少出中型怪，无零碎小卒
	max_spawn_weight = 30, -- 每组上限高，精锐成群涌现
	gap_count_range = {5, 7, 9}, -- 极少间隔，持续施压
	wave_max_types = 100 -- 最多5种敌人混杂，每组都是混乱考验
}

return data
