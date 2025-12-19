-- chunkname: @./all-desktop/platform_services_steam.lua
local log = require("lib.klua.log"):new("platform_services_steam")
local PSU = require("platform_services_utils")
local signal = require("hump.signal")
local steam = {}

steam.can_be_paused = false
steam.update_interval = 2
steam.call_default_update = true
steam._rid = 1

function steam:get_rid()
	self._rid = self._rid + 1

	return self._rid
end

steam.signal_handlers = {
	achievements = {
		["got-achievement"] = function(ach_id)
			steam:unlock_achievement(ach_id)
		end
	},
	leaderboards = {
		["game-defeat"] = function(store)
			if store.level_mode == GAME_MODE_ENDLESS then
				steam:submit_score(store.level_idx, store.level_difficulty, store.player_score)
			end
		end
	}
}
steam.lib = nil
steam.client_ptr = nil
steam.userstats_ptr = nil
steam.apps_ptr = nil
steam.inited = false
steam.USERSTATS_INTERFACE_VERSION = "STEAMUSERSTATS_INTERFACE_VERSION011"
steam.STEAMAPPS_INTERFACE_VERSION = "STEAMAPPS_INTERFACE_VERSION008"
steam.STEAMUTILS_INTERFACE_VERSION = "SteamUtils009"

local ffi = require("ffi")

