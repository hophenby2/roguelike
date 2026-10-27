---=====================================
---touhou style bent lazer
---=====================================

LoadTexture('laser_bent2', 'assets\\laser\\laser5.png')

----------------------------------------
---bent laser

local bent = Class(object)
bent_laser = bent
function bent:init(index, x, y, l, w, sample, node)
    self.index = index
    self.x = x
    self.y = y
    self.l = max(int(l), 2)
    self.w = w
    self.w0 = w
    self._w = w
    self.group = GROUP.INDES
    self.layer = LAYER.ENEMY_BULLET
    self.data = BentLaserData()
    self.bound = false
    self._bound = true
    self.prex = x
    self.prey = y
    self.listx = {}
    self.listy = {}
    self.node = node or 0
    self._l = int(l / 4)
    self.img4 = 'laser_node' .. self.index
    self.pause = 0
    self.a = 0
    self.b = 0
    self.dw = 0
    self.da = 0
    self.alpha = 1
    self.counter = 0
    self._colli = true
    self.IsLaser = true
    self.IsBentLaser = true
    self.deactive = 0
    self.sample = sample--by OLC，不使用换class来实现
    self._blend, self._a, self._r, self._g, self._b = 'mul+add', 255, 255, 255, 255

    setmetatable(self, {
        __index = GetAttr,
        __newindex = function(t, k, v)
            if k == 'bound' then
                rawset(t, '_bound', v)
            elseif k == 'colli' then
                rawset(t, '_colli', v)
            else
                SetAttr(t, k, v)
            end
        end
    })
end

function bent:frame()
    --by ETC
    task.Do(self)

    SetAttr(self, 'colli', self._colli and self.alpha > 0.999)

    if self.counter > 0 then
        self.counter = self.counter - 1
        self.w = self.w + self.dw
        self.alpha = self.alpha + self.da
    end
    local _l = self._l

    if self.pause > 0 then
        --self.pause=self.pause-1
    else
        if self.timer % 4 == 0 then
            self.listx[(self.timer / 4) % _l] = self.x
            self.listy[(self.timer / 4) % _l] = self.y
        end
        self.data:Update(self, self.l, self.w, self.deactive)
    end

    if self.w ~= self._w then
        bent.setWidth(self, self.w)
        self._w = self.w
    end

    if self.alpha > 0.999 and self._colli then
        if self._colli and self.data:CollisionCheck(player.x, player.y, player.rot, player.A, player.B, player.rect) then
            player.class.colli(player, self)
        end
        if self.timer % 4 == 0 then
            --可改为使用自机圆碰撞判定
            if self._colli and self.data:CollisionCheckWidth(player.grazer.x, player.grazer.y, self.w, player.grazer.rot, player.grazer.a, player.grazer.b, player.grazer.rect) then
                player.grazer.class.colli(player.grazer, self, true)
            end
        end
    end
    if self._bound and not self.data:BoundCheck() and not BoxCheck(self, lstg.world.boundl, lstg.world.boundr, lstg.world.boundb, lstg.world.boundt) then
        object.Del(self)
    end
end

function bent:setWidth(w)
    self.w = w
    self.data:SetAllWidth(self.w)
end

function bent:render()
    --by OLC
    if bent.RenderFunc[self.sample] then
        bent.RenderFunc[self.sample](self)
    end
end

function bent:Del()
    New(bent.death_ef, self.index, self.data, self.sample, self._blend, self._a, self._r, self._g, self._b)
end

function bent:Kill()
    --by ETC
    for i = 0, self._l do
        if self.listx[i] and self.listy[i] then
            New(item.drop_point, self.listx[i], self.listy[i])
            if self.index then
                BulletBreak_Table:New(self.listx[i], self.listy[i], self.index)
            end
        end
    end
    bent.Del(self)
end

--by OLC，通过换函数的方式改变样式
bent.RenderFunc = {
    [0] = function(self)
        self.data:Render('laser_bent2', self._blend, Color(self._a * self.alpha, self._r, self._g, self._b), 0, 32 * (int(0.5 * self.timer) % 4), 256, 32)
        if self.timer < self._l * 4 and self.node then
            SetImageState(self.img4, self._blend, self._a, self._r, self._g, self._b)
            Render(self.img4, self.prex, self.prey, -3 * self.timer, (8 + self.timer % 3) * 0.125 * self.node / 8)
            Render(self.img4, self.prex, self.prey, -3 * self.timer + 180, (8 + self.timer % 3) * 0.125 * self.node / 8)
        end
    end,
    [4] = function(self)
        self.data:Render('laser3', self._blend, Color(self._a * self.alpha, self._r, self._g, self._b), 0, self.index * 16 - 12, 256, 8)
        if self.timer < self._l * 4 and self.node then
            SetImageState(self.img4, self._blend, self._a, self._r, self._g, self._b)
            Render(self.img4, self.prex, self.prey, -3 * self.timer, (8 + self.timer % 3) * 0.125 * self.node / 8)
            Render(self.img4, self.prex, self.prey, -3 * self.timer + 180, (8 + self.timer % 3) * 0.125 * self.node / 8)
        end
    end,
}
bent.RenderFuncDeath = {
    [0] = function(self)
        self.data:Render('laser_bent2', self._blend, Color(self._a * (1 - self.timer / 30), self._r, self._g, self._b), 0, 32 * (int(0.5 * self.timer) % 4), 256, 32)
    end,
    [4] = function(self)
        self.data:Render('laser3', self._blend, Color(self._a * (1 - self.timer / 30), self._r, self._g, self._b), 0, self.index * 16 - 12, 256, 8)
    end,
}


