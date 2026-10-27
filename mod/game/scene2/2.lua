local lib = stage_lib
local servant = _editor_class.SimpleServant
local class = SceneClass[2]
local HP = lib.GetHP
local function _t(str)
    return i18n("scene2", str) or ""
end
local function name(str)
    return i18n("bossname", str)
end

lib.NewWaveEventInWaves(class, 21, { 2, 3, 4, 11, 12, 13, 14 }, 1,
        0, 1, function(var)

            local stg = stage.current_stage
            local rain_enemy = Class(enemy, {
                init = function(self, x, y, vx1, vy1, A)
                    enemy.init(self, 24, HP(20), false, true, false, 1.1)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx1, vy1
                    task.New(self, function()
                        while true do
                            local b = NewSimpleBullet(grain_b, 10, self.x, self.y, min(10, 3 + var.chaos / 100 * 2), A)
                            b.stay = false
                            PlaySound("tan00")
                            task.Wait(stage_lib.GetValue(15, 9, 6, 1))
                        end
                    end)
                end,
            }, true)
            for c = 1, 12 do
                for d = -1, 1, 2 do
                    task.New(stg, function()
                        local t = 20
                        for _ = 1, 3 do
                            local A = 90 - (84 + 35 * task.SetMode[2](c / 12 * 2)) * d
                            local k = 3.5
                            New(rain_enemy, -400 * d, 180, cos(A) * k, sin(A) * k, A - 90 * d)
                            task.Wait(8)
                            t = max(1, t - 1)
                        end
                    end)
                    task.Wait(max(8, 78 - c * 6 - stage_lib.GetValue(0, 10, 20, 90)))
                end
            end
        end, _t("茕茕孑立"))
lib.NewWaveEventInWaves(class, 22, { 1, 3, 4, 11, 12, 13 }, 1,
        0, 1, function()
            local maxexp = 100
            local enemy1 = Class(enemy, {
                init = function(self, x, y)
                    enemy.init(self, 14, HP(200), false, true, false, 15)
                    self.x, self.y = x, y

                    task.New(self, function()
                        task.Wait(200)
                        object.ChangingV(self, 0, 1, -90, 80, false)
                    end)
                    task.New(self, function()
                        local n = int(stage_lib.GetValue(10, 13, 18, 72))
                        for u = 1, 15 do
                            for a in sp.math.AngleIterator(0, n) do
                                local v = stage_lib.GetValue(2, 3, 4, 15)
                                for d = -1, 1, 2 do
                                    Create.bullet_changeangle(self.x, self.y, diamond, 6, 0, a, false,
                                            { time = 160, r = d * (u / 15) * 0.5, v = v })
                                end
                            end
                            PlaySound("tan00")
                            task.Wait(stage_lib.GetValue(12, 8, 6, 1))
                        end
                    end)
                end,
            }, true)
            local soul = Class(enemy, {
                init = function(self, x, y, a, o, r, vR)
                    enemy.init(self, 28, HP(6), false, true, false, 0.7)
                    self.protect = true
                    self.x, self.y = x + cos(a) * r, y + sin(a) * r
                    Create.bullet_create_eff(self.x, self.y, ball_big, 8)
                    task.New(self, function()
                        task.New(self, function()
                            local t = 1
                            self.bound = true
                            while true do
                                r = r + vR * sin(min(t, 90))
                                t = t + 1
                                task.Wait()
                            end
                        end)
                        local t = 1
                        Create.bullet_accel(self.x, self.y, ellipse, 6, 0.5,
                                stage_lib.GetValue(3, 4, 5, 18), a + 180)
                        PlaySound("tan00")
                        while true do
                            self.x = x + cos(a) * r
                            self.y = y + sin(a) * r
                            a = a + o * sin(min(t, 90))

                            t = t + 1
                            task.Wait()
                        end

                    end)
                    task.New(self, function()
                        task.Wait(10)
                        self.protect = false
                    end)
                end,
                kill = function(self)
                    maxexp = max(0, maxexp - 0.7)--限制能获得的exp
                    self.drop_exps = min(maxexp, 0.7)
                    enemy.kill(self)
                end
            }, true)
            for m = -1.5, 1.5 do
                local x, y = m * 150, 160
                local d = ran:Sign()
                local rot = ran:Float(0, 360)
                for _ = 1, 12 do
                    local R = 35
                    for a in sp.math.AngleIterator(rot, int(stage_lib.GetValue(15, 25, 35, 120))) do
                        if Dist(player, x + cos(a) * R, y + sin(a) * R) > 40 then
                            New(soul, x, y, a, d * 0.4, R, 3)

                        end
                    end

                    d = -d
                    task.Wait(stage_lib.GetValue(12, 10, 8, 2))
                end
                New(enemy1, x, y)
                task.Wait(110)
            end
        end, _t("但求同年同月生"))
lib.NewWaveEventInWaves(class, 23, { 7, 8, 9, 11, 12, 13 }, 1,
        0, 1, function()
            local grain_to_laser = function(x, y, col, iv, v, a, wait, time)
                local self = NewObject(bullet)
                bullet.init(self, grain_a, col, false, true)
                self.x, self.y = x, y
                object.SetV(self, iv, a, true)
                PlaySound("tan00")
                task.New(self, function()
                    task.Wait(wait)
                    object.ChangingV(self, iv, v * 0.5, a, time)
                    object.Del(self)
                    if not self._no_colli then
                        Create.laser_line(self.x, self.y, col, v, a, 15, 10, 5, 10)
                    end
                end)
            end
            local enemy1 = Class(enemy, {
                init = function(self, x, y, vx1, vy1, vx2, vy2)
                    enemy.init(self, 15, HP(12), false, true, false, 2)
                    self.x, self.y = x, y

                    task.New(self, function()
                        for i = 1, 60 do
                            i = i / 60
                            self.vx = vx1 * (1 - i)
                            self.vy = vy1 * (1 - i)
                            task.Wait()
                        end
                        task.New(self, function()
                            for _ = 1, 3 do
                                for a in sp.math.AngleIterator(Angle(self, player), 8) do
                                    grain_to_laser(self.x, self.y, 6, 0.5, stage_lib.GetValue(7, 8, 9, 30),
                                            a, 0, 40)
                                end
                                task.Wait(60)
                            end
                        end)

                        task.Wait(12)
                        for i = 1, 60 do
                            i = i / 60
                            self.vx = vx2 * (i)
                            self.vy = vy2 * (i)
                            task.Wait()
                        end
                    end)
                end,
            }, true)
            local ball = Class(enemy, {
                drop = function(self)
                    New(bullet_cleaner, self.x, self.y, 100, 1, 2, true, false, 0)
                end,
                init = function(self, x, y, vx1, vy1, vx2, vy2)
                    enemy.init(self, 26, HP(26), false, true, false, 7)
                    self.x, self.y = x, y
                    local o = ran:Sign()
                    for a in sp.math.AngleIterator(0, 4) do
                        servant.init(NewObject(servant), self.x, self.y, 0, 218, 112, 214, 1.5, function(unit)
                            unit.bound = false
                            task.New(unit, function()
                                unit:FadeIn(15)
                                object.ChangingSizeColli(unit, -0.5, -0.5, 15)
                            end)
                            local R = 0
                            unit.angle = a
                            task.New(unit, function()
                                while IsValid(self) do
                                    unit.x = self.x + cos(unit.angle) * R
                                    unit.y = self.y + sin(unit.angle) * R
                                    unit.angle = unit.angle + o
                                    task.Wait()
                                end
                                unit:FadeOut(15)
                                task.Wait(15)
                                Del(unit)
                            end)
                            task.New(unit, function()
                                for i = 1, 25 do
                                    R = 100 * task.SetMode[2](i / 60)
                                    task.Wait()
                                end
                            end)
                        end)

                    end
                    task.New(self, function()
                        task.New(self, function()
                            task.Wait(20)
                            for a in sp.math.AngleIterator(90, int(stage_lib.GetValue(16, 18, 22, 80))) do
                                for v = 0, int(stage_lib.GetValue(0, 1, 2, 12)) do
                                    Create.bullet_accel(self.x, self.y, ellipse, 4, 0.5, stage_lib.GetValue(1.6, 2, 2.7, 9) + v * 0.4, a)
                                end

                            end
                            PlaySound("tan00")
                        end)
                        for i = 1, 80 do
                            i = i / 80
                            self.vx = vx1 * (1 - i)
                            self.vy = vy1 * (1 - i)
                            task.Wait()
                        end
                        for i = 1, 60 do
                            i = i / 60
                            self.vx = vx2 * (i)
                            self.vy = vy2 * (i)
                            task.Wait()
                        end
                    end)
                end,
            }, true)
            task.New(stage.current_stage, function()
                local A = 90
                for _ = 1, 15 do
                    local vx, vy = cos(A + 180) * 9, sin(A + 180) * 9
                    New(ball, cos(A) * 400, sin(A) * 400, vx, vy, vx * 0.3, vy * 0.3)
                    A = A + 120
                    task.Wait(60)
                end
            end)
            local d = 1
            for _ = 1, 9 do
                for kx = -0.5, 0.5 do
                    for ky = -0.5, 0.5 do
                        local x = 140 * d + kx * 36
                        local y = 290 + ky * 36
                        New(enemy1, x, y, 0, -6, kx * 3, ky * 3)
                    end
                end
                d = -d
                task.Wait(110)
            end
        end, _t("放长线钓大鱼"))
