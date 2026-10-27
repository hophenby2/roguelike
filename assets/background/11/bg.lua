BG_11 = Class(background)
local SetViewMode = SetViewMode
local RenderTexture = RenderTexture
local Color = Color
local Set3D = Set3D
local cos, sin = cos, sin
local min, max = min, max
local background = background
local Render4V = Render4V







function BG_11:init()
    local path = "assets\\background\\11\\"
    LoadTexture2("bg_11_autumn1", path .. "autumn1.png")
    LoadTexture2("bg_11_autumn2", path .. "autumn2.png")
    LoadImageFromFile("bg_11_autumn3", path .. "autumn3.png")
    LoadImageFromFile("bg_11_autumn4", path .. "autumn4.png")

    background.init(self, false)
    self.float = background.RanFloat
    self.int = background.RanInt
    self.sign = background.RanSign
    Set3D('eye', 0, 3, 0)
    Set3D('at', 0, 1, 4)
    Set3D('up', 0, 1, 1)
    Set3D('z', 0.1, 24)
    Set3D('fovy', 0.1)
    Set3D('fog', 4, 5, Color(100, 239, 80, 3))
    self.zos = 0
    self.xos = 0
    self.speed = 0.003
    self.cloud = {}
    self.autoSetUp = true
    table.insert(self.cloud, {
        x = background:RanFloat(-1, 0),
        y = background:RanFloat(2.3, 2.8),
        z = background:RanFloat(3.8, 4),
        alpha = 200,
        xos = background:RanFloat(self.speed / 4, self.speed / 2),
        scale = background:RanFloat(2, 2.5),
        timer = 10
    })
    self.leaf = CreateFallLeaf({ { -4, 4 }, { 3, 5 }, { 1, 7 }, { 1, 2 }, { -0.002, 0.002 }, { -0.01, -0.025 }, { -0.01, -0.005 } },
            12, 0.1, "mul+add", 100, { 200, 150, 100 },
            "small_leaf", function(self)
                return self.y < -3
            end, { count = 20, xRange = { -4, 4 }, yRange = { -3, 5 }, zRange = { 1, 7 } }, true)
    task.New(self, function()
        NewPulseScreen(LAYER.BG + 6, nil, "mul+add", nil, nil, 60)
        background.Move3Dcamera(self, 'up', 3, 0, 180, 2)
        task.New(self, function()
            for i = 1, 90 do
                lstg.view3d.fovy = 0.1 + 0.9 * sin(i)
                task.Wait()
            end
        end)
        task.New(self, function()
            local t, s = 0, 0
            while true do
                s = s + sin(t)
                lstg.view3d.eye[1] = -sin(s / 5)
                lstg.view3d.at[3] = 4 + sin(s / 3) * 0.5
                if self.autoSetUp then
                    lstg.view3d.up[1] = sin(s / 2) * 0.1
                end
                t = min(t + 1, 90)
                task.Wait()
            end
        end)
    end)
end
function BG_11:frame()
    task.Do(self)
    self.zos = self.zos - self.speed
    self.xos = self.xos + self.speed / 2.1
    self.leaf:frame()
    if self.timer % 1000 == 0 then
        table.insert(self.cloud, {
            x = background:RanFloat(-5, -3),
            y = background:RanFloat(2.3, 3.5),
            z = background:RanFloat(3.8, 4),
            alpha = 0,
            xos = background:RanFloat(self.speed / 4, self.speed / 2),
            scale = background:RanFloat(2, 2.5),
            timer = 1
        })
    end
    local cloud
    for i = #self.cloud, 1, -1 do
        cloud = self.cloud[i]
        cloud.x = cloud.x + cloud.xos
        if cloud.timer <= 10 then
            cloud.alpha = min(200, cloud.alpha + 200 / 10)
        end
        cloud.timer = cloud.timer + 1
        if cloud.x > 3 then
            cloud.alpha = max(0, cloud.alpha - 200 / 10)
        end
        if cloud.timer >= 60 and cloud.alpha == 0 then
            table.remove(self.cloud, i)
        end
    end
end
function BG_11:render()
    SetViewMode '3d'
    background.ClearToFogColor()
    local uv1, uv2, uv3, uv4 = {}, {}, {}, {}
    local color
    local z = self.zos * 100
    local x = self.xos * 100
    uv1[1], uv1[2], uv1[3] = -4, 1, 14
    uv2[1], uv2[2], uv2[3] = 4, 1, 14
    uv3[1], uv3[2], uv3[3] = 4, 1, -6
    uv4[1], uv4[2], uv4[3] = -4, 1, -6

    color = Color(255, 255, 255, 255)
    uv1[6], uv2[6], uv3[6], uv4[6] = color, color, color, color
    uv1[4], uv1[5] = x + 256, z
    uv2[4], uv2[5] = 1536 + 256 + x, z
    uv3[4], uv3[5] = 1536 + 256 + x, 3072 + z
    uv4[4], uv4[5] = x + 256, 3072 + z
    RenderTexture("bg_11_autumn1", "", uv1, uv2, uv3, uv4)

    color = Color(120, 255, 255, 255)
    uv1[6], uv2[6], uv3[6], uv4[6] = color, color, color, color
    uv1[4], uv1[5] = x + 256, z * 1.5
    uv2[4], uv2[5] = 1536 + x, z * 1.5
    uv3[4], uv3[5] = 1536 + x, 3072 + z * 1.5
    uv4[4], uv4[5] = x + 256, 3072 + z * 1.5
    RenderTexture("bg_11_autumn2", "", uv1, uv2, uv3, uv4)

    Render4V("bg_11_autumn4", -4, 4, 4, 4, 4, 4, 4, 1, 4, -4, 1, 4)
    for _, c in ipairs(self.cloud) do
        SetImageState("bg_11_autumn3", 'mul+add', c.alpha, 255, 255, 255)
        Render4V("bg_11_autumn3",
                c.x - c.scale, c.y + c.scale * 0.3, c.z,
                c.x + c.scale, c.y + c.scale * 0.3, c.z,
                c.x + c.scale, c.y - c.scale * 0.3, c.z,
                c.x - c.scale, c.y - c.scale * 0.3, c.z)
    end
    self.leaf:render()
    SetViewMode 'world'
end
