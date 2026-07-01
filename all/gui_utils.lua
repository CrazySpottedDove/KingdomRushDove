-- chunkname: @./all/gui_utils.lua
local GU = {}
local E = require("entity_db")

function GU.lives_desc(v)
	if not v or type(v) ~= "number" then
		return _("None")
	elseif v < 2 then
		return string.format(_("%d Life"), v)
	else
		return string.format(_("%d Lives"), v)
	end
end

-- Only used in dove, so just in Chinese for quickness
function GU.armor_value_desc_detailed(v, immune)
	if immune then
		return "免疫"
	end
	if not v or type(v) ~= "number" or v <= 0 then
		return "无"
	end
	return string.format("%d", v * 100)
end

function GU.armor_value_desc(v, short)
	local pref = short and "CArmorSmall" or "CArmor"

	if not v or type(v) ~= "number" then
		return _(pref .. "0")
	elseif v >= 1 then
		return _(pref .. "9")
	elseif v > 0.9 then
		return _(pref .. "4")
	elseif v >= 0.61 then
		return _(pref .. "3")
	elseif v >= 0.31 then
		return _(pref .. "2")
	elseif v >= 0.01 then
		return _(pref .. "1")
	else
		return _(pref .. "0")
	end
end

function GU.cooldown_value_desc(v)
	if not v or type(v) ~= "number" then
		return "-"
	elseif v >= 3 then
		return _("CReload_1")
	elseif v >= 2 then
		return _("CReload0")
	elseif v >= 1.5 then
		return _("CReload1")
	elseif v >= 0.8 then
		return _("CReload2")
	elseif v >= 0.5 then
		return _("CReload3")
	else
		return _("CReload4")
	end
end

function GU.cooldown_value_desc_detailed(v)
	if not v or type(v) ~= "number" then
		return "-"
	else
		return string.format("%.2f s", v)
	end
end

function GU.speed_value_desc(v)
	if not v or type(v) ~= "number" then
		return _("None")
	elseif v >= 80 then
		return _("CSpeed4")
	elseif v >= 60 then
		return _("CSpeed3")
	elseif v >= 45 then
		return _("CSpeed2")
	elseif v >= 21 then
		return _("CSpeed1")
	elseif v >= 16 then
		return _("CSpeed0")
	elseif v >= 12 then
		return _("CSpeed_1")
	else
		return _("CSpeed_2")
	end
end

function GU.range_value_desc(v)
	if not v or type(v) ~= "number" then
		return _("None")
	end

	v = v * 2

	if v >= 520 then
		return _("CRange5")
	elseif v >= 460 then
		return _("CRange4")
	elseif v >= 400 then
		return _("CRange3")
	elseif v >= 360 then
		return _("CRange2")
	elseif v >= 320 then
		return _("CRange1")
	else
		return _("CRange0")
	end
end

function GU.damage_value_desc(min, max)
	if min and max and max > 0 then
		return string.format("%i-%i", min, max)
	else
		return _("None")
	end
end

function GU.damage_value_and_cooldown_desc(min, max, cooldown)
	if not cooldown or cooldown <= 0 then
		if min and max and max > 0 then
			return string.format("%i-%i", min, max)
		else
			return _("None")
		end
	end

	if min and max and max > 0 then
		return string.format("%i-%i / %.1f", min, max, cooldown)
	else
		return string.format("无 / %.1f", cooldown)
	end
end

function GU.difficulty_desc(i)
	if i == 1 then
		return _("LEVEL_SELECT_DIFFICULTY_CASUAL")
	elseif i == 2 then
		return _("LEVEL_SELECT_DIFFICULTY_NORMAL")
	elseif i == 3 then
		return _("LEVEL_SELECT_DIFFICULTY_VETERAN")
	elseif i == 4 then
		return _("LEVEL_SELECT_DIFFICULTY_IMPOSSIBLE")
	end
end

function GU.difficulty_completed_desc(i, short_version)
	if short_version then
		return GU.difficulty_desc(i)
	elseif i == 1 then
		return _("C_DIFFICULTY_EASY")
	elseif i == 2 then
		return _("C_DIFFICULTY_NORMAL")
	elseif i == 3 then
		return _("C_DIFFICULTY_HARD")
	elseif i == 4 then
		return _("C_DIFFICULTY_IMPOSSIBLE")
	end
end

