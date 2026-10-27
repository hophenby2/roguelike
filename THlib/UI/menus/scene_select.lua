local function GotoTutorial(self)
    task.New(self, function()
        self.locked = true
        lstg.var.player_select = stagedata.player_pos
        if FUNDAMENTAL_MENU then
            FUNDAMENTAL_MENU.music:FadeStop(15)
        end
        mask_fader:Do("close")
        task.Wait(15)
        stage.group.Start(stage.groups["Tutorial0"])
    end)
end
_G.GotoTutorial = GotoTutorial

local function GotoChallenge(self)

    task.New(self, function()
        self.locked = true
        mask_fader:Do("close")
        task.Wait(15)
        stage.Set("none", "challenge")
    end)
end
_G.GotoChallenge = GotoChallenge

local function _t(str)
    return i18n("sth", str) or ""
end

sceneselectmenu = stage.New("scene_select", false, true)
function sceneselectmenu:init()
    lastmenu = self
    self.top_bar = top_bar_Class(self, _t("sceneSelect"))
    self.exit_func2 = function()
        task.New(self, function()
            self.locked = true
            mask_fader:Do("close")
            task.Wait(15)
            stage.Set("none", "main")
        end)
    end
    self.top_bar:addReturnButton(self.exit_func2)
    mainmenu:MusicInit()
    mask_fader:Do("open")
    self.locked = true
    self.scene_select = sp:CopyTable(SceneClass)
    self.ox = 0
    self.moveUnit = 70
    self.pulseUnit = 100
    self.select_buling = 0
    self.scene_count = #self.scene_select
    self.pos = clamp(1, stagedata.SceneSelection, self.scene_count)

    self.diff_pos = stagedata.DiffSelection[self.pos]
    self.tutorial_button = {
        col_flag = 0,
        x1 = 0, x2 = 80,
        y1 = 0, y2 = 35
    }
    self.challenge_button = {
        col_flag = 0,
        x1 = 80, x2 = 160,
        y1 = 0, y2 = 35
    }
    self.timer = 0
    self.alpha = 1
    self.selected = false
    self.info_alpha = 0
    self:fresh()
    task.New(self, function()
        task.Wait(30)
        while GetKeyState(KEY.Z) do
            task.Wait()
        end
        self.locked = false
        if scoredata.guide_flag == 1 then
            New(SimpleChoose, self, function()
                task.New(self, function()
                    if FUNDAMENTAL_MENU then
                        FUNDAMENTAL_MENU.music:FadeStop(15)
                    end
                    scoredata.guide_flag = 2
                    lstg.var.player_select = stagedata.player_pos
                    mask_fader:Do("close")
                    task.Wait(15)
                    lstg.var.scene_id = 1
                    local scene = lstg.var.scene_id
                    stage.group.Start(stage.groups["Tutorial" .. scene])
                end)
            end, function()
                scoredata.guide_flag = 2
            end, _t("guidance"), _t("directTutorialGuide"), 200, 100)
        end
    end)
end
function sceneselectmenu:choose_func()
    PlaySound("ok00")
    local function Go()
        lstg.var.scene_id = self.pos
        task.New(self, function()
            for i = 1, 20 do
                self.info_alpha = 1 - task.SetMode[2](i / 20)
                task.Wait()
            end
        end)
        task.New(self, function()
            self.locked = true
            mask_fader:Do("close")
            task.Wait(15)
            stage.Set("none", "attr_select")
        end)
    end
    if not self.selected then
        self.selected = true
        task.New(self, function()
            for i = 1, 20 do
                self.info_alpha = task.SetMode[2](i / 20)
                task.Wait()
            end
        end)
    else
        local scene = self.scene_select[self.pos]
        if scene.unlock_way() == true then
            self.selected = false
            Go()
        else
            New(UnlockWindow, self, scene.conditionList, function()
                stagedata.scene_unlock[tostring(scene.id)] = true
                ReFreshDaySceneLock()
                self:fresh()
                if scene.id == 3 then
                    scoredata.StartActive = true
                end
            end)
        end
    end

