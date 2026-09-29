local E = require("entity_db")
local U = require("utils")
require("lib.klua.table")
local scripts = require("scripts")
local aura_stage_14_prevent_polymorph_update
aura_stage_14_prevent_polymorph_update = function(this, store)
	local first_hit_ts
	local last_hit_ts = 0
	local cycles_count = 0
	last_hit_ts = store.tick_ts - this.aura.cycle_time
	while true do
		if store.tick_ts - last_hit_ts >= this.aura.cycle_time then
			first_hit_ts = first_hit_ts or store.tick_ts
			last_hit_ts = store.tick_ts
			cycles_count = cycles_count + 1
			local targets = table.filter(store.enemies, function(k, v)
				return v.unit and v.health and not v.health.dead and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius) and not U.flag_has(v.vis.bans, F_POLYMORPH) and (v.nav_path.pi == 2 or v.nav_path.pi == 3) and (not this.aura.allowed_templates or table.contains(this.aura.allowed_templates, v.template_name))
			end)
			for i, target in ipairs(targets) do
				target.vis.bans = U.flag_set(target.vis.bans, F_POLYMORPH)
			end
		end
		coroutine.yield()
	end
	simulation:queue_remove_entity(this)
end
local tt
tt = E:register_t_hot("decal_terrain_3_glare_eye_big_stage_14", "decal_terrain_3_glare_eye_big", true)
tt.render.sprites[1].name = "glare_stage_14_eye_2_big"
tt.render.sprites[2].prefix = "glare_stage_14_eyelid_2_big"
tt.render.sprites[3].prefix = "glare_stage_14_eye_2_big_pupil"
tt = E:register_t_hot("decal_stage_14_mask_amalgam", "decal_stage_14_mask_1", true)
tt.render.sprites[1].name = "T3_S14_mask_amalgam"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = 90
tt = E:register_t_hot("decal_stage_14_glare_1", "decal_stage_12_glare", true)
tt.render.sprites[1].prefix = "stage_14_glare_1Def"
tt = E:register_t_hot("decal_terrain_3_glare_eye_small_3_stage_14", "decal_terrain_3_glare_eye_small", true)
tt.render.sprites[1].prefix = "glare_stage_14_eye_2_3"
tt.render.sprites[2].prefix = "glare_stage_14_eyelid_2_3"
tt = E:register_t_hot("decal_stage_14_mask_3", "decal_stage_14_mask_1", true)
tt.render.sprites[1].name = "T3_S14_mask_03"
tt = E:register_t_hot("decal_stage_14_glare_2", "decal_stage_12_glare", true)
tt.render.sprites[1].prefix = "stage_14_glare_2Def"
tt = E:register_t_hot("decal_terrain_3_glare_eye_small_2_stage_14", "decal_terrain_3_glare_eye_small", true)
tt.render.sprites[1].prefix = "glare_stage_14_eye_2_2"
tt.render.sprites[2].prefix = "glare_stage_14_eyelid_2_2"
tt = E:register_t_hot("decal_stage_14_hidden_path_dust", "decal", true)
tt.render.sprites[1].prefix = "dust_pathDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t_hot("decal_stage_14_tentacles", "decal_stage_12_tentacles", true)
tt.render.sprites[1].prefix = "BKtentacle14Def"
tt = E:register_t_hot("decal_stage_14_mask_2", "decal_stage_14_mask_1", true)
tt.render.sprites[1].name = "T3_S14_mask_02"
tt = E:register_t_hot("aura_stage_14_prevent_polymorph", "aura", true)
tt.aura.duration = 1e+99
tt.aura.cycle_time = 0.25
tt.aura.radius = 100
tt.aura.allowed_templates = {"enemy_glareling"}
tt.main_script.update = aura_stage_14_prevent_polymorph_update
tt = E:register_t_hot("decal_stage_14_mask_4", "decal_stage_14_mask_1", true)
tt.render.sprites[1].name = "T3_S14_mask_04"
tt = E:register_t_hot("decal_terrain_3_glare_eye_small_1_stage_14", "decal_terrain_3_glare_eye_small", true)
tt.render.sprites[1].prefix = "glare_stage_14_eye_2_1"
tt.render.sprites[2].prefix = "glare_stage_14_eyelid_2_1"
tt = E:register_t_hot("decal_stage_14_hidden_path", "decal", true)
tt.render.sprites[1].prefix = "hidden_pathDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
