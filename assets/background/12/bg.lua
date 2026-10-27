BG_12 = Class(background)

local SetViewMode = SetViewMode
local Color = Color
local Set3D = Set3D
local cos, sin = cos, sin
local background = background
local SetImageState = SetImageState
local Render4V = Render4V
local Forbid = clamp
local task = task

function BG_12:init()
    local path = "assets\\background\\12\\"
    LoadImageFromFile("bg_12_bright", path .. "bright.png")
    LoadImageFromFile("bg_12_circle1", path .. "circle1.png")
    LoadImageFromFile("bg_12_circle2", path .. "circle2.png")
    LoadImageGroupFromFile("bg_12_circle3", path .. "circle3.png", nil, 1, 8)

    background.init(self, false)
    Set3D('eye', 0, 0, -1.5)
    Set3D('at', 0, 0, 0)
    Set3D('up', 0, 1, 0)
    Set3D('z', 0.1, 120)
    Set3D('fovy', 0.1)
    Set3D('fog', 20, 40, Color(100, 10, 90, 40))
    self.float = background.RanFloat
    self.int = background.RanInt
    self.sign = background.RanSign
    self.speed = 0.3
    self.z = 0
    self.circle = {}
    self.bright = {}
    self.building = {}
    self.rx, self.ry = 0, 0
    self.rR, self.rG, self.rB = 135, 206, 235
    function self:SetColor(Hue)
        if Hue == "black" then
            self.rR, self.rG, self.rB = 180, 180, 180
            lstg.view3d.fog[3] = Color(100, 0, 0, 0)
        else

            self.rR, self.rG, self.rB = sp:HSVtoRGB(Hue, 0.4, 1)
            lstg.view3d.fog[3] = Color(100, sp:HSVtoRGB(Hue, 0.8, 0.1))

        end
    end
    self:SetColor(200)
    local AddCircle = BG_12.AddCircle
    local AddBright = BG_12.AddBright
    local AddBuilding = BG_12.AddBuilding

    task.New(self, function()
        if not self.nosetfovy then
            for i = 1, 120 do
                i = sin(i * 0.75)
                Set3D('fog', 20, 40, Color(100, 10, 90 - 80 * i, 40))
                lstg.view3d.fovy = 0.1 + 0.6 * i
                task.Wait()
            end
        end
    end)

    task.New(self, function()
        local z = -2
        local range
        local rot
        for _ = 1, 10 do
            AddCircle(self, 0, 0, z, self:int(1, 2), 2)
            range = self:float(9, 12)
            rot = self:float(0, 360)
            for i = 1, 30 do
                AddBright(self, 0, 0, z, rot + i * range, 3, 1.2, 0.07)
            end
            z = z + self.speed * 15
            range = self:float(9, 12)
            rot = self:float(0, 360)
            for i = 1, 30 do
                AddBright(self, 0, 0, z, rot + i * range, 1.9, 0.9, 0.1)
            end
            z = z + self.speed * 15
        end
        while true do
            AddCircle(self, 0, 0, z, self:int(1, 2), 2)
            range = self:float(9, 12)
            rot = self:float(0, 360)
            for i = 1, 30 do
                AddBright(self, 0, 0, z, rot + i * range, 3, 1.2, 0.07)
            end
            task.Wait(15)
            range = self:float(9, 12)
            rot = self:float(0, 360)
            for i = 1, 30 do
                AddBright(self, 0, 0, z, rot + i * range, 1.9, 0.9, 0.1)
            end
            task.Wait(15)
        end
    end)
    task.New(self, function()
        local tz = -2
        for _ = 1, 300 do
            AddBright(self, 0, 0, tz, self:float(0, 360), self:float(2.1, 5), 0.1, 0.03, 135, 206, 235)
            tz = tz + self.speed
        end
        while true do
            AddBright(self, 0, 0, tz, self:float(0, 360), self:float(2.1, 5), 0.1, 0.03, 135, 206, 235)
            task.Wait(10)
        end
    end)
    task.New(self, function()
        local z = -2
        local rot = 0
        for _ = 1, 150 do
            AddBright(self, 0, 0, z, self:float(0, 360), 2, 1.2, 0.05)
            AddBright(self, 0, 0, z, self:float(0, 360), 2, 2.3, 0.1)
            for a = 1, 2 do
                AddBright(self, 0, 0, z, a * 180 + rot, 2.3, 1.5, 0.15)
            end
            rot = rot + 13
            z = z + self.speed * 2
        end
        while true do
            AddBright(self, 0, 0, z, self:float(0, 360), 2, 1.2, 0.05)
            AddBright(self, 0, 0, z, self:float(0, 360), 2, 2.3, 0.1)
            AddBright(self, 0, 0, z, self:float(0, 360), self:float(2.1, 5), 0.1, 0.03, 135, 206, 235)
            for a = 1, 2 do
                AddBright(self, 0, 0, z, a * 180 + rot, 2.3, 1.5, 0.15)
            end
            rot = rot + 13
            task.Wait(2)
        end
    end)
    task.New(self, function()
        local z = -2
        for _ = 1, 2 do
            AddBuilding(self, self:float(2, 4) * self:sign(), self:float(-4, -3), z,
                    self:float(1.5, 3.5), self:float(0.08, 0.12),
                    self:float(-45, 45), self:float(0, 360), self:sign() * 0.3, 0.2, 135, 206, 235)
            z = z + self.speed * 100
        end
        while true do
            AddBuilding(self, self:float(2, 4) * self:sign(), self:float(-4, -3), z,
                    self:float(1.5, 3.5), self:float(0.08, 0.12),
                    self:float(-45, 45), self:float(0, 360), self:sign() * 0.3, 0.2, 135, 206, 235)
            task.Wait(100)
        end
    end)
