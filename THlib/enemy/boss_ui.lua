--======================================
--th style boss ui
--======================================

local Forbid = clamp
local sin, abs = sin, abs
local min, max = min, max
local string = string
local IsValid = IsValid
local SetViewMode = SetViewMode
local SetFontState = SetFontState
local SetImageState = SetImageState
local SetRenderRect = SetRenderRect
local RenderText = RenderText
local Render = Render
----------------------------------------

---@class boss.ui
boss.ui = Class(object)
function boss.ui:init(system, b)
    self.layer = LAYER.TOP + 2
    self.boss = b
    self.system = system
    self.drawhp = true
    self.drawname = true
    self.drawtime = true
    self.drawspell = true
    self.needposition = true
    self.drawpointer = true
    self.drawtimesaver = nil
    self.infobar = boss.infobar(self, self.system)

    self.timeCounter = boss.timeCounter(self, self.system)
    self.pointer = boss.pointer(self, self.system)
end
function boss.ui:frame()
    if IsValid(self.boss) then
        if self.infobar then
            self.infobar:frame()
        end
        if self.timeCounter then
            self.timeCounter:frame()
        end
        if self.pointer then
            self.pointer:frame()
        end
    else
        object.Del(self)
    end
end
function boss.ui:render()
    if IsValid(self.boss) then
        if self.infobar and not self.no_infobar then
            self.infobar:render()
        end
        if self.timeCounter and not self.no_timeCounter then
            self.timeCounter:render()
        end
        if self.pointer and not self.no_pointer then
            self.pointer:render()
        end
    end
end
----------------------------------------
---boss 计时器
---@class boss.timeCounter
local timeCounter = plus.Class()
---@param ui boss.ui
---@param system boss.system
function timeCounter:init(ui, system)
    self.ui = ui
    self.system = system
    self.x, self.y = 176, 185
    self.oldstyle = true
    self.scale = 0.8
    self.scalewarning = 1
    self.scalewarning_current = 1.0
    self.scalewarning_1 = 1.5
    self.scalewarning_2 = 2
    self.yoffset = 0
    self.yoffsettemp = 0
    self.yoffsetmax = 28
    self.yoffsetspeedrate = 0.4
    self.yoffset2 = 0
    self.open = false
    self.t1 = 10
    self.t2 = 5
    self.sound = true
    self.flag = 0
    self.cd1 = 0
    self.cd2 = 0
end
function timeCounter:frame()
    local _ui = self.ui
    local b = self.system.boss
    if not (IsValid(b)) then
        return
    end
    assert(self.t2 <= self.t1, "time counter's t1 > t2 must be satisfied.")
    if _ui.countdown and self.sound then
        if _ui.countdown > self.t2 and _ui.countdown <= self.t1 and _ui.countdown % 1 == 0 then
            if not b.NotPlayTimeOutSound then
                PlaySound("timeout", 0.6)
            end
            self.scalewarning = self.scalewarning_1
            self.scalewarning_current = self.scalewarning_1
        end
        if _ui.countdown > 0 and _ui.countdown <= self.t2 and _ui.countdown % 1 == 0 then
            if not b.NotPlayTimeOutSound then
                PlaySound("timeout2", 0.8)
            end
            self.scalewarning = self.scalewarning_2
            self.scalewarning_current = self.scalewarning_2
        end
    end
    if not (self.open) then
        if not (b.__is_waiting) and b.is_combat then
            if b.is_sc then
                self.yoffsettemp = self.yoffsetmax
            else
                self.yoffsettemp = 0
            end
            self.open = true
        end
    elseif (b.__is_waiting and (lstg.player.dialog or not self.ui.drawtimesaver)) or (not (b.is_combat) and (lstg.player.dialog or not self.ui.drawtimesaver)) then
        self.open = false
        self.ui.drawtimesaver = nil
    end
    if self.open then
        if b.is_sc then
            self.yoffsettemp = max(self.yoffsettemp - 1 * self.yoffsetspeedrate, 0)
            local s = self.yoffsettemp / self.yoffsetmax
            self.yoffset = (s * s) * self.yoffsetmax
        else
            self.yoffsettemp = min(self.yoffsettemp + 1 * self.yoffsetspeedrate, self.yoffsetmax)
            local s = self.yoffsettemp / self.yoffsetmax
            self.yoffset = (s * s) * self.yoffsetmax
        end

        if not self.ui.drawtimesaver or _ui.countdown ~= 0 then
            self.cd1 = _ui.countdown
        end

        if not b.is_combat and self.ui.drawtimesaver and not lstg.player.dialog then
            self.cd1 = self.ui.drawtimesaver
        end

        self.cd2 = (self.cd1 - int(self.cd1)) * 100
        if IsValid(player) and Dist(player.x, player.y, self.x, self.y) <= 70 then
            self.flag = self.flag + 1
        else
            self.flag = self.flag - 1
        end
        self.flag = Forbid(self.flag, 0, 18)
    else
        self.flag = 0
    end
    if self.scalewarning > 1 then
        self.scalewarning = self.scalewarning - (self.scalewarning_current - 1.0) * 0.2
    else
        self.scalewarning = 1
        self.scalewarning_current = 1.0
    end
