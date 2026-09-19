-- chunkname: @./dove_modules/gui/time_rewind_view.lua
-- 时间回溯：时间轴面板（波次刻度 + 拖动选择）与重演进度画面
local G = love.graphics
local class = require("middleclass")
local km = require("lib.klua.macros")
local V = require("lib.klua.vector")
local F = require("lib.klove.font_db")
local v = V.v

-- PopUpView 的宿主；本模块可能在 game_gui 的 require 之前被加载，必须自己保证它已就绪
require("gg_views_custom")

local PAD = 60
local TRACK_H = 12
local TICK_TOP = 30
local TICK_BOTTOM = 10
local EV_ROW_H = 20
local EV_FONT = 15

local COL_PANEL = {0.09, 0.10, 0.13}
local COL_TEXT = {0.88, 0.90, 0.94}
local COL_MUTED = {0.55, 0.58, 0.65}
local COL_TRACK = {0.20, 0.22, 0.27}
local COL_KEEP = {0.30, 0.55, 0.92}
local COL_DROP = {0.42, 0.18, 0.18}
local COL_TICK = {0.48, 0.53, 0.63}
local COL_HANDLE = {1, 0.80, 0.25}
local COL_PROGRESS = {0.32, 0.75, 0.48}

local function clock(ts)
	return string.format("%d:%02d", math.floor(ts / 60), math.floor(ts % 60))
end

-- 进度画面的阶段文案，按 time_rewind.phase 的数字编号索引（1 重建 / 2 重演）
local PHASE_TEXT = {"INGAME_UI_TIME_REWIND_REBUILD", "INGAME_UI_TIME_REWIND_REPLAY"}

local TimeRewindView = class("TimeRewindView", PopUpView)

function TimeRewindView:initialize(sw, sh, gui, rewind)
	PopUpView.initialize(self, V.v(sw, sh))

	self.pos = v(0, 0)
	self.gui = gui
	self.rewind = rewind
	self.target_time = 0
	self.dragging = false
	self.panel_w = math.min(sw - 80, 960)
	self.panel_h = 178
	self.panel_x = (sw - self.panel_w) * 0.5
	-- 面板上移，把下半屏留给事件列表（矮屏再往上一点，安卓可用空间小）
	self.panel_y = sh * (sh < 620 and 0.12 or 0.18)
	self.bar_x = self.panel_x + PAD
	self.bar_w = self.panel_w - PAD * 2
	self.bar_y = self.panel_y + 108
	-- 关闭按钮：安卓端没有 Esc 也没有键盘，面板必须自带出口。
	-- 位置取面板右下角，且要避开刻度线的下缘（bar_y + TRACK_H + TICK_BOTTOM）
	self.close_w = 110
	self.close_h = 34
	self.close_x = self.panel_x + self.panel_w - PAD - self.close_w
	self.close_y = self.panel_y + self.panel_h - self.close_h - 10

	-- 事件列表（KScrollList）：面板下方，滚轮在 game_gui:wheelmoved 里被面板吃掉，不透传给地图
	local list_y = self.panel_y + self.panel_h + 64

	self.ev_list = KScrollList:new(V.v(self.panel_w - PAD * 2, math.max(0, sh - list_y - 16)))
	self.ev_list.pos = V.v(self.panel_x + PAD, list_y)
	self.ev_list.scroll_amount = EV_ROW_H
	self.ev_list.drag_scroll_threshold = 6
	self.ev_list:set_scroller_size(24, 4) -- 滚动条矩形由它算出来，不调会错位
	self.ev_list.colors.scroller_background = {45, 36, 22, 200}
	self.ev_list.colors.scroller_foreground = {110, 90, 50, 255}
	self:add_child(self.ev_list)

	-- 固定标题行 + 列头（只有 ev_list 里的数据滚动）。列宽算法与列表内部一致
	local inner_w = self.ev_list.size.x - 24 - 2 * 4 - 4
	local h_col_t = math.floor(inner_w * 0.16)
	local h_col_k = math.floor(inner_w * 0.32)

	self.ev_title = GGLabel:new(V.v(inner_w, 24))
	self.ev_title.font_name = "body"
	self.ev_title.font_size = EV_FONT + 1
	self.ev_title.text_align = "left"
	self.ev_title.vertical_align = "middle"
	self.ev_title.colors.text = {224, 230, 240, 255}
	self.ev_title.pos = V.v(self.panel_x + PAD, list_y - 62)
	self:add_child(self.ev_title)

	local h_text = {_("INGAME_UI_TIME_REWIND_EVENTS_TIME"), _("INGAME_UI_TIME_REWIND_EVENTS_KIND"), _("INGAME_UI_TIME_REWIND_EVENTS_ARGS")}
	local h_x = {0, h_col_t, h_col_t + h_col_k}
	local h_w = {h_col_t, h_col_k, inner_w - h_col_t - h_col_k}

	for i = 1, 3 do
		local h = GGLabel:new(V.v(h_w[i], EV_ROW_H - 4))

		h.font_name = "body"
		h.font_size = EV_FONT - 1
		h.text_align = "left"
		h.vertical_align = "middle"
		h.colors.text = {140, 148, 160, 255}
		h.text = h_text[i]
		h.pos = V.v(self.panel_x + PAD + h_x[i], list_y - 34)
		self:add_child(h)
	end
