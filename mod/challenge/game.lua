local module = "challenge"
loadLanguageModule(module, "mod\\challenge\\lang")
local function _t(str)
    return i18n(module, str) or ""
end

local C7Mouse = Class(object, {
    init = function(self)
        self.bound = false
        self.layer = LAYER.PLAYER
        self.group = GROUP.PLAYER
        self.colli = false
        self.alpha = 0.5
        self._r, self._g, self._b = player.colorR, player.colorG, player.colorB
    end,
    frame = function(self)
        task.Do(self)
        local mouse = ext.mouse
        mouse:frame()
        self.R = sqrt(player.damage) * 28
        self.x, self.y = UIToWorld(mouse.x, mouse.y)
        if IsValid(player) then
            player.x, player.y = self.x, self.y
            local w = lstg.world
            local off = player.borderless_offset
            player.x = clamp(player.x, w.pl + 8 - off, w.pr - 8 + off)
            player.y = clamp(player.y, w.pb + 16 - off, w.pt - 32 + off)
        end
        self.dmg = player.damage * 5
        if mouse:isDown(1) then
            PlaySound("explode")
            NewWave(self.x, self.y, 2, self.R * 2, 15, self._r, self._g, self._b, self.R)
            NewBon(self.x, self.y, 15, self.R, self._r, self._g, self._b)
            object.EnemyNontjtDo(function(e)
                if Dist(e, self) < self.R then
                    if e.class.base.take_damage then
                        e.class.base.take_damage(e, self.dmg)
                    end
                end
            end)
            object.BulletDo(function(b)
                if Dist(b, self) < self.R then
                    Del(b)
                end
            end)
            cutLasersByCircle(self.x, self.y, self.R)
        end
    end,
    render = function(self)
        local R, G, B = self._r, self._g, self._b
        SetImageState("bright_circleOutline", "mul+add", self.alpha * 145, R, G, B)
        Render("bright_circleOutline", self.x, self.y, 0, self.R / 200)
        SetImageState("white", "mul+add", self.alpha * 80, R, G, B)
        misc.SectorRender(self.x, self.y, 0, self.R, 0, 360, 25)
    end
}, true)
local C8Mouse = Class(object, {
    init = function(self)
        self.bound = false
        self.layer = LAYER.PLAYER
        self.group = GROUP.PLAYER
        self.colli = false
    end,
    frame = function(self)
        task.Do(self)
        local mouse = ext.mouse
        mouse:frame()
        self.x, self.y = UIToWorld(mouse.x, mouse.y)
        if IsValid(player) then
            player.x, player.y = self.x, self.y
            local w = lstg.world
            local off = player.borderless_offset
            player.x = clamp(player.x, w.pl + 8 - off, w.pr - 8 + off)
            player.y = clamp(player.y, w.pb + 16 - off, w.pt - 32 + off)
        end
    end
}, true)
local C12_rec = Class(object, {
    init = function(self)
        self.bound = false
        self.layer = LAYER.TOP + 1
        self.group = GROUP.GHOST
        self.colli = false
        self.x, self.y = 0, 0
        self.img = "C12_rec"
    end,
    render = function(self)
        local A = 0.7
        SetImageState(self.img, "", A * 255, 255, 255, 255)
        Render(self.img, self.x, self.y)
        local wrinkle = 1
        if self.timer % 30 < 15 then
            wrinkle = 0
        end
        SetImageState("white", "", wrinkle * 255 * A, 255, 0, 0)
        misc.SectorRender(-224, 197, 0, 9, 0, 360, 10)
        local s = int(self.timer / 60) % 60
        local min = int(self.timer / 60 / 60) % 60
        local h = int(self.timer / 60 / 60 / 60)
        RenderTTF2("title", ("%.2d:%.2d:%.2d"):format(h, min, s),
                -283, -172, 1.6, Color(A * 255, 255, 255, 255), "left")
    end
}, true)
local challenge20_should_add_count = 0
LoadImageFromFile("C12_rec", "assets\\challenge\\C12_rec.png")

