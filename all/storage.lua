-- chunkname: @./all/storage.lua
local log = require("lib.klua.log"):new("storage")
local km = require("lib.klua.macros")
local FS = love.filesystem
local persistence = require("lib.klua.persistence")
local signal = require("lib.hump.signal")

require("lib.klua.string")

local GS = require("kr1.game_settings")
local version = require("version")

local sio = require("all.storage_io_generic")
local storage = {}

storage.active_slot_idx = nil
storage.slot = nil
storage.SETTINGS_FILE = "settings.lua"
storage.SLOT_FILE_FMT = "slot_%d.lua"

local SETTINGS_PARAMS = {
	"fps",
	"fullscreen",
	"height",
	"texture_size",
	"volume_fx",
	"volume_music",
	"vsync",
	"width",
	"msaa",
	"locale",
	"large_pointer",
	"highdpi",
	"pause_on_switch",
	"sound_pool_size",
	"update_enabled",
	"update_last_site",
	"launch_options",
	"last_slot_idx",
	-- 用于指示是否为即时重启。如为即时重启，会跳过多数不必要的 scene。
	"tmp_restart"
}
local SLOT_ADDITIONAL_DATA = {
	gems = 0,
	bag = {},
	upgrade_list_id = 1
}
local SLOT_MANDATORY_KEYS = {"levels", "upgrades", "heroes"}

function storage:deserialize_lua(data)
	if not data then
		log.error("Error deserializing. data is nil")

		return nil
	end

	local chunk, err = loadstring(data)

	if not chunk then
		log.error("Error loading chunk. %s", err)

		return nil
	end

	local env = {}

	setfenv(chunk, env)

	local ok, result = pcall(chunk)

	if not ok then
		log.error("Error parsing chunk. %s", tostring(result))

		return nil
	end

	return result
end

function storage:serialize_lua(data_table)
	return persistence.serialize_to_string(data_table)
end

function storage:load_lua(filename, force_load)
	local ok, data_table = sio:load_file(filename, force_load)

	if not ok or not data_table then
		return nil
	end

	return data_table
end

function storage:load_config()
	local config = self:load_lua("config.lua", true)
	local default_patch = require("patches.default")

	if not config then
		log.error("config.lua not found, using default.lua instead")

		config = default_patch

		self:save_config(config)
	elseif not config.custom_config_enabled then
		log.error("config.custom_config_enable is false, using default.lua instead")

		config = default_patch
	else
		for k, v in pairs(default_patch) do
			if config[k] == nil then
				config[k] = v
			end
		end
	end

	return config
end

function storage:load_criket()
	local criket = self:load_lua("criket.lua", true)

	if not criket then
		local criket_template = require("patches.criket_template")

		criket = criket_template

		self:save_criket(criket)
	end

	if criket.on then
		local criket_template = require("patches.criket_template")

		for k, v in pairs(criket_template) do
			if criket[k] == nil then
				if type(v) == "table" then
					criket[k] = table.deepclone(v)
				else
					criket[k] = v
				end
			end
		end

		if #criket.groups <= 0 then -- 若没有出怪组则使用模板的出怪组
			criket.groups = criket_template.groups
		else
			local ct_groups = criket_template.groups[1]
			local ct_spawns = ct_groups.spawns[1]

			for _, group in pairs(criket.groups) do
				for ctg_k, ctg_v in pairs(ct_groups) do
					if not group[ctg_k] then -- 若出怪组不存在模板出怪组的键则向其增加模板的对应键
						group[ctg_k] = ctg_v
					else
						local criket_spawns = group.spawns

						if #criket_spawns <= 0 then -- 若没有出任何怪则使用模板的怪物
							criket_spawns = ct_spawns
						else
							for ct_k, ct_v in pairs(ct_spawns) do
								for _, spawn in pairs(criket_spawns) do
									if not spawn[ct_k] then
										spawn[ct_k] = ct_v
									end
								end
							end
						end
					end
				end
			end
		end

		criket.fps_transformed = false
	end

	return criket
end

function storage:load_endless(level_name)
	return self:load_lua(string.format("endless_%s.lua", level_name), true)
end

