local lib = stage_lib
local servant = _editor_class.SimpleServant
local GetNumByInverse = sp.math.GetNumByInverse
local class = SceneClass[3]
local HP = lib.GetHP
local function _t(str)
    return i18n("scene3", str) or ""
end
local function name(str)
    return i18n("bossname", str)
end

lib.NewWaveEventInWaves(class, 1, { 1, 2, 3, 4, 16 }, 1,
        0, 1, function()
            local enemy1 = Class(enemy, {
                init = function(self, x, y, vx1, vy1)
                    enemy.init(self, 28, HP(10), false, true, false, 1)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx1, vy1
                    PlaySound("boon00")
                    Create.bullet_create_eff(self.x, self.y, ball_big, 5)
                    task.New(self, function()
                        task.Wait(ran:Int(35, 125))
                        for _ = 1, 7 do
                            local v = stage_lib.GetValue(2, 3, 4, 15)
                            local b = NewSimpleBullet(ball_mid, 5, self.x, self.y, v, 90)
                            b.ag = v / 100
                            PlaySound("tan00")
                            task.Wait(stage_lib.GetValue(125, 40, 12, 2))
                        end
                    end)
                end,
            }, true)
            local enemy2 = Class(enemy, {
                init = function(self, x, y, mx, my, vx, vy)
                    enemy.init(self, 1, HP(11), false, true, false, 1.2)
                    self.x, self.y = x, y
                    task.New(self, function()
                        task.MoveTo(mx, my, 75, 2)
                        local v = stage_lib.GetValue(3, 4, 5, 10)
                        for a in sp.math.AngleIterator(Angle(self, player), 8) do
                            Create.bullet_decel(self.x, self.y, ball_huge, 2, v * 2, v, a)
                        end
                        PlaySound("tan00")
                        for i = 1, 60 do
                            self.vx = i / 60 * vx
                            self.vy = i / 60 * vy
                            task.Wait()
                        end
                    end)
                end,
            }, true)
            local D = 1
            for _ = 1, 2 do
                for _ = 1, 2 do
                    for _ = 1, 3 do
                        for k = 0, 6 do
                            for d = -1, 1, 2 do
                                New(enemy1, d * k * 50 + ran:Float(-30, 30), 140 + ran:Float(-k * 8, k * 8), 0, -2.5)
                            end
                            task.Wait(5)
                        end
                        task.Wait(12)
                    end
                    task.Wait(60)
                end
                for _ = 1, 9 do
                    local y = ran:Float(100, 180)
                    New(enemy2, -360 * D, y + 80, ran:Float(-220, -280) * D, y, 3 * D, 0)
                    task.Wait(5)
                    D = -D
                end

            end
            task.Wait(30)
        end, _t("阴魂探测器"))
lib.NewWaveEventInWaves(class, 2, { 5, 10, 15 }, 1,
        0, 1, function()
            local bclass = boss.Define(name("Okina"), 0, 400, _editor_class.okina_bg, "Okina1")

            local sc = boss.card.New("秘符「秘神的耀光」", 2, 4, 40, HP(1500))
            boss.card.add(bclass, sc)
            function sc:before()
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
            function sc:init()
                task.New(self, function()
                    task.init_left_wait(self)
                    local beat = 3600 / stage_lib.GetValue(145, 180, 250, 1456)
                    self._bosssys:castcard("秘符「秘神的耀光」")
                    task.New(self, function()
                        local W = {}
                        task.init_left_wait(W)
                        local k = 1
                        while true do
                            beat = 3600 / stage_lib.GetValue(145, 180, 250, 1456)
                            for a in sp.math.AngleIterator(sin(k * 8) * 35, int(stage_lib.GetValue(9, 10, 13, 15))) do
                                for d = -1, 1, 2 do
                                    local b = Create.bullet_changeangle(self.x, self.y, arrow_small, 8, 2, a, false,
                                            { wait = 10, v = 4.2, r = d, time = 70 }, { v = 1, time = 60 })
                                    -- b._blend = "mul+add"
                                    function b:frame_new()
                                        bullet.frame(self)
                                        bullet.smear_add(self, 70)
                                        bullet.smear_frame(self, 7)
                                    end
                                    function b:render_new()
                                        bullet.smear_render(self)
                                        bullet.render(self)
                                    end
                                end
                            end
                            PlaySound("tan00", 0.1, 0, true)
                            task.Wait2(W, beat / 2)
                            k = k + 1
                        end
                    end)
                    while true do
                        for a in sp.math.AngleIterator(Angle(self, player), int(stage_lib.GetValue(12, 18, 25, 80))) do
                            for v = 0, 1 do
                                Create.bullet_accel(self.x, self.y, ball_big, 2, 0.5, 4 + v, a, true)
                            end
                        end
                        task.Wait2(self, beat * 4)
                    end
                end)
            end
            function sc:other_bonus_drop()
            end
            boss.Create(bclass)
        end, _t("给我干哪来了"), nil, nil, true)
lib.NewWaveEventInWaves(class, 3, { 5, 10, 15 }, 1,
        0, 1, function()
            local bclass = boss.Define(name("Yukari"), 0, 400, _editor_class.yukari_bg, "Yukari")
            local sc = boss.card.New("「梦中的情之线」", 2, 5, 40, HP(1600))
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
                    task.init_left_wait(self)
                    boss.cast(self, 9999)
                    local beat = 3600 / stage_lib.GetValue(145, 180, 250, 1456)
                    servant.init(NewObject(servant), self.x, self.y, 0, 135, 206, 235, 1.5, function(unit)
                        unit.omega = ran:Sign() * ran:Float(3, 4)
                        unit.bound = false
                        local n = 12
                        local r, o = 0, -90
                        local t = 0
                        local points = {}
                        for i = 1, n do
                            points[i] = {}
                            New(_editor_class.PointRender, points[i], 40 * 60, 100, 135, 206, 235, true)
                        end
                        task.New(unit, function()
                            while true do
                                unit.x = unit.x + (self.x + cos(o) * r - unit.x) * 0.05
                                unit.y = unit.y + (self.y + sin(o) * r - unit.y) * 0.05
                                r = 120 * sin(t * 0.8)
                                o = o + 1.1 * sin(min(t, 90))
                                t = t + 0.5
                                task.Wait()
                            end
                        end)
                        task.New(unit, function()
                            unit:FadeIn(15)
                            object.ChangingSizeColli(unit, -0.5, -0.5, 15)
                        end)
                        task.New(unit, function()
                            task.init_left_wait(unit)
                            while true do
                                for A, i in sp.math.AngleIterator(0, n) do
                                    local b = Create.bullet_accel(unit.x, unit.y, grain_a, 8, 2,
                                            stage_lib.GetValue(5, 6, 8, 12), A, true, false)
                                    table.insert(points[i], b)
                                end
                                PlaySound("tan00", 0.05, 0, true)
                                task.Wait(beat * 0.5)
                            end
                            object.ChangingSizeColli(unit, -1, -1, 15)
                            object.Del(unit)
                        end)
                    end)
                    servant.init(NewObject(servant), self.x, self.y, 0, 135, 206, 235, 1.5, function(unit)
                        unit.omega = ran:Sign() * ran:Float(3, 4)
                        unit.bound = false
                        local r, o = 0, -90
                        local t = 0
                        local n = 10
                        local points = {}
                        for i = 1, n do
                            points[i] = {}
                            New(_editor_class.PointRender, points[i], 40 * 60, 100, 64, 64, 235, true)
                        end
                        task.New(unit, function()
                            while true do
                                unit.x = unit.x + (self.x + cos(o) * r - unit.x) * 0.05
                                unit.y = unit.y + (self.y + sin(o) * r - unit.y) * 0.05
                                r = 120 * sin(t * 0.7)
                                o = o - 0.99 * sin(min(t, 90))
                                t = t + 0.5
                                task.Wait()
                            end
                        end)
                        task.New(unit, function()
                            unit:FadeIn(15)
                            object.ChangingSizeColli(unit, -0.5, -0.5, 15)
                        end)
                        task.New(unit, function()
                            task.init_left_wait(unit)
                            while true do
                                for A, i in sp.math.AngleIterator(0, n) do
                                    local b = Create.bullet_accel(unit.x, unit.y, grain_a, 6, 2,
                                            stage_lib.GetValue(5, 6, 8, 12), A, true, false)
                                    table.insert(points[i], b)
                                end
                                PlaySound("tan00", 0.05, 0, true)
                                task.Wait(beat * 0.5)
                            end

                        end)
                    end)
                    while true do
                        beat = 3600 / stage_lib.GetValue(145, 180, 250, 1456)
                        for v = 1, 2 do
                            for a in sp.math.AngleIterator(ran:Float(0, 360), int(stage_lib.GetValue(12, 18, 22, 100))) do
                                local vindex = stage_lib.GetValue(1, 1.3, 1.6, 2.5)
                                Create.bullet_decel(self.x, self.y, ball_big, 4, (3 + v) * vindex, (1 + v * 0.5) * vindex, a)
                            end
                        end
                        PlaySound("tan00")
                        task.Wait2(self, beat * 4)
                    end
                end)
            end
            boss.Create(bclass)
        end, _t("怎么还是你"), nil, nil, true)
