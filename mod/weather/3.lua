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
    [15] = {
        name = [[立秋]],
        switchname = [[LiQiu]],
        stitle = [[万物消长程度的天气]],
        des = [[敌人/maxhp随机变为原来的§b10%~200%§d
升级时有§g50%§d概率§g额外升1级§d]],
        spdes = [[有且仅有§b10§d倍权重在/season3的第一波出现]],
        state = 1,
        init = nil,
        frame = nil,
        final = nil,
        pro = first10pro,
    },
    [16] = {
        name = [[处暑]],
        switchname = [[ChuShu]],
        stitle = [[炎热消持程度的天气]],
        des = [[/player/hp高于/maxhp的§b50%§d时§r持续流失/hp
否则§g快速恢复/hp]],
        spdes = nil,
        state = 2,
        init = nil,
        frame = function()
            local v = lstg.var
            if v.frame_counting then
                if v.lifeleft > v.maxlife / 2 then
                    player_lib.ReduceLife(5 * 0.0045 * max(v.maxlife, 50) / 35, "ChuShu")
                else
                    player_lib.AddLife(7 * 0.0045 * max(v.maxlife, 50) / 35)
                end
            end
        end,
        final = nil,
        pro = 1,
    },
    [17] = {
        name = [[白露]],
        switchname = [[BaiLu]],
        stitle = [[秋高气爽程度的天气]],
        des = [[敌人死亡时将掉落§g1§d颗露珠
/player吸收露珠时恢复§g0.5%/maxhp§d的/hp]],
        spdes = nil,
        state = 1,
        init = function()
            if not IsValid(lstg.tmpvar.BaiLuEff) then
                lstg.tmpvar.BaiLuEff = New(lib.class.BaiLuEff)
            end
            lstg.weather.enemy_kill_func = function(self)
                item.dropItem(item.drop_dewdrop, 1, self.x, self.y)
            end
        end,
        frame = nil,
        final = nil,
        pro = 1,
    },
    [18] = {
        name = [[秋分]],
        switchname = [[QiuFen]],
        stitle = [[万物沉稳程度的天气]],
        des = [[敌人/spd§b-25%§d
升级时有§g25%§d概率随机获得1个/item]],
        spdes = [[有且仅有§b10§d倍权重在/season3的最中间一波出现]],
        state = 1,
        other = [[/w18至！(获得/item)]],
        init = function()
            if lstg.var.scene_id == 3 then
                mission_lib.GoMission(138)
            end
            if not IsValid(lstg.tmpvar.QiuFenEff) then
                lstg.tmpvar.QiuFenEff = New(lib.class.QiuFenEff)
            end
        end,
        frame = function()
            if lstg.var.frame_counting then
                object.EnemyNontjtDo(function(e)
                    sp:UnitSetVIndex(e, -0.25)
                end)
            end
        end,
        final = nil,
        pro = middle10pro,
    },
    [19] = {
        name = [[寒露]],
        switchname = [[HanLu]],
        stitle = [[稗谷丰盈程度的天气]],
        des = [[敌人死亡时向随机方向爆出§r0~4§d颗拥有重力的米弹，
天上不断§g掉落§y/expp]],
        spdes = nil,
        state = 1,
        init = function()
            lstg.weather.enemy_kill_func = function(self)
                local x, y = self.x, self.y
                for _ = 1, ran:Int(0, 4) do
                    local col = ran:Int(0, 1) * 12 + 2
                    local b = NewSimpleBullet(grain_a, col, x, y, 1.6, ran:Float(0, 360))
                    b.ag = 0.03
                    b.omega = ran:Float(2, 3) * ran:Sign()
                    b.maxvy = 4.3
                end
            end
        end,
        frame = function()
            local t = stage.current_stage.timer
            if lstg.var.frame_counting then
                if t % 15 == 0 then
                    item.dropItem(item.drop_exp, 1, ran:Float(-300, 300), 240)
                end
            end
        end,
        final = nil,
        pro = 1,
    },
    [20] = {
        name = [[霜降]],
        switchname = [[ShuangJiang]],
        stitle = [[深秋微寒程度的天气]],
        des = [[所有敌方子弹附带一层白边
/player每被击中时，/spd§r-25%§-(Wave结束时恢复)]],
        spdes = nil,
        state = 3,
        init = function()
            lstg.weather.ShuangJiang_speed_low = 0
        end,
        frame = function()
            if not scoredata.Achievement["64"] then
                local ball_huge_c = 0
                object.BulletIndesDo(function(b)
                    if b.imgclass == ball_huge then
                        ball_huge_c = ball_huge_c + 1
                    end
                end)
                if ball_huge_c > 10 then
                    ext.achievement:get(64)
                end
            end
        end,
        final = function()
            lstg.weather.ShuangJiang_speed_low = 0
        end,
        pro = 1,
    },
    [21] = {
        name = [[谷物雨]],
        switchname = [[GuWuYu]],
        stitle = [[丰收祈福程度的天气]],
        des = [[弹幕/hitb§r+5%
所有弹幕贴图§b变为红、橙、黄色米弹]],
        spdes = nil,
        state = 2,
        init = function()
            local GuWuYu_Colors = { 2, 12, 14 }
            object.BulletIndesDo(function(b)
                b.GuWuYu_index = GuWuYu_Colors[ran:Int(1, 3)]
            end)
            lstg.weather.bullet_init_func = function(self)
                self.GuWuYu_index = GuWuYu_Colors[ran:Int(1, 3)]
                object.SetSizeColli(self, 1.05)
            end
        end,
        frame = nil,
        final = nil,
        pro = 1,
    },
    [35] = {
        name = [[鳞云]],
        switchname = [[LinYun]],
        stitle = [[守矩程度的天气]],
        des = [[弹幕仅能往坐标轴的正负方向移动]],
        spdes = nil,
        state = 2,
        init = nil,
        frame = function()
            if lstg.var.frame_counting then
                object.BulletIndesDo(function(b)
                    if not b.not_move then
                        if not b.LinYun_set then
                            if abs(b.vx) > abs(b.vy) then
                                b.LinYun_set = 1
                            else
                                b.LinYun_set = 2
                            end
                        end
                        if b.LinYun_set == 1 then
                            b.y = b.y - b.vy
                        else
                            b.x = b.x - b.vx
                        end
                    end
                end)
            end
        end,
        final = nil,
        pro = 1,
    },
    [43] = {
        name = [[秋老虎]],
        switchname = [[QiuLaoHu]],
        stitle = [[回光返夏程度的天气]],
        des = [[/player§r持续掉血]],
        spdes = nil,
        state = 3,
        init = function()
            if not IsValid(lstg.tmpvar.QiuLaoHuEff) then
                lstg.tmpvar.QiuLaoHuEff = New(lib.class.QiuLaoHuEff)
            end
        end,
        frame = function()
            if lstg.var.frame_counting then
                player_lib.ReduceLife(2 * 0.0045 * max(lstg.var.maxlife, 50) / 35, "QiuLaoHu")
            end
        end,
        final = nil,
        pro = 1,
    },
    [44] = {
        name = [[秋实]],
        switchname = [[QiuShi]],
        stitle = [[弹幕成熟程度的天气]],
        des = [[被弹时，/maxhp§g+1.5§d]],
        spdes = nil,
        state = 1,
        init = nil,
        frame = nil,
        final = nil,
        pro = 1,
    },
    [45] = {
        name = [[绯空]],
        switchname = [[FeiKong]],
        stitle = [[欢撒收获程度的天气]],
        des = [[§g+5§d/maxhp
敌人死亡时§r爆出开花弹]],
        spdes = nil,
        state = 3,
        init = function()
            if not IsValid(lstg.tmpvar.FeiKongEff) then
                lstg.tmpvar.FeiKongEff = New(lib.class.FeiKongEff)
            end
            player_lib.AddMaxLife(5)
            lstg.weather.enemy_kill_func = function(self)
                local chaos = lstg.var.chaos
                for a in sp.math.AngleIterator(ran:Float(0, 360), int(min(9, chaos / 12.5))) do
                    NewSimpleBullet(ball_mid_c, 2, self.x, self.y, min(9, 2 + chaos / 888 * 7), a)
                end
            end
        end,
        frame = nil,
        final = nil,
        pro = 1,
    },
    [57] = {
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
    [58] = {
        name = [[卷云]],
        switchname = [[JuanYun]],
        stitle = [[包裹程度的天气]],
        des = [[每当消弹时，有10%概率生成1颗/expp]],
        spdes = nil,
        state = 1,
        init = nil,
        frame = nil,
        final = nil,
        pro = 1,
    },
    [59] = {
        name = [[社日]],
        switchname = [[SheRi]],
        stitle = [[全属性提升程度的天气]],
        des = [[/hp§g恢复至满
/maxhp§g+5
充满§g所有/spellstk
/ss§g+10
/hitb§r+2
/atk、/spd、/bv§g+50%]],
        spdes = nil,
        state = 1,
        init = function()
            local v = lstg.var
            player_lib.AddMaxLife(5)
            v.lifeleft = v.maxlife
            v.energy = v.maxenergy * v.energy_stack
            local p = player
            p.dmg_fixed = p.dmg_fixed + 0.5
            local set = p.shoot_set
            local ss = set.speed
            local sr = set.range
            local sb = set.bvelocity
            ss.offset = ss.offset + 10
            sr.fixed = sr.fixed + 0.5
            sb.fixed = sb.fixed + 0.5
            player_lib.AddPlayerCollisize(2)
            if not IsValid(lstg.tmpvar.SheRiEff) then
                lstg.tmpvar.SheRiEff = New(lib.class.SheRiEff)
            end
        end,
        frame = nil,
        final = function()
            local p = player
            p.dmg_fixed = p.dmg_fixed - 0.5
            local set = p.shoot_set
            local ss = set.speed
            local sr = set.range
            local sb = set.bvelocity
            ss.offset = ss.offset - 10
            sr.fixed = sr.fixed - 0.5
            sb.fixed = sb.fixed - 0.5
            player_lib.AddPlayerCollisize(-2)
        end,
        pro = 1,
    },
    [66] = {
        name = [[秋霜]],
        switchname = [[QiuShuang]],
        stitle = [[枫叶残红程度的天气]],
        des = [[敌人死亡时会喷洒枫叶，屏幕震动]],
        spdes = nil,
        state = 2,
        init = function()
            if not IsValid(lstg.tmpvar.QiuShuangEff) then
                lstg.tmpvar.QiuShuangEff = New(lib.class.QiuShuangEff)
            end
            lstg.weather.enemy_kill_func = function(self)
                New(boss_explode_maple, self.x, self.y, 80)
            end
        end,
        frame = nil,
        final = nil,
        pro = 1,
    },
}