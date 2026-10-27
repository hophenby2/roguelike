local function _t(str)
    return i18n("sth", str) or ""
end

local SimpleNotice = Class(object)
_G.SimpleNotice = SimpleNotice
function SimpleNotice:init(cur_menu, title, text, w, h)
    self.bound = false
    self.colli = false
    object.init(self, screen.width / 2, screen.height * 1.5, GROUP.GHOST, LAYER.TOP)
    self.cur_menu = cur_menu
    self.title = title
    self.text = text
    self.lock = true
    self.width = w or 350
    self.height = h or 160
    self.pheight = 50
    self.select_col = 0
    self.max_select_col = 0
    self.y = 270
    self.alpha = 0
    task.New(self, function()
        task.SmoothSetValueTo("alpha", 1, 9, 2)
        self.lock = false
    end)
    self.ty = 0
    self._ty = 0
    self.texts = sp:SplitText(text, "\n")
    self.lines = #self.texts
end
function SimpleNotice:frame()
    task.Do(self)
    if not self.dk then
        if self.cur_menu then
            self.cur_menu.locked = true
        end
        if not self.lock then
            local line_h = 32 * 0.8 * 0.67
            local x = self.x
            local y = self.y
            local w = self.width
            local h = self.height
            local ph = self.pheight
            self._ty = self._ty + (-self._ty + clamp(self._ty, 0, max(line_h * self.lines - h * 2, 0))) * 0.3
            self.ty = self.ty + (-self.ty + self._ty) * 0.3
            self.select_col = self.select_col + (-self.select_col + self.max_select_col) * 0.2
            menu:Updatekey()
            if menu:keyYes() or menu:keyNo() then
                Del(self)
                PlaySound("ok00")
            end
            if menu:keyDown() then
                self._ty = self._ty + line_h * 4
                PlaySound("select00")
            end
            if menu:keyUp() then
                self._ty = self._ty - line_h * 4
                PlaySound("select00")
            end
            local mouse = ext.mouse
            if sp.math.PointBoundCheck(mouse.x, mouse.y, x - w, x + w, y - h, y - h - ph) then
                self.max_select_col = 100
                if mouse:isUp(1) then
                    Del(self)
                    PlaySound("ok00")
                end
            else
                self.max_select_col = 0
            end
            if mouse._wheel ~= 0 then
                self._ty = self._ty - sign(mouse._wheel) * line_h * 4
                PlaySound("select00")
            end
        end
    end

end
function SimpleNotice:render()
    SetViewMode("ui")
    local scrh = screen.height
    local line_h = 32 * 0.8 * 0.67
    local x = self.x
    local y = self.y
    local alpha = self.alpha
    local w = self.width * (0.6 + 0.4 * alpha)
    local h = self.height * (0.6 + 0.4 * alpha)
    local ph = self.pheight

    local pulse = self.select_col
    SetImageState("white", "", alpha * 150, 0, 0, 0)
    RenderRect("white", 0, screen.width, 0, scrh)
    SetImageState("white", "", alpha * 150, 70, 40, 40)
    RenderRect("white", x - w, x + w, y + h, y + h + ph)
    SetImageState("white", "", alpha * 150, 20, 20, 20)
    RenderRect("white", x - w, x + w, y + h, y - h)
    SetImageState("white", "", alpha * 150, 20 + pulse, 30 + pulse * 2, 30 + pulse)
    RenderRect("white", x - w, x + w, y - h, y - h - ph)
    SetImageState("white", "", alpha * 255, 255, 255, 255)
    misc.RenderOutLine("white", x - w, x + w, y - h - ph, y + h + ph, 0, 2)
    RenderRect("white", x - w, x + w, y - h, y - h - 2)
    RenderRect("white", x - w, x + w, y + h, y + h + 2)
    ui:RenderText("big_text", self.title, x, y + h + ph / 2,
            0.7, Color(alpha * 255, 255, 255, 255), "centerpoint")
    ui:RenderText("big_text", _t("yes"), x, y - h - ph / 2,
            0.5 + pulse / 100 * 0.3, Color(alpha * 255, 255, 255, 255), "centerpoint")
    local ty = clamp(y + h, 0, scrh)
    local by = clamp(y - h, 0, scrh)
    if (-w) ~= w and (by - y) ~= (ty - y) and (x - w) ~= (x + w) and by ~= ty then
        SetRenderRect(-w, w, by - y, ty - y, x - w, x + w, by, ty)
        local Y = self.ty + h
        for _, str in ipairs(self.texts) do
            if Y > -h - line_h and Y < h + line_h then
                ui:RenderTextWithCommand("title", str, -w + 10, Y, 0.8, alpha * 200, "left", "top")
            end
            Y = Y - line_h
        end
    end
    SetViewMode("ui")


