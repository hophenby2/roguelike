local path = "assets\\addition_unit\\"

LoadImage('reimu_bullet_blue', 'reimu_player', 0, 160, 16, 16, 16, 16)
SetImageState('reimu_bullet_blue', '', 100, 255, 255, 255)
LoadAnimation('reimu_bullet_blue_ef', 'reimu_player', 0, 160, 16, 16, 4, 1, 4)
SetAnimationState('reimu_bullet_blue_ef', 'mul+add', 160, 255, 255, 255)
LoadImage('marisa_missile', 'marisa_player', 192, 224, 32, 16, 8, 8)
SetImageState('marisa_missile', '', 238, 255, 255, 255)
LoadAnimation('marisa_missile_ef', 'marisa_player', 64, 224, 32, 32, 4, 1, 2)
SetAnimationState('marisa_missile_ef', 'mul+add', 128, 255, 255, 255)

CopyImage("level_obj_small_ningyou_bullet", "level_obj_ice_bullet")
SetImageState("level_obj_small_ningyou_bullet", "", 190, 255, 255, 125)
LoadAnimation("level_obj_small_ningyou_bullet_ef", "level_obj_tex", 128, 128, 16, 16, 4, 1, 4)
SetAnimationState("level_obj_small_ningyou_bullet_ef", "", 190, 255, 255, 125)
LoadAnimation("level_obj_ningyou_support", "level_obj_tex", 128, 80, 32, 32, 3, 1, 6)
LoadAniFromFile("level_obj_reimu_baby", path .. "reimu_baby.png", true, 4, 1, 6)
LoadAniFromFile("level_obj_marisa_baby", path .. "marisa_baby.png", true, 4, 1, 6)
LoadAniFromFile("level_obj_siyuan_baby1", path .. "siyuan_baby1.png", true, 6, 1, 3)
LoadAniFromFile("level_obj_siyuan_baby2", path .. "siyuan_baby2.png", true, 6, 3, 4)
LoadAniFromFile("level_obj_siyuan_baby3", path .. "siyuan_baby3.png", true, 17, 1, 2)
LoadAniFromFile("level_obj_siyuan_baby4", path .. "siyuan_baby4.png", true, 2, 1, 5)
LoadAniFromFile("level_obj_siyuan_baby5", path .. "siyuan_baby5.png", true, 3, 1, 3)
LoadAniFromFile("level_obj_sweat_cat", path .. "sweat_cat.png", true, 4, 5, 5)
LoadAniFromFile("level_obj_tease_cat", path .. "tease_cat.png", true, 4, 2, 4)
LoadAniFromFile("level_obj_mushroom", path .. "mushroom.png", true, 1, 2, 5)
LoadImageFromFile("level_obj_dish", path .. "dish.png", true)
LoadImageFromFile("level_obj_igiari", path .. "igiari.png", true)

lstg.var.igiari_mode = 1

---@class level_obj4
local class4 = {}
class4.baby_idList = {}

local baby_class = Class(object)
function baby_class:init(img)
    self.x, self.y = player.x, player.y
    self.group = GROUP.PLAYER
    self.layer = LAYER.PLAYER - 5
    self.colli = false
    self.bound = false
    self.savePos_x = { player.x }
    self.savePos_y = { player.y }
    local bs = lstg.tmpvar.baby_stack

    sp:UnitListAppend(bs, self)
    self.img = img
    self._a, self._r, self._g, self._b = 255, 255, 255, 255
    self.alpha = 0
    self._blend = ""
    task.New(self, function()
        for i = 1, 15 do
            self.alpha = i / 15
            task.Wait()
        end
    end)

end
function baby_class:frame()
    task.Do(self)
    local bs = lstg.tmpvar.baby_stack
    sp:UnitListUpdate(bs)
    for i, u in ipairs(bs) do
        if u == self then
            self.id = i
        end
    end
    local p = player
    if p.dx ~= 0 or p.dy ~= 0 then
        table.insert(self.savePos_x, p.x)
        table.insert(self.savePos_y, p.y)
        for _ = 1, 2 do
            if #self.savePos_x > self.id * 9 then
                table.remove(self.savePos_x, 1)
                table.remove(self.savePos_y, 1)
            end
        end
    end
    self._x, self._y = self.savePos_x[1], self.savePos_y[1]
    self.x = self.x + (-self.x + self._x) * 0.2
    self.y = self.y + (-self.y + self._y) * 0.2
    if self.class.shoot then
        self.class.shoot(self)
    end

end
function baby_class:render()
    SetImgState(self, self._blend, self._a * self.alpha, self._r, self._g, self._b)
    DefaultRenderFunc(self)
end
class4.baby_class = baby_class

local reimu_baby_bullet = Class(player_bullet_trail)
function reimu_baby_bullet:init(x, y, v, angle, Trail, dmg)
    player_bullet_trail.init(self, "reimu_bullet_blue", x, y, v, angle, nil, Trail, dmg * lstg.var.baby_dmg_factor)
    self.master = player
    self.smear = {}
    task.New(self, function()
        for i = 1, 75 do
            self.v = v * (1 - i / 75)
            task.Wait()
        end
        Del(self)

    end)
