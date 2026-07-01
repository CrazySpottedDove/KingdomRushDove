local class = require("middleclass")
local log = require("lib.klua.log"):new("kr5_gui_balloon")
local signal = require("lib.hump.signal")
local V = require("lib.klua.vector")
local GU = require("gui_utils")
local tb = require("kr5_taunt_balloon")

local Kr5TextBalloon = class("Kr5TextBalloon", KView)

local function flag_has(flags, token)
	return string.find(flags, token, 1, true) ~= nil
end

local function build_callout_balloon(parent, max_size, flags, text, text_padding, background_color, line_color, text_color)
	max_size = max_size or V.v(256, 0)

	local text_font = "body"
	local text_font_size = 28
	local text_align, text_vertical_align = "left", "middle"
	local text_line_height = 0.85
	local fit_lines, direction
	local padding = text_padding or V.v(10, 10)
	local separation = 0

	background_color = background_color or {
		254,
		243,
		213,
		255
	}
	line_color = line_color or {
		127,
		104,
		86,
		255
	}
	text_color = text_color or {
		70,
		56,
		47,
		255
	}

	local tip_offset = V.v(30, 0)
	local tip_size = 15

	if flag_has(flags, "centered") then
		text_align = "center"
	end

	if flag_has(flags, "direction_v") then
		direction = "v"
	end

	if flag_has(flags, "direction_h") then
		direction = "h"
	end

	if flag_has(flags, "dialog") then
		text_font_size = 17
	end

	local l_text = GGLabel:new(max_size)

	l_text.text = text
	l_text.font_name = text_font
	l_text.font_size = text_font_size
	l_text.text_align = text_align
	l_text.fit_lines = fit_lines
	l_text.vertical_align = text_vertical_align
	l_text.line_height = text_line_height

	if not l_text.colors then
		l_text.colors = {}
	end

	l_text.colors.text = text_color

	l_text:_load_font()
	l_text:_fit_text()

	local tw, tc = l_text:get_wrap_lines()
	local th = l_text:get_font_height()

	l_text.size.x = tw
	l_text.size.y = math.ceil(tc * th * text_line_height)

	local block_size = V.v(l_text.size.x, l_text.size.y)

	Kr5TextBalloon.super.initialize(parent, V.v(block_size.x + 2 * padding.x, block_size.y + 2 * padding.y))

	if flag_has(flags, "callout-") then
		local bw, bh = parent.size.x, parent.size.y
		local background = KView:new(V.v(bw, bh))

		if flag_has(flags, "side") then
			if flag_has(flags, "left") then
				background.scale.x = -1
				tip_offset.x = bw
				parent.anchor.x = 0 - tip_size
			elseif flag_has(flags, "right") then
				tip_offset.x = bw
				parent.anchor.x = bw + tip_size
			end

			if flag_has(flags, "top") then
				background.scale.y = -1
				tip_offset.y = bh - bh / 4
				parent.anchor.y = bh / 4
			elseif flag_has(flags, "bottom") then
				tip_offset.y = bh - bh / 4
				parent.anchor.y = 3 * bh / 4
			else
				tip_offset.y = bh / 2
				parent.anchor.y = bh / 2
			end
		else
			if flag_has(flags, "left") then
				background.scale.x = -1
				tip_offset.x = bw - bw / 4
				parent.anchor.x = bw / 4
			elseif flag_has(flags, "right") then
				tip_offset.x = bw - bw / 4
				parent.anchor.x = 3 * bw / 4
			else
				tip_offset.x = bw / 2
				parent.anchor.x = bw / 2
			end

			if flag_has(flags, "top") then
				background.scale.y = -1
				parent.anchor.y = 0 - tip_size
			elseif flag_has(flags, "bottom") then
				parent.anchor.y = bh + tip_size
			else
				parent.anchor.y = bh / 2
			end
		end

		local vertices = GU.rounded_rectangle(0, 0, bw, bh, 5, tip_offset, 1.6)

		background.colors.background = background_color
		background.shape = {
			name = "polygon",
			args = vertices
		}
		background.propagate_on_click = true
		background.anchor = V.v(bw / 2, bh / 2)
		background.pos = V.v(bw / 2, bh / 2)

		parent:add_child(background)

		local border_vertices = table.clone(vertices)

		border_vertices[1] = "line"

		local line = KView:new(V.v(bw, bh))

		line.colors.background = line_color
		line.shape = {
			name = "polygon",
			args = border_vertices
		}
		line.propagate_on_click = true

		background:add_child(line)
	end

	local x_margin = math.floor((parent.size.x - block_size.x) * 0.5)
	local y_margin = math.floor((parent.size.y - block_size.y) * 0.5)

	l_text.pos = V.v(x_margin, y_margin)
	parent:add_child(l_text)
