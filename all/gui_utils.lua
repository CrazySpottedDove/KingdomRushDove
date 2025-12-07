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

return GU
