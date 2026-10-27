local path = "assets\\active_unit\\"
LoadImageFromFile("active_obj_no_entry_image", path .. "no_entry_image.png")
LoadImageFromFile("active_obj_no_entry_text", path .. "no_entry_text.png")

---@class active_obj
local class = {}

local exoplasm = Class(object, {
    init = function(self)
        self.layer = LAYER.PLAYER - 1
        self.group = GROUP.GHOST
        self.colli = false
        self.r = 25
        self.alpha = 0
        self._r, self._g, self._b = 200, 200, 200
        self.particle = {}
        self.bound = false
        self.x, self.y = player.x, player.y
        task.New(self, function()
            task.New(self, function()
                task.SmoothSetValueTo("alpha", 1, 25, 0)
            end)
            while not self.del_flag do
                task.Wait()
            end
            task.SmoothSetValueTo("alpha", 0, 25, 0)
        end)
    end,
    del = function(self)
        object.Preserve(self)
        self.del_flag = true
    end,
    frame = function(self)
        task.Do(self)
        self.x, self.y = player.x, player.y
        local p
        if not self.del_flag then
            if self.timer % (6 - setting.rdQual) == 0 then
                local a = self.timer * 6
                local R = abs(sin(self.timer * 2) * 60)
                local v = 2
                local x, y = self.x + cos(a) * R, self.y + sin(a) * R / 2
                for A in sp.math.AngleIterator(a, 3) do
                    local va = A + 90
                    local vx, vy = cos(va) * v, sin(va) * v
                    table.insert(self.particle, {
                        x = x, y = y,
                        vx = vx, vy = vy,
                        rot = va,
                        omega = 1.5,
                        alpha = ran:Float(75, 150), timer = 0,
                    })
                end


            end
        end
        for i = #self.particle, 1, -1 do
            p = self.particle[i]
            p.x = p.x + p.vx
            p.y = p.y + p.vy
            p.vx = p.vx - p.vx * 0.04
            p.vy = p.vy - p.vy * 0.04
            p.rot = p.rot + p.omega
            if p.timer > 40 then
                p.alpha = max(p.alpha - 5, 0)
                if p.alpha == 0 then
                    table.remove(self.particle, i)
                end
            end
            p.timer = p.timer + 1
        end
        if #self.particle == 0 then
            object.RawDel(self)
        end
    end,
    render = function(self)

        for _, p in ipairs(self.particle) do
            SetImageState("bright_line", "mul+add", p.alpha, self._r, self._g, self._b)
            Render("bright_line", p.x, p.y, p.rot, 0.5, 0.05)
        end
        if self.alpha > 0 then
            SetImageState("bright", "", self.alpha * 255, self._r, self._g, self._b)
            Render("bright", self.x, self.y, 0, self.r / 75)
        end
    end
})
class.exoplasm = exoplasm