end
function sceneselectmenu:exit_func()
    if self.selected then
        task.New(self, function()
            for i = 1, 12 do
                self.info_alpha = 1 - task.SetMode[2](i / 12)
                task.Wait()
            end
        end)
        self.selected = false
        PlaySound("cancel00")
        return true

    end

end
function sceneselectmenu:fresh()

    self.unlocked_scenes = {}
    self.pos = max(1, self.pos)

    for t, d in ipairs(self.scene_select) do
        self.unlocked_scenes[t] = d.unlock_way() == true
    end
end
function sceneselectmenu:frame()
    self.timer = self.timer + 1
    self.ox = self.ox - self.ox * 0.07

    if self.locked then
        return
    end
    menu:Updatekey()
    stagedata.SceneSelection = self.pos
    local mouse = ext.mouse
    do
        local function SetPos(pos)
            local t = self.pos
            self.pos = sp:TweakValue(pos, self.scene_count, 1)
            self.ox = self.ox + (self.pos - t) * self.moveUnit
            self.diff_pos = stagedata.DiffSelection[self.pos]
            self:fresh()
            PlaySound('select00', 0.3)
        end

        if menu:keyLeft() then
            SetPos(self.pos - 1)
        end
        if menu:keyRight() then
            SetPos(self.pos + 1)
        end

        if menu:keyYes() then
            self:choose_func()
        end
        if menu:keyNo() then
            PlaySound("cancel00")
            if not self:exit_func() then
                self.exit_func2()
            end
        end
        do
            local flag
            local Pos = self.pos
            local width = self.moveUnit / 2 / 1.4 * 1.6
            local pulseUnit = self.pulseUnit
            for i, u in ipairs(self.scene_select) do
                local x = 480 + self.ox + (i - Pos) * self.moveUnit
                local pulse = u.pulse
                local way = sign(i - Pos) * pulseUnit * (1 - pulse + self.select_buling + self.info_alpha * 1.72)
                if mouse:isUp(1) then
                    local ox1, ox2 = 0, 0
                    if i == Pos then
                        ox1 = -self.info_alpha * 170
                        ox2 = self.info_alpha * 170
                    end
                    if sp.math.PointBoundCheck(mouse.x, mouse.y,
                            x - width - pulseUnit * pulse + way + ox1,
                            x + width + pulseUnit * pulse + way + ox2,
                            270 + 140 + 30 * pulse, 270 - 140 - 30 * pulse) then
                        if i == Pos then
                            self:choose_func()
                            flag = true
                            break
                        elseif self.scene_select[i] then

                            SetPos(i)
                            flag = true
                            break
                        end
                    end
                end
            end--点击包
            if not flag and mouse:isUp(1) then
                self:exit_func()
            end
            if mouse._wheel ~= 0 then
                SetPos(self.pos - sign(mouse._wheel))
                PlaySound('select00', 0.3)
            end
        end--鼠标
    end--主要操作
    local tutorbutton = self.tutorial_button
    if sp.math.PointBoundCheck(mouse.x, mouse.y, tutorbutton.x1, tutorbutton.x2, tutorbutton.y1, tutorbutton.y2) then
        tutorbutton.col_flag = tutorbutton.col_flag + (-tutorbutton.col_flag + 1) * 0.21
        if mouse:isUp(1) then
            New(SimpleChoose, self, function()
                menu.FadeOut(self)
                GotoTutorial(self)

            end, load(""), _t("tutorial"), _t("tutorialWarning"), 200, 100)
            PlaySound("ok00")
        end
    else
        tutorbutton.col_flag = tutorbutton.col_flag - tutorbutton.col_flag * 0.21
    end
    local challengebutton = self.challenge_button
    if sp.math.PointBoundCheck(mouse.x, mouse.y, challengebutton.x1, challengebutton.x2, challengebutton.y1, challengebutton.y2) then
        challengebutton.col_flag = challengebutton.col_flag + (-challengebutton.col_flag + 1) * 0.21
        if mouse:isUp(1) then
            GotoChallenge(self)
            PlaySound("ok00")
        end
    else
        challengebutton.col_flag = challengebutton.col_flag - challengebutton.col_flag * 0.21
    end
    if GetLastKey() == KEY.C then
        GotoChallenge(self)
        PlaySound("ok00")
    end
    self.top_bar:frame()
