local lib = stg_levelUPlib
local AddWaveEvent = lib.AddWaveEvent
local RemoveWaveEvent = lib.RemoveWaveEvent

local tg = stg_levelUPlib.tagslist

local function AfterActive()
    return scoredata.StartActive
end

return {
    [28] = {
        name = [[历经伤痛之心]],
        stitle = [[碎心难圆]],
        sdes = [[/player被弹（包括体术）时无论如何都是§b扣除33%的/maxhp]],
        detail = [[/t28sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[暴力退出过§p1§d次游戏]],
        condd = nil,
        tags = { tg.defend, tg.debuff },
        picID = 25,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            local v = lstg.var
            v.forever33 = flag
        end,
        condfunc = nil,
    },
    [36] = {
        name = [[灵体外质]],
        stitle = [[纯粹的游戏]],
        sdes = [[将符卡改为§p一段时间的/inv§d，且§r无法射击]],
        detail = [[记§ya=1§d, §yb=原符卡给予的/inv时间
将符卡的效果§r取消§d，改为获得§pb*(1.6+0.4*a)秒§d的/inv
释放符卡时，§r不能射击§d，/spdR§g+50%]],
        repeatd = [[§ya§d+1]],
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = { tg.defend, tg.debuff },
        picID = 29,
        repeatp = 0,
        maxc = 2,
        initialTake = false,
        event = function(d, flag)
            if flag then
                if not lstg.tmpvar.bomb_to_protect then
                    lstg.tmpvar.bomb_to_protect = { count = 1 }
                else
                    local bomb_to_protect = lstg.tmpvar.bomb_to_protect
                    bomb_to_protect.count = bomb_to_protect.count + 1
                end
            else
                local bomb_to_protect = lstg.tmpvar.bomb_to_protect
                bomb_to_protect.count = bomb_to_protect.count - 1
                if bomb_to_protect.count == 0 then
                    lstg.tmpvar.bomb_to_protect = nil
                end
            end
        end,
        condfunc = nil,
    },
    [39] = {
        name = [[疏与密的境界]],
        stitle = [[心体合一]],
        sdes = [[擦弹范围修改至/hitb的§b36.9§d倍
且/hitb§r+0.5§d，/hitbR§r+100%§d]],
        detail = [[/t39sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[改变过§p1§d次/hitb]],
        condd = nil,
        tags = { tg.store, tg.debuff },
        picID = 32,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            local p = player
            player_lib.AddPlayerCollisize(0.5 * d, nil, 1 * d)
            if flag then
                p._playersys:addFrameBeforeEvent("refresh_grazer_colli", 1, function(self)
                    self.grazer_colli = self.A * 36.9
                end)
            else
                p._playersys:removeFrameBeforeEvent("refresh_grazer_colli")
                p.grazer_colli = 24
            end
        end,
        condfunc = nil,
    },
    [43] = {
        name = [[反馈调节机]],
        stitle = [[奇变偶也变]],
        sdes = [[波数为偶数时/chaos每秒§g-0.1%§d，
为奇数时每秒§b+0.1%§d]],
        detail = [[/t43sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = { tg.chaos, tg.debuff },
        picID = 36,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            if flag then
                player._playersys:addFrameBeforeEvent("chaosadjuster", 1, function()

                    local v = lstg.var
                    if v.frame_counting then
                        if v.wave % 2 == 0 then
                            player_lib.AddChaos(-0.1 / 60)
                        else
                            player_lib.AddChaos(0.1 / 60)
                        end
                    end
                end)
            else
                player._playersys:removeFrameBeforeEvent("chaosadjuster")
            end
        end,
        condfunc = nil,
    },
    [46] = {
        name = [[行稳致远]],
        stitle = [[千里之行]],
        sdes = [[/hspd§b+0.2§d，/lspd§b+0.2§d
/spd将不会低于拾取此/item后的面板数值]],
        detail = [[/t46sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = { tg.store, tg.debuff },
        picID = 39,
        repeatp = 0,
        maxc = 3,
        initialTake = true,
        event = function(d, flag)
            local p = player
            p.hspeed_offset = p.hspeed_offset + 0.2 * d
            p.lspeed_offset = p.lspeed_offset + 0.2 * d
            local v = lstg.var
            v.stable_hspeed, v.stable_lspeed = p.cur_hspd, p.cur_lspd
        end,
        condfunc = nil,
    },
    [48] = {
        name = [[Blood Magic]],
        stitle = [[喋血反击!]],
        sdes = [[敌怪死亡时，会向/player§r发射子弹]],
        detail = [[敌怪死亡时，发射1条§r3颗§d的/aimplayer弹链]],
        repeatd = nil,
        collabd = [[每拥有1个/tgsacrifice标签的/item，
/atk§g+0.25§d，/aimplayer弹链颗数§r+1
/t55：向反方向发射弹链]],
        unlockd = [[累计杀死§p1000§d个敌人]],
        condd = nil,
        tags = { tg.sacrifice, tg.debuff },
        picID = 200,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            local v = lstg.var
            v.blood_magic = flag
            if flag then
                player._playersys:addEnemyKillEvent("blood_magic", 1, function(player, _, self)
                    local x, y = self.x, self.y
                    New(tasker, function()
                        local count = 3
                        for _, p in ipairs(lib.ListByTags.sacrifice) do
                            if v.addition[p.id] then
                                count = count + v.addition[p.id]
                            end
                        end
                        local ROT = 0
                        if v.addition[55] then
                            ROT = 180
                        end
                        for _ = 1, count do
                            NewSimpleBullet(grain_c, 2, x, y, min(1.8 + v.chaos / 40, 6), Angle(x, y, player) + ROT)
                            task.Wait(4)
                        end
                    end)
                end)
            else
                player._playersys:removeEnemyKillEvent("blood_magic")
            end
        end,
        condfunc = nil,
    },
    [54] = {
        name = [[便携式隙间]],
        stitle = [[小小贤者的力量]],
        sdes = [[屏幕两端出现隙间，能够传送/player，敌人，子弹等
敌人进入隙间后，对其造成§g350%/atk§d的伤害]],
        detail = [[/t54sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[击败1次/bossYukari]],
        condd = nil,
        tags = tg.debuff,
        picID = 47,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            local p = player
            if flag then
                lstg.tmpvar.yukariTool1 = New(lib.class.YukariTool, -310, player.y, 90)
                lstg.tmpvar.yukariTool2 = New(lib.class.YukariTool, 310, player.y, 90)
                local t1, t2 = lstg.tmpvar.yukariTool1, lstg.tmpvar.yukariTool2
                t1.vscale = -1
                t1.opposite = t2
                t2.opposite = t1
                p._playersys:addFrameBeforeEvent("refreshYukariTool", 1, function()
                    t1.y = t1.y + (-t1.y + player.y) * 0.1
                    t2.y = t1.y
                end)
            else
                if IsValid(lstg.tmpvar.yukariTool1) then
                    Del(lstg.tmpvar.yukariTool1)
                end
                if IsValid(lstg.tmpvar.yukariTool2) then
                    Del(lstg.tmpvar.yukariTool2)
                end
                p._playersys:removeFrameBeforeEvent("refreshYukariTool")
            end
        end,
        condfunc = nil,
    },
    [56] = {
        name = [[天地有用]],
        stitle = [[转逆]],
        sdes = [[/atkR§g+50%§d，/pbullet将§r朝后发射
使/w34天气无效化]],
        detail = [[/t56sdes]],
        repeatd = nil,
        collabd = [[/t7：飞刀将从上往下发射
/t24：改为在/player头顶生成/minion
/t29：激光将向下发射
/t59：改为在/player前方生成门扉
/t92：雪花将从下往上飘“落”
/t92+/t70：雪花出现时就会融化
/t124：低速时，波纹弹将向下发射
/t123：针弹将向下发射
/t99：移动时，将同向发射火焰弹
/t101：七色珠一开始将向上发射
/t159：改为在/player下方生成伞
/t189：改为从板顶向下发射主炮
]],
        unlockd = [[见过一次/w34天气]],
        condd = nil,
        tags = { tg.debuff },
        picID = 49,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local p = player
            p.dmg_fixed = p.dmg_fixed + 0.5 * d
            lstg.var.reverse_shoot = flag
        end,
        condfunc = nil,
    },
    [83] = {
        name = [[偷天换日]],
        stitle = [[……]],
        sdes = [[选择的/item有§b20%§d概率§r随机变成其他/item]],
        detail = [[/t83sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = { tg.store, tg.debuff },
        picID = 72,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local v = lstg.var
            v.steal_sun = flag
        end,
        condfunc = nil,
    },
    [88] = {
        name = [[运动学定律]],
        stitle = [[玩转偏向力]],
        sdes = [[/bv§g+0.3
/pbullet获得等同于/player/spd的方向与大小的速度向量]],
        detail = [[/t88sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = { tg.debuff },
        picID = 77,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            local v = lstg.var
            v.kinematics = flag
            local ssb = player.shoot_set.bvelocity
            ssb.offset = ssb.offset + 0.3 * d
        end,
        condfunc = nil,
    },
    [98] = {
        name = [[可持续发展]],
        stitle = [[回收旧手机，旧电脑......]],
        sdes = [[每波开始时，获得一个/benefit、/trade或/infringe]],
        detail = [[/t98sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        other = "可持续发展!!",
        tags = { tg.debuff },
        picID = 87,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            if flag then
                AddWaveEvent("recycleAddition", 1, function()
                    local t = ran:Float(0, 1)
                    local pos = 1
                    if t < 0.3 then
                        pos = 1
                    elseif t < 0.7 then
                        pos = 2
                    else
                        pos = 3
                    end
                    local k = lib.ListByState[pos][ran:Int(1, #lib.ListByState[pos])]
                    k:Set(true)
                    ext.notice_menu:AdditionAdd(k.id, "pin00", i18n("addition_des", 1)[98].other, 25)
                end)
            else
                RemoveWaveEvent("recycleAddition")
            end
        end,
        condfunc = nil,
    },
    [102] = {
        name = [[秘神的指引]],
        stitle = [[里世界直通车]],
        sdes = [[下次更换季节时，一定会变成/season5
生效一次后§-损坏]],
        detail = [[/t102sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = [[遇到过一次/season5季节]],
        condd = [[存在§p/wxsys]],
        tags = { tg.debuff },
        picID = 91,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.weather.MustSeason5 = flag
        end,
        condfunc = function()
            return lstg.var._season_system
        end,
    },
    [107] = {
        name = [[血色阴阳玉]],
        stitle = [[它渴望鲜血]],
        sdes = [[恢复§g10§d/hp
按下x键(Bomb键)时会§b瞬移到离/player最近的敌人处]],
        detail = [[恢复§g10§d/hp
按下x键(Bomb键)时会获得§b9帧§d/inv，并§b瞬移到离/player最近的敌人处
冷却时间§b12帧]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = { tg.debuff },
        picID = 96,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            if flag then
                player_lib.AddLife(10)
                if not IsValid(lstg.tmpvar.TPyyy) then
                    lstg.tmpvar.TPyyy = New(lib.class2.TPyyy)
                end
            else
                if IsValid(lstg.tmpvar.TPyyy) then
                    Del(lstg.tmpvar.TPyyy)
                end
            end
        end,
        condfunc = nil,
    },
    [134] = {
        name = [[分子重组仪]],
        stitle = [[世界崩坏]],
        sdes = [[§g获得§d\§-损坏§d\§r失去§d该/item后，除了该/item以外
§b依次将所有/item§-(/tempitem除外)§d替换成其他随机/item]],
        detail = [[/t134sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        other = { "获得道具", "失去道具" },
        tags = { tg.debuff },
        picID = 123,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag, otherflag)
            if not otherflag then
                local lost = {}
                local get = {}
                local addition = sp:CopyTable(lstg.var.addition)
                for i, c in pairs(addition) do
                    local l = lib.AdditionTotalList[i]
                    if i ~= 134 and l.isTool and not l.temporary then
                        for _ = 1, c do
                            l:Remove()
                            table.insert(lost, l)
                            local g = lib.GetAdditionList(1, function(p)
                                return p.isTool and p.id ~= i and p.id ~= 134
                            end)
                            if #g > 0 then
                                g[1]:Set(true)
                                table.insert(get, g[1])
                            end
                        end
                    end
                end
                if #get > 0 then
                    ext.popup_menu:FlyIn(i18n("addition_des", 1)[134].other[1], 255, 227, 132, get, "bonus")
                end
                if #lost > 0 then
                    ext.popup_menu:FlyIn(i18n("addition_des", 1)[134].other[2], 250, 128, 114, lost, "invalid")
                end
            end
        end,
        condfunc = nil,
    },
    [136] = {
        name = [[无间之钟]],
        stitle = [[幸福今生]],
        sdes = [[本场游戏中，§g每次升级时额外出现一个选项
结算时若持有该/item，下一局游戏开始时获得道具/t137]],
        detail = [[/t136sdes]],
        repeatd = nil,
        collabd = [[/t137：
/t137detail]],
        unlockd = nil,
        condd = [[不会在/challmode中出现]],
        tags = { tg.debuff },
        picID = 125,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.var.level_upOption = lstg.var.level_upOption + d
        end,
        condfunc = function()
            return not stage.current_stage.is_challenge
        end,
    },
    [137] = {
        name = [[永恒的回音]],
        stitle = [[无间]],
        sdes = [[/chaos§r+25%§d，/expR§g+33%§d，阻止/t136出现
升级时，有§r13%§d概率获得一个/infringe]],
        detail = [[上一局游戏结算时若拥有/t136，该/item便会§r强制初始携带
/chaos§r+25%§d，阻止/t136出现
升级时，有§r13%§d概率获得一个/infringe
/expR§g+33%
仅§r当携带该/item通关§d时，下一局游戏才不再携带该/item]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = [[不自然出现]],
        tags = { tg.debuff },
        picID = 126,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.var.infinite_nightmare = flag
            lstg.var.exp_factor = lstg.var.exp_factor + 0.33 * d
            if flag then
                lib.AdditionTotalList[136].pro_fixed = 0
                player_lib.AddChaos(25)
            else
                lib.AdditionTotalList[136].pro_fixed = 1
            end
        end,
        condfunc = function()
            return false
        end,
    },
    [142] = {
        name = [[MAX M]],
        stitle = [[物极必反]],
        sdes = [[/player移速§r-0.25§d，/pbullet、掉落物等获得向/player方向的加速度
每§b12帧§d对靠近的敌人造成一定伤害]],
        detail = [[/t142sdes]],
        repeatd = nil,
        collabd = [[/t116：引力变大，其造成的伤害翻倍]],
        unlockd = nil,
        condd = nil,
        tags = { tg.debuff },
        picID = 131,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            lstg.var.MAX_M = flag
            local p = player
            p.hspeed_offset = p.hspeed_offset - 0.25 * d
            p.lspeed_offset = p.lspeed_offset - 0.25 * d
            if flag then
                lstg.tmpvar.MAX_M = New(lib.class3.maxm)
            else
                if IsValid(lstg.tmpvar.MAX_M) then
                    Del(lstg.tmpvar.MAX_M)
                end
            end
        end,
        condfunc = nil,
    },
    [143] = {
        name = [[幽灵沙包]],
        stitle = [[Friends to The End]],
        sdes = [[获得一个红色幽灵追随于/player
§r拥有体术伤害§d，§b阻挡敌我双方子弹]],
        detail = [[获得一个红色幽灵追随于/player
初始生成时不拥有体术伤害，
当幽灵与/player分离时§r拥有体术伤害§d，§b且阻挡敌我双方子弹
若/player为§c/playerYoumu§d，则会发射伤害固定为§g1.0§d的小子弹]],
        repeatd = nil,
        collabd = [[/t17：幽灵不拥有伤害，且不阻挡任何子弹]],
        unlockd = nil,
        condd = nil,
        tags = { tg.defend, tg.baby, tg.debuff },
        picID = 132,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            if flag then
                lstg.tmpvar.soul_baby = lstg.tmpvar.soul_baby or {}
                table.insert(lstg.tmpvar.soul_baby, New(lib.class4.soul_baby))

            else
                if lstg.tmpvar.soul_baby then
                    if IsValid(lstg.tmpvar.soul_baby[1]) then
                        Del(lstg.tmpvar.soul_baby[1])
                        table.remove(lstg.tmpvar.soul_baby, 1)
                    end
                end
            end
        end,
        condfunc = nil,
    },
    [151] = {
        name = [[休止符]],
        stitle = [[本是同根生，就是要相煎]],
        sdes = [[阻止所有§-0级/item§d出现]],
        detail = [[/t151sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = { tg.debuff },
        picID = 140,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.var.stop_0_tool = flag
        end,
        condfunc = nil,
    },
    [153] = {
        name = [[小小星球]],
        stitle = [[除夕快乐给大家送一个大回环]],
        sdes = [[/br§g+7§d,/brR§g+177%
/pbullet会§b不断旋转]],
        detail = [[/t153sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = { tg.debuff },
        picID = 142,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            local ss = player.shoot_set.range
            ss.offset = ss.offset + 7 * d
            ss.fixed = ss.fixed + 1.77 * d
            lstg.var.rotate_star = flag
        end,
        condfunc = nil,
    },
    [158] = {
        name = [[符札化络合物]],
        stitle = [[结构式错误]],
        sdes = [[/pbullet变为§y特殊/pbullet
§-*该/pbullet能获得意义不明的特性*]],
        detail = [[/pbullet随机获得以下§b1~2§d种特性：
大小§b*50%~250%
伤害§b*10%~300%
/bv§b*-25%~160%
/br§b*50%~1000%
颜色§b随机]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = { tg.debuff },
        picID = 147,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.var.nue_main_bullet = flag
        end,
        condfunc = nil,
    },
    [200] = {
        name = [[崩溃市场]],
        stitle = [[获利还是吃亏？]],
        sdes = [[每波开始时/expR会变为上一波的§p20%~200%§d倍]],
        detail = [[/t200sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = { tg.debuff },
        picID = 193,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            if flag then
                AddWaveEvent("economy_crash", 1, function()
                    local v = lstg.var
                    local base = 2 / 0.2
                    local c = 0.2 * (base ^ ran:Float(0, 1))
                    v.exp_factor = v.exp_factor * c
                end)
            else
                RemoveWaveEvent("economy_crash")
            end
        end,
        condfunc = nil,
    },
    [206] = {
        name = [[麻木]],
        stitle = [[俺寻思不疼]],
        sdes = [[/hp§r不再可见§d，
受伤时扣除的/hp§g降低25%§d，增加的/chaos§g降低30%]],
        detail = [[/t206sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = { tg.debuff, tg.defend },
        picID = 216,
        repeatp = 0,
        maxc = 1,
        initialTake = false,
        event = function(d, flag)
            lstg.var.paralyzed = flag
        end,
        condfunc = nil,
    },
    [208] = {
        name = [[逢魔之刻]],
        stitle = [[黑化]],
        sdes = [[每秒，/chaos§r+0.05%§d
/hp§g+0.1§d，/atk§g+0.01§d]],
        detail = [[/t208sdes]],
        repeatd = nil,
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = { tg.chaos, tg.debuff },
        picID = 209,
        repeatp = 0,
        maxc = 1,
        initialTake = true,
        event = function(d, flag)
            if flag then
                player._playersys:addFrameBeforeEvent("fengmo", 1, function()
                    local v = lstg.var
                    if v.frame_counting then
                        player_lib.AddChaos(0.05 / 60)
                        player_lib.AddMaxLife(0.1 / 60)
                        player.dmg_offset = player.dmg_offset + (0.01 / 60)
                    end
                end)
            else
                player._playersys:removeFrameBeforeEvent("fengmo")
            end
        end,
        condfunc = nil,
    },

}