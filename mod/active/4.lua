local tg = stg_levelUPlib.tagslist
local lib = activeItem_lib

return {
    [3] = {
        name = [[蓝莓浆果]],
        stitle = [[栓栓的]],
        sdes = [[使当前波内所有发射的/pbullet为§b蓝色/pbullet
被击中的敌人将掉落§g1§d颗/expp]],
        detail = [[/a3sdes]],
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = nil,
        activeType = 2,
        chargeC = 0.300000,
        maxEnergy = 1,
        hold = false,
        cost = 0.900000,
        event = function(self)
            PlaySound("eatfood")
            lstg.wave.all_blue_bullet = true
        end,
        frameEvent = nil,
        condfunc = nil,
    },


}