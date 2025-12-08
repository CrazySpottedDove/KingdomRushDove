local V=require("lib.klua.vector")
local level={}
function level:fn_can_power(store,power_id,pos)
return V.is_inside(pos,V.r(127,483,130,90))
end
return level
