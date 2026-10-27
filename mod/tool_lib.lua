---把道具和主动道具的获得等函数统一放在这里，不由任意一个子类管理
local lib = {}
tool_lib = lib
local bubbles = {}

local function SortUnit()
    local nums = { 0, 0, 0, 0, 0 }
    local w = lstg.weather
    local v = lstg.var
    for _, u in pairs(stg_levelUPlib.AdditionTotalList) do
        local nowc = (v.addition and v.addition[u.id]) or 0
        local maxc = u.maxcount or 999
        if nowc < maxc and u.pro_fixed > 0 and u.upgrade_get() then
            if u._quality then
                local k = u._quality + 1
                nums[k] = nums[k] + 1
            end
        end
    end
    if scoredata.StartActive then
        for _, u in pairs(activeItem_lib.ActiveTotalList) do
            if (not activeItem_lib.IfHasActive(u.id)) and u.pro_fixed > 0 and u.upgrade_get() then
                local k = u.quality + 1
                nums[k] = nums[k] + 1
            end
        end
    end
    local qual_pro = { 0.1, 0.40, 0.37, 0.12, 0.01 }
    local qual_chaosp = { -0.005, -0.01, 0, 0.01, 0.005 }
    if w.RuiXue then
        qual_pro[5] = qual_pro[5] + 0.05
        qual_pro[4] = qual_pro[4] + 0.1
        --0级1级被顶下去
        qual_pro[1] = qual_pro[1] - 0.05
        qual_pro[2] = qual_pro[2] - 0.1
    end
    for i = 1, 5 do
        local num = max(nums[i], 1)
        qual_pro[i] = qual_pro[i] / num
        qual_chaosp[i] = qual_chaosp[i] / num
    end
    ---@param u addition_unit
    for _, u in pairs(stg_levelUPlib.AdditionTotalList) do
        local i = (u._quality or 0) + 1
        u.proba = max(qual_pro[i], 0)
        u.chaos_power = qual_chaosp[i]
    end
    if scoredata.StartActive then
        for _, u in pairs(activeItem_lib.ActiveTotalList) do
            local i = u.quality + 1
            u.proba = max(qual_pro[i], 0)
            u.chaos_power = qual_chaosp[i]
        end
    end
end
lib.SortUnit = SortUnit

local function ToolOnScreen(p)
    for _, v in ipairs(bubbles) do
        if v.addition == p then
            return true
        end
    end
    return false
end

local function GetAdditionList(count, othercondition)
    local var = lstg.var
    local wea = lstg.weather
    local normal = var.level_upOption
    count = count or normal
    if lstg.tmpvar.SanaeSkill1 and ran:Float(0, 1) < 0.19 then
        count = 9
    end
    othercondition = othercondition or function(add)
        if wea.BiYiRi then
            return add.state == 1
        end
        if wea.JiaoYiRi then
            return add.state == 2
        end
        if wea.QinHaiRi then
            return add.state == 3
        end
        return true
    end
    local list = {}
    local chaos = var.chaos
    local temp = {}
    local lastp = 0
    local tmpvar_otherCondition = lstg.var.othercondition
    ---@param p addition_unit
    for _, p in ipairs(stg_levelUPlib.AdditionList) do
        local nowc = (lstg.var.addition[p.id] or 0)
        local maxc = p.maxcount or 999
        if p.upgrade_get() and (nowc < maxc) and othercondition(p) and tmpvar_otherCondition(p) and not p.broken then
            if not (var.stop_0_tool and p.quality == 0) then
                local cp = p.chaos_power * min(chaos, 25) / 25
                local rp = p.repeat_power * nowc
                local nowp = max((p.proba + cp) * (rp + 1), 0) * p.pro_fixed
                if nowp > 0 then
                    table.insert(temp, { p, lastp, lastp + nowp })
                end
                lastp = lastp + nowp
            end
        end---TODO:注意这里和init.lua是分开的定义，要同步修改
    end
    if scoredata.StartActive and var.max_active_item > 0 then
        sp:UnitListUpdate(bubbles)
        for _, p in pairs(activeItem_lib.ActiveTotalList) do
            if (not activeItem_lib.IfHasActive(p.id) and not ToolOnScreen(p)) and p.upgrade_get() and othercondition(p) and tmpvar_otherCondition(p) then
                if not (var.stop_0_tool and p.quality == 0) then
                    local cp = p.chaos_power * min(chaos, 25) / 25
                    local nowp = max(p.proba + cp, 0) * p.pro_fixed
                    if nowp > 0 then
                        table.insert(temp, { p, lastp, lastp + nowp })
                    end
                    lastp = lastp + nowp
                end
            end
        end
    end

    for _ = 1, count do
        local n = ran:Float(0, lastp)
        for k, p in ipairs(temp) do
            if p[2] <= n and n < p[3] then
                table.insert(list, p[1])
                local len = p[3] - p[2]
                for _k = k + 1, #temp do
                    temp[_k][2] = temp[_k][2] - len
                    temp[_k][3] = temp[_k][3] - len
                end
                lastp = lastp - len
                table.remove(temp, k)
                break
            end
        end
    end
    return list