end
function sceneselectmenu:render()
    if self.alpha == 0 then
        return
    end
    local t = self.timer
    local ui = ui
    local Pos = self.pos
    local alpha = self.alpha
    ui:DrawBack(self.alpha, self.timer)
    do
        local x
        local width = self.moveUnit / 2 / 1.4
        local pulseUnit = self.pulseUnit
        for i, u in ipairs(self.scene_select) do
            x = 480 + self.ox + (i - Pos) * self.moveUnit
            if x > -width and x < 960 + width then
                local cindex = self.unlocked_scenes[i] and 1 or 0.4
                if i == Pos then
                    u.pulse = u.pulse + (-u.pulse + (1 + self.select_buling)) * 0.1
                else
                    u.pulse = u.pulse + (-u.pulse) * 0.1
                    cindex = cindex * 0.5
                end
                local pulse = u.pulse
                local way = sign(i - Pos) * pulseUnit * (1 - pulse + self.select_buling + self.info_alpha * 1.72)
                local x1, x2 = x - width - pulseUnit * pulse + way, x + width + pulseUnit * pulse + way
                local y1, y2 = 270 - 140 - 30 * pulse, 270 + 140 + 30 * pulse
                local r, g, b = sp:HSVtoRGB(i * 15 + t / 2 + x / 30, 1, 1)
                local offx, offy = 0, 0
                if i == Pos then
                    offx = -self.info_alpha * 170
                end
                x1, x2, y1, y2 = x1 + offx, x2 + offx, y1 + offy, y2 + offy
                for l = 1, 16 do
                    SetImageState("white", "mul+add", (17 - l) * alpha, r * cindex, g * cindex, b * cindex)
                    RenderRect("white", x1 - l, x2 + l, y1 - l, y2 + l)
                end
                if u.tex then
                    local size = 512 / GetTextureSize(u.tex) * 0.7
                    misc.RenderTexInRect(u.tex, x1, x2, y1, y2, 0, 0, 0, size, size, "",
                            Color(255 * alpha, 200 * cindex, 200 * cindex, 200 * cindex))
                end
                local ia = self.info_alpha
                SetImageState("white", "", 255 * alpha, 255 * cindex, 255 * cindex, 255 * cindex)
                misc.RenderOutLine("white", x1, x2, y2, y1, 0, 2)
                SetImageState("white", "", 155 * alpha, 0, 0, 0)
                RenderRect("white", x1, x2, y1, y1 + 20 + 23 * pulse)
                ui:RenderTextInWidth("title", u.title, x + way + offx, y1 + 10 + 13 * pulse,
                        0.4 + 0.8 * pulse, (width + pulseUnit * pulse) * 1.8,
                        Color(255 * alpha * (1 - ia), 255 * cindex, 255 * cindex, 255 * cindex), "centerpoint")
                if i == Pos then
                    if self.unlocked_scenes[i] then
                        ui:RenderText("title", "GO!!", x + way + offx, y1 + 10 + 13 * pulse, 1.5,
                                Color(255 * alpha * ia, 255 * cindex, 255 * cindex, 255 * cindex), "centerpoint")
                    else
                        ui:RenderText("title", "Unlock", x + way + offx, y1 + 10 + 13 * pulse, 1.5,
                                Color(255 * alpha * ia, 255 * cindex, 255 * cindex, 255 * cindex), "centerpoint")
                    end
                end
                if ia > 0 and i == Pos then
                    local _x1, _x2, _y1, _y2 = x2 + 2, x2 + ia * 340, y1, y2
                    local _w = _x2 - _x1
                    SetImageState("white", "", 80 * alpha, 0, 0, 0)
                    RenderRect("white", _x1, _x2, _y1, _y2)
                    RenderRect("white", _x1, _x2, _y2, _y2 - 43 * ia)
                    RenderRect("white", _x1, _x2, _y1, _y1 + 23 * ia)
                    SetImageState("white", "", 255 * alpha, 255 * cindex, 255 * cindex, 255 * cindex)
                    misc.RenderOutLine("white", _x1, _x2, _y2, _y1, 0, 2)
                    misc.RenderOutLine("white", _x1, _x2, _y2, _y2 - 43 * ia, 0, 2)
                    --misc.RenderOutLine("white", _x1, _x2, _y1 + 43 * ia, _y1, 0, 2)
                    ui:RenderText("title", u.title, (_x1 + _x2) / 2, _y2 - 21.5 * ia, 1.2,
                            Color(255 * alpha * ia, 255 * cindex, 255 * cindex, 255 * cindex), "centerpoint")
                    ui:RenderTextWithCommand("pretty_title", u.mode_des, _x1, _y1 + 6, 0.7,
                            255 * alpha * ia, "left", "bottom")

                    lstg.RenderTTF("title", u.describe or "",
                            _x1 + 5, _x1 + 340 - 5, _y1 + 43 * ia + 5, _y2 - 43 * ia - 5,
                            0x10, Color(alpha * 255 * ia, 255 * cindex, 255 * cindex, 255 * cindex), 0.8)

                end
                if u.is_new then
                    SetImageState("NEW!!", "", 200 * alpha, 255 * cindex, 255 * cindex, 255 * cindex)
                    Render("NEW!!", x1, y2, 0, 0.3)
                end

            end

        end
    end--包渲染
    do
        local tutorbutton = self.tutorial_button
        local r, g, b = sp:HSVtoRGB(-t / 2, 0.7, 1)
        local colorindex = tutorbutton.col_flag * 0.7 + 0.3
        local x1, x2, y1, y2 = tutorbutton.x1, tutorbutton.x2, tutorbutton.y1, tutorbutton.y2 + tutorbutton.col_flag * 6
        SetImageState("white", "", 150 * alpha, 10, tutorbutton.col_flag * 50 + 10, 10)
        RenderRect("white", x1, x2, y1, y2)
        for l = 1, 9 do
            SetImageState("white", "mul+add", (14 - l) * alpha, r * colorindex, g * colorindex, b * colorindex)
            RenderRect("white", x1 - l, x2 + l, y1 - l, y2 + l)
        end
        SetImageState("white", "", 255 * alpha, 255, 255, 255)
        misc.RenderOutLine("white", x1, x2, y1, y2, 1, 1)
        ui:RenderText("title", _t("STGtutorial"), (x1 + x2) / 2, (y1 + y2) / 2,
                0.85, Color(255 * alpha, 255, 255, 255), "centerpoint")

    end
    do
        local challengebutton = self.challenge_button
        local r, g, b = sp:HSVtoRGB(t / 2, 0.7, 1)
        local colorindex = challengebutton.col_flag * 0.7 + 0.3
        local x1, x2, y1, y2 = challengebutton.x1, challengebutton.x2, challengebutton.y1, challengebutton.y2 + challengebutton.col_flag * 6
        SetImageState("white", "", 150 * alpha, 10, challengebutton.col_flag * 50 + 10, 10)
        RenderRect("white", x1, x2, y1, y2)
        for l = 1, 9 do
            SetImageState("white", "mul+add", (14 - l) * alpha, r * colorindex, g * colorindex, b * colorindex)
            RenderRect("white", x1 - l, x2 + l, y1 - l, y2 + l)
        end
        SetImageState("white", "", 255 * alpha, 255, 255, 255)
        misc.RenderOutLine("white", x1, x2, y1, y2, 1, 1)
        ui:RenderText("title", _t("challengeButton"), (x1 + x2) / 2, (y1 + y2) / 2,
                0.85, Color(255 * alpha, 255, 255, 255), "centerpoint")
    end
    self.top_bar:render()

end


