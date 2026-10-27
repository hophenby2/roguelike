--======================================
--杂项
--======================================

---@class misc
misc = {}

----------------------------------------
--杂项功能
---多功能object
---逐渐要被淘汰的
---@class _object
_object = Class(object)
function _object:frame()
    if self.hp <= 0 then
        object.Kill(self)
    end
    task.Do(self)
end
function _object:render()
    SetImgState(self, self._blend, self._a, self._r, self._g, self._b)
    DefaultRenderFunc(self)
end
function _object:set_color(blend, a, r, g, b)
    self._blend, self._a, self._r, self._g, self._b = blend or "", a or 255, r or 255, g or 255, b or 255
end
function _object:del()
    if ParticleGetn(self) > 0 then
        misc.KeepParticle(self)
    end
    object.DelServants(self)
    if not (self.hide or self._a == 0) then
        New(bubble3, self.img, self.x, self.y, self.rot, self.dx, self.dy, self.omega, 15, self.hscale, self.hscale,
                Color(self._a, self._r, self._g, self._b), Color(0, self._r, self._g, self._b), self.layer, self._blend)
    end
end
function _object:kill()
    if ParticleGetn(self) > 0 then
        misc.KeepParticle(self)
    end
    object.KillServants(self)
    if not (self.hide or self._a == 0) then
        New(bubble3, self.img, self.x, self.y, self.rot, self.dx, self.dy, self.omega, 15, self.hscale, self.hscale,
                Color(self._a, self._r, self._g, self._b), Color(0, self._r, self._g, self._b), self.layer, self._blend)
    end
end


--多种消亡特效
hinter = Class(object)
function hinter:init(img, size, x, y, t1, t2, fade)
    self.img = img
    self.x = x
    self.y = y
    self.t1 = t1
    self.t2 = t2
    self.fade = fade
    self.group = GROUP.GHOST
    self.layer = LAYER.TOP
    self.size = size
    self.t = 0
    self.hscale = self.size
end
function hinter:frame()
    if self.timer < self.t1 then
        self.t = self.timer / self.t1
    elseif self.timer < self.t1 + self.t2 then
        self.t = 1
    elseif self.timer < self.t1 * 2 + self.t2 then
        self.t = (self.t1 * 2 + self.t2 - self.timer) / self.t1
    else
        object.Del(self)
    end
end
function hinter:render()
    if self.fade then
        SetImageState(self.img, '', self.t * 255, 255, 255, 255)
        self.vscale = self.size
        object.render(self)
    else
        SetImageState(self.img, '', 255, 255, 255, 255)
        self.vscale = self.t * self.size
        object.render(self)
    end
end

bubble = Class(object)
function bubble:init(img, x, y, life_time, size1, size2, color1, color2, layer, blend)
    self.img = img
    self.x = x
    self.y = y
    self.group = GROUP.GHOST
    self.life_time = life_time
    self.size1 = size1
    self.size2 = size2
    self.color1 = color1
    self.color2 = color2
    self.layer = layer
    self.blend = blend or ''
end
function bubble:render()
    local t = (self.life_time - self.timer) / self.life_time
    SetImageState(self.img, self.blend, self.color1 * t + self.color2 * (1 - t))
    Render(self.img, self.x, self.y, self.rot, self.size1 * t + self.size2 * (1 - t))
end
function bubble:frame()
    if self.timer == self.life_time - 1 then
        object.Del(self)
    end
end

bubble2 = Class(bubble)
function bubble2:init(img, x, y, vx, vy, life_time, size1, size2, color1, color2, layer, blend)
    self.img = img
    self.x = x
    self.y = y
    self.vx = vx
    self.vy = vy
    self.group = GROUP.GHOST
    self.life_time = life_time
    self.size1 = size1
    self.size2 = size2
    self.color1 = color1
    self.color2 = color2
    self.layer = layer
    self.blend = blend or ''
end

--消亡特效（渐隐）
bubble3 = Class(bubble)
function bubble3:init(img, x, y, rot, vx, vy, omega, life_time, size1, size2, color1, color2, layer, blend)
    self.img = img
    self.x = x
    self.y = y
    self.rot = rot
    self.vx = vx
    self.vy = vy
    self.omega = omega
    self.group = GROUP.GHOST
    self.life_time = life_time
    self.size1 = size1
    self.size2 = size2
    self.color1 = color1
    self.color2 = color2
    self.layer = layer
    self.blend = blend or ''
