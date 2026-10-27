menu = { noflag = false, yesflag = false, stopcheck = false, stagename = "" }
function menu:FadeIn()
    task.Clear(self)
    task.New(self, function()
        for i = 1, 30 do
            self.alpha = task.SetMode[2](i / 30)
            task.Wait()
        end
        self.locked = false
    end)
end
function menu:FadeOut()
    task.Clear(self)
    if not self.locked then
        task.New(self, function()
            self.locked = true
            for i = 1, 30 do
                self.alpha = 1 - task.SetMode[2](i / 30)
                task.Wait()
            end
        end)
    end
end
function menu:Updatekey()

    ext.mouse:frame()
    self.key = GetLastKey()

end
function menu:keyYes()
    if self.yesflag then
        self.yesflag = false
        return true
    end
    return self.key == setting.keys.shoot or
            self.key == KEY.ENTER
end
function menu:keyNo()
    local flag = false
    if self.noflag then
        self.noflag = false
        flag = true
    else
        flag = self.key == setting.keys.spell or self.key == KEY.ESCAPE
    end
    if flag then
        lstg.tmpvar.EscIsOccupied = true
    end
    return flag
end
function menu:keyLeft()
    return self.key == setting.keys.left or
            self.key == KEY.NUMPAD4 or
            self.key == KEY.NUMPAD1 or
            self.key == KEY.NUMPAD7
end
function menu:keyRight()
    return self.key == setting.keys.right or
            self.key == KEY.NUMPAD6 or
            self.key == KEY.NUMPAD3 or
            self.key == KEY.NUMPAD9
end
function menu:keyUp()
    return self.key == setting.keys.up or
            self.key == KEY.NUMPAD8 or
            self.key == KEY.NUMPAD7 or
            self.key == KEY.NUMPAD9
end
function menu:keyDown()
    return self.key == setting.keys.down or
            self.key == KEY.NUMPAD2 or
            self.key == KEY.NUMPAD1 or
            self.key == KEY.NUMPAD3
end

function menu:ControlExit(x1, x2, y1, y2, action)
    local mouse = ext.mouse
    if sp.math.PointBoundCheck(mouse.x, mouse.y, x1, x2, y1, y2) and mouse:isUp(1) then
        if action then
            action()
        else
            self.noflag = true
        end
    end
end
function menu:RenderExit(x1, x2, y1, y2, alpha)
    alpha = alpha * 255
    SetImageState("white", "", alpha * 0.6, 0, 0, 0)
    RenderRect("white", x1, x2, y1, y2)
    ui:RenderText("big_text", "×", (x1 + x2) / 2, (y1 + y2) / 2 + 3,
            abs(x2 - x1) / 45, Color(alpha, 255, 255, 255), "centerpoint")
end

local select_block = plus.Class()

---@param name_renderfunc string|fun(offx:number, offy:number, alpha:number)
---@param event fun
function select_block:init(x1, x2, y1, y2, name_renderfunc, event)
    self.x1, self.x2, self.y1, self.y2 = x1, x2, y1, y2
    if name_renderfunc == "function" then
        self.name_renderfunc = name_renderfunc
    else
        if name_renderfunc:find("\n") then
            self.name, self.subname = name_renderfunc:match("^(.+)\n(.+)$")
            self.namelen = sp.string(self.name):GetLength() / 2
            self.subnamelen = sp.string(self.subname):GetLength() / 2
        else
            self.name = name_renderfunc
            self.namelen = sp.string(self.name):GetLength() / 2
        end
    end
    self.event = event
    self.choosing = false
    self.bcol = 255
end
function select_block:frame(locked, offx, offy)
    if not locked then
        local mouse = ext.mouse
        if sp.math.PointBoundCheck(mouse.x, mouse.y, self.x1 + offx, self.x2 + offx, self.y1 + offy, self.y2 + offy) then
            self.bcol = self.bcol + (-self.bcol + 120) * 0.2
            if mouse:isUp(1) then
                self.event()
                PlaySound("ok00")
            end
        else
            self.bcol = self.bcol + (-self.bcol + 255) * 0.2
        end--鼠标
        if self.choosing and menu:keyYes() then
            self.event()
            PlaySound("ok00")
        end--键盘
    end
end
function select_block:render(alpha, offx, offy)
    if alpha > 0 then
        local x1, x2, y1, y2 = self.x1 + offx, self.x2 + offx, self.y1 + offy, self.y2 + offy
        local x, y = (x1 + x2) / 2, (y1 + y2) / 2

        for i = 1, 10 do
            SetImageState("white", "", 70 - i * 7, 0, 0, 0)
            RenderRect("white", x1 + i, x2 + i, y1 - i, y2 - i)
        end
        SetImageState("white", "", alpha * 220, self.bcol, self.bcol, self.bcol)
        RenderRect("white", x1, x2, y1, y2)
        SetImageState("white", "", alpha * 100, 255, 255, 255)
        misc.RenderOutLine("white", x1, x2, y2, y1, 1, 0)
        if self.name_renderfunc then
            self.name_renderfunc(x, y, alpha)
        elseif self.name then
            local ttf = "big_text"
            local size = 80 / 2
            if self.subname then
                local h = y2 - y1
                local sw = (x2 - x1) / size / self.namelen
                local sh = h / 3 * 2 / size
                RenderTTF2(ttf, self.name, x, y + h / 6, min(sw, sh) * 0.87,
                        Color(alpha * 255, 0, 0, 0), "centerpoint")
                local sw2 = (x2 - x1) / size / self.subnamelen
                local sh2 = h / 3 * 1 / size
                RenderTTF2(ttf, self.subname, x, y - h / 3, min(sw2, sh2) * 0.87,
                        Color(alpha * 255, 0, 0, 0), "centerpoint")
            else
                local sw = (x2 - x1) / size / self.namelen
                local sh = (y2 - y1) / size
                RenderTTF2(ttf, self.name, x, y, min(sw, sh) * 0.87,
                        Color(alpha * 255, 0, 0, 0), "centerpoint")
            end

        end
        if self.choosing then
            SetImageState("white", "", alpha * 255, 255, 227, 132)
            misc.RenderOutLine("white", x1 - 4, x2 + 4, y2 + 4, y1 - 4, 0, 2)
        end
    end
end

