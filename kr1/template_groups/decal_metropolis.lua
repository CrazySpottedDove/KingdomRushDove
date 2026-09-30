local E = require("entity_db")
local scripts = require("game_scripts")
local tt
local U = require("utils")
local P = require("path_db")
local LU = require("level_utils")
local V = require("lib.klua.vector")
local r = V.r
local band = bit.band
local decal_metropolis_portal = {}

function decal_metropolis_portal.update(this, store)
	local function should_activate()
		local enemies = table.filter(store.enemies, function(k, v)
			if v.pending_removal or not v.enemy or not v.vis or not v.nav_path or not v.health or v.health.dead or band(v.vis.flags, this.vis_bans) ~= 0 or band(v.vis.bans, this.vis_flags) ~= 0 or not P:is_node_valid(v.nav_path.pi, v.nav_path.ni) then
				return false
			end

			if this.detection_paths and not table.contains(this.detection_paths, v.nav_path.pi) then
				return false
			end

			for _, r in pairs(this.detection_rects) do
				if V.is_inside(v.pos, r) then
					return true
				end
			end

			return false
		end)

		return #enemies > 0
	end

	if this.detection_tags then
		this.detection_rects = {}

		for _, tag in pairs(this.detection_tags) do
			local es = LU.list_entities(store.entities, this.template_name, tag)

			if #es == 1 then
				local e = es[1]
				local rect = table.deepclone(e.detection_rect)

				rect.pos.x, rect.pos.y = rect.pos.x + e.pos.x, rect.pos.y + e.pos.y

				table.insert(this.detection_rects, rect)
			end
		end
	end

	while true do
		this.render.sprites[1].hidden = true

		while not should_activate() do
			coroutine.yield()
		end

		this.active = true
		this.tween.reverse = false
		this.tween.ts = store.tick_ts
		this.render.sprites[1].hidden = false

		U.y_animation_play(this, "start", nil, store.tick_ts, 1, 1)
		U.animation_start(this, "loop", nil, store.tick_ts, true, 1)

		while should_activate() or not this.render.sprites[1].sync_flag do
			coroutine.yield()
		end

		this.active = false
		this.tween.reverse = true
		this.tween.ts = store.tick_ts

		U.y_animation_play(this, "end", nil, store.tick_ts, 1, 1)
	end
end

tt = E:register_t_hot("decal_metropolis_floating_rock", "decal_tween", true)
tt.render.sprites[1].animated = false
tt.tween.random_ts = fts(80)
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {{0, vec_2(0, 1)}, {fts(20), vec_2(0, 2)}, {fts(40), vec_2(0, 1)}, {fts(60), vec_2(0, 0)}, {fts(80), vec_2(0, 1)}}
tt.tween.props[1].loop = true

tt = E:register_t_hot("decal_metropolis_portal", "decal_scripted", true)
AC(tt, "tween", "editor")
tt.main_script.update = decal_metropolis_portal.update
tt.render.sprites[1].prefix = "decal_metropolis_portal"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "fx_metropolis_portal"
tt.render.sprites[2].anchor.y = 0.071429
tt.render.sprites[2].alpha = 0
tt.render.sprites[2].random_ts = 0.5
tt.render.sprites[3] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[3].offset = vec_2(-27, -5)
tt.render.sprites[4] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[4].offset = vec_2(27, -19)
tt.render.sprites[5] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[5].offset = vec_2(12, 0)
tt.render.sprites[6] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[6].offset = vec_2(-11, -19)
tt.tween.ts = -1
tt.tween.reverse = true
tt.tween.remove = false

for i = 1, 6 do
	tt.tween.props[i] = CC("tween_prop")
	tt.tween.props[i].keys = {{0, 0}, {0.5, 255}}
	tt.tween.props[i].sprite_id = i
end

tt.editor.props = {{"editor.tag", PT_NUMBER}}
tt.editor.overrides = {
	["render.sprites[1].name"] = "loop"
}
tt.detection_tags = {}
tt.detection_rect = r(-60, -40, 120, 80)
tt.vis_flags = 0
tt.vis_bans = F_BOSS