local function bubble_effect(texname, x, y, sr, stkrange)
    local n = 15--渲染圆切割数量
    local tn = 42--渲染横向切割数量
    local _color = Color(255, 255, 255, 255)
    local _uv1, _uv2, _uv3, _uv4 = { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }
    _uv1[6] = _color
    _uv2[6] = _color
    _uv3[6] = _color
    _uv4[6] = _color
    local m = 1
    local kr1 = 0
    local kr2 = 0
    local dr1 = sr / tn
    local dr2 = sr / tn
    --x*2/n-1的积分是x*x/n-x
    for i = 1, tn do
        dr2 = sr / tn + stkrange * (i * 2 / tn - 1) * m
        _color = Color(255, 255 - 155 * (1 - i / 42), 255 - 155 * (1 - i / 42), 255)
        for r = 1, n do
            local da = 360 / n
            local ang = r * da
            local cx, cy = x, y
            local offa = 0
            local offx, offy = 0, 0
            _uv1[6] = _color
            _uv2[6] = _color
            _uv3[6] = _color
            _uv4[6] = _color
            _uv1[1], _uv1[2] = cx + offx + cos(ang + offa) * kr2, cy + offy + sin(ang + offa) * kr2
            _uv2[1], _uv2[2] = cx + offx + cos(ang + offa) * (kr2 + dr2), cy + offy + sin(ang + offa) * (kr2 + dr2)
            _uv3[1], _uv3[2] = cx + offx + cos(ang + da + offa) * (kr2 + dr2), cy + offy + sin(ang + da + offa) * (kr2 + dr2)
            _uv4[1], _uv4[2] = cx + offx + cos(ang + da + offa) * kr2, cy + offy + sin(ang + da + offa) * kr2

            _uv1[4], _uv1[5] = cx + offx + cos(ang) * kr1, cy + offy + sin(ang) * kr1
            _uv2[4], _uv2[5] = cx + offx + cos(ang) * (kr1 + dr1), cy + offy + sin(ang) * (kr1 + dr1)
            _uv3[4], _uv3[5] = cx + offx + cos(ang + da) * (kr1 + dr1), cy + offy + sin(ang + da) * (kr1 + dr1)
            _uv4[4], _uv4[5] = cx + offx + cos(ang + da) * kr1, cy + offy + sin(ang + da) * kr1
            _uv1[4], _uv1[5] = WorldToScreen(_uv1[4], _uv1[5])
            _uv2[4], _uv2[5] = WorldToScreen(_uv2[4], _uv2[5])
            _uv3[4], _uv3[5] = WorldToScreen(_uv3[4], _uv3[5])
            _uv4[4], _uv4[5] = WorldToScreen(_uv4[4], _uv4[5])
            RenderTexture(texname, "one", _uv1, _uv2, _uv3, _uv4)
            --[[
            SetImageState("white", "", 0, 0, 0, 0)
            Render4V("white", _uv1[1], _uv1[2], 0.5, _uv2[1], _uv2[2], 0.5, _uv3[1], _uv3[2], 0.5, _uv4[1], _uv4[2], 0.5)--]]
        end
        kr1 = kr1 + dr1
        kr2 = kr2 + dr2
    end
end

