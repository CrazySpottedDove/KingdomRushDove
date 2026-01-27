-- chunkname: @./all-desktop/gg_views_custom.lua
local log = require("lib.klua.log"):new("gg_views_custom")

require("klove.kui")

local V = require("lib.klua.vector")
local class = require("middleclass")
local km = require("lib.klua.macros")
local F = require("lib.klove.font_db")
local G = love.graphics
local i18n = require("i18n")

require("gg_views")

local FADE_IN_TIME = 0.5
local FADE_OUT_TIME = 0.25

PopUpView = class("PopUpView", KView)

function PopUpView:initialize(size)
	KView.initialize(self, size)

	self.colors.background = {0, 0, 0, 80}
	self.disabled_tint_color = nil
	self.sw = size and size.x or 0
	self.sh = size and size.y or 0
	self.hidden = true
	self._timers = {}
end

function PopUpView:destroy()
	self:cancel_timers()
	PopUpView.super.destroy(self)
end

function PopUpView:show()
	if not self.hidden then
		return
	end

	self:cancel_timers()

	local _timers = {}
	local timer = self:get_window().timer
	local back = self.back or self:get_child_by_id("back")

	self:enable(false)

	if back then
		back.disabled_tint_color = nil
		back.pos = V.v(self.sw * 0.5, self.sh * 0.5 - 50)
		back.alpha = 0

		table.insert(_timers, timer:tween(FADE_IN_TIME, back, {
			alpha = 1,
			pos = {
				y = self.sh * 0.5
			}
		}, "out-quad"))
	end

	table.insert(_timers, timer:tween(FADE_IN_TIME, self.colors.background, {0, 0, 0, 160}, "in-quad"))

	self.propagating = false
	self.propagate_on_click = false
	self.hidden = false
end

function PopUpView:hide()
	local timer = self:get_window().timer

	self:cancel_timers()

	local _timers = {}

	self:disable(false)

	local back = self.back or self:get_child_by_id("back")

	if back then
		table.insert(_timers, timer:tween(FADE_OUT_TIME, back, {
			alpha = 0,
			pos = {
				y = back.pos.y - 50
			}
		}, "out-quad"))
	end

	table.insert(_timers, timer:tween(FADE_OUT_TIME, self.colors.background, {0, 0, 0, 1}, "in-quad", function()
		self.hidden = true
	end))
end

-- 不跳出的情况下不要占用运算资源！
function PopUpView:update(dt)
	if self.hidden then
		return
	end
	PopUpView.super.update(self, dt)
end

function PopUpView:cancel_timers()
	if self._timers then
		for _, t in pairs(self._timers) do
			timer:cancel(t)
		end
	end
end

function PopUpView:on_enter()
	return false
end

function PopUpView:on_exit()
	return false
end

VolumeSlider = class("VolumeSlider", KImageView)
VolumeSlider.static.serialize_children = false

VolumeSlider:append_serialize_keys("style")

VolumeSlider.static.init_arg_names = {"style"}

function VolumeSlider:initialize(style)
	self.style = style or "music"
	self.value = 0

	KImageView.initialize(self, "options_barBg")

	local value_bar = KImageView:new("options_bar")

	value_bar.pos = V.v(0.02666666666666667 * self.size.x, 0.3333333333333333 * self.size.y)
	value_bar.scale.x = 0

	self:add_child(value_bar)

	self.value_bar = value_bar

	local button

	if self.style == "music" then
		button = KImageButton:new("options_sounds_0001", "options_sounds_0002", "options_sounds_0003")
	else
		button = KImageButton:new("options_sounds_0004", "options_sounds_0005", "options_sounds_0006")
	end

	self:add_child(button)

	self.button = button
	button.pos.x = value_bar.pos.x
	button.pos.y = self.size.y * 0.5
	button.anchor.x, button.anchor.y = button.size.x * 0.5, button.size.y * 0.5

	function button.on_down(this, button, x, y)
		this:set_image(this.click_image_name)

		self._sliding = true
	end

	function button.on_up(this, button, x, y)
		this:set_image(this.hover_image_name)

		self._sliding = nil
	end
