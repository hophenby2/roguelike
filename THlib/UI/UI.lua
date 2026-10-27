Include "THlib\\UI\\font.lua"
ui = {}
ui.version = "v1.3.7"
local LoadImage = LoadImage
LoadTexture("hint", "assets\\UI\\hint.png", true)
LoadImage("hint.bonusfail", "hint", 0, 64, 256, 64)
LoadImage("hint.getbonus", "hint", 0, 128, 396, 64)

LoadImage("kill_time", "hint", 232, 200, 152, 56, 16, 16)
local function _t(str)
    return i18n("sth", str) or ""
end
--"THlib\\UI\\font\\title.otf"
--"THlib\\UI\\font\\default_ttf"


LoadTexture('line', 'assets\\UI\\line.png', true)
LoadImageGroup('line_', 'line', 0, 0, 200, 8, 1, 8, 0, 0)

ui.menu = {
    font_size = 0.625,
    line_height = 24,
    char_width = 20,
    num_width = 12.5,
    title_color = { 255, 255, 255 },
    unfocused_color = { 190, 190, 190 },
    unfocused_color2 = { 90, 90, 90 },
    focused_color1 = { 255, 255, 255 },
    focused_color2 = { 250, 128, 114 },
    blink_speed = 2,
    shake_time = 9,
    shake_speed = 40,
    shake_range = 3,
    sc_pr_line_per_page = 14,
    sc_pr_line_height = 22,
    sc_pr_width = 600,
    sc_pr_margin = 8,
    rep_font_size = 0.6,
    rep_line_height = 20
}

local cos, sin, screen, abs, int, lstg, table, string, tostring = cos, sin, screen, abs, int, lstg, table, string, tostring
local task, misc = task, misc
local min, max = min, max
local sign = sign
local Color = Color
local SetViewMode = SetViewMode
local SetImageState = SetImageState
local SetFontState = SetFontState
local unpack = unpack
local Render = Render
local RenderTTF2 = RenderTTF2
local RenderRect = RenderRect
local RenderText = RenderText

function ui:RenderText(ttfname, text, x, y, size, color, ...)
    local a = (color:ARGB())
    local s = size / 0.6 * _TTF_SIZES[ttfname] / 80
    for i = 1, 4 do
        RenderTTF2(ttfname, text, x + i * 0.7 * s, y - i * 0.5 * s, size, Color(a * (1 - i / 5), 0, 0, 0), ...)
    end
    RenderTTF2(ttfname, text, x, y, size, color, ...)

end

---最大宽度渲染字体
function ui:RenderTextInWidth(ttfname, text, x, y, size, maxw, color, ...)
    local a = (color:ARGB())
    local s = size / 0.6 * _TTF_SIZES[ttfname] / 80
    for i = 1, 4 do
        RenderTTF4(ttfname, text, x + i * 0.7 * s, y - i * 0.5 * s, size, maxw, Color(a * (1 - i / 5), 0, 0, 0), ...)
    end
    RenderTTF4(ttfname, text, x, y, size, maxw, color, ...)
end

function ui:RenderTextWithCommand(ttfname, text, x, y, size, alpha, ...)
    local s = size / 0.6 * _TTF_SIZES[ttfname] / 80
    for i = 1, 4 do
        RenderTTF5(ttfname, text, x + i * 0.7 * s, y - i * 0.5 * s, size, alpha * (1 - i / 5), true, ...)
    end
    RenderTTF5(ttfname, text, x, y, size, alpha, false, ...)

end

local particle = {}
local particle2 = {}
function ui:DrawBack(alpha, t)
    if t % (7 + 5 - setting.rdQual) == 0 then
        local va = ran:Float(0, 360)
        local v = 0.4

        table.insert(particle, {
            alpha = 0, maxalpha = 150,
            size = ran:Float(250, 400),
            x = ran:Float(0, 960), y = ran:Float(0, 540),
            vx = cos(va) * v, vy = sin(va) * v,
            timer = 0, lifetime = ran:Int(120, 180),
        })
        table.insert(particle, {
            alpha = 0, maxalpha = 250,
            size = ran:Float(40, 60),
            x = ran:Float(0, 960), y = ran:Float(0, 540),
            vx = cos(va) * v, vy = sin(va) * v,
            timer = 0, lifetime = ran:Int(75, 120),
        })
        table.insert(particle2, {
            alpha = 0, maxalpha = 255,
            size = ran:Float(1, 2) * ran:Int(1, 4),
            x = ran:Float(0, 960), y = ran:Float(0, 540),
            v = v, rotate = ran:Float(0, 360), o = ran:Float(1, 2) * ran:Sign(),
            timer = 0, lifetime = ran:Int(75, 120),
        })
        table.insert(particle2, {
            alpha = 0, maxalpha = 255,
            size = ran:Float(3, 4),
            x = ran:Float(0, 960), y = ran:Float(0, 540),
            v = v * 0.2, rotate = ran:Float(0, 360), o = ran:Float(1, 2) * ran:Sign(),
            timer = 0, lifetime = ran:Int(240, 480),
        })
    end
    local mouse = ext.mouse
    if mouse:isPress(1) then
        for _ = 1, setting.rdQual * 3.5 do
            local x, y = mouse.x, mouse.y
            local v = ran:Float(1, 7)
            table.insert(particle2, {
                alpha = 200, maxalpha = 200,
                size = ran:Float(1, 2) * ran:Int(1, 4),
                x = x, y = y,
                v = v, rotate = ran:Float(0, 360), o = 0,
                timer = 0, lifetime = ran:Int(20, 40),
                slow = true
            })
        end
    end

    local p
    for i = #particle, 1, -1 do
        p = particle[i]

        p.x = p.x + p.vx
        p.y = p.y + p.vy

        p.timer = p.timer + 1
        if p.timer <= 10 then
            p.alpha = min(p.maxalpha, p.alpha + p.maxalpha / 10)
        elseif p.timer > p.lifetime - 10 then
            p.alpha = max(p.alpha - p.maxalpha / 10, 0)
            if p.alpha == 0 then
                table.remove(particle, i)
            end
        end

    end
    for i = #particle2, 1, -1 do
        p = particle2[i]
        p.rotate = p.rotate + p.o
        local vx = p.v * cos(p.rotate)
        local vy = p.v * sin(p.rotate)
        p.x = p.x + vx
        p.y = p.y + vy
        if p.slow then
            p.v = p.v - p.v * 0.05
        end

        p.timer = p.timer + 1
        if p.timer <= 10 then
            p.alpha = min(p.maxalpha, p.alpha + p.maxalpha / 10)
        elseif p.timer > p.lifetime - 10 then
            p.alpha = max(p.alpha - p.maxalpha / 10, 0)
            if p.alpha == 0 then
                table.remove(particle2, i)
            end
        end

    end
    SetViewMode('ui')
    local scale = 1 + sin(t / 3) * 0.1
    local rot = -90
    local v = 3
    misc.RenderTexInRect("menu_bg_2", 0, screen.width, 0, screen.height, v * cos(rot), v * sin(rot), rot,
            scale / 2, scale / 2, "mul+add",
            Color(alpha * 150, 128 + 64 * sin(t / 2), 128 + 64 * sin(t / 4), 128 + 64 * sin(t / 6)))
    local R, G, B = sp:HSVtoRGB(t * 0.2, 0.5, 0.3)
    for _, c in ipairs(particle) do
        SetImageState("bright", "mul+add", c.alpha * alpha, R, G, B)
        Render("bright", c.x, c.y, 0, c.size / 130)
    end
    for _, c in ipairs(particle2) do
        SetImageState("bright", "mul+add", c.alpha * alpha, 255, 255, 255)
        Render("bright", c.x, c.y, 0, c.size / 130)
    end

    SetImageState("menu_bg", "mul+rev", 255, 255, 255, 255)
    Render("menu_bg", 480, 270)


