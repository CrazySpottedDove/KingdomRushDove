local E = require("entity_db")
local U = require("utils")
local km = require("lib.klua.macros")
require("all.constants")
require("lib.klua.table")
local function fts(t)
	return t / FPS
end
local function AC(tpl, ...)
	return E:add_comps(tpl, ...)
end
local function decal_bush_statue_insert(this, store)
	local d = store.ephemeral
	if not d.bush_indexes then
		local indexes = {}
		for i = 1, #this.bush_frames do
			table.insert(indexes, i)
		end
		local match_idx = math.random(1, #indexes)
		table.remove(indexes, match_idx)
		d.bush_match_idx = match_idx
		d.bush_indexes = indexes
		d.bush_start_idx = math.random(1, 3)
	end
	this.bush_indexes = {d.bush_match_idx, table.remove(d.bush_indexes, math.random(1, #d.bush_indexes)), table.remove(d.bush_indexes, math.random(1, #d.bush_indexes))}
	this.bush_match_idx = 1
	this.bush_idx = d.bush_start_idx
	d.bush_start_idx = km.zmod(d.bush_start_idx + 1, #this.bush_indexes)
	this.render.sprites[1].name = this.bush_frame_prefix .. this.bush_frames[this.bush_indexes[this.bush_idx]]
	return true
end
local function decal_bush_statue_update(this, store)
	while true do
		if this.ui.clicked then
			local fx = E:create_entity("fx_bush_statue_click")
			fx.pos = this.pos
			fx.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(fx)
			U.y_wait_unconditional(store, fts(5))
			this.bush_idx = km.zmod(this.bush_idx + 1, #this.bush_indexes)
			local frame = this.bush_frame_prefix .. this.bush_frames[this.bush_indexes[this.bush_idx]]
			this.render.sprites[1].name = frame
			if this.bush_idx == this.bush_match_idx then
				local all_bushes = table.filter(store.entities, function(k, v)
					return v.template_name == this.template_name
				end)
				for _, e in pairs(all_bushes) do
					if e.bush_idx ~= e.bush_match_idx then
						goto label_521_0
					end
				end
			end
			::label_521_0::
			this.ui.clicked = nil
		end
		coroutine.yield()
	end
end
local tt
tt = E:register_t_hot("decal_s05_tree_round", "decal", true)
tt.render.sprites[1].name = "stage5_tree"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.13953488372093023
tt = E:register_t_hot("decal_s05_tree_pine", "decal", true)
tt.render.sprites[1].name = "stage5_pine"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.08333333333333333
tt = E:register_t_hot("decal_bush_statue", "decal_scripted", true)
AC(tt, "ui")
tt.main_script.insert = decal_bush_statue_insert
tt.main_script.update = decal_bush_statue_update
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "stage5_bushes_0001"
tt.render.sprites[1].anchor.y = 0.1744186046511628
tt.bush_frame_prefix = "stage5_bushes_"
tt.bush_frames = {"0001", "0002", "0003", "0004", "0005", "0006", "0007"}
tt.ui.click_rect = r(-40, 0, 80, 66)
tt.ui.can_select = false
tt = E:register_t_hot("fx_bush_statue_click", "fx", true)
AC(tt, "sound_events")
tt.render.sprites[1].name = "fx_bush_statue_click"
tt.render.sprites[1].offset.y = 34
tt.sound_events.insert = "ElvesAchievementScissorFingers"
