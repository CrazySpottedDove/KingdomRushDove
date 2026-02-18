-- chunkname: @./all/wave_db.lua
local log = require("lib.klua.log"):new("wave_db")
local km = require("lib.klua.macros")
local tsv = require("lib.klua.tsv")
require("lib.klua.string")
require("lib.klua.table")
local FS = love.filesystem
local E = require("entity_db")
local EL = require("kr1.data.endless")
local EU = require("endless_utils")
local bit = require("bit")
require("all.constants")

local wave_db = {}

wave_db.db = nil
wave_db.game_mode = nil
wave_db.format = nil
wave_db.parse_errors = nil

local WS_IDLE = "idle"
local WS_PENDING = "pending"
local WS_RUNNING = "running"
local WS_DONE = "done"
local WS_REMOVED = "removed"

wave_db.WS_IDLE = WS_IDLE
wave_db.WS_PENDING = WS_PENDING
wave_db.WS_RUNNING = WS_RUNNING
wave_db.WS_DONE = WS_DONE
wave_db.WS_REMOVED = WS_REMOVED

local gms = {
	[GAME_MODE_CAMPAIGN] = "campaign",
	[GAME_MODE_HEROIC] = "heroic",
	[GAME_MODE_IRON] = "iron",
	-- [GAME_MODE_ENDLESS] = "endless"
	[GAME_MODE_ENDLESS] = "campaign" -- endless模式下也加载普通模式的波次
}

local tsv_cmd_col = 2
local tsv_value_col = 3

local function log_e(fmt, ...)
	if not wave_db.parse_errors then
		wave_db.parse_errors = {}
	end

	table.insert(wave_db.parse_errors, string.format(fmt or "", ...))
	log.error(fmt, ...)
end

local function is_file(path)
	local info = love.filesystem.getInfo(path)

	return info and info.type == "file"
end

--- 斗蛐蛐时使用，改为加载斗蛐蛐文件
---@param criket table
function wave_db:patch_waves(criket)
	self.db.groups = {}

	local criket_groups = criket.groups

	if not criket.fps_transformed then
		criket.fps_transformed = true

		for _, group in pairs(criket_groups) do
			for key, value in pairs(group) do
				if key == "delay" then
					value = value * FPS
				elseif key == "spawns" then
					for _, single_spawn in pairs(value) do
						for k, v in pairs(single_spawn) do
							if k == "interval" or k == "interval_next" then
								single_spawn[k] = v * FPS
							end
						end
					end
				end
			end
		end
	end

	self.db.groups[1] = {
		interval = 0,
		waves = criket_groups
	}
end

-- tsv

function wave_db:parse_column_names(cmd, row, row_idx)
	local function col_letter(idx)
		local first = string.byte("A")
		local last = string.byte("Z")
		local base = last - first + 1
		local r = ""
		local q = idx - 1

		while q >= 0 do
			local rem = q % base

			r = string.char(rem + first) .. r
			q = math.floor(q / base) - 1
		end

		return r
	end

	local time_columns = {}
	local path_columns = {}

	for i, col in ipairs(row) do
		col = string.trim(col)

		if col == "column_names" or col == "" then
		-- block empty
		else
			local parts = string.split(col, ":")

			if parts[1] == "inc" then
				time_columns.inc = i
			elseif parts[1] == "abs" then
				time_columns.abs = i
			elseif tonumber(parts[1]) then
				local pi = tonumber(parts[1])
				local spi = tonumber(parts[2]) or "*"

				path_columns[pi] = path_columns[pi] or {}
				path_columns[pi][spi] = i
			else
				return true, string.format("unknown column type: %s at column %s", col, col_letter(i))
			end
		end
	end

	cmd.time_columns = time_columns
	cmd.path_columns = path_columns
end

function wave_db:parse_flags(cmd, row, row_idx)
	local cmd_cols = self:find_prev_cmd("column_names", cmd)

	if not cmd_cols then
		return true, "flags cmd requires a path command before"
	end

	local pc = cmd_cols.path_columns

	if not pc then
		return true, "flags cmd requires path cmd with path_columns"
	end

	local out = {}

	for pi in pairs(pc) do
		out[pi] = {}

		for spi, col_index in pairs(pc[pi]) do
			local flag = string.lower(row[col_index] or "")
			local v = flag ~= "n" and flag ~= "false" and flag ~= "hide" and flag ~= "hidden"

			if spi == "*" then
				out[pi][1] = v
				out[pi][2] = v
				out[pi][3] = v

				break
			else
				local spin = tonumber(spi)

				out[pi][spin] = v
			end
		end
	end

	cmd.flags_visibility = out
