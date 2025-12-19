-- chunkname: @./all/screen_credits.lua
local log = require("lib.klua.log"):new("screen_slots")
local class = require("middleclass")
local F = require("lib.klove.font_db")
local V = require("lib.klua.vector")
local v = V.v
local km = require("lib.klua.macros")
local timer = require("hump.timer").new()
local S = require("sound_db")
local SU = require("screen_utils")
local ISM = require("input_state_machine")
local i18n = require("i18n")

require("klove.kui")
require("gg_views_custom")

local IS_PHONE = KR_TARGET == "phone"
local IS_TABLET = KR_TARGET == "tablet"
local IS_MOBILE = KR_TARGET == "phone" or KR_TARGET == "tablet"
local screen = {}

screen.required_sounds = {"common", "music_screen_credits"}
screen.required_textures = IS_MOBILE and {"screen_credits", "screen_credits_bg"} or {"screen_credits"}
screen.ref_h = IS_MOBILE and 320 or 768
screen.ref_w = IS_MOBILE and 480 or nil
screen.ref_res = IS_PHONE and TEXTURE_SIZE_ALIAS.iphone or TEXTURE_SIZE_ALIAS.ipad

function screen:init(w, h, done_callback, ending_version)
	if self.args and self.args.custom == "ending" then
		ending_version = true
	end

	local music_name

	music_name = KR_GAME == "kr1" and "MusicEndCredits" or KR_GAME == "kr2" and "MusicEndCredits" or "MusicCredits"

	if not S:sound_is_playing(music_name) then
		S:queue(music_name)
	end

	package.loaded["data.credits_data"] = nil
	screen.credits_data = require("data.credits_data")
	self.ending_version = ending_version
	self.done_callback = done_callback
	self.end_credits_done = nil
	self.scroll_speed_max = IS_MOBILE and 50 or 80
	self.scroll_speed = IS_MOBILE and 0 or screen.scroll_speed_max
	self.scroll_phase = IS_MOBILE and 1 or nil
	self.scroll_paused = false

	local sw, sh, scale, origin = SU.clamp_window_aspect(w, h, self.ref_w, self.ref_h)

	self.sw = sw
	self.sh = sh

	local window = KWindow:new(v(sw, sh))

	window.scale = {
		x = scale,
		y = scale
	}
	window.origin = origin
	window.colors.background = ending_version and {0, 0, 0, 255} or {0, 0, 0, 255}

	window:set_responder(window)

	self.window = window
	GGLabel.static.font_scale = scale
	GGLabel.static.ref_h = self.ref_h

	if not IS_MOBILE and not ending_version then
		local backImage = KImageView:new("credits_new_bg")

		backImage.anchor = v(backImage.size.x * 0.5, backImage.size.y * 0.5)
		backImage.pos = v(window.size.x * 0.5, window.size.y * 0.5)

		window:add_child(backImage)

		local vl = GGLabel:new(v(200, 20))

		vl.colors.text = {0, 0, 0, 255}
		vl.font_name = "numbers_italic"
		vl.text = version.string_short
		vl.anchor = v(200, 22)
		vl.text_align = "right"
		vl.font_size = 14
		vl.pos = v(1150, sh - 5)

		backImage:add_child(vl)

		local knife = KImageView:new("credits_knife")

		knife.pos.x, knife.pos.y = backImage.size.x * 0.5 + 355, -28

		backImage:add_child(knife)
	end

	self.scroll_paused = nil

	local container = KView:new(v(sw, sh))

	container.propagate_on_click = true
	self.container = container

	local label_w = IS_MOBILE and 380 or sw - 285
	local font_size_factor = 1

	if IS_PHONE then
		font_size_factor = 0.7
	elseif IS_TABLET then
		font_size_factor = 0.7
	elseif KR_TARGET == "console" then
		font_size_factor = 1.4
	end

	local font_name_h = IS_MOBILE and "body_bold" or i18n:cjk("body", "sans", nil, "h_noti")
	local current_y = 0

	for i = 1, #screen.credits_data do
		local type = screen.credits_data[i][2]

		if #screen.credits_data[i] == 0 or screen.credits_data[i][1] == "" then
			current_y = current_y + 50 * font_size_factor
		elseif not type or type == "body" then
			local label = GGLabel:new(V.v(label_w, 15))

			label.pos = v(sw * 0.5, current_y)
			label.anchor = v(label.size.x * 0.5, 0)
			label.font_name = "Comic Book Italic"
			label.font_size = 15 * font_size_factor
			label.colors.text = ending_version and {212, 163, 115} or {0, 0, 0}
			label.text = screen.credits_data[i][1]

			if screen.credits_data[i][3] then
				label.text_align = screen.credits_data[i][3]
			else
				label.text_align = "center"
			end

			local _h, lines = label:get_wrap_lines()

			label.size.y = lines * label.line_height * label:get_font_height()
			current_y = current_y + label.size.y

			container:add_child(label)
		elseif not type or type == "body_ja" then
			local label = GGLabel:new(V.v(label_w, 15))

			label.pos = v(sw * 0.5, current_y)
			label.anchor = v(label.size.x * 0.5, 0)
			label.font_name = "NotoSansCJKjp-Regular"
			label.font_size = 13 * font_size_factor
			label.line_height = 1.1
			label.colors.text = ending_version and {212, 163, 115} or {0, 0, 0}
			label.text = screen.credits_data[i][1]

			if screen.credits_data[i][3] then
				label.text_align = screen.credits_data[i][3]
			else
				label.text_align = "center"
			end

			local _h, lines = label:get_wrap_lines()

			label.size.y = lines * label.line_height * label:get_font_height()
			current_y = current_y + label.size.y

			container:add_child(label)
		elseif type == "h1" then
			local label = GGLabel:new(V.v(label_w, 15))

			label.pos = v(sw * 0.5, current_y)
			label.anchor = v(label.size.x * 0.5, 0)
			label.font_name = font_name_h
			label.font_size = 20 * font_size_factor
			label.colors.text = ending_version and {255, 253, 210} or {0, 0, 0}
			label.text = screen.credits_data[i][1]

			if screen.credits_data[i][3] then
				label.text_align = screen.credits_data[i][3]
			else
				label.text_align = "center"
			end

			local _h, lines = label:get_wrap_lines()

			label.size.y = lines * label.line_height * label:get_font_height()
			current_y = current_y + label.size.y

			container:add_child(label)
		elseif type == "h2" then
			local label = GGLabel:new(V.v(label_w, 15))

			label.pos = v(sw * 0.5, current_y)
			label.anchor = v(label.size.x * 0.5, 0)
			label.font_name = font_name_h
			label.font_size = 18 * font_size_factor
			label.colors.text = ending_version and {255, 253, 210} or {0, 0, 0}
			label.text = screen.credits_data[i][1]

			if screen.credits_data[i][3] then
				label.text_align = screen.credits_data[i][3]
			else
				label.text_align = "center"
			end

			local _h, lines = label:get_wrap_lines()

			label.size.y = lines * label.line_height * label:get_font_height()
			current_y = current_y + label.size.y

			container:add_child(label)
		elseif type == "h3" then
			local label = GGLabel:new(V.v(label_w, 15))

			label.pos = v(sw * 0.5, current_y)
			label.anchor = v(label.size.x * 0.5, 0)
			label.font_name = font_name_h
			label.font_size = 13 * font_size_factor
			label.colors.text = ending_version and {212, 163, 115} or {0, 0, 0}
			label.text = screen.credits_data[i][1]

			if screen.credits_data[i][3] then
				label.text_align = screen.credits_data[i][3]
			else
				label.text_align = "center"
			end

			local _h, lines = label:get_wrap_lines()

			label.size.y = lines * label.line_height * label:get_font_height()
			current_y = current_y + label.size.y

			container:add_child(label)
		elseif type ~= "image" or ending_version and screen.credits_data[i][3] then
		-- block empty
		else
			local img = KImageView:new(screen.credits_data[i][1])

			img.anchor = v(img.size.x * 0.5, 0)
			img.pos = v(sw * 0.5, current_y)

			container:add_child(img)

			current_y = current_y + img.size.y + 8
		end
	end

	self.tot_y = current_y

	local scroller

	if IS_MOBILE and not ending_version then
		local topv = KImageView:new("credits_tile_lt")
		local botv = KImageView:new("credits_tile_lt")
		local container_my = topv.size.y / 3

		scroller = KView:new(V.v(592, 0))

		scroller:add_child(topv)

		local vy = topv.size.y - 2

		while vy < self.tot_y + 2 * container_my - botv.size.y do
			local midv = KImageView:new("credits_tile_lc")

			midv.pos.y = vy
			vy = vy + midv.size.y - 2

			scroller:add_child(midv)
		end

		botv.scale.y = -1
		botv.anchor.y = botv.size.y
		botv.pos.y = vy

		scroller:add_child(botv)

		scroller.clip_view = window
		scroller.size.y = vy + botv.size.y
		scroller.pos = v(sw * 0.5, 0)
		scroller.anchor = v(296, 0)

		scroller:add_child(container)

		local scale = km.clamp(IS_TABLET and 0.5 or 1, 2, self.sw / topv.size.x)

		scroller.scale = V.v(scale, scale)
		container.size.y = self.tot_y
		container.anchor = v(sw * 0.5, 0)
		container.pos.y = container_my
		container.pos.x = 296
		container.propagate_on_down = true
		container.propagate_on_up = true
		container.clip_view = window
	else
		container.size.y = self.tot_y + 100
		container.anchor = v(sw * 0.5, 0)

		if IS_TABLET then
			container.scale = V.v(0.7, 0.7)
		end

		scroller = container
		scroller.pos = v(sw * 0.5, 2 * sh / 3)
		scroller.clip_view = window
	end

	scroller.propagate_on_click = true
	scroller.can_drag = true

	if IS_MOBILE then
		scroller.drag_limits = V.r(scroller.pos.x, scroller.pos.y, 0, -scroller.size.y * scroller.scale.y + sh)
	else
		scroller.drag_limits = V.r(scroller.pos.x, scroller.pos.y, 0, -scroller.size.y * scroller.scale.y + 0 * sh / 3)
	end

	function scroller.on_down()
		self.scroll_paused = true
	end

	function scroller.on_up()
		self.scroll_paused = nil
	end

	self.scroller = scroller

	window:add_child(scroller)

	if not ending_version and IS_MOBILE then
		local vl = GGLabel:new(v(320, 14))

		vl.colors.text = {0, 0, 0, 255}
		vl.font_name = "numbers_italic"
		vl.text = version.string .. (version.bundle_keywords or "")
		vl.anchor = v(0, 0)
		vl.text_align = "left"
		vl.font_size = 10
		vl.pos = v(70, 0)

		scroller:add_child(vl)

		local kv = KImageView:new("credits_sword")

		kv.pos = v(442, -35)

		scroller:add_child(kv)
	end

	if ending_version then
		local skip = GGLabel:new(V.v(128, 100))

		window:add_child(skip)

		skip.text = _("CLICK HERE TO SKIP.\nPLEASE DON'T")
		skip.pos = v(sw, sh)
		skip.vertical_align = "bottom"
		skip.text_align = "center"
		skip.font_name = "body"
		skip.font_size = 16 * font_size_factor * (IS_TABLET and 0.7 or 1)

		local min_w = skip:do_fit_lines(3)

		if min_w > skip.size.x then
			skip.size.x = min_w
		end

		skip.anchor = v(skip.size.x + 15, skip.size.y + 8)
		skip.colors.text = {158, 119, 87, 255}
		skip.label_colors = {
			default = {158, 119, 87, 255},
			hover = {232, 211, 139, 255}
		}

		function skip.on_click()
			self:on_end_credits()
		end

		function skip.on_enter(this)
			this.colors.text = this.label_colors.hover
		end

		function skip.on_exit(this)
			this.colors.text = this.label_colors.default
		end

		timer:script(function(wait)
			skip.hidden = true
			skip.alpha = 0
			scroller.alpha = 0

			timer:tween(1, scroller, {
				alpha = 1
			}, "in-quad")
			wait(5)

			skip.hidden = false

			timer:tween(0.5, skip, {
				alpha = 1
			}, "in-quad")
		end)
	else
		local back_image = IS_MOBILE and "credits_back_" or "credits_back_bg_"
		local back = GGButton:new(back_image .. "0001", back_image .. "0002")

		back.pos = v(back.size.x * 0.5, sh)
		back.anchor.y = back.size.y
		back.propagate_drag = false
		back.label.text = _("BACK")
		back.label.font_size = 36 * font_size_factor

		if IS_MOBILE then
			back.label.pos.x, back.label.pos.y = 24, 25
			back.label.size.x, back.label.size.y = 62, 26
		else
			back.label.pos.x, back.label.pos.y = 142, 80
			back.label.size.x, back.label.size.y = 142, 54
			back.label.anchor.x, back.label.anchor.y = back.label.size.x * 0.5, back.label.size.y * 0.5
		end

		back.label.vertical_align = "middle"
		back.label.r = 2 * math.pi / 180
		back.label.shaders = {"p_outline", "p_edge_blur"}
		back.label.shader_args = {{
			thickness = 3,
			outline_color = {0.30980392156862746, 0.19215686274509805, 0.08235294117647059, 1}
		}, {
			thickness = 1
		}}
		back.label.fit_size = true
		back.focus_nav_ignore = true

		window:add_child(back)

		function back.on_click(this)
			S:queue("GUIButtonCommon")
			self:on_end_credits()
		end

		function back.on_keypressed(this, key, isrepeat)
			if key == "return" then
				this:on_click()

				return true
			end
		end

		if KR_PLATFORM == "nx" then
			local tbh1 = GGLabel:new(V.v(32, 32))

			tbh1.pos.x, tbh1.pos.y = 130, 116
			tbh1.text = ""
			tbh1.font_name = "symbols_nx"
			tbh1.font_size = 28
			tbh1.text_align = "center"
			tbh1.colors.text = back.label_colors.default
			self.tbh1 = tbh1

			back:add_child(tbh1)
		end
	end

	local ism_data = {
		FIRST = {{
			"escape",
			true,
			[4] = function()
				self:on_end_credits()
			end
		}, {"return", "escape"}, {
			"space",
			true,
			[4] = function()
				self.scroll_paused = not self.scroll_paused
			end
		}, {
			"up",
			true,
			[4] = self.c_scroll,
			[5] = {100}
		}, {
			"down",
			true,
			[4] = self.c_scroll,
			[5] = {-100}
		}, {"jleftxy", ISM.q_rate_limit, {0.1}, self.c_scroll, {100}}, {
			"ja",
			true,
			[4] = function()
				self.scroll_paused = not self.scroll_paused
			end
		}, {"jb", "escape"}, {"jdpup", "up"}, {"jdpdown", "down"}}
	}

	ISM:init(ism_data, window)