lib.NewWaveEventInWaves(class, 24, { 6, 11, 12, 13, }, 1,
        0, 1, function()
            if lstg.weather.QingMing then
                ext.achievement:get(107)
            end
            local ranFrot = {}
            for _ = 1, 25 do
                table.insert(ranFrot, ran:Float(25, 50))
            end
            local ball = Class(enemy, {
                init = function(self, x, y, v, ka, ki, d)
                    enemy.init(self, 25, HP(25), false, true, false,
                            stage_lib.GetValue(3, 2, 1.5, 0.4))
                    self.x, self.y = x, y
                    task.New(self, function()
                        for i = ki, ki + 3 do
                            local A = ka + d * ranFrot[i]
                            object.ChangingV(self, v, 0, A, 36, false)
                            if self.y > 0 then
                                local bv = stage_lib.GetValue(3, 4, 5, 18)
                                for a in sp.math.AngleIterator(A, 16) do
                                    Create.bullet_accel(self.x, self.y, arrow_mid, 8, bv * 0.6, bv, a)
                                end
                                PlaySound("tan00")
                            end

                            d = -d
                        end
                        object.SetV(self, v, ka + d * ranFrot[ki + 3])
                    end)
                end,
            }, true)
            local d = 1
            for p = -1.5, 1.5 do
                local x = p * 120 + ran:Float(-30, 30)
                local ki = ran:Int(1, 16)

                local N = int(stage_lib.GetValue(8, 12, 16, 60))
                for t = 1, N do
                    New(ball, x, 260, 7, -90, ki, d * (1 + t / N * 0.3))
                    task.Wait(96 / N)
                end
                d = -d
                task.Wait(50)
            end


        end, _t("雷霆乍惊，宫车过也"))
lib.NewWaveEventInWaves(class, 25, { 7, 12, 13, 14 }, 1,
        0, 1, function()
            if lstg.weather.QingMing then
                ext.achievement:get(108)
            end
            local ranFrot = {}
            for _ = 1, 25 do
                table.insert(ranFrot, ran:Float(25, 50))
            end
            local ball = Class(enemy, {
                init = function(self, x, y, v, ka, ki, d)
                    enemy.init(self, 24, HP(25), false, true, false,
                            stage_lib.GetValue(3, 2, 1.5, 0.4))
                    self.x, self.y = x, y
                    task.New(self, function()
                        for i = ki, ki + 3 do
                            local A = ka + d * ranFrot[i]
                            object.ChangingV(self, v, 0, A, 36, false)
                            if self.y > 0 then
                                local bv = stage_lib.GetValue(3, 3.6, 4.2, 15)
                                for a in sp.math.AngleIterator(A, 20) do
                                    Create.bullet_accel(self.x, self.y, grain_c, 10, bv * 0.6, bv, a)
                                end
                                PlaySound("tan00")
                            end

                            d = -d
                        end
                        object.SetV(self, v, ka + d * ranFrot[ki + 3])
                    end)
                end,
            }, true)
            local d = 1
            for _ = 1, 4 do
                local ki = ran:Int(1, 16)
                local N = int(stage_lib.GetValue(5, 10, 16, 60))
                for t = 1, N do
                    New(ball, 360 * d, 175, 7, 90 + 90 * d, ki, d * (1 + t / N * 0.3))
                    task.Wait(110 / N)
                end
                d = -d
                task.Wait(60)
            end


        end, _t("绿云扰扰，梳晓鬟也"))
local _w = lib.NewWaveEventInWaves(class, 26, { 11, 13, 14 }, 1,
        0, 1, function()
            lstg.tmpvar.Wave26Nomiss = lstg.var.miss
            local shoot_laser = Class(laser, {
                init = function(self, x, y, w, a, time, life, R, G, B)
                    laser.init(self, 15, x, y, a, 0, 0, 0, w, w, 0)
                    laser._TurnHalfOn(self, 0, false)
                    laser.ChangeImage(self, 4, 15)
                    self.line = 0
                    self.Isradial = true
                    self._blend = "add+add"
                    self._r, self._g, self._b = R, G, B
                    local KL = 1200 / life
                    self.radial_v = KL
                    task.New(self, function()
                        task.New(self, function()
                            for i = 1, 45 do
                                self.line = sin(i * 2) * 600
                                task.Wait()
                            end
                            task.Wait(15)
                        end)
                        task.Wait(time)
                        laser._TurnOn(self, 1, true, false)
                        task.New(self, function()
                            for _ = 1, life do
                                self.l2 = self.l2 + KL
                                task.Wait()
                            end
                            laser._TurnOff(self, 30, true)
                            object.Del(self)
                        end)
                    end)
                end,
                render = function(self)
                    SetImageState("white", "mul+add", self.alpha * 180, unpack(ColorList[math.ceil(self.index / 2)]))
                    Render("white", self.x + cos(self.rot) * self.line / 2, self.y + sin(self.rot) * self.line / 2, self.rot, self.line / 16, 0.125)
                    laser.render(self)
                end
            }, true)
            local ball_t = function(x, y, v, a, R, G, B)
                local self = NewObject(bullet)
                bullet.init(self, ball_big, 15, false, true)
                self.x, self.y = x, y
                self._blend = "add+add"
                self._r, self._g, self._b = R, G, B
                task.New(self, function()
                    object.ChangingV(self, v, 0, a, 45, false)
                    Del(self)
                    if not self._no_colli then
                        New(shoot_laser, self.x, self.y, 14, a, 30, 120, R, G, B)
                    end
                end)
            end
            local enemy1 = Class(enemy, {
                init = function(self, x, y, mx, my, vx, vy, col, d)
                    enemy.init(self, 14, HP(520), false, true, false, 30)
                    self.x, self.y = x, y
                    task.New(self, function()
                        task.Wait(60)
                        task.init_left_wait(self)
                        local N = int(stage_lib.GetValue(100, 130, 160, 550))

                        for _ = 1, N do
                            local rf = stage_lib.GetValue(0, 15, 25, 90)
                            local v = stage_lib.GetValue(2.5, 2.7, 3.1, 12)
                            local b = Create.bullet_dec_setangle(self.x, self.y, star_small, col, false,
                                    { v = ran:Float(3, 10), a = ran:Float(0, 360), time = 60 },
                                    { a = -90 + ran:Float(-rf, rf), v = ran:Float(v - 0.5, v + 0.5) })
                            b.omega = ran:Float(2, 3) * ran:Sign()
                            PlaySound("tan00")
                            task.Wait2(self, 360 / N)
                        end
                        for i = 1, 60 do
                            self.vx = vx * i / 60
                            self.vy = vy * i / 60
                            task.Wait()
                        end
                    end)
                    task.New(self, function()
                        task.MoveTo(mx, my, 60, 2)
                        local rot = ran:Float(0, 360)
                        local N = int(stage_lib.GetValue(13, 15, 18, 72))
                        for _ = 1, N do
                            for a in sp.math.AngleIterator(rot, 2) do
                                ball_t(self.x, self.y, 7.5, a, sp:HSVtoRGB(a, 1, 1))
                            end
                            task.Wait(5)
                            rot = rot + 180 / N * d
                        end
                    end)

                end,
            }, true)
            local enemy2 = Class(enemy, {
                init = function(self, x, y, vx, vy, ax, ay, col, d)
                    enemy.init(self, 9, HP(250), false, true, false, 30)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx, vy
                    self.ax, self.ay = ax, ay
                    task.New(self, function()
                        task.init_left_wait(self)
                        local N = int(stage_lib.GetValue(100, 130, 160, 550))

                        for _ = 1, N do
                            local rf = stage_lib.GetValue(0, 15, 25, 90)
                            local v = stage_lib.GetValue(2.5, 2.7, 3.1, 12)
                            local b = Create.bullet_dec_setangle(self.x, self.y, star_small, col, false,
                                    { v = ran:Float(3, 10), a = ran:Float(0, 360), time = 60 },
                                    { a = -90 + ran:Float(-rf, rf), v = ran:Float(v - 0.5, v + 0.5) })
                            b.omega = ran:Float(2, 3) * ran:Sign()
                            PlaySound("tan00")
                            task.Wait2(self, 360 / N)
                        end
                    end)
                    task.New(self, function()
                        local rot = ran:Float(0, 360)
                        local N = int(stage_lib.GetValue(13, 15, 18, 72))
                        for _ = 1, N * 2 do
                            for a in sp.math.AngleIterator(rot, 2) do
                                ball_t(self.x, self.y, 7.5, a, sp:HSVtoRGB(rot, 1, 1))
                            end
                            task.Wait(5)
                            rot = rot + 180 / N * d
                        end
                    end)

                end,
            }, true)

            task.Wait(50)
            New(enemy1, 0, 280, 0, 50, 0, -1, 6, 1)
            task.Wait(280)
            New(enemy1, -150, 280, -150, 50, 0, -1, 2, 1)
            New(enemy1, 150, 280, 150, 50, 0, -1, 10, -1)
            task.Wait(450)
            New(enemy2, -360, 0, 7, 0, -0.04, 0.01, 4, -1)
            task.Wait(240)
            New(enemy2, 360, 0, -7, 0, 0.04, 0.01, 12, 1)
        end, _t("彩虹五吴克"))
