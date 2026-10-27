local PlayerSelect = attributeselectmenu.PlayerSelect
local SpellSelect = attributeselectmenu.SpellSelect
local PlayerSelect_Submenu = attributeselectmenu.PlayerSelect_Submenu
local SpellSelect_Submenu = attributeselectmenu.SpellSelect_Submenu

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

attributeselectmenu2 = stage.New("attr_select2", false, true)

attributeselectmenu2.general_buttonFrame = general_buttonFrame
attributeselectmenu2.general_buttonRender = general_buttonRender
function attributeselectmenu2:init()
    self.top_bar = top_bar_Class(self, challenge_lib.class[lstg.var.challenge_select].title)
    self.top_bar:addReturnButton(function()
        self.exit_func()
    end)
    mainmenu:MusicInit()
    mask_fader:Do("open")
    PlayerSelect:init(self)
    SpellSelect:init(self)

    PlayerSelect_Submenu:init(self)
    SpellSelect_Submenu:init(self)
    PlayerSelect.back="star_back"
    self.exit_func = function()
        PlaySound("cancel00")
        task.New(self, function()
            self.locked = true
            mask_fader:Do("close")
            task.Wait(15)
            stage.Set("none", "challenge")
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
                self.locked = true
                lstg.var.player_select = stagedata.player_pos
                FUNDAMENTAL_MENU.music:FadeStop(15)
                mask_fader:Do("close")
                task.Wait(15)
                local ID = challenge_lib.class[lstg.var.challenge_select].inStageID
                stage.group.Start(stage.groups["Challenge" .. ID])
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
function attributeselectmenu2:frame()
    PlayerSelect_Submenu:frame()
    SpellSelect_Submenu:frame()

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
    self.start_button:frame()


end
function attributeselectmenu2:render()
    ui:DrawBack(1, self.timer)
    PlayerSelect:render()
    SpellSelect:render()
    self.start_button:render()
    self.top_bar:render()
    PlayerSelect_Submenu:render()
    SpellSelect_Submenu:render()

end