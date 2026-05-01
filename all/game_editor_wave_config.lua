require("klove.kui")
require("gg_views_custom")
require("lib.klua.table")

local V = require("lib.klua.vector")
local v = V.v
local G = love.graphics
local serpent = require("serpent")
local interface = require("dove_modules.wave_generator.interface")
local E = require("entity_db")

local WaveConfigView = class("WaveConfigView", PopUpView)

local MODE_SUFFIX = {
	[GAME_MODE_CAMPAIGN] = "campaign",
	[GAME_MODE_HEROIC] = "heroic",
	[GAME_MODE_IRON] = "iron"
}

local C = {
	bg = {248, 248, 248, 255},
	panel = {234, 234, 234, 255},
	text = {18, 18, 18, 255},
	border = {180, 180, 180, 255},
	button = {225, 225, 225, 255}
}

local function mode_suffix_of(mode)
	return MODE_SUFFIX[mode]
end

local function config_rel_path(level_idx, level_mode)
	return string.format("game_editor/data/waveconfigs/level%02d_waves_%s_config.lua", level_idx, mode_suffix_of(level_mode))
end

local function wave_rel_path(level_idx, level_mode)
	return string.format("game_editor/data/waves/level%02d_waves_%s.lua", level_idx, mode_suffix_of(level_mode))
end

local function load_lua_table_with_pref(filename)
	local f = love.filesystem.loadWithPreference(filename, {"game_editor", KR_PATH_GAME})
	if not f then
		return nil
	end
	local ok, data = pcall(f)
	if ok and type(data) == "table" then
		return data
	end
	return nil
end

local function enemy_name_label(template_name, tpl)
	local i18n_key = tpl and tpl.info and tpl.info.i18n_key
	local prefix = string.upper(i18n_key or template_name or "")
	local cname = _(prefix .. "_NAME")
	if cname == prefix .. "_NAME" then
		cname = _(string.upper(template_name or ""))
	end
	if cname == template_name or cname == "" or cname == string.upper(template_name or "") then
		return nil
	end
	return string.format("%s (%s)", template_name, cname)
end

local function enemy_cn_only(template_name)
	local tpl = E.entities and E.entities[template_name] or nil
	local label = enemy_name_label(template_name, tpl)
	if not label then
		return "未知敌人"
	end
	return label:match("%((.+)%)$") or "未知敌人"
end

local function hook_button_feedback(btn)
	local base = btn.colors and btn.colors.background or {56, 72, 102, 255}
	local hover = {math.min(255, base[1] + 16), math.min(255, base[2] + 16), math.min(255, base[3] + 16), base[4] or 255}
	local down = {math.max(0, base[1] - 14), math.max(0, base[2] - 14), math.max(0, base[3] - 14), base[4] or 255}
	function btn.on_enter(this)
		this.colors.background = hover
	end
	function btn.on_exit(this)
		this.colors.background = base
	end
	function btn.on_down(this)
		this.colors.background = down
	end
	function btn.on_up(this)
		this.colors.background = hover
	end
end

