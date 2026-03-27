local SystemsTowerUpgrade = require("systems.tower_upgrade")
local SystemsGameUpgrades = require("systems.game_upgrades")
local SystemsMainScript = require("systems.main_script")
local SystemsHealth = require("systems.health")
local SystemsCountGroups = require("systems.count_groups")
local SystemsHeroXpTracking = require("systems.hero_xp_tracking")
local SystemsPops = require("systems.pops")
local SystemsTimed = require("systems.timed")
local SystemsTexts = require("systems.texts")
local SystemsSoundEvents = require("systems.sound_events")
local SystemsSeenTracker = require("systems.seen_tracker")
local SystemsEvents = require("systems.events")
local SystemsWaveSpawnTsv = require("systems.wave_spawn_tsv")
local SystemsWaveSpawn = require("systems.wave_spawn")
local SystemsModLifecycle = require("systems.mod_lifecycle")
local SystemsGoalLine = require("systems.goal_line")
local SystemsParticleSystemInit = require("systems.particle_system_init")
local SystemsParticleSystemLifecycle = require("systems.particle_system_lifecycle")
local SystemsParticleSystemUpdate = require("systems.particle_system_update")
local SystemsEditorOverrides = require("systems.editor_overrides")
local SystemsEditorScript = require("systems.editor_script")
local SystemsSpatialIndex = require("systems.spatial_index")
local SystemsLastHook = require("systems.last_hook")
local SystemsLights = require("systems.lights")
local SystemsAssetsChecker = require("systems.assets_checker")
local SystemsEndless = require("systems.endless")
local SystemsTowerSkill = require("systems.tower_skill")
local SystemsWaveGenerator = require("systems.wave_generator")

local M = {}

function M.register_extracted(sys, deps)
	SystemsTowerUpgrade.register(sys, {
		E = deps.E,
		V = deps.V,
		U = deps.U,
		S = deps.S,
		km = deps.km,
		signal = deps.signal,
		perf = deps.perf,
		queue_insert = deps.queue_insert,
		queue_remove = deps.queue_remove
	})

	SystemsGameUpgrades.register(sys, {
		E = deps.E,
		UP = deps.UP,
		km = deps.km,
		ceil = deps.ceil
	})

	SystemsMainScript.register(sys, {
		perf = deps.perf,
		log = deps.log
	})

	SystemsHealth.register(sys, {
		perf = deps.perf,
		band = deps.band,
		bor = deps.bor,
		U = deps.U,
		SU = deps.SU,
		signal = deps.signal,
		E = deps.E,
		queue_remove = deps.queue_remove
	})

	SystemsCountGroups.register(sys, {
		km = deps.km,
		signal = deps.signal
	})

	SystemsHeroXpTracking.register(sys, {
		perf = deps.perf
	})

	SystemsPops.register(sys, {
		perf = deps.perf,
		random = deps.random,
		band = deps.band,
		E = deps.E,
		V = deps.V,
		PI = deps.PI,
		queue_insert = deps.queue_insert
	})

	SystemsTimed.register(sys, {
		perf = deps.perf,
		queue_remove = deps.queue_remove
	})

	SystemsTexts.register(sys, {
		F = deps.F,
		I = deps.I
	})

	SystemsSoundEvents.register(sys, {
		S = deps.S
	})

	SystemsSeenTracker.register(sys, {
		storage = deps.storage,
		U = deps.U,
		perf = deps.perf
	})

	SystemsEvents.register(sys, {})

	SystemsWaveSpawnTsv.register(sys, {
		W = deps.W,
		U = deps.U,
		E = deps.E,
		P = deps.P,
		LU = deps.LU,
		km = deps.km,
		GS = deps.GS,
		signal = deps.signal,
		log = deps.log,
		queue_insert = deps.queue_insert,
		fts = deps.fts
	})

	SystemsWaveSpawn.register(sys, {
		W = deps.W,
		U = deps.U,
		E = deps.E,
		P = deps.P,
		LU = deps.LU,
		DI = deps.DI,
		km = deps.km,
		GS = deps.GS,
		signal = deps.signal,
		log = deps.log,
		perf = deps.perf,
		queue_insert = deps.queue_insert,
		fts = deps.fts,
		random = deps.random,
		ceil = deps.ceil
	})

	SystemsModLifecycle.register(sys, {
		queue_remove = deps.queue_remove
	})

	SystemsGoalLine.register(sys, {
		perf = deps.perf,
		P = deps.P,
		signal = deps.signal,
		km = deps.km,
		queue_remove = deps.queue_remove
	})

	SystemsParticleSystemInit.register(sys, {
		floor = deps.floor
	})

	SystemsParticleSystemLifecycle.register(sys, {})

	SystemsParticleSystemUpdate.register(sys, {
		perf = deps.perf,
		ffi = deps.ffi,
		random = deps.random,
		cos = deps.cos,
		sin = deps.sin,
		floor = deps.floor,
		km = deps.km,
		A = deps.A,
		I = deps.I,
		queue_remove = deps.queue_remove
	})

	SystemsEditorOverrides.register(sys, {
		E = deps.E,
		LU = deps.LU
	})

	SystemsEditorScript.register(sys, {
		E = deps.E,
		perf = deps.perf,
		log = deps.log
	})

	SystemsSpatialIndex.register(sys, {
		perf = deps.perf
	})

	SystemsLastHook.register(sys, {
		log = deps.log
	})

	SystemsLights.register(sys, {
		perf = deps.perf
	})

	SystemsAssetsChecker.register(sys, {
		ASSETS_CHECK_ENABLED = deps.ASSETS_CHECK_ENABLED,
		E = deps.E,
		I = deps.I,
		log = deps.log
	})

	SystemsEndless.register(sys, {
		U = deps.U,
		SU = deps.SU,
		ceil = deps.ceil
	})

	SystemsTowerSkill.register(sys, {
		perf = deps.perf
	})

	SystemsWaveGenerator.register(sys, {
		E = deps.E
	})
end

return M
