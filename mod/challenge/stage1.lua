local function GetWaveEvent()
    local v = lstg.var
    local w = lstg.weather
    local self = stage.current_stage
    local target
    if v.next_wave_id then
        target = self.wave_events[v.next_wave_id]
        v.next_wave_id = nil
    else

        --计算概率
        local pro = {}
        local lastp = 0
        local function InsertWave(p)
            local base = p.proba
            if p.islucky and v.lucky_cat then
                local lc = 100
                if v.meet_lucky_wave >= 1 then
                    lc = 30
                end
                base = base * (1 + lc)
            end
            if (v.wave + 1) % 30 == 0 then
                if p.isboss and p.isdangerous then
                    base = base * 10000
                end
            end
            local nowp = max(base + p.chaos_power * v.chaos / 100, 0) * p.pro_fixed
            table.insert(pro, { p, lastp, lastp + nowp })
            lastp = lastp + nowp
        end
        for _, p in ipairs(self.wave_events) do
            if not (w.QingLang and (p.islucky or p.isdangerous or p.isboss)) then
                if v.FINAL_HARD_BOSS then
                    if v.wave + 1 == v.maxwave then
                        if p.isdangerous and p.isboss then
                            InsertWave(p)
                        end
                    else
                        InsertWave(p)
                    end
                else
                    if not (p.isdangerous and p.isboss) then
                        InsertWave(p)
                    end
                end
            end
            p.pro_fixed = p.pro_fixed + 0.1
            if (p.isdangerous and p.isboss) then
                p.pro_fixed = p.pro_fixed + 0.5
            end
        end
        if lastp == 0 then
            for _, p in ipairs(self.wave_events) do
                if not (p.islucky or p.isdangerous or p.isboss) then
                    InsertWave(p)
                end
            end
        end--晴朗天气的最后检测
        local n = ran:Float(0, lastp)
        for _, p in ipairs(pro) do
            if p[2] <= n and n < p[3] then
                local e = p[1]
                e.pro_fixed = 0.3
                target = e
                break
            end
        end
    end
    if target.isdangerous and target.isboss then
        v.FINAL_HARD_BOSS = false
    end
    if target.islucky and v.lucky_cat then
        v.meet_lucky_wave = v.meet_lucky_wave + 1
    end
    --  target.event(lstg.var.chaos, lstg.var.difficulty)
    return target


end

local CheckAddition_Submenu = ext.CheckAddition_Submenu
local CheckWeather_Submenu = ext.CheckWeather_Submenu
local CheckActive_Submenu = StageSummary.CheckActive_Submenu
local j = 0
local passCheck = function()
    --menu:Updatekey()
    local flag = menu:keyYes() or ext.mouse:isUp(1)
    if not flag then
        j = 0
    end
    return flag and (j == 0)
end
local function InitWaveEvents(self)
    self.wave_events = {}
    for _, sc in ipairs(SceneClass) do
        for _, p in ipairs(sc.events) do
            local e = sp:CopyTable(p)
            e.proba = 1
            if stagedata.BookWave[e.inscene][e.id] then
                if e.state then
                    if e.state == 3 then
                        e.proba = 0.01
                        e.isdangerous = true
                        e.isboss = true
                    elseif e.state == 2 then
                        e.proba = 0.5
                        e.isboss = true
                    end
                    if e.state <= 3 and e.title ~= "" then
                        table.insert(self.wave_events, e)
                    end
                else
                    if e.islucky then
                        e.proba = 0.1
                    elseif e.isdangerous then
                        e.proba = 0.3
                        if e.isboss then
                            e.proba = 0.07
                        end
                    elseif e.isboss then
                        e.proba = 0.5
                    end
                    table.insert(self.wave_events, e)
                end
            end

        end
    end
end
stage.group.New('attr_select2', {}, "Challenge1", false)