function WaveConfigView:initialize(sw, sh, editor)
	PopUpView.initialize(self, V.v(sw, sh))
	self.colors.background = {0, 0, 0, 150}
	self.editor = editor
	self.level_idx = editor.store.level_idx
	self.level_mode = editor.store.level_mode
	self.level_name = editor.store.level_name
	self.config = self:_load_config()
	self._scroll = 0
	self._generated_waves = nil
	self._enemy_rows = nil
	self._active_enemy_prop = nil

	local pw, ph = 1080, 700
	local panel = KView:new(V.v(pw, ph))
	panel.colors.background = C.bg
	panel.anchor = v(pw * 0.5, ph * 0.5)
	panel.pos = v(sw * 0.5, sh * 0.5)
	self:add_child(panel)
	self.panel = panel

	local title = KLabel:new(V.v(pw, 34))
	title.text = "出怪配置"
	title.text_align = "center"
	title.vertical_align = "middle"
	title.colors.background = C.panel
	title.colors.text = C.text
	panel:add_child(title)

	local close_btn = KButton:new(V.v(26, 24))
	close_btn.text = "X"
	close_btn.pos = v(pw - 30, 5)
	close_btn.colors.background = {220, 180, 180, 255}
	close_btn.colors.text = C.text
	function close_btn.on_click()
		self:hide()
	end
	hook_button_feedback(close_btn)
	panel:add_child(close_btn)

	self._content_view = KView:new(V.v(pw - 20, ph - 96))
	self._content_view.pos = v(10, 40)
	self._content_view.clip = true
	self._content_view.colors.background = {255, 255, 255, 255}
	panel:add_child(self._content_view)

	self._content = KView:new(V.v(self._content_view.size.x, 0))
	self._content_view:add_child(self._content)
	self._scrollbar = KView:new(v(6, 10))
	self._scrollbar.pos = v(self._content_view.size.x - 8, 0)
	self._scrollbar.colors.background = {110, 126, 160, 180}
	self._content_view:add_child(self._scrollbar)
	self._drag_scrollbar = false
	self._drag_last_mouse_y = 0
	function self._scrollbar.on_down(this, button)
		if button == 1 then
			self._drag_scrollbar = true
			self._drag_last_mouse_y = select(2, love.mouse.getPosition())
		end
	end
	function self._scrollbar.on_up(this, button)
		if button == 1 then
			self._drag_scrollbar = false
		end
	end
	self._enemy_hint = KView:new(v(320, 170))
	self._enemy_hint.colors.background = {245, 245, 245, 255}
	self._enemy_hint.hidden = true
	self._enemy_hint.clip = true
	self.panel:add_child(self._enemy_hint)
	self._enemy_hint_content = KView:new(v(self._enemy_hint.size.x, 0))
	self._enemy_hint:add_child(self._enemy_hint_content)
	self._enemy_hint_index = 1
	self._enemy_hint_items = {}
	self._enemy_hint_all = {}
	self._enemy_hint_offset = 1
	self._hint_cache_key = nil

	self:_build_form()

	local save_cfg = KEButton:new("保存配置")
	save_cfg.size = v(120, 30)
	save_cfg.pos = v(20, ph - 44)
	save_cfg.colors.background = C.button
	function save_cfg.on_click()
		self:_save_config()
	end
	hook_button_feedback(save_cfg)
	panel:add_child(save_cfg)

	local gen_btn = KEButton:new("生成出怪")
	gen_btn.size = v(120, 30)
	gen_btn.pos = v(154, ph - 44)
	gen_btn.colors.background = C.button
	function gen_btn.on_click()
		self:_generate_waves()
	end
	hook_button_feedback(gen_btn)
	panel:add_child(gen_btn)

	local save_wave_btn = KEButton:new("保存出怪")
	save_wave_btn.size = v(120, 30)
	save_wave_btn.pos = v(288, ph - 44)
	save_wave_btn.colors.background = C.button
	function save_wave_btn.on_click()
		self:_save_waves()
	end
	hook_button_feedback(save_wave_btn)
	panel:add_child(save_wave_btn)

	local preview_btn = KEButton:new("出怪预览")
	preview_btn.size = v(120, 30)
	preview_btn.pos = v(422, ph - 44)
	preview_btn.colors.background = C.button
	function preview_btn.on_click()
		self:_show_preview()
	end
	hook_button_feedback(preview_btn)
	panel:add_child(preview_btn)

	local add_group_btn = KEButton:new("+ 新增波")
	add_group_btn.size = v(120, 30)
	add_group_btn.pos = v(556, ph - 44)
	function add_group_btn.on_click()
		self:_append_group()
	end
	hook_button_feedback(add_group_btn)
	panel:add_child(add_group_btn)

	local glossary_btn = KEButton:new("怪物一览表")
	glossary_btn.size = v(130, 30)
	glossary_btn.pos = v(690, ph - 44)
	function glossary_btn.on_click()
		self:_show_enemy_glossary()
	end
	hook_button_feedback(glossary_btn)
	panel:add_child(glossary_btn)
