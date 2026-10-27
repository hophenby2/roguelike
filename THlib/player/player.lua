local lib = {}
player_lib = lib

----------------------------------------
---加载资源
local path = "assets\\player\\"
LoadPS("player_death_ef", path .. "player_death_ef.psi", "parimg1")
LoadImageFromFile("player_aura", path .. "player_aura.png", true)
LoadImageFromFile("player_aura2", path .. "player_aura2.png", true)
LoadImageFromFile("collect_line", path .. "collect_line.png", true)
LoadImageFromFile("Grazer2", path .. "Grazer.png", true)
LoadImageFromFile("player_bullet", path .. 'player_bullet.png', true, 48, 48)
LoadImageFromFile("mimichan_bullet", path .. 'mimichan.png', true, 48, 48)
--LoadImageFromFile("love_bullet", 'THlib\\player\\love_bullet.png', true, 48, 48)
DoFile("THlib\\player\\player_system.lua")

----------------------------------------
---player class
---@class player
player_class = Class(object)
lib.player_class = player_class

function player_class:init()
    lib.PlayerInit()

    New(BulletBreak_Table)
    New(ui.ChaosRenderObj)
    self.my_shield = New(player_shield)
    self.group = GROUP.PLAYER
    self.layer = LAYER.PLAYER
    self.bound = false
    self.x = 0
    self.y = -176
    self._blend = ""
    self._a, self._r, self._g, self._b = 255, 255, 255, 255
    self._wisys = PlayerWalkImageSystem(self) --by OLC，自机行走图系统
    self._playersys = player_lib.system(self) --by OLC，自机逻辑系统
    --self.class = player_class--
    lstg.player = self
    player = self
    local var = lstg.var
    local ps = var.player_select
    local ss = var.spell_select
    player_lib.SetPlayerAttribute(self, ps)
    self.spell_sys = self.class.spells[ss](self, lib.GetSpellAttribute(ps, ss))
    self.skill_level = int(playerdata[self.name].unlock_c or 0)
    if stage.current_stage.is_tutorial then
        self.skill_level = 0
        player_lib.SetPlayerAttribute(self, ps)
        self.spell_sys = self.class.spells[ss](self, lib.GetSpellAttribute(ps, ss))
    end

    self.particle = {}
    self.energy_particle = {}
    ---作为储存射击子弹的表
    self.shoot_table = {}
    self.StopLoss = false--在一些特殊情况时停止流失生命
    self.shoot_rot = 90
    ---每帧更新，便于引用
    self.damage = 0
    self.A, self.B = 0.5, 0.5
    self.cur_hspd, self.cur_lspd = 0, 0
    self.cur_sspeed, self.cur_bv, self.cur_brange = 0, 0, 0
    task.New(self, function()
        local w = {}
        task.init_left_wait(w)
        local j = 0
        local gold = (sqrt(5) - 1) / 2
        while true do
            --一对的自我也要改记得
            local sspeed = self.cur_sspeed
            local interval = 60 / sspeed
            table.insert(self.shoot_table, {
                offset = w.task_left_wait,
                offa = (self.shoot_angle_off * gold * j) % max(0.01, self.shoot_angle_off),
                d = j % 2 * 2 - 1
            })
            j = j + 1
            task.Wait2(w, interval)
        end
    end)
end

