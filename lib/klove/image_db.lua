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
local atlas_binary = require("lib.klove.atlas_binary")
local ffi = require("ffi")
local bit = require("bit")

local extension_name = IS_ANDROID and ".abin" or ".bin"

local km = require("lib.klua.macros")
local image_db = {}
-- 缓存纹理，这些纹理只要进局内肯定会需要加载，就不重复加载卸载了
image_db.persistent_textures = table.to_map({
	-- game
	"go_decals",
	"go_enemies_common",
	"go_editor",
	"go_towers_ray",
	"go_towers_elven_stargazers",
	"go_towers_group1",
	"go_towers_group2",
	"go_towers_group3",
	"go_towers_group4",
	"go_towers_group5",
	"go_towers_group6",
	"go_towers_group7",
	"go_towers_group8",
	"go_towers_group9",
	"go_towers_group10",
	"go_towers_group11",
	"go_towers_group12",
	"go_towers_group13",
	"go_towers_group14",
	"go_towers_group15",
	"go_towers_group16",
	"go_towers_group17",
	"go_towers_group18",
	"go_towers_group19",
	"go_towers_group20",
	"go_towers_group21",
	"go_towers_group22",
	"go_towers_group23",
	"go_towers_group24",
	"go_towers_group25",
	"go_stage128",
	"tower_holders",
	-- game_gui
	"gui_common",
	"gui_ico",
	"gui_portraits",
	-- "achievements",
	"encyclopedia_creeps",
	"gui_notifications",
	"gui_notifications_bg",
	"ballon"
-- TODO: view_options 不可加入该缓存列表，因为两个scene的scale不一样，目前暂未处理
})
-- 已加载的图片名称（无拓展名），为 map<string, {userdata(Image), number(width), number(height)}>
image_db.db_images = {}
-- 已加载的图集帧信息，map<frame_name, frame_id>。
-- 插件不要直接写这个表，请使用 add_frame / add_frame_table / add_image / queue_load_image。
image_db.db_atlas = {}
-- 图像组引用计数，map<group_id, number>
image_db.atlas_uses = {}
-- 原始图像文件引用计数，map<atlas_id, number>。不同图集可能引用同一张图片，释放时需确保没有其他图集在使用。
image_db.image_uses = {}
image_db.load_queue = {}
image_db.load_queue_current = nil
image_db.progress = 0
image_db.missing_images = {}
image_db.missing_sprites = {}
image_db.threads = {}
image_db.image_name_queue = {}
image_db.image_path_queue = {}
image_db._queue_image_info = {}
image_db.queue_load_total_images = 0
image_db.queue_load_done_images = 0

-- by dove
image_db.supportedformats = love.graphics.getImageFormats()

-- 帧数据使用紧凑 FFI 数组存储；atlas/group 使用数字 id，需要字符串时通过注册表还原。
-- 结构体字段读取在 LuaJIT 中会直接转成 Lua number；trim/size 为 0-based C 数组。
ffi.cdef[[
typedef struct {
	float ref_scale;
	uint32_t atlas_id;
	uint32_t group_id;
	uint32_t id;
	uint32_t generation;
	uint16_t trim[2];
	uint16_t size[2];
} FrameData;
]]

-- 帧数据按固定大小块分配，避免一次性预分配固定容量后溢出。
-- 块一旦创建就不会移动，因此 s.ss / animation link 持有的 cdata 引用始终有效。
-- 约定：所有 frame id 必须由调用方保证有效；接口本身不做运行期校验。
local BLOCK_SHIFT = 12
local BLOCK_SIZE = bit.lshift(1, BLOCK_SHIFT)
local BLOCK_MASK = BLOCK_SIZE - 1
-- local MAX_FRAME_ID = 0x7FFFFFFF
local atlas_ids = {}
local atlas_names = {}
local group_ids = {}
local group_names = {}
local next_atlas_id = 0
local next_group_id = 0

local function intern_atlas(name)
	local id = atlas_ids[name]
	if id then
		return id
	end
	next_atlas_id = next_atlas_id + 1
	id = next_atlas_id
	atlas_ids[name] = id
	atlas_names[id] = name
	return id
end

