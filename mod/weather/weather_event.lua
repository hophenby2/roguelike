local module = "weather"
loadLanguageModule(module, "mod\\weather")
local function _t(str)
    return i18n(module, str)
end
local function _t1(str)
    return i18n(module, 1)[str]
end
local function _t2(str)
    return i18n(module, 2)[str]
end
local function _t3(str)
    return i18n(module, 3)[str]
end
local function _t4(str)
    return i18n(module, 4)[str]
end
local function _t5(str)
    return i18n(module, 5)[str]
end

-------------------
local lib = {}
weather_lib = lib
local BackColorList = {
    { 218, 112, 214 },
    { 189, 252, 201 },
    { 250, 200, 100 },
    { 135, 150, 235 },
    { 250, 100, 100 }
}
lib.season = {}
---@type weather_unit[]
lib.weather = {}
local function DefineSeason(id, name)
    local n = {}
    n.id = id
    n.name = name
    n.weathers = {}
    n.R, n.G, n.B = unpack(BackColorList[id])
    lib.season[n.id] = n
    return n
end
DefineSeason(1, _t("spring"))
DefineSeason(2, _t("summer"))
DefineSeason(3, _t("autumn"))
DefineSeason(4, _t("winter"))
DefineSeason(5, _t("inside"))

local ColorList = {
    { 255, 227, 132 },
    { 135, 206, 235 },
    { 205, 128, 114 }
}

local state_name = { _t("state1"), _t("state2"), _t("state3") }
local function DefineWeather(id, inseason, name, state, switch, init, frame, final, subtitle, describe, pro, special_des, other)
    ---@class weather_unit
    local w = {}
    w.id = id
    w.inseason = inseason
    w.inseason_name = lib.season[inseason].name
    w.name = name
    w.subtitle = subtitle
    w.state = state
    w.state_name = state_name[state]
    w.R, w.G, w.B = unpack(ColorList[w.state])
    w.sR, w.sG, w.sB = unpack(BackColorList[w.inseason])
    w.describe = describe
    w.special_des = special_des
    w.switch = switch
    w._init = init
    w._frame = frame
    w._final = final
    w.other = other
    if type(pro) == "function" then
        w.pro = pro
    else
        w.pro = function()
            return pro
        end
    end
    w.init = function()
        local data = scoredata
        data.Weather[id] = true
        data.FirstWeather = true--第一次遇到天气
        if switch then
            lstg.weather[switch] = true
        end
        if init then
            init(w)
        end
    end
    w.frame = frame or function()
    end
    w.final = function()
        local lw = lstg.weather
        if switch then
            lw[switch] = nil
        end
        if final then
            final(w)
        end
        ---一些一直需要重置的数据
        lw.enemyHP_offset = 0
        lw.enemyHP_index = 1
        lw.playerSpeed_index = 1
        lw.bullet_init_func = function()
        end
        lw.enemy_kill_func = function()
        end
    end
    table.insert(lib.season[inseason].weathers, w)
    lib.weather[id] = w
    scoredata.Weather[id] = scoredata.Weather[id] or false
end

local weatherList = DoFile("mod\\weather\\weather_ch.lua")
for i, v in pairs(weatherList) do
    if type(v) == "table" then
        for j, w in pairs(v) do
            local i18 = i18n(module, i)[j]
            DefineWeather(j, i, i18.name, w.state, w.switchname, w.init, w.frame, w.final, i18.stitle, i18.des, w.pro, i18.spdes, i18.other)
        end
    end
end

local function PrintOut()
    local file1 = io.open("User\\what2_en.lua", "wb")

    file1:write("\n")
    file1:write("return {\n")
    for k = 1, 5 do
        file1:write("{\n")
        for i, p in ipairs(lib.weather) do
            if k == p.inseason then
                if false then
                    file1:write(("[\"%s\"] = \"%s\",\n"):format(p.title2, p.title2))
                else
                    file1:write(("[%d] = {\n"):format(i))
                    file1:write(("name = [[%s]],\n"):format(p.name))
                    file1:write(("stitle = [[%s]],\n"):format(p.subtitle))
                    file1:write(("des = [[%s]],\n"):format(p.describe))
                    file1:write(("spdes = [[%s]],\n"):format(p.special_des))
                    if i18n(module, k)["other" .. i] then
                        file1:write(("other = [[%s]],\n"):format(i18n(module, k)["other" .. i]))
                    end
                    file1:write("},\n")
                end
            end
        end
        file1:write("},\n")
    end
    file1:write([[}]])
end
--PrintOut()

local function GanYaoRewind()
    local self = stage.current_stage
    local var = lstg.var
    local wea = lstg.weather
    var.lifeleft = 0.001
    player.lock = true
    player.StopLoss = true
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
        mask_fader:Do("close")
        task.Wait(15)
        mask_fader:Do("open")
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
                Active[index] = value
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
lib.GanYaoRewind = GanYaoRewind

