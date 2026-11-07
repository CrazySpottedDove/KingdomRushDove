-- chunkname: @./all/storage.lua
local log = require("lib.klua.log"):new("storage")
local km = require("lib.klua.macros")
local persistence = require("lib.klua.persistence")
local signal = require("lib.hump.signal")

require("lib.klua.string")

local GENS = require("generations.registry")
local LEGACY = require("generations.legacy")
local version = require("version")

local sio = require("all.storage_io_generic")
local storage = {}

storage.active_slot_idx = nil
storage.slot = nil
storage.SETTINGS_FILE = "settings.lua"
-- 旧版单文件存档，仅用于迁移。
storage.SLOT_FILE_FMT = "slot_%d.lua"
-- 新版每个 slot 一个目录，每个 generation 一个文件。
storage.SLOT_DIR_FMT = "slot_%d"
storage.SLOT_META_FILE = "meta.lua"
storage.SLOT_SCHEMA_VERSION = 3

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
local SLOT_MANDATORY_KEYS = {"levels", "upgrades", "heroes"}
local OBSOLETE_SLOT_KEYS = {"unmigrated_levels", "gems", "bag", "status", "achievements", "achivements", "achievement_counters", "achievements_counters", "upgrade_line_key"}
local DEFAULT_UPGRADE_LEVELS = {
	archers = 0,
	barracks = 0,
	mages = 0,
	engineers = 0,
	rain = 0,
	reinforcements = 0
}

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

-- load_config/load_criket moved to dove_modules.configer

-- load_keyset/load_ui_settings/save_* moved to dove_modules.configer

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

--- slot 目录。
---@param idx number
---@return string
function storage:get_slot_dir(idx)
	return string.format(self.SLOT_DIR_FMT, idx)
end

--- generation 数据文件路径。
---@param idx number
---@param gen_name string
---@return string
function storage:get_generation_path(idx, gen_name)
	return self:get_slot_dir(idx) .. "/" .. gen_name .. ".lua"
end

--- 补齐 slot 的公共默认字段，并标记为当前 schema。
---@param slot table
---@return table
function storage:normalize_slot(slot)
	for _, key in ipairs(OBSOLETE_SLOT_KEYS) do
		slot[key] = nil
	end

	slot.schema_version = self.SLOT_SCHEMA_VERSION

	return slot
end

--- 读取新版 slot 目录。metadata 与 generation 文件在内存中重新合并为旧结构。
---@param idx number
---@param force boolean|nil
---@return table|nil
function storage:load_slot_folder(idx, force)
	local dir = self:get_slot_dir(idx)
	local meta = self:load_lua(dir .. "/" .. self.SLOT_META_FILE, force)

	if not meta or type(meta) ~= "table" then
		return nil
	end

	local slot = {}

	for k, v in pairs(meta) do
		if k ~= "levels" and k ~= "upgrades" then
			slot[k] = v
		end
	end

	slot.levels = {}
	slot.upgrades = {}

	-- 兼容未来可能把 levels/upgrades 留在 meta 中的中间格式。
	if type(meta.levels) == "table" then
		for k, v in pairs(meta.levels) do
			slot.levels[k] = v
		end
	end

	if type(meta.upgrades) == "table" then
		for k, v in pairs(meta.upgrades) do
			slot.upgrades[k] = v
		end
	end

	local ok, items = pcall(love.filesystem.getDirectoryItems, dir)

	if ok and items then
		for _, filename in ipairs(items) do
			local gen_name = filename:match("^([%w_%-]+)%.lua$")

			if gen_name and gen_name ~= "meta" then
				local data = self:load_lua(dir .. "/" .. filename, force)

				if type(data) == "table" then
					slot.levels[gen_name] = data.levels or {}
					slot.upgrades[gen_name] = data.upgrades or {}
				end
			end
		end
	end

	return slot
end