lib.NewWaveEventInWaves(class, 4, { 6, 7, 8, 9, 17, 19 }, 1,
        0, 1, function(var)
            local stg = stage.current_stage
            local enemy1 = Class(enemy, {
                init = function(self, x, y, vx, vy)
                    enemy.init(self, 25, HP(20), false, true, false, 2.3)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx * 0.3, vy * 0.3
                    task.New(self, function()
                        task.Wait(90)
                        local A = Angle(0, 0, self.vx, self.vy)
                        for _ = 1, int(stage_lib.GetValue(12, 18, 25, 60)) do
                            Create.bullet_decel(self.x, self.y, arrow_big_c, 6, 4, min(8, 2 + var.chaos / 38), A + 180 + ran:Float(-10, 10))
                            PlaySound("tan00")
                            task.Wait(stage_lib.GetValue(7, 5, 4, 1))
                        end
                    end)
                    task.New(self, function()
                        task.Wait(50)
                        for i = 1, 36 do
                            self.vx = vx * (0.3 + 0.7 * (i / 36))
                            self.vy = vy * (0.3 + 0.7 * (i / 36))
                            task.Wait()
                        end
                    end)
                end,
            }, true)
            local enemy2 = Class(enemy, {
                init = function(self, x, y, mx, my, vx, vy, vp)
                    enemy.init(self, 6, HP(20), false, true, false, 8)
                    self.x, self.y = x, y
                    task.New(self, function()
                        task.MoveTo(mx, my, 60, 2)
                        task.New(self, function()
                            for _ = 1, int(stage_lib.GetValue(3, 3, 5, 35)) do
                                for a in sp.math.AngleIterator(Angle(self, player), int(stage_lib.GetValue(12, 18, 25, 60))) do
                                    local v = vp + stage_lib.GetValue(0, 1, 2, 5)
                                    Create.bullet_decel(self.x, self.y, ball_mid_c, 2, v * 1.5, v, a)
                                end
                                PlaySound("tan00")
                                task.Wait(stage_lib.GetValue(90, 55, 22, 6))
                            end
                        end)
                        task.Wait(180)
                        for i = 1, 60 do
                            self.vx = i / 60 * vx
                            self.vy = i / 60 * vy
                            task.Wait()
                        end
                    end)
                end,
            }, true)
            local d = 1
            for t = 1, 8 do
                task.New(stg, function()
                    local m = (t <= 4) and 2 or 3
                    for c = -m * d, m * d, d do

                        New(enemy1, c * 100, 300, ran:Float(-1, 1), -4)
                        task.Wait(20)
                    end
                end)
                task.Wait(60)
                New(enemy2, 120 * d, 300, 120 * d + ran:Float(-50, 50), 150 + ran:Float(-50, 50), -1.5 * d, 0, 1 + t / 8 * 2)
                task.Wait(80 - t * 6)
                d = -d
            end
            task.Wait(120)
            for c = -7, 7 do
                New(enemy1, c * 40, 300, ran:Float(-1, 1), -ran:Float(3, 5))
            end
        end, _t("蓝藻"))
lib.NewWaveEventInWaves(class, 5, { 6, 7, 8, 9, 16, 18 }, 1,
        0, 1, function()
            local stg = stage.current_stage
            local enemy1 = Class(enemy, {
                init = function(self, x, y, vx, vy)
                    enemy.init(self, 24, HP(20), false, true, false, 2.3)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx * 0.3, vy * 0.3
                    task.New(self, function()
                        task.Wait(60)
                        local A = Angle(0, 0, self.vx, self.vy)
                        for _ = 1, int(stage_lib.GetValue(7, 10, 15, 60)) do
                            local v = stage_lib.GetValue(2, 3, 4, 12)
                            local b = NewSimpleBullet(arrow_big_c, 10, self.x, self.y, v, A + 180 + ran:Float(-10, 10))
                            b.ag = v / 60
                            b.navi = true
                            b.maxv = stage_lib.GetValue(4, 5, 6, 12)
                            PlaySound("tan00")
                            task.Wait(stage_lib.GetValue(7, 5, 4, 1))
                        end
                    end)
                    task.New(self, function()
                        task.Wait(50)
                        for i = 1, 36 do
                            self.vx = vx * (0.3 + 0.7 * (i / 36))
                            self.vy = vy * (0.3 + 0.7 * (i / 36))
                            task.Wait()
                        end
                    end)
                end,
            }, true)
            local enemy2 = Class(enemy, {
                init = function(self, x, y, mx, my, vx, vy, vp)
                    enemy.init(self, 6, HP(20), false, true, false, 8)
                    self.x, self.y = x, y
                    task.New(self, function()
                        task.MoveTo(mx, my, 60, 2)
                        task.New(self, function()
                            for _ = 1, int(stage_lib.GetValue(3, 3, 5, 35)) do
                                for a in sp.math.AngleIterator(Angle(self, player), int(stage_lib.GetValue(12, 18, 25, 60))) do
                                    local v = vp + stage_lib.GetValue(0, 1, 2, 5)
                                    Create.bullet_decel(self.x, self.y, ball_mid_c, 2, v * 1.5, v, a)
                                end
                                PlaySound("tan00")
                                task.Wait(stage_lib.GetValue(90, 55, 22, 6))
                            end
                        end)
                        task.Wait(180)
                        for i = 1, 60 do
                            self.vx = i / 60 * vx
                            self.vy = i / 60 * vy
                            task.Wait()
                        end
                    end)
                end,
            }, true)
            local d = -1
            for t = 1, 8 do
                task.New(stg, function()
                    local m = (t <= 4) and 2 or 3
                    for c = -m * d, m * d, d do

                        New(enemy1, c * 100, 300, ran:Float(-1, 1), -4)
                        task.Wait(20)
                    end
                end)
                task.Wait(60)
                New(enemy2, 120 * d, 300, 120 * d + ran:Float(-50, 50), 150 + ran:Float(-50, 50), -1.5 * d, 0, 1 + t / 8 * 2)
                task.Wait(24 + t * 4)
                d = -d
            end
            task.Wait(75)
            for c = -7, 7 do
                New(enemy1, c * 40, 300, ran:Float(-1, 1), -ran:Float(3, 5))
            end
        end, _t("绿藻"))
lib.NewWaveEventInWaves(class, 6, { 1, 19 }, 1,
        0, 1, function()
            local bclass = boss.Define(name("Kogasa"), 0, 400, _editor_class.kogasa_bg, "Kogasa")
            local sc = boss.card.New("恐吓「针里插缝」", 1, 5, 40, HP(1100))
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
                        local L = int(stage_lib.GetValue(27, 35, 55, 200))
                        local v = 7
                        local bv = stage_lib.GetValue(4, 3, 2, 0.3)
                        local A = ran:Float(0, 360)
                        local c = 240 / L + 0.2
                        local n = int(stage_lib.GetValue(12, 16, 20, 72))
                        local nkindex = 1.5
                        for l = 1, L do
                            for a in sp.math.AngleIterator(A, n) do
                                for j = -1, 1, 2 do
                                    local _a = a + j * 180 / n * nkindex
                                    Create.bullet_accel(self.x + cos(_a) * sin(l * c) * 150, self.y + sin(_a) * sin(l * c) * 150,
                                            water_drop, 4, 0.5, v, _a)
                                    if l % math.ceil(L / 20) == 0 then
                                        Create.bullet_accel(self.x + cos(a) * sin(l * c) * 150, self.y + sin(a) * sin(l * c) * 150,
                                                ball_mid, 3, 0, bv, a + j * 360 / n * nkindex, true, false)
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
            function sc:other_bonus_drop()
                activeItem_lib.DropActive(self.x, self.y, 15)
                mission_lib.GoMission(76)
            end
            boss.Create(bclass)
        end, _t("墙打鬼"), nil, nil, true)
