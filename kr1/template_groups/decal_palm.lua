local E = require("entity_db")
local tt
tt = E:register_t_hot("decal_palm_tree", "decal_timed", true)
-- tt.timed.disabled = true
tt.timed.runs = INT_32_MAX
tt.render.sprites[1].prefix = "decal_palm_tree"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].sort_y_offset = -40

tt = E:register_t_hot("decal_palm_land", "decal_tween", true)
tt.pos = vec_2(REF_W * 0.5, REF_H * 0.5)
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {0.4, 0}}
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BACKGROUND_COVERS

