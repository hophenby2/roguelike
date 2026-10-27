

---boss 特效
---一些华丽的效果（
local cos, sin, int = cos, sin, int
local SetImageState = SetImageState
local Render = Render
local Render4V = Render4V
local SetFontState = SetFontState
local SetViewMode = SetViewMode
local RenderText = RenderText
local task = task
local object = object
local Format = string.format


--开卡文字
--！警告：未适配宽屏等非传统版面
spell_card_ef = Class(object, { frame = task.Do })
function spell_card_ef:init()
    self.layer = LAYER.BG + 0.8
    self.group = GROUP.GHOST
    self.alpha = 0
    task.New(self, function()
        for _ = 1, 50 do
            task.Wait()
            self.alpha = self.alpha + 0.02
        end
        task.Wait(60)
        for _ = 1, 50 do
            task.Wait()
            self.alpha = self.alpha - 0.02
        end
        Del(self)
    end)
end
function spell_card_ef:render()
    local img = "spell_card_ef"
    SetImageState(img, "", 167 * self.alpha, 255, 255, 255)
    local l
    for j = 1, 10 do
        for i = -2, 2 do
            l = i * 128 + self.timer * (2 * (j % 2) - 1)
            Render(img, l * cos(30), l * sin(30) + (j - 4.5) * 32, -60)
        end
    end
    l = -self.timer * 1.5
    local da = 45
    local dr = 20
    local minr = 112
    local ddr = 32
    local cx = 288
    local cy = -208
    local dir = { -1, -1, 1, 1 }
    for j = 1, 8 do
        for i, d in ipairs(dir) do
            i = i - 1
            Render4V(img,
                    cx + (minr + ddr * i) * cos(j * 45 + l * d), cy + (minr + ddr * i) * sin(j * 45 + l * d), 0.5,
                    cx + (minr + ddr * i - dr) * cos(j * 45 + l * d), cy + (minr + ddr * i - dr) * sin(j * 45 + l * d), 0.5,
                    cx + (minr + ddr * i - dr) * cos(j * 45 - da + l * d), cy + (minr + ddr * i - dr) * sin(j * 45 - da + l * d), 0.5,
                    cx + (minr + ddr * i) * cos(j * 45 - da + l * d), cy + (minr + ddr * i) * sin(j * 45 - da + l * d), 0.5)
            if i < 2 then
                Render4V(img,
                        -cx + (minr + ddr * i) * cos(j * 45 + l * d), -cy + (minr + ddr * i) * sin(j * 45 + l * d), 0.5,
                        -cx + (minr + ddr * i - dr) * cos(j * 45 + l * d), -cy + (minr + ddr * i - dr) * sin(j * 45 + l * d), 0.5,
                        -cx + (minr + ddr * i - dr) * cos(j * 45 - da + l * d), -cy + (minr + ddr * i - dr) * sin(j * 45 - da + l * d), 0.5,
                        -cx + (minr + ddr * i) * cos(j * 45 - da + l * d), -cy + (minr + ddr * i) * sin(j * 45 - da + l * d), 0.5)
            end
        end

    end
end

local boss_cast_darkball_unit = Class(object)
function boss_cast_darkball_unit:init(CX, CY, Radius, T, c, blendtype, R, G, B, LAYER_MOVE, rv)
    self.x, self.y = CX, CY
    self.img = "boss_light"
    self.layer = LAYER.ENEMY + 10
    self.bound = false
    self.lm = LAYER_MOVE
    local ran = ran
    local rotv = rv + ran:Float(0, 0.25)
    local t1 = 45
    local rs
    if blendtype == 1 then
        rs = ran:Float(1.75, 1.5) + 0.5
    elseif blendtype == 2 then
        rs = ran:Float(1.55, 1.75) + 0.5
    elseif blendtype == 3 then
        rs = ran:Float(1.4, 1.25) + 0.25
    end
    self.rot = ran:Float(0, 360)
    self.r_floater = ran:Float(-20, 20)
    self.r = Radius + self.r_floater
    self.a_floater = ran:Float(-30, 30)
    self.hscale, self.vscale = rs, rs

    if blendtype == 1 then
        self._blend, self._a, self._r, self._g, self._b = "", 0, R, G, B
    elseif blendtype == 2 then
        self._blend, self._a, self._r, self._g, self._b = "mul+rev", 0, R, G, B
    elseif blendtype == 3 then
        self._blend, self._a, self._r, self._g, self._b = "mul+add", 0, R, G, B
    end
    task.New(self, function()
        task.New(self, function()
            local a, _d_a = 0, 255 / t1
            for _ = 0, t1 do
                self._a = a
                task.Wait()
                a = a + _d_a
            end
        end)
        local final_scale = 2
        local a, _d_a = 0, 90 / T
        local ra, _d_ra = 0, rotv
        local d
        for _ = 0, T do
            self.hscale = rs + (final_scale - rs) * sin(a)
            self.vscale = rs + (final_scale - rs) * sin(a)
            d = ((self.r) * (1 - sin(a)))
            if blendtype == 3 then
                self.a = 255 * cos(a)
            end
            self.x = CX + d * cos(c + self.a_floater + ra)
            self.y = CY + d * sin(c + self.a_floater + ra)
            task.Wait()
            a = a + _d_a
            ra = ra + _d_ra
        end
        local gather_time = 10
        task.Wait(gather_time)
        local disapt = 30
        a, _d_a = 0, 90 / disapt
        for _ = 0, disapt do
            if blendtype == 3 then
                self._a = 0
            else
                self.a = 255 * cos(a)
            end
            self.hscale = final_scale * cos(a)
            self.vscale = final_scale * cos(a)
            task.Wait()
            a = a + _d_a
        end
        Del(self)
    end)
