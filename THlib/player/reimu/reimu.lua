reimu_player = Class(player_class)
do
    local path = "assets\\player\\reimu\\"
    LoadTexture('reimu_player_pic', path .. 'reimu_pic.png')
    LoadTexture('reimu_player', path .. 'reimu.png')
    LoadImageFromFile("reimu_player_spell1", path .. "reimu_spell1.png")
    LoadImageFromFile("reimu_player_spell2", path .. "reimu_spell2.png")
    -----------------------------------------
    LoadImageGroup('reimu_player', 'reimu_player', 0, 0, 32, 48, 8, 3, 0.5, 0.5)
    -----------------------------------------
    LoadPS('reimu_sp_ef', path .. 'reimu_sp_ef.psi', 'parimg1', 16, 16)
    LoadImageFromFile('reimu_bomb_ef', path .. 'reimu_bomb_ef.png')
    -----------------------------------------
    LoadImageFromFile("reimu_player_bullet", path .. "reimu_bullet.png", true, 48, 48)
end
local langModule = "reimu_des"
loadLanguageModule(langModule, "THlib\\player\\reimu")
local function _t(str)
    return i18n(langModule, str) or ""
end

function reimu_player:init()
    player_class.init(self)

    player_lib.SetPlayerBulletImg(1, "reimu_player_bullet")

    self.imgs = {}
    for i = 1, 24 do
        self.imgs[i] = 'reimu_player' .. i
    end
    if player_lib.GetPlayerStarLevel(2) then
        lstg.tmpvar.ReimuSkill2 = true--五步成诗
    end
    if player_lib.GetPlayerStarLevel(3) then
        lstg.var.double_BiYi = true
    end
    lstg.weather.weather_order = { 1, 2, 3, 4 }
end
function reimu_player:frame()
    player_class.frame(self)
    player_class.findtarget(self)
    if player_lib.GetPlayerStarLevel(1) then
        if lstg.var.frame_counting then
            player_lib.AddLife(0.4 / 60)
        end
    end
end
function reimu_player:render()
    player_class.render(self)
end

local lib = player_lib
local pu = lib.CreatePlayerUnit(1, "Reimu", _t("name"), _t("subname"),
        'reimu_player_pic', 548, 300, 0.45, reimu_player,
        0, {
            { _t("Talent1name"), _t("Talent1des"), },
            { _t("Talent2name"), _t("Talent2des"), },
            { _t("Talent3name"), _t("Talent3des"), },
        }, 218, 112, 214)
--设置等级属性
reimu_player.attribute = lib.CreatePlayerAttributeList(36.0, 6, 0.6,
        4.5, 2.0, 17, 9, 40)

lib.CreateSpellUnit(1, pu, "灵符「梦想封印」", "reimu_player_spell1",
        { dmg_index = 0.26, protect = 6, count = 10, })

local spell1 = plus.Class(lib.spell_class)

function spell1:init(master, attribute)
    self.master = master
    self.dmg_index = attribute.dmg_index
    self.ball_count = int(attribute.count)
    self.protect_time = attribute.protect
end
function spell1:spell()
    local p = self.master
    local dmg = p.damage * self.dmg_index
    PlaySound('nep00', 0.8)
    PlaySound('slash', 0.8)
    local rot = ran:Float(0, 360)
    local t = int(self.protect_time * 60)
    for i = 1, self.ball_count do
        New(reimu_player.bullets.sp_ef1, 'reimu_sp_ef', p.x, p.y, 8, rot + i * 360 / self.ball_count,
                p.target, 1200, dmg, int(40 - 80 * i / self.ball_count), p, t - 90)
    end
    p.nextspell = t
    --p.nextshoot = 300
    p.protect = p.protect + t
    p.collect_line = p.collect_line - 600
    lstg.var.energy_efficiency = lstg.var.energy_efficiency - 0.75
    New(tasker, function()
        task.Wait(t)
        p.collect_line = p.collect_line + 600
        lstg.var.energy_efficiency = lstg.var.energy_efficiency + 0.75
    end)
    return t
end
function spell1:getDescribe()
    --持续帧数30
    return _t("spelldes"):format(self.ball_count, self.dmg_index * 30 * 100, self.protect_time)
end

local spells = { spell1 }
reimu_player.spells = spells

