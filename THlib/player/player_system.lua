local ObjList = ObjList
local Dist = Dist
local Forbid = clamp

local defaultKeys = {
    "up", "down", "left", "right",
    "slow", "shoot", "spell", "special", "change",
}
local defaultKeyEvent = {
    { "up", "down", "key.up.down", 0, function(self)
        self.__up_flag = true
        self.__up_counting = self.__up_counting + 1
    end },
    { "up", "up", "key.up.up", 0, function(self)
        self.__up_flag = false
        self.__up_counting = 0
    end },
    { "down", "down", "key.down.down", 0, function(self)
        self.__down_flag = true
        self.__down_counting = self.__down_counting + 1
    end },
    { "down", "up", "key.down.up", 0, function(self)
        self.__down_flag = false
        self.__down_counting = 0
    end },
    { "left", "down", "key.left.down", 0, function(self)
        self.__left_flag = true
        self.__left_counting = self.__left_counting + 1

    end },
    { "left", "up", "key.left.up", 0, function(self)
        self.__left_flag = false
        self.__left_counting = 0
    end },
    { "right", "down", "key.right.down", 0, function(self)
        self.__right_flag = true
        self.__right_counting = self.__right_counting + 1
    end },
    { "right", "up", "key.right.up", 0, function(self)
        self.__right_flag = false
        self.__right_counting = 0
    end },
    { "slow", "down", "key.slow.down", 0, function(self)
        if not lstg.var.forbid_slow then
            self.__slow_flag = true
        end
    end },
    { "slow", "up", "key.slow.up", 0, function(self)
        self.__slow_flag = false
    end },
    { "shoot", "down", "key.shoot.down", 0, function(self)
        self.__shoot_flag = true
        self.__shoot_delay = 15
    end },
    { "shoot", "up", "key.shoot.up", 0, function(self)
        if self.__shoot_delay <= 0 then
            self.__shoot_flag = false
        end
    end },
    { "spell", "down", "key.spell.down", 0, function(self)
        self.__spell_flag = true
    end },
    { "spell", "up", "key.spell.up", 0, function(self)
        self.__spell_flag = false
        self.__have_spell = false
    end },
    { "special", "down", "key.special.down", 0, function(self)
        self.__special_flag = true
    end },
    { "special", "up", "key.special.up", 0, function(self)
        self.__special_flag = false
        self.__have_special = false
    end },
}
local defaultFrameEvent = {
    ["frame.updateDeathState"] = { 100, function(self)
        if (self.death == 0 or self.death > 90) and (not self.lock) and not (self.time_stop) then
            self.__death_state = 0
        elseif self.death == 90 then
            self.__death_state = 1
        elseif self.death == 84 then
            self.__death_state = 2
        elseif self.death == 50 then
            self.__death_state = 3
        elseif self.death < 50 and not (self.lock) and not (self.time_stop) then
            self.__death_state = 4
        else
            self.__death_state = -1
        end
    end },
    ["frame.updateSlow"] = { 99, function(self)
        if self.__slow_flag then
            self.slow = 1
        else
            self.slow = 0
        end
    end },
    ["frame.control"] = { 98, function(self, system)
        if not self.dialog then
            if self.__shoot_flag and self.nextshoot <= 0 and not lstg.var.stop_shoot then
                system:shoot()
            end
            if self.__spell_flag and self.nextspell <= 0 and not self.__have_spell then
                system:spell()
                self.__have_spell = true
            end
            local acList = lstg.var.active_item
            local ActiveID = acList[1]

            if ActiveID then
                local using_flag = false
                local active = activeItem_lib.ActiveTotalList[ActiveID]
                if active then
                    if active.hold then
                        if self.__special_flag and self.nextsp <= 0 then
                            using_flag = system:special()
                            --self.__have_special = true

                        end
                    else
                        if self.__special_flag and self.nextsp <= 0 and not self.__have_special then
                            using_flag = system:special()
                            self.__have_special = true
                        end
                    end
                    active:SetUsing(using_flag)
                end
            end
            if #acList >= 2 then
                if system:keyIsPressed("change") then
                    activeItem_lib.ChangeActive()
                end
            end
            for i = 1, #acList do
                local active = activeItem_lib.ActiveTotalList[acList[i]]
                if i >= 2 then
                    active:SetUsing(false)
                end
                active:normal_function()
            end
        else
            self.nextshoot = 15
            self.nextspell = 30
        end
    end },
    ["frame.move"] = { 97, function(self)
        local dx, dy = 0, 0
        local left, right, up, down
        local lc, rc, uc, dc = self.__left_counting, self.__right_counting, self.__up_counting, self.__down_counting
        if not self.lock then
            local hspeed, lspeed = self.cur_hspd, self.cur_lspd
            if self.stop_move then
                hspeed = 0
                lspeed = 0
            end
            local v = hspeed
            if self.slowlock then
                self.slow = 1
            end
            if self.slow == 1 then
                v = lspeed
            end
            v = v
            if lstg.weather.NiZhuan and not lstg.var.reverse_shoot then
                v = -v
            end
            up = self.__up_flag
            down = self.__down_flag
            left = self.__left_flag
            right = self.__right_flag
            if uc > dc and dc > 0 then
                down = true
                up = false
            end
            if dc > uc and uc > 0 then
                up = true
                down = false
            end
            if lc > rc and rc > 0 then
                right = true
                left = false
            end
            if rc > lc and lc > 0 then
                left = true
                right = false
            end
            dx = dx - (left and 1 or 0)
            dx = dx + (right and 1 or 0)
            dy = dy + (up and 1 or 0)
            dy = dy - (down and 1 or 0)
            if dx * dy ~= 0 then
                v = v * SQRT2_2
            end
            dx = v * dx
            dy = v * dy
            local w = lstg.world
            self.x = Forbid(self.x + dx, w.pl + 8 - self.borderless_offset, w.pr - 8 + self.borderless_offset)
            self.y = Forbid(self.y + dy, w.pb + 16 - self.borderless_offset, w.pt - 32 + self.borderless_offset)
            if lstg.var.borderless_moving then
                if BoxCheck(self, w.pl + 8, w.pr - 8, w.pb + 16, w.pt - 32) then
                    self.borderless_offset = min(100, 1 + self.borderless_offset)
                    self.outborder_time = 0
                else
                    self.borderless_offset = max(0, self.borderless_offset - self.outborder_time / 20)
                    self.outborder_time = self.outborder_time + 1
                end
            end

        end
        self.__move_dx = dx
        self.__move_dy = dy
    end },
    ["frame.fire"] = { 96, function(self)
        if self.__shoot_flag and not self.dialog then
            self.fire = self.fire + 0.16
        else
            self.fire = self.fire - 0.16
        end
        if self.fire < 0 then
            self.fire = 0
        end
        if self.fire > 1 then
            self.fire = 1
        end
    end },
    ["frame.itemCollect"] = { 95, function(self)
        local C = self.getItem_r
        if self.slow then
            C = C * 1.5
        end
        for _, o in ObjList(GROUP.ITEM) do
            if Dist(self, o) < C + o.a then
                o.get_player = true
                o.attract = 4.5
                o.target = self
            end
        end
        if self.y > self.collect_line then
            for _, o in ObjList(GROUP.ITEM) do
                if o.attract then
                    local flag = false
                    if o.attract < 8 then
                        flag = true
                    elseif o.attract == 10 and o.target ~= self then
                        if (not o.target) or o.target.y < self.y then
                            flag = true
                        end
                    end
                    if flag then

                        o.attract = 10
                        o.num = self.item
                        o.target = self
                    end
                end
            end
        end
    end },
    ["frame.updateVar"] = { 94, function(self)

        self.nextshoot = max(self.nextshoot - 1, 0)
        self.nextspell = max(self.nextspell - 1, 0)
        self.nextsp = max(self.nextsp - 1, 0)
        self.__shoot_delay = max(self.__shoot_delay - 1, 0)
        self.supportx = self.x + (self.supportx - self.x) * 0.6875
        self.supporty = self.y + (self.supporty - self.y) * 0.6875
        self.protect = max(self.protect - 1, 0)
        self.death = max(self.death - 1, 0)
    end },


}

