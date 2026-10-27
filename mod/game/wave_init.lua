local path = "assets\\weather\\season\\"
for k, s in ipairs({ "spring", "summer", "autumn", "winter", "inside" }) do
    for i = 1, 6 do
        LoadImageFromFile(("season_icon_%d_%d"):format(k, i), ("%s%s_%d.png"):format(path, s, i), true)
    end
    LoadImageFromFile(("season_icon_full_%d"):format(k), ("%s%s.png"):format(path, s), true)
end

local lib = stage_lib
---@param class scene_class
local function NewWaveEvent(class, id, proba, chaosp, hardf, event, title, islucky, isdanger, isboss)
    ---@class wave_event
    local e = {}
    e.proba = proba
    e.inscene = class.id
    e.id = id
    e.isWave = true
    e.title = title or ""
    e.chaos_power = chaosp
    e.hard_factor = hardf
    e.islucky, e.isdangerous, e.isboss = islucky, isdanger, isboss
    e.pro_fixed = 1
    class.events[e.id] = e
    local data = stagedata.BookWave[class.id]
    data[e.id] = data[e.id] or false
    e.event = function(var)
        data[e.id] = true--开图鉴
        event(var)
    end
    e.final = function()
    end
    return e
end
stage_lib.NewWaveEvent = NewWaveEvent

local function SetWaveEventInWave(class, e, inwave)
    class.wave_events[inwave] = class.wave_events[inwave] or {}
    table.insert(class.wave_events[inwave], e)
end
stage_lib.SetWaveEventInWave = SetWaveEventInWave

---一种方式来添加波的事件
---在指定波数添加固定概率的事件
---@param inwaves table
local function NewWaveEventInWaves(class, id, inwaves, proba, chaosp, hardf, event, title, islucky, isdanger, isboss)
    local e = NewWaveEvent(class, id, proba, chaosp, hardf, event, title, islucky, isdanger, isboss)
    for _, p in ipairs(inwaves) do
        SetWaveEventInWave(class, e, p)
    end
    return e
end
stage_lib.NewWaveEventInWaves = NewWaveEventInWaves

---刷新怪物血量的倍率
local function RefreshHPindex()
    local v = lstg.var
    local w = lstg.weather
    local chaos = v.chaos
    local diff = v.difficulty
    local weakened = 1
    if not stage.current_stage.is_practice then
        if v.wave == 1 then
            weakened = 0.25
        elseif v.wave == 2 then
            weakened = 0.5
        elseif v.wave == 3 then
            weakened = 0.75
        end
    end
    local diffk = 0.4 + diff * 0.2
    local chaosk = 1
    local _chaos = chaos
    while _chaos > 0 do
        chaosk = chaosk * (1 + max(0, _chaos - 75) / 75 * 0.1)
        _chaos = _chaos - 75
    end
    local other = 1
    if v._season_system then
        other = other * w.enemyHP_index
        if w.LiQiu then
            other = other * ran:Float(0.1, 2)
        end
    end
    v.enemyHP_index = (1 + max(0, chaos - 40) / 60 * 0.25) * diffk * chaosk * weakened * other

end
stage_lib.RefreshHPindex = RefreshHPindex

local Show_WaveCount = Class(object)
function Show_WaveCount:init(wave, title, lucky, dangerous, isboss, sound)
    self.black_h = 0
    self.alpha = 1
    self.y = 140
    self.talpha = 0
    self.wave = wave
    self.title = title
    self.bound = false
    self.colli = false
    self.layer = 0
    if isboss and lucky then
        self.text = "Lucky Boss Wave?!"
        self._r, self._g, self._b = 255, 227, 132
        if sound then
            PlaySound("bonus2")
        end
    elseif isboss and dangerous then
        self.text = "Hard Boss Wave!!"
        self._r, self._g, self._b = 250, 64, 64
        if sound then
            PlaySound("hyz_warning")
        end
    elseif dangerous then
        self.text = "Hard Wave"
        self._r, self._g, self._b = 218, 112, 214
        if sound then
            PlaySound("hyz_warning")
        end
    elseif isboss then
        self.text = "Boss Wave"
        self._r, self._g, self._b = 220, 100, 100
        if sound then
            PlaySound("alert")
        end
    elseif lucky then
        self.text = "Lucky Wave!!"
        self._r, self._g, self._b = 100, 220, 100
        if sound then
            PlaySound("bonus2")
        end
    else
        self.text = "Wave"
        self._r, self._g, self._b = 200, 200, 200
        if sound then
            PlaySound("heal")
        end
    end
    task.New(self, function()
        for i = 1, 15 do
            self.black_h = i / 15 * 16
            task.Wait()
        end
        for i = 1, 16 do
            self.talpha = i / 16
            task.Wait()
        end
        if isboss or dangerous then
            for _ = 1, 8 do
                self.talpha = 1
                task.Wait(10)
                self.talpha = 0
                task.Wait(10)
            end
        else
            task.Wait(100)
        end
        for i = 1, 30 do
            self.alpha = 1 - i / 30
            task.Wait()
        end
        Del(self)
    end)

    local w = lstg.weather
    if w.now_weather ~= 0 then
        local wu = weather_lib.weather[w.now_weather]
        local describes = sp:SplitText(wu.describe, "\n")
        self.describe = {  }
        for i = 1, 2 do
            self.describe[i] = describes[i]
        end
        if #describes > 2 then
            self.describe[2] = self.describe[2] .. "..."
        end
    end
