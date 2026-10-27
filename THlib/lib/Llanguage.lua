local currentLanguage = setting.language or 1
local languageCache = {}
local languageMap = { "ch", "en", "jp" }
function ResetLanguageCache()
    languageCache = {}
end

function loadLanguageModule(module, fpath)
    if not languageCache[currentLanguage] then
        languageCache[currentLanguage] = {}
    end

    if not languageCache[currentLanguage][module] then
        local path = ("%s\\%s_%s.lua"):format(fpath, module, languageMap[currentLanguage])

        languageCache[currentLanguage][module] = DoFile(path)
    end

    return languageCache[currentLanguage][module]
end

function switchLanguage(language, init)
    currentLanguage = language
    languageCache[currentLanguage] = {}
    loadLanguageModule("ext", "THlib\\ext\\lang")
    loadLanguageModule("lockfunc", "THlib\\lib\\lang")
    ext.achievement.getcount = 0
    --[[
    local lang = { "ch", "en" }
    local path = "THlib\\UI\\font\\"
    local ntext2 = path .. ("text2_%s.ttf"):format(lang[2])
    SetResourceStatus("global")
    LoadTTF("pretty_title", ntext2, 32)
    LoadTTF("pretty", ntext2, 80)
    SetResourceStatus("stage")--]]--I dont know why this didnt work
    for p in pairs(_editor_class) do
        _editor_class[p] = nil
    end
    for p in pairs(_editor_boss) do
        _editor_boss[p] = nil
    end
    for p in pairs(_sc_list) do
        _sc_list[p] = nil
    end
    DoFile("mod\\active\\init.lua")
    DoFile("mod\\addition\\init.lua")
    if not init then
        stg_levelUPlib.DefineAddition()
        activeItem_lib.DefineActive()
    end
    --DoFile("THlib\\ext\\ext_pause_menu.lua")
    DoFile("THlib\\player\\player.lua")
    DoFile("THlib\\background\\background.lua")
    DoFile("mod\\_editor_output.lua")
    DoFile("THlib\\UI\\menu.lua")
    DoFile("THlib\\UI\\UI.lua")
    DoFile("THlib\\enemy\\boss.lua")
    DoFile("THlib\\lib\\Lmission.lua")
    if not init then
        mission_lib.InitMission()
    end
    InitAllClass()
    checkJargonCommand()
    --ext.CheckProblem()

end

---或许还可以返回成一个表？？
---极简化翻译函数
function i18n(module, str)
    return languageCache[currentLanguage][module][str]
end

local jargon = {
    { "/wxsys", "天气系统", " Wx system" },
    { "/expp", "经验点", "EXP Point" },
    { "/expR", "经验获取倍率", "EXP Rate" },
    { "/exp", "经验值", "EXP" },
    { "/bvR", "弹速倍率", "BulletVel Rate" },
    { "/bv", "弹速", "BulletVel" },
    { "/brR", "射程倍率", "Range Rate" },
    { "/br", "射程", "Range" },
    { "/ssR", "射速倍率", "ShotSPD Rate" },
    { "/ss", "射速", "ShotSPD" },
    { "/atkR", "攻击力倍率", "ATK Rate" },
    { "/atk", "攻击力", "ATK" },
    { "/maxhp", "生命上限", "MaxHP" },
    { "/hp", "生命值", "HP" },
    { "/hspd", "高速移速", "HighSPD" },
    { "/lspd", "低速移速", "LowSPD" },
    { "/spdR", "移速倍率", "SPD Rate" },
    { "/spd", "移速", "SPD" },
    { "/aimplayer", "自机狙", "Aimed" },
    { "/plopca", "自机不透明度", "Player Opacity" },
    { "/player", "自机", "Player" },
    { "/minion", "子机", "Minion" },
    { "/pbullethitb", "主炮大小", "Shot's Size" },
    { "/pbullet", "主炮", "Shot" },
    { "/itcl", "道具回收线", "Item Collect Line" },
    { "/spelle", "符卡能量", "SC Energy" },
    { "/spellme", "符卡最大能量", "SC MaxEnergy" },
    { "/spellcR", "符卡充能效率", "SC Charge Rate" },
    { "/spellstk", "符卡槽", "SC Stack" },
    { "/hitbR", "判定点倍率", "Hitbox Rate" },
    { "/hitb", "判定大小", "Hitbox" },
    { "/chaos", "混沌值", "Chaos" },
    { "/inv", "无敌", "Invincibility" },
    { "/season1", "§p春§d", "§pSpring§d" },
    { "/season2", "§b夏§d", "§bSummer§d" },
    { "/season3", "§y秋§d", "§yAutumn§d" },
    { "/season4", "§c冬§d", "§cWinter§d" },
    { "/season5", "§r里§d", "§rDoyou§d" },
    { "/benefit", "§g裨益§d", "§gBenefit§d" },
    { "/trade", "§p交易§d", "§pTrade§d" },
    { "/infringe", "§r侵害§d", "§rInfringe§d" },
    { "/tempitem", "§y临时道具§d", "§yTemporary Item§d" },
    { "/item", "§y道具§d", "§yItem§d" },
    { "/activestk", "主动槽位", "Active Stack" },
    { "/active", "§c主动道具§d", "§cActive Item§d" },
    { "/challmode", "挑战模式", "Challenge Mode" },
    { "/once", "§r一次性§d", "§rDISPOSABLE§d" },
    { "/holduse", "§g可长按使用§d", "§gHold to Use§d" }
}

