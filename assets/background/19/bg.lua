BG_19 = Class(background)
local RenderTexture = RenderTexture
local SetViewMode = SetViewMode
local Color = Color
local Set3D = Set3D
local cos, sin = cos, sin
local min, max = min, max
local background = background
local Render4V = Render4V



function BG_19:init()
    local path = "assets\\background\\19\\"
    LoadImageFromFile("bg_19_floor", path .. "floor.png")
    LoadTexture2("bg_19_fog", path .. "fog.png")
    LoadImageGroupFromFile("bg_19_leaf", path .. "leaf.png", nil, 2, 1)
    LoadImageFromFile("bg_19_moon", path .. "moon.png")
    LoadImageFromFile("bg_19_bamboo", path .. "bamboo.png")

    background.init(self, false)
    self.float = background.RanFloat
    self.int = background.RanInt
    self.sign = background.RanSign

    Set3D('eye', 0, 1.2, -4)
    Set3D('at', 0, 0, 0)
    Set3D('up', 0, 1, 0)
    Set3D('fog', 1.6, 6, Color(100, 0, 0, 0))
    Set3D('fovy', 0.8)
    self.bamboo = {}
    self.leaf = {}
    self.fogos = 0
    self.speed = 0.03
    self.zos = 0
    self.scale = 0.4
    self.x, self.y, self.z = unpack(lstg.view3d.eye)
    SetImageState("bg_19_moon", "mul+add")
    function self:create_bamboo(x, z, d, alpha)
        local rot = self:float(-4, 4)
        table.insert(self.bamboo, { x = x * d, y = -0.1, z = z, alpha = 0, talpha = alpha, rot = rot })
        local y
        local s
        for _ = 1, self:float(1, 6) do
            y = self:float(0.5, 15)
            s = self:float(0.6, 1)
            table.insert(self.leaf, { x = x * d + tan(rot) * y, y = -0.1 + y, z = z, alpha = 0, talpha = alpha,
                                      rot = rot, t = self:int(1, 2), rotate = self:float(-60, 60), scale = s })
            table.insert(self.leaf, { x = x * d + tan(rot) * y, y = -0.1 + y, z = z, alpha = 0, talpha = alpha,
                                      rot = rot, t = self:int(1, 2), rotate = 180 + self:float(-60, 60), scale = s })
        end
        table.sort(self.leaf, function(a, b)
            if a.z and b.z then
                if a.z == b.z then
                    return b.rotate < a.rotate
                else
                    return b.z < a.z
                end
            else
                return false
            end
        end)
        table.sort(self.bamboo, function(a, b)
            return b.z < a.z
        end)
    end
    for _ = 1, 13 do
        self:create_bamboo(self:float(0.5, 1.5), self:float(-5, 5), self:sign(), self:float(180, 230))
    end
    self.leaf2 = CreateFallLeaf({ { -3, 3 }, { 0, 5 }, { 3, 7 }, { 1, 2 }, { -0.002, 0.002 }, { -0.02, -0.03 }, { -0.03, -0.042 } },
            12, 0.1, "mul+add", 100, { 200, 100, 100 },
            "leaf", function(self)
                return self.y < -1 or self.z < lstg.view3d.eye[3] - 1
            end, { count = 30, xRange = { -3, 3 }, yRange = { 0, 5 }, zRange = { -3, 7 } }, true)
    task.New(self, function()
        local s, t = 0, 0
        while true do
            lstg.view3d.eye[1] = sin(t) * 0.3
            lstg.view3d.at[1] = sin(t / 2) * 0.3
            t = t + sin(s)
            s = min(s + 1, 90)
            task.Wait()
        end
    end)
end
function BG_19:frame()
    task.Do(self)
    self.x, self.y, self.z = unpack(lstg.view3d.eye)
    self.zos = self.zos - self.speed
    self.fogos = self.fogos - 0.03 * 0.2
    if self.timer % math.ceil(self.scale / self.speed) == 0 then
        self:create_bamboo(self:float(0.5, 1.5), self.z + self:float(7, 9), self:sign(), self:float(180, 230))
    end
    local b
    for i = #self.bamboo, 1, -1 do
        b = self.bamboo[i]
        b.z = b.z - self.speed
        b.alpha = min(b.talpha, b.alpha + b.talpha / 20)
        if b.z < self.z - 1 then
            b.alpha = max(0, b.alpha - b.talpha / 10)
            if b.alpha == 0 then
                table.remove(self.bamboo, i)
            end
        end
    end
    for i = #self.leaf, 1, -1 do
        b = self.leaf[i]
        b.z = b.z - self.speed
        b.alpha = min(b.talpha, b.alpha + b.talpha / 20)
        if b.z < self.z - 1 then
            b.alpha = max(0, b.alpha - b.talpha / 10)
            if b.alpha == 0 then
                table.remove(self.leaf, i)
            end
        end
    end
    self.leaf2.speed = self.speed * 100 / 2
    self.leaf2:frame()

end
local function rotate(x, y, z, ax, ay, az)
    x, y = x * cos(az) - y * sin(az), y * cos(az) + x * sin(az)
    x, z = x * cos(ay) - z * sin(ay), z * cos(ay) + x * sin(ay)
    y, z = y * cos(ax) - z * sin(ax), z * cos(ax) + y * sin(ax)
    return x, y, z
