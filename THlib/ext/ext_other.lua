--local ext = ext
local PostEffect = PostEffect
local PopRenderTarget = PopRenderTarget
local PushRenderTarget = PushRenderTarget
local SetImageState = SetImageState
local Render = Render
local Color = Color
local RenderClear = RenderClear
local SetFontState = SetFontState
local RenderText = RenderText
local lstg = lstg
local Forbid = clamp
local RenderRect = RenderRect

--游玩时长相关

function ext.InputDuration()
    --frame,second,minute,hour,day
    local time = scoredata["Duration"]
    time[1] = time[1] + 1
    for i = 1, 3 do
        if time[i] >= 60 then
            time[i] = time[i] - 60
            time[i + 1] = time[i + 1] + 1
        end
    end
    if time[4] >= 24 then
        time[4] = time[4] - 24
        time[5] = time[5] + 1
    end
    if not scoredata.Achievement["26"] then
        if time[3] >= 30 or time[4] > 0 or time[5] > 0 then
            ext.achievement:get(3)
        end--30分钟，一个成就
        if time[4] >= 1 or time[5] > 0 then
            ext.achievement:get(4)
        end--1小时，一个成就
        if time[4] >= 12 or time[5] > 0 then
            ext.achievement:get(5)
        end--12小时，一个成就
        if time[5] >= 1 then
            ext.achievement:get(6)
        end--1天，一个成就
        if time[5] >= 1 and time[4] >= 7 and time[3] >= 48 and time[2] >= 33 then
            ext.achievement:get(25)
        end--114513
        if time[5] >= 1 and time[4] >= 7 and time[3] >= 48 and time[2] >= 34 then
            ext.achievement:get(116)
        end--114514
        if time[5] >= 1 and time[4] >= 7 and time[3] >= 48 and time[2] >= 35 then
            ext.achievement:get(26)
        end--114515
    end
end
do
    _G["FAST_DOFRAME_TIME"] = 120
    local t, err = io.open("testing.lua", "r")
    local now
    if not err then
        now = #t:read("*a") + 1
        t:close()
        t = nil
    end
    ---开发者模式
    function ext.Debugging()
        --DEBUGGER
        if DEBUG then
            ext.FullSaveCode()--作弊码只能在开发者模式使用
            ext.CheckCheatCode()
            local key, KEY = GetLastKey(), KEY
            if key == KEY.BACKSPACE then
                object.EnemyNontjtDo(function(u)
                    if BoxCheck(u, lstg.world.l, lstg.world.r, lstg.world.b, lstg.world.t) and u.is_combat ~= false and not u.is_exploding then
                        object.Kill(u)
                    end
                end)
            end--快速击破boss
            if key == KEY.ADD then
                --for _ = 1, _G["FAST_DOFRAME_TIME"] do
                ext.FrameCounter = ext.FrameCounter + _G["FAST_DOFRAME_TIME"]
                --end
            end--快进
            if lstg.var.chaos then
                if key == KEY.NUMPAD1 then
                    --for _ = 1, _G["FAST_DOFRAME_TIME"] do
                    lstg.var.chaos = max(lstg.var.chaos - 7, 0)
                    --end
                end
                if key == KEY.NUMPAD3 then
                    --for _ = 1, _G["FAST_DOFRAME_TIME"] do
                    lstg.var.chaos = lstg.var.chaos + 7
                    --end
                end
            end
            if key == KEY.G then
                ResetLanguageCache()
                ext.achievement.getcount = 0
                loadLanguageModule("ext", "THlib\\ext\\lang")
                loadLanguageModule("lockfunc", "THlib\\lib\\lang")
                for p in pairs(_editor_class) do
                    _editor_class[p] = nil
                end
                for p in pairs(_editor_boss) do
                    _editor_boss[p] = nil
                end
                for p in pairs(_sc_list) do
                    _sc_list[p] = nil
                end
                DoFile("THlib\\ext\\ext_level_up.lua")
                DoFile("THlib\\player\\player.lua")
                DoFile("THlib\\background\\background.lua")
                DoFile("mod\\_editor_output.lua")
                DoFile("THlib\\UI\\menu.lua")
                DoFile("THlib\\UI\\UI.lua")
                DoFile("THlib\\enemy\\boss.lua")
                DoFile("THlib\\lib\\Lmission.lua")
                mission_lib.InitMission()

                InitAllClass()
                stage.Restart()
                --ext.CheckProblem()

            end--快速加载
            if not err then
                do
                    local testing = io.open("testing.lua", "r")
                    local text = testing:read("*a")
                    if string.match(text, "\n", now) then
                        t = string.sub(text, now)
                        now = #text + 1
                        Print(t)
                        load(t)()
                    end
                    testing:close()
                end--控制台
            end
        end
    end

    ---打印一些东西，检测存在的问题
    function ext.CheckProblem()
        local addition = stg_levelUPlib.AdditionTotalList
        local strb = "潜在问题：%s"
        for i, p in pairs(addition) do
            if p.isTool then
                if p.cond_des ~= "无" and not p.condition then
                    Print(strb:format("道具有出现前提描述，但是没有前提函数："), p.id, p.title, p.cond_des)
                end
                if p.unlock_des ~= "无" and not p.is_locked then
                    Print(strb:format("道具有解锁方式描述，但是没有解锁flag："), p.id, p.title, p.unlock_des)
                end
                if p.subtitle == "todo" then
                    Print(strb:format("道具副标题未填写"), p.id, p.title, p.subtitle)
                end
            end
            if p.id ~= i then
                Print(strb:format("加成id位与排序对不上"))
            end
        end
    end