--- 将内存中的 slot 写入目录结构。
---@param slot table
---@param idx number
---@return boolean
function storage:write_slot_folder(slot, idx)
	local dir = self:get_slot_dir(idx)

	love.filesystem.createDirectory(dir)

	local meta = {}

	for k, v in pairs(slot) do
		if k ~= "levels" and k ~= "upgrades" then
			meta[k] = v
		end
	end

	meta.schema_version = self.SLOT_SCHEMA_VERSION

	if not self:write_lua(dir .. "/" .. self.SLOT_META_FILE, meta) then
		return false
	end

	local gen_names = {}

	for gen_name in pairs(slot.levels or {}) do
		gen_names[gen_name] = true
	end

	for gen_name in pairs(slot.upgrades or {}) do
		gen_names[gen_name] = true
	end

	for _, gen in ipairs(GENS:all()) do
		gen_names[gen.name] = true
	end

	for gen_name in pairs(gen_names) do
		local gen_data = {
			levels = slot.levels and slot.levels[gen_name] or {},
			upgrades = slot.upgrades and slot.upgrades[gen_name] or {}
		}

		if not self:write_lua(self:get_generation_path(idx, gen_name), gen_data) then
			return false
		end
	end

	slot.schema_version = self.SLOT_SCHEMA_VERSION

	return true
end

--- 迁移旧单文件 slot 前保留原始内容。
---@param idx number
function storage:backup_legacy_slot(idx)
	local filename = string.format(self.SLOT_FILE_FMT, idx)
	local raw = love.filesystem.read(filename)

	if raw then
		local backup = filename .. ".bak_v3_" .. os.date("%Y%m%d_%H%M%S")
		love.filesystem.write(backup, raw)
	end
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

--- 将旧存档迁移到 v2，并补齐所有已注册世代的默认进度结构。
---@param input table 原始 slot 表
---@param idx number slot 序号
---@return table
function storage:ensure_slot_v2(input, idx)
	GENS:init()

	if (tonumber(input.schema_version) or 1) < 2 then
		local fn = string.format(self.SLOT_FILE_FMT, idx)
		local raw = love.filesystem.read(fn)

		if raw then
			love.filesystem.write(fn .. ".bak_v1_" .. os.date("%Y%m%d_%H%M%S"), raw)
		end

		local old_levels = input.levels
		input.levels = {}

		for key, value in pairs(old_levels) do
			local global_idx = tonumber(key)
			local gen_id, local_idx = LEGACY.to_ref(global_idx)

			if gen_id then
				input.levels[gen_id] = input.levels[gen_id] or {}
				input.levels[gen_id][local_idx] = value
			end
		end

		local last_gen_id = LEGACY.to_gen_id(input.last_generation or 1)

		input.last_generation = last_gen_id
		input.upgrades = {
			[last_gen_id] = {
				list_id = tostring(input.upgrade_list_id or "1"),
				levels = input.upgrades or {}
			}
		}
		input.upgrade_list_id = nil

		if input.last_victory then
			local gen_id, local_idx = LEGACY.to_ref(input.last_victory.level_idx)

			if gen_id then
				input.last_victory.gen_id = gen_id
				input.last_victory.level_idx = local_idx
			else
				input.last_victory = nil
			end
		end

		input.schema_version = 2
	end

	if not GENS:get(input.last_generation) then
		input.last_generation = "kr1"
	end

	for _, gen in ipairs(GENS:all()) do
		if gen.kind == "standard" then
			local levels = input.levels[gen.name] or {}

			if not levels[1] then
				levels[1] = {}
			end

			input.levels[gen.name] = levels
		end

		local upgrades = input.upgrades[gen.name]

		if not upgrades then
			upgrades = {
				list_id = gen.upgrades.default_line,
				levels = {}
			}
			input.upgrades[gen.name] = upgrades
		end

		if not upgrades.list_id then
			upgrades.list_id = gen.upgrades.default_line
		end

		upgrades.list_id = tostring(upgrades.list_id)

		for class, value in pairs(DEFAULT_UPGRADE_LEVELS) do
			if upgrades.levels[class] == nil then
				upgrades.levels[class] = value
			end
		end
	end

	return input
end

