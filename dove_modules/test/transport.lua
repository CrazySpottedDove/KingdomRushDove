-- 测试命令通道：
--   * -test <script.jsonl>：按行读脚本
--   * -test：用后台线程读 stdin，避免 io.read 阻塞主循环
-- 响应统一写 stdout，并加 @TEST 前缀，和游戏日志隔开。
local json = require("lib.json")
local transport = {}
local STDIN_READER = [[
local channel = ...
while true do
	local line = io.stdin and io.stdin:read("*l")
	if not line then
		channel:push("\0EOF")
		break
	end
	channel:push(line)
end
]]

function transport.new(harness)
	local self = {
		harness = harness,
		queue = {},
		eof = false
	}
	local src = harness.params.test

	if type(src) == "string" and src ~= "" then
		local f, err = io.open(src, "r")

		if not f and src:sub(1, 1) ~= "/" then
			local base = love.filesystem.getSourceBaseDirectory()

			f, err = io.open(base .. "/" .. src, "r")
		end

		if not f then
			error(string.format("cannot open test script %s: %s", src, tostring(err)))
		end

		for line in f:lines() do
			self.queue[#self.queue + 1] = line
		end

		f:close()

		self.eof = true
		self.source = src
	else
		if not love.thread or not love.thread.newThread then
			error("stdin test channel requires love.thread")
		end

		self.channel = love.thread.newChannel()
		self.thread = love.thread.newThread(STDIN_READER)

		self.thread:start(self.channel)

		self.source = "stdin"
	end

	return setmetatable(self, {
		__index = transport
	})
end

function transport:send(payload)
	io.stdout:write("@TEST ", json.encode(payload), "\n")
	io.stdout:flush()
end

function transport:pop()
	if #self.queue > 0 then
		return table.remove(self.queue, 1)
	end

	if not self.channel then
		return nil
	end

	local line = self.channel:pop()

	if line == nil then
		return nil
	end

	if line == "\0EOF" then
		self.eof = true

		return nil
	end

	return line
end

return transport
