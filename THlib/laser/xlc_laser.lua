LoadTexture("xlc_laser", "assets\\laser\\xlc_laser.png")
LoadImageGroupFromFile("xlc_lasernode", "assets\\laser\\xlc_lasernode.png", nil, 2, 1)
LoadImageFromFile("xlc_laser2", "assets\\laser\\xlc_laser2.png")
SetImageCenter('xlc_lasernode1', 16, 64)
SetImageCenter('xlc_lasernode2', 16, 64)

---@class WideLaser
WideLaser = Class(object)
---@param x number
---@param y number
---@param color lstg.Color
---@param rot number
---@param playsnd boolean
function WideLaser:init(x, y, color, rot, w, playsnd)
    self.x, self.y = x, y
    self.layer = LAYER.ENEMY_BULLET - 1
    self.group = GROUP.INDES
    self.w0 = w or 48
    self.w = 0
    self.vscale = (self.w + 8) / 32
    self.hscale = self.vscale
    self.color = color
    self._r, self._g, self._b = unpack(ColorList[math.ceil(color / 2)])
    self.texture = 'xlc_laser'
    self.tex_v = 6
    self.rot = rot or 0
    self.IsLaser = true
    self.alpha = 1
    self.counter = 0
    if playsnd then
        PlaySound("boon01", 0.1, self.x / 256, false)
    end
end
function WideLaser:frame()
    task.Do(self)
    self.vscale = (self.w + 8) / 32
    self.hscale = self.vscale
    if self.counter > 0 then
        self.counter = self.counter - 1
        self.w = self.w + self.dw
    end
    local player = player
    if self.w >= self.w0 - 1 and self.colli then
        local x = player.x - self.x
        local y = player.y - self.y
        local rot = self.rot
        x, y = x * cos(rot) + y * sin(rot), y * cos(rot) - x * sin(rot)
        y = abs(y)
        if x > 0 then
            if y < self.w * 10 / 32 then
                player.class.colli(player, self)
            end
            if self.timer % 4 == 0 then
                if y < self.w then
                    player.grazer.class.colli(player.grazer, self, true)
                end
            end
        end
    end
end
local Render = Render
local SetImageState = SetImageState
local RenderTexture = RenderTexture
function WideLaser:render()
    local l = (self.timer * self.tex_v) % 256
    local rot = self.rot
    local x, y = self.x, self.y
    local c0 = Color(255 * self.alpha, 255, 255, 255)
    local cosr, sinr = cos(rot), sin(rot)
    SetImageState('xlc_laser2', 'mul+add', 255 * self.alpha, self._r, self._g, self._b)
    for i = 1, 64 do
        Render('xlc_laser2', x + 16 * i * cosr, y + 16 * i * sinr, rot, 1, self.w / 32)
    end
    local w = self.w * 0.5
    RenderTexture(self.texture, '',
            { x + w * sinr, y + w * cosr, 0.5, 256 - l, 0, c0 },
            { x + l * cosr + w * sinr, y + w * cosr + l * sinr, 0.5, 256, 0, c0 },
            { x + l * cosr - w * sinr, y - w * cosr + l * sinr, 0.5, 256, 32, c0 },
            { x - w * sinr, y - w * cosr, 0.5, 256 - l, 32, c0 })
    for i = 1, 3 do
        RenderTexture(self.texture, '',
                { x + (l + (i - 1) * 256) * cosr + w * sinr, y + w * cosr + (l + (i - 1) * 256) * sinr, 0.5, 0, 0, c0 },
                { x + (l + i * 256) * cosr + w * sinr, y + w * cosr + (l + i * 256) * sinr, 0.5, 256, 0, c0 },
                { x + (l + i * 256) * cosr - w * sinr, y - w * cosr + (l + i * 256) * sinr, 0.5, 256, 32, c0 },
                { x + (l + (i - 1) * 256) * cosr - w * sinr, y - w * cosr + (l + (i - 1) * 256) * sinr, 0.5, 0, 32, c0 })
    end
    local img = 'xlc_lasernode' .. (int(self.timer / 2) % 2 + 1)
    SetImageState(img, 'mul+add', 255 * self.alpha, self._r, self._g, self._b)
    Render(img, self.x, self.y, self.rot, self.hscale * 1.5, self.vscale * 1.1)
    SetImageState(img, 'mul+add', 255 * self.alpha, 255, 255, 255)
    Render(img, self.x, self.y, self.rot, self.hscale, self.vscale)
end
function WideLaser:del()
    if not self.dk then
        object.Preserve(self)
        self.dk = true
    end
    task.New(self, function()
        self.colli = false
        local w0 = self.w0
        local w = self.w
        for i = 1, 30 do
            self.w0 = sin(90 - i * 3) * w0
            self.w = sin(90 - i * 3) * w
            task.Wait()
        end
        object.RawDel(self)
    end)
end
function WideLaser:kill()
    WideLaser.del(self)
    local x, y
    for i = 0, 800, 16 do
        x, y = self.x + i * cos(self.rot), self.y + i * sin(self.rot)
        if not sp.math.PointBoundCheck(x, y, lstg.world.boundl, lstg.world.boundr, lstg.world.boundb, lstg.world.boundt) then
            break
        end
        New(item.drop_point, x, y)
    end
end
function WideLaser:TurnOn(t, playsnd)
    t = max(1, int(t or 30))
    if playsnd then
        PlaySound('lazer00', 0.25, self.x / 200)
    end
    self.counter = t
    self.dw = (self.w0 - self.w) / t
end
function WideLaser:TurnOff(t)
    t = max(1, int(t or 30))
    self.counter = t
    self.dw = -self.w / t
end