---=====================================
---stage group
---=====================================

----------------------------------------
---关卡组
local stage = stage
local stg = {}
stage.group = stg
stage.groups = {}

--package.loaded["THlib.ext.death_text"] = nil
local death_text = require("THlib.ext.death_text")

local function _t(str)
    return i18n("ext", str) or ""
end

---新建关卡组
function stg.New(title, stages, name, allow_practice, difficulty)
    local sg = { title = title, number = #stages, _name = name }
    for i = 1, #stages do
        sg[i] = stages[i]
        local s = stage.New(stages[i])
        s.frame = stage.group.frame
        s.render = stage.group.render
        s.number = i
        s.group = sg
        sg[stages[i]] = s
        s.x, s.y = 0, 0
        s.name = stages[i]
    end
    if name then
        if stage.groups[name] then
            return stage.groups[name]
        end
        stage.groups[name] = sg
        local flag
        for _, c in ipairs(stage.groups) do
            if c == name then
                flag = true
                break
            end
        end
        if not flag then
            table.insert(stage.groups, name)
        end
    end
    sg.allow_practice = allow_practice or false
    sg.difficulty = difficulty or 1
    return sg
end

---为关卡组添加关卡
function stg.AddStage(groupname, stagename, allow_practice)
    if stage.stages[stagename] then
        return stage.stages[stagename]
    end
    if stage.groups[groupname] then
        local sg = stage.groups[groupname]
        sg.number = sg.number + 1
        table.insert(sg, stagename)
        local s = stage.New(stagename)
        s.frame = stage.group.frame
        s.render = stage.group.render
        s.number = sg.number
        s.group = sg
        sg[stagename] = s
        s.x, s.y = 0, 0
        s.name = stagename
        s.allow_practice = allow_practice or false
        return s
    end
end

---为关卡的对应key赋值
function stg.DefStageValue(stagename, key, value)
    stage.stages[stagename][key] = value
end

local function SettingInPause()
    local lstg = lstg
    local var = lstg.var
    local tvar = lstg.tmpvar
    tvar.stopFrame = true
    tvar.pause_menu_text = nil
    tvar.noPause = true
    tvar.noresumeSound = true
    ext.DefaultMusic()
    for _, m in ipairs(ext.PriorMenu) do
        m.kill = true
        task.New(ext, function()
            for i = 1, 10 do
                m.alpha = min(1 - i / 10, m.alpha)
                task.Wait()
            end
        end)
    end
end
function stg.ActionDo(order)
    local lstg = lstg
    local var = lstg.var
    local tvar = lstg.tmpvar
    if order == "重新开始" then
        SettingInPause()
        mask_fader:Do("last", 15)
        task.New(ext, function()

            task.Wait(10 + 1)
            tvar.stopFrame = false
            --stg.ReturnToTitle()
            stage.Set('save', stage.current_stage.group[1])
        end)
    end
    if order == "直接结束游玩" then
        SettingInPause()
        task.New(ext, function()
            mask_fader:Do("close")
            task.Wait(15 + 1)
            tvar.stopFrame = false
            stg.ReturnToTitle()
            lstg.var.is_cheatMode = nil
        end)
    end
    if order == "进入结算" then
        SettingInPause()
        task.New(ext, function()
            mask_fader:Do("close")
            task.Wait(15 + 1)
            tvar.stopFrame = false
            var.lost = true
            stage_lib.saveWaveData()
            stg.NextStage()
        end)
    end
end

ext.ExecuteFlag = false
function stg.frame()
    local self = stage.current_stage
    local lstg = lstg
    local var = lstg.var
    local tvar = lstg.tmpvar
    local wea = lstg.weather
    if self.scene_class and not self.is_summary then
        self.scene_class.frame_set()
    end
    stage_lib.DoMusicEvent()
    if var.lifeleft <= 0 and not ext.ExecuteFlag then
        scoredata._total_death = scoredata._total_death + 1
        ext.achievement:get(18)
        mission_lib.GoMission(7)
        mission_lib.GoMission(16, 1 / 5 * 100)
        mission_lib.GoMission(32, 1 / 10 * 100)
        mission_lib.GoMission(33, 1 / 15 * 100)
        mission_lib.GoMission(63, 1 / 20 * 100)
        if var.del_bullet_with_enemy then
            object.BulletDo(function(b)
                object.Del(b)
            end)
        end
        if activeItem_lib.IfHasActive(5) then
            --红心火龙果
            activeItem_lib.PitayaResurection()
        elseif wea.GanYao then
            --绀药
            weather_lib.GanYaoRewind()
        elseif var.resurrect9 > 0 then
            --九代稗谷
            stg_levelUPlib.Resurrect9_func()
        elseif var.rewindable and not var.rewind_CD and var.wave > 1 then
            --时间回溯
            ext.ExecuteFlag = true
            stg_levelUPlib.Rewinding()

        elseif var.fire_bird_resurrection and not tvar.bird_resurrecting then
            --不死的尾羽
            stg_levelUPlib.BirdResurrecting()
        else
            if wea.YunYing then
                weather_lib.class.PutYunYing(player.x, player.y)
                ext.achievement:get(81)
            end
            if wea.QiuShuang then
                New(boss_explode_maple, player.x, player.y, 80)
                ext.achievement:get(82)
            end
            if tvar.sc_name == "药符「酒石酸唑吡坦」" then
                ext.achievement:get(80)
            end
            StopSound("resurrecting")
            PlaySound("pldead01")
            --lstg.tmpvar.lost = true
            var.lost = true
            ext.ExecuteFlag = true
            tvar.noPause = true
            player.colli = false
            player.lock = true
            for _, b in ObjList(GROUP.PLAYER) do
                task.Clear(b)
            end
            object.EnemyNontjtDo(function(b)
                task.Clear(b)
            end)
            object.BulletIndesDo(function(b)
                task.Clear(b)
            end)
            --task.Clear(self)
            if self.is_tutorial then

                task.New(self, function()
                    ext.tutorial:event(function(unit)
                        local n1 = unit:addtext(_t("tutorialDeath1"), 480, 270, 1.2, 230, 230, 230)
                        for i = 1, 15 do
                            i = task.SetMode[2](i / 15)
                            n1.alpha = i
                            task.Wait()
                        end
                        unit:waitforpress()
                        local n2 = unit:addtext(_t("tutorialDeath2"), 480, 270, 1.2, 230, 230, 230)
                        for i = 1, 15 do
                            i = task.SetMode[2](i / 15)
                            n1.y = 270 + 20 * i
                            n2.y = 270 - 20 * i
                            n2.alpha = i
                            task.Wait()
                        end
                        unit:waitforpress()
                        for i = 1, 15 do
                            i = task.SetMode[2](i / 15)
                            n1.alpha = 1 - i
                            n2.alpha = 1 - i
                            task.Wait()
                        end
                        unit:deltext(n1)
                        unit:deltext(n2)
                    end)
                    task.Wait()
                    mask_fader:Do("close")
                    task.Wait(15)
                    stage.Set('save', self.group[1])
                    var.lifeleft = 1--防止再检测
                    ext.ExecuteFlag = false
                end)
            elseif self.is_practice then
                task.New(self, function()
                    --Failed_Show:Do(175, death_text.check_death())
                   -- task.Wait(100)
                  --  lstg.tmpvar.StopMusic = true
                  --  task.Wait(60)
                    mask_fader:Do("close")
                    task.Wait(15)
                    stage.Set('save', self.group[1])
                    var.lifeleft = 1--防止再检测
                    ext.ExecuteFlag = false
                end)
            else
                task.New(self, function()
                    Failed_Show:Do(175, death_text.check_death())
                    task.Wait(100)
                    lstg.tmpvar.StopMusic = true
                    task.Wait(60)
                    mask_fader:Do("close")
                    task.Wait(15)
                    stage_lib.saveWaveData()
                    stg.NextStage()
                    var.lifeleft = 1--防止再检测
                    ext.ExecuteFlag = false
                end)
            end
        end


    end
    if var.lifeleft > 0 and not self.is_tutorial then
        if self.is_challenge then
            local challenge_id = var.challenge_select
            if challenge_id and tvar.fileexist and tvar.objcount then
                local name = ("Challenge%d"):format(challenge_id)
                if tvar.fileexist[challenge_id] == nil then
                    tvar.fileexist[challenge_id] = FileExist(("%s\\%s.png"):format(ext.SaveScreenPath, name))
                end
                if not tvar.fileexist[challenge_id] then
                    tvar.objcount[challenge_id] = tvar.objcount[challenge_id] or 0
                    local count = 0
                    local doevent = function(e)
                        if e._IsTagged then
                            --标记弹幕和敌人所在波，以免混淆
                            if e._IsTagged == challenge_id then
                                count = count + 1
                            end
                        else
                            e._IsTagged = challenge_id
                            count = count + 1
                        end
                    end
                    object.BulletIndesDo(doevent)
                    object.EnemyNontjtDo(doevent)
                    if tvar.objcount[challenge_id] < count then
                        tvar.objcount[challenge_id] = count
                        ext.saveScreenToFile = name
                    end
                end
            end
        else
            local scene_id = var.scene_id
            local wave_id = var.now_wave_id
            if self.is_practice then
                scene_id = var.practice_inscene
                wave_id = var.practice_id
            end
            if scene_id and wave_id and tvar.fileexist and tvar.objcount then
                local name = ("WavePic_%d_%d"):format(scene_id, wave_id)

                if tvar.fileexist[wave_id] == nil then
                    tvar.fileexist[wave_id] = FileExist(("%s\\%s.png"):format(ext.SaveScreenPath, name))
                end
                if not tvar.fileexist[wave_id] then
                    tvar.objcount[wave_id] = tvar.objcount[wave_id] or 0
                    local count = 0
                    local doevent = function(e)
                        if e._IsTagged then
                            --标记弹幕和敌人所在波，以免混淆
                            if e._IsTagged == wave_id then
                                count = count + 1
                            end
                        else
                            e._IsTagged = wave_id
                            count = count + 1
                        end
                    end
                    object.BulletIndesDo(doevent)
                    object.EnemyNontjtDo(doevent)
                    if tvar.objcount[wave_id] < count then
                        tvar.objcount[wave_id] = count
                        ext.saveScreenToFile = name
                    end
                end
            end
        end
    end

    if not tvar.noPause and GetKeyState(KEY.R) then
        ext.RestartBlack = min(1, ext.RestartBlack + 1 / 60)
        if GetKeyState(KEY.TAB) then
            ext.RestartBlack = 1
        end
        if ext.RestartBlack == 1 then
            stg.ActionDo("重新开始")
            ext.RestartBlack = 0
        end
    else
        ext.RestartBlack = max(0, ext.RestartBlack - 1 / 25)
    end
end

function stg.render()
    SetViewMode 'world'
    RenderClearViewMode(Color(255, 0, 0, 0))
end

function stg.Start(group)
    lstg.var.is_practice = false
    stage.Set('save', group[1])
    stage.stages[group.title].save_replay = { group[1] }
    ext.ExecuteFlag = false
end

function stg.NextStage()
    local self = stage.current_stage
    local group = self.group
    stage.Set('save', group[self.number + 1])
end

function stg.ReturnToTitle()
    for _, v in pairs(EnumRes2('bgm')) do
        if GetMusicState2(v) == "playing" then
            StopMusic2(v)
        end
    end
    stage.Set('none', stage.current_stage.group.title)
end