---@param name_renderfunc fun(offx:number, offy:number, alpha:number)
---@param event fun
local function Newselect_block(x1, x2, y1, y2, name_renderfunc, event)
    return select_block(x1, x2, y1, y2, name_renderfunc, event)
end
_G.Newselect_block = Newselect_block

function menu:mouseCheck(main_y, offy, height, list_count)
    local mouse = ext.mouse
    local y
    local selected
    for i = 1, list_count do
        y = main_y - i * height
        if abs(mouse.y - y) + offy < height / 2 then
            selected = i
            break
        end
    end
    return selected
end

function menu:GetTXTlen(ttf, size, txt)
    local fr = lstg.FontRenderer
    fr.SetFontProvider(ttf)
    fr.SetScale(size, size)
    local _l, _r = fr.MeasureTextBoundary(txt)
    return (_r - _l) / 2
end

---根本菜单，用来播放bgm的
FUNDAMENTAL_MENU = nil
DoFile("THlib\\UI\\loading.lua")
DoFile("THlib\\UI\\menus\\initlanguage.lua")

local function LoadMenuFile()
    local path = "assets\\UI\\menus\\"
    LoadImageFromFile("menu_button", path .. "general_button.png")
    LoadImageFromFile("menu_circle", path .. "general_circle.png")
    LoadImageFromFile("menu_pure_circle", path .. "pure_circle.png")
    LoadImageFromFile("menu_bright_circle", path .. "bright_circle.png")
    LoadImageFromFile("menu_unlock_button", path .. "unlock_button.png", true)
    LoadImageFromFile("menu_locked_icon", path .. "locked_icon.png", true)
    LoadImageFromFile("menu_unlocked_icon", path .. "unlocked_icon.png", true)
    LoadImageFromFile("menu_newicon", path .. "new_icon.png", true)
    LoadImageFromFile("menu_questionicon", path .. "question_icon.png", true)
    LoadImageFromFile("menu_exiticon", path .. "exit_icon.png", true)
    LoadImageFromFile("menu_check_addition", path .. "check_addition.png")
    LoadImageGroupFromFile("menu_player_star", path .. "player_star.png", true, 3, 1)
    LoadImageFromFile("mission_unit_back", path .. "mission_unit_back.png")
    LoadImageFromFile("mission_unit_outline", path .. "mission_unit_outline.png")
    LoadImageFromFile("menu_wave_handbook", path .. "wave_handbook.png")
    LoadImageFromFile("menu_active_handbook", path .. "active_handbook.png")
    -- LoadImageFromFile("menu_circle1", path .. "circle1.png", true)
    LoadImageFromFile("menu_circle2", path .. "circle2.png", true)
    LoadImageFromFile("menu_logo", "assets\\UI\\logo.png", true)
    LoadTexture2("menu_bg_2", "assets\\UI\\menu_bg2.png")
    local spath = "THlib\\UI\\menus\\"

    DoFile(spath .. "menu_obj.lua")
    DoFile(spath .. "mainmenu.lua")
    DoFile(spath .. "music_stream.lua")
    DoFile(spath .. "attr_select.lua")
    DoFile(spath .. "attr_select2.lua")
    DoFile(spath .. "attr_select3.lua")
    DoFile(spath .. "scene_select.lua")
    DoFile(spath .. "playdatamenu.lua")
    DoFile(spath .. "settingmenu.lua")
    DoFile(spath .. "top_bar.lua")
    DoFile(spath .. "achievement.lua")
    DoFile(spath .. "handbookmenu.lua")
    DoFile(spath .. "missionmenu.lua")
    DoFile(spath .. "small_loading.lua")
    DoFile(spath .. "challenge_select.lua")
end
if GlobalLoading then
    LoadMenuFile()
else
    table.insert(LoadRes, LoadMenuFile)
end

local function t(str)
    return i18n("sth", str) or ""
end

function menu:RenderBar(x, y, length, width, progress, alpha, r, g, b)
    r, g, b = r or 100, g or 255, b or 100
    local x1, x2, y1, y2 = x - length / 2, x + length / 2, y - width / 2, y + width / 2
    local rr = (y2 - y1) / 2
    local co = clamp(progress / 100, 0, 1)
    local gox = x1 + max(rr * 2, (x2 - x1) * co)
    SetImageState("white", "", 100 * alpha, r, g, b)
    misc.RenderRoundedRect(x1, gox, y1, y2, rr, 6)
    SetImageState("white", "", 150 * alpha, 255, 255, 255)
    --misc.RenderRoundedRectOutline(x1 - 1, gox + 1, y1 - 1, y2 + 1, rr + 1, 1, 6)
    misc.RenderRoundedRectOutline(x1 - 2, x2 + 2, y1 - 2, y2 + 2, rr + 2, 2, 6)
end

local rTWC = ReplaceTextWithCommand

