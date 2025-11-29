-- chunkname: @./all/platform_services_gamecenter.lua

require("lib.klua.string")

local log = require("lib.klua.log"):new("platform_services_gamecenter")
local PSU = require("platform_services_utils")
local signal = require("hump.signal")
local gamecenter = {}

gamecenter.can_be_paused = false
gamecenter.update_interval = 2
gamecenter.signal_handlers = {
	achievements = {
		["got-achievement"] = function(ach_id)
			gamecenter:unlock_achievement(ach_id)
		end
	},
	leaderboards = {
		["game-defeat"] = function(store)
			if store.level_mode == GAME_MODE_ENDLESS then
				gamecenter:submit_score(store.level_idx, store.level_difficulty, store.player_score)
			end
		end
	}
}
gamecenter.lib = nil
gamecenter.inited = false

local ffi = require("ffi")

ffi.cdef("bool  gkw_initialize(void);\nvoid  gkw_shutdown(void);\nint   gkw_get_status(void);\nint   gkw_get_request_status(int rid);\nvoid  gkw_delete_request(int rid);\nbool  gkw_ach_unlock(const char* name);\nbool  gkw_ach_reset_all(void);\nconst char* gkw_ach_get_cached(void);\nint   gkw_create_request_ach_sync(void);\nvoid  gkw_ach_show(void);\nvoid  gkw_lb_submit_score(const char* board_id, int score);\nvoid  gkw_lb_show_board(const char* board_id);\n")

function gamecenter:init(name, params)
	if self.initied then
		log.debug("service %s already inited", name)
	else
		self.lib = PSU:load_library("kgamekit", ffi)

		if not self.lib then
			log.error("Error loading kgamekit library")

			return false
		end

		self.inited = self.lib.gkw_initialize()

		if not self.inited then
			log.error("Error initializing kgamekit")

			return false
		end

		do
			local ids = require("data.platform_services_ids")

			if not ids then
				log.error("data.platform_services_ids missing")

				return nil
			end

			local ids_key = params and params.id or "gamecenter"

			if not ids[ids_key] then
				log.error("data.platform_services_ids for %s not found", ids_key)

				return nil
			end

			self.ids = ids[ids_key]
		end

		self.prq = PSU:new_prq()
	end

	if self.signal_handlers and self.signal_handlers[name] then
		for sn, fn in pairs(self.signal_handlers[name]) do
			log.debug("registering signal %s", sn)
			signal.register(sn, fn)
		end
	end

	self.names = self.names or {}

	if not table.contains(self.names, name) then
		table.insert(self.names, name)
	end

	return true
end

function gamecenter:shutdown(name)
	log.debug("Shutting down ")

	if self.inited then
		if self.signal_handlers and self.signal_handlers[name] then
			for sn, fn in pairs(self.signal_handlers[name]) do
				log.debug("removing signal %s", sn)
				signal.remove(sn, fn)
			end
		end

		self.lib.gkw_shutdown()
	end

	self.names = nil
	self.lib = nil
	self.inited = false
end

function gamecenter:get_status()
	return self.inited
end

function gamecenter:get_install_dir()
	local o = love.filesystem.getUserDirectory() .. ".config"

	return o
end

function gamecenter:get_pending_requests()
	return self.prq
end

function gamecenter:get_request_status(rid)
	if self.inited then
		local result = self.lib.gkw_get_request_status(rid)

		log.paranoid("get_request_status(%s) = %s", rid, result)

		return result
	end

	return -1
end

function gamecenter:cancel_request(rid)
	if not rid then
		return
	end

	self.prq:remove(rid)

	if self.inited then
		self.lib.gkw_delete_request(rid)
	end
end

function gamecenter:do_signin()
	return
end

function gamecenter:do_signout()
	return
end

function gamecenter:unlock_achievement(ach_id, defer_store)
	if not self.inited then
		log.error("kgamekit not initialized")

		return
	end

	local gkw_ach_id = self.ids.achievements[ach_id]

	if not gkw_ach_id then
		log.error("gkw achievement id missing for %s", ach_id)

		return
	end

	self.lib.gkw_ach_unlock(gkw_ach_id)
	log.debug("Unlocked achievement %s (%s)", ach_id, gkw_ach_id)
end

function gamecenter:sync_achievements()
	local function cb_sync_achievements(status, req)
		if not self.prq:contains(req.id) then
			return
		end

		local success

		if status == 0 then
			success = true
			self.sync_times.achievements = os.time()
		else
			success = false
			self.sync_times.achievements = false
		end

		signal.emit(SGN_PS_SYNC_ACHIEVEMENTS_FINISHED, "achievements", success, req.id)
	end

	local rid = self.lib.gkw_create_request_ach_sync()

	if rid < 0 then
		log.error("error creating request to sync achievements")

		return nil
	end

	self.prq:add(rid, "sync_achievements", cb_sync_achievements)

	return rid
end

function gamecenter:list_achievements()
	local achs = {}
	local achs_cd = self.lib.gkw_ach_get_cached()

	if achs_cd then
		local achs_str = ffi.string(achs_cd)

		if achs_str and achs_str ~= "" then
			achs = string.split(achs_str, ",")
		end
	end

	return achs
end

function gamecenter:reset_achievements()
	if not self.inited then
		log.error("kgamekit not initialized")

		return
	end

	self.lib.gkw_ach_reset_all()
	log.debug("reset all achievements")
end

function gamecenter:show_achievements()
	self.lib.gkw_ach_show()
end

function gamecenter:show_leaderboard(level_idx, diff_idx)
	local board_id = self.ids.leaderboards[level_idx] and self.ids.leaderboards[level_idx][diff_idx] or nil

	if not board_id then
		log.error("gps leaderboard id missing for level_idx: %s", level_idx)

		return
	end

	self.lib.gkw_lb_show_board(board_id)
end

function gamecenter:submit_score(level_idx, diff_idx, score)
	local board_id = self.ids.leaderboards[level_idx] and self.ids.leaderboards[level_idx][diff_idx] or nil

	if not board_id then
		log.error("gps leaderboard id missing for level_idx: %s", level_idx)

		return
	end

	self.lib.gkw_lb_submit_score(board_id, score)
	log.debug("Submitted score to leaderboard:%s score:%s", board_id, score)
end

return gamecenter