function storage:save_endless(level_name, endless)
	local success = self:write_lua(string.format("endless_%s.lua", level_name), endless)

	if not success then
		log.error("Error saving endless_%s.lua", level_name)
	end
end

function storage:delete_endless(level_name)
	local success = self:remove(string.format("endless_%s.lua", level_name), true)

	if not success then
		log.error("Error deleting endless_%s.lua", level_name)
	end

	return success
end

function storage:load_keyset()
	local key_shortcuts = self:load_lua("keyset.lua", true)
	local default_key_shortcuts = require("patches.keyset_default")

	if not key_shortcuts then
		key_shortcuts = default_key_shortcuts

		self:save_keyset(key_shortcuts)
	else
		for k, v in pairs(default_key_shortcuts) do
			if not key_shortcuts[k] or type(key_shortcuts[k]) ~= type(v) then
				key_shortcuts[k] = v
			end
		end
	end

	return key_shortcuts
end

function storage:save_keyset(key_shortcuts)
	local success = self:write_lua("keyset.lua", key_shortcuts)

	if not success then
		log.error("Error saving keyset.lua")
	end
end

function storage:save_config(config)
	local success = self:write_lua("config.lua", config)

	if not success then
		log.error("Error saving config.lua")
	end
end

function storage:save_criket(criket)
	local success = self:write_lua("criket.lua", criket)

	if not success then
		log.error("Error saving criket.lua")
	end
end

function storage:write_lua(filename, data_table)
	local ok = sio:write_file(filename, data_table)

	if not ok then
		log.error("Error writing %s", filename)
	end

	return ok
end

function storage:remove(filename)
	local ok = sio:remove_file(filename)

	if not ok then
		log.error("Error removing %s", filename)
	end

	return ok
end

function storage:load_settings()
	local input = self:load_lua(self.SETTINGS_FILE)
	local template = require("settings_template")

	if not input or not type(input) == "table" then
		return table.deepclone(template)
	else
		for k, v in pairs(template) do
			if type(v) ~= "table" then
				if input[k] == nil then
					input[k] = v
				end
			else
				if input[k] == nil then
					input[k] = table.deepclone(v)
				else
					for tk, tv in pairs(v) do
						if input[k][tk] == nil then
							input[k][tk] = tv
						end
					end
				end
			end
		end

		return input
	end
end

function storage:save_settings(data_table)
	local out = {}

	for _, p in pairs(SETTINGS_PARAMS) do
		out[p] = data_table[p]
	end

	local success = self:write_lua(self.SETTINGS_FILE, out)

	if not success then
		log.error("error saving settings")
	end

	return success
end

function storage:load_slot(idx, force)
	idx = idx or self.active_slot_idx

	if not idx then
		log.error("slot idx is nil")

		return nil
	end

	local input = self:load_lua(string.format(self.SLOT_FILE_FMT, idx), force)

	if not input or not type(input) == "table" then
		return nil
	end

	for _, v in pairs(SLOT_MANDATORY_KEYS) do
		if not input[v] then
			log.error("loaded slot %s has invalid data for %s. removing.", idx, v)
			self:delete_slot(idx)

			return nil
		end
	end

	for k, v in pairs(SLOT_ADDITIONAL_DATA) do
		if not input[k] then
			input[k] = v
		end
	end

	if not input.levels[101] then
		input.levels[101] = {}
	end

	return input
end

function storage:save_slot(data_table, idx, should_sync)
	idx = idx or self.active_slot_idx

	if not idx then
		log.error("slot idx is nil")

		return nil
	end

	if data_table then
		data_table.version_string = version.string
	end

	log.debug("saving slot:%s should sync:%s", idx, should_sync)

	local fn = string.format(self.SLOT_FILE_FMT, idx)
	local success = self:write_lua(fn, data_table)

	if success then
		signal.emit("slot-saved", idx, should_sync)
	else
		log.error("error saving slot %s", idx)
	end

	return success
end

function storage:delete_slot(idx)
	if not idx then
		log.error("slot idx is nil")

		return nil
	end

	local success = storage:remove(string.format(self.SLOT_FILE_FMT, idx), true)

	if success then
		signal.emit("slot-deleted", idx)
	end

	return success
