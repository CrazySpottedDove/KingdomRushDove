local enemy_mixed = {}
local CU = require("precompile.compile_utils")

CU.define("y_enemy_walk_step_default", [=[
function(store, this)
	local next
	local step = this.motion.real_speed * store.tick_length
	local m = this.motion
	local pos = this.pos

	if m.forced_waypoint then
		local w = m.forced_waypoint
		local dx = w.x - pos.x
		local dy = w.y - pos.y
		if math.sqrt(dx * dx + dy * dy) < 2 * step then
			pos.x, pos.y = w.x, w.y
			m.forced_waypoint = nil

			return
		end
		next = w
	else
		local n = this.nav_path
		local path = P.paths[n.pi][n.spi]
		next = path[n.ni + n.dir]

		if not next or math.sqrt((next.x - pos.x) * (next.x - pos.x) + (next.y - pos.y) * (next.y - pos.y)) < 2 * step then
			n.ni = n.ni + n.dir

			if n.ni < 1 or n.ni > #path then
				if P.path_connections[n.pi] and n.dir > 0 then
					local newni = P.path_connections_spi_to_ni[n.pi][n.spi]

					n.pi = P.path_connections[n.pi]
					n.ni = newni + n.dir
					path = P.paths[n.pi][n.spi]
				else
					coroutine.yield()
					return
				end
			end

			@constif(this.sound_events and this.sound_events.new_node)
			S:queue(this.sound_events.new_node, this.sound_events.new_node_args)

			next = path[n.ni + n.dir]
		end

		if not next then
			coroutine.yield()
			return
		end
	end

	m.dest.x, m.dest.y = next.x, next.y
	m.arrived = false

	local dx, dy = next.x - pos.x, next.y - pos.y
	local an
    local af = false
	do
        constvar _sprite = this.render.sprites[1]
        constvar _angles = this.render.sprites[1].angles and this.render.sprites[1].angles.walk

		constif(_angles)
    		local _sprite = this.render.sprites[1]
            local _angles = _sprite.angles.walk
            constvar _angle_count = #this.render.sprites[1].angles.walk
            constif(_angle_count == 1)
                an, af = _angles[1], dx < 0
            constelseif(_angle_count == 2)
                local _coordinate_idx = dy > 0 and 1 or 2
				an = _angles[_coordinate_idx]
                @constif(this.render.sprites[1].angles_flip_horizontal)
                af = _sprite.angles_flip_horizontal[_coordinate_idx] and (dx >= 0) or (dx < 0)
                @constelse
                af = dx < 0
            constelse
                local _angle = math.atan2(dy, dx) % 6.2831853071795862
				local _coordinate_idx = 1

				@constif(_sprite.angles_custom and _sprite.angles_custom.walk)
				local _a1, _a2, _a3, _a4 = _sprite.angles_custom["walk"][1], _sprite.angles_custom["walk"][2], _sprite.angles_custom["walk"][3], _sprite.angles_custom["walk"][4]
                @constelse
				local _a1, _a2, _a3, _a4 = 45, 135, 225, 315

                @constif(_sprite.angles_stickiness and _sprite.angles_stickiness.walk)
				local _stickiness = _sprite.angles_stickiness["walk"]

				local _angle_deg = _angle * 57.295779513082323

				constif(_sprite.angles_stickiness and _sprite.angles_stickiness.walk)
					local _skew_factor = _sprite._last_skew_factor
					if _skew_factor then
						local _skew = _stickiness * _skew_factor
						_a1, _a3 = _a1 - _skew, _a3 - _skew
						_a2, _a4 = _a2 + _skew, _a4 + _skew
					end
					if _a1 <= _angle_deg and _angle_deg < _a2 then
						_coordinate_idx = 2
						_sprite._last_skew_factor = 1
					elseif _a3 <= _angle_deg and _angle_deg < _a4 then
						_coordinate_idx = 3
						_sprite._last_skew_factor = 1
					else
						_sprite._last_skew_factor = -1
						if dx < 0 then
							af = true
						end
					end
				constelse
					if _a1 <= _angle_deg and _angle_deg < _a2 then
						_coordinate_idx = 2
					elseif _a3 <= _angle_deg and _angle_deg < _a4 then
						_coordinate_idx = 3
					elseif dx < 0 then
						af = true
					end
				constend

				@constif(_sprite.angles_flip_vertical and _sprite.angles_flip_vertical["walk"])
				af = dx < 0

				an = _angles[_coordinate_idx]
            constend
		constelse
			an, af = "walk", dx < 0
		constend
	end

	constfor i = 1, #this.render.sprites do
		local a = this.render.sprites[i]

		constif(not this.render.sprites[i].ignore_start)
			a.flip_x = af

			if a.animated then
				a.loop = true
				a.name = an
			end
		constend
	constend

	if dx * dx + dy * dy <= step * step and not (this.teleport and this.teleport.pending) then
		pos.x, pos.y = m.dest.x, m.dest.y
		m.speed.x, m.speed.y = 0, 0
		m.arrived = true
	else
		local v_angle = math.atan2(dy, dx)

		@constif(this.heading)
		this.heading.angle = v_angle

		local sx, sy = step * math.cos(v_angle), step * math.sin(v_angle)
		pos.x, pos.y = pos.x + sx, pos.y + sy
		m.speed.x, m.speed.y = sx / store.tick_length, sy / store.tick_length
	end

	coroutine.yield()

	m.speed.x, m.speed.y = 0, 0

	return
end
]=])

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

		if this.unit.is_stunned or this.health.dead then
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

			-- 实验性功能：template y_enemy_walk_step_default(store, this)
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
