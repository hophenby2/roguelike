local PlayerSelect = {}
local SpellSelect = {}
local DiffSelect = {}
local AdditionSelect = {}
local Addition_select_informationRead = {}
local PlayerSelect_Submenu = {}
local SpellSelect_Submenu = {}
local AdditionSelect_Submenu = {}
local Detail_Submenu = {}

local CheatMode = {}

local PreSetAddtionSelect = {}

local function general_buttonFrame(self)
    local mouse = ext.mouse
    local x1, y1, x2, y2 = self.x - self.w * self.scale, self.x + self.w * self.scale, self.y - self.h * self.scale, self.y + self.h * self.scale
    if sp.math.PointBoundCheck(mouse.x, mouse.y, x1, y1, x2, y2) then
        self.index = self.index + (-self.index + 1) * 0.1
        if not self.selected then
            self.selected = true
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
local function general_buttonRender(self, A)
    A = A or 1
    local k = self.index
    local blk = k * 40 + 200
    local x, y = self.x, self.y
    local s = (self.scale + k * 0.01)
    local x1, y1, x2, y2 = self.x - self.w * s, self.x + self.w * s, self.y - self.h * s, self.y + self.h * s
    SetImageState("white", "", A * 200, 0, 0, 0)
    misc.RenderRoundedRect(x1, y1, x2, y2, self.h * s)
    SetImageState("white", "", A * 200, 200 - k * 50, 200, 200 - k * 50)
    misc.RenderRoundedRectOutline(x1, y1, x2, y2, self.h * s, 2)
    --SetImageState("menu_button", "", A * 200, 200 - k * 50, 200, 200 - k * 50)
    -- Render("menu_button", x, y, 0, s * self.w / 230, s * self.h / 48)

    ui:RenderText("pretty_title", self.text, x, y + 0.5,
            1 + k * 0.05, Color(A * 200, blk - k * 50, blk, blk - k * 50), "centerpoint")
end

local function _t(str)
    return i18n("sth", str) or ""
end

local attrmenu = stage.New("attr_select", false, true)
attributeselectmenu = attrmenu

attrmenu.general_buttonFrame = general_buttonFrame
attrmenu.general_buttonRender = general_buttonRender

function attrmenu:init()
    lastmenu = self
    self.top_bar = top_bar_Class(self, SceneClass[lstg.var.scene_id].title)
    self.top_bar:addReturnButton(function()
        self.exit_func()
    end)
    mainmenu:MusicInit()
    mask_fader:Do("open")

    PlayerSelect:init(self)
    SpellSelect:init(self)
    DiffSelect:init(self)
    AdditionSelect:init(self)

    PlayerSelect_Submenu:init(self)
    SpellSelect_Submenu:init(self)
    AdditionSelect_Submenu:init(self)
    Addition_select_informationRead:init(self, 890, 424)
    self.exit_func = function()
        PlaySound("cancel00")
        task.New(self, function()
            self.locked = true
            mask_fader:Do("close")
            task.Wait(15)
            stage.Set("none", "scene_select")
        end)
    end
    self.locked = true
    self.start_button = {
        x = 480, y = 45, index = 0,
        w = 230, h = 48,
        scale = 0.3,
        selected = false,
        text = _t("start"),
        func = function()
            task.New(self, function()
                local scene = lstg.var.scene_id
                local ID = SceneClass[scene].inStageID
                local stg_name = { "Tutorial" .. scene, "Simple" .. ID, "Simple" .. ID, "Extra" .. ID }
                local id = stagedata.DiffSelection[DiffSelect.id]
                local cost = false
                local function Start()
                    self.locked = true
                    lstg.var.player_select = stagedata.player_pos
                    FUNDAMENTAL_MENU.music:FadeStop(15)
                    mask_fader:Do("close")
                    task.Wait(15)
                    stage.group.Start(stage.groups[stg_name[id]])
                end
                for i = 1, #stagedata.chooseInitial do
                    local choose = stagedata.chooseInitial[i]
                    if choose ~= 0 then
                        local unit = stg_levelUPlib.AdditionTotalList[choose]
                        if scoredata.initialAddition[choose] and #stagedata.chooseInitial <= 5 then
                        elseif scoredata.cheatMode_show  then
                            cost = true
                        end
                    end
                end
                if cost and id ~= 1 then
                    New(SimpleChoose, self, function()
                        task.New(self, function()
                            lstg.var.is_cheatMode = true
                            Start()
                        end)

                    end, load(""), _t("cheatMode"), (_t("cheatModeWarning")):format(cost), 200, 100)
                else
                    lstg.var.is_cheatMode = nil
                    Start()
                end
            end)
        end,
        frame = general_buttonFrame,
        render = general_buttonRender
    }
    task.New(self, function()
        task.Wait(30)
        while GetKeyState(KEY.Z) do
            task.Wait()
        end

        if scoredata.guide_flag == 2 and scoredata._total_mission > 0 then
            task.Wait(25)
            New(SimpleChoose, self, function()
                task.New(self, function()
                    scoredata.guide_flag = 5
                    mask_fader:Do("close")
                    task.Wait(15)
                    stage.Set("none", "mission")
                end)
            end, function()
                scoredata.guide_flag = 5
            end, _t("guidance"), _t("exploreGuide"), 200, 100)
        else
            self.locked = false
        end
    end)
end
function attrmenu:frame()
    RefreshInitialSelect()
    PlayerSelect_Submenu:frame()
    SpellSelect_Submenu:frame()
    AdditionSelect_Submenu:frame()

    if self.locked then
        return
    end
    self.top_bar:frame()
    menu:Updatekey()
    if menu:keyYes() then
        self.start_button.func()
    end
    if menu:keyNo() then
        self.exit_func()
    end
    PlayerSelect:frame()
    SpellSelect:frame()
    DiffSelect:frame()
    AdditionSelect:frame()
    Addition_select_informationRead:frame()
    self.start_button:frame()


end
function attrmenu:render()
    ui:DrawBack(1, self.timer)
    PlayerSelect:render()
    SpellSelect:render()
    DiffSelect:render()
    AdditionSelect:render()
    self.start_button:render()
    self.top_bar:render()
    Addition_select_informationRead:render(1)
    PlayerSelect_Submenu:render()
    SpellSelect_Submenu:render()
    AdditionSelect_Submenu:render()

end

local function GetChooseInitial2INDEX(m)
    if m.isActive then
        return 2
    elseif m.isTool then
        return 1
    else
        return 1
    end
end
local function GetChooseInitial2LEVEL(m)
    if m.isActive then
        return 2
    elseif m.isTool then
        return 1
    else
        return 0
    end
end
local function GetChooseInitialByID(idtable)
    local m = {
        stg_levelUPlib.AdditionTotalList,
        activeItem_lib.ActiveTotalList
    }
    return m[idtable[2]][idtable[1]]
end
local function ChooseInitialIsUnit(idtable, m)
    return idtable[1] == m.id and idtable[2] == GetChooseInitial2INDEX(m)
end
local function GetChooseInitialTable(m)
    return { m.id, GetChooseInitial2INDEX(m) }
end

function RefreshInitialSelect()
    if scoredata.cheatMode_show or DEBUG then
        for p = 5, 1, -1 do
            if #stagedata.chooseInitial >= 6 then
                if stagedata.chooseInitial[p][1] == 0 then
                    table.remove(stagedata.chooseInitial, p)
                end
            end
        end
    else
        for p = 6, #stagedata.chooseInitial do
            stagedata.chooseInitial[p] = nil
        end
    end

    for i = 1, 5 do
        local choose = stagedata.chooseInitial[i]
        if choose[1] ~= 0 then
            local unit = GetChooseInitialByID(choose)
            if unit and not unit.isActive then
                if scoredata.initialAddition[choose[1]] then
                elseif scoredata.cheatMode_show and scoredata.BookAddition[choose[1]] and unit.isTool then
                elseif DEBUG then
                else
                    stagedata.chooseInitial[i] = { 0, 1 }
                end
            elseif unit then
            else
                stagedata.chooseInitial[i] = { 0, 1 }
            end
        end
    end
end

---以大于号为基准
function CompareID(id1, id2)
    if type(id1) == type(id2) then
        return id1 > id2
    else
        return tostring(id1) > tostring(id2)
    end
end


