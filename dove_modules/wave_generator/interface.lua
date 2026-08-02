local interface = {}

-- friend class
local E = require("entity_db")
local band = require("bit").band
require("lib.klua.table")

--- 提供默认配置
--- @return table
function interface.config_default()
	local config_template = require("dove_modules.wave_generator.config_template")
	return table.deepclone(config_template)
end

function interface.validate_config(config)
	if type(config) ~= "table" then
		return false, "Config must be a table."
	end

	if type(config.groups) ~= "table" then
		return false, "Groups must be a table."
	end

	if type(config.lives) ~= "number" or config.lives < 0 then
		return false, "Lives must be a non-negative number."
	end

	if type(config.cash) ~= "number" or config.cash < 0 then
		return false, "Gold must be a non-negative number."
	end

	for i, group in ipairs(config.groups) do
		local valid, err = interface.validate_group(group)
		if not valid then
			return false, string.format("Group %d: %s", i, err)
		end
	end

	return true
end

--- 检查 group 是否合法
---@param group table
---@return boolean
function interface.validate_group(group)
	if type(group) ~= "table" then
		return false, "Config must be a table."
	end

	if type(group.interval) ~= "number" or group.interval < 0 then
		return false, "Interval must not be a negative number."
	end

	if type(group.total_gold) ~= "number" or group.total_gold < 0 then
		return false, "Total gold must be a non-negative number."
	end

	if type(group.waves) ~= "table" then
		return false, "Waves must be a table."
	end

	for i, wave in ipairs(group.waves) do
		if type(wave.delay) ~= "number" or wave.delay < 0 then
			return false, string.format("Wave %d: Delay must be a non-negative number.", i)
		end

		if type(wave.rest) ~= "number" or wave.rest < 0 then
			return false, string.format("Wave %d: Rest must be a non-negative number.", i)
		end

		if type(wave.path_index) ~= "number" or wave.path_index < 1 then
			return false, string.format("Wave %d: Path index must be a positive number.", i)
		end

		if type(wave.enemies) ~= "table" then
			return false, string.format("Wave %d: Enemies must be a table.", i)
		end

		if wave.weight ~= nil and (type(wave.weight) ~= "number" or wave.weight <= 0) then
			return false, string.format("Wave %d: Weight must be a positive number.", i)
		end

		if wave.formation ~= nil and type(wave.formation) ~= "boolean" then
			return false, string.format("Wave %d: Formation must be a boolean.", i)
		end

		for j, enemy in ipairs(wave.enemies) do
			if type(enemy) ~= "string" or enemy == "" then
				return false, string.format("Wave %d: Enemy %d must be a non-empty string.", i, j)
			end
		end
	end

	return true
end

local function distribute_total_amount_to_groups_randomly(total, n, min_each, weights)
	min_each = tonumber(min_each) or 0
	if min_each * n > total then
		print("min_each: ", min_each, "n: ", n, "total: ", total)
		error("min_each * n 不能大于 total")
	end

	local remain = total - min_each * n

	-- 使用传入权重，若没有则用随机权重
	local ws = {}
	local sum = 0
	for i = 1, n do
		local w = (weights and weights[i]) or (math.random() + 0.5)
		ws[i] = w
		sum = sum + w
	end

	-- 按权重分配剩余（整数部分）
	local result = {}
	local allocated = 0
	for i = 1, n do
		local amount = min_each + math.floor(remain * ws[i] / sum)
		result[i] = amount
		allocated = allocated + amount
	end

	-- 计算还差多少（因为 floor 丢失的零头）
	local diff = total - allocated

	-- 把 diff 分配给权重最高的 diff 个组
	if diff > 0 then
		local idx = {}
		for i = 1, n do
			idx[i] = i
		end
		table.sort(idx, function(a, b)
			return ws[a] > ws[b]
		end)
		for i = 1, diff do
			result[idx[i]] = result[idx[i]] + 1
		end
	end

	return result
end