---渲染道具详述
---@param unit addition_unit
---@return number@总共渲染行数
function menu:RenderToolDescribe(unit, x1, x2, y1, y2, ky, offy, line_h, a1, a2, timer, Ingame)
    local _y = y2 - ky
    SetImageState("white", "", a1 * 180, 10, 10, 10)
    RenderRect("white", x1, x2, y1, y2)
    SetImageState("white", "", a1 * 255, 255, 255, 255)
    misc.RenderOutLine("white", x1, x2, y2, y1, 0, 2)
    ---@type addition_unit
    local p = unit
    if p then
        RenderRect("white", x1, x2, y2 - ky - 1, y2 - ky + 1)
        RenderRect("white", x1 + ky - 1, x1 + ky + 1, y2 - ky, y2)
        RenderRect("white", x1 + ky, x2, y2 - ky * 0.65 + 1, y2 - ky * 0.65 - 1)
        if Ingame or scoredata.BookAddition[p.id] then
            SetImageState(p.pic, "", 255 * a2, 255, 255, 255)
            Render(p.pic, x1 + ky / 2, y2 - ky / 2, 0, (ky - 6) / 256)
            --RenderRect(p.pic, x1, x1 + ky, y2 - ky, y2)
            if p.isTool then
                if Ingame then
                    ui:RenderText("title", ("%d / %d"):format(lstg.var.addition[p.id] or 0, p.maxcount),
                            x1 + ky - 6, y2, 0.8, Color(a2 * 255, p.R, p.G, p.B), "right", "top")
                    if p.broken then
                        local pic = "menu_exiticon"
                        SetImageState(pic, "", 100 * a2, 250, 128, 114)
                        RenderRect(pic, x1 + ky - 35, x1 + ky, y2 - ky, y2 - ky + 35)
                    end
                end
                ui:RenderText("big_text", p.title2, (x1 + ky + x2) / 2, y2 - 25,
                        0.46, Color(a2 * 255, p.R, p.G, p.B), "centerpoint")
                ui:RenderText("title", p.subtitle, (x1 + ky + x2) / 2, y2 - ky + 14,
                        0.8, Color(a2 * 255, p.R, p.G, p.B), "centerpoint")

            else
                if Ingame then
                    ui:RenderText("title", ("%d"):format(lstg.var.addition[p.id] or 0),
                            x1 + ky - 6, y2, 0.8, Color(a2 * 255, p.R, p.G, p.B), "right", "top")
                end
                ui:RenderText("big_text", p.title3, (x1 + ky + x2) / 2, y2 - 25,
                        0.46, Color(a2 * 255, p.R, p.G, p.B), "centerpoint")
                ui:RenderText("pretty_title", p.title2, (x1 + ky + x2) / 2, y2 - ky + 17,
                        0.8, Color(a2 * 255, p.R, p.G, p.B), "centerpoint")
            end
            SetRenderRect(x1, x2, y1 - offy, y2 - ky - offy - 1, x1, x2, y1, y2 - ky - 1)
            local tsize = 0.725
            if p.isTool then
                do
                    local s = t("effect")
                    local w = self:GetTXTlen("title", tsize, s) + 12
                    ui:RenderText("title", s, x1 + 6, _y - 5,
                            tsize, Color(a2 * 255, 255, 255, 255), "left", "top")
                    for _, str in ipairs(sp:SplitText(p.detail, "\n")) do
                        ui:RenderTextWithCommand("title", str, x1 + w, _y - 5, tsize, a2 * 230, "left")
                        _y = _y - line_h
                    end
                end--效果
                _y = _y - line_h
                do
                    if Ingame then
                        ui:RenderText("title", ("%s%d / %d"):format(t("curGet"), lstg.var.addition[p.id] or 0, p.maxcount),
                                x1 + 6, _y - 5, tsize, Color(a2 * 255, 230, 255, 230), "left", "top")
                    else
                        ui:RenderText("title", ("%s%d"):format(t("maxC"), p.maxcount),
                                x1 + 6, _y - 5, tsize, Color(a2 * 255, 230, 255, 230), "left", "top")
                    end
                    _y = _y - line_h
                    local s = t("overlay")
                    local w = self:GetTXTlen("title", tsize, s) + 12
                    ui:RenderText("title", s, x1 + 6, _y - 5,
                            tsize, Color(a2 * 255, 230, 255, 230), "left", "top")
                    for _, str in ipairs(sp:SplitText(p.repeat_des, "\n")) do
                        ui:RenderTextWithCommand("title", str, x1 + w, _y - 5, tsize, a2 * 230, "left")
                        _y = _y - line_h
                    end
                end--叠加效果
                _y = _y - line_h
                do
                    local s = t("cooperation")
                    local w = self:GetTXTlen("title", tsize, s) + 12
                    ui:RenderText("title", s, x1 + 6, _y - 5,
                            tsize, Color(a2 * 255, 230, 230, 255), "left", "top")
                    for _, str in ipairs(sp:SplitText(p.collab_des, "\n")) do
                        ui:RenderTextWithCommand("title", str, x1 + w, _y - 5, tsize, a2 * 230, "left")
                        _y = _y - line_h
                    end
                end--道具协同
                _y = _y - line_h
                do
                    ui:RenderText("title", ("%s%s"):format(t("initialTake"), p.initialTake and t("T") or t("F")),
                            x1 + 6, _y - 5, tsize, Color(a2 * 255, 220, 230, 245), "left", "top")
                    _y = _y - line_h
                    ui:RenderTextWithCommand("title", ("%s%s"):format(t("tag"), table.concat(p.tags, " | ")),
                            x1 + 6, _y - 5, tsize, a2 * 255, "left", "top")
                    _y = _y - line_h * 2
                    local s = t("unlockWay")
                    local w = self:GetTXTlen("title", tsize, s) + 12
                    ui:RenderText("title", s, x1 + 6, _y - 5,
                            tsize, Color(a2 * 255, 245, 230, 220), "left", "top")
                    for _, str in ipairs(sp:SplitText(p.unlock_des, "\n")) do
                        ui:RenderTextWithCommand("title", str, x1 + w, _y - 5, tsize, a2 * 230, "left")
                        _y = _y - line_h
                    end
                    s = t("appearCond")
                    w = self:GetTXTlen("title", tsize, s) + 12
                    ui:RenderText("title", s, x1 + 6, _y - 5,
                            tsize, Color(a2 * 255, 189, 201, 252), "left", "top")
                    for _, str in ipairs(sp:SplitText(p.cond_des, "\n")) do
                        ui:RenderTextWithCommand("title", str, x1 + w, _y - 5, tsize, a2 * 230, "left")
                        _y = _y - line_h
                    end
                end--杂项
            else
                for _, str in ipairs(sp:SplitText(p.describe, "\n")) do
                    ui:RenderText("title", str, x1 + 6, _y - 5,
                            tsize, Color(a2 * 230, 255, 255, 255), "left", "top")
                    _y = _y - line_h
                end
            end
        else
            local tsize = 0.725
            if p.isTool then
                local s = t("unlockWay")
                local w = self:GetTXTlen("title", tsize, s) + 12
                ui:RenderText("title", s, x1 + 6, _y - 5,
                        tsize, Color(a2 * 255, 245, 230, 220), "left", "top")
                for _, str in ipairs(sp:SplitText(p.unlock_des, "\n")) do
                    ui:RenderTextWithCommand("title", str, x1 + w, _y - 5, tsize, a2 * 230, "left")
                    _y = _y - line_h
                end
            end
        end
        SetViewMode('ui')
        misc.RenderBrightOutline(x1, x2, y1, y2, 25, a2 * (sin(timer * 3) * 30 + 60), p.R, p.G, p.B)
    end
    return (y2 - ky - _y) / line_h--就直接在这里算得了
end