local function intern_group(name)
	local id = group_ids[name]
	if id then
		return id
	end
	next_group_id = next_group_id + 1
	id = next_group_id
	group_ids[name] = id
	group_names[id] = name
	return id
end

local quads = {}
local free_frame_ids = {}
local frame_blocks = {}
local next_frame_slot = 0

local function get_frame(id)
	local slot = id - 1
	return frame_blocks[bit.rshift(slot, BLOCK_SHIFT) + 1][bit.band(slot, BLOCK_MASK)]
end

local function alloc_frame_id()
	local n = #free_frame_ids
	if n > 0 then
		local id = free_frame_ids[n]
		free_frame_ids[n] = nil
		return id
	end
	-- if next_frame_slot >= MAX_FRAME_ID then
	-- 	local msg = string.format("image_db frame id exhausted (max=%d). This usually means a plugin is leaking frames.\n%s", MAX_FRAME_ID, debug.traceback())
	-- 	log.error(msg)
	-- 	error(msg)
	-- end
	local block_index = bit.rshift(next_frame_slot, BLOCK_SHIFT) + 1
	if not frame_blocks[block_index] then
		frame_blocks[block_index] = ffi.new("FrameData[?]", BLOCK_SIZE)
	end
	next_frame_slot = next_frame_slot + 1
	return next_frame_slot
end

ffi.metatype("FrameData", {
	__index = function(self, k)
		if k == "atlas" then
			return atlas_names[self.atlas_id]
		elseif k == "group" then
			return group_names[self.group_id]
		elseif k == "quad" then
			return quads[self.id]
		end
	end
})

local function fill_frame(id, atlas_id, group_id, ref_scale, tx, ty, w, h, quad)
	local f = get_frame(id)
	f.ref_scale = ref_scale or 1
	f.atlas_id = atlas_id
	f.group_id = group_id
	f.id = id
	f.generation = f.generation + 1
	f.trim[0] = tx or 0
	f.trim[1] = ty or 0
	f.size[0] = w or 0
	f.size[1] = h or 0
	quads[id] = quad
end

