--- 加载构建期生成的优化脚本
local M = {}

local entries = {}
local loaded = false

local function read_file(path)
	if love and love.filesystem and love.filesystem.read then
		local content = love.filesystem.read(path)
		if content then
			return content
		end
	end
	local file = io.open(path, "rb")
	if not file then
		return nil
	end
	local content = file:read("*a")
	file:close()
	return content
end

local function load_module(path, env)
	local source = read_file(path)
	if not source then
		return nil, "missing " .. path
	end
	local chunk, err = load(source, "@" .. path, "t", env)
	if not chunk then
		return nil, err
	end
	local ok, result = pcall(chunk)
	if not ok then
		return nil, result
	end
	return result
end

function M.load(env)
	if loaded then
		return true
	end
	loaded = true

	local index, err = load_module("precompile/generated/index.lua", env)
	if not index then
		print("precompile: 未加载生成脚本: " .. tostring(err))
		return false
	end

	for _, name in ipairs(index) do
		local module, module_err = load_module("precompile/generated/" .. name .. ".lua", env)
		if not module then
			print("precompile: 生成脚本加载失败 " .. name .. ": " .. tostring(module_err))
		elseif name == "shared" then
			env.__pc_functions = module
		else
			for entity_name, entry in pairs(module) do
				local target = entries[entity_name]
				if not target then
					target = {}
					entries[entity_name] = target
				end
				for key, value in pairs(entry) do
					target[key] = value
				end
			end
		end
	end

	env.__pc_functions = nil

	return true
end

function M.get(entity_name)
	return entries[entity_name]
end

return M
