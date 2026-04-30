-- chunkname: @./all/game_editor_utils.lua
-- 地图编辑器专用的文件操作工具
-- 所有关卡文件存放在用户的存档目录下的 game_editor/ 中
-- 目录结构：
--   game_editor/data/levels/  → level%04d.lua, level%04d_data.lua, level%04d_grid.lua, level%04d_paths.lua
--   game_editor/waves/        → level%04d_waves_campaign.lua, level%04d_waves_heroic.lua, level%04d_waves_iron.lua

local log = require("lib.klua.log"):new("game_editor_utils")
local km = require("lib.klua.macros")
local serpent = require("serpent")
local GEU = {}

-- 编辑器存档根目录（相对于 love.filesystem 的 save 目录）
local EDITOR_ROOT = "game_editor"
local LEVELS_DIR = EDITOR_ROOT .. "/data/levels"
local WAVES_DIR = EDITOR_ROOT .. "/data/waves"

-- 编辑器关卡起始编号（从 9999 递减）
GEU.EDITOR_FIRST_INDEX = 9999

--- 确保编辑器目录结构存在
function GEU.ensure_dirs()
	love.filesystem.createDirectory(EDITOR_ROOT)
	love.filesystem.createDirectory(EDITOR_ROOT .. "/data")
	love.filesystem.createDirectory(LEVELS_DIR)
	love.filesystem.createDirectory(WAVES_DIR)
end

--- 获取关卡在编辑器目录下的基础路径
--- @param level_name string 如 "level0001"
--- @return string 如 "game_editor/data/levels/level0001"
function GEU.get_level_base_path(level_name)
	return LEVELS_DIR .. "/" .. level_name
end

--- 检查编辑器目录下是否存在某个关卡的文件
--- @param level_name string
--- @return boolean
function GEU.editor_level_exists(level_name)
	local base = GEU.get_level_base_path(level_name)
	local info = love.filesystem.getInfo(base .. ".lua")
	-- 至少需要 .lua 文件存在
	return info ~= nil and info.type == "file"
end

--- 检查编辑器目录下的单个文件是否存在
--- @param path string 相对于 save 目录的路径
--- @return boolean
function GEU.file_exists(path)
	local info = love.filesystem.getInfo(path)
	return info ~= nil and info.type == "file"
end

--- 从编辑器目录加载关卡主文件 (level%04d.lua)
--- @param level_name string
--- @return table|nil
function GEU.load_editor_level_file(level_name)
	local path = GEU.get_level_base_path(level_name) .. ".lua"
	if not GEU.file_exists(path) then
		return nil
	end
	local chunk, err = love.filesystem.load(path)
	if err then
		log.error("Failed to load editor level %s: %s", path, err)
		return nil
	end
	return chunk()
end

--- 从编辑器目录加载关卡数据文件 (level%04d_data.lua)
--- @param level_name string
--- @return table|nil
function GEU.load_editor_data_file(level_name)
	local path = GEU.get_level_base_path(level_name) .. "_data.lua"
	if not GEU.file_exists(path) then
		return nil
	end
	-- data 文件是 "return {...}" 格式，直接用 love.filesystem.load
	local chunk, err = love.filesystem.load(path)
	if err then
		log.error("Failed to load editor data %s: %s", path, err)
		return nil
	end
	return chunk()
end

--- 从编辑器目录加载网格文件，返回内容字符串
--- @param level_name string
--- @return string|nil
function GEU.load_editor_grid_raw(level_name)
	local path = GEU.get_level_base_path(level_name) .. "_grid.lua"
	if not GEU.file_exists(path) then
		return nil
	end
	return love.filesystem.read(path)
end

--- 从编辑器目录加载路径文件，返回内容字符串
--- @param level_name string
--- @return string|nil
function GEU.load_editor_paths_raw(level_name)
	local path = GEU.get_level_base_path(level_name) .. "_paths.lua"
	if not GEU.file_exists(path) then
		return nil
	end
	return love.filesystem.read(path)
end

