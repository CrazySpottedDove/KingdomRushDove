-- -- chunkname: @./lib/klua/log.lua
-- local dgetinfo = debug.getinfo
-- local strformat = string.format
-- local noNames = {
-- 	INFO_LEVEL = true,
-- 	ERROR_LEVEL = true,
-- 	DEBUG_LEVEL = true,
-- 	debug = true,
-- 	TODO_LEVEL = true,
-- 	paranoid = true,
-- 	WARNING_LEVEL = true,
-- 	PARANOID_LEVEL = true,
-- 	warning = true,
-- 	error = true,
-- 	OFF_LEVEL = true,
-- 	new = true,
-- 	info = true,
-- 	todo = true
-- }
-- local klog = {
-- 	WARNING_LEVEL = 2,
-- 	ERROR_LEVEL = 1,
-- 	DEBUG_LEVEL = 4,
-- 	TODO_LEVEL = 1,
-- 	INFO_LEVEL = 3,
-- 	OFF_LEVEL = 0,
-- 	PARANOID_LEVEL = 5
-- }

-- klog.__index = klog
-- klog.level = klog.ERROR_LEVEL
-- klog.default_level_by_name = {}
-- klog.last_log_msgs = {}
-- klog.last_log_count = 10

-- local function log(use_print, logname, level, fmt, ...)
-- 	local func_info = dgetinfo(3, "n")
-- 	local func_name = func_info.name or "-"
-- 	local time = love and love.timer.getTime() or os.clock()
-- 	local user_str = strformat(fmt or "", ...)
-- 	local out = strformat("[%.4f] %s.%s %s() - %s\n", time, logname, level, func_name, user_str)

-- 	if level == "ERROR   " then
-- 		table.insert(klog.last_log_msgs, 1, out)

-- 		if #klog.last_log_msgs > klog.last_log_count then
-- 			table.remove(klog.last_log_msgs)
-- 		end
-- 	end

-- 	if use_print then
-- 		print(out)
-- 	else
-- 		io.write(out)

-- 		if io.output() == io.stdout then
-- 			io.flush()
-- 		end
-- 	end
-- end

-- function klog.new(parentlog, name, newlevel)
-- 	local newlog = setmetatable({}, parentlog)

-- 	parentlog.__index = parentlog

-- 	if parentlog then
-- 		if parentlog.default_level_by_name and parentlog.default_level_by_name[name] then
-- 			newlog.level = parentlog.default_level_by_name[name]
-- 		else
-- 			newlog.level = newlevel and newlevel or parentlog.level
-- 		end

-- 		newlog.use_print = parentlog.use_print
-- 	else
-- 		newlog.level = newlevel and newlevel or klog.level
-- 	end

-- 	if type(name) == "string" then
-- 		assert(not noNames[name], "Can't use name " .. name .. " for a klogger. It's reserved!")

-- 		newlog.name = name
-- 		klog[name] = newlog
-- 	end

-- 	function newlog.paranoid(fmt, ...)
-- 		if newlog.level >= klog.PARANOID_LEVEL then
-- 			log(newlog.use_print, newlog.name, "PARANOID", fmt, ...)
-- 		end
-- 	end

-- 	function newlog.debug(fmt, ...)
-- 		if newlog.level >= klog.DEBUG_LEVEL then
-- 			log(newlog.use_print, newlog.name, "DEBUG   ", fmt, ...)
-- 		end
-- 	end

-- 	function newlog.info(fmt, ...)
-- 		if newlog.level >= klog.INFO_LEVEL then
-- 			log(newlog.use_print, newlog.name, "INFO    ", fmt, ...)
-- 		end
-- 	end

-- 	function newlog.warning(fmt, ...)
-- 		if newlog.level >= klog.WARNING_LEVEL then
-- 			log(newlog.use_print, newlog.name, "WARNING ", fmt, ...)
-- 		end
-- 	end

-- 	function newlog.error(fmt, ...)
-- 		if newlog.level >= klog.ERROR_LEVEL then
-- 			log(newlog.use_print, newlog.name, "ERROR   ", fmt, ...)
-- 		end
-- 	end

-- 	function newlog.todo(fmt, ...)
-- 		if newlog.level >= klog.TODO_LEVEL then
-- 			log(newlog.use_print, newlog.name, "TODO   ", fmt, ...)
-- 		end
-- 	end

-- 	function newlog.assert(check, fmt, ...)
-- 		if newlog.level >= klog.DEBUG_LEVEL then
-- 			assert(check, string.format(fmt, ...))
-- 		end
-- 	end

-- 	function newlog.traceall(msg)
-- 		msg = msg or ""

