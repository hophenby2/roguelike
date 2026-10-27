local tg = stg_levelUPlib.tagslist
local lib = activeItem_lib

return {
    [1] = {
        name = [[携带TNT]],
        stitle = [[这才是神风！]],
        sdes = [[使/player发生爆炸§-(视作受击)
产生消弹圈，同时对敌人造成伤害]],
        detail = [[使/player发生§r爆炸§-(视作受击)§d，失去一定的/hp
产生半径与/atk的平方根成正比的§y消弹圈
持续时间§b30帧§d，每帧造成§g600%/atk§d的伤害]],
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = { tg.sacrifice, tg.debuff },
        activeType = 1,
        chargeC = 1.000000,
        maxEnergy = 1,
        hold = false,
        cost = 1.000000,
        event = function(self)
            PlaySound("explode")
            local p = player
            --p.nextsp = 5--小冷却
            player_lib.PlayerMiss(p, 5, "kamikaze")
            Newcharge_out(p.x, p.y, 250, 128, 114)
            local dmg = player.damage
            local R = sqrt(dmg) * 75
            stg_levelUPlib.class.lifeboom_func(p.x, p.y, R, dmg * 6, 30, 250, 128, 114)
        end,
        frameEvent = nil,
        condfunc = nil,
    },
    [2] = {
        name = [[全都睡觉吧！]],
        stitle = [[开摆]],
        sdes = [[/once
将当前的所有宝宝转化成/t163]],
        detail = [[/a2sdes]],
        collabd = [[/t163：
/t163detail]],
        unlockd = nil,
        condd = nil,
        tags = { tg.debuff },
        activeType = 1,
        chargeC = 0.000000,
        maxEnergy = 1,
        hold = false,
        cost = 0,
        event = function(self)
            PlaySound("goast2")
            self:Remove()
            player.nextsp = 5
            local v = lstg.var
            for _, id in ipairs(stg_levelUPlib.class4.baby_idList) do
                if id ~= 163 then
                    if v.addition[id] then
                        for _ = 1, v.addition[id] do
                            stg_levelUPlib.AdditionTotalList[id]:Remove()
                            stg_levelUPlib.AdditionTotalList[163]:Set()
                        end
                    end
                end
            end
        end,
        frameEvent = nil,
        condfunc = nil,
    },
    [12] = {
        name = [[坐标系]],
        stitle = [[建系哥又来了]],
        sdes = [[让弹幕§g随着/player移动而移动]],
        detail = [[/a12sdes]],
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = nil,
        activeType = 1,
        chargeC = 1,
        maxEnergy = 1,
        hold = true,
        cost = 0,
        event = function(self)
            local descartes = function(e)
                if not e.not_move then
                    e.x = e.x + player.dx
                    e.y = e.y + player.dy
                end
            end
            object.BulletDo(descartes)
        end,
        frameEvent = nil,
        condfunc = nil,
    },
}