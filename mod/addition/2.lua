local lib = stg_levelUPlib
local AddWaveEvent = lib.AddWaveEvent
local RemoveWaveEvent = lib.RemoveWaveEvent

local tg = stg_levelUPlib.tagslist

local function AfterActive()
    return scoredata.StartActive
end

return {
    [7] = {
        name = [[女仆飞刀]],
        stitle = [[完美主义者的操刀秀]],
        sdes = [[从底部发射自动瞄准敌人的飞刀]],
        detail = [[记§ya=1
发射飞刀间隔为§b({14,9,6})[a]§d帧，
造成§g(a/3*0.5+0.3)*100%/atk§d的伤害]],
        repeatd = [[§ya§d+1]],
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = nil,
        picID = 13,
        repeatp = 0,
        maxc = 3,
        initialTake = true,
        event = function(d, flag)
            if flag then
                if not IsValid(lstg.tmpvar.straightknife_shooter) then
                    lstg.tmpvar.straightknife_shooter = New(lib.class.straightknife_shooter)
                else
                    local straightknife_shooter = lstg.tmpvar.straightknife_shooter
                    straightknife_shooter.count = straightknife_shooter.count + 1
                end
            else
                local straightknife_shooter = lstg.tmpvar.straightknife_shooter
                if IsValid(straightknife_shooter) then
                    straightknife_shooter.count = straightknife_shooter.count - 1
                    if straightknife_shooter.count == 0 then
                        Del(straightknife_shooter)
                    end
                end
            end
        end,
        condfunc = nil,
    },
    [17] = {
        name = [[金刚不灭之身]],
        stitle = [[致命拥抱]],
        sdes = [[§g不再受到敌人体术攻击
且每§b15帧§d对敌人造成§g100%/atk§d体术伤害]],
        detail = [[/t17sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[被敌怪体术§p5§d次]],
        condd = nil,
        tags = tg.defend,
        picID = 14,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.var.goldenbody = flag
            if flag then
                lstg.tmpvar.golden_body = New(lib.class2.golden_body)
            else
                if IsValid(lstg.tmpvar.golden_body) then
                    Del(lstg.tmpvar.golden_body)
                end
            end
        end,
        condfunc = nil,
    },
    [22] = {
        name = [[吸血鬼之牙]],
        stitle = [[地牢五玩具]],
        sdes = [[击败敌人时根据敌人血量§g恢复/hp]],
        detail = [[记§ya=1
击败敌人时恢复§g16a%§d的敌人/maxhp]],
        repeatd = [[§ya§d+1]],
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = tg.life,
        picID = 19,
        repeatp = 0,
        maxc = 3,
        initialTake = false,
        event = function(d, flag)
            local var = lstg.var
            var.heal_factor = var.heal_factor + 0.0016 * d
        end,
        condfunc = nil,
    },
    [25] = {
        name = [[专注法阵]],
        stitle = [[汇聚力量与魔力的法阵]],
        sdes = [[出现一个跟随/player的法阵
/player在阵内时，/atk§g+50%§d、/spd§r-15%]],
        detail = [[/t25sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[/passtime1]],
        condd = nil,
        tags = nil,
        picID = 22,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            if flag then
                lstg.tmpvar.strength_aura = New(lib.class.strength_aura)
            else
                if IsValid(lstg.tmpvar.strength_aura) then
                    Del(lstg.tmpvar.strength_aura)
                end
            end
        end,
        condfunc = nil,
    },
    [30] = {
        name = [[魔力护瓶]],
        stitle = [[……代价是什么呢]],
        sdes = [[当/spelle足够多时，能够以能量§g抵消被弹
但/spelle不够多时，会使§r受到的伤害增加]],
        detail = [[记§ya=/spellstk个数
每当被弹&体术时，如果此时/spelle>70%，
则§g不损耗/hp§d，改为§r扣除10%能量§d
每次触发此/item后，下次触发§r额外扣除5%能量§d，
最大扣除§b70%§d能量；
若此时/spelle不足，受到伤害则会§r提高15a%]],
        repeatd = [[最大扣除/spelle§g-30%
充能不足时受到伤害§g减少5a%]],
        collabd = nil,
        unlockd = [[使用§p5§d次符卡]],
        condd = nil,
        tags = { tg.defend, tg.store, tg.debuff },
        picID = 27,
        repeatp = 0.35,
        maxc = 2,
        initialTake = true,
        event = function(d, flag)
            if flag then
                if not IsValid(lstg.tmpvar.magic_bottle) then
                    lstg.tmpvar.magic_bottle = New(lib.class.magic_bottle_renderer)
                else
                    local magic_bottle = lstg.tmpvar.magic_bottle
                    magic_bottle.count = magic_bottle.count + 1
                    magic_bottle.dev_value = min(magic_bottle.dev_value, 100 - magic_bottle.count * 30)
                end
                mission_lib.GoMission(44)
            else
                local magic_bottle = lstg.tmpvar.magic_bottle
                if IsValid(magic_bottle) then
                    magic_bottle.count = magic_bottle.count - 1
                    magic_bottle.dev_value = min(magic_bottle.dev_value, 100 - magic_bottle.count * 30)
                    if magic_bottle.count == 0 then
                        Del(magic_bottle)
                    end
                end
            end
        end,
        condfunc = nil,
    },
    [44] = {
        name = [[平安喜乐]],
        stitle = [[一帆风顺]],
        sdes = [[/player受到伤害时仅增加原本所增加的/chaos的§g66%]],
        detail = [[/t44sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[/chaos达到§r200%]],
        condd = nil,
        tags = tg.chaos,
        picID = 37,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            lstg.var.peace_chaos = flag
        end,
        condfunc = nil,
    },
    [45] = {
        name = [[⑨之祝福]],
        stitle = [[⑨⑨⑨⑨⑨⑨⑨⑨⑨]],
        sdes = [[为美好的世界献上小天才的§g各种增益§d！
"还不快谢谢本老娘！"]],
        detail = [[/spellme§g-0.9%
恢复§g9§d/hp
/maxhp§g+9
/atk&/spd§g+0.9
/br§g+9
/hitb§g-0.09
/chaos§g-0.9%
/t24的权重增加§g9倍]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[获得§b9§d次/tgnine标签的/item]],
        condd = nil,
        tags = tg.nine,
        picID = 38,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local v = lstg.var
            local p = player
            p.dmg_offset = p.dmg_offset + 0.9 * d
            p.hspeed_offset = p.hspeed_offset + 0.9 * d
            p.lspeed_offset = p.lspeed_offset + 0.9 * d
            p.shoot_set.range.offset = p.shoot_set.range.offset + 9 * d
            player_lib.AddPlayerCollisize(-0.09 * d)
            player_lib.AddMaxLife(9 * d)
            player_lib.AddLife(9 * d)
            player_lib.AddChaos(-0.9 * d)
            player_lib.SetEnergy(v.maxenergy - 0.9 * d)
            if flag then
                if lstg.var.addition[24] then
                    mission_lib.GoMission(8)
                end
                local othert = lib.AdditionTotalList[24]
                othert.pro_fixed = othert.pro_fixed + 9
            else
                local othert = lib.AdditionTotalList[24]
                othert.pro_fixed = othert.pro_fixed - 9
            end
        end,
        condfunc = nil,
    },
    [52] = {
        name = [[一对的自我]],
        stitle = [[谁？]],
        sdes = [[在屏幕上形成一个假/player，会射击造成§g/player相同伤害的子弹
假/player以屏幕中线为对称轴，对称/player移动]],
        detail = [[/plopca§r-30%
假/player以屏幕中线为对称轴，对称/player移动
假/player发射与/pbullet完全一致的子弹，但/ss是/player的§b1/3]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[一局游戏内达到§p5§d级]],
        condd = nil,
        tags = nil,
        picID = 45,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local p = player
            if flag then
                lstg.tmpvar.fake_player = New(lib.class.fake_player)
                p._wisys.alpha2 = p._wisys.alpha2 * 0.8
                AddWaveEvent("refresh_fakeplayer", 1, function()
                    task.New(lstg.tmpvar.fake_player, function()
                        local self = task.GetSelf()
                        for i = 1, 10 do
                            self.vscale = 1 + i / 10
                            self.hscale = 1 - i / 10
                            task.Wait()
                        end
                        self.x, self.y = player.x, player.y
                        for i = 1, 10 do
                            self.vscale = 2 - i / 10
                            self.hscale = i / 10
                            task.Wait()
                        end
                    end)
                end)
            else
                if IsValid(lstg.tmpvar.fake_player) then
                    Del(lstg.tmpvar.fake_player)
                end
                p._wisys.alpha2 = p._wisys.alpha2 / 0.8
                RemoveWaveEvent("refresh_fakeplayer")
            end
        end,
        condfunc = nil,
    },
    [55] = {
        name = [[见血封喉术]],
        stitle = [[令敌我双方都害怕的秘籍]],
        sdes = [[/atk§g+1.0§d，/atkR§g+25%§d
/player射击时，§r/hp会缓慢流失]],
        detail = [[/t55sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[死亡§p10§d次]],
        condd = nil,
        tags = { tg.sacrifice, tg.debuff },
        picID = 48,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local p = player
            p.dmg_offset = p.dmg_offset + 1 * d
            p.dmg_fixed = p.dmg_fixed + 0.25 * d
            if flag then
                p._playersys:addFrameBeforeEvent("damage_when_shoot", 1, function(self)
                    if lstg.var.frame_counting then
                        if self.__shoot_flag and self.nextshoot <= 0 then
                            local v = lstg.var
                            local n = player_lib.ReduceLife(0.0045 * max(v.maxlife, 50) / 39, true)
                            if v.cowrie_shell and n and n > 0 then
                                v.weak_life = v.weak_life + n
                                v.maxweak_life = v.maxweak_life + n
                            end
                        end
                    end
                end)
            else
                p._playersys:removeFrameBeforeEvent("damage_when_shoot")
            end
        end,
        condfunc = nil,
    },
    [61] = {
        name = [[正体不明的飞仓]],
        stitle = [[幻想溢出]],
        sdes = [[敌方子弹有概率变为§y特殊子弹
§-*该子弹能获得意义不明的特性*]],
        detail = [[敌方子弹有§b30%§d概率变为§y特殊子弹§d，随机获得以下§b1~2§d种特性：
每§b10~22帧§d改变一次弹型
每§b10~30帧§d改变一次颜色
每§b120~300帧§d，有§b50%§d概率速度变为负数
每§b150~300帧§d，子弹大小变为原来的§b0.5~1.2§d倍
经过§b0~300帧§d后停留在原地，§b120帧§d后消失
每§g20帧§d有§g10%§d的概率变为/expp]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[/passtime2]],
        condd = nil,
        tags = tg.debuff,
        picID = 53,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.var.nue_special_bullet = flag
        end,
        condfunc = nil,
    },
    [62] = {
        name = [[ToDo清单]],
        stitle = [[首要任务：退治]],
        sdes = [[每波提供一个§y「ToDo擦弹」§d任务，
达到目标数后会获得一个非/tgdebuff道具]],
        detail = [[记§ya=当前Wave数
每波提供一个§y「ToDo擦弹」§d任务，完成后会获得一个非/tgdebuff道具
§y「ToDo擦弹」§d：拾取时的Wave需擦§b100+5a§d颗弹，
其他Wave需擦§b0.8*前波擦弹数+a^2§d颗弹]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[一场游戏内擦满§p1000§d颗弹]],
        condd = nil,
        tags = tg.store,
        picID = 55,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local var = lstg.var
            local p = player
            if flag then
                var.todo_graze_check = 100 + 50 * var.wave
                var.todo_graze = 0
                local finish_flag
                p._playersys:addGrazingBeforeEvent("addpower", 1, function(self)
                    var.todo_graze = var.todo_graze + 1
                    if var.todo_graze >= var.todo_graze_check and not finish_flag then
                        finish_flag = true
                        local k = lib.GetAdditionList(1, function(tool)
                            return tool.isTool and not lib.SearchToolTag(tool, "debuff")
                        end)
                        if k[1] then
                            k[1]:Set(true)
                            ext.notice_menu:AdditionAdd(k[1].id, "bonus2", i18n("addition_des", 3)[62].name)
                        end
                    end
                end)
                AddWaveEvent("todo_graze", 1, function()
                    local last_graze = var.todo_graze
                    local w = var.wave + 1
                    var.todo_graze_check = int(0.8 * last_graze + w * w)
                    var.todo_graze = 0
                    finish_flag = false
                end)
            else
                var.todo_graze_check = nil
                var.todo_graze = 0
                p._playersys:removeGrazingBeforeEvent("addpower")
                RemoveWaveEvent("todo_graze")
            end
        end,
        condfunc = nil,
    },
    [71] = {
        name = [[便携式后户]],
        stitle = [[小小轮椅的力量]],
        sdes = [[/br§g+7
允许主炮§g穿墙1次]],
        detail = [[/t71sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[累计获得过§p5§d次/t59]],
        condd = nil,
        tags = nil,
        picID = 59,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local ss = player.shoot_set.range
            ss.offset = ss.offset + 7 * d
            lstg.var.shuttle_main_bullet = flag
        end,
        condfunc = nil,
    },
    [73] = {
        name = [[极欲的暴食]],
        stitle = [[八分饱]],
        sdes = [[每擦1颗弹，擦弹范围增大§g1%§d，最大增加§r266%
当§b10帧§d内没擦弹时，擦弹范围逐渐减小至原状态]],
        detail = [[记§ya=0§-(最大为266)
擦弹范围增大§ga%
每擦1颗弹，§ga+1
当§b10帧§d内没擦弹时，擦弹范围逐渐减小至原状态]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[一场游戏内擦满§p2000§d颗弹]],
        condd = nil,
        tags = nil,
        picID = 61,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local v = lstg.var
            v.violent_eater = flag
            v.violent_eater_n = 0
            v.violent_eater_CD = 0
            if flag then
                player._playersys:addFrameBeforeEvent("violent_eater", 1, function(p)
                    v.violent_eater_CD = max(v.violent_eater_CD - 1, 0)
                    if v.violent_eater_CD == 0 then
                        if v.violent_eater_n > 0 then
                            p.grazer_colli_factor = p.grazer_colli_factor - 0.01 * v.violent_eater_n * 0.02
                            v.violent_eater_n = v.violent_eater_n - v.violent_eater_n * 0.02
                        end
                    end
                end)
                player._playersys:addGrazingBeforeEvent("violent_eater", 1, function(p)
                    if v.violent_eater_n < 266 then
                        p.grazer_colli_factor = p.grazer_colli_factor + 0.01
                        v.violent_eater_n = v.violent_eater_n + 1
                    end
                    v.violent_eater_CD = 10
                end)
            else
                player._playersys:removeFrameBeforeEvent("violent_eater")
                player._playersys:removeGrazingBeforeEvent("violent_eater")
            end
        end,
        condfunc = nil,
    },
    [76] = {
        name = [[向神山的供品]],
        stitle = [[妖怪之山名产]],
        sdes = [[/maxhp§g+7
/itcl下降§g64]],
        detail = [[/t76sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[一局游戏内达到§p10§d级]],
        condd = nil,
        tags = tg.store,
        picID = 64,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            if flag then
                player_lib.AddMaxLife(7)
                player_lib.AddLife(7)
                player.collect_line = player.collect_line - 64
            else
                player_lib.AddMaxLife(-7)
                player.collect_line = player.collect_line + 64
            end
        end,
        condfunc = nil,
    },
    [78] = {
        name = [[妖怪测谎仪]],
        stitle = [[可视化本我活动]],
        sdes = [[生成§g3§d个半透明圆形/minion，围绕/player旋转
点击§-低速键§d时，/minion发射半透明弹链，§g造成一定伤害]],
        detail = [[记§ya=一秒内按§-低速键§y的次数§d
获得§g3§d个半透明圆形/minion，在轨道上围绕/player旋转
高速时，/minion旋转半径较大
低速时，/minion汇聚到/player处
点击§-低速键§d时，生成一定数量的半透明子弹链
经过§b30帧§d后向外发散
每颗造成§g5a^2*max(1,/minion半径/100)%/atk§d的伤害]],
        repeatd = nil,
        collabd = [[/t126：/player失去光环，/t78的/minion获得较小范围的光环]],
        unlockd = nil,
        condd = nil,
        tags = tg.store,
        picID = 66,
        repeatp = 0,
        maxc = 2,
        initialTake = true,
        event = function(d, flag)
            if flag then
                if not IsValid(lstg.tmpvar.lie_detector) then
                    lstg.tmpvar.lie_detector = New(lib.class2.lie_detector)
                else
                    lstg.tmpvar.lie_detector.count = lstg.tmpvar.lie_detector.count + 1
                end
                if lstg.tmpvar.god_circle_with_lie_detector then
                    for i = lstg.tmpvar.lie_detector.count * 3 - 2, lstg.tmpvar.lie_detector.count * 3 do
                        lstg.tmpvar.god_circle_with_lie_detector[i] = New(lib.class3.god_circle_with_lie_detector, i)
                    end
                end
            else
                local lie_detector = lstg.tmpvar.lie_detector
                if IsValid(lie_detector) then
                    local god_circle = lstg.tmpvar.god_circle_with_lie_detector
                    if god_circle then
                        for i = lie_detector.count * 3 - 2, lie_detector.count * 3 do
                            if IsValid(god_circle[i]) then
                                Del(god_circle[i])
                            end
                        end
                    end
                    lie_detector.count = lie_detector.count - 1
                    if lie_detector.count == 0 then
                        Del(lie_detector)
                    end
                end
            end
        end,
        condfunc = nil,
    },
    [80] = {
        name = [[硝酸甘油]],
        stitle = [[高燃易爆性！]],
        sdes = [[每当/player使用bomb时，恢复§g7§d/hp]],
        detail = [[记§ya=1
每当/player使用bomb时，恢复§g7a§d/hp]],
        repeatd = [[§ya§d+1]],
        collabd = nil,
        unlockd = [[使用§p15§d次符卡]],
        condd = nil,
        tags = { tg.life, tg.store },
        picID = 68,
        repeatp = 0,
        maxc = 2,
        initialTake = true,
        event = function(d, flag)
            local v = lstg.var
            if flag then
                v.bomb_healing = v.bomb_healing or 0
                v.bomb_healing = v.bomb_healing + 7
            else
                v.bomb_healing = v.bomb_healing - 7
                if v.bomb_healing == 0 then
                    v.bomb_healing = nil
                end
            end
        end,
        condfunc = nil,
    },
    [81] = {
        name = [[经验血袋]],
        stitle = [[一滴EXP十滴血]],
        sdes = [[每当升级时，恢复§g(当前等级)%/maxhp§d的/hp
最大恢复§b50%§d/maxhp]],
        detail = [[/t81sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[一局游戏内达到§p20§d级]],
        condd = nil,
        tags = { tg.life, tg.store },
        picID = 69,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            lstg.var.levelup_healing = flag
        end,
        condfunc = nil,
    },
    [85] = {
        name = [[EXHP]],
        stitle = [[HP = EXP]],
        sdes = [[每当/player失去§b2.65%/maxhp§d的/hp时
在/player前方生成§g1§d颗/expp]],
        detail = [[/t85sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[一局游戏内达到§p25§d级]],
        condd = nil,
        tags = { tg.sacrifice, tg.store },
        picID = 74,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            lstg.var.hp_to_exp = flag
        end,
        condfunc = nil,
    },
    [87] = {
        name = [[以命汲命]],
        stitle = [[无限的成长]],
        sdes = [[拾取boss掉落的残碎额外使/maxhp§g+7]],
        detail = [[/t87sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = { tg.life, tg.store },
        picID = 76,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            local v = lstg.var
            v.chip_addmaxlife = flag
        end,
        condfunc = nil,
    },
    [94] = {
        name = [[符海突击学说]],
        stitle = [[广域覆盖]],
        sdes = [[/atkR§r-34%§d，/ss§g+1§d，/ssR§g+44%§d
/pbullet散射角§b+15°§d]],
        detail = [[/t94sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[/passtime3]],
        condd = nil,
        tags = tg.debuff,
        picID = 83,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local p = player
            p.dmg_fixed = p.dmg_fixed - 0.34 * d
            local ss = p.shoot_set.speed
            ss.offset = ss.offset + 1 * d
            ss.fixed = ss.fixed + 0.44 * d
            p.shoot_angle_off = p.shoot_angle_off + 15 * d
        end,
        condfunc = nil,
    },
    [114] = {
        name = [[燕的子安贝]],
        stitle = [[永命线]],
        sdes = [[/player受到的伤害增加§r50%§d，受伤的/hp变为§p虚血
§p虚血§d可以§g自愈]],
        detail = [[受到的被弹&体术伤害将§r增加50%
受伤的/hp将变成暗绿色的§p虚血§d，每秒恢复§g1/6§d的§p虚血
再次受到伤害时，先前的所有§p虚血§r全部归零
收集残碎会§g立即回复§p虚血]],
        repeatd = nil,
        collabd = [[/t55：流逝的/hp将变为虚血]],
        unlockd = [[收取§p"神宝「无限的生命之泉」"]],
        condd = nil,
        tags = { tg.defend, tg.neet, tg.life, tg.debuff },
        picID = 103,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.var.cowrie_shell = flag
            if flag then
                player._playersys:addFrameBeforeEvent("cowrie_shell", 1, function()

                    local v = lstg.var
                    if v.frame_counting then
                        if v.weak_life > 0 then
                            local n = player_lib.AddLife(v.maxweak_life / 360) or 0
                            v.weak_life = max(0, v.weak_life - n)
                        else
                            v.maxweak_life = 0
                        end
                    end
                end)
            end
        end,
        condfunc = nil,
    },
    [116] = {
        name = [[中子星]],
        stitle = [[判定奇点]],
        sdes = [[/player贴图与/hitb§b*75%§d，/spd§r-0.25
使/w55和/w57天气无效化]],
        detail = [[/t116sdes]],
        repeatd = nil,
        collabd = [[/t142：引力变大，其造成的伤害翻倍]],
        unlockd = [[收取§p"「阿波罗11的捏造」"]],
        condd = nil,
        tags = nil,
        picID = 105,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.var.neutron_star = flag
            local p = player
            p.hspeed_offset = p.hspeed_offset - 0.25 * d
            p.lspeed_offset = p.lspeed_offset - 0.25 * d
            player_lib.AddPlayerCollisize(0, 0, -0.25 * d)
        end,
        condfunc = nil,
    },
    [119] = {
        name = [[虚与实的境界]],
        stitle = [[无有合一]],
        sdes = [[点击§-低速键§d时可以使离/player最近的3颗弹幕§b反转判定]],
        detail = [[/t119sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[击败1次/bossYukari]],
        condd = nil,
        tags = { tg.defend, tg.store },
        picID = 108,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            if flag then
                player._playersys:addFrameBeforeEvent("fake_and_real", 1, function(p)
                    if p._playersys:keyIsPressed("slow") then
                        local heap = {}
                        local count = 3
                        object.BulletIndesDo(function(o)
                            table.insert(heap, { o, Dist(p, o) })
                            if #heap > count then
                                table.sort(heap, function(a, b)
                                    return a[2] < b[2]
                                end)
                                table.remove(heap, #heap)
                            end
                        end)
                        -- 获取最近的三颗子弹
                        for i = 1, count do
                            local target = heap[i] and heap[i][1]
                            if IsValid(target) then
                                New(lib.class2.fake_and_real_eff, target)
                                bullet.setfakeColli(target, target._no_colli)
                            end
                        end
                    end
                end)
            else
                player._playersys:removeFrameBeforeEvent("fake_and_real")
            end
        end,
        condfunc = nil,
    },
    [122] = {
        name = [[具现化记忆]],
        stitle = [[回溯子弹]],
        sdes = [[/ss§g+0.7§d，/brR§g+100%§d
当/pbullet达到§b50%/br§d时，将反转速度方向]],
        detail = [[/t122sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[/passtime6]],
        condd = nil,
        tags = nil,
        picID = 111,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local ss = player.shoot_set.speed
            ss.offset = ss.offset + 0.7 * d
            local sr = player.shoot_set.range
            sr.fixed = sr.fixed + 1 * d
            lstg.var.return_bullet = flag
        end,
        condfunc = nil,
    },
    [135] = {
        name = [[永远的幼月]],
        stitle = [[恸红]],
        sdes = [[每当敌人死亡时，在原地留下一个§y血色光环
光环每§g(66//ss)帧§d造成§g2%/atk§d的伤害，§g45帧§d后消失]],
        detail = [[每当敌人死亡时，在原地留下一个§y血色光环
光环每§g(66//ss)帧§d造成§g2%/atk§d的伤害，§g45帧§d后消失
光环的大小和敌人/hitb成正比]],
        repeatd = nil,
        collabd = [[/t123：增大光环的范围]],
        unlockd = nil,
        condd = nil,
        tags = tg.store,
        picID = 124,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local v = lstg.var
            v.forever_scarlet = flag
            if flag then
                player._playersys:addEnemyKillEvent("forever_scarlet", 1, function(_, _, self)
                    local index = 2.5
                    if v.scarlet_focus > 0 then
                        index = 5
                    end
                    New(lib.class3.forever_scarlet_moon, self.a * index, self.x, self.y)
                end)
            else
                player._playersys:removeEnemyKillEvent("forever_scarlet")
            end
        end,
        condfunc = nil,
    },
    [138] = {
        name = [[过往的风花]],
        stitle = [[被遗忘的遗弃之物]],
        sdes = [[获得一个追随型/minion
每波开始时，随机获得一个§-(满叠)§d/tempitem]],
        detail = [[/t138sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[/passtime5]],
        condd = nil,
        tags = tg.baby,
        picID = 127,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            if flag then
                AddWaveEvent("randomTemporary", 1, function()
                    local lvl_lib = stg_levelUPlib
                    if lstg.tmpvar.randomTemporary then
                        local t = lstg.tmpvar.randomTemporary
                        t.temporary = false
                        for _ = 1, t.maxcount do
                            t:Remove()
                        end
                        lstg.tmpvar.randomTemporary = nil
                    end
                    local othercond = function(tool)
                        return tool.isTool and not lstg.var.addition[tool.id] and not lvl_lib.SearchToolTag(tool, "debuff")
                    end
                    local tool = lvl_lib.GetAdditionList(1, othercond)[1]
                    if tool then
                        tool.temporary = true
                        for _ = 1, tool.maxcount do
                            tool:Set(true, true)
                        end
                    end
                    lstg.tmpvar.randomTemporary = tool
                    if tool then
                        ext.notice_menu:AdditionAdd(tool.id, "pin00", i18n("addition_des", 3)[138].name, 25, 255, 227, 132)
                    end
                end)
                lstg.tmpvar.huyuelin_baby = New(lib.class4.huyuelin_baby)
            else
                RemoveWaveEvent("randomTemporary")
                if lstg.tmpvar.randomTemporary then
                    local t = lstg.tmpvar.randomTemporary
                    t.temporary = false
                    lstg.tmpvar.randomTemporary = nil
                end
                if IsValid(lstg.tmpvar.huyuelin_baby) then
                    Del(lstg.tmpvar.huyuelin_baby)
                end
            end
        end,
        condfunc = nil,
    },
    [139] = {
        name = [[茶杯灵梦]],
        stitle = [[灵梦宝宝]],
        sdes = [[获得一个小灵梦追随型/minion
发射§g追踪札符§d，造成§g2.0§d的伤害]],
        detail = [[/t139sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = { tg.baby, tg.store },
        picID = 128,
        repeatp = 0,
        maxc = 3,
        initialTake = true,
        event = function(d, flag)
            if flag then
                lstg.tmpvar.reimu_baby = lstg.tmpvar.reimu_baby or {}
                table.insert(lstg.tmpvar.reimu_baby, New(lib.class4.reimu_baby))
            else
                if lstg.tmpvar.reimu_baby then
                    if IsValid(lstg.tmpvar.reimu_baby[1]) then
                        Del(lstg.tmpvar.reimu_baby[1])
                        table.remove(lstg.tmpvar.reimu_baby, 1)
                    end
                end
            end
        end,
        condfunc = nil,
    },
    [140] = {
        name = [[茶杯魔理沙]],
        stitle = [[魔理沙宝宝]],
        sdes = [[获得一个小魔理沙追随型/minion
发射§g小导弹§d，造成§g6.0§d的伤害]],
        detail = [[/t140sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = { tg.baby, tg.store },
        picID = 129,
        repeatp = 0,
        maxc = 3,
        initialTake = true,
        event = function(d, flag)
            if flag then
                lstg.tmpvar.marisa_baby = lstg.tmpvar.marisa_baby or {}
                table.insert(lstg.tmpvar.marisa_baby, New(lib.class4.marisa_baby))
            else
                if lstg.tmpvar.marisa_baby then
                    if IsValid(lstg.tmpvar.marisa_baby[1]) then
                        Del(lstg.tmpvar.marisa_baby[1])
                        table.remove(lstg.tmpvar.marisa_baby, 1)
                    end
                end
            end
        end,
        condfunc = nil,
    },
    [144] = {
        name = [[后撤的大人]],
        stitle = [[此面向敌]],
        sdes = [[有§g21%§d概率额外向后发射/pbullet]],
        detail = [[/t144sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = nil,
        picID = 133,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local v = lstg.var
            v.behind_main_bullet = flag
        end,
        condfunc = nil,
    },
    [147] = {
        name = [[招财宛]],
        stitle = [[死宛猫猫]],
        sdes = [[获得一个猫猫追随型/minion
有节奏地向上洒小子弹，每颗造成§g1.0§d的伤害]],
        detail = [[/t147sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = { tg.siyuan, tg.baby },
        picID = 136,
        repeatp = 0,
        maxc = 3,
        initialTake = true,
        event = function(d, flag)
            if flag then
                lib.siyuan_achievement()
                lstg.tmpvar.siyuan_baby2 = lstg.tmpvar.siyuan_baby2 or {}
                table.insert(lstg.tmpvar.siyuan_baby2, New(lib.class4.siyuan_baby2))
            else
                if lstg.tmpvar.siyuan_baby2 then
                    if IsValid(lstg.tmpvar.siyuan_baby2[1]) then
                        Del(lstg.tmpvar.siyuan_baby2[1])
                        table.remove(lstg.tmpvar.siyuan_baby2, 1)
                    end
                end
            end
        end,
        condfunc = nil,
    },
    [152] = {
        name = [[Mimichan]],
        stitle = [[一飞冲天]],
        sdes = [[/atk§g+1.5
/pbullet变为§y火箭子弹§d，初始从0开始逐渐加速，直至200%/bv]],
        detail = [[/t152sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[通关§p挑战3]],
        condd = nil,
        tags = tg.store,
        picID = 141,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local p = player
            local v = lstg.var
            p.dmg_offset = p.dmg_offset + 1.5 * d
            v.is_mimichan = flag
            if flag then
                player_lib.SetPlayerBulletImg(2, "mimichan_bullet")
            else
                player_lib.SetPlayerBulletImg(2)
            end
        end,
        condfunc = nil,
    },
    [155] = {
        name = [[深海七花]],
        stitle = [[海之恩惠]],
        sdes = [[随机获得§g7种效果之一§d，效果的获得§-不重复]],
        detail = [[随机获得以下某一种效果§-(不会重复)§d：
§r红 /maxhp+10
§o橙 删除3个/infringe
§y黄 缩短夏季时长1波
§g绿 恢复25/hp
§c青 获得3个/benefit
§b蓝 缩短冬季时长1波
§p紫 修复3个损坏的/item]],
        repeatd = [[a+1
增加§g5§d倍获得权重]],
        collabd = nil,
        unlockd = [[通关§p挑战5]],
        condd = nil,
        other = {
            "深海七花之绿(恢复25/hp)",
            "深海七花之红(/maxhp+10)",
            "深海七花之紫(获得3个裨益)",
            "深海七花之橙(删除3个灾害)",
            "深海七花之青(修复3个损坏的道具)",
            "深海七花之黄(缩短夏季时长)",
            "深海七花之蓝(缩短冬季时长)"
        },
        tags = tg.life,
        picID = 144,
        repeatp = 5,
        maxc = 7,

        initialTake = false,
        event = function(d, flag, otherflag)
            local var = lstg.var
            local tvar = lstg.tmpvar
            local other = i18n("addition_des", 3)[155].other
            local eventArr = {
                function()
                    if flag then
                        if not otherflag then
                            ext.popup_menu:FlyInOneTool(ReplaceTextWithCommand(other[1]), 100, 255, 100, 155, "bonus")
                        end
                        player_lib.AddLife(25)
                    end
                end,
                function()
                    if flag then
                        if not otherflag then
                            ext.popup_menu:FlyInOneTool(ReplaceTextWithCommand(other[2]), 250, 100, 100, 155, "bonus")
                        end
                    end
                    player_lib.AddMaxLife(10 * d)
                end,
                function()
                    if not otherflag then
                        if flag then
                            local list = stg_levelUPlib.GetAdditionList(3, function(p)
                                return p.state == 1 and not p.spBENEFIT
                            end)
                            var.seven_flower_BiYi_list = list
                            local show_list = sp:CopyTable(list)
                            table.insert(show_list, lib.AdditionTotalList[155])
                            ext.popup_menu:FlyIn(ReplaceTextWithCommand(other[3]), 218, 112, 214, show_list, "bonus")
                            for _, p in ipairs(list) do
                                p:Set()
                            end
                        else
                            if var.seven_flower_BiYi_list then
                                for _, p in ipairs(var.seven_flower_BiYi_list) do
                                    p:Remove()
                                end
                            end
                        end
                    end
                end,
                function()
                    if not otherflag then
                        if flag then
                            local list = {}
                            local QingHai_list = {}
                            local count = (var.addition_count[3]) or 0
                            for k, p in pairs(var.addition) do
                                local tool = lib.AdditionTotalList[k]
                                if tool.state == 3 then
                                    for _ = 1, p do
                                        table.insert(QingHai_list, tool)
                                    end
                                end
                            end
                            for _ = 1, min(count, 3) do
                                table.insert(list, table.remove(QingHai_list, ran:Int(1, #QingHai_list)))
                            end
                            var.seven_flower_QingHai_list = list
                            local show_list = sp:CopyTable(list)
                            table.insert(show_list, lib.AdditionTotalList[155])
                            ext.popup_menu:FlyIn(ReplaceTextWithCommand(other[4]), 135, 200, 200, show_list, "bonus")
                            for _, p in ipairs(list) do
                                p:Remove()
                            end
                        else
                            if var.seven_flower_QingHai_list then
                                for _, p in ipairs(var.seven_flower_QingHai_list) do
                                    p:Set()
                                end
                            end
                        end
                    end
                end,
                function()
                    if not otherflag then
                        if flag then
                            local list = {}
                            local Broken_list = {}
                            local count = 0
                            for k, p in pairs(var.addition) do
                                local tool = lib.AdditionTotalList[k]
                                if tool.broken then
                                    for _ = 1, p do
                                        count = count + 1
                                        table.insert(Broken_list, tool)
                                    end
                                end
                            end
                            for _ = 1, min(count, 3) do
                                table.insert(list, table.remove(Broken_list, ran:Int(1, #Broken_list)))
                            end
                            var.seven_flower_Broken_list = list
                            local show_list = sp:CopyTable(list)
                            table.insert(show_list, lib.AdditionTotalList[155])
                            ext.popup_menu:FlyIn(ReplaceTextWithCommand(other[5]), 135, 206, 235, show_list, "bonus")
                            for _, p in ipairs(list) do
                                stg_levelUPlib.RecoverAddition(p)
                            end
                        else
                            if var.seven_flower_Broken_list then
                                for _, p in ipairs(var.seven_flower_Broken_list) do
                                    stg_levelUPlib.BreakAddition(p)
                                end
                            end
                        end
                    end
                end,
                function()
                    if flag and not otherflag then
                        ext.popup_menu:FlyInOneTool(ReplaceTextWithCommand(other[6]), 255, 227, 132, 155, "bonus")
                    end
                    local w = lstg.weather
                    w.season_last[2] = w.season_last[2] - d
                end,
                function()
                    if flag and not otherflag then
                        ext.popup_menu:FlyInOneTool(ReplaceTextWithCommand(other[7]), 130, 140, 222, 155, "bonus")
                    end
                    local w = lstg.weather
                    w.season_last[4] = w.season_last[4] - d
                end
            }
            tvar.seven_flower_count = tvar.seven_flower_count or 0
            if flag then
                tvar.seven_flower_count = sp:TweakValue(tvar.seven_flower_count + 1, 7, 1)
                eventArr[var.seven_flowers[tvar.seven_flower_count]]()
            else
                eventArr[var.seven_flowers[tvar.seven_flower_count]]()
                tvar.seven_flower_count = sp:TweakValue(tvar.seven_flower_count - 1, 7, 1)
            end
        end,
    },
    [157] = {
        name = [[扭臀猫猫]],
        stitle = [[嘲讽]],
        sdes = [[/ss§g+0.9§d，获得一个猫猫追随型/minion
发射追踪子弹，每颗造成§g0.8§d的伤害]],
        detail = [[/t157sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = tg.baby,
        picID = 146,
        repeatp = 0,
        maxc = 3,
        initialTake = true,
        event = function(d, flag)
            local ss = player.shoot_set.speed
            ss.offset = ss.offset + 0.9 * d
            if flag then
                lstg.tmpvar.tease_cat = lstg.tmpvar.tease_cat or {}
                table.insert(lstg.tmpvar.tease_cat, New(lib.class4.tease_cat))
            else
                if lstg.tmpvar.tease_cat then
                    if IsValid(lstg.tmpvar.tease_cat[1]) then
                        Del(lstg.tmpvar.tease_cat[1])
                        table.remove(lstg.tmpvar.tease_cat, 1)
                    end
                end
            end
        end,
        condfunc = nil,
    },
    [164] = {
        name = [[向侧之月]],
        stitle = [[月的另一边]],
        sdes = [[/player处展开1个§y可消弹的月球§d，当月球碰到弹幕时缩小至消失
消失间隔§b85帧§d后，会在§b120帧§d内完全展开]],
        detail = [[/t164sdes]],
        repeatd = nil,
        collabd = [[/t135：月球变为红色]],
        unlockd = [[击败1次/bossLunaChild]],
        condd = nil,
        tags = tg.defend,
        picID = 153,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            if flag then
                lstg.tmpvar.protect_moon = New(lib.class4.protect_moon)
                AddWaveEvent("150achievement", 1, function()
                    lstg.tmpvar.protect_moon_achievement = lstg.var.chaos >= 100
                end)
                lib.AddWaveFinalEvent("150achievement", 1, function()
                    if lstg.tmpvar.protect_moon_achievement then
                        ext.achievement:get(150)
                    end
                end)
            else
                if IsValid(lstg.tmpvar.protect_moon) then
                    Del(lstg.tmpvar.protect_moon)
                end
                RemoveWaveEvent("150achievement")
                lib.RemoveWaveFinalEvent("150achievement")
            end
        end,
        condfunc = nil,
    },
    [166] = {
        name = [[异议！]],
        stitle = [[不支持日语]],
        sdes = [[每隔§b180帧§d生成一个§r"異議あり！"
寻找场上/hp最高的非boss敌人§y秒杀§d]],
        detail = [[/t166sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[/passtime2]],
        condd = nil,
        tags = nil,
        picID = 155,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            if flag then
                lstg.tmpvar.igiari_shooter = New(lib.class4.igiari_shooter)
            else
                if IsValid(lstg.tmpvar.igiari_shooter) then
                    Del(lstg.tmpvar.igiari_shooter)
                end
            end
        end,
        condfunc = nil,
    },
    [173] = {
        name = [[石是球势]],
        stitle = [[飞翔于天空的不思议经验]],
        sdes = [[/expR§g+50%
/expp下降速度§r+75%]],
        detail = [[/t173sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[使用/playerMarisa/passtime1]],
        condd = nil,
        tags = { tg.store, tg.debuff },
        picID = 162,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local v = lstg.var
            v.exp_factor = v.exp_factor + 0.5 * d
            v.exp_drop_factor = v.exp_drop_factor + 0.75 * d
        end,
        condfunc = nil,
    },
    [181] = {
        name = [[无情之地]],
        stitle = [[受控于吾]],
        sdes = [[场上所有敌人以较慢的速度§g流失/hp]],
        detail = [[记§ya=2
场上所有敌人每秒流失§g(a)%的/hp§d]],
        repeatd = [[§ya§d+1]],
        collabd = nil,
        unlockd = [[获得过/t53]],
        condd = nil,
        tags = nil,
        picID = 41,
        repeatp = 0,
        maxc = 3,
        initialTake = true,
        event = function(d, flag)
            local v = lstg.var
            v.fierce_place = v.fierce_place + d
            if flag and v.fierce_place == 1 then
                player._playersys:addFrameBeforeEvent("fierce_place", 1, function()
                    if v.frame_counting then
                        object.EnemyNontjtDo(function(e)
                            if e.class.base.take_damage then
                                e.class.base.take_damage(e, (0.01 + v.fierce_place * 0.01) * (e.maxhp) / 60)
                            end
                        end)
                    end
                end)

            elseif not flag and v.fierce_place == 0 then
                player._playersys:removeFrameBeforeEvent("fierce_place")
            end
        end,
        condfunc = nil,
    },
    [182] = {
        name = [[梦我梦中]],
        stitle = [[治愈一切伤痛]],
        sdes = [[当/player不进行任何行为超过§b75帧§d后，每秒恢复§g6.53/hp
受击时会被§r打断]],
        detail = [[/t182sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[获得过/t186]],
        condd = nil,
        tags = tg.life,
        picID = 166,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local v = lstg.var
            local sleep_flag = false
            local sleep_eff
            local timer = 0
            if flag then
                player._playersys:addFrameBeforeEvent("dream_in", 1, function()
                    if v.frame_counting then
                        local sys = player._playersys
                        local keyEvent = sys:keyIsDown("shoot") or sys:keyIsDown("spell") or sys:keyIsDown("special") or sys:keyIsDown("slow")
                        if player.dx == 0 and player.dy == 0 and player.protect == 0 and not keyEvent then
                            timer = timer + 1
                        else
                            timer = 0
                            if sleep_flag then
                                if IsValid(sleep_eff) then
                                    sleep_eff.del_flag = true
                                end
                                PlaySound("invalid")
                                sleep_flag = false
                            end
                        end
                        if timer >= 75 then
                            player_lib.AddLife(66 / 606)
                            if not sleep_flag then
                                sleep_eff = New(lib.class5.dream_in, player.x, player.y, 99, 60, 200, 200, 200)
                                sleep_flag = true
                            end
                        end
                    end
                end)
                player._playersys:addMissAfterEvent("dream_in", 1, function()
                    if sleep_flag then
                        player.x = player.x + 0.0001
                    end
                end)
            else
                player._playersys:removeFrameBeforeEvent("dream_in")
                player._playersys:removeMissAfterEvent("dream_in")
            end
        end,
        condfunc = nil,
    },
    [187] = {
        name = [[宝宝们的午夜舞会~]],
        stitle = [[Dance!]],
        sdes = [[宝宝跟班的伤害倍率§g+50%]],
        detail = [[/t187sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[/passtime8]],
        condd = nil,
        tags = nil,
        picID = 171,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            local v = lstg.var
            v.baby_dmg_factor = v.baby_dmg_factor + 0.5 * d
        end,
        condfunc = nil,
    },
    [189] = {
        name = [[异次元杀弹]],
        stitle = [[飞起来！]],
        sdes = [[每隔§b40帧§d，从板底随机位置竖直向上发射§g1§d枚/pbullet]],
        detail = [[/t189sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[/passtime9]],
        condd = nil,
        tags = nil,
        picID = 173,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local var = lstg.var
            if flag then
                player._playersys:addFrameBeforeEvent("random_kill_bullet", 1, function()
                    if player.timer % 40 == 0 then
                        local bv, lifetime = player.cur_bv, player.cur_brange
                        local dmg = player.damage
                        local class = player_main_bullet
                        if var.imaginary_main_bullet then
                            class = player_main_bullet_imaginary
                            dmg = dmg * 1.5
                        end
                        local A = var.reverse_shoot and (-90) or (90)
                        local Y = var.reverse_shoot and (240) or (-240)
                        New(class, ran:Float(-310, 310), Y, bv, A, dmg, lifetime)
                    end
                end)
            else
                player._playersys:removeFrameBeforeEvent("random_kill_bullet")
            end
        end,
        condfunc = nil,
    },
    [194] = {
        name = [[灾衡之天秤]],
        stitle = [[称量万物之物]],
        sdes = [[/chaos§r增加§d时，恢复增加量的§g50%§d的/hp
/chaos§g减少§d时，失去减少量的§r50%§d的/hp]],
        detail = [[/t194sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[/passtime9]],
        condd = nil,
        tags = { tg.chaos, tg.life, tg.debuff },
        picID = 178,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.var.balance_chaos = flag
        end,
        condfunc = nil,
    },
    [196] = {
        name = [[越来越大的如意棒]],
        stitle = [[玉宇澄清万里埃]],
        sdes = [[/pbullet随着游戏进行§g越来越大]],
        detail = [[/t196sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[通关§p挑战18]],
        condd = nil,
        tags = nil,
        picID = 196,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.var.monkey_king = flag
        end
    },
    [198] = {
        name = [[特大头条]],
        stitle = [[おmg]],
        sdes = [[/ss§r-20%§d，/atk§g+1§d
/pbullethitb§g将随/atk而变化§d]],
        detail = [[/t198sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[通关§p挑战12]],
        condd = nil,
        tags = tg.debuff,
        picID = 182,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local p = player
            p.dmg_offset = p.dmg_offset + 1 * d
            local ss = player.shoot_set.speed
            ss.fixed = ss.fixed * 0.8
            lstg.var.omg_bullet = flag
        end,
        condfunc = nil,
    },
    [199] = {
        name = [[埴轮护卫队]],
        stitle = [[死而不亡]],
        sdes = [[击破敌人时，有概率在其位置生成埴轮
埴轮可以阻挡子弹,§g3秒§d后消失]],
        detail = [[记§yb=1§d
击破敌人时，有§g40*b%§d概率在其位置生成埴轮
埴轮可以阻挡子弹,§g180帧§d后消失]],
        repeatd = [[§yb§d+1]],
        collabd = [[/t6：埴轮消失时，产生小范围爆炸]],
        unlockd = nil,
        condd = nil,
        tags = tg.defend,
        picID = 183,
        repeatp = 0,
        maxc = 2,
        initialTake = false,
        event = function(d, flag)
            local v = lstg.var
            v.haniwa = v.haniwa + d
            if flag and d == 1 then
                player._playersys:addEnemyKillEvent("haniwa", 1, function(player, _, self)
                    if ran:Float(0, 1) < v.haniwa * 0.4 then
                        PlaySound("boon00")
                        New(stg_levelUPlib.class5.haniwa, 24, self.x, self.y)
                    end
                end)
            elseif not flag and d == -1 then
                player._playersys:removeEnemyKillEvent("haniwa")
            end

        end,
        condfunc = nil
    },
    [202] = {
        name = [[烟熏的团扇]],
        stitle = [[免受财祸之苦]],
        sdes = [[失去一个/activestk
/maxhp§g+10§d，/atk§g+1.5§d，/ss§g+30%§d，/bv§g+2§d，/br§g+20%§d]],
        detail = [[/t202sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd =  [[携带任意/active通关/scenep1]],
        condd = [[只会在尚有空余的/activestk时出现]],
        tags = { tg.debuff, tg.life, tg.active },
        picID = 202,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local v = lstg.var
            local p = player
            local ss = p.shoot_set.speed
            local ssb = p.shoot_set.bvelocity
            local ssr = p.shoot_set.range
            p.dmg_offset = p.dmg_offset + 1.5 * d
            ss.factor = ss.factor + 0.3 * d
            ssb.offset = ssb.offset + 2 * d
            ssr.factor = ssr.factor + 0.2 * d
            v.max_active_item = v.max_active_item - 1 * d
            if flag then
                player_lib.AddMaxLife(10)
                player_lib.AddLife(10)
            else
                player_lib.AddMaxLife(-10)
            end
        end,
        condfunc = function()
            if AfterActive() then
                local var = lstg.var
                if not stage.current_stage.is_menu then
                    return #var.active_item < var.max_active_item
                else
                    return true
                end
            end
        end
    },
    [215] = {
        name = [[时间慧面]],
        stitle = [[智慧流转]],
        sdes = [[/active的所有充能方式都改为§b时间充能]],
        detail = [[/t215sdes
若原本为§yx§d波充满，则改为§c(10+x*10)§d秒充满
若原本为§yx%§d/spelle充满，则改为§cx*0.9§d秒充满]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[击败1次/bossByakuren]],
        condd = nil,
        tags = { tg.active, tg.debuff },
        picID = 188,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            if flag then
                for _, item in ipairs(activeItem_lib.ActiveTotalList) do
                    if item.type == 2 then
                        item.type = 1
                        item.charge_c = 1 / ((10 + 1 / item.charge_c * 10) * 60)
                    elseif item.type == 3 then
                        item.type = 1
                        item.charge_c = 1 / (1 / item.charge_c * 0.9 * 60)
                    end
                end
            else
                for _, item in ipairs(activeItem_lib.ActiveTotalList) do
                    item.type = item._type
                    item.charge_c = item._charge_c
                end
            end
        end,
        condfunc = AfterActive,
    },
}