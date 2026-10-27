local lib = stage_lib
local servant = _editor_class.SimpleServant
local class = SceneClass[1]
local HP = lib.GetHP
local function _t(str)
    return i18n("scene1", str) or ""
end
local function name(str)
    return i18n("bossname", str)
end

lib.NewWaveEventInWaves(class, 21, { 11, 12, 13, 14 }, 1,
        0, 1, function(var)

            local stg = stage.current_stage
            local enemy1 = Class(enemy, {
                init = function(self, x, y, vx1, vy1)
                    enemy.init(self, 31, HP(6), false, true, false, 0.4)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx1, vy1
                    task.New(self, function()
                        if var.chaos >= 50 then
                            task.Wait(ran:Int(35, 125))
                            for _ = 1, stage_lib.GetValue(5, 8, 13, 60) do
                                Create.bullet_accel(self.x, self.y, ball_mid, 4, 0.3, min(9, 2 + var.chaos / 35), ran:Float(0, 360))
                                PlaySound("tan00")
                                task.Wait(stage_lib.GetValue(40, 30, 25, 8))
                            end
                        end
                    end)
                    task.New(self, function()
                        task.Wait(200)
                        for i = 1, 36 do
                            self.vx = vx1 + vx1 * (i / 36)
                            self.vy = vy1 + vy1 * (i / 36)
                            task.Wait()
                        end
                        task.Wait(200)
                        Del(self)
                    end)
                end,
            }, true)
            local enemy2 = Class(enemy, {
                drop = function(self)
                    New(bullet_cleaner, self.x, self.y, 100, 10, 10, true, false, 0)
                end,
                init = function(self, x, y, vx, vy)
                    enemy.init(self, 25, HP(30), false, true, false, 8)
                    self.x, self.y = x, y
                    self.colli = false
                    task.New(self, function()
                        self.hscale, self.vscale = 0, 0
                        self._r, self._g, self._b = 120, 120, 120
                        for i = 1, 30 do
                            self.vy = 1 - task.SetMode[1](i / 30)
                            self.hscale = i / 30
                            self.vscale = self.hscale
                            task.Wait()
                        end
                        self._r, self._g, self._b = 255, 255, 255
                        self.colli = true
                        for a in sp.math.AngleIterator(ran:Float(0, 360), int(stage_lib.GetValue(20, 35, 45, 120))) do
                            Create.bullet_decel(self.x, self.y, water_drop, 6,
                                    4, max(0.7, 2.5 - var.chaos / 60), a, true, false)
                        end
                        PlaySound("tan00")
                        task.Wait(20)
                        for i = 1, 60 do
                            self.vx, self.vy = i / 60 * vx, i / 60 * vy
                            task.Wait()
                        end
                    end)
                end,
            }, true)
            task.New(stg, function()
                local n = (int(stage_lib.GetValue(5, 10, 18, 50)) - 1) / 2
                for _ = 1, 17 do
                    for z = -n, n do
                        New(enemy1, z * 300 / n, 300, ran:Float(-0.1, 0.1), -1)
                    end
                    task.Wait(30)
                end
            end)

            for _ = 1, 15 do
                New(enemy2, ran:Float(-270, 270), ran:Float(0, 100), ran:Sign() * 2, 0, 1)
                task.Wait(45)
            end
            task.Wait(30)

            task.Wait(30)
        end, _t("水波不兴"))
lib.NewWaveEventInWaves(class, 22, { 11, 12, 13, 14 }, 1,
        0, 1, function(var)

            local enemy1 = Class(enemy, {
                init = function(self, x, y, vx1, vy1)
                    enemy.init(self, 4, HP(10), false, true, false, 0.5)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx1, vy1
                    self.ag = 0.04
                    task.New(self, function()
                        if var.chaos >= 50 then
                            -- task.Wait(ran:Int(35, 125))
                            for _ = 1, 60 do
                                Create.bullet_accel(self.x, self.y, ball_mid, 2, 0, 2, 90)
                                PlaySound("tan00")
                                task.Wait(stage_lib.GetValue(11, 8, 6, 1))
                            end
                        end
                    end)
                end,
            }, true)
            local d = ran:Sign()
            for _ = 1, 3 do
                local t = 20
                for _ = 1, 128 do
                    for _ = 1, 1 do
                        New(enemy1, ran:Float(-350, -250) * d, 300, ran:Float(0.2, 6) * d, ran:Float(-0.3, -0.6))
                    end
                    task.Wait(t)
                    t = max(t - 1, 1)
                end
                task.Wait(60)
                d = -d
            end
            task.Wait(50)
        end, _t("逃荒"))
lib.NewWaveEventInWaves(class, 23, { 11, 12, 13, 14 }, 0,
        2, 2, function(var)

            local stg = stage.current_stage
            local enemy1 = Class(enemy, {
                init = function(self, x, y, vx1, vy1)
                    enemy.init(self, ran:Int(1, 9), HP(ran:Float(10, 25)), false, true, false, 0.33)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx1, vy1
                    self.ag = 0.06
                    self.omega = ran:Sign() * ran:Float(5, 8)
                    task.New(self, function()
                        if var.chaos >= 50 then
                            task.Wait(ran:Int(35, 125))
                            for _ = 1, 30 do
                                Create.bullet_accel(self.x, self.y, ball_small, 2, 0, 2, -90)
                                PlaySound("tan00")
                                task.Wait(stage_lib.GetValue(22, 16, 12, 3))
                            end
                        end
                    end)
                end,
            }, true)
            local t = 22
            for _ = 1, 128 do
                for _ = 1, 4 do
                    local x = ran:Float(-200, 200)
                    New(enemy1, x, 300, x / 80, ran:Float(-0.3, -0.6))
                end
                task.Wait(t)
                t = max(t - 1, 1)
            end
            task.Wait(30)
            task.New(stg, function()
                for i = 1, 120 do
                    i = 5 * (1 - task.SetMode[2](i / 120))
                    object.EnemyDo(function(e)
                        local a = Angle(0, 270, e)
                        e.x = e.x + cos(a) * i
                        e.y = e.y + sin(a) * i

                    end)
                    task.Wait()
                end
            end)
            Newcharge_out(0, 270, 250, 128, 114)
            for v = 1, int(stage_lib.GetValue(3, 5, 6, 20)) do
                for a in sp.math.AngleIterator(ran:Float(0, 360), int(stage_lib.GetValue(110, 120, 130, 200))) do
                    Create.bullet_decel(0, 270, ball_big, 4, 4, 0.7 + v * 0.1, a, false, false)
                end
            end
            misc.ShakeScreen(90, 2, 1, 1.8, 1)
            task.Wait(180)


        end, _t("真正的逃荒！"), nil, true)
lib.NewWaveEventInWaves(class, 24, { 11, 12, 13, 14 }, 1,
        0, 1, function(var)

            local enemy1 = Class(enemy, {
                init = function(self, x, y, snakeg, t, interval, move, speed)
                    enemy.init(self, 2, HP(30), false, true, false, 1)
                    self.x, self.y = x, y
                    snakeg[t] = self
                    task.New(self, function()
                        while true do
                            PlaySound("item01", 0.2, self.x, false)
                            if t == 1 or not IsValid(snakeg[t - 1]) then
                                local xd, yd = sign(player.x - self.x), sign(player.y - self.y)
                                local m = ran:Int(1, 2)
                                if abs(self.x - player.x) <= move / 2 then
                                    m = 2
                                end
                                if abs(self.y - player.y) <= move / 2 then
                                    m = 1
                                end
                                if abs(self.x - player.x) <= move / 2 and abs(self.y - player.y) <= move / 2 then
                                    m = ran:Int(1, 2)
                                end
                                if m == 1 then
                                    task.MoveTo(self.x + xd * move, self.y, speed, 3)
                                end
                                if m == 2 then
                                    task.MoveTo(self.x, self.y + yd * move, speed, 3)
                                end
                            else
                                task.MoveToForce(snakeg[t - 1].x, snakeg[t - 1].y, speed, 3)
                            end
                            task.Wait(interval)
                        end
                    end)

                end,
                frame = function(self)
                    enemy.frame(self)
                    if self.timer >= 60 * 24 then
                        object.Del(self)
                    end
                end,
                kill = function(self)
                    enemy.kill(self)
                    for a in sp.math.AngleIterator(Angle(self, player), int(stage_lib.GetValue(3, 7, 12, 45))) do
                        Create.bullet_accel(self.x, self.y, ball_mid, 10, 0.6, min(8, 2 + var.chaos / 70 * 2), a, false, false)
                    end
                end
            }, true)
            local interval = 0
            local speed = int(stage_lib.GetValue(13, 10, 7, 4))
            local snakeg1 = {}
            for i = 1, int(stage_lib.GetValue(35, 50, 62, 80)) do
                New(enemy1, 0, 300, snakeg1, i, interval, stage_lib.GetValue(20, 24, 30, 36), speed)
                task.Wait(interval + speed)
            end

            task.Wait(180)


        end, _t("贪吃蛇"))
lib.NewWaveEventInWaves(class, 25, { 11, 12, 13, 14 }, 0,
        2, 2, function(var)

            local enemy1 = Class(enemy, {
                init = function(self, x, y, style, snakeg, t, interval, move, speed)
                    enemy.init(self, style, HP(31), false, true, false, 0.4)
                    self.x, self.y = x, y
                    snakeg[t] = self
                    task.New(self, function()
                        while true do
                            PlaySound("item01", 0.2, self.x, false)
                            if t == 1 or not IsValid(snakeg[t - 1]) then
                                local xd, yd = sign(player.x - self.x), sign(player.y - self.y)
                                local m = ran:Int(1, 2)
                                if abs(self.x - player.x) <= move / 2 then
                                    m = 2
                                end
                                if abs(self.y - player.y) <= move / 2 then
                                    m = 1
                                end
                                if abs(self.x - player.x) <= move / 2 and abs(self.y - player.y) <= move / 2 then
                                    m = ran:Int(1, 2)
                                end
                                if m == 1 then
                                    task.MoveTo(self.x + xd * move, self.y, speed, 3)
                                end
                                if m == 2 then
                                    task.MoveTo(self.x, self.y + yd * move, speed, 3)
                                end
                            else
                                task.MoveToForce(snakeg[t - 1].x, snakeg[t - 1].y, speed, 3)
                            end
                            task.Wait(interval)
                        end
                    end)

                end,
                frame = function(self)
                    enemy.frame(self)
                    if self.timer >= 60 * 24 then
                        object.Del(self)
                    end
                end,
                kill = function(self)
                    enemy.kill(self)
                    for a in sp.math.AngleIterator(Angle(self, player), int(stage_lib.GetValue(3, 7, 12, 45))) do
                        Create.bullet_accel(self.x, self.y, ball_big, 16, 0.6, min(8, 2 + var.chaos / 80 * 2), a, false, false)
                    end
                end
            }, true)
            local interval = 0
            local speed = int(stage_lib.GetValue(18, 12, 9, 6))
            local snakeg = { {}, {}, {}, {} }

            for i = 1, int(stage_lib.GetValue(25, 35, 45, 60)) do
                for k = 1, 4 do
                    New(enemy1, cos(k * 90) * 350, sin(k * 90) * 300, k, snakeg[k], i, interval, stage_lib.GetValue(20, 24, 30, 36), speed)

                end
                task.Wait(interval + speed)
            end

            task.Wait(180)


        end, _t("腹背受敌"), nil, true)
