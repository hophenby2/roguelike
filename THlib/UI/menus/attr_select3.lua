local PlayerSelect = attributeselectmenu.PlayerSelect
local SpellSelect = attributeselectmenu.SpellSelect
local DiffSelect = {  }
local AdditionSelect = attributeselectmenu.AdditionSelect
local Addition_select_informationRead = attributeselectmenu.Addition_select_informationRead
local PlayerSelect_Submenu = attributeselectmenu.PlayerSelect_Submenu
local SpellSelect_Submenu = attributeselectmenu.SpellSelect_Submenu
local AdditionSelect_Submenu = attributeselectmenu.AdditionSelect_Submenu

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
    SetImageState("menu_button", "", A * 200, 200 - k * 50, 200, 200 - k * 50)
    Render("menu_button", x, y, 0, s * self.w / 230, s * self.h / 48)

    ui:RenderText("pretty_title", self.text, x, y + 0.5,
            1 + k * 0.05, Color(A * 200, blk - k * 50, blk, blk - k * 50), "centerpoint")
end

local function _t(str)
    return i18n("sth", str) or ""
end

attributeselectmenu3 = stage.New("attr_select3", false, true)

attributeselectmenu3.general_buttonFrame = general_buttonFrame
attributeselectmenu3.general_buttonRender = general_buttonRender
function attributeselectmenu3:init()
    local title
    if lstg.var.practice_mode == "wave" then
        title = SceneClass[lstg.var.practice_inscene].events[lstg.var.practice_id].title
    else
        title = weather_lib.weather[lstg.var.practice_weather].name
    end

    self.top_bar = top_bar_Class(self, title)
    self.top_bar:addReturnButton(function()
        self.exit_func()
    end)
    mainmenu:MusicInit()
    mask_fader:Do("open")
    PlayerSelect:init(self)
    if lstg.var.practice_mode == "wave" then
        PlayerSelect.back = SceneClass[lstg.var.practice_inscene].tex
    else
        PlayerSelect.back = "star_back"
    end
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
            stage.Set("none", "handbook")
            if lstg.var.practice_mode == "wave" then
                handbook_menu.goto_pos = 1
            else
                handbook_menu.goto_pos = 3
            end
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
                local cost = false
                local function Start()
                    self.locked = true
                    lstg.var.player_select = stagedata.player_pos
                    FUNDAMENTAL_MENU.music:FadeStop(15)
                    mask_fader:Do("close")
                    task.Wait(15)
                    local var = lstg.var
                    if var.practice_mode == "wave" then
                        local inStageID = SceneClass[var.practice_inscene].inStageID
                        stage.group.Start(stage.groups["practice" .. inStageID])
                    else
                        stage.group.Start(stage.groups["practice1"])
                    end

                end
                for i = 1, #stagedata.chooseInitial do
                    local choose = stagedata.chooseInitial[i]
                    if choose ~= 0 then
                        local unit = stg_levelUPlib.AdditionTotalList[choose]
                        if scoredata.initialAddition[choose] and #stagedata.chooseInitial <= 5 then
                        elseif scoredata.cheatMode_show then
                            cost = true
                        end
                    end
                end
                if cost then
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
        self.locked = false
    end)
end
function attributeselectmenu3:frame()
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
function attributeselectmenu3:render()
    ui:DrawBack(1, self.timer)
    PlayerSelect:render()
    SpellSelect:render()
    DiffSelect:render()
    AdditionSelect:render()
    self.start_button:render()
    ui:RenderText("title", _t("practiceModeWarning"),
            480, 470, 1, Color(150, 250, 128, 114), "centerpoint")
    self.top_bar:render()
    Addition_select_informationRead:render(1)
    PlayerSelect_Submenu:render()
    SpellSelect_Submenu:render()
    AdditionSelect_Submenu:render()

end

function DiffSelect:init()
    self.x, self.y = 170, 255
    self.w, self.h = 122, 135
    self.index = 0
    self.timer = 0
    self.r = 58
    self.selected = false
    self.text = _t("selInitialChaos")
    self.id = lstg.var.scene_id
    self.pos = 1
    self.diff_obj = {
        {
            title = "0%",
            colH = 135
        },
        {
            title = "50%",
            colH = 45
        },
        {
            title = "100%",
            colH = 0
        },
        {
            title = "150%",
            colH = 270
        },
        {
            title = "200%",
            colH = 315
        },
    }
    self.pos = stagedata.practice_diff_pos
end
function DiffSelect:frame()
    stagedata.practice_diff_pos = self.pos
    lstg.var.practice_chaos = (self.pos - 1) * 50
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
            self.pos = sp:TweakValue(self.pos - sign(mouse._wheel), #self.diff_obj, 1)
            self.index = self.index + 0.5
            PlaySound("select00")
        end
        if mouse:isUp(1) then
            for i = 1, #self.diff_obj do
                local _w = (y2 - y1) / #self.diff_obj
                local _y = y2 - _w * (i - 0.5)
                if sp.math.PointBoundCheck(mouse.x, mouse.y, x1, x2, _y - _w / 2, _y + _w / 2) then
                    self.pos = i
                end
            end
            self.index = self.index + 0.5
            PlaySound("select00")
        end
    end
    if menu:keyDown() then
        self.pos = sp:TweakValue(self.pos + 1, #self.diff_obj, 1)
        self.index = self.index + 0.5
        PlaySound("select00")
    end
    if menu:keyUp() then
        self.pos = sp:TweakValue(self.pos - 1, #self.diff_obj, 1)
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
        local _w = (y2 - y1) / #self.diff_obj
        local _y = y2 - _w * (i - 0.5)
        local index = ((self.pos == i) and (k * 0.2 + 0.8) or (k * 0.1 + 0.2))
        SetImageState("white", "", index * 150, sp:HSVtoRGB(p.colH, 0.4, 1))
        RenderRect("white", x1 + 4, x2 - 4, _y - _w / 2 + 4, _y + _w / 2 - 4)
        ui:RenderText("big_text", p.title, (x1 + x2) / 2, _y + 2, 1,
                Color(index * 255, sp:HSVtoRGB(p.colH, 0.3, 1)), "centerpoint")
    end
    SetImageState("white", "", 255, 200 - k * 15, 200, 200 - k * 15)

    misc.RenderOutLine("white", x1, x2, y2, y1, 3, 0)
    for i = 1, #self.diff_obj - 1 do
        local _y = y2 - (y2 - y1) / #self.diff_obj * i
        misc.RenderOutLine("white", x1, x2, _y, _y, 1.5, 0)
    end
end