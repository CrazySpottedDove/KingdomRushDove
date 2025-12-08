-- chunkname: @./kr5/data/exoskeletons/tower_tree_projectileDef.lua

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
							name = "tower_tree_projectile_asst_projectile",
							xform = {
								kx = 0,
								sx = 1,
								r = 0,
								ky = 0,
								sy = 1,
								y = -2.95,
								x = 0.15
							}
						}
					}
				}
			}
		}
	},
	parts = {
		tower_tree_projectile_asst_projectile = {
			offsetY = 2.95,
			name = "tower_tree_projectile_asst_projectile",
			offsetX = -0.15
		}
	}
}
