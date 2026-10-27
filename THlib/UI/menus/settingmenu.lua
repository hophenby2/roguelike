local function all_setting_default(self)
    local cs = setting
    local ds = default_setting
    cs.bgmvolume = ds.bgmvolume
    cs.sevolume = ds.sevolume

    --cs.notespeed = ds.notespeed
    cs.rdQual = ds.rdQual

    cs.windowed = ds.windowed
    cs.vsync = ds.vsync
    cs.auto_hide_title_bar = ds.auto_hide_title_bar
    cs.language = ds.language

    cs.displayBG = ds.displayBG
    for k in pairs(ds.keys) do
        cs.keys[k] = ds.keys[k]
    end
    for _, m1 in ipairs(self.menus) do
        for _, m2 in ipairs(m1.setting_item) do
            if m2.otherfunction then
                m2.otherfunction()
            end
        end
    end
end

local function _t(str)
    return i18n("sth", str) or ""
end

local line = Class(object, { frame = task.Do })
function line:init(x, y, wid)
    self.x, self.y = x, y
    self.bound = false
    self.alpha = 1
    self.length = 0
    self.width = wid
    self.layer = LAYER.TOP + 5
    task.New(self, function()
        for i = 1, 30 do
            self.alpha = 1 - task.SetMode[1](i / 30)
            self.length = task.SetMode[2](i / 30)
            task.Wait()
        end
        Del(self)
    end)
end
function line:render()
    SetViewMode("ui")
    SetImageState("white", "", 255 * self.alpha, 255, 227, 132)
    RenderRect("white", self.x - self.length * self.width, self.x + self.length * self.width, self.y + 1, self.y - 1)
end

local setting_bar = plus.Class()
---@param display_way fun(t:number):string
function setting_bar:init(display_name, set_name, small_index, big_index, min, max, min_unit, x1, x2, y1, y2, display_way, otherfunction)
    self.display_name = display_name
    self.name = set_name
    self.small = small_index
    self.big = big_index
    self.max = max
    self.min = min
    self.min_unit = min_unit
    self.choosing = false
    self.otherfunction = otherfunction or load("")
    if x1 > x2 then
        x1, x2 = x2, x1
    end
    if y1 > y2 then
        y1, y2 = y2, y1
    end
    self.x1, self.x2, self.y1, self.y2 = x1, x2, y1, y2
    self.display_way = display_way
    self.locked = true
    if setting[self.name] == nil then
        setting[self.name] = default_setting[self.name]
    end
end
function setting_bar:frame()
    if not self.locked then
        if self.choosing then
            local mouse = ext.mouse
            local key = GetLastKey()
            local value = 0
            if key == setting.keys.left then
                value = -1
            end
            if key == setting.keys.right then
                value = 1
            end
            if value ~= 0 then
                value = value * (GetKeyState(KEY.SHIFT) and self.big or self.small)
                setting[self.name] = clamp(setting[self.name] + value, self.min, self.max)
                PlaySound('select00')
                self.otherfunction()
            end
            if key == KEY.R then
                setting[self.name] = default_setting[self.name]
                self.otherfunction()
            end
            local x1, x2, y1, y2 = self.x1, self.x2, self.y1, self.y2
            local width = x2 - x1
            local height = y2 - y1
            if mouse:isPress(1) then
                if sp.math.PointBoundCheck(mouse.x, mouse.y, x1 + width / 12 - 4, x2 - width / 12 + 4, y1 + height / 3 - 8, y1 + height / 3 + 8) then
                    self.press_flag = true
                end
            else
                self.press_flag = false
            end
            if self.press_flag then
                local _x1, _x2 = x1 + width / 12, x2 - width / 12
                local index = (_x2 - _x1) / (self.max - self.min)
                local part = index * self.min_unit
                local nx = self.align(mouse.x, _x1, part)
                local before = int(setting[self.name])
                local after = int(self.min + (nx - _x1) / (_x2 - _x1) * (self.max - self.min))
                if before ~= after then
                    setting[self.name] = clamp(after, self.min, self.max)
                    PlaySound("select00")
                    self.otherfunction()
                end
            end
        end
    end
