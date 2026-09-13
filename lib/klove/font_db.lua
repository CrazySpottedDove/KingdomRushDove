-- chunkname: @./lib/klove/font_db.lua
local log = require("lib.klua.log"):new("font_db")
local G = love.graphics
local FS = love.filesystem

require("lib.klua.dump")
require("lib.klua.string")

local font_db = {}

function font_db:init(path)
	self.path = path
end

local function is_file(path)
	local info = love.filesystem.getInfo(path)

	return info and info.type == "file"
end

function font_db:load(font_sizes)
	self.fonts = {}
	self.ttf_fonts = {}
	self.fallback_font_names = {}
	self.ascents = {}
	self.font_files = {}
	self.font_subst = {}
	self.font_adj = {}

	local path = self.path or "fonts"

	font_sizes = font_sizes or {12}

	local font_chars = "abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?-+/():;%&`'*#=[]\\\"ÁÉÍÓÚÑáéíóúñ¿¡_<>$"
	local font_files = FS.getDirectoryItems(path)

	for i = 1, #font_files do
		local f = font_files[i]

		font_files[i] = path .. "/" .. f
	end

	for _, f in ipairs(font_files) do
		if not is_file(f) then
		-- block empty
		elseif string.match(f, ".PNG$") or string.match(f, ".png$") then
			local key = string.gsub(f, ".PNG$", "")

			key = string.gsub(key, ".png$", "")
			key = string.gsub(key, "^" .. string.gsub(path, "%-", "%%-") .. "/", "")

			local font = G.newImageFont(f, font_chars)

			self.fonts[key] = font

			local image = G.newImage(f)
			local _, h = image:getDimensions()
			local data = image:getData()
			local sr, sg, sb, sa

			for y = 0, h - 1 do
				local r, g, b, a = data:getPixel(0, y)

				if not sr then
					sr, sg, sb, sa = r, g, b, a
				elseif sr ~= r or sg ~= g or sb ~= b or sa ~= a then
					self.ascents[key] = y

					break
				end
			end
		elseif string.match(f, ".TTF$") or string.match(f, ".ttf$") or string.match(f, ".otf$") or string.match(f, ".ttc$") or string.match(f, ".TTC$") then
			local key = string.gsub(f, ".TTF$", "")

			key = string.gsub(key, ".ttf$", "")
			key = string.gsub(key, ".otf$", "")
			key = string.gsub(key, ".ttc$", "")
			key = string.gsub(key, "^" .. string.gsub(path, "%-", "%%-") .. "/", "")

			self.font_files[key] = f
		end
	end

	if DEBUG then
		log.debug("Fonts loaded\n%s", getfulldump(self.fonts))
		log.debug("Font ascents\n%s", getfulldump(self.ascents))
	end
end

--[[
	缺失字形回退字体。

	主字体（尤其是英文环境下的 Comic Book Italic / TOONISH）只含拉丁字形，
	一旦文本里出现中文字符（例如插件作者名、插件说明、中文自定义关卡名）或者
	→ ← 这类符号，就会整段渲染成空白。这里给每个字体挂上含 CJK 的回退字体，
	由 LOVE（>= 11.4 的 Font:setFallbacks）按字形逐个回退。

	用法：font_db:set_fallback_fonts({"msyh", "NotoSansCJKkr-Regular"})
	（名字是字体文件去掉扩展名后的 key，必须在 font_db:load() 之后调用）
]]
function font_db:set_fallback_fonts(names)
	self.fallback_font_names = names or {}

	for _, v in pairs(self.ttf_fonts or {}) do
		self:apply_fallbacks(v.font, v.size)
	end
end