end
function boss_cast_darkball_unit:frame()
    task.Do(self)
    self.layer = LAYER.ENEMY + self.lm
end
function boss_cast_darkball_unit:render()
    SetImageState(self.img, self._blend, self._a, self._r, self._g, self._b)
    DefaultRenderFunc(self)
end


--黑球蓄力
boss_cast_darkball = Class(object, { frame = task.Do })
function boss_cast_darkball:init(x, y, KeepTime, ContractTime, Radius, Ways, Angle, R, G, B, ROT_V)
    self.x, self.y = x, y
    self.layer = LAYER.ENEMY + 10
    self.bound = false
    local T = KeepTime
    local jg1, jg2 = 3, 2
    local New = New
    task.New(self, function()
        for _ = 0, (T / jg1) do
            local c, _d_c = Angle, 360 / Ways
            for _ = 1, Ways do
                for _ = 1, 3 do
                    New(boss_cast_darkball_unit, x, y, Radius, ContractTime, c, 2, 255 - R, 255 - G, 255 - B, 15, ROT_V)
                end
                c = c + _d_c
            end
            task.Wait(jg1)
        end
        task.Wait(60)
        Del(self)
    end)
    task.New(self, function()
        -- mul+rev(dark)
        local jg3 = 4
        for _ = 1, (T / jg3) + 1 do
            local c, _d_c = (Angle), (360 / Ways)
            for _ = 1, Ways do
                New(boss_cast_darkball_unit, x, y, Radius, ContractTime, c, 2, 200, 200, 200, 10, ROT_V)
                c = c + _d_c
            end
            task.Wait(jg3)
        end
    end)
    task.New(self, function()
        for _ = 0, (T / jg2) do
            local c, _d_c = Angle, 360 / Ways
            for _ = 1, Ways do
                New(boss_cast_darkball_unit, x, y, Radius, ContractTime, c, 3, R, G, B, 5, ROT_V)
                c = c + _d_c
            end
            task.Wait(jg2)
        end
    end)
end

boss_death_ef_unit = Class(object)
function boss_death_ef_unit:init(x, y, v, angle, lifetime, size, img, rot)
    self.x = x
    self.y = y
    self.rot = rot or ran:Float(0, 360)
    SetV(self, v, angle)
    self.lifetime = lifetime
    self.omega = 3
    self.layer = LAYER.ENEMY + 50
    self.group = GROUP.GHOST
    self.bound = false
    self.img = img or "leaf"
    self.hscale = size
    self.vscale = size
end
function boss_death_ef_unit:frame()
    if self.timer == self.lifetime then
        Del(self)
    end
end
function boss_death_ef_unit:render()
    if self.timer < 15 then
        SetImageState(self.img, "mul+add", self.timer * 12, 255, 255, 255)
    else
        SetImageState(self.img, "mul+add", ((self.lifetime - self.timer) / (self.lifetime - 15)) * 180, 255, 255, 255)
    end
    DefaultRenderFunc(self)
end

--死亡爆炸
boss_explode_cherry = Class(object)
function boss_explode_cherry:init(x, y)
    self.x, self.y = x, y
    self.layer = LAYER.ENEMY + 50
    self.group = GROUP.GHOST
    self.bound = false
    self.img = "cherry_bullet"
    self.cherry = {}
    misc.ShakeScreen(20, 1)
    local rand = math.random
    local lifetime, l
    for _ = 1, 150 * setting.rdQual / 5 do
        lifetime = rand(60, 90)
        l = ran:Float(100, 500)
        table.insert(self.cherry, { x = self.x, y = self.y,
                                    v = l / lifetime, a = ran:Float(0, 360),
                                    rot = rand() * 360, omega = ran:Sign() * 3,
                                    scale = ran:Float(0.5, 1), lifetime = lifetime,
                                    timer = 0, alpha = 0 })
    end
