local path = "assets\\addition_unit\\"

LoadTexture("level_obj_tex", path .. "obj.png")
LoadTexture("level_obj_tex2", path .. "obj2.png")
LoadImageFromFile("level_obj_strength_aura", path .. "obj3.png")
LoadImageFromFile("exp_pendulum", path .. "obj4.png")
LoadImage("level_obj_straight_knife", "level_obj_tex", 0, 96, 32, 16, 8, 8)
LoadAnimation("level_obj_straight_knife_ef", "level_obj_tex", 0, 96, 32, 16, 4, 1, 4)
LoadImageSetCenter("beast_hyper_2", "level_obj_tex2", 0, 0, 80, 64, 80, 80)
LoadAnimation("level_obj_ice_support", "level_obj_tex", 128, 112, 16, 16, 4, 1, 5)
LoadAnimation("level_obj_back_door", "level_obj_tex", 0, 128, 32, 16, 4, 1, 5)
LoadImage("level_obj_ice_bullet", "level_obj_tex", 128, 128, 16, 16, 6, 6)

LoadAnimation("level_obj_ice_bullet_ef", "level_obj_tex", 128, 128, 16, 16, 4, 1, 4)
SetImageState("level_obj_ice_bullet", "", 168, 255, 255, 255)
SetAnimationState("level_obj_ice_bullet_ef", "", 168, 255, 255, 255)

LoadImageGroupFromFile("YukariTool", path .. "YukariTool.png", nil, 3, 10)
for i = 1, 30 do
    SetImageState("YukariTool" .. i, "mul+add")
end

LoadTexture("level_obj_tex5", path .. "obj5.png")

LoadAnimation("level_obj_ningyou_soul", "level_obj_tex5", 0, 0, 32, 64, 8, 1, 6)
LoadAnimation("level_obj_ningyou", "level_obj_tex5", 0, 64, 32, 64, 2, 1, 8)
LoadImage("level_obj_ningyou_bullet", "level_obj_tex5", 64, 96, 32, 32, 8, 8)

do
    LoadImageFromFile("Sakura1", path .. "Sakura1.png")
    LoadImageFromFile("Sakura2", path .. "Sakura2.png")
    LoadTexture("sakura_item", path .. "sakura_item.png")
    LoadImage("item11", "sakura_item", 0, 0, 32, 32, 8, 8)
    SetImageState("item11", "", 150, 200, 200, 200)
    LoadImage("item_up11", "sakura_item", 32, 0, 32, 32)
end--sakura

---@class level_obj
local class = {}

local lifeadder = Class(object, {
    init = function(self)
        self.group = GROUP.GHOST
        self.count = 1
    end,
    frame = function(self)
        if lstg.var.frame_counting then
            player_lib.AddLife(self.count * 0.1 / 60)
        end
    end
})
class.lifeadder = lifeadder

local lifeboom_obj = Class(object, {
    frame = task.Do,
    init = function(self, x, y, dmg, time, r)
        self.group = GROUP.PLAYER_BULLET
        self.killflag = true
        self.dmg = dmg
        self.x, self.y = x, y
        task.New(self, function()
            for i = 1, time do
                local _r = r * task.SetMode[2](i / time)
                self.a = _r
                self.b = _r
                task.Wait()
            end
            Del(self)
        end)
    end }, true)

local function lifeboom_func(x, y, r, dmg, time, R, G, B)
    NewBon(x, y, time, 0, R, G, B)
    NewWave(x, y, 2, r, time, R, G, B)
    New(bullet_cleaner, x, y, r, 20, time, true, false, 0)
    New(lifeboom_obj, x, y, dmg, time, r)
end
class.lifeboom_func = lifeboom_func

local straightknife = Class(object, {
    init = function(self, x, y, v, a, dmg)
        player_bullet_straight.init(self, "level_obj_straight_knife", x, y, v, a, dmg)
        self.trail = 555
        self.v = v
    end,
    frame = function(self)
        self.target = player.target
        if IsValid(self.target) and self.target.colli and self.target.class.base.take_damage then
            local a = (Angle(self, self.target) - self.rot) % 360
            if a > 180 then
                a = a - 360
            end
            local da = self.trail / (Dist(self, self.target) + 1)
            if da >= abs(a) then
                self.rot = Angle(self, self.target)
            else
                self.rot = self.rot + sign(a) * da
            end
        end
        self.vx = self.v * cos(self.rot)
        self.vy = self.v * sin(self.rot)
    end,
    kill = function(self)
        New(class.straightknife_ef, self.x, self.y, self.rot)
    end
})
class.straightknife = straightknife

local straightknife_ef = Class(object, {
    init = function(self, x, y, rot)
        self.x = x
        self.y = y
        self.img = "level_obj_straight_knife_ef"
        self.layer = LAYER.PLAYER_BULLET + 50
        self.group = GROUP.GHOST
        object.SetV(self, 2.25, rot, true)
    end,
    frame = function(self)
        if self.timer == 15 then
            object.RawDel(self)
        end
    end
})
class.straightknife_ef = straightknife_ef

local straightknife_shooter = Class(object, {
    init = function(self)
        self.count = 1
        self.intervals = { 14, 9, 6 }
    end,
    frame = function(self)
        local p = player
        if p.__shoot_flag and p.nextshoot <= 0 then
            local pos = clamp(self.count, 1, 3)
            if p.timer % self.intervals[pos] == 0 then
                local rot = 90
                local x, y = p.x + ran:Float(-40, 40), -270
                if lstg.var.reverse_shoot then
                    y = -y
                    rot = -rot
                end
                if IsValid(p.target) then
                    rot = Angle(x, y, p.target)
                end

                local dmg = player.damage * (self.count / 3 * 0.5 + 0.3)
                New(straightknife, x, y, 22, rot, dmg)
            end
        end
    end
})
class.straightknife_shooter = straightknife_shooter

