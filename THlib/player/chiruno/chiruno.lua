chiruno_player = Class(player_class)
do
    --resource
    local path = "assets\\player\\chiruno\\"
    LoadImageFromFile("chiruno_player_spell1", path .. "chiruno_spell1.png")
    LoadTexture('chiruno_player', path .. 'chiruno.png')
    LoadImageGroup('chiruno_player', 'chiruno_player', 0, 0, 32, 48, 8, 3, 0, 0)
    LoadTexture('chiruno_player_pic', path .. 'chiruno_pic.png')

    LoadImageFromFile("chiruno_player_bullet", path .. "chiruno_bullet.png", true, 48, 48)
    LoadTexture('Chiruno_ice', path .. 'ice.png')

    LoadImageGroup("Chiruno_ice1", "Chiruno_ice", 0, 128, 32, 32, 4, 1, 16, 16)
    LoadImageGroup("Chiruno_ice2", "Chiruno_ice", 0, 0, 64, 64, 4, 1, 32, 32)
    LoadImage("Chiruno_ice3", "Chiruno_ice", 64, 160, 96, 96, 48, 48)

    LoadImageGroup("Chiruno_ice_ef1", "Chiruno_ice", 128, 128, 32, 32, 4, 1, 16, 16)
    LoadImageGroup("Chiruno_ice_ef2", "Chiruno_ice", 0, 64, 64, 64, 4, 1, 32, 32)
    LoadImage("Chiruno_ice_ef3", "Chiruno_ice", 160, 160, 96, 96, 48, 48)
end

local langModule = "chiruno_des"
loadLanguageModule(langModule, "THlib\\player\\chiruno")
local function _t(str)
    return i18n(langModule, str) or ""
end

function chiruno_player:init()
    player_class.init(self)

    player_lib.SetPlayerBulletImg(1, "chiruno_player_bullet")

    self.imgs = {}
    for i = 1, 24 do
        self.imgs[i] = 'chiruno_player' .. i
    end
    self.bright = {}
    player_lib.SetEnergy(35, 3)
    player_lib.AddEnergy(114514)
    if player_lib.GetPlayerStarLevel(1) then
        lstg.tmpvar.ChirunoSkill1 = true
    end
    if player_lib.GetPlayerStarLevel(2) then
        lstg.tmpvar.ChirunoSkill2 = true
    end
    if player_lib.GetPlayerStarLevel(3) then
        player._playersys:addMissAfterEvent("ChirunoSkill3", 1, function()
            for a in sp.math.AngleIterator(0, 10) do
                New(chiruno_player.bullets.ice, player.x + cos(a) * 36, player.y + sin(a) * 36, ran:Int(1, 2), nil, 56)
            end
        end)
    end
    lstg.weather.weather_order = { 2, 3, 4, 1 }
end
function chiruno_player:frame()
    player_class.frame(self)
    local b
    for i = #self.bright, 1, -1 do
        b = self.bright[i]
        b.alpha = max(0, b.alpha - 10)
        b.x = b.x + cos(b.a) * b.v
        b.y = b.y + sin(b.a) * b.v
        if b.alpha == 0 then
            table.remove(self.bright, i)
        end
    end
end

local lib = player_lib
local pu = lib.CreatePlayerUnit(3, "Chiruno", _t("name"), _t("subname"),
        'chiruno_player_pic', 500, 340, 0.38, chiruno_player,
        {
            NewLockFunction("scene:2"),
            NewLockFunction("passChallenge:5")
        }, {
            { _t("Talent1name"), _t("Talent1des"), },
            { _t("Talent2name"), _t("Talent2des"), },
            { _t("Talent3name"), _t("Talent3des"), },
        }, 135, 206, 235)

--设置等级属性
chiruno_player.attribute = lib.CreatePlayerAttributeList(30.0, 5, 0.7,
        4.0, 2.0, 18, 9, 46)

lib.CreateSpellUnit(1, pu, "冰符「小小冰镇世界」", "chiruno_player_spell1",
        { dmg_index = 0.6, protect = 2.5, })

local spell1 = plus.Class(lib.spell_class)

function spell1:init(master, attribute)
    self.master = master
    self.dmg_index = attribute.dmg_index
    self.protect_time = attribute.protect
end
function spell1:spell()
    local p = self.master

    PlaySound('slash', 1.0)
    PlaySound('release', 1.0)
    local dmg = p.damage * self.dmg_index
    local t = int(self.protect_time * 60)
    if not lstg.tmpvar.ChirunoSkill1 then
        p.nextspell = t
    else
        p.nextspell = 2
    end
    p.protect = max(p.protect, t)
    p.collect_line = p.collect_line - 600

    --lstg.var.energy_efficiency = lstg.var.energy_efficiency - 0.6
    New(tasker, function()
        task.Wait(t)
        p.collect_line = p.collect_line + 600
        -- lstg.var.energy_efficiency = lstg.var.energy_efficiency + 0.6
    end)
    New(chiruno_player.bullets.spell_unit, dmg, t, 80)

    return t
