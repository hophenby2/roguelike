local path = "assets\\addition_unit\\"
LoadImageFromFile("level_obj_needle_bullet", path .. "needle_bullet.png", true, 128, 51)
LoadImageFromFile("level_obj_wave_bullet", path .. "wave_bullet.png", true, 64, 128)
LoadImageFromFile("level_obj_rainbow_bullet", path .. "rainbow_bullet.png", true, 36, 36)

---@class level_obj3
local class3 = {}

local needle_bullet = Class(object)
function needle_bullet:init(x, y, v, a, dmg, lifetime)
    local var = lstg.var
    player_bullet_straight.init(self, "level_obj_needle_bullet", x, y, v, a, dmg)
    self.killflag = true
    self.lifetime = int(lifetime or 999)
    self.shuttle_flag = var.shuttle_main_bullet and 1 or 0
    self.target = nil
    self.trail = 450
    self.alpha = 1
    self.v = v

    task.New(self, function()
        for i = 1, 8 do
            i = i / 8
            self.alpha = i
            object.SetSizeColli(self, 1.2 - i * 0.5)
            task.Wait()
        end
    end)
end
function needle_bullet:frame()
    task.Do(self)
    player_class.findtarget(self)
    if self.lifetime == self.timer then
        self.time_out = true
        object.Kill(self)
    end
    local v = lstg.var
    if v.shuttle_main_bullet and self.shuttle_flag > 0 then
        local w = lstg.world
        if self.y > w.t then
            self.y = w.b + (self.y - w.t)
            self.shuttle_flag = self.shuttle_flag - 1
        end
        if self.y < w.b then
            self.y = w.t + (self.y - w.b)
            self.shuttle_flag = self.shuttle_flag - 1
        end
        if self.x > w.r then
            self.x = w.l + (self.x - w.r)
            self.shuttle_flag = self.shuttle_flag - 1
        end
        if self.x < w.l then
            self.x = w.r + (self.x - w.l)
            self.shuttle_flag = self.shuttle_flag - 1
        end
    end
    if v.bound_main_bullet and self.shuttle_flag == 0 then
        local w = lstg.world
        if self.y > w.t then
            self.vy = -self.vy
            self.rot = -self.rot
            self.y = w.t - (self.y - w.t)
        end
        if self.y < w.b then
            self.vy = -self.vy
            self.rot = -self.rot
            self.y = w.b - (self.y - w.b)
        end
        if self.x > w.r then
            self.vx = -self.vx
            self.rot = 180 - self.rot
            self.x = w.r - (self.x - w.r)
        end
        if self.x < w.l then
            self.vx = -self.vx
            self.rot = 180 - self.rot
            self.x = w.l - (self.x - w.l)
        end
    end
    if v.trail_main_bullet then
        player_bullet_trail.frame(self)
    end
    New(class3.needle_bullet_ef, self.x, self.y, self.rot, self.hscale)
end
function needle_bullet:render()
    SetImageState(self.img, "mul+add", self.alpha * 200, 255, 255, 255)
    DefaultRenderFunc(self)
end
class3.needle_bullet = needle_bullet

local needle_bullet_ef = Class(object)
function needle_bullet_ef:init(x, y, a, size)
    player_bullet_straight.init(self, "level_obj_needle_bullet", x, y, 0, a, 0)
    self.group = GROUP.GHOST
    self.lifetime = 20
    self.colli = false
    self.alpha = 1
    object.SetSize(self, size)
end
function needle_bullet_ef:frame()
    task.Do(self)
    self.target = player.target
    if self.lifetime == self.timer then
        object.Del(self)
    end
end
function needle_bullet_ef:render()
    local A = self.alpha * (1 - self.timer / self.lifetime) * 0.8
    --SetImageState(self.img, "mul+add", A * 100, self._r, self._g, self._b)
    -- Render(self.img, self.x, self.y, 0, self.hscale * 0.7, self.vscale * 0.7)
    SetImageState(self.img, "mul+add", A * 75, 255, 255, 255)
    DefaultRenderFunc(self)


end
class3.needle_bullet_ef = needle_bullet_ef

