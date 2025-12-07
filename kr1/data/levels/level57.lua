-- chunkname: @./kr3/data/levels/level09.lua
local log = require("lib.klua.log"):new("level04")
local signal = require("hump.signal")
local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local LU = require("level_utils")
local V = require("lib.klua.vector")
local P = require("path_db")
require("constants")

local function fts(v)
	return v / FPS
end

local level = {}
local WARNING = 1
local ATTACK = 2
local OPEN_PATH = 3
level.blocked_path_sections = {
	[2] = {
		from = 140
	},
	[5] = {
		from = 96
	}
}
level.serpent_action_data = {
	[WARNING] = {{V.v(435, 523), false}, {V.v(435, 523), true}, {V.v(500, 436), true}},
	[ATTACK] = {{V.v(451, 571), false, V.v(592, 496), true, V.v(398, 447), true, {"2", "7", "1"}}, {V.v(578, 555), true, V.v(417, 501), false, V.v(492, 421), true, {"1", "2", "4"}}, {V.v(439, 553), false, V.v(583, 493), true, V.v(494, 414), false, {"6", "3", "5"}}, {V.v(516, 423), true, V.v(422, 488), false, V.v(617, 518), false, {"10", "5", "9"}}},
	[OPEN_PATH] = {{V.v(435, 523), false, V.v(530, 451), true, {1}, {6}}, {V.v(571, 556), true, V.v(450, 471), false, {2, 3}, {2, 3, 5}}}
}
level.serpent_sequence = {
	[GAME_MODE_CAMPAIGN] = {
		{{WARNING, 15}},
		{{WARNING, 5}, {WARNING, 20}},
		{{WARNING, 5}, {ATTACK, 12, 2}},
		{{WARNING, 5}, {WARNING, 12}, {ATTACK, 30, 3}},
		{{OPEN_PATH, 20, 1}},
		{{ATTACK, 10, 3}},
		{{WARNING, 10}, {WARNING, 18}},
		{{WARNING, 5}, {WARNING, 20}, {WARNING, 35}},
		{{WARNING, 5}, {ATTACK, 10, 2}, {ATTACK, 25, 3}},
		{{OPEN_PATH, 5, 2}, {WARNING, 15}, {WARNING, 25}},
		{{ATTACK, 9, 2}, {ATTACK, 22, 3}, {WARNING, 35}},
		{{ATTACK, 5, 3}, {ATTACK, 20, 2}, {WARNING, 35}},
		{{WARNING, 5}},
		{{WARNING, 5}, {WARNING, 15}, {WARNING, 20}, {WARNING, 25}},
		{{WARNING, 5}, {ATTACK, 10, 2}, {ATTACK, 20, 3}, {ATTACK, 30, 2}},
		{{ATTACK, 7, 2}, {ATTACK, 15, 3}, {ATTACK, 30, 2}, {WARNING, 40}, {ATTACK, 45, 3}}
	},
	[GAME_MODE_HEROIC] = {{{WARNING, 5}, {WARNING, 10}, {WARNING, 15}}, {{WARNING, 5}, {WARNING, 10}, {WARNING, 15}}},
	[GAME_MODE_IRON] = {{
		{WARNING, 5},
		{WARNING, 10},
		{WARNING, 15},
		{ATTACK, 20, 2},
		{ATTACK, 30, 3},
		{WARNING, 40},
		{ATTACK, 50, 1},
		{ATTACK, 60, 4},
		{WARNING, 70},
		{ATTACK, 80, 2},
		{ATTACK, 90, 3},
		{WARNING, 100},
		{ATTACK, 110, 1},
		{ATTACK, 120, 4},
		{WARNING, 130},
		{ATTACK, 140, 1},
		{ATTACK, 150, 4},
		{WARNING, 160},
		{ATTACK, 170, 1},
		{ATTACK, 180, 4}
	}}
}

function level:load(store)
	if store.level_mode == GAME_MODE_CAMPAIGN then
		local flags = LU.list_entities(store.pending_inserts, "decal_defense_flag", 2)
		local defend_point = LU.list_entities(store.pending_inserts, "decal_defense_flag", 2)[1]

		for _, flag in pairs(flags) do
			flag.render.sprites[1].hidden = true
		end

		defend_point.render.sprites[1].hidden = true

		for pid, v in pairs(self.blocked_path_sections) do
			P:add_invalid_range(pid, v.from, v.to, NF_ALL)
		end
	else
		for _, d in pairs(self.serpent_action_data[OPEN_PATH]) do
			local back_pos, back_flip, scream_pos, scream_flip, zone_ids, path_ids = unpack(d)

			for _, pid in pairs(path_ids) do
				P:activate_path(pid)
			end
		end
	end
end

