-- chunkname: @./all/debug_tools.lua
local log = require("lib.klua.log"):new("debug_tools")

log.level = log.DEBUG_LEVEL
dd = {}

function dd.sid()
	local e = game.game_gui.selected_entity

	if e then
		return e.id
	end
end

function dd.se()
	return game.game_gui.selected_entity
end

function dd.ft(template_name)
	return table.filter(game.store.entities, function(_, v)
		return template_name == v.template_name
	end)
end

function dd.dl(t)
	local o = ""

	for _, e in ipairs(t) do
		o = o .. string.format("(%s) %s\n", e.id, e.template_name)
	end

	return o
end

function dd.ne(name)
	local E = require("entity_db")
	local e = E:create_entity(name)

	e.nav_path.pi = game.dbg_active_pi
	e.nav_path.spi = math.random(1, 3)

	game.simulation:queue_insert_entity(e)
end

function dd.f(comp)
	local E = require("entity_db")
	local entities = E:filter(game.store.entities, comp)

	for _, e in pairs(entities) do
		print(string.format("(%s) %s", e.id, e.template_name))
	end
end

function dd.e(id)
	return game.store.entities[id]
end

function dd.d(t)
	return getdump(t)
end

function dd.fd(t)
	return getfulldump(t)
end

function dd.ed(id, comp)
	if comp then
		return getdump(dd.e(id)[comp])
	else
		return getdump(dd.e(id))
	end
end

function dd.sk(keyseq)
	table.map(string.split(keyseq, " "), function(_, key)
		love.event.push("keypressed", key)
	end)
end

function dd.sshot()
	local signal = require("lib.hump.signal")

	signal.emit("hide-gui")

	for _, e in pairs(game.store.entities) do
		if e.tower_holder then
			e.pos.x = 10000
		end

		if e.soldier then
			e.render.sprites[1].hidden = true
		end

		if e.template_name == "decal_defend_point" then
			e.pos.x = 10000
		end
	end

	game.store.main_hero.nav_rally.pos.x = -1000
	game.store.main_hero.pos.x = -1000

	for _, e in pairs(game.store.entities) do
		if e.tower or e.soldier then
			e.pos.x = 10000
		end
	end
end

function dd.dh(view, pad, i)
	print(pad .. ("(" .. (i or "") .. ")") .. tostring(view))

	for i, c in ipairs(view.children) do
		dd.dh(c, pad .. "  ", i)
	end
end

function dd.victory()
	local signal = require("lib.hump.signal")
	local outcome = {
		lives_left = 10,
		victory = true,
		stars = game.store.level_mode == 1 and 3 or 1,
		level_idx = game.store.level_idx,
		level_mode = game.store.level_mode,
		level_difficulty = game.store.level_difficulty
	}

	game.store.game_outcome = outcome

	signal.emit("game-victory", game.store)
	signal.emit("game-victory-after", game.store)
end

function dd.defeat()
	game.store.lives = 0
	game.store.game_outcome = nil
end

DEBUG_NNI = 1

function dd.nn(force_nni)
	local signal = require("lib.hump.signal")

	ggd = require("data.game_gui_data")
	eel = table.map(ggd.notifications, function(k, v)
		return k
	end)

	table.sort(eel)

	if game.game_gui.notiview then
		game.game_gui.notiview:hide()
	end

	if game.game_gui.window:ci("notification_view") then
		game.game_gui.window:ci("notification_view"):hide()
	end

	DEBUG_NNI = force_nni or DEBUG_NNI

	local noti_name = eel[DEBUG_NNI]

	log.debug("DEBUG_NNI:%s  %s", DEBUG_NNI, noti_name)

	if noti_name then
		signal.emit("wave-notification", "view", noti_name, true)

		DEBUG_NNI = DEBUG_NNI + 1
	else
		DEBUG_NNI = 1
	end

	return string.format("(%s) %s", DEBUG_NNI - 1, noti_name)
end

local aai = 1

function dd.aa(force_aai)
	local signal = require("lib.hump.signal")

	ad = require("data.achievements_data")
	aai = force_aai or aai

	if ad[aai] then
		signal.emit("got-achievement", ad[aai].name)

		aai = aai + 1
	else
		aai = 1
	end
end

function dd.dump_flags(v)
	local flag_names = {
		F_LETHAL = 8192,
		F_MOD = 4,
		F_WATER = 512,
		F_INSTAKILL = 524288,
		F_TELEPORT = 8388608,
		F_CUSTOM = 4096,
		F_FLYING = 128,
		F_HERO = 32,
		F_RANGED = 2,
		F_FRIEND = 1024,
		F_CANNIBALIZE = 32768,
		F_POLYMORPH = 2097152,
		F_ENEMY = 2048,
		F_FREEZE = 268435456,
		F_LAVA_BURN = 16384,
		F_POISON = 1048576,
		F_DRILL_DRIDER = 131072,
		F_TWISTER_RAGGIFY = 16777216,
		F_BOSS = 64,
		F_SKELETON = 33554432,
		F_BLOOD = 65536,
		F_DISINTEGRATED = 134217728,
		F_EAT = 262144,
		F_CLIFF = 256,
		F_STUN = 4194304,
		F_ZOMBIE_SERVANT = 536870912,
		F_NET = 67108864,
		F_SPELLCASTER = 2147483648,
		F_AREA = 8,
		F_LYCAN_DARK_ELF = 1073741824,
		F_BLOCK = 1
	}
	local bit = require("bit")
	local out = ""

	for i = 31, 0, -1 do
		local m = 2 ^ i

		out = out .. (bit.band(m, v) ~= 0 and "1" or "0")
		out = out .. (i % 4 == 0 and " " or "")
	end

	local flags = {}

	for fk, fv in pairs(flag_names) do
		if bit.band(v, fv) ~= 0 then
			table.insert(flags, fk)
		end
	end

	return flags, out
