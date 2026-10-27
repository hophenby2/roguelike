local path = "assets\\addition_unit\\"

LoadImageFromFile("level_obj_resurrection_bird", path .. "resurrection_bird.png")
LoadImageFromFile("level_obj_detector_bullet", path .. "detector_bullet.png", nil, 10, 10)
LoadImageFromFile("level_obj_rewind_clock", path .. "rewind_clock.png", nil, 10, 10)
LoadTexture("level_obj_snow", path .. "obj6.png", true)
LoadImageGroup("level_obj_snow", "level_obj_snow", 0, 0, 64, 64, 8, 3, 32, 32)
LoadTexture2("level_obj_shield", path .. "shield.png", true)
LoadImageFromFile("level_obj_protect_lotus", path .. "protect_lotus.png", true)

---@class level_obj2
local class2 = {}

local SUN = Class(object, {
    init = function(self)
        self.bound = false
        self.layer = 3
        self.alpha = 0
        self.particle = {}
        self.y = -240
        task.New(self, function()
            for i = 1, 30 do
                self.alpha = task.SetMode[2](i / 30)
                task.Wait()
            end
        end)
        self._event_FUNC = function(b)
            if abs(b.y - self.y) < 4 then
                object.Del(b)
            else
                if not b._frozen and not b.not_move then
                    local acc = clamp(1 / (b.y - self.y), 0, 0.2)
                    if b.group == GROUP.ENEMY_BULLET then
                        acc = acc / (b.a / 3)
                    elseif b.A then
                        acc = acc / (b.A / 4)
                    end
                    if not b._sun_accel then
                        b._sun_accel = acc
                    end
                    b._sun_accel = acc
                    b.vy = b.vy + b._sun_accel
                    if b.y > 450 then
                        object.RawDel(b)
                    end
                end
            end
        end
    end,
    frame = function(self)
        task.Do(self)
        if self.timer % (6 - setting.rdQual) == 0 then
            table.insert(self.particle, {
                alpha = 0, maxalpha = ran:Float(120, 180),
                size = ran:Float(4, 9),
                x = ran:Float(-320, 320), y = self.y,
                vx = ran:Float(-2, 2), vy = ran:Float(-2, 2),
                timer = 0, lifetime = ran:Int(30, 60),
                rot = ran:Float(0, 360), omega = ran:Float(1, 2) * ran:Sign()
            })
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
        object.BulletDo(function(b)
            self._event_FUNC(b)
        end)
        object.EnemyNontjtDo(function(b)
            if not b.IsBoss then
                if not b.style or (b.style <= 22) then
                    self._event_FUNC(b)
                end
            end
        end)
        for _, b in ObjList(GROUP.ITEM) do
            if not b.is_drop_point then
                self._event_FUNC(b)
            end
        end
    end,

    render = function(self)
        local r, g, b = 255, 200, 120
        local col1 = Color(0, r, g, b)
        local col2 = Color(self.alpha * 75, r, g, b)
        SetImageState("white", "mul+add", 666, 0, 0, 0)--刷新存储列表
        OriginalSetImageState("white", "mul+add", col1, col1, col2, col2)
        RenderRect("white", -320, 320, self.y - 1, self.y + 30)
        RenderRect("white", -320, 320, self.y + 1, self.y - 30)
        for _, p in ipairs(self.particle) do
            SetImageState("white", "mul+add", p.alpha, r, g, b)
            misc.SectorRender(p.x, p.y, p.size * 0.9, p.size, 0, 360, 10, p.rot)
        end

    end
}, true)
class2.SUN = SUN

local resurrection_bird = Class(object, {
    init = function(self)
        self.bound = false
        self.img = "level_obj_resurrection_bird"
        self.layer = LAYER.PLAYER - 5
        self.group = GROUP.PLAYER
        self.hscale = 8
        self.vscale = 0
        self.x, self.y = player.x, player.y
        NewWave(self.x, self.y, 2, 300, 125, 250, 128, 114)
        lstg.tmpvar.bird_resurrecting = true
        player.StopLoss = true
        task.New(self, function()
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                self.hscale = 8 - 7 * i
                self.vscale = i
                task.Wait()
            end
        end)
        task.New(self, function()
            local p = player
            p.dmg_fixed = p.dmg_fixed - 0.9
            task.Wait(266)
            p.dmg_fixed = p.dmg_fixed + 0.9
            lstg.tmpvar.bird_resurrecting = false
            player.StopLoss = false
            lstg.tmpvar.bird_resurrected = lstg.tmpvar.bird_resurrected + 1
            player_lib.AddLife(lstg.var.maxlife / 2)
            PlaySound("explode")
            New(bullet_cleaner, self.x, self.y, 300, 90, 100, true, false, 0)
            Newcharge_out(self.x, self.y, 250, 128, 114)
            NewBon(self.x, self.y, 60, 128, 255, 227, 132)
            NewWave(self.x, self.y, 2, 300, 125, 255, 227, 132)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                self.hscale = 1 + 7 * i
                self.vscale = 1 - i
                task.Wait()
            end
            Del(self)

        end)
    end,
    frame = function(self)
        task.Do(self)
        self.x, self.y = player.x, player.y
    end,
    render = function(self)
        SetImageState(self.img, "mul+add", 255, 255, 255, 255)
        local reverse_vscale = lstg.var.reverse_shoot and (-1) or 1
        Render(self.img, self.x, self.y, self.rot, self.hscale, self.vscale * reverse_vscale)
    end
}, true)
class2.resurrection_bird = resurrection_bird

