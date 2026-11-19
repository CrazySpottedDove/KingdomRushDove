local sha = require("scripts.assets.sha256")
local bin = require("scripts.assets.binary")

local M = {}

local ALLOWED = {
	png = true,
	jpg = true,
	jpeg = true,
	bmp = true,
	tga = true,
	psd = true,
	fbx = true,
	obj = true,
	gif = true,
	webp = true,
	svg = true,
	mp3 = true,
	wav = true,
	dds = true,
	ogg = true,
	mp4 = true,
	otf = true,
	ttf = true,
	ttc = true
}

local function read_all(path)
	local f = assert(io.open(path, "rb"))
	local s = f:read("*a")
	f:close()
	return s
end

local function write_all(path, data)
	local f = assert(io.open(path, "wb"))
	f:write(data)
	f:close()
end

local function list_files(root)
	local p = assert(io.popen("find " .. string.format("%q", root) .. " -type f -print0 2>/dev/null"))
	local data = p:read("*a") or ""
	p:close()
	local out = {}
	for path in data:gmatch("([^%z]+)") do
		out[#out + 1] = path
	end
	return out
end

local function relpath(root, path)
	root = root:gsub("/+$", "")
	if path:sub(1, #root + 1) == root .. "/" then
		return path:sub(#root + 2)
	end
	return path
end

local function ext(path)
	return path:match("%.([A-Za-z0-9]+)$")
end

function M.scan(root, allowed, opts)
	opts = opts or {}
	local entries = {}
	for _, path in ipairs(list_files(root)) do
		local rel = relpath(root, path)
		local e = ext(rel)
		if e and allowed[e:lower()] and not rel:find("/%.git/", 1, true) then
			local skip = false
			for _, pat in ipairs(opts.exclude or {}) do
				if rel:find(pat, 1, true) then
					skip = true
					break
				end
			end
			if not skip then
				local data = read_all(path)
				entries[#entries + 1] = {
					path = rel,
					size = #data,
					sha256 = sha.hash_string(data)
				}
			end
		end
	end
	table.sort(entries, function(a, b)
		return a.path < b.path
	end)
	return entries
end

function M.build_runtime(runtime_dir)
	runtime_dir = runtime_dir or "_assets"
	local entries = M.scan(runtime_dir, ALLOWED, {
		exclude = {"/.git/"}
	})
	local data = bin.pack_index(entries, {
		source = false,
		source_index_sha256 = string.rep("\0", 32),
		mirror_manifest_sha256 = string.rep("\0", 32)
	})
	local out = runtime_dir .. "/assets_index.bin"
	write_all(out, data)
	return out, entries
end

function M.load(path)
	return bin.parse_index(read_all(path))
end

function M.verify(index_path, root)
	local index = M.load(index_path)
	local issues = {}
	for _, e in ipairs(index.entries) do
		local path = root .. "/" .. e.path
		if sha.hash_file(path) ~= e.sha256 then
			issues[#issues + 1] = e.path .. ": hash mismatch"
		end
	end
	return index, issues
end

local function print_tsv(index)
	for _, e in ipairs(index.entries) do
		print(string.format("%s\t%d\t%s", e.path, e.size, sha.hex(e.sha256)))
	end
end

local function json_escape(s)
	return (s:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n"))
end

local function print_json(index)
	print('{"magic":"' .. index.magic .. '","fmt":' .. index.fmt .. ',"count":' .. index.count .. ',"entries":[')
	for i, e in ipairs(index.entries) do
		local comma = i < #index.entries and "," or ""
		print(string.format('{"path":"%s","size":%d,"sha256":"%s"}%s', json_escape(e.path), e.size, sha.hex(e.sha256), comma))
	end
	print("]}")
end

local function print_lua(index)
	print("return {")
	for _, e in ipairs(index.entries) do
		print(string.format('\t["%s"] = {%d, "%s"},', e.path:gsub('"', '\\"'), e.size, sha.hex(e.sha256)))
	end
	print("}")
end

function M.decode(path, mode)
	local index = M.load(path)
	if mode == "json" then
		print_json(index)
	elseif mode == "lua" then
		print_lua(index)
	else
		print(string.format("# %s fmt=%d entries=%d total=%d", index.magic, index.fmt, index.count, index.total_size))
		print_tsv(index)
	end
end

function M.diff(a_path, b_path)
	local a = M.load(a_path)
	local b = M.load(b_path)
	local seen = {}
	local changes = 0
	for _, e in ipairs(a.entries) do
		seen[e.path] = true
		local other = b.map[e.path]
		if not other then
			print("- " .. e.path)
			changes = changes + 1
		elseif other.sha256 ~= e.sha256 or other.size ~= e.size then
			print("M " .. e.path)
			changes = changes + 1
		end
	end
	for _, e in ipairs(b.entries) do
		if not seen[e.path] then
			print("+ " .. e.path)
			changes = changes + 1
		end
	end
	return changes
end

local function usage()
	print([[
用法：
  index.lua build-runtime [runtime_dir]
  index.lua decode <index.bin> [--json|--tsv|--lua]
  index.lua verify <index.bin> --root <dir>
  index.lua diff <a.bin> <b.bin>
  index.lua lookup <path> <index.bin>
]])
end

local function main(args)
	local cmd = args[1]
	if cmd == "build-runtime" then
		local out, entries = M.build_runtime(args[2])
		print(string.format("wrote %s (%d entries)", out, #entries))
	elseif cmd == "decode" then
		if not args[2] then
			usage()
			os.exit(1)
		end
		local mode = args[3] == "--json" and "json" or args[3] == "--lua" and "lua" or "tsv"
		M.decode(args[2], mode)
	elseif cmd == "verify" then
		local root
		for i = 3, #args do
			if args[i] == "--root" then
				root = args[i + 1]
			end
		end
		if not args[2] or not root then
			usage()
			os.exit(1)
		end
		local index, issues = M.verify(args[2], root)
		if #issues == 0 then
			print(string.format("OK: %d entries", index.count))
		else
			for _, s in ipairs(issues) do
				print("ERROR " .. s)
			end
			os.exit(1)
		end
	elseif cmd == "diff" then
		if not args[2] or not args[3] then
			usage()
			os.exit(1)
		end
		local n = M.diff(args[2], args[3])
		print(string.format("# %d changes", n))
	elseif cmd == "lookup" then
		if not args[2] or not args[3] then
			usage()
			os.exit(1)
		end
		local index = M.load(args[3])
		local e = index.map[args[2]]
		if not e then
			os.exit(1)
		end
		print(string.format("%s\t%d\t%s", e.path, e.size, sha.hex(e.sha256)))
	else
		usage()
		os.exit(1)
	end
end

if arg and arg[0] and arg[0]:match("index%.lua$") then
	main(arg)
end

return M
