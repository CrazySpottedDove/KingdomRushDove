require("klove.kui")
require("gg_views_custom")

local V = require("lib.klua.vector")
local v = V.v
local G = love.graphics
local E = require("entity_db")

local WaveEditorView = class("WaveEditorView", PopUpView)

local C = {
	bg = {248, 248, 248, 255},
	panel = {236, 236, 236, 255},
	text = {18, 18, 18, 255},
	border = {180, 180, 180, 255},
	button = {226, 226, 226, 255}
}

local function enemy_display(template_name, tpl)
	local key = tpl and tpl.info and tpl.info.i18n_key
	local prefix = string.upper(key or template_name or "")
	local cname = _(prefix .. "_NAME")
	if cname == prefix .. "_NAME" then
		cname = _(string.upper(template_name or ""))
	end
	if cname == template_name or cname == "" or cname == string.upper(template_name or "") then
		return nil
	end
	return string.format("%s (%s)", template_name, cname)
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

function WaveEditorView:initialize(sw, sh, editor, opts)
	PopUpView.initialize(self, V.v(sw, sh))
	self.colors.background = {0, 0, 0, 150}
	self.editor = editor
	self.level_idx = (opts and opts.level_idx) or (editor.store.level_idx or 1)
	self.level_mode = (opts and opts.level_mode) or (editor.store.level_mode or GAME_MODE_CAMPAIGN)
	self._rows = {}
	self._scroll = 0
	self._enemy_suggest = nil
	self._enemy_suggest_items = {}
	self._enemy_suggest_index = 1
	self._enemy_suggest_all = {}
	self._enemy_suggest_offset = 1
	self._suggest_cache_key = nil

	local pw, ph = 1360, 800
	local panel = KView:new(V.v(pw, ph))
	panel.colors.background = C.bg
	panel.anchor = v(pw * 0.5, ph * 0.5)
	panel.pos = v(sw * 0.5, sh * 0.5)
	self:add_child(panel)
	self.panel = panel

	local title = KLabel:new(V.v(pw, 34))
	title.text = "出怪预览 / 微调"
	title.text_align = "center"
	title.vertical_align = "middle"
	title.colors.background = C.panel
	title.colors.text = C.text
	panel:add_child(title)

	local close_btn = KButton:new(V.v(30, 20))
	close_btn.text = "x"
	close_btn.pos = v(pw - 30, 5)
	close_btn.colors.background = {220, 180, 180, 255}
	close_btn.colors.text = C.text
	function close_btn.on_click()
		self:hide()
	end

	hook_button_feedback(close_btn)
	panel:add_child(close_btn)

	self.list_view = KView:new(V.v(940, ph - 92))
	self.list_view.pos = v(10, 40)
	self.list_view.clip = true
	self.list_view.colors.background = {255, 255, 255, 255}
	panel:add_child(self.list_view)

	self.list_content = KView:new(V.v(self.list_view.size.x, 0))
	self.list_content.pos = v(0, 30)
	self.list_view:add_child(self.list_content)
	self.list_header = KView:new(V.v(self.list_view.size.x, 30))
	self.list_header.colors.background = {234, 234, 234, 255}
	self.list_view:add_child(self.list_header)

	self.side = KView:new(V.v(390, ph - 92))
	self.side.pos = v(960, 40)
	self.side.colors.background = {255, 255, 255, 255}
	panel:add_child(self.side)

	self:_build_side_panel()
	self:_rebuild_rows()
	self:_refresh_list_scrollbar()

	local save_btn = KEButton:new("保存出怪文件")
	save_btn.size = v(130, 30)
	save_btn.pos = v(10, ph - 44)
	save_btn.colors.background = C.button
	function save_btn.on_click()
		self:_save_wave_data()
	end

	hook_button_feedback(save_btn)
	panel:add_child(save_btn)

	local glossary_btn = KEButton:new("怪物一览表")
	glossary_btn.size = v(130, 30)
	glossary_btn.pos = v(150, ph - 44)
	function glossary_btn.on_click()
		self:_show_enemy_glossary()
	end

	hook_button_feedback(glossary_btn)
	panel:add_child(glossary_btn)
