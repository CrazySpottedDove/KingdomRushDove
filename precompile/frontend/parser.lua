--- Lua 5.1 语法分析器（含 goto/label）
local lexer = require("precompile.frontend.lexer")

local M = {}

local Parser = {}
Parser.__index = Parser

local BIN_PRIORITY = {
	["or"] = {1, 1},
	["and"] = {2, 2},
	["<"] = {3, 3},
	[">"] = {3, 3},
	["<="] = {3, 3},
	[">="] = {3, 3},
	["~="] = {3, 3},
	["=="] = {3, 3},
	[".."] = {5, 4},
	["+"] = {6, 6},
	["-"] = {6, 6},
	["*"] = {7, 7},
	["/"] = {7, 7},
	["%"] = {7, 7},
	["^"] = {10, 9}
}

local UNARY_PRIORITY = 8

local function node(tag, line, col, fields)
	fields = fields or {}
	fields.tag = tag
	fields.line = line
	fields.col = col
	return fields
end

local function new(tokens, chunkname)
	return setmetatable({
		tokens = tokens,
		pos = 1,
		chunkname = chunkname
	}, Parser)
end

function Parser:peek(offset)
	return self.tokens[self.pos + (offset or 0)]
end

function Parser:next()
	local token = self.tokens[self.pos]
	self.pos = self.pos + 1
	return token
end

function Parser:check(value)
	return self:peek().value == value
end

function Parser:accept(value)
	if self:check(value) then
		return self:next()
	end
	return nil
end

function Parser:error(msg, token)
	token = token or self:peek()
	error(string.format("%s:%d:%d: %s", self.chunkname or "?", token.line, token.col, msg), 0)
end

function Parser:expect(value)
	local token = self:peek()
	if token.value ~= value then
		self:error(string.format("expected '%s', got '%s'", value, token.value), token)
	end
	return self:next()
end

function Parser:expect_name()
	local token = self:peek()
	if token.type ~= "name" then
		self:error("expected name, got '" .. token.value .. "'", token)
	end
	return self:next()
end

function Parser:parse()
	local body = self:parse_block({
		["<eof>"] = true
	})
	self:expect("<eof>")
	return node("Chunk", 1, 1, {
		body = body
	})
end

