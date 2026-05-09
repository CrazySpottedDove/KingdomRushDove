local enemy_basic = {}
enemy_basic.insert = [[
return function(this, store)
    local next, new = P:next_entity_node(this, store.tick_length)

    if not next then
        return false
    end

    U.set_destination(this, next)
    U.set_heading(this, next)

    if this.pos.x == 0 and this.pos.y == 0 then
        this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
    end

    constif(this.render)
        constfor i = 1, #this.render.sprites do
            this.render.sprites[i].ts = store.tick_ts
        constend
    constend

    constif(this.melee)
        conststmt(this.melee.order = U.attack_order(this.melee.attacks))
        constfor i = 1, #this.melee.attacks do
            this.melee.attacks[i].ts = store.tick_ts
        constend
    constend

    constif(this.ranged)
        conststmt(this.ranged.order = U.attack_order(this.ranged.attacks))
        constfor i = 1, #this.ranged.attacks do
            this.ranged.attacks[i].ts = store.tick_ts
        constend
    constend

    constif(this.auras)
        constfor i = 1, #this.auras.list do
            local a = this.auras.list[i]
            a.ts = store.tick_ts
            if a.cooldown == 0 then
                local e = E:create_entity(a.name)
                e.pos.x = this.pos.x
                e.pos.y = this.pos.y
                e.aura.level = this.unit.level
                e.aura.source_id = this.id
                e.aura.ts = store.tick_ts
                queue_insert(store, e)
            end
        constend
    constend

    this.enemy.gold_bag = this.enemy.gold

    constif(this.water)
        if this.spawn_data and this.spawn_data.water_ignore_pi then
            this.water.ignore_pi = this.spawn_data.water_ignore_pi
        end
    constend

    return true
end
]]

return enemy_basic