end
function Show_WaveCount:frame()
    task.Do(self)
end
function Show_WaveCount:render()
    local y = self.y
    local A = self.alpha
    local w = lstg.weather
    local dy = 0
    if w.now_weather ~= 0 then
        dy = self.black_h * 3.4
    end
    SetImageState("white", "", A * 150, 0, 0, 0)
    RenderRect("white", -320, 320, y - self.black_h - dy, y + self.black_h)
    ui:RenderText("title", ("%s %d %s"):format(self.text, self.wave, self.title), 0, y, 1,
            Color(A * self.talpha * 255, self._r, self._g, self._b), "centerpoint")
    if w.now_weather ~= 0 then
        ---@type weather_unit
        local wu = weather_lib.weather[w.now_weather]
        ui:RenderText("pretty_title", ("%s"):format(wu.name), 0, y - self.black_h * 1.3, 1,
                Color(A * self.talpha * 255, wu.R, wu.G, wu.B), "centerpoint")
        ui:RenderText("title", ("%s"):format(wu.subtitle), 0, y - self.black_h * 2.4, 0.6,
                Color(A * self.talpha * 255, wu.R, wu.G, wu.B), "centerpoint")
        for i, t in ipairs(self.describe) do
            ui:RenderTextWithCommand("title", t, 0, y - self.black_h * 2.8 - i * 10 + 3, 0.5,
                    A * self.talpha * 150, "centerpoint")
        end
    end
end
stage_lib.Show_WaveCount = Show_WaveCount

function SetWave(wave, wait, title, lucky, dangerous, isboss)
    local var = lstg.var
    var.wave_luck = lucky
    var.wave_hard = dangerous
    var.wave_boss = isboss
    New(Show_WaveCount, wave, title, lucky, dangerous, isboss, true)
    if lstg.var._season_system then
        wait = wait + 60
    end
    task.Wait(wait)
end
local normal_cond = function()
    return true
end
local function SetWeather(condition)
    condition = condition or normal_cond
    local w = lstg.weather
    local selected
    if w.next_weather then
        selected = weather_lib.weather[w.next_weather]
        w.next_weather = nil
    else
        local nowc = {}
        local j = 0
        for _, p in ipairs(weather_lib.season[w.now_season].weathers) do
            if condition(p) then
                local pro = p.pro()
                if p.state == 1 and w.TwiceXiangRui then
                    pro = pro * 1.25
                end
                table.insert(nowc, { p, j, j + pro })
                j = j + pro
            end
        end
        local c = ran:Float(0, j)
        for _, unit in ipairs(nowc) do
            if c >= unit[2] and c < unit[3] then
                selected = unit[1]
                break
            end
        end
    end
    if selected then
        if w.now_weather ~= 0 then
            weather_lib.weather[w.now_weather].final()
        end
        w.now_weather = selected.id
        weather_lib.weather[w.now_weather].init()
        table.insert(w.total_weather, w.now_weather)
    end
end
stage_lib.SetWeather = SetWeather

local Show_ChangeSeason = Class(object)
function Show_ChangeSeason:init(id, mode)
    self.mode = mode
    self.alpha = 0
    self.x, self.y = 0, 0
    self.r = 200
    self.id = id
    self.imgs = ("season_icon_%d_"):format(self.id)
    self.index = 0
    self.group = GROUP.GHOST
    self.layer = LAYER.BG + 4
    local time = 90
    if self.mode == 1 then
        local unit = weather_lib.season[self.id]
        NewWave(self.x, self.y, 2, 350, 60, unit.R, unit.G, unit.B)
        self.index = 0
        task.New(self, function()
            for i = 1, time do
                i = i / time
                self.index = task.SetMode[10](i)
                self.alpha = min(1, sin(i * 180) * 2)
                lstg.ui.season_alpha = 1 - self.alpha
                task.Wait()
            end
            Del(self)
        end)
    else
        self.index = 1

        task.New(self, function()
            for i = 1, time do
                i = i / time
                self.index = 1 - task.SetMode[10](i)
                self.alpha = min(1, sin(i * 180) * 2) * 0.6
                task.Wait()
            end
            Del(self)
        end)
    end
