---=====================================
---luastg screen
---=====================================

----------------------------------------
---api

local function setViewportAndScissorRect(l, r, b, t)
    SetViewport(l, r, b, t)
    if SetScissorRect then
        SetScissorRect(l, r, b, t)
    end
end

----------------------------------------
---screen

---@class screen
screen = {}
local FullW, FullH = GetFullScreenResolution()

function ResetScreen()
    local set = setting
    local scr = screen
    local l = lstg
    --16:9
    local resx, resy = set.resx, set.resy
    if not set.windowed then
        resx, resy = FullW, FullH
    end
    scr.width = 960
    scr.height = 540
    scr.hScale = resx / scr.width
    scr.vScale = resy / scr.height
    scr.resScale = resx / resy
    scr.scale = math.min(scr.hScale, scr.vScale)
    if scr.resScale >= (scr.width / scr.height) then
        scr.dx = (resx - scr.scale * scr.width) * 0.5
        scr.dy = 0
    else
        scr.dx = 0
        scr.dy = (resy - scr.scale * scr.height) * 0.5
    end
    l.scale_3d = 0.007 * scr.scale
    ResetWorld()
    ResetWorldOffset()
    if ext and ext.OtherScreenEff then
        ext.OtherScreenEff:ResetUV()
    end
end

local RAW_DEFAULT_WORLD = {--默认的world参数，只读
    l = -320, r = 320, b = -240, t = 240,
    boundl = -352, boundr = 352, boundb = -272, boundt = 272,
    scrl = 160, scrr = 800, scrb = 30, scrt = 510,
    pl = -320, pr = 320, pb = -240, pt = 240,
    world = 15,
}
local DEFAULT_WORLD = {--默认的world参数，可更改
    l = -320, r = 320, b = -240, t = 240,
    boundl = -352, boundr = 352, boundb = -272, boundt = 272,
    scrl = 160, scrr = 800, scrb = 30, scrt = 510,
    pl = -320, pr = 320, pb = -240, pt = 240,
    world = 15,
}

---用于设置默认world参数
function OriginalSetDefaultWorld(l, r, b, t, bl, br, bb, bt, sl, sr, sb, st, pl, pr, pb, pt, m)
    DEFAULT_WORLD = {
        l = l, r = r, b = b, t = t,
        boundl = bl, boundr = br, boundb = bb, boundt = bt,
        scrl = sl, scrr = sr, scrb = sb, scrt = st,
        pl = pl, pr = pr, pb = pb, pt = pt,
        world = m
    }
end

function SetDefaultWorld(l, b, w, h, bound, m)
    OriginalSetDefaultWorld(-w / 2, w / 2, -h / 2, h / 2,
            -w / 2 - bound, w / 2 + bound, -h / 2 - bound, h / 2 + bound,
            l, l + w, b, b + h,
            -w / 2, w / 2, -h / 2, h / 2,
            m)
end

---用于重置world参数
function RawGetDefaultWorld()
    local w = {}
    for k, v in pairs(RAW_DEFAULT_WORLD) do
        w[k] = v
    end
    return w
end

function GetDefaultWorld()
    local w = {}
    for k, v in pairs(DEFAULT_WORLD) do
        w[k] = v
    end
    return w
end

function RawResetWorld()
    local w = {}
    for k, v in pairs(RAW_DEFAULT_WORLD) do
        w[k] = v
    end
    lstg.world = w
    DEFAULT_WORLD = w
    SetBound(lstg.world.boundl, lstg.world.boundr, lstg.world.boundb, lstg.world.boundt)
end

function ResetWorld()
    local w = {}
    for k, v in pairs(DEFAULT_WORLD) do
        w[k] = v
    end
    lstg.world = w
    SetBound(lstg.world.boundl, lstg.world.boundr, lstg.world.boundb, lstg.world.boundt)
end

---用于设置world参数
function OriginalSetWorld(l, r, b, t, bl, br, bb, bt, sl, sr, sb, st, pl, pr, pb, pt, m)
    local w = lstg.world
    w.l = l
    w.r = r
    w.b = b
    w.t = t
    w.boundl = bl
    w.boundr = br
    w.boundb = bb
    w.boundt = bt
    w.scrl = sl
    w.scrr = sr
    w.scrb = sb
    w.scrt = st
    w.pl = pl
    w.pr = pr
    w.pb = pb
    w.pt = pt
    w.world = m
