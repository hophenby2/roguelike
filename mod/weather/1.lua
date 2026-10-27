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
    [1] = {
        name = [[立春]],
        switchname = [[LiChun]],
        stitle = [[万物复苏程度的天气]],
        des = [[恢复§g100%§d/hp
立即获得§g3~5§d个随机/benefit]],
        spdes = [[有且仅有§b10§d倍权重在/season1的第一波出现]],
        state = 1,
        other = [[立春至！(获得裨益)]],
        init = function(w)
            player_lib.AddLife(lstg.var.maxlife)
            local count = ran:Int(3, 5)
            local list = stg_levelUPlib.GetAdditionList(count, function(p)
                return p.state == 1 and not p.spBENEFIT
            end)
            ext.popup_menu:FlyIn(w.other, 189, 252, 201, list, "bonus")
            for _, p in ipairs(list) do
                p:Set()
            end
        end,
        frame = nil,
        final = nil,
        pro = first10pro,
    },
    [2] = {
        name = [[雨水]],
        switchname = [[YuShui]],
        stitle = [[回忆朦胧程度的天气]],
        des = [[恢复§g20%§d/hp
弹幕有§g36%§d概率失去判定，变得透明
敌人(除boss外)有§b10%§d概率失去判定，变得透明
/plopca§r减半§d]],
        spdes = nil,
        state = 2,
        init = function()
            player_lib.AddLife(0.2 * lstg.var.maxlife)
            if not IsValid(lstg.tmpvar.YuShuiEff) then
                lstg.tmpvar.YuShuiEff = New(lib.class.YuShuiEff)
            end
            lstg.weather.bullet_init_func = function(self)
                local p2 = ran:Float(0, 1)
                if p2 < 0.36 then
                    bullet.setfakeColli(self, false)
                    --雨水
                end
            end
        end,
        frame = nil,
        final = nil,
        pro = 1,
    },
    [3] = {
        name = [[惊蛰]],
        switchname = [[JingZhe]],
        stitle = [[春雷鸣动程度的天气]],
        des = [[恢复§g50%§d/hp
屏幕上§r频繁出现闪电§d
闪电将§g杀死一切除boss外的敌人
闪电对boss造成§g25%/maxhp§d的伤害
闪电对/player造成§r7点§d伤害]],
        spdes = nil,
        state = 3,
        init = function()
            player_lib.AddLife(0.5 * lstg.var.maxlife)
            if not IsValid(lstg.tmpvar.JingZhe_lightninger) then
                lstg.tmpvar.JingZhe_lightninger = New(lib.class.JingZhe_lightninger)
            end
        end,
        frame = nil,
        final = nil,
        pro = 1,
    },
    [4] = {
        name = [[春分]],
        switchname = [[ChunFen]],
        stitle = [[万物平衡程度的天气]],
        des = [[恢复§g50%§d/hp
如果/hp为满则额外获得§g15§d/maxhp
随机获得§g2§d个已获得但未满级的/item
§-（若没有/item满足条件则升1级）]],
        spdes = [[有且仅有§b10§d倍权重在/season1的最中间一波出现]],
        state = 1,
        other = [[/w4至！(获得/item)]],
        init = function(w)

            local v = lstg.var
            if v.scene_id == 3 then
                mission_lib.GoMission(136)
            end
            player_lib.AddLife(0.5 * v.maxlife)
            if v.lifeleft == v.maxlife then
                player_lib.AddMaxLife(15)
            end

            local lvl_lib = stg_levelUPlib
            local got = {}
            for _ = 1, 2 do
                local can_get = {}
                for i, nowc in pairs(lstg.var.addition) do
                    local p = lvl_lib.AdditionTotalList[i]
                    if p.isTool then
                        local maxc = p.maxcount or 999
                        if p.upgrade_get() and (nowc < maxc) then
                            table.insert(can_get, i)
                        end
                    end
                end
                if #can_get > 0 then
                    local i = can_get[ran:Int(1, #can_get)]
                    local t = lvl_lib.AdditionTotalList[i]
                    table.insert(got, t)
                    t:Set()
                else
                    break
                end
            end
            if #got > 0 then
                ext.popup_menu:FlyIn(w.other, 218, 112, 214, got, "bonus")
            else
                AddExp((stg_levelUPlib.GetCurMaxEXP() - v.now_exp) / player_lib.GetEXPfactor())
            end
        end,
        frame = nil,
        final = nil,
        pro = middle10pro,
    },
    [5] = {
        name = [[清明]],
        switchname = [[QingMing]],
        stitle = [[蜉蝣天地程度的天气]],
        des = [[恢复§g10%§d/hp
弹幕贴图大小§b-50%§d，/hitb§g-35%
敌人贴图大小§b-50%§d]],
        spdes = nil,
        state = 2,
        init = function()
            ext.achievement:get(34)
            player_lib.AddLife(0.1 * lstg.var.maxlife)
            lstg.weather.bullet_init_func = function(self)
                object.SetSize(self, 0.5)
                object.SetColli(self, self.a * 0.35)
            end
        end,
        frame = nil,
        final = nil,
        pro = 1,
    },
    [6] = {
        name = [[谷雨]],
        switchname = [[GuYu]],
        stitle = [[茁壮成长程度的天气]],
        des = [[恢复§g20%§d/hp
§g/player快速恢复/hp
/expR§g+50%]],
        spdes = nil,
        state = 1,
        init = function()
            player_lib.AddLife(0.2 * lstg.var.maxlife)
            local v = lstg.var
            v.exp_factor = v.exp_factor + 0.5
            if not IsValid(lstg.tmpvar.GuYuEff) then
                lstg.tmpvar.GuYuEff = New(lib.class.GuYuEff)
            end
        end,
        frame = function()
            if lstg.var.frame_counting then
                player_lib.AddLife(5 * 0.1 / 60)
            end
        end,
        final = function()
            local v = lstg.var
            v.exp_factor = v.exp_factor - 0.5
        end,
        pro = 1,
    },
    [7] = {
        name = [[晴岚]],
        switchname = [[QingLan]],
        stitle = [[风高气舒程度的天气]],
        des = [[从屏幕左边不断吹入绿色米弹]],
        spdes = nil,
        state = 3,
        init = nil,
        frame = function()
            local t = stage.current_stage.timer
            local chaos = lstg.var.chaos
            local interval = int(sp.math.GetNumByInverse(chaos, 1, 17, 6))
            local v = min(chaos / 500 + 0.5, 2)
            if t % interval == 0 and lstg.var.frame_counting then
                lib.class.QingLanBullet(-340, ran:Float(-200, 350), 0.7 * v, ran:Float(0, 360), 3 * v, -1 * v)
            end
        end,
        final = nil,
        pro = 1,
    },
    [31] = {
        name = [[霁雨]],
        switchname = [[JiYu]],
        stitle = [[丁达尔效应程度的天气]],
        des = [[弹幕/hitb§g-25%
弹幕附带§b拖尾效果]],
        spdes = nil,
        state = 2,
        init = function()
            lstg.weather.bullet_init_func = function(self)
                object.SetColli(self, self.a * 0.75)
            end
            if not IsValid(lstg.tmpvar.JiYuEff) then
                lstg.tmpvar.JiYuEff = SmearScreen("JIYU", 8, 9999,
                        LAYER.ENEMY_BULLET - 10, LAYER.ENEMY_BULLET + 10, "")
            end
            lstg.tmpvar.JiYuEff.flag = false
        end,
        frame = nil,
        final = function()
            if IsValid(lstg.tmpvar.JiYuEff) then
                lstg.tmpvar.JiYuEff.flag = true
            end
        end,
        pro = 1,
    },
    [39] = {
        name = [[云樱]],
        switchname = [[YunYing]],
        stitle = [[无理由绽放程度的天气]],
        des = [[敌人死亡时在原地§r生成一朵樱花§d，§b60帧§d后向四周绽放
绽放后，樱瓣每§b30帧§d有§b10%§d概率消失]],
        spdes = nil,
        state = 3,
        init = function()
            if not IsValid(lstg.tmpvar.YunYingEff) then
                lstg.tmpvar.YunYingEff = New(lib.class.YunYingEff)
            end
            lstg.weather.enemy_kill_func = function(self)
                lib.class.PutYunYing(self.x, self.y)
            end
        end,
        frame = nil,
        final = nil,
        pro = 1,
    },
    [40] = {
        name = [[春雾]],
        switchname = [[ChunWu]],
        stitle = [[雾气氤氲程度的天气]],
        des = [[屏幕上每§b60§d帧出现一片雾气区域，持续§r180帧]],
        spdes = nil,
        state = 3,
        init = function()
            if not IsValid(lstg.tmpvar.ChunWuEff) then
                lstg.tmpvar.ChunWuEff = New(lib.class.ChunWuEff)
            end
        end,
        frame = function()
            local t = stage.current_stage.timer
            if t % 60 == 0 then
                New(lib.class.ChunWuFog, ran:Float(-300, 300), ran:Float(-200, 200), 0.6, ran:Float(0, 360))
            end
        end,
        final = nil,
        pro = 1,
    },
    [50] = {
        name = [[新阳]],
        switchname = [[XinYang]],
        stitle = [[以伤为愈程度的天气]],
        des = [[§r/player不再恢复/hp
损失/hp时将获得§g损失值25%§d的/maxhp]],
        spdes = nil,
        state = 2,
        init = function()
            if not IsValid(lstg.tmpvar.XinYangEff) then
                lstg.tmpvar.XinYangEff = New(lib.class.XinYangEff)
            end
        end,
        frame = nil,
        final = nil,
        pro = 1,
    },
    [51] = {
        name = [[云天]],
        switchname = [[YunTian]],
        stitle = [[补充灵力程度的天气]],
        des = [[/atk§g+1.00
恢复/hp时将§g充能同等量的/spellstk]],
        spdes = nil,
        state = 1,
        init = function()
            local p = player
            p.dmg_offset = p.dmg_offset + 1
        end,
        frame = nil,
        final = nil,
        pro = 1,
    },
    [52] = {
        name = [[融雪]],
        switchname = [[RongXue]],
        stitle = [[消融弹幕程度的天气]],
        des = [[弹幕每§b34帧§d有§g1%§d的概率变成/expp]],
        spdes = nil,
        state = 1,
        init = function()
            if not IsValid(lstg.tmpvar.RongXueEff) then
                lstg.tmpvar.RongXueEff = New(lib.class.RongXueEff)
            end
            local w = lstg.weather
            w.bullet_init_func = function(self)
                task.New(self, function()
                    while w.RongXue do
                        if ran:Float(0, 1) < 0.01 then
                            if self.group == GROUP.ENEMY_BULLET then
                                object.Del(self)
                            end
                            item.dropItem(item.drop_exp, 1, self.x, self.y)
                            local eff = lstg.tmpvar.RongXueEff
                            if IsValid(eff) then
                                eff.create_snow(self.x, self.y)
                            end
                        end
                        task.Wait(34)
                    end
                end)
            end
        end,
        frame = nil,
        final = nil,
        pro = 1,
    },
    [53] = {
        name = [[风絮云]],
        switchname = [[FengXuYun]],
        stitle = [[友爱程度的天气]],
        des = [[敌方弹幕对/player造成§g负值§d的伤害]],
        spdes = nil,
        state = 1,
        init = nil,
        frame = nil,
        final = nil,
        pro = 1,
    },
    [54] = {
        name = [[羽云]],
        switchname = [[YuYun]],
        stitle = [[轻浮程度的天气]],
        des = [[敌人、/expp和弹幕将获得§b向上的加速度
/spd+§b50%§d]],
        spdes = nil,
        state = 2,
        init = function()
            if not IsValid(lstg.tmpvar.YuYunEff) then
                lstg.tmpvar.YuYunEff = New(lib.class.YuYunEff)
            end
            local w = lstg.weather
            w.playerSpeed_index = 1.5
        end,
        frame = nil,
        final = nil,
        pro = 1,
    },
}