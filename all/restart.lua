local storage = require("all.storage")
local restart = {}

function restart.tmp()
	main.params.tmp_restart = true
	storage:save_settings(main.params)
	love.event.quit("restart")
end

function restart.full()
	love.event.quit("restart")
end

return restart
