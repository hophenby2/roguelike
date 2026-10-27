local StarDrawer = Class(object, {
    init = function(self, x, y, n, rot, len, v, interval, event)
        local a = 360 / n + 90
        local l = (len * v / 2) * (1 / cos(180 - a))
        self.x, self.y = x + cos(a + rot) * l, y + sin(a + rot) * l
        self._x, self._y = x, y
        self.group = GROUP.INDES
        self.hide = true
        self.bound = false
        self.n = n
        self.len = len
        self.interval = interval
        self.event = event
        self.rot = rot
        self.FrameCount = 0
        task.New(self, function()
            local V, A
            for _ = 1, n do
                V, A = v * self.interval, self.rot
                for _ = 1, len / self.interval do
                    self.x = self.x + cos(A) * V
                    self.y = self.y + sin(A) * V
                    self.event(self, self._x, self._y)
                    task.Wait()
                end
                self.timer = 0
                self.rot = self.rot - 720 / n
            end
            object.RawDel(self)
        end)
    end,
    frame = function(self)
        self.FrameCount = self.FrameCount + 1 / self.interval
        for _ = 1, self.FrameCount do
            self.timer = self.timer + 1
            task.Do(self)
            self.FrameCount = self.FrameCount - 1
        end
        self.timer = self.timer - 1
    end
})
_editor_class.StarDrawer = StarDrawer

local fan = Class(object, {
    init = function(self, master, interval)
        self.master = master
        self.group = GROUP.GHOST
        self.layer = LAYER.ENEMY - 1
        self.hscale, self.vscale = 0, 0
        self.bound = false
        self._a, self._s = 0, 0
        self.img = "fan"
        task.New(self, function()
            task.Wait(30)
            self.vscale = 0.1
            for i = 1, 30 do
                self.hscale = sin(i * 3)
                task.Wait()
            end
            New(WhiteScreen)
            task.New(self, function()
                for i = 1, 30 do
                    self.vscale = 0.1 + 0.9 * sin(i * 3)
                    task.Wait()
                end
            end)
            task.init_left_wait(self)
            while true do
                task.New(self, function()
                    for i = 1, 10 do
                        self._a = sin(i * 9)
                        task.Wait()
                    end
                    for i = 29, 0, -1 do
                        self._a = sin(i * 3)
                        task.Wait()
                    end
                end)
                for i = 1, 60 do
                    self._s = 1 + 0.35 * sin(i * 1.5)
                    task.Wait()
                end
                task.Wait2(self, interval - 60)
            end
        end)
    end,
    frame = function(self)
        if not IsValid(self.master) then
            object.Del(self)
            return
        end
        task.Do(self)
        local x, y = self.master._wisys:GetFloat(self.master.ani)
        self.x, self.y = self.master.x + x, self.master.y + y
    end,
    render = function(self)
        SetImageState(self.img, "mul+add", 255, 255, 255, 255)
        object.render(self)
        if self._a > 0 then
            SetImageState(self.img, "mul+add", 255 * self._a, 255, 255, 255)
            Render(self.img, self.x, self.y, 0, self._s)
        end
    end
})
_editor_class.yuyuko_fan = fan