end
function reimu_baby_bullet:frame()
    if not IsValid(self.master) then
        object.RawDel(self)
        return
    end
    task.Do(self)
    self.target = self.master.target
    player_bullet_trail.frame(self)
    table.insert(self.smear, { x = self.x, y = self.y, rot = self.rot, alpha = 40 })
    local s
    for i = #self.smear, 1, -1 do
        s = self.smear[i]
        s.alpha = max(0, s.alpha - 5)
        if s.alpha == 0 then
            table.remove(self.smear, i)
        end
    end
end
function reimu_baby_bullet:render()
    for _, s in ipairs(self.smear) do
        SetImageState(self.img, 'mul+add', s.alpha, 255, 255, 255)
        Render(self.img, s.x, s.y, s.rot)
    end
    SetImageState(self.img, '', 100, 255, 255, 255)
    DefaultRenderFunc(self)
end
function reimu_baby_bullet:kill()
    New(class4.reimu_baby_bullet_ef, self.x, self.y, self.rot)
end
class4.reimu_baby_bullet = reimu_baby_bullet

local reimu_baby_bullet_ef = Class(object)
function reimu_baby_bullet_ef:init(x, y, rot)
    self.x = x
    self.y = y
    self.rot = rot
    self.img = 'reimu_bullet_blue_ef'
    self.layer = LAYER.PLAYER_BULLET + 50
    self.group = GROUP.GHOST
    self.vx = cos(rot)
    self.vy = sin(rot)
    self.alpha = 160
end
function reimu_baby_bullet_ef:frame()
    task.Do(self)
    self.hscale = self.hscale + 0.2
    self.vscale = self.hscale
    if self.timer == 10 then
        task.New(self, function()
            for _ = 1, 4 do
                self.alpha = self.alpha - 160 / 4
                task.Wait()
            end
            object.Del(self)
        end)
    end
end
function reimu_baby_bullet_ef:render()
    SetAnimationState(self.img, 'mul+add', self.alpha, 255, 255, 255)
    DefaultRenderFunc(self)
end
class4.reimu_baby_bullet_ef = reimu_baby_bullet_ef

local marisa_baby_bullet = Class(player_bullet_straight)
function marisa_baby_bullet:init(x, y, a, dmg)
    player_bullet_straight.init(self, "marisa_missile", x, y, 0, a, dmg * lstg.var.baby_dmg_factor)
    self.ay = 0.15
    self.rot = 90
    self.alpha = 0
    PlaySound('msl', 0.3)
    task.New(self, function()
        for i = 1, 112 do
            self.ay = 0.15 - 0.30 * i / 112
            task.Wait()
        end
        New(bubble3, self.img, self.x, self.y, self.rot, self.vx, self.vy, self.omega, 8, self.hscale, self.hscale,
                Color(155, 255, 255, 255), Color(0, 255, 255, 255), self.layer, self._blend)
        Del(self)

    end)
    task.New(self, function()
        for i = 1, 10 do
            self.alpha = i / 10
            task.Wait()
        end
    end)
end
function marisa_baby_bullet:frame()
    task.Do(self)
    player_bullet_straight.frame(self)
end
function marisa_baby_bullet:render()
    SetImgState(self, "", 155 * self.alpha, 255, 255, 255)
    DefaultRenderFunc(self)
end
function marisa_baby_bullet:kill()
    PlaySound('msl2', 0.3)
    local a, r = ran:Float(0, 360), ran:Float(0, 6)
    New(class4.marisa_baby_bullet_ef, self.x + r * cos(a), self.y + r * sin(a), self.dmg, 5)
end
class4.marisa_baby_bullet = marisa_baby_bullet

local marisa_baby_bullet_ef = Class(object)
function marisa_baby_bullet_ef:init(x, y, dmg, t)
    self.x = x
    self.y = y
    self.a = 4
    self.b = 4
    self.img = 'marisa_missile_ef'
    self.group = GROUP.PLAYER_BULLET
    self.dmg = dmg / 75
    self.killflag = true
    self.layer = LAYER.PLAYER_BULLET
    self.mute = true
    self.t = t
end
function marisa_baby_bullet_ef:frame()
    if self.timer == 3 and self.t > 0 then
        local a, r = ran:Float(0, 360), ran:Float(8, 16)
        New(class4.marisa_baby_bullet_ef, self.x + r * cos(a), self.y + r * sin(a), self.dmg * 20, self.t - 1)
    end
    if self.timer == 15 then
        Del(self)
    end
end
class4.marisa_baby_bullet_ef = marisa_baby_bullet_ef

