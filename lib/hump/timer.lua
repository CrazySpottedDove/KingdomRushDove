-- timer:tween(len 补间持续时间, subject 被补间的对象, target 目标状态, method 插值方法, after 补间结束后的回调函数, ...)
local log = require("lib.klua.log"):new("timer")
local Timer = {}

Timer.__index = Timer

local function _nothing_()
	return
end

function Timer:update(dt)
	local to_remove = {}

	-- 每次更新时，遍历所有 active 的 handle，增加它们的时间，并调用它们的 during 函数
	for handle in pairs(self.functions) do
		handle.time = handle.time + dt

		handle.during(dt, math.max(handle.limit - handle.time, 0))

		while handle.time >= handle.limit and handle.count > 0 do
			if handle.after(handle.after) == false then
				handle.count = 0

				break
			end

			handle.time = handle.time - handle.limit
			handle.count = handle.count - 1
		end

		if handle.count == 0 then
			table.insert(to_remove, handle)
		end
	end

	for i = 1, #to_remove do
		self.functions[to_remove[i]] = nil
	end
end

--- 为指定时间段内的补间创建一个 handle
---@param delay number 多少时间后完成补间
---@param during function 每帧调用的函数 function(dt)
---@param after function 补间结束后调用的函数
function Timer:during(delay, during, after)
	local handle = {
		count = 1,
		time = 0,
		during = during,
		after = after or _nothing_,
		limit = delay
	}

	self.functions[handle] = true

	return handle
end

--- func desc
---@param delay any
---@param func any
function Timer:after(delay, func)
	return self:during(delay, _nothing_, func)
end

--- func desc
---@param delay any
---@param after any
---@param count any
function Timer:every(delay, after, count)
	local count = count or math.huge
	local handle = {
		time = 0,
		during = _nothing_,
		after = after,
		limit = delay,
		count = count
	}

	self.functions[handle] = true

	return handle
end

function Timer:cancel(handle)
	self.functions[handle] = nil
end

function Timer:clear()
	self.functions = {}
end

function Timer:script(f)
	local co = coroutine.wrap(f)

	co(function(t)
		self:after(t, co)
		coroutine.yield()
	end)
end

Timer.tween = setmetatable({
	out = function(f)
		return function(s, ...)
			return 1 - f(1 - s, ...)
		end
	end,
	chain = function(f1, f2)
		return function(s, ...)
			return (s < 0.5 and f1(2 * s, ...) or 1 + f2(2 * s - 1, ...)) * 0.5
		end
	end,
	linear = function(s)
		return s
	end,
	quad = function(s)
		return s * s
	end,
	cubic = function(s)
		return s * s * s
	end,
	quart = function(s)
		return s * s * s * s
	end,
	quint = function(s)
		return s * s * s * s * s
	end,
	sine = function(s)
		return 1 - math.cos(s * math.pi * 0.5)
	end,
	expo = function(s)
		return 2 ^ (10 * (s - 1))
	end,
	circ = function(s)
		return 1 - math.sqrt(1 - s * s)
	end,
	back = function(s, bounciness)
		bounciness = bounciness or 1.70158

		return s * s * ((bounciness + 1) * s - bounciness)
	end,
	bounce = function(s)
		local a, b = 7.5625, 0.36363636363636365

		return math.min(a * s ^ 2, a * (s - 1.5 * b) ^ 2 + 0.75, a * (s - 2.25 * b) ^ 2 + 0.9375, a * (s - 2.625 * b) ^ 2 + 0.984375)
	end,
	elastic = function(s, amp, period)
		amp, period = amp and math.max(1, amp) or 1, period or 0.3

		return -amp * math.sin(2 * math.pi / period * (s - 1) - math.asin(1 / amp)) * 2 ^ (10 * (s - 1))
	end
}, {
	__call = function(tween, self, len, subject, target, method, after, ...)
		-- 收集补间信息，生成一个包含所有需要修改的字段和对应增量的列表
		local function tween_collect_payload(subject, target, out)
			-- if type(target) ~= "table" then
			-- 	log.error(target)

			-- 	return {}
			-- end

			for k, v in pairs(target) do
				-- subject: 被补间的对象
				local ref = subject[k]

				-- assert(type(v) == type(ref), "Type mismatch in field \"" .. k .. "\".")

				-- ! 补间参数不可以传入 cdata，但是被补间的对象可以是 cdata!
				if type(v) == "table" then
					tween_collect_payload(ref, v, out)
				else
					-- local ok, delta = pcall(function()
					-- return (v - ref) * 1
					-- end)

					-- assert(ok, "Field \"" .. k .. "\" does not support arithmetic operations")

					-- 输出补间信息：subject[k] 需要增加的增量为 v - ref，即从原值变成目标值需要增加的量
					out[#out + 1] = {subject, k, v - ref}
				end
			end

			return out
		end

		-- 补间方法默认为 linear
		method = tween[method or "linear"]

		local payload, t, args = tween_collect_payload(subject, target, {}), 0, {...}
		local last_s = 0

		return self:during(len, function(dt)
			t = t + dt

			local s = method(math.min(1, t / len), unpack(args))
			local ds = s - last_s

			last_s = s

			for _, info in ipairs(payload) do
				local ref, key, delta = unpack(info)

				ref[key] = ref[key] + delta * ds
			end
		end, after)
	end,
	-- 允许组合补间方法，例如 in-quad, out-quad, in-out-quad 等
	__index = function(tweens, key)
		if type(key) == "function" then
			return key
		end

		-- assert(type(key) == "string", "Method must be function or string.")

		if rawget(tweens, key) then
			return rawget(tweens, key)
		end

		local function construct(pattern, f)
			local method = rawget(tweens, key:match(pattern))

			if method then
				return f(method)
			end

			return nil
		end

		local out, chain = rawget(tweens, "out"), rawget(tweens, "chain")

		return construct("^in%-([^-]+)$", function(...)
			return ...
		end) or construct("^out%-([^-]+)$", out) or construct("^in%-out%-([^-]+)$", function(f)
			return chain(f, out(f))
		end) or construct("^out%-in%-([^-]+)$", function(f)
			return chain(out(f), f)
		end) or error("Unknown interpolation method: " .. key)
	end
})

function Timer.new()
	return setmetatable({
		functions = {},
		tween = Timer.tween
	}, Timer)
end

local default = Timer.new()
local module = {}

for k in pairs(Timer) do
	if k ~= "__index" then
		module[k] = function(...)
			return default[k](default, ...)
		end
	end
end

module.tween = setmetatable({}, {
	__index = Timer.tween,
	__newindex = function(k, v)
		Timer.tween[k] = v
	end,
	__call = function(t, ...)
		return default:tween(...)
	end
})

return setmetatable(module, {
	__call = Timer.new
})
