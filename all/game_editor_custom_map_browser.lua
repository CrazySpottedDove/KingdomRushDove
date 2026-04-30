-- chunkname: @./all/game_editor_custom_map_browser.lua
-- 自定义地图浏览器 - 在 screen_map 中展示所有已安装的自定义地图
local log = require("lib.klua.log"):new("custom_map_browser")
local km = require("lib.klua.macros")
require("lib.klua.table")
require("klove.kui")
require("gg_views_custom")
local V = require("lib.klua.vector")
local v = V.v
local FS = love.filesystem
local F = require("lib.klove.font_db")
local S = require("sound_db")

local CustomMapBrowser = class("CustomMapBrowser", PopUpView)

local C = {
	bg = {16, 20, 32, 255},
	panel = {26, 33, 50, 255},
	text = {205, 218, 248, 255},
	accent = {195, 148, 38, 255},
	card_bg = {36, 46, 68, 200},
	hover = {58, 130, 220, 255}
}

-- 加载自定义地图（供外部在 screen_map 中使用）
function CustomMapBrowser.load_and_play_custom_map(map_cfg, done_callback)
	if not map_cfg or not map_cfg.map_id then
		log.error("Invalid map config")
		return
	end

	local map_dir = "dove_map_editor/maps/" .. map_cfg.map_id
	local level_name = map_cfg.level_name or "level01"

	-- 检查文件是否存在
	local data_path = map_dir .. "/" .. level_name .. "_data.lua"
	local exists = pcall(FS.getInfo, data_path)
	if not exists then
		log.error("Map data not found: %s", data_path)
		return
	end

	-- 找出可用的关卡编号（使用高编号避免冲突）
	local target_level = 999

	-- 复制文件到游戏数据目录
	local base_path = KR_FULLPATH_BASE .. "/" .. KR_PATH_GAME .. "/data/levels/"
	local wave_path = KR_FULLPATH_BASE .. "/" .. KR_PATH_GAME .. "/data/waves/"

	-- 读取并写入关卡数据
	local data_content = FS.read(data_path)
	if data_content then
		local df = io.open(base_path .. "level999_data.lua", "w")
		if df then
			df:write(data_content)
			df:close()
		end
	end

	-- 路径数据
	local paths_path = map_dir .. "/" .. level_name .. "_paths.lua"
	local paths_content = FS.read(paths_path)
	if paths_content then
		local pf = io.open(base_path .. "level999_paths.lua", "w")
		if pf then
			pf:write(paths_content)
			pf:close()
		end
	end

	-- 出怪文件（战役模式）
	local wave_path_src = map_dir .. "/" .. level_name .. "_waves_campaign.lua"
	local wave_content = FS.read(wave_path_src)
	if wave_content then
		local wf = io.open(wave_path .. "level999_waves_campaign.lua", "w")
		if wf then
			wf:write(wave_content)
			wf:close()
		end
	end

	log.info("Custom map '%s' prepared for playing as level999", map_cfg.name or "unknown")

	-- 更新保存数据（记录该地图被游玩过）
	local EditorExportView = require("game_editor_export")
	local save_data = EditorExportView.load_custom_save()
	save_data.maps = save_data.maps or {}
	save_data.maps[map_cfg.map_id] = save_data.maps[map_cfg.map_id] or {
		plays = 0
	}
	save_data.maps[map_cfg.map_id].plays = (save_data.maps[map_cfg.map_id].plays or 0) + 1
	save_data.maps[map_cfg.map_id].last_played = os.time()
	EditorExportView.save_custom_save(save_data)

	-- 跳转到游戏场景
	if done_callback then
		done_callback({
			next_item_name = "game",
			level_idx = target_level,
			level_mode = GAME_MODE_CAMPAIGN,
			level_difficulty = DIFFICULTY_NORMAL
		})
	end
end

function CustomMapBrowser:initialize(sw, sh, done_callback)
	PopUpView.initialize(self, V.v(sw, sh))
	self.colors.background = {0, 0, 0, 160}
	self._done_callback = done_callback

	-- 扫描自定义地图
	self._maps = require("game_editor_export").scan_custom_maps()

	local pw, ph = 800, 600
	local panel = KView:new(V.v(pw, ph))
	panel.colors.background = C.bg
	panel.anchor = v(pw / 2, ph / 2)
	panel.pos = v(sw / 2, sh / 2)
	self:add_child(panel)

	-- 标题
	local title = KLabel:new(V.v(pw, 40))
	title.text = "自定义地图"
	title.text_align = "center"
	title.vertical_align = "middle"
	title.colors.text = {238, 244, 255, 255}
	title.colors.background = C.panel
	title.font_size = 20
	title.font_name = KE_CONST.font_name
	title.pos = v(0, 0)
	panel:add_child(title)

	-- 关闭
	local close_btn = KButton:new(V.v(30, 30))
	close_btn.text = "X"
	close_btn.pos = v(pw - 35, 5)
	close_btn.colors.background = {120, 50, 50, 255}
	close_btn.colors.text = {255, 255, 255, 255}
	function close_btn.on_click()
		self:hide()
	end
	panel:add_child(close_btn)

	-- 地图列表
	local list_y = 50
	local list_h = ph - list_y - 20

	self._scroll_y = 0
	self._list_view = KView:new(V.v(pw - 20, list_h))
	self._list_view.pos = v(10, list_y)
	self._list_view.clip = true
	panel:add_child(self._list_view)

	self._list_content = KView:new(V.v(pw - 20, 0))
	self._list_content.pos = v(0, 0)
	self._list_view:add_child(self._list_content)

	self:_rebuild_list()
