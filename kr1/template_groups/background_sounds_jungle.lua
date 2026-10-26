local E = require("entity_db")
local tt
tt = E:register_t("background_sounds_jungle", "background_sounds", true)
tt.min_delay = 20
tt.sounds = {"JungleAmbienceSound"}

