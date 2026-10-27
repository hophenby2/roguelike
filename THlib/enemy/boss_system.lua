local StopWatch = StopWatch

local CardsSystem = plus.Class()
boss._cards_system = CardsSystem
---@param system boss.system @要执行符卡组的boss挂载系统
---@param cards table @默认符卡表
---@param is_final boolean @是否执行完删除boss
function CardsSystem:init(system, cards, is_final)
    if is_final == nil then
        is_final = true
    end
    self.system = system
    self.is_finish = false
    self.is_final = is_final
    local b = self.system.boss
    b.cards = cards or {}
    b.card_num = 0
    b.sc_left = 0
    b.last_card = 0
    for i = 1, #b.cards do
        if b.cards[i].is_combat then
            b.last_card = i
        end
        b.sc_left = b.sc_left + 1--非符和符卡一起标星
    end
    self:next()
end

---执行符卡
---@param card boss.card @要执行的符卡
---@param final boolean @是否为终符
function CardsSystem:doCard(card, final)
    self.system:doCard(card, final and self.is_final)
end

---执行下一张符卡
function CardsSystem:next()
    local b = self.system.boss
    b.card_num = b.card_num + 1
    if not (b.cards[b.card_num]) then
        self.is_finish = true
        return false
    end
    self:doCard(b.cards[b.card_num], b.card_num == b.last_card)
    return true
end

local item, lstg, task, object, ran = item, lstg, task, object, ran
local cos, sin, int = cos, sin, int
local max, min = max, min
local IsValid = IsValid
local New = New
local table = table
local math = math

---@class boss.system
boss.system = plus.Class()
local system = plus.Class()
boss.system = system
---boss系统初始化函数
---@param b object @目标boss
---@param cards table|nil @目标执行符卡组（可不设置）
---@param bg object|nil @boss符卡背景（可不设置）
---@param diff string @难度信息
function system:init(b, cards, bg, diff, scname)
    self.boss = b
    --b.name = name --显示名称
    b.name = scname
    b.self_color = { 0, 0, 0 }--可能要用到的颜色，在设置图像里设置
    b.self_color2 = { 0, 0, 0 }--可能要用到的颜色，在设置图像里设置
    b.self_color3 = { 0, 0, 0 }--可能要用到的颜色，在设置图像里设置
    b._bg = bg
    b.bg = nil --符卡背景，前往extboss修改
    b.diff = diff --boss难度
    --boss符卡环
    b.sc_ring_alpha = 255 --符卡环透明度
    --属性设置
    b.difficulty = diff or 'All' --boss难度
    b.dmg_factor = 0 --伤害比例（系统）
    b.DMG_factor = 1 --伤害比例（用户）
    b.sc_pro = 0 --符卡高防剩余帧数
    b.sp_point = {} --血条阶段点位置
    b._sp_point_auto = {} --血条阶段点位置
    b.sc_bonus_max = 2000000 --boss符卡默认最高分
    b.sc_bonus_base = 1000000 --boss符卡默认基础分
    b.t1, b.t2, b.t3 = 0, 0, 0 --boss阶段时间
    b.is_combat = false --是否为战斗阶段
    b.is_sc = false --当前是否为符卡
    b.sc_left = 0 --boss剩余符卡数
    b.spell_damage = 0
    b.__is_waiting = true --boss是否在等待操作

    b.__card_timer = 0 --阶段已进行时长
    b.__hpbar_timer = 0 --血条计时器
    b.__rescore = 0 --符卡分数每帧损失量
    b.__rescore_wait = 300 --符卡分数滑落等待时间
    b.__dieinstantly = false --true时终符结束立刻爆炸
    b.__disallow_100sec = false --true时倒计时显示不超过99.99
    b.ui = New(boss.ui, self, b)
    b.ui_slot = 1
    self.aura = New(boss_aura, b)

    self:resetBonus() --重置bonus
    self.clock = StopWatch()
    if cards then
        self:doCards(cards)
    end
end

