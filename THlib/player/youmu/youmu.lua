do
    --resource
    local path = "assets\\player\\youmu\\"
    LoadImageFromFile("youmu_player_spell1", path .. "youmu_spell1.png")
    LoadTexture('youmu_player', path .. 'youmu.png')
    LoadImageGroup('youmu_player', 'youmu_player', 0, 0, 32, 48, 8, 3, 0, 0)
    LoadTexture('youmu_player_pic', path .. 'youmu_pic.png')
    LoadTexture2("youmu_spell_back", path .. "youmu_spell_back.png")
    LoadTexture2("youmu_spell_back2", path .. "youmu_spell_back2.png")
    LoadImageFromFile("youmu_player_bullet", path .. "youmu_bullet.png", true, 48, 48)
end

local langModule = "youmu_des"
loadLanguageModule(langModule, "THlib\\player\\youmu")
local function _t(str)
    return i18n(langModule, str) or ""
end

youmu_player = Class(player_class)

function youmu_player:init()
    player_class.init(self)
    player_lib.SetPlayerBulletImg(1, "youmu_player_bullet")
    self.imgs = {}
    for i = 1, 24 do
        self.imgs[i] = 'youmu_player' .. i
    end
    self.charge_shoot = 0
    self.can_shoot = false
    self.can_shoot2 = false
    self.shoot_effect = 0
    self.show_charge = 0
    if player_lib.GetPlayerStarLevel(1) then
        lstg.tmpvar.YoumuSkill1 = true
    end
    if player_lib.GetPlayerStarLevel(2) then
        lstg.tmpvar.YoumuSkill2 = true
    end
    if player_lib.GetPlayerStarLevel(3) then
        lstg.tmpvar.YoumuSkill3 = true
        local baby_class = stg_levelUPlib.class4.baby_class
        local soul = Class(baby_class, {
            init = function(self)
                baby_class.init(self, "white")
                enemy.init(self, 28, 999, false, false, true, 0)
                self.group = GROUP.GHOST
                self._a, self._r, self._g, self._b = 150, 135, 206, 235
                self._blend = "add+add"
                self.hscale, self.vscale = 0.7, 0.7
                --self.tool_id = 139
                self.shoot_table = {}
                task.New(self, function()
                    local w = {}
                    task.init_left_wait(w)
                    local j = 0
                    local gold = (sqrt(5) - 1) / 2
                    while true do
                        local p = player
                        local sspeed = p.cur_sspeed / 3
                        local interval = 60 / sspeed
                        table.insert(self.shoot_table, {
                            offset = w.task_left_wait,
                            offa = (p.shoot_angle_off * gold * j) % max(0.01, p.shoot_angle_off),
                            d = 0
                        })
                        j = j + 1
                        task.Wait2(w, interval)
                    end
                end)
            end,
            shoot = function(self)
                enemy.frame(self)
                local p = player
                if p.__shoot_flag and p.nextshoot <= 0 then
                    player_class.shoot(p, 0.5, -p.x + self.x, -p.y + self.y, self.shoot_table)
                end
                for i = #self.shoot_table, 1, -1 do
                    table.remove(self.shoot_table, i)
                end
            end,
            render = function(self)
                enemy.render(self)
            end
        }, true)
        New(soul)
    end
    lstg.weather.weather_order = { 4, 3, 2, 1 }