do
    -------------------------------------------------------
    local bullets = {}
    reimu_player.bullets = bullets
    -------------------------------------------------------
    local sp_ef1 = Class(object)
    function sp_ef1:init(img, x, y, v, angle, target, _trail, dmg, t, player, lifetime)
        self.killflag = true
        self.group = GROUP.PLAYER_BULLET
        self.layer = LAYER.PLAYER_BULLET
        self.img = img
        local scale = player_lib.GetPlayerBulletSize() * 2
        self.vscale = 1.2 * scale
        self.hscale = 1.2 * scale
        self.a = self.a * self.hscale
        self.b = self.b * self.vscale
        self.x = x
        self.y = y
        self.rot = angle
        self.angle = angle
        self.v = v
        self.target = target
        self.trail = _trail
        self.dmg = dmg * 0.4
        self.DMG = dmg
        self.bound = false
        self.tflag = t
        self.player = player
        self.lifetime = lifetime
        self.bound = false
    end
    function sp_ef1:frame()
        if BoxCheck(self, -320, 320, -240, 240) then
            self.inscreen = true
        end
        if self.timer < 150 + self.tflag then
            self.rot = self.angle - 4 * self.timer - 90
            self.x = self.timer * 1 * cos(self.rot + 90) + self.player.x
            self.y = self.timer * 1 * sin(self.rot + 90) + self.player.y
        end
        player_class.findtarget(self)
        if self.timer > 150 + self.tflag then
            self.killflag = false
            -- self.dmg = self.DMG * 10
            if IsValid(self.target) and self.target.colli then
                local a = (Angle(self, self.target) - self.rot + 720) % 360
                if a > 180 then
                    a = a - 360
                end
                local da = self.trail / (Dist(self, self.target) + 1)
                if da >= abs(a) then
                    self.rot = Angle(self, self.target)
                else
                    self.rot = self.rot + sign(a) * da
                end
            end
            self.vx = 8 * cos(self.rot)
            self.vy = 8 * sin(self.rot)
            if self.inscreen then
                if self.x > 320 then
                    self.x = 320
                    self.vx = 0
                    self.vy = 0
                end
                if self.x < -320 then
                    self.x = -320
                    self.vx = 0
                    self.vy = 0
                end
                if self.y > 240 then
                    self.y = 240
                    self.vx = 0
                    self.vy = 0
                end
                if self.y < -240 then
                    self.y = -240
                    self.vx = 0
                    self.vy = 0
                end
            end
        end
        if self.timer > self.lifetime - 10 then
            self.killflag = true
            --self.dmg = 0.4 * self.DMG
            self.a = 2 * self.a
            self.b = 2 * self.b
            self.hscale = self.hscale * 1.2
            self.vscale = self.hscale
        end
        if self.timer > self.lifetime then
            Kill(self)
        end
        New(bomb_bullet_killer, self.x, self.y, self.a * 1.5, self.b * 1.5, false)
    end
    function sp_ef1:kill()
        misc.ShakeScreen(5, 5)
        PlaySound('explode', 0.3)
        New(bubble, 'parimg12', self.x, self.y, 30, 4, 6, Color(0xFFFFFFFF), Color(0x00FFFFFF), LAYER.ENEMY_BULLET_EF, '')
        local a = ran:Float(0, 360)
        for i = 1, 6 do
            New(bullets.sp_ef2, self.x, self.y, ran:Float(4, 6), a + i * 60, 2, ran:Int(1, 3), self.DMG / 2)
        end
        self.vscale = 2
        self.hscale = 2
    end
    function sp_ef1:del()
        PlaySound('explode', 0.3)
        New(bubble, 'parimg12', self.x, self.y, 30, 4, 6, Color(0xFFFFFFFF), Color(0x00FFFFFF), LAYER.ENEMY_BULLET_EF, '')
        misc.KeepParticle(self)
        self.vscale = 6
        self.hscale = 6
    end
    bullets.sp_ef1 = sp_ef1
    -------------------------------------------------------
    local sp_ef2 = Class(object)
    function sp_ef2:init(x, y, v, angle, scale, index, dmg)
        self.img = 'reimu_bomb_ef'
        self.a, self.b = 100, 100
        self.killflag = true
        self.group = GROUP.PLAYER_BULLET
        self.layer = LAYER.PLAYER_BULLET
        --self.colli = false
        self.x = x
        self.y = y
        self.rot = angle
        self.vx = v * cos(angle)
        self.vy = v * sin(angle)
        self.dmg = dmg
        self.scale = scale
        self.hscale = scale
        self.vscale = scale
        self.rbg = { { 255, 0, 0 }, { 0, 255, 0 }, { 0, 0, 255 } }
        self.index = index
        self.bound = false
        --	ParticleSetEmission(self,10)
    end
    function sp_ef2:frame()
        self.vscale = self.scale * (1 - self.timer / 60)
        self.hscale = self.scale * (1 - self.timer / 60)
        if self.timer >= 30 then
            Del(self)
        end
    end
    function sp_ef2:render()
        SetImageState(self.img, 'mul+add', Color(255 - 255 * self.timer / 30, self.rbg[self.index][1], self.rbg[self.index][2], self.rbg[self.index][3]))
        Render(self.img, self.x, self.y)
        SetImageState(self.img, 'mul+add', Color(255, 255, 255, 255))
    end
    bullets.sp_ef2 = sp_ef2
end--bullets