---boss系统帧逻辑
function system:frame()
    --执行自身task
    local b = self.boss
    b.__card_timer = b.__card_timer + 1 --更新阶段计时器
    if b.is_combat then
        self:checkHP() --检查血量
    end
    self:checkAutoSPPoint() --检查auto阶段点
    self:doTask() --执行task
    self:updateHPFlags() --更新血条flag
    --出屏判定关闭
    SetAttr(b, 'colli', BoxCheck(b, lstg.world.boundl, lstg.world.boundr, lstg.world.boundb, lstg.world.boundt) and b._colli)
    self:updatePosition() --更新位置指示器
    self:updateBG() --更新符卡背景

    if b.hp < 1145141919810 then
        b.hpbarlen = b.hp / b.maxhp --更新血条长度
    else
        b.hpbarlen = 0
    end
    --符卡逻辑
    if b.current_card then
        b.current_card.frame(b)
    end
    --阶段逻辑
    if not (b.__is_waiting) and b.is_combat then
        --高防时间计算
        b.sc_pro = max(b.sc_pro - 1, 0)
        local nsp = 0
        if player.nextspell > nsp then
            nsp = player.nextspell
        end
        if nsp > 0 and b.timer <= 0 then
            b.sc_pro = nsp
        end
        if b.timer < 60 then
            b.dmg_factor = 0
        elseif b.sc_pro > 0 then
            b.dmg_factor = 0.1
        --elseif b.timer < b.t2 then
       --    b.dmg_factor = (b.timer - b.t1) / (b.t2 - b.t1)
        elseif b.timer < b.t3 then
            b.dmg_factor = 1
        else
            b.hp = 0
            b.timeout = true
        end--]]--搁置老的减伤算法吗？
        --是否为耐久阶段
        if b.t1 == b.t3 then
            b.dmg_factor = 0
            b.time_sc = true
        else
            --自定义时符
            b.time_sc = b._time_sc or false
        end
        --分数流失
        if b.sc_bonus then
            b.sc_bonus = b.sc_bonus - b.__rescore
        end
        --自机spell保护
        if b.is_extra and nsp > 0 then
            b.dmg_factor = 0
        end
        b.countdown = (b.t3 - b.timer) / 60
        if IsValid(b.ui) then
            b.ui.countdown = (b.t3 - b.timer) / 60
        end
        self:checkBonus()
    else
        b.dmg_factor = 0
        b.DMG_factor = 1
        b.time_sc = false
        b.sc_pro = 0
        b.countdown = 0
        if IsValid(b.ui) then
            b.ui.countdown = b.t3
        end
        b.dropitem = nil
        self:clearBonus("all")
    end
end

---boss系统渲染逻辑
function system:render()
    --符卡逻辑
    if self.boss.current_card then
        self.boss.current_card.render(self.boss)
    end
end
---boss系统击破奖励逻辑
function system:KillBonus()
    local b = self.boss
    if b.time_sc or not b.timeout then
        if b.is_sc then
            item.dropItem(item.drop_hp, 1, b.x, b.y)
        end
        DropExpPoint(50, b.x, b.y)
        KillEnemyFunction(b, b.current_card and b.current_card.other_drop)
    end
end

---boss系统击破结算逻辑
function system:kill()
    local b = self.boss
    if b.is_combat then
        b.ui.drawtimesaver = b.countdown
    end
    if b.timeout and not b.time_sc then
        self:clearBonus("all")
    end
    --符卡逻辑
    if b.current_card then
        b.current_card.del(b)
    end
    if b.__card_finish then
        b.__card_finish(b)
        b.__card_finish = nil
    end
    if not b.cannot_kill then
        if not b.__NoPlayerProtect then
            player.protect = player.protect + 60
        end
        self:KillBonus()
        self:refresh(1)
        if b.is_final and not (b.no_killeff) and not (b.killed) then
            self:explode()
        else
            self:popSpellResult()
            if b.is_final then
                object.Del(self)
            else
                self:popResult(true)
                self:refresh(2)
                if self._cards_system then
                    local ref = self._cards_system:next()
                    if not ref then
                        self._cards_system = nil
                    else
                        self:doTask()
                    end
                end
            end
        end
    else
        object.Preserve(self)
        object.Preserve(b)
    end