end

---震屏
---fixed by ETC，不再直接改lrbt
---@param time number
---@param size number
function misc.ShakeScreen(time, size, interval, way, fadeout_size_mode)
    local shaker = lstg.tmpvar.shaker
    if shaker then
        shaker.time = time
        shaker.size = size
        shaker.interval = interval or 3
        shaker.way = way or 2.5
        shaker.fadeout_size_mode = fadeout_size_mode
        shaker.timer = 0
    else
        New(shaker_maker, time, size, interval or 3, way or 2.5, fadeout_size_mode)
    end
end

shaker_maker = Class(object)
function shaker_maker:init(time, size, interval, way, fadeout_size_mode)
    lstg.tmpvar.shaker = self
    self.time = time
    self.size = size
    self._size = size
    self.interval = interval
    self.way = way
    self.fadeout_size_mode = fadeout_size_mode
    self.offset = lstg.worldoffset
end
function shaker_maker:frame()
    local a = int(self.timer / self.interval) * 360 / self.way
    self.offset.dx = self.size * cos(a)
    self.offset.dy = self.size * sin(a)
    if self.fadeout_size_mode then
        self.size = self._size * task.SetMode[self.fadeout_size_mode](1 - self.timer / self.time)
    end
    if self.timer >= self.time then
        object.Del(self)
    end
end
function shaker_maker:del()
    self.offset.dx = 0
    self.offset.dy = 0
    lstg.tmpvar.shaker = nil
end
shaker_maker.kill = shaker_maker.del


--tasker
tasker = Class(object)
function tasker:init(f, group)
    self.task = {}
    self.group = group or GROUP.GHOST
    task.New(self, f)
end
function tasker:frame()
    task.Do(self)
    if self.task then
        if coroutine.status(self.task[1]) == 'dead' then
            object.Del(self)
        end
    end
end

tasker2 = Class(object)
function tasker2:init(f, group)
    self.task = {}
    self.isTasker = true
    self.group = group or GROUP.GHOST
    task.New(self, f)
end
function tasker2:frame()
    task.Do(self)
    if self.task then
        if coroutine.status(self.task[1]) == 'dead' then
            object.Del(self)
        end
    end
end


--维持粒子特效直到消失
--！警告：使用了改类功能
function misc.KeepParticle(o)
    o.class = ParticleKepper
    object.Preserve(o)
    ParticleStop(o)
    o.bound = false
    o.group = GROUP.GHOST
end

ParticleKepper = Class(object)
function ParticleKepper:frame()
    if ParticleGetn(self) == 0 then
        object.Del(self)
    end
end

local cos, sin = cos, sin
local RenderTexture = RenderTexture
local Render = Render
local Render4V = Render4V
local RenderRect = RenderRect
local GetTextureSize = GetTextureSize

--一些形状的渲染
---图片组渲染成环状
function misc.RenderRing(img, x, y, r1, r2, rot, n, maximgs)
    local da = 360 / n
    local a
    for i = 1, n do
        a = rot - da * i
        Render4V(img .. ((i - 1) % maximgs + 1),
                r1 * cos(a + da) + x, r1 * sin(a + da) + y, 0.5,
                r2 * cos(a + da) + x, r2 * sin(a + da) + y, 0.5,
                r2 * cos(a) + x, r2 * sin(a) + y, 0.5,
                r1 * cos(a) + x, r1 * sin(a) + y, 0.5)
    end
end

---渲染圆，扇形，环形，环扇形
function misc.SectorRender(x, y, r1, r2, a1, a2, point, rot)
    rot = rot or 0
    local ang = (a2 - a1) / point
    local angle
    for i = 1, point do
        angle = a1 + ang * i + rot
        Render4V('white',
                x + r2 * cos(angle - ang), y + r2 * sin(angle - ang), 0.5,
                x + r1 * cos(angle - ang), y + r1 * sin(angle - ang), 0.5,
                x + r1 * cos(angle), y + r1 * sin(angle), 0.5,
                x + r2 * cos(angle), y + r2 * sin(angle), 0.5)
    end
end

