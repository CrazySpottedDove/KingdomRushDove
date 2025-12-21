-- chunkname: @./all-desktop/platform_services_rail.lua
local log = require("lib.klua.log"):new("platform_services_rail")
local PSU = require("platform_services_utils")
local signal = require("hump.signal")
local GS = require("game_settings")
local rail = {}

rail.can_be_paused = false
rail.update_interval = 1
rail.sync_times = {}
rail.lib = nil
rail.R = nil
rail.inited = nil
rail.signal_handlers = {
	achievements = {
		["got-achievement"] = function(ach_id)
			rail:unlock_achievement(ach_id)
		end
	},
	leaderboards = {
		["game-defeat"] = function(store)
			if store.level_mode == GAME_MODE_ENDLESS then
				rail:submit_score(store.level_idx, store.level_difficulty, store.player_score)
			end
		end
	}
}

local ffi = require("ffi")

ffi.cdef("    typedef struct RailW RailW;\n\n    RailW* railw_new(const char* lib_path);\n    void railw_delete(RailW* r);\n    \n    bool railw_must_restart_app(RailW* r, uint64_t game_id);\n\n    bool railw_initialize(RailW* r);\n    void railw_shutdown(RailW* r);\n    void railw_update(RailW* r);\n    int  railw_get_system_status(RailW* r);\n\n    // async requests management\n    void railw_delete_request(RailW* r, int rid);\n    int  railw_get_request_status(RailW* r, int rid);\n    int  railw_create_test_request(RailW* r);\n\n    // achievements\n    bool railw_ach_set(RailW* r,const char* name);\n    bool railw_ach_get(RailW* r,const char* name, bool* unlocked);\n    bool railw_ach_reset(RailW* r,const char* name);\n    int  railw_ach_async_request(RailW* r);\n    int  railw_ach_async_store(RailW* r);\n\n    int  railw_lb_async_request(RailW* r, const char* board_name);\n    bool railw_lb_update_score(RailW* r, const char* board_name, double score);\n")

function rail:init(name, params)
	local lib_name, lib_path

	if self.inited then
		log.debug("service %s already inited", name)
	else
		if not params or not params.game_id or type(params.game_id) ~= "number" then
			log.error("platform_services_rail requires game_id param of type number")

			return
		end

		self.game_id = params.game_id
		lib_name = PSU:get_library_file("rail_c_wrapper")
		lib_path = PSU:get_library_path()
		self.lib = ffi.load(lib_name)

		if self.lib then
			self.R = self.lib.railw_new(lib_path)
		end

		self:restart_app_if_necessary(self.game_id)

		self.inited = self.lib.railw_initialize(self.R)

		if not self.inited then
			log.error("railw_initialize() failed")

			return
		end

		self.prq = PSU:new_prq()
	end

	for sn, fn in pairs(self.signal_handlers) do
		for sn, fn in pairs(self.signal_handlers[name]) do
			log.debug("registering signal %s", sn)
			signal.register(sn, fn)
		end
	end

	if not self.names then
		self.names = {}
	end

	if not table.contains(self.names, name) then
		table.insert(self.names, name)
	end

	self:sync_achievements()
	self:sync_leaderboards()

	return true
end

function rail:shutdown()
	log.debug("Shutting down rail lib")

	local lib, R = self.lib, self.R

	if self.inited then
		lib.railw_shutdown(R)
	end

	self.lib = nil
	self.R = nil
	self.inited = false
end

function rail:get_status()
	if self.inited then
		local status = self.lib.railw_get_system_status(self.R)

		return status == 1
	end

	return false
end

function rail:update(dt)
	local lib, R = self.lib, self.R

	if self.inited then
		lib.railw_update(R)

		local status = lib.railw_get_system_status(R)

		if status ~= 0 and status ~= 1 then
			if DEBUG then
				log.error("DEBUG mode. Skipping exit")
			else
				love.event.quit()
			end
		end
	end
end

function rail:get_pending_requests()
	return self.prq
end

function rail:get_request_status(rid)
	if self.inited then
		local result = self.lib.railw_get_request_status(rid)

		log.paranoid("get_request_status(%s) = %s", rid, result)

		return result
	end

	return -1
end

function rail:cancel_request(rid)
	if not rid then
		return
	end

	self.prq:remove(rid)

	if self.inited then
		self.lib.railw_delete_request(rid)
	end
end

function rail:do_signin()
	return
end

function rail:do_signout()
	return
end

function rail:unlock_achievement(ach_id, defer_store)
	local lib, R = self.lib, self.R

	if self.inited then
		lib.railw_ach_set(R, ach_id)

		if not defer_store then
			lib.railw_ach_async_store(R)
		end
	else
		log.error("Rail API not initialized. Ignoring achievement unlock: %s", tostring(ach_id))

		return false
	end
end

function rail:sync_achievements()
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

	local rid = self.lib.railw_ach_async_request(self.R)

	if rid < 0 then
		log.error("error creating request to sync achievements")

		return nil
	end

	self.prq:add(rid, "sync_achievements", cb_sync_achievements)

	return rid
end

function rail:get_sync_status()
	return
end

function rail:sync_slots()
	return
end

function rail:push_slot(idx, overwrite)
	return
end

function rail:delete_slot(idx)
	return
end

function rail:sync_leaderboards()
	local function cb_sync_leaderboards(status, req)
		if not self.prq:contains(req.id) then
			return
		end

		local success

		if status == 0 then
			success = true
			self.sync_times.leaderboards = os.time()
		else
			success = false
			self.sync_times.leaderboards = false
		end
	end

	local BASE_IDX = 80

	for i = 1, GS.endless_levels_count do
		for diff = DIFFICULTY_EASY, DIFFICULTY_HARD do
			local rid = self.lib.railw_lb_async_request(self.R, "endless_" .. i + BASE_IDX .. "_" .. diff)

			if rid < 0 then
				log.error("error creating request to sync leaderboards")

				return nil
			end

			self.prq:add(rid, "sync_leaderboards", cb_sync_leaderboards)
		end
	end
end

function rail:submit_score(level_idx, difficulty_idx, score)
	local lib, R = self.lib, self.R

	if self.inited then
		return lib.railw_lb_update_score(R, "endless_" .. level_idx .. "_" .. difficulty_idx, score)
	else
		return false
	end
end

function rail:show_leaderboard(level_idx, difficulty_idx)
	return
end

function rail:restart_app_if_necessary(game_id)
	local lib, R = self.lib, self.R

	if R and lib.railw_must_restart_app(R, game_id) then
		log.error("RailW_RestartAppIfNecessary() returned true. Rail should soon launch automatically.")

		if DEBUG then
			log.error("DEBUG mode. Skipping restart")
		else
			love.event.quit()
		end

		return true
	else
		return false
	end
end

return rail