end

function wave_db:parse_wave(cmd, row, row_idx)
	local cmd_cols = self:find_prev_cmd("column_names", cmd)

	if not cmd_cols then
		return true, string.format("%s cmd requires a path command before", cmd.name)
	end

	local cmd_i = self:find_prev_cmd("interval", cmd)
	local cmd_di = self:find_prev_cmd("default_interval", cmd)
	local tc = cmd_cols.time_columns

	cmd.wait_time = tonumber(row[tc.inc]) or cmd_i and cmd_i.value or cmd_di and cmd_di.value
end

function wave_db:parse_spawn(cmd, row, row_idx)
	local cmd_cols = self:find_prev_cmd("column_names", cmd)

	if not cmd_cols then
		return true, string.format("%s cmd requires a path command before", cmd.name)
	end

	local cmd_enemy_prefix = self:find_prev_cmd("enemy_prefix", cmd)
	local enemy_prefix = cmd_enemy_prefix.value or ""
	local cmd_default_increment = self:find_prev_cmd("default_increment", cmd)
	local default_increment = cmd_default_increment.value or 1
	local tc = cmd_cols.time_columns
	local row_increment = tonumber(row[tc.inc])

	cmd.wait_time = row_increment or default_increment
	cmd.absolute = row[tc.abs]
	cmd.spawns = {}

	local pc = cmd_cols.path_columns

	for pi in pairs(pc) do
		for spi, col_index in pairs(pc[pi]) do
			local enemy_suffix = row[col_index] and string.trim(row[col_index]) or ""

			if enemy_suffix and enemy_suffix ~= "" then
				table.insert(cmd.spawns, {
					pi = pi,
					spi = spi,
					enemy = enemy_prefix .. enemy_suffix
				})
			end
		end
	end
end

function wave_db:parse_event(cmd, row, row_idx)
	local cmd_cols = self:find_prev_cmd("column_names", cmd)

	if not cmd_cols then
		return true, string.format("%s cmd requires a path command before", cmd.name)
	end

	local cmd_default_increment = self:find_prev_cmd("default_increment", cmd)
	local default_increment = cmd_default_increment.value or 1
	local event_name = row[tsv_value_col]
	local increment = row[cmd_cols.time_columns.inc] or default_increment
	local params = {}

	for i = tsv_value_col + 1, #row do
		if i ~= cmd_cols.path_columns.inc then
			table.insert(params, row[i])
		end
	end

	cmd.event_name = event_name
	cmd.event_params = params
	cmd.wait_time = tonumber(increment)
end

function wave_db:parse_signal(cmd, row, row_idx)
	local cmd_cols = self:find_prev_cmd("column_names", cmd)

	if not cmd_cols then
		return true, string.format("%s cmd requires a path command before", cmd.name)
	end

	local cmd_default_increment = self:find_prev_cmd("default_increment", cmd)
	local default_increment = cmd_default_increment.value or 1
	local signal_name = row[tsv_value_col]
	local increment = row[cmd_cols.path_columns.inc] or default_increment
	local params = {}

	for i = tsv_value_col + 1, #row do
		if i ~= cmd_cols.path_columns.inc then
			table.insert(params, row[i])
		end
	end

	cmd.signal_name = signal_name
	cmd.signal_params = params
	cmd.wait_time = increment
end

function wave_db:parse_wait_signal(cmd, row, row_idx)
	local cmd_cols = self:find_prev_cmd("column_names", cmd)

	if not cmd_cols then
		return true, string.format("%s cmd requires a path command before", cmd.name)
	end

	local cmd_default_increment = self:find_prev_cmd("default_increment", cmd)
	local default_increment = cmd_default_increment.value or 1
	local signal_name = row[tsv_value_col]
	local increment = row[cmd_cols.path_columns.inc] or default_increment

	log.debug("waiting for signal %s...", signal_name)

	cmd.signal_name = signal_name
	cmd.wait_time = increment
end

function wave_db:parse_number(cmd, row, row_idx)
	local value = row[tsv_value_col]

	cmd.value = tonumber(value)
end

