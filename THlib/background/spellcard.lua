---@class _SC_BG
_SC_BG = Class(background)
function _SC_BG:init()
    background.init(self, true)
    self.layers = {}
end
function _SC_BG:AddLayer(tex, tile, x, y, r, vx, vy, ome, blend, hscale, vscale, init, bframe, aframe, brender, arender)
    table.insert(self.layers, {
        tex = tex,
        tile = tile and true,
        x = x or 0,
        y = y or 0,
        rot = r or 0,
        vx = vx or 0,
        vy = vy or 0,
        omega = ome or 0,
        blend = blend or "",
        a = 255,
        r = 255,
        g = 255,
        b = 255,
        Beforeframe = bframe,
        Afterframe = aframe,
        Beforerender = brender,
        Afterrender = arender,
        timer = 0,
        hscale = hscale or 1,
        vscale = vscale or 1,
        _cur_alpha = self.alpha,
        boss = self,
    })
    local l = self.layers[#self.layers]
    --l._w, l._h = GetTextureSize(l.tex)
    if init then
        init(l)
    end
    return l
end
function _SC_BG:frame()
    local a = self.alpha
    for _, lay in ipairs(self.layers) do
        if lay.Beforeframe then
            lay:Beforeframe()
        end
        lay.x = lay.x + lay.vx
        lay.y = lay.y + lay.vy
        lay.rot = lay.rot + lay.omega
        lay.timer = lay.timer + 1
        if lay.Afterframe then
            lay:Afterframe()
        end
    end
end
local misc = misc
function _SC_BG:render()
    SetViewMode 'world'
    local a = self.alpha
    if a > 0 then
        local lay
        local world = lstg.world
        for i = #self.layers, 1, -1 do
            lay = self.layers[i]
            if lay.Beforerender then
                lay:Beforerender()
            end
            lay._cur_alpha = a
            if lay.tile then
                misc.RenderTexInRect(lay.tex, world.l, world.r, world.b, world.t, lay.x, lay.y, lay.rot, lay.hscale, lay.vscale, lay.blend, Color(lay.a * a, lay.r, lay.g, lay.b))
            else
                misc.RenderTexInSize(lay.tex, lay.x, lay.y, lay.rot, lay.hscale, lay.vscale, lay.blend, Color(lay.a * a, lay.r, lay.g, lay.b))
            end
            if lay.Afterrender then
                lay:Afterrender()
            end
        end
    end
end

---极坐标渲染
_SC_BG.PolarCoordinatesRender = misc.PolarCoordinatesRender
