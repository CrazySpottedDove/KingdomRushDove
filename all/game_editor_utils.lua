-- chunkname: @./all/game_editor_utils.lua
-- 地图编辑器专用的文件操作工具
-- 所有关卡文件存放在用户的存档目录下的 game_editor/ 中
-- 目录结构：
--   game_editor/data/levels/  → level%04d.lua, level%04d_data.lua, level%04d_grid.lua, level%04d_paths.lua
--   game_editor/waves/        → level%04d_waves_campaign.lua, level%04d_waves_heroic.lua, level%04d_waves_iron.lua

local log = require("lib.klua.log"):new("game_editor_utils")
local km = require("lib.klua.macros")
local I = require("lib.klove.image_db")
local S = require("sound_db")
local G = love.graphics
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

--- 扫描编辑器目录，找到当前最小的关卡序号
--- @return number 最小序号，若目录为空则返回 9999
function GEU.find_min_editor_index()
	GEU.ensure_dirs()
	local files = love.filesystem.getDirectoryItems(LEVELS_DIR)
	local min_idx = 10000
	for _, f in ipairs(files) do
		-- 匹配 level%02d_paths.lua（不匹配 _data, _grid, _paths 后缀）
		local idx = f:match("^level(%d%d%d%d)_paths%.lua$")
		if idx then
			idx = tonumber(idx)
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
		plugin_required_textures = {},
		required_sounds = {},
		plugin_required_sounds = {},
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

function GEU.register_runtime_image(rel_path, sprite_name, group_name)
	if not rel_path or not sprite_name then
		return false
	end

	local ok_img, img_data = pcall(love.image.newImageData, rel_path)
	if not ok_img or not img_data then
		return false
	end

	local img = G.newImage(img_data)
	if not img then
		return false
	end

	I:add_image(sprite_name, img, group_name or "game")
	return true, img
end

function GEU.register_runtime_music(rel_path, sound_id)
	if not rel_path or not sound_id then
		return false
	end

	local ok_src, src = pcall(love.audio.newSource, rel_path, "stream")
	if not ok_src or not src then
		return false
	end

	local file_key = sound_id .. "__file"
	S.sources[file_key] = {src}
	S.source_uses[file_key] = 1
	S.sounds[sound_id] = {
		files = {
			[1] = file_key
		},
		gain = 0.6,
		loop = true,
		source_group = "MUSIC",
		stream = true
	}

	if not S.sound_extras[sound_id] then
		S:_precache_sound(sound_id, S.sounds[sound_id])
	end

	return true
end

return GEU
