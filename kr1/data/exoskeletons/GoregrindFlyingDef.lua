-- chunkname: @./kr5/data/exoskeletons/GoregrindFlyingDef.lua

return {
	fps = 30,
	partScaleCompensation = 1,
	animations = {
		{
			name = "idle",
			frames = {
				{
					parts = {
						{
							name = "GoregrindFlying_asst_goregrind_flying",
							xform = {
								kx = 0,
								sx = 1,
								r = 0,
								ky = 0,
								sy = 1,
								y = -27,
								x = -4
							}
						}
					}
				}
			}
		}
	},
	parts = {
		GoregrindFlying_asst_goregrind_flying = {
			offsetY = -1.8,
			name = "GoregrindFlying_asst_goregrind_flying",
			offsetX = -1.25
		}
	}
}
