-- chunkname: @./lib/klove/kui.lua

local log = require("klua.log"):new("kui")

require("klua.table")

local km = require("klua.macros")
local V = require("klua.vector")
local I = require("klove.image_db")
local F = require("klove.font_db")
local SH = require("klove.shader_db")
local class = require("middleclass")
local G = love.graphics
local _last_id = 99000
local KUI_FPS = 30

M_DOWN = "mouse_down"
M_UP = "mouse_up"
M_SCROLL = "mouse_scroll"
M_ENTER = "mouse_enter"
M_DRAG_ENTER = "mouse_drag_enter"

local function vround(x, y)
	return math.floor(0.5 + x), math.floor(0.5 + y)
end

KMDragInertia = {}

function KMDragInertia:included(klass)
	if klass.initialize then
		klass._kmdi_initialize = klass.initialize
	end

	if klass.update then
		klass._kmdi_update = klass.update
	end

	if klass.on_down then
		klass._kmdi_on_down = klass.on_down
	end

	if klass.on_dropped then
		klass._kmdi_on_droppped = klass.on_droppped
	end

	klass.initialize = klass.kmdi_initialize
	klass.update = klass.kmdi_update
	klass.on_down = klass.kmdi_on_down
	klass.on_dropped = klass.kmdi_on_dropped

	table.insert(klass.static.serialize_keys, "inertia_damping")
end

function KMDragInertia:kmdi_initialize(...)
	if self._kmdi_initialize then
		self._kmdi_initialize(self, ...)
	end

	self._inertia_v = V.v(0, 0)
	self._inertia_idx = 1
	self._inertia_deltas = {
		V.v(0, 0),
		V.v(0, 0),
		V.v(0, 0)
	}
	self._inertia_last_pos = V.v()
	self.can_drag = true
	self.inertia_damping = 0.9
end

