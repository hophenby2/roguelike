local lib = stage_lib

LoadImageGroupFromFile("node_state", "assets\\pathlike\\icon.png", true, 4, 4)
LoadImageFromFile("node_select", "assets\\pathlike\\select_icon.png", true)

local function GetPathlikeEXPline(index)
    return function(t)
        return (2) * sqrt(t)
    end
end
stage_lib.GetPathlikeEXPline = GetPathlikeEXPline

local function DangerToChaos(d)
    local k = 1.246
    return max(((k ^ (d) - 1) / (k ^ (10) - 1)) * 100 + lstg.var._off_chaos, 0)
end
stage_lib.DangerToChaos = DangerToChaos

local stateColor = { "§d", "§o", "§r", "§g", "§y", "§b" }
local stateName = { "普通", "精英", "首领", "商店", "奖励", "事件" }
local stateEngName = { "Normal", "Boss", "Hard | Boss", "Store", "Bonus", "What" }
local stateRGB = {
    { 200, 200, 200 },
    { 250, 185, 185 },
    { 250, 128, 114 },
    { 189, 252, 201 },
    { 255, 227, 132 },
    { 135, 206, 235 }
}
local weaState = { "§y", "§b", "§r" }

---@param state number@
---@param class scene_class
local function NewNodeEvent(class, id, proba, wavep, state, event, title)
    ---@class node_event
    local e = {}
    e.proba = proba
    e.inscene = class.id
    e.id = id
    e.isNode = true
    e.title = title or ""
    e.wave_power = wavep
    e.state = state
    e.tagName = stateEngName[state]
    e.R, e.G, e.B = unpack(stateRGB[e.state])
    e.chaos_power = 0
    e.hard_factor = 1
    e.pro_fixed = 1
    e.dangerOffset = 0
    class.events[e.id] = e
    class.nodes[e.id] = e
    local data = stagedata.BookWave[class.id]
    data[e.id] = data[e.id] or false
    e.event = function(var)
        data[e.id] = true--开图鉴
        event(var)
    end
    e.final = function()
    end
    class.nodesBystate[e.state] = class.nodesBystate[e.state] or {}
    table.insert(class.nodesBystate[e.state], e)
    return e
end
stage_lib.NewNodeEvent = NewNodeEvent

local function NewPlace(id, node, danger, weaid)
    local tmp = {
        id = id,
        node = node,
        danger = danger,
        weather = weaid,
        cX = 0,
        cY = 0, --坐标，经渲染时计算
        next = {},
        master = {},
        index = 0,
        index2 = 0,
        size_fixed = 1,
        selected = false,
        passed = false,
        master_count = 0,
    }
    return tmp
end

local function GetNodeByPro(nodes, othercond)
    local lastpro = 0
    local prolist = {}
    local v = lstg.var
    othercond = othercond or function()
        return true
    end
    for _, n in ipairs(nodes) do
        local pro = n.proba + n.wave_power * v.wave / v.maxwave
        pro = pro * n.pro_fixed
        if pro > 0 and othercond(n) then
            table.insert(prolist, { n, lastpro, lastpro + pro })
            lastpro = lastpro + pro
        end
        n.pro_fixed = n.pro_fixed + 0.1

    end
    local target
    local n = ran:Float(0, lastpro)
    for _, p in ipairs(prolist) do
        if p[2] <= n and n < p[3] then
            local e = p[1]
            e.pro_fixed = 0.3
            target = e
            break
        end
    end
    return target
end

local function GetWeather()
    local w = lstg.weather
    local target
    local nowc = {}
    local j = 0
    for _, p in ipairs(weather_lib.weather) do
        local pro = p.pro()
        if p.state == 1 and w.TwiceXiangRui then
            pro = pro * 1.25
        end
        table.insert(nowc, { p, j, j + pro })
        j = j + pro
    end
    local c = ran:Float(0, j)
    for _, unit in ipairs(nowc) do
        if c >= unit[2] and c < unit[3] then
            target = unit[1]
            break
        end
    end
    return target
end