local ningyou_bullet = Class(object, {
    init = function(self, x, y, v, a, dmg)
        player_bullet_straight.init(self, "level_obj_small_ningyou_bullet", x, y, v, a, dmg * lstg.var.baby_dmg_factor)

    end,
    kill = function(self)
        New(class4.ningyou_bullet_ef, self.x, self.y, self.rot)
    end
})
class4.ningyou_bullet = ningyou_bullet
local ningyou_bullet_ef = Class(object, {
    init = function(self, x, y, rot)
        self.x = x
        self.y = y
        self.img = "level_obj_small_ningyou_bullet_ef"
        self.layer = LAYER.PLAYER_BULLET + 50
        self.group = GROUP.GHOST
        object.SetV(self, 2.25, rot, true)
    end,
    frame = function(self)
        if self.timer == 15 then
            object.RawDel(self)
        end
    end
})
class4.ningyou_bullet_ef = ningyou_bullet_ef

local siyuan1_bullet = Class(object, {
    init = function(self, x, y, v, a, dmg, t, R, G, B)
        player_bullet_straight.init(self, "ball_small15", x, y, v, a, dmg * lstg.var.baby_dmg_factor)
        self.a, self.b = 8, 8
        self._r, self._g, self._b = R or 255, G or 255, B or 255
        task.New(self, function()
            t = t or 50
            for i = 1, t do
                self.v = v * (1 - i / t)
                object.SetV(self, self.v, a)
                task.Wait()
            end
            object.Kill(self)

        end)
    end,
    frame = task.Do,
    render = function(self)
        SetImageState(self.img, '', 100, self._r, self._g, self._b)
        DefaultRenderFunc(self)
    end,
    kill = function(self)
        New(class4.siyuan1_bullet_ef, self.x, self.y, self.v, self.rot, self._r, self._g, self._b)
    end
})
class4.siyuan1_bullet = siyuan1_bullet
local siyuan1_bullet_ef = Class(object, {
    init = function(self, x, y, v, rot, R, G, B)
        self.x = x
        self.y = y
        self.img = "ball_small15"
        self.layer = LAYER.PLAYER_BULLET + 50
        self.group = GROUP.GHOST
        self._r, self._g, self._b = R, G, B
        object.SetV(self, min(v, 2.2), rot, true)
    end,
    frame = function(self)
        if self.timer == 8 then
            object.RawDel(self)
        end
    end,
    render = function(self)
        local A = max(1 - self.timer / 8, 0)
        SetImageState(self.img, '', 100 * A, self._r, self._g, self._b)
        DefaultRenderFunc(self)
    end
})
class4.siyuan1_bullet_ef = siyuan1_bullet_ef

local siyuan2_bullet = Class(object, {
    init = function(self, x, y, v, a, dmg, t, R, G, B)
        player_bullet_straight.init(self, "ball_small15", x, y, v, a, dmg * lstg.var.baby_dmg_factor)
        self.a, self.b = 8, 8
        self._r, self._g, self._b = R or 255, G or 255, B or 255
        self.trail = 500
        self.v = v
        task.New(self, function()
            t = t or 50
            for i = 1, t do
                self.v = v * (1 - i / t)
                --object.SetV(self, self.v, a)
                task.Wait()
            end
            object.Kill(self)

        end)
    end,
    frame = function(self)
        task.Do(self)
        player_class.findtarget(self)
        player_bullet_trail.frame(self)
    end,
    render = function(self)
        SetImageState(self.img, '', 100, self._r, self._g, self._b)
        DefaultRenderFunc(self)
    end,
    kill = function(self)
        New(class4.siyuan2_bullet_ef, self.x, self.y, self.v, self.rot, self._r, self._g, self._b)
    end
})
class4.siyuan2_bullet = siyuan2_bullet
local siyuan2_bullet_ef = Class(object, {
    init = function(self, x, y, v, rot, R, G, B)
        self.x = x
        self.y = y
        self.img = "ball_small15"
        self.layer = LAYER.PLAYER_BULLET + 50
        self.group = GROUP.GHOST
        self._r, self._g, self._b = R, G, B
        object.SetV(self, min(v, 2.2), rot, true)
    end,
    frame = function(self)
        if self.timer == 8 then
            object.RawDel(self)
        end
    end,
    render = function(self)
        local A = max(1 - self.timer / 8, 0)
        SetImageState(self.img, '', 100 * A, self._r, self._g, self._b)
        DefaultRenderFunc(self)
    end
})
class4.siyuan2_bullet_ef = siyuan2_bullet_ef

local reimu_baby = Class(baby_class)
function reimu_baby:init()
    baby_class.init(self, "level_obj_reimu_baby")
    self.tool_id = 139
end
function reimu_baby:shoot()
    if self.timer % 18 == 0 then
        New(reimu_baby_bullet, self.x, self.y, 10, 90, 500, 2)
    end
    self.hscale = 0.2 + sin(self.timer * 3) * 0.02
    self.vscale = self.hscale
end
function reimu_baby:render()

    baby_class.render(self)
    SetImageState("bright", "", 150 * self.alpha, 250, 128, 114)
    Render("bright", self.x, self.y, 0, 35 / 130)
