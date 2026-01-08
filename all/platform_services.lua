-- chunkname: @./all/platform_services.lua
local log = require("lib.klua.log"):new("platform_services")
local signal = require("lib.hump.signal")
local features = require("features")
local PLATFORM_SERVICE_TIMEOUT = 60
local ps = {}

ps.services = {}
ps.paused = nil

function ps:init(only_essential)
	if not features.platform_services then
		log.debug("Platform services not defined. Skipping init")

		return
	end

	for k, v in pairs(features.platform_services) do
		if only_essential and not v.essential then
		-- block empty
		elseif not v.enabled then
			log.debug("Service %s disabled", k)
		elseif not v.src then
			log.error("Service %s has no src param", k)
		else
			local s = require(v.src)

			if not s then
				log.error("Error requiring service %s src %s", k, v.src)
			elseif s:init(k, v.params) then
				log.debug("Service %s (src=%s) initialized", k, v.src)

				self.services[k] = s
				s.name = v.name

				if v.name ~= k then
					self.services[v.name] = s
				end

				s.ts = 0
			end
		end
	end
end

function ps:shutdown()
	for _, service in pairs(self.services) do
		if type(service.shutdown) == "function" then
			service:shutdown()
		end
	end
end

function ps:update(dt)
	for _, service in pairs(self.services) do
		if type(service.update) == "function" then
			if not service.can_be_paused or not service.paused then
				service:update(dt)
			end

			if not service.call_default_update then
				goto label_3_0
			end
		end

		if not service.inited then
		-- block empty
		else
			if service.update_interval then
				service.ts = service.ts + dt

				if service.update_interval and service.last_ts and service.ts - service.last_ts < service.update_interval then
					goto label_3_0
				end
			end

			if type(service.get_status) == "function" then
				local ns = service:get_status()

				if ns ~= service.last_status or service.last_ts == nil then
					service.last_status = ns

					for _, n in pairs(service.names) do
						log.paranoid("status changed for %s: %s", n, service.last_status)
						signal.emit(SGN_PS_STATUS_CHANGED, n, service.last_status)
					end
				end
			end

			if type(service.update_requests) == "function" then
				service:update_requests(dt)
			end

			if type(service.get_pending_requests) == "function" then
				local to_remove = {}

				for rid, req in pairs(service:get_pending_requests()) do
					local status = service:get_request_status(rid)

					if status == 1 then
						if req.timeout == -1 then
						-- block empty
						else
							local ts = love.timer.getTime()
							local timeout = req.timeout or PLATFORM_SERVICE_TIMEOUT

							if timeout < ts - req.ts then
								log.error("request (%s)%s timed out (%s)", rid, req.kind, timeout)
								table.insert(to_remove, rid)
							end
						end
					else
						if status == -1 then
						-- block empty
						elseif req.callback then
							req.callback(status, req)
						end

						table.insert(to_remove, rid)
					end
				end

				for _, rid in pairs(to_remove) do
					service:cancel_request(rid)
				end
			end

			if type(service.late_update) == "function" and (not service.can_be_paused or not service.paused) then
				service:late_update(dt)
			end

			service.last_ts = service.ts
		end

		::label_3_0::
	end
end

return ps
