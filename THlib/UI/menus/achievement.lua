local function _t(str)
    return i18n("sth", str) or ""
end

local achievement_menu = stage.New("achievement", false, true)
function achievement_menu:init()
    self.top_bar = top_bar_Class(self, _t("achievement"))
    self.exit_func = function()
        task.New(self, function()
            self.locked = true
            mask_fader:Do("close")
            task.Wait(15)
            stage.Set("none", "main")
        end)
    end
    self.top_bar:addReturnButton(self.exit_func)
    mask_fader:Do("open")
    self.alpha = 1
    self.timer = 0
    self.tri2 = 1
    self.ox = 0
    ------------------------------------------
    self.now = nil
    self.select = nil
    self.rank_color = sp:CopyTable(ext.achievement.rank)
    setmetatable(self.rank_color, { __index = function(t, k)
        return t[(k - 1) % #t + 1]
    end })
    self.rank_select = { _t("Achv1"), _t("Achv2"), _t("Achv3"), _t("Achv4"), _t("Achv5"), _t("Achv6"), }
    setmetatable(self.rank_select, { __index = function(t, k)
        return t[(k - 1) % #t + 1]
    end })
    self.rank_pos = 1
    self:Refresh()
    self.locked = true
    task.New(self, function()
        task.Wait(30)
        while GetKeyState(KEY.Z) do
            task.Wait()
        end
        self.locked = false
    end)
    self.x, self.y = 480, 235
    self.w, self.h = 300, 190
    self.locked = true
    self.offy1 = 0
    self._offy1 = 0
    self.line_h_1 = 65
end
function achievement_menu:refreshlist()
    self.infodata = self.mainlist[self.rank_pos]
    task.New(self, function()
        for i = 1, 10 do
            self.tri2 = sin(i * 9)
            task.Wait()
        end
    end)
end
function achievement_menu:frame()
    self.timer = self.timer + 1
    if self.locked then
        return
    end
    local mouse = ext.mouse
    menu:Updatekey()
    local x1, x2, y1, y2, h
    x1, x2, y1, y2 = self.x - self.w, self.x + self.w, self.y - self.h, self.y + self.h
    h = y2 - y1
    self._offy1 = self._offy1 + (-self._offy1 + clamp(self._offy1, 0, max(self.line_h_1 * #self.infodata - h, 0))) * 0.3
    self.offy1 = self.offy1 + (-self.offy1 + self._offy1) * 0.3
    self.ox = self.ox - self.ox * 0.08
    if menu:keyNo() then
        PlaySound("cancel00", 0.3)
        self.exit_func()
    else
        if menu:keyUp() then
            self._offy1 = self._offy1 - self.line_h_1 * 2.5
            PlaySound("select00")
        end
        if menu:keyDown() then
            self._offy1 = self._offy1 + self.line_h_1 * 2.5
            PlaySound("select00")
        end
        if menu:keyLeft() then
            self.rank_pos = sp:TweakValue(self.rank_pos - 1, #self.rank_select, 1)
            self.ox = self.ox - 170
            self:refreshlist()
            PlaySound('select00', 0.3)
        end
        if menu:keyRight() then
            self.rank_pos = sp:TweakValue(self.rank_pos + 1, #self.rank_select, 1)
            self.ox = self.ox + 170
            self:refreshlist()
            PlaySound('select00', 0.3)
        end
        if sp.math.PointBoundCheck(mouse.x, mouse.y, x1, x2, y1, y2) then
            if mouse._wheel ~= 0 then
                self._offy1 = self._offy1 - sign(mouse._wheel) * self.line_h_1 * 2.5
                PlaySound("select00")
            end
        elseif mouse.y < 540 - 46 then
            if mouse:isUp(1) then
                for i = -3, 3 do
                    if i ~= 0 and abs(mouse.x - (480 + 170 * i + self.ox)) < 75 then
                        self.rank_pos = sp:TweakValue(self.rank_pos + i, #self.rank_select, 1)
                        self.ox = self.ox + 170 * i
                        self:refreshlist()
                        PlaySound("select00")
                    end
                end
            end
            if mouse._wheel ~= 0 then
                self.rank_pos = sp:TweakValue(self.rank_pos - sign(mouse._wheel), #self.rank_select, 1)
                self.ox = self.ox - sign(mouse._wheel) * 170
                self:refreshlist()
                PlaySound("select00")
            end
        end
    end
    self.top_bar:frame()
end
function achievement_menu:render()
    if self.alpha == 0 then
        return
    end
    local A = self.alpha
    ui:DrawBack(A, self.timer)
    SetImageState("white", "", 666, 0, 0, 0)--刷新存储列表
    OriginalSetImageState("white", "",
            Color(0, 0, 0, 0),
            Color(200 * A, 0, 0, 0),
            Color(200 * A, 0, 0, 0),
            Color(0, 0, 0, 0))
    local py = 475
    RenderRect("white", 76, 480, py + 16, py - 16)
    RenderRect("white", 884, 480, py + 16, py - 16)
    SetImageState("white", "", 255, 0, 0, 0)
    for i = -3, 3 do
        local p = i + self.rank_pos
        local str = ("%s(%d/%d)"):format(self.rank_select[p], self.get_count[p], self.total_count[p])
        ui:RenderText("pretty", str, 480 + 170 * i + self.ox, py + 2, 0.45,
                Color((((i == 0) and 255) or 120) * A, unpack(self.rank_color[p])), "centerpoint")
    end
    do
        local alpha = A * self.tri2
        local x1, x2, y1, y2, Y
        x1, x2, y1, y2 = self.x - self.w, self.x + self.w, self.y - self.h, self.y + self.h
        SetImageState("white", "", alpha * 180, 10, 10, 10)
        RenderRect("white", x1, x2, y1, y2)
        SetImageState("white", "", alpha * 255, 255, 255, 255)
        misc.RenderOutLine("white", x1, x2, y2, y1, 0, 2)
        SetRenderRect(x1, x2, y1 - self.offy1, y2 - self.offy1, x1, x2, y1, y2)
        Y = y2
        RenderRect("white", x1, x2, Y - 0.5, Y + 0.5)
        local _h = self.line_h_1
        for i, o in ipairs(self.infodata) do
            if Y < y1 - self.offy1 then
                break
            end
            Y = Y - _h
            if Y < y2 - self.offy1 then
                ---@type addition_unit
                local index = 0.5
                local R, G, B = unpack(self.rank_color[self.rank_pos])
                local tR, tG, tB = 150, 150, 150
                local img = "menu_locked_icon"
                local hide = o.hide or (not o.showcond())
                if o.IsGet then
                    img = "menu_unlocked_icon"
                    tR, tG, tB = R, G, B
                    index = 1
                end
                SetImageState("white", "", index * alpha * 75, R / 2, G / 2, B / 2)
                RenderRect("white", x1, x2, Y + _h, Y)
                RenderRect("white", x1 + 1, x1 + _h - 1, Y + _h - 1, Y + 1)
                SetImageState("white", "", index * alpha * 255, 255, 255, 255)
                RenderRect("white", x1, x2, Y - 1, Y + 1)
                RenderRect("white", x1 + _h - 1, x1 + _h + 1, Y + _h, Y)
                local getway_comment = sp:SplitText(o.getway, "\n")
                local name = string.format("%02d. %s %s", o.id, o.IsGet and o.name:Get() or "? ? ?", hide and "(hide)" or "")
                local getway
                if o.IsGet or DEBUG then
                    getway = getway_comment[1]
                else
                    getway = (hide and "???" or getway_comment[1])
                end
                ui:RenderText("title", name, x1 + _h + 5, Y + _h - 3,
                        1, Color(index * A * 255, R, G, B), "left", "top")
                ui:RenderTextWithCommand("title", getway, x1 + _h + 32, Y + _h - 26,
                        0.65, index * A * 180, "left", "top")
                ui:RenderTextWithCommand("title", getway_comment[2] or "", x1 + _h + 32, Y + _h - 42,
                        0.65, index * A * 180, "left", "top")
                local time = o.time
                if time then
                    local str = os.date("!%Y/%m/%d %H:%M:%S", time + setting.timezone * 3600)
                    ui:RenderText("title", ("%s"):format(str), x2 - 8, Y + _h - 35,
                            0.8, Color(index * A * 255, R, G, B), "right", "top")
                end
                SetImageState(img, "", index * 200, 255, 255, 255)
                Render(img, x1 + _h / 2, Y + _h / 2, 0, 0.45)
                if o.hide then
                    misc.RenderBrightOutline(x1, x2, Y, Y + _h,
                            10, A * (sin(self.timer * 2 + i * 120) * 30 + 60), R, G, B)
                end
            end

        end

        SetViewMode("ui")
        local str = ("%s§g%d§d/§y%d"):format(_t("achieveCount"), self.All_get, self.All_total)
        ui:RenderTextWithCommand("title", str, self.x, self.y - self.h - 24,
                0.9, A * 200, "centerpoint")
    end
    self.top_bar:render()
end
function achievement_menu:Refresh()
    local sp = sp
    self.mainlist = {}
    self.infodata = {}
    self.All_total = 0
    self.All_get = 0
    self.total_count = { 0, 0, 0, 0, 0, 0 }
    setmetatable(self.total_count, { __index = function(t, k)
        return t[(k - 1) % #t + 1]
    end })
    self.get_count = { 0, 0, 0, 0, 0, 0 }
    setmetatable(self.get_count, { __index = function(t, k)
        return t[(k - 1) % #t + 1]
    end })
    local o = 0
    for i, unit in pairs(AchievementInfo) do
        if not self.mainlist[unit.rank] then
            self.mainlist[unit.rank] = {}
        end
        local u = {
            real_id = i,
            id = i,
            name = sp.string(unit.name),
            IsGet = scoredata.Achievement[tostring(i)],
            getway = unit.getway,
            hide = unit.hide,
            showcond = unit.showcond,
            rank = ext.achievement.rank[unit.rank],
            sort = unit.rank,
            time = scoredata.AchievementGetTime[tostring(i)]
        }
        table.insert(self.mainlist[unit.rank], u)
        if u.IsGet then
            self.get_count[unit.rank] = self.get_count[unit.rank] + 1
            self.All_get = self.All_get + 1
        end
        self.total_count[unit.rank] = self.total_count[unit.rank] + 1
        self.All_total = self.All_total + 1
        o = o + 1
    end
    for _, m in ipairs(self.mainlist) do
        table.sort(m, function(a, b)
            local ahide = a.hide and 1 or 0
            local bhide = b.hide and 1 or 0
            local aIsGet = a.IsGet and 1 or 0
            local bIsGet = b.IsGet and 1 or 0
            if aIsGet ~= bIsGet then
                return aIsGet > bIsGet
            elseif ahide ~= bhide then
                return ahide < bhide
            else
                return a.id < b.id
            end
        end)
        for i, n in ipairs(m) do
            n.id = i
        end
    end
    self.rank_pos = sp:TweakValue(self.rank_pos, #self.rank_select, 1)
    self.infodata = self.mainlist[self.rank_pos]
end