end
table.insert(class4.baby_idList, 139)
class4.reimu_baby = reimu_baby

local marisa_baby = Class(baby_class)
function marisa_baby:init()
    baby_class.init(self, "level_obj_marisa_baby")
    self.tool_id = 140
end
function marisa_baby:shoot()
    if self.timer % 22 == 0 then
        New(marisa_baby_bullet, self.x + ran:Float(-6, 6), self.y + ran:Float(-6, 6), 0, 3)
    end
    self.hscale = 0.2 + sin(self.timer * 3) * 0.02
    self.vscale = self.hscale
end
function marisa_baby:render()
    baby_class.render(self)
    SetImageState("bright", "", 150 * self.alpha, 255, 227, 132)
    Render("bright", self.x, self.y, 0, 35 / 130)

end
table.insert(class4.baby_idList, 140)
class4.marisa_baby = marisa_baby

local ningyou_baby = Class(baby_class)
function ningyou_baby:init()
    baby_class.init(self, "level_obj_ningyou_support")
    self.tool_id = 141
end
function ningyou_baby:shoot()
    if self.timer % 12 == 0 then
        for a in sp.math.AngleIterator(45, 4) do
            New(ningyou_bullet, self.x, self.y, 10, a, 1)
        end
    end
end
table.insert(class4.baby_idList, 141)
class4.ningyou_baby = ningyou_baby

local soul_baby = Class(enemy)
function soul_baby:init()

    baby_class.init(self, "white")

    enemy.init(self, 30, 999, false, false, true, 0)
    self.group = GROUP.GHOST
    self.tool_id = 143
    self.servant_back = true
    self.servant_back_scale = 0.6
    self.protect = true
    self.pass_check = true
    self.last_priority = true
    self._a = 255
    self._r, self._g, self._b = 158, 45, 60
    self.flag = false
    task.New(self, function()
        while Dist(self, player) < player.A + self.a do
            task.Wait()
        end
        self.flag = true
    end)
end
function soul_baby:frame()

    enemy.frame(self)
    baby_class.frame(self)
    self.colli = true
    if lstg.var.goldenbody and lstg.var.frame_counting then
        self.group = GROUP.GHOST
    else
        if self.flag then
            self.group = GROUP.ENEMY
        else
            self.group = GROUP.GHOST
        end
    end
    if self.group == GROUP.ENEMY then
        New(stg_levelUPlib.class.bullet_killer, self.x, self.y, self.a * 1.5, self.b * 1.5)
    end
    local p = player
    if p.name == "Youmu" and p.__shoot_flag and p.nextshoot <= 0 then
        local A = 90
        if lstg.var.reverse_shoot then
            A = -90
        end
        if self.timer % 8 == 0 then
            New(siyuan1_bullet, self.x + self.a * cos(A), self.y + self.b * sin(A), 15, A, 1)
        end
    end
end
table.insert(class4.baby_idList, 143)
class4.soul_baby = soul_baby

local huyuelin_baby = Class(baby_class)
function huyuelin_baby:init()
    baby_class.init(self, "addition_state127")
    self.hscale = 0.1
    self.vscale = 0.1
    self.omega = -2
    self._a = 120
    self.tool_id = 138
end
function huyuelin_baby:render()


    SetImageState("bright", "", 150 * self.alpha, 255, 227, 132)
    Render("bright", self.x, self.y, 0, 35 / 130)
    baby_class.render(self)
end
table.insert(class4.baby_idList, 138)
class4.huyuelin_baby = huyuelin_baby

local siyuan_baby1 = Class(baby_class)
function siyuan_baby1:init()
    baby_class.init(self, "level_obj_siyuan_baby1")
    self.hscale = 0.45
    self.vscale = 0.45
    self._a = 130
    self.tool_id = 145
end
function siyuan_baby1:shoot()
    if self.timer % 21 == 0 then
        for a in sp.math.AngleIterator(ran:Float(0, 360), 10) do
            New(siyuan1_bullet, self.x, self.y, 10, a, 1)
        end
    end
end
function siyuan_baby1:render()
    SetImageState("bright", "", 150 * self.alpha, 255, 255, 255)
    Render("bright", self.x, self.y, 0, 35 / 130)
    baby_class.render(self)
end
table.insert(class4.baby_idList, 145)
class4.siyuan_baby1 = siyuan_baby1

local siyuan_baby2 = Class(baby_class)
function siyuan_baby2:init()
    baby_class.init(self, "level_obj_siyuan_baby2")
    self.hscale = 0.23
    self.vscale = 0.23
    self._a = 130
    self.tool_id = 147
end
function siyuan_baby2:shoot()
    if self.timer % 36 == 32 then
        local c = (self.timer % 72 < 36) and -1 or 1
        for d = -1, 1, 2 do
            for z = -3, 3 do
                local A = 90 + d * 45
                New(siyuan1_bullet, self.x + cos(A) * 9, self.y + sin(A) * 9, ran:Float(8, 12),
                        90 + d * 25 + c * 15 + z * 6 + ran:Float(-7, 7), 1, 68)
            end
        end
    end
