require("klove.kui")
local class = require("middleclass")
local G = love.graphics

local PixelArtView = class("PixelArtView", KView)

PixelArtView.DEFAULT_PALETTE = {
	[1] = {186, 173, 154},
	[2] = {159, 142, 119},
	[3] = {197, 93, 39},
	[4] = {105, 95, 80},
	[5] = {204, 64, 16},
	[6] = {89, 65, 40},
	[7] = {67, 52, 35},
	[8] = {54, 39, 21},
	[9] = {54, 27, 11},
	[10] = {34, 24, 13},
	[11] = {30, 21, 12},
	[12] = {28, 18, 9},
	[13] = {20, 13, 6}
}

function PixelArtView:initialize(pixel_art)
	KView.initialize(self, nil)
	self.pixel_map = pixel_art.pixel_map or {}
	self.palette = pixel_art.pixel_palette or PixelArtView.DEFAULT_PALETTE
	self._native_w = #self.pixel_map[1] or 0
	self._native_h = #self.pixel_map
	self.pixel_scale = 3
	self.color = {1, 1, 1}
	self.alpha = 1
	self.anim_t = 0
	self.phase = 0
	self.enable_glow = true
	self.glow_interval = 11
	self.glow_amount = 18
	self.enable_bob = true
	self.bob_speed = 2.8
	self.bob_amplitude = 1
end

function PixelArtView:set_pixel_map(map)
	self.pixel_map = map
	self._native_w = #map[1]
	self._native_h = #map
end

function PixelArtView:set_palette(palette)
	self.palette = palette
end

function PixelArtView:set_pixel_scale(scale)
	self.pixel_scale = math.max(1, scale)
end

function PixelArtView:get_sprite_size()
	return self._native_w * self.pixel_scale, self._native_h * self.pixel_scale
end

function PixelArtView:get_native_size()
	return self._native_w, self._native_h
end

function PixelArtView:update(dt)
	PixelArtView.super.update(self, dt)
	self.anim_t = self.anim_t + dt
	self.phase = math.floor(self.anim_t * 14)
end

function PixelArtView:draw_at(x, y, scale, alpha)
	scale = scale or self.pixel_scale
	alpha = alpha or self.alpha

	local bob_y = 0
	if self.enable_bob then
		bob_y = math.floor(math.sin(self.anim_t * self.bob_speed) * scale * self.bob_amplitude)
	end

	for row_idx, row in ipairs(self.pixel_map) do
		for col_idx = 1, #row do
			local pixel = tonumber(row:sub(col_idx, col_idx), 16)
			local color = self.palette[pixel]
			if color then
				local r, g, b = color[1], color[2], color[3]
				if self.enable_glow and (col_idx + row_idx + self.phase) % self.glow_interval == 0 then
					r = math.min(255, r + self.glow_amount)
					g = math.min(255, g + self.glow_amount)
					b = math.min(255, b + self.glow_amount)
				end
				G.setColor(r / 255 * self.color[1], g / 255 * self.color[2], b / 255 * self.color[3], alpha)
				G.rectangle("fill", x + (col_idx - 1) * scale, y + (row_idx - 1) * scale + bob_y, scale, scale)
			end
		end
	end
end

function PixelArtView:_draw_self()
	local w, h = self:get_size()
	if w == 0 or h == 0 then
		w, h = G.getDimensions()
	end
	local _, _, _, pa = G.getColor()
	if self._native_w == 0 then
		return
	end
	local scale = math.min(w / self._native_w, h / self._native_h)
	self:draw_at(math.floor((w - self._native_w * scale) * 0.5), math.floor((h - self._native_h * scale) * 0.5), scale, pa)
end

return PixelArtView
