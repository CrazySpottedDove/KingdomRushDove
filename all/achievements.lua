-- chunkname: @./all/achievements.lua
local log = require("lib.klua.log"):new("achievements")
local signal = require("lib.hump.signal")
local bit = require("bit")
local E = require("entity_db")
local GS = require("kr1.game_settings")
local storage = require("storage")
local data = require("data.achievements_data")
local handlers = require("achievements_handlers")
local A = {}

function A:init()
	self.counters = {}

	for i = 1, #data do
		data[data[i].name] = data[i]
	end

	self:register_handlers()
	handlers:register_handlers(self)
end

function A:register_handlers()
	local function reg(name, fn)
		signal.register(name, function(...)
			fn(A, ...)
		end)
	end

	reg("slot-changed", self.h_slot_changed)
	reg("game-start", self.h_game_start)
	reg("game-quit", self.h_game_quit)
	reg("game-restart", self.h_game_quit)
	reg("game-victory-after", self.h_game_quit)
	reg("game-defeat-after", self.h_game_quit)
	reg("next-wave-sent", self.h_next_wave_sent)
end

function A:load()
	log.debug("loading achievements data from slot")

	local slot = storage:load_slot()

	self.ach = slot.achievements or {}
	self.counters[P_LIFETIME] = slot.achievement_counters or {}
	self.dirty = false
end

function A:save()
	log.debug("saving achievements data to slot. dirty:%s", self.dirty)

	if self.dirty then
		local slot = storage:load_slot()

		slot.achievements = self.ach
		slot.achievement_counters = self.counters[P_LIFETIME]

		storage:save_slot(slot)

		self.dirty = false
	end
end

function A:get_data(id)
	local ad = data[id]

	if not ad then
		log.error("achievement with id %s not found", id)
	end

	return ad
end

function A:get_count(id)
	local ad = self:get_data(id)

	if not ad then
		return
	end

	local period = ad.period or P_LIFETIME
	local counter = self.counters[period]

	return counter[id] or 0
end

function A:got(id)
	if not self:get_data(id) then
		return
	end

	if self.ach[id] then
		log.debug("already got achievement %s", id)

		return
	end

	log.debug("got achievement %s", id)

	self.ach[id] = true
	self.dirty = true

	self:save()
	signal.emit("got-achievement", id)
end

function A:have(id)
	return self.ach[id]
end

function A:flag(id, flag)
	if not flag then
		log.error("flag value missing for %s", id)

		return
	end

	local ad = self:get_data(id)

	if not ad then
		return
	end

	local period = ad.period or P_LIFETIME
	local counter = self.counters[period]
	local c = counter[id] or 0

	c = bit.bor(c, flag)
	counter[id] = c
	self.dirty = true

	log.paranoid("A:flag id:%s flag:%s -> %04X", id, flag, c)

	return c, ad
end

function A:flag_check(id, flag)
	if not flag then
		log.error("flag value missing for %s", id)

		return
	end

	local c, ad = self:flag(id, flag)

	if c and ad and ad.goal and c == ad.goal then
		self:got(ad.name)
	end

	return c, ad
end

function A:inc(id, value)
	value = value or 1

	local ad = self:get_data(id)

	if not ad then
		return
	end

	local period = ad.period or P_LIFETIME
	local counter = self.counters[period]
	local c = counter[id] or 0

	c = c + value
	counter[id] = c
	self.dirty = true

	log.paranoid("A:inc id:%s value:%s -> %s", id, value, c)

	return c, ad
end

function A:inc_check(id, value)
	value = value or 1

	local c, ad = self:inc(id, value)

	if c and ad and ad.goal and c >= ad.goal and c - value < ad.goal then
		self:got(ad.name)
	end

	return c, ad
end

function A:ge_check(id, value)
	if not value then
		log.error("value missing for %s", id)

		return
	end

	local ad = self:get_data(id)

	if not ad then
		return
	end

	local g = ad.goal or 1

	if g <= value then
		log.paranoid("A:ge_check id:%s value:%s >= goal:%s", id, value, g)
		self:got(ad.name)

		return value, ad
	else
		log.paranoid("A:ge_check id:%s value:%s < goal:%s", id, value, g)

		return nil
	end
end

function A:high(id, value)
	if not value then
		log.error("value missing for %s", id)

		return
	end

	local ad = self:get_data(id)

	if not ad then
		return
	end

	local period = ad.period or P_LIFETIME
	local counter = self.counters[period]
	local c = counter[id] or 0

	if c < value then
		counter[id] = value
		self.dirty = true

		log.paranoid("A:high id:%s value:%s > %s", id, value, c)

		return value, ad
	else
		log.paranoid("A:high id:%s value:%s <= %s", id, value, c)

		return nil
	end
end

function A:high_check(id, value)
	if not value then
		log.error("value missing for %s", id)

		return
	end

	local c, ad = self:high(id, value)

	if c and ad and ad.goal and c >= ad.goal then
		self:got(ad.name)
	end

	return c, ad
end

function A:lap_start(id, ts)
	ts = ts or game.store.tick_ts

	local ad = self:get_data(id)

	if not ad then
		return
	end

	local period = ad.period or P_LIFETIME
	local counter = self.counters[period]

	counter[id] = ts
	self.dirty = true

	log.paranoid("A:lap_start id:%s ts:%s -> %s", id, value, ts)

	return ts, ad
end

function A:lap_check(id, ts)
	ts = ts or game.store.tick_ts

	local ad = self:get_data(id)

	if not ad then
		return
	end

	local period = ad.period or P_LIFETIME
	local counter = self.counters[period]
	local start_ts = counter[id]

	if not start_ts then
		log.debug("no start_ts value for %s", id)

		return
	end

	if ad and ad.goal and ts - start_ts < ad.goal then
		self:got(ad.name)
	end

	return ts, ad
end

function A:count_active_mods(template_name, filter)
	local target_ids = {}
	local count = 0

	for _, m in pairs(game.store.modifiers) do
		if not m.pending_removal and m.template_name == template_name and not target_ids[m.modifier.target_id] and (not filter or filter(m)) then
			target_ids[m.modifier.target_id] = true
			count = count + 1
		end
	end

	return count
end

function A:reset_counters(group)
	self.counters[group] = {}
end

function A:h_slot_changed(slot_idx)
	self.counters = {}
	self.counters[P_SESSION] = {}

	self:load()
end

function A:h_game_start(store)
	self.counters[P_LEVEL] = {}
	self.counters[P_WAVE] = {}
	self.counters[P_POWER_1] = {}
end

function A:h_game_quit(store)
	self:save()
end

function A:h_next_wave_sent(group)
	self.counters[P_WAVE] = {}
end

return A
