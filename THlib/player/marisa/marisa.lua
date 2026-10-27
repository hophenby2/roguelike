marisa_player = Class(player_class)
do
    local path = "assets\\player\\marisa\\"
    LoadImageFromFile("marisa_player_spell1", path .. "marisa_spell1.png")
    -- LoadImageFromFile("marisa_player_spell2", path .. "marisa_spell2.png")
    LoadTexture('marisa_player_pic', path .. 'marisa_pic.png')
    LoadTexture('marisa_player', path .. 'marisa.png')
    LoadImageGroup('marisa_player', 'marisa_player', 0, 0, 32, 48, 8, 3, 1, 1)

    LoadTexture('marisa_spark', path..'marisa_spark.png')
    LoadImage('marisa_spark', 'marisa_spark', 0, 64, 256, 128, 0, 0)
    LoadImage('marisa_spark_wave', 'marisa_spark', 256, 0, 96, 256, 96, 180)
    SetImageState('marisa_spark', 'mul+add', Color(0xFFFFFFFF))
    SetImageState('marisa_spark_wave', 'mul+add', Color(0xFFFFFFFF))
    SetImageCenter('marisa_spark', 0, 64)

    LoadImageFromFile("marisa_player_bullet", path .. "marisa_bullet.png", true, 48, 48)
end

local langModule = "marisa_des"
loadLanguageModule(langModule, "THlib\\player\\marisa")
local function _t(str)
    return i18n(langModule, str) or ""
end

function marisa_player:init()
    player_class.init(self)

    player_lib.SetPlayerBulletImg(1, "marisa_player_bullet")

    self.imgs = {}
    for i = 1, 24 do
        self.imgs[i] = 'marisa_player' .. i
    end
    if player_lib.GetPlayerStarLevel(2) then
        lstg.tmpvar.MarisaSkill2 = true
    end
    if player_lib.GetPlayerStarLevel(3) then
        lstg.tmpvar.MarisaSkill3 = true
    end
    lstg.weather.weather_order = { 4, 1, 2, 3 }
end
function marisa_player:frame()
    player_class.frame(self)
    if player_lib.GetPlayerStarLevel(1) then
        if lstg.var.frame_counting then
            player_lib.AddEnergy(1 / 60)
        end
    end
end

function marisa_player.IsInLaser(x0, y0, a, unit, w)
    local a1 = a - Angle(x0, y0, unit.x, unit.y)
    if a % 180 == 90 then
        if abs(unit.x - x0) < ((unit.a + unit.b + w) / 2) and cos(a1) >= 0 then
            return true
        else
            return false
        end
    else
        local A = tan(a)
        local C = y0 - A * x0
        if abs(A * unit.x - unit.y + C) / sqrt(A * A + 1) < ((unit.a + unit.b + w) / 2) and cos(a1) >= 0 then
            return true
        else
            return false
        end
    end
end
function marisa_player.CreateLaser(tex, x, y, a, w, t, c, offset)
    local width = w / 2
    local n = int(offset / 256)
    local length = t % 256
    local endl = int(offset - n * 256)
    local _, texh = GetTextureSize(tex)
    local w_x = width * cos(a)
    local w_y = width * sin(a)
    local blend = 'mul+add'
    local vx1, vy1, vx2, vy2, vx3, vy3
    for i = 1, n do
        vx1 = x + (length + 256 * (i - 1)) * cos(a)
        vy1 = y + (length + 256 * (i - 1)) * sin(a)
        vx2 = x + 256 * i * cos(a)
        vy2 = y + 256 * i * sin(a)
        vx3 = x + 256 * (i - 1) * cos(a)
        vy3 = y + 256 * (i - 1) * sin(a)
        RenderTexture(tex, blend,
                { vx1 - w_y, vy1 + w_x, 0.5, 0, 0, c },
                { vx2 - w_y, vy2 + w_x, 0.5, 256 - length, 0, c },
                { vx2 + w_y, vy2 - w_x, 0.5, 256 - length, texh, c },
                { vx1 + w_y, vy1 - w_x, 0.5, 0, texh, c })
        RenderTexture(tex, blend,
                { vx3 - w_y, vy3 + w_x, 0.5, 256 - length, 0, c },
                { vx1 - w_y, vy1 + w_x, 0.5, 256, 0, c },
                { vx1 + w_y, vy1 - w_x, 0.5, 256, texh, c },
                { vx3 + w_y, vy3 - w_x, 0.5, 256 - length, texh, c })
    end

    vx2 = x + (endl + 256 * n) * cos(a)
    vy2 = y + (endl + 256 * n) * sin(a)
    vx3 = x + 256 * n * cos(a)
    vy3 = y + 256 * n * sin(a)
    if length <= endl then
        vx1 = x + (length + 256 * n) * cos(a)
        vy1 = y + (length + 256 * n) * sin(a)
        RenderTexture(tex, blend,
                { vx1 - w_y, vy1 + w_x, 0.5, 0, 0, c },
                { vx2 - w_y, vy2 + w_x, 0.5, endl - length, 0, c },
                { vx2 + w_y, vy2 - w_x, 0.5, endl - length, texh, c },
                { vx1 + w_y, vy1 - w_x, 0.5, 0, texh, c })
        RenderTexture(tex, blend,
                { vx3 - w_y, vy3 + w_x, 0.5, 256 - length, 0, c },
                { vx1 - w_y, vy1 + w_x, 0.5, 256, 0, c },
                { vx1 + w_y, vy1 - w_x, 0.5, 256, texh, c },
                { vx3 + w_y, vy3 - w_x, 0.5, 256 - length, texh, c })
    else
        RenderTexture(tex, blend,
                { vx3 - w_y, vy3 + w_x, 0.5, 256 - length, 0, c },
                { vx2 - w_y, vy2 + w_x, 0.5, endl + 256 - length, 0, c },
                { vx2 + w_y, vy2 - w_x, 0.5, endl + 256 - length, texh, c },
                { vx3 + w_y, vy3 - w_x, 0.5, 256 - length, texh, c })
    end
