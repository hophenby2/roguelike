do
    --resource
    local path = "assets\\player\\aya\\"
    LoadImageFromFile("aya_player_spell1", path .. "aya_spell1.png")
    LoadTexture('aya_player', path .. 'aya.png')
    LoadImageGroup('aya_player', 'aya_player', 0, 0, 32, 48, 8, 3, 0, 0)
    LoadTexture('aya_player_pic', path .. 'aya_pic.png')
    LoadImageFromFile("aya_spell_photoON", path .. "photoON.png")
    LoadImageFromFile("aya_spell_photoOFF", path .. "photoOFF.png")
    LoadImageFromFile("aya_player_bullet", path .. "aya_bullet.png", true, 48, 48)
 end

local langModule = "aya_des"
loadLanguageModule(langModule, "THlib\\player\\aya")
local function _t(str)
    return i18n(langModule, str) or ""
end

aya_player = Class(player_class)

function aya_player:init()
    player_class.init(self)
    player_lib.SetPlayerBulletImg(1, "aya_player_bullet")
    self.imgs = {}
    for i = 1, 24 do
        self.imgs[i] = 'aya_player' .. i
    end
    if player_lib.GetPlayerStarLevel(1) then
        lstg.tmpvar.AyaSkill1 = true
    end
    if player_lib.GetPlayerStarLevel(2) then
        lstg.tmpvar.AyaSkill2 = true
    end
    if player_lib.GetPlayerStarLevel(3) then
        lstg.tmpvar.AyaSkill3 = true
    end
    lstg.weather.weather_order = { 3, 4, 1, 2 }
end
function aya_player:frame()
    player_class.frame(self)
end

local lib = player_lib
local pu = lib.CreatePlayerUnit(4, "Aya", _t("name"), _t("subname"),
        'aya_player_pic', 500, 320, 0.45, aya_player,
        {
            NewLockFunction("scene:2"),
            NewLockFunction("passChallenge:6")
        }, {
            { _t("Talent1name"), _t("Talent1des"), },
            { _t("Talent2name"), _t("Talent2des"), },
            { _t("Talent3name"), _t("Talent3des"), },
        }, 250, 128, 114)

--设置等级属性
aya_player.attribute = lib.CreatePlayerAttributeList(32, 3, 0.8,
        5.5, 2.5, 32, 11, 44)

lib.CreateSpellUnit(1, pu, "取材「暴力取材」", "aya_player_spell1",
        { count = 12, dmg_index = 33.5, protect = 4.5, })

local spell1 = plus.Class(lib.spell_class)

function spell1:init(master, attribute)
    self.master = master
    self.count = int(attribute.count)
    self.dmg_index = attribute.dmg_index
    self.protect_time = attribute.protect
end
function spell1:spell()
    local p = self.master

    PlaySound('slash', 1.0)
    PlaySound('nep00', 1.0)
    local dmg = p.damage * self.dmg_index
    local t = int(self.protect_time * 60)
    p.nextspell = t
    p.nextshoot = p.nextshoot + t
    p.protect = p.protect + t
    p.collect_line = p.collect_line - 600
    lstg.var.energy_efficiency = lstg.var.energy_efficiency - 0.75
    New(tasker, function()
        task.Wait(t)
        p.collect_line = p.collect_line + 600
        lstg.var.energy_efficiency = lstg.var.energy_efficiency + 0.75
    end)
    New(aya_player.bullets.photo_back, t * (self.count - 1) / self.count)
    for i = 0, self.count - 1 do
        local j = task.SetMode[2](i / self.count)
        New(tasker, function()
            task.Wait(t * j)
            New(aya_player.bullets.photo_shoot, 30, dmg)

            local bottom = New(aya_player.bullets.capture_bottom, "_aya_capture" .. i)
            New(aya_player.bullets.capture_top, "_aya_capture" .. i, t - t * j + 90, i, bottom)
            if i == self.count - 1 then
                PlaySound("explode")
                PlaySound("cardget")
            end
        end)
    end

    return t
end
function spell1:getDescribe()
    return _t("spelldes"):format(self.count, self.dmg_index * 100, self.protect_time)
end

