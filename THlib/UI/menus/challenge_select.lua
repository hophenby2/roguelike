local Text = TIP
local time = 1 / 60
local clock = os.clock

local informationRead = {}
local function _t(str)
    return i18n("sth", str) or ""
end

local challenge_menu = stage.New("challenge", false, true)
function challenge_menu:init()
    self.top_bar = top_bar_Class(self, _t("challenge"))
    self.exit_func = function()
        task.New(self, function()
            self.locked = true
            mask_fader:Do("close")
            task.Wait(15)
            stage.Set("none", "scene_select")
        end)
    end
    self.start_func = function()
        local now = self.nowlist[self.pos]
        if now.unlock_way() == true then
            task.New(self, function()
                self.locked = true
                lstg.var.challenge_select = now.id
                mask_fader:Do("close")
                task.Wait(15)
                stage.Set("none", "attr_select2")
            end)
        else
            New(UnlockWindow, self, now.conditionList, function()
                stagedata.challenge_unlock[now.id] = true
                ReFreshDaySceneLock()
            end)
        end
    end
    self.top_bar:addReturnButton(self.exit_func)
    mask_fader:Do("open")
    self._alpha = 1
    self.alpha = 0
    self.timer = 0
    self.tri2 = 1
    self.ox = 0
    ------------------------------------------
    self.now = nil
    self.select = nil
    self.rank_color = {
        { 250, 250, 250 },
        { 189, 252, 201 },
        { 250, 128, 114 },
    }
    setmetatable(self.rank_color, { __index = function(t, k)
        return t[(k - 1) % #t + 1]
    end })
    self.rank_select = { _t("all"), _t("finished"), _t("unfinished") }
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
    self.line_h_1 = self.h * 2 / 5
    self.text_w = 265
    informationRead:init(self, 900, 75)
    self.pos = 1
    self.cache_index = {}
    self.fresh_show = function()
        self.tri1 = 0
        self._offy1 = 0
        local hc = min(self.pos, #self.nowlist - 2)
        local scrhc = math.ceil(self.h * 2 / self.line_h_1)
        self._offy1 = clamp(int(hc - scrhc / 2), 0, max(self.line_h_1 * #self.nowlist - self.h * 2 / self.line_h_1, 0)) * self.line_h_1
    end

    local loads = {}
    local path = GetDataPath()
    local searchPath = path .. "/wave_pic/"
    for _, v in ipairs(lstg.FileManager.EnumFiles(searchPath, "png")) do

        table.insert(loads, function()
            local path = v[1]
            local name = path:sub(searchPath:len() + 1, -5)
            if name:sub(1, 1) == "C" then
                LoadImageFromFile(name, path, true)
            end
        end)
    end
    if #loads <= 5 then
        for _, f in ipairs(loads) do
            f()
        end
    else
        self.jump = false
        self.loading = true
        self.start_time = clock()
        self.res = loads
        self.index = 1
        self.maxindex = #self.res
        self.textindex = math.random(1, #Text)
        self.text = Text[self.textindex]
        self.settime = self.timer
        self.load_alpha = 1
        self._alpha = 0
        task.New(self, function()
            while not self.jump do
                task.Wait()
            end
            for i = 1, 15 do
                self._alpha = i / 15
                self.load_alpha = 1 - i / 15
                task.Wait()
            end
            self.loading = false
        end)
    end
end
function challenge_menu:refreshlist()
    self.nowlist = self.nowlist
    task.New(self, function()
        for i = 1, 10 do
            self.tri2 = sin(i * 9)
            task.Wait()
        end
    end)
end
function challenge_menu:frame()
    if self.loading then
        self.timer = int((clock() - self.start_time) * 60)
        if self.timer - self.settime > 150 then
            local t = self.textindex
            while self.textindex == t do
                self.textindex = math.random(1, #Text)
            end
            self.text = Text[self.textindex]
            self.settime = self.timer
        end
        if self.index > self.maxindex then
            self.jump = true
        elseif not self.jump then
            local resFunc
            local start_time, end_time = clock(), clock()
            while end_time - start_time <= time do
                if self.index > self.maxindex then
                    break
                end
                resFunc = self.res[self.index]
                if resFunc then
                    resFunc()
                end
                self.index = self.index + 1
                end_time = clock()
            end
        end
    else
        self.timer = self.timer + 1
        self.nowlist = self.mainlist[self.rank_pos]
        if self.locked then
            return
        end

        local mouse = ext.mouse
        menu:Updatekey()
        local x1, x2, y1, y2, h
        x1, x2, y1, y2 = self.x - self.w, self.x + self.w, self.y - self.h, self.y + self.h
        h = y2 - y1
        self._offy1 = self._offy1 + (-self._offy1 + clamp(self._offy1, 0, max(self.line_h_1 * #self.nowlist - h, 0))) * 0.3
        self.offy1 = self.offy1 + (-self.offy1 + self._offy1) * 0.3
        self.ox = self.ox - self.ox * 0.08
        if menu:keyNo() then
            PlaySound("cancel00", 0.3)
            self.exit_func()
        else
            if menu:keyUp() then
                self.pos = sp:TweakValue(self.pos - 1, max(1, #self.nowlist), 1)
                self.fresh_show()
                PlaySound("select00")
            end
            if menu:keyDown() then
                self.pos = sp:TweakValue(self.pos + 1, max(1, #self.nowlist), 1)
                self.fresh_show()
                PlaySound("select00")
            end
            if menu:keyLeft() then
                self.rank_pos = sp:TweakValue(self.rank_pos - 1, #self.rank_select, 1)
                self.pos = sp:TweakValue(self.pos, max(1, #self.nowlist), 1)
                self.ox = self.ox - self.text_w
                self:refreshlist()
                PlaySound('select00', 0.3)
            end
            if menu:keyRight() then
                self.rank_pos = sp:TweakValue(self.rank_pos + 1, #self.rank_select, 1)
                self.pos = sp:TweakValue(self.pos, max(1, #self.nowlist), 1)
                self.pos = max(1, self.pos)
                self.ox = self.ox + self.text_w
                self:refreshlist()
                PlaySound('select00', 0.3)
            end
            if sp.math.PointBoundCheck(mouse.x, mouse.y, x1, x2, y1, y2) then
                if mouse._wheel ~= 0 then
                    self.pos = sp:TweakValue(self.pos - sign(mouse._wheel), max(1, #self.nowlist), 1)
                    self.fresh_show()
                    PlaySound("select00")
                end
                if mouse:isUp(1) then
                    local Y = y2
                    local _h = self.line_h_1
                    for i in ipairs(self.nowlist) do
                        if Y < y1 - self.offy1 then
                            break
                        end
                        Y = Y - _h
                        if Y < y2 - self.offy1 then
                            if sp.math.PointBoundCheck(mouse.x, mouse.y, x1, x2, Y + self.offy1, Y + _h + self.offy1) then
                                PlaySound("select00")
                                if i ~= self.pos then
                                    self.pos = i
                                    self.fresh_show()
                                else
                                    PlaySound("ok00")
                                    self.start_func()
                                end
                            end
                        end

                    end
                end
            elseif mouse.y < 540 - 46 and mouse.y > 427 then
                if mouse:isUp(1) then
                    for i = -3, 3 do
                        if i ~= 0 and abs(mouse.x - (480 + self.text_w * i + self.ox)) < self.text_w / 2 then
                            self.rank_pos = sp:TweakValue(self.rank_pos + i, #self.rank_select, 1)
                            self.ox = self.ox + self.text_w * i
                            self:refreshlist()
                            PlaySound("select00")
                        end
                    end
                end
                if mouse._wheel ~= 0 then
                    self.rank_pos = sp:TweakValue(self.rank_pos - sign(mouse._wheel), #self.rank_select, 1)
                    self.pos = sp:TweakValue(self.pos, max(1, #self.nowlist), 1)
                    self.ox = self.ox - sign(mouse._wheel) * self.text_w
                    self:refreshlist()
                    PlaySound("select00")
                end
            end
        end
        if menu:keyYes() then
            PlaySound("ok00")
            self.start_func()
        end
        informationRead:frame()
        self.top_bar:frame()
    end
end
function challenge_menu:render()

    local A = self._alpha
    ui:DrawBack(A, self.timer)
    do
        local A2 = self.load_alpha
        if A2 and A2 > 0 then
            local length = min(self.index / self.maxindex, 1)
            local Y = 270
            local x = 480
            local w = 350
            local h = 14
            local x1, x2 = x - w / 2, x + w / 2
            SetImageState("white", "", 255 * A2, 255, 255, 255)
            RenderRect("white", x1 - 1, x2 + 1, Y - h / 2 - 1, Y + h / 2 + 1)
            SetImageState("white", "", 255 * A2, 0, 0, 0)
            RenderRect("white", x1, x2, Y - h / 2, Y + h / 2)
            SetImageState("white", "",
                    Color(180 * A2, 255 - 155 * length, 255 * length, 0 + 100 * length))
            RenderRect("white", x1, x1 + length * w, Y - h / 2, Y + h / 2)
            ui:RenderText("title", ("%0.2f%%"):format(length * 100), x, Y, 0.85,
                    Color(255 * A2, 255 * length, 255 - 28 * length, 100 + 32 * length), "centerpoint")
            ui:RenderText("title", _t("loading") .. string.rep(".", int(self.timer / 20 % 6) + 1),
                    480, Y - 50, 1, Color(A2 * 255, 255, 227, 132), "centerpoint")
            ui:RenderText("small_text", "Tips : " .. self.text,
                    480, Y - 90, 1.15, Color(A2 * 255, 250, 128, 114 + 50 * sin(self.timer * 2)), "centerpoint")
        end
    end
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
    for i = -2, 2 do
        local p = i + self.rank_pos
        local str = ("%s(%d)"):format(self.rank_select[p], #self.mainlist[p])
        ui:RenderText("pretty", str, 480 + self.text_w * i + self.ox, py + 2, 0.45,
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
        for i, o in ipairs(self.nowlist) do
            if Y < y1 - self.offy1 then
                break
            end
            Y = Y - _h
            if Y < y2 - self.offy1 then
                local _index = 0.35
                local R, G, B = 150, 150, 150
                local data = stagedata
                local unlock = data.challenge_unlock[o.id]
                local finish = data.challenge_finish[o.id] > 0
                local ftime = data.challenge_time[o.id]
                if i == self.pos then
                    _index = 1
                end
                local text = _t("unlocked")
                if unlock then
                    if finish then
                        R, G, B = 189, 252, 201
                        text = _t("passCount"):format(data.challenge_finish[o.id])
                    else
                        R, G, B = 250, 128, 114
                        text = _t("unpassed")
                    end
                else
                    _index = _index * 0.7
                end
                self.cache_index[i] = self.cache_index[i] or 0
                self.cache_index[i] = self.cache_index[i] + (-self.cache_index[i] + _index) * 0.25
                local index = self.cache_index[i]
                SetImageState("white", "", index * alpha * 75, R / 2, G / 2, B / 2)
                RenderRect("white", x1, x2, Y + _h, Y)
                RenderRect("white", x1 + 1, x1 + _h - 1, Y + _h - 1, Y + 1)
                SetImageState("white", "", index * alpha * 255, 255, 255, 255)
                RenderRect("white", x1, x2, Y - 1, Y + 1)
                RenderRect("white", x1 + _h - 1, x1 + _h + 1, Y + _h, Y)
                local name = string.format("%02d. %s", o.id, o.title)
                ui:RenderText("title", name, x1 + _h + 5, Y + _h - 3,
                        1, Color(index * A * 255, R, G, B), "left", "top")
                for k, str in ipairs(sp:SplitText(o.subtitle, "\n")) do
                    ui:RenderTextWithCommand("title", str, x1 + _h + 32, Y + _h - 26 - (k - 1) * 15,
                            0.65, index * A * 180, "left", "top")
                end

                SetImageState("menu_circle", "", A * (80 + index * 120), 255, 255, 255)
                Render("menu_circle", x2 - _h / 2, Y + _h / 2, 0, 28 / 192)
                ui:RenderText("pretty", text, x2 - _h / 2, Y + _h / 2, 0.37,
                        Color(A * (80 + index * 120), R, G, B), "centerpoint")
                if unlock then
                    local pic = ("Challenge%d"):format(o.id)
                    local pic_cut = pic .. "cut"
                    if CheckRes("img", pic) then
                        local w, h = GetTextureSize(pic)
                        if not CheckRes("img", pic_cut) then
                            LoadImage(pic_cut, pic, w / 2 - h / 2, h / 2 - h / 2, h, h)
                        end
                        SetImageState(pic_cut, "", A * (130 + index * 120), 150, 150, 150)
                        Render(pic_cut, x1 + _h / 2, Y + _h / 2, 0, _h / (h))
                    else
                        ui:RenderText("pretty_title", _t("noPic"), x1 + _h / 2, Y + _h / 2,
                                0.64, Color(A * (130 + index * 120) * 255, R, G, B), "centerpoint")
                    end
                end
                if ftime then
                    local str = os.date("!%Y/%m/%d\n%H:%M:%S", ftime + setting.timezone * 3600)
                    ui:RenderText("title", ("%s"):format(str), x1 + _h / 2, Y + _h - 35,
                            0.8, Color(index * A * 255, R, G, B), "centerpoint")
                end
            end

        end

        SetViewMode("ui")
    end
    informationRead:render(A)
    self.top_bar:render()
end
function challenge_menu:Refresh()
    local sp = sp
    self.mainlist = { {}, {}, {} }
    self.nowlist = {}
    for _, unit in ipairs(sp:CopyTable(challenge_lib.class)) do

        table.insert(self.mainlist[1], unit)
        if stagedata.challenge_finish[unit.id] > 0 then
            table.insert(self.mainlist[2], unit)
        else
            table.insert(self.mainlist[3], unit)
        end
    end
    for _, m in ipairs(self.mainlist) do
        table.sort(m, function(a, b)
            return a.id < b.id
        end)
    end
    setmetatable(self.mainlist, { __index = function(t, k)
        return t[(k - 1) % #t + 1]
    end })
    self.rank_pos = sp:TweakValue(self.rank_pos, #self.rank_select, 1)
    self.nowlist = self.mainlist[self.rank_pos]
end

function informationRead:init(mainmenu, x, y)
    self.x, self.y = x, y
    self.func = function()
        New(SimpleNotice, self.mainmenu, _t("aboutChallenge"), _t("challengeInformation"), 200, 100)
    end
    self.index = 0
    self.timer = 0
    self.r = 20
    self.selected = false
    self.locked = false
    self.mainmenu = mainmenu
end
function informationRead:frame()
    task.Do(self)
    self.timer = self.timer + 1
    if self.locked then
        return
    end
    local mouse = ext.mouse
    if Dist(self.x, self.y, mouse.x, mouse.y) < self.r then
        self.index = self.index + (-self.index + 1) * 0.1
        if not self.selected then
            self.selected = true
            PlaySound("select00")
        end
    else
        self.index = self.index - self.index * 0.1
        self.selected = false
    end
    if self.selected then
        if mouse:isUp(1) then
            self.index = self.index + 0.5
            PlaySound("ok00")
            self.func()
        end
    end
end
function informationRead:render(A)
    local k = self.index
    local _alpha = (150 + k * 50) * A
    local ax, ay = self.x, self.y
    local adsize = self.r + k * 10
    SetImageState("menu_questionicon", "", _alpha, 200, 200, 200)
    Render("menu_questionicon", ax, ay, 0, adsize / 64)
end