---渲染道具列表
---@return number@总共渲染行数
function menu:RenderToolList(list, x1, x2, y1, y2, offy, line_h, dh, row, a, tri1, tri2, tri3, nowpos, mousepos, timer, Ingame)
    SetImageState("white", "", a * 180, 10, 10, 10)
    RenderRect("white", x1, x2, y1, y2)
    SetImageState("white", "", a * 255, 255, 255, 255)
    misc.RenderOutLine("white", x1, x2, y2, y1, 0, 2)
    SetRenderRect(x1, x2, y1 - offy, y2 - offy, x1, x2, y1, y2)
    local dy = dh
    local width = line_h - dy
    local xi, yi = 1, 1

    for i, p in ipairs(list) do

        local kx = x1 + (xi - 1) * width
        local ky = y2 - (yi - 1) * line_h
        local _a = a * tri3
        local mouseeff = 0
        local kl = 4

        if i ~= nowpos then

            if i == mousepos then
                mouseeff = tri2
                kl = 4 * (1 - tri2)
                _a = _a * (0.5 + tri2 * 0.2)
            else
                _a = _a * 0.5
            end
        else
            _a = _a * (0.5 + tri1 * 0.5)
            kl = 4 * (1 - tri1)
        end

        local _x1, _x2, _y1, _y2 = kx + kl, kx + width - kl, ky - line_h + kl, ky - kl
        if _y2 < y2 - offy + line_h and _y1 > y1 - offy - line_h then
            SetImageState("white", "", _a * 146, 255, 255, 255)
            RenderRect("white", _x1, _x2, _y1 + dy - 1, _y1 + dy + 1)
            SetImageState("white", "", _a * 255, 255, 255, 255)
            misc.RenderOutLine("white", _x1, _x2, _y2, _y1, 0, 1.3)
            SetImageState("white", "", _a * 50, p.R, p.G, p.B)

            RenderRect("white", _x1, _x2, _y1 + dy, _y2)
            if Ingame or scoredata.BookAddition[p.id] then
                SetImageState(p.pic, "", 255 * _a, 255, 255, 255)
                Render(p.pic, (_x1 + _x2) / 2, (_y1 + dy + _y2) / 2, 0, (_x2 - _x1 - 6) / 256)
                --RenderRect(p.pic, _x1, _x2, _y1 + dy, _y2)
                ui:RenderTextInWidth("title", p.title2, (_x1 + _x2) / 2, _y1 + dy * 0.76,
                        0.64, width - 10, Color(_a * 255, p.R, p.G, p.B), "center")
            else
                local pic = p.pic
                SetImageState(pic, "add+alpha", 180 * _a, 255, 255, 255)
                Render(pic, (_x1 + _x2) / 2, (_y1 + dy + _y2) / 2, 0, (_x2 - _x1 - 6) / 256)
                --RenderRect(pic, _x1, _x2, _y1 + dy, _y2)
                ui:RenderText("big_text", "?", (_x1 + _x2) / 2, (_y1 + dy + _y2) / 2,
                        1, Color(_a * 255, 255, 255, 255), "centerpoint")
                ui:RenderTextInWidth("title", "？？？", (_x1 + _x2) / 2, _y1 + dy * 0.76,
                        0.64, width - 10, Color(_a * 255, p.R, p.G, p.B), "center")
            end
            if Ingame then
                local count = lstg.var.addition[p.id] or 0
                ui:RenderText("pretty_title", count, _x2 - 4, _y2,
                        0.73, Color(_a * 255, p.R, p.G, p.B), "right", "top")
                if p.broken then
                    local pic = "menu_exiticon"
                    SetImageState(pic, "", 100 * _a, 250, 128, 114)
                    RenderRect(pic, _x2 - 35, _x2, _y1 + dy, _y1 + dy + 35)
                end
            else
                if p.maxcount and p.maxcount > 1 then
                    ui:RenderText("pretty_title", p.maxcount, _x2 - 4, _y2,
                            0.73, Color(_a * 255, p.R, p.G, p.B), "right", "top")
                end
            end
            if DEBUG then
                ui:RenderText("pretty_title", p.id, _x2 - 4, _y1 + dy + 3,
                        0.73, Color(_a * 255, p.R, p.G, p.B), "right", "bottom")
            end
            misc.RenderBrightOutline(_x1, _x2, _y1 + dy, _y2, 10,
                    _a * mouseeff * 150, 255, 255, 255)
            misc.RenderBrightOutline(_x1, _x2, _y1 + dy, _y2, 10,
                    _a * (sin(timer * 3 + i * 55) * 30 + 50), p.R, p.G, p.B)
        end
        xi = xi + 1
        if xi == row + 1 then
            xi = 1
            yi = yi + 1
        end
    end
    return yi
end

