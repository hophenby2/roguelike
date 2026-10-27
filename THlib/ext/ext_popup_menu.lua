local function _t(str)
    return i18n("ext", str) or ""
end

local popup_menu = {}
function popup_menu:init()
    self.list = {}
    self.timer = 0
    self.events = {}
    self.kill = true
    self.alpha = 0
    self.timer = 0
    self.offx = 0
    self._offx = 0
    self.interval = 240
end
function popup_menu:frame()
    if self.kill then
        return
    end
    task.Do(self)
    self.timer = self.timer + 1
    local maxc = 0
    local main = self.events[1]
    if main then
        maxc = #main.tool_shows
        if maxc <= 4 then
            maxc = 0
        end
    end
    self._offx = self._offx + (-self._offx + clamp(self._offx, 0, max(0, maxc / 2 - 1.5) * self.interval)) * 0.3
    self.offx = self.offx + (-self.offx + self._offx) * 0.3

    if self.lock then
        return
    end
    menu:Updatekey()

    local mouse = ext.mouse
    if mouse._wheel ~= 0 then
        self._offx = self._offx + mouse._wheel
        PlaySound("select00")
    end
    if menu:keyLeft() then
        self._offx = self._offx + self.interval * 0.7
        PlaySound("select00")
    end
    if menu:keyRight() then
        self._offx = self._offx - self.interval * 0.7
        PlaySound("select00")
    end
    if menu:keyYes() or mouse:isUp(1) then
        self:FlyOut()
        return
    end
end
function popup_menu:render()
    SetViewMode("ui")
    local A = self.alpha
    SetImageState('white', '', A * 120, 0, 0, 0)
    RenderRect('white', 0, screen.width, 0, screen.height)

    local main = self.events[1]
    if main then
        local breath = sin(self.timer * 3)
        misc.RenderBrightOutline(0, 960, 0, 540, 42,
                A * (breath * 25 + 50), main.r, main.g, main.b)
        local x, y = 380 + 100 * A + self.offx, 270

        ui:RenderText("pretty", ReplaceTextWithCommand(main.title):gsub("§.", ""), 480, 450,
                0.7, Color(A * 255, main.r, main.g, main.b), "centerpoint")
        local size = 115
        local c = #main.tool_shows
        local k = (c - 1) / 2
        if c >= 5 then
            x = x - (c / 2 - 1.5) * self.interval
        end
        for i, p in ipairs(main.tool_shows) do
            local _x = x + self.offx + (i - 1 - k) * self.interval
            SetImageState("menu_circle", "", A * 200, 200, 200, 200)
            Render("menu_circle", _x, y, 0, size / 192)
            local img = "addition_state" .. p.state
            SetImageState(img, "", A * 200, 200, 200, 200)
            Render(img, _x, y, 0, size / 200)
            ui:RenderTextInWidth("big_text", p.title2, _x, y - size * 1.1, 0.55,
                    size * 1.8, Color(A * 200, p.R, p.G, p.B), "centerpoint")
            SetImageState("bright", "mul+add", A * 200, p.R, p.G, p.B)
            Render("bright", _x, y, 0, 2)
        end
        ui:RenderText("title", _t("clickConfirm"), 480, y - size * 1.6,
                0.8, Color(A * (-breath * 50 + 150), 150, 150, 150), "centerpoint")
    end

    SetViewMode("world")
end
function popup_menu:FlyIn(title, r, g, b, tool_shows, sound)
    if self.kill then
        self.kill = false
        self._nextlock = false
        self._offx = 0
        if sound then
            PlaySound(sound)
        end
        task.New(self, function()
            for i = 1, 10 do
                i = task.SetMode[2](i / 10)
                -- lui.y = 270 + 45 * i
                self.alpha = i
                task.Wait()
            end
        end)
        task.New(self, function()
            while GetKeyState(KEY.Z) do
                task.Wait()
            end
            task.Wait(8)
            self.lock = self._nextlock
        end)
    end
    if title then
        table.insert(self.events, 1, {
            title = title,
            r = r, g = g, b = b,
            tool_shows = tool_shows,
            sound = sound
        })
    end

end
function popup_menu:FlyOut()

    self.lock = true
    task.Clear(self)
    task.New(self, function()
        for i = 1, 6 do
            self.alpha = 1 - i / 6
            task.Wait()
        end
        table.remove(self.events, 1)
        self.kill = true
        if #self.events > 0 then
            if self.events[1].sound then
                PlaySound(self.events[1].sound)
            end
            self:FlyIn()
            self.lock = false
        else
            task.Clear(self, true)
        end
    end)
end
function popup_menu:IsKilled()
    return self.kill
end
function popup_menu:FlyInOneTool(title, r, g, b, id, sound)
    popup_menu:FlyIn(title, r, g, b, { stg_levelUPlib.AdditionTotalList[id] }, sound)
end

ext.popup_menu = popup_menu
ext.popup_menu:init()