end

---boss系统消亡逻辑
function system:del()
    local b = self.boss
    if IsValid(lstg.tmpvar.bg) then
        lstg.tmpvar.bg.hide = false
    end
    for i = #boss_group, 1, -1 do
        if boss_group[i] == b then
            table.remove(boss_group, i)
            ext.boss_ui.name = {}
        end
    end
    for _, obj in pairs({ b.ui, b.dialog_displayer }) do
        if IsValid(obj) then
            object.Del(obj)
        end
    end
end

---设置bossUI槽位
---@param slot number @槽位
function system:setUISlot(slot)
    local b = self.boss
    b.ui_slot = slot
end

---boss爆炸自删
function system:explode()
    local b = self.boss
    b.is_exploding = true
    b.killed = true
    b.no_killeff = true
    PlaySound("enep01", 0.3, 0, true)
    b._colli = false
    b.hp = 0
    task.New(b, function()
        local angle = ran:Float(-15, 15)
        local sign, v = ran:Sign(), 1.5
        local lifetime, l
        b.lr = sign * 28
        b.vx = sign * v * cos(angle)
        b.vy = v * sin(angle)
        if not b.__NoCleanBullet then
            New(bullet_cleaner, b.x, b.y, 3000, 120, 60, true, true, 0)
        end
        if not b.__dieinstantly then
            for _ = 1, 60 do
                v = v * 0.98
                b.vx = sign * v * cos(angle)
                b.vy = v * sin(angle)
                b.hp = 0
                b.timer = b.timer - 1
                lifetime = ran:Int(60, 90)
                l = ran:Float(100, 250)
                New(boss_death_ef_unit, b.x, b.y, l / lifetime, math.random() * 360, lifetime, math.random() + 2, "cherry_bullet")
                task.Wait()
            end
        end
        PlaySound("enep01", 0.2, b.x / 256, true)
        if not b.__no_drop_explode_cherry then
            New(boss_explode_cherry, b.x, b.y)
            if lstg.var._season_system and lstg.weather.QiuShuang then
                New(boss_explode_maple, b.x, b.y)
            end
        end
        self:popSpellResult()
        self:popResult(false)
    end)
end

---执行task
function system:doTask()
    task.Do(self)
    task.Do(self.boss)
end

---检查血量
function system:checkHP()
    local b = self.boss
    b.hp = max(b.hp, 0) --血量下限
    if b.hp <= 0 then
        if not (b.killed) then
            if not b.cannot_kill then
                object.Kill(b)
            else
                self:kill()
            end
        end
    end
end

---增加一个auto阶段点
---@param dmg number @目标损失血量
---@param timer number @目标计时器
---@param current boolean @是否使用真实帧数计时
function system:addAutoSPPoint(dmg, timer, current)
    local b = self.boss
    if b._sp_point_auto == nil then
        b._sp_point_auto = {}
    end
    table.insert(b._sp_point_auto, { dmg = dmg, timer = timer, current = current, })
end

---检查auto阶段点
function system:checkAutoSPPoint()
    local b = self.boss
    local p, flag
    for i = #b._sp_point_auto, 1, -1 do
        p = b._sp_point_auto[i]
        if b.maxhp - b.hp >= p.dmg then
            flag = true
        elseif p.timer then
            if p.current and b.__card_timer >= p.timer then
                flag = true
            elseif not (p.current) and b.timer >= p.timer then
                flag = true
            end
        end
        if flag then
            table.remove(b._sp_point_auto, i)
        end
    end
end

---更新位置指示器
function system:updatePosition()
    local b = self.boss
    if IsValid(b.ui) then
        b.ui.pointer_x = b.x
    end
    b.pointer_x = b.x
end

---更新血条Flag
function system:updateHPFlags()
    local b = self.boss
    if not b.__is_waiting then
        b.__hpbar_timer = b.__hpbar_timer + 1
    else
        b.__hpbar_timer = -1
    end
end

