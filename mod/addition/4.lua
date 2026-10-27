local lib = stg_levelUPlib
local AddWaveEvent = lib.AddWaveEvent
local RemoveWaveEvent = lib.RemoveWaveEvent

local tg = stg_levelUPlib.tagslist

local function AfterActive()
    return scoredata.StartActive
end

return {
    [27] = {
        name = [[幽魂梦舞]],
        stitle = [[魂飞魄散]],
        sdes = [[擦弹时有几率§g将子弹变成追踪幽魂弹
幽魂弹每秒对敌人造成§g1200%/atk§d的伤害]],
        detail = [[/t27sdes
记§yb=-8§-(最小为-16，最大为40)
判定成功概率§yp=(30.23+b)*0.3
判定成功时§rb-8§d，失败时§gb+8
每擦8颗弹时判定1次，判定成功后被判定的子弹变为追踪幽魂弹，
幽魂每帧造成§g20%/atk§d的伤害，持续§b288帧§d
最多存在§b36§d个幽魂]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[/passtime1]],
        condd = nil,
        tags = tg.defend,
        picID = 24,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            if flag then
                local baodi = -16
                local graze_count = 0
                local var = lstg.var
                player._playersys:addGrazingBeforeEvent("tracing_soul", 1, function(p, _, other)
                    graze_count = graze_count + 1
                    if graze_count == 8 then
                        local yes = (30 + 15 / 66 + baodi) * 30
                        yes = yes / 100
                        local c = ran:Float(0, 1)
                        if c <= yes then
                            baodi = max(-16, baodi - 8)
                            local dmg = player.damage
                            New(lib.class.tracing_soul, other.x, other.y, 9, c * 360, dmg * 0.2, 288)
                            if other.group == GROUP.ENEMY_BULLET then
                                object.Del(other)
                            end
                        else
                            baodi = min(40, baodi + 8)
                        end
                        graze_count = 0
                    end
                end)
            else
                player._playersys:removeGrazingBeforeEvent("tracing_soul")
            end
        end,
        condfunc = nil,
    },
    [40] = {
        name = [[天星之沐愿(绿)]],
        stitle = [[永星祈祷]],
        sdes = [[当/hp等于/maxhp时，
回复/hp时会增加§g其回复量一定比例§d的/maxhp]],
        detail = [[记§ya=1
当/hp等于/maxhp时，
回复/hp时会增加其§g回复量的(20+a*10)%§d的/maxhp
不能再获得/t41、/t42]],
        repeatd = [[§ya§d+1]],
        collabd = nil,
        unlockd = [[/passtime3]],
        condd = nil,
        tags = { tg.life, tg.debuff },
        picID = 33,
        repeatp = 0,
        maxc = 3,
        initialTake = false,
        event = function(d, flag)
            local v = lstg.var
            v.green_wish = v.green_wish + d
            if v.green_wish == 1 and d == 1 then
                lib.AdditionTotalList[41].pro_fixed = 0
                lib.AdditionTotalList[42].pro_fixed = 0
            elseif v.green_wish == 0 and d == -1 then
                lib.AdditionTotalList[41].pro_fixed = 1
                lib.AdditionTotalList[42].pro_fixed = 1
            end
        end,
        condfunc = nil,
    },
    [41] = {
        name = [[天星之沐愿(蓝)]],
        stitle = [[质星祈祷]],
        sdes = [[每次升级§g可选择2次加成§d，§r但选择的选项减少1个
/expR§r下降§d，多次获得后§g上升]],
        detail = [[记§ya=1
每次升级§g可选择2次加成§d，§r但选择的选项减少1个
/expR§r-30%
不能再获得/t40、/t42]],
        repeatd = [[/expR§g+20%]],
        collabd = nil,
        unlockd = [[/passtime4]],
        condd = nil,
        tags = { tg.store, tg.debuff },
        picID = 34,
        repeatp = 0,
        maxc = 3,
        initialTake = false,
        event = function(d, flag)
            local v = lstg.var
            v.blue_wish = v.blue_wish + d
            v.exp_factor = v.exp_factor + 0.2 * d
            if v.blue_wish == 1 and d == 1 then
                v.exp_factor = v.exp_factor - 0.5
                v.level_upOption = v.level_upOption - 1
                lib.AdditionTotalList[40].pro_fixed = 0
                lib.AdditionTotalList[42].pro_fixed = 0
            elseif v.blue_wish == 0 and d == -1 then
                v.exp_factor = v.exp_factor + 0.5
                v.level_upOption = v.level_upOption + 1
                lib.AdditionTotalList[40].pro_fixed = 1
                lib.AdditionTotalList[42].pro_fixed = 1
            end
        end,
        condfunc = nil,
    },
    [42] = {
        name = [[天星之沐愿(红)]],
        stitle = [[灵星祈祷]],
        sdes = [[每次升级时，选取§y/atk|/ss|/bv|/br§d中随机一项
§g提高一定数值，该效果每次升级执行§y2§d次]],
        detail = [[记§ya=1§d
每次升级时，将§y/atk|/ss|/bv|/br§d从小到大排序
分别有§g40%§d,§g30%§d,§g20%§d,§g10%§d的概率得到数值提升
数值为§g0.5+a*0.5
该效果每次升级执行§y2§d次
不能再获得/t40、/t41]],
        repeatd = [[a+1]],
        collabd = nil,
        unlockd = [[/passtime5]],
        condd = nil,
        tags = tg.debuff,
        picID = 35,
        repeatp = 0,
        maxc = 3,
        initialTake = false,
        event = function(d, flag)
            local v = lstg.var
            v.red_wish = v.red_wish + d
            if v.red_wish == 1 and d == 1 then
                lib.AdditionTotalList[40].pro_fixed = 0
                lib.AdditionTotalList[41].pro_fixed = 0
            elseif v.red_wish == 0 and d == -1 then
                lib.AdditionTotalList[40].pro_fixed = 1
                lib.AdditionTotalList[41].pro_fixed = 1
            end
        end,
        condfunc = nil,
    },
    [47] = {
        name = [[妖精联结]],
        stitle = [[命之纽带]],
        sdes = [[每当敌人死亡时
对场上所有敌人造成1次§g死亡敌人4%§d/maxhp的伤害]],
        detail = [[/t47sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[累计杀死§p10000§d个敌人]],
        condd = nil,
        tags = tg.store,
        picID = 40,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            if flag then
                lstg.tmpvar.enemy_contact_ef = New(lib.class2.enemy_contact_ef)
                player._playersys:addEnemyKillEvent("enemy_contact", 1, function(player, _, self)
                    object.EnemyNontjtDo(function(e)
                        if e.class.base.take_damage then
                            e.class.base.take_damage(e, self.maxhp * 0.04)
                        end
                    end)
                end)
            else
                if IsValid(lstg.tmpvar.enemy_contact_ef) then
                    Del(lstg.tmpvar.enemy_contact_ef)
                end
                player._playersys:removeEnemyKillEvent("enemy_contact")
            end
        end,
        condfunc = nil,
    },
    [51] = {
        name = [[光之屏障]],
        stitle = [[叹息之墙]],
        sdes = [[生成横跨版面的蓝色屏障
碰到屏障的敌机弹幕§g会被消除§d]],
        detail = [[/t51sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = { tg.defend, tg.store },
        picID = 44,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            if flag then
                lstg.tmpvar.blue_barrier = New(lib.class.blue_barrier)
            else
                if IsValid(lstg.tmpvar.blue_barrier) then
                    Del(lstg.tmpvar.blue_barrier)
                end
            end
        end,
        condfunc = nil,
    },
    [58] = {
        name = [[樱花结界]],
        stitle = [[她将永远守护着你……]],
        sdes = [[获得§y「樱花结界」§d系统
使/season1时长延长§b1§d波]],
        detail = [[获得§y「樱花结界」§d系统
§y「樱花结界」§d：
攻击敌人时增加樱点，高速状态增加更多
樱点数量显示于右处，装满进度条即会自动开启樱花结界
开启结界时，恢复§g10§d/hp，结界持续一段时间，§g擦弹获得大量分数
结界<被弹结束/主动结束>时：§g全屏消弹
结界<时间耗尽>时：§g奖励一定分数
开启结界时按释放符卡键§g可以主动结束
使/season1时长延长§b1§d波]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[遇见一次/w69天气]],
        condd = nil,
        tags = nil,
        picID = 51,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            if flag then
                if lstg.var._season_system then
                    local w = lstg.weather
                    w.season_last[1] = w.season_last[1] + 1
                end
                lib.sakura_kekkai_init()
            else
                if lstg.var._season_system then
                    local w = lstg.weather
                    w.season_last[1] = w.season_last[1] - 1
                end
                lib.sakura_kekkai_fade()
            end
        end,
        condfunc = nil,
    },
    [64] = {
        name = [[贪欲的敛财]],
        stitle = [[我全都要！]],
        sdes = [[§g/player吸引场上的所有经验点
每级升级所需经验§g降低7级]],
        detail = [[/t64sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[/passtime6]],
        condd = nil,
        tags = tg.store,
        picID = 57,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local var = lstg.var
            var.greedy_exp = flag
            var.level_offset = var.level_offset - 7 * d
            AddExp(0)
        end,
        condfunc = nil,
    },
    [86] = {
        name = [[阴晴圆缺]],
        stitle = [[永远的满月]],
        sdes = [[/player对任何类型的伤害都§g减免1.00
/player对任何类型的伤害都§g减免50%]],
        detail = [[/t86sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[击败1次/bossJunko]],
        condd = nil,
        tags = tg.defend,
        picID = 75,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.var.dmg_reduction = flag
        end,
        condfunc = nil,
    },
    [90] = {
        name = [[甘美之毒]],
        stitle = [[甜蜜的痛苦]],
        sdes = [[/ss§g+0.7§d，每当/pbullet击中敌人时，施加§g1§d层§y「甘毒」
§y「甘毒」§d：攻击时，额外对敌人造成§g0.12§d点伤害]],
        detail = [[/t90sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[击败1次/bossMedicine]],
        condd = nil,
        tags = nil,
        picID = 79,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local ss = player.shoot_set.speed
            ss.offset = ss.offset + 0.7 * d
            lstg.var.posion_dot = flag
        end,
        condfunc = nil,
    },
    [115] = {
        name = [[护守之莲]],
        stitle = [[以爱濡养]],
        sdes = [[每有§b90§d颗弹幕被消除时，获得§g60帧§d/inv时间
同时/player周围将展开一定大小的消弹圈]],
        detail = [[当有§b90§d颗弹幕被消除时，获得§y「护莲」
§y「护莲」§d：使/player获得最高§g60帧§d的/inv时间
同时§g展开一定大小的消弹圈
可储存最多§b90§d颗消除的弹幕，以获得下次§y「护莲」§d。
§c消除激光也能计入一定数量的弹幕数。]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[通关/scenep1的§bNormal§d难度]],
        condd = nil,
        tags = { tg.defend, tg.store },
        picID = 104,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local var = lstg.var
            var.protect_lotus = flag
            if flag then
                lstg.tmpvar.protect_lotus = New(lib.class2.protect_lotus)
            else
                var.lotus_record_b = 0
                var.lotus_count = 0
                if IsValid(lstg.tmpvar.protect_lotus) then
                    Del(lstg.tmpvar.protect_lotus)
                end
            end
        end,
        condfunc = nil,
    },
    [132] = {
        name = [[怪力乱神]],
        stitle = [[鬼气狂澜]],
        sdes = [[/atk§g+1
/atkR§g+67%]],
        detail = [[/t132sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[/passtime2]],
        condd = nil,
        tags = nil,
        picID = 121,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local p = player
            p.dmg_offset = p.dmg_offset + 1 * d
            p.dmg_fixed = p.dmg_fixed + 0.67 * d
        end,
        condfunc = nil,
    },
    [133] = {
        name = [[封之术法]],
        stitle = [[八岳之力]],
        sdes = [[每波第1次被弹§g不计伤害
且该弹型在本波中不再出现§-(区分颜色)]],
        detail = [[/t133sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[通过/scenep1与/scenep2的§yExtra§d难度]],
        condd = nil,
        tags = tg.defend,
        picID = 122,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.var.cyoltose = flag
            local tvar = lstg.tmpvar
            tvar.cyoltose_style = nil
            tvar.cyoltose_color = nil
            if flag then
                AddWaveEvent("resetCyoltose_Get", 1, function()
                    tvar.cyoltose_style = nil
                    tvar.cyoltose_color = nil
                end)
            else
                RemoveWaveEvent("resetCyoltose_Get")
            end
        end,
        condfunc = nil,
    },
    [162] = {
        name = [[死亡十字]],
        stitle = [[核聚变]],
        sdes = [[击破敌人时，有概率在敌人位置出现1条§y十字激光
激光对敌人每帧造成§g2%/atk§d伤害]],
        detail = [[记§yb=1§d
击破敌人时，有§g10%§d概率在敌人位置出现1条十字激光
激光对敌人每帧造成§g2%/atk§d伤害，持续§b38~66b帧]],
        repeatd = [[b+1]],
        collabd = nil,
        unlockd = [[通关/scenep2的§bNormal§d难度]],
        condd = nil,
        tags = tg.store,
        picID = 151,
        repeatp = 0,
        maxc = 2,
        initialTake = false,
        event = function(d, flag)
            local v = lstg.var
            v.cross_laser = v.cross_laser + d
            if flag and d == 1 then
                player._playersys:addEnemyKillEvent("cross_laser", 1, function(player, _, self)
                    if ran:Float(0, 1) < 0.1 then
                        local t = ran:Int(38, 66)
                        for a in sp.math.AngleIterator(0, 4) do
                            New(stg_levelUPlib.class4.cross_laser, self.x, self.y, a, v.cross_laser * t)
                        end
                    end
                end)
            elseif not flag and d == -1 then
                player._playersys:removeEnemyKillEvent("cross_laser")
            end
        end,
        condfunc = nil,
    },
    [183] = {
        name = [[小槌的魔力]],
        stitle = [[财富的象征]],
        sdes = [[获得所有已获得但未满级的道具各§y1§d个
之后获得道具时也会触发此效果]],
        detail = [[/t183sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[通关/scenep3的§bNormal§d难度]],
        condd = nil,
        tags = nil,
        picID = 198,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag, otherflag)
            local v = lstg.var
            if flag and not otherflag then
                local can_get = {}
                for i, nowc in pairs(v.addition) do
                    local p = lib.AdditionTotalList[i]
                    if p.isTool then
                        local maxc = p.maxcount or 999
                        if p.upgrade_get() and (nowc < maxc) then
                            table.insert(can_get, p)
                            p:Set(true)
                        end
                    end
                end
                if #can_get > 0 then
                    ext.popup_menu:FlyIn(i18n("addition_des", 5)[183].name .. "!", 189, 252, 201, can_get, "bonus")
                end
            end
            v.copy_center = flag
        end,
        condfunc = nil,
    },
    [201] = {
        name = [[绮罗大结界]],
        stitle = [[花火]],
        sdes = [[/pbullet额外附有一种§y随机特效]],
        detail = [[/pbullet会随机额外附有一种以下道具的效果：
/t88, /t158, /t153, /t142
/t186
/t71, /t152, /t122
/t184, /t77, /t72
/t93, /t185, /t105
/t131, /t129, /t130
/t197, /t111]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[通过/scenep3的§yExtra§d难度]],
        condd = nil,
        tags = nil,
        picID = 167,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local v = lstg.var
            v.damask_effect = flag
        end,
        condfunc = nil,
    },
    [203] = {
        name = [[朱莉安娜羽扇]],
        stitle = [[不可抗拒的富贵]],
        sdes = [[增加§g1§d个/activestk，/active的充能效率翻倍
增加§g1§d个/spellstk]],
        detail = [[增加§g1§d个/activestk，
/active的充能效率§g+100%
增加§g1§d个/spellstk]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[携带任意/active通关/scenep1]],
        condd = nil,
        tags = tg.active,
        picID = 203,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local v = lstg.var
            v.max_active_item = v.max_active_item + d
            v.active_charge_efficiency = v.active_charge_efficiency + d
            player_lib.SetEnergy(nil, v.energy_stack + 1 * d)
        end,
        condfunc = AfterActive,
    },
}