-- chunkname: @./all-desktop/platform_services_kart.lua
local log = require("lib.klua.log"):new("platform_services_kart")
local PSU = require("platform_services_utils")
local signal = require("hump.signal")
local kart = {}

kart.can_be_paused = false
kart.update_interval = 2
kart.signal_handlers = {
	achievements = {
		["got-achievement"] = function(ach_id)
			kart:unlock_achievement(ach_id)
		end
	}
}
kart.lib = nil
kart.inited = false
kart.USERSTATS_INTERFACE_VERSION = "KARTUSERSTATS_INTERFACE_VERSION011"

local ffi = require("ffi")

ffi.cdef("    typedef void* kongregate_event_listener(const char* const event_name, const char* const event_payload);\n\n    bool        KongregateAPI_RestartWithKartridgeIfNeeded(uint32_t game_id);\n    bool        KongregateAPI_Initialize(const char *settings_json);\n    void        KongregateAPI_Shutdown();\n    void        KongregateAPI_Update();\n    bool        KongregateAPI_IsConnected();\n    bool        KongregateAPI_IsReady();\n    void        KongregateAPI_SetEventListener(kongregate_event_listener listener);\n    const char* KongregateServices_GetUsername();\n    uint32_t    KongregateServices_GetUserId();\n    const char* KongregateServices_GetGameAuthToken();\n    void        KongregateStats_Submit(const char *name, int64_t value);\n")

function kart:init(name, params)
	local lib_name, lib

	if self.initied then
		log.debug("service %s already inited", name)
	else
		if not params or not params.game_id or type(params.game_id) ~= "number" then
			log.error("platform_services_kart requires game_id param of type number")

			return 
		end

		self.game_id = params.game_id
		lib_name = PSU:get_library_file("kartridge-sdk")
		self.lib = ffi.load(lib_name)
		lib = self.lib

		if not lib then
			log.error("Kart library %s could not be loaded", lib_name)

			return 
		end

		self:restart_app_if_necessary(self.game_id)

		self.inited = lib.KongregateAPI_Initialize(nil)

		if not self.inited then
			log.error("KongregateAPI_Initialize() failed")

			return 
		end

		lib.KongregateAPI_Update()

		self.inited = true
	end

	log.debug("inited")

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

function kart:shutdown()
	log.info("Shutting down kart lib")

	local lib = kart.lib

	if lib then
		lib.KongregateAPI_Shutdown()
	end

	kart.client_ptr = nil
	kart.userstats_ptr = nil
	kart.lib = nil
	kart.pipe = nil
	kart.user = nil
	kart.inited = false
end

function kart:get_status()
	return self.inited
end

function kart:update(dt)
	local lib = kart.lib

	if kart.inited then
		lib.KongregateAPI_Update()
	end
end

function kart:get_install_dir()
	local o = love.filesystem.getSourceBaseDirectory()

	if KR_PLATFORM == "win32" then
		return o
	elseif KR_PLATFORM == "mac" then
		local parts = string.split(o, "/")

		if not parts or #parts < 3 then
			log.error("could not find original install dir to import savegames in %s. skipping", o)

			return nil
		end

		o = "/" .. table.concat(table.slice(parts, 1, #parts - 3), "/") .. "/Mac standalone"

		return o
	end

	return nil
end

function kart:do_signin()
	return 
end

function kart:do_signout()
	return 
end

function kart:unlock_achievement(ach_id, defer_store)
	log.debug("unlock achievement %s", ach_id)

	local lib = kart.lib

	if kart.inited and lib.KongregateAPI_IsReady() then
		lib.KongregateStats_Submit(ach_id, 1)
	else
		log.error("Kart not inited yet. Ignoring achievement unlock: %s", tostring(ach_id))

		return false
	end
end

function kart:show_achievements()
	return 
end

function kart:restart_app_if_necessary(appid)
	local lib = kart.lib

	if lib.KongregateAPI_RestartWithKartridgeIfNeeded(appid) then
		log.error("KongregateAPI_RestartWithKartridgeIfNeeded() returned true! Kart should soon launch automatically.")

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

return kart
