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
	-- 刷新率，每多少次sync_data才更新一次显示
	refresh_rate = 10,
	-- 当前计数
	sync_count = 0,
	-- 累加的条目
	sum_entries = {},
	-- 累加的总耗时
	sum_total_ms = 0,
	-- 模式："window" = 窗口平均值（默认），"cumulative" = 累计全程平均值
	mode = "window",
	-- 累计模式下不重置的累计数据
	cum_entries = {},
	cum_total_ms = 0,
	cum_count = 0
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

	if perf_ui.mode == "cumulative" then
		-- 累计模式：累加到永久计数器，不重置
		deep_sum_entries(perf_ui.cum_entries, items)
		perf_ui.cum_total_ms = perf_ui.cum_total_ms + sum
		perf_ui.cum_count = perf_ui.cum_count + 1
	end

	if perf_ui.sync_count >= perf_ui.refresh_rate then
		local avg_entries = {}
		local divisor

		if perf_ui.mode == "cumulative" then
			-- 用累计数据算全程平均值
			divisor = perf_ui.cum_count
			for i, e in ipairs(perf_ui.cum_entries) do
				avg_entries[i] = {
					name = e.name,
					time = e.time / divisor,
					percentage = e.percentage / divisor
				}
			end
			perf_ui.total_ms = perf_ui.cum_total_ms / divisor
		else
			-- 窗口模式（默认）：用当前窗口数据算平均值
			divisor = perf_ui.sync_count
			for i, e in ipairs(perf_ui.sum_entries) do
				avg_entries[i] = {
					name = e.name,
					time = e.time / divisor,
					percentage = e.percentage / divisor
				}
			end
			perf_ui.total_ms = perf_ui.sum_total_ms / divisor
		end

		perf_ui.entries = avg_entries

		-- 窗口模式才重置计数，累计模式不清除累计数据
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

function perf_ui.set_mode(m)
	if m == "window" or m == "cumulative" then
		perf_ui.mode = m
		-- 切换模式时重置累计状态
		perf_ui.cum_entries = {}
		perf_ui.cum_total_ms = 0
		perf_ui.cum_count = 0
	end
end
function perf_ui.get_mode()
	return perf_ui.mode
end
function perf_ui.toggle_mode()
	if perf_ui.mode == "window" then
		perf_ui:set_mode("cumulative")
	else
		perf_ui:set_mode("window")
	end
end

local function textWidth(s)
	local f = love.graphics.getFont()
	return f and f:getWidth(s) or 0
end

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
	local mode_tag = perf_ui.mode == "cumulative" and " [AVG]" or ""
	lg.print(string.format("FPS: %d, Memory: %d MB%s", love.timer.getFPS(), collectgarbage("count") / 1024, mode_tag), x + 8, y + 6)

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

-- DEBUG
-- perf_ui.set_mode("cumulative")

return perf_ui