end
function setting_bar:render(alpha)
    if alpha ~= 0 then
        local x1, x2, y1, y2 = self.x1, self.x2, self.y1, self.y2
        local width = x2 - x1
        local height = y2 - y1
        local r, g, b
        if self.choosing then
            SetImageState("white", "", alpha * 78, 255, 227, 132)
            r, g, b = 255, 255, 255
        else
            SetImageState("white", "", alpha * 78, 0, 0, 0)
            r, g, b = 180, 180, 180
        end
        RenderRect("white", x1 - 1, x2 + 1, y1 - 1, y2 + 1)
        RenderRect("white", x1 + 1, x2 - 1, y1 + 1, y2 - 1)
        SetImageState("white", "", alpha * 255, r, g, b)
        RenderRect("white", x1 + width / 12 - 1, x2 - width / 12 + 1, y1 + height / 3 - 1.4, y1 + height / 3 + 1.4)
        SetImageState("white", "", alpha * 200, 10, 10, 10)
        RenderRect("white", x1 + width / 12, x2 - width / 12, y1 + height / 3 - 0.7, y1 + height / 3 + 0.7)

        local percent = (setting[self.name] - self.min) / (self.max - self.min)
        SetImageState("white", "", alpha * 255, r, g, b)
        misc.SectorRender(x1 + width / 12 + (x2 - x1 - width / 6) * percent, y1 + height / 3, 0, 4, 0, 360, 10)
        ui:RenderText("pretty_title", self.display_name, x1 + width / 12, y1 + height / 3 * 2,
                height / 3 * 1.8 / 32, Color(alpha * 255, r, g, b), "left", "vcenter")
        ui:RenderText("pretty_title", self.display_way(setting[self.name]), x2 - width / 12, y1 + height / 3 * 2,
                height / 3 * 1.8 / 32, Color(alpha * 255, r, g, b), "right", "vcenter")
    end
end
function setting_bar.align(x, start, part)
    local align = (x - start) % part
    if abs(-align) > abs(part - align) then
        x = x + part - align
    else
        x = x - align
    end--对齐
    return x
end

local setting_bar2 = plus.Class()
---@param display_way fun(t:number):string
function setting_bar2:init(display_name, set_name, small_index, big_index, min, max, min_unit, x1, x2, y1, y2, display_way, otherfunction)
    self.display_name = display_name
    self.name = set_name
    self.small = small_index
    self.big = big_index
    self.max = max
    self.min = min
    self.min_unit = min_unit
    self.choosing = false
    self.otherfunction = otherfunction or load("")
    if x1 > x2 then
        x1, x2 = x2, x1
    end
    if y1 > y2 then
        y1, y2 = y2, y1
    end
    self.x1, self.x2, self.y1, self.y2 = x1, x2, y1, y2
    self.display_way = display_way
    self.locked = true
    if setting[self.name] == nil then
        setting[self.name] = default_setting[self.name]
    end
end
function setting_bar2:frame()
    if not self.locked then
        if self.choosing then
            local key = GetLastKey()
            local value = 0
            if key == setting.keys.left then
                value = -1
            end
            if key == setting.keys.right then
                value = 1
            end
            if value ~= 0 then
                setting[self.name] = sp:TweakValue(setting[self.name] + value, self.max, 1)
                PlaySound('select00')
                self.otherfunction()
            end
            if key == KEY.R then
                setting[self.name] = default_setting[self.name]
                self.otherfunction()
            end
            local mouse = ext.mouse
            local x1, x2, y1, y2 = self.x1, self.x2, self.y1, self.y2
            local width = x2 - x1
            local height = y2 - y1
            if mouse:isUp(1) then
                if sp.math.PointBoundCheck(mouse.x, mouse.y, x1 + width / 12, x2 - width / 12, y1 + height / 6, y2 - height / 6) then
                    setting[self.name] = sp:TweakValue(setting[self.name] + 1, self.max, 1)
                    self.otherfunction()
                    PlaySound('select00')
                end
            end
        end
    end
