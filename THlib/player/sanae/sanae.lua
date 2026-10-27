do
    --resource
    local path = "assets\\player\\sanae\\"
    LoadImageFromFile("sanae_player_spell1", path .. "sanae_spell1.png")
    LoadTexture('sanae_player', path .. 'sanae.png')
    LoadImageGroup('sanae_player', 'sanae_player', 0, 0, 32, 48, 8, 3, 0, 0)
    LoadTexture('sanae_player_pic', path .. 'sanae_pic.png')

    LoadImageFromFile("sanae_player_bullet", path .. "sanae_bullet.png", true, 48, 48)
end

local langModule = "sanae_des"
loadLanguageModule(langModule, "THlib\\player\\sanae")
local function _t(str)
    return i18n(langModule, str) or ""
end

sanae_player = Class(player_class)

function sanae_player:init()
    player_class.init(self)

    player_lib.SetPlayerBulletImg(1, "sanae_player_bullet")

    self.imgs = {}
    for i = 1, 24 do
        self.imgs[i] = 'sanae_player' .. i
    end
    if player_lib.GetPlayerStarLevel(1) then
        lstg.tmpvar.SanaeSkill1 = true
    end
    if player_lib.GetPlayerStarLevel(2) then
        lstg.tmpvar.SanaeSkill2 = true
    end
    if player_lib.GetPlayerStarLevel(3) then
        lstg.tmpvar.SanaeSkill3 = true
    end
    lstg.weather.weather_order = { 2, 4, 3, 1 }
end
function sanae_player:frame()
    player_class.frame(self)
end

local lib = player_lib
local pu = lib.CreatePlayerUnit(6, "Sanae", _t("name"), _t("subname"),
        'sanae_player_pic', 550, 357, 0.32, sanae_player,
        {
            NewLockFunction("scene:3"),
            NewLockFunction("passChallenge:7"),
        }, {
            { _t("Talent1name"), _t("Talent1des"), },
            { _t("Talent2name"), _t("Talent2des"), },
            { _t("Talent3name"), _t("Talent3des"), },
        }, 150, 255, 175)

--设置等级属性
sanae_player.attribute = lib.CreatePlayerAttributeList(36.0, 6, 0.8,
        4.5, 2.0, 15, 7, 60)

lib.CreateSpellUnit(1, pu, "神风「奇异果」", "sanae_player_spell1",
        { energy = 70, protect = 4, otherpro = 0.3 })
local spell1 = plus.Class(lib.spell_class)

function spell1:init(master, attribute)
    self.master = master
    self.energy = attribute.energy
    self.protect_time = attribute.protect
    self.otherpro = attribute.otherpro
    if lstg.var.maxenergy then
        player_lib.SetEnergy(attribute.energy)
        --lstg.var.maxenergy = attribute.energy
    end
end
function spell1:drawStar(x, y, r2, g2, b2)
    local p = {}
    local A = ran:Float(0, 360)
    local R = 125
    for k = 1, 5 do
        local a = A + k * 144
        local po = New(sanae_player.bullets.PointToConnect, x + R * cos(a), y + R * sin(a), r2, g2, b2)
        table.insert(p, po)
        po._index = 1
    end
    for i = 1, 5 do
        local j = sp:TweakValue(i + 1, 5, 1)
        p[i].link[p[j]] = true
        p[j].link[p[i]] = true
    end
    return p
end
function spell1:spell()
    local p = self.master
    local t = int(self.protect_time * 60)
    PlaySound("extend2")
    p.nextspell = t
    p.protect = p.protect + t
    p.collect_line = p.collect_line - 600
    lstg.var.energy_efficiency = lstg.var.energy_efficiency - 0.75
    New(tasker, function()
        task.Wait(t)
        p.collect_line = p.collect_line + 600
        lstg.var.energy_efficiency = lstg.var.energy_efficiency + 0.75
    end)
    object.BulletDo(function(b)
        object.Kill(b)
    end)
    cutAllLaser()
    New(tasker, function()
        local t0 = t / 2
        local ks = (ran:Float(0, 1) < self.otherpro) and 2 or 1
        for k = 1, ks do
            local tool = stg_levelUPlib.GetAdditionList(1, function(add)
                return add.isTool and not stg_levelUPlib.SearchToolTag(add, "debuff")
            end)[1]
            if tool then
                local pt = self:drawStar(0, 0, tool.R, tool.G, tool.B)
                for i = 1, 5 do
                    task.Wait(t0 / 5)
                    PlaySound("lgods2")
                    local j = sp:TweakValue(i + 1, 5, 1)
                    pt[i].connected = true
                    pt[i].connect[pt[j]] = true
                    pt[j].connect[pt[i]] = true
                    NewWave(pt[i].x, pt[i].y, 2, 100, 30, tool.R, tool.G, tool.B, 0)
                    NewBon(pt[i].x, pt[i].y, 60, 128, tool.R, tool.G, tool.B)
                end
                PlaySound("slash")
                object.BulletDo(function(b)
                    object.Kill(b)
                end)
                cutAllLaser()
                for _, po in ipairs(pt) do
                    NewWave(po.x, po.y, 2, 500, 60, tool.R, tool.G, tool.B, 0)
                end
                stage_lib.NewBonusBubble(0, 0, tool, function(self)
                    self.ag = 0.02
                    task.New(self, function()
                        while self.timer < 600 do

                            if self.y < lstg.world.b + self.a then
                                self.vy = -self.vy
                                self.y = (lstg.world.b + self.a) * 2 - self.y
                            end
                            task.Wait()
                        end
                    end)
                end)
                for _, po in ipairs(pt) do
                    po._index = 0
                    po.delete = true
                end

            end
        end
    end)
    return t
