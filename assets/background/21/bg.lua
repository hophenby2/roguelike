BG_21 = Class(background)
local SetViewMode = SetViewMode
local Color = Color
local Set3D = Set3D
local cos, sin = cos, sin
local min, max = min, max
local background = background
local Render4V = Render4V



function BG_21:init()
    local path = "assets\\background\\21\\"
    LoadTexture2("bg_21_forest", path .. "forest.png")
    LoadTexture2("bg_21_fog", path .. "fog.png")
    LoadImageFromFile("bg_21_rain", path .. "rain.png")

    background.init(self, false)
    self.float = background.RanFloat
    self.int = background.RanInt
    self.sign = background.RanSign
    Set3D('eye', 0, 3, 0)
    Set3D('at', 0, 0.5, 3)
    Set3D('up', 0, 1, 0)
    Set3D('z', 0.1, 24)
    Set3D('fovy', 0.8)
    Set3D('fog', 2, 5, Color(100, 15, 100, 150))
    self.zos = 0
    self.speed = 0.007
    self.rain = {}
    self.thickness = 40
    self.decalpha = 2
    self.rainfallspeed = 0.05
    function self:create_rain(x, y, z, vx, vy, vz, rx, ry, rz)
        local unit = { vx = vx, vy = vy, vz = vz, alpha = 230 }
        local size = 0.01
        table.insert(self.rain, unit)
        unit.x1, unit.y1, unit.z1 = -1 * size, -32 * size, 0
        unit.x2, unit.y2, unit.z2 = -1 * size, 32 * size, 0
        unit.x3, unit.y3, unit.z3 = 1 * size, 32 * size, 0
        unit.x4, unit.y4, unit.z4 = 1 * size, -32 * size, 0
        unit.x, unit.y, unit.z = x, y, z
        unit.rx, unit.ry, unit.rz = rx, ry, rz
        unit.x1, unit.y1 = unit.x1 * cos(rz) - unit.y1 * sin(rz), unit.y1 * cos(rz) + unit.x1 * sin(rz)
        unit.x2, unit.y2 = unit.x2 * cos(rz) - unit.y2 * sin(rz), unit.y2 * cos(rz) + unit.x2 * sin(rz)
        unit.x3, unit.y3 = unit.x3 * cos(rz) - unit.y3 * sin(rz), unit.y3 * cos(rz) + unit.x3 * sin(rz)
        unit.x4, unit.y4 = unit.x4 * cos(rz) - unit.y4 * sin(rz), unit.y4 * cos(rz) + unit.x4 * sin(rz)

        unit.x1, unit.z1 = unit.x1 * cos(ry) - unit.z1 * sin(ry), unit.z1 * cos(ry) + unit.x1 * sin(ry)
        unit.x2, unit.z2 = unit.x2 * cos(ry) - unit.z2 * sin(ry), unit.z2 * cos(ry) + unit.x2 * sin(ry)
        unit.x3, unit.z3 = unit.x3 * cos(ry) - unit.z3 * sin(ry), unit.z3 * cos(ry) + unit.x3 * sin(ry)
        unit.x4, unit.z4 = unit.x4 * cos(ry) - unit.z4 * sin(ry), unit.z4 * cos(ry) + unit.x4 * sin(ry)

        unit.y1, unit.z1 = unit.y1 * cos(rx) - unit.z1 * sin(rx), unit.z1 * cos(rx) + unit.y1 * sin(rx)
        unit.y2, unit.z2 = unit.y2 * cos(rx) - unit.z2 * sin(rx), unit.z2 * cos(rx) + unit.y2 * sin(rx)
        unit.y3, unit.z3 = unit.y3 * cos(rx) - unit.z3 * sin(rx), unit.z3 * cos(rx) + unit.y3 * sin(rx)
        unit.y4, unit.z4 = unit.y4 * cos(rx) - unit.z4 * sin(rx), unit.z4 * cos(rx) + unit.y4 * sin(rx)
    end
    task.New(self, function()
        NewPulseScreen(LAYER.BG + 6, nil, "mul+add", nil, nil, 60)
        task.New(self, function()
            local t, s = 0, 0
            while true do
                s = s + sin(t)
                lstg.view3d.eye[1] = -sin(s / 4)
                lstg.view3d.at[3] = 3 + sin(s / 3) * 0.5
                --lstg.view3d.up[1] = sin(s / 5) * 0.2
                t = min(t + 1, 90)
                task.Wait()
            end
        end)
    end)
end

function BG_21:frame()
    task.Do(self)
    self.zos = self.zos - self.speed
    local x, y, z = unpack(lstg.view3d.eye)
    for _ = 1, int(self.thickness) do
        self:create_rain(x + self:float(-3, 3), y + self:float(4, 5), z + self:float(-3, 3),
                0, -self.rainfallspeed, 0, 0, 0, self:float(-1, 1))
    end
    local r
    for i = #self.rain, 1, -1 do
        r = self.rain[i]
        r.x = r.x + r.vx
        r.y = r.y + r.vy
        r.z = r.z + r.vz
        r.alpha = max(r.alpha - self.decalpha * self.rainfallspeed * 20, 0)
        if r.alpha <= 0 then
            table.remove(self.rain, i)
        end
    end
end
function BG_21:render()
    SetViewMode '3d'
    background.ClearToFogColor()
    local color
    local z = self.zos * 100
    color = Color(255, 255, 255, 255)
    RenderTexture("bg_21_forest", "",
            { -4, 1, 14, 256, z, color },
            { 4, 1, 14, 1536 + 256, z, color },
            { 4, 1, -6, 1536 + 256, 3072 + z, color },
            { -4, 1, -6, 256, 3072 + z, color })
    color = Color(50, 255, 255, 255)
    RenderTexture("bg_21_fog", "",
            { -4, 2, 14, 256, z * 1.5, color },
            { 4, 2, 14, 1536 + 256, z * 1.5, color },
            { 4, 2, -6, 1536 + 256, 3072 + z * 1.5, color },
            { -4, 2, -6, 256, 3072 + z * 1.5, color })
    for _, r in ipairs(self.rain) do
        SetImageState("bg_21_rain", "", r.alpha, 224, 224, 255)
        Render4V("bg_21_rain",
                r.x + r.x1, r.y + r.y1, r.z + r.z1,
                r.x + r.x2, r.y + r.y2, r.z + r.z2,
                r.x + r.x3, r.y + r.y3, r.z + r.z3,
                r.x + r.x4, r.y + r.y4, r.z + r.z4)
    end
    SetViewMode 'world'
end
