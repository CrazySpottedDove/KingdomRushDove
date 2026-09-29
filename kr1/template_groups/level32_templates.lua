local V = require("lib.klua.vector")
local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
require("all.constants")
require("lib.klua.table")
local v = V.v
local function decal_efreeti_door_update(this, store)
	local floor_sid, door_sid, statue_left_sid, statue_right_sid, eyes_sid, eyes_fx_sid = 1, 2, 4, 5, 6, 7
	while true do
		while this.phase ~= "eyes" do
			coroutine.yield()
		end
		local eyes, eyesfx = this.render.sprites[eyes_sid], this.render.sprites[eyes_fx_sid]
		eyes.ts = store.tick_ts
		eyes.hidden = false
		S:queue("BossEfreetiSpawnBoss")
		U.y_wait_unconditional(store, 1.5)
		this.phase = "show_boss"
		eyesfx.ts = store.tick_ts
		eyesfx.hidden = false
		U.y_animation_wait(this, eyes_sid)
		eyes.hidden = true
		eyesfx.hidden = true
		while this.phase ~= "destruction" do
			coroutine.yield()
		end
		U.animation_start(this, "destruction", nil, store.tick_ts, false, door_sid)
		U.animation_start(this, "destruction", nil, store.tick_ts, false, floor_sid)
		S:queue("BossEfreetiDoors")
		U.y_wait_unconditional(store, 0.9)
		for _, p in pairs(this.smoke_positions) do
			local fx = E:create_entity("fx")
			fx.pos.x, fx.pos.y = p.x, p.y
			fx.render.sprites[1].name = "efreeti_door_smoke"
			fx.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(fx)
		end
		for _, p in pairs(this.stone_positions) do
			local fx = E:create_entity("fx")
			fx.pos.x, fx.pos.y = p[1].x, p[1].y
			fx.render.sprites[1].name = "efreeti_door_stone"
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].scale = v(p[2], p[2])
			fx.render.sprites[1].flip_x = p[3]
			simulation:queue_insert_entity(fx)
		end
		this.render.sprites[statue_left_sid].name = "left"
		this.render.sprites[statue_right_sid].name = "right"
		U.y_animation_wait(this, floor_sid)
		this.render.sprites[floor_sid].hidden = true
		U.y_wait_unconditional(store, 3)
		this.phase = "finished"
	end
end
local tt
tt = E:register_t_hot("decal_efreeti_tent", "decal", true)
tt.render.sprites[1].name = "boss_corps_efreeti"
tt.render.sprites[1].animated = false
tt = E:register_t_hot("decal_efreeti_door", "decal_scripted", true)
tt.main_script.update = decal_efreeti_door_update
tt.smoke_positions = {vec_2(521, 674), vec_2(618, 642)}
tt.stone_positions = {{vec_2(599, 664), 1, false}, {vec_2(688, 592), 0.8, false}, {vec_2(479, 647), 0.8, false}, {vec_2(519, 682), 1, true}, {vec_2(625, 608), 0.8, true}, {vec_2(416, 663), 0.8, true}}
tt.render.sprites[1].prefix = "efreeti_door_floor"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].loop = false
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "efreeti_door"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].loop = false
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].name = "Stage06_0003"
tt.render.sprites[3].animated = false
tt.render.sprites[4] = CC("sprite")
tt.render.sprites[4].prefix = "efreeti_statue"
tt.render.sprites[4].name = "idle"
tt.render.sprites[4].offset = vec_2(-139, -66)
tt.render.sprites[4].anchor.y = 0.08
tt.render.sprites[5] = CC("sprite")
tt.render.sprites[5].prefix = "efreeti_statue"
tt.render.sprites[5].name = "idle"
tt.render.sprites[5].offset = vec_2(72, -120)
tt.render.sprites[5].anchor.y = 0.08
tt.render.sprites[6] = CC("sprite")
tt.render.sprites[6].name = "efreeti_door_eyes"
tt.render.sprites[6].offset = vec_2(-51, -55)
tt.render.sprites[6].hidden = true
tt.render.sprites[6].loop = false
tt.render.sprites[7] = CC("sprite")
tt.render.sprites[7].name = "efreeti_door_eyes_effect"
tt.render.sprites[7].offset = vec_2(-51, -55)
tt.render.sprites[7].hidden = true
tt.render.sprites[7].loop = false
tt = E:register_t_hot("decal_efreeti_door_broken", "decal", true)
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].name = "efreeti_statue_left"
tt.render.sprites[1].offset = vec_2(-139, -66)
tt.render.sprites[1].anchor.y = 0.08
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "efreeti_statue_right"
tt.render.sprites[2].offset = vec_2(72, -120)
tt.render.sprites[2].anchor.y = 0.08