end

function BG_19:render()
    SetViewMode '3d'
    background.ClearToFogColor()
    local p0, p1, p2, p3 = {}, {}, {}, {}
    local eye = lstg.view3d.eye
    local x, y, z = 0, 5, 0
    local ax, ay, az
    ay = Angle(-z, x, -eye[3], eye[1])
    ax = Angle(-z * cos(ay) + x * sin(ay), y, -eye[3] * cos(ay) + eye[1] * sin(ay), eye[2])
    az = 0
    p0[1], p0[2], p0[3] = rotate(-1.5, 1.5, 0, ax, ay, az)
    p1[1], p1[2], p1[3] = rotate(1.5, 1.5, 0, ax, ay, az)
    p2[1], p2[2], p2[3] = rotate(1.5, -1.5, 0, ax, ay, az)
    p3[1], p3[2], p3[3] = rotate(-1.5, -1.5, 0, ax, ay, az)
    Render4V("bg_19_moon",
            x + p0[1], y + p0[2], z + p0[3], x + p1[1], y + p1[2], z + p1[3],
            x + p2[1], y + p2[2], z + p2[3], x + p3[1], y + p3[2], z + p3[3])
    ax = 0
    do
        local color
        local size = 2
        local _Z = self.zos % size
        color = Color(255, 255, 255, 255)
        for X = -4, 4, size do
            for z2 = -8, 10, size do
                Render4V("bg_19_floor",
                        X - size / 2, 0, z2 + size / 2 + _Z,
                        X + size / 2, 0, z2 + size / 2 + _Z,
                        X + size / 2, 0, z2 - size / 2 + _Z,
                        X - size / 2, 0, z2 - size / 2 + _Z)
            end
        end
        size = 1024
        _Z = self.zos * 100
        local Z = self.fogos * 100
        local uv1, uv2, uv3, uv4 = {}, {}, {}, {}
        color = Color(255, 135, 206, 235)
        uv1[6], uv2[6], uv3[6], uv4[6] = color, color, color, color
        uv1[1], uv1[2], uv1[3] = -4, 0, 10
        uv2[1], uv2[2], uv2[3] = 4, 0, 10
        uv3[1], uv3[2], uv3[3] = 4, 0, -8
        uv4[1], uv4[2], uv4[3] = -4, 0, -8

        uv1[4], uv1[5] = -Z, _Z
        uv2[4], uv2[5] = size - Z, _Z
        uv3[4], uv3[5] = size - Z, size * 2 + _Z
        uv4[4], uv4[5] = -Z, size * 2 + _Z
        RenderTexture("bg_19_fog", "", uv1, uv2, uv3, uv4)

        uv1[4], uv1[5] = Z, _Z + 100
        uv2[4], uv2[5] = size + Z, _Z + 100
        uv3[4], uv3[5] = size + Z, size * 2 + _Z + 100
        uv4[4], uv4[5] = Z, size * 2 + _Z + 100
        RenderTexture("bg_19_fog", "", uv1, uv2, uv3, uv4)
    end
    for _, b in ipairs(self.bamboo) do
        ay = Angle(-b.z, b.x, -eye[3], eye[1])
        az = b.rot
        p0[1], p0[2], p0[3] = rotate(-0.08, 15, 0, ax, ay, az)
        p1[1], p1[2], p1[3] = rotate(0.08, 15, 0, ax, ay, az)
        p2[1], p2[2], p2[3] = rotate(0.08, 0, 0, ax, ay, az)
        p3[1], p3[2], p3[3] = rotate(-0.08, 0, 0, ax, ay, az)
        SetImageState("bg_19_bamboo", "", b.alpha, 255, 255, 255)
        Render4V("bg_19_bamboo",
                b.x + p0[1], b.y + p0[2], b.z + p0[3], b.x + p1[1], b.y + p1[2], b.z + p1[3],
                b.x + p2[1], b.y + p2[2], b.z + p2[3], b.x + p3[1], b.y + p3[2], b.z + p3[3])
    end

    for _, b in ipairs(self.leaf) do
        if b.alpha > 50 then
            ax = b.rotate * sin(b.rot)
            ay = b.rotate * cos(b.rot)
            az = b.rot
            p0[1], p0[2], p0[3] = rotate(0, b.scale, 0, ax, ay, az)
            p1[1], p1[2], p1[3] = rotate(b.scale * 2, b.scale, 0, ax, ay, az)
            p2[1], p2[2], p2[3] = rotate(b.scale * 2, -b.scale, 0, ax, ay, az)
            p3[1], p3[2], p3[3] = rotate(0, -b.scale, 0, ax, ay, az)
            SetImageState("bg_19_leaf" .. b.t, "", b.alpha, 255, 255, 255)
            Render4V("bg_19_leaf" .. b.t,
                    b.x + p0[1], b.y + p0[2], b.z + p0[3], b.x + p1[1], b.y + p1[2], b.z + p1[3],
                    b.x + p2[1], b.y + p2[2], b.z + p2[3], b.x + p3[1], b.y + p3[2], b.z + p3[3])
        end
    end
    self.leaf2:render()
    SetViewMode 'world'
end
