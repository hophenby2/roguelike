local tg = stg_levelUPlib.tagslist
local lib = activeItem_lib

return {
    [4] = {
        name = [[绿色番荔枝]],
        stitle = [[这啥]],
        sdes = [[给予§g100§d层护罩，§g10§d秒内逐渐衰减]],
        detail = [[/a4sdes]],
        collabd = nil,
        unlockd = [[使用/playerChiruno通关/scenep3]],
        condd = nil,
        tags = { tg.defend },
        activeType = 2,
        chargeC = 0.3,
        maxEnergy = 1,
        hold = false,
        cost = 1.000000,
        event = function()
            PlaySound("eatfood")
            NewWave(player.x, player.y, 2, 400, 42, 189, 252, 201)
            local v = lstg.var
            v.shield_count = v.shield_count + 100
            player.my_shield.index = 1
            player.my_shield._a = 0
            New(tasker, function()
                for _ = 1, 600 do
                    v.shield_count = max(0, v.shield_count - 100 / 600)
                    task.Wait()
                end
            end)
        end,
        frameEvent = nil,
        condfunc = nil,
    },
    [5] = {
        name = [[红心火龙果]],
        stitle = [[轰心轰隆股儿]],
        sdes = [[使用时恢复§g25%/hp
持有时若死亡，/player§y满血复活§d并获得§g2秒§d/inv，并§r失去]],
        detail = [[/a5sdes]],
        collabd = nil,
        unlockd = [[使用/playerReimu通关/scenep3]],
        condd = nil,
        tags = { tg.resurrection, tg.life },
        activeType = 2,
        chargeC = 0.3,
        maxEnergy = 1,
        hold = false,
        cost = 1.000000,
        event = function(self)
            PlaySound("eatfood")
            player_lib.AddLife(0.25 * lstg.var.maxlife)

        end,
        frameEvent = nil,
        condfunc = nil,
    },
    [6] = {
        name = [[护身符]],
        stitle = [[太上老君快显灵]],
        sdes = [[混沌值立刻§g-5%]],
        detail = [[/a6sdes]],
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = tg.chaos,
        activeType = 3,
        chargeC = 1 / 50,
        maxEnergy = 1,
        hold = false,
        cost = 1.000000,
        event = function(self)
            NewBon(player.x, player.y, 30, 30, 200, 64, 64)
            PlaySound("nice")
            player_lib.AddChaos(-5)
        end,
        frameEvent = nil,
        condfunc = nil,
    },
    [16] = {
        name = [[荷取牌能量盾2.0]],
        stitle = [[手充型护盾]],
        sdes = [[使用时，给予§g1层§d护盾]],
        detail = [[/a16sdes]],
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = tg.defend,
        activeType = 2,
        chargeC = 0.75,
        maxEnergy = 3,
        hold = false,
        cost = 1,
        event = function()
            PlaySound("charged")
            NewWave(player.x, player.y, 2, 400, 42, 150, 150, 256)
            local v = lstg.var
            v.shield_count = v.shield_count + 1
        end,
        frameEvent = nil,
        condfunc = nil,
    },
    [24] = {
        name = [[季节解放·春]],
        stitle = [[吹拂樱花]],
        sdes = [[在/player位置生成一个§p春季结界§d
结界的面积随能量等级增大而§g增大§d]],
        detail = [[记§ya=能量等级
在/player位置生成一个§p春季结界§d，可以消弹，
对结界内的敌人每帧造成§g(80+a*10)%/atk§d的伤害
同时会使/player§g/inv一段时间
结界的面积随能量等级增大而§g增大§d]],
        collabd = nil,
        unlockd = [[在/scenep3遇到/w4]],
        condd = nil,
        tags = tg.defend,
        activeType = 3,
        chargeC = 1 / 16,
        maxEnergy = 6,
        hold = false,
        cost = 1,
        event = function(self)
            New(lib.class.Spring_Attack, int(self.energy))
            self.energy = self.energy % 1 + 1
            PlaySound("release")
        end,
        frameEvent = nil,
        condfunc = nil,
    },
    [25] = {
        name = [[季节解放·夏]],
        stitle = [[完美夏冰]],
        sdes = [[在/player位置生成一个§c夏季结界§d
可以消弹，造成§g一定伤害]],
        detail = [[在/player位置生成一个§c夏季结界§d，可以消弹，
对结界内的敌人每帧造成§g50%/atk§d的伤害
同时会使/player§g/inv一段时间
§-每次只消耗100%的能量]],
        collabd = nil,
        unlockd = [[在/scenep3遇到/w11]],
        condd = nil,
        tags = tg.defend,
        activeType = 3,
        chargeC = 1 / 16,
        maxEnergy = 6,
        hold = false,
        cost = 1,
        event = function(self)
            New(lib.class.Summer_Attack, int(self.energy))
            player.nextsp = 60
            PlaySound("release")
        end,
        frameEvent = nil,
        condfunc = nil,
    },
    [26] = {
        name = [[季节解放·秋]],
        stitle = [[疯狂秋风]],
        sdes = [[在/player位置生成一个§o秋季结界§d
结界会跟随/player移动，且/player/spdR§g+50%]],
        detail = [[记§ya=能量等级
在/player位置生成一个§o秋季结界§d，可以消弹，
结界会跟随/player移动，且/player/spdR§g+50%
对结界内的敌人每帧造成§g(60+a*10)%/atk§d的伤害
同时会使/player§g/inv一段时间]],
        collabd = nil,
        unlockd = [[在/scenep3遇到/w18]],
        condd = nil,
        tags = tg.defend,
        activeType = 3,
        chargeC = 1 / 16,
        maxEnergy = 6,
        hold = false,
        cost = 1,
        event = function(self)
            New(lib.class.Autumn_Attack, int(self.energy))
            self.energy = self.energy % 1 + 1
            PlaySound("release")
        end,
        frameEvent = nil,
        condfunc = nil,
    },
    [27] = {
        name = [[季节解放·冬]],
        stitle = [[极端寒冬]],
        sdes = [[在/player位置生成一个§b冬季结界§d
/player/atkR暂时§g增加]],
        detail = [[记§ya=能量等级
在/player位置生成一个§b冬季结界§d，可以消弹，
对结界内的敌人每帧造成§g(100+a*10)%/atk§d的伤害
/player/atkR暂时§g+(a*10)%
同时会使/player§g/inv一小段时间]],
        collabd = nil,
        unlockd = [[在/scenep3遇到/w25]],
        condd = nil,
        tags = tg.defend,
        activeType = 3,
        chargeC = 1 / 16,
        maxEnergy = 6,
        hold = false,
        cost = 1,
        event = function(self)
            New(lib.class.Winter_Attack, int(self.energy))
            self.energy = self.energy % 1 + 1
            PlaySound("release")
        end,
        frameEvent = nil,
        condfunc = nil,
    },
    [28] = {
        name = [[季节解放·里]],
        stitle = [[休眠的生命]],
        sdes = [[在/player位置生成一个§c土用结界§d
可以消弹，造成§g一定伤害]],
        detail = [[在/player位置生成一个§c土用结界§d，可以消弹，
结界会往下运动
对结界内的敌人每帧造成§g50%/atk§d的伤害
同时会使/player§g/inv一段时间
§-每次只消耗100%的能量]],
        collabd = nil,
        unlockd = [[在/scenep3遇到/w47]],
        condd = nil,
        tags = tg.defend,
        activeType = 3,
        chargeC = 1 / 16,
        maxEnergy = 6,
        hold = false,
        cost = 1,
        event = function(self)
            New(lib.class.Doyou_Attack, int(self.energy))
            player.nextsp = 60
            PlaySound("release")
        end,
        frameEvent = nil,
        condfunc = nil,
    },
}