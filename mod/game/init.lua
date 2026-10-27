local lib = {}
stage_lib = lib
---@param money number
---@param conditionList table
local function SetSceneUnlockWay(self, conditionList)
    if conditionList then
        self.conditionList = conditionList or {}
        local data = stagedata
        local strid = tostring(self.id)
        data.scene_unlock[strid] = data.scene_unlock[strid] or false
        self.unlock_way = function()
            return data.scene_unlock[strid]
        end
    else
        self.unlock_way = load("return true")
    end
end
---@return scene_class
local function NewSceneClass(id, pic, bg, bgmlist, finalbgm, maxwave, title, describe, initset, conditionList, mode_des)
    ---@class scene_class
    local unit = {}
    --游戏外属性
    unit.id = id
    unit.tex = pic
    unit.describe = describe or ""
    unit.pulse = 0
    unit.title = title
    unit.title2 = title:match(".+%.(.+)")
    --在传统模式下，事件一般填充于此
    unit.wave_events = {}
    unit.events = {}
    --在路径模式下，要有节点表
    unit.nodes = {}
    unit.nodesBystate = {}

    unit.init_set = initset or function()
    end
    unit.frame_set = function()
    end
    SetSceneUnlockWay(unit, conditionList)
    --游戏内属性
    unit._bg = bg
    unit._bgmlist = bgmlist
    unit._final_bgm = finalbgm
    unit._maxwave = maxwave
    unit.mode_des = mode_des or ""
    unit.inStageID = 1--关卡

    SceneClass[id] = unit
    local data = stagedata
    data.DiffSelection[id] = data.DiffSelection[id] or 1
    data.stagePass[id] = data.stagePass[id] or { 0, 0, 0, 0 }
    data.hiscore[id] = data.hiscore[id] or { 0, 0, 0, 0 }
    data.scene_unlock[tostring(id)] = data.scene_unlock[tostring(id)] or false
    data.BookWave[id] = data.BookWave[id] or {}
    return unit
end
lib.NewSceneClass = NewSceneClass

---目前采用的变量与chaos相关的变化模型
function lib.GetValue(v0, v50, v100, maxv, chaos, tindex)
    chaos = chaos or lstg.var.chaos
    tindex = tindex or 0.5
    if v0 then
        if chaos < 50 then
            return v0 + tindex * (v50 - v0) / 2500 * chaos * chaos
        elseif chaos < 100 then
            local _c = chaos - 50
            return v50 + tindex * (v100 - v50) / 2500 * _c * _c
        else
            return maxv + (v100 - maxv) / (chaos - 100 + 1100) * 1100
        end
    else
        if chaos < 50 then
            return 1
        elseif chaos < 100 then
            return 2
        else
            return 3
        end
    end
end

------------------------------------------------
------------------------------------------------
---
local function GetHP(t)
    local v = lstg.var
    local w = lstg.weather
    local offset = 0
    if v._season_system then
        if w.LiXia then
            offset = offset + v.maxlife * 0.25
        end
        offset = offset + w.enemyHP_offset
    end
    return t * v.enemyHP_index + offset
end
lib.GetHP = GetHP

DoFile("mod\\game\\stage\\simple1.lua")
DoFile("mod\\game\\stage\\extra1.lua")
DoFile("mod\\game\\stage\\practice1.lua")
DoFile("mod\\game\\wave_init.lua")
DoFile("mod\\game\\stage\\simple2.lua")
DoFile("mod\\game\\stage\\extra2.lua")
DoFile("mod\\game\\stage\\practice2.lua")
DoFile("mod\\game\\node_init.lua")

loadLanguageModule("scene", "mod\\game\\scene_lang")
DoFile("mod\\game\\tutorial0.lua")

DoFile("mod\\game\\scene1\\init.lua")
DoFile("mod\\game\\scene2\\init.lua")
DoFile("mod\\game\\scene3\\init.lua")