-- chunkname: @./lib/klove/font_db.lua

local log = require("klua.log"):new("font_db")
local G = love.graphics
local FS = love.filesystem

require("klua.dump")
require("klua.string")

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
	self.ascents = {}
	self.font_files = {}
	self.font_subst = {}
	self.font_adj = {}

	local path = self.path or "fonts"
	local settings_f = path .. "/" .. "font_settings.lua"
	local settings
    local info = FS.getInfo(settings_f)
	if info and info.type == "file" then
		local f, err = FS.load(settings_f)

		if err then
			log.error("Error loading settings file %s", settings_f)
		elseif f then
			settings = f()
			self.settings = settings

			log.paranoid("font settings: %s", getfulldump(settings))
		end
	else
		log.info("Font settings file could not be found at %s", settings_f)
	end

	font_sizes = font_sizes or {
		12
	}

	local font_chars = "abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?-+/():;%&`'*#=[]\\\"ÁÉÍÓÚÑáéíóúñ¿¡_<>$"
	local font_files = FS.getDirectoryItems(path)

	for i = 1, #font_files do
		local f = font_files[i]

		font_files[i] = path .. "/" .. f
	end

	for _, f in pairs(font_files) do
		if not is_file(f) then
			-- block empty
		elseif string.match(f, ".PNG$") or string.match(f, ".png$") then
			local key = string.gsub(f, ".PNG$", "")

			key = string.gsub(key, ".png$", "")
			key = string.gsub(key, "^" .. string.gsub(path, "%-", "%%-") .. "/", "")

			local font = G.newImageFont(f, font_chars)

			self.fonts[key] = font

			local image = G.newImage(f)
			local w, h = image:getDimensions()
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
		elseif string.match(f, ".TTF$") or string.match(f, ".ttf$") or string.match(f, ".otf$") or string.match(f, ".ttc$") or string.match(f, ".TTC$")then
			local key = string.gsub(f, ".TTF$", "")

			key = string.gsub(key, ".ttf$", "")
			key = string.gsub(key, ".otf$", "")
            key = string.gsub(key, ".ttc$", "")
			key = string.gsub(key, "^" .. string.gsub(path, "%-", "%%-") .. "/", "")

			if settings and settings.cache and table.contains(settings.cache, key) then
				log.debug("preloading font file data %s", f)

				self.font_files[key] = FS.newFileData(f)
			else
				self.font_files[key] = f
			end
		end
	end

	log.debug("Fonts loaded\n%s", getfulldump(self.fonts))
	log.debug("Font ascents\n%s", getfulldump(self.ascents))
end

function font_db:f(alias, size)
	local name = self.font_subst[alias] or alias
	local real_size = tonumber(self.font_adj[alias] and self.font_adj[alias].size * size or size)

	if real_size > 6 then
		real_size = math.floor(real_size + 0.5)
	end

	local name_size = name .. "-" .. real_size
	local tf = self.fonts[name_size]

	if tf then
		local fa = self:get_ascent(name_size)
		local fh = tf:getHeight()

		return tf, fh, fa
	else
		local font_file = self.font_files[name]

		if font_file then
			if self.settings and self.settings.cache_missing and type(font_file) == "string" then
				log.debug("caching font file data for %s", font_file)

				font_file = FS.newFileData(font_file)
				self.font_files[name] = font_file
			end

			log.debug("creating font %s-%s (orig size:%s) from file %s ", name, real_size, size, font_file)

			local font = G.newFont(font_file, tonumber(real_size), "light")

			self.fonts[name_size] = font

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
	local c = G.newCanvas(w + padding, h + padding)

	G.setCanvas(c)

	if debug_bg then
		G.setColor(200, 200, 200, 100)
		G.rectangle("fill", 0, 0, w + padding, h + padding)
	end

	local fadj = self:f_adj(font_name, font_size)
	local vadj = fadj["middle-caps"] or 0

	G.setFont(font)
	G.setColor(color)
	G.printf(text, padding * 0.5, vadj + padding * 0.5, w, alignment)
	G.setCanvas()

	local image_data = c:newImageData()
	local image = G.newImage(image_data)

	return image
end

function font_db:set_font_subst(orig, subst, adj)
	log.paranoid("------------------------- orig:%s subst:%s %s", orig, subst, getfulldump(adj))

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
