-- chunkname: @./all/gg_views.lua
local log = require("lib.klua.log"):new("gg_views")

require("klove.kui")

local V = require("lib.klua.vector")
local class = require("middleclass")
local km = require("lib.klua.macros")
local F = require("lib.klove.font_db")
local G = love.graphics
local I = require("lib.klove.image_db")
local utf8 = require("utf8")
local i18n = require("i18n")

GGLabel = class("GGLabel", KLabel)

GGLabel:append_serialize_keys("text_key", "text_shadow", "text_shadow_offset", "fit_lines", "fit_step", "fit_size", "vertical_align")

GGLabel.static.serialize_children = false
GGLabel.static.font_scale = 1
GGLabel.static.ref_h = REF_H

GGLabel:include(KMLocaleOverrides)

function GGLabel:initialize(size, image_name)
	self.font_name = nil
	self.font_size = nil
	self.text_key = nil
	self.text_shadow = nil
	self.text_shadow_offset = V.v(1, 1)
	self.fit_lines = nil
	self.fit_step = 0.5
	self._font_scale = GGLabel.static.font_scale
	self._ref_h = GGLabel.static.ref_h

	KLabel.initialize(self, size, image_name)

	if not self.colors.text_shadow then
		self.colors.text_shadow = {0, 0, 0, 255}
	end

	if DEBUG_GG_SHOW_BG then
		self.colors.background = {255, 0, 0, 100}
	end

	if self.text_key then
		self.text = _(self.text_key)
	end

	self._fitted_font = nil
	self._fitted_lines = nil
	self._fitted_text = nil
end

function GGLabel:_load_font()
	local font_size = self._fitted_font_size or self.font_size

	if not self.font or self._loaded_font_name ~= self.font_name or self._loaded_font_size ~= font_size then
		self._fitted_font = nil
		self._loaded_font_name = self.font_name
		self._loaded_font_size = font_size

		if self.font_name and self.font_size then
			self.font = F:f(self.font_name, font_size * self._font_scale)
			self.font_adj = F:f_adj(self.font_name, font_size * self._font_scale)
		else
			log.debug("Font not specified for %s", self)

			self.font = G:getFont()
			self.font_adj = {
				size = 1
			}
		end
	end
end

function GGLabel:_fit_text()
	local font_size = self.font_size
	local fit_lines = self.fit_lines
	local fit_size = self.fit_size
	local step = self.fit_step

	if not fit_lines and not fit_size then
		return
	end

	if fit_lines and fit_lines > 1 and self.text and not table.contains({"ja", "zh-Hans", "zh-Hant"}, i18n.current_locale) then
		local spacers = {" ", ",", "\n", utf8.char(65292), utf8.char(12290)}

		for _, v in pairs(spacers) do
			if string.find(self.text, v) then
				goto label_3_0
			end
		end

		fit_lines = 1
	end

	::label_3_0::

	if self._fitted_font ~= self.font or self._fitted_starting_font_size ~= font_size or self._fitted_lines ~= fit_lines or self._fitted_fit_size ~= fit_size or self._fitted_step ~= self.fit_step or self._fitted_size ~= self.text_size or self._fitted_text ~= self.text then
		self.font = nil
		self._fitted_font_size = nil

		while font_size >= 1 do
			local _, lines = self:get_wrap_lines()
			local h = lines * self:get_font_height() * self.line_height

			if fit_lines and fit_size and lines <= fit_lines and h <= self.text_size.y or not fit_size and fit_lines and lines <= fit_lines or not fit_lines and fit_size and h <= self.text_size.y then
				break
			end

			font_size = font_size - step
			self._fitted_font_size = font_size
			self.font = nil
		end

		if font_size < 1 then
			log.error("Could not fit label %s for text %s, size:%s,%s, lines:%s, fit_size:%s", self.id, self.text, self.text_size.x, self.text_size.y, fit_lines, fit_size)

			self._fitted_font_size = nil
		end

		self._fitted_starting_font_size = self.font_size
		self._fitted_font = self.font
		self._fitted_lines = fit_lines
		self._fitted_fit_size = fit_size
		self._fitted_step = self.fit_step
		self._fitted_size = self.text_size
		self._fitted_text = self.text
	end
end

