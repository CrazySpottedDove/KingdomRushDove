local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local scripts = require("scripts")
require("all.constants")
require("lib.klua.table")
local function fts(t)
	return t / FPS
end
local function AC(tpl, ...)
	return E:add_comps(tpl, ...)
end
local function decal_s15_mactans_update(this, store)
	local attack_ts, cooldown = 0, 0
	local attack_pending, attack_loop
	this.phase_signal = "attack"
	while true do
		if this.phase_signal == "attack" then
			this.phase_signal = nil
			attack_loop = true
			attack_pending = true
			attack_ts = store.tick_ts
		elseif this.phase_signal == "single_attack" then
			this.phase_signal = nil
			attack_ts = store.tick_ts - cooldown - 1
			attack_loop = false
			attack_pending = true
		elseif this.phase_signal == "stop" then
			this.phase_signal = nil
			attack_loop = false
			attack_pending = false
		elseif this.phase_signal == "jump_out" then
			this.phase_signal = nil
			U.y_animation_play(this, "jumpOut", nil, store.tick_ts)
			U.sprites_hide(this)
			this.phase = "out"
			while this.phase_signal ~= "jump_in" do
				coroutine.yield()
			end
			this.phase_signal = nil
			U.sprites_show(this)
			U.y_animation_play(this, "jumpIn", nil, store.tick_ts)
		elseif this.phase_signal == "jump" then
			U.y_animation_play(this, "jumpToCrystal", nil, store.tick_ts, 1)
			simulation:queue_remove_entity(this)
			return
		end
		if attack_pending and cooldown < store.tick_ts - attack_ts then
			this.phase = "attack"
			S:queue("ElvesFinalBossGemattackSpider")
			U.animation_start_default(this, "attack", nil, store.tick_ts, false)
			U.y_wait_unconditional(store, fts(11))
			this.decal_statue.phase_signal = "hit"
			U.y_animation_wait_default(this)
			attack_ts = store.tick_ts
			cooldown = U.frandom(4, 6)
			attack_pending = attack_loop
		end
		U.animation_start_default(this, "idle", nil, store.tick_ts, true)
		this.phase = "idle"
		coroutine.yield()
	end
end
local function decal_s15_malicia_update(this, store)
	local ray = this.render.sprites[2]
	local ray_duration = U.frandom(4, 6)
	local attack_ts, cooldown = 0, 0
	local attack_pending, attack_loop
	this.phase_signal = "attack"
	while true do
		if this.phase_signal == "attack" then
			this.phase_signal = nil
			attack_loop = true
			attack_pending = true
			attack_ts = store.tick_ts
		elseif this.phase_signal == "single_attack" then
			this.phase_signal = nil
			attack_ts = store.tick_ts - cooldown - 1
			ray_duration = 2
			attack_loop = false
			attack_pending = true
		elseif this.phase_signal == "stop" then
			this.phase_signal = nil
			attack_loop = false
			attack_pending = false
		elseif this.phase_signal == "jump" then
			U.y_animation_play(this, "jumpToCrystal", nil, store.tick_ts, 1, 1)
			simulation:queue_remove_entity(this)
			return
		end
		if attack_pending and cooldown < store.tick_ts - attack_ts then
			this.phase = "attack"
			S:queue("ElvesFinalBossGemattackMalicia")
			ray.hidden = false
			U.animation_start(this, "attack", nil, store.tick_ts, true, 1)
			U.y_wait_conditional(store, ray_duration, function()
				return this.phase_signal == "stop"
			end)
			ray.hidden = true
			attack_ts = store.tick_ts
			cooldown = U.frandom(5, 10)
			ray_duration = U.frandom(4, 6)
			attack_pending = attack_loop
		end
		U.animation_start(this, "idle", nil, store.tick_ts, true, 1)
		this.phase = "idle"
		coroutine.yield()
	end
end
local function decal_s15_statue_update(this, store)
	while true do
		if this.phase_signal == "break" then
			S:queue("ElvesFinalBossGemCrystalBreak")
			U.y_animation_play(this, "break", nil, store.tick_ts)
			this.render.sprites[1].z = Z_DECALS
			this.phase = "broken"
			return
		elseif this.phase_signal == "hit" then
			this.phase_signal = nil
			U.y_animation_play(this, "hit", nil, store.tick_ts)
			U.animation_start_default(this, "idle", nil, store.tick_ts, true)
		end
		coroutine.yield()
	end
end
local tt
tt = E:register_t_hot("decal_s15_mactans", "decal_scripted", true)
AC(tt, "editor")
tt.render.sprites[1].prefix = "stage15_mactans_l1"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.09047619047619047
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].prefix = "stage15_mactans_l2"
tt.main_script.update = decal_s15_mactans_update
tt = E:register_t_hot("decal_s15_malicia", "decal_scripted", true)
AC(tt, "editor")
tt.render.sprites[1].prefix = "stage15_malicia"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.057692307692307696
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "stage15_malicia_ray"
tt.render.sprites[2].hidden = true
tt.render.sprites[2].anchor = vec_2(0.64, 0.21666666666666667)
tt.render.sprites[2].offset = vec_2(-2, 57)
tt.main_script.update = decal_s15_malicia_update
tt = E:register_t_hot("decal_s15_statue", "decal_scripted", true)
AC(tt, "editor")
tt.main_script.update = decal_s15_statue_update
tt.render.sprites[1].prefix = "stage15_shield"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.20161290322580644
tt = E:register_t_hot("decal_s15_crystal", "decal_tween", true)
AC(tt, "editor")
tt.render.sprites[1].name = "stage15_crystal"
tt.render.sprites[1].animated = false
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {{0, vec_2(0, 2)}, {fts(25), vec_2(0, -2)}, {fts(50), vec_2(0, 2)}}
tt.tween.props[1].loop = true
tt.tween.props[1].interp = "sine"
tt = E:register_t_hot("fx_s15_crystal_shine", "fx", true)
tt.render.sprites[1].name = "stage15_crystal_fx"
tt = E:register_t_hot("fx_s15_crystal_transformation", "fx", true)
for i = 1, 4 do
	tt.render.sprites[i] = CC("sprite")
	tt.render.sprites[i].prefix = "stage15_crystal_l" .. i
	tt.render.sprites[i].name = "explosion"