end
function siyuan_baby2:render()
    SetImageState("bright", "", 150 * self.alpha, 255, 255, 255)
    Render("bright", self.x, self.y, 0, 35 / 130)
    baby_class.render(self)
end
table.insert(class4.baby_idList, 147)
class4.siyuan_baby2 = siyuan_baby2

local siyuan_baby3 = Class(baby_class)
function siyuan_baby3:init()
    baby_class.init(self, "level_obj_siyuan_baby3")
    self.hscale = 0.26
    self.vscale = 0.26
    self._a = 130
    self.tool_id = 150
end
function siyuan_baby3:shoot()
    if self.timer % 17 == 16 then
        local c = (self.timer % 34 < 17) and -1 or 1
        for d = -1, 1, 2 do
            local A = 90 + d * 56
            for a in sp.math.AngleIterator(ran:Float(0, 360), 20) do
                New(siyuan1_bullet, self.x + cos(A) * 15, self.y + sin(A) * 15, ran:Float(9, 11), a, 1, 68, 255, 227, 132)
            end
        end
    end
end
function siyuan_baby3:render()
    SetImageState("bright", "", 150 * self.alpha, 255, 255, 255)
    Render("bright", self.x, self.y, 0, 35 / 130)
    baby_class.render(self)
end
table.insert(class4.baby_idList, 150)
class4.siyuan_baby3 = siyuan_baby3

local sweat_cat = Class(baby_class)
function sweat_cat:init()
    baby_class.init(self, "level_obj_sweat_cat")
    self.hscale = 0.4
    self.vscale = 0.4
    self._a = 130
    self.tool_id = 148
end
function sweat_cat:shoot()
    if self.timer % 7 == 0 then
        New(siyuan1_bullet, self.x + ran:Float(-12, 12), self.y, ran:Float(4, 6),
                -90 + ran:Float(-1, 1), 1, 120)
    end
end
function sweat_cat:render()
    SetImageState("bright", "", 150 * self.alpha, 255, 255, 255)
    Render("bright", self.x, self.y, 0, 35 / 130)
    baby_class.render(self)
end
table.insert(class4.baby_idList, 148)
class4.sweat_cat = sweat_cat

local mushroom_baby = Class(baby_class)
function mushroom_baby:init()
    baby_class.init(self, "level_obj_mushroom")
    self.hscale = 0.4
    self.vscale = 0.4
    self._a = 130
    self.tool_id = 149
end
function mushroom_baby:shoot()
    if self.dx ~= 0 or self.dy ~= 0 then
        self.rot = Angle(self.dx, self.dy, 0, 0)
    end
    if self.timer % 3 == 0 then
        New(siyuan1_bullet, self.x + ran:Float(-12, 12), self.y, ran:Float(4, 6),
                self.rot + ran:Float(-3, 3), 1, 120, 218, 112, 214)
    end
end
function mushroom_baby:render()
    SetImageState("bright", "", 150 * self.alpha, 255, 255, 255)
    Render("bright", self.x, self.y, 0, 35 / 130)
    baby_class.render(self)
end
table.insert(class4.baby_idList, 149)
class4.mushroom_baby = mushroom_baby

local siyuan_baby4 = Class(baby_class)
function siyuan_baby4:init()
    baby_class.init(self, "level_obj_siyuan_baby4")
    self.hscale = 0.4
    self.vscale = 0.4
    self._a = 130
    self.d = 1
    self.tool_id = 156
end
function siyuan_baby4:shoot()
    local d = sign(self.dx)
    if d ~= 0 then
        self.d = d
    end
    self.hscale = -0.4 * self.d
    if self.timer % 10 == 5 then
        for _ = 1, 6 do
            New(siyuan1_bullet, self.x, self.y, ran:Float(7, 8), -90 + ran:Float(-50, 50), 1, 120)
        end
    end
end
function siyuan_baby4:render()
    SetImageState("bright", "", 150 * self.alpha, 255, 255, 255)
    Render("bright", self.x, self.y, 0, 35 / 130)
    baby_class.render(self)
end
table.insert(class4.baby_idList, 156)
class4.siyuan_baby4 = siyuan_baby4

local tease_cat = Class(baby_class)
function tease_cat:init()
    baby_class.init(self, "level_obj_tease_cat")
    self.hscale = 0.3
    self.vscale = 0.3
    self._a = 130
    self.d = 1
    self.tool_id = 157
end
function tease_cat:shoot()
    local d = sign(self.dx)
    if d ~= 0 then
        self.d = d
    end
    self.hscale = 0.3 * self.d
    if self.timer % 3 == 1 then
        New(siyuan2_bullet, self.x, self.y, 4, -90 - 90 * self.d, 0.8, 400)
    end
