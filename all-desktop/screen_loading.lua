-- chunkname: @./all-desktop/screen_loading.lua
local log = require("lib.klua.log"):new("screen_loading")
local km = require("lib.klua.macros")
local V = require("lib.klua.vector")
local F = require("lib.klove.font_db")
local I = require("klove.image_db")
local S = require("sound_db")
local SU = require("screen_utils")
local GS = require("kr1.game_settings")
local i18n = require("i18n")

require("klove.kui")
require("gg_views_custom")
require("all.constants")

local data = require("data.director_data")
local screen = {}

screen.required_textures_base = {"loading_common"}
screen.required_textures = nil
screen.required_sounds = {"common", "music_screen_map"}
screen.ref_h = 1080
screen.ref_res = TEXTURE_SIZE_ALIAS.fullhd

function screen:update_required_textures(upcoming_item, level_idx, last_level_idx)
	local lin = data.loading_image_name
	local out = lin.default
	local idx = level_idx or last_level_idx

	if idx then
		for _, row in pairs(lin) do
			if type(row) == "table" then
				local image_name, levels = unpack(row)

				if type(levels) == "table" and table.contains(levels, idx) then
					out = image_name

					break
				end
			end
		end
	end

	self.bg_img_name = out
	self.required_textures = table.append({out}, self.required_textures_base)
end

function screen:init(w, h)
	self.done_callback = done_callback
	self.hold_enabled = not DEBUG_FAST_LOADING

	local sw, sh, scale, origin = SU.clamp_window_aspect(w, h, self.ref_w, self.ref_h)
	local window = KWindow:new(V.v(sw, sh))

	window.scale = {
		x = scale,
		y = scale
	}
	window.origin = origin
	window.colors.background = {0, 0, 0, 255}
	self.window = window

	local img = KImageView:new(self.bg_img_name)

	img.pos.x = sw * 0.5
	img.pos.y = sh * 0.5
	img.anchor.x = img.size.x * 0.5
	img.anchor.y = img.size.y * 0.5

	window:add_child(img)

	local vign = KImageView:new("loading_vignette_small")

	vign.pos.x, vign.pos.y = sw * 0.5, sh * 0.5
	vign.anchor.x, vign.anchor.y = vign.size.x * 0.5, vign.size.y * 0.5
	vign.scale = V.v(1.02 * sw / vign.size.x, 1.02 * sh / vign.size.y)

	window:add_child(vign)

	local bar_bg = KImageView:new("loading_barBg_0001")

	bar_bg.anchor.x = bar_bg.size.x * 0.5
	bar_bg.anchor.y = bar_bg.size.y
	bar_bg.pos.x, bar_bg.pos.y = bar_bg.size.x * 0.5, bar_bg.size.y

	local tips = GGLabel:new(V.v(428, 72))

	tips.text = _(string.format("TIP_%i", math.random(1, GS.gameplay_tips_count)))
	tips.font_name = "body"
	tips.font_size = 18
	tips.colors.text = {255, 255, 255, 255}
	tips.text_align = "center"
	tips.vertical_align = "middle"
	tips.line_height = i18n:cjk(1, 0.85, 1.1, 0.85)
	tips.fit_lines = 3
	tips.pos.x, tips.pos.y = 390, 18

	local bar = KImageView:new("loading_bar")

	bar.pos.x, bar.pos.y = 324, 146
	bar.scale.x = 0
	bar.last_ts = screen.window.ts

	function bar.update(this, dt)
		this.scale.x = km.clamp(0, 1, 0.6 * I.progress + 0.4 * S.progress)
		this.last_ts = screen.window.ts

		if this.scale.x >= 1 then
			screen.hold_enabled = false
		end
	end

	local bar_outline = KImageView:new("loading_barBg_0002")

	bar_outline.anchor.x = bar_outline.size.x * 0.5
	bar_outline.anchor.y = bar_outline.size.y
	bar_outline.pos.x, bar_outline.pos.y = bar_bg.size.x * 0.5, bar_bg.size.y

	local bar_view = KView:new(bar_bg.size)

	bar_view.anchor.x = bar_bg.size.x * 0.5
	bar_view.anchor.y = bar_bg.size.y
	bar_view.pos.x, bar_view.pos.y = sw * 0.5, sh

	bar_view:add_child(bar_bg)
	bar_bg:add_child(tips)
	bar_view:add_child(bar)
	bar_view:add_child(bar_outline)
	window:add_child(bar_view)

	self.bar = bar
end

function screen:destroy()
	self.window:destroy()

	self.window = nil
	self.bar = nil
end

function screen:update(dt)
	self.window:update(dt)
	return true
end

function screen:draw()
	self.window:draw()
end

function screen:keypressed(key, isrepeat)
	return
end

function screen:mousepressed(x, y, button)
	return
end

function screen:close()
	return
end

return screen
