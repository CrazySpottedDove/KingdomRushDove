local Pool = {}

Pool.__index = Pool

function Pool:new(create_fn, reset_fn, initial_size)
	local o = {
		pool = {},
		create_fn = create_fn,
		reset_fn = reset_fn
	}

	if initial_size then
		for i = 1, initial_size do
			o.pool[i] = create_fn()
		end
	end

	setmetatable(o, self)

	return o
end

function Pool:get(...)
	if #self.pool > 0 then
		local obj = self.pool[#self.pool]

		self.reset_fn(obj, ...)

		self.pool[#self.pool] = nil

		return obj
	else
		return self.create_fn(...)
	end
end

function Pool:release(obj)
	self.pool[#self.pool + 1] = obj
end

return Pool