end
function youmu_player:frame()
    player_class.frame(self)
    if lstg.var.lost or lstg.var.stop_shoot then
        return
    end
    local ss = self.cur_sspeed
    self.__shoot_delay = 0--没有射击延后
    local auto = ss >= 30
    if auto then
        if lstg.tmpvar.YoumuSkill2 then
            auto = self.can_shoot2
        else
            auto = self.can_shoot
        end
    end
    if self.__shoot_flag and not auto then
        if self.nextshoot <= 0 then
            self.charge_shoot = self.charge_shoot + ss / 650
        end

        if not self.can_shoot and self.charge_shoot >= 1 then
            self.can_shoot = true
            local size = 1
            if lstg.tmpvar._is_challenge18 then
                size = size * lstg.tmpvar._is_challenge18
            end
            local x, y = self.x + 18 * size, self.y + 20 * size
            local r2 = 7 * size
            PlaySound("option", 0.4)
            NewWave(x, y, 2, 60 * size, 10, 189, 252, 201, r2)
        end
        if lstg.tmpvar.YoumuSkill2 and not self.can_shoot2 and self.charge_shoot >= 2 then
            self.can_shoot2 = true
            local size = 1
            if lstg.tmpvar._is_challenge18 then
                size = size * lstg.tmpvar._is_challenge18
            end
            local x, y = self.x + 18 * size, self.y + 20 * size
            local r2 = 10 * size
            PlaySound("option", 0.5)
            NewWave(x, y, 2, 60 * size, 10, 255, 227, 132, r2)
        end
        self.show_charge = self.show_charge + (-self.show_charge + 1) * 0.1
    else
        self.charge_shoot = 0
        if self.can_shoot then
            youmu_player.shoot_after_charge(self)
        end
        self.can_shoot = false
        self.can_shoot2 = false
        self.show_charge = self.show_charge + (-self.show_charge) * 0.1
    end
end
function youmu_player:render()
    player_class.render(self)
    local size = 1
    if lstg.tmpvar._is_challenge18 then
        size = size * lstg.tmpvar._is_challenge18
    end
    local x, y = self.x + 18 * size, self.y + 20 * size
    local A = self.show_charge
    local c = min(self.charge_shoot, 1)
    local r1, r2 = 5 * A * size, 7 * A * size
    SetImageState("white", "", A * 80, 0, 0, 0)
    misc.SectorRender(x, y, r2, r2 + 1, 0, 360, 20)
    misc.SectorRender(x, y, r1 - 1, r1, 0, 360, 20)
    SetImageState("white", "mul+add", A * 80, 255 - c * 205, 50 + c * 205, 50)
    misc.SectorRender(x, y, r1, r2, 90, 90 - 360 * c, 20)
    if lstg.tmpvar.YoumuSkill2 then
        if self.charge_shoot >= 1 then
            c = min(self.charge_shoot - 1, 1)
            r1, r2 = 8 * A * size, 10 * A * size
            SetImageState("white", "", A * 80, 0, 0, 0)
            misc.SectorRender(x, y, r2, r2 + 1, 0, 360, 20)
            misc.SectorRender(x, y, r1 - 1, r1, 0, 360, 20)
            SetImageState("white", "mul+add", A * 80, 255, 50 + c * 205, 50 + c * 205)
            misc.SectorRender(x, y, r1, r2, 90, 90 - 360 * c, 20)
        end
    end
end
function youmu_player:shoot()

