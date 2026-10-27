local function _t(str)
    return i18n("scene", str) or ""
end

local lib = stage_lib
local class = lib.NewSceneClass(2, "scene2_pic", BG_9,
        { "2_1", "2_2", "2_3", "2_4" }, "2_end",
        15, _t("scene2"), _t("scene2_des"), function()
            local var = lstg.var
            var.level_exp_index = 9.2
            --var.exp_factor = var.exp_factor - 0.2
            var._season_system = true--开启季节系统
        end, {
            NewLockFunction("tool:82"),
            NewLockFunction("scene:1"),
        }, _t("classical") .. "+" .. _t("weaSys"))
class.frame_set = function()
    local v = lstg.var
    if v.chaos >= 150 then
        ext.achievement:get(84)
    end
end

loadLanguageModule("scene2", "mod\\game\\scene2")
local path = "mod\\game\\scene2\\"
LoadTexture("scene2_pic", path .. "pic.png")
DoFile(path .. "tutorial.lua")
DoFile(path .. "1.lua")
DoFile(path .. "2.lua")
DoFile(path .. "3.lua")