end

function SetWorld(l, b, w, h, bound, m)
    l = l or 160
    b = b or 30
    w = w or 640
    h = h or 480
    bound = bound or 32
    m = m or 15
    OriginalSetWorld(-w / 2, w / 2, -h / 2, h / 2,
            -w / 2 - bound, w / 2 + bound, -h / 2 - bound, h / 2 + bound,
            l, l + w, b, b + h,
            -w / 2, w / 2, -h / 2, h / 2,
            m)
    SetBound(lstg.world.boundl, lstg.world.boundr, lstg.world.boundb, lstg.world.boundt)
end

----------------------------------------
---3d

lstg.view3d = {
    eye = { 0, 0, -1 },
    at = { 0, 0, 0 },
    up = { 0, 1, 0 },
    fovy = PI_2,
    z = { 0.01, 100 },
    fog = { 0, 0, Color(0xFF000000) },
}

function Reset3D()
    local d = lstg.view3d
    d.eye = { 0, 0, -1 }
    d.at = { 0, 0, 0 }
    d.up = { 0, 1, 0 }
    d.fovy = PI_2
    d.z = { 0.01, 100 }
    d.fog = { 0, 0, Color(0xFF000000) }
end

function Set3D(key, a, b, c)
    if key == 'eye' then
        lstg.view3d.eye = { a, b, c }
    elseif key == 'at' then
        lstg.view3d.at = { a, b, c }
    elseif key == 'up' then
        lstg.view3d.up = { a, b, c }
    elseif key == 'fovy' then
        lstg.view3d.fovy = a
    elseif key == 'z' then
        assert(a > 0.00001 and b > a)
        lstg.view3d.z = { a, b }
    elseif key == 'fog' then
        local d = lstg.Color(0) -- 复制一个 Color
        d.a = 255 -- 模拟旧版本引擎的行为，雾颜色的 A 通道永远为 255
        d.r = c.r
        d.g = c.g
        d.b = c.b
        lstg.view3d.fog = { a, b, d }
    end
end

----------------------------------------
---视口、投影等的转换和坐标映射
local sqrt = sqrt
local tan = math.tan
local SetViewport = setViewportAndScissorRect
local SetPerspective = SetPerspective
local SetFog = SetFog
local SetImageScale = SetImageScale
local SetOrtho = SetOrtho
local unpack = unpack
local lstg = lstg
local s = screen
function SetViewMode(mode)
    lstg.viewmode = mode
    if mode == '3d' then
        local d = lstg.view3d
        local w = lstg.world
        local scale = s.scale
        local eye = d.eye
        local at = d.at
        local up = d.up
        local z = d.z
        local fovy = d.fovy
        SetViewport(w.scrl * scale + s.dx, w.scrr * scale + s.dx, w.scrb * scale + s.dy, w.scrt * scale + s.dy)
        SetPerspective(eye[1], eye[2], eye[3], at[1], at[2], at[3], up[1], up[2], up[3], fovy, (w.r - w.l) / (w.t - w.b), z[1], z[2])
        SetFog(unpack(d.fog))
        SetImageScale(sqrt((eye[1] - at[1]) * (eye[1] - at[1]) + (eye[2] - at[2]) *
                (eye[2] - at[2]) + (eye[3] - at[3]) * (eye[3] - at[3])) * 2 * tan(fovy * 0.5) / (w.scrr - w.scrl))
    elseif mode == 'world' then
        --计算world宽高和偏移
        local offset = lstg.worldoffset
        local w = lstg.world
        local world = { height = (w.t - w.b), width = (w.r - w.l) }
        world.setheight = world.height * (1 / offset.vscale)--缩放后的高度
        world.setwidth = world.width * (1 / offset.hscale)--缩放后的宽度
        world.setdx = offset.dx * (1 / offset.hscale)--水平整体偏移
        world.setdy = offset.dy * (1 / offset.vscale)--垂直整体偏移
        --计算world最终参数
        world.l = offset.centerx - (world.setwidth / 2) + world.setdx
        world.r = offset.centerx + (world.setwidth / 2) + world.setdx
        world.b = offset.centery - (world.setheight / 2) + world.setdy
        world.t = offset.centery + (world.setheight / 2) + world.setdy
        --应用参数
        SetRenderRect(world.l, world.r, world.b, world.t, w.scrl, w.scrr, w.scrb, w.scrt)
    elseif mode == 'ui' then
        SetRenderRect(0, s.width, 0, s.height, 0, s.width, 0, s.height)
    else
        error('Invalid arguement.')
    end
