local abs = abs
local int = int
local SetImageState = SetImageState
local SetImgState = SetImgState
local Render = Render
WalkImageSystem = plus.Class()
function WalkImageSystem:init(obj, intv, dx_level, dx_rate)
    self.dx_level = abs(dx_level)
    self.dx_rate = abs(dx_rate)
    self.obj = obj
    self.obj.ani_intv = intv or 8
    self.obj.lr = self.obj.lr or 1
end
function WalkImageSystem:frame(dx)
    local obj, lv, rt = self.obj, self.dx_level, self.dx_rate
    if dx == nil then
        dx = obj.dx
    end
    if dx > 0.5 then
        dx = lv
    elseif dx < -0.5 then
        dx = -lv
    else
        dx = 0
    end
    obj.lr = obj.lr + dx
    if obj.lr > rt then
        obj.lr = rt
    end
    if obj.lr < -rt then
        obj.lr = -rt
    end
    if obj.lr == 0 then
        obj.lr = obj.lr + dx
    end
    if dx == 0 then
        if obj.lr > 1 then
            obj.lr = obj.lr - 1
        end
        if obj.lr < -1 then
            obj.lr = obj.lr + 1
        end
    end
end
function WalkImageSystem:render(dmgt, dmgmaxt)
    local obj = self.obj
    local dx, dy = self.dx or 0, self.dy or 0
    local A = obj._a
    if obj.transparent then
        A = A * 0.5
    end
    local c = 0
    if dmgt and dmgmaxt then
        c = dmgt / dmgmaxt
    end
    local gandu = 50 / ((obj.gandu_count or 0) + 50)
    OriginalSetImageState(obj.img, obj._blend, Color(A, obj._r * (1 - 0.75 * c), obj._g * gandu * (1 - 0.75 * c), obj._b))
    if self.float_func then
        local tmpx, tmpy = self.float_func(obj.ani)
        dx, dy = tmpx or dx, tmpy or dy
        self.dx, self.dy = dx, dy
    end

    local size = 1
    if lstg.weather.QingMing then
        size = 0.5
    end
    if lstg.tmpvar._is_challenge18 then
        size = size * lstg.tmpvar._is_challenge18
    end

    Render(obj.img, obj.x + dx, obj.y + dy, obj.rot, obj.hscale * size, obj.vscale * size)
end
function WalkImageSystem:SetFloat(a, b)
    if not (a) and not (b) then
        self.float_func = nil
    elseif type(a) == "function" and not (b) then
        self.float_func = a
    elseif type(a) == "number" and type(b) == "number" then
        self.dx, self.dy = a or self.dx or 0, b or self.dy or 0
        self.float_func = nil
    end
end
function WalkImageSystem:GetFloat(ani)
    if self.float_func then
        return self.float_func(ani)
    elseif self.dx and self.dy then
        return self.dx, self.dy
    else
        return 0, 0
    end

end
function WalkImageSystem:SetImage()
end

BossWalkImageSystem = plus.Class(WalkImageSystem)
function BossWalkImageSystem:init(obj, img, nRow, nCol, imgs, anis, intv, a, b)
    WalkImageSystem.init(self, obj, intv, 2, 28)
    self.obj.cast = self.obj.cast or 0
    self.obj.cast_t = self.obj.cast_t or 0
    self.hscale = 1
    self.obj._blend = ""
    self.obj._a, self.obj._r, self.obj._g, self.obj._b = 255, 255, 255, 255
    if img then
        self:SetImage(img, nRow, nCol, imgs, anis, intv, a, b)
    end
end
function BossWalkImageSystem:frame()
    local obj = self.obj
    WalkImageSystem.frame(self, obj.dx)
    if obj.img4 then
        self.mode = 4
    elseif obj.img3 then
        self.mode = 3
    elseif obj.img2 then
        self.mode = 2
    elseif obj.img1 then
        self.mode = 1
    else
        self.mode = 0
    end
    if obj.cast_t > 0 then
        obj.cast = obj.cast + 1
    elseif obj.cast_t < 0 then
        obj.cast = 0
        obj.cast_t = 0
        if obj.cast_force then
            obj.cast_force = nil
        end
    end
    if obj.dx ~= 0 and not obj.cast_force then
        obj.cast = 0
        obj.cast_t = 0
    end
    if self.mode ~= 0 then
        BossWalkImageSystem['UpdateImage' .. self.mode](obj)
    end
    if type(obj.A) == 'number' and type(obj.B) == 'number' then
        obj.a = obj.A;
        obj.b = obj.B
    end