end
function Show_ChangeSeason:frame()
    task.Do(self)
end
function Show_ChangeSeason:render()
    local k = self.index
    local _alpha = (100 + k * 50) * self.alpha
    local ax, ay = self.x, self.y
    local adsize = self.r + k * 10
    local img1 = ("%s%d"):format(self.imgs, 1)
    local img2 = ("%s%d"):format(self.imgs, 2)
    local img3 = ("%s%d"):format(self.imgs, 3)
    local img4 = ("%s%d"):format(self.imgs, 4)
    local img5 = ("%s%d"):format(self.imgs, 5)
    local img6 = ("%s%d"):format(self.imgs, 6)
    SetImageState(img6, "mul+add", _alpha, 255, 255, 255)
    Render(img6, ax - 100 + 100 * k, ay, 0, adsize / 256 * k)
    SetImageState(img5, "mul+add", _alpha, 200 + 55 * k, 200 + 55 * k, 255)
    Render(img5, ax, ay + 150 - 150 * k, -15 + 15 * k, adsize / 256)
    SetImageState(img4, "mul+add", _alpha, 255, 255, 200 + 55 * k)
    Render(img4, ax - 100 + 100 * k, ay, 15 - 15 * k, adsize / 256)
    SetImageState(img3, "mul+add", _alpha, 255, 200 + 55 * k, 255)
    Render(img3, ax, ay - 90 + 90 * k, -10 + 10 * k, adsize / 256)
    SetImageState(img2, "mul+add", _alpha, 200 + 55 * k, 255, 255)
    Render(img2, ax + 90 - 90 * k, ay, 10 - 10 * k, adsize / 256)
    SetImageState(img1, "", _alpha, 255, 255, 255)
    Render(img1, ax, ay, 0, adsize / 256)
end

local function SetSeason()
    local w = lstg.weather
    local last_season = w.now_season
    if w.now_season == 0 or w.season_wave >= w.season_last[w.now_season] then
        w.selected_ptr = w.selected_ptr + 1
        if w.selected_ptr > #w.weather_order then
            w.selected_ptr = 1
        end
        w.now_season = 0
        w.season_wave = 0
        local flag = true
        for _, p in ipairs(w.selected_season) do
            flag = flag and p
        end
        if flag then
            w.selected_season = { false, false, false, false }
        end
        if last_season ~= 0 then
            New(Show_ChangeSeason, last_season, 0)
            task.Wait(30)
        end
    end
    if w.now_season == 0 then
        local now = w.next_season or w.weather_order[w.selected_ptr]
        if not w.next_season then
            local change_inside = (ran:Float(0, 1) < scoredata.inside_pro)
            if change_inside or w.MustSeason5 then
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
                now = 5
            else
                scoredata.inside_pro = scoredata.inside_pro + 0.05
            end
        end
        w.selected_season[now] = true
        w.now_season = now
        New(Show_ChangeSeason, now, 1)
        w.season_wave = 0
        w.next_season = nil
    end

end
stage_lib.SetSeason = SetSeason

local function saveWaveData()
    local _lib = player_lib
    local p = player
    _lib._last_cache_player = _lib._cache_player
    _lib._last_cache_var = _lib._cache_var
    _lib._last_cache_weather = _lib._cache_weather
    _lib._last_cache_active_data = _lib._cache_active_data
    if _lib._last_cache_var.rewind_CD then
        lstg.var.rewind_CD = false
    end
    _lib._cache_var = sp:CopyTable(lstg.var)
    _lib._cache_weather = sp:CopyTable(lstg.weather)
    _lib._cache_player = {}
    _lib._cache_active_data = {}
    for _, v in ipairs(lstg.var.active_item) do
        ---@type active_unit
        local Active = activeItem_lib.ActiveTotalList[v]
        _lib._cache_active_data[v] = {
            energy = Active.energy,
            charge_c = Active.charge_c,
            type = Active.type,
            energy_max = Active.energy_max,
        }
    end
    for _, v in ipairs(_lib.__must_save_data) do
        local value = p[v]
        if type(value) == "table" then
            value = sp:CopyTable(value)
        end
        _lib._cache_player[v] = value
    end
