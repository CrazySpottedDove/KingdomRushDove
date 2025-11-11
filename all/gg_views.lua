-- chunkname: @./all/gg_views.lua

local log = require("klua.log"):new("gg_views")

require("klove.kui")

local V = require("klua.vector")
local class = require("middleclass")
local km = require("klua.macros")
local F = require("klove.font_db")
local G = love.graphics
local I = require("klove.image_db")
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
		self.colors.text_shadow = {
			0,
			0,
			0,
			255
		}
	end

	if DEBUG_GG_SHOW_BG then
		self.colors.background = {
			255,
			0,
			0,
			100
		}
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

	if fit_lines and fit_lines > 1 and self.text and not table.contains({
		"ja",
		"zh-Hans",
		"zh-Hant"
	}, i18n.current_locale) then
		local spacers = {
			" ",
			",",
			"\n",
			utf8.char(65292),
			utf8.char(12290)
		}

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
			local w, lines = self:get_wrap_lines()
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

	if self.font then
		G.setFont(self.font)
		self.font:setLineHeight(self.line_height)
	end

	local pr, pg, pb, pa = G.getColor()
	local voff = (self.font_adj.top or 0) / font_scale

	if self.vertical_align and self.vertical_align ~= "top" then
		local tw, tl = self:get_wrap_lines()
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
		local new_c = {
			tsc[1],
			tsc[2],
			tsc[3],
			tsc[4]
		}

		if not new_c[4] then
			new_c[4] = 255
		end

		new_c[4] = self.alpha * pa / 255 * new_c[4]

		G.setColor_old(new_c)

		local sox, soy = self.text_shadow_offset.x, self.text_shadow_offset.y

		G.printf(self.text, self.text_offset.x + sox, self.text_offset.y + soy + voff, self.text_size.x * font_scale, self.text_align, 0, 1 / font_scale)
	end

	if self.colors.text then
		local new_c = {
			self.colors.text[1],
			self.colors.text[2],
			self.colors.text[3],
			self.colors.text[4]
		}

		if not new_c[4] then
			new_c[4] = 255
		end

		if self.colors.tint then
			local tint_c = self.colors.tint

			new_c[1] = new_c[1] * tint_c[1] / 255
			new_c[2] = new_c[2] * tint_c[2] / 255
			new_c[3] = new_c[3] * tint_c[3] / 255
			new_c[4] = new_c[4] * tint_c[4] / 255
		end

		new_c[4] = self.alpha * pa / 255 * new_c[4]

		G.setColor_old(new_c)
	end

	G.printf(self.text, self.text_offset.x, self.text_offset.y + voff, self.text_size.x * font_scale, self.text_align, 0, 1 / font_scale)
	G.setColor_old(pr, pg, pb, pa)
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
			default = {
				233,
				233,
				178,
				255
			},
			hover = {
				246,
				228,
				132,
				255
			}
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
	label.shaders = self.label_shaders or {
		"p_glow"
	}
	label.shader_args = self.label_shader_args or {
		{
			glow_color = {
				0,
				0,
				0,
				1
			},
			thickness = 1.8 * rs
		}
	}
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

GGImageButton = class("GGImageButton", GGLabel)

GGImageButton:append_serialize_keys("default_image_name", "hover_image_name", "click_image_name", "down_scale")

GGImageButton.static.init_arg_names = {
	"default_image_name",
	"hover_image_name",
	"click_image_name"
}

function GGImageButton:initialize(default_image_name, hover_image_name, click_image_name)
	log.paranoid("GGImageButton:initialize %s", self.id)

	self.highlighted = false
	self.default_image_name = default_image_name
	self.hover_image_name = hover_image_name or default_image_name
	self.click_image_name = click_image_name or hover_image_name or default_image_name
	self.down_scale = nil

	GGLabel.initialize(self, nil, default_image_name)
end

function GGImageButton:on_enter(drag_view)
	log.paranoid("GGImageButton:on_enter %s", self.id)

	if self.image_name == self.click_image_name then
		return
	end

	self:set_image(self.hover_image_name)
end

function GGImageButton:on_exit(drag_view)
	log.paranoid("GGImageButton:on_exit %s", self.id)
	self:set_image(self.default_image_name)

	if self.down_scale then
		self.scale.x, self.scale.y = 1, 1
	end
end

function GGImageButton:on_down(button, x, y)
	log.paranoid("GGImageButton:on_down %s", self.id)
	self:set_image(self.click_image_name)

	if self.down_scale then
		self.scale.x, self.scale.y = self.down_scale, self.down_scale
	end
end

