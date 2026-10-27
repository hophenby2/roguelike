---STG基础教程

local function _t(str)
    return ReplaceTextWithCommand(i18n("tutorial", str) or "")
end

local class = {}
do
    class.enemy1 = Class(enemy, {
        init = function(self, x, y, vx1, vy1, vx2, vy2)
            enemy.init(self, 3, 10, false, false, false, 0)
            self.x, self.y = x, y
            self.vx, self.vy = vx1, vy1
            task.New(self, function()
                task.Wait(25)
                for i = 1, 36 do
                    self.vx = vx1 + (vx2 - vx1) * (i / 36)
                    self.vy = vy1 + (vy2 - vy1) * (i / 36)
                    task.Wait()
                end
                task.Wait(352)
                Del(self)
            end)
        end,
    }, true)
    class.enemy2 = Class(enemy, {
        init = function(self, x, y, mx, my, vx, vy)
            enemy.init(self, 9, 250, false, true, false, 0)
            self.x, self.y = x, y
            task.New(self, function()
                task.MoveTo(mx, my, 60, 2)
                task.New(self, function()
                    for _ = 1, 3 do
                        for a in sp.math.AngleIterator(ran:Float(0, 360), 18) do
                            Create.bullet_decel(self.x, self.y, ball_mid, 2, 3, 1.5, a)
                        end
                        PlaySound("tan00")
                        task.Wait(120)
                    end
                end)
                task.Wait(180)
                for i = 1, 60 do
                    self.vx = i / 60 * vx
                    self.vy = i / 60 * vy
                    task.Wait()
                end
            end)
        end,
    }, true)
    class.enemy3 = Class(enemy, {
        init = function(self, x, y, mx, my, vx, vy)
            enemy.init(self, 15, 45, false, true, false, 10)
            self.x, self.y = x, y
            task.New(self, function()
                task.MoveTo(mx, my, 60, 2)
                while true do
                    for a in sp.math.AngleIterator(Angle(self, player), 8) do
                        Create.bullet_decel(self.x, self.y, ellipse, 6, 3, 1.5, a)
                    end
                    PlaySound("tan00")
                    task.Wait(150)
                end
            end)
        end,
    }, true)
    class.boss = boss.Define(i18n("bossname", "Whitelily"), 0, 400, _editor_class.spring_bg, "Whitelily")

    local non_sc = boss.card.New("", 1, 4, 40, 600)
    boss.card.add(class.boss, non_sc)
    function non_sc:before()
    end
    function non_sc:init()
        task.New(self, function()
            local tutorial = ext.tutorial
            task.Wait(120)
            tutorial:event(function(self)
                local n1 = self:addtext(_t("tutorial0_44"), 480, 270, 1)
                for i = 1, 15 do
                    i = task.SetMode[2](i / 15)
                    n1.alpha = i
                    task.Wait()
                end
                self:waitforpress()
                local n2 = self:addtext(_t("tutorial0_45"), 480, 270, 1)
                for i = 1, 15 do
                    i = task.SetMode[2](i / 15)
                    n1.y = 270 + 20 * i
                    n2.y = 270 - 20 * i
                    n2.alpha = i
                    task.Wait()
                end
                self:waitforpress()
                local n3 = self:addtext(_t("tutorial0_46"), 480, 210, 1)
                for i = 1, 15 do
                    i = task.SetMode[2](i / 15)
                    n3.alpha = i
                    task.Wait()
                end
                self:waitforpress()
                local n4 = self:addtext(_t("tutorial0_47"), 480, 170, 1)
                for i = 1, 15 do
                    i = task.SetMode[2](i / 15)
                    n4.alpha = i
                    task.Wait()
                end
                self:waitforpress()
                local n5 = self:addtext(_t("tutorial0_48"), 480, 270, 1)
                for i = 1, 15 do
                    i = task.SetMode[2](i / 15)
                    n3.alpha = 1 - i
                    n2.alpha = 1 - i
                    n1.alpha = 1 - i
                    n4.alpha = 1 - i
                    n5.alpha = i
                    task.Wait()
                end
                self:waitforpress()
                local n6 = self:addtext(_t("tutorial0_49"), 480, 270, 1)
                for i = 1, 15 do
                    i = task.SetMode[2](i / 15)
                    n5.y = 270 + 20 * i
                    n6.y = 270 - 20 * i
                    n6.alpha = i
                    task.Wait()
                end
                self:waitforpress()
            end)
        end)
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
            while true do
                local d = 1
                for k = 1, 4 do
                    local rot = ran:Float(0, 360)
                    for n = 1, 5 do
                        for a in sp.math.AngleIterator(rot, 6 * 3) do
                            local v = 1.5 + n
                            local tv = 2
                            Create.bullet_dec_setangle(self.x, self.y, arrow_big, 2, false,
                                    { v = v, a = a, time = 60 }, { func = function(self)
                                        object.SetV(self, tv, Angle(self, player), true)
                                    end })
                        end
                        rot = rot + 6 * d
                    end
                    PlaySound("tan00")
                    task.Wait(60)

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
                local t = 20
                for i = 1, t do
                    local r = ran:Float(0.2, 0.7)
                    local v = ran:Float(1, 2)
                    local k = 4
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
                task.Wait(80)
            end


        end)
    end
    function non_sc:del()
        self.hscale, self.vscale = 1, 1
    end

    local sc = boss.card.New("春符「春天的昭示」", 1, 5, 40, 700)
    boss.card.add(class.boss, sc)
    function sc:before()
        task.MoveTo(0, 100, 60, 2)
    end
    function sc:init()
        task.New(self, function()
            local tutorial = ext.tutorial
            task.Wait(150)
            tutorial:event(function(self)
                local n1 = self:addtext(_t("tutorial0_50"), 480, 270, 1)
                for i = 1, 15 do
                    i = task.SetMode[2](i / 15)
                    n1.alpha = i
                    task.Wait()
                end
                self:waitforpress()
                local n2 = self:addtext(_t("tutorial0_51"), 480, 270, 1)
                for i = 1, 15 do
                    i = task.SetMode[2](i / 15)
                    n1.y = 270 + 20 * i
                    n2.y = 270 - 20 * i
                    n2.alpha = i
                    task.Wait()
                end
                self:waitforpress()
                local n3 = self:addtext(_t("tutorial0_52"), 480, 210, 1)
                for i = 1, 15 do
                    i = task.SetMode[2](i / 15)
                    n3.alpha = i
                    task.Wait()
                end
                self:waitforpress()
                local n4 = self:addtext(_t("tutorial0_53"), 480, 270, 1)
                for i = 1, 15 do
                    i = task.SetMode[2](i / 15)
                    n3.alpha = 1 - i
                    n2.alpha = 1 - i
                    n1.alpha = 1 - i
                    n4.alpha = i
                    task.Wait()
                end
                self:waitforpress()
                local n5 = self:addtext(_t("tutorial0_54"), 480, 270, 1)
                for i = 1, 15 do
                    i = task.SetMode[2](i / 15)
                    n4.y = 270 + 20 * i
                    n5.y = 270 - 20 * i
                    n5.alpha = i
                    task.Wait()
                end
                self:waitforpress()
            end)
        end)
        task.New(self, function()
            task.Wait(60)
            Newcharge_in(self.x, self.y, 250, 128, 114)
            task.Wait(60)
            local d = 1
            local t = 1
            while true do
                local r = ran:Float(0.2, 0.7)
                local v = 1.5
                local k = 7
                local c = (k - 1) / 2
                for n = -c, c do
                    local rot = 90 + d * (10 + t * 14) + n * 80 / c
                    Create.bullet_changeangle(self.x, self.y, ball_mid, 4 - d * 2,
                            v, rot, { r = d * r, time = 60 })
                end
                d = -d
                t = t + 1
                PlaySound("tan00")
                task.Wait(10)
            end


        end)
    end
