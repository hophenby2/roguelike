local SetViewMode = SetViewMode
local RenderTexture = RenderTexture
local Color = Color
local background = background
local cos, sin = cos, sin


BG_4 = Class(background)

function BG_4:init()
    local path = "assets\\background\\4\\"
    LoadTexture2("bg_4_lake", path .. "lake.png")
    LoadTexture2("bg_4_floor1", path .. "floor1.png")
    LoadTexture2("bg_4_floor2", path .. "floor2.png")
    LoadTexture2("bg_4_grass", path .. "grass.png")
    LoadTexture2("bg_4_lake_floor", path .. "lake_floor.png")
    LoadTexture2("bg_4_leaves", path .. "leaves.png")

    background.init(self, false)
    Set3D('z', 0.1, 50)
    Set3D('eye', 0.5, 1.6, -0.6)
    Set3D('at', 0.4, 0, 1)
    Set3D('up', 0, 1, 0)
    Set3D('fog', 1.5, 3, Color(100, 42, 20, 50))--70,82,71
    Set3D('fovy', 0.8)
    self.leaf = CreateFallLeaf({ { -3, 3 }, { 1.5, 2.5 }, { 3, 5 }, { 1, 2 }, { -0.002, 0.002 }, { -0.005, -0.01 }, { -0.01, -0.02 } },
            8, 0.1, "mul+add", 100, { 200, 200, 200 },
            "cherry_bullet", function(self)
                return self.y < -1 or self.z < lstg.view3d.eye[3] - 1
            end, { count = 20, xRange = { -3, 3 }, yRange = { 0, 2.5 }, zRange = { -3, 5 } }, true)
    self.wicker = {}
    self.speed = 0.01
    self.zos = 0
    self.scale = 0.3
    self.lakeos = 0
    function self:create_wicker(x, z, alpha)
        table.insert(self.wicker, { x = x, y = 1.8, z = z, alpha = 0, talpha = alpha, rot = { -20, -20, -20, -20 }, timer = 0 })
    end
    local f = background.RanFloat
    for _ = 1, 13 do
        self:create_wicker(f(self, 0, 3), f(self, -5, 5), f(self, 180, 230))
    end
end
function BG_4:frame()
    task.Do(self)
    self.zos = self.zos - self.speed * 100
    self.lakeos = self.lakeos - 1
    if self.timer % math.ceil(self.scale / self.speed) == 0 then
        local f = background.RanFloat
        self:create_wicker(f(self, 0, 3), f(self, 3, 5), f(self, 180, 230))
    end
    local w
    for i = #self.wicker, 1, -1 do
        w = self.wicker[i]
        w.z = w.z - self.speed
        w.alpha = min(w.talpha, w.alpha + w.talpha / 20)
        for j = 2, 4 do
            w.rot[j] = w.rot[j] + (-w.rot[j] + w.rot[j - 1]) * 0.06
        end
        w.rot[1] = -20 + 10 * sin(w.timer) * self.speed * 50
        w.timer = w.timer + 1
        if w.z < -1 then
            w.alpha = max(0, w.alpha - w.talpha / 10)
            if w.alpha == 0 then
                table.remove(self.wicker, i)
            end
        end
    end
    self.leaf:frame()
end

