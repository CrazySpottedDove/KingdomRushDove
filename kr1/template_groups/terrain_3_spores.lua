local E = require("entity_db")
local v = V.v
local scripts = require("game_scripts")
local tt
local function fts(v)
	return v / FPS
end

local controller_terrain_3_floating_elements = {}

function controller_terrain_3_floating_elements.update(this, store)
	this.floating_elems = {}

	local floating_elems_count = 0

	for _, e in pairs(store.entities) do
		if string.find(e.template_name, "decal_terrain_3_floating") then
			floating_elems_count = floating_elems_count + 1
			this.floating_elems[floating_elems_count] = e
			e.tween.ts = store.tick_ts + fts(math.random(0, 120))

			local frec = e.tween_frecueny + math.random(-50, 50)
			local amp = e.tween_amplitude + math.random(-5, 5)

			e.tween.props[1].keys = {{fts(0), v(0, 0)}, {fts(frec), v(0, amp)}, {fts(frec * 2), v(0, 0)}}
		end
	end
end

tt = E:register_t_hot("controller_terrain_3_floating_elements", nil, true)
E:add_comps(tt, "editor", "pos", "main_script")
tt.main_script.update = controller_terrain_3_floating_elements.update

tt = E:register_t_hot("ps_terrain_3_spores_1", nil, true)
E:add_comps(tt, "pos", "particle_system")
tt.pos = v(512, -20)
tt.particle_system.alphas = {200, 150, 200, 0}
tt.particle_system.emission_rate = 1.5
tt.particle_system.emit_area_spread = v(1300, 10)
tt.particle_system.emit_direction = math.pi * 3 / 8
tt.particle_system.emit_speed = {15, 25}
tt.particle_system.emit_spread = math.pi / 16
tt.particle_system.particle_lifetime = {35, 45}
tt.particle_system.scale_var = {0.6, 0.9}
tt.particle_system.ts_offset = -40
tt.particle_system.z = Z_OBJECTS_SKY
tt.particle_system.name = "T3_12_spore"

tt = E:register_t_hot("ps_terrain_3_spores_2", "ps_terrain_3_spores_1", true)
tt.particle_system.emit_direction = math.pi * 5 / 8

