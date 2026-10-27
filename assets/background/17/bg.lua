BG_17 = Class(background)
local SetViewMode = SetViewMode
local Color = Color
local Set3D = Set3D
local cos, sin = cos, sin
local min, max = min, max
local background = background
local Render4V = Render4V



function BG_17:init()
    local path = "assets\\background\\17\\"
    LoadImageFromFile("bg_17_cloud1", path .. "cloud1.png")
    LoadImageFromFile("bg_17_cloud2", path .. "cloud2.png")
    LoadImageGroupFromFile("bg_17_sign", path .. "sign.png", nil, 1, 8)


    background.init(self, false)
    self.float = background.RanFloat
    self.int = background.RanInt
    self.sign = background.RanSign

    Set3D('eye', 0, 6, 0)
    Set3D('at', 0, 2, 2.5)
    Set3D('up', 0, 1, 0)
    Set3D('z', 0.1, 24)
    Set3D('fovy', 0.6)
    Set3D('fog', 10, 20, Color(150, 50, 50, 50))
    self.speed = 1
    self.angle = 0
    self.SetState = function(color)
        for i = 1, 8 do
            SetImageState("bg_17_sign" .. i, 'mul+add', color)
        end
    end
    SetImageState('bg_17_cloud1', 'mul+alpha', 200, 255, 255, 255)
    SetImageState('bg_17_cloud2', 'mul+alpha', 100, 255, 255, 255)
    self.leaf = CreateFallLeaf({ { -6, 6 }, { -1, 2 }, { -6, 6 }, { 1, 2 }, { -0.002, 0.002 }, { 0.02, 0.05 }, { -0.002, 0.002 } },
            20, 0.1, "mul+add", 100, { 135, 206, 235 },
            "small_leaf", function(self)
                return self.y > 12
            end, { count = 30, xRange = { -6, 6 }, yRange = { -1, 9 }, zRange = { -6, 6 } }, true)
    function self.draw_circle(x, y, z, r, R, N, rot, fa, fr)
        local a1 = 360 / N
        local a2 = a1 / 8
        for n = 1, N do
            for m = 1, 8 do
                Render4V("bg_17_sign" .. m,
                        x + r * cos(n * a1 + a2 * m + rot), y + fr * cos(n * a1 + a2 * m + rot + fa), z + r * sin(n * a1 + a2 * m + rot),
                        x + R * cos(n * a1 + a2 * m + rot), y + fr * cos(n * a1 + a2 * m + rot + fa), z + R * sin(n * a1 + a2 * m + rot),
                        x + R * cos(n * a1 + a2 * (m + 1) + rot), y + fr * cos(n * a1 + a2 * (m + 1) + rot + fa), z + R * sin(n * a1 + a2 * (m + 1) + rot),
                        x + r * cos(n * a1 + a2 * (m + 1) + rot), y + fr * cos(n * a1 + a2 * (m + 1) + rot + fa), z + r * sin(n * a1 + a2 * (m + 1) + rot))
            end
        end
    end
    task.New(self, function()
        while true do
            task.Wait(60)
            lstg.view3d.fog[3] = Color(100, 255, 227, 132)
            task.Wait(3)
            lstg.view3d.fog[3] = Color(100, 50, 50, 50)
            task.Wait(3)
            for i = 1, 60 do
                i = i / 60
                lstg.view3d.fog[3] = Color(100, 255 - 205 * i, 227 - 177 * i, 132 - 82 * i)
                task.Wait()
            end
            task.Wait(60)
        end
    end)
    task.New(self, function()
        local t, s = 0, 0
        while true do
            lstg.view3d.eye[1] = sin(t / 2)
            lstg.view3d.at[1] = sin(t / 6)
            lstg.view3d.up[1] = sin(t / 3) * 0.5
            t = t + sin(s)
            s = min(s + 1, 90)
            task.Wait()
        end
    end)
end
function BG_17:frame()
    task.Do(self)
    if self.angle < -180 then
        self.angle = 0
    else
        self.angle = self.angle - 0.1
    end
    self.leaf:frame()
end

function BG_17:render()
    SetViewMode '3d'
    background.ClearToFogColor()
    local timer = self.timer * self.speed
    local R = 6
    for i = 1, 12 do
        for j = 1, 12 do
            Render4V('bg_17_cloud1',
                    R * cos(30 * i), -24 + R * (j + 1), R * sin(30 * i),
                    R * cos(30 * i), -24 + R * j, R * sin(30 * i),
                    R * cos(30 * (i + 1)), -24 + R * j, R * sin(30 * (i + 1)),
                    R * cos(30 * (i + 1)), -24 + R * (j + 1), R * sin(30 * (i + 1)))
        end
    end
    R = 5
    for i = 1, 12 do
        for j = 1, 12 do
            Render4V('bg_17_cloud2',
                    R * cos(self.angle + 30 * i), -20 + R * (j + 1), R * sin(self.angle + 30 * i),
                    R * cos(self.angle + 30 * i), -20 + R * j, R * sin(self.angle + 30 * i),
                    R * cos(self.angle + 30 * (i + 1)), -20 + R * j, R * sin(self.angle + 30 * (i + 1)),
                    R * cos(self.angle + 30 * (i + 1)), -20 + R * (j + 1), R * sin(self.angle + 30 * (i + 1)))
        end
    end

    local k = 0.5
    local n = 12
    local a3 = timer * 0.1
    self.SetState(Color(100, 255, 255, 255))
    self.draw_circle(0.5, 0.75, 1, 2, 2.25, n, a3, timer * 0.05, k)
    self.draw_circle(0.5, 0.75, 1, 2.5, 2.75, n, a3, timer * 0.05, k)
    self.SetState(Color(100, 200, 60, 100))
    self.draw_circle(-0.5, 2.75, 1, 3, 2.75, n, a3, timer * 0.08 + 90, k)
    self.draw_circle(-0.5, 2.75, 1, 2.5, 2.25, n, a3, timer * 0.08 + 90, k)
    self.SetState(Color(100, 60, 60, 200))
    self.draw_circle(1, 2.75, 1, 3, 2.75, n, a3, timer * 0.08 - 90, k)
    self.draw_circle(1, 2.75, 1, 2.5, 2.25, n, a3, timer * 0.08 - 90, k)
    self.leaf:render()
    SetViewMode 'world'
end
