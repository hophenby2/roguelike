local cos, sin, lstg, ext, ipairs, table = cos, sin, lstg, ext, ipairs, table
local task, object, ran = task, object, ran
local Dist, Angle, Forbid = Dist, Angle, clamp
local max, min = max, min
local New = New
local IsValid = IsValid
local SetViewMode = SetViewMode
local SetImageState = SetImageState
local RenderRect = RenderRect
local Render = Render
local Color = Color
local unpack = unpack
local GetCurrentSuperPause = GetCurrentSuperPause

local extboss = {  }
function extboss:init()
    self.alpha = 0
    self.timer = 0
    self.boss_id = nil--防止boss无缝创建的东西
    self.boss_bg = nil --背景处理
    self.boss_aura = nil --法阵处理
    self.boss_SCcircle = nil--符卡环处理
    self.maxlen = 0
    self.curlen = 0
end
function extboss:frame()
    self.timer = self.timer + 1
    --背景，法阵，符卡环处理
    local bgroup = boss_group
    if #bgroup > 0 then
        if not self.boss_id then
            self.boss_id = bgroup[1].ID--以boss组里的第一个为代表
        end
        if IsValid(bgroup[1]) then
            local bg
            for _, b in ipairs(bgroup) do
                if b._bg then
                    bg = b._bg
                    break
                end
            end
            self:Do("boss_bg", bg, function(self)
                for _, boss in ipairs(bgroup) do
                    boss.bg = self.boss_bg
                end
            end)
        end
        self:Do("boss_SCcircle", boss_drawSpellCircle)
    else
        self:ValidDel()
    end
