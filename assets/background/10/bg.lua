BG_10 = Class(background)
local SetViewMode = SetViewMode
local RenderTexture = RenderTexture
local Color = Color
local Set3D = Set3D
local cos, sin = cos, sin
local task = task
local background = background



function BG_10:init()
    local path = "assets\\background\\10\\"
    LoadTexture2("bg_10_tex", path .. "1.png")


    background.init(self, false)
    self.float = background.RanFloat
    self.int = background.RanInt
    self.sign = background.RanSign
    self.class = BG_10
    --New(camera_setter)
    Set3D('eye', 0, 23, 0)
    Set3D('at', 0, 1.8, 3)
    Set3D('up', 0, 1, 0)
    Set3D('z', 0.1, 50)
    Set3D('fovy', 1)
    Set3D('fog', 18, 29, Color(100, 0, 0, 0))
    self.class:SetAngle(0, 0, 0)
    self.px = 0
    self.py = 0
    self.pz = 0
    self.speed = 1
    self.ltimer = 0
    task.New(self, function()
        task.New(self, function()
            for i = 1, 270 do
                i = task.SetMode[3](i / 270)
                self.py = i * 4
                self.pz = i * 8
                task.Wait()
            end
        end)
        while true do
            task.Wait(180)
            for i = 1, 180 do
                self.class:SetAngle(0, -task.SetMode[3](i / 180) * 90, 0)
                task.Wait()
            end
            self.py, self.pz = 0, 0
            self.class:SetAngle(0, 0, 0)
            task.New(self, function()
                for i = 1, 270 do
                    i = task.SetMode[3](i / 270)
                    self.py = i * 4
                    self.pz = i * 8
                    task.Wait()
                end
            end)
        end
    end)
    self.x = player.x
    self.y = player.y
    self._r, self._g, self._b = 200, 200, 200
    self.leaf = CreateFallLeaf({ { -3, 3 }, { 7, 15 }, { 7, 10 }, { 1, 2 }, { -0.002, 0.002 }, { -0.01, -0.025 }, { -0.01, -0.02 } },
            6, 0.1, "mul+add", 100, { 200, 200, 200 },
            "small_leaf", function(self)
                return self.y < 0
            end, { count = 20, xRange = { -3, 3 }, yRange = { 1, 7 }, zRange = { -3, 7 } }, true)
end

function BG_10:frame()
    task.Do(self)
    self.ltimer = self.ltimer + self.speed
    local t = self.ltimer
    self.x = self.x + (player.x - self.x) * 0.05
    self.y = self.y + (player.y - self.y) * 0.05
    Set3D("at", sin(t / 5) * 0.6, 1.8 + sin(t / 6), 3)
    Set3D("eye", self.x / 170, 5 + self.y / 150, 0)
    Set3D("up", sin(t / 5) * 0.3, 0.5 + 0.3 * sin(t / 3), sin(t / 7) * 0.1)
    self._r = sin(t / 3) * 50 + 150
    self._g = sin(t / 4) * 30 + 170
    self._b = sin(t / 5) * 10 + 190
    self.leaf:frame()
end
local function rotate(ax, ay, az, x, y, z)
    x, y = x * cos(az) - y * sin(az), y * cos(az) + x * sin(az)
    x, z = x * cos(ay) - z * sin(ay), z * cos(ay) + x * sin(ay)
    y, z = y * cos(ax) - z * sin(ax), z * cos(ax) + y * sin(ax)
    return x, y, z
end
BG_10.rx = 0
BG_10.ry = 0
BG_10.rz = 0
function BG_10:SetAngle(x, y, z)
    self.rx = x or self.rx
    self.ry = y or self.ry
    self.rz = z or self.rz