function GU.incoming_wave_report(group, path_index, game_mode)
	local creep_count = {}

	for _, wave in pairs(group.waves) do
		if wave.path_index == path_index then
			for _, spawn in pairs(wave.spawns) do
				local ce, cc = nil, 0

				if spawn.creep_aux and spawn.max_same > 0 then
					for j = 1, spawn.max do
						if not ce then
							ce = spawn.creep
						elseif cc >= spawn.max_same then
							if not creep_count[ce] then
								creep_count[ce] = 0
							end

							creep_count[ce] = creep_count[ce] + cc
							ce = spawn.creep == ce and spawn.creep_aux or spawn.creep
							cc = 0
						end

						cc = cc + 1
					end
				else
					ce = spawn.creep
					cc = spawn.max
				end

				if not creep_count[ce] then
					creep_count[ce] = 0
				end

				creep_count[ce] = creep_count[ce] + cc
			end
		end
	end

	local count = {}

	for k, v in pairs(creep_count) do
		if v > 0 then
			local tpl = E:get_template(k)
			local i18n_key = (tpl.info.i18n_key or string.upper(k)) .. "_NAME"

			count[i18n_key] = (count[i18n_key] or 0) + v
		end
	end

	local out = {}

	for k, v in pairs(count) do
		if game_mode == GAME_MODE_IRON then
			table.insert(out, string.format("%s ??", _(k)))
		else
			table.insert(out, string.format("%s x %i", _(k), v))
		end
	end

	return table.concat(out, "\n")
end

local V = require("lib.klua.vector")
local v = V.v

function GU.rounded_rectangle(x, y, width, height, segments, tip_offset, custom_scale)
	local border = 6 * custom_scale
	local vector = v(-border, 0)
	local angle_steps = math.pi * 0.5 / segments
	local asCos = math.cos(angle_steps)
	local asSin = math.sin(angle_steps)
	local corner_x = x + border
	local corner_y = y + border
	local vertices = {
		"fill"
	}

	local function roundedCorner()
		table.insert(vertices, vector.x + corner_x)
		table.insert(vertices, vector.y + corner_y)

		for i = 1, segments do
			asCos = math.cos(angle_steps * i)
			asSin = math.sin(angle_steps * i)

			local rx = vector.x * asCos - vector.y * asSin
			local ry = vector.x * asSin + vector.y * asCos

			table.insert(vertices, rx + corner_x)
			table.insert(vertices, ry + corner_y)
		end
	end

	if tip_offset and tip_offset.y == 0 then
		table.insert(vertices, x + tip_offset.x)
	else
		table.insert(vertices, x + width * 0.5)
	end

	table.insert(vertices, y)

	corner_x = x + width - border
	corner_y = y + border
	vector.x = 0
	vector.y = -border

	roundedCorner()

	if tip_offset then
		local tip_radius = 4 * custom_scale
		local tip_height = 9 * custom_scale

		corner_x = x + width - border
		corner_y = y + height - border
		vector.x = border
		vector.y = 0

		if tip_offset.y ~= 0 then
			table.insert(vertices, x + width)
			table.insert(vertices, y + tip_offset.y - tip_radius)
			table.insert(vertices, x + width + tip_height)
			table.insert(vertices, y + tip_offset.y)
			table.insert(vertices, x + width)
			table.insert(vertices, y + tip_offset.y + tip_radius)
			roundedCorner()
		else
			roundedCorner()
			table.insert(vertices, x + tip_offset.x + tip_radius)
			table.insert(vertices, y + height)
			table.insert(vertices, x + tip_offset.x)
			table.insert(vertices, y + height + tip_height)
			table.insert(vertices, x + tip_offset.x - tip_radius)
			table.insert(vertices, y + height)
		end
	else
		table.insert(vertices, x + width)
		table.insert(vertices, y + height - 7 * custom_scale)
		table.insert(vertices, x + width + 3 * custom_scale)
		table.insert(vertices, y + height + 3 * custom_scale)
		table.insert(vertices, x + width - 7 * custom_scale)
		table.insert(vertices, y + height)
	end

	corner_x = x + border
	corner_y = y + height - border
	vector.x = 0
	vector.y = border

	roundedCorner()

	corner_x = x + border
	corner_y = y + border
	vector.x = -border
	vector.y = 0

	roundedCorner()

	return vertices
end

return GU