end

-- CheatCode
local CheatCode1 = { "W", "O", "S", "H", "I", "S", "H", "A", "B", "I" }
local CheatCodePos1 = 1

local keyName = KeyCodeToName()
function ext.FullSaveCode()
    local key, KEY = GetLastKey(), KEY
    if key ~= KEY.NULL then
        if CheatCode1[CheatCodePos1] == keyName[key] then
            if CheatCodePos1 == #CheatCode1 then
                CheatCodePos1 = 1
                ---@param p addition_unit
                for _, p in pairs(stg_levelUPlib.AdditionTotalList) do
                    local id = p.id
                    if p.initialTake and p.isTool then
                        scoredata.initialAddition[id] = true
                        scoredata.NoticeinitialAddition[id] = true
                    end
                    scoredata.BookAddition[id] = true
                    scoredata.UnlockAddition[id] = true
                end
                for _, p in pairs(activeItem_lib.ActiveTotalList) do
                    local id = p.id
                    scoredata.BookActive[id] = true
                    scoredata.UnlockActive[id] = true
                end
                scoredata.FirstWeather = true--第一次遇到天气
                scoredata.First5Season = true
                for _, p in pairs(weather_lib.weather) do
                    local id = p.id
                    scoredata.Weather[id] = true
                end
                for i, s in ipairs(SceneClass) do
                    for j = 1, 3 do
                        stagedata.stagePass[i][j] = stagedata.stagePass[i][j] + 1
                    end
                    for j in ipairs(s.events) do
                        stagedata.BookWave[i][j] = true
                    end
                end
                scoredata.unlockInitialPos = { true, true, true, true, true }
                for _, p in ipairs(player_list) do
                    local data = playerdata[p.name]
                    data.unlock_c = 3
                    for i = 1, 3 do
                        data.choose_skill[i] = true
                    end
                end
            else
                CheatCodePos1 = CheatCodePos1 + 1
            end
        else
            CheatCodePos1 = 1
        end
    end
end

