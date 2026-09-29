local E = require("entity_db")
local tt
tt = E:register_t_hot("background_sounds_underground", "background_sounds", true)
tt.max_delay = 20
tt.sounds = {"UndergroundAmbienceSound"}

