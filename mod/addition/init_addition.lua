local lib = stg_levelUPlib
local NewNomalUnit = lib.NewNomalUnit
local NewToolUnit = lib.NewToolUnit

local function DefineOther()
    local function _t1(str)
        return i18n("addition", "BIYI")[str] or ""
    end
    local function _t2(str)
        return i18n("addition", "JIAOYI")[str] or ""
    end
    local function _t3(str)
        return i18n("addition", "QINGHAI")[str] or ""
    end
    NewNomalUnit(1, 0, 1, _t1("name1"), function(d)
        local ss = player.shoot_set.range
        ss.factor = ss.factor + 0.15 * d
    end, _t1("des1"))
    NewNomalUnit(3, 0, 1, _t1("name3"), function(d)
        local p = player
        p.dmg_factor = p.dmg_factor + 0.1 * d
    end, _t1("des3"))
    NewNomalUnit(4, 0, 1, _t1("name4"), function(d)
        player_lib.AddMaxLife(5 * d)
    end, _t1("des4"))
    NewNomalUnit(8, 0, 1, _t1("name8"), function(d, flag, otherflag)
        if flag and not otherflag then
            local t = lib.GetAdditionList(1, function(p)
                return p.isTool and not lib.SearchToolTag(p, "debuff")
            end)[1]
            if t then
                t:Set()
                ext.popup_menu:FlyInOneTool(_t1("srb8"), 255, 227, 132, t.id, "bonus")
            end
        end
    end, _t1("des8"))
    NewNomalUnit(9, 0, 1, _t1("name9"), function(d)
        player_lib.AddChaos(-5 * d)
    end, _t1("des9"), function()
        return lstg.var.chaos > 0
    end)
    NewNomalUnit(10, 0, 1, _t1("name10"), function(d)
        player_lib.AddLife(10)
    end, _t1("des10"))
    NewNomalUnit(15, 0, 1, _t1("name15"), function(d)
        local var = lstg.var
        var.energy_efficiency = var.energy_efficiency + 0.07 * d
    end, _t1("des15"))
    NewNomalUnit(19, 0, 1, _t1("name19"), function(d)
        local var = lstg.var
        var.exp_factor = var.exp_factor + 0.1 * d
    end, _t1("des19"))
    NewNomalUnit(65, 0, 1, _t1("name65"), function(d)
        local ss = player.shoot_set.speed
        ss.factor = ss.factor + 0.04 * d
    end, _t1("des65"))

    NewNomalUnit(11, 0, 2, _t2("name11"), function(d)
        player_lib.AddMaxLife(-5 * d)
        local p = player
        p.dmg_factor = p.dmg_factor + 0.15 * d
    end, _t2("des11"))
    NewNomalUnit(12, 0, 2, _t2("name12"), function(d)
        player_lib.AddMaxLife(10 * d)
        player_lib.AddChaos(11 * d)
    end, _t2("des12"))
    NewNomalUnit(16, 0, 2, _t2("name16"), function(d, flag, otherflag)
        if flag and not otherflag then
            local list = {}
            for i, c in pairs(lstg.var.addition) do
                local l = lib.AdditionTotalList[i]
                if l.isTool and not l.temporary then
                    for _ = 1, c do
                        table.insert(list, i)
                    end
                end
            end
            if #list > 0 then
                local lost = list[ran:Int(1, #list)]
                lib.AdditionTotalList[lost]:Remove()
                ext.popup_menu:FlyInOneTool(_t2("scb16_1"), 250, 128, 114, lost, "invalid")
                local t = lib.GetAdditionList(1, function(p)
                    return p.isTool
                end)[1]
                if t then
                    t:Set()
                    ext.popup_menu:FlyInOneTool(_t2("scb16_2"), 255, 227, 132, t.id, "bonus")
                end
            end


        end
    end, _t2("des16"))
    NewNomalUnit(33, 0, 2, _t2("name33"), function(d)
        local p = player
        p.hspeed_factor = p.hspeed_factor + 0.15 * d
        p.lspeed_factor = p.lspeed_factor + 0.15 * d
        p.dmg_factor = p.dmg_factor - 0.12 * d
    end, _t2("des33"))

    NewNomalUnit(66, 0, 2, _t2("name66"), function(d)
        local ss = player.shoot_set.speed
        ss.factor = ss.factor + 0.07 * d
        player_lib.AddChaos(9 * d)
    end, _t2("des66"))

    NewNomalUnit(13, 0, 3, _t3("name13"), function(d)
        player_lib.AddChaos(25 * d)
    end, _t3("des13"))
    NewNomalUnit(14, 0, 3, _t3("name14"), function(d)
        player_lib.AddMaxLife(-7 * d)
    end, _t3("des14"))
    NewNomalUnit(31, 0, 3, _t3("name31"), function(d)
        player.hspeed_factor = player.hspeed_factor - 0.2 * d
        player.lspeed_factor = player.lspeed_factor - 0.2 * d
    end, _t3("des31"))
    NewNomalUnit(32, 0, 3, _t3("name32"), function(d)
        local p = player
        p.dmg_factor = max(0, p.dmg_factor - 0.25 * d)
    end, _t3("des32"))
    NewNomalUnit(34, 0, 3, _t3("name34"), function(d, flag, otherflag)
        if flag and not otherflag then
            local list = {}
            for i, c in pairs(lstg.var.addition) do
                local l = lib.AdditionTotalList[i]
                if l.isTool and not l.temporary then
                    for _ = 1, c do
                        table.insert(list, i)
                    end
                end
            end
            if #list > 0 then
                local lost = list[ran:Int(1, #list)]
                lib.AdditionTotalList[lost]:Remove()
                ext.popup_menu:FlyInOneTool(_t3("scb34"), 250, 128, 114, lost, "invalid")
            end
        end
    end, _t3("des34"))
    NewNomalUnit(67, 0, 3, _t3("name67"), function(d)
        local ss = player.shoot_set.speed
        ss.factor = ss.factor - 0.2 * d
    end, _t3("des67"))
    NewNomalUnit(68, 0, 3, _t3("name68"), function(d)
        local bv = player.shoot_set.bvelocity
        bv.factor = bv.factor - 0.20 * d
    end, _t3("des68"))
    NewNomalUnit(69, 0, 3, _t3("name69"), function(d)
        player_lib.AddPlayerCollisize(nil, 0.15 * d)
    end, _t3("des69"))
end

local function STT(tags)
    local t = {}
    for _, n in ipairs(tags) do
        for tagname, tn in pairs(lib.tagslist) do
            if n == tn then
                table.insert(t, ("tg.%s"):format(tagname))
            end
        end
    end
    if #t == 1 then
        return t[1]
    elseif #t == 0 then
        return "nil"
    else
        return ("{%s}"):format(table.concat(t, ", "))
    end
end
local function PrintOut()
    local file1 = io.open("User\\what2.lua", "wb")
    file1:write([[local t = stg_levelUPlib.tagslist
]])
    file1:write("\n")
    file1:write("return {\n")
    for k = 1, 5 do
        file1:write("{\n")
        for i, p in pairs(lib.AdditionTotalList) do
            if p.isTool then
                if k == p.quality + 1 then
                    if true then
                        file1:write(("[\"%s\"] = \"%s\",\n"):format(p.title2, p.title2))
                    else
                        file1:write(("[%d] = {\n"):format(i))
                        file1:write(("stitle = [[%s]],\n"):format(p.subtitle))
                        file1:write(("sdes = [[%s]],\n"):format(p.describe))
                        file1:write(("detail = [[%s]],\n"):format(p.detail))
                        file1:write(("repeatd = [[%s]],\n"):format(p.repeat_des))
                        file1:write(("tags = %s,\n"):format(STT(p.tags)))
                        file1:write(("collabd = [[%s]],\n"):format(p.collab_des))
                        file1:write(("unlockd = [[%s]],\n"):format(p.unlock_des))
                        file1:write(("condd = [[%s]],\n"):format(p.cond_des))
                        file1:write("},\n")
                    end
                end
            end
        end
        file1:write("},\n")
    end
    file1:write([[}]])
end
local function PrintOut2()
    local file1 = io.open("User\\what2_en.lua", "wb")
    file1:write([[local tg = stg_levelUPlib.tagslist
]])
    file1:write("\n")
    file1:write("return {\n")
    for k = 1, 5 do
        file1:write("{\n")
        for i, p in pairs(lib.AdditionTotalList) do
            if p.isTool then
                if k == p.quality + 1 then
                    if false then
                        file1:write(("[\"%s\"] = \"%s\",\n"):format(p.title2, p.title2))
                    else
                        file1:write(("[%d] = {\n"):format(i))
                        file1:write(("name = [[%s]],\n"):format(p.title2))
                        file1:write(("stitle = [[%s]],\n"):format(p.subtitle))
                        file1:write(("sdes = [[%s]],\n"):format(p.describe))
                        file1:write(("detail = [[%s]],\n"):format(p.detail))
                        file1:write(("repeatd = [[%s]],\n"):format(p.repeat_des))
                        file1:write(("collabd = [[%s]],\n"):format(p.collab_des))

                        file1:write(("unlockd = [[%s]],\n"):format(p.unlock_des))

                        file1:write(("condd = [[%s]],\n"):format(p.cond_des))
                        if false then
                            file1:write(("tags = %s,\n"):format(STT(p.tags)))
                            file1:write(("picID = %d,\n"):format(p.state))
                            file1:write(("repeatp = %d,\n"):format(p.repeat_power))
                            file1:write(("maxc = %d,\n"):format(p.maxcount))
                            file1:write(("initialTake = %s,\n"):format(p.initialTake and "true" or "false"))
                            file1:write(("event = %s,\n"):format(long[i].event))
                            file1:write(("condfunc = %s,\n"):format(long[i].cond or "nil"))
                        end
                        file1:write("},\n")
                    end
                end
            end
        end
        file1:write("},\n")
    end
    file1:write([[}]])
end

local function DefineTool()
    local addition_list = DoFile("mod\\addition\\addition_des_ch.lua")
    for i, v in ipairs(addition_list) do
        for j, w in pairs(v) do
            NewToolUnit(j, i - 1, w.repeatp, w.picID, w.event, w.maxc, w.tags, w.initialTake, w.unlockd and true, w.condfunc)
        end
    end
end

local function DefineAddition()
    lib.AdditionList = {}--当前的列表
    lib.ListByQual = { {}, {}, {}, {}, {} }
    lib.ListByTags = {}
    lib.ListByState = {}
    lib.AdditionTotalList = {}--总加成列表
    DefineOther()
    --lib.DefineBENEFIT()
    DefineTool()
    lib.SortToolUnits()
    for name, str in pairs(lib.tagslist) do
        lib.ListByTags[name] = {}
        ---@param p addition_unit
        for _, p in pairs(lib.AdditionTotalList) do
            if p.tags then
                for _, n in ipairs(p.tags) do
                    if n == str then
                        table.insert(lib.ListByTags[name], p)
                        break
                    end
                end
            end
        end

    end
    --PrintOut()
end
stg_levelUPlib.DefineAddition = DefineAddition

local function InitAddition(fake)
    for _, u in pairs(lib.AdditionTotalList) do
        u.pro_fixed = 1
        if not fake then
            u.broken = false
            u.temporary = false
        end
    end
    lib.SortToolUnits()
end
stg_levelUPlib.InitAddition = InitAddition

local function BirdResurrecting()
    local var = lstg.var
    PlaySound("explode")
    PlaySound("resurrecting")
    var.lifeleft = 0.001
    New(lib.class2.resurrection_bird)
end
stg_levelUPlib.BirdResurrecting = BirdResurrecting

local function Rewinding()
    local var = lstg.var
    local tvar = lstg.tmpvar
    local wea = lstg.weather
    local self = stage.current_stage
    var.rewindable = false
    var.lifeleft = 0.001
    tvar.rewind_resurrecting = true
    player.StopLoss = true
    PlaySound("rewind_clock")
    player.lock = true
    object.EnemyNontjtDo(function(b)
        task.Clear(b)
    end)
    object.BulletIndesDo(function(b)
        task.Clear(b)
    end)
    for _, b in ObjList(GROUP.PLAYER) do
        task.Clear(b)
    end
    task.Clear(self)

    task.New(self, function()
        task.New(self, function()
            for i = 1, 120 do
                local k = task.SetMode[2](i / 120 * 2)
                i = task.SetMode[2](i / 120)
                local viewbillboard = lstg.viewbillboard
                local eye = viewbillboard.eye
                local at = viewbillboard.at
                local t = 15 + i * 140
                eye[1], eye[2], eye[3] = cos(t) * 1.5, 1 - i * 2, sin(t) * 1.5 + 0.5
                at[1], at[2], at[3] = 0, 0, 0.5
                viewbillboard.fovy = 1
                ext.OtherScreenEff:Open(1, function()
                    SetViewMode("ui")
                    SetImageState("white", "", 255, 0, 0, 0)
                    local cx, cy = 480, 270
                    misc.SectorRender(cx, cy, 0, k * 600, 0, 360, 80)
                    viewbillboard:Set3D()
                    local s = k * 0.8
                    local z = 0.5
                    Render4V("level_obj_rewind_clock", -s, s, z, s, s, z, s, -s, z, -s, -s, z)
                    SetImageState("white", "", 255, 255, 255, 255)
                    local mA = 90 - i * 30
                    local x1, y1, x2, y2, x3, y3, x4, y4 = 0, 0.005, s * 0.4, 0.005, s * 0.4, -0.005, 0, -0.005
                    x1, y1 = cos(mA) * x1 - sin(mA) * y1, cos(mA) * y1 + sin(mA) * x1
                    x2, y2 = cos(mA) * x2 - sin(mA) * y2, cos(mA) * y2 + sin(mA) * x2
                    x3, y3 = cos(mA) * x3 - sin(mA) * y3, cos(mA) * y3 + sin(mA) * x3
                    x4, y4 = cos(mA) * x4 - sin(mA) * y4, cos(mA) * y4 + sin(mA) * x4
                    Render4V("white", x1, y1, z, x2, y2, z, x3, y3, z, x4, y4, z)
                    mA = 90 - i * 360
                    x1, y1, x2, y2, x3, y3, x4, y4 = 0, 0.002, s * 0.45, 0.002, s * 0.45, -0.002, 0, -0.002
                    x1, y1 = cos(mA) * x1 - sin(mA) * y1, cos(mA) * y1 + sin(mA) * x1
                    x2, y2 = cos(mA) * x2 - sin(mA) * y2, cos(mA) * y2 + sin(mA) * x2
                    x3, y3 = cos(mA) * x3 - sin(mA) * y3, cos(mA) * y3 + sin(mA) * x3
                    x4, y4 = cos(mA) * x4 - sin(mA) * y4, cos(mA) * y4 + sin(mA) * x4
                    Render4V("white", x1, y1, z, x2, y2, z, x3, y3, z, x4, y4, z)
                    -- Set3dMode("ui")
                end, true)
                task.Wait()
            end
        end)
        task.Wait(60)
        ext.ExecuteFlag = false
        tvar.rewind_resurrecting = false
        ResetPool()
        lstg.tmpvar = {}
        self.eventListener = eventListener()
        lstg.tmpvar._fake_init = true
        New(player_list[var.player_select].class)
        local scene_class = self.scene_class
        background.Create(scene_class._bg)
        local p = player
        local lastp = player_lib._last_cache_player
        for t, k in pairs(player_lib._last_cache_var.addition) do
            for _ = 1, k do
                stg_levelUPlib.AdditionTotalList[t]:Set(true, true)
            end
        end
        for k, v in pairs(player_lib._last_cache_var) do
            var[k] = v
        end
        for _, v in ipairs(player_lib.__must_save_data) do
            p[v] = lastp[v]
        end
        for k, v in pairs(player_lib._last_cache_weather) do
            lstg.weather[k] = v
        end

        for k, v in pairs(player_lib._last_cache_active_data) do
            local Active = activeItem_lib.ActiveTotalList[k]
            for index, value in pairs(v) do
                Active[index] = value
            end
        end
        if not var.addition[84] then
            stg_levelUPlib.AdditionTotalList[84]:Set()
        end
        var.rewindable = false
        var.rewind_CD = true
        stg_levelUPlib.AdditionTotalList[84].broken = true

        task.Wait(60)
        player.StopLoss = false
        var.next_wave_id = var.now_wave_id
        var.wave = player_lib._last_cache_var.wave
        if var._season_system then
            wea.next_weather = wea.now_weather
            wea.season_wave = player_lib._last_cache_weather.season_wave - 1
            table.remove(wea.total_weather)
            --table.remove(wea.total_weather)
        end
        --var.wave = var.wave + 1
        self.start_function(var.wave)
    end)
end
stg_levelUPlib.Rewinding = Rewinding

local function Resurrect9_func()
    local var = lstg.var
    var.resurrect9 = var.resurrect9 - 1
    if var.resurrect9 == 0 then
        local tool = lib.AdditionTotalList[106]
        lib.BreakAddition(tool)
        ext.achievement:get(78)
    end
    local x, y = player.x, player.y
    local R = var.resurrect9 * 15
    for a in sp.math.AngleIterator(90, var.resurrect9 + 1) do
        local r, g, b = sp:HSVtoRGB(a, 0.6, 1)
        NewBon(x + cos(a) * R, y + sin(a) * R, 45, 75, r, g, b)
    end
    PlaySound("piyo")
    PlaySound("nice")
    player.protect = player.protect + 180

    player_lib.AddMaxLife(-var.maxlife + 9)
    var.lifeleft = var.maxlife
    local tlist = {}
    for i in pairs(var.addition) do
        ---@type addition_unit
        local tool = lib.AdditionTotalList[i]
        if tool.isTool and not tool.broken and i ~= 106 then
            table.insert(tlist, tool)
        end
    end
    if #tlist > 0 then
        local tool = tlist[ran:Int(1, #tlist)]
        lib.BreakAddition(tool)
        ext.notice_menu:AdditionAdd(tool.id, "invalid", i18n("addition_des", 4)[106].other, 30, 250, 128, 114)
    end
end
stg_levelUPlib.Resurrect9_func = Resurrect9_func

local function ikinokosu_yume_eff_old(p)
    task.New(p, function()
        local sys = p._playersys
        local _color = Color(255, 255, 255, 255)
        local _uv1, _uv2, _uv3, _uv4 = { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }
        _uv1[6] = _color
        _uv2[6] = _color
        _uv3[6] = _color
        _uv4[6] = _color
        local n = 15
        for t = 1, 60 do
            local m = task.SetMode[1](task.SetMode[2](t / 60 * 2))
            local kr1 = 0
            local kr2 = 0
            local dr1 = 1.5
            local dr2 = 1.5
            sys.renderfunc = function()
                for i = 1, 42 do
                    dr2 = 1.5 + 1 * m * sin(i * 5)
                    _color = Color(255 - 100 * (1 - i / 42) * m, 255, 255, 255)
                    for r = 1, n do
                        local da = 360 / n
                        local ang = r * da
                        local cx, cy = p.x, p.y
                        local offa = 0
                        local offx, offy = 0, t / 60 * 100 - 50
                        _uv1[6] = _color
                        _uv2[6] = _color
                        _uv3[6] = _color
                        _uv4[6] = _color
                        _uv1[1], _uv1[2] = cx + offx + cos(ang + offa) * kr2, cy + offy + sin(ang + offa) * kr2
                        _uv2[1], _uv2[2] = cx + offx + cos(ang + offa) * (kr2 + dr2), cy + offy + sin(ang + offa) * (kr2 + dr2)
                        _uv3[1], _uv3[2] = cx + offx + cos(ang + da + offa) * (kr2 + dr2), cy + offy + sin(ang + da + offa) * (kr2 + dr2)
                        _uv4[1], _uv4[2] = cx + offx + cos(ang + da + offa) * kr2, cy + offy + sin(ang + da + offa) * kr2

                        _uv1[4], _uv1[5] = cx + offx + cos(ang) * kr1, cy + offy + sin(ang) * kr1
                        _uv2[4], _uv2[5] = cx + offx + cos(ang) * (kr1 + dr1), cy + offy + sin(ang) * (kr1 + dr1)
                        _uv3[4], _uv3[5] = cx + offx + cos(ang + da) * (kr1 + dr1), cy + offy + sin(ang + da) * (kr1 + dr1)
                        _uv4[4], _uv4[5] = cx + offx + cos(ang + da) * kr1, cy + offy + sin(ang + da) * kr1
                        _uv1[4], _uv1[5] = WorldToScreen(_uv1[4], _uv1[5])
                        _uv2[4], _uv2[5] = WorldToScreen(_uv2[4], _uv2[5])
                        _uv3[4], _uv3[5] = WorldToScreen(_uv3[4], _uv3[5])
                        _uv4[4], _uv4[5] = WorldToScreen(_uv4[4], _uv4[5])
                        RenderTexture(sys.rendert, "", _uv1, _uv2, _uv3, _uv4)
                    end
                    kr1 = kr1 + dr1
                    kr2 = kr2 + dr2
                end
            end
            task.Wait()
        end
        p._playersys.renderfunc = nil
    end)
end

local function ikinokosu_yume_eff()
    local k = lstg.tmpvar.ikinokosu_yume_eff_id or 0
    SmearScreen("IKINOKOSU_YUME" .. k, 60, 1, nil, nil, "mul+add")
    lstg.tmpvar.ikinokosu_yume_eff_id = k + 1
end
stg_levelUPlib.ikinokosu_yume_eff = ikinokosu_yume_eff

local function sakura_kekkai_init()
    if not lstg.tmpvar.sakura_kekkai then
        lstg.tmpvar.sakura_kekkai = {
            black_alpha = 0,
            circle = { alpha = 0, rot = { 0, 0 }, omega = { -0.6, 0.6 }, scale = 1.1 },
            count = 0,
            CD = 0,
            back_obj = nil
        }
        player._playersys:addFrameBeforeEvent("sakura_kekkai", 1, function()
            local s = lstg.tmpvar.sakura_kekkai
            if not lstg.var.ON_sakura and lstg.var.sakura >= 50000 and s.CD <= 0 then
                lstg.var.ON_sakura = true
                s.back_obj = New(lib.class.sakura_back, s)
                s.circle.scale = 1.1
                PlaySound("Sakura", 1)
                lstg.var.sakura_bonus = true
                player.protect = player.protect + 60
                player_lib.AddLife(10)
            end
            if lstg.var.ON_sakura then
                for _, unit in ObjList(GROUP.ITEM) do
                    unit.target = player
                    unit.attract = 10
                end
                s.black_alpha = min(s.black_alpha + 2, 120)
                s.circle.alpha = min(s.circle.alpha + 255 / 60, 255)
                s.circle.rot[1] = s.circle.rot[1] + s.circle.omega[1]
                s.circle.rot[2] = s.circle.rot[2] + s.circle.omega[2]
                s.circle.scale = lstg.var.sakura / 50000 + 0.1
                lstg.var.sakura = max(lstg.var.sakura - 50000 / 540, 0)
                if lstg.var.sakura == 0 then
                    lstg.var.ON_sakura = false
                    if lstg.var.sakura_bonus then
                        s.count = min(s.count + 1, 10)
                        New(lib.class.Sakura_bonus, s.count)
                    else
                        s.count = 0
                        PlaySound("bonus2", 0.2, 0, false)
                        local b
                        object.BulletDo(function(unit)
                            b = New(item.sakura, unit.x, unit.y, nil, nil, 10)
                            b.attract = 10
                            b.target = player
                            Del(unit)
                        end)
                        cutLasersByCircle(0, 0, 999, function(x, y)
                            b = New(item.sakura, x, y, nil, nil, 10)
                            b.attract = 10
                            b.target = player
                        end)
                    end

                    player.protect = max(player.protect, 40)
                    s.CD = 39
                end
            else
                s.black_alpha = max(s.black_alpha - 12, 0)
                s.circle.alpha = max(s.circle.alpha - 25.5, 0)
            end
            s.CD = max(0, s.CD - 1)
        end)
    end
end
stg_levelUPlib.sakura_kekkai_init = sakura_kekkai_init

local function sakura_kekkai_fade()

    if lstg.tmpvar.sakura_kekkai then
        local s = lstg.tmpvar.sakura_kekkai
        if IsValid(s.back_obj) then
            Del(s.back_obj)
        end
        lstg.var.sakura = 0
        lstg.var.ON_sakura = false
        lstg.tmpvar.sakura_kekkai = nil
        player._playersys:removeFrameBeforeEvent("sakura_kekkai")
    end
end
stg_levelUPlib.sakura_kekkai_fade = sakura_kekkai_fade

local function red_wish_LevelUp()
    for _ = 1, 2 do
        local v = lstg.var
        local p = player
        local dmg = player.damage

        local s_set = p.shoot_set
        local speed_set = s_set.speed
        local bv_set = s_set.bvelocity
        local range_set = s_set.range
        local sspeed, bv, lifetime = p.cur_sspeed, p.cur_bv, p.cur_brange
        local red_wish_map = {
            { dmg, function(c)
                p.dmg_offset = p.dmg_offset + c
            end }, --攻击力
            { sspeed, function(c)
                speed_set.offset = speed_set.offset + c
            end }, --射速
            { lifetime, function(c)
                range_set.offset = range_set.offset + c
            end }, --射程
            { bv, function(c)
                bv_set.offset = bv_set.offset + c
            end }, --弹速
        }
        table.sort(red_wish_map, function(a, b)
            return a[1] < b[1]
        end)
        local pro = ran:Float(0, 1)
        local pos = 1
        if pro > 0.9 then
            pos = 4
        elseif pro > 0.7 then
            pos = 3
        elseif pro > 0.4 then
            pos = 2
        end
        local value = 0.5 + 0.5 * v.red_wish
        red_wish_map[pos][2](value)
    end
end
stg_levelUPlib.red_wish_LevelUp = red_wish_LevelUp

local function siyuan_achievement()
    local v = lstg.var
    if v.addition[145] and v.addition[156] and v.addition[163] and
            v.addition[147] and v.addition[150] then
        ext.achievement:get(147)
    end
end
stg_levelUPlib.siyuan_achievement = siyuan_achievement

local function bun_cat_achievement()
    local v = lstg.var
    if v.addition[168] and v.addition[169] and v.addition[170] and v.addition[171] then
        ext.achievement:get(151)
    end
end
stg_levelUPlib.bun_cat_achievement = bun_cat_achievement

local function link_main_bullet_damage()
    sp:UnitListUpdate(player_lib.main_bullet_table)
    for _, b in ipairs(player_lib.main_bullet_table) do
        if b._link_main_bullet then
            object.EnemyNontjtDo(function(e)
                if e.class.base.take_damage and e.colli and sp:pointInSegment(e, b, player, e.a) then
                    e.class.base.take_damage(e, b.dmg * 0.1)
                end
            end)
        end
    end
end
stg_levelUPlib.link_main_bullet_damage = link_main_bullet_damage

local function kokoro_musubu_need()
    local v = lstg.var
    return (v.maxenergy - v.energy) / 8 + v.maxlife / 8
end
stg_levelUPlib.kokoro_musubu_need = kokoro_musubu_need

local function silent_fire_need(Active)
    local v = lstg.var
    local need = v.maxlife / 10
    local charge_c = Active.charge_c * activeItem_lib.GetChargeEfficiency()
    local left = (Active.cost - Active.energy)
    if Active.type == 1 then
        local leftsec = left / charge_c / 60
        need = need + leftsec / 2.5
    elseif Active.type == 2 then
        local leftwave = left / charge_c
        need = need + leftwave * 5
    elseif Active.type == 3 then
        local leftenergy = left / charge_c
        need = need + leftenergy / 7
    end
    return need
end
stg_levelUPlib.silent_fire_need = silent_fire_need



--[[
    NewToolUnit(60, 4, 1, 0, 53, "这就是梭哈！", function()
        local v = lstg.var
        v.randomLevelUp = true
        v.exp_factor = v.exp_factor + 0.5
    end, "经验点获得的经验值+50%\n并且每次升级的\"选择加成\"改为\"随机事件\"", 1, true)--]]
--[[
        NewToolUnit(41, 4, 20, 0, 34, "天星之沐愿(蓝)", function()
        local v = lstg.var
        player._playersys:addGrazingBeforeEvent("addscore", 1, function()
            local addscore = int(v.score * 0.0005 / 10) * 10
            v.score = v.score + addscore
        end)
        lib.AdditionTotalList[40].pro_fixed = 0
        lib.AdditionTotalList[42].pro_fixed = 0
        v.chaos_factor = 1.33
    end, "自机每擦1颗弹，获得当前总分0.05%的分数，混沌值变化时额外改变33%\n", 1, true)
--]]