local NewChallenge = challenge_lib.NewChallenge

NewChallenge(1, BG_7, { "challenge1" }, 10, 1, _t("正体不明的X"), _t("des1"),
        function()
            local v = lstg.var
            v.chaos = 12.5
            v.challenge_addchaos = 2.3
            v._season_system = true
            local w = lstg.weather
            w.Xtool = 10
            w.season_last[5] = 10
            w.next_season = 5
            lstg.tmpvar.stop_reset_inside_pro = true
            lstg.var.level_up_func = function()
                player_lib.AddMaxLife(5)
            end
        end, function()
            local w = lstg.weather
            w.next_weather = 76
        end, {
            NewLockFunction("AfterWeather"),
            NewLockFunction("After5Season"),
            NewLockFunction("bookweather:76"),
            NewLockFunction("scene:2"),
        }, function()
        end)
NewChallenge(2, BG_5, { "challenge2" }, 15, 1, _t("测测你的"), _t("des2"),
        function()
            local slib = stg_levelUPlib
            slib.AdditionTotalList[78]:Set()
            slib.AdditionTotalList[126]:Set()
            lstg.var.level_up_func = function()
                if lstg.var.level % 2 == 1 then
                    slib.AdditionTotalList[78]:Set()
                end
            end
            lstg.var.stop_shoot = true
            local self = stage.current_stage
            for i = #self.wave_events, 1, -1 do
                local w = self.wave_events[i]
                if w.isboss then
                    table.remove(self.wave_events, i)
                end
            end
        end, function()
        end, {
            NewLockFunction("booktool:78"),
            NewLockFunction("booktool:126"),
        }, function()
            mission_lib.GoMission(54, nil, true)
        end)
NewChallenge(3, BG_20, { "challenge3_1", "challenge3_2" }, 20, 1, _t("贪吃蛇"), _t("des3"),
        function()
            local v = lstg.var
            v.challenge_addchaos = 2.89
            local slib = stg_levelUPlib
            for _ = 1, 3 do
                slib.AdditionTotalList[143]:Set()
            end
            slib.AdditionTotalList[131]:Set()
            lstg.var.othercondition = function(tool)
                return not slib.SearchToolTag(tool, "baby") and tool.id ~= 17
            end
            lstg.var.level_up_func = function(otherevent)
                slib.AdditionTotalList[143]:Set()
                slib.SelectAddition(otherevent)
            end
        end, function()
        end, {
            NewLockFunction("booktool:143"),
            NewLockFunction("booktool:131"),
        }, function()
            mission_lib.GoMission(55, nil, true)
        end)
NewChallenge(4, BG_19, { "challenge4_1", "challenge4_2" }, 20, 1, _t("好了知道你是0了"), _t("des4"),
        function()
            local v = lstg.var
            v._season_system = true
            lstg.tmpvar.stop_reset_inside_pro = true
            v.challenge_addchaos = 2.3
            local slib = stg_levelUPlib
            ---@param p addition_unit
            for _, p in ipairs(slib.ListByQual[1]) do
                if p.id ~= 134 then
                    for _ = 1, p.maxcount do
                        p:Set(true)
                    end
                end
            end
        end, function()
        end, {
            NewLockFunction("booktool:151"),
            NewLockFunction("scene:2")
        }, function()
            ext.achievement:get(145)
        end)
NewChallenge(5, BG_16, { "challenge5" }, 20, 1, _t("尘肺病"), _t("des5"),
        function()
            local v = lstg.var
            v.challenge_addchaos = 2.5
            v._season_system = true
            local w = lstg.weather
            w.season_last[4] = 20
            w.next_season = 4
            w.next_weather = 37
        end, function()
            local w = lstg.weather
            w.next_weather = 37
        end, {
            NewLockFunction("bookweather:37"),
        }, function()
            if player.name == "Chiruno" then
                ext.achievement:get(139)
            end
            mission_lib.GoMission(57, nil, true)
        end)