---@class player.system
local system = plus.Class()
player_lib.system = system
function system:init(p)
    self.player = p

    p.hspeed = p.hspeed or 4
    p.lspeed = p.lspeed or 2
    p.collect_line = p.collect_line or 96
    p.slow = p.slow or 0
    p.A = p.A or 0
    p.B = p.B or 0
    p.fire = p.fire or 0
    p.lock = p.lock or false
    p.dialog = p.dialog or false
    p.nextshoot = p.nextshoot or 0
    p.nextspell = p.nextspell or 0
    p.nextsp = p.nextsp or 0
    p.item = p.item or 1
    p.death = p.death or 0
    p.protect = p.protect or 120
    p.grazer = p.grazer or New(grazer, p)
    p.getItem_r = p.getItem_r or 30
    p.stop_move = false

    p.time_stop = p.time_stop or false
    p.__death_state = 0 --自机状态
    p.supportx = p.supportx or p.x
    p.supporty = p.supporty or p.y
    p.__move_dx = 0 --本帧操作移动x距离
    p.__move_dy = 0 --本帧操作移动y距离
    p.__up_counting, p.__down_counting, p.__left_counting, p.__right_counting = 0, 0, 0, 0
    p.__shoot_delay = 0
    p.killflag = true
    self.listener = eventListener()
    self._keys = {}
    self._keys_remove = {}
    self.keyState = {}
    self.keyStatePre = {}
    for _, key in ipairs(defaultKeys) do
        self:regKeys(key)
    end
    for _, event in ipairs(defaultKeyEvent) do
        self:addKeyEvent(unpack(event))
    end
    for name, event in pairs(defaultFrameEvent) do
        self:addFrameEvent(name, unpack(event))
    end

    p.borderless_offset = 0--月与海的传送门
    p.outborder_time = 0

    local _uv1, _uv2, _uv3, _uv4 = { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }
    local w = lstg.world
    local _color = Color(255, 255, 255, 255)
    _uv1[1], _uv1[2] = w.l, w.t
    _uv2[1], _uv2[2] = w.r, w.t
    _uv3[1], _uv3[2] = w.r, w.b
    _uv4[1], _uv4[2] = w.l, w.b
    _uv1[4], _uv1[5] = WorldToScreen(w.l, w.t)
    _uv2[4], _uv2[5] = WorldToScreen(w.r, w.t)
    _uv3[4], _uv3[5] = WorldToScreen(w.r, w.b)
    _uv4[4], _uv4[5] = WorldToScreen(w.l, w.b)
    _uv1[6] = _color
    _uv2[6] = _color
    _uv3[6] = _color
    _uv4[6] = _color
    self.player_tex_uv = { _uv1, _uv2, _uv3, _uv4 }
    self.rendert = "player_tex"
    CreateRenderTarget(self.rendert)
