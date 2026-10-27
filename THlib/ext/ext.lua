---=====================================
---stagegroup|replay|pausemenu system
---extra game loop
---=====================================

----------------------------------------
---ext加强库

---@class ext @额外游戏循环加强库
ext = {}
local ext = ext

local extpath = "THlib\\ext\\"
loadLanguageModule("ext", "THlib\\ext\\lang")
DoFile(extpath .. "ext_pause_menu.lua")--暂停菜单和暂停菜单资源
DoFile(extpath .. "ext_replay.lua")--CHU爷爷的replay系统以及切关函数重载
DoFile(extpath .. "ext_stage_group.lua")--关卡组
DoFile(extpath .. "ext_other.lua")--一些函数整理
DoFile(extpath .. "ext_mouse.lua")--鼠标控制
DoFile(extpath .. "ext_tutorial.lua")--用于显示字幕时的全局暂停
DoFile(extpath .. "ext_achievement.lua")
DoFile(extpath .. "ext_boss.lua")
DoFile(extpath .. "ext_level_up.lua")
DoFile(extpath .. "ext_notice_menu.lua")--小型弹窗逻辑
DoFile(extpath .. "ext_popup_menu.lua")--大型弹窗逻辑
DoFile(extpath .. "ext_season_set.lua")

local replayTicker = 0--控制录像播放速度时有用
local slowTicker = 0--控制时缓的变量
ext.FrameCounter = 0--用来改变假fps的变量
ext.RestartBlack = 0

ext.time_slow_level = { 1, 0.5, 1 / 3, 0.25 }--60/30/20/15 4个程度
ext.eventListener = eventListener()
ext.eventListener:create("frameEvent@before")
ext.eventListener:create("frameEvent@after")

---重置缓速计数器
function ext.ResetTicker()
    replayTicker = 0
    slowTicker = 0
end

----------------------------------------
---extra user function
---设置标题
local function ChangeGameTitle()
    local mod = setting.mod
    local t = {
        string.format("FPS=%.1f", GetFPS()),
        ui.version,
    }
    if DEBUG then
        table.insert(t, "Objects=" .. GetnObj())
    end
    if mod then
        SetTitle(mod .. " | " .. table.concat(t, " | "))
    else
        SetTitle(table.concat(t, " | "))
    end
end

---切关处理
local function ChangeGameStage()
    ResetWorldOffset()--by ETC，重置world偏移
    SaveScoreData()
    ext.notUIdraw = nil
    lstg.ui.alpha = 1
    lstg.ui.alpha2 = 1
    lstg.ResetLstgtmpvar()--重置lstg.tmpvar
    ext.notice_menu:Clear()
    ext.DefaultMusic()
    sp:UnitListUpdate(boss_group)

    ReFreshDaySceneLock()
    if lstg.nexttmpvar then
        lstg.tmpvar = lstg.nexttmpvar
        lstg.nexttmpvar = nil
    end
    if lstg.nextvar then
        lstg.var = lstg.nextvar
        lstg.nextvar = nil
    end


    -- 初始化随机数
    if lstg.var.ran_seed then
        ran:Seed(lstg.var.ran_seed)
    end
    if not stage.next_stage.is_menu then
    end
    ext.boss_ui:refresh()
    --切换关卡
    SetSuperPause(0)
    stage.current_stage = stage.next_stage
    stage.next_stage = nil
    stage.current_stage.timer = 0
    stage.current_stage:init()
end