NewChallenge(6, BG_25, { "challenge6_1", "challenge6_2" }, 20, 1, _t("我是地质学家，这就是神金"), _t("des6"),
        function()
            local slib = stg_levelUPlib
            for _ = 1, 3 do
                slib.AdditionTotalList[38]:Set()
            end
            local v = lstg.var
            v.challenge_addchaos = 2.5
            v._season_system = true
            v.forbid_slow = true--禁止低速
            local w = lstg.weather
            w.season_last[5] = 20
            w.next_season = 5
            w.next_weather = 29
        end, function()
            local w = lstg.weather
            w.next_weather = 29
        end, {
            NewLockFunction("booktool:38"),
            NewLockFunction("bookweather:29")
        }, function()
            if player.name == "Aya" then
                ext.achievement:get(138)
            end
            mission_lib.GoMission(58, nil, true)
        end)
NewChallenge(7, BG_22, { "challenge7" }, 15, 1, _t("打妖精"), _t("des7"),
        function()
            local v = lstg.var
            v.challenge_addchaos = 15
            v._season_system = true

            local slib = stg_levelUPlib
            slib.AdditionTotalList[64]:Set()
            lstg.tmpvar.C7Mouse = New(C7Mouse)
        end, function()
            if IsValid(player) and not IsValid(lstg.tmpvar.C7Mouse) then
                lstg.tmpvar.C7Mouse = New(C7Mouse)
            end
            player._playersys.stopUpdateKey = true
        end, {
            NewLockFunction("scene:2")
        }, function()
            mission_lib.GoMission(73, nil, true)
        end)
NewChallenge(8, BG_8, { "challenge8" }, 18, 1, _t("东方游戏手机版"), _t("des8"),
        function()
            local v = lstg.var
            v.challenge_addchaos = 3
            v._season_system = true
            lstg.tmpvar.C8Mouse = New(C8Mouse)
        end, function()
            if IsValid(player) and not IsValid(lstg.tmpvar.C8Mouse) then
                lstg.tmpvar.C8Mouse = New(C8Mouse)
            end
        end, {
            NewLockFunction("passChallenge:7")
        }, function()
            mission_lib.GoMission(70, nil, true)
        end)
NewChallenge(9, BG_24, { "challenge9" }, 10, 1, _t("蓬莱之药"), _t("des9"),
        function()
            local v = lstg.var
            v.challenge_addchaos = 5.8
            v._season_system = true
        end, function()
            local t = stage.current_stage.timer
            local koff = 42500
            lstg.var.CYFPS = 15 + 105 * (koff / (t + koff)) ^ 5
        end, {
            NewLockFunction("tool:97"),
            NewLockFunction("tool:117"),
            NewLockFunction("tool:99"),
            NewLockFunction("tool:114"),
            NewLockFunction("tool:101"),
        }, function()
        end)
NewChallenge(10, BG_12, { "challenge10" }, 12, 1, _t("滑动变阻器"), _t("des10"),
        function()
            local v = lstg.var
            v.chaos = 30
            v.challenge_addchaos = 3
            v._season_system = true
            lstg.var.CYFPS = 120
        end, function()
            local kfps = 0
            if IsValid(player) then
                if player.dx ~= 0 or player.dy ~= 0 or stage.current_stage.timer < 60 or lstg.var.lost then
                    kfps = 365
                end
                lstg.var.CYFPS = lstg.var.CYFPS + (-lstg.var.CYFPS + kfps) * 0.04365
            else
                lstg.var.CYFPS = 60
            end
        end, {
            NewLockFunction("passChallenge:9")
        }, function()
        end)
