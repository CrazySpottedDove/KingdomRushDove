local level={}
function level:init(store)
local E=require("entity_db")
local U=require("utils")
require("all.constants")
require("lib.klua.table")
local function AC(tpl,...)
return E:add_comps(tpl,...)
end
local function decal_crane_update(this,store)
local clicks=0
local max_clicks=math.random(this.final_clicks[1],this.final_clicks[2])
local play_ts=store.tick_ts
local play_time=U.frandom(this.play_time[1],this.play_time[2])
while true do
if this.ui.clicked then
clicks=clicks+1
if max_clicks<=clicks then
this.render.sprites[2].hidden=true
U.y_animation_play(this,this.final_click_animation,nil,store.tick_ts,1,1)
simulation:queue_remove_entity(this)
return
else
U.y_animation_play(this,this.click_animation,nil,store.tick_ts,1,1)
U.animation_start(this,"idle",nil,store.tick_ts,true,1)
end
this.ui.clicked=nil
play_ts=store.tick_ts
end
if play_time<store.tick_ts-play_ts then
play_ts=store.tick_ts
play_time=U.frandom(this.play_time[1],this.play_time[2])
U.y_animation_play(this,this.play_animation,nil,store.tick_ts,1,1)
U.animation_start(this,"idle",nil,store.tick_ts,true,1)
this.ui.clicked=nil
end
coroutine.yield()
end
end
local function river_object_controller_update(this,store)
while store.wave_group_number<1 do
coroutine.yield()
end
local spawn_ts=store.tick_ts
local spawn_time=U.frandom(this.min_time,this.max_time)
local chests=0
local name="hobbit"
while true do
if spawn_time<store.tick_ts-spawn_ts then
spawn_time=U.frandom(this.min_time,this.max_time)
spawn_ts=store.tick_ts
if name~="hobbit" then
name="hobbit"
else
name=table.random(this.river_objects)
if name=="chest" then
chests=chests+1
if chests>=this.max_chests then
table.removeobject(this.river_objects,"chest")
end
end
end
local e=E:create_entity("decal_river_object_"..name)
simulation:queue_insert_entity(e)
end
coroutine.yield()
end
end
local tt
tt=E:register_t_hot("decal_s03_bridge","decal_static",true)
AC(tt,"ui")
tt.ui.click_rect=r(-83,-48,166,96)
tt.ui.can_select=false
tt.render.sprites[1].name="stage3_bridge"
tt.render.sprites[1].z=Z_DECALS+2
tt.render.sprites[1].sort_y_offset=48
tt=E:register_t_hot("decal_crane","decal_scripted",true)
AC(tt,"ui")
tt.render.sprites[1].prefix="decal_crane"
tt.render.sprites[1].name="idle"
tt.render.sprites[2]=CC("sprite")
tt.render.sprites[2].name="decal_crane_fx"
tt.render.sprites[2].draw_order=-1
tt.ui.click_rect=r(-20,-40,40,40)
tt.ui.can_select=false
tt.main_script.update=decal_crane_update
tt.play_animation="play"
tt.click_animation="click"
tt.final_click_animation="final_click"
tt.play_time={10,45}
tt.final_clicks={3,6}
tt=E:register_t_hot("river_object_controller",nil,true)
AC(tt,"main_script")
tt.main_script.update=river_object_controller_update
tt.river_objects={"barrel","barrel","chest","wilson","submarine"}
tt.min_time=12
tt.max_time=24
tt.max_chests=3
tt.max_hobbits=13
end
return level
