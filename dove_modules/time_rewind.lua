-- chunkname: @./dove_modules/time_rewind.lua
-- 时间回溯：记录玩家的每一次操作（连同发生时的游戏时钟），回溯时重建关卡，
-- 再按标称帧率重演到目标游戏时间。
--
-- 数据布局（热路径一律数组 + 数字下标）：
--   events[i] = 一次玩家操作，按发生时间递增（同一时间点的先后就是记录顺序）：
--     [1]     发生时的游戏时钟 store.tick_ts
--     [2]     操作种类，见 IN_* 常量；数字下标可直接索引 replay_fns 取到 game 方法
--     [3..8]  原样透传给 game 方法的参数
--             按键 key,isrepeat / 鼠标 x,y,button,istouch / 触摸 id,x,y,dx,dy,pressure
--     [9..11] 发生时的相机 x,y,zoom —— 命令里的世界坐标依赖相机，必须跟着操作记
--   waves[i] = {游戏时钟, 波数}，面板横轴上的波次刻度
require("all.constants")

local log = require("lib.klua.log"):new("time_rewind")
local km = require("lib.klua.macros")
local configer = require("dove_modules.configer")
local simulation = require("simulation")
local S = require("sound_db")
local AC = require("achievements")
local adaptive_fps = require("dove_modules.perf.adaptive_fps")
local perf = require("dove_modules.perf.perf")
local hook_utils = require("hook_utils")
local PS = require("all.systems.particle_system")
local render = require("all.systems.render")
local tween = require("all.systems.tween")

local time_rewind = {}

--- 每个真实帧用于重演的时间预算（秒）。摊到多个真实帧上，回溯才有进度可看，
--- 也不会因为一次重放整个关卡而卡死。注意它只影响每帧分摊，不影响总耗时。
local BUDGET = 1 / 30

local STATE_IDLE, STATE_REBUILD, STATE_REPLAY = 1, 2, 3

-- 进度画面的阶段编号（给 UI 用，文案由 UI 自己按编号取 i18n 键）
local PHASE_REBUILD, PHASE_REPLAY = 1, 2

-- 事件数组的下标：时间、种类、6 个透传参数、3 个相机分量
local E_TIME, E_KIND, E_A, E_B, E_C, E_D, E_E, E_F, E_CAMX, E_CAMY, E_CAMZ = 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11

-- 操作种类：数字本身就是 replay_fns 的下标
local IN_MOUSE_DOWN, IN_MOUSE_UP, IN_KEY, IN_TOUCH_DOWN, IN_TOUCH_UP, IN_TOUCH_MOVE = 1, 2, 3, 4, 5, 6

-- 导出给 game.lua 的记录调用点，那边一次性取进局部变量，热路径上不再查字符串
time_rewind.IN_MOUSE_DOWN, time_rewind.IN_MOUSE_UP, time_rewind.IN_KEY = IN_MOUSE_DOWN, IN_MOUSE_UP, IN_KEY
time_rewind.IN_TOUCH_DOWN, time_rewind.IN_TOUCH_UP, time_rewind.IN_TOUCH_MOVE = IN_TOUCH_DOWN, IN_TOUCH_UP, IN_TOUCH_MOVE

-- 给 game.lua 判断“现在是不是在回溯”用（非 IDLE 时世界不接受输入）
time_rewind.STATE_IDLE = STATE_IDLE

-- 与回溯面板同层、且排在面板之后的界面：打开面板时要把它们收起来，否则会盖在面板上
local PANELS_UNDER_PANEL = {"pauseview", "victoryview", "defeatview"}

-- 种类 -> game 方法名，按种类编号排列；进入重演时解析成函数数组并缓存
local REPLAY_METHOD = {"mousepressed", "mousereleased", "keypressed", "touchpressed", "touchreleased", "touchmoved"}