---行为帧动作(和游戏循环的帧更新分开)
local function DoFrame()
    --切关处理
    local stage = stage
    if stage.next_stage then
        if #ext.saveScreenCache > 0 then
            lstg.FileManager.CreateDirectory(ext.SaveScreenPath)
            for i = #ext.saveScreenCache, 1, -1 do
                local str = ext.saveScreenCache[i]
                table.insert(SMALL_LOADING, function()
                    SaveTexture(str, ("%s\\%s.png"):format(ext.SaveScreenPath, str))
                end)
                table.remove(ext.saveScreenCache, i)
            end
            stage.next_next_stage = stage.next_stage
            stage.next_stage = stage.stages["small_loading"]
        end--极其耗费运行
        --切关时清空资源和回收对象
        if stage.current_stage then
            stage.current_stage:del()
            task.Clear(stage.current_stage)
            if stage.preserve_res then
                stage.preserve_res = nil
            else
                RemoveResource 'stage'
            end
            ResetPool()
        end
        ChangeGameStage()
    end
    --刷新输入
    GetInput()
    local nopause = (GetCurrentSuperPause() <= 0)
    if nopause or stage.nopause then
        task.Do(stage.current_stage)
        stage.current_stage:frame()
        stage.current_stage.timer = stage.current_stage.timer + 1
    end
    local w = lstg.world
    local inboundboss = inboundboss
    local boss_group = boss_group
    sp:UnitListUpdate(boss_group)
    for t in ipairs(inboundboss) do
        inboundboss[t] = nil
    end
    for _, b in ipairs(boss_group) do
        if sp.math.PointBoundCheck(b.x, b.y, w.l, w.r, w.b, w.t) then
            table.insert(inboundboss, b)
        end
    end
    ObjFrame()
    ext.boss_ui:frame()
    if nopause or stage.nopause then
        BoundCheck()
    end
    if nopause then
        ---@type object

        local CollisionCheck = CollisionCheck
        local GROUP = GROUP
        CollisionCheck(GROUP.PLAYER, GROUP.ENEMY_BULLET)
        CollisionCheck(GROUP.PLAYER, GROUP.ENEMY)
        CollisionCheck(GROUP.PLAYER, GROUP.INDES)
        CollisionCheck(GROUP.ENEMY, GROUP.PLAYER_BULLET)
        CollisionCheck(GROUP.NONTJT, GROUP.PLAYER_BULLET)
        CollisionCheck(GROUP.ITEM, GROUP.PLAYER)
        CollisionCheck(GROUP.ITEM2, GROUP.PLAYER)
        CollisionCheck(GROUP.SPELL, GROUP.ENEMY)
        CollisionCheck(GROUP.SPELL, GROUP.NONTJT)
        CollisionCheck(GROUP.SPELL, GROUP.ENEMY_BULLET)
        CollisionCheck(GROUP.SPELL, GROUP.INDES)
        CollisionCheck(GROUP.PLAYER, GROUP.LASER)
        CollisionCheck(GROUP.SPELL, GROUP.LASER)
        CollisionCheck(GROUP.CPLAYER, GROUP.PLAYER)
    end

    UpdateXY()
    AfterFrame()
end
_G.DoFrame = DoFrame

---优先菜单弹出统一管理
local PriorMenu = {
    ext.tutorial,
    ext.season_set,
    ext.level_menu,
    ext.popup_menu,

}
ext.PriorMenu = PriorMenu
local function CheckPriorMenuKilled()
    local flag = true
    for _, p in ipairs(PriorMenu) do
        if not p:IsKilled() then
            flag = false
            break
        end
    end
    return flag
end
ext.CheckPriorMenuKilled = CheckPriorMenuKilled
local function PriorMenuFrame()
    local flag = true
    for _, p in ipairs(PriorMenu) do
        if flag then
            p:frame()
        else
            break
        end
        flag = p:IsKilled()
    end
end
local function PriorMenuRender()
    for i = #PriorMenu, 1, -1 do
        local p = PriorMenu[i]
        p:render()
    end
end

---缓速和加速
local function DoFrameEx(differ)
    local Count = ext.GetFakeFPS()
    --正常游戏时
    slowTicker = slowTicker + 1
    ext.FrameCounter = ext.FrameCounter + Count
    for _ = 1, ext.FrameCounter do
        ext.OldScreenEff:Reset()
        ext.OtherScreenEff:Reset()
        if ext.CheckPriorMenuKilled() then
            DoFrame()
        else
            PriorMenuFrame()
        end

        ext.FrameCounter = ext.FrameCounter - 1
        --  ext.pause_menu_order = nil
    end
    ext.MusicFrame(Count)
    --不想要被动掉帧的时候音乐变慢，那就不要differ了
    -- ext.MusicFrame(Count / differ)
    --ext.MusicFrame("faketimer", differ)
    --ext.FastMusic()