local function JieHan_eff()
    local k = lstg.tmpvar.JieHan_eff_id or 0
    SmearScreen("JieHan" .. k, 60, 1, nil, nil, "mul+add",
            nil, nil, nil, 100, 100, 255)
    lstg.tmpvar.JieHan_eff_id = k + 1
end
lib.JieHan_eff = JieHan_eff

local function HuaYunLilyWhite()
    local bclass = boss.Define(i18n("bossname", "Whitelily"), 0, 400, nil, "Whitelily")

    local non_sc = boss.card.New("", 1, 3, 40, stage_lib.GetHP(900))
    boss.card.add(bclass, non_sc)
    function non_sc:before()
        self.is_subBoss = true
        self.ui.timeCounter.yoffset2 = -15
        --self.ui.drawtime = false
    end
    function non_sc:other_drop()
        local othercond = function(tool)
            return tool.quality == 3 or tool.quality == 4
        end
        local addition = stg_levelUPlib.GetAdditionList(1, othercond)
        if #addition > 0 then
            item.dropItem(item.drop_card, 1, self.x, self.y + 30, addition[1].id)
        end
    end
    function non_sc:init()
        task.New(self, function()
            local function teleport(ix, iy, x, y)
                Newcharge_in(ix, iy, 135, 206, 235)
                task.Wait(50)
                for i = 1, 10 do
                    i = sin(i * 9)
                    self.hscale = 1 - i
                    self.vscale = 1 + i
                    task.Wait()
                end
                self.x, self.y = x, y
                task.New(self, function()
                    for i = 1, 10 do
                        i = sin(i * 9)
                        self.hscale = i
                        self.vscale = 2 - i
                        task.Wait()
                    end
                end)
            end
            teleport(0, 100, 0, 100)
            task.Wait(25)
            task.init_left_wait(self)
            local var = lstg.var
            while true do
                local d = 1
                for k = 1, 4 do
                    local rot = ran:Float(0, 360)
                    for n = 1, 5 do
                        for a, i in sp.math.AngleIterator(rot, int(min(var.chaos / 45) + 5, 13) * 3) do
                            local t = int(i / 3) % 2
                            local v = 1.5 + n
                            local tv = min(10, var.chaos / 250 + 1.3)
                            if t == 1 then
                                Create.bullet_dec_setangle(self.x, self.y, arrow_big, 2, false,
                                        { v = v, a = a, time = 60 }, { func = function(self)
                                            object.SetV(self, tv, Angle(self, player), true)
                                        end })
                            else
                                Create.bullet_dec_setangle(self.x, self.y, grain_a, 6, false,
                                        { v = v, a = a, time = 60 }, { v = tv, a = a - i % 3 * 90 })
                            end
                        end
                        rot = rot + 6 * d
                    end
                    PlaySound("tan00")
                    task.Wait(max(25, 60 - var.chaos / 10))

                    local x, y = task.MoveToPlayer(0, -200, 200, 100, 160,
                            50, 60, 20, 40, 2, 1)
                    if k == 4 then
                        x = 0
                        y = -30
                    end
                    teleport(self.x, self.y, x, y)
                    task.Wait(50)
                    d = -d
                end
                task.New(self, function()
                    task.MoveTo(0, 120, 150, 3)
                end)
                local t = int(min(20 + var.chaos / 25), 65)
                for i = 1, t do
                    local r = ran:Float(0.2, 0.7)
                    local v = ran:Float(1, 2) + min(var.chaos / 400, 6)
                    local k = int(min(4 + var.chaos / 60, 12))
                    local c = (k - 1) / 2
                    for n = -c, c do
                        local rot = 90 + d * (10 + 250 / t * i) + n * 60 / c
                        Create.bullet_changeangle(self.x, self.y, ball_mid, 4 - d * 2,
                                v, rot, { r = d * r, time = 60 })
                    end
                    d = -d
                    PlaySound("tan00")
                    task.Wait2(self, 150 / t)
                end
                task.Wait(max(32, 80 - var.chaos / 25))
            end


        end)
    end
    boss.Create(bclass)
end
lib.HuaYunLilyWhite = HuaYunLilyWhite

local function WeatherFrame()
    local w = lstg.weather
    if w.now_weather and w.now_weather ~= 0 then
        lib.weather[w.now_weather]:frame()
    end
end
lib.WeatherFrame = WeatherFrame

local dead_soul = Class(enemy)
function dead_soul:init(x, y, vx, vy)
    enemy.init(self, 30, 1, false, true, false, 0)
    self.pass_check = true
    self.is_damage = true--有害
    self.last_priority = true
    self.flag = false
    self.x, self.y = x, y
    self.vx, self.vy = vx, vy
end
lib.dead_soul = dead_soul

DoFile("mod\\weather\\weather_obj.lua")
DoFile("mod\\weather\\weather_obj2.lua")
DoFile("mod\\weather\\weather_obj3.lua")
