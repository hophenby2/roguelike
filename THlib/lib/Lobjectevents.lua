----------------------------------------
---单位管理

--单位清理相关

function object:KillServants()
    if self._servants then
        for _, v in pairs(self._servants) do
            if IsValid(v) then
                object.Kill(v)
            end
        end
        self._servants = {}
    end
end

function object:DelServants()
    if self._servants then
        for _, v in pairs(self._servants) do
            if IsValid(v) then
                object.Del(v)
            end
        end
        self._servants = {}
    end
end

function object:RawDel()
    if self then
        self.status = 'del'
        if self._servants then
            object.DelServants(self)
        end
    end
end

function object:RawKill()
    if self then
        self.status = 'kill'
        if self._servants then
            object.KillServants(self)
        end
    end
end

function object:Preserve()
    self.status = 'normal'
end

function object:Kill()
    if self then
        object.KillServants(self)
        Kill(self)
    end
end

function object:Del()
    if self then
        object.DelServants(self)
        Del(self)
    end
end
local cos, sin = cos, sin
local SetV = SetV
local Angle = Angle
local IsValid = IsValid

--单位速度相关
object.SetV = SetV
function object:SetVxVy(vx, vy, norot)
    self.vx = vx
    self.vy = vy
    if not norot then
        self.rot = Angle(0, 0, vx, vy)
    end
end

function object:SetA(a, rot, aim, navi)
    if navi then
        self.navi = true
    end
    if aim then
        rot = rot + Angle(self, player)
    end
    self.ax = a * cos(rot)
    self.ay = a * sin(rot)
end

function object:SetG(g, navi, maxv)
    if navi then
        self.navi = true
    end
    self.ag = g
    self.maxv = maxv or self.maxv
end

function object:ForbidV(v, vx, vy)
    self.maxv = v or self.maxv
    self.maxvx = vx or self.maxvx
    self.maxvy = vy or self.maxvy
end

---立即停止运动
function object:StopMoving()
    self.vx, self.vy = 0, 0--速度
    self.ax, self.ay = 0, 0--加速度
    self.ag = 0--重力
end

---子弹变速
---需要task环境
---@param iv number@InitVelocity
---@param tv number@TargetVelocity
---@param rotate number@朝向跟随速度方向，默认为true
---@param setmode number@改变的模式，默认为线性
function object:ChangingV(iv, tv, angle, time, rotate, setmode)
    rotate = (rotate or rotate == nil) and true
    setmode = setmode or 0
    iv = iv or GetV(self)
    angle = angle or self.rot
    local V = tv - iv
    local task = task
    for i = 1, time do
        SetV(self, iv + V * task.SetMode[setmode](i / time), angle, rotate)
        task.Wait()
    end
end

---子弹变向
---需要task环境
---@param ia number@InitAngle
---@param da number@AddAngle
function object:ChangingA(ia, da, time, setmode)
    setmode = setmode or 0
    local task = task
    for i = 1, time do
        self.rot = ia + da * task.SetMode[setmode](i / time)
        task.Wait()
    end
end

---子弹变速变向
---需要task环境
function object:ChangingVA(iv, tv, ia, da, time, rotate, setmode)
    rotate = (rotate or rotate == nil) and true
    setmode = setmode or 0
    local V = tv - iv
    local task = task
    for i = 1, time do
        i = task.SetMode[setmode](i / time)
        SetV(self, iv + V * i, ia + da * i, rotate)
        task.Wait()
    end
end

---独自创建一个task来执行速度变化
function object:ChangeVwithTask(iv, tv, angle, time, delay, rotate, setmode)
    local task = task
    task.New(self, function()
        task.Wait(delay or 0)
        object.ChangingV(self, iv, tv, angle, time, rotate, setmode)
    end)
end

---独自创建一个task来执行方向变化
function object:ChangeAwithTask(ia, da, time, delay, setmode)
    local task = task
    task.New(self, function()
        task.Wait(delay or 0)
        object.ChangingA(self, ia, da, time, setmode)
    end)
