local enemy_mixed = {}
local CU = require("precompile.compile_utils")
CU.define("y_enemy_walk_until_blocked", [=[
function(store, this)
    local blocker

    @constif(this.ranged)
    local ranged

	local terrain_type = band(GR:cell_type(this.pos.x, this.pos.y), bor(TERRAIN_WATER, TERRAIN_LAND))

    @constif(this.ranged)
    while not blocker and not ranged do
    @constelse
    while not blocker do

		if this.unit.is_stunned then
			return false
		end

		if this.health.dead then
			return false
		end

        constif(this.ranged)
        if P:is_node_valid(this.nav_path.pi, this.nav_path.ni) then
            if this.enemy.can_do_magic and store.tick_ts - this.ranged.last_range_ts > 0.1 then
                constfor i = 1, #this.ranged.attacks do
                    local a = this.ranged.attacks[i]

                    @constif(this.ranged.attacks[i].hold_advance)
                    if not a.disabled then
                    @constelse
                    if not a.disabled and store.tick_ts - a.ts > a.cooldown then
                        ranged = U.find_nearest_soldier(store.soldiers, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

                        if ranged then
                            constbreak

                        constif(not this.ranged.attacks[i].hold_advance)
                        else
                            a.ts = a.ts + 0.1
                        constend

                        end
                    end
                constend
                if not ranged then
                    this.ranged.last_range_ts = store.tick_ts
                end
            end
            if #this.enemy.blockers > 0 then
                U.cleanup_blockers(store, this)

                blocker = store.entities[this.enemy.blockers[1]]
            end
        end
        constelse
        if #this.enemy.blockers > 0 and P:is_node_valid(this.nav_path.pi, this.nav_path.ni) then
            U.cleanup_blockers(store, this)

            blocker = store.entities[this.enemy.blockers[1]]
        end
        constend

        @constif(this.ranged)
        if not blocker and not ranged then
        @constelse
        if not blocker then

			SU.y_enemy_walk_step_default(store, this)
		else
			U.animation_start_default(this, "idle", nil, store.tick_ts, true)
		end

		if terrain_type ~= band(GR:cell_type(this.pos.x, this.pos.y), bor(TERRAIN_WATER, TERRAIN_LAND)) then
			return false
		end
	end

    @constif(this.ranged)
    return true, blocker, ranged
    @constelse
    return true, blocker
end
]=])

enemy_mixed.update = [[
return function(this, store)
	if this.render.sprites[1].name == "raise" then

        @constif(this.sound_events and this.sound_events.raise)
        S:queue(this.sound_events.raise, this.sound_events.raise_args)

		this.health_bar.hidden = true
		local an, af = U.animation_name_facing_point(this, "raise", this.motion.dest)

		U.y_animation_play(this, an, af, store.tick_ts, 1)

		if not this.health.dead then
			this.health_bar.hidden = nil
		end
	end

	::label_25_0::

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		else

            @constif(this.ranged)
            local cont, blocker, ranged = template y_enemy_walk_until_blocked(store, this)
            @constelse
            local cont, blocker = template y_enemy_walk_until_blocked(store, this)

            if cont then
                if blocker then
                    if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_25_0
					end

					while SU.can_melee_blocker(store, this, blocker) do
                        constif(this.ranged and this.ranged.range_while_blocking)
                        if ranged then
                            SU.y_enemy_range_attacks(store, this, ranged)
                        end
                        constend

						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_25_0
						end

						coroutine.yield()
					end

                constif(this.ranged)
                elseif ranged then
                    while SU.can_range_soldier(store, this, ranged) and #this.enemy.blockers == 0 do
						if not SU.y_enemy_range_attacks(store, this, ranged) then
							goto label_25_0
						end

						coroutine.yield()
					end
                constend

                end

                coroutine.yield()
            end
		end
	end
end
]]
return enemy_mixed