--改的东西记得复制粘贴到attr_select2
function PlayerSelect:init(mainmenu)
    self.x, self.y = 480, 270
    self.mainmenu = mainmenu
    self.func = function()
        self.locked = true
        self.mainmenu.locked = true
        PlayerSelect_Submenu:In()
    end

    self.index = 0
    self.timer = 0
    self.r = 145
    self.selected = false
    self.list = player_list
    self.pos = stagedata.player_pos
    self.locked = false
    self.text = _t("selCharacter")
    self.show_alpha = 1
    if lstg.var.scene_id then
        self.back = SceneClass[lstg.var.scene_id].tex
    end

end
function PlayerSelect:SetPos(pos)
    pos = sp:TweakValue(pos, #self.list, 1)
    self.pos = pos
    stagedata.player_pos = pos
    SpellSelect:SetPos()

    task.New(self, function()
        self.show_alpha = 0
        for i = 1, 16 do
            self.show_alpha = task.SetMode[2](i / 16)
            task.Wait()
        end
    end)
end
function PlayerSelect:frame()
    task.Do(self)
    self.timer = self.timer + 1
    if self.locked then
        return
    end
    local mouse = ext.mouse
    if Dist(self.x, self.y, mouse.x, mouse.y) < self.r and not SpellSelect.selected then
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
        local _wheel = mouse:getWheel()
        if _wheel ~= 0 then
            self.index = self.index + 0.5

            local t = -sign(_wheel)
            local pos = self.pos + t
            while true do
                local spos = sp:TweakValue(pos, #self.list, 1)
                if playerdata[player_list[spos].name].unlock_c then
                    self:SetPos(pos)
                    PlaySound("select00")
                    break
                end
                pos = pos + t
            end


        end

        if mouse:isUp(1) then
            self.index = self.index + 0.5
            PlaySound("ok00")
            self.func()
        end
    end
    if menu:keyRight() then
        self.index = self.index + 0.5
        local t = 1
        local pos = self.pos + t
        while true do
            local spos = sp:TweakValue(pos, #self.list, 1)
            if playerdata[player_list[spos].name].unlock_c then
                self:SetPos(pos)
                PlaySound("select00")
                break
            end
            pos = pos + t
        end
        PlaySound("select00")
    end
    if menu:keyLeft() then
        local t = -1
        local pos = self.pos + t
        while true do
            local spos = sp:TweakValue(pos, #self.list, 1)
            if playerdata[player_list[spos].name].unlock_c then
                self:SetPos(pos)
                PlaySound("select00")
                break
            end
            pos = pos + t
        end
        self.index = self.index + 0.5
        PlaySound("select00")
    end
end
function PlayerSelect:render()
    local k = self.index
    local blk = k * 40 + 200
    local x, y = self.x, self.y
    local R = self.r + k * 6
    SetImageState("menu_circle", "", 255, 200 - k * 15, 200, 200 - k * 15)
    Render("menu_circle", x, y, 0, R / 192)
    ui:RenderText("pretty_title", self.text, x, y + R + 15,
            1.2, Color(200, blk - k * 15, blk, blk - k * 15), "centerpoint")
    ---@type PlayerUnit
    local punit = self.list[self.pos]
    local size = GetTextureSize(self.back)
    misc.RenderTexInCircle(self.back, x, y, size / 2, size / 2,
            R * 0.913, 0, 0.4, "",
            Color(self.show_alpha * (170 + k * 40), blk, blk, blk), 75)
    misc.RenderTexInCircle(punit.picture, x, y, punit.renderx, punit.rendery,
            R * 0.913, 0, punit.renderscale, "",
            Color(self.show_alpha * (200 + k * 40), blk, blk, blk), 75)
    local unlock_c = int(playerdata[punit.name].unlock_c or 0)
    local t = (unlock_c - 1) / 2
    local star_num = 1
    for c = -t, t do
        local starscale = 0.2
        local _x, _y = x + c * 24, y - R * 0.65
        local img = "menu_player_star1"
        if playerdata[punit.name].choose_skill[star_num] then
            img = "menu_player_star3"
        end
        SetImageState(img, "mul+add", self.show_alpha * (180 + k * 40), 255, 255, 255)
        Render(img, _x, _y, 0, starscale * (0.9 + k * 0.1))
        star_num = star_num + 1
    end

end

function SpellSelect:init(mainmenu)
    self.x, self.y = 480 + 100, 270 - 125
    self.mainmenu = mainmenu
    self.func = function()
        self.locked = true
        self.mainmenu.locked = true
        SpellSelect_Submenu:In()
    end
    self.index = 0
    self.timer = 0
    self.r = 50
    self.selected = false
    self.text = _t("selSpell")
    self.show_alpha = 1
    self:SetPos()
end
function SpellSelect:SetPos(pos)

    local pSelectPos = stagedata.player_pos
    ---@type PlayerUnit
    local p = player_list[pSelectPos]
    pos = pos or stagedata.spell_pos[pSelectPos]
    pos = sp:TweakValue(pos, #p.spells, 1)
    self.pos = pos
    stagedata.spell_pos[pSelectPos] = pos
    task.New(self, function()
        self.show_alpha = 0
        for i = 1, 16 do
            self.show_alpha = task.SetMode[2](i / 16)
            task.Wait()
        end
    end)
end
function SpellSelect:frame()
    self.timer = self.timer + 1
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
        local _wheel = mouse:getWheel()
        if _wheel ~= 0 then
            self.index = self.index + 0.5
            self:SetPos(self.pos - sign(_wheel))
            PlaySound("select00")
        end
        if mouse:isUp(1) then
            self.index = self.index + 0.5
            PlaySound("ok00")
            self.func()
        end
    end
end
function SpellSelect:render()
    local k = self.index
    local blk = k * 40 + 200
    local x, y = self.x, self.y
    local R = self.r + k * 6
    SetImageState("menu_circle", "", 255, 200 - k * 15, 200, 200 - k * 15)
    Render("menu_circle", x, y, 0, R / 192)

    local pSelectPos = stagedata.player_pos
    local p = player_list[pSelectPos]
    ---@type SpellUnit
    local sp = p.spells[self.pos]
    local img = sp.picture
    SetImageState(img, "", 255, 200, 200, 200)
    Render(img, x, y, 0, R / 192)

    ui:RenderText("pretty_title", self.text, x, y - R - 10,
            1, Color(200, blk - k * 15, blk, blk - k * 15), "centerpoint")
end

function DiffSelect:init(mainmenu)
    self.mainmenu = mainmenu
    self.x, self.y = 170, 255
    self.w, self.h = 122, 135
    self.index = 0
    self.timer = 0
    self.r = 58
    self.selected = false
    self.text = _t("selDiff")
    self.id = lstg.var.scene_id
    self.pos = stagedata.DiffSelection[self.id]
    self.diff_obj = {
        {
            title = "Tutorial",
            describe = _t("tutorialIntro"),
            colH = 135
        },
        {
            title = "Normal",
            describe = _t("normalIntro"),
            colH = 180
        },
        {
            title = "Ultra",
            describe = _t("ultraIntro"),
            colH = 270
        },
        {
            title = "Extra",
            describe = _t("extraIntro"),
            colH = 45
        },
    }
    self.unlock_extra = false
    for i = 2, 3 do
        self.unlock_extra = self.unlock_extra or (stagedata.stagePass[self.id][i] > 0)
    end
end
function DiffSelect:frame()
    stagedata.DiffSelection[self.id] = self.pos
    self.timer = self.timer + 1
    local mouse = ext.mouse
    local x, y = self.x, self.y
    local w, h = self.w, self.h
    local x1, x2, y1, y2 = x - w, x + w, y - h, y + h
    if sp.math.PointBoundCheck(mouse.x, mouse.y, x1, x2, y1, y2) then
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
        if mouse._wheel ~= 0 then
            self.pos = sp:TweakValue(self.pos - sign(mouse._wheel), self.unlock_extra and 4 or 3, 1)
            self.index = self.index + 0.5
            PlaySound("select00")
        end
        if mouse:isUp(1) then
            for i = 1, 4 do
                local _w = (y2 - y1) / 4
                local _y = y2 - _w * (i - 0.5)
                if sp.math.PointBoundCheck(mouse.x, mouse.y, x1, x2, _y - _w / 2, _y + _w / 2) then
                    if not (not self.unlock_extra and i == 4) then
                        self.pos = i
                    end
                end
            end
            self.index = self.index + 0.5
            PlaySound("select00")
        end
    end
    if menu:keyDown() then
        self.pos = sp:TweakValue(self.pos + 1, self.unlock_extra and 4 or 3, 1)
        self.index = self.index + 0.5
        PlaySound("select00")
    end
    if menu:keyUp() then
        self.pos = sp:TweakValue(self.pos - 1, self.unlock_extra and 4 or 3, 1)
        self.index = self.index + 0.5
        PlaySound("select00")
    end
end
function DiffSelect:render()
    local k = self.index
    local blk = k * 40 + 200
    local x, y = self.x, self.y
    local w, h = self.w, self.h
    local x1, x2, y1, y2 = x - w, x + w, y - h - k * 4, y + h + k * 4
    SetImageState("white", "", 75, 0, 0, 0)
    RenderRect("white", x1, x2, y1, y2)

    ui:RenderText("pretty_title", self.text, x1, y2 + 6, 1, Color(200, blk - k * 15, blk, blk - k * 15), "left", "bottom")

    SetImageState("white", "", 70 - k * 70, 0, 0, 0)
    RenderRect("white", x1, x2, y1, y2)

    for i, p in ipairs(self.diff_obj) do
        local _w = (y2 - y1) / 4
        local _y = y2 - _w * (i - 0.5)
        local index = ((self.pos == i) and (k * 0.2 + 0.8) or (k * 0.1 + 0.2))
        SetImageState("white", "", index * 150, sp:HSVtoRGB(p.colH, 0.4, 1))
        RenderRect("white", x1 + 4, x2 - 4, _y - _w / 2 + 4, _y + _w / 2 - 4)
        ui:RenderText("pretty", p.title, x1 + 6, _y + _w / 2 - 3, 0.6,
                Color(index * 255, sp:HSVtoRGB(p.colH, 0.3, 1)), "left", "top")
        ui:RenderText("title", p.describe, x1 + 6, _y + 2, 0.6,
                Color(index * 255, sp:HSVtoRGB(p.colH, 0.1, 1)), "left", "top")
        local r, g, b = 200, 200, 200
        local text = ""
        if i == 4 and not self.unlock_extra then
            r, g, b = 200, 200, 200
            text = _t("unlocked")
        else
            if stagedata.stagePass[self.id][i] > 0 then
                r, g, b = sp:HSVtoRGB(90, 0.3, 1)
                if i == 1 then
                    text = _t("checked")
                else
                    local count = stagedata.stagePass[self.id][i]
                    text = _t("passCount"):format(count)
                end
            else
                r, g, b = sp:HSVtoRGB(0, 0.3, 1)
                text = _t("unpassed")
            end
        end
        SetImageState("menu_circle", "", 80 + index * 120, r, g, b)
        Render("menu_circle", x2 - 45, _y, 0, 28 / 192)
        ui:RenderText("pretty", text, x2 - 45, _y + 1, 0.37,
                Color(80 + index * 120, r, g, b), "centerpoint")
    end
    SetImageState("white", "", 255, 200 - k * 15, 200, 200 - k * 15)

    misc.RenderOutLine("white", x1, x2, y2, y1, 3, 0)
    for i = 1, 3 do
        local _y = y2 - (y2 - y1) / 4 * i
        misc.RenderOutLine("white", x1, x2, _y, _y, 1.5, 0)
    end
end

function AdditionSelect:init(mainmenu)
    self.mainmenu = mainmenu
    self.x, self.y = 790, 255
    self.w, self.h = 122, 120
    self.index = 0
    self.timer = 0
    self.selected = false
    self.text = _t("selInitialTake")
    self.id = lstg.var.scene_id
    -- scoredata.initialAddition[36] = true
    --scoredata.initialAddition[37] = true
    self.void_addition = stg_levelUPlib.VoidAddition()
    self.locked_addition = stg_levelUPlib.LockedAddition()
    if type(stagedata.chooseInitial[1]) == "number" then
        for i = 1, 5 do
            stagedata.chooseInitial[i] = { stagedata.chooseInitial[i], 1 }
        end
    end--旧版本数据兼容
end
function AdditionSelect:frame()
    self.timer = self.timer + 1
    local mouse = ext.mouse
    local x, y = self.x, self.y
    local w, h = self.w, self.h
    local x1, x2, y1, y2 = x - w, x + w, y - h, y + h
    if sp.math.PointBoundCheck(mouse.x, mouse.y, x1, x2, y1, y2) then
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
            for i = 1, 5 do
                local _w = (y2 - y1) / 5
                local _y = y2 - _w * (i - 0.5)
                if sp.math.PointBoundCheck(mouse.x, mouse.y, x1, x2, _y - _w / 2, _y + _w / 2) then
                    self.mainmenu.locked = true
                    AdditionSelect_Submenu:In()
                end
            end
            self.index = self.index + 0.5
            PlaySound("select00")
        end
    end
end
function AdditionSelect:render()
    local k = self.index
    local blk = k * 40 + 200
    local x, y = self.x, self.y
    local w, h = self.w, self.h
    local count = max(5, #stagedata.chooseInitial)

    local x1, x2, y1, y2 = x - w, x + w, y - h - k * 3, y + h + k * 3
    local _w = (y2 - y1) / count
    SetImageState("white", "", 75, 0, 0, 0)
    RenderRect("white", x1, x2, y1, y2)

    ui:RenderText("pretty_title", self.text, x2, y2 + 6, 1,
            Color(200, blk - k * 15, blk, blk - k * 15), "right", "bottom")

    SetImageState("white", "", 70 - k * 70, 0, 0, 0)
    RenderRect("white", x1, x2, y1, y2)

    for i = 1, count do
        local _y = y2 - _w * (i - 0.5)
        local unit = GetChooseInitialByID(stagedata.chooseInitial[i])
        local R, G, B = 200, 200, 200
        if not unit then
            unit = self.void_addition
        end
        R, G, B = unit.R, unit.G, unit.B

        SetImageState("white", "", 75 + 50 * k, R, G, B)
        local off = _w / 45 * 4
        RenderRect("white", x1 + off, x2 - off, _y - _w / 2 + off, _y + _w / 2 - off)
        SetImageState(unit.pic, "", 100 + 60 * k, 255, 255, 255)
        Render(unit.pic, x1 + _w / 2, _y, 0, (_w) * 0.8 / 256)
        --RenderRect(unit.pic, x1 + 4, x1 + _w - 4, _y - _w / 2 + 4, _y + _w / 2 - 4)
        ui:RenderText("big_text", unit.title2, x1 + _w * 1.15, _y, 0.4 * _w / 45,
                Color(200 + k * 55, R, G, B), "left", "vcenter")
        --[[
        ui:RenderTextInWidth("title", unit.describe, x1 + _w + 5, _y + 2, 0.7, (x2 - x1 - _w - 15),
                Color(200 + k * 55, R, G, B), "left", "top")--]]
    end
    SetImageState("white", "", 255, 200 - k * 15, 200, 200 - k * 15)
    RenderRect("white", x1 + _w - 1, x1 + _w + 1, y1, y2)
    misc.RenderOutLine("white", x1, x2, y2, y1, 3, 0)
    for i = 1, count - 1 do
        local _y = y2 - _w * i
        misc.RenderOutLine("white", x1, x2, _y, _y, 1.5 * _w / 45, 0)
    end
end

function PlayerSelect_Submenu:init(mainmenu)
    self.mainmenu = mainmenu
    self.x, self.y = 300, 275
    self.w, self.h = 180, 190
    self.left_index = 0
    self.right_index = 0
    self.locked = true
    self.alpha = 0
    self.timer = 0
    self.list = player_list
    self.pos = stagedata.player_pos
    self.show_alpha = 1
    self.ok_button = {
        x = 480, y = 27, index = 0,
        w = 230, h = 48,
        scale = 0.3,
        selected = false,
        text = _t("yes"),
        func = function()

            if playerdata[player_list[self.pos].name].unlock_c then
                PlaySound("ok00")
                PlayerSelect:SetPos(self.pos)
                SpellSelect:SetPos()
                self:Out()
            else
                local cond = player_list[self.pos].unlock_way
                New(UnlockWindow, self, cond, function()
                    playerdata[player_list[self.pos].name].unlock_c = 0
                end)
            end

        end,
        frame = general_buttonFrame,
        render = general_buttonRender
    }
    self.page = 1
    self.p_alpha1 = 1
    self.p_alpha2 = 0
    self.tri = { 0, 0, 0 }
    self.tri_index = { 0, 0, 0 }
    self.top_bar = top_bar_Class(self, _t("characterDetail"), true)
    self.top_bar:addReturnButton(function()
        self:Out()
    end)
end
function PlayerSelect_Submenu:In()
    PlaySound("select00")
    self.locked = false
    self.pos = stagedata.player_pos
    self.top_bar:flyIn()
    task.New(self, function()
        for i = 1, 16 do
            self.alpha = i / 16
            task.Wait()
        end
    end)

end
function PlayerSelect_Submenu:Out()

    task.New(self, function()
        self.top_bar:flyOut()
        self.locked = true
        PlayerSelect.locked = false
        self.mainmenu.locked = false
        for i = 1, 16 do
            self.alpha = 1 - i / 16
            task.Wait()
        end

    end)
end
function PlayerSelect_Submenu:SetPos(pos)
    pos = sp:TweakValue(pos, #self.list, 1)
    self.pos = pos
    task.New(self, function()
        self.show_alpha = 0
        for i = 1, 16 do
            self.show_alpha = task.SetMode[2](i / 16)
            task.Wait()
        end
    end)
end
function PlayerSelect_Submenu:frame()
    task.Do(self)
    self.timer = self.timer + 1
    self.top_bar:frame()
    if self.locked then
        return
    end

    menu:Updatekey()
    local mouse = ext.mouse
    if menu:keyNo() then
        PlaySound("cancel00")
        self:Out()
    end
    local _wheel = mouse:getWheel()
    local punit = self.list[self.pos]
    local level = playerdata[punit.name].level
    local data = playerdata[punit.name]
    local unlock = data.unlock_c
    if _wheel ~= 0 then
        local k = -sign(_wheel)
        self:SetPos(self.pos + k)
        if k > 0 then
            self.right_index = 1
        else
            self.left_index = 1
        end
        PlaySound("select00")
    end
    if mouse:isUp(1) then
        if mouse.y < 540 - 46 then
            if mouse.x > 960 - self.x + self.w then
                self.right_index = 1
                self:SetPos(self.pos + 1)
                PlaySound("select00")
            elseif mouse.x < self.x - self.w then
                self.left_index = 1
                self:SetPos(self.pos - 1)
                PlaySound("select00")
            end

            local x, y = self.x, self.y
            local w, h = self.w, self.h
            local x1, x2, y1, y2 = x - w, x + w, y - h, y + h
            local x3 = 960 - x + w
            local _x = (x2 + x3) / 2
            local y3 = y2 - 60
            local y6 = y1 + 45
            if sp.math.PointBoundCheck(mouse.x, mouse.y, x2, _x, y1, y6) then
                self.page = 1
                PlaySound("select00")
            elseif sp.math.PointBoundCheck(mouse.x, mouse.y, _x, x3, y1, y6) then
                self.page = 2
                PlaySound("select00")
            end
            local Y = y3 - 25
            if self.page == 2 and unlock then
                for i = 1, 3 do
                    if sp.math.PointBoundCheck(mouse.x, mouse.y, x2, x3, Y - 50, Y + 25) then
                        ---@type PlayerUnit
                        if data.unlock_c and data.unlock_c >= i then
                            data.choose_skill[i] = not data.choose_skill[i]
                            PlaySound("select00")
                        else
                            PlaySound("invalid")
                            New(info, _t("unlockedTalentWarning"), 90, 20)
                        end
                        self.tri_index[i] = 1
                        break

                    end
                    Y = Y - 75
                end
            end
        end
    end
    local p_alpha1 = (self.page == 1) and 1 or 0
    local p_alpha2 = (self.page == 2) and 1 or 0
    self.p_alpha1 = self.p_alpha1 + (-self.p_alpha1 + p_alpha1) * 0.3
    self.p_alpha2 = self.p_alpha2 + (-self.p_alpha2 + p_alpha2) * 0.3
    self.left_index = self.left_index - self.left_index * 0.1
    self.right_index = self.right_index - self.right_index * 0.1
    for i = 1, 3 do

        local tri = 0
        if data.choose_skill[i] then
            tri = 1
        end
        self.tri[i] = self.tri[i] + (-self.tri[i] + tri) * 0.3
        self.tri_index[i] = self.tri_index[i] - self.tri_index[i] * 0.1
    end
    self.ok_button:frame()

end
function PlayerSelect_Submenu:render()
    local A = self.alpha
    local A2 = self.show_alpha
    if A == 0 then
        return
    end
    local t = self.timer
    SetImageState("white", "", A * 220, 0, 0, 0)
    RenderRect("white", 0, 960, 0, 540)

    local x, y = self.x, self.y
    local w, h = self.w, self.h
    local x1, x2, y1, y2 = x - w, x + w, y - h, y + h
    local x3 = 960 - x + w
    local y3 = y2 - 60
    local y5 = y2 - 300
    SetImageState("white", "", A * 75, 0, 0, 0)
    RenderRect("white", x1, x2, y1, y2)

    ---@type PlayerUnit
    local punit = self.list[self.pos]
    local size = GetTextureSize(punit.picture)
    local unlock = playerdata[punit.name].unlock_c
    local scale = punit.renderscale
    local offx, offy = (-punit.renderx + size / 2), -70 + sin(t / 1.7) * 3
    misc.RenderTexInRect(punit.picture, x1, x2, y1, y2, offx, offy,
            0, scale, scale, "", Color(A * A2 * 200, 255, 255, 255))
    ui:RenderText("title", "Author: ファルケン", x1 + 5, y1 + 5,
            0.7, Color(A * A2 * (150 + 100 * sin(t * 2)), 200, 200, 200), "left", "bottom")
    SetImageState("white", "", A * 180, 0, 0, 0)
    SetImageState("white", "", A * 255, 200, 200, 200)
    RenderRect("white", x2, x3, y3 - 1.5, y3 + 1.5)
    local mouse = ext.mouse

    do
        local english = setting.language == 2
        local ttf = english and "pretty" or "big_text"
        ui:RenderText(ttf, punit.display_name, (x2 + x3) / 2, (y2 + y3) / 2 ,
                0.8, Color(255 * A * A2, 189, 200 + sin(t / 2) * 20, 240), "centerpoint")
        ui:RenderText("pretty", punit.nickname, x3 - 7, y3 + 4,
                0.3, Color(255 * A * A2, 200, 200, 200), "right", "bottom")
    end

    do

        local pa1 = self.p_alpha1
        local pa2 = self.p_alpha2
        local _a1 = A * A2 * pa1
        local _a2 = A * A2 * pa2
        local data = punit.class.attribute
        for i, text in ipairs({
            { ("> %s"):format(_t("maxlife")), ("%0.2f"):format(data.hp) },
            { ("> %s"):format(_t("hitbox")), ("%0.2f"):format(data.collisize) },
            { ("> %s"):format(_t("speed")), ("%0.2f / %0.2f"):format(data.hspeed, data.lspeed) },
            { ("> %s"):format(_t("atk")), ("%0.2f"):format(data.dmg) },
            { ("> %s"):format(_t("srange")), ("%d"):format(data.shoot_set_range) },
            { ("> %s"):format(_t("sspeed")), ("%0.2f"):format(data.shoot_set_speed) },
            { ("> %s"):format(_t("bvelocity")), ("%0.2f"):format(data.shoot_set_bvelocity) },
        }) do
            ui:RenderText("pretty_title", text[1], x2 + 5, y3 - 7 - (i - 1) * 30,
                    0.9, Color(_a1 * 255, 255, 255, 255), "left", "top")
            ui:RenderText("title", text[2], x3 - 7, y3 - 6 - (i - 1) * 30,
                    0.9, Color(_a1 * 255, 255, 227, 132), "right", "top")
        end
        local Y = y3 - 25

        local kcharacters = { "1", "2", "3" }
        for i = 1, 3 do
            local des = punit.skill_describe[i]
            local unlock_c = int(playerdata[punit.name].unlock_c or 0)
            local star_img = "menu_player_star1"
            local tR, tG, tB = 200, 200, 200
            local data2 = playerdata[punit.name]
            if unlock_c >= i then
                star_img = "menu_player_star3"
                tR, tG, tB = 255, 227, 132
                SetImageState("white", "mul+add", _a2 * 30, 125, 200, 169)
                RenderRect("white", x2, x3, Y - 50, Y + 25)
                for _i = -17, 17 do
                    for _j = -3, 3 do
                        local _x, _y = (x2 + x3) / 2 - 1.5 + _i * 10.1, Y - 12.5 + _j * 10
                        local d = Dist(_x, _y, mouse.x, mouse.y)
                        local ti = self.tri_index
                        local s = min(1, (100 + self.tri[i] * 500) / d / d)
                        SetImageState("white", "mul+add", _a2 * (10 + s * 75), 125, 100 + 100 * self.tri[i], 69 + 100 * self.tri[i])
                        Render("white", _x, _y, 0, 0.3 + s * 0.3312 + ti[i] * 0.2)
                    end
                end
            end

            ui:RenderText("pretty", ("%s%s  「%s」"):format(_t("talent"), _t(kcharacters[i]), des[1]), x2 + 40, Y + 5,
                    0.4, Color(_a2 * (200 + 55 * self.tri[i]), tR, tG, tB), "left", "vcenter")
            for k, str in ipairs(sp:SplitText(ReplaceTextWithCommand(des[2]), "\n")) do
                ui:RenderTextWithCommand("title", str, x2 + 40, Y - 10 - (k - 1) * 15,
                        0.7, _a2 * (155 + 55 * self.tri[i]), "left")
            end
            SetImageState("white", "", _a2 * 255, 200, 200, 200)
            RenderRect("white", x2, x3, Y - 50 - 1.5, Y - 50 + 1.5)
            SetImageState(star_img, "mul+add", _a2 * 200, 255, 255, 255)
            Render(star_img, x2 + 20, Y - 13, self.tri_index[i] * 90, 0.25)
            SetImageState("menu_circle", "", _a2 * 200, 200, 200, 200)
            Render("menu_circle", x3 - 50, Y - 13, 0, 0.16 + self.tri_index[i] * 0.02)
            if data2.choose_skill[i] then
                ui:RenderText("big_text", "●", x3 - 50, Y - 13 + 2,
                        self.tri[i], Color(_a2 * 185, 125, 200, 169), "centerpoint")
            end
            Y = Y - 75
        end
        local y6 = y1 + 45
        SetImageState("white", "", A * 255, 200, 200, 200)
        RenderRect("white", x2, x3, y6 - 1, y6 + 1)
        RenderRect("white", (x2 + x3) / 2 - 1, (x2 + x3) / 2 + 1, y1, y6)
        local r, g, b = 255, 227, 132
        ui:RenderText("pretty", _t("attribute"),
                x2 * 3 / 4 + x3 * 1 / 4, (y1 + y6) / 2 + 2,
                0.5 + pa1 * 0.1, Color((150 + pa1 * 80) * A * A2, r, g, b), "centerpoint")
        ui:RenderText("pretty", _t("talent"),
                x2 * 1 / 4 + x3 * 3 / 4, (y1 + y6) / 2 + 2,
                0.5 + pa2 * 0.1, Color((150 + pa2 * 80) * A * A2, r, g, b), "centerpoint")
        misc.RenderBrightOutline(x2, (x2 + x3) / 2, y1, y6, 15,
                (sin(t * 3) * 30 + 60) * _a1, r, g, b)
        misc.RenderBrightOutline((x2 + x3) / 2, x3, y1, y6, 15,
                (sin(t * 3) * 30 + 60) * _a2, r, g, b)


    end--信息

    SetImageState("white", "", A * 255, 200, 200, 200)
    misc.RenderOutLine("white", x1, x2, y2, y1, 3, 0)
    misc.RenderOutLine("white", x2 - 3, x3, y2, y1, 3, 0)

    do
        local li, ri = self.left_index, self.right_index
        ui:RenderText("pretty", "<", x1 / 2 + sin(t * 3) * 5, 270,
                1.5 + li * 0.2, Color(A * 255, 255, 255 - li * 75, 255), "centerpoint")
        ui:RenderText("pretty", ">", (x3 + 960) / 2 - sin(t * 3) * 5, 270,
                1.5 + ri * 0.2, Color(A * 255, 255, 255 - ri * 75, 255), "centerpoint")
        local c = (#self.list - 1) / 2
        local k = 1
        for i = -c, c do
            local _unlock = playerdata[self.list[k].name].unlock_c
            local _size = _unlock and 1 or 0.6
            if self.pos == k then
                SetImageState("bright", "mul+add", A * A2 * 255, 255 - 30 * _size, 225 + 30 * _size, 225)
                Render("bright", 480 + i * 26, y1 - 16, 0, 0.07 * _size)
            end
            SetImageState("white", "", A * 150, 222, 222, 222)
            misc.SectorRender(480 + i * 26, y1 - 16, 6.7 * _size, 8.4 * _size, 0, 360, 6, t / 2)

            k = k + 1

        end
    end--选项渲染
    if not unlock then
        SetImageState("white", "", A * 85, 0, 0, 0)
        RenderRect("white", x1, x3, y1, y2)
    end
    self.ok_button:render(A)
    self.top_bar:render()
end

function SpellSelect_Submenu:init(mainmenu)
    self.mainmenu = mainmenu
    self.x, self.y = (setting.language == 1) and 230 or 190, 270
    self.h = 120
    self.locked = true
    self.alpha = 0
    self.timer = 0
    local ppos = stagedata.player_pos
    self.list = player_list[ppos].spells
    self.pos = stagedata.spell_pos[ppos]
    self.indexs = {}
    for i in ipairs(self.list) do
        self.indexs[i] = 0
    end
    self.show_alpha = 1
    self.ok_button = {
        x = 480, y = 60, index = 0,
        w = 230, h = 48,
        scale = 0.3,
        selected = false,
        text = _t("yes"),
        func = function()
            PlaySound("ok00")
            SpellSelect:SetPos(self.pos)
            self:Out()
        end,
        frame = general_buttonFrame,
        render = general_buttonRender
    }
end
function SpellSelect_Submenu:In()
    PlaySound("select00")
    self.locked = false
    local ppos = stagedata.player_pos
    self.list = player_list[ppos].spells
    self.pos = stagedata.spell_pos[ppos]
    self.indexs = {}
    for i in ipairs(self.list) do
        self.indexs[i] = 0
    end
    task.New(self, function()
        for i = 1, 16 do
            self.alpha = i / 16
            task.Wait()
        end
    end)
end
function SpellSelect_Submenu:Out()
    task.New(self, function()
        self.locked = true
        SpellSelect.locked = false
        self.mainmenu.locked = false
        for i = 1, 16 do
            self.alpha = 1 - i / 16
            task.Wait()
        end
    end)
end
function SpellSelect_Submenu:SetPos(pos)
    pos = sp:TweakValue(pos, #self.list, 1)
    self.pos = pos
    task.New(self, function()
        self.show_alpha = 0
        for i = 1, 16 do
            self.show_alpha = task.SetMode[2](i / 16)
            task.Wait()
        end
    end)
end
function SpellSelect_Submenu:frame()
    task.Do(self)
    self.timer = self.timer + 1
    if self.locked then
        return
    end
    menu:Updatekey()
    local mouse = ext.mouse
    if menu:keyNo() then
        PlaySound("cancel00")
        self:Out()
    end
    local _wheel = mouse:getWheel()
    if _wheel ~= 0 then
        local k = -sign(_wheel)
        self:SetPos(self.pos + k)
        PlaySound("select00")
    end
    if mouse:isUp(1) then
        if mouse.x > self.x - self.h / 2 and mouse.x < self.x + self.h / 2 then
            local count = #self.list
            local k = (count - 1) / 2
            local j = 1
            for p = -k, k do
                if mouse.y < self.y + p * self.h + self.h / 2 and mouse.y > self.y + p * self.h - self.h / 2 then
                    if j ~= self.pos then
                        self:SetPos(j)
                        PlaySound("select00")
                    end
                    break
                end
                j = j + 1
            end
        end
    end
    for i = 1, #self.indexs do
        if i == self.pos then
            self.indexs[i] = self.indexs[i] + (-self.indexs[i] + 1) * 0.1
        else
            self.indexs[i] = self.indexs[i] - self.indexs[i] * 0.1
        end
    end
    self.ok_button:frame()
end
function SpellSelect_Submenu:render()
    local A = self.alpha
    local A2 = self.show_alpha
    if A == 0 then
        return
    end
    local t = self.timer
    SetImageState("white", "", A * 150, 0, 0, 0)
    RenderRect("white", 0, 960, 0, 540)

    local count = #self.list
    local k = (count - 1) / 2
    local j = 1
    for p = -k, k do
        local index = self.indexs[j]
        local R = index * 9 + self.h * 0.4
        local x, y = self.x, self.y + p * self.h
        local blk = 100 + index * 100
        ---@type SpellUnit
        local wp = self.list[j]
        local img = wp.picture
        SetImageState("menu_circle", "", 255 * A, blk, blk, blk)
        Render("menu_circle", x, y, 0, R / 192)
        SetImageState(img, "", 255 * A, blk, blk, blk)
        Render(img, x, y, 0, R / 192)
        j = j + 1
    end

    local x1 = self.x + self.h * 0.6
    local x2 = 960 - x1
    local y1, y2 = 150, 400

    local y3 = y2 - 50
    SetImageState("white", "", A * 75, 0, 0, 0)
    RenderRect("white", x1, x2, y1, y2)

    do
        ---@type SpellUnit
        local spunit = self.list[self.pos]
        ui:RenderText("big_text", spunit.display_name, (x1 + x2) / 2, (y2 + y3) / 2 - 2,
                0.6, Color(255 * A * A2, 189, 230, 220 + sin(t / 2) * 20), "centerpoint")
        local data = spunit.attribute_list
        local str = spunit.belonging.class.spells[self.pos](nil, data):getDescribe()
        local strs = sp:SplitText(ReplaceTextWithCommand(str), "\n")
        for i, text in ipairs(strs) do
            ui:RenderTextWithCommand("title", text, x1 + 5, y3 - 7 - (i - 1) * 26,
                    0.9, A * A2 * 255, "left", "top")
        end
    end
    SetImageState("white", "", A * 255, 200, 200, 200)
    misc.RenderOutLine("white", x1, x2, y2, y1, 3, 0)
    RenderRect("white", x1, x2, y3 - 1.5, y3 + 1.5)
    self.ok_button:render(A)
end

function AdditionSelect_Submenu:init(mainmenu)
    self.mainmenu = mainmenu
    self.x, self.y = 480, 270
    self.w, self.h = 300, 220
    self.alpha = 0
    self.locked = true
    self.offy1 = 0
    self._offy1 = 0
    self.line_h_1 = 70
    self.timer = 0
    self:refresh()

    self.exit_button = ExitButton(810, 480, function()
        self:Out()
        PlaySound("cancel00")
    end)
    PreSetAddtionSelect:init()
    self.save_button = {
        x = 872, y = 100, index = 0,
        w = 230, h = 48,
        scale = 0.3,
        selected = false,
        text = _t("savePreset"),
        func = function()
            local id = #stagedata.presetInitial + 1
            local t = sp:CopyTable(stagedata.chooseInitial)
            stagedata.presetInitial[id] = t
            table.insert(t, scoredata.cheatMode_show)
            New(info, _t("haveSavedPreset"):format(id), 100, 20)
        end,
        frame = general_buttonFrame,
        render = general_buttonRender
    }
    self.load_button = {
        x = 872, y = 60, index = 0,
        w = 230, h = 48,
        scale = 0.3,
        selected = false,
        text = _t("loadPreset"),
        func = function()
            self.locked = true
            PreSetAddtionSelect:In()
        end,
        frame = general_buttonFrame,
        render = general_buttonRender
    }
    self.clear_button = {
        x = 872, y = 140, index = 0,
        w = 230, h = 48,
        scale = 0.3,
        selected = false,
        text = _t("clearSelected"),
        func = function()
            for i = 1, #stagedata.chooseInitial do
                stagedata.chooseInitial[i] = { 0, 1 }
            end
        end,
        frame = general_buttonFrame,
        render = general_buttonRender
    }
    CheatMode:init(self, 93, 270)
end
function AdditionSelect_Submenu:refresh()
    self.infodata = {}

    for i, tool in pairs(stg_levelUPlib.AdditionTotalList) do
        if scoredata.initialAddition[i] then
            table.insert(self.infodata, { unit = tool, subtitle = "CHEAT", free = true })
        elseif scoredata.cheatMode_show and scoredata.BookAddition[i] and tool.isTool then
            table.insert(self.infodata, { unit = tool, subtitle = "CHEAT" })
        elseif DEBUG then
            table.insert(self.infodata, { unit = tool, subtitle = "DEBUG" })
        end
    end
    for _, active in pairs(activeItem_lib.ActiveTotalList) do
        if DEBUG then
            table.insert(self.infodata, { unit = active, subtitle = "DEBUG" })
        end
    end
    table.sort(self.infodata, function(a, b)
        ---@type addition_unit
        local p1 = a.unit
        local p2 = b.unit
        local p1tool = GetChooseInitial2LEVEL(p1)
        local p2tool = GetChooseInitial2LEVEL(p2)
        local chosen1, chosen2 = self:CheckChosen(p1), self:CheckChosen(p2)
        chosen1 = chosen1 and 1 or 0
        chosen2 = chosen2 and 1 or 0
        if chosen1 == chosen2 then
            if p1tool == p2tool then
                if p1tool >= 1 then
                    if p1.quality == p2.quality then
                        return CompareID(p1.id, p2.id)
                    else
                        return p1.quality > p2.quality
                    end
                else
                    if p1.state == p2.state then
                        return p1.id > p2.id
                    else
                        return p1.state < p2.state

                    end
                end
            else
                return p1tool > p2tool

            end
        else
            return chosen1 > chosen2
        end

    end)
    self._offy1 = 0
    self.index = {}
    for i in ipairs(self.infodata) do
        self.index[i] = 0.6
    end
end
function AdditionSelect_Submenu:In()
    self.english = setting.language == 2
    self.w = self.english and 320 or 300
    if self.english then
        self.exit_button.x = 850
    end
    PlaySound("select00")
    self.locked = false
    self:refresh()
    Detail_Submenu:init(self)
    task.New(self, function()
        for i = 1, 16 do
            self.alpha = task.SetMode[2](i / 16)
            task.Wait()
        end
    end)

end
function AdditionSelect_Submenu:Out()

    task.New(self, function()
        self.locked = true
        self.mainmenu.locked = false
        for i = 1, 16 do
            self.alpha = 1 - i / 16
            task.Wait()
        end

    end)
end
function AdditionSelect_Submenu:frame()
    self.timer = self.timer + 1
    task.Do(self)
    PreSetAddtionSelect:frame()
    if self.locked then
        return
    end
    local mouse = ext.mouse
    menu:Updatekey()
    if Detail_Submenu.alpha == 0 then
        local alpha = self.alpha
        local x1, x2, y1, y2, h
        x1, x2, y1, y2 = self.x - self.w * alpha, self.x + self.w * alpha, self.y - self.h, self.y + self.h
        h = y2 - y1
        self._offy1 = self._offy1 + (-self._offy1 + clamp(self._offy1, 0, max(self.line_h_1 * #self.infodata - h, 0))) * 0.3
        self.offy1 = self.offy1 + (-self.offy1 + self._offy1) * 0.3
        if sp.math.PointBoundCheck(mouse.x, mouse.y, x1, x2, y1, y2) then
            if mouse._wheel ~= 0 then
                self._offy1 = self._offy1 - sign(mouse._wheel) * self.line_h_1 * 4
                PlaySound("select00")
            end
        end
        if menu:keyUp() then
            self._offy1 = self._offy1 - self.line_h_1 * 4
            PlaySound("select00")
        end
        if menu:keyDown() then
            self._offy1 = self._offy1 + self.line_h_1 * 4
            PlaySound("select00")
        end
        self.exit_button:frame()
        if menu:keyYes() or menu:keyNo() or menu.key == setting.keys.special then
            self.exit_button.func()
        end
        if mouse:isUp(1) then
            local Y = self.y + self.h + self.offy1
            local _h = self.line_h_1
            for _, t in ipairs(self.infodata) do
                if Y < y1 then
                    break
                end
                Y = Y - _h
                if sp.math.PointBoundCheck(mouse.x, mouse.y, x1, x2, Y, Y + _h) then
                    if mouse.x < x1 + _h then
                        Detail_Submenu:In(t.unit)
                    else
                        local chosen = self:CheckChosen(t.unit)
                        if chosen then
                            if #stagedata.chooseInitial > 5 then
                                for m = #stagedata.chooseInitial, 6, -1 do
                                    if ChooseInitialIsUnit(stagedata.chooseInitial[m], t.unit) then
                                        table.remove(stagedata.chooseInitial, m)
                                        PlaySound("ok00")
                                        break
                                    end
                                end
                            end
                            for k, i in ipairs(stagedata.chooseInitial) do
                                if ChooseInitialIsUnit(i, t.unit) then
                                    stagedata.chooseInitial[k] = { 0, 1 }
                                    PlaySound("ok00")
                                    break
                                end
                            end
                        else
                            local selected = false
                            for k, i in ipairs(stagedata.chooseInitial) do
                                if i[1] == 0 then
                                    stagedata.chooseInitial[k] = GetChooseInitialTable(t.unit)
                                    if t.unit:Noticeinitial() then
                                        scoredata.NoticeinitialAddition[t.unit.id] = false
                                    end
                                    PlaySound("ok00")
                                    selected = true
                                    break
                                end
                            end
                            if scoredata.cheatMode_show or DEBUG then
                                if not selected then
                                    table.insert(stagedata.chooseInitial, GetChooseInitialTable(t.unit))
                                    if t.unit:Noticeinitial() then
                                        scoredata.NoticeinitialAddition[t.unit.id] = false
                                    end
                                    PlaySound("ok00")
                                end
                            end
                        end
                    end

                end

            end
        end
    end
    CheatMode:frame()
    self.save_button:frame()
    self.load_button:frame()
    self.clear_button:frame()
    Detail_Submenu:frame()
end
function AdditionSelect_Submenu:CheckChosen(m)
    for _, i in ipairs(stagedata.chooseInitial) do
        if ChooseInitialIsUnit(i, m) then
            return true
        end
    end
end
function AdditionSelect_Submenu:render()
    local A = self.alpha
    if A == 0 then
        return
    end
    do

        local alpha = self.alpha
        local x1, x2, y1, y2, Y

        x1, x2, y1, y2 = self.x - self.w * alpha, self.x + self.w * alpha, self.y - self.h, self.y + self.h
        SetImageState("white", "", alpha * 180, 0, 0, 0)
        RenderRect("white", 0, 960, 0, 540)
        SetImageState("white", "", alpha * 180, 10, 10, 10)
        RenderRect("white", x1, x2, y1, y2)
        SetImageState("white", "", alpha * 255, 255, 255, 255)
        misc.RenderOutLine("white", x1, x2, y2, y1, 0, 2)
        SetRenderRect(x1, x2, y1 - self.offy1, y2 - self.offy1, x1, x2, y1, y2)
        Y = y2
        RenderRect("white", x1, x2, Y - 0.5, Y + 0.5)
        local _h = self.line_h_1
        for i, t in ipairs(self.infodata) do
            if Y < y1 - self.offy1 then
                break
            end
            Y = Y - _h
            if Y < y2 - self.offy1 then
                ---@type addition_unit
                local p = t.unit
                local chosen = self:CheckChosen(p)
                local _index = chosen and 1 or 0.6
                self.index[i] = self.index[i] + (-self.index[i] + _index) * 0.2
                local index = self.index[i]
                SetImageState("white", "", index * A * 75, p.R, p.G, p.B)
                RenderRect("white", x1 + 6, x1 + _h - 6, Y + _h - 6, Y + 6)
                RenderRect("white", x1 + _h + 3, x2 - 3, Y + _h - 3, Y + 3)
                SetImageState(p.pic, "", index * A * 200, 255, 255, 255)
                Render(p.pic, x1 + _h / 2, Y + _h / 2, 0, (_h - 6 - 12) / 256)
                --RenderRect(p.pic, x1 + 6, x1 + _h - 6, Y + 6, Y + _h - 6)

                SetImageState("white", "", index * A * 255, 200, 200, 200)
                misc.RenderOutLine("white", x1 + 6, x1 + _h - 6, Y + _h - 6, Y + 6, 0, 2)
                RenderRect("white", x1 + _h + 1, x1 + _h - 1, Y + _h, Y)
                local name = p.title2
                if t.subtitle and (not t.free or #stagedata.chooseInitial > 5) then
                    name = name .. ("(%s)"):format(t.subtitle)
                end
                ui:RenderText("big_text", name, x1 + _h + 3, Y + _h - 4,
                        0.45, Color(index * A * 255, p.R, p.G, p.B), "left", "top")
                for k, text in ipairs(sp:SplitText(p.describe, "\n")) do
                    ui:RenderTextWithCommand("title", text, x1 + _h + 8, Y + _h - 10 - k * 18,
                            0.8, index * A * 200, "left")
                end
                --ui:RenderTextInWidth("title", p.describe, x1 + _h + 8, Y + _h - 32,0.8, self.w * 2 - 150, Color(index * A * 255, p.R, p.G, p.B), "left", "top")
                RenderRect("white", x1, x2, Y - 1, Y + 1)
                SetImageState("menu_circle", "", A * index * 200, 200, 200, 200)
                Render("menu_circle", x2 - _h / 2, Y + _h / 2, 0, 0.16)
                ui:RenderText("big_text", "●", x2 - _h / 2, Y + _h / 2 + 2,
                        (index - 0.6) / 0.4, Color(A * 185, 189, 252, 201), "centerpoint")
                if p:Noticeinitial() then
                    SetImageState("menu_newicon", "", A * 200 * index, 200, 200, 200)
                    Render("menu_newicon", x2 - _h / 2, Y + _h / 2, 0, 0.65)
                end
            end

        end
        SetViewMode("ui")
    end
    self.exit_button:render(A)
    CheatMode:render(A)
    self.save_button:render(A)
    self.load_button:render(A)
    self.clear_button:render(A)
    Detail_Submenu:render()
    PreSetAddtionSelect:render()
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

    self.tool = tool
    self._offy1 = 0
    task.New(self, function()

        for i = 1, 16 do
            self.alpha = task.SetMode[2](i / 16)
            task.Wait()
        end
        self.locked = false
    end)

end
function Detail_Submenu:Out()
    task.New(self, function()
        self.locked = true
        self.mainmenu.lock = false
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
    local mouse = ext.mouse
    self.exit_button:frame()
    if menu:keyYes() or menu:keyNo() or mouse:isUp(1) then
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
        if self.tool.isActive then
            self.linecount1 = menu:RenderActiveDescribe(self.tool, x1, x2, y1, y2,
                    80 * T, self.offy1, self.line_h_1, A, A, self.timer)
        else
            self.linecount1 = menu:RenderToolDescribe(self.tool, x1, x2, y1, y2,
                    80 * T, self.offy1, self.line_h_1, A, A, self.timer)
        end
    end
    self.exit_button:render(A)
end

function Addition_select_informationRead:init(mainmenu, x, y)
    self.x, self.y = x, y
    self.func = function()
        New(SimpleNotice, self.mainmenu, _t("aboutInitialTake"), _t("initialTakeInformation"), 220, 130)
    end
    self.index = 0
    self.timer = 0
    self.r = 20
    self.selected = false
    self.locked = false
    self.mainmenu = mainmenu
end
function Addition_select_informationRead:frame()
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
function Addition_select_informationRead:render(A)
    local k = self.index
    local _alpha = (150 + k * 50) * A
    local ax, ay = self.x, self.y
    local adsize = self.r + k * 10
    SetImageState("menu_questionicon", "", _alpha, 200, 200, 200)
    Render("menu_questionicon", ax, ay, 0, adsize / 64)
end

function CheatMode:init(mainmenu, x, y)
    self.x, self.y = x, y
    self.func = function()
        if not scoredata.cheatMode_show then
            New(SimpleChoose, mainmenu, function()
                scoredata.cheatMode_show = true
                AdditionSelect_Submenu:refresh()
            end, load(""), _t("cheatMode"), _t("cheatModeInformation"), 250, 100)

        else

            scoredata.cheatMode_show = false
            AdditionSelect_Submenu:refresh()
        end
    end
    self.index = 0
    self.timer = 0
    self.r = 60
    self.selected = false
    self.locked = false
    self.mainmenu = mainmenu
    self.keyname = KeyCodeToName()
    self.select_index = 0
end
function CheatMode:frame()
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
    local sindex = scoredata.cheatMode_show and 1 or 0
    self.select_index = self.select_index + (-self.select_index + sindex) * 0.3
end
function CheatMode:render(A)
    local k = self.index
    local _alpha = (150 + k * 50) * A
    local ax, ay = self.x, self.y
    local adsize = self.r + k * 10
    SetImageState("menu_circle", "", _alpha, 200, 200, 200)
    Render("menu_circle", ax, ay, 0, adsize / 192)
    local wpimg = "boom"
    SetImageState(wpimg, "mul+add", _alpha, 200, 200, 200)
    Render(wpimg, ax, ay, 0, adsize / 96 * self.select_index)
    ui:RenderText("pretty", _t("cheatMode"), ax, ay,
            0.5, Color(_alpha, 255 - self.select_index * 100, 255, 255 - self.select_index * 100), "centerpoint")
end

function PreSetAddtionSelect:init()
    self.x, self.y = 480, 270
    self.w, self.h = 300, 220
    self.alpha = 0
    self.locked = true
    self.offy1 = 0
    self._offy1 = 0
    self.line_h_1 = 50
    self.timer = 0
    self:refresh()
    self.exit_button = ExitButton(810, 480, function()
        self:Out()
        PlaySound("cancel00")
    end)
end
function PreSetAddtionSelect:refresh()
    self.infodata = stagedata.presetInitial

    self._offy1 = 0
    self.index = {}
    self.chosen = {}
    for i in ipairs(self.infodata) do
        self.index[i] = 0.6
        self.chosen[i] = false
    end
end
function PreSetAddtionSelect:In()
    PlaySound("select00")
    self.locked = false
    self:refresh()
    Detail_Submenu:init(self)
    task.New(self, function()
        for i = 1, 16 do
            self.alpha = task.SetMode[2](i / 16)
            task.Wait()
        end
    end)

end
function PreSetAddtionSelect:Out()

    task.New(self, function()
        self.locked = true
        AdditionSelect_Submenu.locked = false
        for i = 1, 16 do
            self.alpha = 1 - i / 16
            task.Wait()
        end

    end)
end
function PreSetAddtionSelect:frame()
    self.timer = self.timer + 1
    task.Do(self)
    if self.locked then
        return
    end
    local mouse = ext.mouse
    menu:Updatekey()
    local alpha = self.alpha
    local x1, x2, y1, y2, h
    x1, x2, y1, y2 = self.x - self.w * alpha, self.x + self.w * alpha, self.y - self.h, self.y + self.h
    h = y2 - y1
    self._offy1 = self._offy1 + (-self._offy1 + clamp(self._offy1, 0, max(self.line_h_1 * #self.infodata - h, 0))) * 0.3
    self.offy1 = self.offy1 + (-self.offy1 + self._offy1) * 0.3
    if sp.math.PointBoundCheck(mouse.x, mouse.y, x1, x2, y1, y2) then
        if mouse._wheel ~= 0 then
            self._offy1 = self._offy1 - sign(mouse._wheel) * self.line_h_1 * 4
            PlaySound("select00")
        end
    end
    if menu:keyUp() then
        self._offy1 = self._offy1 - self.line_h_1 * 4
        PlaySound("select00")
    end
    if menu:keyDown() then
        self._offy1 = self._offy1 + self.line_h_1 * 4
        PlaySound("select00")
    end
    self.exit_button:frame()
    if menu:keyYes() or menu:keyNo() or menu.key == setting.keys.special then
        self.exit_button.func()
    end

    local _h = self.line_h_1
    local Y = self.y + self.h + self.offy1 - _h * (#self.infodata + 1)
    for i = #self.infodata, 1, -1 do
        local t = self.infodata[i]
        if Y > y2 then
            break
        end
        Y = Y + _h
        if sp.math.PointBoundCheck(mouse.x, mouse.y, x1, x2, Y, Y + _h) then
            self.chosen[i] = true
            if mouse:isUp(1) then
                if mouse.x > x2 - _h and mouse.x < x2 then
                    New(SimpleChoose, self, function()
                        table.remove(self.infodata, i)
                        New(info, _t("haveDeletedPreset"), 130, 20)
                        PlaySound("lgods1")
                    end, load(""), "Warning", _t("warningDelPreset"), 150, 60)

                else
                    PlaySound("ok00")
                    self:Out()
                    stagedata.chooseInitial = sp:CopyTable(t)
                    scoredata.cheatMode_show = t[#t]
                    stagedata.chooseInitial[#stagedata.chooseInitial] = nil

                    AdditionSelect_Submenu:refresh()
                end
            end
        else
            self.chosen[i] = false
        end

    end
end
function PreSetAddtionSelect:render()
    local A = self.alpha
    if A == 0 then
        return
    end
    do

        local alpha = self.alpha
        local x1, x2, y1, y2, Y

        x1, x2, y1, y2 = self.x - self.w * alpha, self.x + self.w * alpha, self.y - self.h, self.y + self.h
        SetImageState("white", "", alpha * 180, 0, 0, 0)
        RenderRect("white", 0, 960, 0, 540)
        SetImageState("white", "", alpha * 180, 10, 10, 10)
        RenderRect("white", x1, x2, y1, y2)
        SetImageState("white", "", alpha * 255, 255, 255, 255)
        misc.RenderOutLine("white", x1, x2, y2, y1, 0, 2)
        SetRenderRect(x1, x2, y1 - self.offy1, y2 - self.offy1, x1, x2, y1, y2)
        Y = y2
        RenderRect("white", x1, x2, Y - 0.5, Y + 0.5)
        local _h = self.line_h_1
        for i, t in ipairs(self.infodata) do
            if Y < y1 - self.offy1 then
                break
            end
            Y = Y - _h
            if Y < y2 - self.offy1 then
                ---@type addition_unit
                local _index = self.chosen[i] and 1 or 0.6
                self.index[i] = self.index[i] + (-self.index[i] + _index) * 0.2
                local index = self.index[i]
                SetImageState("white", "", index * A * 75, 200, 200, 200)
                RenderRect("white", x1 + 3, x2 - 3, Y + _h - 3, Y + 3)
                --RenderRect(p.pic, x1 + 6, x1 + _h - 6, Y + 6, Y + _h - 6)
                ui:RenderText("pretty", _t("Preset") .. i, x1 + 5, Y + _h - 4,
                        0.7, Color(index * A * 255, 200, 200, 200), "left", "top")
                local c = #t - 1
                local kc = (c + 1) / 2
                local w = min(40, 320 / c)
                for k = 1, c do
                    if t[k][1] > 0 then
                        local tool = GetChooseInitialByID(t[k])
                        local x, y = (x1 + x2) / 2 + (k - kc) * w, Y + _h / 2
                        local size = (_h - 30)
                        SetImageState("menu_circle", "", index * A * 200, 200, 200, 200)
                        Render("menu_circle", x, y, 0, size / 192)
                        SetImageState("menu_pure_circle", "mul+add", index * A * 50, tool.R, tool.G, tool.B)
                        Render("menu_pure_circle", x, y, 0, (size - 1) / 125)
                        SetImageState(tool.pic, "", index * A * 200, 200, 200, 200)
                        Render(tool.pic, x, y, 0, size / 175)
                    end

                end
                --ui:RenderTextInWidth("title", p.describe, x1 + _h + 8, Y + _h - 32,0.8, self.w * 2 - 150, Color(index * A * 255, p.R, p.G, p.B), "left", "top")
                SetImageState("white", "", index * A * 255, 200, 200, 200)
                RenderRect("white", x1, x2, Y - 1, Y + 1)
                RenderRect("white", x2 - _h - 1, x2 - _h + 1, Y, Y + _h)
                SetImageState("addition_state4", "", index * A * 200, 0, 0, 0)
                Render("addition_state4", x2 - _h / 2 + 1, Y + _h / 2 - 1, 0, _h / 280)
                SetImageState("addition_state4", "", index * A * 200, 250, 128, 114)
                Render("addition_state4", x2 - _h / 2, Y + _h / 2, 0, _h / 280)
                if t[6] then
                    ui:RenderText("pretty", _t("cheatMode"), x2 - _h - 3, Y + 3, 0.4,
                            Color(index * A * 255, 255, 227, 132), "right", "bottom")
                end

            end

        end
        SetViewMode("ui")
    end
    self.exit_button:render(A)
end

attrmenu.GetChooseInitial2INDEX = GetChooseInitial2INDEX
attrmenu.GetChooseInitial2LEVEL = GetChooseInitial2LEVEL
attrmenu.GetChooseInitialByID = GetChooseInitialByID
attrmenu.ChooseInitialIsUnit = ChooseInitialIsUnit
attrmenu.GetChooseInitialTable = GetChooseInitialTable
attrmenu.PlayerSelect = PlayerSelect
attrmenu.SpellSelect = SpellSelect
attrmenu.DiffSelect = DiffSelect
attrmenu.AdditionSelect = AdditionSelect
attrmenu.Addition_select_informationRead = Addition_select_informationRead
attrmenu.PlayerSelect_Submenu = PlayerSelect_Submenu
attrmenu.SpellSelect_Submenu = SpellSelect_Submenu
attrmenu.AdditionSelect_Submenu = AdditionSelect_Submenu
attrmenu.Detail_Submenu = Detail_Submenu
attrmenu.CheatMode = CheatMode
attrmenu.CheatMode_COST = { 500, 1000, 2000, 5000, 10000, }
attrmenu.PreSetAddtionSelect = PreSetAddtionSelect