end
function boss_explode_cherry:frame()
    local c
    for i = #self.cherry, 1, -1 do
        c = self.cherry[i]
        c.x = c.x + cos(c.a) * c.v
        c.y = c.y + sin(c.a) * c.v
        c.rot = c.rot + c.omega
        if c.timer < 15 then
            c.alpha = c.timer * 12
        else
            c.alpha = ((c.lifetime - c.timer) / (c.lifetime - 15)) * 180
        end
        c.timer = c.timer + 1
        if c.timer >= c.lifetime then
            table.remove(self.cherry, i)
        end
    end
    if #self.cherry == 0 then
        object.RawDel(self)
    end
end
function boss_explode_cherry:render()
    local c
    for i = #self.cherry, 1, -1 do
        c = self.cherry[i]
        SetImageState(self.img, "mul+add", c.alpha, 255, 255, 255)
        Render(self.img, c.x, c.y, c.rot, c.scale)
    end
end

boss_explode_maple = Class(object)
function boss_explode_maple:init(x, y, thickness)
    self.x, self.y = x, y
    self.layer = LAYER.ENEMY + 50
    self.group = GROUP.GHOST
    self.bound = false
    self.img = "leaf"
    self.cherry = {}
    misc.ShakeScreen(20, 1)
    local rand = math.random
    local lifetime, l
    for _ = 1, (thickness or 150) * setting.rdQual / 5 do
        lifetime = rand(60, 90)
        l = ran:Float(100, 500)
        table.insert(self.cherry, { x = self.x, y = self.y,
                                    v = l / lifetime, a = ran:Float(0, 360),
                                    rot = rand() * 360, omega = ran:Sign() * 3,
                                    scale = ran:Float(0.7, 1.2), lifetime = lifetime,
                                    timer = 0, alpha = 0 })
    end
end
function boss_explode_maple:frame()
    local c
    for i = #self.cherry, 1, -1 do
        c = self.cherry[i]
        c.x = c.x + cos(c.a) * c.v
        c.y = c.y + sin(c.a) * c.v
        c.rot = c.rot + c.omega
        if c.timer < 15 then
            c.alpha = c.timer * 12
        else
            c.alpha = ((c.lifetime - c.timer) / (c.lifetime - 15)) * 180
        end
        c.timer = c.timer + 1
        if c.timer >= c.lifetime then
            table.remove(self.cherry, i)
        end
    end
    if #self.cherry == 0 then
        object.RawDel(self)
    end
end
function boss_explode_maple:render()
    local c
    for i = #self.cherry, 1, -1 do
        c = self.cherry[i]
        SetImageState(self.img, "mul+add", c.alpha, 255, 255, 255)
        Render(self.img, c.x, c.y, c.rot, c.scale)
    end
end
--非或符结束时弹出的文字

kill_timer = Class(object)
function kill_timer:init(x, y, t)
    self.t = t
    self.x = x
    self.y = y - 3
    --self.yy = y
    self.alph = 0
end
function kill_timer:frame()
    if self.timer <= 30 then
        self.alph = self.timer / 30
    end
    if self.timer > 120 then
        self.alph = 1 - (self.timer - 120) / 30
    end
    if self.timer >= 150 then
        Del(self)
    end
end
function kill_timer:render()
    SetViewMode "world"
    local alpha = self.alph
    --略修改位置，小数点后位缩小
    local basex = 54
    SetFontState("Score", "", alpha * 255, 0, 0, 0)
    RenderText("Score", Format("%d.", int(self.t / 60)), basex - 1, self.y, 0.5, "vcenter", "right")
    RenderText("Score", Format("%02ds", int(self.t / 60 * 100 % 100)), basex - 1, self.y - 1, 0.3, "vcenter", "left")

    SetFontState("Score", "", alpha * 255, 200, 200, 200)
    RenderText("Score", Format("%d.", int(self.t / 60)), basex, self.y + 1, 0.5, "vcenter", "right")
    RenderText("Score", Format("%02ds", int(self.t / 60 * 100 % 100)), basex, self.y, 0.3, "vcenter", "left")

    SetImageState("hint.killtimer", "", alpha * 255, 255, 255, 255)
    Render("hint.killtimer", -39, self.y + 2, 0.5, 0.5)

end