end

function Kr5TextBalloon:initialize(id, pos_override, gui)
	local bd = tb.get_def(id)

	if not bd then
		log.error("Kr5TextBalloon: missing definition for %s", id)

		return
	end

	self.gui = gui

	local flags = bd.flags or ""
	local text = tb.get_text(id, bd)

	build_callout_balloon(self, bd.size, flags, text, bd.padding, bd.bg_color, bd.line_color, bd.text_color)

	self.id = id
	self.propagate_on_click = true
	self.propagate_on_down = true
	self.propagate_on_up = true
	self.show_time = tb.taunt_duration(bd.time)
	self.world_pos = V.vclone(pos_override or bd.offset or V.v(512, 560))
	self.sig_handles = {}
	self.remove_requested = false

	local function sig_reg(name, fn)
		local h = signal.register(name, fn)

		table.insert(self.sig_handles, {name, h})
	end

	sig_reg("game-defeat", function()
		self:remove(false)
	end)
	sig_reg("game-victory", function()
		self:remove(false)
	end)
	sig_reg("turn-off-balloon", function()
		self:remove(true)
	end)

	self.hidden = true
	self.tween_handle = nil
	self:sync_world_pos()
end

function Kr5TextBalloon:sync_world_pos()
	local gui = self.gui

	if not self.world_pos or not gui or not gui.game then
		return
	end

	local ux, uy = gui:g2u(self.world_pos)
	local z = gui.game.camera.zoom

	self.pos.x, self.pos.y = ux, uy
	self.scale.x = z
	self.scale.y = z
end

function Kr5TextBalloon:reveal()
	if not self.hidden then
		return
	end

	local gui = self.gui

	if not gui or not gui.game or not gui.game.store then
		return
	end

	self:sync_world_pos()
	self.hidden = false
	self.show_ts = gui.game.store.tick_ts
end

function Kr5TextBalloon:remove(animated)
	if self.remove_requested then
		return
	end

	self.remove_requested = true

	for _, h in pairs(self.sig_handles) do
		local name, fn = unpack(h)

		signal.remove(name, fn)
	end

	local gui = self.gui
	local t = gui and gui.timer

	if gui and gui.kr5_gui_balloon == self then
		gui.kr5_gui_balloon = nil
	end

	if self.tween_handle and t then
		t:cancel(self.tween_handle)
		self.tween_handle = nil
	end

	if animated and t then
		local s = 0.4

		self.tween_handle = t:tween(0.4, self, {
			alpha = 0,
			scale = {
				x = s,
				y = s
			}
		}, "in-back", function()
			self:remove_from_parent()
		end)
	else
		self:remove_from_parent()
	end
end

function Kr5TextBalloon:update(dt)
	Kr5TextBalloon.super.update(self, dt)

	local gui = self.gui

	if self.world_pos and gui and gui.game then
		self:sync_world_pos()
	end

	if not self.hidden and not self.remove_requested and self.show_time and self.show_ts and gui and gui.game and gui.game.store then
		if gui.game.store.tick_ts - self.show_ts >= self.show_time then
			self:remove(true)
		end
	end
end

local M = {}

function M.show(gui, taunt_id, pos_override)
	if not gui or not gui.game or not gui.layer_gui_game then
		return nil
	end

	local b = Kr5TextBalloon:new(taunt_id, pos_override, gui)

	if not b or not b.size or not b.gui then
		return nil
	end

	gui.layer_gui_game:add_child(b)
	b:reveal()

	return b
end

M.Kr5TextBalloon = Kr5TextBalloon

return M
