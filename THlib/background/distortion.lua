local cos, sin, Color, screen, abs = cos, sin, Color, screen, abs
local Forbid = clamp
local min = min
local PushRenderTarget = PushRenderTarget
local PopRenderTarget = PopRenderTarget
local RenderClear = RenderClear
local RenderTexture = RenderTexture
local Dist, Angle = Dist, Angle
local WorldToScreen = WorldToScreen
local PostEffect = PostEffect

--@扭曲本体
distortion_effect_object = Class(object)
CreateRenderTarget("addon")
function distortion_effect_object:init(target, r1, color, LAYER_ADDON, x_range_speed_adder, z_range_speed_adder)
    self.layer = LAYER.BG + 1.1 + (LAYER_ADDON or 0)
    self.group = GROUP.GHOST
    self.bound = false
    self.wavetimer = 0
    local r = r1 + 8
    ------------------

    ------------------
    --self.res = "WorldTex1"
    ------------------
    self.xcut, self.ycut = 12, 12--横向切割数,纵向切割数
    ------------------
    self.wy = r * (sqrt(17) / 4) * (7 / 8) - 1
    self.alphar = (sqrt(17) / 4) * r * (7 / 8) - 1

    self.mratio = 1

    self.maxalpha = 255
    ------------------
    self.master = target

    self.xpara = x_range_speed_adder or { 12, 10.5, -90 }
    self.zpara = z_range_speed_adder or { 12, 5.25, 45 }

    self.wavecolor = color or { 224, 0, 0 }
    ------------------
    self.nek = 1
    self.etimer = 0
    self.cx, self.cy = self.master.x, self.master.y
    self.speed = 2
    self.exr = 0
    self.er = 0
    self.fr = 16
    self.r = r
    self.bl = (self.r / self.fr)
    self.radius = 0
    self.radius_k = 0
    self.x = 0
    self.y = 0
    self.swk = 1

    self.exratio_r = 30
    self.tk = 0

    self.shake = 0
    self.list = { 60, 32 }
    ------------------
    self.uxcut, self.uycut = (self.fr * 2) / (self.xcut), (self.fr * 2) / (self.ycut)
    self.xpos = {}
    self.zpos = {}

    self.pos = 1
    self.sqrt2 = SQRT2
    self.phasex = -45
    self.phasey = -90
    self.nerk = 1
    self.blank = Color(255, 255, 255, 255)
    self.aglist = { {}, {}, {}, {} }
    self.distlist = { {}, {}, {}, {} }
    self.distlist2 = { {}, {}, {}, {} }
    ------------------
    local xcut = self.fr * 2 / self.xcut
    local ycut = self.fr * 2 / self.ycut
    local ax, ay = self.cx + self.fr, self.cy + self.fr

    local xcut2 = 2 / self.xcut
    local ycut2 = 2 / self.ycut
    local ax2, ay2 = self.cx + 1, self.cy + 1

    local c
    local pt = {}
    local pt2 = {}

    local cache = { { 0, 0 }, { 1, 0 }, { 1, 1 }, { 0, 1 } }
    local Xcut = self.xcut
    local xpara = self.xpara
    local zpara = self.zpara
    local aglist = self.aglist
    local distlist = self.distlist
    local distlist2 = self.distlist2
    local x, y = self.cx, self.cy
    for h = 0, self.ycut do
        for w = 0, Xcut do
            c = w + 1 + h * Xcut
            self.zpos[w + 1] = { w * zpara[3], (w + 1) * zpara[3] }
            self.xpos[w + 1] = { w * xpara[3], (w + 1) * xpara[3] }
            ------------------------------
            for i = 1, 4 do
                pt[i] = { ax - xcut * (w + cache[i][1]), ay - ycut * (h + cache[i][2]) }
                pt2[i] = { ax2 - xcut2 * (w + cache[i][1]), ay2 - ycut2 * (h + cache[i][2]) }
                distlist[i][c] = Dist(pt[i][1], pt[i][2], x, y)
                distlist2[i][c] = Dist(pt2[i][1], pt2[i][2], x, y)
                aglist[i][c] = Angle(x, y, pt[i][1], pt[i][2])
            end
        end
    end
    self.cache = { { 0, 0 }, { 1, 0 }, { 1, 1 }, { 0, 1 } }
    self.cache2 = { 1, 2, 2, 1 }
    self._vx = {}
    self._vy = {}
    self._col = {}

    self._uv1, self._uv2, self._uv3, self._uv4 = { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }
    local _color = Color(255, 255, 255, 255)
    local w = lstg.world
    self._uv1[1], self._uv1[2] = w.l, w.t
    self._uv2[1], self._uv2[2] = w.r, w.t
    self._uv3[1], self._uv3[2] = w.r, w.b
    self._uv4[1], self._uv4[2] = w.l, w.b
    self._uv1[4], self._uv1[5] = WorldToScreen(w.l, w.t)
    self._uv2[4], self._uv2[5] = WorldToScreen(w.r, w.t)
    self._uv3[4], self._uv3[5] = WorldToScreen(w.r, w.b)
    self._uv4[4], self._uv4[5] = WorldToScreen(w.l, w.b)
    self._uv1[6] = _color
    self._uv2[6] = _color
    self._uv3[6] = _color
    self._uv4[6] = _color
