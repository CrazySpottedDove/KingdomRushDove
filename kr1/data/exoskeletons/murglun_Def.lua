-- chunkname: @./kr5/data/exoskeletons/back_maskDef.lua

return {
	fps = 30,
	partScaleCompensation = 1,
	animations = {
		{
    name = "idle",
    frames = (function()
        local frames = {}
        local totalFrames = 150         -- 1秒 @30fps
        local sx, sy = 1.0, 0.6        -- 固定椭圆比例
        local maxAngle = 5             -- 最大旋转角度（度），±5°内摆动
        local maxShear = 0.1           -- 最大剪切系数，制造流动感
        for i=0,totalFrames-1 do
            local t = i / totalFrames
            -- 用正弦函数平滑循环
            local angle = math.sin(t * 2 * math.pi) * maxAngle
            local shear = math.sin(t * 4 * math.pi) * maxShear
            table.insert(frames, {
                parts = {
                    {
                        name = "hero_murglun_heat_wave_decal", -- 改成你的部件名
                        xform = {
                            x = 0,
                            y = 0,
                            r = angle,  -- 轻微角度摆动
                            sx = sx,
                            sy = sy,
                            kx = 0,
                            ky = shear, -- 剪切带来的流动
                        }
                    }
                }
            })
        end
        return frames
    end)()
}

	},
	
	parts = {
		hero_murglun_heat_wave_decal = {
			offsetY = 0,--241.4,
			name = "hero_murglun_heat_wave_decal",
			offsetX = 0,--309.75
		}
	}
}
