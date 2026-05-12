local log = require("lib.klua.log"):new("EditablePanelView")
local class = require("middleclass")
local V = require("lib.klua.vector")
local S = require("sound_db")
local i18n = require("i18n")
local utf8 = require("utf8")

require("klove.kui")
require("gg_views_custom")

local v = V.v
local function CJK(default, zh, ja, kr)
	return i18n.cjk(i18n, default, zh, ja, kr)
end

local EditableItem = class("EditableItem", KButton)
function EditableItem:initialize(key_text, initial_value, size, keyboard, controller, editable_group)
	size = size or V.v(300, 40)

	KButton.initialize(self, size)
	self.keyboard = keyboard
	self.controller = controller
	self.editable_group = editable_group
	self.key = key_text
	self.value = initial_value or false
	self.on_change_callback = nil
	self.is_focused = false -- 新增：焦点状态

	-- 键名标签
	self.key_label = GGLabel:new(V.v(self.size.x - 190, self.size.y))
	self.key_label.pos = V.v(10, 0)
	self.key_label.font_name = "body"
	self.key_label.font_size = 16
	self.key_label.text = key_text
	self.key_label.text_align = "left"
	self.key_label.vertical_align = "middle"
	self.key_label.fit_lines = 1
	self.key_label.fit_size = true
	self.key_label.colors.text = {200, 200, 200, 255}
	self.key_label.colors.text_default = {200, 200, 200, 255}
	self.key_label.colors.text_hover = {255, 255, 255, 255}
	self.key_label.colors.text_focused = {255, 220, 100, 255} -- 新增：焦点颜色
	self.key_label.propagate_on_click = true

	self:add_child(self.key_label)

	-- 值标签
	self.value_label = GGLabel:new(V.v(170, self.size.y))
	self.value_label.pos = V.v(self.size.x - 180, 0)
	self.value_label.font_name = "body"
	self.value_label.font_size = 16
	self.value_label.text = nil
	self.value_label.text_align = "center"
	self.value_label.vertical_align = "middle"
	self.value_label.fit_lines = 1
	self.value_label.fit_size = true
	self.value_label.colors.text_yes = {100, 255, 100, 255}
	self.value_label.colors.text_no = {255, 100, 100, 255}
	self.value_label.colors.text_yes_hover = {150, 255, 150, 255}
	self.value_label.colors.text_no_hover = {255, 150, 150, 255}
	self.value_label.colors.text_default = {200, 200, 200, 255}
	self.value_label.colors.text_focused = {255, 255, 100, 255} -- 新增：焦点颜色
	self.value_label.propagate_on_click = true

	self:add_child(self.value_label)

	-- 新增：输入框边框提示（用于 number 和 string 类型）
	self.input_border = KView:new(V.v(170, self.size.y - 4))
	self.input_border.pos = V.v(self.size.x - 180, 2)
	self.input_border.colors.background = {0, 0, 0, 0}
	self.input_border.colors.border_focused = {255, 220, 100, 200}
	self.input_border.colors.border_normal = {100, 100, 100, 100}
	self.input_border.hidden = true
	self.input_border.propagate_on_click = true
	self:add_child(self.input_border)

	-- 新增：光标闪烁效果
	self.cursor = KView:new(V.v(2, self.size.y - 12))
	self.cursor.pos = V.v(self.size.x - 15, 6)
	self.cursor.colors.background = {255, 255, 255, 255}
	self.cursor.hidden = true
	self.cursor.propagate_on_click = true
	self:add_child(self.cursor)
	self.cursor_blink_time = 0

	self._type = type(initial_value)

	-- 设置初始状态
	self:update_display()
end

function EditableItem:update(dt)
	KButton.update(self, dt)

	-- 光标闪烁效果
	if self.is_focused and (self._type == "number" or self._type == "string") then
		self.cursor_blink_time = self.cursor_blink_time + dt
		self.cursor.hidden = math.floor(self.cursor_blink_time * 2) % 2 == 1

		-- 更新光标位置（在文字末尾）
		local text_width = self.value_label:get_text_width(self.value_label.text or "")
		self.cursor.pos.x = self.value_label.pos.x + (self.value_label.size.x + text_width) / 2 + 2
	else
		self.cursor.hidden = true
	end
