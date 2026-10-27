local SetViewMode = SetViewMode
local RenderTexture = RenderTexture
local Color = Color
local background = background
local cos, sin = cos, sin


BG_14 = Class(background)

function BG_14:init()
    local path = "assets\\background\\14\\"
    LoadTexture2("bg_14_spring1", path .. "spring1.png")
    LoadTexture2("bg_14_spring2", path .. "spring2.png")
    LoadTexture2("bg_14_spring3", path .. "spring3.png")
    LoadTexture2("bg_14_spring4", path .. "spring4.png")

    background.init(self, false)
    Set3D('eye', 0, 5, 0)
    Set3D('at', 0, 1, 3)
    Set3D('up', 0, 1, 0)
    Set3D('fovy', 0.8)
    Set3D('z', 0.1, 100)
    Set3D('fog', 2, 10, Color(100, 40, 10, 30))
    self.speed = 1
    self.zos = 0
    self.leaf = CreateFallLeaf({ { -4, 3 }, { 0, 2.5 }, { 7, 9 }, { 0.5, 1 }, { -0.002, 0.002 }, { -0.002, -0.002 }, { -0.01, -0.02 } },
            16, 0.3, "mul+add", 200, { 250, 250, 250 },
            "cherry_bullet", function(self)
                return self.z < lstg.view3d.eye[3] - 1
            end, { count = 30, xRange = { -4, 4 }, yRange = { 0, 2.5 }, zRange = { -1, 7 } }, true)
    task.New(self, function()
        local t, s = 0, 0
        while true do
            s = s + sin(t)
            lstg.view3d.eye[1] = sin(s / 4) * 2
            lstg.view3d.at[3] = 3 + sin(s / 3) * 0.5
            lstg.view3d.up[1] = sin(s / 5) * 0.2
            t = min(t + 1, 90)
            task.Wait()
        end
    end)
end
function BG_14:frame()
    if not self.freeze then
        task.Do(self)
        self.zos = self.zos - self.speed
        self.leaf:frame()
        self.leaf.speed = self.speed
    end
end