--by OLC，可自由添加激光类型
function bent.Add_texture(id, tex)
    if id ~= 0 and id ~= 4 then
        local w, h = GetTextureSize(tex)
        bent.RenderFunc[id] = function(self)
            self.data:Render(tex, self._blend, Color(self._a * self.alpha, self._r, self._g, self._b), 0, 0, w, h)
            if self.timer < self._l * 4 and self.node then
                SetImageState(self.img4, self._blend, self._a, self._r, self._g, self._b)
                Render(self.img4, self.prex, self.prey, -3 * self.timer, (8 + self.timer % 3) * 0.125 * self.node / 8)
                Render(self.img4, self.prex, self.prey, -3 * self.timer + 180, (8 + self.timer % 3) * 0.125 * self.node / 8)
            end
        end
        bent.RenderFuncDeath[id] = function(self)
            self.data:Render(tex, self._blend, Color(self._a * (1 - self.timer / 30), self._r, self._g, self._b), 0, 0, w, h)
        end
    else
        Print("不能修改默认曲线激光样式")
    end
end
function bent.Add_thunder_texture(id, tex)
    if id ~= 0 and id ~= 4 then
        local w, h = GetTextureSize(tex)
        h = h / 4
        bent.RenderFunc[id] = function(self)
            self.data:Render(tex, self._blend, Color(self._a * self.alpha, self._r, self._g, self._b), 0, h * (int(0.5 * self.timer) % 4), w, h)
            if self.timer < self._l * 4 and self.node then
                SetImageState(self.img4, self._blend, self._a, self._r, self._g, self._b)
                Render(self.img4, self.prex, self.prey, -3 * self.timer, (8 + self.timer % 3) * 0.125 * self.node / 8)
                Render(self.img4, self.prex, self.prey, -3 * self.timer + 180, (8 + self.timer % 3) * 0.125 * self.node / 8)
            end
        end
        bent.RenderFuncDeath[id] = function(self)
            self.data:Render(tex, self._blend, Color(self._a * (1 - self.timer / 30), self._r, self._g, self._b), 0, h * (int(0.5 * self.timer) % 4), w, h)
        end
    else
        Print("不能修改默认曲线激光样式")
    end
end

--by ETC
bent.death_ef = Class(object)
function bent.death_ef:init(index, data, sample, blend, a, r, g, b)
    self.data = data
    self.sample = sample
    self.index = index

    self.group = GROUP.GHOST
    self.bound = false

    self._blend, self._a, self._r, self._g, self._b = blend, a, r, g, b
end
function bent.death_ef:frame()
    if self.timer == 30 then
        self.data:Release()
        object.Del(self)
    end
end
function bent.death_ef:render()
    if bent.RenderFuncDeath[self.sample] then
        bent.RenderFuncDeath[self.sample](self)
    end
end

---对曲线激光按照长度采样，返回一个对象组
---@param l number
function bent:LaserSampleByLength(l)
    return self.data:SampleByLength(l)
end

---对曲线激光按照时间间隔采样（单位：秒），返回一个对象组
---@param l number
function bent:LaserSampleByTime(l)
    return self.data:LaserSampleByTime(l)
end

---使用一个对象组刷新曲线激光的路径，并设置速度和方向,可以接受一个额外的参数revert，用来确定方向,默认情况list中第一个对象是激光头
---@param list table @对象组
---@param rev boolean @是否将自身朝向设置成速度方向
function bent:LaserFormByList(list, rev)
    local l = #list
    if l < 2 then
        object.Del(self)
    end
    self.data = BentLaserData()
    local _l = self._l
    if rev == nil then
        for i = l, 2, -1 do
            self.x = list[i].x
            self.y = list[i].y
            self.timer = self.timer + 1
            if self.timer % 4 == 0 then
                self.listx[(self.timer / 4) % _l] = self.x
                self.listy[(self.timer / 4) % _l] = self.y
            end
            self.data:Update(self, self.l, self.w)
        end
        self.x = list[1].x
        self.y = list[1].y
        self.vx = self.x - list[2].x
        self.vy = self.y - list[2].y
        self.rot = self._angle
    else
        for i = 1, l - 1, 1 do
            self.x = list[i].x
            self.y = list[i].y
            self.timer = self.timer + 1
            if self.timer % 4 == 0 then
                self.listx[(self.timer / 4) % _l] = self.x
                self.listy[(self.timer / 4) % _l] = self.y
            end
            self.data:Update(self, self.l, self.w)
        end
        self.x = list[l].x
        self.y = list[l].y
        self.vx = self.x - list[l - 1].x
        self.vy = self.y - list[l - 1].y
    end
end

---使用一个对象组刷新曲线激光的路径
---@param list table @对象组
function bent:LaserUpdateByList(list)
    local l = #list
    if l < 2 then
        return
    end
    self.data:UpdatePositionByList(list, l, self._w)
end