function _w.final()
    if lstg.tmpvar.Wave26Nomiss == lstg.var.miss then
        ext.achievement:get(85)
    end
end
lib.NewWaveEventInWaves(class, 27, { 11, 13, 14 }, 1,
        2, 2, function(var)
            if lstg.weather.XuanWo then
                ext.achievement:get(98)
            elseif lstg.weather.HuanYu then
                ext.achievement:get(100)
            end
            local shoot_laser = Class(laser, {
                init = function(self, x, y, w, a, time, life, H)
                    laser.init(self, 15, x, y, a, 0, 0, 0, w, w, 0)
                    laser._TurnHalfOn(self, 0, false)
                    laser.ChangeImage(self, 4, 15)
                    self.line = 0
                    self.Isradial = true
                    self._blend = "add+add"
                    task.New(self, function()
                        while true do
                            self._r, self._g, self._b = sp:HSVtoRGB(H, 1, 1)
                            H = H + 2
                            task.Wait()
                        end
                    end)
                    local KL = 1200 / life
                    self.radial_v = KL
                    task.New(self, function()
                        task.New(self, function()
                            for i = 1, 45 do
                                self.line = sin(i * 2) * 600
                                task.Wait()
                            end
                            task.Wait(15)
                        end)
                        task.Wait(time)
                        laser._TurnOn(self, 1, true, false)
                        task.New(self, function()
                            for _ = 1, life do
                                self.l2 = self.l2 + KL
                                task.Wait()
                            end
                            laser._TurnOff(self, 30, true)
                            object.Del(self)
                        end)
                    end)
                end,
                render = function(self)
                    SetImageState("white", "mul+add", self.alpha * 180, unpack(ColorList[math.ceil(self.index / 2)]))
                    Render("white", self.x + cos(self.rot) * self.line / 2, self.y + sin(self.rot) * self.line / 2, self.rot, self.line / 16, 0.125)
                    laser.render(self)
                end
            }, true)
            local ball_t = function(x, y, v, a, H)
                local self = NewObject(bullet)
                bullet.init(self, ball_big, 15, false, true)
                self.x, self.y = x, y
                self._blend = "add+add"
                task.New(self, function()
                    while true do
                        self._r, self._g, self._b = sp:HSVtoRGB(H, 1, 1)
                        H = H + 2
                        task.Wait()
                    end
                end)
                task.New(self, function()
                    object.ChangingV(self, v, 0, a, 45, false)
                    Del(self)
                    if not self._no_colli then
                        New(shoot_laser, self.x, self.y, 10, a, 30, int(stage_lib.GetValue(60, 80, 90, 300)), H)
                    end
                end)
            end
            local enemy1 = Class(enemy, {
                init = function(self, x, y, mx, my, vx, vy, irot, d, state)
                    enemy.init(self, 14, HP(520), false, true, false, 30)
                    self.x, self.y = x, y

                    task.New(self, function()
                        task.Wait(60)
                        task.init_left_wait(self)
                        if state == 1 then
                            local N = int(stage_lib.GetValue(100, 130, 160, 550))
                            for _ = 1, N do
                                local rf = stage_lib.GetValue(0, 15, 25, 90)
                                local v = stage_lib.GetValue(2.5, 2.7, 3.1, 12)
                                local b = Create.bullet_dec_setangle(self.x, self.y, star_small, 15, false,
                                        { v = ran:Float(3, 10), a = ran:Float(0, 360), time = 60 },
                                        { a = -90 + ran:Float(-rf, rf), v = ran:Float(v - 0.5, v + 0.5) })
                                b.omega = ran:Float(2, 3) * ran:Sign()
                                b._blend = "add+alpha"
                                b.H = ran:Float(0, 360)
                                function b:frame_new()
                                    bullet.frame(self)
                                    self._r, self._g, self._b = sp:HSVtoRGB(self.H, 1, 1)
                                    self.H = self.H - 2.5
                                end
                                PlaySound("tan00")
                                task.Wait2(self, 360 / N)
                            end
                        else
                            task.Wait(360)
                        end
                        for i = 1, 60 do
                            self.vx = vx * i / 60
                            self.vy = vy * i / 60
                            task.Wait()
                        end
                    end)
                    task.New(self, function()
                        task.MoveTo(mx, my, 60, 2)
                        if state == 2 then
                            local rot = irot
                            local N = int(stage_lib.GetValue(12, 14, 18, 72))
                            for _ = 1, N * 5 do
                                for a in sp.math.AngleIterator(rot, 2) do
                                    ball_t(self.x, self.y, 7.5, a, a)
                                end
                                task.Wait(5)
                                rot = rot + 160 / N * d
                            end
                        end
                    end)

                end,
            }, true)

            task.Wait(50)
            New(enemy1, -70, 280, -70, 90, 0, -1, 90, 1, 2)
            New(enemy1, 70, 280, 70, 90, 0, -1, 90, -1, 2)
            New(enemy1, -160, 280, -150, 150, 0, -1, 90, 1, 1)
            New(enemy1, 160, 280, 150, 150, 0, -1, 90, -1, 1)
        end, _t("光之女皇"), nil, true)
