-- chunkname: @./kr5/data/exoskeletons/spawner_mausoleumDef.lua

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
							name = "spawner_mausoleum_asst_mausoleo",
							xform = {
								kx = 0,
								sx = 1,
								r = 0,
								ky = 0,
								sy = 1,
								y = -21.9,
								x = 0.95
							}
						}
					}
				}
			}
		}
	},
	parts = {
		spawner_mausoleum_asst_mausoleo = {
			offsetY = 0,
			name = "spawner_mausoleum_asst_mausoleo",
			offsetX = 0
		}
	}
}