end
function BossWalkImageSystem:render(dmgt, dmgmaxt)
    if self.mode == 0 then
        local obj = self.obj
        local ani = obj.ani
        local x, y = obj.x, obj.y
        OriginalSetImageState('undefined', 'mul+add', Color(obj._a / 2, obj._r, obj._g, obj._b))
        Render('undefined', x + cos(ani * 6 + 180) * 3, y + sin(ani * 6 + 180) * 3, ani * 10, 1 + sin(ani * 4) * 0.15)
        Render('undefined', x + cos(-ani * 6 + 180) * 3, y + sin(-ani * 6 + 180) * 3, -ani * 10)
        Render('undefined', x + cos(ani * 6) * 3, y + sin(ani * 6) * 3, ani * 20, 1 - sin(ani * 4) * 0.15)
        Render('undefined', x + cos(-ani * 6) * 3, y + sin(-ani * 6) * 3, -ani * 20)

        --鵺球的渲染，在boss那边self._wisys:SetImage()应该就可以
    else

        WalkImageSystem.render(self, dmgt, dmgmaxt)
    end
end
function BossWalkImageSystem:SetImage(img, nRow, nCol, imgs, anis, intv)
    local obj = self.obj
    for i = 1, 4 do
        obj['img' .. i] = nil
        obj['ani' .. i] = nil
    end
    if img then
        for i = 1, nRow do
            obj['img' .. i] = {}
        end
        for i = 2, nRow do
            obj['ani' .. i] = imgs[i] - anis[i - 1]
        end
        for i = 1, nRow do
            for j = 1, imgs[i] do
                obj['img' .. i][j] = img .. i .. j
            end
        end
        obj.ani_intv = intv or obj.ani_intv or 8
        obj.lr = obj.lr or 1
        obj.nn, obj.mm = imgs, anis
        self.mode = nCol
    else
        self.mode = 0
    end
end
function BossWalkImageSystem:UpdateImage4()
    if self.cast > 0 then
        if self.cast >= self.ani_intv * self.nn[4] then
            if self.mm[3] == 1 then
                self.img = self.img4[self.nn[4]]
            else
                self.img = self.img4[int(self.cast / self.ani_intv) % self.mm[3] + self.ani4 + 1]
            end
            self.cast_t = self.cast_t - 1
        else
            self.img = self.img4[int(self.cast / self.ani_intv) + 1]
        end
    elseif self.lr > 0 then
        if abs(self.lr) == 1 then
            self.img = self.img1[int(self.ani / self.ani_intv) % self.nn[1] + 1]
        elseif abs(self.lr) == 28 then
            if self.mm[1] == 1 then
                self.img = self.img2[self.nn[2]]
            else
                self.img = self.img2[int(self.ani / self.ani_intv) % self.mm[1] + self.ani2 + 1]
            end
        else
            if self.ani2 == 2 then
                self.img = self.img2[int((abs(self.lr) + 2) / 10) + 1]
            elseif self.ani2 == 3 then
                self.img = self.img2[int((abs(self.lr)) / 7) + 1]
            elseif self.ani2 == 4 then
                self.img = self.img2[int((abs(self.lr) + 2) / 6) + 1]
            elseif self.ani2 > 4 then
                self.img = self.img2[int((abs(self.lr) + 2) / 5) + 1]
            end
        end
    else
        if abs(self.lr) == 1 then
            self.img = self.img1[int(self.ani / self.ani_intv) % self.nn[1] + 1]
        elseif abs(self.lr) == 28 then
            if self.mm[2] == 1 then
                self.img = self.img3[self.nn[3]]
            else
                self.img = self.img3[int(self.ani / self.ani_intv) % self.mm[2] + self.ani3 + 1]
            end
        else
            if self.ani3 == 2 then
                self.img = self.img3[int((abs(self.lr) + 2) / 10) + 1]
            elseif self.ani3 == 3 then
                self.img = self.img3[int((abs(self.lr)) / 7) + 1]
            elseif self.ani3 == 4 then
                self.img = self.img3[int((abs(self.lr) + 2) / 6) + 1]
            elseif self.ani3 > 4 then
                self.img = self.img3[int((abs(self.lr) + 2) / 5) + 1]
            end
        end
    end
