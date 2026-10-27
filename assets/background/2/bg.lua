local SetImageState = SetImageState
local SetViewMode = SetViewMode
local Render = Render
local RenderTexture = RenderTexture
local Color = Color
local background = background



BG_2 = Class(background)

function BG_2:init()
    local path = "assets\\background\\2\\"
    LoadTexture2("bg_2_mask", path .. "mask.png")
    LoadImageFromFile("bg_2_moon", path .. "moon.png")

    SetImageState("bg_2_moon", "", 150, 255, 255, 255)
    background.init(self, false)
end

function BG_2:render()
    SetViewMode 'world'
    Render("bg_2_moon", 32, 100, 0)
    local t = self.timer
    local c
    c = Color(150, 250, 128, 114)
    local uv1, uv2, uv3, uv4 = { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }
    uv1[6], uv2[6], uv3[6], uv4[6] = c, c, c, c

    uv1[1], uv1[2], uv1[4], uv1[5] = 350, -350, 0 - t / 2, 0
    uv2[1], uv2[2], uv2[4], uv2[5] = -350, -350, 256 - t / 2, 0
    uv3[1], uv3[2], uv3[4], uv3[5] = -350, 350, 256 - t / 2, 256
    uv4[1], uv4[2], uv4[4], uv4[5] = 350, 350, 0 - t / 2, 256
    RenderTexture("bg_2_mask", "mul+add", uv1, uv2, uv3, uv4)
    c = Color(80, 230, 240, 235)
    uv1[6], uv2[6], uv3[6], uv4[6] = c, c, c, c

    uv1[1], uv1[2], uv1[4], uv1[5] = 320, -320, 0 - t - 50, 0
    uv2[1], uv2[2], uv2[4], uv2[5] = -320, -320, 256 - t - 50, 0
    uv3[1], uv3[2], uv3[4], uv3[5] = -320, 320, 256 - t - 50, 256
    uv4[1], uv4[2], uv4[4], uv4[5] = 320, 320, 0 - t - 50, 256
    RenderTexture("bg_2_mask", "mul+add", uv1, uv2, uv3, uv4)
end