---更新符卡背景
function system:updateBG()
    local b = self.boss
    if b.hp <= 0 then
        return
    end
    if b.bg and not b.is_subBoss then
        --副boss，额外出现的boss
        if IsValid(b.bg) then
            if b.__show_scbg then
                b.bg.alpha = min(b.bg.alpha + 0.025, 1)
            else
                b.bg.alpha = max(b.bg.alpha - 0.025, 0)
            end
        end
        if lstg.tmpvar.bg then
            if IsValid(b.bg) and b.bg.alpha == 1 then
                lstg.tmpvar.bg.hide = true
            else
                lstg.tmpvar.bg.hide = false
            end
        end
    end
end

---刷新bonus
function system:resetBonus()
    local b = self.boss
    b.chip_bonus = true
    b.bombchip_bonus = true
    b.sc_pro = player.nextspell
    if b.is_sc then
        self:setScore(b.sc_bonus_max)
    else
        self:setScore(nil)
    end
end

---移除bonus
---@param type string @取消类型
function system:clearBonus(type)
    local b = self.boss
    if type == "all" or type == nil then
        b.chip_bonus = false
        b.bombchip_bonus = false
    elseif type == "hit" then
        b.chip_bonus = false
    elseif type == "spell" then
        b.bombchip_bonus = false
    end
    if b.sc_bonus then
        b.sc_bonus = nil
    end
end

---检查bonus
function system:checkBonus()
    local b = self.boss
    local p = player
    local death, nsp = 0, 0
    if p.death > death then
        death = p.death
    end
    if p.nextspell > nsp then
        nsp = p.nextspell
    end
    if death > 0 then
        self:clearBonus("hit")
    end
    if b.sc_pro <= 0 and nsp > 0 then
        self:clearBonus("spell")
    end
end

local time_rate = 60

---符卡收卡奖励
function system:GetBonus(b)
    DropExpPoint(50, b.x, b.y)
    -- lstg.var.getsc = lstg.var.getsc + 1
    if b.current_card and b.current_card.other_bonus_drop then
        b.current_card.other_bonus_drop(b)
    end
    local v = lstg.var
    if v.getCard_dec_chaos then
        player_lib.AddChaos(-8)
    end
end

---检测是否收卡
function system:CheckGetCard()
    local b = self.boss
    if b.is_sc then
        if b.chip_bonus and b.bombchip_bonus and b.sc_bonus then
            if b.hp <= 0 then
                self:GetBonus(b)
                b._getcard = true
                b._getscore = b.sc_bonus
            elseif b.timeout and b.time_sc then
                self:GetBonus(b)
                b._getcard = true
                b._getscore = b.sc_bonus
            else
                b._getcard = false
                b._getscore = 0
            end
        else
            b._getcard = false
            b._getscore = nil
            b._timeout = b.timeout
        end
    else
        if b.chip_bonus and b.bombchip_bonus then
            if b.hp <= 0 then
                -- lstg.var.getsc = lstg.var.getsc + 1
                b._getcard = true
            elseif b.timeout and b.time_sc then
                lstg.var.getsc = lstg.var.getsc + 1
                b._getcard = true
            else
                b._getcard = false
            end
            b._timer = b.timer
        else
            b._getcard = false
            b._timeout = b.timeout
        end
    end
    self:finishSpellHist(b._getcard)
end

---只以是否死亡来检测收卡
function system:SpecialCheckGetCard()
    local b = self.boss
    if b.chip_bonus and b.bombchip_bonus then
        lstg.var.getsc = lstg.var.getsc + 1
        b._getcard = true
    end
    self:finishSpellHist(b._getcard)
    return true
end