local SimpleStage1 = stage.group.AddStage("Challenge1", "Challenge1@1", false)
function SimpleStage1:init()
    self.is_challenge = true
    InitWaveEvents(self)
    self.eventListener = eventListener()
    LoadBossTex()
    mask_fader:Do("open")
    local var = lstg.var
    New(player_list[var.player_select].class)
    ---@type scene_class
    local scene_class = challenge_lib.class[var.challenge_select]
    self.scene_class = scene_class
    background.Create(scene_class._bg)
    --var.wave = 0
    var.maxwave = scene_class._maxwave
    var.difficulty = 4
    scene_class.init_set()
    stage_lib.InitMusicEvent()
    self.start_function = function(init_w)
        var.maxwave = scene_class._maxwave
        task.New(self, function()
            local w = init_w
            local wevents = self.wave_events
            while w <= var.maxwave do
                local cur_w = stage_lib.DoWaveEvent(self, w, GetWaveEvent, wevents)
                stage_lib.PassCheck()
                cur_w.final()
                self.eventListener:Do("waveEvent@after", self, self)
                task.Wait()

                w = w + 1
            end
            task.Wait(30)
            lstg.tmpvar.noPause = true
            New(stage.stage_clear_object, 1000000)
            task.Wait(60)
            lstg.tmpvar.StopMusic = true
            task.Wait(60)
            mask_fader:Do("close", 15)
            task.Wait(15)
            stage_lib.saveWaveData()
            stage.group.NextStage()
        end)

    end

    task.New(self, function()
        task.Wait(60)
        self.start_function(1)
    end)
end

local function _t(str)
    return i18n("sth", str) or ""