end

function WaveEditorView:_create_prop(title, value)
	local p = KEProp:new(title, tostring(value or ""), true)
	return p
end

function WaveEditorView:_build_side_panel()
	self.side:remove_children()
	local y = 8

	self.p_lives = self:_create_prop("生命值(lives)", self.editor.wave_data.lives or 20)
	self.p_lives.pos = v(8, y)
	self.side:add_child(self.p_lives)
	self.p_lives.on_change = function()
		self.editor.wave_data.lives = tonumber(self.p_lives.value) or self.editor.wave_data.lives
	end
	y = y + 46

	self.p_cash = self:_create_prop("初始金币(cash)", self.editor.wave_data.cash or 800)
	self.p_cash.pos = v(8, y)
	self.side:add_child(self.p_cash)
	self.p_cash.on_change = function()
		self.editor.wave_data.cash = tonumber(self.p_cash.value) or self.editor.wave_data.cash
	end
	y = y + 54

	local sep = KLabel:new(V.v(self.side.size.x - 16, 24))
	sep.pos = v(8, y)
	sep.text = "当前选中出怪项"
	sep.vertical_align = "middle"
	sep.colors.background = C.panel
	sep.colors.text = C.text
	self.side:add_child(sep)
	y = y + 28

	self.p_group_interval = self:_create_prop("波间隔(interval 帧)", "")
	self.p_group_interval.pos = v(8, y)
	self.side:add_child(self.p_group_interval)
	y = y + 46

	self.p_wave_delay = self:_create_prop("子波延迟(delay 帧)", "")
	self.p_wave_delay.pos = v(8, y)
	self.side:add_child(self.p_wave_delay)
	y = y + 46

	self.p_wave_path = self:_create_prop("路径(path_index)", "")
	self.p_wave_path.pos = v(8, y)
	self.side:add_child(self.p_wave_path)
	y = y + 46

	self.p_spawn_creep = self:_create_prop("怪物模板(creep)", "")
	self.p_spawn_creep.pos = v(8, y)
	self.side:add_child(self.p_spawn_creep)
	y = y + 46

	self.p_spawn_creep_cn = self:_create_prop("怪物中文", "")
	self.p_spawn_creep_cn.editable = false
	self.p_spawn_creep_cn.pos = v(8, y)
	self.side:add_child(self.p_spawn_creep_cn)
	y = y + 46

	self.p_spawn_max = self:_create_prop("数量(max)", "")
	self.p_spawn_max.pos = v(8, y)
	self.side:add_child(self.p_spawn_max)
	y = y + 46

	self.p_spawn_interval = self:_create_prop("间隔(interval)", "")
	self.p_spawn_interval.pos = v(8, y)
	self.side:add_child(self.p_spawn_interval)
	y = y + 46

	self.p_spawn_interval_next = self:_create_prop("尾延(interval_next)", "")
	self.p_spawn_interval_next.pos = v(8, y)
	self.side:add_child(self.p_spawn_interval_next)
	y = y + 54

	self._enemy_suggest = KView:new(V.v(self.side.size.x - 16, 130))
	self._enemy_suggest.pos = v(8, self.p_spawn_creep.pos.y + self.p_spawn_creep.size.y + 2)
	self._enemy_suggest.colors.background = {245, 245, 245, 255}
	self._enemy_suggest.hidden = true
	self._enemy_suggest.clip = true
	self.side:add_child(self._enemy_suggest)
	self._enemy_suggest_content = KView:new(V.v(self._enemy_suggest.size.x, 0))
	self._enemy_suggest:add_child(self._enemy_suggest_content)

	local function bind_num(prop, setter)
		prop.on_change = function()
			if not self._selected then
				return
			end
			setter(tonumber(prop.value) or 0)
			self:_rebuild_rows()
		end
	end

	bind_num(self.p_group_interval, function(v)
		self._selected.group.interval = v
	end)
	bind_num(self.p_wave_delay, function(v)
		self._selected.wave.delay = v
	end)
	bind_num(self.p_wave_path, function(v)
		self._selected.wave.path_index = v
	end)
	self.p_spawn_creep.on_change = function()
		if self._selected and self.p_spawn_creep.value and self.p_spawn_creep.value ~= "" then
			self._selected.spawn.creep = self.p_spawn_creep.value
			local tpl = E.entities and E.entities[self.p_spawn_creep.value] or nil
			local cn = enemy_display(self.p_spawn_creep.value, tpl)
			local only_cn = (cn and cn:match("^.- %((.+)%)$")) or "-"
			self.p_spawn_creep_cn:set_value(only_cn, true)
			self:_rebuild_rows()
		end
	end
	self:_bind_spawn_prop_keys(self.p_spawn_creep)
	bind_num(self.p_spawn_max, function(v)
		self._selected.spawn.max = v
	end)
	bind_num(self.p_spawn_interval, function(v)
		self._selected.spawn.interval = v
	end)
	bind_num(self.p_spawn_interval_next, function(v)
		self._selected.spawn.interval_next = v
	end)
