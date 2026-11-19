local M = {}

local ASSETS = "assets"

local function q(s)
	return string.format("%q", s)
end

local function run(cmd)
	local p = assert(io.popen(cmd .. " 2>&1"))
	local out = p:read("*a") or ""
	local ok = p:close()
	return ok == true or ok == 0, out
end

local function git(args)
	return run("git -C " .. q(ASSETS) .. " " .. args)
end

local function has_repo()
	local f = io.open(ASSETS .. "/.git/HEAD", "rb")
	if f then
		f:close()
		return true
	end
	return false
end

function M.status()
	if not has_repo() then
		return false, "assets/ 不是 git 仓库"
	end
	local ok, out = git("status --porcelain")
	if not ok then
		return false, out
	end
	if out:gsub("%s+", "") == "" then
		print("assets: clean")
	else
		print("assets: dirty")
		io.write(out)
	end
	return true
end

function M.commit(main_commit, force_empty)
	if not has_repo() then
		return false, "assets/ 不是 git 仓库"
	end
	if not main_commit or main_commit == "" then
		return false, "缺少主仓库 commit hash"
	end
	local ok, out = git("add -A")
	if not ok then
		return false, out
	end
	local clean, _ = git("diff --cached --quiet")
	if clean then
		if force_empty then
			local okc, outc = git("commit --allow-empty -m " .. q(main_commit))
			if not okc then
				return false, outc
			end
		end
		local head_ok, head = git("rev-parse HEAD")
		if head_ok then
			head = head:gsub("%s+", "")
			local ref_ok, ref_out = git("update-ref refs/main/" .. main_commit .. " " .. head)
			if not ref_ok then
				return false, ref_out
			end
		end
		if force_empty then
			print("assets: empty commit recorded, ref updated")
		else
			print("assets: no changes, ref updated")
		end
		return true
	end
	local msg = main_commit
	local okc, outc = git("commit -m " .. q(msg))
	if not okc then
		return false, outc
	end
	local head_ok, head = git("rev-parse HEAD")
	if not head_ok then
		return false, head
	end
	head = head:gsub("%s+", "")
	local ref_ok, ref_out = git("update-ref refs/main/" .. main_commit .. " " .. head)
	if not ref_ok then
		return false, ref_out
	end
	print("assets: committed " .. head .. " for main " .. main_commit)
	return true
end

function M.checkout(main_commit)
	if not has_repo() then
		return false, "assets/ 不是 git 仓库"
	end
	if not main_commit or main_commit == "" then
		return false, "缺少主仓库 commit hash"
	end
	local ok, out = git("rev-parse --verify refs/main/" .. main_commit)
	local target
	if ok then
		target = out:gsub("%s+", "")
	else
		local ok2, out2 = git("log --all --format=%H --grep=^" .. main_commit .. "$ -n 1")
		if ok2 then
			target = out2:gsub("%s+", "")
		end
	end
	if not target or target == "" then
		return false, "assets 仓库中找不到主仓库 commit " .. main_commit
	end
	local okc, outc = git("checkout " .. target)
	if not okc then
		return false, outc
	end
	print("assets: checked out " .. target)
	return true
end

local function main(args)
	local cmd = args[1]
	if cmd == "status" then
		local ok, err = M.status()
		if not ok then
			io.stderr:write(tostring(err) .. "\n")
			os.exit(1)
		end
	elseif cmd == "commit" then
		local force_empty = args[3] == "--force-empty"
		local ok, err = M.commit(args[2], force_empty)
		if not ok then
			io.stderr:write("assets commit failed: " .. tostring(err) .. "\n")
			os.exit(1)
		end
	elseif cmd == "checkout" then
		local ok, err = M.checkout(args[2])
		if not ok then
			io.stderr:write("assets checkout failed: " .. tostring(err) .. "\n")
			os.exit(1)
		end
	else
		print("用法: repo.lua status|commit <main_commit>|checkout <main_commit>")
		os.exit(1)
	end
end

if arg and arg[0] and arg[0]:match("repo%.lua$") then
	main(arg)
end

return M