end
tt = E:register_t_hot("fx_s15_white_circle", "decal_tween", true)
tt.render.sprites[1].name = "spiderQueen_deathShapes_0002"
tt.render.sprites[1].animated = false
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_GUI - 2
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {{fts(3), vec_1(0.3)}, {fts(6), vec_1(70)}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].keys = {{0, 255}, {1, 255}, {2, 0}}
tt = E:register_t_hot("decal_s15_finished_gem", "decal", true)
AC(tt, "editor")
tt.render.sprites[1].name = "stage15_bossDecal_gem"
tt.render.sprites[1].anchor.y = 0.22580645161290322
tt.render.sprites[1].animated = false
tt = E:register_t_hot("decal_s15_finished_veznan", "decal_delayed_play", true)
tt.render.sprites[1].prefix = "decal_s15_finished_veznan"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.1111111111111111
tt.delayed_play.min_delay = 5
tt.delayed_play.max_delay = 15
tt = E:register_t_hot("decal_s15_finished_guard", "decal_delayed_sequence", true)
AC(tt, "editor")
for i = 1, 4 do
	tt.render.sprites[i] = CC("sprite")
	tt.render.sprites[i].prefix = "decal_s15_finished_guard_layer" .. i
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].anchor.y = 0.12195121951219512
	tt.render.sprites[i].loop = i > 2
	tt.render.sprites[i].hidden = i == 4
end
tt.delayed_sequence.animations = {"idle", "blink", "blink", "sleep"}
tt.delayed_sequence.min_delay = 5
tt.delayed_sequence.max_delay = 15
tt = E:register_t_hot("decal_s15_finished_guard_flipped", "decal_s15_finished_guard", true)
for i = 1, 4 do
	tt.render.sprites[i].flip_x = true
	tt.render.sprites[i].hidden = i == 3
end
tt = E:register_t_hot("taunts_s15_controller", nil, true)
AC(tt, "main_script", "taunts", "editor")
tt.load_file = "level63_taunts"
tt.main_script.insert = scripts.taunts_controller.insert
tt.main_script.update = scripts.taunts_controller.update
tt.taunts.delay_min = 10
tt.taunts.sets = {}
tt.taunts.sets.mactans = CC("taunt_set")
tt.taunts.sets.mactans.format = "ELVES_ENEMY_MACTANS_TAUNT_%04i"
tt.taunts.sets.mactans.end_idx = 8
tt.taunts.sets.mactans.decal_name = "decal_s15_mactans_shoutbox"
tt.taunts.sets.mactans.pos = vec_2(453, 591)
tt.taunts.sets.malicia = CC("taunt_set")
tt.taunts.sets.malicia.format = "ELVES_ENEMY_MALICIA_TAUNT_%04i"
tt.taunts.sets.malicia.end_idx = 8
tt.taunts.sets.malicia.decal_name = "decal_s15_malicia_shoutbox"
tt.taunts.sets.malicia.pos = vec_2(653, 591)
tt.taunts.sets.welcome_mactans = table.deepclone(tt.taunts.sets.mactans)
tt.taunts.sets.welcome_mactans.format = "ELVES_ENEMY_MALICIA_MACTANS_TAUNT_KIND_WELCOME_0001"
tt.taunts.sets.welcome_malicia = table.deepclone(tt.taunts.sets.malicia)
tt.taunts.sets.welcome_malicia.format = "ELVES_ENEMY_MALICIA_MACTANS_TAUNT_KIND_WELCOME_0002"
tt.taunts.sets.pre_mactans = table.deepclone(tt.taunts.sets.mactans)
tt.taunts.sets.pre_mactans.format = "ELVES_ENEMY_MALICIA_MACTANS_TAUNT_KIND_PREBATTLE_%04i"
tt.taunts.sets.pre_mactans.idxs = {2, 4}
tt.taunts.sets.pre_malicia = table.deepclone(tt.taunts.sets.malicia)
tt.taunts.sets.pre_malicia.format = "ELVES_ENEMY_MALICIA_MACTANS_TAUNT_KIND_PREBATTLE_%04i"
tt.taunts.sets.pre_malicia.idxs = {1, 3}
tt.taunts.sets.custom_malicia = table.deepclone(tt.taunts.sets.malicia)
tt.taunts.sets.custom_malicia.format = "ELVES_ENEMY_MALICIA_TAUNT_KIND_%s"
tt.taunts.sets.custom_mactans = table.deepclone(tt.taunts.sets.mactans)
tt.taunts.sets.custom_mactans.format = "ELVES_ENEMY_MALICIA_TAUNT_KIND_%s"
local km = require("lib.klua.macros")
tt = E:register_t_hot("decal_s15_mactans_shoutbox", "decal_eb_spider_shoutbox", true)
tt.render.sprites[1].name = "stage15_taunts_0004"
tt.render.sprites[2].name = "stage15_taunts_0005"
tt.texts.list[1].color = {247, 133, 102}
tt = E:register_t_hot("decal_s15_malicia_shoutbox", "decal_eb_spider_shoutbox", true)
tt.render.sprites[2].name = "stage15_taunts_0002"
