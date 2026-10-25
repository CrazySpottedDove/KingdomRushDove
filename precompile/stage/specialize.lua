--- 函数特化：按实体配置折叠 if、展开数字 for
local V = require("precompile.stage.value")
local eval = require("precompile.stage.eval")
local emitter = require("precompile.emit.emitter")
local source = require("precompile.frontend.source")

local M = {}

local MAX_UNROLL = 256

local Env = {}
Env.__index = Env

function Env:get(name)
	local env = self
	while env do
		local value = env.locals[name]
		if value then
			return value
		end
		env = env.parent
	end
	return V.unknown()
end

function Env:set(name, value)
	local env = self
	while env do
		if env.locals[name] then
			env.locals[name] = value
			return
		end
		env = env.parent
	end
	self.locals[name] = value
end

function Env:declare(name, value)
	self.locals[name] = value
end

local function child(env)
	return setmetatable({
		parent = env,
		entity = env.entity,
		whitelist = env.whitelist,
		nullable = env.nullable,
		locals = {}
	}, Env)
end

local function new_env(entity, whitelist, nullable)
	return setmetatable({
		parent = nil,
		entity = entity,
		whitelist = whitelist,
		nullable = nullable,
		locals = {}
	}, Env)
end

local function contains_control(node)
	if type(node) ~= "table" then
		return false
	end
	if node.tag == "Function" then
		return false
	end
	if node.tag == "Break" or node.tag == "Goto" or node.tag == "Label" then
		return true
	end
	for _, value in pairs(node) do
		if type(value) == "table" and contains_control(value) then
			return true
		end
	end
	return false
end

