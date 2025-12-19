-- chunkname: @./all/screen_comics.lua
local log = require("lib.klua.log"):new("screen_comics")
local V = require("lib.klua.vector")
local I = require("klove.image_db")
local F = require("lib.klove.font_db")
local G = love.graphics
local S = require("sound_db")
local SU = require("screen_utils")
local v = V.v
local i18n = require("i18n")
local timer = require("hump.timer").new()
local timer_comic = require("hump.timer").new()
require("klove.kui")
require("gg_views_custom")

local function fts(v)
	return v / 30
end

screen_comics = {}

if KR_TARGET == "console" then
	screen_comics.ref_h = 320
	screen_comics.ref_w = 480
	screen_comics.ref_res = TEXTURE_SIZE_ALIAS.fullhd * 0.5
elseif KR_TARGET == "tablet" then
	screen_comics.ref_h = 768
	screen_comics.ref_w = 1024
	screen_comics.ref_res = TEXTURE_SIZE_ALIAS.ipad * 1.4222222222222223
else
	screen_comics.ref_h = GUI_REF_H
	screen_comics.ref_w = GUI_REF_W
	screen_comics.ref_res = KR_TARGET == "phone" and TEXTURE_SIZE_ALIAS.iphone or TEXTURE_SIZE_ALIAS.ipad
end

function screen_comics:init(w, h, done_callback)
	self.done_callback = done_callback
	self.t = 0
	self.playing = true
	self.skipping = nil
	self.finishing = nil
	local sw, sh, scale, origin = SU.clamp_window_aspect(w, h, self.ref_w, self.ref_h)
	self.sw, self.sh = sw, sh
	GGLabel.static.font_scale = scale
	GGLabel.static.ref_h = self.ref_h
	local window = KWindow:new(V.v(sw, sh))
	window.scale = v(scale, scale)
	window.origin = origin
	window.colors.background = {0, 0, 0, 255}
	self.window = window
	local current_page = 1
	local page_views = {}
	local page_end_frames = {}
	local sprites_order = {}
	local sprites = {}
	local labels = {}

	local function new_page_view(hidden)
		local page_view = KView:new(V.v(self.ref_h, self.ref_w))
		page_view.anchor = v(self.ref_w * 0.5, 0)
		page_view.pos = v(sw * 0.5, 0)
		page_view.hidden = hidden
		page_view.propagate_on_down = true
		page_view.propagate_on_up = true
		page_view.propagate_on_click = true
		self.window:add_child(page_view)
		return page_view
	end

	for __, line in pairs(string.split(self.comic_data, "\n")) do
		line = string.gsub(line, "\"", "")
		line = string.gsub(line, ".png", "")
		local row = string.split(line, ",")

		if row[1] == "PAGE_END" then
			table.insert(page_views, new_page_view())
			table.insert(page_end_frames, tonumber(row[2]))
			current_page = current_page + 1
		elseif row[1] == "ORDER" then
			for i = 2, #row do
				table.insert(sprites_order, row[i])
				sprites_order[row[i]] = i
			end
		elseif row[1] == "TEXT" then
			for i = 4, 12 do
				row[i] = tonumber(row[i])
			end

			local cmd, text_key, sid, x, y, size_x, size_y, r, cr, cg, cb, fit_lines = unpack(row)

			if not labels[text_key .. sid] then
				labels[text_key .. sid] = true
				local s = sprites[sid]
				local l = GGLabel:new(V.v(size_x, size_y))

				if fit_lines and fit_lines > 0 then
					l.fit_lines = fit_lines
				else
					l.fit_size = true
				end

				l.line_height = 0.9
				l.propagate_on_down = true
				l.propagate_on_click = true
				l.colors = {
					text = {cr, cg, cb, 255}
				}
				l.pos = V.v(x + s.anchor.x, y + s.anchor.y)
				l.anchor = V.v(size_x * 0.5, size_y * 0.5)
				l.text = _(text_key .. "_" .. string.upper(KR_GAME))
				l.r = r * -1 * math.pi / 180
				l.font_name = "body"
				l.font_size = 22
				l.vertical_align = "middle"
				s:add_child(l)

				if DEBUG_COMIC_TEXT then
					l.colors.background = {0, 0, 0, 80}
				end
			end
		else
			row[2] = tonumber(row[2])

			for i = 4, 11 do
				row[i] = tonumber(row[i])
			end

			local sid, frame, img_name, x, y, scale_x, scale_y, alpha, ease, anchor_x, anchor_y = unpack(row)
			local s = sprites[sid]

			if not s then
				s = KImageView:new(img_name)
				s.id = sid
				s.scale = V.v(scale_x, scale_y)
				s.alpha = 0
				s.pos = V.v(x, y)
				s.anchor = V.v(anchor_x * s.size.x, (1 - anchor_y) * s.size.y)
				s.current_page = current_page
				sprites[sid] = s
				s.timer_script = {{"wait", frame}}
			else
				table.insert(s.timer_script, {"msa", frame, x, y, scale_x, scale_y, alpha, ease})
			end
		end
	end

	for _, s in pairs(sprites) do
		s.timer_h = timer_comic:script(function(wait)
			local last_frame = 0

			for _, si in pairs(s.timer_script) do
				local cmd, frame, x, y, scale_x, scale_y, alpha, ease = unpack(si)

				if cmd == "wait" then
					local t = fts(frame - last_frame)
					wait(t)
					last_frame = frame
				else
					local t = fts(frame - last_frame)
					timer_comic:tween(t, s, {
						pos = {
							x = x,
							y = y
						},
						scale = {
							x = scale_x,
							y = scale_y
						},
						alpha = alpha
					}, ease > 0 and "out-expo" or "in-expo")
					wait(t)
					last_frame = frame
				end
			end
		end)
	end

	for i = 1, #sprites_order do
		local sid = sprites_order[i]
		local s = sprites[sid]
		page_views[s.current_page]:add_child(s)
	end

	for i, p in ipairs(page_views) do
		p.end_time = fts(page_end_frames[i])
	end

	page_views[1].hidden = false
	self.current_page = page_views[1]
	self.current_page_id = 1
	self.page_views = page_views

	if self.fade_in then
		self.playing = false
		local end_color = window.colors.background
		local time, start_color = unpack(self.fade_in)
		window.colors.background = start_color
		timer:tween(time, self.window.colors, {
			background = end_color
		}, "out-linear", function()
			self.playing = true
			self.t = 0
		end)
	end

	if self.level_idx then
		S:queue(string.format("MusicBattlePrep_%02d", self.level_idx))
	end