-- 热路径状态放局部变量；面板要读的值在打开面板时镜像到 time_rewind 字段上。
local events = {}
local n_events = 0
local cursor = 1
-- 已记过刻度的波次。初值取 0：第 0 波只是关卡开场（wave_spawn 的初始值就是 0），它的时间就是 0，
-- 轴上不需要这个刻度，所以从"第 0 波已经记过"开始
local last_wave = 0
-- 上一帧记到哪个事件。用来撤掉「让游戏暂停的那一下」：它是界面操作，进了时间线就会在重演时
-- 把游戏暂停住，而重演一停 tick_ts 就不再前进，进度条永远走不完
local events_at_last_record = 0
-- 重演期间记下的最后一次音乐请求：它代表「回溯到的那一刻本该在放的曲子」
local pending_music
local replay_fns
-- true 表示当前这次 mousepressed/keypressed 是重演自己派发的：要放行，也不要记回日志。
-- 玩家在回溯期间的操作与重演派发的操作走的是同一条路（game:mousepressed 等），只能这样区分。
local replaying = false
-- 重演步长与帧率：固定用引擎标称帧率，每次 start 时从 TICK_LENGTH 取值
-- （设置里改帧率会重算这个全局）。放局部变量是因为重演热路径每步都要读它们。
local fps
local tick

time_rewind.waves = {}
time_rewind.now_time = 0
time_rewind.target_time = 0
time_rewind.progress = 0
time_rewind.phase = 0
time_rewind.state = STATE_IDLE
time_rewind.panel_open = false

-- 重演期间成就信号会再次触发，跨局计数器必须成对备份/还原
local function snapshot_achievements()
	local snap = {
		ach = {},
		counters = {}
	}

	for k, v in pairs(AC.ach) do
		snap.ach[k] = v
	end

	for period, counter in pairs(AC.counters) do
		local ids = {}

		for k, v in pairs(counter) do
			ids[k] = v
		end

		snap.counters[period] = ids
	end

	return snap
end

local function restore_achievements(snap)
	for period, counter in pairs(AC.counters) do
		local ids = snap.counters[period]

		for k in pairs(counter) do
			counter[k] = nil
		end

		if ids then
			for k, v in pairs(ids) do
				counter[k] = v
			end
		end
	end

	for k in pairs(AC.ach) do
		AC.ach[k] = nil
	end

	for k, v in pairs(snap.ach) do
		AC.ach[k] = v
	end
end

local function noop()
end

--- 派发所有发生时间不晚于 ts 的操作（记录顺序即发生顺序，同一帧的多个事件同时间戳也照顺序走）。
--- 抽出来是因为重演收尾还要再派发一次：最后那一 tick 里到期的操作若不派发，会被 finish 当成
--- 「回溯点之后」直接丢掉（同一帧多个事件、以及拖到最右端时当前帧的操作都会踩到）。
local function dispatch_events(game, ts)
	while cursor <= n_events do
		local e = events[cursor]

		if e[E_TIME] > ts then
			break
		end

		local camera = game.camera

		camera.x, camera.y, camera.zoom = e[E_CAMX], e[E_CAMY], e[E_CAMZ]
		-- 6 个参数格全传（多余的是 nil，Lua 调用方自行忽略）
		replay_fns[e[E_KIND]](game, e[E_A], e[E_B], e[E_C], e[E_D], e[E_E], e[E_F])

		cursor = cursor + 1
	end
end

--- 回溯期间顶替 game.update 的原函数：正常帧主体让位给重演驱动。
--- 换的是钩子链尾，插件挂在 game.update 上的 handler 照常执行、也没有额外转发层。
local function rewind_update(game, dt)
	if time_rewind.state == STATE_REBUILD then
		local ok, err = coroutine.resume(time_rewind.rebuild_co)

		if not ok then
			log.error("time rewind: rebuild failed: %s", tostring(err))
			time_rewind:finish(game)

			return true
		end

		time_rewind.progress = game.progress

		if coroutine.status(time_rewind.rebuild_co) == "dead" then
			time_rewind.rebuild_co = nil
			time_rewind.state = STATE_REPLAY
			time_rewind.phase = PHASE_REPLAY
			time_rewind.progress = 0

			-- 解析派发函数（数字索引），重演时每个事件只做一次数组查表，不再查字符串
			local fns = {}

			for i = 1, #REPLAY_METHOD do
				fns[i] = game[REPLAY_METHOD[i]]
			end

			replay_fns = fns
		end

		return true
	end

	local store = game.simulation.store
	local deadline = love.timer.getTime() + BUDGET

	repeat
		time_rewind:replay_step(game)

		time_rewind.progress = time_rewind.target_time > 0 and store.tick_ts / time_rewind.target_time or 1
	until store.tick_ts >= time_rewind.target_time or love.timer.getTime() >= deadline

	if store.tick_ts >= time_rewind.target_time then
		-- 收尾再派发一次：用落点（而不是进入这一帧时）的游戏时钟，把最后一 tick 里到期的操作补上
		replaying = true

		dispatch_events(game, store.tick_ts)

		replaying = false

		time_rewind:finish(game)
	end

	return true
