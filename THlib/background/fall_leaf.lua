---------------------------------------------
---落叶
local FALL_LEAF = plus.Class()

function FALL_LEAF:init(Range, thickness, size, blend, alpha, color, img, remove_condition, init_create, fuzzy_computation, save_rand)
    self.size = size or 0.1
    self.img = img or "leaf"
    self.blend = blend or "mul+add"
    self.maxalpha = alpha or 128
    self.speed = 1
    self.color = color or { 255, 100, 100 }
    self.unit = {}
    self.timer = 0
    self.thicktimer = 0
    self.thickness = (thickness or 10) / 60
    self.condition = remove_condition or (function(self)
        return self.z < -1
    end)
    local up = unpack
    self:SetRange(up(Range or {}))
    self:SetRandom(save_rand)
    self:SetTrigonometry(fuzzy_computation)
    if init_create then
        for _ = 1, init_create.count do
            self:create(self:ran_float(up(init_create.xRange)), self:ran_float(up(init_create.yRange)), self:ran_float(up(init_create.zRange)),
                    self:ran_float(self.omegamin, self.omegamax), self:ran_float(self.omegamin, self.omegamax), self:ran_float(self.omegamin, self.omegamax),
                    self:ran_float(self.vxmin, self.vxmax), self:ran_float(self.vymin, self.vymax), self:ran_float(self.vzmin, self.vzmax))
        end
    end
    self:Falling(true)
end
local int = int
---是否模糊计算(三角函数)
function FALL_LEAF:SetTrigonometry(fuzzy)
    if fuzzy then
        self.cos = function(t)
            t = (int(t) - 1) % 360 + 1
            return self.Reserve[t]
        end
        self.sin = function(t)
            t = (int(t) + 90 - 1) % 360 + 1
            return self.Reserve[t]
        end
    else
        self.cos, self.sin = cos, sin
    end
end

---是否保存随机数
function FALL_LEAF:SetRandom(save_rand)
    if save_rand then
        function self:ran_float(a, b)
            return ran:Float(a, b)
        end
        function self:ran_int(a, b)
            return ran:Int(a, b)
        end
        function self:ran_sign()
            return ran:Sign()
        end
    else
        local rand = math.random
        local t = { -1, 1 }
        function self:ran_float(a, b)
            if a > b then
                a, b = b, a
            end
            local c = (a + b) / 2
            return c + (rand() - 0.5) * (b - c) * 2
        end
        function self:ran_int(a, b)
            if a > b then
                a, b = b, a
            end
            return rand(a, b)
        end
        function self:ran_sign()
            return t[rand(2)]
        end
    end
end

---设置落叶单元坐标范围，自转范围，速度范围
function FALL_LEAF:SetRange(xRange, yRange, zRange, omegaRange, vxRange, vyRange, vzRange)
    local up = unpack
    self.xmin, self.xmax = up(xRange or { -1, 1 })
    self.ymin, self.ymax = up(yRange or { 0, 2 })
    self.zmin, self.zmax = up(zRange or { 3, 5 })
    self.omegamin, self.omegamax = up(omegaRange or { 1, 2 })
    self.vxmin, self.vxmax = up(vxRange or { -0.002, 0.002 })
    self.vymin, self.vymax = up(vyRange or { -0.002, 0.002 })
    self.vzmin, self.vzmax = up(vzRange or { -0.02, -0.04 })
end
local insert = table.insert
---创建一个落叶单元
function FALL_LEAF:create(x, y, z, omega1, omega2, omega3, vx, vy, vz)
    local size = self.size
    local pr1, pr2, pr3 = self:ran_float(0, 360), self:ran_float(0, 360), self:ran_float(0, 360)
    insert(self.unit, {
        x = x, y = y, z = z, --x,y,z坐标
        prot = { pr1, pr2, pr3 },
        pomega = { omega1, omega2, omega3 }, vx = vx, vy = vy, vz = vz, timer = 0, --一些自增量
        alpha = 0, maxalpha = self.maxalpha, --透明度相关
        img = self.img, size = size, color = self.color, condition = self.condition, --分别储存，不会一起变化
        point = {
            { self:rotate3D(-size, size, 0, x, y, z, pr1, pr2, pr3) },
            { self:rotate3D(size, size, 0, x, y, z, pr1, pr2, pr3) },
            { self:rotate3D(size, -size, 0, x, y, z, pr1, pr2, pr3) },
            { self:rotate3D(-size, -size, 0, x, y, z, pr1, pr2, pr3) },
        }
    })
end

