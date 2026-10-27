local SetViewMode = SetViewMode
local RenderTexture = RenderTexture
local Color = Color
local Set3D = Set3D
local table = table
local cos, sin = cos, sin
local background = background
local SetImageState = SetImageState
local Render4V = Render4V
local Dist = Dist

BG_26 = Class(background)

function BG_26:init()

    background.init(self)
    self.float = background.RanFloat
    self.int = background.RanInt
    self.sign = background.RanSign
    Set3D('eye', 0, 0, 0)
    Set3D('at', 0, 0, 2)
    Set3D('up', 0, 1, 0)
    Set3D('z', 0.1, 100)
    Set3D('fovy', 1)
    Set3D('fog', 3, 6, Color(100, 10, 10, 25))
    self.speed = 0.046
    self.zos = 0
    self.bulings = {}
    self.maxid = 32
    self.auto_animate = true
    function self:SetColor(Hue)
        if Hue == "black" then
            self.rR, self.rG, self.rB = 180, 180, 180
            lstg.view3d.fog[3] = Color(100, 0, 0, 0)
        else

            self.rR, self.rG, self.rB = sp:HSVtoRGB(Hue, 0.7, 1)
            lstg.view3d.fog[3] = Color(100, sp:HSVtoRGB(Hue, 0.8, 0.03))

        end
    end
    function self:AddBuling(id, alpha, dealpha)
        id = id or self:int(9, 20)
        alpha = alpha or 255
        dealpha = dealpha or 8
        table.insert(self.bulings, { id = id, alpha = alpha, dealpha = dealpha, size = 0 })
    end

    task.New(self, function()
        local t = 1
        local v = lstg.view3d
        while true do
            v.eye[1] = sin(t / 2) * 0.2
            v.at[2] = -sin(t / 3) * 0.3
            v.at[1] = sin(t / 3) * 0.2
            v.up[1] = sin(t / 2.5) * 0.4
            v.up[2] = sin(t / 4) * 0.6
            t = t + 1
            task.Wait()
        end
    end)
    task.New(self, function()
        while self.auto_animate do
            self:SetColor(self.timer/2)
            if self.timer%25==0 then
                self:AddBuling()
            end
            task.Wait()
        end
    end)

    self:SetColor("black")
    self.leaf = CreateFallLeaf({ { -1, 1 }, { -1, 1 }, { 5, 6 }, { 1, 2 }, { -0.002, 0.002 }, { -0.002, 0.002 }, { -0.02, -0.05 } },
            7, 0.1, "mul+add", 100, { 100, 100, 200 },
            "small_leaf", function(self)
                return self.z < -5
            end, { count = 50, xRange = { -1, 1 }, yRange = { -1, 1 }, zRange = { -1, 6 } }, true)
end
function BG_26:frame()
    task.Do(self)
    local lcol = self.leaf.color
    lcol[1], lcol[2], lcol[3] = self.rR, self.rG, self.rB
    self.leaf:frame()
    self.zos = self.zos - self.speed
    local b
    while self.zos < -1 do
        self.zos = self.zos + 1
        for i = #self.bulings, 1, -1 do
            b = self.bulings[i]
            b.id = b.id - 4
            if b.id < 1 then
                table.remove(self.bulings, i)
            end
        end
    end
    while self.zos > 1 do
        self.zos = self.zos - 1
        for i = #self.bulings, 1, -1 do
            b = self.bulings[i]
            b.id = b.id + 4

            if b.id > self.maxid then
                table.remove(self.bulings, i)
            end
        end

    end
    for i = #self.bulings, 1, -1 do
        b = self.bulings[i]
        b.alpha = max(b.alpha - b.dealpha, 0)
        b.size = b.size + (-b.size + 1) * 0.3
        if b.alpha == 0 then
            table.remove(self.bulings, i)
        end
    end
