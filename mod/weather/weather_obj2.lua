local class = weather_lib.class

local TianQiYuEff = Class(object, {
    init = function(self)
        self.bubble = {}
        self.group = GROUP.GHOST
        self.layer = 0
        self.back_alpha = 0
        self.alpha = 0
        self.particle = {}
        self.rain = {}
        self.x, self.y = 320, 240
        self.bound = false
        self.j = 0
        task.New(self, function()
            for i = 1, 60 do
                self.alpha = i / 60
                task.Wait()
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        local s = min(1, self.timer / 120) * self.timer
        local A = 90 + sin(s * 0.18) * 25
        self.x = cos(A) * 270
        self.y = sin(A) * 270
        self.back_alpha = (0.35 + 0.1 * sin(self.timer)) * self.alpha
        if lstg.weather.TianQiYu then
            if self.timer % (1 + 5 - setting.rdQual) == 0 then
                local pA = ran:Float(0, 360)
                local pV = ran:Float(7, 14)
                table.insert(self.particle, {
                    alpha = 0, maxalpha = ran:Float(40, 70),
                    size = ran:Float(2, 4),
                    x = self.x, y = self.y,
                    vx = cos(pA) * pV, vy = sin(pA) * pV,
                    timer = 0, lifetime = ran:Int(30, 60)
                })
                self.j = self.j + setting.rdQual / 5 * 0.5
                if self.j >= 1 then
                    table.insert(self.rain, { x = ran:Float(-320, 320), y = 250,
                                              vy = -10, len = ran:Float(20, 70), alpha = ran:Float(30, 50) })
                    self.j = self.j - 1
                end

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
            if not p.issmear then
                local inc = 2 + 2 * (1 - setting.rdQual / 5)
                local dx, dy = p.vx, p.vy
                local d = hypot(dx, dy)
                local count = int(d / inc)
                local ix = inc * (dx / d)
                local iy = inc * (dy / d)
                for c = 0, count do
                    table.insert(self.particle, {
                        alpha = 30, maxalpha = 30,
                        size = p.size,
                        x = p.x - c * ix,
                        y = p.y - c * iy,
                        vx = 0, vy = 0,
                        timer = 0, lifetime = 15,
                        issmear = true
                    })
                end
            end
            p.x = p.x + p.vx
            p.y = p.y + p.vy

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
        local R, G, B = 255, 227, 132
        SetImageState("bright", "mul+add", self.alpha * 160 * self.back_alpha, R, G, B)
        Render("bright", self.x, self.y, 0, 6)
        Render("bright", self.x, self.y, 0, 3)
        Render("bright", self.x, self.y, 0, 0.3)
        for _, p in ipairs(self.particle) do
            SetImageState("bright", "mul+add", p.alpha * self.alpha, R, G, B)
            Render("bright", p.x, p.y, 0, p.size / 130)
        end
        for _, w in ipairs(self.rain) do
            SetImageState("white", "mul+add", w.alpha, 200, 200, 200)
            Render("white", w.x, w.y, 0, 0.08, w.len / 16)
        end
    end
}, true)
class.TianQiYuEff = TianQiYuEff

local QiuLaoHuEff = Class(object, {
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
        self.back_alpha = (0.15 + 0.1 * sin(self.timer)) * self.alpha
        if lstg.weather.QiuLaoHu then
            if self.timer % (1 + 5 - setting.rdQual) == 0 then

                table.insert(self.particle, {
                    alpha = 0, maxalpha = ran:Float(40, 70),
                    size = ran:Float(2, 5),
                    rindex = 0,
                    x = ran:Float(-320, 320), y = ran:Float(-240, 240),
                    vx = ran:Float(-0.05, 0.05), vy = ran:Float(-0.05, 0.05),
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
            if not p.issmear then
                table.insert(self.particle, {
                    alpha = 0, maxalpha = ran:Float(40, 70),
                    size = p.size * 0.7,
                    rindex = 0,
                    x = p.x, y = p.y,
                    vx = 0, vy = 1,
                    timer = 0, lifetime = ran:Int(30, 60),
                    issmear = true
                })
            else
                p.size = p.size * 0.95
            end
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
        misc.RenderBrightOutline(-320, 320, -240, 240, 200,
                self.back_alpha * 255, 255, 60, 60, "mul+add")
        for _, p in ipairs(self.particle) do
            SetImageState("white", "mul+add", p.alpha * self.alpha, 250, 128, 114)
            misc.SectorRender(self.x + p.x, self.y + p.y, p.size * p.rindex, p.size, 0, 360, 4, 45)
        end
    end
}, true)
class.QiuLaoHuEff = QiuLaoHuEff

local FeiKongEff = Class(object, {
    init = function(self)
        self.bubble = {}
        self.group = GROUP.GHOST
        self.layer = 0
        self.back_alpha = 0
        self.alpha = 0
        self.particle = {}
        self.x, self.y = 320, 240
        self.bound = false
        task.New(self, function()
            for i = 1, 60 do
                self.alpha = i / 60
                task.Wait()
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        local s = min(1, self.timer / 120) * self.timer
        local A = 90 + sin(s * 0.18) * 25
        self.x = cos(A) * 270
        self.y = sin(A) * 270
        self.back_alpha = (0.35 + 0.1 * sin(self.timer)) * self.alpha
        if lstg.weather.FeiKong then
            if self.timer % (1 + 5 - setting.rdQual) == 0 then
                local pA = ran:Float(0, 360)
                local pV = ran:Float(7, 14)
                table.insert(self.particle, {
                    alpha = 0, maxalpha = ran:Float(40, 70),
                    size = ran:Float(2, 4),
                    x = self.x, y = self.y,
                    vx = cos(pA) * pV, vy = sin(pA) * pV,
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
            if not p.issmear then
                local inc = 2 + 2 * (1 - setting.rdQual / 5)
                local dx, dy = p.vx, p.vy
                local d = hypot(dx, dy)
                local count = int(d / inc)
                local ix = inc * (dx / d)
                local iy = inc * (dy / d)
                for c = 0, count do
                    table.insert(self.particle, {
                        alpha = 30, maxalpha = 30,
                        size = p.size,
                        x = p.x - c * ix,
                        y = p.y - c * iy,
                        vx = 0, vy = 0,
                        timer = 0, lifetime = 15,
                        issmear = true
                    })
                end
            end
            p.x = p.x + p.vx
            p.y = p.y + p.vy

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
        local R, G, B = 250, 100, 90
        SetImageState("bright", "mul+add", self.alpha * 250 * self.back_alpha, R, G, B)
        Render("bright", self.x, self.y, 0, 6)
        Render("bright", self.x, self.y, 0, 3)
        Render("bright", self.x, self.y, 0, 0.3)
        for _, p in ipairs(self.particle) do
            SetImageState("bright", "mul+add", p.alpha * self.alpha, R, G, B)
            Render("bright", p.x, p.y, 0, p.size / 130)
        end
    end
}, true)
class.FeiKongEff = FeiKongEff

local DongYuEff = Class(object, {
    init = function(self)
        object.init(self, 0, 0, GROUP.GHOST, LAYER.TOP - 1)
        self.rain = {}
    end,
    frame = function(self)
        task.Do(self)
        if lstg.weather.DongYu then
            if self.timer % (4 + 5 - setting.rdQual) == 0 then
                table.insert(self.rain, { x = ran:Float(-320, 320), y = 250,
                                          vy = -6, len = ran:Float(20, 70), alpha = ran:Float(40, 60) })
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
            SetImageState("white", "mul+add", w.alpha, 135, 206, 235)
            Render("white", w.x, w.y, 0, 0.1, w.len / 16)
        end
    end
}, true)
class.DongYuEff = DongYuEff

local XinYangEff = Class(object, {
    init = function(self)
        self.bubble = {}
        self.group = GROUP.GHOST
        self.layer = 0
        self.back_alpha = 0
        self.alpha = 0
        self.particle = {}
        self.x, self.y = 320, 240
        self.bound = false
        task.New(self, function()
            for i = 1, 60 do
                self.alpha = i / 60
                task.Wait()
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        local s = min(1, self.timer / 120) * self.timer
        local A = 90 + sin(s * 0.18) * 25
        self.x = cos(A) * 270
        self.y = sin(A) * 270
        self.back_alpha = (0.35 + 0.1 * sin(self.timer)) * self.alpha
        if lstg.weather.XinYang then
            if self.timer % (1 + 5 - setting.rdQual) == 0 then
                local pA = ran:Float(0, 360)
                local pV = ran:Float(7, 14)
                table.insert(self.particle, {
                    alpha = 0, maxalpha = ran:Float(40, 70),
                    size = ran:Float(2, 4),
                    x = self.x, y = self.y,
                    vx = cos(pA) * pV, vy = sin(pA) * pV,
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
            if not p.issmear then
                local inc = 2 + 2 * (1 - setting.rdQual / 5)
                local dx, dy = p.vx, p.vy
                local d = hypot(dx, dy)
                local count = int(d / inc)
                local ix = inc * (dx / d)
                local iy = inc * (dy / d)
                for c = 0, count do
                    table.insert(self.particle, {
                        alpha = 30, maxalpha = 30,
                        size = p.size,
                        x = p.x - c * ix,
                        y = p.y - c * iy,
                        vx = 0, vy = 0,
                        timer = 0, lifetime = 15,
                        issmear = true
                    })
                end
            end
            p.x = p.x + p.vx
            p.y = p.y + p.vy

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
        local R, G, B = 218, 112, 214
        SetImageState("bright", "mul+add", self.alpha * 250 * self.back_alpha, R, G, B)
        Render("bright", self.x, self.y, 0, 6)
        Render("bright", self.x, self.y, 0, 3)
        Render("bright", self.x, self.y, 0, 0.3)
        for _, p in ipairs(self.particle) do
            SetImageState("bright", "mul+add", p.alpha * self.alpha, R, G, B)
            Render("bright", p.x, p.y, 0, p.size / 130)
        end
    end
}, true)
class.XinYangEff = XinYangEff

local RongXueEff = Class(object, {
    init = function(self)
        self.bubble = {}
        self.group = GROUP.GHOST
        self.layer = 0
        self.back_alpha = 0
        self.alpha = 0
        self.particle = {}
        self.create_snow = function(x, y)
            table.insert(self.particle, {
                alpha = 0, maxalpha = ran:Float(40, 70),
                size = ran:Float(0.35, 0.6),
                imgid = ran:Int(1, 19),
                rot = ran:Float(0, 360), omega = ran:Float(1, 2) * ran:Sign(),
                x = x, y = y,
                vx = ran:Float(-0.05, 0.05), vy = ran:Float(-1, -2),
                timer = 0, lifetime = ran:Int(40, 60)
            })
        end
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
        if lstg.weather.RongXue then

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
    end,
    render = function(self)

        for _, p in ipairs(self.particle) do
            local img = "level_obj_snow" .. p.imgid
            SetImageState(img, "mul+add", p.alpha * self.alpha, 255, 255, 255)
            Render(img, p.x, p.y, p.rot, p.size)
        end
    end
}, true)
class.RongXueEff = RongXueEff

local YuYunEff = Class(object, {
    init = function(self)
        self.bound = false
        self.layer = 0
        self.alpha = 0
        self.particle = {}
        task.New(self, function()
            for i = 1, 60 do
                self.alpha = i / 60
                task.Wait()
            end
        end)
        self._event_FUNC = function(b)
            if not b._frozen and not b.not_move then
                local acc = 1 / 200--固定值
                acc = acc * 0.4
                if b.group == GROUP.ENEMY_BULLET then
                    acc = acc / (b.a / 3)
                elseif b.A then
                    acc = acc / (b.A / 4)
                end
                if not b._YuYun_accel then
                    b._YuYun_accel = acc
                end
                b._YuYun_accel = acc
                b.vy = b.vy + b._YuYun_accel
                if b.y > 450 then
                    object.RawDel(b)
                end
            end
        end
    end,
    frame = function(self)
        task.Do(self)
        if lstg.weather.YuYun then
            if self.timer % (1 + 5 - setting.rdQual) == 0 then
                table.insert(self.particle, {
                    alpha = 0, maxalpha = ran:Float(40, 70),
                    size = ran:Float(2, 8),
                    rindex = 0,
                    x = ran:Float(-320, 320), y = ran:Float(-240, 240),
                    vx = 0, vy = ran:Float(0.25, 0.6),
                    timer = 0, lifetime = ran:Int(30, 60)
                })
            end
            object.BulletDo(function(b)
                self._event_FUNC(b)
            end)
            object.EnemyNontjtDo(function(b)
                if not b.IsBoss then
                    self._event_FUNC(b)
                end
            end)
            for _, b in ObjList(GROUP.ITEM) do
                self._event_FUNC(b)
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
            SetImageState("white", "mul+add", p.alpha * self.alpha, 200, 200, 200)
            misc.SectorRender(p.x, p.y, p.size * p.rindex, p.size, 0, 360, 10, 0)
        end

    end
}, true)
class.YuYunEff = YuYunEff

local HeFengEff = Class(object, {
    init = function(self)
        self.bubble = {}
        self.group = GROUP.GHOST
        self.layer = 0
        self.back_alpha = 0
        self.alpha = 0
        self.particle = {}
        self.x, self.y = 320, 240
        self.bound = false
        task.New(self, function()
            for i = 1, 60 do
                self.alpha = i / 60
                task.Wait()
            end
        end)
        task.New(self, function()
            local j = 0
            local id = 1
            while true do
                task.Wait(ran:Int(120, 180))
                local A = ran:Float(0, 360)
                local range = 2.2
                for i = 1, 60 do
                    local v = range * (1 - i / 60)
                    local ka = ran:Float(-45, 45)
                    if not lstg.var.neutron_star then
                        player.x = player.x + cos(A) * v
                        player.y = player.y + sin(A) * v
                    end
                    j = j + setting.rdQual / 5
                    if j >= 1 then
                        table.insert(self.particle, {
                            alpha = 0, maxalpha = ran:Float(40, 70),
                            size = ran:Float(2, 4),
                            x = cos(A + ka + 180) * 500, y = sin(A + ka + 180) * 500,
                            vx = cos(A) * range * 7, vy = sin(A) * range * 7,
                            timer = 0, lifetime = ran:Int(60, 120)
                        })
                        j = j - 1
                    end
                    task.Wait()

                end
                id = id + 1
            end
        end)
    end,
    frame = function(self)
        self.back_alpha = (0.35 + 0.1 * sin(self.timer)) * self.alpha
        if lstg.weather.HeFeng then
            task.Do(self)
        else
            self.alpha = max(self.alpha - 1 / 30, 0)
            if self.alpha == 0 then
                Del(self)
            end

        end
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
                        alpha = 30, maxalpha = 30,
                        size = p.size,
                        x = p.x - c * ix,
                        y = p.y - c * iy,
                        vx = 0, vy = 0,
                        timer = 0, lifetime = 15,
                        issmear = true
                    })
                end
            end
            p.x = p.x + p.vx
            p.y = p.y + p.vy

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
        local R, G, B = 200, 200, 200
        for _, p in ipairs(self.particle) do
            SetImageState("bright", "mul+add", p.alpha * self.alpha, R, G, B)
            Render("bright", p.x, p.y, 0, p.size / 130)
        end
    end
}, true)
class.HeFengEff = HeFengEff

local TaiFengEff = Class(object, {
    init = function(self)
        self.bubble = {}
        self.group = GROUP.GHOST
        self.layer = 0
        self.back_alpha = 0
        self.alpha = 0
        self.particle = {}
        self.x, self.y = 320, 240
        self.bound = false
        task.New(self, function()
            for i = 1, 60 do
                self.alpha = i / 60
                task.Wait()
            end
        end)
        task.New(self, function()
            local j = 0
            local id = 1
            while true do
                task.Wait(ran:Int(120, 180))
                local A = ran:Float(0, 360)
                local range = player.cur_hspd * 0.85
                for i = 1, 100 do

                    local v = range * task.SetMode[2](i / 100 * 2)
                    local ka = ran:Float(-45, 45)
                    if not lstg.var.neutron_star then
                        player.x = player.x + cos(A) * v
                        player.y = player.y + sin(A) * v
                    end
                    if i % 2 == 0 then
                        j = j + setting.rdQual / 5
                        if j >= 1 then
                            table.insert(self.particle, {
                                alpha = 0, maxalpha = ran:Float(40, 70),
                                size = ran:Float(2, 4),
                                x = cos(A + ka + 180) * 500, y = sin(A + ka + 180) * 500,
                                vx = cos(A) * range * 7, vy = sin(A) * range * 7,
                                timer = 0, lifetime = ran:Int(40, 60)
                            })
                            j = j - 1
                        end
                    end
                    task.Wait()

                end
                id = id + 1
            end
        end)
    end,
    frame = function(self)
        self.back_alpha = (0.35 + 0.1 * sin(self.timer)) * self.alpha
        if lstg.weather.TaiFeng then
            task.Do(self)
        else
            self.alpha = max(self.alpha - 1 / 30, 0)
            if self.alpha == 0 then
                Del(self)
            end

        end
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
                        alpha = 30, maxalpha = 30,
                        size = p.size,
                        x = p.x - c * ix,
                        y = p.y - c * iy,
                        vx = 0, vy = 0,
                        timer = 0, lifetime = 15,
                        issmear = true
                    })
                end
            end
            p.x = p.x + p.vx
            p.y = p.y + p.vy

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
        local R, G, B = 200, 200, 200
        misc.RenderBrightOutline(-320, 320, -240, 240, 200, self.back_alpha * 255, 0, 0, 0, "")
        for _, p in ipairs(self.particle) do
            SetImageState("bright", "mul+add", p.alpha * self.alpha, R, G, B)
            Render("bright", p.x, p.y, 0, p.size / 130)
        end
    end
}, true)
class.TaiFengEff = TaiFengEff

local SheRiEff = Class(object, {
    init = function(self)
        self.bubble = {}
        self.group = GROUP.GHOST
        self.layer = 0
        self.back_alpha = 0
        self.alpha = 0
        self.particle = {}
        self.x, self.y = 320, 240
        self.bound = false
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
        if lstg.weather.SheRi then
            if self.timer % (40 + 2 * (5 - setting.rdQual)) == 0 then
                table.insert(self.particle, {
                    alpha = 0, maxalpha = 120,
                    size = 7,
                    x = ran:Float(-300, 300), y = -240,
                    vx = 0, vy = ran:Float(5, 7),
                    timer = 0, lifetime = ran:Int(40, 60),
                    main = true
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

            if not p.issmear then
                local inc = 2 + 2 * (1 - setting.rdQual / 5)
                local dx, dy = p.vx, p.vy
                local d = hypot(dx, dy)
                local count = int(d / inc)
                local ix = inc * (dx / d)
                local iy = inc * (dy / d)
                for c = 0, count do
                    table.insert(self.particle, {
                        alpha = 30, maxalpha = 30,
                        size = p.size,
                        x = p.x - c * ix,
                        y = p.y - c * iy,
                        vx = 0, vy = 0,
                        timer = 0, lifetime = 15,
                        issmear = true
                    })
                end
            end
            p.x = p.x + p.vx
            p.y = p.y + p.vy
            if p.ay then
                p.vy = p.vy + p.ay
            end

            p.timer = p.timer + 1
            if p.timer <= 10 then
                p.alpha = min(p.maxalpha, p.alpha + p.maxalpha / 10)
            elseif p.timer > p.lifetime - 10 then
                p.alpha = max(p.alpha - p.maxalpha / 10, 0)
                if p.alpha == 0 then
                    table.remove(self.particle, i)
                    if p.main then
                        for _ = 1, 15 do
                            local A = ran:Float(0, 360)
                            local v = ran:Float(4, 6)
                            table.insert(self.particle, {
                                alpha = 0, maxalpha = ran:Float(50, 80),
                                size = ran:Float(2, 5),
                                x = p.x, y = p.y,
                                vx = cos(A) * v, vy = sin(A) * v,
                                ay = ran:Float(-0.1, -0.2),
                                timer = 0, lifetime = ran:Int(30, 60),
                            })
                        end
                    end
                end
            end

        end
    end,
    render = function(self)
        local R, G, B = 255, 227, 132
        for _, p in ipairs(self.particle) do
            SetImageState("bright", "mul+add", p.alpha * self.alpha, R, G, B)
            Render("bright", p.x, p.y, 0, p.size / 130)
        end
    end
}, true)
class.SheRiEff = SheRiEff

local HuanYuEff = Class(object, {
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
        if lstg.weather.HuanYu then
        else
            self.alpha = max(self.alpha - 1 / 30, 0)
            if self.alpha == 0 then
                Del(self)
            end
        end
    end,
    render = function(self)
        misc.RenderBrightOutline(-320, 320, -240, 240, 200,
                self.back_alpha * 150, 218, 112, 214, "mul+add")
    end
}, true)
class.HuanYuEff = HuanYuEff

local FuYueEff = Class(object, {
    init = function(self)
        self.bound = false
        self.layer = 0
        self.alpha = 0
        self.particle = {}
        self.y = 240
        task.New(self, function()
            for i = 1, 60 do
                self.alpha = i / 60
                task.Wait()
            end
        end)
        self._event_FUNC = function(b)
            if not b._frozen and not b.not_move then
                local acc = clamp(1 / (b.y + 240), 0, 0.2)
                if b.group == GROUP.ENEMY_BULLET then
                    acc = acc / (b.a / 3)
                elseif b.A then
                    acc = acc / (b.A / 4)
                end
                if not b._FuYue_accel then
                    b._FuYue_accel = acc
                end
                b._FuYue_accel = acc
                b.vy = b.vy + b._FuYue_accel
                if b.y > 450 then
                    object.RawDel(b)
                end
            end
        end
    end,
    frame = function(self)
        task.Do(self)
        if lstg.weather.FuYue then
            if self.timer % (1 + 5 - setting.rdQual) == 0 then
                table.insert(self.particle, {
                    alpha = 0, maxalpha = ran:Float(120, 180),
                    size = ran:Float(3, 6),
                    x = ran:Float(-320, 320), y = self.y,
                    vx = ran:Float(-0.3, 0.3), vy = ran:Float(-2, -1),
                    timer = 0, lifetime = ran:Int(30, 60),
                    rot = ran:Float(0, 360), omega = ran:Float(1, 2) * ran:Sign()
                })
            end
            object.BulletDo(function(b)
                self._event_FUNC(b)
            end)
            object.EnemyNontjtDo(function(b)
                if not b.IsBoss then
                    self._event_FUNC(b)
                end
            end)
            for _, b in ObjList(GROUP.ITEM) do
                self._event_FUNC(b)
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
        local r, g, b = 200, 220, 200
        local col1 = Color(0, r, g, b)
        local col2 = Color(self.alpha * 75, r, g, b)
        SetImageState("white", "mul+add", 666, 0, 0, 0)--刷新存储列表
        OriginalSetImageState("white", "mul+add", col1, col1, col2, col2)
        RenderRect("white", -320, 320, self.y, self.y - 60)
        for _, p in ipairs(self.particle) do
            SetImageState("white", "mul+add", p.alpha, r, g, b)
            misc.SectorRender(p.x, p.y, p.size * 0.9, p.size, 0, 360, 10, p.rot)
        end

    end
}, true)
class.FuYueEff = FuYueEff

local FuRiEff = Class(object, {
    init = function(self)
        self.bound = false
        self.layer = 0
        self.alpha = 0
        self.particle = {}
        self.y = 240
        task.New(self, function()
            for i = 1, 60 do
                self.alpha = i / 60
                task.Wait()
            end
        end)
        self._event_FUNC = function(b)
            if not b._frozen and not b.not_move then
                local acc = clamp(1 / (b.y + 240), 0, 0.2)
                if b.group == GROUP.ENEMY_BULLET then
                    acc = acc / (b.a / 3)
                elseif b.A then
                    acc = acc / (b.A / 4)
                end
                acc = -acc
                if not b._FuRi_accel then
                    b._FuRi_accel = acc
                    b._FuRi_velocity = 0
                end
                b._FuRi_accel = acc
                b.vy = b.vy + b._FuRi_accel
                if b.y < -450 then
                    object.RawDel(b)
                end
            end
        end
    end,
    frame = function(self)
        task.Do(self)
        if lstg.weather.FuRi then
            if self.timer % (1 + 5 - setting.rdQual) == 0 then
                table.insert(self.particle, {
                    alpha = 0, maxalpha = ran:Float(120, 180),
                    size = ran:Float(3, 6),
                    x = ran:Float(-320, 320), y = self.y,
                    vx = ran:Float(-0.3, 0.3), vy = ran:Float(-2, -1),
                    timer = 0, lifetime = ran:Int(30, 60),
                    rot = ran:Float(0, 360), omega = ran:Float(1, 2) * ran:Sign()
                })
            end
            object.BulletDo(function(b)

                self._event_FUNC(b)
            end)
            object.EnemyNontjtDo(function(b)
                if not b.IsBoss then
                    self._event_FUNC(b)
                end
            end)
            for _, b in ObjList(GROUP.ITEM) do
                self._event_FUNC(b)
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
        local r, g, b = 255, 227, 132
        local col1 = Color(0, r, g, b)
        local col2 = Color(self.alpha * 75, r, g, b)
        SetImageState("white", "mul+add", 666, 0, 0, 0)--刷新存储列表
        OriginalSetImageState("white", "mul+add", col1, col1, col2, col2)
        RenderRect("white", -320, 320, self.y, self.y - 60)
        for _, p in ipairs(self.particle) do
            SetImageState("white", "mul+add", p.alpha, r, g, b)
            misc.SectorRender(p.x, p.y, p.size * 0.9, p.size, 0, 360, 10, p.rot)
        end

    end
}, true)
class.FuRiEff = FuRiEff

local QiuShuangEff = Class(object, {
    init = function(self)
        self.bubble = {}
        self.group = GROUP.GHOST
        self.layer = 0
    end,
    frame = function(self)
        task.Do(self)
        if lstg.weather.QiuShuang then
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
class.QiuShuangEff = QiuShuangEff