ffi.cdef("    /* Types */\n    typedef int32_t int32;               // type aliases so we can just use steam_api_flat.h copy declarations verbatim\n    typedef uint32_t uint32;\n    typedef uint64_t uint64;\n\n    typedef unsigned char uint8;\n    typedef int32 AppId_t;\n    typedef int32 HSteamPipe;\n    typedef int32 HSteamUser;\n    typedef uint64 SteamAPICall_t;\n\n    typedef int32 ESteamAPICallFailure;\n\n    typedef uint64 SteamLeaderboard_t;\n    typedef struct LeaderboardFindResult_t\n    {\n\tSteamLeaderboard_t m_hSteamLeaderboard;\t// handle to the leaderboard serarched for, 0 if no leaderboard found\n\tuint8 m_bLeaderboardFound;\t\t\t\t// 0 if no leaderboard found\n    };\n    typedef struct LeaderboardScoreUploaded_t\n    {\n    \tuint8 m_bSuccess;\t\t\t// 1 if the call was successful\n    \tSteamLeaderboard_t m_hSteamLeaderboard;\t// the leaderboard handle that was\n    \tint32 m_nScore;\t\t\t\t// the score that was attempted to set\n    \tuint8 m_bScoreChanged;\t\t// true if the score in the leaderboard change, false if the existing score was better\n    \tint m_nGlobalRankNew;\t\t// the new global rank of the user in this leaderboard\n    \tint m_nGlobalRankPrevious;\t// the previous global rank of the user in this leaderboard; 0 if the user had no existing entry in the leaderboard\n    };  \n\n    typedef int32 ELeaderboardUploadScoreMethod;\n    // {\n    //     k_ELeaderboardUploadScoreMethodNone = 0,\n    //     k_ELeaderboardUploadScoreMethodKeepBest = 1,\t// Leaderboard will keep user's best score\n    //     k_ELeaderboardUploadScoreMethodForceUpdate = 2,\t// Leaderboard will always replace score with specified\n    // };\n\n    /* Function prototypes */\n    bool SteamAPI_Init();                // native lib init and shutdown  \n    void SteamAPI_Shutdown(); \n    bool SteamAPI_RestartAppIfNecessary(uint32 unOwnAppID);\n    \n    intptr_t SteamClient();              // returns reference to SteamClient singleton\n    \n    HSteamPipe SteamAPI_GetHSteamPipe(); // handle to communication pipe for client communication\n    HSteamUser SteamAPI_GetHSteamUser(); \n\n    intptr_t SteamAPI_ISteamClient_GetISteamApps(intptr_t instancePtr, HSteamUser hSteamUser, HSteamPipe hSteamPipe, const char * pchVersion);\n    uint32   SteamAPI_ISteamApps_GetAppInstallDir(intptr_t instancePtr, AppId_t appID, char * pchFolder, uint32 cchFolderBufferSize);\n\n    /* SteamClient function which returns a reference to SteamUserStats object */\n    intptr_t SteamAPI_ISteamClient_GetISteamUserStats(intptr_t instancePtr, HSteamUser hSteamUser, HSteamPipe hSteamPipe, const char * pchVersion);\n    bool SteamAPI_ISteamClient_BReleaseSteamPipe(intptr_t instancePtr, HSteamPipe hSteamPipe);\n    void SteamAPI_ISteamClient_ReleaseUser(intptr_t instancePtr, HSteamPipe hSteamPipe, HSteamUser hUser);\n    \n    /* SteamUserStats functions (isteamuserstats.h). The instancePtr is the reference to the SteamUsersStats object returned by GetISteamUserStats  */\n    bool SteamAPI_ISteamUserStats_SetAchievement(intptr_t instancePtr, const char * pchName);  // unlock achievement by name\n    bool SteamAPI_ISteamUserStats_RequestCurrentStats(intptr_t instancePtr);                   // request current stats and achievements for the game\n    void SteamAPI_RunCallbacks();                                                              // must be called periodically to pump requests callbacks\n    bool SteamAPI_ISteamUserStats_StoreStats(intptr_t instancePtr);                            // stores any changes to stats and achievements\n    bool SteamAPI_ISteamUserStats_GetAchievement(intptr_t instancePtr, const char * pchName, bool * pbAchieved); // query status for named achievement and return it in pbAchieved\n    bool SteamAPI_ISteamUserStats_ResetAllStats(intptr_t instancePtr, bool bAchievementsToo);  // Development only: reset stats and (optional) achievements\n\n    SteamAPICall_t SteamAPI_ISteamUserStats_FindLeaderboard(intptr_t instancePtr, const char * pchLeaderboardName);\n    SteamAPICall_t SteamAPI_ISteamUserStats_UploadLeaderboardScore(intptr_t instancePtr, SteamLeaderboard_t hSteamLeaderboard, ELeaderboardUploadScoreMethod eLeaderboardUploadScoreMethod, int32 nScore, const int32 * pScoreDetails, int cScoreDetailsCount);\n\n    intptr_t SteamAPI_ISteamClient_GetISteamUtils(intptr_t instancePtr, HSteamPipe hSteamPipe, const char * pchVersion);\n    bool SteamAPI_ISteamUtils_IsAPICallCompleted(intptr_t instancePtr, SteamAPICall_t hSteamAPICall, bool * pbFailed);\n    ESteamAPICallFailure SteamAPI_ISteamUtils_GetAPICallFailureReason(intptr_t instancePtr, SteamAPICall_t hSteamAPICall);\n    bool SteamAPI_ISteamUtils_GetAPICallResult(intptr_t instancePtr, SteamAPICall_t hSteamAPICall, void * pCallback, int cubCallback, int iCallbackExpected, bool * pbFailed);\n\n")