function Parser:parse_block(stop)
	local stats = {}
	local line, col = self:peek().line, self:peek().col
	while true do
		local token = self:peek()
		if token.type == "eof" or stop[token.value] then
			break
		end
		if token.value == ";" then
			self:next()
		else
			local stat = self:parse_statement()
			stats[#stats + 1] = stat
			if stat.tag == "Return" then
				break
			end
		end
	end
	return node("Block", line, col, {
		stats = stats
	})
end

function Parser:parse_statement()
	local token = self:peek()
	local value = token.value

	if value == "if" then
		return self:parse_if()
	elseif value == "while" then
		return self:parse_while()
	elseif value == "do" then
		self:next()
		local body = self:parse_block({
			end_ = true,
			["end"] = true
		})
		self:expect("end")
		return node("Do", token.line, token.col, {
			body = body
		})
	elseif value == "for" then
		return self:parse_for()
	elseif value == "repeat" then
		return self:parse_repeat()
	elseif value == "function" then
		return self:parse_function_statement()
	elseif value == "local" then
		return self:parse_local()
	elseif value == "return" then
		return self:parse_return()
	elseif value == "break" then
		self:next()
		return node("Break", token.line, token.col)
	elseif value == "goto" then
		self:next()
		local name = self:expect_name()
		return node("Goto", token.line, token.col, {
			name = name.value
		})
	elseif value == "::" then
		self:next()
		local name = self:expect_name()
		self:expect("::")
		return node("Label", token.line, token.col, {
			name = name.value
		})
	end

	local first = self:parse_prefixexp()
	if self:check("=") or self:check(",") then
		local targets = {first}
		while self:accept(",") do
			targets[#targets + 1] = self:parse_prefixexp()
		end
		self:expect("=")
		local exprs = self:parse_exprlist()
		return node("Assign", token.line, token.col, {
			targets = targets,
			exprs = exprs
		})
	end

	if first.tag == "Call" or first.tag == "Invoke" then
		return node("CallStat", token.line, token.col, {
			call = first
		})
	end

	self:error("syntax error near '" .. token.value .. "'", token)
end

function Parser:parse_if()
	local token = self:next()
	local clauses = {}
	local cond = self:parse_expr()
	self:expect("then")
	local body = self:parse_block({
		["elseif"] = true,
		["else"] = true,
		["end"] = true
	})
	clauses[#clauses + 1] = {
		cond = cond,
		body = body
	}

	while self:accept("elseif") do
		local elseif_cond = self:parse_expr()
		self:expect("then")
		local elseif_body = self:parse_block({
			["elseif"] = true,
			["else"] = true,
			["end"] = true
		})
		clauses[#clauses + 1] = {
			cond = elseif_cond,
			body = elseif_body
		}
	end

	local else_body
	if self:accept("else") then
		else_body = self:parse_block({
			["end"] = true
		})
	end
	self:expect("end")

	return node("If", token.line, token.col, {
		clauses = clauses,
		else_ = else_body
	})
end

function Parser:parse_while()
	local token = self:next()
	local cond = self:parse_expr()
	self:expect("do")
	local body = self:parse_block({
		["end"] = true
	})
	self:expect("end")
	return node("While", token.line, token.col, {
		cond = cond,
		body = body
	})
end

function Parser:parse_for()
	local token = self:next()
	local first = self:expect_name()
	if self:accept("=") then
		local from = self:parse_expr()
		self:expect(",")
		local to = self:parse_expr()
		local step
		if self:accept(",") then
			step = self:parse_expr()
		end
		self:expect("do")
		local body = self:parse_block({
			["end"] = true
		})
		self:expect("end")
		return node("NumFor", token.line, token.col, {
			var = first.value,
			from = from,
			to = to,
			step = step,
			body = body
		})
	end

	local names = {first.value}
	while self:accept(",") do
		names[#names + 1] = self:expect_name().value
	end
	self:expect("in")
	local exprs = self:parse_exprlist()
	self:expect("do")
	local body = self:parse_block({
		["end"] = true
	})
	self:expect("end")
	return node("GenFor", token.line, token.col, {
		names = names,
		exprs = exprs,
		body = body
	})
end

function Parser:parse_repeat()
	local token = self:next()
	local body = self:parse_block({
		["until"] = true
	})
	self:expect("until")
	local cond = self:parse_expr()
	return node("Repeat", token.line, token.col, {
		body = body,
		cond = cond
	})
end

function Parser:parse_function_statement()
	local token = self:next()
	local target = node("Name", self:peek().line, self:peek().col, {
		name = self:expect_name().value
	})
	local method = false
	while true do
		if self:accept(".") then
			local name = self:expect_name()
			target = node("Index", target.line, target.col, {
				obj = target,
				key = node("String", name.line, name.col, {
					value = name.value
				})
			})
		elseif self:accept(":") then
			local name = self:expect_name()
			target = node("Index", target.line, target.col, {
				obj = target,
				key = node("String", name.line, name.col, {
					value = name.value
				})
			})
			method = true
			break
		else
			break
		end
	end
	local func = self:parse_funcbody(token.line, token.col, method)
	return node("FunctionStat", token.line, token.col, {
		target = target,
		func = func
	})
end

function Parser:parse_local()
	local token = self:next()
	if self:accept("function") then
		local name = self:expect_name()
		local func = self:parse_funcbody(token.line, token.col, false)
		return node("LocalFunction", token.line, token.col, {
			name = name.value,
			func = func
		})
	end

	local names = {self:expect_name().value}
	while self:accept(",") do
		names[#names + 1] = self:expect_name().value
	end

	local exprs
	if self:accept("=") then
		exprs = self:parse_exprlist()
	end

	return node("Local", token.line, token.col, {
		names = names,
		exprs = exprs
	})
end

function Parser:parse_return()
	local token = self:next()
	local exprs = {}
	local next_token = self:peek()
	local terminators = {
		["end"] = true,
		["else"] = true,
		["elseif"] = true,
		["until"] = true,
		["<eof>"] = true,
		[";"] = true
	}
	if not terminators[next_token.value] then
		exprs = self:parse_exprlist()
	end
	self:accept(";")
	return node("Return", token.line, token.col, {
		exprs = exprs
	})
end

function Parser:parse_funcbody(line, col, add_self)
	self:expect("(")
	local params = {}
	local vararg = false
	if not self:check(")") then
		if self:accept("...") then
			vararg = true
		else
			params[#params + 1] = self:expect_name().value
			while self:accept(",") do
				if self:accept("...") then
					vararg = true
					break
				end
				params[#params + 1] = self:expect_name().value
			end
		end
	end
	self:expect(")")
	if add_self then
		table.insert(params, 1, "self")
	end
	local body = self:parse_block({
		["end"] = true
	})
	self:expect("end")
	return node("Function", line, col, {
		params = params,
		vararg = vararg,
		body = body
	})
end

function Parser:parse_exprlist()
	local exprs = {self:parse_expr()}
	while self:accept(",") do
		exprs[#exprs + 1] = self:parse_expr()
	end
	return exprs
end

function Parser:parse_expr()
	return self:parse_subexpr(0)
end

function Parser:parse_subexpr(limit)
	local token = self:peek()
	local left

	if (token.type == "op" and (token.value == "-" or token.value == "#")) or (token.type == "kw" and token.value == "not") then
		self:next()
		local operand = self:parse_subexpr(UNARY_PRIORITY)
		left = node("UnOp", token.line, token.col, {
			op = token.value,
			expr = operand
		})
	else
		left = self:parse_simple_expr()
	end

	while true do
		local op_token = self:peek()
		local op = op_token.value
		local priority = (op_token.type == "op" or op_token.type == "kw") and BIN_PRIORITY[op] or nil
		if not priority or priority[1] <= limit then
			break
		end
		self:next()
		local right = self:parse_subexpr(priority[2])
		left = node("BinOp", op_token.line, op_token.col, {
			op = op,
			left = left,
			right = right
		})
	end

	return left
end

function Parser:parse_simple_expr()
	local token = self:peek()
	local value = token.value

	if value == "nil" then
		self:next()
		return node("Nil", token.line, token.col)
	elseif value == "true" then
		self:next()
		return node("True", token.line, token.col)
	elseif value == "false" then
		self:next()
		return node("False", token.line, token.col)
	elseif token.type == "number" then
		self:next()
		return node("Number", token.line, token.col, {
			value = token.value
		})
	elseif token.type == "string" then
		self:next()
		return node("String", token.line, token.col, {
			value = token.value
		})
	elseif value == "..." then
		self:next()
		return node("Vararg", token.line, token.col)
	elseif value == "function" then
		self:next()
		return self:parse_funcbody(token.line, token.col, false)
	elseif value == "{" then
		return self:parse_table()
	end

	return self:parse_prefixexp()
end

function Parser:parse_prefixexp()
	local token = self:peek()
	local expr
	if token.type == "name" then
		self:next()
		expr = node("Name", token.line, token.col, {
			name = token.value
		})
	elseif token.value == "(" then
		self:next()
		local inner = self:parse_expr()
		self:expect(")")
		expr = node("Paren", token.line, token.col, {
			expr = inner
		})
	else
		self:error("unexpected symbol near '" .. token.value .. "'", token)
	end

	while true do
		local current = self:peek()
		if self:accept("[") then
			local key = self:parse_expr()
			self:expect("]")
			expr = node("Index", current.line, current.col, {
				obj = expr,
				key = key
			})
		elseif self:accept(".") then
			local name = self:expect_name()
			expr = node("Index", current.line, current.col, {
				obj = expr,
				key = node("String", name.line, name.col, {
					value = name.value
				})
			})
		elseif self:accept(":") then
			local name = self:expect_name()
			local args = self:parse_args()
			expr = node("Invoke", current.line, current.col, {
				obj = expr,
				name = name.value,
				args = args
			})
		elseif current.value == "(" or current.value == "{" or current.type == "string" then
			local args = self:parse_args()
			expr = node("Call", current.line, current.col, {
				callee = expr,
				args = args
			})
		else
			break
		end
	end

	return expr
end

function Parser:parse_args()
	if self:accept("(") then
		local args = {}
		if not self:check(")") then
			args = self:parse_exprlist()
		end
		self:expect(")")
		return args
	elseif self:check("{") then
		return {self:parse_table()}
	elseif self:peek().type == "string" then
		local token = self:next()
		return {node("String", token.line, token.col, {
			value = token.value
		})}
	end
	self:error("function arguments expected")
end

function Parser:parse_table()
	local token = self:expect("{")
	local fields = {}
	while not self:check("}") do
		if self:accept("[") then
			local key = self:parse_expr()
			self:expect("]")
			self:expect("=")
			fields[#fields + 1] = node("TableField", key.line, key.col, {
				key = key,
				value = self:parse_expr()
			})
		elseif self:peek().type == "name" and self:peek(1).value == "=" then
			local name = self:next()
			self:next()
			fields[#fields + 1] = node("TableField", name.line, name.col, {
				key = node("String", name.line, name.col, {
					value = name.value
				}),
				value = self:parse_expr()
			})
		else
			local value = self:parse_expr()
			fields[#fields + 1] = node("TableField", value.line, value.col, {
				value = value
			})
		end
		if not self:accept(",") and not self:accept(";") then
			break
		end
	end
	self:expect("}")
	return node("Table", token.line, token.col, {
		fields = fields
	})
end

function M.parse(source, chunkname)
	local tokens = lexer.tokenize(source, chunkname)
	local parser = new(tokens, chunkname)
	return parser:parse()
end

return M