end

function RenderClearViewMode(color)
    if not CheckRes("img", "white") then
        return
    end
    color.a = 255
    SetImageState("white", "", color)
    local w = lstg.world
    if lstg.viewmode == "3d" then
        SetViewMode("world")
        RenderRect("white", w.l, w.r, w.b, w.t)
        SetViewMode("3d")
    elseif lstg.viewmode == "world" then
        RenderRect("white", w.l, w.r, w.b, w.t)
    elseif lstg.viewmode == "ui" then
        RenderRect("white", 0, screen.width, 0, screen.height)
    end
end

---另一种设置3d渲染
---Set3dMode("world") 等价于 SetViewMode("3d")
function Set3dMode(mode)
    lstg.viewmode = "3d"
    if mode == "ui" then
        local d = lstg.view3d
        local scale = s.scale
        local eye = d.eye
        local at = d.at
        local up = d.up
        local z = d.z
        local fovy = d.fovy
        SetViewport(s.dx, s.width * scale + s.dx, s.dy, s.height * scale + s.dy)
        SetPerspective(eye[1], eye[2], eye[3], at[1], at[2], at[3], up[1], up[2], up[3], fovy, s.width / s.height, z[1], z[2])
        SetFog(unpack(d.fog))
        SetImageScale(sqrt((eye[1] - at[1]) * (eye[1] - at[1]) + (eye[2] - at[2]) *
                (eye[2] - at[2]) + (eye[3] - at[3]) * (eye[3] - at[3])) * 2 * tan(fovy * 0.5) / s.width)
    elseif mode == "world" then
        local d = lstg.view3d
        local w = lstg.world
        local scale = s.scale
        local eye = d.eye
        local at = d.at
        local up = d.up
        local z = d.z
        local fovy = d.fovy
        SetViewport(w.scrl * scale + s.dx, w.scrr * scale + s.dx, w.scrb * scale + s.dy, w.scrt * scale + s.dy)
        SetPerspective(eye[1], eye[2], eye[3], at[1], at[2], at[3], up[1], up[2], up[3], fovy, (w.r - w.l) / (w.t - w.b), z[1], z[2])
        SetFog(unpack(d.fog))
        SetImageScale(sqrt((eye[1] - at[1]) * (eye[1] - at[1]) + (eye[2] - at[2]) *
                (eye[2] - at[2]) + (eye[3] - at[3]) * (eye[3] - at[3])) * 2 * tan(fovy * 0.5) / (w.scrr - w.scrl))
    end
end

function WorldToScreen(x, y)
    local w = lstg.world
    local scr = screen
    local k = scr.scale
    return (x - w.l + w.scrl) * k, (scr.height - y + w.b - w.scrb) * k
end

function UIToScreen(x, y)
    local scr = screen
    local k = scr.scale
    return x * k, (scr.height - y) * k
end

function WorldToUI(x, y)
    local w = lstg.world
    local l, r, b, t = w.l, w.r, w.b, w.t
    local scrl, scrr, scrb, scrt = w.scrl, w.scrr, w.scrb, w.scrt
    return scrl + (scrr - scrl) * (x - l) / (r - l), scrb + (scrt - scrb) * (y - b) / (t - b)
end

function UIToWorld(x, y)
    local w = lstg.world
    local l, r, b, t = w.l, w.r, w.b, w.t
    local scrl, scrr, scrb, scrt = w.scrl, w.scrr, w.scrb, w.scrt
    return (x - scrl) * (r - l) / (scrr - scrl) + l, (y - scrb) * (t - b) / (scrt - scrb) + b
end