function wave_db:parse_manual_wave(cmd, row, row_idx)
	local cmd_cols = self:find_prev_cmd("column_names", cmd)

	if not cmd_cols then
		return true, string.format("%s cmd requires a path command before", cmd.name)
	end

	local wave_name = row[tsv_value_col]

	if not wave_name or string.trim(wave_name) == "" then
		return true, string.format("%s cmd requires a value with the name of the manual_wave", cmd.name)
	end

	local ws = self:get_wave_status(wave_name)

	if ws then
		return true, string.format("manual waves must be unique. name: %s already exists", wave_name)
	end

	cmd.wave_name = wave_name
	cmd.wait_time = 0
end

function wave_db:parse_manual_wave_repeat(cmd, row, row_idx)
	local cmd_cols = self:find_prev_cmd("column_names", cmd)

	if not cmd_cols then
		return true, string.format("%s cmd requires a path command before", cmd.name)
	end

	local cmd_mw = self:find_prev_cmd("manual_wave", cmd)

	if not cmd_mw then
		return true, string.format("%s cmd requires a manual command before", cmd.name)
	end

	local mws = self:get_wave_status(cmd_mw.wave_name)

	if not mws then
		return true, string.format("%s cmd requires manual_wave %s before", cmd.name, cmd_mw.wave_name)
	end

	cmd.wave_name = cmd_mw.wave_name

	local value = tonumber(row[tsv_value_col])

	cmd.repeat_count = value or 0
	mws.repeat_count = cmd.repeat_count
	mws.repeat_remaining = cmd.repeat_count
end

function wave_db:parse_wait(cmd, row, row_idx)
	local cmd_cols = self:find_prev_cmd("column_names", cmd)

	if not cmd_cols then
		return true, string.format("%s cmd requires a path command before", cmd.name)
	end

	local cmd_default_increment = self:find_prev_cmd("default_increment", cmd)
	local default_increment = cmd_default_increment and cmd_default_increment.value or -1
	--cmd.wait_time 原先是1，改成了-1
	--local default_increment = cmd_default_increment and cmd_default_increment.value or 1
	local tc = cmd_cols.time_columns
	local row_increment = tonumber(row[tc.inc])

	cmd.wait_time = row_increment or default_increment
end

wave_db.tsv_cmds = {
	["#"] = {},
	sheet_name = {},
	description = {},
	lives = {
		parse_fn = wave_db.parse_number
	},
	gold = {
		parse_fn = wave_db.parse_number
	},
	gems = {
		parse_fn = wave_db.parse_number
	},
	gem_keepers = {
		parse_fn = wave_db.parse_number
	},
	enemy_prefix = {},
	default_increment = {
		parse_fn = wave_db.parse_number
	},
	default_interval = {
		parse_fn = wave_db.parse_number
	},
	interval = {
		parse_fn = wave_db.parse_number
	},
	column_names = {
		parse_fn = wave_db.parse_column_names
	},
	flags = {
		parse_fn = wave_db.parse_flags
	},
	wave = {
		parse_fn = wave_db.parse_wave
	},
	spawn = {
		parse_fn = wave_db.parse_spawn
	},
	wait = {
		parse_fn = wave_db.parse_wait
	},
	event = {
		parse_fn = wave_db.parse_event
	},
	signal = {
		parse_fn = wave_db.parse_signal
	},
	wait_signal = {
		parse_fn = wave_db.parse_wait_signal
	},
	manual_wave = {
		parse_fn = wave_db.parse_manual_wave
	},
	manual_wave_repeat = {
		parse_fn = wave_db.parse_manual_wave_repeat
	},
	call_manual_wave = {}
}

