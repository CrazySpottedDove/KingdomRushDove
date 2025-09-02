-- chunkname: @./lib/klove/image_db.lua

local log = require("klua.log"):new("image_db")
local G = love.graphics
local FS = love.filesystem

require("klua.table")
require("klua.dump")

local km = require("klua.macros")
local image_db = {}

image_db.db_images = {}
image_db.db_atlas = {}
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

local _MAX_THREADS = 8
local _LOAD_IMAGE_THREAD_CODE = "local cin,cout,th_i = ...\nrequire 'love.filesystem'\nrequire 'love.image'\nrequire 'love.timer'\nlocal file_count = 0\nwhile true do\n    -- get params\n    local fn = cin:demand()\n    if fn == 'QUIT' then goto quit end\n    local path = cin:demand()\n    local f = path .. '/' .. fn\n\n    --print('TH  ' ..th_i.. ' ARGS ' .. fn .. ' ' .. path .. '\\n')\n    \n    if not love.filesystem.isFile(f) then\n        cout:push({'ERROR','Not a file',f})\n    else\n        local data\n        --local t_start = love.timer.getTime()\n        if string.match(fn, '.pkm$') or string.match(fn, '.astc$') or string.match(fn, '.dds$') then\n            data = love.image.newCompressedData(f)\n        else\n            data = love.image.newImageData(f)\n        end\n        --print('TH  ' ..th_i.. ' newXData time: ' .. (love.timer.getTime()-t_start) .. '\\n')\n        if not data then\n            cout:push({'ERROR','Image could not be loaded',f})\n        else\n            file_count = file_count + 1\n            local w,h = data:getDimensions()\n            local key = string.gsub(fn, '.png$', '')\n            key = string.gsub(key, '.jpg$', '')\n            key = string.gsub(key, '.pkm$', '')\n            key = string.gsub(key, '.astc$', '')\n            key = string.gsub(key, '.dds$', '')\n            cout:push({'OK',key,data,w,h})\n        end\n    end\nend\n::quit::\ncout:supply({'DONE'})\n--print('TH  ' ..th_i.. ' QUIT - FILES LOADED ' .. file_count .. '\\n')\n"

function image_db:get_short_stats()
	local count_frames = 0
	local o = ""
	local list = {}

	o = o .. "Atlas frames count: "

	for k, v in pairs(self.db_atlas) do
		count_frames = count_frames + 1
	end

	o = o .. count_frames .. "\n"
	o = o .. "Loaded images: "

	for k, v in pairs(self.db_images) do
		if v[1] then
			table.insert(list, k)
		end
	end

	table.sort(list)

	o = o .. table.concat(list, ", ")
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
				table.insert(self.image_name_queue, {
					n,
					path
				})

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
				th:setAffinity({
					false,
					true,
					true
				})
				log.paranoid(" ++++ IMAGE_DB THREAD %s AFFINITY %s", th, getdump(th:getAffinity()))
			end

			table.insert(self.threads, {
				th,
				cin,
				cout
			})
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

							self.db_images[key] = {
								c,
								w,
								h
							}
							im = nil

							collectgarbage()
						else
							log.paranoid(" +++ keeping image %s", im)

							self.db_images[key] = {
								im,
								w,
								h
							}
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

	log.info("Done loading atlas queue. | time: %s", love.timer.getTime() - self.queue_load_start_time)

	self.queue_load_start_time = nil
	self.progress = 1
	self.groups_total = 0
	self.queue_load_total_images = 0
	self.queue_load_done_images = 0
	self.image_name_queue = {}

	return true
end

function image_db:queue_load_atlas(ref_scale, path, name)
	log.debug("queued %s/%s-%.6f", path, name, ref_scale)
	table.insert(self.load_queue, {
		ref_scale,
		path,
		name
	})

	self.groups_total = self.groups_total + 1

	if #self.load_queue == 1 and not self.load_queue_current then
		self.progress = 0
		self.groups_done = 0
	end
end

function image_db:unload_atlas(name, ref_scale)
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
	self:purge_atlas()
	collectgarbage()