function FALL_LEAF:rotate3D(x, y, z, offx, offy, offz, ax, ay, az)
    local cos, sin = self.cos, self.sin
    x, y = x * cos(az) - y * sin(az), y * cos(az) + x * sin(az)
    x, z = x * cos(ay) - z * sin(ay), z * cos(ay) + x * sin(ay)
    y, z = y * cos(ax) - z * sin(ax), z * cos(ax) + y * sin(ax)
    return x + offx, y + offy, z + offz
end

local min, max = min, max
local remove = table.remove
function FALL_LEAF:frame()
    self.timer = self.timer + 1
    if self.open then
        self.thicktimer = self.thicktimer + self.thickness
        if self.thicktimer >= 1 then
            for _ = 1, self.thicktimer do
                self:create(self:ran_float(self.xmin, self.xmax), self:ran_float(self.ymin, self.ymax), self:ran_float(self.zmin, self.zmax),
                        self:ran_float(self.omegamin, self.omegamax), self:ran_float(self.omegamin, self.omegamax), self:ran_float(self.omegamin, self.omegamax),
                        self:ran_float(self.vxmin, self.vxmax), self:ran_float(self.vymin, self.vymax), self:ran_float(self.vzmin, self.vzmax))
                self.thicktimer = self.thicktimer - 1
            end
        end
    end
    local l
    local x, y, z, pr1, pr2, pr3, p, size
    local s = self.speed
    for i = #self.unit, 1, -1 do
        l = self.unit[i]
        x, y, z = l.x, l.y, l.z
        pr1, pr2, pr3 = l.prot[1], l.prot[2], l.prot[3]
        size = l.size
        l.x = x + l.vx * s
        l.y = y + l.vy * s
        l.z = z + l.vz * s
        l.prot[1] = pr1 + l.pomega[1]
        l.prot[2] = pr2 + l.pomega[2]
        l.prot[3] = pr3 + l.pomega[3]
        l.timer = l.timer + 1
        p = l.point
        p[1][1], p[1][2], p[1][3] = self:rotate3D(-size, size, 0, x, y, z, pr1, pr2, pr3)
        p[2][1], p[2][2], p[2][3] = self:rotate3D(size, size, 0, x, y, z, pr1, pr2, pr3)
        p[3][1], p[3][2], p[3][3] = self:rotate3D(size, -size, 0, x, y, z, pr1, pr2, pr3)
        p[4][1], p[4][2], p[4][3] = self:rotate3D(-size, -size, 0, x, y, z, pr1, pr2, pr3)
        if l.timer < 10 then
            l.alpha = min(l.alpha + l.maxalpha / 10, l.maxalpha)
        else
            if l:condition() or l.clear then
                l.alpha = max(l.alpha - l.maxalpha / 10, 0)
                if l.alpha == 0 then
                    remove(self.unit, i)
                end
            end
        end
    end
end
local ipairs = ipairs
local SetImageState = SetImageState
local unpack = unpack
local Render4V = Render4V

function FALL_LEAF:render()
    local p
    local p1, p2, p3, p4
    for _, u in ipairs(self.unit) do
        if u.point then
            p = u.point
            p1, p2, p3, p4 = p[1], p[2], p[3], p[4]
            SetImageState(u.img, self.blend, u.alpha, unpack(u.color))
            Render4V(u.img, p1[1], p1[2], p1[3], p2[1], p2[2], p2[3], p3[1], p3[2], p3[3], p4[1], p4[2], p4[3])
        end
    end
end

---自主创建落叶单元
function FALL_LEAF:Falling(open)
    self.open = open
    self.thicktimer = open and self.thicktimer or 0
end

---清空落叶单元(淡出)
function FALL_LEAF:Clear()
    for _, u in ipairs(self.unit) do
        u.clear = true
        u.timer = 10
    end
end

function FALL_LEAF:Reserve()
    self.Reserve = {}
    for i = 1, 360 do
        table.insert(self.Reserve, cos(i))
    end
end
FALL_LEAF:Reserve()

---创建落叶
---其实只是为了ide弄的（x
---@param Range table@{xRange, yRange, zRange, omegaRange, vxRange, vyRange, vzRange}
---@param thickness number@片/秒
---@param init_create table@{count=..., xRange=..., yRange=.., zRange=...}
---@param remove_condition fun(self):boolean@叶子清除条件
---@param fuzzy_computation boolean@模糊计算
---@param save_rand boolean@保存随机数
function CreateFallLeaf(Range, thickness, size, blend, alpha, color, img, remove_condition, init_create, fuzzy_computation, save_rand)
    return FALL_LEAF(Range, thickness, size, blend, alpha, color, img, remove_condition, init_create, fuzzy_computation, save_rand)
end
