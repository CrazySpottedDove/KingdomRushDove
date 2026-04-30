-- chunkname: @./all/game_editor_wave_config.lua
-- 地图编辑器 - 出怪配置编辑器（随机出怪参数配置）
local log = require("lib.klua.log"):new("wave_config")
local km = require("lib.klua.macros")
require("lib.klua.table")
require("klove.kui")
require("gg_views_custom")
local V = require("lib.klua.vector")
local v = V.v
local serpent = require("serpent")
local E = require("entity_db")

local WaveConfigView = class("WaveConfigView", PopUpView)

local C = {
	bg = {16, 20, 32, 255},
	panel = {26, 33, 50, 255},
	text = {205, 218, 248, 255},
	accent = {195, 148, 38, 255},
	input_bg = {22, 28, 42, 255},
	button_bg = {36, 46, 68, 255}
}

-- 预设函数选项
local WAVE_WEIGHT_PRESETS = {
	["标准 (50 + gold^0.95/18)"] = "function(wave_number, total_gold) return 50 + (total_gold ^ 0.95) / 18 end",
	["简单 (30 + gold^0.9/20)"] = "function(wave_number, total_gold) return 30 + (total_gold ^ 0.9) / 20 end",
	["困难 (80 + gold^1.0/15)"] = "function(wave_number, total_gold) return 80 + (total_gold ^ 1.0) / 15 end",
	["线性增长 (10*wave)"] = "function(wave_number, total_gold) return 10 * wave_number end"
}

local INTERVAL_PRESETS = {
	["标准 (25+100*log(weight))*20/speed*(1-wave/15*0.6)"] = "function(weight, e, wave_number) return (25 + 100 * math.log(weight)) * 20 / e.motion.max_speed * (1 - wave_number / 15 * 0.6) end",
	["快速 (15+50*log(weight))*15/speed"] = "function(weight, e, wave_number) return (15 + 50 * math.log(weight)) * 15 / e.motion.max_speed end",
	["慢速 (40+150*log(weight))*25/speed"] = "function(weight, e, wave_number) return (40 + 150 * math.log(weight)) * 25 / e.motion.max_speed end"
}

function WaveConfigView:initialize(sw, sh, editor)
	PopUpView.initialize(self, V.v(sw, sh))
	self.colors.background = {0, 0, 0, 160}
	self.editor = editor
	self.level_idx = editor.store.level_idx or 1
	self.level_mode = editor.store.level_mode or GAME_MODE_CAMPAIGN
	self.config = self:_load_config()

	-- 生成结果缓存
	self._generated_waves = nil

	local pw, ph = 1100, 720
	local panel = KView:new(V.v(pw, ph))
	panel.colors.background = C.bg
	panel.anchor = v(pw / 2, ph / 2)
	panel.pos = v(sw / 2, sh / 2)
	self:add_child(panel)
	self.panel = panel

	-- 标题
	local title = KLabel:new(V.v(pw, 36))
	title.text = "出怪配置编辑器 - Level " .. string.format("%02d", self.level_idx)
	title.text_align = "center"
	title.vertical_align = "middle"
	title.colors.text = {238, 244, 255, 255}
	title.colors.background = C.panel
	title.font_size = 16
	title.font_name = KE_CONST.font_name
	title.pos = v(0, 0)
	panel:add_child(title)

	-- 关闭按钮
	local close_btn = KButton:new(V.v(30, 30))
	close_btn.text = "X"
	close_btn.pos = v(pw - 35, 5)
	close_btn.colors.background = {120, 50, 50, 255}
	close_btn.colors.text = {255, 255, 255, 255}
	function close_btn.on_click()
		self:hide()
	end

	panel:add_child(close_btn)

	-- 内容区域（用滚动视图）
	local content_y = 40
	local content_h = ph - content_y - 55

	self._scroll_y = 0
	self._content_view = KView:new(V.v(pw - 20, content_h))
	self._content_view.pos = v(10, content_y)
	self._content_view.clip = true
	self._content_view.colors.background = C.input_bg
	panel:add_child(self._content_view)

	self._content_inner = KView:new(V.v(pw - 20, 0))
	self._content_inner.pos = v(0, 0)
	self._content_view:add_child(self._content_inner)

	-- 构建配置编辑界面
	self:_build_config_ui()

	-- 底部按钮
	local btn_y = ph - 48
	local gen_btn = KEButton:new("生成出怪并预览")
	gen_btn.size = v(160, 30)
	gen_btn.pos = v(20, btn_y)
	gen_btn.text_offset = V.v(0, (30 - KE_CONST.font_size) / 2)
	gen_btn.colors.background = {0, 80, 0, 200}
	function gen_btn.on_click()
		self:_generate_waves()
	end

	panel:add_child(gen_btn)

	local save_btn = KEButton:new("保存配置")
	save_btn.size = v(120, 30)
	save_btn.pos = v(200, btn_y)
	save_btn.text_offset = V.v(0, (30 - KE_CONST.font_size) / 2)
	function save_btn.on_click()
		self:_save_config()
	end

	panel:add_child(save_btn)

	local preview_btn = KEButton:new("显示预览")
	preview_btn.size = v(120, 30)
	preview_btn.pos = v(340, btn_y)
	preview_btn.text_offset = V.v(0, (30 - KE_CONST.font_size) / 2)
	function preview_btn.on_click()
		self:_show_preview()
	end

	panel:add_child(preview_btn)

	local close_btn2 = KEButton:new("关闭")
	close_btn2.size = v(100, 30)
	close_btn2.pos = v(pw - 120, btn_y)
	close_btn2.text_offset = V.v(0, (30 - KE_CONST.font_size) / 2)
	function close_btn2.on_click()
		self:hide()
	end

	panel:add_child(close_btn2)