local keyToNumber = {
    ["0"] = 0,
    ["1"] = 1,
    ["2"] = 2,
    ["3"] = 3,
    ["4"] = 4,
    ["5"] = 5,
    ["6"] = 6,
    ["7"] = 7,
    ["8"] = 8,
    ["9"] = 9,
    ["NUMPAD0"] = 0,
    ["NUMPAD1"] = 1,
    ["NUMPAD2"] = 2,
    ["NUMPAD3"] = 3,
    ["NUMPAD4"] = 4,
    ["NUMPAD5"] = 5,
    ["NUMPAD6"] = 6,
    ["NUMPAD7"] = 7,
    ["NUMPAD8"] = 8,
    ["NUMPAD9"] = 9,
}

local function IsEnter(key)
    return key == KEY.ENTER or key == KEY.NUMPADENTER
end
local ToolSet = function(ID)
    if ID > 0 and not stage.current_stage.is_menu then
        local p = stg_levelUPlib.AdditionTotalList[ID]
        if p then
            p:Set()
        end
    end
end
local WeaSet = function(ID)
    if ID > 0 and not stage.current_stage.is_menu then
        if weather_lib.weather[ID] then
            lstg.weather.next_weather = ID
        end
    end
end
local ActiveSet = function(ID)
    if ID > 0 and not stage.current_stage.is_menu then
        local p = activeItem_lib.ActiveTotalList[ID]
        if p then
            p:Set()
        end
    end
end

local GetID = 0
local recordPos = { 0, 0, 0 }
local function CheckCode(key, recpos, code, func)
    if recordPos[recpos] == #code then
        local num = keyToNumber[keyName[key]]
        if num then
            GetID = GetID * 10 + num
        elseif keyName[key] == code[1] then
            func(GetID)
            GetID = 0
            recordPos[recpos] = 1
        else
            func(GetID)
            GetID = 0
            recordPos[recpos] = 0
        end
    else
        if code[recordPos[recpos] + 1] == keyName[key] then
            recordPos[recpos] = recordPos[recpos] + 1
            if recordPos[recpos] == #code then
                GetID = 0
            end
        else
            recordPos[recpos] = 0

        end
    end
end
local ToolCode = { "T", }
local WeaCode = { "W", }
local ActiveCode = { "A", }

function ext.CheckCheatCode()
    local key, KEY = GetLastKey(), KEY
    if key ~= KEY.NULL then
        CheckCode(key, 1, ToolCode, ToolSet)
        CheckCode(key, 2, WeaCode, WeaSet)
        CheckCode(key, 3, ActiveCode, ActiveSet)
    end
end

---保存游戏图像
local path = GetDataPath()
ext.SaveScreenPath = path .. "/wave_pic"
ext.saveScreenCache = {}
ext.saveScreenFlag = false
ext.saveScreenToFile = nil
function ext.saveScreenBefore()
    if ext.saveScreenToFile then
        ext.saveScreenFlag = ext.saveScreenToFile
        ext.saveScreenToFile = nil
    end
    if ext.saveScreenFlag then
        SetResourceStatus("global")
        CreateRenderTarget(ext.saveScreenFlag)
        SetResourceStatus("stage")
        PushRenderTarget(ext.saveScreenFlag)
        RenderClear(Color(0xFF000000))
    end
