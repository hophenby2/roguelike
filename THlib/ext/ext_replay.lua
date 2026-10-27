---======================================
---luastg replay
---======================================

----------------------------------------
---replay
local replay = {}
ext.replay = replay

function stage.RefreshHiscore(lost)
    local v = lstg.var
    local diff = v.difficulty + 1
    local data = stagedata
    data.hiscore[v.scene_id][diff] = max(data.hiscore[v.scene_id][diff], v.score)
    local punit = player_list[v.player_select]
    if not lost then
        local stgpass = data.stagePass
        stgpass[v.scene_id][diff] = stgpass[v.scene_id][diff] + 1
        for i, normal in ipairs({ 83, 85, 86 }) do
            if stgpass[i][2] > 0 then
                mission_lib.GoMission(normal)
            end
        end
        if stgpass[1][4] > 0 and stgpass[2][4] > 0 then
            mission_lib.GoMission(50)
        end
        if stgpass[3][4] > 0 then
            mission_lib.GoMission(65)
        end
        if diff ~= 1 then
            local passtime_player = {
                Sanae = { 103, 108 },
                Reimu = { 105 },
                Marisa = { 115, 121 },
                Aya = { 106, 141 },
                Chiruno = { 126 },
                Youmu = { 128, 147 },
                Sakuya = { 146, 148 },
            }
            for i, id in ipairs(passtime_player[punit.name] or {}) do
                mission_lib.GoMission(id, 1 / i * 100)
            end
            local passtime_mission = {
                { 78, 87, 104, 109 },
                { 84, 88, 99, 110, 114 },
                { 79, 92, 97, 111 },
                { 80, 93, 98 },
                { 81, 94, 113, 129 },
                { 82, 96, 107, 112 },
                { 100, 101, 102, 127 },
                { 118, 123, 125, 131 },
                { 119, 120, 124 },
                { 132, 133, 134, 135 }
            }
            for i, list in ipairs(passtime_mission) do
                for _, id in ipairs(list) do
                    mission_lib.GoMission(id, 1 / i * 100 + 0.1)--+0.1是因为怕有浮点数误差
                end
            end
            if #v.active_item > 0 then
                if v.scene_id == 1 then
                    mission_lib.GoMission(143)
                    mission_lib.GoMission(144)
                end
                if v.scene_id == 2 then
                    mission_lib.GoMission(142)
                    mission_lib.GoMission(145)
                end
            end
            if v.scene_id == 3 then
                local unlock = {
                    Reimu = 150,
                    Chiruno = 149,
                    Aya = 141,
                }
                if unlock[punit.name] then
                    mission_lib.GoMission(unlock[punit.name])
                end
            end
        end
    end
end


----------------------------------------
---关卡切换增强功能
---用于支持replay

---设置场景
---当mode="none"时，参数stage用于表明下一个跳转的场景
---当mode="load"时，参数path有效，指明从path录像文件中加载场景stage的录像数据
---当mode="save"时，参数path无效，使用stage指定场景名称并开始录像
---@param mode string @none, load, save录像模式
---@param path string @录像文件路径（可选）
---@param stageName string @关卡名称
function stage.Set(mode, path, stageName)
    if mode == "load" and stage.next_stage then
        return
    end --防止放replay时转场两次
    -- 刷新最高分
    --stage.RefreshHiscore()

    -- 转场
    if mode == "save" then
        assert(stageName == nil)
        stageName = path
        -- 设置随机数种子
        local v = lstg.var
        v.ran_seed = ((os.time() % 65536) * 877) % 65536
        stage.next_stage = stage.stages[stageName]--by OLC
        lstg.var.stage_name = stageName
    elseif mode == "load" then

    else
        assert(mode == "none")
        assert(stageName == nil)
        stageName = path

        -- 转场
        lstg.var.stage_name = stageName
        stage.next_stage = stage.stages[stageName]
    end
end

---重新开始场景
function stage.Restart()
    stage.preserve_res = true  -- 保留资源在转场时不清空
    stage.Set("save", lstg.var.stage_name)
end
