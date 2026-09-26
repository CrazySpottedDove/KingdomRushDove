local LU=require("level_utils")
local P=require("path_db")
local E=require("entity_db")
local U=require("utils")
local V=require("lib.klua.vector")
local log=require("lib.klua.log"):new("level206")
require("all.constants")
require("lib.klua.table")
local level={}
function level:init(store)
local S=require("sound_db")
local SU=require("script_utils")
local scripts=require("scripts")
local signal=require("lib.hump.signal")
local r=V.r
local v=V.v
local vv=V.vv
local function AC(tpl,...)
return E:add_comps(tpl,...)
end
local function fts(t)
return t/30
end
local function queue_insert(store,e)
simulation:queue_insert_entity(e)
end
local function queue_remove(store,e)
simulation:queue_remove_entity(e)
end
local function queue_damage(store,damage)
store.damage_queue[#store.damage_queue+1]=damage
end
local function find_all_t(store,template_name,contains,fn)
if not store or not store.entities then
return {}
end
return table.filter(store.entities,function(k,val)
return (contains and string.find(val.template_name,template_name) or val.template_name==template_name) and (not fn or fn(k,val))
end)
end
local function decal_stage_206_mushroom_mage_update(this,store,script)
while not this.ui.clicked do
coroutine.yield()
end
local smoke=find_all_t(store,this.smoke_t)[1]
local lights=find_all_t(store,this.lights_t)[1]
U.animation_start(smoke,"out",nil,store.tick_ts,1)
U.animation_start(lights,"out",nil,store.tick_ts,1)
U.animation_start(this,"tap",nil,store.tick_ts,1)
for i,snd in ipairs(this.sounds) do
U.y_wait(store,this.waits_sound[i])
S:queue(snd)
end
end
local function decal_stage_206_flush_stick_update(this,store,script)
while not this.ui.clicked do
coroutine.yield()
end
U.animation_start(this,"tap",nil,store.tick_ts,1)
S:queue(this.sound_flush)
U.y_wait(store,fts(15))
local wave=find_all_t(store,this.wave_t)[1]
queue_remove(store,wave)
local mage=find_all_t(store,this.mage_t)[1]
U.y_animation_play(mage,"flush",nil,store.tick_ts,1)
U.animation_start(mage,"loop_2",nil,store.tick_ts,true)
end
local function controller_stage_206_nivus_update(this,store)
local current_mode=1
local spells={this.books,this.disintegrate,this.brooms}
local nivus,bubble
local function find_target(spell,ignore_fail)
local pred_time=spell.time_to_hit
if spell==this.disintegrate then
pred_time=0
end
local target,targets,pred_pos=U.find_foremost_enemy(store,v(512,350),spell.min_range,spell.max_range,pred_time,spell.vis_flags,spell.vis_bans,function(e,o)
if spell==this.disintegrate then
return e.health.hp>=this.disintegrate.min_hp and e.health.hp<=this.disintegrate.max_hp and e.nav_path and P:is_node_valid(e.nav_path.pi,e.nav_path.ni)
else
return e.nav_path and P:is_node_valid(e.nav_path.pi,e.nav_path.ni)
end
end)
if spell==this.brooms then
target,targets,pred_pos=U.find_foremost_enemy(store,v(512,350),spell.min_range,spell.max_range,pred_time,spell.vis_flags,spell.vis_bans,function(e,o)
return e.nav_path and P:is_node_valid(e.nav_path.pi,e.nav_path.ni) and P:nodes_to_goal(e.nav_path.pi,e.nav_path.spi,e.nav_path.ni)>=spell.min_nodes
end)
if not targets or #targets==0 then
target,targets,pred_pos=U.find_foremost_enemy(store,v(512,350),spell.min_range,spell.max_range,pred_time,spell.vis_flags,spell.vis_bans,function(e,o)
return e.nav_path and P:is_node_valid(e.nav_path.pi,e.nav_path.ni)
end)
end
end
if spell==this.disintegrate and not target then
target,targets,pred_pos=U.find_foremost_enemy(store,v(512,350),spell.min_range,spell.max_range,pred_time,spell.vis_flags,spell.vis_bans)
if targets then
table.sort(targets,function(v1,v2)
return v1.health.hp>v2.health.hp
end)
target=targets[1]
pred_pos=target.pos
end
end
if not ignore_fail and (not target or not pred_pos) then
nivus.tween.disabled=false
nivus.tween.ts=store.tick_ts
end
return target, targets, pred_pos
end
local function y_shoot_magic_missiles()
local target,targets,pred_pos=find_target(this.magic_missiles,true)
if not target then
return
end
local enemies=U.find_enemies_in_range(store,target.pos,0,100,this.magic_missiles.vis_flags,this.magic_missiles.vis_bans)
if not enemies or #enemies<=0 then
return
end
local target_idx=1
U.y_animation_play(nivus,this.magic_missiles.animation_in,nil,store.tick_ts,1)
for i=1,this.magic_missiles.count do
target=enemies[target_idx]
U.animation_start(nivus,this.magic_missiles.animation_shoot,nil,store.tick_ts,false)
U.y_wait(store,this.magic_missiles.shoot_time)
local b=E:create_entity(this.magic_missiles.bullet)
b.pos=V.vclone(nivus.pos)
local offset=this.magic_missiles.bullet_start_offset
b.pos.x,b.pos.y=b.pos.x+offset.x,b.pos.y+offset.y
b.bullet.from=V.vclone(b.pos)
b.bullet.to=V.v(target.pos.x+target.unit.hit_offset.x,target.pos.y+target.unit.hit_offset.y)
b.bullet.target_id=target.id
b.bullet.shot_index=1
b.bullet.loop_index=i
b.bullet.source_id=this.id
queue_insert(store,b)
U.y_animation_wait(nivus)
target_idx=target_idx+1
if target_idx>#enemies then
target_idx=1
end
end
U.y_animation_play(nivus,this.magic_missiles.animation_out,nil,store.tick_ts,1)
U.animation_start(nivus,"idle",nil,store.tick_ts,true)
end
while true do
local current_spell=spells[current_mode]
nivus=E:create_entity(this.nivus_t)
nivus.pos=V.vclone(current_spell.spawn_pos)
nivus.render.sprites[1].sort_y_offset=384-nivus.pos.y+this.nivus_sort_y_offset
nivus.render.sprites[1].ts=store.tick_ts
nivus.render.sprites[1].hidden=false
queue_insert(store,nivus)
U.y_animation_play(nivus,"in",nil,store.tick_ts,1)
U.animation_start(nivus,"idle",nil,store.tick_ts,true)
bubble=E:create_entity(current_spell.bubble_t)
bubble.pos=V.vclone(nivus.pos)
bubble.pos.x=bubble.pos.x+this.bubble_offset.x
bubble.pos.y=bubble.pos.y+this.bubble_offset.y
bubble.render.sprites[1].hidden=true
bubble.tween.ts=store.tick_ts
queue_insert(store,bubble)
this.ui.click_rect.pos.x=nivus.pos.x-this.pos.x-this.ui.click_rect.size.x/2
this.ui.click_rect.pos.y=nivus.pos.y-this.pos.y
local books={}
local target_picked,_,pred_pos
this.ui.clicked=nil
if current_mode==1 then
for i=1,3 do
local start_ts=store.tick_ts
U.animation_start(nivus,this.books.animation_charge,nil,store.tick_ts,false)
U.y_wait(store,fts(11))
local fx=E:create_entity(this.books.book_charge_fx_t)
fx.pos=V.v(nivus.pos.x,nivus.pos.y+50)
fx.render.sprites[1].ts=store.tick_ts
queue_insert(store,fx)
local book=E:create_entity(this.books.book_charge_t)
book.pos=V.v(nivus.pos.x+this.books.offsets[i].x,nivus.pos.y+this.books.offsets[i].y)
book.tween.ts=store.tick_ts
local starting_offset=V.v(fx.pos.x-book.pos.x,fx.pos.y-book.pos.y)
book.tween.props[5]=E:clone_c("tween_prop")
book.tween.props[5].keys={{0,starting_offset},{1,v(0,0)}}
book.tween.props[5].name="offset"
book.tween.props[6]=table.deepclone(book.tween.props[5])
book.tween.props[6].sprite_id=2
queue_insert(store,book)
table.insert(books,book)
if i==2 then
book.tween.props[2].keys={{0,0},{1,1.9*math.pi}}
book.tween.props[4].keys={{0,0},{1,1.9*math.pi}}
elseif i==3 then
book.render.sprites[1].flip_x=true
book.render.sprites[2].flip_x=true
book.tween.props[2].keys={{0,0},{1,-1.8*math.pi}}
book.tween.props[4].keys={{0,0},{1,-1.8*math.pi}}
end
U.y_animation_wait(nivus)
U.animation_start(nivus,"idle",nil,store.tick_ts,true)
local et=store.tick_ts-start_ts
U.y_wait(store,1-et+fts(11))
book.tween.props[1].disabled=false
for j=2,6 do
book.tween.props[j].disabled=true
end
book.tween.ts=store.tick_ts
et=store.tick_ts-start_ts
if this.ui.clicked then
this.ui.clicked=nil
target_picked,_,pred_pos=find_target(this.books)
if target_picked then
break
end
end
U.y_wait(store,this.books.delay_between_books-et)
if this.ui.clicked then
this.ui.clicked=nil
target_picked,_,pred_pos=find_target(this.books)
if target_picked then
break
end
end
end
end
local wait_ts=store.tick_ts
local bubble_ts=store.tick_ts
local bubble_cd=2
local near_target,_,_=find_target(current_spell,true)
if near_target and (not target_picked or not pred_pos) then
bubble.render.sprites[1].hidden=false
bubble.tween.ts=store.tick_ts
end
bubble.tween.reverse=true
while not this.ui.clicked do
if store.tick_ts-wait_ts>this.magic_missiles.cooldown then
wait_ts=store.tick_ts
y_shoot_magic_missiles()
end
if bubble_cd<store.tick_ts-bubble_ts then
near_target,_,pred_pos=find_target(current_spell,true)
if near_target or not bubble.tween.reverse then
bubble.render.sprites[1].hidden=false
bubble_cd=bubble.tween.reverse and 3 or 8
bubble.tween.ts=store.tick_ts
bubble.tween.reverse=not bubble.tween.reverse
bubble_ts=store.tick_ts
end
end
coroutine.yield()
end
this.ui.clicked=nil
target_picked,_,pred_pos=find_target(current_spell,true)
queue_remove(store,bubble)
if current_mode==1 then
U.animation_start(nivus,this.books.animation_shoot,nil,store.tick_ts,false)
U.y_wait(store,this.books.cast_time)
if not target_picked or not pred_pos then
target_picked,_,pred_pos=find_target(current_spell,true)
end
pred_pos=pred_pos or V.v(575,242)
for i=1,#books do
local fx=E:create_entity(this.books.book_charge_fx_t)
fx.pos=books[i].pos
fx.render.sprites[1].ts=store.tick_ts
queue_insert(store,fx)
local b=E:create_entity(this.books.bullet_t)
b.pos=books[i].pos
b.bullet.from=V.vclone(b.pos)
b.bullet.to=pred_pos
local nearest=P:nearest_nodes(b.bullet.to.x,b.bullet.to.y,nil,{1},true)[1]
local pi,spi,ni=unpack(nearest)
spi=i
if i==2 or i==3 then
ni=ni+3
end
b.bullet.to=P:node_pos(pi,spi,ni)
b.bullet.source_id=this.id
queue_insert(store,b)
queue_remove(store,books[i])
U.y_wait(store,fts(3))
end
local c=E:create_entity(this.books.squad_controller_t)
c.books_spawned=#books
queue_insert(store,c)
U.y_animation_wait(nivus)
elseif current_mode==2 then
local target_pos=target_picked and target_picked.pos or V.v(575,242)
if target_picked then
local m=E:create_entity(this.disintegrate.mod_stun)
m.modifier.target_id=target_picked.id
m.modifier.source_id=this.id
queue_insert(store,m)
target_picked.health.ignore_damage=true
U.y_wait(store,fts(1))
target_picked.vis.bans=F_ALL
local nivus_on_the_right=math.abs(km.signed_unroll(target_picked.heading.angle))<math.pi/2
target_pos=V.v(target_picked.pos.x+(target_picked.enemy.melee_slot.x+20)*(nivus_on_the_right and 1 or -1),target_picked.pos.y+target_picked.enemy.melee_slot.y)
end
S:queue(this.disintegrate.sound_teleport)
U.y_animation_play(nivus,this.disintegrate.animation_out,nil,store.tick_ts,1)
U.y_wait(store,fts(10))
nivus.pos=target_pos
nivus.render.sprites[1].flip_x=target_picked and math.abs(km.signed_unroll(target_picked.heading.angle))<math.pi/2
nivus.render.sprites[1].z=Z_OBJECTS
nivus.render.sprites[1].sort_y_offset=0
S:queue(this.disintegrate.sound_teleport)
U.y_animation_play(nivus,this.disintegrate.animation_in,nil,store.tick_ts,1)
U.animation_start(nivus,this.disintegrate.animation_cast,nil,store.tick_ts,false)
U.y_wait(store,this.disintegrate.cast_time)
S:queue(this.disintegrate.sound_cast)
if target_picked then
target_picked.health.ignore_damage=false
local d=E.create_damage()
d.damage_type=DAMAGE_EAT
d.source_id=this.id
d.target_id=target_picked.id
d.value=1e+99
queue_damage(store,d)
local fx=E:create_entity(this.disintegrate.vanish_fx_t)
fx.pos.x,fx.pos.y=target_picked.pos.x+target_picked.unit.hit_offset.x,target_picked.pos.y+target_picked.unit.hit_offset.y
fx.render.sprites[1].ts=store.tick_ts
queue_insert(store,fx)
end
U.y_animation_wait(nivus)
U.y_wait(store,fts(10))
S:queue(this.disintegrate.sound_teleport)
U.y_animation_play(nivus,this.disintegrate.animation_out,nil,store.tick_ts,1)
nivus.pos=V.vclone(this.disintegrate.spawn_pos)
nivus.render.sprites[1].flip_x=false
nivus.render.sprites[1].z=Z_FLYING_HEROES
nivus.render.sprites[1].sort_y_offset=384-nivus.pos.y-101
S:queue(this.disintegrate.sound_teleport)
U.y_animation_play(nivus,this.disintegrate.animation_in,nil,store.tick_ts,1)
else
U.animation_start(nivus,this.brooms.animation,nil,store.tick_ts,false)
U.y_wait(store,this.brooms.cast_time)
local new_target,_,_=find_target(this.brooms,true)
if new_target then
target_picked=new_target
end
local target_pos=V.v(575,242)
if target_picked then
target_pos=V.v(target_picked.pos.x+target_picked.unit.hit_offset.x,target_picked.pos.y+target_picked.unit.hit_offset.y)
end
this.chain_targets={}
local b=E:create_entity(this.brooms.ray_t)
local start_offset=this.brooms.bullet_start_offset
b.pos.x,b.pos.y=nivus.pos.x+start_offset.x,nivus.pos.y+start_offset.y
b.bullet.from=V.vclone(b.pos)
b.bullet.to=target_pos
b.bullet.target_id=target_picked and target_picked.id
b.bullet.source_id=this.id
b.chain_pos=1
queue_insert(store,b)
if target_picked then
table.insert(this.chain_targets,target_picked.id,target_picked.id)
end
local dist=V.dist(b.bullet.from.x,b.bullet.from.y,target_pos.x,target_pos.y)
local fxs=math.floor(dist/80)
local dist_v=V.v(target_pos.x-b.bullet.from.x,target_pos.y-b.bullet.from.y)
for i=1,fxs-1 do
local dist_v_aux=V.v(i/fxs*dist_v.x,i/fxs*dist_v.y)
local fx=E:create_entity(this.brooms.magic_fx_t)
fx.pos.x,fx.pos.y=V.add(b.bullet.from.x,b.bullet.from.y,dist_v_aux.x,dist_v_aux.y)
fx.render.sprites[1].ts=store.tick_ts
if math.random(1,2)==1 then
fx.render.sprites[1].flip_x=true
end
queue_insert(store,fx)
U.y_wait(store,fts(1))
end
U.y_animation_wait(nivus)
end
U.animation_start(nivus,"idle",nil,store.tick_ts,true)
U.y_wait(store,fts(15))
U.y_animation_play(nivus,"out",nil,store.tick_ts,1)
nivus.render.sprites[1].hidden=true
U.y_wait(store,this.delay_between_spells)
current_mode=current_mode+1
if current_mode>3 then
current_mode=1
end
end
end
local function controller_stage_206_nivus_books_squads_update(this,store)
local books
repeat
coroutine.yield()
books=find_all_t(store,this.books_t)
until books and #books>=this.books_spawned
for i,b in ipairs(books) do
b.reinforcement.squad_id=this.id
local a=2*math.pi/3
local pos=U.point_on_ellipse(books[1].pos,25,(i-1)*a-math.pi/2+math.pi/4)
local center=V.vclone(books[1].pos)
b.nav_rally.pos,b.nav_rally.center=pos,center
end
queue_remove(store,this)
end
local function bullet_nivus_magic_missiles_insert(this,store)
local b=this.bullet
if not store.entities[b.target_id] then
return false
end
b.to=V.v(this.pos.x+math.random(10,90)*(math.random()<0.5 and -1 or 1),this.pos.y+math.random(100,300))
local ps=E:create_entity(b.particles_name)
ps.particle_system.track_id=this.id
queue_insert(store,ps)
return true
end
local function soldier_nivus_book_insert(this,store,script)
this.nav_rally.center=V.vclone(this.pos)
this.nav_rally.pos=V.vclone(this.pos)
return scripts.soldier_reinforcement.insert(this,store,script)
end
local function soldier_nivus_book_update(this,store,script)
this.reinforcement.ts=store.tick_ts
this.render.sprites[1].ts=store.tick_ts
signal.emit("spawned-reinforcement",this)
if this.render.sprites[1].name=="in" then
this.health_bar.hidden=true
U.y_animation_play(this,"in",nil,store.tick_ts,1)
if not this.health.dead then
this.health_bar.hidden=nil
end
end
return scripts.soldier_reinforcement.update(this,store,script)
end
local function bullet_nivus_brooms_update(this,store)
local b=this.bullet
local s=this.render.sprites[1]
local target=store.entities[b.target_id]
local source=store.entities[b.source_id]
local dest=V.vclone(b.to)
local function update_sprite()
if this.track_target and target and target.motion then
local tpx,tpy=target.pos.x,target.pos.y
tpx,tpy=tpx+target.unit.hit_offset.x,tpy+target.unit.hit_offset.y
dest.x,dest.y=tpx,tpy
b.to.x,b.to.y=target.pos.x+target.unit.hit_offset.x,target.pos.y+target.unit.hit_offset.y
end
local angle=V.angleTo(dest.x-this.pos.x,dest.y-this.pos.y)
s.r=angle
local dist_offset=this.dist_offset or 0
s.scale.x=(V.dist(dest.x,dest.y,this.pos.x,this.pos.y)+dist_offset)/this.image_width
end
s.scale=s.scale or V.vv(1)
U.animation_start(this,"run",nil,store.tick_ts,false)
update_sprite()
if b.hit_fx then
local fx=E:create_entity(b.hit_fx)
if target then
fx.pos.x,fx.pos.y=target.pos.x,target.pos.y
fx.render.sprites[1].offset=target.unit.hit_offset
else
fx.pos.x,fx.pos.y=b.to.x,b.to.y
fx.render.sprites[1].offset=V.v(0,0)
end
fx.render.sprites[1].ts=store.tick_ts
queue_insert(store,fx)
end
if b.hit_time>fts(1) then
while store.tick_ts-s.ts<b.hit_time do
coroutine.yield()
if target and U.flag_has(target.vis.bans,F_RANGED) then
target=nil
end
if this.track_target then
update_sprite()
end
end
end
U.y_wait(store,fts(1))
if this.chain_pos<this.max_chain_length and target then
local chain_target=U.find_nearest_enemy(store,target.pos,0,this.chain_range,this.vis_flags,this.vis_bans,function(e,o)
return source and source.chain_targets and not table.contains(source.chain_targets,e.id) and e.template_name~="enemy_nivus_broom" and e.template_name~="enemy_nivus_broom_flying"
end)
if chain_target then
local chain=E:create_entity(this.chain_ray_t)
local start_offset=target.unit.hit_offset
chain.pos.x,chain.pos.y=target.pos.x+start_offset.x,target.pos.y+start_offset.y
chain.bullet.from=V.vclone(chain.pos)
local end_offset=chain_target.unit.hit_offset
chain.bullet.to=V.vclone(chain_target.pos)
chain.bullet.to.x,chain.bullet.to.y=chain.bullet.to.x+end_offset.x,chain.bullet.to.y+end_offset.y
chain.bullet.target_id=chain_target.id
chain.bullet.source_id=b.source_id
chain.chain_pos=this.chain_pos+1
queue_insert(store,chain)
table.insert(source.chain_targets,chain_target.id,chain_target.id)
end
end
U.y_wait(store,fts(5))
if not target then
target=store.entities[b.target_id]
if not target then
queue_remove(store,this)
return
end
end
if b.mod or b.mods then
local mods=b.mods or {b.mod}
for _,mod_name in pairs(mods) do
local m=E:create_entity(mod_name)
m.modifier.target_id=b.target_id
m.modifier.source_id=b.source_id
queue_insert(store,m)
end
end
local fx=E:create_entity(this.transform_fx)
fx.pos.x,fx.pos.y=target.pos.x+target.unit.hit_offset.x,target.pos.y+target.unit.hit_offset.y
fx.render.sprites[1].ts=store.tick_ts
queue_insert(store,fx)
U.y_wait(store,fts(4))
this.render.sprites[1].hidden=true
queue_remove(store,this)
end
local function mod_nivus_brooms_polymorph_insert(this,store)
local target=store.entities[this.modifier.target_id]
if target then
this.target_ref=target
for _,s in ipairs(target.render.sprites) do
s.hidden=true
end
this.polymorph_enemy={enemy=target}
SU.remove_modifiers(store,target)
SU.remove_auras(store,target)
queue_remove(store,target)
U.unblock_all(store,target)
if target.ui then
target.ui.can_click=false
end
target.main_script.co=nil
target.main_script.runs=0
if target.count_group then
target.count_group.in_limbo=true
end
target.trigger_deselect=true
local is_flying=U.flag_has(target.vis.flags,F_FLYING)
local broom=E:create_entity(is_flying and this.entity_t_flying or this.entity_t)
broom.pos.x,broom.pos.y=target.pos.x,target.pos.y
broom.nav_path=target.nav_path
broom.health.hp_max=target.health.hp_max*this.hp_mult
broom.health.hp=target.health.hp*this.hp_mult
if broom.grant_original_enemy_gold then
broom.enemy.gold=target.enemy.gold
end
queue_insert(store,broom)
this.polymorph_enemy.broom=broom
return true
end
return false
end
local function mod_nivus_brooms_polymorph_update(this,store,script)
local m=this.modifier
this.modifier.ts=store.tick_ts
local target=this.target_ref
this.pos.x,this.pos.y=target.pos.x,target.pos.y
while true do
if m.duration>=0 and store.tick_ts-m.ts>m.duration then
queue_remove(store,this)
return
end
coroutine.yield()
end
end
local function mod_nivus_brooms_polymorph_remove(this,store)
local target=this.polymorph_enemy.enemy
local broom=this.polymorph_enemy.broom
if broom and store.entities[broom.id] and not broom.health.dead then
for _,s in ipairs(target.render.sprites) do
s.hidden=false
end
target.main_script.runs=1
if target.ui then
target.ui.can_click=true
end
target.pos.x,target.pos.y=broom.pos.x,broom.pos.y
target.nav_path=broom.nav_path
target.health.hp=target.health.hp_max*broom.health.hp/broom.health.hp_max
queue_insert(store,target)
broom.trigger_deselect=true
if this.sound_transform_out then
S:queue(this.sound_transform_out)
end
local sfx=E:create_entity(this.transform_fx)
sfx.pos.x,sfx.pos.y=target.pos.x+target.unit.hit_offset.x,target.pos.y+target.unit.hit_offset.y
sfx.render.sprites[1].ts=store.tick_ts
sfx.render.sprites[1].runs=0
if sfx.render.sprites[1].size_names then
sfx.render.sprites[1].name=sfx.render.sprites[1].size_names[target.unit.size]
end
queue_insert(store,sfx)
queue_remove(store,broom)
end
return true
end
local mask_z={Z_OBJECTS_COVERS,Z_OBJECTS_COVERS,Z_OBJECTS_COVERS,Z_OBJECTS_COVERS,Z_OBJECTS_COVERS,Z_OBJECTS_COVERS,Z_OBJECTS,Z_OBJECTS_COVERS,Z_OBJECTS,Z_OBJECTS_COVERS+1}
local tt=E:register_t_hot("decal_stage_206_mask_1","decal",true)
tt.render.sprites[1].name="Stage_6_tower_mask"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_FLYING_HEROES
tt.render.sprites[1].sort_y_offset=-20
tt=E:register_t_hot("decal_stage_206_mask_2","decal",true)
tt.render.sprites[1].name="Stage_6_tower_door_mask"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].sort_y_offset=-114
tt=E:register_t_hot("decal_stage_206_mask_3","decal",true)
tt.render.sprites[1].name="Stage_6_balcony_mask"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_FLYING_HEROES
tt.render.sprites[1].sort_y_offset=-102
tt=E:register_t_hot("decal_stage_206_mask_4","decal",true)
tt.render.sprites[1].name="Stage_6_tower_door_shadow"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].sort_y_offset=-102
tt=E:register_t_hot("decal_stage_206_mushroom_mage","decal_scripted",true)
AC(tt,"ui")
tt.render.sprites[1].prefix="mushroom_mageDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.main_script.insert=scripts.decal_utils.censor_cn_insert
tt.main_script.update=decal_stage_206_mushroom_mage_update
tt.waits_sound={fts(64),fts(136),fts(165)}
tt.sounds={"Stage06WizardMushroomYawn","Stage06WizardMushroomEat","Stage06WizardMushroomHitSigh"}
tt.smoke_t="decal_stage_206_mushroom_mage_smoke"
tt.lights_t="decal_stage_206_mushroom_mage_lights"
tt.ui.click_rect=r(-560,-20,123,100)
tt=E:register_t_hot("decal_stage_206_mushroom_mage_lights","decal_scripted",true)
tt.main_script.insert=scripts.decal_utils.censor_cn_insert
tt.render.sprites[1].prefix="mushroom_mage_lightDef"
tt.render.sprites[1].name="loop"
tt.render.sprites[1].exo=true
tt=E:register_t_hot("decal_stage_206_mushroom_mage_smoke","decal_scripted",true)
tt.main_script.insert=scripts.decal_utils.censor_cn_insert
tt.render.sprites[1].prefix="mushroom_mage_smokeDef"
tt.render.sprites[1].name="loop"
tt.render.sprites[1].exo=true
tt=E:register_t_hot("decal_stage_206_flush_stick","decal_scripted",true)
AC(tt,"ui")
tt.render.sprites[1].prefix="float_mage_stickDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_DECALS
tt.main_script.update=decal_stage_206_flush_stick_update
tt.sound_flush="Stage06LakeWizardTap"
tt.mage_t="decal_stage_206_flush_mage"
tt.wave_t="decal_stage_206_flush_wave"
tt.ui.click_rect=r(202,262,100,45)
tt=E:register_t_hot("decal_stage_206_flush_mage","decal",true)
tt.render.sprites[1].prefix="float_mageDef"
tt.render.sprites[1].name="loop_1"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_DECALS
tt=E:register_t_hot("decal_stage_206_flush_wave","decal",true)
tt.render.sprites[1].prefix="float_mage_waveDef"
tt.render.sprites[1].name="loop"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_DECALS-1
tt=E:register_t_hot("decal_stage_206_nivus","decal_tween",true)
tt.render.sprites[1].prefix="nivus_nivus"
tt.render.sprites[1].name="in"
tt.render.sprites[1].animated=true
tt.render.sprites[1].loop=true
tt.render.sprites[1].z=Z_FLYING_HEROES
tt.tween.props[1].keys={{0,vv(1)},{fts(3),vv(1.1)},{fts(6),vv(1)}}
tt.tween.props[1].name="scale"
tt.tween.remove=false
tt.tween.reverse=false
tt.tween.disabled=true
tt=E:register_t_hot("decal_nivus_book_charge","decal_tween",true)
tt.render.sprites[1].name="nivus_animate_book_call_idle"
tt.render.sprites[1].animated=true
tt.render.sprites[1].z=Z_BULLETS
tt.render.sprites[2]=E:clone_c("sprite")
tt.render.sprites[2].name="nivus_animate_book_call_color_effect"
tt.render.sprites[2].animated=false
tt.render.sprites[2].z=Z_BULLETS
tt.tween.props[1].keys={{0,v(0,0)},{2,v(0,8)},{4,v(0,0)}}
tt.tween.props[1].name="offset"
tt.tween.props[1].loop=true
tt.tween.props[1].interp="sine"
tt.tween.props[1].disabled=true
tt.tween.props[2]=E:clone_c("tween_prop")
tt.tween.props[2].keys={{0,0},{1,2*math.pi}}
tt.tween.props[2].name="r"
tt.tween.props[3]=E:clone_c("tween_prop")
tt.tween.props[3].keys={{0,255},{1,0}}
tt.tween.props[3].name="alpha"
tt.tween.props[3].sprite_id=2
tt.tween.props[4]=table.deepclone(tt.tween.props[2])
tt.tween.props[4].sprite_id=2
tt.tween.remove=false
tt.tween.reverse=false
tt=E:register_t_hot("decal_nivus_books_bubble","decal_tween",true)
tt.render.sprites[1].name="nivus_book_icon"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_SKY
tt.tween.props[1].keys={{0,vv(0.25)},{fts(8),vv(1.2)},{fts(12),vv(0.9)},{fts(14),vv(1)}}
tt.tween.props[1].name="scale"
tt.tween.props[1].interp="sine"
tt.tween.props[2]=E:clone_c("tween_prop")
tt.tween.props[2].keys={{0,0},{fts(8),255}}
tt.tween.remove=false
tt.tween.reverse=false
tt=E:register_t_hot("decal_nivus_brooms_bubble","decal_nivus_books_bubble",true)
tt.render.sprites[1].name="nivus_polymorph_icon"
tt=E:register_t_hot("decal_nivus_disintegrate_bubble","decal_nivus_books_bubble",true)
tt.render.sprites[1].name="nivus_desintegrate_icon"
tt=E:register_t_hot("fx_nivus_magic_missiles_hit","fx",true)
tt.render.sprites[1].prefix="nivus_missile_explosion"
tt.render.sprites[1].name="run"
tt=E:register_t_hot("fx_nivus_book_charge","fx",true)
tt.render.sprites[1].prefix="nivus_animate_book_call"
tt.render.sprites[1].name="out"
tt=E:register_t_hot("fx_nivus_book_hit","fx",true)
tt.render.sprites[1].prefix="nivus_animate_book_hit"
tt.render.sprites[1].name="run"
tt=E:register_t_hot("fx_nivus_disintegrate","fx",true)
tt.render.sprites[1].prefix="nivus_desintegrate"
tt.render.sprites[1].name="run"
tt=E:register_t_hot("fx_nivus_brooms","fx",true)
tt.render.sprites[1].prefix="nivus_polymorph_ray_hit"
tt.render.sprites[1].name="run"
tt=E:register_t_hot("fx_nivus_brooms_magic","fx",true)
tt.render.sprites[1].prefix="nivus_polymorph_particles"
tt.render.sprites[1].name="run"
tt=E:register_t_hot("ps_nivus_magic_missiles","particle_system",true)
tt.particle_system.animated=true
tt.particle_system.loop=false
tt.particle_system.z=Z_BULLET_PARTICLES
tt.particle_system.names={"nivus_missile_particle_01_run","nivus_missile_particle_02_run"}
tt.particle_system.particle_lifetime={fts(20),fts(20)}
tt.particle_system.emission_rate=50
tt.particle_system.emit_offset=v(0,0)
tt.particle_system.emit_area_spread=v(2,2)
tt.particle_system.track_rotation=true
tt=E:register_t_hot("ps_nivus_book","particle_system",true)
tt.particle_system.animated=true
tt.particle_system.loop=false
tt.particle_system.z=Z_BULLET_PARTICLES
tt.particle_system.names={"nivus_animate_book_particle_run","nivus_animate_book_particle_1_run"}
tt.particle_system.particle_lifetime={fts(23),fts(23)}
tt.particle_system.emission_rate=10
tt.particle_system.emit_offset=v(18,8)
tt.particle_system.emit_area_spread=v(25,25)
tt=E:register_t_hot("bullet_nivus_magic_missiles","bullet",true)
tt.render.sprites[1].prefix="nivus_missile"
tt.render.sprites[1].name="run"
tt.render.sprites[1].flip_x=true
tt.bullet.retarget_range=200
tt.bullet.damage_min=5
tt.bullet.damage_max=15
tt.bullet.damage_type=DAMAGE_MAGICAL
tt.bullet.min_speed=270
tt.bullet.max_speed=330
tt.bullet.turn_speed=20*math.pi/180*30
tt.bullet.acceleration_factor=0.1
tt.bullet.hit_fx="fx_nivus_magic_missiles_hit"
tt.bullet.hit_fx_air="fx_nivus_magic_missiles_hit"
tt.bullet.vis_flags=F_RANGED
tt.bullet.particles_name="ps_nivus_magic_missiles"
tt.main_script.insert=bullet_nivus_magic_missiles_insert
tt.main_script.update=scripts.missile.update
tt.sound_events.hit=nil
tt.sound_events.insert="Stage06NivusMagicMissileCast"
tt=E:register_t_hot("bullet_nivus_book","bomb",true)
tt.bullet.damage_min=0
tt.bullet.damage_max=0
tt.bullet.damage_radius=0
tt.bullet.flight_time=fts(40)
tt.bullet.hit_fx=nil
tt.bullet.hit_fx_water=nil
tt.bullet.hit_decal=nil
tt.bullet.pop_chance=0
tt.bullet.align_with_trajectory=false
tt.bullet.rotation_speed=10
tt.bullet.hit_payload="soldier_nivus_book"
tt.bullet.particles_name="ps_nivus_book"
tt.sound_events.hit_water=nil
tt.sound_events.insert="Stage06NivusSpawnBooksCast"
tt.sound_events.remove="Stage06NivusSpawnBooksSummon"
tt.render.sprites[1].prefix="nivus_animate_book_call"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].animated=true
tt=E:register_t_hot("bullet_nivus_brooms_long","bullet",true)
tt.bullet.damage_type=DAMAGE_NONE
tt.bullet.damage_min=0
tt.bullet.damage_max=0
tt.bullet.hit_time=fts(6)
tt.bullet.hit_fx="fx_nivus_brooms"
tt.bullet.mod="mod_nivus_brooms_polymorph"
tt.image_width=375
tt.main_script.update=bullet_nivus_brooms_update
tt.render.sprites[1].anchor=v(0.5,0.5)
tt.render.sprites[1].prefix="nivus_polymorph_ray"
tt.render.sprites[1].name="run"
tt.render.sprites[1].loop=false
tt.sound_events.insert="Stage06PolymorphCast"
tt.track_target=true
tt.ray_duration=10
tt.max_chain_length=5
tt.chain_range=120
tt.chain_ray_t="bullet_nivus_brooms_short"
tt.transform_fx="fx_nivus_brooms_magic"
tt=E:register_t_hot("bullet_nivus_brooms_short","bullet_nivus_brooms_long",true)
tt.image_width=65
tt.render.sprites[1].prefix="nivus_polymorph_ray_area"
tt=E:register_t_hot("enemy_nivus_broom","enemy",true)
tt.health.armor=0
tt.health.magic_armor=0
tt.health_bar.offset=v(0,39)
tt.grant_original_enemy_gold=true
tt.enemy.gold=5
tt.enemy.lives_cost=1
tt.info.portrait="kr6_info_portraits_enemies_0017"
tt.unit.hit_offset=v(0,14)
tt.unit.head_offset=v(0,5)
tt.unit.mod_offset=v(0,10)
tt.main_script.insert=scripts.enemy_basic.insert
tt.main_script.update=scripts.enemy_mixed.update
tt.motion.max_speed=20
tt.render.sprites[1].prefix="nivus_polymorph_broom"
tt.render.sprites[1].angles.walk={"walk","walk_down","walk_up"}
tt.sound_events.death="EnemyPumpkinDeath"
tt.ui.click_rect=r(-11,0,22,30)
tt.vis.flags=bor(F_ENEMY,F_POLYMORPH)
tt.vis.bans=bor(F_BLOCK,F_SKELETON)
tt=E:register_t_hot("enemy_nivus_broom_flying","enemy_nivus_broom",true)
tt.info.portrait="kr6_info_portraits_enemies_0018"
tt.flight_height=47
tt.health_bar.offset=v(0,tt.flight_height+20)
tt.health_bar.type=HEALTH_BAR_SIZE_MEDIUM
tt.render.sprites[1].prefix="nivus_polymorph_broom_flying"
tt.render.sprites[1].angles.walk={"fly","fly_down","fly_up"}
tt.render.sprites[1].offset=v(0,tt.flight_height)
tt.render.sprites[2]=E:clone_c("sprite")
tt.render.sprites[2].animated=false
tt.render.sprites[2].name="crowcaller_crow_shadow"
tt.render.sprites[2].offset=v(0,0)
tt.render.sprites[2].scale=vv(0.8)
tt.unit.hide_after_death=true
tt.unit.disintegrate_fx="fx_enemy_desintegrate_air"
tt.unit.hit_offset=v(0,tt.flight_height+10)
tt.unit.mod_offset=v(0,tt.flight_height+10)
tt.unit.show_blood_pool=false
tt.ui.click_rect=r(-18,tt.flight_height-10,36,23)
tt.vis.flags=bor(F_ENEMY,F_FLYING,F_POLYMORPH)
tt=E:register_t_hot("soldier_nivus_book","soldier_militia",true)
AC(tt,"reinforcement","tween","nav_grid")
tt.info.portrait="kr6_info_portraits_soldiers_0019"
tt.info.random_name_count=12
tt.info.random_name_format="SOLDIER_NIVUS_BOOK_%i_NAME"
tt.main_script.insert=soldier_nivus_book_insert
tt.main_script.update=soldier_nivus_book_update
tt.render.sprites[1].prefix="nivus_animate_book"
tt.render.sprites[1].name="in"
tt.render.sprites[1].anchor=v(0.5,0.5)
tt.render.sprites[1].angles.walk={"walk"}
tt.unit.hit_offset=v(0,12)
tt.unit.marker_offset=v(0,0)
tt.unit.mod_offset=v(0,13)
tt.unit.hide_after_death=true
tt.health.hp_max=35
tt.health.armor=0
tt.health_bar.offset=v(0,30)
tt.regen.health=4
tt.motion.max_speed=80
tt.melee.range=72
tt.vis.flags=bor(F_BLOCK,F_FRIEND)
tt.melee.attacks[1].cooldown=1
tt.melee.attacks[1].damage_min=10
tt.melee.attacks[1].damage_max=14
tt.melee.attacks[1].hit_times={fts(8),fts(21)}
tt.melee.attacks[1].loops=1
tt.melee.attacks[1].animations={nil,"attack"}
tt.melee.attacks[1].hit_fx="fx_nivus_book_hit"
tt.melee.attacks[1].hit_offset=v(15,15)
tt.soldier.melee_slot_offset=v(4,0)
tt.reinforcement.duration=16
tt.reinforcement.fade=false
tt.tween.props[1].keys={{0,0},{fts(10),255}}
tt.tween.props[1].name="alpha"
tt.tween.remove=false
tt.tween.reverse=false
tt.tween.disabled=true
tt.nivus_controller_t="controller_stage_206_nivus"
tt.ui.click_rect=r(-13,-2,26,25)
tt=E:register_t_hot("controller_stage_206_nivus",nil,true)
AC(tt,"main_script","pos","ui")
local b_nivus={delay_between_spells=15,magic_missiles={cooldown=17,min_range=0,max_range=400,count=3,damage_min=5,damage_max=15,damage_type=DAMAGE_MAGICAL},books={min_range=0,max_range=1000},disintegrate={min_range=0,max_range=1000,min_hp=220,max_hp=1000},brooms={min_nodes=40,max_range=1000,max_brooms=5,chain_range=120,duration=10}}
tt.main_script.update=controller_stage_206_nivus_update
tt.nivus_t="decal_stage_206_nivus"
tt.delay_between_spells=b_nivus.delay_between_spells
tt.nivus_sort_y_offset=-33
tt.magic_missiles={}
tt.magic_missiles.animation_in="missille"
tt.magic_missiles.animation_shoot="missille_shot"
tt.magic_missiles.animation_out="missille_out"
tt.magic_missiles.cooldown=b_nivus.magic_missiles.cooldown
tt.magic_missiles.min_range=b_nivus.magic_missiles.min_range
tt.magic_missiles.max_range=b_nivus.magic_missiles.max_range
tt.magic_missiles.vis_flags=bor(F_RANGED)
tt.magic_missiles.vis_bans=0
tt.magic_missiles.count=b_nivus.magic_missiles.count
tt.magic_missiles.bullet="bullet_nivus_magic_missiles"
tt.magic_missiles.bullet_start_offset=v(-12,27)
tt.magic_missiles.shoot_time=fts(2)
tt.magic_missiles.time_to_hit=fts(2)+2.5
tt.books={}
tt.books.bubble_t="decal_nivus_books_bubble"
tt.books.spawn_pos=v(530,598)
tt.books.min_range=b_nivus.books.min_range
tt.books.max_range=b_nivus.books.max_range
tt.books.vis_flags=0
tt.books.vis_bans=bor(F_FLYING)
tt.books.animation_charge="animate_call"
tt.books.animation_shoot="animate_shot"
tt.books.cast_time=fts(20)
tt.books.time_to_hit=fts(20)+fts(40)
tt.books.delay_between_books=1.5
tt.books.offsets={v(-40,50),v(0,70),v(40,50)}
tt.books.book_charge_t="decal_nivus_book_charge"
tt.books.book_charge_fx_t="fx_nivus_book_charge"
tt.books.bullet_t="bullet_nivus_book"
tt.books.squad_controller_t="controller_stage_206_nivus_books_squads"
tt.books.sound_cast="Stage06NivusSpawnBooksCast"
tt.disintegrate={}
tt.disintegrate.bubble_t="decal_nivus_disintegrate_bubble"
tt.disintegrate.spawn_pos=v(523,372)
tt.disintegrate.min_range=b_nivus.disintegrate.min_range
tt.disintegrate.max_range=b_nivus.disintegrate.max_range
tt.disintegrate.vis_flags=bor(F_INSTAKILL)
tt.disintegrate.vis_bans=bor(F_FLYING,F_BOSS)
tt.disintegrate.min_hp=b_nivus.disintegrate.min_hp
tt.disintegrate.max_hp=b_nivus.disintegrate.max_hp
tt.disintegrate.vanish_fx_t="fx_nivus_disintegrate"
tt.disintegrate.animation_out="desintegrate_out"
tt.disintegrate.animation_in="desintegrate_in"
tt.disintegrate.animation_cast="desintegrate"
tt.disintegrate.animation_back="desintegrate_back"
tt.disintegrate.mod_stun="mod_nivus_disintegrate_stun"
tt.disintegrate.cast_time=fts(13)
tt.disintegrate.time_to_hit=fts(88)
tt.disintegrate.sound_teleport="Stage06DisintegrateTeleportCast"
tt.disintegrate.sound_cast="Stage06DisintegrateCast"
tt.disintegrate.wait_sound_cast=fts(26)
tt.brooms={}
tt.brooms.bubble_t="decal_nivus_brooms_bubble"
tt.brooms.spawn_pos=v(470,511)
tt.brooms.min_range=0
tt.brooms.max_range=b_nivus.brooms.max_range
tt.brooms.vis_flags=bor(F_POLYMORPH)
tt.brooms.vis_bans=bor(F_BOSS)
tt.brooms.animation="polymorph"
tt.brooms.bullet_start_offset=v(15,35)
tt.brooms.cast_time=fts(28)
tt.brooms.min_nodes=b_nivus.brooms.min_nodes
tt.brooms.ray_t="bullet_nivus_brooms_long"
tt.brooms.magic_fx_t="fx_nivus_brooms_magic"
tt.bubble_offset=v(40,40)
tt.ui.click_rect=r(0,0,60,60)
tt=E:register_t_hot("controller_stage_206_nivus_books_squads",nil,true)
AC(tt,"main_script")
tt.books_t="soldier_nivus_book"
tt.main_script.update=controller_stage_206_nivus_books_squads_update
tt=E:register_t_hot("mod_nivus_disintegrate_stun","mod_stun",true)
tt.modifier.duration=1e+99
tt.modifier.vis_flags=bor(F_MOD,F_STUN)
tt.modifier.vis_bans=bor(F_BOSS)
tt.render.sprites[1].hidden=true
tt=E:register_t_hot("mod_nivus_brooms_polymorph","modifier",true)
tt.modifier.vis_flags=F_MOD
tt.modifier.duration=b_nivus.brooms.duration
tt.hp_mult=0.6
tt.main_script.insert=mod_nivus_brooms_polymorph_insert
tt.main_script.update=mod_nivus_brooms_polymorph_update
tt.main_script.remove=mod_nivus_brooms_polymorph_remove
tt.entity_t="enemy_nivus_broom"
tt.entity_t_flying="enemy_nivus_broom_flying"
tt.transform_fx="fx_nivus_brooms_magic"
self.manual_hero_insertion=false
end
function level:update(store)
P:add_invalid_range(2,90,110)
for i=1,3 do
P:add_invalid_range(i,P:get_end_node(i)-4,P:get_end_node(i))
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
log.debug("-- WON")
end
return level
