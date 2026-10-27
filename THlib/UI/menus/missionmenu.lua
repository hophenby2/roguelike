local XS, YS = 5120, 2880
local informationRead = {}

local Detail_Submenu = {}
local function _t(str)
    return i18n("sth", str) or ""
end

missionmenu = stage.New("mission", false, true)

function missionmenu:init()
    local imgpath = "assets\\UI\\menus\\"
    LoadImageFromFile("mission_back", imgpath .. "mission_back.png", true)
    if scoredata.new_unlock then

        local unit = mission_lib.MissionList[scoredata.new_unlock]
        scoredata.new_unlock = nil
        self:GotoPos(unit.x, unit.y)
    end
    FUNDAMENTAL_MENU = self
    self.locked = false
    self.top_bar = top_bar_Class(self, _t("explore"))
    self.exit_func = function()
        PlaySound("cancel00")
        self.locked = true
        task.New(self, function()
            mask_fader:Do("close", 30)
            task.Wait(30)
            stage.Set("none", "main")
        end)
    end
    self.top_bar:addReturnButton(self.exit_func)
    mask_fader:Do("open")

    self.maxoff = 75
    self.scale = 0.6
    self.lx, self.rx = 480, XS * self.scale - 480
    self.by, self.ty = 270, YS * self.scale - 270
    self.k_scale = self.scale
    self.x, self.y = (self.lx + self.rx) / 2 / self.scale, (self.by + self.maxoff) / self.scale
    self.k_x, self.k_y = self.x, self.y
    self.minscale = 0.2
    self.maxscale = 1.2
    self.maxscaleoff = 0.05

    self.missionlist = mission_lib.MissionList
    self.now_select = nil
    self.describe_alpha = 0
    self.content_alpha = 0
    self.is_describing = false
    self.is_contenting = false
    self.acting_unit = nil
    self.debug = false
    Detail_Submenu:init(self)
    informationRead:init(self, 928, 477)
    if self._nextk_x then
        self.k_x = self._nextk_x
        self._nextk_x = nil
    end
    if self._nextk_y then
        self.k_y = self._nextk_y
        self._nextk_y = nil
    end
    if self._nextk_scale then
        self.k_scale = self._nextk_scale
        self._nextk_scale = nil
    end
    self.particle = {}
    self.particle2 = {}
    self.block_select = false
