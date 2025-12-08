local log=require("lib.klua.log"):new("level17")
local signal=require("hump.signal")
local km=require("lib.klua.macros")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("lib.klua.vector")
local P=require("path_db")
require("constants")
local function fts(v)
return v/FPS
end
local level={}
function level:update(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
self.megaspawner=LU.list_entities(store.entities,"mega_spawner")[1]
local boss=E:create_entity("eb_bram")
boss.pos=V.vclone(boss.pos_sitting)
LU.queue_insert(store,boss)
self.boss=boss
coroutine.yield()
U.y_wait(store,1)
boss.phase_signal="welcome"
while self.boss.phase~="sitting" do
coroutine.yield()
end
while store.wave_group_number<1 do
coroutine.yield()
end
while not store.waves_finished or select(2,LU.has_alive_enemies(store))>1 do
coroutine.yield()
end
boss.phase_signal="prebattle"
while self.boss.phase~="battle" do
coroutine.yield()
end
P:activate_path(boss.nav_path.pi)
local spawn_idx=1
while self.boss.phase~="dead" do
if boss.nav_path.ni==boss.spawn_at_nodes[spawn_idx] then
self.megaspawner.manual_wave=boss.spawn_wave_names[spawn_idx]
spawn_idx=km.zmod(spawn_idx+1,#boss.spawn_at_nodes)
end
coroutine.yield()
end
self.megaspawner.interrupt=true
while self.boss.phase~="death-complete" do
coroutine.yield()
end
U.y_wait(store,1)
end
end
return level
