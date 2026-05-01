return {
	-- 生命
	lives = 20,
	-- 初始资金
	cash = 1000,
	-- 出怪具体配置，为一个数组，每个元素配置单个 group 的出怪
	groups = {{
		interval = 30, -- 该波给玩家的总处理时间，单位秒
		total_gold = 1000, -- 该波出怪总共提供的金币量
		-- 波次配置，为一个数组，每个元素配置单个 wave 的出怪。一个 wave 管理一条路线的出怪。
		-- 每个 wave 的出怪都是一个独立的协程，它们在等待 delay 时间后，会连续地执行自己的 spawn。

		waves = {{
			delay = 0, -- 出怪前的等待时间，单位为秒
			-- 在本 wave 结束时，相比 group 的 interval，剩余了多少时间。
			rest = 5,
			path_index = 1, -- 出怪路径序号
			-- 这里，我们不再具体让玩家定义 spawn 的内容了，而是采用一种类似于随机生成的方式，减少玩家手动编写的压力。
			-- 所有本 wave 可能出现的怪物
			enemies = {"enemy_goblin"}
		}}
	}}
}
