local lib = weather_lib

return {
    [27] = {
        name = [[蜃境]],
        switchname = [[ShenJing]],
        stitle = [[身临幻境程度的天气]],
        des = [[敌机子弹发射时§b贴图发生随机变化
但/hitb不变]],
        spdes = nil,
        state = 3,
        init = function()
            if not IsValid(lstg.tmpvar.ShenJingEff) then
                lstg.tmpvar.ShenJingEff = New(lib.class.ShenJingEff)
            end
            lstg.weather.bullet_init_func = function(self)
                local a, b = self.a, self.b
                bullet.ChangeImage(self, bulletStyles[ran:Int(1, #bulletStyles)], self._index)
                self.a, self.b = a, b
            end
        end,
        frame = nil,
        final = nil,
        pro = 1,
    },
    [28] = {
        name = [[彼世]],
        switchname = [[BiShi]],
        stitle = [[死后皆空程度的天气]],
        des = [[场上所有物体§b失去判定
非时符符卡和非符倒计时§b大幅减少]],
        spdes = nil,
        state = 2,
        init = function()
            if not IsValid(lstg.tmpvar.BiShiEff) then
                lstg.tmpvar.BiShiEff = New(lib.class.BiShiEff)
            end
            lstg.weather.bullet_init_func = function(self)
                bullet.setfakeColli(self, false)
            end
        end,
        frame = function()
            if lstg.var.frame_counting then
                object.EnemyNontjtDo(function(e)
                    e.colli = false
                end)
                object.BulletIndesDo(function(e)
                    e.colli = false
                end)
                object.LaserDo(function(e)
                    e.colli = false
                end)
            end
        end,
        final = nil,
        pro = 1,
    },
    [29] = {
        name = [[狂气]],
        switchname = [[KuangQi]],
        stitle = [[精神疯狂程度的天气]],
        des = [[弹幕和敌人的/spd§r+100%
/player/spd§r+100%]],
        spdes = nil,
        state = 3,
        init = function()
            if not IsValid(lstg.tmpvar.KuangQiEff) then
                lstg.tmpvar.KuangQiEff = New(lib.class.KuangQiEff)
            end
            local w = lstg.weather
            w.playerSpeed_index = 2
        end,
        frame = function()
            local doAccel = function(e)
                sp:UnitSetVIndex(e, 1)
            end
            object.EnemyNontjtDo(doAccel)
            object.BulletIndesDo(doAccel)
        end,
        final = nil,
        pro = 1,
    },
    [30] = {
        name = [[漩涡]],
        switchname = [[XuanWo]],
        stitle = [[旋转不停程度的天气]],
        des = [[屏幕上所有物体获得以屏幕中心为中心的旋转速度]],
        spdes = nil,
        state = 3,
        init = function()
            if not IsValid(lstg.tmpvar.XuanWoEff) then
                lstg.tmpvar.XuanWoEff = New(lib.class.XuanWoEff)
            end
        end,
        frame = function()
            local doRotate = function(e)
                if not e.__not_XuanWo then
                    local R = Dist(0, 0, e)
                    local A = Angle(0, 0, e)
                    local v = R / 200
                    e.x = e.x + cos(A + 90) * v
                    e.y = e.y + sin(A + 90) * v
                end
            end
            object.EnemyNontjtDo(doRotate)
            object.BulletIndesDo(doRotate)
            object.LaserDo(doRotate)
            doRotate(player)
            for _, i in ObjList(GROUP.ITEM) do
                doRotate(i)
            end
        end,
        final = nil,
        pro = 1,
    },
    [33] = {
        name = [[绀药]],
        switchname = [[GanYao]],
        stitle = [[绝对完美程度的天气]],
        des = [[/player受击时§r立即从当前波重新开始
若/player因流失/hp而死亡，也§r从当前波重新开始]],
        spdes = nil,
        state = 3,
        init = function()
            if not IsValid(lstg.tmpvar.GanYaoEff) then
                lstg.tmpvar.GanYaoEff = New(lib.class.GanYaoEff)
            end
        end,
        frame = nil,
        final = function()
        end,
        pro = 1,
    },
    [34] = {
        name = [[逆转]],
        switchname = [[NiZhuan]],
        stitle = [[气天的度程转逆]],
        des = [[/player操作§r反向]],
        spdes = nil,
        state = 3,
        init = function()
            mission_lib.GoMission(5)
            if not IsValid(lstg.tmpvar.NiZhuanEff) then
                lstg.tmpvar.NiZhuanEff = New(lib.class.NiZhuanEff)
            end
        end,
        frame = function()
            if lstg.var.reverse_shoot then
                ext.achievement:get(71)
            end
        end,
        final = nil,
        pro = 1,
    },
    [38] = {
        name = [[X]],
        switchname = [[weatherX]],
        stitle = [[未知程度的天气]],
        des = [[随机获得§g5§d个/tempitem]],
        spdes = nil,
        state = 1,
        other = { "获得/item", "失去/item" },
        init = function(w)
            if not IsValid(lstg.tmpvar.weatherXEff) then
                lstg.tmpvar.weatherXEff = New(lib.class.weatherXEff)
            end
            local lvl_lib = stg_levelUPlib
            local got = {}
            local othercond = function(tool)
                return tool.isTool and not  lvl_lib.SearchToolTag(tool,"debuff")
            end
            for _ = 1, 5 do
                local tool = lvl_lib.GetAdditionList(1, othercond)[1]
                if tool then
                    tool.temporary = true
                    table.insert(got, tool)
                    tool:Set(true)
                else
                    break
                end
            end
            lstg.weather.weatherXgot = got
            if #got > 0 then
                ext.popup_menu:FlyIn(w.other[1], 255, 227, 132, got, "bonus")
            end
        end,
        frame = nil,
        final = function(w)
            local lvl_lib = stg_levelUPlib
            if lstg.weather.weatherXgot then
                local got = lstg.weather.weatherXgot
                local lost = {}
                for _, p in ipairs(got) do
                    if lstg.var.addition[p.id] then
                        p.temporary = false
                        p:Remove()
                        table.insert(lost, p)
                    end
                end
                if #got > 0 then
                    ext.popup_menu:FlyIn(w.other[2], 250, 128, 114, lost, "invalid")
                end
            end
        end,
        pro = 1,
    },
    [47] = {
        name = [[裨益日]],
        switchname = [[BiYiRi]],
        stitle = [[满眼只有裨益程度的天气]],
        des = [[屏幕上方不断掉落可被拾取的/benefit
但其不能上线收取
升级时只有/benefit选项]],
        spdes = nil,
        state = 1,
        init = function()
            if lstg.var.scene_id == 3 then
                mission_lib.GoMission(140)
            end
        end,
        frame = function()
            if lstg.var.frame_counting then
                local t = stage.current_stage.timer
                if t % 100 == 0 then
                    local othercond = function(tool)
                        return tool.state == 1 and not tool.spBENEFIT
                    end
                    local addition = stg_levelUPlib.GetAdditionList(1, othercond)[1]
                    item.dropItem(item.drop_addition_sp, 1, ran:Float(-320, 320), 245, addition.id)
                end
            end
        end,
        final = nil,
        pro = 1,
    },
    [48] = {
        name = [[交易日]],
        switchname = [[JiaoYiRi]],
        stitle = [[满眼只有交易程度的天气]],
        des = [[屏幕上方不断掉落可被拾取的/trade
但其不能上线收取
升级时只有/trade§d选项]],
        spdes = nil,
        state = 2,
        init = nil,
        frame = function()
            if lstg.var.frame_counting then
                local t = stage.current_stage.timer
                if t % 80 == 0 then
                    local othercond = function(tool)
                        return tool.state == 2
                    end
                    local addition = stg_levelUPlib.GetAdditionList(1, othercond)[1]
                    item.dropItem(item.drop_addition_sp, 1, ran:Float(-320, 320), 245, addition.id)
                end
            end
        end,
        final = nil,
        pro = 1,
    },
    [49] = {
        name = [[侵害日]],
        switchname = [[QinHaiRi]],
        stitle = [[满眼只有侵害程度的天气]],
        des = [[屏幕上方不断掉落可被拾取的/infringe
但其不能上线收取
升级时只有/infringe§d选项]],
        spdes = nil,
        state = 3,
        init = nil,
        frame = function()
            if lstg.var.frame_counting then
                local t = stage.current_stage.timer
                if t % 60 == 0 then
                    local othercond = function(tool)
                        return tool.state == 3
                    end
                    local addition = stg_levelUPlib.GetAdditionList(1, othercond)[1]
                    item.dropItem(item.drop_addition_sp, 1, ran:Float(-320, 320), 245, addition.id)
                end
            end
        end,
        final = nil,
        pro = 1,
    },
    [62] = {
        name = [[幻玉]],
        switchname = [[HuanYu]],
        stitle = [[红烧程度的天气]],
        des = [[所有子弹被替换为蓝色大玉，§g但为点弹判定]],
        spdes = nil,
        state = 2,
        init = function()
            ext.achievement:get(51)
            if not IsValid(lstg.tmpvar.HuanYuEff) then
                lstg.tmpvar.HuanYuEff = New(lib.class.HuanYuEff)
            end
            lstg.weather.bullet_init_func = function(self)
                bullet.ChangeImage(self, ball_huge, 6, true)
                object.SetColli(self, 2)
            end
        end,
        frame = nil,
        final = nil,
        pro = 1,
    },
    [63] = {
        name = [[浮月]],
        switchname = [[FuYue]],
        stitle = [[低重力程度的天气]],
        des = [[弹幕、敌人和经验点获得§b向上的加速度]],
        spdes = nil,
        state = 2,
        init = function()
            if not IsValid(lstg.tmpvar.FuYueEff) then
                lstg.tmpvar.FuYueEff = New(lib.class.FuYueEff)
            end
        end,
        frame = nil,
        final = nil,
        pro = 1,
    },
    [64] = {
        name = [[浮日]],
        switchname = [[FuRi]],
        stitle = [[高重力程度的天气]],
        des = [[弹幕、敌人和经验点获得§b向下的加速度]],
        spdes = nil,
        state = 2,
        init = function()
            if not IsValid(lstg.tmpvar.FuRiEff) then
                lstg.tmpvar.FuRiEff = New(lib.class.FuRiEff)
            end
        end,
        frame = nil,
        final = nil,
        pro = 1,
    },
    [65] = {
        name = [[阴阳]],
        switchname = [[YinYang]],
        stitle = [[虚实互融程度的天气]],
        des = [[弹幕有§b50%§d失去判定
点击§b低速键§d时，将弹幕的判定§b反转]],
        spdes = nil,
        state = 2,
        init = function()
            local w = lstg.weather
            w.bullet_init_func = function(self)
                if ran:Int(1, 2) == 1 then
                    bullet.setfakeColli(self, false)
                end
                task.New(self, function()
                    while w.YinYang do
                        if player._playersys:keyIsPressed("slow") then
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
    [75] = {
        name = [[极光]],
        switchname = [[JiGuang]],
        stitle = [[未知天气程度的天气]],
        des = [[随机模仿一种天气]],
        spdes = nil,
        state = 2,
        init = function()
            lstg.tmpvar.JiGuangID = ran:Int(1, #lib.weather)
            while lstg.tmpvar.JiGuangID == 75 or lstg.tmpvar.JiGuangID == 33 do
                lstg.tmpvar.JiGuangID = ran:Int(1, #lib.weather)
            end
            local w = lib.weather[lstg.tmpvar.JiGuangID]
            if w and w.switch then
                lstg.weather[w.switch] = true
            end
            if w and w._init then
                w:_init()
            end
        end,
        frame = function()
            local w = lib.weather[lstg.tmpvar.JiGuangID]
            if w and w._frame then
                w:_frame()
            end
        end,
        final = function()
            local w = lib.weather[lstg.tmpvar.JiGuangID]
            if w and w.switch then
                lstg.weather[w.switch] = nil
            end
            if w and w._final then
                w:_final()
            end
        end,
        pro = 1,
    },
    [76] = {
        name = [[X*2]],
        switchname = [[weatherX]],
        stitle = [[未知*2程度的天气]],
        des = [[随机获得§g10§d个/tempitem]],
        spdes = nil,
        state = 1,
        other = { "获得/item", "失去/item" },
        init = function(w)
            if not IsValid(lstg.tmpvar.weatherXEff) then
                lstg.tmpvar.weatherXEff = New(lib.class.weatherXEff)
            end
            local lvl_lib = stg_levelUPlib
            local got = {}
            local othercond = function(tool)
                return tool.isTool and not  lvl_lib.SearchToolTag(tool,"debuff")
            end
            for _ = 1, 10 do
                local tool = lvl_lib.GetAdditionList(1, othercond)[1]
                if tool then
                    tool.temporary = true
                    table.insert(got, tool)
                    tool:Set(true)
                else
                    break
                end
            end
            lstg.weather.weatherXgot = got
            if #got > 0 then
                ext.popup_menu:FlyIn(w.other[1], 255, 227, 132, got, "bonus")
            end
        end,
        frame = nil,
        final = function(w)
            local lvl_lib = stg_levelUPlib
            if lstg.weather.weatherXgot then
                local got = lstg.weather.weatherXgot
                local lost = {}
                for _, p in ipairs(got) do
                    if lstg.var.addition[p.id] then
                        p.temporary = false
                        p:Remove()
                        table.insert(lost, p)
                    end
                end
                if #got > 0 then
                    ext.popup_menu:FlyIn(w.other[2], 250, 128, 114, lost, "invalid")
                end
            end
        end,
        pro = 1,
    },
    [77] = {
        name = [[abs(X)]],
        switchname = [[weatherX]],
        stitle = [[魅知之旅程度的天气]],
        des = [[随机获得§g5§d个/item]],
        spdes = nil,
        state = 1,
        other = {"获得/item"},
        init = function(w)
            if not IsValid(lstg.tmpvar.weatherXEff) then
                lstg.tmpvar.weatherXEff = New(lib.class.weatherXEff)
            end
            local lvl_lib = stg_levelUPlib
            local got = {}
            local othercond = function(tool)
                return tool.isTool and not  lvl_lib.SearchToolTag(tool,"debuff")
            end
            for _ = 1, 5 do
                local tool = lvl_lib.GetAdditionList(1, othercond)[1]
                if tool then
                    tool.temporary = true
                    table.insert(got, tool)
                    tool:Set(true)
                else
                    break
                end
            end
            if #got > 0 then
                ext.popup_menu:FlyIn(w.other[1], 255, 227, 132, got, "bonus")
            end
        end,
        frame = nil,
        final = nil,
        pro = 1,
    },
    [78] = {
        name = [[亡雨]],
        switchname = [[WangYu]],
        stitle = [[百鬼夜行程度的天气]],
        des = [[屏幕上不断出现§r横行的鬼魂§d，阻挡子弹]],
        spdes = nil,
        state = 3,
        init = nil,
        frame = function()
            local t = stage.current_stage.timer
            if lstg.var.frame_counting then
                if t % 4 == 0 then
                    local d = ran:Sign()
                    New(lib.dead_soul, 350 * d, ran:Float(-220, 220), ran:Float(2, 4) * -d, 0)
                end
            end
        end,
        final = nil,
        pro = 1,
    },
    [79] = {
        name = [[流星雨]],
        switchname = [[LiuXingYu]],
        stitle = [[向星许愿程度的天气]],
        des = [[屏幕上方不断出现星星坠落
开始时掉落一个§y4级/item§d]],
        spdes = [[仅当获得§y天星之沐愿§d中任何一种才能抽取到此天气]],
        state = 1,
        init = function()
            if not IsValid(lstg.tmpvar.LiuXingYuEff) then
                lstg.tmpvar.LiuXingYuEff = New(lib.class.LiuXingYuEff)
            end
            local othercond = function(tool)
                return tool.quality == 4
            end
            local addition = stg_levelUPlib.GetAdditionList(1, othercond)
            if #addition > 0 then
                item.dropItem(item.drop_card, 1, 0, 240, addition[1].id)
            end
        end,
        frame = function()
            if lstg.var.frame_counting then
                local t = stage.current_stage.timer
                local chaos = lstg.var.chaos
                local interval = int(sp.math.GetNumByInverse(chaos, 1, 17, 6))
                local v = min(chaos / 120 + 1, 5)
                local Kcolor = { 100, 100, 100 }
                if t % interval == 0 then
                    local va = -40
                    v = v + abs(sin(t)) * 1
                    local b = NewSimpleBullet(star_small, 8, ran:Float(-500, 300), 260, v, va)
                    b.bound = false
                    b.ag = v / 100
                    b.omega = 3
                    function b:frame_other()
                        if self.y < -245 then
                            if #self.smear == 0 then
                                object.RawDel(self)
                            end
                        else
                            bullet.smear_add(self, 100)
                        end
                        bullet.smear_frame(self, 7)
                    end
                    function b:render_other()
                        bullet.smear_render(self, "mul+add", Kcolor)
                    end
                end
            end
        end,
        final = nil,
        pro = function()
            local va = lstg.var.addition
            if va[40] or va[41] or va[42] then
                return 1
            else
                return 0
            end
        end,
    },

}