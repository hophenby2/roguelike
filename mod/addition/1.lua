local lib = stg_levelUPlib
local AddWaveEvent = lib.AddWaveEvent
local RemoveWaveEvent = lib.RemoveWaveEvent

local tg = stg_levelUPlib.tagslist

local function AfterActive()
    return scoredata.StartActive
end

return {
    [2] = {
        name = [[轻量储能包]],
        stitle = [[轻量，快捷，更方便！]],
        sdes = [[/spellme§g-11.1%]],
        detail = [[/t2sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[一局游戏内释放§p5次§d符卡]],
        condd = nil,
        tags = nil,
        picID = 85,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d)
            local v = lstg.var
            player_lib.SetEnergy(v.maxenergy - 11.1 * d)
        end,
        condfunc = nil,
    },
    [5] = {
        name = [[生命的丰穰]],
        stitle = [[丰收的喜悦]],
        sdes = [[每秒恢复微量/hp]],
        detail = [[记§ya=1
每帧恢复§ga*0.1/60§d/hp]],
        repeatd = [[§ya§d+1]],
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = tg.life,
        picID = 11,
        repeatp = 0,
        maxc = 3,
        initialTake = true,
        event = function(d, flag)
            if flag then
                if not IsValid(lstg.tmpvar.lifeadder) then
                    lstg.tmpvar.lifeadder = New(lib.class.lifeadder)
                else
                    local lifeadder = lstg.tmpvar.lifeadder
                    lifeadder.count = lifeadder.count + 1
                end
            else
                local lifeadder = lstg.tmpvar.lifeadder
                if IsValid(lifeadder) then
                    lifeadder.count = lifeadder.count - 1
                    if lifeadder.count == 0 then
                        Del(lifeadder)
                    end
                end
            end
        end,
        condfunc = nil,
    },
    [6] = {
        name = [[生命爆炸之药]],
        stitle = [[神风！]],
        sdes = [[/player被弹时会发生较大范围爆炸
消除敌弹且对敌人造成伤害]],
        detail = [[记§ya=1
/player被弹时产生持续§b45帧§d的消弹圈，
半径为§g66a§d，每帧造成§b0.66a/atk§d伤害]],
        repeatd = [[§ya§d+1]],
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = tg.defend,
        picID = 12,
        repeatp = 0,
        maxc = 3,
        initialTake = true,
        event = function(d, flag)
            local v = lstg.var
            v.life_boom = v.life_boom + d
            if flag and v.life_boom == 1 then
                player._playersys:addMissAfterEvent("life_boom", 1, function()
                    lib.class.lifeboom_func(player.x, player.y, (v.life_boom / 3) * 200, v.life_boom / 3 * 2,
                            45, 255, 227, 132)
                end)
            elseif not flag and v.life_boom == 0 then
                player._playersys:removeMissAfterEvent("life_boom")
            end
        end,
        condfunc = nil,
    },
    [20] = {
        name = [[纯粹的自信]],
        stitle = [[防御性攻击]],
        sdes = [[/player处于/inv状态时，/atk§g+50%]],
        detail = [[记§ya=1
/player处于/inv状态时，/atk§g+a*50%]],
        repeatd = [[§ya§d+1]],
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = nil,
        picID = 17,
        repeatp = 0,
        maxc = 2,
        initialTake = true,
        event = function(d, flag)
            if flag then
                if not IsValid(lstg.tmpvar.attackInProtect) then
                    lstg.tmpvar.attackInProtect = New(lib.class.attackInProtect)
                else
                    local attackInProtect = lstg.tmpvar.attackInProtect
                    attackInProtect.count = attackInProtect.count + 1
                end
            else
                local attackInProtect = lstg.tmpvar.attackInProtect
                if IsValid(attackInProtect) then
                    attackInProtect.count = attackInProtect.count - 1
                    if attackInProtect.count == 0 then
                        Del(attackInProtect)
                    end
                end
            end
        end,
        condfunc = nil,
    },
    [23] = {
        name = [[饥饿的狼犬]],
        stitle = [[嗜血狂怒]],
        sdes = [[/hp百分比越低，敌人受到的伤害越高]],
        detail = [[记§ya=1§d, §yp=/hp//maxhp
敌人受到的伤害倍率为§g1+(1-p)*(0.5+a/3)
§-该伤害倍率不会显示在/atk面板中]],
        repeatd = [[§ya§d+1]],
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = tg.sacrifice,
        picID = 20,
        repeatp = 0,
        maxc = 3,
        initialTake = true,
        event = function(d, flag)
            lstg.var.dmgfactor_withlifeleft = lstg.var.dmgfactor_withlifeleft + d
        end,
        condfunc = nil,
    },
    [35] = {
        name = [[幸运的招财猫]],
        stitle = [[喵喵喵，好运来！]],
        sdes = [[Lucky Wave出现的概率权重增加§g100§d，
遇到Lucky Wave后权重改为增加§g30]],
        detail = [[/t35sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[使用/playerMarisa/passtime2]],
        condd = nil,
        tags = nil,
        picID = 28,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.var.lucky_cat = flag
            lstg.var.meet_lucky_wave = 0
        end,
        condfunc = nil,
    },
    [38] = {
        name = [[光学迷彩服]],
        stitle = [[别人看不到你]],
        sdes = [[/hitb§g-0.1§d，同时/player贴图变得§r透明]],
        detail = [[记§ya=1
/hitb§g-0.1a
/plopca§r-a*33%]],
        repeatd = [[§ya§d+1]],
        collabd = nil,
        unlockd = [[获得过/t113]],
        condd = nil,
        tags = { tg.store, tg.debuff },
        picID = 31,
        repeatp = 0,
        maxc = 3,
        initialTake = true,
        event = function(d, flag)
            mission_lib.GoMission(130)
            local p = player
            player_lib.AddPlayerCollisize(-0.1 * d)
            p._wisys.alpha = p._wisys.alpha - 1 / 3 * d
        end,
        condfunc = nil,
    },
    [49] = {
        name = [[伊吹大山岚]],
        stitle = [[幻想的山之风]],
        sdes = [[/spd§b+0.25
每当敌怪发弹时，有§g7%§d概率使子弹变为半透明，§g失去判定]],
        detail = [[记§ya=1
/spd§b+0.25a
每当敌怪发弹时，有§g7a%§d概率使子弹变为半透明，§g失去判定]],
        repeatd = [[§ya§d+1]],
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = nil,
        picID = 42,
        repeatp = 0,
        maxc = 2,
        initialTake = true,
        event = function(d, flag)
            local p = player
            local v = lstg.var
            p.hspeed_offset = p.hspeed_offset + 0.25 * d
            p.lspeed_offset = p.lspeed_offset + 0.25 * d
            v.delete_bullet = v.delete_bullet + 0.07 * d
        end,
        condfunc = nil,
    },
    [57] = {
        name = [[积善成德]],
        stitle = [[重度收集狂]],
        sdes = [[每当拾取/expp时，随机触发§g有益效果
多次拾取时解锁更多§g有益效果]],
        detail = [[每当拾取/expp时，随机触发以下效果：
/hp§g+0.03§d, /exp§g+0.3§d, 分数§g+0.01%
/spelle§g+0.5%§d, /exp§g+0.7§d§-(2)
/hp§g+0.1§d, /atk§g+0.005§d, /maxhp§g+0.03§-(3)]],
        repeatd = [[叠加2个时解锁§-(2)§d，叠加3个时解锁§-(3)]],
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = nil,
        picID = 50,
        repeatp = 0,
        maxc = 3,
        initialTake = true,
        event = function(d, flag)
            lstg.var.accumulate_exp = lstg.var.accumulate_exp + d
        end,
        condfunc = nil,
    },
    [59] = {
        name = [[背扉的秘国]],
        stitle = [[后户之国]],
        sdes = [[增加一个后户之门在/player后方，
碰到此/minion的弹幕将被§g消除]],
        detail = [[/t59sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = tg.defend,
        picID = 52,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag, otherflag)
            if flag then
                lstg.tmpvar.back_door = New(lib.class.back_door)
                if not otherflag then
                    mission_lib.GoMission(34, 1 / 5 * 100)
                end
            else
                if IsValid(lstg.tmpvar.back_door) then
                    Del(lstg.tmpvar.back_door)
                end
            end
        end,
        condfunc = nil,
    },
    [60] = {
        name = [[损坏的空间]],
        stitle = [[连接月与海]],
        sdes = [[/player周围的空间出现坍缩
靠近/player的弹幕有§b24%§d概率被§b传送到屏幕的任意位置]],
        detail = [[靠近/player的弹幕有§b24%§d概率被§b传送到屏幕的任意位置
被传送的弹幕的速度、方向等保持不变]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[击败1次/bossYukari]],
        condd = nil,
        tags = { tg.defend, tg.debuff },
        picID = 54,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            if flag then
                lstg.tmpvar.broken_room = New(lib.class.broken_room)
                mission_lib.GoMission(23)
            else
                if IsValid(lstg.tmpvar.broken_room) then
                    Del(lstg.tmpvar.broken_room)
                end
            end
        end,
        condfunc = nil,
    },
    [70] = {
        name = [[太阳表面]],
        stitle = [[地上太阳]],
        sdes = [[在版底形成一个"太阳"，为了躲避"太阳"
敌人、敌方子弹和掉落物等都有§b向上运动的趋势]],
        detail = [[在版底形成一个太阳
有"生命体征"的敌人、敌方子弹和掉落物等
§b都有向上运动的趋势，碰到版底时直接消除
§-他们都不想被太阳消灭！]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = { tg.defend, tg.debuff },
        picID = 58,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            if flag then
                lstg.tmpvar.SUN = New(lib.class2.SUN)
            else
                if IsValid(lstg.tmpvar.SUN) then
                    Del(lstg.tmpvar.SUN)
                end
            end
        end,
        condfunc = nil,
    },
    [75] = {
        name = [[颂德之玉]],
        stitle = [[密葬]],
        sdes = [[所有大玉都§g不再对/player造成伤害]],
        detail = [[/t75sdes]],
        repeatd = nil,
        collabd = [[/t48：所有大玉变为红色]],
        unlockd = nil,
        condd = nil,
        tags = nil,
        picID = 63,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.var.friendly_ball_huge = flag
        end,
        condfunc = nil,
    },
    [79] = {
        name = [[以血换血]],
        stitle = [[以牙还牙]],
        sdes = [[每当/player失去/hp时，对所有敌怪造成§g50%/atk§d的伤害
有§b45帧§d的冷却时间]],
        detail = [[/t79sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[死亡§p1§d次]],
        condd = nil,
        tags = tg.sacrifice,
        picID = 67,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.var.lifelife_exchange = flag
            local tvar = lstg.tmpvar
            if flag then
                tvar.lifelife_exchangeCD = 0
                player._playersys:addFrameBeforeEvent("del_lifelife_exchangeCD", 1, function()
                    tvar.lifelife_exchangeCD = max(0, tvar.lifelife_exchangeCD - 1)
                end)
            else
                player._playersys:removeFrameBeforeEvent("del_lifelife_exchangeCD")
                tvar.lifelife_exchangeCD = nil
            end
        end,
        condfunc = nil,
    },
    [82] = {
        name = [[月与海的传送门]],
        stitle = [[静海浮月]],
        sdes = [[/spd§b+0.35
§g允许/player移动到版外§d，但会出现强大的斥力让/player回到版内]],
        detail = [[§g允许/player移动到版外
在版外待的越久，会出现越强大的斥力让/player回到版内
/spd§b+0.35]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[获得过/t60]],
        condd = nil,
        tags = tg.tp,
        picID = 71,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            local p = player
            p.hspeed_offset = p.hspeed_offset + 0.35 * d
            p.lspeed_offset = p.lspeed_offset + 0.35 * d
            local v = lstg.var
            v.borderless_moving = flag
            player.outborder_time = 0
            player.borderless_offset = 0
        end,
        condfunc = nil,
    },
    [91] = {
        name = [[完美散华]],
        stitle = [[自动式全方位射击]],
        sdes = [[场上每出现§b99§d颗/pbullet，/player发射/pbullet开花弹]],
        detail = [[记§ya=1
场上每出现§b99§d颗/pbullet，
/player发射条数§g9a§d的/pbullet开花弹]],
        repeatd = [[§ya§d+1]],
        collabd = nil,
        unlockd = [[/passtime8]],
        condd = nil,
        tags = nil,
        picID = 80,
        repeatp = 0,
        maxc = 2,
        initialTake = true,
        event = function(d, flag)
            local v = lstg.var
            v.perfect_spread = v.perfect_spread + d
        end,
        condfunc = nil,
    },
    [92] = {
        name = [[寂静的冬天]],
        stitle = [[北风萧萧]],
        sdes = [[敌人死亡时，从版顶飘落雪花，每片雪花造成§g(1+50%)/atk§d伤害]],
        detail = [[敌人死亡时，从版顶飘落§b1~2§d片雪花，每片雪花造成§g(1+50%)/atk§d伤害
§-屏幕上方微微变蓝]],
        repeatd = nil,
        collabd = [[/t48：雪花变为粉红色
/t70：雪花飘过版中时透明度不断降低直至消失]],
        unlockd = [[一局游戏内拥有/t45和/t24]],
        condd = nil,
        tags = nil,
        picID = 81,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            if flag then
                lstg.tmpvar.fallen_snow_winter_ef = New(lib.class2.fallen_snow_winter_ef)
                player._playersys:addEnemyKillEvent("fallen_snow", 1, function()
                    for _ = 1, ran:Int(1, 2) do
                        New(lib.class2.fallen_snow_bullet, ran:Float(-300, 300), 250)
                    end
                end)
            else
                if IsValid(lstg.tmpvar.fallen_snow_winter_ef) then
                    Del(lstg.tmpvar.fallen_snow_winter_ef)
                end
                player._playersys:removeEnemyKillEvent("fallen_snow")
            end
        end,
        condfunc = nil,
    },
    [95] = {
        name = [[赤蛮奇之头]],
        stitle = [[可怖的注视]],
        sdes = [[生成3个赤蛮奇的头，自动寻找并围绕着敌人外部旋转
每帧造成§g16%/atk§d伤害]],
        detail = [[/t95sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[/passtime9]],
        condd = nil,
        tags = nil,
        picID = 84,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            if flag then
                lstg.tmpvar.sekibanki_head = {}
                for i = 1, 3 do
                    table.insert(lstg.tmpvar.sekibanki_head, New(lib.class2.sekibanki_head, i * 120))
                end
            else
                for _, p in ipairs(lstg.tmpvar.sekibanki_head) do
                    if IsValid(p) then
                        Del(p)
                    end
                end
            end
        end,
        condfunc = nil,
    },
    [97] = {
        name = [[龙颈之玉]],
        stitle = [[五色的弹丸]],
        sdes = [[环绕一名敌人发射五色风车弹，每颗造成§g20%/atk§d伤害]],
        detail = [[选中一个敌人，使其每§b5帧§d向外发射五色的环玉风车弹
每颗弹造成§g20%/atk§d伤害]],
        repeatd = nil,
        collabd = [[/t122：当风车弹达到面板§b50%§d/br时，将反转速度方向]],
        unlockd = [[收取§p"神宝「耀眼的龙玉」"]],
        condd = nil,
        tags = tg.neet,
        picID = 86,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            if flag then
                lstg.tmpvar.dragon_jade = New(lib.class3.dragon_jade)
            else
                if IsValid(lstg.tmpvar.dragon_jade) then
                    Del(lstg.tmpvar.dragon_jade)
                end
            end
        end,
        condfunc = nil,
    },
    [99] = {
        name = [[火鼠的皮衣]],
        stitle = [[不焦躁的内心]],
        sdes = [[移动时向后发射火焰弹，每颗造成§g58%/atk§d的伤害]],
        detail = [[每当/player移动时，每§b3帧§d向反方向发射微型火弹
火弹对敌怪造成§g58%/atk§d伤害]],
        repeatd = nil,
        collabd = [[/t74：重生后，生成火焰弹的间隔减小，最小为§g1帧§d
/t72：火焰弹获得小范围的§p追踪效果]],
        unlockd = [[收取§p"神宝「火蜥蜴之盾」"]],
        condd = nil,
        tags = tg.neet,
        picID = 88,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            if flag then
                lstg.tmpvar.fire_drop_shooter = New(lib.class3.fire_drop_shooter)
            else
                if IsValid(lstg.tmpvar.fire_drop_shooter) then
                    Del(lstg.tmpvar.fire_drop_shooter)
                end
            end
        end,
        condfunc = nil,
    },
    [103] = {
        name = [[公转轨道异常]],
        stitle = [[我离太阳越来越远了吗？]],
        sdes = [[所有季节时长§b延长1波]],
        detail = [[/t103sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[通过/scenep2]],
        condd = [[存在/wxsys]],
        tags = { tg.debuff },
        picID = 92,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            local w = lstg.weather
            for i = 1, 5 do
                w.season_last[i] = w.season_last[i] + d
            end
        end,
        condfunc = function()
            return lstg.var._season_system and not lstg.var._pathlike
        end,
    },
    [104] = {
        name = [[天气之神的眷顾]],
        stitle = [[天气之子]],
        sdes = [["祥瑞"类的天气出现的概率提高§g25%]],
        detail = [[/t104sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = [[存在/wxsys]],
        tags = nil,
        picID = 93,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.weather.TwiceXiangRui = flag
        end,
        condfunc = function()
            return lstg.var._season_system and not lstg.var._pathlike
        end,
    },
    [109] = {
        name = [[量子弹幕]],
        stitle = [[可控的未来]],
        sdes = [[消除弹幕时，随机消除§g1§d颗同弹型的弹幕]],
        detail = [[/t109sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = tg.store,
        picID = 98,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.var.quantum_bullet = flag
        end,
        condfunc = nil,
    },
    [110] = {
        name = [[幻无垢]],
        stitle = [[带走你的污秽]],
        sdes = [[敌人死亡时，消除离其最近的§g1§d颗弹幕
/hp归§r0§d时清空场上的弹幕]],
        detail = [[/t110sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = nil,
        picID = 99,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.var.del_bullet_with_enemy = flag
            if flag then
                player._playersys:addEnemyKillEvent("del_bullet_with_enemy", 1, function(_, _, self)
                    local minD = 999
                    local target
                    object.BulletDo(function(b)
                        local sd = Dist(b, self)
                        if sd < minD then
                            target = b
                            minD = sd
                        end
                    end)
                    if IsValid(target) then
                        Del(target)
                    end
                end)
            else
                player._playersys:removeEnemyKillEvent("del_bullet_with_enemy")
            end
        end,
        condfunc = nil,
    },
    [117] = {
        name = [[佛的御石钵]],
        stitle = [[不碎的意志]],
        sdes = [[被弹/升级获得的/inv时间额外增加§g0.6秒]],
        detail = [[/t117sdes]],
        repeatd = nil,
        collabd = [[/t63：玩偶生成时玩偶额外获得§g30帧§d/inv时间]],
        unlockd = [[收取§p"神宝「佛体的舍利子」"]],
        condd = nil,
        tags = { tg.neet, tg.defend },
        picID = 106,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            local v = lstg.var
            v.protect_time_ex = v.protect_time_ex + 36 * d
            v.buddhist_diamond = flag
        end,
        condfunc = nil,
    },
    [118] = {
        name = [[加长反射弧]],
        stitle = [[受伤了？]],
        sdes = [[/player受到伤害时，保留/inv时间但不扣除/hp，
间隔§b120帧§d后才失去/hp§-(附带完整/inv时间)]],
        detail = [[/t118sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[/passtime8]],
        condd = nil,
        tags = { tg.defend, tg.debuff },
        picID = 107,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            lstg.var.reflex_arc = flag
        end,
        condfunc = nil,
    },
    [120] = {
        name = [[自指悖论]],
        stitle = [[x = x]],
        sdes = [[每当发射主炮时，有§g7.7%§d概率向随机方向发射§b1枚§d主炮
每有1个/item，概率§g*105%]],
        detail = [[/t120sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = nil,
        picID = 109,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            lstg.var.self_paradox = flag
        end,
        condfunc = nil,
    },
    [121] = {
        name = [[黑雾异变]],
        stitle = [[I can't see Forever!]],
        sdes = [[/player周围出现黑色圆形区域，
区域内的敌人受到的伤害额外§g+75%]],
        detail = [[/t121sdes]],
        repeatd = nil,
        collabd = [[/t126：黑圈不断出现向外扩散的特效]],
        unlockd = nil,
        condd = nil,
        tags = nil,
        picID = 110,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            if flag then
                lstg.tmpvar.black_fog_circle = New(lib.class2.black_fog_circle)
            else
                if IsValid(lstg.tmpvar.black_fog_circle) then
                    Del(lstg.tmpvar.black_fog_circle)
                end
            end
        end,
        condfunc = nil,
    },

    [141] = {
        name = [[上海人偶]],
        stitle = [[爱丽丝宝宝]],
        sdes = [[获得一个人偶追随型/minion
对角四向发射§g小针弹§d，造成§g1.0§d的伤害]],
        detail = [[/t141sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = tg.baby,
        picID = 130,
        repeatp = 0,
        maxc = 3,
        initialTake = true,
        event = function(d, flag)
            if flag then
                lstg.tmpvar.ningyou_baby = lstg.tmpvar.ningyou_baby or {}
                table.insert(lstg.tmpvar.ningyou_baby, New(lib.class4.ningyou_baby))
            else
                if lstg.tmpvar.ningyou_baby then
                    if IsValid(lstg.tmpvar.ningyou_baby[1]) then
                        Del(lstg.tmpvar.ningyou_baby[1])
                        table.remove(lstg.tmpvar.ningyou_baby, 1)
                    end
                end
            end
        end,
        condfunc = nil,
    },
    [145] = {
        name = [[死宛团子宝宝]],
        stitle = [[my name is fashion]],
        sdes = [[获得一个团子追随型/minion
发射短距离开花子弹攻击敌人，每颗造成§g1.0§d的伤害]],
        detail = [[/t145sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = { tg.siyuan, tg.baby },
        picID = 134,
        repeatp = 0,
        maxc = 3,
        initialTake = true,
        event = function(d, flag)
            if flag then
                lib.siyuan_achievement()
                lstg.tmpvar.siyuan_baby1 = lstg.tmpvar.siyuan_baby1 or {}
                table.insert(lstg.tmpvar.siyuan_baby1, New(lib.class4.siyuan_baby1))
            else
                if lstg.tmpvar.siyuan_baby1 then
                    if IsValid(lstg.tmpvar.siyuan_baby1[1]) then
                        Del(lstg.tmpvar.siyuan_baby1[1])
                        table.remove(lstg.tmpvar.siyuan_baby1, 1)
                    end
                end
            end
        end,
        condfunc = nil,
    },
    [146] = {
        name = [[安产大炮]],
        stitle = [[无底的沉溺]],
        sdes = [[/ss§g+1.4
/player将以一定的角速度旋转发射方向，§g自动瞄准敌人射击]],
        detail = [[记§ya=/bv
/ss§g+1.4
/player将以§g4*a°/s§d的角速度旋转发射方向，§g自动瞄准敌人射击]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = { tg.debuff },
        picID = 135,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local ss = player.shoot_set.speed
            ss.offset = ss.offset + 1.4 * d
            lstg.var.rotate_shoot_rot = flag
        end,
        condfunc = nil,
    },
    [148] = {
        name = [[流汗猫猫]],
        stitle = [[汗颜了]],
        sdes = [[获得一个猫猫追随型/minion
向下发射子弹，每颗造成§g1.0§d的伤害]],
        detail = [[/t148sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = tg.baby,
        picID = 137,
        repeatp = 0,
        maxc = 3,
        initialTake = true,
        event = function(d, flag)
            if flag then
                lstg.tmpvar.sweat_cat = lstg.tmpvar.sweat_cat or {}
                table.insert(lstg.tmpvar.sweat_cat, New(lib.class4.sweat_cat))
            else
                if lstg.tmpvar.sweat_cat then
                    if IsValid(lstg.tmpvar.sweat_cat[1]) then
                        Del(lstg.tmpvar.sweat_cat[1])
                        table.remove(lstg.tmpvar.sweat_cat, 1)
                    end
                end
            end
        end,
        condfunc = nil,
    },
    [149] = {
        name = [[大喷菇]],
        stitle = [[网络喷子]],
        sdes = [[获得一个大喷菇追随型/minion
向/player身后发射子弹，每颗造成§g1.0§d的伤害]],
        detail = [[/t149sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = tg.baby,
        picID = 138,
        repeatp = 0,
        maxc = 3,
        initialTake = true,
        event = function(d, flag)
            if flag then
                lstg.tmpvar.mushroom_baby = lstg.tmpvar.mushroom_baby or {}
                table.insert(lstg.tmpvar.mushroom_baby, New(lib.class4.mushroom_baby))
            else
                if lstg.tmpvar.mushroom_baby then
                    if IsValid(lstg.tmpvar.mushroom_baby[1]) then
                        Del(lstg.tmpvar.mushroom_baby[1])
                        table.remove(lstg.tmpvar.mushroom_baby, 1)
                    end
                end
            end
        end,
        condfunc = nil,
    },
    [154] = {
        name = [[梅露兰的小号]],
        stitle = [[激情二射]],
        sdes = [[/atkR§r-70%§d
/ss§g+2§d，/ssR§g+200%§d]],
        detail = [[/t154sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[通关§p挑战6]],
        condd = nil,
        tags = { tg.debuff },
        picID = 143,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local p = player
            p.dmg_fixed = p.dmg_fixed - 0.7 * d
            local ss = p.shoot_set.speed
            ss.offset = ss.offset + 2 * d
            ss.fixed = ss.fixed + 2 * d
            local var = lstg.var
            var.player_bullet_scale_factor = var.player_bullet_scale_factor - 0.3 * d
        end,
        condfunc = nil,
    },
    [156] = {
        name = [[膜膜膜]],
        stitle = [[顶礼膜拜]],
        sdes = [[/atk§g+0.2§d，获得一个膜图追随型/minion
向下发射子弹，每颗造成§g1.0§d的伤害]],
        detail = [[/t156sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = { tg.siyuan, tg.baby },
        picID = 145,
        repeatp = 0,
        maxc = 3,
        initialTake = true,
        event = function(d, flag)
            player.dmg_offset = player.dmg_offset + 0.2 * d
            if flag then
                lib.siyuan_achievement()
                lstg.tmpvar.siyuan_baby4 = lstg.tmpvar.siyuan_baby4 or {}
                table.insert(lstg.tmpvar.siyuan_baby4, New(lib.class4.siyuan_baby4))
            else
                if lstg.tmpvar.siyuan_baby4 then
                    if IsValid(lstg.tmpvar.siyuan_baby4[1]) then
                        Del(lstg.tmpvar.siyuan_baby4[1])
                        table.remove(lstg.tmpvar.siyuan_baby4, 1)
                    end
                end
            end
        end,
        condfunc = nil,
    },
    [159] = {
        name = [[小小星之伞]],
        stitle = [[遮风避雨]],
        sdes = [[每当/player受伤时，在/player前方生成一把伞§g阻挡弹幕
伞持续时间§b90帧§d，冷却时间§b90帧§d]],
        detail = [[/t159sdes]],
        repeatd = nil,
        collabd = [[/t70：伞往上漂浮]],
        unlockd = [[击败1次/bossKogasa]],
        condd = nil,
        tags = { tg.defend, tg.store },
        picID = 148,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            local v = lstg.var
            local CD = 0
            if flag then
                player._playersys:addFrameBeforeEvent("protect_kogasa_CD", 1, function()
                    CD = max(CD - 1, 0)
                end)
                player._playersys:addMissAfterEvent("protect_kogasa", 1, function(p)
                    if CD == 0 then
                        local Y = 60
                        if v.reverse_shoot then
                            Y = -Y
                        end
                        PlaySound("boon00")
                        New(lib.class4.protect_kogasa, p.x, p.y + Y)
                        CD = 90
                    end
                end)
            else
                player._playersys:removeFrameBeforeEvent("protect_kogasa_CD")
                player._playersys:removeMissAfterEvent("protect_kogasa")
            end
        end,
        condfunc = nil,
    },
    [160] = {
        name = [[Game Killer]],
        stitle = [[...]],
        sdes = [[获得/expp时生成§g自瞄子弹
每发造成§g当前游戏版本号§d点伤害]],
        detail = [[/t160sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[通关§p挑战2]],
        condd = nil,
        tags = nil,
        picID = 149,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            local v = lstg.var
            v.game_killer = flag
        end,
        condfunc = nil,
    },
    [163] = {
        name = [[摆烂小孩]],
        stitle = [[开摆]],
        sdes = [[获得一个摆烂宝宝追随型/minion，不做任何事情
结算时计算摆烂宝宝存在个数，下局游戏开始时获得§g等量死宛宝宝]],
        detail = [[/t163sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[一局游戏内达到§p35§d级]],
        condd = [[不会在/challmode中出现]],
        tags = { tg.siyuan, tg.baby },
        picID = 152,
        repeatp = 0,
        maxc = 10,
        initialTake = true,
        event = function(d, flag)
            if flag then
                lib.siyuan_achievement()
                lstg.tmpvar.siyuan_baby5 = lstg.tmpvar.siyuan_baby5 or {}
                table.insert(lstg.tmpvar.siyuan_baby5, New(lib.class4.siyuan_baby5))
            else
                if lstg.tmpvar.siyuan_baby5 then
                    if IsValid(lstg.tmpvar.siyuan_baby5[1]) then
                        Del(lstg.tmpvar.siyuan_baby5[1])
                        table.remove(lstg.tmpvar.siyuan_baby5, 1)
                    end
                end
            end
        end,
        condfunc = function()
            return not stage.current_stage.is_challenge
        end,
    },
    [165] = {
        name = [[旋转水皿]],
        stitle = [[覆水难收]],
        sdes = [[每波开始时生成§g3§d个可阻挡弹幕的水皿
吸收弹幕后有概率破碎，并向上抛射大量§g我方子弹]],
        detail = [[记§ya=水皿个体阻挡的弹数
每波开始时生成§g3§d个可阻挡弹幕的水皿
水皿可阻挡弹幕，每次阻挡有§b0.5a%§d的概率碎裂，
向上方投射§ya§d颗水弹，每颗造成§g120%/atk§d伤害]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = { tg.defend, tg.store },
        picID = 154,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            if flag then
                AddWaveEvent("protect_dish", 1, function()
                    for _ = 1, 3 do
                        New(lib.class4.protect_dish, ran:Float(-290, 290), ran:Float(-200, 200))
                    end
                end)
            else
                RemoveWaveEvent("protect_dish")
            end
        end,
        condfunc = nil,
    },
    [167] = {
        name = [[旋转猫猫]],
        stitle = [[可爱捏]],
        sdes = [[场上出现一个旋转猫猫在屏幕中飞行
对敌人造成§g12%/atk§d的接触伤害]],
        detail = [[/t167sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = tg.siyuan,
        picID = 156,
        repeatp = 0,
        maxc = 3,
        initialTake = true,
        event = function(d, flag)
            if flag then
                lstg.tmpvar.rotate_cat = lstg.tmpvar.rotate_cat or {}
                table.insert(lstg.tmpvar.rotate_cat, New(lib.class5.rotate_cat, #lstg.tmpvar.rotate_cat))

            else
                if lstg.tmpvar.rotate_cat then
                    if IsValid(lstg.tmpvar.rotate_cat[1]) then
                        Del(lstg.tmpvar.rotate_cat[1])
                        table.remove(lstg.tmpvar.rotate_cat, 1)
                    end
                end
            end
        end,
        condfunc = nil,
    },
    [168] = {
        name = [[黄豆包]],
        stitle = [[黄豆粉灵魂的包子]],
        sdes = [[获得一个黄豆猫猫围绕/player
射击时猫猫飞出去打击敌人，造成§g42%/atk§d的接触伤害]],
        detail = [[/t168sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[击败1次/bossRingo]],
        condd = nil,
        tags = tg.store,
        picID = 157,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            if flag then
                lib.bun_cat_achievement()
                lstg.tmpvar.bun_cat1 = New(lib.class5.bun_cat, 1)
            else
                if IsValid(lstg.tmpvar.bun_cat1) then
                    Del(lstg.tmpvar.bun_cat1)
                end
            end
        end,
        condfunc = nil,
    },
    [169] = {
        name = [[红豆包]],
        stitle = [[寻求者包子]],
        sdes = [[获得一个红豆猫猫围绕/player
射击时猫猫飞出去打击敌人，造成§g42%/atk§d的接触伤害]],
        detail = [[/t169sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[击败1次/bossRingo]],
        condd = nil,
        tags = tg.store,
        picID = 158,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            if flag then
                lib.bun_cat_achievement()
                lstg.tmpvar.bun_cat2 = New(lib.class5.bun_cat, 2)
            else
                if IsValid(lstg.tmpvar.bun_cat2) then
                    Del(lstg.tmpvar.bun_cat2)
                end
            end
        end,
        condfunc = nil,
    },
    [170] = {
        name = [[绿豆包]],
        stitle = [[渴望者包子]],
        sdes = [[获得一个绿豆猫猫围绕/player
射击时猫猫飞出去打击敌人，造成§g42%/atk§d的接触伤害]],
        detail = [[/t170sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[击败1次/bossRingo]],
        condd = nil,
        tags = tg.store,
        picID = 159,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            if flag then
                lib.bun_cat_achievement()
                lstg.tmpvar.bun_cat3 = New(lib.class5.bun_cat, 3)
            else
                if IsValid(lstg.tmpvar.bun_cat3) then
                    Del(lstg.tmpvar.bun_cat3)
                end
            end
        end,
        condfunc = nil,
    },
    [171] = {
        name = [[蓝豆包]],
        stitle = [[喜爱者包子]],
        sdes = [[获得一个蓝豆猫猫围绕/player
射击时猫猫飞出去打击敌人，造成§g42%/atk§d的接触伤害]],
        detail = [[/t171sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[击败1次/bossRingo]],
        condd = nil,
        tags = tg.store,
        picID = 160,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            if flag then
                lib.bun_cat_achievement()
                lstg.tmpvar.bun_cat4 = New(lib.class5.bun_cat, 4)
            else
                if IsValid(lstg.tmpvar.bun_cat4) then
                    Del(lstg.tmpvar.bun_cat4)
                end
            end
        end,
        condfunc = nil,
    },
    [172] = {
        name = [[垒叠的石头]],
        stitle = [[原地tp]],
        sdes = [[拾取时提升§g1§d级
每级升级所需/exp降低§g1§d级]],
        detail = [[/t172sdes]],
        repeatd = [[提高§g999§d倍获得权重]],
        collabd = nil,
        unlockd = [[使用/playerChiruno/passtime1]],
        condd = nil,
        tags = nil,
        picID = 161,
        repeatp = 999,
        maxc = 3,
        initialTake = false,
        event = function(d, flag, otherflag)
            local v = lstg.var
            v.level_offset = v.level_offset - 1 * d
            if flag and not otherflag then
                AddExp((lib.GetCurMaxEXP() - v.now_exp + 1) / player_lib.GetEXPfactor())
            end
        end,
        condfunc = nil,
    },
    [178] = {
        name = [[大地的富饶]],
        stitle = [[令人难舍]],
        sdes = [[/player位于画面最底部时，/expR+§g30%]],
        detail = [[/t178sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[/passtime7]],
        condd = nil,
        tags = nil,
        picID = 213,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local v = lstg.var
            v.booming_earth = flag

        end,
        condfunc = nil,
    },
    [180] = {
        name = [[电子木鱼]],
        stitle = [[功德+1]],
        sdes = [[每隔几秒§y敲出§d一些经验点]],
        detail = [[记§ya=3
每隔§ya§d秒在/player前方生成§y0~5§d颗经验点]],
        repeatd = [[§ya§d-1]],
        collabd = nil,
        unlockd = [[使用/playerYoumu/passtime1]],
        condd = nil,
        tags = nil,
        picID = 164,
        repeatp = 0,
        maxc = 3,
        initialTake = true,
        event = function(d, flag)
            local v = lstg.var
            local count = 0
            v.elec_fish = v.elec_fish + d
            if flag and v.elec_fish == 1 then
                player._playersys:addFrameBeforeEvent("elec_fish", 1, function()
                    if v.frame_counting then
                        count = count + 1
                        while count >= 240 - v.elec_fish * 60 do
                            DropExpPoint(ran:Int(0, 5), player.x, player.y + 40)
                            count = count - (240 - v.elec_fish * 60)
                        end
                    end
                end)
            elseif not flag and v.elec_fish == 0 then
                player._playersys:removeFrameBeforeEvent("elec_fish")
            end
        end,
        condfunc = nil,
    },
    [186] = {
        name = [[槐安通路]],
        stitle = [[禁锢槐安]],
        sdes = [[/ss§g+0.7§d，/br§g+3
/pbullet将跟随/player移动而移动]],
        detail = [[/t186sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[击败1次/bossDoremy]],
        condd = nil,
        tags = nil,
        picID = 170,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            mission_lib.GoMission(117)
            local ss = player.shoot_set.speed
            ss.offset = ss.offset + 0.7 * d
            local sr = player.shoot_set.range
            sr.offset = sr.offset + 3 * d
            local v = lstg.var
            v.following_main_bullet = flag
        end,
        condfunc = nil,
    },
    [188] = {
        name = [[落向地狱的雨]],
        stitle = [[极乐净土]],
        sdes = [[每当敌人死亡时，
在其位置向正下方发射1枚§g100%/atk§d伤害的子弹]],
        detail = [[/t188sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[/passtime5]],
        condd = nil,
        tags = nil,
        picID = 172,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            if flag then
                player._playersys:addEnemyKillEvent("rain_of_hell", 1, function(_, _, self)
                    local bv = player.cur_bv
                    local dmg = player.damage
                    local class = lib.class.hell_bullet
                    local A = -90
                    local b = New(class, self.x, self.y, bv, A, dmg)
                    b.colli = false
                    task.New(b, function()
                        task.Wait()
                        b.colli = true
                    end)
                end)
            else
                player._playersys:removeEnemyKillEvent("rain_of_hell")
            end
        end,
        condfunc = nil,
    },

    [190] = {
        name = [[经纬仪]],
        stitle = [[天涯海角]],
        sdes = [[/player判定点§g始终显示§d，且§g显示/itcl
/hitb§g-0.05§d，/hp满时/hitb§g-0.05§d]],
        detail = [[/t190sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[获得过/t38]],
        condd = nil,
        tags = nil,
        picID = 174,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local var = lstg.var
            var.forever_show_grazer = flag
            player_lib.AddPlayerCollisize(-0.05 * d)
        end,
        condfunc = nil,
    },
    [191] = {
        name = [[递质不耐受]],
        stitle = [[受体绝结]],
        sdes = [[每回合第一次受击/inv时间§g+300%]],
        detail = [[/t191sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[/passtime8]],
        condd = nil,
        tags = tg.defend,
        picID = 175,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            local var = lstg.var
            var.first_miss_protect = flag
        end,
        condfunc = nil,
    },
    [192] = {
        name = [[浓缩熵]],
        stitle = [[空间萃取]],
        sdes = [[随机获得§p6§d个交易]],
        detail = [[/t192sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[/passtime10]],
        condd = nil,
        tags = { tg.debuff },
        picID = 176,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag, otherflag)
            if flag and not otherflag then
                local list = {}
                for _ = 1, 6 do
                    local jiaoyi = lib.GetAdditionList(1, function(p)
                        return p.state == 2
                    end)
                    table.insert(list, jiaoyi[1])
                end
                ext.popup_menu:FlyIn(i18n("addition_des", 2)[192].name, 218, 112, 214, list, "bonus")
                for _, p in ipairs(list) do
                    p:Set()
                end
            end
        end,
        condfunc = nil,
    },
    [204] = {
        name = [[强身健体]],
        stitle = [[练得壮壮的]],
        sdes = [[/hitb§r+10%§d
/maxhp§g+8]],
        detail = [[/t204sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[/passtime10]],
        condd = nil,
        tags = { tg.store, tg.debuff },
        picID = 204,
        repeatp = 0,
        maxc = 3,
        initialTake = true,
        event = function(d, flag)
            player_lib.AddMaxLife(8 * d)
            player_lib.AddPlayerCollisize(nil, 0.1 * d, 0)
        end,
        condfunc = nil,
    },
    [205] = {
        name = [[亘古的恨意]],
        stitle = [[血债血偿]],
        sdes = [[每当/player受伤时，增加§g2%§d/atk和§g0.1§d/ss]],
        detail = [[/t205sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[死亡§p20§d次]],
        condd = nil,
        tags = tg.sacrifice,
        picID = 205,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.var.hate_add = flag
        end,
        condfunc = nil,
    },
    [209] = {
        name = [[多普勒突击]],
        stitle = [[突进]],
        sdes = [[§b向前移动§d时，基于移速使/ss暂时§g增加]],
        detail = [[记§yk§d = sqrt(移速)*10
§b向前移动§d时，/ss§g增加§yk§g%§d]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = nil,
        picID = 211,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.var.doppler_effect = flag
        end,
        condfunc = nil,
    },
    [210] = {
        name = [[华彩波纹]],
        stitle = [[滞空]],
        sdes = [[/expp下落速度§g-30%]],
        detail = [[/t210sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[/passtime10]],
        condd = nil,
        tags = nil,
        picID = 210,
        repeatp = 0,
        maxc = 2,
        initialTake = false,
        event = function(d, flag)
            local v = lstg.var
            v.exp_drop_factor = v.exp_drop_factor - 0.30 * d
        end,
        condfunc = nil,
    },
    [211] = {
        name = [[背水阵]],
        stitle = [[后撤步]],
        sdes = [[§b向后移动§d时，/hitb§g-0.2§d]],
        detail = [[/t211sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[/passtime10]],
        condd = nil,
        tags = nil,
        picID = 212,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.var.beishui_effect = flag
        end,
        condfunc = nil,

    },

}