local wave_bullet = Class(object)
function wave_bullet:init(x, y, v, a, dmg, lifetime, size)
    player_bullet_straight.init(self, "level_obj_wave_bullet", x, y, v, a, dmg)
    self.lifetime = int(lifetime or 999)
    self.target = nil
    self.alpha = 1
    self.v = v

    task.New(self, function()
        for i = 1, 9 do
            i = i / 9 * 0.8
            self.alpha = i
            object.SetSizeColli(self, i * size)
            task.Wait()
        end
    end)
end
function wave_bullet:frame()
    task.Do(self)
    self.target = player.target
    if self.lifetime == self.timer then
        self.time_out = true
        object.Kill(self)
    end
    New(class3.wave_bullet_ef, self.x, self.y, self.rot, self.hscale)
end
function wave_bullet:kill()
    New(class3.wave_bullet_ef, self.x, self.y, self.rot, self.hscale, 2)
end
function wave_bullet:render()
    SetImageState(self.img, "mul+add", self.alpha * 100, 255, 255, 255)
    DefaultRenderFunc(self)
end
class3.wave_bullet = wave_bullet

local wave_bullet_ef = Class(object)
function wave_bullet_ef:init(x, y, a, size, v)
    player_bullet_straight.init(self, "level_obj_wave_bullet", x, y, 0, a, 0)
    self.group = GROUP.GHOST
    self.lifetime = 20
    self.colli = false
    self.alpha = 1
    self.malpha = 35
    object.SetSize(self, size)
    if v then
        self.malpha = 100
        object.SetV(self, v, a)
    end
end
function wave_bullet_ef:frame()
    task.Do(self)
    self.target = player.target
    if self.lifetime == self.timer then
        object.Del(self)
    end
end
function wave_bullet_ef:render()
    local A = self.alpha * (1 - self.timer / self.lifetime) * 0.8
    --SetImageState(self.img, "mul+add", A * 100, self._r, self._g, self._b)
    -- Render(self.img, self.x, self.y, 0, self.hscale * 0.7, self.vscale * 0.7)
    SetImageState(self.img, "mul+add", A * self.malpha, 255, 255, 255)
    DefaultRenderFunc(self)


end
class3.wave_bullet_ef = wave_bullet_ef