local function SortPlaceTotal(placetotal)
    for _, pL in ipairs(placetotal) do
        for _, p in ipairs(pL) do
            for i = #p.next, 1, -1 do
                table.remove(p.next, i)
            end
        end
    end
    local net2 = {
        { 1, 2 },
        { 2, 1 }
    }
    local net3 = {
        { 1, 2, 3 },
        { 2, 1, 3 },
        { 1, 3, 2 },
        { 2, 3, 1 },
        { 3, 1, 2 },
        { 3, 2, 1 }
    }
    for i = 1, #placetotal - 1 do
        local pList = placetotal[i]
        local pListN = placetotal[i + 1]
        if #pListN == 1 then
            for _, p in ipairs(pList) do
                table.insert(p.next, pListN[1])
            end
        else
            local ct = (#pList - 1) / 2
            local dt = (#pListN - 1) / 2
            for ci, p1 in ipairs(pList) do
                ci = -ct + (ci - 1)
                for di, p2 in ipairs(pListN) do
                    di = -dt + (di - 1)
                    if abs(ci - di) <= 1 and ran:Float(0, 1) <= 1 / (abs(ci - di) + 0.5) then
                        table.insert(p1.next, p2)
                        table.insert(p2.master, p1)
                    end
                end
            end
        end
    end
    for i = #placetotal, 2, -1 do
        local pList = placetotal[i]
        local pListN = placetotal[i - 1]
        local ct = (#pList - 1) / 2
        local dt = (#pListN - 1) / 2
        for ci, p1 in ipairs(pList) do
            ci = -ct + (ci - 1)
            for di, p2 in ipairs(pListN) do
                di = -dt + (di - 1)
                if #p1.master == 0 and abs(ci - di) < 2 then
                    table.insert(p2.next, p1)
                    table.insert(p1.master, p2)
                    break
                end
            end
        end
    end
end

local Aw, Ah = 120, 85
local function ArrangeTreeLayout(placetotal)

    local rf = 20
    for yid, xList in ipairs(placetotal) do
        local t = (#xList - 1) / 2
        for k, p in ipairs(xList) do
            local i = -t + (k - 1)
            p.cX = Aw * i + ran:Float(-rf, rf)
            p.cY = Ah * (yid - 1) + ran:Float(-rf, rf)
        end
    end
end

---@param class scene_class
local function NewStagePath(class, wavecount)
    local placetotal = {}
    local function NewPathFunc(initw, maxcount, beforePlace, xid, dividePro)
        local closeNode = {}
        local cacheFunc

        for i = initw, maxcount do
            local n
            if i == 1 then
                n = GetNodeByPro(class.nodesBystate[1])
            elseif i == wavecount then
                n = GetNodeByPro(class.nodesBystate[3])
            else
                n = GetNodeByPro(class.nodes, function(s)
                    return s.state ~= 3
                end)
            end
            local danger = max(0, i / wavecount * 12 + n.dangerOffset + ran:Float(-0.5, 0.5))
            local place = NewPlace(xid, n, danger, GetWeather())
            if i == wavecount then
                place.size_fixed = 1.35
            end
            placetotal[i] = placetotal[i] or {}
            table.insert(placetotal[i], place)
            if beforePlace then
                table.insert(beforePlace.next, place)
            end
            if i ~= initw and i ~= maxcount then
                for _ = 1, 1 do
                    if ran:Float(0, 1) <= dividePro then
                        dividePro = dividePro * 0.25
                        local c = task.SetMode[1](ran:Float(0, 1))
                        local finali = int((i + 1) + c * (maxcount - i - 1))
                        local _i = i
                        local _beforePlace = beforePlace
                        local _xid = xid + 1
                        local _dividePro = dividePro
                        cacheFunc = function()
                            return NewPathFunc(_i, finali, _beforePlace, _xid, _dividePro)
                        end
                        table.insert(closeNode, { finali, cacheFunc })
                    end
                end
            end
            for c = #closeNode, 1, -1 do
                local cn = closeNode[c]
                if cn[1] + 1 == i then
                    table.insert(cn[2]().next, place)
                    table.remove(closeNode, c)
                    dividePro = dividePro / 0.25
                end
            end
            beforePlace = place
        end
        return beforePlace
    end
    NewPathFunc(1, wavecount, nil, 1, 0.9)

    SortPlaceTotal(placetotal)
    ArrangeTreeLayout(placetotal)
    return placetotal
end
stage_lib.NewStagePath = NewStagePath

local ShowPath = Class(object)
function ShowPath:init(placetotal)
    self.alpha = 0
    self.placetotal = placetotal
    self.smear = {}
    self.bound = false
    self.colli = false
    self.state = 1
    object.SetSize(self, 10)
    self.bkalpha = 1
    self.bright = 0
    self.lockPlayer = true
    self.offx, self.offy = 0, 0
    self.ioffx, self.ioffy = 0, 0
    self.camera = {
        x = 0, y = -90,
        dx = 0, dy = 0
    }
    self.lock = true
    task.New(self, function()
        for i = 1, 45 do
            i = task.SetMode[2](i / 45)
            self.bright = i
            object.SetSize(self, 10 * (1 - i))
            player.x = clamp(player.x, -320 + 320 * i, 320 - 320 * i)
            player.y = clamp(player.y, -240 + 150 * i, 240 - 330 * i)
            task.Wait()
        end
        self.state = 2
        local cur = self.placetotal[lstg.var.now_path_y][lstg.var.now_path_x]
        self.offx, self.offy = player.x - cur.cX, player.y - cur.cY
        self.ioffx, self.ioffy = self.offx, self.offy
        for i = 1, 15 do
            self.alpha = i / 15
            task.Wait()
        end
        self.lock = false
        while not self.stop do
            task.Wait()
        end
        for i = 1, 15 do
            self.alpha = 1 - i / 15
            task.Wait()
        end
        self.state = 1
        for i = 1, 45 do
            i = task.SetMode[2](i / 45)
            self.bright = 1 - i
            object.SetSize(self, 10 * i)
            task.Wait()
        end
        Del(self)
    end)
    local v = lstg.var
    local isize = 0.4
    local indexs = 0.05
    self.GetSize = function(p, yid)
        local d = max(yid - v.now_path_y - v.path_view + 1, 1)
        return (isize + p.index * indexs + p.index2 * indexs) * p.size_fixed / d
    end
    self.GetAlpha = function(yid)
        local d = max(yid - v.now_path_y - v.path_view + 1, 1)
        return 1 / d
    end
end
function ShowPath:frame()
    task.Do(self)
    player.nextshoot = max(player.nextshoot, 2)
    player.nextspell = max(player.nextspell, 2)
    if not self.stop then
        local mouse = ext.mouse
        menu:Updatekey()
        if self.lockPlayer then
            self.x, self.y = player.x, player.y
        end
        local trackUnit = self.camera
        if self.state == 2 then

            local vx, vy = player.__move_dx, player.__move_dy
            if mouse.dx ~= 0 or mouse.dy ~= 0 then
                local rx, ry = UIToWorld(mouse.x, mouse.y)
                player.x, player.y = rx, ry
                local w = lstg.world
                local off = player.borderless_offset
                player.x = clamp(player.x, w.pl + 8 - off, w.pr - 8 + off)
                player.y = clamp(player.y, w.pb + 16 - off, w.pt - 32 + off)
                trackUnit = mouse
            end
            local index = 1
            if abs(self.ioffy - self.offy) / Ah > lstg.var.path_view then
                index = lstg.var.path_view / abs((self.ioffy - self.offy) / Ah)
                index = index * index
            end
            index = index * min(1, 200 / max(1, abs(self.ioffx - self.offx)))
            local dx, dy = vx * index, vy * index
            self.camera.dx = dx
            self.camera.dy = dy
            self.camera.x = self.camera.x + dx
            self.camera.y = self.camera.y + dy
            player.x = player.x - dx
            player.y = player.y - dy
            self.offx = self.offx - dx
            self.offy = self.offy - dy
        end
        do
            local inc = 2 + 2 * (1 - setting.rdQual / 5)
            local dx, dy = trackUnit.dx, trackUnit.dy
            local rot = Angle(dx, dy, 0, 0)
            local d = Dist(0, 0, dx, dy)
            for c = 0, d, inc do
                local x, y = player.x + cos(rot) * c, player.y + sin(rot) * c
                table.insert(self.smear, {
                    x = x, y = y, alpha = 1,
                })
            end
            local s
            for i = #self.smear, 1, -1 do
                s = self.smear[i]
                s.alpha = max(s.alpha - 0.08, 0)
                if s.alpha == 0 then
                    table.remove(self.smear, i)
                end
            end
        end
        local GetSize = self.GetSize
        local v = lstg.var
        self.selected = nil
        for _, xList in ipairs(self.placetotal) do
            for _, p in ipairs(xList) do
                p.Now2 = false
                p.selected2 = false
            end
        end
        for yid, xList in ipairs(self.placetotal) do
            for _, p in ipairs(xList) do
                local size = GetSize(p, yid)
                local _x, _y = p.cX + self.offx, p.cY + self.offy
                if yid - v.now_path_y - v.path_view <= 0 then
                    if Dist(player, _x, _y) < size * 43 then
                        if not p.selected then
                            p.selected = true
                            PlaySound("select00")
                        end
                    else
                        p.selected = false
                    end
                else
                    p.selected = false
                end
                if p.selected then
                    p.index = p.index + (-p.index + 1) * 0.1
                else
                    p.index = p.index + (-p.index) * 0.1
                end
                if p.selected2 then
                    p.index2 = p.index2 + (-p.index2 + 1) * 0.1
                else
                    p.index2 = p.index2 + (-p.index2) * 0.1
                end
                for _, p2 in ipairs(p.next) do
                    if p.selected or p.selected2 then
                        p2.selected2 = true
                    end
                end
            end

        end
        for _, xList in ipairs(self.placetotal) do
            for _, p in ipairs(xList) do
                if p.selected then
                    self.selected = p
                    break
                end
            end
            if self.selected then
                break
            end
        end
        if not self.lock then
            if menu:keyYes() or mouse:isUp(1) then

                if self.selected then
                    local cur = self.placetotal[v.now_path_y][v.now_path_x]
                    local flag
                    for _, nextp in ipairs(cur.next) do
                        if nextp == self.selected then
                            flag = true
                        end
                    end
                    if flag then
                        for px, p in ipairs(self.placetotal[v.now_path_y + 1]) do
                            if p == self.selected then
                                v.now_path_y = v.now_path_y + 1
                                v.now_path_x = px
                                self.stop = true
                                PlaySound("ok00")
                                break
                            end
                        end
                    else
                        New(info, "选择失败", 60, 14, true)
                        PlaySound("invalid")
                    end
                end
            end
        end
    end
end
function ShowPath:render()
    local x, y = self.x, self.y
    if self.state == 1 then
        local B = "Blindness"

        SetImageState(B, "", 255, 255, 255, 255)
        Render(B, x, y, 0, self.hscale, self.vscale)
        SetImageState("white", "", 255, 0, 0, 0)
        local w = lstg.world
        if x - 64 * self.hscale > w.l then
            RenderRect("white", w.l, x - 64 * self.hscale, w.t, w.b)
        end
        if x + 64 * self.hscale < w.r then
            RenderRect("white", x + 64 * self.hscale, w.r, w.t, w.b)
        end
        if y - 64 * self.hscale > w.b then
            RenderRect("white", w.l, w.r, y - 64 * self.hscale, w.b)
        end
        if y + 64 * self.hscale < w.t then
            RenderRect("white", w.l, w.r, w.t, y + 64 * self.hscale)
        end
    else

        SetImageState("white", "", self.bkalpha * 255, 0, 0, 0)
        RenderRect("white", -320, 320, -240, 240)
        local A = self.alpha
        local v = lstg.var
        local GetSize = self.GetSize
        local GetAlpha = self.GetAlpha
        for yid, xList in ipairs(self.placetotal) do
            for xid, p in ipairs(xList) do
                local sA = GetAlpha(yid) * A
                local n = p.node
                local passed = p.passed and 1 or 0
                local size = GetSize(p, yid)
                local _x, _y = p.cX + self.offx, p.cY + self.offy
                local shining = sin((yid + xid) * 114 + 3.8 * self.timer)

                if sp.math.PointBoundCheck(_x, _y, -320 - 100, 320 + 100, -240 - 100, 240 + 100) then
                    p.Now = self.placetotal[v.now_path_y][v.now_path_x] == p
                    if not p.Now and not p.Now2 then
                        sA = sA * 0.4
                    end
                    if yid - v.now_path_y - v.path_view <= 0 then
                        local wea = p.weather
                        local name = stagedata.BookWave[n.inscene][n.id] and n.title or "???"
                        ui:RenderTextWithCommand("pretty_title", ("名称：%s%s"):format(stateColor[n.state], name),
                                -320, -180, 1, p.index * 150, "left", "bottom")
                        ui:RenderTextWithCommand("pretty_title", ("性质：%s%s"):format(stateColor[n.state], stateName[n.state]),
                                -320, -200, 1, p.index * 150, "left", "bottom")
                        ui:RenderTextWithCommand("pretty_title", ("危险度：§r%0.1f"):format(p.danger),
                                -320, -220, 1, p.index * 150, "left", "bottom")
                        ui:RenderTextWithCommand("pretty_title", ("天气：%s%s"):format(weaState[wea.state], wea.name),
                                -320, -240, 1, p.index * 150, "left", "bottom")
                        SetImageState("node_select", "mul+add", sA * 200, n.R, n.G, n.B)
                        Render("node_select", _x, _y, self.timer * 3, size * 0.7 * p.index)
                        SetImageState("bright", "mul+add",
                                sA * (50 + p.index * 70 + p.index2 * 100 + passed * 90), n.R, n.G, n.B)
                        Render("bright", _x, _y, 0, size * 0.7)
                        SetImageState("mission_unit_back", "add+alpha",
                                sA * (50 + p.index * 70 + p.index2 * 100 + passed * 90), n.R, n.G, n.B)
                        Render("mission_unit_back", _x, _y, 0, size)
                        SetImageState("menu_bright_circle", "", passed * (110 + 46 * shining), 189, 252, 201)
                        Render("menu_bright_circle", _x, _y, 0, size * 0.385)
                        SetImageState("mission_unit_outline", "",
                                sA * (100 + p.index * 50 + p.index2 * 100 + passed * 100), 255, 255, 255)
                        Render("mission_unit_outline", _x, _y, 0, size)
                        local img = "node_state" .. n.state
                        SetImageState(img, "mul+add", sA * 150, 255, 255, 255)
                        Render(img, _x, _y, 0, size * 0.8)
                        ui:RenderText("pretty_title", "已通过", _x, _y,
                                0.5, Color(passed * (100 + p.index * 100), 189, 252, 201), "centerpoint")
                    else
                        SetImageState("bright", "mul+add", sA * (50), 255, 255, 255)
                        Render("bright", _x, _y, 0, size * 0.7)
                        SetImageState("mission_unit_back", "add+alpha", sA * (50), 255, 255, 255)
                        Render("mission_unit_back", _x, _y, 0, size)
                        SetImageState("mission_unit_outline", "", sA * (100), 255, 255, 255)
                        Render("mission_unit_outline", _x, _y, 0, size)
                    end
                    for _, p2 in ipairs(p.next) do
                        local x1, y1, x2, y2 = p.cX, p.cY, p2.cX, p2.cY
                        local rot = Angle(x1, y1, x2, y2)
                        local dr1, dr2 = size * 43, GetSize(p2, yid + 1) * 43
                        local dist = Dist(x1, y1, x2, y2)
                        local len = dist - dr1 - dr2
                        local dx, dy = x2 - x1, y2 - y1
                        local cindex = (dr1 + len / 2) / dist
                        local A2 = 0.4
                        if p.Now then
                            A2 = 1
                            p2.Now2 = true
                        end
                        SetImageState("white", "mul+add", A2 * GetAlpha(yid + 1) * (100 + p.index * 50 + p.index2 * 50),
                                250, 250, 250)
                        Render("white", x1 + dx * cindex + self.offx, y1 + dy * cindex + self.offy, rot, len / 16, 2 / 8)
                    end
                end
            end
        end
    end
    SetImageState("bright", "mul+add", self.bright * 255, 255, 255, 255)
    Render("bright", x, y, 0, self.bright * 0.3)
    Render("bright", x, y, 0, self.bright * 0.02)
    for _, s in ipairs(self.smear) do
        SetImageState("bright", "mul+add", max(0, s.alpha) * self.bright * 200, 255, 255, 255)
        Render("bright", s.x, s.y, 0, self.bright * 0.04)
    end
end
stage_lib.ShowPath = ShowPath

local function DoNodeEvent(self, wave, node, weather)
    local var = lstg.var
    local w = lstg.weather

    if weather then
        if w.now_weather ~= 0 then
            weather_lib.weather[w.now_weather].final()
        end
        w.now_season = weather.inseason
        w.now_weather = weather.id
        weather.init()
        table.insert(w.total_weather, w.now_weather)
    end

    task.Wait()
    if node then
        var.wave = wave
        var.now_wave_id = node.id
        stage_lib.saveWaveData()
        if var.wave ~= 1 then
            activeItem_lib.AddActiveChargeByWave()
        end
        local tvar = lstg.tmpvar
        if node.state == 3 and tvar.MarisaSkill2 then
            var.energy = var.maxenergy * var.energy_stack
        end
        player_lib.WaveInit()

        self.eventListener:Do("waveEvent@before", self, self)
        SetWave(wave, 45, node.title, nil, node.state == 3, node.state == 2 or node.state == 3)
        node.event(var)
    end
end
stage_lib.DoNodeEvent = DoNodeEvent

local WaitForSpace = Class(object)
function WaitForSpace:init()
    self.alpha = 0
    self.layer = LAYER.BG + 10
    self.group = GROUP.GHOST
    self.bound = false
    self.colli = false
    self.key = setting.keys.pass
    self.flag = true
    task.New(self, function()
        for i = 1, 30 do
            self.alpha = task.SetMode[2](i / 30)
            task.Wait()
            if GetKeyState(self.key) then
                break
            end
        end
        while not GetKeyState(self.key) do
            task.Wait()
        end
        PlaySound("explode")
        self.flag = false
        for _ = 1, 25 do
            self.alpha = max(0, self.alpha - 1 / 25)
            task.Wait()
        end
        Del(self)
    end)
    self.keyNameList = KeyCodeToName()
end
function WaitForSpace:frame()
    task.Do(self)
end
function WaitForSpace:render()
    local da = clamp(Dist(player, 0, 0) / 80, 0.3, 1)
    local A = self.alpha
    local tA = max(0.2, 600 / (self.timer + 600))
    local dname = self.keyNameList[setting.keys.pass]
    ui:RenderTextWithCommand("pretty", ("点击§y%s§d结束当前波"):format(dname),
            500 - 500 * A, 20, 0.6, tA * da * A * 150, "centerpoint")
    ui:RenderTextWithCommand("big_text", "§r该操作会使场上所有掉落物，弹幕清空",
            -500 + 500 * A, -20, 0.4, tA * da * A * 150, "centerpoint")
end
stage_lib.WaitForSpace = WaitForSpace

local function ClearScreen()
    for _, g in ObjList(GROUP.GHOST) do
        if g.isTasker then
            Del(g)
        end
    end
    object.EnemyNontjtDo(function(o)
        if not o.pass_check then
            object.Del(o)
        elseif o.is_damage then
            object.Del(o)
        end
    end)
    object.BulletDo(function(b)
        object.Del(b)
    end)
    for _, i in ObjList(GROUP.ITEM) do
        object.Del(i)
    end
end
stage_lib.ClearScreen = ClearScreen

---@overload fun(count:number, qual:number)
local function GetStoreAddition(count, minqual, maxqual, exclusionList)
    local slib = stg_levelUPlib
    local additionList = slib.GetAdditionList(count, function(tool)
        local bool = slib.SearchToolTag(tool, "store")
        if minqual then
            if maxqual then
                bool = bool and (tool.quality >= minqual) and tool.quality <= maxqual
            else
                bool = bool and tool.quality == minqual
            end
        end
        if exclusionList then
            for _, add in ipairs(exclusionList) do
                if add.id == tool.id then
                    bool = false
                    break
                end
            end
        end
        return bool
    end)
    return additionList
end
stage_lib.GetStoreAddition = GetStoreAddition

local function NewStoreBubble(x, y, tool, otherFunc, getFunc, money)
    local normalMoney = { 5, 10, 15, 20, 30 }
    local b = New(tool_lib.bubble_tool, x, y, tool, money or normalMoney[tool.quality + 1], getFunc)
    if otherFunc then
        otherFunc(b)
    end
    return b
end
stage_lib.NewStoreBubble = NewStoreBubble

---@overload fun(count:number, qual:number)
local function GetBonusAddition(count, minqual, maxqual, exclusionList)
    local slib = stg_levelUPlib
    local additionList = slib.GetAdditionList(count, function(tool)
        local bool = not slib.SearchToolTag(tool, "store")
        if minqual then
            if maxqual then
                bool = bool and (tool.quality >= minqual) and tool.quality <= maxqual
            else
                bool = bool and tool.quality == minqual
            end
        end
        if exclusionList then
            for _, add in ipairs(exclusionList) do
                if add.id == tool.id then
                    bool = false
                    break
                end
            end
        end
        return bool
    end)
    return additionList
end
stage_lib.GetBonusAddition = GetBonusAddition

local function NewBonusBubble(x, y, tool, otherFunc, getFunc)
    local b = New(tool_lib.bubble_tool, x, y, tool, 0, getFunc)
    if otherFunc then
        otherFunc(b)
    end
    return b
end
stage_lib.NewBonusBubble = NewBonusBubble