end
local rtuv1, rtuv2, rtuv3, rtuv4 = {}, {}, {}, {}
function BG_10:RenderTexture(tex, blend, col, uv1, uv2, uv3, uv4, oX, oY, oZ, aX, aY, aZ)
    oX, oY, oZ = rotate(self.rx, self.ry, self.rz, oX, oY, oZ)
    rtuv1[6], rtuv2[6], rtuv3[6], rtuv4[6] = col, col, col, col

    rtuv1[1], rtuv1[2], rtuv1[3] = rotate(aX, aY, aZ, rotate(self.rx, self.ry, self.rz, uv1[1], uv1[2], uv1[3]))
    rtuv2[1], rtuv2[2], rtuv2[3] = rotate(aX, aY, aZ, rotate(self.rx, self.ry, self.rz, uv2[1], uv2[2], uv2[3]))
    rtuv3[1], rtuv3[2], rtuv3[3] = rotate(aX, aY, aZ, rotate(self.rx, self.ry, self.rz, uv3[1], uv3[2], uv3[3]))
    rtuv4[1], rtuv4[2], rtuv4[3] = rotate(aX, aY, aZ, rotate(self.rx, self.ry, self.rz, uv4[1], uv4[2], uv4[3]))
    rtuv1[1], rtuv1[2], rtuv1[3] = oX + rtuv1[1], oY + rtuv1[2], oZ + rtuv1[3]
    rtuv2[1], rtuv2[2], rtuv2[3] = oX + rtuv2[1], oY + rtuv2[2], oZ + rtuv2[3]
    rtuv3[1], rtuv3[2], rtuv3[3] = oX + rtuv3[1], oY + rtuv3[2], oZ + rtuv3[3]
    rtuv4[1], rtuv4[2], rtuv4[3] = oX + rtuv4[1], oY + rtuv4[2], oZ + rtuv4[3]
    rtuv1[4], rtuv1[5] = uv1[4], uv1[5]
    rtuv2[4], rtuv2[5] = uv2[4], uv2[5]
    rtuv3[4], rtuv3[5] = uv3[4], uv3[5]
    rtuv4[4], rtuv4[5] = uv4[4], uv4[5]
    RenderTexture(tex, blend, rtuv1, rtuv2, rtuv3, rtuv4)
end
local rsuv1, rsuv2, rsuv3, rsuv4 = {}, {}, {}, {}
function BG_10:RenderStairs(tex, blend, x, y, z, stairs, white, black, Rsize, Vsize, ax, ay, az)
    local rw = Rsize * 2 / stairs
    local vw = Vsize / stairs
    for c = 1, stairs do
        rsuv1[1], rsuv1[2], rsuv1[3], rsuv1[4], rsuv1[5] = -Rsize, c * rw, Rsize + c * rw, 0, Vsize - (c) * vw
        rsuv2[1], rsuv2[2], rsuv2[3], rsuv2[4], rsuv2[5] = Rsize, c * rw, Rsize + c * rw, Vsize, Vsize - (c) * vw
        rsuv3[1], rsuv3[2], rsuv3[3], rsuv3[4], rsuv3[5] = Rsize, c * rw, Rsize + (c - 1) * rw, Vsize, Vsize - (c - 1) * vw
        rsuv4[1], rsuv4[2], rsuv4[3], rsuv4[4], rsuv4[5] = -Rsize, c * rw, Rsize + (c - 1) * rw, 0, Vsize - (c - 1) * vw
        self:RenderTexture(tex, blend, white, rsuv1, rsuv2, rsuv3, rsuv4, x, y, z, ax, ay, az)
        rsuv1[1], rsuv1[2], rsuv1[3], rsuv1[4], rsuv1[5] = -Rsize, c * rw, Rsize + (c - 1) * rw, 0, Vsize - (c - 1) * vw
        rsuv2[1], rsuv2[2], rsuv2[3], rsuv2[4], rsuv2[5] = Rsize, c * rw, Rsize + (c - 1) * rw, Vsize, Vsize - (c - 1) * vw
        rsuv3[1], rsuv3[2], rsuv3[3], rsuv3[4], rsuv3[5] = Rsize, (c - 1) * rw, Rsize + (c - 1) * rw, Vsize, Vsize - (c - 2) * vw
        rsuv4[1], rsuv4[2], rsuv4[3], rsuv4[4], rsuv4[5] = -Rsize, (c - 1) * rw, Rsize + (c - 1) * rw, 0, Vsize - (c - 2) * vw
        self:RenderTexture(tex, blend, black, rsuv1, rsuv2, rsuv3, rsuv4, x, y, z, ax, ay, az)
    end
end