end

---独自创建一个task来执行变速变向
function object:ChangeVAwithTask(iv, tv, ia, da, time, delay, rotate, setmode)
    local task = task
    task.New(self, function()
        task.Wait(delay or 0)
        object.ChangingVA(self, iv, tv, ia, da, time, rotate, setmode)
    end)
end


--单位绑定相关
--已经很少用到了

---绑定主从关系
---@param servant object
---@param dmg_transfer number@伤害传导比例
---@param con_death boolean@是否连接清理
function object:Connect(servant, dmg_transfer, con_death)
    if IsValid(self) and IsValid(servant) then
        if con_death or con_death == nil then
            self._servants = self._servants or {}
            table.insert(self._servants, servant)
        end
        servant._master = self
        servant._dmg_transfer = dmg_transfer or 0
    end
end

---设置相对位置
---使用unit._master进行绑定
---@param x number
---@param y number
---@param rot number
---@param follow_rot boolean
function object:SetRelPos(x, y, rot, follow_rot)
    if self._master and IsValid(self._master) then
        local master = self._master
        if follow_rot then
            x, y = x * cos(master.rot) - y * sin(master.rot), x * sin(master.rot) + y * cos(master.rot)
            rot = rot + master.rot
        end
        self.x = master.x + x
        self.y = master.y + y
        self.rot = rot
    end
end

--单位拖影相关
local table = table
local SetImageState = SetImageState
local SetAnimationState = SetAnimationState
local unpack = unpack
local Render = Render
local RenderAnimation = RenderAnimation
local Color = Color

function object:smear_add(alpha)
    if not self.smear then
        self.smear = {}
    end
    table.insert(self.smear, { x = self.x, y = self.y, rot = self.rot, alpha = alpha, img = self.img, hscale = self.hscale, vscale = self.vscale })
end

local OriginalSmearBlend = "mul+add"
local OriginalSmearColor = { 200, 200, 200 }

function object:smear_frame(dealpha)
    if self.smear then
        local s
        local max = max
        for i = #self.smear, 1, -1 do
            s = self.smear[i]
            s.alpha = max(s.alpha - dealpha, 0)
            if s.alpha == 0 then
                table.remove(self.smear, i)
            end
        end
    end
end

function object:smear_render(mode, color)
    mode = mode or OriginalSmearBlend
    color = color or OriginalSmearColor
    local R, G, B = unpack(color)
    if self.smear then
        for _, s in ipairs(self.smear) do
            SetImageState(s.img, mode, max(0, s.alpha), R, G, B)
            Render(s.img, s.x, s.y, s.rot, s.hscale, s.vscale)
        end
    end
end
function object:smear_renderAnimation(mode, color)
    if self.smear then
        for i, s in ipairs(self.smear) do
            SetAnimationState(s.img, mode, max(0, s.alpha), unpack(color))
            RenderAnimation(s.img, self.ani + i, s.x, s.y, s.rot, s.hscale, s.vscale)
        end
    end
end


--只是方便遍历obj的操作
local ObjList = ObjList
function object.BulletDo(func)
    for _, o in ObjList(1) do
        func(o)
    end
end
function object.IndesDo(func)
    for _, o in ObjList(5) do
        func(o)
    end
end
function object.BulletIndesDo(func)
    for _, o in ObjList(1) do
        func(o)
    end
    for _, o in ObjList(5) do
        func(o)
    end
end
function object.EnemyDo(func)
    for _, o in ObjList(2) do
        func(o)
    end
end
function object.NontjtDo(func)
    for _, o in ObjList(7) do
        func(o)
    end
end
function object.EnemyNontjtDo(func)
    for _, o in ObjList(2) do
        func(o)
    end
    for _, o in ObjList(7) do
        func(o)
    end
end
function object.LaserDo(func)
    for _, o in ObjList(10) do
        func(o)
    end
end

local abs = abs
--尺寸相关
function object:SetSize(h, v)
    h = h or 1
    v = v or h
    self.hscale = h
    self.vscale = v