lib.NewWaveEventInWaves(class, 7, { 5, 10, 15 }, 1,
        0, 1, function()

            local bclass = boss.Define(name("Yamame"), 0, 400, _editor_class.yamame_bg, "Yamame")

            local non_sc = boss.card.New("", 2, 6, 35, HP(1200))
            boss.card.add(bclass, non_sc)
            function non_sc:before()
                task.MoveToForce(0, 120, 60, 2)
            end
            function non_sc:init()
                task.New(self, function()
                    Newcharge_in(self.x, self.y, 135, 206, 235)
                    task.Wait(60)
                    task.init_left_wait(self)
                    PlaySound("boon01")
                    local function spider(x, y, v, a, col1, col2, wait, reb_flag)
                        local self = NewObject(bullet)
                        bullet.init(self, ball_mid, col1, false, true)
                        self.x, self.y = x, y
                        object.SetV(self, v / 100, a, true)
                        self.reb_flag = reb_flag
                        local t = { "l", "r", "t" }
                        PlaySound("tan00")
                        task.New(self, function()
                            while self.reb_flag > 0 do
                                object.ReBound(self, t, nil, self.reb_flag > 0, function()
                                    self.reb_flag = self.reb_flag - 1
                                end)
                                task.Wait()
                            end
                        end)
                        task.New(self, function()
                            task.Wait(wait)
                            bullet.ChangeImage(self, self.imgclass, col2)
                            PlaySound("kira00")
                            Create.bullet_create_eff(self)
                            local dv = v - v / 100
                            for i = 1, 75 do
                                object.SetV(self, v / 100 + dv * (i / 75), self.rot)
                                task.Wait()
                            end
                        end)
                    end
                    local d = 1
                    while true do
                        boss.cast(self, 55)
                        local N = int(stage_lib.GetValue(5, 7, 10, 30))
                        local V = stage_lib.GetValue(5, 6, 7, 12)
                        local W = stage_lib.GetValue(0.7, 0.8, 1, 1.3)

                        for a in sp.math.AngleIterator(0, N) do
                            servant.init(NewObject(servant), self.x, self.y, 0, 135, 206, 235, 1.5, function(unit)
                                object.Connect(self, unit, 0.3, true)
                                task.New(unit, function()
                                    unit:FadeIn(15)
                                    object.ChangingSizeColli(unit, -0.5, -0.5, 15)
                                end)
                                local D = d
                                unit.angle = a
                                unit.reb_flag = 1
                                local t = { "l", "r", "t" }
                                task.New(unit, function()
                                    object.SetV(unit, V, unit.angle)
                                    while IsValid(self) do
                                        unit.angle = Angle(0, 0, unit.vx, unit.vy)
                                        object.SetA(unit, V * W / 180 * PI, unit.angle + 90 * D)
                                        object.ReBound(unit, t, nil, unit.reb_flag > 0, function()
                                            unit.reb_flag = unit.reb_flag - 1
                                        end)
                                        task.Wait()
                                    end
                                    Del(unit)
                                end)
                                task.New(unit, function()

                                    while true do
                                        if Dist(unit, player) > 40 then
                                            local w = int(stage_lib.GetValue(120, 110, 100, 45))
                                            spider(unit.x, unit.y, stage_lib.GetValue(3, 4, 5, 12), unit.angle + 180,
                                                    4, 6, w, 1 - unit.reb_flag)
                                        end
                                        task.Wait(stage_lib.GetValue(5, 4, 3, 1))
                                    end
                                end)
                            end)
                        end
                        task.Wait(stage_lib.GetValue(160, 140, 130, 45))
                        d = -d
                        task.MoveToPlayer(60, -180, 180, 100, 150,
                                30, 40, 10, 20, 2, 1)
                        task.Wait(80)
                    end

                end)
            end

            local sc = boss.card.New("蛛符「虫网之束缚」", 2, 5, 40, HP(1200))
            boss.card.add(bclass, sc)
            function sc:before()
                task.Wait(60)
            end
            function sc:init()
                task.New(self, function()
                    task.MoveToForce(0, 120, 60, 2)
                    Newcharge_in(self.x, self.y, 135, 206, 235)
                    task.Wait(60)
                    task.init_left_wait(self)
                    PlaySound("boon01")
                    local accel_laser = function(x, y, v, a, bv, time)
                        local self = Create.laser_line(x, y, 10, v, a, 35, 8)
                        task.New(self, function()
                            task.Wait(35)
                            local kv = 0
                            local dv = bv - v
                            for i = 1, time do
                                local _v = dv / time * i
                                self.l1 = self.l1 + _v / 2
                                self.l3 = self.l3 + _v / 2
                                task.Wait()
                            end
                            object.SetV(self, bv, a)
                        end)
                    end
                    local function spider(x, y, v, a, col1, col2, wait, reb_flag)
                        local self = NewObject(bullet)
                        bullet.init(self, ball_mid, col1, false, true)
                        self.x, self.y = x, y
                        object.SetV(self, v / 100, a, true)
                        self.reb_flag = reb_flag
                        local t = { "l", "r", "t" }
                        PlaySound("tan00")
                        task.New(self, function()
                            while self.reb_flag > 0 do
                                object.ReBound(self, t, nil, self.reb_flag > 0, function()
                                    self.reb_flag = self.reb_flag - 1
                                end)
                                task.Wait()
                            end
                        end)
                        task.New(self, function()
                            task.Wait(wait)
                            bullet.ChangeImage(self, self.imgclass, col2)
                            PlaySound("kira00")
                            Create.bullet_create_eff(self)
                            local dv = v - v / 100
                            for i = 1, 75 do
                                object.SetV(self, v / 100 + dv * (i / 75), self.rot)
                                task.Wait()
                            end
                        end)
                    end
                    local d = 1
                    while true do
                        boss.cast(self, 55)
                        local N = int(stage_lib.GetValue(3, 4, 6, 12))
                        local V = stage_lib.GetValue(5, 6, 7, 12)
                        local G = stage_lib.GetValue(0.04, 0.05, 0.07, 0.15)

                        for a in sp.math.AngleIterator(-90 + 90 / N, N * 2) do
                            servant.init(NewObject(servant), self.x, self.y, 0, 189, 252, 201, 1.5, function(unit)
                                object.Connect(self, unit, 0.3, true)
                                task.New(unit, function()
                                    unit:FadeIn(15)
                                    object.ChangingSizeColli(unit, -0.5, -0.5, 15)
                                end)
                                unit.angle = a
                                unit.reb_flag = 1
                                local t = { "l", "r", "t" }
                                task.New(unit, function()
                                    object.SetV(unit, V, unit.angle)
                                    unit.ag = G
                                    while IsValid(self) do
                                        unit.angle = Angle(0, 0, unit.vx, unit.vy)
                                        object.ReBound(unit, t, nil, unit.reb_flag > 0, function()
                                            local v = stage_lib.GetValue(2, 3, 4, 9)
                                            for la in sp.math.AngleIterator(Angle(unit, player), 15) do
                                                accel_laser(unit.x, unit.y, v, la, v * 2, 25)
                                            end
                                            unit.reb_flag = unit.reb_flag - 1
                                        end)
                                        task.Wait()
                                    end
                                    Del(unit)
                                end)
                                task.New(unit, function()

                                    while true do
                                        if Dist(unit, player) > 40 then
                                            local w = int(stage_lib.GetValue(120, 110, 100, 45))
                                            spider(unit.x, unit.y, stage_lib.GetValue(3, 4, 5, 12), unit.angle + 180,
                                                    10, 2, w, 1 - unit.reb_flag)
                                        end
                                        task.Wait(stage_lib.GetValue(5, 4, 3, 1))
                                    end
                                end)
                            end)
                        end
                        task.Wait(stage_lib.GetValue(100, 90, 80, 40))
                        d = -d
                        task.MoveToPlayer(60, -180, 180, 100, 150,
                                30, 40, 10, 20, 2, 1)
                        task.Wait(80)
                    end

                end)
            end
            boss.Create(bclass)
        end, _t("勇敢蛛蛛，不怕困难"), nil, nil, true)