end
function missionmenu:frame()
    if self.timer % (3 + 5 - setting.rdQual) == 0 then
        local va = ran:Float(0, 360)
        local v = 0.4

        table.insert(self.particle, {
            alpha = 0, maxalpha = 150,
            size = ran:Float(900, 1250),
            x = ran:Float(0, XS), y = ran:Float(0, YS),
            vx = cos(va) * v, vy = sin(va) * v,
            timer = 0, lifetime = ran:Int(120, 180),
        })
        table.insert(self.particle2, {
            alpha = 0, maxalpha = 255,
            size = ran:Float(3, 4) * ran:Int(1, 4),
            x = ran:Float(0, XS), y = ran:Float(0, YS),
            v = v, rotate = ran:Float(0, 360), o = ran:Float(1, 2) * ran:Sign(),
            timer = 0, lifetime = ran:Int(75, 120),
        })
        table.insert(self.particle2, {
            alpha = 0, maxalpha = 255,
            size = ran:Float(6, 7),
            x = ran:Float(0, XS), y = ran:Float(0, YS),
            v = v * 0.2, rotate = ran:Float(0, 360), o = ran:Float(1, 2) * ran:Sign(),
            timer = 0, lifetime = ran:Int(240, 480),
        })
    end
    local p
    for i = #self.particle, 1, -1 do
        p = self.particle[i]

        p.x = p.x + p.vx
        p.y = p.y + p.vy

        p.timer = p.timer + 1
        if p.timer <= 30 then
            p.alpha = min(p.maxalpha, p.alpha + p.maxalpha / 30)
        elseif p.timer > p.lifetime - 30 then
            p.alpha = max(p.alpha - p.maxalpha / 30, 0)
            if p.alpha == 0 then
                table.remove(self.particle, i)
            end
        end

    end
    for i = #self.particle2, 1, -1 do
        p = self.particle2[i]
        p.rotate = p.rotate + p.o
        local vx = p.v * cos(p.rotate)
        local vy = p.v * sin(p.rotate)
        p.x = p.x + vx
        p.y = p.y + vy

        p.timer = p.timer + 1
        if p.timer <= 10 then
            p.alpha = min(p.maxalpha, p.alpha + p.maxalpha / 10)
        elseif p.timer > p.lifetime - 10 then
            p.alpha = max(p.alpha - p.maxalpha / 10, 0)
            if p.alpha == 0 then
                table.remove(self.particle2, i)
            end
        end

    end
    if self.locked then
        return
    end
    local mouse = ext.mouse
    menu:Updatekey()
    if self.is_describing then
        if menu:keyNo() or menu:keyYes() or mouse:isDown(1) then
            PlaySound("cancel00")
            self.is_describing = false
            self.block_select = true
            task.New(self, function()
                for i = 1, 30 do
                    self.describe_alpha = 1 - task.SetMode[2](i / 30)
                    task.Wait()
                end

            end)
        end
    elseif self.is_contenting then

        Detail_Submenu:frame()
        return --不能操作top_bar
    else
        local flag
        local stopcamera = false
        for _, s in pairs(self.missionlist) do
            if s.show_condition() then
                if Dist(mouse.x, mouse.y, self:CameraToUI(s.x, s.y)) < 40 * self.scale then
                    if self.now_select ~= s then
                        self.now_select = s
                        PlaySound("select00")
                    end
                    flag = true
                    break
                end
            end
        end
        if not flag then
            self.now_select = nil
        end
        if self.now_select then
            self.now_select.index = self.now_select.index + (-self.now_select.index + 1) * 0.2
            if mouse:isUp(1) and not self.block_select then
                PlaySound("ok00")
                stopcamera = true
                self.acting_unit = self.now_select
                if self.now_select.data.new then
                    self.now_select.data.new = false

                end
                if self.now_select.data.open then
                    self.is_contenting = true
                    local au = self.acting_unit
                    local tool = au.tool
                    Detail_Submenu:In(tool)
                else
                    self.is_describing = true
                    task.New(self, function()
                        for i = 1, 30 do
                            self.describe_alpha = task.SetMode[2](i / 30)
                            task.Wait()
                        end
                    end)
                end
            end
            if self.debug then
                if mouse:isPress(1) then
                    local n = self.now_select
                    n.x, n.y = self:UIToCamera(mouse.x, mouse.y)
                    stopcamera = true
                end
            end
        end
        for _, s in pairs(self.missionlist) do
            if s ~= self.now_select then
                s.index = s.index + (-s.index) * 0.2
            end
        end
        if menu:keyNo() then
            self.exit_func()
        end
        if not stopcamera then
            self:CameraRefresh()
        end
        informationRead:frame()
    end
    if DEBUG then
        if GetLastKey() == KEY.P then
            self.debug = not self.debug
        end
    end
    if self.block_select and not mouse:isPress(1) then
        self.block_select = false
    end
    self.top_bar:frame()
