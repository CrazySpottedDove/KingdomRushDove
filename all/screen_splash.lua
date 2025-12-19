-- chunkname: @./all/screen_splash.lua
local log = require("lib.klua.log"):new("screen_splash")
local V = require("lib.klua.vector")
local F = require("lib.klove.font_db")
local FS = love.filesystem
local SU = require("screen_utils")
local PS = require("platform_services")
local timer = require("hump.timer").new()

require("klove.kui")

local storage = require("storage")
local features = require("features")
local screen = {}

screen.required_textures = {"screen_splash"}
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

	local window = KWindow:new(V.v(sw, sh))

	window.scale = {
		x = scale,
		y = scale
	}
	window.origin = origin
	window.colors.background = {0, 0, 0, 255}
	self.window = window

	local content = KView:new(V.v(sw, sh))

	self.window:add_child(content)

	self.content = content

	local overlay = KView:new(V.v(sw, sh))

	overlay.colors.background = {0, 0, 0, 255}
	overlay.alpha = 0
	overlay.hidden = true

	self.window:add_child(overlay)

	self.overlay = overlay

	local global = storage:load_global()

	if not global or not global.first_launch_time then
		self.first_launch = true
	end

	if features.splash_video_service then
		timer:after(0.1, function()
			self:play_video_hw()
		end)
	elseif features.splash_video_path then
		self:play_video_sw()
	else
		self:start_animation()
	end
end

function screen:update(dt)
	timer:update(dt)
	self.window:update(dt)

	if self.video_service and self.video_service:is_finished() then
		log.debug("video_service playback finihed!")
		self.video_service:stop()

		self.video_service = nil

		timer:after(0.25, function()
			self:start_animation()
		end)
	elseif self.video and love.timer.getTime() - self.video_start_ts > 0.5 and not self.video.video:isPlaying() then
		self.window:remove_child(self.video)

		self.video = nil

		timer:after(0.25, function()
			self:start_animation()
		end)
	end
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

	if self.skipped then
		return 
	end

	log.debug("skipping...")

	self.skipped = true

	timer:clear()

	if self.video_service then
		self.video_service:stop()

		self.video_service = nil
	end

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
	if self.skipped then
		return 
	end

	local window = self.window
	local sh = self.sh
	local sw = self.sw
	local st = storage:load_settings()
	local img = KImageView:new("logo_image")
	local iso = KImageView:new("logo_text")

	img.pos.y = sh * 0.5
	img.anchor.y = img.size.y * 0.5
	iso.pos.y = sh * 0.5
	iso.anchor.y = iso.size.y * 0.5

	self.content:add_child(img)
	self.content:add_child(iso)

	local img_shine = KImageView:new("logo_image_shine_0001")

	img_shine.animation = {
		to = 16,
		prefix = "logo_image_shine",
		from = 1
	}
	img_shine.ts = -1
	img_shine.hidden = true

	img:add_child(img_shine)

	local function end_logo_shine()
		local fade_out_duration = features.splash_fade_out_duration or 0.8

		timer:tween(fade_out_duration, img, {
			alpha = 0
		})
		timer:tween(fade_out_duration, iso, {
			alpha = 0
		})
		timer:after(fade_out_duration + 0.2, function()
			self:done()
		end)
	end

	local function start_logo_shine()
		S = require("sound_db")

		local sound_fx = love.audio.newSource(S.path .. "/files/logo_shimmer.ogg", "stream")

		sound_fx:setVolume(st and st.volume_fx or 1)
		sound_fx:play()

		img_shine.ts = 0
		img_shine.hidden = false

		timer:after(0.5666666666666667, function()
			img_shine.hidden = true
		end)
		timer:after(1.5, end_logo_shine)
	end

	img.alpha = 0
	iso.alpha = 0

	timer:tween(0.2, img, {
		alpha = 1
	})
	timer:tween(0.2, iso, {
		alpha = 1
	})

	img.scale.x = 2
	iso.scale.x = 2

	timer:tween(0.2, img.scale, {
		x = 1
	})
	timer:tween(0.2, iso.scale, {
		x = 1
	})

	local iw = math.floor(img.size.x + iso.size.x)

	img.anchor.x = img.size.x
	iso.anchor.x = 0

	local cx = self.sw * 0.5 - iw * 0.5 + img.size.x
	local pos_img_x_i = cx - img.size.x * 0.5
	local pos_img_x_f = cx - img.size.x * 0.05
	local pos_iso_x_i = cx + img.size.x * 0.5
	local pos_iso_x_f = cx + img.size.x * 0.05

	img.pos.x = pos_img_x_i
	iso.pos.x = pos_iso_x_i

	timer:tween(0.6, img.pos, {
		x = pos_img_x_f
	}, "in-bounce")
	timer:tween(0.6, iso.pos, {
		x = pos_iso_x_f
	}, "in-bounce", start_logo_shine)