end

function screen_comics:destroy()
	timer:clear()
	timer_comic:clear()
	self.window:destroy()
	self.window = nil
	SU.remove_references(self, KView)
end

function screen_comics:update(dt)
	if self.playing then
		self.t = self.t + dt

		if self.t > self.current_page.end_time then
			self.playing = false
		else
			timer_comic:update(dt)
		end
	end

	timer:update(dt)
	self.window:update(dt)
end

function screen_comics:draw()
	self.window:draw()
end

function screen_comics:do_last_frame()
	while self.t < self.current_page.end_time do
		timer_comic:update(0.03333333333333333)
		self.t = self.t + 0.03333333333333333
	end

	self.t = self.current_page.end_time
	self.playing = false
end

function screen_comics:do_next_page()
	self.current_page.hidden = true

	if self.current_page_id < #self.page_views then
		self.current_page_id = self.current_page_id + 1
		self.current_page = self.page_views[self.current_page_id]
		self.current_page.hidden = false
		self.playing = true
		self.skipping = false
	else
		self.finishing = true
		self.done_callback()
	end
end

function screen_comics:skip()
	if self.skipping or self.finishing then
		return
	elseif not self.playing then
		self.skipping = true
		S:queue("GUINotificationPaperOver")
		timer:tween(0.25, self.current_page, {
			alpha = 0
		}, "out-linear", function()
			self:do_next_page()
		end)
	else
		self:do_last_frame()
	end
end

function screen_comics:keypressed(key, isrepeat)
	self:skip()
end

function screen_comics:keyreleased(key)
	return
end

function screen_comics:mousepressed(x, y, button)
	self:skip()
end

function screen_comics:mousereleased(x, y, button)
	return
end

function screen_comics:gamepadpressed(joystick, button)
	self:skip()
end

return screen_comics
