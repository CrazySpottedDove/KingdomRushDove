-- -test 模式的唯一入口。
-- 职责：启动命令通道、驱动 director/模拟、统一错误退出、输出结构化快照。
--
-- 时间只由命令推进：tick N / run_until ...。love.update 的 dt 不会被喂给游戏，
-- 所以同一份脚本在快机器和慢机器上走同一条路径。
local json = require("lib.json")
local signal = require("lib.hump.signal")
local commands = require("dove_modules.test.commands")
local transport = require("dove_modules.test.transport")
local harness = {}

harness.__index = harness

local function hook_log_errors(self)
	local ok, klog = pcall(require, "lib.klua.log")

	if not ok or not klog then
		return
	end

	klog.__test_harness = self

	if klog.__test_hooked then
		return
	end

	klog.__test_hooked = true

	local orig_new = klog.new

	function klog:new(name)
		local l = orig_new(self, name)
		local orig_error = l.error

		l.error = function(fmt, ...)
			local target = klog.__test_harness

			if target then
				local ok_fmt, msg = pcall(string.format, fmt or "", ...)

				target.log_errors[#target.log_errors + 1] = {
					logger = tostring(name),
					message = ok_fmt and msg or tostring(fmt)
				}
			end

			return orig_error(fmt, ...)
		end

		return l
	end
end

function harness:init(params)
	self.params = params or {}
	self.failed = false
	self.quitting = false
	self.exit_code = 0
	self.render = false
	self.log_errors = {}
	self.game_started = false
	self.autoplay = nil
	self.start_time = love.timer.getTime()

	hook_log_errors(self)

	self.director = require("director")

	-- plugin_main:init 内部会 director:init(main.params)。
	-- -test 下不自动加载插件：autoplay 用 plugins_load_all，插件验收用 plugin_load。
	local plugin_main = require("plugin.plugin_main")

	plugin_main:init(self.director, false)

	self.plugin_main = plugin_main

	signal.register("game-start", function()
		self.game_started = true
	end)

	self.transport = transport.new(self)

	self.transport:send({
		type = "event",
		event = "ready",
		data = {
			test = true,
			source = self.transport.source,
			width = self.params.width,
			height = self.params.height,
			fps = DRAW_FPS,
			tick_length = TICK_LENGTH
		}
	})

	return self
end

function harness:get_game()
	local item = self.director and self.director.active_item

	if item and item.item_name == "game" then
		return item
	end

	return nil
end

function harness:count_entities(filter)
	local game = self:get_game()

	if not game or not game.store then
		return 0
	end

	local n = 0

	for _, e in pairs(game.store.entities or {}) do
		if not e.pending_removal and (not filter or filter(e)) then
			n = n + 1
		end
	end

	return n
end

function harness:snapshot()
	local item = self.director and self.director.active_item
	local snap = {
		scene = item and item.item_name or nil,
		progress = item and item.progress or nil,
		render = self.render,
		failed = self.failed,
		game_started = self.game_started,
		log_errors = #self.log_errors
	}
	local game = self:get_game()

	if game and game.store then
		local s = game.store

		snap.game = {
			gen_id = s.gen_id,
			level_idx = s.level_idx,
			mode = s.level_mode,
			difficulty = s.level_difficulty,
			tick_ts = s.tick_ts,
			dt = s.dt,
			lives = s.lives,
			gold = s.player_gold,
			wave = s.wave_group_number,
			wave_total = s.wave_group_total,
			waves_finished = s.waves_finished,
			next_wave_ready = s.next_wave_group_ready and true or false,
			paused = s.paused,
			enemies = self:count_entities(function(e)
				return e.enemy ~= nil
			end),
			towers = self:count_entities(function(e)
				return e.tower ~= nil and e.tower.type ~= "holder"
			end),
			outcome = s.game_outcome and {
				victory = s.game_outcome.victory
			} or nil
		}
	end

	if self.autoplay then
		snap.autoplay = self.autoplay.stats
	end

	return snap
end

function harness:step_once()
	if not self.director then
		return
	end

	-- 场景切换/加载一律走 director；游戏内则走精简的模拟推进，
	-- 避免 adaptive_fps 把固定 tick 改写。
	if self.director.next_item_name or self.director.queued_item or self.director.queue_unload_item then
		self.director:update(TICK_LENGTH)

		return
	end

	local game = self:get_game()

	if game then
		require("dove_modules.test.handlers.autoplay").step_game(self)
	else
		self.director:update(TICK_LENGTH)
	end
end

function harness:tick(n)
	n = tonumber(n) or 1

	for _ = 1, n do
		self:step_once()
	end

	return self:snapshot()
end

function harness:respond(id, ok, payload)
	local msg = {
		type = "response",
		id = id,
		ok = ok
	}

	if ok then
		msg.result = payload
	else
		msg.error = payload
	end

	self.transport:send(msg)
end

function harness:quit(code)
	code = tonumber(code) or 0

	if self.failed and code == 0 then
		code = 1
	end

	self.quitting = true
	self.exit_code = code

	love.event.quit(code)
end

function harness:finish()
	if self.quitting then
		return
	end

	self.transport:send({
		type = "event",
		event = "exit",
		data = {
			failed = self.failed,
			log_errors = #self.log_errors,
			elapsed = love.timer.getTime() - self.start_time
		}
	})
	self:quit(self.failed and 1 or 0)
end

function harness:handle_line(line)
	local ok, cmd = pcall(json.decode, line)

	if not ok or type(cmd) ~= "table" then
		self:respond(nil, false, "invalid json: " .. tostring(cmd))

		self.failed = true

		return
	end

	local id = cmd.id
	local name = cmd.cmd or cmd.command
	local fn = commands.map[name]

	if not fn then
		self:respond(id, false, "unknown command: " .. tostring(name))

		self.failed = true

		return
	end

	local args = type(cmd.args) == "table" and cmd.args or cmd
	local ok_run, result = xpcall(function()
		return fn(self, args, cmd)
	end, debug.traceback)

	if not ok_run then
		self:respond(id, false, tostring(result))

		self.failed = true

		self:quit(1)

		return
	end

	self:respond(id, true, result)
end

function harness:update()
	local line

	while true do
		line = self.transport:pop()

		if not line then
			break
		end

		line = line:match("^%s*(.-)%s*$")

		if line ~= "" and line:sub(1, 2) ~= "--" then
			self:handle_line(line)
		end

		if self.quitting then
			return false
		end
	end

	if self.transport.eof and not self.quitting then
		self:finish()
	end

	return false
end

function harness:draw()
	if self.render and self.director then
		self.director:draw()
	end
end

-- 真实窗口输入：-test 下也转发，方便边看边调。
local function forward(name)
	return function(self, ...)
		local item = self.director and self.director.active_item

		if item and item[name] then
			return item[name](item, ...)
		end
	end
end

harness.keypressed = forward("keypressed")
harness.keyreleased = forward("keyreleased")
harness.textinput = forward("textinput")
harness.mousepressed = forward("mousepressed")
harness.mousereleased = forward("mousereleased")
harness.wheelmoved = forward("wheelmoved")
harness.touchpressed = forward("touchpressed")
harness.touchreleased = forward("touchreleased")
harness.touchmoved = forward("touchmoved")

function harness:resize(w, h)
	self.params.width, self.params.height = w, h

	if self.director and self.director.active_item and self.director.active_item.resize then
		self.director.active_item:resize(w, h)
	end
end

function harness:focus()
end

return harness
