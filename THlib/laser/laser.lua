laser_texture_num = 1
laser_data = {}

function LoadLaserTexture(text, l1, l2, l3)
    local n = laser_texture_num
    local texture = 'laser' .. n
    LoadTexture(texture, 'assets\\laser\\' .. text .. '.png')
    LoadImageGroup(texture .. 1, texture, 0, 0, l1, 16, 1, 16)
    LoadImageGroup(texture .. 2, texture, l1, 0, l2, 16, 1, 16)
    LoadImageGroup(texture .. 3, texture, l1 + l2, 0, l3, 16, 1, 16)
    for i = 1, 3 do
        for j = 1, 16 do
            SetImageCenter(texture .. i .. j, 0, 8)
        end
    end
    laser_data[n] = { l1, l2, l3 }
    laser_texture_num = n + 1
end

LoadLaserTexture('laser1', 64, 128, 64)
LoadLaserTexture('laser2', 5, 236, 15)
LoadLaserTexture('laser3', 127, 1, 128)
LoadLaserTexture('laser4', 1, 254, 1)
LoadLaserTexture('laser6', 64, 128, 64)
local cos, sin, min, max, int = cos, sin, min, max, int
local task, object = task, object

for i = 1, 16 do
    CopyImage('laser_node' .. i, "preimg" .. i)
    SetImageScale('laser_node' .. i, 0.5)
end

laser = Class(object)

function laser:init(index, x, y, rot, l1, l2, l3, w, node, head)
    self.index = clamp(int(index), 1, 16)
    self.imgid = 1
    self.img1 = 'laser11' .. self.index
    self.img2 = 'laser12' .. self.index
    self.img3 = 'laser13' .. self.index
    self.img4 = 'laser_node' .. self.index
    self.img5 = 'ball_mid' .. self.index
    self.x = x
    self.y = y
    self.rot = rot
    self.prex = x
    self.prey = y
    self.l1 = l1
    self.l2 = l2
    self.l3 = l3
    self.w0 = w or 8
    self.w = 0
    self.alpha = 0
    self.node = node or 0
    self.head = head or 0
    self.group = GROUP.LASER
    self.layer = LAYER.ENEMY_BULLET
    self.a = 0
    self.b = 0
    self.dw = 0
    self.da = 0
    self.counter = 0
    self.IsLaser = true
    --self._inf_graze = true
    self._blend, self._a, self._r, self._g, self._b = 'mul+add', 255, 255, 255, 255
    self.drop_CD = 0
    self.protect = 0
end

function laser:frame()
    task.Do(self)
    self.drop_CD = max(0, self.drop_CD - 1)
    self.protect = max(0, self.protect - 1)

    if self.counter > 0 then
        self.counter = self.counter - 1
        self.w = self.w + self.dw
        self.alpha = self.alpha + self.da
    end
    local player = player
    local len = self.l1 + self.l2 + self.l3
    if self.alpha > 0.999 and self.colli then
        local w = self.w
        if lstg.weather.QingMing then
            w = w * 0.5
        end
        if lstg.tmpvar._is_challenge18 then
            w = w * lstg.tmpvar._is_challenge18
        end
        local dx = player.x - self.x
        local dy = player.y - self.y
        local rot = self.rot
        local dist = 2
        dx, dy = dx * cos(rot) + dy * sin(rot), dy * cos(rot) - dx * sin(rot)
        dy = abs(dy)
        if dx > 0 then
            local flag = false
            if dx < self.l1 then
                if dy < dx / self.l1 * w / dist then
                    player.class.colli(player, self)
                end
                if dy < dx / self.l1 * w / dist + player.grazer.a then
                    flag = true
                end
            elseif dx < self.l1 + self.l2 then
                if dy < w / dist then
                    player.class.colli(player, self)
                end
                if dy < w / dist + player.grazer.a then
                    flag = true
                end
            elseif dx < len then
                if dy < (len - dx) / self.l3 * w / dist then
                    player.class.colli(player, self)
                end
                if dy < (len - dx) / self.l3 * w / dist + player.grazer.a then
                    flag = true
                end
            end
            if self.timer % 4 == 0 and flag then
                player.grazer.class.colli(player.grazer, self, true, self.x + cos(rot) * dx, self.y + sin(rot) * dx)
            end
        end
    end