end

function WaveEditorView:_bind_spawn_prop_keys(prop)
	local owner = self
	function prop.on_keypressed(this, key)
		if owner._enemy_suggest and not owner._enemy_suggest.hidden and #owner._enemy_suggest_all > 0 then
			if key == "down" then
				owner._enemy_suggest_index = math.min(#owner._enemy_suggest_all, owner._enemy_suggest_index + 1)
				owner:_refresh_suggest_focus()
				return true
			elseif key == "up" then
				owner._enemy_suggest_index = math.max(1, owner._enemy_suggest_index - 1)
				owner:_refresh_suggest_focus()
				return true
			elseif key == "return" or key == "kpenter" then
				local picked = owner._enemy_suggest_all[owner._enemy_suggest_index]
				if picked then
					owner.p_spawn_creep:set_value(picked.name)
					owner._enemy_suggest.hidden = true
				end
				return true
			elseif key == "escape" then
				owner._enemy_suggest.hidden = true
				return true
			end
		end
		return KEProp.on_keypressed(this, key)
	end
end

function WaveEditorView:_rebuild_rows()
	self.list_content:remove_children()
	self._rows = {}
	self.list_header:remove_children()
	local y = 0
	local row_h = 24

	local cols = {{
		key = "group",
		title = "波",
		w = 44
	}, {
		key = "interval",
		title = "波间隔",
		w = 76
	}, {
		key = "path",
		title = "路径",
		w = 54
	}, {
		key = "delay",
		title = "延迟",
		w = 60
	}, {
		key = "en",
		title = "怪物英文",
		w = 184
	}, {
		key = "cn",
		title = "怪物中文",
		w = 184
	}, {
		key = "max",
		title = "数量",
		w = 52
	}, {
		key = "spawn_i",
		title = "间隔",
		w = 52
	}, {
		key = "next_i",
		title = "尾延",
		w = 52
	}}

	local function add_cell(parent, text, x, y0, w, h, bg, tc)
		local box = KView:new(V.v(w - 1, h - 1))
		box.pos = v(x, y0)
		box.colors.background = bg
		parent:add_child(box)
		local lb = KLabel:new(V.v(w - 4, h))
		lb.pos = v(x + 3, y0)
		lb.text = tostring(text or "")
		lb.vertical_align = "middle"
		lb.colors.text = tc
		parent:add_child(lb)
	end

	local hx = 0
	for _, c in ipairs(cols) do
		add_cell(self.list_header, c.title, hx, 0, c.w, 30, {230, 230, 230, 255}, {20, 20, 20, 255})
		hx = hx + c.w
	end

	for gi, group in ipairs(self.editor.wave_data.groups or {}) do
		for wi, wave in ipairs(group.waves or {}) do
			for si, spawn in ipairs(wave.spawns or {}) do
				local is_selected = self._selected and self._selected.group == group and self._selected.wave == wave and self._selected.spawn == spawn
				local bgc = is_selected and {210, 226, 252, 255} or (((gi + wi + si) % 2 == 0) and {252, 252, 252, 255} or {244, 244, 244, 255})
				local cn = enemy_display(spawn.creep or "", E.entities and E.entities[spawn.creep or ""] or nil)
				local only_cn = (cn and cn:match("^.- %((.+)%)$")) or "-"
				local values = {gi, tonumber(group.interval) or 0, tonumber(wave.path_index) or 1, tonumber(wave.delay) or 0, spawn.creep or "", only_cn, tonumber(spawn.max) or 0, tonumber(spawn.interval) or 0, tonumber(spawn.interval_next) or 0}
				local x = 0
				local row_hit = KView:new(V.v(self.list_view.size.x, row_h))
				row_hit.pos = v(0, y)
				row_hit.colors.background = {0, 0, 0, 0}
				for idx, c in ipairs(cols) do
					add_cell(self.list_content, values[idx], x, y, c.w, row_h, bgc, C.text)
					x = x + c.w
				end
				function row_hit.on_click()
					self:_select_spawn(group, wave, spawn)
					self:_rebuild_rows()
				end

				self.list_content:add_child(row_hit)
				self._rows[#self._rows + 1] = row_hit
				y = y + row_h
			end
		end
	end

	self.list_content.size = v(self.list_view.size.x, y)
	self:_refresh_list_scrollbar()
end

function WaveEditorView:_select_spawn(group, wave, spawn)
	self._selected = {
		group = group,
		wave = wave,
		spawn = spawn
	}
	self.p_group_interval:set_value(tostring(group.interval or 0), true)
	self.p_wave_delay:set_value(tostring(wave.delay or 0), true)
	self.p_wave_path:set_value(tostring(wave.path_index or 1), true)
	self.p_spawn_creep:set_value(tostring(spawn.creep or ""), true)
	local tpl = E.entities and E.entities[spawn.creep or ""] or nil
	local cn = enemy_display(spawn.creep or "", tpl)
	local only_cn = (cn and cn:match("^.- %((.+)%)$")) or "-"
	self.p_spawn_creep_cn:set_value(only_cn, true)
	self.p_spawn_max:set_value(tostring(spawn.max or 0), true)
	self.p_spawn_interval:set_value(tostring(spawn.interval or 0), true)
	self.p_spawn_interval_next:set_value(tostring(spawn.interval_next or 0), true)
end

function WaveEditorView:_save_wave_data()
	if self._selected then
		self._selected.group.interval = tonumber(self.p_group_interval.value) or self._selected.group.interval
		self._selected.wave.delay = tonumber(self.p_wave_delay.value) or self._selected.wave.delay
		self._selected.wave.path_index = tonumber(self.p_wave_path.value) or self._selected.wave.path_index
		self._selected.spawn.creep = self.p_spawn_creep.value ~= "" and self.p_spawn_creep.value or self._selected.spawn.creep
		self._selected.spawn.max = tonumber(self.p_spawn_max.value) or self._selected.spawn.max
		self._selected.spawn.interval = tonumber(self.p_spawn_interval.value) or self._selected.spawn.interval
		self._selected.spawn.interval_next = tonumber(self.p_spawn_interval_next.value) or self._selected.spawn.interval_next
	end
	self.editor.wave_data.lives = tonumber(self.p_lives.value) or self.editor.wave_data.lives
	self.editor.wave_data.cash = tonumber(self.p_cash.value) or self.editor.wave_data.cash

	if self.editor:save_wave_assets() then
		self.editor.gui:show_save_notification("出怪文件已保存", true)
	else
		self.editor.gui:show_save_notification("出怪文件保存失败", false)
	end
end

function WaveEditorView:_on_scroll(dy)
	local max_scroll = math.max(0, self.list_content.size.y - (self.list_view.size.y - 30))
	self._scroll = math.max(0, math.min(max_scroll, self._scroll - dy * 24))
	self.list_content.pos = v(0, 30 - self._scroll)
	self:_refresh_list_scrollbar()
end

function WaveEditorView:_refresh_list_scrollbar()
	if not self._list_scrollbar then
		self._list_scrollbar = KView:new(v(6, 12))
		self._list_scrollbar.colors.background = {100, 116, 152, 180}
		self.list_view:add_child(self._list_scrollbar)
		self._drag_list_scrollbar = false
		self._drag_list_last_mouse_y = 0
		function self._list_scrollbar.on_down(this, button)
			if button == 1 then
				self._drag_list_scrollbar = true
				self._drag_list_last_mouse_y = select(2, love.mouse.getPosition())
			end
		end
		function self._list_scrollbar.on_up(this, button)
			if button == 1 then
				self._drag_list_scrollbar = false
			end
		end
	end
	local max_scroll = math.max(0, self.list_content.size.y - (self.list_view.size.y - 30))
	if max_scroll <= 0 then
		self._list_scrollbar.hidden = true
		return
	end
	self._list_scrollbar.hidden = false
	local visible_h = self.list_view.size.y - 30
	local ratio = visible_h / math.max(self.list_content.size.y, 1)
	local h = math.max(24, math.floor(visible_h * ratio))
	local t = self._scroll / max_scroll
	self._list_scrollbar.size = v(self._list_scrollbar.size.x, h)
	if not self._drag_list_scrollbar then
		self._list_scrollbar.pos = v(self.list_view.size.x - 8, 30 + math.floor((visible_h - h) * t))
	end
end

function WaveEditorView:_sync_scroll_from_list_bar()
	local max_scroll = math.max(0, self.list_content.size.y - (self.list_view.size.y - 30))
	if max_scroll <= 0 then
		return
	end
	local y0 = 30
	local track = math.max(1, (self.list_view.size.y - 30) - self._list_scrollbar.size.y)
	local t = math.max(0, math.min(1, (self._list_scrollbar.pos.y - y0) / track))
	self._scroll = t * max_scroll
	self.list_content.pos = v(0, 30 - self._scroll)
end

function WaveEditorView:_rebuild_creep_suggestions()
	if not self._enemy_suggest then
		return
	end
	if not self.p_spawn_creep.is_focused then
		self._enemy_suggest.hidden = true
		return
	end
	local query = string.lower(self.p_spawn_creep.value or "")
	if query == "" then
		self._enemy_suggest.hidden = true
		return
	end
	self._enemy_suggest_content:remove_children()
	self._enemy_suggest_items = {}
	local rows = {}
	for name, tpl in pairs(E.entities or {}) do
		if string.sub(name, 1, 6) == "enemy_" and tpl.enemy and string.find(string.lower(name), query, 1, true) then
			local label = enemy_display(name, tpl)
			if label then
				rows[#rows + 1] = {
					name = name,
					label = label
				}
			end
		end
	end
	table.sort(rows, function(a, b)
		return a.name < b.name
	end)
	self._enemy_suggest_all = rows
	if #rows == 0 then
		self._enemy_suggest.hidden = true
		return
	end
	self._enemy_suggest_index = math.max(1, math.min(self._enemy_suggest_index, #rows))
	self._enemy_suggest_offset = math.max(1, math.min(self._enemy_suggest_offset, self._enemy_suggest_index))
	local row_h = 24
	local max_rows = math.max(1, math.floor((self._enemy_suggest.size.y - 8) / row_h))
	local max_offset = math.max(1, #rows - max_rows + 1)
	self._enemy_suggest_offset = math.max(1, math.min(self._enemy_suggest_offset, max_offset))
	local y = 4
	for i = self._enemy_suggest_offset, math.min(#rows, self._enemy_suggest_offset + max_rows - 1) do
		local row = rows[i]
		local btn = KButton:new(v(self._enemy_suggest.size.x - 8, 22))
		btn.pos = v(4, y)
		btn.text = row.label
		btn.text_align = "left"
		btn.colors.background = {236, 236, 236, 255}
		btn.colors.text = {20, 20, 20, 255}
		function btn.on_click()
			self.p_spawn_creep:set_value(row.name)
			self._enemy_suggest.hidden = true
		end

		hook_button_feedback(btn)
		self._enemy_suggest_content:add_child(btn)
		self._enemy_suggest_items[#self._enemy_suggest_items + 1] = {
			name = row.name,
			idx = i,
			btn = btn
		}
		y = y + 24
	end
	self._enemy_suggest_content.size = v(self._enemy_suggest.size.x, y + 4)
	self._enemy_suggest.hidden = false
	self._enemy_suggest_index = math.max(1, math.min(self._enemy_suggest_index, #self._enemy_suggest_all))
	self:_refresh_suggest_focus()
	local text_w = 0
	if G and G.getFont and G.getFont() then
		text_w = G.getFont():getWidth(tostring(self.p_spawn_creep.value or ""))
	end
	local px = math.min(self.side.size.x - self._enemy_suggest.size.x - 8, self.p_spawn_creep.lv.pos.x + 8 + text_w)
	local py = self.p_spawn_creep.pos.y + self.p_spawn_creep.lv.pos.y + self.p_spawn_creep.lv.size.y + 2
	if py + self._enemy_suggest.size.y > self.side.size.y - 8 then
		py = self.p_spawn_creep.pos.y + self.p_spawn_creep.lv.pos.y - self._enemy_suggest.size.y - 2
	end
	py = math.max(8, py)
	self._enemy_suggest.pos = v(px, py)
end

function WaveEditorView:_refresh_suggest_focus()
	for i, it in ipairs(self._enemy_suggest_items or {}) do
		if it.idx == self._enemy_suggest_index then
			it.btn.colors.background = {208, 220, 244, 255}
		else
			it.btn.colors.background = {236, 236, 236, 255}
		end
	end
end

function WaveEditorView:keypressed(key, isrepeat)
	if self._enemy_suggest and not self._enemy_suggest.hidden and #self._enemy_suggest_all > 0 then
		if key == "down" then
			self._enemy_suggest_index = math.min(#self._enemy_suggest_all, self._enemy_suggest_index + 1)
			local max_rows = math.max(1, math.floor((self._enemy_suggest.size.y - 8) / 24))
			if self._enemy_suggest_index > self._enemy_suggest_offset + max_rows - 1 then
				self._enemy_suggest_offset = self._enemy_suggest_index - max_rows + 1
				self:_rebuild_creep_suggestions()
			else
				self:_refresh_suggest_focus()
			end
			return true
		elseif key == "up" then
			self._enemy_suggest_index = math.max(1, self._enemy_suggest_index - 1)
			if self._enemy_suggest_index < self._enemy_suggest_offset then
				self._enemy_suggest_offset = self._enemy_suggest_index
				self:_rebuild_creep_suggestions()
			else
				self:_refresh_suggest_focus()
			end
			return true
		elseif key == "return" or key == "kpenter" then
			local picked = self._enemy_suggest_all[self._enemy_suggest_index]
			if picked then
				self.p_spawn_creep:set_value(picked.name)
				self._enemy_suggest.hidden = true
			end
			return true
		elseif key == "escape" then
			self._enemy_suggest.hidden = true
			return true
		end
	end
	return PopUpView.keypressed(self, key, isrepeat)
end

function WaveEditorView:update(dt)
	PopUpView.update(self, dt)
	if self._drag_list_scrollbar then
		local down = love.mouse.isDown and love.mouse.isDown(1)
		if not down then
			self._drag_list_scrollbar = false
		else
			local _, my = love.mouse.getPosition()
			local dy = my - self._drag_list_last_mouse_y
			self._drag_list_last_mouse_y = my
			local min_y = 30
			local max_y = 30 + math.max(0, (self.list_view.size.y - 30) - self._list_scrollbar.size.y)
			self._list_scrollbar.pos = v(self._list_scrollbar.pos.x, math.max(min_y, math.min(max_y, self._list_scrollbar.pos.y + dy)))
			self:_sync_scroll_from_list_bar()
		end
	end
	local focus = self.p_spawn_creep and self.p_spawn_creep.is_focused and "1" or "0"
	local query = self.p_spawn_creep and tostring(self.p_spawn_creep.value or "") or ""
	local key = focus .. "|" .. query .. "|" .. tostring(self._enemy_suggest_index) .. "|" .. tostring(self._enemy_suggest_offset)
	if key ~= self._suggest_cache_key then
		self._suggest_cache_key = key
		self:_rebuild_creep_suggestions()
	end
	return true
end

function WaveEditorView:_show_enemy_glossary()
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

return WaveEditorView
