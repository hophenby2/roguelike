local class = {}
weather_lib.class = class

local YuShuiEff = Class(object, {
    init = function(self)
        self.bubble = {}
        self.group = GROUP.GHOST
        self.layer = 0
        self.back_alpha = 1
    end,
    frame = function(self)
        task.Do(self)
        if lstg.weather.YuShui then
            if self.timer % (6 + 5 - setting.rdQual) == 0 then
                table.insert(self.bubble, {
                    x = ran:Float(-320, 320), y = ran:Float(-240, 240),
                    vy = ran:Float(-0.2, 0.2), vx = ran:Float(-0.1, 0.1),
                    r = ran:Float(90, 120), maxr = ran:Float(100, 150),
                    timer = 0, lifetime = ran:Int(70, 120),
                    alpha = 0, maxalpha = 8
                })
            end

        else
            if #self.bubble == 0 then
                Del(self)
            end
        end
        local b
        for i = #self.bubble, 1, -1 do
            b = self.bubble[i]
            b.x = b.x + b.vx
            b.y = b.y + b.vy
            b.vx = sin(b.timer / b.lifetime * 360 * 2) * 0.1
            b.r = b.r + (-b.r + b.maxr) * 0.05
            if b.timer <= 10 then
                b.alpha = min(b.maxalpha, b.alpha + b.maxalpha / 10)
            elseif b.lifetime - b.timer <= 20 then
                b.alpha = max(0, b.alpha - b.maxalpha / 20)
            end
            if b.timer == b.lifetime then
                table.remove(self.bubble, i)
            end
            b.timer = b.timer + 1
        end
    end,
    render = function(self)
        for _, b in ipairs(self.bubble) do
            SetImageState("white", "mul+add", b.alpha * self.back_alpha, 255, 255, 255)
            misc.SectorRender(b.x, b.y, 0, b.r, 0, 360, 40)
            misc.SectorRender(b.x, b.y, 0, b.r * 0.7, 0, 360, 40)
        end
    end
}, true)
class.YuShuiEff = YuShuiEff

