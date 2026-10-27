local path = "assets\\item\\"
LoadTexture('item', path .. 'item.png')
LoadImageGroup('item', 'item', 0, 0, 32, 32, 2, 5, 8, 8)
LoadImageGroup('item_up', 'item', 64, 0, 32, 32, 2, 5)

LoadImageFromFile("item_drop_point", path .. "drop_point.png", true, 8, 8)
SetImageState("item_drop_point", "mul+add")
LoadImageFromFile("item_drop_exp", path .. "drop_exp.png", true, 8, 8)
LoadImageFromFile("item_drop_dewdrop", path .. "dewdrop.png", true, 12, 12)

local lstg, ran = lstg, ran
local max, min, Forbid = max, min, clamp
local SetV = SetV
---@class item
local item = Class(object)
_G.item = item
function item:init(x, y, t, v, angle)
    self.x = Forbid(x, lstg.world.l + 8, lstg.world.r - 8)
    self.y = y
    self.v = v or 2.5
    SetV(self, self.v, angle or 90)
    self.group = 6
    self.layer = -300
    self.bound = false
    self.img = 'item' .. t
    self.imgup = 'item_up' .. t
    self.attract = 0
    self.collect_online = true
    self.py = y
    self.t = 0
    self._vy = 0
    self._scale = 0
    self.__scale = 1
    if lstg.tmpvar._is_challenge18 then
        self.__scale = self.__scale * lstg.tmpvar._is_challenge18
    end
    self._blend = ""
    self._a, self._r, self._g, self._b = 255, 255, 255, 255
    self.fall_v = 1.7
    self.fall_a = 0.03
end

function item:render()
    if self.y > lstg.world.t and not self.no_up_render and self.imgup then
        Render(self.imgup, self.x, lstg.world.t - 8)
    else
        SetImageState(self.img, self._blend, self._a, self._r, self._g, self._b)
        Render(self.img, self.x, self.y, self.rot, self.hscale, self.vscale)
    end
end

function item:frame()
    task.Do(self)
    local player = self.target or player
    self.t = self.t + 1
    if self.timer == 1 then
        self.rot = -45
    end

    if self.t == 24 then

        self.py = self.y
    end
    if self.t < 24 then
        self._scale = min(self.__scale, self._scale + self.__scale / 24)
        self.rot = 45 * self.t + 45
        self.hscale = (self.t + 25) / 48 * self._scale
        self.vscale = self.hscale
        if self.timer < 24 then
            self.y = self.py + self.v * self.t - 0.5 * self.v / 48 * self.t * self.t
        end
        if self.t == 22 then
            self.vx = 0
        end
    else
        local _a = self.fall_a or 0.03
        if self.attract <= 0 then
            self._vy = max(-self.fall_v, self._vy - _a)
            self.vy = self._vy
        end
    end
    if self.timer > 24 and self.attract > 0 then
        SetV(self, self.attract, Angle(self, player))
        self.x = self.x + player.dx * 0.5
        self.y = self.y + player.dy * 0.5
    end
    if self.y < lstg.world.boundb or self.y > lstg.world.boundt + 65 then
        object.Del(self)
    end
    if self.attract >= 8 then
        self.collected = true
    end
    if lstg.var.MAX_M then
        local index = 0.002
        if lstg.var.neutron_star then
            index = 0.003
        end
        self.ac_MAX_M = self.ac_MAX_M or 0
        self.ac_MAX_M = self.ac_MAX_M + index
        local A = Angle(self, player)
        self.x = self.x + cos(A) * self.ac_MAX_M
        self.y = self.y + sin(A) * self.ac_MAX_M
    end
end

