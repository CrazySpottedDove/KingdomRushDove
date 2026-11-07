-- 通用声明式注册表：统一 name 主键、注册/查找/排序/懒加载/资源聚合。
local Registry = {}
Registry.__index = Registry

--- 创建注册表。
---@param config table {module_names=table[], sort_fn=function|nil, lazy=boolean, on_register=function|nil, on_unregister=function|nil}
---@return table
function Registry.new(config)
	return setmetatable({
		items = {},
		by_id = {},
		module_names = config.module_names or {},
		sort_fn = config.sort_fn,
		lazy = config.lazy or false,
		inited = false,
		on_register = config.on_register,
		on_unregister = config.on_unregister
	}, Registry)
end

local function merge_resources(out, resources)
	for key, value in pairs(resources) do
		if type(value) == "table" then
			local dst = out[key]

			if type(dst) ~= "table" then
				dst = {}
				out[key] = dst
			end

			if #value > 0 then
				for _, item in ipairs(value) do
					dst[#dst + 1] = item
				end
			else
				for k, v in pairs(value) do
					dst[k] = v
				end
			end
		else
			out[key] = value
		end
	end
end

function Registry:add(module)
	local name = module.name
	local existing = self.by_id[name]

	if existing then
		for i, item in ipairs(self.items) do
			if item == existing then
				self.items[i] = module

				break
			end
		end
	else
		self.items[#self.items + 1] = module
	end

	self.by_id[name] = module

	if self.on_register then
		self.on_register(module)
	end
end

--- 加载 module_names 中的本体模块。幂等；lazy=true 时不提前 require。
function Registry:init()
	if self.inited then
		return
	end

	self.inited = true

	if self.lazy then
		return
	end

	for _, path in ipairs(self.module_names) do
		self:add(require(path))
	end
end

--- 注册一个模块。插件在初始化时调用。
---@param module table
---@return table
function Registry:register(module)
	self:add(module)

	return module
end

--- 卸载一个模块。已创建实例不回收。
---@param name string
function Registry:unregister(name)
	local module = self.by_id[name]

	if not module then
		return
	end

	self.by_id[name] = nil

	for i, item in ipairs(self.items) do
		if item == module then
			table.remove(self.items, i)

			break
		end
	end

	if self.on_unregister then
		self.on_unregister(module)
	end
end

---@param name string
---@return table|nil
---@return string|nil
function Registry:get(name)
	local module = self.by_id[name]

	if module then
		return module
	end

	if not self.lazy then
		return nil
	end

	for _, path in ipairs(self.module_names) do
		if path:match("([^%.]+)$") == name then
			local ok, loaded = pcall(require, path)

			if not ok then
				return nil, loaded
			end

			self:add(loaded)

			return loaded
		end
	end

	return nil
end

--- 返回所有模块副本。提供 sort_fn 时排序，否则保持原顺序。
---@return table[]
function Registry:all()
	local list = {}

	for _, module in ipairs(self.items) do
		list[#list + 1] = module
	end

	if self.sort_fn then
		table.sort(list, self.sort_fn)
	end

	return list
end

--- 按 scene 聚合资源声明。资源结构与 scene 自身的 required_* 字段一致。
---@param scene_name string
---@return table
function Registry:resources(scene_name)
	local out = {}

	for _, module in ipairs(self.items) do
		local resources = module.resources and module.resources[scene_name]

		if resources then
			merge_resources(out, resources)
		end
	end

	return out
end

--- 注册表当前模块数。
---@return number
function Registry:size()
	return #self.items
end

--- 清空注册表。
function Registry:clear()
	if self.on_unregister then
		for _, module in ipairs(self.items) do
			self.on_unregister(module)
		end
	end

	for i = #self.items, 1, -1 do
		self.items[i] = nil
	end

	for name in pairs(self.by_id) do
		self.by_id[name] = nil
	end
end

return Registry