end

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
		self.db_images[v] = nil
	end

	log.debug("  purged #images:%s", #remove_images)
end

function image_db:preload_atlas(ref_scale, path, name)
	local name_scale = string.format("%s-%.6f", name, ref_scale)

	log.debug("load atlas: %s,%s-%.6f", path, name, ref_scale)

	if self.atlas_uses[name_scale] then
		self.atlas_uses[name_scale] = self.atlas_uses[name_scale] + 1

		log.debug("atlas %s already loaded", name)

		return
	end

	self.atlas_uses[name_scale] = 1
	self.progress = 0
	ref_scale = ref_scale or 1

	local group_file = path .. "/" .. name .. ".lua"

	if not FS.isFile(group_file) then
		log.error("atlas file %s not found for %s/%s", group_file, path, name)

		return
	end

	local frames = FS.load(group_file)()
	local unique_frames = {}
	local image_names = {}
	local deferred_image_names = {}

	for k, v in pairs(frames) do
		log.paranoid("loading atlas-frame: %s - %s", v.a_name, k)

		v.group = name_scale
		v.quad = G.newQuad(v.f_quad[1], v.f_quad[2], v.f_quad[3], v.f_quad[4], v.a_size[1], v.a_size[2])

		if v.defer then
			deferred_image_names[v.a_name] = true
		else
			image_names[v.a_name] = true
		end

		v.atlas = string.gsub(v.a_name, ".png$", "")
		v.atlas = string.gsub(v.atlas, ".pkm$", "")
		v.atlas = string.gsub(v.atlas, ".astc$", "")
        v.atlas = string.gsub(v.atlas, ".dds$", "")
		for _, a in ipairs(v.alias) do
			unique_frames[a] = v
		end

		v.ref_scale = ref_scale
	end

	for k, v in pairs(unique_frames) do
		frames[k] = v
	end

	self.db_atlas = table.merge(self.db_atlas, frames)

	for fn in pairs(deferred_image_names) do
		local key = string.gsub(fn, ".png$", "")

		key = string.gsub(key, ".jpg$", "")
		key = string.gsub(key, ".pkm$", "")
		key = string.gsub(key, ".astc$", "")
        key = string.gsub(key, ".dds$", "")
		self.db_images[key] = {
			[4] = fn,
			[5] = path
		}
	end

	return image_names
end

function image_db:load_atlas(ref_scale, path, name, yielding)
	local rt_start = love.timer.getTime()
	local image_names = self:preload_atlas(ref_scale, path, name)

	if not image_names then
		return
	end

	local i = 0

	for fn in pairs(image_names) do
		i = i + 1

		local key, im, w, h = image_db:load_image_file(fn, path)

		self.db_images[key] = {
			im,
			w,
			h
		}

		if yielding then
			self.progress = i / #table.keys(image_names)

			coroutine.yield()
		end
	end

	self.progress = 1

	log.info("Finished loading atlas %s/%s at scale %s (time:%s)", path, name, ref_scale, love.timer.getTime() - rt_start)
end

function image_db:load(ref_scale, custom_paths)
	ref_scale = ref_scale or 1

	local paths = custom_paths or {
		"images/ipad"
	}
	local image_files = {}

	for _, path in pairs(paths) do
		local files = FS.getDirectoryItems(path)

		for i = 1, #files do
			local name = files[i]
			local f = path .. "/" .. name

			if FS.isFile(f) and (string.match(f, ".png$") or string.match(f, ".jpg$")) then
				local key = string.gsub(name, ".png$", "")

				key = string.gsub(key, ".jpg$", "")

				local im = G.newImage(f)

				if not im then
					log.error("Image %s could not be created", f)
				else
					local w, h = im:getDimensions()

					self.db_images[key] = {
						im,
						w,
						h
					}
				end
			end
		end
	end

	for _, path in pairs(paths) do
		local files = FS.getDirectoryItems(path)

		for i = 1, #files do
			local name = files[i]
			local f = path .. "/" .. name

			if FS.isFile(f) and string.match(f, ".lua$") then
				local file_basename = string.gsub(name, ".lua$", "")
				local frames = require(path .. "." .. file_basename)
				local queue = {}

				for k, v in pairs(frames) do
					v.quad = G.newQuad(v.f_quad[1], v.f_quad[2], v.f_quad[3], v.f_quad[4], v.a_size[1], v.a_size[2])
					v.atlas = string.gsub(v.a_name, ".png$", "")

					for _, a in ipairs(v.alias) do
						queue[a] = v
					end

					v.ref_scale = ref_scale
				end

				for k, v in pairs(queue) do
					frames[k] = v
				end

				self.db_atlas = table.merge(self.db_atlas, frames)
			end
		end
	end

	log.debug("finished loading image_db")
end

function image_db:load_image_file(fn, path)
	local f = path .. "/" .. fn

	if not FS.isFile(f) then
		log.error("not a valid file: %s", f)

		return
	end

	if string.match(f, ".png$") or string.match(f, ".jpg$") or string.match(f, ".pkm$") or string.match(f, ".astc$") or string.match(f, ".dds$") then
		log.paranoid("  loading image file %s", f)

		local compressed = false

		if string.match(f, ".pkm$") then
			compressed = true

			local supportedformats = love.graphics.getCompressedImageFormats()

			if not supportedformats.ETC1 then
				log.error("ETC1 not supported. Could not load %s", f)

				return nil
			end
		elseif string.match(f, ".astc$") then
			compressed = true

			local supportedformats = love.graphics.getCompressedImageFormats()

			if not supportedformats.ASTC4x4 then
				log.error("ASTC not supported. Could not load %s", f)

				return nil
			end
		elseif string.match(f, ".dds$") then
			compressed = true

			local supportedformats = love.graphics.getCompressedImageFormats()

			if not supportedformats.DXT3 then
				log.error("DXT3 not supported. Could not load %s", f)

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

			return key, im, w, h
		end
	end
end

function image_db:add_image(name, image, group, scale)
	scale = scale or 1

	local name_scale = string.format("%s-%.6f", group, scale)
	local w, h = image:getDimensions()

	local v = {}
	v.size = {
		w,
		h
	}
	v.trim = {
		0,
		0,
		0,
		0
	}
	v.a_name = name
	v.a_size = {
		w,
		h
	}
	v.group = name_scale
	v.quad = G.newQuad(0, 0, w, h, w, h)
	v.atlas = name
	v.ref_scale = scale
	self.db_atlas[name] = v
	self.db_images[name] = {
		image,
		w,
		h
	}

	if not self.atlas_uses[name_scale] then
		self.atlas_uses[name_scale] = 1
	end
end

function image_db:remove_image(name)
	self.db_images[name] = nil
	self.db_atlas[name] = nil
end

function image_db:i(name, optional)
	local i = self.db_images[name]

	if self.db_images[name] then
		if i[1] == nil and i[4] and i[5] then
			local key, im, w, h = self:load_image_file(i[4], i[5])

			self.db_images[name] = {
				im,
				w,
				h
			}

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

	-- if DBG_REPLACE_MISSING_TEXTURES and not s then
	-- 	s = self.db_atlas._debug_textures_missing

	-- 	log.error("DBG_REPLACE_MISSING_TEXTURES: replaced %s", name)
	-- end

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
