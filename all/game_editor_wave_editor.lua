-- chunkname: @./all/game_editor_wave_editor.lua
-- 地图编辑器 - 出怪编辑面板
local log = require("lib.klua.log"):new("wave_editor")
local km = require("lib.klua.macros")
require("lib.klua.table")
require("klove.kui")
require("gg_views_custom")
local V = require("lib.klua.vector")
local v = V.v
local F = require("lib.klove.font_db")
local serpent = require("serpent")
local E = require("entity_db")

local WaveEditorView = class("WaveEditorView", PopUpView)

-- 颜色主题（深色策略游戏风格）
local C = {
	bg = {16, 20, 32, 255},
	panel = {26, 33, 50, 255},
	selection = {58, 130, 220, 255},
	text = {205, 218, 248, 255},
	accent = {195, 148, 38, 255},
	input_bg = {22, 28, 42, 255},
	button_bg = {36, 46, 68, 255}
}

function WaveEditorView:initialize(sw, sh, editor)
	PopUpView.initialize(self, V.v(sw, sh))
	self.colors.background = {0, 0, 0, 160}
	self.editor = editor

	-- 获取当前关卡编号和游戏模式
	self.level_idx = editor.store.level_idx or 1
	self.level_mode = editor.store.level_mode or GAME_MODE_CAMPAIGN
	self.wave_data = self:_load_wave_data()

	-- 主面板（半透明背景）
	local pw, ph = 1000, 700
	local panel = KView:new(V.v(pw, ph))
	panel.colors.background = C.bg
	panel.anchor = v(pw / 2, ph / 2)
	panel.pos = v(sw / 2, sh / 2)
	self:add_child(panel)
	self.panel = panel

	-- 标题栏
	local title = KLabel:new(V.v(pw, 40))
	title.text = "出怪编辑器 - Level " .. string.format("%02d", self.level_idx)
	title.text_align = "center"
	title.vertical_align = "middle"
	title.colors.text = {238, 244, 255, 255}
	title.colors.background = C.panel
	title.font_size = 18
	title.font_name = KE_CONST.font_name
	title.pos = v(0, 0)
	panel:add_child(title)

	-- 关闭按钮
	local close_btn = KButton:new(V.v(30, 30))
	close_btn.text = "X"
	close_btn.pos = v(pw - 35, 5)
	close_btn.colors.background = {120, 50, 50, 255}
	close_btn.colors.text = {255, 255, 255, 255}
	function close_btn.on_click()
		self:hide()
	end

	panel:add_child(close_btn)

	-- 参数编辑区（y=45 开始）
	local param_y = 45
	-- 生命值 + 初始金币（一行）
	local pw2 = pw - 40

	-- 生命值
	local lives_label = KLabel:new(V.v(80, 24))
	lives_label.pos = v(20, param_y)
	lives_label.text = "生命值:"
	lives_label.text_align = "right"
	lives_label.colors.text = C.text
	lives_label.font_size = 13
	lives_label.font_name = KE_CONST.font_name
	lives_label.vertical_align = "middle"
	panel:add_child(lives_label)

	self._lives_input = self:_create_number_input(panel, 110, param_y, 80, 24, self.wave_data.lives or 20)
	self._lives_input.on_change = function(val)
		self.wave_data.lives = val
	end

	-- 初始金币
	local cash_label = KLabel:new(V.v(80, 24))
	cash_label.pos = v(220, param_y)
	cash_label.text = "初始金币:"
	cash_label.text_align = "right"
	cash_label.colors.text = C.text
	cash_label.font_size = 13
	cash_label.font_name = KE_CONST.font_name
	cash_label.vertical_align = "middle"
	panel:add_child(cash_label)

	self._cash_input = self:_create_number_input(panel, 310, param_y, 100, 24, self.wave_data.cash or 800)
	self._cash_input.on_change = function(val)
		self.wave_data.cash = val
	end

	-- 总波数
	local waves_label = KLabel:new(V.v(80, 24))
	waves_label.pos = v(460, param_y)
	waves_label.text = "总波数:"
	waves_label.text_align = "right"
	waves_label.colors.text = C.text
	waves_label.font_size = 13
	waves_label.font_name = KE_CONST.font_name
	waves_label.vertical_align = "middle"
	panel:add_child(waves_label)

	-- 显示当前波数
	self._waves_count_label = KLabel:new(V.v(40, 24))
	self._waves_count_label.pos = v(550, param_y)
	self._waves_count_label.text = tostring(#self.wave_data.groups or 0)
	self._waves_count_label.text_align = "left"
	self._waves_count_label.colors.text = C.accent
	self._waves_count_label.font_size = 14
	self._waves_count_label.font_name = KE_CONST.font_name
	self._waves_count_label.vertical_align = "middle"
	panel:add_child(self._waves_count_label)

	-- 总金币统计
	self:_update_gold_stats()

	-- 波次列表区域（可滚动）
	local list_y = param_y + 35
	local list_h = ph - list_y - 80

	-- header
	local header_h = 24
	local cols = {{
		label = "#",
		x = 10,
		w = 30
	}, {
		label = "间隔(ms)",
		x = 45,
		w = 80
	}, {
		label = "路径",
		x = 130,
		w = 40
	}, {
		label = "延迟",
		x = 175,
		w = 50
	}, {
		label = "敌人类型",
		x = 230,
		w = 180
	}, {
		label = "数量",
		x = 415,
		w = 50
	}, {
		label = "出怪间隔",
		x = 470,
		w = 70
	}}

	local header = KView:new(V.v(pw - 40, header_h))
	header.pos = v(20, list_y)
	header.colors.background = C.panel
	for _, col in ipairs(cols) do
		local hl = KLabel:new(V.v(col.w, header_h))
		hl.pos = v(col.x, 0)
		hl.text = col.label
		hl.text_align = "left"
		hl.colors.text = C.accent
		hl.font_size = 11
		hl.font_name = KE_CONST.font_name
		hl.vertical_align = "middle"
		header:add_child(hl)
	end
	panel:add_child(header)

	-- 可滚动的内容区域
	self._list_scroll = 0
	self._list_view = KView:new(V.v(pw - 40, list_h))
	self._list_view.pos = v(20, list_y + header_h)
	self._list_view.colors.background = C.input_bg
	self._list_view.clip = true
	panel:add_child(self._list_view)
	self._list_content = KView:new(V.v(pw - 40, 0))
	self._list_content.pos = v(0, 0)
	self._list_view:add_child(self._list_content)

	self:_rebuild_wave_list()

	-- 底部操作按钮
	local btn_y = ph - 40
	local add_btn = KEButton:new("+ 添加波次")
	add_btn.size = v(120, 28)
	add_btn.pos = v(20, btn_y)
	add_btn.text_offset = V.v(0, (28 - KE_CONST.font_size) / 2)
	function add_btn.on_click()
		self:_add_wave()
	end

	panel:add_child(add_btn)

	local save_btn = KEButton:new("保存出怪文件")
	save_btn.size = v(140, 28)
	save_btn.pos = v(pw - 310, btn_y)
	save_btn.text_offset = V.v(0, (28 - KE_CONST.font_size) / 2)
	save_btn.colors.background = {0, 100, 0, 200}
	function save_btn.on_click()
		self:_save_wave_data()
	end

	panel:add_child(save_btn)

	local close_btn2 = KEButton:new("关闭")
	close_btn2.size = v(100, 28)
	close_btn2.pos = v(pw - 140, btn_y)
	close_btn2.text_offset = V.v(0, (28 - KE_CONST.font_size) / 2)
	function close_btn2.on_click()
		self:hide()
	end

	panel:add_child(close_btn2)

	-- 注册滚轮事件
	self._on_wheel = function(dx, dy)
		if not self.hidden then
			self:_on_scroll(dy)
		end
	end
end

function WaveEditorView:_create_number_input(parent, x, y, w, h, default_val)
	local container = KView:new(V.v(w, h))
	container.pos = v(x, y)
	container.colors.background = C.input_bg

	local label = KLabel:new(V.v(w - 20, h))
	label.pos = v(2, 0)
	label.text = tostring(default_val or 0)
	label.text_align = "left"
	label.colors.text = C.text
	label.font_size = 13
	label.font_name = KE_CONST.font_name
	label.vertical_align = "middle"
	container:add_child(label)

	local value = default_val or 0
	local result = {
		container = container,
		label = label,
		get_value = function()
			return value
		end,
		set_value = function(self, new_val)
			value = new_val
			label.text = tostring(value)
			if self.on_change then
				self.on_change(value)
			end
		end,
		on_change = nil,
		_inc = function(self, delta)
			value = math.max(0, value + delta)
			label.text = tostring(value)
			if self.on_change then
				self.on_change(value)
			end
		end
	}

	-- +/- 按钮
	local bw = 16
	local inc_btn = KButton:new(V.v(bw, h / 2 - 1))
	inc_btn.text = "+"
	inc_btn.pos = v(w - bw, 0)
	inc_btn.colors.background = C.button_bg
	inc_btn.colors.text = {255, 255, 255, 255}
	inc_btn.font_size = 10
	function inc_btn.on_click()
		result:_inc(1)
	end

	container:add_child(inc_btn)

	local dec_btn = KButton:new(V.v(bw, h / 2 - 1))
	dec_btn.text = "-"
	dec_btn.pos = v(w - bw, h / 2 + 1)
	dec_btn.colors.background = C.button_bg
	dec_btn.colors.text = {255, 255, 255, 255}
	dec_btn.font_size = 10
	function dec_btn.on_click()
		result:_inc(-1)
	end

	container:add_child(dec_btn)

	parent:add_child(container)
	return result
end

function WaveEditorView:_load_wave_data()
	local level_name = "level" .. string.format("%02i", self.level_idx)
	local mode_str = "campaign"
	if self.level_mode == GAME_MODE_HEROIC then
		mode_str = "heroic"
	elseif self.level_mode == GAME_MODE_IRON then
		mode_str = "iron"
	end

	-- 尝试加载现有的出怪文件
	local file_name = string.format("data.waves.level%02d_waves_%s", self.level_idx, mode_str)
	local ok, data = pcall(function()
		package.loaded[file_name] = nil
		return require(file_name)
	end)

	if ok and data then
		return data
	end

	-- 默认数据
	return {
		lives = 20,
		cash = 800,
		groups = {{
			interval = 800,
			waves = {{
				delay = 0,
				path_index = 1,
				spawns = {{
					interval = 50,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_goblin",
					path = 1,
					interval_next = 50,
					max = 3
				}}
			}}
		}}
	}
end

function WaveEditorView:_rebuild_wave_list()
	self._list_content:remove_children()
	local pw = self._list_view.size.x
	local y = 0
	local row_h = 24

	for gi, group in ipairs(self.wave_data.groups or {}) do
		for wi, wave in ipairs(group.waves or {}) do
			for si, spawn in ipairs(wave.spawns or {}) do
				local row = KView:new(V.v(pw, row_h))
				row.pos = v(0, y)
				row.colors.background = gi % 2 == 0 and {30, 38, 56, 255} or {22, 28, 42, 255}

				-- 波次编号
				local idx_label = KLabel:new(V.v(30, row_h))
				idx_label.pos = v(10, 0)
				idx_label.text = tostring(gi)
				idx_label.text_align = "center"
				idx_label.colors.text = C.accent
				idx_label.font_size = 11
				idx_label.font_name = KE_CONST.font_name
				idx_label.vertical_align = "middle"
				row:add_child(idx_label)

				-- 间隔
				local interval_label = KLabel:new(V.v(80, row_h))
				interval_label.pos = v(45, 0)
				interval_label.text = tostring(group.interval or 0)
				interval_label.text_align = "left"
				interval_label.colors.text = C.text
				interval_label.font_size = 11
				interval_label.font_name = KE_CONST.font_name
				interval_label.vertical_align = "middle"
				row:add_child(interval_label)

				-- 路径
				local path_label = KLabel:new(V.v(40, row_h))
				path_label.pos = v(130, 0)
				path_label.text = tostring(wave.path_index or 1)
				path_label.text_align = "center"
				path_label.colors.text = C.text
				path_label.font_size = 11
				path_label.font_name = KE_CONST.font_name
				path_label.vertical_align = "middle"
				row:add_child(path_label)

				-- 延迟
				local delay_label = KLabel:new(V.v(50, row_h))
				delay_label.pos = v(175, 0)
				delay_label.text = tostring(wave.delay or 0)
				delay_label.text_align = "left"
				delay_label.colors.text = C.text
				delay_label.font_size = 11
				delay_label.font_name = KE_CONST.font_name
				delay_label.vertical_align = "middle"
				row:add_child(delay_label)

				-- 敌人类型
				local creep_label = KLabel:new(V.v(180, row_h))
				creep_label.pos = v(230, 0)
				creep_label.text = spawn.creep or ""
				creep_label.text_align = "left"
				creep_label.colors.text = C.text
				creep_label.font_size = 10
				creep_label.font_name = KE_CONST.font_name
				creep_label.vertical_align = "middle"
				row:add_child(creep_label)

				-- 数量
				local max_label = KLabel:new(V.v(50, row_h))
				max_label.pos = v(415, 0)
				max_label.text = tostring(spawn.max or 0)
				max_label.text_align = "center"
				max_label.colors.text = C.text
				max_label.font_size = 11
				max_label.font_name = KE_CONST.font_name
				max_label.vertical_align = "middle"
				row:add_child(max_label)

				-- 出怪间隔
				local sp_interval_label = KLabel:new(V.v(70, row_h))
				sp_interval_label.pos = v(470, 0)
				sp_interval_label.text = tostring(spawn.interval or 0)
				sp_interval_label.text_align = "left"
				sp_interval_label.colors.text = C.text
				sp_interval_label.font_size = 11
				sp_interval_label.font_name = KE_CONST.font_name
				sp_interval_label.vertical_align = "middle"
				row:add_child(sp_interval_label)

				-- 点击行可编辑(选中效果)
				function row.on_click()
					self:_edit_spawn(gi, wi, si)
				end

				self._list_content:add_child(row)
				y = y + row_h
			end
		end
	end

	self._list_content.size = v(pw, y)
	self._waves_count_label.text = tostring(#self.wave_data.groups or 0)
	self:_update_gold_stats()
end

function WaveEditorView:_update_gold_stats()
	if not self._stats_label then
		local stats_label = KLabel:new(V.v(300, 24))
		stats_label.pos = v(620, 45)
		stats_label.text_align = "left"
		stats_label.colors.text = C.accent
		stats_label.font_size = 12
		stats_label.font_name = KE_CONST.font_name
		stats_label.vertical_align = "middle"
		self.panel:add_child(stats_label)
		self._stats_label = stats_label
	end

	-- 简单估算总金币（每个 spawn 的 max * 预估权重）
	-- 这里不精确计算，只是给用户一个参考
	local wave_count = #(self.wave_data.groups or {})
	local total_enemy_gold = 0
	local total_enemy_count = 0
	for _, group in ipairs(self.wave_data.groups or {}) do
		for _, wave in ipairs(group.waves or {}) do
			for _, spawn in ipairs(wave.spawns or {}) do
				local count = spawn.max or 0
				total_enemy_count = total_enemy_count + count
				local e = E and E.entities and E.entities[spawn.creep]
				local gold = (e and e.gold_value) or (e and e.data and e.data.gold_value) or 15
				total_enemy_gold = total_enemy_gold + count * gold
			end
		end
	end
	local initial_cash = self.wave_data.cash or 0
	self._stats_label.text = string.format("总波数: %d | 初始金币: %d | 敌人数: %d | 预估金币: %d", wave_count, initial_cash, total_enemy_count, total_enemy_gold)
end

function WaveEditorView:_add_wave()
	table.insert(self.wave_data.groups, {
		interval = 1000,
		waves = {{
			delay = 0,
			path_index = 1,
			spawns = {{
				interval = 50,
				max_same = 0,
				fixed_sub_path = 0,
				creep = "enemy_goblin",
				path = 1,
				interval_next = 50,
				max = 3
			}}
		}}
	})
	self:_rebuild_wave_list()
end

function WaveEditorView:_edit_spawn(gi, wi, si)
	-- 弹出简单的编辑对话框（后续可扩展为更完整的编辑面板）
	local group = self.wave_data.groups[gi]
	if not group then
		return
	end
	local wave = group.waves[wi]
	if not wave then
		return
	end
	local spawn = wave.spawns[si]
	if not spawn then
		return
	end

	-- 在日志中显示当前值，指导用户直接修改源码
	log.info(string.format("编辑出怪 [波次%d, 子波%d, 出怪%d]: creep=%s, max=%d, interval=%d, path=%d", gi, wi, si, spawn.creep or "?", spawn.max or 0, spawn.interval or 0, spawn.path or 1))

	-- 显示简单提示
	if self.editor and self.editor.gui then
		self.editor.gui:show_save_notification(string.format("已选中: %s x%d (波次%d)", spawn.creep or "?", spawn.max or 0, gi))
	end
end

function WaveEditorView:_on_scroll(dy)
	local max_scroll = math.max(0, self._list_content.size.y - self._list_view.size.y)
	self._list_scroll = km.clamp(0, max_scroll, self._list_scroll - dy * 24)
	self._list_content.pos = v(0, -self._list_scroll)
end

function WaveEditorView:_save_wave_data()
	if not self.editor or not self.editor.store then
		log.error("WaveEditor: no editor/store available")
		return
	end

	local level_name = "level" .. string.format("%02i", self.level_idx)
	local mode_str = "campaign"
	if self.level_mode == GAME_MODE_HEROIC then
		mode_str = "heroic"
	elseif self.level_mode == GAME_MODE_IRON then
		mode_str = "iron"
	end

	-- 序列化出怪数据
	local str = serpent.block(self.wave_data, {
		indent = "    ",
		comment = false,
		sortkeys = false
	})

	local file_name = level_name .. "_waves_" .. mode_str .. ".lua"
	local fn = KR_FULLPATH_BASE .. "/" .. KR_PATH_GAME .. "/data/waves/" .. file_name

	local out = "return " .. str .. "\n"
	local f = io.open(fn, "w")
	if f then
		f:write(out)
		f:flush()
		f:close()
		log.info("Wave data saved to: %s", fn)

		if self.editor and self.editor.gui then
			self.editor.gui:show_save_notification("出怪文件已保存: " .. file_name)
		end
	else
		log.error("Failed to save wave file: %s", fn)
		if self.editor and self.editor.gui then
			self.editor.gui:show_save_notification("保存失败! 文件: " .. file_name)
		end
	end
end

return WaveEditorView