lib.NewWaveEventInWaves(class, 26, { 11, 12, 13, 14 }, 1,
        0, 1, function(var)
            local enemy1 = Class(enemy, {
                init = function(self, x, y, mx, my, d)
                    enemy.init(self, 14, HP(200), false, true, false, 15)
                    self.x, self.y = x, y

                    task.New(self, function()
                        task.MoveTo(mx, my, 60, 2)
                        task.Wait(200)
                        object.ChangingV(self, 0, 1, -90, 80, false)
                    end)
                    task.New(self, function()
                        task.Wait(20)
                        local n = int(stage_lib.GetValue(5, 10, 15, 60))
                        for u = 1, 150 do
                            for a in sp.math.AngleIterator(u * 360 / n / 3 * d, n) do
                                Create.bullet_accel(self.x, self.y, ball_mid_c, 6, 1,
                                        stage_lib.GetValue(3, 4, 5, 12), a, false, false)
                            end
                            PlaySound("tan00")
                            task.Wait(stage_lib.GetValue(12, 8, 6, 2))
                        end
                    end)
                end,
            }, true)
            local enemy2 = Class(enemy, {
                init = function(self, x, y, mx, my, v, A, d)
                    enemy.init(self, 9, HP(250), false, true, false, 16)
                    self.x, self.y = x, y
                    task.New(self, function()
                        task.MoveTo(mx, my, 90, 2)
                        task.Wait(200)
                        object.ChangingV(self, 0, v, A, 80, false)
                    end)
                    task.New(self, function()
                        task.Wait(20)
                        local n = int(stage_lib.GetValue(5, 10, 15, 60))
                        local n1, ia1 = int(stage_lib.GetValue(3, 4, 4, 15)), 5
                        local n2, ia2 = 2, -15
                        local bv = stage_lib.GetValue(1.6, 2.3, 3.3, 10)
                        for u = 1, 90 do
                            for a in sp.math.AngleIterator(u * ia1 * d, n1) do
                                local l = 170 * (1 - u / 90)
                                for c in sp.math.AngleIterator(u * ia2 * d, n2) do
                                    Create.bullet_dec_acc(self.x + cos(a) * l, self.y + sin(a) * l, grain_a,
                                            4, 3, bv, a + c, false, false)
                                end
                            end
                            PlaySound("tan00")
                            task.Wait()
                        end
                        for _ = 1, 6 do
                            for a in sp.math.AngleIterator(Angle(self, player), n) do
                                Create.bullet_decel(self.x, self.y, ball_big, 6, 4, 2, a, false, false)
                            end
                            PlaySound("tan00")
                            task.Wait(15)
                        end
                        for u = 1, 720 do
                            for a in sp.math.AngleIterator(u * ia1 * d, n1 - 1) do
                                local l = 50 * sin(u * 3)
                                for c in sp.math.AngleIterator(u * ia2 * d, n2) do
                                    Create.bullet_dec_acc(self.x + cos(a) * l, self.y + sin(a) * l, grain_a,
                                            6, 3, bv, a + c, false, false)
                                end
                            end
                            PlaySound("tan00")
                            task.Wait(6)
                        end
                    end)
                end,
            }, true)

            task.Wait(50)
            for _ = 1, 2 do
                for d = -1, 1, 2 do
                    New(enemy2, -320 * d, 300, -100 * d, 100, 1, -90 + 85 * d, 1 * d)

                    task.Wait(250)

                end
                New(enemy1, 0, 300, 0, 150, 1)
                task.Wait(180)
            end
            task.Wait(50)
        end, _t("怎么这么难"))
lib.NewWaveEventInWaves(class, 27, { 5, 10 }, 1,
        0, 1, function(var)

            local bclass = boss.Define(name("Rumia"), -200, 400, _editor_class.ice_black_bg, "Rumia")

            local sc = boss.card.New("暗符「恐惧红丝」", 1, 4, 40, HP(950))
            boss.card.add(bclass, sc)
            function sc:before()
                task.MoveToForce(0, 120, 60, 2)
                Newcharge_in(self.x, self.y, 189, 252, 201)
                task.Wait(60)
            end
            function sc:other_drop()
                mission_lib.GoMission(90)
            end
            function sc:other_bonus_drop()
                item.dropItem(item.drop_card, 1, self.x, self.y + 30, 53)
            end
            function sc:init()
                task.New(self, function()

                    task.Wait(25)
                    task.New(self, function()
                        local d = 1
                        while true do
                            local A = ran:Float(0, 360)
                            for t = 1, 42 do
                                local l = task.SetMode[1](t / 42) * 450
                                for a in sp.math.AngleIterator(A, int(stage_lib.GetValue(15, 23, 32, 100))) do
                                    local x, y = self.x + cos(a) * l, self.y + sin(a) * l
                                    if Dist(x, y, player) > 32 then
                                        Create.bullet_accel(self.x + cos(a) * l, self.y + sin(a) * l, ball_mid,
                                                15, 0.7, (1 + t / 42 * 4) / stage_lib.GetValue(1, 1.3, 1.6, 6), a)
                                    end
                                end
                                PlaySound("tan00")
                                task.Wait(2)
                            end
                            task.New(self, function()
                                task.MoveToPlayer(60, -180, 180, 100, 160,
                                        80, 100, 25, 50, 2, 1)
                            end)
                            task.Wait(20)
                            for _ = 1, 15 do
                                for a in sp.math.AngleIterator(A, int(stage_lib.GetValue(10, 18, 26, 100))) do
                                    Create.bullet_changeangle(self.x, self.y, grain_b, 2, 3, a,
                                            { r = d * 2, time = 70 }, { v = 1.6, r = d * 0.5, time = 180 })
                                end
                                d = -d
                                PlaySound("kira00")
                                task.Wait(8)
                            end


                        end
                    end)


                end)
            end

            boss.Create(bclass)
        end, _t("黑手！"), nil, nil, true)
lib.NewWaveEventInWaves(class, 28, { 5, 10 }, 1,
        0, 1, function(var)

            local bclass = boss.Define(name("Wakasagihime"), 500, 200, _editor_class.ice_bg, "Wakasagihime")

            local non_sc = boss.card.New("", 1, 4, 40, HP(700))
            boss.card.add(bclass, non_sc)
            function non_sc:before()
                self._wisys:SetImageInList("Wakasagihime2")
                boss.show_aura(self, false)
                local spray = Class(bullet, {
                    init = function(self, x, y, v, a, time)
                        bullet.init(self, water_drop, 6, false, true)
                        self.x, self.y = x, y
                        object.SetV(self, v, a, true)
                        self.navi = true
                        self.ag = ran:Float(0.01, 0.03)
                        task.New(self, function()
                            local A = self.a
                            for i = 1, time do
                                i = 1 - sin(90 - i / time * 90)
                                self.hscale = 1 - i
                                self.vscale = self.hscale
                                self.a = A * self.hscale
                                self.b = self.a
                                task.Wait()
                            end
                            object.RawDel(self)
                        end)
                    end
                }, true)
                task.New(self, function()
                    task.Wait(100)
                    boss.show_aura(self, true)
                end)
                task.New(self, function()
                    for _ = 1, 160 do
                        self.rot = math.deg(math.atan2(self.dy, self.dx))
                        New(spray, self.x, self.y, ran:Float(1, 2), self.rot + ran:Float(-30, 30) + 180, ran:Int(50, 90))
                        task.Wait()
                    end
                end)
                task.BezierMoveTo(160, 2, -300, 150, -150, 80)
                local x, y
                for i = 6, 360, 6 do
                    x, y = self.x + cos(i) * 60, self.y + 60 + sin(i) * 20
                    New(spray, self.x, self.y, Dist(self.x, self.y, x, y) / 40, Angle(self.x, self.y, x, y), ran:Int(80, 140))
                    New(spray, self.x, self.y, ran:Float(1, 2), ran:Float(30, 150), ran:Int(80, 140))
                end
                PlaySound("water")
            end
            function non_sc:init()
                local b
                self.shoot = function(x, y, a, v, o, t)
                    return function()
                        for i = 1, t do
                            b = Create.bullet_dec_acc(x + cos(a) * 30, y + sin(a) * 30, arrow_big,
                                    i % 2 * 2 + 6, 4, v, a)
                            b.time1 = 60
                            b.time2 = 10
                            b.time3 = 80
                            PlaySound('tan00')
                            a = a + o / t
                            v = v + 0.05

                            task.Wait(6)
                        end
                    end
                end
                task.New(self, function()
                    self._wisys:SetImageInList("Wakasagihime")
                    self.hscale = 0
                    self.vscale = 0
                    self.rot = 90
                    for i = 1, 15 do
                        self.hscale = i / 15
                        self.vscale = i / 15
                        self.rot = 90 - 90 * sin(i * 6)
                        task.Wait()
                    end
                end)
                task.New(self, function()
                    Newcharge_in(self.x, self.y, 135, 206, 235)
                    task.Wait(60)
                    task.New(self, function()
                        local a = 180
                        while true do
                            task.New(self, self.shoot(self.x, self.y, a, stage_lib.GetValue(3.5, 4.5, 5, 18),
                                    sin(a * 0.6) * 40, int(stage_lib.GetValue(10, 15, 20, 75))))
                            a = a - 20
                            task.Wait(5)
                        end
                    end)
                    task.New(self, function()
                        while true do
                            task.Wait(stage_lib.GetValue(85, 60, 42, 10))
                            for a in sp.math.AngleIterator(Angle(self, player), 20) do
                                Create.bullet_accel(self.x, self.y, ball_big, 4,
                                        1, stage_lib.GetValue(2.7, 3.5, 4, 12), a, false, false)
                            end
                            PlaySound("kira00")
                        end
                    end)
                    while true do
                        task.BezierMoveTo(175, 3, 0, 300, -self.x, self.y)
                        task.Wait(180)
                    end
                end)
            end
            function non_sc:del()
            end
            local sc = boss.card.New("湖符「波撼长空」", 1, 5, 45, HP(1100))
            boss.card.add(bclass, sc)
            function sc:before()
                task.Wait(60)
            end
            function sc:init()
                task.New(self, function()
                    Newcharge_in(0, 0, 135, 206, 235)
                    task.MoveToForce(0, 0, 60, 2)
                    task.Wait(60)
                    boss.cast(self, 545454)
                    task.New(self, function()
                        local t = stage_lib.GetValue(18, 12, 7, 2)
                        local A = 0
                        while true do
                            task.New(self, function()
                                local _A = A
                                for i = 1, 50 do
                                    local k = 180 * i / 50
                                    for d = -1, 1, 2 do
                                        local ia = -90 + d * k
                                        local x, y = (60) / cos(ia), 60 * tan(ia)
                                        x, y = cos(_A) * x + sin(_A) * y, cos(_A) * y - sin(_A) * x
                                        for a in sp.math.AngleIterator(Angle(0, 0, x, y), 1) do
                                            Create.bullet_decel(self.x + x, self.y + y, ball_mid,
                                                    6, 1, 6, a, true, false)
                                        end
                                    end
                                    task.Wait()
                                end
                            end)
                            PlaySound("tan00")
                            task.Wait(t)
                            A = A + 6
                            t = max(6, t - 1)
                        end
                    end)
                    while true do
                        task.Wait(stage_lib.GetValue(180, 80, 40, 8))
                        Newcharge_in(self.x, self.y, 135, 206, 235)
                        task.Wait(60)
                        misc.ShakeScreen(25, 1.2, 1, 1.5, 1)
                        Newcharge_out(self.x, self.y, 135, 206, 235)
                        local rg = stage_lib.GetValue(1, 7, 13, 45)

                        object.BulletDo(function(b)
                            if not b.flag then
                                object.Del(b)
                                if ran:Int(1, 3) == 1 then
                                    local bk = Create.bullet_accel(b.x, b.y, arrow_big, 8, 0.5, stage_lib.GetValue(2.5, 3, 4.5, 12),
                                            Angle(self, player) + ran:Float(-rg, rg), false, false, 25)
                                    bk.flag = true
                                end
                            end
                        end)
                    end
                end)
            end
            function sc:other_drop()
                if ran:Float(0, 1) < 0.5 then
                    item.dropItem(item.drop_card, 1, self.x, self.y + 30, 124)
                end
                mission_lib.GoMission(43)
            end
            boss.Create(bclass)
        end, _t("鱼击长空"), nil, nil, true)
