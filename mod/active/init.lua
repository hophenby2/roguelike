---主动道具逻辑
local lib = {}
activeItem_lib = lib

loadLanguageModule("active", "mod\\active\\lang")
local function _t(str)
    return i18n("active", str) or ""
end

---@type active_obj
lib.class = DoFile("mod\\active\\active_obj.lua")
---@type active_unit[][]
lib.ListByQual = { {}, {}, {}, {}, {} }
---@type active_unit[]
lib.ActiveTotalList = {}--主动道具总列表

local qual_col = {
    { 200, 220, 230 },
    { 110, 255, 132 },
    { 108, 210, 255 },
    { 235, 128, 240 },
    { 235, 220, 132 }
}

---@return addition_unit
---@param event fun()
---@param active_type number@充能类型：1是每帧，2是每波，3是每点攻击
---@param charge_c number@充能量
---@param hold boolean@是否可长按
local function NewSimpleActiveUnit(id, qual, title, event, active_type, charge_c, maxe, cond, locked, hold)
    ---@class active_unit
    local self = {}
    self.id = id
    ---可供修改的数据
    self.type = active_type
    self.charge_c = charge_c
    self.energy = 1
    self.energy_max = maxe or 1
    self.cost = 1
    self.normal_function = function()
    end

    ---内部存储的数据
    self._is_using = false--是否在使用
    self.last_is_using = false--上一帧是否在使用
    self._type = active_type
    self._charge_c = charge_c
    self._energy_max = maxe
    self.hold = hold or false
    self.isActive = true
    ---基础概率
    self.proba = 0.1
    ---混沌值权重
    self.chaos_power = 0
    local beforeTitle = _t("active")
    ---叠卡权重
    self.title = beforeTitle .. title
    ---除去前缀的名称
    self.title2 = title
    ---只保留前缀的名称
    self.title3 = beforeTitle
    self.R, self.G, self.B = 255, 255, 255
    ---概率修正，一般由其他道具修改
    self.pro_fixed = 1
    self.state = 0
    self.quality = qual
    self.R, self.G, self.B = unpack(qual_col[qual + 1])
    self._quality = qual
    ---副标题
    self.subtitle = ""
    ---详述
    self.detail = ""
    ---简述
    self.describe = ""
    ---道具协同
    self.collab_des = ""
    ---解锁方式
    self.unlock_des = ""
    ---出现前提
    self.cond_des = ""
    ---标签
    self.tags = {}
    self.pic = "active_state" .. self.id
    if GlobalLoading then
        LoadImageFromFile(self.pic, ("assets\\active_unit\\state%s.png"):format(self.id), true)
        local w, h = GetImageSize(self.pic)
        local k = max(w, h)
        SetImageScale(self.pic, 256 / k)
    else
        table.insert(LoadRes, function()
            LoadImageFromFile(self.pic, ("assets\\active_unit\\state%s.png"):format(self.id), true)
            local w, h = GetImageSize(self.pic)
            local k = max(w, h)
            SetImageScale(self.pic, 256 / k)
        end)
    end

    ---使用后进行的事件
    self.event = event
    self.is_locked = locked--保存其拥有的flag
    ---出现的条件
    self.condition = cond
    self.upgrade_get = function()
        local flag = true
        flag = flag and scoredata.UnlockActive[self.id]--解锁机制
        if self.condition then
            flag = flag and self.condition()
        end
        return flag
    end
    lib.ActiveTotalList[id] = self

    local data = scoredata
    data.ShowNewActive[id] = data.ShowNewActive[id] or false
    data.BookActive[id] = data.BookActive[id] or false
    if not data.UnlockActive[id] then
        if locked then
            data.UnlockActive[id] = false
        else
            data.UnlockActive[id] = true--就直接开启咯
        end
    end
    function self:SetUsing(flag)
        self.last_is_using = self._is_using
        self._is_using = flag
    end

    function self:ShowNew()
        return data.ShowNewActive[self.id]
    end
    function self:HandBook()
        return data.BookActive[self.id]
    end
    function self:Unlock()
        return data.UnlockActive[self.id]
    end
    function self:Noticeinitial()
        return false
    end
    function self:OpenHandbook()
        data.BookActive[self.id] = true
    end
    function self:SetUnlock()
        data.UnlockActive[self.id] = true
    end
    function self:Set()
        lib.SetActive(self)
    end
    function self:Remove()
        lib.RemoveActive(self)
    end
    function self:CanGet()
        return true
    end

    return self
end
lib.NewSimpleActiveUnit = NewSimpleActiveUnit

---道具的详细信息补充
local function DetailActiveUnit(id, describe, stitle, detail, tags, collabd, unlockd, condd)
    local none = _t("none")
    ---@type active_unit
    local u = lib.ActiveTotalList[id]
    u.subtitle = stitle or none
    u.describe = describe or none
    u.detail = detail or none
    u.collab_des = collabd or none
    u.unlock_des = unlockd or none
    u.cond_des = condd or none
    if type(tags) == "string" then
        u.tags = { tags }
    else
        u.tags = tags or { none }
    end

