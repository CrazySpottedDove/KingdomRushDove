local E = require("entity_db")
local U = require("utils")
local UP = require("kr1.upgrades")
local Common = require("kr1.endless.tech_handlers.common")

local function patch_barrack_luck(level, ctx)
	for _, name in pairs(UP.soldiers) do
		local s = E:get_template(name)

		if not s._endless_barrack_luck then
			s.health.on_damage = U.function_append(s.health.on_damage, function(this, store, damage)
				return math.random() > this._endless_barrack_luck
			end)
		end

		s._endless_barrack_luck = level * ctx.friend_buff.barrack_luck
	end
end

local function patch_barrack_unity(level, ctx)
	for _, name in pairs(UP.towers_with_barrack) do
		if name ~= "tower_pandas_lvl4" then
			local t = E:get_template(name)
			t.barrack.max_soldiers = t.barrack.max_soldiers + level * ctx.friend_buff.barrack_unity_count
		end
	end

	for _, name in pairs(UP.soldiers) do
		local s = E:get_template(name)
		s.health.dead_lifetime = s.health.dead_lifetime - ctx.friend_buff.barrack_unity_lifetime * level
	end
end

local function patch_barrack_synergy(level, ctx)
	for _, name in pairs(UP.soldiers) do
		local s = E:get_template(name)

		if not s._barrack_synergy then
			if s.main_script then
				s.main_script.insert = U.function_append(s.main_script.insert, function(this, store)
					local a = E:create_entity("endless_barrack_synergy_aura")
					a.aura.source_id = this.id
					Common.queue_insert(store, a)
					this._barrack_synergy_aura = a
					return true
				end)
				s.main_script.remove = U.function_append(s.main_script.remove, function(this, store)
					if this._barrack_synergy_aura then
						Common.queue_remove(store, this._barrack_synergy_aura)
					end
					return true
				end)
			end

			s._barrack_synergy = true
		end
	end

	local m = E:get_template("mod_endless_barrack_synergy")
	m.extra_damage = level * ctx.friend_buff.barrack_synergy
end

local function patch_barrack_rally(level)
	for _, name in pairs(UP.towers_with_barrack) do
		local t = E:get_template(name)
		t.barrack.rally_range = math.huge
	end

	local pixie_tower = E:get_template("tower_pixie")
	pixie_tower.attacks.range = math.huge
end

local function patch_barrack_rally_runtime(level, store)
	for _, t in pairs(store.towers) do
		if t.barrack then
			t.barrack.rally_range = math.huge
		end
	end
end

local function patch_barrack_unity_runtime(level, store, ctx)
	for _, t in pairs(store.towers) do
		if t.barrack then
			t.barrack.max_soldiers = t.barrack.max_soldiers + ctx.friend_buff.barrack_unity_count
		elseif t.template_name == "tower_pixie" then
			t.attacks.range = math.huge
		end
	end
end

local function patch_barrack_luck_runtime(level, store, ctx)
	for _, s in pairs(store.soldiers) do
		if s.health then
			if not s._endless_barrack_luck then
				s.health.on_damage = U.function_append(s.health.on_damage, function(this, store, damage)
					return math.random() > this._endless_barrack_luck
				end)
			end

			s._endless_barrack_luck = level * ctx.friend_buff.barrack_luck
		end
	end
end

local function patch_barrack_synergy_runtime(level, store)
	for _, s in pairs(store.soldiers) do
		if not s._barrack_synergy_aura then
			local a = E:create_entity("endless_barrack_synergy_aura")
			a.aura.source_id = s.id
			Common.queue_insert(store, a)
			s._barrack_synergy_aura = a

			if s.main_script then
				s.main_script.remove = U.function_append(s.main_script.remove, function(this, store)
					if this._barrack_synergy_aura then
						Common.queue_remove(store, this._barrack_synergy_aura)
					end
					return true
				end)
			end
		end
	end
end

local function register_barrack_techs(registry, ctx)
	registry.register({
		id = "barrack_rally",
		group = "barrack",
		apply_template = function(level, endless)
			patch_barrack_rally(level)
		end,
		apply_runtime = function(level, store, endless)
			patch_barrack_rally_runtime(level, store)
			patch_barrack_rally(level)
		end,
	})

	registry.register({
		id = "barrack_unity",
		group = "barrack",
		apply_template = function(level, endless)
			patch_barrack_unity(level, ctx)
		end,
		apply_runtime = function(level, store, endless)
			patch_barrack_unity_runtime(level, store, ctx)
			patch_barrack_unity(level, ctx)
		end,
	})

	registry.register({
		id = "barrack_luck",
		group = "barrack",
		apply_template = function(level, endless)
			patch_barrack_luck(level, ctx)
		end,
		apply_runtime = function(level, store, endless)
			patch_barrack_luck(level, ctx)
			patch_barrack_luck_runtime(level, store, ctx)
		end,
	})

	registry.register({
		id = "barrack_synergy",
		group = "barrack",
		apply_template = function(level, endless)
			patch_barrack_synergy(level, ctx)
		end,
		apply_runtime = function(level, store, endless)
			patch_barrack_synergy_runtime(level, store)
			patch_barrack_synergy(level, ctx)
		end,
	})
end

return {
	register = register_barrack_techs,
}