end
function SimpleNotice:del()
    if self.cur_menu then
        self.cur_menu.locked = false
    end
    object.Preserve(self)
    self.dk = true
    task.New(self, function()
        task.SmoothSetValueTo("alpha", 0, 9, 1)
        object.RawDel(self)
    end)
end

local SimpleChoose = Class(object)
_G.SimpleChoose = SimpleChoose
function SimpleChoose:init(cur_menu, yes, no, title, text, w, h)
    self.bound = false
    self.colli = false
    object.init(self, screen.width / 2, screen.height * 1.5, GROUP.GHOST, LAYER.TOP)
    self.cur_menu = cur_menu
    self.title = title
    self.text = text
    self.lock = true
    self.width = w or 350
    self.height = h or 160
    self.pheight = 50
    self.pos = 1
    self.yes_func = yes
    self.no_func = no
    self.y = 270
    self.alpha = 0
    task.New(self, function()
        task.SmoothSetValueTo("alpha", 1, 9, 2)
        self.lock = false
    end)
    self.ty = 0
    self._ty = 0
    self.texts = sp:SplitText(text, "\n")
    self.lines = #self.texts
end
function SimpleChoose:frame()
    task.Do(self)
    if not self.dk then
        if self.cur_menu then
            self.cur_menu.locked = true
            self.cur_menu.lock = true
        end
        if not self.lock then
            local line_h = 32 * 0.8 * 0.67
            local x = self.x
            local y = self.y
            local w = self.width
            local h = self.height
            local ph = self.pheight
            self._ty = self._ty + (-self._ty + clamp(self._ty, 0, max(line_h * self.lines - h * 2, 0))) * 0.3
            self.ty = self.ty + (-self.ty + self._ty) * 0.3
            menu:Updatekey()
            if menu:keyYes() then
                if self.pos == 1 then
                    Del(self)
                    self.yes_func()
                    PlaySound("ok00")
                else
                    Del(self)
                    self.no_func()
                    PlaySound("cancel00")
                end
            end
            if menu:keyNo() then
                Del(self)
                self.no_func()

                PlaySound("cancel00")
            end
            if menu:keyDown() then
                self._ty = self._ty + line_h * 4
                PlaySound("select00")
            end
            if menu:keyUp() then
                self._ty = self._ty - line_h * 4
                PlaySound("select00")
            end
            if menu:keyLeft() or menu:keyRight() then
                self.pos = self.pos % 2 + 1
                PlaySound("select00")
            end
            local mouse = ext.mouse
            if sp.math.PointBoundCheck(mouse.x, mouse.y, x - w, x, y - h, y - h - ph) then
                if mouse:isUp(1) then
                    Del(self)
                    self.pos = 1
                    self.yes_func()

                    PlaySound("ok00")
                end
            end
            if sp.math.PointBoundCheck(mouse.x, mouse.y, x + w, x, y - h, y - h - ph) then
                if mouse:isUp(1) then
                    Del(self)
                    self.pos = 2
                    self.no_func()

                    PlaySound("cancel00")
                end
            end
            if mouse._wheel ~= 0 then
                self._ty = self._ty - sign(mouse._wheel) * line_h * 4
                PlaySound("select00")
            end
        end
    end