end

---帧逻辑事件
function system:frame()
    local p = self.player
    p.grazer.world = p.world
    if p.lock then
        p.timer = p.timer - 1
    else
        self:updateKeyState() --更新自机按键状态（之后应改为外部调用）
        self:findTarget() --更新target目标
        self:doFrameEvent() --执行帧逻辑事件
    end
    if not p._wisys then
        p._wisys = PlayerWalkImageSystem(p)
    end
    p._wisys:frame((p.lock) and 0 or p.__move_dx)
end

---渲染事件
function system:render()
    local p = self.player
    if self.renderfunc then
        PushRenderTarget(self.rendert)
        RenderClear(Color(0, 0, 0, 0))
        p._wisys:render()
        PopRenderTarget(self.rendert)
        self.renderfunc()
    else
        p._wisys:render()
    end
end

---Shoot事件
function system:shoot()
    local p = self.player
    local v = lstg.var
    if p.class.shoot then
        p.class.shoot(p)
    else
        player_class.shoot(p)
    end
end

function system:spell()
    local p = self.player
    player_class.spell(p)
end

function system:special()
    local p = self.player
    return player_class.special(p)
end

---更新target目标
function system:findTarget()
    local p = self.player
    if not IsValid(p.target) or not p.target.colli then
        player_class.findtarget(p)
    end
    --[[
    if not self:keyIsDown("shoot") then
        p.target = nil
    end--]]
end