function wave_db:create_wave_group_from_tsv(wave_cmd)
	local path_columns = self:find_prev_cmd("column_names", wave_cmd)

	if not path_columns then
		log_e("%s cmd requires a path command before", wave_cmd.name)

		return
	end

	local group = {
		waves = {},
		interval = (wave_cmd.wait_time or 0) * FPS
	}
	local out = {}
	local w
	local delay = 0
	local has_flying = false
	local wave_idx = self:get_cmd_idx(wave_cmd)

	for i = wave_idx + 1, #self.db_cmds do
		local cmd = self.db_cmds[i]

		if cmd.name == "wave" or cmd.name == "manual_wave" then
			break
		elseif cmd.name == "spawn" then
			local interval = cmd.wait_time

			delay = delay + interval

			for _, es in pairs(cmd.spawns) do
				if w and w.path_index ~= es.pi then
					w.delay = delay * FPS
					w.some_flying = has_flying

					table.insert(group.waves, w)

					w = nil
					has_flying = false
				end

				w = w or {
					path_index = es.pi,
					spawns = {}
				}

				table.insert(w.spawns, {
					max_same = 0,
					interval_next = 0,
					max = 1,
					creep = es.enemy,
					fixed_sub_path = es.spi == "*" and 0 or 1,
					interval = interval * FPS,
					path = es.spi == "*" and 1 or es.spi
				})

				local tpl = E:get_template(es.enemy)

				if tpl and bit.band(tpl.vis.flags, F_FLYING) ~= 0 then
					has_flying = true
				end
			end

			if w then
				w.delay = delay * FPS
				w.some_flying = has_flying

				table.insert(group.waves, w)

				w = nil
				has_flying = false
			end
		end
	end

	if log.level == log.PARANOID_LEVEL then
		log.paranoid("group:%s", getfulldump(group))
	end

	return group
end

function wave_db:get_spawns_for_wave(idx)
	local wave_count = 0
	local start_idx

	for i, cmd in pairs(self.db_cmds) do
		if cmd.name == "wave" then
			wave_count = wave_count + 1

			if wave_count == idx then
				start_idx = i

				break
			end
		end
	end

	if not start_idx then
		log.paranoid("wave %s not found", idx)

		return
	end

	local spawns = {}

	for i = start_idx + 1, #self.db_cmds do
		local cmd = self.db_cmds[i]

		if cmd.name == "wave" then
			return spawns
		elseif cmd.name == "spawn" then
			table.append(spawns, cmd.spawns)
		end
	end

	return spawns
end