end
function missionmenu:CameraRefresh()
    local mouse = ext.mouse
    if mouse:isPress(1) then
        local dx, dy = mouse.dx, mouse.dy
        self.k_x = self.k_x - dx / self.k_scale
        self.k_y = self.k_y - dy / self.k_scale
        if (dx ~= 0 or dy ~= 0) and not self.now_select then
            self.block_select = true
        end
    elseif mouse:isPress(2) then
        local dx, dy = mouse:getDrag()
        dx = dx / self.k_scale
        dy = dy / self.k_scale
        local l = hypot(dx, dy)
        local angle = math.deg(math.atan2(dy, dx))
        l = min(l, 15)
        local x = cos(angle) * l
        local y = sin(angle) * l
        self.k_x = self.k_x - x
        self.k_y = self.k_y - y
    end
    if mouse._wheel ~= 0 then
        self.k_scale = self.k_scale + mouse._wheel / 120 * 0.1
        local x, y = self:UIToCamera(mouse.x, mouse.y)
        self.k_x = self.k_x + (-self.k_x + x) * 0.2
        self.k_y = self.k_y + (-self.k_y + y) * 0.2
    end--操控
    do
        local mins = self.minscale + self.maxscaleoff
        local maxs = self.maxscale - self.maxscaleoff
        if self.k_scale < mins then
            self.k_scale = max(self.k_scale, self.minscale)
            self.k_scale = self.k_scale + (-self.k_scale + mins) * 0.1
        end
        if self.k_scale > maxs then
            self.k_scale = min(self.k_scale, self.maxscale)
            self.k_scale = self.k_scale + (-self.k_scale + maxs) * 0.1
        end
        self.lx, self.rx = 480, XS * self.k_scale - 480
        self.by, self.ty = 270, YS * self.k_scale - 270
        local lx, rx = (self.lx + self.maxoff) / self.k_scale, (self.rx - self.maxoff) / self.k_scale
        local by, ty = (self.by + self.maxoff) / self.k_scale, (self.ty - self.maxoff) / self.k_scale
        if self.k_x < lx then
            self.k_x = max(self.k_x, self.lx / self.k_scale)
            self.k_x = self.k_x + (-self.k_x + lx) * 0.1
        end
        if self.k_x > rx then
            self.k_x = min(self.k_x, self.rx / self.k_scale)
            self.k_x = self.k_x + (-self.k_x + rx) * 0.1
        end
        if self.k_y < by then
            self.k_y = max(self.k_y, self.by / self.k_scale)
            self.k_y = self.k_y + (-self.k_y + by) * 0.1
        end
        if self.k_y > ty then
            self.k_y = min(self.k_y, self.ty / self.k_scale)
            self.k_y = self.k_y + (-self.k_y + ty) * 0.1
        end
        self.scale = self.scale + (-self.scale + self.k_scale) * 0.2
        self.x = self.x + (-self.x + self.k_x) * 0.2
        self.y = self.y + (-self.y + self.k_y) * 0.2

    end--限制
end