NewChallenge(11, BG_21, { "challenge11" }, 7, 1, _t("收起你的小霁霁"), _t("des11"),
        function()
            local v = lstg.var
            v.challenge_addchaos = 4
            v._season_system = true
        end, function()
            if not IsValid(lstg.tmpvar.Challenge11Eff) then
                lstg.tmpvar.Challenge11Eff = SmearScreen("Challenge11", 12, 1e308,
                        LAYER.BG + 10, LAYER.TOP, "mul+add")
            end
        end, {
            NewLockFunction("scene:2")
        }, function()
        end)
NewChallenge(12, BG_23, { "challenge12" }, 12, 1, _t("新「文」直播间"), _t("des12"),
        function()
            local v = lstg.var
            v.challenge_addchaos = 3
            v._season_system = true
            lstg.tmpvar.RotateWorld = misc.RotateWorld("challenge12_RT", LAYER.BG - 11, 0)
        end, function()
            if not IsValid(lstg.tmpvar.C12_rec) then
                lstg.tmpvar.C12_rec = New(C12_rec)
            end
            if not IsValid(lstg.tmpvar.RotateWorld) then
                lstg.tmpvar.RotateWorld = misc.RotateWorld("challenge12_RT", LAYER.BG - 11, 0)
            end
            local world = lstg.tmpvar.RotateWorld
            local function SetCameraScale(scale)
                world.hscale = scale
                world.vscale = scale
            end
            local timer = stage.current_stage.timer
            local size = sin(timer / 2) * 0.1 + 1.6
            SetCameraScale(size)
            local sw, sh = 320, 240
            local x = player.x
            local y = player.y
            local num = 0
            local tx = 0
            local ty = 0
            object.BulletIndesDo(function(b)
                num = num + 1
                tx = tx + b.x
                ty = ty + b.y
            end)
            local ax, ay = tx / num, ty / num
            local Realnum = 0
            object.BulletIndesDo(function(b)
                if BoxCheck(b, ax - sw * size, ax + sw * size, ay - sh * size, ay + sh * size) then
                    Realnum = Realnum + 1
                end
            end)
            if Realnum > 0 then
                x, y = ax, ay
            end
            x = clamp(x, sw * (1 - size), -sw * (1 - size))
            y = clamp(y, sh * (1 - size), -sh * (1 - size))
            world.x = world.x + (-x - world.x) * 0.1
            world.y = world.y + (-y - world.y) * 0.1
        end, {
            NewLockFunction("scene:2")
        }, function()
            mission_lib.GoMission(71, nil, true)
        end)
NewChallenge(13, BG_10, { "challenge13" }, 15, 1, _t("引力超大的(魔理沙)"), _t("des13"),
        function()
            local v = lstg.var
            v.challenge_addchaos = 1
            v._season_system = true
            local slib = stg_levelUPlib
            slib.AdditionTotalList[86]:Set()
        end, function()
            lstg.wave.all_green_bullet = true
            local f = function(b, p, slo)
                slo = slo or "a"
                if not (b.__not_XuanWo or b.not_move) then
                    local r = max(Dist(b, p), 25)
                    local ang = Angle(b, p)
                    local G = 6.674e-11
                    local pA = player.a * 10e12
                    local A = b[slo] * pA * G / r / r
                    b._c13_vx = b._c13_vx or 0
                    b._c13_vy = b._c13_vy or 0
                    b._c13_vx = b._c13_vx + A * cos(ang)
                    b._c13_vy = b._c13_vy + A * sin(ang)
                    b.x = b.x + b._c13_vx
                    b.y = b.y + b._c13_vy
                end
            end
            object.LaserDo(function(b)
                f(b, player, "w")
                if IsValid(lstg.tmpvar.fake_player) then
                    f(b, lstg.tmpvar.fake_player, "w")
                end
            end)
            object.BulletIndesDo(function(b)
                f(b, player)
                if IsValid(lstg.tmpvar.fake_player) then
                    f(b, lstg.tmpvar.fake_player)
                end
            end)
            for _, i in ObjList(GROUP.ITEM) do
                f(i, player)
                if IsValid(lstg.tmpvar.fake_player) then
                    f(i, lstg.tmpvar.fake_player)
                end
            end

        end, {
            NewLockFunction("scene:2")
        }, function()
        end)