end
function spell1:getDescribe()
    return _t("spelldes"):format(self.energy, self.protect_time)
end

local spells = { spell1 }
sanae_player.spells = spells
do

    local bullets = {}
    sanae_player.bullets = bullets
    local PointNormalRender = function(self)
        local c = self.cindex
        local size = self.size * (self.index + c * 0.3)
        local r = self.R * (1 - c) + self.R2 * c
        local g = self.G * (1 - c) + self.G2 * c
        local b = self.B * (1 - c) + self.B2 * c
        local totalA = self.alpha
        local ba = totalA * (self.balpha or 1)
        local la = totalA * (self.lalpha or 1)
        SetImageState("bright", "mul+add", ba * 80, r, g, b)
        Render("bright", self.x, self.y, 0, size * 5 / 150)
        SetImageState("white", "mul+add", ba * 80, r, g, b)
        misc.SectorRender(self.x, self.y, 0, size * (1 + sin(self.timer * 2) * 0.1),
                0, 360, clamp(int(size), 10, 30), 0)
        SetImageState("white", "mul+add", ba * 120, r, g, b)
        misc.SectorRender(self.x, self.y, 0, size / 3, 0, 360,
                clamp(int(size / 3), 10, 30), 0)
        local img = "white"
        local rot, len, x1, y1, x2, y2
        for lp in pairs(self.link) do
            if IsValid(lp) then
                x1, y1, x2, y2 = self.x, self.y, lp.x, lp.y
                x2, y2 = x2 - x1, y2 - y1
                rot = Angle(self, lp)
                len = Dist(self, lp)
                local alpha = 25
                if not lp.link[self] then
                    --如果对方没有连接自己（单向连接），则不透明度*2
                    alpha = 50

                end
                local width = self.stable_w and 1 or size / 6
                SetImageState(img, "mul+add", la * alpha, r, g, b)
                Render(img, x1 + x2 / 2, y1 + y2 / 2, rot, len / 16, width / 8)
                if not lp.link[self] then
                    misc.SectorRender(x1 + x2 / 2, y1 + y2 / 2, width * 2, width * 4, 0, 360, 3, rot)
                end
            end
        end
    end
    local PointToConnect = Class(object, {
        init = function(self, x, y, r2, g2, b2)
            self.alpha = 1
            self.bound = false
            self.balpha = 1
            self.x, self.y = x, y
            self.R, self.G, self.B = 250, 128, 114
            self.R2, self.G2, self.B2 = r2 or 255, g2 or 255, b2 or 255
            self.group = GROUP.PLAYER_BULLET
            self.colli = false
            self.layer = LAYER.PLAYER_BULLET
            self.size = 8
            self.index = 0
            self._index = 0
            self.link = {}
            self.connect = {}
            setmetatable(self.link, { __mode = "v" })
            setmetatable(self.connect, { __mode = "v" })
            self.connected = false
            self.cindex = 0
            self.last_point = {}
            self.linking_index = 0
            self.timer = ran:Int(1, 1000)
        end,
        frame = function(self)
            local cindex = self.connected and 1 or 0
            self.cindex = self.cindex + (-self.cindex + cindex) * 0.1
            self.index = self.index + (-self.index + self._index) * 0.1
            if self.delete and self.index < 0.001 then
                for _, lp in ipairs(self.link) do
                    lp.link[self] = nil
                end
                Del(self)
            end
        end,
        del = function()
        end,
        render = PointNormalRender
    }, true)
    bullets.PointToConnect = PointToConnect
end