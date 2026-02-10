-- chunkname: @./lib/klove/image_db.lua
local log = require("lib.klua.log"):new("image_db")
local G = love.graphics
local FS = love.filesystem
local perf = require("dove_modules.perf.perf")
local function is_file(path)
	local info = love.filesystem.getInfo(path)

	return info and info.type == "file"
end

require("lib.klua.table")
require("lib.klua.dump")
local function table_to_map(t)
	local m = {}

	for _, v in pairs(t) do
		m[v] = true
	end

	return m
end

-- TODO: 现在不同的 go_...lua 文件中有交叉的纹理，会导致持久化的纹理被其它图集引用计数影响而被卸载，需正规化图集整理，重新打包 go_towers，现在暂时使用不持久化 go_towers 解决问题
local persistent_textures = table_to_map({
	"go_decals",
	"go_enemies_common",
	"go_towers",
	"go_towers_pandas",
	"go_towers_dark_elf",
	"go_towers_tricannon",
	"go_towers_demon_pit",
	"go_towers_necromancer",
	"go_towers_ray",
	"go_towers_elven_stargazers",
	"go_towers_sand",
	"go_towers_royal_archers",
	"go_towers_arcane_wizard",
	"go_towers_rocket_gunners",
	"go_towers_flamespitter",
	"go_towers_ballista",
	"go_towers_barrel",
	"go_towers_hermit_toad",
	"go_towers_sparking_geode",
	"go_towers_dwarf",
	"go_towers_ghost",
	"go_towers_paladin_covenant",
	"go_towers_arborean_emissary",
	"loading_common",
	"gui_ico"
})

local km = require("lib.klua.macros")
local image_db = {}
-- 已加载的图片名称（无拓展名），为 map<string, {userdata(Image), number(width), number(height)}>
image_db.db_images = {}
-- 已加载的图集帧信息
image_db.db_atlas = {}
-- 图像组引用计数，map<string(name-scale), number>
image_db.atlas_uses = {}
image_db.load_queue = {}
image_db.load_queue_current = nil
image_db.progress = 0
image_db.groups_total = 0
image_db.groups_done = 0
image_db.missing_images = {}
image_db.missing_sprites = {}
image_db.threads = {}
image_db.image_name_queue = {}
image_db.queue_load_total_images = 0
image_db.queue_load_done_images = 0
image_db.use_canvas = true
-- by dove
image_db.supportedformats = love.graphics.getImageFormats()

local is_android = love.system.getOS() == "Android"

-- 简化版本，只基于CPU核心数
local function calculate_thread_count()
	local cpu_count = love.system.getProcessorCount() or 4
	local thread_count

	if cpu_count <= 1 then
		thread_count = 2
	elseif cpu_count <= 2 then
		thread_count = 4
	elseif cpu_count <= 4 then
		thread_count = 6
	elseif cpu_count <= 8 then
		thread_count = 8
	elseif cpu_count <= 16 then
		thread_count = 12
	else
		thread_count = 16
	end

	return thread_count
end

local function name_scale(name, scale)
	return string.format("%s-%.6f", name, scale)
end

local _MAX_THREADS = calculate_thread_count()
local _LOAD_IMAGE_THREAD_CODE = [[
local cin,cout,th_i = ...
require 'love.filesystem'
require 'love.image'
require 'love.timer'

local file_count = 0
while true do
    local fn = cin:demand()
    if fn == 'QUIT' then goto quit end
    local path = cin:demand()
    local f = path .. '/' .. fn
    local info = love.filesystem.getInfo(f)
    if (not info) or (info.type ~= "file") then
        cout:push({'ERROR','Not a file',f})
    else
        local data
        if string.match(fn, '.dds$') then
            data = love.image.newCompressedData(f)
        else
            data = love.image.newImageData(f)
        end

        if not data then
            cout:push({'ERROR','Image could not be loaded',f})
        else
            file_count = file_count + 1
            local w,h = data:getDimensions()
            local key = fn:match("(.+)%.[^.]*$") or fn
            cout:push({'OK',key,data,w,h})
        end
    end
end
::quit::
cout:supply({'DONE'})
]]

local function remove_extension_fast(filename)
	return filename:match("(.+)%.[^.]*$") or filename
end

function image_db:get_short_stats()
	local count_frames = 0
	local o = ""
	-- local list = {}

	o = o .. "Atlas frames count: "

	for k, v in pairs(self.db_atlas) do
		count_frames = count_frames + 1
	end

	o = o .. count_frames .. "\n"
	-- o = o .. "Loaded images: "

	-- for k, v in pairs(self.db_images) do
	-- 	if v[1] then
	-- 		table.insert(list, k)
	-- 	end
	-- end

	-- table.sort(list)

	-- o = o .. table.concat(list, ", ")
	o = o .. "\nTexture memory (MB): " .. love.graphics.getStats().texturememory / 1048576

	return o
