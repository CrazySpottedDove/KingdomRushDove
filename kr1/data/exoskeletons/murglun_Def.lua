return {fps=30,partScaleCompensation=1,animations={{name="idle",frames=(function()
local frames={}
local totalFrames=150
local sx,sy=1.0,0.6
local maxAngle=5
local maxShear=0.1
for i=0,totalFrames-1 do
local t=i/totalFrames
local angle=math.sin(t*2*math.pi)*maxAngle
local shear=math.sin(t*4*math.pi)*maxShear
table.insert(frames,{parts={{name="hero_murglun_heat_wave_decal",xform={x=0,y=0,r=angle,sx=sx,sy=sy,kx=0,ky=shear,}}}})
end
return frames
end)()}},parts={hero_murglun_heat_wave_decal={offsetY=0,name="hero_murglun_heat_wave_decal",offsetX=0,}}}