end
function spell1:getDescribe()
    --持续帧数30
    return _t("spelldes"):format(self.dmg_index * 6000, self.protect_time)
end

local spells = { spell1 }
chiruno_player.spells = spells
do

    local bullets = {}
    chiruno_player.bullets = bullets
    local spell_unit = Class(object)
    function spell_unit:init(dmg, time, radius)
        self.x, self.y = player.x, player.y
        self.group = 3
        self.layer = -401
        self.bound = false
        self.colli = true
        self.alpha = 0
        self.col = { 60, 100, 235 }
        self.a = 0
        self.dmg = dmg
        self.killflag = true
        self.count = 0
        local _radius = radius
        self.drop_item = function(x, y)
            player_lib.NewEnergySp(x, y, 0.015)
        end
        if lstg.tmpvar.ChirunoSkill2 then
            self.drop_item = function(x, y, is_laser)
                player_lib.NewEnergySp(x, y, 0.015)
                if not is_laser then
                    local percent = 0.0035
                    self.a = self.a + radius * percent
                    _radius = _radius + radius * percent
                end
            end
        end
        self.alpha = 0
        task.New(self, function()
            for i = 1, 15 do
                i = task.SetMode[2](i / 15)
                self.a = i * _radius
                task.Wait()
            end
        end)
        task.New(self, function()
            task.SmoothSetValueTo("alpha", 255, 15, 2)
            task.Wait(time)
            self.colli = false
            task.SmoothSetValueTo("alpha", 0, 15, 2)
            object.Del(self)
        end)
    end
    function spell_unit:frame()
        task.Do(self)
        self.b = self.a
        if self.colli then
            cutLasersByCircle(self.x, self.y, self.a, function(x, y)
                self.drop_item(x, y, true)
            end)
            object.BulletDo(function(o)
                if Dist(self, o) < self.a then
                    object.Del(o)
                    self.drop_item(o.x, o.y)
                    --New(main_item, o.x, o.y, nil, nil, true, nil, 0.6)
                end
            end)
            object.LaserDo(function(o)
                if Dist(self, o) < self.a and not o.Isradial and not o.Isgrowing then
                    object.Del(o)
                    self.drop_item(o.x, o.y)
                    --New(main_item, o.x, o.y, nil, nil, true, nil, 0.6)
                end
            end)
        end
    end
    function spell_unit:render()
        SetImageState("white", "mul+add", self.alpha / 2.7, 60, 100, 235)
        misc.SectorRender(self.x, self.y, 0, self.a, 0, 360, 40)
        misc.SectorRender(self.x, self.y, self.a - 8, self.a, 0, 360, 40)
    end
    bullets.spell_unit = spell_unit

    local ice = Class(object)
    bullets.ice = ice
    function ice:init(x, y, size, unit, time)
        self.colli = false
        self.group = GROUP.SPELL
        self.layer = -199
        self.rot = ran:Float(0, 360)
        if size == 3 then
            self.t = 3
        else
            self.t = size .. ran:Int(1, 4)
        end
        self.size = size
        self.x, self.y = x, y
        self.unit = unit
        self.img = "Chiruno_ice_ef" .. self.t
        self.scale = ran:Float(0.9, 1.2)
        self.hscale = self.scale + 0.5
        self.vscale = self.hscale
        self.lifetime = time
        PlaySound("ice", 0.2, 0, true)
        task.New(self, function()
            task.New(self, function()
                for i = 0, 10 do
                    i = task.SetMode[4](i / 10)
                    self._a = i * 180
                    self.hscale = self. scale + 0.5 - 0.5 * i
                    self.vscale = self.hscale
                    task.Wait()
                end
                self.img = "Chiruno_ice" .. self.t
            end)
            task.Wait(time - self.timer)
            object.Del(self)
        end)
        self._a = 0
    end
    function ice:colli(other)
        if not other.wasIced and (other.group == GROUP.ENEMY_BULLET) then
            New(ice, other.x, other.y, clamp(math.ceil(other.a / 4), 1, 3), other, self.lifetime - self.timer)
            task.Clear(other)
            object.StopMoving(other)
            other.wasIced = true
            other.group = 0
        end
    end
    function ice:frame()
        task.Do(self)
        if self.unit then
            if IsValid(self.unit) then
                self.unit.x, self.unit.y = self.x, self.y
            else
                object.Del(self)
            end
        end
        self.colli = (self.timer > 2 and not self.dk)
    end
    function ice:del()
        if not self.dk then
            self.dk = true
            object.Preserve(self)
            task.New(self, function()

                if self.unit and IsValid(self.unit) then
                    object.Del(self.unit)
                end
                for i = 10, 0, -1 do
                    i = task.SetMode[4](i / 10)
                    self._a = i * 180
                    self.hscale = self.scale + 0.5 - 0.5 * i
                    self.vscale = self.hscale
                    task.Wait()
                end
                object.RawDel(self)
            end)
        end
    end
    function ice:render()
        SetImageState(self.img, "mul+add", self._a, 255, 255, 255)
        DefaultRenderFunc(self)
    end
end