function BG_4:render()
    SetViewMode("3d")
    RenderClearViewMode(Color(255, 0, 0, 0))
    do
        local color, size
        local z = self.zos
        local z2 = self.lakeos
        size = 2048
        color = Color(255, 255, 255, 255)
        local uv1, uv2, uv3, uv4 = {}, {}, {}, {}
        uv1[6], uv2[6], uv3[6], uv4[6] = color, color, color, color

        uv1[1], uv1[2], uv1[3], uv1[4], uv1[5] = -4, 0, 8, 0, z2 + 100
        uv2[1], uv2[2], uv2[3], uv2[4], uv2[5] = 2, 0, 8, size, z2 + 100
        uv3[1], uv3[2], uv3[3], uv3[4], uv3[5] = 2, 0, -4, size, size * 2 + z2 + 100
        uv4[1], uv4[2], uv4[3], uv4[4], uv4[5] = -4, 0, -4, 0, size * 2 + z2 + 100
        RenderTexture("bg_4_lake_floor", "", uv1, uv2, uv3, uv4)
        color = Color(80, 255, 255, 255)
        uv1[6], uv2[6], uv3[6], uv4[6] = color, color, color, color
        uv1[4] = -z2 * 0.2
        uv2[4] = size - z2 * 0.2
        uv3[4] = size - z2 * 0.2
        uv4[4] = -z2 * 0.2
        RenderTexture("bg_4_lake", "", uv1, uv2, uv3, uv4)
        uv1[4] = z2 * 0.2
        uv2[4] = size + z2 * 0.2
        uv3[4] = size + z2 * 0.2
        uv4[4] = z2 * 0.2
        uv1[5] = z2
        uv2[5] = z2
        uv3[5] = size * 2 + z2
        uv4[5] = size * 2 + z2
        RenderTexture("bg_4_lake", "", uv1, uv2, uv3, uv4)
        color = Color(255, 255, 255, 255)
        size = 256 * 6
        uv1[6], uv2[6], uv3[6], uv4[6] = color, color, color, color

        uv1[1], uv1[2], uv1[3], uv1[4], uv1[5] = -0.2, 0.1, 8, 1, z
        uv2[1], uv2[2], uv2[3], uv2[4], uv2[5] = 0.3, 0.1, 8, size / 24, z
        uv3[1], uv3[2], uv3[3], uv3[4], uv3[5] = 0.3, 0.1, -4, size / 24, size * 2 + z
        uv4[1], uv4[2], uv4[3], uv4[4], uv4[5] = -0.2, 0.1, -4, 1, size * 2 + z
        RenderTexture("bg_4_grass", "", uv1, uv2, uv3, uv4)

        uv1[1], uv1[2], uv1[3], uv1[4], uv1[5] = 0, 0.1, 8, 1, z
        uv2[1], uv2[2], uv2[3], uv2[4], uv2[5] = 1, 0.1, 8, size / 6 - 1, z
        uv3[1], uv3[2], uv3[3], uv3[4], uv3[5] = 1, 0.1, -4, size / 6 - 1, size * 2 + z
        uv4[1], uv4[2], uv4[3], uv4[4], uv4[5] = 0, 0.1, -4, 1, size * 2 + z
        RenderTexture("bg_4_floor1", "", uv1, uv2, uv3, uv4)
        uv1[1] = 1
        uv2[1] = 2
        uv3[1] = 2
        uv4[1] = 1
        RenderTexture("bg_4_floor2", "", uv1, uv2, uv3, uv4)
    end
    self.leaf:render()
    local color, x, y, h, rot
    local size = 0.05
    local uv1, uv2, uv3, uv4 = {}, {}, {}, {}
    local cosr, sinr
    uv1[4], uv2[4], uv3[4], uv4[4] = 0, 16, 16, 0
    for _, w in ipairs(self.wicker) do
        color = Color(w.alpha, 255, 255, 255)
        uv1[6], uv2[6], uv3[6], uv4[6] = color, color, color, color
        x, y, h = w.x, w.y, 0
        for z = 1, 4 do
            rot = w.rot[z] + sin(w.timer * 3 + z * 90) * 2
            cosr, sinr = cos(rot), sin(rot)
            uv1[1], uv1[2], uv1[3], uv1[5] = x - size * cosr, y - size * sinr, w.z, h
            uv2[1], uv2[2], uv2[3], uv2[5] = x + size * cosr, y + size * sinr, w.z, h
            uv3[1], uv3[2], uv3[3], uv3[5] = x + size * cosr + size * 8 * sinr, y - size * 8 * cosr + size * sinr, w.z, h + 64
            uv4[1], uv4[2], uv4[3], uv4[5] = x - size * cosr + size * 8 * sinr, y - size * 8 * cosr - size * sinr, w.z, h + 64
            RenderTexture("bg_4_leaves", "", uv1, uv2, uv3, uv4)
            h = h + 64
            x = x + size * 8 * sin(rot)
            y = y - size * 8 * cos(rot)
        end
    end
    SetViewMode("world")
end
