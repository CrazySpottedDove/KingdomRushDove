-- 无人值守自动测试场（autoplay）
--
-- 用法：
--   love . -autoplay 201              -- campaign
--   love . -autoplay 201 -mode 3      -- iron
--   love . -autoplay 201 -diff 3      -- 难度
--   love . -autoplay 201 -noclick     -- 关闭自动点击（只测纯战斗）
--   love . -autoplay 201 -notowers    -- 不铺塔（只测无塔时敌人推平/结算）
--
-- 做的事就一件：跳过其它所有场景，完整跑一局，看看有没有报错。
--   * 走一遍 game 的初始化（关卡数据 / 资源 / 骨骼 / 模拟器）
--   * 不渲染：只推 simulation:update，不调用 render_update / draw
--   * 给每个塔位造一座满级塔，代替玩家点「下一波」
--   * 自动点击带 ui 的世界物件（羊/篝火/马厩/谷仓…）与需要选点的特殊塔
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
--- 进入最后一波后，若这么久还没结算（boss 打不死/卡住），也算跑完，避免拖到 MAX
local LAST_WAVE_TIMEOUT = 180
--- 固定步长：与正常游玩同一套数值
local STEP = TICK_LENGTH
--- 自动点击节流：每隔多少游戏内秒点一轮（避免刷屏点击）
local CLICK_INTERVAL = 0.5

-- 四系各取一座满级塔（外加几个别的系），轮流摆到塔位上
local TOWER_ROTATION = {"tower_ranger", "tower_sorcerer", "tower_barbarian", "tower_bfg", "tower_musketeer", "tower_arcane_wizard", "tower_tesla", "tower_paladin"}

local stats
local errors

-- AUTOPLAY 覆盖 love.errorhandler：调试时出错立即退出（love 的兜底 handler 会留在错误界面不退出）
do
	local _orig = love.errorhandler

	love.errorhandler = function(msg)
		print("AUTOPLAY 异常，立即退出：")
		print(tostring(msg))
		print(debug.traceback("", 2))

		if _orig and os.getenv("AUTOPLAY_KEEP_ERRORHANDLER") then
			return _orig(msg)
		end

		os.exit(1)
	end
end

--- 收集 log.error（这就是「有没有报错」的来源）
local S = require("sound_db")
require("i18n").set_debug_missing(true) -- autoplay 时把缺失文案打出来（按需替换实现，平时零开销）

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
				print(debug.traceback("", 2))
			end

			-- 调试用：首个报错立刻退出（报错本身不会让主循环停下来）
			if #errors == 1 and not _G.AUTOPLAY_NO_FAST_EXIT then
				print("AUTOPLAY 首个报错，立即退出")
				love.event.quit(1)
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
	print(string.format("AUTOPLAY %-22s %s", "auto_clicks", tostring(stats.auto_clicks or 0)))
	print(string.format("AUTOPLAY %-22s %s", "auto_hires", tostring(stats.auto_hires or 0)))
	print(string.format("AUTOPLAY %-22s %s", "victory", tostring(stats.victory)))
	print(string.format("AUTOPLAY %-22s %s", "verdict", verdict))

	for i, e in ipairs(errors) do
		if i <= 30 then
			print(string.format("AUTOPLAY_ERROR[%d] %s", i, e))
			love.event.quit(1)
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

	self.auto_click = (args.auto_click ~= false)
	self.build_towers_enabled = (args.build_towers ~= false)
	self.next_click_ts = 0
	stats.auto_clicks = 0

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

	if game.store.level.plugin_required_exoskeletons then
		EXO:queue_load_plugin(game.store.level.plugin_required_exoskeletons)
	end

	EXO:queue_load(game.required_exoskeletons)
	EXO:queue_load_plugin(game.plugin_required_exoskeletons)
	EXO:queue_load_plugin(game_gui.plugin_required_exoskeletons)

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
		love.event.quit(1)
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