end
function youmu_player:shoot_after_charge()
    PlaySound("down", 0.4)
    local var = lstg.var
    local bv, lifetime, dmg, A, self_paradox_pro, class = player_lib.getShootParams(1)
    local can_shoot2 = self.can_shoot2
    task.New(self, function()
        for _ = 1, 10 do
            for _ = 1, 8 do
                local aoff = self.shoot_angle_off + 25
                local f = task.SetMode[1](ran:Float(0, 1)) * ran:Sign()
                local ang = A + f * aoff
                local x = self.x

                local y = self.y
                local vf = 0.3 + 0.7 * (1 - abs(f))
                local v = bv * ran:Float(0.3, vf)
                New(class, x, y, v, ang, dmg, lifetime)
                if var.behind_main_bullet and ran:Float(0, 1) < 0.21 then
                    New(class, x, y, v, ang + 180, dmg, lifetime)
                end

                if ran:Float(0, 1) < self_paradox_pro then
                    New(class, x, y, v, ran:Float(0, 360), dmg, lifetime)
                end

            end
            PlaySound("plst00")
            stg_levelUPlib.link_main_bullet_damage()
            task.Wait(2)
        end
        if can_shoot2 then
            NewWave(self.x, self.y, 2, 60, 10, 255, 227, 132)
            for k = 1, 8 do
                for _ = 1, 8 do
                    local aoff = self.shoot_angle_off + 25 + k * 13
                    local f = task.SetMode[1](ran:Float(0, 1)) * ran:Sign()
                    local ang = A + f * aoff
                    local x = self.x

                    local y = self.y
                    local vf = 0.3 + 0.7 * (1 - abs(f))
                    local v = bv * ran:Float(0.3, vf)
                    New(class, x, y, v, ang, dmg, lifetime)
                    if var.behind_main_bullet and ran:Float(0, 1) < 0.21 then
                        New(class, x, y, v, ang + 180, dmg, lifetime)
                    end

                    if ran:Float(0, 1) < self_paradox_pro then
                        New(class, x, y, v, ran:Float(0, 360), dmg, lifetime)
                    end

                end
                PlaySound("plst00")
                stg_levelUPlib.link_main_bullet_damage()
                task.Wait(2)
            end
        end
    end)


end

local lib = player_lib
local pu = lib.CreatePlayerUnit(7, "Youmu", _t("name"), _t("subname"),
        'youmu_player_pic', 344, 494, 0.48, youmu_player,
        {
            NewLockFunction("scene:3"),
            NewLockFunction("passChallenge:3"),
        }, {
            { _t("Talent1name"), _t("Talent1des"), },
            { _t("Talent2name"), _t("Talent2des"), },
            { _t("Talent3name"), _t("Talent3des"), },
        }, 100, 100, 255)

--设置等级属性
youmu_player.attribute = lib.CreatePlayerAttributeList(46.0, 6, 0.7,
        5, 2.2, 8, 16, 70)

lib.CreateSpellUnit(1, pu, "六道剑「一念无量劫」", "youmu_player_spell1",
        { count = 8, dmg_index = 6, protect = 2, })

local spell1 = plus.Class(lib.spell_class)

function spell1:init(master, attribute)
    self.master = master
    self.count = int(attribute.count)
    self.dmg_index = attribute.dmg_index
    self.protect_time = attribute.protect