end

stage.group.New("main", {}, "Tutorial0", false)
local SimpleStage1 = stage.group.AddStage("Tutorial0", "Tutorial0@1", false)
function SimpleStage1:init()
    LoadBossTex()
    self.is_tutorial = true
    mask_fader:Do("open")
    local var = lstg.var
    var.difficulty = 0
    var.scene_id = 1
    New(player_list[var.player_select].class)
    --强行1级
    local ps = var.player_select
    local ss = var.spell_select
    player_lib.SetPlayerAttribute(player, ps, 1)
    player.spell_sys = player.class.spells[ss](player, player_lib.GetSpellAttribute(ps, ss))

    background.Create(BG_14)
    var.level = 61
    var.wave = 0
    var.maxwave = 3
    var.chaos = 0
    var.energy = 0
    var.energy_efficiency = 0.05

    task.New(self, function()
        task.Wait(60)
        PlayMusic2("1_1")
        local tutorial = ext.tutorial
        tutorial:event(function(self)
            local n0 = self:addtext(_t("tutorial0_3"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n0.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n1 = self:addtext(_t("tutorial0_4"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n0.alpha = 1 - i
                n1.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n2 = self:addtext(_t("tutorial0_5"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n1.y = 270 + 20 * i
                n2.y = 270 - 20 * i
                n2.alpha = i
                task.Wait()
            end
            self:waitforpress()
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n1.alpha = 1 - i
                n2.alpha = 1 - i
                task.Wait()
            end
            self:deltext(n1)
            self:deltext(n2)
        end)
        task.Wait(120)
        tutorial:event(function(self)
            local n1 = self:addtext(_t("tutorial0_6"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n1.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n2 = self:addtext(_t("tutorial0_7"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n1.y = 270 + 20 * i
                n2.y = 270 - 20 * i
                n2.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n3 = self:addtext(_t("tutorial0_8"), 480, 210, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n3.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n4 = self:addtext(_t("tutorial0_9"), 480, 170, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n4.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n5 = self:addtext(_t("tutorial0_10"), 480, 130, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n5.alpha = i
                task.Wait()
            end
            self:waitforpress()
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n5.alpha = 1 - i
                n4.alpha = 1 - i
                n3.alpha = 1 - i
                n2.alpha = 1 - i
                n1.alpha = 1 - i
                task.Wait()
            end
        end)
        task.Wait(180)
        tutorial:event(function(self)
            local n1 = self:addtext(_t("tutorial0_11"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n1.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n2 = self:addtext(_t("tutorial0_12"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n1.y = 270 + 20 * i
                n2.y = 270 - 20 * i
                n2.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n4 = self:addtext(_t("tutorial0_13"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n2.alpha = 1 - i
                n1.alpha = 1 - i
                n4.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n5 = self:addtext(_t("tutorial0_14"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n4.y = 270 + 20 * i
                n5.y = 270 - 20 * i
                n5.alpha = i
                task.Wait()
            end
            self:waitforpress()
        end)
        task.Wait(60)
        var.wave = 1
        SetWave(1, 40, _t("tutorial0_1"))
        for _ = 1, 16 do
            New(class.enemy1, 356, ran:Float(140, 180), -1, -0.2, ran:Float(-1.9, -2.2), ran:Float(-0.1, -0.2))
            task.Wait(12)
        end
        task.Wait(30)
        New(class.enemy2, 0, 300, 0, 150, 0, -1)
        task.Wait(80)
        tutorial:event(function(self)
            local n1 = self:addtext(_t("tutorial0_15"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n1.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n2 = self:addtext(_t("tutorial0_16"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n1.y = 270 + 20 * i
                n2.y = 270 - 20 * i
                n2.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n3 = self:addtext(_t("tutorial0_17"), 480, 210, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n3.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n3_ = self:addtext(_t("tutorial0_18"), 480, 170, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n3_.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n4 = self:addtext(_t("tutorial0_19"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n3_.alpha = 1 - i
                n3.alpha = 1 - i
                n2.alpha = 1 - i
                n1.alpha = 1 - i
                n4.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n5 = self:addtext(_t("tutorial0_20"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n4.y = 270 + 20 * i
                n5.y = 270 - 20 * i
                n5.alpha = i
                task.Wait()
            end
            self:waitforpress()
        end)
        task.Wait(100)
        tutorial:event(function(self)
            local n1 = self:addtext(_t("tutorial0_21"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n1.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n2 = self:addtext(_t("tutorial0_22"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n1.y = 270 + 20 * i
                n2.y = 270 - 20 * i
                n2.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n3 = self:addtext(_t("tutorial0_23"), 480, 210, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n3.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n4 = self:addtext(_t("tutorial0_24"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n3.alpha = 1 - i
                n2.alpha = 1 - i
                n1.alpha = 1 - i
                n4.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n5 = self:addtext(_t("tutorial0_25"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n4.y = 270 + 20 * i
                n5.y = 270 - 20 * i
                n5.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n6 = self:addtext(_t("tutorial0_26"), 480, 210, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n6.alpha = i
                task.Wait()
            end
            self:waitforpress()
        end)
        while true do
            local flag
            for _ in ObjList(GROUP.ENEMY) do
                flag = true
                break
            end
            if not flag then
                break
            end
            task.Wait()
        end
        task.Wait(60)
        tutorial:event(function(self)
            local n1 = self:addtext(_t("tutorial0_27"), 480, 270, 1, 230, 230, 230)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n1.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n2 = self:addtext(_t("tutorial0_28"), 480, 270, 1, 255, 227, 132)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n1.y = 270 + 20 * i
                n2.y = 270 - 20 * i
                n2.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n3 = self:addtext(_t("tutorial0_29"), 480, 210, 1, 230, 200, 200)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n3.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n4 = self:addtext(_t("tutorial0_30"), 480, 270, 1, 230, 230, 230)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n3.alpha = 1 - i
                n2.alpha = 1 - i
                n1.alpha = 1 - i
                n4.alpha = i
                task.Wait()
            end
            self:waitforpress()
        end)
        task.Wait()
        stg_levelUPlib.AdditionTotalList[24]:Set()
        PlaySound("lgods2")
        task.Wait(60)
        var.wave = 2
        SetWave(2, 40,  _t("tutorial0_2"))
        for x = -2, 2 do
            New(class.enemy2, x * 100, 300, x * 100, 140 - abs(x) * 25, 0, -1)
        end
        task.Wait(120)
        lstg.var.energy = 100
        tutorial:event(function(self)
            local n1 = self:addtext(_t("tutorial0_31"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n1.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n2 = self:addtext(_t("tutorial0_32"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n1.y = 270 + 20 * i
                n2.y = 270 - 20 * i
                n2.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n3 = self:addtext(_t("tutorial0_33"), 480, 210, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n3.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n4 = self:addtext(_t("tutorial0_34"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n3.alpha = 1 - i
                n2.alpha = 1 - i
                n1.alpha = 1 - i
                n4.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n5 = self:addtext(_t("tutorial0_35"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n4.y = 270 + 20 * i
                n5.y = 270 - 20 * i
                n5.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n6 = self:addtext(_t("tutorial0_36"), 480, 210, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n6.alpha = i
                task.Wait()
            end
            self:waitforpress()
        end)
        stage_lib.PassCheck()
        task.Wait(60)
        for x = -1, 1 do
            New(class.enemy3, x * 100, 300, x * 100, 120 + abs(x) * 25)
        end
        task.New(self, function()
            while true do
                local c = 0
                for _ in ObjList(GROUP.ENEMY) do
                    c = c + 1
                end
                if c < 3 then
                    break
                end
                task.Wait()
            end
            task.Wait(45)
            tutorial:event(function(self)
                local n1 = self:addtext(_t("tutorial0_37"), 480, 270, 1)
                for i = 1, 15 do
                    i = task.SetMode[2](i / 15)
                    n1.alpha = i
                    task.Wait()
                end
                self:waitforpress()
                local n2 = self:addtext(_t("tutorial0_38"), 480, 270, 1)
                for i = 1, 15 do
                    i = task.SetMode[2](i / 15)
                    n1.y = 270 + 20 * i
                    n2.y = 270 - 20 * i
                    n2.alpha = i
                    task.Wait()
                end
                self:waitforpress()
                local n3 = self:addtext(_t("tutorial0_39"), 480, 210, 1)
                for i = 1, 15 do
                    i = task.SetMode[2](i / 15)
                    n3.alpha = i
                    task.Wait()
                end
                self:waitforpress()
                local n4 = self:addtext(_t("tutorial0_40"), 480, 270, 1)
                for i = 1, 15 do
                    i = task.SetMode[2](i / 15)
                    n3.alpha = 1 - i
                    n2.alpha = 1 - i
                    n1.alpha = 1 - i
                    n4.alpha = i
                    task.Wait()
                end
                self:waitforpress()
                local n5 = self:addtext(_t("tutorial0_41"), 480, 270, 1)
                for i = 1, 15 do
                    i = task.SetMode[2](i / 15)
                    n4.y = 270 + 20 * i
                    n5.y = 270 - 20 * i
                    n5.alpha = i
                    task.Wait()
                end
                self:waitforpress()
                local n6 = self:addtext(_t("tutorial0_42"), 480, 210, 1)
                for i = 1, 15 do
                    i = task.SetMode[2](i / 15)
                    n6.alpha = i
                    task.Wait()
                end
                self:waitforpress()
                local n7 = self:addtext(_t("tutorial0_43"), 480, 170, 1)
                for i = 1, 15 do
                    i = task.SetMode[2](i / 15)
                    n7.alpha = i
                    task.Wait()
                end
                self:waitforpress()
            end)
        end)
        stage_lib.PassCheck()
        task.Wait(120)
        var.wave = 3
        SetWave(3, 40, "", nil, nil, true)
        boss.Create(class.boss)
        stage_lib.PassCheck()
        task.Wait(60)
        tutorial:event(function(self)
            local n1 = self:addtext(_t("tutorial0_55"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n1.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n2 = self:addtext(_t("tutorial0_56"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n1.y = 270 + 20 * i
                n2.y = 270 - 20 * i
                n2.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n3 = self:addtext(_t("tutorial0_57"), 480, 210, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n3.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n4 = self:addtext(_t("tutorial0_58"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n3.alpha = 1 - i
                n2.alpha = 1 - i
                n1.alpha = 1 - i
                n4.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n5 = self:addtext(_t("tutorial0_59"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n4.y = 270 + 20 * i
                n5.y = 270 - 20 * i
                n5.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n6 = self:addtext(_t("tutorial0_60"), 480, 210, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n6.alpha = i
                task.Wait()
            end
            self:waitforpress()
        end)
        task.Wait(60)
        tutorial:event(function(self)
            local n1 = self:addtext(_t("tutorial0_61"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n1.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n2 = self:addtext(_t("tutorial0_62"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n1.alpha = 1 - i
                n2.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n3 = self:addtext(_t("tutorial0_63"), 480, 230, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n3.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n4 = self:addtext(_t("tutorial0_64"), 480, 190, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n4.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n5 = self:addtext(_t("tutorial0_65"), 480, 270, 2)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n4.alpha = 1 - i
                n3.alpha = 1 - i
                n2.alpha = 1 - i
                n1.alpha = 1 - i
                n5.alpha = i
                task.Wait()
            end
            self:waitforpress()
        end)
        task.Wait(60)
        lstg.tmpvar.noPause = true
        --stage.RefreshHiscore(false)
        New(stage.stage_clear_object, 500000)
        task.Wait(120)
        stage.group.ActionDo("直接结束游玩")


    end)
end