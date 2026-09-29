local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local V = require("lib.klua.vector")
require("all.constants")
require("lib.klua.table")
local function AC(tpl, ...)
	return E:add_comps(tpl, ...)
end
local function s11_lava_spawner_update(this, store)
	local cooldown = this.cooldown
	while store.wave_group_number < 1 do
		coroutine.yield()
	end
	while true do
		U.y_wait_unconditional(store, cooldown)
		S:queue(this.sound)
		local e = E:create_entity(this.entity)
		e.pos = V.vclone(this.pos)
		e.nav_path.pi, e.nav_path.spi, e.nav_path.ni = this.pi, 1, 1
		e.render.sprites[1].name = "raise"
		simulation:queue_insert_entity(e)
		cooldown = this.cooldown_after
	end
end
local tt
tt = E:register_t_hot("s11_lava_spawner", nil, true)
AC(tt, "main_script")
tt.main_script.update = s11_lava_spawner_update
tt.entity = "enemy_lava_elemental"
tt.cooldown = 400
tt.cooldown_after = 120
tt.pi = 4
tt.sound = "RockElementalDeath"