---不可以上线收集的frame
function item:frame2()
    task.Do(self)
    local player = self.target or player
    self.t = self.t + 1
    if self.timer == 1 then
        self.rot = -45
    end

    if self.t == 24 then

        self.py = self.y
    end
    if self.t < 24 then
        self._scale = min(self.__scale, self._scale + self.__scale / 24)
        self.rot = 45 * self.t + 45
        self.hscale = (self.t + 25) / 48 * self._scale
        self.vscale = self.hscale
        if self.timer < 24 then
            self.y = self.py + self.v * self.t - 0.5 * self.v / 48 * self.t * self.t
        end
        if self.t == 22 then
            self.vx = 0
        end
    else
        local _a = self.fall_a or 0.03
        self._vy = max(-self.fall_v, self._vy - _a)
        self.vy = self._vy
    end
    if self.timer > 24 and self.attract > 0 and self.get_player then
        SetV(self, self.attract, Angle(self, player))
        self.vx = self.vx + player.dx * 0.5
        self.vy = self.vy + player.dy * 0.5
    end
    if self.y < lstg.world.boundb or self.y > lstg.world.boundt + 65 then
        object.Del(self)
    end
    if lstg.var.MAX_M then
        local index = 0.002
        if lstg.var.neutron_star then
            index = 0.003
        end
        self.ac_MAX_M = self.ac_MAX_M or 0
        self.ac_MAX_M = self.ac_MAX_M + index
        local A = Angle(self, player)
        self.x = self.x + cos(A) * self.ac_MAX_M
        self.y = self.y + sin(A) * self.ac_MAX_M
    end
end

function item:colli(other)
    if other == player then
        if self.class.collect then
            self.class.collect(self, other)
        end
        object.Kill(self)
        PlaySound('item00', 0.3, self.x / 200)

    end
end

function item.dropItem(item_obj, num, x, y, ...)
    for _ = 1, num do
        local r2 = sqrt(ran:Float(1, 4)) * sqrt(num - 1) * 5
        local a = ran:Float(0, 360)
        New(item_obj, x + r2 * cos(a), y + r2 * sin(a), ...)
    end
end

item.drop_point = Class(object)
function item.drop_point:init(x, y)
    x = Forbid(x, lstg.world.l + 8, lstg.world.r - 8)
    self.x = x
    self.y = y
    SetV(self, 1.5, 90)
    self.v = 1.5
    self.group = GROUP.ITEM
    self.layer = LAYER.ITEM
    self.bound = false
    self.img = "item_drop_point"
    self.attract = 0
    self.collect_online = true
    self.py = y
    self.t = 0
    self._vy = 0
    self._scale = 1
    if lstg.tmpvar._is_challenge18 then
        self._scale = self._scale * lstg.tmpvar._is_challenge18
    end
    self.is_drop_point = true
    if not BoxCheck(self, lstg.world.l, lstg.world.r, lstg.world.b, lstg.world.t) then
        object.RawDel(self)
    end
    self.vx = ran:Float(-0.15, 0.15)
    self._vy = ran:Float(3.25, 3.75)
    self.flag = 1
    self.is_minor = true
    self.target = player
    if GetnObj() >= 5000 then
        self.class.collect(self)
        Del(self)
    end
end
function item.drop_point:frame()
    local player = self.target
    if self.timer < 45 then
        self.vy = self._vy - self._vy * self.timer / 45
    end
    if self.timer >= 54 and self.flag == 1 then
        SetV(self, 8, Angle(self, player))
    end
    if self.timer >= 54 and self.flag == 0 then
        if self.attract > 0 then
            local a = Angle(self, player)
            self.vx = self.attract * cos(a) + player.dx * 0.5
            self.vy = self.attract * sin(a) + player.dy * 0.5
        else
            self.vy = max(self.dy - 0.03, -2.5)
            self.vx = 0
        end
        if self.y < lstg.world.boundb or self.y > lstg.world.boundt + 65 then
            object.Del(self)
        end
    end
end
function item.drop_point:collect()
    local v = lstg.var
    v.score = v.score + 500
    if v.powerful_point and not v.stop_getting then
        player_lib.AddEnergy(0.02)
    end
end
function item.drop_point:colli(other)
    if other == player then
        if self.class.collect then
            self.class.collect(self, other)
        end
        object.Kill(self)
        PlaySound('item00', 0.3, self.x / 200)

    end
end

