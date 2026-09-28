local level={}
function level:init(store)
local E=require("entity_db")
local U=require("utils")
local A=require("achievements")
require("all.constants")
require("lib.klua.table")
local function fts(t)
return t/FPS
end
local function AC(tpl,...)
return E:add_comps(tpl,...)
end
local function decal_s24_nevermore_update(this,store)
while not this.ui.clicked do
coroutine.yield()
end
this.ui.clicked=nil
U.animation_start_default(this,"clicked",nil,store.tick_ts,false)
U.y_animation_wait_default(this)
U.animation_start_default(this,"fly",nil,store.tick_ts,true)
this.tween.reverse=false
this.tween.ts=store.tick_ts
U.y_wait_unconditional(store,this.leave_time)
A:got("NEVERMORE")
simulation:queue_remove_entity(this)
end
local tt
tt=E:register_t_hot("decal_s24_nevermore","decal_click_play",true)
AC(tt,"tween")
tt.render.sprites[1].scale=vec_2(0.7,0.7)
tt.render.sprites[1].prefix="decal_s24_nevermore"
tt.leave_time=2
tt.main_script.update=decal_s24_nevermore_update
tt.sound="ExtraBlackburnCrow"
tt.tween.remove=false
tt.tween.reverse=true
tt.tween.ts=-10
tt.tween.props[1].name="offset"
tt.tween.props[1].keys={{fts(0),vec_2(0,0)},{fts(60),vec_2(334,44)}}
tt.ui.can_select=false
tt.ui.click_rect.pos.y=-26
end
return level