---渲染天气详述
---@param unit addition_unit
---@return number@总共渲染行数
function menu:RenderWeatherDescribe(unit, x1, x2, y1, y2, ky, offy, line_h, a1, a2, timer, Ingame)
    local _y = y2 - ky
    SetImageState("white", "", a1 * 180, 10, 10, 10)
    RenderRect("white", x1, x2, y1, y2)
    SetImageState("white", "", a1 * 255, 255, 255, 255)
    misc.RenderOutLine("white", x1, x2, y2, y1, 0, 2)
    ---@type weather_unit
    local p = unit
    if p then
        local kindex = (setting.language == 2) and 2.6 or 2
        RenderRect("white", x1, x2, y2 - ky - 1, y2 - ky + 1)
        RenderRect("white", x1 + ky * kindex - 1, x1 + ky * kindex + 1, y2 - ky, y2)
        if Ingame or scoredata.Weather[p.id] then
            ui:RenderText("pretty", p.name, x1 + ky * kindex / 2, y2 - ky / 2 + 2,
                    0.6, Color(a2 * 255, p.R, p.G, p.B), "centerpoint")
            ui:RenderText("pretty", p.subtitle, (x1 + ky * kindex + x2) / 2, y2 - ky / 2 + 2,
                    0.5, Color(a2 * 255, p.R, p.G, p.B), "centerpoint")
            SetRenderRect(x1, x2, y1 - offy, y2 - ky - offy - 1, x1, x2, y1, y2 - ky - 1)
            if not Ingame then
                ui:RenderText("big_text", t("gotoPractice"), x2 - 6, y1 + 6,
                        0.4, Color(a2 * (sin(timer * 3) * 50 + 100), 200, 200, 200), "right", "bottom")
            end
            local back_img = ("season_icon_full_%d"):format(p.inseason)
            SetImageState(back_img, "mul+add", a2 * 48, 255, 255, 255)
            Render(back_img, (x1 + x2) / 2, (y1 + y2 - ky) / 2 - offy * 0.8, 0, 0.7)
            local tsize = 0.725
            do
                local s = t("effect")
                local w = self:GetTXTlen("title", tsize, s) + 12
                ui:RenderText("title", s, x1 + 6, _y - 5,
                        tsize, Color(a2 * 255, 255, 255, 255), "left", "top")
                for _, str in ipairs(sp:SplitText(p.describe, "\n")) do
                    ui:RenderTextWithCommand("title", str, x1 + w, _y - 5, tsize, a2 * 230, "left")
                    _y = _y - line_h
                end
            end--效果
            _y = _y - line_h
            if p.special_des then
                local s = t("sp")
                local w = self:GetTXTlen("title", tsize, s) + 12
                ui:RenderText("title", s, x1 + 6, _y - 5,
                        tsize, Color(a2 * 255, 255, 255, 255), "left", "top")
                for _, str in ipairs(sp:SplitText(p.special_des, "\n")) do
                    ui:RenderTextWithCommand("title", str, x1 + w, _y - 5, tsize, a2 * 230, "left")
                    _y = _y - line_h
                end
                _y = _y - line_h
            end--特殊
            do

                ui:RenderText("title", ("%s%s"):format(t("dependSeason"), p.inseason_name),
                        x1 + 6, _y - 5, tsize, Color(a2 * 255, p.sR, p.sG, p.sB), "left", "top")
                _y = _y - line_h
                ui:RenderText("title", ("%s%s"):format(t("characteristic"), p.state_name),
                        x1 + 6, _y - 5, tsize, Color(a2 * 255, p.R, p.G, p.B), "left", "top")
            end--杂项
        end
        SetViewMode('ui')
        misc.RenderBrightOutline(x1, x2, y1, y2, 25, a2 * (sin(timer * 3) * 30 + 60), p.R, p.G, p.B)
    end
    return (y2 - ky - _y) / line_h--就直接在这里算得了
end

---渲染天气列表
---@return number@总共渲染行数
function menu:RenderWeatherList(list, x1, x2, y1, y2, offy, line_h, dh, row, a, tri1, tri2, tri3, nowpos, mousepos, timer, Ingame)

    SetImageState("white", "", a * 180, 10, 10, 10)
    RenderRect("white", x1, x2, y1, y2)
    SetImageState("white", "", a * 255, 255, 255, 255)
    misc.RenderOutLine("white", x1, x2, y2, y1, 0, 2)
    SetRenderRect(x1, x2, y1 - offy, y2 - offy, x1, x2, y1, y2)
    local dy = dh
    local width = (x2 - x1) / row
    local xi, yi = 1, 1

    for i, p in ipairs(list) do
        local wea = p.wea
        local kx = x1 + (xi - 1) * width
        local ky = y2 - (yi - 1) * line_h
        local _a = a * tri3
        local mouseeff = 0
        local kl = 4
        local sk = 0
        if i ~= nowpos then

            if i == mousepos then
                mouseeff = tri2
                kl = 4 * (1 - tri2)
                _a = _a * (0.5 + tri2 * 0.2)
            else
                _a = _a * 0.5
            end
        else
            _a = _a * (0.5 + tri1 * 0.5)
            kl = 4 * (1 - tri1)
            sk = tri1
        end
        local _x1, _x2, _y1, _y2 = kx + kl, kx + width - kl, ky - line_h + kl, ky - kl
        if _y2 < y2 - offy + line_h and _y1 > y1 - offy - line_h then
            SetImageState("white", "", _a * 146, 255, 255, 255)
            RenderRect("white", _x1, _x2, _y1 + dy - 1, _y1 + dy + 1)
            SetImageState("white", "", _a * 255, 255, 255, 255)
            misc.RenderOutLine("white", _x1, _x2, _y2, _y1, 0, 1.3)
            SetImageState("white", "", _a * 50, wea.sR, wea.sG, wea.sB)
            RenderRect("white", _x1, _x2, _y1, _y2)
            if Ingame or scoredata.Weather[wea.id] then
                ui:RenderTextInWidth("pretty", wea.name, (_x1 + _x2) / 2, (_y1 + dy + _y2) / 2 + 1,
                        0.4 + 0.1 * sk, _x2 - _x1 - 3, Color(_a * 255, wea.R, wea.G, wea.B), "centerpoint")
                if Ingame then
                    ui:RenderText("title", ("Wave %d"):format(p.wave), (_x1 + _x2) / 2, _y1 + dy * 0.6,
                            0.64, Color(_a * 255, 200, 200, 200), "centerpoint")
                else
                    ui:RenderText("title", wea.inseason_name, (_x1 + _x2) / 2, _y1 + dy * 0.6,
                            0.6, Color(_a * 255, 200, 200, 200), "centerpoint")
                end
            else
                ui:RenderText("pretty", "??", (_x1 + _x2) / 2, (_y1 + dy + _y2) / 2 + 1,
                        0.45 + 0.1 * sk, Color(_a * 255, 200, 200, 200), "centerpoint")
                ui:RenderText("title", "??", (_x1 + _x2) / 2, _y1 + dy * 0.6,
                        0.6, Color(_a * 255, 200, 200, 200), "centerpoint")

            end
            if DEBUG then
                ui:RenderText("pretty_title", wea.id, _x2 - 4, _y1 + 3,
                        0.73, Color(_a * 255, wea.R, wea.G, wea.B), "right", "bottom")
            end
            misc.RenderBrightOutline(_x1, _x2, _y1, _y2, 10,
                    _a * mouseeff * 150, 255, 255, 255)
            misc.RenderBrightOutline(_x1, _x2, _y1, _y2, 10,
                    _a * (sin(timer * 3 + i * 55) * 30 + 50), wea.sR, wea.sG, wea.sB)

        end
        xi = xi + 1
        if xi == row + 1 then
            xi = 1
            yi = yi + 1
        end
    end
    return yi
end