local bullet_killer = Class(object)
function bullet_killer:init(x, y, a, b, kill_indes)
    self.x = x
    self.y = y
    self.a = a
    self.b = b
    self.group = GROUP.PLAYER
    self.hide = true
    self.kill_indes = kill_indes
    self.colli = false
    self.bound = false
end
function bullet_killer:frame()
    if self.timer == 1 then
        object.Del(self)
    end
    cutLasersByCircle(self.x, self.y, self.a)
    object.BulletDo(function(o)
        if Dist(self, o) < self.a then
            object.Del(o)
        end
    end)
    --[[
    object.LaserDo(function(o)
        if Dist(self, o) < self.a and not o.Isradial and not o.Isgrowing then
            object.Del(o)
        end
    end)--]]
end
class.bullet_killer = bullet_killer

local GreenHyperCenter = Class(object)
function GreenHyperCenter:init()
    self.img = "beast_hyper_2"
    self.group = GROUP.GHOST
    self.layer = LAYER.PLAYER
    self.x, self.y = player.x, player.y
    self.bound = false
    self.colli = false
    self.count = 1
end
function GreenHyperCenter:frame()
    for o = 1, self.count do
        o = o * 360 / self.count + player.timer * 4
        New(bullet_killer, player.x + cos(o) * 70, player.y + sin(o) * 70, 28, 28)
    end
end
function GreenHyperCenter:render()
    for o = 1, self.count do
        Render(self.img, player.x, player.y, o * 360 / self.count - 135 + player.timer * 4)
    end
end
class.GreenHyperCenter = GreenHyperCenter

local attackInProtect = Class(object, {
    init = function(self)
        self.group = GROUP.PLAYER_BULLET
        self.count = 1
        self.killflag = true
        self.colli = false
        task.New(self, function()
            local p = player
            while true do
                local count = self.count
                while player.protect == 0 do
                    task.Wait()
                end
                p.dmg_factor = p.dmg_factor + count * 0.5
                while player.protect > 0 do
                    task.Wait()
                end
                p.dmg_factor = p.dmg_factor - count * 0.5
            end
        end)
    end,
    frame = task.Do
}, true)
class.attackInProtect = attackInProtect--TODO 这个碰到回溯就有概率会翻倍攻击

local small_ice = Class(object, {
    init = function(self, x, y, v, a, dmg)
        player_bullet_straight.init(self, "level_obj_ice_bullet", x, y, v, a, dmg)

    end,
    kill = function(self)
        New(class.small_ice_ef, self.x, self.y, self.rot)
    end
})
class.small_ice = small_ice

local small_ice_ef = Class(object, {
    init = function(self, x, y, rot)
        self.x = x
        self.y = y
        self.img = "level_obj_ice_bullet_ef"
        self.layer = LAYER.PLAYER_BULLET + 50
        self.group = GROUP.GHOST
        object.SetV(self, 2.25, rot, true)
    end,
    frame = function(self)
        if self.timer == 15 then
            object.RawDel(self)
        end
    end
})
class.small_ice_ef = small_ice_ef

local small_ice_shooter = Class(object, {
    init = function(self)
        self.count = 1
        self.ways = { 9, 9, 12 }
        self.intervals = { 12, 8, 6 }
        self.img = "level_obj_ice_support"
        self.x, self.y = player.x, player.y - 40
        self.layer = LAYER.PLAYER_BULLET
        self.d = 1
        self.bound = false
    end,
    frame = function(self)

        local p = player
        self.x, self.y = p.x, p.y - 40
        if lstg.var.reverse_shoot then
            self.y = p.y + 40
        end
        if p.__shoot_flag and p.nextshoot <= 0 then
            local pos = clamp(self.count, 1, 3)
            if p.timer % self.intervals[pos] == 0 then
                for a in sp.math.AngleIterator(90 * self.d, self.ways[pos]) do
                    New(small_ice, self.x, self.y, 15, a, player.damage * 0.35)
                end
                self.d = -self.d
            end
        end
    end
}, true)
class.small_ice_shooter = small_ice_shooter

local strength_aura = Class(object, {
    init = function(self)
        self.bound = false
        self.img = "level_obj_strength_aura"
        self.x, self.y = player.x, player.y
        self.omega = 3
        self._a = 0
        self.__a = 0
        self.r = 90
        self.player_x = {}
        self.player_y = {}
        task.New(self, function()
            local p = player
            while true do
                while Dist(self, player) >= self.r do
                    task.Wait()
                end
                self.__a = 75
                while Dist(self, player) < self.r do
                    task.Wait()
                end
                self.__a = 145
                task.Wait()
            end
        end)
        self.px, self.py = player.x, player.y

    end,
    frame = function(self)
        task.Do(self)
        table.insert(self.player_x, player.x)
        table.insert(self.player_y, player.y)
        self._a = self._a + (-self._a + self.__a) * 0.1
        if #self.player_x > 60 then
            table.remove(self.player_x, 1)
            table.remove(self.player_y, 1)
        end
        local index = clamp(Dist(self, self.player_x[1], self.player_y[1]) / 200 * 0.02, 0.008, 0.02)
        self.x = self.x + (-self.x + self.player_x[1]) * index
        self.y = self.y + (-self.y + self.player_y[1]) * index
    end,
    render = function(self)
        SetImageState(self.img, "mul+add", self._a, 200, 200, 200)
        Render(self.img, self.x, self.y, self.rot, self.r / 128)
    end
}, true)
class.strength_aura = strength_aura

