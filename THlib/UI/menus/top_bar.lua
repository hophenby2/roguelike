local function t(str)
    return i18n("sth", str) or ""
end

top_bar_Class = plus.Class()
function top_bar_Class:init(menu, title, notIN)

    local path = "assets\\UI\\menus\\"
    LoadImageFromFile("top_bar_back", path .. "top_bar_back.png")
    SetImageCenter("top_bar_back", 0, 0)
    LoadImageGroupFromFile("top_bar_icon", path .. "top_bar_icon.png", true, 4, 4)

    self.menu = menu
    self.timer = 0
    self.alpha = 0
    self.locked = true
    if not notIN then
        self:flyIn()
    end
    self.buttons = {
        {
            event = function()
                New(SimpleChoose, self.menu, function()
                    task.New(self.menu, function()
                        mask_fader:Do("close")
                        task.Wait(15)
                        stage.QuitGame()
                    end)
                end, load(""), "Warning", t("warning_exitGame"), 150, 60)
            end,
            pic = "top_bar_icon1",
            size = 0.8,
            describe = t("exitGame")
        },
        {
            event = function()
                task.New(self, function()
                    self.locked = true
                    mask_fader:Do("close")
                    task.Wait(15)
                    stage.Set("none", "mission")
                end)
            end,
            pic = "top_bar_icon6",
            size = 0.8,
            describe = t("explore")
        },
        {
            event = function()
                task.New(self, function()
                    self.locked = true
                    mask_fader:Do("close")
                    task.Wait(15)
                    stage.Set("none", "handbook")
                end)
            end,
            pic = "top_bar_icon2",
            size = 0.8,
            describe = t("handbook")
        },
    }
    self.now_select = nil
    self.name_obj = {
        off_index = 0,
        selected = false,
        shake_index = 0,
        change_alpha = 0,
        add_count = 0,
    }
    self.player_name = scoredata.PlayerBrand
    self.title = title
end
function top_bar_Class:addReturnButton(event)
    table.insert(self.buttons, {
        event = event, pic = "top_bar_icon9",
        size = 0.8,
        describe = t("returnToPrevious")
    })
end
function top_bar_Class:flyIn()
    task.New(self, function()
        for i = 1, 25 do
            self.alpha = task.SetMode[2](i / 25)
            task.Wait()
        end
        self.locked = false
    end)
end
function top_bar_Class:flyOut()
    self.locked = true
    task.New(self, function()
        for i = 1, 25 do
            self.alpha = 1 - task.SetMode[1](i / 25)
            task.Wait()
        end
    end)
end
function top_bar_Class:frame()
    task.Do(self)
    self.timer = self.timer + 1
    if self.locked then
        return
    end
    --menu:Updatekey()
    local mouse = ext.mouse

    local A = self.alpha
    local Y = 540 + 60 - 60 * A
    local H = 28
    do
        local flag
        for i, p in ipairs(self.buttons) do
            local x, y = 960 - 14 - 28 * (i - 1), Y - 14
            local w, h = H / 2, H / 2
            if sp.math.PointBoundCheck(mouse.x, mouse.y, x - w, x + w, y - h, y + h) then
                if self.now_select ~= p then
                    self.now_select = p
                    PlaySound("select00")
                end
                flag = true
                break
            end
        end
        if not flag then
            self.now_select = nil
        end

        if self.now_select then
            self.now_select.size = self.now_select.size + (-self.now_select.size + 1) * 0.1
            if mouse:isUp(1) then
                PlaySound("ok00")
                self.now_select.event()
            end
        end

        for i, n in ipairs(self.buttons) do
            if i ~= self.pos then
                n.size = n.size + (-n.size + 0.8) * 0.1
            end
        end
    end--按钮相关
    do
        local x, y = 480, Y
        local nobj = self.name_obj
        if Dist(mouse.x, mouse.y, x, y) < 32 then
            nobj.off_index = nobj.off_index + (-nobj.off_index + 1) * 0.1
            if not nobj.selected then
                nobj.selected = true
                PlaySound("select00")
            end
            if mouse:isUp(1) then
                task.New(self, function()
                    local n = 30
                    for i = 1, n do
                        nobj.shake_index = sin(i / n * 360 * 3) * 5 * (1 - task.SetMode[2](i / n))
                        task.Wait()
                    end
                end)
                PlaySound("ok00")
            end
        else
            nobj.off_index = nobj.off_index + (-nobj.off_index) * 0.1
            nobj.selected = false
        end
    end--name相关
end
function top_bar_Class:render()
    SetViewMode("ui")
    local A = self.alpha
    local Y = 540 + 60 - 60 * A
    local H = 28
    Render("top_bar_back", 0, Y)
    ui:RenderText("pretty", self.title, 40, Y - H / 2,
            0.4, Color(255, 210, 210, 210), "left", "vcenter")
    do
        for i, p in ipairs(self.buttons) do
            local x, y = 960 - 14 - 28 * (i - 1), Y - 14
            local w, h = 28 / 2, H / 2
            local size = 28 / 64 * p.size
            local index = (p.size - 0.8) / 0.2
            ui:RenderText("pretty", p.describe, 960 - 5, Y - H - 5,
                    0.25, Color(index * 200, 255, 255, 255), "right", "top")
            SetImageState("white", "", 70 + index * 70, 0, index * 200, 0)
            RenderRect("white", x - w, x + w, y + h, y - h)
            SetImageState("white", "", 255, 255, 255, 255)
            misc.RenderOutLine("white", x - w, x + w, y + h, y - h, 1, 1)
            SetImageState(p.pic, "", 120 + index * 120, 255, 255, 255)
            Render(p.pic, x, y, 0, size)
        end
    end--按钮相关
    do
        local nobj = self.name_obj
        local index = nobj.off_index
        local shake = nobj.shake_index
        local x, y = 480 + shake, Y
        local wht = 210 + index * 40
        local playername = self.player_name
        ui:RenderText("pretty", playername, x, y - 4,
                0.37 + index * 0.01, Color(255, wht, wht, wht), "center")
    end--abp相关

end
function top_bar_Class:SetShowAddMoney(count)
    local _money = self.money
    _money.addcount = count
    if _money.addcount ~= 0 then
        task.New(self, function()
            for i = 1, 30 do
                _money.add_alpha = task.SetMode[2](i / 30)
                task.Wait()
            end
            task.Wait(120)
            for i = 1, 30 do
                _money.add_alpha = 1 - task.SetMode[2](i / 30)
                task.Wait()
            end
        end)
    end
end