end

function EditableItem:update_display()
	if self._type == "boolean" then
		self.input_border.hidden = true
		if self.value then
			self.value_label.text = _("YES")
			self.value_label.colors.text = self.value_label.colors.text_yes
		else
			self.value_label.text = _("NO")
			self.value_label.colors.text = self.value_label.colors.text_no
		end
	elseif self._type == "number" then
		self.input_border.hidden = false
		if not self.value_label.text then
			self.value_label.text = tostring(self.value)
		end

		if self.is_focused then
			self.value_label.colors.text = self.value_label.colors.text_focused
		else
			self.value_label.colors.text = self.value_label.colors.text_default
		end
	elseif self._type == "string" then
		self.input_border.hidden = false
		if not self.value_label.text then
			self.value_label.text = self.value
		end

		if self.is_focused then
			self.value_label.colors.text = self.value_label.colors.text_focused
		else
			self.value_label.colors.text = self.value_label.colors.text_default
		end
	end

	-- 更新边框颜色
	if self.input_border and not self.input_border.hidden then
		if self.is_focused then
			self.colors.background = {80, 70, 30, 150} -- 焦点时的背景色
		end
	end

	-- 强制重绘
	if self.value_label.redraw then
		self.value_label:redraw()
	end
end

function EditableItem:on_enter()
	-- 悬浮高亮效果
	if not self.is_focused then
		self.colors.background = {50, 50, 50, 100}
	end
	self.key_label.colors.text = self.is_focused and self.key_label.colors.text_focused or self.key_label.colors.text_hover

	if self._type == "boolean" then
		if self.value then
			self.value_label.colors.text = self.value_label.colors.text_yes_hover
		else
			self.value_label.colors.text = self.value_label.colors.text_no_hover
		end
	end

	if self.value_label.redraw then
		self.value_label:redraw()
	end
end

function EditableItem:set_focused(focused)
	self.is_focused = focused
	self.cursor_blink_time = 0

	if focused then
		-- 获得焦点时的视觉效果
		self.colors.background = {80, 70, 30, 150}
		self.key_label.colors.text = self.key_label.colors.text_focused

		if self._type == "number" or self._type == "string" then
			self.cursor.hidden = false
		end
	else
		-- 失去焦点时恢复
		self.colors.background = {0, 0, 0, 0}
		self.key_label.colors.text = self.key_label.colors.text_default
		self.cursor.hidden = true
	end

	self:update_display()
end

function EditableItem:on_exit()
	-- 取消高亮效果（但保留焦点状态）
	if not self.is_focused then
		self.colors.background = {0, 0, 0, 0}
		self.key_label.colors.text = self.key_label.colors.text_default
	else
		self.colors.background = {80, 70, 30, 150}
		self.key_label.colors.text = self.key_label.colors.text_focused
	end

	self:update_display()
end

function EditableItem:set_value_lable(new_value)
	self.value_label.text = new_value or self.value_label.text

	if self._type == "number" then
		local num = tonumber(self.value_label.text)
		if num then
			self.value = num
		end
	elseif self._type == "string" then
		self.value = self.value_label.text
	end

	self:update_display()

	if self.on_change_callback then
		self.on_change_callback(self.key, self.value)
	end
end

function EditableItem:on_click(button, vx, vy)
	S:queue("GUIButtonCommon")

	if self._type == "boolean" then
		self.value = not self.value
		-- self.parent:clear_focus()
		self.editable_group:clear_focus()
	elseif self._type == "number" then
		if IS_ANDROID then
			-- 安卓端：弹出数字键盘让用户精确输入
			local item = self
			-- screen_map.numeric_keyboard:order_to_front()
			-- screen_map.numeric_keyboard:open(self.value, function(new_val)
			-- 	if new_val ~= nil then
			-- 		item:set_value_lable(tostring(new_val))
			-- 	end
			-- end)
			self.keyboard:order_to_front()
			self.keyboard:open(self.value, function(new_val)
				if new_val ~= nil then
					item:set_value_lable(tostring(new_val))
				end
			end)
		else
			-- 电脑端：直接键盘录入
			-- screen_map.window:set_responder(self)
			self.controller:set_responder(self)
			-- self.parent:clear_focus()
			self.editable_group:clear_focus()
			self:set_focused(true)
		end
	elseif self._type == "string" then
		-- screen_map.window:set_responder(self)
		self.controller:set_responder(self)
		-- self.parent:clear_focus()
		self.editable_group:clear_focus()
		self:set_focused(true)
	end

	self:update_display()

	if self.on_change_callback then
		self.on_change_callback(self.key, self.value)
	end