---渲染波详述
---@param unit addition_unit
---@return number@总共渲染行数
function menu:RenderWaveDescribe(unit, x1, x2, y1, y2, ky, offy, line_h, a1, a2, timer)
    SetImageState("white", "", a1 * 180, 10, 10, 10)
    RenderRect("white", x1, x2, y1, y2)
    SetImageState("white", "", a1 * 255, 255, 255, 255)
    misc.RenderOutLine("white", x1, x2, y2, y1, 0, 2)
    ---@type addition_unit
    local p = unit
    if p then
        local kh = (x2 - x1) / 2 * 0.5625
        RenderRect("white", x1, x2, y2 - kh * 2 - 1, y2 - kh * 2 + 1)
        local unlock = stagedata.BookWave[p.inscene][p.id]
        if unlock then

            local pic = ("WavePic_%d_%d"):format(p.inscene, p.id)
            local attribute = {}
            local R, G, B = 255, 255, 255
            if p.tagName then
                table.insert(attribute, p.tagName)
                R, G, B = p.R, p.G, p.B
            else
                if p.isdangerous then
                    table.insert(attribute, "Hard")
                    R, G, B = 218, 112, 214
                end
                if p.islucky then
                    table.insert(attribute, "Lucky")
                    R, G, B = 255, 227, 132
                end
                if p.isboss then
                    table.insert(attribute, "Boss")
                    R, G, B = 250, 128, 114
                end
            end
            if CheckRes("img", pic) then
                local w = GetTextureSize(pic)
                SetImageState(pic, "", 255 * a2, 255, 255, 255)
                Render(pic, (x1 + x2) / 2, y2 - kh, 0, (x2 - x1 - 1) / (w))

                ui:RenderText("big_text", t("resetPIC"), x2 - 6, y2 - kh * 2 + 6,
                        0.4, Color(a2 * (sin(timer * 3) * 50 + 100), 200, 200, 200), "right", "bottom")
            else
                ui:RenderText("pretty", "找不到取景", (x1 + x2) / 2, y2 - kh,
                        1, Color(a2 * 255, R, G, B), "centerpoint")
            end
            ui:RenderText("big_text", t("gotoPractice"), x2 - 6, y1 + 6,
                    0.4, Color(a2 * (sin(timer * 3) * 50 + 100), 200, 200, 200), "right", "bottom")
            local _y = y2 - kh * 2

            do
                ui:RenderText("big_text", ("%s%s"):format(t("scene"), SceneClass[p.inscene].title), x1 + 6, _y - 5,
                        0.48, Color(a2 * 255, 200, 200, 200), "left", "top")
                _y = _y - line_h
                ui:RenderText("big_text", ("%s%s"):format(t("name"), p.title), x1 + 6, _y - 5,
                        0.48, Color(a2 * 255, 255, 255, 255), "left", "top")
                _y = _y - line_h
                local str = "Normal"
                if #attribute > 0 then
                    str = table.concat(attribute, " ")
                end
                ui:RenderText("big_text", ("%s%s"):format(t("tag"), str), x1 + 6, _y - 5,
                        0.48, Color(a2 * 255, R, G, B), "left", "top")

            end--效果
            misc.RenderBrightOutline(x1, x2, y1, y2, 25, a2 * (sin(timer * 3) * 30 + 60), R, G, B)
            SetRenderRect(x1, x2, y1 - offy, y2 - ky - offy - 1, x1, x2, y1, y2 - ky - 1)
        end
        SetViewMode('ui')
    end
    return 0--就直接在这里算得了
end

---渲染波列表
---@return number@总共渲染行数
function menu:RenderWaveList(list, x1, x2, y1, y2, offy, line_h, dh, row, a, tri1, tri2, tri3, nowpos, mousepos, timer)
    SetImageState("white", "", a * 180, 10, 10, 10)
    RenderRect("white", x1, x2, y1, y2)
    SetImageState("white", "", a * 255, 255, 255, 255)
    misc.RenderOutLine("white", x1, x2, y2, y1, 0, 2)
    SetRenderRect(x1, x2, y1 - offy, y2 - offy, x1, x2, y1, y2)
    local dy = dh
    local width = (x2 - x1) / row
    local xi, yi = 1, 1

    for i, p in ipairs(list) do

        local kx = x1 + (xi - 1) * width
        local ky = y2 - (yi - 1) * line_h
        local _a = a * tri3
        local mouseeff = 0
        local kl = 4

        if i ~= nowpos then

            if i == mousepos then
                mouseeff = tri2
                kl = 4 * (1 - tri2)
                _a = _a * (0.5 + tri2 * 0.2)
            else
                _a = _a * 0.5
            end
        else
            _a = _a * (0.5 + tri1 * 0.5)
            kl = 4 * (1 - tri1)
        end
        local unlock = stagedata.BookWave[p.inscene][p.id]
        local _x1, _x2, _y1, _y2 = kx + kl, kx + width - kl, ky - line_h + kl, ky - kl
        if _y2 < y2 - offy + line_h and _y1 > y1 - offy - line_h then
            SetImageState("white", "", _a * 146, 255, 255, 255)
            RenderRect("white", _x1, _x2, _y1 + dy - 1, _y1 + dy + 1)
            SetImageState("white", "", _a * 255, 255, 255, 255)
            misc.RenderOutLine("white", _x1, _x2, _y2, _y1, 0, 1.3)
            SetImageState("white", "", _a * 50, p.R, p.G, p.B)

            RenderRect("white", _x1, _x2, _y1 + dy, _y2)
            local R, G, B = 255, 255, 255
            if p.R and p.G and p.B then
                R, G, B = p.R, p.G, p.B
            else
                if p.isdangerous then
                    R, G, B = 218, 112, 214
                end
                if p.isboss then
                    R, G, B = 250, 128, 114
                end
                if p.islucky then
                    R, G, B = 255, 227, 132
                end
            end
            if unlock then
                local pic = ("WavePic_%d_%d"):format(p.inscene, p.id)
                if CheckRes("img", pic) then
                    local w = GetTextureSize(pic)
                    SetImageState(pic, "", 255 * _a, 255, 255, 255)
                    Render(pic, (_x1 + _x2) / 2, (_y1 + dy + _y2) / 2, 0, (_x2 - _x1 - 1) / (w))
                else
                    ui:RenderText("pretty_title", "找不到取景", (_x1 + _x2) / 2, (_y1 + dy + _y2) / 2,
                            0.64, Color(_a * 255, R, G, B), "centerpoint")
                end
                --RenderRect(p.pic, _x1, _x2, _y1 + dy, _y2)
                ui:RenderTextInWidth("title", p.title, (_x1 + _x2) / 2, _y1 + dy * 0.76,
                        0.64, width - 10, Color(_a * 255, R, G, B), "center")
            else
                -- local pic = "addition_state1"
                -- SetImageState(pic, "", 255 * _a, 200, 200, 255)
                --  Render(pic, (_x1 + _x2) / 2, (_y1 + dy + _y2) / 2, 0, (_x2 - _x1 - 6) / 256)
                --RenderRect(pic, _x1, _x2, _y1 + dy, _y2)
                ui:RenderText("big_text", "?", (_x1 + _x2) / 2, (_y1 + dy + _y2) / 2,
                        1, Color(_a * 255, 255, 255, 255), "centerpoint")
                ui:RenderTextInWidth("title", "？？？", (_x1 + _x2) / 2, _y1 + dy * 0.76,
                        0.64, width - 10, Color(_a * 255, 200, 200, 200), "center")
            end
            misc.RenderBrightOutline(_x1, _x2, _y1 + dy, _y2, 10,
                    _a * mouseeff * 150, 255, 255, 255)
            misc.RenderBrightOutline(_x1, _x2, _y1 + dy, _y2, 10,
                    _a * (sin(timer * 3 + i * 55) * 30 + 50), R, G, B)
        end
        xi = xi + 1
        if xi == row + 1 then
            xi = 1
            yi = yi + 1
        end
    end
    return yi
