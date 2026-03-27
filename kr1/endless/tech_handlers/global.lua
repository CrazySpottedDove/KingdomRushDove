local Common = require("kr1.endless.tech_handlers.common")

local function register_global_techs(registry, ctx)
	local function register_ban_tech(id, list_key)
		registry.register({
			id = id,
			group = "ban",
			apply_template = function(level, endless)
				Common.remove_upgrade_group(endless, ctx.EL[list_key])
			end,
			apply_runtime = function(level, store, endless)
				Common.remove_upgrade_group(endless, ctx.EL[list_key])
			end,
		})
	end

	registry.register({
		id = "more_gold",
		group = "global",
		apply_runtime = function(level, store, endless)
			endless.enemy_gold_factor = endless.enemy_gold_factor + ctx.friend_buff.more_gold
		end,
	})

	register_ban_tech("ban_rain", "rain")

	register_ban_tech("ban_archer", "archer")
	register_ban_tech("ban_barrack", "barrack")
	register_ban_tech("ban_engineer", "engineer")
	register_ban_tech("ban_mage", "mage")
end

return {
	register = register_global_techs,
}
