-- chunkname: @./all/entity_db.lua

local log = require("klua.log"):new("entity_db")

require("klua.table")

local copy = table.deepclone
local entity_db = {}

entity_db.last_id = 1

function entity_db:load()
	self.last_id = 1
	self.components = {}
	self.entities = {}
	package.loaded.components = nil
	package.loaded.game_templates = nil
	package.loaded.templates = nil
	package.loaded.game_scripts = nil
	package.loaded.scripts = nil
	package.loaded.script_utils = nil
    package.loaded["kr1.data.balance"] = nil
	require("components")
	require("templates")
	require("game_templates")
end

-- 性能与内存测试函数
function entity_db:test()
    -- 记录初始内存
    collectgarbage("collect")
    local mem_before = collectgarbage("count") -- 单位：KB

    local t0 = os.clock()
    self:load()
    local t1 = os.clock()

    -- 统计模板数量
    local template_count = 0
    if self.entities then
        for _ in pairs(self.entities) do
            template_count = template_count + 1
        end
    end

    -- 统计组件数量
    local component_count = 0
    if self.components then
        for _ in pairs(self.components) do
            component_count = component_count + 1
        end
    end

    -- 记录load后内存
    collectgarbage("collect")
    local mem_after = collectgarbage("count") -- 单位：KB

    print("entity_db:load() 用时: " .. string.format("%.4f", t1 - t0) .. " 秒")
    print("entity_db:load() 前内存: " .. string.format("%.2f", mem_before) .. " KB")
    print("entity_db:load() 后内存: " .. string.format("%.2f", mem_after) .. " KB")
    print("entity_db:load() 增加内存: " .. string.format("%.2f", mem_after - mem_before) .. " KB")
    print("模板数量: " .. template_count)
    print("组件数量: " .. component_count)

    -- 可选：测试批量创建实体的性能和内存
    local create_count = 1000
    local t2 = os.clock()
    local tmp_entities = {}
    for k in pairs(self.entities) do
        for i = 1, create_count do
            tmp_entities[#tmp_entities + 1] = self:create_entity(k)
        end
        break -- 只测一个模板
    end
    local t3 = os.clock()
    collectgarbage("collect")
    local mem_entities = collectgarbage("count")
    print("批量创建 " .. create_count .. " 个实体用时: " .. string.format("%.4f", t3 - t2) .. " 秒")
    print("批量创建后内存: " .. string.format("%.2f", mem_entities) .. " KB")
    print("批量创建增加内存: " .. string.format("%.2f", mem_entities - mem_after) .. " KB")
end

function entity_db:register_t(name, base)
	if self.entities[name] then
		log.error("template %s already exists", name)

		return
	end

	local t

	if base then
		-- if type(base) == "string" then
		-- 	base = self.entities[base]
		-- end

        -- if type(base) ~= "string" then
        --     log.error("template base for %s must be a string", name)
        --     return
        -- end

        -- if self.entities[base] == nil then
        --     log.error("template base %s for %s does not exist", base, name)
        --     return
        -- end

		-- t = copy(base)
        t = copy(self.entities[base])
	else
		t = {}
	end

	t.template_name = name
	self.entities[name] = t

	return t
end

function entity_db:register_c(name, base)
	if self.components[name] then
		log.error("component %s already exists", name)

		return
	end

	local c = {}

	if base then
		-- if type(base) == "string" then
		-- 	base = self.components[base]
		-- end

		-- c = copy(base)
        c = copy(self.components[base])
	end

	self.components[name] = c

	return c
end

function entity_db:clone_c(name)
	if not self.components[name] then
		log.error("component %s does not exist", name)

		return
	end

	return copy(self.components[name])
end

function entity_db:add_comps(entity, ...)
	if entity == nil then
		log.error("entity is nil")

		return
	end

	for _, v in pairs({
		...
	}) do
		if not self.components[v] then
			log.error("component %s does not exist", v)

			return
		end

		entity[v] = copy(self.components[v])
	end
end

--- 只接收字符串模板名，创建对应实体
---@param t string 模板名
function entity_db:create_entity(t)
	local tpl = self.entities[t]

	-- if type(t) == "string" then
	-- 	tpl = self.entities[t]
	-- else
	-- 	tpl = t
	-- end

	if not tpl then
		log.error("template %s not found", t)

		return nil
	end

	local out = copy(tpl)

	out.id = self.last_id
	self.last_id = self.last_id + 1

	return out
end

function entity_db:clone_entity(e)
	local out = copy(e)

	out.id = self.last_id
	self.last_id = self.last_id + 1

	return out
end

function entity_db:append_templates(entity, ...)
	if entity == nil then
		log.error("entity is nil")

		return
	end

	for _, tn in pairs({
		...
	}) do
		local tpl = self.entities[tn]

		if not tpl then
			log.error("template %s not found", tn)

			return
		end

		for k, v in pairs(tpl) do
			entity[k] = copy(v)
		end
	end
end

function entity_db:get_component(c)
	local cmp

	if type(c) == "string" then
		cmp = self.components[c]
	else
		cmp = c
	end

	if not cmp then
		log.error("component %s not found", c)

		return nil
	end

	return cmp
end

--- 获取对应实体模板
---@param t string 模板名
function entity_db:get_template(t)
	local tpl = self.entities[t]

	-- if type(t) == "string" then
	-- 	tpl = self.entities[t]
	-- else
	-- 	tpl = t
	-- end

	if not tpl then
		log.error("template %s not found", t)

		return nil
	end

	return tpl
end

function entity_db:set_template(name, t)
	self.entities[name] = t
end

function entity_db:filter(entities, ...)
	local result = {}

	for id, e in pairs(entities) do
		for _, n in pairs({
			...
		}) do
			if not e[n] then
				goto label_12_0
			end
		end

		table.insert(result, e)

		::label_12_0::
	end

	return result
end

function entity_db:filter_iter(entities, c1, c2, c3)
	local function next_entity(t, i)
		local k, v = i

		while true do
			::label_14_0::

			k, v = next(t, k)

			if not k then
				return nil
			end

			if c1 and not v[c1] then
				goto label_14_0
			end

			if c2 and not v[c2] then
				goto label_14_0
			end

			if c3 and not v[c3] then
				goto label_14_0
			end

			return k, v
		end
	end

	return next_entity, entities, nil
end

function entity_db:filter_templates(...)
	return self:filter(self.entities, ...)
end

function entity_db:search_entity(p)
	local results = {}

	for k, e in pairs(self.entities) do
		if string.match(k, p) then
			table.insert(results, k)
		end
	end

	return results
end

return entity_db