end
function extboss:render()

    if stage.current_stage.is_menu then
        return
    end
    SetViewMode("ui")
    local timer = self.timer
    local w = lstg.world
    local alpha = self.alpha
    local white = "white"
    local bosses = boss_group
    local validboss = {}
    if #bosses > 0 then
        do
            local show_name = ""
            local t = 0
            for _, b in ipairs(bosses) do
                b.ui.infobar.offy = -t * 13
                if b.ui.drawname then
                    show_name = show_name .. b.name .. "\n"
                end
                t = t + 1
                if b.sc_left > 1 then
                    show_name = show_name .. "\n"
                    t = t + 1
                end
            end
            ui:RenderText("title", show_name, w.scrl + 7, w.scrt - 2, 0.65,
                    Color(255, 205 + 50 * sin(timer / 4), 227, 132), "noclip")
        end
        local unit, percent
        for _, b in ipairs(boss_group) do
            if IsValid(b) and not (b.no_hp_render or (b.t1 == b.t3)) then
                table.insert(validboss, b)
            end
        end
        if #validboss > 0 then
            self.maxlen = (w.scrr - w.scrl) / #validboss
            self.curlen = self.curlen + (-self.curlen + self.maxlen) * 0.11
            local maxlen = self.curlen
            local last_x = w.scrl
            local b
            for i = 1, #validboss do
                --Print(maxlen)
                b = validboss[i]
                unit = sin(min(b.__hpbar_timer, 90))
                percent = b.hp / b.maxhp
                if unit > 0 then
                    local c = b.dmgt / b.dmgmaxt
                    SetImageState(white, "", 255 * alpha, 0, 0, 0)
                    RenderRect(white, last_x + 1, last_x + percent * maxlen * unit + 1, w.scrb - 22 - 1, w.scrb - 25 - 1)
                    SetImageState(white, "mul+add", (100 + c * 100) * alpha,
                            sp:HSVtoRGB((i / #validboss) * 360 + timer / 2, 0.6, 1))
                    RenderRect(white, last_x, last_x + percent * maxlen * unit, w.scrb - 22, w.scrb - 25)
                    ui:RenderText('title', b.name, last_x, w.scrb - 22, 0.5,
                            Color(alpha * 255 * unit, 200, 200, 200), "left", "bottom")
                    for _, a in ipairs(b._sp_point_auto) do
                        local index = 1 - a.dmg / b.maxhp
                        SetImageState(white, "", 255 * alpha, 255, 255, 255)
                        RenderRect(white, last_x + index * maxlen * unit - 1, last_x + index * maxlen * unit + 1, w.scrb - 21, w.scrb - 26)
                    end
                    last_x = last_x + percent * maxlen * unit
                end
            end
        end
        if #validboss == 0 then
            self.alpha = max(0, alpha - 1 / 60)
        else
            self.alpha = min(1, alpha + 1 / 60)
        end
    else
        self.alpha = max(0, alpha - 1 / 60)
    end
end

---@param index string
---@param unit object
---@param other function
function extboss:Do(index, unit, other)
    if IsValid(self[index]) then
        --[[
        if self.boss_id ~= boss_group[1].ID then
            self.boss_id = nil
            object.Del(self[index])
            if unit then
                self[index] = New(unit)
            end
            if other then
                other(self)
            end
        end--]]
    else
        if unit then
            self[index] = New(unit)
        end
        if other then
            other(self)
        end
    end
end
function extboss:refresh()
    self.alpha = 0
    self.boss_id = nil--防止boss无缝创建的东西
    self.boss_bg = nil --背景处理
    self.boss_aura = nil --法阵处理
    self.boss_SCcircle = nil--符卡环处理
    self.maxlen = 0
    self.curlen = 0
end
function extboss:ValidDel()
    self.boss_id = nil
    if IsValid(self.boss_bg) then
        Del(self.boss_bg)
    end
    if IsValid(self.boss_aura) then
        Del(self.boss_aura)
    end
    if IsValid(self.boss_SCcircle) then
        Del(self.boss_SCcircle)
    end
    self.boss_bg = nil
    self.boss_aura = nil
    self.boss_SCcircle = nil
end

---@class ext.boss
ext.boss_ui = extboss
ext.boss_ui:init()

local Smooth = task.Smooth


---@class boss_aura
boss_aura = Class(object)
function boss_aura:init(boss)
    self.bound = false
    self.layer = LAYER.ENEMY - 2
    self.group = GROUP.GHOST
    self.boss = boss
    self.scale = 0
    self._scale = 0
    self.angle = -180
    self.alpha = 128
    self._timer = 0
    self._alpha = 1
    self.img = "_boss_aura"
    self.open = false
    self.rotspeed = -5.624999803045763
    self.nopause = true
end
function boss_aura:frame()
    if not IsValid(self.boss) then
        Del(self)
        return
    end
    task.Do(self)
    self.x, self.y = self.boss.x, self.boss.y
    self.rot = self.angle
    self.hscale, self.vscale = self.scale, self.scale
    local k = (self._timer) % 120
    if self.open and (GetCurrentSuperPause() <= 0 or self.boss.nopause) then
        self.angle = self.angle + self.rotspeed
        if k <= 60 then
            local K = Smooth(k / 60)
            self.alpha = min(128 - 32 * K, 128)
            self.scale = 1.6 + 0.4 * K
        else
            k = k - 60
            local K = Smooth(k / 60)
            self.alpha = 96 + 32 * K
            self.scale = 2 - 0.4 * K
        end
        self._timer = self._timer + 1
    end
end
function boss_aura:render()
    if not IsValid(self.boss) then
        return
    end
    if self._alpha > 0 then
        SetImageState(self.img, "mul+add", self.alpha * self._alpha, 255, 255, 255)
        DefaultRenderFunc(self)
    end
end

---@class boss_drawSpellCircle
local extend_rate = 1.4
local exr1, bold, main_radius = -0.5, 3, 164 --红外环半径偏移，环粗偏移值，原环粗16，卡环半径
local main_radius2 = 200
local bold2 = 20
local rov1, rov2 = -4, 1.5
boss_drawSpellCircle = Class(object)
function boss_drawSpellCircle:init()
    self.layer = LAYER.BG + 0.99
    self.group = GROUP.GHOST
    self.setstate = function(t, alpha)
        for i = 1, 16 do
            SetImageState('bossring' .. t .. i, 'mul+add', alpha, 255, 255, 255)
        end
    end
    self.renderfunc = misc.RenderRing
end
function boss_drawSpellCircle:render()
    local alpha
    local ringx, ringy
    local speed, angle
    local t, r
    local cut = int(28 + 20 * setting.rdQual / 5)
    sp:UnitListUpdate(boss_group)
    for _, b in ipairs(boss_group) do
        alpha = 255
        ringx = b._sc_ring_x or b.x
        ringy = b._sc_ring_y or b.y
        if ext.pause_menu:IsKilled() then
            speed = Dist(ringx, ringy, b.x, b.y)
            angle = Angle(ringx, ringy, b.x, b.y)
            speed = Forbid(speed * (b._sc_ring_ratespeed or 0.08), b._sc_ring_minspeed or 0.5, speed)
            ringx = ringx + speed * cos(angle)
            ringy = ringy + speed * sin(angle)
        end
        b._sc_ring_x = ringx
        b._sc_ring_y = ringy
        if not b.__is_waiting and b.__draw_sc_ring then
            if b.t1 ~= b.t3 then
                self.setstate(1, alpha * 0.6)
                self.setstate(3, alpha)
                if b.timer < 90 then
                    self.renderfunc('bossring1', ringx, ringy,
                            b.timer * (main_radius / 90) + main_radius * 1.5 * sin(b.timer * 2) + 14 + exr1 + bold,
                            b.timer * (main_radius / 90) + main_radius * 1.5 * sin(b.timer * 2) - 2 + exr1,
                            b.ani * rov1, cut, 16)
                    self.renderfunc('bossring3', ringx, ringy,
                            90 + ((main_radius - 90) / 90) * b.timer + 4,
                            -main_radius + (1 - cos(b.timer) * cos(b.timer)) * (main_radius * 2 - 12) - bold * 3,
                            b.ani * rov2, cut, 16)--white
                else
                    t = b.t3 * extend_rate --多给点收缩时间,符卡环最终半径不要为0
                    r = (t - 90) / main_radius
                    self.renderfunc('bossring1', ringx, ringy,
                            (t - b.timer * 1.08) / r + 14 + exr1 + bold,
                            (t - b.timer * 1.08) / r - 2 + exr1,
                            b.ani * rov1, cut, 16)
                    self.renderfunc('bossring3', ringx, ringy,
                            (t - b.timer) / r + 4,
                            (t - b.timer) / r - 12 - bold * 3,
                            b.ani * rov2, cut, 16)--white

                end
            else
                self.setstate(3, alpha)
                if b.timer < 90 then
                    self.renderfunc('bossring3', ringx, ringy,
                            90 + ((main_radius2 - 90) / 90) * b.timer + 4,
                            -main_radius2 + task.SetMode[2](b.timer / 90) * (main_radius2 * 2 - 12) - bold2,
                            -b.ani * rov2, cut, 16)--white
                else
                    t = b.t3 * extend_rate --多给点收缩时间,符卡环最终半径不要为0
                    r = (t - 90) / main_radius2
                    self.renderfunc('bossring3', ringx, ringy,
                            (t - b.timer) / r + 4,
                            (t - b.timer) / r - 12 - bold2,
                            -b.ani * rov2, cut, 16)--white

                end
            end
        end
    end
end

local path = "assets\\enemy\\"
LoadImageFromFile("_boss_aura", path.."aura.png")
LoadTexture("lifebar", path .. "lifebar.png")
LoadImageFromFile('circle_charge', path .. "charge.png")
LoadImageFromFile("circle_charge_eff", path .. "charge_eff.png")
CopyImage("small_leaf", "circle_charge_eff")
LoadImageFromFile('saoqi1', path .. "saoqi1.png")
LoadImageFromFile("saoqi2", path .. "saoqi2.png")
SetImageCenter("saoqi1", 24, 48)
LoadTexture("eff_maple", path .. "eff_maple.png")

LoadImageGroup("eff_maple", "eff_maple", 0, 0, 32, 32, 2, 2)

local rand = math.random
local charge = {}
charge.leaf = {
    insert = function(self, l, angle, lifetime, size, mode)
        local _l = (mode == 2) and 0 or l
        table.insert(self.leaf, {
            x = self.x + _l * cos(angle),
            y = self.y + _l * sin(angle),
            v = l / lifetime,
            a = angle + 180,
            timer = 0,
            lifetime = lifetime,
            size = size,
            hscale = size,
            vscale = size,
            _d_size = -(1 + rand() * 2) * size / lifetime,
            alpha = 0,
            rot = rand() * 360,
            omega = (0.8 + rand() * 0.4) * ({ 1, -1 })[rand(2)]
        })
    end,
    frame = function(self)
        local l
        for i = #self.leaf, 1, -1 do
            l = self.leaf[i]
            l.x = l.x + cos(l.a) * l.v
            l.y = l.y + sin(l.a) * l.v
            l.size = l.size + l._d_size
            l.hscale = l.size
            if l.timer < 10 then
                l.alpha = min(128, l.alpha + 128 / 10)
            end
            if l.timer > l.lifetime - 15 then
                l.alpha = max(0, 128 * (l.lifetime - l.timer - 1) / 15)
            end
            if l.timer == l.lifetime then
                table.remove(self.leaf, i)
            end
            l.timer = l.timer + 1
        end
    end,
    render = function(self)
        for _, l in ipairs(self.leaf) do
            SetImageState("circle_charge_eff", "mul+add", l.alpha, 255, 255, 255)
            Render("circle_charge_eff", l.x, l.y, l.rot, l.hscale, l.vscale)
        end
    end
}
charge.IN = Class(object, {
    init = function(self, x, y, r, g, b, nosound)
        self.x, self.y = x, y
        self.img = 'circle_charge'
        self.layer = LAYER.ENEMY + 50
        self.group = GROUP.GHOST
        self.bound = true
        self.leaf = {}
        self._a, self._r, self._g, self._b = 255, r, g, b
        if not nosound then
            PlaySound("ch02", 1, 0, false)
        end
        task.New(self, function()
            local s = 1
            local a = 80
            local j = 0
            for i = 1, 61 do
                if i < 45 then
                    j = j + setting.rdQual / 5
                    if j >= 1 then
                        charge.leaf.insert(self, 200 + rand() * 100, rand() * 360,
                                rand(30, 45), 3.5 + rand() * 1.5, 1)
                        j = j - 1
                    end
                end
                self.hscale = s
                self.vscale = s
                self._a = a
                task.Wait()
                s = s - 1 / 60
                a = a + 2
            end
            while #self.leaf > 0 do
                task.Wait()
            end
            object.Del(self)
        end)
    end,
    frame = function(self)
        task.Do(self)
        charge.leaf.frame(self)
    end,
    render = function(self)
        SetImageState(self.img, "mul+add", self._a, self._r, self._g, self._b)
        DefaultRenderFunc(self)
        charge.leaf.render(self)
    end
})
charge.OUT = Class(object, {
    init = function(self, x, y, r, g, b, nosound, size)
        self.x, self.y = x, y
        self.img = "circle_charge"
        self.layer = LAYER.ENEMY + 50
        self.group = GROUP.GHOST
        self.bound = true
        self.leaf = {}
        self.hscale, self.vscale = 0, 0
        self._a, self._r, self._g, self._b = 0, r, g, b
        if not nosound then
            PlaySound("enep02", 1, 0, false)
        end
        task.New(self, function()

            local a = 240
            local j = 0
            for i = 1, 61 do

                if i < 15 then
                    for _ = 1, 3 do
                        j = j + setting.rdQual / 5
                        if j >= 1 then
                            charge.leaf.insert(self, 200 + rand() * 100, rand() * 360,
                                    rand(45, 60), 3.5 + rand() * 1.5, 2)
                            j = j - 1
                        end
                    end
                end
                i = task.SetMode[2](i / 61)
                self.hscale = 1.5 * i
                self.vscale =  self.hscale
                self._a = a
                task.Wait()
                a = a - 4
            end
            while #self.leaf > 0 do
                task.Wait()
            end
            object.Del(self)
        end)
    end,
    frame = function(self)
        task.Do(self)
        charge.leaf.frame(self)
    end,
    render = function(self)
        SetImageState(self.img, "mul+add", self._a, self._r, self._g, self._b)
        DefaultRenderFunc(self)
        charge.leaf.render(self)
    end
})

charge_in = charge.IN
charge_out = charge.OUT
function Newcharge_in(x, y, r, g, b, nosound)
    New(charge.IN, x, y, r, g, b, nosound)
end
function Newcharge_out(x, y, r, g, b, nosound)
    New(charge.OUT, x, y, r, g, b, nosound)
end

local DefaultRenderFunc = DefaultRenderFunc
local wait = task.Wait
local del = object.RawDel
local blend = "mul+add"

SaoqiMain = Class(object)
function SaoqiMain:frame()
    task.Do(self)
    if IsValid(self.master) then
        self.y = self.y + (self.master.y - self.bossy)
        self.bossy = self.master.y
        self.x = self.x + (self.master.x - self.bossx)
        self.bossx = self.master.x
    else
        del(self)
    end
end

local up_color = Class(SaoqiMain)
function up_color:init(x, y, master, R, G, B)
    self.x, self.y = x, y
    self.layer = -600 - 1
    self.group = 0
    self.R, self.G, self.B = R, G, B
    self.img = "saoqi1"
    self.blend = blend
    self.bound = false
    self.xpos = ran:Float(-1, 1) * 4
    self.ypos = 0
    self.master = master
    self.acck = 0
    self.hscale = ran:Float(0, 0.7) + 1
    self.vscale = 0
    if IsValid(self.master) then
        self.bossx = self.master.x
        self.bossy = self.master.y
    end
    task.New(self, function()
        local scaley = ran:Float(0, 0.5) + 1.9
        for i = 1, 30 do
            i = i / 30
            self.acck = i * i
            self.vscale = scaley * (i * 2 - i * i)
            wait()
        end
        wait()
        del(self)
    end)
end
function up_color:render()
    SetImageState(self.img, self.blend, 255 * (1 - self.acck), self.R, self.G, self.B)
    DefaultRenderFunc(self)
end

local round_color = Class(SaoqiMain)
function round_color:init(x, y, master, R, G, B)
    self.x, self.y = x, y
    self.layer = -700
    self.group = 0
    self.R, self.G, self.B = R, G, B
    self.img = "saoqi2"
    self.blend = blend
    self.bound = false
    self.xpos = 0
    self.ypos = 0
    self.rot = ran:Float(-180, 180)
    self.master = master
    self.deck = 0
    local hscale, vscale = ran:Float(0, 0.7) + 1.6, ran:Float(0, 0.7) + 1.6
    self.hscale, self.vscale = hscale, vscale

    if IsValid(self.master) then
        self.bossx = self.master.x
        self.bossy = self.master.y
    end
    task.New(self, function()
        for i = 1, 30 do
            i = i / 30
            i = 2 * i - i * i
            self.deck = i
            self.vscale = hscale + (0.7 - hscale) * i
            self.hscale = vscale + (0.7 - vscale) * i
            wait()
        end
        del(self)
    end)
end
function round_color:render()
    SetImageState(self.img, self.blend, 255 * self.deck, self.R, self.G, self.B)
    DefaultRenderFunc(self)
end

local white_color = Class(SaoqiMain)
function white_color:init(x, y, master)
    self.x, self.y = x, y
    self.layer = -600 - 2
    self.group = 0
    self.img = "saoqi2"
    self.blend = blend
    self.bound = false
    self.master = master
    self.rot = ran:Float(-180, 180)
    self.deck = 0
    local hscale, vscale = ran:Float(0, 0.7) + 2, ran:Float(0, 0.7) + 2
    self.hscale, self.vscale = hscale, vscale
    if IsValid(self.master) then
        self.bossx = self.master.x
        self.bossy = self.master.y
    end
    task.New(self, function()
        for i = 1, 30 do
            i = i / 30
            i = 2 * i - i * i
            self.hscale = hscale + (1.2 - hscale) * i
            self.vscale = hscale + (1.2 - hscale) * i
            self.deck = i
            wait()
        end
        wait()
        del(self)
    end)
end
function white_color:render()
    SetImageState(self.img, self.blend, 64 * self.deck, 255, 255, 255)
    DefaultRenderFunc(self)
end

function SaoqiMain:init(X, Y, master, color1, color2)
    self.x, self.y = X, Y
    self.layer = -600 - 1
    self.group = 0
    self.master = master
    self.bound = false
    if IsValid(self.master) then
        self.bossx = self.master.x
        self.bossy = self.master.y
    end
    local r2, g2, b2 = unpack(color2)
    local r1, g1, b1 = unpack(color1)
    task.New(self, function()
        while true do
            if self.master._bosssys and self.master._bosssys.aura and self.master._bosssys.aura._alpha > 0 then
                wait(3)
                New(round_color, self.x, self.y, self, r2, g2, b2)
                wait(1)
                New(white_color, self.x, self.y, self)
                wait(2)
                New(up_color, self.x, self.y, self, r1, g1, b1)
            else
                wait(6)
            end
        end
    end)
end