local spells = { spell1 }
aya_player.spells = spells
do

    local bullets = {}
    aya_player.bullets = bullets
    local photo_back = Class(object)
    function photo_back:init(time)
        self.x, self.y = 0, 0
        self.img = "aya_spell_photoOFF"
        self.group = GROUP.GHOST
        self.layer = LAYER.TOP + 10.5
        self.bound = false
        self.alpha = 1
        task.New(self, function()
            task.Wait(time)
            task.SmoothSetValueTo("alpha", 0, 15, 2)
            object.Del(self)
        end)
    end
    function photo_back:frame()
        task.Do(self)
    end
    function photo_back:render()
        SetImageState("white", "", self.alpha * 75, 0, 0, 0)
        RenderRect("white", -320, 320, -240, 240)
        SetImageState(self.img, "mul+add", self.alpha * 255, 255, 255, 255)
        Render(self.img, self.x, self.y, 90, 1.25)
    end
    bullets.photo_back = photo_back

    local photo_shoot = Class(object)
    function photo_shoot:init(time, dmg)
        self.x, self.y = 0, 0
        self.img = "aya_spell_photoON"
        self.group = GROUP.PLAYER_BULLET
        self.layer = LAYER.TOP + 11
        self.bound = false
        self.alpha = 1
        self.dmg = dmg
        self.killflag = true
        self.a, self.b = 999, 999
        PlaySound("shutter")
        task.New(self, function()
            task.SmoothSetValueTo("alpha", 0, time, 2)
            object.Del(self)
        end)
        object.BulletDo(function(b)
            object.Kill(b)
        end)
        cutAllLaser()
    end
    function photo_shoot:frame()
        task.Do(self)
        if self.timer >= 1 then
            self.colli = false
        end
    end
    function photo_shoot:render()
        SetImageState(self.img, "mul+add", self.alpha * 255, 255, 255, 255)
        Render(self.img, self.x, self.y, 90, 1.25)
    end
    bullets.photo_shoot = photo_shoot

    local capture_bottom = Class(object)
    function capture_bottom:init(tex)
        self.layer = LAYER.BG - 100
        self.group = GROUP.GHOST
        self.tex = tex
        CreateRenderTarget(self.tex)
    end
    function capture_bottom:frame()

    end
    function capture_bottom:render()
        if self.timer == 1 then
            lstg.PushRenderTarget(self.tex)
            RenderClear(Color(255, 0, 0, 0))
        end
    end
    bullets.capture_bottom = capture_bottom
    local capture_top = Class(object)
    function capture_top:init(tex, time, id, bottom)
        self.bottom = bottom
        self.layer = LAYER.TOP + 10 - id * 0.1
        self.group = GROUP.GHOST
        self.tex = tex
        self.uv1, self.uv2, self.uv3, self.uv4 = { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }
        local color = Color(180, 255, 255, 255)
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
        local irot = ran:Float(-30, 30)
        local dx, dy = -400, -180 + 360 * (id / 5)
        if id > 5 then
            dx, dy = 400, -180 + 360 * ((id - 6) / 5)
        end
        task.New(self, function()
            task.Wait(time - 60)
            for i = 1, 60 do
                color = Color(180 * (1 - i / 60), 255, 255, 255)
                self.uv1[6] = color
                self.uv2[6] = color
                self.uv3[6] = color
                self.uv4[6] = color
                task.Wait()
            end
        end)
        task.New(self, function()
            local t = 60
            for i = 1, t do
                i = task.SetMode[10](i / t)
                local k = (1 - 0.8 * i)
                local cx, cy = dx * i, dy * i
                local rot = irot * i
                self.uv1[1], self.uv1[2] = w.l * k, w.t * k
                self.uv2[1], self.uv2[2] = w.r * k, w.t * k
                self.uv3[1], self.uv3[2] = w.r * k, w.b * k
                self.uv4[1], self.uv4[2] = w.l * k, w.b * k
                self.uv1[1], self.uv1[2] = self.uv1[1] * cos(rot) - self.uv1[2] * sin(rot), self.uv1[1] * sin(rot) + self.uv1[2] * cos(rot)
                self.uv2[1], self.uv2[2] = self.uv2[1] * cos(rot) - self.uv2[2] * sin(rot), self.uv2[1] * sin(rot) + self.uv2[2] * cos(rot)
                self.uv3[1], self.uv3[2] = self.uv3[1] * cos(rot) - self.uv3[2] * sin(rot), self.uv3[1] * sin(rot) + self.uv3[2] * cos(rot)
                self.uv4[1], self.uv4[2] = self.uv4[1] * cos(rot) - self.uv4[2] * sin(rot), self.uv4[1] * sin(rot) + self.uv4[2] * cos(rot)
                self.uv1[1], self.uv1[2] = WorldToUI(self.uv1[1] + cx, self.uv1[2] + cy)
                self.uv2[1], self.uv2[2] = WorldToUI(self.uv2[1] + cx, self.uv2[2] + cy)
                self.uv3[1], self.uv3[2] = WorldToUI(self.uv3[1] + cx, self.uv3[2] + cy)
                self.uv4[1], self.uv4[2] = WorldToUI(self.uv4[1] + cx, self.uv4[2] + cy)
                task.Wait()
            end
            task.Wait(time - 60)
            if IsValid(self.bottom) then
                Del(self.bottom)
            end

            Del(self)
        end)
    end
    function capture_top:frame()
        task.Do(self)
    end
    function capture_top:render()
        if self.timer == 1 then
            SetImageState("white", "mul+add", 255, 255, 255, 255)
            local w = lstg.world
            misc.RenderOutLine("white", w.l, w.r, w.t, w.b, 5, 0)
            lstg.PopRenderTarget(self.tex)
        end
        SetViewMode("ui")
        lstg.RenderTexture(self.tex, "", self.uv1, self.uv2, self.uv3, self.uv4)
        SetViewMode("world")
    end
    bullets.capture_top = capture_top
end