function KMDragInertia:kmdi_update(dt)
	if self._kmdi_update then
		self._kmdi_update(self, dt)
	end

	if self.hidden then
		return
	end

	if love.mouse.isDown(1) then
		self._inertia_idx = km.zmod(self._inertia_idx + 1, #self._inertia_deltas)

		local idelta = self._inertia_deltas[self._inertia_idx]

		idelta.x, idelta.y = (self.pos.x - self._inertia_last_pos.x) / dt, (self.pos.y - self._inertia_last_pos.y) / dt
		self._inertia_last_pos.x = self.pos.x
		self._inertia_last_pos.y = self.pos.y
	else
		if self._inertia_done then
			return
		end

		local lx, ly = self.pos.x, self.pos.y

		self.pos.x = self.pos.x + self._inertia_v.x * dt
		self.pos.y = self.pos.y + self._inertia_v.y * dt
		self._inertia_v.x = self._inertia_v.x * self.inertia_damping
		self._inertia_v.y = self._inertia_v.y * self.inertia_damping

		if self.drag_limits then
			local dl = self.drag_limits

			self.pos.x = km.clamp(dl.pos.x, dl.pos.x + dl.size.x, self.pos.x)
			self.pos.y = km.clamp(dl.pos.y, dl.pos.y + dl.size.y, self.pos.y)
		end

		if math.abs(self.pos.x - lx) < 1 and math.abs(self.pos.y - ly) < 1 then
			self._inertia_done = true
		end
	end
end

function KMDragInertia:kmdi_on_down(...)
	if self._kmdi_on_down then
		self._kmdi_on_down(self, ...)
	end

	for i = 1, #self._inertia_deltas do
		local d = self._inertia_deltas[i]

		d.x, d.y = 0, 0
		self._inertia_v.x = 0
		self._inertia_v.y = 0
	end

	self._inertia_last_pos.x = self.pos.x
	self._inertia_last_pos.y = self.pos.y
end

function KMDragInertia:kmdi_on_dropped(...)
	if self._kmdi_on_dropped then
		self._kmdi_on_dropped(self, ...)
	end

	if self.inertia_damping then
		local vx, vy = 0, 0
		local steps = #self._inertia_deltas

		for i = 1, steps do
			local p = self._inertia_deltas[i]

			vx = vx + p.x / steps
			vy = vy + p.y / steps
		end

		if math.abs(vx) > 1 or math.abs(vy) > 1 then
			self._inertia_done = nil
			self._inertia_v.x = vx
			self._inertia_v.y = vy
		end
	end
end

KMOverrides = {}

function KMOverrides:included(klass)
	table.insert(klass.static.serialize_keys, "overrides")
end

function KMOverrides:apply_override(o_key)
	local function apply_data(this, data)
		for k, v in pairs(data) do
			if type(v) == "table" and type(this[k]) == "table" then
				apply_data(this[k], v)
			else
				this[k] = v
			end
		end
	end

	if not self.overrides or not self.overrides[o_key] then
		return
	end

	local ov = self.overrides[key]

	apply_data(self, ov)

	self.overrides.active = o_key
end

KMShaderDraw = {}

function KMShaderDraw:redraw()
	self.canvases_drawn = nil
	self.canvases = nil

	if self.font then
		self.font = nil
	end
end

function KMShaderDraw:shader_draw()
	if self.text and self.text ~= self._last_text then
		self:redraw()

		self._last_text = self.text
	end

	local ss = self._font_scale or self.class.font_scale or 1
	local m = math.ceil((self.shader_margin or 0.2 * self.size.y) * ss)

	if not self.canvases then
		self.canvases = {}

		local cw, ch = math.ceil(self.size.x * ss + 2 * m), math.ceil(self.size.y * ss + 2 * m)

		self.canvases[1] = G.newCanvas(cw, ch)

		if self.shaders then
			for i = 1, #self.shaders do
				self.canvases[i + 1] = G.newCanvas(cw, ch)
			end
		end
	end

	if not self.canvases_drawn then
		self.canvases_drawn = true

		local pr, pg, pb, pa = G.getColor()

		G.setColor(1, 1, 1, 1)

		local scx, scy, scw, sch = G.getScissor()

		G.push()
		G.setCanvas(self.canvases[1])
		G.setScissor()
		G.origin()
		G.translate(m, m)
		G.scale(ss)

		local clear_color = self.colors.text or self.colors.background

		if clear_color then
			local r, g, b = unpack(clear_color)

			G.clear(r, g, b, 0)
		else
			G.clear()
		end

		self:_draw_self_original()
		G.setCanvas()
		G.pop()

		if self.shaders then
			local b = G.getBlendMode()

			G.setBlendMode("alpha", "premultiplied")

			for i = 1, #self.shaders do
				local sh = self.shaders and SH:get(self.shaders[i]) or nil
				local in_ca = self.canvases[i]
				local out_ca = self.canvases[i + 1]

				G.push()
				G.setScissor()
				G.setCanvas(out_ca)
				G.clear()
				G.origin()

				if not sh then
					log.warning("error loading shader:%s falling back to p_none", self.shaders[i])

					sh = SH:get("p_none")

					G.setShader(sh)
				else
					G.setShader(sh)

					if self.shader_args and self.shader_args[i] then
						sh:send("c_ss", ss)
						sh:send("c_size", {
							out_ca:getDimensions()
						})

						for k, v in pairs(self.shader_args[i]) do
							sh:send(k, v)
						end
					end
				end

				G.draw(in_ca)
				G.setShader()
				G.setCanvas()
				G.pop()
			end

			G.setBlendMode(b)
		end

		G.setScissor(scx, scy, scw, sch)
		G.setColor_old(pr, pg, pb, pa)
	end

	G.draw(self.canvases[#self.canvases], -m / ss, -m / ss, 0, 1 / ss)
end

function KMShaderDraw:included(klass)
	if klass._draw_self then
		klass._draw_self_original = klass._draw_self
		klass._draw_self = klass.shader_draw
	end

	table.insert(klass.static.serialize_keys, "shaders")
	table.insert(klass.static.serialize_keys, "shader_args")
	table.insert(klass.static.serialize_keys, "shader_margin")
end

KObject = class("KObject")
KObject.static.serialize_keys = {
	"id"
}
KObject.static.serialize_children = true
KObject.static.init_arg_names = {}

function KObject.static:append_serialize_keys(...)
	local new_keys = {
		...
	}

	if self.super and self.super.serialize_keys then
		self.serialize_keys = table.append(new_keys, self.super.serialize_keys)
	else
		self.serialize_keys = new_keys
	end
end

function KObject.static:get_init_args(t)
	local function nil_unpack(tt, i, maxi)
		i = i or 1

		if i == maxi then
			return tt[i]
		elseif i < maxi then
			return tt[i], nil_unpack(tt, i + 1, maxi)
		end
	end

	local args = {}

	for i, n in ipairs(self.static.init_arg_names) do
		args[i] = t[n]
	end

	return nil_unpack(args, 1, #self.static.init_arg_names)
end

function KObject.static:new_from_table(t)
	local v = self:allocate()

	v._deserialize_table = t

	v:initialize(v.class:get_init_args(t))

	v._deserialize_table = nil

	return v
end

function KObject:initialize()
	_last_id = _last_id + 1
	self.id = tostring(_last_id)
	self.children = {}
	self.parent = nil

	self:deserialize()
end

function KObject:deserialize()
	local t = self._deserialize_table

	if not t then
		return
	end

	for k, v in pairs(t) do
		if k == "children" then
			for _, ct in pairs(v) do
				local klass_name = ct.class

				if not klass_name then
					log.error("class param not found for %s", getdump(ct))
				else
					local klass = _G[klass_name]

					if not klass then
						log.error("class not found %s", klass_name)
					else
						local c = klass:new_from_table(ct)

						self:add_child(c)
					end
				end
			end
		elseif k == "class" then
			-- block empty
		elseif type(v) == "table" then
			if not self[k] then
				self[k] = {}
			end

			table.deepmerge(self[k], v)
		else
			self[k] = v
		end
	end
end

function KObject:serialize(doing_template)
	local out = {}
	local doing_template_instance = self.template_name and not doing_template

	if doing_template_instance then
		local out_t = self:serialize(true)

		out._template_table = out_t
	end

	out.class = self.class.name

	local keys = doing_template_instance and self.class.static.instance_keys or self.class.static.serialize_keys

	for _, k in pairs(keys) do
		local v = self[k]

		if type(v) == "table" then
			out[k] = table.deepclone(v)
		else
			out[k] = v
		end
	end

	if not doing_template_instance and self.class.static.serialize_children and self.children and #self.children > 0 then
		local children = {}

		for _, c in pairs(self.children) do
			if not c.ephemeral then
				table.insert(children, c:serialize())
			end
		end

		out.children = children
	end

	return out
end

function KObject:add_child(c, idx)
	c.parent = self

	if idx then
		table.insert(self.children, idx, c)
	else
		table.insert(self.children, c)
	end
end

function KObject:remove_child(c)
	if not c then
		log.error("Removing nil child from %s", self)

		return
	end

	table.removeobject(self.children, c)

	c.parent = nil
end

function KObject:remove_children()
	for i = #self.children, 1, -1 do
		self:remove_child(self.children[i])
	end
end

function KObject:remove_from_parent()
	if self.parent ~= nil then
		self.parent:remove_child(self)
	end
end

function KObject:is_child_of(ancestor)
	if self.parent == nil then
		return false
	elseif self.parent == ancestor then
		return true
	else
		return self.parent:is_child_of(ancestor)
	end
end

function KObject:get_order()
	if not self.parent then
		return nil
	end

	for i = 1, #self.parent.children do
		if self.parent.children[i] == self then
			return i
		end
	end

	return nil
end

function KObject:order_to_front()
	if self.parent then
		local p = self.parent

		p:remove_child(self)
		p:add_child(self)
	end
end

function KObject:order_to_back()
	if self.parent and #self.parent.children > 1 then
		self:order_below(self.parent.children[1])
	end
end

function KObject:order_above(c)
	local p = self.parent

	if not p or c.parent ~= p then
		return
	end

	p:remove_child(self)

	local idx = c:get_order()

	if idx then
		p:add_child(self, idx + 1)
	end
end

function KObject:order_below(c)
	local p = self.parent

	if not p or c.parent ~= p then
		return
	end

	p:remove_child(self)

	local idx = c:get_order()

	if idx then
		p:add_child(self, idx)
	end
end

function KObject:clone()
	local o = table.deepclone(self)

	return o
end

function KObject:flatten(filter, trim_filter)
	local o = {}

	if trim_filter and not trim_filter(self) then
		return o
	end

	if not filter or filter(self) then
		table.insert(o, self)
	end

	if self.children and #self.children > 0 then
		for _, cc in pairs(self.children) do
			local l = cc:flatten(filter, trim_filter)

			if l and #l > 0 then
				table.append(o, l)
			end
		end
	end

	return o
end

KView = class("KView", KObject)

KView:append_serialize_keys("pos", "size", "padding", "anchor", "scale", "r", "hit_rect", "clip", "alpha", "disabled_tint_color", "colors", "image_scale", "image_name", "image_offset", "focus_nav_offset", "focus_nav_dir", "animation")

KView.static.serialize_children = true
KView.static.init_arg_names = {
	"size"
}

function KView:initialize(size, image_name, image_scale)
	self.pos = V.v(0, 0)
	self.size = V.v(0, 0)
	self.padding = V.v(0, 0)
	self.anchor = V.v(0, 0)
	self.scale = V.v(1, 1)
	self.r = 0
	self.hidden = false
	self.can_drag = false
	self.clip = false
	self.clip_view = nil
	self.alpha = 1
	self.disabled_tint_color = {
		150,
		150,
		150,
		255
	}
	self.hit_rect = nil
	self.focus_order = 0
	self.focus_nav_dir = nil
	self.focus_nav_offset = nil
	self.focus_nav_ignore = nil
	self.focus_nav_override = nil
	self.propagate_on_up = false
	self.propagate_on_down = false
	self.propagate_on_click = false
	self.propagate_on_drop = true
	self.propagate_on_scroll = true
	self.propagate_on_enter = true
	self.propagate_drag = true
	self.propagate_on_touch_down = true
	self.propagate_on_touch_up = true
	self.propagate_on_touch_move = true
	self.scroll_origin_y = 0
	self.colors = {}
	self.image_scale = image_scale or 1
	self.image_offset = nil
	self.animation = nil
	self.ts = 0
	self._disabled = false
	self._focused = false

	self:set_image(image_name, size)
	KView.super.initialize(self)
end

function KView:deserialize()
	local t = self._deserialize_table

	if not t then
		return
	end

	t.image_name = nil

	KView.super.deserialize(self)
end

function KView:set_image(image, size)
	local w, h = 0, 0

	if image and type(image) == "userdata" then
		self.image = image

		if size then
			w, h = size.x, size.y
		else
			w, h = self.image:getDimensions()
		end
	elseif image and type(image) == "string" then
		self.image_name = image

		local ss = I:s(image)

		if not ss then
			log.error("Image %s not found in database", image)
		end

		self.image_ss = ss
		self.image = I:i(ss.atlas)

		local ref_scale = (ss.ref_scale or 1) * self.image_scale

		if size then
			w, h = size.x, size.y
		else
			w, h = ss.size[1] * ref_scale, ss.size[2] * ref_scale
		end
	elseif size then
		w, h = size.x, size.y
	end

	self.size.x, self.size.y = w, h
end

function KView:destroy()
	for i = #self.children, 1, -1 do
		self.children[i]:destroy()
	end

	self.children = nil
	self.parent = nil
	self.image = nil
	self.image_ss = nil
	self.colors = nil
	self.on_click = nil
	self.on_down = nil
	self.on_up = nil
	self.on_drop = nil
	self.on_scroll = nil
	self.on_enter = nil
	self.hit_rect = nil

	for k, v in pairs(self) do
		if v and type(v) == "table" and v.isInstanceOf and v:isInstanceOf(klass) then
			self[k] = nil
		end
	end
end

function KView:update(dt)
	if not self.animation or not self.animation.paused then
		self.ts = self.ts + dt
	end

	for _, c in pairs(self.children) do
		c:update(dt)
	end
end

function KView:draw()
	if self.hidden then
		return
	end

	local pr, pg, pb, pa = G.getColor()
	local current_alpha = pa * self.alpha

	G.setColor_old({
		255,
		255,
		255,
		current_alpha
	})
	G.push()
	G.scale(self.scale.x, self.scale.y)
	G.rotate(-self.r)
	G.translate(-self.anchor.x, -self.anchor.y)

	if self.clip then
		local this = self

		if self.clip_fn then
			self._stencil_fn = self.clip_fn
		else
			function self._stencil_fn()
				G.rectangle("fill", 0, 0, this.size.x, this.size.y)
			end
		end

		G.stencil(self._stencil_fn)
		G.setStencilTest("greater", 0)
	end

	self:_draw_self()

	if self.scroll_origin_y then
		G.push()
		G.translate(0, self.scroll_origin_y)
	end

	self:_draw_children()

	if self.scroll_origin_y then
		G.pop()
	end

	if self.clip then
		G.setStencilTest()
	end

	if self._focused then
		if self.draw_focus then
			self:draw_focus()
		end

		if self.colors.focused_outline then
			G.setColor_old(self.colors.focused_outline)
			G.rectangle("line", -1, -1, self.size.x + 1, self.size.y + 1)
		end
	end

	G.pop()
	G.setColor_old(pr, pg, pb, pa)
end

function KView:_draw_self()
	local pr, pg, pb, pa = G.getColor()
	local current_alpha = pa / 255

	if self.colors.background then
		local new_c = {
			self.colors.background[1],
			self.colors.background[2],
			self.colors.background[3],
			self.colors.background[4] * current_alpha
		}

		G.setColor_old(new_c)

		if self.shape then
			local fn = G[self.shape.name]

			if fn then
				fn(unpack(self.shape.args))
			else
				log.error("shape %s was not found in love.graphics", self.shape.name)
			end
		else
			G.rectangle("fill", 0, 0, self.size.x, self.size.y)
		end
	end

	if self.colors.tint then
		local tint = self.colors.tint

		G.setColor_old({
			tint[1],
			tint[2],
			tint[3],
			tint[4] * current_alpha
		})
	end

	if self.animation then
		local fn, runs = self:animation_frame(self.animation, self.ts, self.loop, self.fps)

		self.image_ss = I:s(fn)
		self.image = I:i(self.image_ss.atlas)

		if self.animation.hide_at_end and runs >= 1 then
			self.hidden = true
		end
	end

	if self.image_offset then
		G.push()
		G.translate(self.image_offset.x, self.image_offset.y)
	end

	if self.image_ss then
		local ss = self.image_ss
		local ref_scale = (ss.ref_scale or 1) * self.image_scale

		G.draw(self.image, ss.quad, ss.trim[1] * ref_scale, ss.trim[2] * ref_scale, 0, ref_scale)
	elseif self.image then
		local iw, ih = self.image:getDimensions()
		local ix = (self.size.x - iw * self.image_scale) * 0.5
		local iy = (self.size.y - ih * self.image_scale) * 0.5

		G.draw(self.image, ix, iy, 0, self.image_scale, self.image_scale)
	end

	if DEBUG_KUI_DRAW_FOCUS_NAV and self.on_keypressed then
		G.setColor(0, 0, 1, 1)

		local x, y = 0, 0

		if self.focus_nav_offset then
			x, y = self.focus_nav_offset.x, self.focus_nav_offset.y
		elseif self.anchor then
			x, y = self.anchor.x, self.anchor.y
		end

		G.rectangle("fill", x - 2, y - 2, 4, 4)
	end

	if self.image_offset then
		G.pop()
	end

	G.setColor_old(pr, pg, pb, pa)
end

function KView:_draw_children()
	local clip_x, clip_y, clip_xw, clip_yh
	local cv = self.clip_view

	if cv then
		clip_x, clip_y = self.clip_view:view_to_view(0, 0, self)
		clip_xw, clip_yh = self.clip_view:view_to_view(cv.size.x, cv.size.y, self)
	end

	G.push()
	G.translate(self.padding.x, self.padding.y)

	for _, c in pairs(self.children) do
		if clip_x ~= nil and (clip_xw < c.pos.x or clip_x > c.pos.x + c.size.x or clip_yh < c.pos.y or clip_y > c.pos.y + c.size.y) then
			-- block empty
		else
			G.push()
			G.translate(c.pos.x, c.pos.y)
			c:draw()
			G.pop()
		end
	end

	G.pop()
end

function KView:animation_frame(animation, time_offset, loop, fps)
	local a = animation

	fps = fps or animation.fps or KUI_FPS

	local frames = a.frames

	if not frames then
		frames = {}

		if a.pre then
			table.append(frames, a.pre)
		end

		if not a.from then
			a.from = 1
		end

		if a.from and a.to then
			local inc = a.from > a.to and -1 or 1

			for i = a.from, a.to, inc do
				table.insert(frames, i)
			end
		end

		if a.post then
			table.append(frames, a.post)
		end

		a.frames = frames
	end

	local len = #frames
	local elapsed = math.ceil(time_offset * fps)
	local runs = math.floor(elapsed / len)
	local idx

	if loop then
		idx = km.zmod(elapsed, len)
	else
		idx = km.clamp(1, len, elapsed)
	end

	local frame = frames[idx]

	return string.format("%s_%04i", a.prefix, frame), runs
end

function KView:hit_all(x, y, filter)
	local hits = {}

	if self._disabled then
		return hits
	end

	if self.clip and (x < 0 or x > self.size.x or y < 0 or y > self.size.y) then
		return hits
	end

	for i = #self.children, 1, -1 do
		local c = self.children[i]

		if c.hidden or c._disabled then
			-- block empty
		else
			local cx = (x - c.pos.x + c.anchor.x * c.scale.x) / c.scale.x
			local cy = (y - c.pos.y + c.anchor.y * c.scale.y - self.scroll_origin_y) / c.scale.y
			local c_hits = c:hit_all(cx, cy, filter)

			table.append(hits, c_hits)
		end
	end

	local hr = self.hit_rect

	if not self.hidden and not self._disabled and (hr and x >= hr.pos.x and x <= hr.pos.x + hr.size.x and y >= hr.pos.y and y <= hr.pos.y + hr.size.y or not hr and x >= 0 and x <= self.size.x and y >= 0 and y <= self.size.y) and (filter == nil or filter(self)) then
		table.insert(hits, self)
	end

	return hits
end

function KView:hit_topmost(x, y, filter)
	local result = self:hit_all(x, y, filter)

	if #result > 0 then
		return result[1]
	else
		return nil
	end
end

function KView:screen_to_view(x, y)
	local ox, oy = 0, 0
	local this = self
	local view_list = {}

	repeat
		table.insert(view_list, this)

		this = this.parent
	until not this

	for i = #view_list, 1, -1 do
		local v = view_list[i]

		x = (x - v.pos.x) / v.scale.x + v.anchor.x
		y = (y - v.pos.y) / v.scale.y + v.anchor.y

		if v.parent and v.parent:isInstanceOf(KScrollList) then
			y = y + v.scroll_origin_y / v.scale.y
		end
	end

	return vround(x, y)
end

function KView:view_to_screen(x, y)
	local ox, oy = 0, 0
	local this = self

	repeat
		x = (x - this.anchor.x) * this.scale.x + this.pos.x
		y = (y - this.anchor.y) * this.scale.y + this.pos.y

		if this.parent and this.parent:isInstanceOf(KScrollList) then
			y = y - this.scroll_origin_y
		end

		this = this.parent
	until not this

	return vround(x, y)
end

function KView:view_to_view(x, y, dest_view)
	local ix, iy = self:view_to_screen(x, y)

	return dest_view:screen_to_view(ix, iy)
end

function KView:get_window()
	local this = self

	while this do
		if this:isInstanceOf(KWindow) then
			return this
		else
			this = this.parent
		end
	end

	return nil
end

function KView:get_child_by_id(id)
	if self.id == id then
		return self
	else
		for _, c in ipairs(self.children) do
			local found = c:get_child_by_id(id)

			if found then
				return found
			end
		end
	end

	return nil
end

KView.ci = KView.get_child_by_id

function KView:disable(tint, color)
	self._disabled = true

	if tint == nil or tint == true then
		self:apply_disabled_tint(color)
	end
end

function KView:enable(untint)
	self._disabled = false

	if untint == nil or untint == true then
		self:remove_disabled_tint()
	end
end

function KView:is_disabled()
	return self._disabled == true
end

function KView:focus()
	local w = self:get_window()

	if w then
		w:focus_view(self)
	end
end

function KView:defocus()
	local w = self:get_window()

	if w then
		w:focus_view(nil)
	end
end

function KView:is_focused()
	return self._focused == true
end

function KView:apply_disabled_tint(color)
	self.colors.tint = color or self.disabled_tint_color

	for _, c in ipairs(self.children) do
		c:apply_disabled_tint(color)
	end
end

function KView:remove_disabled_tint()
	if not self._disabled then
		self.colors.tint = nil
	end

	for _, c in ipairs(self.children) do
		c:remove_disabled_tint()
	end
end

function KView:get_bounds()
	if self.ignore_bounds then
		return V.r(0, 0, 0, 0)
	end

	local xmin, xmax, ymin, ymax = 0, self.size.x, 0, self.size.y

	for _, c in pairs(self.children) do
		if not c.ignore_bounds then
			local b = c:get_bounds()

			xmin = xmin > b.pos.x and b.pos.x or xmin
			ymin = ymin > b.pos.y and b.pos.y or ymin
			xmax = xmax < b.pos.x + b.size.x and b.pos.x + b.size.x or xmax
			ymax = ymax < b.pos.y + b.size.y and b.pos.y + b.size.y or ymax
		end
	end

	local w, h = (xmax - xmin) * self.scale.x, (ymax - ymin) * self.scale.y
	local x, y

	if self.parent then
		x, y = self:view_to_view(xmin, ymin, self.parent)
	else
		x, y = xmin, ymin
	end

	return V.r(x, y, w, h)
end

KImageView = class("KImageView", KView)
KImageView.static.init_arg_names = {
	"image_name",
	"size",
    "image_scale"
}

function KImageView:initialize(image_name, size, image_scale)
	KView.initialize(self, size, image_name, image_scale)

	local dt = self._deserialize_table

	for _, v in pairs({
		"up",
		"down",
		"click"
	}) do
		local k = "propagate_on_" .. v

		if dt and dt[k] ~= nil then
			self[k] = dt[k]
		else
			self[k] = true
		end
	end
end

KWindow = class("KWindow", KView)

KWindow:append_serialize_keys("origin")

function KWindow:initialize(size)
	KWindow.super.initialize(self, size)

	self.origin = V.v(0, 0)
	self.drag_threshold = 4
	self.focused = nil
end

function KWindow:draw()
	G.push()
	G.translate(self.origin.x, self.origin.y)
	G.setColor(1, 1, 1, 1)
	KView.draw(self)
	G.pop()
end

function KWindow:draw_child(child)
	G.push()
	G.translate(self.origin.x, self.origin.y)
	G.scale(self.scale.x, self.scale.y)
	G.rotate(-self.r)
	G.translate(-self.anchor.x, -self.anchor.y)
	child:draw()
	G.pop()
end

function KWindow:get_mouse_position()
	local x, y = love.mouse.getPosition()

	x, y = x - self.origin.x, y - self.origin.y

	local any_button_down = love.mouse.isDown(1, 2)

	return x, y, any_button_down
end

function KWindow:mousepressed(x, y, button, istouch)
	x, y = x - self.origin.x, y - self.origin.y
	self._mouse_down_pos = V.v(x, y)

	local wx, wy = self:screen_to_view(x, y)

	log.paranoid("x,y:%s,%s  button:%s, istouch:%s, wx,wy:%s,%s  ", x, y, button, istouch, wx, wy)

	local event_name

	if button == 1 or button == 2 then
		event_name = "on_down"

		local dv = self:hit_topmost(wx, wy, function(v)
			return not v.propagate_drag or v.can_drag
		end)

		self._drag_view = dv and dv.can_drag and dv or nil

		log.paranoid("  _drag_view:%s", self._drag_view)
	elseif button == "wu" or button == "wd" then
		event_name = "on_scroll"
	else
		log.paranoid("button press not handled: %s", button)

		return
	end

	local hl = self:hit_all(wx, wy)

	self._click_start_view = nil

	for _, v in pairs(hl) do
		if v.on_click then
			self._click_start_view = v

			break
		elseif not v.propagate_on_click then
			break
		end
	end

	for _, v in pairs(hl) do
		log.paranoid(" checking event %s in view %s[%s]", event_name, tostring(v), v.id)

		if v[event_name] then
			log.paranoid(" > handling event %s in view %s[%s]", event_name, tostring(v), v.id)

			local vx, vy = v:screen_to_view(x, y)

			if not v[event_name](v, button, vx, vy, istouch) then
				break
			end
		elseif not v["propagate_" .. event_name] then
			break
		end
	end
end

function KWindow:wheelmoved(dx, dy)
	local x, y = love.mouse.getPosition()

	log.debug("dx:%s dy:%s", dx, dy)

	local button

	if dy > 0 then
		button = "wu"
	elseif dy < 0 then
		button = "wd"
	end

	self:mousepressed(x, y, button)
end

function KWindow:mousereleased(x, y, button, istouch)
	x, y = x - self.origin.x, y - self.origin.y

	log.paranoid("x:%s, y:%s, button:%s istouch:%s", x, y, button, istouch)

	if not self._mouse_down_pos then
		return
	end

	local mth = self.drag_threshold * self.scale.x
	local moved = mth < math.abs(self._mouse_down_pos.x - x) or mth < math.abs(self._mouse_down_pos.y - y)
	local wx, wy = self:screen_to_view(x, y)
	local hl = self:hit_all(wx, wy)

	if moved and self._drag_view then
		for _, v in pairs(hl) do
			if v == self._drag_view then
				if v.on_dropped then
					v:on_dropped(istouch)
				end
			elseif v.on_drop then
				if not v:on_drop(self._drag_view, istouch) then
					break
				end
			elseif not v.propagate_on_drop then
				break
			end
		end
	else
		for _, v in pairs(hl) do
			log.paranoid(" checking event %s in view %s[%s]", "up", tostring(v), v.id)

			if v.on_up then
				log.paranoid(" > handling event %s in view %s[%s]", "up", tostring(v), v.id)

				local vx, vy = v:screen_to_view(x, y)

				if not v:on_up(button, vx, vy, self._drag_view, istouch) then
					break
				end
			elseif not v.propagate_on_up then
				break
			end
		end

		for _, v in pairs(hl) do
			log.paranoid(" checking event %s in view %s[%s]", "click", tostring(v), v.id)

			if v.on_click and v == self._click_start_view then
				log.paranoid(" > handling event %s in view %s[%s]", "click", tostring(v), v.id)

				local vx, vy = v:screen_to_view(x, y)

				if not v:on_click(button, vx, vy, istouch, moved) then
					break
				end
			elseif not v.propagate_on_click then
				break
			end
		end
	end

	self._drag_view = nil
end

function KWindow:touchpressed(id, x, y, dx, dy, pressure)
	x, y = x - self.origin.x, y - self.origin.y

	log.paranoid("x:%s, y:%s, id:%s", x, y, id)

	local wx, wy = self:screen_to_view(x, y)
	local hl = self:hit_all(wx, wy)
	local event_name = "on_touch_down"

	for _, v in pairs(hl) do
		log.paranoid(" checking event %s in view %s", event_name, tostring(v))

		if v[event_name] then
			log.paranoid(" > handling event %s in view %s", event_name, tostring(v))

			local vx, vy = v:screen_to_view(x, y)

			if not v[event_name](v, id, vx, vy, dx, dy, pressure) then
				break
			end
		elseif not v["propagate_" .. event_name] then
			break
		end
	end
end

function KWindow:touchreleased(id, x, y, dx, dy, pressure)
	x, y = x - self.origin.x, y - self.origin.y

	log.paranoid("x:%s, y:%s, id:%s", x, y, id)

	local wx, wy = self:screen_to_view(x, y)
	local hl = self:hit_all(wx, wy)
	local event_name = "on_touch_up"

	for _, v in pairs(hl) do
		log.paranoid(" checking event %s in view %s", event_name, tostring(v))

		if v[event_name] then
			log.paranoid(" > handling event %s in view %s", event_name, tostring(v))

			local vx, vy = v:screen_to_view(x, y)

			if not v[event_name](v, id, vx, vy, dx, dy, pressure) then
				break
			end
		elseif not v["propagate_" .. event_name] then
			break
		end
	end
end

function KWindow:touchmoved(id, x, y, dx, dy, pressure)
	x, y = x - self.origin.x, y - self.origin.y

	local wx, wy = self:screen_to_view(x, y)
	local hl = self:hit_all(wx, wy)
	local event_name = "on_touch_move"

	for _, v in pairs(hl) do
		log.paranoid(" checking event %s in view %s", event_name, tostring(v))

		if v[event_name] then
			log.paranoid(" > handling event %s in view %s", event_name, tostring(v))

			local vx, vy = v:screen_to_view(x, y)

			if not v[event_name](v, id, vx, vy, dx, dy, pressure) then
				break
			end
		elseif not v["propagate_" .. event_name] then
			break
		end
	end
end

function KWindow:update(dt)
	KWindow.super.update(self, dt)

	local x, y = 0, 0
	local button_1_down = false
	local touches = love.touch.getTouches()

	if touches and #touches > 0 then
		x, y = love.touch.getPosition(touches[1])
		x, y = x - self.origin.x, y - self.origin.y
		button_1_down = true
	else
		x, y = self:get_mouse_position()
		button_1_down = love.mouse.isDown(1)
	end

	local wx, wy = self:screen_to_view(x, y)
	local dv = self._drag_view

	if button_1_down then
		if not self._last_mouse_pos then
			self._last_mouse_pos = V.v(x, y)
		end

		local lx, ly = self._last_mouse_pos.x, self._last_mouse_pos.y
		local dx, dy = x - lx, y - ly

		if self._mouse_down_pos then
			local mdx, mdy = self._mouse_down_pos.x, self._mouse_down_pos.y
			local mth = self.drag_threshold * self.scale.x

			if mth >= math.abs(mdx - x) and mth >= math.abs(mdy - y) then
				goto label_70_0
			end
		end

		if dv ~= nil then
			local csv = self._click_start_view

			if csv and csv.on_exit then
				csv:on_exit()

				self._click_start_view = nil
			end

			dv.pos.x = dv.pos.x + dx / self.scale.x
			dv.pos.y = dv.pos.y + dy / self.scale.y

			if dv.drag_limits then
				local dl = dv.drag_limits

				dv.pos.x = km.clamp(dl.pos.x, dl.pos.x + dl.size.x, dv.pos.x)
				dv.pos.y = km.clamp(dl.pos.y, dl.pos.y + dl.size.y, dv.pos.y)
			end
		end

		::label_70_0::

		self._last_mouse_pos = V.v(x, y)
	else
		self._last_mouse_pos = nil
	end

	local lev = self._last_enter_view
	local nev = self:hit_topmost(wx, wy, function(v)
		return not v.hidden and (not v.propagate_on_enter or v.on_enter ~= nil or v.on_exit ~= nil)
	end)

	if lev ~= nev then
		if lev and lev.on_exit then
			lev:on_exit(self._drag_view)
		end

		if nev and nev.on_enter and not self.disable_mouse_enter then
			nev:on_enter(self._drag_view)
		end

		self._last_enter_view = nev
	end
end

function KWindow:focus_view(v)
	log.debug("focus_view:%s", v)

	local c = self.focused

	if c then
		self.focused = nil
		c._focused = nil

		if c.on_defocus then
			c:on_defocus()
		end
	end

	if v then
		self.focused = v
		v._focused = true

		if v.on_focus then
			v:on_focus()
		end
	end
end

function KWindow:find_next_focus(root, focused, key, reverse)
	local function get_dir(vx, vy, restrict_dir, threshold)
		if not restrict_dir or restrict_dir == "+" or restrict_dir == "normal" then
			if vx >= math.abs(vy) then
				return "right"
			elseif vx <= -1 * math.abs(vy) then
				return "left"
			elseif vy >= math.abs(vx) then
				return "down"
			elseif vy <= -1 * math.abs(vx) then
				return "up"
			end
		elseif restrict_dir == "vertical" then
			if threshold < vy then
				return "down"
			elseif vy < -threshold then
				return "up"
			else
				return nil
			end
		elseif restrict_dir == "horizontal" then
			if threshold < vx then
				return "right"
			elseif vx < -threshold then
				return "left"
			else
				return nil
			end
		end
	end

	local all = root:flatten(function(v)
		return v.on_keypressed and not v:is_disabled() and not v.hidden and not v.focus_nav_ignore
	end, function(v)
		return not v:is_disabled() and not v.hidden
	end)

	if #all < 1 then
		log.paranoid("sorted list of views is empty")

		return
	end

	local root_pos_list = {}

	for _, v in pairs(all) do
		local vox, voy = 0, 0

		if v.focus_nav_offset then
			vox, voy = v.focus_nav_offset.x, v.focus_nav_offset.y
		elseif v.anchor then
			vox, voy = v.anchor.x, v.anchor.y
		end

		table.insert(root_pos_list, {
			v,
			v:view_to_view(vox, voy, root)
		})
	end

	table.sort(root_pos_list, function(i1, i2)
		local v1, p1x, p1y = unpack(i1)
		local v2, p2x, p2y = unpack(i2)

		if v1.focus_order == v2.focus_order then
			if p1y == p2y then
				return p1x < p2x
			else
				return p1y < p2y
			end
		else
			return v1.focus_order < v2.focus_order
		end
	end)

	local sorted = table.map(root_pos_list, function(k, v)
		return v[1]
	end)
	local fidx = table.keyforobject(sorted, focused)

	if not fidx then
		fidx = key == "tab" and reverse and #sorted or 1
		focused = sorted[fidx]
	elseif focused.focus_nav_override and focused.focus_nav_override[key] then
		local dest = focused.focus_nav_override[key]

		if dest ~= "none" then
			focused = focused.focus_nav_override[key]
		end
	else
		do
			local fox, foy = 0, 0

			if focused.focus_nav_offset then
				fox, foy = focused.focus_nav_offset.x, focused.focus_nav_offset.y
			elseif focused.anchor then
				fox, foy = focused.anchor.x, focused.anchor.y
			end

			local fposx, fposy = focused:view_to_view(fox, foy, root)

			if key == "tab" then
				fidx = km.zmod(fidx + (reverse and -1 or 1), #sorted)
				focused = sorted[fidx]

				log.paranoid("after tab. fidx:%s focused:%s", fidx, focused)
			elseif table.contains({
				"up",
				"down",
				"left",
				"right"
			}, key) then
				local dir_passes

				if focused.focus_nav_dir then
					dir_passes = {
						focused.focus_nav_dir
					}
				elseif key == "up" or key == "down" then
					dir_passes = {
						"+",
						"vertical"
					}
				elseif key == "left" or key == "right" then
					dir_passes = {
						"+",
						"horizontal"
					}
				end

				for _, nav_dir in pairs(dir_passes) do
					local fx, fy = 1, 1

					if key == "up" or key == "down" then
						fx = nav_dir == "+" and 3 or 1
					elseif key == "left" or key == "right" then
						fy = nav_dir == "+" and 3 or 1
					end

					table.sort(root_pos_list, function(i1, i2)
						local p1x, p1y, p2x, p2y = i1[2], i1[3], i2[2], i2[3]
						local d1x, d1y = (p1x - fposx) * fx, (p1y - fposy) * fy
						local d2x, d2y = (p2x - fposx) * fx, (p2y - fposy) * fy
						local d1, d2 = d1x * d1x + d1y * d1y, d2x * d2x + d2y * d2y

						return d1 < d2
					end)

					if DEBUG_KUI_DRAW_FOCUS_NAV then
						log.paranoid("pass - nav_dir: %s", nav_dir)

						for _, item in ipairs(root_pos_list) do
							log.paranoid("  %s,%s - %s", item[2], item[3], item[1])
						end
					end

					for _, row in pairs(root_pos_list) do
						local v, vx, vy = unpack(row)
						local dir = get_dir(vx - fposx, vy - fposy, nav_dir, 5)

						log.paranoid("key:%s pass:%s fpos:%s,%s  v:%s pos:%s,%s  dir:%s", key, nav_dir, fposx, fposy, v, vx, vy, dir)

						if v ~= focused and dir == key then
							focused = v

							goto label_73_0
						end
					end
				end
			end
		end

		::label_73_0::
	end

	return focused
end

function KWindow:set_responder(view)
	self.responder = view
end

function KWindow:keypressed(key, isrepeat)
	if self.responder and self.responder.on_keypressed and self.responder:on_keypressed(key) then
		log.paranoid("FOCUS: keypress handled by focused view: %s", self.focused)

		return true
	end

	if self.focused and self.focused.on_keypressed and self.focused:on_keypressed(key) then
		log.paranoid("FOCUS: keypress handled by focused view: %s", self.focused)

		return true
	end

	if self.responder then
		local reverse

		if key == "tab" then
			reverse = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
		end

		local next_view = self:find_next_focus(self.responder, self.focused, key, reverse)

		self:focus_view(next_view)
	end
end

function KWindow:keyreleased(key)
	if self.responder then
		local responder = self.responder

		if responder and responder.on_keyreleased then
			return responder:on_keyreleased(key)
		end
	end
end

function KWindow:textinput(t)
	local r = self.responder

	if r and r.on_textinput then
		r:on_textinput(t)
	end
end

KLabel = class("KLabel", KImageView)

KLabel:append_serialize_keys("text", "text_offset", "text_align", "text_size", "colors", "line_height", "font_name", "font_size")

KLabel.static.init_arg_names = {
	"size",
	"image_name"
}

function KLabel:initialize(size, image_name)
	self.text = ""
	self.text_offset = V.v(0, 0)
	self.font = nil
	self.font_name = nil
	self.font_size = nil
	self.text_align = "center"
	self.line_height = 1
	self._loaded_font_name = nil
	self._loaded_font_size = nil

	KImageView.initialize(self, image_name, size)

	if not self.text_size then
		self.text_size = self.size
	end

	if not self.colors.text then
		self.colors.text = {
			0,
			0,
			0
		}
	end
end

function KLabel:_draw_self()
	KLabel.super._draw_self(self)
	self:_load_font()

	if self.font then
		G.setFont(self.font)
		self.font:setLineHeight(self.line_height)
	end

	local pr, pg, pb, pa = G.getColor()

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

	local voff = self.font_adj and self.font_adj.top or 0

	G.printf(self.text, self.text_offset.x, self.text_offset.y + voff, self.text_size.x, self.text_align)
	G.setColor_old(pr, pg, pb, pa)
end

function KLabel:get_wrap_lines()
	self:_load_font()

	local width, wrapped = self.font:getWrap(self.text, self.text_size.x)

	return width, #wrapped, wrapped
end

function KLabel:_load_font()
	if not self.font or self._loaded_font_name ~= self.font_name or self._loaded_font_size ~= self.font_size then
		self._loaded_font_name = self.font_name
		self._loaded_font_size = self.font_size

		if self.font_name and self.font_size then
			self.font = F:f(self.font_name, self.font_size)
			self.font_adj = F:f_adj(self.font_name, self.font_size)
		else
			log.debug("Font not specified for %s", self)

			self.font = G:getFont()
			self.font_adj = {
				size = 1
			}
		end
	end
end

KButton = class("KButton", KLabel)

function KButton:initialize(size, image_name)
	KLabel.initialize(self, size, image_name)

	self.highlighted = false
	self.propagate_on_up = false
	self.propagate_on_down = false
	self.propagate_on_click = false
	self.propagate_on_touch_down = false
	self.propagate_on_touch_up = false
	self.propagate_on_touch_move = false
end

function KButton:update(dt)
	KButton.super.update(self, dt)
end

function KButton:draw()
	KButton.super.draw(self)
end

KImageButton = class("KImageButton", KButton)

KImageButton:append_serialize_keys("default_image_name", "hover_image_name", "click_image_name", "disable_image_name")

KImageButton.static.init_arg_names = {
	"default_image_name",
	"hover_image_name",
	"click_image_name",
	"disable_image_name"
}

function KImageButton:initialize(default_image_name, hover_image_name, click_image_name, disable_image_name)
	self.default_image_name = default_image_name
	self.hover_image_name = hover_image_name or default_image_name
	self.click_image_name = click_image_name or hover_image_name or default_image_name
	self.disable_image_name = disable_image_name

	KButton.initialize(self, nil, default_image_name)
end

function KImageButton:on_enter(drag_view)
	if not self:is_disabled() then
		self:set_image(self.hover_image_name)
	end
end

function KImageButton:on_exit(drag_view)
	if not self:is_disabled() then
		self:set_image(self.default_image_name)
	end
end

function KImageButton:on_down(button, x, y)
	if not self:is_disabled() then
		self:set_image(self.click_image_name)
	end
end

function KImageButton:on_up(button, x, y)
	if not self:is_disabled() then
		self:set_image(self.hover_image_name)
	end
end

function KImageButton:on_focus()
	self:on_enter()
end

function KImageButton:on_defocus()
	self:on_exit()
end

function KImageButton:on_keypressed(key, is_repeat)
	if key == "return" and not self:is_disabled() then
		self:on_click()

		return true
	end
end

function KImageButton:apply_disabled_tint(color)
	if self.disable_image_name then
		self:set_image(self.disable_image_name)
	else
		if self.default_image_name then
			self:set_image(self.default_image_name)
		end

		KImageButton.super.apply_disabled_tint(self, color)
	end
end

function KImageButton:remove_disabled_tint()
	if self.disable_image_name then
		self:set_image(self.default_image_name)
	else
		KImageButton.super.remove_disabled_tint(self, color)
	end
end

KScrollList = class("KScrollList", KView)

KScrollList:append_serialize_keys("scroll_amount", "scroll_acceleration", "scroller_width", "scroller_margin", "scroller_hidden")

function KScrollList:initialize(size)
	log.debug("KScrollList")

	self.scroll_origin_y = 0
	self._bottom_y = 0
	self.scroll_amount = 1
	self.scroll_acceleration = 2
	self.scroller_width = 16
	self.scroller_margin = 4
	self.scroller_hidden = false

	KView.initialize(self, size)

	self.clip = true
	self.propagate_on_scroll = false

	if not self.colors.scroller_background then
		self.colors.scroller_background = {
			220,
			220,
			220,
			255
		}
	end

	if not self.colors.scroller_foreground then
		self.colors.scroller_foreground = {
			180,
			180,
			180,
			255
		}
	end

	self:set_scroller_size()
end

function KScrollList:set_scroller_size(width, margin)
	if width then
		self.scroller_width = width
	end

	if margin then
		self.scroller_margin = margin
	end

	self.scroller_rect = V.r(self.size.x - self.scroller_width - 2 * self.scroller_margin, 0, self.scroller_width + 2 * self.scroller_margin, self.size.y)
end

function KScrollList:draw()
	KScrollList.super.draw(self)
	G.push()
	G.scale(self.scale.x, self.scale.y)
	G.rotate(-self.r)

	if not self.scroller_hidden and self._bottom_y > self.size.y then
		G.setColor_old(self.colors.scroller_background)
		G.rectangle("fill", self.scroller_rect.pos.x, self.scroller_rect.pos.y, self.scroller_rect.size.x, self.scroller_rect.size.y)
		G.setColor_old(self.colors.scroller_foreground)

		local scroller_height = self.size.y / self._bottom_y * (self.size.y - 2 * self.scroller_margin)
		local scroller_offset = -self.scroll_origin_y / self._bottom_y * (self.size.y - 2 * self.scroller_margin)

		G.rectangle("fill", self.size.x - self.scroller_width - self.scroller_margin, scroller_offset + self.scroller_margin, self.scroller_width, scroller_height)
	end

	G.pop()
end

function KScrollList:clear_rows()
	self._bottom_y = 0
	self.scroll_origin_y = 0

	self:remove_children()
end

function KScrollList:add_row(view)
	view.pos.y = self._bottom_y
	self._bottom_y = self._bottom_y + view.size.y

	self:add_child(view)
end

function KScrollList:is_at_bottom()
	return self.size.y - self.scroll_origin_y >= self._bottom_y
end

function KScrollList:is_at_top()
	return self.scroll_origin_y == 0
end

function KScrollList:scroll_to_bottom()
	self.scroll_origin_y = -(self._bottom_y - self.size.y)
end

function KScrollList:scroll_to_top()
	self.scroll_origin_y = 0
end

function KScrollList:scroll_to_show_y(y)
	self.scroll_origin_y = -1 * (y - self.size.y * 0.5)
	self.scroll_origin_y = km.clamp(-(self._bottom_y - self.size.y), 0, self.scroll_origin_y)
end

function KScrollList:update(dt)
	KScrollList.super.update(self, dt)

	local mx, my, any_button_down = self:get_window():get_mouse_position()
	local wx, wy = self:screen_to_view(mx, my)

	if any_button_down and self._down_y and V.is_inside(V.v(wx, wy), self.scroller_rect) then
		local a = wy - self._down_y
		local scroller_factor = self._bottom_y / (self.size.y - 2 * self.scroller_margin)
		local scroller_step = self.scroll_amount / scroller_factor

		if math.abs(a) >= math.abs(scroller_step) then
			local steps = km.sign(a) * math.floor(math.abs(a) / scroller_step)

			self._down_y = self._down_y + steps * scroller_step
			self.scroll_origin_y = self.scroll_origin_y - steps * self.scroll_amount
			self.scroll_origin_y = km.clamp(-(self._bottom_y - self.size.y), 0, self.scroll_origin_y)
		end
	end
end

function KScrollList:on_down(button, x, y)
	log.paranoid("button:%s x:%s, y:%s", button, x, y)

	if button == 1 and V.is_inside(V.v(x, y), self.scroller_rect) and self._bottom_y > self.size.y then
		self._down_y = y
		self._scroll_origin_start = self.scroll_origin_y
	end
end

function KScrollList:on_up(button, x, y)
	log.debug()

	self._down_y = nil
end

function KScrollList:on_exit()
	log.debug()

	self._down_y = nil
end

function KScrollList:on_scroll(button)
	if self._bottom_y <= self.size.y then
		return false
	end

	local amount = self.scroll_amount
	local now = love.timer.getTime()

	if self.scroll_acceleration > 0 and self._last_scroll_time and now - self._last_scroll_time < 0.25 and self._last_scroll_direction == button then
		amount = km.clamp(1, 30, self._last_scroll_amount * self.scroll_acceleration)
	end

	self._last_scroll_amount = amount
	self._last_scroll_time = now
	self._last_scroll_direction = button
	self.scroll_origin_y = self.scroll_origin_y + (button == "wu" and 1 or -1) * amount
	self.scroll_origin_y = km.clamp(-(self._bottom_y - self.size.y), 0, self.scroll_origin_y)

	return false
end

KInertialView = class("KInertialView", KView)

KInertialView:include(KMDragInertia)

KTable = class("KTable", KView)

KTable:append_serialize_keys("cell_view", "start_view", "end_view")

function KTable:initialize(size, cell_view, start_view, end_view)
	KView.initialize(self, size)

	self.clip = true
	self.propagate_on_scroll = false
	self.cell_view = cell_view
	self.start_view = start_view
	self.end_view = end_view
	self._total_height = 0
end

function KTable:set_data(data)
	self.data = data
	self._first_cell_y = 0

	local height = self.cell_view.size.y * #data

	if self.start_view then
		height = height + self.start_view.size.y
	end

	if self.end_view then
		height = height + self.end_view.size.y
	end

	self._total_height = height
	self._first_cell_y = self.start_view and self.start_view.size.y or 0
	self._last_cell_y = #data * self.cell_view.size.y + self._first_cell_y
end

function KTable:update(dt)
	local sy = self.scroll_origin_y

	if not self.data or not self.cell_view then
		return
	end

	if self.start_view then
		local sv = self.start_view

		if -sy <= sv.size.y and not table.contains(self.children, sv) then
			sv:prepare(0, self.data[0])
			self:add_child(sv)
			table.insert(self._visible_cells, sv)
		elseif -sv > sv.size.y and table.contains(self.children, sv) then
			self:remove_child(sv)
		end
	end

	if self.end_view then
		local th = self._total_height
		local ev = self.end_view

		if -sy >= th - ev.size.y and not table.contains(self.children, ev) then
			sv:prepare(#self.data + 1, self.data[#data + 1])
			self:add_child(ev)
		elseif -sv < th - ev.size.y and table.contains(self.children, ev) then
			self:remove_child(ev)
		end
	end

	local cy = self.cell_view.size.y
	local vis_count = self.cell_view.size.y / self.size.y
	local start_vis_idx = math.ceil((-sy - self._first_cell_y) / cy)
	local end_vis_idx = math.ceil((-sy - self._first_cell_y + self.size.y) / cy)

	for i = #self.children, 1, -1 do
		local v = self.children[i]

		if v.cell_idx and (start_vis_idx > v.cell_idx or end_vis_idx < v.cell_idx) then
			self:remove_child(v)
			table.insert(self.cell_pool, v)

			self._vis_idx[v.cell_idx] = nil
		end
	end

	for i = start_vis_idx, end_vis_idx do
		if not self._vis_idx[i] then
			local v = table.remove(self.cell_pool) or self.cell_view:clone()

			v.cell_idx = i
			v.pos.y = self._first_cell_y + (i - 1) * v.size.y

			v:prepare(i, self.data[i])

			self._vis_idx[i] = v

			self:add_child(v)
		end
	end
end

KVideoView = class("KVideoView", KView)
KVideoView.static.init_arg_names = {
	"video_name"
}

function KVideoView:initialize(video_name)
	self.video_name = video_name
	self.video = love.graphics.newVideo(video_name)

	if not self.video then
		log.error("video not found: %s", video_name)

		return
	end

	local size = V.v(self.video:getWidth(), self.video:getHeight())

	log.debug("video name:%s", video_name)
	log.debug("video size:%s,%s", size.x, size.y)
	KView.initialize(self, size)
end

function KVideoView:_draw_self()
	if self.video then
		G.draw(self.video, 0, 0, 0, 1, 1)
	end
end
