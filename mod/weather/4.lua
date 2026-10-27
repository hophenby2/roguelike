local lib = weather_lib

local first10pro = function()
    if lstg.var._pathlike then
        return 1
    else
        if lstg.weather.season_wave == 1 then
            return 10
        else
            return 0
        end

    end
end
local middle10pro = function()
    if lstg.var._pathlike then
        return 1
    else
        local w = lstg.weather
        if w.season_wave == (w.season_last[w.now_season] + 1) / 2 then
            return 10
        else
            return 0
        end
    end
end

return {
    [22] = {
        name = [[立冬]],
        switchname = [[LiDong]],
        stitle = [[万物休养程度的天气]],
        des = [[恢复/hp时，将其转化为§r12%§d的/maxhp
敌人/spd§b-50%]],
        spdes = [[有且仅有§b10§d倍权重在/season4的第一波出现]],
        state = 1,
        init = function()
            if lstg.var.frame_counting then
                object.EnemyNontjtDo(function(e)
                    sp:UnitSetVIndex(e, -0.5)
                end)
            end
        end,
        frame = function()
            if lstg.var.frame_counting then
                object.EnemyNontjtDo(function(e)
                    sp:UnitSetVIndex(e, -0.5)
                end)
            end
        end,
        final = nil,
        pro = first10pro,
    },
    [23] = {
        name = [[小雪]],
        switchname = [[XiaoXue]],
        stitle = [[冷涩凝绝程度的天气]],
        des = [[弹幕每§b10帧§d有§b2%§d的概率停顿在原地，Wave结束时被清除
敌人/spd§b-25%]],
        spdes = nil,
        state = 3,
        init = function()
            local w = lstg.weather
            w.bullet_init_func = function(self)
                task.New(self, function()
                    while w.XiaoXue do
                        task.Wait(10)
                        if ran:Float(0, 1) < 0.02 and w.XiaoXue and self.group == GROUP.ENEMY_BULLET then
                            self._frozen = true
                            self.xiaoxue_frozen = true
                            task.Clear(self, true)
                            break
                        end
                    end
                    task.Wait()
                    if self.xiaoxue_frozen and w.XiaoXue then
                        object.StopMoving(self)
                    end
                end)
            end
        end,
        frame = function()
            if lstg.var.frame_counting then
                object.EnemyNontjtDo(function(e)
                    sp:UnitSetVIndex(e, -0.25)
                end)
            end
        end,
        final = function()
            object.BulletIndesDo(function(b)
                if b.xiaoxue_frozen then
                    Del(b)
                end
            end)
        end,
        pro = 1,
    },
    [24] = {
        name = [[大雪]],
        switchname = [[DaXue]],
        stitle = [[凛冬将至程度的天气]],
        des = [[屏幕上方将§r不断飞落点弹
除点弹外的弹幕消失时将爆出§r1~3§d颗拥有重力的点弹
敌人/spd§b-33%]],
        spdes = nil,
        state = 3,
        init = nil,
        frame = function()
            if lstg.var.frame_counting then
                object.EnemyNontjtDo(function(e)
                    sp:UnitSetVIndex(e, -0.33)
                end)
                local t = stage.current_stage.timer
                local chaos = lstg.var.chaos
                local interval = int(max(12 - chaos / 100, 1))
                local v = min(chaos / 120 + 1.5, 8)
                if t % interval == 0 then
                    NewSimpleBullet(ball_small, 8, ran:Float(-320, 320), 245,
                            ran:Float(v - 0.3, v + 0.3), -90 + ran:Float(-6, 6))
                end
            end
        end,
        final = nil,
        pro = 1,
    },
    [25] = {
        name = [[冬至]],
        switchname = [[DongZhi]],
        stitle = [[万物清平程度的天气]],
        des = [[Wave开始时§g升1级
所有类型的弹幕§g一出现就会消失]],
        spdes = [[有且仅有§b10§d倍权重在/season4的最中间一波出现]],
        state = 1,
        init = function()
            local v = lstg.var
            if v.scene_id == 3 then
                mission_lib.GoMission(139)
            end
            AddExp((stg_levelUPlib.GetCurMaxEXP() - v.now_exp + 1) / player_lib.GetEXPfactor())
            if not IsValid(lstg.tmpvar.DongZhiEff) then
                lstg.tmpvar.DongZhiEff = New(lib.class.DongZhiEff)
            end
        end,
        frame = function()
            if lstg.var.frame_counting then
                object.BulletIndesDo(function(b)
                    object.Del(b)
                end)
            end
        end,
        final = nil,
        pro = middle10pro,
    },
    [26] = {
        name = [[小寒]],
        switchname = [[XiaoHan]],
        stitle = [[迷雾冰滑程度的天气]],
        des = [[在屏幕上不断§r生成一片迷雾区域
在迷雾区域内，/player/spd§r-40%§d，敌人和弹幕/spd§r-60%]],
        spdes = nil,
        state = 3,
        init = nil,
        frame = function()
            if lstg.var.frame_counting then
                local t = stage.current_stage.timer
                if t % 15 == 0 then
                    New(lib.class.XiaoHanFog, ran:Float(-300, 300), ran:Float(-200, 200), 0.6, ran:Float(0, 360))
                end
                object.EnemyNontjtDo(function(e)
                    e._xiaohan_slowed = nil
                end)
                object.BulletIndesDo(function(e)
                    e._xiaohan_slowed = nil
                end)
                player._xiaohan_slowed = nil
            end
        end,
        final = nil,
        pro = 1,
    },
    [36] = {
        name = [[瑞雪]],
        switchname = [[RuiXue]],
        stitle = [[祥瑞美满程度的天气]],
        des = [[屏幕上方§y不断飘落/expp
升级时出现3&4级道具的概率§y大大提升]],
        spdes = nil,
        state = 1,
        init = nil,
        frame = function()
            if lstg.var.frame_counting then
                local t = stage.current_stage.timer
                if t % 8 == 0 then
                    item.dropItem(item.drop_exp, 1, ran:Float(-320, 320), 245)
                end
            end
        end,
        final = nil,
        pro = 1,
    },
    [37] = {
        name = [[钻石尘]],
        switchname = [[ZuanShiChen]],
        stitle = [[受击既死程度的天气]],
        des = [[进入此天气时记录一次当前的/hp
被弹&体术时§r扣除等同于记录值的/hp]],
        spdes = nil,
        state = 3,
        init = function()
            local w = lstg.weather
            w.ZuanShiChen_GetLife = lstg.var.lifeleft
            if not IsValid(lstg.tmpvar.ZuanShiChenEff) then
                lstg.tmpvar.ZuanShiChenEff = New(lib.class.ZuanShiChenEff)
            end
        end,
        frame = nil,
        final = nil,
        pro = 1,
    },
    [46] = {
        name = [[冻雨]],
        switchname = [[DongYu]],
        stitle = [[碎碎冰程度的天气]],
        des = [[敌人/maxhp§g-25%
敌人死亡时§r向/player发射弹链]],
        spdes = nil,
        state = 3,
        init = function()
            if not IsValid(lstg.tmpvar.DongYuEff) then
                lstg.tmpvar.DongYuEff = New(lib.class.DongYuEff)
            end
            local w = lstg.weather
            w.enemyHP_index = 0.75
            w.enemy_kill_func = function(self)
                local chaos = lstg.var.chaos
                local x, y = self.x, self.y
                local A = Angle(self, player)
                New(tasker, function()
                    for _ = 1, int(min(9, 3 + chaos / 50)) do
                        for a in sp.math.AngleIterator(A, 5) do
                            NewSimpleBullet(ball_mid_c, 8, x, y, min(3 + chaos / 70, 9), a)
                        end
                        task.Wait(3)
                    end
                end)
            end
        end,
        frame = nil,
        final = nil,
        pro = 1,
    },
    [68] = {
        name = [[大寒]],
        switchname = [[DaHan]],
        stitle = [[雨雪霏霏程度的天气]],
        des = [[敌人死亡时§r生成1颗无法被消弹的中玉
中玉将慢慢向着/player方向移动，天气结束后再消除
每当攻击敌人时，有25%概率§r生成1颗点弹
敌人/spd§b-60%]],
        spdes = nil,
        state = 3,
        init = function()
            if not IsValid(lstg.tmpvar.DaHanEff) then
                lstg.tmpvar.DaHanEff = New(lib.class.DaHanEff)
            end
            lstg.weather.enemy_kill_func = function(self)
                local b = NewSimpleBullet(ball_big, 6, self.x, self.y, 0.8, Angle(self, player))
                b.group = GROUP.INDES
                b.dahan_bullet = true
            end
        end,
        frame = function()
            if lstg.var.frame_counting then
                object.EnemyNontjtDo(function(e)
                    sp:UnitSetVIndex(e, -0.6)
                end)
            end
        end,
        final = function()
            object.IndesDo(function(b)
                if b.dahan_bullet then
                    Del(b)
                end
            end)
        end,
        pro = 1,
    },
    [69] = {
        name = [[春雪]],
        switchname = [[ChunXue]],
        stitle = [[异变程度的天气]],
        des = [[/player持续获得/t58
下一个季节一定是/season1]],
        spdes = [[有且仅有§b4§d倍权重在/season4的最后一波出现
拥有/t58§d时权重上升§g4§d倍]],
        state = 1,
        init = function()
            mission_lib.GoMission(47)
            local w = lstg.weather
            w.selected_season[1] = false
            w.next_season = 1
            if not IsValid(lstg.tmpvar.ChunXueEff) then
                lstg.tmpvar.ChunXueEff = New(lib.class.ChunXueEff)
            end
            if not lstg.var.addition[58] then
                stg_levelUPlib.sakura_kekkai_init()
            end
        end,
        frame = function()
            if lstg.var.frame_counting then
                if not lstg.var.ON_sakura then
                    lstg.var.sakura = 50000
                end
            end
        end,
        final = function()
            if not lstg.var.addition[58] then
                stg_levelUPlib.sakura_kekkai_fade()
            end
        end,
        pro = function()
            if lstg.var._pathlike then
                return 1
            else
                local w = lstg.weather
                if w.season_wave == w.season_last[w.now_season] then
                    return lstg.var.addition[58] and 8 or 4
                else
                    return 0
                end
            end
        end,
    },
    [70] = {
        name = [[暴风雪]],
        switchname = [[BaoFengXue]],
        stitle = [[视野受限程度的天气]],
        des = [[屏幕上方不断§r飘落点弹和中玉
除/player周围的区域外，其余区域§r被大片风雪覆盖]],
        spdes = nil,
        state = 3,
        init = function()
            lstg.tmpvar.BaoFengXue_miss = lstg.var.miss
            if not IsValid(lstg.tmpvar.BaoFengXueEff) then
                lstg.tmpvar.BaoFengXueEff = New(lib.class.BaoFengXueEff)
            end
        end,
        frame = function()
            if lstg.var.frame_counting then
                local t = stage.current_stage.timer
                local chaos = lstg.var.chaos
                local interval = int(sp.math.GetNumByInverse(chaos, 1, 30, 10))
                local v = min(chaos / 120 + 1.5, 8)
                if t % interval == 0 then
                    NewSimpleBullet(ball_small, 8, ran:Float(-320, 320), 245,
                            ran:Float(v - 0.3, v + 0.3), -90 + ran:Float(-6, 6))
                    NewSimpleBullet(ball_big, 8, ran:Float(-320, 320), 250,
                            ran:Float(v - 0.3, v + 0.3), -90 + ran:Float(-6, 6))
                end
            end
        end,
        final = function()
            if lstg.var.miss == lstg.tmpvar.BaoFengXue_miss then
                ext.achievement:get(61)
            end
        end,
        pro = 1,
    },
    [71] = {
        name = [[结寒]],
        switchname = [[JieHan]],
        stitle = [[躲避过错程度的天气]],
        des = [[/player有§g50%§d概率闪避被弹&体术伤害
/spd§r-50%]],
        spdes = nil,
        state = 2,
        init = function()
            lstg.weather.playerSpeed_index = 0.5
            if not IsValid(lstg.tmpvar.JieHanEff) then
                lstg.tmpvar.JieHanEff = New(lib.class.JieHanEff)
            end
        end,
        frame = nil,
        final = nil,
        pro = 1,
    },
    [72] = {
        name = [[花云]],
        switchname = [[HuaYun]],
        stitle = [[奇观程度的天气]],
        des = [[/player和敌人周围不断出现/expp，§b60帧§d后消失
出现Boss§y莉莉白§d，击破后掉落一个§g3~4§d级道具]],
        spdes = nil,
        state = 2,
        init = function()
            if not IsValid(lstg.tmpvar.HuaYunEff) then
                lstg.tmpvar.HuaYunEff = New(lib.class.HuaYunEff)
            end
            lib.HuaYunLilyWhite()
        end,
        frame = function()
            if lstg.var.frame_counting then
                local dropEXP = function(e)
                    if e.timer % 30 == 0 then
                        local x = e.x + ran:Float(30, 40) * ran:Sign()
                        local y = e.y + ran:Float(30, 40) * ran:Sign()
                        local b = New(item.drop_exp, x, y)
                        b.can_collect_online = false
                        task.New(b, function()
                            task.Wait(60)
                            New(bubble3, b.img, b.x, b.y, b.rot, b.dx, b.dy, b.omega, 8, b.hscale, b.hscale,
                                    Color(b._a, b._r, b._g, b._b), Color(0, b._r, b._g, b._b), b.layer, b._blend)
                            Del(b)
                        end)
                    end
                end
                object.EnemyNontjtDo(dropEXP)
                dropEXP(player)
            end
        end,
        final = nil,
        pro = 1,
    },
    [73] = {
        name = [[霜华]],
        switchname = [[ShuangHua]],
        stitle = [[满天寒霜程度的天气]],
        des = [[/player擦弹时，在弹幕处有§r40%§d概率生成1块冰块
在冰块内/player/spd为§r0
冰块持续§b60帧§d，同屏最多存在§b100§d个冰块
冰块融化后变为§r0~1§d颗点弹，
并有§g30%§d概率掉落§g1§d颗/expp]],
        spdes = nil,
        state = 3,
        init = function()
            if not IsValid(lstg.tmpvar.ShuangHuaEff) then
                lstg.tmpvar.ShuangHuaEff = New(lib.class.ShuangHuaEff)
            end
            player._playersys:addGrazingBeforeEvent("ShuangHua", 1, function(p, _, other)
                if ran:Float(0, 1) < 0.4 then
                    New(lib.class.ice, other.x, other.y, 60)
                end
            end)
        end,
        frame = nil,
        final = function()
            player._playersys:removeGrazingBeforeEvent("ShuangHua")
        end,
        pro = 1,
    },
    [74] = {
        name = [[冰云]],
        switchname = [[BingYun]],
        stitle = [[结冰程度的天气]],
        des = [[主炮子弹每帧有§r0.1%§d的概率被冻结成冰块
在冰块内/player/spd为§r0
冰块持续§b60帧§d，同屏最多存在§b100§d个冰块
冰块融化后变为§r0~1§d颗点弹，
并有§g30%§d概率掉落§g1§d颗/expp]],
        spdes = nil,
        state = 3,
        init = function()
            if not IsValid(lstg.tmpvar.BingYunEff) then
                lstg.tmpvar.BingYunEff = New(lib.class.BingYunEff)
            end
        end,
        frame = nil,
        final = nil,
        pro = 1,
    },
}