end

function image_db:get_stats()
	local count_images = 0
	local count_images_MB = 0
	local count_frames = 0
	local count_images_deferred = 0
	local o = ""

	o = o .. "Loaded images ------------------\n"

	local list = {}

	for k, v in pairs(self.db_images) do
		if v[1] then
			count_images = count_images + 1
			count_images_MB = count_images_MB + v[2] * v[3] * 4 / 1048576

			table.insert(list, k .. "    " .. v[2] .. "\n")
		else
			count_images_deferred = count_images_deferred + 1
		end
	end

	table.sort(list)

	for _, row in pairs(list) do
		o = o .. row
	end

	o = o .. "\n"
	o = o .. "Atlas usage---------------------\n"

	for k, v in pairs(self.atlas_uses) do
		o = o .. k .. ":" .. v .. "\n"
	end

	for k, v in pairs(self.db_atlas) do
		count_frames = count_frames + 1
	end

	o = o .. "\n"
	o = o .. "Counts---------------------\n"
	o = o .. "Total images: " .. count_images .. " (" .. count_images_MB .. " MB)\n"
	o = o .. "Total deferred images: " .. count_images_deferred .. "\n"
	o = o .. "Total frames: " .. count_frames .. "\n"
	o = o .. "\n"
	o = o .. "love.graphics.getStats()---\n"
	o = o .. getdump(love.graphics.getStats())

	return o
end

