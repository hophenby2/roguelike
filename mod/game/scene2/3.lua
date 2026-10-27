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

lib.NewWaveEventInWaves(class, 34, { 11, 12, 13, 14 }, 0,
        2, 2, function(var)
            local enemy2 = Class(enemy, {
                drop = function(self)
                    New(bullet_cleaner, self.x, self.y, 111, 1, 2, true, false, 0)
                end,
                init = function(self, x, y, mx, my, v, A, d)
                    enemy.init(self, 15, HP(200), false, true, false, 25)
                    self.x, self.y = x, y
                    self.servant_back = true
                    task.New(self, function()
                        task.MoveTo(mx, my, 90, 2)
                        task.Wait(200)
                        object.ChangingV(self, 0, v, A, 80, false)
                        task.Wait(650)
                        Del(self)
                    end)
                    task.New(self, function()
                        local N = int(stage_lib.GetValue(7, 9, 12, 48))
                        for a, ki in sp.math.AngleIterator(0, N) do
                            servant.init(NewObject(servant), self.x, self.y, 0, 135, 206, 235, 1.5, function(unit)
                                unit.bound = false
                                object.Connect(self, unit, 0.3, true)
                                task.New(unit, function()
                                    unit:FadeIn(15)
                                    object.ChangingSizeColli(unit, -0.5, -0.5, 15)
                                end)
                                local R = 0
                                local o = 3 * d
                                unit.angle = a
                                task.New(unit, function()
                                    while IsValid(self) do
                                        unit.x = self.x + cos(unit.angle) * R
                                        unit.y = self.y + sin(unit.angle) * R
                                        unit.angle = unit.angle + o
                                        task.Wait()
                                    end
                                    Del(unit)
                                end)
                                task.New(unit, function()
                                    for i = 1, 35 do
                                        R = 75 * task.SetMode[2](i / 35)
                                        task.Wait()
                                    end

                                    unit.bound = true
                                    task.New(unit, function()
                                        for _ = 1, 40 do
                                            for z = -1.5, 1.5 do
                                                local b = NewSimpleBullet(ball_mid_c, 2, unit.x, unit.y,
                                                        stage_lib.GetValue(2, 2.3, 2.6, 9), unit.angle - 80 * d + 30 * z)
                                                b.fogtime = 0
                                            end

                                            PlaySound("tan00")
                                            task.Wait(abs(360 / N / o))
                                        end
                                    end)
                                    task.Wait(ki)
                                    for k = 1, 40 do
                                        local offa = ran:Float(30, 75)
                                        for ba in sp.math.AngleIterator(ran:Float(0, 360), 5) do
                                            Create.bullet_dec_setangle(unit.x, unit.y, grain_a, 2,
                                                    { v = 0.5, a = ba, time = 35 },
                                                    { wait = 5, v = stage_lib.GetValue(2.5, 2.8, 3.3, 9), a = ba + offa })
                                        end
                                        local b = NewSimpleBullet(ball_mid_c, 6, unit.x, unit.y,
                                                stage_lib.GetValue(1.4, 1.6, 1.8, 6), unit.angle + 165 * d + k * 2 * d)
                                        b.fogtime = 0
                                        PlaySound("tan00")
                                        task.Wait(12)
                                    end
                                end)
                            end)

                        end
                    end)
                end,
            }, true)
            New(enemy2, -500, 300, 0, 100, 1, -175, 1)
            task.Wait(310)
            New(enemy2, 500, 300, 0, 100, 1, -5, -1)
            task.Wait(310)
            New(enemy2, -500, 300, 75, 100, 1, -175, 1)
            task.Wait(30)
            New(enemy2, 500, 300, -75, 100, 1, -5, -1)
        end, _t("夜空珠，你可以藏公主"), nil, true)