--- 从编辑器目录加载出怪文件
--- @param level_name string
--- @param mode_str string "campaign"|"heroic"|"iron"
--- @return table|nil
function GEU.load_editor_waves(level_name, mode_str)
	local path = WAVES_DIR .. "/" .. level_name .. "_waves_" .. mode_str .. ".lua"
	if not GEU.file_exists(path) then
		return nil
	end
	local chunk, err = love.filesystem.load(path)
	if err then
		log.error("Failed to load editor waves %s: %s", path, err)
		return nil
	end
	return chunk()
end

--- 保存关卡主文件到编辑器目录
--- @param level_name string
--- @param data table
function GEU.save_editor_level_file(level_name, data)
	GEU.ensure_dirs()
	local path = GEU.get_level_base_path(level_name) .. ".lua"
	local str = serpent.block(data, {
		indent = "    ",
		comment = false,
		sortkeys = false
	})
	love.filesystem.write(path, "return " .. str .. "\n")
end

--- 保存关卡数据文件到编辑器目录
--- @param level_name string
--- @param data table
function GEU.save_editor_data_file(level_name, data)
	GEU.ensure_dirs()
	local path = GEU.get_level_base_path(level_name) .. "_data.lua"
	local str = serpent.block(data, {
		indent = "    ",
		comment = false,
		sortkeys = false
	})
	love.filesystem.write(path, "return " .. str .. "\n")
end

--- 保存网格文件到编辑器目录
--- @param level_name string
--- @param content string
function GEU.save_editor_grid_file(level_name, content)
	GEU.ensure_dirs()
	local path = GEU.get_level_base_path(level_name) .. "_grid.lua"
	love.filesystem.write(path, content)
end

--- 保存路径文件到编辑器目录
--- @param level_name string
--- @param content string
function GEU.save_editor_paths_file(level_name, content)
	GEU.ensure_dirs()
	local path = GEU.get_level_base_path(level_name) .. "_paths.lua"
	love.filesystem.write(path, content)
end

--- 保存出怪文件到编辑器目录
--- @param level_name string
--- @param mode_str string
--- @param data table
function GEU.save_editor_waves(level_name, mode_str, data)
	GEU.ensure_dirs()
	local path = WAVES_DIR .. "/" .. level_name .. "_waves_" .. mode_str .. ".lua"
	local str = serpent.block(data, {
		indent = "    ",
		comment = false,
		sortkeys = false
	})
	love.filesystem.write(path, "return " .. str .. "\n")
end

--- 扫描编辑器目录，找到当前最小的关卡序号
--- @return number 最小序号，若目录为空则返回 9999
function GEU.find_min_editor_index()
	GEU.ensure_dirs()
	local files = love.filesystem.getDirectoryItems(LEVELS_DIR)
	local min_idx = 10000
	for _, f in ipairs(files) do
		-- 匹配 level%04d.lua（不匹配 _data, _grid, _paths 后缀）
		local idx = tonumber(f:match("^level(%d+)%.lua$"))
		if idx then
			if idx < min_idx and idx > 9000 then
				min_idx = idx
			end
		end
	end
	return min_idx
end

--- 初始化一个空白关卡的基本数据结构
--- @param store table 游戏的 store 对象
--- @param idx number 关卡序号
--- @param mode number 游戏模式
function GEU.init_blank_level(store, idx, mode)
	local level_name = "level" .. string.format("%04d", idx)

	store.level_idx = idx
	store.level_name = level_name
	store.level_mode = mode or 1
	store.level_difficulty = DIFFICULTY_EASY

	store.level = {
		data = {
			entities_list = {},
			invalid_path_ranges = {},
			level_mode_overrides = {{}, {}, {}},
			nav_mesh = {}
		},
		required_textures = {},
		required_sounds = {},
		nav_mesh = {}
	}

	log.info("Initialized blank level: %s", level_name)
end

--- 获取 mode_str 对应的字符串
--- @param mode number
--- @return string
function GEU.mode_to_str(mode)
	if mode == GAME_MODE_HEROIC then
		return "heroic"
	elseif mode == GAME_MODE_IRON then
		return "iron"
	else
		return "campaign"
	end
end

return GEU
