-- dove_modules/perf/perf_ui.lua
local perf = require("dove_modules.perf.perf")

local perf_ui = {
	enabled = false,
	x = 8,
	y = 8,
	w = 420,
	max_rows = 24,
	row_h = 18,
	font = require("lib.klove.font_db"):f("msyh", 12),
	entries = {},
	total_ms = 0,
	fps = 0,
	-- 刷新率，每多少次sync_data才更新一次显示
	refresh_rate = 10,
	-- 当前计数
	sync_count = 0,
	-- 累加的条目
	sum_entries = {},
	-- 累加的总耗时
	sum_total_ms = 0
}

local function deep_sum_entries(sum_entries, items)
	for i, e in ipairs(items) do
		if not sum_entries[i] then
			sum_entries[i] = {
				name = e.name,
				time = 0,
				percentage = 0
			}
		end
		sum_entries[i].time = sum_entries[i].time + (e.time or 0)
		sum_entries[i].percentage = sum_entries[i].percentage + (e.percentage or 0)
	end
end

function perf_ui.sync_data()
	if not perf_ui.enabled then
		return
	end
	local items, sum = perf.export_table()
	perf_ui.sync_count = perf_ui.sync_count + 1
	deep_sum_entries(perf_ui.sum_entries, items)
	perf_ui.sum_total_ms = perf_ui.sum_total_ms + sum

	if perf_ui.sync_count >= perf_ui.refresh_rate then
		-- 计算平均值
		local avg_entries = {}
		for i, e in ipairs(perf_ui.sum_entries) do
			avg_entries[i] = {
				name = e.name,
				time = e.time / perf_ui.sync_count,
				percentage = e.percentage / perf_ui.sync_count
			}
		end
		perf_ui.entries = avg_entries
		perf_ui.total_ms = perf_ui.sum_total_ms / perf_ui.sync_count
		perf_ui.fps = 1000000 / (perf_ui.total_ms > 0 and perf_ui.total_ms or 1000)

		-- 重置计数和累加
		perf_ui.sync_count = 0
		perf_ui.sum_entries = {}
		perf_ui.sum_total_ms = 0
	end
end

function perf_ui.enable()
	perf_ui.enabled = true
end
function perf_ui.disable()
	perf_ui.enabled = false
end
function perf_ui.toggle()
	perf_ui.enabled = not perf_ui.enabled
end

local function textWidth(s)
	local f = love.graphics.getFont()
	return f and f:getWidth(s) or 0
end

-- function perf_ui.sync_data()
-- 	local items, sum = perf.export_table()
-- 	perf_ui.entries = items
-- 	perf_ui.total_ms = sum
-- 	perf_ui.fps = 1000000 / (sum > 0 and sum or 1000)
-- end

function perf_ui.draw()
	if not perf_ui.enabled then
		return
	end
	local lg = love.graphics
	lg.push("all")

	lg.setFont(perf_ui.font)

	local x, y, w = perf_ui.x, perf_ui.y, perf_ui.w
	local rows = math.min(#perf_ui.entries, perf_ui.max_rows)
	local h = 32 + rows * perf_ui.row_h + 8

	-- 背景
	lg.setColor(0, 0, 0, 0.6)
	lg.rectangle("fill", x, y, w, h, 6, 6)

	-- 标题：FPS 和 总耗时
	lg.setColor(1, 1, 1, 0.95)
	lg.print(string.format("Perf • FPS: %d • Total: %d us", perf_ui.fps, perf_ui.total_ms), x + 8, y + 6)

	local bx, by = x + 8, y + 28
	local value_x = x + w - 8

	for i = 1, rows do
		local e = perf_ui.entries[i]
		if not e then
			break
		end

		-- 名称（左对齐，必要时截断）
		lg.setColor(1, 1, 1, 0.95)
		local name = tostring(e.name)
		local max_name_w = value_x - bx - 8
		if textWidth(name) > max_name_w then
			while textWidth(name .. "...") > max_name_w and #name > 1 do
				name = name:sub(1, -2)
			end
			name = name .. "..."
		end
		lg.print(name, bx, by)

		-- 右侧数值：ms + 百分比，右对齐
		local ms = e.time or 0
		local pct = e.percentage or 0
		local right = string.format("%.2f us (%.1f%%)", ms, pct)
		local tw = textWidth(right)
		lg.print(right, value_x - tw, by)

		by = by + perf_ui.row_h
	end

	lg.pop()
end

return perf_ui
