BG_1 = Class(background)
function BG_1:init()

    local path = "assets\\background\\1\\"
    LoadTexture2("bg_1_wall", path .. "wall.png")
    LoadTexture2("bg_1_floor", path .. "floor.png")
    LoadImageFromFile("bg_1_outside", path .. "outside.png")

    background.init(self)
    self.leaf = CreateFallLeaf({ { -1, 1 }, { -4, 4 }, { 5, 6 }, { 1, 2 }, { -0.002, 0.002 }, { -0.002, 0.002 }, { -0.02, -0.05 } },
            10, 0.1, "mul+add", 100, { 100, 100, 200 },
            "small_leaf", function(self)
                return self.z < -3
            end, { count = 50, xRange = { -1, 1 }, yRange = { -1, 9 }, zRange = { -1, 6 } }, true)
    Set3D('fog', 2.4, 10, Color(150, 135, 206, 235))
    Set3D('up', 0, 1, 0)
    Set3D('eye', -0.8, 1, -1)
    Set3D('at', 0.8, 0, 0)
    Set3D('z', 0.1, 50)
    Set3D('fovy', 0.8)
    self.zos = 0
    self.speed = 3
    task.New(self, function()
        local Move3D = background.Move3Dcamera
        Move3D(self, "up", 1, 0, 360, 2)
        --Move3D(self, "up", 2, 1, 360, 2)
        Move3D(self, "eye", 2, 1.6, 180, 2)
        Move3D(self, "at", 2, 0.7, 180, 2)
        Move3D(self, "eye", 3, -0.8, 180, 2)
        local s, t = 0, 0
        local sin, min, lstg = sin, min, lstg
        while true do
            lstg.view3d.eye[1] = sin(t / 3.1 - 90) * 0.7
            lstg.view3d.at[1] = sin(t / 5 + 90) * 0.7
            lstg.view3d.up[3] = sin(t / 6.2) * 0.5
            lstg.view3d.up[2] = 0.5 + sin(t / 4.1) * 0.4
            t = t + sin(s)
            s = min(s + 1, 90)
            task.Wait()
        end
    end)
end
function BG_1:frame()
    self.leaf:frame()
    task.Do(self)
    self.zos = self.zos - self.speed
end
function BG_1:render()
    SetViewMode("ui")

    Render("bg_1_outside", 320 + sin(self.timer / 10) * 50, 240, 0, 0.5)
    SetViewMode("3d")
    local color
    local size = 512 * 8
    local z = self.zos
    color = Color(255, 255, 255, 255)
    local y = 0
    local uv1, uv2, uv3, uv4 = {}, {}, {}, {}
    uv1[6], uv2[6], uv3[6], uv4[6] = color, color, color, color

    uv1[1], uv1[2], uv1[3], uv1[4], uv1[5] = -1, y, 10, 0, z
    uv2[1], uv2[2], uv2[3], uv2[4], uv2[5] = 1, y, 10, 512, z
    uv3[1], uv3[2], uv3[3], uv3[4], uv3[5] = 1, y, -6, 512, size + z
    uv4[1], uv4[2], uv4[3], uv4[4], uv4[5] = -1, y, -6, 0, size + z
    RenderTexture("bg_1_floor", "", uv1, uv2, uv3, uv4)
    uv1[2] = y + 1.8
    uv2[2] = y + 1.8
    uv3[2] = y + 1.8
    uv4[2] = y + 1.8
    RenderTexture("bg_1_floor", "", uv1, uv2, uv3, uv4)
    uv1[1], uv1[2], uv1[3], uv1[4], uv1[5] = 1, y + 1.8, 10, z, 0
    uv2[1], uv2[2], uv2[3], uv2[4], uv2[5] = 1, y + 1.8, -6, size + z, 0
    uv3[1], uv3[2], uv3[3], uv3[4], uv3[5] = 1, y, -6, size + z, 390
    uv4[1], uv4[2], uv4[3], uv4[4], uv4[5] = 1, y, 10, z, 390
    RenderTexture("bg_1_wall", "", uv1, uv2, uv3, uv4)
    uv1[1] = -1
    uv2[1] = -1
    uv3[1] = -1
    uv4[1] = -1
    RenderTexture("bg_1_wall", "", uv1, uv2, uv3, uv4)
    SetImageState("white", "", 255, 0, 0, 0)
    Render4V("white", -1, 1.8, 10, 1, 1.8, 10, 1, 0, 10, -1, 0, 10)
    self.leaf:render()
    SetViewMode("world")
end