lib.NewWaveEventInWaves(class, 28, { 5, 10 }, 1,
        0, 1, function(var)

            local bclass = boss.Define(name("Clownpiece"), 500, 200, _editor_class.clownpiece_bg, "Clownpiece")

            local non_sc = boss.card.New("", 1, 5, 40, HP(1200))
            boss.card.add(bclass, non_sc)
            function non_sc:before()
                task.MoveToForce(0, 100, 60, 2)
            end
            function non_sc:init()
                task.New(self, function()
                    local Laser = Class(laser, {
                        init = function(self, x, y, a, d)
                            laser.init(self, 6, x, y, a, 0, 0, 0, 12, 12, 0)
                            laser._TurnHalfOn(self, 0, false)
                            self.line = 0
                            self.Isradial = true
                            self.radial_v = 16
                            task.New(self, function()
                                for i = 1, 40 do
                                    self.rot = a - d * 90 * task.SetMode[2](i / 40)
                                    self.line = sin(i * 2.25) * 900
                                    task.Wait()
                                end
                                laser._TurnOn(self, 1, true, false)
                                task.New(self, function()
                                    for i = 1, 60 do
                                        self.rot = self.rot + d * 0.25 * task.SetMode[2](i / 60)
                                        self.l3 = self.l3 + 16
                                        task.Wait()
                                    end
                                    for i = 1, 40 do
                                        self.rot = self.rot + d * 0.25 * task.SetMode[2](1 - i / 40)
                                        self.l1 = self.l1 + 16
                                        task.Wait()
                                    end
                                    laser._TurnOff(self, 30, true)
                                    object.Del(self)
                                end)
                            end)
                        end,
                        render = function(self)
                            SetImageState("white", "mul+add", self.alpha * 180, unpack(ColorList[math.ceil(self.index / 2)]))
                            Render("white", self.x + cos(self.rot) * self.line / 2, self.y + sin(self.rot) * self.line / 2, self.rot, self.line / 16, 0.125)
                            laser.render(self)
                        end
                    }, true)
                    local center = Class(bullet, {
                        init = function(self, x, y, v, a, d)
                            bullet.init(self, ball_big, 6, true, false)
                            self.x, self.y = x, y
                            self._blend = "mul+add"
                            task.New(self, function()
                                object.ChangingV(self, v, 0, a, 60)
                                object.Del(self)

                                for A in sp.math.AngleIterator(0, 14) do
                                    New(Laser, self.x, self.y, A, d)
                                end
                            end)
                        end
                    }, true)
                    local d = 1
                    while true do
                        boss.cast(self, 60)
                        Newcharge_in(self.x, self.y, 250, 128, 114)
                        task.Wait(60)
                        Newcharge_out(self.x, self.y, 255, 227, 132)
                        New(center, self.x, self.y, 3, 90 + 45, 1)
                        New(center, self.x, self.y, 3, 90 - 45, -1)
                        local N = int(stage_lib.GetValue(10, 14, 18, 66))
                        for a in sp.math.AngleIterator(-90, 36) do
                            for z = 0, N do
                                NewSimpleBullet(star_small, 6, self.x, self.y, 3.5 - z * max(1.44 / N, 0.11),
                                        a + sin(z / N * 480) * 2.2 * d, nil, 2)
                            end
                        end
                        for a in sp.math.AngleIterator(-90, 19) do
                            for z = 0, N do
                                NewSimpleBullet(star_small, 4, self.x, self.y, 1.5 - z * max(0.84 / N, 0.06),
                                        a - sin(z / N * 252) * stage_lib.GetValue(4.8, 5, 7, 27) * d, nil, -2)
                            end
                        end
                        task.Wait(90)
                        task.MoveToPlayer(90, -230, 230, 100, 140,
                                40, 50, 10, 20, 2, 1)
                        PlaySound("kira00", 0.2, 0, true)
                        for a in sp.math.AngleIterator(ran:Float(0, 360), 25) do
                            local x, y = player.x + cos(a) * 100, player.y + sin(a) * 100
                            local vin = stage_lib.GetValue(160, 140, 122, 33)
                            NewSimpleBullet(star_small, 16, self.x, self.y,
                                    Dist(self, x, y) / vin, Angle(self, x, y), nil, 3)
                        end
                        d = -d
                        task.Wait(stage_lib.GetValue(90, 75, 60, 13))
                    end
                end)
            end
            boss.Create(bclass)
        end, _t("横扫饥饿，做回自己"), nil, nil, true)
lib.NewWaveEventInWaves(class, 29, { 8, 9, 11, 12 }, 1,
        0, 1, function(var)
            local grain_to_laser = function(x, y, col, iv, v, a, wait, time)
                local self = NewObject(bullet)
                bullet.init(self, grain_a, col, false, true)
                self.x, self.y = x, y
                object.SetV(self, iv, a, true)
                PlaySound("tan00")
                task.New(self, function()
                    task.Wait(wait)
                    object.ChangingV(self, iv, v * 0.5, a, time)
                    object.Del(self)
                    if not self._no_colli then
                        Create.laser_line(self.x, self.y, col, v, a, 15, 8, 5, 10)
                    end
                end)
            end
            local enemy1 = Class(enemy, {
                init = function(self, x, y, vx1, vy1, vx2, vy2)
                    enemy.init(self, 1, HP(15), false, false, false, 2)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx1, vy1
                    task.New(self, function()
                        task.Wait(ran:Int(35, 125))
                        for _ = 1, stage_lib.GetValue(1, 2, 3, 15) do
                            for a in sp.math.AngleIterator(-90 + ran:Float(-10, 10), 6) do
                                grain_to_laser(self.x, self.y, 2, 0.5,
                                        stage_lib.GetValue(7, 8, 9, 30), a, 0, 40)
                            end
                            local t = int(stage_lib.GetValue(100, 75, 50, 10))
                            task.Wait(t)
                        end
                    end)
                    task.New(self, function()
                        task.Wait(25)
                        for i = 1, 36 do
                            self.vx = vx1 + (vx2 - vx1) * (i / 36)
                            self.vy = vy1 + (vy2 - vy1) * (i / 36)
                            task.Wait()
                        end
                        task.Wait(352)
                        Del(self)
                    end)
                end,
            }, true)
            local enemy2 = Class(enemy, {
                init = function(self, cx, cy, a, o, r, bA)
                    enemy.init(self, 25, HP(30), false, false, false, 8)
                    self.x, self.y = cx + cos(a) * r, cy + sin(a) * r
                    self.omega = o * 2
                    task.New(self, function()
                        while true do
                            for v = 1, int(stage_lib.GetValue(3, 4, 5, 18)) do
                                Create.bullet_accel(self.x, self.y, diamond, 8,
                                        0.3, stage_lib.GetValue(2, 3, 4, 15) + v * 0.3, bA)
                            end
                            PlaySound("tan00")
                            task.Wait(int(stage_lib.GetValue(16, 12, 10, 2)))
                        end
                    end)
                    task.New(self, function()
                        for _ = 1, abs(360 / o) do
                            a = a + o
                            self.x, self.y = cx + cos(a) * r, cy + sin(a) * r
                            task.Wait()
                        end
                        object.RawDel(self)
                    end)
                end,
            }, true)
            task.New(stage.current_stage, function()
                task.Wait(60)
                for _ = 1, 2 do
                    for d = -1, 1, 2 do
                        New(enemy2, 400 * d, 0, -90, -0.7 * d, 250, 90 + 90 * d)
                        task.Wait(150)
                    end
                end
                for d = -1, 1, 2 do
                    New(enemy2, 400 * d, 0, 90, 1 * d, 250, 90 + 90 * d)
                    task.Wait(150)
                end
            end)
            local d = 1
            for _ = 1, 32 do
                New(enemy1, 356 * d, ran:Float(100, 180), -1 * d, -0.2, ran:Float(-3, -4) * d, ran:Float(-0.1, -0.2))
                d = -d
                task.Wait(12)
            end
            task.Wait(95)
            for _ = 1, 32 do
                New(enemy1, 356 * d, ran:Float(0, 100), -1 * d, -0.2, ran:Float(-3, -4) * d, ran:Float(0.1, 0.2))
                d = -d
                task.Wait(12)
            end
        end, _t("我走我的独木桥"))
lib.NewWaveEventInWaves(class, 30, { 11, 12, 13, 14 }, 1,
        0, 1, function(var)
            local enemy4_circle = Class(enemy, {
                init = function(self, x, y, a, r, da, time, delay)
                    enemy.init(self, 32, HP(9), false, true, false, 0.25)
                    self.x, self.y = x + cos(a) * r, y + sin(a) * r
                    self.bound = false
                    local A = a
                    task.New(self, function()
                        for i = 1, time do
                            A = a + da * i / time
                            self.x, self.y = x + cos(A) * r, y + sin(A) * r
                            task.Wait()
                        end
                        object.RawDel(self)
                    end)
                    task.New(self, function()
                        task.Wait(delay)
                        while true do
                            NewSimpleBullet(grain_a, 15, self.x, self.y, stage_lib.GetValue(3, 2, 1.3, 0.3), A)
                            PlaySound("tan00", 0.05, 0, true)
                            task.Wait(stage_lib.GetValue(60, 40, 20, 4))
                        end
                    end)
                end,
            }, true)
            local enemy4_main = Class(enemy, {
                init = function(self, x1, y1, x2, y2, x3, y3)
                    enemy.init(self, 4, HP(12), false, true, false, 1)
                    self.x, self.y = x1, y1
                    task.New(self, function()
                        task.BezierMoveTo(180, 0, x2, y2, x3, y3)
                        object.RawDel(self)
                    end)
                    task.New(self, function()
                        task.Wait(ran:Int(10, 80))
                        if var.chaos >= 50 then
                            Create.bullet_decel(self.x, self.y, ball_big, 2, 4, stage_lib.GetValue(1, 1.6, 2, 7), Angle(self, player))
                            PlaySound("tan00")
                        end
                    end)
                end,
            }, true)
            task.New(stage.current_stage, function()
                task.Wait(150)
                for c = 1, 20 do
                    New(enemy4_circle, 350, -c * 3, 90, 270, 180, 200 + c * 3, c)
                    New(enemy4_circle, 350, c * 3, -90, 200, -180, 200 + c * 3, c)
                    New(enemy4_circle, 350, -c * 6, 90, 100, 180, 200 + c * 3, c)
                    New(enemy4_circle, 350, c * 6, -90, 100, -180, 200 + c * 3, c)
                    New(enemy4_main, 350, 250, 0, c * 5, -350, 120)
                    task.Wait(15)
                end
            end)
            for c = 1, 20 do
                New(enemy4_circle, -350, -c * 3, 90, 270, -180, 200 + c * 3, c)
                New(enemy4_circle, -350, c * 3, -90, 200, 180, 200 + c * 3, c)
                New(enemy4_circle, -350, -c * 6, -90, 100, 180, 200 + c * 3, c)
                New(enemy4_circle, -350, c * 6, 90, 100, -180, 200 + c * 3, c)
                New(enemy4_main, -350, 250, 0, c * 5, 350, 120)
                task.Wait(15)
            end
            task.Wait(300)
            task.New(stage.current_stage, function()
                for _ = 1, 20 do
                    local x = ran:Float(150, 250)
                    New(enemy4_main, -x, 260, -100, 0, -x, -260)
                    New(enemy4_main, x, 260, 100, 0, x, -260)
                    task.Wait(25)
                end
            end)
            for c = 1, 50 do
                New(enemy4_circle, c * 3, 260, 180, 140, 180, 180 + c * 3, c)
                New(enemy4_circle, -c * 3, 260, 0, 180, -180, 180 + c * 3, c)
                New(enemy4_circle, -c * 3, 260, 180, 200, 180, 180 + c * 3, c)
                New(enemy4_circle, c * 3, 260, 0, 250, -180, 180 + c * 3, c)
                task.Wait(10)
            end
        end, _t("忘却的意义"))