local rfuv1, rfuv2, rfuv3, rfuv4 = {}, {}, {}, {}
function BG_10:RenderFloor(tex, blend, x, y, z, Rsize, Vsize, col, ax, ay, az, ht, vt)
    ht = ht or 1
    vt = vt or 1
    rfuv1[1], rfuv1[2], rfuv1[3] = rotate(ax, 0, az, -Rsize * ht, 0, Rsize * vt)
    rfuv2[1], rfuv2[2], rfuv2[3] = rotate(ax, 0, az, Rsize * ht, 0, Rsize * vt)
    rfuv3[1], rfuv3[2], rfuv3[3] = rotate(ax, 0, az, Rsize * ht, 0, -Rsize * vt)
    rfuv4[1], rfuv4[2], rfuv4[3] = rotate(ax, 0, az, -Rsize * ht, 0, -Rsize * vt)
    rfuv1[4], rfuv1[5] = 0, 0
    rfuv2[4], rfuv2[5] = Vsize * ht, 0
    rfuv3[4], rfuv3[5] = Vsize * ht, Vsize * vt
    rfuv4[4], rfuv4[5] = 0, Vsize * vt
    self:RenderTexture(tex, blend, col, rfuv1, rfuv2, rfuv3, rfuv4, x, y, z, 0, ay, 0)

end
local Cos, Sin = Cos, Sin
function BG_10:render()
    SetViewMode '3d'
    background.ClearToFogColor()
    local tex = "bg_10_tex"
    local blend = ""
    local white = Color(255, self._r, self._g, self._b)
    local black = Color(255, self._r / 2.3, self._g / 2.3, self._b / 2.3)
    local Rsize = 4
    local Vsize = 512
    local Rsize2 = 2
    local class = BG_10
    local X, Y, Z = -self.px, -self.py, -self.pz
    ClearZBuffer()
    SetZBufferEnable(1)
    class:RenderFloor(tex, blend, X, Y, Z, Rsize2, Vsize, white, 0, 0, 0)
    class:RenderStairs(tex, blend, X, Y, Z, 10, white, black, Rsize2, Vsize, 0, 0, 0)

    class:RenderFloor(tex, blend, X, Y + Rsize, Z + Rsize * 2, Rsize2, Vsize, white, 0, 90, 0)
    class:RenderStairs(tex, blend, X, Y + Rsize, Z + Rsize * 2, 10, white, black, Rsize2, Vsize, 0, 90, 0)

    class:RenderFloor(tex, blend, X - Rsize * 2, Y + Rsize * 2, Z + Rsize * 2, Rsize2, Vsize, white, 0, 180, 0)
    class:RenderStairs(tex, blend, X - Rsize * 2, Y + Rsize * 2, Z + Rsize * 2, 10, white, black, Rsize2, Vsize, 0, 180, 0)

    class:RenderFloor(tex, blend, X - Rsize * 2, Y - Rsize, Z, Rsize2, Vsize, white, 0, 270, 0)
    class:RenderStairs(tex, blend, X - Rsize * 2, Y - Rsize, Z, 10, white, black, Rsize2, Vsize, 0, 270, 0)
    class:RenderStairs(tex, blend, X - Rsize * 2, Y - Rsize * 2, Z + Rsize * 2, 10, white, black, Rsize2, Vsize, 0, 180, 0)
    local eyex, eyez = lstg.view3d.eye[1] - (X - Rsize), lstg.view3d.eye[3] - (Z + Rsize)
    local d = Rsize2 * Cos(45)
    for i = 1, 4 do
        i = i * 90
        if d * Cos(-i) * eyex + d * Sin(-i) * eyez - d * d > 0 then
            class:RenderFloor(tex, blend,
                    X - Rsize + Rsize2 * cos(i),
                    Y + Rsize2,
                    Z + Rsize + Rsize2 * sin(i),
                    Rsize2, Vsize, white, 90, 0, i + 90, 1, 8)
        end
        class:RenderFloor(tex, blend,
                X - Rsize + Rsize2 * cos(i) * 3,
                Y + Rsize2,
                Z + Rsize + Rsize2 * sin(i) * 3,
                Rsize2, Vsize, white, 90, 0, i + 90, 3, 8)
    end

    SetZBufferEnable(0)
    self.leaf:render()
    SetViewMode 'world'
end