end
function tease_cat:render()
    SetImageState("bright", "", 150 * self.alpha, 255, 255, 255)
    Render("bright", self.x, self.y, 0, 35 / 130)
    baby_class.render(self)
end
table.insert(class4.baby_idList, 157)
class4.tease_cat = tease_cat

local protect_kogasa = Class(object, {
    init = function(self, x, y)
        self.layer = LAYER.PLAYER - 2
        self.colli = true
        self.killflag = true
        self.group = GROUP.PLAYER
        self.bound = false
        self.index = 0
        self._index = 0
        self.r = 42
        self.open = false
        self.img = "umbrella_pic2"
        self.bound = false
        self.x, self.y = x, y
        self._index = 1
        task.New(self, function()
            task.Wait(90)
            self._index = 0
            self.colli = false
            task.Wait(25)
            Del(self)
        end)
    end,
    frame = function(self)
        task.Do(self)
        if IsValid(lstg.tmpvar.SUN) then
            self.vy = 1.5
            self.ay = 0.03
        end
        self.index = self.index + (-self.index + self._index) * 0.1
        self.a = self.index * self.r
        self.b = self.a
        if self.colli then
            cutLasersByCircle(self.x, self.y, self.a)
        end
    end,
    colli = function(self, other)
        if other.group == GROUP.ENEMY_BULLET then
            object.Del(other)
        end
    end,
    render = function(self)
        local px, py = self.x, self.y
        local size = self.index * self.r
        SetImageState(self.img, "", self.index * 255, 255, 255, 255)
        Render(self.img, px, py, 180 + 180 * self.index + self.timer * 2, (self.r) * (2 - self.index) / 32)
        SetImageState(self.img, "", 255, 255, 255, 255)
        Render(self.img, px, py, 180 - 180 * self.index + self.timer * 2, size / 32)
        SetImageState("umbrella_black", "", 255, 255, 255, 255)
        Render("umbrella_black", px, py, 180 - 180 * self.index, size / 32)
    end
}, true)
class4.protect_kogasa = protect_kogasa

local game_killer = Class(object, {
    init = function(self, x, y)
        self.x, self.y = x, y
        self.img = "arrow_small2"
        self.layer = LAYER.ENEMY_BULLET_EF
        self.group = GROUP.PLAYER_BULLET
        self.colli = true
        self.dmg = tonumber(ui.version:match("v(%d+%.%d+).%d+"))
        self.alpha = 170
        self.vscale = 0.45
        self.hscale = 0.45
        self.navi = true
        task.New(self, function()
            local a, l = ran:Float(0, 360), ran:Float(40, 80)
            task.MoveToEx(cos(a) * l, sin(a) * l, ran:Int(45, 70), 2)
            task.Wait(10)
            player_class.findtarget(self)
            local target = self.target
            if IsValid(target) then
                local angle = Angle(self.x, self.y, target.x, target.y)
                self.vx = self.vx + cos(angle)
                self.vy = self.vy + sin(angle)
            end
            for i = 1, 36 do
                self.vx, self.vy = self.vx * 1.075, self.vy * 1.075
                task.Wait()
            end
            task.Wait(24)
            for i = 1, 3 do
                self.alpha = 170 - 170 * i / 3
                task.Wait()
            end
            object.Del(self)
        end)
    end,
    frame = task.Do,
    render = function(self)
        SetImageState(self.img, "mul+add", self.alpha, 250, 128, 114)
        DefaultRenderFunc(self)
    end
}, true)
class4.game_killer = game_killer

local cross_laser = Class(WideLaser)
function cross_laser:init(x, y, rot, time)
    WideLaser.init(self, x, y, 14, rot)
    self.alpha = 0.5
    self.layer = LAYER.PLAYER_BULLET - 1
    WideLaser.TurnOn(self, 10)
    self.group = GROUP.PLAYER_BULLET
    self.killflag = true
    task.New(self, function()
        task.Wait(time)
        Del(self)
    end)
end
function cross_laser:frame()
    task.Do(self)
    self.vscale = (self.w + 8) / 64
    self.hscale = self.vscale
    if self.counter > 0 then
        self.counter = self.counter - 1
        self.w = self.w + self.dw
    end
    object.EnemyNontjtDo(function(o)
        if o.colli and o.class.base.take_damage then
            local x = o.x - self.x
            local y = o.y - self.y
            local rot = self.rot
            x, y = x * cos(rot) + y * sin(rot), y * cos(rot) - x * sin(rot)
            y = abs(y)
            if x > 0 then
                if y < self.w * 10 / 48 then
                    o.class.base.take_damage(o, player.damage * 0.02)
                end
            end
        end
    end)
end
class4.cross_laser = cross_laser

local siyuan_baby5 = Class(baby_class)
function siyuan_baby5:init()
    baby_class.init(self, "level_obj_siyuan_baby5")
    self.hscale = 0.35
    self.vscale = 0.35
    self._a = 130
    self.d = 1
    self.tool_id = 163