local AccumulateFunc = {
    function()
        player_lib.AddLife(0.03)
    end,
    function()
        AddExp(0.3)
    end,
    function()
        local v = lstg.var
        local addscore = int(v.score * 0.0001 / 10) * 10
        v.score = v.score + addscore
    end,
    function()
        player_lib.AddEnergy(0.5)
    end,
    function()
        AddExp(0.7)
    end,
    function()

    end,
    function()
        player_lib.AddLife(0.1)
    end,
    function()
        local p = player
        p.dmg_offset = p.dmg_offset + 0.005
    end,
    function()

        player_lib.AddMaxLife(0.03)
    end,
}

local drop_exp_table = {}
item.drop_exp = Class(item)
function item.drop_exp:init(x, y)
    item.init(self, x, y, 5)
    sp:UnitListUpdate(drop_exp_table)
    sp:UnitListAppend(drop_exp_table, self)
    if #drop_exp_table > 2000 then
        item.drop_exp.collect(self, nil, true)
        Del(self)
    end
    self.imgup = nil
    self.img = "item_drop_exp"
    self._blend = "mul+add"
    self.__scale = 0.5
    if lstg.tmpvar._is_challenge18 then
        self.__scale = self.__scale * lstg.tmpvar._is_challenge18
    end
    self._scale = 0
    self.is_exp = true
    self._a, self._r, self._g, self._b = 120, 255, 255, 255
    self.can_collect_online = true
    if lstg.var.greedy_exp then
        self.attract = 10
    elseif lstg.weather.MangZhong then
        self.vx, self.vy = 0, 0
        object.SetSize(self, self.__scale)
        task.New(self, function()
            task.MoveToEx(ran:Float(-12, 12), ran:Float(-12, 12), 15, 2)
            while lstg.weather.MangZhong do
                if ran:Float(0, 1) < 0.09 then
                    task.New(self, function()
                        task.MoveToEx(ran:Float(-12, 12), ran:Float(-12, 12), 15, 2)
                    end)
                    New(item.drop_exp, self.x, self.y)
                end
                task.Wait(60)
            end
        end)
    end

end
function item.drop_exp:frame()
    local df = lstg.var.exp_drop_factor
    self.fall_a = 0.03 * df
    self.fall_v = 1.7 * df
    if lstg.weather.MangZhong and not lstg.var.greedy_exp then
        if self.timer >= 999 then
            object.Del(self)
        end
        if self.get_player then
            SetV(self, 3, Angle(self, player))
            self.vx = self.vx + player.dx * 0.5
            self.vy = self.vy + player.dy * 0.5
        end
        task.Do(self)
    elseif self.can_collect_online then
        item.frame(self)
    else
        item.frame2(self)
    end
end
function item.drop_exp:collect(_, nokiller)
    AddExp(1)
    local v = lstg.var
    v.score = v.score + 100
    if v.accumulate_exp > 0 then
        AccumulateFunc[ran:Int(1, min(v.accumulate_exp * 3, 9))]()
    end
    if v.philosopher_stone then
        local p = player
        local ss = p.shoot_set.speed
        ss.offset = ss.offset + 0.012
        p.dmg_offset = p.dmg_offset + 0.012
        v.philosopher_stone_n = v.philosopher_stone_n + 1
    end
    if v.game_killer and not nokiller then
        New(stg_levelUPlib.class4.game_killer, self.x, self.y)
    end
    if v.native_faith then
        player_lib.AddEnergy(0.1)
    end
end
function item.drop_exp:del()
    if not IsSpecialMode() then
        scoredata._total_miss_exp = scoredata._total_miss_exp + 1
    end
end

item.drop_hp = Class(item)
function item.drop_hp:init(x, y)
    item.init(self, x, y, 3)
end
function item.drop_hp:collect()
    PlaySound("lgods1")
    player_lib.AddLife(20)
    local var = lstg.var
    var.score = var.score + 1000
    if var.chip_addmaxlife then
        player_lib.AddMaxLife(7)
    end
    if var.chip_adddmg then
        player.dmg_offset = player.dmg_offset + 1
        player_lib.AddEnergy(25)
    end
    if var.cowrie_shell then
        if var.weak_life > 0 then
            player_lib.AddLife(var.maxweak_life)
            var.maxweak_life = 0
        end
    end