local wave_bullet_shooter = Class(object, {
    init = function(self)
        self.rot = 45
        self.open = false
        self.index = 0
        self.layer = LAYER.PLAYER + 5
        task.New(self, function()
            while true do
                local p = player
                while not p._playersys:keyIsDown("slow") do
                    task.Wait()
                end
                --NewBon(p.x, p.y, 60, 0, 135, 206, 235)
                NewWave(p.x, p.y, 3, 100, 15, 135, 206, 235)
                PlaySound("water")
                self.open = true
                while p._playersys:keyIsDown("slow") do
                    task.Wait()
                end
                self.open = false
                task.Wait()
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        local p = player
        if self.open then
            self.index = self.index + (-self.index + 1) * 0.1
            if p.__shoot_flag and p.nextshoot <= 0 then
                local dmg = player.damage
                local tA = 90
                if lstg.var.reverse_shoot then
                    tA = -90
                end
                if p.timer % 12 == 0 then
                    for c = -1, 1, 2 do
                        New(wave_bullet, p.x, p.y, 15, tA + c * 30, dmg * 0.45, 35, 0.4)
                    end
                end
                if p.timer % 25 == 0 then
                    for c = -1, 1, 2 do
                        New(wave_bullet, p.x, p.y, 12, tA + 15 * c, dmg * 0.25, 40, 0.25)
                        New(wave_bullet, p.x, p.y, 12, tA + 45 * c, dmg * 0.25, 40, 0.25)
                    end
                end
            end
        else
            self.index = self.index + (-self.index) * 0.1
        end
    end,
    render = function(self)
        SetImageState("bright", "", 220, 64, 64, 235)
        Render("bright", player.x, player.y, 0, self.index * 65 / 150)
    end
})
class3.wave_bullet_shooter = wave_bullet_shooter

local god_circle = Class(object, {
    init = function(self)
        self.x, self.y = player.x, player.y
        self.layer = LAYER.ENEMY + 1
        self.group = GROUP.PLAYER_BULLET
        self.alpha = 0
        self.R = 90
        self.a = self.R
        self.b = self.R
        self.bound = false
        self.particle = {}
        self.killflag = true
        self.dmg = 0
        task.New(self, function()
            for i = 1, 15 do
                self.alpha = i / 15
                task.Wait()
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        local ld = lstg.tmpvar.lie_detector
        if IsValid(ld) then
            self.R = self.R - self.R * 0.1
        else
            if self.timer % (3 + 5 - setting.rdQual) == 0 then
                local a = ran:Float(0, 360)
                local va = ran:Float(0, 360)
                local v = ran:Float(3, 5) * ran:Sign()
                table.insert(self.particle, {
                    alpha = 120, maxalpha = 200,
                    size = 7,
                    x = cos(a) * self.R, y = sin(a) * self.R,
                    vx = cos(va) * v, vy = sin(va) * v,
                    rotate = ran:Float(-1, 1),
                    timer = 0, lifetime = ran:Int(10, 20),
                    main = true
                })
            end
            self.R = self.R + (-self.R + 90) * 0.1
        end
        self.a = self.R
        self.b = self.R
        self.dmg = player.damage * 0.033
        self.x, self.y = player.x, player.y

        local p
        for i = #self.particle, 1, -1 do
            p = self.particle[i]

            if not p.issmear then
                local inc = 2 + 2 * (1 - setting.rdQual / 5)
                local dx, dy = p.vx, p.vy
                local d = hypot(dx, dy)
                local count = int(d / inc)
                local ix = inc * (dx / d)
                local iy = inc * (dy / d)
                for c = 0, count do
                    table.insert(self.particle, {
                        alpha = 0, maxalpha = 30,
                        size = p.size,
                        x = p.x - c * ix,
                        y = p.y - c * iy,
                        vx = ran:Float(-1, 1), vy = ran:Float(-1, 1),
                        timer = 0, lifetime = 5,
                        issmear = true
                    })
                end
            end
            p.x = p.x + p.vx
            p.y = p.y + p.vy
            if p.rotate then
                p.vx = p.vx + cos(p.rotate) * 0.05
                p.vy = p.vy + sin(p.rotate) * 0.05
            end
            if p.main then
                p.size = p.size - p.size * 0.1
            end
            p.vx = p.vx - p.vx * 0.1
            p.vy = p.vy - p.vy * 0.1

            p.timer = p.timer + 1
            if p.timer <= 10 then
                p.alpha = min(p.maxalpha, p.alpha + p.maxalpha / 10)
            elseif p.timer > p.lifetime - 10 then
                p.alpha = max(p.alpha - p.maxalpha / 10, 0)
                if p.alpha == 0 then
                    table.remove(self.particle, i)
                end
            end

        end
    end,
    render = function(self)
        local R, G, B = 255, 227, 132
        SetImageState("bright_circleOutline", "mul+add", self.alpha * 145, R, G, B)
        Render("bright_circleOutline", self.x, self.y, 0, self.R / 200)

        for _, p in ipairs(self.particle) do
            SetImageState("bright", "mul+add", p.alpha * self.alpha, R, G, B)
            Render("bright", self.x + p.x, self.y + p.y, 0, p.size / 130)
        end
    end
})
class3.god_circle = god_circle

local god_circle_with_lie_detector = Class(object, {
    init = function(self, id)
        self.x, self.y = player.x, player.y
        self.layer = LAYER.ENEMY + 1
        self.group = GROUP.PLAYER_BULLET
        self.alpha = 0
        self.R = 0
        self.a = self.R
        self.b = self.R
        self.bound = false
        self.killflag = true
        self.dmg = 0
        self.id = id
        task.New(self, function()
            for i = 1, 15 do
                self.alpha = i / 15
                task.Wait()
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        local ld = lstg.tmpvar.lie_detector
        if IsValid(ld) and ld.pos[self.id * 2 - 1] then
            self.R = self.R + (-self.R + 60) * 0.1
            self.x, self.y = ld.pos[self.id * 2 - 1], ld.pos[self.id * 2]
        else
            self.R = self.R - self.R * 0.1
        end
        self.a = self.R
        self.b = self.R
        self.dmg = player.damage * 0.05

    end,
    render = function(self)
        local R, G, B = 255, 227, 132
        SetImageState("bright_circleOutline", "mul+add", self.alpha * 100, R, G, B)
        Render("bright_circleOutline", self.x, self.y, 0, self.R / 200)

    end
})
class3.god_circle_with_lie_detector = god_circle_with_lie_detector

local fire_drop = Class(object)
function fire_drop:init(x, y, v, a, dmg)
    player_bullet_straight.init(self, "water_drop2", x, y, v, a, dmg)
    self.alpha = 1
    self.v = 0
    self.a, self.b = 16, 16
    self.trail = 500
    task.New(self, function()
        for i = 1, 100 do
            i = task.SetMode[2](i / 100 * 2)
            self.v = v * i
            if not lstg.var.trail_main_bullet then
                object.SetV(self, self.v, a)
            end
            task.Wait()
        end
    end)
    task.New(self, function()
        for i = 1, 10 do
            i = i / 10
            object.SetSizeColli(self, 0.7 * i)
            task.Wait()
        end
        task.Wait(100 - 10)
        for i = 1, 20 do
            self.alpha = 1 - i / 20
            task.Wait()
        end
        object.Kill(self)
    end)
end
function fire_drop:frame()
    task.Do(self)
    if lstg.var.trail_main_bullet then
        player_class.findtarget(self)
        player_bullet_trail.frame(self)
    end
end
function fire_drop:kill()
    New(class3.fire_drop_ef, self.x, self.y, self.rot, self.v / 2, self.hscale, self.vscale, self.alpha)
end
function fire_drop:render()
    SetAnimationState(self.img, "mul+add", self.alpha * 120, 255, 255, 255)
    DefaultRenderFunc(self)
end
class3.fire_drop = fire_drop

local fire_drop_ef = Class(object)
function fire_drop_ef:init(x, y, rot, v, hscale, vscale, alpha)
    self.x = x
    self.y = y
    self.rot = rot
    self.vx = v * cos(rot)
    self.vy = v * sin(rot)
    self.hscale, self.vscale = hscale, vscale
    self.alpha = alpha
    self.img = "water_drop2"
    self.layer = LAYER.PLAYER_BULLET + 50
end
function fire_drop_ef:frame()
    if self.timer == 7 then
        Del(self)
    end
end
function fire_drop_ef:render()
    local A = self.alpha * (1 - self.timer / 8) * 0.8
    SetAnimationState(self.img, "mul+add", A * 120, 255, 255, 255)
    DefaultRenderFunc(self)
end
class3.fire_drop_ef = fire_drop_ef

local fire_drop_shooter = Class(object)
function fire_drop_shooter:init()

end
function fire_drop_shooter:frame()
    local p = player
    if p.dx ~= 0 or p.dy ~= 0 then
        local c = lstg.tmpvar.bird_resurrected or 0
        if p.timer % max(1, 3 - c) == 0 then
            local ang = Angle(p.dx, p.dy, 0, 0) + ran:Float(-20, 20)
            local bv = 7
            if lstg.var.reverse_shoot then
                ang = ang + 180
            end
            New(fire_drop, p.x + ran:Float(-12, 12), p.y + ran:Float(-12, 12), bv, ang, player.damage * 0.58)
            PlaySound("nodamage", 0.01)
        end
    end
end
class3.fire_drop_shooter = fire_drop_shooter

local dragon_jade = Class(object, {
    init = function(self)
        self.group = GROUP.GHOST
        self.layer = LAYER.ENEMY - 5
        self.x, self.y = 666, 666
        self.bound = false
        self.index = 0
        self.omega = 2
        self.bsize = 0
    end,
    frame = function(self)
        task.Do(self)
        self.index = self.index - self.index * 0.05
        local t = player.target2--运用新目标
        if IsValid(t) then
            self.x, self.y = t.x, t.y
            self.bsize = t.a
            if self.timer % 5 == 0 then
                local sk = sin(self.timer * 3) * 0.2
                local size = self.bsize * (2.5 + sk)
                local lifetime = player.cur_brange
                local dmg = player.damage * 0.2
                for a in sp.math.AngleIterator(self.rot, 5) do
                    local R, G, B = sp:HSVtoRGB(a - self.timer, 0.6, 1)
                    New(class3.dragon_jade_bullet, self.x + cos(a) * size, self.y + sin(a) * size, 7, a, dmg, lifetime, R, G, B)
                end
            end
        else
            self.x, self.y = 666, 666
        end
    end,
    render = function(self)
        local alpha = 180
        local sk = sin(self.timer * 3) * 0.2
        local size = self.bsize * (2.5 + sk)
        SetImageState("white", "mul+add", alpha * 0.5, 255, 255, 255)
        misc.SectorRender(self.x, self.y, size - 2.5, size, 0, 360, int(clamp(size / 3, 20, 80)))
        for a in sp.math.AngleIterator(self.rot, 5) do
            SetImageState("white", "mul+add", alpha, sp:HSVtoRGB(a - self.timer, 0.7, 0.6))
            misc.SectorRender(self.x + cos(a) * size, self.y + sin(a) * size, 0, size * 0.4, 0, 180, 2, a + 180)
        end
    end
}, true)
class3.dragon_jade = dragon_jade

CopyImage("dragon_jade_bullet", "player_bullet")
SetImageScale("dragon_jade_bullet", 0.5 / 4)

local dragon_jade_bullet = Class(object)
function dragon_jade_bullet:init(x, y, v, a, dmg, lifetime, R, G, B)
    player_bullet_straight.init(self, "dragon_jade_bullet", x, y, v, a, dmg)
    self.alpha = 1
    self.v = v
    self.a, self.b = 16, 16
    self.R, self.G, self.B = R, G, B
    self.lifetime = lifetime

    object.SetV(self, v, a)
end
function dragon_jade_bullet:frame()
    task.Do(self)
    if lstg.var.return_bullet and not self.have_returned and self.timer >= self.lifetime * 0.5 then
        self.have_returned = true
        self.vx, self.vy = -self.vx, -self.vy
        self.ax, self.ay = -self.ax, -self.ay
        self.rot = Angle(0, 0, self.vx, self.vy)
    end
    if self.lifetime == self.timer then
        self.time_out = true
        object.Kill(self)
    end
end
function dragon_jade_bullet:kill()
    New(class3.dragon_jade_bullet_ef, self.x, self.y, self.rot, 3, self.hscale, self.vscale, self.alpha, self.R, self.G, self.B)
end
function dragon_jade_bullet:render()
    SetImageState(self.img, "mul+add", self.alpha * 75, self.R, self.G, self.B)
    DefaultRenderFunc(self)
end
class3.dragon_jade_bullet = dragon_jade_bullet

local dragon_jade_bullet_ef = Class(object)
function dragon_jade_bullet_ef:init(x, y, rot, v, hscale, vscale, alpha, R, G, B)
    self.x = x
    self.y = y
    self.rot = rot
    self.vx = v * cos(rot)
    self.vy = v * sin(rot)
    self.hscale, self.vscale = hscale, vscale
    self.alpha = alpha
    self.img = "dragon_jade_bullet"
    self.layer = LAYER.PLAYER_BULLET + 50
    self.R, self.G, self.B = R, G, B
end
function dragon_jade_bullet_ef:frame()
    if self.timer == 7 then
        Del(self)
    end
end
function dragon_jade_bullet_ef:render()
    local A = self.alpha * (1 - self.timer / 8) * 0.8
    SetImageState(self.img, "mul+add", A * 75, self.R, self.G, self.B)
    DefaultRenderFunc(self)
end
class3.dragon_jade_bullet_ef = dragon_jade_bullet_ef

local penglai_jade_bullet = Class(object)
function penglai_jade_bullet:init(x, y, v, a, dmg, rot, omega)
    if lstg.tmpvar.penglai_jade_count >= 20 then
        Del(self)

    end
    player_bullet_straight.init(self, "level_obj_rainbow_bullet", x, y, v, a, dmg)
    self.alpha = 1
    self.v = v
    self.angle = a
    self.rot = rot or 0
    self.omega = omega or ran:Float(2, 3) * ran:Sign()
    object.SetV(self, v, a)
    object.SetSizeColli(self, 0.3)
    self.rebound_flag = 1
    lstg.tmpvar.penglai_jade_count = lstg.tmpvar.penglai_jade_count + 1
end
function penglai_jade_bullet:frame()
    task.Do(self)

    if self.rebound_flag > 0 then
        local w = lstg.world
        local off = 16
        if self.y > w.t - off then
            self.y = w.t - (self.y - w.t)
            self.rebound_flag = self.rebound_flag - 1
            player_class.findtarget(self)
            if IsValid(self.target2) then
                local tar = self.target2
                local d = Dist(self, tar)
                local x = tar.x + tar.dx * d / self.v
                local y = tar.y + tar.dy * d / self.v
                object.SetV(self, self.v, Angle(self, x, y))
            else
                self.vy = -self.vy
            end


        end
        if self.y < w.b + off then
            self.y = w.b - (self.y - w.b)
            self.rebound_flag = self.rebound_flag - 1
            player_class.findtarget(self)
            if IsValid(self.target2) then
                local tar = self.target2
                local d = Dist(self, tar)
                local x = tar.x + tar.dx * d / self.v
                local y = tar.y + tar.dy * d / self.v
                object.SetV(self, self.v, Angle(self, x, y))
            else
                self.vy = -self.vy
            end

        end
        if self.x > w.r - off then
            self.x = w.r - (self.x - w.r)
            self.rebound_flag = self.rebound_flag - 1
            player_class.findtarget(self)
            if IsValid(self.target2) then
                local tar = self.target2
                local d = Dist(self, tar)
                local x = tar.x + tar.dx * d / self.v
                local y = tar.y + tar.dy * d / self.v
                object.SetV(self, self.v, Angle(self, x, y))
            else
                self.vx = -self.vx
            end

        end
        if self.x < w.l + off then
            self.x = w.l - (self.x - w.l)
            self.rebound_flag = self.rebound_flag - 1
            player_class.findtarget(self)
            if IsValid(self.target2) then
                local tar = self.target2
                local d = Dist(self, tar)
                local x = tar.x + tar.dx * d / self.v
                local y = tar.y + tar.dy * d / self.v
                object.SetV(self, self.v, Angle(self, x, y))
            else
                self.vx = -self.vx
            end

        end
    end
end
function penglai_jade_bullet:del()
    lstg.tmpvar.penglai_jade_count = lstg.tmpvar.penglai_jade_count - 1
end
function penglai_jade_bullet:kill()
    New(class3.penglai_jade_bullet_ef, self.x, self.y, self.rot, 3, self.hscale, self.vscale, self.alpha)
    New(class3.penglai_jade_bullet_item, self.x, self.y, self.v / 2, self.angle, self.v, self.dmg, self.hscale, self.vscale, self.alpha, self.rot, self.omega)
end
function penglai_jade_bullet:render()
    SetImageState(self.img, "mul+add", self.alpha * 240, 255, 255, 255)
    DefaultRenderFunc(self)
end
class3.penglai_jade_bullet = penglai_jade_bullet

local penglai_jade_bullet_ef = Class(object)
function penglai_jade_bullet_ef:init(x, y, rot, v, hscale, vscale, alpha)
    self.x = x
    self.y = y
    self.rot = rot
    self.vx = v * cos(rot)
    self.vy = v * sin(rot)
    self.hscale, self.vscale = hscale, vscale
    self.alpha = alpha
    self.img = "level_obj_rainbow_bullet"
    self.layer = LAYER.PLAYER_BULLET + 50
end
function penglai_jade_bullet_ef:frame()
    if self.timer == 7 then
        Del(self)
    end
end
function penglai_jade_bullet_ef:render()
    local A = self.alpha * (1 - self.timer / 8) * 0.8
    SetImageState(self.img, "mul+add", A * 240, 255, 255, 255)
    DefaultRenderFunc(self)
end
class3.penglai_jade_bullet_ef = penglai_jade_bullet_ef

local penglai_jade_bullet_item = Class(item)
penglai_jade_bullet_item.frame = item.frame2
function penglai_jade_bullet_item:init(x, y, v, a, wv, dmg, hscale, vscale, alpha, rot, omega)
    self.x = clamp(x, lstg.world.l + 8, lstg.world.r - 8)
    self.y = y
    self.v = v
    object.SetV(self, v, a)
    self.wv = wv
    self._dmg = dmg
    self.group = 6
    self.layer = -300
    self.bound = false
    self.img = "level_obj_rainbow_bullet"
    self.rot = rot
    self.omega = omega
    self.hscale, self.vscale = hscale, vscale
    self.alpha = alpha
    self.attract = 0
    self.py = y
    self.t = 0
    self._vy = 0
    self._scale = 0
    self.__scale = self.hscale
    self._blend = ""
    self._a, self._r, self._g, self._b = 255, 255, 255, 255
    self.fall_v = 6
    self.fall_a = 0.08
end
function penglai_jade_bullet_item:render()
    local A = self.alpha
    SetImageState(self.img, "mul+add", A * 125, 255, 255, 255)
    DefaultRenderFunc(self)
end
function penglai_jade_bullet_item:collect()
    PlaySound("lgods1")
    local A
    player_class.findtarget(self)
    if IsValid(self.target2) then
        local tar = self.target2
        local d = Dist(self, tar)
        local x = tar.x + tar.dx * d / self.wv
        local y = tar.y + tar.dy * d / self.wv
        A = Angle(self, x, y)
    else
        A = 90
    end
    New(class3.penglai_jade_bullet, self.x, self.y, self.wv, A, self._dmg, self.rot, self.omega)
end
function penglai_jade_bullet_item:del()
    lstg.tmpvar.penglai_jade_count = lstg.tmpvar.penglai_jade_count - 1
end
penglai_jade_bullet_item.kill = penglai_jade_bullet_item.del
class3.penglai_jade_bullet_item = penglai_jade_bullet_item

local forever_scarlet_moon = Class(object, {
    init = function(self, R, x, y)
        self.x, self.y = x, y
        self.layer = LAYER.ENEMY + 1
        self.group = GROUP.PLAYER_BULLET
        self.alpha = 0
        self._R = R
        self.R = 0
        self.a = self.R
        self.b = self.R
        self.bound = false
        self.killflag = true
        self.dmg = 0
        task.New(self, function()
            for i = 1, 15 do
                self.alpha = i / 15
                task.Wait()
            end
            task.Wait(15)
            for i = 1, 15 do
                self.alpha = 1 - i / 15
                task.Wait()
            end
            Del(self)
        end)
    end,
    frame = function(self)
        task.Do(self)
        self.R = self.R + (-self.R + self._R) * 0.1
        self.a = self.R
        self.b = self.R
        self.dmg = player.damage * 0.02
        local sspeed = player.cur_sspeed
        local interval = math.ceil(66 / sspeed)
        if self.timer % interval == 0 then
            self.colli = false
        else
            self.colli = true
        end

    end,
    render = function(self)
        local R, G, B = 250, 25, 40
        SetImageState("bright_circleOutline", "mul+add", self.alpha * 145, R, G, B)
        Render("bright_circleOutline", self.x, self.y, 0, self.R / 200)
        SetImageState("white", "mul+add", self.alpha * 80, R, G, B)
        misc.SectorRender(self.x, self.y, 0, self.R, 0, 360, 25)
    end
})
class3.forever_scarlet_moon = forever_scarlet_moon

local maxm = Class(object, {
    init = function(self)
        self.group = GROUP.PLAYER_BULLET
        self.layer = LAYER.PLAYER - 5
        self.a, self.b = 16, 16
        self.killflag = true
        self.dmg = 0
        self.bound = false
    end,
    frame = function(self)
        self.dmg = player.damage * max(1.5, player.A)
        if lstg.var.neutron_star then
            self.dmg = self.dmg * 2
        end
        if player.timer % 12 == 0 then
            self.x, self.y = player.x, player.y
        else
            self.x, self.y = 5555, 5555
        end
    end,
}, true)
class3.maxm = maxm

return class3