---符卡结算
function system:popSpellResult()
    local b = self.boss
    self:CheckGetCard()
    b._timer = b.timer
    local t = self.clock:GetElapsed() * time_rate
    b._real_timer = t
    b.timeout = nil

    local c = {
        finish = true, --阶段是否已结束
        is_sc = b.is_sc, --阶段是否为符卡
        sc_name = b.sc_name, --阶段符卡名
        time_sc = b.time_sc, --阶段是否为耐久
        getcard = b._getcard, --阶段是否收取
        timeout = b._timeout, --阶段是否超时
        score = b._getscore, --阶段获取分数
        chip = { b.chip_bonus, b.bombchip_bonus }, --阶段获取碎片
        timer = b._timer, --阶段结束时timer
        current_timer = b.__card_timer, --阶段结束时真实timer
        damage = b.spell_damage, --阶段伤害总计
        real_timer = b._real_timer, --真实系统时间
        boss_x = b.x,
        boss_y = b.y,
    }
    if b._transport then
        --boss设置了这个表后会在阶段结束时传递阶段结果到这个表并断开连接
        for k, v in pairs(c) do
            b._transport[k] = v
        end
        b._transport = nil
    end
    if b.__getspellbonus then
        --结算bonus
        self:resultSpell(c)
        b.__getspellbonus = nil
    end
    b.spell_damage = 0
end

---创建一个符卡数据记录信息
---@param name string @符卡名称
---@param diff string @难度信息
---@param player string @自机信息
function system:startSpellHist(name, diff, player)
    --[[
   diff = diff or "All"
   player = player or "All"
   local b = self.boss

   local hist = spell_card_data
   if not ext.replay.IsReplay() then
       hist[name][player][2] = hist[name][player][2] + 1
   end
   b.spellcard_hist = { name = name, diff = diff, player = player }
   b._sc_hist = hist[name][player]
   if IsValid(b.ui) then
       b.ui.sc_hist = hist[name][player]
   end--]]
end

---结束符卡数据信息
---@param getcard boolean @是否收取符卡
function system:finishSpellHist(getcard)
    --[[
    local b = self.boss
    if b.spellcard_hist then
        local h = b.spellcard_hist
        if getcard and not ext.replay.IsReplay() then
            spell_card_data[h.name][h.player][1] = spell_card_data[h.name][h.player][1] + 1
        end
        b.spellcard_hist = nil
        b.last_sc_hist = spell_card_data[h.name][h.player]
    end--]]
end

---刷新boss状态
---@param part number @阶段
function system:refresh(part)
    local b = self.boss
    object.Preserve(b)
    if not part or part == 1 then
        object.KillServants(b)
        task.Clear(self)
        task.Clear(b)
        --self.vx, self.vy = 0, 0
        b.vx, b.vy = 0, 0
    end
    if not part or part == 2 then
        b.t1, b.t2, b.t3 = 0, 0, 0
        b.is_combat = false
        b.is_sc = false
        b._time_sc = nil--自定义时符
        b.sp_point = {}
        b._sp_point_auto = {}
        b.__is_waiting = true
    end
end

---结算并重置状态以便执行下一阶段
---@param continue boolean @是否保留对象
function system:popResult(continue)
    local b = self.boss
    if b.dropitem then
        --  item.Dropitem_PFP(b.x, b.y, b.dropitem)
        b.dropitem = nil
    end
    b.sc_left = max(b.sc_left - 1, 0)
    self:setIsSpellcard(false)
    self:setSCName("")
    self:setIsWaiting(true)
    --结束符卡后是否需要清除子弹
    if b.no_clear_buller then
        b.no_clear_buller = nil
    elseif b.is_combat then
        PlaySound('enep02', 0.4, 0)
        if not b.__NoCleanBullet then
            --New(bullet_killer, player.x, player.y, true)
            New(bullet_cleaner, player.x, player.y, 800, 40, 40, true, true, 0, 0)
        end
    end
    if b.is_final or not continue then
        object.Del(b)
    end
    if continue then
        self:setDamageRate(1)
        self:resetTimer()
        enemybase.init(b, 999999999)
        self:resetBonus()
    end
end

