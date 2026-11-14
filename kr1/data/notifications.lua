return {
	TIP_ARMOR = {
		paper = "notifications_tips_slides_notxt_0001",
		always = true,
		ach_flag = 1,
		icon = "alert_tip_notxt_0002",
		layout = N_TIP
	},
	TIP_RALLY = {
		paper = "notifications_tips_slides_notxt_0003",
		always = true,
		ach_flag = 2,
		icon = "alert_tip_notxt_0001",
		layout = N_TIP
	},
	TIP_ARMOR_MAGIC = {
		paper = "notifications_tips_slides_notxt_0002",
		always = true,
		ach_flag = 4,
		icon = "alert_tip_notxt_0003",
		layout = N_TIP
	},
	TIP_STRATEGY = {
		paper = "notifications_tips_slides_notxt_0004",
		always = true,
		ach_flag = 8,
		icon = "alert_tip_notxt_0004",
		layout = N_TIP
	},
	TIP_ARMOR_HARD = {
		paper = "notifications_tips_slides_notxt_0005",
		always = true,
		ach_flag = 4,
		icon = "alert_tip_notxt_0005",
		layout = N_TIP
	},
	TIP_HEROES = {
		icon = "alert_tip_notxt_0006",
		paper = "notifications_tips_slides_notxt_0007",
		always = true,
		layout = N_TIP
	},
	TIP_UPGRADES = {
		icon = "alert_tip_notxt_0005",
		paper = "notifications_tips_slides_notxt_0006",
		layout = N_TIP
	},
	TIP_ELITE = {
		icon = "alert_tip_notxt_0005",
		paper = "notifications_tips_slides_notxt_0008",
		layout = N_TIP
	},
	POWER_FIREBALL = {
		prefix = "POWER_FIREBALL",
		always = true,
		image = "tutorial_powers_polaroids_0002",
		layout = N_POWER,
		signals = {{"show-balloon", "TB_POWER1"}, {"unlock-user-power", 1}}
	},
	POWER_REINFORCEMENT = {
		prefix = "POWER_REINFORCEMENTS",
		always = true,
		image = "tutorial_powers_polaroids_0001",
		layout = N_POWER,
		signals = {{"show-balloon", "TB_POWER2"}, {"unlock-user-power", 2}}
	},
	TUTORIAL_1 = {
		next = "TUTORIAL_2",
		paper = "tutorial_slide1_notxt",
		always = true,
		layout = N_TUTORIAL
	},
	TUTORIAL_2 = {
		next = "TUTORIAL_3",
		paper = "tutorial_slide2_notxt",
		always = true,
		layout = N_TUTORIAL
	},
	TUTORIAL_3 = {
		always = true,
		paper = "tutorial_slide3_notxt",
		layout = N_TUTORIAL
	}
}
