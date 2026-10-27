local SetViewMode = SetViewMode
local Color = Color
local Set3D = Set3D
local table = table
local cos, sin = cos, sin
local background = background
local SetImageState = SetImageState
local Render4V = Render4V



BG_8 = Class(background)

function BG_8:init()
    local path = "assets\\background\\8\\"
    LoadImageFromFile("bg_8_building1", path .. "building1.png")
    LoadImageFromFile("bg_8_building2", path .. "building2.png")
    LoadImageFromFile("bg_8_building3", path .. "building3.png")
    LoadImageFromFile("bg_8_building21", path .. "building21.png")
    LoadImageFromFile("bg_8_building22", path .. "building22.png")
    LoadImageFromFile("bg_8_building23", path .. "building23.png")

    local fogcol = Color(100, 18, 0, 50)
    background.init(self, false)
    self.float = background.RanFloat
    self.int = background.RanInt
    self.sign = background.RanSign
    self.imgs = "bg_8_building"
    Set3D('eye', 0, 0, 9)
    Set3D('at', 0, 5, 0)
    Set3D('up', 0, 1, 0)
    Set3D('z', 0.1, 50)
    Set3D('fovy', 1)
    Set3D('fog', 0, 0.1, fogcol)
    self.buling = { 218, 112, 214 }
    self.leaf_color = { 150, 64, 150 }
    self.color = { 70, 70, 70 }
    task.New(self, function()
        while true do
            task.Wait(180)
            for i = 1, 90 do
                if (i >= 1 and i <= 4) or (i >= 10 and i <= 13) then
                    self.color = self.buling
                else
                    self.color = { 160 - i, 160 - i, 160 - i }
                end
                task.Wait()
            end
        end
    end)
    self.speed = 0.02
    self.yos = 0
    task.New(self, function()
        for i = 1, 90 do
            Set3D('fog', 3 * sin(i), 0.1 + 3 * sin(i), fogcol)
            task.Wait()
        end
        for i = 1, 180 do
            Set3D('fog', 3 + 2.2 * sin(i / 2), 3.1 + 5.2 * sin(i / 2), fogcol)
            task.Wait()
        end
    end)
    self.leaf = {}
    for y = 13, 0, -0.3 do
        table.insert(self.leaf,
                { x = self:float(-9, 9), y = self:float(y - 0.1, y + 0.1), z = self:float(-9, 9),
                  prot = { self:float(0, 360), self:float(0, 360), self:float(0, 360) },
                  pomega = { self:float(1, 2) * self:sign(),
                             self:float(1, 2) * self:sign(),
                             self:float(1, 2) * self:sign() },
                  vx = 0, vy = -self:float(self.speed, self.speed * 2), vz = 0 })
    end
end

function BG_8:frame()
    task.Do(self)
    local speed = self.timer / 6
    local d = lstg.view3d
    d.eye[3] = cos(speed) * 9
    d.eye[1] = sin(speed) * 9
    d.eye[2] = -1.5 + cos(speed / 1.8) * 1.5
    d.up[1] = sin(speed / 3) * 0.1
    d.at[1] = sin(speed / 4) * 5
    self.yos = self.yos + self.speed
    self.yos = self.yos % 12
    if self.timer % 5 == 0 and self.speed > 0 then
        table.insert(self.leaf,
                { x = self:float(-9, 9), y = self:float(12, 13), z = self:float(-9, 9),
                  prot = { self:float(0, 360), self:float(0, 360), self:float(0, 360) },
                  pomega = { self:float(1, 2) * self:sign(),
                             self:float(1, 2) * self:sign(),
                             self:float(1, 2) * self:sign() },
                  vx = 0, vy = -self:float(self.speed * 0.5, self.speed), vz = 0 })
    end
    local l
    for i = #self.leaf, 1, -1 do
        l = self.leaf[i]
        l.x = l.x + l.vx
        l.y = l.y + l.vy
        l.z = l.z + l.vz
        l.prot[1] = l.prot[1] + l.pomega[1]
        l.prot[2] = l.prot[2] + l.pomega[2]
        l.prot[3] = l.prot[3] + l.pomega[3]
        if l.y <= -10 then
            table.remove(self.leaf, i)
        end
    end
end

