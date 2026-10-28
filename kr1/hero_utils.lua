-- chunkname: @./kr1/hero_utils.lua
-- 英雄脚本共享工具。hero_scripts.lua 与各英雄模块（含插件）共用这一份实现。
local km = require("lib.klua.macros")
local E = require("entity_db")
local GR = require("grid_db")
local GS = require("kr1.game_settings")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")

local bit = require("bit")
local bor = bit.bor

local HU = {}

--- 创建大招控制器实体并结算 XP
---@param this table 英雄
---@param store table
---@param pos table 目标位置
---@param animation_name string|nil 释放动画
function HU.apply_ultimate(this, store, pos, animation_name)
	if animation_name then
		U.y_animation_play(this, animation_name, nil, store.tick_ts, 1)
	end

	S:queue(this.sound_events.change_rally_point)

	local e = E:create_entity(this.hero.skills.ultimate.controller_name)

	e.pos:copy(pos)
	e.damage_factor = this.unit.damage_factor
	e.level = this.hero.skills.ultimate.level

	simulation:queue_insert_entity(e)

	this.ultimate.ts = store.tick_ts

	SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
end

--- 按英雄等级解锁技能并执行技能内的数值配置
---@param this table 英雄
---@param skill_name string 技能名
---@param upgrade_func function(this, skill)
function HU.upgrade_skill(this, skill_name, upgrade_func)
	local s = this.hero.skills[skill_name]
	local sl = s.xp_level_steps[this.hero.level]

	if sl then
		s.level = sl

		upgrade_func(this, s)
	end
end

--- 判断技能/攻击是否可用
---@param skill_attack table 攻击或技能
---@param store table game.store
---@param factor number|nil 冷却系数
---@return boolean
function HU.ready_to_use_skill(skill_attack, store, factor)
	return (not skill_attack.disabled) and (store.tick_ts - skill_attack.ts > skill_attack.cooldown * (factor or 1))
end

function HU.update_regen(this)
	this.regen.health = math.ceil(this.health.hp_max * GS.soldier_regen_factor)
end

function HU.inc_armor_by_skill(this, amount)
	this.health.raw_armor = this.health.raw_armor + amount
	this.health.armor = km.clamp(0, 1, this.health.armor + amount)
end

function HU.inc_magic_armor_by_skill(this, amount)
	this.health.raw_magic_armor = this.health.raw_magic_armor + amount
	this.health.magic_armor = km.clamp(0, 1, this.health.magic_armor + amount)
end

function HU.update_hp(this)
	if not this.health.hp then
		this.health.hp = this.health.hp_max
	else
		U.heal(this, this.health.hp_max)
	end
end

--- 升级基础属性
---@param this table 实体
---@return number, table 英雄等级 hl, 英雄等级属性表 ls
function HU.level_up_basic(this)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]

	HU.update_regen(this)

	this.health.raw_armor = ls.armor[hl]

	SU.update_armor(this)

	if ls.magic_armor then
		this.health.raw_magic_armor = ls.magic_armor[hl]

		SU.update_magic_armor(this)
	end

	return hl, ls
end

--- ultimate 索敌。默认在敌人数量较多时或者有血量比较高的敌人时返回有效的 target。返回敌人和敌人数量。
---@param this table
---@param range number
---@param vis_flags number
---@param vis_bans number
---@param filter function|nil
---@param ignore_bigguy boolean|nil
---@param require_foremost boolean|nil
---@return table, number
function HU.find_target_at_critical_moment(this, range, vis_flags, vis_bans, filter, ignore_bigguy, require_foremost)
	local target, targets

	if filter then
		target, targets = U.find_foremost_enemy_in_range_filter_on(this.pos, range, nil, vis_flags, vis_bans, filter)
	else
		target, targets = U.find_foremost_enemy_in_range_filter_off(this.pos, range, nil, vis_flags, vis_bans)
	end

	target = nil

	local num = 0

	if targets then
		num = #targets

		if not ignore_bigguy then
			for _, t in ipairs(targets) do
				if t.health and t.health.hp > BIG_ENEMY_HP then
					return t, num
				end
			end
		end

		if num > MANY_ENEMY_COUNT then
			if require_foremost then
				target = targets[1]
			else
				target = targets[math.random(1, #targets)]
			end
		end
	end

	return target, num
end

function HU.valid_land_node_nearby(pos)
	return not GR:cell_is(pos.x, pos.y, TERRAIN_FAERIE) and P:valid_node_nearby(pos.x, pos.y, 1.4285714285714286) and not GR:cell_is(pos.x, pos.y, TERRAIN_WATER)
end

function HU.valid_twister_node_nearby(pos)
	return P:valid_node_nearby(pos.x, pos.y, nil, NF_TWISTER) and GR:cell_is_only(pos.x, pos.y, bor(TERRAIN_LAND, TERRAIN_ICE))
end

return HU