end

function storage:new_slot(idx)
	local template = require("data.slot_template")

	template = table.deepclone(template)

	return template
end

function storage:create_slot(idx)
	local template = storage:new_slot(idx)

	storage:save_slot(template, idx, true)

	return storage:load_slot(idx)
end

function storage:set_active_slot(idx)
	if not idx then
		log.error("slot idx is nil")

		return
	end

	if not self:load_slot(idx) then
		self:create_slot(idx)
	end

	self.active_slot_idx = idx

	signal.emit("slot-changed", idx)
end

function storage:get_slot_name(idx)
	return string.format(self.SLOT_FILE_FMT, idx)
end

function storage:get_slot_progress(slot)
	if not slot then
		log.paranoid("slot is nil")

		return -1
	end

	local total = 0

	for i = 1, GS.last_level do
		local v = slot.levels[i]

		if v then
			total = total + (v.stars or 0) + (v[GAME_MODE_HEROIC] and 1 or 0) + (v[GAME_MODE_IRON] and 1 or 0)
		end
	end

	if slot.last_victory then
		local vidx = slot.last_victory.level_idx
		local vmode = slot.last_victory.level_mode
		local vstars = slot.last_victory.stars or 0
		local ll = slot.levels[vidx]
		local lstars = ll and ll.stars or 0

		if ll and ll[vmode] then
			if vmode == GAME_MODE_CAMPAIGN and lstars < vstars then
				total = total - lstars + vstars
			end
		else
			total = total + vstars
		end
	end

	total = km.clamp(0, GS.max_stars, total)

	log.paranoid("slot progress %s\nlevels:%s\nlast_victory:%s", total, getfulldump(slot.levels), getfulldump(slot.last_victory or {}))

	return total
end

function storage:get_best_slot(slot_a, slot_b)
	if not slot_a and not slot_b then
		return nil
	end

	if not slot_a then
		return slot_b
	end

	if not slot_b then
		return slot_a
	end

	local prog_a = self:get_slot_progress(slot_a)
	local prog_b = self:get_slot_progress(slot_b)
	local gems_a = slot_a.gems or 0
	local gems_b = slot_b.gems or 0
	local crowns_a = slot_a.crowns or 0
	local crowns_b = slot_b.crowns or 0

	if prog_a < prog_b then
		return slot_b
	elseif prog_b < prog_a then
		return slot_a
	end

	if gems_a < gems_b then
		return slot_b
	elseif gems_b < gems_a then
		return slot_a
	end

	if crowns_a < crowns_b then
		return slot_b
	elseif crowns_b < crowns_a then
		return slot_a
	end

	return slot_a
end

function storage:import_plist(filename)
	local plist = require("lib.klua.plist")
	local storage_mappings = require("storage_mappings")

	local fs

	if filename == "NSUserDefaults" then
		log.info("importing plist from nsuserdefaults")

		local function get_nsuserdefaults_data()
			local ffi = require("ffi")

			ffi.cdef(" const char* kr_get_nsuserdefaults_data(); ")

			return ffi.string(ffi.C.kr_get_nsuserdefaults_data())
		end

		local ok, result = pcall(get_nsuserdefaults_data)

		if not ok then
			log.error("error loading plist from ns_userdefaults: %s", tostring(result))

			return
		end

		fs = result
	else
		log.info("importing plist from %s", filename)

		local f = io.open(filename, "r")

		if not f then
			log.debug("plist file could not be found at %s", filename)

			return
		end

		fs = f:read("*a")

		f:close()
	end

	local p = plist:parse(fs)

	if not p then
		log.error("error parsing plist file %s", filename)

		return
	end

	for i = 1, 3 do
		local src_slot_name = string.format("slot_%i", i - 1)
		local src_slot = p[src_slot_name]

		if not src_slot then
			log.error("Slot %s could not be found", src_slot_name)
		else
			local dst_slot = self:load_slot(i) or self:create_slot(i)

			storage_mappings:append_slot(src_slot, dst_slot)
			self:save_slot(dst_slot, i)
		end
	end

	log.info("plist import finished")
end

return storage