end
lib.GetAdditionList = GetAdditionList

local Temp_ShowGetAddition
local ShowGetAddition = Class(object)
function ShowGetAddition:init(addition)
    if IsValid(Temp_ShowGetAddition) then
        Del(Temp_ShowGetAddition)
    end
    Temp_ShowGetAddition = self
    self.layer = LAYER.BG + 50
    self.group = GROUP.GHOST
    self.addition = addition
    self.bound = false
    self.x = -320
    self.index = 0
    self.y = 50
    self.renderline = {}
    task.New(self, function()
        local n = int(25) - 1
        local x0 = 0
        for i = 0, n do
            local x1 = task.SetMode[2](i / n) * 190
            for z = -1, 1, 2 do
                table.insert(self.renderline, { offx = z * x1,
                                                time = 10, maxtime = 10, w = abs(x1 - x0) })
            end
            x0 = x1
            task.Wait()
        end
    end)
    task.New(self, function()
        local t = 20
        for i = 1, t do
            i = task.SetMode[2](i / t)
            self.index = i
            self.x = -320 + 320 * i
            task.Wait()

        end
        task.Wait(50)
        for i = 1, t do
            i = task.SetMode[1](i / t)
            self.index = 1 - i
            self.x = 320 * i
            task.Wait()
        end
        Del(self)
    end)
end
function ShowGetAddition:frame()
    task.Do(self)
    local l
    for i = #self.renderline, 1, -1 do
        l = self.renderline[i]
        l.time = max(l.time - 1, 0)
        if l.time == 0 then
            table.remove(self.renderline, i)
        end
    end
end
function ShowGetAddition:render()
    local k = self.index
    local t = self.addition
    SetImageState("white", "", 66, t.R / 3, t.G / 3, t.B / 3)
    --RenderRect("white", -320, 320, self.y - k * 35, self.y + k * 35)
    --RenderRect("white", -320, 320, self.y - k * 30, self.y + k * 30)
    local brness = 255
    local ttf = "big_text"
    local scale1, scale2 = 0.35, 0.2
    local len1 = menu:GetTXTlen(ttf, scale1, t.title2)
    local len2 = menu:GetTXTlen(ttf, scale2, t.subtitle)
    local w1 = 50
    local w2 = max(len1, len2) * 2 + 10
    local pw = (w1 + w2) / 2
    local ox = -w1 / 2
    local ox1 = -pw + w1 / 2 + ox
    local ox2 = -pw + w1 + w2 / 2 + ox
    SetImageState("bright_line", "mul+add", k * 150, t.R, t.G, t.B)
    Render("bright_line", 0, self.y - 4, 0, pw * 2 / 200 * k, 0.3)
    SetImageState("bright", "mul+add", k * 150, t.R, t.G, t.B)
    Render("bright", self.x + ox1, self.y, 0, w1 / 130)
    SetImageState(t.pic, "", k * 222, 200, 200, 200)
    Render(t.pic, self.x + ox1, self.y, 0, w1 / 256)
    RenderTTF3(ttf, t.title2, self.x + ox2, self.y + 12, 0, scale1 * (2 - k), scale1,
            "mul+alpha", Color(k * 180, brness, brness, brness), "centerpoint")
    RenderTTF3(ttf, t.subtitle, self.x + ox2, self.y - 15, 0, scale2 * (2 - k), scale2,
            "mul+alpha", Color(k * 180, brness, brness, brness), "centerpoint")

    local rot = 0
    for _, l in ipairs(self.renderline) do
        SetImageState("white", "mul+add", 50 * l.time / l.maxtime, t.R, t.G, t.B)
        Render("white", 0 - sin(rot) * l.offx, self.y + cos(rot) * l.offx, rot, 100, l.w / 8)
    end
end
lib.ShowGetAddition = ShowGetAddition

local Tool_eid_object
local tool_eid = Class(object)
function tool_eid:init()
    self.group = GROUP.GHOST
    self.layer = LAYER.BG + 15
    self.colli = false
    self.bound = false
end
function tool_eid:frame()
    sp:UnitListUpdate(bubbles)
    if #bubbles == 0 then
        Del(self)
    else
        local md = 999
        local cur
        for _, b in ipairs(bubbles) do
            b.show_des = false
            local d = Dist(b, player)
            if d < md then
                md = d
                cur = b
            end
        end
        if IsValid(cur) then
            cur.show_des = true
        end
    end