NewChallenge(14, BG_2, { "fake_music" }, 16, 1, _t("东方弹幕风"), _t("des14"),
        function()
            local v = lstg.var
            v.challenge_addchaos = 4
            v._season_system = true
        end, function()
            local fps = 60
            local tvar = lstg.tmpvar
            tvar._last_objn = tvar._now_objn or 0
            tvar._now_objn = GetnObj()

            fps = min(61, 677 / ((tvar._now_objn + 1) ^ 0.376))
            local ct = tvar._now_objn - tvar._last_objn
            fps = fps - ct * 0.1
            if GetKeyState(setting.keys.pass) then
                fps = fps * ran:Float(1.56, 1.69)
            end
            lstg.var.CYFPS = abs(fps)
            for _, b in ipairs(boss_group) do
                b._wisys:SetImageInList("Rumia")
            end
        end, {
            NewLockFunction("scene:2")
        }, function()
        end)
NewChallenge(15, BG_1, { "challenge15" }, 12, 1, _t("只能听见歌声了"), _t("des15"),
        function()
            local v = lstg.var
            v.challenge_addchaos = 3
            v._season_system = true
        end, function()
            if not IsValid(lstg.tmpvar.Challenge16Eff) then
                lstg.tmpvar.Challenge16Eff = SmearScreen("Challenge16", 1, 1e308,
                        LAYER.BG + 10, LAYER.TOP, "mul+min")
            end
        end, {
            NewLockFunction("scene:3")
        }, function()
            mission_lib.GoMission(72, nil, true)
        end)
NewChallenge(16, BG_6, { "challenge16" }, 15, 1, _t("塔防游戏"), _t("des16"),
        function()
            local v = lstg.var
            local slib = stg_levelUPlib
            slib.AdditionTotalList[197]:Set()
            player.shoot_set.range.fixed = player.shoot_set.range.fixed * 1.33
            v.challenge_addchaos = 3
            v._season_system = true
        end, function()
            local ssb = player.shoot_set.bvelocity
            ssb.fixed = 0
            if not player._playersys.listener:find("enemyKill", "challenge16killer") then
                player._playersys:addEnemyKillEvent("challenge16killer", 1, function(self)
                    local sr = self.shoot_set.range
                    sr.offset = sr.offset + 0.1
                    sr.fixed = sr.fixed + 0.0025
                end)
            end
        end, {
            NewLockFunction("scene:3")
        }, function()
        end)
NewChallenge(17, BG_3, { "challenge17" }, 20, 1, _t("乾坤大挪移"), _t("des17"),
        function()
            local v = lstg.var
            local slib = stg_levelUPlib
            slib.AdditionTotalList[72]:Set()
            v.challenge_addchaos = 2
            v._season_system = true
        end, function()
            local tvar = lstg.tmpvar
            tvar.cache__move_dx = tvar.cache__move_dx or 0
            tvar.cache__move_dx = tvar.cache__move_dx + (-tvar.cache__move_dx + sign(player.__move_dx)) * 0.1
            local doRotate = function(e)
                if not e.__not_XuanWo then
                    local R = Dist(0, 0, e)
                    local A = Angle(0, 0, e)
                    local v = R / (45 - stage_lib.GetValue(0, 10, 20, 44))
                    e.x = e.x - cos(A + 90) * v * tvar.cache__move_dx
                    e.y = e.y - sin(A + 90) * v * tvar.cache__move_dx
                end
            end
            object.EnemyNontjtDo(doRotate)
            object.BulletIndesDo(doRotate)
            object.LaserDo(doRotate)
            doRotate(player)
            for _, i in ObjList(GROUP.ITEM) do
                doRotate(i)
            end
            local up = lstg.view3d.up
            local curA = atan2(up[2], up[1])
            curA = curA + tvar.cache__move_dx * 0.8
            up[1] = cos(curA)
            up[2] = sin(curA)
        end, {
            NewLockFunction("bookweather:30"),
            NewLockFunction("scene:2"),
        }, function()
        end)