end
function SimpleChoose:render()
    SetViewMode("ui")
    local scrh = screen.height
    local line_h = 32 * 0.8 * 0.67
    local x = self.x
    local y = self.y
    local alpha = self.alpha
    local w = self.width * (0.6 + 0.4 * alpha)
    local h = self.height * (0.6 + 0.4 * alpha)
    local ph = self.pheight

    SetImageState("white", "", alpha * 150, 0, 0, 0)
    RenderRect("white", 0, screen.width, 0, scrh)
    SetImageState("white", "", alpha * 150, 70, 40, 40)
    RenderRect("white", x - w, x + w, y + h, y + h + ph)
    SetImageState("white", "", alpha * 150, 20, 20, 20)
    RenderRect("white", x - w, x + w, y + h, y - h)
    SetImageState("white", "", alpha * 150, 20, (self.pos == 1) and 150 or 30, 30)
    RenderRect("white", x - w, x, y - h, y - h - ph)
    SetImageState("white", "", alpha * 150, 20, (self.pos == 2) and 150 or 30, 30)
    RenderRect("white", x + w, x, y - h, y - h - ph)

    SetImageState("white", "", alpha * 255, 255, 255, 255)
    RenderRect("white", x - 1, x + 1, y - h, y - h - ph)
    misc.RenderOutLine("white", x - w, x + w, y - h - ph, y + h + ph, 0, 2)
    RenderRect("white", x - w, x + w, y - h, y - h - 2)
    RenderRect("white", x - w, x + w, y + h, y + h + 2)
    ui:RenderText("big_text", self.title, x, y + h + ph / 2,
            0.7, Color(alpha * 255, 255, 255, 255), "centerpoint")
    ui:RenderText("big_text", _t("yes"), x - w / 2, y - h - ph / 2,
            0.7, Color(alpha * 255, 255, 255, 255), "centerpoint")
    ui:RenderText("big_text", _t("no"), x + w / 2, y - h - ph / 2,
            0.7, Color(alpha * 255, 255, 255, 255), "centerpoint")
    local ty = clamp(y + h, 0, scrh)
    local by = clamp(y - h, 0, scrh)
    if (-w) ~= w and (by - y) ~= (ty - y) and (x - w) ~= (x + w) and by ~= ty then
        SetRenderRect(-w, w, by - y, ty - y, x - w, x + w, by, ty)
        local Y = self.ty + h
        for _, str in ipairs(self.texts) do
            if Y > -h - line_h and Y < h + line_h then
                ui:RenderTextWithCommand("title", str, -w + 10, Y, 0.8, alpha * 200, "left", "top")
            end
            Y = Y - line_h
        end
    end
    SetViewMode("ui")
end
function SimpleChoose:del()
    if self.cur_menu then
        self.cur_menu.locked = false
        self.cur_menu.lock = false
    end
    object.Preserve(self)
    self.dk = true
    task.New(self, function()
        task.SmoothSetValueTo("alpha", 0, 9, 1)
        object.RawDel(self)
    end)
end

local UnlockWindow = Class(object)
_G.UnlockWindow = UnlockWindow
function UnlockWindow:init(cur_menu, conditionList, unlockfunc)
    self.bound = false
    self.colli = false
    self.x, self.y = 0, 0
    self.cur_menu = cur_menu
    local flag = true
    for _, u in ipairs(conditionList) do
        local t = u:func()
        flag = flag and t
    end
    self.list = sp:CopyTable(conditionList)
    self.unlock_button = true
    self.unlock_flag = flag
    if flag then

        function self:yes_func()
            PlaySound("extend")
            unlockfunc()
            self.cur_menu.locked = false
            self.lock = true
            task.New(self, function()
                task.SmoothSetValueTo("alpha", 0, 35, 2)
            end)
        end
    else
        function self:yes_func()
            PlaySound("invalid")
            New(info, _t("noCondition"), 90, 20)
        end
    end
    function self:no_func()
        PlaySound("cancel00")
        self.cur_menu.locked = false
        self.lock = true
        task.New(self, function()
            task.SmoothSetValueTo("alpha", 0, 15, 2)
        end)
    end
    self.index = 0
    self.select = false
    self.lock = true
    self.pheight = 50
    self.pos = 1
    self.alpha = 0
    self.cur_menu.locked = true
    task.New(self, function()
        task.SmoothSetValueTo("alpha", 1, 15, 2)
        self.lock = false
    end)
