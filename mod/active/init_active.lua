local lib = activeItem_lib
local NewActiveUnit = lib.NewActiveUnit

local function STT(tags)
    local t = {}
    for _, n in ipairs(tags) do
        for tagname, tn in pairs(stg_levelUPlib.tagslist) do
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
local function PrintOut2()
    local file1 = io.open("User\\what2_en.lua", "wb")
    file1:write([[local tg = stg_levelUPlib.tagslist
]])
    file1:write("\n")
    file1:write("return {\n")
    for k = 1, 5 do
        file1:write("{\n")
        for i, p in pairs(lib.ActiveTotalList) do

            if k == p.quality + 1 then
                if false then
                    file1:write(("[\"%s\"] = \"%s\",\n"):format(p.title2, p.title2))
                else
                    file1:write(("[%d] = {\n"):format(i))
                    file1:write(("name = [[%s]],\n"):format(p.title2))
                    file1:write(("stitle = [[%s]],\n"):format(p.subtitle))
                    file1:write(("sdes = [[%s]],\n"):format(p.describe))
                    file1:write(("detail = [[%s]],\n"):format(p.detail))
                    file1:write(("collabd = [[%s]],\n"):format(p.collab_des))
                    file1:write(("unlockd = [[%s]],\n"):format(p.unlock_des))
                    file1:write(("condd = [[%s]],\n"):format(p.cond_des))
                    if false then
                        file1:write(("tags = %s,\n"):format(STT(p.tags)))
                        file1:write(("activeType = %d,\n"):format(p.type))
                        file1:write(("chargeC = %f,\n"):format(p.charge_c))
                        file1:write(("maxEnergy = %d,\n"):format(p.energy_max))
                        file1:write(("hold = %s,\n"):format(p.hold and "true" or "false"))
                        file1:write(("cost = %f,\n"):format(p.cost))
                        file1:write(("event = %s,\n"):format("nil"))
                        file1:write(("frameEvent = %s,\n"):format("nil"))
                        file1:write(("condfunc = %s,\n"):format("nil"))
                    end
                    file1:write("},\n")
                end
            end

        end
        file1:write("},\n")
    end
    file1:write([[}]])
end

local function DefineActive()
    local active_list = DoFile("mod\\active\\active_des_ch.lua")
    for i, v in pairs(active_list) do
        for j, w in pairs(v) do
            local u = NewActiveUnit(j, i - 1, w.event, w.activeType, w.chargeC, w.maxEnergy, w.condfunc,
                    w.tags, w.unlockd and true, w.hold, w.cost, w.frameEvent)
            u.real_cost = w.real_cost
        end
    end
end
activeItem_lib.DefineActive = DefineActive

local function InitActive(fake)
    for _, u in pairs(lib.ActiveTotalList) do
        u.pro_fixed = 1
        if not fake then
            u.energy = 1
            --初始化属性
            u.type = u._type
            u.charge_c = u._charge_c
            u.energy_max = u._energy_max
            u._is_using = false
            u.last_is_using = false
        end
    end

end
activeItem_lib.InitActive = InitActive

local function PitayaResurection()
    local x, y = player.x, player.y
    local var = lstg.var
    NewWave(x, y, 5, 300, 40, 250, 128, 114)
    NewBon(x, y, 45, 75, 250, 128, 114)
    PlaySound("eatfood")
    PlaySound("ch01")
    lib.ActiveTotalList[5]:Remove()
    player.protect = player.protect + 120
    var.lifeleft = var.maxlife
end
activeItem_lib.PitayaResurection = PitayaResurection

local function Rewinding()
    local var = lstg.var
    local tvar = lstg.tmpvar
    local wea = lstg.weather
    local self = stage.current_stage
    var.rewindable = false
    --var.lifeleft = 0.001
    tvar.rewind_resurrecting = true
    player.StopLoss = true
    PlaySound("rewind_clock")
    player.lock = true
    player.protect = 666
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
                    misc.RenderBrightOutline(0, 960, 0, 540, 80, k * 50, 135, 206, 235)
                    viewbillboard:Set3D()
                    local s = k * 0.8
                    local z = 0.5
                    Render4V("level_obj_rewind_clock", -s, s, z, s, s, z, s, -s, z, -s, -s, z)
                    SetImageState("white", "", 255, 135, 206, 235)
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
        local lastp = player_lib._cache_player
        for t, k in pairs(player_lib._cache_var.addition) do
            for _ = 1, k do
                stg_levelUPlib.AdditionTotalList[t]:Set(true, true)
            end
        end
        for _, v in ipairs(player_lib.__must_save_data) do
            p[v] = lastp[v]
        end
        for k, v in pairs(player_lib._cache_var) do
            var[k] = v
        end
        for k, v in pairs(player_lib._cache_weather) do
            lstg.weather[k] = v
        end

        for k, v in pairs(player_lib._cache_active_data) do
            local Active = activeItem_lib.ActiveTotalList[k]
            --Active:Set()
            for index, value in pairs(v) do
                if k ~= 11 then
                    Active[index] = value
                end
            end
        end

        task.Wait(15)
        player.StopLoss = false
        var.next_wave_id = var.now_wave_id
        if var._season_system then
            wea.next_weather = wea.now_weather
            wea.season_wave = wea.season_wave - 1
            table.remove(wea.total_weather)
        end
        --var.wave = var.wave + 1
        self.start_function(var.wave)
    end)
end
activeItem_lib.Rewinding = Rewinding