end

function VolumeSlider:update(dt)
	VolumeSlider.super.update(self, dt)

	local x, y, is_button_down = self:get_window():get_mouse_position()

	if not is_button_down then
		self._sliding = nil

		return
	end

	if self._sliding then
		local wx, wy = self:screen_to_view(x, y)
		local vbx = self.value_bar.pos.x
		local vbw = self.value_bar.size.x
		local value = km.clamp(0, vbw, wx - vbx) / vbw

		self:set_value(value)
	end
end

function VolumeSlider:set_value(value)
	self.value = value
	self.value_bar.scale.x = value

	local vbx = self.value_bar.pos.x
	local vbw = self.value_bar.size.x

	self.button.pos.x = vbx + vbw * value

	if self.on_change then
		self:on_change(value)
	end
end

local function fc(a)
	return {a[1] / 255, a[2] / 255, a[3] / 255, a[4] / 255}
end

GGDoneButton = class("GGDoneButton", GGButton)
GGDoneButton.static.init_arg_names = {"label_text"}

function GGDoneButton:initialize(label_text)
	local rs = GGLabel.static.ref_h / 1080

	GGButton.initialize(self, "heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")

	self.label.size.x = 108 * rs
	self.label.text_size.x = 108 * rs
	self.label.pos.x, self.label.pos.y = 16 * rs, 0
	self.label.vertical_align = i18n:sw("middle-caps", "zh-Hans", "middle", "ko", "middle", "zh-Hant", "middle")
	self.label.font_size = rs * i18n:sw(26, "es", 24, "fr", 24, "ru", 24, "ko", 29)

	if not self.label_text_key and label_text then
		self.label.text = label_text
	end

	self.label.fit_lines = 1
end

GGKR1SelectButton = class("GGKR1SelectButton", GGButton)
GGKR1SelectButton.static.init_arg_names = {"label_text"}

function GGKR1SelectButton:initialize(label_text)
	local rs = GGLabel.static.ref_h / 1080

	GGButton.initialize(self, "heroroom_selectBtn_0001", "heroroom_selectBtn_0002")

	self.label.size.x = 114 * rs
	self.label.text_size.x = 114 * rs
	self.label.pos.x, self.label.pos.y = 17 * rs, 2 * rs
	self.label.vertical_align = i18n:sw("middle-caps", "zh-Hans", "middle", "ko", "middle", "zh-Hant", "middle")
	self.label.font_size = rs * i18n:sw(26, "es", 24, "fr", 24, "ru", 24, "ko", 29)

	if not self.label_text_key and label_text then
		self.label.text = label_text
	end

	self.label.fit_lines = 1
	self.anchor = V.v(75, 36)
end

GGOptionsButton = class("GGOptionsButton", GGButton)
GGOptionsButton.static.init_arg_names = {"label_text"}

function GGOptionsButton:initialize(label_text)
	local rs = GGLabel.static.ref_h / REF_H

	GGButton.initialize(self, "options_button_bg_0001", "options_button_bg_0002", "options_button_bg_0002")

	self.label.size.x = 106 * rs
	self.label.text_size.x = 106 * rs
	self.label.pos.x, self.label.pos.y = 16 * rs, 0
	self.label.vertical_align = i18n:sw("middle-caps", "zh-Hans", "middle", "ko", "middle", "zh-Hant", "middle")
	self.label.font_size = rs * i18n:sw(19, "es", 17, "fr", 17, "ru", 17, "ko", 21)

	if not self.label_text_key and label_text then
		self.label.text = label_text
	end

	self.label.fit_lines = 1
end

GGUpgradesButton = class("GGUpgradesButton", GGButton)
GGUpgradesButton.static.init_arg_names = {"label_text"}

