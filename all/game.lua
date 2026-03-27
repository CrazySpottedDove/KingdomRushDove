-- chunkname: @./all/game.lua
local log = require("lib.klua.log"):new("game")
local km = require("lib.klua.macros")
local perf = require("dove_modules.perf.perf")
local signal = require("lib.hump.signal")
local V = require("hump.vector-light")
local U = require("utils")
local RU = require("render_utils")
local I = require("lib.klove.image_db")
local E = require("entity_db")
local F = require("lib.klove.font_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("screen_utils")
local GR = require("grid_db")
local GS = require("kr1.game_settings")
local AC = require("achievements")
local simulation = require("simulation")
local game_gui = require("game_gui")
local SH = require("klove.shader_db")
local G = love.graphics
local bit = require("bit")

require("all.constants")

game = {}
game.required_textures = {
	"go_decals",
	"go_enemies_common",
	"go_towers_group1",
	"go_editor",
	"go_towers_group2",
	"go_towers_group3",
	"go_towers_group4",
	"go_towers_group5",
	"go_towers_group6",
	"go_towers_pandas",
	"go_towers_dark_elf",
	"go_towers_tricannon",
	"go_towers_demon_pit",
	"go_towers_necromancer",
	"go_towers_ray",
	"go_towers_elven_stargazers",
	"go_towers_sand",
	"go_towers_royal_archers",
	"go_towers_arcane_wizard",
	"go_towers_rocket_gunners",
	"go_towers_flamespitter",
	"go_towers_ballista",
	"go_towers_barrel",
	"go_towers_hermit_toad",
	"go_towers_sparking_geode",
	"go_towers_dwarf",
	"go_towers_ghost",
	"go_towers_paladin_covenant",
	"go_towers_arborean_emissary",
	"go_towers_dragons",
	"tower_holders"
}
game.ref_h = REF_H
game.ref_w = REF_W
game.ref_res = TEXTURE_SIZE_ALIAS.ipad
game.required_sounds = {
	"common",
	"ElvesTowerTaunts",
	"ElvesCommonSounds",
	"tower_dark_elf",
	"tower_tricannon",
	"tower_demon_pit",
	"tower_necromancer",
	"tower_pandas",
	"tower_ray",
	"tower_elven_stargazers",
	"tower_sand",
	"tower_royal_archers",
	"tower_arcane_wizard",
	"tower_rocket_gunners",
	"tower_flamespitter",
	"tower_ballista",
	"tower_barrel",
	"tower_hermit_toad",
	"tower_sparking_geode",
	"tower_dwarf",
	"tower_ghost",
	"tower_paladin_covenant",
	"tower_arborean_emissary",
	"tower_dragons"
}
game.simulation_systems = {
	"level",
	"wave_spawn",
	"wave_spawn_tsv",
	"mod_lifecycle",
	"main_script",
	"events",
	"timed",
	"tween",
	"endless_patch",
	"health",
	"count_groups",
	"hero_xp_tracking",
	"pops",
	"goal_line",
	"tower_upgrade",
	"tower_skill",
	"game_upgrades",
	"texts",
	"particle_system",
	"render",
	"sound_events",
	"seen_tracker",
	"spatial_index",
	"last_hook",
	"lights",
	"assets_checker",
	"wave_generator"
}

function game:init(screen_w, screen_h, done_callback)
	self.dash_start_offset = 0
	self.screen_w = screen_w
	self.screen_h = screen_h
	self.done_callback = done_callback
	self.dashed_shader = SH:get("dashed_path")
	self.path_meshes = {} -- path_id -> { mesh = ..., total_len = ... }

	local aspect = screen_w / screen_h
	if aspect < MIN_SCREEN_ASPECT then
		self.game_scale = screen_w / MIN_SCREEN_ASPECT / self.ref_h
	else
		self.game_scale = screen_h / self.ref_h
	end

	self.game_ref_origin = V.v((screen_w - self.ref_w * self.game_scale) * 0.5, (screen_h - self.ref_h * self.game_scale) * 0.5)
	local visible_h = REF_H
	local visible_w = math.ceil(self.screen_w * self.ref_h / self.screen_h)

	visible_w = km.clamp(REF_H * 4 / 3, REF_H * 16 / 9, visible_w)
	local v_left = (self.ref_w - visible_w) * 0.5
	local v_right = self.ref_w + (visible_w - self.ref_w) * 0.5
	local v_top = visible_h
	local v_bottom = 0
	self.store.visible_coords = {
		top = v_top,
		left = v_left,
		bottom = v_bottom,
		right = v_right
	}
	self.camera = {}
	self.camera.x = screen_w * 0.5
	self.camera.y = screen_h * 0.5
	self.camera.damped_x = nil
	self.camera.damped_y = nil
	self.camera.ww = visible_w * self.game_scale
	self.camera.wh = visible_h * self.game_scale
	self.camera.wl = v_left * self.game_scale
	self.camera.wr = v_right * self.game_scale

	if aspect < 1920 / 1080 then
		-- 我不知道为什么铁皮把 game.ref_w, game.ref_h 直接定义成 REF_W, REF_H! 总之这里相机要对 1920x1080 的设计分辨率进行适配，避免窄屏无法看到所有的地图
		self.camera.wl = 0.5 * (self.game_scale * visible_w - self.camera.wh * 1920 / 1080) + self.camera.wl
		self.camera.wr = self.camera.wl + self.camera.wh * 1920 / 1080
	end

	self.camera.wt = (visible_h - v_top) * self.game_scale
	self.camera.wb = (visible_h - v_bottom) * self.game_scale
	self.camera.zoom = 1
	self.camera.min_zoom = aspect > 1.7777777777777777 and math.min(screen_w, MAX_SCREEN_ASPECT * screen_h) / (visible_w * self.game_scale) or 1
	self.camera.max_zoom = 2.5

	-- 打印所有 window, camera 参数
	-- print( "screen_w:", screen_w, "screen_h:", screen_h, "game_scale:", self.game_scale)
	-- print( "camera.ww:", self.camera.ww, "camera.wh:", self.camera.wh, "camera.wl:", self.camera.wl, "camera.wr:", self.camera.wr, "camera.wt:", self.camera.wt, "camera.wb:", self.camera.wb, "camera.zoom:", self.camera.zoom, "camera.min_zoom:", self.camera.min_zoom, "camera.max_zoom:", self.camera.max_zoom)
	-- print( "game_ref_origin:", self.game_ref_origin.x, self.game_ref_origin.y)
	-- print( "visible_coords:", self.store.visible_coords.left, self.store.visible_coords.top, self.store.visible_coords.right, self.store.visible_coords.bottom)

	function self.camera:clamp()
		self.zoom = km.clamp(self.min_zoom, self.max_zoom, self.zoom)
		self.x = km.clamp(self.wl + self.ww * self.min_zoom / (2 * self.zoom), self.wr - self.ww * self.min_zoom / (2 * self.zoom), self.x)
		self.y = km.clamp(self.wt + self.wh / (2 * self.zoom), self.wb - self.wh / (2 * self.zoom), self.y)
	end

	function self.camera.tween(this, timer, time, x, y, zoom, ease)
		this.damped_x = nil
		this.damped_y = nil
		zoom = zoom or this.zoom
		x = x or this.x
		y = y or this.y

		this:cancel_tween(timer)

		this.tweener = timer:tween(time, this, {
			x = x,
			y = y,
			zoom = zoom
		}, ease, function()
			this.tweener = nil
		end)
	end

	function self.camera.cancel_tween(this, timer)
		if this.tweener then
			timer:cancel(this.tweener)

			this.tweener = nil
		end
	end

	self.camera:clamp()

	RU.init()

	self.store.ephemeral = {}

	simulation:init(self.store, self.simulation_systems)

	self.simulation = simulation

	game_gui:init(screen_w, screen_h, self)

	self.game_gui = game_gui
	-- 允许 store 层影响 game_gui
	self.store.game_gui = game_gui

	if not self.store.level.show_comic_idx or self.store.level_mode ~= GAME_MODE_CAMPAIGN then
		S:queue(string.format("MusicBattlePrep_%02d", self.store.level_idx))
	end

	self:init_debug()
	signal.emit("game-start", self.store)
end

if DEBUG then
	function game:reload_gui()
		self.game_gui:destroy()

		local i18n = require("i18n")

		main:set_locale(i18n.current_locale)

		package.loaded.game_gui = nil
		self.game_gui = require("game_gui")

		self.game_gui:init(self.screen_w, self.screen_h, self)

		if self.store.main_hero then
			self.game_gui:add_hero(self.store.main_hero)
		end
	end
end

function game:restart()
	self.store.restarted = true
	self.store.restart_count = (self.store.restart_count or 0) + 1
	self.store.ephemeral = {}

	self.simulation:init(self.store, self.simulation_systems)
	self.game_gui:init(self.screen_w, self.screen_h, self)
	S:stop_all()
	S:queue(string.format("MusicBattlePrep_%02d", self.store.level_idx))

	self:init_debug()
	signal.emit("game-start", self.store)
end

function game:destroy()
	self.game_gui:destroy()

	self.game_gui = nil

	RU.destroy()
end

function game:update_debug(dt)
	if self.DBG_AUTO_SEND then
		for k, ts in pairs(self.auto_send_list) do
			if game.store.tick_ts - ts > self.auto_send_interval then
				self.auto_send_list[k] = game.store.tick_ts

				local e = E:create_entity(k)

				e.nav_path.pi = self.dbg_active_pi
				e.nav_path.spi = self.dbg_use_random_subpath and math.random(1, 3) or 1
				e.nav_path.ni = P:get_start_node(self.dbg_active_pi)

				self.simulation:queue_insert_entity(e)
			end
		end
	end
end

function game:init_debug()
	if not DEBUG then
		return
	end

	DEBUG_KEYS_ON = true
	self.I = I
	self.DBG_DRAW_CLICKABLE = false
	self.DBG_DRAW_PATHS = nil
	self.DBG_DRAW_GRID = false
	self.DBG_DRAW_CENTERS = false
	self.DBG_ENEMY_PAGES = false
	self.DBG_DRAW_RALLY_RANGES = false
	self.DBG_DRAW_UNIT_RANGE = false
	self.DBG_DRAW_BULLET_TRAILS = false
	self.DBG_FPS_COUNTER = false
	self.PERF_TIME_GRAPH = false
	self.DBG_TIME_MULT = 1
	self.DBG_AUTO_SEND = false
	self.auto_send_list = {}
	self.auto_send_interval = 5
	self.dbg_use_random_subpath = true
	package.loaded["data.game_debug_data"] = nil

	local data = require("data.game_debug_data")

	self.current_enemy_page = data.default_page_for_level and data.default_page_for_level[self.store.level_idx] or 1
	self.enemy_pages = data.enemy_pages
	self.enemy_keys = {"q", "w", "e", "r", "t", "y", "u", "i", "o", "p"}
	self.dbg_active_pi = 1
end

local tick_length_limit = TICK_LENGTH * 1.1
local click_state = {
	active = false,
	press_time = 0,
	threshold = 0.1,
	x = 0,
	y = 0
}

function game:update(dt)
	if DEBUG then
		self:update_debug(dt)
	end

	if click_state.active then
		local now = love.timer.getTime()

		if now - click_state.press_time > click_state.threshold then
			local sx, sy = love.mouse.getPosition()

			self.camera.x = self.camera.x - sx + click_state.x
			self.camera.y = self.camera.y - sy + click_state.y
			self.camera:clamp()
			click_state.x = sx
			click_state.y = sy
		end
	end

	local d = self.simulation.store

	if dt > tick_length_limit then
		dt = tick_length_limit
	end

	d.dt = dt * d.speed_factor
	d.ts = d.ts + d.dt
	d.to = d.to + d.dt

	-- gui 应不受时间倍率影响
	d.to_gui = d.to_gui + dt

	local updated = false

	while d.to > d.tick_length do
		d.to = d.to - d.tick_length
		self.simulation:update(d.tick_length)
		d.step = false
		updated = true
	end

	while d.to_gui > TICK_LENGTH do
		d.to_gui = d.to_gui - TICK_LENGTH
		perf.start("game_gui:update")
		self.game_gui:update(TICK_LENGTH)
		perf.stop("game_gui:update")
		d.step = false
		updated = true
	end

	return updated
end

function game:keypressed(key, isrepeat)
	if DEBUG then
		if key == "/" then
			DEBUG_KEYS_ON = not DEBUG_KEYS_ON
		end

		if DEBUG_KEYS_ON and self:debug_keypressed(key, isrepeat) then
			return true
		end
	end

	return self.game_gui:keypressed(key, isrepeat)
end

function game:keyreleased(key, isrepeat)
	self.game_gui:keyreleased(key, isrepeat)
end

function game:mousepressed(x, y, button, istouch)
	click_state.active = true
	click_state.press_time = love.timer.getTime()
	click_state.x = x
	click_state.y = y

	self.game_gui:mousepressed(x, y, button, istouch)
end

function game:mousereleased(x, y, button, istouch)
	click_state.active = false

	self.game_gui:mousereleased(x, y, button, istouch)
end

function game:wheelmoved(dx, dy)
	if self.camera then
		local old_zoom = self.camera.zoom

		self.camera.zoom = self.camera.zoom * (1 + dy * 0.1)

		self.camera:clamp()
	end

	if self.game_gui.wheelmoved then
		self.game_gui:wheelmoved(dx, dy)
	end
end

game._touch_points = {} -- id -> {x, y}
game._pinch_last_dist = nil
game._pinch_last_center = nil
game._pinch_last_zoom = nil

function game:touchpressed(id, x, y, dx, dy, pressure)
	self._touch_points[id] = {
		x = x,
		y = y
	}

	-- 保持原有 GUI 事件
	if self.game_gui and self.game_gui.touchpressed then
		self.game_gui:touchpressed(id, x, y, dx, dy, pressure)
	end
end

function game:touchreleased(id, x, y, dx, dy, pressure)
	self._touch_points[id] = nil
	self._pinch_last_dist = nil
	self._pinch_last_center = nil
	self._pinch_last_zoom = nil

	if self.game_gui and self.game_gui.touchreleased then
		self.game_gui:touchreleased(id, x, y, dx, dy, pressure)
	end
end

function game:touchmoved(id, x, y, dx, dy, pressure)
	self._touch_points[id] = {
		x = x,
		y = y
	}

	local points = self._touch_points
	local ids = {}

	for k in pairs(points) do
		table.insert(ids, k)
	end

	if #ids == 2 and self.camera then
		local id1, id2 = ids[1], ids[2]
		local p1, p2 = points[id1], points[id2]

		if p1 and p2 then
			local cx = (p1.x + p2.x) / 2
			local cy = (p1.y + p2.y) / 2
			local dist = math.sqrt((p1.x - p2.x) ^ 2 + (p1.y - p2.y) ^ 2)

			if not self._pinch_last_dist then
				self._pinch_last_dist = dist
				self._pinch_last_center = {
					x = cx,
					y = cy
				}
				self._pinch_last_zoom = self.camera.zoom
			else
				local scale = dist / self._pinch_last_dist
				local new_zoom = km.clamp(self.camera.min_zoom, self.camera.max_zoom, self._pinch_last_zoom * scale)
				-- 以两指中心为缩放中心
				local old_zoom = self.camera.zoom
				local ratio = old_zoom / new_zoom

				self.camera.zoom = new_zoom

				self.camera:clamp()
			end
		end
	end

	if self.game_gui and self.game_gui.touchmoved then
		self.game_gui:touchmoved(id, x, y, dx, dy, pressure)
	end
end

function game:focus(focus)
	if self.game_gui.focus then
		self.game_gui:focus(focus)
	end
end

function game:get_ism_state()
	if self.game_gui and self.game_gui.get_ism_state then
		return self.game_gui:get_ism_state()
	end
end

function game:draw()
	self:draw_game()
end

function game:draw_enemy_pages()
	local function print_sh(str, x, y, color)
		color = color and color or {255, 255, 255}

		G.setColor(0, 0, 0)
		G.print(str, x + 1, y + 1)
		G.setColor_old(unpack(color))
		G.print(str, x, y)
		G.setColor(1, 1, 1)
	end

	local sw, sh, scale, origin = SU.clamp_window_aspect(self.screen_w, self.screen_h, self.screen_w, self.screen_h)

	G.setColor(0, 0, 0, 0.392)
	G.rectangle("fill", origin.x + 5, self.screen_h * 0.5 - 5, 270, self.screen_h / 3)

	local names = self.enemy_pages[self.current_enemy_page]
	local x, y = math.floor(origin.x + 10), self.screen_h * 0.5

	G.setFont(F:f("DroidSansMono", 13))

	for i, n in ipairs(names) do
		local key = self.enemy_keys[i]

		print_sh(string.format("%s: %s", key, n), x, y, self.auto_send_list[n] and {255, 100, 100} or {255, 255, 255})

		y = y + 12
	end

	G.setColor(1, 1, 1)

	y = y + 12

	print_sh("[: prev page", x, y)

	y = y + 12

	print_sh("]: next page", x, y)

	y = y + 12

	if self.DBG_AUTO_SEND then
		print_sh("=: auto send (ON)", x, y)
	else
		print_sh("=: auto send (OFF)", x, y)
	end

	y = y + 12

	print_sh(string.format(";: use random subpath: %s", self.dbg_use_random_subpath), x, y)

	y = y + 12

	print_sh(string.format(":: remove existing mods: %s", self.DBG_REMOVE_EXISTING_MODS), x, y)

	y = y + 12

	print_sh(string.format("+/-: auto send time (%s sec)", self.auto_send_interval), x, y)

	if self.store.game_outcome then
		y = y + 12

		print_sh("Lives checking OFF (store.game_outcome set)", x, y)
	end

	y = y + 12

	print_sh(string.format("z/Z: time warp (%sx)", self.DBG_TIME_MULT), x, y)

	y = y + 12

	print_sh(string.format("f9/f10: enemy speed factor (%sx)", GS.difficulty_enemy_speed_factor[self.store.level_difficulty]), x, y)

	y = y + 12

	print_sh(string.format("DEBUG KEYS ARE %s", DEBUG_KEYS_ON and "ON" or "OFF"), x, y)

	y = y + 12

	print_sh(string.format("Frame: %if", self.store.tick_ts * FPS), x, y)

	if self.store._lap_start then
		y = y + 12

		local sta = self.store._lap_start
		local sto = self.store._lap_stop or 0

		print_sh(string.format(",/.: Chrono: %i->%i=%if (%.2fs)", sta * FPS, sto * FPS, (sto - sta) * FPS, sto - sta), x, y)
	end
end

if DEBUG then
	function game:debug_keypressed(key, isrepeat)
		local shift = love.keyboard.isDown("rshift") or love.keyboard.isDown("lshift")
		local ctrl = love.keyboard.isDown("lctrl") or love.keyboard.isDown("lctrl")

		local function remove_all_modifiers()
			log.error("remove_all_modifiers")

			for _, e in pairs(self.store.entities) do
				if e.modifier then
					self.simulation:queue_remove_entity(e)
				end
			end
		end

		local function apply_modifier(name, e)
			if e then
				local m = E:create_entity(name)

				m.modifier.target_id = e.id
				m.pos = V.vclone(e.pos)

				self.simulation:queue_insert_entity(m)
			else
				for _, e in pairs(self.store.enemies) do
					local m = E:create_entity(name)

					m.modifier.target_id = e.id
					m.pos = V.vclone(e.pos)

					self.simulation:queue_insert_entity(m)
				end
			end
		end

		if self.DBG_ENEMY_PAGES and table.contains(self.enemy_keys, key) and #self.enemy_pages[self.current_enemy_page] >= table.keyforobject(self.enemy_keys, key) then
			local idx = table.keyforobject(self.enemy_keys, key)
			local template_name = self.enemy_pages[self.current_enemy_page][idx]
			local e = E:create_entity(template_name)

			if e and e.enemy then
				e.enemy.wave_group_idx = km.clamp(1, 99999, game.store.wave_group_number)
				e.nav_path.pi = self.dbg_active_pi
				e.nav_path.spi = self.dbg_use_random_subpath and math.random(1, 3) or 1
				e.nav_path.ni = P:get_start_node(self.dbg_active_pi)

				if self.DBG_AUTO_SEND then
					if self.auto_send_list[e.template_name] then
						self.auto_send_list[e.template_name] = nil
					else
						self.auto_send_list[e.template_name] = 0
					end
				end

				if not self.DBG_AUTO_SEND then
					self.simulation:queue_insert_entity(e)
				end
			elseif e and e.modifier and not isrepeat then
				if self.DBG_REMOVE_EXISTING_MODS then
					remove_all_modifiers()
				end

				apply_modifier(self.enemy_pages[self.current_enemy_page][idx], self.game_gui.selected_entity)
			end
		elseif key == "-" then
			self.auto_send_interval = km.clamp(1, 1000, self.auto_send_interval - 1)
		elseif key == "=" then
			if shift then
				self.auto_send_interval = km.clamp(1, 1000, self.auto_send_interval + 1)
			else
				self.DBG_AUTO_SEND = not self.DBG_AUTO_SEND
				self.auto_send_list = {}
			end
		elseif key == "`" then
			self.DBG_ENEMY_PAGES = not self.DBG_ENEMY_PAGES
		elseif key == "[" then
			self.current_enemy_page = km.clamp(1, #self.enemy_pages, self.current_enemy_page - 1)
		elseif key == "]" then
			self.current_enemy_page = km.clamp(1, #self.enemy_pages, self.current_enemy_page + 1)
		elseif key == "a" then
			self.store.paused = not self.store.paused
		elseif key == "s" then
			self.store.step = true
		elseif key == "d" then
			if self.game_gui and self.game_gui.selected_entity then
				local e = self.game_gui.selected_entity

				if ctrl and shift and e.health then
					local damage = E:create_entity("damage")

					damage.value = e.health.hp
					damage.target_id = e.id
					damage.damage_type = bit.bor(DAMAGE_EAT)

					table.insert(self.store.damage_queue, damage)
				elseif shift and e.health then
					local damage = E:create_entity("damage")

					damage.value = math.floor(0.9 * e.health.hp - 1)
					damage.target_id = e.id

					table.insert(self.store.damage_queue, damage)
				elseif ctrl and e.health then
					e.health.hp = e.health.hp_max
				elseif e.health then
					local damage = E:create_entity("damage")

					damage.value = e.health.hp
					damage.target_id = e.id
					damage.damage_type = DAMAGE_TRUE

					table.insert(self.store.damage_queue, damage)
				end
			end
		elseif key == "f" then
		-- block empty
		elseif key == "g" then
			self.DBG_DRAW_GRID = not self.DBG_DRAW_GRID
			self.grid_canvas = nil
		elseif key == "h" then
			self.path_canvas = nil

			if not self.DBG_DRAW_PATHS then
				self.DBG_DRAW_PATHS = 1
			elseif self.DBG_DRAW_PATHS == 1 then
				self.DBG_DRAW_PATHS = 2
			else
				self.DBG_DRAW_PATHS = nil
			end
		elseif key == "j" then
			self.dbg_active_pi = km.zmod(self.dbg_active_pi + 1, #P.paths)
			self.path_canvas = nil
		elseif key == "l" then
			if ctrl then
				local outcome = {
					lives_left = 10,
					victory = true,
					stars = game.store.level_mode == 1 and 3 or 1,
					level_idx = game.store.level_idx,
					level_mode = game.store.level_mode,
					level_difficulty = game.store.level_difficulty
				}

				game.store.game_outcome = outcome

				signal.emit("game-victory", game.store)
				signal.emit("game-victory-after", game.store)

				return true
			elseif shift then
				if self.store.lives > 1 then
					self.store.lives = km.clamp(1, 20, self.store.lives - 100)
				else
					self.store.lives = 0
				end
			else
				self.store.lives = self.store.lives + 100
			end

			if self.store.lives > 200 then
				self.store.lives = 1000
				self.store.game_outcome = {}
			elseif self.store.lives <= 20 then
				self.store.game_outcome = nil
			end
		elseif key == ";" then
			if shift then
				self.DBG_REMOVE_EXISTING_MODS = not self.DBG_REMOVE_EXISTING_MODS
			else
				self.dbg_use_random_subpath = not self.dbg_use_random_subpath
			end
		elseif key == "z" then
			if shift then
				self.DBG_TIME_MULT = km.clamp(1, 64, self.DBG_TIME_MULT * 0.5)
			else
				self.DBG_TIME_MULT = km.clamp(1, 64, self.DBG_TIME_MULT * 2)
			end
		elseif key == "x" then
			local heroes = table.filter(self.store.entities, function(_, e)
				return e.hero and not e.hero.stage_hero
			end)

			if heroes and #heroes > 0 then
				heroes[1].hero.xp_queued = 500
			end
		elseif key == "c" then
			if shift then
				self.DBG_DRAW_BULLET_TRAILS = not self.DBG_DRAW_BULLET_TRAILS
			else
				self.DBG_DRAW_CENTERS = not self.DBG_DRAW_CENTERS
				self.DBG_DRAW_CLICKABLE = not self.DBG_DRAW_CLICKABLE
			end
		elseif key == "v" then
			if shift then
				local storage = require("all.storage")
				local slot = storage:load_slot()

				if self.game_gui.window:get_child_by_id("bag_contents_view") then
					for _, v in pairs(self.game_gui.window:get_child_by_id("bag_contents_view").children) do
						v:enable()

						v:ci("bag_item_qty").text = 9999
						slot.bag[v.item] = 9999
					end
				end

				storage:save_slot(slot)
			else
				signal.emit("debug-ready-user-powers")
				signal.emit("debug-ready-plants-crystals")
			end
		elseif key == "b" then
			self.DBG_DRAW_TOWER_RANGE = not self.DBG_DRAW_TOWER_RANGE
			self.DBG_DRAW_UNIT_RANGE = not self.DBG_DRAW_UNIT_RANGE
			self.DBG_DRAW_RALLY_RANGES = not self.DBG_DRAW_RALLY_RANGES
			self.DBG_DRAW_SPECIAL_RANGES = not self.DBG_DRAW_SPECIAL_RANGES
		elseif key == "m" then
			if love.keyboard.isDown("rshift") or love.keyboard.isDown("lshift") then
				self.store.player_gold = self.store.player_gold - 1000
			else
				self.store.player_gold = self.store.player_gold + 1000
			end
		elseif key == "n" then
			if love.keyboard.isDown("rshift") or love.keyboard.isDown("lshift") then
				self.DBG_DRAW_NAV_MESH = not self.DBG_DRAW_NAV_MESH
			else
				self.store.force_next_wave = true
			end
		elseif key == "," then
			self.store._lap_start = self.store.tick_ts
			self.store._lap_stop = nil
		elseif key == "." then
			self.store._lap_stop = self.store.tick_ts
		elseif key == "f8" then
			if self.game_gui.manual_gui_hide then
				signal.emit("show-gui")
			else
				signal.emit("hide-gui")
			end
		elseif key == "f9" then
			GS.difficulty_enemy_speed_factor[self.store.level_difficulty] = GS.difficulty_enemy_speed_factor[self.store.level_difficulty] - 0.01

			log.debug(" decrement speed factor")
		elseif key == "f10" then
			GS.difficulty_enemy_speed_factor[self.store.level_difficulty] = GS.difficulty_enemy_speed_factor[self.store.level_difficulty] + 0.01

			log.debug(" increment speed factor")
		else
			return false
		end

		return true
	end
end

function game:front_draw_debug(rox, roy, gs)
	if self.DBG_DRAW_PATHS and not self.path_canvas then
		local node_size = 2
		local point_size = 3

		G.push()
		G.translate(rox, roy)
		G.scale(gs, gs)

		self.path_canvas = G.newCanvas()

		G.setCanvas(self.path_canvas)

		for pi, p in ipairs(P.paths) do
			for _, sp in pairs(p) do
				for ni, o in ipairs(sp) do
					if ni % 2 == 0 then
						G.setColor(1, 0, 0, 0.47058823529411764)
						G.circle("fill", o.x, REF_H - o.y, 3, 6)
					end
				end
			end
		end

		G.setLineWidth(1)
		G.setColor(1, 1, 1, 1)
		G.setCanvas()
		G.pop()
	end

	if self.DBG_DRAW_GRID and not self.grid_canvas then
		G.push()
		G.translate(rox, REF_H * gs + roy)
		G.scale(gs, -gs)
		G.translate(GR.ox, GR.oy)

		self.grid_canvas = G.newCanvas()

		G.setCanvas(self.grid_canvas)

		for i = 1, #GR.grid do
			for j = 1, #GR.grid[i] do
				local t = GR.grid[i][j]

				G.setColor_old(GR.grid_colors[t] or {100, 100, 100})
				G.rectangle("fill", (i - 1) * GR.cell_size, (j - 1) * GR.cell_size, GR.cell_size, GR.cell_size)
			end
		end

		if GR.waypoints_cache and GR.waypoints_cache.path_c then
			G.setColor_old(GR.grid_colors.path)

			for _, n in pairs(GR.waypoints_cache.path_c) do
				G.rectangle("fill", (n.x - 0.5) * GR.cell_size, (n.y - 0.5) * GR.cell_size, GR.cell_size * 0.5, GR.cell_size * 0.5)
			end
		end

		if DEBUG_POINTS then
			G.setColor_old(GR.grid_colors.path)

			for _, n in pairs(DEBUG_POINTS) do
				G.rectangle("fill", (n.x - 0.5) * GR.cell_size, (n.y - 0.5) * GR.cell_size, GR.cell_size * 0.5, GR.cell_size * 0.5)
			end
		end

		G.setCanvas()
		G.setColor(1, 1, 1, 1)
		G.pop()
	end

	if self.DBG_DRAW_GRID then
		G.setColor(1, 1, 1, 0.392)
		G.draw(self.grid_canvas)
		G.setColor(1, 1, 1, 1)
	end

	if self.DBG_DRAW_RALLY_RANGES then
		G.push()
		G.translate(rox, roy)
		G.scale(gs, gs)

		for _, e in pairs(self.store.entities) do
			if e.barrack then
				local b = e.barrack
				local s = E:get_template(b.soldier_type)

				G.setColor(0.392, 0.392, 1, 0.392)

				if s.melee then
					local range = s.melee.range

					G.ellipse("fill", b.rally_pos.x, REF_H - b.rally_pos.y, range, range * ASPECT)
				end
			end
		end

		G.setColor(1, 1, 1, 1)
		G.pop()
	end

	if self.DBG_DRAW_SPECIAL_RANGES then
		G.push()
		G.translate(rox, roy)
		G.scale(gs, gs)

		for _, e in pairs(self.store.entities) do
			if e.custom_attack and e.custom_attack.range then
				G.setColor_old(100, 100, 255, 100)
				G.ellipse("fill", e.pos.x, REF_H - e.pos.y, e.custom_attack.range, e.custom_attack.range * ASPECT)
			end
		end

		for _, e in pairs(self.store.entities) do
			if e.aura and e.aura.damage_radius then
				G.setColor_old(100, 100, 255, 100)
				G.ellipse("fill", e.pos.x, REF_H - e.pos.y, e.aura.damage_radius, e.aura.damage_radius * ASPECT)
			end
		end

		G.setColor(1, 1, 1, 1)
		G.pop()
	end

	if self.DBG_DRAW_TOWER_RANGE then
		G.push()
		G.translate(rox, roy)
		G.scale(gs, gs)

		local e = game.game_gui.selected_entity or self.dbg_last_selected_entity

		if e then
			self.dbg_last_selected_entity = e

			local range = e.attacks and e.attacks.range

			if range then
				range = range * (e.attacks.prediction_range_factor or 1)

				local pos = e.pos

				if e.tower and e.tower.range_offset then
					pos = V.v(pos.x + e.tower.range_offset.x, pos.y + e.tower.range_offset.y)
				end

				G.setColor_old(100, 100, 255, 100)
				G.setLineWidth(3)
				G.ellipse("line", pos.x, REF_H - pos.y, range, range * ASPECT)

				if e.attacks and e.attacks.range_check_factor then
					local f = e.attacks.range_check_factor

					G.setColor_old(100, 100, 255, 60)
					G.setLineWidth(3)
					G.ellipse("line", pos.x, REF_H - pos.y, f * range, f * range * ASPECT)
				end
			end
		end

		G.setColor(1, 1, 1, 1)
		G.pop()
	end

	if self.DBG_DRAW_UNIT_RANGE then
		G.push()
		G.translate(rox, roy)
		G.scale(gs, gs)

		local e = game.game_gui.selected_entity or self.dbg_last_selected_entity

		if e then
			self.dbg_last_selected_entity = e

			local range, min_range

			if e.ranged then
				range = e.ranged.attacks[1].max_range
				min_range = e.ranged.attacks[1].min_range
			elseif e.melee and e.melee.range then
				range = e.melee.range
			elseif e.attacks and e.attacks.list[1] and e.attacks.list[1].max_range then
				range = e.attacks.list[1].max_range
				min_range = e.attacks.list[1].min_range
			end

			if range then
				G.setColor_old(100, 100, 255, 100)
				G.setLineWidth(3)
				G.ellipse("line", e.pos.x, REF_H - e.pos.y, range, range * ASPECT)
			end

			if min_range then
				G.setColor_old(50, 50, 255, 100)
				G.setLineWidth(2)
				G.ellipse("line", e.pos.x, REF_H - e.pos.y, min_range, min_range * ASPECT)
			end
		end

		G.setColor(1, 1, 1, 1)
		G.pop()
	end

	if self.DBG_DRAW_AURA_RANGE then
		G.push()
		G.translate(rox, roy)
		G.scale(gs, gs)

		for _, e in pairs(self.store.entities) do
			if e.aura and e.aura.radius then
				G.setColor_old(100, 100, 255, 100)
				G.setLineWidth(3)
				G.ellipse("line", e.pos.x, REF_H - e.pos.y, e.aura.radius, e.aura.radius * ASPECT)
			end
		end

		G.setColor(1, 1, 1, 1)
		G.pop()
	end
end

function game:after_draw_debug(rox, roy, gs)
	if self.DBG_DRAW_CENTERS then
		G.push()
		G.translate(rox, roy)
		G.scale(gs, gs)

		for _, e in pairs(self.store.entities) do
			if e.pos and e.bullet then
				G.setLineWidth(1)
				G.setColor_old(200, 200, 0, 200)
				G.line(e.pos.x - 1, REF_H - e.pos.y - 1, e.pos.x + 1, REF_H - e.pos.y + 1)
				G.line(e.pos.x - 1, REF_H - e.pos.y + 1, e.pos.x + 1, REF_H - e.pos.y - 1)
			elseif e.pos and not e.bullet and not e.decal then
				G.setColor_old(0, 0, 200, 200)
				G.rectangle("fill", e.pos.x - 1, REF_H - e.pos.y - 4, 2, 8)
				G.rectangle("fill", e.pos.x - 4, REF_H - e.pos.y - 1, 8, 2)
			end
		end

		G.pop()
		G.setColor(1, 1, 1, 1)
	end

	if self.DBG_DRAW_CLICKABLE then
		G.push()
		G.translate(rox, roy)
		G.scale(gs, gs)

		for _, e in pairs(self.store.entities) do
			if e.ui then
				G.setColor_old(255, 255, 0, 70)

				local rect = e.ui.click_rect

				G.rectangle("fill", e.pos.x + rect.pos.x, REF_H - (e.pos.y + rect.pos.y), rect.size.x, -rect.size.y)
			end
		end

		G.pop()
		G.setColor(1, 1, 1, 1)
	end

	if self.DBG_DRAW_NAV_MESH then
		G.push()
		G.translate(rox, roy)
		G.scale(gs, gs)
		G.setFont(F:f("DroidSansMono", 18))

		local towers = {}

		for _, e in pairs(self.store.entities) do
			if e.ui and e.ui.nav_mesh_id then
				towers[tonumber(e.ui.nav_mesh_id)] = e

				G.setColor_old(0, 0, 0, 255)
				G.print(e.ui.nav_mesh_id, e.pos.x + 5, REF_H - e.pos.y - 8)
				G.setColor_old(202, 202, 0, 255)
				G.print(e.ui.nav_mesh_id, e.pos.x + 5 - 2, REF_H - e.pos.y - 8 - 2)
			end
		end

		G.setColor_old(0, 100, 255, 255)
		G.setLineWidth(2)
		G.translate(0, -10)

		local ox, oy = 40, 15
		local ax, ay = 40, 15

		for h_id, row in pairs(self.store.level.nav_mesh) do
			local e = towers[h_id]

			if not e then
			-- block empty
			else
				local oe = towers[row[1]]

				if oe then
					G.line(e.pos.x + ox, REF_H - e.pos.y, oe.pos.x - ax, REF_H - oe.pos.y)
				end

				oe = towers[row[2]]

				if oe then
					G.line(e.pos.x, REF_H - e.pos.y - oy, oe.pos.x, REF_H - oe.pos.y + ay)
				end

				oe = towers[row[3]]

				if oe then
					G.line(e.pos.x - ox, REF_H - e.pos.y, oe.pos.x + ax, REF_H - oe.pos.y)
				end

				oe = towers[row[4]]

				if oe then
					G.line(e.pos.x, REF_H - e.pos.y + oy, oe.pos.x, REF_H - oe.pos.y - ay)
				end
			end
		end

		local s2 = 10
		local s3 = 15

		G.setColor_old(0, 0, 200, 255)

		for h_id, row in pairs(self.store.level.nav_mesh) do
			local e = towers[h_id]

			if not e then
			-- block empty
			else
				for i = 1, 4 do
					local oe = towers[row[i]]

					if oe then
						local tx, ty, ta, a, r

						if i == 1 then
							tx, ty = e.pos.x + ox, REF_H - e.pos.y
							a, r = V.toPolar(oe.pos.x - ax - (e.pos.x + ox), REF_H - oe.pos.y - (REF_H - e.pos.y))
						elseif i == 2 then
							tx, ty = e.pos.x, REF_H - e.pos.y - oy
							a, r = V.toPolar(oe.pos.x - e.pos.x, REF_H - oe.pos.y + ay - (REF_H - e.pos.y - oy))
						elseif i == 3 then
							a, r = V.toPolar(oe.pos.x + ax - (e.pos.x - ox), REF_H - oe.pos.y - (REF_H - e.pos.y))
							tx, ty = e.pos.x - ox, REF_H - e.pos.y
						else
							a, r = V.toPolar(oe.pos.x - e.pos.x, REF_H - oe.pos.y - ay - (REF_H - e.pos.y + oy))
							tx, ty = e.pos.x, REF_H - e.pos.y + oy
						end

						if a then
							G.push()
							G.translate(tx, ty)
							G.rotate(a)
							G.translate(s3, 0)
							G.polygon("fill", s2, 0, 0, s2, 0, -s2)
							G.pop()
						end
					end
				end
			end
		end

		G.pop()
		G.setColor(1, 1, 1, 1)
	end

	if self.DBG_DRAW_BULLET_TRAILS then
		G.push()
		G.scale(gs, gs)
		G.translate(rox, roy)

		if not self.dbg_bullet_canvas then
			self.dbg_bullet_canvas = G.newCanvas()
		end

		G.setCanvas(self.dbg_bullet_canvas)

		for _, e in pairs(self.store.entities) do
			if e.bullet and e.bullet.from and e.bullet.to and (not self.DBG_DRAW_BULLET_TRAILS_SOURCE or e.bullet.source_id == self.DBG_DRAW_BULLET_TRAILS_SOURCE) then
				G.setColor_old(0, 0, 255, 255)
				G.circle("fill", e.bullet.from.x, REF_H - e.bullet.from.y, 4, 3)
				G.circle("fill", e.bullet.to.x, REF_H - e.bullet.to.y, 4, 5)
				G.setColor_old(0, 255, 100, 255)
				G.circle("fill", e.pos.x, REF_H - e.pos.y, 1, 6)
			end
		end

		G.setCanvas()
		G.scale(gs, gs)
		G.pop()
		G.setColor(1, 1, 1, 0.784)
		G.draw(self.dbg_bullet_canvas)
		G.setColor(1, 1, 1, 1)
	elseif self.dbg_bullet_canvas then
		self.dbg_bullet_canvas = nil
	end

	if self.DBG_ENEMY_PAGES then
		game:draw_enemy_pages()
	end
end

function game:draw_dark_foreground(rox, roy, gs)
	G.push()
	G.translate(rox, roy)
	G.scale(gs, gs)
	-- 直接在当前渲染目标（通常是屏幕）上使用 stencil，避免在 Canvas 上做 stencil 的兼容问题
	love.graphics.stencil(function()
		-- 绘制圆形遮罩（将这些区域从遮罩中抠出）
		if self.store and self.store.lights then
			for _, l in pairs(self.store.lights) do
				local _, uy = game_gui:g2u(l.pos)

				love.graphics.circle("fill", l.pos.x, uy, l.radius)
			end
		end

		local x, y = game_gui.window:get_mouse_position()
		local ux, uy = game_gui.window:screen_to_view(x, y)
		local gx = game_gui:u2g(vec_2(ux, uy))

		love.graphics.circle("fill", gx, uy, 50)
	end, "replace", 1)
	-- 仅在 stencil 值为 0 的区域绘制暗色覆盖层（被抠出的圆形保持亮）
	love.graphics.setStencilTest("equal", 0)
	G.setColor(0, 0, 0.2, 0.1176)
	-- 覆盖一个足够大的矩形，注意使用相对于 push() 的坐标
	G.rectangle("fill", -rox - 20, -roy - 20, 2000, 1100)
	-- 恢复默认
	love.graphics.setStencilTest()
	G.setColor(1, 1, 1, 1)
	G.pop()
end

-- 构建某条路径的三角形 Mesh（带每顶点 PathDistance），并缓存
function game:_build_path_mesh(path_ids, thickness)
	local vertex_format = {{"VertexPosition", "float", 2}, {"VertexTexCoord", "float", 2}}
	local vertices = {}

	local function add_quad(p0, p1, d0, d1, t)
		local x0, y0 = p0.x, REF_H - p0.y
		local x1, y1 = p1.x, REF_H - p1.y
		local dx, dy = x1 - x0, y1 - y0
		local len = math.sqrt(dx * dx + dy * dy)
		if len <= 0 then
			return
		end
		local nx, ny = -dy / len, dx / len
		local ox, oy = nx * (t * 0.5), ny * (t * 0.5)

		local v0 = {x0 + ox, y0 + oy, d0, 0}
		local v1 = {x0 - ox, y0 - oy, d0, 0}
		local v2 = {x1 + ox, y1 + oy, d1, 0}
		local v3 = {x1 - ox, y1 - oy, d1, 0}

		-- 两个三角形
		table.insert(vertices, v0)
		table.insert(vertices, v1)
		table.insert(vertices, v2)

		table.insert(vertices, v2)
		table.insert(vertices, v1)
		table.insert(vertices, v3)
	end

	local total_len = 0

	for i, path_id in ipairs(path_ids) do
		for spi, sp in ipairs(P.paths[path_id]) do
			local d_acc = 0
			local start_ni = 2
			-- 如果上一条连接到这一条路径，需要寻找正确的起点
			if i > 1 then
				start_ni = math.max(P.path_connections_spi_to_ni[path_ids[i - 1]][spi], 2)
			end
			for ni = start_ni, #sp do
				local p0 = sp[ni - 1]
				local p1 = sp[ni]
				local dx = p1.x - p0.x
				local dy = p1.y - p0.y
				local seg = math.sqrt(dx * dx + dy * dy)
				add_quad(p0, p1, d_acc, d_acc + seg, thickness)
				d_acc = d_acc + seg
			end
			total_len = total_len + d_acc
		end
	end

	local mesh = G.newMesh(vertex_format, vertices, "triangles", "static")
	return mesh, total_len
end

function game:draw_path(rox, roy, gs)
	-- 懒构建 Mesh 并缓存
	local pid = self.shown_path
	if not self.path_meshes[pid] then
		local mesh, total_len = self:_build_path_mesh(P:get_connected_paths(pid), 4) -- 厚度可调
		self.path_meshes[pid] = {
			mesh = mesh,
			total_len = total_len
		}
	end
	local mh = self.path_meshes[pid]

	local dash_length = 25
	local gap_length = 15
	local speed = 60

	-- 时间推进（用 store.dt）
	local d = self.store
	self.dash_start_offset = (self.dash_start_offset or 0) + speed * (d and d.dt or 0.016)
	local period = dash_length + gap_length
	self.dash_start_offset = self.dash_start_offset % period

	-- 设置 shader 参数
	self.dashed_shader:send("dash_length", dash_length)
	self.dashed_shader:send("gap_length", gap_length)
	self.dashed_shader:send("dash_offset", self.dash_start_offset)

	G.setShader(self.dashed_shader)
	G.push()
	G.translate(rox, roy)
	G.scale(gs, gs)
	G.draw(mh.mesh)
	G.pop()
	G.setShader()
end

function game:draw_game()
	local d = self.store

	local frame_draw_params = RU.frame_draw_params
	local draw_frames_range = RU.draw_frames_range
	local gs = self.game_scale

	local c = self.camera

	-- c:clamp()

	local rox, roy = -(c.x * c.zoom - self.screen_w * 0.5), -(c.y * c.zoom - self.screen_h * 0.5)
	gs = gs * c.zoom

	if d.world_offset then
		rox, roy = rox + d.world_offset.x, roy + d.world_offset.y
	end

	-- self:front_draw_debug(rox, roy, gs)
	G.push()
	G.translate(rox, roy)
	G.scale(gs, gs)
	local last_idx = draw_frames_range(d.render_frames, 1, Z_SCREEN_FIXED - 1)
	G.pop()

	if self.DBG_DRAW_PATHS or self.shown_path then
		self:draw_path(rox, roy, gs)
	end

	if d.night_mode then
		self:draw_dark_foreground(rox, roy, gs)
	end

	G.push()
	G.translate(self.game_ref_origin.x, self.game_ref_origin.y)
	G.scale(self.game_scale, self.game_scale)
	last_idx = draw_frames_range(d.render_frames, last_idx + 1, Z_GUI - 1)
	G.pop()

	self.game_gui.window:draw_child(self.game_gui.layer_gui)

-- self:after_draw_debug(rox, roy, gs)
end

return game
