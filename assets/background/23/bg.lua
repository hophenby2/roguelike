local SetViewMode = SetViewMode
local Color = Color
local Set3D = Set3D
local cos, sin = cos, sin
local background = background
local SetImageState = SetImageState
local Render4V = Render4V

BG_23 = Class(background)

function BG_23:init()
    local path = "assets\\background\\23\\"
    LoadImageFromFile("bg_23_road", path .. "road.png")
    LoadImageFromFile("bg_23_ground", path .. "ground.png")
    LoadImageFromFile("bg_23_pillar", path .. "pillar.png")
    --
    background.init(self, false)
    Set3D('eye', 0, 2.6, -4)
    Set3D('at', 0, 0, 0)
    Set3D('up', 0, 1, 0)
    Set3D('z', 1, 10)
    Set3D('fovy', 0.6)
    Set3D('fog', 3, 10, Color(255, 100, 40, 30))
    --
    self.speed = 0.03
    self.leafspeed = 0.03
    self.z = 0
    self.leaf = CreateFallLeaf({ { -3, 6 }, { 2, 5 }, { 4, 10 }, { 1, 2 }, { -0.01, 0 }, { -0.02, -0.03 }, { -0.03, -0.042 } },
            30, 0.1, "mul+add", 100, { 255, 227, 132 },
            "leaf", function(self)
                return self.y < -1 or self.z < lstg.view3d.eye[3] - 1
            end, {
                count = 30,
                xRange = { -3, 3 },
                yRange = { 0, 5 },
                zRange = { -3, 7 } },
            true)
    task.New(self, function()
        local s, t = 0, 0
        while true do
            lstg.view3d.eye[1] = sin(t/2) * 0.4
            lstg.view3d.at[1] = sin(t / 3) * 0.4
            t = t + sin(s)
            s = min(s + 1, 90)
            task.Wait()
        end
    end)
end


function BG_23:frame()
    task.Do(self)
    self.z = self.z + self.speed
    self.leaf.speed = self.leafspeed * 100 / 4
    self.leaf:frame()
end

function BG_23:render()
    SetViewMode("3d")
    background.ClearToFogColor()

    for j = 0, 4 do
        local dz = j * 2 - self.z % 2
        Render4V("bg_23_ground", 4.5, 0, dz, 2.5, 0, dz, 2.5, 0, -2 + dz, 4.5, 0, -2 + dz)
        Render4V("bg_23_ground", -4.5, 0, dz, -2.5, 0, dz, -2.5, 0, -2 + dz, -4.5, 0, -2 + dz)
        Render4V("bg_23_ground", 0.5, 0, dz, 2.5, 0, dz, 2.5, 0, -2 + dz, 0.5, 0, -2 + dz)
        Render4V("bg_23_ground", -0.5, 0, dz, -2.5, 0, dz, -2.5, 0, -2 + dz, -0.5, 0, -2 + dz)
        Render4V("bg_23_road", -1, 0, dz, 1, 0, dz, 1, 0, -2 + dz, -1, 0, -2 + dz)
    end
    for j = 3, -1, -1 do
        local dz = j * 2 - self.z % 2
        BG_23.draw_pillar(0.85, dz + 0.2, 2.5, 0, 0.15)
        BG_23.draw_pillar(-0.85, dz + 0.2, 2.5, 0, 0.15)
    end
    self.leaf:render()
    SetViewMode("world")
end

function BG_23.draw_pillar(x, z, y1, y2, r)
    local a = 0
    local d = r * cos(22.5)
    local eyex, eyez
    eyex = lstg.view3d.eye[1] - x
    eyez = lstg.view3d.eye[3] - z
    for _ = 1, 8 do
        if d * cos(a) * eyex + d * sin(a) * eyez - d * d > 0 then
            local blk = 255 * (((1 - cos(a) * SQRT2_2 + sin(a) * SQRT2_2) * 0.5) + 0.0625)
            SetImageState("bg_23_pillar", "", 255, blk, blk, blk)
            Render4V("bg_23_pillar",
                    x + r * cos(a - 22.5), y1, z + r * sin(a - 22.5),
                    x + r * cos(a + 22.5), y1, z + r * sin(a + 22.5),
                    x + r * cos(a + 22.5), y2, z + r * sin(a + 22.5),
                    x + r * cos(a - 22.5), y2, z + r * sin(a - 22.5))
        end
        a = a + 45
    end
end
