local SetViewMode = SetViewMode
local RenderTexture = RenderTexture
local Color = Color
local background = background
local cos, sin = cos, sin

BG_7 = Class(background)

function BG_7:init()
    local path = "assets\\background\\7\\"
    LoadImageFromFile("185_sun", path .. "sun.png")
    LoadImageFromFile("185_sun2", path .. "sun2.png")
    LoadTexture2("185_deco1", path .. "deco1.png")
    LoadTexture2("185_deco2", path .. "deco2.png")

    background.init(self, false)
    Set3D('eye', 0, 4, -1.9)
    Set3D('at', 0, 0, 0)
    Set3D('up', 0, 1, 0)
    Set3D('fovy', 0.8)
    Set3D('z', 0.01, 100)
    Set3D('fog', 4, 6, Color(255, 0, 0, 0))
    self.speed = 0.1
    self.zos = 0
    self.leaf = CreateFallLeaf({ { -3, 3 }, { 1.5, 2.5 }, { 3, 5 }, { 1, 2 }, { -0.002, 0.002 }, { -0.005, -0.01 }, { -0.005, -0.01 } },
            10, 0.1, "mul+add", 100, { 218, 112, 214 },
            "small_leaf", function(self)
                return self.y < -1 or self.z < lstg.view3d.eye[3] - 1
            end, { count = 13, xRange = { -3, 3 }, yRange = { 0, 2.5 }, zRange = { -5, 3 } }, true)
    task.New(self, function()
        local a = 0
        local c = 0
        local v = lstg.view3d
        while true do
            v.up[1] = 0.1 * sin(a / 10)
            v.up[3] = sin(a / 15)
            a = a + sin(c) * 0.6
            c = min(c + 1, 90)
            task.Wait()
        end
    end)
end
function BG_7:frame()
    task.Do(self)
    self.zos = self.zos - self.speed
    self.leaf.speed = self.speed * 10
    self.leaf:frame()
end

function BG_7:render()
    SetViewMode '3d'
    background.ClearToFogColor()
    local z = self.zos
    local color, size
    local uv1, uv2, uv3, uv4 = {}, {}, {}, {}
    uv1[1], uv1[2], uv1[3] = -4, 0, 16
    uv2[1], uv2[2], uv2[3] = 4, 0, 16
    uv3[1], uv3[2], uv3[3] = 4, 0, -4
    uv4[1], uv4[2], uv4[3] = -4, 0, -4

    size = 1.3
    color = Color(50, 255, 255, 255)
    uv1[6], uv2[6], uv3[6], uv4[6] = color, color, color, color
    uv1[4], uv1[5] = 0, z
    uv2[4], uv2[5] = 1024 / size, z
    uv3[4], uv3[5] = 1024 / size, z + 2560 / size
    uv4[4], uv4[5] = 0, z + 2560 / size
    RenderTexture("185_deco2", "mul+add", uv1, uv2, uv3, uv4)

    size = 0.8
    color = Color(25 + 10 * sin(self.timer / 2), 255, 255, 255)
    uv1[6], uv2[6], uv3[6], uv4[6] = color, color, color, color
    uv1[4], uv1[5] = 0 - z, z * 2
    uv2[4], uv2[5] = 1024 / size - z, z * 2
    uv3[4], uv3[5] = 1024 / size - z, z * 2 + 2560 / size
    uv4[4], uv4[5] = 0 - z, z * 2 + 2560 / size
    RenderTexture("185_deco1", "mul+add", uv1, uv2, uv3, uv4)

    size = 1.3
    color = Color(120 + 50 * sin(self.timer / 2), 255, 255, 255)
    uv1[6], uv2[6], uv3[6], uv4[6] = color, color, color, color
    uv1[4], uv1[5] = 0 + z, z * 2
    uv2[4], uv2[5] = 1024 / size + z, z * 2
    uv3[4], uv3[5] = 1024 / size + z, z * 2 + 2560 / size
    uv4[4], uv4[5] = 0 + z, z * 2 + 2560 / size
    RenderTexture("185_deco1", "mul+add", uv1, uv2, uv3, uv4)

    size = 1
    color = Color(150, 255, 255, 255)
    uv1[6], uv2[6], uv3[6], uv4[6] = color, color, color, color
    uv1[4], uv1[5] = 0, z
    uv2[4], uv2[5] = 1024 / size, z
    uv3[4], uv3[5] = 1024 / size, z + 2560 / size
    uv4[4], uv4[5] = 0, z + 2560 / size
    RenderTexture("185_deco2", "mul+add", uv1, uv2, uv3, uv4)
    self.leaf:render()
    SetViewMode 'world'

end