end
function ext.saveScreenAfter()
    if ext.saveScreenFlag then
        PopRenderTarget(ext.saveScreenFlag)
        PostEffect("fx:SaveScreen", ext.saveScreenFlag, 6, "", {
            { 1.0, 0.0, 0.0, 0.0 }, -- alpha, 未使用, 未使用, 未使用
        }, {})
        if #ext.saveScreenCache > 0 then
            if ext.saveScreenCache[#ext.saveScreenCache] == ext.saveScreenFlag then
                table.remove(ext.saveScreenCache)
            end
        end
        table.insert(ext.saveScreenCache, ext.saveScreenFlag)
        ext.saveScreenFlag = nil

    end
end

function ext.RenderFPS()
    local font = "Score"

    SetFontState(font, "", 255, 250, 128, 114)
    if lstg.var.is_cheatMode then
        RenderText("Score", "Cheating...",
                958, 19, 0.25, "right", "bottom")
    end
    SetFontState(font, "", 255, 255, 255, 255)
    RenderText(font, ui.version, 958, 10, 0.25, "right", "bottom")
    local fps = GetFPS() * ext.GetFakeFPS()
    if fps >= 59 then
        SetFontState(font, "", 255, 189, 252, 201)
    elseif fps > 55 then
        SetFontState(font, "", 255, 255, 227, 132)
    else
        SetFontState(font, "", 255, 250, 128, 114)
    end
    RenderText(font, string.format("%.1ffps", fps), 958, 1, 0.25, "right", "bottom")
end

function ext.StageIsMenu()
    local stage = stage
    if stage.current_stage then
        if stage.current_stage.is_menu then
            return true
        end
    else
        return true
    end
    return false
end

function ext.GetFakeFPS()
    local v = lstg.var
    local s = stage.current_stage
    if ext.StageIsMenu() or (s and s.is_summary) or v.lost or (not ext.level_menu:IsKilled()) then
        return 1
    else
        local cyfps = (v.CYFPS or 60) / 60
        local sakuyaFPS = (v.sakuyaFPS or 60) / 60
        return cyfps * sakuyaFPS
    end
end

CreateRenderTarget("mask_fader")
---@class mask_fader
mask_fader = {
    name = "mask_fader",
    time = 0,
    maxtime = 30,
    color = Color(255, 255, 255, 255),
    blend = "",
    tox = function(t, x)
        return t * x
    end,
    toy = function(t, y)
        return t * (540 - y)
    end,
}
function mask_fader:BeforeRender()
    if self.time > 0 then
        PushRenderTarget(self.name)
        RenderClear(Color(255, 0, 0, 0))
    end
end
function mask_fader:frame()
    self.time = self.time - 1
end
function mask_fader:AfterRender()
    if self.time > 0 then
        PopRenderTarget(self.name)
        SetViewMode("ui")
        local s = min(1, self.time / (self.maxtime - 2))
        local height = s
        if self.mode == "open" then
            height = 1 - s
        elseif self.mode == "last" then
            height = 0
        end
        AE.FadeAnimation(self.name, height, 0.1, 0, 0, 0, 0)
        SetViewMode("ui")
        --[[
        local index1, index2
        local s = min(1, self.time / (self.maxtime - 5))
        if self.mode == "open" then
            s = task.SetMode[2](s)
            index1 = s
            index2 = 1 - s * 0.5
        elseif self.mode == "last" then
            index1 = 1
        else
            s = task.SetMode[1](s)
            index1 = 1 - s
            index2 = 0.5 - s * 0.5
        end
        SetImageState("white", "", 255 * index1, 0, 0, 0)
        RenderRect("white", 0, 960, 0, 540)--]]
    end
end
function mask_fader:Do(mode, time)
    self.time = time or 15
    self.time = self.time + 1
    self.maxtime = time or 15
    self.mode = mode

end

LoadImageFromFile("failed_show", "assets\\ext\\failed_show.png")

---@class Failed_Show
Failed_Show = {
    alpha = 0,
    timer = 0,
    x = 480, y = 270,
    tex = "Final_SHOW_tex"
}
CreateRenderTarget(Failed_Show.tex)
function Failed_Show:Do(time, text)
    self.timer = 0
    self.alpha = 0
    self.text = text or ""
    task.New(self, function()
        for i = 1, time do
            i = task.SetMode[2](i / time)
            self.alpha = i
            task.Wait()
        end
        for i = 1, 30 do
            i = task.SetMode[2](i / 30)
            self.alpha = 1 - i
            task.Wait()
        end
    end)

end
function Failed_Show:frame()
    task.Do(self)
    self.timer = self.timer + 1
end
function Failed_Show:BeforeRender()
    if self.alpha > 0 then
        PushRenderTarget(self.tex)
        RenderClear(Color(0, 0, 0, 0))
    end
end
function Failed_Show:AfterRender()
    local A = self.alpha
    if A > 0 then
        SetViewMode("ui")
        PopRenderTarget(self.tex)
        AE.PostEffectGrayColor(self.tex, A)
        SetImageState("white", "", A * 120, 0, 0, 0)
        RenderRect("white", 0, 960, 0, 540)
        SetImageState("failed_show", "mul+add", A * 255, 255, 255, 255)
        Render("failed_show", 480, 270, 0, 0.5)
        ui:RenderText("title", self.text, 480, 180, 1, Color(A * 200, 255, 255, 255), "centerpoint")
    end
end

---@class ext.OldScreenEff
local OldScreenEff = {
    name = "OldScreenEff",
    col00000000 = Color(0, 0, 0, 0),
    colFFFFFFF = Color(255, 255, 255, 255),
    colsRGB = { Color(255, 255, 0, 0), Color(255, 0, 255, 0), Color(255, 0, 0, 255) },
    cut = 121,
    index = 100,
    flag = false, ---开启
    offcache = {},
    departrgbcache = {},
    vertical = false,
}
CreateRenderTarget(OldScreenEff.name)
function OldScreenEff:BeforeRender()
    if self.flag then
        PushRenderTarget(self.name)
        RenderClear(self.col00000000)
    end
end
---一整个屏幕古老电视机效果
---@param index number@数字越小效果越强
---@param cut number@纵向切割数
---@param departrgb boolean@是否分离rgb
---@param vertical boolean@垂直分割（默认为水平分割）
function OldScreenEff:Open(index, cut, departrgb, vertical)
    self.flag = true
    self.index = index or 100
    self.cut = cut or 121
    for i in ipairs(self.offcache) do
        self.offcache[i] = nil
    end
    for i in ipairs(self.departrgbcache) do
        self.departrgbcache[i] = nil
    end
    for _ = 1, self.cut do
        table.insert(self.offcache, (ran:Int(0, self.index) == 0) and ran:Sign() * ran:Float(100 - (50 - self.index / 10), 150) or 0)
    end
    for _ = 1, self.cut do
        table.insert(self.departrgbcache, departrgb and ran:Float(-10, 10) or 0)
    end
    self.vertical = vertical or false
end
function OldScreenEff:AfterRender()
    if self.flag then
        SetViewMode("ui")
        PopRenderTarget(self.name)
        local color = self.colFFFFFFF
        local scr = screen
        local sw, sh = scr.width, scr.height
        local uvx1, uvy1 = UIToScreen(0, 0)
        local uvx2, uvy2 = UIToScreen(sw, sh)
        if self.vertical then
            local w = sw / self.cut
            local k = (self.cut - 1) / 2
            for x = -k, k do
                local floatx = self.offcache[x + k + 1]
                local tx = (x * w + floatx + sw / 2) % sw - sw / 2
                local _x1, _ = UIToScreen(sw / 2 - w / 2 + tx, 0)
                local _x2, _ = UIToScreen(sw / 2 + w / 2 + tx, 0)
                if self.departrgbcache[x + k + 1] ~= 0 then
                    local departy = self.departrgbcache[x + k + 1]
                    for y = -1, 1 do
                        local _color = self.colsRGB[y + 2]
                        RenderTexture(self.name, "mul+add",
                                { sw / 2 + x * w - w / 2, sh + y * departy, 0.5, _x1, uvy2, _color },
                                { sw / 2 + x * w + w / 2, sh + y * departy, 0.5, _x2, uvy2, _color },
                                { sw / 2 + x * w + w / 2, 0 + y * departy, 0.5, _x2, uvy1, _color },
                                { sw / 2 + x * w - w / 2, 0 + y * departy, 0.5, _x1, uvy1, _color })
                    end
                else
                    RenderTexture(self.name, "",
                            { sw / 2 + x * w - w / 2, sh, 0.5, _x1, uvy2, color },
                            { sw / 2 + x * w + w / 2, sh, 0.5, _x2, uvy2, color },
                            { sw / 2 + x * w + w / 2, 0, 0.5, _x2, uvy1, color },
                            { sw / 2 + x * w - w / 2, 0, 0.5, _x1, uvy1, color })
                end
            end
            self.vertical = false
        else
            local h = sh / self.cut
            local k = (self.cut - 1) / 2
            for y = -k, k do
                local floaty = self.offcache[y + k + 1]
                local ty = (y * h + floaty + sh / 2) % sh - sh / 2
                local _, _y1 = UIToScreen(0, sh / 2 + h / 2 + ty)
                local _, _y2 = UIToScreen(0, sh / 2 - h / 2 + ty)
                if self.departrgbcache[y + k + 1] ~= 0 then
                    local departx = self.departrgbcache[y + k + 1]
                    for x = -1, 1 do
                        local _color = self.colsRGB[x + 2]
                        RenderTexture(self.name, "mul+add",
                                { 0 + x * departx, sh / 2 + y * h + h / 2, 0.5, uvx1, _y1, _color },
                                { sw + x * departx, sh / 2 + y * h + h / 2, 0.5, uvx2, _y1, _color },
                                { sw + x * departx, sh / 2 + y * h - h / 2, 0.5, uvx2, _y2, _color },
                                { 0 + x * departx, sh / 2 + y * h - h / 2, 0.5, uvx1, _y2, _color })
                    end
                else
                    RenderTexture(self.name, "",
                            { 0, sh / 2 + y * h + h / 2, 0.5, uvx1, _y1, color },
                            { sw, sh / 2 + y * h + h / 2, 0.5, uvx2, _y1, color },
                            { sw, sh / 2 + y * h - h / 2, 0.5, uvx2, _y2, color },
                            { 0, sh / 2 + y * h - h / 2, 0.5, uvx1, _y2, color })

                end
            end
        end
        self.flag = false--仅当前帧有效
    end
end
function OldScreenEff:Reset()
    self.flag = false
end
ext.OldScreenEff = OldScreenEff

---@class ext.OtherScreenEff
local OtherScreenEFF = {
    col00000000 = Color(0, 0, 0, 0),
    colFFFFFFF = Color(255, 255, 255, 255),
    flag = false, ---开启
    Event = {},
    rtcount = {},
    delayEvent = {

    }
}

---自定义全屏效果
---@param level number@优先级，数字越大优先级越高
---@param RenderOrigin boolean@是否渲染原有画面
---@param texname string@纹理名称
---@param noCapture boolean@不捕捉画面覆盖纹理
function OtherScreenEFF:Open(level, func, RenderOrigin, texname, noCapture)
    self.flag = true
    local name = texname or ("OtherScreenEff:level%d"):format(level)
    for _, e in ipairs(self.Event) do
        if e.level == level then
            e.func = func
            e.RenderOrigin = RenderOrigin
            e.Capture = not noCapture
            e.name = name
            return name
        end
    end--如果有同样的level，则更新func
    table.insert(self.Event, {
        func = func,
        level = level,
        RenderOrigin = RenderOrigin,
        Capture = not noCapture,
        name = name,
    })
    table.sort(self.Event, function(a, b)
        return a.level > b.level
    end)
    return name
end
---获取当前画面存于一个纹理
---@param texname string
function OtherScreenEFF:GetCurrentTex(texname)
    self.flag = true
    local name = texname or "OtherScreenEff:level66666"
    -- CreateRenderTarget(name)
    table.insert(self.Event, {
        func = function()
        end,
        level = 66666,
        RenderOrigin = true,
        Capture = true,
        name = name,
    })
    table.sort(self.Event, function(a, b)
        return a.level > b.level
    end)
    return name
end
function OtherScreenEFF:ResetUV()
    local scr = screen
    local uv1, uv2, uv3, uv4 = { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }
    local w, h = scr.width, scr.height
    uv1[6], uv2[6], uv3[6], uv4[6] = self.colFFFFFFF, self.colFFFFFFF, self.colFFFFFFF, self.colFFFFFFF
    uv1[4], uv1[5] = UIToScreen(0, h)
    uv2[4], uv2[5] = UIToScreen(w, h)
    uv3[4], uv3[5] = UIToScreen(w, 0)
    uv4[4], uv4[5] = UIToScreen(0, 0)
    uv1[1], uv1[2] = 0, h
    uv2[1], uv2[2] = w, h
    uv3[1], uv3[2] = w, 0
    uv4[1], uv4[2] = 0, 0
    self.uv1, self.uv2, self.uv3, self.uv4 = uv1, uv2, uv3, uv4

end
function OtherScreenEFF:GetScreenUV(copy)
    if not (self.uv1 and self.uv2 and self.uv3 and self.uv4) then
        self:ResetUV()
    end
    if copy then
        return sp:CopyTable(self.uv1), sp:CopyTable(self.uv2), sp:CopyTable(self.uv3), sp:CopyTable(self.uv4)
    else
        return self.uv1, self.uv2, self.uv3, self.uv4
    end
end
function OtherScreenEFF:CreateRenderTarget(name)
    if not self.rtcount[name] then
        self.rtcount[name] = 1--初始时多计一次
        CreateRenderTarget(name)
    end
    self.rtcount[name] = self.rtcount[name] + 1

end
---下一帧再移除纹理，避免冗余处理
function OtherScreenEFF:RemoveRenderTarget(name)
    if self.rtcount[name] then
        self.rtcount[name] = self.rtcount[name] - 1
        if self.rtcount[name] <= 0 then
            local resType = 1
            local respool = lstg.CheckRes(resType, name)
            if respool then
                lstg.RemoveResource(respool, resType, name)
            end
            self.rtcount[name] = nil
        end
    end
end
function OtherScreenEFF:BeforeRender()
    if self.flag then
        local e
        for i = #self.Event, 1, -1 do
            e = self.Event[i]
            if e.Capture then
                self:CreateRenderTarget(e.name)
                PushRenderTarget(e.name)
                RenderClear(self.col00000000)
            end
        end
    end
end
function OtherScreenEFF:AfterRender()
    if self.flag then
        SetViewMode("ui")
        for _, e in ipairs(self.Event) do
            if e.Capture then
                PopRenderTarget(e.name)
            end
            if e.RenderOrigin then
                RenderTexture(e.name, "", self:GetScreenUV())
            end
            e.func(e)
        end
    end
    for n in pairs(self.rtcount) do
        self:RemoveRenderTarget(n)
    end
end
function OtherScreenEFF:Reset()
    self.flag = false
    for k in ipairs(self.Event) do
        self.Event[k] = nil
    end

end
ext.OtherScreenEff = OtherScreenEFF

---获取分离rgb的执行函数，要配合ext.OtherScreenEff
---@return fun(index:number, cx:number, cy:number):fun(self:ext.OtherScreenEff)
local GetDepartRGBFunc = function(col)
    local scr = screen
    local uv1, uv2, uv3, uv4 = { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }
    local w, h = scr.width, scr.height
    uv1[4], uv1[5] = UIToScreen(0, h)
    uv2[4], uv2[5] = UIToScreen(w, h)
    uv3[4], uv3[5] = UIToScreen(w, 0)
    uv4[4], uv4[5] = UIToScreen(0, 0)
    col = col or { { 255, 0, 0 }, { 0, 255, 0 }, { 0, 0, 255 } }
    return function(index, cx, cy)
        cx = cx or w / 2
        cy = cy or h / 2
        local w1, w2 = cx, w - cx
        local h1, h2 = cy, h - cy
        ---@param self ext.OtherScreenEff
        return function(self)
            SetImageState("white", "", 255, 0, 0, 0)
            RenderRect("white", 0, w, 0, h)
            for z = -1, 1 do
                local scale = 1 + index / 333 * z
                local color = Color(255, col[z + 2][1], col[z + 2][2], col[z + 2][3])
                uv1[6], uv2[6], uv3[6], uv4[6] = color, color, color, color
                uv1[1], uv1[2] = cx - w1 * scale + 0 * index, cy + h2 * scale
                uv2[1], uv2[2] = cx + w2 * scale + 0 * index, cy + h2 * scale
                uv3[1], uv3[2] = cx + w2 * scale + 0 * index, cy - h1 * scale
                uv4[1], uv4[2] = cx - w1 * scale + 0 * index, cy - h1 * scale
                RenderTexture(self.name_fake or self.name, "mul+add", uv1, uv2, uv3, uv4)
            end
        end
    end
end
ext.GetDepartRGBFunc = GetDepartRGBFunc


--音乐相关
local CheckRes = CheckRes
local LoadMusic = LoadMusic
local RemoveResource = RemoveResource

local SetBGMSpeed = SetBGMSpeed
local int = int
local GetBGMSpeed = GetBGMSpeed
local pairs = pairs

local play = PlayMusic
local stop = StopMusic
local get = GetMusicState
local set = SetBGMVolume
function LoadMusicInList(bgm)
    if not CheckRes("bgm", bgm) then
        local musicList = musicList
        lstg.SetResourceStatus("global")
        LoadMusic(bgm, musicList[bgm][6], musicList[bgm][1], musicList[bgm][2])
        lstg.SetResourceStatus("stage")
    end
end
local function LoadAndPlayMusic(bgm, v, start_time)
    LoadMusicInList(bgm)
    play(bgm, v, start_time)
end
local function StopAndRemoveMusic(bgm, noremove)
    if CheckRes("bgm", bgm) then
        stop(bgm)
    end
    if not noremove then
        RemoveResource("global", 4, bgm)

    end
end
function SetBGMVolume2(bgm, v)
    if not v then
        set(bgm)
    elseif bgm then
        if CheckRes("bgm", bgm) then
            set(bgm, v)
        end
    end
end
function GetMusicState2(bgm)
    if not CheckRes("bgm", bgm) then
        return false
    else
        return get(bgm)
    end
end

ext.PlayMusic = LoadAndPlayMusic
ext.StopMusic = StopAndRemoveMusic
ext.ResumeMusic = ResumeMusic
ext.PauseMusic = PauseMusic
ext.music = {}
function ext.SetBGMSpeed(bgm, speed)
    if GetMusicState2(bgm) == "playing" then
        SetBGMSpeed(bgm, speed)
        ext.music[bgm].speed = speed
    end
end
function PlayMusic2(bgm, v, start_time)
    local musicList = musicList
    start_time = start_time or 0
    start_time = start_time - int(start_time / musicList[bgm][1]) * musicList[bgm][2]
    ext.PlayMusic(bgm, v, start_time)
    local t = { faketimer = int(start_time * 60), timer = int(start_time * 60), paused = false, speed = 1, volume = v or 1 }
    t.once = true
    ext.music[bgm] = t
    return t
end
function StopMusic2(bgm)
    ext.StopMusic(bgm)
    ext.music[bgm] = nil
end
function ext.SetBGMVolume(bgm, v)
    if GetMusicState2(bgm) == "playing" then
        SetBGMVolume2(bgm, v)
        ext.music[bgm].volume = v
    end
end
function ResumeMusic2(bgm)
    ext.ResumeMusic(bgm)
    ext.music[bgm].paused = false
end
function PauseMusic2(bgm)
    ext.PauseMusic(bgm)
    ext.music[bgm].paused = true
end

function ext.DefaultMusic()
    for p in pairs(ext.music) do
        if GetBGMSpeed(p) ~= 1 then
            SetBGMSpeed(p, 1)
        end
        StopMusic2(p)
    end
end
function ext.MusicFrame(i)
    i = i or 1
    for bgm, m in pairs(ext.music) do
        if m.speed ~= i then
            ext.SetBGMSpeed(bgm, i)
        end
    end
end