end

function screen:destroy()
	ISM:destroy(self.window)
	timer:clear()
	self.window:destroy()

	self.window = nil

	SU.remove_references(self, KView)
end

function screen:on_end_credits()
	if self.end_credits_done then
		return 
	end

	self.end_credits_done = true

	timer:script(function(wait)
		if self.ending_version then
			timer:tween(1, self.scroller, {
				alpha = 0
			}, "in-quad")
			wait(1)
		end

		self.done_callback({
			next_item_name = "slots"
		})
	end)
end

function screen.c_scroll(ctx, step)
	screen.scroll_paused = true

	if ctx.axis_value then
		local vx, vy = ctx.axis_value[1], ctx.axis_value[2] * ISM.joy_y_axis_factor

		step = (vy > 0 and 1 or -1) * step
	end

	local dl = screen.scroller.drag_limits

	screen.scroller.pos.y = km.clamp(dl.size.y, dl.pos.y, screen.scroller.pos.y + step)
end

function screen:update(dt)
	timer:update(dt)
	self.window:update(dt)

	if not self.scroll_paused then
		if self.scroll_phase == 1 then
			self.scroll_speed = km.clamp(0, self.scroll_speed_max, self.scroll_speed + 0.25)

			if self.scroll_speed == self.scroll_speed_max then
				self.scroll_phase = 2
			end
		elseif self.scroll_phase == 2 then
			local dist = math.abs(self.scroller.pos.y - self.scroller.drag_limits.size.y)

			if dist < 50 then
				self.scroll_phase = 3
			end
		elseif self.scroll_phase == 3 then
			local dist = math.abs(self.scroller.pos.y - self.scroller.drag_limits.size.y)

			self.scroll_speed = self.scroll_speed_max * (dist / 50)

			if self.scroll_speed < 0.1 then
				self.scroll_paused = true

				self:on_end_credits()
			end
		elseif self.scroller.pos.y <= self.scroller.drag_limits.size.y + 1 and not self.scroll_paused then
			self.scroll_paused = true

			self:on_end_credits()
		end

		self.scroller.pos.y = km.clamp(self.scroller.drag_limits.size.y, self.scroller.drag_limits.pos.y, self.scroller.pos.y - self.scroll_speed * dt)
	end
end

function screen:draw()
	self.window:draw()
end

function screen:mousepressed(x, y, button)
	self.window:mousepressed(x, y, button)
end

function screen:mousereleased(x, y, button)
	self.window:mousereleased(x, y, button)
end

function screen:keypressed(key, isrepeat)
	self.window:keypressed(key, isrepeat)
end

return screen
