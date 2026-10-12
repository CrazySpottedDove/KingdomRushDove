local W = {}
local GS = require("kr1.game_settings")
local signal = require("lib.hump.signal")

function W.next_wave_reward(store, group, remaining_secs)
	store.early_wave_reward = math.ceil(remaining_secs * GS.early_wave_reward_per_second)

	store.player_gold = store.player_gold + store.early_wave_reward

	for _, t in pairs(store.towers) do
		if t.template_name == "tower_miners" then
			local td = t.tower_upgrade_persistent_data
			if td.gold_ts then
				td.gold_ts = td.gold_ts - remaining_secs
			end
			if td.gold_rush_acum then
				td.gold_rush_acum = td.gold_rush_acum + remaining_secs
			end
		end
	end

	signal.emit("early-wave-called", group, store.early_wave_reward, remaining_secs)
end

return W
