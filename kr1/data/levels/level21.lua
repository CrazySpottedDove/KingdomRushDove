local signal=require("lib.hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("lib.klua.vector")
local P=require("path_db")
require("all.constants")
local function fts(v)
return v/FPS
end
local level={}
function level:init(store)
local E=require("entity_db")
require("all.constants")
require("lib.klua.table")
local tt
tt=E:register_t_hot("decal_inferno_portal","decal_demon_portal_big",true)
tt.render.sprites[1].name="decal_inferno_portal_active"
tt=E:register_t_hot("decal_inferno_ground_portal","decal_demon_portal_big",true)
tt.render.sprites[1].name="decal_inferno_ground_portal_active"
tt=E:register_t_hot("decal_s21_hellboy","decal",true)
tt.render.sprites[1].name="decal_s21_hellboy_idle"
tt=E:register_t_hot("decal_s21_veznan","decal",true)
tt.render.sprites[1].name="Inferno_Stg21_Veznan_0001"
tt.render.sprites[1].animated=false
tt=E:register_t_hot("decal_s21_veznan_free","decal",true)
tt.render.sprites[1].name="Inferno_Stg21_Veznan_0002"
tt.render.sprites[1].animated=false
end
function level:update(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
local boss=E:create_entity("eb_moloch")
boss.pos=V.vclone(boss.pos_sitting)
LU.queue_insert(store,boss)
self.boss=boss
coroutine.yield()
U.y_wait_unconditional(store,1)
while store.wave_group_number<boss.wave_active do
coroutine.yield()
end
boss.phase_signal="battle"
while self.boss.phase~="death-complete" do
coroutine.yield()
end
U.y_wait_unconditional(store,1)
end
end
return level