---设置渲染矩形（会被SetViewMode覆盖）
---@param l number @坐标系左边界
---@param r number @坐标系右边界
---@param b number @坐标系下边界
---@param t number @坐标系上边界
---@param scrl number @渲染系左边界
---@param scrr number @渲染系右边界
---@param scrb number @渲染系下边界
---@param scrt number @渲染系上边界
---@overload fun(info:table):nil @坐标系信息
function SetRenderRect(l, r, b, t, scrl, scrr, scrb, scrt)
    if not (l ~= r and b ~= t and scrl ~= scrr and scrb ~= scrt) then
        assert(false,
                string.format("coord: [%f, %f, %f, %f] screen: [%f, %f, %f, %f]", l, r, b, t, scrl, scrr, scrb, scrt))
    end
    local scr = screen
    local scale = scr.scale
    local dx = scr.dx
    local dy = scr.dy
    if l and r and b and t and scrl and scrr and scrb and scrt then
        --设置坐标系
        SetOrtho(l, r, b, t)
        --设置视口
        SetViewport(scrl * scale + dx, scrr * scale + dx, scrb * scale + dy, scrt * scale + dy)
        --清空fog
        SetFog()
        --设置图像缩放比
        SetImageScale(1)
    elseif type(l) == "table" then
        --设置坐标系
        SetOrtho(l.l, l.r, l.b, l.t)
        --设置视口
        SetViewport(l.scrl * scale + dx, l.scrr * scale + dx, l.scrb * scale + dy, l.scrt * scale + dy)
        --清空fog
        SetFog()
        --设置图像缩放比
        SetImageScale(1)
    else
        error("Invalid arguement.")
    end
end
----------------------------------------
---world offset
---by ETC
---用于独立world本身的数据、world坐标系中心偏移和横纵缩放、world坐标系整体偏移

local DEFAULT_WORLD_OFFSET = {
    centerx = 0, centery = 0, --world中心位置偏移
    hscale = 1, vscale = 1, --world横向、纵向缩放
    dx = 0, dy = 0, --整体偏移
}

lstg.worldoffset = {
    centerx = 0, centery = 0, --world中心位置偏移
    hscale = 1, vscale = 1, --world横向、纵向缩放
    dx = 0, dy = 0, --整体偏移
}

---重置world偏移
function ResetWorldOffset()
    local l = lstg
    l.worldoffset = l.worldoffset or {}
    for k, v in pairs(DEFAULT_WORLD_OFFSET) do
        l.worldoffset[k] = v
    end
end

---设置world偏移
function SetWorldOffset(centerx, centery, hscale, vscale)
    local w = lstg.worldoffset
    w.centerx = centerx
    w.centery = centery
    w.hscale = hscale
    w.vscale = vscale
end

---在2d上渲染3d
---@class lstg.viewbillboard
local viewbillboard = {
    eye = { 0, 0, -1 },
    at = { 0, 0, 0 },
    up = { 0, 1, 0 },
    fovy = PI_2 / 2,
    z = { 0.01, 3 },
    fog = { 0, 0, Color(0xFF000000) },
}
lstg.viewbillboard = viewbillboard
function viewbillboard:ResetParameter()
    self.eye = { 0, 0, -1 }
    self.at = { 0, 0, 0 }
    self.up = { 0, 1, 0 }
    self.fovy = PI_2 / 2
    self.z = { 0.01, 2 }
    self.fog = { 0, 0, Color(0xFF000000) }
end
function viewbillboard:Set3D()
    SetPerspective(self.eye[1], self.eye[2], self.eye[3], self.at[1], self.at[2], self.at[3], self.up[1], self.up[2], self.up[3],
            self.fovy, (lstg.world.r - lstg.world.l) / (lstg.world.t - lstg.world.b), self.z[1], self.z[2])
    SetFog(self.fog[1], self.fog[2], self.fog[3])
    SetImageScale(((((self.eye[1] - self.at[1]) ^ 2 + (self.eye[2] - self.at[2]) ^ 2 + (self.eye[3] - self.at[3]) ^ 2) ^ 0.5) * 2 * math.tan(self.fovy * 0.5)) / (lstg.world.scrr - lstg.world.scrl))

end

function viewbillboard:rotate3D(x, y, z, ax, ay, az)
    x, y = x * cos(az) - y * sin(az), y * cos(az) + x * sin(az)
    x, z = x * cos(ay) - z * sin(ay), z * cos(ay) + x * sin(ay)
    y, z = y * cos(ax) - z * sin(ax), z * cos(ax) + y * sin(ax)
    local size = self.fovy / PI_2
    return x * size, y * size, z * size
end
function viewbillboard:WorldToBillBoard(x, y)
    x = x / 448 / 0.5 / (1 / math.tan(self.fovy / 2))
    y = y / 448 / 0.5 / (1 / math.tan(self.fovy / 2))
    return x, y
end




----------------------------------------
---init

ResetScreen()--先初始化一次，！！！注意不能漏掉这一步