local MikoBack = Class(object, {
    init = function(self, master, rot, d, wait, color, alphaer, offx, offy, breath)
        self.master = master
        d = d or 1
        self.rot = rot - 90 * d
        self.bound = false
        self.group = GROUP.GHOST
        self.layer = LAYER.ENEMY - 2
        self.color = color or { 255, 255, 255 }
        self.offx, self.offy = offx or 0, offy or 0
        self.x = self.master.x + self.offx
        self.y = self.master.y + self.offy
        self.scale = 0
        self.alpha = 0
        self.alphaer = alphaer or 1
        self.ss = 0
        task.New(self, function()
            task.init_left_wait(self)
            breath = breath or 80
            local offwait = breath - int(breath)
            task.Wait(wait or 0)
            PlaySound("kira00")
            local Smooth = task.Smooth
            for i = 1, 60 do
                i = i / 60
                i = i * 2 - i * i
                self.rot = rot - 90 * d + 90 * i * d
                self.scale = i
                self.alpha = i * 128
                task.Wait()
            end
            for i = 1, breath do
                i = Smooth(i / breath)
                self.ss = -15 * i
                self.alpha = 128 - 32 * i
                task.Wait()
            end
            task.Wait2(self, offwait)
            while true do
                for i = 1, breath do
                    i = Smooth(i / breath)
                    self.ss = -15 + 30 * i
                    self.alpha = 96 + 32 * i
                    task.Wait()
                end
                task.Wait2(self, offwait)
                for i = 1, breath do
                    i = Smooth(i / breath)
                    self.ss = 15 - 30 * i
                    self.alpha = 128 - 32 * i
                    task.Wait()
                end
                task.Wait2(self, offwait)
            end
        end)

    end,
    del = function(self)
        enemy.death_ef(self.x, self.y, 10, 1)
    end,
    kill = function(self)
        self.class.del(self)
    end,
    frame = function(self)
        if not IsValid(self.master) then
            object.Del(self)
            return
        end
        task.Do(self)
        self.x = self.master.x + self.offx
        self.y = self.master.y + self.offy
    end,
    render = function(self)
        local viewbillboard = lstg.viewbillboard
        viewbillboard:ResetParameter()
        viewbillboard:Set3D()
        local ax, ay, az = self.ss * sin(self.rot), self.ss * cos(self.rot), self.rot
        local _x1, _x2, _y1, _y2 = 0, 1, -0.5, 0.5
        local x1, y1, z1 = viewbillboard:rotate3D(_x1, _y2, 0, ax, ay, az)
        local x2, y2, z2 = viewbillboard:rotate3D(_x2, _y2, 0, ax, ay, az)
        local x3, y3, z3 = viewbillboard:rotate3D(_x2, _y1, 0, ax, ay, az)
        local x4, y4, z4 = viewbillboard:rotate3D(_x1, _y1, 0, ax, ay, az)
        SetImageState("miko_back", "mul+add", self.alpha * self.alphaer, unpack(self.color))
        local x, y = viewbillboard:WorldToBillBoard(self.x, self.y)
        Render4V("miko_back",
                x + self.scale * x1, y + self.scale * y1, self.scale * z1,
                x + self.scale * x2, y + self.scale * y2, self.scale * z2,
                x + self.scale * x3, y + self.scale * y3, self.scale * z3,
                x + self.scale * x4, y + self.scale * y4, self.scale * z4
        )
        SetViewMode("world")
    end
})
_editor_class.MikoBack = MikoBack