lib.NewWaveEventInWaves(class, 35, { 15 }, 1,
        0, 1, function(var)
            local bclass = boss.Define(name("Ringo"), 0, 400, _editor_class.ringo_bg, "Ringo")

            local non_sc1 = boss.card.New("", 1, 4, 40, HP(1100))
            boss.card.add(bclass, non_sc1)
            function non_sc1:before()
                lstg.tmpvar.otherMusic = "2_boss2"
                --lstg.tmpvar.otherMusic_start_time = 82.5 - 140 / 60
                boss.show_aura(self, false)
                PlaySound("ch02")
                New(boss_cast_darkball, 0, 100, 60, 80, 360, 1, 270, 64, 64, 255, 2)
                New(boss_cast_darkball, 0, 100, 60, 80, 360, 1, 270, 255, 64, 64, -2)
                task.Wait(80)
                self.x, self.y = 0, 100
                boss.show_aura(self, true)
                Newcharge_in(self.x, self.y, 250, 128, 114)
                task.Wait(60)
            end
            function non_sc1:init()
                task.New(self, function()
                    local d = 1
                    while true do
                        boss.cast(self, 150)
                        Newcharge_out(self.x, self.y, 250, 128, 114)
                        task.New(self, function()
                            task.Wait(210 - 60)
                            task.MoveToPlayer(60, -200, 200, 80, 120,
                                    20, 40, 10, 20, 2, 1)
                        end)
                        local v
                        local I = 1
                        local index = 2
                        local wait = 80
                        servant.init(NewObject(servant), self.x, self.y, 0, 135, 206, 235, 1.5, function(unit)
                            task.New(unit, function()
                                unit:FadeIn(15)
                                object.ChangingSizeColli(unit, -0.5, -0.5, 15)
                            end)
                            task.New(unit, function()
                                object.SetA(unit, 0.012, Angle(unit, player), false)
                                for i = 1, 35 do
                                    v = stage_lib.GetValue(1.5, 2, 3, 10) + i / 35 * index
                                    for a in sp.math.AngleIterator(90 - 90 * d + i * 5 * d,
                                            int(stage_lib.GetValue(2, 3, 5, 32) + i * I)) do
                                        local x, y = unit.x + cos(a) * (60 - i) * 2, unit.y + sin(a) * (60 - i) * 2
                                        if Dist(x, y, player) > 64 then
                                            Create.bullet_decel(x, y, ball_mid, 6, 4 - i / 35 * index, v, a)
                                            PlaySound("tan00")
                                        end
                                    end

                                    task.Wait(6)
                                end
                                object.ChangingSizeColli(unit, -1, -1, 15)
                                Del(unit)
                            end)
                        end)
                        task.Wait(35 * 6 - stage_lib.GetValue(30, 45, 60, 100))
                        for a in sp.math.AngleIterator(ran:Float(0, 360), int(stage_lib.GetValue(30, 40, 50, 180))) do
                            for V = 4, 8 + int(stage_lib.GetValue(1, 2, 3, 12)) do
                                NewSimpleBullet(arrow_small, 2, self.x, self.y, 0.3 + V * 0.3, a + V * d)
                            end
                        end
                        task.Wait(wait)
                        d = -d
                    end
                end)
            end

            local sc1 = boss.card.New("团子「团子制作中心」", 2, 4, 40, HP(1600))
            boss.card.add(bclass, sc1)
            function sc1:before()
                task.Wait(60)
            end
            function sc1:init()
                task.New(self, function()
                    local dumpling_rotate = function(center, a, o, r)
                        local self = NewObject(bullet)
                        bullet.init(self, ball_small, 4, false, true)
                        self.x, self.y = center.x + cos(a) * r, center.y + sin(a) * r
                        task.New(self, function()
                            while IsValid(center) do
                                self.x, self.y = center.x + cos(a) * r, center.y + sin(a) * r
                                a = a + o
                                task.Wait()
                            end
                            self.vx, self.vy = self.dx, self.dy
                        end)
                    end
                    local dumpling_center = function(x, y, v, a, ra, ro, rr, rk)
                        local self = NewObject(bullet)
                        bullet.init(self, ball_small, 6, false, true)
                        self.x, self.y = x, y
                        object.SetV(self, v, a)
                        PlaySound("tan00")
                        for k = -rk, rk do
                            if k ~= 0 then
                                dumpling_rotate(self, ra, ro, rr * k)
                            end
                        end
                    end

                    task.MoveToForce(0, 100, 60, 2)
                    boss.cast(self, 3600)
                    Newcharge_in(self.x, self.y, 250, 128, 114)
                    task.Wait(60)
                    Newcharge_out(self.x, self.y, 250, 128, 114)
                    local d = 1
                    while true do
                        local rot = ran:Float(0, 360)
                        local N = int(stage_lib.GetValue(18, 20, 24, 75))
                        local cR = stage_lib.GetValue(10, 15, 20, 35)
                        local ro = stage_lib.GetValue(0.5, 1.14, 1.66, 6)
                        local v = stage_lib.GetValue(1.5, 2, 2.5, 9)
                        local wt = stage_lib.GetValue(10, 8, 7, 3)
                        for _ = 1, 9 do
                            for a in sp.math.AngleIterator(rot, N) do
                                dumpling_center(self.x, self.y, v, a, a + 180, ro * d, 10, 2)
                            end
                            rot = rot + cR * d
                            task.Wait(wt)
                        end
                        for _ = 1, 3 do
                            for a in sp.math.AngleIterator(rot, N) do
                                Create.bullet_accel(self.x, self.y, ball_big, 2, v, v * 1.3, a, true, false)
                            end
                            PlaySound("tan00")
                            task.Wait(wt * 3)
                            rot = rot - cR * d
                        end
                        d = -d

                    end

                end)
            end

            local non_sc2 = boss.card.New("", 1, 4, 40, HP(1100))
            boss.card.add(bclass, non_sc2)
            function non_sc2:before()
                task.MoveToForce(0, 100, 60, 2)
            end
            function non_sc2:init()
                task.New(self, function()
                    local d = 1
                    self.cast_t = 0
                    task.Wait(60)
                    Newcharge_in(self.x, self.y, 250, 128, 114)
                    task.Wait(60)

                    while true do
                        boss.cast(self, 150)
                        Newcharge_out(self.x, self.y, 250, 128, 114)
                        task.New(self, function()
                            task.Wait(210 - 60)
                            task.MoveToPlayer(60, -200, 200, 80, 120,
                                    20, 40, 10, 20, 2, 1)
                        end)
                        local v
                        local index = 2
                        local wait = 80
                        local Rot = Angle(self, player)
                        for p = -1, 1 do
                            servant.init(NewObject(servant), self.x, self.y, 0, 250, 128, 114, 1.5, function(unit)
                                task.New(unit, function()
                                    unit:FadeIn(15)
                                    object.ChangingSizeColli(unit, -0.5, -0.5, 15)
                                end)
                                task.New(unit, function()
                                    object.SetA(unit, 0.0152, Rot + p * 45, false)
                                    local A = Rot + p * 45
                                    local N = int(stage_lib.GetValue(10, 20, 30, 60))
                                    for i = 1, 20 do
                                        v = stage_lib.GetValue(1.5, 2, 3, 10) + i / 35 * index
                                        for a in sp.math.AngleIterator(A + 180 / N, N) do
                                            local x, y = unit.x + cos(a) * (60 - i * 2) * 2, unit.y + sin(a) * (60 - i * 2) * 2
                                            if Dist(x, y, player) > 48 then
                                                Create.bullet_decel(x, y, ball_mid, 2, 4 - i / 35 * index, v, a)
                                                PlaySound("tan00")
                                            end
                                        end
                                        task.Wait(6)
                                    end
                                    object.ChangingSizeColli(unit, -1, -1, 15)
                                    Del(unit)
                                end)
                            end)
                            task.Wait(60)
                        end
                        task.Wait(60)
                        for a in sp.math.AngleIterator(ran:Float(0, 360), int(stage_lib.GetValue(40, 50, 60, 200))) do
                            for V = 4, 6 do
                                NewSimpleBullet(arrow_small, 6, self.x, self.y, 0.3 + V * 0.3, a + V * d)
                            end
                        end
                        task.Wait(wait)
                        d = -d
                    end
                end)
            end

            local sc2 = boss.card.New("团子「团子加工厂」", 2, 4, 40, HP(1600))
            boss.card.add(bclass, sc2)
            function sc2:before()
                task.Wait(60)
            end
            function sc2:init()
                task.New(self, function()
                    local dumpling_rotate = function(center, a, o, r)
                        local self = NewObject(bullet)
                        bullet.init(self, ball_small, 10, false, true)
                        self.x, self.y = center.x + cos(a) * r, center.y + sin(a) * r
                        task.New(self, function()
                            while IsValid(center) do
                                self.x, self.y = center.x + cos(a) * r, center.y + sin(a) * r
                                a = a + o
                                task.Wait()
                            end
                            self.vx, self.vy = self.dx, self.dy
                        end)
                    end
                    local dumpling_center = function(x, y, v, a, ra, ro, rr, rk, d)
                        local self = NewObject(bullet)
                        bullet.init(self, ball_small, 8, false, true)
                        self.x, self.y = x, y
                        object.SetV(self, v, a)
                        PlaySound("tan00")
                        for k = -rk, rk do
                            if k ~= 0 then
                                dumpling_rotate(self, ra + abs(rr * k * ro * 2) * d, ro, rr * k)
                            end
                        end
                    end

                    task.MoveToForce(0, 100, 60, 2)
                    boss.cast(self, 3600)
                    Newcharge_in(self.x, self.y, 250, 128, 114)
                    task.Wait(60)
                    Newcharge_out(self.x, self.y, 250, 128, 114)
                    local d = 1
                    while true do
                        local rot = ran:Float(0, 360)
                        local N = int(stage_lib.GetValue(12, 13, 14, 40))
                        local v = stage_lib.GetValue(1.5, 1.7, 2, 9)
                        local wt = stage_lib.GetValue(50, 45, 40, 20)
                        local ro = stage_lib.GetValue(0.5, 0.5, 0.5, 1)
                        for _ = 1, 3 do
                            for a in sp.math.AngleIterator(rot, N) do
                                dumpling_center(self.x, self.y, v, a, a + 180, ro * d, 10, 15, d)
                            end
                            rot = rot + 10 * d
                            task.Wait(wt)
                        end
                        local zN = int(stage_lib.GetValue(2, 2, 3, 8))
                        for _ = 1, 6 do
                            for z = -zN, zN do
                                for cv = 0, stage_lib.GetValue(2, 3, 5, 16) do
                                    NewSimpleBullet(arrow_big, 2, self.x, self.y, (2.3 + cv * 0.6), Angle(self, player) + z / zN * 75)
                                end
                            end
                            PlaySound("tan00")
                            task.Wait(wt / 2)
                        end
                        d = -d

                    end

                end)
            end

            local non_sc3 = boss.card.New("", 1, 4, 40, HP(900))
            boss.card.add(bclass, non_sc3)
            function non_sc3:before()
                task.MoveToForce(0, 120, 60, 2)
            end
            function non_sc3:init()
                task.New(self, function()
                    local d = 1
                    self.cast_t = 0
                    task.Wait(60)
                    Newcharge_in(self.x, self.y, 250, 128, 114)
                    task.Wait(60)

                    while true do
                        boss.cast(self, 150)
                        Newcharge_out(self.x, self.y, 250, 128, 114)
                        task.New(self, function()
                            task.Wait(210 - 60)
                            task.MoveToPlayer(60, -200, 200, 80, 120,
                                    20, 40, 10, 20, 2, 1)
                        end)
                        local v
                        local index = 2.5
                        local wait = 80
                        local Rot = Angle(self, player)
                        servant.init(NewObject(servant), self.x, self.y, 0, 250, 128, 114, 1.5, function(unit)
                            task.New(unit, function()
                                unit:FadeIn(15)
                                object.ChangingSizeColli(unit, -0.5, -0.5, 15)
                            end)
                            task.New(unit, function()
                                task.MoveTo(player.x, player.y, 60, 2)
                                local A = ran:Float(0, 360)
                                local N = int(stage_lib.GetValue(8, 10, 12, 20))
                                for i = 1, 50 do
                                    v = stage_lib.GetValue(1.5, 1.8, 2, 8) + i / 50 * index
                                    local drot = 0
                                    local R = (60 - i * 2) * 2
                                    if R < 0 then
                                        drot = drot + 180
                                    end
                                    for a in sp.math.AngleIterator(A + 180 / N + drot, N * 2 + 1) do
                                        local x, y = unit.x + cos(a) * R, unit.y + sin(a) * R
                                        if Dist(x, y, player) > 48 then
                                            Create.bullet_decel(x, y, ball_mid, 2, 4 - i / 35 * index, v, a)
                                            PlaySound("tan00")
                                        end
                                    end

                                    task.Wait(3)
                                end
                                object.ChangingSizeColli(unit, -1, -1, 15)
                                Del(unit)
                            end)
                        end)
                        task.Wait(120)
                        for a in sp.math.AngleIterator(ran:Float(0, 360), int(stage_lib.GetValue(25, 30, 40, 150))) do
                            for V = 4, 6 do
                                NewSimpleBullet(arrow_big, 8, self.x, self.y, 0.3 + V * 0.3, a + V * d)
                            end
                        end
                        task.Wait(wait)
                        d = -d
                    end
                end)
            end

            local sc3 = boss.card.New("中秋「佳期圆月，纵情无愁」", 2, 10, 60, HP(3300))
            boss.card.add(bclass, sc3)
            function sc3:before()
                task.Wait(60)
            end
            function sc3:init()
                task.New(self, function()
                    task.MoveToForce(0, 120, 60, 2)
                    Newcharge_in(self.x, self.y, 250, 128, 114)
                    task.Wait(60)
                    boss.cast(self, 33333)
                    local rotatelaser = function(x, y, a, d)
                        local l = Create.laser_changeangle(x, y, 13, 150, 7,
                                3.5, a, { r = 0.85 * d, time = 130, v = 5.5 })
                        l.bound = false
                        task.New(l, function()
                            local T = 150
                            local ROT = ran:Float(0, 360)
                            while T > 0 do
                                sakura_big.New(l.x, l.y, l.rot * 2 + ROT, 0, 0, 0, function(self)
                                    self._blend = "mul+alpha"
                                    task.New(self, function()
                                        task.Wait(T)
                                        local _a = self.rot
                                        local v = stage_lib.GetValue(1, 2, 3, 9)
                                        self.max = cos(_a) * v / 200
                                        self.may = sin(_a) * v / 200
                                        self.mmaxvx = abs(cos(_a) * v)
                                        self.mmaxvy = abs(sin(_a) * v)
                                    end)
                                end)
                                PlaySound("kira00")
                                local wt = stage_lib.GetValue(11, 8, 6, 3)
                                T = T - (wt - 2)
                                task.Wait(wt)
                            end
                            l.bound = true
                        end)
                    end
                    local dango = function(x, y, R, G, B, vy, size)
                        local self = NewObject(bullet)
                        bullet.init(self, ball_light, 15, false, true)
                        object.SetSizeColli(self, 0.1, 0.1)
                        self.x, self.y = x, y
                        self.fogtime = 0
                        self._blend = "add+add"
                        self._r, self._g, self._b = R, G, B
                        task.New(self, function()
                            for i = 1, 60 do
                                i = task.SetMode[2](i / 60)
                                object.SetSizeColli(self, 0.1 + 1.9 * i)
                                task.Wait()
                            end
                            local dsize = 2 - size
                            for i = 1, 60 do
                                i = task.SetMode[2](i / 60)
                                object.SetSizeColli(self, 2 - dsize * i)
                                self.vy = vy * i
                                task.Wait()
                            end
                        end)
                    end
                    local CreateDango = function(x, y, R, G, B, vy, isize, count, interval)
                        task.New(self, function()
                            for i = 1, count do
                                dango(x, y, R, G, B, vy, isize * (1 + 0.5 * abs(cos(i / count * 180))))
                                task.Wait(interval)
                            end
                        end)
                    end
                    local W = stage_lib.GetValue(560, 500, 480, 300)
                    task.New(self, function()
                        while true do
                            for z = -2, 1 do
                                rotatelaser(280 - z * 30, 255, -60 - z * 4, -1)
                            end
                            task.Wait(W)
                        end
                    end)
                    task.New(self, function()
                        while true do
                            task.Wait(W / 2)
                            for z = -2, 1 do
                                rotatelaser(-280 + z * 30, 255, -120 + z * 4, 1)
                            end
                            task.Wait(W / 2 + 40)
                        end
                    end)
                    task.Wait(80)
                    local t = 0
                    while true do
                        local c = stage_lib.GetValue(10, 14, 18, 40)
                        local vy = stage_lib.GetValue(3, 4, 5, 13)
                        local R, G, B = sp:HSVtoRGB(t * 25, 1, 1)
                        CreateDango(sin(t * 25) * 300 + ran:Float(-20, 20), 240, R, G, B,
                                -ran:Float(vy - 1, vy + 1), ran:Float(0.4, 0.6), ran:Int(c - 6, c + 6), 50 / vy)
                        PlaySound("water", 0.3)
                        t = t + 1
                        task.Wait(stage_lib.GetValue(50, 40, 30, 6))
                    end
                end)
            end
            function sc3:del()
                if var.wave ~= var.maxwave then
                    lstg.tmpvar.otherMusic = nil
                end
            end
            function sc3:other_drop()
                mission_lib.GoMission(51)
                mission_lib.GoMission(59)
                mission_lib.GoMission(60)
                mission_lib.GoMission(61)
                mission_lib.GoMission(62)
                if var.wave ~= var.maxwave then
                    item.dropItem(item.drop_card, 1, self.x, self.y + 30, 161)
                end
            end
            boss.Create(bclass)
        end, _t("你也是团子"), nil, true, true)