local function unroll_values(from, to, step)
	if step == 0 then
		return nil
	end
	local values = {}
	local value = from
	if step > 0 then
		while value <= to do
			values[#values + 1] = value
			if #values > MAX_UNROLL then
				return nil
			end
			value = value + step
		end
	else
		while value >= to do
			values[#values + 1] = value
			if #values > MAX_UNROLL then
				return nil
			end
			value = value + step
		end
	end
	return values
end

local specialize_block
local specialize_stat
local specialize_call

local function trim_block(body)
	return (body:gsub("\n+$", ""))
end

local function make_hook(env, options, state)
	return function(node)
		return specialize_call(node, env, options, state)
	end
end

specialize_block = function(block, env, depth, options, state)
	local out = {}
	for i = 1, #block.stats do
		local stat = block.stats[i]
		local code = emitter.with_hook(make_hook(env, options, state), function()
			return specialize_stat(stat, env, depth, options, state)
		end)
		if code and code ~= "" then
			out[#out + 1] = code
			out[#out + 1] = "\n"
		end
	end
	return table.concat(out)
end

local function is_truthy(value)
	return value ~= nil and value ~= false
end

local function contains_nullable(node, env)
	if node.tag == "Name" or node.tag == "Index" then
		local value = eval.eval(node, env)
		return value.known and value.safe and value.nullable == true
	end
	if node.tag == "Paren" then
		return contains_nullable(node.expr, env)
	end
	if node.tag == "UnOp" then
		return contains_nullable(node.expr, env)
	end
	if node.tag == "BinOp" and (node.op == "and" or node.op == "or") then
		return contains_nullable(node.left, env) or contains_nullable(node.right, env)
	end
	return false
end

local function emit_condition(node, env)
	if node.tag == "Paren" then
		return emit_condition(node.expr, env)
	end

	if node.tag == "UnOp" and node.op == "not" then
		local inner = emit_condition(node.expr, env)
		if inner == "true" then
			return "false"
		elseif inner == "false" then
			return "true"
		end
		return "(not " .. inner .. ")"
	end

	if node.tag == "BinOp" and (node.op == "and" or node.op == "or") then
		local left = eval.eval(node.left, env)
		if left.known and left.safe and contains_nullable(node.left, env) then
			local left_code = emit_condition(node.left, env)
			local right = eval.eval(node.right, env)
			if right.known and right.safe and not right.nullable then
				if node.op == "and" and is_truthy(right.value) then
					return left_code
				elseif node.op == "or" and not is_truthy(right.value) then
					return left_code
				end
			end
			if node.op == "and" then
				if not is_truthy(left.value) then
					return "false"
				end
				return "(" .. left_code .. " and " .. emit_condition(node.right, env) .. ")"
			else
				if not is_truthy(left.value) then
					return emit_condition(node.right, env)
				end
				return "(" .. left_code .. " or " .. emit_condition(node.right, env) .. ")"
			end
		end

		if left.known and left.safe then
			if node.op == "and" then
				if not is_truthy(left.value) then
					return "false"
				end
				return emit_condition(node.right, env)
			else
				if is_truthy(left.value) then
					return "true"
				end
				return emit_condition(node.right, env)
			end
		end

		local left_code = emit_condition(node.left, env)
		local right = eval.eval(node.right, env)
		if right.known and right.safe and not right.nullable then
			if node.op == "and" and is_truthy(right.value) then
				return left_code
			elseif node.op == "or" and not is_truthy(right.value) then
				return left_code
			end
		end
		return "(" .. left_code .. " " .. node.op .. " " .. emit_condition(node.right, env) .. ")"
	end

	local value = eval.eval(node, env)
	if value.known and value.safe and not value.nullable then
		return is_truthy(value.value) and "true" or "false"
	end
	if value.known and value.safe and value.nullable and not is_truthy(value.value) then
		return "false"
	end

	return emitter.expr(node)
end

local function specialize_if(node, env, depth, options, state)
	local pad = string.rep("\t", depth)
	local out = {}
	local unknown_from

	for i = 1, #node.clauses do
		local clause = node.clauses[i]
		local value = eval.eval_condition(clause.cond, env)
		if value.known and value.safe and (not contains_nullable(clause.cond, env) or not is_truthy(value.value)) then
			if value.value ~= nil and value.value ~= false then
				state.folded = state.folded + 1
				local body_env = child(env)
				local body = trim_block(specialize_block(clause.body, body_env, depth + 1, options, state))
				out[#out + 1] = pad .. "do"
				if body ~= "" then
					out[#out + 1] = body
				end
				out[#out + 1] = pad .. "end"
				return table.concat(out, "\n")
			end
			state.folded = state.folded + 1
		else
			unknown_from = i
			break
		end
	end

	if not unknown_from then
		if node.else_ then
			local body_env = child(env)
			local body = trim_block(specialize_block(node.else_, body_env, depth + 1, options, state))
			out[#out + 1] = pad .. "do"
			if body ~= "" then
				out[#out + 1] = body
			end
			out[#out + 1] = pad .. "end"
			return table.concat(out, "\n")
		end
		return ""
	end

	local has_else = false
	for i = unknown_from, #node.clauses do
		local clause = node.clauses[i]
		local value = eval.eval_condition(clause.cond, env)
		local folded = value.known and value.safe and (not contains_nullable(clause.cond, env) or not is_truthy(value.value))
		if folded then
			state.folded = state.folded + 1
			if not is_truthy(value.value) then
			-- known false: drop this branch
			else
				local body_env = child(env)
				local body = trim_block(specialize_block(clause.body, body_env, depth + 1, options, state))
				out[#out + 1] = pad .. "else"
				if body ~= "" then
					out[#out + 1] = body
				end
				has_else = true
				break
			end
		else
			local keyword = (i == unknown_from) and "if" or "elseif"
			local body_env = child(env)
			local body = trim_block(specialize_block(clause.body, body_env, depth + 1, options, state))
			out[#out + 1] = pad .. keyword .. " " .. emit_condition(clause.cond, env) .. " then"
			if body ~= "" then
				out[#out + 1] = body
			end
		end
	end
	if node.else_ and not has_else then
		local body_env = child(env)
		local body = trim_block(specialize_block(node.else_, body_env, depth + 1, options, state))
		out[#out + 1] = pad .. "else"
		if body ~= "" then
			out[#out + 1] = body
		end
	end
	out[#out + 1] = pad .. "end"
	return table.concat(out, "\n")
end

local function specialize_num_for(node, env, depth, options, state)
	local from = eval.eval(node.from, env)
	local to = eval.eval(node.to, env)
	local step = node.step and eval.eval(node.step, env) or V.const(1, true)

	local useful = from.known and from.safe and to.known and to.safe and step.known and step.safe and type(from.value) == "number" and type(to.value) == "number" and type(step.value) == "number" and not contains_control(node.body)

	local values = useful and unroll_values(from.value, to.value, step.value) or nil
	if values then
		state.unrolled = state.unrolled + 1
		local out = {}
		local pad = string.rep("\t", depth)
		for i = 1, #values do
			local body_env = child(env)
			body_env:declare(node.var, V.const(values[i], true))
			out[#out + 1] = pad .. "do"
			out[#out + 1] = pad .. "\tlocal " .. node.var .. " = " .. tostring(values[i])
			local body = trim_block(specialize_block(node.body, body_env, depth + 1, options, state))
			if body ~= "" then
				out[#out + 1] = body
			end
			out[#out + 1] = pad .. "end"
		end
		return table.concat(out, "\n")
	end

	local body_env = child(env)
	body_env:declare(node.var, V.unknown())
	local pad = string.rep("\t", depth)
	local header = "for " .. node.var .. " = " .. emitter.expr(node.from) .. ", " .. emitter.expr(node.to)
	if node.step then
		header = header .. ", " .. emitter.expr(node.step)
	end
	return pad .. header .. " do\n" .. trim_block(specialize_block(node.body, body_env, depth + 1, options, state)) .. "\n" .. pad .. "end"
end

specialize_stat = function(node, env, depth, options, state)
	local tag = node.tag
	local pad = string.rep("\t", depth)

	if tag == "If" then
		return specialize_if(node, env, depth, options, state)
	elseif tag == "NumFor" then
		return specialize_num_for(node, env, depth, options, state)
	elseif tag == "While" then
		local body_env = child(env)
		return pad .. "while " .. emit_condition(node.cond, env) .. " do\n" .. trim_block(specialize_block(node.body, body_env, depth + 1, options, state)) .. "\n" .. pad .. "end"
	elseif tag == "Repeat" then
		local body_env = child(env)
		return pad .. "repeat\n" .. trim_block(specialize_block(node.body, body_env, depth + 1, options, state)) .. "\n" .. pad .. "until " .. emit_condition(node.cond, env)
	elseif tag == "Do" then
		local body_env = child(env)
		return pad .. "do\n" .. trim_block(specialize_block(node.body, body_env, depth + 1, options, state)) .. "\n" .. pad .. "end"
	elseif tag == "GenFor" then
		local body_env = child(env)
		for _, name in ipairs(node.names) do
			body_env:declare(name, V.unknown())
		end
		local exprs = {}
		for i = 1, #node.exprs do
			exprs[i] = emitter.expr(node.exprs[i])
		end
		return pad .. "for " .. table.concat(node.names, ", ") .. " in " .. table.concat(exprs, ", ") .. " do\n" .. trim_block(specialize_block(node.body, body_env, depth + 1, options, state)) .. "\n" .. pad .. "end"
	elseif tag == "Local" then
		local values = {}
		for i = 1, #(node.exprs or {}) do
			values[i] = eval.eval(node.exprs[i], env)
		end
		for i = 1, #node.names do
			env:declare(node.names[i], values[i] or V.unknown())
		end
		return emitter.stat(node, depth)
	elseif tag == "Assign" then
		local values = {}
		for i = 1, #node.exprs do
			values[i] = eval.eval(node.exprs[i], env)
		end
		for i = 1, #node.targets do
			local target = node.targets[i]
			if target.tag == "Name" then
				env:set(target.name, values[i] or V.unknown())
			end
		end
		return emitter.stat(node, depth)
	elseif tag == "LocalFunction" then
		env:declare(node.name, V.unknown())
		return emitter.stat(node, depth)
	elseif tag == "FunctionStat" then
		return emitter.stat(node, depth)
	end

	return emitter.stat(node, depth)
end

local function resolve_global(node, globals)
	if node.tag == "Name" then
		return globals[node.name]
	elseif node.tag == "Index" then
		local obj = resolve_global(node.obj, globals)
		if type(obj) ~= "table" then
			return nil
		end
		local key = node.key
		if key.tag == "String" then
			return obj[key.value]
		elseif key.tag == "Number" then
			return obj[key.value]
		end
	end
	return nil
end

local function value_key(value)
	if not value.known then
		return "?"
	end
	if not value.safe then
		return "!"
	end
	local kind = type(value.value)
	if kind == "table" then
		return "t:" .. tostring(value.value)
	end
	return kind .. ":" .. tostring(value.value)
end

local function helper_target(node, state)
	if node.tag ~= "Call" then
		return nil
	end
	local target = resolve_global(node.callee, state.globals)
	if type(target) ~= "function" then
		return nil
	end
	if state.target_cache[target] == false then
		return nil
	end
	local cached = state.target_cache[target]
	if cached then
		return cached
	end
	-- 内联只复制函数体，不复制它的闭包 upvalue。只有 upvalue 能在运行环境
	-- 里按同名、同值解析时，函数体里的自由变量才仍指向同一个对象；否则
	-- （例如 macros.lua 的 CLAMP_SIGNED）内联后会变成访问不存在的全局。
	local upvalue_index = 1
	while true do
		local upvalue_name, upvalue_value = debug.getupvalue(target, upvalue_index)
		if not upvalue_name then
			break
		end
		if upvalue_name ~= "" and state.globals[upvalue_name] ~= upvalue_value then
			state.target_cache[target] = false
			return nil
		end
		upvalue_index = upvalue_index + 1
	end
	local func, file = source.find_function(target)
	if not func or func.vararg then
		state.target_cache[target] = false
		return nil
	end
	cached = {
		func = func,
		file = file
	}
	state.target_cache[target] = cached
	return cached
end

specialize_call = function(node, env, options, state)
	if os.getenv("KR_NO_HELPER_INLINE") == "1" then
		return nil
	end
	local target = helper_target(node, state)
	if not target then
		return nil
	end

	local args = {}
	local key_parts = {}
	for i = 1, #node.args do
		args[i] = eval.eval(node.args[i], env)
		key_parts[i] = value_key(args[i])
	end
	local key = tostring(target.func) .. "|" .. table.concat(key_parts, ",")
	local cached = state.helper_cache[key]
	if cached == false then
		return nil
	end
	local function helper_ref(name)
		return "__pc_helpers[" .. string.format("%q", name) .. "]"
	end
	if type(cached) == "string" then
		local args_code = {}
		for i = 1, #node.args do
			args_code[i] = emitter.expr(node.args[i])
		end
		return helper_ref(cached) .. "(" .. table.concat(args_code, ", ") .. ")"
	end

	state.helper_index = state.helper_index + 1
	local name = state.helper_prefix .. state.helper_index
	state.helper_cache[key] = name

	local henv = new_env(env.entity, env.whitelist, env.nullable)
	for i = 1, #target.func.params do
		henv:declare(target.func.params[i], args[i] or V.unknown())
	end

	local folded_before = state.folded
	local helpers_before = #state.helpers
	local body = trim_block(specialize_block(target.func.body, henv, 1, options, state))
	local changed = state.folded > folded_before or #state.helpers > helpers_before
	if not changed then
		state.helper_cache[key] = false
		return nil
	end

	local params = {}
	for i = 1, #target.func.params do
		params[i] = target.func.params[i]
	end
	state.helpers[#state.helpers + 1] = {
		name = name,
		params = params,
		body = body,
		file = target.file and target.file.path
	}
	return helper_ref(name) .. "(" .. table.concat((function()
		local out = {}
		for i = 1, #node.args do
			out[i] = emitter.expr(node.args[i])
		end
		return out
	end)(), ", ") .. ")"
end

--- @param func table Function AST
--- @param entity table
--- @param options table|nil { file = string }
--- @return table { code = string, folded = number, unrolled = number }
function M.specialize(func, entity, options)
	local env = new_env(entity, options and options.whitelist, options and options.nullable)
	local state = {
		folded = 0,
		unrolled = 0,
		helpers = {},
		helper_cache = {},
		helper_index = 0,
		helper_prefix = options and options.helper_prefix or "__pc_h_",
		target_cache = {},
		globals = options and options.globals or _G
	}
	local params = {}
	for i = 1, #func.params do
		local name = func.params[i]
		params[i] = name
		if i == 1 then
			env:declare(name, V.const(entity, true, {}))
		else
			env:declare(name, V.unknown())
		end
	end
	if func.vararg then
		params[#params + 1] = "..."
	end

	local body = specialize_block(func.body, env, 1, options, state)
	local code = "return function(" .. table.concat(params, ", ") .. ")\n" .. body .. "end\n"
	local helper_lines = {}
	if #state.helpers > 0 then
		helper_lines[#helper_lines + 1] = "local __pc_helpers = {}"
		for i = 1, #state.helpers do
			local helper = state.helpers[i]
			local code = "__pc_helpers[" .. string.format("%q", helper.name) .. "] = function(" .. table.concat(helper.params, ", ") .. ")\n"
			if helper.body ~= "" then
				code = code .. helper.body .. "\n"
			end
			code = code .. "end"
			helper_lines[#helper_lines + 1] = code
		end
	end

	return {
		code = code,
		helpers = state.helpers,
		helpers_code = table.concat(helper_lines, "\n"),
		folded = state.folded,
		unrolled = state.unrolled,
		file = options and options.file,
		line = func.line
	}
end

return M