lib.NewWaveEventInWaves(class, 8, { 5, 10, 15 }, 1,
        0, 1, function()

            local bclass = boss.Define(name("Murasa"), 0, 400, _editor_class.murasa_bg, "Murasa")

            local non_sc = boss.card.New("", 2, 5, 40, HP(1200))
            boss.card.add(bclass, non_sc)
            function non_sc:before()
                self.tp = function(x, y)
                    self._wisys:SetImageInList("Murasa2")
                    PlaySound("boon01")
                    local j = 1
                    for i = 1, 40 do
                        self._wisys:SetFloat(sin(i * 2.25) * 30 * j, 0)
                        j = -j
                        task.Wait()
                    end
                    self.x, self.y = x, y
                    PlaySound("boon01")
                    for i = 39, 0, -1 do
                        self._wisys:SetFloat(sin(i * 2.25) * 30 * j, 0)
                        j = -j
                        task.Wait()
                    end
                    self._wisys:SetImageInList("Murasa")
                    self._wisys:SetFloat(function(ani)
                        return 0, 4 * sin(ani * 4)
                    end)
                end
                self.tp(0, 120)
            end
            function non_sc:init()
                task.New(self, function()
                    Newcharge_in(self.x, self.y, 135, 206, 235)
                    task.Wait(60)
                    task.init_left_wait(self)

                    while true do
                        local x, y
                        local d = -1
                        local beat = 3600 / stage_lib.GetValue(145, 180, 250, 1456)
                        for _ = 1, 2 do
                            boss.cast(self, 60)
                            local ck = int(stage_lib.GetValue(6, 9, 12, 45))
                            local k = (ck - 1) / 2
                            for i = -k, k do
                                i = i * d
                                i = -90 + i * 15
                                x, y = self.x + cos(i) * 120, self.y + sin(i) * 30
                                for a, c in sp.math.AngleIterator(Angle(x, y, player), int(stage_lib.GetValue(14, 17, 22, 50))) do
                                    NewSimpleBullet(arrow_big, 6 + c % 2 * 2, x, y,
                                            (2 + c % 2 + ran:Float(-0.5, 0.5)) * stage_lib.GetValue(0.7, 1, 1.3, 3), a)
                                end
                                PlaySound("tan00", 0.1, 0, true)
                                task.Wait2(self, beat / 4)
                            end
                            d = -d
                            self._wisys.hscale = -self._wisys.hscale
                        end
                        for _ = 1, 2 do
                            local N = int(stage_lib.GetValue(7, 12, 15, 35))
                            for a, i in sp.math.AngleIterator(0, N * 5) do
                                i = i % 5 - 2
                                Create.bullet_changeangle(self.x, self.y, water_drop, 6, 1.5, a,
                                        { r = -i / 20, time = 60, wait = 30, v = (2.5 - abs(i) * 0.2) * stage_lib.GetValue(1, 1.2, 1.4, 2.3) })
                            end
                            PlaySound("kira00", 0.1, 0, true)
                            task.New(self, function()
                                task.MoveToPlayer(40, -200, 200, 80, 120,
                                        20, 40, 10, 20, 2, 1)
                            end)
                            task.Wait2(self, beat * 2)
                        end
                    end
                end)
            end

            local sc = boss.card.New("幽灵「俄勒冈漩涡」", 2, 5, 40, HP(1400))
            boss.card.add(bclass, sc)
            function sc:before()
                task.Wait(60)
            end
            function sc:init()
                task.New(self, function()
                    Newcharge_in(0, 120, 135, 206, 235)
                    task.MoveTo(0, 120, 60, 2)
                    task.init_left_wait(self)
                    local d
                    local x, y
                    local beat = 3600 / stage_lib.GetValue(145, 180, 250, 1456)
                    d = -sign(self.dx)
                    if d == 0 then
                        d = 1
                    end
                    while true do
                        for _ = 1, 2 do
                            beat = 3600 / stage_lib.GetValue(145, 180, 250, 1456)
                            boss.cast(self, 30)
                            task.New(self, function()
                                task.Wait(beat)
                                local index = { 0, 0.25, 0.5, 0.75, 1, 1.5 }
                                for a in sp.math.AngleIterator(ran:Float(0, 360), int(stage_lib.GetValue(18, 21, 28, 55))) do
                                    for c = 1, 6 do
                                        Create.bullet_dec_setangle(self.x, self.y, ellipse, 8, false,
                                                { v = 3 + c * 0.3, a = a, time = beat + beat * index[c] },
                                                { v = stage_lib.GetValue(3, 3.8, 4.3, 9), a = a + (c % 2 * 2 - 1) * 150 })
                                    end
                                end
                            end)
                            local px, py = player.x, player.y
                            for i = -7.5 * d, 7.5 * d, d do

                                x, y = self.x + cos(-90 + i * 8) * 120, self.y + sin(-90 + i * 8) * 30 + i * 7 - 50
                                if i == -7.5 * d then
                                    NewBon(x, y, 60, 128, 250, 128, 114)
                                end

                                for a, c in sp.math.AngleIterator(Angle(x, y, px, py), int(stage_lib.GetValue(15, 20, 25, 60))) do
                                    Create.bullet_decel(x, y, grain_a, 4 + c % 2 * 2, 4,
                                            stage_lib.GetValue(2, 3, 4, 8) + c % 2 * 0.3 + i / 12, a)
                                end
                                PlaySound("tan00")
                                task.Wait2(self, beat / 8)
                            end
                            task.MoveToPlayer(40, -200, 200, 80, 120,
                                    20, 40, 10, 20, 2, 1)
                            d = -sign(self.dx)
                            task.Wait2(self, beat * 2 - 40)
                            boss.cast(self, 30)
                            task.New(self, function()
                                task.Wait(beat)
                                NewBon(self.x, self.y, 60, 128, 135, 206, 235)
                                local index = { 0, 0.25, 0.5, 0.75, 1 }
                                for a in sp.math.AngleIterator(ran:Float(0, 360), int(stage_lib.GetValue(12, 15, 20, 50))) do
                                    for c = 1, 5 do
                                        Create.bullet_dec_setangle(self.x, self.y, ellipse, 8, false,
                                                { v = 3 + c * 0.3, a = a, time = beat + beat * index[c] },
                                                { v = stage_lib.GetValue(3, 3.8, 4.3, 9), a = a + (c % 2 * 2 - 1) * 150 })
                                    end
                                end
                            end)
                            for i = -7.5 * d, 7.5 * d, d do
                                x, y = self.x + cos(-90 + i * 8) * 120, self.y + sin(-90 + i * 8) * 30 + i * 7 - 50
                                if i == -7.5 * d then
                                    NewBon(x, y, 60, 128, 250, 128, 114)
                                end
                                for a, c in sp.math.AngleIterator(Angle(x, y, px, py), int(stage_lib.GetValue(13, 18, 22, 55))) do
                                    Create.bullet_decel(x, y, grain_a, 4 + c % 2 * 2, 4,
                                            stage_lib.GetValue(2, 3, 4, 8) + c % 2 * 0.3 + i / 12, a)
                                end

                                PlaySound("tan00")
                                task.Wait2(self, beat / 8)
                            end
                            task.Wait2(self, beat * 2)
                            for i = 1, 4 do
                                i = i % 2 * 2 - 1
                                for a in sp.math.AngleIterator(ran:Float(0, 360), int(stage_lib.GetValue(8, 10, 13, 30))) do
                                    for v = 0, stage_lib.GetValue(2, 3, 4, 10) do
                                        Create.bullet_changeangle(self.x, self.y, water_drop, 4,
                                                stage_lib.GetValue(2, 3, 4, 9) + v * 0.3,
                                                a + v * 3 * i, { r = -i - v * 0.1 * i, time = 60, wait = 30 })
                                    end
                                end
                                if i % 2 == 0 then
                                    task.New(self, function()
                                        task.MoveToPlayer(40, -200, 200, 80, 120,
                                                20, 40, 10, 20, 2, 1)
                                        d = -sign(self.dx)
                                    end)
                                end

                                task.Wait2(self, beat)
                            end
                            task.Wait2(self, beat * 1.3)
                        end
                    end
                end)
            end
            function sc:other_bonus_drop()
            end
            boss.Create(bclass)
        end, _t("Pretty Pretty Spark"), nil, nil, true)
lib.NewWaveEventInWaves(class, 9, { 5, 10, 15 }, 1,
        0, 1, function()
            local umbrella = Class(servant, {
                render = function(self)
                    local hscale, vscale = self.hscale, self.vscale
                    if lstg.weather.QingMing then
                        hscale = hscale * 0.5
                        vscale = vscale * 0.5
                    end
                    if lstg.tmpvar._is_challenge18 then
                        hscale = hscale * lstg.tmpvar._is_challenge18
                        vscale = vscale * lstg.tmpvar._is_challenge18
                    end
                    object.smear_render(self, self.smear_blend, self.smear_color)
                    SetImageState("umbrella_pic", self._blend, self._a, self._r, self._g, self._b)
                    Render("umbrella_pic", self.x, self.y, self.rot, hscale, vscale)
                    SetImageState("umbrella_black", "", self._a, 0, 0, 0)
                    Render("umbrella_black", self.x, self.y, 0, hscale, vscale)
                end
            }, true)
            local bclass = boss.Define(name("Kogasa"), 0, 400, _editor_class.kogasa_bg, "Kogasa")
            local sc = boss.card.New("唐伞「绵绵幽恨之雨」", 1, 5, 40, HP(1100))
            boss.card.add(bclass, sc)
            function sc:before()
                task.MoveToForce(0, 135, 60, 2)
            end
            function sc:init()
                task.New(self, function()
                    local beat = 3600 / stage_lib.GetValue(145, 180, 250, 1456)
                    local function NewUmbrella1(time, x1, y1, x2, y2, x3, y3)
                        servant.init(NewObject(umbrella), x1, y1, 0, 255, 255, 255, 1.5, function(unit)
                            unit.omega = ran:Sign() * ran:Float(7, 8)
                            unit.bound = false
                            unit.open_smear = true
                            unit.img = "umbrella_pic"
                            unit.smear_maxalpha = 100
                            unit.smear_dealpha = 8
                            unit.colli = true
                            unit.a, unit.b = 40, 40
                            task.New(unit, function()
                                unit:FadeIn(15)
                                object.ChangingSizeColli(unit, -0.5, -0.5, 15)
                            end)
                            task.New(unit, function()
                                task.init_left_wait(unit)
                                local j = ran:Int(1, 7)
                                local smear_blend = "mul+add"
                                local smear_color = { 120, 120, 120 }
                                while true do
                                    j = sp:TweakValue(j + 1, int(stage_lib.GetValue(4, 7, 7, 7)), 1)
                                    local b = NewSimpleBullet(ball_mid, 14, unit.x, unit.y, 0, -90)
                                    b.ag = 0.01 + stage_lib.GetValue(0, 0.01, 0.02, 0.05) + j / 7 / 100
                                    b.maxv = 4.5
                                    b._blend = "mul+add"
                                    function b:frame_other()
                                        bullet.smear_add(self, 30)
                                        bullet.smear_frame(self, 2.6)
                                    end
                                    function b:render_other()
                                        bullet.smear_render(self, smear_blend, smear_color)
                                    end
                                    PlaySound("tan00", 0.05, 0, true)
                                    task.Wait2(unit, beat / 4)
                                end
                            end)
                            task.New(unit, function()
                                local W = {}
                                task.init_left_wait(W)
                                while true do
                                    for a in sp.math.AngleIterator(ran:Float(0, 360), int(stage_lib.GetValue(4, 5, 8, 20))) do
                                        NewSimpleBullet(ball_big, 2, unit.x, unit.y,
                                                stage_lib.GetValue(1, 1.5, 2, 6), a)

                                    end
                                    PlaySound("tan00", 0.05, 0, true)
                                    task.Wait2(W, beat * 4)
                                end
                            end)
                            task.New(unit, function()
                                task.BezierMoveTo(int(time), 0, x2, y2, x3, y3)
                                Del(unit)
                            end)
                        end)
                    end
                    task.init_left_wait(self)

                    task.New(self, function()
                        while true do
                            for i = 1, 8 do
                                NewUmbrella1(200, -380, -60 - 4 * i, 50, 100 + 4 * i, 300, 280 - 4 * i)
                                NewUmbrella1(200, 380, -60 - 4 * i, -50, 100 + 4 * i, -300, 280 - 4 * i)
                                task.Wait(100)
                            end

                        end
                    end)
                    local d = 1
                    while true do
                        d = -d
                        beat = 3600 / stage_lib.GetValue(145, 180, 250, 1456)
                        for a in sp.math.AngleIterator(ran:Float(0, 360), int(stage_lib.GetValue(22, 25, 35, 88))) do
                            Create.bullet_accel(self.x + 20 * cos(a), self.y + 20 * sin(a), ellipse, 6, 2, 3.5, a)
                        end
                        PlaySound("tan00")
                        task.New(self, function()
                            task.MoveToPlayer(beat * 4, -96, 96, 112, 144,
                                    20, 40, 10, 20, 2, 4)
                        end)
                        task.Wait2(self, beat * 8)
                    end
                end)
            end
            function sc:other_drop()
                if ran:Float(0, 1) < 0.5 then
                    item.dropItem(item.drop_card, 1, self.x, self.y + 30, 159)
                end
            end
            boss.Create(bclass)
        end, _t("下次记得标出处"), nil, nil, true)