---碰撞回调事件
function system:colli(other)
    local p = self.player
    local v = lstg.var
    local tvar = lstg.tmpvar
    local w = lstg.weather
    local group = other.group
    if not p.colli or other._no_colli or w.BiShi then
        return
    end
    if p.death == 0 and not p.dialog and not cheat then
        if p.protect <= 0 then
            if other.IsBoss and not other.is_combat then
                --在没有战斗的时候不判定体术
                return
            end
            local dmg_type_dict = {
                [GROUP.ENEMY] = "IsEnemy",
                [GROUP.ENEMY_BULLET] = "IsBullet",
                [GROUP.LASER] = "IsLaser",
            }
            local IsEnemy = group == GROUP.ENEMY
            if v.goldenbody and IsEnemy then

            else
                local num = 0
                if IsEnemy then
                    num = other.A or other.a
                    num = num * 0.35
                    mission_lib.GoMission(9, 1 / 5 * 100)
                end
                if not num or num == 0 then
                    num = 3
                end
                if other.pdmg then
                    num = other.pdmg
                end
                if group == GROUP.LASER or group == GROUP.ENEMY_BULLET then
                    if v._season_system then
                        if w.ShuangJiang then
                            w.ShuangJiang_speed_low = w.ShuangJiang_speed_low + 1
                        end
                        if w.QiuShi then
                            player_lib.AddMaxLife(1.5)
                        end
                        if w.FengXuYun then
                            num = -num
                        end
                    end
                end
                if group == GROUP.ENEMY_BULLET then
                    if v.cyoltose and not tvar.cyoltose_style then
                        if other.imgclass and other._index then
                            num = 0
                            tvar.cyoltose_style = other.imgclass
                            tvar.cyoltose_color = other._index
                            PlaySound("cyoltose")
                            local R, G, B = unpack(ColorList[math.ceil(tvar.cyoltose_color / 2)])
                            Newcharge_out(p.x, p.y, R, G, B, true)
                            p.protect = max(p.protect, 2)
                        end
                    end
                end

                scoredata._total_miss = scoredata._total_miss + 1
                mission_lib.GoMission(40, 1 / 50 * 100)
                if num ~= 0 then
                    player_lib.PlayerMiss(p, num, other.dmg_type or dmg_type_dict[group])
                end

            end

        end
        if group == GROUP.LASER and not other.IsBentLaser and other.alpha > 0.999 then
            laser.CutOnUnit(other, p)
        end
        if group == GROUP.ENEMY_BULLET then
            object.Del(other)
        end
    end
    self:doColliAfterEvent(other)
end

---注册一个按键
---@param key string @目标按键标识名
function system:regKeys(key)
    self._keys[key] = true
    self._keys_remove[key] = nil
end

---解除注册一个按键
---@param key string @目标按键标识名
function system:unregKeys(key)
    if self._keys[key] then
        self._keys_remove[key] = true
        self._keys[key] = nil
    end
end

---更新自机按键状态
function system:updateKeyState()
    local p = self.player
    local keyState = p.key or KeyState
    local Do = self.doKeyEvent
    if self.stopUpdateKey then
        return
    end
    for key in pairs(self._keys) do
        --更新已注册按键状态并执行事件组
        self.keyStatePre[key] = self.keyState[key]
        self.keyState[key] = keyState[key] or false
        if self.keyState[key] then
            if self.keyStatePre[key] then
                Do(self, key, "hold") --保持按住
            else
                Do(self, key, "press") --按下
            end
            Do(self, key, "down") --按住（包括按下）
        else
            if self.keyStatePre[key] then
                Do(self, key, "release") --抬起
            else
                Do(self, key, "none") --保持抬起
            end
            Do(self, key, "up") --保持抬起（包括抬起）
        end
    end
    for key in pairs(self._keys_remove) do
        --移除解除注册的按键并执行应有的事件组
        if self.keyState[key] then
            Do(self, key, "release") --抬起
            Do(self, key, "up") --保持抬起（包括抬起）
        end
        self.keyStatePre[key] = nil
        self.keyState[key] = nil
        self._keys_remove[key] = nil
    end
end

---获取自身注册按键是否按下
---@param key string @目标按键标识名
---@return boolean
function system:keyIsDown(key)
    if self._keys[key] or self._keys_remove[key] then
        return self.keyState[key]
    end
end

---获取自身注册按键是否在当前帧按下
---@param key string @目标按键标识名
---@return boolean
function system:keyIsPressed(key)
    if self._keys[key] then
        return self.keyState[key] and not self.keyStatePre[key]
    end
