local tg = stg_levelUPlib.tagslist
local lib = activeItem_lib

return {

    [10] = {
        name = [[思考]],
        stitle = [[我怎么知道你在想什么]],
        sdes = [[场上所有子弹暂停移动§g2秒]],
        detail = [[/a10sdes]],
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = nil,
        activeType = 1,
        chargeC = 1 / 688,
        maxEnergy = 1,
        hold = false,
        cost = 1,
        event = function(self)
            object.BulletIndesDo(function(b)
                b._stop_x = nil
                b._stop_y = nil
            end)
            TelescopeSmearScreen(player, 24, 0.4)
            PlaySound('slash2', 1.0)
            lstg.var.score = lstg.var.score + 30360
            self.little_time_stop = 120
        end,
        frameEvent = function(self)
            self.little_time_stop = self.little_time_stop or 0
            if self.little_time_stop > 0 then
                self.little_time_stop = self.little_time_stop - 1
                object.BulletIndesDo(function(b)
                    if not b.not_move then
                        if not b._stop_x and not b._stop_y then
                            b._stop_x = b.x
                            b._stop_y = b.y
                        end
                        b.x = b._stop_x
                        b.y = b._stop_y
                    end
                end)
            end
        end,
        condfunc = nil,
    },
    [18] = {
        name = [[自主散华]],
        stitle = [[手动式全方位射击]],
        sdes = [[发射主炮开花弹]],
        detail = [[/a18sdes]],
        collabd = [[/t91：发射量翻倍]],
        unlockd = nil,
        condd = nil,
        tags = nil,
        activeType = 1,
        chargeC = 1 / 389,
        maxEnergy = 1,
        hold = false,
        cost = 1,
        event = function(self)
            local N = 10
            if lstg.var.perfect_spread > 0 then
                N = N * 2
            end

            local p = player
            local dmg = p.damage
            local bv, lifetime = p.cur_bv, p.cur_brange
            for A in sp.math.AngleIterator(ran:Float(0, 360), N) do
                New(player_main_bullet, p.x, p.y, bv, A, dmg, lifetime)
            end
        end,
        frameEvent = nil,
        condfunc = nil,
    },
    [20] = {
        name = [[惊吓日和]],
        stitle = [[今天也在努力吓人]],
        sdes = [[更改一次当前天气]],
        detail = [[/a20sdes]],
        collabd = nil,
        unlockd = [[收取 §p"恐吓「针里插缝」"]],
        condd = nil,
        tags = nil,
        activeType = 2,
        chargeC = 0.5,
        maxEnergy = 1,
        hold = false,
        cost = 1,
        event = function(self)
            if lstg.var._season_system then
                PlaySound("whoosh")
                local w = lstg.weather
                table.remove(w.total_weather)
                stage_lib.SetWeather(function(p)
                    return w.now_weather ~= p.id
                end)
                New(stage_lib.Show_WaveCount, lstg.var.wave, "")
            end
        end,
        frameEvent = nil,
        condfunc = function()
            return lstg.var._season_system
        end,
    },
}