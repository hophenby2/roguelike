local lib = stg_levelUPlib
local AddWaveEvent = lib.AddWaveEvent
local RemoveWaveEvent = lib.RemoveWaveEvent

local tg = stg_levelUPlib.tagslist

local function AfterActive()
    return scoredata.StartActive
end

return {
    [18] = {
        name = [[水獭灵的帮助]],
        stitle = [[敢于直面弹幕的威光]],
        sdes = [[增加一个可以§g消除弹幕§d的水獭灵/minion]],
        detail = [[/t18sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = { tg.defend, tg.store },
        picID = 15,
        repeatp = 0,
        maxc = 2,
        initialTake = false,
        event = function(d, flag)
            if flag then
                if not IsValid(lstg.tmpvar.greenhyper_center) then
                    lstg.tmpvar.greenhyper_center = New(lib.class.GreenHyperCenter)
                else
                    local greenhyper_center = lstg.tmpvar.greenhyper_center
                    greenhyper_center.count = greenhyper_center.count + 1
                end
            else
                local greenhyper_center = lstg.tmpvar.greenhyper_center
                if IsValid(greenhyper_center) then
                    greenhyper_center.count = greenhyper_center.count - 1
                    if greenhyper_center.count == 0 then
                        Del(lstg.tmpvar.greenhyper_center)
                    end
                end
            end
        end,
        condfunc = nil,
    },
    [21] = {
        name = [[守财奴的教训]],
        stitle = [[化无为有]],
        sdes = [[/player擦弹时有概率掉落/expp]],
        detail = [[记§ya=1
擦弹时，有§ga*15%§d的概率掉落/expp]],
        repeatd = [[§ya§d+1]],
        collabd = nil,
        unlockd = [[/passtime1]],
        condd = nil,
        tags = tg.store,
        picID = 18,
        repeatp = 0,
        maxc = 3,
        initialTake = false,
        event = function(d, flag)
            local var = lstg.var
            var.graze_exp = min(1, var.graze_exp + 0.15 * d)
            var.graze_exp_count = 0
        end,
        condfunc = nil,
    },
    [24] = {
        name = [[冰之妖精]],
        stitle = [[全方位射击]],
        sdes = [[获得1个碎冰弹/minion，散射碎冰弹
每颗子弹伤害为§g35%/atk]],
        detail = [[/t24sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[击败1次/bossChiruno]],
        condd = nil,
        tags = tg.nine,
        picID = 21,
        repeatp = 0,
        maxc = 3,
        initialTake = true,
        event = function(d, flag)
            if flag then
                if lstg.var.addition[45] then
                    mission_lib.GoMission(8)
                end
                if not IsValid(lstg.tmpvar.small_ice_shooter) then
                    lstg.tmpvar.small_ice_shooter = New(lib.class.small_ice_shooter)
                else
                    local small_ice_shooter = lstg.tmpvar.small_ice_shooter
                    small_ice_shooter.count = small_ice_shooter.count + 1
                end
            else
                local small_ice_shooter = lstg.tmpvar.small_ice_shooter
                if IsValid(small_ice_shooter) then
                    small_ice_shooter.count = small_ice_shooter.count - 1
                    if small_ice_shooter.count == 0 then
                        Del(small_ice_shooter)
                    end
                end
            end
        end,
        condfunc = nil,
    },
    [26] = {
        name = [[经验探测仪]],
        stitle = [[灵敏的寻宝器]],
        sdes = [[周期性生成不断旋转扩大的金摆
当其接触到敌人时，§g生成一些/expp§d并对敌人§g造成伤害]],
        detail = [[记§ya=1
每§b355-55*a§d帧在/player周围生成§g3§d个金摆
每帧造成§g30+10*a%/atk§d的伤害，同时§g生成一些/expp]],
        repeatd = [[§ya§d+1]],
        collabd = nil,
        unlockd = [[一局游戏内达到§p15§d级]],
        condd = nil,
        tags = tg.store,
        picID = 23,
        repeatp = 0,
        maxc = 3,
        initialTake = false,
        event = function(d, flag)
            if flag then
                if not IsValid(lstg.tmpvar.exp_pendulum_shooter) then
                    lstg.tmpvar.exp_pendulum_shooter = New(lib.class.exp_pendulum_shooter)
                else
                    local exp_pendulum_shooter = lstg.tmpvar.exp_pendulum_shooter
                    exp_pendulum_shooter.count = exp_pendulum_shooter.count + 1
                end
            else
                local exp_pendulum_shooter = lstg.tmpvar.exp_pendulum_shooter
                if IsValid(exp_pendulum_shooter) then
                    exp_pendulum_shooter.count = exp_pendulum_shooter.count - 1
                    if exp_pendulum_shooter.count == 0 then
                        Del(exp_pendulum_shooter)
                    end
                end
            end
        end,
        condfunc = nil,
    },
    [29] = {
        name = [[大促销：神子牌令牌]],
        stitle = [[清仓大甩卖]],
        sdes = [[射击时会额外发射§y超闪超亮的穿透祷光§d，努力凑满§g17§d条吧！
每当获取此道具时，有概率额外§g获得一个]],
        detail = [[增加§g10§d倍获得权重
记§ya=1
当/player不动时，向/player正前方为§b0°§d，左右各§b(a/17*135)°§d的范围内，
随机角度生成一条激光
每帧造成§g(40-a/17*30)%§d/atk的伤害，持续§g(160-4a)§d帧
激光的不透明度为§b(80-a/17*40)%
每当获取此道具时，有§g(17+6a)%§d概率额外获得一个
当a=17时，/player背后出现§y光背特效]],
        repeatd = [[a+1
增加§g7§d倍获得权重]],
        collabd = nil,
        unlockd = [[/passtime2]],
        condd = nil,
        other = "买一送一！",
        tags = nil,
        picID = 26,
        repeatp = 7,
        maxc = 17,
        initialTake = false,
        event = function(d, flag, otherflag)
            if flag then
                local count = lstg.var.addition[29] or 0
                if not otherflag then
                    local pro = 0.17 + count * 0.06
                    if lstg.var.copy_center then
                        pro = pro + 0.30
                    end
                    if ran:Float(0, 1) < pro and count <= 16 then
                        lib.AdditionTotalList[29]:Set()
                        ext.popup_menu:FlyInOneTool(i18n("addition_des", 4)[29].other, 255, 227, 132, 29, "bonus2")
                    end --  һ  һ
                end
                if not IsValid(lstg.tmpvar.miko_laser_shooter) then
                    lstg.tmpvar.miko_laser_shooter = New(lib.class.miko_laser_shooter)
                else
                    local miko_laser_shooter = lstg.tmpvar.miko_laser_shooter
                    miko_laser_shooter.count = miko_laser_shooter.count + 1
                end
                if count == 17 then
                    lstg.tmpvar.miko_laser_back = New(_editor_class.MikoBack, player, -90, 1)
                    ext.achievement:get(86)
                end
            else
                local miko_laser_shooter = lstg.tmpvar.miko_laser_shooter
                if IsValid(miko_laser_shooter) then
                    miko_laser_shooter.count = miko_laser_shooter.count - 1
                    if miko_laser_shooter.count == 0 then
                        Del(miko_laser_shooter)
                    end
                    if IsValid(lstg.tmpvar.miko_laser_back) and miko_laser_shooter.count <= 16 then
                        Del(lstg.tmpvar.miko_laser_back)
                    end
                end
            end
        end,
        condfunc = nil,
    },
    [37] = {
        name = [[心连心]],
        stitle = [[汝吾连心，血偿无敌]],
        sdes = [[当/hp充足时，可将/hp转化为充能来§g释放符卡]],
        detail = [[记§ya=/spellme-/spelle§d, §yb=/maxhp
当/spelle不足以释放符卡时，
可按释放符卡键耗费§r(a+b)/8§d点/hp来§g释放符卡§d并§r清空/spelle§d
§-(不计作伤害，会致死时则无效)]],
        repeatd = nil,
        collabd = [[/t80：使用/t37释放符卡时，固定回复§g5§d点/hp]],
        unlockd = [[击败2次/bossYukari]],
        condd = nil,
        tags = { tg.store, tg.sacrifice },
        picID = 30,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.var.kokoro_musubu = flag
        end,
        condfunc = nil,
    },
    [50] = {
        name = [[生与死的境界]],
        stitle = [[命冥合一]],
        sdes = [[受到致死伤害时，/hp恢复§g50%§d，但/maxhp减少§r50%§d
每波仅限一次]],
        detail = [[/t50sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[击败1次/bossYukari]],
        condd = nil,
        tags = tg.defend,
        picID = 43,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local var = lstg.var
            var.life_dead = flag
            if flag then
                AddWaveEvent("life_dead_refresh", 1, function()
                    var.life_dead = true
                end)
            else
                RemoveWaveEvent("life_dead_refresh")
            end
        end,
        condfunc = nil,
    },
    [53] = {
        name = [[恐慌的笼罩]],
        stitle = [[暗黑之手]],
        sdes = [[§b场上所有生物的/hp不断流逝
会导致/player§r死亡]],
        detail = [[§b场上所有生物的/hp不断流逝
敌人每秒失去§g min {33.33%/maxhp, 54}
/player每秒失去§r max {1.03%/maxhp, 0.514}
会导致/player§r死亡]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[击败1次/bossRumia]],
        condd = nil,
        tags = tg.debuff,
        picID = 46,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            if flag then
                mission_lib.GoMission(116)
                lstg.tmpvar.scaring_mask = New(lib.class.scaring_mask)
            else
                if IsValid(lstg.tmpvar.scaring_mask) then
                    Del(lstg.tmpvar.scaring_mask)
                end
            end
        end,
        condfunc = nil,
    },
    [63] = {
        name = [[蓬莱人形]],
        stitle = [[陈旧幻想]],
        sdes = [[/player持续一段时间未被弹时，生成§g1§d个小型人偶，上限§b9§d个
人偶会§g攻击敌人§d，也会§g抵挡数颗弹幕]],
        detail = [[记§ya=人偶数量
/player持续§b30+25a§d帧未被弹时，生成§g1§d个小型人偶，上限§b9§d个
每当/player被弹时，强制进入§r110帧§d的冷却，§r无法生成人偶
人偶将朝着最近的敌人每§b75帧§d发射§g1§d枚§g0.5a+23%/atk§d伤害的子弹
人偶生成时有§g30帧§d的/inv时间，可抵消弹幕
非/inv状态时，抵消§g3§d颗弹幕或被体术时消失]],
        repeatd = nil,
        collabd = [[/t6：人偶消失时，产生小范围爆炸
/t117：人偶生成时的保护时间延长§p30帧]],
        unlockd = [[/chaos达到§r250%]],
        condd = nil,
        tags = { tg.defend, tg.store },
        picID = 56,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            if flag then
                lstg.tmpvar.ningyouer = New(lib.class.ningyouer)
            else
                if IsValid(lstg.tmpvar.ningyouer) then
                    Del(lstg.tmpvar.ningyouer)
                end
            end
        end,
        condfunc = nil,
    },
    [72] = {
        name = [[引诱式黄泉]],
        stitle = [[When I see you ...]],
        sdes = [[/br§g+7§d，/bv§r-2.5
主炮获得§g追踪效果]],
        detail = [[/t72sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = nil,
        picID = 60,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local ssr = player.shoot_set.range
            ssr.offset = ssr.offset + 7 * d
            local ssb = player.shoot_set.bvelocity
            ssb.offset = ssb.offset - 2.5 * d
            lstg.var.trail_main_bullet = flag
        end,
        condfunc = nil,
    },
    [74] = {
        name = [[不死的尾羽]],
        stitle = [[「复活」]],
        sdes = [[/player死亡时通过一段时间的§y重生§d便可以复活
若在§y重生§d中受击，则直接§r死亡]],
        detail = [[/player死亡时进入§y重生§d状态
§y重生§d：§r/atk大幅下降且不能释放符卡§d，持续§b4.43秒
若受击，则直接§r死亡
结束后/player恢复§g50%/maxhp§d。
§g该复活道具没有次数限制]],
        repeatd = nil,
        collabd = [[复活优先级为§y-1§-(越高越先触发)]],
        unlockd = [[死亡§p5§d次]],
        condd = nil,
        tags = tg.resurrection,
        picID = 62,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            lstg.var.fire_bird_resurrection = flag
            lstg.tmpvar.bird_resurrecting = false
            lstg.tmpvar.bird_resurrected = 0
        end,
        condfunc = nil,
    },
    [77] = {
        name = [[幽谷回响]],
        stitle = [[全方位无死角反弹]],
        sdes = [[/br§g+7§d
允许/pbullet§g无限反弹]],
        detail = [[/t77sdes]],
        repeatd = nil,
        collabd = [[/t71：先触发穿版，再触发反弹]],
        unlockd = [[/passtime3]],
        condd = nil,
        tags = nil,
        picID = 65,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local ssr = player.shoot_set.range
            ssr.offset = ssr.offset + 7 * d
            lstg.var.bound_main_bullet = flag
        end,
        condfunc = nil,
    },
    [84] = {
        name = [[时间回溯]],
        stitle = [[Rewind]],
        sdes = [[玩家死亡时§g读档至上一波§d，并且该道具§-损坏]],
        detail = [[玩家死亡时§g读档至上一波§d，并且此道具§-损坏
§-第一波时该道具无效
§-回溯后该道具至少有一波的冷却]],
        repeatd = nil,
        collabd = [[复活优先级为§y2§-(越高越先触发)]],
        unlockd = [[/passtime4]],
        condd = nil,
        tags = tg.resurrection,
        picID = 73,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.var.rewindable = flag
        end,
        condfunc = nil,
    },
    [89] = {
        name = [[破碎的护身符]],
        stitle = [[不死图腾？]],
        sdes = [[/chaos超过§r30%§d时，/chaos减少§g30%
触发一次后§-损坏]],
        detail = [[/t89sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[/chaos达到§r150%]],
        condd = nil,
        tags = { tg.chaos, tg.store },
        picID = 78,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local p = player
            local v = lstg.var
            if flag then
                p._playersys:addFrameBeforeEvent("chaos_remove30", 1, function()
                    if v.chaos >= 30 then
                        NewBon(player.x, player.y, 30, 60, 200, 64, 64)
                        PlaySound("nice")
                        player_lib.AddChaos(-30)
                        lib.BreakAddition(lib.AdditionTotalList[89])
                    end
                end)
            else
                p._playersys:removeFrameBeforeEvent("chaos_remove30")
            end
        end,
        condfunc = function()
            return not lstg.var._pathlike
        end,
    },
    [93] = {
        name = [[风神的祝歌]],
        stitle = [[神明之祝福]],
        sdes = [[/pbullet靠近敌人时，若打不中则§g会转向90°以瞄准敌人]],
        detail = [[/t93sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[/passtime5]],
        condd = nil,
        tags = nil,
        picID = 82,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local v = lstg.var
            v.snake_main_bullet = flag
        end,
        condfunc = nil,
    },
    [96] = {
        name = [[灵力槽]],
        stitle = [[火力优势学说]],
        sdes = [[增加一个/spellstk]],
        detail = [[/t96sdes！]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[使用§p30§d次符卡]],
        condd = nil,
        tags = tg.store,
        picID = 70,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            player_lib.SetEnergy(nil, lstg.var.energy_stack + 1 * d)
        end,
        condfunc = nil,
    },
    [100] = {
        name = [[Powerful Point]],
        stitle = [[PPT]],
        sdes = [[所有弹幕消除后都会产生§y消弹点
每颗§y消弹点§d增加§g0.02%§d/spelle]],
        detail = [[/t100sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[使用§p30§d次符卡]],
        condd = nil,
        tags = tg.store,
        picID = 89,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.var.powerful_point = flag
        end,
        condfunc = nil,
    },
    [101] = {
        name = [[蓬莱的玉枝]],
        stitle = [[梦色之乡]],
        sdes = [[/player向下发射§y七色珠§d，反弹后自动瞄准敌人，造成§g80%/atk§d伤害
击中敌人的§y七色珠§d将掉落，可以回收并重新射出]],
        detail = [[/player每§g45帧§d向下随机角度发射§g1~3§d颗§y七色珠
每颗造成§g80%/atk§d伤害
§y七色珠§d可以反弹§g1§d次，反弹后将自动瞄准敌人发射
当§y七色珠§d击中敌人后，将会向下掉落为可回收的§y七色珠§d，
回收后§y七色珠§d将自动瞄准敌人并发射，并重置其反弹次数
同屏最多§b20§d颗§y七色珠§d]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[收取§p"神宝「蓬莱的玉枝　-梦色之乡-」"]],
        condd = nil,
        tags = tg.neet,
        picID = 90,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.tmpvar.penglai_jade_count = 0
            if flag then
                player._playersys:addFrameBeforeEvent("shoot_penglai_jade", 1, function(self)
                    if self.__shoot_flag and self.nextshoot <= 0 then
                        if self.timer % 45 == 0 then
                            local t = ran:Int(1, 3)
                            local c = (t - 1) / 2
                            local tA = -90
                            if lstg.var.reverse_shoot then
                                tA = 90
                            end
                            for m = -c, c do
                                New(lib.class3.penglai_jade_bullet, self.x, self.y, 10, tA + m * 20 + ran:Float(-9, 9), player.damage * 0.8)
                            end
                        end
                    end
                end)
            else
                player._playersys:removeFrameBeforeEvent("shoot_penglai_jade")
            end
        end,
        condfunc = nil,
    },
    [105] = {
        name = [[幻想万华镜]],
        stitle = [[棱镜散光]],
        sdes = [[/pbullet击中敌人时，向四方发射§b原主炮大小75%§d的小/pbullet
每颗小/pbullet造成§g20%/atk§d伤害]],
        detail = [[/t105sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[/passtime6]],
        condd = nil,
        tags = tg.store,
        picID = 94,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.var.mangekyou = flag
        end,
        condfunc = nil,
    },
    [106] = {
        name = [[九代稗谷]],
        stitle = [[稗草萋萋，命散别离]],
        sdes = [[/player死亡后在§g原地复活§d，获得§g180帧§d/inv时间和修改为§r9§d点/maxhp
复活后，随机§r损坏§d1个道具；复活§g8§d次后，此道具§-损坏]],
        detail = [[/player死亡后在§g原地复活§d，获得§g180帧§d/inv时间和修改为§r9§d点/maxhp
复活后，随机§r损坏§d1个道具
复活§g8§d次后，此道具§-损坏]],
        repeatd = nil,
        collabd = [[复活优先级为§y1§-(越高越先触发)]],
        unlockd = [[2024年8月7日后]],
        condd = nil,
        other = "道具损坏...",
        tags = tg.resurrection,
        picID = 95,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.var.resurrect9 = max(0, lstg.var.resurrect9 + 8 * d)
        end,
        condfunc = nil,
    },
    [108] = {
        name = [[活力的繁星]],
        stitle = [[星垂平野阔]],
        sdes = [[每当敌人出现/死亡时，在场上随机一位置生成§b1§d颗星星，
星星造成§g49%/atk§d伤害，经过§b240帧§d后，星星消失]],
        detail = [[每当敌人出现/死亡时，在场上随机一位置生成§b1§d颗星星，
星星造成§g49%/atk§d伤害，经过§b240帧§d后，星星消失]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = nil,
        picID = 97,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.var.active_star = flag
            if flag then
                if not IsValid(lstg.tmpvar.active_star_back) then
                    lstg.tmpvar.active_star_back = New(lib.class2.active_star_back)
                end
                player._playersys:addEnemyKillEvent("active_star", 1, function()
                    New(lib.class2.active_star_bullet)
                end)
            else
                if IsValid(lstg.tmpvar.active_star_back) then
                    Del(lstg.tmpvar.active_star_back)
                end
                player._playersys:removeEnemyKillEvent("active_star")
            end
        end,
        condfunc = nil,
    },
    [111] = {
        name = [[幻想烟花]],
        stitle = [[典礼]],
        sdes = [[/atk§g+1§d，/ssR§r-77%§d，/br§r-3.5§d，/brR§r-34%§d
/player将发射§b150%§d/atk的大/pbullet，消失时分裂出开花/pbullet]],
        detail = [[/atk§g+1§d，/ssR§r-77%§d，/br§r-3.5§d，/brR§r-34%§d
/player改为发射一枚§b150%§d/atk的大/pbullet，
大/pbullet碰到敌人或者消失时分裂，向周围发射§b6~9§dway开花/pbullet
/pbullet继承§b60%§d/br，但最小不小于§b5~8§d]],
        repeatd = nil,
        collabd = [[/t105：每颗小/pbullet只会分裂出§b4§d颗弹幕]],
        unlockd = [[/passtime3]],
        condd = nil,
        tags = { tg.debuff },
        picID = 100,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            player.dmg_offset = player.dmg_offset + 1 * d
            local ss = player.shoot_set.speed
            ss.fixed = ss.fixed - 0.77 * d
            local sr = player.shoot_set.range
            sr.offset = sr.offset - 3.5 * d
            sr.fixed = sr.fixed - 0.34 * d
            lstg.var.imaginary_main_bullet = flag
        end,
        condfunc = nil,
    },
    [112] = {
        name = [[生之残梦]],
        stitle = [[人生之梦]],
        sdes = [[有概率§g免除被弹&体术伤害]],
        detail = [[记§ya=1
有§ga*23%§d概率免除被弹&体术伤害]],
        repeatd = [[a+1
降低§r0.3§d倍获得权重]],
        collabd = nil,
        unlockd = [[被弹累计§p50§d次]],
        condd = nil,
        tags = { tg.defend, tg.store },
        picID = 101,
        repeatp = 0,
        maxc = 3,
        initialTake = false,
        event = function(d, flag)
            lstg.var.ikinokosu_yume = lstg.var.ikinokosu_yume + d
        end,
        condfunc = nil,
    },
    [113] = {
        name = [[荷取牌能量盾]],
        stitle = [[充能型护盾]],
        sdes = [[每Wave获得§g0.75§d层护罩，每§b1§d层护罩可以抵消§g1§d次伤害
最多叠加§b3§d个护罩]],
        detail = [[/t113sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[获得过/t30]],
        condd = nil,
        tags = { tg.defend, tg.store },
        picID = 102,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local var = lstg.var
            if flag then
                mission_lib.GoMission(122)
                var.shield_count = var.shield_count + 1
                AddWaveEvent("refresh_kappa_shield", 1, function()
                    local before = int(var.shield_count)
                    if before < 3 then
                        var.shield_count = min(3, var.shield_count + 0.75)
                        local after = int(var.shield_count)
                        if after - before > 0 then
                            player.my_shield.index = 1
                            PlaySound("kappa_shield_on")
                        end
                    end
                end)
            else
                RemoveWaveEvent("refresh_kappa_shield")
            end
        end,
        condfunc = nil,
    },
    [123] = {
        name = [[绯红的专注]],
        stitle = [[百战不殆的瞄准]],
        sdes = [[开火一段时间后向前发射高速针弹，造成§g大量伤害，
但/player§r熄火一段时间]],
        detail = [[记§ya=0§d，§yγ=1§-(最大为9)
/player每射击§b(300-a*50-γ*13)§-(不低于65)§b帧§d，
向全方位发射§gγ§d枚高速红色拖尾针弹
针弹继承/player/br，对接触到的敌人造成每帧§g0.3+33%/atk§d的伤害
发射完针弹后，/player熄火§r(60-a*20)帧§d，§yγ+0.75
当/player受到非技巧性伤害时，§rγ=1]],
        repeatd = [[a+1]],
        collabd = [[/t72：针弹获得§g追踪效果
/t71：针弹§g可穿版1次
/t77：针弹§g可无限反弹
/t22：§yγ§d最大值修改至§g12]],
        unlockd = [[/passtime4]],
        condd = nil,
        tags = nil,
        picID = 112,
        repeatp = 0,
        maxc = 3,
        initialTake = false,
        event = function(d, flag)
            local v = lstg.var
            v.scarlet_focus = v.scarlet_focus + d
            if flag and v.scarlet_focus == 1 then
                player._playersys:addMissAfterEvent("scarlet_focus", 1, function()
                    if v.scarlet_count >= 9 then
                        ext.achievement:get(73)
                    end
                    v.scarlet_count = 1--记录数量
                end)
                player._playersys:addFrameBeforeEvent("scarlet_focus", 1, function(self)
                    if v.frame_counting then
                        if self.__shoot_flag and self.nextshoot <= 0 then
                            v.scarlet_record = v.scarlet_record + 1
                            local c = (v.scarlet_focus - 1)
                            if v.scarlet_record >= max(65, 300 - c * 50 - v.scarlet_count * 13) then
                                local bv, lifetime = self.cur_bv, self.cur_brange
                                PlaySound("slash2")
                                NewWave(self.x, self.y, 12, 500, 90, 250, 64, 64)
                                local tA = 90
                                if v.reverse_shoot then
                                    tA = -90
                                end
                                for a in sp.math.AngleIterator(tA, int(v.scarlet_count)) do
                                    New(lib.class3.needle_bullet, self.x, self.y, bv * 2, a, 0.3 + player.damage * 0.33, lifetime)
                                end
                                self.nextshoot = 60 - c * 20
                                v.scarlet_record = 0
                                local maxcount = 9
                                if v.heal_factor > 0 then
                                    maxcount = 12
                                end
                                v.scarlet_count = min(maxcount, v.scarlet_count + 0.75)
                            end
                        end
                    end
                end)
            elseif not flag and v.scarlet_focus == 0 then
                player._playersys:removeMissAfterEvent("scarlet_focus")
                player._playersys:removeFrameBeforeEvent("scarlet_focus")
            end
        end,
        condfunc = nil,
    },
    [124] = {
        name = [[冰之鳞]],
        stitle = [[水中的秘密]],
        sdes = [[低速状态下，/atk§g+0.5§d，/hitb§g-0.1§d
同时额外§g发射波纹弹]],
        detail = [[/player低速时，进入§y「潜水」§d，§-贴图变蓝
§y「潜水」§d：/atk§g+0.5§d，/hitb§g-0.1§d
每§b12帧§d，发射大型波纹弹，造成§g45%/atk§d的伤害；
每§b25帧§d，发射小型波纹弹，造成§g25%/atk§d的伤害]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[击败1次/bossWakasagihime]],
        condd = nil,
        tags = nil,
        picID = 113,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            if flag then
                lstg.tmpvar.wave_bullet_shooter = New(lib.class3.wave_bullet_shooter)
            else
                if IsValid(lstg.tmpvar.wave_bullet_shooter) then
                    Del(lstg.tmpvar.wave_bullet_shooter)
                end
            end
        end,
        condfunc = nil,
    },
    [125] = {
        name = [[贤者之石]],
        stitle = [[非等价市场]],
        sdes = [[根据收集的/expp数§g增加/atk与/ss
每当升级时重置/expp计数]],
        detail = [[记§yn=收集的/expp数
/player/atk和/ss§g+0.012n
每当升级时，§rn=0]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[一局游戏内达到§p30§d级]],
        condd = nil,
        tags = tg.store,
        picID = 114,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.var.philosopher_stone = flag
        end,
        condfunc = nil,
    },
    [126] = {
        name = [[宝塔的神光]],
        stitle = [[无上之威光]],
        sdes = [[/player周围出现光环，
进入光环中的敌人每帧受到§g3.3%/atk§d伤害]],
        detail = [[/t126sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[/passtime2]],
        condd = nil,
        tags = nil,
        picID = 115,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            if flag then
                lstg.tmpvar.god_circle = New(lib.class3.god_circle)
                lstg.tmpvar.god_circle_with_lie_detector = {}
                if IsValid(lstg.tmpvar.lie_detector) then
                    for i = 1, lstg.tmpvar.lie_detector.count * 3 do
                        lstg.tmpvar.god_circle_with_lie_detector[i] = New(lib.class3.god_circle_with_lie_detector, i)
                    end
                end
            else
                if IsValid(lstg.tmpvar.god_circle) then
                    Del(lstg.tmpvar.god_circle)
                end
                for _, de in pairs(lstg.tmpvar.god_circle_with_lie_detector) do
                    if IsValid(de) then
                        Del(de)
                    end
                end
                lstg.tmpvar.god_circle_with_lie_detector = nil
            end
        end,
        condfunc = nil,
    },
    [127] = {
        name = [[疯狂的火炬]],
        stitle = [[lookin my eyes!]],
        sdes = [[/player击败敌人越快，§g/atk提升越大]],
        detail = [[/player击败敌人越快，§g/atk提升越大
记§yβ=0§-(最大为200)§d，§yγ=0
每当击破敌人时，§bγ+0.3§d。每帧§bβ-1
§bβ>=60§d时：每击破一名敌人使§bβ+10§d；每15帧§bγ-1
§bβ<60§d时：击破敌人会使得§bβ=60
§bβ<30§d时：如果此时§bγ<=25§d，则§bγ=0§d；否则，每帧§bγ-2
/player/atk§g+35%γ]],
        repeatd = [[叠加2个时，/player/atk§g+15%γ§d；
叠加3个时，击破敌人时§bγ+0.3§d]],
        collabd = nil,
        unlockd = [[累计杀死§p3333§d个敌人]],
        condd = nil,
        tags = tg.store,
        picID = 116,
        repeatp = 0,
        maxc = 3,
        initialTake = false,
        event = function(d, flag)
            local v = lstg.var
            v.crazy_torch = v.crazy_torch + d
            if v.crazy_torch == 1 and d == 1 then
                local p = player
                p._playersys:addFrameBeforeEvent("adddmg_crazy_torch", 1, function()
                    local var = lstg.var
                    if var.frame_counting then
                        if var.crazy_torch > 0 then
                            var.crazy_torch_t = max(var.crazy_torch_t - 1, 0)
                            if var.crazy_torch_t >= 120 then
                                var.crazy_torch_n = max(var.crazy_torch_n - 1 / 15, 0)
                            elseif var.crazy_torch_t < 30 then
                                if var.crazy_torch_n <= 25 then
                                    var.crazy_torch_n = 0
                                else
                                    var.crazy_torch_n = max(var.crazy_torch_n - 2, 0)
                                end
                            end
                        end
                    end
                end)
                p._playersys:addEnemyKillEvent("crazy_torch", 1, function()
                    local num = 0.3
                    if v.crazy_torch == 3 then
                        num = 0.6
                    end
                    v.crazy_torch_n = v.crazy_torch_n + num
                    if v.crazy_torch_t < 60 then
                        v.crazy_torch_t = 60
                    else
                        v.crazy_torch_t = min(v.crazy_torch_t + 10, 200)
                    end
                end)
            elseif v.crazy_torch == 0 and d == -1 then
                local p = player
                p._playersys:removeFrameBeforeEvent("adddmg_crazy_torch")
                p._playersys:removeEnemyKillEvent("crazy_torch")
            end
        end,
        condfunc = nil,
    },
    [128] = {
        name = [[玻璃大炮]],
        stitle = [[轻拿轻放]],
        sdes = [[/atkR§g+69%§d，/pbullethitb§g+69%
/maxhp修改至§r30§d，每次受到伤害时减少§r2.5§d点/maxhp]],
        detail = [[/t128sdes
/maxhp不能再超过30§-(包括复活后)]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[死亡§p15§d次]],
        condd = nil,
        tags = tg.debuff,
        picID = 117,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local p = player
            p.dmg_fixed = p.dmg_fixed + 0.69 * d
            local v = lstg.var
            v.glass_bon = flag
            v.player_bullet_scale_factor = v.player_bullet_scale_factor + 0.69 * d
            if flag then
                player_lib.AddMaxLife(-v.maxlife / 3 + 30)
                player._playersys:addMissAfterEvent("glass_bon", 1, function(self)
                    player_lib.AddMaxLife(-2.5)
                    player_lib.InsertDmgTypeCache("GlassBon")
                end)
            else
                player._playersys:removeMissAfterEvent("glass_bon")
            end
        end,
        condfunc = nil,
    },
    [129] = {
        name = [[寻求者]],
        stitle = [[炽热鲜血]],
        sdes = [[有§b16%§d的概率发射§r红色/pbullet§d
额外造成§g20§d点伤害]],
        detail = [[/t129sdes]],
        repeatd = nil,
        collabd = [[获得3件带有/tgRGB标签的道具时
有概率发射出白色/pbullet，拥有§r红§g绿§b蓝§d子弹的效果
击中敌人时将透过敌人，分裂出§r红§g绿§b蓝§d三枚/pbullet]],
        unlockd = [[/passtime7]],
        condd = nil,
        tags = tg.RGB,
        picID = 118,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local v = lstg.var
            v.red_main_bullet = flag
            if v.addition[129] and v.addition[130] and v.addition[131] then
                ext.achievement:get(106)
            end
        end,
        condfunc = nil,
    },
    [130] = {
        name = [[渴望者]],
        stitle = [[二氧化碳过滤器]],
        sdes = [[有§b17%§d的概率发射§g绿色/pbullet§d
击中时恢复§g0.064§d/hp]],
        detail = [[/t130sdes]],
        repeatd = nil,
        collabd = [[/t129collabd]],
        unlockd = [[/passtime7]],
        condd = nil,
        tags = { tg.RGB, tg.life, tg.store },
        picID = 119,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local v = lstg.var
            v.green_main_bullet = flag
            if v.addition[129] and v.addition[130] and v.addition[131] then
                ext.achievement:get(106)
            end
        end,
        condfunc = nil,
    },
    [131] = {
        name = [[喜爱者]],
        stitle = [[明亮岩盐]],
        sdes = [[有§b10%§d的概率发射§b蓝色/pbullet§d
被击中的敌人将掉落§g1§d颗/expp]],
        detail = [[/t131sdes]],
        repeatd = nil,
        collabd = [[/t129collabd]],
        unlockd = [[/passtime7]],
        condd = nil,
        tags = { tg.RGB, tg.store },
        picID = 120,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local v = lstg.var
            v.blue_main_bullet = flag
            if v.addition[129] and v.addition[130] and v.addition[131] then
                ext.achievement:get(106)
            end
        end,
        condfunc = nil,
    },
    [150] = {
        name = [[拉拉宛]],
        stitle = [[死宛拉拉队]],
        sdes = [[获得一个拉拉队追随型/minion
有节奏地挥舞发射子弹，每颗造成§g1.0§d的伤害]],
        detail = [[/t150sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = { tg.siyuan, tg.baby },
        picID = 139,
        repeatp = 0,
        maxc = 3,
        initialTake = true,
        event = function(d, flag)
            if flag then
                lib.siyuan_achievement()
                lstg.tmpvar.siyuan_baby3 = lstg.tmpvar.siyuan_baby3 or {}
                table.insert(lstg.tmpvar.siyuan_baby3, New(lib.class4.siyuan_baby3))
            else
                if lstg.tmpvar.siyuan_baby3 then
                    if IsValid(lstg.tmpvar.siyuan_baby3[1]) then
                        Del(lstg.tmpvar.siyuan_baby3[1])
                        table.remove(lstg.tmpvar.siyuan_baby3, 1)
                    end
                end
            end
        end,
        condfunc = nil,
    },
    [161] = {
        name = [[团子生命力]],
        stitle = [[黄豆粉灵魂的躯壳]],
        sdes = [[拾取boss掉落的残碎额外使/atk§g+1§d，/spelle§g+25%]],
        detail = [[/t161sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[击败1次/bossRingo]],
        condd = nil,
        tags = nil,
        picID = 150,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local v = lstg.var
            v.chip_adddmg = flag
        end,
        condfunc = nil,
    },
    [174] = {
        name = [[一脉单传的神风]],
        stitle = [[守矢秘法]],
        sdes = [[获得3级/item时
有§g33%§d的概率提升§g1§d级]],
        detail = [[/t174sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[使用/playerSanae/passtime1]],
        condd = nil,
        tags = nil,
        picID = 189,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local v = lstg.var
            v.levelup_get_Q3 = flag
        end,
        condfunc = nil,
    },
    [175] = {
        name = [[多米诺效应]],
        stitle = [[错啦是蝴蝶效应]],
        sdes = [[获得§g当前等级数*2%§d的/expR加成]],
        detail = [[/t175sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[/expR达到§gx2.00§d]],
        condd = nil,
        tags = nil,
        picID = 192,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.var.domino_effect = flag
        end,
        condfunc = nil,
    },
    [176] = {
        name = [[螺光步]],
        stitle = [[聚气凝神]],
        sdes = [[停止移动§b45帧§d后，/ss提升§g50%]],
        detail = [[/t176sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[/passtime1]],
        condd = nil,
        tags = nil,
        picID = 185,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local v = lstg.var
            local p = player
            if flag then
                p._playersys:addFrameBeforeEvent("attention_attack", 1, function()
                    if v.frame_counting then
                        if p.dx == 0 and p.dy == 0 then
                            v.attention_attack_time = v.attention_attack_time + 1
                            if v.attention_attack_time == 45 then
                                NewWave(p.x, p.y, 2, 0, 30, 200, 100, 235, 100)

                                PlaySound("kira01")
                            end
                        else
                            if v.attention_attack_time >= 45 then
                                NewWave(p.x, p.y, 2, 100, 15, 200, 100, 235)
                            end
                            v.attention_attack_time = 0
                        end
                    end
                end)
            else
                player._playersys:removeFrameBeforeEvent("attention_attack")
            end
        end,
        condfunc = nil,
    },
    [177] = {
        name = [[永夜刻印]],
        stitle = [[刻符]],
        sdes = [[敌人死亡时§g消除一次/hitb范围内的子弹§d]],
        detail = [[/t177sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[使用/playerReimu/passtime1]],
        condd = nil,
        tags = tg.defend,
        picID = 191,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local v = lstg.var
            if flag then
                player._playersys:addEnemyKillEvent("shut_up", 1, function(player, _, self)
                    New(bullet_cleaner, self.x, self.y, self.a, 1, 1, true, false, 0, 0)
                end)
            else
                player._playersys:removeEnemyKillEvent("shut_up")
            end
        end,
        condfunc = nil
    },
    [179] = {
        name = [[彼时结界]],
        stitle = [[我biu故我在]],
        sdes = [[/hitb§g-0.1§d
§r受击§d时，使场上所有弹幕§b反转判定]],
        detail = [[/t179sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = tg.defend,
        picID = 163,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            if flag then
                player_lib.AddPlayerCollisize(-0.1 * d)
                player._playersys:addMissAfterEvent("temporal_barrier", 1, function()
                    object.BulletIndesDo(function(b)
                        New(lib.class2.fake_and_real_eff, b)
                        bullet.setfakeColli(b, b._no_colli)
                    end)
                end)
            else
                player._playersys:removeMissAfterEvent("temporal_barrier")
            end
        end,
        condfunc = nil,
    },
    [184] = {
        name = [[半分幻魂魄]],
        stitle = [[穿透子弹]],
        sdes = [[/atk§g+1
/pbullet获得§c穿透§d效果]],
        detail = [[/t184sdes
§c穿透§d：子弹打到敌人时不再消失，对同一个敌人仅造成一次伤害]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[通关§p挑战8]],
        condd = nil,
        tags = nil,
        picID = 168,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local p = player
            p.dmg_offset = p.dmg_offset + 1 * d
            lstg.var.pierce_main_bullet = flag
        end,
        condfunc = nil,
    },
    [185] = {
        name = [[核燃火药]],
        stitle = [[万物之伊始]],
        sdes = [[/pbullet消失时产生持续§b20帧§d的爆风
爆风每帧造成§g4%/atk§d的伤害，其范围基于/pbullethitb]],
        detail = [[/t185sdes]],
        repeatd = nil,
        collabd = [[/t152：爆风范围增大]],
        unlockd = nil,
        condd = nil,
        tags = nil,
        picID = 169,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.var.gunpowder_main_bullet = flag
        end,
        condfunc = nil,
    },
    [193] = {
        name = [[八十亿劫渡法]],
        stitle = [[熵的减是相互的]],
        sdes = [[成功收取符卡时，/chaos§g-8%]],
        detail = [[/t193sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[使用/playerAya/passtime1]],
        condd = nil,
        tags = tg.chaos,
        picID = 177,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.var.getCard_dec_chaos = flag
        end,
        condfunc = nil,
    },
    [195] = {
        name = [[辉夜的百宝箱]],
        stitle = [[永恒的人生]],
        sdes = [[增加§g1§d个/activestk]],
        detail = [[/t195sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[携带任意/active通关/scenep2]],
        condd = nil,
        tags = tg.active,
        picID = 179,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.var.max_active_item = lstg.var.max_active_item + d
        end,
        condfunc = AfterActive,
    },
    [197] = {
        name = [[逢天宇宙仪]],
        stitle = [[星极心理]],
        sdes = [[/pbullet与/player之间出现§p极其微弱的连线
每当发射/pbullet时，连线造成1次被连线/pbullet§g10%/atk§d的伤害]],
        detail = [[/t197sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[/passtime6]],
        condd = nil,
        tags = nil,
        picID = 181,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.var.link_main_bullet = flag
        end,
        condfunc = nil,
    },
    [207] = {
        name = [[本土信仰]],
        stitle = [[信仰]],
        sdes = [[/spelle未满时，获得§b/expp§d时会额外补充§g0.1%§d/spelle
/spelle满时，获得§b/expp§d时会恢复§g所获得能量*8%§d的/hp]],
        detail = [[/t207sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[使用/playerSanae/passtime2]],
        condd = nil,
        tags = { tg.life },
        picID = 207,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.var.native_faith = flag
        end,
        condfunc = nil,
    },

    [212] = {
        name = [[百万鬼夜行]],
        stitle = [[小小的一群]],
        sdes = [[在屏幕上形成一群小/player，会射击§g小/pbullet
每波开始时会重置位置]],
        detail = [[/plopca§r-30%
在屏幕上生成§g6§d个/player小分身，随着/player移动而微移
每Wave开始时，分身重新归位到/player身上
分身发射§g小/pbullet§d，但/ss是/player的§b1/8]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[通关§p挑战15]],
        condd = nil,
        tags = nil,
        picID = 215,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            if flag then
                AddWaveEvent("refresh_little_watermelon", 1, function()
                    if lstg.tmpvar.little_watermelons then
                        for _, watermelon in ipairs(lstg.tmpvar.little_watermelons) do
                            if IsValid(watermelon) then
                                Del(watermelon)
                            end
                        end
                    end
                    lstg.tmpvar.little_watermelons = {}
                    for _ = 1, 6 do
                        --task.Wait(2)
                        local watermelon = New(lib.class.little_watermelon)
                        table.insert(lstg.tmpvar.little_watermelons, watermelon)
                        task.New(watermelon, function()
                            local self = task.GetSelf()
                            for i = 1, 10 do
                                self.vscale = 1 + i / 10
                                self.hscale = 1 - i / 10
                                task.Wait()
                            end
                            for i = 1, 10 do
                                self.vscale = 2 - i / 10
                                self.hscale = i / 10
                                task.Wait()
                            end
                        end)
                    end
                end)
            else
                if lstg.tmpvar.little_watermelons then
                    for _, watermelon in ipairs(lstg.tmpvar.little_watermelons) do
                        if IsValid(watermelon) then
                            Del(watermelon)
                        end
                    end
                end
                RemoveWaveEvent("refresh_little_watermelon")
            end
        end,
        condfunc = nil,
    },
    [213] = {
        name = [[业火的灯芯]],
        stitle = [[燃此身灰，照彼岸明]],
        sdes = [[当/hp充足时，可将/hp转化为充能来§g使用/active]],
        detail = [[记§yb=/maxhp
当/active未满充能时，
可按释放主动键耗费/hp来§g使用/active§d并§r清空充能§d
若/active为时间充能，则耗费的/hp为§b(b/10+所需秒数/2.5)
若/active为波充能，则耗费的/hp为§b(b/10+所需波数*5)
若/active为/spelle充能，则耗费的/hp为§b(b/10+所需能量/7)
§-(不计作伤害，会致死时则无效)]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[击败1次/bossByakuren]],
        condd = nil,
        tags = { tg.sacrifice, tg.active },
        picID = 184,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.var.silent_fire = flag
        end,
        condfunc = AfterActive,
    },
    [214] = {
        name = [[未竟者的誓轮]],
        stitle = [[再承一愿]],
        sdes = [[/active增加额外§g一层充能槽]],
        detail = [[/t214sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[击败1次/bossByakuren]],
        condd = nil,
        tags = { tg.active },
        picID = 186,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            for _, item in ipairs(activeItem_lib.ActiveTotalList) do
                item.energy_max = item.energy_max + d
            end
        end,
        condfunc = AfterActive,
    },
}