---渲染正矩形边框
function misc.RenderOutLine(img, x1, x2, y1, y2, l_in, l_out)
    RenderRect(img, x1 + l_in, x1 - l_out, y1 + l_out, y2 - l_out)
    RenderRect(img, x2 - l_in, x2 + l_out, y1 + l_out, y2 - l_out)
    RenderRect(img, x1 - l_out, x2 + l_out, y1 - l_in, y1 + l_out)
    RenderRect(img, x1 - l_out, x2 + l_out, y2 + l_in, y2 - l_out)
end

---传入纹理，在矩形范围内渲染拼合图像
function misc.RenderTexInRect(tex, x1, x2, y1, y2, offx, offy, rot, hscale, vscale, blend, color)
    local uw, uh = GetTextureSize(tex)
    local cx, cy = -offx, offy
    cx, cy = cx * cos(rot) - cy * sin(rot), cy * cos(rot) + cx * sin(rot)
    cx, cy = cx + uw / 2, cy + uh / 2
    uw, uh = abs(x2 - x1) / 2 / hscale, abs(y2 - y1) / 2 / vscale
    local c, s = cos(-rot), sin(-rot)
    RenderTexture(tex, blend,
            { x1, y2, 0.5, cx - uw * c - uh * s, cy - uh * c + uw * s, color },
            { x2, y2, 0.5, cx + uw * c - uh * s, cy - uh * c - uw * s, color },
            { x2, y1, 0.5, cx + uw * c + uh * s, cy + uh * c - uw * s, color },
            { x1, y1, 0.5, cx - uw * c + uh * s, cy + uh * c + uw * s, color })
end

function misc.RenderTexInCircle(tex, x, y, ux, uy, radius, rot, scale, blend, color, cut)
    local angle
    local ang = 360 / cut / 2
    local uv1, uv2, uv3, uv4 = { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }
    uv2[1], uv2[2], uv2[4], uv2[5], uv2[6] = x, y, ux, uy, color
    uv3[1], uv3[2], uv3[4], uv3[5], uv3[6] = x, y, ux, uy, color
    uv1[6] = color
    uv4[6] = color
    local uradius = radius / scale
    for a = 1, cut do
        angle = rot + 360 / cut * a
        uv1[1], uv1[2] = x + radius * cos(angle + ang), y + radius * sin(angle + ang)
        uv1[4], uv1[5] = ux + uradius * cos(angle + ang), uy - uradius * sin(angle + ang)
        uv4[1], uv4[2] = x + radius * cos(angle - ang), y + radius * sin(angle - ang)
        uv4[4], uv4[5] = ux + uradius * cos(angle - ang), uy - uradius * sin(angle - ang)
        RenderTexture(tex, blend, uv1, uv2, uv3, uv4)
    end
end

local DefaultColor = Color(255, 255, 255, 255)
local DefaultBlend = ""
local uv1, uv2, uv3, uv4 = { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }
---极坐标扩散渲染
---@param count number@一圈的图片数
---@param color lstg.Color@圆心颜色或整体颜色
---@param color2 lstg.Color@扩散颜色
function misc.PolarCoordinatesRender(tex, x, y, r1, r2, rot, n, count, spread, blend, color, color2)
    blend = blend or DefaultBlend
    color = color or DefaultColor
    color2 = color2 or color
    local texl = GetTextureSize(tex)
    local da = 360 / n
    local h = 0
    local _h = texl / n * count
    local height = r2 - r1
    uv1[5], uv1[6] = spread, color
    uv2[5], uv2[6] = spread, color
    uv3[5], uv3[6] = spread + height, color2
    uv4[5], uv4[6] = spread + height, color2
    for _ = 1, n do
        uv1[1], uv1[2], uv1[4] = x + r1 * cos(rot), y + r1 * sin(rot), h
        uv2[1], uv2[2], uv2[4] = x + r1 * cos(rot - da), y + r1 * sin(rot - da), h + _h
        uv3[1], uv3[2], uv3[4] = x + r2 * cos(rot - da), y + r2 * sin(rot - da), h + _h
        uv4[1], uv4[2], uv4[4] = x + r2 * cos(rot), y + r2 * sin(rot), h
        RenderTexture(tex, blend, uv1, uv2, uv3, uv4)
        rot = rot - da
        h = h + _h
    end