-- 		log(newlog.use_print, newlog.name, "TRACEBACK  ", "\n%s", debug.traceback(msg, 2))
-- 	end

-- 	function newlog.trace(depth)
-- 		if newlog.level >= klog.DEBUG_LEVEL then
-- 			local level = 1
-- 			local o = ""

-- 			while true do
-- 				local info = debug.getinfo(level, "Sln")

-- 				if not info or depth and depth < level then
-- 					break
-- 				end

-- 				if info.what == "C" then
-- 					o = o .. string.format("    %2i - C function \n", level)
-- 				else
-- 					o = o .. string.format("    %2i - [%s]:%d at %s: %s\n", level, info.short_src, info.currentline, info.namewhat, info.name)
-- 				end

-- 				level = level + 1
-- 			end

-- 			log(newlog.use_print, newlog.name, "TRACE   ", "\n%s", o)
-- 		end
-- 	end

-- 	return newlog
-- end

-- return klog:new("root")
-- chunkname: @./lib/klua/log.lua
local dgetinfo = debug.getinfo
local strformat = string.format
local klog = {
	levels = {
		warning = 2,
		error = 1,
		debug = 4,
		todo = 1,
		info = 3,
		off = 0,
		paranoid = 5
	},
	last_log_msgs = {},
	last_log_count = 10,
	use_print = false
}

klog.__index = klog
klog.level = klog.levels.error

local function log(use_print, logname, level, fmt, ...)
	local func_info = dgetinfo(3, "n")
	local func_name = func_info.name or "-"
	local user_str = strformat(fmt or "", ...)
	local out = strformat("%s.%s %s() - %s\n", logname, level, func_name, user_str)

	if level == "error" then
		table.insert(klog.last_log_msgs, 1, out)

		if #klog.last_log_msgs > klog.last_log_count then
			table.remove(klog.last_log_msgs)
		end
	end
	if use_print then
		print(out)
	else
		io.write(out)

		if io.output() == io.stdout then
			io.flush()
		end
	end
end

-- 设置日志的级别，可用的有 "off", "error", "warning", "info", "debug", "paranoid"
function klog:set_level(level_name)
	self.level = self.levels[level_name]
end

function klog:new(name)
	-- 继承自母模板
	local newlog = setmetatable({}, self)

	newlog.level = self.level
	newlog.name = name

	local levels = klog.levels

	if newlog.level >= levels.paranoid then
		function newlog.paranoid(fmt, ...)
			log(newlog.use_print, newlog.name, "paranoid", fmt, ...)
		end
	else
		function newlog.paranoid(fmt, ...)
		end
	end

	if newlog.level >= levels.debug then
		function newlog.debug(fmt, ...)
			log(newlog.use_print, newlog.name, "debug", fmt, ...)
		end

		function newlog.assert(check, fmt, ...)
			assert(check, string.format(fmt, ...))
		end

		function newlog.trace(depth)
			local level = 1
			local o = ""

			while true do
				local info = debug.getinfo(level, "Sln")

				if not info or depth and depth < level then
					break
				end

				if info.what == "C" then
					o = o .. string.format("    %2i - C function \n", level)
				else
					o = o .. string.format("    %2i - [%s]:%d at %s: %s\n", level, info.short_src, info.currentline, info.namewhat, info.name)
				end

				level = level + 1
			end

			log(newlog.use_print, newlog.name, "TRACE   ", "\n%s", o)
		end
	else
		function newlog.debug(fmt, ...)
		end

		function newlog.assert(check, fmt, ...)
		end

		function newlog.trace(depth)
		end
	end

	if newlog.level >= levels.info then
		function newlog.info(fmt, ...)
			log(newlog.use_print, newlog.name, "info", fmt, ...)
		end
	else
		function newlog.info(fmt, ...)
		end
	end

	if newlog.level >= levels.warning then
		function newlog.warning(fmt, ...)
			log(newlog.use_print, newlog.name, "warning", fmt, ...)
		end
	else
		function newlog.warning(fmt, ...)
		end
	end

	if newlog.level >= levels.error then
		function newlog.error(fmt, ...)
			log(newlog.use_print, newlog.name, "error", fmt, ...)
		end
	else
		function newlog.error(fmt, ...)
		end
	end

	if newlog.level >= levels.todo then
		function newlog.todo(fmt, ...)
			log(newlog.use_print, newlog.name, "todo", fmt, ...)
		end
	else
		function newlog.todo(fmt, ...)
		end
	end

	function newlog.traceall(msg)
		msg = msg or ""

		log(newlog.use_print, newlog.name, "TRACEBACK  ", "\n%s", debug.traceback(msg, 2))
	end

	return newlog
end

return klog