end
local Summary = stage.group.AddStage("Challenge1", "Challenge1@2", false)
function Summary:init()
    self.is_summary = true
    self.is_challenge = true
    lstg.tmpvar.noPause = true
    mask_fader:Do("open")
    self.top_bar = top_bar_Class(self, _t("summary"))
    ext.notUIdraw = true
    self.bubble = {}
    self.back_alpha = 0
    self.lock = true
    self.title = { text = _t("summaryWin"), x = 480, y = 270, alpha = 0, size = 2, r = 200, g = 200, b = 255 }
    self.subtitle = { x = 180, y = 464, alpha = 0, }
    self.player = { cx = 480, cy = 270, R = 120, alpha = 0, }
    self.acalpha = 0
    self.keyname = KeyCodeToName()
    self.checkaddition_button = {
        x = 180, y = 44, index = 0,
        w = 230, h = 48,
        scale = 0.3,
        selected = false,
        text = ("%s(%s)"):format(_t("checkItem"), self.keyname[setting.keys.special]),
        func = function()
            PlaySound("ok00")
            --self.lock = true
            self.CheckAddition_open = true
            CheckAddition_Submenu:In()
        end,
        frame = attributeselectmenu.general_buttonFrame,
        render = attributeselectmenu.general_buttonRender
    }
    self.checkweather_button = {
        x = 324, y = 86, index = 0,
        w = 200, h = 48,
        scale = 0.3,
        selected = false,
        text = ("%s(Y)"):format(_t("checkWea")),
        func = function()
            PlaySound("ok00")
            -- self.lock = true
            self.CheckWeather_open = true
            CheckWeather_Submenu:In()
        end,
        frame = attributeselectmenu.general_buttonFrame,
        render = attributeselectmenu.general_buttonRender
    }
    self.checkactive_button = {
        x = 324, y = 44, index = 0,
        w = 200, h = 48,
        scale = 0.3,
        selected = false,
        text = ("%s(A)"):format(_t("checkActive")),
        func = function()
            PlaySound("ok00")
            -- self.lock = true
            self.CheckActive_open = true
            CheckActive_Submenu:In()
        end,
        frame = attributeselectmenu.general_buttonFrame,
        render = attributeselectmenu.general_buttonRender
    }
    self.retry_button = {
        x = 480, y = 44, index = 0,
        w = 230, h = 48,
        scale = 0.3,
        selected = false,
        text = ("%s(%s)"):format(_t("restart"), "R"),
        func = function()
            PlaySound("ok00")
            self.lock = true
            stage.group.ActionDo("重新开始")
        end,
        frame = attributeselectmenu.general_buttonFrame,
        render = attributeselectmenu.general_buttonRender
    }
    self.exit_button = {
        x = 780, y = 44, index = 0,
        w = 230, h = 48,
        scale = 0.3,
        selected = false,
        text = ("%s(%s)"):format(_t("returnMenu"), self.keyname[setting.keys.spell]),
        func = function()
            PlaySound("ok00")
            self.lock = true
            stage.group.ActionDo("直接结束游玩")
        end,
        frame = attributeselectmenu.general_buttonFrame,
        render = attributeselectmenu.general_buttonRender
    }
    self.button_alpha = 0
    self.info_alpha = { 0, 0, 0, 0, 0, 0 }
    self.score_alpha = { 0, 0, 0, 0, 0, 0, 0 }
    self.unlock_addition = {}
    CheckAddition_Submenu:init(self)
    CheckWeather_Submenu:init(self)
    CheckActive_Submenu:init(self)
    self.addition_order = {}
    local var = lstg.var
    for _, u in ipairs(var.addition_order) do
        table.insert(self.addition_order, stg_levelUPlib.AdditionTotalList[u.id])
    end
    for _, u in ipairs(var.active_item) do
        table.insert(self.addition_order, activeItem_lib.ActiveTotalList[u])
    end
    self.add_unlock_c = 0
    if var.lost then
        PlayMusic2("SCORE")
        self.lost = true
        local t = self.title
        t.text = _t("summaryLost")
        t.r, t.g, t.b = 200, 200, 200
        var.wave = var.wave - 1
    else
        local id = var.challenge_select

        local scene_class = challenge_lib.class[id]
        self.scene_class = scene_class
        PlayMusic2("1_end")
        for i, p in pairs(lstg.var.addition) do
            local unit = stg_levelUPlib.AdditionTotalList[i]
            if p == unit.maxcount and unit.initialTake and not scoredata.initialAddition[i] then
                scoredata.initialAddition[i] = true
                scoredata.NoticeinitialAddition[i] = true
                table.insert(self.unlock_addition, unit)
            end
        end
        local data = stagedata
        if data.challenge_finish[id] == 0 then
            data.challenge_time[id] = os.time()
        end
        data.challenge_finish[id] = data.challenge_finish[id] + 1
        scene_class.success_func()
    end
    self.cur_unlock_c = 3
    do
        self.score = 0

        local waveindex = var.wave / var.maxwave
        if waveindex ~= 1 then
            waveindex = waveindex * 0.9
        end
        local scoreindex = max(0, math.log(max(1, 0.165 * var.score - 155), 1.03) - 225) / 100
        local levelindex = 1 + var.level / 20 * 0.1
        local chaosindex = 1100 / (var.chaos + 1050)
        local diffindex = 1.5
        local C = 1000 * waveindex * scoreindex * levelindex * chaosindex * diffindex
        self.score = int(C)

        self.add_unlock_c = sqrt(self.score) / 150
        local data = playerdata[player_list[stagedata.player_pos].name]
        self.cur_unlock_c = data.unlock_c
        if self.cur_unlock_c < 3 then
            data.unlock_c = min(data.unlock_c + self.add_unlock_c, 3)
            self.add_unlock_c = data.unlock_c - self.cur_unlock_c
        end
    end
    task.New(self, function()
        task.Wait(30)
        task.New(self, function()
            local t = self.title
            local p = self.player
            local st = self.subtitle
            for i = 1, 25 do
                i = task.SetMode[2](i / 25)
                t.size = 2 - i
                t.alpha = i
                if not passCheck() then
                    task.Wait()
                end
            end
            j = 2
            task.New(self, function()
                for _ = 1, 40 do
                    if not passCheck() then
                        task.Wait()
                    end
                end
                for i = 1, 25 do
                    i = task.SetMode[2](i / 25)
                    p.alpha = i
                    p.R = 200 - 80 * i
                    if not passCheck() then
                        task.Wait()
                    end
                end
                for i = 1, 60 do
                    i = task.SetMode[3](i / 60)
                    self.acalpha = i
                    p.cx = 480 - 300 * i
                    if not passCheck() then
                        task.Wait()
                    end
                end

            end)
            j = 2
            for i = 1, 70 do
                i = task.SetMode[3](i / 70)

                t.y = 270 + 190 * i
                if not passCheck() then
                    task.Wait()
                end
            end
            j = 2
            task.New(self, function()
                for k = 1, 5 do
                    task.New(self, function()
                        for i = 1, 45 do
                            i = task.SetMode[2](i / 45)
                            self.info_alpha[k] = i
                            if not passCheck() then
                                task.Wait()
                            end
                        end
                    end)
                    for _ = 1, 16 do
                        if not passCheck() then
                            task.Wait()
                        end
                    end
                end
                j = 2
                for _ = 1, 30 do
                    if not passCheck() then
                        task.Wait()
                    end
                end
                j = 2
                for k = 1, var.lost and 2 or 4 do
                    task.New(self, function()
                        for i = 1, 60 do
                            i = task.SetMode[2](i / 60)
                            self.score_alpha[k] = i
                            if not passCheck() then
                                task.Wait()
                            end
                        end
                    end)
                    for _ = 1, 25 do
                        if not passCheck() then
                            task.Wait()
                        end
                    end
                end
                j = 2
                if self.cur_unlock_c < 3 then
                    for k = 5, 7 do
                        task.New(self, function()
                            for i = 1, 60 do
                                i = task.SetMode[2](i / 60)
                                self.score_alpha[k] = i
                                if not passCheck() then
                                    task.Wait()
                                end
                            end
                        end)
                        for _ = 1, 25 do
                            if not passCheck() then
                                task.Wait()
                            end
                        end
                    end
                    j = 2

                end
                self.lock = false
                task.New(self, function()
                    local ti = int(self.add_unlock_c * 60)
                    local slast = 0
                    for c = 1, ti do
                        c = task.SetMode[2](c / ti)
                        local last_unlock_c = self.cur_unlock_c
                        self.cur_unlock_c = self.cur_unlock_c + self.add_unlock_c * (c - slast)
                        if int(self.cur_unlock_c) - int(last_unlock_c) > 0 then
                            PlaySound("extend")
                            NewWave(p.cx, p.cy, 2, 300, 60, 255, 227, 132, p.R)
                        end
                        slast = c
                        if not passCheck() then
                            task.Wait()
                        end
                    end
                end)
                for i = 1, 40 do
                    i = task.SetMode[2](i / 40)
                    self.button_alpha = i
                    task.Wait()
                end


            end)
            j = 2
            for i = 1, 40 do
                i = task.SetMode[3](i / 40)
                st.alpha = i
                if not passCheck() then
                    task.Wait()
                end
            end


        end)
        for i = 1, 30 do
            self.back_alpha = i / 30
            if not passCheck() then
                task.Wait()
            end
        end
        j = 2
    end)
