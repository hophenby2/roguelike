BG_13 = Class(background)

local SetViewMode = SetViewMode
local RenderTexture = RenderTexture
local Color = Color
local Set3D = Set3D
local background = background
local SetImageState = SetImageState
local Render = Render



function BG_13:init()
    local path = "assets\\background\\13\\"
    LoadTexture2("bg_13_floor1", path .. "floor1.png")
    LoadTexture2("bg_13_floor2", path .. "floor2.png")
    LoadTexture2("bg_13_fog1", path .. "fog1.png")
    LoadTexture2("bg_13_fog2", path .. "fog2.png")
    LoadImageFromFile("bg_13_moon", path .. "moon.png")

    background.init(self, false)
    Set3D('eye', 0, 3, -1)
    Set3D('at', 0, 0, 0)
    Set3D('up', 0, 1, 0)
    Set3D('z', 0.1, 50)
    Set3D('fovy', 1)
    Set3D('fog', 7, 20, Color(100, 0, 0, 0))
    self.zos = 0
    self.speed = 1
    SetImageState("bg_13_moon", "mul+add", 230, 255, 255, 255)
    task.New(self, function()
        local a, t = 0, -30
        while true do
            Set3D('eye', sin(a / 9), 3 - sin(a / 2), -1 + 0.1 * sin(a))
            Set3D('at', 0, 0, sin(a / 4)+0.11)
            Set3D('up', 0.2 * sin(a / 3), 1, 0)
            a = a + sin(max(0, t))
            if not self.nosetspeed then
                self.speed = 1 + 2 * sin(t)
            end
            t = min(t + 0.3, 90)
            task.Wait()
        end
    end)
end
function BG_13:frame()
    task.Do(self)
    self.zos = self.zos - self.speed

end

function BG_13:render()
    SetViewMode '3d'
    background.ClearToFogColor()
    local z = self.zos
    local color
    color = Color(255, 70, 70, 70)
    RenderTexture("bg_13_fog1", "",
            { -8, -2, 12, 0, z / 3, color },
            { 8, -2, 12, 4096, z / 3, color },
            { 8, -2, -12, 4096, 6144 + z / 3, color },
            { -8, -2, -12, 0, 6144 + z / 3, color })
    color = Color(50, 255, 255, 255)
    RenderTexture("bg_13_floor1", "mul+add",
            { -8, -2, 12, 0, z, color },
            { 8, -2, 12, 2048, z, color },
            { 8, -2, -12, 2048, 3072 + z, color },
            { -8, -2, -12, 0, 3072 + z, color })
    color = Color(150, 255, 255, 255)
    RenderTexture("bg_13_floor2", "mul+add",
            { -8, -1, 12, 0, z, color },
            { 8, -1, 12, 2048, z, color },
            { 8, -1, -12, 2048, 3072 + z, color },
            { -8, -1, -12, 0, 3072 + z, color })
    color = Color(200, 255, 255, 255)
    RenderTexture("bg_13_floor1", "mul+add",
            { -8, 0, 12, 0, z, color },
            { 8, 0, 12, 2048, z, color },
            { 8, 0, -12, 2048, 3072 + z, color },
            { -8, 0, -12, 0, 3072 + z, color })
    color = Color(80, 255, 255, 255)
    RenderTexture("bg_13_fog2", "mul+add",
            { -8, 1, 12, 0, z / 3, color },
            { 8, 1, 12, 2048, z / 3, color },
            { 8, 1, -12, 2048, 3072 + z / 3, color },
            { -8, 1, -12, 0, 3072 + z / 3, color })


    SetViewMode 'world'
    Render("bg_13_moon", 0, 170)
end