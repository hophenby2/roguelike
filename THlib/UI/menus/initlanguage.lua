local M = stage.New("language", false, true)
--menu.SelectLanguage = M

function M:NewMenuUnit(name, event, unlock)
    local unit = {
        name = name,
        event = event,
        unlock = unlock or function()
            return true
        end,
        index = 0,
        cindex = 0,
        shake = 0,
    }
    return unit
end

function M:OtherMenuInit()
    self.other_menu = {
        alpha = 0,
        pos = 1,
        posi = 1,
        nd = 10,
        line_h = 32,
        line_w = 75,
        cx = screen.width / 2,
        list_y = screen.height / 2 + 64,
        cindex = 0,
        txtsize = 0.43,
        list = {
        },
        se_list = {},
    }
    for i, name in ipairs({ "简体中文", "English", }) do
        local unit = self:NewMenuUnit(name, function()
            setting.language = i
            switchLanguage(setting.language, true)
            --ResetLanguageCache()
            self.locked = true
            scoredata.first_language = true
            save_setting()
            task.New(self, function()
                for k = 1, 15 do
                    self.black = k / 15
                    task.Wait()
                end
                stage.Set("none", "init")
            end)
        end)
        table.insert(self.other_menu.list, unit)
    end
end

function M:OtherMenuFrame()
    local om = self.other_menu
    local mouse = ext.mouse
    local mx, my = mouse:get()
    local w = om.line_w
    if not self.locked then
        for i in ipairs(om.list) do
            if abs(my - (om.list_y - i * om.line_h)) < om.line_h / 2 then
                if i ~= om.pos then
                    om.pos = i
                end
                break
            end
        end
    end

    for i, s in ipairs(om.list) do
        if not self.locked then
            if i == om.pos and abs(mx - om.cx) < w then
                s.index = s.index + (-s.index + 1) * 0.1
                if mouse:isDown(1) then
                    if s.unlock() then
                        s.event()
                    else
                        s.shake = 20
                    end
                    om.cindex = 1
                    s.cindex = 1
                end
            else
                s.index = s.index + (-s.index) * 0.1
            end
        end
        s.shake = s.shake - s.shake * 0.1
        s.cindex = s.cindex + (-s.cindex) * 0.1
    end
    om.alpha = om.alpha + (-om.alpha + 1) * 0.1
    om.posi = om.posi + (-om.posi + om.pos) * 0.1
    om.cindex = om.cindex + (-om.cindex) * 0.1
end

function M:OtherMenuRender()
    local om = self.other_menu

    local lh = om.line_h
    local cx = om.cx
    local cy = (om.list_y - om.posi * lh)
    local alpha = om.alpha
    local w = om.line_w
    local oR, oG, oB = 255 - om.cindex * 150, 255, 255 - om.cindex * 150
    SetImageState("white", "", alpha * 150, oR, oG, oB)
    local smx, smy = 12 - om.cindex * 3, 3
    misc.RenderRoundedRectOutline(cx - w + smx, cx + w - smx, cy - lh / 2 + smy, cy + lh / 2 - smy, lh / 2 - smy, 2)

    for i, s in ipairs(om.list) do
        local unlock = s.unlock() and 1 or 0
        local x = om.cx + sin(s.shake * 78 + self.timer + i * 75) * 3
        local y = (om.list_y - i * lh)
        local sk = s.index
        local ck = s.cindex--点击时的反应
        local size = om.txtsize + sk * 0.05 + unlock * 0.1
        local r, g, b = 255, 255, 255
        if unlock == 0 then
            r, g, b = 250, 128, 114
        end
        r = r - ck * 100
        b = b - ck * 100
        RenderTTF3("title", s.name, x, y, 0, size, size, "mul+add",
                Color(alpha * (100 * unlock + 100 * sk), r, g, b), s.name, "centerpoint")


    end
end

function M:init()
    self:OtherMenuInit()
    self.text = {
        "请选择你的语言",
        "Please select your language",
    }
    self.locked = false
    self.black = 0
end
function M:frame()
    menu:Updatekey()
    self:OtherMenuFrame()
end
function M:render()
    SetViewMode("ui")
    self:OtherMenuRender()
    local scr = screen
    local cx, cy = scr.width / 2, screen.height / 2
    RenderTTF3("title", self.text[self.other_menu.pos], cx + 0, cy + 120, 0, 0.5, 0.5,
            "mul+add", Color(255, 255, 255, 255), "centerpoint")
    SetImageState("white", "", 255 * self.black, 0, 0, 0)
    Render("white", 0, scr.width, 0, scr.height)
end