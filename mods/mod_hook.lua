-- chunkname: @./mods/mod_hook.lua
local log = require("lib.klua.log"):new("mod_hook")
local I = require("lib.klove.image_db")
local S = require("sound_db")
local LU = require("level_utils")
local P = require("path_db")
local FS = love.filesystem
local mod_utils = require("mod_utils")
local hook_utils = require("hook_utils")
local mod_db = require("mod_db")
local HOOK = hook_utils.HOOK
local raw_image_load_atlas = nil

local hook = hook_utils:new()

local function merge_keyed_table(dst, src, on_assign)
	if not src then
		return
	end
	for k, v in pairs(src) do
		dst[k] = v
		if on_assign then
			on_assign(k, v)
		end
	end
end

function hook:front_init()
	HOOK(S, "init", self.S.init)
end

function hook:after_init()
	raw_image_load_atlas = I.load_atlas
	HOOK(I, "load_atlas", self.I.load_atlas)
	HOOK(I, "queue_load_atlas", self.I.queue_load_atlas)
	HOOK(S, "queue_load_group", self.S.queue_load_group)
	HOOK(S, "queue_load_done", self.S.queue_load_done)
	HOOK(LU, "load_level", self.LU.load_level)
	HOOK(P, "load", self.P.load)
end

-- 增加图像资源覆盖路径
function hook.I.load_atlas(load_atlas, self, ref_scale, path, name, yielding)
	load_atlas(self, ref_scale, path, name, yielding)

	for i = 1, mod_db.mods_count do
		local mod_data = mod_db.mods_datas[i]
		local images_path = mod_data.check_paths["/_assets/images"]

		if images_path then
			local lua_file = string.format("%s/%s.lua", images_path, name)

			if FS.isFile(lua_file) then
				local name_scale = string.format("%s-%.6f", name, ref_scale)

				if self.atlas_uses and self.atlas_uses[name_scale] then
					self.atlas_uses[name_scale] = nil
				end

				load_atlas(self, ref_scale, images_path, name, yielding)
				log.info("Found atlas override %s in mod %s", lua_file, mod_data.name)
			end
		end
	end
end

-- 增加图像资源覆盖路径
function hook.I.queue_load_atlas(queue_load_atlas, self, ref_scale, path, name, not_bytecode)
	queue_load_atlas(self, ref_scale, path, name, not_bytecode)

	for i = 1, mod_db.mods_count do
		local mod_data = mod_db.mods_datas[i]
		local images_path = mod_data.check_paths["/_assets/images"]

		if images_path then
			local lua_file = string.format("%s/%s.lua", images_path, name)

			if FS.isFile(lua_file) then
				local name_scale = string.format("%s-%.6f", name, ref_scale)
				local removed_key = {}

				if self.atlas_uses and self.atlas_uses[name_scale] then
					self.atlas_uses[name_scale] = nil
				end

				for k, item in ipairs(self.load_queue) do
					local item_name = item[3]

					if item_name == name then
						table.insert(removed_key, k)
					end
				end

				for _, k in ipairs(removed_key) do
					log.debug("Removed load queue item key: %d, name: %s", k, name)

					self.load_queue[k] = nil
				end

				if IS_ANDROID and raw_image_load_atlas then
					-- Android 下强制走 .lua atlas 加载路径，让 image_db 的格式回退逻辑生效（ASTC/PNG/JPG）
					raw_image_load_atlas(self, ref_scale, images_path, name, false)
					log.info("Found atlas override %s in mod %s (android lua fallback)", lua_file, mod_data.name)
				else
					queue_load_atlas(self, ref_scale, images_path, name, not_bytecode)
					log.info("Found atlas override %s in mod %s", lua_file, mod_data.name)
				end
			end
		end
	end
end

