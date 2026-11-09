-- chunkname: @./all/game_editor_utils.lua
-- 地图编辑器专用的文件操作工具
-- 所有关卡文件存放在用户的存档目录下的 game_editor/ 中
-- 目录结构（按代际隔离，可覆盖本体关卡）：
--   game_editor/generations/<gen>/data/levels/  → level_XXX.lua, level_XXX_data.lua, level_XXX_grid.lua, level_XXX_paths.lua
--   game_editor/generations/<gen>/data/waves/   → level_XXX_waves_campaign.lua, level_XXX_waves_heroic.lua, level_XXX_waves_iron.lua

local log = require("lib.klua.log"):new("game_editor_utils")
local km = require("lib.klua.macros")
local I = require("lib.klove.image_db")
local S = require("sound_db")
local G = love.graphics
local GEU = {}

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
