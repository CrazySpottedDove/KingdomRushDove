-- chunkname: @./all/exoskeleton.lua
local log = require("lib.klua.log"):new("exoskeleton")
local FS = love.filesystem
local A = require("animation_db")
local perf = require("dove_modules.perf.perf")
local EXO = {}

EXO.exos = {}
EXO.exos_count = {}
EXO.db = {}
EXO.supported_extensions = {"exo3", "exo", "lua"}
EXO.base_path = KR_PATH_GAME .. "/data/exoskeletons"
EXO.exo_lists_to_load = {}

-- TODO: 为 EXO 添加 unload 方法，避免 exo 数据过多导致内存占用过高的问题；优化 EXO 数据结构。

--- director 调用，将资源列表加入 EXO.exo_lists_to_load 中，在进入对局时被加载
---@param exo_list any
function EXO:queue_load(exo_list)
	table.insert(self.exo_lists_to_load, exo_list)
end

--- 为了避免自引用，选择为 exo_frame 添加属性 exo_name，而不是直接让它引用 exo。因此，EXO 数据库需要暴露通过 exo_frame 查询 exo 的方法。
---@param exo_frame any
function EXO:get_exo_by_frame(exo_frame)
	return self.exos[exo_frame.exo_name]
end

--- 简短查看当前 EXO 的加载情况
function EXO:dump()
	local exo_names = ""
	for k, v in pairs(self.exos) do
		exo_names = exo_names .. k .. ", "
	end
	log.error("EXO:dump - currently loaded exos: %s", exo_names)
end

--- 加载 exo 数据，在进入对局时，A:load()后调用
function EXO:load()
	-- perf.tmp_start("EXO:load")
	for _, exo_list in pairs(self.exo_lists_to_load) do
		for _, exo_name in ipairs(exo_list) do
			if not self.exos[exo_name] then
				local exo = self:load_lua(exo_name, EXO.exo_path)
				local db_animation = A.db
				for _, animation in ipairs(exo.animations) do
					local name = exo.name .. "_" .. animation.name

					if not db_animation[name] then
						db_animation[name] = A.extract_frame_from({
							from = 1,
							to = #animation.frames,
							prefix = name
						})
					end

					for i = 1, db_animation[name][1] do
						self.db[db_animation[name][2][i]] = animation.frames[i]
						animation.frames[i].exo_name = exo.name
					end
				end

				self.exos[exo_name] = exo
				self.exos_count[exo_name] = (self.exos_count[exo_name] or 0) + 1
			end
		end
	end

	-- A:dump()
	self.exo_lists_to_load = {}
-- perf.tmp_stop("EXO:load")
end

function EXO:load_groups(groups)
	if not groups then
		return
	end

	for _, g in pairs(groups) do
		local exo_names = {}
		local group_path = EXO.base_path .. "/" .. g

		if FS.isDirectory(group_path) then
			local items = FS.getDirectoryItems(group_path)

			for i = 1, #items do
				local item = items[i]

				for _, ext in pairs(EXO.supported_extensions) do
					local ext_s = "." .. ext .. "$"

					if string.match(item, ext_s) then
						local name = string.gsub(item, ext_s, "")

						table.insert(exo_names, name)

						break
					end
				end
			end
		end

		EXO:load(exo_names, g, group_path)
	end
end

--- 加载存放在 lua 文件中的 v3 格式的 exo 数据
function EXO:load_lua(exo_name, exo_path)
	local fn = (exo_path or EXO.base_path) .. "/" .. exo_name

	local f = FS.load(fn .. ".lua")
	local exo = f()

	exo.name = exo_name
	exo.attach_idx = {}

	for _, v in pairs(exo.parts) do
		exo.parts[v[1]] = v
	end

	for i, v in ipairs(exo.attach_points) do
		exo.attach_points[v[1]] = v
		exo.attach_idx[v[1]] = i
	end

	return exo
end

function EXO:load_animations_to_animation_db(exo)
	local db = A.db

	for _, animation in ipairs(exo.animations) do
		local name = exo.name .. "_" .. animation.name

		if not db[name] then
			db[name] = A.extract_frame_from({
				from = 1,
				to = #animation.frames,
				prefix = name
			})
		end
	end
end

function EXO:load_fake_sprites_to_db(exo)
	for _, animation in ipairs(exo.animations) do
		local ani_name = animation.name

		for idx, frame in ipairs(animation.frames) do
			local sprite_name = string.format("%s_%s_%04d", exo.name, ani_name, idx)

			self.db[sprite_name] = frame
			frame.exo_name = exo.name
		end
	end
end

function EXO:f(frame_name)
	local exo_frame = self.db[frame_name]

	if not exo_frame then
		log.error("Could not find exo_frame called: %s", frame_name)

		return nil
	end

	return exo_frame
end

function EXO:get_last_attach_point_xform(entity, sprite_id, name)
	local f = entity.render and entity.render.sprites[sprite_id]

	if not f then
		log.error("Could not find frame for sprite_id:%s in entity:%s (%s)", sprite_id, entity.id, entity.template_name)

		return
	end

	local exo_frame = f.exo_frame

	if not exo_frame then
		log.error("frame for sprite_id:%s in entity:%s (%s) does not have exo_frame", sprite_id, entity.id, entity.template_name)
	end

	local exo = self.exos[exo_frame.exo_name]

	local idx = exo.attach_idx[name]

	if not idx then
		log.error("Could not find attach point named %s in sprite_id:%s in entity:%s (%s)", name, sprite_id, entity.id, entity.template_name)

		return
	end

	return f and f.last_attach_point_xform and f.last_attach_point_xform[idx]
end

return EXO
