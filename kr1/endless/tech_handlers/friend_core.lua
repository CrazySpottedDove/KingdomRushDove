local SU = require("script_utils")

local function register_friend_core_techs(registry, ctx)
	registry.register({
		id = "health",
		group = "friend_core",
		apply_runtime = function(level, store, endless)
			for _, s in pairs(store.soldiers) do
				if s.health then
					s.health.hp_max = s.health.hp_max * ctx.friend_buff.health_factor
					s.health.hp = s.health.hp_max
				end
			end

			endless.soldier_health_factor = endless.soldier_health_factor * ctx.friend_buff.health_factor
		end,
	})

	registry.register({
		id = "soldier_damage",
		group = "friend_core",
		apply_runtime = function(level, store, endless)
			for _, s in pairs(store.soldiers) do
				if s.unit then
					s.unit.damage_factor = s.unit.damage_factor * ctx.friend_buff.soldier_damage_factor
				end
			end

			endless.soldier_damage_factor = endless.soldier_damage_factor * ctx.friend_buff.soldier_damage_factor
		end,
	})

	registry.register({
		id = "soldier_cooldown",
		group = "friend_core",
		apply_runtime = function(level, store, endless)
			for _, s in pairs(store.soldiers) do
				if s.unit then
					SU.insert_unit_cooldown_buff(store.tick_ts, s, ctx.friend_buff.soldier_cooldown_factor)
				end
			end

			endless.soldier_cooldown_factor = endless.soldier_cooldown_factor * ctx.friend_buff.soldier_cooldown_factor
		end,
	})

	registry.register({
		id = "tower_damage",
		group = "friend_core",
		apply_runtime = function(level, store, endless)
			for _, t in pairs(store.towers) do
				SU.insert_tower_damage_factor_buff(t, ctx.friend_buff.tower_damage_factor)
			end

			endless.tower_damage_factor = endless.tower_damage_factor + ctx.friend_buff.tower_damage_factor
		end,
	})

	registry.register({
		id = "tower_cooldown",
		group = "friend_core",
		apply_runtime = function(level, store, endless)
			for _, t in pairs(store.towers) do
				SU.insert_tower_cooldown_buff(store.tick_ts, t, ctx.friend_buff.tower_cooldown_factor)
			end

			endless.tower_cooldown_factor = endless.tower_cooldown_factor * ctx.friend_buff.tower_cooldown_factor
		end,
	})

	registry.register({
		id = "hero_damage",
		group = "friend_core",
		apply_runtime = function(level, store, endless)
			for _, h in pairs(store.soldiers) do
				if h.hero then
					h.unit.damage_factor = h.unit.damage_factor * ctx.friend_buff.hero_damage_factor
					h.health.hp_max = h.health.hp_max * ctx.friend_buff.hero_health_factor
					h.health.hp = h.health.hp_max
				end
			end

			endless.hero_damage_factor = endless.hero_damage_factor * ctx.friend_buff.hero_damage_factor
			endless.hero_health_factor = endless.hero_health_factor * ctx.friend_buff.hero_health_factor
		end,
	})

	registry.register({
		id = "hero_cooldown",
		group = "friend_core",
		apply_runtime = function(level, store, endless)
			for _, h in pairs(store.soldiers) do
				if h.hero then
					SU.insert_unit_cooldown_buff(store.tick_ts, h, ctx.friend_buff.hero_cooldown_factor)
				end
			end

			endless.hero_cooldown_factor = endless.hero_cooldown_factor * ctx.friend_buff.hero_cooldown_factor
		end,
	})
end

return {
	register = register_friend_core_techs,
}
