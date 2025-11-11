-- chunkname: @./all/screen_splash_custom.lua

local log = require("klua.log"):new("screen_splash_custom")
local V = require("klua.vector")
local F = require("klove.font_db")
local FS = love.filesystem
local G = love.graphics
local SU = require("screen_utils")
local PS = require("platform_services")
local timer = require("hump.timer").new()

require("klove.kui")
require("gg_views_custom")

local storage = require("storage")
local features = require("features")
local screen = {}

screen.ref_h = 1080

local all_ref_res = {
	console = TEXTURE_SIZE_ALIAS.fullhd,
	desktop = TEXTURE_SIZE_ALIAS.fullhd,
	phone = TEXTURE_SIZE_ALIAS.ipadhd,
	tablet = TEXTURE_SIZE_ALIAS.ipadhd
}

screen.ref_res = all_ref_res[KR_TARGET]

function screen:init(w, h, done_callback)
	self.done_callback = done_callback

	local sw, sh, scale, origin = SU.clamp_window_aspect(w, h, self.ref_w, self.ref_h)

	self.w, self.h = w, h
	self.sw = sw
	self.sh = sh
	GGLabel.static.font_scale = scale
	GGLabel.static.ref_h = self.ref_h

	local window = KWindow:new(V.v(sw, sh))

	window.scale = {
		x = scale,
		y = scale
	}
	window.origin = origin
	window.colors.background = {
		0,
		0,
		0,
		255
	}
	self.window = window

	local content = KView:new(V.v(sw, sh))

	self.window:add_child(content)

	self.content = content

	local overlay = KView:new(V.v(sw, sh))

	overlay.colors.background = {
		0,
		0,
		0,
		255
	}
	overlay.alpha = 0
	overlay.hidden = false

	self.window:add_child(overlay)

	self.overlay = overlay

	local global = storage:load_global()

	if not global or not global.first_launch_time then
		self.first_launch = true
	end

	self:start_animation()
end

function screen:update(dt)
	timer:update(dt)
	self.window:update(dt)
end

function screen:destroy()
	timer:clear()
	self.window:destroy()

	self.window = nil
end

function screen:draw()
	self.window:draw()
end

function screen:keypressed(key, isrepeat)
	self:skip()
end

function screen:mousepressed(x, y, button)
	self:skip()
end

function screen:skip()
	if self.first_launch then
		log.debug("cannot skip in first launch")

		return
	end

	if self.prevent_skip then
		return
	end

	if self.skipped then
		return
	end

	log.debug("skipping...")

	self.skipped = true

	timer:clear()

	self.overlay.hidden = false
	self.overlay.alpha = 0

	timer:tween(0.25, self.overlay, {
		alpha = 1
	}, "linear", function()
		self:done()
	end)
end

function screen:done()
	local outcome = {
		splash_done = true
	}

	if KR_TARGET == "phone" then
		outcome.prevent_loading = true
	end

	self.done_callback(outcome)
end

function screen:start_animation()
	local data = features.show_splash_custom

	if not data then
		log.error("features.show_splash_custom missing!")

		return
	end

	if self.skipped then
		return
	end

	local window = self.window
	local sh = self.sh
	local sw = self.sw

	if data.image then
		local imf = table.concat({
			"_assets/_resources",
			version.bundle_id,
			data.path,
			data.image
		}, "/")

		log.error("IMAGE FILE: %s exists:%s", imf, love.filesystem.getInfo(imf))

		local imd = G.newImage(imf)
		local img = KImageView:new(imd)

		img.pos.y = sh * 0.5
		img.pos.x = sw * 0.5
		img.anchor.x = img.size.x * 0.5
		img.anchor.y = img.size.y * 0.5

		self.content:add_child(img)
	end

	if data.text_key then
		local l = GGLabel:new(V.v(sw * 0.5, sh / 4))

		l.pos = V.v(sw * 0.5, 4 * sh / 5)

		local text = _(data.text_key)

		if text == data.text_key then
			l.text = ""
		else
			l.text = text
		end

		l.font_size = 28
		l.colors.text = {
			255,
			255,
			255,
			255
		}
		l.font_name = "sans_bold"
		l.text_align = "center"
		l.vertical_align = "middle"
		l.anchor = V.v(l.size.x * 0.5, l.size.y * 0.5)

		self.content:add_child(l)
	end

	self.prevent_skip = true
	self.overlay.alpha = 1

	timer:tween(0.5, self.overlay, {
		alpha = 0
	}, "linear", function()
		self.prevent_skip = nil
	end)
	timer:after(2, function()
		timer:tween(0.5, self.overlay, {
			alpha = 1
		}, "linear", function()
			self:done()
		end)
	end)
end

return screen