end
stage_lib.saveWaveData = saveWaveData

local function DoWaveEvent(self, wave, getwavefunc, events, event)
    local var = lstg.var
    local weather = lstg.weather

    if var._season_system then
        SetSeason()
        task.Wait()
        weather.season_wave = weather.season_wave + 1
        SetWeather()
    end
    event = event or getwavefunc(wave, events)
    if event then
        var.wave = wave
        var.now_wave_id = event.fake_id or event.id
        saveWaveData()
        if wave ~= 1 then
            activeItem_lib.AddActiveChargeByWave()
            player_lib.AddChaos(lib.GetChaosAddRange())
        end--chaos增长
        if event.islucky then
            ext.achievement:get(12)
        end
        local tvar = lstg.tmpvar
        if event.isdangerous and tvar.MarisaSkill2 then
            var.energy = var.maxenergy * var.energy_stack
        end
        player_lib.WaveInit()
        self.eventListener:Do("waveEvent@before", self, self)
        SetWave(wave, 45, event.title, event.islucky, event.isdangerous, event.isboss)
        event.event(var)
        return event
    end
end
stage_lib.DoWaveEvent = DoWaveEvent

local function DoWaveEventFake(self, wave, title, islucky, isdangerous, isboss)
    local var = lstg.var
    local weather = lstg.weather

    if var._season_system then
        SetSeason()
        task.Wait()
        weather.season_wave = weather.season_wave + 1
        SetWeather()
    end
    var.wave = wave
    saveWaveData()
    if wave ~= 1 then
        activeItem_lib.AddActiveChargeByWave()
        player_lib.AddChaos(lib.GetChaosAddRange())
    end
    if islucky then
        ext.achievement:get(12)
    end
    local tvar = lstg.tmpvar
    if isdangerous and tvar.MarisaSkill2 then
        var.energy = var.maxenergy * var.energy_stack
    end
    player_lib.WaveInit()
    self.eventListener:Do("waveEvent@before", self, self)

    SetWave(wave, 45, title, islucky, isdangerous, isboss)

end
stage_lib.DoWaveEventFake = DoWaveEventFake

local function InitMusicEvent(scene_class)
    local self = stage.current_stage
    scene_class = scene_class or self.scene_class
    self.bgmlist = scene_class._bgmlist
    self.bgm_volumes = { }
    for i, m in ipairs(scene_class._bgmlist) do
        self.bgm_volumes[i] = 0
        PlayMusic2(m, self.bgm_volumes[i])
    end
    self.music_max_volume = 0.75--太吵了，降低音量
    self.otherMusic_volume = 0
    self.cur_otherMusic = nil
    self.global_music_volume = {  }
    self.music_text_show = {}
end
stage_lib.InitMusicEvent = InitMusicEvent

local function GetChaosAddRange()
    local var = lstg.var
    local addv = { 1, 3, 4, 4, var.challenge_addchaos or 4, 3 }
    local k = addv[var.difficulty + 1]
    local w = var.wave
    if w <= 25 then
        return k * (w * w / 750 - w / 30 + 1)
    else
        return k * (1 + 0.1 * math.log(5 * (w - 25) + 1, 6))
    end
    return k
end
stage_lib.GetChaosAddRange = GetChaosAddRange

local function GetGlobalMusicVolume()
    local self = stage.current_stage
    local v = 1
    for o, p in pairs(self.global_music_volume) do
        if IsValid(o) then
            v = v * p
        else
            self.global_music_volume[o] = nil
        end

    end
    return v
end

local function SetGlobalMusicVolume(unit, s)
    local self = stage.current_stage
    if IsValid(unit) then
        self.global_music_volume[unit] = s
    else
        self.global_music_volume[unit] = nil
    end
end
stage_lib.SetGlobalMusicVolume = SetGlobalMusicVolume