NewChallenge(18, BG_1, { "challenge18" }, 15, 1, _t("等比稀释"), _t("des18"),
        function()
            local v = lstg.var
            v.challenge_addchaos = 2
            v._season_system = true
            if IsValid(player) then
                player_lib.AddPlayerCollisize(0, -0.7)
            end
        end, function()
            lstg.tmpvar._is_challenge18 = 0.3
            lstg.view3d.fovy = 2

        end, {
            NewLockFunction("bookweather:5"),
            NewLockFunction("scene:3"),
        }, function()
            mission_lib.GoMission(69, nil, true)
        end)
NewChallenge(19, BG_26, { "challenge19" }, 15, 1, _t("昨日重现"), _t("des19"),
        function()
            local v = lstg.var
            v._season_system = true
            local slib = stg_levelUPlib
            slib.AdditionTotalList[119]:Set()
            slib.AdditionTotalList[179]:Set()
            local w = lstg.weather
            w.season_last[2] = 15
            w.next_season = 2
            w.next_weather = 60
            player.collect_line = player.collect_line - 600
        end, function()
            local w = lstg.weather
            w.next_weather = 60
            object.BulletDo(function(b)
                if not b.not_move then
                    if not b.c19index then
                        b.c19index = -0.4
                    end
                    if not b.colli and b.timer >= 66 then
                        b.c19index = -1
                    else
                        b.c19index = -0.4
                    end
                    sp:UnitSetVIndex(b, b.c19index)
                end
            end)
        end, {
            NewLockFunction("bookweather:60"),
        }, function()
            mission_lib.GoMission(74, nil, true)
        end)
NewChallenge(20, BG_14, { "challenge19" }, 100, 1, _t("这就是你想要的无尽模式"), _t("des20"),
        function()
            local v = lstg.var
            v._season_system = true
            challenge20_should_add_count = stagedata.challenge_finish[20] + 1
            local mlist = {}
            challenge_lib.class[20]._bgmlist = {}
            for m in pairs(musicList) do
                if m:find("challenge") then
                    table.insert(mlist, m)
                end
            end
            for _ = 1, #mlist do
                table.insert(challenge_lib.class[20]._bgmlist, table.remove(mlist, ran:Int(1, #mlist)))
            end
        end, function()
            local v = lstg.var
            v.maxwave = v.wave + 2
            v.FINAL_HARD_BOSS = true
            if v.wave > 20 then
                if stagedata.challenge_finish[20] == 0 then
                    stagedata.challenge_time[20] = os.time()
                end
                stagedata.challenge_finish[20] = challenge20_should_add_count
            end
        end, {
            NewLockFunction("scene:3"),
        }, function()

        end)
NewChallenge(21, BG_2, { "challenge21" }, 15, 1, _t("布朗运动"), _t("des21"),
        function()
            local v = lstg.var
            v._season_system = true
            local slib = stg_levelUPlib
        end, function()
            object.BulletDo(function(b)
                if not b.not_move then
                    local beat = stage_lib.GetValue(1, 2, 3, 5)
                    local c21index = -1
                    local g = ran:Float(0, 1)
                    if g <= 0.1 then
                        c21index = ran:Float(-100, beat * 3)
                        sp:UnitSetVIndex(b, c21index)
                    else
                        b.x = b.x + ran:Float(-beat, beat)
                        b.y = b.y + ran:Float(-beat, beat)
                    end
                end
            end)
        end, {
            NewLockFunction("scene:3"),
        }, function()
        end)