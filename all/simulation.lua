-- chunkname: @./all/simulation.lua

local log = require("klua.log"):new("simulation")
local km = require("klua.macros")
local S = require("systems")

require("constants")

simulation = {}

function simulation:init(store, system_names)
	self.store = store

	local d = store

	d.tick_length = TICK_LENGTH
	d.tick = 0
	d.tick_ts = 0
	d.ts = 0
	d.to = 0
	d.paused = false
	d.step = false
	d.entities = {}

    -- 优化分类索引
    d.enemies = {}
    d.soldiers = {}
    d.modifiers = {}
    d.towers = {}
    d.auras = {}
    d.particle_systems = {}
    d.entities_with_main_script_on_update = {}
    d.entities_with_timed = {}
    d.entities_with_tween = {}
    d.entities_with_render = {}

	d.pending_inserts = {}
	d.pending_removals = {}
	d.entity_count = 0
	-- d.entity_max = 0
    d.speed_factor = 1
	self.systems_on_queue = {}
	self.systems_on_dequeue = {}
	self.systems_on_insert = {}
	self.systems_on_remove = {}
	self.systems_on_update = {}

	local systems_order = {}

	for _, name in pairs(system_names) do
		if not S[name] then
			-- log.error("System named %s not found", name)
		else
			table.insert(systems_order, S[name])
		end
	end

	for _, s in ipairs(systems_order) do
        if s.on_queue then
            table.insert(self.systems_on_queue, s)
        end

        if s.on_dequeue then
            table.insert(self.systems_on_dequeue, s)
        end

        if s.on_insert then
            table.insert(self.systems_on_insert, s)
        end

        if s.on_remove then
            table.insert(self.systems_on_remove, s)
        end

        if s.on_update then
            table.insert(self.systems_on_update, s)
        end
	end
    self.systems_on_queue_count = #self.systems_on_queue
    self.systems_on_dequeue_count = #self.systems_on_dequeue
    self.systems_on_insert_count = #self.systems_on_insert
    self.systems_on_remove_count = #self.systems_on_remove
    self.systems_on_update_count = #self.systems_on_update
    for _, s in ipairs(systems_order) do
        if s.init then
            s:init(self.store)
        end
    end
end

function simulation:update(dt)
	local d = self.store

	if d.paused and not d.step then
		return
	end

    simulation:do_tick()
end

function simulation:do_tick()
	local d = self.store

	d.tick = d.tick + 1
	d.tick_ts = d.tick_ts + TICK_LENGTH

    -- 批量插入
    local last_count = #d.pending_inserts
    for i = last_count, 1, -1 do
        self:insert_entity(d.pending_inserts[i])
    end
    -- 清理前 last_count 个元素
    for i = 1, #d.pending_inserts - last_count do
        d.pending_inserts[i] = d.pending_inserts[i + last_count]
    end
    for i = #d.pending_inserts, #d.pending_inserts - last_count + 1, -1 do
        d.pending_inserts[i] = nil
    end

    last_count = #d.pending_removals
    -- 批量移除
    for i = last_count, 1, -1 do
        self:remove_entity(d.pending_removals[i])
    end
    for i = 1, #d.pending_removals - last_count do
        d.pending_removals[i] = d.pending_removals[i + last_count]
    end
    for i = #d.pending_removals, #d.pending_removals - last_count + 1, -1 do
        d.pending_removals[i] = nil
    end

    for i = 1, self.systems_on_update_count do
        self.systems_on_update[i]:on_update(TICK_LENGTH, d.tick_ts, d)
    end
end

function simulation:queue_insert_entity(e)
	if not e then
		return
	end

	local d = self.store
    for i = 1, self.systems_on_queue_count do
        self.systems_on_queue[i]:on_queue(e, d, true)
    end

	e.pending_removal = nil

    d.pending_inserts[#d.pending_inserts + 1] = e
end

function simulation:queue_remove_entity(e)
	if not e or e.pending_removal then
		return
	end

	local d = self.store

    for i = 1, self.systems_on_dequeue_count do
        self.systems_on_dequeue[i]:on_dequeue(e, d, false)
    end

	e.pending_removal = true

    self.store.pending_removals[#self.store.pending_removals + 1] = e
end

function simulation:insert_entity(e)
	local d = self.store

    for i = 1, self.systems_on_insert_count do
        if not self.systems_on_insert[i]:on_insert(e, d) then
            for j = 1, self.systems_on_dequeue_count do
                self.systems_on_dequeue[j]:on_dequeue(e, d, true)
            end

            return
        end
    end

	e.pending_removal = nil
	d.entities[e.id] = e

	d.entity_count = d.entity_count + 1
	-- d.entity_max = d.entity_count >= d.entity_max and d.entity_count or d.entity_max

	-- log.error("entity (%s) %s added", e.id, e.template_name)
end

function simulation:remove_entity(e)
	local d = self.store

    for i = 1, self.systems_on_remove_count do
        if not self.systems_on_remove[i]:on_remove(e, d) then
            for j = 1, self.systems_on_dequeue_count do
                self.systems_on_dequeue[j]:on_dequeue(e, d, false)
            end
            print(string.format("remove %s aborted", e.template_name))
            return
        end
    end

	e.pending_removal = nil
	d.entities[e.id] = nil

	d.entity_count = d.entity_count - 1
end

return simulation
