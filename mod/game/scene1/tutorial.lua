local function _t(str)
    return ReplaceTextWithCommand(i18n("tutorial", str) or "")
end


local class = {}
do
    class.enemy1 = Class(enemy, {
        init = function(self, x, y, mx, my)
            enemy.init(self, 9, 250, false, true, false, 40)
            self.x, self.y = x, y
            task.New(self, function()
                task.MoveTo(mx, my, 75, 2)
                task.New(self, function()
                    while true do
                        for a in sp.math.AngleIterator(ran:Float(0, 360), 20) do
                            Create.bullet_decel(self.x, self.y, ball_mid, 6, 2, 2, a)
                        end
                        PlaySound("tan00")
                        task.Wait(45)
                    end
                end)
            end)
        end,
    }, true)
    class.enemy2 = Class(enemy, {
        init = function(self, x, y, vx1, vy1)
            enemy.init(self, 23, 50, false, false, false, 1.5)
            self.x, self.y = x, y
            self.vx, self.vy = vx1, vy1
            task.New(self, function()
                for _ = 1, 4 do
                    Create.bullet_accel(self.x, self.y, ball_big, 2, 1, 2, Angle(self, player))
                    task.Wait(75)
                end
            end)
            task.New(self, function()
                task.Wait(200)
                for i = 1, 36 do
                    self.vx = vx1 + vx1 * (i / 36)
                    self.vy = vy1 + vy1 * (i / 36)
                    task.Wait()
                end
                task.Wait(450)
                Del(self)
            end)
        end,
    }, true)
    class.boss1 = boss.Define(i18n("bossname", "Daiyousei"), -200, 400, _editor_class.ice_bg, "Daiyousei")

    local non_sc = boss.card.New("", 1, 4, 999, 350)
    boss.card.add(class.boss1, non_sc)
    function non_sc:before()
        task.MoveTo(0, 120, 60, 2)
    end
    function non_sc:other_drop()
        item.dropItem(item.drop_card, 1, self.x, self.y + 30, 5)
    end
    function non_sc:init()
        task.New(self, function()
            Newcharge_in(self.x, self.y, 189, 252, 201)
            task.Wait(60)
            task.New(self, function()
                local d = 1
                while true do
                    task.New(self, function()
                        task.MoveTo(-120 * d, 90, 72, 2)
                    end)
                    local n = 9
                    for i = 1, 72 do
                        for a in sp.math.AngleIterator(-90 + i * 360 / n * d, 2) do
                            Create.bullet_dec_acc(self.x, self.y, arrow_big, 6, 5,
                                    (3 - i / 72 * 1.5), a, false, false)
                        end
                        PlaySound("tan00")
                        task.Wait()
                    end
                    task.New(self, function()
                        for _ = 1, 6 do
                            for a in sp.math.AngleIterator(ran:Float(0, 360), 10) do
                                NewSimpleBullet(ball_big, 2, self.x, self.y, 2.5, a)
                            end
                            PlaySound("tan00")
                            task.Wait(25)
                        end
                    end)

                    task.MoveTo(0, 120, 140, 3)
                    d = -d

                end
            end)


        end)
    end
end

