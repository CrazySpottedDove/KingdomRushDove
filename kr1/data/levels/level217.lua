local LU=require("level_utils")
local P=require("path_db")
local E=require("entity_db")
local U=require("utils")
local V=require("lib.klua.vector")
local log=require("lib.klua.log"):new("level217")
local signal=require("lib.hump.signal")
local S=require("sound_db")
local SU=require("script_utils")
local scripts=require("scripts")
require("all.constants")
require("lib.klua.table")
local level={}
local function fts(t)
return t/30
end
local function find_all_t(store,template_name,contains,fn)
if not store or not store.entities then
return {}
end
return table.filter(store.entities,function(k,val)
return (contains and string.find(val.template_name,template_name) or val.template_name==template_name) and (not fn or fn(k,val))
end)
end
local function queue_insert(store,e)
simulation:queue_insert_entity(e)
end
local function queue_remove(store,e)
simulation:queue_remove_entity(e)
end
local function tower_stage_217_joust_update(this,store)
local lady=find_all_t(store,this.lady_t)[1]
this.ui.can_click=false
while store.wave_group_number==0 do
coroutine.yield()
end
S:queue(this.sound_horse_gallop)
U.y_animation_play(this,this.start_anim,nil,store.tick_ts,1)
this.ui.can_click=true
U.animation_start(this,this.idle_anim,nil,store.tick_ts,false)
local idle_ts=store.tick_ts
local lady_idle_ts=store.tick_ts
while true do
if this.user_selection.in_progress and not this.tower_action.active then
local choice=this.user_selection.arg
this.user_selection.in_progress=nil
this.user_selection.allowed=false
this.tower_action.active=true
store.player_gold=store.player_gold-this.tower_action.cost
local result=math.random(0,1)==0 and "red" or "blue"
U.animation_start(this,result.."Win",nil,store.tick_ts,false,1)
local delay_joust_start,delay_clash,delay_knocked_out,delay_win,delay_lose
if result=="red" then
delay_joust_start=fts(79)
delay_clash=fts(129)
delay_knocked_out=fts(147)
delay_win=fts(169)
delay_lose=fts(180)
else
delay_joust_start=fts(87)
delay_clash=fts(137)
delay_knocked_out=fts(155)
delay_win=fts(180)
delay_lose=fts(180)
end
S:queue(this.sound_battle_cry)
S:queue(this.sound_joust_start,{delay=delay_joust_start})
S:queue(this.sound_clash,{delay=delay_clash})
S:queue(this.sound_knocked_out,{delay=delay_knocked_out})
if result==choice then
S:queue(this.sound_player_win,{delay=delay_win})
S:queue(this.sound_lady_win,{delay=delay_win})
else
S:queue(this.sound_player_lose,{delay=delay_lose})
S:queue(this.sound_lady_lose,{delay=delay_lose})
end
U.y_wait(store,fts(179))
U.animation_start(lady,result==choice and "celebration" or "sad",nil,store.tick_ts,false,1)
if result==choice then
local pos=V.v(this.pos.x+this.show_gold_offset.x,this.pos.y+this.show_gold_offset.y)
local reward=E:create_entity(this.gold_reward_t)
reward.pos.x,reward.pos.y=pos.x,pos.y
reward.render.sprites[1].ts=store.tick_ts
reward.reward=this.bet.payout_mult*this.tower_action.cost
queue_insert(store,reward)
signal.emit("feeling-lucky-stage17")
end
U.y_animation_wait(this,1)
U.y_wait(store,this.bet.cooldown)
this.tower_action.active=false
this.user_selection.allowed=true
this.user_selection.in_progress=nil
S:queue(this.sound_horse_gallop)
U.y_animation_play(this,this.start_anim,nil,store.tick_ts,1)
end
if store.tick_ts-idle_ts>=5 then
U.animation_start(this,this.idle_anim,nil,store.tick_ts,false)
idle_ts=store.tick_ts
end
if store.tick_ts-lady_idle_ts>=14 then
U.animation_start(lady,this.idle_lady_anim,nil,store.tick_ts,false)
lady_idle_ts=store.tick_ts
end
coroutine.yield()
end
end
local function decal_stage_217_joust_gold_reward_insert(this,store)
local pos=V.v(this.pos.x+this.offset_number.x,this.pos.y+this.offset_number.y)
signal.emit("got-gold-generic",pos,this.reward)
return true
end
local function soldier_stage_217_paladin_update(this,store)
this.render.sprites[1].ts=store.tick_ts
this.hp=this.hp_max
this.nav_rally.pos=V.vclone(this.pos)
this.nav_rally.center:copy(this.nav_rally.pos)
if this.sound_events and this.sound_events.raise then
S:queue(this.sound_events.raise)
end
local brk,stam,distance
local path_ni=1
local path_spi=1
local path_pi=1
local node_pos
local nearest=P:nearest_nodes(this.pos.x,this.pos.y,{this.pi})
if #nearest>0 then
path_pi,path_spi,path_ni=unpack(nearest[1])
end
path_spi=1
path_ni=path_ni-3
while true do
if this.health.dead then
SU.y_soldier_death(store,this)
return
end
if path_ni<=0 then
this.health_bar.hidden=true
U.unblock_target(store,this)
queue_remove(store,this)
return
end
if this.unit.is_stunned then
SU.soldier_idle(store,this)
else
this.nav_rally.center:copy(this.pos)
brk,stam=SU.y_soldier_melee_block_and_attacks(store,this)
if brk or stam==A_DONE or stam==A_IN_COOLDOWN and not this.melee.continue_in_cooldown then
else
node_pos=this.nav_rally.pos
distance=V.dist2(node_pos.x,node_pos.y,this.pos.x,this.pos.y)
if distance<4 then
path_ni=path_ni-1
this.nav_rally.pos=P:node_pos(path_pi,path_spi,path_ni)
end
if SU.soldier_go_back_step(store,this) then
else
SU.soldier_regen(store,this)
end
end
end
coroutine.yield()
end
end
local function controller_stage_217_castle_paladins_update(this,store)
local function is_on_path_at_ni(pd,e)
for _,pde in pairs(pd) do
if pde[1]~=e.nav_path.pi then
elseif not pde[2] or e.nav_path.ni<=pde[2] then
return true
end
end
return false
end
local function determine_paths()
local ps={}
for i,path_id in ipairs(this.paths_to_spawn) do
local path_data=this.paths_map[path_id]
for k,e in pairs(store.entities) do
if store.entities[e.id]~=nil and e.enemy and e.vis and e.health and not e.health.dead and band(e.vis.flags,bor(F_FLYING))==0 and band(e.vis.bans,bor(F_BLOCK))==0 and is_on_path_at_ni(path_data,e) then
table.insert(ps,path_id)
break
end
end
end
return ps
end
while true do
if this.spawn_paladin then
this.spawn_paladin=false
local paths=determine_paths()
local pi
if #paths==0 then
pi=this.paths_to_spawn[math.random(1,#this.paths_to_spawn)]
else
pi=paths[math.random(1,#paths)]
end
local s=E:create_entity(this.paladin_t)
s.pi=pi
s.pos=P:node_pos(pi,1,P:get_end_node(pi))
queue_insert(store,s)
end
coroutine.yield()
end
end
local function controller_stage_217_slayers_update(this,store)
local run_ts=store.tick_ts-this.update_interval
while true do
if store.tick_ts-run_ts>this.update_interval then
local enemies=table.filter(store.entities,function(k,t)
return t.enemy and t.nav_path and not t.pending_removal and t.health and not t.health.dead and t.template_name==this.slayer_t and t.nav_path.pi==this.path_knights
end)
if enemies then
for k,t in pairs(enemies) do
t.nav_path.pi=this.path_slayers
local nearest_nodes=P:nearest_nodes(t.pos.x,t.pos.y,{t.nav_path.pi},{t.nav_path.spi},true)
if nearest_nodes and nearest_nodes[1] then
local _,spi,ni=unpack(nearest_nodes[1])
t.nav_path.spi=spi
t.nav_path.ni=ni
local next=P:next_entity_node(t,store.tick_length)
U.set_destination(t,next)
end
end
end
run_ts=store.tick_ts
end
coroutine.yield()
end
end
local function decal_stage_217_duel_update(this,store)
while true do
if this.duel_started then
local taps=0
S:queue(this.sound_entrance)
U.y_animation_play(this,this.animation_entrance,nil,store.tick_ts,1)
U.animation_start(this,this.animation_fight,nil,store.tick_ts,true)
local iterations=math.ceil(this.duel_duration/this.animation_fight_duration)
for i=1,iterations do
S:queue(this.sound_combat,{delay=i*this.animation_fight_duration-this.sound_combat_delay})
end
U.y_wait(store,this.duel_duration)
U.y_animation_play(this,this.animation_start_clash,nil,store.tick_ts,1)
U.animation_start(this,this.animation_clash,nil,store.tick_ts,true)
local tap_decal=E:create_entity(this.tap_decal_t)
tap_decal.pos.x,tap_decal.pos.y=this.tap_decal_pos.x,this.tap_decal_pos.y
tap_decal.render.sprites[1].ts=store.tick_ts
queue_insert(store,tap_decal)
local start_ts=store.tick_ts
local window=this.conclusion_window
while window>store.tick_ts-start_ts do
if this.ui.clicked then
this.ui.clicked=nil
taps=taps+1
window=window+this.tap_time_aid
end
if taps>=this.required_taps then
break
end
coroutine.yield()
end
queue_remove(store,tap_decal)
local result=taps>=this.required_taps and "paladin" or "slayer"
local controller=store.entities[this.controller_id]
if result=="paladin" then
U.animation_start(this,this.animation_end_paladin,nil,store.tick_ts,false)
S:queue(this.sound_player_win)
U.y_wait(store,fts(63))
if controller then
controller.duel_result=result
end
U.y_animation_wait(this,1)
else
U.animation_start(this,this.animation_end_slayer,nil,store.tick_ts,false)
S:queue(this.sound_player_lose)
U.y_wait(store,fts(40))
if controller then
controller.duel_result=result
end
U.y_animation_wait(this,1)
end
this.duel_started=false
U.animation_start(this,"Idle",nil,store.tick_ts,true)
end
coroutine.yield()
end
end
local function controller_stage_217_duel_on_event(this,store,action)
this.duel_call=true
end
local function controller_stage_217_duel_update(this,store)
local sp=find_all_t(store,this.paladin_spawner_t)[1]
local duel_decal=find_all_t(store,this.decal_t)[1]
duel_decal.controller_id=this.id
local function buff_allies()
local a=E:create_entity(this.soldier_aura_t)
a.pos.x,a.pos.y=0,0
a.aura.ts=store.tick_ts
a.aura.source_id=this.id
queue_insert(store,a)
end
local function buff_enemies()
local a=E:create_entity(this.enemy_aura_t)
a.pos.x,a.pos.y=0,0
a.aura.ts=store.tick_ts
a.aura.source_id=this.id
queue_insert(store,a)
end
local function duel_outcome(result)
if result=="paladin" then
sp.spawn_paladin=true
else
local slayer=E:create_entity(this.slayer_t)
slayer.nav_path.pi=this.path_slayers
slayer.nav_path.spi=1
slayer.nav_path.ni=1
slayer.enemy.gold=0
slayer.pos=P:node_pos(slayer.nav_path.pi,slayer.nav_path.spi,slayer.nav_path.ni)
queue_insert(store,slayer)
if not U.is_seen(store,this.slayer_t) then
signal.emit("wave-notification","icon",this.slayer_t)
U.mark_seen(store,this.slayer_t)
end
end
end
while true do
if this.duel_call then
this.duel_call=false
this.duel_result=nil
duel_decal.duel_started=true
U.y_wait(store,fts(116))
local alert_enemy=E:create_entity(this.alert_enemy)
alert_enemy.pos=this.alert_enemy_pos
queue_insert(store,alert_enemy)
U.y_wait(store,1e+99,function()
return this.duel_result~=nil
end)
queue_remove(store,alert_enemy)
if this.duel_result=="paladin" then
buff_allies()
else
buff_enemies()
this.paladin_lost=true
end
U.y_wait(store,1e+99,function()
return not duel_decal.duel_started
end)
U.y_wait(store,this.duel_result=="paladin" and this.paladin_victory_wait or this.slayer_victory_wait)
duel_outcome(this.duel_result)
this.duel_call=false
end
coroutine.yield()
end
end
local function enemy_stage_217_duel_alert_insert(this,store)
this.nav_path.pi=11
this.nav_path.ni=P:get_visible_end_node(11)-1
return true
end
local function enemy_stage_217_duel_alert_remove(this,store)
if this.ui and this.ui.alert_view then
this.ui.alert_view:remove()
end
return true
end
local function mod_stage_217_duel_visuals_update(this,store)
local target=store.entities[this.modifier.target_id]
if not target then
queue_remove(store,this)
return
end
if this.render.sprites[1].size_scales then
this.render.sprites[1].scale=this.render.sprites[1].size_scales[target.unit.size]
end
this.pos=target.pos
U.y_animation_play(this,this.animation_enter,nil,store.tick_ts,1,1)
scripts.mod_track_target.update(this,store)
end
local function decal_stage_217_blacksmith_update(this,store)
local ts=store.tick_ts
while true do
::label_blacksmith::
if this.ui.clicked then
U.y_animation_play(this,"click",nil,store.tick_ts,1)
U.animation_start(this,"idle_yunke",nil,store.tick_ts,true)
return
end
if store.tick_ts-ts>this.loop_time then
U.animation_start(this,"hamer",nil,store.tick_ts,false)
while not U.animation_finished(this) do
if this.ui.clicked then
goto label_blacksmith
end
coroutine.yield()
end
U.animation_start(this,"loop",nil,store.tick_ts,false)
ts=store.tick_ts
end
coroutine.yield()
end
end
local function decal_stage_217_bonfire_update(this,store)
while true do
if this.ui.clicked then
this.ui.clicked=nil
this.ui.can_click=false
S:queue(this.sound_extinguish)
U.y_animation_play(this,"action",nil,store.tick_ts,1)
U.animation_start(this,"idle_ashes",nil,store.tick_ts,true)
break
end
coroutine.yield()
end
while true do
coroutine.yield()
end
queue_remove(store,this)
end
function level:init(store)
self.manual_hero_insertion=false
end
function level:update(store)
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
local duel=table.filter(store.entities,function(k,entity)
return entity.template_name=="controller_stage_217_duel"
end)[1]
if (not duel or not duel.paladin_lost) and store.level_mode==GAME_MODE_CAMPAIGN then
signal.emit("there-can-only-be-one-stage17")
end
log.debug("-- WON")
end
return level
