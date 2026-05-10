-- 编译期模板预处理工具
local M = {}

-- byte 常量（避免重复计算）
local b_space = 32
local b_tab = 9
local b_cr = 13
local b_dash = 45
local b_squote = 39
local b_dquote = 34
local b_bslash = 92
local b_lbrack = 91
local b_rbrack = 93
local b_eq = 61
local b_lparen = 40
local b_rparen = 41
local b_comma = 44
local b_colon = 58
local b_dot = 46
local b_semic = 59
local b_newl = 10
local b_und = 95

-- 字节级判断函数（内联友好）
local function is_ws(b)
	return b == b_space or b == b_tab or b == b_cr
end
local function is_id_start(b)
	return (b >= 65 and b <= 90) or b == b_und or (b >= 97 and b <= 122)
end
local function is_id_char(b)
	return (b >= 48 and b <= 57) or (b >= 65 and b <= 90) or b == b_und or (b >= 97 and b <= 122)
end

-- Helper: 将 byte 转为 Lua 字符（必须定义在所有使用它的函数之前）
local BYTE_TO_CHAR = {}
for i = 0, 255 do
	BYTE_TO_CHAR[i] = string.char(i)
end

-- 参数拆分
local function split_args(s)
	if not s or s:match("^%s*$") then
		return {}
	end
	local parts = {}
	local depth = 0
	local buf = {}
	for k = 1, #s do
		local b = s:byte(k)
		if b == b_lparen or b == b_lbrack or b == 123 then
			depth = depth + 1
			buf[#buf + 1] = BYTE_TO_CHAR[b]
		elseif b == b_rparen or b == b_rbrack or b == 125 then
			depth = depth - 1
			buf[#buf + 1] = BYTE_TO_CHAR[b]
		elseif b == b_comma and depth == 0 then
			parts[#parts + 1] = table.concat(buf):match("^%s*(.-)%s*$")
			buf = {}
		else
			buf[#buf + 1] = BYTE_TO_CHAR[b]
		end
	end
	parts[#parts + 1] = table.concat(buf):match("^%s*(.-)%s*$")
	return parts
end

-- 行类型分析（用 string.find 替换多次 match，提前跳出）
local function analyze_line(line)
	local t = line:match("^%s*(.*)$")
	-- 用首字符快速分流
	local fb = t:byte(1)
	if not fb then
		return {
			directive = nil
		}
	end
	if fb == b_dash and t:byte(2) == b_dash then
		return {
			directive = nil
		}
	end

	-- conststmt
	if fb == 99 and t:find("^conststmt%(", 1) then
		local expr = t:match("^conststmt%((.*)%)$")
		if expr then
			M._prof.al_hits = M._prof.al_hits + 1
			return {
				directive = "stmt",
				expr = expr
			}
		end
	end
	-- constif
	if fb == 99 and t:find("^constif%(", 1) then
		local cond = t:match("^constif%((.*)%)$")
		if cond then
			M._prof.al_hits = M._prof.al_hits + 1
			return {
				directive = "if",
				expr = cond
			}
		end
	end
	-- constelseif
	if fb == 99 and t:find("^constelseif%(", 1) then
		local cond = t:match("^constelseif%((.*)%)$")
		if cond then
			M._prof.al_hits = M._prof.al_hits + 1
			return {
				directive = "elseif",
				expr = cond
			}
		end
	end
	-- constelse
	if fb == 99 and t:find("^constelse$", 1) then
		M._prof.al_hits = M._prof.al_hits + 1
		return {
			directive = "constelse"
		}
	end
	-- constend
	if fb == 99 and t:find("^constend$", 1) then
		M._prof.al_hits = M._prof.al_hits + 1
		return {
			directive = "constend"
		}
	end
	-- @constif
	if fb == 64 and t:find("^@constif%(", 1) then
		local cond = t:match("^@constif%((.*)%)$")
		if cond then
			M._prof.al_hits = M._prof.al_hits + 1
			return {
				directive = "at_constexpr",
				expr = cond
			}
		end
	end
	-- @constelse
	if fb == 64 and t:find("^@constelse$", 1) then
		M._prof.al_hits = M._prof.al_hits + 1
		return {
			directive = "at_else"
		}
	end
	-- constvar
	if fb == 99 and t:find("^constvar%s+", 1) then
		local cvn, cve = t:match("^constvar%s+(%w+)%s*=%s*(.-)$")
		if cvn then
			M._prof.al_hits = M._prof.al_hits + 1
			return {
				directive = "constvar",
				var = cvn,
				expr = cve
			}
		end
	end
	-- conststring
	if fb == 99 and t:find("^conststring%(", 1) then
		local s_expr = t:match("^conststring%((.*)%)$")
		if s_expr then
			M._prof.al_hits = M._prof.al_hits + 1
			return {
				directive = "string",
				expr = s_expr
			}
		end
	end
	-- constfor
	if fb == 99 and t:find("^constfor ", 1) then
		local vn, rest = t:match("^constfor (%w+)%s*=%s*(.+)$")
		if vn then
			rest = rest:match("^(.*)%s+do$")
			if rest then
				local parts = split_args(rest)
				M._prof.al_hits = M._prof.al_hits + 1
				return {
					directive = "for",
					var = vn,
					start = parts[1],
					stop = parts[2],
					step = parts[3] or "1"
				}
			end
		end
	end
	M._prof.al_hits = M._prof.al_hits + 1
	return {
		directive = nil
	}
end

-- 手动快速求值：覆盖 90% 常见表达式，避免 load()
-- 返回 value, handled；handled=true 表示已处理，nil 是有效结果
local function _fast_eval(expr, env)
	-- 数字
	local num = tonumber(expr)
	if num then
		return num, true
	end
	-- this.field
	local f = expr:match("^this%.(%w+)$")
	if f then
		return env.this[f], true
	end
	-- this.field.subfield
	local f1, f2 = expr:match("^this%.(%w+)%.(%w+)$")
	if f1 and f2 then
		local v = env.this[f1]
		return v and v[f2], true
	end
	-- #this.field.subfield
	local n1, n2 = expr:match("^#this%.(%w+)%.(%w+)$")
	if n1 and n2 then
		local v = env.this[n1]
		return v and #v[n2], true
	end
	-- this.a and this.a.b
	local a, b = expr:match("^this%.(%w+) and this%.%1%.(%w+)$")
	if a and b then
		local v = env.this[a]
		return v and v[b], true
	end
	-- not simple_expr (单层)
	local inner = expr:match("^not%s+(.+)$")
	if inner then
		local iv, ok = _fast_eval(inner, env)
		if ok then
			return not iv, true
		end
	end
	-- scope_vars 查表（用 byte 检查替代模式匹配）
	if env[expr] ~= nil and type(expr) == "string" then
		local ok = true
		for j = 1, #expr do
			local b = expr:byte(j)
			if not is_id_char(b) then
				ok = false
				break
			end
		end
		if ok then
			return env[expr], true
		end
	end
	return nil, false -- 无法处理
end

-- 创建求值环境
local function make_eval_env(env, scope_vars)
	if not scope_vars or not next(scope_vars) then
		return env
	end
	local eval_env = {}
	for k, v in pairs(scope_vars) do
		eval_env[k] = v
	end
	setmetatable(eval_env, {
		__index = env
	})
	return eval_env
end

-- 求值
local function eval_expr(expr, env, scope_vars)
	local eval_env = make_eval_env(env, scope_vars)
	-- 快速路径
	local r, handled = _fast_eval(expr, eval_env)
	if handled then
		M._prof.eval_total = M._prof.eval_total + 1
		M._prof.eval_fast = M._prof.eval_fast + 1
		return r
	end
	M._prof.eval_total = M._prof.eval_total + 1
	M._prof.eval_slow = M._prof.eval_slow + 1
	-- fallback：复杂表达式用 load()
	local fn, err = load("return(" .. expr .. ")", "constexpr", "t", eval_env)
	if not fn then
		error("compile_utils: constexpr error on [" .. expr .. "]: " .. err)
	end
	local ok, r = pcall(fn)
	if not ok then
		error("compile_utils: constexpr runtime error on [" .. expr .. "]: " .. tostring(r))
	end
	return r
end

local function eval_stmt(stmt, env, scope_vars)
	local eval_env = make_eval_env(env, scope_vars)
	-- inject constexpr function for use inside conststmt()
	eval_env.constexpr = function(expr)
		return eval_expr(expr, env, scope_vars)
	end
	local fn, err = load(stmt, "conststmt", "t", eval_env)
	if not fn then
		error("compile_utils: conststmt error on [" .. stmt .. "]: " .. err)
	end
	local ok, r = pcall(fn)
	if not ok then
		error("compile_utils: conststmt runtime error on [" .. stmt .. "]: " .. tostring(r))
	end
end

-- 查找 constfor/constif 的匹配 constend
local function find_ctime_end(lines, start, finish, dirs)
	local depth = 1
	for i = start, finish do
		local info = dirs and dirs[i] or analyze_line(lines[i])
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
local function parse_if_structure(lines, start, finish, dirs)
	local branches = {}
	local depth = 1
	local ct = "then"
	local cs = start
	local ce = nil
	local i = start
	while i <= finish do
		local info = dirs and dirs[i] or analyze_line(lines[i])
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

-- 字节级 tokenizer：提取下一个单词
local function scan_word(text, i, n)
	local j = i + 1
	while j <= n and is_id_char(text:byte(j)) do
		j = j + 1
	end
	return text:sub(i, j - 1), j
end

-- 字节级 tokenizer：跳过字符串字面量
local function skip_string(text, i, n)
	local q = text:byte(i)
	local j = i + 1
	while j <= n do
		local bc = text:byte(j)
		if bc == b_bslash then
			j = j + 2
		elseif bc == q then
			return j + 1
		else
			j = j + 1
		end
	end
	return j
end

-- 字节级 tokenizer：跳过长括号字面量
local function skip_longbracket(text, i, n)
	local eq = 0
	local k = i + 1
	while text:byte(k) == b_eq do
		eq = eq + 1
		k = k + 1
	end
	if text:byte(k) == b_lbrack then
		local close = "]"
		for _ = 1, eq do
			close = close .. "="
		end
		close = close .. "]"
		local pos = text:find(close, k + 1, true)
		if pos then
			return pos + #close
		end
		return n + 1
	end
	return i + 1
end

-- 分词安全的标识符替换
local function replace_ident_in_text(text, var_name, value)
	local out = {}
	local i = 1
	local n = #text
	while i <= n do
		local b = text:byte(i)
		if is_ws(b) then
			out[#out + 1] = BYTE_TO_CHAR[b]
			i = i + 1
		elseif b == b_dash and text:byte(i + 1) == b_dash then
			out[#out + 1] = text:sub(i)
			break
		elseif b == b_squote or b == b_dquote then
			local j = skip_string(text, i, n)
			out[#out + 1] = text:sub(i, j - 1)
			i = j
		elseif b == b_lbrack then
			local j = skip_longbracket(text, i, n)
			out[#out + 1] = text:sub(i, j - 1)
			i = j
		elseif is_id_start(b) then
			local word, j = scan_word(text, i, n)
			if word == var_name then
				out[#out + 1] = value
			else
				out[#out + 1] = word
			end
			i = j
		else
			out[#out + 1] = BYTE_TO_CHAR[b]
			i = i + 1
		end
	end
	return table.concat(out)
end

-- 检查字符前面是否被 . 或 : 前缀（跳过空白）
local function is_preceded_by_dot_colon(text, i)
	local k = i - 1
	while k >= 1 and is_ws(text:byte(k)) do
		k = k - 1
	end
	if k >= 1 then
		local pb = text:byte(k)
		return pb == b_dot or pb == b_colon
	end
	return false
end

-- 将输出变量重命名为 __tpl_ 前缀（保留 local，只改独立标识符，不改字段访问）
local function rename_output_vars(body, var_names)
	if not var_names or #var_names == 0 then
		return body
	end
	-- 构建重命名映射表
	local rename = {}
	for vi = 1, #var_names do
		rename[var_names[vi]] = "__tpl_" .. var_names[vi]
	end
	-- 单次遍历完成所有重命名
	local out = {}
	local i = 1
	local n = #body
	while i <= n do
		local b = body:byte(i)
		if is_ws(b) then
			out[#out + 1] = BYTE_TO_CHAR[b]
			i = i + 1
		elseif b == b_dash and body:byte(i + 1) == b_dash then
			out[#out + 1] = body:sub(i)
			break
		elseif b == b_squote or b == b_dquote then
			local j = skip_string(body, i, n)
			out[#out + 1] = body:sub(i, j - 1)
			i = j
		elseif b == b_lbrack then
			local j = skip_longbracket(body, i, n)
			out[#out + 1] = body:sub(i, j - 1)
			i = j
		elseif is_id_start(b) then
			local word, j = scan_word(body, i, n)
			local new_name = rename[word]
			if new_name then
				if not is_preceded_by_dot_colon(body, i) then
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
			out[#out + 1] = BYTE_TO_CHAR[b]
			i = i + 1
		end
	end
	return table.concat(out)
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
		local b = body:byte(i)
		if is_ws(b) then
			out[#out + 1] = BYTE_TO_CHAR[b]
			i = i + 1
		elseif b == b_dash and body:byte(i + 1) == b_dash then
			local nl = body:find("\n", i, true)
			if nl then
				out[#out + 1] = body:sub(i, nl - 1)
				i = nl
			else
				out[#out + 1] = body:sub(i)
				break
			end
		elseif b == b_squote or b == b_dquote then
			local j = skip_string(body, i, n)
			out[#out + 1] = body:sub(i, j - 1)
			i = j
		elseif b == b_lbrack then
			local j = skip_longbracket(body, i, n)
			out[#out + 1] = body:sub(i, j - 1)
			i = j
		elseif is_id_start(b) then
			local word, j = scan_word(body, i, n)
			if word == "return" then
				local nc = body:byte(j)
				if not nc or not is_id_char(nc) then
					hr = true
					local vs2 = j
					while vs2 <= n and (body:byte(vs2) == b_space or body:byte(vs2) == b_tab) do
						vs2 = vs2 + 1
					end
					local ve = vs2
					while ve <= n do
						local bc = body:byte(ve)
						if bc == b_newl or bc == b_semic then
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
					if i <= n and body:byte(i) == b_semic then
						i = i + 1
					end
					if i <= n and body:byte(i) == b_newl then
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
			out[#out + 1] = BYTE_TO_CHAR[b]
			i = i + 1
		end
	end
	if hr then
		out[#out + 1] = "\n::" .. label .. "::"
	end
	return table.concat(out)
end

-- ====== 指令流架构：parse 阶段生成指令列表（缓存），eval 阶段逐指令执行 ======
-- 指令类型: txt, if, for, stmt, var, at, tpl

-- 扫描单行中的 template 调用
local function _scan_tpl(line)
	if not next(M.templates) then
		return nil
	end
	local pos = line:find("template ", 1, true)
	if not pos then
		return nil
	end
	M._prof.tpl_find = M._prof.tpl_find + 1
	if pos > 1 then
		local pb = line:byte(pos - 1)
		if is_id_char(pb) then
			return nil
		end
	end
	local ns, ne, n = pos + 9, pos + 9, #line
	while ne <= n and is_id_char(line:byte(ne)) do
		ne = ne + 1
	end
	local name = line:sub(ns, ne - 1)
	if #name == 0 or line:byte(ne) ~= b_lparen then
		return nil
	end
	local depth, close = 0, nil
	for j = ne, n do
		local bc = line:byte(j)
		if bc == b_lparen then
			depth = depth + 1
		elseif bc == b_rparen then
			depth = depth - 1
			if depth == 0 then
				close = j
				break
			end
		end
	end
	if not close or not M.templates[name] then
		return nil
	end
	local before, after = line:sub(1, pos - 1), line:sub(close + 1)
	local lhs = before:match("^(.-)%s*=%s*$")
	if not lhs then
		if before:match("^%s*$") and after:match("^%s*$") then
			return name
		end
		return nil
	end
	local vs = (lhs:match("^%s*(.-)%s*$")):match("^local%s+(.*)$") or lhs:match("^%s*(.-)%s*$")
	local vns = {}
	for v in vs:gmatch("[%w_]+") do
		vns[#vns + 1] = v
	end
	return name, vns, lhs
end

-- 编译指令流（一次调用，返回 insts）
local function compile_insts(lines, start, finish, dirs)
	local insts, i = {}, start
	while i <= finish do
		local d, dt = dirs[i], dirs[i].directive
		if dt == "if" then
			local bdata = dirs._if[i]
			local br, ei = bdata[1], bdata[2]
			local then_i, else_i
			if br[1] and br[1].start <= br[1].stop then
				then_i = compile_insts(lines, br[1].start, br[1].stop, dirs)
			end
			if br[2] and br[2].start <= br[2].stop then
				else_i = compile_insts(lines, br[2].start, br[2].stop, dirs)
			end
			insts[#insts + 1] = {
				t = "if",
				expr = d.expr,
				then_i = then_i,
				else_i = else_i
			}
			i = ei + 1
		elseif dt == "for" then
			local ei = dirs._for[i]
			local has_cb = false
			for j = i + 1, ei - 1 do
				if lines[j]:find("constbreak", 1, true) then
					has_cb = true
					break
				end
			end
			local body = compile_insts(lines, i + 1, ei - 1, dirs)
			insts[#insts + 1] = {
				t = "for",
				var = d.var,
				start = d.start,
				stop = d.stop,
				step = d.step,
				body = body,
				has_cb = has_cb
			}
			i = ei + 1
		elseif dt == "stmt" then
			insts[#insts + 1] = {
				t = "stmt",
				expr = d.expr
			}
			i = i + 1
		elseif dt == "constvar" then
			insts[#insts + 1] = {
				t = "var",
				vname = d.var,
				expr = d.expr
			}
			i = i + 1
		elseif dt == "string" then
			insts[#insts + 1] = {
				t = "string",
				expr = d.expr
			}
			i = i + 1
		elseif dt == "at_constexpr" then
			local t_line = (i + 1 <= finish) and lines[i + 1] or ""
			local e_line, skip = "", 2
			if i + 2 <= finish and dirs[i + 2].directive == "at_else" then
				e_line = (i + 3 <= finish) and lines[i + 3] or ""
				skip = 4
			end
			local t_tpl = {_scan_tpl(t_line)}
			local e_tpl = (e_line ~= "" and {_scan_tpl(e_line)} or nil)
			insts[#insts + 1] = {
				t = "at",
				expr = d.expr,
				t_line = t_line,
				e_line = e_line,
				t_tpl = t_tpl[1] and t_tpl,
				e_tpl = e_tpl and e_tpl[1] and e_tpl
			}
			i = i + skip
		elseif dt == "at_else" then
			i = i + 1
		else
			local tpl_name, vns, lhs = _scan_tpl(lines[i])
			if tpl_name then
				insts[#insts + 1] = {
					t = "tpl",
					name = tpl_name,
					vns = vns,
					lhs = lhs,
					line = lines[i]
				}
			else
				insts[#insts + 1] = {
					t = "txt",
					v = lines[i] .. "\n"
				}
			end
			i = i + 1
		end
	end
	return insts
end

-- Forward declaration for mutual recursion with _exec_tpl
local _exec_tpl

-- 执行指令流，追加到 out 表
local function exec_insts(insts, env, scope_vars, out, subs)
	scope_vars = scope_vars or {}
	subs = subs or {}
	local _cache = {}
	if not insts then
		return
	end
	local function _eval(e)
		-- 先应用 subs 替换（constfor 循环变量等）
		if subs and next(subs) then
			for k, v in pairs(subs) do
				if e:find(k, 1, true) then
					e = replace_ident_in_text(e, k, v)
				end
			end
		end
		local v = _cache[e]
		if v ~= nil then
			return v
		end
		v = eval_expr(e, env, scope_vars)
		_cache[e] = v
		return v
	end
	for _, inst in ipairs(insts) do
		local t = inst.t
		if t == "txt" then
			local text = inst.v
			for k, v in pairs(subs) do
				text = replace_ident_in_text(text, k, v)
			end
			out[#out + 1] = text
		elseif t == "if" then
			exec_insts(_eval(inst.expr) and inst.then_i or inst.else_i, env, scope_vars, out, subs)
		elseif t == "for" then
			local sv, ev, stv = _eval(inst.start), _eval(inst.stop), _eval(inst.step)
			cf_counter = cf_counter + 1
			local label = "__cf_br_" .. cf_counter
			for val = sv, ev, stv do
				local s2 = {}
				for k, v in pairs(subs) do
					s2[k] = v
				end
				s2[inst.var] = tostring(val)
				s2["constbreak"] = "goto " .. label
				exec_insts(inst.body, env, scope_vars, out, s2)
			end
			if inst.has_cb then
				out[#out + 1] = "::" .. label .. "::\n"
			end
		elseif t == "stmt" then
			eval_stmt(inst.expr, env, scope_vars)
		elseif t == "var" then
			scope_vars[inst.vname] = _eval(inst.expr)
		elseif t == "string" then
			out[#out + 1] = tostring(_eval(inst.expr))
		elseif t == "at" then
			local take = _eval(inst.expr)
			local line = take and inst.t_line or inst.e_line
			if line and line ~= "" then
				local tpl_info = take and inst.t_tpl or inst.e_tpl
				if tpl_info then
					local tpl = M.templates[tpl_info[1]]
					if tpl then
						_exec_tpl(tpl, {
							vns = tpl_info[2],
							lhs = tpl_info[3]
						}, env, scope_vars, out)
					end
				else
					out[#out + 1] = line .. "\n"
				end
			end
		elseif t == "tpl" then
			local tpl = M.templates[inst.name]
			if tpl then
				_exec_tpl(tpl, inst, env, scope_vars, out)
			end
		end
	end
end

-- 执行模板展开
_exec_tpl = function(tpl, info, env, scope_vars, out)
	-- 确保 template body 有缓存指令流
	if not tpl._insts then
		local lines = {}
		for eline in tpl.body:gmatch("([^\r\n]*)\r?\n") do
			lines[#lines + 1] = eline
		end
		if #tpl.body > 0 and not tpl.body:match("\n$") then
			local last = tpl.body:match("[^\r\n]+$")
			if last then
				lines[#lines + 1] = last
			end
		end
		local dirs = {}
		for i = 1, #lines do
			dirs[i] = analyze_line(lines[i])
		end
		dirs._if = {}
		dirs._for = {}
		for i = 1, #lines do
			local d = dirs[i]
			if d.directive == "if" then
				local br, ei = parse_if_structure(lines, i + 1, #lines, dirs)
				dirs._if[i] = {br, ei}
			end
			if d.directive == "for" then
				dirs._for[i] = find_ctime_end(lines, i + 1, #lines, dirs)
			end
		end
		tpl._insts = compile_insts(lines, 1, #lines, dirs)
	end
	-- 生成代码
	local inner = {}
	exec_insts(tpl._insts, env, scope_vars, inner)
	local sub = table.concat(inner)
	local vns, lhs = info and info.vns, info and info.lhs
	if vns and #vns > 0 then
		cf_counter = cf_counter + 1
		local t0 = os.clock()
		sub = rename_output_vars(sub, vns)
		M._prof.rename_dt = M._prof.rename_dt + (os.clock() - t0)
		M._prof.rename_count = M._prof.rename_count + 1
		local t1 = os.clock()
		sub = transform_returns_to_assign(sub, vns, "_" .. cf_counter)
		M._prof.xret_dt = M._prof.xret_dt + (os.clock() - t1)
		M._prof.xret_count = M._prof.xret_count + 1
	end
	if lhs then
		sub = lhs .. "\ndo\n" .. sub .. "\nend\n"
	end
	out[#out + 1] = sub
end

-- 模板字符串 → 指令流缓存
local _inst_cache = setmetatable({}, {
	__mode = "k"
})
local function get_insts(template)
	local insts = _inst_cache[template]
	if insts then
		return insts
	end
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
	local dirs = {}
	for i = 1, #lines do
		dirs[i] = analyze_line(lines[i])
	end
	dirs._if = {}
	dirs._for = {}
	for i = 1, #lines do
		local d = dirs[i]
		if d.directive == "if" then
			local br, ei = parse_if_structure(lines, i + 1, #lines, dirs)
			dirs._if[i] = {br, ei}
		end
		if d.directive == "for" then
			dirs._for[i] = find_ctime_end(lines, i + 1, #lines, dirs)
		end
	end
	insts = compile_insts(lines, 1, #lines, dirs)
	_inst_cache[template] = insts
	return insts
end

local function exec_insts_outer(insts, env, scope_vars)
	local out = {}
	exec_insts(insts, env, scope_vars, out)
	return table.concat(out)
end

M.templates = {}

local function parse_template_func(text)
	local paren
	for i = 1, #text do
		if text:byte(i) == b_lparen then
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
		local c = text:byte(i)
		if c == b_lparen then
			depth = depth + 1
		elseif c == b_rparen then
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
	local t0 = os.clock()
	local insts = get_insts(template)
	M._prof.parse_dt = M._prof.parse_dt + (os.clock() - t0)
	local t1 = os.clock()
	local result = exec_insts_outer(insts, env, {})
	M._prof.proc_dt = M._prof.proc_dt + (os.clock() - t1)
	M._prof.calls = M._prof.calls + 1
	return result
end

-- profiling counters（设置 M.PROFILE = true 开启）
M.PROFILE = false
M._prof = {}
setmetatable(M._prof, {
	__index = function()
		return 0
	end
})

function M.profile_report()
	if not M.PROFILE then
		return
	end
	local p = M._prof
	print("=== Precompile Profile ===")
	print(string.format("  calls:                 %d", p.calls))
	print(string.format("  parse_template:        %.3f ms", p.parse_dt * 1000))
	print(string.format("  process_lines:         %.3f ms", p.proc_dt * 1000))
	print(string.format("  eval_expr total:       %d (fast=%d slow=%d)", p.eval_total, p.eval_fast, p.eval_slow))
	print(string.format("  rename_output_vars:    %d (%.3f ms)", p.rename_count, p.rename_dt * 1000))
	print(string.format("  transform_returns:     %d (%.3f ms)", p.xret_count, p.xret_dt * 1000))
	print(string.format("  analyze_line hits:     %d", p.al_hits))
	print(string.format("  line-find template:    %d", p.tpl_find))
end

return M