function BG_8:render()
    SetViewMode '3d'
    background.ClearToFogColor()
    local bg = BG_8
    local j = 0
    for y = -15, 21, 6 do
        bg.draw_pillar(self, 0, 0, y + self.yos, y + 3 + self.yos, 5)
        bg.draw_pillar(self, 0, 0, y + 3 + self.yos, y + 6 + self.yos, 5, true, j * 45, unpack(self.color))
        j = j % 2 + 1
    end
    SetImageState("small_leaf", "mul+add", 100, unpack(self.leaf_color))
    local Cos, Sin = Cos, Sin
    for _, l in ipairs(self.leaf) do
        Render4V("small_leaf",
                l.x - Cos(l.prot[1]) * 0.1 - Cos(l.prot[3]) * 0.1, l.y - Sin(l.prot[1]) * 0.1 - Cos(l.prot[2]) * 0.1, l.z - Sin(l.prot[2]) * 0.1 - Sin(l.prot[3]) * 0.1,
                l.x - Sin(l.prot[1]) * 0.1 - Sin(l.prot[3]) * 0.1, l.y + Cos(l.prot[1]) * 0.1 - Sin(l.prot[2]) * 0.1, l.z + Cos(l.prot[2]) * 0.1 + Cos(l.prot[3]) * 0.1,
                l.x + Cos(l.prot[1]) * 0.1 + Cos(l.prot[3]) * 0.1, l.y + Sin(l.prot[1]) * 0.1 + Cos(l.prot[2]) * 0.1, l.z + Sin(l.prot[2]) * 0.1 + Sin(l.prot[3]) * 0.1,
                l.x + Sin(l.prot[1]) * 0.1 + Sin(l.prot[3]) * 0.1, l.y - Cos(l.prot[1]) * 0.1 + Sin(l.prot[2]) * 0.1, l.z - Cos(l.prot[2]) * 0.1 - Cos(l.prot[3]) * 0.1)
    end
    SetViewMode 'world'


end
local SQRT2_2 = SQRT2_2
local _t = {}
for i = 1, 16 do
    _t[i * 22.5] = cos(i * 22.5)
end
local function Cos(t)
    t = (t - 1) % 360 + 1
    return _t[t]
end
local function Sin(t)
    t = (t + 90 - 1) % 360 + 1
    return _t[t]
end

function BG_8:draw_pillar(x, z, y1, y2, r, window, rot, R, G, B)
    R, G, B = R or 255, G or 255, B or 255
    local a = rot or 0
    local d = r * Cos(22.5)
    local eyex, eyez = lstg.view3d.eye[1] - x, lstg.view3d.eye[3] - z
    local blk
    for i = 1, 8 do
        if d * Cos(a) * eyex + d * Sin(a) * eyez - d * d > 0 then
            blk = (1 - Cos(a) * SQRT2_2 + Sin(a) * SQRT2_2) * 0.3 + 0.1
            if window and i % 2 == 0 then
                SetImageState(self.imgs .. "2", '', 255, 255 * blk, 255 * blk, 255 * blk)
                Render4V(self.imgs .. "2",
                        x + r * Cos(a - 22.5), y2, z + r * Sin(a - 22.5), x + r * Cos(a + 22.5), y2, z + r * Sin(a + 22.5),
                        x + r * Cos(a + 22.5), y1, z + r * Sin(a + 22.5), x + r * Cos(a - 22.5), y1, z + r * Sin(a - 22.5))
                SetImageState(self.imgs .. "3", '', 255, R * 0.8, G * 0.8, B * 0.8)
                Render4V(self.imgs .. "3",
                        x + r * Cos(a - 22.5), y2, z + r * Sin(a - 22.5), x + r * Cos(a + 22.5), y2, z + r * Sin(a + 22.5),
                        x + r * Cos(a + 22.5), y1, z + r * Sin(a + 22.5), x + r * Cos(a - 22.5), y1, z + r * Sin(a - 22.5))
            else
                SetImageState(self.imgs .. "1", '', 255, 255 * blk, 255 * blk, 255 * blk)
                Render4V(self.imgs .. "1",
                        x + r * Cos(a - 22.5), y2, z + r * Sin(a - 22.5), x + r * Cos(a + 22.5), y2, z + r * Sin(a + 22.5),
                        x + r * Cos(a + 22.5), y1, z + r * Sin(a + 22.5), x + r * Cos(a - 22.5), y1, z + r * Sin(a - 22.5))
            end
        end
        a = a + 45
    end
end