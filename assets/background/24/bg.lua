local SetViewMode = SetViewMode
local Color = Color
local Set3D = Set3D
local cos, sin = cos, sin
local background = background
local SetImageState = SetImageState
local Render4V = Render4V

BG_24 = Class(background)

function BG_24:init()
    local path = "assets\\background\\24\\"
    LoadImageFromFile("bg_24", path .. "bg.png")
    LoadTexture2("bg_24_bright", path .. "bright.png")
    --
    background.init(self, false)

    self.offx, self.offy = 0, -50
    self.x, self.y = self.offx, self.offy
    self.rot = 0
    self.scale = 0.7
    self.spread = 0
    self.speed = 1
end

function BG_24:frame()
    task.Do(self)
    local t = self.timer
    self.x = self.offx + sin(t / 2) * 7
    self.y = self.offy + sin(t / 3) * 8
    self.spread = self.spread - self.speed
end

function BG_24:render()
    SetViewMode("world")
    local x, y, rot, scale = self.x, self.y, self.rot, self.scale
    local t = self.timer
    Render("bg_24", x, y, rot, scale)
    local cx, cy = x - 148 * sin(rot) * scale, self.y + 148 * cos(rot) * scale
    misc.PolarCoordinatesRender("bg_24_bright", cx, cy, 0, 500,
            t / 10, 512, 1, self.spread, "mul+add",
            Color(255, 65, 50, 100))

end