end

function BG_12:AddCircle(x, y, z, img, r)
    table.insert(self.circle, { x = x, y = y, z = z, r = r, vz = -self.speed, rz = self:float(0, 360),
                                img = "bg_12_circle" .. img, omega = self:float(0.3, 0.5) * background:RanSign() })
end
function BG_12:AddBright(x, y, z, a, r, speed, size)
    table.insert(self.bright, { x = x + cos(a) * r, y = y + sin(a) * r, z = z, vz = -self.speed * speed,
                                img = "bg_12_bright", s = size })
end
function BG_12:AddBuilding(x, y, z, radius, width, rz, rot, omega, speed)
    table.insert(self.building, { x = x, y = y, z = z, vz = -self.speed * speed, rz = rz,
                                  radius = radius, width = width, rot = rot, omega = omega })
end
local SQRT2 = SQRT2
local function draw_circle(x, y, z, radius, width, rz, rot, a, r, g, b)
    local a1 = 30
    local a2 = a1 / 8
    local ang
    for u = 1, 8 do
        SetImageState("bg_12_circle3" .. u, "mul+add", a, r, g, b)
    end
    local radius2 = radius - width * 2
    local radius3 = radius - width * 5
    local radius4 = radius3 - width * 2
    local cosrz, sinrz = cos(rz), sin(rz)
    local cosang, sinang, cosang2, sinang2
    for n = 1, 12 do
        for m = 1, 8 do
            ang = n * a1 + a2 * m + rot
            cosang, sinang = cos(ang), sin(ang)
            cosang2, sinang2 = cos(ang + a2), sin(ang + a2)
            Render4V("bg_12_circle3" .. m,
                    x + cosang * radius * cosrz, y - cosang * radius * sinrz, z + sinang * radius,
                    x + cosang2 * radius * cosrz, y - cosang2 * radius * sinrz, z + sinang2 * radius,
                    x + cosang2 * radius2 * cosrz, y - cosang2 * radius2 * sinrz, z + sinang2 * radius2,
                    x + cosang * radius2 * cosrz, y - cosang * radius2 * sinrz, z + sinang * radius2)
            ang = n * a1 + a2 * m - rot
            cosang, sinang = cos(ang), sin(ang)
            cosang2, sinang2 = cos(ang + a2), sin(ang + a2)
            Render4V("bg_12_circle3" .. m,
                    x + cosang * radius3 * cosrz, y - cosang * radius3 * sinrz, z + sinang * radius3,
                    x + cosang2 * radius3 * cosrz, y - cosang2 * radius3 * sinrz, z + sinang2 * radius3,
                    x + cosang2 * radius4 * cosrz, y - cosang2 * radius4 * sinrz, z + sinang2 * radius4,
                    x + cosang * radius4 * cosrz, y - cosang * radius4 * sinrz, z + sinang * radius4)
        end
    end
    radius = radius3 - width * 8
    radius = radius * SQRT2
    local rcosr, rsinr = radius * cos(rot), radius * sin(rot)
    SetImageState("bg_12_circle1", "mul+add", a, r, g, b)
    Render4V("bg_12_circle1",
            x + (-rcosr + rsinr) * cosrz, y - (-rcosr + rsinr) * sinrz, z - rcosr - rsinr,
            x + (rcosr + rsinr) * cosrz, y - (rcosr + rsinr) * sinrz, z - rcosr + rsinr,
            x + (rcosr - rsinr) * cosrz, y - (rcosr - rsinr) * sinrz, z + rcosr + rsinr,
            x + (-rcosr - rsinr) * cosrz, y - (-rcosr - rsinr) * sinrz, z + rcosr - rsinr)
    radius = radius - width * 8
    SetImageState("bg_12_circle2", "mul+add", a, r, g, b)
    rcosr, rsinr = radius * cos(-rot), radius * sin(-rot)
    Render4V("bg_12_circle2",
            x + (-rcosr + rsinr) * cosrz, y - (-rcosr + rsinr) * sinrz, z - rcosr - rsinr,
            x + (rcosr + rsinr) * cosrz, y - (rcosr + rsinr) * sinrz, z - rcosr + rsinr,
            x + (rcosr - rsinr) * cosrz, y - (rcosr - rsinr) * sinrz, z + rcosr + rsinr,
            x + (-rcosr - rsinr) * cosrz, y - (-rcosr - rsinr) * sinrz, z + rcosr - rsinr)
