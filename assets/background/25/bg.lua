local SetViewMode = SetViewMode
local Color = Color
local Set3D = Set3D
local sin = sin
local background = background
local SetImageState = SetImageState
local Render4V = Render4V

BG_25 = Class(background)

function BG_25:init()
    local path = "assets\\background\\25\\"
    LoadImageFromFile("bg_25_back", path .. "back.png")
    LoadImageFromFile("bg_25_water", path .. "water.png")

    background.init(self, false)
    Set3D('eye', 0, 1, 0)
    Set3D('at', 0, 5, -5)
    Set3D('up', 0, 1, 0)
    Set3D('z', 0.1, 24)
    Set3D('fovy', 0.7)
    Set3D('fog', 2, 8, Color(100, 70, 91, 103))
    self.tos = 0
    self.speed = 0.005
    self.alpha = 255
    self.eye_y = 1
end

function BG_25:frame()
    self.tos = self.tos + self.speed
    Set3D('at', 1 + sin(self.timer / 8) * 2, 0, -2.5 - sin(self.timer / 10))
    Set3D('eye', 0.4 + sin(self.timer / 4), 3, -0.9 - sin(self.timer / 7) * 2)

end

function BG_25:render()
    SetViewMode '3d'
    background.ClearToFogColor()
    local z = self.tos % 4

    SetImageState('bg_25_water', '', self.alpha / 3, 255, 255, 255)
    SetImageState('bg_25_back', '', self.alpha, 255, 255, 255)
    for x = -12, 12, 4 do
        Render4V('bg_25_water', -2 + x + z, -0.5, 2, 2 + x + z, -0.5, 2, 2 + x + z, -0.5, -2, -2 + x + z, -0.5, -2)
        Render4V('bg_25_water', 2 + x + z, -0.5, 2, -2 + x + z, -0.5, 2, -2 + x + z, -0.5, 6, 2 + x + z, -0.5, 6)
        Render4V('bg_25_water', 2 + x + z, -0.5, -6, -2 + x + z, -0.5, -6, -2 + x + z, -0.5, -2, 2 + x + z, -0.5, -2)
        Render4V('bg_25_water', -2 + x - z, -0.5, 2, 2 + x - z, -0.5, 2, 2 + x - z, -0.5, -2, -2 + x - z, -0.5, -2)
        Render4V('bg_25_water', 2 + x - z, -0.5, 2, -2 + x - z, -0.5, 2, -2 + x - z, -0.5, 6, 2 + x - z, -0.5, 6)
        Render4V('bg_25_water', 2 + x - z, -0.5, -6, -2 + x - z, -0.5, -6, -2 + x - z, -0.5, -2, 2 + x - z, -0.5, -2)
    end
    for x = -12, 12, 4 do
        Render4V('bg_25_back', -2 + x, 0, 2, 2 + x, 0, 2, 2 + x, 0, -2, -2 + x, 0, -2)
        Render4V('bg_25_back', 2 + x, 0, 2, -2 + x, 0, 2, -2 + x, 0, 6, 2 + x, 0, 6)
        Render4V('bg_25_back', 2 + x, 0, -6, -2 + x, 0, -6, -2 + x, 0, -2, 2 + x, 0, -2)
        Render4V('bg_25_back', -2 + x, 0, -6, 2 + x, 0, -6, 2 + x, 0, -10, -2 + x, 0, -10)
    end

    SetViewMode 'world'


end