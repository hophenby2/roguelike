----------------------------------------
---暂停菜单
local pausemenu = {  }
local TIP = {
    "是新版本！",
    "事新版本！",
    "非常好游戏，爱来自图书",
    "遇事不决炸过去",
    "遇事不决扭一扭",
    "扭一扭，炸一炸",
    "今天也是好天气。？",
    "总有地上的水獭，敢于直面弹幕的威光(",
    "你能在这个游戏看到多少游戏的影子呢（x",
    "chaos中蕴含了人类的上限",
    "快乐三选一",
    "Next Dream...",
    "看不到我看不到我看不到我）",
    "偷懒的同源染色体",
    "How's the weather today?",
    "What season is it now?",
    "概率问题，概率问题",
    "不要盲目相信概率",
    "东方的避弹：肉鸽",
    "Life 4 EXP 2",
    "少女祈祷中……",
    "少女折寿中……",
    "少女挑战中……",
    "经验还是活着，这是个问题",
    "升级和避弹的快感，都体会到了吗",
    "漏的经验点被回收到天气里了",
    "我们移除了bug",
    "没有bug，只有特性",
    "吃药图书最新力作！",
    "抽足一百八十发，真金保底赢到家",
    "这就是梭哈！",
    "这样的肉鸽才不要呢.mp4",
    "幻想溢出",
    "典礼",
    "升（级）之残梦",
    "静海浮月",
    "⑨^⑨",
    "⑨⑨⑨⑨⑨⑨⑨⑨⑨",
    "8月7日",
    "小小星球之梦",
    "封之大玉",
    "小心钻石尘史诗级过肺",
    "绀药纯狐.jpg",
    "心连心连心连心连心",
    "以血换血换血换血换血",
    "哪儿来的这么多wave的小怪？",
    "人有悲欢离合，月有阴晴圆缺",
    "呜呜呜 呜呜呜 呜呜呜",
    "我离太阳越来越远了吗？",
    "现在神子令牌大促销！",
    "你是没见过真正的黑手.jpg",
    "世界は可愛く出来ている",
    "呜呜呜，太暴力莉",
    "Long time no see!",
    "你能收集全部的Tips吗？",
    "我得了一不升级就会死的病",
    "我得了没收到经验点就会死的病",
    "我得了没避开弹幕就会死的病",
    "这条tip是不对称的（嘘）     ",
    "最快3小时内通关",
    "成就之神V",
    "在.lua输入Rewind",
    "32767颗经验点",
    "陪你去看流星雨",
    "君不见，天文大玉天上来",
    "1秒最快能按多少次shift？",
    "PowerPoint 19.69",
    "我去，RGL啊！",
    "感谢您的支持！",
    "感谢您游玩本游戏！",
    "nil",
    "雾失楼台，月迷津渡",
    "槛菊愁烟兰泣露",
    "花在杯中，月在杯中",
    "望极春愁，黯黯生天际",
    "云破月来花弄影",
    "寒蝉凄切，对长亭晚，骤雨初歇",
    "酒杯秋吸露，诗句夜裁冰",
    "有情风万里卷潮来，无情送潮归",
    "君飞机技术本当上手",
    "长按R键无法推把",
    "馒好宛的.jpg",
    "桃花开呦李花开，姐姐妹妹动起来",
    "电脑里有一款在美少女裙下射击的游戏",
    "一钱不落虚空地",
    "或许有在控制wave难度，又或许没有",
    --提示
    "玩正篇前，别忘了先看教程！",
    "别忘了多看看道具的详细信息！",
    "别忘了看看\"探索\"页面！",
    "\"探索\"页面可以查看哪些道具还未解锁",
    "某些时候，道具不是越高等级越好",
    "注意！chaos过高会导致游玩变得困难",
    "注意！某些天气会禁用回血效果",
    "游戏中，过度上线会带来本可避免的麻烦",
    "经验点很重要，生命值更重要",
    "多被弹，chaos会水涨船高",
    "隐藏成就基本是可遇不可求的，多玩玩吧",
    "协同效果往往比叠加单一道具更有效",
    "协同效果很强大，但也不是往往都有益",
    "控制chaos是通关游戏的秘诀之一",
    "多加利用天气是通关游戏的秘诀之一",
    "你可以在\"图鉴\"中练习wave",
    "别忘了打挑战！",
    --冷知识
    "你知道吗，游戏早期曾有过子机系统",
    "你知道吗，游戏早期的wave是固定的",
    "你知道吗，游戏早期的主炮曾有着不同的贴图",
    "你知道吗，游戏早期的道具贴图曾是各类卡片",
    "你知道吗，游戏以前曾有过幸运值系统",
    "你知道吗，疯狂的火炬是天星红的前身之一",
    "你知道吗，游戏曾经有抽卡系统",
    "你知道吗，游戏曾经有资金力系统",
    "你知道吗，\"作弊模式\"曾经被称为\"充钱模式\"",
    "你知道吗，甘美之毒曾每次施加与之等层的甘毒",
    "你知道吗，大促销：神子牌令牌曾会减缓你的移动",
    "你知道吗，可持续发展是三个道具的聚合体",
    "你知道吗，灵体外质曾是4级道具",
    "你知道吗，Blood Magic的子弹曾是银色的",
    "你知道吗，惊蛰曾是没有预警提示的",
    "你知道吗，灵梦第三天赋曾是一个4级道具",
    --"",
}
_G.TIP = TIP

local function _t(str)
    return i18n("ext", str) or ""
end
local function _t2(str)
    return i18n("sth", str) or ""
end

--LoadFX("fx:pause_menu_blur", "shader\\texture_BoxBlur49.hlsl")

local CheckAddition = {}
local CheckAddition_Submenu = {}
local CheckWeather = {}
local CheckWeather_Submenu = {}
local CheckActive = {}
local CheckActive_Submenu = {}