end
lib.DetailActiveUnit = DetailActiveUnit

---语言模块式补充道具详细信息
local module = "active_des"
loadLanguageModule(module, "mod\\active")

---@param event fun(self:active_unit)
---@param active_type number@充能类型：1是每帧，2是每波，3是每点攻击
---@param charge_c number@充能量
local function NewActiveUnit(id, qual, event, active_type, charge_c, maxe, cond, tags, locked, hold, cost, normal_function)
    local p = qual + 1
    local c = i18n(module, p)[id] or {}
    local n = NewSimpleActiveUnit(id, qual, c.name, event, active_type, charge_c, maxe, cond, locked, hold)
    if cost then
        n.cost = cost
    end
    if normal_function then
        n.normal_function = normal_function
    end
    DetailActiveUnit(id, c.sdes, c.stitle, c.detail, tags, c.collabd, c.unlockd, c.condd)
    table.insert(lib.ListByQual[p], n)
    return n
end
lib.NewActiveUnit = NewActiveUnit

---@param unit UI_active_item
local function GetActiveUIPos(unit, pos)
    local x, y, r = 110, 70, 29
    if not unit.alive then
        x = 0
        r = 0
    end
    if pos > 1 then
        local vl = sqrt(pos - 1)
        r = max(25 - vl * 9, 0)
        x = 122 - vl ^ 1.26 * 55
        y = 75 - task.SetMode[2](0.2 + pos / 6) * 35
    end
    return x, y, r
end
lib.GetActiveUIPos = GetActiveUIPos

local function SetActive(m)
    local var = lstg.var
    local id = m.id
    local data = scoredata
    data.BookActive[id] = true
    table.insert(var.active_item, 1, id)
    ---@class UI_active_item
    local UI_active_item = {
        id = id,
        alpha = 0,
        x = 135, y = 132,
        r = 16,
        alive = true,
    }
    table.insert(var.UI_active_item, 1, UI_active_item)
    New(tool_lib.ShowGetAddition, m)
    data._total_get_item = data._total_get_item + 1
    if #var.active_item > var.max_active_item then
        local remove_id = table.remove(var.active_item)
        for _, v in ipairs(var.UI_active_item) do
            if v.id == remove_id then
                v.alive = false
                break
            end
        end
        lib.DropActive(player.x, player.y, remove_id)
    end
end
lib.SetActive = SetActive

local function DropActive(x, y, m)
    local drop = New(tool_lib.bubble_tool, x, y, lib.ActiveTotalList[m])
    task.New(drop, function()
        local bound = { "l", "r", "b", "t" }
        local offset = { x = drop.a, y = drop.b }
        local ang = 0
        if IsValid(player) then
            ang = atan2(-player.dy, -player.dx)
        end
        if ang % 90 < 1e-6 then
            ang = ang + ran:Sign() * 30
        end
        drop.vx, drop.vy = cos(ang) * 2.5, sin(ang) * 2.5
        while drop.timer < 1500 do
            object.ReBound(drop, bound, offset, true)
            task.Wait()
        end
    end)
end
lib.DropActive = DropActive

local function RemoveActive(m)
    local var = lstg.var
    local id = m.id
    for i, v in ipairs(var.active_item) do
        if v == id then
            table.remove(var.active_item, i)
            var.UI_active_item[i].alive = false
            break
        end
    end
end
lib.RemoveActive = RemoveActive

local function ChangeActive()
    local var = lstg.var
    table.insert(var.active_item, table.remove(var.active_item, 1))
    table.insert(var.UI_active_item, table.remove(var.UI_active_item, 1))
end
lib.ChangeActive = ChangeActive

local function IfHasActive(id)
    local var = lstg.var
    for _, v in ipairs(var.active_item) do
        if v == id then
            return true
        end
    end
    return false
end
lib.IfHasActive = IfHasActive

local function GetChargeEfficiency()
    local var = lstg.var
    local e = var.active_charge_efficiency
    return e
end
lib.GetChargeEfficiency = GetChargeEfficiency

local function CheckTypeAndAddCharge(Active, targettype, value)
    if Active.type == targettype then
        local before = Active.energy
        Active.energy = min(Active.energy_max, Active.energy + Active.charge_c * GetChargeEfficiency() * value)
        local after = Active.energy
        if int(after) - int(before) > 0 then
            PlaySound("charged")
            PlaySound("ch01")
        end
    end
end
local function DefineChargeMode(type)
    return function(t)
        t = t or 1
        local var = lstg.var
        for _, id in ipairs(var.active_item) do
            CheckTypeAndAddCharge(lib.ActiveTotalList[id], type, t)
        end
    end
end
lib.AddActiveChargeByFrame = DefineChargeMode(1)
lib.AddActiveChargeByWave = DefineChargeMode(2)
lib.AddActiveChargeByPT = DefineChargeMode(3)

DoFile("mod\\active\\init_active.lua")