function GGLabel:_draw_self()
	KLabel.super._draw_self(self)
	self:_load_font()
	self:_fit_text()

	local font_scale = self._font_scale or GGLabel.static.font_scale

	G.setFont(self.font)
	self.font:setLineHeight(self.line_height)

	local pr, pg, pb, pa = G.getColor()
	local voff = (self.font_adj.top or 0) / font_scale

	if self.vertical_align and self.vertical_align ~= "top" then
		local _, tl = self:get_wrap_lines()
		local th = self:get_font_height()
		local des = -1 * self.font:getDescent() / font_scale
		local base = self.font:getBaseline() / font_scale

		if tl > 1 then
			th = th + (tl - 1) * self:get_font_height() * self.font:getLineHeight()
		end

		if self.vertical_align == "middle" then
			voff = math.floor((self.text_size.y - th) * 0.5)
		elseif self.vertical_align == "middle-caps" then
			voff = math.floor((self.text_size.y - th + des) * 0.5)
		elseif self.vertical_align == "bottom" then
			voff = self.text_size.y - th
		elseif self.vertical_align == "bottom-caps" then
			voff = self.text_size.y - th + des
		elseif self.vertical_align == "base" then
			voff = -base
		end

		local vadj = (self.font_adj[self.vertical_align] or 0) / font_scale

		voff = voff + vadj
	end

	if self.text_shadow then
		local tsc = self.colors.text_shadow
		local new_c = {tsc[1], tsc[2], tsc[3], tsc[4]}

		if not new_c[4] then
			new_c[4] = 255
		end

		new_c[4] = self.alpha * pa / 255 * new_c[4]

		G.setColor_old(new_c)

		local sox, soy = self.text_shadow_offset.x, self.text_shadow_offset.y

		G.printf(self.text, self.text_offset.x + sox, self.text_offset.y + soy + voff, self.text_size.x * font_scale, self.text_align, 0, 1 / font_scale)
	end

	if self.colors.text then
		local new_c1, new_c2, new_c3, new_c4 = self.colors.text[1], self.colors.text[2], self.colors.text[3], self.colors.text[4] or 255

		if self.colors.tint then
			local tint_c = self.colors.tint
			new_c1 = new_c1 * tint_c[1]
			new_c2 = new_c2 * tint_c[2]
			new_c3 = new_c3 * tint_c[3]
			new_c4 = new_c4 * tint_c[4]
		end

		new_c4 = new_c4 * self.alpha * pa / 255

		G.setColor_old(new_c1, new_c2, new_c3, new_c4)
	end

	G.printf(self.text, self.text_offset.x, self.text_offset.y + voff, self.text_size.x * font_scale, self.text_align, 0, 1 / font_scale)
	G.setColor(pr, pg, pb, pa)
end

function GGLabel:get_wrap_lines()
	self:_load_font()

	local width, wrapped = self.font:getWrap(self.text, self.text_size.x * self._font_scale)

	width = width / self._font_scale

	return width, #wrapped, wrapped
end

function GGLabel:get_font_height()
	self:_load_font()

	if self.font then
		return self.font:getHeight() / self._font_scale
	end

	return 0
end

function GGLabel:get_font_ascent()
	self:_load_font()

	if self.font then
		return self.font:getAscent() / self._font_scale
	end

	return 0
end

function GGLabel:get_font_descent()
	self:_load_font()

	if self.font then
		return self.font:getDescent() / self._font_scale
	end

	return 0
end

function GGLabel:get_font_baseline()
	self:_load_font()

	if self.font then
		return self.font:getBaseline() / self._font_scale
	end

	return 0
end

function GGLabel:get_fitted_font_size()
	return self._fitted_font_size or self.font_size
end

function GGLabel:get_text_width(text)
	self:_load_font()

	if self.font then
		return self.font:getWidth(text) / self._font_scale
	end

	return 0
end

function GGLabel:do_fit_lines(max_lines, start_size, step)
	self.fit_lines = max_lines or self.fit_lines
	self.font_size = start_size or self.font_size
	self.fit_step = step or self.fit_step
	self.font = nil

	self:_fit_text()

	if not self._fitted_font_size then
		return 0, 0
	else
		return self:get_wrap_lines()
	end
end

GGTextLabel = class("GGTextLabel", GGLabel)

function GGTextLabel:initialize(size)
	self.font_name = nil
	self.font_size = nil
	self.text_key = nil
	self.text_shadow = nil
	self.text_shadow_offset = V.v(1, 1)
	self.fit_lines = nil
	self.fit_step = 0.5
	self._font_scale = GGLabel.static.font_scale
	self._ref_h = GGLabel.static.ref_h

	KTextLabel.initialize(self, size)

	if not self.colors.text_shadow then
		self.colors.text_shadow = {0, 0, 0, 255}
	end

	if DEBUG_GG_SHOW_BG then
		self.colors.background = {255, 0, 0, 100}
	end

	if self.text_key then
		self.text = _(self.text_key)
	end

	self._fitted_font = nil
	self._fitted_lines = nil
	self._fitted_text = nil