function pausemenu:init()
    self.kill = true
    self.alpha = 0
    self.pos = 1
    self.ok = false
    self.choose = false
    self.lock = true

    self.timer = 0
    self.settime = self.timer
    self.textindex = math.random(1, #TIP)
    self.tip = TIP[self.textindex]
    self.t = 30
    self.nopos = {}
    self.eff = 0
    self.mask_color = Color(0, 255, 255, 255)
    self.mask_alph = 0
    self.mask_x = 0
    self.Option = false

    self.bgmlist = {}--用来储存正在播放的bgm
    self.pos_pre = 1
    self.pos_changed = 0
    self.pos2_pre = 1
    self.pos2_changed = 0


end

function pausemenu:frame()

    if self.kill then
        return "killed"
    end

    task.Do(self)
    if self.choosemenu then
        self.choosemenu:frame()
        return
    end
    if self.watching then
        menu:Updatekey()
        local mouse = ext.mouse
        local flag = menu:keyYes() or menu:keyNo() or mouse:isDown(1)
        if flag then
            PlaySound("ok00")
            task.New(self, function()
                for i = 1, 10 do
                    i = task.SetMode[2](i / 10)
                    self.alpha = i
                    task.Wait()
                end
                self.watching = false
            end)
        end
        return
    else
        self.watch_button:frame()
    end
    if self.CheckWeather_open then
        CheckWeather_Submenu:frame()
        return
    end
    if self.CheckAddition_open then
        CheckAddition_Submenu:frame()
        return
    end
    if self.CheckActive_open then
        CheckActive_Submenu:frame()
        return
    end
    CheckWeather:frame()
    CheckAddition:frame()
    CheckActive:frame()
    if self.lock then
        return
    end
    menu:Updatekey()
    local mouse = ext.mouse
    --last op
    self.timer = self.timer + 1
    if menu:keyNo() then
        self.button[1].func()
    end
    if menu:keyRight() then
        self.pos = sp:TweakValue(self.pos + 1, 3, 1)
        PlaySound("select00")
    end
    if menu:keyLeft() then
        self.pos = sp:TweakValue(self.pos - 1, 3, 1)
        PlaySound("select00")
    end
    if mouse._wheel ~= 0 then
        self.pos = sp:TweakValue(self.pos - sign(mouse._wheel), 3, 1)
        PlaySound("select00")
    end
    if menu:keyYes() then
        self.button[self.pos].func()
    end
    if menu.key == KEY.R then
        self.button[2].func()
    end
    if menu.key == KEY.Q then
        self.button[3].func()
    end
    for i, p in ipairs(self.button) do
        p:frame()
        if i == self.pos then
            p.index = p.index + (-p.index + 2) * 0.1
        end
    end


end
function pausemenu:render()

    if self.kill then
        return "killed"
    end

    --绘制黑色遮罩

    SetViewMode 'ui'

    local A = self.alpha
    local var = lstg.var

    do

        SetImageState('white', '', A * 150, 0, 0, 0)
        RenderRect('white', 0, screen.width, 0, screen.height)

        ui:RenderText("small_text", "Tips : " .. self.tip, 480, 125, 1,
                Color(A * 200, 250, 128, 114 + 50 * sin(self.timer * 2)), "centerpoint")
        for _, p in ipairs(self.button) do
            p:render(A)
        end
        local now = self.button[self.pos]
        local x, y = now.x, now.y
        ui:RenderText("pretty", ">", x - now.w * 0.35 + sin(self.timer * 3) * 3, y + 4,
                1, Color(A * 255, 189, 252, 201), "right", "vcenter")
        ui:RenderText("pretty", "<", x + now.w * 0.35 - sin(self.timer * 3) * 3, y + 4,
                1, Color(A * 255, 189, 252, 201), "left", "vcenter")

    end--选项与tip

    do

        local px, py = 180, 300
        local size = A * 120
        local spx, spy = 180, 180
        local spsize = 35
        local _alpha = 200 * A
        --player
        SetImageState("menu_circle", "",
                _alpha, 200, 200, 200)
        Render("menu_circle", px, py, 0, size / 192)
        ---@type PlayerUnit
        local punit = player_list[var.player_select]
        misc.RenderTexInCircle(punit.picture, px, py, punit.renderx, punit.rendery - 32,
                size * 0.913, 0, punit.renderscale * 0.5 * size / 61, "",
                Color(_alpha, 200, 200, 200), 75)

        local unlock_c = int(playerdata[punit.name].unlock_c or 0)
        local _ct = (unlock_c - 1) / 2
        local star_num = 1
        for c = -_ct, _ct do
            local starscale = 0.18
            local _x, _y = px + c * 24, py - size * 0.43
            local img = "menu_player_star1"
            if playerdata[punit.name].choose_skill[star_num] then
                img = "menu_player_star3"
            end
            SetImageState(img, "mul+add", _alpha, 255, 255, 255)
            Render(img, _x, _y, 0, starscale)
            star_num = star_num + 1
        end

        --spell
        SetImageState("menu_circle", "", _alpha, 200, 200, 200)
        Render("menu_circle", spx, spy, 0, spsize / 192)
        ---@type SpellUnit
        local sp = punit.spells[var.spell_select]
        local spimg = sp.picture
        SetImageState(spimg, "", _alpha, 200, 200, 200)
        Render(spimg, spx, spy, 0, spsize / 192)
        local p = player
        local dmg = p.damage
        local colli = p.A
        local hspeed, lspeed = p.cur_hspd, p.cur_lspd
        local sspeed, bv, lifetime = p.cur_sspeed, p.cur_bv, p.cur_brange
        for i, text in ipairs({
            { ("> %s"):format(_t2("maxlife")), var.paralyzed and "???" or ("%0.2f / %0.2f"):format(var.lifeleft, var.maxlife) },
            { ("> %s"):format(_t2("hitbox")), ("%0.2f"):format(colli) },
            { ("> %s"):format(_t2("speed")), ("%0.2f / %0.2f"):format(hspeed, lspeed) },
            { ("> %s"):format(_t2("atk")), ("%0.2f"):format(max(dmg, 0)) },
            { ("> %s"):format(_t2("srange")), ("%d"):format(lifetime) },
            { ("> %s"):format(_t2("sspeed")), ("%0.2f"):format(sspeed) },
            { ("> %s"):format(_t2("bvelocity")), ("%0.2f"):format(bv) },
        }) do
            local _y = py + size / 2 - (i - 1) * 28 + 36
            ui:RenderText("pretty_title", text[1], px + 240, _y,
                    0.9, Color(A * 255, 255, 255, 230), "left", "top")
            ui:RenderText("pretty_title", text[2], px + 240 - 12, _y,
                    0.9, Color(A * 255, 255, 255, 230), "right", "top")
            SetImageState("bright_line", "mul+add", A * 255, 255, 255, 230)
            Render("bright_line", px + 240, _y - 23, 0, 200 / 350, 0.12)
        end
    end--自机信息
    do
        local wx, wy = 270, 470
        local ex, ey = 480, 500
        local cx, cy = 600, 500
        local sx, sy = 708, 507
        local diffname = { "TUTORIAL", "NORMAL", "ULTRA", "EXTRA", "CHALLENGE", "PRACTICE" }
        if var.maxwave then
            ui:RenderText("pretty", ("%s  %d / %d"):format(diffname[var.difficulty + 1], var.wave, var.maxwave), wx, wy,
                    0.8, Color(A * 255, 200, 200, 230), "center", "bottom")
        else
            ui:RenderText("pretty", ("%s %d"):format(diffname[var.difficulty + 1], var.wave), wx, wy,
                    0.8, Color(A * 255, 200, 200, 230), "center", "bottom")
        end

        ui:RenderText("pretty_title", ("Level.%d"):format(var.level), ex, ey,
                0.8, Color(A * 200, 255, 255, 255), "centerpoint")
        local nowexp = var.now_exp
        local maxexp = stg_levelUPlib.GetCurMaxEXP()
        menu:RenderBar(ex, ey - 20, 82, 13, nowexp / maxexp * 100, A * 0.8)

        ui:RenderText("pretty_title", ("Chaos : %0.1f%%"):format(var.chaos), cx, cy,
                0.8, Color(A * 200, 250, 128, 114), "centerpoint")
        menu:RenderBar(cx, cy - 20, 82, 13, min(var.chaos, 100), A * 0.8, 250, 128, 114)
        local biggest = 9999999999990
        local hiscore = lstg.tmpvar.hiscore or 0
        local score = var.score or 0
        ui:RenderText("pretty_title", ("Score : %s"):format(formatnum(min(score, biggest))), sx, sy,
                0.8, Color(A * 200, 250, 250, 250), "left")
        ui:RenderText("pretty_title", ("HighScore : %s"):format(formatnum(clamp(hiscore, score, biggest))), sx - 22, sy - 17,
                0.8, Color(A * 200, 250, 250, 250), "left")
    end--关卡信息
    self.watch_button:render(A)
    CheckWeather:render(A)
    CheckAddition:render(A)
    CheckActive:render(A)
    CheckWeather_Submenu:render()
    CheckAddition_Submenu:render()
    CheckActive_Submenu:render()
    if self.watching then
        local A2 = 1 - A
        ui:RenderText("big_text", "Watching...", 480, 15,
                0.5, Color(A2 * 50, 255, 255, 255), "centerpoint")
    end
    if self.choosemenu then
        self.choosemenu:render()
    end
end

function pausemenu:FlyIn()
    --清除一些flag
    ext.pop_pause_menu = nil
    self.kill = false--标记为开启状态
    self.CheckWeather_open = nil
    self.CheckAddition_open = nil
    self.pos = 1
    self.ok = false
    self.choose = false
    self.lock = true
    self.textindex = math.random(1, #TIP)
    self.tip = TIP[self.textindex]
    self.timer = 0
    self.t = 30
    self.alpha = 0
    CheckAddition:init(self, CheckAddition_Submenu, 630, 270)
    CheckWeather:init(self, CheckWeather_Submenu, 78, 465)
    CheckActive:init(self, CheckActive_Submenu, 80, 90)
    CheckAddition_Submenu:init(self)
    CheckWeather_Submenu:init(self)
    CheckActive_Submenu:init(self)
    self.watching = false
    self.watch_button = {
        x = 730, y = 420, index = 0,
        r = 25,
        scale = 0.3,
        selected = false,
        text = "Watch",
        func = function()
            PlaySound("ok00")
            self.watching = true
            task.New(self, function()
                for i = 1, 10 do
                    i = task.SetMode[2](i / 10)
                    self.alpha = 1 - i
                    task.Wait()
                end
            end)
        end,
        frame = function(self)
            local mouse = ext.mouse
            if Dist(self.x, self.y, mouse.x, mouse.y) < self.r then
                self.index = self.index + (-self.index + 1) * 0.1
                if not self.selected then
                    self.selected = true
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
        end,
        render = function(self, A)
            local k = self.index
            local _alpha = (150 + k * 50) * A
            local ax, ay = self.x, self.y
            local adsize = self.r + k * 5
            SetImageState("menu_circle", "", _alpha, 200, 200, 200)
            Render("menu_circle", ax, ay, 0, adsize / 192)
            local blk = k * 40 + 200
            ui:RenderText("pretty_title", self.text, ax, ay + 0.5,
                    0.8 + k * 0.05, Color(A * 200, blk - k * 50, blk, blk - k * 50), "centerpoint")
        end
    }
    task.New(self, function()
        PlaySound('pause', 0.5)
        for i = 1, 10 do
            i = task.SetMode[2](i / 10)
            self.alpha = i
            task.Wait()
        end
        self.lock = false
    end)

    do
        local frame = attributeselectmenu.general_buttonFrame
        local render = attributeselectmenu.general_buttonRender
        local x, y = 480, 270
        local w = 450
        local h = 250
        local function GlobalAction()
            PlaySound("ok00")
            self:FlyOut()
        end
        self.button = {}
        self.button[1] = {
            x = x - w / 2, y = y - h / 2 - 50, index = 0,
            w = 230, h = 48,
            scale = 0.3,
            selected = false,
            text = _t("continueGame"),
            func = function()
                GlobalAction()
            end,
            frame = frame,
            render = render
        }
        if stage.current_stage.is_tutorial or stage.current_stage.is_practice then
            self.button[2] = {
                x = x, y = y - h / 2 - 50, index = 0,
                w = 230, h = 48,
                scale = 0.3,
                selected = false,
                text = _t("restart"),
                func = function()
                    GlobalAction()
                    stage.group.ActionDo("重新开始")
                end,
                frame = frame,
                render = render
            }
        else
            self.button[2] = {
                x = x, y = y - h / 2 - 50, index = 0,
                w = 230, h = 48,
                scale = 0.3,
                selected = false,
                text = _t("summary"),
                func = function()
                    local wave = lstg.var.wave
                    if wave >= 2 then
                        ext.SimpleChoose(self, function()
                            GlobalAction()
                            stage.group.ActionDo("进入结算")
                        end, load(""), "Warning", _t("summaryWarning"), 180, 70)
                    else
                        GlobalAction()
                        stage.group.ActionDo("进入结算")
                    end
                end,
                frame = frame,
                render = render
            }
        end
        self.button[3] = {
            x = x + w / 2, y = y - h / 2 - 50, index = 0,
            w = 230, h = 48,
            scale = 0.3,
            selected = false,
            text = _t("endGame"),
            func = function()
                local wave = lstg.var.wave
                if wave >= 2 then
                    ext.SimpleChoose(self, function()
                        GlobalAction()
                        stage.group.ActionDo("直接结束游玩")
                    end, load(""), "Warning", _t("endWarning"), 180, 70)
                else
                    GlobalAction()
                    stage.group.ActionDo("直接结束游玩")
                end
            end,
            frame = frame,
            render = render
        }
    end
    for _, v in ipairs(EnumRes("snd")) do
        if GetSoundState(v) == "playing" then
            PauseSound(v)
        end
    end
end

function pausemenu:FlyOut()

    self.lock = true

    task.New(self, function()
        for i = 1, 10 do
            self.alpha = 1 - i / 10
            task.Wait()
        end
        for _, v in ipairs(EnumRes("snd")) do
            if GetSoundState(v) == "paused" then
                ResumeSound(v)
            end
        end
        self.kill = true--标记为关闭状态
        --清除一些flag
        lstg.tmpvar.death = false
        ext.rep_over = false
    end)
end
function pausemenu:IsKilled()
    return self.kill
end

function CheckAddition:init(mainmenu, submenu, x, y)
    self.x, self.y = x, y
    self.func = function()
        self.mainmenu.CheckAddition_open = true
        -- self.locked = true
        -- self.mainmenu.lock = true
        --CheckWeather.locked = true
        self.submenu:In()
    end
    self.index = 0
    self.timer = 0
    self.r = 60
    self.selected = false
    self.locked = false
    self.mainmenu = mainmenu
    self.submenu = submenu
    self.keyname = KeyCodeToName()
end
function CheckAddition:frame()
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
    if menu.key == KEY.C then
        self.index = self.index + 0.5
        PlaySound("ok00")
        self.func()
    end
end
function CheckAddition:render(A)
    local k = self.index
    local _alpha = (150 + k * 50) * A
    local ax, ay = self.x, self.y
    local adsize = self.r + k * 10
    SetImageState("menu_circle", "", _alpha, 200, 200, 200)
    Render("menu_circle", ax, ay, 0, adsize / 192)
    local wpimg = "menu_check_addition"
    SetImageState(wpimg, "", _alpha, 200, 200, 200)
    Render(wpimg, ax, ay, 0, adsize / 192)
    ui:RenderText("pretty_title", ("%s\n(%s)"):format(_t("checkItem"), "C"), ax, ay - adsize / 2,
            0.8, Color(_alpha, 255, 255, 255), "centerpoint")
end

function CheckAddition_Submenu:init(mainmenu)
    self.english = setting.language == 2
    self.x, self.y = 480, 270
    self.w1, self.w2 = self.english and 480 or 420, self.english and 400 or 460
    self.h = 420
    --1在右边，2在左边，即详述在右边，列表在左边
    self.x1 = (960 - self.w1 - self.w2) / 2 + self.w2 + self.w1 / 2
    self.x2 = (960 - self.w1 - self.w2) / 2 + self.w2 / 2
    self.row = self.english and 5 or 6
    self.alpha = 0
    self.locked = true
    self.timer = 0
    self.exit_button = ExitButton(930, 520, function()
        self:Out()
        PlaySound("cancel00")
    end)
    self.mainmenu = mainmenu

    self.offy1 = 0
    self._offy1 = 0
    self.line_h_1 = 18
    self.linecount1 = 1
    self.offy2 = 0
    self._offy2 = 0
    self._dh = 18
    self.line_h_2 = self.w2 / self.row + self._dh
    self.linecount2 = 1
    self.bar_offx = -20
    self:refresh()
    self.tri1 = 1
    self.tri2 = 1
    self.tri3 = 1
    self.fresh_show = function()
        self.tri1 = 0
        self._offy1 = 0
        local hc = math.ceil(self.pos / self.row)
        local scrhc = math.ceil(self.h / self.line_h_2)
        self._offy2 = clamp(int(hc - scrhc / 2), 0,
                max(0, self.linecount2 - self.h / self.line_h_2)) * self.line_h_2
        task.New(self, function()
            for i = 1, 10 do
                self.tri1 = task.SetMode[2](i / 10)
                task.Wait()
            end
        end)
    end
    self.fresh_mouse = function()
        self.tri2 = 0
        task.New(self, function()
            for i = 1, 10 do
                self.tri2 = task.SetMode[2](i / 10)
                task.Wait()
            end
        end)
    end
    self.fresh_list = function()
        self.list = self.tooldatas[self.list_pos]
        self.pos = 1
        self.tri3 = 0
        self._offy2 = 0
        self.mousepos = nil
        task.New(self, function()
            for i = 1, 10 do
                self.tri3 = task.SetMode[2](i / 10)
                task.Wait()
            end
        end)
    end
    self.count_show = { 0, 0, 0, 0, 0, 0, 0 }
end
function CheckAddition_Submenu:refresh()
    self.count_show = { 0, 0, 0, 0, 0, 0, 0 }
    local tool_list = stg_levelUPlib.AdditionTotalList
    ---全部，4级，3级，2级，1级，0级，其他
    self.tooldatas = { {}, {}, {}, {}, {}, {}, {} }
    for i, c in pairs(lstg.var.addition) do
        self.count_show[1] = self.count_show[1] + c
        table.insert(self.tooldatas[1], tool_list[i])
    end
    table.sort(self.tooldatas[1], function(a, b)
        ---@type addition_unit
        local p1 = a
        local p2 = b
        local p1tool = p1.isTool and 1 or 0
        local p2tool = p2.isTool and 1 or 0
        local p1broken = p1.broken and 1 or 0
        local p2broken = p2.broken and 1 or 0
        if p1tool == p2tool then
            if p1tool == 1 then
                if p1.quality == p2.quality then
                    if p1broken == p2broken then
                        return CompareID(p1.id, p2.id)
                    else
                        return p1broken < p2broken
                    end
                else
                    return p1.quality > p2.quality
                end
            else
                if p1.state == p2.state then
                    return p1.id > p2.id
                else
                    return p1.state < p2.state

                end
            end
        else
            return p1tool > p2tool

        end
    end)
    for _, u in ipairs(self.tooldatas[1]) do
        local pos
        if u.isTool then
            pos = 6 - u.quality
        else
            pos = 7
        end
        self.count_show[pos] = self.count_show[pos] + lstg.var.addition[u.id]
        table.insert(self.tooldatas[pos], u)
    end
    self.list_pos = self.list_pos or 1
    self.list = self.tooldatas[self.list_pos]
    self.pos = max(1, self.pos or 1)
    self.mousepos = nil
end
function CheckAddition_Submenu:In()
    PlaySound("select00")
    self.locked = false
    self:refresh()
    task.New(self, function()
        for i = 1, 16 do
            self.alpha = task.SetMode[2](i / 16)
            task.Wait()
        end
    end)

end
function CheckAddition_Submenu:Out()

    task.New(self.mainmenu, function()
        --self.locked = true
        self.mainmenu.CheckAddition_open = false
        --CheckAddition.locked = false
        --CheckWeather.locked = false
        --self.mainmenu.lock = false
        for i = 1, 16 do
            self.alpha = 1 - i / 16
            task.Wait()
        end

    end)
end
function CheckAddition_Submenu:frame()
    self.timer = self.timer + 1
    task.Do(self)
    if self.locked then
        return
    end
    local mouse = ext.mouse
    menu:Updatekey()
    self._offy1 = self._offy1 + (-self._offy1 + clamp(self._offy1, 0,
            self.line_h_1 * max(0, self.linecount1 - 14.5))) * 0.3
    self.offy1 = self.offy1 + (-self.offy1 + self._offy1) * 0.3
    self._offy2 = self._offy2 + (-self._offy2 + clamp(self._offy2, 0,
            max(self.line_h_2 * self.linecount2 - self.h, 0))) * 0.3
    self.offy2 = self.offy2 + (-self.offy2 + self._offy2) * 0.3
    local x1, x2, y1, y2
    local w = self.w1
    local h = self.h
    local T = 0.7 + 0.3 * self.alpha
    local x, y = self.x1, self.y
    x1, x2, y1, y2 = x - w / 2 * T, x + w / 2 * T, y - h / 2 * T, y + h / 2 * T
    if sp.math.PointBoundCheck(mouse.x, mouse.y, x1, x2, y1, y2) then
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
           --PlaySound("select00")
        end
    else

        w = self.w2
        h = self.h
        x, y = self.x2, self.y
        x1, x2, y1, y2 = x - w / 2, x + w / 2, y - h / 2, y + h / 2
        if menu:keyLeft() then
            self.pos = sp:TweakValue(self.pos - 1, #self.list, 1)
            self.fresh_show()
            PlaySound("select00")
        end
        if menu:keyRight() then
            self.pos = sp:TweakValue(self.pos + 1, #self.list, 1)
            self.fresh_show()
            PlaySound("select00")
        end
        if menu:keyUp() then
            self.pos = sp:TweakValue(self.pos - self.row, #self.list, 1)
            self.fresh_show()
            PlaySound("select00")
        end
        if menu:keyDown() then
            self.pos = sp:TweakValue(self.pos + self.row, #self.list, 1)
            self.fresh_show()
            PlaySound("select00")
        end
        if mouse.y > y2 then
            if mouse._wheel ~= 0 then
                self.list_pos = sp:TweakValue(self.list_pos - sign(mouse._wheel),
                        #self.tooldatas, 1)
                self.fresh_list()
                self.fresh_show()
                PlaySound("select00")
            end
            if mouse:isUp(1) then
                for i = 1, #self.tooldatas do
                    local _w, _h = 45, 20
                    local X, Y = x1 + i * _w * 1.35 + self.bar_offx, y2 + _h
                    if Dist(mouse.x, mouse.y, X, Y) < _w * 0.6 then
                        self.list_pos = i
                        self.fresh_list()
                        self.fresh_show()
                        PlaySound("select00")
                        break
                    end

                end
            end
        else
            if mouse._wheel ~= 0 then
                self._offy2 = self._offy2 - mouse._wheel / 120 * self.line_h_2
            end
            do
                local dy = self._dh
                local width = self.line_h_2 - dy
                local line_h = self.line_h_2
                local xi, yi = 1, 0
                while xi + yi * self.row <= #self.list do
                    local kx = x1 + (xi - 1) * width
                    local ky = y2 - yi * line_h
                    local _x1, _x2, _y1, _y2 = kx, kx + width, ky - line_h + self.offy2, ky + self.offy2
                    if sp.math.PointBoundCheck(mouse.x, mouse.y, _x1, _x2, _y1, _y2) then
                        local pos = xi + yi * self.row
                        if self.mousepos ~= pos then
                            self.mousepos = pos
                            --PlaySound("select00")
                            self.fresh_mouse()
                        end
                        if mouse:isUp(1) then
                            self.pos = self.mousepos
                            self.fresh_show()
                            PlaySound("ok00")
                        end
                        break
                    end
                    xi = xi + 1
                    if xi == self.row + 1 then
                        xi = 1
                        yi = yi + 1
                    end
                end
            end
        end
    end
    self.exit_button:frame()
    if menu:keyYes() or menu:keyNo() or menu.key == setting.keys.special then
        menu.key = nil
        self.exit_button.func()
    end
end
function CheckAddition_Submenu:render()
    local A = self.alpha
    if A == 0 then
        return
    end
    SetImageState("white", "", A * 180, 0, 0, 0)
    RenderRect("white", 0, 960, 0, 540)
    do

        local x1, x2, y1, y2
        local w = self.w1
        local h = self.h
        local T = 0.7 + 0.3 * A
        local x, y = self.x1, self.y
        x1, x2, y1, y2 = x - w / 2 * T, x + w / 2 * T, y - h / 2 * T, y + h / 2 * T
        self.linecount1 = menu:RenderToolDescribe(self.list[self.pos], x1, x2, y1, y2,
                80 * T, self.offy1, self.line_h_1, A, A * self.tri1, self.timer, true)
    end--1
    do
        local x1, x2, y1, y2
        local w = self.w2
        local h = self.h
        local T = 0.7 + 0.3 * A
        local x, y = self.x2, self.y
        x1, x2, y1, y2 = x - w / 2 * T, x + w / 2 * T, y - h / 2 * T, y + h / 2 * T
        self.linecount2 = menu:RenderToolList(self.list, x1, x2, y1, y2, self.offy2, self.line_h_2, self._dh, self.row,
                A, self.tri1, self.tri2, self.tri3, self.pos, self.mousepos, self.timer, true)
        SetViewMode("ui")
        for i, str in ipairs({ _t("all"), _t("4Q"), _t("3Q"), _t("2Q"), _t("1Q"), _t("0Q"), _t("other") }) do
            local index = 1
            if self.list_pos ~= i then
                index = 0.4
            end
            local _w, _h = 45, 15 + index * 5
            local X, Y = x1 + i * _w * 1.35 + self.bar_offx, y2 + _h

            SetImageState("white", "", A * 255,
                    255 * index, 255 * index, 255 * index)
            RenderRect("white", X - _w / 2, X + _w / 2, y2 + 2, Y)
            RenderTTF2("pretty_title", ("%s(%d)"):format(str, self.count_show[i]), X, Y - _h * 0.4,
                    0.57 + index * 0.1, Color(255, 0, 0, 0), "centerpoint")
        end
    end--2
    self.exit_button:render(A)
end

function CheckWeather:init(mainmenu, submenu, x, y)
    self.x, self.y = x, y

    self.func = function()
        self.mainmenu.CheckWeather_open = true
        self.submenu:In()
    end
    self.index = 0
    self.timer = 0
    self.r = 60
    self.selected = false
    self.locked = false
    self.mainmenu = mainmenu
    self.submenu = submenu
end
function CheckWeather:frame()
    if lstg.weather.now_weather ~= 0 then
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
        if menu.key == KEY.Y then
            self.index = self.index + 0.5
            PlaySound("ok00")
            self.func()
        end
    end
end
function CheckWeather:render(A)
    if lstg.weather.now_season ~= 0 then
        local k = self.index
        local _alpha = (150 + k * 50) * A
        local ax, ay = self.x, self.y
        local adsize = self.r + k * 10
        local wea = lstg.weather
        SetImageState("menu_circle", "", _alpha, 200, 200, 200)
        Render("menu_circle", ax, ay, 0, adsize / 192)
        local wpimg = "season_icon_full_" .. (wea.now_season)
        SetImageState(wpimg, "mul+add", _alpha, 200, 200, 200)
        Render(wpimg, ax, ay, 0, adsize * 0.7 / 192)
        ui:RenderText("pretty_title", ("%s\n(%s)"):format(_t("checkWea"), "y"), ax, ay - adsize / 2,
                0.8, Color(_alpha, 255, 255, 255), "centerpoint")
    end
end

function CheckWeather_Submenu:init(mainmenu)
    self.english = setting.language == 2
    self.x, self.y = 480, 270
    self.w1, self.w2 = self.english and 500 or 350, 360
    self.h = 400
    --1在右边，2在左边，即详述在右边，列表在左边
    self.x1 = (960 - self.w1 - self.w2) / 2 + self.w2 + self.w1 / 2
    self.x2 = (960 - self.w1 - self.w2) / 2 + self.w2 / 2
    self.row = self.english and 4 or 5
    self.alpha = 0
    self.locked = true
    self.timer = 0
    self.exit_button = ExitButton(860, 500, function()
        self:Out()
        PlaySound("cancel00")
    end)
    self.mainmenu = mainmenu

    self.offy1 = 0
    self._offy1 = 0
    self.line_h_1 = 18
    self.linecount1 = 1
    self.offy2 = 0
    self._offy2 = 0
    self._dh = 20
    self.line_h_2 = 35 + self._dh
    self.linecount2 = 1
    self.bar_offx = -20
    self:refresh()
    self.tri1 = 1
    self.tri2 = 1
    self.tri3 = 1
    self.fresh_show = function()
        self.tri1 = 0
        self._offy1 = 0
        local hc = math.ceil(self.pos / self.row)
        local scrhc = math.ceil(self.h / self.line_h_2)
        self._offy2 = clamp(int(hc - scrhc / 2), 0,
                max(0, self.linecount2 - self.h / self.line_h_2)) * self.line_h_2
        task.New(self, function()
            for i = 1, 10 do
                self.tri1 = task.SetMode[2](i / 10)
                task.Wait()
            end
        end)
    end
    self.fresh_mouse = function()
        self.tri2 = 0
        task.New(self, function()
            for i = 1, 10 do
                self.tri2 = task.SetMode[2](i / 10)
                task.Wait()
            end
        end)
    end
    self.fresh_list = function()
        self.list = self.weatherdatas[self.list_pos]
        self.pos = 1
        self.tri3 = 0
        self._offy2 = 0
        self.mousepos = nil
        task.New(self, function()
            for i = 1, 10 do
                self.tri3 = task.SetMode[2](i / 10)
                task.Wait()
            end
        end)
    end
end
function CheckWeather_Submenu:refresh()
    ---全部，春，夏，秋，冬，里
    self.weatherdatas = { {}, {}, {}, {}, {}, {} }
    for i, id in ipairs(lstg.weather.total_weather) do
        local p = { wave = i, wea = weather_lib.weather[id] }
        table.insert(self.weatherdatas[1], p)
        table.insert(self.weatherdatas[p.wea.inseason + 1], p)
    end
    if not scoredata.First5Season then
        self.weatherdatas[6] = nil
    end
    self.list_pos = 1
    self.list = self.weatherdatas[self.list_pos]
    self.pos = max(1, #self.list)
    self.mousepos = nil
end
function CheckWeather_Submenu:In()
    PlaySound("select00")
    self.locked = false
    self:refresh()
    task.New(self, function()
        for i = 1, 16 do
            self.alpha = task.SetMode[2](i / 16)
            task.Wait()
        end
    end)
end
function CheckWeather_Submenu:Out()
    task.New(self.mainmenu, function()
        self.mainmenu.CheckWeather_open = false
        for i = 1, 16 do
            self.alpha = 1 - i / 16
            task.Wait()
        end

    end)
end
function CheckWeather_Submenu:frame()
    self.timer = self.timer + 1
    task.Do(self)
    if self.locked then
        return
    end
    local mouse = ext.mouse
    menu:Updatekey()
    self._offy1 = self._offy1 + (-self._offy1 + clamp(self._offy1, 0,
            self.line_h_1 * max(0, self.linecount1 - 14.5))) * 0.3
    self.offy1 = self.offy1 + (-self.offy1 + self._offy1) * 0.3
    self._offy2 = self._offy2 + (-self._offy2 + clamp(self._offy2, 0,
            max(self.line_h_2 * self.linecount2 - self.h, 0))) * 0.3
    self.offy2 = self.offy2 + (-self.offy2 + self._offy2) * 0.3
    local x1, x2, y1, y2
    local w = self.w1
    local h = self.h
    local T = 0.7 + 0.3 * self.alpha
    local x, y = self.x1, self.y
    x1, x2, y1, y2 = x - w / 2 * T, x + w / 2 * T, y - h / 2 * T, y + h / 2 * T
    if sp.math.PointBoundCheck(mouse.x, mouse.y, x1, x2, y1, y2) then
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
            --PlaySound("select00")
        end
    else

        w = self.w2
        h = self.h
        x, y = self.x2, self.y
        x1, x2, y1, y2 = x - w / 2, x + w / 2, y - h / 2, y + h / 2
        if menu:keyLeft() then
            self.pos = sp:TweakValue(self.pos - 1, #self.list, 1)
            self.fresh_show()
            PlaySound("select00")
        end
        if menu:keyRight() then
            self.pos = sp:TweakValue(self.pos + 1, #self.list, 1)
            self.fresh_show()
            PlaySound("select00")
        end
        if menu:keyUp() then
            self.pos = sp:TweakValue(self.pos - self.row, #self.list, 1)
            self.fresh_show()
            PlaySound("select00")
        end
        if menu:keyDown() then
            self.pos = sp:TweakValue(self.pos + self.row, #self.list, 1)
            self.fresh_show()
            PlaySound("select00")
        end
        if mouse.y > y2 then
            if mouse._wheel ~= 0 then
                self.list_pos = sp:TweakValue(self.list_pos - sign(mouse._wheel),
                        #self.weatherdatas, 1)
                self.fresh_list()
                self.fresh_show()
                PlaySound("select00")
            end
            if mouse:isUp(1) then
                for i = 1, #self.weatherdatas do
                    local _w, _h = 45, 20
                    local X, Y = x1 + i * _w * 1.35 + self.bar_offx, y2 + _h
                    if Dist(mouse.x, mouse.y, X, Y) < _w * 0.6 then
                        self.list_pos = i
                        self.fresh_list()
                        self.fresh_show()
                        PlaySound("select00")
                        break
                    end

                end
            end
        else
            if mouse._wheel ~= 0 then
                self._offy2 = self._offy2 - mouse._wheel / 120 * self.line_h_2
            end
            do
                local width = w / self.row
                local line_h = self.line_h_2
                local xi, yi = 1, 0
                while xi + yi * self.row <= #self.list do
                    local kx = x1 + (xi - 1) * width
                    local ky = y2 - yi * line_h
                    local _x1, _x2, _y1, _y2 = kx, kx + width, ky - line_h + self.offy2, ky + self.offy2
                    if sp.math.PointBoundCheck(mouse.x, mouse.y, _x1, _x2, _y1, _y2) then
                        local pos = xi + yi * self.row
                        if self.mousepos ~= pos then
                            self.mousepos = pos
                            --PlaySound("select00")
                            self.fresh_mouse()
                        end
                        if mouse:isUp(1) then
                            self.pos = self.mousepos
                            self.fresh_show()
                            PlaySound("ok00")
                        end
                        break
                    end
                    xi = xi + 1
                    if xi == self.row + 1 then
                        xi = 1
                        yi = yi + 1
                    end
                end
            end
        end
    end
    self.exit_button:frame()
    if menu:keyYes() or menu:keyNo() or menu.key == KEY.Y then
        menu.key = nil
        self.exit_button.func()
    end
end
function CheckWeather_Submenu:render()
    local A = self.alpha
    if A == 0 then
        return
    end
    SetImageState("white", "", A * 180, 0, 0, 0)
    RenderRect("white", 0, 960, 0, 540)
    do

        local x1, x2, y1, y2
        local w = self.w1
        local h = self.h
        local T = 0.7 + 0.3 * A
        local x, y = self.x1, self.y
        x1, x2, y1, y2 = x - w / 2 * T, x + w / 2 * T, y - h / 2 * T, y + h / 2 * T
        self.linecount1 = menu:RenderWeatherDescribe(self.list[self.pos] and self.list[self.pos].wea,
                x1, x2, y1, y2, 50 * T, self.offy1, self.line_h_1, A, A * self.tri1, self.timer, true)
    end--1
    do
        local x1, x2, y1, y2
        local w = self.w2
        local h = self.h
        local T = 0.7 + 0.3 * A
        local x, y = self.x2, self.y
        x1, x2, y1, y2 = x - w / 2 * T, x + w / 2 * T, y - h / 2 * T, y + h / 2 * T
        self.linecount2 = menu:RenderWeatherList(self.list, x1, x2, y1, y2, self.offy2, self.line_h_2, self._dh, self.row,
                A, self.tri1, self.tri2, self.tri3, self.pos, self.mousepos, self.timer, true)
        SetViewMode("ui")
        local k = { "all", "spring", "summer", "autumn", "winter", "inside" }
        if not scoredata.First5Season then
            k[6] = nil
        end
        for i, str in ipairs(k) do
            local index = 1
            if self.list_pos ~= i then
                index = 0.4
            end
            local _w, _h = 45, 15 + index * 5
            local X, Y = x1 + i * _w * 1.35 + self.bar_offx, y2 + _h

            SetImageState("white", "", A * 255,
                    255 * index, 255 * index, 255 * index)
            RenderRect("white", X - _w / 2, X + _w / 2, y2 + 2, Y)
            RenderTTF2("pretty_title", ("%s(%d)"):format(i18n("weather", str), #self.weatherdatas[i]), X, Y - _h * 0.4,
                    0.57 + index * 0.1, Color(255, 0, 0, 0), "centerpoint")
        end
    end--2
    self.exit_button:render(A)
end

function CheckActive:init(mainmenu, submenu, x, y)
    self.x, self.y = x, y

    self.func = function()
        self.mainmenu.CheckActive_open = true
        self.submenu:In(activeItem_lib.ActiveTotalList[lstg.var.active_item[1]])
    end
    self.index = 0
    self.timer = 0
    self.r = 48
    self.selected = false
    self.locked = false
    self.mainmenu = mainmenu
    self.submenu = submenu
end
function CheckActive:frame()
    if lstg.var.active_item[1] then
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
        if menu.key == KEY.A then
            self.index = self.index + 0.5
            PlaySound("ok00")
            self.func()
        end
    end
end
function CheckActive:render(A)
    if lstg.var.active_item[1] then
        local k = self.index
        local _alpha = (150 + k * 50) * A
        local ax, ay = self.x, self.y
        local adsize = self.r + k * 10
        local ActiveID = lstg.var.active_item[1]
        local Active = activeItem_lib.ActiveTotalList[ActiveID]
        SetImageState("menu_circle", "", _alpha, 200, 200, 200)
        Render("menu_circle", ax, ay, 0, adsize / 192)
        local pic = Active.pic
        SetImageState(pic, "mul+add", _alpha, 200, 200, 200)
        Render(pic, ax, ay, 0, adsize / 192)
        ui:RenderText("pretty_title", ("%s\n(%s)"):format(_t("checkActive"), "a"), ax, ay - adsize / 2,
                0.72, Color(_alpha, 255, 255, 255), "centerpoint")
    end
end

function CheckActive_Submenu:init(mainmenu)
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
function CheckActive_Submenu:In(active)
    self.english = setting.language == 2
    self.w = self.english and 480 or 420
    PlaySound("select00")
    self.locked = false
    self.active = active
    self._offy1 = 0
    task.New(self, function()
        for i = 1, 16 do
            self.alpha = task.SetMode[2](i / 16)
            task.Wait()
        end
    end)

end
function CheckActive_Submenu:Out()
    task.New(self.mainmenu, function()
        task.Wait()
        self.mainmenu.CheckActive_open = false
        for i = 1, 16 do
            self.alpha = 1 - i / 16
            task.Wait()
        end
    end)
end
function CheckActive_Submenu:frame()
    self.timer = self.timer + 1
    task.Do(self)
    if self.locked then
        return
    end
    menu:Updatekey()
    local mouse = ext.mouse

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
    self.exit_button:frame()
    if menu:keyYes() or menu:keyNo() or menu.key == KEY.A or mouse:isUp(1) then
        self.exit_button.func()
    end
end
function CheckActive_Submenu:render()
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
        self.linecount1 = menu:RenderActiveDescribe(self.active, x1, x2, y1, y2, 80 * T, self.offy1, self.line_h_1, A, A, self.timer, true)
    end
    self.exit_button:render(A)
end

---@class ext.pausemenu @暂停菜单对象
ext.pause_menu = pausemenu
ext.pause_menu:init()

ext.CheckAddition = CheckAddition
ext.CheckAddition_Submenu = CheckAddition_Submenu

ext.CheckWeather = CheckWeather
ext.CheckWeather_Submenu = CheckWeather_Submenu

ext.CheckActive = CheckActive
ext.CheckActive_Submenu = CheckActive_Submenu

ext.SimpleChoose = plus.Class()
function ext.SimpleChoose:init(cur_menu, yes, no, title, text, w, h)
    self.bound = false
    self.colli = false
    object.init(self, screen.width / 2, screen.height * 1.5, GROUP.GHOST, LAYER.TOP)
    self.cur_menu = cur_menu
    self.cur_menu.choosemenu = self
    self.title = title
    self.text = text
    self.lock = true
    self.width = w or 350
    self.height = h or 160
    self.pheight = 50
    self.pos = 1
    self.yes_func = yes
    self.no_func = no
    self.y = 270
    self.alpha = 0
    task.New(self, function()
        task.SmoothSetValueTo("alpha", 1, 9, 2)
        self.lock = false
    end)
    self.ty = 0
    self._ty = 0
    self.texts = sp:SplitText(text, "\n")
    self.lines = #self.texts
end
function ext.SimpleChoose:frame()
    task.Do(self)
    if not self.dk then
        if not self.lock then
            local line_h = 32 * 0.8 * 0.61
            local x = self.x
            local y = self.y
            local w = self.width
            local h = self.height
            local ph = self.pheight
            self._ty = self._ty + (-self._ty + clamp(self._ty, 0, max(line_h * self.lines - h * 2, 0))) * 0.3
            self.ty = self.ty + (-self.ty + self._ty) * 0.3
            menu:Updatekey()
            if menu:keyYes() then
                if self.pos == 1 then
                    self:del()
                    self.yes_func()
                    PlaySound("ok00")
                else
                    self:del()
                    self.no_func()
                    PlaySound("cancel00")
                end
            end
            if menu:keyNo() then
                self:del()
                self.no_func()

                PlaySound("cancel00")
            end
            if menu:keyDown() then
                self._ty = self._ty + line_h * 4
                PlaySound("select00")
            end
            if menu:keyUp() then
                self._ty = self._ty - line_h * 4
                PlaySound("select00")
            end
            if menu:keyLeft() or menu:keyRight() then
                self.pos = self.pos % 2 + 1
                PlaySound("select00")
            end
            local mouse = ext.mouse
            if sp.math.PointBoundCheck(mouse.x, mouse.y, x - w, x, y - h, y - h - ph) then
                if mouse:isUp(1) then
                    self:del()
                    self.pos = 1
                    self.yes_func()

                    PlaySound("ok00")
                end
            end
            if sp.math.PointBoundCheck(mouse.x, mouse.y, x + w, x, y - h, y - h - ph) then
                if mouse:isUp(1) then
                    self:del()
                    self.pos = 2
                    self.no_func()

                    PlaySound("cancel00")
                end
            end
            if mouse._wheel ~= 0 then
                self._ty = self._ty - sign(mouse._wheel) * line_h * 4
                PlaySound("select00")
            end
        end
    end

end
function ext.SimpleChoose:render()
    SetViewMode("ui")
    local scrh = screen.height
    local line_h = 32 * 0.8 * 0.61
    local x = self.x
    local y = self.y
    local alpha = self.alpha
    local w = self.width * (0.6 + 0.4 * alpha)
    local h = self.height * (0.6 + 0.4 * alpha)
    local ph = self.pheight

    SetImageState("white", "", alpha * 150, 0, 0, 0)
    RenderRect("white", 0, screen.width, 0, scrh)
    SetImageState("white", "", alpha * 150, 70, 40, 40)
    RenderRect("white", x - w, x + w, y + h, y + h + ph)
    SetImageState("white", "", alpha * 150, 20, 20, 20)
    RenderRect("white", x - w, x + w, y + h, y - h)
    SetImageState("white", "", alpha * 150, 20, (self.pos == 1) and 150 or 30, 30)
    RenderRect("white", x - w, x, y - h, y - h - ph)
    SetImageState("white", "", alpha * 150, 20, (self.pos == 2) and 150 or 30, 30)
    RenderRect("white", x + w, x, y - h, y - h - ph)

    SetImageState("white", "", alpha * 255, 255, 255, 255)
    RenderRect("white", x - 1, x + 1, y - h, y - h - ph)
    misc.RenderOutLine("white", x - w, x + w, y - h - ph, y + h + ph, 0, 2)
    RenderRect("white", x - w, x + w, y - h, y - h - 2)
    RenderRect("white", x - w, x + w, y + h, y + h + 2)
    ui:RenderText("big_text", self.title, x, y + h + ph / 2,
            0.7, Color(alpha * 255, 255, 255, 255), "centerpoint")
    ui:RenderText("big_text", i18n("sth", "yes"), x - w / 2, y - h - ph / 2,
            0.7, Color(alpha * 255, 255, 255, 255), "centerpoint")
    ui:RenderText("big_text", i18n("sth", "no"), x + w / 2, y - h - ph / 2,
            0.7, Color(alpha * 255, 255, 255, 255), "centerpoint")
    local ty = clamp(y + h, 0, scrh)
    local by = clamp(y - h, 0, scrh)
    if (-w) ~= w and (by - y) ~= (ty - y) and (x - w) ~= (x + w) and by ~= ty then
        SetRenderRect(-w, w, by - y, ty - y, x - w, x + w, by, ty)
        local Y = self.ty + h
        for _, str in ipairs(self.texts) do
            if Y > -h - line_h and Y < h + line_h then
                ui:RenderText("title", str, -w + 10, Y, 0.8, Color(alpha * 255, 255, 255, 255), "left", "top")
            end
            Y = Y - line_h
        end
    end
    SetViewMode("ui")
end
function ext.SimpleChoose:del()
    self.dk = true

    task.New(self, function()
        task.SmoothSetValueTo("alpha", 0, 9, 1)
        self.cur_menu.choosemenu = nil
    end)
end

