local enemy_passive = {}

-- enemy_passive 没有 insert（沿用 enemy_basic 的 insert）
-- 只有 update

enemy_passive.update = [[
return function(this, store)
	local terrain_type

	if this.render.sprites[1].name == "raise" then
		local next_pos

		if this.motion.forced_waypoint then
			next_pos = this.motion.forced_waypoint
		else
			next_pos = P:next_entity_node(this, store.tick_length)
		end

		local an, af = U.animation_name_facing_point(this, "raise", next_pos)

		U.y_animation_play(this, an, af, store.tick_ts, 1)
	end

	while true do
		constif(this.cliff)
		terrain_type = SU.enemy_cliff_change(store, this)
		constend

		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			-- passive 敌人不会攻击，这里直接排除所有分支
			SU.y_enemy_walk_until_blocked_off__ignore_soldiers__func__ranged(store, this)
		end
	end
end
]]

return enemy_passive