end

function GGTextLabel:_draw_self()
	self:_load_font()
	self:_fit_text()

	local font_scale = self._font_scale or GGLabel.static.font_scale

	G.setFont(self.font)
	self.font:setLineHeight(self.line_height)

	local pr, pg, pb, pa = G.getColor()
	local voff = (self.font_adj.top or 0) / font_scale

	if self.vertical_align and self.vertical_align ~= "top" then
		local _, tl = self:get_wrap_lines()
		local th = self:get_font_height()
		local des = -1 * self.font:getDescent() / font_scale
		local base = self.font:getBaseline() / font_scale

		if tl > 1 then
			th = th + (tl - 1) * self:get_font_height() * self.font:getLineHeight()
		end

		if self.vertical_align == "middle" then
			voff = math.floor((self.text_size.y - th) * 0.5)
		elseif self.vertical_align == "middle-caps" then
			voff = math.floor((self.text_size.y - th + des) * 0.5)
		elseif self.vertical_align == "bottom" then
			voff = self.text_size.y - th
		elseif self.vertical_align == "bottom-caps" then
			voff = self.text_size.y - th + des
		elseif self.vertical_align == "base" then
			voff = -base
		end

		local vadj = (self.font_adj[self.vertical_align] or 0) / font_scale

		voff = voff + vadj
	end

	if self.text_shadow then
		local tsc = self.colors.text_shadow
		local new_c1, new_c2, new_c3, new_c4 = tsc[1], tsc[2], tsc[3], tsc[4] or 255
		new_c4 = self.alpha * pa / 255 * new_c4

		G.setColor_old(new_c1, new_c2, new_c3, new_c4)

		local sox, soy = self.text_shadow_offset.x, self.text_shadow_offset.y

		G.printf(self.text, self.text_offset.x + sox, self.text_offset.y + soy + voff, self.text_size.x * font_scale, self.text_align, 0, 1 / font_scale)
	end

	if self.colors.text then
		local new_c1, new_c2, new_c3, new_c4 = self.colors.text[1], self.colors.text[2], self.colors.text[3], self.colors.text[4] or 255

		if self.colors.tint then
			local tint_c = self.colors.tint
			new_c1 = new_c1 * tint_c[1]
			new_c2 = new_c2 * tint_c[2]
			new_c3 = new_c3 * tint_c[3]
			new_c4 = new_c4 * tint_c[4]
		end

		new_c4 = new_c4 * self.alpha * pa / 255

		G.setColor_old(new_c1, new_c2, new_c3, new_c4)
	end

	G.printf(self.text, self.text_offset.x, self.text_offset.y + voff, self.text_size.x * font_scale, self.text_align, 0, 1 / font_scale)
	G.setColor(pr, pg, pb, pa)
end

GGShaderLabel = class("GGShaderLabel", GGLabel)

GGShaderLabel:include(KMShaderDraw)

GGButton = class("GGButton", KImageButton)
GGButton.static.serialize_children = false
GGButton.static.label_keys = {
	"label_font_name",
	"label_font_size",
	"label_text_align",
	"label_vertical_align",
	"label_text",
	"label_text_key",
	"label_pos",
	"label_fit_size",
	"label_fit_lines",
	"label_shaders",
	"label_shader_args",
	"label_colors"
}

GGButton:append_serialize_keys(unpack(GGButton.static.label_keys))

function GGButton:initialize(default_image_name, hover_image_name, click_image_name)
	self.on_down_scale = 0.95

	KImageButton.initialize(self, default_image_name, hover_image_name, click_image_name)

	if not self.label_colors then
		self.label_colors = {
			default = {233, 233, 178, 255},
			hover = {246, 228, 132, 255}
		}
	end

	if not self._deserialize_table then
		self.anchor.x, self.anchor.y = self.size.x * 0.5, self.size.y * 0.5
	end

	local rs = GGLabel.static.ref_h / REF_H
	local label = GGShaderLabel:new(self.label_size or self.size)

	label.text = self.label_text_key and _(self.label_text_key) or self.label_text or ""
	label.text_key = self.label_text_key
	label.font_name = self.label_font_name or "button"
	label.font_size = self.label_font_size or 19 * rs
	label.text_align = self.label_text_align or "center"
	label.fit_size = self.label_fit_size
	label.fit_lines = self.label_fit_lines
	label.colors.text = self.label_colors.default
	label.pos = self.label_pos or V.v(0, 18 * rs)
	label.propagate_on_down = true
	label.propagate_on_up = true
	label.propagate_on_click = true
	label.shaders = self.label_shaders or {"p_glow"}
	label.shader_args = self.label_shader_args or {{
		glow_color = {0, 0, 0, 1},
		thickness = 1.8 * rs
	}}
	label.vertical_align = self.label_vertical_align or "top"

	self:add_child(label)

	self.label = label