local weather_state = { "§y", "§b", "§r" }
local tool_state = { "§-", "§g", "§c", "§p", "§y" }
---@param str string
---替换文本中的命令
function ReplaceTextWithCommand(str)
    if not str then
        return ""
    end
    str = str:gsub("/t(%d+)sdes", function(id)
        id = tonumber(id)
        local t = stg_levelUPlib.AdditionTotalList[id]
        if t then
            return t.describe
        else
            return ("/t%dsdes"):format(id)
        end
    end)     :gsub("/t(%d+)collabd", function(id)
        id = tonumber(id)
        local t = stg_levelUPlib.AdditionTotalList[id]
        if t then
            return t.collab_des
        else
            return ("/t%dcollabd"):format(id)
        end
    end)     :gsub("/t(%d+)detail", function(id)
        id = tonumber(id)
        local t = stg_levelUPlib.AdditionTotalList[id]
        if t then
            return t.detail
        else
            return ("/t%ddetail"):format(id)
        end
    end)     :gsub("/t(%d+)", function(id)
        id = tonumber(id)
        local t = stg_levelUPlib.AdditionTotalList[id]
        if t then
            return ("%s%s§d"):format(tool_state[(t._quality or 0) + 1], t.title2)
        else
            return ("/t%d"):format(id)
        end
    end)     :gsub("/a(%d+)sdes", function(id)
        id = tonumber(id)
        local t = activeItem_lib.ActiveTotalList[id]
        if t then
            return t.describe
        else
            return ("/a%dsdes"):format(id)
        end
    end)     :gsub("/a(%d+)collabd", function(id)
        id = tonumber(id)
        local t = activeItem_lib.ActiveTotalList[id]
        if t then
            return t.collab_des
        else
            return ("/a%dcollabd"):format(id)
        end
    end)     :gsub("/a(%d+)detail", function(id)
        id = tonumber(id)
        local t = activeItem_lib.ActiveTotalList[id]
        if t then
            return t.detail
        else
            return ("/a%ddetail"):format(id)
        end
    end)     :gsub("/a(%d+)", function(id)
        id = tonumber(id)
        local t = activeItem_lib.ActiveTotalList[id]
        if t then
            return ("%s%s§d"):format(tool_state[t.quality + 1], t.title2)
        else
            return ("/a%d"):format(id)
        end
    end)     :gsub("/w(%d+)", function(id)
        id = tonumber(id)
        local w = weather_lib.weather[id]
        if w then
            return ("%s%s§d"):format(weather_state[w.state], w.name)
        else
            return ("/w%d"):format(id)
        end
    end)   :gsub("/chall(%d+)", function(id)
        id = tonumber(id)
        local c = challenge_lib.class[id]
        if c then
            return c.title
        else
            return ("/chall%d"):format(id)
        end
    end)     :gsub("/scenep(%d+)s(%d+)", function(id, id2)
        id = tonumber(id)
        id2 = tonumber(id2)
        local w = SceneClass[id].events[id2]
        return ("§o\"%s\"§d"):format(w.title)
    end)     :gsub("/scenep(%d+)", function(id)
        id = tonumber(id)
        local w = SceneClass[id]
        if w then
            return ("§c%s§d"):format(w.title2)
        else
            return ("/scenep%d"):format(id)
        end
    end)     :gsub("/boss(%a+)", function(name)
        return ("§y%s§d"):format(i18n("bossname", name))
    end)     :gsub("/player(%a+)", function(name)
        return player_list_by_name[name].display_name
    end)     :gsub("/tg(%a+)", function(name)
        return ("§p\"%s\"§d"):format(stg_levelUPlib.tagslist[name]:gsub("§.", ""))
    end)     :gsub("/passtime(%d+)", function(times)
        if setting.language == 1 then
            return ("通关游戏§y%s§d次"):format(times)
        else
            return ("Pass Game §y%s§d time%s"):format(times, times == "1" and "" or "s")
        end
    end)
    for _, v in ipairs(jargon) do
        str = str:gsub(v[1], v[currentLanguage + 1])
    end
    return str
end

function checkJargonCommand()
    local rwc = ReplaceTextWithCommand
    for _, p in ipairs(stg_levelUPlib.AdditionTotalList) do
        p.describe = rwc(p.describe)
        p.detail = rwc(p.detail)
        p.repeat_des = rwc(p.repeat_des)
        p.collab_des = rwc(p.collab_des)
        p.unlock_des = rwc(p.unlock_des)
        p.cond_des = rwc(p.cond_des)
    end
    for _, p in ipairs(activeItem_lib.ActiveTotalList) do
        p.describe = rwc(p.describe)
        p.detail = rwc(p.detail)
        p.collab_des = rwc(p.collab_des)
        p.unlock_des = rwc(p.unlock_des)
        p.cond_des = rwc(p.cond_des)
    end
    for _, w in ipairs(weather_lib.weather) do
        w.describe = rwc(w.describe)
        w.special_des = rwc(w.special_des)
    end
end