end

item.drop_dewdrop = Class(item)
function item.drop_dewdrop:init(x, y)
    item.init(self, x, y, 3)
    self.img = "item_drop_dewdrop"
    self.imgup = nil
    self._blend, self._a, self._r, self._g, self._b = "mul+add", 150, 255, 255, 255
end
function item.drop_dewdrop:collect()
    PlaySound("lgods2", 0.1)
    local var = lstg.var
    player_lib.AddLife(var.maxlife * 0.005)
    var.score = var.score + 100
end

item.drop_card = Class(item)
function item.drop_card:init(x, y, id, collet_func)
    item.init(self, x, y, 3)
    self.addition = stg_levelUPlib.AdditionTotalList[id]
    self.img = "addition_state" .. self.addition.state
    self.id = id

    self.a, self.b = 16, 16
    self.collet_func = collet_func
end
function item.drop_card:render()
    SetImageState("bright", "mul+add", 255, 255, 227, 132)
    Render("bright", self.x, self.y, 0, self._scale * 0.43)
    SetImageState(self.img, "", 200, 255, 255, 255)
    Render(self.img, self.x, self.y, sin(self.timer * 2) * 6, self._scale * 0.2)
end
function item.drop_card:collect()
    PlaySound("lgods2")
    local list = {  }
    local lib = stg_levelUPlib
    if self.collet_func then
        self.collet_func()
    end
    local nowget = lstg.var.addition[self.id] or 0
    self.can_get = (nowget + 1) <= (self.addition.maxcount or 999)
    self.can_two = (nowget + 2) <= (self.addition.maxcount or 999)
    if self.can_get then
        table.insert(list, self.addition)
    end
    table.insert(list, lib.NoneAddition())
    if self.can_two then
        table.insert(list, lib.TwiceAddition(function()
            lib.AdditionTotalList[self.addition.id]:Set()
            lib.AdditionTotalList[self.addition.id]:Set()
            local dmglist = {}
            for _, p in pairs(lib.AdditionTotalList) do
                if p.state == 3 then
                    table.insert(dmglist, p)
                end
            end
            local tid = ran:Int(1, #dmglist)
            dmglist[tid]:Set()
            ext.popup_menu:FlyInOneTool(i18n("addition", "costOfDouble"), 250, 100, 100, dmglist[tid].id, "invalid")
        end))
    end
    if ran:Float(0, 1) < 0.3 then
        table.insert(list, lib.GetAdditionList(1, function(tool)
            return (tool.id ~= self.addition.id)
        end)[1])
    end

    ext.level_menu:FlyIn(list, nil, true)
    local tvar = lstg.tmpvar
    if tvar.ToolItemGet_event then
        tvar.ToolItemGet_event()
        tvar.ToolItemGet_event = nil
    end
end

item.drop_addition_sp = Class(item)
item.drop_addition_sp.frame = item.frame2
function item.drop_addition_sp:init(x, y, id, collet_func, otherflag)
    item.init(self, x, y, 3)
    self.addition = stg_levelUPlib.AdditionTotalList[id]
    self.img = "addition_state" .. self.addition.state
    self.a, self.b = 16, 16
    self.R, self.G, self.B = self.addition.R, self.addition.G, self.addition.B
    self.fall_v = 2.9
    self.collet_func = collet_func
    self.id = id
    self.__otherflag = otherflag
end
function item.drop_addition_sp:render()
    SetImageState("bright", "mul+add", 200, self.R, self.G, self.B)
    Render("bright", self.x, self.y, 0, self._scale * 0.43)
    SetImageState(self.img, "", 200, 255, 255, 255)
    Render(self.img, self.x, self.y, sin(self.timer * 2) * 6, self._scale * 0.2)
end
function item.drop_addition_sp:collect()
    if self.collet_func then
        self.collet_func()
    end
    PlaySound("lgods2")
    local nowget = lstg.var.addition[self.id] or 0
    self.can_get = (nowget + 1) <= (self.addition.maxcount or 999)
    if self.can_get then
        self.addition:Set(true)
    end

end