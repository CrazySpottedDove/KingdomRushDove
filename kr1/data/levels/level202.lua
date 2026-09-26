local LU=require("level_utils")
local P=require("path_db")
local E=require("entity_db")
local U=require("utils")
require("all.constants")
require("lib.klua.table")
local level={}
function level:init(store)
local S=require("sound_db")
local scripts=require("scripts")
local V=require("lib.klua.vector")
local r=V.r
local v=V.v
local vv=V.vv
local signal=require("lib.hump.signal")
local function AC(tpl,...)
return E:add_comps(tpl,...)
end
local function fts(t)
return t/30
end
local function find_all_t(store,template_name,contains,fn)
if not store or not store.entities then
return {}
end
return table.filter(store.entities,function(k,v)
return (contains and string.find(v.template_name,template_name) or v.template_name==template_name) and (not fn or fn(k,v))
end)
end
local function masterclass_update(this,store,script)
local teleporters=find_all_t(store,"controller_stage_202_teleport",true)
local function none_teleported()
for k,tp in pairs(teleporters) do
if tp.teleported then
return false
end
end
return true
end
local claimed=false
while not claimed do
if store.waves_finished and not LU.has_alive_enemies(store) and none_teleported() and store.level_mode==GAME_MODE_CAMPAIGN then
signal.emit("masterclass-stage02",this)
claimed=true
end
coroutine.yield()
end
simulation:queue_remove_entity(this)
end
local function scrolls_update(this,store,script)
while this.scrolls_obtained<this.amount_for_achievement do
coroutine.yield()
end
simulation:queue_remove_entity(this)
end
local function wisp_update(this,store,script)
while true do
this.render.sprites[1].hidden=false
U.y_animation_play(this,"run",nil,store.tick_ts,math.random(1,3))
this.render.sprites[1].hidden=true
U.y_wait(store,fts(math.random(0,5*FPS)))
coroutine.yield()
end
end
local function teleport_update(this,store,script)
this.teleported=false
local defend_point_pos
local defend_points={}
while #defend_points<2 do
defend_points={}
for k,v in pairs(store.entities) do
if v.template_name=="decal_defend_point" then
table.insert(defend_points,v)
end
end
if #defend_points<2 then
coroutine.yield()
end
end
if defend_points[1].pos.x<defend_points[2].pos.x then
if this.template_name=="controller_stage_202_teleport_left" then
defend_point_pos=defend_points[1].pos
else
defend_point_pos=defend_points[2].pos
end
elseif this.template_name=="controller_stage_202_teleport_left" then
defend_point_pos=defend_points[2].pos
else
defend_point_pos=defend_points[1].pos
end
local books=E:create_entity(this.book_t)
books.render.sprites[1].ts=store.tick_ts
books.pos=v(512,384)
simulation:queue_insert_entity(books)
U.y_animation_play(books,"active",nil,store.tick_ts,1)
U.animation_start(books,"idle_active",nil,store.tick_ts,true)
local function find_enemy()
return U.find_foremost_enemy(store.entities,defend_point_pos,0,50,false,F_TELEPORT,0,function(e,o)
return not U.has_modifiers(store,e,this.mod_mark)
end)
end
local function find_enemies(target_pos)
return U.find_enemies_in_range(store.entities,target_pos,0,this.radius*2,F_TELEPORT,0,function(e,o)
return not U.has_modifiers(store,e,this.mod_mark)
end)
end
while true do
local target,_=find_enemy()
if not target then
U.y_wait(store,fts(10))
else
U.animation_start(books,"run",nil,store.tick_ts,false)
U.y_wait(store,fts(5))
local decal=E:create_entity(this.decal_teleport)
decal.render.sprites[1].ts=store.tick_ts
decal.pos=V.vclone(defend_point_pos)
simulation:queue_insert_entity(decal)
U.y_wait(store,fts(5))
local targets=find_enemies(defend_point_pos)
local count=0
if targets then
for k,t in ipairs(targets) do
local mod_mark=E:create_entity(this.mod_mark)
mod_mark.modifier.target_id=t.id
mod_mark.modifier.source_id=this.id
simulation:queue_insert_entity(mod_mark)
count=count+1
if count>=this.max_targets then
break
end
end
end
count=0
if targets then
for k,t in ipairs(targets) do
if t and not t.health.dead then
S:queue(this.sound_teleport)
local mod_teleport=E:create_entity(this.mod_teleport)
mod_teleport.modifier.target_id=t.id
mod_teleport.modifier.source_id=this.id
simulation:queue_insert_entity(mod_teleport)
U.y_wait(store,fts(2))
count=count+1
if count>=this.max_targets then
break
end
this.teleported=true
end
end
end
U.y_animation_wait(books)
U.animation_start(books,"off",nil,store.tick_ts,false)
U.y_wait(store,this.cooldown)
S:queue(this.sound_recharge)
U.y_animation_play(books,"active",nil,store.tick_ts,1)
U.animation_start(books,"idle_active",nil,store.tick_ts,true)
end
end
end
local function book_update(this,store,script)
while true do
if this.ui.clicked and this.render.sprites[1].name=="loop" then
S:queue(this.sound)
this.ui.clicked=nil
U.animation_start(this,"tap",nil,store.tick_ts,false)
end
if this.render.sprites[1].name=="tap" and U.animation_finished(this) then
U.animation_start(this,"loop",nil,store.tick_ts,true,1,true)
end
coroutine.yield()
end
end
local function merlin_update(this,store,script)
local tapped=false
while true do
if this.ui.clicked then
this.ui.clicked=nil
this.ui.can_click=false
if tapped then
S:queue(this.sound_p1)
S:queue(this.sound_p2,{delay=fts(121)})
U.y_animation_play(this,"start",nil,store.tick_ts,1)
U.animation_start(this,"end",nil,store.tick_ts,true)
else
S:queue(this.sound_p1)
U.y_animation_play(this,"tap",nil,store.tick_ts,1)
U.animation_start(this,"loop",nil,store.tick_ts,true,1,true)
this.ui.can_click=true
tapped=true
end
end
coroutine.yield()
end
end
local function chess_insert(this,store,script)
local c=find_all_t(store,this.controller_t)[1]
if not c and this.controller_t then
simulation:queue_insert_entity(E:create_entity(this.controller_t))
end
return true
end
local function chess_update(this,store,script)
local other_pieces={}
local black_piece
for k,v in pairs(store.entities) do
if v~=this then
if string.find(v.template_name,this.template_name) then
black_piece=v
elseif string.find(v.template_name,"decal_stage_202_chess") then
table.insert(other_pieces,v)
end
end
end
while true do
if this.wrong_piece then
this.wrong_piece=false
if this.activated then
this.activated=false
S:queue(this.sound_miss)
U.y_animation_play(this,"miss",nil,store.tick_ts,1)
U.animation_start(this,"idle",nil,store.tick_ts,true)
end
end
if this.ui.clicked then
this.ui.clicked=nil
local other_active
for k,v in pairs(other_pieces) do
v.wrong_piece=true
if v.activated then
other_active=true
end
end
if not other_active then
if this.activated then
this.activated=false
S:queue(this.sound_miss)
U.y_animation_play(this,"miss",nil,store.tick_ts,1)
U.animation_start(this,"idle",nil,store.tick_ts,true)
else
S:queue(this.sound_select)
this.activated=true
U.y_animation_play(this,"activate",nil,store.tick_ts,1)
U.animation_start(this,"activeidle",nil,store.tick_ts,true)
end
end
end
if black_piece.ui.clicked then
black_piece.ui.clicked=nil
for k,v in pairs(other_pieces) do
v.wrong_piece=true
end
if this.activated then
this.activated=false
S:queue(this.sound_valid)
U.animation_start(this,"attacking",nil,store.tick_ts,false)
U.y_wait(store,fts(34))
if string.find(this.template_name,"knight") then
this.render.sprites[1].z=Z_OBJECTS
end
if string.find(this.template_name,"bishop") then
this.render.sprites[1].z=Z_OBJECTS+2
end
U.y_wait(store,fts(7))
if string.find(this.template_name,"rook") then
this.render.sprites[1].z=Z_OBJECTS-1
end
if string.find(this.template_name,"knight") then
U.y_wait(store,fts(40))
end
S:queue(this.sound_explosion)
U.y_animation_wait(this)
U.animation_start(this,"idledone",nil,store.tick_ts,true)
break
end
end
coroutine.yield()
end
this.done=true
while true do
coroutine.yield()
end
simulation:queue_remove_entity(this)
end
local function mage_2_update(this,store,script)
local action_ts=store.tick_ts
local action_cd=math.random(3,7)
while store.wave_group_number<1 do
if action_cd<store.tick_ts-action_ts then
action_ts=store.tick_ts
action_cd=math.random(3,7)
U.y_animation_play(this,"animeveryxseconds",nil,store.tick_ts,1)
U.animation_start(this,"idle",nil,store.tick_ts,true)
end
coroutine.yield()
end
local random_wait=math.random(0,2)
U.y_wait(store,random_wait)
U.y_animation_play(this,"tpout",nil,store.tick_ts,1)
simulation:queue_remove_entity(this)
end
local function mage_3_update(this,store,script)
while store.wave_group_number<1 do
if math.random(1,2)==1 then
U.y_animation_play(this,"idle",nil,store.tick_ts,math.random(1,3))
else
U.y_animation_play(this,"idle2",nil,store.tick_ts,math.random(1,3))
end
coroutine.yield()
end
local random_wait=math.random(0,2)
U.y_wait(store,random_wait)
U.y_animation_play(this,"tpout",nil,store.tick_ts,1)
simulation:queue_remove_entity(this)
end
local function mage_4_update(this,store,script)
while store.wave_group_number<1 do
if math.random(1,2)==1 then
U.y_animation_play(this,"idle1",nil,store.tick_ts,math.random(1,3))
else
U.y_animation_play(this,"idle2",nil,store.tick_ts,math.random(1,3))
end
coroutine.yield()
end
local random_wait=math.random(0,2)
U.y_wait(store,random_wait)
U.y_animation_play(this,"tpout",nil,store.tick_ts,1)
simulation:queue_remove_entity(this)
end
local function magnus_update(this,store,script)
local taps_count=0
while true do
if this.ui.clicked then
this.ui.clicked=nil
this.ui.can_click=false
taps_count=taps_count+1
if taps_count==1 then
S:queue(this.sound_t1)
U.y_animation_play(this,"tap1",nil,store.tick_ts,1)
U.animation_start(this,"idle2",nil,store.tick_ts,true)
this.ui.can_click=true
else
S:queue(this.sound_t2)
S:queue(this.sound_t2_cheer,{delay=fts(205)})
U.y_animation_play(this,"tap2",nil,store.tick_ts,1)
U.animation_start(this,"idle_end",nil,store.tick_ts,true)
break
end
end
coroutine.yield()
end
while true do
coroutine.yield()
end
simulation:queue_remove_entity(this)
end
local function scroll_update(this,store,script)
scripts.decal_utils.animation_on_tap_update(this,store,script)
local c=find_all_t(store,this.scrolls_controller_t)[1]
c.scrolls_obtained=c.scrolls_obtained+1
simulation:queue_remove_entity(this)
end
local function chess_controller_update(this,store,script)
local d=false
local pieces={}
table.insert(pieces,find_all_t(store,this.bishop_t)[1])
table.insert(pieces,find_all_t(store,this.knight_t)[1])
table.insert(pieces,find_all_t(store,this.rook_t)[1])
::label_997_0::
while not d do
for i,v in ipairs(pieces) do
coroutine.yield()
if not pieces[i].done then
goto label_997_0
end
end
signal.emit("checkmate-stage02",this)
d=true
end
simulation:queue_remove_entity(this)
end
local tt=E:register_t_hot("controller_stage_202_masterclass_achievement_tracker",nil,true)
AC(tt,"main_script","pos")
tt.main_script.update=masterclass_update
tt=E:register_t_hot("controller_stage_202_scrolls",nil,true)
AC(tt,"pos","main_script")
tt.main_script.update=scrolls_update
tt.amount_for_achievement=4
tt.scrolls_obtained=0
tt=E:register_t_hot("controller_stage_202_teleport_left",nil,true)
AC(tt,"main_script")
tt.main_script.update=teleport_update
tt.mod_teleport="mod_stage_202_teleport"
tt.mod_mark="mod_stage_202_teleport_mark"
tt.book_t="decal_stage_202_teleport_book_left"
tt.decal_teleport="decal_stage_202_teleport"
tt.sound_teleport="Stage02StatueTeleport"
tt.sound_recharge="Stage02StatueTeleportRecharge"
tt.cooldown=35
tt.nodes_teleport=50
tt.radius=40
tt.max_targets=4
tt=E:register_t_hot("controller_stage_202_teleport_right","controller_stage_202_teleport_left",true)
tt.book_t="decal_stage_202_teleport_book_right"
tt=E:register_t_hot("controller_stage_202_chess",nil,true)
AC(tt,"main_script")
tt.main_script.update=chess_controller_update
tt.bishop_t="decal_stage_202_chess_bishop"
tt.knight_t="decal_stage_202_chess_knight"
tt.rook_t="decal_stage_202_chess_rook"
tt=E:register_t_hot("decal_stage_202_book","decal_scripted",true)
AC(tt,"ui")
tt.render.sprites[1].prefix="stage202_bukDef"
tt.render.sprites[1].name="loop"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS
tt.main_script.update=book_update
tt.sound="Stage02BookFountainTap"
tt.ui.click_rect=r(-42.5,-35,85,60)
tt=E:register_t_hot("decal_stage_202_chess_bishop_black",nil,true)
tt.controller_t="controller_stage_202_chess"
AC(tt,"pos","ui")
tt.ui.click_rect=r(-241,-294,25,35)
tt=E:register_t_hot("decal_stage_202_chess_knight_black",nil,true)
tt.controller_t="controller_stage_202_chess"
AC(tt,"pos","ui")
tt.ui.click_rect=r(-165,-255,25,35)
tt=E:register_t_hot("decal_stage_202_chess_rook_black",nil,true)
tt.controller_t="controller_stage_202_chess"
AC(tt,"pos","ui")
tt.ui.click_rect=r(-203,-276,25,49)
tt=E:register_t_hot("decal_stage_202_chess_bishop","decal_scripted",true)
AC(tt,"ui")
tt.render.sprites[1].prefix="chess_bishopDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS
tt.main_script.insert=chess_insert
tt.main_script.update=chess_update
tt.controller_t="controller_stage_202_chess"
tt.sound_miss="Stage02BattleChessPieceInvalidMove"
tt.sound_valid="Stage02BattleChessPieceValidMove"
tt.sound_select="Stage02BattleChessPieceSelect"
tt.sound_explosion="Stage02BattleChessPieceExplosion"
tt.ui.click_rect=r(-238,-214,25,49)
tt=E:register_t_hot("decal_stage_202_chess_knight","decal_stage_202_chess_bishop",true)
tt.render.sprites[1].prefix="chess_knightDef"
tt.render.sprites[1].z=Z_OBJECTS+1
tt.ui.click_rect=r(-280,-275,30,40)
tt=E:register_t_hot("decal_stage_202_chess_rook","decal_stage_202_chess_bishop",true)
tt.render.sprites[1].prefix="chess_rookDef"
tt.ui.click_rect=r(-278,-232,25,35)
tt=E:register_t_hot("decal_stage_202_lamp","decal_scripted",true)
AC(tt,"ui")
tt.render.sprites[1].prefix="magelampDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS
tt.tap_anim="brokenstart"
tt.tap_anim_play_times=1
tt.loop_anim="broken"
tt.tap_disables=true
tt.tap_ends=true
tt.tap_sound="Stage05LampBreak"
tt.main_script.update=scripts.decal_utils.animation_on_tap_update
tt.ui.can_click=true
tt.ui.click_rect=r(-13,20,25,30)
tt=E:register_t_hot("decal_stage_202_mage_1","decal",true)
tt.render.sprites[1].prefix="mage1_animationsDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS
tt=E:register_t_hot("decal_stage_202_mage_1_2","decal",true)
tt.render.sprites[1].prefix="mage1_2_animationsDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS
tt=E:register_t_hot("decal_stage_202_mage_2","decal_scripted",true)
tt.render.sprites[1].prefix="mage2_animationsDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS
tt.main_script.update=mage_2_update
tt=E:register_t_hot("decal_stage_202_mage_3","decal_scripted",true)
tt.render.sprites[1].prefix="mage3_animationsDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS
tt.main_script.update=mage_3_update
tt=E:register_t_hot("decal_stage_202_mage_3_2","decal_scripted",true)
tt.render.sprites[1].prefix="mage3_2_animationsDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS
tt.main_script.update=mage_3_update
tt=E:register_t_hot("decal_stage_202_mage_4","decal_scripted",true)
tt.render.sprites[1].prefix="mage4_animationsDef"
tt.render.sprites[1].name="idle1"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS
tt.main_script.update=mage_4_update
tt=E:register_t_hot("decal_stage_202_mage_4_2","decal_scripted",true)
tt.render.sprites[1].prefix="mage4_2_animationsDef"
tt.render.sprites[1].name="idle1"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].flip_x=true
tt.main_script.update=mage_4_update
tt=E:register_t_hot("decal_stage_202_mage_4_3","decal_scripted",true)
tt.render.sprites[1].prefix="mage4_animationsDef"
tt.render.sprites[1].name="idle1"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].flip_x=true
tt.main_script.update=mage_4_update
tt=E:register_t_hot("decal_stage_202_magnus","decal_scripted",true)
AC(tt,"ui")
tt.render.sprites[1].prefix="magnus_animationsDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.main_script.update=magnus_update
tt.sound_t1="Stage02WizardStudentsTap1"
tt.sound_t2="Stage02WizardStudentsTap2"
tt.sound_t2_cheer="Stage02WizardStudentsTap2Cheer"
tt.ui.click_rect=r(105,-55,30,35)
tt=E:register_t_hot("decal_stage_202_mask_1","decal",true)
tt.render.sprites[1].name="KR6_stage_202_mask1"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt=E:register_t_hot("decal_stage_202_mask_2","decal",true)
tt.render.sprites[1].name="KR6_stage_202_mask2"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS
tt=E:register_t_hot("decal_stage_202_mask_3","decal",true)
tt.render.sprites[1].name="KR6_stage_202_mask3"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].sort_y_offset=122
tt=E:register_t_hot("decal_stage_202_merlin","decal_scripted",true)
AC(tt,"ui")
tt.render.sprites[1].prefix="stage202_merlinDef"
tt.render.sprites[1].name="loop"
tt.render.sprites[1].exo=true
tt.main_script.insert=scripts.decal_utils.censor_cn_insert
tt.main_script.update=merlin_update
tt.sound_p1="Stage02MerlinPart1"
tt.sound_p2="Stage02MerlinPart2"
tt.ui.click_rect=r(-50,-60,110,120)
tt=E:register_t_hot("decal_stage_202_scroll_1","decal_scripted",true)
AC(tt,"ui")
tt.render.sprites[1].prefix="scroll_1Def"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.tap_anim="tap"
tt.tap_anim_play_times=1
tt.tap_sound="Stage02ScrollsDisintegrate"
tt.no_loop_anim=true
tt.tap_disables=true
tt.tap_ends=true
tt.scrolls_controller_t="controller_stage_202_scrolls"
tt.main_script.update=scroll_update
tt.ui.click_rect=r(-476,-76,25,18)
tt=E:register_t_hot("decal_stage_202_scroll_2","decal_scripted",true)
AC(tt,"ui")
tt.render.sprites[1].prefix="scroll_2Def"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.tap_anim="tap"
tt.tap_anim_play_times=1
tt.tap_sound="Stage02ScrollsDisintegrate"
tt.no_loop_anim=true
tt.tap_disables=true
tt.tap_ends=true
tt.scrolls_controller_t="controller_stage_202_scrolls"
tt.main_script.update=scroll_update
tt.ui.click_rect=r(249,141,25,18)
tt=E:register_t_hot("decal_stage_202_scroll_3","decal_scripted",true)
AC(tt,"ui")
tt.render.sprites[1].prefix="scroll_3Def"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.tap_anim="tap"
tt.tap_anim_play_times=1
tt.tap_sound="Stage02ScrollsDisintegrate"
tt.no_loop_anim=true
tt.tap_disables=true
tt.tap_ends=true
tt.scrolls_controller_t="controller_stage_202_scrolls"
tt.main_script.update=scroll_update
tt.ui.click_rect=r(-596,-304,25,18)
tt=E:register_t_hot("decal_stage_202_scroll_4","decal_scripted",true)
AC(tt,"ui")
tt.render.sprites[1].prefix="scroll_4Def"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.tap_anim="tap"
tt.tap_anim_play_times=1
tt.tap_sound="Stage02ScrollsDisintegrate"
tt.no_loop_anim=true
tt.tap_disables=true
tt.tap_ends=true
tt.scrolls_controller_t="controller_stage_202_scrolls"
tt.main_script.update=scroll_update
tt.ui.click_rect=r(16,-270,25,18)
tt=E:register_t_hot("decal_stage_202_water_small","decal",true)
tt.render.sprites[1].prefix="magewaterDef"
tt.render.sprites[1].name="run"
tt.render.sprites[1].exo=true
tt.render.sprites[1].random_ts=fts(15)
tt.render.sprites[1].z=Z_BACKGROUND_COVERS
tt.render.sprites[1].scale=vv(0.75)
tt=E:register_t_hot("decal_stage_202_water","decal",true)
tt.render.sprites[1].prefix="magewaterDef"
tt.render.sprites[1].name="run"
tt.render.sprites[1].exo=true
tt.render.sprites[1].random_ts=fts(15)
tt.render.sprites[1].z=Z_BACKGROUND_COVERS
tt=E:register_t_hot("decal_stage_202_wisp","decal_scripted",true)
tt.render.sprites[1].prefix="magewispDef"
tt.render.sprites[1].name="run"
tt.render.sprites[1].exo=true
tt.render.sprites[1].random_ts=fts(30)
tt.main_script.update=wisp_update
tt=E:register_t_hot("decal_stage_202_teleport_book_left","decal",true)
tt.render.sprites[1].prefix="stage202_tpDef"
tt.render.sprites[1].name="idle_active"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS_COVERS+1
tt=E:register_t_hot("decal_stage_202_teleport_book_right","decal_stage_202_teleport_book_left",true)
tt.render.sprites[1].prefix="stage202_tp2Def"
tt=E:register_t_hot("decal_stage_202_teleport","decal_timed",true)
tt.render.sprites[1].prefix="stage202_teleport_decalDef"
tt.render.sprites[1].name="run"
tt.render.sprites[1].exo=true
tt=E:register_t_hot("mod_stage_202_teleport_mark","modifier",true)
AC(tt,"mark_flags")
tt.mark_flags.vis_bans=F_TELEPORT
tt.modifier.duration=fts(50)
tt.main_script.insert=scripts.mod_mark_flags.insert
tt.main_script.remove=scripts.mod_mark_flags.remove
tt.main_script.update=scripts.mod_mark_flags.update
tt.main_script.type=1
tt=E:register_t_hot("mod_stage_202_teleport","mod_teleport",true)
tt.modifier.vis_flags=bor(F_MOD)
tt.modifier.vis_bans=bor(F_BOSS)
tt.modifier.duration=1
tt.modifier.allows_duplicates=false
tt.nodes_offset=-50
tt.max_times_applied=5
tt.dest_valid_node=true
tt.dest_node_valid_flags=NF_NO_BACKWARDS
tt.delay_start=fts(3)
tt.hold_time=0.34
tt.delay_end=fts(3)
tt.fx_start="fx_stage_202_teleport"
tt.fx_end="fx_stage_202_teleport"
tt=E:register_t_hot("fx_stage_202_teleport","fx",true)
tt.render.sprites[1].prefix="stage202_tpfxDef"
tt.render.sprites[1].name="run"
tt.render.sprites[1].exo=true
tt.render.sprites[1].offset=v(0,-20)
self.manual_hero_insertion=false
end
function level:update(store)
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
return level
