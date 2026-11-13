-- Run from the repository root: luajit scripts/test/plugin_gitignore.lua
local gitignore = require("dove_modules.gitignore")
local function check(pattern, path, directory, expected)
	local rules = {}
	gitignore.append(rules, pattern, "")
	assert(gitignore.ignored(rules, path, directory) == expected, pattern .. " -> " .. path)
end

check("*.log\r\n!keep.log", "sub/debug.log", false, true)
check("*.log\n!keep.log", "sub/keep.log", false, false)
check("/root.txt", "sub/root.txt", false, false)
check("/root.txt", "root.txt", false, true)
check("build/", "build", false, false)
check("build/", "sub/build", true, true)
check("a/**/b?.[ch]", "a/b1.c", false, true)
check("a/**/b?.[ch]", "a/x/y/b2.h", false, true)
check("a/*/b", "a/x/y/b", false, false)
check("a/**", "a", true, false)
check("a/**", "a/x", true, true)
check("**/cache", "cache", true, true)
check("[!0-9].txt", "a.txt", false, true)
check("[!0-9].txt", "1.txt", false, false)
check("[[:digit:]].txt", "1.txt", false, true)
check("[[:digit:]].txt", "a.txt", false, false)
check("#comment\n\\#file\n\\!file", "#file", false, true)
check("\\!file", "!file", false, true)
check("file   \nspace\\ \n\\*.txt", "file", false, true)
check("space\\ ", "space ", false, true)
check("\\*.txt", "*.txt", false, true)
check("\\*.txt", "other.txt", false, false)
check("file[", "file[", false, true)

local files = {
	[".gitignore"] = "*.log\nprivate/\n!private/keep.lua\n/root.txt",
	["config.lua"] = "config",
	["root.txt"] = "ignored",
	["debug.log"] = "ignored",
	["private/keep.lua"] = "ignored parent",
	["sub/.gitignore"] = "!keep.log\nlocal.txt",
	["sub/keep.log"] = "keep",
	["sub/debug.log"] = "ignored",
	["sub/local.txt"] = "ignored",
	["sub/root.txt"] = "keep",
	["other/local.txt"] = "keep",
	["other/keep.log"] = "ignored",
	["cover.png"] = "cover",
	[".backup/source.lua"] = "backup",
	["sub/cover.png"] = "nested cover",
	["sub/.backup/source.lua"] = "nested backup"
}
local dirs = {
	["plugin"] = {}
}
for path in pairs(files) do
	local parent = "plugin"
	for name in path:gmatch("[^/]+") do
		dirs[parent][name] = true
		parent = parent .. "/" .. name
		if not files[parent:sub(8)] then
			dirs[parent] = dirs[parent] or {}
		end
	end
end
local FS = {}
function FS.getDirectoryItems(path)
	local names = {}
	for name in pairs(dirs[path] or {}) do
		names[#names + 1] = name
	end
	table.sort(names)
	return names
end
function FS.getInfo(path, kind)
	local t = dirs[path] and "directory" or files[path:sub(8)] and "file"
	if t and (not kind or t == kind) then
		return {
			type = t
		}
	end
end
function FS.read(path)
	return files[path:sub(8)]
end
love = {
	filesystem = FS,
	data = {
		hash = function(_, data)
			return data
		end,
		encode = function(_, _, data)
			return data
		end
	}
}

-- Exercise the real walker without loading the game's GUI dependencies.
local source = assert(io.open("dove_modules/gui/plugin_manager_view.lua")):read("*a")
local method = assert(source:match("(function PluginManagerView:_compute_dir_hashes.-)\nfunction PluginManagerView:_hash_check"))
local view = {}
local chunk = assert(loadstring(method))
setfenv(chunk, setmetatable({
	PluginManagerView = view,
	FS = FS,
	gitignore = gitignore
}, {
	__index = _G
}))
chunk()
local hashes = view:_compute_dir_hashes("plugin", nil, true).hashes
local expected = {
	[".gitignore"] = true,
	["config.lua"] = true,
	["sub/.gitignore"] = true,
	["sub/keep.log"] = true,
	["sub/root.txt"] = true,
	["other/local.txt"] = true,
	["sub/cover.png"] = true,
	["sub/.backup/source.lua"] = true
}
for path in pairs(files) do
	assert((hashes[path] ~= nil) == (expected[path] == true), path)
end
local unfiltered = view:_compute_dir_hashes("plugin").hashes
assert(unfiltered["debug.log"], "download hashes must remain unfiltered")
assert(not unfiltered["cover.png"], "root cover must always be excluded")
assert(not unfiltered[".backup/source.lua"], "root .backup must always be excluded")
assert(unfiltered["sub/cover.png"], "built-in exclusions must be root-only")
assert(unfiltered["sub/.backup/source.lua"], "built-in exclusions must be root-only")

local zip = require("lib.zip")
local _, err = zip.create_from_dir("plugin", {
	include = function(path)
		return hashes[path] ~= nil
	end,
	on_progress = function(_, total, phase)
		assert(phase == "read" and total == 8, "ZIP must use the filtered manifest")
		return false
	end
})
assert(err == "cancelled")
print("plugin gitignore tests passed")
