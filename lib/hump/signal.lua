-- chunkname: @./lib/hump/signal.lua
local Registry = {}

function Registry:__index(key)
	return Registry[key] or (function()
		local t = {}

		rawset(self, key, t)

		return t
	end)()
end

function Registry:register(s, f)
	self[s][f] = f

	return f
end

function Registry:emit(s, ...)
	for f in pairs(self[s]) do
		f(...)
	end
end

function Registry:remove(s, ...)
	local f = {...}

	for i = 1, select("#", ...) do
		self[s][f[i]] = nil
	end
end

function Registry:clear(...)
	local s = {...}

	for i = 1, select("#", ...) do
		self[s[i]] = {}
	end
end

function Registry:emitPattern(p, ...)
	for s in pairs(self) do
		if s:match(p) then
			self:emit(s, ...)
		end
	end
end

function Registry:registerPattern(p, f)
	for s in pairs(self) do
		if s:match(p) then
			self:register(s, f)
		end
	end

	return f
end

function Registry:removePattern(p, ...)
	for s in pairs(self) do
		if s:match(p) then
			self:remove(s, ...)
		end
	end
end

function Registry:clearPattern(p)
	for s in pairs(self) do
		if s:match(p) then
			self[s] = {}
		end
	end
end

function Registry.new()
	return setmetatable({}, Registry)
end

local default = Registry.new()
local module = {}

for k in pairs(Registry) do
	if k ~= "__index" then
		module[k] = function(...)
			return default[k](default, ...)
		end
	end
end

return setmetatable(module, {
	__call = Registry.new
})
