local table = table
local ChangeImage

local Nue_bullet_event = {
    function(self)
        task.New(self, function()
            while true do
                bullet.ChangeImage(self, bulletStyles[ran:Int(1, #bulletStyles)], self._index)
                task.Wait(ran:Int(10, 22))
            end
        end)
    end,
    function(self)
        task.New(self, function()
            while true do
                bullet.ChangeImage(self, self.imgclass, ran:Int(1, 16))
                task.Wait(ran:Int(10, 30))
            end
        end)
    end,
    function(self)
        task.New(self, function()
            while true do
                object.SetSizeColli(self, ran:Float(0.5, 1.2))
                task.Wait(ran:Int(150, 300))
            end
        end)
    end,
    function(self)
        task.New(self, function()
            while true do
                if ran:Int(1, 2) == 1 then
                    self.vx, self.vy = -self.vx, -self.vy
                    self.ax, self.ay = -self.ax, -self.ay
                    self.ag = -self.ag
                end
                task.Wait(ran:Int(120, 300))
            end
        end)
    end,
    function(self)
        task.New(self, function()
            task.Wait(ran:Int(0, 300))
            task.Clear(self, true)
            self._frozen = true
            task.Wait()
            object.StopMoving(self)
            if self.group == GROUP.ENEMY_BULLET then
                task.Wait(120)
                object.RawDel(self)
            end
        end)
    end,
    function(self)
        task.New(self, function()
            while true do
                if ran:Float(0, 1) < 0.10 then
                    item.dropItem(item.drop_exp, 1, self.x, self.y)
                    object.RawDel(self)
                end
                task.Wait(20)
            end
        end)
    end,
}
local function DelBulletFunc(self, drop_p)
    local w = lstg.world
    local inbound = BoxCheck(self, w.boundl, w.boundr, w.boundb, w.boundt)
    local wea = lstg.weather
    local var = lstg.var
    if self._index and inbound then
        BulletBreak_Table:New(self.x, self.y, self._index)

    end
    if self.imgclass.size == 2.0 then
        self.imgclass.del(self)
    end
    if inbound then
        if var._season_system then

            if wea.DaXue and self.imgclass ~= ball_small then
                local x, y = self.x, self.y
                for _ = 1, ran:Int(0, 3) do
                    local b = NewSimpleBullet(ball_small, 8, x, y, 1.6, ran:Float(0, 360))
                    b.ag = 0.03
                    b.omega = ran:Float(2, 3) * ran:Sign()
                    b.maxvy = 4.3
                end
            end
            if wea.JuanYun then
                if ran:Float(0, 1) < 0.1 then
                    item.dropItem(item.drop_exp, 1, self.x, self.y)
                end
            end
        end
        if var.quantum_bullet and not self._isQuantum then
            for _, obj in ObjList(GROUP.ENEMY_BULLET) do
                if obj.imgclass == self.imgclass then
                    obj._isQuantum = true
                    Del(obj)
                    break
                end
            end
        end
        if var.protect_lotus then
            stg_levelUPlib.class2.add_protect_lotus_c(1)
        end
        if (drop_p or var.powerful_point) and not var.stop_getting then
            New(item.drop_point, self.x, self.y)
        end
    end

end
--------------------------
---支持拖影
---@class bullet
local bullet = Class(object)
_G.bullet = bullet
function bullet:frame()
    task.Do(self)
    local v = lstg.var
    local tvar = lstg.tmpvar
    self._no_colli = self._no_colli or (v.friendly_ball_huge and self.imgclass == ball_huge)
    self.colli = self.colli and not self._no_colli
    self.__salpha = self._no_colli and 0.2 or 1
    self._salpha = self._salpha + (-self._salpha + self.__salpha) * 0.3
    if tvar.cyoltose_style == self.imgclass and tvar.cyoltose_color == self._index then
        Del(self)
    end
end
function bullet:kill()
    DelBulletFunc(self, true)
end
function bullet:del()
    DelBulletFunc(self)
end
function bullet:render()
    local c = self.imgclass
    local A = self._salpha
    local w = lstg.weather
    local v = lstg.var
    local alpha = self._a * A
    if w.ShuangJiang then
        c.SetColorFunc(self.img, "add+add", alpha, 255, 255, 255)
        c.RenderFunc(self.img, self.x, self.y + 1, self.rot, self.hscale, self.vscale, 0.5, self.ani)
    end
    if w.GuWuYu and self.GuWuYu_index then
        local img = "grain_a" .. self.GuWuYu_index
        SetImageState(img, self._blend, alpha, self._r, self._g, self._b)
        Render(img, self.x, self.y, self.rot, self.hscale, self.vscale)
    else
        local blend = self._blend
        if self.xiaoxue_frozen then
            blend = "add+add"
        end
        c.SetColorFunc(self.img, blend, alpha, self._r, self._g, self._b)
        DefaultRenderFunc(self)
    end


end

---一种新的碰撞开关，和透明度有关
function bullet:setfakeColli(flag)
    if not self._force_colli then
        self._no_colli = not flag
        self.colli = flag
    end
end

---@param imgclass bulletStyle
---@param index number
---@param stay boolean
---@param destroyable boolean
---@param fogtime number@雾化时间
function bullet:init(imgclass, index, stay, destroyable, fogtime)
    self._blend, self._a, self._r, self._g, self._b = "", 255, 255, 255, 255
    self._layer = -200
    self.logclass = self.class
    self.imgclass = imgclass
    self.class = imgclass
    self.smear = {}
    self.group = destroyable and 1 or 5
    self.fogtime = fogtime or 11
    self._salpha = 1
    self.__salpha = 1
    local var = lstg.var
    if var.blood_magic and var.friendly_ball_huge and imgclass == ball_huge then
        index = 2
    end
    if tonumber(index) then
        self.colli = true
        self.stay = stay
        index = int(clamp(index, 1, 16))
        self.layer = self._layer + 100 - imgclass.size * 0.001 + index * 0.00001
        self._index = index
        self.real_index = index
        self.index = int((index + 1) / 2)
    end
    imgclass.init(self, index)
    local v = lstg.var
    local w = lstg.weather
    if ran:Float(0, 1) < v.delete_bullet then
        bullet.setfakeColli(self, false)
        --伊吹大山岚
    end
    if v.nue_special_bullet then
        local p = ran:Float(0, 1)
        if p < 0.3 then
            local t = { 1, 2, 3, 4, 5, 6 }
            if v.stop_getting then
                table.remove(t, 6)
            end
            local _t = {}
            for _ = 1, ran:Int(1, 2) do
                table.insert(_t, table.remove(t, ran:Int(1, #t)))
            end
            for _, c in ipairs(_t) do
                Nue_bullet_event[c](self)
            end
        end
    end
    if v._season_system then
        --天气系统
        w.bullet_init_func(self)
    end
    if lstg.tmpvar._is_challenge18 then
        object.SetSize(self, lstg.tmpvar._is_challenge18)
        object.SetColli(self, self.a * lstg.tmpvar._is_challenge18)
    end
    self.smearImageRender = CheckRes("img", self.img)
end

---@param layer number
---@param real boolean@图层真正是这个(可能会被覆盖)
function bullet:SetLayer(layer, real)
    if real then
        self.layer = layer
    else
        self._layer = layer or LAYER.ENEMY_BULLET
        self.layer = self._layer + ((self.class == self.logclass) and 0 or 100) - self.imgclass.size * 0.001 + self._index * 0.00001
    end
end

---@param imgclass bulletStyle
---@param index number
---@param force boolean@强制修改，下次不再触发该函数
function bullet:ChangeImage(imgclass, index, force)
    if self.IsForceChange then
        return
    end
    if self.class == self.imgclass then
        self.class = imgclass
        self.imgclass = imgclass
    else
        self.imgclass = imgclass
    end
    local var = lstg.var
    if var.blood_magic and var.friendly_ball_huge and imgclass == ball_huge then
        index = 2
    end
    self._index = index

    imgclass.init(self, self._index)
    if force then
        self.IsForceChange = true
    end
    self.smearImageRender = CheckRes("img", self.img)
end
ChangeImage = bullet.ChangeImage

---取消雾化效果
function bullet:RemoveFog()
    self.timer = self.fogtime
end

---重新雾化
function bullet:RestartFog()
    self.class = self.imgclass
    self.timer = 0
end

bullet.ReBound = object.ReBound
bullet.Shuttle = object.Shuttle

local OriginalSmearBlend = "mul+add"
local OriginalSmearColor = { 200, 200, 200 }
bullet.smear_add = object.smear_add
bullet.smear_frame = object.smear_frame
function bullet:smear_render(mode, color)
    mode = mode or OriginalSmearBlend
    color = color or OriginalSmearColor
    local R, G, B = unpack(color)
    if self.smear then
        if self.smearImageRender then
            for _, s in ipairs(self.smear) do
                SetImageState(self.img, mode, max(0, s.alpha), R, G, B)
                Render(self.img, s.x, s.y, s.rot, s.hscale, s.vscale)
            end
        else
            for i, s in ipairs(self.smear) do
                SetAnimationState(self.img, mode, max(0, s.alpha), R, G, B)
                RenderAnimation(self.img, self.ani + i, s.x, s.y, s.rot, s.hscale, s.vscale)
            end
        end
    end

end

---自动根据style设置角度
---并返回设置速度时是否要设置朝向
function bullet:GetNavi()
    self.rot = (self.imgclass == music) and -90 or self.rot
    return (self.imgclass ~= star_small and self.imgclass ~= star_big and self.imgclass ~= music) and true
end
----------------------------------------------------------------

------bullet_break--------
--牺牲内存优化运行性能
LoadTexture('etbreak', 'assets\\bullet\\etbreak.png')
for j = 1, 16 do
    LoadImageGroup('etbreak' .. j, 'etbreak', 0, 0, 128, 128, 4, 2)
    for i = 1, 8 do
        SetImageScale('etbreak' .. j .. i, 0.5)
    end
end

BulletBreak_Table = Class(object, { bulletbreak = {} })
function BulletBreak_Table:init()
    self.group = GROUP.GHOST
    self.layer = LAYER.ENEMY_BULLET - 50
    self.x, self.y = 0, 0
    self.bound = false
    self.class = BulletBreak_Table
    self.class.bulletbreak = {}
    BulletBreakIndex = {
        Color(192, sp:HSVtoRGB(0, 0.5, 0.75)),
        Color(192, sp:HSVtoRGB(0, 0.5, 1)), --red
        Color(192, sp:HSVtoRGB(295, 0.5, 0.75)),
        Color(192, sp:HSVtoRGB(295, 0.5, 1)), --purple
        Color(192, sp:HSVtoRGB(240, 0.5, 0.75)),
        Color(192, sp:HSVtoRGB(240, 0.5, 1)), --blue
        Color(192, sp:HSVtoRGB(189, 0.5, 0.75)),
        Color(192, sp:HSVtoRGB(189, 0.5, 1)), --cyan
        Color(192, sp:HSVtoRGB(113, 0.5, 0.75)),
        Color(192, sp:HSVtoRGB(113, 0.5, 1)), --green
        Color(192, sp:HSVtoRGB(61, 0.5, 0.75)),
        Color(192, sp:HSVtoRGB(61, 0.5, 1)), --yellow
        Color(192, sp:HSVtoRGB(20, 0.5, 0.75)),
        Color(192, sp:HSVtoRGB(20, 0.5, 1)), --orange
        Color(192, sp:HSVtoRGB(0, 0, 0.75)),
        Color(192, sp:HSVtoRGB(0, 0, 1)), --gray
    }
    for j = 1, 16 do
        for l = 1, 8 do
            SetImageState('etbreak' .. j .. l, 'mul+add', BulletBreakIndex[j])
        end
    end
end
function BulletBreak_Table:frame()
    local b
    for i = #self.class.bulletbreak, 1, -1 do
        b = self.class.bulletbreak[i]
        b.timer = b.timer + 1
        if b.timer == 23 then
            table.remove(self.class.bulletbreak, i)
        end
    end
end
function BulletBreak_Table:render()
    local b
    for i = #self.class.bulletbreak, 1, -1 do
        b = self.class.bulletbreak[i]
        Render("etbreak" .. b.index .. int(b.timer / 3) + 1, b.x, b.y, b.rot, b.scale / 2)
    end
end
function BulletBreak_Table:New(x, y, index)
    if #self.bulletbreak >= 3000 then
        return
    end
    table.insert(self.bulletbreak, { x = x, y = y, index = index,
                                     scale = ran:Float(0.5, 0.75), rot = ran:Float(0, 360), timer = 0 })
end

Include("THlib\\bullet\\bulletStyle.lua")
Include("THlib\\bullet\\clearbullet.lua")

local straight_bullet = Class(bullet, {
    init = function(self, imgclass, index, x, y, v, angle, aim, omega, stay, destroyable, _495, through, frame, render)
        bullet.init(self, imgclass, index, stay, destroyable)
        self.x = x
        self.y = y
        self.rot = angle
        if aim then
            self.rot = self.rot + Angle(self, player)
        end
        self.omega = omega

        object.SetV(self, v, self.rot, true)
        self._495 = _495
        self.through = through
        self.frame_other = frame
        self.render_other = render
    end,
    frame = function(self)
        bullet.frame(self)
        bullet.Shuttle(self, { "l", "r" }, nil, self.through, function(o)
            o.through = nil
        end)
        bullet.ReBound(self, { "l", "r", "t" }, nil, self._495, function(o)
            o._495 = nil
        end)
        if self.frame_other then
            self.frame_other(self)
        end
    end,
    render = function(self)
        bullet.render(self)
        if self.render_other then
            self.render_other(self)
        end
    end,
    kill = function(self)
        bullet.kill(self)
        if self.kill_other then
            self.kill_other(self)
        end
    end,
    del = function(self)
        bullet.del(self)
        if self.del_other then
            self.del_other(self)
        end
    end
})

---@param style bulletStyle
---@param color number
---@param x number
---@param y number
---@param v number
---@param  a number
---@param aim boolean
---@param omega number
---@param stay boolean
---@param destroyable boolean
---@param rebound boolean
---@param through boolean
function NewSimpleBullet(style, color, x, y, v, a, aim, omega, stay, destroyable, rebound, through, frame, render)
    return New(straight_bullet,
            style, color, x, y, v or 0, a or 0, aim,
            omega or 0,
            (stay or stay == nil) and true,
            (destroyable or destroyable == nil) and true,
            rebound,
            through,
            frame,
            render)
end

