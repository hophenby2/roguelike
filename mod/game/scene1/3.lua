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

lib.NewWaveEventInWaves(class, 36, { 5, 10 }, 1,
        0, 1, function(var)
            local object21 = Class(object, {
                init = function(self)
                    self.x, self.y = player.x, player.y
                    self.group = GROUP.INDES
                    self.layer = LAYER.ENEMY
                    self.colli = false
                    self.alpha = 0
                    self.omega = 0.7
                    PlaySound("explode")
                    local music_round = Class(bullet, { init = function(unit, index, master, t, a, r, o)
                        bullet.init(unit, music, index, false, false)
                        unit.x, unit.y = master.x, master.y
                        unit.bound = false
                        unit.timer = 11
                        unit._a = 0
                        unit.colli = false
                        unit.rot = -90
                        unit.master = master
                        unit.noTPbyYukari = true
                        unit.change = function(id)
                            PlaySound("kira00")
                            if id == 1 then
                                for i = 1, 90 do
                                    unit._a = 255 * sin(i)
                                    task.Wait()
                                end
                            else
                                if unit._a == 0 then
                                    task.Wait(90)
                                else
                                    for i = 1, 90 do
                                        unit._a = 255 - 255 * sin(i)
                                        task.Wait()
                                    end
                                end

                            end
                        end
                        task.New(unit, function()
                            while true do
                                if not IsValid(unit.master) then
                                    object.Del(unit)
                                    return
                                end
                                if unit._a == 255 then
                                    unit.colli = true
                                else
                                    unit.colli = false
                                end
                                unit.x = unit.master.x + cos(a) * unit.master.r * r
                                unit.y = unit.master.y + sin(a) * unit.master.r * r
                                a = a + o
                                task.Wait()
                            end
                        end)
                        task.New(unit, function()
                            while true do
                                unit.change((1 + t) % 2)
                                task.Wait(240)
                                unit.change((2 + t) % 2)
                                task.Wait(240)
                            end
                        end)
                    end }, true)
                    task.New(self, function()
                        for i = 10, 360, 10 do
                            New(music_round, 14, self, 2, i, 1, 2)
                        end
                        for i = 10, 360, 10 do
                            New(music_round, 10, self, 1, i, 0.01, -2)
                        end
                        for i = 1, 90 do
                            self.r = 35 * sin(i)
                            task.Wait()
                        end
                    end)
                    task.New(self, function()
                        while true do
                            self.x = self.x + (-self.x + player.x) * 0.05
                            self.y = self.y + (-self.y + player.y) * 0.05
                            task.Wait()
                        end
                    end)
                end,
                frame = task.Do,
                render = function(self)
                    SetImageState("white", "mul+add", 128, 255, 227, 132)
                    misc.SectorRender(self.x, self.y, self.r - 2, self.r, 0, 360, 40)
                    misc.SectorRender(self.x, self.y, self.r * 0.01 - 2, self.r * 0.01, 0, 360, 40)
                end
            }, true)
            local stg = stage.current_stage
            local bclass = boss.Define(name("LunaChild"), 0, 400, _editor_class.yousei_bg, "LunaChild")
            local sc = boss.card.New("幽寂「月下无声胜有声」", 2, 5, 45, HP(1245))
            boss.card.add(bclass, sc)
            function sc:before()
                self.group = GROUP.NONTJT
                task.MoveToForce(0, 120, 60, 2)
            end
            function sc:init()
                task.New(self, function()
                    task.Wait(60)
                    Newcharge_in(self.x, self.y, 250, 128, 114)
                    task.Wait(60)
                    boss.cast(self, 3600)
                    self.sound = 0.3
                    New(object21)
                    task.New(self, function()
                        while true do
                            Newcharge_in(self.x, self.y, 32, 32, 128)
                            for i = 1, 90 do
                                stage_lib.SetGlobalMusicVolume(self,1 - 0.6 * sin(i))
                                self.sound = 0.1 - 0.05 * sin(i)
                                task.Wait()
                            end
                            task.Wait(240)
                            Newcharge_out(self.x, self.y, 32, 32, 128)
                            for i = 1, 90 do
                                stage_lib.SetGlobalMusicVolume(self, 0.4 + 0.6 * sin(i))
                                self.sound = 0.05 + 0.05 * sin(i)
                                task.Wait()
                            end
                            task.Wait(240)
                        end
                    end)
                    task.Wait(60)
                    local r = 0
                    local d = 45
                    local a
                    local v = 1
                    while true do
                        for c = -1, 1, 2 do
                            for z = -2, 2 do
                                a = -90 + c * r + z * stage_lib.GetValue(1.7, 1.6, 1.4, 0.4)
                                Create.bullet_changeangle(self.x + cos(a) * 30, self.y + sin(a) * 30, arrow_big,
                                        13, 1.5 + v * 0.1 + stage_lib.GetValue(0, 0.8, 1.2, 5.4),
                                        a, { wait = 12, time = 90, r = sin(d) * c })
                            end
                        end
                        PlaySound("tan00", self.sound)
                        r = r + 29
                        v = -v
                        d = d + 9
                        task.Wait(stage_lib.GetValue(4, 3, 3, 1))
                    end
                end)
            end
            function sc:other_drop()
                if ran:Float(0, 1) < 0.5 then
                    item.dropItem(item.drop_card, 1, self.x, self.y + 30, 164)
                end
                mission_lib.GoMission(52)
            end
            function sc:del()
                stage_lib.SetGlobalMusicVolume(self, 1)
            end

            boss.Create(bclass)
        end, _t("只能听见歌声了"), nil, nil, true)