end

----------------------------------------
---extra game call-back function
local differ = 1
local offset = 0
local stopWatch = lstg.StopWatch()
local before, after = 0, 0
local debugui = require("THlib.lib.Ldebug")
local _DEBUG = DEBUG
local setting = setting
function FrameFunc()
    _DEBUG = DEBUG
    if _DEBUG then
        debugui.update()
    end
    after = stopWatch:GetElapsed()
    differ = (after - before) * 60
    before = stopWatch:GetElapsed()

    --标题设置
    ChangeGameTitle()
    ext.Debugging()

    task.Do(ext)
    local stage, lstg = stage, lstg
    --执行场景逻辑
    if ext.pause_menu:IsKilled() and not (lstg.tmpvar and lstg.tmpvar.stopFrame) then
        --处理录像速度与正常更新逻辑
        ext.eventListener:Do("frameEvent@before")
        local add = 0
        offset = offset + (differ - 1)
        if offset > 1 then
            add = int(offset)
            offset = offset - add
        end
        DoFrameEx(1 + add)
        ext.eventListener:Do("frameEvent@after")
        --按键弹出菜单
        if lstg.tmpvar.EscIsOccupied then
            lstg.tmpvar.EscIsOccupied = nil
        else
            if (GetLastKey() == setting.keysys.menu and not lstg.tmpvar.noPause or ext.pop_pause_menu) and not ext.StageIsMenu() then
                ext.pause_menu:FlyIn()
            end
        end

    end
    --暂停菜单更新
    if stage.current_stage then
        if not ext.StageIsMenu() then
            ext.pause_menu:frame()
        else
            ext.music = {}
        end
    end

    ext.achievement:frame()
    ext.notice_menu:frame()

    --游玩时间计算
    ext.InputDuration()

    if _DEBUG then
        debugui.layout()
    end

    if lstg.quit_flag then
        GameExit()
    end

    --退出游戏逻辑
    return lstg.quit_flag
end

function RenderFunc()
    BeginScene()
    SetViewMode("ui")
    if SetWorldFlag then SetWorldFlag(1) end
    Failed_Show:BeforeRender()
    ext.saveScreenBefore()

    ext.OtherScreenEff:BeforeRender()
    ext.OldScreenEff:BeforeRender()

    local stage = stage
    if stage.current_stage then
        mask_fader:BeforeRender()
        stage.current_stage:render()
        if lstg.var.init_player_data and not ext.StageIsMenu() and not ext.notUIdraw then
            ui.DrawFrame(self)
            ui.DrawScore(self)
        end
        ObjRender()
    end
    ext.boss_ui:render()
    ext.OldScreenEff:AfterRender()
    ext.OtherScreenEff:AfterRender()

    ext.saveScreenAfter()
    if ext.RestartBlack > 0 and not stage.current_stage.is_menu then
        SetImageState("white", "", ext.RestartBlack * 255, 0, 0, 0)
        RenderRect("white", 0, screen.width, 0, screen.height)
    end
    mask_fader:AfterRender()
    Failed_Show:AfterRender()

    mask_fader:frame()
    Failed_Show:frame()
    if _DEBUG and Collision_Checker then
        Collision_Checker.render()
    end

    SetViewMode("ui")
    PriorMenuRender()
    ext.pause_menu:render()
    ext.achievement:render()
    ext.notice_menu:render()

    SetViewMode("ui")
    ext.RenderFPS()
    if _DEBUG then
        debugui.draw()
    end
    EndScene()
    --截图
    if GetLastKey() == setting.keysys.snapshot then
        lstg.FileManager.CreateDirectory("snapshot")
        Snapshot('snapshot\\' .. os.date("!%Y-%m-%d-%H-%M-%S", os.time()) .. '.png')
    end
end

function FocusLoseFunc()
    --[[if not stage.current_stage.is_menu and ext.pause_menu:IsKilled() then
        ext.pause_menu:FlyIn()
    end--]]
end--失去焦点时弹出暂停
