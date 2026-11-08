-- 标准世代的描述符构造器。5 个本体世代共用，避免重复字段。
local V = require("lib.klua.vector")
local v = V.v

local common = {}

local function count_stars(ranges)
	local total = 0

	for _, range in ipairs(ranges) do
		if #range == 2 then
			total = total + (range[2] - range[1] + 1) * 5
		else
			total = total + 5
		end
	end

	return total
end

--- 由关卡范围推导关卡总数、主线末关与满星数。
--- ranges 必须从 1 开始连续覆盖所有关卡，否则会在加载时报错。
---@param ranges table
---@return table
function common.level_meta(ranges)
	local count = 0

	for _, range in ipairs(ranges) do
		local first = range[1]
		local last = range[2] or first

		assert(first == count + 1, string.format("gen ranges 必须从 1 开始连续覆盖：期望 %d，实际 %d", count + 1, first))
		assert(last >= first, string.format("gen ranges 的区间结束值不能小于起始值：%d > %d", first, last))

		count = last
	end

	return {
		count = count,
		main_campaign_last = ranges[1] and (ranges[1][2] or ranges[1][1]) or 0,
		ranges = ranges,
		max_stars = count_stars(ranges)
	}
end

--- 构造标准世代描述符。
---@param config table
---@return table
function common.standard(config)
	local ranges = config.ranges
	local flags = {
		texture = config.flag_texture or "map_flag_0181",
		anchor = config.flag_anchor or {
			mode = "center"
		},
		star_pos = {v(12, 12), v(28, 12), v(43, 12)},
		wing_texture = "map_flag_heroic_0015",
		wing_offset = v(-3, 0)
	}
	local levels = common.level_meta(ranges)
	levels.xp_multiplier = config.xp_multiplier or function(local_idx)
		if local_idx <= 9 then
			return 0.1 * local_idx
		end

		return 1
	end

	return {
		name = config.name,
		label_key = config.label_key,
		hotkey = config.hotkey or "",
		kind = "standard",
		resource_root = config.resource_root,
		map = {
			background = config.background,
			vignette = "map_vignette_small",
			music = config.music,
			points = config.points,
			start_here_pos = v(292, 775),
			animations = config.map_animations,
			decos = config.map_decos,
			level_data = config.level_data,
			thumb_key = config.thumb_key,
			battle_music = config.battle_music,
			prep_music = config.prep_music
		},
		flags = flags,
		levels = levels,
		level_select = config.level_select or {},
		upgrades = {
			default_line = config.default_upgrade_line or "1"
		},
		resources = {
			map = {
				required_textures = config.required_textures or {},
				plugin_required_textures = config.plugin_required_textures or {},
				required_sounds = config.required_sounds or {},
				plugin_required_sounds = config.plugin_required_sounds or {},
				required_exoskeletons = config.required_exoskeletons or {},
				plugin_required_exoskeletons = config.plugin_required_exoskeletons or {}
			}
		}
	}
end

return common
