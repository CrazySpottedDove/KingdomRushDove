local M = {}

local DEFAULT = "/mnt/d/Local-App/NVIDIA Texture Tools/nvdecompress.exe"

local function q(s)
	return string.format("%q", s)
end

function M.decode(dds, png, opts)
	opts = opts or {}
	local exe = opts.exe or os.getenv("NVDECOMPRESS") or DEFAULT
	local tmp = png .. ".tmp.png"
	os.remove(tmp)
	local cmd = string.format("%s -format png %s %s", q(exe), q(dds), q(tmp))
	local ok = os.execute(cmd)
	if not (ok == true or ok == 0) then
		os.remove(tmp)
		return nil, "nvdecompress failed: " .. cmd
	end
	local f = io.open(tmp, "rb")
	if not f then
		return nil, "nvdecompress did not produce " .. tmp
	end
	f:close()
	os.remove(png)
	local okr, err = os.rename(tmp, png)
	if not okr then
		return nil, "rename failed: " .. tostring(err)
	end
	return true
end

if arg and arg[0] and arg[0]:match("decode_dds%.lua$") then
	local src, dst = arg[1], arg[2]
	if not src or not dst then
		io.stderr:write("用法: luajit scripts/assets/decode_dds.lua <dds> <png>\n")
		os.exit(1)
	end
	local ok, err = M.decode(src, dst)
	if not ok then
		io.stderr:write(tostring(err) .. "\n")
		os.exit(1)
	end
end

return M
