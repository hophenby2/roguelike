local tg = stg_levelUPlib.tagslist
local lib = activeItem_lib

return {
    [7] = {
        name = [[箜篌引]],
        stitle = [[游心太玄]],
        sdes = [[/holduse
获得§y/inv§d，但同时§r流失/hp§d，流失速度会越来越快]],
        detail = [[/a7sdes]],
        collabd = nil,
        unlockd = [[通关§p挑战19]],
        condd = nil,
        tags = { tg.sacrifice, tg.debuff },
        activeType = 1,
        chargeC = 0.000000,
        maxEnergy = 1,
        hold = true,
        cost = 0.000000,
        event = function(self)
            player.protect = max(player.protect, 5)
            local index = self._reducelife_index or 1
            player_lib.ReduceLife(index * 0.05 * lstg.var.maxlife / 60)
            if not IsValid(self.Object) then
                self.Object = New(lib.class.exoplasm)
            end
        end,
        frameEvent = function(self)
            self._reducelife_index = self._reducelife_index or 1
            if self._is_using then
                self._reducelife_index = self._reducelife_index + 0.01
                if GetSoundState("aubergine") ~= "playing" then
                    PlaySound("aubergine")
                end
                if not self.start_sound then
                    PlaySound("zither")
                    self.start_sound = true
                end
            else
                self._reducelife_index = 1
                self.start_sound = false
                if IsValid(self.Object) then
                    Del(self.Object)
                    self.Object = nil
                end
                if GetSoundState("aubergine") == "playing" then
                    StopSound("aubergine")
                end
            end
        end,
        condfunc = nil,
    },
    [8] = {
        name = [[煲仔饭]],
        stitle = [[什锦口味]],
        sdes = [[/once，使用后宝宝§r消失§d，
每个宝宝提供：§g5§d/hp，§g3§d/maxhp，§g2§d随机属性]],
        detail = [[/a8sdes
随机属性包括：/atk | /ss | /br | /bv]],
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = { tg.life, tg.debuff },
        activeType = 1,
        chargeC = 0.000000,
        maxEnergy = 1,
        hold = false,
        cost = 0.000000,
        event = function(self)
            self:Remove()
            player.nextsp = 5
            local ss = player.shoot_set.speed
            local sv = player.shoot_set.bvelocity
            local sr = player.shoot_set.range
            local addfunc = {
                function(d)
                    player.dmg_offset = player.dmg_offset + d
                end,
                function(d)
                    ss.offset = ss.offset + d
                end,
                function(d)
                    sv.offset = sv.offset + d
                end,
                function(d)
                    sr.offset = sr.offset + d
                end,
            }
            New(tasker, function()
                local function check()
                    local flag = false
                    for _, v in ipairs(lstg.tmpvar.baby_stack) do
                        flag = flag or v.tool_id
                    end
                    return flag
                end
                while check() do
                    local k = lstg.tmpvar.baby_stack[#lstg.tmpvar.baby_stack]
                    if IsValid(k) and k.tool_id then
                        stg_levelUPlib.AdditionTotalList[k.tool_id]:Remove()
                        player_lib.AddLife(5)
                        player_lib.AddMaxLife(3)
                        addfunc[ran:Int(1, #addfunc)](2)
                        New(player_death_ef, k.x, k.y)
                        PlaySound("pldead00", 0.2)
                        PlaySound("eatfood")
                    end
                    task.Wait(6)
                    sp:UnitListUpdate(lstg.tmpvar.baby_stack)
                end
            end)

        end,
        frameEvent = nil,
        condfunc = nil,
    },
    [9] = {
        name = [[八百万众神的庇佑]],
        stitle = [[大笑]],
        sdes = [[长按使用键发出一个可移动的§c泡泡§d，直至松开以固定
泡泡内的弹幕&敌人临时减速80.0%]],
        detail = [[使用时，在/player处生成1个§c泡泡§d，/player移速暂时为§r0%
长按使用键可移动§c泡泡§d，直至松开以固定
泡泡内的弹幕&敌人§g临时减速80.0%§d，泡泡存在时间为§g800帧§d。]],
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = nil,
        activeType = 1,
        chargeC = 1 / 1500,
        maxEnergy = 1,
        hold = true,
        real_cost = 0,
        cost = 1,
        event = function(self)
            if not IsValid(self.active_bubble) then
                PlaySound("bubble2")
                self.active_bubble = New(lib.class.bubble, self, stage.current_stage.timer)
            end
        end,
        frameEvent = function(self)
            if self.last_is_using and not self._is_using then
                if IsValid(self.active_bubble) then
                    self.active_bubble.isMoving = false
                    self.active_bubble.HaveCost = true
                    self.energy = self.energy - self.cost
                    self.active_bubble = nil
                end
            end
        end,
        condfunc = nil,
    },
    [11] = {
        name = [[rewind]],
        stitle = [[控制台领域大神]],
        sdes = [[§g回溯至当前波开始§d]],
        detail = [[/a11sdes]],
        collabd = nil,
        unlockd = [[[使用/playerSakuya/passtime2]],
        condd = nil,
        tags = nil,
        activeType = 2,
        chargeC = 0.28,
        maxEnergy = 1,
        hold = false,
        real_cost = 0,
        cost = 1,
        event = function(self)
            --时间回溯
            ext.ExecuteFlag = true
            activeItem_lib.Rewinding()
            self.energy = self.energy - self.cost
        end,
        frameEvent = nil,
        condfunc = nil,
    },
    [13] = {
        name = [[大天狗的麦饭]],
        stitle = [[应急食品]],
        sdes = [[使用时恢复§g10/hp§d并获得§g10%/spelle]],
        detail = [[/a13sdes]],
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = { tg.life },
        activeType = 1,
        chargeC = 1 / 2100,
        maxEnergy = 1,
        hold = false,
        cost = 1,
        event = function(self)
            local var = lstg.var
            PlaySound("eatfood")
            player_lib.AddLife(10)
            player_lib.AddEnergy(10)
        end,
        frameEvent = nil,
        condfunc = nil,
    },
    [14] = {
        name = [[极限自我扩容]],
        stitle = [[明天体考]],
        sdes = [[每次使用§r失去7点/hp§d
增加§g4点/maxhp§d，§g0.2/atk§d]],
        detail = [[/a14sdes]],
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = { tg.life, tg.debuff },
        activeType = 2,
        chargeC = 1,
        maxEnergy = 1,
        hold = false,
        cost = 1,
        event = function(self)
            PlaySound("powerup1")
            local p = player
            local ss = player.shoot_set.speed
            player_lib.ReduceLife(7)
            player_lib.AddMaxLife(4)
            p.dmg_offset = p.dmg_offset + 0.2
        end,
        frameEvent = nil,
        condfunc = nil,
    },
    [15] = {
        name = [[超干爽伞妖]],
        stitle = [[渗透作用]],
        sdes = [[向/player移动方向丢出一把伞
弹幕碰到伞时，其大小§g缩小§d，伞碰到版边时破裂并§g消弹]],
        detail = [[向/player移动方向丢出一把伞
弹幕碰到伞时，其大小缩小§g60%§d，同时伞增大§g0.7%§d
当伞碰到版边时破裂，
消除小范围弹幕同时生成§gmax(5,吸收的弹幕/5)§d颗露珠
/player吸收露珠时恢复§g0.5%/maxhp§d的/hp]],
        collabd = nil,
        unlockd = [[收取§p"空轮「天边的雨色」"]],
        condd = nil,
        tags = { tg.defend, tg.life },
        activeType = 1,
        chargeC = 1 / 1500,
        maxEnergy = 1,
        hold = false,
        cost = 1,
        event = function(self)
            local ang = atan2(player.dy, player.dx)
            if player.dx == 0 and player.dy == 0 then
                ang = 90
            end
            New(lib.class.penetrate_kogasa, player.x, player.y, cos(ang) * 3, sin(ang) * 3)
        end,
        frameEvent = nil,
        condfunc = nil,
    },
    [17] = {
        name = [[重低音太鼓]],
        stitle = [[节奏大师]],
        sdes = [[按节奏敲击使用时，可以发挥消弹、攻击、/inv的效果，每次最多敲击§b8§d下
若没有按照节奏敲击，则会直接进入冷却]],
        detail = [[按节奏敲击使用时，
第二次敲击：进行一次§g小范围消弹
第四次敲击：发射§g开花/pbullet
第六次敲击：进行一次§g大范围消弹
第八次敲击：发射§g开花/pbullet§d，获得短暂的§g/inv§d效果
每次最多敲击§b8§d下
节奏间隔越长，效果越§g明显
若没有按照节奏敲击，则会§r直接进入冷却]],
        collabd = nil,
        unlockd = [[通关§p挑战7]],
        condd = nil,
        tags = tg.defend,
        activeType = 1,
        chargeC = 1 / 1200,
        maxEnergy = 1,
        hold = false,
        cost = 1,
        real_cost = 0,
        event = function(self)
            local slist = { "808_snare", "909_snare", "808_snare", "fpc_snare_2", "808_snare", "909_snare", "808_snare", "fpc_snare_3" }
            if not self._save_list then
                self._save_list = {  }
            end
            local curpos = #self._save_list + 1
            PlaySound(slist[curpos])
            self._save_list[curpos] = self.timer
            local p = player
            local all = 0
            local all2 = 0
            for i = 1, #self._save_list - 1 do
                local diff = self._save_list[i + 1] - self._save_list[i]
                all = all + diff
                all2 = all2 + diff * diff
            end
            local avg = all / (#self._save_list - 1)
            if #self._save_list > 2 then
                local std = math.sqrt(all2 / (#self._save_list - 1) - avg * avg)
                if std > 3 then
                    self.energy = self.energy - 1
                    self._save_list = nil
                    PlaySound("invalid")
                    NewWave(p.x, p.y, 2, 120, 20, 250, 128, 114)
                    return
                elseif #self._save_list == 8 then
                    self.energy = self.energy - 1
                    self._save_list = nil
                    PlaySound("extend")
                end
            end
            local power = int(11 - (600 / (avg + 60)))
            NewWave(p.x, p.y, 2, 200, 20, 100, 100, 100)
            if curpos == 2 then
                local R = 50 + 10 * power
                NewBon(p.x, p.y, 30, 80, 135, 206, 235)
                NewWave(p.x, p.y, 2, R, 25, 135, 206, 235)
                New(bullet_cleaner, p.x, p.y, R, 25, 25, false, false, 0)
            end
            if curpos == 4 then
                NewWave(p.x, p.y, 2, 100, 40, 189, 252, 201)
                local dmg = p.damage
                local bv, lifetime = p.cur_bv, p.cur_brange
                for A in sp.math.AngleIterator(ran:Float(0, 360), int(10 + power * 2)) do
                    New(player_main_bullet, p.x, p.y, bv, A, dmg, lifetime)
                end
            end
            if curpos == 6 then
                local R = 75 + 19 * power
                NewBon(p.x, p.y, 30, 80, 218, 112, 214)
                NewWave(p.x, p.y, 2, R, 25, 218, 112, 214)
                New(bullet_cleaner, p.x, p.y, R, 25, 25, false, false, 0)
            end
            if curpos == 8 then
                NewWave(p.x, p.y, 2, 100, 40, 255, 227, 132)
                local dmg = p.damage
                local bv, lifetime = p.cur_bv, p.cur_brange
                New(tasker, function()
                    for _ = 1, 6 do
                        for A in sp.math.AngleIterator(ran:Float(0, 360), int(8 + power * 2)) do
                            New(player_main_bullet, p.x, p.y, bv, A, dmg, lifetime)
                        end
                        task.Wait(6)
                    end
                end)

                player.protect = max(player.protect, 30 + 10 * power)
            end
        end,
        frameEvent = function(self)
            self.timer = self.timer or 0
            self.timer = self.timer + 1
        end,
        condfunc = nil,
    },
    [19] = {
        name = [[宝宝堆]],
        stitle = [[宝宝一生堆]],
        sdes = [[永久获得一个§g随机宝宝
/t138，/t143除外]],
        detail = [[/a19sdes]],
        collabd = nil,
        unlockd = nil,
        condd = nil,
        tags = nil,
        activeType = 2,
        chargeC = 0.5,
        maxEnergy = 1,
        hold = false,
        cost = 1,
        event = function()

            local slib = stg_levelUPlib
            local othercond = function(tool)
                return slib.SearchToolTag(tool, "baby")
                        and tool.id ~= 138 and tool.id ~= 143
            end
            local p = slib.GetAdditionList(1, othercond)
            if p[1] then
                PlaySound("powerup")
                p[1]:Set()
            end
        end,
        frameEvent = nil,
        condfunc = nil,
    },
    [21] = {
        name = [[埃及路障]],
        stitle = [[此路不通]],
        sdes = [[立刻结束当前波
§-无法对最终波生效]],
        detail = [[立刻结束当前波
清空屏幕，§r不会获得任何奖励
§-无法对最终波生效]],
        collabd = nil,
        unlockd = [[使用/playerSakuya/passtime1]],
        condd = nil,
        tags = { tg.debuff },
        activeType = 2,
        chargeC = 0.34,
        maxEnergy = 1,
        hold = false,
        cost = 1,
        event = function(self)
            local var = lstg.var
            if var.wave ~= var.maxwave then
                New(lib.class.no_entry_show)
                PlaySound("energy_whip")

                local stg = stage.current_stage
                task.Clear(stg)
                player.protect = max(80, player.protect)
                New(tasker, function()
                    for _ = 1, 80 do
                        object.EnemyNontjtDo(function(e)
                            object.RawDel(e)
                            if e.IsBoss and e._bosssys then
                                boss.system.del(e._bosssys)
                            end
                        end)
                        object.BulletIndesDo(function(e)
                            object.RawDel(e)
                        end)
                        object.LaserDo(function(e)
                            object.RawDel(e)
                        end)
                        for _, e in ObjList(GROUP.ITEM) do
                            object.RawDel(e)
                        end
                        task.Wait()
                    end
                    stg.start_function(var.wave + 1)
                end)

            end
        end,
        frameEvent = nil,
        condfunc = nil,
    },
    [22] = {
        name = [[新月]],
        stitle = [[C-Moon]],
        sdes = [[召唤一个§c新月§d，
§p5§d秒内使靠近的物体受到/player的§c斥力]],
        detail = [[/a22sdes]],
        collabd = nil,
        unlockd = [[携带任意/active通关/scenep2]],
        condd = nil,
        tags = nil,
        activeType = 1,
        chargeC = 1 / 1200,
        maxEnergy = 1,
        hold = false,
        cost = 1,
        event = function(self)
            lstg.tmpvar.c_moon = New(lib.class.c_moon)
        end,
        frameEvent = nil,
        condfunc = nil,
    },
    [23] = {
        name = [[高清相机]],
        stitle = [[拍个照发朋友圈]],
        sdes = [[对全屏进行§g1§d次拍照取景
消除弹幕，并且造成§g300%/atk§d 的伤害]],
        detail = [[/a23sdes]],
        collabd = nil,
        unlockd = [[使用/playerAya通关/scenep3]],
        condd = nil,
        tags = nil,
        activeType = 3,
        chargeC = 1 / 25,
        maxEnergy = 1,
        hold = false,
        cost = 1,
        event = function()
            New(aya_player.bullets.photo_shoot, 30, player.damage * 3)
            local bottom = New(aya_player.bullets.capture_bottom, "_active_capture")
            New(aya_player.bullets.capture_top, "_active_capture", 90, 5, bottom)
        end,
        frameEvent = nil,
        condfunc = nil,
    },
    [29] = {
        name = [[罪人不释之枷]],
        stitle = [[澄如明镜]],
        sdes = [[/holduse
/player每秒流失§r10%/hp§d，同时所有敌人以§g9倍速度§d流失/hp]],
        detail = [[/a29sdes]],
        collabd = nil,
        unlockd = [[使用/playerYoumu/passtime2]],
        condd = nil,
        tags = { tg.sacrifice, tg.debuff },
        activeType = 1,
        chargeC = 0,
        maxEnergy = 1,
        hold = true,
        cost = 0,
        event = function(self)
            local value = 0.1
            local ml = lstg.var.maxlife
            player_lib.ReduceLife(value * ml / 60)
            object.EnemyNontjtDo(function(e)
                if e.class.base.take_damage then
                    e.class.base.take_damage(e, 9 * value * ml / 60)
                end
            end)
            if not IsValid(self.Object) then
                self.Object = New(lib.class.shackles)
            end
        end,
        frameEvent = function(self)
            if self._is_using then
                if GetSoundState("dark_rite") ~= "playing" then
                    PlaySound("dark_rite")
                end
                if not self.start_sound then
                    PlaySound("shackles")
                    self.start_sound = true
                end
            else
                self.start_sound = false
                if IsValid(self.Object) then
                    Del(self.Object)
                    self.Object = nil
                end
                if GetSoundState("dark_rite") == "playing" then
                    StopSound("dark_rite")
                end
            end
        end,
        frameEvent = nil,
        condfunc = nil,
    },
}