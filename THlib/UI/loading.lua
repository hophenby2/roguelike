local function EnumPNG(list, searchPath, func)
    for _, v in ipairs(lstg.FileManager.EnumFiles(searchPath, "png", true)) do
        local path = v[1]
        local name = path:sub(searchPath:len() + 1, -5)
        table.insert(list, function()
            func(name, path)
        end)
    end
end

local function GetLoadingFile()
    local list = {}

    EnumPNG(list, "assets\\BossBackGround\\", LoadTexture2)
    EnumPNG(list, "assets\\BossImage\\", LoadTexture)
    EnumPNG(list, "assets\\Special\\", LoadImageFromFile)
    for _, v in ipairs(FindFiles('assets\\se\\', 'wav', '')) do
        local name = string.sub(v[1], 14, -5)
        table.insert(list, function()
            LoadSound(name, 'assets\\se\\se_' .. name .. '.wav')
        end)
    end
    stg_levelUPlib.DefineAddition()
    activeItem_lib.DefineActive()
    mission_lib.InitMission()

    for _, v1 in ipairs(LoadRes) do
        table.insert(list, v1)
    end
    table.insert(list, function()
        InitAllClass()
        checkJargonCommand()
        for id, mission in ipairs(mission_lib.MissionList) do
            if mission.tool:Unlock() and not mission.data.open then
                mission_lib.GoMission(id)
            end
            if mission.data.open then
                mission.tool:SetUnlock()
            end
        end
    end)

    return list
end

LoadImageFromFile("loading", "assets\\UI\\loading.png")
loadLanguageModule("sth", "THlib\\UI\\lang")
local function _t(str)
    return i18n("sth", str) or ""
end

local string = string
local clock = os.clock

local Color = Color
--0.016666666666
local time = 1 / 60

local Text = TIP