lib.NewWaveEventInWaves(class, 31, { 12 }, 3,
        0, 2, function(var)

            local bclass = boss.Define(name("Neet"), -200, 400, _editor_class.neet_bg, "Neet")

            local sc = boss.card.New("「Baccano!」", 2, 8, 40, HP(1400))
            boss.card.add(bclass, sc)
            function sc:before()
                task.MoveToForce(0, 120, 60, 2)
                Newcharge_in(self.x, self.y, 120, 152, 255)
                task.Wait(60)
            end
            function sc:del()
                if lstg.weather.JiYun then
                    ext.achievement:get(104)
                end
            end
            function sc:frame()

                    if lstg.tmpvar.BaccanoMiss then
                        if lstg.var.miss >= lstg.tmpvar.BaccanoMiss + 5 then
                            ext.achievement:get(103)
                        end
                    end
            end
            function sc:init()
                lstg.tmpvar.BaccanoMiss = lstg.var.miss
                task.New(self, function()
                    task.Wait(60)
                    task.New(self, function()
                        task.Wait(60)
                        local d = 1
                        while true do
                            local A = Angle(self, player)
                            for c = 0, stage_lib.GetValue(2, 3, 4, 18) do
                                for a in sp.math.AngleIterator(A + c * 2 * d, int(stage_lib.GetValue(18, 22, 24, 80))) do
                                    NewSimpleBullet(ball_mid, 15, self.x, self.y,
                                            stage_lib.GetValue(3, 3.6, 4.2, 14) - c * 0.1, a)
                                end
                            end
                            PlaySound("tan00")
                            d = -d
                            task.Wait(stage_lib.GetValue(60, 50, 40, 10))
                        end
                    end)
                    local A = 0
                    local v = 0
                    while true do
                        for a = 1, 25 do
                            local b = Create.bullet_dec_acc(self.x + cos(a * 360 / 25 + A) * 100, self.y + sin(a * 360 / 25 - A) * 100,
                                    arrow_small, 6, 6, stage_lib.GetValue(3, 4, 5, 18) + v, a * 360 / 25)
                            b.time2 = 20
                            b.time3 = int(stage_lib.GetValue(120, 100, 80, 20))
                        end

                        PlaySound("tan00")
                        task.Wait(stage_lib.GetValue(5, 3, 2, 2))
                        A = A + 3.75
                        v = v + 1 / 600
                    end
                end)
            end
            function sc:other_bonus_drop()
                if not IsSpecialMode() then
                    scoredata.NeetQuestions[6] = 1
                    if table.concat(scoredata.NeetQuestions) == "111111" then
                        ext.achievement:get(102)
                    end
                end
            end
            boss.Create(bclass)
        end, _t("五难题之六"), nil, nil, true)
lib.NewWaveEventInWaves(class, 32, { 5, 10 }, 1,
        0, 1, function(var)
            local bclass = boss.Define(name("Yukari"), 0, 400, _editor_class.yukari_bg, "Yukari")
            local sc = boss.card.New("「不朽的境界」", 2, 5, 40, HP(1400))
            boss.card.add(bclass, sc)
            function sc:before()
                boss.show_aura(self, false)
                self.back = New(_editor_class.YukariBack, self)
                PlaySound("ch02")
                New(boss_cast_darkball, 0, 120, 60, 80, 360, 1, 270, 64, 64, 255, 2)
                New(boss_cast_darkball, 0, 120, 60, 80, 360, 1, 270, 255, 64, 64, -2)
                task.Wait(80)
                self.x, self.y = 0, 120
                boss.show_aura(self, true)
                Newcharge_in(self.x, self.y, 250, 128, 114)
                task.Wait(60)
            end
            function sc:init()
                task.New(self, function()
                    local arrow = Class(bullet, {
                        init = function(self, master, a, o, r, dr)
                            bullet.init(self, arrow_small, 6, false, true)
                            self.master = master
                            self.bound = false
                            self.x, self.y = master.x, master.y
                            task.New(self, function()
                                local l = 0
                                task.New(self, function()
                                    while true do
                                        if not IsValid(self.master) then
                                            object.Del(self)
                                            NewSimpleBullet(ball_light, 6, self.x, self.y, 6, self.rot)
                                            PlaySound("kira00")
                                            break
                                        end
                                        self.rot = a

                                        self.x, self.y = self.master.x + cos(a) * l, self.master.y + sin(a) * l
                                        a = a + o
                                        task.Wait()
                                    end
                                end)
                                local T = stage_lib.GetValue(280, 240, 200, 50)
                                local n1 = int(T / 280 * 60)
                                for i = 1, n1 do
                                    l = sin(i / n1 * 90) * r
                                    task.Wait()
                                end
                                task.Wait(int(T / 280 * 40))
                                local n2 = int(T / 280 * 180)
                                for i = 1, n2 do
                                    l = r + sin(i / n2 * 180) * dr
                                    task.Wait()
                                end

                            end)
                        end
                    }, true)
                    local center = Class(object, {
                        init = function(self, x, y, d, ag)
                            self.x, self.y = x, y
                            self.vx = ran:Float(0.2, 0.4) * d
                            self.vy = 2.5
                            self.ag = ag
                            self.maxvy = stage_lib.GetValue(4, 5, 6, 20)
                            self.group = GROUP.INDES
                            self.colli = false
                            local N = 48
                            local A = ran:Float(0, 360)
                            for a in sp.math.AngleIterator(0, N) do
                                New(arrow, self, a + A, d * 0.15, 100, LineNum(a * 6) * 40)
                                New(arrow, self, a + A, -d * 0.3, 190, LineNum(a * 6) * 50)
                            end
                        end
                    }, true)

                    Newcharge_in(0, 70, 250, 128, 114)
                    task.MoveTo(0, 70, 59, 2)
                    task.Wait()
                    boss.cast(self, 3600)
                    local d = 1
                    while true do
                        New(center, self.x, self.y, d, stage_lib.GetValue(0.03, 0.04, 0.05, 0.18))
                        local A = Angle(self, player)
                        for c = 0, 4 do
                            for a in sp.math.AngleIterator(A + c * 5 * d, int(stage_lib.GetValue(18, 22, 24, 80))) do
                                local b = NewSimpleBullet(ball_light, 4, self.x, self.y,
                                        stage_lib.GetValue(3, 3.6, 4.2, 13), a)
                                object.SetSizeColli(b, 0.8 - 0.4 * sin(a / 2 + 45))
                            end
                            PlaySound("tan00")
                            task.Wait(stage_lib.GetValue(18, 15, 12, 3))
                        end
                        d = -d
                        task.Wait(stage_lib.GetValue(60, 50, 40, 10))
                    end
                end)
            end
            boss.Create(bclass)
        end, _t("永垂不朽！"), nil, nil, true)