end

function WaveConfigView:_build_config_ui()
	self._fields = {}
	local y = 4
	local pw = self._content_view.size.x - 40
	local fh = 22

	-- 辅助函数：创建输入行
	local function add_field(label, key, default_val, type_hint)
		local row = KView:new(V.v(pw + 40, fh + 4))
		row.pos = v(0, y)

		local lbl = KLabel:new(V.v(200, fh))
		lbl.pos = v(4, 2)
		lbl.text = label
		lbl.text_align = "left"
		lbl.colors.text = C.accent
		lbl.font_size = 11
		lbl.font_name = KE_CONST.font_name
		lbl.vertical_align = "middle"
		row:add_child(lbl)

		local val = self.config[key]
		if val == nil then
			val = default_val
		end

		local input = self:_create_field_input(pw - 200, fh, val, type_hint)
		input.pos = v(210, 2)
		row:add_child(input)

		self._content_inner:add_child(row)
		self._fields[key] = input
		y = y + fh + 6
		return input
	end

	-- 辅助函数：添加分隔标题
	local function add_section(title_text)
		local sec = KESep:new(title_text)
		sec.size = v(pw + 40, 20)
		sec.pos = v(0, y)
		self._content_inner:add_child(sec)
		y = y + 22
	end

	-- ====== 基本参数 ======
	add_section("基本参数")
	add_field("最大波次 (max_waves)", "max_waves", 15, "number")
	add_field("初始金币 (initial_cash)", "initial_cash", 800, "number")
	add_field("波次间隔-起始 (initial_interval)", "initial_interval", 800, "number")
	add_field("波次间隔-最终 (final_interval)", "final_interval", 1600, "number")

	-- ====== 路径配置 ======
	add_section("路径配置")
	add_field("可用路径列表 (paths)", "paths", {1, 2}, "path_list")

	-- ====== 出怪参数 ======
	add_section("出怪参数")
	add_field("最小出怪权重 (min_spawn_weight)", "min_spawn_weight", 8, "number")
	add_field("最大出怪权重 (max_spawn_weight)", "max_spawn_weight", 48, "number")
	add_field("每波最大敌种类 (wave_max_types)", "wave_max_types", 5, "number")

	-- ====== 函数配置 ======
	add_section("函数配置（选择预设）")
	add_field("波次权重函数", "wave_weight_preset", "标准 (50 + gold^0.95/18)", "wave_weight_preset")
	add_field("出怪间隔函数", "interval_preset", "标准 (25+100*log(weight))*20/speed*(1-wave/15*0.6)", "interval_preset")

	self._content_inner.size = v(pw + 40, y)
end

