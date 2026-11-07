-- 世代旧编号映射：仅用于存档迁移、资源改名脚本与一次性兼容。
-- 运行时禁止用旧全局关卡号做逻辑判断。
local legacy = {}

-- 旧 GS 编号域 -> (gen_id, local_idx)
legacy.ranges = {{
	gen_id = "kr1",
	from = 1,
	to = 26,
	local_from = 1
}, {
	gen_id = "kr1",
	from = 1000,
	to = 1000,
	local_from = 27
}, {
	gen_id = "kr2",
	from = 27,
	to = 48,
	local_from = 1
}, {
	gen_id = "kr3",
	from = 49,
	to = 70,
	local_from = 1
}, {
	gen_id = "kr5",
	from = 101,
	to = 140,
	local_from = 1
}, {
	gen_id = "kr6",
	from = 201,
	to = 218,
	local_from = 1
}}

--- 旧全局关卡号 -> (gen_id, local_idx)
---@param global_idx number
---@return string|nil gen_id
---@return number|nil local_idx
function legacy.to_ref(global_idx)
	for _, range in ipairs(legacy.ranges) do
		if global_idx >= range.from and global_idx <= range.to then
			return range.gen_id, range.local_from + (global_idx - range.from)
		end
	end

	return nil, nil
end

--- (gen_id, local_idx) -> 旧全局关卡号
---@param gen_id string
---@param local_idx number
---@return number|nil
function legacy.to_global(gen_id, local_idx)
	for _, range in ipairs(legacy.ranges) do
		if range.gen_id == gen_id then
			local global_idx = range.from + (local_idx - range.local_from)

			if global_idx >= range.from and global_idx <= range.to then
				return global_idx
			end
		end
	end

	return nil
end

--- (gen_id, local_idx) -> 旧关卡文件名（资源局部化完成前过渡使用）
---@param gen_id string
---@param local_idx number
---@return string
function legacy.level_name(gen_id, local_idx)
	return string.format("level_%s_%03d", gen_id, local_idx)
end

--- 旧数字 generation -> 字符串 id
---@param generation number|string
---@return string
function legacy.to_gen_id(generation)
	if generation == 1 then
		return "kr1"
	elseif generation == 2 then
		return "kr2"
	elseif generation == 3 then
		return "kr3"
	elseif generation == 5 then
		return "kr5"
	elseif generation == 6 then
		return "kr6"
	end

	return generation
end

return legacy