end

--- 回溯期间顶替 game.draw_game 的原函数：只画进度画面，半成品/快速重演中的世界不参与绘制。
--- 同样只换链尾，插件叠加绘制的 handler 照常执行。
local function rewind_draw(game)
	game.game_gui.time_rewind_view:draw_progress()
end

local function rewind_particle_update(system, dt, ts, store)
	for _, e in pairs(store.particle_systems) do
		local ps = e.particle_system

		if ps.track_id then
			local target = store.entities[ps.track_id]

			if target then
				ps.last_pos.x, ps.last_pos.y = e.pos.x, e.pos.y
				e.pos.x, e.pos.y = target.pos.x, target.pos.y

				if ps.track_offset then
					e.pos.x, e.pos.y = e.pos.x + ps.track_offset.x, e.pos.y + ps.track_offset.y
				end
			else
				ps.emit = false
				ps.source_lifetime = 0
			end
		end

		if ps.emit_duration and ps.emit then
			if not ps.emit_duration_ts then
				ps.emit_duration_ts = ts
			end

			if ts - ps.emit_duration_ts > ps.emit_duration then
				ps.emit = false
			end
		end

		if ps.emit then
			ps.emit_ts = ts
		else
			ps.emit_ts = ts + ps.ts_offset
		end

		if ps.source_lifetime and ts - ps.ts > ps.source_lifetime then
			ps.emit = false

			if ps.particle_count == 0 then
				simulation:queue_remove_entity(e)
			end
		end
	end
end

local EXO = require("all.exoskeleton")
local ffi = require("ffi")
local A = require("animation_db")
local I = require("lib.klove.image_db")
local table_clear = require("table.clear")

local function rewind_render_update(self, dt, ts, store)
	if store.render_frames_count > store.render_frames_ffi_cap then
		store.render_frames_ffi_cap = store.render_frames_ffi_cap * 2
		store.render_frames_ffi = ffi.new("RenderFrameFFI[" .. store.render_frames_ffi_cap .. "]")
		store.render_frames_ffi_tmp = ffi.new("RenderFrameFFI[" .. store.render_frames_ffi_cap .. "]")
	end

	local render_frames = store.render_frames
	local new_frames = store.render_frames_swapper
	-- 必须保留该行！怀疑对象的写入更替引发了一些 GC 问题，导致性能暴跌。在清理后可以恢复正常
	table_clear(new_frames)

	local n = 0
	local start_idx = 1

	for i = 1, store.render_frames_count do
		local s = render_frames[i]

		if not s.marked_to_remove then
			if s._render_e_id then
				if s.ts > ts then
					s.hidden = true
					s._hidden_for_ts = true
				elseif s._hidden_for_ts then
					s.hidden = false
					s._hidden_for_ts = false
				end

				do
					local fn
					local last_runs = s.runs

					if s.animated then
						fn, s.runs, s.frame_idx = A:fn(s.prefix and (s.prefix .. "_" .. s.name) or s.name, ts - s.ts + s.time_offset, s.loop, s.fps)
					else
						s.runs = 0
						s.frame_idx = 1
						fn = s.name
					end

					if s.exo then
						local exo_frame = EXO:f(fn)

						if exo_frame then
							s.exo_frame = exo_frame
							local exo = EXO:get_exo_by_frame(exo_frame)

							if s.exo_hide_prefix then
								for i = 1, #exo_frame do
									local p = exo_frame[i]
									if p[1] == 1 then
										local pname = exo.parts[p[2]][1]

										p.hidden = false

										for j = 1, #s.exo_hide_prefix do
											if string.find(pname, s.exo_hide_prefix[j], 1, true) then
												p.hidden = true

												break
											end
										end
									end
								end
							end
						else
							s.exo_frame = {}
						end
					else
						s.sync_flag = last_runs ~= s.runs
						s.ss = I:s(fn)
					end
				end

				if s.hide_after_runs and s.runs >= s.hide_after_runs then
					s.hidden = true
				end

				local e = store.entities[s._render_e_id]

				if s._track_e then
					s.pos.x, s.pos.y = e.pos.x, e.pos.y
				end
			end

			n = n + 1
			new_frames[n] = s
		end
	end

	store.render_frames = new_frames
	store.render_frames_swapper = render_frames
	store.render_frames_count = n + start_idx - 1
	store.render_frames_start_idx = start_idx