--- 等待所有加载队列中的纹理加载完毕
function image_db:queue_load_done()
	if #self.load_queue == 0 and #self.threads == 0 then
		self.progress = 1
		self.groups_total = 0

		return true
	end

	if not self.queue_load_start_time then
		self.queue_load_start_time = love.timer.getTime()
	end

	::label_3_0::

	for i = 1, #self.load_queue do
		local item = table.remove(self.load_queue, 1)
		local ref_scale, path, name = unpack(item)
		local image_names = self:preload_atlas(ref_scale, path, name)

		if image_names then
			for n in pairs(image_names) do
				table.insert(self.image_name_queue, {n, path})

				self.queue_load_total_images = self.queue_load_total_images + 1
			end
		end
	end

	if #self.threads == 0 then
		for i = 1, math.min(#self.image_name_queue, _MAX_THREADS) do
			local th = love.thread.newThread(_LOAD_IMAGE_THREAD_CODE)
			local cin = love.thread.newChannel()
			local cout = love.thread.newChannel()

			th:start(cin, cout, i)

			if love.nx then
				th:setAffinity({false, true, true})
				log.paranoid(" ++++ IMAGE_DB THREAD %s AFFINITY %s", th, getdump(th:getAffinity()))
			end

			table.insert(self.threads, {th, cin, cout})
		end

		self.last_thread_used = 1
	end

	if #self.image_name_queue > 0 then
		for j = 1, #self.image_name_queue do
			local image_name, path = unpack(table.remove(self.image_name_queue, 1))
			local cin = self.threads[self.last_thread_used][2]

			cin:push(image_name)
			cin:push(path)

			self.last_thread_used = km.zmod(self.last_thread_used + 1, #self.threads)
		end
	end

	for i = 1, #self.threads do
		self.threads[i][2]:push("QUIT")
	end

	if not love.graphics.isActive() then
		return false
	end

	for i = #self.threads, 1, -1 do
		local th, cin, cout = unpack(self.threads[i])

		if th:isRunning() then
			local result = cout:pop()

			if result then
				local r1, r2, r3, r4, r5 = unpack(result)

				if r1 == "DONE" then
					table.remove(self.threads, i)
				elseif r1 == "ERROR" then
					log.error("Failed to load image file: %s. Error: %s", r3, r2)
				elseif r1 == "OK" then
					local key, data, w, h = r2, r3, r4, r5
					local im = G.newImage(data)

					if not im then
						log.error("Image could not be created: %s", key)
					else
						if self.use_canvas and not im:isCompressed() then
							log.paranoid(" +++ creating canvas %s", im)

							local c = G.newCanvas(w, h)

							G.setCanvas(c)
							G.setBlendMode("replace", "premultiplied")
							G.draw(im)
							G.setBlendMode("alpha", "alphamultiply")
							G.setCanvas()

							self.db_images[key] = {c, w, h}
							im = nil
						else
							log.paranoid(" +++ keeping image %s", im)

							self.db_images[key] = {im, w, h}
						end

						self.queue_load_done_images = self.queue_load_done_images + 1
					end
				end
			end
		else
			log.error("Thread %s error:%s", i, th:getError())
			table.remove(self.threads, i)
		end
	end

	if #self.threads > 0 then
		self.progress = self.queue_load_done_images / self.queue_load_total_images

		return false
	end

	if #self.load_queue > 0 then
		goto label_3_0
	end

	print("Image DB queue load done in " .. (love.timer.getTime() - self.queue_load_start_time) * 1000 .. "ms. Loaded images: " .. self.queue_load_done_images)

	self.queue_load_start_time = nil
	self.progress = 1
	self.groups_total = 0
	self.queue_load_total_images = 0
	self.queue_load_done_images = 0
	self.image_name_queue = {}

	return true
end

function image_db:queue_load_atlas(ref_scale, path, name)
	if persistent_textures[name] and self.atlas_uses[name_scale(name, ref_scale)] then
		return
	end

	table.insert(self.load_queue, {ref_scale, path, name})

	self.groups_total = self.groups_total + 1

	if #self.load_queue == 1 and not self.load_queue_current then
		self.progress = 0
		self.groups_done = 0
	end
end

function image_db:unload_atlas(name, ref_scale)
	-- 不卸载持久化纹理
	if persistent_textures[name] then
		return
	end

	ref_scale = ref_scale or 1

	local name_scale = string.format("%s-%.6f", name, ref_scale)

	if not self.atlas_uses[name_scale] then
		log.info("atlas %s does not exist", name_scale)

		return
	end

	self.atlas_uses[name_scale] = self.atlas_uses[name_scale] - 1

	if self.atlas_uses[name_scale] > 0 then
		log.debug("atlas %s still in use", name)

		return
	end

	log.debug("unloading atlas %s-%.6f", name, ref_scale)

	self.atlas_uses[name_scale] = nil

	local remove_frames = {}
	local remove_images = {}

	for k, f in pairs(self.db_atlas) do
		if f.group == name_scale then
			table.insert(remove_frames, k)

			remove_images[f.atlas] = true
		end
	end

	local removed_images_count = 0

	for k, _ in pairs(remove_images) do
		self.db_images[k] = nil
		removed_images_count = removed_images_count + 1
	end

	for _, k in pairs(remove_frames) do
		self.db_atlas[k] = nil
	end

	log.debug(" removed #frames:%s #images:%s ", #remove_frames, removed_images_count)
-- self:purge_atlas()
end

--- 检查资源，把没有 atlas 指向的纹理回收掉。需要指出，铁皮原来随便调用这个函数是非常不负责任的，因为设计合理的情况下，完全不应当重新检查资源是否清理干净！因此，不要随意使用这个函数解决问题，而是尝试找出资源泄漏的根本原因。
function image_db:purge_atlas()
	local used_images = {}

	for k, f in pairs(self.db_atlas) do
		used_images[f.atlas] = true
	end

	local remove_images = {}

	for k, v in pairs(self.db_images) do
		if not used_images[k] then
			table.insert(remove_images, k)
		end
	end

	for _, v in pairs(remove_images) do
		print("purged image:", v)
		self.db_images[v] = nil
	end
end

--- 加载图像组的全部帧信息，但不加载图像资源。帧信息实现了帧到纹理的映射。
---@param ref_scale number 图像组的渲染比例
---@param path string 图像组父目录路径
---@param name string 图像组名称（不含.lua后缀）
---@return table|nil 所有待加载的图像名称 map<string, boolean>
function image_db:preload_atlas(ref_scale, path, name)
	local name_scale = string.format("%s-%.6f", name, ref_scale)

	if self.atlas_uses[name_scale] then
		self.atlas_uses[name_scale] = self.atlas_uses[name_scale] + 1

		return
	end

	self.atlas_uses[name_scale] = 1
	self.progress = 0
	ref_scale = ref_scale or 1

	local group_file = path .. "/" .. name .. ".lua"

	if not is_file(group_file) then
		log.error("atlas file %s not found for %s/%s", group_file, path, name)

		return
	end

	local frames = FS.load(group_file)()
	local unique_frames = {}
	local image_names = {}

	-- 为每一帧设置具体信息，并处理 alias
	for _, v in pairs(frames) do
		v.group = name_scale
		-- Texture 中 x 坐标，Texture 中 y 坐标，宽度，高度，Texture 宽度，Texture 高度
		v.quad = G.newQuad(v.f_quad[1], v.f_quad[2], v.f_quad[3], v.f_quad[4], v.a_size[1], v.a_size[2])

		if is_android then
			v.a_name = v.a_name:gsub(".dds$", ".png")
		end

		image_names[v.a_name] = true

		v.atlas = remove_extension_fast(v.a_name)

		-- 允许为帧也独立定义 ref_scale
		v.ref_scale = ref_scale * (v.ref_scale or 1)

		-- alias 只有指针
		for i = 1, #v.alias do
			unique_frames[v.alias[i]] = v
		end
	end

	for k, v in pairs(unique_frames) do
		frames[k] = v
	end

	self.db_atlas = table.merge(self.db_atlas, frames)

	return image_names
end

--- 加载一张图像资源，用于少量、临时的图像加载
---@param ref_scale number 图像的渲染比例
---@param path string 图像父目录路径
---@param name string 图像组名称（不含.lua后缀）
function image_db:load_atlas(ref_scale, path, name)
	if persistent_textures[name] and self.atlas_uses[name_scale(name, ref_scale)] then
		return
	end

	local image_names = self:preload_atlas(ref_scale, path, name)

	if not image_names then
		return
	end

	local i = 0

	for fn in pairs(image_names) do
		i = i + 1

		local key, im, w, h = image_db:load_image_file(fn, path)

		self.db_images[key] = {im, w, h}
	end

	self.progress = 1
end

--- 加载图像资源的核心逻辑，属于私有方法
---@param fn string 图像文件名称
---@param path string 图像文件父目录路径
function image_db:load_image_file(fn, path)
	local f = path .. "/" .. fn

	if not is_file(f) then
		log.error("not a valid file: %s", f)

		return
	end

	if string.match(f, ".png$") or string.match(f, ".jpg$") or string.match(f, ".pkm$") or string.match(f, ".astc$") or string.match(f, ".dds$") then
		log.paranoid("  loading image file %s", f)

		local compressed = false

		if string.match(f, ".dds$") then
			compressed = true

			if is_android then
				return self:load_image_file(fn:gsub("%.dds$", ".png"), path)
			end

			-- 检查 DXT3 和 BC7 是否都不支持
			if not self.supportedformats.DXT3 then
				log.error("DDS not supported (DXT3). Fallback to PNG for %s", f)

				return nil
			end
		elseif string.match(f, ".astc$") then
			compressed = true

			if not self.supportedformats.ASTC4x4 then
				log.error("ASTC not supported. Could not load %s", f)

				return nil
			end
		elseif string.match(f, ".pkm$") then
			compressed = true

			if not self.supportedformats.ETC1 then
				log.error("ETC1 not supported. Could not load %s", f)

				return nil
			end
		end

		local im

		if compressed then
			local imd = love.image.newCompressedData(f)

			if not imd then
				log.error("Compressed image %s could not be loaded", f)

				return
			end

			im = G.newImage(imd)
		else
			im = G.newImage(f)
		end

		if not im then
			log.error("Image %s could not be created", f)
		else
			local w, h = im:getDimensions()
			local key = string.gsub(fn, ".png$", "")

			key = string.gsub(key, ".jpg$", "")
			key = string.gsub(key, ".pkm$", "")
			key = string.gsub(key, ".astc$", "")
			key = string.gsub(key, ".dds$", "")

			return key, im, w, h
		end
	end
end

--- 临时添加图像文件
---@param name string 纹理名称
---@param image userdata 纹理
---@param group string 纹理组名称
---@param scale number 纹理参考缩放比例
function image_db:add_image(name, image, group, scale)
	scale = scale or 1

	local name_scale = string.format("%s-%.6f", group, scale)
	local w, h = image:getDimensions()
	local v = {}

	v.size = {w, h}
	v.trim = {0, 0, 0, 0}
	v.a_name = name
	v.a_size = {w, h}
	v.group = name_scale
	v.quad = G.newQuad(0, 0, w, h, w, h)
	v.atlas = name
	v.ref_scale = scale
	self.db_atlas[name] = v
	self.db_images[name] = {image, w, h}

	if not self.atlas_uses[name_scale] then
		self.atlas_uses[name_scale] = 1
	end
end

--- 移除图像文件
---@param name string 纹理名称
function image_db:remove_image(name)
	self.db_images[name] = nil
	self.db_atlas[name] = nil
end

function image_db:i(name, optional)
	local i = self.db_images[name]

	if self.db_images[name] then
		if i[1] == nil and i[4] and i[5] then
			local key, im, w, h = self:load_image_file(i[4], i[5])

			self.db_images[name] = {im, w, h}

			return im, w, h
		else
			return i[1], i[2], i[3]
		end
	else
		if not name and self.missing_images["nil"] or self.missing_images[name] then
			return nil
		end

		if not optional then
			log.error("Image %s not found in the images db\n%s", name, self:get_short_stats())
		end

		self.missing_images[name or "nil"] = true

		return nil
	end
end

function image_db:s(name, optional)
	local s = self.db_atlas[name]

	if not s then
		if not name and self.missing_sprites["nil"] or self.missing_sprites[name] then
			return nil
		end

		if not optional then
			log.error("Sprite %s was not found in the atlas db.\n%s", name, self:get_short_stats())
		end

		self.missing_sprites[name or "nil"] = true

		return nil
	end

	return s
end

return image_db