function missionmenu:render()

    local sw, sh = 480, 270
    local scale = 1 / self.scale
    SetRenderRect(self.x - sw * scale, self.x + sw * scale, self.y - sh * scale, self.y + sh * scale,
            0, 960, 0, 540)
    local wht = 160 + sin(self.timer / 2) * 10
    SetImageState("mission_back", "", 255, wht, wht, wht)
    RenderRect("mission_back", 0, XS, 0, YS)
    local R, G, B = 85, 65, 45
    for _, p in ipairs(self.particle) do
        SetImageState("bright", "mul+rev", p.alpha, R, G, B)
        Render("bright", p.x, p.y, 0, p.size / 130)
    end
    for _, p in ipairs(self.particle2) do
        SetImageState("bright", "mul+add", p.alpha, 255, 255, 255)
        Render("bright", p.x, p.y, 0, p.size / 130)
    end

    for _, s in ipairs(self.missionlist) do
        if s.show_condition() then
            local openindex = s.data.open and 1 or 0

            local shining = sin(s.id * 114 + 3.8 * self.timer)
            local size = s.size + s.index * 0.1 + openindex * shining * 0.01
            if s.master_id then
                --SetImageState("white", "", 50 + s.index * 70 + openindex * 90, s.R, s.G, s.B)
                SetImageState("white", "", 50 + s.index * 70 + openindex * 90, 255, 255, 255)
                local sm = mission_lib.MissionList[s.master_id]
                local smsize = sm.size + sm.index * 0.1
                local dr1, dr2 = size * 43, smsize * 43
                local x1, y1, x2, y2 = sm.x, sm.y, s.x, s.y
                local dist = Dist(x1, y1, x2, y2)
                local len = dist - (dr1 + dr2)
                local cindex = (dr2 + len / 2) / dist
                local dx, dy = x2 - x1, y2 - y1
                local rot = math.deg(math.atan2(dy, dx))
                Render("white", x1 + dx * cindex, y1 + dy * cindex, rot, len / 16, 2 / 8)
            end
            local tool = s.tool
            SetImageState("bright", "mul+add", 50 + s.index * 70 + openindex * 90, tool.R, tool.G, tool.B)
            Render("bright", s.x, s.y, 0, size * 0.7)
            SetImageState("mission_unit_back", "add+alpha", 50 + s.index * 70 + openindex * 90, s.Rb, s.Gb, s.Bb)
            Render("mission_unit_back", s.x, s.y, 0, size)

            SetImageState("mission_unit_outline", "", 100 + s.index * 50 + openindex * 100, s.R, s.G, s.B)
            Render("mission_unit_outline", s.x, s.y, 0, size)--]]
            SetImageState(tool.pic, "", 100 + s.index * 50 + openindex * 110, 255, 255, 255)
            Render(tool.pic, s.x, s.y, 0, size * 0.25)
            ui:RenderText("title", tool.title2, s.x, s.y + s.size * s.index * (65 + 6 / self.scale), s.index * 0.8 / self.scale,
                    Color(s.index * 222, tool.R, tool.G, tool.B), "centerpoint")
            SetImageState("menu_bright_circle", "",
                    openindex * (110 + 46 * shining), tool.R, tool.G, tool.B)
            Render("menu_bright_circle", s.x, s.y, 0, size * 0.385)--]]
            if s.data.new then
                SetImageState("menu_newicon", "", 150 + s.index * 50, s.R, s.G, s.B)
                Render("menu_newicon", s.x + 38 * size, s.y + 38 * size, 0, 0.27)
            end
            if self.debug then
                ui:RenderText("title", ("%d,%d\n%d"):format(s.x, s.y, s.id), s.x, s.y,
                        1, Color(255, 255, 255, 255), "centerpoint")
            end
        end
    end

    SetViewMode("ui")
    informationRead:render(1)
    if self.acting_unit then
        if self.describe_alpha > 0 then
            local A = self.describe_alpha
            SetImageState("white", "", A * 125, 0, 0, 0)
            RenderRect("white", 0, 960, 0, 540)
            --SetImageState("bright_line", "mul+add", col)
            --Render("bright_line", 480, 270, 0, 400 / 200, 0.8)
            local au = self.acting_unit
            local tool = au.tool
            local text = tool.unlock_des
            if au.hide then
                text = "? ? ?" .. _t("selfToExplore")
            end

            local img = tool.pic
            local adsize = 100
            SetImageState("bright", "mul+add", A * 255, tool.R, tool.G, tool.B)
            Render("bright", 480, 270, 0, adsize / 100)
            SetImageState(img, "", A * 255, 255, 255, 255)
            Render(img, 480, 270, 0, adsize / 200)
            SetImageState("menu_circle", "", A * 255, 200, 200, 200)
            Render("menu_circle", 480, 270, 0, (adsize + 4) / 192)
            ui:RenderText("big_text", tool.title, 480, 270 - adsize * 1.17,
                    0.42, Color(A * 255, tool.R, tool.G, tool.B), "centerpoint")
            ui:RenderTextWithCommand("big_text", _t("unlockWayinExplore"):format(text),
                    480, 270 - adsize * 1.42, 0.4, A * 200, "centerpoint")
            menu:RenderBar(480, 270 - adsize * 1.68, 110, 20, au.data.progress, A * 0.7)
        end
    end
    self.top_bar:render()
    if self.acting_unit then
        if self.is_contenting then
            Detail_Submenu:render()
        end
    end

end
function missionmenu:GotoPos(x, y)
    self._nextk_x = x
    self._nextk_y = y
    self._nextk_scale = 0.65--缩小一下
end
function missionmenu:CameraToUI(x, y)
    local sw, sh = 480, 270
    local scale = 1 / self.scale
    local l, r, b, t = self.x - sw * scale, self.x + sw * scale, self.y - sh * scale, self.y + sh * scale
    local scrl, scrr, scrb, scrt = 0, 960, 0, 540
    return scrl + (scrr - scrl) * (x - l) / (r - l), scrb + (scrt - scrb) * (y - b) / (t - b)
end
function missionmenu:UIToCamera(x, y)
    local sw, sh = 480, 270
    local scale = 1 / self.scale
    local l, r, b, t = self.x - sw * scale, self.x + sw * scale, self.y - sh * scale, self.y + sh * scale
    local scrl, scrr, scrb, scrt = 0, 960, 0, 540
    return (x - scrl) * (r - l) / (scrr - scrl) + l, (y - scrb) * (t - b) / (scrt - scrb) + b
end

