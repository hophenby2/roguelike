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

lib.NewWaveEventInWaves(class, 20, { 20 }, 1,
        0, 1, function(var)
            local smearer = Class(object, {
                init = function(self, master)
                    self.master = master
                    self.smear = {}
                    self.group = GROUP.GHOST
                    self.layer = LAYER.ENEMY - 1
                    self.stop = false
                end,
                frame = function(self)
                    if not IsValid(self.master) then
                        Del(self)
                        return
                    end
                    if not self.stop then
                        if self.timer % 3 == 0 then
                            table.insert(self.smear, {
                                x = self.master.x,
                                y = self.master.y,
                                rot = self.master.rot,
                                hscale = self.master.hscale,
                                vscale = self.master.vscale,

                                img = self.master.img,
                                alpha = 150,
                            })
                        end
                    end
                    for i = #self.smear, 1, -1 do
                        local s = self.smear[i]
                        s.alpha = max(s.alpha - 10, 0)
                        if s.alpha <= 0 then
                            table.remove(self.smear, i)
                        end
                    end
                    if #self.smear == 0 then
                        Del(self)
                    end
                end,
                render = function(self)
                    for _, s in ipairs(self.smear) do
                        SetImageState(s.img, "mul+add", Color(s.alpha, 218, 112, 214))
                        Render(s.img, s.x, s.y, s.rot, s.hscale, s.vscale)
                    end
                end
            }, true)
            local bclass = boss.Define(name("Byakuren"), -400, 0, _editor_class.byakuren_bg, "Byakuren")

            local non_sc1 = boss.card.New("", 1, 4, 40, HP(1100))
            boss.card.add(bclass, non_sc1)
            function non_sc1:before()
                local smearobj = New(smearer, self)
                lstg.tmpvar.otherMusic = "3_boss1"
                lstg.tmpvar.otherMusic_start_time = 214.93 - 180 / 60
                boss.show_aura(self, false)
                task.New(self, function()
                    if setting.displayBG and lstg.tmpvar.bg.class ~= BG_7 then
                        self.replaced_bg = lstg.tmpvar.bg.class
                        task.New(self, function()
                            local curfog = lstg.view3d.fog
                            local foga, fogb = curfog[1], curfog[2]
                            local fogcol = curfog[3]
                            local midcol = Color(255, 0, 0, 0)
                            local targetcol = Color(255, 0, 0, 0)
                            for i = 1, 100 do
                                i = i / 100
                                foga = curfog[1] * (1 - i)
                                fogb = curfog[2] * (1 - i)
                                fogcol = curfog[3] * (1 - i) + midcol * (i)
                                Set3D('fog', foga, fogb + 0.00001, fogcol)
                                task.Wait()
                            end
                            for i = 1, 80 do
                                i = i / 80
                                foga = 4 * i
                                fogb = 6 * i
                                fogcol = targetcol * i + midcol * (1 - i)
                                Set3D('fog', foga, fogb, fogcol)
                                task.Wait()
                            end
                        end)
                    end
                    task.BezierMoveTo(100, 2, 0, 50, -120, 100)
                    if setting.displayBG and lstg.tmpvar.bg.class ~= BG_7 then
                        background.Create(BG_7)
                    end
                    --Set3D('fog', 0, 0, Color(0, 0, 0, 0))
                    task.BezierMoveTo(80, 3, -50, 120, 0, 120)
                end)
                task.Wait(120)
                boss.show_aura(self, true)
                Newcharge_in(0, 120, 250, 128, 114)
                task.Wait(60)
                smearobj.stop = true
            end
            function non_sc1:init()
                local accel_laser = function(x, y, v, a, bv, wait, time)
                    local self = Create.laser_line(x, y, 8, v, a, 35, 8, 5, 8)
                    task.New(self, function()
                        task.Wait(wait)
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
                task.New(self, function()
                    local d = 1
                    while true do
                        boss.cast(self, 150)
                        Newcharge_out(self.x, self.y, 250, 128, 114, true)
                        PlaySound("kira00")
                        task.New(self, function()
                            task.Wait(210 - 60)
                            task.MoveToPlayer(60, -200, 200, 80, 120,
                                    20, 40, 10, 20, 2, 1)
                        end)
                        local v
                        local da = stage_lib.GetValue(14, 10, 8, 2)
                        local kt = stage_lib.GetValue(25, 35, 45, 100)
                        local t = stage_lib.GetValue(4, 3, 2, 1)
                        local lw = int(stage_lib.GetValue(10, 15, 20, 60))
                        local gt = stage_lib.GetValue(120, 120, 80, 45)
                        for z = -1.5, 1.5 do
                            local A = -90 + z * 80 * d
                            servant.init(NewObject(servant), self.x, self.y, 0, 135, 206, 235, 1.5, function(unit)
                                task.New(unit, function()
                                    unit:FadeIn(15)
                                    object.ChangingSizeColli(unit, -0.5, -0.5, 15)
                                end)
                                task.New(unit, function()
                                    object.ChangeVwithTask(unit, 4, 0, A, 60, 0, false)

                                    for i = 1, kt do
                                        v = stage_lib.GetValue(1.5, 1.8, 2.5, 7) + i / 35
                                        for a in sp.math.AngleIterator(A + i * da * d, 2) do
                                            local x, y = unit.x + cos(a * 1.5) * 10, unit.y + sin(a * 1.5) * 10
                                            if Dist(x, y, player) > 64 then
                                                for w = 1, 2 do
                                                    Create.bullet_decel(x, y, grain_a, 6, 4,
                                                            v * (0.8 + w * 0.1), a, false, false)
                                                end
                                                PlaySound("tan00")
                                            end
                                        end

                                        task.Wait(t)
                                    end
                                    for a in sp.math.AngleIterator(-90, lw) do
                                        accel_laser(unit.x, unit.y, 0.5, a, 12, 35, gt)
                                    end
                                    object.ChangingSizeColli(unit, -1, -1, 15)
                                    Del(unit)
                                end)
                            end)
                        end
                        task.Wait(kt * t)
                        local wt = 35 + gt
                        for k = 1, 4 do
                            for a in sp.math.AngleIterator(ran:Float(0, 360), int(stage_lib.GetValue(10, 15, 25, 100))) do
                                Create.bullet_decel(self.x, self.y, ball_big, 4, v, v * 0.6, a, true, false)
                            end
                            task.Wait(wt / 4)
                        end
                        d = -d
                    end
                end)
            end

            local sc1 = boss.card.New("命运「火烧比叡山」", 2, 4, 40, HP(1600))
            boss.card.add(bclass, sc1)
            function sc1:before()
                task.Wait(60)
            end
            function sc1:init()
                task.New(self, function()
                    task.MoveToForce(0, 120, 60, 2)
                    Newcharge_in(self.x, self.y, 250, 128, 114)
                    task.Wait(60)
                    local attack = function(x, y, v, a, ag, H)
                        local self = NewObject(bullet)
                        bullet.init(self, water_drop, 15, false, true)
                        self.reb_flag = 1
                        self.x, self.y = x, y
                        object.SetV(self, v, a, true)
                        self.ag = ag
                        self.navi = true
                        self._blend = "add+add"
                        self._r, self._g, self._b = sp:HSVtoRGB(H, 1, 0.4)
                        local t = { "b" }
                        PlaySound("tan00")
                        local w = lstg.world
                        task.New(self, function()
                            while self.reb_flag > 0 do
                                object.ReBound(self, t, nil, self.reb_flag > 0, function()
                                    self.reb_flag = self.reb_flag - 1
                                end)
                                task.Wait()
                            end
                        end)
                    end
                    local d = 1
                    while true do
                        task.New(self, function()
                            local N = stage_lib.GetValue(5, 8, 13, 40)
                            for k = 1, N do
                                local c = 1 + k * 2
                                local _c = (c - 1) / 2
                                for z = -_c, _c do
                                    Create.bullet_decel(self.x, self.y, ball_big, 4, 7, 4, 90 + (z / _c) * 50, true)
                                end
                                for z = -_c, _c do
                                    Create.bullet_accel(self.x, self.y, ball_big, 6, 2, 5, -90 + z * (30 - k))
                                end
                                PlaySound("tan00")
                                task.Wait(260 / N)
                            end
                        end)
                        local kt = stage_lib.GetValue(5, 6, 8, 30)
                        for k = 1, 25 do
                            for t = -2, 2 do
                                for h = 0, kt do
                                    local A = -90 + t * t * t * 30 + k * 2 * d + h * 0.5 * d
                                    attack(self.x, self.y, 3, A, 0.03 + h * min(0.054 / kt, 0.006), sin(h * 36) * 20)
                                end
                            end
                            task.Wait(3)
                        end
                        d = -d
                        task.Wait(300)
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
                    self.back = New(_editor_class.ByakurenBack, self)
                    local d = 1
                    self.cast_t = 0
                    task.Wait(60)
                    Newcharge_in(self.x, self.y, 250, 128, 114)
                    task.Wait(60)
                    while true do
                        task.New(self, function()
                            local A = Angle(self, player)
                            local m = int(stage_lib.GetValue(2, 3, 5, 18))
                            for k = 1, stage_lib.GetValue(4, 5, 8, 12) do
                                for z = -m, m do
                                    local A1 = A + 90 * d + z * 20 - k * 18 * d
                                    local A2 = A - 90 * d + z * 20 + k * 18 * d
                                    Create.bullet_accel(self.x, self.y, ball_big, 4, 1, 3, A1, true)
                                    Create.bullet_accel(self.x, self.y, ball_huge, 4, 1, 4, A2, true)

                                end
                                task.Wait(18)
                            end
                            task.MoveToPlayer(60, -150, 150, 100, 144,
                                    30, 45, 12, 24, 2, 1)
                        end)
                        local rot = 0
                        local spl = int(stage_lib.GetValue(4, 6, 9, 15))
                        for c = 1, 50 do
                            for _, p in ipairs(self.back.back_c) do
                                local x, y = self.x + p.x, self.y + p.y
                                local pd = sign(p.x)
                                for a in sp.math.AngleIterator(-90 + rot * pd, int(stage_lib.GetValue(3, 3, 4, 10))) do
                                    Create.bullet_changeangle(x, y, arrow_big_c, 1, 4, a,
                                            { wait = 20, r = d * pd * (0.4 - c % spl / spl * 0.6) * (1 - p.t * 0.5 + 0.5) * spl / 4, time = 120, v = 1 })

                                end
                                PlaySound("tan00")
                            end
                            task.Wait(3)
                            rot = rot + 4 * d
                        end
                        d = -d
                        for i, p in ipairs(self.back.back_c) do
                            local x, y = self.x + p.x, self.y + p.y
                            for a in sp.math.AngleIterator(Angle(x, y, player), int(stage_lib.GetValue(10, 20, 30, 90))) do
                                for v = 0, stage_lib.GetValue(1, 2, 3, 10) do
                                    local b = Create.bullet_accel(x, y, ball_big, 13, 1, 2 + v * 0.6, a)
                                    object.SetSizeColli(b, 10 / (v + 10))
                                end
                            end
                            PlaySound("tan00")
                            task.Wait((i + 1) % 2 * 15)
                        end
                        task.Wait(stage_lib.GetValue(150, 140, 130, 80))
                    end

                end)
            end

            local sc2 = boss.card.New("飞钵「磬钵飞行」", 2, 4, 40, HP(1600))
            boss.card.add(bclass, sc2)
            function sc2:before()
                task.Wait(60)
            end
            function sc2:init()
                task.New(self, function()
                    task.MoveToForce(0, 120, 60, 2)
                    Newcharge_in(self.x, self.y, 250, 128, 114)
                    task.Wait(60)
                    local square = function(center, a, o, col)
                        local self = NewObject(bullet)
                        bullet.init(self, square, col, false, true)
                        self.x, self.y = center.x, center.y
                        self.bound = false
                        self._blend = "mul+add"
                        task.New(self, function()
                            while IsValid(center) do
                                self.x = center.x + cos(a) * center.radius
                                self.y = center.y + sin(a) * center.radius
                                self.rot = a + 75 * sign(o)
                                a = a + o
                                task.Wait()
                            end
                            Del(self)
                        end)
                    end
                    local square_center = function(x, y, v, a, time, R, ia, N, ome, col)
                        local self = NewObject(Class(object, {
                            frame = function(self)
                                task.Do(self)
                                local w = lstg.world
                                if not BoxCheck(self, w.boundl - self.radius, w.boundr + self.radius, w.boundb - self.radius, w.boundt + self.radius) then
                                    Del(self)
                                end
                            end,
                            render = function(self)
                                local pcol = ColorList[math.ceil(col / 2)]
                                SetImageState("white", "mul+add", 45, pcol[1], pcol[2], pcol[3])
                                misc.SectorRender(self.x, self.y, self.radius - 1, self.radius + 1, 0, 360, 40, ia + ome * self.timer)
                            end
                        }, true))
                        self.group = GROUP.INDES
                        self.x, self.y = x, y
                        self.bound = false
                        object.SetV(self, v, a)
                        self.radius = 0
                        for sa in sp.math.AngleIterator(ia, N) do
                            square(self, sa, ome, col)
                        end
                        task.New(self, function()
                            for i = 1, time do
                                self.radius = task.SetMode[2](i / time) * R
                                task.Wait()
                            end
                        end)

                    end
                    local tt = 1
                    local col = 4
                    task.New(self, function()
                        task.Wait(120)
                        boss.cast(self, 333333)
                        while true do
                            for a in sp.math.AngleIterator(Angle(self, player), int(stage_lib.GetValue(13, 20, 28, 75))) do
                                Create.bullet_changeangle(self.x, self.y, ball_huge, col,
                                        stage_lib.GetValue(1.8, 2.3, 3, 10), a)
                            end
                            PlaySound("tan00")
                            task.Wait(stage_lib.GetValue(75, 58, 45, 10))
                        end
                    end)
                    while true do
                        local K = 15
                        local A = ran:Float(0, 360)
                        for c = 1, K do
                            for _, p in ipairs(self.back.back_c) do
                                if p.t == tt then
                                    local x, y = self.x + p.x, self.y + p.y
                                    local pd = sign(p.x)
                                    local ptd = (p.t * 2 - 3)
                                    square_center(x, y, 1.5 * (1 - 0.5 * c / K), -90, 126 + p.t * 50,
                                            250, -c / K * 80 * pd * ptd + A, int(stage_lib.GetValue(5, 6, 8, 50)),
                                            (0.1 + c / K * 0.25) * pd * ptd, 18 - col)
                                end
                                PlaySound("tan00")
                            end
                            task.Wait(4)
                        end
                        tt = tt % 2 + 1
                        col = ran:Int(1, 8) * 2
                        task.Wait(stage_lib.GetValue(400, 375, 350, 100))
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
                    local shoot_laser = Class(laser, {
                        init = function(self, x, y, rot, col, w, time, life)
                            laser.init(self, col, x, y, rot, 0, 0, 0, w, w, 0)
                            laser._TurnHalfOn(self, 0, false)
                            self.line = 0
                            self.Isradial = true
                            local n1, n2 = life * 0.6, life * 0.4
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
                    local d = 1
                    self.cast_t = 0
                    task.Wait(60)
                    Newcharge_in(self.x, self.y, 250, 128, 114)
                    task.Wait(60)
                    local snakey = function(x, y, v, a, rg, is, os, col)
                        local self = NewObject(bullet)
                        bullet.init(self, grain_a, col, false, true)
                        self.x, self.y = x, y
                        object.SetV(self, v, a, true)
                        self.v = v
                        self.angle = a
                        task.New(self, function()
                            while true do
                                object.SetV(self, self.v, self.angle + sin(is) * rg, true)
                                is = is + os
                                task.Wait()
                            end
                        end)
                    end
                    while true do
                        local rot = 0
                        local px, py = player.x, player.y
                        local sN = int(stage_lib.GetValue(10, 13, 17, 56))
                        for c = 1, 10 do
                            for _, p in ipairs(self.back.back_c) do
                                local x, y = self.x + p.x, self.y + p.y
                                for a in sp.math.AngleIterator(Angle(x, y, px, py), sN) do
                                    for k = 1, 2 do
                                        snakey(x, y, 3, a, 30, c * 3 + k * 180, 4, 14)
                                    end
                                end
                                PlaySound("tan00")
                            end
                            task.Wait(4)
                            rot = rot + 4 * d
                        end
                        for _, p in ipairs(self.back.back_c) do
                            local x, y = self.x + p.x, self.y + p.y
                            for a in sp.math.AngleIterator(Angle(x, y, px, py), sN) do
                                New(shoot_laser, x, y, a, 14, 8, 60, 60)
                            end

                        end
                        Newcharge_in(self.x, self.y, 250, 128, 114)

                        task.Wait(60)
                        local A = Angle(self, player)
                        local N = int(stage_lib.GetValue(18, 25, 36, 110))
                        for a in sp.math.AngleIterator(A, N * 2) do
                            New(shoot_laser, self.x, self.y, a, 2, 20, 30, 120)
                        end
                        task.Wait(30)
                        for v = 0, 5 do
                            for a in sp.math.AngleIterator(A + 180 / N * v, N) do
                                local b = Create.bullet_dec_acc(self.x, self.y, ball_light, 2, 4, 4 - v * 0.3, a, true, false)
                                b.time2 = 0
                                b.time3 = 60
                            end
                            task.Wait(5)
                        end
                        d = -d
                        task.Wait(stage_lib.GetValue(80, 60, 40, 15))
                    end

                end)
            end

            local sc3 = boss.card.New("意马「缚心猿锁六耗」", 2, 10, 60, HP(3300))
            boss.card.add(bclass, sc3)
            function sc3:before()
                task.Wait(60)
            end
            function sc3:init()
                task.New(self, function()
                    local shoot_laser = Class(laser, {
                        init = function(self, x, y, rot, col, w, time, life)
                            laser.init(self, col, x, y, rot, 0, 0, 0, w, w, 0)
                            laser._TurnHalfOn(self, 0, false)
                            self.line = 0
                            self.Isradial = true
                            local n1, n2 = life * 0.6, life * 0.4
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
                    task.MoveToForce(0, 120, 60, 2)
                    Newcharge_in(self.x, self.y, 250, 128, 114)
                    task.Wait(60)
                    boss.cast(self, 333333)
                    local d = 1
                    task.New(self, function()
                        task.Wait(120)
                        while true do
                            for a in sp.math.AngleIterator(Angle(self, player), int(stage_lib.GetValue(13, 20, 28, 75))) do
                                New(shoot_laser, self.x, self.y, a, 3, 8, 30, 50)
                            end
                            task.Wait(stage_lib.GetValue(150, 130, 120, 80))
                        end
                    end)
                    local rot = 0
                    local j = 3
                    while true do
                        local px, py = player.x, player.y
                        local tp = int(stage_lib.GetValue(13, 18, 23, 100))
                        for _ = 1, tp do
                            for _, p in ipairs(self.back.back_c) do
                                local x, y = self.x + p.x, self.y + p.y
                                local cd = sign(p.x) * (p.t * 2 - 3)
                                local A = Angle(x, y, px, py) + rot * cd
                                local KR = 300
                                for a in sp.math.AngleIterator(Angle(x, y, px, py), int(stage_lib.GetValue(18, 18, 12, 14))) do
                                    local targx, targy = x + cos(A) * KR + cos(a) * 100, y + sin(A) * KR + sin(a) * 100
                                    local sA, sR = a * 3 + 90 * cd, 20
                                    local sx, sy = x + cos(sA) * sR, y + sin(sA) * sR
                                    local cv = Dist(sx, sy, targx, targy) / 100
                                    local b = Create.bullet_accel(sx, sy, ball_mid, 2, cv * 0.3,
                                            cv, Angle(sx, sy, targx, targy))
                                    b.laser_angle = a + 180
                                end
                                PlaySound("tan00")
                            end
                            rot = rot + tp / 15 * 50 * d
                            task.Wait(450 / tp)
                        end
                        Newcharge_in(self.x, self.y, 250, 128, 114)
                        task.Wait(60)
                        local T = int(stage_lib.GetValue(75, 60, 55, 30))
                        object.BulletDo(function(b)
                            if b.laser_angle then
                                Del(b)
                                New(shoot_laser, b.x, b.y, b.laser_angle, 2, 6, T, 50)
                            end
                        end)
                        task.Wait(T)
                        for a in sp.math.AngleIterator(Angle(self, player), int(stage_lib.GetValue(25, 31, 40, 123))) do
                            for v = 0, j do
                                Create.bullet_accel(self.x, self.y, ball_huge, 2, 1.5,
                                        stage_lib.GetValue(2, 3, 4, 5) + v, a)
                            end
                        end
                        j = j + 1
                        task.Wait(stage_lib.GetValue(50, 40, 30, 5))
                    end
                end)
            end
            function sc3:del()
                if var.wave ~= var.maxwave then
                    lstg.tmpvar.otherMusic = nil
                    if self.replaced_bg then
                        background.Create(self.replaced_bg)
                    end
                end
            end
            function sc3:other_drop()
                mission_lib.GoMission(66)
                mission_lib.GoMission(67)
                mission_lib.GoMission(68)
                if var.wave ~= var.maxwave then
                    item.dropItem(item.drop_card, 1, self.x, self.y + 30, 214)
                end
            end
            boss.Create(bclass)
        end, _t("游行圣"), false, true, true)

lib.NewWaveEventInWaves(class, 21, { 1, 2, 3, 4, 18 }, 1,
        0, 1, function(var)
            local enemy1 = Class(enemy, {
                init = function(self, x, y, vx1, vy1, vx2, vy2)
                    enemy.init(self, 6, HP(10), false, false, false, 1)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx1, vy1
                    task.New(self, function()
                        task.Wait(ran:Int(30, 90))
                        while true do
                            Create.bullet_decel(self.x, self.y, ball_mid, 2, 4,
                                    stage_lib.GetValue(1, 5, 7, 11), Angle(self, player) + ran:Float(-30, 30))
                            PlaySound("tan00")
                            local t = int(stage_lib.GetValue(90, 55, 20, 2))
                            task.Wait(t)
                        end
                    end)
                    task.New(self, function()
                        task.Wait(30)
                        for i = 1, 36 do
                            self.vx = vx1 + (vx2 - vx1) * (i / 30)
                            self.vy = vy1 + (vy2 - vy1) * (i / 48)
                            task.Wait()
                        end
                        task.Wait(380)
                        Del(self)
                    end)
                end,
            }, true)
            local enemy2 = Class(enemy, {
                init = function(self, x, y, mx, my, vx, vy)
                    enemy.init(self, 14, HP(130), false, true, false, 12)
                    self.x, self.y = x, y
                    task.New(self, function()
                        task.MoveTo(mx, my, 60, 2)
                        task.New(self, function()
                            local sty = ({ ball_mid, ball_big, ball_huge })[stage_lib.GetValue()]
                            for _ = 1, int(stage_lib.GetValue(2, 4, 5, 24)) do
                                for a in sp.math.AngleIterator(Angle(self, player) + ran:Float(-30, 30), 6) do
                                    Create.bullet_decel(self.x, self.y, sty, 4,
                                            stage_lib.GetValue(1, 4, 5, 27),
                                            stage_lib.GetValue(2, 4, 6, 21), a)
                                end
                                PlaySound("tan00")
                                task.Wait(int(stage_lib.GetValue(60, 30, 10, 2)))
                            end
                        end)
                        task.Wait(240)
                        for i = 1, 60 do
                            self.vx = i / 60 * vx
                            self.vy = i / 60 * vy
                            task.Wait()
                        end
                    end)
                end,
            }, true)
            for _ = 1, 24 do
                New(enemy1, 380, ran:Float(120, 200), -1, -0.2, ran:Float(-1.9, -2.2), ran:Float(-0.1, -0.2))
                task.Wait(12)
            end
            task.Wait(30)
            for _ = 1, 24 do
                New(enemy1, -380, ran:Float(120, 220), 1, -0.2, ran:Float(1.9, 2.2), ran:Float(-0.1, -0.2))
                task.Wait(12)
            end
            task.Wait(30)
            New(enemy2, -360, 100, -150, 100, 0, -1)
            for _ = 1, 16 do
                New(enemy1, 380, ran:Float(30, 70), -1, -0.2, ran:Float(-1.9, -2.2), ran:Float(-0.1, -0.2))
                task.Wait(12)
            end
            task.Wait(30)
            New(enemy2, 360, 100, 150, 100, 0, -1)
            for _ = 1, 16 do
                New(enemy1, -380, ran:Float(30, 70), 1, -0.2, ran:Float(1.9, 2.2), ran:Float(-0.1, -0.2))
                task.Wait(12)
            end
            task.Wait(30)
        end, _t("难顾归路"))
lib.NewWaveEventInWaves(class, 22, { 6, 7, 8, 9, 16 }, 1,
        0, 1, function(var)

            local stg = stage.current_stage
            local rain_enemy = Class(enemy, {
                init = function(self, x, y, vx1, vy1, A)
                    enemy.init(self, 24, HP(18), false, true, false, 1.1)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx1, vy1
                    task.New(self, function()
                        while true do
                            local b = NewSimpleBullet(ball_mid, ran:Int(9, 11), self.x, self.y, 3, 90 + ran:Float(-30, 30))
                            b.stay = false
                            PlaySound("tan00")
                            task.New(b, function()
                                for i = 1, stage_lib.GetValue(120, 160, 180, 240) do
                                    b.vy = b.vy - stage_lib.GetValue(0.04, 0.045, 0.05, 0.1)
                                    task.Wait(1)
                                end
                            end)
                            task.Wait(stage_lib.GetValue(40, 18, 6, 1))
                        end
                    end)
                end,
            }, true)
            for c = 1, 3 do
                for d = -1, 1, 2 do
                    task.New(stg, function()
                        local t = 36
                        for i = 1, 16 do
                            local B = 90 - (84 + 35 * task.SetMode[2](i / 32)) * d
                            local k = 3.5
                            New(rain_enemy, -400 * d, 140, cos(B) * k, sin(B) * k, B - 90 * d)
                            task.Wait(23)
                            t = max(1, t - 1)
                        end
                    end)
                    task.Wait(300 - c * 50)
                end
            end
        end, _t("金风玉露"))
lib.NewWaveEventInWaves(class, 23, { 2, 3, 4, 19 }, 1,
        0, 1, function(var)
            local stg = stage.current_stage
            local enemy1 = Class(enemy, {
                init = function(self, x, y, vx1, vy1)
                    enemy.init(self, 19, HP(10), false, true, false, 3)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx1, vy1
                    task.New(self, function()
                        task.Wait(5)
                        for _ = 1, stage_lib.GetValue(5, 15, 30, 60) do
                            Create.bullet_accel(self.x, self.y, ball_mid, 8, 0.4,
                                    stage_lib.GetValue(1, 2, 4, 15), -90 + ran:Float(-30, 30))
                            PlaySound("tan00")
                            task.Wait(int(stage_lib.GetValue(65, 45, 20, 2)))
                        end
                    end)
                    task.New(self, function()
                        task.Wait(200)
                        for i = 1, 18 do
                            self.vx = vx1 + vx1 * (i / 36)
                            self.vy = vy1 + vy1 * (i / 36)
                            task.Wait()
                        end
                        task.Wait(480 + ran:Float(-60, 30))
                        Del(self)
                    end)
                end,
            }, true)
            local enemy2 = Class(enemy, {
                drop = function(self)
                    New(bullet_cleaner, self.x, self.y, 100, 10, 10, true, false, 0)
                end,
                init = function(self, x, y, vx, vy, d)
                    enemy.init(self, 12, HP(13), false, true, false, 6)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx, vy
                    task.New(self, function()
                        task.Wait(ran:Int(40, 60))
                        for r = 1, 15 do
                            local v = stage_lib.GetValue(0.8, 2, 5, 20)
                            for a in sp.math.AngleIterator(r * d * 25, int(stage_lib.GetValue(5, 9, 13, 80))) do
                                Create.bullet_accel(self.x, self.y, arrow_big_c, 4, v * 0.5, v, a)
                            end
                            PlaySound("tan00")
                            task.Wait(int(stage_lib.GetValue(70, 50, 32, 8)))
                        end
                    end)
                end,
            }, true)
            task.New(stg, function()
                for _ = 1, 6 do
                    for d = -1, 1, 2 do
                        New(enemy2, -360 * d, ran:Float(-110, -80), 2.6 * d, 0.8, d)
                    end
                    task.Wait(160)
                end
            end)
            local C = stage_lib.GetValue(24, 30, 45, 120)
            for _ = 1, C do
                New(enemy1, ran:Float(-300, 300), 260, ran:Float(-0.6, 0.6), -stage_lib.GetValue(1, 2, 3, 8))
                task.Wait(960 / C)
            end

        end, _t("不上不下"))
lib.NewWaveEventInWaves(class, 24, { 3, 4, 5, 6, 17 }, 1,
        0, 1, function(var)
            local stg = stage.current_stage
            local enemy1 = Class(enemy, {
                init = function(self, x, y, vx1, vy1)
                    enemy.init(self, 19, HP(12), false, true, false, 2)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx1, vy1
                    task.New(self, function()
                        task.Wait(5)
                        for _ = 1, stage_lib.GetValue(5, 15, 40, 100) do
                            Create.bullet_accel(self.x, self.y, arrow_big, 6, 0.4,
                                    stage_lib.GetValue(1, 2, 5, 15), atan2(self.dy, self.dx))
                            PlaySound("tan00")
                            task.Wait(int(stage_lib.GetValue(35, 20, 5, 1)))
                        end
                    end)
                    task.New(self, function()
                        task.Wait(200)
                        for i = 1, stage_lib.GetValue(18, 24, 32, 72) do
                            self.vx = vx1 + vx1 * (i / 36)
                            self.vy = vy1 + vy1 * (i / 36)
                            task.Wait()
                        end
                        task.Wait(480)
                        Del(self)
                    end)
                end,
            }, true)
            local enemy2 = Class(enemy, {
                drop = function(self)
                    New(bullet_cleaner, self.x, self.y, 100, 10, 10, true, false, 0)
                end,
                init = function(self, x, y, vx, vy, d)
                    enemy.init(self, 12, HP(14), false, true, false, 6)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx, vy
                    task.New(self, function()
                        task.Wait(ran:Int(20, 60))
                        for r = 1, 17 do
                            local v = stage_lib.GetValue(0.8, 2, 5, 20)
                            Create.bullet_accel(self.x, self.y, ball_big, 4, v * 0.5, v, Angle(self, player))
                            PlaySound("tan00")
                            task.Wait(int(stage_lib.GetValue(60, 40, 20, 3)))
                        end
                    end)
                end,
            }, true)
            task.New(stg, function()
                for _ = 1, 6 do
                    for d = -1, 1, 2 do
                        New(enemy2, 360 * d, ran:Float(-180, -60), -2.4 * d, 1, d)
                    end
                    task.Wait(130 + ran:Int(-10, 10))
                end
            end)
            local C = stage_lib.GetValue(24, 30, 45, 120)
            for _ = 1, C do
                New(enemy1, ran:Float(-300, 300), -260, ran:Float(-0.6, 0.6), stage_lib.GetValue(1, 2, 3, 8))
                task.Wait(720 / C)
            end
        end, _t("难上难下"))

lib.NewWaveEventInWaves(class, 25, { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19 }, 0.03,
        0, 0.4, function()
            local enemy1 = Class(enemy, {
                init = function(self, x, y, vx1, vy1)
                    enemy.init(self, 22, HP(8), false, false, true, 1)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx1, vy1
                    task.New(self, function()
                        task.Wait(200)
                        for i = 1, 36 do
                            self.vx = vx1 + vx1 * (i / 36)
                            self.vy = vy1 + vy1 * (i / 36)
                            task.Wait()
                        end
                        task.Wait(400)
                        Del(self)
                    end)
                end,
            }, true)

            for r = 1, 52 do
                local px, py = player.x, player.y
                for a in sp.math.AngleIterator(90 + r * 17, 4) do
                    New(enemy1, px + cos(a) * 700, py + sin(a) * 700, cos(a + 180) * 2, sin(a + 180) * 2)
                end
                task.Wait(8)
            end
            task.Wait(60)
        end, _t("他们朝我扔毛玉"), true)
lib.NewWaveEventInWaves(class, 26, { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19 }, 0.03,
        0, 0.4, function()
            local enemy = Class(enemy, {
                init = function(self, x, y, vx, vy)
                    enemy.init(self, 21, HP(14), false, true, true, 1)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx, vy
                end
            }, true)
            task.New(stage.current_stage, function()
                task.Wait(60)
                local othercond = function(tool)
                    return tool.quality == 4 or tool.quality == 3
                end
                local addition = stg_levelUPlib.GetAdditionList(4, othercond)
                if #addition > 0 then
                    for i = 1, #addition do
                        item.dropItem(item.drop_addition_sp, 1, (i - 2.5) * 150, 240, addition[i].id, function()
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
                for x = -2, 2 do
                    New(enemy, x * 150, 270, 0, -2.2)
                end
                task.Wait(20)
            end
            task.Wait(60)
        end, _t("我拿毛玉做道具"), true)

lib.NewWaveEventInWaves(class, 27, { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19 }, 0.03,
        0, 0.5, function(var)

            local enemy1 = Class(enemy, {
                init = function(self, x, y, vx1, vy1, ag)
                    enemy.init(self, 20, HP(10), false, true, true, 1)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx1, vy1
                    self.ag = ag
                end,
            }, true)
            local t = 20
            for _ = 1, 128 do
                New(enemy1, ran:Float(-250, 250), 260, ran:Float(-2, 2), ran:Float(-0.3, -0.6), 0.04)
                New(enemy1, ran:Float(-250, 250), -260, ran:Float(-2, 2), ran:Float(0.3, 0.6), -0.04)
                task.Wait(t)
                t = max(t - 1, 1)
            end
            task.Wait(120)
        end, _t("毛玉学长这招太狠了"), true)

lib.NewWaveEventInWaves(class, 28, { 11, 12, 13, 14, 16, 19 }, 1,
        0, 1, function()
            local stg = stage.current_stage
            local enemy1 = Class(enemy, {
                init = function(self, x, y, vx, vy)
                    enemy.init(self, 23, HP(20), false, true, false, 2.3)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx * 0.3, vy * 0.3
                    task.New(self, function()
                        task.Wait(60)
                        local A = Angle(0, 0, self.vx, self.vy)
                        for _ = 1, int(stage_lib.GetValue(7, 10, 15, 60)) do
                            local v = stage_lib.GetValue(2, 3, 4, 12)
                            local b = NewSimpleBullet(arrow_big_c, 2, self.x, self.y, v,
                                    Angle(self, player) + 180 + ran:Float(-10, 10))
                            object.SetA(b, 0.03, Angle(self, player))
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
                    enemy.init(self, 5, HP(20), false, true, false, 8)
                    self.x, self.y = x, y
                    task.New(self, function()
                        task.MoveTo(mx, my, 60, 2)
                        task.New(self, function()
                            for _ = 1, int(stage_lib.GetValue(3, 3, 5, 35)) do
                                for a in sp.math.AngleIterator(Angle(self, player), int(stage_lib.GetValue(12, 18, 25, 60))) do
                                    local v = vp + stage_lib.GetValue(0, 1, 2, 5)
                                    Create.bullet_decel(self.x, self.y, ball_mid_c, 6, v * 1.5, v, a)
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
        end, _t("红藻"))

lib.NewWaveEventInWaves(class, 29, { 11, 12, 13, 14, 17, 18 }, 1,
        0, 1, function(var)
            local stg = stage.current_stage
            local enemy1 = Class(enemy, {
                init = function(self, x, y, vx, vy)
                    enemy.init(self, 26, HP(20), false, true, false, 2.3)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx * 0.3, vy * 0.3
                    task.New(self, function()
                        for _ = 1, int(stage_lib.GetValue(12, 18, 25, 60)) do
                            Create.bullet_accel(self.x, self.y, arrow_big_c, 4, 1, min(13, 4 + var.chaos / 90), Angle(self, player))
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
                    enemy.init(self, 5, HP(20), false, true, false, 8)
                    self.x, self.y = x, y
                    task.New(self, function()
                        task.MoveTo(mx, my, 60, 2)
                        task.New(self, function()
                            for _ = 1, int(stage_lib.GetValue(3, 3, 5, 35)) do
                                for a in sp.math.AngleIterator(Angle(self, player), int(stage_lib.GetValue(12, 18, 25, 60))) do
                                    local v = vp + stage_lib.GetValue(0, 1, 2, 5)
                                    Create.bullet_decel(self.x, self.y, ball_mid_c, 8, v * 1.5, v, a)
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
        end, _t("紫藻"))

lib.NewWaveEventInWaves(class, 30, { 6, 7, 8, 9, 16, 17, 18, 19 }, 0,
        2, 2, function()
            local stg = stage.current_stage
            local enemy1 = Class(enemy, {
                init = function(self, x, y, vx, vy)
                    enemy.init(self, 24, HP(50), false, true, false, 2.3)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx * 0.3, vy * 0.3
                    task.New(self, function()
                        local w = lstg.world
                        while not BoxCheck(self, w.l, w.r, w.b, w.t) do
                            task.Wait()
                        end
                        local A = Angle(0, 0, self.vx, self.vy)
                        for _ = 1, int(stage_lib.GetValue(7, 10, 15, 60)) do
                            local v = stage_lib.GetValue(2, 3, 4, 12)
                            local b = NewSimpleBullet(grain_c, 10, self.x, self.y, v,
                                    A + ran:Float(-10, 10))
                            object.SetA(b, 0.03, A)
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
                    enemy.init(self, 5, HP(20), false, true, false, 8)
                    self.x, self.y = x, y
                    task.New(self, function()
                        task.MoveTo(mx, my, 60, 2)
                        task.New(self, function()
                            for _ = 1, int(stage_lib.GetValue(3, 3, 5, 35)) do
                                for a in sp.math.AngleIterator(Angle(self, player), int(stage_lib.GetValue(12, 18, 25, 60))) do
                                    local v = vp + stage_lib.GetValue(0, 1, 2, 5)
                                    Create.bullet_decel(self.x, self.y, ball_mid_c, 6, v * 1.5, v, a)
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
                    local m = int(stage_lib.GetValue(10, 15, 20, 80))
                    local wt = stage_lib.GetValue(20, 15, 10, 3)
                    for a in sp.math.AngleIterator(ran:Float(0, 360), m) do

                        New(enemy1, cos(a) * 500, sin(a) * 500, cos(a + 180) * 2, sin(a + 180) * 2)
                        task.Wait(wt)
                    end
                end)
                task.Wait(60)
                New(enemy2, 120 * d, 300, 120 * d + ran:Float(-50, 50), 150 + ran:Float(-50, 50), -1.5 * d, 0, 1 + t / 8 * 2)
                task.Wait(24 + t * 4)
                d = -d
            end
            task.Wait(75)
        end, _t("水华"), nil, true)

lib.NewWaveEventInWaves(class, 31, { 4, 6, 8, 9, 11, 13, 16, 17, 18, 19 }, 1,
        0, 1, function(var)
            local stg = stage.current_stage
            local ball = Class(enemy, {
                init = function(self, x, y, D, dx, dy, time, wait)
                    enemy.init(self, 25, HP(45),
                            false, true, false, 5.3)
                    self.x, self.y = x, y
                    task.New(self, function()
                        local c = 1
                        while true do
                            task.MoveToEx(dx * D, dy, time, 3)
                            if c <= stage_lib.GetValue(1, 2, 3, 10) then
                                for a in sp.math.AngleIterator(-90, int(stage_lib.GetValue(4, 6, 8, 45))) do
                                    Create.bullet_changeangle(self.x, self.y, ball_big, 8, 3, a,
                                            { r = ran:Float(-0.1, 0.1), time = 150, v = 2 })
                                end
                                PlaySound("tan00")
                            end
                            c = c + 1
                            task.Wait(wait)
                            D = -D
                        end
                    end)
                end
            }, true)
            local w = stage_lib.GetValue(100, 80, 70, 50)
            for _ = 1, 9 do
                local ox = ran:Float(-100, 50)
                for c = -2, 2 do
                    New(ball, c * 100 + ox, 280, 1, 50, -60, int(w * 0.5), int(w * 0.4))
                end
                task.Wait(w)
            end
        end, _t("有钱能使鬼推磨"))

lib.NewWaveEventInWaves(class, 32, { 4, 8, 12, 16 }, 1,
        0, 1, function(var)
            local diff = var.difficulty
            local stg = stage.current_stage
            local enemy1 = Class(enemy, {
                init = function(self, x, y, vx1, vy1, vx2, vy2)
                    enemy.init(self, 32, HP(12), false, true, false, 2)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx1, vy1
                    task.New(self, function()
                        task.Wait(20)
                        for a in sp.math.AngleIterator(ran:Float(0, 360), int(stage_lib.GetValue(10, 18, 24, 75))) do
                            Create.bullet_decel(self.x, self.y, grain_a, 8, 3 + var.chaos / 150, 1.5 + var.chaos / 150, a)
                        end
                        PlaySound("tan00")
                    end)
                    task.New(self, function()
                        task.Wait(60)
                        for i = 1, 180 do
                            self.vx = vx1 + (vx2 - vx1) * (i / 180)
                            self.vy = vy1 + (vy2 - vy1) * (i / 180)
                            task.Wait()
                        end
                        task.Wait(180)
                        Del(self)
                    end)
                end,
            }, true)
            local enemy2 = Class(enemy, {
                init = function(self, x, y, mx, my, vx, vy)
                    enemy.init(self, 9, HP(240), false, true, false, 15)
                    self.x, self.y = x, y
                    task.New(self, function()
                        task.MoveTo(mx, my, 60, 2)
                        for _ = 1, 12 do
                            for a in sp.math.AngleIterator(ran:Float(0, 360), int(stage_lib.GetValue(20, 30, 40, 120))) do
                                Create.bullet_decel(self.x, self.y, ball_mid, 2, 3 + var.chaos / 120, 1.5 + var.chaos / 120, a)
                            end
                            PlaySound("tan00")
                            task.Wait(stage_lib.GetValue(50, 40, 30, 6))
                        end
                        task.Wait(780)
                        for i = 1, 60 do
                            self.vx = i / 60 * vx
                            self.vy = i / 60 * vy
                            task.Wait()
                        end
                    end)
                end,
            }, true)

            local enemy3 = Class(enemy, {
                init = function(self, x, y, mx, my, vx, vy)
                    enemy.init(self, 9, HP(120), false, true, false, 15)
                    self.x, self.y = x, y
                    task.New(self, function()
                        task.MoveTo(mx, my, 60, 2)
                        for _ = 1, 12 do
                            for a in sp.math.AngleIterator(ran:Float(0, 360), int(stage_lib.GetValue(16, 23, 30, 100))) do
                                Create.bullet_decel(self.x, self.y, ball_mid, 4, 3 + var.chaos / 120, 1.5 + var.chaos / 120, a)
                            end
                            PlaySound("tan00")
                            task.Wait(stage_lib.GetValue(60, 50, 40, 10))
                        end
                        for i = 1, 60 do
                            self.vx = i / 60 * vx
                            self.vy = i / 60 * vy
                            task.Wait()
                        end
                    end)
                end,
            }, true)

            local enemy4 = Class(enemy, {
                init = function(self, x, y, mx, my, vx, vy)
                    enemy.init(self, 14, HP(150), false, true, false, 15)
                    self.x, self.y = x, y
                    task.New(self, function()
                        task.MoveTo(mx, my, 60, 2)
                        for _ = 1, 30 do
                            local N = int(stage_lib.GetValue(15, 20, 35, 120))
                            for a in sp.math.AngleIterator(-90 + 180 / N, N) do
                                Create.bullet_decel(self.x, self.y, ellipse, 6, 3 + var.chaos / 100, 2 + var.chaos / 100, a)
                            end
                            PlaySound("tan00")
                            task.Wait(stage_lib.GetValue(25, 20, 15, 3))
                        end
                        for i = 1, 60 do
                            self.vx = i / 60 * vx
                            self.vy = i / 60 * vy
                            task.Wait()
                        end
                    end)
                end,
            }, true)

            New(enemy2, 0, 300, 0, 110, 0, -2)
            task.Wait(180)
            New(enemy3, -60, 300, -60, 135, -1.5, -1.5)
            New(enemy3, 60, 300, 60, 135, 1.5, -1.5)
            task.Wait(180)
            task.New(stg, function()
                task.Wait(300)
                New(enemy4, 0, 300, 0, 160, 0, -1.5)
            end)
            local t = 50
            for _ = 1, 30 do
                New(enemy1, 356, ran:Float(-30, 30), -4, 0.2, ran:Float(-0.5, 0.5), ran:Float(2, 3))
                task.Wait(t)
                New(enemy1, -356, ran:Float(-30, 30), 4, 0.2, ran:Float(-0.5, 0.5), ran:Float(2, 3))
                task.Wait(t)
                t = max(t - 6, 5)
            end

        end, _t("追忆纯粹"))

lib.NewWaveEventInWaves(class, 33, { 8, 9, 16 }, 1,
        0, 1, function(var)
            local stg = stage.current_stage
            local throwing_ball = Class(enemy, {
                init = function(self, x, y, tx)
                    enemy.init(self, 25, HP(50), false, true, false, 1)
                    self.x, self.y = x, y
                    task.New(self, function()
                        local mH = ran:Float(180, 200) - y
                        local h = y + 240
                        local g = 0.05
                        local t = sqrt(2 * mH / g) + sqrt(2 * (mH + h) / g)
                        local vx = (tx - x) / t
                        local vy = sqrt(2 * g * mH)
                        self.vx, self.vy = vx, vy
                        self.ag = g
                        while self.y > -240 do
                            task.Wait()
                        end
                        for a in sp.math.AngleIterator(Angle(self, player), int(stage_lib.GetValue(6, 8, 12, 36))) do
                            for k = -3, 3 do
                                NewSimpleBullet(arrow_big, 6, self.x, self.y,
                                        (2 - abs(k) * 0.1) * min(3, 1 + var.chaos / 200), a + k * 3)
                            end
                        end
                        NewBon(self.x, self.y, 60, 128, 218, 112, 214)
                        PlaySound("explode")
                        Del(self)
                    end)
                end,
            }, true)
            local enemy2 = Class(enemy, {
                init = function(self, x, y, mx, my, vx, vy)
                    enemy.init(self, 2, HP(10), false, true, false, 2)
                    self.x, self.y = x, y
                    task.New(self, function()
                        task.Wait(ran:Int(35, 125))
                        if lstg.var.chaos > 36 then
                            for _ = 1, stage_lib.GetValue(1, 2, 4, 18) do
                                for z = -1, 1 do
                                    Create.bullet_decel(self.x, self.y, diamond, 10, 4,
                                            stage_lib.GetValue(2, 3, 4, 15) * (1 - abs(z) * 0.05),
                                            Angle(self, player) + z * 2)
                                end
                                PlaySound("tan00")
                                task.Wait(stage_lib.GetValue(125, 45, 14, 2))
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
                    for _ = 1, 18 do
                        local x = ran:Float(-135, 135)
                        New(enemy2, x, 270, x + ran:Float(-60, 60), ran:Float(100, 160), 0, -ran:Float(1, 2))
                        task.Wait(6)
                    end
                    task.Wait(90)

                end
            end)
            local d = -1
            for k = 1, 15 do
                New(throwing_ball, d * 350, ran:Float(150, 170), d * ran:Float(200, 250))
                task.Wait(90 - k * 5)
                d = -d
            end
            task.Wait(30)

            task.Wait(30)
        end, _t("左加右减"))

lib.NewWaveEventInWaves(class, 34, { 6, 7, 18, 19 }, 1,
        0, 1, function(var)
            local enemy2 = Class(enemy, {
                drop = function(self)
                    New(bullet_cleaner, self.x, self.y, 500, 1, 2, true, false, 0)
                end,
                init = function(self, x, y, mx, my, v, A, color, D)
                    enemy.init(self, 9, HP(152), false, true, false, 20)
                    self.x, self.y = x, y
                    task.New(self, function()
                        task.MoveTo(mx, my, 90, 2)
                        task.Wait(200)
                        object.ChangingV(self, 0, v, A, 80, false)
                    end)
                    task.New(self, function()
                        task.Wait(20)
                        color = color or 4
                        local rot = A
                        for j = 1, 60 do
                            for a in sp.math.AngleIterator(rot, int(stage_lib.GetValue(2, 3, 6, 12))) do
                                local R = sin(j * 3 + a) * 18
                                for ba in sp.math.AngleIterator(ran:Float(0, 360), 8) do
                                    Create.bullet_accel(self.x + cos(ba) * R, self.y + sin(ba) * R, ball_mid_c, color, 3, 7, a)
                                end
                            end
                            rot = rot + 23 * D
                            PlaySound("tan00")
                            task.Wait(4)
                        end
                    end)
                end,
            }, true)
            New(enemy2, 0, 300, 0, 100, 1, -90, 2, 1)
            task.Wait(220)
            for c = 1, 3 do
                for d = -1, 1, 2 do
                    New(enemy2, -320 * d, 300, -c * 50 * d, 100, 2, -90 + 85 * d, 4, d)
                end
                task.Wait(350 - c * 60)
            end
            task.Wait(280)
            New(enemy2, 0, 300, 0, 100, 1, -90, 6, -1)
        end, _t("风神妖精"))

lib.NewWaveEventInWaves(class, 35, { 12, 14, 18, 19, }, 0,
        2, 2, function(var)
            local stg = stage.current_stage
            local ball = Class(enemy, {
                init = function(self, x, y, D, dx, dy, time, wait)
                    enemy.init(self, 26, HP(20),
                            false, true, false, 3)
                    self.x, self.y = x, y
                    task.New(self, function()
                        local c = 1
                        while true do
                            task.MoveToEx(dx * D, dy, time, 3)
                            if c <= stage_lib.GetValue(6, 9, 12, 36) then
                                for a in sp.math.AngleIterator(-90, int(stage_lib.GetValue(4, 6, 8, 45))) do
                                    Create.bullet_changeangle(self.x, self.y, ball_big, 4, 3, a)
                                end
                                PlaySound("tan00")
                            end
                            c = c + 1
                            task.Wait(wait)
                            D = -D
                        end
                    end)
                end
            }, true)
            local w = stage_lib.GetValue(100, 80, 70, 50)
            local d = 1
            for _ = 1, 9 do
                for c = -6, 6 do
                    New(ball, c * 49 - 25, 280, 1, 50, -60, int(w * 0.5 + c * 2 * d), int(w * 0.4))
                end
                d = -d
                task.Wait(w)
            end
        end, _t("立入禁止"), nil, true)

lib.NewWaveEventInWaves(class, 36, { 6, 7, 8, 9 }, 1,
        0, 1, function(var)

            local stg = stage.current_stage
            local rain_enemy = Class(enemy, {
                init = function(self, x, y, vx1, vy1, A)
                    enemy.init(self, 10, HP(12), false, true, false, 1.1)
                    self.x, self.y = x, y
                    self.vx, self.vy = vx1, vy1
                    task.New(self, function()
                        while true do
                            local b = NewSimpleBullet(grain_c, 6, self.x, self.y, min(10, 3 + var.chaos / 100 * 2), A)
                            b.stay = false
                            PlaySound("tan00")
                            task.Wait(stage_lib.GetValue(20, 15, 9, 3))
                        end
                    end)
                end,
            }, true)
            for c = 1, 3 do
                for d = 1, -1, -2 do
                    task.New(stg, function()
                        local t = 20
                        for i = 1, 32 do
                            local A = 90 - (120 - 20 * task.SetMode[4](i / 32)) * d
                            local k = 3.5 + i % 2 * 0.2
                            New(rain_enemy, -400 * d, 180, cos(A) * k, sin(A) * k, A - 90 * d)
                            task.Wait(7)
                            t = max(1, t - 1)
                        end
                    end)
                    task.Wait(300 - c * 50)
                end
            end
        end, _t("一分干掉一个操场"))

lib.NewWaveEventInWaves(class, 37, { 2, 16, 17, 18, 19 }, 0,
        2, 2, function(var)
            local enemy2 = Class(enemy, {
                drop = function(self)
                    New(bullet_cleaner, self.x, self.y, 500, 1, 2, true, false, 0)
                end,
                init = function(self, x, y, mx, my, v, A, color, D)
                    enemy.init(self, 9, HP(152), false, true, false, 20)
                    self.x, self.y = x, y
                    task.New(self, function()
                        task.MoveTo(mx, my, 90, 2)
                        task.Wait(200)
                        object.ChangingV(self, 0, v, A, 80, false)
                    end)
                    task.New(self, function()
                        task.Wait(20)
                        color = color or 4
                        local rot = A
                        for j = 1, 60 do
                            for a in sp.math.AngleIterator(rot, int(stage_lib.GetValue(1, 1, 2, 6))) do
                                local R = sin(j * 8) * 80
                                for ba in sp.math.AngleIterator(a, int(stage_lib.GetValue(5, 8, 8, 9))) do
                                    Create.bullet_accel(self.x + cos(ba) * R, self.y + sin(ba) * R, ball_mid_c, color, 3, 7, a)
                                end
                            end
                            rot = rot + 23 * D
                            PlaySound("tan00")
                            task.Wait(4)
                        end
                    end)
                end,
            }, true)

            for c = 1, 5 do
                for d = -1, 1, 2 do
                    New(enemy2, -320 * d, 300, -c * 50 * d, 100, 2, -90 + 85 * d, 10, d)
                end
                task.Wait(350 - c * 60)
            end
        end, _t("妖精颪"), nil, true)

lib.NewWaveEventInWaves(class, 38, { 4, 11, 13, 18, 19, }, 1,
        0, 1, function(var)
            local stg = stage.current_stage
            local normal_enemy = Class(enemy, {
                init = function(self, x, y, dy, time, wait)
                    enemy.init(self, 10, HP(35),
                            false, true, false, 3)
                    self.x, self.y = x, y
                    task.New(self, function()
                        task.MoveToEx(0, dy, time, 3)
                        task.New(self, function()
                            task.MoveToEx(ran:Float(-20, 20), dy, time * 5, 3)
                        end)
                        for c = 1, int(stage_lib.GetValue(15, 30, 50, 90)) do
                            local create_x = self.x + ran:Float(-20, 20)
                            local create_y = self.y + ran:Float(-20, 20)
                            local spread = stage_lib.GetValue(0, 0.6, 1.4, 2.7)
                            local a = Angle(self, player) + ran:Float(-spread, spread)
                            local col = 4 + (c % 2)
                            local v = stage_lib.GetValue(2.7, 3.2, 4, 5.1) * ran:Float(0.9, 1.1)
                            -- for a in sp.math.AngleIterator(-90, int(stage_lib.GetValue(4, 6, 8, 45))) do
                            if ran:Int(1, 2) == 1 then
                                local b = Create.bullet_changeangle(create_x, create_y, ball_mid, col, v, a + 180)
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
                            Create.bullet_changeangle(create_x, create_y, arrow_big_c, col, v, a)
                            task.Wait(wait)
                        end
                        local ia = ran:Float(0, 360)
                        for a in sp.math.AngleIterator(ia, int(stage_lib.GetValue(5, 6, 8, 12))) do
                            local v = stage_lib.GetValue(2.5, 2.2, 2.1, 2) * ran:Float(0.9, 1.1)
                            Create.bullet_decel(self.x, self.y, ball_big, 5, v * 2, v, a)
                        end
                        PlaySound("tan00")
                        task.MoveToEx(0, -dy * 3, time * 2, 3)
                    end)
                end
            }, true)
            local big_enemy = Class(enemy, {
                drop = function(self)
                    New(bullet_cleaner, self.x, self.y, 500, 1, 2, true, false, 0)
                end,
                init = function(self, x, y, dy, time, wait)
                    enemy.init(self, 9, HP(125),
                            false, true, false, 16)
                    self.x, self.y = x, y
                    task.New(self, function()
                        task.MoveToEx(0, dy, time, 3)
                        local D = 1
                        for _ = 1, int(stage_lib.GetValue(5, 6, 8, 12)) do
                            local ia = ran:Float(0, 360)
                            for a in sp.math.AngleIterator(ia, int(stage_lib.GetValue(6, 9, 12, 35))) do
                                local min_v = stage_lib.GetValue(2.5, 2.2, 2.1, 2)
                                local max_v = stage_lib.GetValue(4, 5, 5.5, 7)
                                local max_it = int(stage_lib.GetValue(3, 4, 6, 12))
                                local ait = stage_lib.GetValue(5, 4.5, 3.2, 2.5)
                                for c = 1, max_it do
                                    local v = min_v + (max_v - min_v) / max_it * c
                                    Create.bullet_decel(self.x, self.y, ball_big, 4, v * 1.3,
                                            v, a + c * D * ait)
                                end
                            end
                            D = -D
                            PlaySound("tan00")
                            task.Wait(wait)
                        end
                        task.MoveToEx(0, dy * 3, time * 3, 3)
                    end)
                end
            }, true)
            local w = stage_lib.GetValue(60, 50, 40, 20)
            local normal_wait = stage_lib.GetValue(24, 18, 12, 8)
            local big_wait = stage_lib.GetValue(60, 50, 40, 30)
            local d = 1
            for _ = 1, 4 do
                local big_index = ran:Int(-3, 3)
                for c = -3, 3 do
                    if c == big_index then
                        New(big_enemy, c * 79 + ran:Int(-20, 20),
                                280, ran:Int(-200, -170), int(w * 1.5), int(big_wait))
                    else
                        New(normal_enemy, c * 79 + ran:Int(-20, 20),
                                280, ran:Int(-120, -80), int(w * 2), int(normal_wait))
                    end
                end
                d = -d
                task.Wait(w * 5)
            end
        end, _t("我不会起名"))

lib.NewWaveEventInWaves(class, 39, { 5, 10, 15 }, 0.8,
        0, 1, function()
            misc.ShakeScreen(80, 10, 1, 1.5, 1)
            local bclass = boss.Define(name("Ichirin"), 0, 400, _editor_class.ichirin_bg, "Ichirin")
            local sc = boss.card.New("拳服「紫红色极地大冲击」", 1, 4, 50, HP(1000))
            boss.card.add(bclass, sc)
            SetImageCenter("fist", 320, 125)

            local midball = Class(bullet, {
                init = function(self, x, y, master, v, a, c)
                    bullet.init(self, c, COLOR.PURPLE, true, true)
                    self._blend, self._a, self._r, self._g, self._b = "", 255, 255, 255, 255
                    self.x, self.y = x, y
                    self.maxv = 4
                    SetV(self, v, a)
                    PlaySound("tan00")
                    task.New(self, function()
                        local beat = stage_lib.GetValue(0.01, 0.005, 0, 0)
                        while IsValid(master) and not master.BOUND do
                            task.Wait()
                        end
                        self.vx = 0
                        self.vy = 0
                        SetV(self, ran:Float(2.2 - beat * 50, 3.2 - beat * 50), ran:Float(80, 100))
                        self.ag = ran:Float(0.03 - beat, 0.035 - beat)
                    end)
                end
            }, true)

            local fist = Class(object, {
                init = function(self, x, y, v, a, master)
                    self.img = "fist"
                    self.x = x
                    self.y = y
                    self.group = GROUP.INDES
                    self.layer = LAYER.ENEMY_BULLET
                    self.hscale = 1.2
                    self.vscale = 1.2
                    self.alpha = 0
                    self.a = 48
                    self.b = self.a
                    self.BOUND = false
                    self.bound = false
                    PlaySound("boon00", 0.5)
                    SetV(self, v, a, true)
                    task.New(self, function()
                        while not self.BOUND do
                            local beat = stage_lib.GetValue(10, 7, 5, 1)
                            New(midball, self.x, self.y, self, 1, ran:Float(-20, 20) + self.rot + 180, ball_big)
                            task.Wait(ran:Int(beat, 15))
                            New(midball, self.x, self.y, self, 1, ran:Float(-20, 20) + self.rot + 180, ball_mid_c)
                            task.Wait(ran:Int(beat, 15))
                        end
                    end)
                    task.New(self, function()
                        local beat = stage_lib.GetValue(18, 6, 4, 2)
                        while not self.BOUND do
                            task.Wait(beat)
                            New(midball, self.x, self.y, self, v / 1.6, math.sin((self.timer + master.timer) / v) * (12 + beat) + self.rot + 180, ball_mid)
                            New(midball, self.x, self.y, self, v / 1.6, math.sin(-(self.timer + master.timer) / v) * (12 + beat) + self.rot + 180, ball_mid)
                        end
                        misc.ShakeScreen(30, 3, 1, 1.5, 1)
                        task.Wait(60)
                        self.colli = false
                        object.ChangingV(self, 0, v * 0.8, a, 60)
                        task.Wait(180)
                        Del(self)
                    end)
                end,
                frame = function(self)
                    task.Do(self)
                    if self.vscale >= 0.65 then
                        self.hscale = self.hscale - 0.05
                        self.vscale = self.hscale - 0.05
                        self.alpha = self.alpha + 255 / 11
                    end
                    local w = lstg.world
                    if not self.BOUND and (abs(self.x) >= abs(w.boundl) or abs(self.y) >= abs(w.boundt)) then
                        NewWave(self.x, self.y, 2, 300, 60, 218, 112, 214)
                        NewBon(self.x, self.y, 60, 128, 218, 112, 214)
                        self.vx = 0
                        self.vy = 0
                        self.BOUND = true
                        PlaySound("enep00")
                    end
                end,
            }, true)

            function sc:before()
                task.MoveToForce(0, 0, 60, 2)
            end
            function sc:init()
                local beat = stage_lib.GetValue(15, 7, 0, -100)
                task.New(self, function()
                    Newcharge_in(self.x, self.y, 255, 255, 255)
                    task.Wait(20)
                    Newcharge_in(self.x, self.y, 255, 155, 155)
                    task.Wait(20)
                    Newcharge_in(self.x, self.y, 255, 0, 155)
                    task.Wait(20)
                    Newcharge_out(self.x, self.y, 255, 0, 0)
                    while true do
                        local A = ran:Float(0, 360)
                        local a = Angle(self, player) + 90
                        for _ = 1, 10 do
                            New(fist, self.x, self.y, 4, a, self)

                            a = a + 20
                            task.Wait()
                        end
                        task.Wait(180 + beat)
                        local I = ran:Sign()
                        task.MoveToPlayer(60, -200, 200, 80, 120,
                                20, 40, 10, 20, 2, 1)
                        Newcharge_in(self.x, self.y, 255, 0, 255)
                        task.Wait(20)
                        for i = 1, 10 do
                            New(fist, self.x, self.y, 3 + i / 1.5, Angle(self, player) + (7 + i / 2) * i * I, self)
                            task.Wait(8)
                        end
                        task.Wait(65 + beat)
                        task.MoveToForce(player.x + ran:Float(-20, 20), min(200, player.y + 200), 60, 2)
                        Newcharge_in(self.x, self.y, 255, 0, 255)
                        for _ = 1, 10 do
                            for i = 1, 11 do
                                NewSimpleBullet(diamond, COLOR.PURPLE, self.x, self.y, 1.5, A + i * 2, true)
                            end

                            A = A + 360 / 10
                        end
                        PlaySound("tan00")
                        task.Wait(20)
                        local y = ran:Float(260, 280)
                        for i = 1, 5 do
                            New(fist, -200, y - ran:Float(85, 100) * (i - 1), 5 + i / 5, ran:Float(30, 40), self)
                            task.Wait(8)
                        end
                        task.Wait(45 + beat)
                        task.MoveToForce(player.x + ran:Float(-20, 20), min(210, player.y + 220), 60, 2)
                        Newcharge_in(self.x, self.y, 255, 0, 255)
                        for _ = 1, 10 do
                            for i = 1, 11 do
                                NewSimpleBullet(diamond, COLOR.PURPLE, self.x, self.y, 1.5, A + i * 2, true)
                            end
                            A = A + 360 / 10
                        end
                        PlaySound("tan00")
                        task.Wait(20)
                        for i = 1, 3 do
                            New(fist, 240, y + 100 - ran:Float(50, 65) * (i * 2 - 1), 6, ran:Float(30, 40) + 180, self)
                            task.Wait(8)
                        end
                        task.Wait(110 + beat)
                        task.MoveToForce(0, 80, 60, 2)
                        Newcharge_in(self.x, self.y, 255, 0, 255)
                        task.Wait(20)
                        local a = Angle(self, player)
                        for _ = 1, 8 do
                            New(fist, self.x, self.y, 4, a, self)
                            a = a + 360 / 8
                            task.Wait()
                        end

                        task.Wait(110 + beat)
                        Newcharge_in(self.x, self.y, 255, 0, 255)
                        task.Wait(20)
                        local x = ran:Float(290, 320)
                        for i = 1, 8 do
                            New(fist, x - ran:Float(100, 130) * (i - 1), 240, ran:Float(4.9, 5.6), ran:Float(260, 280), self)
                            task.Wait(10)
                        end
                        task.Wait(110 + beat)
                        task.MoveToPlayer(60, -200, 200, 60, 80,
                                20, 40, 10, 20, 2, 1)
                        Newcharge_in(self.x, self.y, 255, 255, 255)
                        local bbeat = stage_lib.GetValue(0, 1, 2, 10)
                        for _ = 1, 9 do
                            for i = 1, 10 + bbeat do
                                NewSimpleBullet(diamond, COLOR.GRAY, self.x, self.y, 1, A + i * 2, true)
                            end
                            A = A + 360 / 9
                        end
                        PlaySound("tan00")
                        task.Wait(20)
                        task.MoveToPlayer(60, -200, 200, 40, 60,
                                20, 40, 10, 20, 2, 1)
                        Newcharge_in(self.x, self.y, 255, 0, 155)
                        for _ = 1, 10 do
                            for i = 1, 11 + bbeat do
                                NewSimpleBullet(diamond, COLOR.PURPLE, self.x, self.y, 1, A + i * 2, true)
                            end
                            A = A + 360 / 10
                        end
                        PlaySound("tan00")
                        task.Wait(20)
                        task.MoveToPlayer(60, -200, 200, -20, 40,
                                20, 40, 10, 20, 2, 1)
                        Newcharge_in(self.x, self.y, 255, 0, 0)
                        for _ = 1, 11 do
                            for i = 1, 12 + bbeat do
                                NewSimpleBullet(diamond, COLOR.RED, self.x, self.y, 1, A + i * 2, true)
                            end
                            A = A + 360 / 11
                        end
                        PlaySound("tan00")
                        task.Wait(40)
                    end
                end)
            end
            function sc:other_drop()
            end
            boss.Create(bclass)
        end, _t("天地人间完全发电"), nil, nil, true)