end
function BossWalkImageSystem:UpdateImage3()
    if self.cast > 0 then
        if self.cast >= self.ani_intv * self.nn[3] then
            if self.mm[2] == 1 then
                self.img = self.img3[self.nn[3]]
            else
                self.img = self.img3[int(self.cast / self.ani_intv) % self.mm[2] + self.ani3 + 1]
            end
            self.cast_t = self.cast_t - 1
        else
            self.img = self.img3[int(self.cast / self.ani_intv) + 1]
        end
    else
        if abs(self.lr) == 1 then
            self.img = self.img1[int(self.ani / self.ani_intv) % self.nn[1] + 1]
        elseif abs(self.lr) == 28 then
            if self.mm[1] == 1 then
                self.img = self.img2[self.nn[2]]
            else
                self.img = self.img2[int(self.ani / self.ani_intv) % self.mm[1] + self.ani2 + 1]
            end
        else
            if self.ani2 == 2 then
                self.img = self.img2[int((abs(self.lr) + 2) / 10) + 1]
            elseif self.ani2 == 3 then
                self.img = self.img2[int((abs(self.lr)) / 7) + 1]
            elseif self.ani2 == 4 then
                self.img = self.img2[int((abs(self.lr) + 2) / 6) + 1]
            elseif self.ani2 > 4 then
                self.img = self.img2[int((abs(self.lr) + 2) / 5) + 1]
            end
        end
    end
    self.hscale = sign(self.lr) * abs(self.hscale) * self._wisys.hscale
end
function BossWalkImageSystem:UpdateImage1()
    self.img = self.img1[int(self.ani / self.ani_intv) % self.nn[1] + 1]
end

BossWalkImageSystemRotate = plus.Class(BossWalkImageSystem)
function BossWalkImageSystemRotate:frame()

    BossWalkImageSystem.frame(self)
    local obj = self.obj
    if obj.dx >= 0 and abs(obj.lr) ~= 1 then
        obj.rot = obj.rot - 32
    elseif obj.dx < 0 then
        obj.rot = obj.rot + 32
    end
    if obj.cast > 0 then
        obj.rot = 0
    elseif abs(obj.lr) == 1 then
        obj.rot = 0
    end
end

Include("THlib\\BossImageList.lua")
local WalkImage = WalkImage
local unpack = unpack
function BossWalkImageSystem:SetImageInList(img, notsaoqi)
    local b = self.obj
    if WalkImage.imglist[img] then
        WalkImage.LoadFunc[img]()
        b.WALKIMGID = img
        self:SetImage(img, unpack(WalkImage.imglist[img]))
        if WalkImage.saoqilist[img] and not notsaoqi then
            if IsValid(b.saoqi) then
                Del(b.saoqi)
            end
            b.self_color, b.self_color2, b.self_color3 = unpack(WalkImage.saoqilist[img])
            if IsValid(b.distortion) then
                b.distortion.wavecolor = b.self_color3
            end
            b.saoqi = New(SaoqiMain, b.x, b.y, b, b.self_color, b.self_color2, b.self_color3)--New(saoqi, b.x, b.y, b, unpack(WalkImage.saoqilist[img]))

        end
    elseif CheckRes("img", img) then
        self.mode = 1
        b.WALKIMGID = img
        b.img1 = { img }
        b.img2 = nil
        b.img3 = nil
        b.img4 = nil
        b.img = img
        b.nn = { 1 }
        b.mm = {}
    else
        error("InValid image:" .. img)
    end
    self:frame()
end

EnemyWalkImageSystem = plus.Class(WalkImageSystem)
function EnemyWalkImageSystem:init(obj, style, intv)
    WalkImageSystem.init(self, obj, intv, 1, 18)
    self:SetImage(style)
    self.particle = {}
