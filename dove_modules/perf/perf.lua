-- 用于性能监测的模块
local perf = {}

-- 当前帧（或当前一轮测量）的耗时，单位：微秒
-- items[name] = last_time_us
-- item: { sum: number, start_time: number, avg_sum: number, count: number}
perf.items = {}
perf.tmp = {}

function perf.reset()
	for _, v in pairs(perf.items) do
		v.count = v.count + 1
		v.avg_sum = (v.avg_sum * (v.count - 1) + v.sum) / v.count
		v.sum = 0
	end
end

function perf.clear()
	perf.items = {}
end

-- 开始计时
function perf.start(name)
	-- 记录开始时间（微秒）
	if not perf.items[name] then
		perf.items[name] = {
			sum = 0,
			start_time = 0,
			avg_sum = 0,
			count = 0
		}
	end
	local item = perf.items[name]
	item.start_time = love.timer.getTime() * 1000000
end

-- 结束计时并更新统计
function perf.stop(name)
	local item = perf.items[name]
	item.sum = item.sum + (love.timer.getTime() * 1000000 - item.start_time)
end

--- 导出排序后的报告表格和总耗时（基于“本次测量”的耗时）
--- @return table, number
--- sorted_items: array{ name: string, time: number, percentage: number, avg_time: number }
function perf.export_table()
	local sorted_items = {}
	local sum = 0
	local item_count = 0

	for name, item in pairs(perf.items) do
		item_count = item_count + 1

		sorted_items[item_count] = {
			name = name,
			time = item.sum, -- 当前这次的耗时（us）
			avg_time = item.avg_sum -- 历史平均耗时（us）
		}

		sum = sum + item.sum
	end

	-- 按历史平均耗时从大到小排序；如果相等，按 name 稍微稳定一下
	table.sort(sorted_items, function(a, b)
		if a.avg_time == b.avg_time then
			return a.name < b.name
		end
		return a.avg_time > b.avg_time
	end)

	-- 百分比基于“当前这次”的总和；sum 为 0 时给 0 防止 NaN

	for i = 1, item_count do
		local item = sorted_items[i]
		item.percentage = (item.time / sum) * 100
	end

	return sorted_items, sum
end

function perf.tmp_start(name)
	perf.tmp[name] = love.timer.getTime() * 1000
end

function perf.tmp_stop(name)
	local elapsed = love.timer.getTime() * 1000 - perf.tmp[name]
	print(name .. " took " .. elapsed .. " ms")
	perf.tmp[name] = nil
end

return perf