end
function timeCounter:render()
    local b = self.system.boss
    if not (IsValid(b)) then
        return
    end
    if self.open and self.ui.drawtime then
        local w = lstg.world
        local scrx, scry = w.scrr - 672, w.scrt - 494
        local alpha1 = (1 - self.flag / 30) * min(b.timer / 30, 1)
        local cd1, cd2 = max(self.cd1, 0), max(self.cd2, 0)
        local dy = (b.ui_slot - 1) * 44
        local x = self.x + scrx
        local y1 = self.y + self.yoffset - dy + self.yoffset2 * 30 + scry
        local ttf = "bonus2"
        if cd1 >= self.t1 then
            SetFontState(ttf, "", alpha1 * 255, 255, 255, 255)
        elseif cd1 >= self.t2 then
            SetFontState(ttf, "", alpha1 * 255, 255, 144, 144)
        else
            SetFontState(ttf, "", alpha1 * 255, 255, 48, 48)
        end
        if self.cd1 >= 99.99 and b.__disallow_100sec then
            cd1 = 99
            cd2 = 99
        end
        RenderText(ttf, string.format("%d", int(cd1)), x - 4, y1, self.scale * self.scalewarning, "vcenter", "right")
        RenderText(ttf, ".", x + 1, y1, self.scale, "vcenter", "right")
        RenderText(ttf, string.format("%d%d", min(cd2 / 10, 9), min(cd2 % 10, 9)),
                x, y1 - 2, self.scale * 0.6, "vcenter", "left")
    end
end
boss.timeCounter = timeCounter

----------------------------------------
---boss 下标
---@class boss.pointer
local pointer = plus.Class()
---@param ui boss.ui
---@param system boss.system
function pointer:init(ui, system)
    self.ui = ui
    self.system = system
    self.y = lstg.world.b
    self.scale = 1
    self.EnemyIndicater = 0
end
function pointer:frame()
    local b = self.system.boss
    if not (IsValid(b)) then
        return
    end
    if b.hp >= 0 then
        self.EnemyIndicater = self.EnemyIndicater + max(b.maxhp / 2 - b.hp, 0) / (b.maxhp / 2) * 90
    end
end
function pointer:render()
    local _ui = self.ui
    local b = self.system.boss
    if not (IsValid(b)) then
        return
    end
    if _ui.pointer_x and _ui.drawpointer then
        local w = lstg.world
        local scale = self.scale
        SetRenderRect(w.l, w.r, w.b - max(16 * scale, 0), w.t,
                w.scrl, w.scrr, w.scrb - max(16 * scale, 0), w.scrt)
        local x, y = _ui.pointer_x, self.y
        local distsub = 1
        distsub = min(1 - (min(abs(x - player.x), 64) / 128), distsub)
        local hpsub = (sin(self.EnemyIndicater + 270) + 1) * 0.125
        local alpha = (1 - distsub * 0.6 - hpsub) * 255
        SetImageState("boss_pointer", "", alpha, 255, 255, 255)
        Render("boss_pointer", x, y, 0, self.scale)
        SetViewMode "world"
    end
