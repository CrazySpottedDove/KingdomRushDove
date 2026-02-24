-- 用于生成出怪文件的初稿
local data = {
	max_waves = 6,
	-- 最大波数
	initial_cash = 1200,
	-- 初始资金
	initial_interval = 1500,
	-- 初始每大波持续时间
	final_interval = 2500,
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
		-- w1: 快攻先锋 — 最短左路直扑，无预警急袭
		[1] = {1},
		-- w2: 双翼奇袭 — 左绕长路 + 右短路，两侧夹击
		[2] = {3, 8},
		-- w3: 铁甲推进 — 左下绕 + 右上绕，长路铁甲缓推
		[3] = {2, 7},
		-- w4: 三线骚扰 — 左短、左中、右次短，分散防线
		[4] = {1, 4, 9},
		-- w5: 精锐突袭 — 四路齐发，考验极限资源分配
		[5] = {2, 6, 7, 8},
		-- w6: 全面围攻 — 六路同发，最终决战无退路
		[6] = {1, 3, 5, 6, 8, 9}
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
		[1] = {"enemy_bouncer", "enemy_desert_raider", "enemy_immortal", "enemy_tremor"},
		[2] = {"enemy_bouncer", "enemy_desert_raider", "enemy_desert_wolf_small", "enemy_desert_wolf", "enemy_executioner", "enemy_immortal", "enemy_wasp_queen"},
		[3] = {"enemy_bouncer", "enemy_desert_raider", "enemy_desert_wolf_small", "enemy_desert_wolf", "enemy_executioner", "enemy_immortal", "enemy_munra", "enemy_wasp"},
		[4] = {"enemy_bouncer", "enemy_desert_raider", "enemy_desert_wolf_small", "enemy_desert_wolf", "enemy_executioner", "enemy_immortal"},
		[5] = {"enemy_bouncer", "enemy_desert_raider", "enemy_desert_wolf_small", "enemy_desert_wolf", "enemy_immortal", "enemy_munra", "enemy_desert_spider"},
		[6] = {"enemy_bouncer", "enemy_desert_raider", "enemy_desert_wolf_small", "enemy_desert_wolf", "enemy_executioner", "enemy_immortal", "enemy_munra", "enemy_tremor", "enemy_desert_archer", "enemy_wasp"},
		[7] = {"enemy_bouncer", "enemy_wasp", "enemy_wasp_queen", "enemy_scorpion", "enemy_executioner", "enemy_desert_spider"},
		[8] = {"enemy_fallen", "enemy_wasp_queen", "enemy_scorpion", "enemy_tremor"},
		[9] = {"enemy_fallen", "enemy_wasp_queen", "enemy_scorpion", "enemy_tremor", "enemy_munra", "enemy_desert_spider"}
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
		["enemy_munra"] = 15,
		["enemy_desert_spider"] = 10
	},
	-- 敌人的权重
	enemy_comeout_wave_map = {
		-- w1: 小卒先行
		["enemy_bouncer"] = 1,
		["enemy_desert_raider"] = 1,
		["enemy_desert_wolf_small"] = 1,
		-- w2: 中型威胁登场
		["enemy_desert_wolf"] = 2,
		["enemy_fallen"] = 2,
		["enemy_tremor"] = 2,
		-- w3: 精英初现
		["enemy_immortal"] = 3,
		["enemy_wasp"] = 3,
		["enemy_desert_archer"] = 3,
		-- w4: 特种部队
		["enemy_desert_spider"] = 4,
		["enemy_wasp_queen"] = 4,
		-- w5: 精锐重甲
		["enemy_scorpion"] = 5,
		["enemy_executioner"] = 5,
		-- w6: 终极boss
		["enemy_munra"] = 6
	}, -- 敌人首次出现的波次（压缩至6波节奏）
	enemy_delete_wave_map = {
		-- 波次缩短，小卒在中期淘汰，保持后期精锐化
		[1] = {
			[4] = {"enemy_bouncer"}
		},
		[2] = {
			[4] = {"enemy_bouncer"},
			[5] = {"enemy_desert_raider"}
		},
		[3] = {
			[4] = {"enemy_bouncer"},
			[5] = {"enemy_desert_raider"}
		},
		[4] = {
			[5] = {"enemy_bouncer", "enemy_desert_wolf_small"}
		},
		[5] = {
			[5] = {"enemy_bouncer"}
		},
		[6] = {
			[5] = {"enemy_bouncer", "enemy_desert_raider"}
		},
		[7] = {
			[4] = {"enemy_bouncer"}
		},
		[8] = {},
		[9] = {}
	},
	-- 波次权重：陡坡加速，英雄难度后劲更猛
	wave_weight_function = function(wave_number, total_gold)
		return (70 + (total_gold ^ 0.75) / 14 + wave_number ^ 3.0) * 0.65
	end,
	-- 出怪间隔：紧凑有力，前密后更密，每波节奏感强
	interval_function = function(weight, e, wave_number)
		local base = 55 + 160 * math.log(weight)
		local speed_factor = 20 / (e.motion.max_speed or 1)
		local wave_factor = 1 - math.min(wave_number / 8, 0.55)
		return base * speed_factor * wave_factor
	end,
	interval_next_factor = 0.15, -- 组间停顿更短，节奏更紧迫
	min_spawn_weight = 2, -- 每组最小权重稍高，避免零碎小怪
	max_spawn_weight = 22, -- 每组上限略高，精锐组团出现
	gap_count_range = {1, 2, 3}, -- 间隔次数减少，压迫感更强
	wave_max_types = 4 -- 每波最多4种敌人，英雄难度更多变
}

return data
