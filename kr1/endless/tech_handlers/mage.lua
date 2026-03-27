local E = require("entity_db")
local U = require("utils")
local V = require("lib.klua.vector")
local UP = require("kr1.upgrades")
local Common = require("kr1.endless.tech_handlers.common")

local function patch_mage_thunder(level, ctx)
	for _, name in pairs(table.append(UP.bolts, {"ray_arcane_disintegrate", "bullet_tower_ray_lvl4"}, true)) do
		local bolt = E:get_template(name)

		if not bolt._endless_mage_thunder then
			bolt._endless_mage_thunder = true

			if (bolt.bullet and bolt.bullet.damage_max and bolt.bullet.damage_max >= 50) or bolt.template_name == "ray_arcane" then
				bolt.main_script.insert = U.function_append(bolt.main_script.insert, function(this, store)
					local target = store.entities[this.bullet.target_id]

					if not target or target.health.dead then
						return true
					end

					if math.random() < store.endless.upgrade_levels.mage_thunder * ctx.friend_buff.mage_thunder_normal then
						local thunder = E:create_entity("endless_mage_thunder")
						thunder.pos = V.vclone(target.pos)
						Common.queue_insert(store, thunder)
					end

					return true
				end)
			else
				bolt.main_script.insert = U.function_append(bolt.main_script.insert, function(this, store)
					local target = store.entities[this.bullet.target_id]

					if not target or target.health.dead then
						return true
					end

					if math.random() < store.endless.upgrade_levels.mage_thunder * ctx.friend_buff.mage_thunder_small then
						local thunder = E:create_entity("endless_mage_thunder")
						thunder.pos = V.vclone(target.pos)
						Common.queue_insert(store, thunder)
					end

					return true
				end)
			end
		end
	end

	local mod_pixie_pickpocket = E:get_template("mod_pixie_pickpocket")

	if not mod_pixie_pickpocket._endless_mage_thunder then
		mod_pixie_pickpocket._endless_mage_thunder = true
		mod_pixie_pickpocket.main_script.insert = U.function_append(mod_pixie_pickpocket.main_script.insert, function(this, store)
			local target = store.entities[this.modifier.target_id]

			if not target or target.health.dead then
				return true
			end

			if math.random() < store.endless.upgrade_levels.mage_thunder * ctx.friend_buff.mage_thunder_normal then
				local thunder = E:create_entity("endless_mage_thunder")
				thunder.pos = V.vclone(target.pos)
				Common.queue_insert(store, thunder)
			end

			return true
		end)
	end
end

local function patch_mage_shatter(level, ctx)
	for _, name in pairs(table.append(UP.bolts, {"bullet_pixie_poison"}, true)) do
		local bolt = E:get_template(name)

		if not bolt._endless_mage_shatter then
			bolt._endless_mage_shatter = true
			bolt.main_script.insert = U.function_append(bolt.main_script.insert, function(this, store)
				local target = store.entities[this.bullet.target_id]

				if not target or target.health.dead then
					return true
				end

				if not this.bullet._endless_mage_shatter then
					this.bullet.damage_factor = this.bullet.damage_factor * (1 + target.health.armor * store.endless.upgrade_levels.mage_shatter * ctx.friend_buff.mage_shatter)
					this.bullet._endless_mage_shatter = true
				end

				return true
			end)
		end
	end
end

local function patch_mage_chain(level, ctx)
	for _, name in pairs(table.append(UP.bolts, {"bullet_pixie_poison", "bullet_pixie_instakill", "ray_arcane_disintegrate"}, true)) do
		local bolt = E:get_template(name)

		if not bolt._endless_mage_chain then
			bolt._endless_mage_chain = true
			bolt.main_script.remove = U.function_append(bolt.main_script.remove, function(this, store)
				local target = store.entities[this.bullet.target_id]

				if not target or target.health.dead then
					return true
				end

				if not this.bullet._endless_mage_chain then
					local enemies = U.find_enemies_in_range_filter_on(target.pos, ctx.friend_buff.mage_chain_radius, F_RANGED, 0, function(e)
						return e.id ~= target.id
					end)

					if enemies then
						for i = 1, #enemies do
							local enemy = enemies[i]
							local new_bolt = E:create_entity(this.template_name)

							new_bolt.bullet.target_id = enemy.id
							new_bolt.bullet.from = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
							new_bolt.pos = V.vclone(new_bolt.bullet.from)
							new_bolt.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
							new_bolt.bullet.damage_factor = new_bolt.bullet.damage_factor * ctx.friend_buff.mage_chain * store.endless.upgrade_levels.mage_chain
							new_bolt.bullet._endless_mage_chain = true

							if new_bolt.tween then
								new_bolt.tween.ts = store.tick_ts
							end

							if this.bullet.payload then
								local payload = E:create_entity(this.bullet.payload.template_name)

								if payload.bullet then
									payload.bullet.level = this.bullet.payload.bullet.level
									payload.bullet.damage_factor = this.bullet.payload.bullet.damage_factor
								end

								new_bolt.bullet.payload = payload
							end

							if this.bullet.shot_index then
								new_bolt.bullet.shot_index = this.bullet.shot_index
							end

							Common.queue_insert(store, new_bolt)
						end
					end
				end

				return true
			end)
		end
	end
end

local function patch_mage_curse(level, ctx)
	local curse = E:get_template("mod_slow_curse")
	curse.slow.factor = ctx.friend_buff.mage_curse_factor
	curse.slow.duration = ctx.friend_buff.mage_curse_duration
end

local function register_mage_techs(registry, ctx)
	registry.register({
		id = "mage_thunder",
		group = "mage",
		apply_template = function(level, endless)
			patch_mage_thunder(level, ctx)
		end,
		apply_runtime = function(level, store, endless)
			patch_mage_thunder(level, ctx)
		end,
	})

	registry.register({
		id = "mage_shatter",
		group = "mage",
		apply_template = function(level, endless)
			patch_mage_shatter(level, ctx)
		end,
		apply_runtime = function(level, store, endless)
			patch_mage_shatter(level, ctx)
		end,
	})

	registry.register({
		id = "mage_chain",
		group = "mage",
		apply_template = function(level, endless)
			patch_mage_chain(level, ctx)
		end,
		apply_runtime = function(level, store, endless)
			patch_mage_chain(level, ctx)
		end,
	})

	registry.register({
		id = "mage_curse",
		group = "mage",
		apply_template = function(level, endless)
			patch_mage_curse(level, ctx)
		end,
		apply_runtime = function(level, store, endless)
			patch_mage_curse(level, ctx)
		end,
	})
end

return {
	register = register_mage_techs,
}