end

---用纹理以Render的形式渲染
function misc.RenderTexInSize(tex, x, y, rot, hscale, vscale, blend, color)
    blend = blend or DefaultBlend
    color = color or DefaultColor
    local w, h = GetTextureSize(tex)
    local cosr, sinr = cos(rot), sin(rot)
    local _w, _h = w * hscale / 2, h * vscale / 2
    uv1[1], uv1[2], uv1[4], uv1[5], uv1[6] = x - cosr * _w - sinr * _h, y + cosr * _h - sinr * _w, 0, 0, color
    uv2[1], uv2[2], uv2[4], uv2[5], uv2[6] = x + cosr * _w - sinr * _h, y + cosr * _h + sinr * _w, w, 0, color
    uv3[1], uv3[2], uv3[4], uv3[5], uv3[6] = x + cosr * _w + sinr * _h, y - cosr * _h + sinr * _w, w, h, color
    uv4[1], uv4[2], uv4[4], uv4[5], uv4[6] = x - cosr * _w + sinr * _h, y - cosr * _h - sinr * _w, 0, h, color
    RenderTexture(tex, blend, uv1, uv2, uv3, uv4)
end
local deg = math.deg
local atan2 = math.atan2
local Dist = Dist
local function GetDist(a, b)
    if IsValid(a) and IsValid(b) then
        return Dist(a, b)
    elseif a.x and b.x then
        return hypot(a.x - b.x, a.y - b.y)
    end
end

