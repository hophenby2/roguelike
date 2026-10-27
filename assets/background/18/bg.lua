BG_18 = Class(background)
local RenderTexture = RenderTexture
local SetViewMode = SetViewMode
local Color = Color
local Set3D = Set3D
local cos, sin = cos, sin
local min, max = min, max
local background = background
local Render4V = Render4V

function BG_18:init()
    local path = "assets\\background\\18\\"
    LoadTexture2("bg_18_leaf1", path .. "leaf1.png")
    LoadTexture2("bg_18_leaf2", path .. "leaf2.png")
    LoadTexture2("bg_18_water", path .. "water.png")
    LoadTexture2("bg_18_waterback", path .. "water_back.png")
    LoadImageFromFile("bg_18_cloud", path .. "cloud.png")

    background.init(self, false)
    self.float = background.RanFloat
    self.int = background.RanInt
    self.sign = background.RanSign
    Set3D('eye', 0, 1.5, -1)
    Set3D('at', 0, 0, 0)
    Set3D('up', 0, 1, 0)
    Set3D('z', 0.1, 50)
    Set3D('fovy', 1)
    Set3D('fog', 7, 20, Color(100, 0, 0, 0))

    self.cloud = {}
    function self:create_cloud(x, y, z, alpha)
        table.insert(self.cloud, { x = x, y = y, z = z, alpha = 0, talpha = alpha })
    end
    self.speed = 0.01
    self.zos = 0
    self.x, self.y, self.z = unpack(lstg.view3d.eye)
    self.scale = 0.3
    local f = background.RanFloat
    for _ = 1, 13 do
        self:create_cloud(self.x + f(self, -3, 3),
                f(self, 0.3, 0.8),
                self.z + f(self, -3, 3), f(self, 120, 180))
    end
    self.leaf = CreateFallLeaf({ { -3, 3 }, { 1.5, 2.5 }, { 3, 5 }, { 1, 2 }, { -0.002, 0.002 }, { -0.005, -0.01 }, { -0.005, -0.01 } },
            10, 0.1, "mul+add", 100, { 100, 255, 100 },
            "small_leaf", function(self)
                return self.y < -1 or self.z < lstg.view3d.eye[3] - 1
            end, { count = 13, xRange = { -3, 3 }, yRange = { 0, 2.5 }, zRange = { -3, 3 } })
    task.New(self, function()
        local t, s = 0, 0
        while true do
            lstg.view3d.eye[1] = sin(t / 4)
            lstg.view3d.at[1] = sin(t / 4)
            lstg.view3d.up[1] = sin(t / 3) * 0.2
            t = t + sin(s)
            s = min(s + 1, 90)
            task.Wait()
        end
    end)
end
function BG_18:frame()
    task.Do(self)
    self.x, self.y, self.z = unpack(lstg.view3d.eye)
    self.zos = self.zos - self.speed * 100
    if self.timer % math.ceil(self.scale / self.speed) == 0 then
        local f = background.RanFloat
        self:create_cloud(self.x + f(self, -3, 3),
                f(self, 0.3, 0.8),
                self.z + f(self, 3, 5), f(self, 120, 180))
    end
    local c
    for i = #self.cloud, 1, -1 do
        c = self.cloud[i]
        c.z = c.z - self.speed * 0.5
        c.alpha = min(c.talpha, c.alpha + c.talpha / 20)
        if c.z < self.z - 1 then
            c.alpha = max(0, c.alpha - c.talpha / 10)
            if c.alpha == 0 then
                table.remove(self.cloud, i)
            end
        end
    end
    self.leaf:frame()

end

function BG_18:render()
    SetViewMode '3d'
    background.ClearToFogColor()
    do
        local uv1, uv2, uv3, uv4 = {}, {}, {}, {}
        local color
        local z = self.zos
        local size = 2048
        uv1[1], uv1[2], uv1[3] = -4, 0, 10
        uv2[1], uv2[2], uv2[3] = 4, 0, 10
        uv3[1], uv3[2], uv3[3] = 4, 0, -6
        uv4[1], uv4[2], uv4[3] = -4, 0, -6

        uv1[4], uv1[5] = 0, z
        uv2[4], uv2[5] = size, z
        uv3[4], uv3[5] = size, size * 2 + z
        uv4[4], uv4[5] = 0, size * 2 + z
        color = Color(190, 255, 255, 255)
        uv1[6], uv2[6], uv3[6], uv4[6] = color, color, color, color
        RenderTexture("bg_18_waterback", "", uv1, uv2, uv3, uv4)

        color = Color(100, 255, 255, 255)
        uv1[6], uv2[6], uv3[6], uv4[6] = color, color, color, color
        RenderTexture("bg_18_water", "", uv1, uv2, uv3, uv4)

        uv1[4], uv1[5] = -z * 0.3, z
        uv2[4], uv2[5] = size - z * 0.3, z
        uv3[4], uv3[5] = size - z * 0.3, size * 2 + z
        uv4[4], uv4[5] = -z * 0.3, size * 2 + z
        color = Color(50, 255, 255, 255)
        uv1[6], uv2[6], uv3[6], uv4[6] = color, color, color, color
        RenderTexture("bg_18_water", "", uv1, uv2, uv3, uv4)

        color = Color(150, 255, 255, 255)
        uv1[6], uv2[6], uv3[6], uv4[6] = color, color, color, color
        uv1[4], uv1[5] = 0, z
        uv2[4], uv2[5] = size, z
        uv3[4], uv3[5] = size, size * 2 + z
        uv4[4], uv4[5] = 0, size * 2 + z
        uv1[2] = 0.2
        uv2[2] = 0.2
        uv3[2] = 0.2
        uv4[2] = 0.2
        RenderTexture("bg_18_leaf2", "", uv1, uv2, uv3, uv4)
        uv1[2] = 0.4
        uv2[2] = 0.4
        uv3[2] = 0.4
        uv4[2] = 0.4
        RenderTexture("bg_18_leaf1", "", uv1, uv2, uv3, uv4)
    end
    self.leaf:render()
    for _, c in ipairs(self.cloud) do
        SetImageState("bg_18_cloud", "", c.alpha * 0.8, 180, 180, 180)
        Render4V("bg_18_cloud", c.x - 1, c.y, c.z + 1, c.x + 1, c.y, c.z + 1, c.x + 1, c.y, c.z - 1, c.x - 1, c.y, c.z - 1)
    end
    SetViewMode 'world'
end