end
function EnemyWalkImageSystem:frame()
    local obj = self.obj
    WalkImageSystem.frame(self, obj.dx)
    if obj.style <= 18 then
        EnemyWalkImageSystem.UpdateImage(obj)
    end
    if type(obj.A) == 'number' and type(obj.B) == 'number' then
        obj.a = obj.A
        obj.b = obj.B
    end
    if self.img_state == "ghost" then
        if obj.timer % 2 == 0 then
            local scale = obj.hscale
            if lstg.weather.QingMing then
                scale = scale * 0.5
            end
            if lstg.tmpvar._is_challenge18 then
                scale = scale * lstg.tmpvar._is_challenge18
            end
            table.insert(self.particle, {
                x = obj.x, y = obj.y,
                vx = ran:Float(-1, 1) * scale, vy = ran:Float(2, 4) * scale,
                lifetime = int(15 * scale), alpha = 0.8, timer = 0, size = 1 * scale
            })
        end
        for i = #self.particle, 1, -1 do
            local p = self.particle[i]
            p.x = p.x + p.vx
            p.y = p.y + p.vy
            p.timer = p.timer + 1
            p.size = p.size - p.size * 0.11
            if p.lifetime < p.timer + 5 then
                p.alpha = max(p.alpha - 1 / 5, 0)
                if p.alpha == 0 then
                    table.remove(self.particle, i)
                end
            end
        end
    end
end
function EnemyWalkImageSystem:render(dmgt, dmgmaxt)
    local obj = self.obj
    local c = 0
    if dmgt and dmgmaxt then
        c = dmgt / dmgmaxt
    end
    local A = obj._a
    if obj.transparent then
        A = A * 0.5
    end
    local hscale, vscale = obj.hscale, obj.vscale
    if lstg.weather.QingMing then
        hscale = hscale * 0.5
        vscale = vscale * 0.5
    end
    if lstg.tmpvar._is_challenge18 then
        hscale = hscale * lstg.tmpvar._is_challenge18
        vscale = vscale * lstg.tmpvar._is_challenge18
    end
    local gandu = 50 / ((obj.gandu_count or 0) + 50)
    local r, g, b = obj._r, obj._g * gandu, obj._b
    SetImgState(obj, obj._blend, A, r * (1 - 0.75 * c), g * (1 - 0.75 * c), b)
    if obj.aura then
        SetImageState('enemy_aura' .. obj.aura, "mul+add", A, r, g, b)
        local breath = 1.25 + 0.15 * sin(obj.timer * 6)
        Render('enemy_aura' .. obj.aura, obj.x, obj.y, obj.timer * 3, hscale * breath, vscale * breath)
    end
    if obj.servant_back then
        SetImageState("servant", "mul+add", A, r, g, b)
        local scale = obj.servant_back_scale or 1
        local breath = (1.25 + 0.2 * sin(obj.timer * 7)) * scale
        Render("servant", obj.x, obj.y, obj.timer * 3, hscale * breath, vscale * breath)
    end

    --调换到低一层
    if obj.style >= 27 and obj.style <= 30 then
        local img = 'Ghost' .. (obj.style - 26) .. int((obj.timer / 4) % 8) + 1
        SetImageState(img, obj._blend, A, r * (1 - 0.75 * c), g * (1 - 0.75 * c), b)
        Render(img, obj.x, obj.y, 90, hscale * 1.1, vscale * 1.1)
    end
    if obj.style > 30 then
        local img = 'Ghost' .. (obj.style - 30) .. int((obj.timer / 4) % 8) + 1
        SetImageState(img, obj._blend, A, r * (1 - 0.75 * c), g * (1 - 0.75 * c), b)
        Render(img, obj.x, obj.y, 90, hscale * 1.1, vscale * 1.1)
    end
    if self.img_state == "ghost" then
        for _, p in ipairs(self.particle) do
            SetImageState("parimg1", "mul+add", p.alpha * A, r * (1 - 0.75 * c), g * (1 - 0.75 * c), b)
            Render("parimg1", p.x, p.y, 0, p.size)
        end
    else
        Render(obj.img, obj.x, obj.y, obj.rot, hscale, vscale)
    end

    if obj.style > 22 and obj.style <= 26 then
        SetImageState('enemy_orb_ring' .. obj.aura, 'mul+add', A, r * (1 - 0.75 * c), g * (1 - 0.75 * c), b)
        Render('enemy_orb_ring' .. obj.aura, obj.x, obj.y, -obj.timer * 6, hscale, vscale)
        Render('enemy_orb_ring' .. obj.aura, obj.x, obj.y, obj.timer * 4, hscale * 1.4, vscale * 1.4)
    end