function WaveConfigView:_create_field_input(w, h, value, type_hint)
	local container = KView:new(V.v(w, h))

	if type_hint == "number" then
		container.colors.background = C.input_bg
		local label = KLabel:new(V.v(w - 4, h))
		label.pos = v(2, 0)
		label.text = tostring(value)
		label.text_align = "left"
		label.colors.text = C.text
		label.font_size = 11
		label.font_name = KE_CONST.font_name
		label.vertical_align = "middle"
		container:add_child(label)
		container.get_value = function()
			return tonumber(label.text) or 0
		end
		container.set_value = function(self, v)
			label.text = tostring(v)
		end

		-- +/- buttons
		local bw = 14
		local inc = KButton:new(V.v(bw, h / 2 - 1))
		inc.text = "+"
		inc.pos = v(w - bw, 0)
		inc.colors.background = C.button_bg
		inc.colors.text = {255, 255, 255, 255}
		inc.font_size = 9
		function inc.on_click()
			local nv = (tonumber(label.text) or 0) + 1
			label.text = tostring(nv)
		end

		container:add_child(inc)

		local dec = KButton:new(V.v(bw, h / 2 - 1))
		dec.text = "-"
		dec.pos = v(w - bw, h / 2 + 1)
		dec.colors.background = C.button_bg
		dec.colors.text = {255, 255, 255, 255}
		dec.font_size = 9
		function dec.on_click()
			local nv = math.max(0, (tonumber(label.text) or 0) - 1)
			label.text = tostring(nv)
		end

		container:add_child(dec)
	elseif type_hint == "path_list" then
		container.colors.background = C.input_bg
		local label = KLabel:new(V.v(w - 4, h))
		label.pos = v(2, 0)
		label.text = table.concat(value or {}, ",")
		label.text_align = "left"
		label.colors.text = C.text
		label.font_size = 10
		label.font_name = KE_CONST.font_name
		label.vertical_align = "middle"
		container:add_child(label)
		container.get_value = function()
			local parts = {}
			for s in string.gmatch(label.text, "(%d+)") do
				table.insert(parts, tonumber(s))
			end
			return #parts > 0 and parts or {1, 2}
		end
		container.set_value = function(self, v)
			label.text = table.concat(v or {}, ",")
		end
	elseif type_hint == "wave_weight_preset" or type_hint == "interval_preset" then
		container.colors.background = C.input_bg
		local label = KLabel:new(V.v(w - 4, h))
		label.pos = v(2, 0)
		label.text = tostring(value)
		label.text_align = "left"
		label.colors.text = C.text
		label.font_size = 10
		label.font_name = KE_CONST.font_name
		label.vertical_align = "middle"
		container:add_child(label)
		container.get_value = function()
			return label.text
		end
		container.set_value = function(self, v)
			label.text = tostring(v)
		end

		-- 点击切换预设
		local presets = type_hint == "wave_weight_preset" and WAVE_WEIGHT_PRESETS or INTERVAL_PRESETS
		local keys = {}
		for k, _ in pairs(presets) do
			table.insert(keys, k)
		end
		table.sort(keys)

		local bw2 = 40
		local toggle = KButton:new(V.v(bw2, h))
		toggle.text = "切换"
		toggle.pos = v(w - 42, 0)
		toggle.colors.background = C.button_bg
		toggle.colors.text = {255, 255, 255, 255}
		toggle.font_size = 9
		local current_idx = 1
		function toggle.on_click()
			current_idx = current_idx % #keys + 1
			label.text = keys[current_idx]
		end

		container:add_child(toggle)
	end

	return container
end

function WaveConfigView:_load_config()
	local game_mode_str_map = {
		[GAME_MODE_CAMPAIGN] = "campaign",
		[GAME_MODE_HEROIC] = "heroic",
		[GAME_MODE_IRON] = "iron"
	}
	local file_name = string.format("data.waveconfigs.level%02d_waves_%s_config", self.level_idx, game_mode_str_map[self.level_mode])

	package.loaded[file_name] = nil
	local ok, cfg = pcall(function()
		return require(file_name)
	end)

	if ok and cfg then
		return cfg
	end

	-- 默认配置
	return {
		max_waves = 15,
		initial_cash = 800,
		initial_interval = 800,
		final_interval = 1600,
		paths = {1, 2},
		min_spawn_weight = 8,
		max_spawn_weight = 48,
		wave_max_types = 5,
		wave_weight_preset = "标准 (50 + gold^0.95/18)",
		interval_preset = "标准 (25+100*log(weight))*20/speed*(1-wave/15*0.6)"
	}
end