end
function UnlockWindow:frame()
    task.Do(self)
    if self.lock then
        return
    end
    menu:Updatekey()
    local mouse = ext.mouse
    if self.unlock_button then
        local A = self.alpha
        local count = #self.list
        local w, h = 600, count * 50
        local cx, cy = 480 + 960 - 960 * A, 270
        local x1, x2, y1, y2 = cx - w / 2, cx + w / 2, cy - h / 2, cy + h / 2
        local bx, by = cx, y1 - 60
        if menu:keyYes() then
            self.index = 1
            self:yes_func()
            return
        end
        if Dist(mouse.x, mouse.y, bx, by) < 42 * 0.5 then
            if not self.select then
                self.select = true
                PlaySound("select00")
            end
        else
            self.select = false
        end
        if self.select then
            self.index = self.index + (-self.index + 1) * 0.1
            if mouse:isUp(1) then
                self:yes_func()
            end
            return
        else
            self.index = self.index + (-self.index) * 0.1
        end
    end
    if menu:keyYes() and self.yes_func then
        self:yes_func()
    end
    if menu:keyNo() or mouse:isUp(1) then
        self:no_func()
    end
end
function UnlockWindow:render()
    if self.alpha == 0 then
        return
    end
    local A = self.alpha
    local t = self.timer
    SetImageState("white", "", A * 150, 0, 0, 0)
    RenderRect("white", 0, 960, 0, 540)
    local count = #self.list
    local w, h = 600 + 100 - 100 * A, count * 50 + 100 - 100 * A
    local cx, cy = 480, 270
    local x1, x2, y1, y2 = cx - w / 2, cx + w / 2, cy - h / 2, cy + h / 2

    SetImageState("white", "", A * 150, 0, 0, 0)
    RenderRect("white", x1, x2, y1, y2)
    SetImageState("white", "", A * 255, 255, 255, 255)
    misc.RenderOutLine("white", x1, x2, y2, y1, 0, 2)
    for i = 1, count - 1 do
        misc.RenderOutLine("white", x1, x2, y2 - i * h / count, y2 - i * h / count, 0, 2)
    end
    ui:RenderText("pretty", _t("unlockCond"), cx, y2 + 20,
            0.6, Color(A * 255, 255, 255, 255), "centerpoint")
    for i = 1, count do
        local rot = 0
        local size = 0.35
        local u = self.list[i]
        local x, y = cos(t * 2 + i * 37) * 2 + cx - w / 2 + h / count / 2, y2 - i * h / count + h / count / 2
        local img = "menu_locked_icon"
        local tR, tG, tB = 200, 200, 200
        if u:func() then
            img = "menu_unlocked_icon"
            tR, tG, tB = 255, 227, 132
        end
        SetImageState(img, "", A * 200, 255, 255, 255)
        Render(img, x, y, rot, size)
        ui:RenderTextInWidth("big_text", u.describe, x + 35, y,
                0.5, w - 70, Color(A * 255, tR, tG, tB), "left", "vcenter")
    end
    local br, bg, bb = 150, 50, 50
    local a = A * 100
    if self.unlock_button then
        a = A * 200
        br, bg, bb = 215, 255, 215
        if not self.unlock_flag then
            br, bg, bb = 255, 100, 100
        end
    end

    SetImageState("menu_unlock_button", "", a, br, bg, bb)
    Render("menu_unlock_button", cx, y1 - 60, 0, 0.5 + self.index * 0.1)
end

local ExitButton = plus.Class()
_G.ExitButton = ExitButton
function ExitButton:init(x, y, func)
    self.x, self.y = x, y
    self.func = func
    self.index = 0
    self.timer = 0
    self.r = 14
    self.selected = false
    self.img = "menu_exiticon"
end
function ExitButton:frame()
    self.timer = self.timer + 1
    local mouse = ext.mouse
    if menu:keyNo() then
        self.index = self.index + 1
        PlaySound("cancel00")
        self.func()
    end
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
            PlaySound("cancel00")
            self.func()
        end
    end
end
function ExitButton:render(A)
    A = A or 1
    SetImageState(self.img, "", A * (100 + self.index * 100), 255, 255, 255)
    Render(self.img, self.x, self.y, self.index * 180, (self.r + self.index * 2) / 48)
end