-- 增加声音资源覆盖路径
function hook.S.init(init, self, path, overrides)
	init(self, path, overrides)

	for i = 1, mod_db.mods_count do
		local mod_data = mod_db.mods_datas[i]
		local settings_path = mod_data.check_paths["/_assets/sounds/settings.lua"]

		if settings_path then
			local f_settings = FS.load(settings_path)()

			if f_settings.source_groups then
				for gid, group in pairs(f_settings.source_groups) do
					self.source_groups[gid] = {
						max_sources = group.max_sources or 1
					}
					self.active_sources[gid] = self.active_sources[gid] or {}
				end
			end

			self.mod_load.settings = true
		end

		local sounds_path = mod_data.check_paths["/_assets/sounds/sounds.lua"]

		if sounds_path then
			local mod_sounds = FS.load(sounds_path)()
			merge_keyed_table(self.sounds, mod_sounds, function(id, sd)
				if self._precache_sound then
					self:_precache_sound(id, sd)
				end
			end)

			log.info("Merged sound's sounds from mod %s", mod_data.name)

			self.mod_load.sounds = true
		end

		local groups_path = mod_data.check_paths["/_assets/sounds/groups.lua"]

		if groups_path then
			local mod_groups = FS.load(groups_path)()
			merge_keyed_table(self.groups, mod_groups)

			log.info("Merged sound's groups from mod %s", mod_data.name)
		end
	end
end

local function clear_sound_group_cache(self, name)
	local group = self.groups and self.groups[name]
	if not group then
		return
	end

	if self.sounds_uses and self.sounds_uses[name] then
		self.sounds_uses[name] = nil
	end

	local function clear_file(file_name)
		if self.sources and self.sources[file_name] then
			self.sources[file_name] = nil
		end
		if self.source_uses and self.source_uses[file_name] then
			self.source_uses[file_name] = nil
		end
	end

	if group.files then
		for _, file_name in ipairs(group.files) do
			clear_file(file_name)
		end
	end

	if group.sounds then
		for _, sound_name in ipairs(group.sounds) do
			local sound = self.sounds and self.sounds[sound_name]
			if sound and sound.files then
				for _, file_name in ipairs(sound.files) do
					clear_file(file_name)
				end
			end
		end
	end
end

function hook.S.queue_load_group(queue_load_group, self, name)
	queue_load_group(self, name)

	if self._mod_overlay_running then
		return
	end

	if not self._mod_override_groups then
		self._mod_override_groups = {}
		self._mod_override_groups_seen = {}
	end

	if not self._mod_override_groups_seen[name] then
		self._mod_override_groups_seen[name] = true
		self._mod_override_groups[#self._mod_override_groups + 1] = name
	end
end

function hook.S.queue_load_done(queue_load_done, self)
	local done = queue_load_done(self)
	if not done then
		return false
	end

	if self._mod_overlay_running then
		return true
	end

	local override_groups = self._mod_override_groups
	if not override_groups or #override_groups == 0 then
		return true
	end

	self._mod_override_groups = nil
	self._mod_override_groups_seen = nil
	self._mod_overlay_running = true

	local origin_path = self.files_path
	for i = 1, mod_db.mods_count do
		local mod_data = mod_db.mods_datas[i]
		local files_path = mod_data.check_paths["/_assets/sounds/files"]

		if files_path then
			self.files_path = files_path

			for _, group_name in ipairs(override_groups) do
				clear_sound_group_cache(self, group_name)
				self:load_group(group_name, false)
			end
		end
	end
	self.files_path = origin_path
	self._mod_overlay_running = nil

	return true
end

-- 增加关卡数据覆盖路径
function hook.LU.load_level(load_level, store, name)
	local level = load_level(store, name)

	for i = 1, mod_db.mods_count do
		local mod_data = mod_db.mods_datas[i]
		local levels_data_path = mod_data.check_paths["/data/levels"]

		if levels_data_path then
			local origin_path = KR_PATH_GAME

			KR_PATH_GAME = mod_data.path

			local new_level = load_level(store, name)

			KR_PATH_GAME = origin_path

			if new_level.data then
				level.data = new_level.data
			end

			if new_level.locations then
				level.locations = new_level.locations
			end
		end
	end

	return level
end

-- 增加波次数据覆盖路径
function hook.P.load(load, self, name, visible_coords)
	load(self, name, visible_coords)

	for i = 1, mod_db.mods_count do
		local mod_data = mod_db.mods_datas[i]
		local waves_data_path = mod_data.check_paths["/data/waves"]

		if waves_data_path then
			local origin_path = KR_PATH_GAME

			KR_PATH_GAME = mod_data.path

			load(self, name, visible_coords)

			KR_PATH_GAME = origin_path
		end
	end
end

return hook