end

function menu:RenderActiveList(list, x1, x2, y1, y2, offy, line_h, dh, row, a, tri1, tri2, tri3, nowpos, mousepos, timer, Ingame)
    SetImageState("white", "", a * 180, 10, 10, 10)
    RenderRect("white", x1, x2, y1, y2)
    SetImageState("white", "", a * 255, 255, 255, 255)
    misc.RenderOutLine("white", x1, x2, y2, y1, 0, 2)
    SetRenderRect(x1, x2, y1 - offy, y2 - offy, x1, x2, y1, y2)
    local dy = dh
    local width = line_h - dy
    local xi, yi = 1, 1

    for i, p in ipairs(list) do

        local kx = x1 + (xi - 1) * width
        local ky = y2 - (yi - 1) * line_h
        local _a = a * tri3
        local mouseeff = 0
        local kl = 4

        if i ~= nowpos then

            if i == mousepos then
                mouseeff = tri2
                kl = 4 * (1 - tri2)
                _a = _a * (0.5 + tri2 * 0.2)
            else
                _a = _a * 0.5
            end
        else
            _a = _a * (0.5 + tri1 * 0.5)
            kl = 4 * (1 - tri1)
        end

        local _x1, _x2, _y1, _y2 = kx + kl, kx + width - kl, ky - line_h + kl, ky - kl
        if _y2 < y2 - offy + line_h and _y1 > y1 - offy - line_h then
            SetImageState("white", "", _a * 146, 255, 255, 255)
            RenderRect("white", _x1, _x2, _y1 + dy - 1, _y1 + dy + 1)
            SetImageState("white", "", _a * 255, 255, 255, 255)
            misc.RenderOutLine("white", _x1, _x2, _y2, _y1, 0, 1.3)
            SetImageState("white", "", _a * 50, p.R, p.G, p.B)

            RenderRect("white", _x1, _x2, _y1 + dy, _y2)
            if Ingame or scoredata.BookActive[p.id] then
                SetImageState(p.pic, "", 255 * _a, 255, 255, 255)
                Render(p.pic, (_x1 + _x2) / 2, (_y1 + dy + _y2) / 2, 0, (_x2 - _x1 - 6) / 256)
                --RenderRect(p.pic, _x1, _x2, _y1 + dy, _y2)
                ui:RenderTextInWidth("title", p.title2, (_x1 + _x2) / 2, _y1 + dy * 0.76,
                        0.64, width - 10, Color(_a * 255, p.R, p.G, p.B), "center")
            else
                local pic = p.pic
                SetImageState(pic, "add+alpha", 180 * _a, 255, 255, 255)
                Render(pic, (_x1 + _x2) / 2, (_y1 + dy + _y2) / 2, 0, (_x2 - _x1 - 6) / 256)
                --RenderRect(pic, _x1, _x2, _y1 + dy, _y2)
                ui:RenderText("big_text", "?", (_x1 + _x2) / 2, (_y1 + dy + _y2) / 2,
                        1, Color(_a * 255, 255, 255, 255), "centerpoint")
                ui:RenderTextInWidth("title", "？？？", (_x1 + _x2) / 2, _y1 + dy * 0.76,
                        0.64, width - 10, Color(_a * 255, p.R, p.G, p.B), "center")
            end
            if DEBUG then
                ui:RenderText("pretty_title", p.id, _x2 - 4, _y1 + dy + 3,
                        0.73, Color(_a * 255, p.R, p.G, p.B), "right", "bottom")
            end
            misc.RenderBrightOutline(_x1, _x2, _y1 + dy, _y2, 10,
                    _a * mouseeff * 150, 255, 255, 255)
            misc.RenderBrightOutline(_x1, _x2, _y1 + dy, _y2, 10,
                    _a * (sin(timer * 3 + i * 55) * 30 + 50), p.R, p.G, p.B)
        end
        xi = xi + 1
        if xi == row + 1 then
            xi = 1
            yi = yi + 1
        end
    end
    return yi
end