end
function EnemyWalkImageSystem:SetImage(style, intv)
    local obj = self.obj
    obj.style = style
    obj.aura = _enemy_aura_tb[style]
    obj.death_ef = _death_ef_tb[style]
    obj.ani_intv = intv or obj.ani_intv or 8
    obj.lr = obj.lr or 1
    if style <= 18 then
        obj.imgs = {}
        for i = 1, 12 do
            obj.imgs[i] = 'enemy' .. style .. '_' .. i
        end
    elseif style <= 22 then
        obj.img = 'kedama' .. (style - 18)
        obj.omega = 12
    elseif style <= 26 then
        obj.img = 'enemy_orb' .. (style - 22)
        obj.omega = 6
    elseif style == 27 or style == 31 then
        obj.img = 'ghost_fire_r'
        self.img_state = "ghost"
        obj.rot = -90
    elseif style == 28 or style == 32 then
        obj.img = 'ghost_fire_b'
        self.img_state = "ghost"
        obj.rot = -90
    elseif style == 29 or style == 33 then
        obj.img = 'ghost_fire_g'
        self.img_state = "ghost"
        obj.rot = -90
    elseif style == 30 or style == 34 then
        obj.img = 'ghost_fire_y'
        self.img_state = "ghost"
        obj.rot = -90
    else
        obj.img = obj.imgs[1]
        obj.style = 0
    end
end
function EnemyWalkImageSystem:UpdateImage()
    if abs(self.lr) == 1 then
        self.img = self.imgs[int(self.ani / self.ani_intv) % 4 + 1]
    elseif abs(self.lr) == 18 then
        self.img = self.imgs[int(self.ani / self.ani_intv) % 4 + 9]
    else
        self.img = self.imgs[int((abs(self.lr) - 2) / 4) + 5]
    end
    self.hscale = sign(self.lr) * abs(self.hscale)
end

PlayerWalkImageSystem = plus.Class()
function PlayerWalkImageSystem:init(obj)
    self.obj = obj
    self.obj.ani_intv = nil
    self.obj.lr = self.obj.lr or 1
    self.leftlr = 6
    self.rightlr = 6
    self.obj.protect = self.obj.protect or 0
    self.alpha = 1
    self.alpha2 = 1
end
function PlayerWalkImageSystem:update(dx)
    local obj = self.obj
    if dx == nil then
        dx = obj.dx
    end
    if dx > 0.5 then
        dx = 1
    elseif dx < -0.5 then
        dx = -1
    else
        dx = 0
    end
    obj.lr = obj.lr + dx
    if obj.lr > self.rightlr then
        obj.lr = self.rightlr
    end
    if obj.lr < -self.leftlr then
        obj.lr = -self.leftlr
    end
    if obj.lr == 0 then
        obj.lr = obj.lr + dx
    end
    if dx == 0 then
        if obj.lr > 1 then
            obj.lr = obj.lr - 1
        end
        if obj.lr < -1 then
            obj.lr = obj.lr + 1
        end
    end
end
function PlayerWalkImageSystem:frame(dx)
    local obj = self.obj
    self.UpdateImage(obj)
    self:update(dx or 0)
end
function PlayerWalkImageSystem:render()
    local obj = self.obj
    local A = obj._a * self.alpha * self.alpha2
    local v = lstg.var
    local w = lstg.weather
    local reverse_vscale = v.reverse_shoot and (-1) or 1
    if w.YuShui then
        A = A * 0.5
    end
    if obj.protect % 3 == 1 then
        SetImageState(obj.img, obj._blend, A, 0, 0, obj._b)
    else
        SetImageState(obj.img, obj._blend, A, obj._r, obj._g, obj._b)
    end
    local Scale = 1
    if v.neutron_star then
        Scale = 0.75
    end
    if lstg.tmpvar._is_challenge18 then
        Scale = Scale * lstg.tmpvar._is_challenge18
    end
    Render(obj.img, obj.x, obj.y, obj.rot, obj.hscale * Scale, obj.vscale * reverse_vscale * Scale)
end
function PlayerWalkImageSystem:UpdateImage()
    if abs(self.lr) == 1 then
        self.img = self.imgs[int(self.ani / 6) % 8 + 1]
    elseif self.lr == -self._wisys.leftlr then
        self.img = self.imgs[int(self.ani / 10) % 4 + 13]
    elseif self.lr == self._wisys.rightlr then
        self.img = self.imgs[int(self.ani / 10) % 4 + 21]
    elseif self.lr < 0 then
        self.img = self.imgs[7 - self.lr]
    elseif self.lr > 0 then
        self.img = self.imgs[15 + self.lr]
    end
    self.a = self.A
    self.b = self.B
end