end

function dd.build(template)
	local templates = {"tower_totem", "tower_crossbow", "tower_assassin", "tower_templar", "tower_dwaarp", "tower_mech", "tower_archmage", "tower_necromancer"}
	local i = 1

	for _, h in pairs(game.store.entities) do
		if h.tower_holder then
			local tn = template or templates[i]

			i = i + 1

			if i > #templates then
				i = 1
			end

			h.tower.upgrade_to = tn
		elseif h.tower and h.powers then
			for k, v in pairs(h.powers) do
				if v.level == 0 then
					v.level = v.max_level
					v.changed = true
				end
			end
		end
	end
end

function dd.ls(path)
	local t = ""

	for n in io.popen("ls -a " .. path):lines() do
		t = t .. n .. "\n"
	end

	return t
end

function dd.cat(filename)
	local f = io.open(filename, "r")

	if not f then
		return "file could not be found"
	end

	local fs = f:read("*a")

	f:close()

	return fs
end

function dd.copy_file(src, dst)
	local fin = io.open(src)
	local c = fin:read("*all")

	fin:close()

	local fout = io.open(dst, "w")

	fout:write(c)
	fout:flush()
	fout:close()
end

function dd.trace(co)
	local level = 1
	local o = ""
	local is_co = co and type(co) ~= "string"

	if not is_co then
		o = o .. "-- ++++++++++++++++++++++++++++++++++++++++++++" .. "\n"
	end

	while true do
		local info

		if is_co then
			info = debug.getinfo(co, level, "Sl")
		else
			info = debug.getinfo(level, "Sl")
		end

		if not info then
			break
		end

		if info.what == "C" then
			o = o .. level .. " " .. "C function" .. "\n"
		else
			o = o .. string.format("[%s]:%d\n", info.short_src, info.currentline)
		end

		level = level + 1
	end

	if is_co then
		return o
	else
		print(o)
	end
end

function dd.hook_count(n)
	debug.sethook(dd.trace, "", n)
end

function dd.get_local(name, stack_offset)
	local i = 1
	local n, v
	local stack_idx = 4 + (stack_offset or 0)

	repeat
		n, v = debug.getlocal(stack_idx, i)

		if n == name then
			print(v)

			return v
		end

		i = i + 1
	until n == nil

	print("not found")
end

function dd.hex_dump(buf, first, last)
	local out = ""

	local function align(n)
		return math.ceil(n / 16) * 16
	end

	for i = align((first or 1) - 16) + 1, align(math.min(last or #buf, #buf)) do
		if (i - 1) % 16 == 0 then
			out = out .. string.format("%08X  ", i - 1)
		end

		out = out .. (i > #buf and "   " or string.format("%02X ", buf:byte(i)))

		if i % 8 == 0 then
			out = out .. " "
		end

		if i % 16 == 0 then
			out = out .. buf:sub(i - 16 + 1, i):gsub("%c", ".") .. "\n"
		end
	end

	return out
end

function dd.wid(n)
	local ai = director.active_item

	if not ai then
		return
	end

	if ai.game_gui and ai.game_gui.window then
		return ai.game_gui.window:get_child_by_id(n)
	elseif ai.window then
		return ai.window:get_child_by_id(n)
	end
end

function dd.help()
	out = " \ndd.aa(force_id)  : show achievement (force_id is optional)\ndd.build(tpl)    : build all towers of template, or cycle from list\ndd.cat(filename) : returns a file\ndd.copy_file(s,d): copy file, passing through memory\ndd.d(table)      : return dump of table\ndd.dl(table)     : list entities list with id and template\ndd.dump_flags(v) : dumps wich flags match\ndd.e(id)         : return entity with id\ndd.ed(id,comp)   : return dump of entity with id, or component dump if specified\ndd.f(comp)       : filter and print entities that have specified component\ndd.fd(table)     : return full dump of table\ndd.hex(d,fr,to)  : returns hex dump string of d[fr..to]\ndd.trace(co)     : returns coroutine stack trace\ndd.hook_count(n) : dumps trace after n instructions (100.000.000 for finding infinite loops)\ndd.ft(template)  : return array of entities of template\ndd.ls(path)      : returns printed list of files in path (only for unix)\ndd.ne(name)      : create and insert new entity with template name\ndd.nn(force_id)  : show notification (force_id is optional)\ndd.se()          : return entity selected from the gui\ndd.sid()         : return id of entity selected from the gui\ndd.sk(string)    : send the key names, separated by space(eg: \"tab f q =\")\ndd.sshot()       : prepare the screen for a screenshot (hide hero, gui, holders, etc.)\ndd.wid(n)        : returns kui view with id in director.active_item\n-- debug.debug() utils\ndd.get_local(name) : returns local variable with name\n"

	print(out)

	return out
end

return dd
