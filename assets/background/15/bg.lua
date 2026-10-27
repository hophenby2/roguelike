BG_15 = Class(background)
local SetViewMode = SetViewMode
local RenderTexture = RenderTexture
local Color = Color
local Set3D = Set3D
local cos, sin = cos, sin
local min, max = min, max
local background = background
local Render4V = Render4V



function BG_15:init()
    local path = "assets\\background\\15\\"
    LoadTexture2("bg_15_summer1", path .. "summer1.png")
    LoadImageFromFile("bg_15_summer2", path .. "summer2.png")
    LoadImageFromFile("bg_15_summer3", path .. "summer3.png")

    background.init(self, false)
    self.float = background.RanFloat
    self.int = background.RanInt
    self.sign = background.RanSign
    Set3D('eye', 0, 3, 0)
    Set3D('at', 0, 1.5, 4)
    Set3D('up', 0, 1, 0)
    Set3D('z', 0.1, 24)
    Set3D('fovy', 0.1)
    Set3D('fog', 4, 5, Color(100, 31, 173, 206))
    self.zos = 0
    self.xos = 0
    self.speed = 0.007

    self.cloud = {}
    table.insert(self.cloud, {
        x = background:RanFloat(-1, 0),
        y = background:RanFloat(2.8, 3.8),
        z = background:RanFloat(3.8, 4),
        alpha = 200,
        xos = background:RanFloat(0.007 / 4, 0.007 / 2),
        scale = background:RanFloat(1.6, 2.5),
        timer = 10
    })
    table.insert(self.cloud, {
        x = background:RanFloat(-1, 1),
        y = background:RanFloat(3.8, 4.5),
        z = background:RanFloat(3.8, 4),
        alpha = 200,
        xos = background:RanFloat(0.007 / 4, 0.007 / 2),
        scale = background:RanFloat(1.6, 2.5),
        timer = 10
    })
    task.New(self, function()
        NewPulseScreen(LAYER.BG + 6, nil, "mul+add", nil, nil, 60)
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
                lstg.view3d.eye[1] = -sin(s / 4)
                lstg.view3d.at[3] = 4 + sin(s / 3) * 0.5
                lstg.view3d.up[1] = sin(s / 5) * 0.2
                t = min(t + 1, 90)
                task.Wait()
            end
        end)
    end)
end

function BG_15:frame()
    task.Do(self)
    self.zos = self.zos - self.speed
    self.xos = self.xos + self.speed / 2.1
    if self.timer % 720 == 0 then
        table.insert(self.cloud, {
            x = background:RanFloat(-5, -3),
            y = background:RanFloat(2.8, 3.8),
            z = background:RanFloat(3.8, 4),
            alpha = 0,
            xos = background:RanFloat(0.007 / 4, 0.007 / 2),
            scale = background:RanFloat(1.6, 2.5),
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
        if cloud.x > 5 then
            cloud.alpha = max(0, cloud.alpha - 200 / 10)
        end
        if cloud.timer >= 60 and cloud.alpha == 0 then
            table.remove(self.cloud, i)
        end
    end
end
function BG_15:render()
    SetViewMode '3d'
    background.ClearToFogColor()
    local color
    local z = self.zos * 100
    local x = self.xos * 100
    color = Color(255, 255, 255, 255)
    RenderTexture("bg_15_summer1", "",
            { -4, 1, 14, x + 256, z, color },
            { 4, 1, 14, 1536 + 256 + x, z, color },
            { 4, 1, -6, 1536 + 256 + x, 3072 + z, color },
            { -4, 1, -6, x + 256, 3072 + z, color })
    Render4V("bg_15_summer3", -4, 6, 4, 4, 6, 4, 4, 1, 4, -4, 1, 4)
    for _, cloud in ipairs(self.cloud) do
        SetImageState("bg_15_summer2", 'mul+add', cloud.alpha, 255, 255, 255)
        Render4V("bg_15_summer2",
                cloud.x - cloud.scale, cloud.y + cloud.scale, cloud.z,
                cloud.x + cloud.scale, cloud.y + cloud.scale, cloud.z,
                cloud.x + cloud.scale, cloud.y - cloud.scale, cloud.z,
                cloud.x - cloud.scale, cloud.y - cloud.scale, cloud.z
        )
    end
    SetViewMode 'world'
end