end
function object:SetColli(a, b)
    a = a or 0
    b = b or a
    self.a = abs(a)
    self.b = abs(b)
    --self.a = self.A
    --self.b = self.B
end
function object:SetSizeColli(h, v)
    h = h or 1
    v = v or h
    object.SetColli(self, h / self.hscale * self.a, v / self.vscale * self.b)
    object.SetSize(self, h, v)

end
---大小变化过程
---需要task
function object:ChangingSizeColli(dh, dv, time, mode)
    mode = mode or 0
    local h = self.hscale
    local v = self.vscale
    local _a, _b = self.a / h, self.b / v
    local task = task
    for i = 1, time do
        i = task.SetMode[mode](i / time)
        self.hscale = h + dh * i
        self.vscale = v + dv * i
        self.a = _a * self.hscale
        self.b = _b * self.vscale
        task.Wait()
    end
end
function object:ChangeSizeColliWithTask(dh, dv, time, mode, delay)
    local task = task
    task.New(self, function()
        task.Wait(delay or 0)
        object.ChangingSizeColli(self, dh, dv, time, mode)
    end)
end

local lstg = lstg
--反弹与穿板
local ReboundCommand = {
    ["l"] = function(self, offset)
        return self.x < lstg.world.l + offset.x, "vx", "x", lstg.world.l + offset.x
    end,
    ["r"] = function(self, offset)
        return self.x > lstg.world.r - offset.x, "vx", "x", lstg.world.r - offset.x
    end,
    ["b"] = function(self, offset)
        return self.y < lstg.world.b + offset.y, "vy", "y", lstg.world.b + offset.y
    end,
    ["t"] = function(self, offset)
        return self.y > lstg.world.t - offset.y, "vy", "y", lstg.world.t - offset.y
    end
}
local ShuttleCommand = {
    ["l"] = function(self, offset)
        return self.x < lstg.world.l + offset.x, "x", lstg.world.l + offset.x
    end,
    ["r"] = function(self, offset)
        return self.x > lstg.world.r - offset.x, "x", lstg.world.r - offset.x
    end,
    ["b"] = function(self, offset)
        return self.y < lstg.world.b + offset.y, "y", lstg.world.b + offset.y
    end,
    ["t"] = function(self, offset)
        return self.y > lstg.world.t - offset.y, "y", lstg.world.t - offset.y
    end
}
local DefaultOffset = { x = 0, y = 0 }

---@param bound table@要反弹的版
---@param offset table@{x,y}偏移值
---@param condition boolean@条件为true检测反弹
---@param command function@反弹时执行指令
function object:ReBound(bound, offset, condition, command)
    if condition then
        offset = offset or DefaultOffset
        local factor, v, pos, pos2
        for _, co in ipairs(bound) do
            factor, v, pos, pos2 = ReboundCommand[co](self, offset)
            if factor then
                self[v] = -self[v]
                self.rot = Angle(0, 0, self.vx, self.vy)
                self[pos] = pos2 * 2 - self[pos]
                if command then
                    command(self)
                end
                return
            end
        end
    end
end
---@param bound table@要穿板的版
---@param offset table@{x,y}偏移值
---@param condition boolean@条件为true检测穿板
---@param command function@穿板时执行指令
function object:Shuttle(bound, offset, condition, command)
    if condition then
        offset = offset or DefaultOffset
        local factor, pos, pos2
        for _, co in ipairs(bound) do
            factor, pos, pos2 = ShuttleCommand[co](self, offset)
            if factor then
                self[pos] = pos2 * 2 - self[pos]
                self[pos] = -self[pos]
                if command then
                    command(self)
                end
                return
            end
        end
    end
end

local _group = GROUP
function object:SetGroup(group)
    if type(group) == "number" then
        self.group = group
    else
        self.group = _group[group]
    end
end

local _layer = LAYER
function object:SetLayer(layer)
    if type(layer) == "number" then
        self.group = layer
    else
        self.group = _layer[layer]
    end
end

