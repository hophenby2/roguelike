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

lib.NewWaveEventInWaves(class, 1, { 1, 2, 3, 4, }, 1,
        0, 1, function(var)
            local enemy1 = Class(enemy, {
                init = function(self, x, y, vx1, vy1, vx2, vy2)
                    enemy.init(self, 3, HP(10), false, false, false, 1)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx1, vy1
                    task.New(self, function()
                        task.Wait(ran:Int(35, 125))
                        while true do
                            Create.bullet_decel(self.x, self.y, ball_mid, 6, 4,
                                    stage_lib.GetValue(1, 4, 5, 18), Angle(self, player))
                            PlaySound("tan00")
                            local t = int(stage_lib.GetValue(100, 30, 10, 2))
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
                init = function(self, x, y, mx, my, vx, vy)
                    enemy.init(self, 9, HP(75), false, true, false, 12)
                    self.x, self.y = x, y
                    task.New(self, function()
                        task.MoveTo(mx, my, 60, 2)
                        task.New(self, function()
                            local sty = ({ ball_mid, ball_big, ball_huge })[stage_lib.GetValue()]
                            for _ = 1, int(stage_lib.GetValue(3, 6, 9, 36)) do
                                for a in sp.math.AngleIterator(ran:Float(0, 360), 20) do
                                    Create.bullet_decel(self.x, self.y, sty, 2,
                                            stage_lib.GetValue(3, 5, 6, 10),
                                            stage_lib.GetValue(2, 3.5, 4.6, 8), a)
                                end
                                PlaySound("tan00")
                                task.Wait(int(stage_lib.GetValue(70, 40, 20, 3)))
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
            New(enemy2, -100, 300, -100, 150, 0, -1)
            for _ = 1, 16 do
                New(enemy1, 356, ran:Float(70, 100), -1, -0.2, ran:Float(-1.9, -2.2), ran:Float(-0.1, -0.2))
                task.Wait(12)
            end
            task.Wait(30)
            New(enemy2, 100, 300, 100, 150, 0, -1)
            for _ = 1, 16 do
                New(enemy1, -356, ran:Float(70, 100), 1, -0.2, ran:Float(1.9, 2.2), ran:Float(-0.1, -0.2))
                task.Wait(12)
            end
            task.Wait(30)
        end, _t("左右逢源"))
lib.NewWaveEventInWaves(class, 2, { 2, 3 }, 1,
        0, 1, function(var)
            local stg = stage.current_stage
            local enemy1 = Class(enemy, {
                init = function(self, x, y, vx1, vy1)
                    enemy.init(self, 32, HP(6), false, true, false, 0.7)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx1, vy1
                    task.New(self, function()
                        if var.chaos >= 50 then
                            task.Wait(ran:Int(35, 125))
                            for _ = 1, stage_lib.GetValue(5, 15, 40, 100) do
                                Create.bullet_accel(self.x, self.y, ball_mid, 6, 0.3,
                                        stage_lib.GetValue(2, 3, 4, 10), -90)
                                PlaySound("tan00")
                                task.Wait(int(stage_lib.GetValue(70, 40, 10, 1)))
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
                init = function(self, x, y, vx, vy, d)
                    enemy.init(self, 8, HP(56), false, true, false, 8)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx, vy
                    task.New(self, function()
                        task.Wait(ran:Int(40, 120))
                        for r = 1, 15 do
                            for a in sp.math.AngleIterator(r * d * 25, int(stage_lib.GetValue(4, 6, 10, 36))) do
                                Create.bullet_accel(self.x, self.y, arrow_big_c, 2, 1 + var.chaos / 100, min(6, 3 + var.chaos / 100 * 1.5), a)
                            end
                            PlaySound("tan00")
                            task.Wait(int(stage_lib.GetValue(20, 15, 7, 2)))
                        end
                    end)
                end,
            }, true)
            task.New(stg, function()
                for _ = 1, 4 do
                    for d = -1, 1, 2 do
                        New(enemy2, 356 * d, ran:Float(140, 180), -1.3 * d, -0.2, d)
                    end
                    task.Wait(230)
                end
            end)
            for k = 1, 60 do
                New(enemy1, ran:Float(-320, 320), 300, ran:Float(-0.2, 0.2), -1)
                task.Wait(15 - k / 60 * 6)
            end

            task.Wait(30)

            task.Wait(30)
        end, _t("减速慢行"))
lib.NewWaveEventInWaves(class, 3, { 3, 4 }, 1,
        0, 1, function(var)
            local diff = var.difficulty
            local stg = stage.current_stage
            local enemy1 = Class(enemy, {
                init = function(self, cx, cy, a, o, r)
                    enemy.init(self, 26, HP(30), false, false, false, 8)
                    self.x, self.y = cx + cos(a) * r, cy + sin(a) * r
                    self.omega = o * 2
                    task.New(self, function()
                        while true do
                            for A in sp.math.AngleIterator(a, int(stage_lib.GetValue(3, 4, 5, 18))) do
                                for v = 1, int(stage_lib.GetValue(3, 4, 5, 6)) do
                                    Create.bullet_accel(self.x + cos(A) * 18, self.y + sin(A) * 18, grain_a, 4,
                                            0.3, min(6, 2 + var.chaos / 80 * 1.6) + v * 0.3, A, false, false)
                                end
                            end
                            PlaySound("tan00")
                            task.Wait(int(stage_lib.GetValue(10, 8, 7, 2)))
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
            local enemy2 = Class(enemy, {
                drop = function(self)
                    New(bullet_cleaner, self.x, self.y, 20, 10, 10, true, false, 0)
                end,
                init = function(self, cx, cy, a, o, r)
                    enemy.init(self, 31, HP(4), false, false, false, 0.8)
                    self.x, self.y = cx + cos(a) * r, cy + sin(a) * r
                    self.omega = o * 2
                    task.New(self, function()
                        while true do
                            Create.bullet_accel(self.x, self.y, ellipse, 2, 0.3,
                                    stage_lib.GetValue(2, 3, 4.5, 10), -90)
                            PlaySound("tan00")
                            task.Wait(stage_lib.GetValue(18, 12, 8, 2))
                        end

                    end)
                    task.New(self, function()
                        for _ = 1, abs(190 / o) do
                            a = a + o
                            self.x, self.y = cx + cos(a) * r, cy + sin(a) * r
                            task.Wait()
                        end
                        object.RawDel(self)
                    end)
                end,
            }, true)
            task.New(stg, function()
                for k = 1, 4 do
                    for d = -1, 1, 2 do
                        New(enemy1, 320 * d, 240, -90 + 10 * d, -d * 0.65, 200 + k * 20)
                    end
                    task.Wait(230 - diff * 32)
                end
            end)
            task.Wait(100)
            for d = -1, 1, 2 do
                for k = 1, 23 do
                    New(enemy2, 0, 240, 90 + 80 * d, d, 100 + k * 7)
                    task.Wait(13)
                end
            end
            task.Wait(90)
            for k = 1, 23 do
                for d = -1, 1, 2 do
                    New(enemy2, 0, 240, 90 + 80 * d, d, 300 - k * 7)
                end
                task.Wait(13)
            end

        end, _t("这是摩天轮吧"))
lib.NewWaveEventInWaves(class, 4, { 2, 4 }, 1,
        0, 1, function(var)
            local diff = var.difficulty
            local stg = stage.current_stage
            local enemy1 = Class(enemy, {
                init = function(self, x, y, vx1, vy1, vx2, vy2)
                    enemy.init(self, 6, HP(6), false, false, false, 1)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx1, vy1
                    task.New(self, function()
                        if var.chaos >= 50 then
                            task.Wait(ran:Int(35, 125))
                            while true do
                                Create.bullet_decel(self.x, self.y, ball_mid_c, 2, 4, min(8, 2 + var.chaos / 50), Angle(self, player))
                                PlaySound("tan00")
                                task.Wait(stage_lib.GetValue(100, 50, 10, 2))
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
                    enemy.init(self, 14, HP(120), false, true, false, 20)
                    self.x, self.y = x, y
                    task.New(self, function()
                        task.MoveTo(mx, my, 60, 2)
                        task.New(self, function()
                            for _ = 1, 3 do
                                for _ = 1, 3 do
                                    for a in sp.math.AngleIterator(Angle(self, player), int(stage_lib.GetValue(14, 18, 22, 72))) do
                                        Create.bullet_decel(self.x, self.y, ball_big, 2, 3 + var.chaos / 80, 2 + var.chaos / 80, a)
                                    end
                                    PlaySound("tan00")
                                    task.Wait(max(4, 20 - var.chaos / 75 * 8))
                                end
                                for a in sp.math.AngleIterator(Angle(self, player), int(stage_lib.GetValue(26, 32, 45, 100))) do
                                    Create.bullet_decel(self.x, self.y, ball_mid, 4,
                                            3 + var.chaos / 100, min(10, 1 + var.chaos / 80), a)
                                end
                                PlaySound("tan00")
                                task.Wait(stage_lib.GetValue(90, 60, 40, 13))
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
            for _ = 1, 3 do
                task.New(stg, function()
                    for _ = 1, 15 do
                        New(enemy1, 356 * d, ran:Float(-100, -180), -4 * d, 0.2, ran:Float(-0.5, 0.5), ran:Float(2, 3))
                        task.Wait(7)
                    end
                    for _ = 1, 15 do
                        New(enemy1, -356 * d, ran:Float(-100, -180), 4 * d, 0.2, ran:Float(-0.5, 0.5), ran:Float(2, 3))
                        task.Wait(7)
                    end
                end)
                task.Wait(60)
                New(enemy2, 0, 300, 0, 150, -1.5 * d, 0)
                task.Wait(180)
                task.Wait(75)
                d = -d
            end
            task.Wait(60)
            New(enemy2, -100, 300, -100, 120, -0.78, 0)
            New(enemy2, 100, 300, 100, 120, 0.78, 0)

        end, _t("趁虚而入"))
lib.NewWaveEventInWaves(class, 5, { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 }, 0.03,
        0, 0.4, function()
            local enemy1 = Class(enemy, {
                init = function(self, x, y, vx1, vy1)
                    enemy.init(self, 21, HP(3), false, false, true, 1)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx1, vy1
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
            for r = 1, 52 do
                for a in sp.math.AngleIterator(90 + r * 17, 4) do
                    New(enemy1, cos(a) * 500, sin(a) * 500, cos(a + 180) * 2, sin(a + 180) * 2)
                end
                task.Wait(8)
            end
            task.Wait(60)
        end, _t("万毛筒"), true)
lib.NewWaveEventInWaves(class, 6, { 5, 10 }, 3,
        0, 1, function(var)

            local bclass = boss.Define(name("Chiruno"), 0, 400, _editor_class.ice_bg, "Chiruno")

            local non_sc = boss.card.New("", 1, 2.5, 25, HP(920))
            boss.card.add(bclass, non_sc)
            function non_sc:before()
                task.MoveToForce(0, 160, 60, 2)
            end
            function non_sc:init()
                task.New(self, function()
                    Newcharge_in(self.x, self.y, 135, 206, 235)
                    task.Wait(60)
                    local D = 1
                    while true do
                        for _ = 1, 2 do
                            for a in sp.math.AngleIterator(ran:Float(0, 360), int(stage_lib.GetValue(20, 26, 30, 80))) do
                                Create.bullet_dec_acc(self.x, self.y, ball_big, 8, 3 + var.chaos / 100 * 2,
                                        4 + var.chaos / 100 * 2, a, false, false)
                            end
                            PlaySound("tan00")
                            task.Wait(int(stage_lib.GetValue(45, 35, 25, 8)))
                        end
                        local d = D
                        for t = 1, 4 do
                            task.MoveTo(d * 75, 160 - t * 50, max(25 - var.chaos / 50 * 10, 15), 2)
                            for a in sp.math.AngleIterator(ran:Float(0, 360), int(stage_lib.GetValue(12, 20, 26, 90))) do
                                if var.chaos >= 100 then
                                    Create.bullet_dec_acc(self.x, self.y, ball_mid, 6, 2, 0.3, a, false, false)
                                end
                                Create.bullet_dec_acc(self.x, self.y, ball_mid, 8, 3,
                                        stage_lib.GetValue(1, 1.5, 2, 8), a, false, false)
                            end
                            d = -d
                            PlaySound("tan00")
                        end
                        task.New(self, function()
                            task.MoveTo(0, 160, 160, 3)
                        end)
                        local w = clamp(10 + var.chaos / 10, 10, 30)
                        for i = 1, w do
                            for a in sp.math.AngleIterator(-90, int(stage_lib.GetValue(15, 21, 27, 96))) do
                                Create.bullet_changeangle(self.x, self.y, grain_a, 6, stage_lib.GetValue(1.5, 2.5, 3, 9), a, false,
                                        { r = (-1 + i / (w + var.chaos / 60) * (2 + var.chaos / 100)) * D,
                                          time = 90 - i * 2, v = var.chaos / 100 * 0.5 + 1 + i / 20 * 2 })
                            end
                            PlaySound("tan00")
                            task.Wait(max(1, 160 / w))
                        end
                        D = -D
                    end


                end)
            end

            local sc = boss.card.New("冰符「纸上谈冰」", 1, 3, 32, HP(1000))
            boss.card.add(bclass, sc)
            function sc:before()
                task.Wait(60)
            end
            function sc:init()
                task.New(self, function()
                    Newcharge_in(0, 100, 135, 206, 235)
                    task.MoveToForce(0, 100, 60, 2)
                    task.New(self, function()
                        local rot = -135
                        local m = 23
                        while true do
                            servant.init(NewObject(servant), self.x, self.y, 0, 135, 206, 235, 1.5, function(unit)
                                task.New(unit, function()
                                    unit:FadeIn(15)
                                    object.ChangingSizeColli(unit, -0.5, -0.5, 15)
                                end)
                                task.New(unit, function()
                                    task.MoveTo(unit.x + cos(rot) * 150, unit.y + sin(rot) * 100, 60, 2)
                                    for a in sp.math.AngleIterator(-90, 9) do
                                        Create.laser_line(unit.x, unit.y, 6, 4 + 1 / m * 8 + var.chaos / 45,
                                                a, 12 + 1 / m * 30, 8, 8)
                                    end
                                    task.Wait(20)
                                    object.ChangingSizeColli(unit, -1, -1, 15)
                                    Del(unit)
                                end)
                            end)
                            rot = rot + 27
                            m = max(5, m - var.chaos / 50 * 2 - 1)
                            task.Wait(m)
                        end
                    end)
                    task.Wait(120)
                    local rot = -45
                    local m = 23
                    while true do
                        servant.init(NewObject(servant), self.x, self.y, 0, 100, 100, 255, 1.5, function(unit)
                            task.New(unit, function()
                                unit:FadeIn(15)
                                object.ChangingSizeColli(unit, -0.5, -0.5, 15)
                            end)
                            task.New(unit, function()
                                task.MoveTo(unit.x + cos(rot) * 300, unit.y + sin(rot) * 160, 60, 2)
                                if var.chaos >= 50 then
                                    for a in sp.math.AngleIterator(Angle(unit, player), int(stage_lib.GetValue(0, 10, 15, 60))) do
                                        Create.bullet_decel(unit.x, unit.y, grain_a, 8, 6, 2.5 + var.chaos / 75, a, false, false)
                                    end
                                end
                                task.Wait(20)
                                object.ChangingSizeColli(unit, -1, -1, 15)
                                Del(unit)
                            end)
                        end)
                        rot = rot - 27
                        m = max(6, m - var.chaos / 25 * 2 - 1)
                        task.Wait(m)
                    end


                end)
            end
            function sc:other_drop()
                if ran:Float(0, 1) < 0.5 then
                    item.dropItem(item.drop_card, 1, self.x, self.y + 30, 24)
                end
                mission_lib.GoMission(15)
            end
            boss.Create(bclass)
        end, _t("压死，管上"), nil, nil, true)
lib.NewWaveEventInWaves(class, 7, { 6, 7, 8 }, 1,
        0, 1, function(var)
            local stg = stage.current_stage
            local follow_enemy1 = Class(enemy, {
                init = function(self, master, a, o, r)
                    enemy.init(self, 28, HP(6), false, false, false, 0.4)
                    object.Connect(master, self, 0.2, true)
                    self.x = master.x + cos(a) * r
                    self.y = master.y + sin(a) * r
                    task.New(self, function()
                        while IsValid(master) do
                            self.x = master.x + cos(a) * r
                            self.y = master.y + sin(a) * r
                            a = a + o
                            task.Wait()
                        end
                        Del(self)
                    end)
                    task.New(self, function()
                        task.Wait(20)
                        while true do
                            local v = stage_lib.GetValue(2.5, 3, 3.8, 10)
                            Create.bullet_accel(self.x, self.y, ellipse, 6, v * 0.7,
                                    v, a, nil, false)
                            PlaySound("tan00")
                            task.Wait(int(stage_lib.GetValue(45, 25, 10, 2)))
                        end
                    end)
                end
            }, true)
            local enemy1 = Class(enemy, {
                init = function(self, x, y, vx1, vy1, so)
                    enemy.init(self, 7, HP(95), false, false, false, 10)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx1, vy1
                    for a in sp.math.AngleIterator(ran:Float(0, 360), int(stage_lib.GetValue(11, 15, 19, 50))) do
                        New(follow_enemy1, self, a, so, 80)
                    end
                    task.New(self, function()
                        task.Wait(200)
                        for i = 1, 36 do
                            self.vx = vx1 + vx1 * (i / 36)
                            self.vy = vy1 + vy1 * (i / 36)
                            task.Wait()
                        end
                        while Dist(self, 0, 0) < 500 do
                            task.Wait()
                        end
                        Del(self)
                    end)
                end,
            }, true)
            local enemy2 = Class(enemy, {
                init = function(self, x, y, mx, my, vx, vy)
                    enemy.init(self, 18, HP(11), false, true, false, 1)
                    self.x, self.y = x, y
                    task.New(self, function()
                        if var.chaos >= 50 then
                            task.Wait(ran:Int(35, 125))
                            while true do
                                for z = -1, 1 do
                                    Create.bullet_decel(self.x, self.y, ball_mid, 4, 4,
                                            min(9, 2 + var.chaos / 100 * 1.8), Angle(self, player) + z * 2)
                                end
                                PlaySound("tan00")
                                task.Wait(int(stage_lib.GetValue(125, 56, 10, 3)))
                            end
                        end
                    end)
                    task.New(self, function()
                        task.MoveTo(mx, my, 75, 2)

                        for i = 1, 60 do
                            self.vx = i / 60 * vx
                            self.vy = i / 60 * vy
                            task.Wait()
                        end
                    end)
                end,
            }, true)
            task.New(stg, function()
                task.Wait(90)

                for _ = 1, 4 do
                    for _ = 1, 9 do
                        local x = ran:Float(-240, 240)
                        New(enemy2, x, 270, x + ran:Float(-60, 60), ran:Float(100, 160), ran:Sign() * ran:Float(1, 2), 0)
                        task.Wait(12)
                    end
                    task.Wait(90)

                end
            end)
            for _ = 1, 2 do
                for d = -1, 1, 2 do
                    New(enemy1, -420 * d, 200, 1 * d, -0.3, 1.3 * d)
                    task.Wait(120)
                end
                task.Wait(120)
            end
            task.Wait(120)
            for d = -1, 1, 2 do
                New(enemy1, -320 * d, -450, 0.35 * d, 1.5, -0.7 * d)
                task.Wait(120)
            end
        end, _t("掉队的同源染色体"))
lib.NewWaveEventInWaves(class, 8, { 6, 8, 9 }, 0,
        2, 2, function(var)
            local stg = stage.current_stage
            local maxexp = 100
            local enemy1 = Class(enemy, {
                init = function(self, x, y, mx, my, vx, vy)
                    enemy.init(self, 5, HP(8), false, true, false, 1)
                    self.x, self.y = x, y
                    task.New(self, function()
                        task.MoveTo(mx, my, 75, 2)
                        task.New(self, function()
                            for _ = 1, 2 do
                                for z = -1, 1 do
                                    Create.bullet_decel(self.x, self.y, ellipse, 6, 5,
                                            stage_lib.GetValue(3, 3.5, 4, 10),
                                            Angle(self, player) + z * 2, false, false)
                                end
                                task.Wait(int(stage_lib.GetValue(250, 120, 80, 20)))
                            end
                        end)

                        for i = 1, 60 do
                            self.vx = i / 60 * vx
                            self.vy = i / 60 * vy
                            task.Wait()
                        end
                    end)
                end,
            }, true)
            local ball = Class(enemy, {
                init = function(self, x, y, D, dx, dy, time, wait)
                    enemy.init(self, 24, HP(60),
                            false, true, false, min(5, maxexp))
                    self.x, self.y = x, y
                    task.New(self, function()
                        while true do
                            task.MoveToEx(dx * D, dy, time, 3)
                            task.Wait(wait)
                            D = -D
                        end
                    end)
                end,
                kill = function(self)
                    maxexp = max(0, maxexp - 5)--限制能获得的exp
                    self.drop_exps = min(maxexp, 5)
                    enemy.kill(self)
                    for a in sp.math.AngleIterator(ran:Float(0, 360), int(stage_lib.GetValue(10, 25, 35, 100))) do
                        if var.chaos >= 100 then
                            Create.bullet_accel(self.x, self.y, ball_mid_c, 10, 0.6, 0.7, a, false, false)
                        end
                        Create.bullet_accel(self.x, self.y, ball_mid_c, 10, 0.6 + var.chaos / 100,
                                min(10, 2 + var.chaos / 100 * 2), a, false, false)
                    end
                end
            }, true)
            task.New(stg, function()
                task.Wait(75)
                for _ = 1, 9 do
                    for c = -3, 3 do
                        New(ball, c * 100, 280, 1, 50, -60, 60, 30)
                    end
                    task.Wait(90)
                end
            end)
            for _ = 1, 2 do
                for d = -1, 1, 2 do
                    for y = -9, 9 do
                        New(enemy1, -400 * d, y * 24, -ran:Float(260, 280) * d, y * 24, 0, 1.5)
                        task.Wait(3)
                    end
                    task.Wait(90)
                end
                task.Wait(120)
            end
            for d = -1, 1, 2 do
                for y = -9, 9 do
                    New(enemy1, -400 * d, y * 24, -ran:Float(260, 280) * d, y * 24, ran:Float(1.5, 1.9) * d, -y * 0.1)
                    task.Wait(3)
                end
                task.Wait(90)
            end

        end, _t("寸步难行"), nil, true)
lib.NewWaveEventInWaves(class, 9, { 6, 7, 9 }, 1,
        0, 1, function(var)

            local stg = stage.current_stage
            local rain_enemy = Class(enemy, {
                init = function(self, x, y, vx1, vy1, A)
                    enemy.init(self, 10, HP(9), false, true, false, 0.7)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx1, vy1
                    task.New(self, function()
                        while true do
                            local b = NewSimpleBullet(grain_a, 6, self.x, self.y, min(10, 3 + var.chaos / 35 * 1.7), A)
                            b.stay = false
                            PlaySound("tan00")
                            task.Wait(stage_lib.GetValue(15, 8, 4, 1))
                        end
                    end)
                end,
            }, true)
            for c = 1, 4 do
                for d = -1, 1, 2 do
                    task.New(stg, function()
                        local t = 20
                        for i = 1, 55 do
                            local A = 90 - (84 + 35 * task.SetMode[2](i / 55)) * d
                            local k = 2 + i / 50 * 8
                            New(rain_enemy, -400 * d, 180, cos(A) * k, sin(A) * k, A - 90 * d)
                            task.Wait(t)
                            t = max(1, t - 1)
                        end
                    end)
                    task.Wait(300 - c * 50)
                end
            end
            task.Wait(100)
        end, _t("拉窗帘"))
lib.NewWaveEventInWaves(class, 10, { 7, 8, 9, }, 1,
        0, 1, function(var)
            local diff = var.difficulty

            local shoot_soul = Class(enemy, {
                drop = function(self)
                    New(bullet_cleaner, self.x, self.y, 25, 1, 1, true, false, 0)
                    if self.flag then
                        local x, y = self.x, self.y
                        New(tasker, function()
                            task.Wait(2)
                            for a in sp.math.AngleIterator(-90, int(diff + var.chaos / 30)) do
                                Create.bullet_accel(x, y, ball_mid, 6, 0, min(10, 2 + var.chaos / 100 * 1.7), a, false, false)
                            end
                        end)

                    end
                end,
                init = function(self, master, v, a, flag)
                    enemy.init(self, 28, HP(6.5), false, true, false, 0.25)
                    object.Connect(master, self, 0.25, false)
                    self.x = master.x
                    self.y = master.y
                    self.flag = flag
                    object.SetSizeColli(self, 0.1)
                    object.ChangeSizeColliWithTask(self, 0.9, 0.9, 16, 2)
                    object.ChangeVwithTask(self, 0, v, a, 90, 0, false)
                    self.protect = true
                    task.New(self, function()
                        task.Wait(15)
                        self.protect = false
                        task.Wait(980 / v)
                        Del(self)
                    end)
                end
            }, true)
            local enemy1 = Class(enemy, {
                init = function(self, x, y, mx, my, vx, vy, d, flag)
                    enemy.init(self, 9, HP(250), false, true, false, 15)
                    self.x, self.y = x, y
                    task.New(self, function()
                        task.MoveTo(mx, my, 75, 2)
                        task.New(self, function()
                            local rot2 = ran:Float(0, 360)
                            while true do
                                for a in sp.math.AngleIterator(rot2, 6) do
                                    local v = stage_lib.GetValue(2, 3, 4, 10)
                                    Create.bullet_accel(self.x, self.y, grain_b, 8, v * 0.7, v, a, nil, false)
                                end
                                PlaySound("tan00")
                                rot2 = rot2 - d * (100 / (var.chaos + 8) + 1)
                                task.Wait((var.chaos >= 50) and 1 or 2)
                            end
                        end)
                        task.New(self, function()
                            local rot1 = ran:Float(0, 360)
                            local w = lstg.world
                            while BoxCheck(self, w.boundl, w.boundr, w.boundb, w.boundt) do
                                for a in sp.math.AngleIterator(rot1, 3) do
                                    New(shoot_soul, self, 2 + var.chaos / 35 * 2, a, flag)
                                end
                                PlaySound("tan00")
                                rot1 = rot1 + d * 17
                                task.Wait(int(stage_lib.GetValue(13, 6, 4, 1)))
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
            New(enemy1, -350, 300, -250, 160, 1, 0, 1)
            task.Wait(200)
            New(enemy1, 350, 300, 250, 160, -1, 0, -1)
            task.Wait(300)
            New(enemy1, -70, 300, -70, 160, 1, 0, -1, true)
            task.Wait(200)
            New(enemy1, 70, 300, 70, 160, -1, 0, 1, true)
            task.Wait(200)
            New(enemy1, 0, 300, 0, 140, 1, 0, 1, true)
        end, _t("实践优于理论"))
lib.NewWaveEventInWaves(class, 11, { 7, 8, 9 }, 0,
        2, 2, function(var)

            local shoot_soul = Class(enemy, {
                drop = function(self)
                    local x, y = self.x, self.y
                    New(tasker, function()
                        task.Wait(2)
                        for a in sp.math.AngleIterator(Angle(x, y, player), stage_lib.GetValue(4, 7, 11, 30)) do
                            local v = stage_lib.GetValue(3, 4, 5, 12)
                            Create.bullet_accel(x, y, ball_mid, 14, v - 1, v, a, false, false)
                        end
                    end)


                end,
                init = function(self, master, v, a, flag)
                    enemy.init(self, 34, HP(6), false, true, false, 0.25)
                    object.Connect(master, self, 0, false)
                    self.x = master.x
                    self.y = master.y
                    self.flag = flag
                    object.SetSizeColli(self, 0.1)
                    object.ChangeSizeColliWithTask(self, 0.9, 0.9, 16, 2)
                    object.ChangeVwithTask(self, 0, v, a, 90, 0, false)
                    self.protect = true
                    task.New(self, function()
                        task.Wait(30)
                        self.protect = false
                        task.Wait(980 / v)
                        Del(self)
                    end)
                end
            }, true)
            local enemy1 = Class(enemy, {
                init = function(self, x, y, mx, my, vx, vy, d, flag)
                    enemy.init(self, 14, HP(260), true, true, false, 15)
                    self.x, self.y = x, y
                    task.New(self, function()
                        task.MoveTo(mx, my, 75, 2)
                        task.New(self, function()
                            local rot2 = ran:Float(0, 360)
                            while true do
                                for a in sp.math.AngleIterator(rot2, 4) do
                                    Create.bullet_accel(self.x, self.y, ball_big, 2, stage_lib.GetValue(3, 4, 5, 8),
                                            stage_lib.GetValue(4, 5, 6, 12), a, nil, false)
                                end
                                PlaySound("tan00")
                                rot2 = rot2 - d * (230 / (var.chaos + 8) + 9)
                                task.Wait(stage_lib.GetValue(6, 4, 3, 1))
                            end
                        end)
                        task.New(self, function()
                            local rot1 = ran:Float(0, 360)
                            while true do
                                for a in sp.math.AngleIterator(rot1, 2) do
                                    New(shoot_soul, self, 2 + var.chaos / 30 * 2, a, flag)
                                end
                                PlaySound("tan00")
                                rot1 = rot1 + d * 17
                                task.Wait(stage_lib.GetValue(13, 8, 6, 1))
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
            New(enemy1, -350, 300, -200, 160, 1, 0, 1)
            task.Wait(200)
            New(enemy1, 350, 300, 200, 160, -1, 0, -1)
            task.Wait(300)
            New(enemy1, -70, 300, -70, 160, 1, 0, -1, true)
            task.Wait(200)
            New(enemy1, 70, 300, 70, 160, -1, 0, 1, true)
            task.Wait(200)
            New(enemy1, 0, 300, 0, 140, 1, 0, 1, true)
        end, _t("理论优于实践"), nil, true)
lib.NewWaveEventInWaves(class, 12, { 6, 7, 8, 9 }, 1,
        0, 1, function(var)

            local stg = stage.current_stage
            local rain_enemy = Class(enemy, {
                init = function(self, x, y, vx1, vy1, A)
                    enemy.init(self, 11, HP(10), false, true, false, 0.8)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx1, vy1
                    task.New(self, function()
                        while true do
                            local b = NewSimpleBullet(ball_mid, 2, self.x, self.y, min(10, 3 + var.chaos / 30 * 1.7), A)
                            b.stay = false
                            PlaySound("tan00")
                            task.Wait(stage_lib.GetValue(15, 8, 6, 1))
                        end
                    end)
                end,
            }, true)
            for c = 1, 8 do
                task.New(stg, function()
                    local t = 1
                    for i = 1, 45 do
                        for d = -1, 1, 2 do
                            local A = -90
                            local k = 16 - i / 45 * 12
                            New(rain_enemy, -(300 - c * 30) * d, 350, cos(A) * k, sin(A) * k, A - 90 * d)
                            task.Wait(t)
                            t = t + 0.05
                        end
                    end
                end)
                task.Wait(120 - c * 10)
            end
            task.Wait(120)
        end, _t("御柱？？"))
lib.NewWaveEventInWaves(class, 13, { 1, 3, 4 }, 1,
        0, 1, function(var)
            local stg = stage.current_stage
            local enemy1 = Class(enemy, {
                init = function(self, x, y, vx1, vy1)
                    enemy.init(self, 32, HP(6), false, true, false, 0.7)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx1, vy1
                    task.New(self, function()
                        if var.chaos >= 50 then
                            task.Wait(ran:Int(35, 125))
                            for _ = 1, stage_lib.GetValue(5, 8, 15, 75) do
                                Create.bullet_accel(self.x, self.y, ball_mid, 2, 0.3, min(10, 2 + var.chaos / 100), -90)
                                PlaySound("tan00")
                                task.Wait(stage_lib.GetValue(40, 20, 7, 1))
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
                init = function(self, x, y, vx, vy, d)
                    enemy.init(self, 8, HP(56), false, true, false, 8)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx, vy
                    task.New(self, function()
                        task.Wait(ran:Int(40, 120))
                        for r = 1, 15 do
                            for a in sp.math.AngleIterator(r * d * 25, int(stage_lib.GetValue(6, 9, 12, 48))) do
                                Create.bullet_accel(self.x, self.y, arrow_big_c, 4, 1, stage_lib.GetValue(3, 5, 6, 7), a)
                            end
                            PlaySound("tan00")
                            task.Wait(stage_lib.GetValue(20, 10, 6, 1))
                        end
                    end)
                end,
            }, true)
            task.New(stg, function()
                for _ = 1, 4 do
                    for d = -1, 1, 2 do
                        New(enemy2, 356 * d, ran:Float(140, 180), -1.3 * d, -0.2, d)
                    end
                    task.Wait(230)
                end
            end)
            for k = 1, 60 do
                local d = ran:Sign()
                New(enemy1, 350 * d, ran:Float(-240, 240), -1 * d, ran:Float(-0.2, 0.2))
                task.Wait(15 - k / 60 * 6)
            end

            task.Wait(30)

            task.Wait(30)
        end, _t("减速横穿"))
lib.NewWaveEventInWaves(class, 14, { 2, 3, 4, 7 }, 1,
        0, 1, function(var)
            local stg = stage.current_stage
            local enemy1 = Class(enemy, {
                init = function(self, x, y, vx1, vy1, vx2, vy2)
                    enemy.init(self, 3, HP(10), false, false, false, 1)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx1, vy1
                    task.New(self, function()
                        task.Wait(ran:Int(35, 125))
                        while true do
                            Create.bullet_decel(self.x, self.y, ball_mid, 6, 4,
                                    stage_lib.GetValue(1, 2, 3.5, 10), Angle(self, player))
                            PlaySound("tan00")
                            local t = int(stage_lib.GetValue(100, 60, 35, 8))
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
                init = function(self, x, y, mx, my, vx, vy)
                    enemy.init(self, 9, HP(75), false, true, false, 12)
                    self.x, self.y = x, y
                    task.New(self, function()
                        task.MoveTo(mx, my, 60, 2)
                        task.New(self, function()
                            local sty = ({ ball_mid, ball_big, ball_huge })[stage_lib.GetValue()]
                            for _ = 1, int(stage_lib.GetValue(3, 6, 9, 36)) do
                                for a in sp.math.AngleIterator(ran:Float(0, 360), 13) do
                                    Create.bullet_decel(self.x, self.y, sty, 2,
                                            stage_lib.GetValue(3, 5, 6, 12),
                                            stage_lib.GetValue(2, 3, 4, 8), a)
                                end
                                PlaySound("tan00")
                                task.Wait(int(stage_lib.GetValue(70, 40, 20, 3)))
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
            for _ = 1, 2 do
                task.New(stg, function()
                    for _ = 1, 54 do
                        New(enemy1, 356 * d, ran:Float(120, 180), -1 * d, -0.2, ran:Float(-1.9, -2.2) * d, ran:Float(-0.1, -0.2))
                        task.Wait(10)
                    end
                    d = -d
                end)
                task.Wait(200)
                for x = 1, 3 do
                    New(enemy2, d * (-180 + x * 70), 300, d * (-180 + x * 70), 150, 0, -1 * d)
                    task.Wait(30)
                end
                task.Wait(200)

            end
        end, _t("左右右右逢源"))
lib.NewWaveEventInWaves(class, 15, { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 }, 0.03,
        0, 0.4, function()
            local enemy1 = Class(enemy, {
                init = function(self, x, y, vx1, vy1)
                    enemy.init(self, 27, HP(3), false, false, true, 0.87)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx1, vy1
                    task.New(self, function()
                        task.Wait(400)
                        for i = 1, 36 do
                            self.vx = vx1 + vx1 * 3 * (i / 36)
                            self.vy = vy1 + vy1 * 3 * (i / 36)
                            task.Wait()
                        end
                        task.Wait(200)
                        Del(self)
                    end)
                end,
            }, true)
            for r = 1, 10 do
                for a in sp.math.AngleIterator(90 + r * 17, 20) do
                    New(enemy1, cos(a) * 500, sin(a) * 500, cos(a + 180) * 1, sin(a + 180) * 1)
                end
                task.Wait(50)
            end
        end, _t("这里是墓碑"), true)
lib.NewWaveEventInWaves(class, 16, { 3, 4, 6, 7, 12 }, 0,
        2, 2, function(var)
            local enemy1 = Class(enemy, {
                init = function(self, x, y, vx1, vy1)
                    enemy.init(self, 23, HP(50), false, false, false, 1)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx1, vy1
                    task.New(self, function()
                        for _ = 1, stage_lib.GetValue(4, 7, 9, 42) do
                            local v = stage_lib.GetValue(1, 2.5, 3.6, 12)
                            local b = Create.bullet_accel(self.x, self.y, music, 2, v * 0.7, v, Angle(self, player))
                            b.rot = -90
                            PlaySound("kira00")
                            task.Wait(stage_lib.GetValue(120, 90, 65, 13))
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
            for r = 1, stage_lib.GetValue(4, 6, 8, 20) do
                for a, i in sp.math.AngleIterator(90 + r * 17, 25) do
                    if i <= 20 then
                        New(enemy1, cos(a) * 500, sin(a) * 500, cos(a + 180) * 2, sin(a + 180) * 2)
                    end
                end
                task.Wait(stage_lib.GetValue(100, 95, 90, 30))
            end
        end, _t("二十面围攻"), nil, true)
lib.NewWaveEventInWaves(class, 17, { 5, 10 }, 2,
        0, 1, function(var)

            local bclass = boss.Define(name("Chiruno"), -400, 400, _editor_class.ice_bg, "Chiruno")

            local non_sc = boss.card.New("", 1, 4, 40, HP(850))
            boss.card.add(bclass, non_sc)
            function non_sc:before()
                task.MoveToForce(-200, 120, 60, 2)
            end
            function non_sc:other_bonus_drop()
                if ran:Float(0, 1) < 0.5 then
                    item.dropItem(item.drop_card, 1, self.x, self.y + 30, 24)
                end
            end
            function non_sc:init()
                task.New(self, function()
                    Newcharge_in(self.x, self.y, 135, 206, 235)
                    task.Wait(25)
                    task.New(self, function()
                        local s, t = 0, 0
                        while true do
                            self.x = cos(s * 0.72 + 180) * 200
                            s = s + sin(t)
                            t = min(t + 1, 90)
                            task.Wait()
                        end
                    end)
                    task.New(self, function()
                        task.Wait(200)
                        Newcharge_in(self.x, self.y, 135, 206, 235)
                        task.Wait(60)
                        self._bosssys:castcard("冰符「冰海绸云」")
                        self.flag = true
                        while true do

                            task.New(self, function()
                                local k = stage_lib.GetValue(0, 5, 8, 36)
                                local x, y = ran:Float(-320, 320), 255
                                local a = -90 + ran:Float(-k, k)
                                Create.bullet_dec_acc(x, y, ball_big, 8, 3, 4, a, false, false)
                                task.Wait(8)
                                for _ = 0, stage_lib.GetValue(1, 2, 4, 21) do
                                    Create.bullet_dec_acc(x, y, arrow_big_c, 8, 3, 4, a, true, false)
                                    task.Wait(4)
                                end
                            end)

                            PlaySound("tan00")
                            task.Wait(stage_lib.GetValue(15, 10, 7, 1))
                        end
                    end)
                    task.New(self, function()

                        while true do
                            for a in sp.math.AngleIterator(-90, int(stage_lib.GetValue(8, 12, 15, 54))) do
                                local b = Create.bullet_changeangle(self.x, self.y, ball_mid, 6,
                                        stage_lib.GetValue(1.8, 2.8, 4, 6), a, false)
                                b.ag = var.chaos / 100 * 0.025
                                b._blend = "mul+add"
                            end
                            PlaySound("tan00")
                            task.Wait(stage_lib.GetValue(16, 12, 10, 2))
                        end
                    end)


                end)
            end
            function non_sc:del()
                mission_lib.GoMission(15)
            end
            boss.Create(bclass)
        end, _t("冰海凝影"), nil, nil, true)
lib.NewWaveEventInWaves(class, 18, { 6, 7, 8, 9 }, 1,
        0, 1, function(var)

            local stg = stage.current_stage
            local rain_enemy = Class(enemy, {
                init = function(self, x, y, vx1, vy1, A)
                    enemy.init(self, 26, HP(20), false, true, false, 1.1)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx1, vy1
                    task.New(self, function()
                        while true do
                            local b = NewSimpleBullet(grain_b, 4, self.x, self.y, min(10, 3 + var.chaos / 100 * 2), A)
                            b.stay = false
                            PlaySound("tan00")
                            task.Wait(stage_lib.GetValue(15, 9, 6, 1))
                        end
                    end)
                end,
            }, true)
            for c = 1, 3 do
                for d = -1, 1, 2 do
                    task.New(stg, function()
                        local t = 20
                        for i = 1, 32 do
                            local A = 90 - (84 + 35 * task.SetMode[2](i / 32)) * d
                            local k = 3.5
                            New(rain_enemy, -400 * d, 180, cos(A) * k, sin(A) * k, A - 90 * d)
                            task.Wait(7)
                            t = max(1, t - 1)
                        end
                    end)
                    task.Wait(300 - c * 50)
                end
            end
        end, _t("阴阳玉云来袭"))
lib.NewWaveEventInWaves(class, 19, { 5, 10 }, 1,
        0, 1, function(var)

            local bclass = boss.Define(name("Daiyousei"), -200, 400, _editor_class.ice_bg, "Daiyousei")

            local non_sc = boss.card.New("", 1, 4, 16, HP(720))
            boss.card.add(bclass, non_sc)
            function non_sc:before()
                task.MoveToForce(0, 120, 60, 2)
            end
            function non_sc:other_bonus_drop()
                if ran:Float(0, 1) < 0.5 then
                    item.dropItem(item.drop_card, 1, self.x, self.y + 30, 45)
                end
            end
            function non_sc:init()
                task.New(self, function()
                    Newcharge_in(self.x, self.y, 189, 252, 201)
                    task.Wait(25)
                    task.New(self, function()
                        local d = 1
                        while true do
                            task.New(self, function()
                                task.MoveTo(-120 * d, 90, 72, 2)
                            end)
                            local n = int(stage_lib.GetValue(24, 38, 45, 120))
                            for i = 1, 72 do
                                for a in sp.math.AngleIterator(-90 + i * 360 / n * d, 2) do
                                    for c = -1, 1, 2 do
                                        Create.bullet_dec_acc(self.x, self.y, arrow_small, 6, 5,
                                                (4 - i / 72 * 2) * stage_lib.GetValue(0.7, 1.2, 1.8, 4),
                                                a + c * 0.7, false, false)
                                    end
                                end
                                PlaySound("tan00")
                                task.Wait()
                            end
                            task.New(self, function()

                                for _ = 1, int(stage_lib.GetValue(2, 4, 6, 8)) do
                                    for a in sp.math.AngleIterator(ran:Float(0, 360), int(stage_lib.GetValue(5, 9, 15, 20))) do
                                        local b = NewSimpleBullet(ball_big, 16, self.x, self.y, ran:Float(1, 3), a)
                                        b.ag = 0.02
                                    end
                                    PlaySound("tan00")
                                    task.Wait(10)
                                end
                            end)

                            task.MoveTo(0, 120, int(stage_lib.GetValue(140, 99, 60, 15)), 3)
                            d = -d

                        end
                    end)


                end)
            end

            boss.Create(bclass)
        end, _t("这不是白给"), nil, nil, true)
lib.NewWaveEventInWaves(class, 20, { 5, 10 }, 0.03,
        0, 0.5, function(var)

            local bclass = boss.Define(name("Daiyousei"), 200, 400, _editor_class.ice_bg, "Daiyousei")

            local non_sc = boss.card.New("", 1, 4, 16, HP(860))
            boss.card.add(bclass, non_sc)
            function non_sc:before()
                task.MoveToForce(0, 120, 60, 2)
            end
            function non_sc:other_drop()
                local othercond = function(tool)
                    return tool.quality == 4
                end
                local addition = stg_levelUPlib.GetAdditionList(1, othercond)
                if #addition > 0 then
                    item.dropItem(item.drop_card, 1, self.x, self.y + 30, addition[1].id)
                end

            end
            function non_sc:init()
                task.New(self, function()
                    Newcharge_in(self.x, self.y, 189, 252, 201)
                    task.Wait(25)
                    task.New(self, function()
                        local d = 1
                        while true do
                            task.New(self, function()
                                task.MoveTo(-120 * d, 90, 72, 2)
                                task.MoveTo(0, 120, 72, 3)
                            end)
                            local n = int(stage_lib.GetValue(24, 30, 40, 90))
                            for i = 1, 144 do
                                for a in sp.math.AngleIterator(Angle(self, player) + i * 360 / n * d, 2) do
                                    for c = -1, 1, 2 do
                                        Create.bullet_dec_acc(self.x, self.y, grain_a, 10, 5,
                                                (4 - i / 144 * 2) * min(4, var.chaos / 35 + 0.7), a + c * 0.7, false, false)
                                    end
                                end
                                PlaySound("tan00")
                                task.Wait()
                            end
                            d = -d

                        end
                    end)


                end)
            end

            boss.Create(bclass)
        end, _t("这是白给，吗？"), true, nil, true)