end

function CustomMapBrowser:_rebuild_list()
	self._list_content:remove_children()
	local pw = self._list_view.size.x
	local y = 4
	local card_h = 70
	local gap = 6

	if #self._maps == 0 then
		local empty_lbl = KLabel:new(V.v(pw, 40))
		empty_lbl.pos = v(0, 20)
		empty_lbl.text = "暂无自定义地图\n请在地图编辑器中导出地图"
		empty_lbl.text_align = "center"
		empty_lbl.colors.text = {150, 150, 150, 255}
		empty_lbl.font_size = 14
		empty_lbl.font_name = KE_CONST.font_name
		empty_lbl.line_height = 1.5
		self._list_content:add_child(empty_lbl)
		self._list_content.size = v(pw, 80)
		return
	end

	for _, map_cfg in ipairs(self._maps) do
		local card = KView:new(V.v(pw, card_h))
		card.pos = v(0, y)
		card.colors.background = C.card_bg

		-- 地图名称
		local name_lbl = KLabel:new(V.v(pw - 20, 22))
		name_lbl.pos = v(12, 6)
		name_lbl.text = map_cfg.name or "未命名"
		name_lbl.text_align = "left"
		name_lbl.colors.text = {238, 244, 255, 255}
		name_lbl.font_size = 16
		name_lbl.font_name = KE_CONST.font_name
		name_lbl.vertical_align = "middle"
		card:add_child(name_lbl)

		-- 作者和版本
		local info_lbl = KLabel:new(V.v(pw - 20, 18))
		info_lbl.pos = v(12, 30)
		info_lbl.text = (map_cfg.by or "匿名") .. "  v" .. (map_cfg.version or "1.0")
		info_lbl.text_align = "left"
		info_lbl.colors.text = C.accent
		info_lbl.font_size = 11
		info_lbl.font_name = KE_CONST.font_name
		info_lbl.vertical_align = "middle"
		card:add_child(info_lbl)

		-- 描述
		local desc_lbl = KLabel:new(V.v(pw - 100, 18))
		desc_lbl.pos = v(12, 48)
		desc_lbl.text = map_cfg.desc or ""
		desc_lbl.text_align = "left"
		desc_lbl.colors.text = {180, 190, 210, 255}
		desc_lbl.font_size = 10
		desc_lbl.font_name = KE_CONST.font_name
		desc_lbl.vertical_align = "middle"
		card:add_child(desc_lbl)

		-- 游玩按钮
		local play_btn = KButton:new(V.v(60, card_h - 10))
		play_btn.text = "游玩"
		play_btn.pos = v(pw - 70, 5)
		play_btn.colors.background = {0, 100, 0, 200}
		play_btn.colors.text = {255, 255, 255, 255}
		play_btn.font_size = 12

		-- 捕获 map_cfg 到闭包
		local captured_cfg = map_cfg
		function play_btn.on_click()
			S:queue("GUIButtonCommon")
			self:_play_map(captured_cfg)
		end
		card:add_child(play_btn)

		-- 整张卡片点击
		function card.on_click()
			S:queue("GUIButtonCommon")
			self:_play_map(captured_cfg)
		end

		-- 悬浮效果
		function card.on_enter()
			card.colors.background = C.hover
		end
		function card.on_exit()
			card.colors.background = C.card_bg
		end

		self._list_content:add_child(card)
		y = y + card_h + gap
	end

	self._list_content.size = v(pw, y)
end

function CustomMapBrowser:_play_map(map_cfg)
	self:hide()
	CustomMapBrowser.load_and_play_custom_map(map_cfg, self._done_callback)
end

-- 滚轮支持
function CustomMapBrowser:on_wheelmoved(dx, dy)
	if self.hidden then
		return
	end
	local max_scroll = math.max(0, self._list_content.size.y - self._list_view.size.y)
	self._scroll_y = km.clamp(0, max_scroll, self._scroll_y - dy * 40)
	self._list_content.pos = v(0, -self._scroll_y)
end

return CustomMapBrowser
