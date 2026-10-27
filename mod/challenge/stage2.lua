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
            local nowp = max(p.proba  + p.chaos_power * v.chaos / 100, 0) * p.pro_fixed
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
    --  target.event(lstg.var.chaos, lstg.var.difficulty)
    return target


end

local function InitWaveEvents(self)
    self.wave_events = {}
    for _, sc in ipairs(SceneClass) do
        for _, p in ipairs(sc.events) do
            local e = sp:CopyTable(p)
            e.proba = 1
            if e.state then
                if e.state == 3 then
                    e.proba = 0.01
                    e.isdangerous = true
                    e.isboss = true
                elseif e.state == 2 then
                    e.proba = 0.5
                    e.isboss = true
                end
                if e.state <= 3 then
                    table.insert(self.wave_events, e)
                end
            else
                if e.islucky then
                    e.proba = 0
                elseif e.isdangerous then
                    e.proba = 0.3
                    if e.isboss then
                        e.proba = 0.01
                    end
                elseif e.isboss then
                    e.proba = 0.5
                end
                table.insert(self.wave_events, e)
            end

        end
    end
end
stage.group.New('attr_select2', {}, "Challenge2", false)

local SimpleStage1 = stage.group.AddStage("Challenge2", "Challenge2@1", false)
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
                stage_lib.DoWaveEvent(self, w, GetWaveEvent, wevents)
                stage_lib.PassCheck()
                self.wave_events[var.now_wave_id].final()
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


local Summary = stage.group.AddStage("Challenge2", "Challenge2@2", false)
Summary.init = ChallengeSummary.init
Summary.frame = ChallengeSummary.frame
Summary.render = ChallengeSummary.render