end

function screen:play_video_hw()
	local aspect_list = {}

	for _, v in pairs(features.splash_video_service_items) do
		local aspect_str = string.split(v, "_")
		local parts = string.split(aspect_str[1], "x")

		table.insert(aspect_list, {tonumber(parts[1]) / tonumber(parts[2]), aspect_str[1]})
	end

	table.sort(aspect_list, function(i1, i2)
		return i1[1] < i2[1]
	end)
	log.paranoid("aspect_list: %s", getfulldump(aspect_list))

	local aspect = self.sw / self.sh
	local aspect_string = "4x3"
	local dist = 9999

	for _, v in pairs(aspect_list) do
		local this_dist = math.abs(aspect - v[1])

		if this_dist < dist then
			aspect_string = v[2]
			dist = this_dist
		end
	end

	log.debug("picked aspect %s dist:%s", aspect_string, dist)

	local orientation = "Landscape"
	local current_res = 99999
	local current_dist = 99999
	local video_name

	for _, file in pairs(features.splash_video_service_items) do
		local basename = string.sub(file, 1, #file - 4)
		local parts = string.split(basename, "_")

		log.debug("  %s %s %s w:%s", parts[1], parts[2], parts[3], self.w)

		if parts[1] ~= aspect_string then
		-- block empty
		elseif parts[2] ~= orientation then
		-- block empty
		elseif parts[3] == nil then
			video_name = file

			break
		else
			local p3 = tonumber(parts[3])
			local dist = math.abs(p3 - self.w)

			if dist < current_dist then
				current_res = p3
				current_dist = dist
				video_name = file
			end
		end
	end

	if not video_name then
		log.error("could not find video")

		return 
	else
		log.debug("found video_name: %s", video_name)
	end

	local absolute = not love.filesystem.isFused()

	if absolute then
		local parts = {"file://", KR_FULLPATH_BASE, "_assets/_resources", version.bundle_id, "splash_videos", video_name}

		video_name = table.concat(parts, "/")

		log.error("PLAYING ABSOLUTE VIDEO: %s", video_name)
	elseif features.splash_video_service_path then
		video_name = features.splash_video_service_path .. "/" .. video_name
	end

	self.video_service = PS.services[features.splash_video_service]

	self.video_service:set_video_name(video_name, absolute)
	self.video_service:play()
end

function screen:play_video_sw()
	local video_file = KR_PATH_ASSETS_ROOT .. "/" .. features.splash_video_path

	if string.sub(video_file, #video_file) == "*" then
		local video_path = string.sub(video_file, 1, #video_file - 2)
		local aspect_list = {{2.1666666666666665, "19.5x9"}, {1.7777777777777777, "16x9"}, {1.6, "16x10"}, {1.4333333333333333, "4.3x3"}, {1.3333333333333333, "4x3"}}

		log.paranoid("aspect_list: %s", getfulldump(aspect_list))

		local aspect = self.w / self.h
		local aspect_string = "4x3"
		local dist = 9999

		for _, v in pairs(aspect_list) do
			local this_dist = math.abs(aspect - v[1])

			if this_dist < dist then
				aspect_string = v[2]
				dist = this_dist
			end
		end

		log.debug("picked aspect %s dist:%s", aspect_string, dist)

		local orientation = "Landscape"
		local files = FS.getDirectoryItems(video_path)
		local current_res = 99999
		local current_dist = 99999
		local video_name

		for _, file in pairs(files) do
			local basename = string.sub(file, 1, #file - 4)
			local parts = string.split(basename, "_")

			log.debug("  %s %s %s w:%s", parts[1], parts[2], parts[3], self.sw)

			if parts[1] ~= aspect_string then
			-- block empty
			elseif parts[2] ~= orientation then
			-- block empty
			elseif parts[3] == nil then
				video_name = file

				break
			else
				local p3 = tonumber(parts[3])
				local dist = math.abs(p3 - self.sw)

				if dist < current_dist then
					current_res = p3
					current_dist = dist
					video_name = file
				end
			end
		end

		if not video_name then
			log.error("could not find video")
		else
			log.debug("found video_name: %s", video_name)
		end

		video_file = video_path .. "/" .. video_name
	end

	log.debug("loading video " .. video_file)

	self.video = KVideoView:new(video_file)

	local scale = 1
	local screen_a = self.sw / self.sh
	local video_a = self.video.size.x / self.video.size.y

	if video_a <= screen_a then
		scale = self.sw / self.video.size.x
	else
		scale = self.sh / self.video.size.y
	end

	self.video.scale = V.v(scale, scale)
	self.video.pos = V.v((self.sw - self.video.size.x * scale) * 0.5, (self.sh - self.video.size.y * scale) * 0.5)

	self.video.video:play()
	self.content:add_child(self.video)

	self.video_start_ts = love.timer.getTime()
end

return screen