lib.NewWaveEventInWaves(class, 29, { 5, 10 }, 1,
        0, 1, function(var)
            local bclass = boss.Define(name("Wakasagihime"), -450, 50, _editor_class.ice_bg, "Wakasagihime2")
            local non_sc = boss.card.New("", 1, 4, 40, HP(720))
            boss.card.add(bclass, non_sc)
            function non_sc:before()
                task.Wait(60)
            end
            function non_sc:init()
                local spray = Class(bullet, {
                    init = function(self, x, y, v, a, time)
                        bullet.init(self, water_drop, 6, false, true)
                        self.x, self.y = x, y
                        object.SetV(self, v, a, true)
                        self.navi = true
                        self.ag = ran:Float(0.01, 0.03)
                        self._a = 150
                        self.colli = false
                        task.New(self, function()
                            local A = self.a
                            for i = 1, time do
                                i = 1 - sin(90 - i / time * 90)
                                self.hscale = 1 - i
                                self.vscale = self.hscale
                                self.a = A * self.hscale
                                self.b = self.a
                                task.Wait()
                            end
                            object.RawDel(self)
                        end)
                    end
                }, true)
                task.New(self, function()
                    while true do
                        if abs(self.dy) > 1 or abs(self.dx) > 1 then
                            New(spray, self.x, self.y, ran:Float(1, 2), self.rot + ran:Float(-30, 30) + 180, ran:Int(50, 90))
                        end
                        task.Wait()
                    end
                end)
                task.New(self, function()
                    self.navi = true
                    local d = 1
                    while true do
                        task.New(self, function()
                            for k = 1, 10 do
                                for a in sp.math.AngleIterator(Angle(self, player), int(stage_lib.GetValue(12, 20, 30, 100))) do
                                    Create.bullet_dec_acc(self.x, self.y, ellipse, 8,
                                            2.5, (3 - k / 10 * 2) + stage_lib.GetValue(0, 1, 2, 9), a)
                                    Create.bullet_accel(self.x, self.y, ellipse, 8,
                                            0.5, (5 - k / 10 * 3) + stage_lib.GetValue(0, 1, 2, 9), a)
                                end
                                PlaySound("tan00")
                                task.Wait(20)
                            end
                        end)
                        task.BezierMoveTo(200, 3, -100 * d, 250, 0 * d, 100, 100 * d, 20, 101 * d, 22)
                        task.New(self, function()
                            local t = int(stage_lib.GetValue(3, 5, 7, 27))
                            for k = 1, 60 do
                                local A = -90 - k / 60 * stage_lib.GetValue(45, 50, 68, 190) * d
                                for c = -t, t do
                                    Create.bullet_decel(self.x, self.y, arrow_big, 4, 4,
                                            2 + stage_lib.GetValue(0, 1, 2, 8), A + c * k / 60 * 720)
                                end
                                PlaySound("tan00")
                                task.Wait(2)
                            end
                        end)
                        task.BezierMoveTo(120, 1, 250 * d, 300, 450 * d, 50)
                        d = -d
                    end
                end)
            end
            function non_sc:other_drop()
                if ran:Float(0, 1) < 0.5 then
                    item.dropItem(item.drop_card, 1, self.x, self.y + 30, 124)
                end
                mission_lib.GoMission(43)
            end
            boss.Create(bclass)
        end, _t("舞幽壑之潜蛟"), nil, nil, true)
lib.NewWaveEventInWaves(class, 30, { 5, 10 }, 1,
        0, 1, function(var)
            local bclass = boss.Define(name("Rumia"), 0, 400, _editor_class.ice_black_bg, "Rumia")
            local non_sc = boss.card.New("", 1, 4, 40, HP(895))
            boss.card.add(bclass, non_sc)
            function non_sc:before()
                task.MoveToForce(0, 120, 60, 2)
            end
            function non_sc:init()
                task.New(self, function()
                    local d = 1
                    while true do
                        Newcharge_in(self.x, self.y, 250, 128, 114)
                        task.Wait(60)
                        task.New(self, function()
                            task.MoveTo(120 * d, 140, 90, 3)
                            task.MoveTo(0, 120, 90, 3)
                        end)
                        for i = 1, 15 do
                            local r = 700 - i * 30
                            for a in sp.math.AngleIterator(i * 15 * d, int(stage_lib.GetValue(15, 18, 25, 90))) do
                                local _x, _y = 0 + cos(a) * r, -700 + sin(a) * r
                                local v = Dist(self, _x, _y) / (300 + i * 10 + 25 - stage_lib.GetValue(0, 35, 70, 315))
                                local A = Angle(self, _x, _y)
                                NewSimpleBullet(ball_small, 2, self.x, self.y, v, A)
                            end
                            local t = int(stage_lib.GetValue(6, 8, 10, 36))
                            for c = -t, t do
                                Create.bullet_dec_acc(self.x, self.y, ball_huge, 6, 9,
                                        3 + min(var.chaos / 100, 6), 90 + c * i / 15 * 25, true, false)
                            end
                            PlaySound("tan00")
                            task.Wait(10)
                        end
                        task.Wait(stage_lib.GetValue(150, 125, 100, 25))
                        d = -d
                    end
                end)
            end
            function non_sc:other_drop()
                mission_lib.GoMission(90)
            end
            boss.Create(bclass)
        end, _t("正中下怀"), nil, nil, true)
lib.NewWaveEventInWaves(class, 31, { 11, 12, 13, 14 }, 1,
        0, 1, function(var)

            local stg = stage.current_stage
            local enemy1 = Class(enemy, {
                init = function(self, x, y, vx1, vy1)
                    enemy.init(self, 32, HP(6), false, true, false, 0.5)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx1, vy1
                    task.New(self, function()
                        if var.chaos >= 50 then
                            task.Wait(ran:Int(35, 125))
                            for _ = 1, stage_lib.GetValue(5, 8, 13, 60) do
                                Create.bullet_accel(self.x, self.y, ball_mid, 6, 0.3, stage_lib.GetValue(2, 3, 4, 15), ran:Float(0, 360))
                                PlaySound("tan00")
                                task.Wait(stage_lib.GetValue(40, 30, 25, 8))
                            end
                        end
                    end)
                    task.New(self, function()
                        task.Wait(200)
                        for i = 1, 36 do
                            self.vx = vx1 + vx1 * (i / 36)
                            self.vy = vy1 + vy1 * (i / 36)
                            task.Wait()
                        end
                        task.Wait(200)
                        Del(self)
                    end)
                end,
            }, true)
            local enemy2 = Class(enemy, {
                drop = function(self)
                    New(bullet_cleaner, self.x, self.y, 100, 10, 10, true, false, 0)
                end,
                init = function(self, x, y, vx, vy)
                    enemy.init(self, 26, HP(30), false, true, false, 2)
                    self.x, self.y = x, y
                    self.colli = false
                    task.New(self, function()
                        self.hscale, self.vscale = 0, 0
                        self._r, self._g, self._b = 120, 120, 120
                        for i = 1, 30 do
                            self.vy = 1 - task.SetMode[1](i / 30)
                            self.hscale = i / 30
                            self.vscale = self.hscale
                            task.Wait()
                        end
                        self._r, self._g, self._b = 255, 255, 255
                        self.colli = true
                        for a in sp.math.AngleIterator(ran:Float(0, 360), int(stage_lib.GetValue(20, 32, 40, 100))) do
                            Create.bullet_decel(self.x, self.y, water_drop, 4,
                                    4, stage_lib.GetValue(2, 1.6, 1.2, 1), a, true, false)
                        end
                        PlaySound("tan00")
                        task.Wait(20)
                        for i = 1, 60 do
                            self.vx, self.vy = i / 60 * vx, i / 60 * vy
                            task.Wait()
                        end
                    end)
                end,
            }, true)
            task.New(stg, function()
                local n = int((stage_lib.GetValue(5, 10, 18, 30)) - 1) / 2
                for _ = 1, 7 do
                    for z = -n, n do
                        New(enemy1, z * 300 / n, 300, ran:Float(-0.1, 0.1), -1)
                    end
                    task.Wait(100)
                end
            end)

            for _ = 1, 6 do
                local x, y = ran:Float(-270, 270), ran:Float(0, 100)
                for a in sp.math.AngleIterator(ran:Float(0, 360), 8) do
                    New(enemy2, x + cos(a) * 80, y + sin(a) * 80, ran:Sign() * 2, 0, 1)
                    task.Wait(7)
                end
                task.Wait(90)
            end
            task.Wait(30)

            task.Wait(30)
        end, _t("水波正兴"))