lib.NewWaveEventInWaves(class, 10, { 5, 10, 15 }, 1,
        0, 1, function()
            local bclass = boss.Define(name("Nazrin"), 200, 400, _editor_class.nazrin_bg, "Nazrin")
            local sc = boss.card.New("测符「赤经赤纬之量度」", 1, 4, 45, HP(1522))
            boss.card.add(bclass, sc)
            function sc:before()
                task.MoveToForce(0, 120, 60, 2)
                Newcharge_in(self.x, self.y, 120, 152, 255)
                task.Wait(60)
            end
            function sc:init()
                task.New(self, function()
                    task.Wait(60)
                    local beat = 3600 / stage_lib.GetValue(100, 200, 300, 1200)
                    local sty = { ball_mid, ball_mid_c }
                    task.New(self, function()
                        task.Wait(60)
                        while true do
                            task.MoveToPlayer(60, -200, 200, 100, 144,
                                    40, 50, 15, 22, 2, 1)
                            task.Wait(180)
                        end
                    end)
                    while true do
                        beat = 3600 / stage_lib.GetValue(100, 150, 200, 1200)
                        boss.cast(self, 60)
                        local d = 1
                        for a in sp.math.AngleIterator(ran:Float(0, 360), 8) do
                            servant.init(NewObject(servant), self.x, self.y, 0, 250, 128, 114, 1.5, function(unit)
                                unit.bound = false
                                task.New(unit, function()
                                    unit:FadeIn(15)
                                    object.ChangingSizeColli(unit, -0.5, -0.5, 15)
                                end)
                                task.New(unit, function()
                                    local off = -ran:Int(0, 40)
                                    task.BezierMoveTo(stage_lib.GetValue(170, 150, 130, 100) + off, 1,
                                            self.x + cos(a + 75 * d) * 100, self.y + sin(a + 75 * d) * 100, self.x, self.y)
                                    unit.vx = unit.dx
                                    unit.vy = unit.dy
                                    task.Wait(-off)
                                    task.New(unit, function()
                                        local v = stage_lib.GetValue(2, 2.4, 2.8, 7)
                                        for _ = 1, 7 do
                                            for _ = 1, 2 do

                                                Create.bullet_dec_acc(unit.x, unit.y, sty[ran:Int(1, 2)], 6,
                                                        ran:Float(v + 0.5, v + 1), ran:Float(v - 0.5, v + 0.5), ran:Float(0, 360), true, false)
                                            end
                                            for a1 in sp.math.AngleIterator(a, 6) do
                                                Create.bullet_decel(unit.x, unit.y, grain_b, 2, v * 2, v + 0.5, a1 + 15)
                                            end
                                            PlaySound("tan00", 0.05, 0, true)
                                            task.Wait(3)
                                        end
                                    end)
                                    task.Wait(beat * 2)
                                    object.ChangingSizeColli(unit, -1, -1, 15)
                                    Del(unit)
                                end)
                            end)
                        end
                        task.Wait(beat * 4)
                        d = -d
                    end
                end)
            end
            function sc:other_bonus_drop()
            end
            boss.Create(bclass)
        end, _t("滴滴滴"), nil, nil, true)
lib.NewWaveEventInWaves(class, 11, { 5, 10, 15 }, 1,
        0, 1, function()

            local bclass = boss.Define(name("Sagume"), -200, 400, _editor_class.sagume_bg, "Sagume")

            local non_sc = boss.card.New("", 1, 1, 35, HP(900))
            boss.card.add(bclass, non_sc)
            function non_sc:before()
                task.MoveToForce(0, 120, 60, 2)
            end
            function non_sc:init()
                task.New(self, function()
                    task.init_left_wait(self)
                    local beat = 3600 / 120
                    local d = 1
                    local _d = 1
                    while true do
                        task.New(self, function()
                            local W = {}
                            task.init_left_wait(W)
                            task.Wait2(W, beat)
                            for _ = 1, 4 do
                                local bv = stage_lib.GetValue(3, 4, 5, 18)
                                for a in sp.math.AngleIterator(ran:Float(0, 360), int(stage_lib.GetValue(6, 10, 17, 45))) do
                                    Create.bullet_decel(self.x, self.y, ball_huge, 4, bv * 1.3, bv, a)
                                end
                                PlaySound("kira00")
                                task.Wait2(W, beat)
                            end
                        end)
                        task.New(self, function()
                            task.MoveTo(90 * d, ran:Float(100, 144), 60, 2)
                        end)
                        task.New(self, function()
                            for k = 1, 45 do
                                for a in sp.math.AngleIterator(k * 9, 2) do
                                    local v1 = stage_lib.GetValue(7, 9, 11, 40)
                                    local v2 = stage_lib.GetValue(4, 5, 6, 20)
                                    local b = Create.bullet_dec_setangle(self.x, self.y, ball_mid, 6, false,
                                            { v = 7, a = a, time = 25 }, { func = function(self)
                                                bullet.ChangeImage(self, self.imgclass, 2)
                                                Create.bullet_create_eff(self)
                                                object.ChangeVwithTask(self, 0, v1, Angle(self, player), 75,
                                                        0, false, function(n)
                                                            return 1 - task.SetMode[4](1 - n)
                                                        end)
                                            end })
                                    b._blend = "mul+add"
                                    Create.bullet_dec_setangle(self.x, self.y, grain_b, 2, false,
                                            { v = 7, a = a, time = 25 }, { func = function(self)
                                                bullet.ChangeImage(self, self.imgclass, 6)
                                                Create.bullet_create_eff(self)
                                            end, v = v2 - k / 45, a = a + 45 * _d })
                                end
                                _d = -_d
                                task.Wait()
                            end
                        end)
                        task.Wait2(self, beat * 4)
                        d = -d
                    end

                end)
            end

            local sc = boss.card.New("鹭符「南天白鹭」", 2, 5, 40, HP(900))
            boss.card.add(bclass, sc)
            function sc:before()
                task.Wait(60)
            end
            function sc:init()
                task.New(self, function()
                    task.MoveToForce(0, 120, 60, 2)
                    Newcharge_in(self.x, self.y, 135, 206, 235)
                    task.Wait(60)
                    task.init_left_wait(self)
                    local beat = 3600 / stage_lib.GetValue(170, 280, 400, 2000)
                    task.New(self, function()
                        local W = {}
                        task.init_left_wait(W)
                        while true do
                            local n = int(beat * 8)
                            for k = 1, n do
                                if k % 2 == 1 then
                                    for d = -1, 1, 2 do
                                        local shootA = d * LineNum(k / n * 180) * 166 + Angle(self, player) + 180

                                        local R, G, B = sp:HSVtoRGB(k / 45 * 360, 1, 0.5)
                                        local l = ParticleLaserLine(R, G, B, self.x, self.y, 15, 14.5, shootA, 25, 19)
                                        l._blend = "add+add"
                                        l._r, l._g, l._b = R, G, B
                                        task.New(l, function()
                                            while true do
                                                local len = (l.l1 + l.l2 + l.l3) / 2
                                                local x, y = l.x + cos(l.rot) * len, l.y + sin(l.rot) * len
                                                local b = Create.bullet_accel(x, y, ball_mid, 15, 0.1, 16, shootA + 180)
                                                b._blend = "add+add"
                                                b._r, b._g, b._b = R, G, B
                                                b.wait = 0
                                                b.fogtime = 0
                                                task.New(b, function()
                                                    task.Wait(15)
                                                    b.colli = false
                                                    for i = 1, 30 do
                                                        b._a = 255 * (1 - i / 30)
                                                        task.Wait()
                                                    end
                                                    object.RawDel(b)
                                                end)
                                                task.Wait(3)
                                            end
                                        end)
                                    end
                                end
                                task.Wait()
                            end
                            task.Wait2_InFrac(W, beat * 8)
                        end
                    end)

                    local D = 1
                    task.New(self, function()
                        local d = 1
                        while true do
                            for k = 1, 45 do
                                for a in sp.math.AngleIterator(k * 9 * D, int(stage_lib.GetValue(1, 2, 3, 20))) do
                                    local b = Create.bullet_dec_setangle(self.x, self.y, arrow_big_c, 2, false,
                                            { v = 7, a = a, time = int(beat) }, { func = function(self)
                                                bullet.ChangeImage(self, self.imgclass, 6)
                                                Create.bullet_create_eff(self)
                                            end, v = stage_lib.GetValue(2, 2.5, 3.6, 13), a = a + 30 * d })
                                    b._blend = "mul+add"
                                end
                                d = -d
                                task.Wait()
                            end
                        end
                    end)
                    while true do
                        Newcharge_out(self.x, self.y, 250, 128, 114)
                        task.New(self, function()
                            local _d = -D
                            for k = 1, 45 do
                                for a in sp.math.AngleIterator(-k * 9 * D, 3) do
                                    local b = Create.bullet_dec_setangle(self.x, self.y, ball_mid, 6, false,
                                            { v = 7, a = a, time = 45 }, { func = function(self)
                                                bullet.ChangeImage(self, self.imgclass, 2)
                                                Create.bullet_create_eff(self)
                                                object.ChangeVwithTask(self, 0, 9, Angle(self, player), 75,
                                                        0, false, function(n)
                                                            return 1 - task.SetMode[4](1 - n)
                                                        end)
                                            end })
                                    b._blend = "mul+add"
                                end
                                _d = -_d
                                task.Wait()
                            end

                        end)
                        task.New(self, function()
                            task.MoveTo(95 * D, ran:Float(100, 144), 60, 2)
                        end)
                        task.Wait2(self, beat * 8)
                        D = -D
                    end

                end)
            end
            boss.Create(bclass)
        end, _t("哦，你是谁"), nil, nil, true)