end

---添加按键事件
---@param key string @目标按键标识名
---@param state string @目标按键事件
---@param eventName string @按键事件名
---@param eventLevel number @按键事件优先度
---@param eventFunc function @按键事件函数
---@return boolean @是否发生覆盖
function system:addKeyEvent(key, state, eventName, eventLevel, eventFunc)
    return self.listener:addEvent(string.format("keyEvent@%s@%s", key, state),
            eventName, eventLevel, eventFunc)
end

---移除按键事件
---@param key string @目标按键标识名
---@param state string @目标按键事件
---@param eventName string @按键事件名
function system:removeKeyEvent(key, state, eventName)
    self.listener:remove(string.format("keyEvent@%s@%s", key, state), eventName)
end

---执行按键事件
---@param key string @目标按键标识名
---@param state string @目标按键事件
function system:doKeyEvent(key, state)
    self.listener:Do(string.format("keyEvent@%s@%s", key, state), self.player, self)
end

---添加帧逻辑事件（前）
---@param eventName string @事件名
---@param eventLevel number @事件优先度
---@param eventFunc function @事件函数
---@return boolean @是否发生覆盖
function system:addFrameBeforeEvent(eventName, eventLevel, eventFunc)
    return self.listener:addEvent("frameEvent@before", eventName, eventLevel, eventFunc)
end

---移除帧逻辑事件（前）
---@param eventName string @事件名
function system:removeFrameBeforeEvent(eventName)
    self.listener:remove("frameEvent@before", eventName)
end

---执行帧逻辑事件（前）
function system:doFrameBeforeEvent()
    self.listener:Do("frameEvent@before", self.player, self)
end

---添加帧逻辑事件
---@param eventName string @事件名
---@param eventLevel number @事件优先度
---@param eventFunc function @事件函数
---@return boolean @是否发生覆盖
function system:addFrameEvent(eventName, eventLevel, eventFunc)
    return self.listener:addEvent("frameEvent@frame", eventName, eventLevel, eventFunc)
end

---移除帧逻辑事件
---@param eventName string @事件名
function system:removeFrameEvent(eventName)
    self.listener:remove("frameEvent@frame", eventName)
end

---执行帧逻辑事件
function system:doFrameEvent()
    self.listener:Do("frameEvent@frame", self.player, self)
end

---添加帧逻辑事件（后）
---@param eventName string @事件名
---@param eventLevel number @事件优先度
---@param eventFunc function @事件函数
---@return boolean @是否发生覆盖
function system:addFrameAfterEvent(eventName, eventLevel, eventFunc)
    return self.listener:addEvent("frameEvent@after", eventName, eventLevel, eventFunc)
end

---移除帧逻辑事件（后）
---@param eventName string @事件名
function system:removeFrameAfterEvent(eventName)
    self.listener:remove("frameEvent@after", eventName)
end

---执行帧逻辑事件（后）
function system:doFrameAfterEvent()
    self.listener:Do("frameEvent@after", self.player, self)
end

---添加渲染逻辑事件（前）
---@param eventName string @事件名
---@param eventLevel number @事件优先度
---@param eventFunc function @事件函数
---@return boolean @是否发生覆盖
function system:addRenderBeforeEvent(eventName, eventLevel, eventFunc)
    return self.listener:addEvent("renderEvent@before", eventName, eventLevel, eventFunc)
end

---移除渲染逻辑事件（前）
---@param eventName string @事件名
function system:removeRenderBeforeEvent(eventName)
    self.listener:remove("renderEvent@before", eventName)
end

---执行渲染逻辑事件（前）
function system:doRenderBeforeEvent()
    self.listener:Do("renderEvent@before", self.player, self)
end

---添加渲染逻辑事件（后）
---@param eventName string @事件名
---@param eventLevel number @事件优先度
---@param eventFunc function @事件函数
---@return boolean @是否发生覆盖
function system:addRenderAfterEvent(eventName, eventLevel, eventFunc)
    return self.listener:addEvent("renderEvent@after", eventName, eventLevel, eventFunc)
end

---移除渲染逻辑事件（后）
---@param eventName string @事件名
function system:removeRenderAfterEvent(eventName)
    self.listener:remove("renderEvent@after", eventName)
