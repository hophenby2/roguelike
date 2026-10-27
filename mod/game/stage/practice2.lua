stage.group.New('attr_select3', {}, "practice2", false)
local SimpleStage1 = stage.group.AddStage("practice2", "practice2@1", false)
function SimpleStage1:init()
    self.is_practice = true
    self.eventListener = eventListener()
    LoadBossTex()
    mask_fader:Do("open")
    local var = lstg.var
    New(player_list[var.player_select].class)
    ---@type scene_class
    local scene_class = SceneClass[var.practice_inscene]
    self.scene_class = scene_class
    background.Create(scene_class._bg)
    --var.wave = 0
    var.maxwave = 1
    var.difficulty = 5
    var.chaos = var.practice_chaos
    var._pathlike = true
     scene_class.init_set()
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
    task.New(self, function()
        local w = 1
        while w <= var.maxwave do
            local event = scene_class.events[var.practice_id]
            var.frame_counting = true
            if event.state > 3 then
                var.level = 100
            end
            stage_lib.DoNodeEvent(self, 1, event)
            stage_lib.PassCheck()
            var.frame_counting = false
            local waiting = New(stage_lib.WaitForSpace)
            while IsValid(waiting) and waiting.flag do
                task.Wait()
            end
            stage_lib.ClearScreen()
            event.final()
            self.eventListener:Do("waveEvent@after", self, self)
            var.stop_getting = false--每波结束开启
            task.Wait()

            w = w + 1
        end
        task.Wait(60)
        lstg.tmpvar.noPause = true
        --stage.RefreshHiscore(false)
        stage.group.ActionDo("直接结束游玩")


    end)
end