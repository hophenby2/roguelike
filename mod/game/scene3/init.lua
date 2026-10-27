local function _t(str)
    return i18n("scene", str) or ""
end

local lib = stage_lib
local class = lib.NewSceneClass(3, "scene3_pic", BG_5,
        { "3_1", "3_2", "3_3", "3_4" }, "3_end",
        20, _t("scene3"), _t("scene3_des"), function()
            local var = lstg.var
            --var.exp_line_func = stage_lib.GetPathlikeEXPline()
           -- var._pathlike = true
            var._season_system = true
            var.level_exp_index = 9.2
            --var.level_offset = var.level_offset + 1
        end, {
            NewLockFunction("tool:186"),
            NewLockFunction("scene:2"),
        }, _t("classical") .. "+" .. _t("weaSys"))

loadLanguageModule("scene3", "mod\\game\\scene3")
local path = "mod\\game\\scene3\\"
LoadTexture("scene3_pic", path .. "pic.png")

DoFile(path .. "tutorial.lua")
DoFile(path .. "1.lua")
DoFile(path .. "2.lua")
