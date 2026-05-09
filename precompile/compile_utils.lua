-- 编译期模板预处理工具
local M = {}

-- 常量
local OPENERS = {
	["if"] = true,
	["for"] = true,
	["while"] = true,
	["function"] = true,
	["do"] = true,
	["repeat"] = true
}
local CLOSERS = {
	["end"] = true,
	["until"] = true
}

-- 分词
local function scan_keywords(line)
	local kws = {}
	local i = 1
	local n = #line
	while i <= n do
		local ch = line:sub(i, i)
		if ch:match("[ \t\r]") then
			i = i + 1
		elseif ch == "-" and line:sub(i + 1, i + 1) == "-" then
			break
		elseif ch == "'" or ch == '"' then
			local q = ch
			local j = i + 1
			while j <= n do
				local c = line:sub(j, j)
				if c == "\\" then
					j = j + 2
				elseif c == q then
					j = j + 1
					break
				else
					j = j + 1
				end
			end
			i = j
		elseif ch == "[" then
			local eq = 0
			local k = i + 1
			while line:sub(k, k) == "=" do
				eq = eq + 1
				k = k + 1
			end
			if line:sub(k, k) == "[" then
				local close = "]"
				for _ = 1, eq do
					close = close .. "="
				end
				close = close .. "]"
				local pos = line:find(close, k + 1)
				if pos then
					i = pos + #close
				else
					i = n + 1
				end
			else
				i = i + 1
			end
		elseif ch:match("[%a_]") then
			local j = i + 1
			while j <= n and line:sub(j, j):match("[%w_]") do
				j = j + 1
			end
			local word = line:sub(i, j - 1)
			if OPENERS[word] then
				kws[#kws + 1] = word
			elseif CLOSERS[word] then
				kws[#kws + 1] = word
			end
			i = j
		else
			i = i + 1
		end
	end
	return kws
end

-- 参数拆分
local function split_args(s)
	if not s or s:match("^%s*$") then
		return {}
	end
	local parts = {}
	local depth = 0
	local buf = ""
	for k = 1, #s do
		local c = s:sub(k, k)
		if c == "(" or c == "[" or c == "{" then
			depth = depth + 1
			buf = buf .. c
		elseif c == ")" or c == "]" or c == "}" then
			depth = depth - 1
			buf = buf .. c
		elseif c == "," and depth == 0 then
			parts[#parts + 1] = buf:match("^%s*(.-)%s*$")
			buf = ""
		else
			buf = buf .. c
		end
	end
	parts[#parts + 1] = buf:match("^%s*(.-)%s*$")
	return parts
end

-- 行类型分析
local function analyze_line(line)
	local t = line:match("^%s*(.*)$")
	local stmt = t:match("^conststmt%((.*)%)$")
	if stmt then
		return {
			directive = "stmt",
			expr = stmt
		}
	end
	local cond = t:match("^constif%((.*)%)$")
	if cond then
		return {
			directive = "if",
			expr = cond
		}
	end
	cond = t:match("^constelseif%((.*)%)$")
	if cond then
		return {
			directive = "elseif",
			expr = cond
		}
	end
	if t:match("^constelse$") then
		return {
			directive = "constelse"
		}
	end
	if t:match("^constend$") then
		return {
			directive = "constend"
		}
	end
	-- @constif 标签语法：对下一行生效
	cond = t:match("^@constif%((.*)%)$")
	if cond then
		return {
			directive = "at_constexpr",
			expr = cond
		}
	end
	if t:match("^@constelse$") then
		return {
			directive = "at_else"
		}
	end
	local cvn, cve = t:match("^constvar%s+(%w+)%s*=%s*(.-)$")
	if cvn then
		return {
			directive = "constvar",
			var = cvn,
			expr = cve
		}
	end
	local vn, rest = t:match("^constfor (%w+)%s*=%s*(.+)$")
	if vn then
		rest = rest:match("^(.*)%s+do$")
		if rest then
			local parts = split_args(rest)
			return {
				directive = "for",
				var = vn,
				start = parts[1],
				stop = parts[2],
				step = parts[3] or "1"
			}
		end
	end
	return {
		directive = nil
	}
end

-- 求值
local function eval_expr(expr, env, scope_vars)
	local eval_env = env
	if scope_vars and next(scope_vars) then
		eval_env = setmetatable({}, {
			__index = env
		})
		for k, v in pairs(scope_vars) do
			eval_env[k] = v
		end
	end
	local fn, err = load("return(" .. expr .. ")", "constexpr", "t", eval_env)
	if not fn then
		error("compile_utils: constexpr error: " .. err)
	end
	local ok, r = pcall(fn)
	if not ok then
		error("compile_utils: constexpr runtime error: " .. tostring(r))
	end
	return r
end
local function eval_stmt(stmt, env, scope_vars)
	local eval_env = env
	if scope_vars and next(scope_vars) then
		eval_env = setmetatable({}, {
			__index = env
		})
		for k, v in pairs(scope_vars) do
			eval_env[k] = v
		end
	end
	local fn, err = load(stmt, "conststmt", "t", eval_env)
	if not fn then
		error("compile_utils: conststmt error: " .. err)
	end
	local ok, r = pcall(fn)
	if not ok then
		error("compile_utils: conststmt runtime error: " .. tostring(r))
	end
end

-- 查找 constfor/constif 的匹配 constend
local function find_ctime_end(lines, start, finish)
	local depth = 1
	for i = start, finish do
		local info = analyze_line(lines[i])
		if info.directive == "if" or info.directive == "for" then
			depth = depth + 1
		elseif info.directive == "constend" then
			depth = depth - 1
			if depth == 0 then
				return i
			end
		end
	end
	error("compile_utils: unterminated compile-time construct")
end

-- 用 constelse/constend 解析 if constexpr 结构
local function parse_if_structure(lines, start, finish)
	local branches = {}
	local depth = 1
	local ct = "then"
	local cs = start
	local ce = nil
	local i = start
	while i <= finish do
		local info = analyze_line(lines[i])
		if info.directive == "if" or info.directive == "for" then
			depth = depth + 1
		elseif info.directive == "constend" then
			depth = depth - 1
			if depth == 0 then
				branches[#branches + 1] = {
					type = ct,
					start = cs,
					stop = i - 1,
					expr = ce
				}
				return branches, i
			end
		elseif depth == 1 then
			if info.directive == "elseif" then
				branches[#branches + 1] = {
					type = ct,
					start = cs,
					stop = i - 1,
					expr = ce
				}
				ct = "elseif"
				cs = i + 1
				ce = info.expr
			elseif info.directive == "constelse" then
				branches[#branches + 1] = {
					type = ct,
					start = cs,
					stop = i - 1,
					expr = ce
				}
				ct = "else"
				cs = i + 1
				ce = nil
			end
		end
		i = i + 1
	end
	error("compile_utils: unterminated if constexpr structure")
end

-- 全局计数器
local cf_counter = 0

-- constbreak→goto 转换（不追加标签，由调用方统一添加）
local function replace_constbreak_in_lines(lines, label)
	local result = {}
	for _, line in ipairs(lines) do
		local out = {}
		local i = 1
		local n = #line
		while i <= n do
			local ch = line:sub(i, i)
			if ch:match("[ \t\r]") then
				out[#out + 1] = ch
				i = i + 1
			elseif ch == "-" and line:sub(i + 1, i + 1) == "-" then
				out[#out + 1] = line:sub(i)
				break
			elseif ch == "'" or ch == "\"" then
				local q = ch
				local j = i + 1
				while j <= n do
					local c = line:sub(j, j)
					if c == "\\" then
						j = j + 2
					elseif c == q then
						j = j + 1
						break
					else
						j = j + 1
					end
				end
				out[#out + 1] = line:sub(i, j - 1)
				i = j
			elseif ch == "[" then
				local eq = 0
				local k = i + 1
				while line:sub(k, k) == "=" do
					eq = eq + 1
					k = k + 1
				end
				if line:sub(k, k) == "[" then
					local close = "]"
					for _ = 1, eq do
						close = close .. "="
					end
					close = close .. "]"
					local pos = line:find(close, k + 1)
					if pos then
						out[#out + 1] = line:sub(i, pos + #close - 1)
						i = pos + #close
					else
						out[#out + 1] = ch
						i = i + 1
					end
				else
					out[#out + 1] = ch
					i = i + 1
				end
			elseif ch:match("[%a_]") then
				local j = i + 1
				while j <= n and line:sub(j, j):match("[%w_]") do
					j = j + 1
				end
				local word = line:sub(i, j - 1)
				if word == "constbreak" then
					out[#out + 1] = "goto " .. label
					i = j
				else
					out[#out + 1] = word
					i = j
				end
			else
				out[#out + 1] = ch
				i = i + 1
			end
		end
		result[#result + 1] = table.concat(out)
	end
	return result
end

-- 分词安全的标识符替换
local function replace_ident_in_text(text, var_name, value)
	local out = {}
	local i = 1
	local n = #text
	while i <= n do
		local ch = text:sub(i, i)
		if ch:match("[ \t\r]") then
			out[#out + 1] = ch
			i = i + 1
		elseif ch == "-" and text:sub(i + 1, i + 1) == "-" then
			out[#out + 1] = text:sub(i)
			break
		elseif ch == "'" or ch == '"' then
			local q = ch
			local j = i + 1
			while j <= n do
				local c = text:sub(j, j)
				if c == "\\" then
					j = j + 2
				elseif c == q then
					j = j + 1
					break
				else
					j = j + 1
				end
			end
			out[#out + 1] = text:sub(i, j - 1)
			i = j
		elseif ch == "[" then
			local eq = 0
			local k = i + 1
			while text:sub(k, k) == "=" do
				eq = eq + 1
				k = k + 1
			end
			if text:sub(k, k) == "[" then
				local close = "]"
				for _ = 1, eq do
					close = close .. "="
				end
				close = close .. "]"
				local pos = text:find(close, k + 1)
				if pos then
					out[#out + 1] = text:sub(i, pos + #close - 1)
					i = pos + #close
				else
					out[#out + 1] = ch
					i = i + 1
				end
			else
				out[#out + 1] = ch
				i = i + 1
			end
		elseif ch:match("[%a_]") then
			local j = i + 1
			while j <= n and text:sub(j, j):match("[%w_]") do
				j = j + 1
			end
			local word = text:sub(i, j - 1)
			if word == var_name then
				out[#out + 1] = value
			else
				out[#out + 1] = word
			end
			i = j
		else
			out[#out + 1] = ch
			i = i + 1
		end
	end
	return table.concat(out)
end

local function replace_ident_in_lines(lines, var_name, value)
	local result = {}
	for _, line in ipairs(lines) do
		local cf = line:match("^%s*constfor%s+(%w+)%s*=")
		if cf and cf == var_name then
			result[#result + 1] = line
		else
			result[#result + 1] = replace_ident_in_text(line, var_name, value)
		end
	end
	return result
end

-- 将输出变量重命名为 __tpl_ 前缀（保留 local，只改独立标识符，不改字段访问）
local function rename_ident_standalone(text, old_name, new_name)
	local out = {}
	local i = 1
	local n = #text
	while i <= n do
		local ch = text:sub(i, i)
		if ch:match("[ \t\r]") then
			out[#out + 1] = ch
			i = i + 1
		elseif ch == "-" and text:sub(i + 1, i + 1) == "-" then
			out[#out + 1] = text:sub(i)
			break
		elseif ch == "'" or ch == "\"" then
			local q = ch
			local j = i + 1
			while j <= n do
				local c = text:sub(j, j)
				if c == "\\" then
					j = j + 2
				elseif c == q then
					j = j + 1
					break
				else
					j = j + 1
				end
			end
			out[#out + 1] = text:sub(i, j - 1)
			i = j
		elseif ch == "[" then
			local eq = 0
			local k = i + 1
			while text:sub(k, k) == "=" do
				eq = eq + 1
				k = k + 1
			end
			if text:sub(k, k) == "[" then
				local close = "]"
				for _ = 1, eq do
					close = close .. "="
				end
				close = close .. "]"
				local pos = text:find(close, k + 1)
				if pos then
					out[#out + 1] = text:sub(i, pos + #close - 1)
					i = pos + #close
				else
					out[#out + 1] = ch
					i = i + 1
				end
			else
				out[#out + 1] = ch
				i = i + 1
			end
		elseif ch:match("[%a_]") then
			local j = i + 1
			while j <= n and text:sub(j, j):match("[%w_]") do
				j = j + 1
			end
			local word = text:sub(i, j - 1)
			if word == old_name then
				-- 检查是否是被 . 或 : 前缀的字段访问
				local k = i - 1
				while k >= 1 and text:sub(k, k):match("[ \t\r]") do
					k = k - 1
				end
				local prev = (k >= 1) and text:sub(k, k) or ""
				if prev ~= "." and prev ~= ":" then
					out[#out + 1] = new_name
					i = j
				else
					out[#out + 1] = word
					i = j
				end
			else
				out[#out + 1] = word
				i = j
			end
		else
			out[#out + 1] = ch
			i = i + 1
		end
	end
	return table.concat(out)
end

local function rename_output_vars(body, var_names)
	local result = body
	for _, vn in ipairs(var_names) do
		result = rename_ident_standalone(result, vn, "__tpl_" .. vn)
	end
	return result
end

-- return → goto 转换
local function transform_returns_to_assign(body, var_names, label_suffix)
	local out = {}
	local i = 1
	local n = #body
	local vs = table.concat(var_names, ", ")
	local label = "__template_end" .. (label_suffix or "")
	local hr = false
	while i <= n do
		local ch = body:sub(i, i)
		if ch:match("[ \t\r]") then
			out[#out + 1] = ch
			i = i + 1
		elseif ch == "-" and body:sub(i + 1, i + 1) == "-" then
			local nl = body:find("\n", i)
			if nl then
				out[#out + 1] = body:sub(i, nl - 1)
				i = nl
			else
				out[#out + 1] = body:sub(i)
				break
			end
		elseif ch == "'" or ch == '"' then
			local q = ch
			local j = i + 1
			while j <= n do
				local c = body:sub(j, j)
				if c == "\\" then
					j = j + 2
				elseif c == q then
					j = j + 1
					break
				else
					j = j + 1
				end
			end
			out[#out + 1] = body:sub(i, j - 1)
			i = j
		elseif ch == "[" then
			local eq = 0
			local k = i + 1
			while body:sub(k, k) == "=" do
				eq = eq + 1
				k = k + 1
			end
			if body:sub(k, k) == "[" then
				local close = "]"
				for _ = 1, eq do
					close = close .. "="
				end
				close = close .. "]"
				local pos = body:find(close, k + 1)
				if pos then
					out[#out + 1] = body:sub(i, pos + #close - 1)
					i = pos + #close
				else
					out[#out + 1] = ch
					i = i + 1
				end
			else
				out[#out + 1] = ch
				i = i + 1
			end
		elseif ch:match("[%a_]") then
			local j = i + 1
			while j <= n and body:sub(j, j):match("[%w_]") do
				j = j + 1
			end
			local word = body:sub(i, j - 1)
			if word == "return" then
				local nc = body:sub(j, j)
				if nc == "" or not nc:match("[%w_]") then
					hr = true
					local vs2 = j
					while vs2 <= n and body:sub(vs2, vs2):match("[ \t]") do
						vs2 = vs2 + 1
					end
					local ve = vs2
					while ve <= n do
						local c = body:sub(ve, ve)
						if c == "\n" or c == ";" then
							break
						end
						ve = ve + 1
					end
					local expr = body:sub(vs2, ve - 1):match("^%s*(.-)%s*$") or ""
					if #expr == 0 then
						out[#out + 1] = vs .. " = nil"
					else
						out[#out + 1] = vs .. " = " .. expr
					end
					out[#out + 1] = "\ngoto " .. label .. "\n"
					i = ve
					if i <= n and body:sub(i, i) == ";" then
						i = i + 1
					end
					if i <= n and body:sub(i, i) == "\n" then
						i = i + 1
					end
				else
					out[#out + 1] = word
					i = j
				end
			else
				out[#out + 1] = word
				i = j
			end
		else
			out[#out + 1] = ch
			i = i + 1
		end
	end
	if hr then
		out[#out + 1] = "\n::" .. label .. "::"
	end
	return table.concat(out)
end

-- 行内 template 展开
local function expand_template_in_line(line)
	if not next(M.templates) then
		return nil
	end
	local pos = line:find("template ", 1, true)
	if not pos then
		return nil
	end
	if pos > 1 then
		local p = line:sub(pos - 1, pos - 1)
		if p:match("[%w_]") then
			return nil
		end
	end
	local ns = pos + 9
	local ne = ns
	local n = #line
	while ne <= n and line:sub(ne, ne):match("[%w_]") do
		ne = ne + 1
	end
	local name = line:sub(ns, ne - 1)
	if #name == 0 or line:sub(ne, ne) ~= "(" then
		return nil
	end
	local depth = 0
	local close
	for j = ne, n do
		local c = line:sub(j, j)
		if c == "(" then
			depth = depth + 1
		elseif c == ")" then
			depth = depth - 1
			if depth == 0 then
				close = j
				break
			end
		end
	end
	if not close then
		return nil
	end
	local tpl = M.templates[name]
	if not tpl then
		return nil
	end
	local args_str = line:sub(ne + 1, close - 1)
	local args = split_args(args_str)
	local expanded = tpl.body
	for pi, pname in ipairs(tpl.params) do
		local arg = args[pi] or ""
		expanded = replace_ident_in_text(expanded, pname, arg)
	end
	local before = line:sub(1, pos - 1)
	local after = line:sub(close + 1)
	local standalone = (before:match("^%s*$") and after:match("^%s*$"))
	if standalone then
		return expanded, true, nil, nil, nil, nil
	end
	local lhs = before:match("^(.-)%s*=%s*$")
	if lhs then
		local stripped = lhs:match("^%s*(.-)%s*$")
		local vs = stripped:match("^local%s+(.*)$") or stripped
		local vns = {}
		for v in vs:gmatch("[%w_]+") do
			vns[#vns + 1] = v
		end
		if #vns > 0 then
			-- Return body separately; lhs_line, prefix, suffix will be handled by caller
			-- after rename_output_vars and transform_returns_to_assign have processed the body
			return expanded, false, vns, lhs, "do\n", "\nend\n" .. after
		end
	end
	return before .. expanded .. after, false, {}, nil, nil, nil
end

-- 作用域复制（展开 metatable 链，扁平化为一个表）
local function copy_scope(scope)
	if not scope then
		return {}
	end
	local result = {}
	local s = scope
	while s do
		for k, v in pairs(s) do
			result[k] = v
		end
		local mt = getmetatable(s)
		s = mt and mt.__index
	end
	return result
end

-- 主处理流水线
local function process_lines(lines, start, finish, env, scope_vars)
	local out = {}
	local i = start
	local pc_active = false
	local pc_include = false
	scope_vars = scope_vars or {}
	while i <= finish do
		local line = lines[i]
		if pc_active then
			local info = analyze_line(line)
			if info.directive == "at_else" then
				pc_include = not pc_include
				i = i + 1
			else
				if pc_include then
					local exp, _, vns, lhs_line, prefix, suffix = expand_template_in_line(line)
					if exp then
						local el = {}
						for eline in exp:gmatch("([^\r\n]*)\r?\n") do
							el[#el + 1] = eline
						end
						if #exp > 0 and not exp:match("\n$") then
							local last = exp:match("[^\r\n]+$")
							if last then
								el[#el + 1] = last
							end
						end
						if #el > 0 then
							local sub = process_lines(el, 1, #el, env, {})
							if vns and #vns > 0 then
								cf_counter = cf_counter + 1
								sub = rename_output_vars(sub, vns)
								sub = transform_returns_to_assign(sub, vns, "_" .. cf_counter)
							end
							if lhs_line then
								sub = lhs_line .. "\n" .. prefix .. sub .. suffix
							end
							out[#out + 1] = sub
						end
					else
						out[#out + 1] = line
					end
				end
				if i + 1 <= finish then
					local next_info = analyze_line(lines[i + 1])
					if next_info.directive == "at_else" then
						pc_include = not pc_include
						i = i + 2
						goto continue
					end
				end
				pc_active = false
				i = i + 1
			end
		else
			local exp, _, vns, lhs_line, prefix, suffix = expand_template_in_line(line)
			if exp then
				local el = {}
				for eline in exp:gmatch("([^\r\n]*)\r?\n") do
					el[#el + 1] = eline
				end
				if #exp > 0 and not exp:match("\n$") then
					local last = exp:match("[^\r\n]+$")
					if last then
						el[#el + 1] = last
					end
				end
				if #el > 0 then
					local sub = process_lines(el, 1, #el, env, {})
					if vns and #vns > 0 then
						cf_counter = cf_counter + 1
						sub = rename_output_vars(sub, vns)
						sub = transform_returns_to_assign(sub, vns, "_" .. cf_counter)
					end
					if lhs_line then
						sub = lhs_line .. "\n" .. prefix .. sub .. suffix
					end
					out[#out + 1] = sub
				end
				i = i + 1
			else
				local info = analyze_line(line)
				if info.directive == "at_constexpr" then
					pc_active = true
					pc_include = not not eval_expr(info.expr, env, scope_vars)
					i = i + 1
				elseif info.directive == "at_else" then
					if pc_active then
						pc_include = not pc_include
					end
					i = i + 1
				elseif info.directive == "stmt" then
					eval_stmt(info.expr, env, scope_vars)
					i = i + 1
				elseif info.directive == "constvar" then
					scope_vars[info.var] = eval_expr(info.expr, env, scope_vars)
					i = i + 1
				elseif info.directive == "if" then
					local cv = eval_expr(info.expr, env, scope_vars)
					local br, ei = parse_if_structure(lines, i + 1, finish)
					for bi, branch in ipairs(br) do
						local take = false
						if bi == 1 then
							take = cv
						elseif branch.type == "elseif" then
							take = eval_expr(branch.expr, env, scope_vars)
						elseif branch.type == "else" then
							take = true
						end
						if take then
							if branch.start <= branch.stop then
								local branch_scope = copy_scope(scope_vars)
								local sub = process_lines(lines, branch.start, branch.stop, env, branch_scope)
								out[#out + 1] = sub
							end
							break
						end
					end
					i = ei + 1
				elseif info.directive == "for" then
					local sv = eval_expr(info.start, env, scope_vars)
					local ev = eval_expr(info.stop, env, scope_vars)
					local stv = eval_expr(info.step, env, scope_vars)
					local fei = find_ctime_end(lines, i + 1, finish)
					local bl = {}
					for j = i + 1, fei - 1 do
						bl[#bl + 1] = lines[j]
					end
					cf_counter = cf_counter + 1
					local cf_label = "__cf_br_" .. cf_counter
					local iters = {}
					for val = sv, ev, stv do
						local subbed = replace_ident_in_lines(bl, info.var, tostring(val))
						subbed = replace_constbreak_in_lines(subbed, cf_label)
						local iter_scope = copy_scope(scope_vars)
						iters[#iters + 1] = process_lines(subbed, 1, #subbed, env, iter_scope)
					end
					out[#out + 1] = table.concat(iters, "\n")
					out[#out + 1] = "::" .. cf_label .. "::"
					i = fei + 1
				else
					out[#out + 1] = line
					i = i + 1
				end
			end
		end
		::continue::
	end
	return table.concat(out, "\n")
end

M.templates = {}

local function parse_template_func(text)
	local paren
	for i = 1, #text do
		if text:sub(i, i) == "(" then
			paren = i
			break
		end
	end
	if not paren then
		error("template must define function(...)...end")
	end
	local prefix = text:sub(1, paren - 1):match("^%s*(.-)%s*$")
	if prefix ~= "function" then
		error("template must start with 'function', got: " .. prefix)
	end
	local depth = 0
	local close
	for i = paren, #text do
		local c = text:sub(i, i)
		if c == "(" then
			depth = depth + 1
		elseif c == ")" then
			depth = depth - 1
			if depth == 0 then
				close = i
				break
			end
		end
	end
	if not close then
		error("template: unbalanced parentheses")
	end
	local ps = text:sub(paren + 1, close - 1)
	local body = text:sub(close + 1)
	body = body:match("^(.-)%s*end%s*$") or body
	return {
		params = split_args(ps),
		body = body
	}
end

function M.define(name, text)
	M.templates[name] = parse_template_func(text)
end

function M.process(template, compile_env, entity)
	if not template then
		return ""
	end
	local env = compile_env and setmetatable({
		this = entity
	}, {
		__index = compile_env
	}) or {
		this = entity
	}
	local lines = {}
	for line in template:gmatch("([^\r\n]*)\r?\n") do
		lines[#lines + 1] = line
	end
	if #template > 0 and not template:match("\n$") then
		local last = template:match("[^\r\n]+$")
		if last then
			lines[#lines + 1] = last
		end
	end
	if #lines == 0 then
		return ""
	end
	return process_lines(lines, 1, #lines, env, {})
end

return M
