return function(map)
local new_level=map:new_level()
if map:level_completed(4) then
map:hide_exo("kr6_map_stage254_crane",true)
if new_level==5 then
map:play_exo_once("kr6_map_stage254_wall","run",{next_animation="idle_2"})
else
map:play_exo("kr6_map_stage254_wall","idle_2",true)
end
end
map:hide_exo("kr6_map_stage255_tree",not map:level_completed(5))
if map:level_completed(5) then
if new_level==6 then
map:play_exo_once("kr6_map_stage255_tree","run",{next_animation="idle"})
map:play_exo_once("kr6_map_stage255_light","off",{next_animation="idle_off"})
else
map:play_exo("kr6_map_stage255_tree","idle",true)
map:play_exo("kr6_map_stage255_light","idle_off",true)
end
end
if map:level_completed(8) then
map:hide_exo("kr6_map_stage258_templars",true)
if new_level==9 then
map:play_exo_once("kr6_map_stage258_wall","run",{next_animation="idle_2"})
else
map:play_exo("kr6_map_stage258_wall","idle_2",true)
end
end
map:hide_exo("kr6_map_stage260_jt",true)
if map:level_completed(9) then
if new_level==10 then
map:play_exo_once("kr6_map_stage260_mountain_wall","run",{on_finished=function()
map:hide_exo("kr6_map_stage260_mountain_wall",true)
map:hide_exo("kr6_map_stage260_jt",false)
end})
else
map:hide_exo("kr6_map_stage260_mountain_wall",true)
map:hide_exo("kr6_map_stage260_jt",false)
end
end
map:hide_exo("kr6_map_stage261_spider",true)
map:hide_exo("kr6_map_stage261_spider_eyes",true)
if map:level_completed(10) then
if new_level==11 then
map:play_exo_once("kr6_map_stage261_mountain_wall","run",{on_finished=function()
map:hide_exo("kr6_map_stage261_mountain_wall",true)
map:hide_exo("kr6_map_stage261_spider",false)
map:hide_exo("kr6_map_stage261_spider_eyes",false)
end})
else
map:hide_exo("kr6_map_stage261_mountain_wall",true)
map:hide_exo("kr6_map_stage261_spider",false)
map:hide_exo("kr6_map_stage261_spider_eyes",false)
end
end
map:hide_exo("kr6_map_stage262_torches",true)
if map:level_completed(11) and map:level_unlocked(12) then
if new_level==12 then
map:play_exo_once("kr6_map_stage262_mountain_wall","run",{on_finished=function()
map:hide_exo("kr6_map_stage262_mountain_wall",true)
end})
map:hide_exo("kr6_map_stage262_torches",false)
else
map:hide_exo("kr6_map_stage262_mountain_wall",true)
map:hide_exo("kr6_map_stage262_torches",false)
map:play_exo("kr6_map_stage262_torches","run",true)
end
end
map:hide_exo("kr6_map_stage263_sunray_tower",not map:level_completed(13))
if map:level_completed(15) then
if new_level==16 then
map:play_exo_once("kr6_map_stage265_swamp","start",{next_animation="loop"})
else
map:play_exo("kr6_map_stage265_swamp","loop",true)
end
end
map:hide_exo("kr6_map_stage266_rotten_forest",not map:level_completed(16))
if map:level_completed(16) then
if new_level==17 then
map:play_exo_once("kr6_map_stage266_rotten_forest","start",{next_animation="idle"})
else
map:play_exo("kr6_map_stage266_rotten_forest","idle",true)
end
end
if map:level_completed(18) then
map:play_exo("kr6_map_stage268_tower","idle_2",true)
end
end
