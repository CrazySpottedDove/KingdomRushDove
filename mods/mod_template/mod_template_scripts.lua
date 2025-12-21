local log = require("klua.log"):new("mod_template_scripts")
local scripts = require("scripts")
local S = require("sound_db")
local P = require("path_db")
local UP = require("upgrades")
local scripts = require("scripts")
local mod_utils = require("mod_utils")
local v = V.v
local vv = V.vv

-- 这里可以覆盖函数，示例：
-- function scripts.hero_alleria.update(this, store)
-- 	函数体
-- end
-- --
-- 注修改后需要在模板内重新引用该函数
-- T("hero_alleria").main_script.update = scripts.hero_alleria.update