local ByakurenBack = Class(object, {
    init = function(self, master)
        self.x, self.y = master.x, master.y
        self.master = master
        self.layer = LAYER.ENEMY - 6
        self.group = GROUP.GHOST
        self.bound = false
        self.offx, self.offy = 0, 0
        self.back_a = { hscale = 0, vscale = 1 }
        self.back_b = { rot = 90, hscale = 0, vscale = 0 }
        self.back_c = {
            { t = 1, x = 114, y = -56, rot = 0, hscale = 0, vscale = 0 },
            { t = 1, x = -114, y = -56, rot = 0, hscale = 0, vscale = 0 },
            { t = 2, x = 64, y = 80, rot = 0, hscale = 0, vscale = 0 },
            { t = 2, x = -64, y = 80, rot = 0, hscale = 0, vscale = 0 },
        }
        function self:GetAngle(b)
            return Angle(self.x + b.x, self.y + b.y, player)
        end--flower的朝向事件，可更改
        local pos = { {}, {}, {}, {} }
        function self:GetFlowerPos()
            local b = self.back_c
            pos[1][1], pos[1][2], pos[1][3] = self.x + b[1].x, self.y + b[1].y, b[1].rot
            pos[2][1], pos[2][2], pos[2][3] = self.x + b[2].x, self.y + b[2].y, b[2].rot
            pos[3][1], pos[3][2], pos[3][3] = self.x + b[3].x, self.y + b[3].y, b[3].rot
            pos[4][1], pos[4][2], pos[4][3] = self.x + b[4].x, self.y + b[4].y, b[4].rot
            return pos
        end--获取flower的坐标与朝向
        task.New(self, function()
            PlaySound("boon01")
            for i = 1, 30 do
                self.back_b.rot = 90 - sin(i * 3) * 90
                self.back_b.hscale = sin(i * 3)
                self.back_b.vscale = sin(i * 3)
                task.Wait()
            end
            for i = 1, 30 do
                self.back_a.hscale = sin(i * 3)
                task.Wait()
            end
            task.New(self, function()
                while true do
                    for i = 1, 50 do
                        self.back_a.hscale = 1 - 0.05 * sin(i * 1.8)
                        task.Wait()
                    end
                    for i = 1, 50 do
                        self.back_a.hscale = 0.95 + 0.05 * sin(i * 1.8)
                        task.Wait()
                    end
                end
            end)
            PlaySound("tan00")
            for i = 1, 30 do
                for _, b in ipairs(self.back_c) do
                    b.hscale = sin(i * 3)
                    b.vscale = sin(i * 3)
                end
                task.Wait()
            end
            task.Wait(20)
            task.New(self, function()
                while true do
                    for i = 1, 50 do
                        self.back_b.hscale = 1 - 0.05 * sin(i * 1.8)
                        self.back_b.vscale = self.back_b.hscale
                        task.Wait()
                    end
                    for i = 1, 50 do
                        self.back_b.hscale = 0.95 + 0.05 * sin(i * 1.8)
                        self.back_b.vscale = self.back_b.hscale
                        task.Wait()
                    end
                end
            end)
        end)
        task.New(self, function()
            while true do
                for i = 1, 50 do
                    for t, b in ipairs(self.back_c) do
                        b.rot = sign(b.x) * 10 * sin(i * 1.8) + self:GetAngle(b, t)
                    end
                    task.Wait()
                end
                for i = 1, 50 do
                    for t, b in ipairs(self.back_c) do
                        b.rot = sign(b.x) * 10 * (1 - sin(i * 1.8)) + self:GetAngle(b, t)
                    end
                    task.Wait()
                end
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        if not IsValid(self.master) then
            object.Del(self)
            return
        end
        local x, y = self.master._wisys:GetFloat(self.master.ani)
        self.x = self.master.x + x + self.offx
        self.y = self.master.y + y + self.offy
    end,
    render = function(self)
        Render("byakuren_b", self.x, self.y, self.back_b.rot, self.back_b.hscale, self.back_b.vscale)
        Render("byakuren_a", self.x, self.y, 0, self.back_a.hscale, self.back_a.vscale)
        for t, b in ipairs(self.back_c) do
            Render('byakuren_d', self.x + b.x + 5 * cos(self:GetAngle(b, t)), self.y + b.y + 5 * sin(self:GetAngle(b, t)), 0, b.hscale, b.vscale)
            Render("byakuren_c" .. b.t, self.x + b.x, self.y + b.y, b.rot, b.hscale, b.vscale)
        end
    end,
    del = function(self)
        for _, p in ipairs(self:GetFlowerPos()) do
            enemy.death_ef(p[1], p[2], 10, 1)
        end
        enemy.death_ef(self.x, self.y, 10, 1)
    end,
    kill = function(self)
        self.class.del(self)
    end
})
_editor_class.ByakurenBack = ByakurenBack

local seijagrain = Class(bullet)
_editor_class.Seija_grain = seijagrain
function seijagrain:init(index, x, y, v, a, time, v1, r1, time1, v2, r2, time2)
    bullet.init(self, grain_c, index, false, true)
    self.x, self.y = x, y
    object.SetV(self, v, a, true)
    PlaySound("tan00", 0.1, self.x / 200, true)
    task.New(self, function()
        task.Wait(time)
        object.RawDel(self)
        local b = NewSimpleBullet(grain_a, self._index, self.x, self.y, v, self.rot, nil, nil, false)
        PlaySound("kira00", 0.2, self.x / 200, true)
        b.v = v
        b.v1 = v1
        b.r1 = r1
        b.time1 = time1
        b.v2 = v2
        b.r2 = r2
        b.time2 = time2
        task.New(b, function()
            self = task.GetSelf()
            local _v1 = self.v1 - self.v
            for i = 1, self.time1 do
                i = i / self.time1
                i = 2 * i - i * i
                object.SetV(self, self.v + _v1 * i, self.rot + self. r1, true)
                task.Wait()
            end
            object.RawDel(self)
            b = NewSimpleBullet(grain_c, self._index, self.x, self.y, self.v1, self.rot, nil, nil, false)
            PlaySound("kira01", 0.2, self.x / 200, true)
            b.v1 = self.v1
            b.v2 = self.v2
            b.r2 = self.r2
            b.time2 = self.time2
            task.New(b, function()
                self = task.GetSelf()
                local _v2 = self.v2 - self.v1
                for i = 1, self.time2 do
                    i = i / self.time2
                    i = i * i
                    object.SetV(self, self.v1 + _v2 * i, self.rot + self.r2, true)
                    task.Wait()
                end
            end)
        end)
    end)
end
local seijagrain2 = Class(bullet)
_editor_class.Seija_grain2 = seijagrain2
function seijagrain2:init(style, index1, index2, x, y, vx, vy, dr, dx, dy, dl, time1, time2, time3, sound)
    bullet.init(self, style, index1, false, true)
    self.x, self.y = x, y
    local v, a = sp.math.RectangularToPolar(vx, vy)
    local l = 0
    dr, dx, dy, dl = dr or 0, dx or 0, dy or 0, dl or 0
    sound = sound or true
    task.New(self, function()
        while true do
            self.rot = a
            self.x = x + cos(a) * l
            self.y = y + sin(a) * l
            l = l + v
            task.Wait()
        end
    end)
    time1 = int(time1 or 37)
    time2 = int(time2 or 30)
    time3 = int(time3 or 20)
    task.New(self, function()
        local _bound = self.bound
        self.bound = false
        task.Wait(time1)
        local _v = v
        for i = 1, time2 do
            v = _v * (1 - i / (time2 + time3))
            task.Wait()
        end
        task.Wait(time3)
        task.New(self, function()
            local __v = v
            for i = 1, 90 do
                v = __v + (_v - __v) * i / 90
                task.Wait()
            end
        end)
        local slast = 0
        bullet.ChangeImage(self, self.imgclass, index2)
        Create.bullet_create_eff(self)
        if sound == true then
            PlaySound("kira00")
        end
        for i = 1, 60 do
            i = task.SetMode[2](i / 60)
            a = a + (i - slast) * dr
            x = x + (i - slast) * dx
            y = y + (i - slast) * dy
            l = l + (i - slast) * dl
            slast = i
            task.Wait()
        end
        self.bound = _bound
    end)
end

local RanBack = Class(object, {
    init = function(self, master, interval)
        object.init(self, master.x, master.y, GROUP.INDES, LAYER.ENEMY - 1)
        self.bound = false
        self.img = "ran-ef"
        self._a, self._s = 0, 0
        self._A = 0
        task.New(self, function()
            task.init_left_wait(self)
            while true do
                task.New(self, function()
                    for i = 1, 10 do
                        self._a = sin(i * 9)
                        task.Wait()
                    end
                    for i = 29, 0, -1 do
                        self._a = sin(i * 3)
                        task.Wait()
                    end
                end)
                for i = 1, 60 do
                    self._s = 1 + 0.35 * sin(i * 1.5)
                    task.Wait()
                end
                task.Wait2(self, interval - 60)
            end
        end)
        task.New(self, function()
            while IsValid(master) do
                self._A = 100 + sin(self.timer) * 50
                self.hscale = 1.05 - sin(self.timer) * 0.05
                self.vscale = self.hscale
                local x, y = master._wisys:GetFloat(master.ani)
                self.x, self.y = master.x + x, master.y + y
                task.Wait()
            end
            Del(self)
        end)
    end,
    frame = task.Do,
    render = function(self)
        SetImageState(self.img, "mul+add", self._A, 255, 255, 255)
        object.render(self)
        if self._a > 0 then
            SetImageState(self.img, "mul+add", 255 * self._a, 255, 255, 255)
            Render(self.img, self.x, self.y, 0, self._s)
        end
    end
})
_editor_class.RanBack = RanBack

local SimpleServant = Class(object)
---@param event fun(self:object)
function SimpleServant:init(x, y, a, r, g, b, scale, event, frame)
    object.init(self, x, y, GROUP.INDES, LAYER.ENEMY)
    self.colli = false
    self.img = "servant"
    self.frame_func = frame or load("")
    self._a, self._r, self._g, self._b = a, r, g, b
    self._blend = "mul+add"
    self.hscale = scale
    self.vscale = scale
    self.omega = ran:Float(2, 3) * ran:Sign()
    self.open_smear = false
    self.smear = {}
    self.smear_color = { r / 2, g / 2, b / 2 }
    self.smear_blend = "mul+add"
    self.smear_maxalpha = 150
    self.smear_dealpha = 7
    function self:FadeIn(time, mode, maxalpha)
        maxalpha = maxalpha or 255
        task.New(self, function()
            local nowa = self._a
            mode = mode or 0
            for i = 1, time do
                self._a = nowa + (maxalpha - nowa) * task.SetMode[mode](i / time)
                task.Wait()
            end
        end)
    end
    function self:FadeOut(time, mode)
        task.New(self, function()
            local nowa = self._a
            mode = mode or 0
            for i = 1, time do
                self._a = nowa * task.SetMode[mode](1 - i / time)
                task.Wait()
            end
        end)
    end
    if event then
        event(self)
    end
end
function SimpleServant:frame()
    task.Do(self)
    if self.open_smear then
        local hscale, vscale = self.hscale, self.vscale
        if lstg.weather.QingMing then
            hscale = hscale * 0.5
            vscale = vscale * 0.5
        end
        if lstg.tmpvar._is_challenge18 then
            hscale = hscale * lstg.tmpvar._is_challenge18
            vscale = vscale * lstg.tmpvar._is_challenge18
        end
        table.insert(self.smear, { x = self.x, y = self.y, rot = self.rot,
                                   alpha = self.smear_maxalpha, img = self.img,
                                   hscale = hscale, vscale = vscale })
    end
    object.smear_frame(self, self.smear_dealpha)
    self:frame_func()
end
function SimpleServant:render()
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
    SetImageState(self.img, self._blend, self._a, self._r, self._g, self._b)
    Render(self.img, self.x, self.y, self.rot, hscale, vscale)
end
_editor_class.SimpleServant = SimpleServant

local PointRender = Class(object, {
    init = function(self, point, lifetime, a, r, g, b, noclose, layer, FadeInTime, FadeOutTime)
        object.init(self, 0, 0, 0, layer or LAYER.ENEMY_BULLET - 1)
        self.point = point
        self.lifetime = lifetime
        self.alpha_set = 1
        self._a = a
        self._r, self._g, self._b = r, g, b
        self.close = not noclose
        self.update = true
        self.FadeInTime = FadeInTime or 0
        self.FadeOutTime = FadeOutTime or 0
    end,
    frame = function(self)
        task.Do(self)
        if self.timer <= self.FadeInTime then
            self.alpha_set = min(self.timer / self.FadeOutTime, 1)
        end
        if self.timer >= self.lifetime - self.FadeOutTime then
            local k = self.timer - (self.lifetime - self.FadeOutTime)
            self.alpha_set = max(1 - k / self.FadeOutTime, 0)
        end
        if self.timer >= self.lifetime then
            Del(self)
        end
    end,
    render = function(self)
        SetImageState("white", "mul+add", self._a * self.alpha_set, self._r, self._g, self._b)
        if self.update then
            sp:UnitListUpdate(self.point)
        end
        misc.RenderPointLine("white", self.point, 1, self.close)
    end
})
_editor_class.PointRender = PointRender

-- 支持自定义宽度的 PointRender
-- 注意，最后一个参数不是 width 是 layer
local PointRenderWidth = Class(object, {
    init = function(self, point, lifetime, a, r, g, b, noclose, width, layer)
        object.init(self, 0, 0, 0, layer or LAYER.ENEMY_BULLET - 1)
        self.point = point
        self.lifetime = lifetime
        self._a = a
        self._r, self._g, self._b = r, g, b
        self.close = not noclose
        self.update = true
        self.w = width or 1
    end,
    frame = function(self)
        task.Do(self)
        if self.timer >= self.lifetime then
            Del(self)
        end
    end,
    render = function(self)
        SetImageState("white", "mul+add", self._a, self._r, self._g, self._b)
        if self.update then
            sp:UnitListUpdate(self.point)
        end
        misc.RenderPointLine("white", self.point, self.w, self.close)
    end
})
_editor_class.PointRenderWidth = PointRenderWidth

local EFF_BRIGHTPILLAR = Class(object, {
    init = function(self, time, x, y, rot, width, Hue, alpha, event)
        self.rx, self.ry = 0, 0
        self.rot = rot
        self.x, self.y = x, y
        self.width = width
        self.layer = LAYER.BG + 10
        self.group = GROUP.GHOST
        self.alpha = 0
        self.bound = false
        self.Hue = Hue
        self.linew = 1
        self.S = 0.4
        self.V = 1
        if event then
            event(self)
        end
        task.New(self, function()
            for i = 1, 90 do
                self.alpha = alpha * sin(i)
                task.Wait()
            end
            task.Wait(time - 135)
            for i = 1, 45 do
                self.alpha = alpha - alpha * sin(i * 2)
                task.Wait()
            end
            Del(self)
        end)
    end,
    frame = function(self)
        task.Do(self)
    end,
    render = function(self)
        local r, g, b = sp:HSVtoRGB(self.Hue, self.S, self.V)
        SetImageState("white", "mul+add", 666, 0, 0, 0)--刷新存储列表
        OriginalSetImageState("white", "mul+add",
                Color(self.alpha * 255, r, g, b),
                Color(self.alpha * 255, r, g, b),
                Color(0, r, g, b), Color(0, r, g, b))
        local w = self.width / 2 - self.linew
        Render("white",
                self.x + cos(self.rot + 90) * w,
                self.y + sin(self.rot + 90) * w,
                self.rot + 180, 100, self.width / 16)
        Render("white",
                self.x + cos(self.rot - 90) * w,
                self.y + sin(self.rot - 90) * w,
                self.rot, 100, self.width / 16)
    end
}, true)
_editor_class.EFF_BRIGHTPILLAR = EFF_BRIGHTPILLAR

local EFF_BRIGHTLINE = Class(object, {
    init = function(self, time, x, y, rot, width, length, Hue, alpha, event)
        self.rx, self.ry = 0, 0
        self.rot = rot
        self.x, self.y = x, y
        self.width = width
        self.layer = LAYER.BG + 10
        self.group = GROUP.GHOST
        self.alpha = 0
        self.bound = false
        self.Hue = Hue
        self.S = 0.4
        self.V = 1
        self.length = length
        if event then
            event(self)
        end
        task.New(self, function()
            for i = 1, 90 do
                self.alpha = alpha * sin(i)
                task.Wait()
            end
            task.Wait(time - 135)
            for i = 1, 45 do
                self.alpha = alpha - alpha * sin(i * 2)
                task.Wait()
            end
            Del(self)
        end)
    end,
    frame = function(self)
        task.Do(self)
    end,
    render = function(self)
        SetImageState("bright_line", "mul+add", self.alpha * 255, sp:HSVtoRGB(self.Hue, self.S, self.V))
        Render("bright_line", self.x, self.y, self.rot, self.length / 200, self.width / 32)
    end
}, true)
_editor_class.EFF_BRIGHTLINE = EFF_BRIGHTLINE

local KanakoBack = Class(object, {
    init = function(self, master, radius, range)
        self.master = master
        self.group = GROUP.GHOST
        self.layer = LAYER.BG + 0.8
        self.bound = false
        self.circle = {
            { color = { 255, 0, 0 }, x = 500, y = 500 },
            { color = { 0, 255, 0 }, x = 500, y = 500 },
            { color = { 0, 0, 255 }, x = 500, y = 500 },
        }
        self.pillar = { New(self.class.pillar, self, "left", -500, 0), New(self.class.pillar, self, "right", 500, 0) }
        self.event = {}
        self.rotate = false
        self.rotate_radius = radius or 100
        self.rotate_timer = 0
        self.rotate_range = range or 3
        setmetatable(self.event, {
            __newindex = function(_, k, v)
                if k == "open" then
                    task.New(self, function()
                        for i = 1, v do
                            for a, c in ipairs(self.circle) do
                                c.x = cos(a * 120 + 360 * sin(i / v * 90)) * 400 * (1 - i / v)
                                c.y = sin(a * 120 + 360 * sin(i / v * 90)) * 400 * (1 - i / v)
                            end
                            self.pillar[1]._x = -500 + 500 * sin(i / v * 90)
                            self.pillar[2]._x = 500 - 500 * sin(i / v * 90)
                            task.Wait()
                        end
                    end)
                elseif k == "close" then
                    self.circle = {
                        { color = { 255, 0, 0 }, x = 500, y = 500 },
                        { color = { 0, 255, 0 }, x = 500, y = 500 },
                        { color = { 0, 0, 255 }, x = 500, y = 500 },
                    }
                    self.pillar = { New(self.class.pillar, self, "left", -500, 0), New(self.class.pillar, self, "right", 500, 0) }
                    enemy.death_ef(self.x, self.y, 10, 1)
                    PlaySound("explode")
                elseif k == "rotate" then
                    self.rotate = v
                    if not v then
                        enemy.death_ef(self.x, self.y, 10, 1)
                    end
                    self.rotate_timer = 0
                    for _, c in ipairs(self.circle) do
                        c.x = 0
                        c.y = 0
                    end
                end
            end })
    end,
    frame = function(self)
        if not IsValid(self.master) then
            object.Del(self)
            return
        end
        task.Do(self)
        self.x, self.y = self.master.x, self.master.y + 4 * sin(self.master.ani * 4)
        if self.rotate then
            local t, rad, range = self.rotate_timer, self.rotate_radius, self.rotate_range
            for a, c in ipairs(self.circle) do
                c.x = cos(t * sign(range) + a * 120) * rad + cos(t * range + a * 120 + 180) * rad
                c.y = sin(t * sign(range) + a * 120) * rad + sin(t * range + a * 120 + 180) * rad
            end
            self.rotate_timer = self.rotate_timer + 1
        end
    end,
    render = function(self)
        if not IsValid(self.master) then
            return
        end
        for _, c in ipairs(self.circle) do
            SetImageState("kanako-ef", "mul+add", 128, unpack(c.color))
            Render("kanako-ef", self.x + c.x, self.y + c.y)
        end
    end,
    pillar = Class(object, {
        init = function(self, master, img, x, y)
            self.group = GROUP.GHOST
            self.layer = LAYER.BG + 10
            self.master = master
            self.img = "kanako-ef2_" .. img
            self._x = x
            self._y = y
            self.x = self.master.x + self._x
            self.y = self.master.y + self._y
            self.bound = false
        end,
        frame = function(self)
            task.Do(self)
            if not IsValid(self.master) then
                object.Del(self)
                return
            end
            self.x = self.master.x + self._x
            self.y = self.master.y + self._y
        end,
    }, true),
    del = function(self)
        enemy.death_ef(self.x, self.y, 10, 1)
    end,
    kill = function(self)
        self.class.del(self)
    end,
})
_editor_class.KanakoBack = KanakoBack

local RedEye = Class(_object, {
    init = function(self, _x, _y, t, a, i)
        self.x, self.y = _x, _y
        self.img = "eye" .. i
        self.layer = LAYER.ENEMY_BULLET_EF
        self.group = GROUP.GHOST
        self.hide = false
        self.bound = true
        self.navi = false
        self.hp = 10
        self.maxhp = 10
        self.colli = true
        self._servants = {}
        self._blend, self._a, self._r, self._g, self._b = '', 255, 255, 255, 255
        self.vscale = a
        self.hscale = a
        _object.set_color(self, "mul+add", 255, 255, 255, 255)
        task.New(self, function()
            task.Wait(t)
            object.Del(self)
        end)
    end
})
---红眼效果
---@param totaltime number@持续时间
---@param eye_lifetime number@拖影时长
---@param scbg_layer lstg.GameObject@将boss的卡背的要变化的图层传进去
local function RedEyeEff(self, totaltime, eye_lifetime, scbg_layer, nosound)
    task.New(self, function()
        eye_lifetime = eye_lifetime or 50
        if not nosound then
            PlaySound("slash")
        end
        NewPulseScreen(0, { 100, 0, 0 }, "mul+add", 10, totaltime - 15, 5)
        do
            local time = totaltime - eye_lifetime
            local x1, _d_x1 = (-140), (50 / (time - 1))
            local x2, _d_x2 = (140), (-50 / (time - 1))
            local a, _d_a = (1.6), (-0.6 / (time - 1))
            local t, _d_t = (11), (1)
            if scbg_layer then
                scbg_layer.omega = 1.5
            end
            for _ = 1, time do

                New(RedEye, x1, eye_lifetime, t, a, "L")
                New(RedEye, x2, eye_lifetime, t, a, "R")
                task.Wait()
                x1 = x1 + _d_x1
                x2 = x2 + _d_x2
                a = a + _d_a
                t = t + _d_t
            end
            task.Wait(eye_lifetime)
            if not nosound then
                PlaySound("kira00")
            end
            if scbg_layer then
                scbg_layer.omega = -0.5
            end
        end
    end)

end
_editor_class.RedEyeEff = RedEyeEff

local YukariBack = Class(object, {
    init = function(self, master)
        self.master = master
        self.layer = LAYER.ENEMY - 1
        self.bound = false
        self.group = GROUP.GHOST
    end,
    frame = function(self)
        if not IsValid(self.master) then
            object.Del(self)
            return
        end
        local master = self.master
        local x, y = master._wisys:GetFloat(master.ani)
        self.x, self.y = master.x + x, master.y + y
    end,
    render = function(self)
        local t = self.timer
        SetImageState("yukari-ef", "mul+add", 50 + min(150, t) + sin(t * 0.7 - 90) * 50, 255, 255, 255)
        Render("yukari-ef", self.x, self.y, -0.5 * t, 1.8 + sin(t * 0.7 + 135) * 0.1)
    end
})
_editor_class.YukariBack = YukariBack

SetImageCenter("junko_back", 0, 42)
local JunkoBack = Class(object, {
    init = function(self, master, co, rot)
        self.master = master
        self.x, self.y = self.master.x, self.master.y
        self._r, self._g, self._b = co * 50, 70, 300 - co * 50
        self._a = 200
        self.rot = rot
        self.group = GROUP.GHOST
        self.layer = LAYER.ENEMY - 1
        self.bound = false
        self.img = "junko_back"
        self.vscale = 0
        self.back2 = {}
        task.New(self, function()
            task.SmoothSetValueTo("vscale", 1, 30, 2)
            local r = 0
            local ss = -abs(co - 3) * 40
            while true do
                self._a = 200 + 50 * sin(r)
                if ss % 360 == 0 then
                    table.insert(self.back2, { timer = 0 })
                end
                r = r + 4
                ss = ss + 4
                task.Wait()
            end
        end)
        task.New(self, function()
            while true do
                for i = 1, 50 do
                    self.hscale = 1 - 0.05 * sin(i * 1.8)
                    task.Wait()
                end
                for i = 1, 50 do
                    self.hscale = 0.95 + 0.05 * sin(i * 1.8)
                    task.Wait()
                end
            end
        end)
    end,
    frame = function(self)
        if not IsValid(self.master) then
            object.Del(self)
            return
        end
        task.Do(self)
        self.x, self.y = self.master.x, self.master.y
        local b
        for i = #self.back2, 1, -1 do
            b = self.back2[i]
            b.timer = b.timer + 1
            b.alpha = 210 - 7 * b.timer
            b.hscale = 1 + 0.75 * sin(b.timer * 3)
            b.vscale = 1 + 0.2 - 0.2 * sin(b.timer * 7.5)
            if b.timer == 30 then
                table.remove(self.back2, i)
            end
        end
    end,
    render = function(self)
        SetImageState(self.img, "mul+add", self._a, self._r, self._g, self._b)
        DefaultRenderFunc(self)
        for _, p in ipairs(self.back2) do
            SetImageState(self.img, "mul+add", p.alpha, self._r, self._g, self._b)
            Render(self.img, self.x, self.y, self.rot, p.hscale, p.vscale)
        end
    end
})
_editor_class.JunkoBack = JunkoBack



