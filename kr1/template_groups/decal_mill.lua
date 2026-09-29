local E = require("entity_db")
local tt
tt = E:register_t_hot("decal_mill_big", "decal_click_pause", true)
tt.render.sprites[1].name = "decal_mill_big"
tt.ui.can_select = false
tt.ui.click_rect = r(-10, -30, 40, 65)

tt = E:register_t_hot("decal_mill_small", "decal_mill_big", true)
tt.render.sprites[1].name = "decal_mill_small"
tt.ui.click_rect = r(-10, -25, 35, 55)

