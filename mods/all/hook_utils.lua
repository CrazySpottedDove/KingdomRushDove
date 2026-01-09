-- chunkname: @./mods/all/hook_utils.lua
local log = require("klua.log"):new("hook_utils")
local serpent = require("serpent")
local hook_utils = {}

-- 元表：自动创建不存在表
hook_utils.auto_table_mt = {
	__index = function(table, key)
		local new = {}

		setmetatable(new, hook_utils.auto_table_mt)
		rawset(table, key, new)

		return new
	end
}

---创建新的钩子工具实例
---@return table 新的钩子工具实例
function hook_utils:new()
	local new = {}

	setmetatable(new, self.auto_table_mt)

	return new
end

---增加钩子
---@param obj table 对象
---@param fn_name string 函数名
---@param handler function 钩子处理器
---@param priority integer 优先级
function hook_utils.HOOK(obj, fn_name, handler, priority)
	priority = priority or 0

	-- 步骤1: 检查对象是否已经初始化钩子系统
	if not obj.__hooks then
		obj.__hooks = {} -- 为这个对象创建钩子存储
	end

	-- 步骤2: 检查这个函数是否已经有钩子
	if not obj.__hooks[fn_name] then
		-- 第一次给这个函数添加钩子
		-- 2.1 保存原始函数
		obj.__hooks[fn_name] = {
			original = obj[fn_name], -- 保存原函数
			hooks = {} -- 钩子处理器列表
		}
		-- 2.2 创建新的包装函数
		obj[fn_name] = function(...)
			return hook_utils:execute_hook_chain(obj, fn_name, ...)
		end
	end

	-- 步骤3: 添加新的钩子处理器
	table.insert(obj.__hooks[fn_name].hooks, {
		handler = handler,
		priority = priority
	})
	table.sort(obj.__hooks[fn_name].hooks, function(a, b)
		return a.priority < b.priority
	end)
end

---链式调用钩子
---@param obj table 对象
---@param fn_name string 函数名
---@param ... any 参数
---@return function 钩子函数
function hook_utils:execute_hook_chain(obj, fn_name, ...)
	-- 获取这个函数的钩子信息
	local hook_info = obj.__hooks[fn_name]
	local hooks = hook_info.hooks
	local original = hook_info.original

	-- 情况1: 没有钩子，直接调用原函数
	if #hooks == 0 then
		return original(obj, ...)
	end

	-- 情况2: 有钩子，创建执行链
	-- 当前执行位置
	local current_index = 1

	-- 定义链式调用函数
	local function call_next(...)
		if current_index > #hooks then
			-- 所有钩子都执行完了，调用原始函数
			return original(...)
		else
			-- 执行当前钩子，并递增进度
			local current_handler = hooks[current_index].handler

			current_index = current_index + 1

			-- 调用钩子处理器，传递下一个调用的函数
			return current_handler(call_next, ...)
		end
	end

	-- 开始执行钩子链
	return call_next(...)
end

-- 移除特定钩子
function hook_utils.UNHOOK(obj, fn_name, handler_to_remove)
	if not obj.__hooks or not obj.__hooks[fn_name] then
		return false
	end

	local hooks = obj.__hooks[fn_name].hooks
	local removed_count = 0

	-- 从后往前遍历，避免删除时索引错乱
	for i = #hooks, 1, -1 do
		local handler = hooks[i].handler

		if handler == handler_to_remove then
			table.remove(hooks, i)

			removed_count = removed_count + 1
		end
	end

	return removed_count > 0
end

-- 直接调用原始函数（绕过所有钩子）
function hook_utils.CALL_ORIGINAL(obj, fn_name, ...)
	if not obj.__hooks or not obj.__hooks[fn_name] then
		return obj[fn_name](...)
	end

	return obj.__hooks[fn_name].original(obj, ...)
end

return hook_utils