function GGImageButton:on_up(button, x, y)
	log.paranoid("GGImageButton:on_up %s", self.id)
	self:set_image(self.hover_image_name)

	if self.down_scale then
		self.scale.x, self.scale.y = 1, 1
	end
end

function GGImageButton:on_focus()
	log.paranoid("GGImageButton:on_focus %s", self.id)
	self:on_enter()
end

function GGImageButton:on_defocus()
	log.paranoid("GGImageButton:on_defocus %s", self.id)
	self:on_exit()
end

GGToggleButton = class("GGToggleButton", GGLabel)

GGToggleButton:append_serialize_keys("true_image_name", "false_image_name", "down_scale")

GGToggleButton.static.init_arg_names = {
	"true_image_name",
	"false_image_name"
}

function GGToggleButton:initialize(true_image_name, false_image_name)
	self.value = true
	self.true_image_name = true_image_name
	self.false_image_name = false_image_name
	self.down_scale = nil

	GGLabel.initialize(self, nil, true_image_name)

	self.propagate_on_up = false
	self.propagate_on_down = false
	self.propagate_on_click = false
	self.propagate_on_touch_down = false
	self.propagate_on_touch_up = false
	self.propagate_on_touch_move = false
end

function GGToggleButton:on_down(button, x, y)
	self:set_value(not self.value)

	if self.down_scale then
		self.scale.x, self.scale.y = self.down_scale, self.down_scale
	end
end

function GGToggleButton:on_up(button, x, y)
	if self.down_scale then
		self.scale.x, self.scale.y = 1, 1
	end
end

function GGToggleButton:on_exit(drag_view)
	if self.down_scale then
		self.scale.x, self.scale.y = 1, 1
	end
end

function GGToggleButton:set_value(value)
	self.value = value

	if value then
		self:set_image(self.true_image_name)
	else
		self:set_image(self.false_image_name)
	end

	if self.on_change then
		self:on_change(value)
	end
end

GG9View = class("GG9View", KView)

GG9View:append_serialize_keys("slice_rect")

GG9View.static.init_arg_names = {
	"image_name",
	"size",
	"slice_rect"
}

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

	local quads = {
		{
			G.newQuad(0, 0, tw1, th1, imgw, imgh),
			G.newQuad(0, p1y, tw1, th2, imgw, imgh),
			G.newQuad(0, p2y, tw1, th3, imgw, imgh)
		},
		{
			G.newQuad(p1x, 0, tw2, th1, imgw, imgh),
			G.newQuad(p1x, p1y, tw2, th2, imgw, imgh),
			G.newQuad(p1x, p2y, tw2, th3, imgw, imgh)
		},
		{
			G.newQuad(p2x, 0, tw3, th1, imgw, imgh),
			G.newQuad(p2x, p1y, tw3, th2, imgw, imgh),
			G.newQuad(p2x, p2y, tw3, th3, imgw, imgh)
		}
	}
	local canvas = G.newCanvas(size.x / ref_scale, size.y / ref_scale)

	G.push()
	G.setCanvas(canvas)
	G.setScissor()
	G.origin()

	local ox, oy, lw, lh = 0, 0, 0, 0

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

GG9SlicesView = class("GG9SlicesView", KView)

GG9SlicesView:append_serialize_keys("slices_prefix", "direction")

GG9SlicesView.static.init_arg_names = {
	"size",
	"slices_prefix",
	"direction"
}
GG9SlicesView.static.image_suffixes = {
	"lt",
	"ct",
	"rt",
	"lc",
	"cc",
	"rc",
	"lb",
	"cb",
	"rb"
}
GG9SlicesView.static.image_suffixes_miss_map = {
	rt = {
		"lt",
		-1,
		1
	},
	rc = {
		"lc",
		-1,
		1
	},
	lb = {
		"lt",
		1,
		-1
	},
	cb = {
		"ct",
		1,
		-1
	},
	rb = {
		"lt",
		-1,
		-1
	}
}