--- 把实体所在的世界坐标换算成窗口坐标，模拟一次真实的鼠标左键点击。
--- 走 game_gui:mousepressed → window:mousepressed → PickView:on_down →
--- select_entity / InfoBar / TowerMenu。autoplay 不再自己置 ui.clicked
--- （直接置字段会漏掉 info.fn、塔菜单等点击路径里的报错）。
function autoplay:simulate_click_at(e)
	local game_gui = self.game.game_gui

	if not game_gui or not game_gui.window or not e.pos then
		return
	end

	local wx, wy = e.pos.x, e.pos.y
	local rect = e.ui and e.ui.click_rect

	if rect then
		-- 点 click_rect 中心，命中率更高
		wx = e.pos.x + rect.pos.x + rect.size.x * 0.5
		wy = e.pos.y + rect.pos.y + rect.size.y * 0.5
	end

	local ux, uy = game_gui:g2u(V.v(wx, wy))
	local origin = game_gui.window.origin
	local scale = game_gui.window.scale
	local sx = origin.x + ux * scale.x
	local sy = origin.y + uy * scale.y

	game_gui:mousepressed(sx, sy, 1)
	game_gui:mousereleased(sx, sy, 1)
end

--- 强制推进 boss 阶段：autoplay 的通用塔常被 boss 波的小怪吸引，打不动 boss，
--- 于是 boss 的 phase 代码（升空/降落等，例如 stage11 boss 升到屏幕外坐标）测不到。
--- 这里按 `phases_health_thresholds` 把 boss 血量逐档压低，确保每个 phase 都跑一遍。
function autoplay:force_boss_phases()
	local store = self.game.simulation.store

	for _, e in pairs(store.entities) do
		if e.health and not e.health.dead and not e.pending_removal and e.phases_health_thresholds and e.health.hp_max > 0 then
			local hp_max = e.health.hp_max

			for _, t in ipairs(e.phases_health_thresholds) do
				if e.health.hp >= hp_max * t then
					e.health.hp = hp_max * t - 1

					break
				end
			end
		end
	end
end

