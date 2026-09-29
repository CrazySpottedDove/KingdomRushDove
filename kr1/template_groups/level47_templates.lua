local E = require("entity_db")
local U = require("utils")
require("all.constants")
require("lib.klua.table")
local function decal_taunting_dracula_update(this, store)
	local taunt = this.taunt
	local pos_idx = math.random(1, 2)
	local s = this.render.sprites[1]
	local cooldown = math.random(taunt.cooldown[1], taunt.cooldown[2])
	local last_ts
	local moon = store.level and store.level.moon_controller
	local last_was_moon = false
	local last_wave
	local function show_taunt(pos_idx, fmt, idx, duration)
		local t = E:create_entity("decal_dracula_shoutbox")
		t.texts.list[1].text = _(string.format(fmt, idx))
		t.pos = taunt.taunt_positions[pos_idx]
		t.timed.duration = duration
		t.render.sprites[1].ts = store.tick_ts
		t.render.sprites[2].ts = store.tick_ts
		simulation:queue_insert_entity(t)
		return t
	end
	this.showing = true
	this.pos = taunt.dracula_positions[pos_idx]
	s.hidden = false
	U.y_animation_play(this, "show", nil, store.tick_ts, 1)
	show_taunt(pos_idx, taunt.format_welcome, 1, taunt.duration)
	U.y_wait_unconditional(store, taunt.duration)
	show_taunt(pos_idx, taunt.format_welcome, 2, taunt.duration)
	U.y_wait_unconditional(store, taunt.duration)
	U.y_animation_play(this, "hide", nil, store.tick_ts, 1)
	s.hidden = true
	last_ts = store.tick_ts
	this.showing = false
	while true do
		if moon and moon.moon_active and not last_was_moon and store.tick_ts - last_ts > taunt.min_cooldown then
			last_was_moon = true
			this.showing = true
			this.pos = taunt.dracula_positions[pos_idx]
			s.hidden = false
			U.y_animation_play(this, "show", nil, store.tick_ts, 1)
			local taunt_idx = math.random(taunt.idx_moon[1], taunt.idx_moon[2])
			show_taunt(pos_idx, taunt.format_moon, taunt_idx, taunt.duration)
			U.y_wait_unconditional(store, taunt.duration)
			U.y_animation_play(this, "hide", nil, store.tick_ts, 1)
			s.hidden = true
			last_ts = store.tick_ts
			pos_idx = math.random(1, 2)
			this.showing = false
		elseif cooldown < store.tick_ts - last_ts or last_wave ~= store.wave_group_number and store.tick_ts - last_ts > taunt.min_cooldown then
			last_was_moon = false
			this.showing = true
			this.pos = taunt.dracula_positions[pos_idx]
			s.hidden = false
			U.y_animation_play(this, "show", nil, store.tick_ts, 1)
			local taunt_idx = math.random(taunt.idx_generic[1], taunt.idx_generic[2])
			show_taunt(pos_idx, taunt.format_generic, taunt_idx, taunt.duration)
			U.y_wait_unconditional(store, taunt.duration)
			U.y_animation_play(this, "hide", nil, store.tick_ts, 1)
			s.hidden = true
			last_ts = store.tick_ts
			pos_idx = math.random(1, 2)
			this.showing = false
		end
		last_wave = store.wave_group_number
		coroutine.yield()
	end
end
local tt
tt = E:register_t_hot("decal_taunting_dracula", "decal_scripted", true)
tt.main_script.update = decal_taunting_dracula_update
tt.render.sprites[1].prefix = "decal_taunting_dracula"
tt.render.sprites[1].name = "show"
tt.render.sprites[1].anchor.y = 0.1375
tt.render.sprites[1].sort_y = 557
tt.taunt = {}
tt.taunt.cooldown = {50, 70}
tt.taunt.min_cooldown = 10
tt.taunt.format_welcome = "DRACULA_TAUNT_WELCOME_%04d"
tt.taunt.format_moon = "DRACULA_TAUNT_MOON_%04d"
tt.taunt.format_generic = "DRACULA_TAUNT_GENERIC_%04d"
tt.taunt.idx_welcome = {1, 2}
tt.taunt.idx_moon = {1, 4}
tt.taunt.idx_generic = {1, 12}
tt.taunt.duration = 4
tt.taunt.shoutbox = "decal_dracula_shoutbox"
tt.taunt.dracula_positions = {vec_2(328, 615), vec_2(708, 615)}
tt.taunt.taunt_positions = {vec_2(327, 558), vec_2(707, 558)}
tt.taunt.ts = 0
local function AC(tpl, ...)
	return E:add_comps(tpl, ...)
end
local i18n = require("i18n")
tt = E:register_t_hot("decal_dracula_shoutbox", "decal_tween", true)
AC(tt, "texts", "timed")
tt.render.sprites[1].name = "HalloweenBoss_tauntBox"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_BULLETS
tt.render.sprites[2].offset = vec_2(0, -9)
tt.texts.list[1].text = "Hello world"
tt.texts.list[1].size = vec_2(172, 62)
tt.texts.list[1].font_name = "body_bold"
tt.texts.list[1].font_size = 20
tt.texts.list[1].color = {255, 114, 114}
tt.texts.list[1].line_height = i18n:cjk(0.8, nil, 1.1, 0.7)
tt.texts.list[1].sprite_id = 2
tt.texts.list[1].fit_height = true
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {{0, vec_2(1.01, 1.01)}, {0.4, vec_2(0.99, 0.99)}, {0.8, vec_2(1.01, 1.01)}}
tt.tween.props[1].loop = true
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.remove = false