end
boss.pointer = pointer

----------------------------------------
---boss 信息板
---@class boss.infobar
local infobar = plus.Class()
---@param ui boss.ui
---@param system boss.system
function infobar:init(ui, system)
    self.ui = ui
    self.system = system
    self.offy = 0
    self.x, self.y = -184, 2 + self.offy
    self.t = 0
    self.mt = 15
end
function infobar:frame()
    local b = self.system.boss
    if not (IsValid(b)) then
        return
    end
    self.x, self.y = -184, 219 + self.offy
    local bscl = b.sc_left
    if self.sc_left == nil then
        self.sc_left = bscl
    end
    if self.sc_left > bscl then
        self.t = self.t + self.mt * (self.sc_left - bscl)
        self.sc_left = bscl
    end
    if self.t > 0 then
        self.t = self.t - 1
    end
end
function infobar:render()
    local _ui = self.ui
    local b = self.system.boss
    if not (IsValid(b)) then
        return
    end
    if _ui.drawname then
        local w = lstg.world
        local scrx, scry = w.scrl - 288, w.scrt - 494
        local dy = (b.ui_slot - 1) * 44
        local x, y
        local anisc = int(self.t / self.mt)
        local sc_left = self.sc_left + anisc
        local m = sc_left - 1
        x = self.x - 9 + scrx
        y = self.y - 15 - dy + scry
        for i = 1, m do
            SetImageState("boss_cardleft", "", 255, 255, 255, 255)
            Render("boss_cardleft", x + i * 12, y, 0, 0.5)
        end
        local t, at, x2, y2
        t = self.mt - (self.t - anisc * self.mt)
        at = self.mt
        if self.t > 0 then
            x2 = x + (m + 1) * 12 + t / 5
            y2 = y - t / 5
            SetImageState("boss_cardleft", "", 255 * (1 - (t / at)), 255, 255, 255)
            Render("boss_cardleft", x2, y2, 0, 0.5 + (t / at) * 0.5)
        end
    end
end
boss.infobar = infobar

----------------------------------------
----------------------------------------
---boss 符卡名（gzz式）
---@class boss.sc_name
local sc_name = Class(object)
---@param b object @目标对象
---@param name string @符卡名称
---@param score boolean @是否显示score
function sc_name:init(b, name, score)
    if score == nil then
        score = true
    end
    self.flag = 0
    self.layer = LAYER.TOP + 1
    self.boss = b
    self.name = name or ""
    self.score = score
    self.xp = -8
    self.yp = 0
    if self.name == "" then
        object.RawDel(self)
    end

    self.x = 192
    self.y = 236
    self.ybot = 380
    self.xoffset = 200
    self.xoffset2 = 0
    self.yoffset = -self.ybot
    self.bound = false
    self._scale = 1
    self._scale2 = 1
    self._alpha = 0
    self.talpha = 0
    self.talpha2 = 0
    self.talpha3 = 0
    self.yoffset2 = 0

