local SetImageState = SetImageState
local SetViewMode = SetViewMode
local Render4V = Render4V
local RenderTexture = RenderTexture
local Color = Color
local background = background
local cos, sin = cos, sin


BG_3 = Class(background)

function BG_3:init()
    local path = "assets\\background\\3\\"
    LoadImageFromFile("bg_3_lake", path .. "lake.png")
    LoadImageFromFile("bg_3_lakefog", path .. "lakefog.png")
    LoadImageFromFile("bg_3_pillar", path .. "pillar.png")
    LoadImageFromFile("bg_3_wire", path .. "wire.png")
    SetImageState("bg_3_pillar","",255,0,0,0)

    background.init(self, false)
    Set3D('fog', 0, 0.1, Color(0, 0, 0, 0))
    Set3D('z', 0.1, 50)
    Set3D('fovy', 0.8)
    Set3D("eye", 0, 1, -9)
    Set3D("at", 0, 0, 0)
    Set3D("up", 0, 1, 0)
    self.leaf = { {}, {}, {} }
    self.WaterFog = {}
    self.wave = {}
    self.pillar = { {}, {}, {} }
    self.speed = 0.01
    self.exactTimer = 0
    for x = -7, 7, 2.5 do
        table.insert(self.pillar[1], { x = x + background:RanFloat(-1, 1), y = 0 + background:RanFloat(-0.3, 0.3), z = -2 })
        table.insert(self.pillar[2], { x = x + background:RanFloat(-1, 1), y = 0.5 + background:RanFloat(-0.3, 0.3), z = -3 })
        table.insert(self.pillar[3], { x = x + background:RanFloat(-1, 1), y = 1 + background:RanFloat(-0.3, 0.3), z = -4 })
    end
    self.zos = 0
    task.New(self, function()
        SetImageState('bg_3_lakefog', 'mul+add', 0, 255, 255, 255)
        for i = 1, 180 do
            SetImageState('bg_3_lakefog', 'mul+add', max(0, (15 * sin(i / 2) - 7) * 25), 255, 255, 255)
            Set3D('fog', 15 * sin(i / 2), 0.1 + 21.9 * sin(i / 2), Color(0, 0, 0, 0))
            task.Wait()
        end
    end)

end
function BG_3:frame()
    task.Do(self)
    Set3D("eye", sin(self.timer / 2), 2 + sin(self.timer / 3), -9)
    self.zos = self.zos - self.speed
    self.exactTimer = self.exactTimer + 1
    local p
    while self.exactTimer >= 5 / self.speed do
        table.insert(self.pillar[1], { x = 7 + background:RanFloat(-1, 1), y = 0 + background:RanFloat(-0.3, 0.3), z = -2 })
        table.insert(self.pillar[2], { x = 7 + background:RanFloat(-1, 1), y = 0.5 + background:RanFloat(-0.3, 0.3), z = -3 })
        table.insert(self.pillar[3], { x = 7 + background:RanFloat(-1, 1), y = 1 + background:RanFloat(-0.3, 0.3), z = -4 })
        self.exactTimer = self.exactTimer - 5 / self.speed
    end
    for j = 1, 3 do
        for i = #self.pillar[j], 1, -1 do
            p = self.pillar[j][i]
            p.x = p.x - self.speed / 2
            if p.x < -10 then
                table.remove(self.pillar[j], i)
            end
        end
    end
    if self.timer % 7 == 0 then
        local l = background:RanInt(1, 3)
        local t = { { -1, -1.8 }, { -2.2, -2.8 }, { -3.2, -5 } }
        table.insert(self.leaf[l], {
            x = background:RanFloat(6, 7),
            y = background:RanFloat(4, 5),
            z = background:RanFloat(unpack(t[l])),
            vx = -background:RanFloat(0.005, 0.02), vy = -background:RanFloat(0.005, 0.02), vz = 0,
            rot = background:RanFloat(0, 360), omega = background:RanSign() * background:RanFloat(2, 4) })
    end
    local l
    for j = 1, 3 do
        for i = #self.leaf[j], 1, -1 do
            l = self.leaf[j][i]
            l.x = l.x + l.vx
            l.y = l.y + l.vy
            l.z = l.z + l.vz
            l.rot = l.rot + l.omega
            if l.y < -4 then
                table.remove(self.leaf[j], i)
            end
        end
    end
end

function BG_3:render()
    SetViewMode("3d")
    RenderClearViewMode(Color(255, 0, 0, 0))
    Render4V("bg_3_lake", -7, 7, 0, 7, 7, 0, 7, -7, 0, -7, -7, 0)
    for x = -10, 10, 2 do
        Render4V("bg_3_lakefog",
                x - 2 + self.zos%4, 5.5, 0,
                x + 2 + self.zos%4, 5.5, 0,
                x + 2 + self.zos%4, 1.5, 0,
                x - 2 + self.zos%4, 1.5, 0)
        Render4V("bg_3_lakefog",
                x - 2 + self.zos%4, 5.5, 0,
                x + 2 + self.zos%4, 5.5, 0,
                x + 2 + self.zos%4, 9.5, 0,
                x - 2 + self.zos%4, 9.5, 0)
    end
    local r = 0.2
    SetImageState("leaf", "mul+add", 70, 255, 227, 132)
    for i = 1, 3 do
        for _, l in ipairs(self.leaf[i]) do
            Render4V("leaf",
                    l.x - 0.1 * cos(l.rot) - 0.1 * sin(l.rot), l.y + 0.1 * cos(l.rot) - 0.1 * sin(l.rot), l.z,
                    l.x + 0.1 * cos(l.rot) - 0.1 * sin(l.rot), l.y + 0.1 * cos(l.rot) + 0.1 * sin(l.rot), l.z,
                    l.x + 0.1 * cos(l.rot) + 0.1 * sin(l.rot), l.y - 0.1 * cos(l.rot) + 0.1 * sin(l.rot), l.z,
                    l.x - 0.1 * cos(l.rot) + 0.1 * sin(l.rot), l.y - 0.1 * cos(l.rot) - 0.1 * sin(l.rot), l.z)
        end
        for _, p in ipairs(self.pillar[i]) do
            for j = 1, 6 do
                Render4V("bg_3_pillar",
                        p.x + cos(j * 60 + 30) * r, p.y, p.z + sin(j * 60 + 30) * r,
                        p.x + cos(j * 60 - 30) * r, p.y, p.z + sin(j * 60 - 30) * r,
                        p.x + cos(j * 60 - 30) * r, -4, p.z + sin(j * 60 - 30) * r,
                        p.x + cos(j * 60 + 30) * r, -4, p.z + sin(j * 60 + 30) * r)
                Render4V("bg_3_wire",
                        p.x + cos(j * 60 + 30) * r, p.y, p.z + sin(j * 60 + 30) * r,
                        p.x + cos(j * 60 + 30) * r * 2, p.y, p.z + sin(j * 60 + 30) * r * 2,
                        p.x + cos(j * 60 + 30) * r * 2, p.y - 1, p.z + sin(j * 60 + 30) * r * 2,
                        p.x + cos(j * 60 + 30) * r, p.y - 1, p.z + sin(j * 60 + 30) * r)
            end
        end
    end

    SetViewMode("world")
end
