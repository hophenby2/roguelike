--额试一下在学校写
--目前还没导入
local Vec = sp.vector--用一下向量库嗷
local NewV = Vec.NewVector2d
local NewV2 = Vec.NewVector2d2
local PI = math.pi

---重力加速度
local g_normal = 0.05
---空气密度
local air_normal = 0.05
---地板能量损耗倍数
local lossindex_normal = 0.8
---地板摩擦系数
local friction_normal = 0.5
---地板静摩擦系数
local static_fric_normal = 0.55
--F = 0.5CpS(V^2)

---@class sp.Physics
---目前还没有清晰的思路
---的一个物理引擎
local Physics = plus.Class()
sp.Physics = Physics

function Physics:init(lx, rx, by, ty, g, air, loss, friction, static_fric)
    self:SetG(g)
    self:SetAir(air)
    self:SetELoss(loss)
    self:SetFriction(friction, static_fric)
    self:SetBound(lx, rx, by, ty)

    ---大概用来装在该物理引擎中的obj
    self.objs = {}
end

---设置边界
function Physics:SetBound(lx, rx, by, ty)
    self.lx, self.rx, self.by, self.ty = lx, rx, by, ty
end

---设置能量损失倍数
function Physics:SetELossIndex(loss)
    self.ELossIndex = loss or lossindex_normal
end

---设置摩擦系数（动摩擦和静摩擦）
function Physics:SetFriction(friction, static_fric)
    self.Friction = friction or friction_normal
    self.Static_Fric = static_fric or static_fric_normal
end

---设置引力
function Physics:SetG(g)
    self.g = g or g_normal
end

---设置空气密度与流动
function Physics:SetAir(air, vx, vy)
    self.air = air or air_normal
    self.air_vx = vx or 0
    self.air_vy = vy or 0
end

---帧行为
function Physics:frame()
    for _, o in ipairs(self.objs) do
        o:frame()
    end
end

---大概是所有特殊obj的基类
---质量Mass的单位应该是kg
---体积Volume的单位应该是m^3
---密度Density的单位应该是kg/m^3---密度可能用不上？
local Normal_obj = plus.Class()
function Normal_obj:init(real_obj, m, physics)
    self.obj = real_obj
    object.StopMoving(self.obj)--可能会有用？
    self.status = IsValid(self.obj)
    --self.obj.navi = true
    self.Inphy = physics
    table.insert(physics.objs, self)
    self:SetMass(m)
end

---设置质量，顺便设置密度
---@param m number
function Normal_obj:SetMass(m)
    self.mass = m
    if self.volume then
        self.density = self.mass / self.volume
    else
        self.density = 1
        self.volume = self.mass
    end
end

---设置体积，顺便设置密度
---@param v number
function Normal_obj:SetVolume(v)
    self.volume = v
    if self.mass then
        self.density = self.mass / self.volume
    else
        self.density = 1
        self.mass = self.mass
    end
end

function Normal_obj:frame()
    self.status = IsValid(self.obj)
    if not self.status then
        return
    end
end

---将力转为加速度
---@return number, number
function Normal_obj:ForceToAccel(Force)
    return Force.x / self.mass, Force.y / self.mass
end

---可能目前只会写球的--
---半径Radius的单位应该是m
---表面积Surface的单位应该是m^2
local Ball = plus.Class(Normal_obj)
sp.Physics_Ball = Ball
function Ball:init(real_obj, m, physics, r)
    Normal_obj.init(self, real_obj, m, physics)
    self:SetRadius(r)
    ---大概是空气阻力系数
    self.DC = 0.5
    ---能量损失
    self.ELossIndex = 0.5
    ---动摩擦系数
    self.Friction = 0.0005
    ---静摩擦系数
    self.Static_Fric = 0.00055
    self.isBall = true
end

---设置球的半径
function Ball:SetRadius(r)
    self.radius = r
    self.surface = 4 * PI * r * r--表面积，大概可以用来算空气阻力？
    self:SetVolume(4 / 3 * PI * r * r * r)
end

---帧行为
function Ball:frame()
    Normal_obj.frame(self)
    if not self.status then
        return
    end
    local Phy = self.Inphy
    local obj = self.obj

    local LossIndex = sqrt(self.ELossIndex * Phy.ELossIndex)
    local Friction = self.Friction * Phy.Friction
    local Static_Fric = self.Static_Fric * Phy.Static_Fric

    local Force = NewV(0, 0)
    Force = Force + NewV(0, -self.mass * Phy.g)--重力
    local V, rot = GetV(obj)
    local _k = 0.5 * self.DC * Phy.air * self.surface / 2
    Force = Force + NewV2(_k * V * V, rot+180)
    Force = Force + NewV(_k * Phy.air_vx * Phy.air_vx * sign(Phy.air_vx), 0)
    Force = Force + NewV(0, _k * Phy.air_vy * Phy.air_vy * sign(Phy.air_vy))--空气阻力

    if obj.y - self.radius <= Phy.by then
        obj.y = 2 * Phy.by - (obj.y - self.radius) * LossIndex
        local Elastic = max(-Force.y, 0)
        if obj.vy < 0 then
            Elastic = Elastic - obj.vy * (1 + LossIndex) * self.mass
            Force = Force + NewV(0, Elastic)
        else
            Force = Force + NewV(0, Elastic)
        end
        if obj.vx ~= 0 then
            Force = Force + NewV(-Elastic * Friction * sign(obj.vx), 0)
        end
    end
    if obj.y + self.radius >= Phy.ty then
        obj.y = 2 * Phy.ty - (obj.y + self.radius) * LossIndex
        local Elastic = -min(Force.y, 0)
        if obj.vy > 0 then
            Elastic = Elastic - obj.vy * (1 + LossIndex) * self.mass
            Force = Force + NewV(0, Elastic)
        else
            Force = Force + NewV(0, Elastic)
        end
        if obj.vx ~= 0 then
            Force = Force + NewV(-Elastic * Friction * sign(obj.vx), 0)
        end
    end

    if obj.x - self.radius <= Phy.bx then
        obj.x = 2 * Phy.bx - (obj.x - self.radius) * LossIndex
        local Elastic = max(-Force.x, 0)
        if obj.vx < 0 then
            Elastic = Elastic - obj.vx * (1 + LossIndex) * self.mass
            Force = Force + NewV(Elastic, 0)
        else
            Force = Force + NewV(Elastic, 0)
        end
        if obj.vy ~= 0 then
            Force = Force + NewV(0, -Elastic * Friction * sign(obj.vy))
        end
    end
    if obj.x + self.radius >= Phy.tx then
        obj.x = 2 * Phy.tx - (obj.x + self.radius) * LossIndex
        local Elastic = -min(Force.x, 0)
        if obj.vx < 0 then
            Elastic = Elastic - obj.vx * (1 + LossIndex) * self.mass
            Force = Force + NewV(Elastic, 0)
        else
            Force = Force + NewV(Elastic, 0)
        end
        if obj.vy ~= 0 then
            Force = Force + NewV(0, -Elastic * Friction * sign(obj.vy))
        end
    end

    local ax, ay = Normal_obj.ForceToAccel(self, Force)
    obj.vx = obj.vx + ax
    obj.vy = obj.vy + ay
end