lib.NewWaveEventInWaves(class, 37, { 5, 10 }, 1,
        0, 1, function(var)
            local bclass = boss.Define(name("StarSapphire"), 0, 400, _editor_class.yousei_bg, "StarSapphire")
            local sc = boss.card.New("环星「充满活力的繁星」", 2, 5, 45, HP(1245))
            boss.card.add(bclass, sc)
            function sc:before()
                self.group = GROUP.NONTJT
                task.MoveToForce(0, 120, 60, 2)
            end
            function sc:init()
                local ball_circle = Class(object, {
                    init = function(self, x, y, v, a, r, o)
                        self.x, self.y = x, y
                        self.group = GROUP.INDES
                        self.bound = false
                        self.colli = false
                        object.SetV(self, v, a, true)
                        self.servant = {}
                        self.l = 0
                        self.r = r
                        local b
                        for _a, i in sp.math.AngleIterator(0, 12) do
                            b = NewSimpleBullet(star_small, int(i / 2) % 2 * 4 + 2, self.x, self.y, nil, nil, nil, 2, false)
                            table.insert(self.servant, b)
                            b._rot = _a
                            b._omega = o
                            b.master = self
                            b.frame_other = function(unit)
                                if not IsValid(unit.master) then
                                    object.Del(unit)
                                    return
                                end
                                unit._rot = unit._rot + unit._omega
                                unit.x = unit.master.x + cos(unit._rot) * r * unit.master.l
                                unit.y = unit.master.y + sin(unit._rot) * r * unit.master.l
                            end
                        end
                    end,
                    frame = function(self)
                        self.l = self.l + (-self.l + min(1, 50 / Dist(self, player))) * 0.05
                        sp:UnitListUpdate(self.servant)
                        if #self.servant == 0 then
                            object.Del(self)
                        end
                    end,
                    render = function(self)
                        local alpha = (self.l - 0.5) * 2 * 200
                        if alpha > 0 then
                            SetImageState("white", "mul+add", alpha, 189, 252, 201)
                            misc.SectorRender(self.x, self.y, self.l * self.r - 1, self.l * self.r + 1, 0, 360, math.ceil(40 * self.l), 0)
                        end
                    end
                }, true)
                task.New(self, function()
                    task.Wait(60)
                    Newcharge_in(self.x, self.y, 135, 206, 235)
                    task.Wait(60)
                    boss.cast(self, 3600)
                    task.New(self, function()
                        task.Wait(100)
                        local rot = 0
                        local d = 1
                        local a, b
                        while true do
                            for i = 1, 5 do
                                for c = -2 * d, 2 * d, d do
                                    a = i * 72 + c * d * 2 + rot
                                    b = NewSimpleBullet(grain_a, 4, self.x + cos(a) * (30 + c * 3), self.y + sin(a) * (30 + c * 3),
                                            (1.3 + c * 0.02 + d * 0.1) * stage_lib.GetValue(1, 1.5, 2, 7), a)
                                    b._blend = "mul+add"
                                end
                            end
                            PlaySound("tan00")
                            d = -d
                            rot = rot + 13
                            task.Wait(stage_lib.GetValue(14, 10, 8, 2))
                        end
                    end)
                    while true do
                        local d = 1
                        for a, i in sp.math.AngleIterator(ran:Float(0, 360), int(stage_lib.GetValue(10, 12, 14, 54))) do
                            New(ball_circle, self.x, self.y, stage_lib.GetValue(1.5, 2, 2.5, 3.5), a, 120, 0.3 * d, -90, 0.5)
                            d = -d
                        end
                        task.Wait(stage_lib.GetValue(110, 100, 75, 13))
                    end
                end)

            end
            function sc:other_bonus_drop()
                if ran:Float(0, 1) < 0.5 then
                    item.dropItem(item.drop_card, 1, self.x, self.y + 30, 108)
                end
            end

            boss.Create(bclass)
        end, _t("这不是含羞草"), nil, nil, true)
