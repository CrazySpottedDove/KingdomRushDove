-- 无人值守自动测试场（autoplay）
--
-- 用法：
--   love . -autoplay 201              -- campaign
--   love . -autoplay 201 -mode 3      -- iron
--   love . -autoplay 201 -diff 3      -- 难度
--
-- 做的事就一件：跳过其它所有场景，完整跑一局，看看有没有报错。
--   * 走一遍 game 的初始化（关卡数据 / 资源 / 骨骼 / 模拟器）
--   * 不渲染：只推 simulation:update，不调用 render_update / draw
--   * 给每个塔位造一座满级塔，代替玩家点「下一波」
--   * 跑完（或超时）后打印报告并退出
--
-- 判定只看一件事：这局有没有 log.error / 异常。胜负不重要。

local log = require("lib.klua.log"):new("autoplay")

require("all.constants")

local V = require("lib.klua.vector")
local LU = require("level_utils")
local E = require("entity_db")
local U = require("utils")
local I = require("lib.klove.image_db")
local EXO = require("all.exoskeleton")

local autoplay = {}

autoplay.item_name = "autoplay"
autoplay.ref_w = REF_W
autoplay.ref_h = REF_H

--- 每帧最多花多少墙钟秒推进模拟（防止窗口假死）
local WALL_BUDGET = 0.35
--- 模拟的最长游戏内时间（秒）；超时即认为关卡卡住
local MAX_SIM_SECONDS = 60 * 30
--- 固定步长：与正常游玩同一套数值
local STEP = TICK_LENGTH

-- 四系各取一座满级塔（外加几个别的系），轮流摆到塔位上
local TOWER_ROTATION = {"tower_ranger", "tower_sorcerer", "tower_barbarian", "tower_bfg", "tower_musketeer", "tower_arcane_wizard", "tower_tesla", "tower_paladin"}

local stats
local errors