function storage:load_slot(idx, force)
	idx = idx or self.active_slot_idx

	if not idx then
		log.error("slot idx is nil")

		return nil
	end

	local input = self:load_slot_folder(idx, force)

	if not input then
		local legacy_filename = string.format(self.SLOT_FILE_FMT, idx)
		local legacy = self:load_lua(legacy_filename, force)

		if legacy and type(legacy) == "table" then
			self:backup_legacy_slot(idx)

			input = self:ensure_slot_v2(legacy, idx)
			input = self:normalize_slot(input)

			-- 迁移成功后再移除旧文件；失败时保留旧文件作为回退。
			if self:write_slot_folder(input, idx) then
				sio:remove_file(legacy_filename)
			end
		end
	end

	if not input or type(input) ~= "table" then
		return nil
	end

	input = self:ensure_slot_v2(input, idx)
	input = self:normalize_slot(input)

	for _, v in pairs(SLOT_MANDATORY_KEYS) do
		if not input[v] then
			log.error("loaded slot %s has invalid data for %s. removing.", idx, v)
			self:delete_slot(idx)

			return nil
		end
	end

	return input
end

function storage:save_slot(data_table, idx, should_sync)
	idx = idx or self.active_slot_idx

	if not idx then
		log.error("tried save slot, but slot idx is nil")

		return nil
	end

	local success = self:write_slot_folder(data_table, idx)

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

	local dir = self:get_slot_dir(idx)
	local success = false
	local ok, items = pcall(love.filesystem.getDirectoryItems, dir)

	if ok and items then
		for _, filename in ipairs(items) do
			sio:remove_file(dir .. "/" .. filename)
			success = true
		end
	end

	if love.filesystem.remove(dir) then
		success = true
	end

	if sio:remove_file(string.format(self.SLOT_FILE_FMT, idx)) then
		success = true
	end

	if success then
		signal.emit("slot-deleted", idx)
	else
		log.error("error deleting slot %s", idx)
	end

	return success
end

--- 将磁盘镜像结构的模板合并成运行时使用的 slot 结构。
---@param template table
---@return table
function storage:merge_slot_template(template)
	local slot = {}

	for k, v in pairs(template.meta or {}) do
		slot[k] = table.deepclone(v)
	end

	slot.levels = {}
	slot.upgrades = {}

	for gen_name, data in pairs(template.generations or {}) do
		slot.levels[gen_name] = table.deepclone(data.levels or {})
		slot.upgrades[gen_name] = table.deepclone(data.upgrades or {})
	end

	return slot
end

function storage:new_slot(idx)
	local template = require("data.slot_template")
	local slot = self:merge_slot_template(template)

	slot = self:ensure_slot_v2(slot, idx or self.active_slot_idx)

	return self:normalize_slot(slot)
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
	return self:get_slot_dir(idx)
end

function storage:get_slot_progress(slot)
	if not slot then
		log.paranoid("slot is nil")

		return -1
	end

	local total = 0

	for _, gen in ipairs(GENS:all()) do
		if gen.kind == "standard" then
			local levels = slot.levels[gen.name]

			if levels then
				for _, v in pairs(levels) do
					total = total + (v.stars or 0) + (v[GAME_MODE_HEROIC] and 1 or 0) + (v[GAME_MODE_IRON] and 1 or 0)
				end
			end
		end
	end

	if slot.last_victory then
		local vidx = slot.last_victory.level_idx
		local vmode = slot.last_victory.level_mode
		local vstars = slot.last_victory.stars or 0
		local gen_levels = slot.levels[slot.last_victory.gen_id]
		local ll = gen_levels and gen_levels[vidx]
		local lstars = ll and ll.stars or 0

		if ll and ll[vmode] then
			if vmode == GAME_MODE_CAMPAIGN and lstars < vstars then
				total = total - lstars + vstars
			end
		else
			total = total + vstars
		end
	end

	total = km.clamp(0, GENS:total_max_stars(), total)

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
	local crowns_a = slot_a.crowns or 0
	local crowns_b = slot_b.crowns or 0

	if prog_a < prog_b then
		return slot_b
	elseif prog_b < prog_a then
		return slot_a
	end

	if crowns_a < crowns_b then
		return slot_b
	elseif crowns_b < crowns_a then
		return slot_a
	end

	return slot_a
end

return storage