lib.NewWaveEventInWaves(class, 12, { 2, 3, 4, 16, 17, 18, 19 }, 0,
        2, 2, function()
            local soul = Class(enemy, {
                init = function(self, x, y, v, a)
                    enemy.init(self, 27, HP(11), false, true, false, 1)
                    self.x, self.y = x, y
                    PlaySound("boon00")
                    Create.bullet_create_eff(self.x, self.y, ball_big, 2)
                    object.ChangeVwithTask(self, 0, v, a, 100, 0, false)
                    self.angle = a
                    task.New(self, function()
                        task.Wait(10)
                        local n = int(stage_lib.GetValue(0, 2, 4, 30))
                        local iv = stage_lib.GetValue(1.2, 1.5, 1.7, 7)
                        for aa in sp.math.AngleIterator(a, n) do
                            NewSimpleBullet(ball_mid, 2, self.x, self.y, iv, aa)
                        end
                    end)

                end,
            }, true)
            local d = 1
            local N = 36
            local A = 90
            for p = 1, 3 do
                for i = 1, N * 2.5 do
                    for a in sp.math.AngleIterator(A, p) do
                        New(soul, cos(a) * 270, sin(a) * 270, 5, a + 180 - i / N * 180)
                    end
                    A = A + 360 / N * d
                    task.Wait(p * 2)
                end
                A = ran:Float(0, 360)
                task.Wait(60)
            end
        end, _t("风魂轮"), nil, true)
lib.NewWaveEventInWaves(class, 13, { 1, 2, 3, 4, 18, 19 }, 1,
        0, 1, function()
            local enemy1 = Class(enemy, {
                init = function(self, x, y, vy1)
                    enemy.init(self, 1, HP(10), false, false, false, 3)
                    self.x, self.y = x, y
                    self.vy = vy1
                    task.New(self, function()
                        while self.y <= ran:Float(100, 200) do
                            local a = ran:Float(0, 360)
                            for _ = 1, 3 do
                                local b = NewSimpleBullet(arrow_big, 10, self.x, self.y, ran:Float(0.6, 0.8), a)
                                a = a + 60
                                task.New(b, function()
                                    while true do
                                        if IsValid(self) then
                                            task.Wait(ran:Float(15 * (3.3 - self.vy), 20 * (3.3 - self.vy)))
                                            Del(b)
                                        end
                                        task.Wait()
                                    end
                                end)
                            end
                            task.Wait(3)
                        end
                        self.auto_delete = true
                        self.vy = 0
                        local a = ran:Float(0, 360)
                        local i = stage_lib.GetValue(10, 30, 50, 100)
                        for _ = 1, i do
                            local v = stage_lib.GetValue(3, 2.5, 2, 0.8)
                            local b = NewSimpleBullet(ball_mid, 10, self.x, self.y, v, a)
                            b.ag = v * i / 6660
                            a = a + 360 / i
                            PlaySound("tan00")
                        end
                        task.Wait(60)
                        self.vx = ran:Sign() * 1.1
                    end)
                end,
            }, true)
            for _ = 1, 11 do
                local x = ran:Float(-280, -220)
                for _ = 1, 4 do
                    local vy = stage_lib.GetValue(2, 3, 4, 8)
                    New(enemy1, x, ran:Float(-350, -280), ran:Float(vy - 1, vy + 0.3))
                    x = x + 145 + ran:Float(-50, 40)
                end
                task.Wait(stage_lib.GetValue(110, 90, 70, 40))
            end
            task.Wait(30)
        end, _t("雨后春笋"))
lib.NewWaveEventInWaves(class, 14, { 5, 10, 15 }, 1,
        0, 1, function()
            local bclass = boss.Define(name("Whitelily"), 200, 400, _editor_class.seiran_bg, "Whitelily")
            local common = Class(bullet, { init = function(self, x, y, v, i, _, I, t, boss)
                bullet.init(self, ball_small, COLOR.PURPLE, true, true)
                self._blend, self._a, self._r, self._g, self._b = "", 255, 255, 255, 255
                self.x, self.y = x, y
                self.bound = false
                self.i = i
                self.bo = 1
                self.target = {}
                if self.i == 3 then
                    bullet.ChangeImage(self, ball_mid_c, COLOR.GRAY)
                end
                object.SetV(self, v, Angle(self, boss) + t * I * (2 - i), true)
                task.New(self, function()
                    for _, unit in ObjList(GROUP.INDES) do
                        if unit.co == COLOR.RED then
                            self.target.red = abs(unit.r)
                        elseif unit.co == COLOR.PURPLE then
                            self.target.purple = abs(unit.r)
                        else
                            self.target.gray = unit.r
                        end
                    end
                    local del = stage_lib.GetValue(0, 0, 0, 1)
                    while i ~= 3 do
                        if del == 0 then
                            self.hide = true
                            self.colli = false
                        end
                        if self.target.purple ~= nil then
                            if IsValid(boss) and Dist(self, boss) <= self.target.purple then
                                object.Del(self)
                            end
                        end
                        if self.timer == 120 then
                            object.Del(self)
                        end
                        task.Wait(1)
                    end
                    local d = 0
                    while true do
                        if self.timer == 120 then
                            self.bound = true
                        end
                        if IsValid(boss) then
                            d = Dist(self, boss)
                        end
                        if (self.target.red ~= nil and self.target.purple ~= nil) and self.target.gray ~= nil then
                            if self.bo == 1 and d <= self.target.purple then
                                bullet.ChangeImage(self, ball_mid_c, COLOR.PURPLE)
                                local ii = 1
                                for _ = 1, 2 do
                                    NewSimpleBullet(grain_a, COLOR.PURPLE, self.x, self.y, ii * 0.9, self.rot + I * 90)
                                    ii = -ii
                                end
                                self.bo = 2
                            elseif self.bo == 2 and d <= self.target.red then
                                bullet.ChangeImage(self, ball_mid_c, COLOR.RED)
                                object.SetV(self, 1.1, Angle(self, boss), false)
                                object.SetA(self, 0.0072, ran:Float(0.95, 1.05) * Angle(self, player))
                                self.bo = 4
                            elseif self.bo == 1 and d <= self.target.red then
                                bullet.ChangeImage(self, ball_mid_c, COLOR.RED)
                                for u = 1, 3 do
                                    local b = NewSimpleBullet(grain_a, COLOR.RED, self.x, self.y, 1.3 + u / 10, Angle(self, boss))
                                    b.bound = false
                                    task.New(b, function()
                                        task.Wait(120)
                                        b.bound = true
                                    end)
                                end
                                self.bo = 3
                            elseif self.bo == 3 and d <= self.target.purple then
                                bullet.ChangeImage(self, ball_mid_c, COLOR.PURPLE)
                                self.omega = ran:Float(-3, 3)
                                PlaySound("kira00")
                                object.SetV(self, 0.05, Angle(self, boss), true)
                                local where = stage_lib.GetValue(0, 0.01, 0.05, 0.1)
                                object.SetA(self, 0.03, ran:Float(1 - where, 1 + where) * Angle(self, player))
                                self.bo = 4
                            elseif self.bo == 4 then
                                break
                            end
                        end
                        task.Wait(1)
                    end
                    self.bound = true
                end)
            end }, true)

            local rice = Class(bullet, { init = function(self, x, y, a, R, co, mode, I, boss)
                bullet.init(self, heart, co, true, false)
                self._blend, self._a, self._r, self._g, self._b = "", 255, 255, 255, 255
                self.x, self.y = x, y
                self.bound = false
                self.rot = a + 90
                self.co = co
                self.r = 0
                task.New(self, function()
                    task.init_left_wait(self)
                    local n = 0
                    PlaySound("kira00")
                    for _ = 1, 56 do
                        a = a + 1
                        n = n + 90 / 56
                        self.r = R * sin(n)
                        self.x = boss.x + self.r * cos(a)
                        self.y = boss.y + self.r * sin(a)
                        self.rot = a + 180
                        task.Wait(1)
                    end
                    n = 90
                    local m, q = 0, 0
                    if self.co == COLOR.RED then
                        m, q = 0.13, 0.5
                    elseif self.co == COLOR.PURPLE then
                        m, q = -0.23, -1.6
                    else
                        m, q = 0.03, 0
                    end
                    task.New(self, function()
                        while true do
                            a = a + 1 + q
                            n = n + m
                            self.r = R * sin(n)
                            self.x = boss.x + self.r * cos(a)
                            self.y = boss.y + self.r * sin(a)
                            self.rot = a + 180
                            task.Wait(1)
                        end
                    end)
                    if mode then
                        local beat = stage_lib.GetValue(12, 11, 10, 1)
                        local A = 0
                        while true do
                            local av = 1
                            if I ~= 1 then
                                av = 2
                            end
                            local ag = ran:Float(0, 360)
                            local t = ran:Float(-1, 1)
                            A = A + 2
                            for i = 1, 5 do
                                av = av + I * 1 / 5
                                PlaySound("tan00")
                                New(common, self.x, self.y, av, i, ag, I, t, boss)
                                task.Wait(1)
                            end
                            task.Wait2(self, beat + abs(7 * sin(A)))
                        end
                    end
                end)
            end }, true)

            local non_sc = boss.card.New("", 1, 6, 40, HP(1100))
            boss.card.add(bclass, non_sc)

            function non_sc:before()
                task.MoveToForce(0, 100, 60, 2)
                Newcharge_in(self.x, self.y, 255, 152, 255)
            end
            function non_sc:init()
                task.New(self, function()
                    local num = int(stage_lib.GetValue(6, 8, 10, 28))
                    local r = stage_lib.GetValue(190, 200, 250, 400)
                    local i = 1
                    local a = 0
                    for _ = 1, 26 do
                        a = a + 360 / 26
                        New(rice, self.x, self.y, a, r - 30 * (num / 4), COLOR.RED, false, i, self)
                    end
                    for _ = 1, 28 do
                        a = a + 360 / 28
                        New(rice, self.x, self.y, a, r - 10 * (num / 4), COLOR.PURPLE, false, i, self)
                    end
                    for _ = 1, (num * 2) do
                        i = -i
                        a = a + 360 / (num * 2)
                        New(rice, self.x, self.y, a, r, COLOR.GRAY, true, i, self)
                    end
                end)
            end

            boss.Create(bclass)
        end, _t("樱花烂漫时"), nil, nil, true)