---描点连线
---@param img string@建议"white"
---@param line table@由obj组成的一个数组
---@param width number@线条宽度
---@param close boolean@封闭图形
function misc.RenderPointLine(img, line, width, close)
    if #line > 1 then
        local rot, len, x1, y1, x2, y2
        for i = 1, #line - 1 do
            x1, y1, x2, y2 = line[i].x, line[i].y, line[i + 1].x, line[i + 1].y
            x2, y2 = x2 - x1, y2 - y1
            rot = deg(atan2(y2, x2))
            len = GetDist(line[i], line[i + 1])
            Render(img, x1 + x2 / 2, y1 + y2 / 2, rot, len / 16, width / 8)
        end
        if close then
            x1, y1, x2, y2 = line[1].x, line[1].y, line[#line].x, line[#line].y
            x2, y2 = x2 - x1, y2 - y1
            rot = deg(atan2(y2, x2))
            len = GetDist(line[1], line[#line])
            Render(img, x1 + x2 / 2, y1 + y2 / 2, rot, len / 16, width / 8)
        end
    end
end

---简易翻转屏幕
---@param texname string@所用的rendertarget
---@param from number@初图层，默认BG-1
---@param to number@末图层，默认TOP-1
---@return object@任意操控x,y,hscale,vscale,rot等的对象
function misc.RotateWorld(texname, from, to)
    CreateRenderTarget(texname)
    local begin = New({
        function(self)
            self.layer = from or -702
            self.tex = texname
        end,
        function()
        end,
        function()
        end,
        function(self)
            PushRenderTarget(self.tex)
            RenderClear(Color(255, 0, 0, 0))
        end,
        function()
        end,
        function()
        end,
        is_class = true,
        base = object
    })
    local final = New({
        function(self)
            self.bound = false
            self.layer = to or -1
            self.hscale = 1
            self.vscale = 1
            self.tex = texname
            self.rot = 0
            self.uv1, self.uv2, self.uv3, self.uv4 = { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }
            local color = Color(255, 255, 255, 255)
            local k = screen.scale
            local w = lstg.world
            self.uv1[4], self.uv1[5] = WorldToScreen(w.l, w.t)
            self.uv2[4], self.uv2[5] = WorldToScreen(w.r, w.t)
            self.uv3[4], self.uv3[5] = WorldToScreen(w.r, w.b)
            self.uv4[4], self.uv4[5] = WorldToScreen(w.l, w.b)
            self.uv1[6] = color
            self.uv2[6] = color
            self.uv3[6] = color
            self.uv4[6] = color
        end,
        function()
            object.RawDel(begin)
        end,
        function()
        end,
        function(self)
            PopRenderTarget(self.tex)
            local x, y = self.x, self.y
            local w = lstg.world
            local cosr, sinr = cos(self.rot), sin(self.rot)
            local _w, _h = self.hscale * w.r, self.vscale * w.t
            self.uv1[1], self.uv1[2] = x - cosr * _w - sinr * _h, y + cosr * _h - sinr * _w
            self.uv2[1], self.uv2[2] = x + cosr * _w - sinr * _h, y + cosr * _h + sinr * _w
            self.uv3[1], self.uv3[2] = x + cosr * _w + sinr * _h, y - cosr * _h + sinr * _w
            self.uv4[1], self.uv4[2] = x - cosr * _w + sinr * _h, y - cosr * _h - sinr * _w
            RenderTexture(self.tex, "one", self.uv1, self.uv2, self.uv3, self.uv4)
        end,
        function()
        end,
        function()
            object.RawDel(begin)
        end,
        is_class = true,
        base = object
    })
    --object.Connect(final, begin, 0, true)
    return final
end

function misc.RenderBrightOutline(x1, x2, y1, y2, ws, alpha, r, g, b, blend)
    blend = blend or "mul+add"
    local col1 = Color(0, r, g, b)
    local col2 = Color(alpha, r, g, b)
    SetImageState("white", "mul+add", 666, 0, 0, 0)--刷新存储列表
    OriginalSetImageState("white", blend, col1, col1, col2, col2)
    RenderRect("white", x1, x2, y1, y1 + ws)
    RenderRect("white", x1, x2, y2, y2 - ws)
    OriginalSetImageState("white", blend, col2, col1, col1, col2)
    RenderRect("white", x1, x1 + ws, y1, y2)
    RenderRect("white", x2, x2 - ws, y1, y2)

end


---渲染圆角矩形
function misc.RenderRoundedRect(x1, x2, y1, y2, rr, point)
    point = point or 1

    RenderRect("white", x1 + rr, x2 - rr, y1 + rr, y2 - rr)
    RenderRect("white", x1 + rr, x2 - rr, y1, y1 + rr)
    RenderRect("white", x1 + rr, x2 - rr, y2 - rr, y2)
    RenderRect("white", x1, x1 + rr, y1 + rr, y2 - rr)
    RenderRect("white", x2 - rr, x2, y1 + rr, y2 - rr)
    misc.SectorRender(x1 + rr, y2 - rr, 0, rr, 90, 180, point, 0)
    misc.SectorRender(x2 - rr, y2 - rr, 0, rr, 0, 90, point, 0)
    misc.SectorRender(x1 + rr, y1 + rr, 0, rr, 180, 270, point, 0)
    misc.SectorRender(x2 - rr, y1 + rr, 0, rr, 270, 360, point, 0)
end

---渲染圆角矩形描边
function misc.RenderRoundedRectOutline(x1, x2, y1, y2, rr, outline, point)
    point = point or 1
    RenderRect("white", x1 + rr, x2 - rr, y1, y1 + outline)
    RenderRect("white", x1 + rr, x2 - rr, y2 - outline, y2)
    RenderRect("white", x1, x1 + outline, y1 + rr, y2 - rr)
    RenderRect("white", x2 - outline, x2, y1 + rr, y2 - rr)
    misc.SectorRender(x1 + rr, y2 - rr, rr - outline, rr, 90, 180, point, 0)
    misc.SectorRender(x2 - rr, y2 - rr, rr - outline, rr, 0, 90, point, 0)
    misc.SectorRender(x1 + rr, y1 + rr, rr - outline, rr, 180, 270, point, 0)
    misc.SectorRender(x2 - rr, y1 + rr, rr - outline, rr, 270, 360, point, 0)
end

----------------------------------------
--资源加载

--一些乱七八糟的东西
LoadTexture("misc", "assets\\misc\\misc.png", true)

LoadImageGroup("bubble", "misc", 192, 0, 64, 64, 1, 4)
LoadImage("leaf", "misc", 0, 32, 32, 32)
LoadImage("white", "misc", 56, 8, 16, 16)

--预制粒子特效图片
LoadTexture("particles", "assets\\misc\\particles.png")
LoadImageGroup("parimg", 'particles', 0, 0, 32, 32, 4, 4)
--空图片
LoadImageFromFile("img_void", "assets\\misc\\img_void.png")
