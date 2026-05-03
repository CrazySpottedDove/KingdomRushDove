-- chunkname: @./all/simulation.lua
local log = require("lib.klua.log"):new("simulation")
local km = require("lib.klua.macros")
local S = require("systems")

require("all.constants")

simulation = {}

-- 把 game 的 store 挂载给 simulation
function simulation:init(store, system_names)
	self.store = store

	local d = store

	d.tick_length = TICK_LENGTH -- 游戏的时间单位，可用于倍速调节。TICK_LENGTH 是恒定值，但是可以通过调整 tick_length 来实现倍速效果。
	d.tick_ts = 0
	d.ts = 0
	d.to = 0
	d.to_gui = 0
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
	-- d.entities_with_main_script_on_update = {}
	d.entities_with_main_script_on_update = {}
	d.entities_with_main_script_on_update_index = {}
	d.entities_with_main_script_on_update_count = 0
	d.entities_with_timed = {}
	d.entities_with_tween = {}
	d.entities_with_render = {}
	d.entities_with_lights = {}
	d.entities_with_ui = {}
	d.pending_inserts = {}
	d.pending_removals = {}
	-- d.entity_count = 0
	-- d.entity_max = 0
	d.speed_factor = 1
	self.systems_on_queue = {}
	self.systems_on_dequeue = {}
	self.systems_on_insert = {}
	self.systems_on_remove = {}
	self.systems_on_update = {}

	local systems_order = {}

	for _, name in ipairs(system_names) do
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

	-- init 动作必须在最后执行，因为对 systems_on_xxx_count 有依赖。而且，你必须保证所有因 init 而进入的实体都经历所有的钩子处理。

	local system_ids_to_remove = {}

	for i, s in ipairs(systems_order) do
		if s.init_coroutined then
			if s:init_coroutined(self.store) == "skip" then
				system_ids_to_remove[#system_ids_to_remove + 1] = i
			end
		elseif s.init then
			if s:init(self.store) == "skip" then
				system_ids_to_remove[#system_ids_to_remove + 1] = i
			end
		end
	end

	-- 移除被 skip 的系统
	for i = #system_ids_to_remove, 1, -1 do
		local id = system_ids_to_remove[i]
		table.remove(systems_order, id)
	end

	-- 重建 systems.on_xxx_count
	self.systems_on_queue = {}
	self.systems_on_dequeue = {}
	self.systems_on_insert = {}
	self.systems_on_remove = {}
	self.systems_on_update = {}
	self.systems_on_render_update = {}

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

		if s.on_render_update then
			table.insert(self.systems_on_render_update, s)
		end
	end

	self.systems_on_queue_count = #self.systems_on_queue
	self.systems_on_dequeue_count = #self.systems_on_dequeue
	self.systems_on_insert_count = #self.systems_on_insert
	self.systems_on_remove_count = #self.systems_on_remove
	self.systems_on_update_count = #self.systems_on_update
	self.systems_on_render_update_count = #self.systems_on_render_update
end

function simulation:update(dt)
	local d = self.store

	if d.paused and not d.step then
		return
	end

	self:do_tick(dt)
end

function simulation:render_update(dt)
	local d = self.store

	if d.paused and not d.step then
		return
	end

	for i = 1, self.systems_on_render_update_count do
		self.systems_on_render_update[i]:on_render_update(dt, d.tick_ts, d)
	end
end

function simulation:do_tick(dt)
	local d = self.store

	d.tick_ts = d.tick_ts + dt

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
		self.systems_on_update[i]:on_update(dt, d.tick_ts, d)
	end
end

function simulation:queue_insert_entity(e)
	local d = self.store

	for i = 1, self.systems_on_queue_count do
		self.systems_on_queue[i]:on_queue(e, d, true)
	end

	d.pending_inserts[#d.pending_inserts + 1] = e
end

function simulation:queue_remove_entity(e)
	-- 这里做检查，避免重复移除同一个实体
	if e.pending_removal then
		return
	end

	local d = self.store

	for i = 1, self.systems_on_dequeue_count do
		self.systems_on_dequeue[i]:on_dequeue(e, d, false)
	end

	e.pending_removal = true
	self.store.pending_removals[#self.store.pending_removals + 1] = e
end

--- 我们乐观地认为，不可能存在对同一实体的重复插入。如果有，也是先移除了，然后重新插入
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

	d.entities[e.id] = e
-- d.entity_count = d.entity_count + 1
end

-- 由于有些实体自己会管理自己的 remove，同时有些实体会控制其它实体的 remove，所以我们需要在 remove_entity 里做检查，避免重复移除同一个实体导致的各种问题。
function simulation:remove_entity(e)
	local d = self.store

	-- 已经不在 store 里了，跳过后续所有逻辑
	if d.entities[e.id] == nil then
		return
	end

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
-- d.entity_count = d.entity_count - 1
end

return simulation