local function DoMusicEvent()
    local self = stage.current_stage
    local tvar = lstg.tmpvar
    local Color = { 255, 255, 255 }
    if self.bgmlist then
        for i, m in ipairs(self.bgmlist) do

            local A, B = (i - 1) * 50, i * 50
            local chaos = lstg.var.chaos
            local flag = (A <= chaos) and (chaos < B)
            if i == #self.bgmlist then
                flag = A <= chaos
            end
            if not self.StopMusic and not tvar.otherMusic and flag then
                self.bgm_volumes[i] = min(self.bgm_volumes[i] + self.music_max_volume / 60, self.music_max_volume)
                if self.bgm_volumes[i] == 1 and not self.music_text_show[m] then
                    self.music_text_show[m] = true
                    SimpleText.MusicSign(("BGM : %s"):format(musicList[m][3]), Color)
                end
            else
                self.bgm_volumes[i] = max(self.bgm_volumes[i] - self.music_max_volume / 60, 0)
                self.music_text_show[m] = nil
            end
            if GetMusicState2(m) == "playing" then
                ext.SetBGMVolume(m, self.bgm_volumes[i] * GetGlobalMusicVolume())
            end
        end
        if not self.StopMusic and tvar.otherMusic then
            if GetMusicState2(tvar.otherMusic) ~= "playing" then
                self.cur_otherMusic = tvar.otherMusic
                self.otherMusic_volume = 0
                PlayMusic2(tvar.otherMusic, 0, tvar.otherMusic_start_time)
            end
            ext.SetBGMVolume(tvar.otherMusic, self.otherMusic_volume * GetGlobalMusicVolume())
            self.otherMusic_volume = min(self.otherMusic_volume + self.music_max_volume / 60, self.music_max_volume)
            if self.otherMusic_volume == 1 and not self.music_text_show[self.cur_otherMusic] then
                self.music_text_show[self.cur_otherMusic] = true
                SimpleText.MusicSign(("BGM : %s"):format(musicList[self.cur_otherMusic][3]), Color)
            end
        else
            self.otherMusic_volume = max(self.otherMusic_volume - self.music_max_volume / 60, 0)
            if self.otherMusic_volume == 0 and self.cur_otherMusic then
                StopMusic2(self.cur_otherMusic)
                self.music_text_show[self.cur_otherMusic] = nil
                self.cur_otherMusic = nil

            end
        end
    end
end
stage_lib.DoMusicEvent = DoMusicEvent

local function StageInit(self)
    self.eventListener = eventListener()
    LoadBossTex()
    mask_fader:Do("open")
    local var = lstg.var
    New(player_list[var.player_select].class)
    ---@type scene_class
    local scene_class = SceneClass[var.scene_id]
    self.scene_class = scene_class
    background.Create(scene_class._bg)
    if var.difficulty == 3 then
        var.maxwave = scene_class._maxwave * 2
    else
        var.maxwave = scene_class._maxwave
    end
    var.chaos = ({ 0, 100, 0 })[var.difficulty]
    var._off_chaos = var.chaos
    scene_class.init_set()
    stage_lib.InitMusicEvent()
    if not IsSpecialMode() then
        local slib = stg_levelUPlib
        if scoredata.infinite_clock then
            slib.AdditionTotalList[137]:Set(true)
        end
        if scoredata.siyuan_baby_count > 0 then

            local othercond = function(tool)
                return slib.SearchToolTag(tool, "baby") and slib.SearchToolTag(tool, "siyuan")
            end
            for _ = 1, scoredata.siyuan_baby_count do
                local p = slib.GetAdditionList(1, othercond)
                if p[1] then
                    p[1]:Set()
                end
            end
            scoredata.siyuan_baby_count = 0
        end
    end
    for _, p in ipairs(stagedata.chooseInitial) do
        if p[1] ~= 0 then
            local tool = attributeselectmenu.GetChooseInitialByID(p)
            if tool.isActive then
                tool:Set()
            else
                if (lstg.var.addition[tool.id] or 0) < (tool.maxcount or 999) then
                    tool:Set()
                end
            end
        end
    end

end
stage_lib.StageInit = StageInit

local function PassCheck()
    while true do
        local flag
        for _, o in ObjList(GROUP.ENEMY) do
            if not o.pass_check then
                flag = true
                break
            end
        end
        if not flag then
            for _, o in ObjList(GROUP.NONTJT) do
                if not o.pass_check then
                    flag = true
                    break
                end
            end
        end
        if not flag then
            break
        end
        task.Wait()
    end
end
stage_lib.PassCheck = PassCheck

local function testItem(k, count)
    local p = stg_levelUPlib.AdditionTotalList[k]
    for _ = 1, count or 1 do
        p:Set()
    end
end
stage_lib.testItem = testItem
local function testWeather(id)

    local w = lstg.weather
    w.next_weather = id
    w.next_season = weather_lib.weather[w.next_weather].inseason

end
stage_lib.testWeather = testWeather
local function testWave(id)
    lstg.var.next_wave_id = id
end
stage_lib.testWave = testWave
