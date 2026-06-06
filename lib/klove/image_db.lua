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

local extension_name = IS_ANDROID and ".aluac" or ".luac"

-- 缓存纹理，这些纹理只要进局内肯定会需要加载，就不重复加载卸载了
local persistent_textures = table.to_map({
	-- game
	"go_decals",
	"go_enemies_common",
	"go_towers_group1",
	"go_editor",
	"go_towers_group2",
	"go_towers_group3",
	"go_towers_group4",
	"go_towers_group5",
	"go_towers_group6",
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
	"go_towers_dragons",
	"tower_holders",
	"kr4_dark_army_tower_archer",
	"kr4_rotten_forest_tower",
	"kr4_ember_lords_tower_mage",
	"kr4_fallen_ones_bone_flingers",
	"kr4_warmongers_tower_barrack",
	"kr4_dark_army_tower_barrack",
	"kr4_ogres_tower_barrack",
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
image_db.missing_images = {}
image_db.missing_sprites = {}
image_db.threads = {}
image_db.image_name_queue = {}
image_db.image_path_queue = {}
image_db.queue_load_total_images = 0
image_db.queue_load_done_images = 0
image_db.use_canvas = true
-- by dove
image_db.supportedformats = love.graphics.getImageFormats()

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

		return true
	end

	local load_queue_length = #self.load_queue

	for i = load_queue_length, 1, -1 do
		local item = self.load_queue[i]
		self.load_queue[i] = nil

		-- 不要删掉这行，这真是注释：local ref_scale, path, name = unpack(item)
		local image_names = item[4] and self:preload_atlas(item[1], item[2], item[3]) or self:preload_atlas_from_bytecode(item[1], item[2], item[3])

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

	-- self:save_to_file()
	return true
end

function image_db:queue_load_atlas(ref_scale, path, name, not_bytecode)
	if persistent_textures[name] and self.atlas_uses[name_scale(name, ref_scale)] then
		return
	end

	table.insert(self.load_queue, {ref_scale, path, name, not_bytecode})

	if #self.load_queue == 1 and not self.load_queue_current then
		self.progress = 0
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
	ref_scale = ref_scale or 1
	local name_scale = string.format("%s-%.6f", name, ref_scale)

	if self.atlas_uses[name_scale] then
		self.atlas_uses[name_scale] = self.atlas_uses[name_scale] + 1

		return
	end

	self.atlas_uses[name_scale] = 1
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

		-- 我们重建 atlas 数据，除去了冗余数据，以做到内存占用的减少
		self.db_atlas[k] = {
			atlas = remove_extension_fast(v.a_name),
			group = name_scale,
			quad = G.newQuad(v.f_quad[1], v.f_quad[2], v.f_quad[3], v.f_quad[4], v.a_size[1], v.a_size[2]),
			trim = {v.trim[1], v.trim[2]},
			ref_scale = ref_scale * (v.ref_scale or 1),
			size = {v.size[1], v.size[2]}
		}
		-- alias 只有指针
		for i = 1, #v.alias do
			self.db_atlas[v.alias[i]] = self.db_atlas[k]
		end
	end

	return image_names
end

--- 加载图像组的全部帧信息，但不加载图像资源。帧信息实现了帧到纹理的映射。
--- 使用了预编译的数据，格式见 scripts/compile_image_atlas.lua
---@param ref_scale number 图像组的渲染比例
---@param path string 图像组父目录路径
---@param name string 图像组名称（不含.lua后缀）
---@return table|nil 所有待加载的图像名称 map<string, boolean>
function image_db:preload_atlas_from_bytecode(ref_scale, path, name)
	ref_scale = ref_scale or 1
	local name_scale = string.format("%s-%.6f", name, ref_scale)

	if self.atlas_uses[name_scale] then
		self.atlas_uses[name_scale] = self.atlas_uses[name_scale] + 1

		return
	end

	self.atlas_uses[name_scale] = 1
	self.progress = 0

	local group_file = path .. "/" .. name .. extension_name

	-- 使用 pcall 进行保护，避免加载不存在的资源文件。如果不存在，报错提醒。
	-- local info = FS.load(group_file)()
	local success, chunk = pcall(FS.load, group_file)
	if not success or type(chunk) ~= "function" then
		log.error("Failed to load atlas bytecode: %s. Error: %s", group_file, chunk)
		return
	end

	local info = chunk()

	local image_names = {}

	for i = 1, info.count do
		local v = info.values[i]
		image_names[v[1]] = true
		self.db_atlas[info.keys[i]] = {
			atlas = remove_extension_fast(v[1]),
			group = name_scale,
			quad = G.newQuad(v[2][1], v[2][2], v[2][3], v[2][4], v[2][5], v[2][6]),
			trim = v[3],
			ref_scale = ref_scale * v[4],
			size = v[5]
		}
		-- alias
		if v[6] then
			for j = 1, #v[6] do
				self.db_atlas[v[6][j]] = self.db_atlas[info.keys[i]]
			end
		end
	end

	return image_names
end

--- [[DEPRECATED]] 加载一张图像资源，用于少量、临时的图像加载。建议使用 load_atlas_new 以利用预编译的图像列表，提高加载性能。该接口用于保证现有插件的兼容性，但不建议在新开发中使用。
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

--- 加载一张图像资源，用于少量、临时的图像加载
---@param ref_scale number 图像的渲染比例
---@param path string 图像父目录路径
---@param name string 图像组名称（不含.lua后缀）
function image_db:load_atlas_new(ref_scale, path, name)
	if persistent_textures[name] and self.atlas_uses[name_scale(name, ref_scale)] then
		return
	end

	local image_names = self:preload_atlas_from_bytecode(ref_scale, path, name)

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

			-- Android 端应该已在 preload_atlas 中转换为 .astc 或 .png，此处为容错
			if IS_ANDROID then
				local astc_fn = fn:gsub("%.dds$", ".astc")
				if is_file(path .. "/" .. astc_fn) then
					return self:load_image_file(astc_fn, path)
				end

				local png_fn = fn:gsub("%.dds$", ".png")
				if is_file(path .. "/" .. png_fn) then
					return self:load_image_file(png_fn, path)
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

--- 临时添加图像文件。改方法添加的图像组都是临时组，由 director 接管资源的释放，因此不会主动管理 atlas_uses 引用计数。
---@param name string 纹理名称
---@param image userdata 纹理
---@param group string 纹理组名称
---@param scale number 纹理参考缩放比例
function image_db:add_image(name, image, group, scale)
	scale = scale or 1

	local name_scale = string.format("%s-%.6f", group, scale)
	local w, h = image:getDimensions()

	self.db_atlas[name] = {
		atlas = name,
		group = name_scale,
		quad = G.newQuad(0, 0, w, h, w, h),
		trim = {0, 0},
		ref_scale = scale,
		size = {w, h}
	}
	self.db_images[name] = {image, w, h}

-- if not self.atlas_uses[name_scale] then
-- self.atlas_uses[name_scale] = 1
-- else
-- self.atlas_uses[name_scale] = self.atlas_uses[name_scale] + 1
-- end
end

--- 移除图像文件
---@param name string 纹理名称
function image_db:remove_image(name)
	-- local name_scale = self.db_atlas[name].group
	-- self.atlas_uses[name_scale] = self.atlas_uses[name_scale] - 1
	-- if self.atlas_uses[name_scale] <= 0 then
	self.db_images[name] = nil
	self.db_atlas[name] = nil
-- end
end

function image_db:i(name)
	local i = self.db_images[name]

	if self.db_images[name] then
		if i[1] == nil and i[4] and i[5] then
			local _, im, w, h = self:load_image_file(i[4], i[5])

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
		log.error("Image %s not found in the images db\n%s", name, self:get_short_stats())
		-- end

		self.missing_images[name or "nil"] = true

		return nil
	end
end

function image_db:s(name)
	local s = self.db_atlas[name]

	if not s then
		if not name and self.missing_sprites["nil"] or self.missing_sprites[name] then
			return nil
		end

		-- if not optional then
		log.error("Sprite %s was not found in the atlas db.\n%s", name, self:get_short_stats())
		-- end

		self.missing_sprites[name or "nil"] = true

		return nil
	end

	return s
end

function image_db:save_to_file()
	local storage = require("all.storage")
	storage:write_lua("image_db_DB_IMAGES.lua", self.db_images)
	storage:write_lua("image_db_DB_ATLAS.lua", self.db_atlas)
	storage:write_lua("image_db_ATLAS_USES.lua", self.atlas_uses)

end

return image_db