end

function TimeRewindView:in_close(x, y)
	return x >= self.close_x and x <= self.close_x + self.close_w and y >= self.close_y and y <= self.close_y + self.close_h
end

function TimeRewindView:set_target_from_x(x)
	-- 横轴是游戏时间：像素位置线性映射到 [0, 当前游戏时钟]
	local t = km.clamp(0, 1, (x - self.bar_x) / self.bar_w)

	self.target_time = t * self.rewind.now_time
end

-- 返回 nil 才会截断事件链，面板打开时点击不会落到下层游戏 UI
function TimeRewindView:on_down(button, x, y)
	if button ~= 1 then
		return
	end

	if self:in_close(x, y) then
		self.rewind:close(self.gui)

		return
	end

	if x > self.bar_x - 20 and x < self.bar_x + self.bar_w + 20 and y > self.bar_y - TICK_TOP and y < self.bar_y + TRACK_H + TICK_BOTTOM then
		self.dragging = true
		self:set_target_from_x(x)
	end
end

-- 鼠标移动事件没有转发到游戏，所以拖动靠轮询；抬手即开始回溯
function TimeRewindView:update(dt)
	PopUpView.update(self, dt)

	if not self.dragging then
		return
	end

	local mx, my, down = self:get_window():get_mouse_position()

	if down then
		self:set_target_from_x(self:screen_to_view(mx, my))
	else
		self.dragging = false
		self.rewind:start(self.gui.game, self.target_time)
	end
end

