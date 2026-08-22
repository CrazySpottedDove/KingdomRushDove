local km = require("lib.klua.macros")
local F = require("lib.klove.font_db")
local I = require("lib.klove.image_db")
local S = require("sound_db")
local GS = require("kr1.game_settings")
local PixelArtView = require("dove_modules.gui.pixel_art_view")

require("all.constants")

local screen = {}

screen.required_textures = {}
screen.required_sounds = {}
screen.plugin_required_textures = {}
screen.plugin_required_sounds = {}
screen.ref_w = 1920
screen.ref_h = 1080
screen.ref_res = TEXTURE_SIZE_ALIAS.fullhd
screen.pixel_arts = {"_assets.kr1-desktop.pixel_art.dove"}
screen.images = {}
screen.art_layout = {
	art_type = "pixel_map",
	-- art_type = "image",
	mode = "top",
	-- mode = "fullscreen",
	alpha = 1,
	-- alpha = 0.5,
	enable_bob = true,
	-- enable_bob = false,
	enable_glow = true,
	-- enable_glow = false,
	hide_bar = false
}

-- 允许 director 在初始化 screen 时为其传入一个协程，screen 可以在加载过程中执行协程代码，从而在等待加载资源的同时完成一些初始化任务
function screen:init(w, h, director_ref)
	self.hold_enabled = true
	self.progress = {0, 0, 0}
	self.font_title = F:f("body", 34)
	self.font_percent = F:f("body", 24)
	self.font_tip = F:f("body", 20)
	self.tip = _(string.format("TIP_%i", math.random(1, GS.gameplay_tips_count)))
	self.director_ref = director_ref
	self.w = w
	self.h = h
	self.pixel_art_view = nil
	self.bg_image = nil
	if self.art_layout.art_type == "image" then
		self.bg_image = I:s(table.random(self.images))
	else
		self.pixel_art_view = PixelArtView:new(require(table.random(self.pixel_arts)))
	end
end

function screen:destroy()
	self.progress = nil
	self.font_title = nil
	self.font_percent = nil
	self.font_tip = nil
	self.tip = nil
	self.pixel_art_view = nil
end

function screen:update(dt)
	local init_coro = self.director_ref.queued_item_init_co

	-- 优先保证资源加载的并行线程启动
	local s_done = S:queue_load_done()
	local i_done = I:queue_load_done()

	-- 同时执行初始化逻辑协程，让 lua 端也不要闲着
	if init_coro and coroutine.status(init_coro) ~= "dead" then
		local ok, err = coroutine.resume(init_coro)
		if not ok then
			error("Error in loading coroutine: " .. tostring(err) .. "\n" .. debug.traceback(self.director_ref.queued_item_init_co))
		end
	end

	-- 加载完成之后，再更新动画状态，保证动画状态是最新的
	if self.pixel_art_view then
		self.pixel_art_view:update(dt)
	end
	-- print("Loading progress: ", I.progress, S.progress, self.progress)
	-- print("Corotine status: ", init_coro and coroutine.status(init_coro) or "no coroutine")
	self.progress[1] = I.progress
	self.progress[2] = S.progress
	self.progress[3] = (init_coro and coroutine.status(init_coro) ~= "dead") and (self.director_ref.queued_item.progress or 0) or 1

	-- 检查工作是否已经完成
	if i_done and s_done then
		-- 没有初始化协程，那就结束
		if not init_coro then
			self.hold_enabled = false
		else
			-- 有初始化协程，需要保证初始化协程也已经结束
			if coroutine.status(init_coro) == "dead" then
				self.hold_enabled = false
				-- 执行剩余的必须在资源加载完后执行的 init 工作
				self.director_ref.queued_item:init(self.w, self.h)
				self.director_ref.queued_item_init = true
				self.director_ref.queued_item.done_callback_called = nil
			end
		end
	end

	return true
end

