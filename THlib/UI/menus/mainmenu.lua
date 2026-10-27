---主菜单设计
local function _t(str)
    return i18n("sth", str) or ""
end

local function OpenUpdateLog(self)
    loadLanguageModule("update", "THlib\\UI\\lang")
    local text = ReplaceTextWithCommand(i18n("update", 1))
    New(SimpleNotice, self, "更新日志", text)
    if false then
        local f = io.open("update.txt", "w")
        f:write(text:gsub("§.", ""))
        f:close()
    end
end

local _Music
mainmenu = stage.New("main", false, true)
function mainmenu:init()
    lastmenu = self
    self.top_bar = top_bar_Class(self, _t("mainMenu"))
    local path = "assets\\UI\\menus\\"
    LoadTexture("mainmenu_ol", path .. "mainmenu_outline.png", true)
    local filename = path .. ("mainmenu_pic%d.png"):format(setting.language)
    LoadImageGroupFromFile("mainmenu_pic1", filename, true, 2, 3)
    LoadImage("mainmenu_white", "mainmenu_ol", 0, 0, 512, 512)
    LoadImage("mainmenu_bright", "mainmenu_ol", 512, 0, 512, 512)
    if scoredata["Alt+F4"] then
        mission_lib.GoMission(2)
    end
    FUNDAMENTAL_MENU = self
    mask_fader:Do("open")
    if scoredata.version ~= ui.version then
        --更新版本初始化
        scoredata.version = ui.version
        OpenUpdateLog(self)

    end
    do
        local d = os.date("*t")
        local date = os.time({ day = d.day, month = d.month, year = d.year })
        if date - scoredata.LastLoginDate >= 172800 then
            scoredata.ContinuousLogin = 1
        elseif date - scoredata.LastLoginDate >= 86400 then
            scoredata.ContinuousLogin = scoredata.ContinuousLogin + 1
        end
        scoredata.LastLoginDate = date
        local nine_date = os.time({ day = 7, month = 8, year = 2024 })
        if date >= nine_date then
            mission_lib.GoMission(42)
        end
    end--登录天数计算


    if _Music then
        self.music = _Music
    else
        self.music = StreamMusic("menu")
        _Music = self.music
    end
    if self.music:GetState() ~= "playing" then
        self.music:FadePlay(60, 1)
    end
    self.pos = 1
    local posR = 175
    local cx, cy = 275, 250
    local global_action = function()
        self.locked = true
        mask_fader:Do("close")
        for i = 1, 15 do
            self.tri = 1 - i / 15
            task.Wait()
        end
    end
    self.selects = {
        { x = cx, y = cy, r = 100, size = 0.9,
          event = function()
              task.New(self, function()
                  global_action()
                  stage.Set("none", "scene_select")
              end)
          end,
          picture = "mainmenu_pic11",
        },
        { x = cx + cos(18) * posR, y = cy + sin(18) * posR, r = 70, size = 0.9,
          event = function()

              task.New(self, function()
                  global_action()
                  stage.Set("none", "playdata")
              end)
          end,
          picture = "mainmenu_pic15",
        },
        { x = cx + cos(90) * posR, y = cy + sin(90) * posR, r = 70, size = 0.9,
          event = function()
              OpenUpdateLog(self)
          end,
          picture = "mainmenu_pic13",
        },
        { x = cx + cos(162) * posR, y = cy + sin(162) * posR, r = 70, size = 0.9,
          event = function()
              task.New(self, function()
                  global_action()
                  stage.Set("none", "achievement")
              end)
          end,
          picture = "mainmenu_pic16",
        },
        { x = cx + cos(234) * posR, y = cy + sin(234) * posR, r = 70, size = 0.9,
          event = function()
              task.New(self, function()
                  global_action()
                  stage.Set("none", "setting")
              end)
          end,

          picture = "mainmenu_pic14",
        },
        { x = cx + cos(306) * posR, y = cy + sin(306) * posR, r = 70, size = 0.9,
          event = function()
              task.New(self, function()

                  global_action()
                  stage.Set("none", "handbook")
              end)
          end,
          picture = "mainmenu_pic12",
        },


    }
    self.alpha = 0
    self.locked = true
    self.tri = 1
    self.rotate = 0
    self.rotate_v = 0
    self.particle = {}
    self.particle2 = {}
    self.R = 260
    task.New(self, function()
        for i = 1, 30 do
            self.alpha = task.SetMode[1](i / 30)
            task.Wait()
        end
        while GetKeyState(KEY.Z) do
            task.Wait()
        end
        self.locked = false
    end)