end
local SetImageState = SetImageState
local Render = Render
local Color = Color
function laser:render()
    local b = self._blend
    local w = self.w
    local w0 = self.w0
    if lstg.weather.QingMing then
        w = w * 0.5
        w0 = w0 * 0.5
    end
    if lstg.tmpvar._is_challenge18 then
        w = w * lstg.tmpvar._is_challenge18
        w0 = w0 * lstg.tmpvar._is_challenge18
    end
    if w > 0 then
        local c = Color(self._a * self.alpha, self._r, self._g, self._b)
        local data = laser_data[self.imgid]
        local l = (self.l1 + self.l2 + self.l3) * 0.95
        SetImageState(self.img1, b, self._a * self.alpha, self._r, self._g, self._b)
        Render(self.img1, self.x, self.y, self.rot, self.l1 / data[1], w / 7)
        SetImageState(self.img2, b, self._a * self.alpha, self._r, self._g, self._b)
        Render(self.img2, self.x + self.l1 * cos(self.rot), self.y + self.l1 * sin(self.rot), self.rot, self.l2 / data[2], w / 7)
        SetImageState(self.img3, b, self._a * self.alpha, self._r, self._g, self._b)
        Render(self.img3, self.x + (self.l1 + self.l2) * cos(self.rot), self.y + (self.l1 + self.l2) * sin(self.rot), self.rot, self.l3 / data[3], w / 7)
        if self.node > 0 then
            local n = self.node
            if lstg.weather.QingMing then
                n = n * 0.5
            end
            if lstg.tmpvar._is_challenge18 then
                n = n * lstg.tmpvar._is_challenge18
            end
            c = Color(self._a * w / w0, self._r, self._g, self._b)
            SetImageState(self.img4, b, self._a * w / w0, self._r, self._g, self._b)
            Render(self.img4, self.x, self.y, 18 * self.timer, n / 8)
            Render(self.img4, self.x, self.y, -18 * self.timer, n / 8)
        end
        if self.head > 0 then
            c = Color(self._a * w / w0, self._r, self._g, self._b)
            SetImageState(self.img5, b, self._a * w / w0, self._r, self._g, self._b)
            Render(self.img5, self.x + l * cos(self.rot), self.y + l * sin(self.rot), 0, self.head / 8)
            Render(self.img5, self.x + l * cos(self.rot), self.y + l * sin(self.rot), 0, 0.75 * self.head / 8)
        end
    end
end

function laser:kill()
    --老的实现
    object.Preserve(self)
    local w = lstg.world
    if self.class ~= laser_death_ef then
        local cx, cy = cos(self.rot), sin(self.rot)
        local x, y = 0, 0
        local length = ((32768 - GetnObj()) / 2) * 12
        length = min(length, self.l1 + self.l2 + self.l3)
        for l = 0, length, 12 do
            x, y = self.x + l * cx, self.y + l * cy
            if (x <= w.r and x >= w.l) and (y <= w.t and y >= w.b) then
                New(item.drop_point, self.x, self.y)
                if self.index and l % 2 == 0 then
                    BulletBreak_Table:New(x, y, self.index)
                end
            end
        end
        self.class = laser_death_ef
        self.group = GROUP.GHOST
        local alpha = self.alpha
        local d = self.w
        task.Clear(self)
        task.New(self, function()
            for _ = 1, 30 do
                self.alpha = self.alpha - alpha / 30
                self.w = self.w - d / 30
                task.Wait()
            end
            object.Del(self)
        end)
    end
end

function laser:del()
    object.Preserve(self)
    if self.class ~= laser_death_ef then
        self.class = laser_death_ef
        --self.group = GROUP.GHOST
        self.colli = false
        local alpha = self.alpha
        local d = self.w
        task.Clear(self)
        task.New(self, function()
            for _ = 1, 30 do
                self.alpha = self.alpha - alpha / 30
                self.w = self.w - d / 30
                task.Wait()
            end
            object.Del(self)
        end)
    end
end

---以一个单位为本身来截断激光
---目前用在player的碰撞
function laser:CutOnUnit(other)
    local x = other.x - self.x
    local y = other.y - self.y
    x = x * cos(self.rot) + y * sin(self.rot)
    laser.CutOnRadius(self, x - 2, x + 2)