function GG9SlicesView:initialize(size, slices_prefix, direction)
	if not slices_prefix or type(slices_prefix) ~= "string" then
		log.error("No slices_prefix or not a string. View not created")

		return nil
	end

	if not size then
		log.error("No size. View not created")

		return nil
	end

	local i1 = I:s(slices_prefix .. "_lt")
	local i2 = I:s(slices_prefix .. (direction == "v" and "_lc" or direction == "h" and "_ct" or "_cc"))
	local i3 = I:s(slices_prefix .. (direction == "v" and "_lb" or direction == "h" and "_rt" or "_rb"), true)

	i3 = i3 or i1

	if not i1 or not i2 or not i3 then
		log.error("On or more slices with prefix %s not found in database", slices_prefix)

		return nil
	end

	local ref_scale = i1.ref_scale or 1
	local mid_count_x, mid_count_y = 0, 0

	if size.x / ref_scale > i1.size[1] + i3.size[1] then
		mid_count_x = math.ceil((size.x / ref_scale - (i1.size[1] + i3.size[1])) / i2.size[1])
	end

	if size.y / ref_scale > i1.size[2] + i3.size[2] then
		mid_count_y = math.ceil((size.y / ref_scale - (i1.size[2] + i3.size[2])) / i2.size[2])
	end

	local count_x, count_y = mid_count_x + 2, mid_count_y + 2
	local cw = i1.size[1] + i3.size[1] + mid_count_x * i2.size[1]
	local ch = i1.size[2] + i3.size[2] + mid_count_y * i2.size[2]

	if direction == "v" then
		cw = i1.size[1]
		count_x = 1
	elseif direction == "h" then
		ch = i1.size[2]
		count_y = 1
	end

	local canvas = G.newCanvas(cw, ch)
	local pr, pg, pb, pa = G.getColor()

	G.setColor(1, 1, 1, 1)

	local scx, scy, scw, sch = G.getScissor()

	G.push()
	G.setCanvas(canvas)
	G.setScissor()
	G.origin()

	local suff = GG9SlicesView.static.image_suffixes
	local miss_suff = GG9SlicesView.static.image_suffixes_miss_map
	local lw, lh = 0, 0
	local ox, oy = 0, 0

	for i = 1, count_x do
		local si = i == 1 and 1 or i == count_x and 3 or 2

		oy = 0

		for j = 1, count_y do
			local sj = j == 1 and 0 or j == count_y and 6 or 3
			local sox, soy, scale_x, scale_y = 0, 0, 1, 1
			local sn = slices_prefix .. "_" .. suff[si + sj]
			local iss = I:s(sn, true)

			if not iss then
				local ms = miss_suff[suff[si + sj]]

				sn = slices_prefix .. "_" .. ms[1]
				iss = I:s(sn)

				if not iss then
					log.error("Could not find slice image %s with suffix %s", slices_prefix, ms[1])

					return nil
				end

				scale_x, scale_y = ms[2], ms[3]
				sox, soy = scale_x == -1 and iss.size[1] or 0, scale_y == -1 and iss.size[2] or 0
			end

			local ti = I:i(iss.atlas)

			lw, lh = iss.size[1], iss.size[2]

			G.push()
			G.translate(ox, oy)
			G.draw(ti, iss.quad, iss.trim[1] * scale_x, iss.trim[2] * scale_y, 0, scale_x, scale_y, sox, soy)
			G.pop()

			oy = oy + lh
		end

		ox = ox + lw
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

GGLayout = class("GGLayout", KView)

GGLayout:append_serialize_keys("layout", "space")

GGLayout.static.init_arg_names = {
	"size",
	"layout",
	"space"
}

function GGLayout:initialize(size, layout, space)
	GGLayout.super.initialize(self, size)

	self.layout = layout or "top"
	self.space = space or 0

	self:update_layout()

	self.propagate_on_up = true
	self.propagate_on_down = true
	self.propagate_on_click = true
end

function GGLayout:update_layout()
	local x, y = 0, 0

	if self.layout == "top" then
		x, y = 0, 0

		for _, c in pairs(self.children) do
			if c:isInstanceOf(GGLabel) then
				c.size.x = self.size.x
				c.text_size.x = self.size.x

				c:_load_font()
				c:_fit_text()

				local w, l = c:get_wrap_lines()

				c.size.y = l * c:get_font_height() * c.line_height
				c.text_size.y = c.size.y
			end

			c.pos.y = y
			y = y + c.size.y + self.space
		end
	end
end

GGEllipseText = class("GGEllipseText", KView)
GGEllipseText.static.serialize_children = false

GGEllipseText:append_serialize_keys("text")

GGEllipseText.static.init_arg_names = {
	"size",
	"text"
}

function GGEllipseText:initialize(size, text)
	GGEllipseText.super.initialize(self, size, nil)

	self.ellipse_w = size.x
	self.ellipse_h = size.y
	self.max_angle = self.max_angle or math.pi * 0.5
	self.text = text

	if self.text_key then
		self.text = _(self.text_key)
	end

	self.colors.text = self.colors.text or {
		200,
		200,
		200,
		255
	}
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
		local o = utf8.offset(self.text, i)
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
