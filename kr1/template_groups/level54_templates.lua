local V = require("lib.klua.vector")
local E = require("entity_db")
require("all.constants")
require("lib.klua.table")
local function AC(tpl, ...)
	return E:add_comps(tpl, ...)
end
local function gryphon_controller_update(this, store)
	local cwi, cw = 0, nil
	local wts = store.tick_ts
	::label_529_0::
	while true do
		cwi, cw = next(this.gryphon_waves, cwi)
		if not cw then
			break
		end
		while store.wave_group_number < cw.wave do
			coroutine.yield()
			wts = store.tick_ts
		end
		while store.tick_ts - wts < cw.delay do
			if store.wave_group_number ~= cw.wave then
				goto label_529_0
			end
			coroutine.yield()
		end
		local e = E:create_entity("decal_gryphon")
		e.cooldown = cw.cooldown
		e.side = cw.side
		simulation:queue_insert_entity(e)
	end
	simulation:queue_remove_entity(this)
end
local tt
tt = E:register_t_hot("decal_s06_eagle", "decal_delayed_sequence", true)
AC(tt, "editor")
tt.delayed_sequence.animations = {"1", "2", "3", "4"}
tt.delayed_sequence.random = true
tt.delayed_sequence.max_delay = 3
tt.render.sprites[1].prefix = "decal_s06_eagle"
tt.render.sprites[1].name = "1"
tt.render.sprites[1].z = Z_OBJECTS + 1
tt = E:register_t_hot("decal_s06_boxed_boss", "decal_delayed_play", true)
tt.delayed_play.min_delay = 5
tt.delayed_play.min_delay = 10
tt.render.sprites[1].prefix = "decal_s06_boxed_boss_l1"
tt.render.sprites[1].z = Z_OBJECTS + 1
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "decal_s06_boxed_boss_l2"
tt.render.sprites[2].z = Z_OBJECTS + 1
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].prefix = "decal_s06_boxed_boss_l3"
tt.render.sprites[3].z = Z_OBJECTS + 1
tt = E:register_t_hot("decal_s06_jailed_boss", "decal", true)
for i = 1, 6 do
	tt.render.sprites[i] = CC("sprite")
	tt.render.sprites[i].prefix = "decal_s06_jailed_boss_l" .. i
	tt.render.sprites[i].name = "walk"
	tt.render.sprites[i].anchor.y = 0.26373626373626374
end
tt.render.sprites[6].sort_y_offset = -10
tt = E:register_t_hot("gryphon_controller", nil, true)
AC(tt, "main_script")
tt.main_script.update = gryphon_controller_update
local S = require("sound_db")
local U = require("utils")
local P = require("path_db")
local km = require("lib.klua.macros")
local v = V.v
local function fts(t)
	return t / FPS