local function free_frame_id(id)
	local f = get_frame(id)
	f.ref_scale = 1
	f.atlas_id = 0
	f.group_id = 0
	f.id = 0
	f.trim[0] = 0
	f.trim[1] = 0
	f.size[0] = 0
	f.size[1] = 0
	quads[id] = nil
	free_frame_ids[#free_frame_ids + 1] = id
end

image_db.frame_blocks = frame_blocks
image_db.quads = quads
image_db.atlas_ids = atlas_ids
image_db.atlas_names = atlas_names
image_db.group_ids = group_ids
image_db.group_names = group_names

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
        if string.match(fn, '.dds$') or string.match(fn, '.astc$') or string.match(fn, '.pkm$') then
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

---只加载 .lua 源码图集的帧信息，不加载纹理
---@param ref_scale number 渲染缩放比例
---@param path string 图集所在目录
---@param name string 图集名称
---@return table|nil 待加载图片名集合；已加载或其他错误时返回 nil
local function preload_atlas_lua(self, ref_scale, path, name)
	ref_scale = ref_scale or 1
	local name_scale = string.format("%s-%.6f", name, ref_scale)
	local group_id = intern_group(name_scale)

	if self.atlas_uses[group_id] then
		self.atlas_uses[group_id] = self.atlas_uses[group_id] + 1

		return
	end

	self.atlas_uses[group_id] = 1
	self.progress = 0

	local group_file = path .. "/" .. name .. ".lua"
	local frames = FS.load(group_file)()
	local image_names = {}

	-- 为每一帧设置具体信息，并处理 alias
	for k, v in pairs(frames) do
		-- Android 端：自动选择实际存在的格式（ASTC > PNG > DDS）
		if IS_ANDROID then
			if v.a_name:match("%.dds$") then
				local astc_name = v.a_name:gsub("%.dds$", ".astc")

				if is_file(path .. "/" .. astc_name) then
					v.a_name = astc_name
				else
					local png_name = v.a_name:gsub("%.dds$", ".png")

					if is_file(path .. "/" .. png_name) then
						v.a_name = png_name
					end
				end
			elseif v.a_name:match("%.png$") then
				local astc_name = v.a_name:gsub("%.png$", ".astc")

				if is_file(path .. "/" .. astc_name) then
					v.a_name = astc_name
				end
			-- 都不存在则保留 .dds 或 .png，后续会报错
			end
		end

		image_names[v.a_name] = true
		local atlas_name = remove_extension_fast(v.a_name)
		local atlas_id = intern_atlas(atlas_name)
		self.image_uses[atlas_id] = (self.image_uses[atlas_id] or 0) + 1

		local id = alloc_frame_id()
		fill_frame(id, atlas_id, group_id, ref_scale * (v.ref_scale or 1), v.trim[1], v.trim[2], v.size[1], v.size[2], G.newQuad(v.f_quad[1], v.f_quad[2], v.f_quad[3], v.f_quad[4], v.a_size[1], v.a_size[2]))
		self.db_atlas[k] = id

		-- alias 只有指针
		if v.alias then
			for i = 1, #v.alias do
				self.db_atlas[v.alias[i]] = id
			end
		end
	end

	return image_names
end

---只加载 .bin/.abin 图集的帧信息，不加载纹理
---@param ref_scale number 渲染缩放比例
---@param path string 图集所在目录
---@param name string 图集名称
---@return table|nil 待加载图片名集合；已加载或其他错误时返回 nil
local function preload_atlas_binary(self, ref_scale, path, name)
	ref_scale = ref_scale or 1
	local name_scale = string.format("%s-%.6f", name, ref_scale)
	local group_id = intern_group(name_scale)

	if self.atlas_uses[group_id] then
		self.atlas_uses[group_id] = self.atlas_uses[group_id] + 1

		return
	end

	self.atlas_uses[group_id] = 1
	self.progress = 0

	local group_file = path .. "/" .. name .. extension_name

	local data = FS.read(group_file)
	if not data then
		log.error("Failed to load atlas data: %s", group_file)
		return
	end
	if not atlas_binary.is_binary(data) then
		log.error("Invalid atlas data: %s", group_file)
		return
	end
	local info = atlas_binary.unpack(data)

	local image_names = {}

	for i = 1, info.count do
		local v = info.values[i]
		image_names[v[1]] = true
		local atlas_name = remove_extension_fast(v[1])
		local atlas_id = intern_atlas(atlas_name)
		self.image_uses[atlas_id] = (self.image_uses[atlas_id] or 0) + 1

		local id = alloc_frame_id()
		fill_frame(id, atlas_id, group_id, ref_scale * v[4], v[3][1], v[3][2], v[5][1], v[5][2], G.newQuad(v[2][1], v[2][2], v[2][3], v[2][4], v[2][5], v[2][6]))
		self.db_atlas[info.keys[i]] = id

		-- alias
		if v[6] then
			for j = 1, #v[6] do
				self.db_atlas[v[6][j]] = id
			end
		end
	end

	return image_names
end

---加载单个纹理文件（内部接口）
---@param fn string 图片文件名
---@param path string 图片所在目录
---@return string|nil 图集页名称
---@return userdata|nil LÖVE Image
---@return number|nil 宽度
---@return number|nil 高度
local function load_image_file(self, fn, path)
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

			-- Android 端应该已在 preload_atlas 中转换为 .astc 或 .png，此处为容错
			if IS_ANDROID then
				local astc_fn = fn:gsub("%.dds$", ".astc")
				if is_file(path .. "/" .. astc_fn) then
					return load_image_file(self, astc_fn, path)
				end

				local png_fn = fn:gsub("%.dds$", ".png")
				if is_file(path .. "/" .. png_fn) then
					return load_image_file(self, png_fn, path)
				end

				log.error("No Android-compatible format found for %s (tried .astc, .png)", f)
				return nil
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

---返回简短图集统计文本
---@param self table image_db
---@return string 帧数量和纹理内存
local function get_short_stats(self)
	local count_frames = 0
	local o = "Atlas frames count: "

	for _ in pairs(self.db_atlas) do
		count_frames = count_frames + 1
	end

	o = o .. count_frames .. "\n"
	o = o .. "\nTexture memory (MB): " .. love.graphics.getStats().texturememory / 1048576

	return o
end

--==加载与卸载==

---将单张图片加入异步加载队列
---@param sprite_name string 注册后的帧名称
---@param a_name string 图片文件名（含扩展名）
---@param path string 图片所在目录
---@param group string 图集组名称
---@param scale number 渲染缩放比例
---@return nil
function image_db:queue_load_image(sprite_name, a_name, path, group, scale)
	local key = remove_extension_fast(a_name)
	if self._queue_image_info[key] or self.db_atlas[sprite_name] then
		return
	end
	self._queue_image_info[key] = {
		group = group,
		scale = scale,
		sprite_name = sprite_name
	}
	local insert_index = #self.image_name_queue + 1
	self.image_name_queue[insert_index] = a_name
	self.image_path_queue[insert_index] = path
	self.queue_load_total_images = self.queue_load_total_images + 1
end

---将图集加入异步加载队列
---@param ref_scale number 渲染缩放比例
---@param path string 图集所在目录
---@param name string 图集名称
---@param not_binary boolean? true 加载 .lua 源码，false/nil 加载 .bin/.abin
---@return nil
function image_db:queue_load_atlas(ref_scale, path, name, not_binary)
	local loaded_group_id = group_ids[name_scale(name, ref_scale)]
	if self.persistent_textures[name] and loaded_group_id and self.atlas_uses[loaded_group_id] then
		return
	end

	table.insert(self.load_queue, {ref_scale, path, name, not_binary})

	if #self.load_queue == 1 and not self.load_queue_current then
		self.progress = 0
	end
end

---推进异步图集/图片加载队列
---@return boolean 是否全部加载完成
function image_db:queue_load_done()
	if #self.load_queue == 0 and #self.threads == 0 and #self.image_name_queue == 0 then
		self.progress = 1

		return true
	end

	local load_queue_length = #self.load_queue

	for i = load_queue_length, 1, -1 do
		local item = self.load_queue[i]
		self.load_queue[i] = nil

		-- 不要删掉这行，这真是注释：local ref_scale, path, name = unpack(item)
		local image_names
		if item[4] then
			image_names = preload_atlas_lua(self, item[1], item[2], item[3])
		else
			image_names = preload_atlas_binary(self, item[1], item[2], item[3])
		end

		if image_names then
			for n in pairs(image_names) do
				local insert_index = #self.image_name_queue + 1
				self.image_name_queue[insert_index] = n
				self.image_path_queue[insert_index] = item[2]
				self.queue_load_total_images = self.queue_load_total_images + 1
			end
		end
	end

	if #self.image_name_queue > 0 then
		local thread_count = math.min(_MAX_THREADS, #self.image_name_queue)
		for i = 1, thread_count do
			local th = love.thread.newThread(_LOAD_IMAGE_THREAD_CODE)
			local cin = love.thread.newChannel()
			local cout = love.thread.newChannel()

			th:start(cin, cout, i)
			self.threads[i] = {th, cin, cout}
		end

		local last_thread_used = 1

		for j = #self.image_name_queue, 1, -1 do
			local cin = self.threads[last_thread_used][2]
			cin:push(self.image_name_queue[j])
			cin:push(self.image_path_queue[j])
			self.image_name_queue[j] = nil
			self.image_path_queue[j] = nil

			last_thread_used = km.zmod(last_thread_used + 1, thread_count)
		end

		for i = 1, thread_count do
			self.threads[i][2]:push("QUIT")
		end
	end

	for i = #self.threads, 1, -1 do
		local th, _, cout = unpack(self.threads[i])

		if th:isRunning() then
			while true do
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
							if self._queue_image_info[key] then
								local info = self._queue_image_info[key]
								self:add_image(info.sprite_name, im, info.group, info.scale)
								self._queue_image_info[key] = nil
							else
								self.db_images[key] = {im, w, h}
							end

							self.queue_load_done_images = self.queue_load_done_images + 1
						end
					end
				else
					break
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

	self.progress = 1
	self.queue_load_total_images = 0
	self.queue_load_done_images = 0

	return true
end

---减少图集组引用计数，归零时卸载帧和纹理
---@param name string 图集名称
---@param ref_scale number? 渲染缩放比例，默认 1
---@return nil
function image_db:unload_atlas(name, ref_scale)
	-- 不卸载持久化纹理
	if self.persistent_textures[name] then
		return
	end

	ref_scale = ref_scale or 1

	local name_scale = string.format("%s-%.6f", name, ref_scale)
	local group_id = group_ids[name_scale]

	if not group_id or not self.atlas_uses[group_id] then
		log.info("atlas %s does not exist", name_scale)

		return
	end

	self.atlas_uses[group_id] = self.atlas_uses[group_id] - 1

	if self.atlas_uses[group_id] > 0 then
		log.debug("atlas %s still in use", name)

		return
	end

	log.debug("unloading atlas %s-%.6f", name, ref_scale)

	self.atlas_uses[group_id] = nil

	local remove_frames = {}
	local removed_ids = {}
	local image_counts = {}

	for k, id in pairs(self.db_atlas) do
		local f = get_frame(id)
		if f and f.group_id == group_id then
			remove_frames[#remove_frames + 1] = k
			if not removed_ids[id] then
				removed_ids[id] = true
				local atlas_id = f.atlas_id
				image_counts[atlas_id] = (image_counts[atlas_id] or 0) + 1
			end
		end
	end

	local removed_images_count = 0

	for atlas_id, count in pairs(image_counts) do
		local uses = (self.image_uses[atlas_id] or 0) - count
		if uses <= 0 then
			self.image_uses[atlas_id] = nil
			self.db_images[atlas_names[atlas_id]] = nil
			removed_images_count = removed_images_count + 1
		else
			self.image_uses[atlas_id] = uses
		end
	end

	for _, k in pairs(remove_frames) do
		self.db_atlas[k] = nil
	end

	for id in pairs(removed_ids) do
		free_frame_id(id)
	end

	log.debug(" removed #frames:%s #images:%s ", #remove_frames, removed_images_count)
end

---同步加载图集帧信息和纹理
---@param ref_scale number 渲染缩放比例
---@param path string 图集所在目录
---@param name string 图集名称
---@param not_binary boolean? true 加载 .lua 源码，false/nil 加载 .bin/.abin
---@return nil
function image_db:load_atlas_new(ref_scale, path, name, not_binary)
	local loaded_group_id = group_ids[name_scale(name, ref_scale)]
	if self.persistent_textures[name] and loaded_group_id and self.atlas_uses[loaded_group_id] then
		return
	end

	local image_names
	if not_binary then
		image_names = preload_atlas_lua(self, ref_scale, path, name)
	else
		image_names = preload_atlas_binary(self, ref_scale, path, name)
	end

	if not image_names then
		return
	end

	local i = 0

	for fn in pairs(image_names) do
		i = i + 1

		local key, im, w, h = load_image_file(self, fn, path)

		self.db_images[key] = {im, w, h}
	end

	self.progress = 1
end

---把单张图片注册为一个图集帧（临时/UI 图片使用）
---@param name string 帧名称
---@param image userdata LÖVE Image
---@param group string 图集组名称
---@param scale number 渲染缩放比例
---@param single_use boolean? true 时把该组引用计数固定为 1（临时文本图集使用）
---@return nil
function image_db:add_image(name, image, group, scale, single_use)
	scale = scale or 1

	local name_scale = string.format("%s-%.6f", group, scale)
	local w, h = image:getDimensions()
	local atlas_id = intern_atlas(name)
	local group_id = intern_group(name_scale)
	local id = alloc_frame_id()
	fill_frame(id, atlas_id, group_id, scale, 0, 0, w, h, G.newQuad(0, 0, w, h, w, h))
	self.db_atlas[name] = id
	self.db_images[name] = {image, w, h}
	self.atlas_uses[group_id] = (self.atlas_uses[group_id] or 0) + 1
	if single_use then
		self.atlas_uses[group_id] = 1
	end
	self.image_uses[atlas_id] = (self.image_uses[atlas_id] or 0) + 1
end

---移除由 add_image / queue_load_image 注册的单图帧
---@param name string 帧名称，必须存在于 db_atlas
---@return nil
function image_db:remove_image(name)
	local id = self.db_atlas[name]
	local f = get_frame(id)
	local atlas_id = f.atlas_id
	local group_id = f.group_id

	if self.image_uses[atlas_id] then
		self.image_uses[atlas_id] = self.image_uses[atlas_id] - 1
		if self.image_uses[atlas_id] <= 0 then
			self.image_uses[atlas_id] = nil
			self.db_images[atlas_names[atlas_id]] = nil
		end
	end

	if self.atlas_uses[group_id] then
		self.atlas_uses[group_id] = self.atlas_uses[group_id] - 1
		if self.atlas_uses[group_id] <= 0 then
			self.atlas_uses[group_id] = nil
			self.db_atlas[name] = nil
			free_frame_id(id)
		end
	end
end

--==查询==

---查询图集页对应的纹理
---@param name string 图集页名称
---@return userdata|nil LÖVE Image
---@return number|nil 宽度
---@return number|nil 高度
function image_db:i(name)
	local i = self.db_images[name]

	if self.db_images[name] then
		if i[1] == nil and i[4] and i[5] then
			local _, im, w, h = load_image_file(self, i[4], i[5])

			self.db_images[name] = {im, w, h}

			return im, w, h
		else
			return i[1], i[2], i[3]
		end
	else
		if not name and self.missing_images["nil"] or self.missing_images[name] then
			return nil
		end

		-- if not optional then
		log.error("Image %s not found in the images db\n%s", name, get_short_stats(self))
		-- end

		self.missing_images[name or "nil"] = true

		return nil
	end
end

---查询图集帧
---@param name string 帧名称
---@return any|nil FrameData cdata；未找到返回 nil
function image_db:s(name)
	local id = self.db_atlas[name]

	if not id then
		if not name and self.missing_sprites["nil"] or self.missing_sprites[name] then
			return nil
		end

		log.error("Sprite %s was not found in the atlas db.\n%s", name, get_short_stats(self))
		self.missing_sprites[name or "nil"] = true

		return nil
	end

	return get_frame(id)
end

---按 id 获取图集帧
---@param id integer 帧 id，必须由调用方保证有效
---@return any FrameData cdata
function image_db:frame(id)
	return get_frame(id)
end

---按旧式 frame table 注入帧，trim/size 同时兼容 0-based 和 1-based
---@param name string 帧名称
---@param f table 含 atlas、group、quad、ref_scale、trim、size 的帧数据
---@return integer 帧 id
function image_db:add_frame_table(name, f)
	local trim = f.trim
	local size = f.size
	local tx, ty, w, h
	if trim then
		if trim[0] ~= nil then
			tx, ty = trim[0], trim[1]
		else
			tx, ty = trim[1] or 0, trim[2] or 0
		end
	end
	if size then
		if size[0] ~= nil then
			w, h = size[0], size[1]
		else
			w, h = size[1] or 0, size[2] or 0
		end
	end
	return self:add_frame(name, f.atlas, f.group, f.quad, f.ref_scale, tx, ty, w, h)
end

---注入一个图集帧
---@param name string 帧名称
---@param atlas string 图集页名称
---@param group string 图集组名称（含缩放）
---@param quad userdata LÖVE Quad
---@param ref_scale number 渲染缩放比例
---@param tx number 横向 trim
---@param ty number 纵向 trim
---@param w number 帧宽
---@param h number 帧高
---@return integer 帧 id
---@return integer atlas_id 图集页 id
---@return integer group_id 图集组 id
function image_db:add_frame(name, atlas, group, quad, ref_scale, tx, ty, w, h)
	local atlas_id = intern_atlas(atlas)
	local group_id = intern_group(group)
	local id = alloc_frame_id()
	fill_frame(id, atlas_id, group_id, ref_scale or 1, tx, ty, w, h, quad)
	self.db_atlas[name] = id

	return id, atlas_id, group_id
end

--==统计==

---获取帧存储统计
---@return table { blocks: integer, block_size: integer, next_id: integer, free: integer, used: integer }
function image_db:get_frame_stats()
	return {
		blocks = #frame_blocks,
		block_size = BLOCK_SIZE,
		next_id = next_frame_slot,
		free = #free_frame_ids,
		used = next_frame_slot - #free_frame_ids
	}
end

return image_db
