local function _t(str)
    return ReplaceTextWithCommand(i18n("tutorial", str) or "")
end

local class = {}
do
    class.enemy1 = Class(enemy, {
        init = function(self, x, y, vx, vy)
            enemy.init(self, 24, 10, false, true, false, 0)
            self.x, self.y = x, y
            self.vx, self.vy = vx * 0.3, vy * 0.3
            task.New(self, function()
                task.Wait(60)
                local A = Angle(0, 0, self.vx, self.vy)
                for _ = 1, int(stage_lib.GetValue(7, 10, 15, 60)) do
                    local v = stage_lib.GetValue(2, 3, 4, 12)
                    local b = NewSimpleBullet(ball_mid, 10, self.x, self.y, v, A + 180 + ran:Float(-10, 10))
                    b.ag = v / 60
                    b.navi = true
                    b.maxv = stage_lib.GetValue(4, 5, 6, 12)
                    PlaySound("tan00")
                    task.Wait(stage_lib.GetValue(7, 5, 4, 1))
                end
            end)
            task.New(self, function()
                task.Wait(50)
                for i = 1, 36 do
                    self.vx = vx * (0.3 + 0.7 * (i / 36))
                    self.vy = vy * (0.3 + 0.7 * (i / 36))
                    task.Wait()
                end
            end)
        end,
    }, true)
    class.enemy2 = Class(enemy, {
        init = function(self, x, y, vx1, vy1)
            enemy.init(self, 27, 3, false, true, false, 0)
            self.x, self.y = x, y
            self.vx, self.vy = vx1, vy1
            PlaySound("boon00")
            Create.bullet_create_eff(self.x, self.y, ball_big, 4)
            task.New(self, function()
                task.Wait(ran:Int(35, 125))
                for _ = 1, 7 do
                    local v = stage_lib.GetValue(2, 3, 4, 15)
                    local b = NewSimpleBullet(arrow_big_c, 4, self.x, self.y, v, -90+ran:Float(-2, 2))
                    PlaySound("tan00")
                    task.Wait(stage_lib.GetValue(125, 40, 12, 2))
                end
            end)
        end,
    }, true)
end

stage.group.New('attr_select', {}, "Tutorial3", false)
local SimpleStage1 = stage.group.AddStage("Tutorial3", "Tutorial3@1", false)
function SimpleStage1:init()
    self.eventListener = eventListener()
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
    var.maxwave = 2
    var.chaos = 0
    var.energy = 0
    var.energy_efficiency = 0.05

    task.New(self, function()
        task.Wait(60)
        PlayMusic2("3_1")
        local tutorial = ext.tutorial
        tutorial:event(function(self)
            local n0 = self:addtext(_t("tutorial3_1"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n0.alpha = i
                task.Wait()
            end
            self:waitforpress()
        end)
        local next_flag = false
        local drop = New(tool_lib.bubble_tool, 0, 120, activeItem_lib.ActiveTotalList[9], 0, function()
            next_flag = true
        end)
        task.New(drop, function()
            while true do
                object.SetV(drop, 2.5, Angle(drop, player))
                task.Wait()
            end
        end)
        while not next_flag do
            task.Wait()
        end
        task.Wait(50)
        tutorial:event(function(self)
            local n1 = self:addtext(_t("tutorial3_2"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n1.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n2 = self:addtext(_t("tutorial3_3"), 480, 270, 1)
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
            local n3 = self:addtext(_t("tutorial3_4"), 480, 100, 1)
            for i = 1, 25 do
                i = task.SetMode[2](i / 25)
                n3.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n4 = self:addtext(_t("tutorial3_5"), 480, 100, 1)
            for i = 1, 25 do
                i = task.SetMode[2](i / 25)
                n4.alpha = i
                n4.y = 100 + 40 * i
                task.Wait()
            end
            self:waitforpress()
        end)
        stage_lib.DoWaveEventFake(self, 1, "")
        do
            local d = -1
            for t = 1, 5 do
                task.New(self, function()
                    local m = (t <= 4) and 2 or 3
                    for c = -m * d, m * d, d do

                        New(class.enemy1, c * 100, 300, ran:Float(-1, 1), -4)
                        task.Wait(20)
                    end
                end)
                task.Wait(60)
                task.Wait(24 + t * 4)
                d = -d
            end
            task.Wait(75)
            for c = -7, 7 do
                New(class.enemy1, c * 40, 300, ran:Float(-1, 1), -ran:Float(3, 5))
            end
        end
        stage_lib.PassCheck()
        next_flag = false
        drop = New(tool_lib.bubble_tool, 0, 120, activeItem_lib.ActiveTotalList[13], 0, function()
            next_flag = true
        end)
        task.New(drop, function()
            while true do
                object.SetV(drop, 2.5, Angle(drop, player))
                task.Wait()
            end
        end)
        while not next_flag do
            task.Wait()
        end
        tutorial:event(function(self)
            local n1 = self:addtext(_t("tutorial3_6"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n1.alpha = i
                task.Wait()
            end
            self:waitforpress()
            local n2 = self:addtext(_t("tutorial3_7"), 480, 270, 1)
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                n1.y = 270 + 20 * i
                n2.y = 270 - 20 * i
                n2.alpha = i
                task.Wait()
            end
            self:waitforpress()
        end)
        stage_lib.DoWaveEventFake(self, 2, "")

        do
            for _ = 1, 2 do
                for _ = 1, 2 do
                    for _ = 1, 3 do
                        for k = 0, 6 do
                            for d = -1, 1, 2 do
                                New(class.enemy2, d * k * 50 + ran:Float(-30, 30), 140 + ran:Float(-k * 8, k * 8), 0, -2.5)
                            end
                            task.Wait(5)
                        end
                        task.Wait(12)
                    end
                    task.Wait(60)
                end

            end
        end
        stage_lib.PassCheck()
        lstg.tmpvar.noPause = true
        stage.RefreshHiscore(false)
        New(stage.stage_clear_object, 500000)
        task.Wait(120)
        stage.group.ActionDo("直接结束游玩")


    end)
end