end
local function decal_gryphon_update(this, store)
	local flip_x = this.side == "right"
	local flip_sign = flip_x and -1 or 1
	local at = this.attacks.list[1]
	local bso = v(at.bullet_start_offset.x * flip_sign, at.bullet_start_offset.y)
	local beo = v(bso.x + 100 * flip_sign, bso.y - 140)
	local c = this.custom[this.side]
	local initial_curve = P:nodes_as_list(c.initial_curve_id)
	local default_curve = P:nodes_as_list(c.default_curve_id)
	local approach_curve = P:nodes_as_list(c.land_curve_id)
	local idle_pos = v(default_curve[1], default_curve[2])
	local approach_offset = v(-152 * flip_sign, 15)
	local default_offset = v(0, 0)
	local shadow_default_offset = v(94 * flip_sign, 0)
	local shadow_approach_offset = v(-28 - 30 * flip_sign, 60)
	local flash_offset = v(104 * flip_sign, -23)
	local sign_hidden_time = 5
	local sign_shown_time = 1
	local sign = E:create_entity("decal_gryphon_sign")
	sign.pos.x, sign.pos.y = idle_pos.x + flip_sign * 64, idle_pos.y + 5
	sign.render.sprites[1].flip_x = flip_x
	sign.tween.reverse = true
	sign.tween.ts = -1
	simulation:queue_insert_entity(sign)
	this.render.sprites[4].offset = flash_offset
	local first_pass = true
	while true do
		this.render.sprites[3].offset = shadow_default_offset
		this.render.sprites[3].hidden = false
		U.animation_start_group(this, "fly", flip_x, store.tick_ts, true, "layers")
		local bez = love.math.newBezierCurve(first_pass and initial_curve or default_curve)
		local start_ts = store.tick_ts
		local t = 0
		local ari, ar = next(c.attack_ranges)
		local phase = 1
		while t <= 1 do
			this.pos.x, this.pos.y = bez:evaluate(t)
			t = (store.tick_ts - start_ts) / (first_pass and c.initial_duration or c.default_duration)
			if phase == 1 and flip_sign * this.pos.x > flip_sign * ar[1] then
				phase = phase + 1
				S:queue("ElvesGryphonsShoot")
				U.animation_start_group(this, "attack_start", flip_x, store.tick_ts, false, "layers")
			elseif phase == 2 and U.animation_finished_default(this) then
				phase = phase + 1
				U.animation_start_group(this, "attack_loop", flip_x, store.tick_ts, true, "layers")
			elseif phase == 3 then
				if flip_sign * this.pos.x > flip_sign * ar[2] then
					this.render.sprites[4].hidden = true
					ari, ar = next(c.attack_ranges, ari)
					phase = ar and 1 or phase + 1
					U.animation_start_group(this, "attack_end", flip_x, store.tick_ts, false, "layers")
					S:queue("ElvesGryphonsShootEnd")
				elseif flip_sign * this.pos.x > flip_sign * ar[1] and store.tick_ts - at.ts >= at.cooldown then
					at.ts = store.tick_ts
					this.render.sprites[4].hidden = nil
					this.render.sprites[4].ts = store.tick_ts
					for i = 1, at.loops do
						local b = E:create_entity(at.bullet)
						b.pos.x, b.pos.y = this.pos.x + bso.x, this.pos.y + bso.y
						b.bullet.from = v(b.pos.x, b.pos.y)
						b.bullet.to = v(this.pos.x + beo.x + U.frandom(-20, 20), this.pos.y + beo.y + U.frandom(-30, 30))
						b.initial_impulse = U.frandom(0, 1000) * 30
						simulation:queue_insert_entity(b)
					end
				end
			elseif phase == 4 and U.animation_finished_default(this) then
				phase = phase + 1
				U.animation_start_group(this, "fly", flip_x, store.tick_ts, true, "layers")
			end
			coroutine.yield()
		end
		U.y_wait_unconditional(store, first_pass and 0 or this.cooldown)
		first_pass = false
		this.render.sprites[1].offset = approach_offset
		this.render.sprites[2].offset = approach_offset
		this.render.sprites[3].offset = shadow_approach_offset
		local bez = love.math.newBezierCurve(approach_curve)
		local start_ts = store.tick_ts
		local t = 0
		while t <= 1 do
			this.pos.x, this.pos.y = bez:evaluate(t)
			t = (store.tick_ts - start_ts) / c.approach_duration
			coroutine.yield()
		end
		this.render.sprites[1].offset = default_offset
		this.render.sprites[2].offset = default_offset
		this.render.sprites[3].hidden = true
		S:queue("ElvesGryphonsLand")
		this.pos.x, this.pos.y = idle_pos.x, idle_pos.y
		U.y_animation_play_group(this, "land", flip_x, store.tick_ts, 1, "layers")
		U.animation_start_group(this, "idle", flip_x, store.tick_ts, true, "layers")
		this.ui.clicked = nil
		while not this.ui.clicked do
			local sign_cooldown = sign.tween.reverse and sign_hidden_time or sign_shown_time
			if sign_cooldown < store.tick_ts - sign.tween.ts then
				sign.tween.reverse = not sign.tween.reverse
				sign.tween.ts = store.tick_ts
			end
			coroutine.yield()
		end
		sign.tween.reverse = true
		sign.tween.ts = -1
		S:queue("ElvesGryphonsTakeOff")
		U.y_animation_play_group(this, "takeoff", flip_x, store.tick_ts, 1, "layers")
	end
end
tt = E:register_t_hot("decal_gryphon", "decal_scripted", true)
AC(tt, "attacks", "ui", "sound_events")
tt.attacks.list[1] = CC("bullet_attack")
tt.attacks.list[1].cooldown = fts(3)
tt.attacks.list[1].bullet = "bullet_gryphon"
tt.attacks.list[1].loops = 3
tt.attacks.list[1].bullet_start_offset = vec_2(102, -22)
tt.main_script.update = decal_gryphon_update
tt.render.sprites[1].prefix = "gryphon_l1"
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[1].group = "layers"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "gryphon_l2"
tt.render.sprites[2].z = Z_BULLETS
tt.render.sprites[2].group = "layers"
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].animated = false
tt.render.sprites[3].name = "ally_gryphon_0000"
tt.render.sprites[3].alpha = 60
tt.render.sprites[4] = CC("sprite")
tt.render.sprites[4].hidden = true
tt.render.sprites[4].loop = false
tt.render.sprites[4].name = "gryphon_attack_flash"
tt.ui.click_rect = r(-40, -106, 80, 100)
tt.ui.can_select = false
tt.custom = {
	left = {},
	right = {}
}
tt.custom.left.initial_duration = 4.6
tt.custom.left.default_duration = 4
tt.custom.left.approach_duration = 0.7
tt.custom.left.attack_ranges = {{-50, 500}}
tt.custom.left.initial_curve_id = 5
tt.custom.left.default_curve_id = 6
tt.custom.left.land_curve_id = 7
tt.custom.right.initial_duration = 5
tt.custom.right.default_duration = 4.5
tt.custom.right.approach_duration = 0.7
tt.custom.right.attack_ranges = {{1050, 750}, {600, 200}}
tt.custom.right.initial_curve_id = 8
tt.custom.right.default_curve_id = 9
tt.custom.right.land_curve_id = 10
