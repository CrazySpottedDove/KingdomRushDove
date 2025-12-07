-- 用于生成出怪文件的初稿
local data = {
	max_waves = 1,
	-- 最大波数
	initial_cash = 1200,
	-- 初始资金
	initial_inverval = 7200,
	-- 初始每大波持续时间
	final_interval = 7200,
	-- 最终每大波持续时间
	paths = {1, 2},
	-- 允许的路径
	path_active_map = {
		[1] = 1,
		[2] = 1
	}, -- 在这些波次，path 才被激活
	path_weight_map = {
		[1] = 3,
		[2] = 2
	}, -- 每一个路径分配出怪权重时的权重。每次出怪时，取活跃路径的权重相加，然后再根据各路径权重分配出怪权重
	path_enemy_map = {
		[1] = {"enemy_skeleton", "enemy_skeleton_big", "enemy_necromancer", "enemy_phantom_death_rider", "enemy_wererat"},
		[2] = {"enemy_gargoyle", "enemy_abomination", "enemy_zombiemancer", "enemy_halloween_zombie", "enemy_zombie", "enemy_werewolf"}
	},
	-- 每条路径允许出哪些敌人
	enemy_weight_map = {
		["enemy_halloween_zombie"] = 1.4,
		["enemy_skeleton"] = 1,
		["enemy_skeleton_big"] = 2,
		["enemy_necromancer"] = 12,
		["enemy_gargoyle"] = 2,
		["enemy_wererat"] = 6,
		["enemy_werewolf"] = 7,
		["enemy_zombiemancer"] = 20,
		["enemy_zombie"] = 1.5,
		["enemy_phantom_death_rider"] = 10,
		["enemy_abomination"] = 10
	},
	-- 敌人的权重
	enemy_comeout_wave_map = {
		["enemy_halloween_zombie"] = 1,
		["enemy_skeleton"] = 1,
		["enemy_skeleton_big"] = 1,
		["enemy_necromancer"] = 1,
		["enemy_gargoyle"] = 1,
		["enemy_wererat"] = 1,
		["enemy_werewolf"] = 1,
		["enemy_phantom_death_rider"] = 1,
		["enemy_abomination"] = 1,
		["enemy_zombiemancer"] = 1,
		["enemy_zombie"] = 1
	}, -- 敌人首次出现的波次
	enemy_delete_wave_map = {
		[1] = {},
		[2] = {}
	}, -- 每一条路径在哪些波次删除哪些敌人
	wave_weight_function = function(wave_number, total_gold)
		return 1500
	end,
	min_spawn_weight = 14, -- 每个 spawn 的出怪最少总权重,
	max_spawn_weight = 40, -- 每个 spawn 的出怪最大总权重,
	interval_function = function(weight, e, wave_number)
		return (25 + 100 * math.log(weight)) * 20 / e.motion.max_speed * (1.4 - math.random())
	end, -- 某权重怪物对应的 spawn 内 interval，允许上下 10% 浮动。interval_next 统一等于 interval * 0.2
	-- fixed_sub_path 始终赋 0
	-- delay 始终赋 0
	-- 如果怪物的 vis.flags 中含有 F_FLYING，就要为 wave 添加 some_flying = true
	wave_max_types = 10 -- 每个 wave 最多不同种类敌人数量
}
return data