local bubble_bottom = Class(object, {
    init = function(self, master, id)
        CreateRenderTarget("active_obj:bubble" .. id)
        self.layer = LAYER.BG - 5 - id / 15000
        self.id = id
        self.group = GROUP.GHOST
        self.colli = false
        self.master = master
        self.r = self.master.r
    end,
    frame = function(self)
        task.Do(self)
        if not IsValid(self.master) then
            object.Del(self)
            return
        end
    end,
    render = function(self)
        if not IsValid(self.master) then
            return
        end
        PushRenderTarget("active_obj:bubble" .. self.id)
        RenderClear(Color(255, 0, 0, 0))
    end
}, true)
local bubble = Class(object, {
    init = function(self, active, id)
        self.layer = LAYER.TOP + id / 15000
        self.group = GROUP.GHOST
        self.colli = false
        self.r = 0
        self.x, self.y = player.x, player.y
        New(bubble_bottom, self, id)
        self.id = id
        self.uv1, self.uv2, self.uv3, self.uv4 = { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }
        local color = Color(255, 255, 255, 255)
        local w = lstg.world
        self.uv1[1], self.uv1[2] = w.l, w.t
        self.uv2[1], self.uv2[2] = w.r, w.t
        self.uv3[1], self.uv3[2] = w.r, w.b
        self.uv4[1], self.uv4[2] = w.l, w.b
        self.uv1[4], self.uv1[5] = WorldToScreen(w.l, w.t)
        self.uv2[4], self.uv2[5] = WorldToScreen(w.r, w.t)
        self.uv3[4], self.uv3[5] = WorldToScreen(w.r, w.b)
        self.uv4[4], self.uv4[5] = WorldToScreen(w.l, w.b)
        self.uv1[6] = color
        self.uv2[6] = color
        self.uv3[6] = color
        self.uv4[6] = color
        self.isMoving = true
        self.HaveCost = false
        self.active = active
        task.New(self, function()
            task.Wait(800)
            task.Clear(self, true)
            PlaySound("popbubble")
            if not self.HaveCost and self.active then
                self.active.energy = self.active.energy - self.active.cost
            end
            local R = self.r
            for i = 1, 10 do
                i = task.SetMode[2](i / 10)
                self.r = R * (1 - i)
                task.Wait()
            end
            self.isMoving = false
            player.stop_move = false
            Del(self)
        end)
        task.New(self, function()
            for i = 1, 30 do
                i = task.SetMode[2](i / 30)
                self.r = 175 * i
                task.Wait()
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        local p = player
        self.isMoving = self.isMoving and (lstg.var.active_item[1] == 9)
        if self.isMoving then

            local dx, dy = 0, 0
            local left, right, up, down
            local lc, rc, uc, dc = p.__left_counting, p.__right_counting, p.__up_counting, p.__down_counting
            local hspeed, lspeed = p.cur_hspd, p.cur_lspd
            local v = hspeed
            if p.slowlock then
                p.slow = 1
            end
            if p.slow == 1 then
                v = lspeed
            end
            v = v
            if lstg.weather.NiZhuan and not lstg.var.reverse_shoot then
                v = -v
            end
            up = p.__up_flag
            down = p.__down_flag
            left = p.__left_flag
            right = p.__right_flag
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
            self.x = clamp(self.x + dx, w.pl + 8 - p.borderless_offset, w.pr - 8 + p.borderless_offset)
            self.y = clamp(self.y + dy, w.pb + 16 - p.borderless_offset, w.pt - 32 + p.borderless_offset)
            if lstg.var.borderless_moving then
                if BoxCheck(self, w.pl + 8, w.pr - 8, w.pb + 16, w.pt - 32) then
                    p.borderless_offset = min(100, 1 + p.borderless_offset)
                    p.outborder_time = 0
                else
                    p.borderless_offset = max(0, p.borderless_offset - p.outborder_time / 20)
                    p.outborder_time = p.outborder_time + 1
                end
            end

        end
        p.stop_move = self.isMoving
        local function SlowDown(o)
            local d = Dist(o, self)
            local range = 50
            if d < self.r and not o.not_move then
                local k = 0.8 * clamp(self.r - d, 0, range) / range
                sp:UnitSetVIndex(o, -k)
            end
        end
        object.BulletDo(SlowDown)
        object.EnemyNontjtDo(SlowDown)

    end,
    render = function(self)
        local R = self.r * (sin(self.timer * 2) * 0.03 + 1)
        local tex = "active_obj:bubble" .. self.id
        PopRenderTarget(tex)
        RenderTexture(tex, "", self.uv1, self.uv2, self.uv3, self.uv4)
        bubble_effect(tex, self.x, self.y, R, -1 - 0.4 * sin(self.timer * 6))
        SetImageState("bubble_outline", "mul+add", 200, 255, 255, 255)
        Render("bubble_outline", self.x, self.y, self.timer * 2, R / 132)
        SetImageState("bubble_bright", "mul+add", 200, 255, 255, 255)
        Render("bubble_bright", self.x, self.y, 0, R / 132)
    end
})
class.bubble = bubble

local penetrate_kogasa = Class(object, {
    init = function(self, x, y, vx, vy)
        self.layer = LAYER.PLAYER - 2
        self.colli = true
        self.killflag = true
        self.group = GROUP.PLAYER
        self.bound = false
        self.index = 0
        self._index = 0
        self.r = 42
        self.open = false
        self.img = "umbrella_pic3"
        self.bound = false
        self.x, self.y = x, y
        self._index = 1
        self.vx, self.vy = vx * 1.25, vy * 1.25
        self.delete_mode = false
        self.count = 0
        PlaySound("umbrella_on")
        task.New(self, function()
            local w = lstg.world
            while BoxCheck(self, w.l, w.r, w.b, w.t) do
                task.Wait()
            end
            PlaySound("umbrella_off")
            self._index = 0
            self.delete_mode = true
            self.vx, self.vy = 0, 0
            local k = max(5, self.count)
            NewWave(self.x, self.y, 2, 300, 50, 135, 206, 235)
            item.dropItem(item.drop_dewdrop, k, self.x, self.y)
            task.Wait(25)
            Del(self)
        end)
    end,
    frame = function(self)
        task.Do(self)
        self.index = self.index + (-self.index + self._index) * 0.1
        self.a = self.index * self.r
        self.b = self.a
        if self.delete_mode then
            if self.colli then
                cutLasersByCircle(self.x, self.y, self.a)
            end
        end
    end,
    colli = function(self, other)
        if self.delete_mode then
            if other.group == GROUP.ENEMY_BULLET then
                object.Del(other)
            end
        else
            if other.group == GROUP.ENEMY_BULLET and not other._is_penetrated then
                other._is_penetrated = true
                object.ChangeSizeColliWithTask(other, -0.6, -0.6, 20, 2, 0)
                NewBon(other.x, other.y, 20, 40, 135, 206, 235, 0)
                self.r = min(178, self.r + 0.3)
                self.count = self.count + 1 / 5
            end
        end
    end,
    render = function(self)
        local px, py = self.x, self.y
        local size = self.index * self.r
        SetImageState(self.img, "", self.index * 255, 255, 255, 255)
        Render(self.img, px, py, 180 + 180 * self.index + self.timer * 2, (self.r) * (2 - self.index) / 128)
        SetImageState(self.img, "", 255, 255, 255, 255)
        Render(self.img, px, py, 180 - 180 * self.index + self.timer * 2, size / 128)
        SetImageState("umbrella_black", "", 255, 255, 255, 255)
        Render("umbrella_black", px, py, 180 - 180 * self.index, size / 32)
    end
}, true)
class.penetrate_kogasa = penetrate_kogasa

local no_entry_show = Class(object, {
    init = function(self)
        self.group = GROUP.GHOST
        self.layer = LAYER.TOP + 200
        self.colli = false
        self.alpha = 0
        self.show1 = 0
        self.show2 = 0
        task.New(self, function()
            for i = 1, 15 do
                self.alpha = i / 15
                task.Wait()
            end
            for i = 1, 30 do
                i = task.SetMode[10](i / 30)
                self.show1 = i
                self.show2 = i
                task.Wait()
            end
            task.Wait(42)
            for i = 1, 30 do
                self.alpha = 1 - task.SetMode[1](i / 30)
                task.Wait()
            end
            Del(self)
        end)
    end,
    frame = task.Do,
    render = function(self)
        local A = self.alpha
        local S1 = self.show1 * A
        local S2 = self.show2 * A
        local w = lstg.world
        SetImageState("white", "mul+add", A * 255, 255, 255, 255)
        RenderRect("white", w.l, w.r, w.b, w.t)
        SetImageState("active_obj_no_entry_image", "", S1 * 255, 255, 255, 255)
        Render("active_obj_no_entry_image", 480 - 355 * S1, 0, sin(self.timer * 2) * 6, 0.5)
        SetImageState("active_obj_no_entry_text", "", S2 * 255, 0, 0, 0)
        Render("active_obj_no_entry_text", -125, -300 + 300 * S2, 0, 0.5)
    end
}, true)
class.no_entry_show = no_entry_show

local c_moon = Class(object, {
    init = function(self)
        self.layer = LAYER.ENEMY - 2
        self.colli = true
        self.killflag = true
        self.group = GROUP.PLAYER
        self.bound = false
        self.index = 0
        self._index = 0
        self.r = 64
        self.open = false
        self.img = "moon3"
        self.bound = false
        self._index = 0
        PlaySound("metal_aura")
        task.New(self, function()
            local T = 300
            for i = 1, T do
                self._index = min(sin(i / T * 180) * 3, 1)
                local size = player.a * 12000
                if lstg.var.MAX_M then
                    size = size * 1.3
                end
                if lstg.var.neutron_star then
                    size = size * 1.3
                end
                local exclude = function(b)
                    if not b.not_move and not b.IsBoss then
                        local a = 3
                        local d = Dist(b, player)
                        local force = self._index * size * a / d / d
                        local A = Angle(b, player) + 180
                        b.x = b.x + cos(A) * force
                        b.y = b.y + sin(A) * force
                    end
                end
                object.BulletDo(exclude)
                object.EnemyNontjtDo(exclude)
                for _, o in ObjList(GROUP.ITEM) do
                    exclude(o)
                end
                for _, o in ObjList(GROUP.ITEM2) do
                    exclude(o)
                end
                task.Wait()

            end
            Del(self)
        end)
    end,
    frame = function(self)
        task.Do(self)
        self.x, self.y = player.x, player.y
        self.index = self.index + (-self.index + self._index) * 0.1
    end,
    render = function(self)
        local px, py = self.x, self.y
        local size = self.index * self.r
        --SetImageState(self.img, "", self.index * 255, 255, 255, 255)
        --Render(self.img, px, py, 180 + 180 * self.index + self.timer * 2, (self.r) * (2 - self.index) / 64)
        SetImageState(self.img, "mul+rev", self.index * 180, 255, 255, 255)
        Render(self.img, px, py, self.timer * 2, size / 56)
    end
}, true)
class.c_moon = c_moon

local Attack = Class(object)
function Attack:init(col, dmg)
    self.x, self.y = player.x, player.y
    self.group = 3
    self.layer = -401
    self.bound = false
    self.colli = true
    self.alpha = 0
    self.col = col
    self.a = 0
    self.dmg = dmg
    self.killflag = true
    self.count = 0
    function self:drop_item(x, y)
        New(item.drop_point, x, y)
        player_lib.NewEnergySp(x, y, 0.022)
    end
end
function Attack:frame()
    task.Do(self)
    self.b = self.a
    if self.colli then
        cutLasersByCircle(self.x, self.y, self.a, function(x, y)
            self:drop_item(x, y)
        end)
        object.BulletDo(function(o)
            if Dist(self, o) < self.a then
                object.Del(o)
                self:drop_item(o.x, o.y)
                --New(main_item, o.x, o.y, nil, nil, true, nil, 0.6)
            end
        end)
        object.LaserDo(function(o)
            if Dist(self, o) < self.a and not o.Isradial and not o.Isgrowing then
                object.Del(o)
                self:drop_item(o.x, o.y)
                --New(main_item, o.x, o.y, nil, nil, true, nil, 0.6)
            end
        end)
    end
end
function Attack:render()
    SetImageState("white", "mul+add", self.alpha / 2.7, unpack(self.col))
    misc.SectorRender(self.x, self.y, 0, self.a, 0, 360, 40)
    misc.SectorRender(self.x, self.y, self.a - 6, self.a, 0, 360, 40)
end

local Spring_Attack = Class(Attack)
function Spring_Attack:init(rank)
    Attack.init(self, { 230, 40, 40 }, (0.8 + rank * 0.1) * player.damage)
    self.alpha = 255
    player.protect = player.protect + 20 + rank * 3
    task.New(self, function()
        task.SmoothSetValueTo("a", 60 + rank * 28, 12, 2)
        task.Wait(30 + rank * 6)
        self.colli = false
        task.SmoothSetValueTo("alpha", 0, 30, 2)
        object.Del(self)
    end)
end
class.Spring_Attack = Spring_Attack

local Summer_Attack = Class(Attack)
function Summer_Attack:init(rank)
    Attack.init(self, { 40, 90, 230 }, 0.5 * player.damage)
    player.protect = player.protect + 30
    self.alpha = 0
    self.a = 60
    task.New(self, function()
        task.SmoothSetValueTo("alpha", 255, 12, 2)
        task.Wait(60 + rank * 2)
        self.colli = false
        task.SmoothSetValueTo("alpha", 0, 30, 2)
        object.Del(self)
    end)
end
class.Summer_Attack = Summer_Attack

local Autumn_Attack = Class(Attack)
function Autumn_Attack:init(rank)
    Attack.init(self, { 230, 80, 20 }, (0.6 + rank * 0.1) * player.damage)
    player.protect = player.protect + 30 + rank * 18
    self.alpha = 0
    self.a = 60 + rank * 3
    player.hspeed_fixed = player.hspeed_fixed + 0.5
    player.lspeed_fixed = player.lspeed_fixed + 0.5
    task.New(self, function()
        task.SmoothSetValueTo("alpha", 255, 20, 2)
        task.Wait(30 + rank * 18)
        self.colli = false
        player.hspeed_fixed = player.hspeed_fixed - 0.5
        player.lspeed_fixed = player.lspeed_fixed - 0.5
        task.SmoothSetValueTo("alpha", 0, 30, 2)
        object.Del(self)
    end)
end
function Autumn_Attack:frame()
    Attack.frame(self)
    self.x, self.y = player.x, player.y
end
class.Autumn_Attack = Autumn_Attack

local Winter_Attack = Class(Attack)
function Winter_Attack:init(rank)
    Attack.init(self, { 60, 100, 235 }, (1 + rank * 0.1) * player.damage)
    player.protect = player.protect + 90 + rank * 22
    self.alpha = 0
    self.a = 60 + rank * 2
    player.dmg_fixed = player.dmg_fixed + 0.1 * rank
    task.New(self, function()
        task.SmoothSetValueTo("alpha", 255, 20, 2)
        task.Wait(60 + rank * 22)
        self.colli = false
        player.dmg_fixed = player.dmg_fixed - 0.1 * rank
        task.SmoothSetValueTo("alpha", 0, 30, 2)
        object.Del(self)
    end)
end
class.Winter_Attack = Winter_Attack

local Doyou_Attack = Class(Attack)
function Doyou_Attack:init(rank)
    Attack.init(self, { 40, 40, 200 }, 0.5 * player.damage)
    player.protect = player.protect + 30
    self.alpha = 0
    self.a = 60
    self.vy = -1.3
    task.New(self, function()
        task.SmoothSetValueTo("a", 40, 60, 2)
    end)
    task.New(self, function()
        task.SmoothSetValueTo("alpha", 255, 12, 2)
        task.Wait(60 + rank * 2)
        self.colli = false
        task.SmoothSetValueTo("alpha", 0, 30, 2)
        object.Del(self)
    end)
end
class.Doyou_Attack = Doyou_Attack

local shackles = Class(object, {
    init = function(self)
        self.layer = LAYER.PLAYER
        self.group = GROUP.GHOST
        self.colli = false
        self.r = 0
        self.alpha = 1
        self._r, self._g, self._b = 200, 200, 200
        self.particle = {}
        self.bound = false
        self.x, self.y = player.x, player.y
        self.timer = ran:Int(1, 1000)
        task.New(self, function()
            task.New(self, function()
                task.SmoothSetValueTo("r", 666, 25, 2)
            end)
            while not self.del_flag do
                task.Wait()
            end
            task.SmoothSetValueTo("alpha", 0, 25, 0)
        end)
    end,
    del = function(self)
        object.Preserve(self)
        self.del_flag = true
    end,
    frame = function(self)
        task.Do(self)
        self.x, self.y = player.x, player.y
        local p
        if not self.del_flag then
            if self.timer % (9 - setting.rdQual) == 0 then

                object.EnemyNontjtDo(function(e)
                    if e.class.base.take_damage then
                        local a = e.timer * 6
                        local R = abs(sin(e.timer * 2) * 60)
                        local v = 0.5
                        local x, y = e.x + cos(a) * R, e.y + sin(a) * R / 2
                        local va = a
                        local vx, vy = cos(va) * v, sin(va) * v
                        table.insert(self.particle, {
                            x = x, y = y,
                            vx = vx, vy = vy,
                            rot = va,
                            omega = 0,
                            alpha = 0, timer = 0,
                        })
                    end
                end)
                local a = self.timer * 6
                local R = abs(sin(self.timer * 2) * 60)
                local v = 0.5
                local x, y = self.x + cos(a) * R, self.y + sin(a) * R / 2
                local va = a
                local vx, vy = cos(va) * v, sin(va) * v
                table.insert(self.particle, {
                    x = x, y = y,
                    vx = vx, vy = vy,
                    rot = va,
                    omega = 0,
                    alpha = 0, timer = 0,
                })


            end
        end
        for i = #self.particle, 1, -1 do
            p = self.particle[i]
            p.x = p.x + p.vx
            p.y = p.y + p.vy
            p.vx = p.vx - p.vx * 0.04
            p.vy = p.vy - p.vy * 0.04
            p.rot = p.rot + p.omega
            if p.timer < 10 then
                p.alpha = min(p.alpha + 10, 100)
            elseif p.timer > 40 then
                p.alpha = max(p.alpha - 5, 0)
                if p.alpha == 0 then
                    table.remove(self.particle, i)
                end
            end
            p.timer = p.timer + 1
        end
        if #self.particle == 0 then
            object.RawDel(self)
        end
    end,
    render = function(self)

        for _, p in ipairs(self.particle) do
            SetImageState("bright_line", "mul+rev", p.alpha, 0, 255, 255)
            Render("bright_line", p.x, p.y, p.rot, 1, 0.3)
        end
        if self.alpha > 0 then
            SetImageState("bright_fog", "mul+rev", self.alpha * 150, self._r, self._g, self._b)
            Render("bright_fog", 0, 0, 0, self.r / 400)
        end
    end
})
class.shackles = shackles

return class