function WaveConfigView:_build_full_config()
	local cfg = {
		max_waves = self:_get_field("max_waves", 15),
		initial_cash = self:_get_field("initial_cash", 800),
		initial_interval = self:_get_field("initial_interval", 800),
		final_interval = self:_get_field("final_interval", 1600),
		paths = self:_get_field("paths", {1, 2}),
		path_active_map = {},
		path_weight_map = {},
		path_enemy_map = {},
		enemy_weight_map = {},
		enemy_comeout_wave_map = {},
		min_spawn_weight = self:_get_field("min_spawn_weight", 8),
		max_spawn_weight = self:_get_field("max_spawn_weight", 48),
		wave_max_types = self:_get_field("wave_max_types", 5),
		interval_next_factor = 1,
		gap_count_range = {1, 2}
	}

	-- 设置默认的路径映射
	for _, p in ipairs(cfg.paths) do
		cfg.path_active_map[p] = p
		cfg.path_weight_map[p] = 5
		cfg.path_enemy_map[p] = {"enemy_goblin"}
	end
	cfg.path_active_map[1] = 1

	-- 敌人权重
	cfg.enemy_weight_map["enemy_goblin"] = 1
	cfg.enemy_comeout_wave_map["enemy_goblin"] = 1

	-- 函数配置
	local wp = self:_get_field("wave_weight_preset", "标准 (50 + gold^0.95/18)")
	local ip = self:_get_field("interval_preset", "标准 (25+100*log(weight))*20/speed*(1-wave/15*0.6)")

	local wf_src = WAVE_WEIGHT_PRESETS[wp] or WAVE_WEIGHT_PRESETS["标准 (50 + gold^0.95/18)"]
	local intf_src = INTERVAL_PRESETS[ip] or INTERVAL_PRESETS["标准 (25+100*log(weight))*20/speed*(1-wave/15*0.6)"]

	local ok_wf, wf = pcall(loadstring("return " .. wf_src))
	if ok_wf and wf then
		cfg.wave_weight_function = wf
	end

	local ok_intf, intf = pcall(loadstring("return " .. intf_src))
	if ok_intf and intf then
		cfg.interval_function = intf
	end

	return cfg
end

function WaveConfigView:_get_field(key, default)
	local input = self._fields[key]
	if input and input.get_value then
		return input:get_value()
	end
	return default
end

function WaveConfigView:_generate_waves()
	-- 构建完整配置
	local cfg = self:_build_full_config()

	-- 临时保存到 package.loaded 以便 gen_wave 读取
	local game_mode_str_map = {
		[GAME_MODE_CAMPAIGN] = "campaign",
		[GAME_MODE_HEROIC] = "heroic",
		[GAME_MODE_IRON] = "iron"
	}
	local cfg_name = string.format("data.waveconfigs.level%02d_waves_%s_config", self.level_idx, game_mode_str_map[self.level_mode])

	-- 先清除缓存
	package.loaded[cfg_name] = nil
	-- 注入配置（gen_wave 会 require 这个模块名）
	package.loaded[cfg_name] = {
		data = cfg
	}
	-- 但 gen_wave 直接 require 并期望返回 data，所以需要重新注入
	-- 直接调用 gen_wave，它会 require 我们的配置

	-- 我们需要把临时配置存成 require 可读的形式
	-- 简单方式：直接将 cfg 保存到 package.loaded 的模块返回值
	local mod = function()
		return cfg
	end
	package.loaded[cfg_name] = {
		data = cfg
	}
	-- 修改 gen_wave 调用的行为，这里我们直接调用底层生成逻辑

	-- 实际上 gen_wave 调用 require 得到的是文件返回值，不支持函数
	-- 我们使用自己的生成逻辑简化版
	self:_simple_generate(cfg)
end