function level:update(store)
	local this_wave = 0

	while store.wave_group_number < 1 do
		coroutine.yield()
	end

	while not store.waves_finished do
		local wave_seq = self.serpent_sequence[store.level_mode][DEBUG_SERPENT_WAVE or store.wave_group_number]

		if wave_seq then
			local start_ts = store.tick_ts
			log.debug("crystal serpent / wave_seq:%s ts:%s", getdump(wave_seq), start_ts)
			this_wave = store.wave_group_number
			local interrupted = false

			for _, seq in pairs(wave_seq) do
				local action, delay, data = unpack(seq)
				log.debug(" seq. action:%s delay:%s", action, delay)
				interrupted = U.y_wait(store, delay - (store.tick_ts - start_ts), function(store, time)
					return this_wave ~= store.wave_group_number or store.waves_finished
				end)

				if not interrupted or action == OPEN_PATH then
					self:y_serpent_seq(store, action, data)
				end
			end

			while not store.waves_finished and (DEBUG_SERPENT_WAVE or store.wave_group_number) == this_wave do
				coroutine.yield()
			end
		end

		U.y_wait(store, 0.5)
	end

	while not store.waves_finished or LU.has_alive_enemies(store) do
		coroutine.yield()
	end
end

function level:y_serpent_seq(store, action, data)
	if action == WARNING then
		local t, idx = table.random(self.serpent_action_data[WARNING])
		local pos, flip_x = unpack(t)
		self:add_serpent_back(store, pos, flip_x)
	elseif action == ATTACK then
		local back1_pos, back1_flip, back2_pos, back2_flip, attack_pos, attack_flip, holder_ids = unpack(self.serpent_action_data[ATTACK][data])
		self:add_serpent_back(store, back1_pos, back1_flip)
		U.y_wait(store, 1.4)
		self:add_serpent_back(store, back2_pos, back2_flip)
		U.y_wait(store, 3.3)
		self:add_serpent_attack(store, attack_pos, attack_flip, holder_ids)
	elseif action == OPEN_PATH then
		local back_pos, back_flip, scream_pos, scream_flip, zone_ids, path_ids = unpack(self.serpent_action_data[OPEN_PATH][data])
		self:add_serpent_back(store, back_pos, back_flip)
		U.y_wait(store, 3.3)
		self:add_serpent_scream(store, scream_pos, scream_flip, path_ids)
		U.y_wait(store, 1.7)
		S:queue("ElvesCrystalSerpentBreakingCrystal")

		for _, z in pairs(zone_ids) do
			self:open_zone(store, z)
		end

		for _, pid in pairs(path_ids) do
			P:activate_path(pid)

			if self.blocked_path_sections[pid] then
				local s = self.blocked_path_sections[pid]
				P:remove_invalid_range(pid, s.from, s.to, NF_ALL)
			end
		end
	end
end

function level:add_serpent_back(store, pos, flip_x)
	local e = E:create_entity("decal_s09_crystal_serpent_back")
	e.pos.x, e.pos.y = pos.x, pos.y
	e.render.sprites[1].ts = store.tick_ts
	e.render.sprites[1].flip_x = flip_x
	e.tween.props[1].keys[2][2].x = flip_x and -65 or 65
	e.tween.props[1].keys[3][2].x = e.tween.props[1].keys[2][2].x
	LU.queue_insert(store, e)
end

function level:add_serpent_attack(store, pos, flip_x, holder_ids)
	local e = E:create_entity("decal_s09_crystal_serpent_attack")
	e.flip_x = flip_x
	e.holder_ids = holder_ids
	e.pos.x, e.pos.y = pos.x, pos.y
	LU.queue_insert(store, e)
end

function level:add_serpent_scream(store, pos, flip_x, path_ids)
	local e = E:create_entity("decal_s09_crystal_serpent_scream")
	e.flip_x = flip_x
	e.path_ids = path_ids
	e.pos.x, e.pos.y = pos.x, pos.y
	LU.queue_insert(store, e)
end

function level:open_zone(store, zone)
	local land = LU.list_entities(store.entities, "decal_s09_land_" .. zone)[1]
	local flags = LU.list_entities(store.entities, "decal_defense_flag", zone)
	local defend_point = LU.list_entities(store.entities, "decal_defense_point", zone)[1]
	local crystals = table.filter(store.entities, function(k, e)
		return string.find(e.template_name, "decal_s09_crystal_", 1, true) and e.editor and e.editor.tag == zone
	end)

	if land then
		land.tween.ts = store.tick_ts
		land.tween.disabled = nil
	end

	local delay = 0.05

	for i, c in ipairs(crystals) do
		local d = delay * i
		c.render.sprites[1].name = "break"
		c.render.sprites[1].ts = store.tick_ts
		c.render.sprites[1].time_offset = -1 * d
		c.timed.disabled = nil
		local s = E:create_entity("decal_s09_crystal_debris")
		s.pos.x, s.pos.y = c.pos.x + c.debris_pos.x, c.pos.y + c.debris_pos.y
		U.animation_start(s, nil, nil, store.tick_ts + d + fts(7))
		s.tween.ts = store.tick_ts + d + fts(7)
		LU.queue_insert(store, s)
	end

	for _, flag in pairs(flags) do
		flag.render.sprites[1].hidden = nil
		flag.render.sprites[1].ts = store.tick_ts + 0.7
	end

	if defend_point then
		defend_point.render.sprites[1].hidden = nil
		defend_point.render.sprites[1].ts = store.tick_ts + 0.7
	end
end

return level
