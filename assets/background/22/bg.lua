
local SetViewMode = SetViewMode
local RenderTexture = RenderTexture
local Color = Color
local Set3D = Set3D
local table = table
local cos, sin = cos, sin
local background = background
local SetImageState = SetImageState
local Render4V = Render4V
local Dist = Dist

BG_22 = Class(background)

function BG_22:init()
    local path = "assets\\background\\22\\"
    LoadTexture2("bg_22_floor", path .. "floor.png")
    LoadTexture2("bg_22_flower1", path .. "flower1.png")
    LoadTexture2("bg_22_flower2", path .. "flower2.png")

    background.init(self)
    self.float = background.RanFloat
    self.int = background.RanInt
    self.sign = background.RanSign
    Set3D('eye', 0, 4.4, -4.3)
    Set3D('at', 0, 1, 0)
    Set3D('up', 0, 1, 0)
    Set3D('z', 0.1, 100)
    Set3D('fovy', 1)
    Set3D('fog', 4.3, 12, Color(100, 50, 30, 65))
    self.speed = 1
    self.zos = 0
    self.leaf = {}
    for i = -5, 25, 0.2 do
        table.insert(self.leaf, { x = self:float(-3, 3), y = self:float(0, 2), z = self:float(i - 1, i + 1),
                                  prot = { self:float(0, 360), self:float(0, 360), self:float(0, 360) },
                                  pomega = { self:float(0.5, 1) * self:sign(), self:float(0.5, 1) * self:sign(), self:float(0.5, 1) * self:sign() },
                                  vx = self:float(-0.002, 0.002), vy = -self:float(-0.002, 0.002), vz = -self:float(0.02, 0.04) })
    end
end
function BG_22:frame()
    task.Do(self)
    self.zos = self.zos - self.speed
    if self.timer % 13 == 0 then
        table.insert(self.leaf, { x = self:float(-3, 3), y = self:float(0, 2), z = self:float(26, 24),
                                  prot = { self:float(0, 360), self:float(0, 360), self:float(0, 360) },
                                  pomega = { self:float(0.5, 1) * self:sign(), self:float(0.5, 1) * self:sign(), self:float(0.5 * 10, 1) * self:sign() },
                                  vx = self:float(-0.002, 0.002), vy = self:float(-0.002, 0.002), vz = -self:float(0.02, 0.04) })
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
        if l.z <= -10 then
            table.remove(self.leaf, i)
        end
    end
    Set3D('eye', sin(self.timer / 6) * 0.6, 4.4, -4.3)