function GGUpgradesButton:initialize(label_text)
	local rs = GGLabel.static.ref_h / REF_H

	GGButton.initialize(self, "Upgrades_Btns_notxt_0001", "Upgrades_Btns_notxt_0002", "Upgrades_Btns_notxt_0002")

	self.on_down_scale = nil
	self.disabled_tint_color = {0.58823529411765, 0.58823529411765, 0.58823529411765, 1}
	self.anchor.x, self.anchor.y = 0, 0
	self.label.pos = V.v(20, 18)
	self.label.size = V.v(93, 38)
	self.label.text_size = V.v(93, 38)
	self.label.vertical_align = i18n:sw("middle-caps", "zh-Hans", "middle", "zh-Hant", "middle", "ko", "middle")
	self.label.font_size = rs * i18n:sw(19, "es", 17, "fr", 17, "ru", 17, "ko", 21)

	if not self.label_text_key and label_text then
		self.label.text = label_text
	end

	self.label.fit_lines = 1
end

GGBorderButton = class("GGBorderButton", GGButton)
GGBorderButton.static.init_arg_names = {"label_text", "large"}

GGBorderButton:append_serialize_keys("large")

function GGBorderButton:initialize(text, large)
	local rs = GGLabel.static.ref_h / REF_H

	if large then
		GGButton.initialize(self, "button_border_large_0001", "button_border_large_0002", "button_border_large_0002")

		self.label.font_size = i18n:sw(24, "ru", 22) * rs
	else
		GGButton.initialize(self, "button_border_0001", "button_border_0002", "button_border_0002")

		self.label.font_size = i18n:sw(19, "es", 17, "fr", 17) * rs
	end

	self.label.pos.y = 0
	self.label.vertical_align = i18n:cjk("middle-caps", "middle", nil, "middle")

	if not self.label_text_key and text then
		self.label.text = text

		self.label:do_fit_lines(1)
	end
end

GGOptionsLabel = class("GGOptionsLabel", GGShaderLabel)

function GGOptionsLabel:initialize(size, image_name)
	local rs = GGLabel.static.ref_h / REF_H

	GGShaderLabel.initialize(self, size, image_name)

	self.font_name = "h"
	self.font_size = 20 * rs
	self.colors.text = {233, 233, 178, 255}
	self.shaders = {"p_glow"}
	self.shader_args = {{
		glow_color = {0, 0, 0, 1},
		thickness = 1.8 * rs
	}}
end

GGPanelHeader = class("GGPanelHeader", GGShaderLabel)

GGPanelHeader:append_serialize_keys("text")

GGPanelHeader.static.init_arg_names = {"text", "width"}

function GGPanelHeader:initialize(text, width)
	local rs = GGLabel.static.ref_h / REF_H

	GGShaderLabel.initialize(self, V.v(width, 32 * rs))

	if KR_GAME == "kr3" then
		self.colors.text = {47, 45, 30, 255}
		self.font_name = "h_popup"
		self.font_size = 28 * rs
		self.shaders = {"p_drop_shadow"}
		self.shader_args = {{
			shadow_color = fc({238, 232, 155, 255})
		}}
	else
		self.colors.text = {250, 250, 250, 255}
		self.font_name = "h"
		self.font_size = 24 * rs
		self.shaders = {"p_bands", "p_glow"}
		self.shader_args = {{
			p1 = 0.42,
			p2 = 0.56,
			margin = 1 * rs,
			c1 = fc({250, 250, 250, 255}),
			c2 = fc({232, 223, 176, 255}),
			c3 = fc({168, 160, 117, 255})
		}, {
			glow_color = {0, 0, 0, 0.85},
			thickness = 2 * rs
		}}
	end

	self.text_align = "center"
	self.vertical_align = i18n:cjk("middle-caps", "middle", "middle", "middle")

	if not self.text_key and text then
		self.text = text

		self:do_fit_lines(1)
	end
end