function steam:init(name, params)
	local lib_name, lib, sclient, ustats, astats, sutils

	if self.initied then
		log.debug("service %s already inited", name)
	else
		if not params or not params.app_id or type(params.app_id) ~= "number" then
			log.error("platform_services_steam requires app_id param of type number")

			return 
		end

		self.app_id = params.app_id
		lib_name = PSU:get_library_file("steam_api")
		self.lib = ffi.load(lib_name)
		lib = self.lib

		if not lib then
			log.error("Steam library %s could not be loaded", lib_name)

			return 
		end

		self.inited = lib.SteamAPI_Init()

		if not self.inited then
			log.error("SteamAPI_Init() failed")
			self:restart_app_if_necessary(self.app_id)

			return 
		end

		sclient = lib.SteamClient()

		if sclient == nil then
			log.error("SteamClient() returned NULL")
			self:restart_app_if_necessary(self.app_id)

			return 
		end

		self.pipe = lib.SteamAPI_GetHSteamPipe()
		self.user = lib.SteamAPI_GetHSteamUser()
		ustats = lib.SteamAPI_ISteamClient_GetISteamUserStats(sclient, self.user, self.pipe, self.USERSTATS_INTERFACE_VERSION)

		if ustats == nil then
			log.error("GetISteamUserStats() returned NULL")
			self:restart_app_if_necessary(self.app_id)

			return 
		end

		astats = lib.SteamAPI_ISteamClient_GetISteamApps(sclient, self.user, self.pipe, self.STEAMAPPS_INTERFACE_VERSION)

		if astats == nil then
			log.error("GetISteamApps() returned NULL")
			self:restart_app_if_necessary(self.app_id)

			return 
		end

		sutils = lib.SteamAPI_ISteamClient_GetISteamUtils(sclient, self.pipe, self.STEAMUTILS_INTERFACE_VERSION)

		if sutils == nil then
			log.error("GetISteamUtils() returned NULL")
			self:restart_app_if_necessary(self.app_id)

			return 
		end

		self:restart_app_if_necessary(self.app_id)

		self.client_ptr = sclient
		self.userstats_ptr = ustats
		self.apps_ptr = astats
		self.sutils_ptr = sutils

		lib.SteamAPI_ISteamUserStats_RequestCurrentStats(self.userstats_ptr)
		lib.SteamAPI_RunCallbacks()

		if KR_GAME == "kr1" or KR_GAME == "kr2" then
			local ids = require("data.platform_services_ids")

			if not ids or not ids.steam then
				log.error("data.platform_services_ids for steam not found")

				return nil
			end

			self.ids = ids.steam
		end

		self.prq = PSU:new_prq()
		self.nrq = {}

		log.debug("init true")

		self.inited = true
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

	return true
end

function steam:shutdown()
	log.info("Shutting down steam lib")

	local lib = steam.lib

	if lib then
		lib.SteamAPI_Shutdown()
	end

	steam.client_ptr = nil
	steam.userstats_ptr = nil
	steam.lib = nil
	steam.pipe = nil
	steam.user = nil
	steam.inited = false
end

function steam:get_status()
	return self.inited
end

function steam:update(dt)
	local lib = steam.lib

	if steam.inited then
		lib.SteamAPI_RunCallbacks()
	end
end

function steam:get_pending_requests()
	return self.prq
end

function steam:get_request_status(rid)
	if self.inited then
		local n = self.nrq[rid]

		if n then
			local pb_failed = ffi.new("bool [1]", {false})

			if self.lib.SteamAPI_ISteamUtils_IsAPICallCompleted(self.sutils_ptr, n.hcall, pb_failed) then
				if pb_failed[0] then
					local errcode = SteamAPI_ISteamUtils_GetAPICallFailureReason(self.sutils_ptr, n.hcall)

					log.error("steam api failure reason:%s", errcode)

					return 99
				else
					return 0
				end
			else
				return 1
			end
		end
	end

	return -1
end

function steam:cancel_request(rid)
	if not rid then
		return 
	end

	self.prq:remove(rid)

	self.nrq[rid] = nil
end

function steam:get_install_dir()
	local lib = steam.lib

	if not steam.inited then
		return nil
	end

	local folder_len = 1024
	local folder_c = ffi.new("char[?]", folder_len)
	local len = lib.SteamAPI_ISteamApps_GetAppInstallDir(steam.apps_ptr, self.app_id, folder_c, folder_len)
	local folder = ffi.string(folder_c)

	return folder
end

function steam:do_signin()
	return 
end

function steam:do_signout()
	return 
end

function steam:unlock_achievement(ach_id, defer_store)
	ach_id = self.ids and self.ids.achievements and self.ids.achievements[ach_id] or ach_id

	log.debug("unlock achievement %s", ach_id)

	local lib = steam.lib
	local sus = steam.userstats_ptr

	if steam.inited then
		lib.SteamAPI_ISteamUserStats_SetAchievement(sus, ach_id)

		if not defer_store then
			steam:store_stats()
		end
	else
		log.error("SteamAPI not inited yet. Ignoring achievement unlock: %s", tostring(ach_id))

		return false
	end
end

function steam:show_achievements()
	log.info("unsupported by steam")
end

function steam:show_leaderboard(level_idx, diff_idx)
	local meta = self.ids and self.ids.leaderboards_metadata and self.ids.leaderboards_metadata[level_idx][diff_idx] or nil

	if meta and meta.url then
		love.system.openURL(meta.url)
	end
