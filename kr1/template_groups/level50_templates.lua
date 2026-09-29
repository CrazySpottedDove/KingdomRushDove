local E = require("entity_db")
require("all.constants")
require("lib.klua.table")
local tt
tt = E:register_t_hot("decal_water_sparks_small", "decal_loop", true)
tt.render.sprites[1].name = "decal_water_sparks_idle"
tt.render.sprites[1].scale = vec_2(0.6, 0.6)
tt = E:register_t_hot("decal_water_wave_3", "decal_loop", true)
tt.render.sprites[1].name = "decal_water_wave_3_play"
tt = E:register_t_hot("decal_water_wave_4", "decal_loop", true)
tt.render.sprites[1].name = "decal_water_wave_4_play"
tt = E:register_t_hot("decal_water_splash", "decal_loop", true)
tt.render.sprites[1].name = "decal_water_splash_play"
tt = E:register_t_hot("decal_stage_02_waterfall_1", "decal", true)
tt.render.sprites[1].name = "decal_stage_02_waterfall_1_idle"
tt = E:register_t_hot("decal_stage_02_waterfall_2", "decal", true)
tt.render.sprites[1].name = "decal_stage_02_waterfall_2_idle"
tt = E:register_t_hot("decal_stage_02_waterfall_3", "decal", true)
tt.render.sprites[1].name = "decal_stage_02_waterfall_3_idle"
tt = E:register_t_hot("decal_stage_02_waterfall_4", "decal", true)
tt.render.sprites[1].name = "decal_stage_02_waterfall_4_idle"
tt = E:register_t_hot("decal_stage_02_bigwaves", "decal", true)
tt.render.sprites[1].name = "decal_stage_02_bigwaves_idle"
tt = E:register_t_hot("decal_stage_02_bridge_mask", "decal", true)
tt.render.sprites[1].name = "stage2_bridge"
tt.render.sprites[1].animated = false
tt = E:register_t_hot("decal_stage_02_bridge_shadows", "decal", true)
tt.render.sprites[1].name = "stage2_shadows"
tt.render.sprites[1].animated = false