function Detail_Submenu:init(mainmenu)
    self.x, self.y = 480, 270
    self.w, self.h = 420, 445
    self.alpha = 0
    self.locked = true
    self.timer = 0
    self.exit_button = ExitButton(750, 480, function()
        self:Out()
        PlaySound("cancel00")
    end)
    self.mainmenu = mainmenu
    self.offy1 = 0
    self._offy1 = 0
    self.line_h_1 = 18
    self.linecount1 = 1
end
function Detail_Submenu:In(tool)
    self.english = setting.language == 2
    self.w = self.english and 480 or 420
    PlaySound("select00")
    self.tool = tool
    self._offy1 = 0
    task.New(self, function()
        for i = 1, 9 do
            self.alpha = task.SetMode[2](i / 9)
            task.Wait()
        end
        self.locked = false
    end)

end
function Detail_Submenu:Out()
    task.New(self, function()
        self.locked = true
        for i = 1, 9 do
            self.alpha = 1 - i / 9
            task.Wait()
        end
        self.mainmenu.is_contenting = false
    end)
end
function Detail_Submenu:frame()
    self.timer = self.timer + 1
    task.Do(self)
    if self.locked then
        return
    end
    local mouse = ext.mouse
    self.exit_button:frame()
    if menu:keyYes() or menu:keyNo() or menu.key == KEY.I or mouse:isUp(1) then
        self.exit_button.func()
    end
    self._offy1 = self._offy1 + (-self._offy1 + clamp(self._offy1, 0, self.line_h_1 * max(0, self.linecount1 - 14.5))) * 0.3
    self.offy1 = self.offy1 + (-self.offy1 + self._offy1) * 0.3
    if menu:keyUp() then
        self._offy1 = self._offy1 - self.line_h_1
        PlaySound("select00")
    end
    if menu:keyDown() then
        self._offy1 = self._offy1 + self.line_h_1
        PlaySound("select00")
    end
    if mouse._wheel ~= 0 then
        self._offy1 = self._offy1 - mouse._wheel / 120 * self.line_h_1
        PlaySound("select00")
    end
end
function Detail_Submenu:render()
    local A = self.alpha
    if A == 0 then
        return
    end
    do
        SetImageState("white", "", A * 180, 0, 0, 0)
        RenderRect("white", 0, 960, 0, 540)
        local x, y = self.x, self.y
        local x1, x2, y1, y2
        local w = self.w
        local h = self.h
        local T = 0.7 + 0.3 * A
        x1, x2, y1, y2 = x - w / 2 * T, x + w / 2 * T, y - h / 2 * T, y + h / 2 * T
        if self.tool.isActive then
            self.linecount1 = menu:RenderActiveDescribe(self.tool, x1, x2, y1, y2,
                    80 * T, self.offy1, self.line_h_1, A, A, self.timer)
        else
            self.linecount1 = menu:RenderToolDescribe(self.tool, x1, x2, y1, y2,
                    80 * T, self.offy1, self.line_h_1, A, A, self.timer)
        end
    end
    self.exit_button:render(A)
end

function informationRead:init(mainmenu, x, y)
    self.x, self.y = x, y
    self.func = function()
        New(SimpleNotice, self.mainmenu, _t("aboutExplore"), _t("exploreInformation"), 200, 100)
    end
    self.index = 0
    self.timer = 0
    self.r = 20
    self.selected = false
    self.locked = false
    self.mainmenu = mainmenu
end
function informationRead:frame()
    task.Do(self)
    self.timer = self.timer + 1
    if self.locked then
        return
    end
    local mouse = ext.mouse
    if Dist(self.x, self.y, mouse.x, mouse.y) < self.r then
        self.index = self.index + (-self.index + 1) * 0.1
        if not self.selected then
            self.selected = true
            PlaySound("select00")
        end
    else
        self.index = self.index - self.index * 0.1
        self.selected = false
    end
    if self.selected then
        if mouse:isUp(1) then
            self.index = self.index + 0.5
            PlaySound("ok00")
            self.func()
        end
    end
    if scoredata.guide_flag == 5 then
        self.func()
        scoredata.guide_flag = 6
    end
end
function informationRead:render(A)
    local k = self.index
    local _alpha = (150 + k * 50) * A
    local ax, ay = self.x, self.y
    local adsize = self.r + k * 10
    SetImageState("menu_questionicon", "", _alpha, 200, 200, 200)
    Render("menu_questionicon", ax, ay, 0, adsize / 64)
end