function player_class:spell()
    local v = lstg.var
    local tvar = lstg.tmpvar
    local healing = true
    if not tvar.bird_resurrecting and not tvar.rewind_resurrecting then
        if v.ON_sakura then
            lstg.var.sakura = 0
            lstg.var.sakura_bonus = false
            player.nextspell = 40
            return
        end
        if v.kokoro_musubu and v.energy < v.maxenergy then
            local need = stg_levelUPlib.kokoro_musubu_need()
            if v.lifeleft > need then
                v.energy = v.maxenergy
                player_lib.ReduceLife(need, nil, true, nil, "kokoro_musubu")
                healing = false
                PlaySound("extend2")
            end
        end
        if v.energy >= v.maxenergy then
            if v.bomb_healing then
                lib.AddLife(healing and v.bomb_healing or 5)
            end

            local time
            if tvar.bomb_to_protect then
                PlaySound("goast1")
                time = self.spell_sys.protect_time * 60 * (1.6 + 0.4 * tvar.bomb_to_protect.count)
                self.protect = self.protect + time
                self.nextspell = self.nextspell + time
                self.nextshoot = self.nextshoot + time
                self.hspeed_factor = self.hspeed_factor + 0.5
                self.lspeed_factor = self.lspeed_factor + 0.5
                task.New(self, function()
                    task.Wait(time)
                    StopSound("goast1")
                    PlaySound("goast2")
                    player.hspeed_factor = player.hspeed_factor - 0.5
                    player.lspeed_factor = player.lspeed_factor - 0.5
                end)
            else
                time = self.spell_sys:spell()
            end
            scoredata._total_bomb = scoredata._total_bomb + 1
            lstg.tmpvar.spell_count = lstg.tmpvar.spell_count + 1
            mission_lib.GoMission(11, 1 / 5 * 100 + 0.01)--魔力护瓶
            mission_lib.GoMission(1, 1 / 15 * 100 + 0.01)--硝酸甘油
            mission_lib.GoMission(18, 1 / 30 * 100 + 0.01)--灵力槽
            mission_lib.GoMission(95, 1 / 30 * 100 + 0.01)--Powerful Point
            if lstg.tmpvar.spell_count >= 5 then
                mission_lib.GoMission(36)
            end

            if tvar.MarisaSkill3 then
                local slib = stg_levelUPlib
                local k = slib.ListByState[1][ran:Int(1, #slib.ListByState[1])]
                k:Set(true)
                ext.notice_menu:AdditionAdd(k.id, "bonus", i18n("marisa_des", "Talent3name"), 25)
            end
            v.energy = v.energy - v.maxenergy
        end
    end
end

function player_class:special()
    local v = lstg.var
    ---@type active_unit
    local ActiveID = v.active_item[1]
    if ActiveID then
        local Active = activeItem_lib.ActiveTotalList[ActiveID]
        if v.silent_fire and Active.energy < Active.cost then
            local need = stg_levelUPlib.silent_fire_need(Active)
            if v.lifeleft > need then
                Active.energy = Active.cost
                player_lib.ReduceLife(need, nil, true, nil, "silent_fire")
                PlaySound("extend2")
            end
        end
        if Active.energy >= Active.cost then
            Active:event()
            v.UI_active_item[1].r = min(40, v.UI_active_item[1].r + 10)
            local cost = Active.real_cost or Active.cost
            Active.energy = Active.energy - cost
            return true
        end
    end
end

function player_class:shoot(dmgindex, ox, oy, shoot_table, class)
    dmgindex = dmgindex or 1
    ox = ox or 0
    oy = oy or 0
    local var = lstg.var
    local bv, lifetime, dmg, A, self_paradox_pro, rclass = lib.getShootParams(dmgindex, class)
    local size = lib.GetPlayerBulletSize()
    for _, p in ipairs(shoot_table or self.shoot_table) do
        PlaySound('plst00', 0.15, self.x)
        local k = -p.offset * bv
        local d = p.d
        local kx = 10 * size / 0.5
        local offa = p.offa
        if offa ~= 0 then
            kx = 0
        end--如果存在散射角，就不正负交替
        if var.rotate_star then
            offa = offa + 90
        end
        local ang = A + offa * d
        local x = self.x + ox + cos(ang) * k
        local y = self.y + oy + sin(ang) * k

        New(rclass, x - kx * d, y, bv, ang, dmg, lifetime)
        if var.behind_main_bullet and ran:Float(0, 1) < 0.21 then
            New(rclass, x - kx * d, y, bv, ang + 180, dmg, lifetime)
        end

        if ran:Float(0, 1) < self_paradox_pro then
            New(rclass, x, y, bv, ran:Float(0, 360), dmg, lifetime)
        end
        stg_levelUPlib.link_main_bullet_damage()
    end
end
function player_class:frame()
    local tvar = lstg.tmpvar
    self.damage = lib.GetPlayerDmg()
    self.cur_hspd, self.cur_lspd = lib.GetPlayerSpeed()
    self.cur_sspeed, self.cur_bv, self.cur_brange = lib.GetShootAttribute()
    self.A = lib.GetPlayerCollisize()
    self.B = self.A

    if tvar.lost or self.realrealreal_lock then
        return
    end

    weather_lib.WeatherFrame()
    stage_lib.RefreshHPindex()
    activeItem_lib.AddActiveChargeByFrame()

    task.Do(self)
    self._playersys:doFrameBeforeEvent()
    self._playersys:frame()
    self.spell_sys:frame()
    self._playersys:doFrameAfterEvent()
    do
        local p
        for i = #self.particle, 1, -1 do
            p = self.particle[i]
            p.x = p.x + p.vx
            p.y = p.y + p.vy
            p.vx = p.vx - p.vx * 0.04
            p.vy = p.vy - p.vy * 0.04
            --if p.timer > 10 then
            p.alpha = max(p.alpha - 4, 0)
            if p.alpha == 0 then
                table.remove(self.particle, i)
            end
            --end
            p.timer = p.timer + 1
        end
        for i = #self.shoot_table, 1, -1 do
            table.remove(self.shoot_table, i)
        end
        local s
        local _w = lstg.world
        for i = #self.energy_particle, 1, -1 do
            s = self.energy_particle[i]
            task.Do(s)
            s.timer = s.timer + 1
            s.rot = s.rot + s.omega
            if s.cao or not sp.math.PointBoundCheck(s.x, s.y, _w.boundl, _w.boundr, _w.boundb, _w.boundt) then
                table.remove(self.energy_particle, i)
            end
        end
    end--粒子等帧行为
    SetImageScale(lib.GetPlayerBulletImg(), lib.GetPlayerBulletSize() / 4)
    lib.UpdateDmgTypeCache()
end
function player_class:render()
    if self.realrealreal_lock then
        return
    end
    self._playersys:doRenderBeforeEvent()
    self._playersys:render()
    self.spell_sys:render()
    self._playersys:doRenderAfterEvent()

    if self.protect > 0 then
        local tA = min(self.protect, 20) / 20
        ui:RenderText("title", ("%0.2f"):format(self.protect / 60), self.x, self.y + 20,
                0.5, Color(tA * 150, 255, 255, 255), "centerpoint")
    end
    do
        if not lstg.var.paralyzed then
            local v = lstg.var
            local life = (lstg.ui.lifeleft or v.lifeleft) / v.maxlife
            local weak_life = v.weak_life / v.maxlife
            local size = 1
            if lstg.tmpvar._is_challenge18 then
                size = size * lstg.tmpvar._is_challenge18
            end
            SetImageState("white", "", 85, 0, 0, 0)
            RenderRect("white", self.x - 20 * size, self.x + 20 * size, self.y - 20 * size, self.y - 25 * size)
            SetImageState("white", "", 85, sp:HSVtoRGB(90 * life, 0.8, 1))
            RenderRect("white", self.x - 19 * size, self.x + (-19 + 38 * life) * size, self.y - 21 * size, self.y - 24 * size)
            if weak_life > 0 then
                SetImageState("white", "", 85, sp:HSVtoRGB(90 * life, 0.8, 0.3))
                RenderRect("white", self.x - 19 + 38 * life, self.x - 19 + 38 * min(1, weak_life + life), self.y - 21, self.y - 24)
            end
        end
    end--血条渲染
    for _, p in ipairs(self.particle) do
        SetImageState("bright", "mul+add", p.alpha, self.colorR, self.colorG, self.colorB)
        Render("bright", p.x, p.y, 0, p.size / 150)
    end
    for _, s in ipairs(self.energy_particle) do
        SetImageState("white", "mul+add", s.alpha / 2, unpack(s.color))
        Render("white", s.x, s.y, s.rot, s.scale * 3 / 8 + sin(s.timer * 8) / 8)
        SetImageState("white", "mul+add", s.alpha, unpack(s.color))
        Render("white", s.x, s.y, s.rot, s.scale * 2 / 8 + sin(s.timer * 8) / 8)
    end

end
function player_class:colli(other)
    self._playersys:doColliBeforeEvent(other)
    self._playersys:colli(other)
    self._playersys:doColliAfterEvent(other)
end
function player_class:findtarget()
    self.target = nil
    self.target2 = nil--新增目标计算
    local maxpri = -1
    local mindist = 999
    local dx, dy, pri, dist
    object.EnemyNontjtDo(function(o)
        if o.colli and o.class.base.take_damage then
            dist = Dist(self, o)
            if o.last_priority then
                dist = 999
            end
            if dist < mindist then
                mindist = dist
                self.target2 = o
            end
            dx = self.x - o.x
            dy = self.y - o.y
            pri = abs(dy) / (abs(dx) + 0.01)
            if pri > maxpri then
                maxpri = pri
                self.target = o
            end
        end
    end)
end

local SetImageState = SetImageState
local Render = Render

---@class grazer
grazer = Class(object)
function grazer:init(player)
    self.layer = LAYER.ENEMY_BULLET_EF + 50
    self.group = GROUP.PLAYER
    self.player = player or lstg.player
    --self.player=lstg.player
    self.aura = 0
    self.aura_d = 0
    self.log_state = self.player.slow
    self._slowTimer = 0
    self._pause = 0
    self.gp = {}
    self.bound = false
    self.grazed = 0
    self.alpha2 = 0
    self.lh = 0
    self.collect_line_alpha = 0
    self._collect_line = player.collect_line
end
function grazer:frame()
    if lstg.tmpvar.lost then
        return
    end
    local p = self.player
    local v = lstg.var
    self.x = p.x
    self.y = p.y
    self.hide = p.hide
    self.a = (p.grazer_colli * p.grazer_colli_factor + p.grazer_colli_offset) * p.grazer_colli_fixed
    self.b = self.a
    if not p.time_stop then
        local slow = p.slow
        if v.forever_show_grazer then
            slow = 1
        end
        if self.log_state ~= slow then
            self.log_state = slow
            self._pause = 30
        end
        if slow == 1 then
            if self._slowTimer < 30 then
                self._slowTimer = self._slowTimer + 1
            end
        else
            self._slowTimer = 0
        end
        if self._pause == 0 then
            self.aura = self.aura + 1.5
        end
        if self._pause > 0 then
            self._pause = self._pause - 1
        end
        local S = cos(90 * self._slowTimer / 30)
        S = S * S
        self.aura_d = 180 * S
        self.lh = self.lh + (slow - 0.5) * 0.3
        if self.lh < 0 then
            self.lh = 0
        end
        if self.lh > 1 then
            self.lh = 1
        end
    end
    local g
    for i = #self.gp, 1, -1 do
        g = self.gp[i]
        g.x = g.x + cos(g.a) * g.v
        g.y = g.y + sin(g.a) * g.v
        if g.timer >= 10 then
            g.alpha = max(0, g.alpha - 16)
        end
        g.v = max(0.1, g.v - 0.03)
        g.rot = g.rot + g.omega
        g.timer = g.timer + 1
        if g.alpha == 0 then
            table.remove(self.gp, i)
        end
    end
    if self.grazed_add then
        if self.grazed < 30 then
            self.grazed = self.grazed + 1
        end
        self.grazed_add = nil
    else
        if self.grazed > 0 then
            self.grazed = self.grazed - 1
        end
    end
    if self.a / 24 > 1.5 then
        self.alpha2 = self.alpha2 + (-self.alpha2 + 1) * 0.1
    else
        self.alpha2 = self.alpha2 + (-self.alpha2) * 0.1
    end
    if v.forever_show_grazer then
        self.collect_line_alpha = self.collect_line_alpha + (-self.collect_line_alpha + 1) * 0.1
        local k = p.collect_line
        if v.greedy_exp then
            k = -280
        end
        self._collect_line = self._collect_line + (-self._collect_line + k) * 0.054
    else
        self.collect_line_alpha = self.collect_line_alpha + (-self.collect_line_alpha) * 0.1

    end

end
function grazer:render()
    local p = self.player
    for _, g in ipairs(self.gp) do
        SetImageState("white", "mul+add", g.alpha, 255, 227, 132)
        Render("white", g.x, g.y, g.rot, 0.25)
        SetImageState("white", "mul+add", g.alpha / 2, 255, 227, 132)
        Render("white", g.x, g.y, g.rot, 0.25)
    end
    local v = lstg.var
    local size = p.A
    if size < 0.5 then
        size = 0.8
    elseif size < 1 then
        size = size * 0.4 + 0.5
    else
        size = 0.9 + (size - 1) * 0.2
    end
    if lstg.tmpvar._is_challenge18 then
        size = size * lstg.tmpvar._is_challenge18
    end
    local img = "player_aura"
    if v.forever_show_grazer and p.slow ~= 1 then
        img = "player_aura2"
    end
    SetImageState(img, "", 192, 255, 255, 255)
    Render(img, self.x, self.y, -self.aura + self.aura_d, self.lh * size / 4)
    SetImageState(img, "", Color(0xC0FFFFFF) * self.lh + Color(0x00FFFFFF) * (1 - self.lh))
    Render(img, self.x, self.y, self.aura, (2 - self.lh) * size / 4)
    local size2 = self.a / 24
    if size2 > 1.5 then
        SetImageState('Grazer2', 'mul+rev', 3.2 * self.grazed * self.alpha2, 255, 255, 255)
        Render('Grazer2', self.x, self.y, -self.ani, 0.25 * (size2 + 2 - 2 * task.SetMode[2](min(12, self.grazed) / 12)))
    end
    if v.forever_show_grazer then
        SetImageState("collect_line", "mul+add", 50 * self.collect_line_alpha, 255, 255, 255)
        Render("collect_line", 0, self._collect_line)
    end

end
function grazer:colli(other, new)
    local w = lstg.weather
    local tvar = lstg.tmpvar
    if tvar.lost then
        return
    end
    if lstg.weather.BiShi then
        return
    end
    if lstg.var.stop_getting then
        return
    end
    if other.group ~= GROUP.ENEMY then
        local p = self.player
        if (not (other._graze) or other._inf_graze) or (other.IsLaser and new) then
            p._playersys:doGrazingBeforeEvent(other)
            local var = lstg.var
            if var.graze_exp > 0 then
                DropExpPoint(var.graze_exp - var.graze_exp_count, other.x, other.y)
                var.graze_exp_count = min(var.graze_exp - 0.0001, var.graze_exp_count + var.graze_exp * 0.00000001)
            end
            var.graze = var.graze + 1
            var.score = var.score + 100
            PlaySound("graze", 0.5, self.x / 120)
            if #self.gp <= 90 then
                table.insert(self.gp, { x = self.x, y = self.y,
                                        a = ran:Float(0, 360), v = ran:Float(4, 5),
                                        alpha = 180, timer = 1, rot = ran:Float(0, 360), omega = ran:Sign() * 5 })
            end
            if not (other._inf_graze) or (other.IsLaser and new) then
                other._graze = true
            end
            p._playersys:doGrazingAfterEvent(other)
            if var.graze >= 1000 then
                mission_lib.GoMission(13)
            end
            if var.graze >= 2000 then
                mission_lib.GoMission(35)
            end
        end
        self.grazed_add = true
    end
end

function lib.getShootParams(dmgindex, class)
    local self = player
    local var = lstg.var
    local bv, lifetime = self.cur_bv, self.cur_brange
    local dmg = lib.GetPlayerDmg() * dmgindex

    local rot = 90
    if var.rotate_shoot_rot then
        rot = self.shoot_rot
        if IsValid(self.target) and self.target.colli and self.target.class.base.take_damage then
            local a = (Angle(self, self.target) - self.shoot_rot) % 360
            if a > 180 then
                a = a - 360
            end
            local da = bv / 15
            if da >= abs(a) then
                self.shoot_rot = Angle(self, self.target)
            else
                self.shoot_rot = self.shoot_rot + sign(a) * da
            end
        end
    end
    local A = var.reverse_shoot and (rot + 180) or rot
    if not class then
        class = player_main_bullet
        if var.imaginary_main_bullet then
            class = player_main_bullet_imaginary
            dmg = dmg * 1.5
        end
    end
    local self_paradox_pro = 0
    if var.self_paradox then
        self_paradox_pro = 0.077
        for i, p in pairs(var.addition) do
            if stg_levelUPlib.AdditionTotalList[i].isTool then
                for _ = 1, p do
                    self_paradox_pro = self_paradox_pro * 1.05
                end
            end
        end
    end
    return bv, lifetime, dmg, A, self_paradox_pro, class
end

function lib.PlayerMiss(p, num, dmg_type)

    local v = lstg.var
    local tvar = lstg.tmpvar
    local sound = v.default_miss_se
    if v.lost then
        return
    end
    local w = lstg.weather
    local mb = tvar.magic_bottle
    local mbtrue
    ---根据子弹判定大小扣血
    local diffindex = { 1, 1, 1.5, 1.5, 1.5, 1.5 }
    local c = num * diffindex[v.difficulty + 1] * stage_lib.GetValue(1, 1.25, 1.5, 10)

    if w.ZuanShiChen then
        c = w.ZuanShiChen_GetLife
        dmg_type = "ZuanShiChen"
    end

    if v.ON_sakura and not mbtrue then
        v.sakura = 0
        v.sakura_bonus = false
        c = 0
    else
        if IsValid(mb) then
            local k = v.maxenergy / 100
            if v.energy >= 70 * k then
                v.energy = v.energy - mb.dev_value * k
                mb.dev_value = min(mb.dev_value + 5, 100 - mb.count * 30)
                c = 0
                sound = "gun00"
                mbtrue = true
            else
                local t = v.energy_stack
                c = c * (1 + t * (0.2 - 0.05 * mb.count))
                if v.forever33 then
                    c = max(0.01, v.maxlife * 0.33) * sign(c)---兼容风絮云
                end
            end
        else
            if v.forever33 then
                c = max(0.01, v.maxlife * 0.33) * sign(c)---兼容风絮云
            end
        end
        if c ~= 0 then
            if w.JieHan and ran:Float(0, 1) < 0.5 then
                c = 0
                sound = nil
                PlaySound("yumedead")
                NewWave(p.x, p.y, 3, 120, 60, 100, 100, 240)
                weather_lib.JieHan_eff(p)
            end
        end--结寒天气
        if c ~= 0 then
            if v.shield_count >= 1 then
                v.shield_count = v.shield_count - 1
                local unit = p.my_shield
                unit.index = 1
                c = 0
                sound = nil
                PlaySound("kappa_shield_off")
            end
        end
        if c ~= 0 then
            if v.ikinokosu_yume > 0 and ran:Float(0, 1) < v.ikinokosu_yume * 0.23 then
                c = 0
                sound = nil
                PlaySound("yumedead")
                NewWave(p.x, p.y, 3, 120, 60, 240, 240, 240)
                stg_levelUPlib.ikinokosu_yume_eff(p)
            end
        end--生之残梦

        local pro_time = 60 + v.protect_time_ex
        local first_protect_flag
        if lstg.wave.miss_count == 0 and v.first_miss_protect then
            first_protect_flag = true
        end
        local MissEvent = function()
            player._playersys:doMissAfterEvent()
            v.miss = v.miss + 1--检测无伤用
            lstg.wave.miss_count = lstg.wave.miss_count + 1--单波miss计数
            if v.hate_add then
                local ss = p.shoot_set.speed
                p.dmg_factor = p.dmg_factor + 0.02
                ss.offset = ss.offset + 0.1
            end
            if first_protect_flag then
                p.protect = max(p.protect, int(pro_time * 4))
                New(stg_levelUPlib.class5.feel_sick, pro_time * 4)
            end
        end
        if v.reflex_arc and c > 0 then
            p.protect = max(p.protect, int(pro_time))
            PlaySound("pldead00_fake")
            New(stg_levelUPlib.class2.reflex_arc_eff)
            New(tasker, function()
                for _ = 1, 120 do
                    if v.lost then
                        break
                    end
                    task.Wait()
                end
                if not v.lost then
                    lib.ReduceLife(c, nil, nil, nil, dmg_type)
                    p.death = 2
                    p.protect = max(p.protect, pro_time)
                    PlaySound("pldead00", 0.38)
                    MissEvent()
                    New(player_death_ef, p.x, p.y)
                end
            end)
        else
            p.protect = max(p.protect, pro_time)
            New(player_death_ef, p.x, p.y)
            if c > 0 then
                p.death = 2
                lib.ReduceLife(c, nil, nil, nil, dmg_type)
                MissEvent()
            else
                lib.AddLife(-c)
            end
            if sound then
                PlaySound(sound, 0.38)
            end
        end
    end
    if c > 0 then
        do
            local addchao = stage_lib.GetChaosAddRange()
            if v.peace_chaos then
                addchao = addchao * 0.66
            end
            if v.paralyzed then
                addchao = addchao * 0.7
            end
            player_lib.AddChaos(addchao)
        end
    end--增加chaos
end

function lib.AddEnergy(n)

    local var = lstg.var
    if var.lost then
        return
    end
    local efficiency = lib.GetEnergyEfficiency()
    n = max(n, 0)
    n = n * max(efficiency, 0)
    local maxenergy = var.maxenergy * var.energy_stack
    if var.energy < maxenergy then
        local lastcount = int(var.energy / var.maxenergy)
        var.energy = min(maxenergy, var.energy + n)
        local nowcount = int(var.energy / var.maxenergy)
        if nowcount > lastcount then
            PlaySound("opshow")
        end
    end
end

function lib.NewEnergySp(x, y, value)
    local p = player
    local par = p.energy_particle
    table.insert(par, { x = x, y = y, rot = ran:Float(0, 360), omega = ran:Sign(), color = { 200, 200, 200 }, alpha = 45, scale = 0, timer = 0 })
    task.New(par[#par], function()
        local self = task.GetSelf()
        local v, a = ran:Float(1, 5), ran:Float(0, 360)
        for i = 29, 0, -1 do
            self.scale = sin(90 - i * 3) * 1.6
            self.x = self.x + cos(a) * v * sin(i * 3)
            self.y = self.y + sin(a) * v * sin(i * 3)
            coroutine.yield()
        end
        task.Wait(ran:Int(1, 30))
        local t = int(Dist(self.x, self.y, p) / 300 * 60)
        task.MoveToTarget(p, t, 1)
        PlaySound("item00")
        activeItem_lib.AddActiveChargeByPT(value)
        lib.AddEnergy(value)
        if lstg.var.native_faith then
            if lstg.var.energy == lstg.var.maxenergy * lstg.var.energy_stack then
                player_lib.AddLife(value * 0.08)
            end
        end
        self.color[1], self.color[2], self.color[3] = p.colorR, p.colorG, p.colorB
        self.alpha = 20
        v, a = ran:Float(2, 5), ran:Float(0, 360)
        local px, py = p.x, p.y
        for i = 59, 0, -1 do
            self.scale = 1.6 - sin(90 - i * 1.5) * 0.6
            self.x = self.x + cos(a) * v * sin(i * 1.5)
            self.y = self.y + sin(a) * v * sin(i * 1.5)
            coroutine.yield()
        end
        task.New(self, function()
            for i = 59, 0, -1 do
                self.scale = sin(i * 1.5)
                coroutine.yield()
            end
        end)
        task.MoveToForce(px, py, 60, 1)
        self.cao = true
    end)
end

function lib.SetEnergy(maxe, stacks)
    local var = lstg.var
    if var.lost then
        return
    end
    stacks = stacks or var.energy_stack
    maxe = maxe or var.maxenergy
    var.maxenergy = maxe
    var.energy_stack = stacks
    var.energy = min(var.energy, var.maxenergy * var.energy_stack)
end
---@param LossType boolean@是否是流失类型的减少生命
---减少生命
function lib.ReduceLife(n, LossType, noGanYao, minv, dmg_type)
    local w = lstg.weather
    local a = lstg.active
    local v = lstg.var
    local flag = true
    if v.lost then
        return 0
    end

    if LossType then
        flag = not player.StopLoss
    end
    if w.GanYao and not LossType and not noGanYao then
        weather_lib.GanYaoRewind()
        return 0
    else
        if flag then
            local no_dmg = dmg_type == "kokoro_musubu"
            if v.paralyzed and not no_dmg then
                n = n * 0.75
            end
            if v.dmg_reduction and not no_dmg then
                n = n - 1
                n = n / 2
                lib.InsertDmgTypeCache("moonDmgReduction")
            end
            n = max(0, n)
            if not LossType and not no_dmg then
                if v.cowrie_shell then
                    n = n * 1.5
                    v.weak_life = n
                    v.maxweak_life = n
                    lib.InsertDmgTypeCache("CowrieShell")
                end--燕的子安贝

            end
            if v.life_dead and v.lifeleft - n <= 0 then
                n = 0
                New(stg_levelUPlib.class2.life_dead_eff)
                PlaySound("hyz_timestop0")
                lib.AddLife(v.maxlife / 2)
                lib.AddMaxLife(-v.maxlife / 2)
                v.life_dead = false
            end--生与死的境界
            if v.lifeleft - n <= 0 and not no_dmg then
                if LossType == "ScaringMask" then
                    ext.achievement:get(120)
                elseif LossType == "QiuLaoHu" then
                    ext.achievement:get(50)
                end
                if dmg_type == "Lightning" then
                    ext.achievement:get(62)
                end
            end
            lib.InsertDmgTypeCache(LossType or dmg_type)
            if n > 0 then
                minv = minv or -0.1
                if w.QingLang then
                    minv = 0.01--不会死亡
                end
                v.lifeleft = clamp(v.lifeleft - n, minv)
                if v.lifelife_exchange and lstg.tmpvar.lifelife_exchangeCD == 0 then
                    object.EnemyNontjtDo(function(e)
                        if e.class.base.take_damage then
                            e.class.base.take_damage(e, lib.GetPlayerDmg() * 0.5)
                        end
                    end)
                    lstg.tmpvar.lifelife_exchangeCD = 45
                end

                if v.hp_to_exp then
                    v.hp_to_exp_lost_hp = v.hp_to_exp_lost_hp + n
                    local count = 0
                    local maxf = max(v.maxlife, 0.1) * 0.0265
                    while v.hp_to_exp_lost_hp >= maxf do
                        v.hp_to_exp_lost_hp = v.hp_to_exp_lost_hp - maxf
                        count = count + 1
                    end
                    item.dropItem(item.drop_exp, count, player.x, player.y + 45)
                end
                if v._season_system then
                    if w.XinYang and not no_dmg then
                        lib.AddMaxLife(n * 0.25)
                    end
                end
            end
            return n
        end
    end
end
---增加生命
function lib.AddLife(n, no_addmax)
    if lstg.var.lifeleft <= 0 then
        return 0
    end--没血了就直接死了谁让你回血了
    if not lstg.tmpvar.bird_resurrecting and not lstg.tmpvar.rewind_resurrecting then
        n = max(0, n)
        local v = lstg.var
        local w = lstg.weather
        if v.lost then
            return 0
        end

        if v.green_wish ~= 0 and not no_addmax then
            if v.lifeleft + n > v.maxlife then
                lib.AddMaxLife((0.2 + v.green_wish * 0.1) * (v.lifeleft + n - v.maxlife))
            end
        end
        if v._season_system then
            if w.LiDong then
                lib.AddMaxLife(n * 0.12)
                n = 0
            end
            if w.XinYang then
                n = 0--不回血
            end
            if w.YunTian then
                lib.AddEnergy(n / v.maxlife * v.maxenergy)
            end
        end
        v.lifeleft = min(v.maxlife, v.lifeleft + n)
        return n--返回真正获得的生命值
    end
end

---增加(减少)生命上限
function lib.AddMaxLife(n)
    n = n or 0
    local v = lstg.var
    if v.lost then
        return
    end
    local w = lstg.weather
    if v._season_system then
        if w.TianQiYu then
            n = 0--不增加上限
        end
    end
    v.maxlife = max(0.01, v.maxlife + n)
    if v.glass_bon then
        v.maxlife = min(30, v.maxlife)
    end
    if v.maxlife > 100 then
        ext.achievement:get(72)
    elseif v.maxlife == 0.01 then
        ext.achievement:get(74)
    end
    v.lifeleft = min(v.maxlife, v.lifeleft)
end

---增加(减少)混沌值
function lib.AddChaos(n)
    local var = lstg.var
    if var.lost then
        return
    end
    n = n * var.chaos_factor
    var._off_chaos = var._off_chaos + n
    var.chaos = max(var.chaos + n, 0)
    if var.chaos >= 250 then
        mission_lib.GoMission(91)
    end
    if var.chaos >= 200 then
        mission_lib.GoMission(12)
    end
    if var.chaos >= 150 then
        mission_lib.GoMission(17)
    end
    if var.balance_chaos then
        if n >= 0 then
            lib.AddLife(n * 0.5)
        else
            lib.ReduceLife(-n * 0.5)
        end
    end
end

function lib.AddPlayerCollisize(offset, factor, fixed)
    mission_lib.GoMission(3)
    local p = player
    if offset then
        p.collisize_offset = p.collisize_offset + offset
    end
    if factor then
        p.collisize_factor = p.collisize_factor + factor
    end
    if fixed then
        p.collisize_fixed = p.collisize_fixed + fixed
    end

end


-------尽量少用的函数
----------------------------------------------

function lib.GetPlayerDmg(p)
    p = p or player
    if not p then
        return
    end
    local v = lstg.var
    local tvar = lstg.tmpvar
    local crazy_torch_index = 0.35
    if v.crazy_torch == 3 then
        crazy_torch_index = 0.5
    end
    local offset = 0
    offset = offset + int(v.crazy_torch_n) * crazy_torch_index

    local factor = p.dmg_factor
    if IsValid(tvar.strength_aura) and IsValid(p) then
        local sa = tvar.strength_aura
        if Dist(p, sa) < sa.r then
            factor = factor + 0.5
        end
    end
    if IsValid(tvar.wave_bullet_shooter) and tvar.wave_bullet_shooter.open and IsValid(p) then
        offset = offset + 0.5
    end
    if tvar.AyaSkill1 then
        offset = offset + int(v.maxenergy * v.energy_stack - v.energy) * 0.035
    end
    if v.blood_magic then
        for _, t in ipairs(stg_levelUPlib.ListByTags.sacrifice) do
            if v.addition[t.id] then
                offset = offset + v.addition[t.id] * 0.25
            end
        end
    end
    return max((p.dmg * factor + p.dmg_offset + offset) * p.dmg_fixed, 0.01)
end

function lib.GetPlayerSpeed(p)
    local w = lstg.weather
    local v = lstg.var
    local tvar = lstg.tmpvar
    p = p or player
    if p.ice_frozen then
        ext.achievement:get(75)
        return 0, 0

    end
    local hfactor = p.hspeed_factor
    local lfactor = p.lspeed_factor
    if IsValid(tvar.strength_aura) and IsValid(p) then
        local sa = lstg.tmpvar.strength_aura
        if Dist(p, sa) < sa.r then
            hfactor = hfactor - 0.15
            lfactor = lfactor - 0.15
        end
    end
    local hspeed = (p.hspeed * hfactor + p.hspeed_offset) * p.hspeed_fixed
    local lspeed = (p.lspeed * lfactor + p.lspeed_offset) * p.lspeed_fixed
    local index = 1
    for _ = 1, w.ShuangJiang_speed_low do
        index = index * 0.75
    end
    index = index * w.playerSpeed_index
    if tvar.playerSpeed_index then
        index = index * tvar.playerSpeed_index
        tvar.playerSpeed_index = nil
    end
    hspeed = max(hspeed, 0.01, v.stable_hspeed)
    lspeed = max(lspeed, 0.01, v.stable_lspeed)
    if hspeed * index == 0.01 then
        ext.achievement:get(75)
    end
    if lstg.tmpvar.SakuyaSkill1 then
        index = index / ext.GetFakeFPS()
    end
    return hspeed * index, lspeed * index
end

function lib.GetPlayerStarLevel(num)
    local pclass = player_list[lstg.var.player_select]
    return playerdata[pclass.name].choose_skill[num]
end

function lib.GetPlayerCollisize(p)
    p = p or player
    local offset = p.collisize_offset
    local tvar = lstg.tmpvar
    local v = lstg.var
    if IsValid(tvar.wave_bullet_shooter) and tvar.wave_bullet_shooter.open and IsValid(p) then
        offset = offset - 0.1
    end
    if v.forever_show_grazer and v.maxlife == v.lifeleft then
        offset = offset - 0.05
    end
    if v.beishui_effect then
        if IsValid(p) and p.dy < 0 then
            offset = offset - 0.2
        end
    end
    local c = (p.collisize * p.collisize_factor + offset) * p.collisize_fixed
    c = max(0.01, c)
    if c == 0.01 then
        ext.achievement:get(76)
    end
    return c
end

---依次返回射速，弹速，射程
function lib.GetShootAttribute(p)
    p = p or player
    local v = lstg.var
    local tvar = lstg.tmpvar
    local s_set = p.shoot_set
    local speed_set = s_set.speed
    local bv_set = s_set.bvelocity
    local range_set = s_set.range
    local ssfac = speed_set.factor
    if v.doppler_effect and p.dy and p.dy > 0 then
        ssfac = ssfac + sqrt(p.dy) * 0.1
    end
    if v.attention_attack_time >= 90 then
        ssfac = ssfac + 0.5
    end
    local sspeed = max(0.5, (speed_set.value * ssfac + speed_set.offset) * speed_set.fixed)
    local bv = max(0.5, (bv_set.value * bv_set.factor + bv_set.offset) * bv_set.fixed)
    local lifetime = max(1, (range_set.value * range_set.factor + range_set.offset) * range_set.fixed)
    if tvar.AyaSkill3 then
        sspeed = sspeed + (v.addition_count[3] or 0) * 4
    end

    return sspeed, bv, lifetime
end

function lib.GetEnergyEfficiency()
    local var = lstg.var
    local tvar = lstg.tmpvar
    local efficiency = var.energy_efficiency
    if tvar.MarisaSkill2 and var.wave_hard then
        efficiency = efficiency + 0.5
    end
    return efficiency
end

function lib.GetEXPfactor()
    local v = lstg.var
    local nm = v.exp_factor
    if v.domino_effect then
        nm = nm + v.level / 50
    end
    local w = lstg.world
    if v.booming_earth and player.y <= w.pb + 16 then
        nm = nm + 0.3
    end
    if nm >= 2 then
        mission_lib.GoMission(64)
    end
    return nm
end

function lib.UpdateDmgTypeCache()
    local v = lstg.var
    local threshold = v.save_dmg_maxtime
    for i = #v.dmg_type_cache, 1, -1 do
        local d = v.dmg_type_cache[i]
        d[2] = d[2] + 1
        if d[2] >= threshold then
            table.remove(v.dmg_type_cache, i)
        end
    end
end
function lib.InsertDmgTypeCache(type)
    table.insert(lstg.var.dmg_type_cache, { type, 0 })
end

local spell_class = plus.Class()
lib.spell_class = spell_class
function spell_class:getName()

end
function spell_class:init()

end
function spell_class:frame()

end
function spell_class:spell()

end
function spell_class:render()

end

---一些必须要存储的player的数据
lib.__must_save_data = {
    "x", "y",
    "dmg", "dmg_factor", "dmg_offset", "dmg_fixed",
    "hspeed", "lspeed",
    "hspeed_factor", "lspeed_factor",
    "hspeed_offset", "lspeed_offset",
    "hspeed_fixed", "lspeed_fixed",
    "collisize", "collisize_factor", "collisize_offset", "collisize_fixed",
    "grazer_colli", "grazer_colli_factor", "grazer_colli_offset", "grazer_colli_fixed",
    "shoot_set", "shoot_angle_off"
}
lib._last_cache_player = {}
lib._last_cache_var = {}
lib._last_cache_weather = {}
lib._last_cache_active_data = {}
lib._cache_player = {}
lib._cache_var = {}
lib._cache_weather = {}
lib._cache_active_data = {}
function lib.PlayerInit()
    local v = lstg.var
    v.player_bullet_scale = 0.5
    v.player_bullet_scale_factor = 1
    v.player_bullet_scale_offset = 0
    v.player_bullet_scale_fixed = 1
    lib.ResetPlayerBulletImg()
    lib.LevelInit()
    lib.ActiveInit()
    lib.PathInit()
    lib.OtherInit()
    lib.WeatherInit()
    lib.WaveInit()

    stg_levelUPlib.InitAddition(lstg.tmpvar._fake_init)
    activeItem_lib.InitActive(lstg.tmpvar._fake_init)
    lstg.tmpvar._fake_init = nil
end

function lib.LevelInit()
    local var = lstg.var
    -----------------
    var.othercondition = function()
        return true
    end
    var.exp_drop_factor = 1.25
    var.challenge_addchaos = nil
    var.FINAL_HARD_BOSS = true
    var.miss = 0
    var.level = 1
    var.level_exp_index = 9
    var.exp_line_func = nil
    var.now_exp = 0
    var.chaos = 0
    var.addition = {}--加成记录
    var.addition_count = {}--加成类别数量记录
    var.addition_order = {}--加成顺序记录
    var.addition_pos = {}--加成id映射为加成顺序
    var.wave = 1--波数写为1？
    var.wave_luck = false
    var.wave_hard = false
    var.wave_boss = false--3个标签
    var.maxwave = nil
    var.next_wave_id = nil
    var.now_wave_id = nil
    var.enemyHP_index = 1--怪物血量倍率，实时更新
    var.level_upOption = 3--3选1
    var.level_offset = 0--和升级有关的，隐藏数据
    var.drop_exp_point = 0--计算经验点的小数部分
    var.maxenergy = 100--所需符卡能量
    var.energy = 100--初始符卡能量
    var.energy_stack = 1--符卡储存上限（默认为1个）
    var.energy_efficiency = 1--符卡充能效率
    var.exp_factor = 1--获得经验值的倍率
    var.heal_factor = 0--击败敌人回血的倍率
    var.graze_exp = 0--擦弹获得经验值的数量，最高为1
    var.graze_exp_count = 0--缓存
    var.goldenbody = false--金刚不灭之身
    var.forever33 = false--永无伤痛之心
    var.blood_magic = false--blood magic
    var.delete_bullet = 0--伊吹大山岚,使弹幕失去判定概率
    var.kokoro_musubu = false--心连心
    var.life_dead = false--生与死的境界
    var.reverse_shoot = false--天地有用
    var.accumulate_exp = 0--积善成德
    var.ON_sakura = false--樱花结界相关
    var.sakura = 0--樱花结界相关
    var.randomLevelUp = false--随机升级
    var.chaos_factor = 1--加混沌值倍率
    var.green_wish = 0--绿沐愿
    var.blue_wish = 0--蓝沐愿
    var.red_wish = 0--红沐愿
    var.crazy_torch = 0--疯狂的火炬
    var.crazy_torch_n = 0
    var.crazy_torch_t = 0
    var.todo_graze_check = nil--TㅇDㅇ清单
    var.todo_graze = 0
    var.nue_special_bullet = false--正体不明的飞仓
    var.greedy_exp = false--贪欲的敛财
    var.shuttle_main_bullet = false--便携式后户
    var.trail_main_bullet = false--引诱式黄泉
    var.bound_main_bullet = false--幽谷回响
    var.fire_bird_resurrection = false--不死尾羽
    var.friendly_ball_huge = false--颂德之玉
    var.lifelife_exchange = false--以血换血
    var.bomb_healing = nil--开大回血（硝酸甘油）
    var.levelup_healing = false--升级回血（经验血袋）
    var.borderless_moving = false--无边界移动（月与海的传送门）
    var.steal_sun = false--偷天换日
    var.rewindable = false--时间回溯
    var.rewind_CD = false--时间回溯的CD
    var.hp_to_exp = false--EXHP
    var.hp_to_exp_lost_hp = 0--EXHP计算流失生命值
    var.dmg_reduction = false--伤害减免（阴晴圆缺）
    var.chip_addmaxlife = false--以命汲命
    var.kinematics = false--运动学定律
    var.posion_dot = false--甘美之毒
    var.perfect_spread = 0--完美散华
    var.snake_main_bullet = false--风神的祝歌
    var.double_BiYi = false--双蛋黄
    var.mangekyou = false--万华镜
    var.resurrect9 = 0--九代稗谷
    var.active_star = false--活力的繁星
    var.quantum_bullet = false--量子弹幕
    var.del_bullet_with_enemy = false--幻无垢
    var.dmgfactor_withlifeleft = 0--饥饿的狼犬
    var.imaginary_main_bullet = false--幻想烟花
    var.ikinokosu_yume = 0--生之残梦
    var.shield_count = 0--盾量（统一管理了）（荷取牌能量盾什么的
    var.cowrie_shell = false--燕的子安贝
    var.weak_life = 0
    var.maxweak_life = 0
    var.protect_lotus = false--护守之莲
    var.lotus_record_b = 0--记录清弹个数
    var.lotus_open = false
    var.buddhist_diamond = false--佛的御石钵
    var.protect_time_ex = 0--额外增加的无敌时间
    var.reflex_arc = false--加长反射弧
    var.self_paradox = false--自指悖论
    var.return_bullet = false--具现化记忆
    var.scarlet_focus = 0--绯红的专注
    var.scarlet_record = 0--记录开火时长
    var.scarlet_count = 1
    var.philosopher_stone = false--贤者之石
    var.philosopher_stone_n = 0--收集经验点个数
    var.life_boom = 0--生命爆炸
    var.peace_chaos = false--平安喜乐
    var.neutron_star = false--中子星
    var.violent_eater = false--极欲的暴食
    var.violent_eater_n = 0
    var.violent_eater_CD = 0
    var.glass_bon = false--玻璃大炮
    var.red_main_bullet = false--寻求者
    var.blue_main_bullet = false--喜爱者
    var.blue_main_bullet_count = 0
    var.green_main_bullet = false--渴望者
    var.powerful_point = false
    var.cyoltose = false--封之术法
    var.forever_scarlet = false--永远的满月
    var.infinite_nightmare = false--永恒的回音
    var.MAX_M = false--MAX M
    var.behind_main_bullet = false--后撤的大人
    var.rotate_shoot_rot = false--安产大炮
    var.stop_0_tool = false--休止符
    var.is_mimichan = false--Mimichan
    var.rotate_star = false--小小星球
    local nums = { 1, 2, 3, 4, 5, 6, 7 }
    var.seven_flowers = {}--深海七花
    for _ = 1, 7 do
        table.insert(var.seven_flowers, table.remove(nums, ran:Int(1, #nums)))
    end
    var.seven_flower_BiYi_list = nil
    var.seven_flower_QingHai_list = nil
    var.seven_flower_Broken_list = nil
    var.nue_main_bullet = false--符札化络合物
    var.game_killer = false--Game Killer
    var.chip_adddmg = false--团子生命力
    var.cross_laser = 0--死亡十字
    var.stable_hspeed = 0.01--行稳致远
    var.stable_lspeed = 0.01--行稳致远
    var.elec_fish = 0--电子木鱼
    var.fierce_place = 0--无情之地
    var.copy_center = false--复制中心
    var.pierce_main_bullet = false--半分幻魂魄
    var.gunpowder_main_bullet = false--核燃火药
    var.following_main_bullet = false--槐安通路
    var.baby_dmg_factor = 1--宝宝伤害倍率
    var.forever_show_grazer = false--经纬仪
    var.first_miss_protect = false--递质不耐受
    var.getCard_dec_chaos = false--八十亿劫渡法
    var.balance_chaos = false--灾衡之天秤
    var.link_main_bullet = false--逢天宇宙仪
    var.haniwa = 0--埴轮
    var.sakuyaFPS = 60--咲夜的FPS
    var.doppler_effect = false--多普勒效应
    var.beishui_effect = false--背水阵
    var.omg_bullet = false--特大头条
    var.monkey_king = false--越来越大的如意棒
    var.attention_attack_time = 0--螺光步持续时间
    var.levelup_get_Q3 = false--一脉单传的暗杀拳
    var.domino_effect = false--多米诺效应
    var.hate_add = false--亘古的恨意
    var.booming_earth = false--大地的富饶
    var.native_faith = false--土著的信仰
    var.paralyzed = false--麻木
    var.damask_effect = false--绮罗大结界
    var.lucky_cat = false--幸运的招财猫
    var.meet_lucky_wave = 0--遇到幸运的波
    var.silent_fire = false--寂火
end
function lib.ActiveInit()
    local var = lstg.var
    var.active_item = {}--当前拥有的主动道具
    var.max_active_item = 1--最大主动道具数量
    var.UI_active_item = {}--UI上显示的主动道具
    var.active_charge_efficiency = 1--主动道具充能效率
end
function lib.PathInit()
    local var = lstg.var
    ---路径模式
    var._pathlike = false
    var._off_chaos = 0
    var.frame_counting = true--一些每帧事件的计时
    var.stop_getting = false--禁止擦弹、ppt等
    var.path_view = 7
    var.now_path_x, var.now_path_y = 1, 1
end
function lib.OtherInit()
    local var = lstg.var

    local data = stagedata
    var.player_select = data.player_pos
    var.spell_select = data.spell_pos[data.player_pos]
    if not stage.current_stage.is_challenge and not stage.current_stage.is_practice then
        var.difficulty = data.DiffSelection[var.scene_id] - 1--错个位
        lstg.tmpvar.hiscore = stagedata.hiscore[var.scene_id][var.difficulty]
    end
    lstg.tmpvar.playerSpeed_index = nil

    ---季节系统
    var._season_system = false
    ----禁止低速
    var.forbid_slow = false
    -----------------分数数据
    --var.lifeleft = 100
    --var.maxlife = 100

    var.graze = 0
    var.score = 0
    var.score_tmp = 0
    var.score_draw = 0
    -----------------其他数据
    var.default_miss_se = "pldead00"
    var.dmg_type_cache = {}
    var.save_dmg_maxtime = 180
    --var.gray = false
    var.hp_render = true
    var.init_player_data = true
    var.CYFPS = 60
    var.lost = false
    var.stop_shoot = false
    var.level_up_func = nil
    --计量wave里的obj高峰
    lstg.tmpvar.objcount = {}
    lstg.tmpvar.fileexist = {}
    ext.RestartBlack = 0
    lstg.tmpvar.spell_count = 0
    lstg.tmpvar.baby_stack = {}
end
function lib.WeatherInit()
    local w = lstg.weather
    for t in pairs(w) do
        w[t] = nil
    end--直接重制一些变量的开关
    w.total_weather = {}
    w.season_last = { 5, 5, 5, 5, 5 }--季节持续时间
    w.season_wave = 0
    w.now_season = 0
    w.now_weather = 0
    w.enemyHP_offset = 0
    w.enemyHP_index = 1
    w.playerSpeed_index = 1
    w.bullet_init_func = function()

    end
    w.enemy_kill_func = function()
    end
    w.selected_season = { false, false, false, false }
    w.selected_ptr = 0
    w.weather_order = { 1, 2, 3, 4 }
    w.next_weather = nil
    w.next_season = nil
    w.ShuangJiang_speed_low = 0
    w.ZuanShiChen_GetLife = nil
    w.MustSeason5 = false
    w.TwiceXiangRui = false
end
function lib.WaveInit()
    local w = lstg.wave
    for t in pairs(w) do
        w[t] = nil
    end--直接重制所有变量的开关
    w.level_up_count = 0
    w.get_pearl = 0
    w.miss_count = 0
end


----------------------------------

---端点式列表，然后取值，是一段段一次函数
function lib.GetAttributeByLevel(list, level)
    ---@type p_attributeList
    local result = {}

    local k_list = {}
    local k1, k2 = 0, 0--level所处位置
    for i in pairs(list) do
        table.insert(k_list, i)
    end
    table.sort(k_list)
    for i = 1, #k_list - 1 do
        if level >= k_list[i] and level <= k_list[i + 1] then
            k1 = k_list[i]
            k2 = k_list[i + 1]
            break
        end
    end
    for p in pairs(list[1]) do
        result[p] = list[k1][p] + (list[k2][p] - list[k1][p]) / (k2 - k1) * (level - k1)
        -- result[p] = int(result[p] * 10) / 10--默认保留两位小数
    end
    return result
end
function lib.CreatePlayerUnit(id, name, display_name, nickname, picture, renderx, rendery, renderscale, class, unlock_way, sdescribe, R, G, B)
    local init_unlock_c = false
    if unlock_way == 0 then
        init_unlock_c = 0
        unlock_way = nil
    end
    ---@class PlayerUnit
    local unit = {
        id = id, name = name, display_name = display_name, nickname = nickname,
        picture = picture, renderx = renderx, rendery = rendery, renderscale = renderscale,
        spells = {}, init_unlock_c = init_unlock_c, skill_describe = sdescribe, R = R, G = G, B = B,
        unlock_way = unlock_way,
        class = class
    }
    player_list[id] = unit
    player_list_by_name[name] = unit
    --数据初始化
    if not playerdata[name] then
        local data = {}
        ---解锁技能
        ---如果是false，就是角色本身都没解锁
        data.unlock_c = init_unlock_c or false
        data.choose_skill = { false, false, false }
        playerdata[name] = data
    end
    stagedata.spell_pos[id] = stagedata.spell_pos[id] or 1
    return unit
end
function lib.CreatePlayerAttributeList(hp, dmg, collisize, hspeed, lspeed, Sspeed, Sbvelocity, Srange)
    ---@class p_attributeList
    local list = {
        hp = hp, dmg = dmg, collisize = collisize,
        hspeed = hspeed, lspeed = lspeed,
        shoot_set_speed = Sspeed, shoot_set_bvelocity = Sbvelocity, shoot_set_range = Srange
    }
    return list
end
function lib.SetPlayerAttribute(self, player_listID)
    local p = player_list[player_listID]
    local v = lstg.var
    ---@type p_attributeList
    local attribute = p.class.attribute
    v.lifeleft = attribute.hp
    v.maxlife = attribute.hp
    self.colorR, self.colorG, self.colorB = p.R, p.G, p.B
    self.name = p.name
    --攻击力
    self.dmg = attribute.dmg
    self.dmg_factor = 1
    self.dmg_offset = 0
    self.dmg_fixed = 1
    --速度
    self.hspeed = attribute.hspeed
    self.lspeed = attribute.lspeed
    self.hspeed_factor = 1
    self.lspeed_factor = 1
    self.hspeed_offset = 0
    self.lspeed_offset = 0
    self.hspeed_fixed = 1
    self.lspeed_fixed = 1
    --碰撞大小
    self.collisize = attribute.collisize
    self.collisize_factor = 1
    self.collisize_offset = 0
    self.collisize_fixed = 1
    self.A = (self.collisize * self.collisize_factor + self.collisize_offset) * self.collisize_fixed
    self.B = self.A
    --擦弹范围大小
    self.grazer_colli = 24
    self.grazer_colli_factor = 1
    self.grazer_colli_offset = 0
    self.grazer_colli_fixed = 1
    --攻击设置
    local shoot_set = {
        --射速(每秒发射几颗)
        speed = {
            value = attribute.shoot_set_speed,
            factor = 1, offset = 0, fixed = 1
        },
        --弹速
        bvelocity = {
            value = attribute.shoot_set_bvelocity,
            factor = 1, offset = 0, fixed = 1
        },
        --射程(子弹存在几帧)
        range = {
            value = attribute.shoot_set_range,
            factor = 1, offset = 0, fixed = 1
        }
    }
    self.shoot_set = shoot_set
    self.shoot_angle_off = 0

end

---@param belonging PlayerUnit
function lib.CreateSpellUnit(id, belonging, display_name, picture, attribute_list, introduce)
    ---@class SpellUnit
    local unit = {
        id = id, belonging = belonging, display_name = display_name, picture = picture,
        attribute_list = attribute_list,
        introduce = introduce
    }
    belonging.spells[id] = unit
    return unit
end
function lib.GetSpellAttribute(player_listID, spell_ID)
    local p = player_list[player_listID]
    local sp = p.spells[spell_ID]
    local attribute = sp.attribute_list
    return attribute
end

function lib.ResetPlayerBulletImg()
    lstg.var.player_bullet_img = {
        [0] = "player_bullet", --初始图像
        [1] = nil, --自机自带的图像
    }
end

---pos越大优先级越大
function lib.SetPlayerBulletImg(pos, img)
    lstg.var.player_bullet_img[pos] = img or nil
end
function lib.GetPlayerBulletImg()
    local m = 0
    local rimg = "player_bullet"
    for i, p in pairs(lstg.var.player_bullet_img) do
        if i >= m then
            m = i
            rimg = p
        end
    end
    return rimg
end

function lib.GetPlayerBulletSize()
    local v = lstg.var
    local value = (v.player_bullet_scale * v.player_bullet_scale_factor + v.player_bullet_scale_offset) * v.player_bullet_scale_fixed
    if v.omg_bullet then
        value = math.log(player.damage + 0.39, 12.921)
    end
    if v.monkey_king then
        value = value * max(1,math.log(v.wave ^ 1.15 + 6.9, 6.9))
    end
    if lstg.tmpvar._is_challenge18 then
        value = value * lstg.tmpvar._is_challenge18
    end
    return max(value, 0.15)
end

player_death_ef = Class(object)
function player_death_ef:init(x, y)
    self.x = x
    self.y = y
    self.img = "player_death_ef"
    self.hscale = 0.7
    self.vscale = 0.7
    self.layer = LAYER.PLAYER + 50
end
function player_death_ef:frame()
    if self.timer == 4 then
        ParticleStop(self)
    end
    if self.timer == 60 then
        object.Del(self)
    end
end

player_bullet_straight = Class(object)
function player_bullet_straight:init(img, x, y, v, angle, dmg)
    self.group = GROUP.PLAYER_BULLET
    self.layer = LAYER.PLAYER_BULLET
    self.img = img
    self.x = x
    self.y = y
    self.rot = angle
    self.vx = v * cos(angle)
    self.vy = v * sin(angle)
    self.dmg = dmg
    if self.a ~= self.b then
        self.rect = true
    end
end

player_bullet_trail = Class(object)
function player_bullet_trail:init(img, x, y, v, angle, target, trail, dmg)
    self.group = GROUP.PLAYER_BULLET
    self.layer = LAYER.PLAYER_BULLET
    self.img = img
    self.x = x
    self.y = y
    self.rot = angle
    self.v = v
    self.target = target
    self.trail = trail
    self.dmg = dmg
end
function player_bullet_trail:frame()
    if IsValid(self.target) and self.target.colli and self.target.class.base.take_damage then
        local a = (Angle(self, self.target) - self.rot) % 360
        if a > 180 then
            a = a - 360
        end
        local da = self.trail / (Dist(self, self.target) + 1)
        if da >= abs(a) then
            self.rot = Angle(self, self.target)
        else
            self.rot = self.rot + sign(a) * da
        end
    end
    self.vx = self.v * cos(self.rot)
    self.vy = self.v * sin(self.rot)
end

player_main_bullet_ef = Class(object)
function player_main_bullet_ef:init(x, y, rot, v, hscale, vscale, alpha, timeout, r, g, b)
    self.x = x
    self.y = y
    self.rot = rot
    self.vx = v * cos(rot)
    self.vy = v * sin(rot)
    self.hscale, self.vscale = hscale, vscale
    self.alpha = alpha
    self.img = lib.GetPlayerBulletImg()
    self.layer = LAYER.PLAYER_BULLET + 50
    self.time_out = timeout
    local j = 1
    if not self.time_out then
        local qual = setting.rdQual
        for _ = 1, int(self.alpha * 3) do
            if #player.particle < 100 + qual * 20 then
                j = j + qual / 5
                if j > 1 then
                    local _a = ran:Float(0, 360)
                    local _v = ran:Float(4, 8)
                    table.insert(player.particle, {
                        x = self.x, y = self.y, size = ran:Float(6, 15),
                        vx = cos(_a) * _v, vy = sin(_a) * _v,
                        alpha = ran:Float(120, 170), timer = 0,
                    })
                    j = j - 1
                end
            end
        end
    end
    self.R, self.G, self.B = r, g, b
end
function player_main_bullet_ef:frame()
    if self.timer == 7 then
        Del(self)
    end
end
function player_main_bullet_ef:render()
    local A = self.alpha * (1 - self.timer / 8) * 0.8
    --SetImageState(self.img, "mul+add", A * 100, self._r, self._g, self._b)
    -- Render(self.img, self.x, self.y, 0, self.hscale * 0.7, self.vscale * 0.7)
    SetImageState(self.img, "", A * 200, 255, 255, 255)
    DefaultRenderFunc(self)
end

local Nue_bullet_event = {
    function(self)
        object.SetSizeColli(self, ran:Float(0.5, 2.5))
    end,
    function(self)
        self.dmg = self.dmg * ran:Float(0.1, 3)
    end,
    function(self)
        local v = self.real_v * ran:Float(-0.25, 1.6)
        self.real_v = v
        if not lstg.var.mimichan then
            self.v = v
            object.SetV(self, self.v, self.rot)
        end
    end,
    function(self)
        self.lifetime = int(self.lifetime * ran:Float(0.5, 10))
    end,
    function(self)
        self.R = ran:Float(114, 255)
        self.G = ran:Float(114, 255)
        self.B = ran:Float(114, 255)
    end,
}
local RGB_cache = {
    { true, false, false },
    { false, true, false },
    { false, false, true },
}
local main_bullet_table = {}
player_lib.main_bullet_table = main_bullet_table
local main_bullet_count = 0

local function blueDrop(self)
    if self.is_blue then
        local v = lstg.var
        local koff = 42 / max(100, 1600 - #main_bullet_table)
        if #main_bullet_table <= 150 then
            koff = 0
        end
        local s = clamp(self.a / 12 - koff - v.blue_main_bullet_count, 0.00001, 1)
        DropExpPoint(s, self.x, self.y)
        v.blue_main_bullet_count = v.blue_main_bullet_count + s * 10e-7
    end
end
player_main_bullet = Class(player_bullet_straight)

local main_bullet_effect_list = {
    [0] = 1,
    [1] = 1,
    [2] = function(self)
        self.img = "mimichan_bullet"
        SetImageScale("mimichan_bullet", lib.GetPlayerBulletSize() / 4)
    end,
    [3] = 1,
    [4] = 1,
    [5] = 1,
    [6] = 1,
    [7] = 1,
    [8] = 1,
    [9] = 1,
    [10] = 1,
    [11] = 1,
    [12] = 1,
    [13] = 1,
    [14] = 1,
    [15] = 1,
    [16] = 1,
    [17] = 1,
    [18] = 1,
    [19] = function(self)
        if not lstg.var.imaginary_main_bullet then
            self.class = player_main_bullet_imaginary
            self.dmg = self.dmg * 1.5
            self._dmg = self.dmg
            object.SetSizeColli(self, 1.6)
            self.is_imaginary = true
        end
    end,
}

function player_main_bullet:init(x, y, v, a, dmg, lifetime, red, green, blue)
    local var = lstg.var
    local lw = lstg.wave
    local random_effect = 0
    if var.damask_effect then
        random_effect = ran:Int(1, #main_bullet_effect_list)

    end
    self._shuttle_main_bullet = var.shuttle_main_bullet or (random_effect == 1)--便携式后户/t71
    self._is_mimichan = var.is_mimichan or (random_effect == 2)--Mimichan/t152
    self._kinematics = var.kinematics or (random_effect == 3)--运动学定律/t88
    self._pierce_main_bullet = var.pierce_main_bullet or (random_effect == 4)--半分幻魂魄/t184
    self._nue_main_bullet = var.nue_main_bullet or (random_effect == 5)--符札化络合物/t158
    self._following_main_bullet = var.following_main_bullet or (random_effect == 6)--槐安通路/t186
    self._rotate_star = var.rotate_star or (random_effect == 7)--小小星球/t153
    self._return_bullet = var.return_bullet or (random_effect == 8)--具现化记忆/t122
    self._bound_main_bullet = var.bound_main_bullet or (random_effect == 9)--幽谷回响/t77
    self._MAX_M = var.MAX_M or (random_effect == 10)--MAX M/t142
    self._trail_main_bullet = var.trail_main_bullet or (random_effect == 11)--引诱式黄泉/t72
    self._snake_main_bullet = var.snake_main_bullet or (random_effect == 12)--风神的祝歌/t93
    self._gunpowder_main_bullet = var.gunpowder_main_bullet or (random_effect == 13)--核燃火药/t185
    self._mangekyou = var.mangekyou or (random_effect == 14)--万华镜/t105
    self._link_main_bullet = var.link_main_bullet or (random_effect == 15)--逢天宇宙仪/t197
    self._red_main_bullet = (var.red_main_bullet and ran:Float(0, 1) < 0.16) or (random_effect == 16)--寻求者/t129
    self._green_main_bullet = (var.green_main_bullet and ran:Float(0, 1) < 0.17) or (random_effect == 17)--绿主炮/t130
    self._blue_main_bullet = (var.blue_main_bullet and ran:Float(0, 1) < 0.1) or (random_effect == 18)--蓝主炮/t131
    self._imaginary_main_bullet = var.imaginary_main_bullet or (random_effect == 19)--幻想烟花/t111
    --self.division_main_bullet = var.division_main_bullet or (random_effect == 20)复活吧二叉树（幻想）

    if not (red or green or blue) then
        if self._red_main_bullet then
            red = true
            dmg = dmg + 20--伤害增幅在这里  --谢谢注释喵
        end
        if self._green_main_bullet or lw.all_green_bullet then
            green = true
        end
        if self._blue_main_bullet or lw.all_blue_bullet then
            blue = true
        end
    end
    player_bullet_straight.init(self, lib.GetPlayerBulletImg(), x, y, v, a, dmg)
    self._dmg = dmg
    if main_bullet_effect_list[random_effect] ~= 1 then
        main_bullet_effect_list[random_effect](self)
    end
    local factor = lib.GetPlayerBulletSize()
    local collisize = 24 * factor
    if lstg.tmpvar._is_challenge18 then
        collisize = collisize / lstg.tmpvar._is_challenge18
    end --这个是为了让子弹命中率更高
    self.bound = not var.rotate_star
    self.a, self.b = collisize, collisize
    self.lifetime = int(lifetime or 999)
    self.shuttle_flag = var.shuttle_main_bullet and 1 or 0
    self.target = nil
    self.trail = 400
    self.alpha = 1
    self.rotate_d = sign(player.x - self.x)
    if self.rotate_d == 0 then
        self.rotate_d = ran:Sign()
    end
    self.real_v = v
    self.v = v
    self.isMainBullet = true
    self.can_division = self.lifetime >= 13
    self.smear = {}
    local p = player
    self._r, self._g, self._b = p.colorR, p.colorG, p.colorB
    if self._is_mimichan then
        self.v = 0
        self.vx, self.vy = 0, 0
    end--Mimichan
    if self._kinematics then
        self.vx, self.vy = self.vx + player.dx, self.vy + player.dy
        self.v = GetV(self)
    end--运动学定律

    if (self._pierce_main_bullet) then
        self.killflag = true
        self.pierce_main_bullet = true
        self.pierced_enemy = {}
        setmetatable(self.pierced_enemy, { __mode = "v" })
    end--半分幻魂魄

    if not (red or green or blue) then
        self.R, self.G, self.B = 190, 190, 190
    else
        if red then
            self.R, self.G, self.B = 255, 130, 130
            self.is_red = true
        end
        if green then
            self.R, self.G, self.B = 130, 255, 130
            self.is_green = true
        end
        if blue then
            self.R, self.G, self.B = 130, 130, 255
            self.is_blue = true
        end
    end

    if self._nue_main_bullet then
        local np = ran:Float(0, 1)
        if np < 3 then
            local t = { 1, 2, 3, 4, 5 }
            local _t = {}
            for _ = 1, ran:Int(1, 2) do
                table.insert(_t, table.remove(t, ran:Int(1, #t)))
            end
            for _, c in ipairs(_t) do
                Nue_bullet_event[c](self)
            end
        end
    end
    if var.perfect_spread > 0 then
        main_bullet_count = main_bullet_count + 1
        while main_bullet_count >= 99 do
            main_bullet_count = main_bullet_count - 99
            for A in sp.math.AngleIterator(ran:Float(0, 360), var.perfect_spread * 9) do
                New(player_main_bullet, player.x, player.y, self.real_v, A, self.dmg, self.lifetime)
            end

        end
    end--完美散华
    sp:UnitListUpdate(main_bullet_table)
    sp:UnitListAppend(main_bullet_table, self)
    if #main_bullet_table >= 1500 then
        if var.perfect_spread > 0 then
            main_bullet_count = main_bullet_count - 1
        end
        object.RawDel(self)
    end
    self._time_stop = 0
end
function player_main_bullet:frame()
    if self._time_stop > 0 then
        self.x = self.x - self.vx
        self.y = self.y - self.vy
        self.vx = self.vx - self.ax
        self.vy = self.vy - self.ay
        self.vy = self.vy + self.ag
        self.timer = self.timer - 1
        self.rot = self.rot - self.omega
        self._time_stop = self._time_stop - 1
        return
    end
    task.Do(self)
    if self._is_mimichan then
        local v = self.real_v
        local ax = cos(self.rot) * v * 2 / self.lifetime
        local ay = sin(self.rot) * v * 2 / self.lifetime
        self.vx = self.vx + ax
        self.vy = self.vy + ay
    end
    self.v, self.rot = GetV(self)
    local p = player
    self.target = p.target
    local t = self.timer
    local tvar = lstg.tmpvar
    if tvar.YoumuSkill1 then
        self.dmg = self._dmg * (1 + 0.2 * 50 / (self.timer + 50))
    end
    if self.lifetime == t then
        self.time_out = true
        object.Kill(self)
        if self.is_blue and self.is_green and self.is_red then
            for z = -1, 1 do
                local c = RGB_cache[z + 2]
                local b = New(player_main_bullet, self.x, self.y, self.real_v, self.rot + z * 15, self.dmg, self.lifetime, c[1], c[2], c[3])
                b.colli = false
                task.New(b, function()
                    task.Wait(2)
                    b.colli = true
                end)
                if self.pierced_enemy and b.pierced_enemy then
                    for k in pairs(b.pierced_enemy) do
                        self.pierced_enemy[k] = true
                    end
                end
            end
        end
    end
    if self._following_main_bullet then
        self.x = self.x + p.dx
        self.y = self.y + p.dy
        table.insert(self.smear, {
            x = self.x, y = self.y, rot = self.rot, alpha = 70,
            hscale = self.hscale, vscale = self.vscale
        })
        local s
        local dealpha = (#main_bullet_table / 100)
        dealpha = dealpha * dealpha
        dealpha = dealpha + 5
        for i = #self.smear, 1, -1 do
            s = self.smear[i]
            s.alpha = max(s.alpha - dealpha, 0)
            if s.alpha == 0 then
                table.remove(self.smear, i)
            end
        end
    end
    if self._rotate_star then
        local r = 5.8 + sin(self.timer * 3)
        self.rot = self.rot - self.rotate_d * r
        object.SetV(self, self.v, self.rot)
    end
    if self._return_bullet and not self.have_returned and t >= self.lifetime * 0.5 then
        self.have_returned = true
        self.vx, self.vy = -self.vx, -self.vy
        self.ax, self.ay = -self.ax, -self.ay
        self.rot = Angle(0, 0, self.vx, self.vy)
        self.rotate_d = -self.rotate_d
        if self._shuttle_main_bullet and self.shuttle_flag == 0 then
            self.shuttle_flag = 1
        end
    end
    if self._shuttle_main_bullet and self.shuttle_flag > 0 then
        local w = lstg.world
        if self.y > w.t then
            self.y = w.b + (self.y - w.t)
            self.shuttle_flag = self.shuttle_flag - 1
        end
        if self.y < w.b then
            self.y = w.t + (self.y - w.b)
            self.shuttle_flag = self.shuttle_flag - 1
        end
        if self.x > w.r then
            self.x = w.l + (self.x - w.r)
            self.shuttle_flag = self.shuttle_flag - 1
        end
        if self.x < w.l then
            self.x = w.r + (self.x - w.l)
            self.shuttle_flag = self.shuttle_flag - 1
        end
    end
    if self._bound_main_bullet and self.shuttle_flag == 0 then
        local w = lstg.world
        if self.y > w.t then
            self.vy = -self.vy
            self.rot = -self.rot
            self.y = w.t - (self.y - w.t)
        end
        if self.y < w.b then
            self.vy = -self.vy
            self.rot = -self.rot
            self.y = w.b - (self.y - w.b)
        end
        if self.x > w.r then
            self.vx = -self.vx
            self.rot = 180 - self.rot
            self.x = w.r - (self.x - w.r)
        end
        if self.x < w.l then
            self.vx = -self.vx
            self.rot = 180 - self.rot
            self.x = w.l - (self.x - w.l)
        end
    end
    if self._MAX_M then
        local D = Dist(self, p)
        local A = Angle(self, p)
        local index = 0.002
        if lstg.var.neutron_star then
            index = 0.003
        end
        object.SetA(self, D * index, A)

    end
    if self._trail_main_bullet then
        player_bullet_trail.frame(self)
    end
    if self._snake_main_bullet then
        if IsValid(self.target) and Dist(self, self.target) < self.trail then
            local higher_than_target = false
            if self.vy > 0 then
                higher_than_target = self.y > self.target.y and (self.y - self.dy < self.target.y)
            else
                higher_than_target = self.y < self.target.y and (self.y - self.dy > self.target.y)
            end
            if higher_than_target and not self.isturn_around then
                self.y = self.target.y
                object.SetV(self, self.v, Angle(self, self.target), true)
                self.isturn_around = true
            end
        end
    end

    if lstg.weather.BingYun and self.timer > 5 then
        if lstg.var.frame_counting then
            if ran:Float(0, 1) < 0.01 then
                New(weather_lib.class.ice, self.x, self.y, 60)
                Del(self)
            end
        end
    end
end
function player_main_bullet:kill()
    local velocity = self.time_out and self.v or min(2.5, self.v)
    New(player_main_bullet_ef, self.x, self.y, self.rot, velocity, self.hscale, self.vscale, self.alpha, self.time_out, self.R, self.G, self.B)
    if (self._gunpowder_main_bullet) then
        local scale = 2
        if self._is_mimichan then
            scale = 3
        end
        New(stg_levelUPlib.class5.gunpowder, self.x, self.y, 0.04 * self.dmg, self.a * scale)
    end
end
function player_main_bullet:hit()
    local v = lstg.var
    local t = stage.current_stage.timer
    blueDrop(self)
    if self.is_green then
        player_lib.AddLife(0.064)
    end
    if self._mangekyou then
        for a in sp.math.AngleIterator(t * 4.5, 4) do
            local mk = New(player_main_bullet_mangekyou, self.x, self.y, self.real_v, a, self.dmg * 0.2, self.lifetime, self.is_red, self.is_green, self.is_blue)
            if self.pierced_enemy then
                if not mk.pierced_enemy then
                    mk.pierced_enemy = {}
                end
                for k in pairs(self.pierced_enemy) do
                    mk.pierced_enemy[k] = true
                end
            end
        end
    else
        if self.is_blue and self.is_green and self.is_red then
            for z = -1, 1 do
                local c = RGB_cache[z + 2]
                local b = New(player_main_bullet, self.x, self.y, self.real_v, self.rot + z * 15, self.dmg, self.lifetime, c[1], c[2], c[3])
                b.colli = false
                task.New(b, function()
                    task.Wait(2)
                    b.colli = true
                end)
                if self.pierced_enemy and b.pierced_enemy then
                    for k in pairs(b.pierced_enemy) do
                        self.pierced_enemy[k] = true
                    end
                end
            end
        end
    end
end--击中时的事件
function player_main_bullet:render()
    --SetImageState(self.img, "mul+add", self.alpha * 100, self._r, self._g, self._b)
    --Render(self.img, self.x, self.y, 0, self.hscale * 0.7, self.vscale * 0.7)
    SetImgState(self, "", self.alpha * 200, self.R, self.G, self.B)
    DefaultRenderFunc(self)
    for _, s in ipairs(self.smear) do
        SetImgState(self, "", self.alpha * s.alpha, self.R, self.G, self.B)
        Render(self.img, s.x, s.y, s.rot, s.hscale, s.vscale)
    end
    if self._link_main_bullet then
        local rot, len, x1, y1, x2, y2
        x1, y1, x2, y2 = self.x, self.y, player.x, player.y
        x2, y2 = x2 - x1, y2 - y1
        rot = Angle(self, player)
        len = Dist(self, player)
        SetImageState("white", "mul+add", self.alpha * 35, self.R, self.G, self.B)
        Render("white", x1 + x2 / 2, y1 + y2 / 2, rot, len / 16, self.alpha * 1 / 8)
    end
end

player_main_bullet_imaginary = Class(player_main_bullet)
function player_main_bullet_imaginary:init(x, y, v, a, dmg, lifetime, red, green, blue)
    player_main_bullet.init(self, x, y, v, a, dmg, lifetime, red, green, blue)
    object.SetSizeColli(self, 1.6)
    self.is_imaginary = true
end
function player_main_bullet_imaginary:kill()
    New(player_main_bullet_ef, self.x, self.y, self.rot, min(2.5, self.v), self.hscale, self.vscale, self.alpha, self.time_out, self.R, self.G, self.B)
    local v = lstg.var
    local t = stage.current_stage.timer
    if (self._gunpowder_main_bullet) then
        local scale = 2
        if self._is_mimichan then
            scale = 3
        end
        New(stg_levelUPlib.class5.gunpowder, self.x, self.y, 0.04 * self.dmg, self.a * scale)
    end
    if self._imaginary_main_bullet then
        if v.perfect_spread > 0 then
            main_bullet_count = main_bullet_count - 1
        end
        for a in sp.math.AngleIterator(t * 1.3, ran:Int(6, 9)) do
            New(player_main_bullet, self.x, self.y, self.real_v, a, self.dmg / 1.5, max(ran:Int(5, 8), self.lifetime * 0.6), self.is_red, self.is_green, self.is_blue)
        end
    end

end
function player_main_bullet_imaginary:hit()
    blueDrop(self)
    if self.is_green then
        player_lib.AddLife(0.002 * self.dmg)
    end
end--击中时的事件

player_main_bullet_mangekyou = Class(player_main_bullet)
function player_main_bullet_mangekyou:init(x, y, v, a, dmg, lifetime, red, green, blue)
    player_main_bullet.init(self, x, y, v, a, dmg, lifetime, red, green, blue)
    object.SetSizeColli(self, 0.75)
    self.is_mangekyou = true
    self.colli = false
    task.New(self, function()
        task.Wait()
        self.colli = true
    end)
end
function player_main_bullet_mangekyou:kill()
    New(player_main_bullet_ef, self.x, self.y, self.rot, min(2.5, self.v), self.hscale, self.vscale, self.alpha, self.time_out, self.R, self.G, self.B)
    if (self._gunpowder_main_bullet) then
        local scale = 2
        if self._is_mimichan then
            scale = 3
        end
        New(stg_levelUPlib.class5.gunpowder, self.x, self.y, 0.04 * self.dmg, self.a * scale)
    end
end
function player_main_bullet_mangekyou:hit()
    blueDrop(self)
    if self.is_green then
        player_lib.AddLife(0.002 * self.dmg)
    end
    if self.is_blue and self.is_green and self.is_red then
        for z = -1, 1 do
            local c = RGB_cache[z + 2]
            local b = New(player_main_bullet_mangekyou, self.x, self.y, self.real_v, self.rot + z * 15, self.dmg, self.lifetime, c[1], c[2], c[3])
            if self.pierced_enemy and b.pierced_enemy then
                for k in pairs(b.pierced_enemy) do
                    self.pierced_enemy[k] = true
                end
            end
        end
    end
end--击中时的事件


player_shield = Class(object)
function player_shield:init()
    self.layer = LAYER.PLAYER + 2
    self.group = GROUP.GHOST
    self.colli = false
    self.bound = false
    self.x, self.y = 0, 0
    self.vx, self.vy = 2, 0
    self.alpha = 0
    self._a = 0
    self.__a = 0
    self.index = 0
    task.New(self, function()
        for i = 1, 30 do
            self.alpha = task.SetMode[2](i / 30)
            task.Wait()
        end
    end)
end
function player_shield:frame()
    task.Do(self)
    self.count = lstg.var.shield_count
    self.vy = sin(self.timer * 2)
    local c = int(self.count)
    self.__a = 255
    if c == 0 then
        self.__a = 0
    end
    self._a = self._a + (-self._a + self.__a) * 0.05
    self.index = self.index - self.index * 0.1
end
function player_shield:render()
    local c = int(self.count)
    local n = 13 + setting.rdQual
    local kr1 = 0
    local kr2 = 0
    local dr1 = 5
    local dr2 = 2
    local R, G, B = sp:HSVtoRGB(c * 0.3, 1, 0.6)
    local _color = Color(self.alpha * self._a, R, G, B)
    local _uv1, _uv2, _uv3, _uv4 = { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }
    local cx, cy = self.x, self.y
    local px, py = player.x, player.y
    _uv1[6] = _color
    _uv2[6] = _color
    _uv3[6] = _color
    _uv4[6] = _color
    for i = 1, 15 do
        dr2 = (3.4) * (1 - i / 15) + self.index
        --_color = Color(255 - 100 * (1 - i / 42) * m, 255, 255, 255)
        for r = 1, n do
            local da = 360 / n
            local ang = r * da
            local offa = 0
            local offx, offy = 0, 0
            _uv1[1], _uv1[2] = px + offx + cos(ang + offa) * kr2, py + offy + sin(ang + offa) * kr2
            _uv2[1], _uv2[2] = px + offx + cos(ang + offa) * (kr2 + dr2), py + offy + sin(ang + offa) * (kr2 + dr2)
            _uv3[1], _uv3[2] = px + offx + cos(ang + da + offa) * (kr2 + dr2), py + offy + sin(ang + da + offa) * (kr2 + dr2)
            _uv4[1], _uv4[2] = px + offx + cos(ang + da + offa) * kr2, py + offy + sin(ang + da + offa) * kr2

            _uv1[4], _uv1[5] = cx + offx + cos(ang) * kr1, cy + offy + sin(ang) * kr1
            _uv2[4], _uv2[5] = cx + offx + cos(ang) * (kr1 + dr1), cy + offy + sin(ang) * (kr1 + dr1)
            _uv3[4], _uv3[5] = cx + offx + cos(ang + da) * (kr1 + dr1), cy + offy + sin(ang + da) * (kr1 + dr1)
            _uv4[4], _uv4[5] = cx + offx + cos(ang + da) * kr1, cy + offy + sin(ang + da) * kr1
            _uv1[4], _uv1[5] = WorldToScreen(_uv1[4], _uv1[5])
            _uv2[4], _uv2[5] = WorldToScreen(_uv2[4], _uv2[5])
            _uv3[4], _uv3[5] = WorldToScreen(_uv3[4], _uv3[5])
            _uv4[4], _uv4[5] = WorldToScreen(_uv4[4], _uv4[5])
            RenderTexture("level_obj_shield", "add+add", _uv1, _uv2, _uv3, _uv4)
        end
        kr1 = kr1 + dr1
        kr2 = kr2 + dr2
    end

    for t = 1, c do
        SetImageState("white", "mul+add", self.alpha * self._a * 0.3, sp:HSVtoRGB(t / 100 * 360 + self.timer / 2, 0.7, 1))
        misc.SectorRender(px, py, self.alpha * (kr2 - 2), self.alpha * kr2, 0, 360, 18 + setting.rdQual + int(t * 0.5))
        kr2 = kr2 + 3
    end

    SetImageState("white", "mul+add", self.alpha * self._a * 0.4, R, G, B)
    misc.SectorRender(px, py, 0, kr2 * self.index, 0, 360, 15 + setting.rdQual)
    SetImageState("menu_bright_circle", "mul+add", self.alpha * self._a * 0.2, R, G, B)
    Render("menu_bright_circle", px, py, 0, (kr2 - 2) / 125)
end

function InitPlayer()
    ---@type PlayerUnit[]
    player_list = {}
    ---@type PlayerUnit<string, PlayerUnit>
    player_list_by_name = {}
    for _, dir in ipairs(lstg.FileManager.EnumFiles("THlib/player/", nil, true)) do
        if dir[2] then
            for _, file in ipairs(FindFiles(dir[1], "lua", "")) do
                DoFile(file[1])
            end
        end
    end
end
InitPlayer()