end

function ui:DrawMenu(title, text, pos, x, y, alpha, timer, shake, align, tri, nopos)
    align = align or "center"
    local ttfname = "title"
    local yos
    if title == "" then
        yos = (#text + 1) * self.menu.line_height * 0.5
    else
        yos = (#text - 1) * self.menu.line_height * 0.5
        self:RenderText(ttfname, title, x, y + yos + self.menu.line_height, 1,
                Color(alpha * 255, unpack(self.menu.title_color)), "center", "vcenter")
    end
    local t, now, color, k, xos
    for i = 1, #text do
        if i == pos then
            if text[i] ~= "" then
                color = {}
                k = cos(timer * self.menu.blink_speed)
                k = k * k
                for j = 1, 3 do
                    color[j] = self.menu.focused_color1[j] * k + self.menu.focused_color2[j] * (1 - k)
                end
                xos = self.menu.shake_range * sin(self.menu.shake_speed * shake)
                t = text[i]
                now = t
                self:RenderText(ttfname, "♪" .. t, x + xos, y - i * self.menu.line_height + yos, 1 + 0.2 * tri * tri,
                        Color(alpha * 255, unpack(color)), align, "vcenter")
            end
        else
            t = text[i]
            self:RenderText(ttfname, t, x, y - i * self.menu.line_height + yos, 1,
                    Color(alpha * 255, unpack(self["menu"]["unfocused_color" .. ((nopos and nopos[i]) and "2" or "")])), align, "vcenter")
        end
    end
end

function ui:DrawMenuTTF(ttfname, title, text, pos, x, y, alpha, timer, align, tri)
    align = align or "center"
    local yos
    if title == "" then
        yos = (#text + 1) * self.menu.sc_pr_line_height * 0.5
    else
        yos = (#text - 1) * self.menu.sc_pr_line_height * 0.5
        self:RenderText(ttfname, title, x, y + yos + self.menu.sc_pr_line_height, 1, Color(alpha * 255, unpack(self.menu.title_color)), align, "vcenter", "noclip")
    end
    local color, k
    for i = 1, #text do
        if i == pos then
            color = {}
            k = cos(timer * self.menu.blink_speed)
            k = k * k
            for j = 1, 3 do
                color[j] = self.menu.focused_color1[j] * k + self.menu.focused_color2[j] * (1 - k)
            end
            self:RenderText("small_text", text[i], x, y - i * self.menu.sc_pr_line_height + yos, 1 + 0.1 * (tri or 0),
                    Color(alpha * 255, unpack(color)), align, "vcenter", "noclip")
        else
            self:RenderText("small_text", text[i], x, y - i * self.menu.sc_pr_line_height + yos, 1,
                    Color(alpha * 255, unpack(self.menu.unfocused_color)), align, "vcenter", "noclip")
        end
    end
end

local function formatnum(num)
    local S = sign(num)
    num = abs(num)
    local tmp = {}
    local var
    while num >= 1000 do
        var = num - int(num / 1000) * 1000
        table.insert(tmp, 1, string.format("%03d", var))
        num = int(num / 1000)
    end
    table.insert(tmp, 1, tostring(num))
    var = table.concat(tmp, ",")
    if S < 0 then
        var = string.format("-%s", var)
    end
    return var, #tmp - 1
end
_G.formatnum = formatnum
local function RenderScore(fontname, score, x, y, size, ...)
    if score < 10000000000000 then
        RenderText(fontname, formatnum(score), x, y, size, ...)
    else
        RenderText(fontname, "9,999,999,999,990", x, y, size, ...)
    end
end
_G.RenderScore = RenderScore

---@class lstg.lstg_ui
---@return lstg.lstg_ui
local lstg_ui = plus.Class()
lstg.lstg_ui = lstg_ui

local res_list = {
    ["tex"] = {
        "ui_bg",
        "ui_bg2",
        "menu_bg",
        "menu_bg2",
        integer = 1,
    },
    ["img"] = {
        "ui_bg",
        "ui_bg2",
        "menu_bg",
        "menu_bg2",
        integer = 2,
    },
}
function lstg_ui:reloadUI()
    for type, list in pairs(res_list) do
        for _, res in pairs(list) do
            if CheckRes(type, res) == "global" then
                RemoveResource("global", list.integer, res)
            end
        end
    end
    local pool = GetResourceStatus() or "global"
    SetResourceStatus("global")
    if self.type == 1 then
        LoadImageFromFile("ui_bg", "assets\\UI\\ui_bg.png")
        LoadImageFromFile("menu_bg", "assets\\UI\\menu_bg.png")
        LoadTexture2("ui_bg2", "assets\\UI\\ui_bg2.png")

        LoadImageFromFile("sub_menu_bg", "assets\\UI\\sub_menu_bg.png")
        LoadTexture2("lifebar", "assets\\UI\\lifebar.png")
        LoadImageFromFile("summary_back", "assets\\UI\\summary_back.png")
        LoadImageGroupFromFile("attr_icon", "assets\\UI\\attr_icon.png", true, 4, 4)
    elseif self.type == 2 then
        LoadImageFromFile("menu_bg2", "assets\\UI\\menu_bg.png")
    end
    SetResourceStatus(pool)
end
function lstg_ui:init()
    if setting.resx > setting.resy then
        self.type = 1
    else
        self.type = 2
    end
    self.alpha = 1
    self.alpha2 = 1
    self.rotate = 0
    self.lifeleft = 0
    self:reloadUI()
    self.acalpha = { 0, 0, 0 }
    self.season_alpha = 0
end
function lstg_ui:drawFrame()
    self["drawFrame" .. self.type](self)
end
function lstg_ui:drawFrame1()
    SetViewMode "ui"

    Render("ui_bg", 480, 270)

    local t = stage.current_stage.timer
    local v = lstg.var
    misc.RenderTexInRect("ui_bg2", 0, screen.width, 0, screen.height, t / 2, -t,
            30 + int((t + 90) / 360) * 78, 0.7, 0.7,
            "mul+rev", Color(20 + 20 * sin(t), sp:HSVtoRGB(t * 1.1 % 360, 0.3, 1)))
    do
        local w = lstg.world
        local x1, x2, y1, y2 = w.scrl, w.scrr, w.scrb, w.scrt
        for i = 1, 8 do
            SetImageState("white", "", 155 / 8 * (8 - i), 0, 0, 0)
            RenderRect("white", x1 - i * 2, x2 + i * 2, y1 - i * 2, y2 + i * 2)
        end
    end

    SetViewMode "world"
end
function lstg_ui:drawFrame2()
    SetViewMode "ui"
    Render("ui_bg2", 198, 264)
    SetViewMode "world"
end

function lstg_ui:ScoreRefresh()
    local cur_score = lstg.var.score
    local score = self.score or cur_score
    if score < cur_score then
        if cur_score - score <= 100 then
            score = score + 10
        elseif cur_score - score <= 1000 then
            score = score + 100
        else
            score = int(score / 10 + int((cur_score - score) / 600)) * 10 + cur_score % 10
        end
    end
    self.score = min(cur_score, score)
end

function lstg_ui:ScoreUpdate()
    self:ScoreRefresh()
end
function lstg_ui:drawScore()
    self:ScoreUpdate()
    self["drawScore" .. self.type](self)
end

CreateRenderTarget("player_avator")
function lstg_ui:drawScore1()
    SetViewMode "ui"
    local ui = ui
    local ttf = "pretty_title"
    local biggest = 9999999999990
    local Forbid = clamp

    local A = 1 - ext.pause_menu.alpha
    local s = stage.current_stage
    local t = s.timer
    local alpha = min(t / 120, 1) * A
    local falpha = alpha * 255
    local w = lstg.world
    local scrl, scrr, scrb, scrt = w.scrl, w.scrr, w.scrb, w.scrt
    local var = lstg.var
    local wea = lstg.weather

    do
        local hiscore = lstg.tmpvar.hiscore or 0
        local score = self.score or 0
        ui:RenderText(ttf, _t("hiscore"), scrl - 2, scrt + 4,
                0.8, Color(falpha, 200, 200, 230), "right", "bottom")
        ui:RenderText(ttf, formatnum(Forbid(hiscore, score, biggest)), scrl, scrt + 4,
                0.8, Color(falpha, 173, 173, 173), "left", "bottom")

        ui:RenderText(ttf, _t("score"), scrr + 2, scrt + 4,
                0.8, Color(falpha, 200, 200, 230), "left", "bottom")
        ui:RenderText(ttf, formatnum(min(score, biggest)), scrr, scrt + 4,
                0.8, Color(falpha, 255, 255, 255), "right", "bottom")
    end--分数
    do
        local diffname = { "TUTORIAL", "NORMAL", "ULTRA", "EXTRA", "CHALLENGE", "PRACTICE" }
        local name = diffname[var.difficulty + 1]
        if var.difficulty + 1 == 5 and var.challenge_select then
            name = challenge_lib.class[var.challenge_select].title
        end
        local str = ("%s   %d"):format(name, var.wave)
        if var.maxwave then
            str = ("%s   %d / %d"):format(name, var.wave, var.maxwave)
        end

        if wea.now_weather ~= 0 then
            str = str .. "  " .. weather_lib.weather[wea.now_weather].name
        end
        ui:RenderText(ttf, str, 480, scrt + 8, 0.8, Color(falpha, 200, 200, 230), "center", "bottom")
        if wea.now_season ~= 0 then
            local k = alpha * self.season_alpha
            local cx, cy = 135, 493
            local img = "season_icon_full_" .. (wea.now_season)
            SetImageState("menu_circle", "", k * 200, 200, 200, 200)
            Render("menu_circle", cx, cy, 0, 16 / 192)
            SetImageState(img, "mul+add", k * 200, 200, 200, 200)
            Render(img, cx, cy, 0, 14 / 256)
            ui:RenderText(ttf, (wea.season_last[wea.now_season] - wea.season_wave + 1),
                    cx + 13, cy - 9, 0.4, Color(k * 200, 200, 200, 230), "center", "right")
        end
    end--难度&波数&天气显示
    do
        local R, G, B = 255, 227, 132
        if lstg.tmpvar.bomb_to_protect then
            R, G, B = 218, 112, 214
        end
        if lstg.tmpvar.bird_resurrecting then
            R, G, B = 0, 0, 0
        end
        local px, py = 80, 440

        local _alpha = Forbid(t - 60, 0, 100) / 100 * 200 * A
        --player
        SetImageState("menu_circle", "", _alpha, 200, 200, 200)
        Render("menu_circle", px, py, 0, 61 / 192)
        if var.kokoro_musubu and var.energy < var.maxenergy then
            local need = stg_levelUPlib.kokoro_musubu_need()
            if var.lifeleft > need then
                SetImageState("menu_bright_circle", "mul+add", _alpha * (sin(t * 4) * 0.2 + 0.4), R, G, B)
                Render("menu_bright_circle", px, py, 0, 61 / 125)
            end
        end
        if var.silent_fire then
            local ActiveID = var.active_item[1]
            if ActiveID then
                local Active = activeItem_lib.ActiveTotalList[ActiveID]
                if Active.energy < Active.cost then
                    local need = stg_levelUPlib.silent_fire_need(Active)
                    if var.lifeleft > need then
                        SetImageState("menu_bright_circle", "mul+add", _alpha * (sin(t * 4) * 0.2 + 0.4), 200, 200, 200)
                        Render("menu_bright_circle", px, py, 0, 61 / 125)
                    end
                end
            end
        end
        if var.resurrect9 > 0 then
            for i = 0, var.resurrect9 do
                local ang = 90 + i * 18
                SetImageState("grain_a15", "add+add", _alpha, sp:HSVtoRGB(i * 45, 1, 0.4))
                Render("grain_a15", px + 68 * cos(ang), py + 68 * sin(ang), ang + 60, 1 + sin(t * 3 + i * 25) * 0.2)
            end
        end

        self.lifeleft = self.lifeleft + (-self.lifeleft + var.lifeleft) * 0.15
        local punit = player_list[var.player_select]
        local life = self.lifeleft / var.maxlife
        local weak_life = var.weak_life / var.maxlife
        local r1, r2 = 61 * 0.913, 61 * 0.957
        ---@type PlayerUnit
        misc.RenderTexInCircle(punit.picture, px, py, punit.renderx, punit.rendery - 32,
                61 * 0.913, 0, punit.renderscale * 0.5, "",
                Color(_alpha, 200, 200, 200), 75)
        do
            if not var.paralyzed then
                SetImageState("white", "", _alpha, sp:HSVtoRGB(90 * life, 0.8, 1))
                misc.SectorRender(px, py, r1, r2, 0, 360 * life, 70, 90)
                if weak_life > 0 then
                    SetImageState("white", "", _alpha, sp:HSVtoRGB(90 * life, 0.8, 0.3))
                    misc.SectorRender(px, py, r1, r2, 360 * life,
                            360 * min(1, weak_life + life), 70, 90)
                end
            end
        end

        local unlock_c = int(playerdata[punit.name].unlock_c or 0)
        local _tc = (unlock_c - 1) / 2
        local star_num = 1
        for c = -_tc, _tc do
            local starscale = 0.1
            local _x, _y = px + c * 12, py - 61 * 0.45
            local img = "menu_player_star1"
            if playerdata[punit.name].choose_skill[star_num] then
                img = "menu_player_star3"
            end
            SetImageState(img, "mul+add", _alpha, 255, 255, 255)
            Render(img, _x, _y, 0, starscale)
            star_num = star_num + 1
        end

        --spell


        --active
        local Ua
        for i = #var.UI_active_item, 1, -1 do
            Ua = var.UI_active_item[i]
            if Ua.alive then
                Ua.alpha = Ua.alpha + (-Ua.alpha + 1) * 0.1
            else
                Ua.alpha = Ua.alpha + (-Ua.alpha) * 0.1
                if Ua.alpha < 0.01 then
                    table.remove(var.UI_active_item, i)
                end
            end
            local _x, _y, _r = activeItem_lib.GetActiveUIPos(Ua, i)
            Ua.x = Ua.x + (_x - Ua.x) * 0.1
            Ua.y = Ua.y + (_y - Ua.y) * 0.1
            Ua.r = Ua.r + (_r - Ua.r) * 0.1
            local ax, ay = Ua.x, Ua.y
            local r = Ua.r
            local Active = activeItem_lib.ActiveTotalList[Ua.id]
            if Active then


                local img = Active.pic
                local Aa = alpha * Ua.alpha
                if i > 1 then
                    Aa = Aa * 0.5
                end
                local count = int(Active.energy)
                local ct = Active.energy - count
                local k = 0
                local _R, _G, _B = Active.R, Active.G, Active.B
                if count == Active.energy_max then
                    k = 1
                    ct = 1
                end
                local open = (Active.energy >= 1) and 1 or 0
                local color = Color((0.2 + k * 0.2) * _alpha * Aa, _R, _G, _B)

                SetImageState("menu_circle", "", Aa * 200, 200, 200, 200)
                Render("menu_circle", ax, ay, 0, r * 1.09 / 192)
                SetImageState("menu_bright_circle", "mul+add", Aa * _alpha * open * (sin(t * 4) * 0.2 + 0.4), _R, _G, _B)
                Render("menu_bright_circle", ax, ay, 0, r * 1.09 / 125)
                if count >= 1 and not (k == 1) then
                    SetImageState("menu_pure_circle", "mul+add", Aa * count * 30, _R, _G, _B)
                    Render("menu_pure_circle", ax, ay, 0, r / 125)
                end
                RenderTexture("menu_pure_circle", "mul+add",
                        { ax - r, ay - r + r * 2 * ct, 0.5, 0, 250 - 250 * ct, color },
                        { ax + r, ay - r + r * 2 * ct, 0.5, 250, 250 - 250 * ct, color },
                        { ax + r, ay - r, 0.5, 250, 250, color },
                        { ax - r, ay - r, 0.5, 0, 250, color })
                local offy = 0
                if Active.energy_max > 1 then
                    local p = (Active.energy_max - 1) / 2
                    local j = 1
                    local sr = 0.096 * r
                    local inc = 12 * r / 41
                    for z = -p, p do
                        SetImageState("white", "", Aa * _alpha, 255, 255, 255)
                        misc.SectorRender(ax + z * inc, ay - r * 1.2, sr, sr * 0.75, 0, 360, 6)
                        if count >= j then
                            SetImageState("white", "mul+add", Aa * _alpha * 0.5, _R, _G, _B)
                            misc.SectorRender(ax + z * inc, ay - r * 1.2, 0, sr, 0, 360, 6)
                        end
                        j = j + 1
                    end
                    offy = -r * 0.17
                end
                local tA = Forbid(r / 15 - 1, 0, 1)
                SetImageState(img, "mul+add", Aa * 200, 200, 200, 200)
                Render(img, ax, ay, 0, r * 1.5 / 256)
                ui:RenderText("title", Active.title2, ax, ay - r * 1.28 + offy,
                        0.7 * r / 41, Color(tA * Aa * 150, _R, _G, _B), "centerpoint")
                local id = Active.type
                local c = Active.charge_c * activeItem_lib.GetChargeEfficiency()
                --charge3
                local str = i18n("sth", "charge" .. id)
                if id == 1 then
                    c = c * 60
                end
                local left = (1 - Active.energy) / c
                if c == 0 then
                    left = 0
                end
                if left > 0 then
                    ui:RenderTextWithCommand("title", str:format(left), ax, ay - r * 1.6 + offy,
                            0.6 * r / 41, tA * Aa * 150, "centerpoint")
                end
            end

        end

        local S = 0
        if var.UI_active_item[1] then
            S = var.UI_active_item[1].alpha
        end
        local spx, spy = 80 - 35 * S, 90 + 22 * S
        local r = 41 - 10 * S
        do

            SetImageState("menu_circle", "", _alpha, 200, 200, 200)
            Render("menu_circle", spx, spy, 0, r * 1.09 / 192)

            local E = var.energy / var.maxenergy
            local count = int(E)
            local ct = E - count
            local k = 0
            if count == var.energy_stack then
                k = 1
                ct = 1
            end
            local open = (E >= 1) and 1 or 0
            local color = Color((0.4 + k * 0.5) * _alpha, R, G, B)

            SetImageState("menu_bright_circle", "mul+add", _alpha * open * (sin(t * 4) * 0.2 + 0.4), R, G, B)
            Render("menu_bright_circle", spx, spy, 0, r * 1.09 / 125)
            if count >= 1 and not (k == 1) then
                SetImageState("menu_pure_circle", "mul+add", count * 30, R, G, B)
                Render("menu_pure_circle", spx, spy, 0, r / 125)
            end

            RenderTexture("menu_pure_circle", "mul+add",
                    { spx - r, spy - r + r * 2 * ct, 0.5, 0, 250 - 250 * ct, color },
                    { spx + r, spy - r + r * 2 * ct, 0.5, 250, 250 - 250 * ct, color },
                    { spx + r, spy - r, 0.5, 250, 250, color },
                    { spx - r, spy - r, 0.5, 0, 250, color })
            if var.energy_stack > 1 then
                local p = (var.energy_stack - 1) / 2
                local j = 1
                local sr = 0.096 * r
                local inc = 12 * r / 41
                for z = -p, p do
                    SetImageState("white", "", _alpha, 255, 255, 255)
                    misc.SectorRender(spx + z * inc, spy - r * 1.2, sr * 0.75, sr, 0, 360, 8)
                    if count >= j then
                        SetImageState("white", "mul+add", _alpha * 0.5, R, G, B)
                        misc.SectorRender(spx + z * inc, spy - r * 1.2, 0, sr * 0.75, 0, 360, 8)
                    end
                    j = j + 1
                end
                ui:RenderText("title", ("x%0.2f"):format(player_lib.GetEnergyEfficiency()), spx, spy - r * 1.42,
                        r / 41 * 0.55, Color(_alpha, 150, 150, 150), "centerpoint")
            else
                ui:RenderText("title", ("x%0.2f"):format(player_lib.GetEnergyEfficiency()), spx, spy - r * 1.2,
                        r / 41 * 0.55, Color(_alpha, 150, 150, 150), "centerpoint")
            end
            ---@type SpellUnit
            local sp = punit.spells[var.spell_select]
            local spimg = sp.picture
            SetImageState(spimg, "", _alpha, 200, 200, 200)
            Render(spimg, spx, spy, 0, r * 1.05 / 192)

            if player.nextspell > 0 then
                ui:RenderText("big_text", ("%0.1f"):format(player.nextspell / 60), spx, spy,
                        r / 41 * 0.7, Color(_alpha, 200, 200, 200), "centerpoint")
            end
        end
    end--玩家头像与符卡充能
    do
        local p = player
        local dmg = p.damage
        local colli = p.A
        local hspeed, lspeed = p.cur_hspd, p.cur_lspd
        local s_set = p.shoot_set
        local speed_set = s_set.speed
        local bv_set = s_set.bvelocity
        local range_set = s_set.range
        local sspeed, bv, lifetime = p.cur_sspeed, p.cur_bv, p.cur_brange

        local _alphaf = function(k)
            return Forbid(t - 60 - k * 20, 0, 100) / 100 * A
        end
        local kx = 80
        local Y = 360
        local width = 45
        local img, _a
        local tsize = 0.7
        local speed = hspeed
        local ispeed = p.hspeed
        if p.__slow_flag then
            speed = lspeed
            ispeed = p.lspeed
        end
        for i, text in ipairs({
            { var.paralyzed and "???" or ("%0.1f / %0.1f"):format(var.lifeleft, var.maxlife) },
            { ("%0.2f"):format(colli), colli - p.collisize, -1, "(%+0.2f)" },
            { ("%0.2f"):format(speed), speed - ispeed, 1, "(%+0.2f)" },
            { ("%0.2f"):format(dmg), dmg - p.dmg, 1, "(%+0.2f)" },
            { ("%d"):format(lifetime), lifetime - range_set.value, 1, "(%+d)" },
            { ("%0.2f"):format(sspeed), sspeed - speed_set.value, 1, "(%+0.2f)" },
            { ("%0.2f"):format(bv), bv - bv_set.value, 1, "(%+0.2f)" }
        }) do
            img = "attr_icon" .. i
            _a = _alphaf(i)
            SetImageState(img, "", _a * 200, 255, 255, 255)
            Render(img, kx - width + 7, Y - 4, 0, 0.27)
            SetImageState("bright_line", "mul+add", _a * 200, 255, 255, 255)
            RenderRect("bright_line", kx - width * 2.5, kx + width * 2.5, Y - 12, Y - 17)
            ui:RenderText("title", text[1], kx - width + 17, Y + 4,
                    tsize, Color(_a * 200, 255, 255, 255), "left")
            if text[2] then
                local fr = lstg.FontRenderer
                fr.SetFontProvider("title")
                fr.SetScale(tsize, tsize)
                local _l, _r = fr.MeasureTextBoundary(text[1])
                local _w = (_r - _l) / 2
                local R, G, B = 100, 100, 100
                if text[2] * text[3] > 0 then
                    R, G, B = 189, 252, 201
                elseif text[2] * text[3] < 0 then
                    R, G, B = 250, 128, 114
                end
                ui:RenderText("title", text[4]:format(text[2]), kx - width + 18.5 + _w, Y + 2.5,
                        tsize * 0.8, Color(_a * 200, R, G, B), "left")
            end
            Y = Y - 27
        end
    end--面板属性

    do
        local _alpha = Forbid(t - 90, 0, 100) / 100 * A
        ui:RenderText("title", ("Chaos : %0.1f%%"):format(var.chaos), 880, 110,
                0.8, Color(_alpha * 220, 255, 135, 135), "centerpoint")
        local H = stage_lib.GetValue(180, 270, 360, 361, var.chaos, 0.8)
        local R, G, B = sp:HSVtoRGB(H, 0.7, 1)
        menu:RenderBar(880, 90, 82, 13, var.chaos, _alpha * 0.8, R, G, B)
        ui:RenderText("title", ("Level.%d"):format(var.level), 880, 65,
                0.8, Color(_alpha * 200, 255, 255, 255), "centerpoint")
        local nowexp = var.now_exp
        local maxexp = stg_levelUPlib.GetCurMaxEXP()
        menu:RenderBar(880, 45, 82, 13, nowexp / maxexp * 100, _alpha * 0.8)
        ui:RenderText("title", ("%d / %d"):format(nowexp, maxexp), 880, 45,
                0.55, Color(_alpha * 200, 189, 252, 201), "centerpoint")
        ui:RenderText("title", ("x%0.2f"):format(player_lib.GetEXPfactor()), 880, 32,
                0.43, Color(_alpha * 200, 150, 150, 150), "centerpoint")
        local ac = var.addition_count
        local color = { 189, 252, 201, 218, 112, 214, 250, 128, 114 }
        local kx, ky = 880, 480
        for k = 1, 3 do
            if ac[k] then
                self.acalpha[k] = self.acalpha[k] + (-self.acalpha[k] + 1) * 0.1
                local px, py = kx - 90 + k * 45, ky
                local size = 19 * self.acalpha[k]
                local _a = _alpha * self.acalpha[k]
                SetImageState("menu_circle", "", _a * 200, 200, 200, 200)
                Render("menu_circle", px, py, 0, size / 192)
                SetImageState("menu_pure_circle", "mul+add", _a * 75, color[k * 3 - 2], color[k * 3 - 1], color[k * 3])
                Render("menu_pure_circle", px, py, 0, (size - 1) / 125)
                local img = "addition_state" .. k
                SetImageState(img, "", _a * 200, 200, 200, 200)
                Render(img, px, py, 0, size / 150)
                if ac[k] > 1 then
                    ui:RenderText("pretty_title", ac[k], px - 2, py + 2, 0.8,
                            Color(_a * 200, 200, 200, 200), "right", "bottom")
                end
            else
                self.acalpha[k] = 0
            end
        end
        if ac[11] then
            local MAXSHOW_COUNT = 25
            local ROW = 5
            local px, py = kx, ky - 45
            local count = min(MAXSHOW_COUNT, #var.addition_order)
            local tn = math.ceil(count / ROW)
            local c = sp:TweakValue(count, ROW, 1)
            local j = 1
            for _tc = 1, ROW do
                if j > count then
                    break
                end
                local k = (tn - 1) / 2
                if _tc > c then
                    k = k - 0.5
                end
                for m = -k, k do
                    local x, y = px + ((k == 0) and 0 or (m * min(45, 45 / k))), py
                    local unit = var.addition_order[#var.addition_order + 1 - j]
                    local addition = stg_levelUPlib.AdditionTotalList[unit.id]
                    unit.x = unit.x + (-unit.x + x) * 0.1
                    unit.y = unit.y + (-unit.y + y) * 0.1
                    unit.index = unit.index + (-unit.index + 1) * 0.1
                    local _a = unit.index * _alpha
                    local size = 19 * _a
                    if addition.broken then
                        _a = _a * 0.3
                    end
                    SetImageState("menu_circle", "", _a * 200, 200, 200, 200)
                    Render("menu_circle", unit.x, unit.y, 0, size / 192)
                    SetImageState("menu_pure_circle", "mul+add", _a * 50, addition.R, addition.G, addition.B)
                    Render("menu_pure_circle", unit.x, unit.y, 0, (size - 1) / 125)
                    local img = "addition_state" .. addition.state
                    SetImageState(img, "", _a * 200, 200, 200, 200)
                    Render(img, unit.x, unit.y, 0, size / 175)
                    if unit.count > 1 then
                        ui:RenderText("pretty_title", unit.count, unit.x - 2, unit.y + 2, 0.8,
                                Color(_a * 200, 200, 200, 200), "right", "bottom")
                    end
                    j = j + 1
                end
                py = py - 45
            end
            if #var.addition_order > MAXSHOW_COUNT then
                local k = (#var.addition_order - MAXSHOW_COUNT - 1) / 2
                for m = -k, k do
                    local x, y = px + ((k == 0) and 0 or (m * min(45, 45 / k))), py
                    local unit = var.addition_order[#var.addition_order + 1 - j]
                    local addition = stg_levelUPlib.AdditionTotalList[unit.id]
                    unit.x = unit.x + (-unit.x + x) * 0.1
                    unit.y = unit.y + (-unit.y + y) * 0.1
                    unit.index = unit.index + (-unit.index + 1) * 0.1
                    local _a = unit.index * _alpha
                    local size = 19 * _a
                    if addition.broken then
                        _a = _a * 0.3
                    end
                    SetImageState("menu_circle", "", _a * 200, 200, 200, 200)
                    Render("menu_circle", unit.x, unit.y, 0, size / 192)
                    SetImageState("menu_pure_circle", "mul+add", _a * 50, addition.R, addition.G, addition.B)
                    Render("menu_pure_circle", unit.x, unit.y, 0, (size - 1) / 125)
                    local img = "addition_state" .. addition.state
                    SetImageState(img, "", _a * 200, 200, 200, 200)
                    Render(img, unit.x, unit.y, 0, size / 175)
                    if unit.count > 1 then
                        ui:RenderText("pretty_title", unit.count, unit.x - 2, unit.y + 2, 0.8,
                                Color(_a * 200, 200, 200, 200), "right", "bottom")
                    end
                    j = j + 1
                end
                py = py - 45
            end

        end
    end--游玩等级&chaos
    do
        local pro = var.lifeleft / var.maxlife
        if pro <= 0.1 then
            local H = 0
            if lstg.tmpvar.bird_resurrecting then
                H = 45
            end
            local r, g, b = sp:HSVtoRGB(H, 1 - pro / 0.2, 1)
            local ws = 100 - 50 * pro / 0.1
            misc.RenderBrightOutline(0, 960, 0, 540, ws, sin(t * 4) * 30 + 60, r, g, b)
        end
    end--危险时屏幕泛红
    do
        local _alpha = Forbid(t - 120, 0, 100) / 100 * A
        local unit = lstg.tmpvar.sakura_kekkai
        if unit then
            local a = _alpha * 255
            local x, y = 880, 170
            SetImageState("line_7", "", a, 255, 255, 255)
            RenderRect("line_7", x - 74, x + 74, y - 6, y + 2)
            ui:RenderText(ttf, _t("Sakura"), x - 70, y - 1,
                    0.7, Color(a, 218, 160, 214), "left", "bottom")
            ui:RenderText(ttf, ("%d/%d"):format(var.sakura, 50000), x + 70, y + 5,
                    0.47, Color(a, 218, 160, 214), "right", "bottom")
            SetImageState("white", "", a, 255, 255, 255)
            RenderRect("white", x - 31 + 40, x + 30.5 + 40, y - 2.5 + 2, y + 1.5 + 2)
            SetImageState("white", "", a, 50, 50, 50)
            RenderRect("white", x - 30 + 40, x + 30 + 40, y - 2 + 2, y + 1 + 2)
            local color = Color(a, 250, 128, 114)
            if unit.CD > 0 then
                color = Color(a, 128, 128, 128)
            end
            if lstg.var.ON_sakura then
                color = Color(a, 218, 112, 214)
            end
            SetImageState("white", "", color)
            RenderRect("white", x - 30 + 40, x - 30 + 40 + 60 * (var.sakura / 50000), y - 2 + 2, y + 1 + 2)
        end
        if lstg.var.todo_graze_check then
            local a = _alpha * 255
            local x, y = 880, 140
            local r, g, b = 200, 200, 200
            if var.todo_graze >= var.todo_graze_check then
                r, g, b = 189, 252, 189
            end
            SetImageState("line_7", "", a, 255, 255, 255)
            RenderRect("line_7", x - 74, x + 74, y - 6, y + 2)
            ui:RenderText(ttf, _t("ToDoGraze"), x - 70, y - 1,
                    0.7, Color(a, 255, 225, 225), "left", "bottom")
            ui:RenderText(ttf, ("%d/%d"):format(var.todo_graze, var.todo_graze_check), x + 70, y - 1,
                    0.7, Color(a, r, g, b), "right", "bottom")
            ui:RenderText(ttf, ("%d"):format(var.graze), x + 70, y - 1.5,
                    0.5, Color(a, 200, 200, 230), "right", "top")
        else
            local a = _alpha * 255
            local x, y = 880, 140
            local r, g, b = 200, 200, 230
            SetImageState("line_7", "", a, 255, 255, 255)
            RenderRect("line_7", x - 74, x + 74, y - 6, y + 2)
            ui:RenderText(ttf, _t("graze"), x - 70, y - 1,
                    0.7, Color(a, 255, 225, 225), "left", "bottom")
            ui:RenderText(ttf, ("%d"):format(var.graze), x + 70, y - 1,
                    0.7, Color(a, r, g, b), "right", "bottom")
        end
    end--其他
    SetViewMode "world"
end

function lstg_ui:drawScore2()

end

function ResetUI()
    lstg.ui = lstg.lstg_ui()
    function ui.DrawFrame()
        if lstg.ui then
            lstg.ui:drawFrame()
        end
    end
    function ui.DrawScore()
        if lstg.ui then
            lstg.ui:drawScore()
        end
    end
end

ResetUI()

ui.ChaosRenderObj = Class(object)
function ui.ChaosRenderObj:init()
    self.layer = 300
    self.group = GROUP.GHOST
    self.alpha = 0
    self._alpha = 0
    self.R, self.G, self.B = 218, 112, 214
    self._R, self._G, self._B = 218, 112, 214
    self.particle = {}
    self.turn_on_flag = {}
    self.turn_on = false
    self.turn_on2 = false
    local j = 0
    self.newpar = function(vx, life)
        j = j + setting.rdQual / 5
        if j >= 1 then
            table.insert(self.particle, {
                alpha = 0, maxalpha = ran:Float(40, 70),
                size = ran:Float(2, 5),
                rindex = 0,
                x = 960, y = ran:Float(0, 540),
                vx = -ran:Float(vx - 1, vx + 1), vy = ran:Float(-1, 1),
                timer = 0, lifetime = ran:Int(life - 15, life + 15)
            })
            table.insert(self.particle, {
                alpha = 0, maxalpha = ran:Float(40, 70),
                size = ran:Float(2, 5),
                rindex = 0,
                x = 0, y = ran:Float(0, 540),
                vx = ran:Float(vx - 1, vx + 1), vy = ran:Float(-1, 1),
                timer = 0, lifetime = ran:Int(life - 15, life + 15)
            })
            j = j - 1
        end
    end
    self.index = 0
end
function ui.ChaosRenderObj:frame()
    local c = lstg.var.chaos
    local j = 1
    local newparflag = false
    while c >= j * 50 do
        self._alpha = 1
        newparflag = true
        if not self.turn_on_flag[j] then
            self.turn_on_flag[j] = true
            for _ = 1, 100 do
                self.newpar(ran:Float(2, 25), 45)
            end
            self.index = 1
            PlaySound("focusfix")
        end
        self.R, self.G, self.B = sp:HSVtoRGB(-60 - sin(j * 55) * 75, 0.6 + sin(j * 66) * 0.1, 1)
        if c < (j + 1) * 50 then
            for k = j + 1, #self.turn_on_flag do
                self.turn_on_flag[k] = false
            end
        end
        j = j + 1
    end
    if newparflag then
        self.newpar(ran:Float(4, 4 + (j - 1)), 45)
    else
        self._alpha = 0
        self.turn_on_flag[1] = false
    end
    self.index = self.index - self.index * 0.04
    self.alpha = self.alpha + (-self.alpha + self._alpha) * 0.1
    self._R = self._R + (-self._R + self.R) * 0.1
    self._G = self._G + (-self._G + self.G) * 0.1
    self._B = self._B + (-self._B + self.B) * 0.1
    local p
    for i = #self.particle, 1, -1 do
        p = self.particle[i]
        p.x = p.x + p.vx
        p.y = p.y + p.vy
        p.vx = p.vx - p.vx * 0.06
        p.timer = p.timer + 1
        if p.timer <= 10 then
            p.alpha = p.timer / 10 * p.maxalpha
        elseif p.timer > p.lifetime - 10 then
            p.alpha = max(p.alpha - p.maxalpha / 10, 0)
            if p.alpha == 0 then
                table.remove(self.particle, i)
            end
        end

    end

end
function ui.ChaosRenderObj:render()
    SetViewMode("ui")
    local R = self._R + (255 - self._R) * self.index
    local G = self._G + (255 - self._G) * self.index
    local B = self._B + (255 - self._B) * self.index
    for _, p in ipairs(self.particle) do
        SetImageState("white", "mul+add", p.alpha * self.alpha, R, G, B)
        misc.SectorRender(p.x, p.y, p.size * p.rindex, p.size, 0, 360, 2 + setting.rdQual, 0)
    end
    local col1 = Color(0, R, G, B)
    local col2 = Color(self.alpha * 75, R, G, B)
    SetImageState("white", "mul+add", 666, 0, 0, 0)--刷新存储列表
    OriginalSetImageState("white", "mul+add", col1, col2, col2, col1)
    RenderRect("white", 960 - (152 + self.index * 100) * self.alpha, 960 + 45 - 45 * self.alpha, 0, 540)
    RenderRect("white", (152 + self.index * 100) * self.alpha, -45 + 45 * self.alpha, 0, 540)
    SetViewMode("world")
end