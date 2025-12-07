-- chunkname: @./lib/klua/lfs.lua
local success, lfs = pcall(require, "lfs")
lfs = success and lfs or nil

if lfs then
	function dirmatching(dirpath, filter)
		filter = filter or ".*"
		local lfsIter, lfsDirObj = lfs.dir(dirpath)
		local isLambda = type(filter) == "function"

		local function iter()
			repeat
				local fn = lfsIter(lfsDirObj)

				if fn and (isLambda and filter(fn) or not isLambda and string.match(fn, filter)) then
					return fn
				end
			until not fn
		end

		return iter
	end
end