lib.NewWaveEventInWaves(class, 38, { 5, 10 }, 1,
        0, 1, function(var)
            local bclass = boss.Define(name("SunnyMilk"), 0, 400, _editor_class.yousei_bg, "SunnyMilk")
            local sc = boss.card.New("散光「不会迷路的光亮」", 2, 5, 45, HP(1245))
            boss.card.add(bclass, sc)
            function sc:before()
                self.group = GROUP.NONTJT
                task.MoveToForce(0, 120, 60, 2)
            end
            function sc:init()
                task.New(self, function()
                    task.Wait(60)
                    Newcharge_in(self.x, self.y, 250, 128, 114)
                    task.Wait(60)
                    boss.cast(self, 3600)
                    task.New(self, function()
                        task.Wait(150)
                        Newcharge_out(self.x, self.y, 255, 227, 132)
                        task.New(self, function()
                            local b
                            local rot = 0
                            local orot = 0
                            task.New(self, function()
                                for i = 1, 90 do
                                    rot = 150 * sin(i)
                                    task.Wait()
                                end
                                task.Wait(90)
                                local t = 1
                                while true do
                                    orot = sin(t) * sin(min(90, t)) * 40
                                    t = t + stage_lib.GetValue(0.8, 1, 1.3, 5)
                                    task.Wait()
                                end
                            end)
                            while true do
                                for d = -1, 1, 2 do
                                    for k = 0, 2 do
                                        b = NewSimpleBullet(ellipse, 14, self.x, self.y, 8, 90 + d * rot * (1 - k * 0.2) + orot,
                                                nil, nil, false)
                                        b._blend = "mul+add"
                                        b.timer = 11
                                    end
                                end
                                task.Wait(3)
                            end
                        end)
                        while true do
                            local A = Angle(self, player)
                            local N = int(stage_lib.GetValue(18, 23, 28, 96))
                            for v = 1, 2 do
                                for a in sp.math.AngleIterator(A, N) do
                                    Create.bullet_decel(self.x, self.y, ball_big, 12, 5,
                                            (1 + v * 0.5) * stage_lib.GetValue(1, 1.6, 2.2, 7.4),
                                            v * 180 / N + a, true)
                                end
                            end
                            PlaySound("tan00")
                            task.Wait(stage_lib.GetValue(90, 75, 45, 10))
                        end
                    end)
                    local rot = 90
                    while true do
                        for a = 18, 360, 18 do
                            Create.bullet_dec_setangle(self.x, self.y, grain_b, 2, false,
                                    { v = 5, a = a + rot, time = 20 }, { v = 5, a = a * 2 + rot, time = 20 },
                                    { v = 5, a = a * 3 + rot, time = 20 }, { v = 5, a = a * 4 + rot, time = 20 },
                                    { v = stage_lib.GetValue(3, 3.3, 3.6, 9), a = a * 5 + rot, time = 20 })
                        end
                        rot = rot + sin(min(90, self.timer)) * stage_lib.GetValue(4.8, 5.2, 5.6, 18)
                        task.Wait(12)
                    end
                end)


            end

            boss.Create(bclass)
        end, _t("开飞机"), nil, nil, true)