end
local Smooth = task.Smooth
function sc_name:frame()
    local b = self.boss
    if not self.death then
        local sc_hist = { 0, 0 }
        if IsValid(b) then
            sc_hist = b._sc_hist
        end
        if IsValid(b.ui) then
            self.hide = not (b.ui.drawspell)
            sc_hist = b.ui.sc_hist
        end
        self.sc_hist = sc_hist
    end
    local t, t1, t2, ct, t3 = 60, 30, 30, 10, 40
    local etc = abs(t2 - t3)
    if IsValid(b) then
        local dy = (b.ui_slot - 1) * 44
        self._dy = dy
        local bonus
        if b.sc_bonus then
            bonus = string.format("0%.0f", b.sc_bonus - b.sc_bonus % 10)
        else
            if not self.death then
                bonus = "FAILED"
            else
                bonus = self.bonus
            end
        end
        self.bonus = bonus
    end
    if not (self.death) then
        if self.timer > 30 then
            self.xoffset = max(self.xoffset - 10, 0)
        end
        self.xoffset2 = 0
        if self.timer > 100 + etc and self.timer < 100 + etc + t1 then
            self.talpha = min(self.talpha + (1 / t1), 1)
        end
        if self.timer > 60 + etc and self.timer < 60 + etc + t then
            local tmp = (90 / t) * (self.timer - 60 - etc)
            self.yoffset = -self.ybot + (self.ybot + self.yp) * Smooth(tmp / 90)
        end
        if self.timer > t3 - ct and self.timer < t3 - ct + t2 then
            self.talpha2 = min(self.talpha2 + (1 / t2), 1)
            self.talpha3 = min(self.talpha3 + (1 / t2), 1)
            self._scale2 = max(1 - sin((90 / t2) * (self.timer - t3 + ct)), 0)
        end
        if self.timer < t3 then
            self._scale = max(150 - 120 * sin((90 / t3) * self.timer), 30) / 30
        end
        self._alpha = min(self.timer / t3, 1)
    else
        if IsValid(b) and b.is_exploding and not (self.explodeFlag) then
            self.timer = -60
            self.explodeFlag = true
        end
        if self.timer > 0 then
            self.xoffset = self.xoffset + 6
            self.talpha3 = max(self.talpha3 - 1 / 60, 0)
        end
        self.xoffset2 = self.xoffset
        self._scale = 1
        self._alpha = 1
        if self.timer > 60 then
            object.RawDel(self)
        end
    end
end
function sc_name:render()
    local w = lstg.world
    local scrx, scry = w.scrr - 672, w.scrt - 498
    local x = self.x + self.xoffset + self.xp + scrx
    local y = self.y + self.yoffset - self._dy + self.yp + self.yoffset2 * 30 + scry
    local a_ = 1
    if Dist(player.x, player.y, x - 50, y - 5) <= 90 then
        a_ = 1 - (90 - max(Dist(player.x, player.y, x - 50, y - 5), 40)) / 60
    end
    SetImageState("boss_spell_name_bg", "",
            Color(255 * self.talpha * a_, 255, 255, 255))
    x = self.x + self.xoffset2 + scrx
    Render("boss_spell_name_bg", x, y, 0, 1 + 0.5 * self._scale2)
    x = self.x + self.xoffset2 + self.xp + scrx
    y = y - 9
    ui:RenderText("title", self.name, x, y, self._scale * 0.85, Color(self._alpha * a_ * 255, 255, 255, 255), "right", "noclip")
    --[[
        local sc_hist = self.sc_hist or { 0, 0 }
    if self.score then
        local dy = self._dy
        local xm, ym = 4, -1 --字符坐标偏移值
        x = self.x + self.xoffset - 5 + self.xp + scrx
        y = self.y - dy - 31 + self.yp + scry
        local a = 255 * self.talpha3 * a_
        local fontsize = 0.5


        SetImageState("cardui_history", "", a, 255, 255, 255)
        Render("cardui_history", x - 63 + self.xp, y - 6 + self.yp, 0, 0.5)
        SetImageState("cardui_bonus", "", a, 255, 255, 255)
        Render("cardui_bonus", x - 156 + self.xp, y - 6 + self.yp, 0, 0.5)

        x = x + xm + 4 + self.xp
        y = y + ym + self.yp
        SetFontState("bonus2", "", a, 255, 255, 255)
        if self.bonus ~= "FAILED" then
            RenderText("bonus2", self.bonus, x - 90, y, fontsize, "right")
        else
            SetImageState("sc_failed", "", a, 255, 255, 255)
            Render("sc_failed", x - 108, y - ym - 6, 0, fontsize)
        end

        RenderText("bonus2", ("%02d/%02d"):format(sc_hist[1], sc_hist[2]), x - 42, y, fontsize, "left")--]]
    SetViewMode("world")

end
function sc_name:del()
    object.Preserve(self)
    if not (self.death) then
        self.death = true
        self.timer = -1
    end
end
sc_name.kill = sc_name.del
boss.sc_name = sc_name

----------------------------------------
function boss:SetUIDisplay(hp, name, cd, spell, pos, draw_pointer)
    self.ui.drawhp = hp
    self.ui.drawname = name
    self.ui.drawtime = cd
    self.ui.drawspell = spell
    self.ui.needposition = pos
    self.ui.drawpointer = draw_pointer or 1
end
