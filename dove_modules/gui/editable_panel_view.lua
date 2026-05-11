local log = require("lib.klua.log"):new("EditablePanelView")
local class = require("middleclass")
local V = require("lib.klua.vector")
local EditableItem = class("EditableItem", KButton)
local S = require("sound_db")
local i18n = require("i18n")
local utf8 = require("utf8")

require("klove.kui")
require("gg_views_custom")

local v = V.v
local function CJK(default, zh, ja, kr)
	return i18n.cjk(i18n, default, zh, ja, kr)
end

function EditableItem:initialize(key_text, initial_value, size, keyboard, controller)
	size = size or V.v(300, 40)

	KButton.initialize(self, size)
	self.keyboard = keyboard
	self.controller = controller
	self.key = key_text
	self.value = initial_value or false
	self.on_change_callback = nil
	self.is_focused = false -- 新增：焦点状态

	-- 键名标签
	self.key_label = GGLabel:new(V.v(self.size.x - 80, self.size.y))
	self.key_label.pos = V.v(10, 0)
	self.key_label.font_name = "body"
	self.key_label.font_size = 16
	self.key_label.text = key_text
	self.key_label.text_align = "left"
	self.key_label.vertical_align = "middle"
	self.key_label.colors.text = {200, 200, 200, 255}
	self.key_label.colors.text_default = {200, 200, 200, 255}
	self.key_label.colors.text_hover = {255, 255, 255, 255}
	self.key_label.colors.text_focused = {255, 220, 100, 255} -- 新增：焦点颜色
	self.key_label.propagate_on_click = true

	self:add_child(self.key_label)

	-- 值标签
	self.value_label = GGLabel:new(V.v(60, self.size.y))
	self.value_label.pos = V.v(self.size.x - 70, 0)
	self.value_label.font_name = "body"
	self.value_label.font_size = 16
	self.value_label.text = nil
	self.value_label.text_align = "center"
	self.value_label.vertical_align = "middle"
	self.value_label.colors.text_yes = {100, 255, 100, 255}
	self.value_label.colors.text_no = {255, 100, 100, 255}
	self.value_label.colors.text_yes_hover = {150, 255, 150, 255}
	self.value_label.colors.text_no_hover = {255, 150, 150, 255}
	self.value_label.colors.text_default = {200, 200, 200, 255}
	self.value_label.colors.text_focused = {255, 255, 100, 255} -- 新增：焦点颜色
	self.value_label.propagate_on_click = true

	self:add_child(self.value_label)

	-- 新增：输入框边框提示（用于 number 和 string 类型）
	self.input_border = KView:new(V.v(70, self.size.y - 4))
	self.input_border.pos = V.v(self.size.x - 75, 2)
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
		self.parent:clear_focus()
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
			self.parent:clear_focus()
			self:set_focused(true)
		end
	elseif self._type == "string" then
		-- screen_map.window:set_responder(self)
		self.controller:set_responder(self)
		self.parent:clear_focus()
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
	self.keyboard = keyboard
	self.controller = controller
end

function EditableGroup:clear_focus()
	for _, item in pairs(self.items) do
		item:set_focused(false)
	end
end

function EditableGroup:set_key_label_map(map)
	self.key_label_map = map
end

function EditableGroup:add_items(data)
	local total_items = 0

	for key, value in pairs(data) do
		if type(value) == "boolean" or type(value) == "number" or type(value) == "string" then
			total_items = total_items + 1
		end
	end

	-- 重新调整所有 item 的位置
	local max_rows = 8 -- 每列最多 6 个 item
	local row_height = self.item_height
	local actual_columns = math.ceil(total_items / max_rows - 0.0001) -- 实际列数
	local column_width = (self.size.x - (1 + actual_columns) * self.padding.x) / actual_columns -- 动态计算列宽
	local actual_rows = math.min(total_items, max_rows) -- 实际行数
	local actual_height = actual_rows * row_height -- 实际高度
	local start_x = self.padding.x -- 水平居中起始位置
	local start_y = self.padding.y -- 垂直居中起始位置
	local index = 0

	for key, value in pairs(data) do
		if type(value) == "boolean" or type(value) == "number" or type(value) == "string" then
			-- 添加新 item
			if self.key_label_map[key] then
				local item = EditableItem:new(self.key_label_map[key], value, V.v(column_width, 40), self.keyboard, self.controller)

				item.pos = V.v((start_x + math.floor(index / max_rows) * (column_width + self.padding.x)), start_y + (index % max_rows) * row_height)
				item.on_change_callback = function(label, value)
					self.data[table.keyforobject(self.key_label_map, label) or label] = value
				end
				self.items[key] = item
				self.data[key] = value
				index = index + 1

				self:add_child(item)
			end
		end
	end
end

function EditableGroup:get_value(key)
	return self.data[key]
end

function EditableGroup:get_all_data()
	return self.data
end

function EditableGroup:set_all_data(data)
	self.data = data

	for key, item in pairs(self.items) do
		self:remove_child(item)
	end

	self.items = {}

	self:add_items(data)
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

	-- 创建配置组
	self.data_group = EditableGroup:new(V.v(self.back.size.x, self.back.size.y), keyboard, controller)
	self.data_group.pos = V.v(100, 100)
	self.data_group.scale = v(1 / 1.45, 1 / 1.45)

	-- 设置数据改变回调
	self.data_group:set_on_data_change_callback(function(key, value, all_data)
	end)
	self.back:add_child(self.data_group)

	-- 添加底部按钮
	local mx = 150
	local y = 450
	local b = GGOptionsButton:new(_("BUTTON_DONE"))

	b.anchor.x = b.size.x / 2
	b.pos = V.v(self.back.size.x / 2, y)

	function b.on_click()
		S:queue("GUIButtonCommon")
		self:save()
		self:hide()
	end

	self.done_button = b

	self.back:add_child(b)
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