stage.group.New('attr_select', {}, "Tutorial1", false)
local SimpleStage1 = stage.group.AddStage("Tutorial1", "Tutorial1@1", false)
function SimpleStage1:init()
    LoadBossTex()
    self.is_tutorial = true
    mask_fader:Do("open")
    local var = lstg.var
    local tvar = lstg.tmpvar
    local lib = stg_levelUPlib
    New(player_list[var.player_select].class)

    ---@type scene_class
    local scene_class = SceneClass[lstg.var.scene_id]
    self.scene_class = scene_class
    background.Create(scene_class._bg)
    var.wave = 0
    var.maxwave = 3
    var.chaos = 0
    var.energy = 0
    var.energy_efficiency = 0.05

    task.New(self, function()
        task.Wait(60)
        PlayMusic2(scene_class._bgmlist[1])
        local tutorial = ext.tutorial
        tutorial:event(function(self)
            local n1 = self:addtext(_t("tutorial1_1"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n1.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n2 = self:addtext(_t("tutorial1_2"), 480, 270, 1)
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
            local n1 = self:addtext(_t("tutorial1_3"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n1.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local x, y = WorldToUI(player.x, player.y - 120)
            local n2 = self:addtext(_t("tutorial1_4"), 400, 440, 1)
            local n3 = self:addtext(_t("tutorial1_5"), x + 50, y, 1)
            for i = 1, 25 do
                i = task.SetMode[2](i / 25)
                n1.alpha = 1 - i
                n2.x = 400 - 180 * i
                n2.alpha = i
                task.Wait()
            end
            for i = 1, 25 do
                i = task.SetMode[2](i / 25)
                n3.y = y + 75 * i
                n3.alpha = i
                task.Wait()
            end
            self:deltext(n1)
            self:waitforpress()
            local n4 = self:addtext(_t("tutorial1_6"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n4.alpha = i
                n2.alpha = 1 - i
                n3.alpha = 1 - i
                task.Wait()
            end
            self:deltext(n2)
            self:deltext(n3)
            self:waitforpress()
            local n5 = self:addtext(_t("tutorial1_7"), 480, 270, 1)
            local n6 = self:addtext(_t("tutorial1_8"), 800, 90, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n5.alpha = i
                n6.alpha = i
                n4.alpha = 1 - i
                task.Wait()
            end
            self:waitforpress()
            local n7 = self:addtext(_t("tutorial1_9"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n7.alpha = i
                n5.y = 270 + 15 * i
                n7.y = 270 - 15 * i
                task.Wait()
            end
            self:waitforpress()
            local n8 = self:addtext(_t("tutorial1_10"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n8.alpha = i
                n5.y = 285 + 15 * i
                n7.y = 255 + 15 * i
                n8.y = 270 - 30 * i
                task.Wait()
            end
            self:waitforpress()
            local n9 = self:addtext(_t("tutorial1_11"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n9.alpha = i
                n5.alpha = 1 - i
                n6.alpha = 1 - i
                n7.alpha = 1 - i
                n8.alpha = 1 - i
                task.Wait()
            end
            self:deltext(n5)
            self:deltext(n6)
            self:deltext(n7)
            self:deltext(n8)
            self:waitforpress()
            local n10 = self:addtext(_t("tutorial1_12"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n10.alpha = i
                n9.y = 270 + 15 * i
                n10.y = 270 - 15 * i
                task.Wait()
            end
            self:waitforpress()
            local n11 = self:addtext(_t("tutorial1_13"), 480, 270, 1.2)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n11.alpha = i
                n9.alpha = 1 - i
                n10.alpha = 1 - i
                task.Wait()
            end
            self:deltext(n9)
            self:deltext(n10)
            self:waitforpress()
        end)
        task.Wait()
        player_lib.AddChaos(1)
        var.wave = 1
        SetWave(1, 60, "")
        local e1 = New(class.enemy1, 0, 350, 0, 120)
        while IsValid(e1) do
            task.Wait()
        end
        tvar.next_additionList = {
            lib.AdditionTotalList[3],
            lib.AdditionTotalList[33],
            lib.AdditionTotalList[59],
        }
        tvar.levelUp_event = function()
            local lm = ext.level_menu
            lm._nextlock = true
            task.New(lm, function()

                task.Wait(50)
                tutorial:event(function(self)
                    local n1 = self:addtext(_t("tutorial1_17"), 480, 270, 1)
                    for i = 1, 15 do
                        i = task.SetMode[2](i / 15)
                        n1.alpha = i
                        task.Wait()
                    end
                    self:waitforpress()
                    local n2 = self:addtext(_t("tutorial1_18"), 480, 270, 1)
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
                    lm.pos = 1
                    local n3 = self:addtext(_t("tutorial1_19"), 480, 100, 0.5)
                    for i = 1, 25 do
                        i = task.SetMode[2](i / 25)
                        self.mask = 120 - i * 50
                        n3.size = 0.5 + 0.5 * i
                        n3.alpha = i
                        task.Wait()
                    end
                    self:waitforpress()
                    lm.pos = 2
                    local n4 = self:addtext(_t("tutorial1_20"), 480, 100, 0.5)
                    for i = 1, 25 do
                        i = task.SetMode[2](i / 25)
                        n4.size = 0.5 + 0.5 * i
                        n4.alpha = i
                        n3.alpha = 1 - i
                        task.Wait()
                    end
                    self:deltext(n3)
                    self:waitforpress()
                    lm.pos = 3
                    local n5 = self:addtext(_t("tutorial1_21"), 480, 100, 0.5)
                    for i = 1, 25 do
                        i = task.SetMode[2](i / 25)
                        n5.size = 0.5 + 0.5 * i
                        n5.alpha = i
                        n4.alpha = 1 - i
                        task.Wait()
                    end
                    self:deltext(n4)
                    self:waitforpress()
                    local n6 = self:addtext(_t("tutorial1_22"), 480, 350, 1)
                    local n7 = self:addtext(_t("tutorial1_23"), 310, 320, 1.2)
                    local n8 = self:addtext(_t("tutorial1_24"), 395, 320, 1.2)
                    local n9 = self:addtext(_t("tutorial1_25"), 480, 320, 1.2)
                    local n10 = self:addtext(_t("tutorial1_26"), 565, 320, 1.2)
                    local n11 = self:addtext(_t("tutorial1_27"), 650, 320, 1.2)
                    for i = 1, 25 do
                        i = task.SetMode[2](i / 25)
                        self.mask = 70 + i * 100
                        n5.y = 100 + 100 * i
                        n6.alpha = i
                        n7.alpha = i
                        n8.alpha = i
                        n9.alpha = i
                        n10.alpha = i
                        n11.alpha = i
                        task.Wait()
                    end
                    self:waitforpress()
                    local n12 = self:addtext(_t("tutorial1_28"), 480, 200, 1)
                    for i = 1, 15 do
                        i = task.SetMode[2](i / 15)
                        n5.alpha = 1 - i
                        n12.alpha = i
                        task.Wait()
                    end
                    self:waitforpress()
                    local n14 = self:addtext(_t("tutorial1_29"), 480, 270, 1)
                    for i = 1, 15 do
                        i = task.SetMode[2](i / 15)
                        n6.alpha = 1 - i
                        n7.alpha = 1 - i
                        n8.alpha = 1 - i
                        n9.alpha = 1 - i
                        n10.alpha = 1 - i
                        n11.alpha = 1 - i
                        n12.alpha = 1 - i
                        n14.alpha = i
                        task.Wait()
                    end
                    self:waitforpress()
                    local n15 = self:addtext(_t("tutorial1_30"), 480, 250, 1.2)
                    for i = 1, 15 do
                        i = task.SetMode[2](i / 15)
                        n15.alpha = i
                        task.Wait()
                    end
                    self:waitforpress()
                end)
                --task.Wait()
                lm._nextlock = false
                lm.lock = false
            end)
        end
        task.Wait(60)
        tutorial:event(function(self)
            local n1 = self:addtext(_t("tutorial1_14"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n1.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n2 = self:addtext(_t("tutorial1_15"), 480, 270, 1)
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
            local n3 = self:addtext(_t("tutorial1_16"), 600, 70, 1)
            for i = 1, 25 do
                i = task.SetMode[2](i / 25)
                n3.x = 600 + 120 * i
                n3.alpha = i
                task.Wait()
            end
            self:waitforpress()
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n3.alpha = 1 - i
                task.Wait()
            end
            self:deltext(n3)
        end)
        task.Wait(120)

        while var.level <= 1 do
            local e2 = New(class.enemy1, 0, 350, 0, 120)
            while IsValid(e2) do
                task.Wait()
            end
            for _ = 1, 300 do
                if var.level >= 2 then
                    break
                end
                task.Wait()
            end
        end
        task.Wait(120)
        var.chaos = var.chaos + 10
        var.wave = 2
        SetWave(2, 60, "", nil, true)
        tutorial:event(function(self)
            local n1 = self:addtext(_t("tutorial1_31"), 480, 270, 1, 230, 230, 230)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n1.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n2 = self:addtext(_t("tutorial1_32"),
                    480, 270, 1, 230, 230, 230)
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
            local n3 = self:addtext(_t("tutorial1_33"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n3.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n4 = self:addtext(_t("tutorial1_34"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n3.y = 270 + 20 * i
                n4.y = 270 - 20 * i
                n4.alpha = i
                task.Wait()
            end
            self:waitforpress()
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n3.alpha = 1 - i
                n4.alpha = 1 - i
                task.Wait()
            end
            self:deltext(n3)
            self:deltext(n4)
            local n5 = self:addtext(_t("tutorial1_35"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n5.alpha = i
                task.Wait()
            end
            self:waitforpress()
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n5.alpha = 1 - i
                task.Wait()
            end
            self:deltext(n5)
        end)
        for _ = 1, 4 do
            for i = -8, 8 do
                local a = 90 + i * 90 / 8
                New(class.enemy2, cos(a) * 500, sin(a) * 500, cos(a + 180) * 1, sin(a + 180) * 1)
            end
            task.Wait(100)
        end
        task.Wait(20)
        lstg.var.energy = 100
        tvar.next_additionList = {
            lib.AdditionTotalList[20],
            lib.AdditionTotalList[22],
            lib.AdditionTotalList[72],
        }
        tvar.levelUp_event = function()
            local lm = ext.level_menu
            lm._nextlock = true
            task.New(lm, function()
                task.Wait(50)
                tutorial:event(function(self)
                    local n1 = self:addtext(_t("tutorial1_45"), 480, 270, 1)
                    for i = 1, 15 do
                        i = task.SetMode[2](i / 15)
                        n1.alpha = i
                        task.Wait()
                    end
                    self:waitforpress()
                    local n2 = self:addtext(_t("tutorial1_46"), 480, 270, 1)
                    for i = 1, 15 do
                        i = task.SetMode[2](i / 15)
                        n1.y = 270 + 20 * i
                        n2.y = 270 - 20 * i
                        n2.alpha = i
                        task.Wait()
                    end
                    self:waitforpress()
                    local n3 = self:addtext(_t("tutorial1_47"), 480, 300, 1)
                    for i = 1, 15 do
                        i = task.SetMode[2](i / 15)
                        self.mask = 100 + 50 * i
                        n1.alpha = 1 - i
                        n2.alpha = 1 - i
                        n3.alpha = i
                        task.Wait()
                    end
                    self:waitforpress()
                    for i = 1, 15 do
                        i = task.SetMode[2](i / 15)
                        n3.alpha = 1 - i
                        task.Wait()
                    end
                    self:deltext(n1)
                    self:deltext(n2)
                    self:deltext(n3)
                end)
                task.Wait()
                lm._nextlock = false
                lm.lock = false
            end)
        end
        tutorial:event(function(self)
            local n1 = self:addtext(_t("tutorial1_36"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n1.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n2 = self:addtext(_t("tutorial1_37"), 480, 270, 1)
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
            local n3 = self:addtext(_t("tutorial1_38"), 480, 90, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n3.x = 480 - 160 * i
                n3.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n4 = self:addtext(_t("tutorial1_39"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n4.alpha = i
                task.Wait()
            end
            self:waitforpress()
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n3.alpha = 1 - i
                n4.alpha = 1 - i
                task.Wait()
            end
            self:deltext(n3)
            self:deltext(n4)
            local n5 = self:addtext(_t("tutorial1_40"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n5.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n6 = self:addtext(_t("tutorial1_41"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n5.y = 270 + 20 * i
                n6.y = 270 - 20 * i
                n6.alpha = i
                task.Wait()
            end
            self:waitforpress()
            for i = 1, 25 do
                i = task.SetMode[2](i / 25)
                n5.alpha = 1 - i
                n6.alpha = 1 - i
                n6.size = 1 + i * 2
                task.Wait()
            end
            self:deltext(n5)
            self:deltext(n6)
        end)
        task.Wait(480)
        if var.level <= 2 then
            tutorial:event(function(self)
                local n1 = self:addtext(_t("tutorial1_42"), 480, 270, 2)
                for i = 1, 15 do
                    i = task.SetMode[2](i / 15)
                    n1.alpha = i
                    task.Wait()
                end
                self:waitforpress()
                local n2 = self:addtext(_t("tutorial1_43"), 480, 240, 1)
                for i = 1, 15 do
                    i = task.SetMode[2](i / 15)
                    n2.alpha = i
                    task.Wait()
                end
                self:waitforpress()
                local n3 = self:addtext(_t("tutorial1_44"), 480, 270, 1.5)
                for i = 1, 15 do
                    i = task.SetMode[2](i / 15)
                    n1.size = 1 - i
                    n2.size = 1 - i
                    n3.alpha = i
                    task.Wait()
                end
                self:deltext(n1)
                self:deltext(n2)
                self:waitforpress()
                for i = 1, 15 do
                    i = task.SetMode[2](i / 15)
                    n3.alpha = 1 - i
                    task.Wait()
                end
            end)
            task.Wait()
            AddExp(lib.GetCurMaxEXP(2) - var.now_exp + 1)
        end
        task.Wait(60)
        var.chaos = var.chaos + 5
        var.wave = 3
        SetWave(3, 60, "", nil, nil, true)
        tvar.ToolItemGet_event = function()
            local lm = ext.level_menu
            task.New(lm, function()
                lm._nextlock = true
                task.Wait(50)
                tutorial:event(function(self)
                    local n1 = self:addtext(_t("tutorial1_48"), 480, 270, 1)
                    for i = 1, 15 do
                        i = task.SetMode[2](i / 15)
                        n1.alpha = i
                        task.Wait()
                    end
                    self:waitforpress()
                    local n2 = self:addtext(_t("tutorial1_49"), 480, 270, 1)
                    for i = 1, 15 do
                        i = task.SetMode[2](i / 15)
                        n1.y = 270 + 20 * i
                        n2.y = 270 - 20 * i
                        n2.alpha = i
                        task.Wait()
                    end
                    self:waitforpress()
                    self:deltext(n1)
                    self:deltext(n2)
                    local n3 = self:addtext(_t("tutorial1_50"), 480, 270, 1)
                    for i = 1, 15 do
                        i = task.SetMode[2](i / 15)
                        n3.alpha = i
                        task.Wait()
                    end
                    self:waitforpress()
                    local n4 = self:addtext(_t("tutorial1_51"), 480, 270, 1)
                    for i = 1, 15 do
                        i = task.SetMode[2](i / 15)
                        n3.y = 270 + 20 * i
                        n4.y = 270 - 20 * i
                        n4.alpha = i
                        task.Wait()
                    end
                    self:waitforpress()
                end)
                task.Wait()
                lm._nextlock = false
                lm.lock = false
            end)
        end
        local b = boss.Create(class.boss1)
        while IsValid(b) do
            task.Wait()
        end
        task.Wait(265)
        tutorial:event(function(self)
            local n1 = self:addtext(_t("tutorial1_52"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n1.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n2 = self:addtext(_t("tutorial1_53"), 480, 270, 1.2)
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
        lstg.tmpvar.noPause = true
        stage.RefreshHiscore(false)
        New(stage.stage_clear_object, 500000)
        task.Wait(120)
        stage.group.ActionDo("直接结束游玩")


    end)
end