end

function steam:submit_score(level_idx, diff_idx, score)
	local board_id = self.ids and self.ids.leaderboards and self.ids.leaderboards[level_idx][diff_idx] or nil

	if not board_id then
		log.error("leaderboard id missing for level_idx:%s diff_idx:%s", level_idx, diff_idx)

		return 
	end

	local function cb_upload_leaderboard_score(status, req)
		local n = self.nrq[req.id]

		if status == 0 then
			local pc = ffi.new("struct LeaderboardScoreUploaded_t")
			local ce = 1106
			local pf = ffi.new("bool [1]", {false})

			if self.lib.SteamAPI_ISteamUtils_GetAPICallResult(self.sutils_ptr, n.hcall, pc, ffi.sizeof(pc), ce, pf) then
				log.debug("rid:%s - cb_upload_leaderboard_score - GetAPICallResult success. success:%s", req.id, pc.m_bSuccess)
			else
				log.error("rid:%s - cb_upload_leaderboard - GetAPICallResult(%s,%s) error", req.id, n.iptr, n.hcall)
			end
		end
	end

	local function cb_find_leaderboard(status, req)
		local n = self.nrq[req.id]

		if status == 0 then
			local pc = ffi.new("struct LeaderboardFindResult_t")
			local ce = 1104
			local pf = ffi.new("bool [1]", {false})

			if self.lib.SteamAPI_ISteamUtils_GetAPICallResult(self.sutils_ptr, n.hcall, pc, ffi.sizeof(pc), ce, pf) then
				log.debug("rid:%s - cb_find_leaderboard - GetAPICallResult success. found:%s", req.id, pc.m_bLeaderboardFound)

				local nrid = self:get_rid()
				local nn = {}

				nn.iptr = steam.userstats_ptr
				nn.hcall = self.lib.SteamAPI_ISteamUserStats_UploadLeaderboardScore(self.userstats_ptr, pc.m_hSteamLeaderboard, 1, score, nil, 0)
				self.nrq[nrid] = nn

				self.prq:add(nrid, "steam.UploadLeaderboardScore", cb_upload_leaderboard_score)

				return 
			else
				log.error("rid:%s - cb_find_leaderboard - GetAPICallResult(%s,%s) error", req.id, n.iptr, n.hcall)
			end
		end
	end

	local rid = self:get_rid()
	local n = {}

	n.hcall = self.lib.SteamAPI_ISteamUserStats_FindLeaderboard(steam.userstats_ptr, board_id)
	self.nrq[rid] = n

	self.prq:add(rid, "steam.get_FindLeaderboard", cb_find_leaderboard)
	log.debug("rid:%s - Submitted score to leaderboard:%s score:%s", rid, board_id, score)

	return rid
end

function steam:achievement_unlocked(ach_id)
	local lib = steam.lib
	local sus = steam.userstats_ptr

	ach_id = self.ids and self.ids.achievements and self.ids.achievements[ach_id] or ach_id

	if steam.inited then
		local achieved = ffi.new("bool [1]", {false})

		lib.SteamAPI_ISteamUserStats_GetAchievement(sus, ach_id, achieved)

		return achieved[0] == true
	else
		log.error("SteamAPI not inited yet. Can't query achievement status: %s", tostring(ach_id))
	end
end

function steam:store_stats()
	local lib = steam.lib
	local sus = steam.userstats_ptr

	if steam.inited then
		lib.SteamAPI_ISteamUserStats_StoreStats(sus)
	else
		log.error("SteamAPI not inited yet. Ignoring store_stats(): ")
	end
end

function steam:reset_stats(achievements_too)
	log.error("RESETTING ALL STATS AND ACHIEVEMENTS!")

	local lib = steam.lib
	local sus = steam.userstats_ptr

	if steam.inited then
		lib.SteamAPI_ISteamUserStats_ResetAllStats(sus, achievements_too)
		steam:store_stats()
	end
end

function steam:restart_app_if_necessary(appid)
	local lib = steam.lib

	if lib.SteamAPI_RestartAppIfNecessary(appid) then
		log.error("SteamAPI_RestartAppIfNecessary() returned true! Steam should soon launch automatically.")

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

return steam
