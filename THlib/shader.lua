LoadFX("fx:gray_color", "assets\\shader\\gray.hlsl")
LoadFX("fx:hue_set", "assets\\shader\\hue_set.hlsl")
LoadFX("fx:brightness_set", "assets\\shader\\brightness_set.hlsl")

LoadFX("fx:SaveScreen", "assets\\shader\\screen_save.hlsl")
LoadFX("fx:alpha", "assets\\shader\\alpha.hlsl")
LoadFX("fx:WORLDROTATE", "assets\\shader\\world_rotate.hlsl")
local M = {}
AE = M

function M.PostEffectGrayColor(tex, alpha, flag)
    flag = flag or 0.0
    PostEffect("fx:gray_color", tex, 6, "", {
        { alpha, flag, 0.0, 0.0 }
    }, {})
end

function M.PostEffectHueSet(tex, Hue, flag, open)
    flag = flag or 1
    open = open or 1.0
    PostEffect("fx:hue_set", tex, 6, "", {
        { Hue, flag, open, 0.0 }
    }, {})
end

function M.PostEffectBrightnessSet(tex, delta)
    PostEffect("fx:brightness_set", tex, 6, "", {
        { delta, 1, 1, 0.0 }
    }, {})
end

local fade_shader = lstg.CreatePostEffectShader("assets\\shader\\fade.hlsl")
function M.FadeAnimation(tex, height, width, A, R, G, B)
    fade_shader:setFloat("height", height)
    fade_shader:setFloat("width", width)
    fade_shader:setFloat4("edge_color", R / 255, G / 255, B / 255, A / 255)
    fade_shader:setTexture("u_texture", tex)
    fade_shader:setTexture("u_texture_h", "fade_effect")
    lstg.PostEffect(fade_shader, "")
end