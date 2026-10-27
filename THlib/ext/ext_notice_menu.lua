local notice_menu = {}
function notice_menu:init()
    self.list = {}
    self.timer = 0
end
function notice_menu:frame()
    task.Do(self)
    self.timer = self.timer + 1
    if self.list[1] then
        task.Do(self.list[1])
        if coroutine.status(self.list[1].task[1]) == 'dead' then
            table.remove(self.list, 1)
        end
    end
end
function notice_menu:render()
    SetViewMode("ui")
    if self.list[1] then
        local k = self.list[1]
        local x1, x2, y1, y2 = 960 - k.index * 150, 960 - k.index * 10, 300 - 79, 300 + 79
        local _a = k.alpha1
        local px, py = (x1 + x2) / 2, y2 - 67
        local size = 45
        local R, G, B = k.R, k.G, k.B
        local img = k.pic
        local t = self.timer
        SetImageState("white", "", 150 * k.alpha2, 0, 0, 0)

        RenderRect("white", x1, x2, y1, y2)
        SetImageState("white", "", 180 * k.alpha2, 255, 255, 255)
        misc.RenderOutLine("white", x1, x2, y2, y1, 0, 2)

        SetImageState("menu_circle", "", _a * 200, 200, 200, 200)
        Render("menu_circle", px, py, 0, size / 192)
        SetImageState("menu_pure_circle", "mul+add", _a * 75, R, G, B)
        Render("menu_pure_circle", px, py, 0, (size - 1) / 125)
        SetImageState(img, "", _a * 200, 200, 200, 200)
        Render(img, px, py, 0, size / 200)
        ui:RenderText("pretty_title", ReplaceTextWithCommand(k.describe):gsub("§.", ""), x1 + 1, y2,
                0.8, Color(_a * ((t % 40 < 20) and 180 or 0), k.tR, k.tG, k.tB), "left", "top")
        misc.RenderBrightOutline(x1, x2, y1, y2, 12, _a * (75 + sin(t * 4) * 25), R, G, B)
        ui:RenderTextInWidth("title", k.title, px, py - 60, 0.7, (x2 - x1) * 0.9, Color(_a * 200, R, G, B), "centerpoint")

    end
    SetViewMode("world")
end
function notice_menu:Add(pic, title, R, G, B, sound, describe, time, tR, tG, tB)
    local k = { index = 0, pic = pic or "white", title = title or "", tR = tR or 120, tG = tG or 210, tB = tB or 120,
                R = R or 0, G = G or 0, B = B or 0, alpha2 = 1, alpha1 = 0, task = {}, describe = describe or "Get!!" }
    table.insert(self.list, k)
    PlaySound(sound or "bonus")
    task.New(k, function()
        for i = 1, 30 do
            i = task.SetMode[2](i / 30)
            k.index = i
            task.Wait()
        end
        for i = 1, 20 do
            i = task.SetMode[2](i / 20)
            k.alpha1 = i
            task.Wait()
        end
        task.Wait(time or 120)
        for i = 1, 90 do
            i = task.SetMode[1](i / 90)
            k.alpha2 = 1 - i
            k.alpha1 = 1 - i
            task.Wait()
        end
    end)
end

function notice_menu:AdditionAdd(toolid, sound, describe, time, tR, tG, tB)
    local p = stg_levelUPlib.AdditionTotalList[toolid]
    self:Add(p.pic, p.title, p.R, p.G, p.B, sound, describe, time, tR, tG, tB)
end
function notice_menu:Clear()
    self.list = {}
end

ext.notice_menu = notice_menu
ext.notice_menu:init()