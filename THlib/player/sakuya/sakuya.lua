do
    --resource
    local path = "assets\\player\\sakuya\\"
    LoadImageFromFile("sakuya_player_spell1", path .. "sakuya_spell1.png")
    LoadTexture('sakuya_player', path .. 'sakuya.png')
    LoadImageGroup('sakuya_player', 'sakuya_player', 0, 0, 32, 48, 8, 3, 0, 0)
    LoadTexture('sakuya_player_pic', path .. 'sakuya_pic.png')

    LoadImageFromFile("sakuya_player_bullet", path .. "sakuya_bullet.png", true, 60, 60)
end

local langModule = "sakuya_des"
loadLanguageModule(langModule, "THlib\\player\\sakuya")
local function _t(str)
    return i18n(langModule, str) or ""
end

sakuya_player = Class(player_class)

function sakuya_player:init()
    player_class.init(self)

    player_lib.SetPlayerBulletImg(1, "sakuya_player_bullet")

    self.imgs = {}
    for i = 1, 24 do
        self.imgs[i] = 'sakuya_player' .. i
    end
    if player_lib.GetPlayerStarLevel(1) then
        lstg.tmpvar.SakuyaSkill1 = true
    end
    if player_lib.GetPlayerStarLevel(2) then
        lstg.tmpvar.SakuyaSkill2 = true
    end
    if player_lib.GetPlayerStarLevel(3) then
        lstg.tmpvar.SakuyaSkill3 = true
    end
    self.little_time_stop = 0
    lstg.weather.weather_order = { 1, 4, 3, 2 }
end
function sakuya_player:frame()
    player_class.frame(self)
    if lstg.tmpvar.SakuyaSkill1 then
        local v = lstg.var
        if not self.__shoot_flag then
            v.sakuyaFPS = v.sakuyaFPS + (-v.sakuyaFPS + 45) * 0.1
        else
            v.sakuyaFPS = min(60, v.sakuyaFPS + 15 / 60)
        end

    end
    if lstg.tmpvar.SakuyaSkill3 and self.little_time_stop == 0 and lstg.var.energy >= lstg.var.maxenergy then
        object.BulletIndesDo(function(b)
            if self.little_time_stop == 0 then
                b._stop_x = nil
                b._stop_y = nil
                for c = 0, 4 do
                    local bx, by = b.x + c * b.dx, b.y + c * b.dy
                    local px, py = self.x + c * self.dx, self.y + c * self.dy
                    if Dist(bx, by, px, py) < (b.a + self.a) then
                        PlaySound("clock")
                        TelescopeSmearScreen(self, 24, 0.4)
                        --NewWave(b.x, b.y, 2, 300, 30, 189, 252, 201)
                        New(sakuya_player.bullets.sp_ef, 100, true)
                        PlaySound('slash2', 1.0)
                        self.little_time_stop = 100
                        break
                    end
                end
            end
        end)

    end
    if self.little_time_stop > 0 then
        self.little_time_stop = self.little_time_stop - 1
        for _, obj in ObjList(GROUP.PLAYER_BULLET) do
            obj._time_stop = 1
        end
        object.BulletIndesDo(function(b)
            if not b.not_move then
                if not b._stop_x and not b._stop_y then
                    b._stop_x = b.x
                    b._stop_y = b.y
                end
                b.x = b._stop_x
                b.y = b._stop_y
            end
        end)
    else
    end
end

local lib = player_lib
local pu = lib.CreatePlayerUnit(5, "Sakuya", _t("name"), _t("subname"),
        'sakuya_player_pic', 308, 301, 0.5, sakuya_player,
        {
            NewLockFunction("scenecount:2:3"),
            NewLockFunction("passChallenge:9"),
        }, {
            { _t("Talent1name"), _t("Talent1des"), },
            { _t("Talent2name"), _t("Talent2des"), },
            { _t("Talent3name"), _t("Talent3des"), },
        }, 218, 75, 214)

--设置等级属性
sakuya_player.attribute = lib.CreatePlayerAttributeList(40.0, 11, 0.7,
        4.5, 2.3, 9, 14, 36)

lib.CreateSpellUnit(1, pu, "幻幽「迷幻的杰克」", "sakuya_player_spell1",
        { dmg_index = 30, protect = 7, })

local spell1 = plus.Class(lib.spell_class)

function spell1:init(master, attribute)
    self.master = master
    self.dmg_index = attribute.dmg_index
    self.protect_time = attribute.protect
end
function spell1:spell()
    local p = self.master

    PlaySound('slash', 1.0)
    local dmg = p.damage * self.dmg_index
    local t = int(self.protect_time * 60)
    p.nextspell = t
    p.protect = p.protect + t + 15
    p.collect_line = p.collect_line - 600
    lstg.var.energy_efficiency = lstg.var.energy_efficiency - 0.75
    if lstg.tmpvar.SakuyaSkill2 then
        p.grazer_colli_fixed = p.grazer_colli_fixed + 1
        p.shoot_set.speed.fixed = p.shoot_set.speed.fixed + 1
    end

    New(sakuya_player.bullets.sp_ef, t)
    New(tasker, function()
        for _ = 1, t do
            if GetSoundState("clock") ~= 'playing' then
                PlaySound("clock")
            end
            object.BulletDo(function(b)
                if not b.not_move then
                    if not b._stop_x and not b._stop_y then
                        b._stop_x = b.x
                        b._stop_y = b.y
                    end
                    b.x = b._stop_x
                    b.y = b._stop_y
                end
            end)
            for _, obj in ObjList(GROUP.PLAYER_BULLET) do
                obj._time_stop = 1
            end
            task.Wait()
        end
        p.collect_line = p.collect_line + 600
        lstg.var.energy_efficiency = lstg.var.energy_efficiency + 0.75
        if lstg.tmpvar.SakuyaSkill2 then
            p.grazer_colli_fixed = p.grazer_colli_fixed - 1
            p.shoot_set.speed.fixed = p.shoot_set.speed.fixed - 1
        end
        PlaySound('slash', 1.0)
        object.EnemyNontjtDo(function(o)
            if o.colli and o.class.base.take_damage then
                o.class.base.take_damage(o, dmg)
            end
        end)
        object.BulletDo(function(b)
            object.Kill(b)
        end)
        cutAllLaser()
    end)

    return t
end
function spell1:getDescribe()
    return _t("spelldes"):format(self.protect_time, self.dmg_index * 100)
end

local spells = { spell1 }
sakuya_player.spells = spells
do

    local bullets = {}
    sakuya_player.bullets = bullets
    local sp_ef = Class(object)
    bullets.sp_ef = sp_ef
    function sp_ef:init(t, noeff)
        self.layer = LAYER.TOP + 15
        self.group = GROUP.PLAYER
        self.colli = false
        self.noeff = noeff
        self.bound = false
        self.R = 0
        task.New(self, function()
            for i = 1, 30 do
                self.R = self.R + 30
                stage_lib.SetGlobalMusicVolume(self, 1 - i / 30)
                task.Wait()
            end
            task.Wait(t - 60)
            for i = 1, 30 do
                self.R = self.R - 30
                stage_lib.SetGlobalMusicVolume(self, i / 30)
                task.Wait()
            end
            Del(self)
        end)
    end
    function sp_ef:frame()
        task.Do(self)
        self.x, self.y = player.x, player.y
    end
    function sp_ef:render()
        if not self.noeff then
            SetImageState("white", "add+sub", 255, 255, 255, 255)
            misc.SectorRender(self.x, self.y, 0, self.R, 0, 360, 75)
        end
    end

end