end

function GGButton:serialize(doing_template)
	for _, n in pairs(GGButton.static.label_keys) do
		if n == "label_colors" then
		-- block empty
		else
			local label_key = string.gsub(n, "label_", "")

			if self.label[label_key] then
				self[n] = self.label[label_key]
			end
		end
	end

	return GGButton.super.serialize(self, doing_template)
end

function GGButton:on_down(button, x, y)
	GGButton.super.on_down(self, button, x, y)

	if self.on_down_scale and not self.original_scale then
		self.original_scale = V.vclone(self.scale)
		self.scale.x, self.scale.y = self.scale.x * self.on_down_scale, self.scale.y * self.on_down_scale
	end
end

function GGButton:on_up(button, x, y)
	GGButton.super.on_up(self, button, x, y)

	if self.on_down_scale and self.original_scale then
		self.scale = self.original_scale
		self.original_scale = nil
	end
end

function GGButton:on_enter(drag_view)
	GGButton.super.on_enter(self, drag_view)

	self.label.colors.text = self.label_colors.hover
	self.label.canvases_drawn = nil
end

function GGButton:on_exit(drag_view)
	GGButton.super.on_exit(self, drag_view)

	self.label.colors.text = self.label_colors.default
	self.label.canvases_drawn = nil

	if self.on_down_scale and self.original_scale then
		self.scale = self.original_scale
		self.original_scale = nil
	end
end

function GGButton:disable(tint, color)
	GGButton.super.disable(self, tint, color)

	self.label.canvases_drawn = nil
end

function GGButton:enable()
	GGButton.super.enable(self)

	self.label.canvases_drawn = nil
end

GG9View = class("GG9View", KView)

GG9View:append_serialize_keys("slice_rect")

GG9View.static.init_arg_names = {"image_name", "size", "slice_rect"}