kill_timer2 = Class(kill_timer)
function kill_timer2:render()
    SetViewMode "world"
    local alpha = self.alph
    --略修改位置，小数点后位缩小
    local basex = 54
    SetFontState("Score", "", alpha * 255, 0, 0, 0)
    RenderText("Score", Format("%d.", int(self.t / 60)), basex - 1, self.y, 0.5, "vcenter", "right")
    RenderText("Score", Format("%02ds", int(self.t / 60 * 100 % 100)), basex - 1, self.y - 1, 0.3, "vcenter", "left")

    SetFontState("Score", "", alpha * 255, 127, 127, 127)
    RenderText("Score", Format("%d.", int(self.t / 60)), basex, self.y + 1, 0.5, "vcenter", "right")
    RenderText("Score", Format("%02ds", int(self.t / 60 * 100 % 100)), basex, self.y, 0.3, "vcenter", "left")
    SetImageState("hint.truetimer", "", alpha * 255, 255, 255, 255)
    Render("hint.truetimer", -39, self.y + 2, 0.5, 0.5)
end

--收率百分比变化显示
card_percent = Class(kill_timer)
function card_percent:render()
    SetViewMode "world"
    --略修改位置，小数点后位缩小
    SetFontState("Score", "", self.alph * 255, 255, 255, 255)
    RenderText("Score", Format("%+0.2f%%", self.t * 100), self.x, self.y, 0.5, "centerpoint")
end
local table = table
local function formatnum(num)
    local sign = sign(num)
    num = abs(num)
    local tmp = {}
    local var
    while num >= 1000 do
        var = num - int(num / 1000) * 1000
        table.insert(tmp, 1, Format("%03d", var))
        num = int(num / 1000)
    end
    table.insert(tmp, 1, tostring(num))
    var = table.concat(tmp, ",")
    if sign < 0 then
        var = Format("-%s", var)
    end
    return var, #tmp - 1
end

hinter_bonus = Class(object)
function hinter_bonus:init(img, size, x, y, t1, t2, fade, bonus)
    self.img = img
    self.x = x
    self.y = y
    self.t1 = t1
    self.t2 = t2
    self.fade = fade
    self.group = GROUP.GHOST
    self.layer = LAYER.TOP
    self.size = size
    self.t = 0
    self.hscale = self.size
    self.bonus = bonus
    --新增：用于SC得分特效的东西
    local text, commacount = formatnum(self.bonus)
    self.bonustext = text
    self.bonustext = sp.string(self.bonustext).string
    self.digital = #self.bonustext
    self.textspace = 12
    local ts = self.textspace
    self.textright = self.x + (self.digital - commacount) * ts / 2 + commacount * (ts / 2 + 2) / 2
end
function hinter_bonus:frame()
    if self.timer < self.t1 then
        self.t = self.timer / self.t1
    elseif self.timer < self.t1 + self.t2 then
        self.t = 1
    elseif self.timer < self.t1 * 2 + self.t2 then
        self.t = (self.t1 * 2 + self.t2 - self.timer) / self.t1
    else
        Del(self)
    end
    self.vscale = self.t * self.size
end
function hinter_bonus:render()
    if self.fade then
        --更改：SC得分特效
        local alpha = self.t * 255
        local rgb = 255
        local ts = self.textspace
        local initx = self.textright
        local t, y, fade
        if self.timer < 60 and self.timer % 4 == 0 then
            rgb = 63
        end
        SetImageState(self.img, "", alpha, rgb, rgb, rgb)
        for i = 1, self.digital do
            if self.timer >= self.t1 + self.t2 then
                SetFontState("Score", "", alpha, 255, 255, 255)
            else
                t = (self.timer * 8 - i * 32) * 0.4
                if t > 135 and t < 195 and self.timer % 4 == 0 then
                    fade = 1
                else
                    fade = 0
                end
                t = self.timer * 4 - i * 16
                alpha = clamp(t, 0, 255)
                rgb = 255 - 128 * fade
                SetFontState("Score", "", alpha, rgb, rgb, rgb)
            end
            t = (self.timer * 8 - i * 32) * 0.4
            y = self.y - 60 + 60 * sin(clamp(t, 0, 135))
            RenderText("Score", self.bonustext[self.digital - i + 1], initx, y, (ts - 2) / 20, "right")
            if i % 4 == 0 then
                initx = initx - ts / 2
            else
                initx = initx - ts
            end
        end
        DefaultRenderFunc(self)
    else
        SetImageState(self.img, "", 255, 255, 255, 255)
        self.vscale = self.t * self.size
        SetFontState("Score", "", 255, 255, 255, 255)
        RenderScore("Score", self.bonus, self.x + 1, self.y - 41, 0.7, "centerpoint")
        DefaultRenderFunc(self)
    end
end

