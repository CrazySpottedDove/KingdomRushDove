local bit = require("bit")
local bor = bit.bor
local band = bit.band
local bnot = bit.bnot
local E = require("entity_db")
local i18n = require("i18n")

require("constants")

local anchor_y = 0
local image_x = 0
local image_y, tt
local scripts = require("game_scripts")

require("templates")

local IS_PHONE = KR_TARGET == "phone"
local IS_PHONE_OR_TABLET = KR_TARGET == "phone" or KR_TARGET == "tablet"
local IS_CONSOLE = KR_TARGET == "console"

local function v(v1, v2)
	return {
		x = v1,
		y = v2
	}
end

local function vv(v1)
	return {
		x = v1,
		y = v1
	}
end

local function r(x, y, w, h)
	return {
		pos = v(x, y),
		size = v(w, h)
	}
end

local function fts(v)
	return v / FPS
end

local function adx(v)
	return v - anchor_x * image_x
end

local function ady(v)
	return v - anchor_y * image_y
end

local function np(pi, spi, ni)
	return {
		dir = 1,
		pi = pi,
		spi = spi,
		ni = ni
	}
end

local function d2r(d)
	return d * math.pi / 180
end

local function RT(name, ref)
	return E:register_t(name, ref)
end

local function AC(tpl, ...)
	return E:add_comps(tpl, ...)
end

local function CC(comp_name)
	return E:clone_c(comp_name)
end

-------------------------------------------

tt = RT("tower_holder")

AC(tt, "tower", "tower_holder", "pos", "render", "ui", "editor", "editor_script")

