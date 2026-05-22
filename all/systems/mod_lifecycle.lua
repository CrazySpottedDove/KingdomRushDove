local M = {}

function M.register(sys)
	local table_contains = table.contains
	local function queue_remove(store, e)
		simulation:queue_remove_entity(e)
	end

	sys.mod_lifecycle = {}
	sys.mod_lifecycle.name = "mod_lifecycle"

	function sys.mod_lifecycle:on_insert(entity, store)
		local mdf = entity.modifier

		if not mdf then
			return true
		end

		local this = entity
		local target_id = mdf.target_id
		local target = store.entities[target_id]

		if not target then
			return false
		end

		if not target._applied_mods then
			target._applied_mods = {}
		end

		local modifiers = target._applied_mods

		for i = 1, #modifiers do
			local m = modifiers[i].modifier

			if m.bans and table_contains(m.bans, this.template_name) then
				return false
			end
		end

		if mdf.remove_banned then
			for i = 1, #modifiers do
				local m = modifiers[i]
				local mm = m.modifier

				if mdf.bans and table_contains(mdf.bans, m.template_name) then
					mm.removed_by_ban = true
					queue_remove(store, m)
				end

				if mdf.ban_types and table_contains(mdf.ban_types, mm.type) then
					mm.removed_by_ban = true
					queue_remove(store, m)
				end
			end
		end

		-- if mdf.allows_duplicates then
		-- return true
		-- end
		mdf.ts = store.tick_ts

		if this.render then
			for i = 1, #this.render.sprites do
				this.render.sprites[i].ts = store.tick_ts
			end
		end

		for i = 1, #modifiers do
			local m = modifiers[i]

			if m.template_name == this.template_name then
				if mdf.level == m.modifier.level then
					-- 这段代码正常工作，建立在 modifiers 的顺序不会改变的基础上
					if m.max_duplicates then
						if m.max_duplicates == 0 then
							if mdf.replaces_lower then
								if this.render then
									for j = 1, #this.render.sprites do
										this.render.sprites[j].ts = m.render.sprites[1].ts
									end
								end
								queue_remove(store, m)
								return true
							else
								return false
							end
						end

						m.max_duplicates = m.max_duplicates - 1

						if m.dps then
							m.dps.fx = nil
						end

						if m.render then
							for i = 1, #m.render.sprites do
								m.render.sprites[i].hidden = true
								this.render.sprites[i].ts = m.render.sprites[i].ts
							end
						end
					elseif mdf.allows_duplicates then
						if m.dps then
							m.dps.fx = nil
						end
						if m.render then
							for i = 1, #m.render.sprites do
								m.render.sprites[i].hidden = true
								this.render.sprites[i].ts = m.render.sprites[i].ts
							end
						end
					else
						return false
					end
				elseif mdf.level > m.modifier.level and mdf.replaces_lower then
					if m.render then
						for i = 1, #this.render.sprites do
							this.render.sprites[i].ts = m.render.sprites[i].ts
						end
					end

					queue_remove(store, m)
				elseif mdf.level == m.modifier.level and mdf.resets_same then
					m.modifier.ts = store.tick_ts

					if mdf.resets_same_tween and m.tween then
						m.tween.ts = store.tick_ts - (mdf.resets_same_tween_offset or 0)
					end

					return false
				else
					return false
				end
			end
		end

		return true
	end
end

return M