lib.NewWaveEventInWaves(class, 39, { 6, 7, 8, 9 }, 1,
        0, 1, function(var)
            local stg = stage.current_stage
            local enemy1 = Class(enemy, {
                init = function(self, x, y, vx, vy, ax, ay)
                    enemy.init(self, 32, HP(6), false, true, false, 0.7)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx, vy
                    self.ax, self.ay = ax, ay
                    task.New(self, function()
                        if var.chaos >= 50 then
                            task.Wait(ran:Int(35, 125))
                            for _ = 1, stage_lib.GetValue(5, 8, 15, 75) do
                                Create.bullet_accel(self.x, self.y, ball_mid_c, 6, 0.3, min(10, 2 + var.chaos / 20), -90)
                                PlaySound("tan00")
                                task.Wait(stage_lib.GetValue(40, 20, 7, 1))
                            end
                        end
                    end)
                end,
            }, true)
            local enemy2 = Class(enemy, {
                drop = function(self)
                    New(bullet_cleaner, self.x, self.y, 100, 10, 10, true, false, 0)
                end,
                init = function(self, x, y, mx, my, vx, vy)
                    enemy.init(self, 7, HP(75), false, true, false, 8)
                    self.x, self.y = x, y
                    task.New(self, function()
                        task.MoveTo(mx, my, ran:Int(40, 60), 2)
                        local N = int(stage_lib.GetValue(2, 3, 4, 18))

                        for z = -N, N do
                            for v = 0, stage_lib.GetValue(4, 6, 8, 30) do
                                NewSimpleBullet(knife, 2, self.x, self.y, 2 + v * 0.3, Angle(self, player) + z / N * 60)
                            end
                        end
                        for i = 1, 30 do
                            self.vx = i / 30 * vx
                            self.vy = i / 30 * vy
                            task.Wait()
                        end
                    end)
                end,
            }, true)
            task.New(stg, function()
                for c = 1, 4 do
                    for d = -1, 1, 2 do
                        local x = ran:Float(150, 180)
                        New(enemy2, x * d, 270, x * d, ran:Float(130, 150), -d * 1.8, 0)
                    end
                    task.Wait(230 - c * 15)
                end
            end)
            for k = 1, 60 do
                local d = ran:Sign()
                New(enemy1, ran:Float(150, 300) * d, 260, 0, -ran:Float(3, 4), -d * ran:Float(0.02, 0.04), 0.02)
                task.Wait(15 - k / 60 * 6)
            end
            task.Wait(90)
            for d = -1, 1 do
                local x = ran:Float(150, 180)
                New(enemy2, x * d, 270, x * d, ran:Float(130, 150), -d * 1.8, -1)
            end
        end, _t("源源会断"))