end

local lib = player_lib
local pu = lib.CreatePlayerUnit(2, "Marisa", _t("name"), _t("subname"),
        'marisa_player_pic', 360, 300, 0.45, marisa_player,
        0, {
            { _t("Talent1name"), _t("Talent1des"), },
            { _t("Talent2name"), _t("Talent2des"), },
            { _t("Talent3name"), _t("Talent3des"), },
        }, 189, 252, 201)

--设置等级属性
marisa_player.attribute = lib.CreatePlayerAttributeList(32.0, 7, 0.9,
        5, 2.5, 15, 11, 39)

lib.CreateSpellUnit(1, pu, "恋符「Master Spark」", "marisa_player_spell1",
        { dmg_index = 0.4, protect = 6.6, })

local spell1 = plus.Class(lib.spell_class)

function spell1:init(master, attribute)
    self.master = master
    self.dmg_index = attribute.dmg_index
    self.protect_time = attribute.protect
end
function spell1:spell()
    local p = self.master

    PlaySound('slash', 1.0)
    PlaySound('nep00', 1.0)
    local dmg = p.damage * self.dmg_index
    local t = int(self.protect_time * 60)
    local A = lstg.var.reverse_shoot and (-90) or 90
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
    New(marisa_player.bullets.spark, p.x, p.y, A, 30, t - 60, 30, p)
    --反冲
    New(tasker, function()
        local _ct = int(t / 3)
        for i = 1, _ct do
            i = 1 - task.SetMode[1](i / _ct)
            local v = i * 3
            player.x = player.x - cos(A) * v
            player.y = player.y - sin(A) * v
            task.Wait()
        end
    end)
    New(tasker, function()
        for _ = 1, t / 10 - 3 do
            New(marisa_player.bullets.spark_wave, p.x, p.y - 16, A, 12, dmg, p)
            task.Wait(10)
        end
        object.BulletDo(function(b)
            object.Kill(b)
        end)
        cutAllLaser()
        PlaySound('slash', 1.0)
    end)
    misc.ShakeScreen(t, 5)
    return t
end
function spell1:getDescribe()
    --持续帧数30
    return _t("spelldes"):format(self.dmg_index * 6000, self.protect_time)
end

local spells = { spell1 }
marisa_player.spells = spells

do
    local bullets = {}
    marisa_player.bullets = bullets

    local spark = Class(object)
    function spark:init(x, y, rot, turnOnTime, wait, turnOffTime, p)
        self.player = p
        self.x = x
        self.y = y
        self.rot = rot
        self.img = 'marisa_spark'
        self.group = GROUP.GHOST
        self.layer = LAYER.PLAYER_BULLET
        self.hscale = 2.5
        self.bound = false
        task.New(self, function()
            for i = 0, turnOnTime do
                self.vscale = 2.5 * i / turnOnTime
                task.Wait(1)
            end
            task.Wait(wait)
            for i = 0, turnOffTime do
                self.vscale = 2.5 * (1 - i / turnOffTime)
                task.Wait(1)
            end
            Del(self)
        end)
    end
    function spark:frame()
        task.Do(self)
        self.x = self.player.x
        self.y = self.player.y
    end
    bullets.spark = spark

    local spark_wave = Class(object)
    function spark_wave:init(x, y, rot, v, dmg, p)
        self.player = p
        self.x = x
        self.y = y
        self.rot = rot
        self.img = 'marisa_spark_wave'
        self.group = GROUP.PLAYER_BULLET
        self.layer = LAYER.PLAYER_BULLET
        self.vx = v * cos(rot)
        self.vy = v * sin(rot)
        self.dmg = dmg
        --self.rect = true
        self.killflag = true
    end
    function spark_wave:frame()
        self.x = self.player.x
        self.vscale = min(1.5, self.timer / 10)
        self.hscale = self.vscale
        New(bomb_bullet_killer, self.x, self.y, 100 * self.hscale / 1.5, 100, false)
    end
    bullets.spark_wave = spark_wave
end--bullet