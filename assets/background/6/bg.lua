local SetViewMode = SetViewMode
local RenderTexture = RenderTexture
local Color = Color
local background = background
local cos, sin = cos, sin


BG_6 = Class(background)

function BG_6:init()
    local path = "assets\\background\\6\\"
    LoadTexture2("bg_6_floor1", path .. "floor1.png")
    LoadTexture2("bg_6_floor2", path .. "floor2.png")

    background.init(self, false)
    Set3D('eye', 0, 4, -1.9)
    Set3D('at', 0, 0, 1)
    Set3D('up', 0, 1, 0)
    Set3D('fovy', 0.86)
    Set3D('z', 0.01, 100)
    Set3D('fog', 5.5, 8.3, Color(255, 20, 0, 0))
    self.speed = 1.3
    self.zos = 0
end
function BG_6:frame()
    task.Do(self)
    self.zos = self.zos - self.speed
    local t = self.timer
    t = t * sin(min(90, t / 2))
    Set3D('at', sin(t / 3), 1 - cos(t / 4), 1)
    Set3D('up', sin(t / 4) * 0.5, 1, 0)
end

function BG_6:render()
    SetViewMode '3d'
    background.ClearToFogColor()
    local z = self.zos
    local color = Color(255, 180 + 70 * cos(self.timer / 3), 255, 190 + 60 * sin(self.timer / 2))
    local uv1, uv2, uv3, uv4 = {}, {}, {}, {}
    uv1[6], uv2[6], uv3[6], uv4[6] = color, color, color, color

    uv1[4], uv1[5] = 0, z
    uv2[4], uv2[5] = 512, z
    uv3[4], uv3[5] = 512, z + 2560
    uv4[4], uv4[5] = 0, z + 2560

    uv1[2], uv1[3] = 0, 16
    uv2[2], uv2[3] = 0, 16
    uv3[2], uv3[3] = 0, -4
    uv4[2], uv4[3] = 0, -4

    uv1[1], uv2[1], uv3[1], uv4[1] = -2, 2, 2, -2
    RenderTexture("bg_6_floor1", "", uv1, uv2, uv3, uv4)
    uv1[1], uv2[1], uv3[1], uv4[1] = 6, 2, 2, 6
    RenderTexture("bg_6_floor2", "", uv1, uv2, uv3, uv4)
    uv1[1], uv2[1], uv3[1], uv4[1] = -2, -6, -6, -2
    RenderTexture("bg_6_floor2", "", uv1, uv2, uv3, uv4)

    SetViewMode 'world'
end