lib.NewWaveEventInWaves(class, 40, { 6, 7, 8, 9 }, 1,
        0, 1, function(var)
            local stg = stage.current_stage
            local enemy1 = Class(enemy, {
                drop = function(self)
                    New(bullet_cleaner, self.x, self.y, 20, 1, 2, true, false, 0)
                end,
                init = function(self, x, y, vx, vy, ax, ay)
                    enemy.init(self, 32, HP(6), false, true, false, 0.4)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx, vy
                    self.ax, self.ay = ax, ay
                    task.New(self, function()
                        for _ = 1, stage_lib.GetValue(5, 8, 15, 75) do
                            Create.bullet_accel(self.x, self.y, arrow_big, 6, 0.3, min(10, 2 + var.chaos / 20), -90)
                            PlaySound("tan00")
                            task.Wait(stage_lib.GetValue(40, 20, 7, 1))
                        end
                    end)
                end,
            }, true)
            local enemy2 = Class(enemy, {
                drop = function(self)
                    New(bullet_cleaner, self.x, self.y, 100, 10, 10, true, false, 0)
                end,
                init = function(self, x, y, mx, my, vx, vy)
                    enemy.init(self, 7, HP(75), false, true, false, 8)
                    self.x, self.y = x, y
                    task.New(self, function()
                        task.MoveTo(mx, my, ran:Int(40, 60), 2)
                        local N = int(stage_lib.GetValue(2, 3, 4, 2))

                        for z = -N, N do
                            for v = 0, stage_lib.GetValue(4, 6, 8, 30) do
                                NewSimpleBullet(knife, 2, self.x, self.y, 2 + v * 0.3, Angle(self, player) + z / N * 60)
                            end
                        end
                        for i = 1, 30 do
                            self.vx = i / 30 * vx
                            self.vy = i / 30 * vy
                            task.Wait()
                        end
                    end)
                end,
            }, true)
            for k = 1, 120 do
                for d = -1, 1, 2 do
                    New(enemy1, ran:Float(0, 330) * d, 260, 0, -ran:Float(3, 4), -d * ran:Float(0.02, 0.04), 0.02)
                end
                task.Wait(max(1, 14 - k / 120 * 16))
            end
            for d = -1, 1 do
                local x = ran:Float(150, 180)
                New(enemy2, x * d, 270, x * d, 120, -d * 1.8, -1)
            end
        end, _t("源源不断"))
