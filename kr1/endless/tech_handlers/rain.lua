local E = require("entity_db")
local U = require("utils")

local function vv(x)
	return {
		x = x,
		y = x
	}
end

local function patch_rain_count_inc(level, ctx)
	local controller = E:get_template("power_fireball_control")
	controller.cataclysm_count = controller.cataclysm_count + level * ctx.friend_buff.rain_count_inc
	controller.fireball_count = controller.fireball_count + level * ctx.friend_buff.rain_count_inc
end

local function patch_rain_damage_inc(level, ctx)
	local fireball = E:get_template("power_fireball")
	fireball.bullet.damage_min = fireball.bullet.damage_min + level * ctx.friend_buff.rain_damage_inc
	fireball.bullet.damage_max = fireball.bullet.damage_max + level * ctx.friend_buff.rain_damage_inc

	local scorched_water = E:get_template("power_scorched_water")
	scorched_water.aura.damage_min = scorched_water.aura.damage_min + level * ctx.friend_buff.rain_damage_inc * 0.1
	scorched_water.aura.damage_max = scorched_water.aura.damage_max + level * ctx.friend_buff.rain_damage_inc * 0.1

	local scorched_earth = E:get_template("power_scorched_earth")
	scorched_earth.aura.damage_min = scorched_earth.aura.damage_min + level * ctx.friend_buff.rain_damage_inc * 0.1
	scorched_earth.aura.damage_max = scorched_earth.aura.damage_max + level * ctx.friend_buff.rain_damage_inc * 0.1

	local thunder = E:get_template("power_thunder_control")
	thunder.thunders[1].damage_min = thunder.thunders[1].damage_min + level * ctx.friend_buff.rain_damage_inc * 0.5
	thunder.thunders[1].damage_max = thunder.thunders[1].damage_max + level * ctx.friend_buff.rain_damage_inc * 0.5
	thunder.thunders[2].damage_min = thunder.thunders[2].damage_min + level * ctx.friend_buff.rain_damage_inc * 0.5
	thunder.thunders[2].damage_max = thunder.thunders[2].damage_max + level * ctx.friend_buff.rain_damage_inc * 0.5

	thunder = E:get_template("endless_mage_thunder")
	thunder.thunders[1].damage_min = thunder.thunders[1].damage_min + level * ctx.friend_buff.rain_damage_inc * 0.5
	thunder.thunders[1].damage_max = thunder.thunders[1].damage_max + level * ctx.friend_buff.rain_damage_inc * 0.5
	thunder.thunders[2].damage_min = thunder.thunders[2].damage_min + level * ctx.friend_buff.rain_damage_inc * 0.5
	thunder.thunders[2].damage_max = thunder.thunders[2].damage_max + level * ctx.friend_buff.rain_damage_inc * 0.5
end

local function patch_rain_radius_mul(level, ctx)
	local fireball = E:get_template("power_fireball")
	fireball.bullet.damage_radius = fireball.bullet.damage_radius * ctx.friend_buff.rain_radius_mul ^ level
	fireball.render.sprites[1].scale = vv(ctx.friend_buff.rain_radius_mul ^ level)

	local scorched_water = E:get_template("power_scorched_water")
	scorched_water.aura.radius = scorched_water.aura.radius * ctx.friend_buff.rain_radius_mul ^ level
	scorched_water.render.sprites[1].scale = vv(ctx.friend_buff.rain_radius_mul ^ level)

	local scorched_earth = E:get_template("power_scorched_earth")
	scorched_earth.aura.radius = scorched_earth.aura.radius * ctx.friend_buff.rain_radius_mul ^ level
	scorched_earth.render.sprites[1].scale = vv(ctx.friend_buff.rain_radius_mul ^ level)
end

local function patch_rain_cooldown_dec(level, ctx)
	local controller = E:get_template("power_fireball_control")
	controller.cooldown = controller.cooldown - level * ctx.friend_buff.rain_cooldown_dec
end

local function patch_rain_scorch_damage_true(level, ctx)
	local scorched_earth = E:get_template("power_scorched_earth")
	scorched_earth.aura.damage_type = DAMAGE_TRUE
	scorched_earth.aura.damage_min = scorched_earth.aura.damage_min + level * ctx.friend_buff.rain_scorch_damage_true
	scorched_earth.aura.damage_max = scorched_earth.aura.damage_max + level * ctx.friend_buff.rain_scorch_damage_true

	local scorched_water = E:get_template("power_scorched_water")
	scorched_water.aura.damage_type = DAMAGE_TRUE
	scorched_water.aura.damage_min = scorched_water.aura.damage_min + level * ctx.friend_buff.rain_scorch_damage_true
	scorched_water.aura.damage_max = scorched_water.aura.damage_max + level * ctx.friend_buff.rain_scorch_damage_true
end

local function patch_rain_thunder(level)
	local controller = E:get_template("power_fireball_control")

	if not controller._endless_rain_thunder then
		controller.main_script.insert = U.function_append(controller.main_script.insert, function(this, store)
			local thunder = E:create_entity("power_thunder_control")
			thunder.slow.disabled = false
			thunder.rain.disabled = false
			thunder.thunders[1].count = this.fireball_count
			thunder.thunders[2].count = this.cataclysm_count
			simulation:queue_insert_entity(thunder)
			return true
		end)
		controller._endless_rain_thunder = true
	end
end

local function register_rain_techs(registry, ctx)
	registry.register({
		id = "rain_count_inc",
		group = "rain",
		apply_template = function(level, endless)
			patch_rain_count_inc(level, ctx)
		end,
		apply_runtime = function(level, store, endless)
			patch_rain_count_inc(1, ctx)
		end,
	})

	registry.register({
		id = "rain_damage_inc",
		group = "rain",
		apply_template = function(level, endless)
			patch_rain_damage_inc(level, ctx)
		end,
		apply_runtime = function(level, store, endless)
			patch_rain_damage_inc(1, ctx)
		end,
	})

	registry.register({
		id = "rain_radius_mul",
		group = "rain",
		apply_template = function(level, endless)
			patch_rain_radius_mul(level, ctx)
		end,
		apply_runtime = function(level, store, endless)
			patch_rain_radius_mul(1, ctx)
		end,
	})

	registry.register({
		id = "rain_cooldown_dec",
		group = "rain",
		apply_template = function(level, endless)
			patch_rain_cooldown_dec(level, ctx)
		end,
		apply_runtime = function(level, store, endless)
			patch_rain_cooldown_dec(1, ctx)
			store.game_gui.power_1:set_cooldown_time(E:get_template("power_fireball_control").cooldown)
		end,
	})

	registry.register({
		id = "rain_scorch_damage_true",
		group = "rain",
		apply_template = function(level, endless)
			patch_rain_scorch_damage_true(level, ctx)
		end,
		apply_runtime = function(level, store, endless)
			patch_rain_scorch_damage_true(1, ctx)
		end,
	})

	registry.register({
		id = "rain_thunder",
		group = "rain",
		apply_template = function(level, endless)
			patch_rain_thunder(level)
		end,
		apply_runtime = function(level, store, endless)
			patch_rain_thunder(1)
		end,
	})
end

return {
	register = register_rain_techs,
}