tt.ui.click_rect = r(-40, -12, 80, 46)
tt.ui.has_nav_mesh = true
tt.tower.level = 1
tt.tower.type = "holder"
tt.tower.can_be_mod = false
tt.tower_holder.preview_ids = {
	archer = 2,
	engineer = 5,
	barrack = 3,
	mage = 4
}
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "build_terrain_%04i"
tt.render.sprites[1].offset = v(0, 17)
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "tower_preview_archer"
tt.render.sprites[2].animated = false
tt.render.sprites[2].hidden = true
tt.render.sprites[2].offset = v(0, 37)
tt.render.sprites[2].alpha = 180
tt.render.sprites[3] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[3].name = "tower_preview_barrack"
tt.render.sprites[3].offset = v(0, 38)
tt.render.sprites[4] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[4].name = "tower_preview_mage"
tt.render.sprites[4].offset = v(0, 30)
tt.render.sprites[5] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[5].name = "tower_preview_artillery"
tt.render.sprites[5].offset = v(0, 41)
tt.editor.props = {
	{
		"tower.terrain_style",
		PT_NUMBER
	},
	{
		"tower.default_rally_pos",
		PT_COORDS
	},
	{
		"tower.holder_id",
		PT_STRING
	},
	{
		"ui.nav_mesh_id",
		PT_STRING
	},
	{
		"editor.game_mode",
		PT_NUMBER
	}
}
tt.editor_script.insert = scripts.editor_tower.insert
tt.editor_script.remove = scripts.editor_tower.remove
tt = RT("tower_holder_grass", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_GRASS
tt.render.sprites[1].name = "build_terrain_0001"
tt = RT("tower_holder_snow", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_SNOW
tt.render.sprites[1].name = "build_terrain_0002"
tt = RT("tower_holder_wasteland", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_WASTELAND
tt.render.sprites[1].name = "build_terrain_0003"
tt = RT("tower_holder_blackburn", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_BLACKBURN
tt.render.sprites[1].name = "build_terrain_0008"
tt = RT("tower_build_archer", "tower_build")
tt.build_name = "tower_archer_1"
tt.render.sprites[2].name = "tower_constructing_0004"
tt.render.sprites[2].offset = v(0, 39)
tt = RT("tower_build_barrack", "tower_build_archer")
tt.build_name = "tower_barrack_1"
tt.render.sprites[2].name = "tower_constructing_0002"
tt.render.sprites[2].offset = v(0, 40)
tt = RT("tower_build_mage", "tower_build_archer")
tt.build_name = "tower_mage_1"
tt.render.sprites[2].name = "tower_constructing_0003"
tt.render.sprites[2].offset = v(0, 31)
tt = RT("tower_build_engineer", "tower_build_archer")
tt.build_name = "tower_engineer_1"
tt.render.sprites[2].name = "tower_constructing_0001"
tt.render.sprites[2].offset = v(0, 41)
tt = RT("tower_mage_1", "tower")

AC(tt, "attacks")

tt.tower.type = "mage"
tt.tower.level = 1
tt.tower.price = 100
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_towers_0003" or "info_portraits_towers_0010"
tt.info.enc_icon = 3
tt.info.fn = scripts.tower_mage.get_info
tt.main_script.insert = scripts.tower_mage.insert
tt.main_script.update = scripts.tower_mage.update
tt.attacks.range = 140
tt.attacks.list[1] = CC("bullet_attack")
tt.attacks.list[1].animation = "shoot"
tt.attacks.list[1].bullet = "bolt_1"
tt.attacks.list[1].cooldown = 1.5
tt.attacks.list[1].shoot_time = fts(8)
tt.attacks.list[1].bullet_start_offset = {
	v(8, 66),
	v(-5, 62)
}
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_mage_%04i"
tt.render.sprites[1].offset = v(0, 15)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "towermagelvl1"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].offset = v(0, 30)
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].prefix = "shootermage"
tt.render.sprites[3].name = "idleDown"
tt.render.sprites[3].angles = {
	idle = {
		"idleUp",
		"idleDown"
	},
	shoot = {
		"shootingUp",
		"shootingDown"
	}
}
tt.render.sprites[3].offset = v(1, 57)
tt.render.sid_tower = 2
tt.render.sid_shooter = 3
tt.sound_events.insert = "MageTaunt"
tt = RT("tower_mage_2", "tower_mage_1")
tt.info.enc_icon = 7
tt.tower.level = 2
tt.tower.price = 160
tt.attacks.range = 160
tt.attacks.list[1].bullet = "bolt_2"
tt.attacks.list[1].bullet_start_offset = {
	v(8, 66),
	v(-5, 64)
}
tt.render.sprites[2].prefix = "towermagelvl2"
tt.render.sprites[3].offset = v(1, 57)
tt = RT("tower_mage_3", "tower_mage_1")
tt.info.enc_icon = 11
tt.tower.level = 3
tt.tower.price = 240
tt.attacks.range = 180
tt.attacks.list[1].bullet = "bolt_3"
tt.attacks.list[1].bullet_start_offset = {
	v(8, 70),
	v(-5, 69)
}
tt.render.sprites[2].prefix = "towermagelvl3"
tt.render.sprites[3].offset = v(1, 62)
tt = RT("tower_engineer_1", "tower")

AC(tt, "attacks")

tt.tower.type = "engineer"
tt.tower.level = 1
tt.tower.price = 125
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_towers_0004" or "info_portraits_towers_0003"
tt.info.enc_icon = 4
tt.main_script.insert = scripts.tower_engineer.insert
tt.main_script.update = scripts.tower_engineer.update
tt.attacks.range = 160
tt.attacks.list[1] = CC("bullet_attack")
tt.attacks.list[1].bullet = "bomb"
tt.attacks.list[1].cooldown = 3
tt.attacks.list[1].shoot_time = fts(12)
tt.attacks.list[1].vis_bans = bor(F_FLYING)
tt.attacks.list[1].bullet_start_offset = v(0, 50)
tt.attacks.list[1].node_prediction = true
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_artillery_%04i"
tt.render.sprites[1].offset = v(0, 15)

for i = 2, 8 do
	tt.render.sprites[i] = CC("sprite")
	tt.render.sprites[i].prefix = "towerengineerlvl1_layer" .. i - 1
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].offset = v(0, 41)
end

tt.sound_events.insert = "EngineerTaunt"
tt = RT("tower_engineer_2", "tower_engineer_1")
tt.info.enc_icon = 8
tt.tower.level = 2
tt.tower.price = 220
tt.attacks.list[1].bullet = "bomb_dynamite"
tt.attacks.list[1].cooldown = 3
tt.attacks.list[1].shoot_time = fts(12)
tt.attacks.list[1].bullet_start_offset = v(0, 53)

for i = 2, 8 do
	tt.render.sprites[i] = CC("sprite")
	tt.render.sprites[i].prefix = "towerengineerlvl2_layer" .. i - 1
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].offset = v(0, 42)
end

tt = RT("tower_engineer_3", "tower_engineer_1")
tt.info.enc_icon = 12
tt.tower.level = 3
tt.tower.price = 320
tt.attacks.range = 179.20000000000002
tt.attacks.list[1].bullet = "bomb_black"
tt.attacks.list[1].cooldown = 3
tt.attacks.list[1].shoot_time = fts(12)
tt.attacks.list[1].bullet_start_offset = v(0, 57)

for i = 2, 8 do
	tt.render.sprites[i] = CC("sprite")
	tt.render.sprites[i].prefix = "towerengineerlvl3_layer" .. i - 1
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].offset = v(0, 43)
end

tt = RT("tower_archer_1", "tower")

AC(tt, "attacks")