end
function setting_bar2:render(alpha)
    if alpha ~= 0 then
        local x1, x2, y1, y2 = self.x1, self.x2, self.y1, self.y2
        local width = x2 - x1
        local height = y2 - y1
        local r, g, b
        if self.choosing then
            SetImageState("white", "", alpha * 78, 255, 227, 132)
            r, g, b = 255, 255, 255
        else
            SetImageState("white", "", alpha * 78, 0, 0, 0)
            r, g, b = 180, 180, 180
        end
        RenderRect("white", x1 - 1, x2 + 1, y1 - 1, y2 + 1)
        RenderRect("white", x1 + 1, x2 - 1, y1 + 1, y2 - 1)
        ui:RenderText("pretty", self.display_name, x1 + width / 12, y1 + height / 2,
                height * 0.7 / 80, Color(alpha * 255, r, g, b), "left", "vcenter")
        ui:RenderText("pretty", self.display_way(setting[self.name]), x2 - width / 12, y1 + height / 2,
                height * 0.7 / 80, Color(alpha * 255, r, g, b), "right", "vcenter")
    end
end

local setting_button = plus.Class()
function setting_button:init(display_name, set_name, x1, x2, y1, y2, opposite, otherfunction)
    self.display_name = display_name
    self.name = set_name
    if x1 > x2 then
        x1, x2 = x2, x1
    end
    if y1 > y2 then
        y1, y2 = y2, y1
    end
    self.x1, self.x2, self.y1, self.y2 = x1, x2, y1, y2
    self.choosing = false
    self.locked = true
    self.opposite = opposite
    self.otherfunction = otherfunction or load("")
    if setting[self.name] == nil then
        setting[self.name] = default_setting[self.name]
    end
end
function setting_button:frame()
    if not self.locked then
        if self.choosing then
            local mouse = ext.mouse
            local key = GetLastKey()
            if key == KEY.LEFT or key == KEY.RIGHT or key == KEY.Z or key == KEY.ENTER then
                setting[self.name] = not setting[self.name]
                self.otherfunction()
                PlaySound('select00')
            end
            if key == KEY.R then
                setting[self.name] = default_setting[self.name]
                self.otherfunction()
            end
            local x1, x2, y1, y2 = self.x1, self.x2, self.y1, self.y2
            local width = x2 - x1
            local height = y2 - y1
            if mouse:isUp(1) then
                if sp.math.PointBoundCheck(mouse.x, mouse.y, x2 - width / 12 - height / 3 * 2, x2 - width / 12, y1 + height / 6, y2 - height / 6) then
                    setting[self.name] = not setting[self.name]
                    self.otherfunction()
                    PlaySound('select00')
                end
            end
        end
    end
end
function setting_button:render(alpha)
    if alpha ~= 0 then
        local x1, x2, y1, y2 = self.x1, self.x2, self.y1, self.y2
        local width = x2 - x1
        local height = y2 - y1
        local r, g, b
        if self.choosing then
            SetImageState("white", "", alpha * 78, 255, 227, 132)
            r, g, b = 255, 255, 255
        else
            SetImageState("white", "", alpha * 78, 0, 0, 0)
            r, g, b = 180, 180, 180
        end
        RenderRect("white", x1 - 1, x2 + 1, y1 - 1, y2 + 1)
        RenderRect("white", x1 + 1, x2 - 1, y1 + 1, y2 - 1)
        ui:RenderText("pretty", self.display_name, x1 + width / 12, y1 + height / 2,
                height * 0.7 / 80, Color(alpha * 255, r, g, b), "left", "vcenter")
        SetImageState("white", "", alpha * 255, 0, 0, 0)
        misc.SectorRender(x2 - width / 12 - height / 3 + 1, y1 + height / 2 - 1, height / 3, height / 2.7, 0, 360, 6)
        SetImageState("white", "", alpha * 255, r, g, b)
        misc.SectorRender(x2 - width / 12 - height / 3, y1 + height / 2, height / 3, height / 2.7, 0, 360, 6)
        local flag
        if self.opposite then
            flag = not setting[self.name]
        else
            flag = setting[self.name]
        end
        if flag then
            SetImageState("white", "", alpha * 255, 0, 0, 0)
            misc.SectorRender(x2 - width / 12 - height / 3 + 1, y1 + height / 2 - 1, 0, height / 4, 0, 360, 6)
            if self.choosing then
                SetImageState("white", "", alpha * 255, 189, 252, 201)
            else
                SetImageState("white", "", alpha * 255, 189 / 2, 252 / 2, 201 / 2)
            end
            misc.SectorRender(x2 - width / 12 - height / 3, y1 + height / 2, 0, height / 4, 0, 360, 6)

        end
    end
