local io = {}
local sio = require("all.storage_io_generic")
local update_config_template = require("dove_modules.updater.update_config_template")

function io.load()
	local ok, update_config = sio:load_file("update_config.lua")
	if not ok or not update_config then
		print("update_config.lua not found, use default.")
		return update_config_template
	end
	for k, v in pairs(update_config_template) do
		if not update_config[k] then
			update_config[k] = v
		end
	end
	return update_config
end

function io.save(update_config)
	local ok = sio:write_file("update_config.lua", update_config)

	if not ok then
		print("Error writing update_config")
	end

	return ok
end

return io
