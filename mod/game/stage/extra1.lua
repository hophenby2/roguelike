local function GetGlobalWaveEvent(wave, events)
    local v = lstg.var
    local w = lstg.weather
    local target
    local self = stage.current_stage
    if v.next_wave_id then
        target = self.scene_class.events[v.next_wave_id]
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
            local nowp = max(base + p.chaos_power * v.chaos / 100, 0) * p.pro_fixed
            table.insert(pro, { p, lastp, lastp + nowp })
            lastp = lastp + nowp
        end
        for _, p in ipairs(events) do
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
            local scene_class = self.scene_class
            for _, p in ipairs(scene_class.events) do
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

stage.group.New('attr_select', {}, "Extra1", false)
local Exstage1 = stage.group.AddStage("Extra1", "Extra1@1", false)
function Exstage1:init()
    local var = lstg.var
    local scene_class = SceneClass[var.scene_id]
    stage_lib.StageInit(self)
    self.start_function = function(init_w)
        task.New(self, function()
            local w = init_w
            local events = sp:CopyTable(scene_class.events)
            for _, e in ipairs(events) do
                e.proba = 1
                if e.islucky then
                    e.proba = 0.01
                elseif e.isdangerous then
                    e.proba = 0.3
                    if e.isboss then
                        e.proba = 0.01
                    end
                elseif e.isboss then
                    e.proba = 0.5
                end
            end--统一概率
            while w <= var.maxwave do
                stage_lib.DoWaveEvent(self, w, GetGlobalWaveEvent, events)
                stage_lib.PassCheck()
                scene_class.events[var.now_wave_id].final()
                self.eventListener:Do("waveEvent@after", self, self)
                task.Wait()

                w = w + 1
            end
            task.Wait(30)
            lstg.tmpvar.noPause = true
            New(stage.stage_clear_object, 2000000)
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
        if DEBUG then
            --stage_lib.testWeather(33)
        end
        self.start_function(1)
    end)
end

local Summary = stage.group.AddStage("Extra1", "Extra1@2", false)
Summary.init = StageSummary.init
Summary.frame = StageSummary.frame
Summary.render = StageSummary.render