end

local setting_key = plus.Class()
function setting_key:init(display_name, setKey, x1, x2, y1, y2)
    self.display_name = display_name
    self.set = setKey
    if x1 > x2 then
        x1, x2 = x2, x1
    end
    if y1 > y2 then
        y1, y2 = y2, y1
    end
    self.x1, self.x2, self.y1, self.y2 = x1, x2, y1, y2
    self.choosing = false
    self.editing = false
    self.locked = true
    self.keyNameList = KeyCodeToName()


end
function setting_key:frame()
    if not self.locked then
        if self.choosing then
            local mouse = ext.mouse
            local key = GetLastKey()
            if self.editing then
                if key ~= KEY.NULL then
                    if key == KEY.ESCAPE then
                        self.editing = false
                        settingmenu.editing = false
                        PlaySound('cancel00')
                    else
                        local flag2 = true
                        for _, kn in ipairs(self.set) do
                            setting.keys[kn] = key
                        end
                        PlaySound('ok00')
                        self.editing = false
                        settingmenu.editing = false

                    end

                end
            else
                if key == KEY.Z or key == KEY.ENTER then
                    self.editing = true
                    PlaySound('select00')
                end
                if key == KEY.R then
                    for _, kn in ipairs(self.set) do
                        setting.keys[kn] = default_setting.keys[kn]
                    end
                end
                local x1, x2, y1, y2 = self.x1, self.x2, self.y1, self.y2
                if mouse:isUp(1) then
                    if sp.math.PointBoundCheck(mouse.x, mouse.y, x1, x2, y1, y2) then
                        self.editing = true
                        settingmenu.editing = true
                        PlaySound('select00')
                    end
                end
            end
        end
    end
end
function setting_key:render(alpha, timer)
    if alpha ~= 0 then
        local x1, x2, y1, y2 = self.x1, self.x2, self.y1, self.y2
        local width = x2 - x1
        local height = y2 - y1
        local r, g, b
        if self.choosing then
            SetImageState("white", "", alpha * 78, 255, 227, 132)
            r, g, b = 255, 255, 255
        else
            SetImageState("white", "", alpha * 78, 0, 0, 0)
            r, g, b = 180, 180, 180
        end
        RenderRect("white", x1 - 1, x2 + 1, y1 - 1, y2 + 1)
        RenderRect("white", x1 + 1, x2 - 1, y1 + 1, y2 - 1)
        ui:RenderText("pretty", self.display_name, x1 + width / 12, y1 + height / 2,
                height * 0.7 / 80, Color(alpha * 255, r, g, b), "left", "vcenter")
        local dname = self.keyNameList[setting.keys[self.set[1]]]
        if timer % 60 < 30 and self.editing then
            dname = "<" .. dname .. ">"
        else
            dname = "  " .. dname .. "  "
        end
        ui:RenderText("pretty", dname, x2 - width / 12, y1 + height / 2,
                height * 0.7 / 80, Color(alpha * 255, r, g, b), "right", "vcenter")
    end
end

local small_menu = plus.Class()
function small_menu:init(display_name, x1, x2, y1, y2, setting_item)
    self.display_name = display_name
    self.setting_item = setting_item
    if x1 > x2 then
        x1, x2 = x2, x1
    end
    if y1 > y2 then
        y1, y2 = y2, y1
    end
    self.x1, self.x2, self.y1, self.y2 = x1, x2, y1, y2
    self.choosing = false
    self.item_alpha = 0
end
function small_menu:frame()
    if self.choosing then
        self.item_alpha = min(self.item_alpha + max((-self.item_alpha + 1) * 0.1, 0.05), 1)
        for _, item in ipairs(self.setting_item) do
            item.locked = false
            item:frame()
        end
    else
        self.item_alpha = max(self.item_alpha + min((-self.item_alpha) * 0.1, -0.05), 0)
        for _, item in ipairs(self.setting_item) do
            item.locked = true
        end
    end
