local HTTP_WORKER = [[
local https = require("https")
local req_ch, resp_ch = ...

while true do
	local req = req_ch:demand()
	if not req or req == "quit" then
		break
	end
	local options = {}
	for key, value in pairs(req.options or {}) do
		options[key] = value
	end
	options.progress = function(received, total)
		resp_ch:push({
			type = "progress",
			id = req.id,
			received = received,
			total = total
		})
	end
	local start_time = os.time()
	local ok, code, body, headers = pcall(https.request, req.url, options)
	local elapsed = os.time() - start_time
	if ok then
		resp_ch:push({
			type = "complete",
			id = req.id,
			code = code,
			body = body,
			headers = headers or {},
			elapsed = elapsed
		})
	else
		resp_ch:push({
			type = "complete",
			id = req.id,
			code = 0,
			body = tostring(code),
			headers = {},
			elapsed = elapsed
		})
	end
end
]]

local M = {}
local worker
local request_channel
local response_channel
local request_id = 0
local responses = {}
local progress = {}
local ignored = {}

local function clear_messages()
	responses = {}
	progress = {}
	ignored = {}
end

function M.start()
	if worker and worker:isRunning() then
		return
	end
	request_channel = love.thread.newChannel()
	response_channel = love.thread.newChannel()
	worker = love.thread.newThread(HTTP_WORKER)
	worker:start(request_channel, response_channel)
	clear_messages()
end

function M.stop()
	if not worker then
		return
	end
	request_channel:push("quit")
	worker:wait()
	worker = nil
	request_channel = nil
	response_channel = nil
	clear_messages()
end

local function read_messages(channel)
	while channel:getCount() > 0 do
		local message = channel:pop()
		if ignored[message.id] then
			if message.type == "complete" then
				ignored[message.id] = nil
				progress[message.id] = nil
			end
		elseif message.type == "progress" then
			progress[message.id] = message
		else
			responses[message.id] = message
		end
	end
end

function M.request(url, options, timeout, on_progress, on_tick, cancel_fn)
	M.start()
	request_id = request_id + 1
	local id = request_id
	local channel = request_channel
	local channel_response = response_channel
	channel:push({
		id = id,
		url = url,
		options = options
	})
	timeout = timeout or 20
	local start_time = love.timer.getTime()
	local last_tick = 0
	while true do
		local elapsed = love.timer.getTime() - start_time
		if cancel_fn and cancel_fn() then
			ignored[id] = true
			progress[id] = nil
			return nil, "cancelled"
		end
		if elapsed > timeout then
			ignored[id] = true
			progress[id] = nil
			return nil, "timeout"
		end
		if on_tick and elapsed - last_tick >= 0.5 then
			last_tick = elapsed
			on_tick(elapsed)
		end
		read_messages(channel_response)
		local current_progress = progress[id]
		if current_progress then
			progress[id] = nil
			if on_progress then
				on_progress(current_progress.received, current_progress.total)
			end
		end
		local result = responses[id]
		if result then
			responses[id] = nil
			return result
		end
		coroutine.yield()
	end
end

return M