end
function BG_26:render()
    SetViewMode '3d'
    background.ClearToFogColor()
    SetImageState("white", "", 255, self.rR * 0.7, self.rG * 0.7, self.rB * 0.7)
    local s1, s2 = 0.42, 0.46
    for z = -1, 8 do
        z = z + self.zos % 1
        Render4V("white", -s2, -0.5, z + s2, -s1, -0.5, z + s2,
                -s1, -0.5, z - s2, -s2, -0.5, z - s2)
        Render4V("white", -s2, -0.5, z + s2, s2, -0.5, z + s2,
                s2, -0.5, z + s1, -s2, -0.5, z + s1)
        Render4V("white", s1, -0.5, z + s2, s2, -0.5, z + s2,
                s2, -0.5, z - s2, s1, -0.5, z - s2)
        Render4V("white", -s2, -0.5, z - s1, s2, -0.5, z - s1,
                s2, -0.5, z - s2, -s2, -0.5, z - s2)

        Render4V("white", -0.5, -s2, z + s2, -0.5, -s1, z + s2,
                -0.5, -s1, z - s2, -0.5, -s2, z - s2)
        Render4V("white", -0.5, -s2, z + s2, -0.5, s2, z + s2,
                -0.5, s2, z + s1, -0.5, -s2, z + s1)
        Render4V("white", -0.5, s1, z + s2, -0.5, s2, z + s2,
                -0.5, s2, z - s2, -0.5, s1, z - s2)
        Render4V("white", -0.5, -s2, z - s1, -0.5, s2, z - s1,
                -0.5, s2, z - s2, -0.5, -s2, z - s2)

        Render4V("white", -s2, 0.5, z + s2, -s1, 0.5, z + s2,
                -s1, 0.5, z - s2, -s2, 0.5, z - s2)
        Render4V("white", -s2, 0.5, z + s2, s2, 0.5, z + s2,
                s2, 0.5, z + s1, -s2, 0.5, z + s1)
        Render4V("white", s1, 0.5, z + s2, s2, 0.5, z + s2,
                s2, 0.5, z - s2, s1, 0.5, z - s2)
        Render4V("white", -s2, 0.5, z - s1, s2, 0.5, z - s1,
                s2, 0.5, z - s2, -s2, 0.5, z - s2)

        Render4V("white", 0.5, -s2, z + s2, 0.5, -s1, z + s2,
                0.5, -s1, z - s2, 0.5, -s2, z - s2)
        Render4V("white", 0.5, -s2, z + s2, 0.5, s2, z + s2,
                0.5, s2, z + s1, 0.5, -s2, z + s1)
        Render4V("white", 0.5, s1, z + s2, 0.5, s2, z + s2,
                0.5, s2, z - s2, 0.5, s1, z - s2)
        Render4V("white", 0.5, -s2, z - s1, 0.5, s2, z - s1,
                0.5, s2, z - s2, 0.5, -s2, z - s2)
    end
    for _, b in ipairs(self.bulings) do
        local m = (b.id % 4) * 90
        local z = int(b.id / 4) - 1
        z = z + self.zos % 1
        SetImageState("white", "mul+add", b.alpha, self.rR, self.rG, self.rB)
        local s = s2 * b.size
        local x1, y1 = -s, -0.5
        local x2, y2 = s, -0.5
        local x3, y3 = s, -0.5
        local x4, y4 = -s, -0.5
        x1, y1 = x1 * cos(m) - y1 * sin(m), y1 * cos(m) + x1 * sin(m)
        x2, y2 = x2 * cos(m) - y2 * sin(m), y2 * cos(m) + x2 * sin(m)
        x3, y3 = x3 * cos(m) - y3 * sin(m), y3 * cos(m) + x3 * sin(m)
        x4, y4 = x4 * cos(m) - y4 * sin(m), y4 * cos(m) + x4 * sin(m)
        Render4V("white", x1, y1, s + z, x2, y2, s + z, x3, y3, -s + z, x4, y4, -s + z)
    end
    self.leaf:render()
    SetViewMode 'world'
end