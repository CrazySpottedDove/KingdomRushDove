-- chunkname: @./lib/klua/shell.lua
local klog = require("lib.klua.log"):new("klog.shell")
local lfs = require("lfs")

require("lib.klua.table")
require("lib.klua.string")

local shell = {}

shell.DIR_SEP = "/"
shell.DRY_RUN = nil

function shell.has_arg(arg, key)
	return table.contains(arg, "-" .. key)
end

function shell.argv(arg, key)
	return arg[table.keyforobject(arg, "-" .. key) + 1]
end

function shell.path(...)
	return table.concat({...}, shell.DIR_SEP)
end

function shell.run(...)
	local cmd = string.format(...)

	if shell.DRY_RUN then
		klog.error("dry run cmd: %s", cmd)

		return true
	end

	local ret = os.execute(cmd)

	if ret ~= true then
		klog.error("error %s executing %s", ret, cmd)
		os.exit(-1)
	end

	return true
end

function shell.run_no_fail(...)
	local cmd = string.format(...)

	if shell.DRY_RUN then
		klog.error("dry run cmd: %s", cmd)

		return true
	end

	local ret = os.execute(cmd)

	if ret ~= true then
		klog.debug("ignoring error %s executing %s", ret, cmd)
	end

	return true
end

function shell.runget(...)
	local cmd = string.format(...)

	if shell.DRY_RUN then
		klog.error("dry run cmd: %s", cmd)

		return
	end

	local h = io.popen(cmd)

	if not h then
		klog.error("error executing %s", cmd)
		os.exit(-1)
	end

	local out = h:read("*a")

	out = string.gsub(out, "\n$", "")

	h:close()

	return out
end

function shell.is_file(file)
	local t, msg = lfs.attributes(file)

	if t == nil then
		klog.debug("could not find file %s: %s", file, msg)

		return false
	else
		return t.mode == "file"
	end
end

function shell.is_dir(dir)
	local t, msg = lfs.attributes(dir)

	if t == nil then
		klog.debug("could not find dir %s: %s", dir, msg)

		return false
	else
		return t.mode == "directory"
	end
end

function shell.rm(file)
	klog.info("rm \"%s\"", file)
	shell.run("rm \"%s\"", file)
end

function shell.rmdir(dir)
	if dir ~= "" and dir ~= "/" then
		klog.info("rmdir \"%s\"", dir)
		shell.run("rm -rf \"%s\"", dir)
	end
end

function shell.mkdir(dir)
	if dir ~= "" and dir ~= "/" and dir ~= "~" then
		klog.info("mkdir -p \"%s\"", dir)
		shell.run("mkdir -p \"%s\"", dir)
	end
end

function shell.rsync(src, dst, args)
	shell.run("rsync -r %s \"%s\" \"%s\"", args or "", src, dst)
end

function shell.cp(src, dst, nofail)
	if nofail == nil or shell.is_file(src) then
		shell.run("cp \"%s\" \"%s\"", src, dst)
	end
end

function shell.mv(src, dst)
	shell.run("mv \"%s\" \"%s\"", src, dst)
end

function shell.echo(str, file, append)
	local h = io.open(file, append and "wa" or "w")

	if not h then
		klog.error("echo error: could not open %s for writing", file)

		return
	end

	h:write(str)
	h:close()
end

function shell.read(file)
	local h = io.open(file, "r")

	if not h then
		klog.error("read error: could not open %s for reading", file)

		return
	end

	local out = h:read("*a")

	h:close()

	return out
end

function shell.find_files(dir, pattern, out, flat)
	if out == nil then
		klog.error("find_files(): output table parameter missing")
		os.exit(-1)
	end

	for file in lfs.dir(dir) do
		if file == ".." or file == "." then
		-- block empty
		else
			local fullname = dir .. shell.DIR_SEP .. file
			local attr = lfs.attributes(fullname)

			if attr.mode == "directory" and not flat then
				find_files(fullname, pattern, out)
			elseif attr.mode == "file" and (not pattern or string.match(file, pattern)) then
				table.insert(out, fullname)
			end
		end
	end
end

function shell.ls_dir(path)
	local out = {}

	for file in lfs.dir(path) do
		if file == ".." or file == "." then
		-- block empty
		else
			local fullname = shell.path(path, file)
			local attr = lfs.attributes(fullname)

			if attr.mode == "directory" then
				table.insert(out, file)
			end
		end
	end

	return out
end

function shell.zip(src, dst)
	local cwd = lfs.currentdir()

	lfs.chdir(src)
	klog.info("zipping \"%s\" to \"%s\"...", src, dst)
	shell.run("zip -9 -q -r %s .", dst)
	lfs.chdir(cwd)
end

return shell