end
function small_menu:render(alpha, timer)
    if alpha ~= 0 then
        local x1, x2, y1, y2 = self.x1, self.x2, self.y1, self.y2
        local width = x2 - x1
        local height = y2 - y1
        local r, g, b
        if self.choosing then
            SetImageState("white", "", alpha * 78, 189, 252, 201)
            r, g, b = 255, 255, 255
        else
            SetImageState("white", "", alpha * 78, 0, 0, 0)
            r, g, b = 180, 180, 180
        end
        RenderRect("white", x1, x2, y1, y2)
        RenderRect("white", x1 - 1, x2 + 1, y1 - 1, y2 + 1)
        ui:RenderText("pretty", self.display_name, x1 + width / 2, y1 + height / 2,
                height * 0.9 / 80, Color(alpha * 255, r, g, b), "centerpoint")
        for _, item in ipairs(self.setting_item) do
            item:render(self.item_alpha * alpha, timer)
        end
    end
end

local setting_language = plus.Class()
function setting_language:init(display_name, x1, x2, y1, y2, set_func, open_cond)
    self.display_name = display_name
    self.set_func = set_func
    self.open_cond = open_cond
    self.x1, self.x2, self.y1, self.y2 = x1, x2, y1, y2--外部设置
    self.choosing = false
    self.locked = true
    self.index = 0
end
function setting_language:frame()
    if not self.locked then
        if self.choosing then
            local mouse = ext.mouse
            local key = GetLastKey()
            if key == KEY.SPACE or key == KEY.ENTER then
                self.set_func()
                PlaySound('ok00')
            end
            local x1, x2, y1, y2 = self.x1, self.x2, self.y1, self.y2
            local width = x2 - x1
            local height = y2 - y1
            if mouse:isUp(1) then
                if sp.math.PointBoundCheck(mouse.x, mouse.y, x2 - width / 12 - height / 3 * 2, x2 - width / 12, y1 + height / 6, y2 - height / 6) then
                    self.set_func()
                    PlaySound('ok00')
                end
            end
        end
        local _index = self.choosing and 1 or 0
        self.index = self.index + (-self.index + _index) * 0.1
    end
end
function setting_language:render(alpha)
    if alpha ~= 0 then
        local x1, x2, y1, y2 = self.x1, self.x2, self.y1, self.y2
        local width = x2 - x1
        local height = y2 - y1
        local blk = 180 + 75 * self.index
        local R, G, B = 255 * self.index, 227 * self.index, 132 * self.index
        SetImageState("white", "", alpha * 78, R, G, B)
        RenderRect("white", x1 - 1, x2 + 1, y1 - 1, y2 + 1)
        RenderRect("white", x1 + 1, x2 - 1, y1 + 1, y2 - 1)
        ui:RenderText("big_text", self.display_name, x1 + width / 12, y1 + height / 2,
                height * 0.7 / 80, Color(alpha * 255, blk, blk, blk), "left", "vcenter")
        SetImageState("white", "", alpha * 255, 0, 0, 0)
        misc.SectorRender(x2 - width / 12 - height / 3 + 1, y1 + height / 2 - 1, height / 3, height / 2.7, 0, 360, 20)
        SetImageState("white", "", alpha * 255, blk, blk, blk)
        misc.SectorRender(x2 - width / 12 - height / 3, y1 + height / 2, height / 3, height / 2.7, 0, 360, 20)
        if self.open_cond() then
            SetImageState("white", "", alpha * 255, 0, 0, 0)
            misc.SectorRender(x2 - width / 12 - height / 3 + 1, y1 + height / 2 - 1, 0, height / 4, 0, 360, 20)
            local _r, _g, _b = 189 * (self.index * 0.5 + 0.5), 252 * (self.index * 0.5 + 0.5), 201 * (self.index * 0.5 + 0.5)
            SetImageState("white", "", alpha * 255, _r, _g, _b)
            misc.SectorRender(x2 - width / 12 - height / 3, y1 + height / 2, 0, height / 4, 0, 360, 20)

        end
    end
end

---@param display_way fun(t:number):string
local function Newsetting_bar(display_name, set_name, small_index, big_index, min, max, min_unit, x1, x2, y1, y2, display_way, otherfunction)
    return setting_bar(display_name, set_name, small_index, big_index, min, max, min_unit, x1, x2, y1, y2, display_way, otherfunction)
end
---@param display_way fun(t:number):string
local function Newsetting_bar2(display_name, set_name, small_index, big_index, min, max, min_unit, x1, x2, y1, y2, display_way, otherfunction)
    return setting_bar2(display_name, set_name, small_index, big_index, min, max, min_unit, x1, x2, y1, y2, display_way, otherfunction)
