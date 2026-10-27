stage.group.New('attr_select', {}, "Extra2", false)

local SimpleStage1 = stage.group.AddStage("Extra2", "Extra2@1", false)
function SimpleStage1:init()
    local var = lstg.var
    local scene_class = SceneClass[var.scene_id]
    stage_lib.StageInit(self)
    local placetotal = stage_lib.NewStagePath(scene_class, var.maxwave)
    self.start_function = function(init_w)
        var.maxwave = scene_class._maxwave * 2
        task.New(self, function()
            local y = init_w
            while var.now_path_y < 30 do
                if y > 1 then
                    local selecting = New(stage_lib.ShowPath, placetotal)
                    while IsValid(selecting) do
                        task.Wait()
                    end
                end
                var.frame_counting = true
                local cur = placetotal[var.now_path_y][var.now_path_x]
                var.chaos = stage_lib.DangerToChaos(cur.danger)
                stage_lib.DoNodeEvent(self, y, cur.node, cur.weather)
                stage_lib.PassCheck()
                cur.passed = true
                var.frame_counting = false
                local waiting = New(stage_lib.WaitForSpace)
                while IsValid(waiting) and waiting.flag do
                    task.Wait()
                end
                stage_lib.ClearScreen()
                if cur.node.state <= 3 and lstg.wave.level_up_count > 0 then
                    local slib = stg_levelUPlib
                    ---@param u addition_unit
                    for _, u in pairs(slib.AdditionTotalList) do
                        if u.RefreshFunc then
                            u:RefreshFunc()
                        end--刷新高级裨益说明
                    end
                    ext.level_menu:FlyIn(slib.GetAdditionList(nil, function(p)
                        return p.spBENEFIT
                    end))
                end
                cur.node.final()
                self.eventListener:Do("waveEvent@after", self, self)
                var.stop_getting = false--每波结束开启
                task.Wait()
                y = y + 1
            end
            task.Wait(30)
            lstg.tmpvar.noPause = true
            New(stage.stage_clear_object, (var.difficulty == 1) and 1000000 or 1500000)
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
local Summary = stage.group.AddStage("Extra2", "Extra2@2", false)
Summary.init = StageSummary.init
Summary.frame = StageSummary.frame
Summary.render = StageSummary.render

