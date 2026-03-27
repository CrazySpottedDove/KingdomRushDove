local E = require("entity_db")
local U = require("utils")
local UP = require("kr1.upgrades")
local scripts = require("scripts")

local function patch_archer_bleed(level, ctx)
	local mod = E:get_template("mod_blood_elves")
	mod.damage_factor = 0.1 + ctx.friend_buff.archer_bleed * level
end

local function patch_archer_insight(level, ctx)
	for _, name in ipairs(UP.arrows) do
		local arrow = E:get_template(name)

		if not arrow._endless_archer_insight then
			U.append_mod(arrow.bullet, "mod_endless_archer_insight")
		end

		local mod = E:get_template("mod_endless_archer_insight")
		mod.modifier.health_damage_factor_inc = level * ctx.friend_buff.archer_insight
	end
end

local function patch_archer_multishot(level)
	for _, name in ipairs(table.append(UP.arrows, {"arrow_arcane_burst"}, true)) do
		local arrow = E:get_template(name)

		if not arrow._endless_multishot then
			arrow.main_script.insert = U.function_append(arrow.main_script.insert, scripts.arrow_endless_multishot.insert)
		end

		arrow._endless_multishot = level
	end
end

local function patch_archer_critical(level, ctx)
	for _, name in pairs(table.append(UP.arrows, {"arrow_arcane_burst"}, true)) do
		local arrow = E:get_template(name)

		if not arrow._endless_archer_critical then
			arrow.main_script.insert = U.function_append(function(this, store)
				if not this.bullet._endless_archer_critical then
					this.bullet._endless_archer_critical = true

					if math.random() < this._endless_archer_critical then
						this.bullet.damage_factor = this.bullet.damage_factor * 3

						if not (this.bullet.pop and table.contains(this.bullet.pop, "pop_headshot")) then
							this.bullet.pop = {"pop_crit"}
							this.bullet.pop_conds = DR_DAMAGE
						end
					end
				end

				return true
			end, arrow.main_script.insert)
		end

		arrow._endless_archer_critical = level * ctx.friend_buff.archer_critical
	end
end

local function register_archer_techs(registry, ctx)
	registry.register({
		id = "archer_bleed",
		group = "archer",
		apply_template = function(level, endless)
			patch_archer_bleed(level, ctx)
		end,
		apply_runtime = function(level, store, endless)
			patch_archer_bleed(level, ctx)
		end,
	})

	registry.register({
		id = "archer_insight",
		group = "archer",
		apply_template = function(level, endless)
			patch_archer_insight(level, ctx)
		end,
		apply_runtime = function(level, store, endless)
			patch_archer_insight(level, ctx)
		end,
	})

	registry.register({
		id = "archer_multishot",
		group = "archer",
		apply_template = function(level, endless)
			patch_archer_multishot(level)
		end,
		apply_runtime = function(level, store, endless)
			patch_archer_multishot(level)
		end,
	})

	registry.register({
		id = "archer_critical",
		group = "archer",
		apply_template = function(level, endless)
			patch_archer_critical(level, ctx)
		end,
		apply_runtime = function(level, store, endless)
			patch_archer_critical(level, ctx)
		end,
	})
end

return {
	register = register_archer_techs,
}