end
function siyuan_baby5:shoot()
    local d = sign(self.dx)
    if d ~= 0 then
        self.d = d
    end
    self.hscale = -0.35 * self.d
end
function siyuan_baby5:render()
    SetImageState("bright", "", 150 * self.alpha, 255, 255, 255)
    Render("bright", self.x, self.y, 0, 35 / 130)
    baby_class.render(self)
end
table.insert(class4.baby_idList, 163)
class4.siyuan_baby5 = siyuan_baby5

local water_drop_bullet = Class(object, {
    init = function(self, x, y, v, a, dmg, t, R, G, B)
        player_bullet_straight.init(self, "water_drop6", x, y, v, a, dmg)
        self.a, self.b = 16, 16
        self._r, self._g, self._b = R or 255, G or 255, B or 255
        task.New(self, function()
            t = t or 50
            for i = 1, t do
                self.v = v * (1 - i / t)
                object.SetV(self, self.v, a)
                task.Wait()
            end
            object.Kill(self)

        end)
    end,
    frame = task.Do,
    render = function(self)
        SetAnimationState(self.img, 'mul+add', 100, self._r, self._g, self._b)
        DefaultRenderFunc(self)
    end,
    kill = function(self)
        New(class4.water_drop_bullet_ef, self.x, self.y, self.v, self.rot, self._r, self._g, self._b)
    end
})
class4.water_drop_bullet = water_drop_bullet
local water_drop_bullet_ef = Class(object, {
    init = function(self, x, y, v, rot, R, G, B)
        self.x = x
        self.y = y
        self.img = "water_drop6"
        self.layer = LAYER.PLAYER_BULLET + 50
        self.group = GROUP.GHOST
        self._r, self._g, self._b = R, G, B
        object.SetV(self, min(v, 2.2), rot, true)
    end,
    frame = function(self)
        if self.timer == 8 then
            object.RawDel(self)
        end
    end,
    render = function(self)
        local A = max(1 - self.timer / 8, 0)
        SetAnimationState(self.img, 'mul+add', 100 * A, self._r, self._g, self._b)
        DefaultRenderFunc(self)
    end
})
class4.water_drop_bullet_ef = water_drop_bullet_ef