end

local function rewind_tween_update(self, dt, ts, store)
	local entities = store.entities_with_tween

	for _, e in pairs(entities) do
		if not e.tween.disabled then
			local finished = true
			local sprites = e.render.sprites
			local tween = e.tween

			for i = 1, #tween.props do
				local tween_prop = tween.props[i]
				if not tween_prop.disabled then
					local s = sprites[tween_prop.sprite_id]
					local keys = tween_prop.keys
					local start_time = keys[1][1]
					local end_time = keys[#keys][1]
					local duration = end_time - start_time
					local time = ts - (tween_prop.ts or tween.ts or s.ts)

					if tween_prop.time_offset then
						time = time + tween_prop.time_offset
					end

					if tween_prop.loop then
						time = time % duration
					end

					if tween.reverse and not tween_prop.ignore_reverse then
						time = duration - time
						if time > start_time then
							finished = finished and tween_prop.loop
						end
					else
						if time < end_time then
							finished = finished and tween_prop.loop
						end
					end
				end
			end

			if finished then
				if tween.remove then
					simulation:queue_remove_entity(e)
				end

				if tween.run_once then
					tween.disabled = true
				end
			end
		end
	end
end

--- 关卡开始：忘掉上一条时间线。重演按引擎标称帧率推进，所以不需要记录每帧节奏。
function time_rewind:reset()
	events = {}
	n_events = 0
	cursor = 1
	last_wave = 0
	events_at_last_record = 0
	replay_fns = nil
	self.waves = {}
	self.now_time = 0
end

--- 临时顶掉一批函数定义/字段，形如 {{对象, 键, 新值}, ...}。回溯与面板期间正常路径上
--- 就不必再判断状态：进入时换一次，退出时换回来，代价只在两次切换上。
function time_rewind:swap_defs(defs)
	local saved = {}

	for i = 1, #defs do
		local d = defs[i]

		saved[i] = hook_utils.SET_ORIGINAL(d[1], d[2], d[3])
	end

	self.swap_list = defs
	self.swapped = saved
end

function time_rewind:restore_defs()
	local defs = self.swap_list
	local saved = self.swapped

	for i = 1, #defs do
		hook_utils.SET_ORIGINAL(defs[i][1], defs[i][2], saved[i])
	end

	self.swap_list = nil
	self.swapped = nil
end

--- 记录一次玩家操作：参数按位置写进定长数组，第 1 格是发生时的游戏时钟。
--- 返回 true 表示这次输入到此为止：回溯期间世界不接受玩家的输入，否则重演中一个误触就会
--- 改掉刚重建好的关卡或帧率。面板打开期间本函数已被顶成 noop，输入照常往下走。
--- 重演派发进来的操作（replaying）只是借道，既不记录也不拦。
function time_rewind:input(kind, store, camera, a, b, c, d, e, f)
	if replaying then
		return
	end

	if self.state ~= STATE_IDLE then
		return true
	end

	-- 暂停中（暂停菜单 / 胜利 / 失败界面）的点击是界面操作，不是战斗操作：
	-- 记下来只会让它在回溯时被派发到刚重建好的战斗界面上，撞出别的动作
	if store.paused then
		return
	end

	n_events = n_events + 1
	events[n_events] = {
		store.tick_ts,
		kind,
		a,
		b,
		c,
		d,
		e,
		f,
		camera.x,
		camera.y,
		camera.zoom
	}
end

--- 每帧只做一件事：波次变化时插一条刻度。逐帧数据一条不留。
--- 回溯期间 game.update 链尾已被换掉；面板打开期间本函数被顶成 noop。
function time_rewind:record(game, store)
	if game.progress < 1 then
		return
	end

	-- 这一帧刚被暂停（点暂停按钮 / 按 Esc）：把本帧记下的操作撤掉。暂停是那一操作的后果，
	-- 所以记它的时候 paused 还是 false，只能等到这里才发现，于是按「本帧」撤
	if store.paused then
		for i = events_at_last_record + 1, n_events do
			events[i] = nil
		end

		n_events = events_at_last_record
	end

	events_at_last_record = n_events

	local wave = store.wave_group_number

	if wave ~= last_wave then
		last_wave = wave
		self.waves[#self.waves + 1] = {store.tick_ts, wave}
	end
end

--- 处理回溯面板的热键；返回 true 表示这一下按键已经被吞掉
function time_rewind:keypressed(game, key, isrepeat)
	-- 重演派发进来的按键走正常逻辑；玩家在回溯期间的按键则全部吞掉
	-- （否则重演期间一个 t 就会把面板盖在进度画面上）
	if replaying then
		return false
	end

	if self.state ~= STATE_IDLE then
		return true
	end

	local toggle_key = configer.keyset().time_rewind_toggle

	if isrepeat then
		return false
	end

	if self.panel_open then
		if key == KEYPRESS_ESCAPE or key == toggle_key then
			self:close(game.game_gui)
		end

		return true
	end

	if key == toggle_key then
		self:toggle(game.game_gui)

		return true
	end

	return false
end

function time_rewind:toggle(game_gui)
	if self.panel_open then
		self:close(game_gui)

		return
	end

	local game = game_gui.game
	local now_time = game.simulation.store.tick_ts

	if now_time <= 0 then
		return
	end

	local view = game_gui.time_rewind_view

	self.panel_open = true
	-- 面板打开期间记录入口被顶成 noop，时间线不再增长，这里镜像一次当前时间给面板读
	self.now_time = now_time
	-- 进来时是不是暂停的（暂停菜单 / 胜利 / 失败界面）要记住，关闭时原样还回去
	self.paused_before_panel = game.store.paused
	game.store.paused = true

	-- 面板上的操作不属于时间线，直接顶掉两个记录入口
	self:swap_defs({{self, "record", noop}, {self, "input", noop}})

	-- 暂停菜单与胜利/失败界面和面板同一层、还排在面板后面，会把面板盖住；
	-- 这里先收起来，关闭时放回去（它们的状态不能靠重建复原，重建等于直接跳过它们）
	local panels = {}

	for i = 1, #PANELS_UNDER_PANEL do
		local panel = game_gui[PANELS_UNDER_PANEL[i]]

		if panel and not panel.hidden then
			panel.hidden = true
			panels[#panels + 1] = panel
		end
	end

	self.hidden_panels = panels

	view:order_to_front()

	view.target_time = now_time
	view.dragging = false
	view:show()
end

function time_rewind:close(game_gui, keep_hidden)
	local view = game_gui.time_rewind_view

	view:hide()
	-- 关闭时作废进行中的拖动，否则淡出期间松手会再触发一次 start
	view.dragging = false

	-- 放回被面板收起来的暂停菜单 / 结算界面。但要开始回溯时不能放：重建会把它们整个换掉，
	-- 旧对象的 hidden 若停在「可见」，Esc 的分支就会照它直接回大地图（面板其实早就不在了）
	local panels = self.hidden_panels

	if not keep_hidden then
		for i = 1, #panels do
			panels[i].hidden = false
		end
	end

	self.hidden_panels = nil

	self:restore_defs()

	self.panel_open = false
	-- 进来时是暂停的（暂停菜单/结算界面）就照样回到暂停，否则恢复游戏
	game_gui.game.store.paused = self.paused_before_panel
	self.paused_before_panel = nil
end

-- 保留音乐
local function rewind_sound_queue(sound_db, id, options)
	local sd = id and sound_db.sounds[id]

	if sd and sd.source_group == "MUSIC" then
		pending_music = {
			id = id,
			options = options
		}
	end
end

function time_rewind:start(game, target_time)
	local store = game.simulation.store

	-- 轴最右端就是当前时刻，也允许选：那等于把录下的操作从头重演一遍（重演一遍的随机流
	-- 与原来不同，往往正好用来重开一次结果）。所以这里只做钳制，不拦「到当前时刻」。
	target_time = km.clamp(0, store.tick_ts, target_time)

	self:close(game.game_gui, true)

	-- close 会把暂停菜单放回来；重建会把它整个换掉，所以要先让它按自己的流程收尾
	-- （PauseView:hide 会恢复音频、关掉遮罩并写回音量），否则声音会一直停着
	local pauseview = game.game_gui.pauseview

	if pauseview and not pauseview.hidden then
		pauseview:hide()
	end

	-- 重演步有意粗于模拟 tick：1/30 s ≈ 4.8 个 tick。一步跑 4~5 个 tick，但 GUI/渲染每秒只更新 30 次，
	-- 拿落点精度换重演速度：落点最多越过一个重演步，重演期间派发的操作最多滞后一步（收尾按落点补派发）。
	-- 模拟本身仍走标称 tick（simulation:init 把 store.tick_length 填回 TICK_LENGTH），结束时全部还原。
	fps = 30
	tick = 1 / fps

	self.target_time = target_time
	self.progress = 0
	self.phase = PHASE_REBUILD
	self.state = STATE_REBUILD
	self.ach_snapshot = snapshot_achievements()
	cursor = 1
	pending_music = nil

	perf.set_enabled(false)

	local defs = {
		{game, "update", rewind_update},
		{game, "draw_game", rewind_draw},
		{S, "queue", rewind_sound_queue},
		-- 声音的「停」也一律拦下：重演不该动正在放的声音，否则那对 stop+queue 里的 stop 会先生效
		{S, "stop_group", noop},
		{S, "stop", noop},
		{S, "stop_all", noop},
		{AC, "save", noop},
		{adaptive_fps, "fps", fps},
		{adaptive_fps, "tick_length", tick},
		{adaptive_fps.scene, "limit_fps", fps},
		{PS, "on_render_update", rewind_particle_update},
		{render, "on_render_update", rewind_render_update},
		{game.game_gui, "change_speed_factor", noop},
		{tween, "on_render_update", rewind_tween_update},
		{perf, "set_enabled", noop}
	}

	self:swap_defs(defs)

	store.paused = false

	self.rebuild_co = coroutine.create(function()
		store.restarted = true
		store.ephemeral = {}

		simulation:init(store, game.simulation_systems)

		-- 关卡加载协程会停在 0.8，这里补回“关卡已就绪”
		game.progress = 1

		game.game_gui:init(game.screen_w, game.screen_h, game)
	end)
end

--- 重演一个标称帧：推进时钟 → 派发到时间的操作 → 跑一次 tick 与 GUI 更新。
function time_rewind:replay_step(game)
	local store = game.simulation.store
	local dt = tick

	store.dt = dt * store.speed_factor
	store.ts = store.ts + store.dt
	store.to = store.to + store.dt
	store.to_gui = store.to_gui + dt

	replaying = true

	dispatch_events(game, store.tick_ts)

	replaying = false

	-- 重演是自己在推时间，不能被暂停卡住：录下的暂停操作已在 record 里剔掉，
	-- 这里再兜一道底（脚本或插件也可能置 paused），否则 tick_ts 不再前进，进度条永远走不完
	store.paused = false

	while store.to > store.tick_length do
		store.to = store.to - store.tick_length
		simulation:update(store.tick_length)
		store.step = false
	end

	while store.to_gui > adaptive_fps.tick_length do
		store.to_gui = store.to_gui - adaptive_fps.tick_length
		simulation:render_update(adaptive_fps.tick_length)
		game.game_gui:update(adaptive_fps.tick_length)
		store.step = false
	end
end

function time_rewind:finish(game)
	-- 丢弃回溯点之后的记录：派发游标指向下一个未派发的事件，之后的全丢；
	-- 波次刻度按时间截断
	for i = cursor, n_events do
		events[i] = nil
	end

	n_events = cursor - 1

	local waves = self.waves

	for i = #waves, 1, -1 do
		if waves[i][1] > self.target_time then
			table.remove(waves, i)
		end
	end

	local store = game.simulation.store

	last_wave = store.wave_group_number
	replay_fns = nil

	-- 回溯结束一律回到「进行中」：重演期间若真被谁按下了暂停，不能留到回溯之后
	local pauseview = game.game_gui.pauseview

	if pauseview and not pauseview.hidden then
		pauseview:hide()
	end

	store.paused = false

	restore_achievements(self.ach_snapshot)
	self.ach_snapshot = nil
	self.state = STATE_IDLE
	self.progress = 0
	self:restore_defs()

	perf.set_enabled(configer.ui_settings().perf_enabled)

	-- 补放重演期间记下的音乐：它就是回溯到的那一刻本该在放的那首
	if pending_music then
		S:stop_group("MUSIC")
		S:queue(pending_music.id, pending_music.options)

		pending_music = nil
	end

	game.game_gui:change_speed_factor(1)
end

return time_rewind