---结算分数等
---@param info table @数据信息
function system:resultSpell(info)
    local yoffset = { 112, 24, 8, -8 }
    local hist = self.boss.last_sc_hist
    if info.is_sc then
        if info.getcard then
            local score = info.score - info.score % 10
            lstg.var.score = lstg.var.score + score
            PlaySound('cardget', 1.0, 0)
            New(hinter_bonus, 'hint.getbonus', 0.6, 0, yoffset[1], 15, 120, true, score)
            New(kill_timer, 0, yoffset[2], info.current_timer)
            New(kill_timer2, 0, yoffset[3], info.real_timer)
            --   New(card_percent, 0, yoffset[4], hist[1] / hist[2] - (hist[1] - 1) / max(hist[2] - 1, 1))
        else
            if info.timeout and not (info.time_sc) then
                PlaySound('fault', 1.0, 0)
            end
            New(hinter, 'hint.bonusfail', 0.6, 0, yoffset[1], 15, 120)
            New(kill_timer, 0, yoffset[2], info.current_timer)
            New(kill_timer2, 0, yoffset[3], info.real_timer)
            --New(card_percent, 0, yoffset[4], hist[1] / hist[2] - hist[1] / max(hist[2] - 1, 1))
        end
    end
end

---宣言符卡
---@param name string @符卡名
function system:castcard(name)
    local b = self.boss
    self:setIsSpellcard(true)
    self:setSCName(name)
    self:resetBonus()

    New(spell_card_ef)
    PlaySound('cat00', 0.5)
    b.card_timer = -1
    if IsValid(b._sc_name_obj) then
        object.Kill(b._sc_name_obj)
    end
    b._sc_name_obj = New(boss.sc_name, b, name)
    object.Connect(b, b._sc_name_obj, 0, true)
end

---设置血量
---@param maxhp number @最大血量
---@param hp number @血量
function system:setHP(maxhp, hp)
    self.boss.maxhp, self.boss.hp = maxhp, hp or maxhp
end

---设置掉落物
---@param itemtable table @掉落物表
function system:setDropitem(itemtable)
    self.boss.dropitem = itemtable
end

---设置是否不吃雷
---@param is_extra boolean @是否免疫自机符卡
function system:setIsExtra(is_extra)
    self.boss.is_extra = is_extra
end

---设置是否是最后阶段
---@param is_final boolean @是否为最后一张
function system:setIsFinal(is_final)
    self.boss.is_final = is_final
end

---重置timer
function system:resetTimer()
    local b = self.boss
    b.timer = -1
    b.__card_timer = 0
    b.__hpbar_timer = 0
    self.clock:Reset()
end

---设置阶段时间
---@param t1 number @无敌时间
---@param t2 number @防御时间
---@param t3 number @总时间
function system:setStatusTime(t1, t2, t3)
    local b = self.boss
    if t1 > t2 or t2 > t3 then
        error('t1<=t2<=t3 must be satisfied.')
    end
    b.t1, b.t2, b.t3 = int(t1 * 60), int(t2 * 60), int(t3 * 60)
end

---设置是否为符卡
---@param is_sc boolean @是否为符卡
function system:setIsSpellcard(is_sc)
    self.boss.is_sc = is_sc
    self.boss.__show_scbg = true
end

---设置是否为战斗阶段
---@param is_combat boolean @是否为战斗阶段
function system:setIsCombat(is_combat)
    self.boss.is_combat = is_combat
end

---设置是否在等待阶段
---@param is_waiting boolean @是否为等待阶段
function system:setIsWaiting(is_waiting)
    self.boss.__is_waiting = is_waiting
end

---设置是否显示符卡背景
---@param open boolean @是否显示符卡背景
function system:openSCBackground(open)
    self.boss.__show_scbg = open
end

---设置是否显示符卡环
---@param open boolean @是否显示符卡环
function system:openSCRing(open)
    self.boss.__draw_sc_ring = open
end

---设置是否有结算bonus
---@param open boolean @是否结算bonus
function system:openSCBonus(open)
    self.boss.__getspellbonus = open
end

---设置符卡名
---@param name string @符卡名
function system:setSCName(name)
    local b = self.boss
    b.sc_name = name
    if IsValid(b.ui) then
        b.ui.sc_name = name
    end
end

---设置符卡分数
---@param score number @符卡分数
---@param rescore number @符卡分数每帧损失量
function system:setScore(score, rescore)
    self:setCurScore(score)
    self:setScoreMiss(rescore)
