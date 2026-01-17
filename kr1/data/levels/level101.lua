local log=require("klua.log"):new("level01")
local signal=require("hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("klua.vector")
local P=require("path_db")
local G=love.graphics
local SU=require("script_utils")
local storage=require("storage")
local W=require("wave_db")
require("constants")
local tower_menus=require("data.tower_menus_data")
local function fts(v)
return v/FPS
end
local function set_can_click_on_all_holders(store,can_click)
local holders=table.filter(store.entities,function(_,v)
return v.tower and v.tower.holder_id
end)
for _,h in ipairs(holders) do
h.ui.can_click=can_click
h.tower.can_hover=can_click
end
end
local function get_holder_by_id(store,id)
return table.filter(store.entities,function(_,v)
return v.tower and v.tower.holder_id==id
end)[1]
end
local function show_focus_circle(store,pos)
local screen_focus_circle=E:create_entity("screen_focus_circle")
screen_focus_circle.circle_pos=pos
screen_focus_circle.circle_radius=200
LU.queue_insert(store,screen_focus_circle)
return screen_focus_circle
end
local function remove_focus_circle(store,circle)
circle.tween.remove=true
circle.tween.ts=store.tick_ts
circle.tween.reverse=true
end
local function freeze_enemies(store)
local enemies=table.filter(store.entities,function(k,e)
return e.enemy and not e.health.dead
end)
for _,e in ipairs(enemies) do
e._lastfps=e.render.sprites[1].fps
e._lastmaxspeed=e.motion.max_speed
e.render.sprites[1].fps=0
e.motion.max_speed=0
e.un_freez_flags=e.vis.flags
e.vis.flags=F_CUSTOM
if e.ui then
e.ui.can_click=false
e.ui.can_select=false
end
end
return enemies
end
local function unfreeze_enemies(enemies)
for _,e in ipairs(enemies) do
e.render.sprites[1].fps=e._lastfps
e.motion.max_speed=e._lastmaxspeed
if e.un_freez_flags then
e.vis.flags=e.un_freez_flags
end
if e.ui then
e.ui.can_click=true
e.ui.can_select=true
end
end
end
local function restore_all_holders_and_builds(store)
signal.emit("tutorial-tower-enable-all")
set_can_click_on_all_holders(store,true)
end
local level={}
local holder_to_enable_archer={}
local holder_to_enable_barrack={}
level.tower_menu_hiding=true
level.hide_notifications=false
local zoom_in_depth=KR_TARGET=="phone" and 1.75 or 1.25
local signal_handlers
local function unregister_signals()
for _,row in pairs(signal_handlers) do
local id,name,fn=unpack(row)
log.debug("unregistering signal: %s:%s",id,name)
signal.remove(name,fn)
end
signal_handlers={}
end
function level:init(store)
self.manual_hero_insertion=false
local user_data=storage:load_slot()
local already_passed_tutorial=user_data.levels[1] and user_data.levels[1][1]~=nil
local unlocked_raelyn=user_data.levels[2] and user_data.levels[2][1]~=nil
end
function level:preprocess(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
level.show_comic_idx=33
end
end
function level:load(store)
signal_handlers={{"_game_restart","game-restart",function()
unregister_signals()
end},{"_game_quit","game-quit",function()
unregister_signals()
end}}
for _,row in pairs(signal_handlers) do
local id,sn,sf=unpack(row)
signal.register(sn,sf)
end
end
function level:update(store)
local function sig_reg(id,name,fn)
signal.register(name,fn)
table.insert(signal_handlers,{id,name,fn})
end
local function sig_del(id)
for i,row in ipairs(signal_handlers) do
local sid,name,fn=unpack(row)
if id==sid then
log.debug("unregistering signal: %s:%s",id,name)
signal.remove(name,fn)
table.remove(signal_handlers,i)
return
end
end
end
local function y_wait_enemy_dead()
local enemies
while true do
enemies=table.filter(store.entities,function(k,e)
return e.enemy
end)
if enemies then
local enemy_dead_found
for i,v in pairs(enemies) do
if v.health.dead then
enemy_dead_found=true
break
end
end
if enemy_dead_found then
break
end
end
coroutine.yield()
end
return enemies
end
local user_data=storage:load_slot()
local bushes=table.filter(store.entities,function(k,e)
return e.template_name=="stage_01_bush"
end)
for _,bush in ipairs(bushes) do
simulation:queue_remove_entity(bush)
end
while store.wave_group_number<1 do
coroutine.yield()
end
signal.emit("unlock-user-power",1)
signal.emit("unlock-user-power",2)
signal.emit("unlock-user-power",3)
U.y_wait(store,3)
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
log.debug("-- WON")
signal.emit("ftue-step","tutorial_ends")
unregister_signals()
end
return level