lib.NewWaveEventInWaves(class, 36, { 5, 10, 14 }, 1,
        0, 1, function(var)

            local bclass = boss.Define(name("Doremy"), -500, 200, _editor_class.doremy_bg, "Doremy")

            local non_sc = boss.card.New("", 1, 5, 40, HP(1000))
            boss.card.add(bclass, non_sc)
            function non_sc:before()
                task.MoveToForce(0, 100, 60, 2)
            end
            function non_sc:init()
                task.New(self, function()
                    local beat = 1
                    task.init_left_wait(self)
                    task.New(self, function()
                        while true do
                            beat = 3600 / stage_lib.GetValue(100, 250, 350, 1200)
                            task.Wait()
                        end
                    end)
                    Newcharge_in(self.x, self.y, 250, 128, 114)
                    task.Wait(60)
                    while true do

                        do
                            local bulletclass = _editor_class.Seija_grain2
                            local d = 1
                            for _ = 1, 2 do
                                boss.cast(self, 180)
                                local A = ran:Float(0, 360)
                                for i = 1, 30 do
                                    for a in sp.math.AngleIterator(A, int(stage_lib.GetValue(2, 3, 4, 10))) do
                                        local v = stage_lib.GetValue(2, 2.5, 3.3, 12)
                                        local b = NewObject(bulletclass)
                                        bulletclass.init(b, ball_mid, 6, 2,
                                                self.x + cos(a + d * i * 7) * 100, self.y + sin(a + d * i * 7) * 100,
                                                cos(a + d * i * 12) * v, sin(a + d * i * 12) * v,
                                                -100, 0, 0, -200, beat / 2, beat / 2, beat)
                                        b = NewObject(bulletclass)
                                        bulletclass.init(b, ball_mid, 6, 2,
                                                self.x + cos(a + d * i * 7) * 100, self.y + sin(a + d * i * 7) * 100,
                                                cos(a + d * i * 12) * v, sin(a + d * i * 12) * v,
                                                100, 0, 0, -200, beat / 2, beat / 2, beat)
                                    end
                                    PlaySound("tan00")
                                    task.Wait(stage_lib.GetValue(3, 3, 2, 1))
                                end
                                task.New(self, function()
                                    task.MoveToPlayer(40, -200, 200, 100, 145,
                                            40, 60, 10, 12, 2, 1)
                                end)
                                d = -d
                                task.Wait2(self, beat * 2)
                                for a in sp.math.AngleIterator(Angle(self, player), int(stage_lib.GetValue(20, 25, 35, 100))) do
                                    for v = 0, int(stage_lib.GetValue(0, 1, 2, 8)) do
                                        local b = NewSimpleBullet(ball_big, 4, self.x, self.y,
                                                stage_lib.GetValue(1.5, 2, 2.5, 12) * (1 - v / 16), a)
                                        b._blend = "mul+add"
                                    end
                                end
                                PlaySound("tan00")
                                task.Wait2(self, beat * 2)
                            end
                            for _ = 1, 2 do
                                boss.cast(self, 180)
                                local A = ran:Float(0, 360)
                                for i = 1, 30 do
                                    for a in sp.math.AngleIterator(A, int(stage_lib.GetValue(2, 3, 4, 10))) do
                                        local b = NewObject(bulletclass)
                                        local v = stage_lib.GetValue(2, 2.5, 3.3, 12)
                                        bulletclass.init(b, ball_mid, 2, 6,
                                                self.x + cos(a + d * i * 7) * 100, self.y + sin(a + d * i * 7) * 100,
                                                cos(a - d * i * 12) * v, sin(a - d * i * 12) * v,
                                                -100, 0, 0, -200, beat / 2, beat / 2, beat)
                                        b = NewObject(bulletclass)
                                        bulletclass.init(b, ball_mid, 2, 6,
                                                self.x + cos(a + d * i * 7) * 100, self.y + sin(a + d * i * 7) * 100,
                                                cos(a - d * i * 12) * v, sin(a - d * i * 12) * v,
                                                100, 0, 0, -200, beat / 2, beat / 2, beat)
                                    end
                                    PlaySound("tan00")
                                    task.Wait(stage_lib.GetValue(3, 3, 2, 1))
                                end
                                task.New(self, function()
                                    task.MoveToPlayer(40, -200, 200, 100, 145,
                                            40, 60, 10, 12, 2, 1)
                                end)
                                d = -d
                                task.Wait2(self, beat * 2)
                                for a in sp.math.AngleIterator(Angle(self, player), int(stage_lib.GetValue(20, 25, 35, 100))) do
                                    for v = 0, int(stage_lib.GetValue(0, 1, 2, 8)) do
                                        local b = NewSimpleBullet(ball_big, 4, self.x, self.y,
                                                stage_lib.GetValue(1.5, 2, 2.5, 12) * (1 - v / 16), a)
                                        b._blend = "mul+add"
                                    end
                                end
                                PlaySound("tan00")
                                task.Wait2(self, beat * 2)
                            end
                        end

                    end
                end)
            end

            local sc1 = boss.card.New("梦符「圣洁无暇的美梦」", 1, 4, 40, HP(1200))
            boss.card.add(bclass, sc1)
            function sc1:before()
                task.Wait(60)
            end
            function sc1:init()
                local bullet_wheel = function(x, y, ir, ia, ka, kr, iwait, time, interval, event)
                    local self = NewObject(bullet)
                    bullet.init(self, ball_mid, 14, false, true)
                    self.bound = false
                    self.flag = true
                    self.cx, self.cy = x, y
                    self._blend = "mul+add"
                    self.ia, self.ir = ia, ir
                    self.x, self.y = self.cx + cos(self.ia) * self.ir, self.cy + sin(self.ia) * self.ir
                    task.New(self, function()
                        task.init_left_wait(self)
                        if event then
                            event(self)
                        end
                        task.Wait2(self, iwait)
                        local t = int(time)
                        while true do
                            local slast = 0
                            for i = 1, t do
                                i = i / t
                                self.ia = self.ia + ka * (i - slast)
                                self.ir = self.ir + kr * (i - slast)
                                slast = i
                                self.x, self.y = self.cx + cos(self.ia) * self.ir, self.cy + sin(self.ia) * self.ir
                                if self.ir <= 0 then
                                    Del(self)
                                end
                                task.Wait()
                            end
                            task.Wait2(self, time - t + interval)
                        end
                    end)
                    return self
                end
                task.New(self, function()
                    local beat = 1
                    task.init_left_wait(self)
                    task.New(self, function()
                        while true do
                            beat = 3600 / stage_lib.GetValue(100, 150, 200, 800)
                            task.Wait()
                        end
                    end)
                    task.MoveToForce(0, 100, 60, 2)
                    boss.cast(self, 3600)
                    Newcharge_in(self.x, self.y, 250, 128, 114)
                    task.Wait(60)
                    local groups = {}
                    local bn = int(stage_lib.GetValue(12, 16, 23, 100))
                    for i = 1, bn * 2 do
                        groups[i] = {}
                        task.New(New(_editor_class.PointRender, groups[i], 6666, 92, 0, 0, 0, true), function()
                            local H = 360 / bn / 2 * i
                            local self = task.GetSelf()
                            while true do
                                self._r, self._g, self._b = sp:HSVtoRGB(H, 0.7, 1)
                                H = H + 0.5
                                task.Wait()
                            end
                        end)
                    end
                    local first_angle = 60
                    local ka = 10
                    local kr = -10
                    local cx, cy = 0, -300
                    local ir = 800
                    local init_function = function(p, d)
                        return function(self)
                            local n = 144
                            local slast = 0
                            local D = d
                            local P = p
                            for i = 1, n do
                                i = task.SetMode[2](i / n)
                                self.ia = self.ia + D * first_angle * (i - slast)
                                self.ir = self.ir + (7 - P) * kr * 4 * (i - slast)
                                self.x, self.y = self.cx + cos(self.ia) * self.ir, self.cy + sin(self.ia) * self.ir
                                slast = i
                                task.Wait()
                            end
                            task.Wait2(self, beat * 4 - n)
                        end
                    end
                    local b
                    local ia = 0
                    local da = 40
                    local d = 1
                    for p = -12, 6 do

                        for a, t in sp.math.AngleIterator(d * ia, bn) do
                            b = bullet_wheel(cx, cy, ir, a - first_angle * d, d * ka, kr, 0, beat, 0, init_function(p, d))
                            table.insert(groups[(d == 1) and t or t + bn], b)
                            if p % 2 == 0 then
                                b.hide = true
                                b.colli = false
                            end
                        end
                        ia = ia - ka * 2
                        d = -d

                        if p ~= 1 then
                            for a, t in sp.math.AngleIterator(d * ia, bn) do
                                b = bullet_wheel(cx, cy, ir, a - first_angle * d, d * ka, kr, 0, beat, 0, init_function(p, d))
                                table.insert(groups[(d == 1) and t or t + bn], b)
                                if p % 2 == 1 then
                                    b.hide = true
                                    b.colli = false
                                end
                            end
                        end
                        d = -d
                        ia = ia + da
                        ia = ia - ka * 2
                        da = da + 0.5
                    end

                    task.New(self, function()
                        task.MoveTo(0, 100, 120, 2)
                    end)
                    task.Wait(144)
                    Newcharge_out(self.x, self.y, 250, 128, 114)
                    task.New(self, function()
                        local w = {}
                        task.init_left_wait(w)
                        while true do
                            for _ = 1, 2 do
                                for a in sp.math.AngleIterator(Angle(self, player), int(stage_lib.GetValue(8, 13, 20, 80))) do
                                    for v = 0, int(stage_lib.GetValue(0, 1, 2, 8)) do
                                        NewSimpleBullet(ball_big, 4, self.x, self.y,
                                                stage_lib.GetValue(1.5, 2, 2.5, 12) * (1 - v / 16), a)
                                    end
                                end
                                PlaySound("tan00")
                                task.Wait2(w, beat * 4)
                            end
                            task.New(self, function()
                                task.MoveToPlayer(60, -200, 200, 100, 160,
                                        40, 50, 20, 30, 2, 1)
                            end)


                        end
                    end)
                    local p = 1
                    while true do
                        for a, t in sp.math.AngleIterator(ia * d, bn) do
                            b = bullet_wheel(cx, cy, ir, a, d * ka, kr, 0, beat, 0)
                            table.insert(groups[(d == 1) and t or (t + bn)], b)
                            if p % 2 == 0 then
                                b.hide = true
                                b.colli = false
                            end
                        end
                        d = -d
                        for a, t in sp.math.AngleIterator(ia * d + ka * 2, bn) do
                            b = bullet_wheel(cx, cy, ir, a, d * ka, kr, 0, beat, 0)
                            table.insert(groups[(d == 1) and t or (t + bn)], b)
                            if p % 2 == 1 then
                                b.hide = true
                                b.colli = false
                            end
                        end
                        d = -d
                        ia = ia + da
                        da = da + 0.5
                        p = p + 1
                        task.Wait2(self, beat * 4)
                    end

                end)
            end
            function sc1:other_drop()
                if ran:Float(0, 1) < 0.5 then
                    item.dropItem(item.drop_card, 1, self.x, self.y + 30, 186)
                end
                mission_lib.GoMission(77)
            end

            boss.Create(bclass)
        end, _t("梦你梦外"), nil, nil, true)