tt.tower.type = "archer"
tt.tower.level = 1
tt.tower.price = 70
tt.info.portrait = (IS_PHONE_OR_TABLET and "portraits_towers_" or "info_portraits_towers_") .. "0001"
tt.info.enc_icon = 1
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_archer_%04i"
tt.render.sprites[1].offset = v(0, 12)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "archer_tower_0001"
tt.render.sprites[2].offset = v(0, 37)
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].prefix = "shooterarcherlvl1"
tt.render.sprites[3].name = "idleDown"
tt.render.sprites[3].angles = {
	idle = {
		"idleUp",
		"idleDown"
	},
	shoot = {
		"shootingUp",
		"shootingDown"
	}
}
tt.render.sprites[3].offset = v(-9, 51)
tt.render.sprites[4] = CC("sprite")
tt.render.sprites[4].prefix = "shooterarcherlvl1"
tt.render.sprites[4].name = "idleDown"
tt.render.sprites[4].angles = {
	idle = {
		"idleUp",
		"idleDown"
	},
	shoot = {
		"shootingUp",
		"shootingDown"
	}
}
tt.render.sprites[4].offset = v(9, 51)
tt.main_script.insert = scripts.tower_archer.insert
tt.main_script.update = scripts.tower_archer.update
tt.main_script.remove = scripts.tower_archer.remove
tt.attacks.range = 140
tt.attacks.list[1] = CC("bullet_attack")
tt.attacks.list[1].bullet = "arrow_1"
tt.attacks.list[1].cooldown = 0.8
tt.attacks.list[1].shoot_time = fts(5)
tt.attacks.list[1].bullet_start_offset = {
	v(-10, 50),
	v(10, 50)
}
tt.sound_events.insert = "ArcherTaunt"
tt = RT("tower_archer_2", "tower_archer_1")
tt.info.enc_icon = 5
tt.tower.level = 2
tt.tower.price = 110
tt.render.sprites[2].name = "archer_tower_0002"
tt.render.sprites[3].prefix = "shooterarcherlvl2"
tt.render.sprites[3].offset = v(-9, 52)
tt.render.sprites[4].prefix = "shooterarcherlvl2"
tt.render.sprites[4].offset = v(9, 52)
tt.attacks.range = 160
tt.attacks.list[1].bullet = "arrow_2"
tt.attacks.list[1].cooldown = 0.6
tt = RT("tower_archer_3", "tower_archer_1")
tt.info.enc_icon = 9
tt.tower.level = 3
tt.tower.price = 160
tt.render.sprites[2].name = "archer_tower_0003"
tt.render.sprites[3].prefix = "shooterarcherlvl3"
tt.render.sprites[3].offset = v(-9, 57)
tt.render.sprites[4].prefix = "shooterarcherlvl3"
tt.render.sprites[4].offset = v(9, 57)
tt.attacks.range = 180
tt.attacks.list[1].bullet = "arrow_3"
tt.attacks.list[1].cooldown = 0.5
tt = RT("tower_barrack_1", "tower")

AC(tt, "barrack")

tt.tower.type = "barrack"
tt.tower.level = 1
tt.tower.price = 70
tt.info.fn = scripts.tower_barrack.get_info
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_towers_0002" or "info_portraits_towers_0007"
tt.info.enc_icon = 2
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_barrack_%04i"
tt.render.sprites[1].offset = v(0, 13)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "tower_barracks_lvl1_layer1_0001"
tt.render.sprites[2].offset = v(0, 38)
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].prefix = "towerbarracklvl1_door"
tt.render.sprites[3].name = "close"
tt.render.sprites[3].loop = false
tt.render.sprites[3].offset = v(0, 38)
tt.barrack.soldier_type = "soldier_militia"
tt.barrack.rally_range = 145
tt.barrack.respawn_offset = v(0, 0)
tt.main_script.insert = scripts.tower_barrack.insert
tt.main_script.update = scripts.tower_barrack.update
tt.main_script.remove = scripts.tower_barrack.remove
tt.sound_events.insert = "BarrackTaunt"
tt.sound_events.change_rally_point = "BarrackTaunt"
tt = RT("tower_barrack_2", "tower_barrack_1")
tt.info.enc_icon = 6
tt.tower.level = 2
tt.tower.price = 110
tt.render.sprites[2].name = "tower_barracks_lvl2_layer1_0001"
tt.render.sprites[3].prefix = "towerbarracklvl2_door"
tt.barrack.soldier_type = "soldier_footmen"
tt.barrack.rally_range = 150
tt = RT("tower_barrack_3", "tower_barrack_1")
tt.info.enc_icon = 10
tt.tower.level = 3
tt.tower.price = 150
tt.render.sprites[2].name = "tower_barracks_lvl3_layer1_0001"
tt.render.sprites[3].prefix = "towerbarracklvl3_door"
tt.barrack.soldier_type = "soldier_knight"
tt.barrack.rally_range = 155