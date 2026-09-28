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
local U=require("utils")
local V=require("lib.klua.vector")
require("all.constants")
require("lib.klua.table")
local function fts(t)
return t/FPS
end
local function AC(tpl,...)
return E:add_comps(tpl,...)
end
local function veznan_portal_update(this,store)
local spawns=this.spawn_groups[this.portal_idx]
local ni=this.out_nodes[this.pi]
while true do
while not this.spawn_signal do
coroutine.yield()
end
U.y_animation_play(this,"start",nil,store.tick_ts)
local roll=math.random()
local entity_data
for _,s in pairs(spawns) do
if roll<=s[1] then
entity_data=s[2]
break
end
end
U.animation_start_default(this,"active",nil,store.tick_ts,true)
for _,d in pairs(entity_data) do
local min,max,template=unpack(d)
local count=min~=max and math.random(min,max) or min
for i=1,count do
local e=E:create_entity(template)
e.nav_path.pi=this.pi
e.nav_path.spi=math.random(1,3)
e.nav_path.ni=ni
e.pos=V.vclone(this.pos)
simulation:queue_insert_entity(e)
U.y_wait_unconditional(store,this.spawn_interval)
end
end
U.y_animation_wait_default(this)
U.y_animation_play(this,"end",nil,store.tick_ts)
this.spawn_signal=nil
coroutine.yield()
end
end
local tt
tt=E:register_t_hot("decal_burner_big","decal_loop",true)
tt.render.sprites[1].anchor=vec_2(0.5,0.13)
tt.render.sprites[1].name="decal_burner_big_idle"
tt=E:register_t_hot("decal_burner_small","decal_loop",true)
tt.render.sprites[1].anchor=vec_2(0.5,0.11)
tt.render.sprites[1].name="decal_burner_small_idle"
tt=E:register_t_hot("veznan_portal","decal_scripted",true)
AC(tt,"editor")
tt.render.sprites[1].prefix="veznan_portal"
tt.render.sprites[1].z=Z_DECALS
tt.fx_out="fx_demon_portal_out"
tt.main_script.update=veznan_portal_update
tt.spawn_groups={{{0.5,{{4,7,"enemy_demon"}}},{0.8,{{3,3,"enemy_demon_wolf"}}},{1,{{5,5,"enemy_demon"},{1,1,"enemy_demon_mage"}}}},{{0.5,{{2,5,"enemy_demon"}}},{0.8,{{2,2,"enemy_demon_wolf"}}},{1,{{3,3,"enemy_demon"}}}},{{1,{{3,3,"enemy_demon"}}}}}
tt.portal_idx=1
tt.spawn_interval=fts(30)
tt.pi=1
end
function level:fn_can_power(store,power_id,pos)
return V.is_inside(pos,V.r(95,318,117,58))
end
function level:update(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
local boss=E:create_entity("eb_veznan")
boss.pos=V.vclone(boss.pos_castle)
LU.queue_insert(store,boss)
self.boss=boss
coroutine.yield()
U.y_wait_unconditional(store,1)
self.boss.phase_signal="welcome"
while self.boss.phase~="castle" do
coroutine.yield()
end
while not store.waves_finished or LU.has_alive_enemies(store,{"eb_veznan"}) do
coroutine.yield()
end
S:queue("MusicBossFight")
self.boss.phase_signal="descend"
while self.boss.phase~="death" do
coroutine.yield()
end
for _,e in pairs(store.entities) do
if e and e.tower then
e.tower.blocked=true
end
end
while self.boss.phase~="death-end" do
coroutine.yield()
end
store.custom_game_outcome={next_item_name="kr1_end"}
else
while store.wave_group_number<1 do
coroutine.yield()
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
end
return level
