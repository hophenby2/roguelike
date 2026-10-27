local SetViewMode = SetViewMode
local RenderTexture = RenderTexture
local Color = Color
local background = background
local cos, sin = cos, sin


BG_5 = Class(background)

function BG_5:init()
    local path = "assets\\background\\5\\"
    LoadTexture2("bg_5_cloud", path .. "cloud.png")
    LoadTexture2("bg_5_floor1", path .. "floor1.png")
    LoadTexture2("bg_5_floor2", path .. "floor2.png")
    LoadTexture2("bg_5_grass", path .. "grass.png")
    LoadTexture2("bg_5_wall", path .. "wall.png")

    background.init(self, false)
    Set3D('eye', 6, 14, -3)
    Set3D('at', 10, 6, 0)
    Set3D('up', 0, 1, 0)
    Set3D('fovy', 1)
    Set3D('z', 0.01, 100)
    Set3D('fog', 8, 20, Color(255, 0, 0, 0))
    self.speed2 = 1
    self.speed = 0.7
    self.zos = 0
    self.zos2 = 0
    self.maxspeed = 2.5
    task.New(self, function()
        local a, c = 0, 0
        local d = lstg.view3d
        while true do
            if c < 90 then
                c = c + 1
            end
            a = a + sin(c) * min(self.speed, 0.3)
            d.eye[1] = 10 + 4 * cos(a + 180)
            d.eye[2] = 14 + sin(a / 3.6)
            d.at[2] = 6 + 3 * sin(a / 2)
            d.up[1] = sin(a / 6)
            self.speed = min(self.maxspeed, self.speed + 0.001)
            task.Wait()
        end
    end)
end
function BG_5:frame()
    task.Do(self)
    self.zos = self.zos - self.speed
    self.zos2 = self.zos2 - self.speed2
end

