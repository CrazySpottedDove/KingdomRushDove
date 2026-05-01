local interface = {}

-- friend class
local E = require("entity_db")
require("lib.klua.table")

--- 提供默认配置
--- @return table
function interface.config_default()
	local config_template = require("dove_modules.wave_generator.config_template")
	return table.deepclone(config_template)
end

local function distribute_total_amount_to_groups_randomly(total, n, min_each)
	local result = {}

	for i = 1, n do
		local remaining_groups = n - i

		-- 后面至少需要这么多
		local min_required = remaining_groups * min_each

		-- 当前最多能拿多少（不能影响后面）
		local max = total - min_required

		-- 当前最少
		local min = min_each

		-- 做一个更自然的随机（靠近平均值）
		local avg = total / (remaining_groups + 1)

		-- 限制随机范围（避免极端）
		local low = math.max(min, avg * 0.5)
		local high = math.min(max, avg * 1.5)

		local amount
		if low > high then
			amount = min
		else
			amount = math.random(math.floor(low), math.floor(high))
		end

		result[i] = amount
		total = total - amount
	end

	return result
end

--- 生成单子波
--- @param config_sub_wave table 该子波的配置数据
local function generate_wave(config_wave)
	-- 1. 根据金币总量，随机地生成一个数量列表，每个数量对应一个敌人类型
	local gold = config_wave.gold
	local enemies = config_wave.enemies
	local enemy_count = #enemies

	if enemy_count == 0 or gold == 0 then
		return {
			delay = config_wave.delay,
			path_index = config_wave.path_index,
			spawns = {}
		}
	end

	local interval = config_wave.interval

	local golds = distribute_total_amount_to_groups_randomly(gold, #enemies)

	local counts = {}
	for i = 1, enemy_count do
		counts[i] = 0
	end

	local not_free_enemy_count = 0
	for i = 1, enemy_count do
		local e = E:get_template(enemies[i])
		if e.enemy.gold > 0 then
			not_free_enemy_count = not_free_enemy_count + 1
		end
	end

	if not_free_enemy_count == 0 then
		-- 如果没有一个敌人是有金币的，那么就随机生成数量
		for i = 1, enemy_count do
			counts[i] = math.random(0, math.ceil(gold / 10 / enemy_count))
		end
	else
		for i = 1, enemy_count do
			local e = E:get_template(enemies[i])
			if e.enemy.gold > 0 then
				counts[i] = counts[i] + math.ceil(golds[i] / e.enemy.gold)
			else
				counts[i] = math.random(0, math.ceil(gold / 10))
				-- 把它的金币分配平均分给所有其它敌人
				for j = 1, enemy_count do
					local e2 = E:get_template(enemies[j])
					if e2.enemy.gold > 0 then
						counts[j] = counts[j] + math.ceil(golds[i] / not_free_enemy_count / e2.enemy.gold)
					end
				end
			end
		end
	end

	-- 现在已经建立了一个数量列表 counts 了。接下来，我们需要考虑，如何把这些敌人分布在总长为 interval 的时间里。而且，尽量不要让一个 spawn 里面只出一个敌人，这样会显得很杂乱。我们可以首先把这些敌人分成一定数量的 spawn，然后每个 spawn 的耗时使用 distribute_total_amount_to_groups_randomly 来随机分配。
	local spawns = {}

	for i = 1, enemy_count do
		local count = counts[i]

		while count > 0 do
			local spawn_count = math.min(count, math.random(1, 8))
			count = count - spawn_count
			spawns[#spawns + 1] = {
				creep = enemies[i],
				max = spawn_count,
				max_same = 0,
				path = 1,
				fixed_sub_path = 0,
				-- 两个 interval 有待进一步赋值。
				interval = 0,
				interval_next = 0
			}
		end
	end

	local spawn_count = #spawns
	local intervals = distribute_total_amount_to_groups_randomly(interval, spawn_count, 30)

	for i = 1, spawn_count do
		-- 然后计算一个随机但合理的 interval 和 interval_next。interval 不可过小。
		-- spawn.max * interval + interval_next = intervals[i]

		local spawn = spawns[i]
		local interval = intervals[i]
		spawn.interval = math.floor(math.random(interval / spawn.max * 0.8, interval / spawn.max))
		spawn.interval_next = interval - spawn.interval * spawn.max
	end

	table.random_order(spawns)

	return {
		delay = config_wave.delay,
		path_index = config_wave.path_index,
		spawns = spawns
	}
end

--- 生成单波
--- @param config_group table 该波的配置数据
--- @return table 生成的单波数据
function interface.generate_group(config_group)
	local interval = config_group.interval
	local total_gold = config_group.total_gold
	local config_waves = config_group.waves

	-- 1. 金币量随机。把 total_gold 随机分配给每个子波
	local wave_count = #config_waves
	local golds = distribute_total_amount_to_groups_randomly(total_gold, wave_count)

	-- 2. 生成每个子波
	local waves = {}
	for i = 1, wave_count do
		config_waves[i].gold = golds[i]
		config_waves[i].interval = (interval - config_waves[i].delay - config_waves[i].rest) * 30
		config_waves[i].delay = config_waves[i].delay * 30
		config_waves[i].rest = nil -- 生成完后就不需要 rest 了
		waves[i] = generate_wave(config_waves[i])
	end

	return {
		interval = interval * 30,
		waves = waves
	}
end

return interface