function menu:RenderActiveDescribe(unit, x1, x2, y1, y2, ky, offy, line_h, a1, a2, timer, Ingame)
    local _y = y2 - ky
    SetImageState("white", "", a1 * 180, 10, 10, 10)
    RenderRect("white", x1, x2, y1, y2)
    SetImageState("white", "", a1 * 255, 255, 255, 255)
    misc.RenderOutLine("white", x1, x2, y2, y1, 0, 2)
    ---@type addition_unit
    local p = unit
    if p then
        RenderRect("white", x1, x2, y2 - ky - 1, y2 - ky + 1)
        RenderRect("white", x1 + ky - 1, x1 + ky + 1, y2 - ky, y2)
        RenderRect("white", x1 + ky, x2, y2 - ky * 0.65 + 1, y2 - ky * 0.65 - 1)
        if Ingame or scoredata.BookActive[p.id] then
            SetImageState(p.pic, "", 255 * a2, 255, 255, 255)
            Render(p.pic, x1 + ky / 2, y2 - ky / 2, 0, (ky - 6) / 256)
            --RenderRect(p.pic, x1, x1 + ky, y2 - ky, y2)
            ui:RenderText("big_text", p.title2, (x1 + ky + x2) / 2, y2 - 25,
                    0.46, Color(a2 * 255, p.R, p.G, p.B), "centerpoint")
            ui:RenderText("title", p.subtitle, (x1 + ky + x2) / 2, y2 - ky + 14,
                    0.8, Color(a2 * 255, p.R, p.G, p.B), "centerpoint")

            SetRenderRect(x1, x2, y1 - offy, y2 - ky - offy - 1, x1, x2, y1, y2 - ky - 1)
            local tsize = 0.725
            do
                local s = t("effect")
                local w = self:GetTXTlen("title", tsize, s) + 12
                ui:RenderText("title", s, x1 + 6, _y - 5,
                        tsize, Color(a2 * 255, 255, 255, 255), "left", "top")
                for _, str in ipairs(sp:SplitText(p.detail, "\n")) do
                    ui:RenderTextWithCommand("title", str, x1 + w, _y - 5, tsize, a2 * 230, "left")
                    _y = _y - line_h
                end
            end--效果
            _y = _y - line_h
            do
                local s = t("chargeWay")
                local w = self:GetTXTlen("title", tsize, s) + 12
                ui:RenderText("title", s, x1 + 6, _y - 5, tsize, Color(a2 * 255, 230, 245, 220), "left", "top")
                local str = { t("charge1"), t("charge2"), t("charge3") }
                local id = p.type
                local c = p.charge_c
                if Ingame then
                    c = c * activeItem_lib.GetChargeEfficiency()
                end
                if id == 1 then
                    c = c * 60
                end
                local left = (1) / c
                if c == 0 then
                    left = 0
                end
                ui:RenderTextWithCommand("title", str[id]:format(left), x1 + w, _y - 5, tsize, a2 * 230, "left")
                _y = _y - line_h
                ui:RenderText("title", ("%s%d%%"):format(t("chargeEnergy"), p.energy_max * 100),
                        x1 + 6, _y - 5, tsize, Color(a2 * 255, 230, 245, 220), "left", "top")
                _y = _y - line_h * 2
            end

            do
                local s = t("cooperation")
                local w = self:GetTXTlen("title", tsize, s) + 12
                ui:RenderText("title", s, x1 + 6, _y - 5,
                        tsize, Color(a2 * 255, 230, 230, 255), "left", "top")
                for _, str in ipairs(sp:SplitText(p.collab_des, "\n")) do
                    ui:RenderTextWithCommand("title", str, x1 + w, _y - 5, tsize, a2 * 230, "left")
                    _y = _y - line_h
                end
            end--道具协同
            do
                _y = _y - line_h
                ui:RenderTextWithCommand("title", ("%s%s"):format(t("tag"), table.concat(p.tags, " | ")),
                        x1 + 6, _y - 5, tsize, a2 * 255, "left", "top")
                _y = _y - line_h * 2
                local s = t("unlockWay")
                local w = self:GetTXTlen("title", tsize, s) + 12
                ui:RenderText("title", s, x1 + 6, _y - 5, tsize, Color(a2 * 255, 245, 230, 220), "left", "top")
                for _, str in ipairs(sp:SplitText(p.unlock_des, "\n")) do
                    ui:RenderTextWithCommand("title", str, x1 + w, _y - 5, tsize, a2 * 230, "left")
                    _y = _y - line_h
                end
                s = t("appearCond")
                w = self:GetTXTlen("title", tsize, s) + 12
                ui:RenderText("title", s, x1 + 6, _y - 5, tsize, Color(a2 * 255, 189, 201, 252), "left", "top")
                for _, str in ipairs(sp:SplitText(p.cond_des, "\n")) do
                    ui:RenderTextWithCommand("title", str, x1 + w, _y - 5, tsize, a2 * 230, "left")
                    _y = _y - line_h
                end
            end--杂项
        else
            local tsize = 0.725
            local s = t("unlockWay")
            local w = self:GetTXTlen("title", tsize, s) + 12
            ui:RenderText("title", s, x1 + 6, _y - 5,
                    tsize, Color(a2 * 255, 245, 230, 220), "left", "top")
            for _, str in ipairs(sp:SplitText(p.unlock_des, "\n")) do
                ui:RenderTextWithCommand("title", str, x1 + w, _y - 5, tsize, a2 * 230, "left")
                _y = _y - line_h
            end
        end
        SetViewMode('ui')
        misc.RenderBrightOutline(x1, x2, y1, y2, 25, a2 * (sin(timer * 3) * 30 + 60), p.R, p.G, p.B)
    end
    return (y2 - ky - _y) / line_h--就直接在这里算得了
end

local valid
local info = Class(object, { frame = task.Do })
function info:init(text, w, h, ingame)
    if IsValid(valid) then
        if text == valid.text then
            object.RawDel(self)
            return
        else
            object.Del(valid)
        end
    end
    valid = self
    self.bound = false
    self.colli = false
    object.init(self, 480, 270, GROUP.GHOST, 0)
    self.text = text
    self.w = w or sp.string(text):GetLength() * 5 + 3
    self.h = h or 20
    self.alpha = 255
    self.ingame = ingame
    task.New(self, function()
        task.Wait(60)
        if valid == self then
            valid = nil
        end
        for i = 1, 60 do
            self.alpha = 255 - 255 * sin(i * 1.5)
            task.Wait()
        end
        Del(self)
    end)
end
function info:del()
    valid = nil
end
function info:render()
    if self.ingame then
        SetViewMode("ui")
    end
    SetImageState("white", "", self.alpha / 2, 0, 0, 0)
    RenderRect("white", self.x - self.w, self.x + self.w, self.y - self.h, self.y + self.h)
    ui:RenderText("title", self.text, self.x, self.y, 1, Color(self.alpha, 255, 255, 255), "centerpoint")
    if self.ingame then
        SetViewMode("world")
    end
end
_G.info = info