end
function spell1:spell()
    local p = self.master

    PlaySound('slash', 1.0)
    local dmg = p.damage * self.dmg_index
    local t = int(self.protect_time * 60)
    local go_t = 10
    p.nextspell = t + self.count * go_t + 35
    p.protect = p.protect + t + self.count * go_t + 35
    p.nextshoot = p.nextshoot + t + self.count * go_t
    p.collect_line = p.collect_line - 600
    lstg.var.energy_efficiency = lstg.var.energy_efficiency - 0.75
    New(youmu_player.bullets.sp_ef, t)
    local set_pos = {}
    SmearScreen("youmu_spell", 7, t, LAYER.ENEMY - 10, nil, "mul+add")
    New(tasker, function()
        local te = int(t / self.count)
        PlaySound("ch00")
        local D = ran:Sign()
        local Y = 200
        table.insert(set_pos, New(youmu_player.bullets.set_pos_ef, p.x, p.y, t + te + (self.count + 1) * go_t))
        for i = 1, self.count - 1 do
            local x = D * ran:Float(200, 280)
            local y = -Y + ran:Float(-30, 30) + (1 - i / self.count) * Y * 2
            table.insert(set_pos, New(youmu_player.bullets.set_pos_ef, x, y, t - te * (i - 1) + (self.count - i + 1) * go_t))
            if true then
                task.Wait(te)
            else
                PlaySound("kira00")
                local w = NewWave(p.x, p.y, 2, 0, te, 218, 112, 214, 100)
                w.layer = LAYER.ENEMY - 20
                for _ = 1, te do
                    w.x, w.y = p.x, p.y
                    task.Wait()
                end
            end
            D = -D

        end

        local smearer = New(youmu_player.bullets.smear_ef)

        for i = 1, self.count do
            misc.ShakeScreen(go_t, 1, 1, 1.5, 1)
            PlaySound('slash', 1.0)
            local cur = set_pos[#set_pos]
            for k = 1, go_t do
                k = task.SetMode[2](k / go_t)

                player.x = player.x + (-player.x + cur.x) * k
                player.y = player.y + (-player.y + cur.y) * k
                local inc = 3
                local dx, dy = p.dx, p.dy
                local d = hypot(dx, dy)
                local count = int(d / inc)
                local ix = inc * (dx / d)
                local iy = inc * (dy / d)
                for c = 0, count do
                    --
                    table.insert(smearer.smear, {
                        alpha = 1,
                        rot = p.rot,
                        hscale = p.hscale,
                        vscale = p.vscale,
                        img = p.img,
                        x = p.x - c * ix,
                        y = p.y - c * iy,
                    })
                end
                object.BulletDo(function(b)
                    if Dist(b, player) < 100 then
                        object.Kill(b)
                    end
                end)
                cutLasersByCircle(p.x, p.y, 100)
                object.EnemyNontjtDo(function(o)
                    if o.colli and o.class.base.take_damage and Dist(o, player) < 200 then
                        o.class.base.take_damage(o, dmg)
                    end
                end)
                task.Wait()
            end
            local R, G, B = 218 + ran:Float(-35, 35), 112 + ran:Float(-35, 35), 214 + ran:Float(-90, 35)
            NewWave(cur.x, cur.y, 2, 280, 48, R, G, B, cur.r)
            NewBon(cur.x, cur.y, 30, 60, R, G, B)
            table.remove(set_pos)
        end
        PlaySound("ch01")
        local i = 1
        local R = 500
        local N = 8
        local d = 9
        for _ = 1, 15 do
            for _ = 1, 5 do
                for a in sp.math.AngleIterator(0, N) do
                    local x = cos(a) * R - cos(a + 180 / N) * i * d
                    local y = sin(a) * R - sin(a + 180 / N) * i * d
                    NewBon(x, y, 30, 10 + i * 0.2, 218, 112, 214, 4)
                end
                i = i + 1
            end
            task.Wait()
        end
        misc.ShakeScreen(42, 2, 1, 1.5, 1)
        --task.Wait(15)
        NewPulseScreen(1, nil, "alpha+bal", 0, 0, 10)
        Del(smearer)
        NewWave(0, 0, 4, 600, 30, 218, 112, 214)
        NewBon(0, 0, 30, 128, 218, 112, 214)
        PlaySound('slash', 1.0)
        object.BulletDo(function(b)
            object.Kill(b)
        end)
        cutAllLaser()
        object.EnemyNontjtDo(function(o)
            if o.colli and o.class.base.take_damage then
                o.class.base.take_damage(o, dmg * 30)
            end
        end)
        p.collect_line = p.collect_line + 600
        lstg.var.energy_efficiency = lstg.var.energy_efficiency + 0.75

    end)

    return t
end
function spell1:getDescribe()
    return _t("spelldes"):format(self.protect_time, self.count, self.dmg_index * 1000, self.dmg_index * 3000)
end

local spells = { spell1 }
youmu_player.spells = spells
do

    local bullets = {}
    youmu_player.bullets = bullets
    local sp_ef = Class(object)
    bullets.sp_ef = sp_ef
    function sp_ef:init(t, noeff)
        self.layer = LAYER.BG + 15
        self.group = GROUP.PLAYER
        self.colli = false
        self.noeff = noeff
        self.bound = false
        self.R = 0
        self.vx = 1
        self.vy = 0.5
        self.alpha = 0

        self.smear = {}
        self.omega = 1
        task.New(self, function()
            local n = t

            for i = 1, n do
                local slow = -0.9 * i / n
                object.BulletIndesDo(function(e)
                    sp:UnitSetVIndex(e, slow)
                end)
                object.EnemyNontjtDo(function(e)
                    sp:UnitSetVIndex(e, slow)
                end)
                self.omega = 1 * task.SetMode[1](1 - i / n)
                task.Wait()
            end
        end)
        task.New(self, function()
            for i = 1, 30 do
                self.alpha = i / 30
                task.Wait()
            end
            task.Wait(t - 60)
            for i = 1, 30 do
                self.alpha = 1 - i / 30
                task.Wait()
            end
            self.stop = true
            while #self.smear > 0 do
                task.Wait()
            end
            Del(self)
        end)
    end
    function sp_ef:frame()
        task.Do(self)
        if not self.stop then
            table.insert(self.smear, {
                rot = self.rot,
                alpha = 0,
                timer = 0,
            })
        end
        for i = #self.smear, 1, -1 do
            local s = self.smear[i]
            s.timer = s.timer + 1

            if s.timer > 7 then
                s.alpha = max(0, s.alpha - 1 / 7)
                if s.alpha == 0 then
                    table.remove(self.smear, i)
                end
            else
                s.alpha = min(1, s.alpha + 1 / 7)
            end
        end
    end
    function sp_ef:render()
        if not self.noeff then
            local world = lstg.world
            misc.RenderTexInRect("youmu_spell_back", world.l, world.r, world.b, world.t, self.x, self.y,
                    0, 1, 1, "mul+rev", Color(self.alpha * 255, 255, 255, 255))
            for _, s in ipairs(self.smear) do
                misc.RenderTexInRect("youmu_spell_back2", world.l, world.r, world.b, world.t, 0, 0,
                        s.rot, 2, 2, "", Color(self.alpha * 50, 100, 100, 100))
            end

        end
    end
    local set_pos_ef = Class(object)
    bullets.set_pos_ef = set_pos_ef
    function set_pos_ef:init(x, y, time)
        self.hide = true
        self.x, self.y = x, y
        self.group = GROUP.PLAYER
        self.layer = LAYER.ENEMY - 20
        self.R, self.G, self.B = 218, 112, 214
        --local b = NewBon(x, y, 60, 0, self.R, self.G, self.B)
        --  b.layer = self.layer
        self.r = 0
        self.alpha = 1
        task.New(self, function()
            for i = 1, 30 do
                self.r = task.SetMode[2](i / 30) * 5
                task.Wait()
            end
            task.Wait(time - 30)

            for i = 1, 15 do
                self.alpha = 1 - i / 15
                task.Wait()
            end
            Del(self)
        end)
    end
    function set_pos_ef:frame()
        task.Do(self)
    end
    function set_pos_ef:render()
        local c1 = Color(150 * self.alpha, self.R, self.G, self.B)
        local c2 = Color(0, self.R, self.G, self.B)
        OriginalSetImageState("white", "mul+add", c1, c2, c2, c1)
        misc.SectorRender(self.x, self.y, self.r - 10, self.r + 1, 0, 360, 30)
        misc.SectorRender(self.x, self.y, self.r + 10, self.r - 1, 0, 360, 30)
        misc.SectorRender(self.x, self.y, 10, 0, 0, 360, 4)
    end

    local smear_ef = Class(object)
    bullets.smear_ef = smear_ef
    function smear_ef:init()
        self.group = GROUP.GHOST
        self.layer = LAYER.PLAYER
        self.smear = {}
        self.colli = false
    end
    function smear_ef:frame()
        for i = #self.smear, 1, -1 do
            local s = self.smear[i]
            s.alpha = max(0, s.alpha - 1 / 30)
            if s.alpha == 0 then
                table.remove(self.smear, i)
            end
        end
    end
    function smear_ef:render()
        for _, s in ipairs(self.smear) do
            SetImageState(s.img, "mul+add", s.alpha * 50, 218, 112, 214)
            Render(s.img, s.x, s.y, s.rot, s.hscale, s.vscale)

        end
    end
end