

local function _t(str)
    return i18n("ext", str) or ""
end

---@class ext.season_set
local season_set = {  }

local Selection_obj = plus.Class()

function season_set:init()
    self.kill = true
    self.locked = false
    self.alpha = 0
    self.timer = 0
    self.mask = 120
    self.selection = {}
    self.pos = 1
end
function season_set:frame()
    task.Do(self)
    if self.kill then
        return
    end
    menu:Updatekey()
    if not self.locked then

        local mouse = ext.mouse
        if menu:keyUp() or menu:keyLeft() then
            self.pos = sp:TweakValue(self.pos - 1, #self.selection, 1)
            PlaySound("select00")
        end
        if menu:keyDown() or menu:keyRight() then
            self.pos = sp:TweakValue(self.pos + 1, #self.selection, 1)
            PlaySound("select00")
        end
        if mouse._wheel ~= 0 then
            self.pos = sp:TweakValue(self.pos - sign(mouse._wheel), #self.selection, 1)
            PlaySound("select00")
        end
        if menu:keyYes() then
            self.selection[self.pos].func(lstg.tmpvar.ForceSeason)
            PlaySound("ok00")
        end
    end
    for _, p in ipairs(self.selection) do
        p:frame()
    end
end
function season_set:render()
    SetViewMode("ui")
    SetImageState("white", "", self.alpha * self.mask, 0, 0, 0)
    RenderRect("white", 0, 960, 0, 540)
    ui:RenderText("pretty", _t("selectSeason"), 480, 440,
            1.5, Color(self.alpha * 200, 255, 255, 255), "centerpoint")
    for _, p in ipairs(self.selection) do
        p:render(self.alpha)
    end
end

---测试性id参数填入
---功能无法保障完全安全
function season_set:SetSeason(id)
    self._nextlock = false
    self.kill = false
    self.selection = {}
    self.locked = true
    if lstg.tmpvar.SetSeasonEvent then
        lstg.tmpvar.SetSeasonEvent()
        lstg.tmpvar.SetSeasonEvent = nil
    end
    task.New(self, function()
        for i = 1, 15 do
            self.alpha = task.SetMode[2](i / 15)
            lstg.ui.season_alpha = 1 - self.alpha
            task.Wait()
        end
        if id then
            if id == 5 then
                self.selection[5] = Selection_obj(480, 270, 5, 1)
            end
            self.selection[id].func(true)
            PlaySound("ok00")
        else
            task.Wait(25)
            while GetKeyState(KEY.Z) do
                task.Wait()
            end
            self.locked = self._nextlock
        end

    end)
    local w = lstg.weather
    local season = {}
    for i, p in ipairs(w.selected_season) do
        if not p then
            --如果已选过则不选
            table.insert(season, i)
        end
    end
    for k, s in ipairs(season) do
        table.insert(self.selection, Selection_obj(480, 270, s, k))
    end
    local k = (#self.selection - 1) / 2
    local j = 1
    for c = -k, k do
        local s = self.selection[j]
        task.New(s, function()
            task.MoveToForce(480 + c * 180, 320 - abs(c) * 30, 30, 2)
        end)
        j = j + 1
    end
    self.pos = sp:TweakValue(self.pos, #self.selection, 1)
end

function season_set:Out()
    task.New(self, function()
        for i = 1, 10 do
            self.alpha = 1 - i / 10
            task.Wait()
        end
        self.kill = true
    end)
end

function season_set:IsKilled()
    return self.kill
end

function Selection_obj:init(x, y, id, pos)
    self.pos = pos
    self.x, self.y = x, y
    self.id = id
    self.imgs = ("season_icon_%d_"):format(self.id)
    self.func = function(force)
        season_set.locked = true
        task.New(self, function()
            local w = lstg.weather
            local change_inside = (ran:Float(0, 1) < scoredata.inside_pro)
            local real_changed
            for _, p in ipairs(season_set.selection) do
                p.locked = true
                if p ~= self then
                    task.New(self, function()
                        for i = 1, 25 do
                            i = task.SetMode[2](i / 25)
                            p.alpha = 1 - i
                            task.Wait()
                        end
                    end)
                end
            end
            task.MoveToForce(480, 270, 30, 2)
            w.selected_season[self.id] = true
            if not force then
                task.Wait(20)
                if change_inside or w.MustSeason5 then
                    PlaySound("bonus2")
                    self.index = 0
                    self.id = 5
                    self.imgs = ("season_icon_%d_"):format(self.id)
                    if lstg.tmpvar.stop_reset_inside_pro then
                        lstg.tmpvar.stop_reset_inside_pro = nil
                    else
                        scoredata.inside_pro = 0.05
                    end
                    if w.MustSeason5 then
                        stg_levelUPlib.BreakAddition(stg_levelUPlib.AdditionTotalList[102])
                    end
                    scoredata.First5Season = true
                    mission_lib.GoMission(6)
                    real_changed = true
                else
                    scoredata.inside_pro = scoredata.inside_pro + 0.05
                end
            end
            w.now_season = self.id
            w.season_wave = 0
            task.New(stage.current_stage, function()
                for i = 1, 60 do
                    lstg.ui.season_alpha = task.SetMode[2](i / 60)
                    task.Wait()
                end
            end)
            if real_changed then
                task.Wait(60)
            end
            task.MoveToForce(480, 660, 30, 3)
            season_set:Out()

        end)
    end
    self.index = 0
    self.timer = 0
    self.r = 80
    self.alpha = 1
    self.selected = false
    self.locked = false

end
function Selection_obj:frame()
    task.Do(self)
    self.timer = self.timer + 1
    if self.locked then
        self.index = self.index + (-self.index + 1) * 0.1
        return
    end
    if season_set.locked then
        return
    end
    local mouse = ext.mouse
    local flag1 = Dist(self.x, self.y, mouse.x, mouse.y) < self.r
    local flag2 = season_set.pos == self.pos
    if flag1 or flag2 then
        self.index = self.index + (-self.index + 1) * 0.1
        if not self.selected and flag1 then
            self.selected = true
            PlaySound("select00")
        end
    else
        self.index = self.index - self.index * 0.1
        self.selected = false
    end
    if self.selected then
        if mouse:isUp(1) and flag1 then
            self.index = self.index + 0.5
            PlaySound("ok00")
            self.func(lstg.tmpvar.ForceSeason)
        end
    end

end
function Selection_obj:render(A)
    local k = self.index
    local _alpha = (150 + k * 50) * A * self.alpha
    local ax, ay = self.x, self.y
    local adsize = self.r + k * 10
    local w = lstg.weather

    SetImageState("menu_circle", "", _alpha, 200, 200, 200)
    Render("menu_circle", ax, ay, 0, adsize / 192)
    if season_set.pos == self.pos then
        SetImageState("menu_bright_circle", "mul+add", _alpha * (sin(self.timer * 4) * 0.2 + 0.4), 200, 200, 200)
        Render("menu_bright_circle", ax, ay, 0, adsize / 125)
    end
    local t = w.season_last[self.id]
    local _ct = (t - 1) / 2
    for i = -_ct, _ct do
        local angle = -90 + i * (10 + 5 * k)
        local radius = adsize * 1.06
        SetImageState("white", "", _alpha, 200, 200, 200)
        misc.SectorRender(ax + cos(angle) * radius, ay + sin(angle) * radius, 0, 4, 0, 360, 10)
    end
    adsize = adsize * 0.9
    local img1 = ("%s%d"):format(self.imgs, 1)
    local img2 = ("%s%d"):format(self.imgs, 2)
    local img3 = ("%s%d"):format(self.imgs, 3)
    local img4 = ("%s%d"):format(self.imgs, 4)
    local img5 = ("%s%d"):format(self.imgs, 5)
    local img6 = ("%s%d"):format(self.imgs, 6)
    SetImageState(img6, "mul+add", _alpha, 255, 255, 255)
    Render(img6, ax, ay, 0, adsize / 256 * k)
    SetImageState(img5, "mul+add", _alpha, 200 + 55 * k, 200 + 55 * k, 255)
    Render(img5, ax, ay, -15 + 15 * k, adsize / 256)
    SetImageState(img4, "mul+add", _alpha, 255, 255, 200 + 55 * k)
    Render(img4, ax, ay, 30 - 30 * k, adsize / 256)
    SetImageState(img3, "mul+add", _alpha, 255, 200 + 55 * k, 255)
    Render(img3, ax, ay - 10 + 10 * k, -90 + 90 * k, adsize / 256)
    SetImageState(img2, "mul+add", _alpha, 200 + 55 * k, 255, 255)
    Render(img2, ax + 10 - 10 * k, ay, 100 - 100 * k, adsize / 256)
    SetImageState(img1, "", _alpha, 255, 255, 255)
    Render(img1, ax, ay, 0, adsize / 256)


end

ext.season_set = season_set
ext.season_set:init()