function screen:draw()
	local g = love.graphics
	local w, h = g.getDimensions()
	local a = 1
	local old_font = g.getFont()
	local font_title = self.font_title or old_font
	local font_percent = self.font_percent or old_font
	local font_tip = self.font_tip or old_font

	for y = 0, h do
		local t = y / h
		g.setColor(0.12 - 0.04 * t, 0.14 - 0.04 * t, 0.18 - 0.03 * t, a)
		g.rectangle("fill", 0, y, w, 1)
	end

	local layout = self.art_layout
	local sprite_alpha = (layout.alpha or 1) * a

	if self.bg_image then
		local ss = self.bg_image
		local img = I:i(ss.atlas)
		local iw, ih = ss.size[1] * ss.ref_scale, ss.size[2] * ss.ref_scale
		local scale = layout.mode == "fullscreen" and math.max(w / iw, h / ih) or math.min(w / iw, h / ih)
		local sw, sh = iw * scale, ih * scale
		g.setColor(1, 1, 1, sprite_alpha)
		g.draw(img, ss.quad, math.floor((w - sw) * 0.5), math.floor((h - sh) * 0.5), 0, scale, scale)
	else
		local dove = self.pixel_art_view
		local native_w, native_h = dove:get_native_size()
		dove.enable_bob = layout.enable_bob ~= false
		dove.enable_glow = layout.enable_glow ~= false

		local scale, sprite_x, sprite_y
		if layout.mode == "fullscreen" then
			scale = math.min(w / native_w, h / native_h)
			sprite_x = math.floor((w - native_w * scale) * 0.5)
			sprite_y = math.floor((h - native_h * scale) * 0.5)
		else
			local max_w = math.floor(w * 0.6)
			local max_h = math.floor(h * 0.35)
			scale = math.max(3, math.min(math.floor(max_w / native_w), math.floor(max_h / native_h)))
			sprite_x = math.floor((w - native_w * scale) * 0.5)
			sprite_y = math.floor(h * 0.28 - native_h * scale * 0.5)
		end
		dove.pixel_scale = scale
		dove:draw_at(sprite_x, sprite_y, scale, sprite_alpha)
	end

	local hide_bar = layout.hide_bar
	local bar_w = math.floor(math.min(740, w * 0.68))
	local bar_h = math.max(14, math.floor(h / 48))
	local bar_gap = math.max(12, math.floor(bar_h * 0.75))
	local label_w = 92
	local side_gap = 10
	local total_h = bar_h * 3 + bar_gap * 2
	local pct_w = math.max(88, font_percent:getWidth("100%") + 8)
	local bar_x = math.floor((w - (label_w + side_gap + bar_w + side_gap + pct_w)) * 0.5) + label_w + side_gap
	local title_y = math.floor(h * 0.45)
	local bar_y = math.floor(h * 0.52)

	if not hide_bar then
		local labels = {_("IMAGE"), _("SOUND"), _("CORO")}
		local colors = {{0.44, 0.74, 1.0}, {0.56, 0.92, 0.56}, {0.92, 0.54, 0.21}}
		for i = 1, 3 do
			local y = bar_y + (i - 1) * (bar_h + bar_gap)
			local inner_w = bar_w - 4
			local progress = self.progress[i]
			local fill_w = inner_w * progress

			local c = colors[i]
			g.setColor(0.08, 0.08, 0.10, a)
			g.rectangle("fill", bar_x, y, bar_w, bar_h)
			g.setColor(0.22, 0.22, 0.26, a)
			g.rectangle("line", bar_x, y, bar_w, bar_h)

			if fill_w > 0 then
				g.setColor(c[1], c[2], c[3], a)
				g.rectangle("fill", bar_x + 2, y + 2, fill_w, bar_h - 4)
			end

			g.setFont(font_tip)
			g.setColor(0.9, 0.92, 0.96, a)
			g.printf(labels[i], bar_x - label_w - side_gap, y + math.floor((bar_h - font_tip:getHeight()) * 0.5), label_w, "right")

			g.setFont(font_percent)
			local pct_text = string.format("%d%%", math.floor(progress * 100 + 0.5))
			local pct_x = bar_x + bar_w + side_gap + pct_w - font_percent:getWidth(pct_text)
			g.print(pct_text, pct_x, y + math.floor((bar_h - font_percent:getHeight()) * 0.5))
		end
	end
	local title = "Loading..."
	local title_w = font_title:getWidth(title)

	g.setFont(font_title)
	g.setColor(1, 1, 1, a)
	g.print(title, math.floor((w - title_w) * 0.5), title_y)

	g.setFont(font_tip)
	g.setColor(0.82, 0.86, 0.92, a)
	g.printf(self.tip, math.floor(w * 0.1), bar_y + total_h + 12, math.floor(w * 0.8), "center")
	g.setFont(old_font)
end

function screen:keypressed(key, isrepeat)
	return
end

function screen:mousepressed(x, y, button)
	return
end

return screen