--- 收集 log.error（这就是「有没有报错」的来源）
local function hook_log_errors()
	local ok, klog = pcall(require, "lib.klua.log")

	if not ok or not klog or klog.__autoplay_hooked then
		return
	end

	klog.__autoplay_hooked = true

	local orig_new = klog.new

	function klog:new(name)
		local l = orig_new(self, name)
		local orig_error = l.error

		l.error = function(fmt, ...)
			local msg = tostring(name) .. ": " .. string.format(fmt or "", ...)

			errors[#errors + 1] = msg

			if #errors <= 30 then
				print("AUTOPLAY_ERROR " .. msg)
			end

			return orig_error(fmt, ...)
		end

		return l
	end
end

local function report(reason)
	local verdict = (#errors == 0) and "PASS" or "FAIL"

	print("\n================ AUTOPLAY REPORT ================")
	print(string.format("AUTOPLAY %-22s %s", "level_idx", tostring(stats.level_idx)))
	print(string.format("AUTOPLAY %-22s %s", "level_mode", tostring(stats.level_mode)))
	print(string.format("AUTOPLAY %-22s %s", "level_difficulty", tostring(stats.level_difficulty)))
	print(string.format("AUTOPLAY %-22s %s", "reason", reason))
	print(string.format("AUTOPLAY %-22s %s", "errors", tostring(#errors)))
	print(string.format("AUTOPLAY %-22s %s", "sim_seconds", string.format("%.1f", stats.total_ts or 0)))
	print(string.format("AUTOPLAY %-22s %s", "waves", string.format("%s/%s", tostring(stats.wave_group_number or 0), tostring(stats.wave_group_total or "?"))))
	print(string.format("AUTOPLAY %-22s %s", "lives", tostring(stats.lives or "?")))
	print(string.format("AUTOPLAY %-22s %s", "towers_built", tostring(stats.towers_built or 0)))
	print(string.format("AUTOPLAY %-22s %s", "victory", tostring(stats.victory)))
	print(string.format("AUTOPLAY %-22s %s", "verdict", verdict))

	for i, e in ipairs(errors) do
		if i <= 30 then
			print(string.format("AUTOPLAY_ERROR[%d] %s", i, e))
		end
	end

	print("=================================================\n")
	io.stdout:flush()
end

function autoplay:init(w, h, done_callback)
	self.screen_w = w
	self.screen_h = h
	self.done_callback = done_callback
	self.phase = "load_resources"

	stats = {}
	errors = {}

	hook_log_errors()

	local args = self.args or {}
	local level_idx = args.level_idx
	local level_mode = args.level_mode or GAME_MODE_CAMPAIGN
	local level_difficulty = args.level_difficulty or DIFFICULTY_NORMAL

	stats.level_idx = level_idx
	stats.level_mode = level_mode
	stats.level_difficulty = level_difficulty

	local game_gui = require("game_gui")
	local game = require("game")
	local director = require("director")

	self.game = game

	game.item_name = "game"
	game.max_fps = DRAW_FPS

	game.store = {}
	game.store.level_idx = level_idx
	game.store.level_name = "level" .. string.format("%02i", level_idx)
	game.store.level_mode = level_mode
	game.store.level_difficulty = level_difficulty
	game.store.screen_scale = director:get_texture_scale("game", REF_H)
	game.store.texture_size = director.params.texture_size
	game.store.level = LU.load_level(game.store, game.store.level_name)

	if not game.store.level or not game.store.level.data then
		errors[#errors + 1] = "level data not found: " .. tostring(game.store.level_name)
		report("level_not_found")
		love.event.quit()

		return
	end

	local function replace_locale(list)
		local out = {}

		for _, s in pairs(list or {}) do
			out[#out + 1] = string.gsub(s, "LOCALE", require("i18n").current_locale)
		end

		return out
	end

	-- 资源：与 director 的 type="game" 分支一致
	director:load_texture_groups(replace_locale(game.required_textures), director.params.texture_size, game.ref_res, true, "game")
	director:load_plugin_texture_groups(game.plugin_required_textures, game.ref_res, true, "game")
	director:load_texture_groups(replace_locale(game.store.level.required_textures), director.params.texture_size, game.ref_res, true, "game")
	director:load_texture_groups(replace_locale(game_gui.required_textures), director.params.texture_size, game_gui.ref_res, true, "game_gui")
	director:load_plugin_texture_groups(game_gui.plugin_required_textures, game_gui.ref_res, true, "game_gui")
	director:load_sound_groups(game.required_sounds)
	director:load_sound_groups(game.plugin_required_sounds)
	director:load_sound_groups(game.store.level.required_sounds)
	director:load_sound_groups(game_gui.plugin_required_sounds)

	if game.store.level.required_exoskeletons then
		EXO:queue_load(game.store.level.required_exoskeletons)
	end

	EXO:queue_load(game.required_exoskeletons)

	-- 走一遍 game 的初始化协程（内部就是 simulation:init + 关卡加载）
	self.init_co = game:init_coro(w, h, nil)
end

--- 推动 game 的加载协程
---@return boolean|nil true=完成 false=失败 nil=还要继续
local function pump_init(self)
	local co = self.init_co

	if not co then
		return true
	end

	local ok, err = coroutine.resume(co)

	if not ok then
		errors[#errors + 1] = "init coroutine: " .. tostring(err)
		print("AUTOPLAY_ERROR init coroutine: " .. tostring(err))
		print(debug.traceback(co, tostring(err)))
		io.stdout:flush()
		self.init_co = nil

		return false
	end

	if coroutine.status(co) == "dead" then
		self.init_co = nil

		return true
	end

	return nil
end

--- 给每个塔位造一座满级塔
function autoplay:build_towers()
	local store = self.game.simulation.store
	local holders = {}

	for _, e in pairs(store.entities) do
		if e.tower_holder and not e.tower_holder.blocked and e.tower and e.tower.type == "holder" then
			holders[#holders + 1] = e
		end
	end

	table.sort(holders, function(a, b)
		return tostring(a.tower.holder_id) < tostring(b.tower.holder_id)
	end)

	for i, holder in ipairs(holders) do
		local name = TOWER_ROTATION[((i - 1) % #TOWER_ROTATION) + 1]
		local t = E:create_entity(name)

		if not t then
			errors[#errors + 1] = "tower template missing: " .. tostring(name)
		else
			t.pos = V.vclone(holder.pos)
			t.tower.spent = 100000
			t.tower.holder_id = holder.tower.holder_id

			if holder.tower.default_rally_pos then
				t.tower.default_rally_pos = V.vclone(holder.tower.default_rally_pos)

				if t.barrack then
					t.barrack.rally_pos = V.vclone(holder.tower.default_rally_pos)
				end
			end

			if t.ui and holder.ui then
				t.ui.nav_mesh_id = holder.ui.nav_mesh_id
			end

			if holder.tower.terrain_style then
				U.set_terrain_style(t, holder.tower.terrain_style)
			end

			simulation:queue_insert_entity(t)
			simulation:queue_remove_entity(holder)
			stats.towers_built = (stats.towers_built or 0) + 1
		end
	end
end

--- 推进若干步模拟（不渲染）
function autoplay:run_sim()
	local store = self.game.simulation.store
	local started = love.timer.getTime()

	while love.timer.getTime() - started < WALL_BUDGET do
		store.paused = false

		-- 代替玩家点「下一波」：清完当前波再发下一波，
		-- 免得同时上多波把每波出怪代码的覆盖度打没。
		if store.next_wave_group_ready and not store.send_next_wave and not LU.has_alive_enemies(store) then
			store.send_next_wave = true
		end

		simulation:update(STEP)

		-- 一帧的渲染侧更新也要跑：render / tween / particle_system 的 on_render_update
		-- 里可能有会影响 main_script 的逻辑（时间回溯的重演走的也是这条路）。
		simulation:render_update(STEP)

		if self.game.game_gui then
			self.game.game_gui:update(STEP)
		end

		if store.game_outcome or (store.waves_finished and not LU.has_alive_enemies(store)) then
			return
		end

		if store.tick_ts >= MAX_SIM_SECONDS then
			return
		end
	end
end

function autoplay:update(dt)
	local store = self.game and self.game.simulation and self.game.simulation.store

	if self.phase == "load_resources" then
		if not I:queue_load_done() then
			return
		end

		self.phase = "init_game"

		return
	end

	if self.phase == "init_game" then
		local done = pump_init(self)

		if done == nil then
			return
		end

		if not done then
			report("init_failed")
			love.event.quit()

			return
		end

		self.phase = "warmup"
		self.warmup_frames = 0

		return
	end

	if not store then
		return
	end

	if self.phase == "warmup" then
		store.paused = false
		simulation:update(STEP)

		self.warmup_frames = self.warmup_frames + 1

		-- 等关卡加载协程彻底跑完，再铺塔
		if self.warmup_frames >= 10 and self.game.progress >= 1 then
			self:build_towers()
			self.phase = "run"
		end

		return
	end

	if self.phase == "run" then
		self:run_sim()

		stats.total_ts = store.tick_ts
		stats.wave_group_number = store.wave_group_number
		stats.wave_group_total = store.wave_group_total
		stats.lives = store.lives

		if store.game_outcome then
			stats.victory = store.game_outcome.victory
			self.phase = "done"

			return
		end

		if store.waves_finished and not LU.has_alive_enemies(store) then
			stats.victory = true
			stats.reason = "waves_finished"
			self.phase = "done"

			return
		end

		if store.tick_ts >= MAX_SIM_SECONDS then
			stats.victory = false
			stats.reason = "timeout"
			self.phase = "done"
		end

		return
	end

	if self.phase == "done" then
		report(stats.reason or "outcome")
		love.event.quit()
	end
end

function autoplay:draw()
-- 不渲染
end

return autoplay