--- 生成阵型子波：敌人以 3/2/1 路子路径分组同时出怪
--- 每个阵型小组成员均为单只瞬时出怪（max=1, interval=0, interval_next=0），
--- 组间插入一个 max=0 的空 spawn（interval=间隙）拉开节奏，间隙之和 = 波长（帧）。
--- @param config_wave table 该子波的配置数据
--- @param enemies table 已解析的敌人名列表
--- @param counts table 每个敌人类型的数量（与 enemies 下标一一对应）
--- @param interval number 波长，单位帧
local function generate_formation_wave(config_wave, enemies, counts, interval)
	local some_flying = false

	local pool = {}
	for i, name in ipairs(enemies) do
		if counts[i] > 0 then
			pool[#pool + 1] = {
				name = name,
				count = counts[i]
			}
		end
	end

	local function total_left()
		local t = 0
		for _, p in ipairs(pool) do
			t = t + p.count
		end
		return t
	end

	local function pick_type(min_count)
		local cands = {}
		for _, p in ipairs(pool) do
			if p.count >= min_count then
				cands[#cands + 1] = p
			end
		end
		if #cands == 0 then
			return nil
		end
		return cands[math.random(#cands)]
	end

	local groups = {}
	local cur_group = {}

	local function add_member(creep, path)
		cur_group[#cur_group + 1] = {
			creep = creep,
			path = path,
			fixed_sub_path = 1,
			max = 1,
			max_same = 0,
			interval = 0,
			interval_next = 0
		}
		local tpl = E:get_template(creep)
		if tpl and tpl.vis and band(tpl.vis.flags, F_FLYING) ~= 0 then
			some_flying = true
		end
	end

	--- 尝试构建一个 size 路的阵型小组，成功则消耗池并返回 true
	local function build_one(size)
		if size == 1 then
			local p = pick_type(1)
			if not p then
				return false
			end
			p.count = p.count - 1
			add_member(p.name, 1)
			return true
		elseif size == 2 then
			local body = pick_type(2)
			if not body then
				return false
			end
			body.count = body.count - 2
			add_member(body.name, 2)
			add_member(body.name, 3)
			return true
		else
			local body = pick_type(3)
			if body then
				body.count = body.count - 3
				add_member(body.name, 1)
				add_member(body.name, 2)
				add_member(body.name, 3)
				return true
			end
			local body2 = pick_type(2)
			if not body2 then
				return false
			end
			body2.count = body2.count - 2
			local lane1 = pick_type(1)
			if not lane1 then
				body2.count = body2.count + 2
				return false
			end
			lane1.count = lane1.count - 1
			add_member(lane1.name, 1)
			add_member(body2.name, 2)
			add_member(body2.name, 3)
			return true
		end
	end

	local function roll_size(left)
		local r = math.random()
		if left >= 6 then
			if r < 0.60 then
				return 3
			elseif r < 0.85 then
				return 2
			end
			return 1
		end
		if r < 0.40 then
			return 3
		elseif r < 0.75 then
			return 2
		end
		return 1
	end

	while total_left() > 0 do
		local size = roll_size(total_left())
		while not build_one(size) and size > 1 do
			size = size - 1
		end
		if #cur_group > 0 then
			groups[#groups + 1] = cur_group
			cur_group = {}
		end
	end

	-- 组装成扁平的 spawns 列表：小组间插入空 spawn（max=0, interval=间隙）
	local spacer_creep = (groups[1] and groups[1][1] and groups[1][1].creep) or "enemy_goblin"
	local gaps = {}
	if #groups > 1 then
		interval = math.max(interval, #groups - 1)
		gaps = distribute_total_amount_to_groups_randomly(interval, #groups - 1, 1)
	end

	local spawns = {}
	for gi, group in ipairs(groups) do
		for _, s in ipairs(group) do
			spawns[#spawns + 1] = s
		end
		if gi < #groups then
			spawns[#spawns + 1] = {
				creep = spacer_creep,
				path = 1,
				fixed_sub_path = 0,
				max = 0,
				max_same = 0,
				interval = gaps[gi] or 1,
				interval_next = 0
			}
		end
	end

	return {
		delay = config_wave.delay * 30,
		path_index = config_wave.path_index,
		spawns = spawns,
		some_flying = some_flying
	}
end

--- 生成单子波
--- @param config_wave table 该子波的配置数据
local function generate_wave(config_wave)
	local some_flying = false
	-- 1. 根据金币总量，随机地生成一个数量列表，每个数量对应一个敌人类型
	local gold = config_wave.gold
	local enemies = {}
	local entities = E.entities or {}
	for _, raw_name in ipairs(config_wave.enemies or {}) do
		if type(raw_name) == "string" and raw_name ~= "" then
			local name = raw_name
			if not entities[name] then
				local prefixed = "enemy_" .. raw_name
				if entities[prefixed] then
					name = prefixed
				end
			end
			if entities[name] then
				enemies[#enemies + 1] = name
			end
		end
	end
	if #enemies == 0 then
		enemies = {"enemy_goblin"}
	end
	local enemy_count = #enemies

	if enemy_count == 0 or gold == 0 then
		return {
			delay = config_wave.delay,
			path_index = config_wave.path_index,
			spawns = {}
		}
	end

	local interval = tonumber(config_wave.interval) or 0

	local golds = distribute_total_amount_to_groups_randomly(gold, #enemies)

	local counts = {}
	for i = 1, enemy_count do
		counts[i] = 0
	end

	local not_free_enemy_count = 0
	for i = 1, enemy_count do
		local e = E:get_template(enemies[i])
		if e and e.enemy and e.enemy.gold > 0 then
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
			if e and e.enemy and e.enemy.gold > 0 then
				counts[i] = counts[i] + math.ceil(golds[i] / e.enemy.gold)
			else
				counts[i] = math.random(0, math.ceil(gold / 10))
				-- 把它的金币分配平均分给所有其它敌人
				for j = 1, enemy_count do
					local e2 = E:get_template(enemies[j])
					if e2 and e2.enemy and e2.enemy.gold > 0 then
						counts[j] = counts[j] + math.ceil(golds[i] / not_free_enemy_count / e2.enemy.gold)
					end
				end
			end
		end
	end

	-- 现在已经建立了一个数量列表 counts 了。接下来，我们需要考虑，如何把这些敌人分布在总长为 interval 的时间里。而且，尽量不要让一个 spawn 里面只出一个敌人，这样会显得很杂乱。我们可以首先把这些敌人分成一定数量的 spawn，然后每个 spawn 的耗时使用 distribute_total_amount_to_groups_randomly 来随机分配。
	if config_wave.formation then
		return generate_formation_wave(config_wave, enemies, counts, interval)
	end

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
			if spawn_count > 0 and band(E:get_template(enemies[i]).vis.flags, F_FLYING) ~= 0 then
				some_flying = true
			end
		end
	end

	local spawn_count = #spawns
	-- 防御：总时长不合法（负数，或不足以让每个 spawn 至少分到 1 帧）时，按 spawn 数钳制，避免分配报错
	if spawn_count > 0 and interval < spawn_count then
		interval = spawn_count
	end
	local intervals = distribute_total_amount_to_groups_randomly(interval, spawn_count, 1)

	for i = 1, spawn_count do
		-- 然后计算一个随机但合理的 interval 和 interval_next。interval 不可过小。
		-- spawn.max * interval + interval_next = intervals[i]

		local spawn = spawns[i]
		local interval = intervals[i]
		-- 防御：时长不足时全部敌人同帧出，保证 interval_next 非负
		local per_enemy = math.floor(interval / math.max(1, spawn.max))
		if per_enemy >= 1 then
			spawn.interval = math.random(math.max(1, math.floor(interval / spawn.max * 0.8)), per_enemy)
		else
			spawn.interval = 0
		end
		spawn.interval_next = math.max(0, interval - spawn.interval * spawn.max)
	end

	return {
		delay = config_wave.delay * 30,
		path_index = config_wave.path_index,
		spawns = table.random_order(spawns),
		some_flying = some_flying
	}
end

--- 生成单波
--- @param config_group table& 该波的配置数据(保证原本的有效数据不被修改)
--- @return table 生成的单波数据
function interface.generate_group(config_group)
	local interval = config_group.interval
	local total_gold = config_group.total_gold
	local config_waves = config_group.waves

	-- 1. 金币量随机。把 total_gold 随机分配给每个子波（按权重）
	local wave_count = #config_waves
	local weights = {}
	for i = 1, wave_count do
		weights[i] = config_waves[i].weight or 1
	end
	local golds = distribute_total_amount_to_groups_randomly(total_gold, wave_count, 0, weights)

	-- 2. 生成每个子波
	local waves = {}
	for i = 1, wave_count do
		config_waves[i].gold = golds[i]
		config_waves[i].interval = (interval - config_waves[i].delay - config_waves[i].rest) * 30
		config_waves[i].delay = config_waves[i].delay
		waves[i] = generate_wave(config_waves[i])
	end

	return {
		interval = interval * 30,
		waves = waves
	}
end

return interface
