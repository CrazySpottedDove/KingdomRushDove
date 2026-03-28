local M = {}

function M.register(sys, deps)
	local perf = deps.perf
	local band = deps.band
	local bor = deps.bor
	local U = deps.U
	local SU = deps.SU
	local signal = deps.signal
	local E = deps.E
	local queue_remove = deps.queue_remove

	--- 从 damage.source_id 沿 modifier.source_id / bullet.source_id 追溯
	local function damage_trace_bullet_hints(s)
		local b = s.bullet

		if not b then
			return ""
		end

		local bits = {}

		if b.target_id then
			bits[#bits + 1] = "btgt#" .. tostring(b.target_id)
		end

		if b.source_id then
			bits[#bits + 1] = "bsrc#" .. tostring(b.source_id)
		end

		if #bits == 0 then
			return ""
		end

		return "[" .. table.concat(bits, ",") .. "]"
	end

	local function damage_trace_format_source(store, d)
		local entities = store.entities
		local parts = {}
		local sid = d.source_id

		if not sid then
			local o = "source_id=nil"

			if d.damage_trace_origin and d.damage_trace_origin ~= "" then
				o = o .. " || origin:" .. tostring(d.damage_trace_origin)
			end

			if d.damage_trace_extra and d.damage_trace_extra ~= "" then
				o = o .. " || extra:" .. tostring(d.damage_trace_extra)
			end

			return o
		end

		local seen = {}
		local depth = 0

		while sid and depth < 12 do
			if seen[sid] then
				parts[#parts + 1] = string.format("(cycle#%s)", tostring(sid))

				break
			end

			seen[sid] = true
			depth = depth + 1

			local s = entities[sid]

			if not s then
				parts[#parts + 1] = string.format("missing#%s", tostring(sid))

				break
			end

			local tags = {}

			if s.tower then
				tags[#tags + 1] = "tower"
			end

			if s.modifier then
				tags[#tags + 1] = "mod"
			end

			if s.bullet then
				tags[#tags + 1] = "bullet"
			end

			local tag_str = #tags > 0 and ("[" .. table.concat(tags, ",") .. "]") or ""
			local seg = string.format("%s%s#%s", s.template_name or "?", tag_str, tostring(sid))
			local bh = damage_trace_bullet_hints(s)

			if bh ~= "" then
				seg = seg .. bh
			end

			parts[#parts + 1] = seg

			if s.tower_ref and s.tower_ref.id then
				local tw = s.tower_ref

				parts[#parts + 1] = string.format("tower_ref=%s#%s", tw.template_name or "?", tostring(tw.id))
			end

			local next_id

			if s.modifier and s.modifier.source_id then
				next_id = s.modifier.source_id
			elseif s.bullet and s.bullet.source_id then
				next_id = s.bullet.source_id
			else
				break
			end

			sid = next_id
		end

		local out = table.concat(parts, " <- ")

		if out ~= "" and not string.find(out, " <- ", 1, true) and entities[d.source_id] and entities[d.source_id].tower and d.damage_trace_origin ~= "tower_skill_endless" then
			out = out .. " [hint:source is tower only; if unexpected, check modifier/bullet source_id or damage_trace_extra]"
		end

		if d.damage_trace_extra and d.damage_trace_extra ~= "" then
			out = (out ~= "" and out .. " || " or "") .. "extra:" .. tostring(d.damage_trace_extra)
		end

		if d.damage_trace_origin and d.damage_trace_origin ~= "" then
			out = (out ~= "" and out .. " || " or "") .. "origin:" .. tostring(d.damage_trace_origin)
		end

		return out
	end

	--- 是否纳入追溯：默认仅敌人；DEBUG_DAMAGE_TRACE_ALL_TARGETS 时含士兵/英雄等一切带 health 的实体
	local function damage_trace_include_target(e)
		if not e or not e.health then
			return false
		end

		if DEBUG_DAMAGE_TRACE_ALL_TARGETS then
			return true
		end

		return e.enemy ~= nil
	end

	local function damage_trace_target_class(e)
		if not e then
			return "?"
		end

		if e.enemy then
			return "enemy"
		end

		if e.hero then
			return "hero"
		end

		if e.soldier then
			return "soldier"
		end

		if e.tower then
			return "tower"
		end

		return "unit"
	end

	local function damage_trace_investigate_print(store, target, d, val, branch)
		if not DEBUG_DAMAGE_TRACE_INVESTIGATE then
			return
		end

		if not damage_trace_include_target(target) then
			return
		end

		if (branch == "hp" or branch == "eat") and (not val or val <= 0) then
			return
		end

		local e = d.source_id and store.entities[d.source_id]
		local snap = "src_entity=missing"

		if e then
			local twref = ""

			if e.tower_ref and e.tower_ref.id then
				twref = string.format(" twref=%s#%s", tostring(e.tower_ref.template_name), tostring(e.tower_ref.id))
			end

			snap = string.format("src_tpl=%s tw=%s bl=%s mod=%s ray_bullet_id=%s bullet.bsrc=%s bullet.btgt=%s%s", tostring(e.template_name), tostring(e.tower ~= nil), tostring(e.bullet ~= nil), tostring(e.modifier ~= nil), tostring(e.ray_source_bullet_id), tostring(e.bullet and e.bullet.source_id), tostring(e.bullet and e.bullet.target_id), twref)
		end

		print(string.format("[DAMAGE_INVESTIGATE] tick=%.3f branch=%s src_id=%s tgt_kind=%s tgt_id=%s tgt=%s val=%.1f dtype=0x%X origin=%s extra=%s | %s", store.tick_ts, branch, tostring(d.source_id), damage_trace_target_class(target), tostring(d.target_id), target.template_name or "?", val or 0, d.damage_type or 0, tostring(d.damage_trace_origin), tostring(d.damage_trace_extra), snap))

		if e and e.tower and not d.damage_trace_origin then
			print("[DAMAGE_INVESTIGATE] hint: source_id points to TOWER but damage_trace_origin is empty — 请搜 SU.create_attack_damage、mod_dps、无尽技能等")
		end
	end

	--- branch: hp | eat | armor | magic_armor（覆盖 health 系统内各类伤害包）
	local function damage_trace_record_event(store, target, d, branch, val, hp_before, hp_after)
		damage_trace_investigate_print(store, target, d, val, branch)

		if not DEBUG_DAMAGE_TRACE or not damage_trace_include_target(target) then
			return
		end

		local max_h = tonumber(DEBUG_DAMAGE_TRACE_HISTORY) or 32
		local rec = {
			tick_ts = store.tick_ts,
			branch = branch,
			dmg = val,
			hp_before = hp_before,
			hp_after = hp_after,
			dmg_type = d.damage_type,
			src = damage_trace_format_source(store, d),
			damage_trace_extra = d.damage_trace_extra,
			kill = (branch == "hp" or branch == "eat") and hp_before > 0 and hp_after <= 0 or false
		}

		target._damage_trace = target._damage_trace or {}
		local t = target._damage_trace

		t[#t + 1] = rec

		while #t > max_h do
			table.remove(t, 1)
		end

		if DEBUG_DAMAGE_TRACE_ALL_ENEMY_HITS then
			local px = target.pos and target.pos.x or 0
			local py = target.pos and target.pos.y or 0
			local cls = damage_trace_target_class(target)

			print(string.format("[DAMAGE_TRACE] %s %s#%s pos=(%.0f,%.0f) branch=%s val=%.1f hp %d->%d dtype=0x%X | %s", cls, target.template_name or "?", tostring(target.id), px, py, branch, val or 0, hp_before, hp_after, d.damage_type or 0, rec.src))
		end
	end

	local function damage_trace_print_death(store, target)
		if not DEBUG_DAMAGE_TRACE or not damage_trace_include_target(target) then
			return
		end

		local t = target._damage_trace

		if not t or #t == 0 then
			return
		end

		local cls = damage_trace_target_class(target)

		print(string.format("[DAMAGE_TRACE] ========== death %s %s#%s ==========", cls, target.template_name or "?", tostring(target.id)))

		for i = 1, #t do
			local r = t[i]

			print(string.format("  [%d] tick=%.3f branch=%s val=%.1f hp %d->%d dtype=0x%X kill=%s | %s", i, r.tick_ts, tostring(r.branch), r.dmg, r.hp_before, r.hp_after, r.dmg_type or 0, tostring(r.kill), r.src))
		end

		print("[DAMAGE_TRACE] ========== end death trace ==========")
	end

	sys.health = {}
	sys.health.name = "health"

	function sys.health:init(store)
		store.damage_queue = {}
		store.damages_applied = {}
	end

	function sys.health:on_insert(entity, store)
		if entity.health and not entity.health.hp then
			entity.health.hp = entity.health.hp_max
		end

		return true
	end

	function sys.health:on_update(dt, ts, store)
		perf.start("health")
		local new_damage_queue = {}
		local damage_queue = store.damage_queue
		local damages_applied = {}
		local damages_applied_count = 0
		local entities = store.entities
		local damage_queue_len = #damage_queue
		for i = damage_queue_len, 1, -1 do
			local d = damage_queue[i]
			local e = entities[d.target_id]

			if e then
				local h = e.health

				if not (h.dead or band(h.immune_to, d.damage_type) ~= 0 or h.ignore_damage or h.on_damage and not h.on_damage(e, store, d)) then
					local starting_hp = h.hp

					h.last_damage_types = bor(h.last_damage_types, d.damage_type)

					if band(d.damage_type, DAMAGE_EAT) ~= 0 then
						local eat_amt = h.hp

						d.damage_applied = eat_amt
						d.damage_result = bor(d.damage_result, DR_KILL)
						damage_trace_record_event(store, e, d, "eat", eat_amt, starting_hp, 0)
						h.hp = 0
						damages_applied_count = damages_applied_count + 1
						damages_applied[damages_applied_count] = d
					elseif band(d.damage_type, DAMAGE_ARMOR) ~= 0 then
						SU.armor_dec(e, d.value)
						d.damage_result = bor(d.damage_result, DR_ARMOR)
						damage_trace_record_event(store, e, d, "armor", d.value, h.hp, h.hp)
					elseif band(d.damage_type, DAMAGE_MAGICAL_ARMOR) ~= 0 then
						SU.magic_armor_dec(e, d.value)
						d.damage_result = bor(d.damage_result, DR_MAGICAL_ARMOR)
						damage_trace_record_event(store, e, d, "magic_armor", d.value, h.hp, h.hp)
					else
						local actual_damage = U.predict_damage(e, d)

						h.hp = h.hp - actual_damage
						d.damage_applied = actual_damage
						damage_trace_record_event(store, e, d, "hp", actual_damage, starting_hp, h.hp)

						if starting_hp > 0 and h.hp <= 0 then
							d.damage_result = bor(d.damage_result, DR_KILL)
						end

						if actual_damage > 0 then
							d.damage_result = bor(d.damage_result, DR_DAMAGE)

							if e.regen then
								e.regen.last_hit_ts = store.tick_ts
							end

							if d.track_damage then
								signal.emit("entity-damaged", e, d)

								local source = entities[d.source_id]

								if source and source.track_damage then
									table.insert(source.track_damage.damaged, {e.id, actual_damage})
								end
							end
						end

						if h.spiked_armor > 0 and e.soldier and d.source_id and e.soldier.target_id == d.source_id then
							local t = entities[d.source_id]

							if t and t.health and not t.health.dead then
								local sad = E:create_entity("damage")

								sad.damage_type = DAMAGE_TRUE
								sad.value = h.spiked_armor * d.value
								sad.source_id = e.id
								sad.target_id = t.id
								new_damage_queue[#new_damage_queue + 1] = sad
							end
						end

						damages_applied_count = damages_applied_count + 1
						damages_applied[damages_applied_count] = d
					end

					if starting_hp > 0 and h.hp <= 0 then
						signal.emit("entity-killed", e, d)

						if d.track_kills then
							local source = entities[d.source_id]

							if source and source.track_kills then
								table.insert(source.track_kills.killed, e.id)
							end
						end
					end
				end
			end
		end

		local enemies = store.enemies
		local soldiers = store.soldiers

		for _, e in pairs(enemies) do
			local h = e.health

			if h.hp <= 0 and not h.dead and not h.ignore_damage then
				damage_trace_print_death(store, e)
				h.hp = 0
				h.dead = true
				h.death_ts = store.tick_ts
				h.delete_after = store.tick_ts + h.dead_lifetime

				if e.health_bar then
					e.health_bar.hidden = true
				end

				store.player_gold = store.player_gold + e.enemy.gold
				signal.emit("got-enemy-gold", e, e.enemy.gold)
			end

			if not h.dead then
				h.last_damage_types = 0
			elseif not h.ignore_delete_after and (h.delete_after and store.tick_ts > h.delete_after or h.delete_now) then
				queue_remove(store, e)
			end
		end

		for _, e in pairs(soldiers) do
			local h = e.health

			if h.hp <= 0 and not h.dead and not h.ignore_damage then
				damage_trace_print_death(store, e)
				h.hp = 0
				h.dead = true
				h.death_ts = store.tick_ts
				h.delete_after = store.tick_ts + h.dead_lifetime

				if e.health_bar then
					e.health_bar.hidden = true
				end
			end

			if not h.dead then
				h.last_damage_types = 0
			elseif not e.hero and not h.ignore_delete_after and (h.delete_after and store.tick_ts > h.delete_after or h.delete_now) then
				queue_remove(store, e)
			end
		end

		store.damage_queue = new_damage_queue

		for i = damage_queue_len + 1, #damage_queue do
			new_damage_queue[#new_damage_queue + 1] = damage_queue[i]
		end

		store.damages_applied = damages_applied
		perf.stop("health")
	end
end

return M