end

---设置当前符卡分数
---@param score number @符卡分数
function system:setCurScore(score)
    self.boss.sc_bonus = score
end

---设置符卡分数滑落速度
---@param rescore number @符卡分数每帧损失量
function system:setScoreMiss(rescore)
    self.boss.__rescore = rescore or 0
end

---设置符卡分数滑落等待时长
---@param t number @等待时长
function system:setScoreWait(t)
    self.boss.__rescore_wait = int(t)
end

---设置伤害比率
---@param rate number @伤害比率
function system:setDamageRate(rate)
    self.boss.DMG_factor = rate or 1
end

---设置属性
---@param maxhp number @最大生命值
---@param is_extra boolean @是否免疫自机符卡
---@param is_final boolean @是否为最后一张
---@param ret boolean @是否重置timer
---@param t1 number @无敌时间
---@param t2 number @防御时间
---@param t3 number @总时间
---@param is_sc boolean @是否为符卡
---@param sc_bg boolean @是否渲染符卡背景
---@param sc_ring boolean @是否渲染符卡环
function system:setStatus(maxhp, is_extra, is_final, ret, t1, t2, t3, is_sc, sc_bg, sc_ring)
    if sc_bg == nil then
        sc_bg = is_sc
    end
    if sc_ring == nil then
        sc_ring = is_sc
    end
    local b = self.boss
    self:setHP(maxhp)
    -- self:setDropitem(dropitem)
    self:resetBonus()
    self:setIsExtra(is_extra)
    self:setIsFinal(is_final)
    if ret then
        self:resetTimer()
    end
    self:setStatusTime(t1, t2, t3)
    self:setIsSpellcard(is_sc)
    self:setIsCombat(true)
    self:setIsWaiting(false)
    self:openSCBackground(sc_bg)
    self:openSCRing(sc_ring)
    b.countdown = b.t3
    if IsValid(b.ui) then
        b.ui.countdown = b.t3
    end
end

---执行符卡
---@param card boss.card @要执行的符卡
---@param is_final boolean @是否为最后一张
---@param sc_bg boolean @是否渲染符卡背景
---@param sc_ring boolean @是否渲染符卡环
---@param score boolean @是否有score
---@param sc_bonus boolean @是否有符卡奖励结算
function system:doCard(card, is_final, sc_bg, sc_ring, score, sc_bonus)
    local b = self.boss
    score = score or card.is_sc
    sc_bonus = sc_bonus or card.is_sc
    b.current_card = card
    task.New(self, function()
        if card.before then
            self:openSCBackground(false)
            local t = task.New(b, function()
                card.before(b)
            end)
            while coroutine.status(t) ~= 'dead' do
                task.Wait()
            end
        end
        if card.is_sc then
            self:castcard(card.name)
            if score then
                self:startSpellHist(card.card_id, b.diff, lstg.var.player_name)
                task.New(self, function()
                    local t = b.__rescore_wait
                    task.Wait(t)
                    if b.sc_bonus ~= nil then
                        self:setScore(b.sc_bonus_max)
                    end
                    if card.t1 ~= card.t3 then
                        self:setScoreMiss((b.sc_bonus_max - b.sc_bonus_base) / (card.t3 - t))
                    end
                end)
            end
            self:openSCBonus(sc_bonus)
        else
            self:startSpellHist(card.card_id, b.diff, lstg.var.player_name)
        end
        local t3 = card.t3
        if lstg.weather.BiShi and card.t1 ~= t3 then
            t3 = max(card.t2, 20 * 60)
        end--彼世天气，非时符符卡总时间下降
        self:setStatus(card.hp, card.is_extra, is_final, true,
                card.t1 / 60, card.t2 / 60, t3 / 60, card.is_sc, sc_bg, sc_ring)
        self:setIsCombat(card.is_combat)
        card.init(b)
    end)
end

---执行符卡组
---@param cards table @要执行的符卡组
---@param is_final boolean @是否执行完删除boss
function system:doCards(cards, is_final)
    self._cards_system = CardsSystem(self, cards, is_final)
end