end

---用半径范围来截激光
---适用性强
---@return number,number@返回实际所切的长短
function laser:CutOnRadius(l1, l2)
    local _len = self.l1 + self.l2 + self.l3
    if l1 < 0 then
        l1 = 0
    end
    if l2 < l1 then
        l2 = l1
    end
    if l2 > _len then
        l2 = _len
    end
    if l1 == l2 then
        return l1, l2
    end
    local c = 1
    local l = l1
    BulletBreak_Table:New(self.x + cos(self.rot) * l, self.y + sin(self.rot) * l, self.index)
    if l < 4 and not self.no_del and not self.Isradial and not self.Isgrowing then
        object.Del(self)
    else
        self.l1, self.l3 = l / 2 / c, l / 2 / c
        self.l2 = l - l / c
        --self.v_rev = self.v_rev + (_len - l)
    end

    l = _len - l2
    local count = 0
    for _ in ObjList(GROUP.LASER) do
        count = count + 1
    end
    if l > 4 and count < 1000 then
        BulletBreak_Table:New(self.x + cos(self.rot) * l2, self.y + sin(self.rot) * l2, self.index)
        local other_laser = New(laser, self.index, self.x + cos(self.rot) * l2, self.y + sin(self.rot) * l2, self.rot, l / 2 / c, l - l / c, l / 2 / c, self.w, 0, self.head)
        other_laser.protect = 1
        if self.imgid ~= 1 then
            laser.ChangeImage(other_laser, self.imgid, self.index)
        end
        other_laser.secondhand = true
        other_laser.counter = 1
        other_laser.da = 1 - other_laser.alpha
        other_laser.dw = other_laser.w0 - other_laser.w
        other_laser._master_laser = self
        local ml = other_laser._master_laser
        if IsValid(ml) then

            if ml.Isradial then
                object.SetV(other_laser, ml.radial_v, other_laser.rot, true)
            elseif ml.Isgrowing then
                object.SetV(other_laser, ml._fake_v, other_laser.rot, true)
            else
                object.SetV(other_laser, GetV(ml), other_laser.rot, true)
            end
        end
        self.head = 0
    end
    return l1, l2
end

local function InScope(var, minvar, maxvar)
    return (var >= minvar) and (var <= maxvar)
end

local function GetIntersction(x1, y1, rot1, x2)
    local t = (x2 - x1) / cos(rot1)
    local y = y1 + t * sin(rot1)
    return x2, y
end

function laser:newkill()
    object.Preserve(self)
    if self.class ~= laser_death_ef then
        local x1, y1, x2, y2, x, y
        local w = lstg.world
        local x0, y0, rot = self.x, self.y, self.rot
        local len = self.l1 + self.l2 + self.l3
        local tx0, ty0 = x0 + len * cos(rot), y0 + len * sin(rot)
        if x0 > tx0 then
            x0, tx0, y0, ty0 = tx0, x0, ty0, y0
        end
        --
        local bx, by = GetIntersction(x0, y0, rot, w.boundl, w.boundb, 0)
        local lx, ly = GetIntersction(x0, y0, rot, w.boundl, w.boundb, 90)
        local tx, ty = GetIntersction(x0, y0, rot, w.boundr, w.boundt, 180)
        local rx, ry = GetIntersction(x0, y0, rot, w.boundr, w.boundt, 270)
        --
        local flag = InScope(x0, w.boundl, w.boundr)
        flag = flag or InScope(tx0, w.boundl, w.boundr)
        flag = flag or InScope(y0, w.boundb, w.boundt)
        flag = flag or InScope(ty0, w.boundb, w.boundt)
        flag = flag or InScope(bx, w.boundl, w.boundr)
        flag = flag or InScope(tx, w.boundl, w.boundr)
        flag = flag or InScope(ly, w.boundb, w.boundt)
        flag = flag or InScope(ry, w.boundb, w.boundt)
        if flag then
            if by < ly then
                if x0 < bx then
                    x1, y1 = bx, by
                else
                    x1, y1 = x0, y0
                end
            else
                if x0 < lx then
                    x1, y1 = lx, ly
                else
                    x1, y1 = x0, y0
                end
            end
            if ry < ty then
                if tx0 < rx then
                    x2, y2 = tx0, ty0
                else
                    x2, y2 = rx, ry
                end
            else
                if tx0 < tx then
                    x2, y2 = tx0, ty0
                else
                    x2, y2 = tx, ty
                end
            end
            len = Dist(x1, y1, x2, y2)
            if self.x <= x1 then
                x, y = x1, y1
            else
                x, y, rot = x2, y2, rot + 180
            end
            local cx, cy = cos(rot), sin(rot)
            for l = 0, len, 12 do
                New(item.drop_point, self.x, self.y)
                if l % 2 == 0 and self.index then
                    BulletBreak_Table:New(x + l * cx, y + l * cy, self.index)
                end
            end
        end
        self.class = laser_death_ef
        self.group = GROUP.GHOST
        local alpha = self.alpha
        local d = self.w
        task.Clear(self)
        task.New(self, function()
            for _ = 1, 30 do
                self.alpha = self.alpha - alpha / 30
                self.w = self.w - d / 30
                task.Wait()
            end
            object.Del(self)
        end)
    end