--- 取（并缓存）某个字号的回退字体列表
function font_db:get_fallback_fonts(size)
	local names = self.fallback_font_names

	if not names or #names == 0 or not self.font_files then
		return nil
	end

	local list = {}

	for i = 1, #names do
		local n = names[i]
		local font_file = self.font_files[n]

		if font_file then
			local key = "fallback:" .. n .. "-" .. size
			local f = self.fonts[key]

			if not f then
				f = G.newFont(font_file, size, "light")

				self.fonts[key] = f
			end

			list[#list + 1] = f
		end
	end

	if #list == 0 then
		return nil
	end

	return list
end

--- 给一个字体挂上回退字体（旧版 LOVE 没有 setFallbacks 时静默跳过）
function font_db:apply_fallbacks(font, size)
	if not (font and font.setFallbacks) then
		return
	end

	local list = self:get_fallback_fonts(size)

	if list then
		font:setFallbacks(unpack(list))
	end
end

--- LOVE 内置默认字体（Vera Sans，无 CJK）的带回退版本，供调试/工具界面使用
function font_db:default_font(size)
	size = math.max(tonumber(size) or 12, 1)

	local key = "default:" .. size
	local f = self.fonts[key]

	if not f then
		f = G.newFont(size)

		self.fonts[key] = f
		self:apply_fallbacks(f, size)
	end

	return f
end

function font_db:f(alias, size)
	local name = self.font_subst[alias] or alias
	local real_size = tonumber(self.font_adj[alias] and self.font_adj[alias].size * size or size)

	if real_size > 6 then
		real_size = math.floor(real_size + 0.5)
	end

	-- 避免 real_size 为 0 导致错误
	real_size = math.max(real_size, 1)

	local name_size = name .. "-" .. real_size
	local tf = self.fonts[name_size]

	if tf then
		local fa = self:get_ascent(name_size)
		local fh = tf:getHeight()

		return tf, fh, fa
	else
		local font_file = self.font_files[name]

		if font_file then
			log.debug("creating font %s-%s (orig size:%s) from file %s ", name, real_size, size, font_file)

			local font = G.newFont(font_file, real_size, "light")

			self.fonts[name_size] = font
			self.ttf_fonts[name_size] = {
				font = font,
				size = real_size
			}

			self:apply_fallbacks(font, real_size)

			local fa = self:get_ascent(name_size)
			local fh = font:getHeight()

			return font, fh, fa
		else
			log.error("Font %s not found", name)
		end
	end
end

function font_db:get_ascent(name)
	if self.ascents[name] then
		return self.ascents[name]
	else
		return self.fonts[name]:getHeight()
	end
end

function font_db:create_text_image(text, size, alignment, font_name, font_size, color, line_height, scale, fit_height, debug_bg)
	-- 修复Android高DPI问题：
	-- 在高DPI设备上，love.graphics.newCanvas()可能会创建更大的Canvas
	-- 需要除以DPI来补偿，确保Canvas大小正确
	local dpi_scale = love.window.getDPIScale()
	local dpi_compensation = 1.0

	-- 只在Android且DPI>1时应用补偿
	if love.system.getOS() == "Android" and dpi_scale > 1.0 then
		dpi_compensation = dpi_scale
	end

	if scale and scale ~= 1 then
		font_size = math.floor(font_size / scale)
		size.x = math.ceil(size.x / scale)
		size.y = math.ceil(size.y / scale)
	end

	line_height = line_height or 1

	local font, w, lines, h
	local step = 0.5

	while step < font_size do
		font = self:f(font_name, font_size)
		w, lines = font:getWrap(text, size.x)
		h = font:getHeight() * (1 + math.max(#lines - 1, 0) * line_height)

		if not fit_height or h <= size.y then
			break
		end

		font_size = font_size - step
	end

	font:setLineHeight(line_height)

	local padding = 8
	-- 应用DPI补偿到Canvas大小
	local canvas_w = math.ceil((w + padding) / dpi_compensation)
	local canvas_h = math.ceil((h + padding) / dpi_compensation)
	local c = G.newCanvas(canvas_w, canvas_h)

	G.setCanvas(c)

	-- 在Canvas内部也需要调整坐标来补偿DPI
	if dpi_compensation > 1 then
		G.push()
		G.scale(1 / dpi_compensation, 1 / dpi_compensation)
	end

	if debug_bg then
		G.setColor(0.784, 0.784, 0.784, 0.392)
		G.rectangle("fill", 0, 0, w + padding, h + padding)
	end

	local fadj = self:f_adj(font_name, font_size)
	local vadj = fadj["middle-caps"] or 0

	G.setFont(font)
	G.setColor_old(color)
	G.printf(text, padding * 0.5, vadj + padding * 0.5, w, alignment)

	if dpi_compensation > 1 then
		G.pop()
	end

	G.setCanvas()

	local image_data = c:newImageData()
	local image = G.newImage(image_data)

	return image
end

function font_db:set_font_subst(orig, subst, adj)
	if DEBUG then
		log.paranoid("------------------------- orig:%s subst:%s %s", orig, subst, getfulldump(adj))
	end

	self.font_subst[orig] = subst
	self.font_adj[orig] = adj or {
		size = 1
	}

	local to_clean = {}

	for k, v in pairs(self.fonts) do
		if string.find(k, subst, 1, true) then
			table.insert(to_clean, k)
		end
	end

	for _, k in pairs(to_clean) do
		self.fonts[k] = nil
	end
end

function font_db:f_adj(alias, size)
	local fm = {}

	if self.font_adj[alias] then
		local f_size = self.font_adj[alias].size or 1

		for k, v in pairs(self.font_adj[alias]) do
			if k == "top" then
				fm[k] = (0.5 * (1 - f_size) + v * f_size) * size
			elseif k == "middle" then
				fm[k] = v * size * f_size
			elseif k == "middle-caps" then
				fm[k] = v * size * f_size
			elseif k == "bottom" then
				local font = self:f(alias, size)
				local des = font and font:getDescent() or 0.3
				local h = font and font:getHeight() or 1

				fm[k] = (-des / h * (f_size - 1) + v) * size
			elseif k == "bottom-caps" then
				local font = self:f(alias, size)
				local des = font and font:getDescent() or 0.3
				local h = font and font:getHeight() or 1

				fm[k] = (-des / h * (f_size - 1) + v * f_size) * size
			elseif k == "base" then
				fm[k] = v * size * f_size
			end
		end
	end

	return fm
end

return font_db
