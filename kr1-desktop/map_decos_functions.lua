-- chunkname: @./kr1-desktop/map_decos_functions.lua
local km = require("klua.macros")
local V = require("klua.vector")
local v = V.v
local deco_fn = {}

deco_fn.ani_seq = {}

function deco_fn.ani_seq:prepare()
    local d = self.ctx.data
    local timer = self.ctx.timer
    local seq_idx = 1

    self.loop = false

    timer:script(function(wait)
        while true do
            local ani_name, wait_min, wait_max = unpack(d.sequence[seq_idx])

            self.animation = d.animations[ani_name]
            self.ts = 0

            wait((self.animation.to - self.animation.from + 1) / 30)
            wait(math.random(wait_min, wait_max))

            seq_idx = km.zmod(seq_idx + 1, #d.sequence)
        end
    end)
end

deco_fn.path_open = {}

function deco_fn.path_open.unlock(this, wait)
    this.hidden = nil

    if wait then
        this.ts = 0
        this.animation = this.animations

        wait(this.animation.to / 30)
    else
        this.ts = 99
    end
end

deco_fn.ma_big_boat = {}

function deco_fn.ma_big_boat:prepare()
    local d = self.ctx.data
    local timer = self.ctx.timer
    local v_ship_in = KImageView(d.animations.in_sail.prefix .. "_0001")
    local v_ship_out = KImageView(d.animations.out_sail.prefix .. "_0001")

    v_ship_in.animation = d.animations.in_sail
    v_ship_out.animation = d.animations.out_sail
    v_ship_out.alpha = 1
    v_ship_out.pos = V.v(0, -8)
    v_ship_in.loop = true
    v_ship_out.loop = true

    self:add_child(v_ship_out)
    self:add_child(v_ship_in)
    timer:script(function(wait)
        while true do
            self.pos.x, self.pos.y = d.pos_out.x, d.pos_out.y

            wait(d.wait_out)

            v_ship_in.alpha = 1
            v_ship_out.alpha = 0
            v_ship_in.animation = d.animations.in_sail

            timer:tween(d.sail_time, self.pos, {
                x = d.pos_in.x,
                y = d.pos_in.y
            }, "out-quad")
            wait(0.8 * d.sail_time)

            v_ship_in.animation = d.animations.in_idle
            v_ship_out.animation = d.animations.out_idle

            wait(d.wait_in)

            v_ship_out.ts = 0

            timer:tween(1, v_ship_in, {
                alpha = 0
            })
            timer:tween(1, v_ship_out, {
                alpha = 1
            })
            wait(d.wait_in)

            v_ship_out.ts = 0
            v_ship_out.animation = d.animations.out_sail

            timer:tween(d.sail_time, self.pos, {
                x = d.pos_out.x,
                y = d.pos_out.y
            }, "in-quad")
            wait(d.sail_time)
        end
    end)

    -- deco_fn.md_ft_mountain = {}

    -- function deco_fn.md_ft_mountain.unlock(this, wait)
    --     if wait then
    --         this.ctx.timer:tween(2, this, {
    --             alpha = 0
    --         }, "out-quad")
    --         wait(1)
    --     else
    --         this.alpha = 0
    --     end
    -- end

    -- deco_fn.ma_waterfall1_barrel = {}

    -- function deco_fn.ma_waterfall1_barrel:prepare()
    --     local d = self.ctx.data
    --     local timer = self.ctx.timer

    --     timer.script(function(wait)
    --         while true do
    --             wait(math.random(d.wait_out[1], d.wait_out[2]))

    --             local ani_name, pos_to = unpack(d.sequence[1])

    --             self.animation = d.animations[ani_name]
    --             self.ts = 0
    --             self.loop = true
    --             self.pos.x, self.pos.y = d.pos.x, d.pos.y

    --             local dx = pos_to.x - self.pos.x

    --             timer:tween(dx / d.speed_x, self.pos, {
    --                 x = pos_to.x
    --             })
    --             timer:tween(dx / d.speed_x, self.pos, {
    --                 y = pos_to.y
    --             }, "in-quad")
    --             wait(dx / d.speed_x)

    --             ani_name, pos_to = unpack(d.sequence[2])
    --             self.animation = d.animations[ani_name]
    --             self.ts = 0
    --             self.loop = false

    --             local dx = pos_to.x - self.pos.x

    --             timer:tween(dx / d.speed_x, self.pos, {
    --                 x = pos_to.x
    --             })
    --             timer:tween(dx / d.speed_x, self.pos, {
    --                 y = pos_to.y
    --             }, "in-quad")
    --             wait(dx / d.speed_x)

    --             ani_name, pos_to = unpack(d.sequence[3])
    --             self.animation = d.animations[ani_name]
    --             self.ts = 0

    --             wait((self.animation.to - self.animation.from + 1) / 30)
    --         end
    --     end)
    -- end

    -- deco_fn.ma_ship = {}

    -- function deco_fn.ma_ship:prepare()
    --     local d = self.ctx.data
    --     local timer = self.ctx.timer
    --     local v_ship_in = KImageView(d.animations.in_sail.prefix .. "_0001")
    --     local v_ship_out = KImageView(d.animations.out_sail.prefix .. "_0001")
    --     local v_trail_in = KImageView(d.animations.in_trail.prefix .. "_0001")
    --     local v_trail_out = KImageView(d.animations.out_trail.prefix .. "_0001")

    --     v_ship_in.animation = d.animations.in_sail
    --     v_ship_out.animation = d.animations.out_sail
    --     v_trail_in.animation = d.animations.in_trail
    --     v_trail_out.animation = d.animations.out_trail
    --     v_ship_out.alpha = 1
    --     v_trail_out.alpha = 0
    --     v_ship_out.pos = V.v(0, -8)
    --     v_trail_in.pos = V.v(-20, 10)
    --     v_trail_out.pos = V.v(40, 38)
    --     v_ship_in.loop = true
    --     v_ship_out.loop = true
    --     v_trail_in.loop = true
    --     v_trail_out.loop = true

    --     self:add_child(v_trail_out)
    --     self:add_child(v_trail_in)
    --     self:add_child(v_ship_out)
    --     self:add_child(v_ship_in)
    --     timer.script(function(wait)
    --         while true do
    --             self.pos.x, self.pos.y = d.pos_out.x, d.pos_out.y

    --             wait(d.wait_out)

    --             v_ship_in.alpha = 1
    --             v_ship_out.alpha = 0
    --             v_trail_out.alpha = 0
    --             v_trail_in.alpha = 1
    --             v_ship_in.animation = d.animations.in_sail

    --             timer:tween(d.sail_time, self.pos, {
    --                 x = d.pos_in.x,
    --                 y = d.pos_in.y
    --             }, "out-quad")
    --             wait(0.8 * d.sail_time)
    --             timer:tween(0.2 * d.sail_time, v_trail_in, {
    --                 alpha = 0
    --             }, "out-quad")

    --             v_ship_in.animation = d.animations.in_idle
    --             v_ship_out.animation = d.animations.out_idle

    --             wait(d.wait_in)

    --             v_ship_out.ts = 0

    --             timer:tween(1, v_ship_in, {
    --                 alpha = 0
    --             })
    --             timer:tween(1, v_ship_out, {
    --                 alpha = 1
    --             })
    --             wait(d.wait_in)

    --             v_ship_out.ts = 0
    --             v_ship_out.animation = d.animations.out_sail

    --             timer:tween(0.2 * d.sail_time, v_trail_out, {
    --                 alpha = 1
    --             }, "in-quad")
    --             timer:tween(d.sail_time, self.pos, {
    --                 x = d.pos_out.x,
    --                 y = d.pos_out.y
    --             }, "in-quad")
    --             wait(d.sail_time)
    --         end
    --     end)
    -- end

    -- function deco_fn.ma_ship:update(dt)
    --     KView.update(self, dt)
    -- end

end

deco_fn.ma_waterfall1_barrel = {}

function deco_fn.ma_waterfall1_barrel:prepare()
    local d = self.ctx.data
    local timer = self.ctx.timer

    timer:script(function(wait)
        while true do
            wait(math.random(d.wait_out[1], d.wait_out[2]))

            local ani_name, pos_to = unpack(d.sequence[1])

            self.animation = d.animations[ani_name]
            self.ts = 0
            self.loop = true
            self.pos.x, self.pos.y = d.pos.x, d.pos.y

            local dx = pos_to.x - self.pos.x

            timer:tween(dx / d.speed_x, self.pos, {
                x = pos_to.x
            })
            timer:tween(dx / d.speed_x, self.pos, {
                y = pos_to.y
            }, "in-quad")
            wait(dx / d.speed_x)

            ani_name, pos_to = unpack(d.sequence[2])
            self.animation = d.animations[ani_name]
            self.ts = 0
            self.loop = false

            local dx = pos_to.x - self.pos.x

            timer:tween(dx / d.speed_x, self.pos, {
                x = pos_to.x
            })
            timer:tween(dx / d.speed_x, self.pos, {
                y = pos_to.y
            }, "in-quad")
            wait(dx / d.speed_x)

            ani_name, pos_to = unpack(d.sequence[3])
            self.animation = d.animations[ani_name]
            self.ts = 0

            wait((self.animation.to - self.animation.from + 1) / 30)
        end
    end)
end

deco_fn.ma_ship = {}

function deco_fn.ma_ship:prepare()
    local d = self.ctx.data
    local timer = self.ctx.timer
    local v_ship_in = KImageView(d.animations.in_sail.prefix .. "_0001")
    local v_ship_out = KImageView(d.animations.out_sail.prefix .. "_0001")
    local v_trail_in = KImageView(d.animations.in_trail.prefix .. "_0001")
    local v_trail_out = KImageView(d.animations.out_trail.prefix .. "_0001")

    v_ship_in.animation = d.animations.in_sail
    v_ship_out.animation = d.animations.out_sail
    v_trail_in.animation = d.animations.in_trail
    v_trail_out.animation = d.animations.out_trail
    v_ship_out.alpha = 1
    v_trail_out.alpha = 0
    v_ship_out.pos = V.v(0, -8)
    v_trail_in.pos = V.v(-20, 10)
    v_trail_out.pos = V.v(40, 38)
    v_ship_in.loop = true
    v_ship_out.loop = true
    v_trail_in.loop = true
    v_trail_out.loop = true

    self:add_child(v_trail_out)
    self:add_child(v_trail_in)
    self:add_child(v_ship_out)
    self:add_child(v_ship_in)
    timer:script(function(wait)
        while true do
            self.pos.x, self.pos.y = d.pos_out.x, d.pos_out.y

            wait(d.wait_out)

            v_ship_in.alpha = 1
            v_ship_out.alpha = 0
            v_trail_out.alpha = 0
            v_trail_in.alpha = 1
            v_ship_in.animation = d.animations.in_sail

            timer:tween(d.sail_time, self.pos, {
                x = d.pos_in.x,
                y = d.pos_in.y
            }, "out-quad")
            wait(0.8 * d.sail_time)
            timer:tween(0.2 * d.sail_time, v_trail_in, {
                alpha = 0
            }, "out-quad")

            v_ship_in.animation = d.animations.in_idle
            v_ship_out.animation = d.animations.out_idle

            wait(d.wait_in)

            v_ship_out.ts = 0

            timer:tween(1, v_ship_in, {
                alpha = 0
            })
            timer:tween(1, v_ship_out, {
                alpha = 1
            })
            wait(d.wait_in)

            v_ship_out.ts = 0
            v_ship_out.animation = d.animations.out_sail

            timer:tween(0.2 * d.sail_time, v_trail_out, {
                alpha = 1
            }, "in-quad")
            timer:tween(d.sail_time, self.pos, {
                x = d.pos_out.x,
                y = d.pos_out.y
            }, "in-quad")
            wait(d.sail_time)
        end
    end)
end

function deco_fn.ma_ship:update(dt)
    KView.update(self, dt)
end

deco_fn.m1 = {}

function deco_fn.m1.unlock(this, wait)
    if wait then
        this.ctx.timer:tween(1, this, {
            alpha = 0
        }, "out-quad")
        wait(1)
    else
        this.alpha = 0
    end
end

deco_fn.m2 = {}

function deco_fn.m2.unlock(this, wait)
    if wait then
        this.ctx.timer:tween(1, this, {
            alpha = 0
        }, "out-quad")
        wait(1)
    else
        this.alpha = 0
    end
end

deco_fn.gate = {}

function deco_fn.gate.unlock(this, wait)
    if wait then
        this.animation = {
            to = 128,
            prefix = "ma_gate",
            from = 1
        }
        this.ts = 0

        wait(4.266666666666667)
    else
        this.animation = nil

        this:set_image("ma_gate_0128")
    end
end

deco_fn.ship = {}

function deco_fn.ship.prepare(this)
    local point = this.ctx.screen_map.map_points.points[6][1]

    this.pos.x, this.pos.y = point.pos.x, point.pos.y
    this.animation = this.animations.down_stopped
    this.ts = 0
    this.anchor = v(this.size.x * 0.5, 2 * this.size.y / 3)
    this.speed = 50
end

function deco_fn.ship.unlock(this, wait)
    if wait then
        this.last_idx = 1
        this.move_ship = true
    else
        this.animation = this.animations.side_stopped

        local points = this.ctx.screen_map.map_points.points[6]
        local point

        for _, p in pairs(points) do
            if p.water then
                point = p
            end
        end

        this.pos = V.vclone(point.pos)
    end
end

function deco_fn.ship:update(dt)
    KView.update(self, dt)

    if self.move_ship then
        local points = self.ctx.screen_map.map_points.points[6]
        local last_point = points[self.last_idx]
        local next_point = points[self.last_idx + 1]

        if not next_point or not next_point.water then
            self.move_ship = false
            self.animation = self.animations.side_stopped

            return
        end

        local next_pos = next_point.pos
        local last_pos = last_point.pos
        local vel = v(0, 0)

        vel.x, vel.y = V.mul(self.speed, V.normalize(next_pos.x - last_pos.x, next_pos.y - last_pos.y))
        self.pos.x, self.pos.y = self.pos.x + vel.x * dt, self.pos.y + vel.y * dt

        if V.dist(self.pos.x, self.pos.y, next_pos.x, next_pos.y) < self.speed * dt then
            self.last_idx = self.last_idx + 1
        end

        local angle = km.unroll(V.angleTo(V.sub(next_pos.x, next_pos.y, last_pos.x, last_pos.y)))
        local pi_8 = math.pi / 8

        if angle > 1 * pi_8 and angle <= 3 * pi_8 then
            self.animation = self.animations.down_side
        elseif angle > 3 * pi_8 and angle <= 5 * pi_8 then
            self.animation = self.animations.down
        else
            self.animation = self.animations.side
        end
    end
end

deco_fn.md_ft_mountain = {}

function deco_fn.md_ft_mountain.unlock(this, wait)
    if wait then
        this.ctx.timer:tween(2, this, {
            alpha = 0
        }, "out-quad")
        wait(1)
    else
        this.alpha = 0
    end
end


return deco_fn