end
function Summary:frame()
    stage.group.frame()
    --  self.checkaddition_button.x = self.player.cx
    --self.checkaddition_button.y = self.player.cy - 226
    if self.timer % 6 == 0 then
        table.insert(self.bubble, {
            x = ran:Float(0, 960), y = ran:Float(0, 300),
            vy = ran:Float(0.3, 0.9), vx = 0,
            r = 0, maxr = ran:Float(4, 10),
            timer = 0, lifetime = ran:Int(70, 120),
            alpha = 0, maxalpha = 80
        })
    end
    local b
    for i = #self.bubble, 1, -1 do
        b = self.bubble[i]
        b.x = b.x + b.vx
        b.y = b.y + b.vy
        b.vx = sin(b.timer / b.lifetime * 360 * 2) * 0.1
        b.r = b.timer / b.lifetime * b.maxr
        if b.timer <= 10 then
            b.alpha = min(b.maxalpha, b.alpha + b.maxalpha / 10)
        elseif b.lifetime - b.timer <= 20 then
            b.alpha = max(0, b.alpha - b.maxalpha / 20)
        end
        if b.timer == b.lifetime then
            table.remove(self.bubble, i)
        end
        b.timer = b.timer + 1
    end
    if self.CheckAddition_open then
        CheckAddition_Submenu:frame()
        return
    end
    if self.CheckWeather_open then
        CheckWeather_Submenu:frame()
        return
    end
    if self.CheckActive_open then
        CheckActive_Submenu:frame()
        return
    end
    menu:Updatekey()
    if self.lock then
        return
    end
    if menu.key == setting.keys.special then
        self.checkaddition_button.func()
    end
    if menu.key == KEY.R then
        self.retry_button.func()
    end

    if menu:keyNo() then
        self.exit_button.func()
    end
    self.top_bar:frame()

    self.checkaddition_button:frame()
    if lstg.var._season_system then
        self.checkweather_button:frame()
        if menu.key == KEY.Y then
            self.checkweather_button.func()
        end
    end
    if lstg.var.active_item[1] then
        self.checkactive_button:frame()
        if menu.key == KEY.A then
            self.checkactive_button.func()
        end
    end
    self.retry_button:frame()
    self.exit_button:frame()