function BG_5:render()
    SetViewMode '3d'
    background.ClearToFogColor()

    local z = self.zos
    local zc = z * 2 + self.zos2
    local __z = z * 4
    local uv1, uv2, uv3, uv4 = {}, {}, {}, {}
    local color = Color(255, 255, 255, 255)
    uv1[6], uv2[6], uv3[6], uv4[6] = color, color, color, color

    uv1[2], uv1[3], uv1[4], uv1[5] = 0, 20, 0, z
    uv2[2], uv2[3], uv2[4], uv2[5] = 0, 20, 512, z
    uv3[2], uv3[3], uv3[4], uv3[5] = 0, -20, 512, z + 2560
    uv4[2], uv4[3], uv4[4], uv4[5] = 0, -20, 0, z + 2560
    for _, p in ipairs({ 0, 20 }) do
        uv1[1] = p - 4
        uv2[1] = p + 4
        uv3[1] = p + 4
        uv4[1] = p - 4
        RenderTexture("bg_5_grass", "", uv1, uv2, uv3, uv4)
    end--草道

    color = Color(255, 100, 100, 100)
    uv1[6], uv2[6], uv3[6], uv4[6] = color, color, color, color

    uv1[2], uv1[3], uv1[4], uv1[5] = 0, 20, 0, z
    uv2[2], uv2[3], uv2[4], uv2[5] = 5, 20, 320, z
    uv3[2], uv3[3], uv3[4], uv3[5] = 5, -20, 320, z + 1280
    uv4[2], uv4[3], uv4[4], uv4[5] = 0, -20, 0, z + 1280
    for _, p in ipairs({ 4, 16 }) do
        uv1[1] = p
        uv2[1] = p
        uv3[1] = p
        uv4[1] = p
        RenderTexture("bg_5_wall", "", uv1, uv2, uv3, uv4)
    end--高墙

    color = Color(min(abs(lstg.view3d.eye[2] - 1) * 50, 170), 250, 128, 114)
    uv1[6], uv2[6], uv3[6], uv4[6] = color, color, color, color

    uv1[1], uv1[2], uv1[3], uv1[4], uv1[5] = -4, 1, 20, 0, zc
    uv2[1], uv2[2], uv2[3], uv2[4], uv2[5] = 26, 1, 20, 960, zc
    uv3[1], uv3[2], uv3[3], uv3[4], uv3[5] = 26, 1, -20, 960, zc + 1280
    uv4[1], uv4[2], uv4[3], uv4[4], uv4[5] = -4, 1, -20, 0, zc + 1280
    RenderTexture("bg_5_cloud", "", uv1, uv2, uv3, uv4)--草上层的红云

    color = Color(255, 255, 255, 255)
    uv1[6], uv2[6], uv3[6], uv4[6] = color, color, color, color

    uv1[2], uv1[3], uv1[4], uv1[5] = 4.5, 20, 0, z
    uv2[2], uv2[3], uv2[4], uv2[5] = 4.5, 20, 69, z
    uv3[2], uv3[3], uv3[4], uv3[5] = 4.5, -20, 69, z + 1280
    uv4[2], uv4[3], uv4[4], uv4[5] = 4.5, -20, 0, z + 1280
    local j = 1
    for _, p in ipairs({ 5.25, 14.75 }) do
        uv1[1] = p - 0.75 * j
        uv2[1] = p + 0.75 * j
        uv3[1] = p + 0.75 * j
        uv4[1] = p - 0.75 * j
        RenderTexture("bg_5_floor2", "", uv1, uv2, uv3, uv4)
        j = -j
    end--板边
    uv1[2], uv1[3], uv1[4], uv1[5] = 4.5, 20, 0, __z
    uv2[2], uv2[3], uv2[4], uv2[5] = 4.5, 20, 512, __z
    uv3[2], uv3[3], uv3[4], uv3[5] = 4.5, -20, 512, __z + 5120
    uv4[2], uv4[3], uv4[4], uv4[5] = 4.5, -20, 0, __z + 5120
    for _, p in ipairs({ 8, 12 }) do
        uv1[1] = p - 2 * j
        uv2[1] = p + 2 * j
        uv3[1] = p + 2 * j
        uv4[1] = p - 2 * j
        RenderTexture("bg_5_floor1", "", uv1, uv2, uv3, uv4)
        j = -j
    end--板中

    color = Color(255, 100, 100, 100)
    uv1[6], uv2[6], uv3[6], uv4[6] = color, color, color, color

    uv1[2], uv1[3], uv1[4], uv1[5] = 5, 20, 0, z
    uv2[2], uv2[3], uv2[4], uv2[5] = 4.5, 20, 32, z
    uv3[2], uv3[3], uv3[4], uv3[5] = 4.5, -20, 32, z + 1280
    uv4[2], uv4[3], uv4[4], uv4[5] = 5, -20, 0, z + 1280
    for _, p in ipairs({ 4.5, 15.5 }) do
        uv1[1] = p
        uv2[1] = p
        uv3[1] = p
        uv4[1] = p
        RenderTexture("bg_5_wall", "", uv1, uv2, uv3, uv4)
    end--墙边

    color = Color(255, 255, 255, 255)
    uv1[6], uv2[6], uv3[6], uv4[6] = color, color, color, color

    uv1[2], uv1[3], uv1[4], uv1[5] = 5, 20, 0, z
    uv2[2], uv2[3], uv2[4], uv2[5] = 5, 20, 32, z
    uv3[2], uv3[3], uv3[4], uv3[5] = 5, -20, 32, z + 1280
    uv4[2], uv4[3], uv4[4], uv4[5] = 5, -20, 0, z + 1280
    for _, p in ipairs({ 4, 15.5 }) do
        uv1[1] = p
        uv2[1] = p + 0.5
        uv3[1] = p + 0.5
        uv4[1] = p
        RenderTexture("bg_5_wall", "", uv1, uv2, uv3, uv4)
    end--墙顶
    color = Color(min(abs(lstg.view3d.eye[2] - 5.5) * 50, 170), 218, 112, 214)
    uv1[6], uv2[6], uv3[6], uv4[6] = color, color, color, color

    uv1[1], uv1[2], uv1[3], uv1[4], uv1[5] = -8, 5.5, 16, 0, zc
    uv2[1], uv2[2], uv2[3], uv2[4], uv2[5] = 30, 5.5, 16, 1536, zc
    uv3[1], uv3[2], uv3[3], uv3[4], uv3[5] = 30, 5.5, -16, 1536, zc + 1024
    uv4[1], uv4[2], uv4[3], uv4[4], uv4[5] = -8, 5.5, -16, 0, zc + 1024
    RenderTexture("bg_5_cloud", "", uv1, uv2, uv3, uv4)--楼上层的紫云

    SetViewMode 'world'
end
