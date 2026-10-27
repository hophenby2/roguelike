local function _t(str)
    return i18n("scene", str) or ""
end

local lib = stage_lib
lib.NewSceneClass(1, "scene1_pic", BG_18,
        { "1_1", "1_2", "1_3", "1_4" }, "1_end",
        15, _t("scene1"), _t("scene1_des"), function()
        end, nil, _t("classical"))

loadLanguageModule("scene1", "mod\\game\\scene1")
local path = "mod\\game\\scene1\\"
LoadTexture("scene1_pic", path .. "pic.png")
DoFile(path .. "tutorial.lua")
DoFile(path .. "1.lua")
DoFile(path .. "2.lua")
DoFile(path .. "3.lua")