end

function laser:ChangeImage(id, index)
    self.imgid = clamp(int(id), 1, laser_texture_num - 1)
    if index then
        self.index = clamp(int(index), 1, 16)
    end
    index = self.index
    id = self.imgid
    self.img1 = 'laser' .. id .. '1' .. index
    self.img2 = 'laser' .. id .. '2' .. index
    self.img3 = 'laser' .. id .. '3' .. index
    self.img4 = 'laser_node' .. index
    self.img5 = 'ball_mid_b' .. index
end

function laser:_TurnOn(t, sound, wait)
    t = t or 30
    t = max(1, int(t))
    if sound then
        PlaySound('lazer00', 0.25, self.x / 200)
    end
    self.counter = t
    self.da = (1 - self.alpha) / t
    self.dw = (self.w0 - self.w) / t
    if wait and task.GetSelf() == self then
        task.Wait(t)
    end
end

function laser:_TurnHalfOn(t, wait)
    t = t or 30
    t = max(1, int(t))
    self.counter = t
    self.da = (0.5 - self.alpha) / t
    self.dw = (0.37 * self.w0 - self.w) / t
    if task.GetSelf() == self and wait then
        task.Wait(t)
    end
end

function laser:_TurnOff(t, wait)
    t = t or 30
    t = max(1, int(t))
    self.counter = t
    self.da = -self.alpha / t
    self.dw = -self.w / t
    if task.GetSelf() == self and wait then
        task.Wait(t)
    end
end

---@param v  number@伸长速度
---@param t number@伸长时间
---@param c number@伸长比例
---@param rot number@激光角度
function laser:CyGrow(v, t, c, rot, nosound)
    laser._TurnOn(self, 1, not nosound, false)
    self.Isgrowing = true
    self._fake_v = v
    task.New(self, function()
        --tmd误差
        local list = { (c - 1) * t / (2 * c) + 1e-12, t / c, (c - 1) * t / (2 * c) }
        local df = { 0, 0, 0 }
        local last = 0
        for j = 3, 1, -1 do
            self["l" .. j] = self["l" .. j] - v * last
            for _ = 1, int(list[j] + last) do
                self["l" .. j] = self["l" .. j] + v
                task.Wait()

            end
            local m = list[j] + last - int(list[j] + last)
            df[j] = m
            self["l" .. j] = self["l" .. j] + v * m
            last = m
        end
        local dx, dy = v * cos(rot) * (1 - last), v * sin(rot) * (1 - last)
        self.x, self.y = self.x + dx, self.y + dy
        task.Wait()
        object.SetV(self, v, rot, true)
        self.Isgrowing = false
    end)
    task.New(self, function()
        task.Wait(t - 10)
        for n = self.node, 0, (-self.node / 9) do
            self.node = n
            task.Wait()
        end
        self.node = 0
    end)
end

laser_death_ef = Class(laser, { frame = task.Do,
                                del = function()
                                end,
                                kill = function()
                                end })

Include("THlib\\laser\\bent laser.lua")
Include("THlib\\laser\\xlc_laser.lua")