_w = lib.NewWaveEventInWaves(class, 33, { 15 }, 1,
        0, 1, function(var)
            lstg.tmpvar.JunkoNomiss = lstg.var.miss
            if lstg.weather.KuangQi then
                ext.achievement:get(101)
            end
            local bclass = boss.Define(name("Junko"), 0, 400, _editor_class.junko_bg, "Junko")

            local non_sc1 = boss.card.New("", 1, 4, 40, HP(1100))
            boss.card.add(bclass, non_sc1)
            function non_sc1:before()
                lstg.tmpvar.otherMusic = "2_boss1"
                lstg.tmpvar.otherMusic_start_time = 82.5 - 140 / 60
                boss.show_aura(self, false)
                PlaySound("ch02")
                New(boss_cast_darkball, 0, 120, 60, 80, 360, 1, 270, 64, 64, 255, 2)
                New(boss_cast_darkball, 0, 120, 60, 80, 360, 1, 270, 255, 64, 64, -2)
                task.Wait(80)
                self.x, self.y = 0, 120
                boss.show_aura(self, true)
                for a = -2, 2 do
                    New(_editor_class.JunkoBack, self, 3 - abs(a), 90 + a * 40)
                end
                Newcharge_in(self.x, self.y, 250, 128, 114)
                task.Wait(60)
            end
            function non_sc1:init()
                task.New(self, function()
                    local d = 1
                    while true do

                        local A = ran:Float(0, 360)
                        boss.cast(self, 90 * 4)
                        for _ = 1, 4 do

                            servant.init(NewObject(servant), self.x, self.y, 0, 218, 112, 214, 1.5, function(unit)
                                task.New(unit, function()
                                    unit:FadeIn(15)
                                    object.ChangingSizeColli(unit, -0.5, -0.5, 15)
                                end)
                                task.New(unit, function()
                                    unit.vx, unit.vy = -4 * d, -2
                                    unit.ax, unit.ay = 0.07 * d, -0.02

                                    for i = 1, stage_lib.GetValue(10, 12, 14, 51) do
                                        for a in sp.math.AngleIterator(A, int(stage_lib.GetValue(28, 35, 43, 155))) do
                                            local M = stage_lib.GetValue(0.9, 1, 1.2, 4)
                                            local b = Create.bullet_accel(unit.x, unit.y, ball_mid, 6, 1,
                                                    (5 - i / 14 * 3.5) * M,
                                                    a, true, false, 0)
                                            b.flag = true
                                            function b:frame_new()
                                                bullet.frame(self)
                                                if not self.xiaoxue_frozen and not self._frozen then
                                                    self.y = self.y + M
                                                end
                                            end
                                            PlaySound("kira00")
                                        end
                                        task.Wait(5)
                                    end
                                end)
                            end)

                            task.Wait(90)
                            d = -d
                        end
                        Newcharge_in(self.x, self.y, 135, 206, 235)
                        task.Wait(60)
                        Newcharge_out(self.x, self.y, 135, 206, 235)
                        task.New(self, function()
                            task.MoveToPlayer(60, -200, 200, 100, 144,
                                    40, 50, 10, 20, 2, 1)
                        end)
                        task.New(self, function()
                            for i = 1, 90 do
                                local v = i / 90 * stage_lib.GetValue(3, 3.5, 4.2, 15)
                                object.BulletDo(function(b)
                                    if b.flag then
                                        local _a = Angle(0, 0, b.dx, b.dy)
                                        b.x = b.x + cos(_a) * v
                                        b.y = b.y + sin(_a) * v
                                    end
                                end)
                                task.Wait()
                            end
                            object.BulletDo(function(b)
                                if b.flag then
                                    b.vx = b.dx
                                    b.vy = b.dy
                                end
                            end)
                        end)
                        local N = int(stage_lib.GetValue(30, 35, 40, 120))
                        for a in sp.math.AngleIterator(ran:Float(0, 360), N) do
                            for v = 1, stage_lib.GetValue(5, 7, 9, 36) do
                                local b = NewSimpleBullet(ball_mid, 2, self.x, self.y, 1 + v * 0.2, a + v * 180 / N)
                                b.fogtime = 0
                            end
                        end
                        d = -d
                        task.Wait(90)
                    end
                end)
            end

            local sc1 = boss.card.New("「月有阴晴圆缺」", 2, 8, 40, HP(1600))
            boss.card.add(bclass, sc1)
            function sc1:before()
                task.Wait(60)
            end
            function sc1:init()
                task.New(self, function()

                    task.MoveToForce(0, 120, 60, 2)

                    local kmoon_p = function(center, a, o, ir, tr, KR, col)
                        local self = NewObject(bullet)
                        bullet.init(self, ball_mid, col, false, false)
                        self.fogtime = 0
                        self.x, self.y = center.x + cos(a) * ir, center.y + sin(a) * ir
                        self.colli = false
                        self._force_colli = true
                        self._a = 0
                        self.bound = false
                        self._blend = "mul+add"
                        local R = ir
                        local R2 = 0
                        task.New(self, function()
                            for i = 1, 60 do
                                self._a = i / 60 * 255
                                task.Wait()
                            end
                            self.colli = true
                            self._force_colli = nil
                            for i = 1, 240 do
                                i = task.SetMode[3](i / 240)
                                R = ir + (-ir + tr) * i
                                R2 = KR * i
                                task.Wait()
                            end
                            if col == 14 then
                                while true do
                                    Create.bullet_accel(self.x, self.y, grain_a, col, 1,
                                            stage_lib.GetValue(3, 4, 5, 18), a, true, false)
                                    PlaySound("tan00")
                                    task.Wait(stage_lib.GetValue(80, 70, 60, 15))
                                end
                            end
                        end)
                        task.New(self, function()

                            while IsValid(center) do
                                local A = Angle(center, player)
                                self.x, self.y = center.x + cos(A) * R2 + cos(a) * R, center.y + sin(A) * R2 + sin(a) * R
                                a = a + o
                                task.Wait()
                            end
                            Del(self)
                        end)
                    end
                    local function moon(ix, iy, mx, my, col)
                        local R, G, B = unpack(ColorList[math.ceil(col / 2)])
                        local center = NewObject(servant)
                        servant.init(center, self.x, self.y, 0, R, G, B, 1.5, function(self)
                            self.bound = false
                            task.New(self, function()
                                self:FadeIn(15)
                                object.ChangingSizeColli(self, -0.5, -0.5, 15)
                            end)
                            task.New(self, function()
                                self.x, self.y = ix, iy
                                task.Wait(60)
                                task.New(self, function()
                                    task.Wait(210 - 60)
                                    Newcharge_in(mx, my, R, G, B)
                                end)
                                task.MoveTo(mx, my, 210, 3)
                                Newcharge_out(self.x, self.y, R, G, B)
                                local A = Angle(self, player)
                                for a in sp.math.AngleIterator(A, int(stage_lib.GetValue(13, 16, 20, 72))) do
                                    ParticleLaserLine(R, G, B, self.x + cos(A) * 25, self.y + sin(A) * 25,
                                            col, stage_lib.GetValue(8, 10, 12, 42), a, 25, 20)
                                end
                                misc.ShakeScreen(35, 2, 1, 1.5, 1)
                                task.New(self, function()
                                    task.Wait(30)
                                    while true do
                                        task.MoveToPlayer(60, mx - 50, mx + 50, my - 20, my + 20,
                                                30, 40, 10, 20, 2, 3)
                                        if col == 2 then
                                            task.Wait(90)
                                            Newcharge_in(self.x, self.y, R, G, B)
                                            task.Wait(60)
                                            Newcharge_out(self.x, self.y, R, G, B)
                                            task.New(self, function()
                                                for _ = 1, int(stage_lib.GetValue(5, 6, 7, 27)) do
                                                    A = Angle(self, player)
                                                    for z = -2, 2 do
                                                        ParticleLaserLine(R, G, B, self.x + cos(A) * 25, self.y + sin(A) * 25,
                                                                col, stage_lib.GetValue(8, 10, 12, 42),
                                                                A + z * stage_lib.GetValue(25, 19, 15, 4),
                                                                25, 20)
                                                    end
                                                    misc.ShakeScreen(20, 1.5, 1, 1.5, 1)
                                                    task.Wait(15)
                                                end
                                            end)
                                            task.Wait(75)
                                        else
                                            task.Wait(150)
                                        end
                                    end
                                end)
                            end)
                        end)
                        local o = stage_lib.GetValue(0.2, 0.3, 0.4, 1.5)
                        local N = int(stage_lib.GetValue(28, 34, 40, 125))
                        for a in sp.math.AngleIterator(ran:Float(0, 360), N) do
                            kmoon_p(center, a, o, 500, 100, 0, col)
                        end
                        for a in sp.math.AngleIterator(ran:Float(0, 360), N - 10) do
                            kmoon_p(center, a, -o - 0.1, 350, 60, 20, col)
                        end
                        for a in sp.math.AngleIterator(ran:Float(0, 360), N - 20) do
                            kmoon_p(center, a, o + 0.2, 150, 30, 25, col)
                        end
                    end
                    task.Wait(60)
                    boss.cast(self, 3600)
                    task.New(self, function()
                        moon(0, 500, -50, 100, 2)
                        task.Wait(420)
                        moon(0, 500, 50, 100, 2)
                    end)
                    moon(0, 0, -200, 140, 14)
                    task.Wait(320)
                    moon(0, 0, 200, 140, 14)


                end)
            end

            local non_sc2 = boss.card.New("", 1, 4, 40, HP(1100))
            boss.card.add(bclass, non_sc2)
            function non_sc2:before()
                task.MoveToForce(0, 120, 60, 2)
            end
            function non_sc2:init()
                task.New(self, function()
                    task.Wait(60)
                    local d = 1
                    while true do

                        local A = ran:Float(0, 360)
                        boss.cast(self, 90 * 4)
                        for _ = 1, 4 do

                            servant.init(NewObject(servant), self.x, self.y, 0, 218, 112, 214, 1.5, function(unit)
                                task.New(unit, function()
                                    unit:FadeIn(15)
                                    object.ChangingSizeColli(unit, -0.5, -0.5, 15)
                                end)
                                task.New(unit, function()
                                    unit.vx, unit.vy = 0 * d, -4
                                    unit.ax, unit.ay = stage_lib.GetValue(0.04, 0.05, 0.06, 0.21) * d, -0.02

                                    for i = 1, stage_lib.GetValue(8, 9, 10, 36) do
                                        for a in sp.math.AngleIterator(A, 28) do
                                            local M = stage_lib.GetValue(0.9, 1, 1.2, 4.2)
                                            local b = Create.bullet_decel(unit.x, unit.y, ball_mid, 3, 6, (5 - i / 14 * 3.5) * M,
                                                    a, true, false, 0)
                                            b.flag = true
                                            function b:frame_new()
                                                bullet.frame(self)
                                                if not self.xiaoxue_frozen and not self._frozen then
                                                    self.y = self.y + M
                                                end
                                            end
                                            PlaySound("kira00")
                                        end
                                        task.Wait(5)
                                    end
                                end)
                            end)

                            task.Wait(45)
                            d = -d
                        end
                        local N = int(stage_lib.GetValue(28, 33, 38, 120))
                        for a in sp.math.AngleIterator(A, N) do
                            local b = Create.bullet_accel(self.x, self.y, ball_light, 8, 1, 5, a)
                            b.wait, b.time = 0, 45
                        end
                        PlaySound("tan00")
                        Newcharge_in(self.x, self.y, 135, 206, 235)
                        task.Wait(60)
                        Newcharge_out(self.x, self.y, 135, 206, 235)
                        task.New(self, function()
                            for k = 1, 4 do
                                local x = self.x + d * ran:Float(100, 140)
                                local y = 200 - k * 80
                                for a in sp.math.AngleIterator(A, int(stage_lib.GetValue(28, 35, 43, 150)) - k * 3) do
                                    local b = Create.bullet_accel(x, y, ball_mid, 6, 1, 4.5, a)
                                    b.wait = 0
                                end
                                PlaySound("kira00")
                                d = -d
                                task.Wait(3)
                            end
                        end)
                        task.New(self, function()
                            task.MoveToPlayer(60, -200, 200, 120, 144,
                                    40, 50, 8, 10, 2, 1)
                        end)
                        local x, y = self.x, self.y
                        for k = 1, 16 do
                            for a in sp.math.AngleIterator(A, N) do
                                local b = Create.bullet_accel(x, y, ball_light, 8, 6 - k / 16 * 5, 12, a)
                                b.wait, b.time = 0, 45
                            end
                            task.Wait(5)
                        end
                        d = -d
                    end
                end)
            end

            local sc2 = boss.card.New("「终止标记的壁垒」", 2, 8, 40, HP(1600))
            boss.card.add(bclass, sc2)
            function sc2:before()
                task.Wait(60)
            end
            function sc2:init()
                local big_laser_warning = function(x, y, w, wait, rot, col)
                    local self = NewObject(Class(object, {
                        frame = function(self)
                            task.Do(self)
                            local l
                            for i = #self.renderline, 1, -1 do
                                l = self.renderline[i]
                                l.time = max(l.time - 1, 0)
                                if l.time == 0 then
                                    table.remove(self.renderline, i)
                                end
                            end
                        end,
                        render = function(self)
                            for _, l in ipairs(self.renderline) do
                                SetImageState("white", "mul+add", 200 * l.time / l.maxtime, self.linecol[1], self.linecol[2], self.linecol[3])
                                Render("white", self.x - sin(rot) * l.offx, self.y + cos(rot) * l.offx, rot, 100, l.w / 16)
                            end
                        end
                    }, true))
                    self._blend = "mul+add"
                    self.x, self.y = x, y
                    self.colli = false
                    self.linecol = ColorList[math.ceil(col / 2)]
                    self.renderline = {}
                    task.New(self, function()
                        local n = int(wait) - 1
                        local x0 = 0
                        for i = 0, n do
                            local x1 = task.SetMode[2](i / n) * w
                            for z = -1, 1, 2 do
                                table.insert(self.renderline, { offx = z * x1,
                                                                time = 30, maxtime = 30, w = abs(x1 - x0)
                                })
                            end
                            x0 = x1
                            task.Wait()
                        end
                        while #self.renderline > 0 do
                            task.Wait()
                        end
                        object.RawDel(self)
                    end)
                    return self
                end
                task.New(self, function()
                    task.MoveToForce(0, 120, 60, 2)

                    local kd = 0
                    local index = stage_lib.GetValue(0.9, 0.7, 0.5, 0.1)
                    local ROT = 0
                    local cx = 0
                    local another_warning = function(x, y, rot, col)
                        local self = NewObject(Class(object, {
                            frame = function(self)
                                task.Do(self)
                                local l
                                for i = #self.renderline, 1, -1 do
                                    l = self.renderline[i]
                                    l.time = max(l.time - 1, 0)
                                    if l.time == 0 then
                                        table.remove(self.renderline, i)
                                    end
                                end
                            end,
                            render = function(self)
                                for _, l in ipairs(self.renderline) do
                                    SetImageState("white", "mul+add", 200 * l.time / l.maxtime, self.linecol[1], self.linecol[2], self.linecol[3])
                                    Render("white", self.x - sin(rot) * l.offx, self.y + cos(rot) * l.offx, rot, 100, l.w / 16)
                                end
                            end
                        }, true))
                        self._blend = "mul+add"
                        self.x, self.y = x, y
                        self.colli = false
                        self.linecol = ColorList[math.ceil(col / 2)]
                        self.renderline = {}
                        task.New(self, function()
                            local x0 = 0
                            local x1 = 0
                            while true do
                                local _x = (ROT) / index
                                x1 = x1 + (-x1 + _x) * 0.1
                                table.insert(self.renderline, { offx = x1 - cx, time = 30, maxtime = 30, w = max(2, abs(x1 - x0)) })
                                x0 = x1
                                task.Wait()
                            end
                            object.RawDel(self)
                        end)
                        return self
                    end
                    local center = Class(bullet, {
                        init = function(self, x, y, mx, my, d)
                            bullet.init(self, ball_light, 6, false, false)
                            --object.SetSizeColli(self, 0.8, 0.8)
                            self.x, self.y = x, y
                            self.bound = false
                            self.dis = -180
                            task.New(self, function()
                                task.MoveToEx(mx - x, my - y, 60, 2)

                                while true do
                                    for z = -1, 1, 2 do
                                        local b = NewSimpleBullet(arrow_small, 6, self.x + z * 5, self.y,
                                                5, (90 + ROT) * d)
                                        b.stay = false
                                    end

                                    PlaySound("tan00")
                                    task.Wait(6)
                                end
                            end)
                            task.New(self, function()
                                while true do
                                    local k = d * (player.y - self.dis) * min(1, 1 - abs(self.x - player.x) / 190) + my
                                    self.y = clamp(self.y + (-self.y + k) * 0.05, -208, 208)
                                    task.Wait()
                                end
                            end)
                        end
                    }, true)
                    object.Connect(self, another_warning(0, -24, 90, 6), 0, true)

                    Newcharge_in(self.x, self.y, 250, 128, 114)
                    object.Connect(self, big_laser_warning(-320, -240, 150, 60, 0, 2), 0, true)
                    for i = 1, 60 do
                        i = task.SetMode[2](i / 60)
                        player.x = clamp(player.x, -320 + 320 * i, 320 - 320 * i)
                        player.y = max(-240 + 150 * i, player.y)
                        task.Wait()
                    end
                    task.New(self, function()
                        for _ = 1, 60 do
                            cx = player.x
                            task.Wait()
                        end
                        local t = 90
                        while true do
                            ROT = ROT + (player.dx) * index + kd
                            kd = sin(t) * 2
                            task.Wait()
                            t = t + 1
                        end
                    end)
                    for x = -8, 8 do
                        New(center, self.x, self.y, x * 40, 130, 1)
                        New(center, 0, -250, x * 40, -130, -1)
                    end
                    local d = 1
                    local i = 1
                    boss.cast(self, 40 * 60)
                    while true do
                        for a in sp.math.AngleIterator(90 + d * i * 0.9, int(stage_lib.GetValue(20, 26, 31, 120))) do
                            local v = stage_lib.GetValue(1.6, 2, 2.6, 9)
                            Create.bullet_changeangle(self.x, self.y, ball_mid, 4 + d * 2, v + d * 0.1, a)
                        end
                        PlaySound("tan00")
                        d = -d
                        i = i + 1
                        task.Wait(16)
                    end
                end)
            end

            local non_sc3 = boss.card.New("", 1, 4, 40, HP(1100))
            boss.card.add(bclass, non_sc3)
            function non_sc3:before()
                task.MoveToForce(0, 120, 60, 2)
            end
            function non_sc3:init()
                task.New(self, function()
                    Newcharge_in(self.x, self.y, 200, 100, 100)
                    task.Wait(60)
                    local d = 1
                    while true do
                        boss.cast(self, 90)
                        for i = 1, 3 do
                            local N = int(stage_lib.GetValue(18, 22, 26, 90))
                            for a in sp.math.AngleIterator(0, N) do
                                task.New(Create.laser_changeangle(self.x, self.y, 8, 16, 8, 6 - i * 1.1, a,
                                        { r = d * (6 - i * 0.08), time = 60 },
                                        { r = d * (-2 - i * 0.1), time = 40 },
                                        { r = d * (3 - i * 0.1), time = 59 }, { r = d * 0.4, time = 90 }), function()
                                    local self = task.GetSelf()
                                    self.bound = false
                                    task.Wait(320)
                                    self.bound = true
                                end)
                            end
                        end
                        task.Wait(50)
                        local K = int(stage_lib.GetValue(4, 5, 6, 24))
                        local tA = ran:Float(0, 360)
                        for t = 1, K do
                            local N = int(stage_lib.GetValue(15, 18, 23, 90))
                            for a in sp.math.AngleIterator(tA, N) do
                                for z = -2, 2 do
                                    local b = NewSimpleBullet(ball_mid, 6, self.x, self.y, 2.5, a + z * 1.2 + t * 180 / N)
                                    b._blend = "mul+add"
                                end
                            end
                            PlaySound("tan00")
                            task.Wait(90 / K)
                        end
                        local kA = stage_lib.GetValue(6, 5.2, 4.4, 1.5)
                        for c = 1, 5 do
                            for i = 0, 60 do
                                NewSimpleBullet(ball_light, 2, self.x, self.y, 1.8, -90 + c * d - kA - (360 - kA * 2) * i / 60)
                            end
                            PlaySound("tan00")
                            task.Wait(8)
                        end
                        for c = 4, 1, -1 do
                            for i = 0, 60 do
                                NewSimpleBullet(ball_light, 2, self.x, self.y, 1.8, -90 + c * d - kA - (360 - kA * 2) * i / 60)
                            end
                            PlaySound("tan00")
                            task.Wait(8)
                        end
                        task.Wait(100 - 32)
                        d = -d
                    end
                end)
            end

            local sc3 = boss.card.New("「斗转星移的环带」", 2, 8, 25, HP(2300))
            boss.card.add(bclass, sc3)
            function sc3:before()
                task.Wait(60)
            end
            function sc3:init()
                if lstg.weather.JiYu then
                    ext.achievement:get(105)
                end
                self._time_sc = true--自定义时符
                local camera = { x = 0, y = -160 }
                local rotate = function(x, y, a, o, ir, tr)
                    local b = NewObject(bullet)
                    bullet.init(b, ball_light, 6, false, false)
                    b._x, b._y = x, y
                    b.bound = false
                    b.flag = true
                    b.noTPbyYukari = true
                    task.New(b, function()
                        local R = ir
                        local t = 1
                        while true do
                            b._x, b._y = x + cos(a) * R, y + sin(a) * R
                            a = a + o
                            R = ir + sin(t) * (tr - ir)
                            t = min(t + 1, 90)
                            b.x, b.y = b._x - camera.x, b._y - camera.y
                            task.Wait()
                        end
                    end)
                    task.New(b, function()
                        task.Wait(60)
                        while true do
                            local _b = Create.bullet_accel(b.x, b.y, star_small, 4, 1, 3, a, true, false)
                            _b.omega = ran:Float(2, 3) * ran:Sign()
                            PlaySound("tan00")
                            task.Wait(stage_lib.GetValue(140, 100, 80, 25))
                        end
                    end)
                    object.Connect(self, b, 0, true)
                end
                task.New(self, function()
                    task.MoveToForce(0, 144, 60, 2)
                    Newcharge_in(self.x, self.y, 250, 128, 114)
                    task.Wait(60)
                    boss.cast(self, 6600, true)
                    task.New(self, function()
                        local A = -90

                        local t = 1
                        while true do
                            local x, y = camera.x, camera.y
                            local dx, dy = (-x + player.x) * 0.1, (-y + player.y) * 0.1
                            camera.x = camera.x + dx
                            camera.y = camera.y + dy
                            t = min(t + 1, 90)
                            A = A + sin(t) * 0.4
                            self.bg.layers[1].x = self.bg.layers[1].x - dx
                            self.bg.layers[1].y = self.bg.layers[1].y - dy
                            self.bg.layers[2].x = self.bg.layers[2].x - dx
                            self.bg.layers[2].y = self.bg.layers[2].y - dy
                            player.x = player.x - dx
                            player.y = player.y - dy
                            object.EnemyNontjtDo(function(b)
                                b.x = b.x - dx
                                b.y = b.y - dy
                            end)
                            for _, obj in ObjList(GROUP.PLAYER_BULLET) do
                                obj.x = obj.x - dx
                                obj.y = obj.y - dy
                            end
                            for _, obj in ObjList(GROUP.ITEM) do
                                obj.x = obj.x - dx
                                obj.y = obj.y - dy
                            end
                            object.BulletIndesDo(function(b)
                                if not b.flag then
                                    b.x = b.x - dx
                                    b.y = b.y - dy
                                end
                            end)

                            task.Wait()
                        end
                    end)
                    local d = 1
                    for r = 1, 6 do
                        for a in sp.math.AngleIterator(ran:Float(0, 360), r * 8) do
                            rotate(self.x + camera.x, self.y + camera.y, a, d * 0.6, 0, r * 45)
                        end
                        for a in sp.math.AngleIterator(ran:Float(0, 360), 60) do
                            rotate(self.x + camera.x, self.y + camera.y, a, d * 0.6, 700, 400 + r * 35)
                        end
                        d = -d
                    end
                    task.Wait(90)
                    task.New(self, function()

                        local rot = -90
                        local t = 1
                        while true do
                            for a in sp.math.AngleIterator(ran:Float(0, 360), 85) do
                                local b = NewSimpleBullet(ball_mid, 6, self.x + cos(a) * 600, self.y + sin(a) * 600, 6, a)
                                b.stay = false
                                b._blend = "mul+add"
                            end
                            local N = int(stage_lib.GetValue(15, 22, 28, 99))
                            for a in sp.math.AngleIterator(rot + 180 / N, N) do
                                local b = NewSimpleBullet(ellipse, 2, self.x, self.y, 8, a)
                                b.stay = false
                            end
                            PlaySound("tan00")
                            rot = rot + 1.5 * sin(t)
                            t = min(t + 1, 90)
                            task.Wait(4)
                        end
                    end)


                end)
            end
            function sc3:del()
                self.cast_t = 0
                New(tasker, function()
                    task.Wait(60)
                    self.bg.layers[1].x = 0
                    self.bg.layers[1].y = 144
                    self.bg.layers[2].x = 0
                    self.bg.layers[2].y = 0
                end)
                if var.wave ~= var.maxwave then
                    lstg.tmpvar.otherMusic = nil
                end
            end
            function sc3:other_drop()
                mission_lib.GoMission(49)
                if var.wave ~= var.maxwave then
                    item.dropItem(item.drop_card, 1, self.x, self.y + 30, 86)
                end
            end
            boss.Create(bclass)
        end, _t("心之所在"), nil, true, true)


