local systems_list = {
	"level",
	"tween",
	"render",
	"tower",
	"main_script",
	"health",
	"count_groups",
	"timed",
	"sound_events",
	"events",
	"wave_spawn_tsv",
	"wave_spawn",
	"mod_lifecycle",
	"particle_system",
	"editor_overrides",
	"editor_script",
	"last_hook",
	"assets_checker",
	"endless",
	"tower_skill",
	"enemy"
}

local systems = {}

for i = 1, #systems_list do
	local name = systems_list[i]
	local system = require("all.systems." .. name)
	if system then
		systems[name] = system
	end
end

return systems