--- 一行参数：数字按整数显示（坐标是浮点，直接打出来没法看），表只报 {...}
local function args_text(v1, v2, v3, v4, v5)
	local vals = {v1, v2, v3, v4, v5}
	local parts = {}

	for i = 1, 5 do
		local val = vals[i]

		if val ~= nil then
			local vt = type(val)

			if vt == "table" then
				local cnt = 0

				for _ in pairs(val) do
					cnt = cnt + 1
				end

				parts[#parts + 1] = "n=" .. cnt
			elseif vt == "number" then
				parts[#parts + 1] = string.format("%.0f", val)
			else
				parts[#parts + 1] = tostring(val)
			end
		end
	end

	return table.concat(parts, ", ")
end

--- 一行 = 一个容器 + 三个子 label。注意 add_row 一次只加一行：三个 label 各自 add_row 会变成三行。
local function row_view(list_w, col_t, col_k)
	local row = KVirtualView:new(V.v(list_w, EV_ROW_H))

	local function label(x, w)
		local l = GGLabel:new(V.v(w, EV_ROW_H))

		l.font_name = "body"
		l.pos = V.v(x, 0)
		l.text_align = "left"
		l.vertical_align = "middle"
		row:add_child(l)

		return l
	end

	return row, {label(0, col_t), label(col_t, col_k), label(col_t + col_k, list_w - col_t - col_k)}
end

--- 面板打开时重建列表：面板打开期间 record 被顶成 noop，日志是冻结的，所以建一次就够
function TimeRewindView:show()
	local rewind = self.rewind
	local list = self.ev_list
	local list_w = list.size.x - list.scroller_width - 2 * list.scroller_margin - 4
	local col_t = math.floor(list_w * 0.16)
	local col_k = math.floor(list_w * 0.32)

	list:clear_rows()

	-- 标题与列头是视图的固定子节点，不进列表：滚动只影响下面的数据行
	self.ev_title.text = _("INGAME_UI_TIME_REWIND_EVENTS") .. "    " .. string.format(_("INGAME_UI_TIME_REWIND_EVENTS_COUNT"), rewind.event_count())

	for i = rewind.event_count(), 1, -1 do
		local ts, name, v1, v2, v3, v4, v5 = rewind.event_at(i)
		local row, cells = row_view(list_w, col_t, col_k)
		local key = name and ("INGAME_UI_TIME_REWIND_K_" .. name:upper())

		cells[1].text = clock(ts)
		cells[2].text = (key and _(key) ~= key) and _(key) or (name or "?")
		cells[3].text = rewind.event_label(i) or args_text(v1, v2, v3, v4, v5)

		for j = 1, 3 do
			cells[j].font_size = EV_FONT
			cells[j].colors.text = {196, 204, 216, 255}
		end

		list:add_row(row)
	end

	TimeRewindView.super.show(self)
end

function TimeRewindView:_draw_self()
	local a = self.alpha
	local rewind = self.rewind
	local now_time = rewind.now_time
	local px, py, pw = self.panel_x, self.panel_y, self.panel_w
	local bar_x, bar_y, bar_w = self.bar_x, self.bar_y, self.bar_w
	local target_x = bar_x + bar_w * (self.target_time / now_time)

	G.setColor(0, 0, 0, 0.62 * a)
	G.rectangle("fill", 0, 0, self.size.x, self.size.y)
	G.setColor(COL_PANEL[1], COL_PANEL[2], COL_PANEL[3], 0.96 * a)
	G.rectangle("fill", px, py, pw, self.panel_h)

	local big = F:f("body", 22)
	local small = F:f("body", 15)

	G.setFont(big)
	G.setColor(COL_TEXT[1], COL_TEXT[2], COL_TEXT[3], a)
	G.print(_("INGAME_UI_TIME_REWIND"), px + PAD, py + 20)

	G.setFont(small)
	G.setColor(COL_MUTED[1], COL_MUTED[2], COL_MUTED[3], a)
	G.print(_("INGAME_UI_TIME_REWIND_HINT"), px + PAD, py + 54)

	-- 读数就是游戏时钟（store.tick_ts），不是真实时间
	local now_ts = now_time
	local back_ts = self.target_time
	local current = string.format(_("INGAME_UI_TIME_REWIND_NOW"), clock(now_ts))
	local target = string.format(_("INGAME_UI_TIME_REWIND_TO"), clock(back_ts)) .. string.format(_("INGAME_UI_TIME_REWIND_DELTA"), clock(now_ts - back_ts))

	G.print(current, px + pw - PAD - small:getWidth(current), py + 22)
	G.setColor(COL_HANDLE[1], COL_HANDLE[2], COL_HANDLE[3], a)
	G.print(target, px + pw - PAD - small:getWidth(target), py + 54)

	-- 时间轴：左侧保留、右侧丢弃
	G.setColor(COL_TRACK[1], COL_TRACK[2], COL_TRACK[3], a)
	G.rectangle("fill", bar_x, bar_y, bar_w, TRACK_H)
	G.setColor(COL_DROP[1], COL_DROP[2], COL_DROP[3], a)
	G.rectangle("fill", target_x, bar_y, bar_x + bar_w - target_x, TRACK_H)
	G.setColor(COL_KEEP[1], COL_KEEP[2], COL_KEEP[3], a)
	G.rectangle("fill", bar_x, bar_y, target_x - bar_x, TRACK_H)

	-- 波次刻度：waves[i] = {游戏时钟, 波数}（数组，见 time_rewind 文件头的数据布局）
	G.setColor(COL_TICK[1], COL_TICK[2], COL_TICK[3], a)

	local waves = rewind.waves
	local show_label = bar_w / math.max(#waves, 1) > 24

	for i = 1, #waves do
		local w = waves[i]
		local x = bar_x + bar_w * (w[1] / now_time)

		G.rectangle("fill", x, bar_y - TICK_BOTTOM, 1, TRACK_H + TICK_BOTTOM + 6)

		if show_label then
			G.print(tostring(w[2]), x + 3, bar_y - TICK_TOP)
		end
	end

	-- 当前时刻游标与拖动把手
	G.setColor(COL_TEXT[1], COL_TEXT[2], COL_TEXT[3], a)
	G.rectangle("fill", bar_x + bar_w - 1, bar_y - TICK_BOTTOM, 2, TRACK_H + TICK_BOTTOM + 6)
	G.setColor(COL_HANDLE[1], COL_HANDLE[2], COL_HANDLE[3], a)
	G.rectangle("fill", target_x - 1, bar_y - TICK_TOP, 3, TRACK_H + TICK_TOP + TICK_BOTTOM)
	G.circle("fill", target_x, bar_y + TRACK_H * 0.5, 7)

	-- 关闭按钮：除了 Esc/t，鼠标与触摸都能从这里离开面板
	local close_text = _("BUTTON_CLOSE")

	G.setColor(COL_TRACK[1], COL_TRACK[2], COL_TRACK[3], a)
	G.rectangle("fill", self.close_x, self.close_y, self.close_w, self.close_h, 4, 4)
	G.setColor(COL_MUTED[1], COL_MUTED[2], COL_MUTED[3], a)
	G.rectangle("line", self.close_x, self.close_y, self.close_w, self.close_h, 4, 4)
	G.setColor(COL_TEXT[1], COL_TEXT[2], COL_TEXT[3], a)
	G.print(close_text, self.close_x + (self.close_w - small:getWidth(close_text)) * 0.5, self.close_y + (self.close_h - small:getHeight()) * 0.5)
end

--- 重演期间跳过整个世界绘制，只画这张进度画面（屏幕像素坐标）
function TimeRewindView:draw_progress()
	local game = self.gui.game
	local rewind = self.rewind
	local sw, sh = game.screen_w, game.screen_h
	local cx, cy = sw * 0.5, sh * 0.5
	local bar_w = math.min(sw - 240, 720)
	local bar_x = cx - bar_w * 0.5
	local big = F:f("body", 30)
	local small = F:f("body", 18)
	local title = _("INGAME_UI_TIME_REWIND")
	-- rewind.phase 是阶段编号（1 重建 / 2 重演），用数字索引取对应文案
	local info = string.format(_("INGAME_UI_TIME_REWIND_PROGRESS"), _(PHASE_TEXT[rewind.phase]), math.floor(rewind.progress * 100), clock(rewind.target_time))

	G.setColor(0, 0, 0, 1)
	G.rectangle("fill", 0, 0, sw, sh)

	G.setFont(big)
	G.setColor(COL_TEXT[1], COL_TEXT[2], COL_TEXT[3], 1)
	G.print(title, cx - big:getWidth(title) * 0.5, cy - 90)

	G.setFont(small)
	G.setColor(COL_MUTED[1], COL_MUTED[2], COL_MUTED[3], 1)
	G.print(info, cx - small:getWidth(info) * 0.5, cy - 34)

	G.setColor(COL_TRACK[1], COL_TRACK[2], COL_TRACK[3], 1)
	G.rectangle("fill", bar_x, cy, bar_w, 14)
	G.setColor(COL_PROGRESS[1], COL_PROGRESS[2], COL_PROGRESS[3], 1)
	G.rectangle("fill", bar_x, cy, bar_w * rewind.progress, 14)
end

return TimeRewindView