end

local bubble_tool = Class(object)
function bubble_tool:init(x, y, tool, money, getFunc)
    sp:UnitListUpdate(bubbles)
    sp:UnitListAppend(bubbles, self)
    if not IsValid(Tool_eid_object) then
        Tool_eid_object = New(tool_eid)
    end
    self.x, self.y = x, y
    self.getFunc = getFunc
    self.addition = tool
    self.img = self.addition.pic
    self.R, self.G, self.B = self.addition.R, self.addition.G, self.addition.B
    self.money = money or 0
    self.a, self.b = 32, 32
    self.alpha = 0
    self.show_des = false
    self.sindex = 0
    self.findex = 0
    self.group = GROUP.ITEM2
    self.layer = LAYER.ITEM
    self.stop = true
    task.New(self, function()
        for i = 1, 15 do
            self.alpha = i / 15
            task.Wait()
        end
    end)
end
function bubble_tool:frame()
    task.Do(self)
    if Dist(self, player) <= self.a + player.a then
        if not self.failed and not self.stop then
            if self.class.collect then
                self.class.collect(self)
            end
        end
    else
        self.failed = nil
        self.stop = false
    end
    if self.failed then
        self.findex = self.findex + (-self.findex + 1) * 0.1
    else
        self.findex = self.findex - self.findex * 0.1
    end
    if self.show_des then
        self.sindex = self.sindex + (-self.sindex + 1) * 0.15
    else
        self.sindex = self.sindex - self.sindex * 0.15
    end
end
function bubble_tool:render()
    local f = self.findex
    local s = self.sindex
    local R, G, B = self.R + (-self.R + 255) * f, self.G + (-self.G + 64) * f, self.B + (-self.B + 64) * f
    local size = self.a - f * 10
    local A = self.alpha
    local t = self.timer

    SetImageState("bright_circleOutline", "mul+add", A * 145, R, G, B)
    Render("bright_circleOutline", self.x, self.y, 0, size / 200)
    SetImageState("bright", "mul+add", A * 255, R, G, B)
    Render("bright", self.x, self.y, 0, size / 107)
    SetImageState(self.img, "", A * 200, 255, 255, 255)
    Render(self.img, self.x, self.y, sin(t * 2) * 6, size / 160)
    if self.money > 0 then
        ui:RenderText("title", ("$ Lv.%d"):format(self.money),
                self.x, self.y - size * 1.1, 0.62, Color(self.alpha * 145, R, G, B), "centerpoint")
    end
    if s > 0.01 then
        ui:RenderText("big_text", "∨", self.x, self.y + size * (1.25 + sin(t * 4) * 0.1),
                0.5, Color(A * 180 * s, R, G, B), "centerpoint")
        ui:RenderText("big_text", "∧", self.x, self.y - size * (1.25 + sin(t * 4) * 0.1),
                0.5, Color(A * 180 * s, R, G, B), "centerpoint")
        local p = self.addition
        local strt = sp:SplitText(p.describe, "\n")
        local line_h = 18
        local sY = -237 + (#strt + 1) * line_h
        local da = clamp(Dist(player, -320, -240) / 150, 0.3, 1)
        ui:RenderText("big_text", p.title, -320 + 6, sY + 9,
                0.45, Color(da * s * A * 190, p.R, p.G, p.B), "left")
        for k, text in ipairs(strt) do
            ui:RenderTextWithCommand("title", text, -320 + 6, sY - k * line_h,
                    0.8, da * s * A * 190, "left")
        end
    end
end
function bubble_tool:kill()
    NewWave(self.x, self.y, 2, self.a * 2, 30, self.R, self.G, self.B, 0)
    NewBon(self.x, self.y, 30, 60, self.R, self.G, self.B)
end
function bubble_tool:del()
    self.class.kill(self)
    if self.delFunc then
        self:delFunc()
    end
end
function bubble_tool:collect()
    local v = lstg.var
    local slib = stg_levelUPlib
    if v.level >= self.money then
        PlaySound("extend")
        if self.money > 0 then
            local index = v.now_exp / slib.GetCurMaxEXP()
            v.level = v.level - self.money
            v.now_exp = index * slib.GetCurMaxEXP()
        end
        if self.addition:CanGet() then
            self.addition:Set(true)
        end
        if self.getFunc then
            self:getFunc()
        end
        Kill(self)
    else
        NewWave(self.x, self.y, 2, self.a * 2, 30, 255, 64, 64, self.a)
        PlaySound("invalid")
        self.failed = true
    end

end
lib.bubble_tool = bubble_tool
