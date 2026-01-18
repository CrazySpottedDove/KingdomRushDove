-- chunkname: @./_assets/kr5-desktop/images/ipadhd_bc3/go_stage31_bg.lua

local a = {
	Stage31_0001 = {
		a_name = "go_stage131_bg-1.dds",
		size = {
			2800,
			1536
		},
		trim = {
			0,
			0,
			0,
			0
		},
		a_size = {
			2800,
			1536
		},
		f_quad = {
			0,
			0,
			2800,
			1536
		},
		alias = {}
	},
	stage_31_mask_burned_01 = {
		a_name = "go_stage131_masks-1.dds",
		size = {
			2800,
			1536
		},
		trim = {
			1844,
			0,
			0,
			0
		},
		a_size = {
			1844,
			3896
		},
		f_quad = {
			6,
			1331,
			956,
			1536
		},
		alias = {}
	},
	stage_31_mask_burned_02 = {
		a_name = "go_stage131_masks-1.dds",
		size = {
			2800,
			1536
		},
		trim = {
			674,
			0,
			500,
			931
		},
		a_size = {
			1844,
			3896
		},
		f_quad = {
			6,
			720,
			1626,
			605
		},
		alias = {}
	},
	stage_31_mask_burned_03 = {
		a_name = "go_stage131_masks-1.dds",
		size = {
			2800,
			1536
		},
		trim = {
			564,
			828,
			398,
			0
		},
		a_size = {
			1844,
			3896
		},
		f_quad = {
			6,
			6,
			1838,
			708
		},
		alias = {}
	},
}

for k, v in pairs(a) do
	local rate = 1080 / 1536
	a[k]["size"][1] = math.ceil(a[k]["size"][1]*rate)
	a[k]["size"][2] = math.ceil(a[k]["size"][2]*rate)

	a[k]["trim"][1] = math.ceil(a[k]["trim"][1]*rate)
	a[k]["trim"][2] = math.ceil(a[k]["trim"][2]*rate)
	a[k]["trim"][3] = math.ceil(a[k]["trim"][3]*rate)
	a[k]["trim"][4] = math.ceil(a[k]["trim"][4]*rate)

	a[k]["a_size"][1] = math.ceil(a[k]["a_size"][1]*rate)
	a[k]["a_size"][2] = math.ceil(a[k]["a_size"][2]*rate)

	a[k]["f_quad"][1] = math.ceil(a[k]["f_quad"][1]*rate)
	a[k]["f_quad"][2] = math.ceil(a[k]["f_quad"][2]*rate)
	a[k]["f_quad"][3] = math.ceil(a[k]["f_quad"][3]*rate)
	a[k]["f_quad"][4] = math.ceil(a[k]["f_quad"][4]*rate)
end 

return a