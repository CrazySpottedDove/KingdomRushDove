-- chunkname: @./plugin/all/hook_utils.lua
local log = require("lib.klua.log"):new("hook_utils")
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

-- 重建 fn_name 的调用链：把已按 priority 排序的 hooks 扁平化成一条闭包链并赋给 obj[fn_name]。
-- 闭包只在 HOOK/UNHOOK 时创建一次，运行时调用零分配（对比旧实现每次调用都新建 call_next 闭包链）。
-- 无钩子时直接把 original 还原回 obj[fn_name]，调用开销与未启用钩子完全一致。
-- 语义（责任链）：handler 签名 function(next, self_or_first_arg, ...)，
--   next 是把后续 handler 与 original 串起来的函数；链尾调用 original 时参数由各 handler 通过 next(...) 传递。
-- 注意：与旧实现的差异——旧实现中重复调用 next 会推进到链的下一环；预编译链中重复调用 next 会再次执行同一个后续 handler（标准责任链语义）。插件中 next 应恰好调用一次。
local function rebuild_chain(obj, fn_name)
	local hook_info = obj.__hooks[fn_name]
	local hooks = hook_info.hooks
	local count = #hooks

	if count == 0 then
		obj[fn_name] = hook_info.original

		return
	end

	local next_fn = hook_info.original

	for i = count, 1, -1 do
		local handler = hooks[i].handler
		local next_prev = next_fn

		next_fn = function(...)
			return handler(next_prev, ...)
		end
	end

	obj[fn_name] = next_fn
end

---增加钩子
---@param obj table 对象
---@param fn_name string 函数名
---@param handler function 钩子处理器
---@param priority integer 优先级
function hook_utils.HOOK(obj, fn_name, handler, priority)
	if not obj then
		log.error("尝试添加钩子到一个空对象!")
		return
	end

	if not obj[fn_name] then
		log.error("尝试添加钩子到不存在的函数%s!", fn_name)
		return
	end

	if type(handler) ~= "function" then
		log.error("钩子处理器必须是函数: %s.%s（实际为 %s）", tostring(obj), tostring(fn_name), type(handler))
		return
	end

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
	end

	-- 步骤3: 添加新的钩子处理器
	table.insert(obj.__hooks[fn_name].hooks, {
		handler = handler,
		priority = priority
	})
	table.sort(obj.__hooks[fn_name].hooks, function(a, b)
		return a.priority < b.priority
	end)

	-- 步骤4: 重建预编译调用链
	rebuild_chain(obj, fn_name)
end

-- 移除特定钩子
function hook_utils.UNHOOK(obj, fn_name, handler_to_remove)
	if not obj.__hooks or not obj.__hooks[fn_name] then
		return false
	end

	local hook_info = obj.__hooks[fn_name]
	local hooks = hook_info.hooks
	local removed_count = 0

	-- 从后往前遍历，避免删除时索引错乱
	for i = #hooks, 1, -1 do
		local handler = hooks[i].handler

		if handler == handler_to_remove then
			table.remove(hooks, i)

			removed_count = removed_count + 1
		end
	end

	-- 钩子集合变化后必须重建链，否则已编译闭包仍引用已删除的 handler
	if removed_count > 0 then
		rebuild_chain(obj, fn_name)
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