end

function EditableItem:on_textinput(t)
	if self._type == "number" then
		self:set_value_lable(tostring(self.value_label.text .. t))
	elseif self._type == "string" then
		self:set_value_lable(self.value_label.text .. t)
	end

	return true
end

function EditableItem:on_keypressed(key)
	if self._type == "number" or self._type == "string" then
		if key == "backspace" then
			local text = self.value_label.text
			local byteoffset = utf8.offset(text, -1)

			if byteoffset then
				if byteoffset > 1 then
					self.value_label.text = string.sub(text, 1, byteoffset - 1)
				else
					self.value_label.text = ""
				end
			else
				self.value_label.text = ""
			end

			self:set_value_lable()
		elseif key == "return" then
			S:queue("GUIButtonCommon")
			-- 按回车或ESC确认输入并取消焦点
			self:set_focused(false)
			-- screen_map.window:set_responder()
			self.controller:set_responder()
		end
	end
end

local EditableGroup = class("EditableGroup", KView)

function EditableGroup:initialize(size, keyboard, controller)
	size = size or V.v(400, 300)

	KView.initialize(self, size)

	self.key_label_map = {}
	self.items = {}
	self.item_height = 45
	self.padding = V.v(10, 10) -- 修正：使用向量表示水平和垂直内边距
	self.data = {}
	self.sorted_keys = {}
	self.keyboard = keyboard
	self.controller = controller

	self.list = KScrollList:new(V.v(self.size.x - 2 * self.padding.x, self.size.y - 2 * self.padding.y))
	self.list.pos = V.v(self.padding.x, self.padding.y)
	self.list.scroll_acceleration = 0
	self.list.scroll_amount = self.item_height
	self.list.drag_scroll_threshold = 8
	self.list:set_scroller_size(12, 2)
	self.list.colors.scroller_background = {80, 70, 50, 120}
	self.list.colors.scroller_foreground = {180, 160, 120, 200}
	self:add_child(self.list)
end

function EditableGroup:clear_focus()
	for _, item in pairs(self.items) do
		item:set_focused(false)
	end
end

function EditableGroup:set_key_label_map(map)
	self.key_label_map = map or {}
	self:_rebuild_and_render()
end

function EditableGroup:_is_editable_type(value)
	local t = type(value)
	return t == "boolean" or t == "number" or t == "string"
end

function EditableGroup:_clear_items()
	self.list:clear_rows()
	self.items = {}
end

