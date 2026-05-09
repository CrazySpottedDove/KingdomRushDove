--- 为 component 生成优化的克隆函数。
--- 因为 components 一旦注册就永不修改，所以可以安全地在编译时分析其结构，
--- 生成直接构造克隆体的代码，避免运行时 pairs 遍历和递归 deepclone 的开销。

local M = {}

-- 判断一个 table 是否能被安全地内联为字面量（所有值都是标量，不含子表或 cdata）
local function is_simple_literal(t)
	for _, v in pairs(t) do
		local tv = type(v)
		if tv == "table" or tv == "cdata" then
			return false
		end
	end
	return true
end

-- 将简单字面量表内联为 Lua 代码
local function literal_to_code(t)
	local tk = type(t)
	if tk == "number" then
		return tostring(t)
	elseif tk == "string" then
		return ("%q"):format(t)
	elseif tk == "boolean" then
		return tostring(t)
	elseif tk == "nil" then
		return "nil"
	elseif tk == "table" then
		local is_array = true
		local max_n = 0
		for k in pairs(t) do
			if type(k) ~= "number" or k ~= math.floor(k) or k < 1 then
				is_array = false
			end
			if type(k) == "number" and k > max_n then
				max_n = k
			end
		end

		if is_array and max_n > 0 then
			local keys = {}
			for k in pairs(t) do
				keys[#keys + 1] = k
			end
			if #keys ~= max_n then
				is_array = false
			end
		end

		if is_array and max_n > 0 then
			local parts = {}
			for i = 1, max_n do
				if t[i] ~= nil then
					parts[#parts + 1] = literal_to_code(t[i])
				else
					parts[#parts + 1] = "nil"
				end
			end
			return "{" .. table.concat(parts, ", ") .. "}"
		else
			local parts = {}
			local sorted_keys = {}
			for k in pairs(t) do
				sorted_keys[#sorted_keys + 1] = k
			end
			table.sort(sorted_keys, function(a, b)
				if type(a) ~= type(b) then
					return type(a) < type(b)
				end
				return a < b
			end)

			for _, k in ipairs(sorted_keys) do
				local k_code
				if type(k) == "string" and k:match("^[%w_]+$") then
					k_code = k
				else
					k_code = "[" .. literal_to_code(k) .. "]"
				end
				parts[#parts + 1] = k_code .. " = " .. literal_to_code(t[k])
			end
			return "{" .. table.concat(parts, ", ") .. "}"
		end
	else
		return nil
	end
end

--- 递归生成一个值的克隆表达式。
--- 对简单值返回字面量代码，对表递归展开为内联构造器。
---@param v any 当前值
---@param tpl_path table tpl 访问路径，如 {"sprites", 1, "anchor"} 表示 tpl["sprites"][1]["anchor"]
---@return string|nil Lua 表达式代码
local function gen_value(v, tpl_path)
	local tk = type(v)

	if tk == "number" then
		return tostring(v)
	elseif tk == "string" then
		return ("%q"):format(v)
	elseif tk == "boolean" then
		return tostring(v)
	elseif tk == "nil" then
		return nil
	elseif tk == "cdata" then
		-- 沿着 tpl_path 生成 tpl["k1"]["k2"]:clone() 路径
		local path = ""
		for _, key in ipairs(tpl_path) do
			if type(key) == "string" then
				path = path .. "[" .. ("%q"):format(key) .. "]"
			else
				path = path .. "[" .. tostring(key) .. "]"
			end
		end
		return "tpl" .. path .. ":clone()"
	elseif tk == "table" then
		if not next(v) then
			return "{}"
		elseif is_simple_literal(v) then
			return literal_to_code(v)
		else
			-- 复杂表：递归展开，生成内联构造器
			local parts = {}
			for k, vv in pairs(v) do
				local sub_path = {}
				for _, p in ipairs(tpl_path) do
					sub_path[#sub_path + 1] = p
				end
				sub_path[#sub_path + 1] = k

				local sub_expr = gen_value(vv, sub_path)
				if sub_expr then
					local cons_key
					if type(k) == "string" and k:match("^[%w_]+$") then
						cons_key = k
					elseif type(k) == "string" then
						cons_key = "[" .. ("%q"):format(k) .. "]"
					else
						cons_key = "[" .. tostring(k) .. "]"
					end
					parts[#parts + 1] = cons_key .. " = " .. sub_expr
				end
			end

			if #parts == 0 then
				return "{}"
			end
			return "{" .. table.concat(parts, ", ") .. "}"
		end
	end

	return nil
end

--- 为一个 component 生成优化的克隆函数代码
---@param comp_name string 组件名称
---@param comp_table table|userdata 组件表或 ffi cdata
---@return string 生成的 Lua 代码，load 后返回 function(tpl) ... end
function M.generate(comp_name, comp_table)
	-- 处理 ffi cdata 组件（通过 register_c_ffi 注册的）
	if type(comp_table) ~= "table" then
		return ("-- compiled cloner for ffi component %q\n" .. "return function(tpl)\n" .. "\treturn tpl:clone()\n" .. "end"):format(comp_name)
	end

	-- 递归展开整个组件表
	-- 顶层路径为空，gen_value 遇到 cdata 时直接生成 "tpl:clone()"
	local parts = {}
	for k, v in pairs(comp_table) do
		local sub_path = {k}
		local sub_expr = gen_value(v, sub_path)
		if sub_expr then
			local cons_key
			if type(k) == "string" and k:match("^[%w_]+$") then
				cons_key = k
			elseif type(k) == "string" then
				cons_key = "[" .. ("%q"):format(k) .. "]"
			else
				cons_key = "[" .. tostring(k) .. "]"
			end
			parts[#parts + 1] = cons_key .. " = " .. sub_expr
		end
	end

	local body = "return function(tpl)\n"
	if #parts == 0 then
		body = body .. "\treturn {}\n"
	else
		body = body .. "\treturn {"
		for i, part in ipairs(parts) do
			if i > 1 then
				body = body .. ","
			end
			body = body .. "\n\t\t" .. part
		end
		body = body .. "\n\t}\n"
	end
	body = body .. "end"

	return body
end

--- 为所有 components 生成克隆函数，并返回 {name = func} 的表
---@param components table entity_db.components
---@param env table 编译环境（用于 load 生成的代码）
---@return table {name = function} mapping
function M.compile_all(components, env)
	local cloners = {}

	for name, comp in pairs(components) do
		local code = M.generate(name, comp)
		-- print(code)
		local chunk, err = load(code, ("=[cloner:%s]"):format(name), "t", env)
		if not chunk then
			error(("Failed to compile cloner for component %q: %s"):format(name, err))
		end
		cloners[name] = chunk()
	end

	return cloners
end

return M
