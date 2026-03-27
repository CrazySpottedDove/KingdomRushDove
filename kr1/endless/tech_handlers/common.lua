local Common = {}

function Common.queue_insert(store, entity)
	simulation:queue_insert_entity(entity)
end

function Common.queue_remove(store, entity)
	simulation:queue_remove_entity(entity)
end

function Common.queue_damage(store, damage)
	store.damage_queue[#store.damage_queue + 1] = damage
end

function Common.remove_upgrade_group(endless, names)
	for _, name in pairs(names) do
		table.removeobject(endless.upgrade_options, name)
		table.removeobject(endless.gold_extra_upgrade_options, name)
	end
end

return Common