local lie_detector = Class(object, {
    init = function(self)
        self.bound = false
        self.count = 1
        self.x, self.y = player.x, player.y
        self.group = GROUP.PLAYER
        self.layer = LAYER.PLAYER - 3
        self.r = 25
        self.maxR = 60
        self.minR = 15
        self.roindex = 3
        self.smear = {}
        self.pos = {}
        self.H = 0
        self.alpha = 0
        self.onesecond = {}
        for a, i in sp.math.AngleIterator(self.timer * self.roindex, self.count * 3) do
            self.pos[i * 2 - 1] = self.x + cos(a) * self.r
            self.pos[i * 2] = self.y + sin(a) * self.r
        end
        task.New(self, function()
            for i = 1, 15 do
                self.alpha = i / 15
                task.Wait()
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        local p = player
        if #self.onesecond < 60 then
            table.insert(self.onesecond, p._playersys:keyIsPressed("slow") and true)
        else
            table.remove(self.onesecond, 1)
            table.insert(self.onesecond, p._playersys:keyIsPressed("slow") and true)
            if self.maxR <= 266 then
                self.maxR = self.maxR + 0.514
            end
        end
        local dmgindex = 0
        for _, t in ipairs(self.onesecond) do
            if t then
                dmgindex = dmgindex + 1
                self.maxR = 60
            end
        end
        if self.count >= 2 and dmgindex > 12 then
            ext.achievement:get(66)
        end

        self.H = self.timer
        self.x = self.x + (-self.x + p.x) * 0.2
        self.y = self.y + (-self.y + p.y) * 0.2
        local R = p.__slow_flag and self.minR or self.maxR
        self.r = self.r + (-self.r + R) * 0.1

        for a, i in sp.math.AngleIterator(self.timer * self.roindex, self.count * 3) do
            local lx, ly = self.pos[i * 2 - 1], self.pos[i * 2]
            local nx, ny = self.x + cos(a) * self.r, self.y + sin(a) * self.r
            lx = lx or nx
            ly = ly or ny
            self.pos[i * 2 - 1] = nx
            self.pos[i * 2] = ny
            local inc = 2 + 2 * (1 - setting.rdQual / 5)
            local dx, dy = nx - lx, ny - ly
            local d = hypot(dx, dy)
            local count = int(d / inc)
            local ix = inc * (dx / d)
            local iy = inc * (dy / d)
            local cR, cG, cB = 254, 31, 29
            if self.count >= 2 then
                local fb = (i % self.count) / self.count
                cR, cG, cB = 254 - 10 * fb, 31 - 27 * fb, 29 + 67 * fb
            end
            for k = 0, count do
                table.insert(self.smear, {
                    x = nx - k * ix,
                    y = ny - k * iy,
                    H = self.H,
                    alpha = 8,
                    size = 12,
                    timer = 0,
                    cR = cR, cG = cG, cB = cB
                })
            end
            if player._playersys:keyIsPressed("slow") then
                local dmg = player.damage
                task.New(self, function()
                    for i = 1, max(1, dmgindex / 3.3) * max(1, (self.r / 3) - 12) do
                        New(class2.lie_detector_bullet, nx, ny, a + i * 5.14, dmg * dmgindex * dmgindex * 0.05 * max(1, self.r / 100), dmgindex)
                        task.Wait()
                    end
                end)
            end
        end
        local s
        for i = #self.smear, 1, -1 do
            s = self.smear[i]
            s.timer = s.timer + 1
            s.size = s.size - s.size * 0.03
            if s.timer > 21 - self.count then
                s.alpha = max(s.alpha - 0.65 - self.count * 0.15, 0)
                if s.alpha == 0 then
                    table.remove(self.smear, i)
                end
            end
        end


    end,
    render = function(self)
        SetImageState("white", "mul+add", self.alpha * 28, sp:HSVtoRGB(self.H, 0.6, 0.8))
        misc.SectorRender(self.x, self.y, self.r - 2, self.r, 0, 360, 25 + setting.rdQual * 2)
        for i = 1, self.count * 3 do
            local x, y = self.pos[i * 2 - 1] or 0, self.pos[i * 2] or 0
            SetImageState("white", "mul+add", self.alpha * 95, 255, 255, 255)
            misc.SectorRender(x, y, 0, 6, 0, 360, 10)

            for _, s in ipairs(self.smear) do
                SetImageState("bright", "mul+add", self.alpha * s.alpha, s.cR, s.cG, s.cB)
                Render("bright", s.x, s.y, 0, s.size / 150)
            end
        end
    end
}, true)
class2.lie_detector = lie_detector

local lie_detector_bullet = Class(object, {
    init = function(self, x, y, a, dmg, r)
        player_bullet_straight.init(self, "level_obj_detector_bullet", x, y, 0, a, dmg)
        self.hscale, self.vscale = 0.7, 0.7
        self.r = task.SetMode[2](r / 30)
        object.SetSizeColli(self, 0.5)
        task.New(self, function()
            task.Wait(30)
            object.ChangingV(self, 0, 16, a, 100)
        end)
    end,
    frame = task.Do,
    render = function(self)
        SetImageState(self.img, "mul+add", 100, 255, 255 - self.r * 255, 255 - self.r * 255)
        DefaultRenderFunc(self)
    end,
    kill = function(self)
        New(class2.lie_detector_bullet_ef, self.x, self.y, self.rot, self.r)
    end
}, true)
class2.lie_detector_bullet = lie_detector_bullet

local lie_detector_bullet_ef = Class(object, {
    init = function(self, x, y, rot, r)
        self.x = x
        self.y = y
        self.img = "level_obj_detector_bullet"
        self.layer = LAYER.PLAYER_BULLET + 50
        self.group = GROUP.GHOST
        self.colli = false
        object.SetV(self, 2.25, rot, true)
        self.hscale = 0.7 * 0.5
        self.vscale = 0.7 * 0.5
        self.r = r
    end,
    frame = function(self)
        if self.timer == 15 then
            object.RawDel(self)
        end
    end,
    render = function(self)
        local a = 100 * (1 - self.timer / 15)
        SetImageState(self.img, "mul+add", a, 255, 255 - self.r * 255, 255 - self.r * 255)
        DefaultRenderFunc(self)
    end,
}, true)
class2.lie_detector_bullet_ef = lie_detector_bullet_ef

local fallen_snow_bullet = Class(object, {
    init = function(self, x, y, imgt)
        imgt = imgt or ran:Int(1, 19)
        if lstg.var.reverse_shoot then
            y = -y
        end
        player_bullet_straight.init(self, "level_obj_snow" .. imgt, x, y,
                0, ran:Float(0, 360), 1 + player.damage * 0.50)
        object.SetSizeColli(self, ran:Float(0.35, 0.6))
        self.omega = ran:Float(2, 3) * ran:Sign()
        self.ag = self.hscale / 0.6 * 0.04
        if lstg.var.reverse_shoot then
            self.ag = -self.ag
        end
        self.maxv = 5
        self.alpha = 1
    end,
    frame = function(self)
        task.Do(self)
        if lstg.tmpvar.SUN then
            self.alpha = clamp((self.y + 45) / (240 + 45), 0, 1)
            if self.alpha == 0 then
                Del(self)
            end
        end
    end,
    render = function(self)
        local GB = 255
        if lstg.var.blood_magic then
            GB = 100
        end
        SetImageState(self.img, "mul+add", 100 * self.alpha, 255, GB, GB)
        DefaultRenderFunc(self)
    end,
    kill = function(self)
        New(class2.fallen_snow_bullet_ef, self.x, self.y, self.hscale, self.rot, self.omega, self.img, self.alpha)
    end
}, true)
class2.fallen_snow_bullet = fallen_snow_bullet

local fallen_snow_bullet_ef = Class(object, {
    init = function(self, x, y, size, rot, omega, img, alpha)
        self.x = x
        self.y = y
        object.SetSizeColli(self, size)
        self.img = img
        self.layer = LAYER.PLAYER_BULLET + 50
        self.group = GROUP.GHOST
        self.colli = false
        self.omega = omega
        self.alpha = alpha
        object.SetV(self, 2.25, rot, true)
    end,
    frame = function(self)
        if self.timer == 15 then
            object.RawDel(self)
        end
    end,
    render = function(self)
        local GB = 255
        if lstg.var.blood_magic then
            GB = 100
        end
        local a = 100 * (1 - self.timer / 15)
        SetImageState(self.img, "mul+add", a * self.alpha, 255, GB, GB)
        DefaultRenderFunc(self)
    end,
}, true)
class2.fallen_snow_bullet_ef = fallen_snow_bullet_ef

local fallen_snow_winter_ef = Class(object, {
    init = function(self)
        self.bound = false
        self.layer = 3
        self.alpha = 0
        self.particle = {}
        self.y = 240
        task.New(self, function()
            for i = 1, 30 do
                self.alpha = task.SetMode[2](i / 30)
                task.Wait()
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        local ky = 1
        if lstg.var.reverse_shoot then
            self.y = -240
            ky = -1
        else
            self.y = 240
        end
        if self.timer % (7 - setting.rdQual) == 0 then
            table.insert(self.particle, {
                alpha = 0, maxalpha = ran:Float(40, 70),
                size = ran:Float(0.2, 0.3),
                x = ran:Float(-320, 320), y = self.y,
                vx = ran:Float(-0.2, 0.2), vy = ran:Float(-2, -1) * ky,
                timer = 0, lifetime = ran:Int(30, 60),
                img = "level_obj_snow" .. ran:Int(1, 19),
                rot = ran:Float(0, 360), omega = ran:Float(1, 2) * ran:Sign()
            })
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
        local r, g, b = 60, 60, 235
        local col1 = Color(0, r, g, b)
        local col2 = Color(self.alpha * 75, r, g, b)
        SetImageState("white", "mul+add", 666, 0, 0, 0)--刷新存储列表
        OriginalSetImageState("white", "mul+add", col1, col1, col2, col2)
        RenderRect("white", -320, 320, self.y + 1, self.y - 100)
        RenderRect("white", -320, 320, self.y - 1, self.y + 100)
        for _, p in ipairs(self.particle) do
            SetImageState(p.img, "mul+add", p.alpha, 200, 200, 200)
            Render(p.img, p.x, p.y, p.rot, p.size)
        end

    end
}, true)
class2.fallen_snow_winter_ef = fallen_snow_winter_ef

local enemy_contact_ef = Class(object, {
    init = function(self)
        self.group = GROUP.GHOST
        self.layer = LAYER.ENEMY - 1
    end,
    render = function()
        local enemy_list = {}
        object.EnemyNontjtDo(function(e)
            table.insert(enemy_list, e)
        end)
        SetImageState("white", "mul+add", 26, 255, 227, 132)
        misc.RenderPointLine("white", enemy_list, 1.3, false)
    end
}, true)
class2.enemy_contact_ef = enemy_contact_ef

local sekibanki_head = Class(object, {
    init = function(self, offa)

        self._wisys = BossWalkImageSystem(self)
        self._wisys:SetImageInList("Sekibanki_head2")
        self.A, self.B = 5, 5
        self.bound = false
        self.group = GROUP.PLAYER_BULLET
        self.layer = LAYER.PLAYER_BULLET
        self.killflag = true
        self.x, self.y = self.x, self.y + 24 + sin(self.ani * 4) * 4
        self.bound = false
        self._blend = "mul+add"
        self._a = 0
        self._r, self._g, self._b = 200, 200, 200
        self.noTPbyYukari = true
        self.x, self.y = ran:Float(-280, 280), ran:Float(0, 180)
        self._x, self._y = self.x, self.y
        self.offa = offa
        self.m = 0
        task.New(self, function()
            for i = 1, 25 do
                self._a = 255 * i / 25
                task.Wait()
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        self._wisys:frame()
        object.smear_add(self, self._a * 0.7)
        object.smear_frame(self, 10 + 0.5 * (5 - setting.rdQual))
        self.dmg = player.damage * 0.16
        local w = lstg.world
        if self.y > w.t then
            self.vy = -self.vy
            self.y = w.t - (self.y - w.t)
        end
        if self.y < w.b then
            self.vy = -self.vy
            self.y = w.b - (self.y - w.b)
        end
        if self.x > w.r then
            self.vx = -self.vx
            self.x = w.r - (self.x - w.r)
        end
        if self.x < w.l then
            self.vx = -self.vx
            self.x = w.l - (self.x - w.l)
        end
        local t = stage.current_stage.timer * 3
        local o = self.target

        if IsValid(o) and o.colli and o.class.base.take_damage then
            local colli = o.a or o.A
            local R = colli * 3
            local mx, my = o.x, o.y
            local index = 0.05
            self._x = self._x + (-self._x + mx) * index
            self._y = self._y + (-self._y + my) * index
            self.m = self.m + (-self.m + 1) * index
            self.x = self._x + R * cos(t + self.offa) * self.m
            self.y = self._y + R * sin(t + self.offa) * self.m
        else
            player_class.findtarget(self)
            if not IsValid(self.target) then
                self.m = 0
                self.vx, self.vy = self.dx, self.dy
                self._x = self.x
                self._y = self.y
            end
        end

    end,
    render = function(self)
        object.smear_render(self, "mul+add", { 10, 50, 50 })
        self._wisys:render()
    end,
    kill = function(self)
        enemy.death_ef(self.x, self.y, 10, 1)
    end,
    del = function(self)
        self.class.kill(self)
    end
}, true)
class2.sekibanki_head = sekibanki_head

local golden_body = Class(object, {
    init = function(self)
        self.group = GROUP.PLAYER_BULLET
        self.layer = LAYER.PLAYER - 5
        self.a, self.b = 26, 26
        self.killflag = true
        self.dmg = 0
        self.bound = false
    end,
    frame = function(self)
        self.dmg = player.damage
        if player.timer % 15 == 0 then
            self.x, self.y = player.x, player.y
        else
            self.x, self.y = 5555, 5555
        end

    end,
    render = function()
        local p = player
        local A = p._a * p._wisys.alpha * p._wisys.alpha2
        local v = lstg.var
        local reverse_vscale = v.reverse_shoot and (-1) or 1
        local _a = A * (0.6 + 0.2 * sin(p.timer * 2))
        SetImageState(p.img, "add+alpha", _a, 255, 227, 132)
        local Scale = 1
        if v.neutron_star then
            Scale = 0.75
        end
        if lstg.tmpvar._is_challenge18 then
            Scale = Scale * lstg.tmpvar._is_challenge18
        end
        Render(p.img, p.x, p.y, p.rot, p.hscale * 1.1 * Scale, p.vscale * reverse_vscale * 1.1 * Scale)
    end
}, true)
class2.golden_body = golden_body

local TPyyy = Class(object, {
    init = function(self)
        self.group = GROUP.GHOST
        self.layer = LAYER.ENEMY - 5
        self.x, self.y = 666, 666
        self.bound = false
        self.index = 0
        self.img = "TPyyy2"
        self.omega = 2.5
        self.bsize = 0
        self.CD = 0
    end,
    frame = function(self)
        task.Do(self)
        self.index = self.index - self.index * 0.05
        player_class.findtarget(player)
        local t = player.target2--运用新目标
        if IsValid(t) then
            self.x, self.y = t.x, t.y
            self.bsize = t.a
            if self.CD == 0 and player._playersys:keyIsPressed("spell") then
                NewBon(self.x, self.y, 30, 40, 255, 64, 64)
                player.x, player.y = self.x, self.y
                NewBon(self.x, self.y, 30, 40, 255, 64, 64)
                self.index = 1
                PlaySound("goast2")
                self.CD = 12
                player.protect = max(player.protect, 9)
            end
        else
            self.x, self.y = 666, 666
        end
        self.CD = max(self.CD - 1, 0)
    end,
    render = function(self)
        local sk = sin(self.timer * 3) * 0.03
        local alpha = 180 - self.CD * 9
        SetImageState(self.img, "mul+add", alpha, 255, 255, 255)
        Render(self.img, self.x, self.y, self.rot, self.bsize / 38 + self.index * 0.1 + sk)
    end
}, true)
class2.TPyyy = TPyyy

local active_stars = {}
local active_star_bullet = Class(object, {
    init = function(self)
        local x, y = ran:Float(-320, 320), ran:Float(-240, 240)
        player_bullet_straight.init(self, "star_46", x, y,
                0, 45, player.damage * 0.49)
        self.size = ran:Float(0.06, 0.09)
        object.SetSize(self, self.size)
        self.a = self.hscale * 200
        self.b = self.a
        self.alpha = 0
        task.New(self, function()
            for i = 1, 10 do
                self.alpha = i / 10
                task.Wait()
            end
        end)
        sp:UnitListAppend(active_stars, self)
    end,
    frame = function(self)
        task.Do(self)
        object.SetSize(self, self.size + sin(self.timer * 5) * 0.015)
        if self.timer >= 240 then
            Kill(self)
        end
    end,
    render = function(self)
        local r, g, b = 135, 206, 235
        SetImageState("bright", "mul+add", self.alpha * 40, r, g, b)
        Render("bright", self.x, self.y, self.rot, self.hscale * 2.3)
        SetImageState(self.img, "mul+add", 50 * self.alpha, 255, 255, 255)
        DefaultRenderFunc(self)
    end,
    kill = function(self)
        New(class2.active_star_bullet_ef, self.x, self.y, self.hscale, self.rot, self.omega, self.img, self.alpha)
    end
}, true)
class2.active_star_bullet = active_star_bullet

local active_star_bullet_ef = Class(object, {
    init = function(self, x, y, size, rot, omega, img, alpha)
        self.x = x
        self.y = y
        object.SetSize(self, size)
        self.img = img
        self.layer = LAYER.PLAYER_BULLET + 50
        self.group = GROUP.GHOST
        self.colli = false
        self.omega = omega
        self.alpha = alpha
        self.rot = rot
        -- object.SetV(self, 2.25, rot, true)
    end,
    frame = function(self)
        if self.timer == 15 then
            object.RawDel(self)
        end
    end,
    render = function(self)
        local a = 50 * (1 - self.timer / 15)
        SetImageState(self.img, "mul+add", a * self.alpha, 255, 255, 255)
        DefaultRenderFunc(self)
    end,
}, true)
class2.active_star_bullet_ef = active_star_bullet_ef

local active_star_back = Class(object, {
    init = function(self)
        self.alpha = 0
        self._alpha = 0
        self.layer = LAYER.BG + 5
        self.grop = GROUP.GHOST
    end,
    frame = function(self)
        sp:UnitListUpdate(active_stars)
        local count = #active_stars
        if count >= 70 then
            if count >= 195 then
                ext.achievement:get(77)
            end
            self._alpha = 0.4 + min(1, (count - 70) / 125) * 0.6
        else
            self._alpha = 0
        end
        self.alpha = self.alpha + (-self.alpha + self._alpha) * 0.07
    end,
    render = function(self)
        local ox = sin(self.timer * 0.1) * 30
        SetImageState("star_back", "", self.alpha * 255, 255, 255, 255)
        Render("star_back", ox, 0, 0, 0.5)
    end
}, true)
class2.active_star_back = active_star_back

local kappa_shield = Class(object, {
    init = function(self)
        self.layer = LAYER.PLAYER + 2
        self.colli = false
        self.bound = false
        self.x, self.y = 0, 0
        self.vx, self.vy = 2, 0
        self.alpha = 0
        self._a = 0
        self.__a = 0
        self.index = 0

        task.New(self, function()
            for i = 1, 30 do
                self.alpha = i / 30
                task.Wait()
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        self.vy = sin(self.timer * 2)
        local c = int(lstg.var.shield_count)
        self.__a = 100 + 35 * c
        if c == 0 then
            self.__a = 0
        end
        self._a = self._a + (-self._a + self.__a) * 0.05
        self.index = self.index - self.index * 0.1
    end,
    render = function(self)
        local c = int(lstg.var.shield_count)
        local n = 13 + setting.rdQual
        local kr1 = 0
        local kr2 = 0
        local dr1 = 5
        local dr2 = 2
        local R, G, B = sp:HSVtoRGB(c / 3 * 360, 1, 0.6)
        local _color = Color(self.alpha * self._a, R, G, B)
        local _uv1, _uv2, _uv3, _uv4 = { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }
        local cx, cy = self.x, self.y
        local px, py = player.x, player.y
        _uv1[6] = _color
        _uv2[6] = _color
        _uv3[6] = _color
        _uv4[6] = _color
        for i = 1, 15 do
            dr2 = (3 + c * 0.5) * (1 - i / 15) + self.index
            --_color = Color(255 - 100 * (1 - i / 42) * m, 255, 255, 255)
            for r = 1, n do
                local da = 360 / n
                local ang = r * da
                local offa = 0
                local offx, offy = 0, 0
                _uv1[1], _uv1[2] = px + offx + cos(ang + offa) * kr2, py + offy + sin(ang + offa) * kr2
                _uv2[1], _uv2[2] = px + offx + cos(ang + offa) * (kr2 + dr2), py + offy + sin(ang + offa) * (kr2 + dr2)
                _uv3[1], _uv3[2] = px + offx + cos(ang + da + offa) * (kr2 + dr2), py + offy + sin(ang + da + offa) * (kr2 + dr2)
                _uv4[1], _uv4[2] = px + offx + cos(ang + da + offa) * kr2, py + offy + sin(ang + da + offa) * kr2

                _uv1[4], _uv1[5] = cx + offx + cos(ang) * kr1, cy + offy + sin(ang) * kr1
                _uv2[4], _uv2[5] = cx + offx + cos(ang) * (kr1 + dr1), cy + offy + sin(ang) * (kr1 + dr1)
                _uv3[4], _uv3[5] = cx + offx + cos(ang + da) * (kr1 + dr1), cy + offy + sin(ang + da) * (kr1 + dr1)
                _uv4[4], _uv4[5] = cx + offx + cos(ang + da) * kr1, cy + offy + sin(ang + da) * kr1
                _uv1[4], _uv1[5] = WorldToScreen(_uv1[4], _uv1[5])
                _uv2[4], _uv2[5] = WorldToScreen(_uv2[4], _uv2[5])
                _uv3[4], _uv3[5] = WorldToScreen(_uv3[4], _uv3[5])
                _uv4[4], _uv4[5] = WorldToScreen(_uv4[4], _uv4[5])
                RenderTexture("level_obj_shield", "add+add", _uv1, _uv2, _uv3, _uv4)
            end
            kr1 = kr1 + dr1
            kr2 = kr2 + dr2
        end

        SetImageState("white", "mul+add", self.alpha * self._a * 0.1, 255, 255, 255)
        for _ = 1, c do
            misc.SectorRender(px, py, kr2 - 2, kr2, 0, 360, 18 + setting.rdQual)
            kr2 = kr2 + 3
        end

        SetImageState("white", "mul+add", self.alpha * self._a * 0.35, R, G, B)
        misc.SectorRender(px, py, 0, kr2 * self.index, 0, 360, 15 + setting.rdQual)
        SetImageState("menu_bright_circle", "mul+add", self.alpha * self._a * 0.2, R, G, B)
        Render("menu_bright_circle", px, py, 0, (kr2 - 2) / 125)
    end
}, true)
class2.kappa_shield = kappa_shield

local MAX_PROTECT_LOTUS = 90
class2.MAX_PROTECT_LOTUS = MAX_PROTECT_LOTUS
local function add_protect_lotus_c(c)
    local var = lstg.var
    var.lotus_record_b = min(var.lotus_record_b + c, MAX_PROTECT_LOTUS)
    if var.lotus_record_b == MAX_PROTECT_LOTUS and not var.lotus_open then
        var.lotus_open = true
        var.lotus_record_b = 0
    end
end
class2.add_protect_lotus_c = add_protect_lotus_c

local protect_lotus = Class(object, {
    init = function(self)
        self.layer = LAYER.PLAYER - 2
        self.colli = true
        self.killflag = true
        self.group = GROUP.PLAYER
        self.bound = false
        self.index = 0
        self._index = 0
        self.r = 64
        self.open = false
        self.img = "level_obj_protect_lotus"
        self.bound = false
    end,
    frame = function(self)
        task.Do(self)
        self.x, self.y = player.x, player.y
        self.index = self.index + (-self.index + self._index) * 0.1
        self.a = self.index * self.r
        self.b = self.a
        local var = lstg.var
        if var.lotus_open then
            self._index = 1
            if not self.open then
                player.protect = max(player.protect, 60)
                task.New(self, function()
                    task.Wait(60)
                    if var.lotus_record_b == MAX_PROTECT_LOTUS then
                        self.open = false
                        var.lotus_record_b = 0
                        self._index = 0
                    else
                        var.lotus_open = false
                    end
                end)
                PlaySound("lotus")
                self.open = true
                self.colli = true
                NewWave(self.x, self.y, 2, 100, 60, 255, 227, 132)
            end
        else
            self._index = 0
            self.colli = false
            self.open = false
        end
        if self.colli then
            cutLasersByCircle(self.x, self.y, self.a)
        end
    end,
    colli = function(self, other)
        if other.group == GROUP.ENEMY_BULLET then
            object.Del(other)
        end
    end,
    render = function(self)
        local px, py = self.x, self.y
        local size = self.index * self.r
        SetImageState(self.img, "mul+add", self.index * 200, 255, 255, 255)
        Render(self.img, px, py, 180 + 180 * self.index, (self.r) * (2 - self.index) / 256)
        SetImageState(self.img, "mul+add", 125, 255, 255, 255)
        Render(self.img, px, py, 180 - 180 * self.index, size / 256)
        SetImageState("circle_charge", "mul+add", 150, 255, 160, 100)
        Render("circle_charge", px, py, 0, size / 256)
    end
}, true)
class2.protect_lotus = protect_lotus

local reflex_arc_eff = Class(object, {
    init = function(self)
        self.x, self.y = player.x, player.y
        self.layer = LAYER.ENEMY + 1
        self.group = GROUP.GHOST
        self.colli = false
        self.lifetime = 120
        self.alpha = 0
        self._r, self._g, self._b = 250, 128, 114
        self.particle = {}
        self.R = 120
        self.bound = false
        task.New(self, function()
            local j = 0
            for i = 1, 120 do
                j = j + 1
                if j >= 1 then
                    local a = ran:Float(0, 360)
                    table.insert(self.particle, {
                        x = cos(a) * self.R, y = sin(a) * self.R,
                        vx = cos(a + 180) * self.R / 20, vy = sin(a + 180) * self.R / 20,
                        alpha = 0,
                        malpha = ran:Float(150, 250), timer = 0,
                    })
                    j = j - 1
                end
                self.alpha = task.SetMode[2](i / 120)
                self.R = 120 - i
                task.Wait()
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        self.x, self.y = player.x, player.y
        local p
        local maxtime = max(10, self.lifetime - 20)
        for i = #self.particle, 1, -1 do
            p = self.particle[i]
            p.x = p.x + p.vx
            p.y = p.y + p.vy
            p.vx = p.vx - p.vx * 0.04
            p.vy = p.vy - p.vy * 0.04
            if p.timer < 10 then
                p.alpha = p.timer * p.malpha / 10
            elseif p.timer > maxtime then
                p.alpha = max(p.alpha - 5, 0)
                if p.alpha == 0 then
                    table.remove(self.particle, i)
                end
            end
            p.timer = p.timer + 1
        end
        if self.timer >= self.lifetime and #self.particle == 0 then
            object.Del(self)
        end
    end,
    render = function(self)
        for _, p in ipairs(self.particle) do
            SetImageState("bright", "mul+add", p.alpha, self._r, self._g, self._b)
            Render("bright", self.x + p.x, self.y + p.y, 0, 8 / 150)
        end
        if self.alpha > 0 then
            SetImageState("circle_charge", "mul+add", self.alpha * 255, self._r, self._g, self._b)
            Render("circle_charge", self.x, self.y, 0, self.R / 256)
        end
    end
}, true)
class2.reflex_arc_eff = reflex_arc_eff

local life_dead_eff = Class(object, {
    init = function(self)
        self.x, self.y = player.x, player.y
        self.layer = LAYER.ENEMY + 1
        self.group = GROUP.GHOST
        self.colli = false
        self.lifetime = 99
        self.alpha = 0
        self._r, self._g, self._b = 218, 112, 214
        self.particle = {}
        self.R = 100
        self.bound = false
        local j = 0
        for _ = 1, 60 do
            j = j + setting.rdQual / 5
            if j >= 1 then
                local a = ran:Float(0, 360)
                local v = ran:Float(5, 9)
                table.insert(self.particle, {
                    x = self.x, y = self.y,
                    vx = cos(a) * v, vy = sin(a) * v,
                    alpha = 0,
                    malpha = ran:Float(150, 250), timer = 0,
                })
                j = j - 1
            end
        end
        task.New(self, function()
            for i = 1, 45 do
                self.alpha = 1 - task.SetMode[2](i / 45)
                self.R = i * 6
                task.Wait()
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        local p
        local maxtime = max(10, self.lifetime - 20)
        for i = #self.particle, 1, -1 do
            p = self.particle[i]
            p.x = p.x + p.vx
            p.y = p.y + p.vy
            p.vx = p.vx - p.vx * 0.04
            p.vy = p.vy - p.vy * 0.04
            if p.timer < 10 then
                p.alpha = p.timer * p.malpha / 10
            elseif p.timer > maxtime then
                p.alpha = max(p.alpha - 5, 0)
                if p.alpha == 0 then
                    table.remove(self.particle, i)
                end
            end
            p.timer = p.timer + 1
        end
        if self.timer >= self.lifetime and #self.particle == 0 then
            object.Del(self)
        end
    end,
    render = function(self)
        for _, p in ipairs(self.particle) do
            SetImageState("bright", "mul+add", p.alpha, self._r, self._g, self._b)
            Render("bright", p.x, p.y, 0, 8 / 150)
        end
        if self.alpha > 0 then
            SetImageState("circle_charge", "mul+add", self.alpha * 255, self._r, self._g, self._b)
            Render("circle_charge", self.x, self.y, 0, self.R / 256)
        end
    end
}, true)
class2.life_dead_eff = life_dead_eff

local fake_and_real_eff = Class(object, {
    init = function(self, target)
        self.target = target
        self.x, self.y = target.x, target.y
        self.layer = LAYER.ENEMY + 1
        self.group = GROUP.GHOST
        self.colli = false
        self.lifetime = 99
        self.alpha = 0
        self._r, self._g, self._b = 250, 250, 250
        self.particle = {}
        self.R = 100
        self.bound = false
        task.New(self, function()
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                self.alpha = i
                self.R = 50 * (1 - i)

                task.Wait()
            end
            Del(self)
        end)
    end,
    frame = function(self)
        task.Do(self)
        if IsValid(self.target) then
            self.x, self.y = self.target.x, self.target.y
        else
            Del(self)
        end
    end,
    render = function(self)
        if self.alpha > 0 then
            SetImageState("circle_charge", "mul+add", self.alpha * 255, self._r, self._g, self._b)
            Render("circle_charge", self.x, self.y, 0, self.R / 256)
        end
    end
}, true)
class2.fake_and_real_eff = fake_and_real_eff

local black_fog_circle_eff = Class(object, {
    init = function(unit, w, ir, sr, time, alpha)
        unit.x, unit.y = player.x, player.y
        unit.layer = 1
        unit.group = GROUP.GHOST
        unit.w = w
        unit.sr = sr
        unit.time = time
        unit.ir = ir
        unit.nr = ir
        unit.smear = {}
        unit.malpha = alpha
        unit.alpha = alpha
        unit.colli = false
    end,
    frame = function(unit)
        unit.x, unit.y = player.x, player.y
        unit.lr = unit.nr
        unit.alpha = max(0, unit.malpha * (1 - unit.timer / unit.time))
        unit.nr = unit.ir + task.SetMode[2](unit.timer / unit.time) * (unit.sr - unit.ir)
        if unit.timer > unit.time then
            if #unit.smear == 0 then
                Del(unit)
            end
        else
            table.insert(unit.smear, { alpha = unit.alpha / 2, r = unit.nr, w = (unit.nr - unit.lr) })
        end
        local s
        for i = #unit.smear, 1, -1 do
            s = unit.smear[i]
            s.alpha = max(s.alpha - 15, 0)
            if s.alpha == 0 then
                table.remove(unit.smear, i)
            end
        end
    end,
    render = function(unit)
        SetImageState("white", "", unit.alpha, 0, 0, 0)
        misc.SectorRender(unit.x, unit.y, unit.nr - unit.w / 2, unit.nr + unit.w / 2,
                0, 360, int(clamp(unit.nr / 4, 20, 80)))
        for _, s in ipairs(unit.smear) do
            SetImageState("white", "", s.alpha, 0, 0, 0)
            misc.SectorRender(unit.x, unit.y, s.r - s.w, s.r, 0, 360,
                    int(clamp(s.r / 4, 20, 80)))
        end
    end
}, true)

local black_fog_circle = Class(object, {
    init = function(self)
        self.x, self.y = player.x, player.y
        self.layer = LAYER.ENEMY + 1
        self.group = GROUP.GHOST
        self.colli = false
        self.alpha = 0
        self.R = 90
        self.bound = false
        task.New(self, function()
            for i = 1, 15 do
                self.alpha = i / 15
                task.Wait()
            end
            while true do
                if IsValid(lstg.tmpvar.god_circle) then
                    New(black_fog_circle_eff, 2, self.R, self.R * 2, 45, 145)
                end
                task.Wait(60)
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        self.x, self.y = player.x, player.y
    end,
    render = function(self)
        if self.alpha > 0 then
            SetImageState("circle_charge", "", self.alpha * 145, 0, 0, 0)
            Render("circle_charge", self.x, self.y, 0, self.R / 256)
        end
    end
}, true)
class2.black_fog_circle = black_fog_circle
return class2