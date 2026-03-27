local M = {}

function M.register(sys, deps)
	local E = deps.E
	local LU = deps.LU

	sys.editor_overrides = {}
	sys.editor_overrides.name = "editor_overrides"

	function sys.editor_overrides:on_insert(entity, store)
		if not entity.editor then
			return true
		end

		local editor = entity.editor

		if editor.components then
			for _, c in pairs(editor.components) do
				E:add_comps(entity, c)
			end
		end

		if editor.overrides then
			for k, v in pairs(editor.overrides) do
				LU.eval_set_prop(entity, k, v)
			end
		end

		return true
	end
end

return M