local stage_init = stage.New('init', false, true)
function stage_init:init()
    math.randomseed(os.time())
    self.start_time = clock()
    self.res = GetLoadingFile()
    self.index = 1
    self.maxindex = #self.res
    self.textindex = math.random(1, #Text)
    self.text = Text[self.textindex]
    self.settime = self.timer
    self.alpha = 0
    SetResourceStatus("global")
    task.New(self, function()
        while not self.jump do
            task.Wait()
        end
        SetResourceStatus("stage")
        --   Print("\n\n\n\n" .. (clock() - self.start_time) .. "\n\n\n\n")
        mask_fader:Do("close", 60)
        GlobalLoading = true
        GlobalAddAchievement = true
        task.Wait(60)
        if not scoredata.PlayerBrand then
            stage.Set('none', "setname")
        else
            if scoredata.guide_flag == 0 then
                stage.Set('none', "guide0")
            else
                stage.Set('none', "main")
            end
        end
        self.stop_render = true
        for i = 1, 2 do
            lstg.RemoveResource("global", i, "loading")
            --lstg.RemoveResource("global", i, "load_warning1")
            -- lstg.RemoveResource("global", i, "load_warning2")
        end
    end)
end
function stage_init:frame()
    self.alpha = self.alpha + (-self.alpha + 1) * 0.05
    self.timer = int((clock() - self.start_time) * 60)
    if self.timer - self.settime > 150 then
        local t = self.textindex
        while self.textindex == t do
            self.textindex = math.random(1, #Text)
        end
        self.text = Text[self.textindex]
        self.settime = self.timer
    end
    if self.index > self.maxindex then
        self.jump = true
    elseif not self.jump then
        local resFunc
        local start_time, end_time = clock(), clock()
        while end_time - start_time <= time do
            if self.index > self.maxindex then
                break
            end
            resFunc = self.res[self.index]
            if resFunc then
                resFunc()
            end
            self.index = self.index + 1
            end_time = clock()
        end
    end
end
function stage_init:render()
    if self.stop_render then
        return
    end
    SetImageState("white", "", 255, 0, 0, 0)
    RenderRect("white", 0, screen.width, 0, screen.height)
    SetImageState("loading", "", self.alpha * 255, 255, 255, 255)
    Render("loading", 480, 270, 0, 960 / 1600)
    local length = min(self.index / self.maxindex, 1)
    SetImageState("white", "", 255 * self.alpha, 255, 255, 255)
    misc.RenderOutLine("white", 222, 738, 80, 65, 0, 2)
    --RenderRect("white", 220, 740, 63, 82)
    SetImageState("white", "", 255 * self.alpha, 0, 0, 0)
    RenderRect("white", 222, 738, 65, 80)
    SetImageState("white", "",
            Color(180 * self.alpha, 255 - 155 * length, 255 * length, 0 + 100 * length))
    RenderRect("white", 222, 222 + length * 516, 65, 80)
    SetFontState("Score", "",
            Color(255 * self.alpha, 255 * length, 255 - 28 * length, 100 + 32 * length))
    RenderText("Score", ("%0.2f%%"):format(length * 100), 480, 80, 0.3, "center")

    ui:RenderText("title", _t("loading") .. string.rep(".", int(self.timer / 20 % 6) + 1),
            480, 45, 1, Color(self.alpha * 255, 255, 227, 132), "centerpoint")
    ui:RenderText("small_text", "Tips : " .. self.text,
            480, 170, 1.15, Color(self.alpha * 255, 250, 128, 114 + 50 * sin(self.timer * 2)), "centerpoint")
end

local _keyboard = {}
do
    for i = 65, 90 do
        table.insert(_keyboard, i)
    end
    for i = 97, 122 do
        table.insert(_keyboard, i)
    end
    for i = 48, 57 do
        table.insert(_keyboard, i)
    end
    for _, i in ipairs({ 43, 45, 61, 46, 44, 33, 63, 64, 58, 59, 91, 93, 40, 41, 95, 47, 123, 125, 124, 126, 94 }) do
        table.insert(_keyboard, i)
    end
    for i = 35, 38 do
        table.insert(_keyboard, i)
    end
    for _, i in ipairs({ 42, 92, 127, 34 }) do
        table.insert(_keyboard, i)
    end
end

local stage_other = stage.New('setname', false, true)
function stage_other:init()
    mask_fader:Do("open")
    self.state2CursorX = 0
    self.state2CursorY = 0
    self.shakeValue = 0
    self.alpha = 1
    self.x, self.y = 480, 200
    self.state2UserName = ""
    function self:exitCallback()
        self.jump = true
        scoredata.PlayerBrand = self.state2UserName
        task.New(self, function()
            mask_fader:Do("close")
            task.Wait(15)
            if scoredata.guide_flag == 0 then
                stage.Set('none', "guide0")
            else
                stage.Set('none', "main")
            end
        end)
    end
end
function stage_other:frame()
    if not self.jump then
        local mouse = ext.mouse
        local Yes = function()
            if self.state2CursorX == 12 and self.state2CursorY == 6 then
                if #self.state2UserName < 2 then
                    PlaySound("invalid")
                else
                    self:exitCallback()
                    PlaySound("extend", 0.5)
                end
            else
                if self.state2CursorX == 10 and self.state2CursorY == 6 then
                    local char = string.char(0x20)
                    self.state2UserName = self.state2UserName .. char
                    PlaySound('ok00', 0.3)
                elseif self.state2CursorX == 11 and self.state2CursorY == 6 then
                    if #self.state2UserName == 0 then
                        self.state = 0
                    else
                        self.state2UserName = string.sub(self.state2UserName, 1, -2)
                    end
                    PlaySound('cancel00', 0.3)
                elseif #self.state2UserName == 20 then
                    self.state2CursorX = 12
                    self.state2CursorY = 6
                else
                    local char = string.char(_keyboard[self.state2CursorY * 13 + self.state2CursorX + 1])
                    self.state2UserName = self.state2UserName .. char
                    PlaySound('ok00', 0.3)
                end
            end
        end
        menu:Updatekey()
        if self.shakeValue > 0 then
            self.shakeValue = self.shakeValue - 1
        end
        if menu:keyYes() then
            Yes()
        elseif menu:keyNo() then
            if #self.state2UserName == 0 then
                stage.QuitGame()
            else
                self.state2UserName = string.sub(self.state2UserName, 1, -2)
            end
            PlaySound('cancel00', 0.3)
        else
            if menu:keyUp() then
                self.state2CursorY = self.state2CursorY - 1
                self.shakeValue = ui.menu.shake_time
                PlaySound('select00', 0.3)
            end
            if menu:keyDown() then
                self.state2CursorY = self.state2CursorY + 1
                self.shakeValue = ui.menu.shake_time
                PlaySound('select00', 0.3)
            end
            if menu:keyLeft() then
                self.state2CursorX = self.state2CursorX - 1
                self.shakeValue = ui.menu.shake_time
                PlaySound('select00', 0.3)
            end
            if menu:keyRight() then
                self.state2CursorX = self.state2CursorX + 1
                self.shakeValue = ui.menu.shake_time
                PlaySound('select00', 0.3)
            end
            if mouse:isUp(1) then
                local width, height = ui.menu.char_width, ui.menu.line_height
                local x, y = (function()
                    for x = 0, 12 do
                        for y = 0, 6 do
                            if abs(mouse.x - (self.x + (x - 5.5) * width)) < width / 2 and abs(mouse.y - (self.y - (y - 3.5) * height)) < height / 2 then
                                return x, y
                            end
                        end
                    end
                end)()
                if x and y then
                    self.state2CursorX = x
                    self.state2CursorY = y
                    Yes()
                    PlaySound('select00', 0.3)
                end
            end
            if mouse._wheel ~= 0 then
                self.state2CursorX = self.state2CursorX - sign(mouse._wheel)
                if self.state2CursorX == 13 then
                    self.state2CursorY = self.state2CursorY + 1
                    self.state2CursorX = 0
                end
                if self.state2CursorX == -1 then
                    self.state2CursorY = self.state2CursorY - 1
                    self.state2CursorX = 12
                end
                self.shakeValue = ui.menu.shake_time
                PlaySound('select00', 0.3)
            end
            self.state2CursorX = sp:TweakValue(self.state2CursorX, 13, 0)
            self.state2CursorY = sp:TweakValue(self.state2CursorY, 7, 0)
        end
    end

end
function stage_other:render()
    local text = ({
        [[请输入您的昵称 ( 2 ~ 20 个字符 )
----确定结果后将无法修改----]],
        [[Please Input Your Name (2~20chars)
----the result cannot be modified----]]
    })[setting.language]
    RenderTTF("pretty_title", text, self.x, 430, Color(255, 255, 255, 255), "center")
    local font = "replay"
    -- 标题
    SetFontState(font, "", 255 * self.alpha, unpack(ui.menu.title_color))
    RenderText(font, self.state2UserName, self.x, self.y - 5.5 * ui.menu.line_height + 320 - self.alpha * 320, ui.menu.font_size, "centerpoint")

    ---- 绘制键盘
    -- 未选中按键
    SetFontState(font, "", 255 * self.alpha, unpack(ui.menu.unfocused_color))
    for x = 0, 12 do
        for y = 0, 6 do
            if x ~= self.state2CursorX or y ~= self.state2CursorY then
                RenderText(font, string.char(_keyboard[y * 13 + x + 1]),
                        self.x + (x - 5.5) * ui.menu.char_width, self.y - (y - 3.5) * ui.menu.line_height + 320 - self.alpha * 320,
                        ui.menu.font_size, 'centerpoint')
            end
        end
    end
    -- 激活按键
    local color = {}
    local k = cos(self.timer * ui.menu.blink_speed) ^ 2
    for i = 1, 3 do
        color[i] = ui.menu.focused_color1[i] * k + ui.menu.focused_color2[i] * (1 - k)
    end
    SetFontState(font, "", 255 * self.alpha, unpack(color))
    RenderText(font, string.char(_keyboard[self.state2CursorY * 13 + self.state2CursorX + 1]),
            self.x + (self.state2CursorX - 5.5) * ui.menu.char_width + ui.menu.shake_range * sin(ui.menu.shake_speed * self.shakeValue),
            self.y - (self.state2CursorY - 3.5) * ui.menu.line_height + 320 - self.alpha * 320,
            ui.menu.font_size, "centerpoint")

end

local stage_guide0 = stage.New('guide0', false, true)
function stage_guide0:init()
    New(SimpleChoose, self, function()
        scoredata.guide_flag = 1
        -- lstg.nexttmpvar = { noPause = true }
        menu.FadeOut(self)
        GotoTutorial(self)
    end, function()
        task.New(self, function()
            scoredata.guide_flag = 1
            mask_fader:Do("close")
            task.Wait(15)
            stage.Set("none", "main")
        end)
    end, _t("guidance"), _t("tutorialWarning"), 200, 100)
    PlaySound("ok00")
end


