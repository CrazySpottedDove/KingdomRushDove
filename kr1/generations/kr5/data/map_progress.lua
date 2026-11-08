return function(map)
local new_level=map:new_level()
map:hide_exo("map_deco_sword",map:level_unlocked(7))
if map:level_unlocked(12) then
map:hide_exo("decos_map_clouds",new_level~=12)
map:hide_exo("decos_map_thunder",true)
else
map:hide_exo("decos_map_clouds",false)
map:hide_exo("decos_map_thunder",false)
end
if map:level_unlocked(16) then
map:play_exo("decos_map_overseer","loop_active",true)
end
if new_level==12 then
map:after(1,function()
map:play_exo("decos_map_clouds","out",false)
end)
end
end
