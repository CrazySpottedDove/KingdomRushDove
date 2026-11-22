local storage = require("all.storage")
local restart = {}

local IS_WINDOWS = love.system.getOS() == "Windows"
local ffi
local shell32
local kernel32

-- 处理 windows 上中文路径的问题
if IS_WINDOWS then
	ffi = require("ffi")
	shell32 = ffi.load("shell32")
	kernel32 = ffi.load("kernel32")
	ffi.cdef[[
		unsigned long GetCurrentProcessId(void);
		int MultiByteToWideChar(unsigned int CodePage, unsigned long dwFlags, const char *lpMultiByteStr, int cbMultiByte, wchar_t *lpWideCharStr, int cchWideChar);
		void *ShellExecuteW(void *hwnd, const wchar_t *lpOperation, const wchar_t *lpFile, const wchar_t *lpParameters, const wchar_t *lpDirectory, int nShowCmd);
	]]
else
	ffi = require("ffi")
	ffi.cdef[[
		int getpid(void);
	]]
end

local function utf8_to_wide(value)
	local length = ffi.C.MultiByteToWideChar(65001, 0, value, #value, nil, 0)
	local buffer = ffi.new("wchar_t[?]", length + 1)
	ffi.C.MultiByteToWideChar(65001, 0, value, #value, buffer, length)
	return buffer
end

local function quote_argument(value)
	return '"' .. tostring(value):gsub('"', '\\"') .. '"'
end

local function spawn_new_process()
	local exe = love.filesystem.getExecutablePath()
	local args = {quote_argument(exe)}
	local skip_next = false
	for i = 1, #arg do
		if skip_next then
			skip_next = false
		elseif arg[i] == "-restart-wait-pid" then
			skip_next = true
		else
			args[#args + 1] = quote_argument(arg[i])
		end
	end
	args[#args + 1] = quote_argument("-restart-wait-pid")
	args[#args + 1] = quote_argument(IS_WINDOWS and kernel32.GetCurrentProcessId() or ffi.C.getpid())

	if IS_WINDOWS then
		local result = shell32.ShellExecuteW(nil, utf8_to_wide("open"), utf8_to_wide(exe), utf8_to_wide(table.concat(args, " ", 2)), nil, 1)
		return ffi.cast("intptr_t", result) > 32
	end

	return os.execute("nohup " .. table.concat(args, " ") .. " >/dev/null 2>&1 &") == 0
end

function restart.tmp()
	main.params.tmp_restart = true
	storage:save_settings(main.params)
	if spawn_new_process() then
		love.event.quit()
	else
		love.event.quit("restart")
	end
end

function restart.full()
	if spawn_new_process() then
		love.event.quit()
	else
		love.event.quit("restart")
	end
end

return restart