end

local function Newsetting_button(display_name, set_name, x1, x2, y1, y2, opposite, otherfunction)
    return setting_button(display_name, set_name, x1, x2, y1, y2, opposite, otherfunction)
end

local function Newsetting_key(display_name, setKey, x1, x2, y1, y2)
    return setting_key(display_name, setKey, x1, x2, y1, y2)
end

local function Newsmall_menu(display_name, x1, x2, y1, y2, setting_item)
    return small_menu(display_name, x1, x2, y1, y2, setting_item)
end

local function Newsetting_language(display_name, x1, x2, y1, y2, set_func, open_cond)
    return setting_language(display_name, x1, x2, y1, y2, set_func, open_cond)
end

settingmenu = stage.New("setting", false, true)
function settingmenu:init()
    self.top_bar = top_bar_Class(self, _t("setting"))
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
    self.locked = true
    self.pos1 = 1
    self.pos2 = 1
    self.x1, self.x2, self.y1, self.y2 = 100, 860, 27, 470
    self.dpline = 270
    self.h1, self.h2 = 70, 40
    local x1, x2, y1, y2 = self.x1, self.x2, self.y1, self.y2
    local _line = self.dpline
    local h1, h2 = self.h1, self.h2
    local _, maxH = GetFullScreenResolution()
    local language_setting_item = {}
    local lang_name = { "中文", "English" }
    for i = 1, 2 do
        language_setting_item[i] = Newsetting_language(lang_name[i], _line, x2, y2 - h2 * i, y2 - h2 * (i - 1), function()
            if setting.language ~= i then
                setting.language = i
                save_setting()
                switchLanguage(setting.language)
                stage.Restart()
            end
        end, function()
            return setting.language == i
        end)
    end
    self.menus = {
        Newsmall_menu(_t("sound"), x1, _line, y2 - h1 * 1, y2 - h1 * 0, {
            Newsetting_bar(_t("bgmvolume"), "bgmvolume", 5, 10,
                    0, 100, 1, _line, x2, y2 - h2 * 1, y2 - h2 * 0, function(t)
                        return ("%d%%"):format(t)
                    end),
            Newsetting_bar(_t("sevolume"), "sevolume", 5, 10,
                    0, 100, 1, _line, x2, y2 - h2 * 2, y2 - h2 * 1, function(t)
                        return ("%d%%"):format(t)
                    end),
        }),
        Newsmall_menu(_t("graphics"), x1, _line, y2 - h1 * 2, y2 - h1 * 1, {
            Newsetting_bar(_t("resolution"), "reso_value", 5, 10,
                    maxH / 2, maxH, 1, _line, x2, y2 - h2 * 1, y2 - h2 * 0, function(t)
                        return ("%d x %d"):format(setting.reso_value * 16 / 9, setting.reso_value)
                    end, function()
                        setting.reso_value = int(setting.reso_value)
                        setting.resx = int(setting.reso_value * 16 / 9)
                        setting.resy = int(setting.reso_value)
                        ChangeVideoMode2(setting)
                        ResetScreen()--Lscreen
                        ResetUI()
                    end),
            Newsetting_button(_t("fullscreen"), "windowed", _line, x2, y2 - h2 * 2, y2 - h2 * 1,
                    true, function()
                        ChangeVideoMode2(setting)
                        ResetScreen()--Lscreen
                        ResetUI()
                    end),
            Newsetting_button(_t("vsync"), "vsync", _line, x2, y2 - h2 * 3, y2 - h2 * 2,
                    nil, function()
                        ChangeVideoMode2(setting)
                    end),
            Newsetting_button(_t("auto_hide_bar"), "auto_hide_title_bar", _line, x2, y2 - h2 * 4, y2 - h2 * 3,
                    nil, function()
                        local Window = require("lstg.Window")
                        local main_window = Window.getMain()
                        local window_win11_ext = main_window:queryInterface("lstg.Window.Windows11Extension")
                        if window_win11_ext then
                            window_win11_ext:setTitleBarAutoHidePreference(setting.auto_hide_title_bar)
                        end
                        ChangeVideoMode2(setting)
                        ResetScreen()--Lscreen
                        ResetUI()
                    end),
        }),
        Newsmall_menu(_t("game"), x1, _line, y2 - h1 * 3, y2 - h1 * 2, {
            Newsetting_button(_t("3Dbackground"), "displayBG", _line, x2, y2 - h2 * 1, y2 - h2 * 0),
            Newsetting_bar(_t("renderQual"), "rdQual", 1, 1,
                    1, 5, 1, _line, x2, y2 - h2 * 2, y2 - h2 * 1, function(t)
                        return ("%d%%"):format(t / 5 * 100)
                    end)
        }),
        Newsmall_menu(_t("key"), x1, _line, y2 - h1 * 4, y2 - h1 * 3, {
            Newsetting_key(_t("keyup"), { "up" }, _line, x2, y2 - h2 * 1, y2 - h2 * 0),
            Newsetting_key(_t("keydown"), { "down" }, _line, x2, y2 - h2 * 2, y2 - h2 * 1),
            Newsetting_key(_t("keyleft"), { "left" }, _line, x2, y2 - h2 * 3, y2 - h2 * 2),
            Newsetting_key(_t("keyright"), { "right" }, _line, x2, y2 - h2 * 4, y2 - h2 * 3),
            Newsetting_key(_t("keyslow"), { "slow" }, _line, x2, y2 - h2 * 5, y2 - h2 * 4),
            Newsetting_key(_t("keyshoot"), { "shoot" }, _line, x2, y2 - h2 * 6, y2 - h2 * 5),
            Newsetting_key(_t("keyspell"), { "spell" }, _line, x2, y2 - h2 * 7, y2 - h2 * 6),
            Newsetting_key(_t("keyspecial"), { "special" }, _line, x2, y2 - h2 * 8, y2 - h2 * 7),
            Newsetting_key(_t("keychange"), { "change" }, _line, x2, y2 - h2 * 9, y2 - h2 * 8),
            Newsetting_key(_t("keypass"), { "pass" }, _line, x2, y2 - h2 * 10, y2 - h2 * 9),

        }),
        Newsmall_menu(_t("language"), x1, _line, y2 - h1 * 5, y2 - h1 * 4, language_setting_item),
    }
    self.menus[self.pos1].choosing = true
    self.menus[self.pos1].setting_item[self.pos2].choosing = true
    self.curb_size = 0
    self.maxb_size = 0
    self.timer = 0
    self.editing = false

    task.New(self, function()
        task.Wait(30)
        while GetKeyState(KEY.Z) do
            task.Wait()
        end
        self.locked = false
    end)