end
function Summary:render()
    local t = self.title
    local var = lstg.var

    ui:RenderText("pretty", t.text, t.x, t.y, t.size, Color(t.alpha * 255, 255, 255, 255), "centerpoint")
    --把标题渲染在背景图下层

    SetImageState("summary_back", "", 150 * self.back_alpha, 255, 255, 255)
    Render("summary_back", 480, 270, 0, 0.5)
    for _, b in ipairs(self.bubble) do
        SetImageState("white", "mul+add", b.alpha * self.back_alpha, 200, 200, 255)
        misc.SectorRender(b.x, b.y, b.r - 0.7, b.r, 0, 360, 40)
    end

    SetImageState("bright_line", "mul+add", t.alpha * 255, t.r, t.g, t.b)
    Render("bright_line", t.x, t.y - 28 * t.size, 0, 200 / 350, 0.12)
    ---------------------
    do
        ---@type PlayerUnit
        local punit = player_list[stagedata.player_pos]
        local back = "th08_13_n"
        local tsize = GetTextureSize(back)
        local p = self.player
        local A = self.acalpha
        SetImageState("menu_circle", "", p.alpha * 180, 200, 200, 200)
        Render("menu_circle", p.cx, p.cy, 0, p.R / 192)
        SetImageState("menu_circle", "", p.alpha * 70, 200, 200, 200)
        Render("menu_circle", p.cx, p.cy, 0, (p.R + 27) / 192)
        misc.RenderTexInCircle(back, p.cx, p.cy, tsize / 2, tsize / 2,
                p.R * 0.913, 0, 0.4, "",
                Color(p.alpha * 170, 200, 200, 200), 75)
        misc.RenderTexInCircle(punit.picture, p.cx, p.cy, punit.renderx, punit.rendery,
                p.R * 0.913, 0, punit.renderscale, "",
                Color(p.alpha * 200, 200, 200, 200), 75)
        local unlock_c = int(self.cur_unlock_c or 0)
        local _ct = (unlock_c - 1) / 2

        local star_num = 1
        for c = -_ct, _ct do
            local starscale = 0.18
            local _x, _y = p.cx + c * 24, p.cy - p.R * 0.6
            local img = "menu_player_star1"
            if playerdata[punit.name].choose_skill[star_num] then
                img = "menu_player_star3"
            end
            SetImageState(img, "mul+add", p.alpha * 200, 255, 255, 255)
            Render(img, _x, _y, 0, starscale)
            star_num = star_num + 1
        end
        local _alpha = A * 180
        local spx, spy = p.cx - 120, p.cy - 200

        SetImageState("menu_circle", "", _alpha, 200, 200, 200)
        Render("menu_circle", spx, spy, 0, 45 / 192)
        ---@type SpellUnit
        local sp = punit.spells[var.spell_select]
        local spimg = sp.picture
        SetImageState(spimg, "", _alpha, 200, 200, 200)
        Render(spimg, spx, spy, 0, 45 / 192)

        local ac = var.addition_count
        local color = { 189, 252, 201, 218, 112, 214, 250, 128, 114 }

        for k = 1, 3 do

            local size = 19 * A

            local px, py = p.cx + (k - 2) * 50, p.cy - 185 * A
            SetImageState("menu_circle", "", A * 180, 200, 200, 200)
            Render("menu_circle", px, py, 0, size / 192)
            SetImageState("menu_pure_circle", "mul+add", A * 75, color[k * 3 - 2], color[k * 3 - 1], color[k * 3])
            Render("menu_pure_circle", px, py, 0, (size - 1) / 125)
            local img = "addition_state" .. k
            SetImageState(img, "", A * 180, 200, 200, 200)
            Render(img, px, py, 0, size / 150)
            ui:RenderText("pretty_title", ("x%d"):format(ac[k] or 0), px, py, 1,
                    Color(A * 250, 200, 200, 200), "centerpoint")
        end
        for i, u in ipairs(self.addition_order) do
            local size = 19 * A
            local angle = 90 - (i - 1) * min(360 / (#self.addition_order), 30) * A
            local r = p.R + 20
            local x, y = p.cx + cos(angle) * r, p.cy + sin(angle) * r
            SetImageState("menu_circle", "", A * 200, 200, 200, 200)
            Render("menu_circle", x, y, 0, size / 192)
            SetImageState("menu_pure_circle", "mul+add", A * 50, u.R, u.G, u.B)
            Render("menu_pure_circle", x, y, 0, (size - 1) / 125)
            local img = u.pic
            SetImageState(img, "", A * 200, 200, 200, 200)
            Render(img, x, y, 0, size / 175)
            if u.count and u.count > 1 then
                ui:RenderText("pretty_title", u.count, x - 2, y + 2, 0.8,
                        Color(A * 200, 200, 200, 200), "right", "bottom")
            end
        end

    end--玩家
    do
        local diffname = challenge_lib.class[var.challenge_select].title
        local st = self.subtitle
        ui:RenderText("pretty", diffname, st.x, st.y - 10,
                st.alpha * 0.35, Color(170, 255, 227, 132), "centerpoint")
        SetImageState("bright_line", "mul+add", st.alpha * 255, 230, 230, 230)
        Render("bright_line", st.x, st.y - 28 * st.alpha, 0, 200 / 350, 0.12)
    end--小标题
    do
        local x, y = 480, 380
        local ia = self.info_alpha
        local list = {
            { _t("sPassWave"), ("%d / %d"):format(var.wave * ia[1], var.maxwave) },
            { _t("sPlayScore"), ("%d"):format(var.score * ia[2]) },
            { _t("sPlayLevel"), ("Lv.%d"):format(var.level * ia[3]) },
            { _t("sChaos"), ("%d%%"):format(var.chaos * ia[4]) },
            { _t("sDiff"), ("x%0.1f"):format(1.5 * ia[5]) }
        }
        local dx = 85
        for i, p in ipairs(list) do
            SetImageState("bright_line", "mul+add", ia[i] * 255, 230, 230, 230)
            Render("bright_line", x - (dx - 25) * ia[i], y - 19, 0, 70 / 350, 0.1)
            Render("bright_line", x + (dx - 25) * ia[i], y - 19, 0, 70 / 350, 0.1)
            ui:RenderText("title", p[1], x - dx * ia[i], y,
                    0.9, Color(160 * ia[i], 255, 255, 255), "left")
            ui:RenderText("title", p[2], x + dx * ia[i], y,
                    0.9, Color(160 * ia[i], 255, 255, 255), "right")
            y = y - 42
        end
        local _a = self.score_alpha
        dx = 95
        x, y = 760, 320
        SetImageState("bright_line", "mul+add", _a[1] * 255, 230, 230, 230)
        Render("bright_line", x, y - 42, 0, 250 / 350, 0.1)
        ui:RenderText("pretty", _t("sTotalscore"), x - dx * _a[1], y,
                0.7, Color(230 * _a[1], 255, 255, 255), "left")
        ui:RenderText("pretty", ("%d"):format(self.score * _a[2]), x + 15 * _a[2], y,
                0.7, Color(230 * _a[2], 255, 227, 132), "left")

        ui:RenderText("pretty", _t("unlockInitialTake"), x - dx * _a[3] - 12, y - 70,
                0.4, Color(230 * _a[3], 200, 200, 200), "left", "top")
        local A = _a[4]
        local size = 16
        local _x = x + 20
        local _y = y - 81
        local unlock = self.unlock_addition
        local w = min(33, 130 / (#unlock))
        for _, p in ipairs(unlock) do
            SetImageState("menu_circle", "", A * 200, 200, 200, 200)
            Render("menu_circle", _x, _y, 0, size / 192)
            SetImageState("menu_pure_circle", "mul+add", A * 50, 135, 206, 235)
            Render("menu_pure_circle", _x, _y, 0, (size - 1) / 125)
            local img = "addition_state" .. p.state
            SetImageState(img, "", A * 200, 200, 200, 200)
            Render(img, _x, _y, 0, size / 175)
            _x = _x + A * w
        end
        ui:RenderText("pretty", _t("talentUnlockProgress"), x - dx * _a[5] - 12, y - 125,
                0.4, Color(230 * _a[5], 200, 200, 200), "left", "top")
        for p = 1, 3 do
            local iy = y - 120 - p * 8
            local x1, x2, y1, y2 = x + 5, x + 95, iy - 2, iy + 2
            local rr = (y2 - y1) / 2
            local co = clamp(self.cur_unlock_c - p + 1, 0, 1)
            local r1, g1, b1 = 50, 50, 50
            local r2, g2, b2 = 150, 150, 100
            local r = r1 + (r2 - r1) * co
            local g = g1 + (g2 - g1) * co
            local b = b1 + (b2 - b1) * co
            local gox = x1 + max(rr * 2, (x2 - x1) * co)
            SetImageState("white", "", 100 * _a[6], r, g, b)
            misc.RenderRoundedRect(x1, gox, y1, y2, rr, 6)

            SetImageState("white", "", 150 * _a[6], 150, 150, 150)
            misc.RenderRoundedRectOutline(x1 - 1, gox + 1, y1 - 1, y2 + 1, rr + 1, 1, 6)
        end
        ui:RenderText("pretty", ("+%d%%"):format(self.add_unlock_c * _a[7] * 100), x + 100, y - 125,
                0.4, Color(150 * _a[7], 189, 252, 201), "left")
    end--数据
    do
        local A = self.acalpha
        local p = player_lib._cache_player
        if p.dmg then
            local dmg = player_lib.GetPlayerDmg(p)
            local colli = player_lib.GetPlayerCollisize(p)
            local hspeed, lspeed = player_lib.GetPlayerSpeed(p)
            local s_set = p.shoot_set
            local speed_set = s_set.speed
            local bv_set = s_set.bvelocity
            local range_set = s_set.range
            local sspeed, bv, lifetime = player_lib.GetShootAttribute(p)

            local _alphaf = function(k)
                return clamp(self.timer - 60 - k * 20, 0, 100) / 100 * A
            end
            local kx = 682
            local Y = 473
            local width = 45
            local img, _a
            local tsize = 0.7
            local speed = hspeed
            local ispeed = p.hspeed
            if p.__slow_flag then
                speed = lspeed
                ispeed = p.lspeed
            end
            for i, text in ipairs({
                { ("%0.1f / %0.1f"):format(var.lifeleft, var.maxlife) },
                { ("%0.2f"):format(colli), colli - p.collisize, -1, "(%+0.2f)" },
                { ("%0.2f / %0.2f"):format(p.hspeed, p.lspeed) },
                { ("%0.2f"):format(dmg), dmg - p.dmg, 1, "(%+0.2f)" },
                { ("%d"):format(lifetime), lifetime - range_set.value, 1, "(%+d)" },
                { ("%0.2f"):format(sspeed), sspeed - speed_set.value, 1, "(%+0.2f)" },
                { ("%0.2f"):format(bv), bv - bv_set.value, 1, "(%+0.2f)" }
            }) do
                img = "attr_icon" .. i
                _a = _alphaf(i)
                SetImageState(img, "", _a * 200, 255, 255, 255)
                Render(img, kx - width + 7, Y - 4, 0, 0.27)
                SetImageState("bright_line", "mul+add", _a * 200, 255, 255, 255)
                RenderRect("bright_line", kx - width * 2.5, kx + width * 2.5, Y - 12, Y - 17)
                ui:RenderText("title", text[1], kx - width + 17, Y + 4,
                        tsize, Color(_a * 150, 255, 255, 255), "left")
                if text[2] then
                    local fr = lstg.FontRenderer
                    fr.SetFontProvider("title")
                    fr.SetScale(tsize, tsize)
                    local _l, _r = fr.MeasureTextBoundary(text[1])
                    local _w = (_r - _l) / 2
                    local R, G, B = 100, 100, 100
                    if text[2] * text[3] > 0 then
                        R, G, B = 189, 252, 201
                    elseif text[2] * text[3] < 0 then
                        R, G, B = 250, 128, 114
                    end
                    ui:RenderText("title", text[4]:format(text[2]), kx - width + 18.5 + _w, Y + 2.5,
                            tsize * 0.8, Color(_a * 150, R, G, B), "left")
                end
                Y = Y - 27
                if i == 4 then
                    kx = kx + 156
                    Y = Y + 27 * 4
                end
            end
        end
    end--面板属性
    local ba = self.button_alpha
    self.checkaddition_button:render(ba)
    if lstg.var._season_system then
        self.checkweather_button:render(ba)
    end
    if lstg.var.active_item[1] then
        self.checkactive_button:render(ba)
    end
    self.retry_button:render(ba)
    self.exit_button:render(ba)
    self.top_bar:render()

    CheckAddition_Submenu:render()
    CheckWeather_Submenu:render()
    CheckActive_Submenu:render()
end
_G.ChallengeSummary = Summary