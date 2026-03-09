-- add_ref_scale.lua
-- 用法: lua add_ref_scale.lua <input_file> <ref_scale> [output_file]
-- 为 Lua 图集文件中的每个顶层表条目添加 ref_scale 字段
-- 若未指定 output_file，则原地修改输入文件

local input_file = arg[1]
local ref_scale_str = arg[2]
local output_file = arg[3] or arg[1]

if not input_file or not ref_scale_str then
	print("用法: lua add_ref_scale.lua <input_file> <ref_scale> [output_file]")
	print("示例: lua add_ref_scale.lua go_hero_dragon_sun.lua 1.5")
	os.exit(1)
end

local ref_scale = tonumber(ref_scale_str)
if not ref_scale then
	print("错误: ref_scale 必须是数字，得到的是: " .. ref_scale_str)
	os.exit(1)
end

-- 将数字格式化为 Lua 字面量（整数不带小数点，浮点数保留精度）
local function format_number(n)
	if n == math.floor(n) then
		return string.format("%d", n)
	else
		return tostring(n)
	end
end

local ref_scale_value = format_number(ref_scale)

local f = assert(io.open(input_file, "r"), "无法打开文件: " .. input_file)
local lines = {}
for line in f:lines() do
	lines[#lines + 1] = line
end
f:close()

local output_lines = {}
local added = 0
local skipped = 0

local i = 1
while i <= #lines do
	local line = lines[i]

	-- 检测顶层条目的闭合行：仅有一个 tab + "}" 加可选逗号
	if line:match("^\t}[,]?$") then
		-- 向前查找是否已存在 ref_scale
		local already_has = false
		for j = math.max(1, i - 20), i - 1 do
			if lines[j]:match("^\t\tref_scale%s*=") then
				already_has = true
				break
			end
		end

		if already_has then
			skipped = skipped + 1
		else
			output_lines[#output_lines + 1] = "\t\t,ref_scale = " .. ref_scale_value
			added = added + 1
		end
	end

	output_lines[#output_lines + 1] = line
	i = i + 1
end

local out = assert(io.open(output_file, "w"), "无法写入文件: " .. output_file)
out:write(table.concat(output_lines, "\n"))
-- 保留原文件末尾换行
if lines[#lines] ~= nil then
	out:write("\n")
end
out:close()

print(string.format("完成：已添加 %d 个 ref_scale = %s，跳过 %d 个已存在的条目", added, ref_scale_value, skipped))
print("输出文件: " .. output_file)