local protect_moon = Class(object, {
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
        self.img = "moon2"
        self.R, self.G, self.B = 255, 227, 132
        self.bound = false
        self._index = 0
        self.stop = false
        self.setstop = function()
            self.stop = true
        end
        task.New(self, function()
            while true do
                self.colli = true
                for _ = 1, 120 do
                    self._index = min(1, self._index + 1 / 120)
                    if self.stop then
                        break
                    end
                    task.Wait()
                end
                while not self.stop do
                    if lstg.var.lotus_record_b >= stg_levelUPlib.class2.MAX_PROTECT_LOTUS - 1 then
                        ext.achievement:get(149)
                    end
                    task.Wait()
                end
                lstg.tmpvar.protect_moon_achievement = false
                PlaySound("moon", 0.3)
                NewWave(self.x, self.y, 2, (self.index + 1) * self.r, 15, self.R, self.G, self.B, self.index * self.r)
                while self._index > 0 do
                    self._index = max(0, self._index - 1 / 75)
                    task.Wait()
                end
                self.stop = false
                self.colli = false
                task.Wait(85)
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
        if lstg.var.addition[135] then
            self.img = "moon"
            self.R, self.G, self.B = 250, 128, 114
        else
            self.img = "moon2"
            self.R, self.G, self.B = 255, 227, 132
        end
        self.x, self.y = player.x, player.y
        self.index = self.index + (-self.index + self._index) * 0.2
        self.a = self.index * self.r
        self.b = self.a
        if self.colli then
            cutLasersByCircle(self.x, self.y, self.a, self.setstop)
        end
    end,
    colli = function(self, other)
        if other.group == GROUP.ENEMY_BULLET then
            self.setstop()
            object.Del(other)
        end
    end,
    render = function(self)
        local px, py = self.x, self.y
        local size = self.index * self.r
        --SetImageState(self.img, "", self.index * 255, 255, 255, 255)
        --Render(self.img, px, py, 180 + 180 * self.index + self.timer * 2, (self.r) * (2 - self.index) / 64)
        SetImageState(self.img, "", self.index * 180, 255, 255, 255)
        Render(self.img, px, py, self.timer * 2, size / 56)
    end
}, true)
class4.protect_moon = protect_moon

local protect_dish = Class(object, {
    init = function(self, x, y)
        self.layer = LAYER.PLAYER - 2
        self.colli = true
        self.killflag = true
        self.group = GROUP.PLAYER
        self.index = 0
        self._index = 0
        self.r = 20
        self.open = false
        self.img = "level_obj_dish"
        self.x, self.y = x, y
        self._x, self._y = x, y
        self._index = 1
        self.count = 0
        self.addcount = function()
            self.count = self.count + 1
            if ran:Float(0, 1) < self.count * 0.005 then
                self.colli = false
            end
        end
        task.New(self, function()
            while self.colli do
                task.Wait()
            end
            for _ = 1, self.count do
                New(water_drop_bullet, self.x, self.y, ran:Float(4, 8), 90 + ran:Float(-50, 50), player.damage * 1.2, 120)
            end
            self._index = 0
            PlaySound("water")
            task.Wait(25)
            Del(self)
        end)
    end,
    frame = function(self)
        task.Do(self)
        self.y = self._y + sin(self.timer * 2) * 5
        self.index = self.index + (-self.index + self._index) * 0.1
        self.a = self.index * self.r
        self.b = self.a
        if self.colli then
            cutLasersByCircle(self.x, self.y, self.a, self.addcount)
        end
    end,
    colli = function(self, other)
        if other.group == GROUP.ENEMY_BULLET then
            object.Del(other)
            self.addcount()
        end
    end,
    render = function(self)
        local px, py = self.x, self.y
        local size = self.index * self.r

        SetImageState(self.img, "mul+add", self.index * 150, 255, 255, 255)
        Render(self.img, px, py, 180 + 180 * self.index, (self.r) * (2 - self.index) / 120)
        SetImageState("bright", "mul+add", 150 * self.index, 255, 255, 255)
        Render("bright", self.x, self.y, 0, 35 / 130)
    end
}, true)
class4.protect_dish = protect_dish

local igiari_object = Class(object, {
    init = function(self, x, y)
        self.layer = LAYER.PLAYER - 2
        self.colli = false
        self.killflag = true
        self.group = GROUP.PLAYER
        self.index = 0
        self.r = 40
        self.open = false
        self.img = "level_obj_igiari"
        self.x, self.y = x, y
        self._x, self._y = x, y
        lstg.var.igiari_mode = 1 - lstg.var.igiari_mode
        local sound_name = lstg.var.igiari_mode == 0 and "igiari1" or "igiari2"
        PlaySound(sound_name)
        task.New(self, function()
            for i = 1, 10 do
                self.index = task.SetMode[2](i / 10)
                task.Wait()
            end
            task.Wait(35)
            for i = 1, 12 do
                self.index = 1 - task.SetMode[2](i / 12)
                task.Wait()
            end
            Del(self)
        end)
    end,
    frame = function(self)
        task.Do(self)
        local R = max(0, 6 - self.timer / 5)
        local A = self.timer * 78
        self.x = self._x + cos(A) * R
        self.y = self._y + sin(A) * R
        self.a = self.index * self.r
        self.b = self.a
    end,
    render = function(self)
        local px, py = self.x, self.y
        SetImageState(self.img, "", self.index * 150, 255, 255, 255)
        Render(self.img, px, py, 0, (self.r) * (2 - self.index) / 120)
    end
}, true)
class4.igiari_object = igiari_object

local igiari_shooter = Class(object, {
    init = function(self)
        self.layer = LAYER.PLAYER - 2
        self.colli = false
        self.killflag = true
        self.group = GROUP.GHOST
        task.New(self, function()
            while true do
                local maxhp = 0
                local hp = 0
                local e
                while not IsValid(e) do
                    maxhp = 0
                    hp = 0
                    object.EnemyNontjtDo(function(o)
                        if o.colli and o.class.base.take_damage and not o.IsBoss and not o.protect then
                            hp = o.hp
                            if o.last_priority then
                                hp = 1
                            end
                            if hp > maxhp then
                                maxhp = hp
                                e = o
                            end
                        end
                    end)
                    task.Wait()
                end
                local k = 0
                while k < 180 do
                    local flag = false
                    maxhp = 0
                    hp = 0
                    object.EnemyNontjtDo(function(o)
                        if o.colli and o.class.base.take_damage and not o.IsBoss and not o.protect then
                            hp = o.hp
                            if o.last_priority then
                                hp = 1
                            end
                            if hp > maxhp then
                                maxhp = hp
                                e = o
                            end
                            flag = true

                        elseif not flag then
                            k = 0
                        end
                    end)
                    task.Wait()
                    k = k + 1
                end
                maxhp = 0
                hp = 0
                while not IsValid(e) do
                    maxhp = 0
                    hp = 0
                    object.EnemyNontjtDo(function(o)
                        if o.colli and o.class.base.take_damage and not o.IsBoss and not o.protect then
                            hp = o.hp
                            if o.last_priority then
                                hp = 1
                            end
                            if hp > maxhp then
                                maxhp = hp
                                e = o
                            end
                        end
                    end)
                    task.Wait()
                end
                if IsValid(e) then
                    if e.class.base.take_damage then
                        e.class.base.take_damage(e, e.maxhp)
                    end
                    New(igiari_object, e.x, e.y)
                end
            end
        end)
    end,
    frame = function(self)
        task.Do(self)
    end
}, true)
class4.igiari_shooter = igiari_shooter

return class4