end
function mainmenu:frame()
    local mouse = ext.mouse
    --self._pos = self._pos + (-self._pos + self.pos) * 0.05
    self.rotate_v = self.rotate_v + (-self.rotate_v + sin(self.pos * 75)) * 0.05
    self.rotate = self.rotate + self.rotate_v
    if self.timer % (7 + 5 - setting.rdQual) == 0 then
        local va = ran:Float(0, 360)
        local v = 0.4

        table.insert(self.particle, {
            alpha = 0, maxalpha = 150,
            size = ran:Float(250, 400),
            x = ran:Float(0, 960), y = ran:Float(0, 540),
            vx = cos(va) * v, vy = sin(va) * v,
            timer = 0, lifetime = ran:Int(120, 180),
        })
        table.insert(self.particle, {
            alpha = 0, maxalpha = 250,
            size = ran:Float(40, 60),
            x = ran:Float(0, 960), y = ran:Float(0, 540),
            vx = cos(va) * v, vy = sin(va) * v,
            timer = 0, lifetime = ran:Int(75, 120),
        })
        table.insert(self.particle2, {
            alpha = 0, maxalpha = 255,
            size = ran:Float(1, 2) * ran:Int(1, 4),
            x = ran:Float(0, 960), y = ran:Float(0, 540),
            v = v, rotate = ran:Float(0, 360), o = ran:Float(1, 2) * ran:Sign(),
            timer = 0, lifetime = ran:Int(75, 120),
        })
        table.insert(self.particle2, {
            alpha = 0, maxalpha = 255,
            size = ran:Float(3, 4),
            x = ran:Float(0, 960), y = ran:Float(0, 540),
            v = v * 0.2, rotate = ran:Float(0, 360), o = ran:Float(1, 2) * ran:Sign(),
            timer = 0, lifetime = ran:Int(240, 480),
        })
    end

    if self.timer % (1 + 5 - setting.rdQual) == 0 then
        local x, y = self.selects[self.pos].x, self.selects[self.pos].y
        local v = ran:Float(1, 3)
        table.insert(self.particle2, {
            alpha = 0, maxalpha = 255,
            size = ran:Float(1, 2) * ran:Int(1, 4),
            x = x, y = y,
            v = v, rotate = ran:Float(0, 360), o = 0,
            timer = 0, lifetime = ran:Int(75, 120),
        })
    end
    if mouse:isPress(1) then
        for _ = 1, setting.rdQual * 3.5 do
            local x, y = mouse.x, mouse.y
            local v = ran:Float(1, 7)
            table.insert(self.particle2, {
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
    for i = #self.particle, 1, -1 do
        p = self.particle[i]

        p.x = p.x + p.vx
        p.y = p.y + p.vy

        p.timer = p.timer + 1
        if p.timer <= 10 then
            p.alpha = min(p.maxalpha, p.alpha + p.maxalpha / 10)
        elseif p.timer > p.lifetime - 10 then
            p.alpha = max(p.alpha - p.maxalpha / 10, 0)
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
        if p.slow then
            p.v = p.v - p.v * 0.05
        end
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
    local now_select = self.selects[self.pos]
    now_select.size = now_select.size + (-now_select.size + 1) * 0.1
    for i, n in ipairs(self.selects) do
        if i ~= self.pos then
            n.size = n.size + (-n.size + 0.9) * 0.1
        end
    end
    menu:Updatekey()

    do
        if menu:keyUp() then
            PlaySound("select00")
            self.pos = sp:TweakValue(self.pos - 1, #self.selects, 1)
        end
        if menu:keyDown() then
            PlaySound("select00")
            self.pos = sp:TweakValue(self.pos + 1, #self.selects, 1)
        end
        if menu:keyLeft() then
            PlaySound("select00")
            self.pos = sp:TweakValue(self.pos - 1, #self.selects, 1)

        end
        if menu:keyRight() then
            PlaySound("select00")
            self.pos = sp:TweakValue(self.pos + 1, #self.selects, 1)
        end
        if menu:keyYes() then
            PlaySound("ok00")
            now_select.event()
        end

    end
    do
        if mouse._wheel ~= 0 then
            self.pos = sp:TweakValue(self.pos - sign(mouse._wheel), #self.selects, 1)
            PlaySound("select00")
        end
        if mouse:isUp(1) then
            for i, n in ipairs(self.selects) do
                if Dist(mouse.x, mouse.y, n.x, n.y) <= n.r then
                    if self.pos ~= i then
                        PlaySound("select00")
                        self.pos = i
                    else
                        PlaySound("ok00")
                        now_select.event()
                    end
                    break
                end
            end
        end
    end

    self.top_bar:frame()
end
function mainmenu:render()

    SetViewMode "ui"
    local t = self.timer
    local A = self.alpha
    do

        local alpha = (t > 60) and 1 or task.SetMode[5](min(t / 60, 1))
        local scale = 45
        local rot = 25
        local v = t * 0.4

        local x, y = self.selects[1].x, self.selects[1].y
        local index = self.tri * alpha

        SetImageState("menu_circle2", "mul+add", index * 120, 200, 200, 200)
        Render("menu_circle2", x, y, 90 * index - self.rotate, 0.42 - index * 0.2)
        Render("menu_circle2", x, y, 90 * index + self.rotate, 0.42 - index * 0.1)
        for i = 0, 2 do
            SetImageState("menu_circle2", "mul+add", index * (80 - i * 10), 200, 200, 200)
            --Render("menu_circle2", 740, -80, self.rotate * (0.5 - i * 0.1), 0.4 - i * 0.1 + index * 0.1)
            Render("menu_circle2", 740, 250, self.rotate * (0.7 - i * 0.1), 0.4 - i * 0.1 + index * 0.1)
        end
        local R, G, B = 85, 65, 45
        for _, p in ipairs(self.particle) do
            SetImageState("bright", "mul+add", p.alpha * self.alpha, R, G, B)
            Render("bright", p.x, p.y, 0, p.size / 130)
        end
        for _, p in ipairs(self.particle2) do
            SetImageState("bright", "mul+add", p.alpha * self.alpha, 255, 255, 255)
            Render("bright", p.x, p.y, 0, p.size / 130)
        end
        SetImageState("menu_logo", "mul+add", 10 * index, 255, 255, 255)
        Render("menu_logo", 480, 270, 0, 1)
        SetImageState("menu_bg", "mul+rev", 255, 255, 255, 255)
        Render("menu_bg", 480, 270)
        SetImageState("menu_logo", "mul+add", 200 * index, 255, 255, 255)
        Render("menu_logo", 740 + 120 - 120 * index, 250 + sin(t) * 5, 0, 0.55)
        misc.RenderTexInRect("menu_bg_2", 0, screen.width, 0, screen.height, v * cos(rot), v * sin(rot), rot,
                scale / 2, scale / 2, "mul+add",
                Color(alpha * 150, 128 + 64 * sin(t / 2), 128 + 64 * sin(t / 4), 128 + 64 * sin(t / 6)))

    end--背景，标题，立绘

    for i, b in ipairs(self.selects) do
        local selected = (i == self.pos)
        local V = selected and 1 or 0.5
        local x, y = b.x, b.y + sin(t / i / 2) * 5
        local size = b.r / 200 * b.size
        SetImageState(b.picture, "", A * 255, 255 * V, 255 * V, 255 * V)
        Render(b.picture, x, y, 0, size)
        SetImageState("mainmenu_white", "", A * 255, 255 * V, 255 * V, 255 * V)
        Render("mainmenu_white", x, y, 0, size)
        if selected then
            SetImageState("mainmenu_bright", "mul+add", A * 230, sp:HSVtoRGB(t, 0.5, 1))
            Render("mainmenu_bright", x, y, 0, size)
        end
    end

    self.top_bar:render()
end

function mainmenu:MusicInit()
    FUNDAMENTAL_MENU = self
    if not mainmenu.music then
        self.music = StreamMusic("menu")
    end
    if self.music:GetState() ~= "playing" then
        self.music:FadePlay(60, 1)
    end
end