end

function distortion_effect_object:frame()
    if IsValid(self.master) then
        self.cx = self.master.x
        self.cy = self.master.y
        if self.master.diston then
            self.wavetimer = self.wavetimer + 1
            self.etimer = self.etimer + 1
            self.radius = min(self.etimer * self.speed, self.r)
            self.tk = self.radius / self.r
            self.radius_k = Forbid(self.tk, 0, 1)
            self.exr = min(self.radius, self.list[1])
        else
            self.etimer = Forbid(self.etimer - 1, 0, 60)
            self.radius = min(self.etimer * self.speed, self.r)
            self.tk = self.radius / self.r
            self.radius_k = Forbid(self.tk, 0, 1)
            self.exr = min(self.radius, self.list[1])
            self.radius = self.fr
            self.exr = 0
        end
    else
        object.Del(self)
    end
end

function distortion_effect_object:render()
    if self.etimer > 0 then
        local lw = lstg.world
        local Xcut = self.xcut
        local k = self.radius_k
        local R = self.r
        local wavetimer = self.wavetimer
        local wavecolor = self.wavecolor
        local vx = self._vx
        local vy = self._vy
        local col = self._col
        local res = "WorldTex1"
        local res2 = "WorldTex1"
        local x, y = self.cx, self.cy
        local cache = self.cache
        local cache2 = self.cache2
        local list = self.list
        local sqrt2 = self.sqrt2
        local alphar = self.alphar
        local emptycolor = self.blank
        local maxalpha = self.maxalpha
        local r = self.radius
        local scale = screen.scale
        local BL = self.bl
        local xpara = self.xpara
        local zpara = self.zpara
        local phasex = self.phasex
        local phasey = self.phasey
        local tk = self.tk
        local nek = self.nek
        local xpos = self.xpos
        local zpos = self.zpos
        local aglist = self.aglist
        local distlist = self.distlist
        local distlist2 = self.distlist2

        local bl = 1 + (BL - 1) * k
        local xcut = self.uxcut * bl
        local ycut = self.uycut * bl
        local ax, ay = x + self.fr * bl, y + self.fr * bl
        local ox, oy = WorldToScreen(ax, ay)

    --    PushRenderTarget(res2)
      --  RenderClear(Color(0, 0, 0, 0))

        local ek, angle, dis, dis2
        local ratio, ratio1
        local cratio, sw_ratio, sw_ratio2
        local swingx, swingy

        local c
        local S--一些暂时存起来需要相乘的东西
        local uv1, uv2, uv3, uv4 = { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }
        for h = 0, self.ycut - 1 do
            for w = 0, Xcut - 1 do
                c = w + 1 + h * Xcut
                for i = 1, 4 do
                    dis = distlist[i][c] * bl
                    dis2 = distlist[i][c] * BL
                    do
                        if abs(dis) <= R then
                            ratio = Forbid((r - dis) / r, 0, 1) * min(k + 0.1, 1)
                            S = Forbid((90 - dis) / 90, 0, 1)
                            ratio1 = S * S * S
                        else
                            ratio = 0
                            ratio1 = 0
                        end
                        S = Forbid((120 - dis) / 120, 0, 1)
                        sw_ratio = S * S * min(k, 1)

                        sw_ratio2 = Forbid((r - 16 - dis) / r, 0, 1)
                        S = min(ratio, 1)
                        ek = distlist2[i][c] * tk * R * (1 + nek * S * S + ratio1 * 0.4)

                        swingx = cos(wavetimer * xpara[2] + xpos[w + 1][cache2[i]] + phasex) * xpara[1]
                        swingy = sin(wavetimer * zpara[2] + zpos[w + 1][cache2[i]] + phasey) * zpara[1]
                        angle = aglist[i][c]

                        if dis2 <= 20 * sqrt2 then
                            if dis2 <= 10 then
                                vx[i] = x + ek * cos(angle) + swingx * (sw_ratio2 * 1.6 - sw_ratio)
                                vy[i] = y + (ek + list[2] * ratio1) * sin(angle) + swingy * sw_ratio2
                            else
                                vx[i] = x + (ek + list[2] * ratio1) * cos(angle) + swingx * (sw_ratio2 * 1.6 - sw_ratio)
                                vy[i] = y + (ek + list[2] * ratio1) * sin(angle) + swingy * sw_ratio2
                            end
                        else
                            if ax - xcut * (w + cache[i][1]) == x then
                                vx[i] = x + (ek + list[2] * ratio1) * cos(angle) + swingx * (sw_ratio2 * 1.6 - sw_ratio * 1.2)
                                vy[i] = y + (ek + list[2] * ratio1) * sin(angle) + swingy * sw_ratio2
                            else
                                vx[i] = x + (ek + list[2] * ratio1) * cos(angle) + swingx * (sw_ratio2 * 1.6 - sw_ratio * 1.2)
                                vy[i] = y + ek * sin(angle) + swingy * sw_ratio2
                            end
                        end
                    end
                    if dis >= alphar * k then
                        col[i] = emptycolor
                    else
                        S = 1 - Forbid((r - dis) / r, 0, 1)
                        cratio = S
                        col[i] = Color(255 or maxalpha * Forbid((r - dis) / r, 0, 1),
                                wavecolor[1] + (255 - wavecolor[1]) * cratio,
                                wavecolor[2] + (255 - wavecolor[2]) * cratio,
                                wavecolor[3] + (255 - wavecolor[3]) * cratio)
                    end
                end
                -----------------------------

                --[[
                vx[1] = Forbid(vx[1], lw.l, lw.r)
                vx[2] = Forbid(vx[2], lw.l, lw.r)
                vx[3] = Forbid(vx[3], lw.l, lw.r)
                vx[4] = Forbid(vx[4], lw.l, lw.r)
                vy[1] = Forbid(vy[1], lw.b, lw.t)
                vy[2] = Forbid(vy[2], lw.b, lw.t)
                vy[3] = Forbid(vy[3], lw.b, lw.t)
                vy[4] = Forbid(vy[4], lw.b, lw.t)--]]
                uv1[1], uv1[2], uv1[4], uv1[5], uv1[6] = vx[1], vy[1], ox - xcut * w * scale, oy + ycut * h * scale, col[1]
                uv2[1], uv2[2], uv2[4], uv2[5], uv2[6] = vx[2], vy[2], ox - xcut * (w + 1) * scale, oy + ycut * h * scale, col[2]
                uv3[1], uv3[2], uv3[4], uv3[5], uv3[6] = vx[3], vy[3], ox - xcut * (w + 1) * scale, oy + ycut * (h + 1) * scale, col[3]
                uv4[1], uv4[2], uv4[4], uv4[5], uv4[6] = vx[4], vy[4], ox - xcut * w * scale, oy + ycut * (h + 1) * scale, col[4]
                RenderTexture(res, '', uv1, uv2, uv3, uv4)
            end
        end

     --   PopRenderTarget(res2)
     --   RenderTexture(res2, "", self._uv1, self._uv2, self._uv3, self._uv4)
        --[[      x, y = WorldToScreen(x, y)

              PostEffect("fx:alpha", res2, 6, "", {
                  { x, y, 0.0, 0.0 }, -- centerx, centery, 未使用, 未使用
                  -- ScrScale = screen.scale,
              }, {})--]]
    end
end