function WaveConfigView:_simple_generate(cfg)
	local result = {
		lives = 20,
		cash = cfg.initial_cash or 800,
		groups = {}
	}

	local num_waves = cfg.max_waves or 15

	for wave_i = 1, num_waves do
		local interval = cfg.initial_interval + (cfg.final_interval - cfg.initial_interval) * (wave_i - 1) / math.max(1, num_waves - 1)

		local group = {
			interval = math.floor(interval),
			waves = {}
		}

		-- 每个路径生成一个子波
		for _, path_idx in ipairs(cfg.paths or {1}) do
			-- 根据 wave_weight_function 估算权重
			local total_weight = 50
			if cfg.wave_weight_function then
				total_weight = cfg.wave_weight_function(wave_i, result.cash)
			end

			local enemies = cfg.path_enemy_map and cfg.path_enemy_map[path_idx] or {"enemy_goblin"}
			local spawns = {}

			for _, enemy_name in ipairs(enemies) do
				local weight = (cfg.enemy_weight_map and cfg.enemy_weight_map[enemy_name]) or 1
				local count = math.max(1, math.floor(total_weight / weight / #enemies))

				-- 检查出场波次
				local comeout = cfg.enemy_comeout_wave_map and cfg.enemy_comeout_wave_map[enemy_name] or 1
				if wave_i >= comeout then
					table.insert(spawns, {
						interval = 50,
						interval_next = 50,
						creep = enemy_name,
						path = 1,
						fixed_sub_path = 0,
						max_same = 0,
						max = count
					})
				end
			end

			if #spawns > 0 then
				table.insert(group.waves, {
					delay = 0,
					path_index = path_idx,
					spawns = spawns
				})
			end
		end

		if #group.waves > 0 then
			table.insert(result.groups, group)
		end
	end

	self._generated_waves = result
	log.info("Generated %d waves with %d total gold", #result.groups, result.cash)

	if self.editor and self.editor.gui then
		self.editor.gui:show_save_notification(string.format("已生成 %d 波出怪数据", #result.groups))
	end
end

function WaveConfigView:_show_preview()
	if not self._generated_waves then
		if self.editor and self.editor.gui then
			self.editor.gui:show_save_notification("请先生成出怪数据")
		end
		return
	end

	-- 弹出预览面板（复用出怪编辑器的显示风格）
	self:hide()

	if self.editor and self.editor.gui then
		local WaveEditorView = require("game_editor_wave_editor")
		local preview = WaveEditorView:new(self.editor.gui.sw, self.editor.gui.sh, self.editor)
		-- 替换 wave_data 为生成的出怪数据
		preview.wave_data = self._generated_waves
		preview:_rebuild_wave_list()
		-- 替换保存按钮行为：保存生成的出怪到文件
		preview._save_wave_data = function(wv)
			local level_name = "level" .. string.format("%02i", self.level_idx)
			local mode_str = "campaign"
			if self.level_mode == GAME_MODE_HEROIC then
				mode_str = "heroic"
			elseif self.level_mode == GAME_MODE_IRON then
				mode_str = "iron"
			end
			local serpent = require("serpent")
			local str = serpent.block(self._generated_waves, {
				indent = "    ",
				comment = false,
				sortkeys = false
			})
			local file_name = level_name .. "_waves_" .. mode_str .. ".lua"
			local fn = KR_FULLPATH_BASE .. "/" .. KR_PATH_GAME .. "/data/waves/" .. file_name
			local out = "return " .. str .. "\n"
			local f = io.open(fn, "w")
			if f then
				f:write(out)
				f:flush()
				f:close()
				self.editor.gui:show_save_notification("已保存出怪: " .. file_name)
			else
				self.editor.gui:show_save_notification("保存失败!")
			end
			wv:hide()
		end
		self.editor.gui.window:add_child(preview)
		self.editor.gui._preview_editor = preview -- 保存引用以便滚轮转发
		preview:show()
	end
end

function WaveConfigView:_save_config()
	-- 读取所有字段值
	local cfg = self:_build_full_config()
	cfg.wave_weight_function = nil
	cfg.interval_function = nil

	-- 保存函数源码
	local wp = self:_get_field("wave_weight_preset", "标准 (50 + gold^0.95/18)")
	local ip = self:_get_field("interval_preset", "标准 (25+100*log(weight))*20/speed*(1-wave/15*0.6)")

	local wf_src = WAVE_WEIGHT_PRESETS[wp]
	local intf_src = INTERVAL_PRESETS[ip]

	-- 序列化
	local data_str = "local data=" .. serpent.block(cfg, {
		indent = "    ",
		comment = false,
		sortkeys = false
	})

	-- 添加函数
	if wf_src then
		data_str = data_str .. "\n" .. "data.wave_weight_function=" .. wf_src
	end
	if intf_src then
		data_str = data_str .. "\n" .. "data.interval_function=" .. intf_src
	end

	local game_mode_str_map = {
		[GAME_MODE_CAMPAIGN] = "campaign",
		[GAME_MODE_HEROIC] = "heroic",
		[GAME_MODE_IRON] = "iron"
	}
	local file_name = string.format("level%02d_waves_%s_config.lua", self.level_idx, game_mode_str_map[self.level_mode])
	local fn = KR_FULLPATH_BASE .. "/" .. KR_PATH_GAME .. "/data/waveconfigs/" .. file_name

	local out = data_str .. "\nreturn data\n"
	local f = io.open(fn, "w")
	if f then
		f:write(out)
		f:flush()
		f:close()
		log.info("Wave config saved to: %s", fn)
		if self.editor and self.editor.gui then
			self.editor.gui:show_save_notification("出怪配置已保存: " .. file_name)
		end
	else
		log.error("Failed to save wave config: %s", fn)
		if self.editor and self.editor.gui then
			self.editor.gui:show_save_notification("保存失败!")
		end
	end
end

return WaveConfigView