--- 模拟玩家点击带 ui 的世界物件（羊/篝火/马厩/谷仓…）与特殊塔。
function autoplay:run_clicks()
	local store = self.game.simulation.store
	local ts = store.tick_ts

	if ts < self.next_click_ts then
		return
	end

	self.next_click_ts = ts + CLICK_INTERVAL

	-- 世界物件：真实点击，让 game_gui 自己置 ui.clicked 并走 select_entity / InfoBar
	for _, e in pairs(store.entities_with_ui) do
		if e.ui and e.ui.can_click and not e.pending_removal and not e.enemy and not e.hero and not e.soldier and not e.tower then
			self:simulate_click_at(e)
			stats.auto_clicks = stats.auto_clicks + 1
		end
	end

	for _, e in pairs(store.entities) do
		if e.tower and e.user_selection and e.ui and e.ui.can_click and not e.pending_removal and not e.tower.blocked and (e.tower_action or e.soldier_t) then
			-- 这类「选点雇兵」塔必须能在 tower_menus_data 里找到菜单项
			-- （tw_free_action/tw_point…），否则玩家根本触发不了
			-- user_selection.in_progress（207 谷仓塔就漏过）。
			if not e._autoplay_menu_checked then
				e._autoplay_menu_checked = true

				local tmd = require("kr1.data.tower_menus_data")
				local menus = tmd[e.tower.type]
				local list = menus and (menus[e.tower.level or 1] or menus[1])

				if not list then
					errors[#errors + 1] = "special tower menu missing/empty in tower_menus_data: " .. tostring(e.tower.type)
					print("AUTOPLAY_ERROR special tower menu missing/empty: " .. tostring(e.tower.type))
				else
					-- 复刻 game_gui TowerMenuButton:new 的取价逻辑：菜单项引用的
					-- 字段/模板缺失，玩家一点开塔菜单就会崩（207 谷仓塔的
					-- entity.repair 就是这么暴露的）。
					for _, item in pairs(list) do
						local action = item.action
						local bad

						if action == "tw_repair" then
							if not e.repair then
								bad = "needs entity.repair (cost/active)"
							end
						elseif action == "tw_buy_soldier" then
							local nt = E:get_template(item.action_arg)

							if not (nt and nt.unit and nt.unit.price) then
								bad = "bad action_arg " .. tostring(item.action_arg)
							end
						elseif action == "tw_buy_attack" then
							if not (e.attacks and e.attacks.list and e.attacks.list[item.action_arg]) then
								bad = "bad action_arg " .. tostring(item.action_arg)
							end
						elseif action == "tw_point" or action == "tw_free_action" then
							if not e.user_selection then
								bad = action .. " needs entity.user_selection"
							end
						elseif action == "tw_custom_no_close" or action == "tw_custom_close" then
							if not (e.tower_action and e.tower_action.cost) then
								bad = action .. " needs entity.tower_action (cost/active)"
							end
						elseif action == "tw_upgrade" then
							if not E:get_template(item.action_arg) then
								bad = "missing template " .. tostring(item.action_arg)
							end
						elseif action == "upgrade_power" then
							if not (e.powers and e.powers[item.action_arg]) then
								bad = "bad action_arg " .. tostring(item.action_arg)
							end
						elseif action == "tw_change_mode" then
							if not e.tower_upgrade_persistent_data then
								bad = "needs tower_upgrade_persistent_data"
							end
						end

						if bad then
							errors[#errors + 1] = "tower menu item invalid (" .. tostring(e.tower.type) .. "/" .. tostring(action) .. "): " .. bad
							print("AUTOPLAY_ERROR tower menu item invalid (" .. tostring(e.tower.type) .. "/" .. tostring(action) .. "): " .. bad)
						end
					end
				end
			end

			-- 真实点击打开塔菜单（覆盖 InfoBar/TowerMenu:show 的报错）
			self:simulate_click_at(e)
			stats.auto_clicks = stats.auto_clicks + 1

			-- 需要点一下买一次/雇兵/开火的塔（谷仓、蛛卵巢穴…）：再置 in_progress 让脚本消费
			if e.tower_action and not e.tower_action.active then
				e.user_selection.in_progress = true
				stats.auto_hires = (stats.auto_hires or 0) + 1
			end
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

		if self.auto_click then
			self:run_clicks()
		end

		self:force_boss_phases()

		simulation:update(STEP)

		-- 一帧的渲染侧更新也要跑：render / tween / particle_system 的 on_render_update
		-- 里可能有会影响 main_script 的逻辑（时间回溯的重演走的也是这条路）。
		simulation:render_update(STEP)

		-- 声音系统也要每步驱动：否则 S:queue 的播放/资源校验永远不会跑，声音问题会被漏掉
		S:update(STEP)

		if self.game.game_gui then
			self.game.game_gui:update(STEP)
		end

		-- 见 update：只等关卡真正的 game_outcome，别在中途（KR6 boss 降临前）提前收工
		if store.game_outcome then
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

		-- 像正常开局一样初始化 game_gui：time_rewind 也是直接 `game.game_gui:init(...)`。
		-- autoplay 走的是 game_init_impl，不会创建 game_gui；不补的话，凡访问
		-- game.game_gui 的 release 脚本（如 KR6 boss 阶段）都会在 headless 下崩。
		local game_gui = require("game_gui")

		game_gui:init(self.screen_w, self.screen_h, game)
		game.game_gui = game_gui
		game.store.game_gui = game_gui

		-- 冒烟测试不动胜负：把生命拉满，避免因漏怪/被推平提前结束，方便跑到结算
		game.store.lives = 99999

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
			if self.build_towers_enabled then
				self:build_towers()
			end

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

		-- 只认关卡系统真正给出的 game_outcome。KR6 boss 关会在 waves_finished 之后
		-- 才降下 boss（level:update 协程还没跑完），此时“waves_finished 且无敌人”已成立，
		-- 若照它提前结束就会漏测整个 boss 战（如 boss 升空到屏幕外 out of bounds）。
		if store.game_outcome then
			stats.victory = store.game_outcome.victory
			self.phase = "done"

			return
		end

		-- 最后一波超时兜底：进入最后一波后长时间没结算（如 boss 打不死）就算跑完
		if store.wave_group_total and store.wave_group_number >= store.wave_group_total then
			self._last_wave_ts = self._last_wave_ts or store.tick_ts

			if store.tick_ts - self._last_wave_ts > LAST_WAVE_TIMEOUT then
				stats.victory = false
				stats.reason = "last_wave_timeout"
				self.phase = "done"

				return
			end
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