local lightning = function(_x, _y, a, r, v)
    local self = NewObject(Class(bent_laser, {
        frame = function(self)
            bent_laser.frame(self)
            if self.timer < 90 then
                for _ = 1, min(4, setting.rdQual) do
                    local _a = ran:Float(0, 360)
                    local _v = ran:Float(3, 6)
                    table.insert(self.particle, {
                        x = self.x, y = self.y,
                        vx = cos(_a) * _v, vy = sin(_a) * _v,
                        alpha = ran:Float(200, 250), timer = 0,
                        r = self.pcol[1], g = self.pcol[2], b = self.pcol[3]
                    })
                end
            end
            local p
            for i = #self.particle, 1, -1 do
                p = self.particle[i]
                p.x = p.x + p.vx
                p.y = p.y + p.vy
                p.vx = p.vx - p.vx * 0.04
                p.vy = p.vy - p.vy * 0.04
                if p.timer > 10 then
                    p.alpha = max(p.alpha - 5, 0)
                    if p.alpha == 0 then
                        table.remove(self.particle, i)
                    end
                end
                p.timer = p.timer + 1
            end
            self.bound = (#self.particle == 0) and (self.timer > 30)
        end,
        render = function(self)
            bent_laser.render(self)
            for _, p in ipairs(self.particle) do
                SetImageState("bright", "mul+add", p.alpha, p.r, p.g, p.b)
                Render("bright", p.x, p.y, 0, 10 / 150)
            end
        end
    }, true))
    local w = 26
    if lstg.weather.QingMing then
        w = w * 0.5
    end
    if lstg.tmpvar._is_challenge18 then
        w = w * lstg.tmpvar._is_challenge18
    end
    bent_laser.init(self, 6, _x, _y, 60, w, 0, 5)
    object.SetV(self, v, a, true)
    self.particle = {}
    self.pcol = { 250, 250, 250 }
    self.pdmg = 7
    self.dmg_type = "Lightning"
    self.group = GROUP.INDES
    task.New(self, function()
        local s = 90
        while true do
            object.SetV(self, v, a + sin(s) * r, true)
            task.Wait()
            s = s + 40
        end
    end)
end
local JingZhe_lightninger = Class(object, {
    init = function(self)
        self.group = GROUP.GHOST
        self.colli = false
        self.bubble = {}
        self.back_alpha = 0
        self.alpha = 0
        self.particle = {}
        task.New(self, function()
            for i = 1, 60 do
                self.alpha = i / 60
                task.Wait()
            end
        end)
        task.New(self, function()
            local id = 1
            while true do
                task.Wait(ran:Int(120, 180))
                if lstg.var.frame_counting then
                    task.New(self, function()
                        local x = ran:Float(-280, 280)
                        for t = 1, 30 do
                            table.insert(self.particle, {
                                alpha = 0, maxalpha = ran:Float(60, 120),
                                size = ran:Float(3, 6),
                                x = ran:Float(x - 50, x + 50), y = -300 + 480 * t / 35 + ran:Float(-30, 30),
                                vx = ran:Float(-1, 1), vy = ran:Float(1, 3),
                                timer = 0, lifetime = ran:Int(30, 60),
                                rot = ran:Float(0, 360), omega = ran:Float(1, 2) * ran:Sign()
                            })
                            task.Wait()
                        end
                        task.New(self, function()
                            for _ = 1, 60 do
                                object.EnemyNontjtDo(function(e)
                                    if abs(e.x - x) < 50 and e.lightning_attack ~= id then
                                        if e.class.base.take_damage then
                                            if e.IsBoss then
                                                e.hp = max(e.hp - e.maxhp * 0.25, 0)
                                            else
                                                e.hp = 0
                                            end
                                            e.lightning_attack = id
                                        end
                                    end
                                end)
                                object.BulletDo(function(e)
                                    if abs(e.x - x) < 50 then
                                        object.Del(e)
                                    end
                                end)
                                task.Wait()
                            end
                        end)
                        misc.ShakeScreen(60, 2.3, 1, 1.6, 1)
                        for _ = 1, 6 do
                            lightning(x + ran:Float(-12, 12), 260, ran:Float(-7, 7) - 90, ran:Float(8, 20) * ran:Sign(), ran:Float(35, 60))
                        end
                        PlaySound("Lightning", 3, x, false)
                    end)
                end

                id = id + 1
            end
        end)
    end,
    frame = function(self)
        self.back_alpha = (0.4 + 0.15 * sin(self.timer / 2)) * self.alpha
        if lstg.weather.JingZhe then
            task.Do(self)
            if self.timer % (6 + 5 - setting.rdQual) == 0 then
                table.insert(self.bubble, {
                    x = ran:Float(-320, 320), y = ran:Float(-240, 240),
                    vy = ran:Float(-0.2, 0.2), vx = ran:Float(-0.1, 0.1),
                    r = ran:Float(90, 120), maxr = ran:Float(100, 150),
                    timer = 0, lifetime = ran:Int(70, 120),
                    alpha = 0, maxalpha = 8
                })
            end

        else
            self.alpha = max(self.alpha - 1 / 30, 0)
            if #self.bubble == 0 and #self.particle == 0 and self.alpha == 0 then
                Del(self)
            end
        end
        local b
        for i = #self.bubble, 1, -1 do
            b = self.bubble[i]
            b.x = b.x + b.vx
            b.y = b.y + b.vy
            b.vx = sin(b.timer / b.lifetime * 360 * 2) * 0.1
            b.r = b.r + (-b.r + b.maxr) * 0.05
            if b.timer <= 10 then
                b.alpha = min(b.maxalpha, b.alpha + b.maxalpha / 10)
            elseif b.lifetime - b.timer <= 20 then
                b.alpha = max(0, b.alpha - b.maxalpha / 20)
            end
            if b.timer == b.lifetime then
                table.remove(self.bubble, i)
            end
            b.timer = b.timer + 1
        end
        local p
        for i = #self.particle, 1, -1 do
            p = self.particle[i]
            p.x = p.x + p.vx
            p.y = p.y + p.vy
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
    end,
    render = function(self)
        misc.RenderBrightOutline(-320, 320, -240, 240, 200, self.back_alpha * 255, 0, 0, 0, "")
        for _, b in ipairs(self.bubble) do
            SetImageState("white", "mul+add", b.alpha, 218, 112, 214)
            misc.SectorRender(b.x, b.y, 0, b.r, 0, 360, 40)
            misc.SectorRender(b.x, b.y, 0, b.r * 0.7, 0, 360, 40)
        end
        for _, p in ipairs(self.particle) do
            SetImageState("white", "mul+add", p.alpha, 220, 180, 220)
            misc.SectorRender(p.x, p.y, 0, p.size, 0, 360, 10, p.rot)
        end
    end
}, true)
class.JingZhe_lightninger = JingZhe_lightninger

local GuYuEff = Class(object, {
    init = function(self)
        self.bubble = {}
        self.group = GROUP.GHOST
        self.layer = 0
        self.back_alpha = 1
    end,
    frame = function(self)
        task.Do(self)
        if lstg.weather.GuYu then
            if self.timer % (6 + 5 - setting.rdQual) == 0 then
                table.insert(self.bubble, {
                    x = ran:Float(-320, 320), y = ran:Float(-240, 240),
                    vy = ran:Float(-0.2, 0.2), vx = ran:Float(-0.1, 0.1),
                    r = ran:Float(90, 120), maxr = ran:Float(100, 150),
                    timer = 0, lifetime = ran:Int(70, 120),
                    alpha = 0, maxalpha = 8
                })
            end

        else
            if #self.bubble == 0 then
                Del(self)
            end
        end
        local b
        for i = #self.bubble, 1, -1 do
            b = self.bubble[i]
            b.x = b.x + b.vx
            b.y = b.y + b.vy
            b.vx = sin(b.timer / b.lifetime * 360 * 2) * 0.1
            b.r = b.r + (-b.r + b.maxr) * 0.05
            if b.timer <= 10 then
                b.alpha = min(b.maxalpha, b.alpha + b.maxalpha / 10)
            elseif b.lifetime - b.timer <= 20 then
                b.alpha = max(0, b.alpha - b.maxalpha / 20)
            end
            if b.timer == b.lifetime then
                table.remove(self.bubble, i)
            end
            b.timer = b.timer + 1
        end
    end,
    render = function(self)
        for _, b in ipairs(self.bubble) do
            SetImageState("white", "mul+add", b.alpha * self.back_alpha, 255, 227, 132)
            misc.SectorRender(b.x, b.y, 0, b.r, 0, 360, 40)
            misc.SectorRender(b.x, b.y, 0, b.r * 0.7, 0, 360, 40)
        end
    end
}, true)
class.GuYuEff = GuYuEff

local QingLanBullet = function(x, y, v, a, vx, vy)
    local self = NewObject(bullet)
    bullet.init(self, grain_a, 10, false, true)
    self.fogtime = 1
    self.x, self.y = x, y
    object.SetV(self, v, a, true)
    self.omega = ran:Sign() * ran:Float(2, 3)
    self.bound = false
    task.New(self, function()
        task.Wait(60)
        self.bound = true
    end)
    task.New(self, function()
        while true do
            object.SetV(self, v, self.rot)
            self.x = self.x + vx
            self.y = self.y + vy
            task.Wait()
        end
    end)
end
class.QingLanBullet = QingLanBullet

local MangZhongEff = Class(object, {
    init = function(self)
        self.bubble = {}
        self.group = GROUP.GHOST
        self.layer = 0
        self.back_alpha = 1
    end,
    frame = function(self)
        task.Do(self)
        if lstg.weather.MangZhong then
            if self.timer % (6 + 5 - setting.rdQual) == 0 then
                table.insert(self.bubble, {
                    x = ran:Float(-320, 320), y = ran:Float(-240, 240),
                    vy = ran:Float(-0.2, 0.2), vx = ran:Float(-0.1, 0.1),
                    r = ran:Float(90, 120), maxr = ran:Float(100, 150),
                    timer = 0, lifetime = ran:Int(70, 120),
                    alpha = 0, maxalpha = 8
                })
            end

        else
            if #self.bubble == 0 then
                Del(self)
            end
        end
        local b
        for i = #self.bubble, 1, -1 do
            b = self.bubble[i]
            b.x = b.x + b.vx
            b.y = b.y + b.vy
            b.vx = sin(b.timer / b.lifetime * 360 * 2) * 0.1
            b.r = b.r + (-b.r + b.maxr) * 0.05
            if b.timer <= 10 then
                b.alpha = min(b.maxalpha, b.alpha + b.maxalpha / 10)
            elseif b.lifetime - b.timer <= 20 then
                b.alpha = max(0, b.alpha - b.maxalpha / 20)
            end
            if b.timer == b.lifetime then
                table.remove(self.bubble, i)
            end
            b.timer = b.timer + 1
        end
    end,
    render = function(self)
        for _, b in ipairs(self.bubble) do
            SetImageState("white", "mul+add", b.alpha * self.back_alpha, 189, 252, 201)
            misc.SectorRender(b.x, b.y, 0, b.r, 0, 360, 40)
            misc.SectorRender(b.x, b.y, 0, b.r * 0.7, 0, 360, 40)
        end
    end
}, true)
class.MangZhongEff = MangZhongEff

local XiaoShuEff = Class(object, {
    init = function(self)
        self.bubble = {}
        self.group = GROUP.GHOST
        self.layer = 0
        self.back_alpha = 0
        self.alpha = 0
        task.New(self, function()
            for i = 1, 60 do
                self.alpha = i / 60
                task.Wait()
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        self.back_alpha = (0.15 + 0.1 * sin(self.timer)) * self.alpha
        if lstg.weather.XiaoShu then

        else
            self.alpha = max(self.alpha - 1 / 30, 0)
            if self.alpha == 0 then
                Del(self)
            end
        end
    end,
    render = function(self)
        misc.RenderBrightOutline(-320, 320, -240, 240, 200,
                self.back_alpha * 255, 255, 200, 60, "mul+add")
    end
}, true)
class.XiaoShuEff = XiaoShuEff

local DaShuEff = Class(object, {
    init = function(self)
        self.bubble = {}
        self.group = GROUP.GHOST
        self.layer = 0
        self.back_alpha = 0
        self.alpha = 0
        task.New(self, function()
            for i = 1, 60 do
                self.alpha = i / 60
                task.Wait()
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        self.back_alpha = (0.15 + 0.1 * sin(self.timer)) * self.alpha
        if lstg.weather.DaShu then

        else
            self.alpha = max(self.alpha - 1 / 30, 0)
            if self.alpha == 0 then
                Del(self)
            end
        end
    end,
    render = function(self)
        misc.RenderBrightOutline(-320, 320, -240, 240, 200,
                self.back_alpha * 255, 255, 60, 60, "mul+add")
    end
}, true)
class.DaShuEff = DaShuEff

local XiaYuEff = Class(object, {
    init = function(self)
        self.bubble = {}
        self.group = GROUP.GHOST
        self.layer = 0
        self.back_alpha = 1
    end,
    frame = function(self)
        task.Do(self)
        if lstg.weather.XiaYu then
            if self.timer % (6 + 5 - setting.rdQual) == 0 then
                table.insert(self.bubble, {
                    x = ran:Float(-320, 320), y = ran:Float(-240, 240),
                    vy = ran:Float(-0.2, 0.2), vx = ran:Float(-0.1, 0.1),
                    r = ran:Float(90, 120), maxr = ran:Float(100, 150),
                    timer = 0, lifetime = ran:Int(70, 120),
                    alpha = 0, maxalpha = 5
                })
            end
        else
            if #self.bubble == 0 then
                Del(self)
            end
        end
        local b
        for i = #self.bubble, 1, -1 do
            b = self.bubble[i]
            b.x = b.x + b.vx
            b.y = b.y + b.vy
            b.vx = sin(b.timer / b.lifetime * 360 * 2) * 0.1
            b.r = b.r + (-b.r + b.maxr) * 0.05
            if b.timer <= 10 then
                b.alpha = min(b.maxalpha, b.alpha + b.maxalpha / 10)
            elseif b.lifetime - b.timer <= 20 then
                b.alpha = max(0, b.alpha - b.maxalpha / 20)
            end
            if b.timer == b.lifetime then
                table.remove(self.bubble, i)
            end
            b.timer = b.timer + 1
        end
    end,
    render = function(self)
        for _, b in ipairs(self.bubble) do
            SetImageState("white", "mul+add", b.alpha * self.back_alpha, 135, 206, 235)
            misc.SectorRender(b.x, b.y, 0, b.r, 0, 360, 40)
            misc.SectorRender(b.x, b.y, 0, b.r * 0.7, 0, 360, 40)
        end
    end
}, true)
class.XiaYuEff = XiaYuEff

local BaiLuEff = Class(object, {
    init = function(self)
        self.bubble = {}
        self.group = GROUP.GHOST
        self.layer = 0
    end,
    frame = function(self)
        task.Do(self)
        if lstg.weather.BaiLu then
            if self.timer % (6 + 5 - setting.rdQual) == 0 then
                table.insert(self.bubble, {
                    x = ran:Float(-320, 320), y = ran:Float(0, 240),
                    vx = ran:Float(-0.2, 0.2), vy = ran:Float(-2, -1),
                    size = ran:Float(1, 2),
                    timer = 0, lifetime = ran:Int(70, 120),
                    rot = ran:Float(0, 360), omega = ran:Float(1, 2) * ran:Sign(),
                    alpha = 0, maxalpha = 25
                })
            end

        else
            if #self.bubble == 0 then
                Del(self)
            end
        end
        local b
        for i = #self.bubble, 1, -1 do
            b = self.bubble[i]
            b.x = b.x + b.vx
            b.y = b.y + b.vy
            b.rot = b.rot + b.omega
            if b.timer <= 10 then
                b.alpha = min(b.maxalpha, b.alpha + b.maxalpha / 10)
            elseif b.lifetime - b.timer <= 20 then
                b.alpha = max(0, b.alpha - b.maxalpha / 20)
            end
            if b.timer == b.lifetime then
                table.remove(self.bubble, i)
            end
            b.timer = b.timer + 1
        end
    end,
    render = function(self)
        for _, b in ipairs(self.bubble) do
            SetImageState("eff_maple3", "mul+add", b.alpha, 255, 255, 255)
            Render("eff_maple3", b.x, b.y, b.rot, b.size)
        end
    end
}, true)
class.BaiLuEff = BaiLuEff

local QiuFenEff = Class(object, {
    init = function(self)
        self.bubble = {}
        self.group = GROUP.GHOST
        self.layer = 0
    end,
    frame = function(self)
        task.Do(self)
        if lstg.weather.QiuFen then
            if self.timer % (6 + 5 - setting.rdQual) == 0 then
                table.insert(self.bubble, {
                    x = ran:Float(-320, 320), y = ran:Float(0, 240),
                    vx = ran:Float(-0.2, 0.2), vy = ran:Float(-2, -1),
                    size = ran:Float(1, 2),
                    timer = 0, lifetime = ran:Int(70, 120),
                    rot = ran:Float(0, 360), omega = ran:Float(1, 2) * ran:Sign(),
                    alpha = 0, maxalpha = 25
                })
            end

        else
            if #self.bubble == 0 then
                Del(self)
            end
        end
        local b
        for i = #self.bubble, 1, -1 do
            b = self.bubble[i]
            b.x = b.x + b.vx
            b.y = b.y + b.vy
            b.rot = b.rot + b.omega
            if b.timer <= 10 then
                b.alpha = min(b.maxalpha, b.alpha + b.maxalpha / 10)
            elseif b.lifetime - b.timer <= 20 then
                b.alpha = max(0, b.alpha - b.maxalpha / 20)
            end
            if b.timer == b.lifetime then
                table.remove(self.bubble, i)
            end
            b.timer = b.timer + 1
        end
    end,
    render = function(self)
        for _, b in ipairs(self.bubble) do
            SetImageState("eff_maple3", "mul+add", b.alpha, 255, 255, 255)
            Render("eff_maple3", b.x, b.y, b.rot, b.size)
        end
    end
}, true)
class.QiuFenEff = QiuFenEff

local DongZhiEff = Class(object, {
    init = function(self)
        self.bubble = {}
        self.group = GROUP.GHOST
        self.layer = 0
        self.back_alpha = 0
        self.alpha = 0
        task.New(self, function()
            for i = 1, 60 do
                self.alpha = i / 60
                task.Wait()
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        self.back_alpha = (0.15 + 0.1 * sin(self.timer)) * self.alpha
        if lstg.weather.DongZhi then

        else
            self.alpha = max(self.alpha - 1 / 30, 0)
            if self.alpha == 0 then
                Del(self)
            end
        end
    end,
    render = function(self)
        misc.RenderBrightOutline(-320, 320, -240, 240, 200,
                self.back_alpha * 198, 255, 255, 255, "mul+add")
    end
}, true)
class.DongZhiEff = DongZhiEff

LoadTexture2("Poison", "assets\\weather\\Poison.png")

local XiaoHanFog = Class(object, {
    render = function(self)
        local color1 = Color(self._a * 0.8, 50, 200, 200)
        local color2 = Color(0, 50, 200, 200)
        local point = 12
        local r = 100
        local ang = 360 / (2 * point)
        local uv1, uv2, uv3, uv4 = { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }
        uv1[6], uv2[6] = color2, color2
        uv3[1], uv3[2], uv3[4], uv3[5], uv3[6] = self.x, self.y, self.imgx, self.imgy, color1
        uv4[1], uv4[2], uv4[4], uv4[5], uv4[6] = self.x, self.y, self.imgx, self.imgy, color1
        for angle = 360 / point, 360, 360 / point do
            uv1[1], uv1[2], uv1[4], uv1[5] = self.x + r * cos(angle + ang), self.y + r * sin(angle + ang), self.imgx + r * cos(angle + ang), self.imgy + r * sin(angle + ang)
            uv2[1], uv2[2], uv2[4], uv2[5] = self.x + r * cos(angle - ang), self.y + r * sin(angle - ang), self.imgx + r * cos(angle - ang), self.imgy + r * sin(angle - ang)
            RenderTexture("Poison", "add+alpha", uv1, uv2, uv3, uv4)
        end
    end,
    frame = function(self)
        task.Do(self)
        self.imgx = self.imgx + self.imgvx
        self.imgy = self.imgy + self.imgvy
        local r = 100
        if self._bound and not BoxCheck(self, lstg.world.l - r, lstg.world.r + r, lstg.world.b - r, lstg.world.t + r) then
            Del(self)
        end
        local R = 90
        local function SlowFunc(e, k)
            if Dist(e, self) < R and not e._xiaohan_slowed and not e.not_move then
                sp:UnitSetVIndex(e, k)
                e._xiaohan_slowed = true
            end
        end
        object.EnemyNontjtDo(function(e)
            SlowFunc(e, -0.6)
        end)
        object.BulletIndesDo(function(e)
            SlowFunc(e, -0.6)
        end)
        SlowFunc(player, -0.4)
    end,
    init = function(self, x, y, v, a)
        self.x, self.y = x, y
        self.layer = LAYER.TOP
        self.group = GROUP.GHOST
        self.imgx, self.imgy = ran:Float(-256, 256), ran:Float(-256, 256)
        self.imgvx, self.imgvy = ran:Float(-2, 2), ran:Float(-2, 2)
        self.colli = false
        self.angle = ran:Float(0, 360)
        self.omega = ran:Sign() * ran:Float(0.5, 1)
        self.rot = ran:Float(0, 360)
        self.bound = false
        self._bound = true
        self._a = 0
        task.New(self, function()
            for i = 1, 25 do
                self._a = i / 25 * 255
                task.Wait()
            end
            task.Wait(45)
            for i = 1, 30 do
                self._a = (1 - i / 30) * 255
                task.Wait()
            end
            Del(self)
        end)
        task.New(self, function()
            object.ChangingV(self, v, 0, a, 60, false)
        end)
    end
}, true)
class.XiaoHanFog = XiaoHanFog

local ShenJingEff = Class(object, {
    init = function(self)
        self.bubble = {}
        self.group = GROUP.GHOST
        self.layer = 0
        self.back_alpha = 0
        self.alpha = 0
        self.H = 0
        self.R, self.G, self.B = 0, 0, 0
        task.New(self, function()
            for i = 1, 60 do
                self.alpha = i / 60
                task.Wait()
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        self.H = self.H + 2
        self.R, self.G, self.B = sp:HSVtoRGB(self.H, 0.6, 1)
        self.back_alpha = (0.15 + 0.1 * sin(self.timer)) * self.alpha
        if lstg.weather.ShenJing then

        else
            self.alpha = max(self.alpha - 1 / 30, 0)
            if self.alpha == 0 then
                Del(self)
            end
        end
    end,
    render = function(self)
        misc.RenderBrightOutline(-320, 320, -240, 240, 200,
                self.back_alpha * 255, self.R, self.G, self.B, "mul+add")
    end
}, true)
class.ShenJingEff = ShenJingEff

local BiShiEff = Class(object, {
    init = function(self)
        self.bubble = {}
        self.group = GROUP.GHOST
        self.layer = 0
        self.back_alpha = 0
        self.alpha = 0
        task.New(self, function()
            for i = 1, 60 do
                self.alpha = i / 60
                task.Wait()
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        self.back_alpha = (0.27 + 0.02 * sin(self.timer)) * self.alpha
        if lstg.weather.BiShi then
        else
            self.alpha = max(self.alpha - 1 / 30, 0)
            if self.alpha == 0 then
                Del(self)
            end
        end
    end,
    render = function(self)
        misc.RenderBrightOutline(-320, 320, -240, 240, 400,
                self.back_alpha * 255, 255, 255, 255, "mul+add")
    end
}, true)
class.BiShiEff = BiShiEff

local KuangQiEff = Class(object, {
    init = function(self)
        self.bubble = {}
        self.group = GROUP.GHOST
        self.layer = 0
        self.back_alpha = 0
        self.alpha = 0
        self.px, self.py = player.x, player.y
        task.New(self, function()
            for i = 1, 60 do
                self.alpha = i / 60
                task.Wait()
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        self.px = self.px + (-self.px + player.x) * 0.06
        self.py = self.py + (-self.py + player.y) * 0.06
        self.back_alpha = (0.17 + 0.05 * sin(self.timer)) * self.alpha
        if lstg.weather.KuangQi then
        else
            self.alpha = max(self.alpha - 1 / 30, 0)
            if self.alpha == 0 then
                Del(self)
            end
        end
    end,
    render = function(self)
        SetImageState("eyeL", "mul+add", 50 * self.alpha, 255, 255, 255)

        SetImageState("eyeR", "mul+add", 50 * self.alpha, 255, 255, 255)
        for k = 1, 10 + setting.rdQual do
            local A = Angle(0, 120, self.px, self.py)
            k = k * 2
            Render("eyeL", -150 + k * cos(A), 150 + k * sin(A), 0, k / 10)
            Render("eyeR", 150 + k * cos(A), 150 + k * sin(A), -20, k / 10)
        end
        misc.RenderBrightOutline(-320, 320, -240, 240, 200,
                self.back_alpha * 255, 250, 128, 114, "mul+add")
    end
}, true)
class.KuangQiEff = KuangQiEff

local XuanWoEff = Class(object, {
    init = function(self)
        self.bubble = {}
        self.group = GROUP.GHOST
        self.layer = 0
        self.back_alpha = 0
        self.alpha = 0
        task.New(self, function()
            for i = 1, 60 do
                self.alpha = i / 60
                task.Wait()
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        self.back_alpha = (0.35 + 0.1 * sin(self.timer)) * self.alpha
        if lstg.weather.XuanWo then

        else
            self.alpha = max(self.alpha - 1 / 30, 0)
            if self.alpha == 0 then
                Del(self)
            end
        end
    end,
    render = function(self)
        misc.RenderTexInRect("th12_6", -320, 320, -240, 240,
                0, 0, self.timer * 0.39, 2.5, 2.5,
                "mul+rev", Color(self.back_alpha * 160, 255, 255, 255))
    end
}, true)
class.XuanWoEff = XuanWoEff

local ZhenYuEff = Class(object, {
    init = function(self)
        object.init(self, 0, 0, GROUP.GHOST, LAYER.TOP - 1)
        self.rain = {}
    end,
    frame = function(self)
        task.Do(self)
        if lstg.weather.ZhenYu then
            if self.timer % (1 + 5 - setting.rdQual) == 0 then
                table.insert(self.rain, { x = ran:Float(-320, 320), y = 250,
                                          vy = -16, len = ran:Float(20, 70), alpha = ran:Float(40, 60) })
            end
        else
            if #self.rain == 0 then
                Del(self)
            end
        end
        local w
        for i = #self.rain, 1, -1 do
            w = self.rain[i]
            w.y = w.y + w.vy
            if w.y < -300 then
                table.remove(self.rain, i)
            end
        end

    end,
    render = function(self)
        for _, w in ipairs(self.rain) do
            SetImageState("white", "mul+add", w.alpha, 200, 200, 200)
            Render("white", w.x, w.y, 0, 0.08, w.len / 16)
        end
    end
}, true)
class.ZhenYuEff = ZhenYuEff

local GanYaoEff = Class(object, {
    init = function(self)
        self.bubble = {}
        self.group = GROUP.GHOST
        self.layer = 0
        self.back_alpha = 0
        self.alpha = 0
        self.R, self.G, self.B = 0, 255, 255
        task.New(self, function()
            for i = 1, 60 do
                self.alpha = i / 60
                task.Wait()
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        self.back_alpha = (0.15 + 0.1 * sin(self.timer)) * self.alpha
        if lstg.weather.GanYao then

        else
            self.alpha = max(self.alpha - 1 / 30, 0)
            if self.alpha == 0 then
                Del(self)
            end
        end
    end,
    render = function(self)
        misc.RenderBrightOutline(-320, 320, -240, 240, 150,
                self.back_alpha * 255, self.R, self.G, self.B, "mul+rev")
    end
}, true)
class.GanYaoEff = GanYaoEff

local NiZhuanEff = Class(object, {
    init = function(self)
        self.bubble = {}
        self.group = GROUP.GHOST
        self.layer = 0
        self.back_alpha = 0
        self.alpha = 0
        task.New(self, function()
            for i = 1, 60 do
                self.alpha = i / 60
                task.Wait()
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        self.back_alpha = (0.35 + 0.1 * sin(self.timer)) * self.alpha
        if lstg.weather.NiZhuan then

        else
            self.alpha = max(self.alpha - 1 / 30, 0)
            if self.alpha == 0 then
                Del(self)
            end
        end
    end,
    render = function(self)
        misc.RenderTexInRect("th14_8", -320, 320, -240, 240,
                0, self.timer / 2, 0, 1, 1,
                "mul+rev", Color(self.back_alpha * 90, 255, 255, 255))
    end
}, true)
class.NiZhuanEff = NiZhuanEff

local ZuanShiChenEff = Class(object, {
    init = function(self)
        self.bubble = {}
        self.group = GROUP.GHOST
        self.layer = 0
        self.back_alpha = 0
        self.alpha = 0
        self.particle = {}
        self.particle2 = {}
        task.New(self, function()
            for i = 1, 60 do
                self.alpha = i / 60
                task.Wait()
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        self.back_alpha = (0.35 + 0.1 * sin(self.timer)) * self.alpha
        if lstg.weather.ZuanShiChen then
            if self.timer % (1 + 5 - setting.rdQual) == 0 then
                table.insert(self.particle, {
                    alpha = 0, maxalpha = ran:Float(12, 20),
                    size = ran:Float(10, 30),
                    rindex = 0,
                    x = ran:Float(-320, 320), y = ran:Float(-240, 240),
                    vx = ran:Float(-0.05, 0.05), vy = ran:Float(-0.05, 0.05),
                    timer = 0, lifetime = ran:Int(60, 90)
                })
            end
            if self.timer % (3 + 5 - setting.rdQual) == 0 then
                local v = 0.4
                table.insert(self.particle2, {
                    alpha = 0, maxalpha = 255,
                    size = ran:Float(1, 2) * ran:Int(1, 2),
                    x = ran:Float(-320, 320), y = ran:Float(-240, 240),
                    v = v, rotate = ran:Float(0, 360), o = ran:Float(1, 2) * ran:Sign(),
                    timer = 0, lifetime = ran:Int(75, 120),
                })
            end
        else
            self.alpha = max(self.alpha - 1 / 30, 0)
            if self.alpha == 0 then
                Del(self)
            end
        end
        local p
        for i = #self.particle, 1, -1 do
            p = self.particle[i]
            p.x = p.x + p.vx
            p.y = p.y + p.vy
            p.timer = p.timer + 1
            if p.timer <= 20 then
                p.alpha = p.timer / 20 * p.maxalpha
            elseif p.timer > p.lifetime - 20 then
                p.alpha = max(p.alpha - p.maxalpha / 20, 0)
                if p.alpha == 0 then
                    table.remove(self.particle, i)
                end
            end

        end
        for i = #self.particle2, 1, -1 do
            p = self.particle2[i]
            p.rotate = p.rotate + p.o
            local vx = p.v * cos(p.rotate)
            local vy = p.v * sin(p.rotate)
            p.x = p.x + vx
            p.y = p.y + vy

            p.timer = p.timer + 1
            if p.timer <= 10 then
                p.alpha = min(p.maxalpha, p.alpha + p.maxalpha / 10)
            elseif p.timer > p.lifetime - 10 then
                p.alpha = max(p.alpha - p.maxalpha / 10, 0)
                if p.alpha == 0 then
                    table.remove(self.particle2, i)
                end
            end

        end
    end,
    render = function(self)
        for _, p in ipairs(self.particle2) do
            SetImageState("bright", "mul+add", p.alpha * self.alpha, 135, 206, 235)
            Render("bright", p.x, p.y, 0, p.size / 130)
        end
        for _, p in ipairs(self.particle) do
            local size = Dist(p.x, p.y, player)^0.6
            SetImageState("white", "mul+add", p.alpha * self.alpha, 250, 250, 250)
            misc.SectorRender(self.x + p.x, self.y + p.y, size * p.rindex, size, 0, 360, 20, 45)
        end
    end
}, true)
class.ZuanShiChenEff = ZuanShiChenEff

local weatherXEff = Class(object, {
    init = function(self)
        self.bubble = {}
        self.group = GROUP.GHOST
        self.layer = LAYER.BG + 5
        self.back_alpha = 0
        self.alpha = 0
        task.New(self, function()
            for i = 1, 60 do
                self.alpha = i / 60
                task.Wait()
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        self.back_alpha = (0.35 + 0.1 * sin(self.timer)) * self.alpha
        if lstg.weather.weatherX then

        else
            self.alpha = max(self.alpha - 1 / 30, 0)
            if self.alpha == 0 then
                Del(self)
            end
        end
    end,
    render = function(self)
        misc.RenderTexInRect("th12_13", -320, 320, -240, 240,
                -self.timer / 3, -self.timer / 2, 0, 1, 1,
                "", Color(self.back_alpha * 200, 255, 255, 255))
        misc.RenderTexInRect("th12_13", -320, 320, -240, 240,
                self.timer / 3, -self.timer / 2, 0, 1, 1,
                "", Color(self.back_alpha * 200, 255, 255, 255))
    end
}, true)
class.weatherXEff = weatherXEff

local YunYingEff = Class(object, {
    init = function(self)
        self.bubble = {}
        self.group = GROUP.GHOST
        self.layer = 0
        self.back_alpha = 0
        self.alpha = 0
        self.particle = {}
        task.New(self, function()
            for i = 1, 60 do
                self.alpha = i / 60
                task.Wait()
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        self.back_alpha = (0.35 + 0.1 * sin(self.timer)) * self.alpha
        if lstg.weather.YunYing then
            if self.timer % (1 + 5 - setting.rdQual) == 0 then
                table.insert(self.particle, {
                    alpha = 0, maxalpha = ran:Float(40, 70),
                    size = ran:Float(2, 8),
                    rindex = 0,
                    x = ran:Float(-320, 320), y = ran:Float(-240, 240),
                    vx = 0, vy = ran:Float(-0.25, -0.6),
                    timer = 0, lifetime = ran:Int(30, 60)
                })
            end

        else
            self.alpha = max(self.alpha - 1 / 30, 0)
            if self.alpha == 0 then
                Del(self)
            end
        end
        local p
        for i = #self.particle, 1, -1 do
            p = self.particle[i]
            p.x = p.x + p.vx
            p.y = p.y + p.vy
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
    end,
    render = function(self)

        for _, p in ipairs(self.particle) do
            SetImageState("white", "mul+add", p.alpha * self.alpha, 218, 112, 214)
            misc.SectorRender(self.x + p.x, self.y + p.y, p.size * p.rindex, p.size, 0, 360, 4, 0)
        end
    end
}, true)
class.YunYingEff = YunYingEff

local function PutYunYing(x, y)
    sakura_big.New(x, y, ran:Float(0, 360), ran:Sign(), 0, 0, function(self)
        task.New(self, function()
            task.Wait(60)
            local chaos = lstg.var.chaos
            local a = ran:Float(0, 360)
            local v = ran:Float(1, 2) * min(5, 1 + chaos / 200)
            self.max = cos(a) * v / 200
            self.may = sin(a) * v / 200
            self.mmaxvx = abs(cos(a) * v)
            self.mmaxvy = abs(sin(a) * v)
            task.New(self, function()
                while true do
                    task.Wait(30)
                    if ran:Float(0, 1) < 0.1 then
                        break
                    end

                end
                self.colli = false
                for i = 1, 15 do
                    self._a = 255 - 255 * i / 15
                    task.Wait()
                end
                object.RawDel(self)
            end)
        end)
    end)

end
class.PutYunYing = PutYunYing

local ChunWuFog = Class(object, {
    render = function(self)
        local R, G, B = 180, 180, 180
        local color1 = Color(self._a, R, G, B)
        local color2 = Color(0, R, G, B)
        local point = 12
        local r = 175
        local ang = 360 / (2 * point)
        local uv1, uv2, uv3, uv4 = { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }
        uv1[6], uv2[6] = color2, color2
        uv3[1], uv3[2], uv3[4], uv3[5], uv3[6] = self.x, self.y, self.imgx, self.imgy, color1
        uv4[1], uv4[2], uv4[4], uv4[5], uv4[6] = self.x, self.y, self.imgx, self.imgy, color1
        for angle = 360 / point, 360, 360 / point do
            uv1[1], uv1[2], uv1[4], uv1[5] = self.x + r * cos(angle + ang), self.y + r * sin(angle + ang), self.imgx + r * cos(angle + ang), self.imgy + r * sin(angle + ang)
            uv2[1], uv2[2], uv2[4], uv2[5] = self.x + r * cos(angle - ang), self.y + r * sin(angle - ang), self.imgx + r * cos(angle - ang), self.imgy + r * sin(angle - ang)
            RenderTexture("Poison", "add+alpha", uv1, uv2, uv3, uv4)
        end
    end,
    frame = function(self)
        task.Do(self)
        self.imgx = self.imgx + self.imgvx
        self.imgy = self.imgy + self.imgvy
        local r = 175
        if self._bound and not BoxCheck(self, lstg.world.l - r, lstg.world.r + r, lstg.world.b - r, lstg.world.t + r) then
            Del(self)
        end
    end,
    init = function(self, x, y, v, a)
        self.x, self.y = x, y
        self.layer = LAYER.TOP
        self.group = GROUP.GHOST
        self.imgx, self.imgy = ran:Float(-256, 256), ran:Float(-256, 256)
        self.imgvx, self.imgvy = ran:Float(-2, 2), ran:Float(-2, 2)
        self.colli = false
        self.angle = ran:Float(0, 360)
        self.omega = ran:Sign() * ran:Float(0.5, 1)
        self.rot = ran:Float(0, 360)
        self.bound = false
        self._bound = true
        self._a = 0
        task.New(self, function()
            for i = 1, 25 do
                self._a = i / 25 * 255
                task.Wait()
            end
            task.Wait(180 - 25 - 30)
            for i = 1, 30 do
                self._a = (1 - i / 30) * 255
                task.Wait()
            end
            Del(self)
        end)
        task.New(self, function()
            object.ChangingV(self, v, 0, a, 60, false)
        end)
    end
}, true)
class.ChunWuFog = ChunWuFog

local ChunWuEff = Class(object, {
    init = function(self)
        self.bubble = {}
        self.group = GROUP.GHOST
        self.layer = 0
        self.back_alpha = 1
    end,
    frame = function(self)
        task.Do(self)
        if lstg.weather.ChunWu then
            if self.timer % (6 + 5 - setting.rdQual) == 0 then
                table.insert(self.bubble, {
                    x = ran:Float(-320, 320), y = ran:Float(-240, 240),
                    vy = ran:Float(-0.2, 0.2), vx = ran:Float(-0.1, 0.1),
                    r = ran:Float(90, 120), maxr = ran:Float(100, 150),
                    timer = 0, lifetime = ran:Int(70, 120),
                    alpha = 0, maxalpha = 8
                })
            end

        else
            if #self.bubble == 0 then
                Del(self)
            end
        end
        local b
        for i = #self.bubble, 1, -1 do
            b = self.bubble[i]
            b.x = b.x + b.vx
            b.y = b.y + b.vy
            b.vx = sin(b.timer / b.lifetime * 360 * 2) * 0.1
            b.r = b.r + (-b.r + b.maxr) * 0.05
            if b.timer <= 10 then
                b.alpha = min(b.maxalpha, b.alpha + b.maxalpha / 10)
            elseif b.lifetime - b.timer <= 20 then
                b.alpha = max(0, b.alpha - b.maxalpha / 20)
            end
            if b.timer == b.lifetime then
                table.remove(self.bubble, i)
            end
            b.timer = b.timer + 1
        end
    end,
    render = function(self)
        for _, b in ipairs(self.bubble) do
            SetImageState("white", "mul+add", b.alpha * self.back_alpha, 255, 255, 255)
            misc.SectorRender(b.x, b.y, 0, b.r, 0, 360, 40)
            misc.SectorRender(b.x, b.y, 0, b.r * 0.7, 0, 360, 40)
        end
    end
}, true)
class.ChunWuEff = ChunWuEff
