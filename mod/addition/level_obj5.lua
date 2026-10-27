local path = "assets\\addition_unit\\"

LoadAniFromFile("level_obj_siyuan_baby6", path .. "siyuan_baby6.png", true, 6, 3, 3)

LoadAniFromFile("level_obj_bun_cat1", path .. "bun_cat1.png", true, 6, 10, 1)
LoadAniFromFile("level_obj_bun_cat2", path .. "bun_cat2.png", true, 6, 10, 1)
LoadAniFromFile("level_obj_bun_cat3", path .. "bun_cat3.png", true, 6, 10, 1)
LoadAniFromFile("level_obj_bun_cat4", path .. "bun_cat4.png", true, 6, 10, 1)
LoadAniFromFile("level_obj_bun_cat4", path .. "bun_cat4.png", true, 6, 10, 1)

---@class level_obj5
local class5 = {}

local rotate_cat = Class(object, {
    init = function(self, k)
        self.img = "level_obj_siyuan_baby6"
        self.A, self.B = 5, 5
        self.bound = false
        self.group = GROUP.PLAYER_BULLET
        self.layer = LAYER.PLAYER_BULLET
        self.killflag = true
        self.bound = false
        self._blend = ""
        self._a = 0
        self._r, self._g, self._b = 200, 200, 200
        self.x, self.y = ran:Float(-280, 280), ran:Float(0, 180)
        local d = (k % 2) * 2 - 1
        self.vx = d * 3
        self.vy = ran:Sign() * 2
        self.a, self.b = 20, 20
        self.hscale, self.vscale = 0.6, 0.6
        task.New(self, function()
            for i = 1, 25 do
                self._a = 255 * i / 25
                task.Wait()
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        self.dmg = player.damage * 0.12
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
    end,
    render = function(self)
        SetImageState("bright", "", self._a * 0.6, 255, 255, 255)
        Render("bright", self.x, self.y, 0, 35 / 130)
        SetAnimationState(self.img, self._blend, self._a, self._r, self._g, self._b)
        DefaultRenderFunc(self)
    end,
    kill = function(self)
        enemy.death_ef(self.x, self.y, 10, 1)
    end,
    del = function(self)
        self.class.kill(self)
    end
}, true)
class5.rotate_cat = rotate_cat

local bun_cat_stack = {}
local bun_cat = Class(object, {
    init = function(self, imgid)
        self.id = imgid
        self.img = "level_obj_bun_cat" .. self.id
        self.bound = false
        self.group = GROUP.PLAYER_BULLET
        self.layer = LAYER.PLAYER_BULLET
        self.killflag = true
        self.bound = false
        self._blend = ""
        self._a = 0
        self._r, self._g, self._b = 255, 255, 255
        self.a, self.b = 10, 10
        self.hscale, self.vscale = 0.5, 0.5
        table.insert(bun_cat_stack, self)
        task.New(self, function()
            local p = player
            while true do
                while true do
                    self.x = self.x + (-self.x + self._x) * self._index
                    self.y = self.y + (-self.y + self._y) * self._index
                    if Dist(self, self._x, self._y) < 10 and p.__shoot_flag and p.nextshoot <= 0 then
                        if self.pos - 1 >= 1 and IsValid(bun_cat_stack[self.pos - 1]) then
                            if bun_cat_stack[self.pos - 1].jump then
                                player_class.findtarget(self)
                                if IsValid(self.target) then
                                    break
                                end
                            end
                        else
                            player_class.findtarget(self)
                            if IsValid(self.target) then
                                break
                            end
                        end
                    end
                    task.Wait()
                end
                self.jump = false
                if IsValid(self.target) then
                    object.SetV(self, 15, Angle(self, self.target))
                    self.shoot_out = true
                end
                while self.shoot_out do
                    task.Wait()
                end
                self.jump = true
                task.Wait()

            end
        end)
        task.New(self, function()

            for i = 1, 25 do
                self._a = 255 * i / 25
                task.Wait()
            end
        end)
    end,
    frame = function(self)
        sp:UnitListUpdate(bun_cat_stack)
        for i, b in ipairs(bun_cat_stack) do
            if b == self then
                self.pos = i
            end
        end
        local p = player
        local R = 45
        local t = self.pos * 90 + self.timer * 3
        self._x, self._y = p.x + cos(t) * R, p.y + sin(t) * R
        self._index = clamp(20 / Dist(self, self._x, self._y), 0.00001, 1)

        if self.timer == 1 then
            self.x = self._x
            self.y = self._y
        end
        self.dmg = player.damage * 0.42
        task.Do(self)
        if self.shoot_out then
            self.vx = self.vx - self.vx * 0.018
            self.vy = self.vy - self.vy * 0.018
            if abs(self.vx) < 0.1 or abs(self.vy) < 0.1 then
                self.shoot_out = false
            end
            local w = lstg.world
            if self.y > w.t then
                self.shoot_out = false
            end
            if self.y < w.b then
                self.shoot_out = false
            end
            if self.x > w.r then
                self.shoot_out = false
            end
            if self.x < w.l then
                self.shoot_out = false
            end
        end
    end,
    render = function(self)
        SetImageState("bright", "", self._a * 0.6, 255, 255, 255)
        Render("bright", self.x, self.y, 0, 35 / 130)
        SetAnimationState(self.img, self._blend, self._a, self._r, self._g, self._b)
        DefaultRenderFunc(self)
    end,
    kill = function(self)
        enemy.death_ef(self.x, self.y, 10, 1)
    end,
    del = function(self)
        self.class.kill(self)
    end
}, true)
class5.bun_cat = bun_cat

local dream_in = Class(object, {
    init = function(self, x, y)
        self.x, self.y = x, y
        self.layer = LAYER.PLAYER + 1
        self.group = GROUP.GHOST
        self.colli = false
        self.r = 25
        self.alpha = 0
        self._r, self._g, self._b = 200, 200, 200
        self.particle = {}
        self.bound = false
        for _ = 1, 15 + setting.rdQual * 3 do
            local a = ran:Float(0, 360)
            local v = ran:Float(0.3, 4)
            table.insert(self.particle, {
                x = self.x, y = self.y,
                vx = cos(a) * v, vy = sin(a) * v,
                rot = ran:Float(0, 360),
                omega = ran:Float(1.5, 3) * ran:Sign(),
                alpha = ran:Float(150, 250), timer = 0,
            })
        end
        task.New(self, function()
            task.SmoothSetValueTo("alpha", 1, 25, 0)
        end)
        task.New(self, function()
            while not self.del_flag do
                task.Wait()
            end
            task.SmoothSetValueTo("alpha", 0, 25, 0)
        end)
    end,
    frame = function(self)
        task.Do(self)
        local AY = 0.05
        local p
        if not self.del_flag then
            if self.timer % (6 - setting.rdQual) == 0 then
                local a = ran:Float(0, 360)
                local v = ran:Float(0.3, 4)
                table.insert(self.particle, {
                    x = self.x, y = self.y,
                    vx = cos(a) * v, vy = sin(a) * v,
                    rot = ran:Float(0, 360),
                    omega = ran:Float(0.5, 1.5) * ran:Sign(),
                    alpha = ran:Float(150, 250), timer = 0,
                })
            end
        else
            self._g = self._g - self._g * 0.1
            self._b = self._b - self._b * 0.1
            AY = -0.05
        end
        for i = #self.particle, 1, -1 do
            p = self.particle[i]
            p.x = p.x + p.vx
            p.y = p.y + p.vy
            p.vy = p.vy + AY
            p.vx = p.vx - p.vx * 0.04
            p.vy = p.vy - p.vy * 0.04
            p.rot = p.rot + p.omega
            if p.timer > 40 then
                p.alpha = max(p.alpha - 5, 0)
                if p.alpha == 0 then
                    table.remove(self.particle, i)
                end
            end
            p.timer = p.timer + 1
        end
        if #self.particle == 0 then
            object.Del(self)
        end
    end,
    render = function(self)

        for _, p in ipairs(self.particle) do
            RenderTTF3("pretty_title", "z", p.x, p.y, p.rot, 0.3, 0.3,
                    "mul+add", Color(p.alpha, self._r, self._g, self._b), "centerpoint")
        end
        if self.alpha > 0 then
            SetImageState("bright", "", self.alpha * 255, self._r, self._g, self._b)
            Render("bright", self.x, self.y, 0, self.r / 75)
        end
    end
})
class5.dream_in = dream_in

local gunpowder = Class(object, {
    render = function(self)
        SetImageState(self.img, "mul+add", 12, 255, 100, 100)
        DefaultRenderFunc(self)

    end,
    frame = task.Do,
    init = function(self, x, y, dmg, r)
        self.group = GROUP.PLAYER_BULLET
        self.killflag = true
        self.layer = LAYER.PLAYER_BULLET
        self.dmg = dmg
        self.x, self.y = x, y
        self.img = "boom"
        self.hscale, self.vscale = 0, 0
        self.omega = 7 * ran:Sign()
        self.colli = false

        NewBon(x, y, 30, 0, 255, 120, 132, 2)
        --NewWave(x, y, 1, r , 30, 255, 227, 132)
        task.New(self, function()
            for i = 1, 10 do
                local _r = r * task.SetMode[2](i / 10)
                self.a = _r
                self.b = _r
                self.hscale = _r / 60
                self.vscale = self.hscale
                task.Wait()
            end
            self.colli = true
            task.Wait(20)
            self.colli = false
            for i = 1, 10 do
                local _r = r * (1 - task.SetMode[2](i / 10))
                self.a = _r
                self.b = _r
                self.hscale = _r / 60
                self.vscale = self.hscale
                task.Wait()
            end
            Del(self)
        end)
    end
}, true)
class5.gunpowder = gunpowder

local feel_sick = Class(object, {
    init = function(self, time)
        self.layer = LAYER.PLAYER
        self.group = GROUP.GHOST
        self.colli = false
        self.r = 25
        self.alpha = 0
        self._r, self._g, self._b = 189, 252, 150
        self.particle = {}
        self.bound = false
        self.x, self.y = player.x, player.y
        for _ = 1, 15 + setting.rdQual * 3 do
            local a = ran:Float(0, 360)
            local v = ran:Float(0.3, 4)
            table.insert(self.particle, {
                x = self.x, y = self.y,
                vx = cos(a) * v, vy = sin(a) * v,
                rot = ran:Float(0, 360),
                omega = ran:Float(1.5, 3) * ran:Sign(),
                alpha = ran:Float(150, 250), timer = 0,
            })
        end
        task.New(self, function()
            for i = 1, int(time / 60) do
                PlaySound("bubble")
                task.Wait(60)
            end
        end)
        task.New(self, function()
            task.SmoothSetValueTo("alpha", 1, 25, 0)
            task.Wait(time - 25)
            self.del_flag = true
            task.SmoothSetValueTo("alpha", 0, 25, 0)
        end)
    end,
    frame = function(self)
        task.Do(self)
        self.x, self.y = player.x, player.y
        local p
        if not self.del_flag then
            if self.timer % (6 - setting.rdQual) == 0 then
                local a = ran:Float(0, 360)
                local v = ran:Float(0.3, 4)
                table.insert(self.particle, {
                    x = self.x, y = self.y,
                    vx = cos(a) * v, vy = sin(a) * v,
                    rot = ran:Float(0, 360),
                    omega = ran:Float(0.5, 1.5) * ran:Sign(),
                    alpha = ran:Float(75, 150), timer = 0,
                })
            end
        end
        for i = #self.particle, 1, -1 do
            p = self.particle[i]
            p.x = p.x + p.vx
            p.y = p.y + p.vy
            p.vx = p.vx - p.vx * 0.04
            p.vy = p.vy - p.vy * 0.04
            p.rot = p.rot + p.omega
            if p.timer > 40 then
                p.alpha = max(p.alpha - 5, 0)
                if p.alpha == 0 then
                    table.remove(self.particle, i)
                end
            end
            p.timer = p.timer + 1
        end
        if #self.particle == 0 then
            object.Del(self)
        end
    end,
    render = function(self)

        for _, p in ipairs(self.particle) do
            SetImageState("bright", "mul+add", p.alpha, self._r, self._g, self._b)
            Render("bright", p.x, p.y, 0, 12 / 150)
        end
        if self.alpha > 0 then
            SetImageState("bright", "", self.alpha * 255, self._r, self._g, self._b)
            Render("bright", self.x, self.y, 0, self.r / 75)
        end
    end
})
class5.feel_sick = feel_sick

local haniwa = Class(object, {
    init = function(self,R, x, y)
        self.layer = LAYER.PLAYER - 2
        self.colli = true
        self.killflag = true
        self.group = GROUP.PLAYER
        self.bound = false
        self._R = R
        self.R = 0
        self.a = self.R
        self.b = self.R
        self.open = false
        self.img = "haniwa"
        self.x, self.y = x, y
        self.alpha = 0
        task.New(self, function()
            for i = 1, 15 do
                self.alpha = task.SetMode[2](i / 15)
                task.Wait()
            end
            task.Wait(180)
            if lstg.var.life_boom > 0 then
                local r = 60
                local dmg = 0.05 * player.damage
                stg_levelUPlib.class.lifeboom_func(self.x, self.y, r, dmg, 40, 255, 227, 132)
            end
            for i = 1, 15 do
                self.alpha = 1-task.SetMode[2](i / 15)
                task.Wait()
            end
            Del(self)
        end)
    end,
    frame = function(self)
        task.Do(self)
        self.R = self.R + (-self.R + self._R) * 0.1
        self.a = self.R
        self.b = self.R
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
        local size = self.alpha * self.R
        SetImageState(self.img, "mul+add", self.alpha * 150, 255, 255, 255)
        Render(self.img, px, py, sin(self.timer * 6) * 6, size / 55)
    end
}, true)
class5.haniwa = haniwa


return class5