end

function WaveConfigView:_bind_enemy_prop_keys(prop)
	local owner = self
	function prop.on_keypressed(this, key)
		if owner._enemy_hint and not owner._enemy_hint.hidden and #owner._enemy_hint_all > 0 then
			if key == "down" then
				owner._enemy_hint_index = math.min(#owner._enemy_hint_all, owner._enemy_hint_index + 1)
				owner:_refresh_enemy_hint_focus()
				return true
			elseif key == "up" then
				owner._enemy_hint_index = math.max(1, owner._enemy_hint_index - 1)
				owner:_refresh_enemy_hint_focus()
				return true
			elseif key == "return" or key == "kpenter" then
				owner:_accept_enemy_hint(owner._enemy_hint_all[owner._enemy_hint_index].name)
				return true
			elseif key == "escape" then
				owner._enemy_hint.hidden = true
				return true
			end
		end
		return KEProp.on_keypressed(this, key)
	end
end

function WaveConfigView:_create_prop(title, value)
	local p = KEProp:new(title, tostring(value or ""), true)
	return p
end

function WaveConfigView:_build_form()
	self._content:remove_children()
	self._fields = {
		groups = {}
	}

	local y = 8

	local lives = self:_create_prop("生命值(lives)", self.config.lives or 20)
	lives.pos = v(10, y)
	self._content:add_child(lives)
	self._fields.lives = lives

	local cash = self:_create_prop("初始金币(cash)", self.config.cash or 800)
	cash.pos = v(220, y)
	self._content:add_child(cash)
	self._fields.cash = cash
	y = y + 46

	for gi, group in ipairs(self.config.groups or {}) do
		local sep = KLabel:new(V.v(self._content_view.size.x - 20, 24))
		sep.pos = v(10, y)
		sep.text = string.format("第 %d 波", gi)
		sep.vertical_align = "middle"
		sep.colors.background = C.panel
		sep.colors.text = C.text
		self._content:add_child(sep)
		local del_group_btn = KButton:new(v(88, 24))
		del_group_btn.pos = v(self._content_view.size.x - 122, y)
		del_group_btn.text = "删除波"
		del_group_btn.colors.background = {180, 80, 80, 255}
		del_group_btn.colors.text = {255, 255, 255, 255}
		function del_group_btn.on_click()
			self:_remove_group(gi)
		end
		hook_button_feedback(del_group_btn)
		self._content:add_child(del_group_btn)
		y = y + 28

		local g_interval = self:_create_prop("波的长度(秒)", group.interval)
		g_interval.pos = v(10, y)
		self._content:add_child(g_interval)

		local g_gold = self:_create_prop("该波总金币", group.total_gold)
		g_gold.pos = v(220, y)
		self._content:add_child(g_gold)
		y = y + 46

		self._fields.groups[gi] = {
			interval = g_interval,
			total_gold = g_gold,
			waves = {}
		}

		for wi, wave in ipairs(group.waves or {}) do
			local w_delay = self:_create_prop(string.format("子波%d 延迟秒(delay)", wi), wave.delay or 0)
			w_delay.pos = v(40, y)
			self._content:add_child(w_delay)

			local w_rest = self:_create_prop(string.format("子波%d 留白秒(rest)", wi), wave.rest or 0)
			w_rest.pos = v(250, y)
			self._content:add_child(w_rest)

			local w_path = self:_create_prop(string.format("子波%d 路径(path_index)", wi), wave.path_index or 1)
			w_path.pos = v(460, y)
			self._content:add_child(w_path)

			y = y + 46
			local enemies_props = {}
			local wave_enemies = wave.enemies or {"enemy_goblin"}
			for ei, enemy_name in ipairs(wave_enemies) do
				local enemy_prop = self:_create_prop(string.format("子波%d 敌人%d", wi, ei), enemy_name)
				enemy_prop.pos = v(40, y)
				enemy_prop.size = v(440, enemy_prop.size.y)
				enemy_prop.lt.size = v(440, enemy_prop.lt.size.y)
				enemy_prop.lv.size = v(440, enemy_prop.lv.size.y)
				enemy_prop.input_border.size = v(442, enemy_prop.input_border.size.y)
				self._content:add_child(enemy_prop)
				self:_bind_enemy_prop_keys(enemy_prop)
				enemies_props[#enemies_props + 1] = enemy_prop

				local cn = enemy_cn_only(enemy_name)
				local cn_lb = KLabel:new(v(180, 24))
				cn_lb.pos = v(492, y + 23)
				cn_lb.text = cn
				cn_lb.vertical_align = "middle"
				cn_lb.colors.text = {80, 80, 80, 255}
				self._content:add_child(cn_lb)
				enemy_prop.on_change = function()
					cn_lb.text = enemy_cn_only(enemy_prop.value or "")
				end

				local del_enemy_btn = KButton:new(v(88, 24))
				del_enemy_btn.pos = v(680, y + 23)
				del_enemy_btn.text = "删除敌人"
				del_enemy_btn.colors.background = {160, 90, 90, 255}
				del_enemy_btn.colors.text = {255, 255, 255, 255}
				function del_enemy_btn.on_click()
					self:_remove_enemy(gi, wi, ei)
				end
				hook_button_feedback(del_enemy_btn)
				self._content:add_child(del_enemy_btn)
				y = y + 46
			end

			local add_enemy_btn = KButton:new(v(120, 24))
			add_enemy_btn.pos = v(40, y + 22)
			add_enemy_btn.text = "+ 添加敌人种类"
			add_enemy_btn.colors.background = {120, 150, 196, 255}
			add_enemy_btn.colors.text = {255, 255, 255, 255}
			function add_enemy_btn.on_click()
				self:_append_enemy(gi, wi)
			end
			hook_button_feedback(add_enemy_btn)
			self._content:add_child(add_enemy_btn)

			local del_wave_btn = KButton:new(v(88, 24))
			del_wave_btn.pos = v(680, y + 22)
			del_wave_btn.text = "删除子波"
			del_wave_btn.colors.background = {160, 90, 90, 255}
			del_wave_btn.colors.text = {255, 255, 255, 255}
			function del_wave_btn.on_click()
				self:_remove_wave(gi, wi)
			end
			hook_button_feedback(del_wave_btn)
			self._content:add_child(del_wave_btn)
			y = y + 52

			self._fields.groups[gi].waves[wi] = {
				delay = w_delay,
				rest = w_rest,
				path_index = w_path,
				enemies = enemies_props
			}
		end
		local add_wave_btn = KButton:new(v(120, 26))
		add_wave_btn.pos = v(40, y)
		add_wave_btn.text = "+ 新增子波"
		add_wave_btn.colors.background = {72, 96, 138, 255}
		add_wave_btn.colors.text = {255, 255, 255, 255}
		function add_wave_btn.on_click()
			self:_append_wave(gi)
		end
		hook_button_feedback(add_wave_btn)
		self._content:add_child(add_wave_btn)

		y = y + 34
	end

	self._content.size = v(self._content_view.size.x, y + 8)
	self:_refresh_scrollbar()
end

function WaveConfigView:_load_config()
	local cfg = load_lua_table_with_pref(string.format("data/waveconfigs/level%02d_waves_%s_config.lua", self.level_idx, mode_suffix_of(self.level_mode)))
	if type(cfg) == "table" and type(cfg.groups) == "table" then
		return cfg
	end

	return interface.config_default()
end

function WaveConfigView:_read_config_from_form()
	local cfg = {
		lives = tonumber(self._fields.lives.value) or 20,
		cash = tonumber(self._fields.cash.value) or 800,
		groups = {}
	}

	for gi, gf in ipairs(self._fields.groups) do
		local g = {
			interval = tonumber(gf.interval.value) or 30,
			total_gold = tonumber(gf.total_gold.value) or 300,
			waves = {}
		}
		for wi, wf in ipairs(gf.waves) do
			g.waves[#g.waves + 1] = {
				delay = tonumber(wf.delay.value) or 0,
				rest = tonumber(wf.rest.value) or 0,
				path_index = tonumber(wf.path_index.value) or 1,
				enemies = {}
			}
			for _, enemy_prop in ipairs(wf.enemies or {}) do
				local enemy_name = (enemy_prop.value or ""):gsub("^%s+", ""):gsub("%s+$", "")
				if enemy_name ~= "" then
					g.waves[#g.waves].enemies[#g.waves[#g.waves].enemies + 1] = enemy_name
				end
			end
			if #g.waves[#g.waves].enemies == 0 then
				g.waves[#g.waves].enemies = {"enemy_goblin"}
			end
		end
		cfg.groups[#cfg.groups + 1] = g
	end

	return cfg
end

function WaveConfigView:_save_config()
	local cfg = self:_read_config_from_form()
	local rel = config_rel_path(self.level_idx, self.level_mode)
	love.filesystem.createDirectory("game_editor/data/waveconfigs")
	local out = "return " .. serpent.block(cfg, {
		indent = "    ",
		comment = false,
		sortkeys = false
	}) .. "\n"
	if love.filesystem.write(rel, out) then
		self.editor.gui:show_save_notification("出怪配置已保存", true)
	else
		self.editor.gui:show_save_notification("出怪配置保存失败", false)
	end
end

function WaveConfigView:_generate_waves()
	local cfg = self:_read_config_from_form()
	self.config = cfg
	self._generated_waves = {
		lives = cfg.lives,
		cash = cfg.cash,
		groups = {}
	}
	for _, group in ipairs(cfg.groups) do
		self._generated_waves.groups[#self._generated_waves.groups + 1] = interface.generate_group(group)
	end
	self.editor.wave_data = table.deepclone(self._generated_waves)
	self.editor:refresh_required_assets()
	self.editor.gui:show_save_notification("生成出怪成功", true)
end

function WaveConfigView:_save_waves()
	local cfg = self:_read_config_from_form()
	self.config = cfg
	local result = {
		lives = cfg.lives,
		cash = cfg.cash,
		groups = {}
	}

	for _, group in ipairs(cfg.groups) do
		result.groups[#result.groups + 1] = interface.generate_group(group)
	end
	self._generated_waves = result
	local rel = wave_rel_path(self.level_idx, self.level_mode)
	love.filesystem.createDirectory("game_editor/data/waves")
	local ok = love.filesystem.write(rel, "return " .. serpent.block(result, {
		indent = "    ",
		comment = false,
		sortkeys = false
	}) .. "\n")
	if ok then
		self.editor.wave_data = table.deepclone(result)
		self.editor:refresh_required_assets()
		self.editor.gui:show_save_notification("出怪文件已保存", true)
	else
		self.editor.gui:show_save_notification("出怪文件保存失败", false)
	end
end

function WaveConfigView:_show_preview()
	local WaveEditorView = require("game_editor_wave_editor")
	local cfg = self:_read_config_from_form()
	local source = {
		lives = cfg.lives,
		cash = cfg.cash,
		groups = {}
	}
	for _, group in ipairs(cfg.groups) do
		source.groups[#source.groups + 1] = interface.generate_group(group)
	end
	self._generated_waves = table.deepclone(source)
	local preview = WaveEditorView:new(self.editor.gui.sw, self.editor.gui.sh, self.editor, {
		wave_data = table.deepclone(source),
		level_idx = self.level_idx,
		level_mode = self.level_mode
	})
	self.editor.gui.window:add_child(preview)
	self.editor.gui._preview_editor = preview
	preview:show()
end

function WaveConfigView:_on_scroll(dy)
	local max_scroll = math.max(0, self._content.size.y - self._content_view.size.y)
	self._scroll = math.max(0, math.min(max_scroll, self._scroll - dy * 24))
	self._content.pos = v(0, -self._scroll)
	self:_refresh_scrollbar()
	if not self._enemy_hint.hidden then
		self:_rebuild_enemy_hint()
	end
end

function WaveConfigView:_refresh_scrollbar()
	local max_scroll = math.max(0, self._content.size.y - self._content_view.size.y)
	if max_scroll <= 0 then
		self._scrollbar.hidden = true
		return
	end
	self._scrollbar.hidden = false
	local ratio = self._content_view.size.y / math.max(self._content.size.y, 1)
	local h = math.max(24, math.floor(self._content_view.size.y * ratio))
	local t = self._scroll / max_scroll
	self._scrollbar.size = v(self._scrollbar.size.x, h)
	if not self._drag_scrollbar then
		self._scrollbar.pos = v(self._content_view.size.x - 8, math.floor((self._content_view.size.y - h) * t))
	end
end

function WaveConfigView:_sync_scroll_from_bar()
	local max_scroll = math.max(0, self._content.size.y - self._content_view.size.y)
	if max_scroll <= 0 then
		return
	end
	local track = math.max(1, self._content_view.size.y - self._scrollbar.size.y)
	local t = math.max(0, math.min(1, self._scrollbar.pos.y / track))
	self._scroll = t * max_scroll
	self._content.pos = v(0, -self._scroll)
end

function WaveConfigView:_append_group()
	local cfg = self:_read_config_from_form()
	cfg.groups[#cfg.groups + 1] = {
		interval = 30,
		total_gold = 300,
		waves = {{
			delay = 0,
			rest = 5,
			path_index = 1,
			enemies = {"enemy_goblin"}
		}}
	}
	self.config = cfg
	self:_build_form()
end

function WaveConfigView:_remove_group(gi)
	if not self.config.groups or #self.config.groups <= 1 then
		self.editor.gui:show_save_notification("至少保留 1 个波次", false)
		return
	end
	table.remove(self.config.groups, gi)
	self:_build_form()
end

function WaveConfigView:_append_wave(gi)
	self.config = self:_read_config_from_form()
	local group = self.config.groups[gi]
	group.waves[#group.waves + 1] = {
		delay = 0,
		rest = 5,
		path_index = 1,
		enemies = {"enemy_goblin"}
	}
	self:_build_form()
end

function WaveConfigView:_remove_wave(gi, wi)
	self.config = self:_read_config_from_form()
	local group = self.config.groups[gi]
	if not group or #group.waves <= 1 then
		self.editor.gui:show_save_notification("每个波至少保留 1 个子波", false)
		return
	end
	table.remove(group.waves, wi)
	self:_build_form()
end

function WaveConfigView:_append_enemy(gi, wi)
	self.config = self:_read_config_from_form()
	local wave = self.config.groups[gi] and self.config.groups[gi].waves[wi]
	if not wave then
		return
	end
	wave.enemies[#wave.enemies + 1] = "enemy_goblin"
	self:_build_form()
end

function WaveConfigView:_remove_enemy(gi, wi, ei)
	self.config = self:_read_config_from_form()
	local wave = self.config.groups[gi] and self.config.groups[gi].waves[wi]
	if not wave or #wave.enemies <= 1 then
		self.editor.gui:show_save_notification("每个子波至少保留 1 个敌人种类", false)
		return
	end
	table.remove(wave.enemies, ei)
	self:_build_form()
end

function WaveConfigView:_ensure_enemy_rows()
	if self._enemy_rows then
		return
	end
	E:ensure_loaded()
	self._enemy_rows = {}
	for name, tpl in pairs(E.entities or {}) do
		if string.sub(name, 1, 6) == "enemy_" and tpl.enemy then
			local label = enemy_name_label(name, tpl)
			if label then
				self._enemy_rows[#self._enemy_rows + 1] = {
					name = name,
					label = label
				}
			end
		end
	end
	table.sort(self._enemy_rows, function(a, b)
		return a.name < b.name
	end)
end

function WaveConfigView:_rebuild_enemy_hint()
	self:_ensure_enemy_rows()
	local prop = self._active_enemy_prop
	if not prop or prop.hidden or not prop.is_focused then
		self._enemy_hint.hidden = true
		return
	end
	local text = tostring(prop.value or "")
	local prefix = text:match("([^,%s]*)$") or ""
	local low = string.lower(prefix)
	if low == "" then
		self._enemy_hint.hidden = true
		return
	end
	self._enemy_hint_all = {}
	for _, row in ipairs(self._enemy_rows) do
		if string.find(string.lower(row.name), low, 1, true) then
			self._enemy_hint_all[#self._enemy_hint_all + 1] = row
		end
	end
	if #self._enemy_hint_all == 0 then
		self._enemy_hint.hidden = true
		return
	end
	self._enemy_hint_index = math.max(1, math.min(self._enemy_hint_index or 1, #self._enemy_hint_all))
	self._enemy_hint_offset = math.max(1, math.min(self._enemy_hint_offset or 1, self._enemy_hint_index))
	self:_render_enemy_hint_items()
	self._enemy_hint.hidden = false
	local left = self._content_view.pos.x + prop.lv.pos.x
	local top = self._content_view.pos.y + prop.pos.y - self._scroll
	local text_w = 0
	if G and G.getFont and G.getFont() then
		text_w = G.getFont():getWidth(tostring(prop.value or ""))
	end
	local px = math.min(self.panel.size.x - self._enemy_hint.size.x - 12, left + 8 + text_w)
	local py = top + prop.lv.pos.y + prop.lv.size.y + 2
	if py + self._enemy_hint.size.y > self.panel.size.y - 8 then
		py = top + prop.lv.pos.y - self._enemy_hint.size.y - 2
	end
	py = math.max(38, py)
	self._enemy_hint.pos = v(px, py)
end

function WaveConfigView:_render_enemy_hint_items()
	self._enemy_hint_content:remove_children()
	self._enemy_hint_items = {}
	local row_h = 26
	local max_rows = math.max(1, math.floor((self._enemy_hint.size.y - 8) / row_h))
	local max_offset = math.max(1, #self._enemy_hint_all - max_rows + 1)
	self._enemy_hint_offset = math.max(1, math.min(self._enemy_hint_offset, max_offset))
	local y = 4
	for i = self._enemy_hint_offset, math.min(#self._enemy_hint_all, self._enemy_hint_offset + max_rows - 1) do
		local row = self._enemy_hint_all[i]
		local btn = KButton:new(v(self._enemy_hint.size.x - 8, 24))
		btn.pos = v(4, y)
		btn.text = row.label
		btn.text_align = "left"
		btn.colors.background = {236, 236, 236, 255}
		btn.colors.text = {20, 20, 20, 255}
		function btn.on_click()
			self:_accept_enemy_hint(row.name)
		end
		hook_button_feedback(btn)
		self._enemy_hint_content:add_child(btn)
		self._enemy_hint_items[#self._enemy_hint_items + 1] = {
			name = row.name,
			idx = i,
			btn = btn
		}
		y = y + row_h
	end
	self._enemy_hint_content.size = v(self._enemy_hint.size.x, y + 4)
	self:_refresh_enemy_hint_focus()
end

function WaveConfigView:_accept_enemy_hint(name)
	local prop = self._active_enemy_prop
	if not prop or not name then
		return
	end
	prop:set_value(name)
	self._enemy_hint.hidden = true
end

function WaveConfigView:_refresh_enemy_hint_focus()
	for i, it in ipairs(self._enemy_hint_items or {}) do
		if it.idx == self._enemy_hint_index then
			it.btn.colors.background = {208, 220, 244, 255}
		else
			it.btn.colors.background = {236, 236, 236, 255}
		end
	end
end

function WaveConfigView:_show_enemy_glossary()
	if self._glossary and not self._glossary.hidden then
		self._glossary.hidden = true
		return
	end
	local EnemyGlossaryView = require("game_editor_enemy_glossary")
	local view = EnemyGlossaryView:new(self.editor.gui.sw, self.editor.gui.sh)
	self.editor.gui.window:add_child(view)
	self._glossary = view
	self.editor.gui._enemy_glossary = view
	view:show()
end

function WaveConfigView:keypressed(key, isrepeat)
	if self._enemy_hint and not self._enemy_hint.hidden and #self._enemy_hint_all > 0 then
		if key == "down" then
			self._enemy_hint_index = math.min(#self._enemy_hint_all, self._enemy_hint_index + 1)
			local max_rows = math.max(1, math.floor((self._enemy_hint.size.y - 8) / 26))
			if self._enemy_hint_index > self._enemy_hint_offset + max_rows - 1 then
				self._enemy_hint_offset = self._enemy_hint_index - max_rows + 1
				self:_render_enemy_hint_items()
			else
				self:_refresh_enemy_hint_focus()
			end
			return true
		elseif key == "up" then
			self._enemy_hint_index = math.max(1, self._enemy_hint_index - 1)
			if self._enemy_hint_index < self._enemy_hint_offset then
				self._enemy_hint_offset = self._enemy_hint_index
				self:_render_enemy_hint_items()
			else
				self:_refresh_enemy_hint_focus()
			end
			return true
		elseif key == "return" or key == "kpenter" then
			self:_accept_enemy_hint(self._enemy_hint_all[self._enemy_hint_index].name)
			return true
		elseif key == "escape" then
			self._enemy_hint.hidden = true
			return true
		end
	end
	return PopUpView.keypressed(self, key, isrepeat)
end

function WaveConfigView:update(dt)
	PopUpView.update(self, dt)
	if self._drag_scrollbar then
		local down = love.mouse.isDown and love.mouse.isDown(1)
		if not down then
			self._drag_scrollbar = false
		else
			local _, my = love.mouse.getPosition()
			local dy = my - self._drag_last_mouse_y
			self._drag_last_mouse_y = my
			local min_y = 0
			local max_y = math.max(0, self._content_view.size.y - self._scrollbar.size.y)
			self._scrollbar.pos = v(self._scrollbar.pos.x, math.max(min_y, math.min(max_y, self._scrollbar.pos.y + dy)))
			self:_sync_scroll_from_bar()
		end
	end
	self:_refresh_scrollbar()
	self._active_enemy_prop = nil
	for _, gf in ipairs(self._fields.groups or {}) do
		for _, wf in ipairs(gf.waves or {}) do
			for _, enemy_prop in ipairs(wf.enemies or {}) do
				if enemy_prop and enemy_prop.is_focused then
					self._active_enemy_prop = enemy_prop
					break
				end
			end
			if self._active_enemy_prop then
				break
			end
		end
		if self._active_enemy_prop then
			break
		end
	end
	local active_id = self._active_enemy_prop and tostring(self._active_enemy_prop) or ""
	local active_val = self._active_enemy_prop and tostring(self._active_enemy_prop.value or "") or ""
	local key = active_id .. "|" .. active_val .. "|" .. tostring(self._scroll) .. "|" .. tostring(self._enemy_hint_index) .. "|" .. tostring(self._enemy_hint_offset)
	if key ~= self._hint_cache_key then
		self._hint_cache_key = key
		self:_rebuild_enemy_hint()
	end
	return true
end

return WaveConfigView