end

---执行渲染逻辑事件（后）
function system:doRenderAfterEvent()
    self.listener:Do("renderEvent@after", self.player, self)
end

---添加碰撞逻辑事件（前）
---@param eventName string @事件名
---@param eventLevel number @事件优先度
---@param eventFunc function @事件函数
---@return boolean @是否发生覆盖
function system:addColliBeforeEvent(eventName, eventLevel, eventFunc)
    return self.listener:addEvent("colliEvent@before", eventName, eventLevel, eventFunc)
end

---移除碰撞逻辑事件（前）
---@param eventName string @事件名
function system:removeColliBeforeEvent(eventName)
    self.listener:remove("colliEvent@before", eventName)
end

---执行碰撞逻辑事件（前）
function system:doColliBeforeEvent(other)
    self.listener:Do("colliEvent@before", self.player, self, other)
end

---添加碰撞逻辑事件（后）
---@param eventName string @事件名
---@param eventLevel number @事件优先度
---@param eventFunc function @事件函数
---@return boolean @是否发生覆盖
function system:addColliAfterEvent(eventName, eventLevel, eventFunc)
    return self.listener:addEvent("colliEvent@after", eventName, eventLevel, eventFunc)
end

---移除碰撞逻辑事件（后）
---@param eventName string @事件名
function system:removeColliAfterEvent(eventName)
    self.listener:remove("colliEvent@after", eventName)
end

---执行碰撞逻辑事件（后）
function system:doColliAfterEvent(other)
    self.listener:Do("colliEvent@after", self.player, self, other)
end

---添加擦弹逻辑事件（前）
---@param eventName string @事件名
---@param eventLevel number @事件优先度
---@param eventFunc function @事件函数
---@return boolean @是否发生覆盖
function system:addGrazingBeforeEvent(eventName, eventLevel, eventFunc)
    return self.listener:addEvent("grazingEvent@before", eventName, eventLevel, eventFunc)
end

---移除擦弹逻辑事件（前）
---@param eventName string @事件名
function system:removeGrazingBeforeEvent(eventName)
    self.listener:remove("grazingEvent@before", eventName)
end

---执行擦弹逻辑事件（前）
function system:doGrazingBeforeEvent(other)
    self.listener:Do("grazingEvent@before", self.player, self, other)
end

---添加擦弹逻辑事件（后）
---@param eventName string @事件名
---@param eventLevel number @事件优先度
---@param eventFunc function @事件函数
---@return boolean @是否发生覆盖
function system:addGrazingAfterEvent(eventName, eventLevel, eventFunc)
    return self.listener:addEvent("grazingEvent@after", eventName, eventLevel, eventFunc)
end
---移除擦弹逻辑事件（后）
---@param eventName string @事件名
function system:removeGrazingAfterEvent(eventName)
    self.listener:remove("grazingEvent@after", eventName)
end
---执行擦弹逻辑事件（后）
function system:doGrazingAfterEvent(other)
    self.listener:Do("grazingEvent@after", self.player, self, other)
end

---添加受击逻辑事件（后）
---@param eventName string @事件名
---@param eventLevel number @事件优先度
---@param eventFunc function @事件函数
---@return boolean @是否发生覆盖
function system:addMissAfterEvent(eventName, eventLevel, eventFunc)
    return self.listener:addEvent("missEvent@after", eventName, eventLevel, eventFunc)
end
---移除受击逻辑事件（后）
---@param eventName string @事件名
function system:removeMissAfterEvent(eventName)
    self.listener:remove("missEvent@after", eventName)
end
---执行受击逻辑事件（后）
function system:doMissAfterEvent()
    self.listener:Do("missEvent@after", self.player, self)
end

---@param eventFunc fun(player:player, system, enemy) @事件函数
function system:addEnemyKillEvent(eventName, eventLevel, eventFunc)
    return self.listener:addEvent("enemyKill", eventName, eventLevel, eventFunc)
end
---移除受击逻辑事件（后）
---@param eventName string @事件名
function system:removeEnemyKillEvent(eventName)
    self.listener:remove("enemyKill", eventName)
end
---执行受击逻辑事件（后）
function system:doEnemyKillEvent(enemy)
    self.listener:Do("enemyKill", self.player, self, enemy)
end