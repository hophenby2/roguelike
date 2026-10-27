local class = weather_lib.class

local DaHanEff = Class(object, {
    init = function(self)
        self.bubble = {}
        self.group = GROUP.GHOST
        self.layer = 0
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
        self.back_alpha = (0.15 + 0.1 * sin(self.timer)) * self.alpha
        if lstg.weather.DaHan then
            if self.timer % (6 + 5 - setting.rdQual) == 0 then
                table.insert(self.bubble, {
                    x = ran:Float(-320, 320), y = ran:Float(-240, 240),
                    vx = 0, vy = ran:Float(-2, -1),
                    size = ran:Float(0.3, 0.6),
                    timer = 0, lifetime = ran:Int(40, 70),
                    rot = ran:Float(0, 360), omega = ran:Float(1, 2) * ran:Sign(),
                    alpha = 0, maxalpha = 25,
                    imgid = ran:Int(1, 19),
                })
            end

        else
            self.alpha = max(self.alpha - 1 / 30, 0)
            if self.alpha == 0 and #self.bubble == 0 then
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
        misc.RenderBrightOutline(-320, 320, -240, 240, 200,
                self.back_alpha * 255, 135, 206, 235, "mul+add")
        for _, p in ipairs(self.bubble) do
            local img = "level_obj_snow" .. p.imgid
            SetImageState(img, "mul+add", p.alpha, 255, 255, 255)
            Render(img, p.x, p.y, p.rot, p.size)
        end
    end
}, true)
class.DaHanEff = DaHanEff

