--- 表达式特化求值：只折叠可以证明稳定的值
local V = require("precompile.stage.value")
local bit = require("bit")

local M = {}

local PURE_CALLS = {
	band = bit.band,
	bor = bit.bor,
	bnot = bit.bnot
}

local function is_truthy(value)
	return value ~= nil and value ~= false
end

local function binary(op, left, right)
	if op == "==" then
		return left == right
	elseif op == "~=" then
		return left ~= right
	elseif op == "<" then
		return left < right
	elseif op == ">" then
		return left > right
	elseif op == "<=" then
		return left <= right
	elseif op == ">=" then
		return left >= right
	elseif op == "+" then
		return left + right
	elseif op == "-" then
		return left - right
	elseif op == "*" then
		return left * right
	elseif op == "/" then
		return left / right
	elseif op == "%" then
		return left % right
	elseif op == "^" then
		return left ^ right
	elseif op == ".." then
		return tostring(left) .. tostring(right)
	end
	return nil
end

--- @param node table
--- @param env table
--- @return table value
function M.eval(node, env)
	local tag = node.tag

	if tag == "Nil" then
		return V.const(nil, true)
	elseif tag == "True" then
		return V.const(true, true)
	elseif tag == "False" then
		return V.const(false, true)
	elseif tag == "Number" or tag == "String" then
		return V.const(node.value, true)
	elseif tag == "Paren" then
		return M.eval(node.expr, env)
	elseif tag == "Name" then
		local value = env:get(node.name)
		if value.known then
			return value
		end
		if node.name:match("^[A-Z_][A-Z0-9_]*$") then
			local global = _G[node.name]
			if type(global) == "number" or type(global) == "string" or type(global) == "boolean" then
				return V.const(global, true)
			end
		end
		return value
	elseif tag == "Index" then
		local obj = M.eval(node.obj, env)
		local key = M.eval(node.key, env)
		if not key.known or not key.safe then
			return V.unknown()
		end
		return V.child(obj, key.value, env.whitelist, env.nullable)
	elseif tag == "UnOp" then
		local value = M.eval(node.expr, env)
		if not value.known or not value.safe then
			return V.unknown()
		end
		if node.op == "not" then
			return V.const(not is_truthy(value.value), true)
		elseif node.op == "-" and type(value.value) == "number" then
			return V.const(-value.value, true)
		elseif node.op == "#" and type(value.value) == "table" then
			return V.const(#value.value, true)
		end
		return V.unknown()
	elseif tag == "Invoke" then
		if node.obj.tag == "Name" and node.obj.name == "E" and node.name == "get_template" then
			local arg = M.eval(node.args[1], env)
			if arg.known and arg.safe and type(arg.value) == "string" then
				local E = require("entity_db")
				local template = E:get_template(arg.value)
				if template then
					return V.const(template, true, {})
				end
			end
			return V.unknown()
		end
		return V.unknown()
	elseif tag == "Call" then
		if node.callee.tag == "Name" and PURE_CALLS[node.callee.name] then
			local args = {}
			for i = 1, #node.args do
				local arg = M.eval(node.args[i], env)
				if not arg.known or not arg.safe then
					return V.unknown()
				end
				args[i] = arg.value
			end
			local ok, result = pcall(PURE_CALLS[node.callee.name], unpack(args))
			if not ok then
				return V.unknown()
			end
			return V.const(result, true)
		end
		return V.unknown()
	elseif tag == "BinOp" then
		if node.op == "and" then
			local left = M.eval(node.left, env)
			if left.known and left.safe then
				if not is_truthy(left.value) then
					return left
				end
				return M.eval(node.right, env)
			end
			return V.unknown()
		elseif node.op == "or" then
			local left = M.eval(node.left, env)
			if left.known and left.safe then
				if is_truthy(left.value) then
					return left
				end
				return M.eval(node.right, env)
			end
			return V.unknown()
		end

		local left = M.eval(node.left, env)
		local right = M.eval(node.right, env)
		if not left.known or not right.known or not left.safe or not right.safe then
			return V.unknown()
		end

		local ok, result = pcall(binary, node.op, left.value, right.value)
		if not ok then
			return V.unknown()
		end
		return V.const(result, true)
	end

	return V.unknown()
end

local function is_pure(node)
	local tag = node and node.tag

	if tag == "Name" or tag == "Nil" or tag == "True" or tag == "False" or tag == "Number" or tag == "String" then
		return true
	elseif tag == "Paren" then
		return is_pure(node.expr)
	elseif tag == "Index" then
		return is_pure(node.obj) and is_pure(node.key)
	elseif tag == "BinOp" then
		return is_pure(node.left) and is_pure(node.right)
	elseif tag == "UnOp" then
		return is_pure(node.expr)
	elseif tag == "Call" then
		if node.callee.tag == "Name" and PURE_CALLS[node.callee.name] then
			for i = 1, #node.args do
				if not is_pure(node.args[i]) then
					return false
				end
			end
			return true
		end
	end

	return false
end

--- 条件求值：额外处理 X and false / X or true 的布尔吸收。
--- 普通表达式求值不能这么做，因为 X and false 的结果可能是 nil 而不是 false。
function M.eval_condition(node, env)
	if node.tag == "Paren" then
		return M.eval_condition(node.expr, env)
	end

	if node.tag == "BinOp" and node.op == "and" then
		local left = M.eval_condition(node.left, env)

		if left.known and left.safe then
			if not is_truthy(left.value) then
				return left
			end

			return M.eval_condition(node.right, env)
		end

		local right = M.eval_condition(node.right, env)

		if right.known and right.safe and not is_truthy(right.value) and is_pure(node.left) then
			return V.const(false, true)
		end

		return V.unknown()
	elseif node.tag == "BinOp" and node.op == "or" then
		local left = M.eval_condition(node.left, env)

		if left.known and left.safe then
			if is_truthy(left.value) then
				return left
			end

			return M.eval_condition(node.right, env)
		end

		local right = M.eval_condition(node.right, env)

		if right.known and right.safe and is_truthy(right.value) and is_pure(node.left) then
			return V.const(true, true)
		end

		return V.unknown()
	end

	return M.eval(node, env)
end

return M