end
function settingmenu:frame()
    self.timer = self.timer + 1
    SetSEVolume(setting.sevolume / 100)
    SetBGMVolume2(setting.bgmvolume / 100)

    self.curb_size = self.curb_size + (-self.curb_size + self.maxb_size) * 0.12
    if self.locked then
        return
    end
    menu:Updatekey()
    local mouse = ext.mouse
    save_setting()
    --loadConfigure()

    if mouse._wheel ~= 0 and not self.editing then

        self.menus[self.pos1].choosing = false
        self.menus[self.pos1].setting_item[self.pos2].choosing = false
        self.pos2 = self.pos2 - sign(mouse._wheel)
        if self.pos2 == 0 then
            self.pos1 = sp:TweakValue(self.pos1 - 1, #self.menus, 1)
            self.pos2 = #self.menus[self.pos1].setting_item
        end
        if self.pos2 == #self.menus[self.pos1].setting_item + 1 then
            self.pos1 = sp:TweakValue(self.pos1 + 1, #self.menus, 1)
            self.pos2 = 1
        end
        self.menus[self.pos1].choosing = true
        self.menus[self.pos1].setting_item[self.pos2].choosing = true
        PlaySound("select00")
        task.New(self, function()
            for i = 1, 30 do
                self.tri_alpha = sin(i * 3)
                task.Wait()
            end
        end)
    end
    local x1, x2, y1, y2 = self.x1, self.x2, self.y1, self.y2
    local _line = self.dpline
    local h1, h2 = self.h1, self.h2
    if mouse:isDown(1) and not self.editing then
        local x, y = mouse.x, mouse.y
        if sp.math.PointBoundCheck(x, y, x1, x2, y1, y2) then
            if x < _line then
                for p = 1, #self.menus do
                    if y > y2 - p * h1 and y < y2 - (p - 1) * h1 then
                        self.menus[self.pos1].choosing = false
                        self.menus[self.pos1].setting_item[self.pos2].choosing = false
                        self.pos1 = p
                        self.pos2 = clamp(self.pos2, 1, #self.menus[self.pos1].setting_item)
                        self.menus[self.pos1].choosing = true
                        self.menus[self.pos1].setting_item[self.pos2].choosing = true
                        PlaySound("select00")
                        break
                    end
                end
            else
                for p = 1, #self.menus[self.pos1].setting_item do
                    if y > y2 - p * h2 and y < y2 - (p - 1) * h2 then
                        self.menus[self.pos1].choosing = false
                        self.menus[self.pos1].setting_item[self.pos2].choosing = false
                        self.pos2 = p
                        self.menus[self.pos1].choosing = true
                        self.menus[self.pos1].setting_item[self.pos2].choosing = true
                        PlaySound("select00")
                        break
                    end
                end
            end
        end

    end
    if menu:keyUp() and not self.editing then
        self.menus[self.pos1].choosing = false
        self.menus[self.pos1].setting_item[self.pos2].choosing = false
        self.pos2 = self.pos2 - 1
        if self.pos2 == 0 then
            self.pos1 = sp:TweakValue(self.pos1 - 1, #self.menus, 1)
            self.pos2 = #self.menus[self.pos1].setting_item
        end
        self.menus[self.pos1].choosing = true
        self.menus[self.pos1].setting_item[self.pos2].choosing = true
        task.New(self, function()
            for i = 1, 10 do
                self.tri_alpha = sin(i * 9)
                task.Wait()
            end
        end)
        PlaySound('select00', 0.3)
    end
    if menu:keyDown() and not self.editing then
        self.menus[self.pos1].choosing = false
        self.menus[self.pos1].setting_item[self.pos2].choosing = false
        self.pos2 = self.pos2 + 1
        if self.pos2 == #self.menus[self.pos1].setting_item + 1 then
            self.pos1 = sp:TweakValue(self.pos1 + 1, #self.menus, 1)
            self.pos2 = 1
        end
        self.menus[self.pos1].choosing = true
        self.menus[self.pos1].setting_item[self.pos2].choosing = true
        task.New(self, function()
            for i = 1, 10 do
                self.tri_alpha = sin(i * 9)
                task.Wait()
            end
        end)
        PlaySound('select00', 0.3)
    end
    if sp.math.PointBoundCheck(mouse.x, mouse.y, x1 + 12, _line - 12, y2 + 5, y2 + 25) then
        self.maxb_size = 1
        if mouse:isUp(1) then
            all_setting_default(self)
            PlaySound("select00")
        end
    else
        self.maxb_size = 0
    end
    if not self.editing then
        self.top_bar:frame()
        if menu:keyNo() then
            PlaySound("cancel00")
            self.exit_func()
        end
    end
    for _, item in ipairs(self.menus) do
        item:frame()
    end
end
function settingmenu:render()
    ui:DrawBack(1, self.timer)
    for _, item in ipairs(self.menus) do
        item:render(1, self.timer)
    end
    local x1, x2, y1, y2 = self.x1, self.x2, self.y1, self.y2
    local _line = self.dpline
    SetImageState("white", "", 255, 255, 255, 255)
    misc.RenderOutLine("white", x1, x2, y2, y1, 0, 2)
    RenderRect("white", _line - 1, _line + 1, y2, y1)
    ui:RenderText("pretty_title", _t("settingOther"),
            x2 - 1, y2 + 2, 0.8, Color(255, 200, 200, 200), "right", "bottom")
    SetImageState("white", "", 255, 255, 255, 255)
    local s = self.curb_size
    misc.RenderOutLine("white", x1 + 12 - s * 5, _line - 12 + s * 5, y2 + 25 + s * 5, y2 + 5 - s * 5, 0, 2)
    ui:RenderText("pretty_title", _t("defaultSetting"),
            (x1 + _line) / 2, y2 + 16, 0.6 + s * 0.12, Color(255, 250, 128, 114), "centerpoint")
    self.top_bar:render()
end

