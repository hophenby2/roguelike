---@class boss
boss = Class(enemybase)

function boss:init(x, y, cards, bg, diff, scname, img)
    enemybase.init(self, 999999999)
    self.x, self.y = x, y
    self.img = "img_void"
    self.IsBoss = true
    --boss系统
    self._bosssys = boss.system(self, cards, bg, diff, scname)

    self.dmgt, self.dmgmaxt = 0, 2
    --boss行走图系统
    self._blend = ""
    self._a, self._r, self._g, self._b = 255, 255, 255, 255
    self._wisys = BossWalkImageSystem(self)
    self._wisys:SetImageInList(img)
    self._wisys:SetFloat(function(ani)
        return 0, 4 * sin(ani * 4)
    end)
    lstg.tmpvar.boss = self
    _boss = self
    sp:UnitListUpdate(boss_group)
    sp:UnitListAppend(boss_group, self)
    boss.CreateDistortion(self, 160, self.self_color3)
    boss.show_aura(self, true)
    local w = lstg.weather
    if w.BiShi then
        self._colli = false
        self.transparent = true
    end
end

function boss:CreateDistortion(r, color, LAYER_ADDON, x_range_speed_adder, z_range_speed_adder)
    self.distortion = New(distortion_effect_object, self, r, color, LAYER_ADDON, x_range_speed_adder, z_range_speed_adder)
end
function boss:ActiveDistortion(open)
    ---暂时先关掉所有扭曲特效
    self.diston = false
end
function boss:frame()
    self._bosssys:frame() --boss系统帧逻辑
    self._wisys:frame() --行走图系统帧逻辑
    --受击闪烁
    if self.dmgt and self.dmgt > 0 then
        self.dmgt = self.dmgt - 1
    end
    self._colli = self._colli and not self.transparent
end
function boss:render()
    self._bosssys:render() --boss系统渲染
    self._wisys:render(self.dmgt, self.dmgmaxt) --行走图渲染
end
function boss:kill()
    self._bosssys:kill() --boss系统kill
end
function boss:del()
    self._bosssys:del() --boss系统del
end

function boss:take_damage(dmg)
    if self.dmgmaxt then
        self.dmgt = self.dmgmaxt
    end
    if not self.protect then
        local dmg0 = dmg * self.dmg_factor * self.DMG_factor
        Damage(self, dmg0)
        self.spell_damage = self.spell_damage + dmg0
    end
end
local task, sin = task, sin
local Smooth = task.Smooth
function boss:show_aura(show)
    boss.ActiveDistortion(self, show)
    local a = self._bosssys.aura
    if a then
        if show then
            if a._scale < 1 then
                task.Clear(a)
                a.angle = -180
                a.scale = 0
                a._scale = 0
                a._alpha = 1
                a._timer = 0
                task.New(a, function()
                    local self = task.GetSelf()
                    for i = 1, 60 do
                        self.angle = -180 + 360 * sin(i * 1.5)
                        self.scale = 2 * sin(i * 1.5)
                        self._scale = sin(i * 1.5)
                        task.Wait()
                    end
                    --task.Wait(20)
                    for k = 0, 60 do
                        self.angle = self.angle + self.rotspeed
                        self.scale = 2 - 0.4 * Smooth(k / 60)
                        task.Wait()
                    end
                    self.open = true
                end)
            end
        else
            task.Clear(a)
            if a._scale < 1 then
                a._alpha = 0
                a._scale = 0
                self.open = false
            else
                a._alpha = 1
                a._scale = 1
                task.New(a, function()
                    local self = task.GetSelf()
                    for i = 1, 60 do
                        self._alpha = sin(90 - i * 1.5)
                        self._scale = sin(90 - i * 1.5)
                        task.Wait()
                    end
                    self.open = false
                end)
            end
        end
    end
end

function boss:cast(cast_t, force)
    self.cast_t = cast_t + 0.5
    self.cast = 1
    self.cast_force = force--强制施法动作
end
local IsValid = IsValid
local remove = table.remove
function boss:violent()
    local t = #self.otherboss
    if t == 0 then
        return
    end
    while #self.otherboss >= t do
        for i = t, 1, -1 do
            if not IsValid(self.otherboss[i]) then
                remove(self.otherboss, i)
            end
            task.Wait()
        end
    end
end

---@param name string
---@param SCBG object @符卡背景
---@param img table  @行走图
---@param scale number  @对自身图像的大小调整
---@return boss
function boss.Define(name, x, y, SCBG, img, scale)
    local result = Class(boss, {
        cards = {},
        name = name,
        --       _bg = BG,
        difficulty = "All",
        SCBG = SCBG,
        init = function(self, cards)
            boss.init(self, x, y, cards, SCBG, "All", name, img)
            if scale then
                self.hscale = scale
                self.vscale = scale
            end
        end
    }, true)
    --_editor_boss[other_name or img] = result
    return result
end

---@param class table
function boss.Create(class)
    local w = lstg.weather
    if w.JiYun then
        local b = New(class, class.cards)
        while IsValid(b) do
            task.Wait()
        end
        return New(class, class.cards)
    end
    return New(class, class.cards)
end

----------------------------------------
---boss函数库和资源

function LoadBossTex()
    local path = "assets\\enemy\\"
    LoadTexture("boss", path .. "boss.png")
    LoadImageGroup("bossring1", "boss", 80, 0, 16, 8, 1, 16)
    --LoadImageGroup("bossring2", "boss", 48, 0, 16, 8, 1, 16)
    LoadImageGroup("bossring3", "boss", 0, 0, 16, 8, 1, 16)
    LoadImage("spell_card_ef", "boss", 96, 0, 16, 128)
    LoadTexture("timesign", path .. "timesign.png")
    LoadImage("hint.killtimer", "timesign", 0, 0, 128, 32)
    LoadImage("hint.truetimer", "timesign", 0, 32, 128, 32)
    LoadTexture("scname_sign", path .. "scname_sign.png")
    LoadImage("cardui_history", "scname_sign", 0, 32, 64, 32)
    LoadImage("cardui_bonus", "scname_sign", 0, 0, 64, 32)
    LoadFont("bonus2", path .. "bonus2.fnt", true)
    LoadImageFromFile("boss_light", path .. "eff_cnlight.png")
    LoadTexture("boss_ui", path .. "boss_ui.png")
    LoadImage("boss_spell_name_bg", "boss_ui", 0, 0, 256, 36)
    SetImageCenter("boss_spell_name_bg", 256, 0)
    LoadImageFromFile("boss_cardleft", path .. "boss_cardleft.png")
    LoadImage("boss_pointer", "boss_ui", 0, 64, 48, 16)
    SetImageCenter("boss_pointer", 24, 0)

    LoadImage("boss_sc_left", "boss_ui", 64, 64, 32, 32)
    SetImageState("boss_sc_left", "", 255, 128, 255, 128)
end
local path = "THlib\\enemy\\"
DoFile(path .. "boss_system.lua")--boss行为逻辑
DoFile(path .. "boss_card.lua")--boss非符、符卡
DoFile(path .. "boss_other.lua")--杂项、boss移动、特效
DoFile(path .. "boss_ui.lua")--boss ui