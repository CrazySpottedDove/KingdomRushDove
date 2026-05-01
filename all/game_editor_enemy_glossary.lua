require("klove.kui")
require("gg_views_custom")

local V = require("lib.klua.vector")
local v = V.v
local E = require("entity_db")

local EnemyGlossaryView = class("EnemyGlossaryView", PopUpView)

local function enemy_cn_name(template_name, tpl)
	local key = tpl and tpl.info and tpl.info.i18n_key
	local prefix = string.upper(key or template_name or "")
	local cname = _(prefix .. "_NAME")
	if cname == prefix .. "_NAME" then
		cname = _(string.upper(template_name or ""))
	end
	if cname == template_name or cname == "" or cname == string.upper(template_name or "") then
		return nil
	end
	return cname
end

function EnemyGlossaryView:initialize(sw, sh)
	PopUpView.initialize(self, V.v(sw, sh))
	self.colors.background = {0, 0, 0, 150}
	self._scroll = 0

	local pw, ph = 760, 620
	local panel = KView:new(v(pw, ph))
	panel.anchor = v(pw * 0.5, ph * 0.5)
	panel.pos = v(sw * 0.5, sh * 0.5)
	panel.colors.background = {245, 245, 245, 255}
	self:add_child(panel)
	self.panel = panel

	local title = KLabel:new(v(pw, 34))
	title.text = "怪物一览表"
	title.text_align = "center"
	title.vertical_align = "middle"
	title.colors.background = {232, 232, 232, 255}
	panel:add_child(title)

	local close_btn = KButton:new(v(30, 28))
	close_btn.text = "X"
	close_btn.pos = v(pw - 34, 3)
	close_btn.colors.background = {220, 180, 180, 255}
	close_btn.colors.text = {20, 20, 20, 255}
	function close_btn.on_click()
		self:hide()
	end
	panel:add_child(close_btn)

	self.list_view = KView:new(v(pw - 20, ph - 52))
	self.list_view.pos = v(10, 40)
	self.list_view.clip = true
	self.list_view.colors.background = {255, 255, 255, 255}
	panel:add_child(self.list_view)

	self.header = KView:new(v(self.list_view.size.x, 26))
	self.header.colors.background = {236, 236, 236, 255}
	self.list_view:add_child(self.header)

	local h1 = KLabel:new(v(320, 26))
	h1.pos = v(8, 0)
	h1.text = "英文模板名"
	h1.vertical_align = "middle"
	h1.colors.text = {25, 25, 25, 255}
	self.header:add_child(h1)

	local h2 = KLabel:new(v(380, 26))
	h2.pos = v(336, 0)
	h2.text = "中文名"
	h2.vertical_align = "middle"
	h2.colors.text = {25, 25, 25, 255}
	self.header:add_child(h2)

	self.list_content = KView:new(v(self.list_view.size.x, 0))
	self.list_content.pos = v(0, 26)
	self.list_view:add_child(self.list_content)
	self:_rebuild_rows()
end

function EnemyGlossaryView:_rebuild_rows()
	self.list_content:remove_children()
	E:ensure_loaded()
	local rows = {}
	for name, tpl in pairs(E.entities or {}) do
		if string.sub(name, 1, 6) == "enemy_" and tpl.enemy then
			local cn = enemy_cn_name(name, tpl)
			if cn then
				rows[#rows + 1] = {
					name = name,
					cn = cn
				}
			end
		end
	end
	table.sort(rows, function(a, b)
		return a.name < b.name
	end)

	local y = 0
	for i, row in ipairs(rows) do
		local bg = KView:new(v(self.list_view.size.x, 24))
		bg.pos = v(0, y)
		bg.colors.background = (i % 2 == 0) and {250, 250, 250, 255} or {242, 242, 242, 255}
		self.list_content:add_child(bg)

		local l1 = KLabel:new(v(320, 24))
		l1.pos = v(8, y)
		l1.text = row.name
		l1.vertical_align = "middle"
		l1.colors.text = {30, 30, 30, 255}
		self.list_content:add_child(l1)

		local l2 = KLabel:new(v(380, 24))
		l2.pos = v(336, y)
		l2.text = row.cn
		l2.vertical_align = "middle"
		l2.colors.text = {45, 45, 45, 255}
		self.list_content:add_child(l2)

		y = y + 24
	end
	self.list_content.size = v(self.list_view.size.x, y)
end

function EnemyGlossaryView:_on_scroll(dy)
	local max_scroll = math.max(0, self.list_content.size.y - (self.list_view.size.y - 26))
	self._scroll = math.max(0, math.min(max_scroll, self._scroll - dy * 24))
	self.list_content.pos = v(0, 26 - self._scroll)
end

function EnemyGlossaryView:wheelmoved(dx, dy)
	self:_on_scroll(dy)
end

return EnemyGlossaryView
