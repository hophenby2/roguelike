local function GetRandomWave()
    local list = {}
    for _, sc in ipairs(SceneClass) do
        for _, e in ipairs(sc.events) do
            if stagedata.BookWave[e.inscene][e.id] then
                list[#list + 1] = e
            end
        end
    end
    local target = list[ran:Int(1, #list)]
    return target.inscene, target.id
end

stage.group.New('attr_select3', {}, "practice1", false)
local SimpleStage1 = stage.group.AddStage("practice1", "practice1@1", false)
function SimpleStage1:init()
    self.is_practice = true
    self.eventListener = eventListener()
    LoadBossTex()
    mask_fader:Do("open")
    local var = lstg.var
    New(player_list[var.player_select].class)
    local inscene = var.practice_inscene
    local waveid = var.practice_id
    if var.practice_mode == "weather" then
        inscene, waveid = GetRandomWave()
        var._season_system = true
        var.practice_inscene = inscene
        var.practice_id = waveid
    end
    ---@type scene_class
    local scene_class = SceneClass[inscene]
    self.scene_class = scene_class
    background.Create(scene_class._bg)
    --var.wave = 0
    var.maxwave = 1
    var.difficulty = 5
    var.chaos = var.practice_chaos
    -- scene_class.init_set()
    stage_lib.InitMusicEvent()
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
    self.start_function = function()
        if var._season_system then
            local weather = lstg.weather
            local current_weather = weather_lib.weather[var.practice_weather]
            weather.next_season = current_weather.inseason
            weather.next_weather = current_weather.id
        end
        local w = 1
        while w <= var.maxwave do
            local event = scene_class.events[waveid]
            stage_lib.DoWaveEvent(self, w, nil, nil, event)
            stage_lib.PassCheck()
            event.final()
            self.eventListener:Do("waveEvent@after", self, self)
            task.Wait()

            w = w + 1
        end
        task.Wait(60)
        lstg.tmpvar.noPause = true
        --stage.RefreshHiscore(false)
        stage.group.ActionDo("直接结束游玩")
    end
    task.New(self, function()
        self.start_function()

    end)
end