lib.NewWaveEventInWaves(class, 32, { 15 }, 1,
        0, 1, function(var)
            lstg.tmpvar.MedicineNomiss = lstg.var.miss
            local bclass = boss.Define(name("Medicine"), 0, 400, _editor_class.medicine_bg, "Medicine")

            local non_sc1 = boss.card.New("", 1, 4, 40, HP(1100))
            boss.card.add(bclass, non_sc1)
            function non_sc1:before()
                lstg.tmpvar.otherMusic = "1_boss1"
                lstg.tmpvar.otherMusic_start_time = 37
                boss.show_aura(self, false)
                PlaySound("ch02")
                New(boss_cast_darkball, 0, 120, 60, 80, 360, 1, 270, 64, 64, 255, 2)
                New(boss_cast_darkball, 0, 120, 60, 80, 360, 1, 270, 255, 64, 64, -2)
                task.Wait(80)
                self.x, self.y = 0, 120
                boss.show_aura(self, true)
                Newcharge_in(self.x, self.y, 250, 128, 114)
                task.Wait(60)
            end
            function non_sc1:init()
                task.New(self, function()
                    local d = 1
                    while true do
                        for t = 1, 4 do
                            servant.init(NewObject(servant), self.x, self.y, 0, 218, 112, 214, 1.5, function(unit)
                                task.New(unit, function()
                                    unit:FadeIn(15)
                                    object.ChangingSizeColli(unit, -0.5, -0.5, 15)
                                end)
                                task.New(unit, function()
                                    local k = d * (t % 2 * 2 - 1)
                                    local x, y = ran:Float(100, 200) * -k, ran:Float(-20, -80)
                                    task.MoveToEx(x, y, 60 + t * t * 10, 2)
                                    for a in sp.math.AngleIterator(-90, 8) do
                                        for v = 0, stage_lib.GetValue(2, 3, 5, 15) do
                                            Create.bullet_accel(unit.x, unit.y, ball_big, 4, 1, 1 + v / 7 * 8, a)
                                        end
                                    end
                                    PlaySound("kira00")
                                    unit.ax = k * stage_lib.GetValue(0.1, 0.06, 0.03, 0.01)
                                    task.Wait(25)
                                    for _ = 1, int(stage_lib.GetValue(20, 35, 46, 120)) do
                                        Create.bullet_dec_acc(unit.x, unit.y, arrow_big, 6, 3, 4, -90 + ran:Float(-1, 1))
                                        PlaySound("tan00")
                                        task.Wait(stage_lib.GetValue(7, 6, 5, 1))
                                    end
                                    object.ChangingSizeColli(unit, -1, -1, 15)
                                    Del(unit)


                                end)
                            end)

                        end
                        for _ = 1, 2 do
                            task.Wait(stage_lib.GetValue(80, 43, 28, 5))
                            task.MoveToPlayer(60, -150, 150, 100, 144,
                                    30, 45, 12, 24, 2, 1)
                        end
                        for a in sp.math.AngleIterator(ran:Float(0, 360), int(stage_lib.GetValue(20, 32, 42, 120))) do
                            for v = 0, (var.chaos >= 50) and 1 or 0 do
                                NewSimpleBullet(ball_light, 2, self.x, self.y,
                                        (2 + v) * stage_lib.GetValue(0.6, 0.9, 1.3, 3), a)
                            end
                        end
                        PlaySound("tan00")
                        d = -d
                    end
                end)
            end

            local sc1 = boss.card.New("幻觉「三叶草降临」", 2, 10, 40, HP(1200))
            boss.card.add(bclass, sc1)
            function sc1:before()
                task.Wait(60)
            end
            function sc1:init()
                local clover_obj = Class(bullet, {
                    init = function(self, x, y, a, o, vx, vy)
                        bullet.init(self, heart, 10, false, true)
                        self.mx, self.my = x, y
                        self.rot = a
                        self.x, self.y = self.mx + cos(self.rot + 180) * 8, self.my + sin(self.rot + 180) * 8
                        self.omega = o
                        self.mvx, self.mvy = vx, vy
                        self.max, self.may = 0, 0
                        self.mmaxvx, self.mmaxvy = 1e100, 1e100

                        if Dist(player, self) < 40 then
                            Del(self)
                        end
                    end,
                    frame = function(self)
                        bullet.frame(self)
                        object.SetSizeColli(self, 0.7, 0.6)
                        object.SetColli(self, 3)
                        self.x, self.y = self.mx + cos(self.rot + 180) * 8, self.my + sin(self.rot + 180) * 8
                        self.mx, self.my = self.mx + self.mvx, self.my + self.mvy
                        self.mvx, self.mvy = self.mvx + self.max, self.mvy + self.may
                        if abs(self.mvx) >= self.mmaxvx then
                            self.mvx = sign(self.mvx) * self.mmaxvx
                        end
                        if abs(self.mvy) >= self.mmaxvy then
                            self.mvy = sign(self.mvy) * self.mmaxvy
                        end
                    end
                }, true)
                local function new_clover(x, y, fa, fo, v, a, func)
                    local b
                    for i = 1, 3 do
                        b = New(clover_obj, x, y, fa + i * 120, fo, v * cos(a), v * sin(a))
                        if func then
                            func(b)
                        end
                    end
                end
                local clover = function(x, y, t, num)
                    local rot = ran:Float(0, 360)
                    local omega = ran:Sign()
                    new_clover(x, y, rot, omega, 0, 0, function(self)
                        self.may = -0.01
                        task.New(self, function()
                            for i = 1, t do
                                self._a = 255 - 100 * i / t
                                task.Wait()
                            end
                            Del(self)
                        end)
                    end)
                    new_clover(x, y, rot, omega, 0, 0, function(self)
                        self._a = 0
                        self.colli = false
                        task.New(self, function()
                            for i = 1, t do
                                self._a = 150 * i / t
                                task.Wait()
                            end
                            self._a = 255
                            bullet.ChangeImage(self, self.imgclass, 2)
                            Create.bullet_create_eff(self)
                            self.colli = true
                            task.Wait(60 + num)
                            local A = Angle(self.mx, self.my, player)
                            self.max = cos(A) * 0.03
                            self.may = sin(A) * 0.03
                        end)
                    end)
                end
                task.New(self, function()
                    Newcharge_in(0, 100, 135, 206, 235)
                    task.MoveToForce(0, 100, 60, 2)
                    while true do
                        Newcharge_in(self.x, self.y, 135, 206, 235)
                        task.Wait(60)
                        for a in sp.math.AngleIterator(Angle(self, player), int(stage_lib.GetValue(20, 32, 42, 150))) do
                            for v = 0, (var.chaos >= 50) and 1 or 0 do
                                NewSimpleBullet(ball_big, 2, self.x, self.y,
                                        (2 + v) * stage_lib.GetValue(0.6, 0.9, 1.3, 4), a)
                            end
                        end
                        PlaySound("tan00")
                        NewPulseScreen(0, nil, "mul+add", 0, 0, 25)
                        misc.ShakeScreen(35, 1.5, 1, 1.5, 1)
                        local wt = int(stage_lib.GetValue(240, 220, 200, 60))
                        local px, py = player.x, player.y
                        for k = 30, 1, -1 do
                            local R = k * 17
                            for a in sp.math.AngleIterator(ran:Float(0, 360), math.ceil(k * stage_lib.GetValue(0.3, 0.4, 0.5, 1.8))) do
                                clover(px + cos(a) * R, py + sin(a) * R, wt - (30 - k) * 2, k)
                            end
                            PlaySound("tan00")
                            task.Wait(2)
                        end
                        task.Wait(wt - 120)
                        Newcharge_in(self.x, self.y, 189, 252, 201)
                        task.Wait(60)
                        Newcharge_out(self.x, self.y, 250, 128, 114)
                        NewPulseScreen(0, nil, "mul+add", 0, 0, 25)
                        misc.ShakeScreen(35, 1.5, 1, 1.5, 1)
                        task.MoveToPlayer(60, -150, 150, 100, 144,
                                30, 45, 12, 24, 2, 1)
                        task.Wait(stage_lib.GetValue(110, 85, 67, 15))

                    end
                end)
            end

            local non_sc2 = boss.card.New("", 2, 6, 40, HP(1100))
            boss.card.add(bclass, non_sc2)
            function non_sc2:before()
                task.MoveToForce(0, 120, 60, 2)
            end
            function non_sc2:init()
                task.New(self, function()
                    Newcharge_in(self.x, self.y, 200, 100, 100)
                    task.Wait(60)
                    local d = 1
                    while true do
                        for t = 1, 4 do
                            servant.init(NewObject(servant), self.x, self.y, 0, 189, 252, 201, 1.5, function(unit)
                                task.New(unit, function()
                                    unit:FadeIn(15)
                                    object.ChangingSizeColli(unit, -0.5, -0.5, 15)
                                end)
                                task.New(unit, function()
                                    local k = d * (t % 2 * 2 - 1)
                                    local x, y = ran:Float(100, 200) * -k, ran:Float(-20, -80)
                                    task.MoveToEx(x, y, 46 + t * t * 8, 2)
                                    local cp = int(stage_lib.GetValue(3, 5, 7, 20))
                                    for c = 1, cp do
                                        for a in sp.math.AngleIterator(Angle(unit, player), int((30 - c * 2) * min(var.chaos / 200 + 0.5, 2.5))) do
                                            NewSimpleBullet(arrow_big, 10, unit.x, unit.y,
                                                    (max(0.5, 2.5 - var.chaos / 220) + c / cp * 1.5) * min(var.chaos / 500 + 0.8), a)
                                        end
                                    end
                                    PlaySound("kira00")
                                    unit.ag = stage_lib.GetValue(0.1, 0.06, 0.04, 0.01)
                                    task.Wait(25)
                                    for _ = 1, int(stage_lib.GetValue(20, 36, 50, 125)) do
                                        Create.bullet_dec_acc(unit.x, unit.y, ball_mid, 6,
                                                3, 4, 90 - k * 90 + ran:Float(-1, 1))
                                        PlaySound("tan00")
                                        task.Wait(stage_lib.GetValue(7, 5, 4, 1.3))
                                    end
                                    object.ChangingSizeColli(unit, -1, -1, 15)
                                    Del(unit)


                                end)
                            end)

                        end
                        for _ = 1, 2 do
                            task.Wait(stage_lib.GetValue(90, 70, 48, 10))
                            task.MoveToPlayer(60, -150, 150, 100, 144,
                                    30, 45, 12, 24, 2, 1)
                        end
                        d = -d
                    end
                end)
            end

            local sc2 = boss.card.New("恶符「强渡三毒川」", 2, 10, 40, HP(1200))
            boss.card.add(bclass, sc2)
            function sc2:before()
                task.Wait(60)
            end
            function sc2:frame()
                player._poison_slowed = nil
            end
            function sc2:init()
                local poison = Class(object, {
                    init = function(self, _x, _y, time, K)
                        self.x, self.y = _x, _y
                        self.layer = LAYER.TOP
                        self.group = GROUP.INDES
                        self.imgx, self.imgy = ran:Float(-256, 256), ran:Float(-256, 256)
                        self.imgvx, self.imgvy = ran:Float(-2, 2), ran:Float(-2, 2)
                        self.colli = false
                        self._blend, self._a, self._r, self._g, self._b = '', 0, 255, 255, 255
                        self.omega = ran:Sign() * ran:Float(0.5, 1)
                        self.rot = ran:Float(0, 360)
                        self.K = K
                        task.New(self, function()
                            for i = 1, 30 do
                                self._a = i / 30 * 255
                                task.Wait()
                            end
                            task.Wait(time - 30)
                            for i = 1, 30 do
                                self._a = 255 - i / 30 * 255
                                task.Wait()
                            end
                            Del(self)
                        end)
                    end,
                    frame = function(self)
                        task.Do(self)
                        self.imgx = self.imgx + self.imgvx
                        self.imgy = self.imgy + self.imgvy
                        local R = 90
                        local p = player
                        if Dist(p, self) < R and not p._poison_slowed then
                            sp:UnitSetVIndex(p, -0.55 * self.K)
                            p._poison_slowed = true
                        end
                    end,
                    render = function(self)
                        local color1 = Color(self._a * self.K, self._r, self._g, self._b)
                        local color2 = Color(0, self._r, self._g, self._b)
                        local point = 32
                        local r = 100
                        local b = {}
                        local ang = 360 / (2 * point)
                        for angle = 360 / point, 360, 360 / point do
                            b = { cos(angle + ang), sin(angle + ang), cos(angle - ang), sin(angle - ang) }
                            RenderTexture("Poison", "",
                                    { self.x + r * b[1], self.y + r * b[2], 0.5, self.imgx + r * b[1], self.imgy + r * b[2], color2 },
                                    { self.x + r * b[3], self.y + r * b[4], 0.5, self.imgx + r * b[3], self.imgy + r * b[4], color2 },
                                    { self.x, self.y, 0.5, self.imgx, self.imgy, color1 },
                                    { self.x, self.y, 0.5, self.imgx, self.imgy, color1 })
                        end
                    end
                }, true)
                task.New(self, function()
                    Newcharge_in(0, 100, 135, 206, 235)
                    task.MoveToForce(0, 100, 60, 2)
                    local j = 1
                    while true do
                        Newcharge_in(self.x, self.y, 135, 206, 235)
                        task.Wait(60)
                        local px = player.x
                        local D = stage_lib.GetValue(80, 90, 100, 122)
                        task.New(self, function()
                            PlaySound("boon00")
                            local r = ran:Float(0, 360)
                            for t = 1, 10 do
                                t = t / 10
                                local x = px + sin(r + t * 360) * 20
                                local y = 240 - t * 480
                                for d = -1, 1, 2 do
                                    New(poison, x + d * D, y, 180, 1)
                                end
                                New(poison, x, y, 180, 0.3)
                                task.Wait(2)
                            end
                        end)
                        if j == 1 then
                            task.Wait(35)
                        end
                        task.MoveTo(px, self.y, 20, 2)
                        Newcharge_out(self.x, self.y, 218, 112, 214)
                        local sty = { ball_huge, ball_mid, ball_small, ball_big }
                        for c = 1, 120 do
                            local f = min(c / 20, 1)
                            local g = task.SetMode[1](c / stage_lib.GetValue(150, 140, 120, 120))
                            for _ = 1, math.ceil(c * stage_lib.GetValue(0.02, 0.04, 0.06, 0.1)) do
                                Create.bullet_decel(px + ran:Float(-f, f) * D, 240, sty[ran:Int(1, 4)],
                                        4, 15, ran:Float(-1, 1) + 13 - g * 11,
                                        -90 + ran:Float(-g, g) * 90, true, false)
                            end
                            PlaySound("tan00")
                            task.Wait()
                        end
                        task.New(self, function()
                            for _ = 1, 3 do
                                task.MoveToPlayer(60, -150, 150, 100, 144,
                                        30, 45, 12, 24, 2, 1)
                            end
                        end)
                        task.Wait(35)
                        for _ = 1, 6 do
                            for a in sp.math.AngleIterator(ran:Float(0, 360), int(stage_lib.GetValue(20, 25, 36, 85))) do
                                for v = 0, (var.chaos >= 50) and 1 or 0 do
                                    local b = NewSimpleBullet(ellipse, 2, self.x, self.y,
                                            (2 + v) * min(var.chaos / 100 * 0.4 + 0.6, 3), a)
                                    b._blend = "mul+add"
                                end
                            end
                            PlaySound("tan00")
                            task.Wait(stage_lib.GetValue(34, 28, 20, 6))
                        end
                        task.Wait(35)
                        j = j + 1
                    end
                end)
            end

            local non_sc3 = boss.card.New("", 2, 6, 40, HP(1100))
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
                        for t = 1, 4 do
                            servant.init(NewObject(servant), self.x, self.y, 0, 135, 206, 235, 1.5, function(unit)
                                task.New(unit, function()
                                    unit:FadeIn(15)
                                    object.ChangingSizeColli(unit, -0.5, -0.5, 15)
                                end)
                                task.New(unit, function()
                                    local k = d * (t % 2 * 2 - 1)
                                    local x, y = ran:Float(125, 150) * -k, ran:Float(-60, -80)
                                    task.MoveToEx(x, y, 46 + t * t * 10, 2)
                                    PlaySound("kira00")
                                    unit.ax = k * stage_lib.GetValue(0.1, 0.07, 0.04, 0.01) * 1.25
                                    unit.ag = stage_lib.GetValue(0.1, 0.07, 0.04, 0.01)
                                    task.Wait(25)
                                    task.New(unit, function()
                                        while unit.y >= -240 do
                                            task.Wait()
                                        end
                                        for a in sp.math.AngleIterator(ran:Float(0, 360), int(stage_lib.GetValue(20, 30, 40, 120))) do
                                            for v = 0, (var.chaos >= 50) and 1 or 0 do
                                                Create.bullet_accel(unit.x, -240, ball_mid, 8,
                                                        0.2 + v * 0.2, (1.5 + v) * stage_lib.GetValue(0.6, 1.2, 1.8, 6), a)
                                            end
                                        end
                                        PlaySound("tan00")
                                    end)
                                    for c = 1, int(stage_lib.GetValue(20, 35, 50, 100)) do
                                        for p = -1, 1, 2 do
                                            Create.bullet_changeangle(unit.x, unit.y, grain_a, 6,
                                                    3, -90 - p * c * 2, false,
                                                    { r = 3 * p, time = 60, v = 1 })
                                        end
                                        PlaySound("tan00")
                                        task.Wait(stage_lib.GetValue(7, 5, 4, 1))
                                    end
                                    object.ChangingSizeColli(unit, -1, -1, 15)
                                    Del(unit)


                                end)
                            end)

                        end
                        for _ = 1, 2 do
                            task.Wait(stage_lib.GetValue(100, 70, 40, 5))
                            task.MoveToPlayer(60, -150, 150, 100, 144,
                                    30, 45, 12, 24, 2, 1)
                        end
                        for a in sp.math.AngleIterator(ran:Float(0, 360), int(stage_lib.GetValue(20, 25, 35, 80))) do
                            for v = 0, (var.chaos >= 50) and 1 or 0 do
                                NewSimpleBullet(ball_light, 10, self.x, self.y, (2 + v) * stage_lib.GetValue(0.6, 1.2, 1.8, 6), a)
                            end
                        end
                        PlaySound("tan00")
                        task.Wait(60)
                        d = -d
                    end
                end)
            end
            local sc3 = boss.card.New("谵妄「动荡的剧毒摇篮」", 2, 10, 45, HP(3500))
            boss.card.add(bclass, sc3)
            function sc3:before()
                task.Wait(60)
                task.MoveToForce(0, 120, 60, 2)
            end
            function sc3:init()
                task.New(self, function()
                    Newcharge_in(self.x, self.y, 218, 114, 214)
                    task.Wait(60)
                    local barrier = function(x, y, v, a, getvfunc, pro)
                        local self = NewObject(Class(bullet, {
                            frame = function(self)
                                bullet.frame(self)
                                if not self.jump then
                                    object.SetV(self, getvfunc(), a)
                                end
                            end
                        }, true))
                        bullet.init(self, ball_mid, 10, false, true)
                        self.fogtime = 0
                        self.x, self.y = x, y
                        object.SetV(self, v, a)
                        task.New(self, function()
                            if pro then
                                local ty = ran:Float(-240, 240)
                                while self.y >= ty or Dist(self, player) < 64 do
                                    task.Wait()
                                end
                                PlaySound("kira00")
                                self.jump = true
                                sakura_big.New(self.x, self.y, ran:Float(0, 360), 0, 0, 0, function(unit)
                                    task.New(unit, function()
                                        task.Wait(60)
                                        local chaos = lstg.var.chaos
                                        local _a = unit.rot
                                        local _v = stage_lib.GetValue(1.5, 2, 2.5, 12)
                                        unit.max = cos(_a) * _v / 200
                                        unit.may = sin(_a) * _v / 200
                                        unit.mmaxvx = abs(cos(_a) * _v)
                                        unit.mmaxvy = abs(sin(_a) * _v)
                                    end)
                                end)
                                Del(self)
                            end
                        end)
                        return self
                    end
                    task.New(self, function()
                        local w = {}
                        task.init_left_wait(w)
                        local c = var.chaos
                        PlaySound("boon00")
                        local points = {}
                        local k = 6
                        for i = 1, k do
                            points[i] = {}
                            New(_editor_class.PointRender, points[i], 40 * 60, 60, 189, 252, 201, true)
                        end
                        while true do
                            local ipro = stage_lib.GetValue(0.01, 0.03, 0.08, 0.3)
                            local v = 3.6 + c * 0.03
                            local interval = 1 + 25 / (c * 0.1 + 0.9)
                            local j = 1
                            local t = (k - 1) / 2
                            local left_time = 44 * 60 - self.timer
                            for z = -t, t do
                                local x = sin(c * (1 + 0.00036 * c)) * 150 + z * 150
                                local bu = barrier(x, 264 + w.task_left_wait * v, v, -90, function()
                                    return v
                                end, ran:Float(0, 1) < ipro + (1 - ipro) / max(1, left_time * 0.1 - 1))
                                table.insert(points[j], bu)
                                j = j + 1
                            end
                            task.Wait2(w, interval)
                            c = c + 1

                        end
                    end)
                    task.Wait(9 * 60)
                    Newcharge_in(self.x, self.y, 218, 114, 214)
                    task.Wait(60)
                    task.New(self, function()
                        local g = stage_lib.GetValue(0.4, 0.42, 0.46, 1.5)
                        local v = stage_lib.GetValue(1, 1.6, 2, 9)
                        while true do
                            for a in sp.math.AngleIterator(ran:Float(0, 360), int(stage_lib.GetValue(9, 10, 12, 45))) do
                                for d = -1, 1, 2 do
                                    local b = Create.bullet_changeangle(self.x, self.y, ball_huge, 6, v, a,
                                            { r = d * g, time = 180, v = v + 2 })
                                    b.stay = false
                                    b._flag = true
                                end
                            end
                            PlaySound("tan00")
                            task.Wait(80)
                        end
                    end)
                    local c = 1
                    task.New(self, function()
                        while true do
                            local A = Angle(self, player)
                            local V = stage_lib.GetValue(0.7, 0.8, 0.9, 2)
                            object.BulletDo(function(b)
                                if b._flag then
                                    b.x = b.x + cos(A) * V
                                    b.y = b.y + sin(A) * V
                                end
                            end)
                            task.Wait()
                        end
                    end)
                end)
            end
            function sc3:del()
                if var.wave ~= var.maxwave then
                    lstg.tmpvar.otherMusic = nil
                end
            end
            function sc3:other_drop()
                mission_lib.GoMission(48)
                if var.wave ~= var.maxwave then
                    item.dropItem(item.drop_card, 1, self.x, self.y + 30, 90)
                end
            end
            boss.Create(bclass)
        end, _t("通往地狱的毒药"), nil, true, true)
