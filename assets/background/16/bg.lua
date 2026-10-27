BG_16 = Class(background)
local SetViewMode = SetViewMode
local RenderTexture = RenderTexture
local Color = Color
local Set3D = Set3D
local cos, sin = cos, sin
local min, max = min, max
local background = background
local Render4V = Render4V



function BG_16:init()
    local path = "assets\\background\\16\\"
    LoadTexture2("bg_16_winter1", path .. "winter1.png")
    LoadImageFromFile("bg_16_winter2", path .. "winter2.png")
    LoadTexture2("bg_16_winter3", path .. "winter3.png")


    background.init(self, false)
    self.float = background.RanFloat
    self.int = background.RanInt
    self.sign = background.RanSign

    Set3D('z', 0.1, 24)
    Set3D('eye', 0, 3.8, -1)
    Set3D('at', 0, 1, 3)
    Set3D('up', 0, 1, 0)
    Set3D('fovy', 0.1)
    Set3D('fog', 2, 8, Color(100, 20, 60, 100))
    self.speed = 0.025
    self.zos = 0
    self.cloud = {}
    function self:create_cloud(x, y, z, alpha)
        table.insert(self.cloud, { x = x, y = y, z = z, alpha = 0, talpha = alpha })
        table.sort(self.cloud, function(a, b)
            return a.z > b.z
        end)
    end
    self.scale = 0.1
    local f = background.RanFloat
    for _ = 1, 60 do
        self:create_cloud(f(self, -3, 3), f(self, 2.5, 3.5), f(self, 0, 7), f(self, 30, 40))
    end
    task.New(self, function()
        task.New(self, function()
            for i = 1, 90 do
                lstg.view3d.fovy = 0.1 + 0.6 * sin(i)
                task.Wait()
            end
        end)
        task.New(self, function()
            local t, s = 0, 0
            while true do
                s = s + sin(t)
                lstg.view3d.eye[1] = sin(s / 4)
                lstg.view3d.at[3] = 3 + sin(s / 3) * 0.5
                t = min(t + 1, 90)
                task.Wait()
            end
        end)
    end)
end
function BG_16:frame()
    task.Do(self)
    if self.timer % math.ceil(self.scale / self.speed) == 0 then
        local f = background.RanFloat
        self:create_cloud(f(self, -3, 3), f(self, 2.5, 3.5), f(self, 7, 9), f(self, 30, 40))
    end
    local c
    for i = #self.cloud, 1, -1 do
        c = self.cloud[i]
        c.z = c.z - self.speed * 0.4
        c.alpha = min(c.talpha, c.alpha + c.talpha / 20)
        if c.z < -2 then
            c.alpha = max(0, c.alpha - c.talpha / 10)
            if c.alpha == 0 then
                table.remove(self.cloud, i)
            end
        end
    end
    self.zos = self.zos - self.speed*100
end
function BG_16:render()
    SetViewMode '3d'
    background.ClearToFogColor()
    local color
    local z = self.zos
    local uv1, uv2, uv3, uv4 = {}, {}, {}, {}
    color = Color(255, 255, 255, 255)
    uv1[6], uv2[6], uv3[6], uv4[6] = color, color, color, color
    uv1[1], uv1[2], uv1[3], uv1[4], uv1[5] = -8, 0, 18, 0, z * 1.5
    uv2[1], uv2[2], uv2[3], uv2[4], uv2[5] = 8, 0, 18, 2048, z * 1.5
    uv3[1], uv3[2], uv3[3], uv3[4], uv3[5] = 8, 0, -6, 2048, 3072 + z * 1.5
    uv4[1], uv4[2], uv4[3], uv4[4], uv4[5] = -8, 0, -6, 0, 3072 + z * 1.5
    RenderTexture("bg_16_winter3", "", uv1, uv2, uv3, uv4)
    color = Color(100, 255, 255, 255)
    uv1[6], uv2[6], uv3[6], uv4[6] = color, color, color, color
    uv1[1], uv1[2], uv1[3], uv1[4], uv1[5] = -8, 1, 18, 0, z
    uv2[1], uv2[2], uv2[3], uv2[4], uv2[5] = 8, 1, 18, 2048, z
    uv3[1], uv3[2], uv3[3], uv3[4], uv3[5] = 8, 1, -6, 2048, 3072 + z
    uv4[1], uv4[2], uv4[3], uv4[4], uv4[5] = -8, 1, -6, 0, 3072 + z
    RenderTexture("bg_16_winter1", "mul+add", uv1, uv2, uv3, uv4)
    color = Color(30, 255, 255, 255)
    uv1[6], uv2[6], uv3[6], uv4[6] = color, color, color, color
    uv1[1], uv1[2], uv1[3], uv1[4], uv1[5] = -8, 2, 18, 0 + 256, z * 0.3
    uv2[1], uv2[2], uv2[3], uv2[4], uv2[5] = 8, 2, 18, 2048 + 256, z * 0.3
    uv3[1], uv3[2], uv3[3], uv3[4], uv3[5] = 8, 2, -6, 2048 + 256, 3072 + z * 0.3
    uv4[1], uv4[2], uv4[3], uv4[4], uv4[5] = -8, 2, -6, 0 + 256, 3072 + z * 0.3
    RenderTexture("bg_16_winter1", "mul+add", uv1, uv2, uv3, uv4)

    local v = SQRT2_2
    for _, c in ipairs(self.cloud) do
        SetImageState("bg_16_winter2", "", c.alpha, 255, 255, 255)
        Render4V("bg_16_winter2",
                c.x - 1, c.y + v, c.z + v,
                c.x + 1, c.y + v, c.z + v,
                c.x + 1, c.y - v, c.z - v,
                c.x - 1, c.y - v, c.z - v)
    end
    SetViewMode 'world'
end