function wave_db:parse_cmd(row, row_idx)
	log.paranoid("-- row: | %s | %s | %s |", row[1], row[2], row[3])

	for _, col in ipairs(row) do
		if string.starts(col, "#") then
			log.paranoid("comment found. skipping row %s", table.concat(row, " "))

			return {
				name = "#"
			}
		elseif string.trim(col) ~= "" then
			break
		end
	end

	local cname
	local path_cmd = self:find_prev_cmd("column_names", self.db_cmds[#self.db_cmds])

	if path_cmd and row[tsv_cmd_col] == "" then
		local pc = path_cmd.path_columns

		for pi in pairs(pc) do
			for spi, col_index in pairs(pc[pi]) do
				if row[col_index] and row[col_index] ~= "" and row[col_index] ~= "\r" then
					log.paranoid("spawn found.")

					cname = "spawn"

					goto label_16_0
				end
			end
		end
	end

	cname = row[tsv_cmd_col]

	::label_16_0::

	if not cname or cname == "" then
		return
	elseif not self.tsv_cmds[cname] then
		return nil, string.format("cmd %s not found in tsv_cmds", cname)
	end

	local parse_fn = self.tsv_cmds[cname].parse_fn
	local cmd = {}

	cmd.name = cname
	cmd.tsv_row = row
	cmd.tsv_row_idx = row_idx

	if parse_fn then
		local err, msg = parse_fn(self, cmd, row, row_idx)

		if err then
			return nil, msg
		end
	else
		cmd.value = row[tsv_value_col]
	end

	return cmd
end

function wave_db:get_cmd_idx(start_cmd)
	for i, cmd in ipairs(self.db_cmds) do
		if start_cmd == cmd then
			return i
		end
	end

	return nil
end

function wave_db:find_prev_cmd(cname, start_cmd)
	if not self.db_cmds or not cname or not start_cmd then
		return
	end

	local start_idx = self:get_cmd_idx(start_cmd) or #self.db_cmds

	for i = start_idx, 1, -1 do
		local cmd = self.db_cmds[i]

		if cmd.name == cname then
			return cmd
		end
	end
end

function wave_db:find_first_cmd(cname)
	for _, cmd in pairs(self.db_cmds) do
		if cmd.name == cname then
			return cmd
		end
	end
end

function wave_db:peek_next_cmd(wave_name)
	local ws = self:get_wave_status(wave_name)

	if not ws then
		log.error("wave %s does not exist", wave_name)

		return nil
	end

	if ws.state == WS_DONE or ws.state == WS_REMOVED then
		log.debug("wave %s finished", wave_name)

		return nil
	end

	local next_idx = ws.current_idx + 1
	local next_cmd = self.db_cmds[next_idx]

	if not next_cmd or next_cmd.name == "manual_wave" then
		return nil
	end

	return next_cmd, next_idx
end

function wave_db:get_next_cmd(wave_name)
	local next_cmd, next_idx = self:peek_next_cmd(wave_name)

	if not next_cmd then
		return nil
	end

	local ws = self:get_wave_status(wave_name)

	ws.current_idx = next_idx

	return next_cmd, next_idx
end

function wave_db:load_tsv(level_name, game_mode, wave_ss_data)
	self.parse_errors = nil

	local rows

	if wave_ss_data then
		rows = tsv.parse_tsv(wave_ss_data)
	else
		local suffix = gms[game_mode]
		local wn = string.format("%s/data/waves/%s_waves_%s", KR_PATH_GAME, level_name, suffix)
		local wf = string.format("%s.tsv", wn)

		if not is_file(wf) then
			log.info("wave file in tsv format not found: %s", wf)

			return
		end

		log.debug("Loading %s", wn)

		rows = tsv.load(wf)

		if not rows or #rows == 0 then
			log_e("Failed to load %s", wf)

			return
		end
	end

	self.format = "tsv"
	self.game_mode = game_mode
	self.db_rows = rows
	self.db_cmds = {}
	self.db_waves_status = {}

	local ws = self:create_wave_status("main")

	ws.state = WS_RUNNING

	local db = {
		interval = -1,
		path_columns = {},
		flags_visibility = {}
	}

	self.db = db

	log.paranoid("parsing rows")
	local sheet_name

	for i = 1, #rows do
		local cmd, err = self:parse_cmd(rows[i], i)

		if cmd then
			log.paranoid(" row[%s] = %s", i, getdump(cmd))

			if cmd.name == "sheet_name" then
				sheet_name = cmd.value
			end

			if cmd.name ~= "#" then
				table.insert(self.db_cmds, cmd)
			-- if cmd.name == "spawn" and self.user_data.liuhui.enemy_count and self.user_data.liuhui.enemy_count >= 2 then
			-- 	if self.user_data.liuhui.enemy_count == 2 then
			-- 		table.insert(self.db_cmds, cmd)
			-- 	elseif self.user_data.liuhui.enemy_count == 3 then
			-- 		table.insert(self.db_cmds, cmd)
			-- 		table.insert(self.db_cmds, cmd)
			-- 	end
			-- end
			end

			if cmd.name == "manual_wave" then
				local mws = self:create_wave_status(cmd.wave_name)

				mws.first_idx = #self.db_cmds
				mws.current_idx = mws.first_idx
			end
		elseif err then
			log_e("error at %s#%s:  %s", sheet_name, i, err)
		end
	end

	if log.level == log.PARANOID_LEVEL then
		local out = ""

		for i, cmd in ipairs(self.db_cmds) do
			out = out .. string.format("(%02i) - %s : value:%s wait_time:%s\n", i, cmd.name, cmd.value, cmd.wait_time)
		end

		log.paranoid("wave cmds:\n%s", out)
	end

	return true
end

function wave_db:is_flag_visible(pi, spi)
	if self.db and self.db.flags_visibility and self.db.flags_visibility[pi] then
		return self.db.flags_visibility[pi][spi or 1]
	else
		return true
	end
end

function wave_db:create_wave_status(wave_name)
	local ws = {
		repeat_count = 0,
		current_idx = 0,
		state = WS_IDLE,
		name = wave_name
	}

	self.db_waves_status[wave_name] = ws

	return ws
end

function wave_db:get_wave_status(wave_name)
	wave_name = wave_name or "main"

	return self.db_waves_status[wave_name]
end

function wave_db:stop_manual_wave(wave_name)
	if not wave_name or wave_name == "main" or wave_name == "" then
		log.error("cannot stop main waves")

		return
	end

	local s = self:get_wave_status(wave_name)

	if not s then
		log.error("manual wave %s does not exist", wave_name)

		return
	end

	if table.contains({WS_PENDING, WS_RUNNING}, s.state) then
		s.state = WS_DONE
	else
		log.error("manual wave %s cannot be stopped in state %s", wave_name, s.state)
	end
end

function wave_db:start_manual_wave(wave_name)
	if not wave_name or wave_name == "main" or wave_name == "" then
		log.error("cannot start main waves")

		return
	end

	local s = self:get_wave_status(wave_name)

	if not s then
		log.error("manual wave %s does not exist", wave_name)

		return
	end

	if table.contains({WS_PENDING, WS_RUNNING, WS_DONE}, s.state) then
		log.error("manual wave %s pending or still running. cannot have more than one at a time.", wave_name)

		return
	end

	s.state = WS_PENDING
	s.current_idx = s.first_idx
	s.repeat_remaining = s.repeat_count
end

function wave_db:has_pending_manual_waves()
	for k, v in pairs(self.db_waves_status) do
		if k ~= "main" and v.state == WS_PENDING then
			return true
		end
	end
end

function wave_db:list_pending_manual_waves()
	local names = {}

	for k, v in pairs(self.db_waves_status) do
		if v.state == WS_PENDING then
			table.insert(names, k)
		end
	end

	return names
end

--tsv end

function wave_db:load_lua(level_name, game_mode, endless)
	self.game_mode = game_mode
	self.format = "lua"
	self.is_endless = endless

	local suffix = gms[game_mode]
	local wn = string.format("%s/data/waves/%s_waves_%s", KR_PATH_GAME, level_name, suffix)
	local wf = string.format("%s.lua", wn)

	log.debug("Loading %s", wn)

	local ok, wchunk = pcall(FS.load, wf)

	if not ok then
		log.error("Failed to load %s: error: %s", wf, wchunk)

		return
	end

	local ok, wtable = pcall(wchunk)

	if not ok then
		log.error("Failed to eval chunk for %s: error: %s", wf, wtable)

		return
	end

	wave_db.db = wtable

	local wen = string.format("%s_extra", wn)
	local wef = string.format("%s.lua", wen)

	if is_file(wef) then
		log.info("Found extra waves: %s", wef)

		local ok, wchunk = pcall(FS.load, wef)

		if not ok then
			log.error("Failed to load %s: error: %s", wef, wchunk)

			return
		end

		local ok, extraw = pcall(wchunk)

		if not ok then
			log.error("Failed to eval extra waves chunk for %s: error: %s", wef, extraw)

			return
		end

		self:add_waves_to_groups(extraw)
	end

	if endless then
		self.endless = EU.init_endless(level_name, self:groups())
	end

	return true
end

function wave_db:load(level_name, game_mode, endless)
	if self:load_tsv(level_name, game_mode) then
		return "tsv"
	end

	if self:load_lua(level_name, game_mode, endless) then
		return "lua"
	end

	return nil
end

--- 使每条路线出怪随机化
function wave_db:randomize_creeps()
	local enumerate = {}
	local groups = self.db.groups
	local g_0 = self:initial_gold()
	local g_t = g_0
	local t = #groups
	local creep_count = 0
	local creep_count_per_group = {}
	for i = 1, #groups do
		local group = groups[i]
		creep_count_per_group[i] = 0
		for j = 1, #group.waves do
			local wave = group.waves[j]
			local pid = wave.path_index
			if not enumerate[pid] then
				enumerate[pid] = {}
			end
			local this_path = enumerate[pid]
			for k = 1, #wave.spawns do
				local spawn = wave.spawns[k]
				local creep = spawn.creep
				local creep_aux = spawn.creep_aux
				if creep_aux then
					for l = 1, spawn.max do
						this_path[#this_path + 1] = l % 2 == 0 and creep_aux or creep
						g_t = g_t + E:get_template(this_path[#this_path]).enemy.gold
					end
				else
					for l = 1, spawn.max do
						this_path[#this_path + 1] = creep
						g_t = g_t + E:get_template(this_path[#this_path]).enemy.gold
					end
				end
				creep_count = creep_count + spawn.max
				creep_count_per_group[i] = creep_count_per_group[i] + spawn.max
			end
		end
	end
	local lambda = (g_t - g_0) / creep_count
	local k = ((g_t / g_0) ^ (1 / t) - 1) / lambda

	-- 出怪公式
	local function calculate_creep_count_for_group(n)
		return math.ceil(g_0 * (k * lambda + 1) ^ (n - 1) * k)
	end

	local new_groups = {}
	for i = 1, #groups do
		local group = groups[i]
		local new_group = {
			interval = group.interval,
			waves = {}
		}
		local expected_creep_count = calculate_creep_count_for_group(i)
		local spawn_factor = expected_creep_count / creep_count_per_group[i]

		local spawn_step = 0
		for j = 1, #group.waves do
			local wave = group.waves[j]
			local pid = wave.path_index
			local this_path = enumerate[pid]
			local new_wave = {
				path_index = wave.path_index,
				delay = wave.delay,
				spawns = {}
			}
			local new_spawns = new_wave.spawns

			for k = 1, #wave.spawns do
				local spawn = wave.spawns[k]
				spawn_step = spawn_step + spawn.max * spawn_factor
				local spawn_count = math.floor(spawn_step)
				if spawn_count > 0 then
					spawn_step = spawn_step - spawn_count
					local avg_interval = spawn.interval * spawn.max / spawn_count
					for l = 1, spawn_count do
						local new_spawn = table.deepclone(spawn)
						new_spawn.interval = avg_interval
						if l == spawn_count then
							new_spawn.interval_next = spawn.interval_next
						else
							new_spawn.interval_next = 0
						end
						new_spawn.creep = table.random(this_path)
						new_spawn.max = 1
						if bit.band(E:get_template(new_spawn.creep).vis.flags, F_FLYING) ~= 0 then
							new_wave.some_flying = true
						end
						table.insert(new_spawns, new_spawn)
					end
				else
					local new_spawn = table.deepclone(spawn)
					new_spawn.max = 0
					table.insert(new_spawns, new_spawn)
				end
			end

			table.insert(new_group.waves, new_wave)
		end
		table.insert(new_groups, new_group)
	end
	self.db.groups = new_groups
end

function wave_db:add_waves_to_groups(gwaves)
	if self.db.groups then
		for g, more_waves in pairs(gwaves) do
			if not self.db.groups[g] then
				self.db.groups[g] = {
					waves = {}
				}
			end

			for _, w in pairs(more_waves.waves) do
				table.insert(self.db.groups[g].waves, w)
			end
		end
	else
		log.error("Unable to add waves. No wave groups have been loaded yet.")
	end
end

function wave_db:groups()
	return self.db.groups
end

function wave_db:group(group_number)
	return self.db.groups[group_number]
end

function wave_db:initial_gold()
	if self.format == "tsv" then
		local cmd = self:find_first_cmd("gold")

		if cmd then
			return math.ceil(cmd.value)
		else
			return 0
		end
	else
		return self.db.cash or self.db.gold
	end
end

function wave_db:initial_lives()
	return self.db.lifes or 0
end

function wave_db:groups_count()
	if self.is_endless then
		return 0
	elseif self.format == "tsv" then
		local count = 0

		for _, cmd in ipairs(self.db_cmds) do
			if cmd.name == "wave" then
				count = count + 1
			end
		end

		return count
	else
		return #self.db.groups
	end
end

function wave_db:waves_count()
	if self.is_endless then
		return 0
	elseif self.format == "tsv" then
		return self:groups_count()
	else
		local result = 0

		for __, group in pairs(self.db.groups) do
			result = result + #group.waves
		end

		return result
	end
end

function wave_db:has_group(i)
	if self.is_endless then
		return i <= 100
	else
		return i <= #self.db.groups
	end
end

function wave_db:get_group(i)
	if self.is_endless then
		return self:get_endless_group(i)
	else
		return self.db.groups[i]
	end
end

function wave_db:get_endless_early_wave_reward_factor()
	if self.db and self.db.nextWaveRewardMoneyMultiplier then
		return self.db.nextWaveRewardMoneyMultiplier
	else
		return 1
	end
end

function wave_db:get_endless_score_config()
	if self.db and self.db.score then
		return table.deepclone(self.db.score)
	else
		return nil
	end
end

function wave_db:get_endless_boss_config(i)
	local out = {}
	local db = self.db
	local dif_max = #db.difficulties
	local dif_level = math.ceil(i / 10)
	local dif_idx = km.clamp(1, dif_max, dif_level)
	local dif = db.difficulties[dif_idx]
	local dbc = dif.bossConfig

	out.chance = dbc.powerChance + dbc.powerChanceIncrement * dif_level
	out.cooldown = math.random(dbc.powerCooldownMin, dbc.powerCooldownMax)
	out.multiple_attacks_chance = dbc.powerMultiChance
	out.power_chances = dbc.powerDistribution
	out.powers_config_dif = dbc.powerConfig
	out.boss_config_dif = dbc
	out.powers_config = db.bossConfig.powerConfig

	return out
end

function wave_db:get_endless_group(i)
	return EU.generate_group(self.endless)
end

return wave_db
