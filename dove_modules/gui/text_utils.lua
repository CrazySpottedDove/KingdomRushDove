local M = {}

-- 颜色配置
M.COLORS = {
	OLD_VALUE = {255, 100, 100}, -- 旧数值颜色（红色）
	NEW_VALUE = {100, 255, 100}, -- 新数值颜色（绿色）
	ARROW = {200, 200, 150} -- 箭头颜色
}

-- 提取文本中的所有数字及其位置
local function extract_numbers(text)
	local numbers = {}
	local pos = 1

	while pos <= #text do
		-- 匹配数字（包括小数）
		local num_start, num_end, num_str = string.find(text, "(%d+%.?%d*)", pos)

		if num_start then
			table.insert(numbers, {
				value = tonumber(num_str),
				str = num_str,
				start_pos = num_start,
				end_pos = num_end
			})
			pos = num_end + 1
		else
			break
		end
	end

	return numbers
end

-- 查找两段文本中变化的数值
-- 返回：{old_numbers, new_numbers, diff_indices}
local function find_number_diffs(text1, text2)
	local nums1 = extract_numbers(text1)
	local nums2 = extract_numbers(text2)

	local diff_indices = {}

	-- 简单策略：逐个比较相同位置的数字
	local min_count = math.min(#nums1, #nums2)

	for i = 1, min_count do
		if nums1[i].value ~= nums2[i].value then
			table.insert(diff_indices, {true, i})
		else
			table.insert(diff_indices, {false, i})
		end
	end

	-- 如果数字数量不同，标记额外的数字
	if #nums1 > min_count then
		for i = min_count + 1, #nums1 do
			table.insert(diff_indices, {true, i})
		end
	end
	if #nums2 > min_count then
		for i = min_count + 1, #nums2 do
			table.insert(diff_indices, {true, i})
		end
	end

	return nums1, nums2, diff_indices
end

--- 把文本中的数字标上颜色
---@param text string 原始文本
---@param color table? {r, g, b} 255颜色值，默认为绿色
function M.mark_number(text, color)
	color = color or M.COLORS.NEW_VALUE
	local numbers = extract_numbers(text)
	local result = text
	local offset = 0

	for _, num in ipairs(numbers) do
		local colored_num = string.format("{c:%d,%d,%d}%s{/c}", color[1], color[2], color[3], num.str)

		result = string.sub(result, 1, num.start_pos + offset - 1) .. colored_num .. string.sub(result, num.end_pos + offset + 1)

		offset = offset + (#colored_num - #num.str)
	end

	return result
end

-- 创建带颜色标记的对比文本
-- @param text1 旧文本（当前级）
-- @param text2 新文本（下一级）
-- @return 富文本字符串
function M.create_diff_text(text1, text2, color_old, color_new)
	color_old = color_old or M.COLORS.OLD_VALUE
	color_new = color_new or M.COLORS.NEW_VALUE
	if not text1 or not text2 then
		return text2 or text1 or ""
	end

	local nums1, nums2, diff_indices = find_number_diffs(text1, text2)

	-- 如果没有数值变化，直接返回新文本
	if #diff_indices == 0 then
		return text2
	end

	-- 收集所有需要替换的位置和内容
	local replacements = {}

	for _, t in ipairs(diff_indices) do
		local num1 = nums1[t[2]]
		local num2 = nums2[t[2]]

		if num1 and num2 then
			if t[1] then
				-- 构造替换文本：{c:r,g,b}旧值{/c}→{c:r,g,b}新值{/c}
				local old_colored = string.format("{c:%d,%d,%d}%s{/c}", color_old[1], color_old[2], color_old[3], num1.str)
				local arrow = "→"
				local new_colored = string.format("{c:%d,%d,%d}%s{/c}", color_new[1], color_new[2], color_new[3], num2.str)

				local replacement = old_colored .. arrow .. new_colored

				table.insert(replacements, {
					start_pos = num2.start_pos,
					end_pos = num2.end_pos,
					replacement = replacement
				})
			else
				-- 数值相同，直接保留新文本中的数值
				local new_colored = string.format("{c:%d,%d,%d}%s{/c}", color_new[1], color_new[2], color_new[3], num2.str)

				table.insert(replacements, {
					start_pos = num2.start_pos,
					end_pos = num2.end_pos,
					replacement = new_colored
				})
			end
		elseif (num2 and not num1) then
			-- 新增的数值，直接标绿
			local new_colored = string.format("{c:%d,%d,%d}%s{/c}", color_new[1], color_new[2], color_new[3], num2.str)

			table.insert(replacements, {
				start_pos = num2.start_pos,
				end_pos = num2.end_pos,
				replacement = new_colored
			})
		end
	end

	-- 从后往前替换，避免位置错乱
	table.sort(replacements, function(a, b)
		return a.start_pos > b.start_pos
	end)

	local result = text2
	for _, repl in ipairs(replacements) do
		result = string.sub(result, 1, repl.start_pos - 1) .. repl.replacement .. string.sub(result, repl.end_pos + 1)
	end

	return result
end

-- 简化版本：直接拼接两段文本，用箭头分隔
-- 适用于文本结构完全不同的情况
function M.create_simple_comparison(text1, text2)
	if not text1 or not text2 then
		return text2 or text1 or ""
	end

	return text1 .. "\n→\n" .. text2
end

-- 创建紧凑的对比文本（适合tooltip）
-- 只高亮数值，不显示完整旧文本
function M.create_compact_diff(text1, text2)
	if not text1 or not text2 then
		return text2 or text1 or ""
	end

	local _, nums2, diff_indices = find_number_diffs(text1, text2)

	-- 如果没有变化，返回新文本
	if #diff_indices == 0 then
		return text2
	end

	-- 收集所有需要替换的位置
	local replacements = {}

	for _, t in ipairs(diff_indices) do
		local num2 = nums2[t[2]]

		if num2 then
			local new_colored = string.format("{c:%d,%d,%d}%s{/c}", M.COLORS.NEW_VALUE[1], M.COLORS.NEW_VALUE[2], M.COLORS.NEW_VALUE[3], num2.str)

			table.insert(replacements, {
				start_pos = num2.start_pos,
				end_pos = num2.end_pos,
				replacement = new_colored
			})
		end
	end

	-- 从后往前替换
	table.sort(replacements, function(a, b)
		return a.start_pos > b.start_pos
	end)

	local result = text2
	for _, repl in ipairs(replacements) do
		result = string.sub(result, 1, repl.start_pos - 1) .. repl.replacement .. string.sub(result, repl.end_pos + 1)
	end

	return result
end

return M