lib.NewWaveEventInWaves(class, 33, { 5, 10 }, 1,
        0, 1, function(var)
            local bclass = boss.Define(name("Kogasa"), 0, 400, _editor_class.kogasa_bg, "Kogasa")
            local sc = boss.card.New("恐吓「缝里插针」", 1, 5, 40, HP(1100))
            boss.card.add(bclass, sc)
            function sc:before()
                task.MoveToForce(0, 135, 60, 2)
            end
            function sc:init()
                task.New(self, function()
                    while true do
                        Newcharge_in(self.x, self.y, 250, 128, 114)
                        task.Wait(60)
                        boss.cast(self, 240)
                        local L = int(stage_lib.GetValue(9, 25, 55, 200))
                        local v = 7
                        local bv = stage_lib.GetValue(3, 2, 2, 0.3)
                        local A = ran:Float(0, 360)
                        local c = 240 / L + 0.2
                        local n = int(stage_lib.GetValue(8, 16, 20, 72))
                        local nkindex = 1.5
                        for l = 1, L do
                            for a in sp.math.AngleIterator(A, 14) do
                                for j = -1, 1, 2 do
                                    Create.bullet_accel(self.x + cos(a) * sin(l * c) * 150, self.y + sin(a) * sin(l * c) * 150,
                                            water_drop, 6, 0.5, v, a + j * 360 / n * nkindex)
                                    if l % int(L / 11) == 0 then
                                        Create.bullet_accel(self.x + cos(a) * sin(l * c) * 150, self.y + sin(a) * sin(l * c) * 150,
                                                ball_mid, 8, 0, bv, a + j * 360 / n * nkindex, true, false)
                                    end
                                end

                            end
                            PlaySound("tan00")
                            task.Wait(240 / L)
                        end
                        task.Wait(stage_lib.GetValue(60, 50, 45, 12))
                        task.MoveToPlayer(30, -200, 200, 125, 145,
                                40, 60, 8, 10, 2, 1)
                    end
                end)
            end
            function sc:other_drop()
                if ran:Float(0, 1) < 0.5 then
                    item.dropItem(item.drop_card, 1, self.x, self.y + 30, 159)
                end
                mission_lib.GoMission(53)
            end
            boss.Create(bclass)
        end, _t("鬼打墙"), nil, nil, true)