lib.NewWaveEventInWaves(class, 15, { 5, 10, 15 }, 1,
        0, 1, function()
            local bclass = boss.Define(name("Kogasa"), 0, 400, _editor_class.kogasa_bg, "Kogasa")
            local sc = boss.card.New("空轮「天边的雨色」", 1, 4, 50, HP(1200))
            boss.card.add(bclass, sc)
            local rain = Class(bullet, { init = function(self, x, y, co, vx, px, py)
                bullet.init(self, ball_small, co, true, true)
                self._blend, self._a, self._r, self._g, self._b = "", 255, 255, 255, 255
                self.x, self.y = x, y
                self.maxv = 3
                task.New(self, function()
                    while true do
                        self.x = self.x + player.dx / 26
                        self.y = self.y + player.dy / 7
                        task.Wait()
                    end
                end)
                if vx > -1 and vx < 1 then
                    vx = ran:Sign(1)
                end
                local beat = stage_lib.GetValue(1.8, 1.6, 1.4, 0.8)
                local x1, y1 = ran:Float(x - 150, x + 150) * beat, ran:Float(y - 60, y - 50)
                if x1 > -75 and x1 < 75 then
                    x1 = ran:Sign(75)
                end
                local t1, t2, ay1, ay2, ax2 = 0, 0, 0, 0, 0
                if x > x1 then
                    t1 = (x - x1) / vx
                else
                    t1 = (x1 - x) / vx
                end
                if y > y1 then
                    ay1 = (y1 - y) / (t1 ^ 2)
                else
                    ay1 = (y - y1) / (t1 ^ 2)
                end
                self.vx = vx
                self.ay = ay1
                task.New(self, function()
                    task.Wait(int(t1))
                    local x2, y2 = player.x + ran:Float(-px, px), player.y + ran:Float(py, 0)
                    if x > x2 then
                        t2 = (x - x2) / vx
                    else
                        t2 = (x2 - x) / vx
                    end
                    local vy = self.vy
                    if self.x > x2 then
                        ax2 = ((self.x - x2) - vx * t2) / (t2 ^ 2)
                    else
                        ax2 = ((x2 - self.x) - vx * t2) / (t2 ^ 2)
                    end
                    if self.y > y2 then
                        ay2 = ((y2 - self.y) - vy * t2) / (t2 ^ 2)
                    else
                        ay2 = ((self.y - y2) - vy * t2) / (t2 ^ 2)
                    end
                    self.ay = ay2
                    self.ax = ax2
                    task.Wait(ran:Int(60, 1200))
                    self.ay = 0.01
                end)
            end }, true)

            function sc:before()
                task.MoveToForce(0, 100, 60, 2)
            end
            function sc:init()
                task.New(self, function()
                    task.init_left_wait(self)
                    Newcharge_in(self.x, self.y, 0, 0, 255)
                    task.Wait(60)
                    task.New(self, function()
                        while true do
                            task.MoveToPlayer(60, -200, 200, 80, 120,
                                    20, 40, 10, 20, 2, 1)
                            task.Wait(stage_lib.GetValue(60, 50, 40, 10))
                            for a in sp.math.AngleIterator(Angle(self, player), int(stage_lib.GetValue(18, 24, 29, 66))) do
                                local v = stage_lib.GetValue(2, 2.1, 3, 5)
                                NewSimpleBullet(ball_big, COLOR.GRAY, self.x, self.y, v, a)
                                a = a + 360 / 25
                                PlaySound("kira00")
                            end
                            task.Wait()
                        end
                    end)
                    while true do
                        local beatt = stage_lib.GetValue(14, 11, 7, 2)
                        local beat = stage_lib.GetValue(1, 2, 2, 20)
                        for _ = 1, beat do
                            New(rain, self.x + ran:Float(-150, 150), self.y + ran:Float(-40, 70), COLOR.CYAN, ran:Float(-2.2, 2.2), 0, 0)
                            New(rain, self.x + ran:Float(-200, 200), self.y + ran:Float(-20, 120), COLOR.BLUE, ran:Float(-1.4, 1.4), 50, 0)
                            New(rain, self.x + ran:Float(-300, 300), self.y + ran:Float(-10, 140), COLOR.PURPLE, ran:Float(-1.6, 1.6), 0, -50)
                        end
                        PlaySound("tan00")
                        task.Wait2(self, beatt)
                    end
                end)
            end
            function sc:other_bonus_drop()
                activeItem_lib.DropActive(self.x, self.y, 15)
                mission_lib.GoMission(75)
            end
            boss.Create(bclass)
        end, _t("暮雨千世界"), nil, nil, true)
lib.NewWaveEventInWaves(class, 16, { 5, 10, 15 }, 1,
        0, 1, function()
            local bclass = boss.Define(name("Kogasa"), 0, 400, _editor_class.kogasa_bg, "Kogasa")
            local sc = boss.card.New("「Dancing Dreadful Diamond Drizzle Cyclone」", 1, 4, 50, HP(999))
            boss.card.add(bclass, sc)

            local heart_null = Class(enemy, {
                init = function(self, master, Master)
                    enemy.init(self, 1, HP(1), false, true, true, 0)
                    self.protect = false
                    self.hide = true
                    self.master = master
                    self.Master = Master
                    object.Connect(Master, self, 0.16, true)
                    task.New(self, function()
                        while IsValid(master) do
                            self.x = master.x
                            self.y = master.y
                            task.Wait()
                        end
                        Del(self)
                    end)
                end,
                kill = function(self)
                    enemy.kill(self)
                    if self.Master.rank >= 10 then
                        self.Master.rank = self.Master.rank - 0.33
                    end
                    if IsValid(self.master) then
                        Del(self.master)
                    end
                end }, true)

            local rain = Class(bullet, { init = function(self, x, y, co, style, v, rot, a, I, com, master)
                local s = { ellipse, diamond, grain_a, heart }
                if s[style] == heart then
                    self.group = GROUP.INDES
                    local ch = ran:Sign()
                    if ch == 1 then
                        co = COLOR.PURPLE
                    else
                        co = COLOR.RED
                    end
                end
                bullet.init(self, s[style], co, true, true)
                self._blend, self._a, self._r, self._g, self._b = "", 255, 255 * com, 255, 255
                self.x, self.y = x, y
                self.navi = true
                task.New(self, function()
                    local i = 90
                    if s[style] == heart then
                        self._blend, self._a, self._g, self._b = "mul+add", 240, 180, 180
                        New(heart_null, self, master)
                        local ch = ran:Sign()
                        if ch == 1 then
                            self.layer = self.layer + 1
                        end
                    end
                    for _ = 1, 135 do
                        i = i + 1.34 * I
                        self.ax = a * I * cos(rot + i)
                        self.ay = a * I * sin(rot + i)
                        task.Wait()
                    end
                end)
                SetV(self, v, rot, true)
            end }, true)

            function sc:before()
                task.MoveToForce(0, 0, 60, 2)
            end
            function sc:init()
                task.New(self, function()
                    task.init_left_wait(self)
                    Newcharge_in(self.x, self.y, 0, 0, 255)
                    task.Wait(60)
                    self.rank = 120
                    local I = 1
                    while true do
                        task.New(self, function()
                            local way = stage_lib.GetValue(6, 8, 10, 12)
                            local I = I
                            local angle = ran:Float(0, 360)
                            local style = 1
                            for s = 1, 5 + math.ceil(self.rank) do
                                angle = angle + 0.04
                                if s % 7 == 0 then
                                    style = ran:Int(1, 4)
                                else
                                    style = ran:Int(1, 3)
                                end
                                for _ = 1, way do
                                    local com = ran:Float(0.91, 1)
                                    New(rain, self.x + ran:Float(-10, 10), self.y + ran:Float(-10, 10), COLOR.BLUE, style, 1, angle + ran:Float(-12 + 0.8 * way, 12 - 0.8 * way), 0.04, I, com, self)
                                    angle = angle + 360 / math.floor(way)
                                    PlaySound("tan00")
                                end
                                task.Wait()
                            end
                        end)
                        task.Wait(math.ceil(self.rank))
                        self.y = 120 - math.ceil(self.rank)
                        I = -I
                        PlaySound("water")
                    end
                end)
            end
            function sc:other_drop()
                if ran:Float(0, 1) < 0.5 then
                    item.dropItem(item.drop_card, 1, self.x, self.y + 30, 159)
                end
            end
            boss.Create(bclass)
        end, _t("爱之列车"), nil, nil, true)