function BG_14:render()
    SetViewMode '3d'
    background.ClearToFogColor()
    local color
    local z = self.zos
    local uv1, uv2, uv3, uv4 = {}, {}, {}, {}
    color = Color(255, 255, 255, 255)
    uv1[6], uv2[6], uv3[6], uv4[6] = color, color, color, color
    uv1[1], uv1[2], uv1[3], uv1[4], uv1[5] = -4, 0, 14, 0, z
    uv2[1], uv2[2], uv2[3], uv2[4], uv2[5] = 0, 0, 14, 511, z
    uv3[1], uv3[2], uv3[3], uv3[4], uv3[5] = 0, 0, -6, 511, 2560 + z
    uv4[1], uv4[2], uv4[3], uv4[4], uv4[5] = -4, 0, -6, 0, 2560 + z
    RenderTexture("bg_14_spring1", "", uv1, uv2, uv3, uv4)
    uv1[1], uv1[2], uv1[3], uv1[4], uv1[5] = 4, 0, 14, 0, z
    uv2[1], uv2[2], uv2[3], uv2[4], uv2[5] = 0, 0, 14, 511, z
    uv3[1], uv3[2], uv3[3], uv3[4], uv3[5] = 0, 0, -6, 511, 2560 + z
    uv4[1], uv4[2], uv4[3], uv4[4], uv4[5] = 4, 0, -6, 0, 2560 + z
    RenderTexture("bg_14_spring1", "", uv1, uv2, uv3, uv4)

    for i = 2, 4 do
        local img = "bg_14_spring" .. i
        uv1[1], uv1[2], uv1[3], uv1[4], uv1[5] = -4, 0.2 * i, 14, 0, z + 512
        uv2[1], uv2[2], uv2[3], uv2[4], uv2[5] = 0, 0.2 * i, 14, 511, z + 512
        uv3[1], uv3[2], uv3[3], uv3[4], uv3[5] = 0, 0.2 * i, -6, 511, 2560 + z + 512
        uv4[1], uv4[2], uv4[3], uv4[4], uv4[5] = -4, 0.2 * i, -6, 0, 2560 + z + 512
        RenderTexture(img, "", uv1, uv2, uv3, uv4)
        uv1[1], uv1[2], uv1[3], uv1[4], uv1[5] = -4, 0.2 * i, 14, 0, z + 512
        uv2[1], uv2[2], uv2[3], uv2[4], uv2[5] = -8, 0.2 * i, 14, 511, z + 512
        uv3[1], uv3[2], uv3[3], uv3[4], uv3[5] = -8, 0.2 * i, -6, 511, 2560 + z + 512
        uv4[1], uv4[2], uv4[3], uv4[4], uv4[5] = -4, 0.2 * i, -6, 0, 2560 + z + 512
        RenderTexture(img, "", uv1, uv2, uv3, uv4)
        uv1[1], uv1[2], uv1[3], uv1[4], uv1[5] = 4, 0.2 * i, 14, 0, z
        uv2[1], uv2[2], uv2[3], uv2[4], uv2[5] = 0, 0.2 * i, 14, 511, z
        uv3[1], uv3[2], uv3[3], uv3[4], uv3[5] = 0, 0.2 * i, -6, 511, 2560 + z
        uv4[1], uv4[2], uv4[3], uv4[4], uv4[5] = 4, 0.2 * i, -6, 0, 2560 + z
        RenderTexture(img, "", uv1, uv2, uv3, uv4)
        uv1[1], uv1[2], uv1[3], uv1[4], uv1[5] = 4, 0.2 * i, 14, 0, z
        uv2[1], uv2[2], uv2[3], uv2[4], uv2[5] = 8, 0.2 * i, 14, 511, z
        uv3[1], uv3[2], uv3[3], uv3[4], uv3[5] = 8, 0.2 * i, -6, 511, 2560 + z
        uv4[1], uv4[2], uv4[3], uv4[4], uv4[5] = 4, 0.2 * i, -6, 0, 2560 + z
        RenderTexture(img, "", uv1, uv2, uv3, uv4)
        uv1[1], uv1[2], uv1[3], uv1[4], uv1[5] = -4, 1 + 0.2 * i, 14, 0, z
        uv2[1], uv2[2], uv2[3], uv2[4], uv2[5] = 0, 1 + 0.2 * i, 14, 511, z
        uv3[1], uv3[2], uv3[3], uv3[4], uv3[5] = 0, 1 + 0.2 * i, -6, 511, 2560 + z
        uv4[1], uv4[2], uv4[3], uv4[4], uv4[5] = -4, 1 + 0.2 * i, -6, 0, 2560 + z
        RenderTexture(img, "", uv1, uv2, uv3, uv4)
        uv1[1], uv1[2], uv1[3], uv1[4], uv1[5] = -4, 1 + 0.2 * i, 14, 0, z
        uv2[1], uv2[2], uv2[3], uv2[4], uv2[5] = -8, 1 + 0.2 * i, 14, 511, z
        uv3[1], uv3[2], uv3[3], uv3[4], uv3[5] = -8, 1 + 0.2 * i, -6, 511, 2560 + z
        uv4[1], uv4[2], uv4[3], uv4[4], uv4[5] = -4, 1 + 0.2 * i, -6, 0, 2560 + z
        RenderTexture(img, "", uv1, uv2, uv3, uv4)
        uv1[1], uv1[2], uv1[3], uv1[4], uv1[5] = 4, 1 + 0.2 * i, 14, 0, z + 512
        uv2[1], uv2[2], uv2[3], uv2[4], uv2[5] = 0, 1 + 0.2 * i, 14, 511, z + 512
        uv3[1], uv3[2], uv3[3], uv3[4], uv3[5] = 0, 1 + 0.2 * i, -6, 511, 2560 + z + 512
        uv4[1], uv4[2], uv4[3], uv4[4], uv4[5] = 4, 1 + 0.2 * i, -6, 0, 2560 + z + 512
        RenderTexture(img, "", uv1, uv2, uv3, uv4)
        uv1[1], uv1[2], uv1[3], uv1[4], uv1[5] = 4, 1 + 0.2 * i, 14, 0, z + 512
        uv2[1], uv2[2], uv2[3], uv2[4], uv2[5] = 8, 1 + 0.2 * i, 14, 511, z + 512
        uv3[1], uv3[2], uv3[3], uv3[4], uv3[5] = 8, 1 + 0.2 * i, -6, 511, 2560 + z + 512
        uv4[1], uv4[2], uv4[3], uv4[4], uv4[5] = 4, 1 + 0.2 * i, -6, 0, 2560 + z + 512
        RenderTexture(img, "", uv1, uv2, uv3, uv4)
    end

    self.leaf:render()
    SetViewMode 'world'
end
