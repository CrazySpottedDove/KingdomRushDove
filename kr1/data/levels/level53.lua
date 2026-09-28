local log=require("lib.klua.log"):new("level05")
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
local km=require("lib.klua.macros")
require("all.constants")
require("lib.klua.table")
local function fts(t)
return t/FPS
end
local function AC(tpl,...)
return E:add_comps(tpl,...)
end
local function decal_bush_statue_insert(this,store)
local d=store.ephemeral
if not d.bush_indexes then
local indexes={}
for i=1,#this.bush_frames do
table.insert(indexes,i)
end
local match_idx=math.random(1,#indexes)
table.remove(indexes,match_idx)
d.bush_match_idx=match_idx
d.bush_indexes=indexes
d.bush_start_idx=math.random(1,3)
end
this.bush_indexes={d.bush_match_idx,table.remove(d.bush_indexes,math.random(1,#d.bush_indexes)),table.remove(d.bush_indexes,math.random(1,#d.bush_indexes))}
this.bush_match_idx=1
this.bush_idx=d.bush_start_idx
d.bush_start_idx=km.zmod(d.bush_start_idx+1,#this.bush_indexes)
this.render.sprites[1].name=this.bush_frame_prefix..this.bush_frames[this.bush_indexes[this.bush_idx]]
return true
end
local function decal_bush_statue_update(this,store)
while true do
if this.ui.clicked then
local fx=E:create_entity("fx_bush_statue_click")
fx.pos=this.pos
fx.render.sprites[1].ts=store.tick_ts
simulation:queue_insert_entity(fx)
U.y_wait_unconditional(store,fts(5))
this.bush_idx=km.zmod(this.bush_idx+1,#this.bush_indexes)
local frame=this.bush_frame_prefix..this.bush_frames[this.bush_indexes[this.bush_idx]]
this.render.sprites[1].name=frame
if this.bush_idx==this.bush_match_idx then
local all_bushes=table.filter(store.entities,function(k,v)
return v.template_name==this.template_name
end)
for _,e in pairs(all_bushes) do
if e.bush_idx~=e.bush_match_idx then
goto label_521_0
end
end
end
::label_521_0::
this.ui.clicked=nil
end
coroutine.yield()
end
end
local tt
tt=E:register_t_hot("decal_s05_tree_round","decal",true)
tt.render.sprites[1].name="stage5_tree"
tt.render.sprites[1].animated=false
tt.render.sprites[1].anchor.y=0.13953488372093023
tt=E:register_t_hot("decal_s05_tree_pine","decal",true)
tt.render.sprites[1].name="stage5_pine"
tt.render.sprites[1].animated=false
tt.render.sprites[1].anchor.y=0.08333333333333333
tt=E:register_t_hot("decal_bush_statue","decal_scripted",true)
AC(tt,"ui")
tt.main_script.insert=decal_bush_statue_insert
tt.main_script.update=decal_bush_statue_update
tt.render.sprites[1].animated=false
tt.render.sprites[1].name="stage5_bushes_0001"
tt.render.sprites[1].anchor.y=0.1744186046511628
tt.bush_frame_prefix="stage5_bushes_"
tt.bush_frames={"0001","0002","0003","0004","0005","0006","0007"}
tt.ui.click_rect=r(-40,0,80,66)
tt.ui.can_select=false
tt=E:register_t_hot("fx_bush_statue_click","fx",true)
AC(tt,"sound_events")
tt.render.sprites[1].name="fx_bush_statue_click"
tt.render.sprites[1].offset.y=34
tt.sound_events.insert="ElvesAchievementScissorFingers"
end
function level:load(store)
self.catapult_stop_ni={[6]=41,[5]=40}
if store.level_mode==GAME_MODE_CAMPAIGN then
self.catapult_waves={{wave=2,leave=20,enter=1,path_id=5},{wave=5,leave=30,enter=7,path_id=6},{wave=8,leave=25,enter=1,path_id=5},{wave=8,leave=35,enter=15,path_id=6},{wave=11,leave=30,enter=15,path_id=5},{wave=11,leave=30,enter=15,path_id=6},{wave=14,leave=30,enter=10,path_id=5},{wave=14,leave=30,enter=10,path_id=6},{wave=15,leave=45,enter=15,path_id=5},{wave=15,leave=45,enter=15,path_id=6}}
elseif store.level_mode==GAME_MODE_HEROIC then
self.catapult_waves={{wave=1,leave=30,enter=10,path_id=5},{wave=2,leave=30,enter=10,path_id=6},{wave=5,leave=30,enter=10,path_id=5}}
end
end
function level:update(store)
coroutine.yield()
LU.insert_hero(store,"hero_alleria",V.v(40,190))
while store.wave_group_number<1 do
coroutine.yield()
end
if self.catapult_waves then
local cwi,cw=0,nil
local wts=store.tick_ts
::label_3_0::
while not store.waves_finished do
cwi,cw=next(self.catapult_waves,cwi)
if not cw then
break
end
while store.wave_group_number<cw.wave do
coroutine.yield()
wts=store.tick_ts
end
while store.tick_ts-wts<cw.enter do
if store.wave_group_number~=cw.wave then
goto label_3_0
end
coroutine.yield()
end
local e=E:create_entity("enemy_catapult")
e.nav_path.pi=cw.path_id
e.nav_path.spi=2
e.duration=cw.leave-cw.enter
e.stop_ni=self.catapult_stop_ni[cw.path_id]
LU.queue_insert(store,e)
end
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
log.debug("-- WON")
end
return level