end

function BG_12:frame()
    task.Do(self)
    self.z = self.z - self.speed
    local c
    for i = #self.circle, 1, -1 do
        c = self.circle[i]
        task.Do(c)
        c.rz = c.rz + c.omega
        c.z = c.z + c.vz
        if c.z < -5 then
            table.remove(self.circle, i)
        end
    end
    for i = #self.bright, 1, -1 do
        c = self.bright[i]
        task.Do(c)
        c.z = c.z + c.vz
        if c.z < -5 then
            table.remove(self.bright, i)
        end
    end
    for i = #self.building, 1, -1 do
        c = self.building[i]
        task.Do(c)
        c.z = c.z + c.vz
        c.rot = c.rot + c.omega
        if c.z < -5 - c.radius then
            table.remove(self.building, i)
        end
    end
    Set3D("at", sin(self.timer / 3) * 0.3 * (lstg.view3d.fovy / 0.7), 0, 0)
end

function BG_12:render()
    SetViewMode '3d'
    background.ClearToFogColor()
    local r, cosrz, sinrz
    for _, c in ipairs(self.circle) do
        r = c.r
        cosrz = cos(c.rz)
        sinrz = sin(c.rz)
        SetImageState(c.img, "mul+add", Forbid(45 - c.z, 0, 20) / 20 * 120, self.rR, self.rG, self.rB)
        Render4V(c.img,
                c.x - r * cosrz - r * sinrz, c.y + r * cosrz - r * sinrz, c.z,
                c.x + r * cosrz - r * sinrz, c.y + r * cosrz + r * sinrz, c.z,
                c.x + r * cosrz + r * sinrz, c.y - r * cosrz + r * sinrz, c.z,
                c.x - r * cosrz + r * sinrz, c.y - r * cosrz - r * sinrz, c.z)
    end
    for _, c in ipairs(self.bright) do
        r = c.s
        SetImageState(c.img, "mul+add", Forbid(45 - c.z, 0, 20) / 20 * 100, self.rR, self.rG, self.rB)
        Render4V(c.img, c.x - r, c.y + r, c.z, c.x + r, c.y + r, c.z, c.x + r, c.y - r, c.z, c.x - r, c.y - r, c.z)
    end
    for _, c in ipairs(self.building) do
        draw_circle(c.x, c.y, c.z, c.radius, c.width, c.rz, c.rot, Forbid(45 - c.z, 0, 20) / 20 * 80, self.rR, self.rG, self.rB)
    end
    SetViewMode 'world'

end