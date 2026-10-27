local function _t(str)
    return i18n("ext", str) or ""
end

LoadImageFromFile("level_up_img", "assets\\ext\\level-up.png")

local CheckAddition = sp:EasyCopyTable(ext.CheckAddition)
local CheckAddition_Submenu = sp:EasyCopyTable(ext.CheckAddition_Submenu)

local CheckActive = sp:EasyCopyTable(ext.CheckActive)
local CheckActive_Submenu = sp:EasyCopyTable(ext.CheckActive_Submenu)

local levelmenu = {  }
local Detail_Submenu = {}

function levelmenu:init()
    self.kill = true
    self.circles = {}
    self.particle = {}
    self._r, self._g, self._b = 255, 227, 132
    self.levelupimg = { alpha = 1, scale = 0, x = 480, y = 270, rainbow = 0 }
    self.alpha = 0
    self.pos = 1
    self.timer = 0
    self.list = {}
    self.bR, self.bG, self.bB = 0, 0, 0
    self.maxqual = 0
    self.arrow_y = 270
    self.index = { 0, 0, 0, 0, 0 }
    self.w = 500
    self.h = 75
end
function levelmenu:frame()
    if self.kill then
        return
    end
    task.Do(self)
    self.timer = self.timer + 1
    local c
    for i = #self.circles, 1, -1 do
        c = self.circles[i]
        c.r = c.maxr * task.SetMode[2](c.timer / c.lifetime)
        c.alpha = 170 * task.SetMode[2](2 * c.timer / c.lifetime)
        c.timer = c.timer + 1
        if c.timer >= c.lifetime then
            table.remove(self.circles, i)
        end
    end
    local p
    local maxtime = 30
    for i = #self.particle, 1, -1 do
        p = self.particle[i]
        p.x = p.x + p.vx
        p.y = p.y + p.vy
        p.vx = p.vx - p.vx * 0.04
        p.vy = p.vy - p.vy * 0.04
        if p.timer > maxtime then
            p.alpha = max(p.alpha - 5, 0)
            if p.alpha == 0 then
                table.remove(self.particle, i)
            end
        end
        p.timer = p.timer + 1
    end
    if self.CheckAddition_open then
        CheckAddition_Submenu:frame()
        return
    end
    if self.CheckActive_open then
        CheckActive_Submenu:frame()
        return
    end
    CheckActive:frame()
    CheckAddition:frame()
    Detail_Submenu:frame()

    if self.lock then
        return
    end
    menu:Updatekey()
    local mouse = ext.mouse
    if menu:keyYes() then
        self.start_button.func()
        return
    end
    self.start_button:frame()

    if menu:keyUp() then
        self.pos = sp:TweakValue(self.pos - 1, #self.list, 1)
        PlaySound("select00")
    end
    if menu:keyDown() then
        self.pos = sp:TweakValue(self.pos + 1, #self.list, 1)
        PlaySound("select00")
    end
    if mouse._wheel ~= 0 then
        self.pos = sp:TweakValue(self.pos - sign(mouse._wheel), #self.list, 1)
        PlaySound("select00")
    end
    if mouse:isUp(1) then
        local x, y = 480, 270
        local _c = #self.list
        local _h = self.h
        local w = self.w
        local h = _c * _h
        for i = 1, _c do
            local _y = y + h / 2 - h * (i - 1) / _c
            if sp.math.PointBoundCheck(mouse.x, mouse.y, x - w / 2, x + w / 2, _y - _h, _y) then
                self.pos = i
                PlaySound("select00")
                if mouse.x < x - w / 2 + _h then
                    local k = self.list[self.pos]
                    if k.isTool or k.isActive then
                        Detail_Submenu:In(k)
                        self.lock = true
                        CheckAddition.locked = true
                        CheckActive.locked = true
                    end
                end
            end

        end
    end
    if menu.key == KEY.TAB then
        local k = self.list[self.pos]
        if k.isTool or k.isActive then
            Detail_Submenu:In(k)
            PlaySound("select00")
            self.lock = true
            CheckAddition.locked = true
            CheckActive.locked = true
        end
    end
end
function levelmenu:render()

    if self.kill then
        return "killed"
    end

    SetViewMode 'ui'
    local A = self.alpha
    SetImageState('white', '', A * 150, 0, 0, 0)
    RenderRect('white', 0, screen.width, 0, screen.height)
    local x, y = 480, 270
    local _c = #self.list
    local _h = self.h
    local w = self.w
    local h = _c * _h
    do
        ui:RenderText("title", _t("clickTABtoDetail"), x + w / 2 + 120 - 120 * A, y + h / 2,
                0.8, Color(A * (75 + 75 * sin(self.timer * 2)), 200, 200, 200), "right", "bottom")
        ---@param p addition_unit
        for i, p in ipairs(self.list) do
            self.index[i] = self.index[i] or 0
            local _index = (i == self.pos) and 1 or 0
            self.index[i] = self.index[i] + (-self.index[i] + _index) * 0.18
            local index = 0.4 + 0.6 * self.index[i]
            local index2 = self.index[i]
            local _w = w * (0.95 + 0.05 * index2)
            local _h2 = _h * (0.95 + 0.05 * index2)
            local _x2 = x + (i % 2 * 2 - 1) * (50 - 50 * A)
            local _x, _y = _x2 - _w / 2 + _h2, y + h / 2 - h * (i - 0.5) / _c
            SetImageState("white", "", A * 75, 0, 0, 0)
            RenderRect("white", _x2 - _w / 2, _x2 + _w / 2, _y - _h2 * 0.5, _y + _h2 * 0.5)
            SetImageState("white", "", A * 255, 255, 255, 255)
            misc.RenderOutLine("white", _x2 - _w / 2, _x2 + _w / 2, _y - _h2 * 0.5, _y + _h2 * 0.5, 0, 2)
            RenderRect("white", _x - 1, _x + 1, _y - _h2 * 0.5, _y + _h2 * 0.5)
            SetImageState("white", "", A * 75 * index, p.R, p.G, p.B)
            RenderRect("white", _x2 - _w / 2 + 6, _x2 - _w / 2 + _h2 - 6, _y + _h2 / 2 - 6, _y - _h2 / 2 + 6)
            RenderRect("white", _x + 3, _x2 + _w / 2 - 3, _y - _h2 * 0.5 + 3, _y + _h2 * 0.5 - 3)
            SetImageState(p.pic, "", A * 200 * index, 255, 255, 255)
            Render(p.pic, _x2 - _w / 2 + _h2 / 2, _y, 0, (_h2 - 12 - 6) / 256)
            -- RenderRect(p.pic, x - w / 2 + 6, x - w / 2 + _h - 6, _y - _h / 2 + 6, _y + _h / 2 - 6)
            SetImageState("white", "", A * 255 * index, 200, 200, 200)
            misc.RenderOutLine("white", _x2 - _w / 2 + 6, _x2 - _w / 2 + _h2 - 6,
                    _y + _h2 / 2 - 6, _y - _h2 / 2 + 6, 0, 2)
            if p.quality and p.quality >= 3 then
                misc.RenderBrightOutline(_x2 - _w / 2, _x2 + _w / 2, _y - _h2 * 0.5, _y + _h2 * 0.5,
                        15, A * (sin(self.timer * 4 + i * 120) * 30 + 60), p.R, p.G, p.B)
            end

            local offs = _h / 75
            local maxk = 2
            local titleoffy = 3
            local desoffy = 12
            if #self.list >= 12 then
                maxk = 0
                titleoffy = 6
                offs = offs * 1.6
            elseif #self.list >= 9 then
                maxk = 1
                titleoffy = 3
                desoffy = 15.5
                offs = offs * 1.2
            end
            if not p.isActive then
                local count = ""
                if p.id then
                    local c = lstg.var.addition[p.id] or 0
                    if p.maxcount then
                        count = ("(%d/%d)"):format(c, p.maxcount)
                    else
                        count = ("(%d)"):format(c)
                    end
                end
                ui:RenderText("pretty", count, _x2 + _w / 2 - 6, _y + _h2 / 2 - 5* min(offs * 1.6, 1),
                        0.42 * min(offs * 1.6, 1), Color(A * 255 * index, p.R, p.G, p.B), "right", "top")
            end
            ui:RenderText("big_text", p.title4 or p.title, _x, _y + _h2 / 2 - titleoffy * offs,
                    0.45 * min(offs * 1.2, 1), Color(A * 255 * index, p.R, p.G, p.B), "left", "top")
            for k, text in ipairs(sp:SplitText(p.describe, "\n")) do
                if k > maxk then
                    break
                end
                ui:RenderTextWithCommand("title", text, _x + 6, _y + _h2 / 2 - desoffy * offs - k * offs * 18,
                        offs * 0.8, index * A * 200, "left")
            end
            --ui:RenderTextInWidth("title", p.describe, _x + 6, _y - _h / 2 + 42, 0.8, w * 0.81, Color(A * 255 * index, p.R, p.G, p.B), "left", "top")
            if p.id and not p:ShowNew() then
                SetImageState("menu_newicon", "", A * 200 * index, 200, 200, 200)
                Render("menu_newicon", _x2 - _w / 2 + 17, _y + _h2 / 2 - 17, 0, 0.26 * offs)
            end

            if i == self.pos then
                self.arrow_y = self.arrow_y + (-self.arrow_y + _y) * 0.15
                ui:RenderText("pretty", ">", x - w / 2 - 50 + sin(self.timer * 3) * 3, self.arrow_y,
                        1, Color(A * 255 * index, 255, 255, 255), "left", "vcenter")
                ui:RenderText("pretty", "<", x + w / 2 + 50 - sin(self.timer * 3) * 3, self.arrow_y,
                        1, Color(A * 255 * index, 255, 255, 255), "right", "vcenter")
            end
        end
        ui:RenderText("big_text", _t("selectAddition"), x, y + h / 2 + 50 + 200 - 200 * A,
                0.6, Color(A * 255, 200, 200, 200), "centerpoint")
    end--加成显示
    self.start_button:render(A)
    ------------------------------------------------
    do
        local lui = self.levelupimg
        if self.maxqual == 4 then
            for i = 1, 60 do
                local offi = lui.rainbow * 60
                local n = 30 + int(offi + i) * 3
                local r1, r2 = (i - 1 + offi) * 5, (i + offi) * 5
                local _x, _y = 480, 270
                for m = 1, n do
                    local ang = 360 / n
                    local angle = 360 / n * m + 210
                    local alpha = A * lui.alpha * 120 * sin(i * 3) * sin(abs(sin(m / n * 360) * 90))
                    SetImageState("white", "mul+add", alpha, sp:HSVtoRGB(i * 6, 0.5, 1))
                    Render4V('white',
                            _x + r2 * cos(angle - ang), _y + r2 * sin(angle - ang), 0.5,
                            _x + r1 * cos(angle - ang), _y + r1 * sin(angle - ang), 0.5,
                            _x + r1 * cos(angle), _y + r1 * sin(angle), 0.5,
                            _x + r2 * cos(angle), _y + r2 * sin(angle), 0.5)
                end
            end
        end
        if self.lvlup then

            SetImageState("level_up_img", "mul+add", A * 255 * lui.alpha, 255, 255, 255)
            Render("level_up_img", lui.x, lui.y, 0, lui.scale * 0.5)


        end
        for _, c in ipairs(self.circles) do
            SetImageState("white", "mul+add", A * c.alpha, 255, 227, 132)
            misc.SectorRender(c.x, c.y, c.r - 2, c.r, 0, 360, 60)
        end
        for _, pa in ipairs(self.particle) do
            SetImageState("bright", "mul+add", pa.alpha, 255, 227, 132)
            Render("bright", pa.x, pa.y, 0, 8 / 150)
        end
        misc.RenderBrightOutline(0, 960, 0, 540, 50,
                A * (sin(self.timer * 3) * 30 + 60), self.bR, self.bG, self.bB)
    end--特效
    CheckAddition:render(A)
    CheckActive:render(A)
    CheckAddition_Submenu:render()
    CheckActive_Submenu:render()
    Detail_Submenu:render()
end
function levelmenu:FlyIn(list, otherevent, nolvlup, sound)
    self.english = setting.language == 2
    self.w = self.english and 590 or 500
    self.h = 75
    Detail_Submenu:init(self)
    self.CheckAddition_open = nil
    self._nextlock = false
    self.kill = false
    self.alpha = 0
    self.list = list
    self.h = min(75, 375 / #self.list)
    self.pos = clamp(self.pos, 1, #self.list)
    self.otherevent = otherevent
    self.bR, self.bG, self.bB = 0, 0, 0
    self.maxqual = 0
    self.lvlup = not nolvlup
    local maxqual = 0
    for _, p in ipairs(self.list) do
        if p.quality then
            if p.quality > maxqual then
                maxqual = p.quality
                if maxqual >= 3 then
                    self.maxqual = maxqual
                    self.bR, self.bG, self.bB = p.R, p.G, p.B
                end
            end
        end
        if p.id then
            p:OpenHandbook()
        end
    end
    do
        local x, y = 480, 270
        local c = #self.list
        local _h = self.h
        local h = c * _h
        self.start_button = {
            x = x, y = y - h / 2 - 50, index = 0,
            w = 230, h = 48,
            scale = 0.3,
            selected = false,
            text = "OK!!",
            func = function()
                PlaySound("bonus")
                self:FlyOut(function()
                    self.list[self.pos]:Set()
                    if self.otherevent then
                        self:otherevent()
                    end
                end)
            end,
            frame = attributeselectmenu.general_buttonFrame,
            render = attributeselectmenu.general_buttonRender
        }
    end

    local lui = self.levelupimg
    lui.scale = 0
    lui.alpha = 1
    lui.rainbow = 0
    lui.x = 480
    lui.y = 270
    task.New(self, function()
        local bg = background

        for _ = 1, 12 do
            local x, y = 480 + bg:RanFloat(-120, 120), 270 + bg:RanFloat(-120, 120)
            table.insert(self.circles, {
                x = x, y = y,
                lifetime = bg:RanInt(25, 45), maxr = bg:RanFloat(100, 120),
                alpha = 170, r = 0, timer = 0,
            })
            for _ = 1, 10 do
                local a = bg:RanFloat(0, 360)
                local v = bg:RanFloat(3, 6)
                table.insert(self.particle, {
                    x = x, y = y,
                    vx = cos(a) * v, vy = sin(a) * v,
                    alpha = bg:RanFloat(150, 250), timer = 0,
                })
            end
        end
    end)
    CheckAddition:init(self, CheckAddition_Submenu, 880, 270)
    CheckAddition_Submenu:init(self)
    CheckActive:init(self, CheckActive_Submenu, 80, 90)
    CheckActive_Submenu:init(self)

    task.New(self, function()

        task.New(self, function()
            for i = 1, 50 do
                lui.rainbow = task.SetMode[2](i / 50)
                task.Wait()
            end
        end)
        for i = 1, 18 do
            i = task.SetMode[2](i / 18)
            lui.scale = i
            -- lui.y = 270 + 45 * i
            self.alpha = i
            task.Wait()
        end
        task.New(self, function()
            task.Wait(30)
            for i = 1, 30 do
                lui.alpha = 1 - i / 30
                task.Wait()
            end
        end)
        while GetKeyState(KEY.Z) do
            task.Wait()
        end
        task.Wait(15)
        self.lock = self._nextlock
    end)
    for _, v in ipairs(EnumRes("snd")) do
        if GetSoundState(v) == "playing" then
            PauseSound(v)
        end
    end
    if sound then
        PlaySound("extend")
    end
end
function levelmenu:FlyOut(event)

    self.lock = true
    task.New(self, function()
        for i = 1, 12 do
            self.alpha = 1 - i / 12
            task.Wait()
        end
        self.kill = true
        for _, v in ipairs(EnumRes("snd")) do
            if GetSoundState(v) == "paused" then
                ResumeSound(v)
            end
        end
        task.Clear(self, true)
        if event then
            event()
        end


    end)
end
function levelmenu:IsKilled()
    return self.kill
end

function Detail_Submenu:init(mainmenu)
    self.x, self.y = 480, 270
    self.w, self.h = 420, 445
    self.alpha = 0
    self.locked = true
    self.timer = 0
    self.exit_button = ExitButton(750, 480, function()
        self:Out()
        PlaySound("cancel00")
    end)
    self.mainmenu = mainmenu
    self.offy1 = 0
    self._offy1 = 0
    self.line_h_1 = 18
    self.linecount1 = 1
end
function Detail_Submenu:In(tool)
    self.english = setting.language == 2
    self.w = self.english and 480 or 420
    PlaySound("select00")
    self.locked = false
    self.tool = tool
    self._offy1 = 0
    task.New(self, function()
        for i = 1, 16 do
            self.alpha = task.SetMode[2](i / 16)
            task.Wait()
        end
    end)

end
function Detail_Submenu:Out()
    task.New(self, function()
        self.locked = true
        self.mainmenu.lock = false
        CheckAddition.locked = false
        for i = 1, 16 do
            self.alpha = 1 - i / 16
            task.Wait()
        end
    end)
end
function Detail_Submenu:frame()
    self.timer = self.timer + 1
    task.Do(self)
    if self.locked then
        return
    end
    menu:Updatekey()
    local mouse = ext.mouse
    self.exit_button:frame()
    if menu:keyYes() or menu:keyNo() or menu.key == KEY.TAB or mouse:isUp(1) then
        self.exit_button.func()
    end
    self._offy1 = self._offy1 + (-self._offy1 + clamp(self._offy1, 0, self.line_h_1 * max(0, self.linecount1 - 14.5))) * 0.3
    self.offy1 = self.offy1 + (-self.offy1 + self._offy1) * 0.3
    if menu:keyUp() then
        self._offy1 = self._offy1 - self.line_h_1
        PlaySound("select00")
    end
    if menu:keyDown() then
        self._offy1 = self._offy1 + self.line_h_1
        PlaySound("select00")
    end
    if mouse._wheel ~= 0 then
        self._offy1 = self._offy1 - mouse._wheel / 120 * self.line_h_1
        PlaySound("select00")
    end
end
function Detail_Submenu:render()
    local A = self.alpha
    if A == 0 then
        return
    end
    do
        SetImageState("white", "", A * 180, 0, 0, 0)
        RenderRect("white", 0, 960, 0, 540)
        local x, y = self.x, self.y
        local x1, x2, y1, y2
        local w = self.w
        local h = self.h
        local T = 0.7 + 0.3 * A
        x1, x2, y1, y2 = x - w / 2 * T, x + w / 2 * T, y - h / 2 * T, y + h / 2 * T
        if self.tool.isTool then
            self.linecount1 = menu:RenderToolDescribe(self.tool, x1, x2, y1, y2,
                    80 * T, self.offy1, self.line_h_1, A, A, self.timer, true)
        elseif self.tool.isActive then
            self.linecount1 = menu:RenderActiveDescribe(self.tool, x1, x2, y1, y2,
                    80 * T, self.offy1, self.line_h_1, A, A, self.timer, true)
        end
    end
    self.exit_button:render(A)
end

---@class ext.levelmenu @升级菜单对象
ext.level_menu = levelmenu
ext.level_menu:init()
if ext.PriorMenu then
    ext.PriorMenu[3] = levelmenu
end