function GG9View:initialize(image_name, size, slice_rect)
	if not slice_rect then
		log.error("No slice_rect. GG9View not created")

		return nil
	end

	if not size then
		log.error("No size. GG9View not created")

		return nil
	end

	local oss = I:s(image_name)

	if not oss then
		log.error("Image not found %s", image_name)

		return nil
	end

	local ref_scale = oss.ref_scale or 1
	local oim = I:i(oss.atlas)
	local pr, pg, pb, pa = G.getColor()

	G.setColor(1, 1, 1, 1)

	local scx, scy, scw, sch = G.getScissor()
	local imgw, imgh = oss.size[1], oss.size[2]
	local img = G.newCanvas(imgw, imgh)

	G.push()
	G.setScissor()
	G.setCanvas(img)
	G.origin()
	G.draw(oim, oss.quad, oss.trim[1], oss.trim[2], 0, 1, 1, 0, 0)
	G.pop()

	local p1x, p2x = slice_rect.pos.x / ref_scale, (slice_rect.pos.x + slice_rect.size.x) / ref_scale
	local p1y, p2y = slice_rect.pos.y / ref_scale, (slice_rect.pos.y + slice_rect.size.y) / ref_scale
	local tw1, tw2, tw3 = p1x, slice_rect.size.x / ref_scale, imgw - p2x
	local th1, th2, th3 = p1y, slice_rect.size.y / ref_scale, imgh - p2y
	local cwf, chf = (size.x / ref_scale - tw1 - tw3) / tw2, (size.y / ref_scale - th1 - th3) / th2
	local cw, ch = km.round(cwf), km.round(chf)
	local sw, sh = (size.x / ref_scale - tw1 - tw3) / (cw * tw2), (size.y / ref_scale - th1 - th3) / (ch * th2)

	log.debug("GG9View - NEAREST EXACT SIZE: %s,%s --> %s,%s", size.x, size.y, tw1 + tw2 * cw + tw3, th1 + th2 * ch + th3)

	if cw < 1 or ch < 1 then
		log.error("GG9View: specified size %s,%s is smaller than which is possible for the slice_rect:%s,%s,%s,%s", size.x, size.y, slice_rect.pos.x, slice_rect.pos.y, slice_rect.size.x, slice_rect.size.y)

		return nil
	end

	local quads = {{G.newQuad(0, 0, tw1, th1, imgw, imgh), G.newQuad(0, p1y, tw1, th2, imgw, imgh), G.newQuad(0, p2y, tw1, th3, imgw, imgh)}, {G.newQuad(p1x, 0, tw2, th1, imgw, imgh), G.newQuad(p1x, p1y, tw2, th2, imgw, imgh), G.newQuad(p1x, p2y, tw2, th3, imgw, imgh)}, {G.newQuad(p2x, 0, tw3, th1, imgw, imgh), G.newQuad(p2x, p1y, tw3, th2, imgw, imgh), G.newQuad(p2x, p2y, tw3, th3, imgw, imgh)}}
	local canvas = G.newCanvas(size.x / ref_scale, size.y / ref_scale)

	G.push()
	G.setCanvas(canvas)
	G.setScissor()
	G.origin()

	local ox, oy = 0, 0

	for i = 1, cw + 2 do
		for j = 1, ch + 2 do
			local qi = i == 1 and 1 or i == cw + 2 and 3 or 2
			local qj = j == 1 and 1 or j == ch + 2 and 3 or 2

			ox = (i > 1 and tw1 or 0) + (i > 2 and tw2 * (i - 2) or 0) * sw
			oy = (j > 1 and th1 or 0) + (j > 2 and th2 * (j - 2) or 0) * sh

			G.push()
			G.translate(ox, oy)
			G.draw(img, quads[qi][qj], 0, 0, 0, i > 1 and i < cw + 2 and sw or 1, j > 1 and j < ch + 2 and sh or 1)
			G.pop()
		end
	end

	G.pop()
	G.setScissor(scx, scy, scw, sch)
	G.setCanvas()
	G.setColor_old(pr, pg, pb, pa)

	local view_size = V.v(canvas:getDimensions())

	view_size.x, view_size.y = view_size.x * ref_scale, view_size.y * ref_scale

	KView.initialize(self, view_size, canvas)

	self.size = view_size
	self.image_scale = ref_scale
end

GGEllipseText = class("GGEllipseText", KView)
GGEllipseText.static.serialize_children = false

GGEllipseText:append_serialize_keys("text")

GGEllipseText.static.init_arg_names = {"size", "text"}

function GGEllipseText:initialize(size, text)
	GGEllipseText.super.initialize(self, size, nil)

	self.ellipse_w = size.x
	self.ellipse_h = size.y
	self.max_angle = self.max_angle or math.pi * 0.5
	self.text = text

	if self.text_key then
		self.text = _(self.text_key)
	end

	self.colors.text = self.colors.text or {200, 200, 200, 255}
end

function GGEllipseText:redraw()
	self:remove_children()

	self._drawn = true

	if not self.text or self.text == "" then
		return
	end

	local cv = {}
	local count = utf8.len(self.text)
	local color = self.colors.text
	local text_w = 0

	for i = 1, count do
		local l = GGLabel:new()

		self:add_child(l)

		cv[i] = l
		l.text = string.sub(self.text, utf8.offset(self.text, i), utf8.offset(self.text, i + 1) - 1)
		l.font_name = self.font_name
		l.font_size = self.font_size

		l:_load_font()

		l.size.x = l:get_text_width(l.text)
		l.size.y = l:get_font_height()
		l.colors.text = color
		l.anchor.x = l.size.x * 0.5
		l.anchor.y = l.size.y * 2 / 3
		text_w = text_w + l.size.x
	end

	local so_x = (self.ellipse_w - text_w) * 0.5
	local o_x = so_x

	for i = 1, count do
		local l = cv[i]

		l.pos.x = o_x + l.size.x * 0.5
		l.pos.y = math.sin(l.pos.x / self.ellipse_w * math.pi) * self.ellipse_h

		local phase = (l.pos.x - so_x) / text_w

		l.r = -1 * (phase - 0.5) * self.max_angle
		o_x = o_x + l.size.x
	end
end

function GGEllipseText:_draw_self()
	if not self._drawn then
		self:redraw()
	end

	GGEllipseText.super._draw_self(self)
end