function EditableGroup:_collect_sorted_keys()
	local keys = {}

	for key, value in pairs(self.data) do
		if self:_is_editable_type(value) and self.key_label_map[key] then
			keys[#keys + 1] = key
		end
	end

	table.sort(keys, function(a, b)
		local la = tostring(self.key_label_map[a] or a)
		local lb = tostring(self.key_label_map[b] or b)

		if la == lb then
			return tostring(a) < tostring(b)
		end

		return la < lb
	end)

	self.sorted_keys = keys
end

function EditableGroup:_render_list()
	self:_clear_items()

	local item_w = self.list.size.x - self.padding.x * 2 - 20
	local item_h = 40
	local item_y = math.floor((self.item_height - item_h) * 0.5)

	for idx = 1, #self.sorted_keys do
		local key = self.sorted_keys[idx]
		local value = self.data[key]
		local row = KView:new(V.v(self.list.size.x, self.item_height))
		row.propagate_on_down = true
		row.propagate_on_up = true
		row.propagate_on_touch_down = true
		row.propagate_on_touch_up = true
		row.propagate_on_touch_move = true
		local item = EditableItem:new(self.key_label_map[key], value, V.v(item_w, item_h), self.keyboard, self.controller, self)

		item.pos = V.v(self.padding.x, item_y)
		-- 允许事件继续冒泡到 KScrollList，保证触屏拖动滚动体验
		item.propagate_on_down = true
		item.propagate_on_up = true
		item.propagate_on_touch_down = true
		item.propagate_on_touch_up = true
		item.propagate_on_touch_move = true

		item.on_change_callback = function(_, new_value)
			self.data[key] = new_value
			if self.on_data_change_callback then
				self.on_data_change_callback(key, new_value, self:get_all_data())
			end
		end

		row:add_child(item)
		self.list:add_row(row)
		self.items[key] = item
	end
end

function EditableGroup:_rebuild_and_render()
	self:_collect_sorted_keys()
	self:clear_focus()
	self:_render_list()
	self.list:scroll_to_top()
end

function EditableGroup:get_value(key)
	return self.data[key]
end

function EditableGroup:get_all_data()
	return table.deepclone(self.data)
end

function EditableGroup:set_all_data(data)
	self.data = table.deepclone(data or {})
	self:_rebuild_and_render()
end

function EditableGroup:set_on_data_change_callback(callback)
	self.on_data_change_callback = callback
end

local EditablePanelView = class("EditablePanelView", PopUpView)

function EditablePanelView:initialize(sw, sh, title, keyboard, controller)
	PopUpView.initialize(self, V.v(sw, sh))

	self.back = KImageView:new("options_bg_notxt")
	self.pos = v(0, 0)
	self.back.anchor = v(self.back.size.x / 2, self.back.size.y / 2)
	self.back.pos = v(sw / 2, sh / 2 - 50)
	self.back.scale = v(1.45, 1.45)
	self.header = title
	self.controller = controller

	self:add_child(self.back)

	self.back.alpha = 1

	-- 添加标题
	local header = GGPanelHeader:new(self.header, 242)

	header.pos = V.v(240, CJK(41, 39, nil, 39))

	self.back:add_child(header)

	local controls_y = 448

	-- 创建配置组
	self.data_group = EditableGroup:new(V.v(self.back.size.x, controls_y - 10), keyboard, controller)
	self.data_group.pos = V.v(100, 100)
	self.data_group.scale = v(1 / 1.45, 1 / 1.45)

	-- 设置数据改变回调
	self.data_group:set_on_data_change_callback(function(key, value, all_data)
	end)
	self.back:add_child(self.data_group)

	-- 底部按钮（无分页，改为滚动列表）
	local cancel_btn = GGOptionsButton:new(CJK("Cancel", "取消"))
	cancel_btn.scale = V.v(0.62, 0.62)
	cancel_btn.anchor = V.v(cancel_btn.size.x / 2, cancel_btn.size.y / 2)
	cancel_btn.pos = V.v(self.back.size.x / 2 - 110, controls_y)
	function cancel_btn.on_click()
		S:queue("GUIButtonCommon")
		self:hide()
	end
	self.cancel_button = cancel_btn
	self.back:add_child(cancel_btn)

	local done_btn = GGOptionsButton:new(_("BUTTON_DONE"))
	done_btn.scale = V.v(0.62, 0.62)
	done_btn.anchor = V.v(done_btn.size.x / 2, done_btn.size.y / 2)
	done_btn.pos = V.v(self.back.size.x / 2 + 110, controls_y)
	function done_btn.on_click()
		S:queue("GUIButtonCommon")
		self:save()
		self:hide()
	end
	self.done_button = done_btn
	self.back:add_child(done_btn)
end

function EditablePanelView:set_key_label_map(map)
	self.data_group:set_key_label_map(map)
end

function EditablePanelView:load()
	log.error("EditablePanelView:load not implemented")
end

function EditablePanelView:save()
	log.error("EditablePanelView:save not implemented")
end

function EditablePanelView:show()
	self:load()
	EditablePanelView.super.show(self)
end

function EditablePanelView:hide()
	self.data_group:clear_focus() -- 隐藏前清除焦点状态
	-- screen_map.window:set_responder() -- 隐藏时归还输入控制权
	-- self.parent:set_responder()
	self.controller:set_responder()
	EditablePanelView.super.hide(self)
end

return EditablePanelView
