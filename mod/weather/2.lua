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

local function TaiFengInit()
    lstg.tmpvar.TaiFeng_miss = lstg.var.miss
    local w = lstg.weather
    w.playerSpeed_index = 0.75
    if not IsValid(lstg.tmpvar.TaiFengEff) then
        lstg.tmpvar.TaiFengEff = New(lib.class.TaiFengEff)
    end
end
local function TaiFengFinal()
    if lstg.var.miss == lstg.tmpvar.TaiFeng_miss then
        ext.achievement:get(69)
    end
end

return {
    [8] = {
        name = [[立夏]],
        switchname = [[LiXia]],
        stitle = [[万物繁茂程度的天气]],
        des = [[/player获得§g当前/hp5%§d的/maxhp
所有敌怪获得等同于§r/player/hp25%§d的/maxhp]],
        spdes = [[有且仅有§b10§d倍权重在/season2的第一波出现]],
        state = 2,
        init = function()
            local v = lstg.var
            player_lib.AddMaxLife(v.lifeleft * 0.05)
        end,
        frame = nil,
        final = nil,
        pro = first10pro,
    },
    [9] = {
        name = [[小满]],
        switchname = [[XiaoMan]],
        stitle = [[满足刚需程度的天气]],
        des = [[获得§g2§d个临时/spellstk，并§g充满所有/spellstk]],
        spdes = nil,
        state = 1,
        init = function()
            local v = lstg.var
            player_lib.SetEnergy(nil, v.energy_stack + 2)
            v.energy = v.maxenergy * v.energy_stack
        end,
        frame = nil,
        final = function()
            local v = lstg.var
            player_lib.SetEnergy(nil, v.energy_stack - 2)
        end,
        pro = 1,
    },
    [10] = {
        name = [[芒种]],
        switchname = [[MangZhong]],
        stitle = [[播种期望程度的天气]],
        des = [[恢复§g25%§d/hp
/expp将固定在原地，且§r无法上线收取§d
每颗/expp每秒有§r9%§d概率翻倍
经过§b999帧§d后/expp消失]],
        spdes = nil,
        state = 1,
        init = function()
            player_lib.AddLife(0.25 * lstg.var.maxlife)
            if not IsValid(lstg.tmpvar.MangZhongEff) then
                lstg.tmpvar.MangZhongEff = New(lib.class.MangZhongEff)
            end
        end,
        frame = nil,
        final = nil,
        pro = 1,
    },
    [11] = {
        name = [[夏至]],
        switchname = [[XiaZhi]],
        stitle = [[万物疯狂程度的天气]],
        des = [[敌人/maxhp§r+50%
敌人死亡时将额外掉落§g1§d颗/expp
/expR§g+25%]],
        spdes = [[有且仅有§b10§d倍权重/season2的最中间一波出现]],
        state = 2,
        init = function()
            local v = lstg.var
            if v.scene_id == 3 then
                mission_lib.GoMission(137)
            end
            v.exp_factor = v.exp_factor + 0.25
            local w = lstg.weather
            w.enemyHP_index = 1.5
        end,
        frame = nil,
        final = function()
            local v = lstg.var
            v.exp_factor = v.exp_factor - 0.25
        end,
        pro = middle10pro,
    },
    [12] = {
        name = [[小暑]],
        switchname = [[XiaoShu]],
        stitle = [[炎热无常程度的天气]],
        des = [[/player§r持续流失/hp§-(不会致死)
敌人/maxhp§r+30%]],
        spdes = nil,
        state = 3,
        init = function()
            if not IsValid(lstg.tmpvar.XiaoShuEff) then
                lstg.tmpvar.XiaoShuEff = New(lib.class.XiaoShuEff)
            end
            local w = lstg.weather
            w.enemyHP_index = 1.3
        end,
        frame = function()
            if lstg.var.frame_counting then
                player_lib.ReduceLife(1 * 0.0045 * max(lstg.var.maxlife, 50) / 35, true, nil, 0.01)
            end
        end,
        final = nil,
        pro = 1,
    },
    [13] = {
        name = [[大暑]],
        switchname = [[DaShu]],
        stitle = [[三伏无常程度的天气]],
        des = [[/player§r持续流失/hp(不会致死)
敌人/maxhp§g-23%]],
        spdes = nil,
        state = 3,
        init = function()
            if not IsValid(lstg.tmpvar.DaShuEff) then
                lstg.tmpvar.DaShuEff = New(lib.class.DaShuEff)
            end
            local w = lstg.weather
            w.enemyHP_index = 0.77
        end,
        frame = function()
            if lstg.var.frame_counting then
                player_lib.ReduceLife(3 * 0.0045 * max(lstg.var.maxlife, 50) / 35, true, nil, 0.01)
            end
        end,
        final = nil,
        pro = 1,
    },
    [14] = {
        name = [[夏雨]],
        switchname = [[XiaYu]],
        stitle = [[雨水四散程度的天气]],
        des = [[屏幕上方不断出现散弹和/aimplayer米弹]],
        spdes = nil,
        state = 3,
        init = function()
            if not IsValid(lstg.tmpvar.XiaYuEff) then
                lstg.tmpvar.XiaYuEff = New(lib.class.XiaYuEff)
            end
        end,
        frame = function()
            local t = stage.current_stage.timer
            local chaos = lstg.var.chaos
            local interval = int(sp.math.GetNumByInverse(chaos, 1, 17, 6))
            local v = min(chaos / 120 + 1.5, 8)
            if lstg.var.frame_counting then
                if t % interval == 0 then
                    local b = NewSimpleBullet(grain_a, 6, ran:Float(-320, 320), 245,
                            ran:Float(v - 0.3, v + 0.3), -90 + ran:Float(-6, 6))
                    b.fogtime = 1
                end
                if t % (interval * 2) == 0 then
                    local x, y = ran:Float(-320, 320), 245
                    local b = NewSimpleBullet(grain_a, 6, x, y, v, Angle(x, y, player))
                    b.fogtime = 1
                end
            end
        end,
        final = nil,
        pro = 1,
    },
    [32] = {
        name = [[阵雨]],
        switchname = [[ZhenYu]],
        stitle = [[选择困难程度的天气]],
        des = [[所有升级额外§g增加1个选项]],
        spdes = nil,
        state = 1,
        init = function()
            if not IsValid(lstg.tmpvar.ZhenYuEff) then
                lstg.tmpvar.ZhenYuEff = New(lib.class.ZhenYuEff)
            end
            lstg.var.level_upOption = lstg.var.level_upOption + 1
        end,
        frame = nil,
        final = function()
            lstg.var.level_upOption = lstg.var.level_upOption - 1
        end,
        pro = 1,
    },
    [41] = {
        name = [[天气雨]],
        switchname = [[TianQiYu]],
        stitle = [[休整再启航程度的天气]],
        des = [[/player§g极速恢复/hp
/maxhp§r不会增加]],
        spdes = nil,
        state = 1,
        init = function()
            if not IsValid(lstg.tmpvar.TianQiYuEff) then
                lstg.tmpvar.TianQiYuEff = New(lib.class.TianQiYuEff)
            end
        end,
        frame = function()
            if lstg.var.frame_counting then
                player_lib.AddLife(20 * 0.1 / 60)
            end
        end,
        final = nil,
        pro = 1,
    },
    [42] = {
        name = [[无云]],
        switchname = [[WuYun]],
        stitle = [[望穿程度的天气]],
        des = [[敌人死亡时有§b50%§d概率额外掉落§g1§d颗/expp
敌人/maxhp§g-50%]],
        spdes = nil,
        state = 1,
        init = function()
            local w = lstg.weather
            w.enemyHP_index = 0.50
        end,
        frame = nil,
        final = nil,
        pro = 1,
    },
    [55] = {
        name = [[荷风]],
        switchname = [[HeFeng]],
        stitle = [[吹拂扰动程度的天气]],
        des = [[/player时不时§r向随机方向移动一小段距离
/spd§b+25%]],
        spdes = nil,
        state = 3,
        init = function()
            local w = lstg.weather
            w.playerSpeed_index = 1.25
            if not IsValid(lstg.tmpvar.HeFengEff) then
                lstg.tmpvar.HeFengEff = New(lib.class.HeFengEff)
            end
        end,
        frame = nil,
        final = nil,
        pro = 1,
    },
    [56] = {
        name = [[台风]],
        switchname = [[TaiFeng]],
        stitle = [[移动不受控程度的天气]],
        des = [[/player时不时§r向随机方向移动一大段距离
/spd§r-25%]],
        spdes = [[/season2/season3共有]],
        state = 3,
        init = TaiFengInit,
        frame = nil,
        final = TaiFengFinal,
        pro = 1,
    },
    [60] = {
        name = [[阴晴]],
        switchname = [[YinQing]],
        stitle = [[弹幕随机程度的天气]],
        des = [[弹幕生成时§g50%§d概率失去判定
每§b120帧§d，将弹幕的判定反转]],
        spdes = nil,
        state = 2,
        init = function()
            local w = lstg.weather
            w.bullet_init_func = function(self)
                if ran:Int(1, 2) == 1 then
                    bullet.setfakeColli(self, false)
                end
                task.New(self, function()
                    local t = stage.current_stage
                    while w.YinQing do
                        if t.timer % 120 == 0 then
                            bullet.setfakeColli(self, self._no_colli)
                        end
                        task.Wait()
                    end
                end)
            end
        end,
        frame = nil,
        final = nil,
        pro = 1,
    },
    [61] = {
        name = [[积云]],
        switchname = [[JiYun]],
        stitle = [[重叠程度的天气]],
        des = [[小怪死亡时在原地§r重新复活
Boss死亡时§r重新出现相同的Boss
敌人/maxhp§r+20%]],
        spdes = nil,
        state = 3,
        init = function()
            local w = lstg.weather
            w.enemyHP_index = 1.2
        end,
        frame = nil,
        final = nil,
        pro = 1,
    },
    [67] = {
        name = [[晴朗]],
        switchname = [[QingLang]],
        stitle = [[无事发生程度的天气]],
        des = [[§g/player将不会死亡
不会出现Hard Wave、Lucky Wave和Boss Wave]],
        spdes = nil,
        state = 1,
        init = function()
        end,
        frame = nil,
        final = nil,
        pro = function()
            if stage.current_stage.is_tutorial then
                return 0
            else
                return 1
            end
        end,
    },
}