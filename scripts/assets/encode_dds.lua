local M = {}

local DEFAULT = "/mnt/d/Local-App/NVIDIA Texture Tools/nvcompress.exe"

local function q(s)
	return string.format("%q", s)
end

function M.encode(png, dds, opts)
	opts = opts or {}
	local exe = opts.exe or os.getenv("NVCOMPRESS") or DEFAULT
	local tmp = dds .. ".tmp.dds"
	os.remove(tmp)
	local cmd = string.format("%s -bc3 -highest -nomips -silent %s %s", q(exe), q(png), q(tmp))
	local ok = os.execute(cmd)
	if not (ok == true or ok == 0) then
		os.remove(tmp)
		return nil, "nvcompress failed: " .. cmd
	end
	local f = io.open(tmp, "rb")
	if not f then
		return nil, "nvcompress did not produce " .. tmp
	end
	f:close()
	os.remove(dds)
	local okr, err = os.rename(tmp, dds)
	if not okr then
		return nil, "rename failed: " .. tostring(err)
	end
	return true
end

if arg and arg[0] and arg[0]:match("encode_dds%.lua$") then
	local src, dst = arg[1], arg[2]
	if not src or not dst then
		io.stderr:write("用法: luajit scripts/assets/encode_dds.lua <png> <dds>\n")
		os.exit(1)
	end
	local ok, err = M.encode(src, dst)
	if not ok then
		io.stderr:write(tostring(err) .. "\n")
		os.exit(1)
	end
end

return M