lib.NewWaveEventInWaves(class, 34, { 15 }, 2,
        0, 1, function(var)
            lstg.tmpvar.YukariNomiss = lstg.var.miss
            local bclass = boss.Define(name("Yukari"), 0, 400, _editor_class.yukari_bg, "Yukari")

            local sc1 = boss.card.New("结界「信手拈来之物」", 2, 7, 40, HP(1500))
            boss.card.add(bclass, sc1)
            function sc1:before()
                lstg.tmpvar.otherMusic = "1_boss2"
                lstg.tmpvar.otherMusic_start_time = 47.33 - 140 / 60
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
            function sc1:init()
                task.New(self, function()
                    Newcharge_in(self.x, self.y, 250, 128, 114)
                    task.Wait(60)
                    task.New(self, function()
                        local i = int(stage_lib.GetValue(0, 4, 9, 36))
                        local ad = 0
                        while true do
                            for a, j in sp.math.AngleIterator(i, stage_lib.GetValue(22, 26, 32, 120)) do
                                local b = Create.bullet_dec_acc(self.x, self.y, ball_big, 6 + j % 2 * 2,
                                        stage_lib.GetValue(4, 5, 6, 7),
                                        stage_lib.GetValue(3, 4, 5, 6), a)

                                b.time2 = int(stage_lib.GetValue(60, 40, 30, 20))
                                b.time3 = int(stage_lib.GetValue(120, 90, 75, 60))
                                b.navi = true
                                object.ChangeSizeColliWithTask(b, -0.4, -0.65, 150, 4, 25)
                                b.D = i % 2 * 2 - 1
                                function b:frame_new()
                                    bullet.frame(self)
                                    if not self._frozen then
                                        self.x = self.x + cos(i) * ad * self.D
                                        self.y = self.y + sin(i) * ad * self.D
                                    end
                                end
                            end
                            PlaySound("tan00")
                            ad = 2 - 120 / (i + 60)
                            task.Wait(max(40 - i * 2, stage_lib.GetValue(9, 8, 7, 2)))
                            i = i + 1
                        end
                    end)

                    task.Wait(stage_lib.GetValue(250, 200, 150, 30))
                    Newcharge_in(self.x, self.y, 255, 255, 255)
                    task.Wait(60)
                    while true do
                        PlaySound("boon01", 1)
                        boss.cast(self, 300)
                        local kR = Dist(self, player)
                        for i = 1, 5 do
                            local R = kR / 4 * i
                            local r = i / 5 * 35
                            NewWave2(self.x, self.y, 3, R - r, R + r, 60, 250, 128, 114, 3, 2)
                            NewWave2(self.x, self.y, 3, R + r, R - r, 60, 250, 128, 114, 3, 2)
                        end
                        task.Wait(60)
                        Newcharge_out(self.x, self.y, 250, 128, 114)
                        local x, y = self.x, self.y
                        task.New(self, function()
                            task.Wait(stage_lib.GetValue(90, 65, 35, 0))
                            task.MoveToPlayer(60, -200, 200, 100, 160,
                                    40, 50, 20, 30, 2, 1)
                        end)
                        task.New(self, function()
                            for A = 1, 150 do
                                for d = -3, 3 do
                                    local b = NewSimpleBullet(ball_light, 2, self.x, self.y, 0, 0)
                                    bullet.SetLayer(b, LAYER.ENEMY_BULLET + 1)
                                    b.group = GROUP.INDES
                                    task.New(b, function()
                                        for i = 1, 5 do

                                            local R = kR / 4 * i
                                            local r = i / 5 * 35
                                            local angle = 90 + task.SetMode[3](A / 150) * ((180 - abs(d) * 20) + i * 15) * d
                                            b.x, b.y = x + cos(angle) * R, y + sin(angle) * R
                                            object.SetSizeColli(b, r / 14)
                                            object.BulletDo(function(o)
                                                if Dist(b, o) < r then
                                                    object.Del(o)
                                                end
                                            end)
                                            if A == 150 then
                                                NewBon(b.x, b.y, 60, 100, 250, 128, 114)
                                            end
                                            task.Wait()
                                        end
                                        b.vx, b.vy = b.dx, b.dy
                                    end)
                                end
                                PlaySound("tan01")
                                task.Wait()
                            end
                        end)
                        task.Wait(stage_lib.GetValue(90, 65, 35, 0) + 60)
                        task.Wait(5)
                    end
                end)
            end
            local non_sc1 = boss.card.New("", 2, 6, 40, HP(1150))
            boss.card.add(bclass, non_sc1)
            function non_sc1:before()
                task.MoveToForce(0, 120, 60, 2)
            end
            function non_sc1:init()
                task.New(self, function()
                    local shoot_laser = Class(laser, {
                        init = function(self, master, col, w, time, life)
                            laser.init(self, col, master.x, master.y, master.angle, 0, 0, 0, w, w, 0)
                            laser._TurnHalfOn(self, 0, false)
                            self.line = 0
                            self.Isradial = true
                            local n1, n2 = life * 0.6, life * 0.4
                            local KL = 800 / life
                            self.radial_v = KL
                            task.New(self, function()
                                while IsValid(master) do
                                    self.x, self.y = master.x, master.y
                                    self.rot = master.angle
                                    task.Wait()
                                end
                            end)
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
                                    for _ = 1, n1 do
                                        self.l3 = self.l3 + KL
                                        task.Wait()
                                    end
                                    for _ = 1, n2 do
                                        self.l1 = self.l1 + KL
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
                    Newcharge_in(self.x, self.y, 200, 100, 100)
                    task.Wait(60)
                    local d = 1
                    task.New(self, function()
                        while true do
                            local tR = 160
                            for a in sp.math.AngleIterator(0, 12) do
                                servant.init(NewObject(servant), self.x, self.y, 0, 135, 206, 235, 1.5, function(unit)
                                    unit.bound = true
                                    task.New(unit, function()
                                        unit:FadeIn(15)
                                        object.ChangingSizeColli(unit, -0.5, -0.5, 15)
                                    end)
                                    local cx, cy = self.x, self.y
                                    local R = 0
                                    local o = 0.6 * d
                                    unit.angle = a
                                    task.New(unit, function()
                                        while true do
                                            unit.x = cx + cos(unit.angle) * R
                                            unit.y = cy + sin(unit.angle) * R
                                            unit.angle = unit.angle + o
                                            task.Wait()
                                        end


                                    end)
                                    task.New(unit, function()
                                        for i = 1, 60 do
                                            R = tR * task.SetMode[2](i / 60)
                                            task.Wait()
                                        end
                                        New(shoot_laser, unit, 6, 10, 45, 120)
                                        task.New(unit, function()
                                            task.Wait(45)
                                            local sty = { grain_a, grain_b }
                                            for i = 1, 6 do
                                                for z = -1, 1 do
                                                    local v = stage_lib.GetValue(2, 3.5, 4.3, 20)
                                                    Create.bullet_decel(unit.x, unit.y, sty[i % 2 + 1], 6, v + 2, v,
                                                            unit.angle + 180 + z * 8, false, false)
                                                end
                                                PlaySound("tan00")
                                                task.Wait(8)
                                            end
                                        end)
                                        task.Wait(20)
                                        local aR = 0
                                        while true do
                                            R = R + aR
                                            aR = aR + 0.05
                                            task.Wait()
                                        end
                                    end)
                                end)

                            end
                            PlaySound("tan00")
                            task.Wait(stage_lib.GetValue(60, 50, 40, 10))
                            d = -d
                        end
                    end)
                    local function Shoot(x, y, v, a)
                        local k = Create.bullet_decel(x, y, ball_huge, 2, v * 1.5, v, a)
                        bullet.SetLayer(k, LAYER.ENEMY_BULLET + 1)
                        Create.bullet_decel(x, y, heart, 2, v * 1.5, v, a)
                    end
                    while true do
                        task.Wait(60)
                        task.MoveToPlayer(60, -200, 200, 120, 145,
                                40, 50, 15, 20, 2, 1)
                        for _ = 1, 5 do
                            for a in sp.math.AngleIterator(Angle(self, player), 8) do
                                Shoot(self.x, self.y, stage_lib.GetValue(4, 4.5, 5, 13), a)
                            end
                            task.Wait(30)
                        end
                    end

                end)
            end

            local sc2 = boss.card.New("结界「四方八方之网」", 2, 7, 40, HP(1400))
            boss.card.add(bclass, sc2)
            function sc2:before()
                task.MoveToForce(0, 120, 60, 2)
            end
            function sc2:init()
                local big_laser_warning = function(x, y, wait, rot, col)
                    local self = NewObject(Class(bullet, {
                        frame = function(self)
                            bullet.frame(self)
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
                                SetImageState("white", "mul+add", 100 * l.time / l.maxtime, self.linecol[1], self.linecol[2], self.linecol[3])
                                Render("white", self.x - sin(rot) * l.offx, self.y + cos(rot) * l.offx, rot, 100, 1.6 / 8)
                            end
                        end
                    }, true))
                    bullet.init(self, ball_huge, col, false, false)
                    self.timer = 11
                    self._blend = "mul+add"
                    self.x, self.y = x, y
                    self.colli = false
                    self.linecol = ColorList[math.ceil(col / 2)]
                    self.renderline = {}
                    task.New(self, function()
                        local n = int(wait) - 1
                        for i = 0, n do
                            for z = -1, 1, 2 do
                                table.insert(self.renderline, { offx = z * task.SetMode[2](i / n) * 32, time = 30, maxtime = 30 })
                            end
                            task.Wait()
                        end
                        while #self.renderline > 0 do
                            task.Wait()
                        end
                        object.RawDel(self)
                    end)
                end
                local laser_warning = Class(laser, {
                    init = function(self, x, y, col, w, a, l, wait)
                        laser.init(self, col, x, y, a, 0, 0, 0, w, 0, 0)
                        laser._TurnHalfOn(self, 0, false)
                        self.l1, self.l2, self.l3 = l * 0.4, l * 0.2, l * 0.4
                        self._a = 150
                        task.New(self, function()
                            task.Wait(wait)
                            object.Del(self)
                        end)
                    end
                }, true)
                local function divide(x, y, col, v, a, time, dn, k)
                    local self = NewObject(bullet)
                    object.SetSizeColli(self, 0.7)
                    bullet.init(self, ball_big, col, false, true)
                    self.a, self.b = 3, 3
                    self.x, self.y = x, y
                    self.not_move = true
                    self.is_divide = true
                    self.noTPbyYukari = true
                    self.__broken_room_check = true
                    self.__not_XuanWo = true
                    self.omega = ran:Sign() * ran:Float(2, 3)
                    PlaySound("tan00")
                    task.New(self, function()
                        if k > 0 then
                            object.ChangingV(self, 0, v, a, time / 2)
                            object.ChangingV(self, v, 0, a, time / 2)
                            object.BulletDo(function(b)
                                if b.is_divide then
                                    if Dist(b, self) < 0.01 then
                                        object.RawDel(b)
                                    end
                                end
                            end)
                            for A in sp.math.AngleIterator(a, dn) do
                                divide(self.x, self.y, col, v, A, time, dn, k - 1)
                                New(laser_warning, self.x, self.y, col, 8, A, 95, time * 0.6)
                            end
                            Del(self)
                        else
                            object.SetV(self, v, a)
                        end
                    end)
                end
                task.New(self, function()
                    Newcharge_in(self.x, self.y, 189, 252, 201)
                    task.Wait(60)
                    boss.cast(self, 180)
                    task.New(self, function()

                        while true do
                            local flag = true
                            object.BulletDo(function(e)
                                if e.is_divide then
                                    flag = false
                                    --e.y = e.y - 1
                                end
                            end)
                            if flag then

                                for a in sp.math.AngleIterator(ran:Float(0, 360), 12) do
                                    divide(self.x, self.y, 10, int(stage_lib.GetValue(3, 3.5, 4, 15)), a,
                                            int(stage_lib.GetValue(70, 60, 50, 13)), 3, 333)
                                end
                            end
                            task.Wait()
                        end
                    end)
                    task.Wait(stage_lib.GetValue(180, 150, 90, 25))
                    local A = Angle(self, player)
                    for a in sp.math.AngleIterator(A, 3) do
                        big_laser_warning(self.x, self.y, 60, a, 2)
                    end
                    Newcharge_in(self.x, self.y, 250, 128, 114)
                    task.Wait(60)
                    while true do
                        Newcharge_out(self.x, self.y, 250, 128, 114)
                        local sty = { ball_mid, ball_big, ball_huge, ball_mid_c }
                        local fr = stage_lib.GetValue(3, 4, 5, 18)
                        for a in sp.math.AngleIterator(A, 3) do
                            for _ = 1, 160 do
                                local b = NewSimpleBullet(sty[ran:Int(1, 4)], 2, self.x, self.y, ran:Float(2, 12), a)
                                object.SetA(b, 0.07, a + 180 + ran:Float(-fr, fr))
                            end
                        end
                        task.MoveToPlayer(60, -200, 200, 100, 140,
                                40, 50, 30, 40, 2, 1)
                        task.Wait(stage_lib.GetValue(100, 75, 50, 10))
                        A = Angle(self, player)
                        for a in sp.math.AngleIterator(A, 3) do
                            big_laser_warning(self.x, self.y, 60, a, 2)
                        end
                        boss.cast(self, 60)
                        Newcharge_in(self.x, self.y, 250, 128, 114)
                        task.Wait(60)

                    end
                end)
            end

            local non_sc2 = boss.card.New("", 2, 6, 40, HP(1150))
            boss.card.add(bclass, non_sc2)
            function non_sc2:before()
                task.MoveToForce(0, 120, 60, 2)
            end
            function non_sc2:init()
                task.New(self, function()
                    Newcharge_in(self.x, self.y, 200, 100, 100)
                    task.Wait(60)

                    local d = 1
                    while true do
                        task.Wait(10)
                        boss.cast(self, 60)
                        for a in sp.math.AngleIterator(Angle(self, player), stage_lib.GetValue(15, 20, 25, 90)) do
                            for v = 1, 2 do
                                Create.bullet_accel(self.x, self.y, ball_huge, 6, 2, 1 + v * 3, a)
                            end
                        end
                        local N = int(stage_lib.GetValue(32, 40, 50, 120))
                        for k = 1, N do
                            local a = -90 + (-45 + k / N * 525) * d
                            local mN = int(stage_lib.GetValue(2, 3.5, 4.6, 6))
                            for m = 1, mN do
                                local r = 20 + m * 13
                                local b = Create.bullet_changeangle(self.x + cos(a) * r, self.y + sin(a) * r, butterfly, 16,
                                        0, a, false, { wait = 30, time = 25, v = stage_lib.GetValue(1, 2.5, 3.3, 8) + m / mN },
                                        { r = (-k / 35 * 1.5 + m / mN) * d, time = 60 })
                                b.fogtime = 60
                                b._blend = "add+alpha"
                                b._r, b._g, b._b = sp:HSVtoRGB(k / N * 360, 1, 0.6)
                            end
                            PlaySound("tan00")
                            task.Wait(2 + k / N * 3)
                        end
                        for t = 1, 4 do
                            servant.init(NewObject(servant), self.x, self.y, 0, 135, 206, 235, 1.5, function(unit)
                                task.New(unit, function()
                                    unit:FadeIn(15)
                                    object.ChangingSizeColli(unit, -0.5, -0.5, 15)
                                end)
                                task.New(unit, function()
                                    local k = d * (t % 2 * 2 - 1)
                                    local x, y = ran:Float(150, 200) * -k, ran:Float(-140, -0)
                                    task.MoveToEx(x, y, 46 + t * 10, 2)
                                    PlaySound("kira00")
                                    local A = ran:Float(80, 100)
                                    for a in sp.math.AngleIterator(Angle(unit, player), int(stage_lib.GetValue(12, 14, 16, 50))) do
                                        Create.laser_line(unit.x, unit.y, 6, 6, a,
                                                int(stage_lib.GetValue(20, 31, 42, 120)), 12, 8)
                                    end
                                    task.Wait(20)
                                    object.ChangingSizeColli(unit, -1, -1, 15)
                                    Del(unit)


                                end)
                            end)

                        end
                        d = -d
                        task.MoveToPlayer(60, -200, 200, 120, 145,
                                40, 50, 15, 20, 2, 1)
                    end

                end)
            end

            local sc3 = boss.card.New("「深弹幕结界 -奇花初胎-」", 49.5, 49.5, 49.5, HP(3200))
            boss.card.add(bclass, sc3)
            function sc3:before()
                task.Wait(60)
            end
            function sc3:init()
                task.New(self, function()
                    local total = {}
                    local kekkai_bullet = function(x, y, col, v, a, bound, time, kv)
                        local self = NewObject(bullet)
                        bullet.init(self, arrow_big_c, col, false, false)
                        self.x, self.y = x, y
                        self.fogtime = 6
                        self._blend = "mul+add"
                        object.SetV(self, v, a, true)
                        PlaySound("tan00")
                        sp:UnitListUpdate(total)
                        if #total < 1800 then
                            sp:UnitListAppend(total, self)
                        else
                            object.RawDel(self)
                        end
                        if not bound then
                            self.bound = false
                            task.New(self, function()
                                task.Wait(time * 0.7)
                                object.ChangingV(self, v, 0, a, int(time * 0.3))

                                while not self.jump do
                                    task.Wait()
                                end
                                self.group = GROUP.ENEMY_BULLET
                                bullet.ChangeImage(self, diamond, self._index)
                                Create.bullet_create_eff(self)

                                object.ChangingV(self, 0, kv, a, 140)
                                self.bound = true
                            end)

                        end
                    end
                    self.colli = false
                    self._r, self._g, self._b = 150, 150, 150
                    self._wisys:SetFloat()
                    task.MoveToForce(0, 0, 59, 2)
                    task.Wait()
                    Newcharge_in(self.x, self.y, 189, 252, 201)
                    task.Wait(60)
                    boss.cast(self, 333666)
                    local d = 1
                    for a in sp.math.AngleIterator(0, 6) do
                        servant.init(NewObject(servant), self.x, self.y, 0, 250, 128, 114, 1.5, function(self)
                            self.bound = false
                            local D = d
                            task.New(self, function()
                                self:FadeIn(15)
                                object.ChangingSizeColli(self, -0.5, -0.5, 15)
                            end)
                            local cx, cy = self.x, self.y
                            local R = 0
                            local o = 3 * D
                            self.angle = a
                            task.New(self, function()
                                while true do
                                    self.x = cx + cos(self.angle) * R
                                    self.y = cy + sin(self.angle) * R
                                    self.angle = self.angle + o
                                    task.Wait()
                                end


                            end)
                            task.New(self, function()
                                for i = 1, 60 do
                                    i = task.SetMode[2](i / 60)
                                    R = 260 * i
                                    o = (3 - i * 2) * D
                                    task.Wait()
                                end
                                task.New(self, function()
                                    for i = 1, 9 do
                                        for _ = 1, 7 do
                                            local ox = 0
                                            local oy = 0
                                            for _a in sp.math.AngleIterator(Angle(self, ox, oy) + (i - 1) * 5, 5) do
                                                kekkai_bullet(self.x, self.y, 2, 4 - i / 3, _a,
                                                        false, 60 - i * 4, stage_lib.GetValue(2.5, 3, 3.5, 12))
                                            end
                                            task.Wait(3)
                                        end
                                        --task.Wait(6)
                                    end
                                end)
                                task.Wait(180)
                                for i = 1, 60 do
                                    i = task.SetMode[1](i / 60)
                                    R = 260 + 150 * i
                                    task.Wait()
                                end
                                Del(self)

                            end)
                        end)
                        d = -d
                    end
                    task.Wait(180 + 60 + stage_lib.GetValue(90, 80, 70, 30))
                    self.timer = self.timer + stage_lib.GetValue(0, 10, 20, 60)
                    PlaySound("kira00")
                    object.IndesDo(function(b)
                        b.jump = true
                    end)
                    task.Wait(240)
                    for a in sp.math.AngleIterator(0, 5) do
                        servant.init(NewObject(servant), self.x, self.y, 0, 135, 206, 235, 1.5, function(self)
                            self.bound = false
                            task.New(self, function()
                                self:FadeIn(15)
                                object.ChangingSizeColli(self, -0.5, -0.5, 15)
                            end)
                            local cx, cy = self.x, self.y
                            local R = 0
                            local o = 3
                            self.angle = a
                            task.New(self, function()
                                while true do
                                    self.x = cx + cos(self.angle) * R
                                    self.y = cy + sin(self.angle) * R
                                    self.angle = self.angle + o
                                    task.Wait()
                                end


                            end)
                            task.New(self, function()
                                task.New(self, function()
                                    task.Wait(25)
                                    for i = 1, 20 do
                                        for _ = 1, 5 do
                                            local ox = cos(a) * 75
                                            local oy = sin(a) * 75
                                            kekkai_bullet(self.x, self.y, 6, 3, Angle(self, ox, oy) + 25,
                                                    false, i % 2 * 45 + 25, stage_lib.GetValue(2, 2.5, 3, 7))
                                            kekkai_bullet(self.x, self.y, 6, 0.5, Angle(self, ox, oy) + 180,
                                                    false, i % 2 * 45 + 25, stage_lib.GetValue(2, 2.5, 3, 7))
                                            task.Wait(2)
                                        end
                                    end
                                end)
                                for i = 1, 135 do
                                    i = task.SetMode[2](i / 135)
                                    R = 260 * i
                                    o = 1 - i * 2.5
                                    task.Wait()
                                end
                                task.Wait(80)
                                for i = 1, 60 do
                                    i = task.SetMode[1](i / 60)
                                    R = 260 + 150 * i
                                    task.Wait()
                                end
                                Del(self)

                            end)
                        end)
                    end
                    task.Wait(180 + 60 + stage_lib.GetValue(90, 80, 70, 30))
                    self.timer = self.timer + stage_lib.GetValue(0, 10, 20, 60)
                    PlaySound("kira00")
                    object.IndesDo(function(b)
                        b.jump = true
                    end)
                    task.Wait(190)
                    for a in sp.math.AngleIterator(0, 4) do
                        servant.init(NewObject(servant), self.x, self.y, 0, 189, 252, 201, 1.5, function(self)
                            self.bound = false
                            task.New(self, function()
                                self:FadeIn(15)
                                object.ChangingSizeColli(self, -0.5, -0.5, 15)
                            end)
                            local cx, cy = self.x, self.y
                            local R = 0
                            local o = 3
                            self.angle = a
                            task.New(self, function()
                                while true do
                                    self.x = cx + cos(self.angle) * R
                                    self.y = cy + sin(self.angle) * R
                                    self.angle = self.angle + o
                                    task.Wait()
                                end


                            end)
                            task.New(self, function()
                                for i = 1, 60 do
                                    i = task.SetMode[2](i / 60)
                                    R = 270 * i
                                    o = 1 + i * 2.5
                                    task.Wait()
                                end
                                task.New(self, function()
                                    for i = 1, 18 do
                                        for _ = 1, 4 do
                                            local ox = cos(a) * 200
                                            local oy = sin(a) * 200
                                            kekkai_bullet(self.x, self.y, 10, 3, Angle(self, ox, oy) + 25,
                                                    false, i % 2 * 45 + 25, stage_lib.GetValue(2, 2.5, 3, 7.5))
                                            kekkai_bullet(self.x, self.y, 10, i / 18 * 3, Angle(self, ox, oy) + 180,
                                                    false, 30, stage_lib.GetValue(2, 2.5, 3, 7.5))
                                            task.Wait(1)
                                        end
                                        task.Wait(6)
                                    end
                                end)
                                for _ = 1, 90 do
                                    kekkai_bullet(self.x, self.y, 10, 1.5, self.angle, true)
                                    task.Wait(2)
                                end
                                for i = 1, 60 do
                                    i = task.SetMode[1](i / 60)
                                    R = 270 + 150 * i
                                    task.Wait()
                                end
                                Del(self)

                            end)
                        end)
                    end
                    task.Wait(180 + 60 + stage_lib.GetValue(90, 80, 70, 30))
                    self.timer = self.timer + stage_lib.GetValue(0, 10, 20, 60)
                    PlaySound("kira00")
                    object.IndesDo(function(b)
                        b.jump = true
                    end)
                    task.Wait(190)
                    for a in sp.math.AngleIterator(0, 7) do
                        servant.init(NewObject(servant), self.x, self.y, 0, 250, 128, 114, 1.5, function(self)
                            self.bound = false
                            task.New(self, function()
                                self:FadeIn(15)
                                object.ChangingSizeColli(self, -0.5, -0.5, 15)
                            end)
                            local cx, cy = self.x, self.y
                            local R = 0
                            local o = 3
                            self.angle = a
                            task.New(self, function()
                                while true do
                                    self.x = cx + cos(self.angle) * R
                                    self.y = cy + sin(self.angle) * R
                                    self.angle = self.angle + o
                                    task.Wait()
                                end


                            end)
                            task.New(self, function()
                                for i = 1, 60 do
                                    i = task.SetMode[2](i / 60)
                                    R = 270 * i
                                    o = 0.3
                                    task.Wait()
                                end
                                task.New(self, function()
                                    for i = 1, 6 do
                                        for _ = 1, 10 do
                                            for A in sp.math.AngleIterator(90, 2) do
                                                local ox = cos(A) * 150
                                                local oy = sin(A) * 150
                                                kekkai_bullet(self.x, self.y, 2, 3, Angle(self, ox, oy) + 6 + i * 2,
                                                        false, 120 - i * 10, stage_lib.GetValue(2, 2.5, 3, 8))
                                                kekkai_bullet(self.x, self.y, 2, -2 + i / 6 * 4, Angle(self, 0, 0) + 180,
                                                        false, 100, stage_lib.GetValue(2, 2.5, 3, 8))
                                            end
                                            task.Wait(3)
                                        end
                                    end
                                end)
                                for _ = 1, 90 do
                                    kekkai_bullet(self.x, self.y, 2, 1.5, self.angle, true)
                                    task.Wait(2)
                                end
                                for i = 1, 60 do
                                    i = task.SetMode[1](i / 60)
                                    R = 270 + 150 * i
                                    task.Wait()
                                end
                                Del(self)

                            end)
                        end)
                    end
                    task.Wait(180 + 60 + stage_lib.GetValue(90, 80, 70, 30))
                    self.timer = self.timer + stage_lib.GetValue(0, 10, 20, 60)
                    PlaySound("kira00")
                    object.IndesDo(function(b)
                        b.jump = true
                    end)
                    task.Wait(190)
                    for a in sp.math.AngleIterator(0, 2) do
                        servant.init(NewObject(servant), self.x, self.y, 0, 218, 112, 214, 1.5, function(self)
                            self.bound = false
                            task.New(self, function()
                                self:FadeIn(15)
                                object.ChangingSizeColli(self, -0.5, -0.5, 15)
                            end)
                            local cx, cy = self.x, self.y
                            local R = 0
                            local o = 3
                            self.angle = a
                            task.New(self, function()
                                while true do
                                    self.x = cx + cos(self.angle) * R
                                    self.y = cy + sin(self.angle) * R
                                    self.angle = self.angle + o
                                    task.Wait()
                                end


                            end)
                            task.New(self, function()
                                for i = 1, 60 do
                                    i = task.SetMode[2](i / 60)
                                    R = 270 * i
                                    o = 0.3
                                    task.Wait()
                                end
                                for t = 1, 270 do
                                    kekkai_bullet(self.x, self.y, 4, 4 - t / 180 * 4, Angle(self, 0, 0) + 6 - t / 180 * 6,
                                            false, 120, stage_lib.GetValue(2, 2.5, 3, 8))
                                    kekkai_bullet(self.x, self.y, 4, 1.5, self.angle, true)
                                    o = 0.3 + sin(t / 180 * 270) * 6
                                    task.Wait()
                                end
                                for i = 1, 60 do
                                    i = task.SetMode[1](i / 60)
                                    R = 270 + 150 * i
                                    task.Wait()
                                end
                                Del(self)

                            end)
                        end)
                    end
                    task.Wait(270 + 60 + stage_lib.GetValue(90, 80, 70, 30))
                    self.timer = self.timer + stage_lib.GetValue(0, 10, 20, 60)
                    PlaySound("kira00")
                    object.IndesDo(function(b)
                        b.jump = true
                    end)
                end)

            end
            function sc3:del()
                if var.wave ~= var.maxwave then
                    lstg.tmpvar.otherMusic = nil
                end
            end
            function sc3:other_drop()
                mission_lib.GoMission(19)
                mission_lib.GoMission(20)
                mission_lib.GoMission(21)
                mission_lib.GoMission(22)
                mission_lib.GoMission(89, 1 / 2 * 100)
                if var.wave ~= var.maxwave then
                    local othercond = function(tool)
                        return (tool.id == 54) or (tool.id == 60) or (tool.id == 50) or (tool.id == 119)
                    end
                    local addition = stg_levelUPlib.GetAdditionList(1, othercond)
                    if #addition > 0 then
                        item.dropItem(item.drop_card, 1, self.x, self.y + 30, addition[1].id)
                    end
                end

            end
            boss.Create(bclass)
        end, _t("此面向......?"), nil, true, true)
lib.NewWaveEventInWaves(class, 35, { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 }, 0.03,
        0, 0.4, function()
            local enemy = Class(enemy, {
                init = function(self, x, y, vx, vy)
                    enemy.init(self, 31, HP(5), false, true, true, 1)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx, vy
                end
            }, true)
            task.New(stage.current_stage, function()
                task.Wait(60)
                local othercond = function(tool)
                    return tool.quality == 4 or tool.quality == 3
                end
                local addition = stg_levelUPlib.GetAdditionList(3, othercond)
                if #addition > 0 then
                    for i = 1, #addition do
                        item.dropItem(item.drop_addition_sp, 1, (i - 2) * 170, 240, addition[i].id, function()
                            for _, o in ObjList(GROUP.ITEM) do
                                if o.__otherflag == "is_item" then
                                    object.Del(o)
                                end
                            end
                            object.EnemyNontjtDo(function(e)
                                if not e.pass_check then
                                    e.hp = 0
                                end
                            end)
                        end, "is_item")
                    end
                end
            end)

            for _ = 1, 12 do
                for x = -1, 1 do
                    New(enemy, x * 170, 270, 0, -2.2)
                end
                task.Wait(20)
            end
            task.Wait(60)
        end, _t("三世同堂"), true)