lib.NewWaveEventInWaves(class, 41, { 6, 7, 8, 9 }, 1,
        0, 1, function(var)
            local stg = stage.current_stage
            local enemy1 = Class(enemy, {
                init = function(self, x, y, vx1, vy1, vx2, vy2)
                    enemy.init(self, 6, HP(9), false, true, false, 1)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx1, vy1
                    task.New(self, function()
                        task.Wait(ran:Int(35, 125))
                        for _ = 1, 2 do
                            local N = int(stage_lib.GetValue(2, 3, 4, 2))
                            for z = -N, N do
                                NewSimpleBullet(ball_small, 2, self.x, self.y,
                                        stage_lib.GetValue(1.5, 2, 2.8, 4), Angle(self, player) + z * 2.5)
                            end

                            PlaySound("tan00")
                            task.Wait(stage_lib.GetValue(100, 75, 50, 75))
                        end
                    end)
                    task.New(self, function()
                        task.Wait(60)
                        for i = 1, 60 do
                            self.vx = vx1 + (vx2 - vx1) * (i / 60)
                            self.vy = vy1 + (vy2 - vy1) * (i / 60)
                            task.Wait()
                        end
                    end)
                end,
            }, true)
            local enemy2 = Class(enemy, {
                init = function(self, x, y, mx, my, vx, vy)
                    enemy.init(self, 15, HP(65), false, true, false, 5)
                    self.x, self.y = x, y
                    task.New(self, function()
                        task.MoveTo(mx, my, 60, 2)
                        task.New(self, function()
                            for _ = 1, stage_lib.GetValue(3, 4, 5, 18) do
                                for a in sp.math.AngleIterator(Angle(self, player), int(stage_lib.GetValue(18, 24, 30, 100))) do
                                    NewSimpleBullet(ball_mid, 6, self.x, self.y,
                                            stage_lib.GetValue(2, 2.8, 3.6, 13), a)
                                end
                                PlaySound("tan00")
                                task.Wait(stage_lib.GetValue(90, 60, 30, 5))
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
                    for _ = 1, 8 do
                        New(enemy1, 150 * d, 270, 0, -2.7, -d * 2.5, 0)
                        New(enemy1, 200 * d, 270, 0, -3, -d * 2, 0)
                        task.Wait(13)
                    end
                end)
                task.Wait(60)
                for _ = 1, 6 do
                    local x = -d * ran:Float(0, 120)
                    New(enemy2, x, 280, x, ran:Float(100, 150), 1.5 * d, 0)
                    task.Wait(45)
                end
                d = -d
            end
            task.Wait(60)
        end, _t("不再寻觅"))
lib.NewWaveEventInWaves(class, 42, { 3, 4, 6, 7 }, 1,
        0, 1, function(var)
            local enemy2 = Class(enemy, {
                drop = function(self)
                    New(bullet_cleaner, self.x, self.y, 500, 1, 2, true, false, 0)
                end,
                init = function(self, x, y, mx, my, v, A, color, adw)
                    enemy.init(self, 9, HP(250), false, true, false, 16)
                    self.x, self.y = x, y
                    task.New(self, function()
                        task.MoveTo(mx, my, 90, 2)
                        task.Wait(200)
                        object.ChangingV(self, 0, v, A, 80, false)
                    end)
                    task.New(self, function()
                        task.Wait(20)
                        adw = adw or 0
                        for _ = 1, 240 do
                            for _ = 1, stage_lib.GetValue(1, 1, 2, 10) + adw do
                                local bv = stage_lib.GetValue(3, 4, 5, 15)
                                local bv_r = ran:Float(bv * 0.7, bv * 1.3)
                                local fogtime = ran:Int(11, 20)
                                local b = Create.bullet_accel(self.x, self.y, ball_mid, color or 2, bv_r * 0.3, bv_r, ran:Float(0, 360))
                                b.wait = fogtime
                                b.time = 5
                                b.fogtime = fogtime
                                b.stay = false
                            end
                            PlaySound("tan00")
                            task.Wait()
                        end
                    end)
                end,
            }, true)
            New(enemy2, 0, 300, 0, 100, 1, -90)
            task.Wait(220)
            for c = 1, 3 do
                for d = -1, 1, 2 do
                    New(enemy2, -320 * d, 300, -c * 50 * d, 100, 2, -90 + 85 * d)
                end
                task.Wait(350 - c * 60)
            end
            task.Wait(280)
            New(enemy2, 0, 300, 0, 100, 1, -90, 6, 1)
        end, _t("永恒的暴力"))
lib.NewWaveEventInWaves(class, 43, { 3, 4, 6, 7 }, 1,
        0, 1, function(var)
            local enemy2 = Class(enemy, {
                drop = function(self)
                    New(bullet_cleaner, self.x, self.y, 111, 1, 2, true, false, 0)
                end,
                init = function(self, x, y, mx, my, v, A, d)
                    enemy.init(self, 15, HP(250), false, true, false, 45)
                    self.x, self.y = x, y
                    self.servant_back = true
                    task.New(self, function()
                        task.MoveTo(mx, my, 90, 2)
                        task.Wait(250)
                        object.ChangingV(self, 0, v, A, 80, false)
                        task.Wait(650)
                        Del(self)
                    end)
                    task.New(self, function()
                        local N = int(stage_lib.GetValue(7, 9, 12, 45))
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
                                                local b = NewSimpleBullet(ball_mid_c, 6, unit.x, unit.y,
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
                                        local b = NewSimpleBullet(ball_mid_c, 2, unit.x, unit.y,
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
            task.Wait(380)
            New(enemy2, 500, 300, 0, 100, 1, -5, -1)
        end, _t("藏起夜空珠的公主"))