--- AST -> Lua 源码
local M = {}

local IDENT = "^[%a_][%w_]*$"

local function indent(depth)
	return string.rep("\t", depth)
end

local function trim_body(body)
	return (body:gsub("\n+$", ""))
end

local function join(list, sep)
	local parts = {}
	for i = 1, #list do
		parts[i] = list[i]
	end
	return table.concat(parts, sep)
end

local function quote(value)
	return string.format("%q", value)
end

local expr
local current_hook

function M.with_hook(hook, fn)
	local previous = current_hook
	current_hook = hook
	local ok, result = pcall(fn)
	current_hook = previous
	if not ok then
		error(result, 0)
	end
	return result
end

local function field_key(node)
	if node.tag == "String" and node.value:match(IDENT) then
		return "." .. node.value
	end
	return "[" .. expr(node) .. "]"
end

local function function_expr(node)
	local params = {}
	for i = 1, #node.params do
		params[i] = node.params[i]
	end
	if node.vararg then
		params[#params + 1] = "..."
	end
	local previous = current_hook
	current_hook = nil
	local body = (M.block(node.body, 1):gsub("\n+$", ""))
	current_hook = previous
	if body ~= "" then
		body = body .. "\n"
	end
	return "function(" .. table.concat(params, ", ") .. ")\n" .. body .. "end"
end

expr = function(node)
	local tag = node.tag
	if current_hook and (tag == "Call" or tag == "Invoke") then
		local replacement = current_hook(node)
		if replacement then
			return replacement
		end
	end
	if tag == "Nil" then
		return "nil"
	elseif tag == "True" then
		return "true"
	elseif tag == "False" then
		return "false"
	elseif tag == "Number" then
		return tostring(node.value)
	elseif tag == "String" then
		return quote(node.value)
	elseif tag == "Vararg" then
		return "..."
	elseif tag == "Name" then
		return node.name
	elseif tag == "Paren" then
		return "(" .. expr(node.expr) .. ")"
	elseif tag == "Index" then
		return expr(node.obj) .. field_key(node.key)
	elseif tag == "Call" then
		local callee = expr(node.callee)
		if node.callee.tag == "Function" then
			callee = "(" .. callee .. ")"
		end
		local args = {}
		for i = 1, #node.args do
			args[i] = expr(node.args[i])
		end
		return callee .. "(" .. table.concat(args, ", ") .. ")"
	elseif tag == "Invoke" then
		local args = {}
		for i = 1, #node.args do
			args[i] = expr(node.args[i])
		end
		return expr(node.obj) .. ":" .. node.name .. "(" .. table.concat(args, ", ") .. ")"
	elseif tag == "Function" then
		return function_expr(node)
	elseif tag == "Table" then
		local fields = {}
		for i = 1, #node.fields do
			local field = node.fields[i]
			if field.key then
				local key = field.key
				if key.tag == "String" and key.value:match(IDENT) then
					fields[i] = key.value .. " = " .. expr(field.value)
				else
					fields[i] = "[" .. expr(key) .. "] = " .. expr(field.value)
				end
			else
				fields[i] = expr(field.value)
			end
		end
		return "{" .. table.concat(fields, ", ") .. "}"
	elseif tag == "UnOp" then
		if node.op == "not" then
			return "(not " .. expr(node.expr) .. ")"
		end
		return "(" .. node.op .. " " .. expr(node.expr) .. ")"
	elseif tag == "BinOp" then
		return "(" .. expr(node.left) .. " " .. node.op .. " " .. expr(node.right) .. ")"
	end

	error("emitter: unknown expression tag " .. tostring(tag), 0)
end

local function emit_stat(node, depth, out)
	local pad = indent(depth)
	local tag = node.tag

	if tag == "Local" then
		local names = table.concat(node.names, ", ")
		if node.exprs and #node.exprs > 0 then
			local values = {}
			for i = 1, #node.exprs do
				values[i] = expr(node.exprs[i])
			end
			names = names .. " = " .. table.concat(values, ", ")
		end
		out[#out + 1] = pad .. "local " .. names
	elseif tag == "Assign" then
		local targets = {}
		for i = 1, #node.targets do
			targets[i] = expr(node.targets[i])
		end
		local values = {}
		for i = 1, #node.exprs do
			values[i] = expr(node.exprs[i])
		end
		out[#out + 1] = pad .. table.concat(targets, ", ") .. " = " .. table.concat(values, ", ")
	elseif tag == "CallStat" then
		out[#out + 1] = pad .. expr(node.call)
	elseif tag == "Return" then
		if #node.exprs == 0 then
			out[#out + 1] = pad .. "return"
		else
			local values = {}
			for i = 1, #node.exprs do
				values[i] = expr(node.exprs[i])
			end
			out[#out + 1] = pad .. "return " .. table.concat(values, ", ")
		end
	elseif tag == "Break" then
		out[#out + 1] = pad .. "break"
	elseif tag == "Goto" then
		out[#out + 1] = pad .. "goto " .. node.name
	elseif tag == "Label" then
		out[#out + 1] = pad .. "::" .. node.name .. "::"
	elseif tag == "Do" then
		local body = trim_body(M.block(node.body, depth + 1))
		out[#out + 1] = pad .. "do"
		if body ~= "" then
			out[#out + 1] = body
		end
		out[#out + 1] = pad .. "end"
	elseif tag == "If" then
		for i = 1, #node.clauses do
			local clause = node.clauses[i]
			local keyword = (i == 1) and "if" or "elseif"
			local body = trim_body(M.block(clause.body, depth + 1))
			out[#out + 1] = pad .. keyword .. " " .. expr(clause.cond) .. " then"
			if body ~= "" then
				out[#out + 1] = body
			end
		end
		if node.else_ then
			local body = trim_body(M.block(node.else_, depth + 1))
			out[#out + 1] = pad .. "else"
			if body ~= "" then
				out[#out + 1] = body
			end
		end
		out[#out + 1] = pad .. "end"
	elseif tag == "While" then
		local body = trim_body(M.block(node.body, depth + 1))
		out[#out + 1] = pad .. "while " .. expr(node.cond) .. " do"
		if body ~= "" then
			out[#out + 1] = body
		end
		out[#out + 1] = pad .. "end"
	elseif tag == "Repeat" then
		local body = trim_body(M.block(node.body, depth + 1))
		out[#out + 1] = pad .. "repeat"
		if body ~= "" then
			out[#out + 1] = body
		end
		out[#out + 1] = pad .. "until " .. expr(node.cond)
	elseif tag == "NumFor" then
		local header = "for " .. node.var .. " = " .. expr(node.from) .. ", " .. expr(node.to)
		if node.step then
			header = header .. ", " .. expr(node.step)
		end
		local body = trim_body(M.block(node.body, depth + 1))
		out[#out + 1] = pad .. header .. " do"
		if body ~= "" then
			out[#out + 1] = body
		end
		out[#out + 1] = pad .. "end"
	elseif tag == "GenFor" then
		local exprs = {}
		for i = 1, #node.exprs do
			exprs[i] = expr(node.exprs[i])
		end
		out[#out + 1] = pad .. "for " .. table.concat(node.names, ", ") .. " in " .. table.concat(exprs, ", ") .. " do"
		out[#out + 1] = M.block(node.body, depth + 1)
		out[#out + 1] = pad .. "end"
	elseif tag == "FunctionStat" then
		out[#out + 1] = pad .. expr(node.target) .. " = " .. function_expr(node.func)
	elseif tag == "LocalFunction" then
		local func = node.func
		local params = {}
		for i = 1, #func.params do
			params[i] = func.params[i]
		end
		if func.vararg then
			params[#params + 1] = "..."
		end
		local body = (M.block(func.body, depth + 1):gsub("\n+$", ""))
		out[#out + 1] = pad .. "local function " .. node.name .. "(" .. table.concat(params, ", ") .. ")"
		if body ~= "" then
			out[#out + 1] = body
		end
		out[#out + 1] = pad .. "end"
	else
		error("emitter: unknown statement tag " .. tostring(tag), 0)
	end
end

function M.block(block, depth)
	local out = {}
	for i = 1, #block.stats do
		emit_stat(block.stats[i], depth, out)
	end
	return table.concat(out, "\n") .. (#out > 0 and "\n" or "")
end

function M.stat(node, depth)
	local out = {}
	emit_stat(node, depth, out)
	return table.concat(out, "\n")
end

function M.function_code(func)
	return "return " .. function_expr(func) .. "\n"
end

M.expr = expr

return M