local exp_pendulum = Class(object, {
    init = function(self, cx, cy, offa, d, ir, dmgindex)
        self.img = "exp_pendulum"
        self.group = GROUP.PLAYER_BULLET
        self.killflag = true
        self.scale = 0
        self.a, self.b = 0, 0
        self.index = dmgindex
        local dmg = player.damage
        self.dmg = dmg * self.index
        self.bound = false
        self.alpha = 1
        self.maxexp = 40
        task.New(self, function()
            for i = 1, 15 do
                self.scale = 0.6 * sin(i * 6)
                self.a = self.scale * 29
                self.b = self.a
                task.Wait()
            end
            for i = 1, 250 do
                self.scale = self.scale + i / 7500
                self.alpha = self.alpha - 1 / 250
                self.a = self.scale * 29
                self.b = self.a
                task.Wait()
            end
            Del(self)
        end)
        task.New(self, function()
            local vr = 1
            while true do
                self.rot = offa + d * ir
                self.x = cx + cos(self.rot) * ir
                self.y = cy + sin(self.rot) * ir
                vr = vr + 0.03
                ir = ir + vr
                task.Wait()
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        self.dmg = player.damage * self.index
    end,
    render = function(self)
        SetImageState("bright", "mul+add", 60 * self.alpha, 255, 227, 132)
        Render("bright", self.x, self.y, 0, self.scale)
        SetImageState(self.img, "mul+add", 60 * self.alpha, 255, 255, 255)
        Render(self.img, self.x, self.y, self.rot, self.scale)

    end,
    colli = function(self, other)
        self.maxexp = max(self.maxexp - self.dmg / 12, 0)
        DropExpPoint(min(self.maxexp, self.dmg / 12), other.x, other.y)
    end
}, true)

local exp_pendulum_shooter = Class(object, {
    init = function(self)
        self.count = 1
        task.New(self, function()
            local d = 1
            while true do
                for a in sp.math.AngleIterator(90 * d, 3) do
                    New(exp_pendulum, player.x, player.y, a, d, 50, 0.3 + self.count * 0.1)
                end
                d = -d
                task.Wait(355 - min(3, self.count) * 55)
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        CollisionCheck(GROUP.PLAYER_BULLET, GROUP.ENEMY)
        CollisionCheck(GROUP.PLAYER_BULLET, GROUP.NONTJT)
    end
}, true)
class.exp_pendulum_shooter = exp_pendulum_shooter

local tracing_soul_count = 0
local tracing_soul = Class(object, {
    init = function(self, x, y, v, a, dmg, time)
        player_bullet_straight.init(self, "bright", x, y, v, a, dmg)
        self.trail = 900
        self.v = v
        self.bound = false
        self.a, self.b = 4, 4
        self.killflag = true
        self.smear = {}
        self.alpha = 100
        if tracing_soul_count >= 36 then
            Del(self)
            return
        end
        tracing_soul_count = tracing_soul_count + 1
        task.New(self, function()
            task.Wait(time)
            self.colli = false
            self.stop = true
            object.StopMoving(self)

            while #self.smear > 0 do
                self.alpha = max(0, self.alpha - 7)
                task.Wait()
            end
            tracing_soul_count = tracing_soul_count - 1
            Del(self)
        end)
    end,
    frame = function(self)
        task.Do(self)
        if not self.stop then

            if IsValid(self.target) and self.target.colli and self.target.class.base.take_damage then
                local a = (Angle(self, self.target) - self.rot) % 360
                if a > 180 then
                    a = a - 360
                end
                local da = self.trail / (Dist(self, self.target) + 1)
                if da >= abs(a) then
                    self.rot = Angle(self, self.target)
                else
                    self.rot = self.rot + sign(a) * da
                end
            else
                self.target = player.target
            end
            self.vx = self.v * cos(self.rot)
            self.vy = self.v * sin(self.rot)
            local inc = 2 + 2 * (1 - setting.rdQual / 5)
            local dx, dy = self.dx, self.dy
            local d = hypot(dx, dy)
            local count = int(d / inc)
            local ix = inc * (dx / d)
            local iy = inc * (dy / d)
            for p = 0, count do
                table.insert(self.smear, {
                    x = self.x - p * ix,
                    y = self.y - p * iy,
                    alpha = 100
                })
            end
        end

        local s
        for i = #self.smear, 1, -1 do
            s = self.smear[i]
            s.alpha = max(s.alpha - 7, 0)
            if s.alpha == 0 then
                table.remove(self.smear, i)
            end
        end
    end,
    render = function(self)
        SetImageState("bright", "mul+add", self.alpha, 255, 255, 255)
        Render("bright", self.x, self.y, 0, 12 / 150)
        for _, s in ipairs(self.smear) do
            SetImageState("bright", "mul+add", s.alpha, 255, 255, 255)
            Render("bright", s.x, s.y, 0, 7 / 150)
        end
    end
}, true)
class.tracing_soul = tracing_soul

local miko_laser = Class(object, {
    init = function(self, rot, time, dmg, alpha)
        self.bound = false
        self.layer = GROUP.PLAYER - 500
        self.rot = rot
        self.dmg = dmg
        self.time = time
        self.open = false
        self.l1, self.l2, self.l3 = 0, 0, 0
        self.index = 14
        self.img1 = 'laser11' .. self.index
        self.img2 = 'laser12' .. self.index
        self.img3 = 'laser13' .. self.index
        self._alpha = alpha
        self._a, self._r, self._g, self._b = 255, 255, 255, 255
        self._blend = "mul+add"
        self.w = 10
        self.x, self.y = player.x, player.y
        self.dmg_factor = 1
        task.New(self, function()
            task.Wait(5)
            self.open = true
            task.New(self, function()
                task.Wait(time - 20)
                for i = 1, 20 do
                    self._alpha = alpha - i / 20 * alpha
                    task.Wait()
                end
            end)
            for _ = 1, 30 do
                self.l3 = self.l3 + 25
                task.Wait()
            end
            task.Wait(time - 60)
            for _ = 1, 30 do
                self.l1 = self.l1 + 25
                task.Wait()
            end
            self.open = false
            Del(self)
        end)
    end,
    frame = function(self)
        self.x, self.y = player.x, player.y
        task.Do(self)
        if self.open then
            object.EnemyNontjtDo(function(e)
                local d = Dist(self, e)
                if d < self.l1 + self.l2 + self.l3 then
                    if e.colli and marisa_player.IsInLaser(self.x, self.y, self.rot, e, 16) then
                        if e.class.base.take_damage then
                            --self.offset[i] = max(0, self.offset[i] - t.b)
                            e.class.base.take_damage(e, self.dmg)
                            if e.maxhp then
                                if e.hp > e.maxhp * 0.1 then
                                    PlaySound('damage00', 0.3)
                                else
                                    PlaySound('damage01', 0.6)
                                end
                            else
                                PlaySound('damage00', 0.3)
                            end
                        end
                    end
                end
            end)
        end

    end,
    render = function(self)
        local b = self._blend
        local data = laser_data[1]
        SetImageState(self.img1, b, self._a * self._alpha, self._r, self._g, self._b)
        Render(self.img1, self.x, self.y, self.rot, self.l1 / data[1], self.w / 7)
        SetImageState(self.img2, b, self._a * self._alpha, self._r, self._g, self._b)
        Render(self.img2, self.x + self.l1 * cos(self.rot), self.y + self.l1 * sin(self.rot), self.rot, self.l2 / data[2], self.w / 7)
        SetImageState(self.img3, b, self._a * self._alpha, self._r, self._g, self._b)
        Render(self.img3, self.x + (self.l1 + self.l2) * cos(self.rot), self.y + (self.l1 + self.l2) * sin(self.rot), self.rot, self.l3 / data[3], self.w / 7)

    end
}, true)
class.miko_laser = miko_laser

local miko_laser_shooter = Class(object, {
    init = function(self)
        self.count = 1
    end,
    frame = function(self)
        task.Do(self)
        local p = player
        if p.__shoot_flag and p.nextshoot <= 0 and p.dx == 0 and p.dy == 0 then
            local c = self.count
            local interval = 55 - c * 3
            if self.timer % interval == 0 then
                local proba = 0.3 + self.count / 8
                local n = ran:Float(0, 1)
                if proba >= n then
                    PlaySound("lazer00", 0.01)
                    local sa = c / 17 * 135
                    local dmg = player.damage
                    local tA = 90
                    if lstg.var.reverse_shoot then
                        tA = -90
                    end
                    New(miko_laser, ran:Float(tA - sa, tA + sa), 160 - c * 4, (0.4 - c / 17 * 0.3) * dmg, 0.8 - c / 17 * 0.4)
                end
            end
        end
    end
}, true)
class.miko_laser_shooter = miko_laser_shooter

local magic_bottle_renderer = Class(object, {
    init = function(self)
        self.layer = LAYER.PLAYER
        self.count = 1
        self.dev_value = 10
        self._a = 0
        self.__a = 0

    end,
    frame = function(self)
        self._a = self._a + (-self._a + self.__a) * 0.1
        local v = lstg.var
        local k = v.maxenergy / 100
        if v.energy >= 70 * k then
            self.__a = 50
        else
            self.__a = 0
        end
    end,
    render = function(self)
        SetImageState("circle_charge", "mul+add", self._a, 255, 227, 132)
        Render("circle_charge", player.x, player.y, 0, 24 / 256)
    end
}, true)
class.magic_bottle_renderer = magic_bottle_renderer

local blue_barrier = Class(object, {
    init = function(self)
        self.layer = 3
        self.alpha = 0
        self.particle = {}
        self.y = 90
        self.j = 0
        self._y = 90
        self.offy = 0
        task.New(self, function()
            for i = 1, 30 do
                self.alpha = task.SetMode[2](i / 30)
                task.Wait()
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        self.y = self.y + (-self.y + self._y) * 0.1
        local p
        for i = #self.particle, 1, -1 do
            p = self.particle[i]
            p.x = p.x + p.vx
            p.y = p.y + p.vy
            p.rot = p.rot + p.omega
            p.timer = p.timer + 1
            if p.timer <= 10 then
                p.alpha = p.timer / 10 * p.maxalpha
            elseif p.timer > p.lifetime - 10 then
                p.alpha = max(p.alpha - p.maxalpha / 10, 0)
                if p.alpha == 0 then
                    table.remove(self.particle, i)
                end
            end

        end
        local w = lstg.world

        object.BulletDo(function(b)
            local flag1 = (b.y - b.a - self.y) * (b.y + b.a - self.y) < 0
            local flag2 = (b.y - b.dy - (self.y - self.dy + self.offy)) * (b.y - self.y) < 0

            if flag1 or flag2 and not b._blue_barrier_flag then
                b._blue_barrier_flag = true
                --  if ran:Int(0,1)==0 then--50%的概率
                self._y = self._y - sign(b.dy)
                --    b.y = self.y
                Del(b)
                self.j = self.j + setting.rdQual / 5
                if self.j > 1 then
                    table.insert(self.particle, {
                        alpha = 0, maxalpha = ran:Float(120, 180),
                        size = ran:Float(4, 9),
                        x = b.x, y = self.y,
                        vx = ran:Float(-2, 2), vy = ran:Float(-2, 2),
                        timer = 0, lifetime = ran:Int(30, 60),
                        rot = ran:Float(0, 360), omega = ran:Float(1, 2) * ran:Sign()
                    })
                    self.j = self.j - 1
                end
                -- end
            end
        end)
        self.offy = 0
        if self._y > w.t - 30 then
            self._y = self._y + 2
            if self.y > w.t + 30 then
                local last_y = self.y
                self.y = w.b - 30
                self._y = w.b + 40
                self.offy = self.y - last_y
            end
        elseif self._y < w.b + 30 then
            self._y = self._y - 2
            if self.y < w.b - 30 then
                local last_y = self.y
                self.y = w.t + 30
                self._y = w.t - 40
                self.offy = self.y - last_y
            end
        end
    end,
    render = function(self)
        local r, g, b = 135, 206, 235
        local col1 = Color(0, r, g, b)
        local col2 = Color(self.alpha * 75, r, g, b)
        SetImageState("white", "mul+add", 666, 0, 0, 0)--刷新存储列表
        OriginalSetImageState("white", "mul+add", col1, col1, col2, col2)
        RenderRect("white", -320, 320, self.y - 1, self.y + 30)
        RenderRect("white", -320, 320, self.y + 1, self.y - 30)
        for _, p in ipairs(self.particle) do
            SetImageState("white", "mul+add", p.alpha, r, g, b)
            misc.SectorRender(p.x, p.y, p.size * 0.9, p.size, 0, 360, 5, p.rot)
        end
    end
}, true)
class.blue_barrier = blue_barrier

local fake_player = Class(object, {
    init = function(self)
        self.bound = false
        self.layer = LAYER.ENEMY_BULLET
        self.group = GROUP.GHOST
        self.x, self.y = player.x, player.y
        self.hscale = 1
        self.vscale = 1
        self.foreverTP = true
        ---作为储存射击子弹的表
        self.shoot_table = {}
        self.borderless_offset = 0--月与海的传送门
        self.outborder_time = 0
        task.New(self, function()
            local w = {}
            task.init_left_wait(w)
            local j = 0
            local gold = (sqrt(5) - 1) / 2
            while true do
                --一对的自我
                local p = player
                local sspeed = p.cur_sspeed / 3
                local interval = 60 / sspeed
                table.insert(self.shoot_table, {
                    offset = w.task_left_wait,
                    offa = (p.shoot_angle_off * gold * j) % max(0.01, p.shoot_angle_off),
                    d = j % 2 * 2 - 1
                })
                j = j + 1
                task.Wait2(w, interval)
            end
        end)
    end,
    frame = function(self)

        task.Do(self)
        local w = lstg.world
        local p = player
        self.x = -p.x
        self.y = p.y
        if p.__shoot_flag and p.nextshoot <= 0 then
            player_class.shoot(p, 1, -p.x + self.x, -p.y + self.y, self.shoot_table)
        end
        for i = #self.shoot_table, 1, -1 do
            table.remove(self.shoot_table, i)
        end
        if lstg.var.borderless_moving then
            if BoxCheck(self, w.pl + 8, w.pr - 8, w.pb + 16, w.pt - 32) then
                self.borderless_offset = min(100, 1 + self.borderless_offset)
                self.outborder_time = 0
            else
                self.borderless_offset = max(0, self.borderless_offset - self.outborder_time / 10)
                self.outborder_time = self.outborder_time + 1
            end
        end
    end,
    render = function(self)
        local p = player
        local reverse_vscale = lstg.var.reverse_shoot and (-1) or 1
        local scale_factor = 0.86
        Render(p.img, self.x, self.y, p.rot, -p.hscale * self.hscale * scale_factor, p.vscale * self.vscale * reverse_vscale * scale_factor)
        local alpha_value = 255
        SetImageState(p.img, "mul+add", alpha_value, 125, 125, 255)
        Render(p.img, self.x, self.y, p.rot, -p.hscale * self.hscale * scale_factor, p.vscale * self.vscale * reverse_vscale * scale_factor)
    end


}, true)
class.fake_player = fake_player

local little_watermelon = Class(object, {

    init = function(self)
        self.bound = false
        self.layer = LAYER.ENEMY_BULLET
        self.group = GROUP.GHOST
        self.x, self.y = ran:Float(-256, 256), ran:Float(-192, 24)
        self.hscale = 1
        self.vscale = 1
        self.foreverTP = true
        ---作为储存射击子弹的表
        self.shoot_table = {}
        self.borderless_offset = 0 --月与海的传送门
        self.outborder_time = 0
        self.index = ran:Float(0.3, 0.6)

        task.New(self, function()
            local w = {}
            task.init_left_wait(w)
            local j = 0
            local gold = (sqrt(5) - 1) / 2
            while true do
                local p = player
                local sspeed = player.cur_sspeed / 8
                local interval = 60 / sspeed
                table.insert(self.shoot_table, {
                    offset = w.task_left_wait,
                    offa = (p.shoot_angle_off * gold * j) % max(0.01, p.shoot_angle_off),
                    d = j % 2 * 2 - 1
                })
                j = j + 1
                task.Wait2(w, interval)
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        local w = lstg.world
        local p = player
        self.x = clamp(self.x + p.dx * self.index, w.pl + 8 - self.borderless_offset, w.pr - 8 + self.borderless_offset)
        self.y = clamp(self.y + p.dy * self.index, w.pb + 16 - self.borderless_offset, w.pt - 32 + self.borderless_offset)

        if p.__shoot_flag and p.nextshoot <= 0 then
            player_class.shoot(p, 0.6, -p.x + self.x, -p.y + self.y, self.shoot_table, player_main_bullet_mangekyou)
        end
        for i = #self.shoot_table, 1, -1 do
            table.remove(self.shoot_table, i)
        end
        if lstg.var.borderless_moving then
            if BoxCheck(self, w.pl + 8, w.pr - 8, w.pb + 16, w.pt - 32) then
                self.borderless_offset = min(100, 1 + self.borderless_offset)
                self.outborder_time = 0
            else
                self.borderless_offset = max(0, self.borderless_offset - self.outborder_time / 10)
                self.outborder_time = self.outborder_time + 1
            end
        end
    end,

    render = function(self)
        local p = player
        local reverse_vscale = lstg.var.reverse_shoot and (-1) or 1
        local scale_factor = 0.4
        local alpha_value = 255
        SetImageState(p.img, "mul+add", alpha_value, 255, 0, 255)
        Render(p.img, self.x, self.y, p.rot, p.hscale * self.hscale * scale_factor, p.vscale * self.vscale * reverse_vscale * scale_factor)
    end


}, true)
class.little_watermelon = little_watermelon

local checkContinuingTP_time = 0
local checkContinuingTP_count = 0
--前十开启，中十循环，后十关闭
local YukariTool = Class(object, {
    init = function(self, x, y, rot)
        object.init(self, x, y, GROUP.GHOST, LAYER.ENEMY_BULLET_EF)
        self.hscale = 0.7
        self.vscale = 0.7
        self.img = "YukariTool1"
        self.colli = false
        self.opposite = nil
        self.rot = rot
        self._yukari_tool_flag = nil
        self.bound = false
        self.event = function(o)
            o.tpcount = o.tpcount or 0
            if (o.tpcount <= 5 or o.foreverTP) and not o.noTPbyYukari then
                x = o.x - self.x
                y = o.y - self.y
                x, y = cos(self.rot) * x + sin(self.rot) * y, cos(self.rot) * y - sin(self.rot) * x
                if abs(x) < 100 and abs(y) < 3 then
                    if not o._yukari_tool_flag then
                        y = -y
                        o.x = self.opposite.x + cos(self.opposite.rot) * x - sin(self.opposite.rot) * y
                        o.y = self.opposite.y + cos(self.opposite.rot) * y + sin(self.opposite.rot) * x
                        local v, a = GetV(o)
                        object.SetV(o, v, a - self.rot + self.opposite.rot, true)
                        if o._index and o.imgclass then
                            Create.bullet_create_eff(o)
                        end
                        o.tpcount = o.tpcount + 1
                        o._yukari_tool_flag = true
                        if o.group == GROUP.ENEMY or o.group == GROUP.NONTJT then
                            if not o.IsBoss and o.auto_delete then
                                o.bound = true
                            end
                            if o.colli and o.class.base.take_damage then
                                o.class.base.take_damage(o, player.damage * 3.5)
                            end
                        end--防止有怪没有清除

                    end
                else
                    o._yukari_tool_flag = false
                end
            end
        end
        task.New(self, function()
            for i = 1, 10 do
                self.img = "YukariTool" .. i
                task.Wait(3)
            end
            local i = 1
            while not self.dk do
                self.img = "YukariTool" .. (10 + i)
                i = sp:TweakValue(i + 1, 10, 1)
                task.Wait(5)
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        local opposite = self.opposite
        if opposite and IsValid(opposite) then
            if lstg.var.frame_counting then
                local x, y
                object.BulletIndesDo(self.event)
                object.EnemyNontjtDo(self.event)
                for _, u in ObjList(GROUP.PLAYER_BULLET) do
                    self.event(u)
                end
                if IsValid(lstg.tmpvar.fake_player) then
                    self.event(lstg.tmpvar.fake_player)
                end
                x = player.x - self.x
                y = player.y - self.y
                x, y = cos(self.rot) * x + sin(self.rot) * y, cos(self.rot) * y - sin(self.rot) * x
                if abs(x) < 100 and abs(y) < 3 then
                    if not self._yukari_tool_flag then
                        y = -y
                        NewBon(player.x, player.y, 60, 100, 135, 206, 235)
                        player.x = opposite.x + cos(opposite.rot) * x - sin(opposite.rot) * y
                        player.y = opposite.y + cos(opposite.rot) * y + sin(opposite.rot) * x
                        self._yukari_tool_flag = true
                        opposite._yukari_tool_flag = true
                        checkContinuingTP_time = 30
                        if checkContinuingTP_time > 0 then
                            checkContinuingTP_count = checkContinuingTP_count + 1
                            if checkContinuingTP_count >= 5 then
                                ext.achievement:get(53)
                            end
                        else
                            checkContinuingTP_count = 1
                        end
                        NewBon(player.x, player.y, 60, 100, 135, 206, 235)
                        if self.x < 0 then
                            PlaySound("warpl")
                        else
                            PlaySound("warpr")
                        end
                    end
                else
                    checkContinuingTP_time = max(checkContinuingTP_time - 1, 0)
                    self._yukari_tool_flag = nil
                end
            end
        end
    end,
    del = function(self)
        if not self.dk then
            object.Preserve(self)
            self.dk = true
            task.New(self, function()
                for i = 21, 30 do
                    self.img = "YukariTool" .. i
                    task.Wait(3)
                end
                object.RawDel(self)
            end)
        end
    end,
    kill = function(self)
        self.class.del(self)
    end
}, true)
class.YukariTool = YukariTool

local scaring_mask = Class(object, {
    init = function(self)
        self.layer = 3
        self.alpha = 0
        self.bound = false
    end,
    frame = function(self)
        task.Do(self)
        self.alpha = (0.2 + 0.15 * sin(-90 + self.timer / 2)) * min(self.timer / 90, 1)
        if lstg.var.frame_counting then
            player_lib.ReduceLife(0.006 * max(lstg.var.maxlife, 50) / 35, "ScaringMask")
        end

        object.EnemyNontjtDo(function(e)
            if e.class.base.take_damage then
                e.class.base.take_damage(e, min(e.maxhp / 180, 0.9))
            end
        end)

    end,
    render = function(self)
        misc.RenderBrightOutline(-320, 320, -240, 240, 200, self.alpha * 255, 0, 0, 0, "")
    end
}, true)
class.scaring_mask = scaring_mask

local sakura_back = Class(object)
function sakura_back:init(u)
    self.bound = false
    self.layer = LAYER.BG + 5
    self.group = GROUP.GHOST
    self.colli = false
    self.sakura = u

end
function sakura_back:frame()
    if not lstg.var.ON_sakura then
        Del(self)
    end
end
function sakura_back:render()
    if self.sakura then
        if self.sakura.black_alpha > 0 then
            if lstg.var.ON_sakura then
                SetImageState("white", "", self.sakura.black_alpha, 0, 0, 0)
            else
                SetImageState("white", "", self.sakura.black_alpha, 255, 255, 255)
            end
            RenderRect("white", lstg.world.l, lstg.world.r, lstg.world.b, lstg.world.t)
        end
        local s = self.sakura.circle
        local player = player
        if s.alpha > 0 then
            SetImageState("Sakura1", "mul+add", s.alpha / 2, 255, 255, 255)
            Render("Sakura1", player.x, player.y, s.rot[1], s.scale)
            SetImageState("Sakura2", "mul+add", s.alpha, 255, 255, 255)
            Render("Sakura2", player.x, player.y, s.rot[2], s.scale)
        end
    end
end
class.sakura_back = sakura_back

local Sakura_bonus = Class(object, { frame = task.Do })
function Sakura_bonus:init(count)
    PlaySound("bonus")
    self.alpha = 0
    self.group = 0
    self.layer = 1
    self.count = count
    lstg.var.score = lstg.var.score + 540000 * count
    task.New(self, function()
        for i = 1, 60 do
            self.alpha = sin(i * 1.5)
            task.Wait()
        end
        task.Wait(120)
        for i = 59, 0, -1 do
            self.alpha = sin(i * 1.5)
            task.Wait()
        end
        Del(self)
    end)
end
function Sakura_bonus:render()
    SetViewMode("ui")
    local w = lstg.world
    ui:RenderText("title", ("Bonus! %d"):format(self.count * 540000), 880, 140 - 20,
            0.8, Color(self.alpha * 255, 255, 230, 255), "centerpoint")
    SetViewMode("world")
end
class.Sakura_bonus = Sakura_bonus

item.sakura = Class(item)
function item.sakura:init(x, y, v, a, get, no)
    item.init(self, x, y, 11, v, a)
    self.get = get or 80
    self.no_up_render = no or nil
    self.omega = ran:Float(1, 3) * ran:Sign()
    if GetnObj() >= 5000 then
        self.class.collect(self)
        Del(self)
    end
end
function item.sakura:collect()
    if lstg.var.ON_sakura then
        lstg.var.score = lstg.var.score + 50
    else
        lstg.var.score = lstg.var.score + 10
    end
    if not lstg.var.ON_sakura then
        lstg.var.sakura = min(50000, lstg.var.sakura + self.get)
    end
end

local back_door = Class(object, {
    init = function(self)
        self.layer = LAYER.PLAYER
        self.img = "level_obj_back_door"
        self.alpha = 0
        self.bound = false
        self.group = GROUP.GHOST
        self.a = 16
        task.New(self, function()
            for i = 1, 30 do
                self.alpha = task.SetMode[2](i / 30)
                task.Wait()
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        local _y = -36
        self.vscale = 1
        if lstg.var.reverse_shoot then
            _y = -_y
            self.vscale = -1
        end
        self.x, self.y = player.x, player.y + _y
        if self.colli then
            cutLasersByCircle(self.x, self.y, self.a)
            object.BulletDo(function(o)
                if Dist(self, o) < self.a then
                    object.Del(o)
                end
            end)
            object.LaserDo(function(o)
                if Dist(self, o) < self.a then
                    if self.kill_indes or not (o.Isradial or o.Isgrowing) then
                        object.Del(o)
                    end
                end
            end)
        end
    end,
    render = function(self)
        SetAnimationState(self.img, "", self.alpha * 200, 255, 255, 255)
        DefaultRenderFunc(self)
    end
}, true)
class.back_door = back_door

local broken_room = Class(object, {
    init = function(self)
        self.layer = LAYER.PLAYER + 25
        self.bound = false
        self.group = GROUP.GHOST
        self.par = {}
    end,
    frame = function(self)
        task.Do(self)
        local p = player
        object.BulletDo(function(b)
            if Dist(b, p) < 40 and not b.__broken_room_check then
                local k = ran:Float(0, 1)
                if k <= 0.24 then
                    table.insert(self.par, {
                        cx = b.x, cy = b.y,
                        timer = 0,
                        lifetime = 60,
                        rx = 0, ry = 0,
                        size = 2,
                        oR = 1, oG = 1, oB = 1
                    })
                    b.x, b.y = ran:Float(-320, 320), ran:Float(-240, 240)

                end
                b.__broken_room_check = true

            end
        end)
        if self.timer % (3 + 5 - setting.rdQual) == 0 then
            local r = ran:Int(1, 3)
            table.insert(self.par, {
                cx = p.x + ran:Float(-40, 40),
                cy = p.y + ran:Float(-40, 40),
                timer = 0,
                lifetime = ran:Int(90, 120),
                rx = 0, ry = 0,
                size = 1,
                oR = (r == 1) and 1 or 0,
                oG = (r == 2) and 1 or 0,
                oB = (r == 3) and 1 or 0
            })
        end
        local k
        for i = #self.par, 1, -1 do
            k = self.par[i]
            k.timer = k.timer + 1
            if k.timer % 10 == 0 then
                k.rx = ran:Float(-2, 2)
                k.ry = ran:Float(-2, 2)
            end
            if k.timer >= k.lifetime then
                table.remove(self.par, i)
            end
        end
    end,
    render = function(self)
        for _, k in ipairs(self.par) do
            local i = 1 - k.timer / k.lifetime
            SetImageState("white", "", i * 150, i * i * 200 * k.oR, i * i * 200 * k.oG, i * i * 200 * k.oB)
            Render("white", k.cx + k.rx, k.cy + k.ry, 0, 0.2 * k.size)
        end
    end
}, true)
class.broken_room = broken_room

local ningyous = { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }

local ningyou_bullet = Class(object, {
    init = function(self, x, y, v, a, dmg)
        player_bullet_straight.init(self, "level_obj_ningyou_bullet", x, y, v, a, dmg)
        self.v = v
        self.hscale = 0.7
        self.vscale = 0.7
        self.trail = 400
    end,
    frame = function(self)
        self.target = player.target
        if IsValid(self.target) and self.target.colli and self.target.class.base.take_damage then
            local a = (Angle(self, self.target) - self.rot) % 360
            if a > 180 then
                a = a - 360
            end
            local da = self.trail / (Dist(self, self.target) + 1)
            if da >= abs(a) then
                self.rot = Angle(self, self.target)
            else
                self.rot = self.rot + sign(a) * da
            end
        end
        self.vx = self.v * cos(self.rot)
        self.vy = self.v * sin(self.rot)
    end,
    render = function(self)
        SetImageState(self.img, "mul+add", 100, 255, 255, 255)
        DefaultRenderFunc(self)
    end,
    kill = function(self)
        New(class.ningyou_bullet_ef, self.x, self.y, self.rot)
    end
})
class.ningyou_bullet = ningyou_bullet

local ningyou_bullet_ef = Class(object, {
    init = function(self, x, y, rot)
        self.x = x
        self.y = y
        self.img = "level_obj_ningyou_bullet"
        self.layer = LAYER.PLAYER_BULLET + 50
        self.group = GROUP.GHOST
        object.SetV(self, 2.25, rot, true)
        self.hscale = 0.7
        self.vscale = 0.7
    end,
    frame = function(self)
        if self.timer == 15 then
            object.RawDel(self)
        end
    end,
    render = function(self)
        local a = 100 * (1 - self.timer / 15)
        SetImageState(self.img, "mul+add", a, 255, 255, 255)
        DefaultRenderFunc(self)
    end,
})
class.ningyou_bullet_ef = ningyou_bullet_ef

local ningyou = Class(object, {
    init = function(self, t)
        ningyous[t] = self
        local A = (t - 1) / 9 * 360 + stage.current_stage.timer
        self.offx, self.offy = cos(A) * 60, sin(A) * 60
        self.x, self.y = player.x + self.offx, player.x + self.offy
        self.t = t
        self.collitime = 0
        self.group = GROUP.PLAYER
        self.layer = LAYER.PLAYER
        self.bound = false
        self.a, self.b = 12, 12
        self.hscale = 0
        self.vscale = 1
        self.alpha = 0
        self.protect = 30
        if lstg.var.buddhist_diamond then
            self.protect = self.protect + 30
        end
        task.New(self, function()
            for i = 1, 10 do
                i = i / 10
                self.alpha = i
                self.hscale = i * 0.5
                self.vscale = 1 - i * 0.5
                task.Wait()
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        local t = stage.current_stage.timer
        local A = (self.t - 1) / 9 * 360 + stage.current_stage.timer
        self.offx, self.offy = cos(A) * 60, sin(A) * 60
        self.protect = max(self.protect - 1, 0)
        local p = player
        self.x = self.x + (-self.x + p.x + self.offx) * 0.7
        self.y = self.y + (-self.y + p.y + self.offy) * 0.7
        self.rot = sin(self.timer * 2) * 10
        if p.__shoot_flag and p.nextshoot <= 0 then
            if (t - self.t * 3) % 75 == 0 then
                local dmg = player.damage
                local ang = 90
                if IsValid(p.target2) then
                    ang = Angle(self, p.target2)
                end
                New(ningyou_bullet, self.x, self.y, 9, ang, 0.5 * self.t + dmg * 0.23)
            end
        end
        if self.colli then
            cutLasersByCircle(self.x, self.y, self.a, function()
                self.collitime = self.collitime + 1
            end)
        end
    end,
    colli = function(self, other)
        if self.protect == 0 then
            self.collitime = self.collitime + 1
            if self.collitime >= 3 then
                if not self.dk then
                    object.Kill(self)
                end
                return
            end
        end
        if other.group == GROUP.ENEMY_BULLET then
            object.Del(other)
        end
    end,
    render = function(self)
        SetAnimationState("level_obj_ningyou_soul", "", self.alpha * 150, 255, 255, 255)
        RenderAnimation("level_obj_ningyou_soul", self.ani, self.x, self.y, 0, self.hscale, self.vscale)
        SetAnimationState("level_obj_ningyou", "", self.alpha * 150, 255, 255, 255)
        RenderAnimation("level_obj_ningyou", self.ani, self.x, self.y, self.rot, self.hscale, self.vscale)
    end,
    kill = function(self)
        object.Preserve(self)
        self.dk = true
        task.New(self, function()
            if lstg.var.life_boom > 0 then
                local r = 60
                local dmg = 0.05 * player.damage
                lifeboom_func(self.x, self.y, r, dmg, 40, 218, 112, 214)
            end
            for i = 9, 0, -1 do
                i = i / 10
                self.alpha = i
                self.hscale = i * 0.5
                self.vscale = 1 - i * 0.5
                task.Wait()
            end
            object.RawDel(self)
        end)
    end
}, true)
class.ningyou = ningyou
local ningyouer = Class(object, {
    init = function(self)
        self.colli = false
        self.hide = true
        local function checkcount()
            local t = 0
            for _, p in pairs(ningyous) do
                if IsValid(p) then
                    t = t + 1
                end
            end
            return t
        end
        task.New(self, function()
            while true do
                local flag = true

                for _ = 1, 30 + 25 * (checkcount()) do
                    if player.death > 0 then
                        flag = false
                        break
                    end
                    task.Wait()
                end
                if flag then
                    if checkcount() < 9 then
                        PlaySound("boon00")
                        local t = 1
                        for _, p in pairs(ningyous) do
                            if IsValid(p) then
                                t = t + 1
                            else
                                break
                            end

                        end
                        New(ningyou, t)

                    end
                else
                    task.Wait(110)
                end
                task.Wait()
            end
        end)
    end,
    frame = task.Do
}, true)
class.ningyouer = ningyouer

local hell_bullet = Class(object, {
    init = function(self, x, y, v, a, dmg)
        player_bullet_straight.init(self, "level_obj_ningyou_bullet", x, y, v, a, dmg)
        self.v = v
        self.hscale = 0.7
        self.vscale = 0.7
        self.trail = 400
    end,
    render = function(self)
        SetImageState(self.img, "mul+add", 100, 255, 255, 255)
        DefaultRenderFunc(self)
    end,
    kill = function(self)
        New(class.hell_bullet_ef, self.x, self.y, self.rot)
    end
})
class.hell_bullet = hell_bullet

local hell_bullet_ef = Class(object, {
    init = function(self, x, y, rot)
        self.x = x
        self.y = y
        self.img = "level_obj_ningyou_bullet"
        self.layer = LAYER.PLAYER_BULLET + 50
        self.group = GROUP.GHOST
        object.SetV(self, 2.25, rot, true)
        self.hscale = 0.7
        self.vscale = 0.7
    end,
    frame = function(self)
        if self.timer == 15 then
            object.RawDel(self)
        end
    end,
    render = function(self)
        local a = 100 * (1 - self.timer / 15)
        SetImageState(self.img, "mul+add", a, 255, 255, 255)
        DefaultRenderFunc(self)
    end,
})
class.hell_bullet_ef = hell_bullet_ef

return class