lib.NewWaveEventInWaves(class, 17, { 7, 8, 9, 11, 16, 18 }, 1,
        0, 1, function()
            local enemy1 = Class(enemy, {
                init = function(self, x, y, vx, vy, ay)
                    enemy.init(self, 14, HP(38), false, true, false, 7)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx, vy
                    self.ay = ay
                    task.New(self, function()
                        local k = ran:Int(1, 12)
                        local kg = 6
                        while true do
                            local v = stage_lib.GetValue(4, 5, 6, 12)
                            local A = Angle(0, 0, self.dx, self.dy)
                            for a in sp.math.AngleIterator(A, 7) do
                                Create.bullet_changeangle(self.x, self.y, arrow_big_c, 4, v, a,
                                        { wait = 0, r = sign(vx) * (0.3 - 0.2 * (k % kg) / kg), time = 100, v = v * 0.4 })
                            end
                            PlaySound("tan00")

                            task.Wait(2)
                            k = k + 1

                        end
                    end)
                end,
            }, true)
            local enemy2 = Class(enemy, {
                init = function(self, x, y, vx, vy, ay)
                    enemy.init(self, 9, HP(50), false, true, false, 7)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx, vy
                    self.ay = ay
                    task.New(self, function()
                        local k = ran:Int(1, 12)
                        local kg = 6
                        while true do
                            local v = stage_lib.GetValue(3, 4, 5, 12)
                            local A = Angle(0, 0, self.dx, self.dy)
                            for a in sp.math.AngleIterator(A, 5) do
                                Create.bullet_changeangle(self.x, self.y, arrow_big_c, 2, v, a,
                                        { wait = 0, r = sign(vx) * (0.6 - 0.3 * (k % kg) / kg), time = 100, v = v * 0.4 })
                            end
                            PlaySound("tan00")

                            task.Wait(2)
                            k = k + 1

                        end
                    end)
                end,
            }, true)
            local t = stage_lib.GetValue(100, 90, 86, 80)
            for _ = 1, 4 do
                for d = -1, 1, 2 do
                    New(enemy1, d * 380, 250, -3 * d, -4, 0.04)
                    task.Wait(t)

                end
                t = t - 20
            end
            t = stage_lib.GetValue(120, 110, 106, 100)
            task.Wait(70)
            for _ = 1, 3 do
                for d = -1, 1, 2 do
                    New(enemy2, d * 380, -230, -3 * d, 4.5, -0.05)
                    task.Wait(t)

                end
                t = t - 10
            end
        end, _t("恶语伤人六月寒"))
lib.NewWaveEventInWaves(class, 18, { 1, 3, 13, 14, 18 }, 1,
        0, 1, function()
            local enemy1 = Class(enemy, {
                init = function(self, x, y, vx1, vy1, vx2, vy2)
                    enemy.init(self, 4, HP(10), false, false, false, 1)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx1, vy1
                    task.New(self, function()
                        task.Wait(ran:Int(35, 120))
                        if lstg.var.chaos > 25 then
                            for _ = 1, 3 do
                                for z = -1, 1 do
                                    Create.bullet_decel(self.x, self.y, grain_a, 14, 4,
                                            stage_lib.GetValue(2, 3, 4, 18), Angle(self, player) + z * 3)
                                end
                                PlaySound("tan00")
                                local t = int(stage_lib.GetValue(100, 30, 10, 2))
                                task.Wait(t)
                            end
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
                init = function(self, x, y, mx, my, vx, vy)
                    enemy.init(self, 9, HP(69), false, true, false, 12)
                    self.x, self.y = x, y
                    task.New(self, function()
                        task.MoveTo(mx, my, 60, 2)
                        task.New(self, function()
                            local d = 1

                            for _ = 1, int(stage_lib.GetValue(6, 15, 20, 50)) do
                                local A = Angle(self, player)
                                for a in sp.math.AngleIterator(A, 6) do
                                    local p = int(stage_lib.GetValue(6, 8, 12, 40))
                                    for m = 0, p do
                                        local v = stage_lib.GetValue(5, 6, 7, 18) * (1 - m / p * 0.4)
                                        Create.bullet_decel(self.x, self.y, arrow_big_c, 2, v, v * 0.6, a + m * min(2, 25 / p) * d)
                                    end
                                end
                                PlaySound("tan00")
                                d = -d
                                task.Wait(int(stage_lib.GetValue(38, 30, 24, 10)))
                            end
                        end)
                        task.Wait(180)
                        for i = 1, 60 do
                            self.vx = i / 60 * vx
                            self.vy = i / 60 * vy
                            task.Wait()
                        end
                    end)
                end,
            }, true)
            for _ = 1, 16 do
                New(enemy1, 356, ran:Float(140, 180), -1, -0.2, ran:Float(-1.9, -2.2), ran:Float(-0.1, -0.2))
                task.Wait(12)
            end
            task.Wait(30)
            for _ = 1, 16 do
                New(enemy1, -356, ran:Float(140, 180), 1, -0.2, ran:Float(1.9, 2.2), ran:Float(-0.1, -0.2))
                task.Wait(12)
            end
            task.Wait(30)
            local x = ran:Float(75, 150)
            New(enemy2, -x, 300, -x, 150, 0, -1)
            for _ = 1, 16 do
                New(enemy1, 356, ran:Float(70, 100), -1, -0.2, ran:Float(-1.9, -2.2), ran:Float(-0.1, -0.2))
                task.Wait(12)
            end
            task.Wait(30)
            New(enemy2, x, 300, x, 150, 0, -1)
            for _ = 1, 16 do
                New(enemy1, -356, ran:Float(70, 100), 1, -0.2, ran:Float(1.9, 2.2), ran:Float(-0.1, -0.2))
                task.Wait(12)
            end
            task.Wait(30)
        end, _t("我去是"))
lib.NewWaveEventInWaves(class, 19, { 11, 12, 13, 14, 16, }, 1,
        0, 1, function()
            local soul = Class(enemy, {
                init = function(self, x, y, a, o, r)
                    enemy.init(self, 28, HP(12), false, true, false, 1.5)

                    self.x, self.y = x + cos(a) * r, y + sin(a) * r
                    Create.bullet_create_eff(self.x, self.y, ball_big, 6)
                    task.New(self, function()
                        task.New(self, function()
                            task.Wait(120)
                            local t = 1
                            local R = r
                            self.bound = true
                            while true do
                                r = r + R / 100 * sin(min(t, 90))
                                t = t + 1
                                task.Wait()
                            end
                        end)
                        local t = 1
                        local interval = int(stage_lib.GetValue(39, 35, 30, 10))

                        while true do
                            self.x = x + cos(a) * r
                            self.y = y + sin(a) * r
                            if self.timer % interval == 0 and self.timer > interval and self.timer < interval * 5 then
                                Create.bullet_decel(self.x, self.y, ball_mid, 6, 4,
                                        stage_lib.GetValue(2, 2.6, 3.6, 17), Angle(self, player))
                                PlaySound("tan00")
                            end
                            a = a + o * sin(min(t, 90))

                            t = t + 1
                            task.Wait()
                        end

                    end)
                end,
            }, true)
            for _ = 1, stage_lib.GetValue(4, 5, 5, 18) do
                local x, y = ran:Float(-250, 250), ran:Float(100, 200)
                local d = ran:Sign()
                local rot = ran:Float(0, 360)
                local N = int(stage_lib.GetValue(4, 8, 12, 48))
                for r = 1, N do
                    local R = 30 + r * min(33, 330 / N)
                    for a in sp.math.AngleIterator(rot, int(stage_lib.GetValue(6, 8, 8, 36))) do
                        if Dist(player, x + cos(a) * R, y + sin(a) * R) > 40 then
                            New(soul, x, y, a, d * 0.4, R)

                        end
                    end
                    d = -d
                    task.Wait(stage_lib.GetValue(12, 10, 8, 2))
                end
                task.Wait(stage_lib.GetValue(300, 250, 230, 122))
            end
        end, _t("洱濡沐染"))



