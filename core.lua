---=====================================
---core
---所有基础的东西都会在这里定义
---=====================================

lstg = lstg or {}

----------------------------------------
---用户定义的一些函数
function GameExit()
    if not lstg.quit_flag then
        if not scoredata["Alt+F4"] then
            scoredata["Alt+F4"] = true
        end
    end
    SaveScoreData()

end

----------------------------------------
---全局回调函数，底层调用
function GameInit()

    OldSaveToNew()

    --准备
    InitScoreData()
    Include 'THlib\\THlib.lua'
    InitAllClass()
    InitMusicList()

    _editor_class = {}
    _editor_boss = {}
    _sc_list = {}
    SceneClass = {}
    boss_group = {}
    inboundboss = {}
    AchievementInfo = {}
    cheat = nil
    math.randomseed(os.time())
    SaveScoreData()

    SetViewMode("world")

    --加载

    setting.mod = "Touhou Roguelike"
    save_setting()
    if not ChangeVideoMode2(setting) then
        error(setting.windowed and "Invalid Resolution" or "Failed to FullScreen")
        --stage.QuitGame()
        --return
    end
    --初始化
    SetSEVolume(setting.sevolume / 100)
    SetBGMVolume2(setting.bgmvolume / 100)
    ResetScreen()--Lscreen
    SetResourceStatus 'global'
    ResetUI()
    Include("mod\\root.lua")

    if scoredata.first_language then
        stage.Set("none", 'init')
    else
        stage.Set("none", "language")
    end

    if setting.auto_hide_title_bar then
        local Window = require("lstg.Window")
        local main_window = Window.getMain()
        local window_win11_ext = main_window:queryInterface("lstg.Window.Windows11Extension")
        if window_win11_ext then
            window_win11_ext:setTitleBarAutoHidePreference(true)
            ChangeVideoMode2(setting)
        end
    end
    --SetResourceStatus("stage")
end

function IsSpecialMode()
    local self = stage.current_stage
    return self.is_challenge or lstg.var.is_cheatMode or self.is_practice
end

function ChangeVideoMode2(set)
    if set.windowed then
        return ChangeVideoMode(set.resx, set.resy, set.windowed, set.vsync)
    else
        local w, h = GetFullScreenResolution()
        return ChangeVideoMode(w, h, set.windowed, set.vsync)
    end
end

function DefineAchievement(id, rank, name, getway, noget_insp, hide, showcond)
    showcond = showcond or load("return true")
    AchievementInfo[id] = {
        name = name, getway = getway, hide = hide, rank = rank, showcond = showcond,
        noget_insp = noget_insp--特殊情况时不可获得，如挑战模式，作弊模式
    }
    local data = scoredata
    --由于删掉好多成就，于是乎得转成哈希表来存储
    id = tostring(id)
    if data.Achievement[id] == true then
        ext.achievement.getcount = ext.achievement.getcount + 1
    else
        data.Achievement[id] = false
    end
    data.AchievementGetTime[id] = data.AchievementGetTime[id] or false
end

function ExtractFile(src, dst)
    local infile = io.open(src, "rb")
    if not infile then
        return false, "Cannot open source file"
    end

    local content = infile:read("*all")
    infile:close()

    local outfile = io.open(dst, "wb")
    if not outfile then
        return false, "Cannot open destination file"
    end

    outfile:write(content)
    outfile:close()

    return true
end

function OldSaveToNew()
    local old_path = "User\\"
    local new_path = GetDataPath()
    local move_flag = lstg.FileManager.FileExist(old_path .. "Score1.dat") or
            lstg.FileManager.FileExist(old_path .. "Score2.dat") or
            lstg.FileManager.FileExist(old_path .. "Score3.dat")
    local ignore_flag = lstg.FileManager.FileExist(old_path .. "IGNORE")
    local function copy_file(path, new_base)
        for _, v in ipairs(lstg.FileManager.EnumFiles(path)) do
            local full_path = v[1]
            local is_dir = v[2]
            local relative = full_path:sub(#path + 1)
            local target_path = new_base .. "/" .. relative

            if is_dir then
                lstg.FileManager.CreateDirectory(target_path)
                copy_file(full_path, target_path)
            else
                -- 确保父目录已存在（以防没有提前创建）
                local parent = target_path:match("(.*/)")
                if parent then
                    lstg.FileManager.CreateDirectory(parent)
                end
                ExtractFile(full_path, target_path)
                os.remove(full_path)
            end
        end
    end
    if move_flag and not ignore_flag then
        local msg = [[检测到老存档，是否迁移到新存档目录？
An old save was detected.
Would you like to migrate it to the new save location?]]
        local ret = lstg.Platform.MessageBox("Touhou Roguelike", msg, 1)
        if ret == 1 then
            copy_file(old_path, new_path)
            loadConfigure()
            ChangeVideoMode2(setting)
            ResetScreen()
            --ResetUI()
        elseif ret == 2 then
            local f = io.open(old_path .. "IGNORE", "w")
            f:close()
        end
    end
end

local path = "THlib\\lib\\"
----------------------------------------
---各个模块

lstg.DoFile("THlib\\plus\\plus.lua")--CHU神的plus库，replay系统、plusClass、NativeAPI

lstg.DoFile(path .. "Ltable.lua")--OLC的table.sort优化
lstg.DoFile(path .. "Llanguage.lua")--多语言功能
lstg.DoFile(path .. "Lresources.lua")--资源的加载函数、资源枚举和判断
lstg.DoFile(path .. "Llog.lua")--简单的log系统
lstg.DoFile(path .. "Lglobal.lua")--用户全局变量
lstg.DoFile(path .. "Lmath.lua")--数学常量、数学函数、随机数系统
lstg.DoFile(path .. "Lobject.lua")--Luastg的Class、object
lstg.DoFile(path .. "Lobjectevents.lua")--一些object事件函数
lstg.DoFile(path .. "Lscreen.lua")--world、3d、viewmode的参数设置
lstg.DoFile(path .. "Linput.lua")--按键状态更新
lstg.DoFile(path .. "Ltask.lua")--task
lstg.DoFile(path .. "Lstage.lua")--stage关卡系统
lstg.DoFile(path .. "Ltext.lua")--文字渲染
lstg.DoFile(path .. "Lscoredata.lua")--玩家存档
lstg.DoFile(path .. "Lmission.lua")--任务


lstg.DoFile(path .. "Lmusicload.lua")--音乐加载相关
lstg.DoFile(path .. "Llockfunc.lua")--解锁方式