local ChunXueEff = Class(object, {
    init = function(self)
        self.bubble = {}
        self.group = GROUP.GHOST
        self.layer = 0
    end,
    frame = function(self)
        task.Do(self)
        if lstg.weather.ChunXue then
            if self.timer % (6 + 5 - setting.rdQual) == 0 then
                table.insert(self.bubble, {
                    x = ran:Float(-320, 320), y = ran:Float(-240, 240),
                    vx = 0, vy = ran:Float(1, 2),
                    size = ran:Float(0.3, 0.6),
                    timer = 0, lifetime = ran:Int(40, 70),
                    rot = ran:Float(0, 360), omega = ran:Float(1, 2) * ran:Sign(),
                    alpha = 0, maxalpha = 45,
                    imgid = ran:Int(1, 19),
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
        for _, p in ipairs(self.bubble) do
            local img = "level_obj_snow" .. p.imgid
            SetImageState(img, "mul+add", p.alpha, 218, 112, 214)
            Render(img, p.x, p.y, p.rot, p.size)
        end
    end
}, true)
class.ChunXueEff = ChunXueEff

local BaoFengXueEff = Class(object, {
    init = function(self)
        self.bubble = {}
        self.group = GROUP.GHOST
        self.layer = 100
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
        self.back_alpha = (0.15 + 0.1 * sin(self.timer)) * self.alpha
        if lstg.weather.BaoFengXue then
            local bY = -260
            if IsValid(lstg.tmpvar.SUN) then
                bY = -180
            end
            for _ = 1, 2 do
                table.insert(self.bubble, {
                    x = 400, y = ran:Float(bY, 260),
                    vx = ran:Float(-10, -12), vy = ran:Float(-2, 2),
                    size = ran:Float(1, 2),
                    timer = 0, lifetime = ran:Int(80, 130),
                    alpha = 100, maxalpha = 170,
                })
            end
        else
            self.alpha = max(self.alpha - 1 / 30, 0)
            if #self.bubble == 0 and self.alpha == 0 then
                Del(self)
            end
        end
        local b
        for i = #self.bubble, 1, -1 do
            b = self.bubble[i]
            b.x = b.x + b.vx
            b.y = b.y + b.vy
            if b.timer <= 10 then
                b.alpha = min(b.maxalpha, b.alpha + b.maxalpha / 10)
            elseif b.lifetime - b.timer <= 20 then
                b.alpha = max(0, b.alpha - b.maxalpha / 20)
            end
            if b.timer == b.lifetime or b.x < -400 then
                table.remove(self.bubble, i)
            end
            b.timer = b.timer + 1
        end
    end,
    render = function(self)
        for _, p in ipairs(self.bubble) do
            local img = "bright"

            local A = min(1, Dist(p.x, p.y, player) / (170 * p.size))
            A = A * A * A

            SetImageState(img, "", p.alpha * A, 175, 185, 200)
            Render(img, p.x, p.y, p.rot, p.size)
        end
    end
}, true)
class.BaoFengXueEff = BaoFengXueEff

local JieHanEff = Class(object, {
    init = function(self)
        self.group = GROUP.GHOST
        self.layer = 0
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
        self.back_alpha = (0.15 + 0.1 * sin(self.timer)) * self.alpha
        if lstg.weather.JieHan then

        else
            self.alpha = max(self.alpha - 1 / 30, 0)
            if self.alpha == 0 then
                Del(self)
            end
        end
    end,
    render = function(self)
        misc.RenderBrightOutline(-320, 320, -240, 240, 200,
                self.back_alpha * 255, 100, 100, 235, "mul+add")
    end
}, true)
class.JieHanEff = JieHanEff

local HuaYunEff = Class(object, {
    init = function(self)
        self.group = GROUP.GHOST
        self.layer = 0
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
        self.back_alpha = (0.25 + 0.1 * sin(self.timer)) * self.alpha
        if lstg.weather.HuaYun then

        else
            self.alpha = max(self.alpha - 1 / 30, 0)
            if self.alpha == 0 then
                Del(self)
            end
        end
    end,
    render = function(self)
        misc.RenderBrightOutline(-320, 320, -240, 240, 200,
                self.back_alpha * 255, 100, 50, 100, "mul+add")
    end
}, true)
class.HuaYunEff = HuaYunEff

LoadTexture("ice_block", "assets\\weather\\ice_block.png")
LoadImageGroup("ice_block", "ice_block", 0, 0, 64, 64, 4, 1, 32, 32)
LoadImageGroup("ice_block_ef", "ice_block", 0, 64, 64, 64, 4, 1, 0, 0)
local ice = Class(object, {
    init = function(self, x, y, time, lock_player)
        self.group = GROUP.INDES
        self.layer = LAYER.ENEMY_BULLET - 1
        self.rot = ran:Float(0, 360)
        self.t = ran:Int(1, 4)
        self.img = "ice_block_ef" .. self.t
        self._a = 0
        self.colli = false
        self.colli2 = false
        self.scale = ran:Float(0.5, 0.8)
        self.hscale = self.scale + 0.5
        self.vscale = self.hscale
        self.x, self.y = x, y
        if time <= 0 then
            object.RawDel(self)
            self.time = time
        else
            self.time = time
        end
        self.lock_player = lock_player
        self.playerice = lock_player
        if self.lock_player then
            player.ice_frozen = true
            _object.set_color(player, "", 255, 135, 206, 235)
        end
        PlaySound("ice", 0.2)
        task.New(self, function()
            for i = 0, 10 do
                i = task.SetMode[4](i / 10)
                self._a = i * 180
                self.hscale = self. scale + 0.5 - 0.5 * i
                self.vscale = self.hscale
                task.Wait()
            end
            self.colli2 = true
            self.img = "ice_block" .. self.t
            self.a, self.b = 0, 0
            task.Wait(self.time)
            object.Del(self)
        end)
        task.New(self, function()
            task.Wait(self.time)
            object.Del(self)
        end)
        task.New(self, function()
            task.Wait(3)
            self.colli2 = true
        end)
    end,
    del = function(self)
        if not self.dk then
            self.dk = true
            self.colli2 = false
            object.Preserve(self)
            if not self.playerice then
                for _ = 1, ran:Int(0, 1) do
                    NewSimpleBullet(ball_small, 8, self.x, self.y, 1.5, ran:Float(0, 360))
                end
                if ran:Float(0, 1) < 0.3 then
                    DropExpPoint(1, self.x, self.y)
                end
            end
            task.New(self, function()
                if self.lock_player then
                    player.ice_frozen = nil
                    _object.set_color(player)
                end
                for i = 10, 0, -1 do
                    i = task.SetMode[4](i / 10)
                    self._a = i * 180
                    self.hscale = self.scale + 0.5 - 0.5 * i
                    self.vscale = self.hscale
                    task.Wait()
                end
                object.RawDel(self)
            end)

        end
    end,
    kill = function(self)
        self.class.del(self)
    end,
    frame = function(self)
        task.Do(self)
        if self.colli2 and player.name ~= "Chiruno" then
            if not self.playerice and not player.ice_frozen and Dist(self, player) < 20 then
                self.time = self.time - 1
                self.playerice = true
                New(class.ice, player.x, player.y, self.time, true)
            end
        end
    end,
    render = function(self)
        SetImgState(self, "mul+add", self._a, 255, 255, 255)
        DefaultRenderFunc(self)
    end
}, true)
class.ice = ice

local ShuangHuaEff = Class(object, {
    init = function(self)
        self.bubble = {}
        self.group = GROUP.GHOST
        self.layer = 0
    end,
    frame = function(self)
        task.Do(self)
        if lstg.weather.ShuangHua then
            if self.timer % (6 + 5 - setting.rdQual) == 0 then
                table.insert(self.bubble, {
                    x = ran:Float(-320, 320), y = ran:Float(-240, 240),
                    vx = 0, vy = -ran:Float(0.5, 1),
                    size = ran:Float(0.3, 0.6),
                    timer = 0, lifetime = ran:Int(40, 70),
                    rot = ran:Float(0, 360), omega = ran:Float(1, 2) * ran:Sign(),
                    alpha = 0, maxalpha = 45,
                    imgid = ran:Int(1, 19),
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
        for _, p in ipairs(self.bubble) do
            local img = "level_obj_snow" .. p.imgid
            SetImageState(img, "mul+add", p.alpha, 255, 255, 255)
            Render(img, p.x, p.y, p.rot, p.size)
        end
    end
}, true)
class.ShuangHuaEff = ShuangHuaEff

local BingYunEff = Class(object, {
    init = function(self)
        self.group = GROUP.GHOST
        self.layer = LAYER.BG + 6
        self.particle = {}
        self.particle2 = {}
    end,
    frame = function(self)
        task.Do(self)
        if lstg.weather.BingYun then
            if self.timer % (3 + 5 - setting.rdQual) == 0 then
                local va = ran:Float(0, 360)
                local v = 0.4

                table.insert(self.particle, {
                    alpha = 0, maxalpha = 50,
                    size = ran:Float(250, 352),
                    x = ran:Float(-320, 320), y = ran:Float(-240, 240),
                    vx = cos(va) * v, vy = sin(va) * v,
                    timer = 0, lifetime = ran:Int(120, 180),
                })
                table.insert(self.particle2, {
                    alpha = 0, maxalpha = 255,
                    size = ran:Float(1, 2) * ran:Int(1, 2),
                    x = ran:Float(-320, 320), y = ran:Float(-240, 240),
                    v = v, rotate = ran:Float(0, 360), o = ran:Float(1, 2) * ran:Sign(),
                    timer = 0, lifetime = ran:Int(75, 120),
                })
            end

        else
            if #self.particle == 0 and #self.particle2 == 0 then
                Del(self)
            end
        end
        local p
        for i = #self.particle, 1, -1 do
            p = self.particle[i]

            p.x = p.x + p.vx
            p.y = p.y + p.vy

            p.timer = p.timer + 1
            if p.timer <= 30 then
                p.alpha = min(p.maxalpha, p.alpha + p.maxalpha / 30)
            elseif p.timer > p.lifetime - 30 then
                p.alpha = max(p.alpha - p.maxalpha / 30, 0)
                if p.alpha == 0 then
                    table.remove(self.particle, i)
                end
            end

        end
        for i = #self.particle2, 1, -1 do
            p = self.particle2[i]
            p.rotate = p.rotate + p.o
            local vx = p.v * cos(p.rotate)
            local vy = p.v * sin(p.rotate)
            p.x = p.x + vx
            p.y = p.y + vy

            p.timer = p.timer + 1
            if p.timer <= 10 then
                p.alpha = min(p.maxalpha, p.alpha + p.maxalpha / 10)
            elseif p.timer > p.lifetime - 10 then
                p.alpha = max(p.alpha - p.maxalpha / 10, 0)
                if p.alpha == 0 then
                    table.remove(self.particle2, i)
                end
            end

        end
    end,
    render = function(self)
        local R, G, B = 85, 65, 45
        for _, p in ipairs(self.particle) do
            SetImageState("bright", "mul+rev", p.alpha, R, G, B)
            Render("bright", p.x, p.y, 0, p.size / 130)
        end
        for _, p in ipairs(self.particle2) do
            SetImageState("bright", "mul+add", p.alpha, 135, 206, 235)
            Render("bright", p.x, p.y, 0, p.size / 130)
        end
    end
}, true)
class.BingYunEff = BingYunEff

local LiuXingYuEff = Class(object, {
    init = function(self)
        self.group = GROUP.GHOST
        self.layer = LAYER.BG + 6
        self.particle = {}
        self.particle2 = {}
    end,
    frame = function(self)
        task.Do(self)
        if lstg.weather.LiuXingYu then
            if self.timer % (3 + 5 - setting.rdQual) == 0 then
                local va = -40
                local v = ran:Float(4, 8) + abs(sin(self.timer)) * 4
                table.insert(self.particle2, {
                    alpha = 0, maxalpha = 255,
                    size = ran:Float(4, 8),
                    x = ran:Float(-500, 300), y = 260,
                    vx = cos(va) * v, vy = sin(va) * v,
                    ag = v / 100,
                    timer = 0, lifetime = ran:Int(120, 180),
                })
            end

        else
            if #self.particle == 0 and #self.particle2 == 0 then
                Del(self)
            end
        end
        local p
        for i = #self.particle, 1, -1 do
            p = self.particle[i]

            p.x = p.x + p.vx
            p.y = p.y + p.vy

            p.timer = p.timer + 1
            if p.timer <= 30 then
                p.alpha = min(p.maxalpha, p.alpha + p.maxalpha / 30)
            elseif p.timer > p.lifetime - 30 then
                p.alpha = max(p.alpha - p.maxalpha / 30, 0)
                if p.alpha == 0 then
                    table.remove(self.particle, i)
                end
            end

        end
        for i = #self.particle2, 1, -1 do
            p = self.particle2[i]
            if not p.issmear then
                local inc = 1 + 2 * (1 - setting.rdQual / 5)
                local dx, dy = p.vx, p.vy
                local d = hypot(dx, dy)
                local count = int(d / inc)
                local ix = inc * (dx / d)
                local iy = inc * (dy / d)
                for c = 0, count do
                    table.insert(self.particle2, {
                        alpha = 30, maxalpha = 30,
                        size = p.size,
                        x = p.x - c * ix,
                        y = p.y - c * iy,
                        vx = 0, vy = 0, ag = 0,
                        timer = 0, lifetime = 15,
                        issmear = true
                    })
                end
            end
            p.vy = p.vy - p.ag
            p.x = p.x + p.vx
            p.y = p.y + p.vy

            p.timer = p.timer + 1
            if p.timer <= 10 then
                p.alpha = min(p.maxalpha, p.alpha + p.maxalpha / 10)
            elseif p.timer > p.lifetime - 10 then
                p.alpha = max(p.alpha - p.maxalpha / 10, 0)
                if p.alpha == 0 then
                    table.remove(self.particle2, i)
                end
            end

        end
    end,
    render = function(self)
        local R, G, B = 85, 65, 45
        for _, p in ipairs(self.particle) do

        end
        for _, p in ipairs(self.particle2) do
            if not p.issmear then
                SetImageState("bright", "mul+rev", p.alpha * 0.3, R, G, B)
                Render("bright", p.x, p.y, 0, p.size / 2)
            end
            SetImageState("bright", "mul+add", p.alpha, 135, 206, 235)
            Render("bright", p.x, p.y, 0, p.size / 130)
        end
    end
}, true)
class.LiuXingYuEff = LiuXingYuEff



