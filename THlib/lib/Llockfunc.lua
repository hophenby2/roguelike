local langModule = "lockfunc"
loadLanguageModule(langModule, "THlib\\lib\\lang")
local function _t(str)
    return i18n(langModule, str) or ""
end

---@class lock_unit
local LockUnit = plus.Class()
function LockUnit:init(func, describe)
    self.func = func
    self.describe = describe
end

---通过特定指令快速生成解锁方式或者直接生成一个
---①scene:id
---②tool:id
---@overload fun(command:string):lock_unit
function NewLockFunction(func, describe)
    if not describe then
        if func:sub(1, 10) == "getbenefit" then
            local _, count = func:match("^(.+):(%d+)$")
            count = tonumber(count)
            return LockUnit(function(self)
                self.describe = _t("getBenefit"):format(count, scoredata._total_get_benefit, count)
                return scoredata._total_get_benefit >= count
            end, "")
        end
        if func:sub(1, 10) == "scenecount" then
            local _, id, count = func:match("^(.+):(%d+):(%d+)$")
            id = tonumber(id)
            count = tonumber(count)
            return LockUnit(function(self)
                local scene = SceneClass[id]
                local data = stagedata.stagePass[id]
                self.describe = _t("passSceneCount"):format(scene.title, count, data[2] + data[3] + data[4], count)
                return data[2] + data[3] + data[4] >= count
            end, "")
        end
        if func:sub(1, 5) == "scene" then
            local _, id = func:match("^(.+):(%d+)$")
            id = tonumber(id)
            return LockUnit(function(self)
                local scene = SceneClass[id]
                local data = stagedata.stagePass[id]
                self.describe = _t("passScene"):format(scene.title)
                return data[2] > 0 or data[3] > 0 or data[4] > 0
            end, "")
        end

        if func:sub(1, 4) == "tool" then
            local _, id = func:match("^(.+):(%d+)$")
            id = tonumber(id)
            return LockUnit(function(self)
                local tool = stg_levelUPlib.AdditionTotalList[id]
                self.describe = _t("unlockItem"):format(tool.title2)
                return scoredata.UnlockAddition[id]
            end, "")
        end
        if func:sub(1, 8) == "booktool" then
            local _, id = func:match("^(.+):(%d+)$")
            id = tonumber(id)
            return LockUnit(function(self)
                local tool = stg_levelUPlib.AdditionTotalList[id]
                self.describe = _t("seenItem"):format(tool.title2)
                return scoredata.BookAddition[id]
            end, "")
        end
        if func:sub(1, 11) == "bookweather" then
            local _, id = func:match("^(.+):(%d+)$")
            id = tonumber(id)
            return LockUnit(function(self)
                local wea = weather_lib.weather[id]
                self.describe = _t("seenWx"):format(wea.name)
                return scoredata.Weather[id]
            end, "")
        end
        if func:sub(1, 12) == "AfterWeather" then
            return LockUnit(function(self)
                self.describe = _t("seenWxsys")
                return scoredata.FirstWeather
            end, "")
        end
        if func:sub(1, 12) == "After5Season" then
            return LockUnit(function(self)
                self.describe = _t("seenInside")
                return scoredata.First5Season
            end, "")
        end
        if func:sub(1, 13) == "passChallenge" then
            local _, id = func:match("^(.+):(%d+)$")
            id = tonumber(id)
            return LockUnit(function(self)
                local cc = challenge_lib.class[id]
                self.describe = _t("passChallenge"):format(cc.id, cc.title)
                return stagedata.challenge_finish[id] > 0
            end, "")
        end

    else
        return LockUnit(func, describe)
    end
end

function ReFreshDaySceneLock()
end