end
function BG_22:render()
    SetViewMode '3d'
    background.ClearToFogColor()
    do
        local uv1, uv2, uv3, uv4 = {}, {}, {}, {}
        local color = Color(255, 255, 255, 255)
        local color2 = Color(100 * min(1, self.timer / 300), 250, 250, 250)
        local z = self.zos
        uv1[6], uv2[6], uv3[6], uv4[6] = color, color, color, color
        uv1[1], uv1[2], uv1[3], uv1[4], uv1[5] = -6, 0, 15, 0, z
        uv2[1], uv2[2], uv2[3], uv2[4], uv2[5] = 0, 0, 15, 511, z
        uv3[1], uv3[2], uv3[3], uv3[4], uv3[5] = 0, 0, -4, 511, 1279 + z
        uv4[1], uv4[2], uv4[3], uv4[4], uv4[5] = -6, 0, -4, 0, 1279 + z
        RenderTexture("bg_22_floor", "", uv1, uv2, uv3, uv4)
        uv1[1], uv1[2], uv1[3], uv1[4], uv1[5] = 6, 0, 15, 0, z
        uv2[1], uv2[2], uv2[3], uv2[4], uv2[5] = 0, 0, 15, 511, z
        uv3[1], uv3[2], uv3[3], uv3[4], uv3[5] = 0, 0, -4, 511, 1279 + z
        uv4[1], uv4[2], uv4[3], uv4[4], uv4[5] = 6, 0, -4, 0, 1279 + z
        RenderTexture("bg_22_floor", "", uv1, uv2, uv3, uv4)
        uv1[6], uv2[6], uv3[6], uv4[6] = color2, color2, color2, color2
        uv1[1], uv1[2], uv1[3], uv1[4], uv1[5] = -6, 0.4, 15, 0, z * 0.8 + 15
        uv2[1], uv2[2], uv2[3], uv2[4], uv2[5] = 6, 0.4, 15, 820, z * 0.8 + 15
        uv3[1], uv3[2], uv3[3], uv3[4], uv3[5] = 6, 0.4, -4, 820, 1130 + z * 0.8
        uv4[1], uv4[2], uv4[3], uv4[4], uv4[5] = -6, 0.4, -4, 0, 1130 + z * 0.8
        RenderTexture("bg_22_flower1", "", uv1, uv2, uv3, uv4)
        uv1[1], uv1[2], uv1[3], uv1[4], uv1[5] = -6, 0.3, 15, 0, z * 0.88
        uv2[1], uv2[2], uv2[3], uv2[4], uv2[5] = 6, 0.3, 15, 820, z * 0.88
        uv3[1], uv3[2], uv3[3], uv3[4], uv3[5] = 6, 0.3, -4, 820, 1115 + z * 0.88
        uv4[1], uv4[2], uv4[3], uv4[4], uv4[5] = -6, 0.3, -4, 0, 1115 + z * 0.88
        RenderTexture("bg_22_flower2", "", uv1, uv2, uv3, uv4)
        uv1[1], uv1[2], uv1[3], uv1[4], uv1[5] = -6, 0.2, 15, 0 - z * 0.4, z * 0.8
        uv2[1], uv2[2], uv2[3], uv2[4], uv2[5] = 6, 0.2, 15, 820 - z * 0.4, z * 0.8
        uv3[1], uv3[2], uv3[3], uv3[4], uv3[5] = 6, 0.2, -4, 820 - z * 0.4, 1115 + z * 0.8
        uv4[1], uv4[2], uv4[3], uv4[4], uv4[5] = -6, 0.2, -4, 0 - z * 0.4, 1115 + z * 0.8
        RenderTexture("bg_22_flower1", "", uv1, uv2, uv3, uv4)
        uv1[1], uv1[2], uv1[3], uv1[4], uv1[5] = -6, 0.1, 15, 0 - z * 0.3, z * 0.8 + 15
        uv2[1], uv2[2], uv2[3], uv2[4], uv2[5] = 6, 0.1, 15, 820 - z * 0.3, z * 0.8 + 15
        uv3[1], uv3[2], uv3[3], uv3[4], uv3[5] = 6, 0.1, -4, 820 - z * 0.3, 1130 + z * 0.8
        uv4[1], uv4[2], uv4[3], uv4[4], uv4[5] = -6, 0.1, -4, 0 - z * 0.3, 1130 + z * 0.8
        RenderTexture("bg_22_flower2", "", uv1, uv2, uv3, uv4)

    end
    local d, l
    for i = #self.leaf, 1, -1 do
        l = self.leaf[i]
        d = Dist(lstg.view3d.eye[1], lstg.view3d.eye[3], l.x, l.z)
        SetImageState("small_leaf", "mul+add", 60 * sin(max(0, 9 - d) * 10), 135, 206, 235)
        Render4V("small_leaf",
                l.x - cos(l.prot[1]) * 0.1 - cos(l.prot[3]) * 0.1, l.y - sin(l.prot[1]) * 0.1 - cos(l.prot[2]) * 0.1, l.z - sin(l.prot[2]) * 0.1 - sin(l.prot[3]) * 0.1,
                l.x - sin(l.prot[1]) * 0.1 - sin(l.prot[3]) * 0.1, l.y + cos(l.prot[1]) * 0.1 - sin(l.prot[2]) * 0.1, l.z + cos(l.prot[2]) * 0.1 + cos(l.prot[3]) * 0.1,
                l.x + cos(l.prot[1]) * 0.1 + cos(l.prot[3]) * 0.1, l.y + sin(l.prot[1]) * 0.1 + cos(l.prot[2]) * 0.1, l.z + sin(l.prot[2]) * 0.1 + sin(l.prot[3]) * 0.1,
                l.x + sin(l.prot[1]) * 0.1 + sin(l.prot[3]) * 0.1, l.y - cos(l.prot[1]) * 0.1 + sin(l.prot[2]) * 0.1, l.z - cos(l.prot[2]) * 0.1 - cos(l.prot[3]) * 0.1)
    end
    SetViewMode 'world'
end