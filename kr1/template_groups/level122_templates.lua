local E = require("entity_db")
local U = require("utils")
local V = require("lib.klua.vector")
require("lib.klua.table")
local scripts = require("scripts")
local r = V.r
local decal_stage_22_easteregg_sheepy_update
decal_stage_22_easteregg_sheepy_update = function(this, store)
	local touch_times = 0
	local speed = 30
	local start_pos = V.vclone(this.pos)
	local function y_sheepy_walk(dest)
		U.animation_start_default(this, "running", nil, store.tick_ts, true)
		this.render.sprites[1].flip_x = dest.x > this.pos.x
		local distance = 1000
		while distance > 5 do
			local vx, vy = V.sub(dest.x, dest.y, this.pos.x, this.pos.y)
			local v_angle = V.angleTo(vx, vy)
			local v_len = V.len(vx, vy)
			distance = v_len
			if distance > 5 then
				local step = speed * store.tick_length
				local nx, ny = V.normalize(V.rotate(v_angle, 1, 0))
				local sx, sy = V.mul(step, nx, ny)
				this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, sx, sy)
			else
				U.animation_start_default(this, "idle", nil, store.tick_ts, true)
				return
			end
			coroutine.yield()
		end
	end
	while true do
		if this.ui.clicked then
			this.ui.clicked = nil
			this.ui.can_click = false
			touch_times = touch_times + 1
			if touch_times == 1 then
				y_sheepy_walk(V.v(start_pos.x - 65, start_pos.y))
				U.y_wait_unconditional(store, 0.4)
				y_sheepy_walk(V.v(start_pos.x, start_pos.y))
				U.y_wait_unconditional(store, 0.4)
				y_sheepy_walk(V.v(start_pos.x - 20, start_pos.y + 10))
				this.ui.can_click = true
			elseif touch_times == 2 then
				U.y_animation_play(this, "action1", nil, store.tick_ts)
				this.ui.can_click = true
			elseif touch_times == 3 then
				y_sheepy_walk(V.v(start_pos.x - 20, start_pos.y - 23))
				U.y_animation_play(this, "death", nil, store.tick_ts)
				simulation:queue_remove_entity(this)
				return
			end
		end
		coroutine.yield()
	end
end
local tt
tt = E:register_t_hot("decal_stage_22_easteregg_sheepy", "decal_scripted", true)
E:add_comps(tt, "ui")
tt.main_script.update = decal_stage_22_easteregg_sheepy_update
tt.render.sprites[1].prefix = "croco_sheepy"
tt.render.sprites[1].name = "idle"
tt.ui.click_rect = r(-15, -5, 30, 50)
tt = E:register_t_hot("decal_stage_22_water_vfx1", "decal", true)
tt.render.sprites[1].prefix = "stage_22_bubbles_01Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t_hot("decal_stage_22_puerta5", "decal", true)
tt.render.sprites[1].name = "stage_22_puerta5"
tt.render.sprites[1].animated = false
tt = E:register_t_hot("decal_stage_22_puerta3", "decal", true)
tt.render.sprites[1].name = "stage_22_puerta3"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = 290
tt = E:register_t_hot("decal_stage_22_puerta4", "decal", true)
tt.render.sprites[1].name = "stage_22_puerta4"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = 290
tt = E:register_t_hot("tunnel_KR5_stage22_boss", "tunnel_KR5", true)
tt.untargetable_distance = 20
tt.tunnel.speed_factor = 1000
tt = E:register_t_hot("decal_stage_22_puerta1", "decal", true)
tt.render.sprites[1].name = "stage_22_puerta1"
tt.render.sprites[1].animated = false
tt = E:register_t_hot("decal_stage_22_sombras", "decal", true)
tt.render.sprites[1].name = "stage_22_sombras"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt = E:register_t_hot("decal_stage_22_puerta6", "decal", true)
tt.render.sprites[1].name = "stage_22_puerta6"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t_hot("decal_stage_22_water_vfx2", "decal_stage_22_water_vfx1", true)
tt.render.sprites[1].prefix = "stage_22_bubbles_02Def"
tt = E:register_t_hot("decal_stage_22_puerta2", "decal", true)
tt.render.sprites[1].name = "stage_22_puerta2"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
