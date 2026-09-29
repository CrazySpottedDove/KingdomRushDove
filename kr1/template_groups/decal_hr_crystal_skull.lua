local E = require("entity_db")
local tt
tt = E:register_t_hot("decal_hr_crystal_skull", "decal_delayed_click_play", true)
tt.render.sprites[1].prefix = "decal_hr_crystal_skull"
tt.delayed_play.play_once = true
tt.delayed_play.required_clicks = 1
tt.delayed_play.click_interrupts = true
tt.delayed_play.clicked_sound = "ElvesCrystalSkull"
tt.ui.can_select = false
tt.ui.click_rect = r(-13, -13, 28, 24)

