local function _t(str)
    return i18n("sth", str) or ""
end

local HandBookSubmenu = {}
local handbook_1 = {}
HandBookSubmenu[1] = handbook_1
function handbook_1:init(menu)
    self.x, self.y = 480, 270
    self.w1, self.w2 = 520, 360
    self.h = 420
    --1在右边，2在左边，即详述在右边，列表在左边
    self.x1 = (960 - self.w1 - self.w2) / 2 + self.w2 + self.w1 / 2
    self.x2 = (960 - self.w1 - self.w2) / 2 + self.w2 / 2
    self.row = 4
    self.alpha = 0
    self.offy1 = 0
    self._offy1 = 0
    self.line_h_1 = 40
    self.linecount1 = 1
    self.offy2 = 0
    self._offy2 = 0
    self._dh = 18
    self.line_h_2 = self.w2 / self.row * 0.5625 + self._dh
    self.linecount2 = 1
    self.bar_offx = -32
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
        self.list = self.wavedatas[self.list_pos]
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
    self.alpha = 0
    self.locked = true
    self.timer = 0
    self.mainmenu = menu
    self.select_bar = {}
    self.start_func = function()
        task.New(self, function()
            local p = self.list[self.pos]
            self.locked = true
            mask_fader:Do("close")
            task.Wait(15)
            stage.Set("none", "attr_select3")
            lstg.var.practice_inscene = p.inscene
            lstg.var.practice_id = p.id
            lstg.var.practice_mode = "wave"
        end)
    end
end
function handbook_1:refresh()
    self.select_bar = { "all" }
    self.wavedatas = { {} }
    for i, p in ipairs(SceneClass) do
        table.insert(self.select_bar, "scene" .. i)
        table.insert(self.wavedatas, {})
        for _, wave in ipairs(p.events) do
            table.insert(self.wavedatas[1], wave)
        end
    end
    table.sort(self.wavedatas[1], function(a, b)
        local p1boss = a.isboss and 1 or 0
        local p2boss = b.isboss and 1 or 0
        local p1hard = a.isdangerous and 1 or 0
        local p2hard = b.isdangerous and 1 or 0
        local p1luck = a.islucky and 1 or 0
        local p2luck = b.islucky and 1 or 0
        local p1unlock = stagedata.BookWave[a.inscene][a.id] and 1 or 0
        local p2unlock = stagedata.BookWave[b.inscene][b.id] and 1 or 0
        local p1node = a.isNode and 1 or 0
        local p2node = b.isNode and 1 or 0
        local stateMap = { 3, 2, 1, 4, 5, 6 }
        if p1unlock == p2unlock then
            if a.inscene == b.inscene then
                if p1node == p2node then
                    if p1node == 0 then
                        if p1boss == p2boss then
                            if p1hard == p2hard then
                                if p1luck == p2luck then

                                    return a.id < b.id

                                else
                                    return p1luck > p2luck
                                end
                            else
                                return p1hard > p2hard
                            end
                        else
                            return p1boss > p2boss
                        end
                    else
                        return stateMap[a.state] < stateMap[b.state]
                    end
                else
                    return p1node < p2node

                end
            else
                return a.inscene < b.inscene
            end
        else
            return p1unlock > p2unlock
        end
    end)
    for _, u in ipairs(self.wavedatas[1]) do
        table.insert(self.wavedatas[u.inscene + 1], u)
    end
    self.list_pos = self.list_pos or 1
    self.list = self.wavedatas[self.list_pos]
    self.pos = max(1, self.pos or 1)
    self.mousepos = nil
end
function handbook_1:In()
    PlaySound("select00")
    self:refresh()
    task.New(self.mainmenu, function()
        for i = 1, 16 do
            self.alpha = task.SetMode[2](i / 16)
            task.Wait()
        end
    end)

end
function handbook_1:Out()
    task.New(self.mainmenu, function()
        for i = 1, 16 do
            self.alpha = 1 - i / 16
            task.Wait()
        end

    end)
end
function handbook_1:frame()
    self.timer = self.timer + 1
    task.Do(self)
    local mouse = ext.mouse
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
    local kh = (x2 - x1) / 2 * 0.5625
    local p = self.list[self.pos]
    local unlock = stagedata.BookWave[p.inscene][p.id]
    if sp.math.PointBoundCheck(mouse.x, mouse.y, x1, x2, y2 - kh * 2, y2) then
        local pic = ("WavePic_%d_%d"):format(p.inscene, p.id)
        local path = GetDataPath() .. "/wave_pic/"
        if CheckRes("img", pic) and mouse:isUp(1) then
            New(SimpleChoose, self.mainmenu, function()
                PlaySound("heal")
                os.remove(("%s%s.png"):format(path, pic))
                RemoveResource("stage", 1, pic)
                RemoveResource("stage", 2, pic)
            end, load(""), "Warning", "是否要重制取景", 150, 60)
        end
    elseif sp.math.PointBoundCheck(mouse.x, mouse.y, x1, x2, y1, y2 - kh * 2) then
        if unlock and mouse:isUp(1) then
            self.start_func()
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
                        #self.wavedatas, 1)
                self.fresh_list()
                self.fresh_show()
                PlaySound("select00")
            end
            if mouse:isUp(1) then
                for i = 1, #self.select_bar do
                    local _w, _h = 60, 20
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
                local width = self.w2 / self.row
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
    if unlock and menu:keyYes() then
        PlaySound("ok00")
        self.start_func()
    end
end
function handbook_1:render()
    local A = self.alpha
    if A == 0 then
        return
    end
    do

        local x1, x2, y1, y2
        local w = self.w1
        local h = self.h
        local T = 0.7 + 0.3 * A
        local x, y = self.x1, self.y
        x1, x2, y1, y2 = x - w / 2 * T, x + w / 2 * T, y - h / 2 * T, y + h / 2 * T
        self.linecount1 = menu:RenderWaveDescribe(self.list[self.pos], x1, x2, y1, y2,
                80 * T, self.offy1, self.line_h_1, A, A * self.tri1, self.timer)
    end--1
    do
        local x1, x2, y1, y2
        local w = self.w2
        local h = self.h
        local T = 0.7 + 0.3 * A
        local x, y = self.x2, self.y
        x1, x2, y1, y2 = x - w / 2 * T, x + w / 2 * T, y - h / 2 * T, y + h / 2 * T
        self.linecount2 = menu:RenderWaveList(self.list, x1, x2, y1, y2, self.offy2, self.line_h_2, self._dh, self.row,
                A, self.tri1, self.tri2, self.tri3, self.pos, self.mousepos, self.timer)
        SetViewMode("ui")
        for i, str in ipairs(self.select_bar) do
            local index = 1
            if self.list_pos ~= i then
                index = 0.4
            end
            local _w, _h = 60, 15 + index * 5
            local X, Y = x1 + i * _w * 1.35 + self.bar_offx, y2 + _h

            SetImageState("white", "", A * 255,
                    255 * index, 255 * index, 255 * index)
            RenderRect("white", X - _w / 2, X + _w / 2, y2 + 2, Y)
            RenderTTF2("pretty_title", ("%s(%d)"):format(_t(str), #self.wavedatas[i]), X, Y - _h * 0.4,
                    0.57 + index * 0.1, Color(255, 0, 0, 0), "centerpoint")
        end
    end--2
end

local handbook_2 = {}
HandBookSubmenu[2] = handbook_2
function handbook_2:init(menu)
    self.english = setting.language == 2
    self.x, self.y = 480, 270
    self.w1, self.w2 = self.english and 480 or 420, self.english and 400 or 460
    self.h = 420
    --1在右边，2在左边，即详述在右边，列表在左边
    self.x1 = (960 - self.w1 - self.w2) / 2 + self.w2 + self.w1 / 2
    self.x2 = (960 - self.w1 - self.w2) / 2 + self.w2 / 2
    self.row = self.english and 5 or 6
    self.alpha = 0
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
    self.alpha = 0
    self.locked = true
    self.timer = 0
    self.mainmenu = menu
end
function handbook_2:refresh()
    local tool_list = stg_levelUPlib.AdditionTotalList
    ---全部，4级，3级，2级，1级，0级，其他
    self.tooldatas = { {}, {}, {}, {}, {}, {}, {} }
    for i in pairs(stg_levelUPlib.AdditionTotalList) do
        table.insert(self.tooldatas[1], tool_list[i])
    end
    table.sort(self.tooldatas[1], function(a, b)
        local p1tool = a.isTool and 1 or 0
        local p2tool = b.isTool and 1 or 0
        local p1unlock = scoredata.BookAddition[a.id] and 1 or 0
        local p2unlock = scoredata.BookAddition[b.id] and 1 or 0
        if p1unlock == p2unlock then
            if p1tool == p2tool then
                if p1tool == 1 then
                    if a.quality == b.quality then
                        return CompareID(a.id, b.id)
                    else
                        return a.quality > b.quality
                    end
                else
                    if a.state == b.state then
                        return a.id > b.id
                    else
                        return a.state < b.state

                    end
                end
            else
                return p1tool > p2tool

            end
        else
            return p1unlock > p2unlock
        end
    end)
    for _, u in ipairs(self.tooldatas[1]) do
        if u.isTool then
            table.insert(self.tooldatas[6 - u.quality], u)
        else
            table.insert(self.tooldatas[7], u)
        end
    end
    self.list_pos = self.list_pos or 1
    self.list = self.tooldatas[self.list_pos]
    self.pos = max(1, self.pos or 1)
    self.mousepos = nil
end
function handbook_2:In()
    PlaySound("select00")
    self:refresh()
    task.New(self.mainmenu, function()
        for i = 1, 16 do
            self.alpha = task.SetMode[2](i / 16)
            task.Wait()
        end
    end)

end
function handbook_2:Out()
    task.New(self.mainmenu, function()
        for i = 1, 16 do
            self.alpha = 1 - i / 16
            task.Wait()
        end

    end)
end
function handbook_2:frame()
    self.timer = self.timer + 1
    task.Do(self)
    local mouse = ext.mouse
    self._offy1 = self._offy1 + (-self._offy1 + clamp(self._offy1, 0, self.line_h_1 * max(0, self.linecount1 - 14.5))) * 0.3
    self.offy1 = self.offy1 + (-self.offy1 + self._offy1) * 0.3
    self._offy2 = self._offy2 + (-self._offy2 + clamp(self._offy2, 0, max(self.line_h_2 * self.linecount2 - self.h, 0))) * 0.3
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
end
function handbook_2:render()
    local A = self.alpha
    if A == 0 then
        return
    end
    do

        local x1, x2, y1, y2
        local w = self.w1
        local h = self.h
        local T = 0.7 + 0.3 * A
        local x, y = self.x1, self.y
        x1, x2, y1, y2 = x - w / 2 * T, x + w / 2 * T, y - h / 2 * T, y + h / 2 * T
        self.linecount1 = menu:RenderToolDescribe(self.list[self.pos], x1, x2, y1, y2,
                80 * T, self.offy1, self.line_h_1, A, A * self.tri1, self.timer)
    end--1
    do
        local x1, x2, y1, y2
        local w = self.w2
        local h = self.h
        local T = 0.7 + 0.3 * A
        local x, y = self.x2, self.y
        x1, x2, y1, y2 = x - w / 2 * T, x + w / 2 * T, y - h / 2 * T, y + h / 2 * T
        self.linecount2 = menu:RenderToolList(self.list, x1, x2, y1, y2, self.offy2, self.line_h_2, self._dh, self.row,
                A, self.tri1, self.tri2, self.tri3, self.pos, self.mousepos, self.timer)
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
            RenderTTF2("pretty_title", ("%s(%d)"):format(str, #self.tooldatas[i]), X, Y - _h * 0.4,
                    0.57 + index * 0.1, Color(255, 0, 0, 0), "centerpoint")
        end
    end--2
end

local handbook_3 = {}
HandBookSubmenu[3] = handbook_3
function handbook_3:init(mainmenu)
    self.english = setting.language == 2
    self.x, self.y = 480, 270
    self.w1, self.w2 = self.english and 500 or 350, 360
    self.h = 400
    --1在右边，2在左边，即详述在右边，列表在左边
    self.x1 = (960 - self.w1 - self.w2) / 2 + self.w2 + self.w1 / 2
    self.x2 = (960 - self.w1 - self.w2) / 2 + self.w2 / 2
    self.row = self.english and 4 or 5
    self.alpha = 0
    self.timer = 0
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
    self.start_func = function()
        task.New(self, function()
            local p = self.list[self.pos]
            self.locked = true
            mask_fader:Do("close")
            task.Wait(15)
            stage.Set("none", "attr_select3")
            -- lstg.var.practice_inscene = p.inscene
            --lstg.var.practice_id = p.id

            lstg.var.practice_weather = p.wea.id
            lstg.var.practice_mode = "weather"
        end)
    end
end
function handbook_3:refresh()
    ---全部，春，夏，秋，冬，里
    self.weatherdatas = { {}, {}, {}, {}, {}, {} }
    local _cache = {}
    for _, wea in ipairs(weather_lib.weather) do
        if scoredata.First5Season or wea.inseason ~= 5 then
            table.insert(_cache, wea)
        end
    end
    table.sort(_cache, function(a, b)
        local p1unlock = scoredata.Weather[a.id] and 1 or 0
        local p2unlock = scoredata.Weather[b.id] and 1 or 0
        if p1unlock == p2unlock then
            if a.state == b.state then
                if a.inseason == b.inseason then
                    return a.id < b.id
                else
                    return a.inseason < b.inseason
                end
            else
                return a.state < b.state
            end
        else
            return p1unlock > p2unlock
        end
    end)
    for _, wea in ipairs(_cache) do
        local p = { wea = wea }
        table.insert(self.weatherdatas[1], p)
        table.insert(self.weatherdatas[p.wea.inseason + 1], p)
    end
    if not scoredata.First5Season then
        self.weatherdatas[6] = nil
    end
    self.list_pos = self.list_pos or 1
    self.list = self.weatherdatas[self.list_pos]
    self.pos = max(1, self.pos or 1)
    self.mousepos = nil
end
function handbook_3:In()
    PlaySound("select00")
    self:refresh()
    task.New(self.mainmenu, function()
        for i = 1, 16 do
            self.alpha = task.SetMode[2](i / 16)
            task.Wait()
        end
    end)
end
function handbook_3:Out()
    task.New(self.mainmenu, function()
        for i = 1, 16 do
            self.alpha = 1 - i / 16
            task.Wait()
        end

    end)
end
function handbook_3:frame()
    self.timer = self.timer + 1
    task.Do(self)
    local mouse = ext.mouse
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
    local unlock = scoredata.Weather[self.list[self.pos].wea.id]
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
            PlaySound("select00")
        end
        if unlock and mouse:isUp(1) then
            PlaySound("ok00")
            self.start_func()
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
                --PlaySound("select00")
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
    if unlock and menu:keyYes() then
        PlaySound("ok00")
        self.start_func()
    end
end
function handbook_3:render()
    local A = self.alpha
    if A == 0 then
        return
    end
    do

        local x1, x2, y1, y2
        local w = self.w1
        local h = self.h
        local T = 0.7 + 0.3 * A
        local x, y = self.x1, self.y
        x1, x2, y1, y2 = x - w / 2 * T, x + w / 2 * T, y - h / 2 * T, y + h / 2 * T
        self.linecount1 = menu:RenderWeatherDescribe(self.list[self.pos] and self.list[self.pos].wea,
                x1, x2, y1, y2, 50 * T, self.offy1, self.line_h_1, A, A * self.tri1, self.timer)
    end--1
    do
        local x1, x2, y1, y2
        local w = self.w2
        local h = self.h
        local _T = 0.7 + 0.3 * A
        local x, y = self.x2, self.y
        x1, x2, y1, y2 = x - w / 2 * _T, x + w / 2 * _T, y - h / 2 * _T, y + h / 2 * _T
        self.linecount2 = menu:RenderWeatherList(self.list, x1, x2, y1, y2, self.offy2, self.line_h_2, self._dh, self.row,
                A, self.tri1, self.tri2, self.tri3, self.pos, self.mousepos, self.timer)
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
end

local handbook_4 = {}
HandBookSubmenu[4] = handbook_4
function handbook_4:init(menu)
    self.english = setting.language == 2
    self.x, self.y = 480, 270
    self.w1, self.w2 = self.english and 480 or 420, self.english and 400 or 460
    self.h = 420
    --1在右边，2在左边，即详述在右边，列表在左边
    self.x1 = (960 - self.w1 - self.w2) / 2 + self.w2 + self.w1 / 2
    self.x2 = (960 - self.w1 - self.w2) / 2 + self.w2 / 2
    self.row = self.english and 5 or 6
    self.alpha = 0
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
    self.alpha = 0
    self.locked = true
    self.timer = 0
    self.mainmenu = menu
end
function handbook_4:refresh()
    ---全部，4级，3级，2级，1级，0级
    self.tooldatas = { {}, {}, {}, {}, {}, {} }
    for i, a in pairs(activeItem_lib.ActiveTotalList) do
        table.insert(self.tooldatas[1], a)
    end
    table.sort(self.tooldatas[1], function(a, b)
        local p1unlock = scoredata.BookActive[a.id] and 1 or 0
        local p2unlock = scoredata.BookActive[b.id] and 1 or 0
        if p1unlock == p2unlock then
            if a.quality == b.quality then
                return a.id > b.id
            else
                return a.quality > b.quality
            end
        else
            return p1unlock > p2unlock
        end
    end)
    for _, u in ipairs(self.tooldatas[1]) do
        table.insert(self.tooldatas[6 - u.quality], u)
    end
    self.list_pos = self.list_pos or 1
    self.list = self.tooldatas[self.list_pos]
    self.pos = max(1, self.pos or 1)
    self.mousepos = nil
end
function handbook_4:In()
    PlaySound("select00")
    self:refresh()
    task.New(self.mainmenu, function()
        for i = 1, 16 do
            self.alpha = task.SetMode[2](i / 16)
            task.Wait()
        end
    end)

end
function handbook_4:Out()
    task.New(self.mainmenu, function()
        for i = 1, 16 do
            self.alpha = 1 - i / 16
            task.Wait()
        end

    end)
end
function handbook_4:frame()
    self.timer = self.timer + 1
    task.Do(self)
    local mouse = ext.mouse
    self._offy1 = self._offy1 + (-self._offy1 + clamp(self._offy1, 0, self.line_h_1 * max(0, self.linecount1 - 14.5))) * 0.3
    self.offy1 = self.offy1 + (-self.offy1 + self._offy1) * 0.3
    self._offy2 = self._offy2 + (-self._offy2 + clamp(self._offy2, 0, max(self.line_h_2 * self.linecount2 - self.h, 0))) * 0.3
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
            PlaySound("select00")
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
                --PlaySound("select00")
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
end
function handbook_4:render()
    local A = self.alpha
    if A == 0 then
        return
    end
    do

        local x1, x2, y1, y2
        local w = self.w1
        local h = self.h
        local T = 0.7 + 0.3 * A
        local x, y = self.x1, self.y
        x1, x2, y1, y2 = x - w / 2 * T, x + w / 2 * T, y - h / 2 * T, y + h / 2 * T
        self.linecount1 = menu:RenderActiveDescribe(self.list[self.pos], x1, x2, y1, y2,
                80 * T, self.offy1, self.line_h_1, A, A * self.tri1, self.timer)
    end--1
    do
        local x1, x2, y1, y2
        local w = self.w2
        local h = self.h
        local T = 0.7 + 0.3 * A
        local x, y = self.x2, self.y
        x1, x2, y1, y2 = x - w / 2 * T, x + w / 2 * T, y - h / 2 * T, y + h / 2 * T
        self.linecount2 = menu:RenderActiveList(self.list, x1, x2, y1, y2, self.offy2, self.line_h_2, self._dh, self.row,
                A, self.tri1, self.tri2, self.tri3, self.pos, self.mousepos, self.timer)
        SetViewMode("ui")
        for i, str in ipairs({ _t("all"), _t("4Q"), _t("3Q"), _t("2Q"), _t("1Q"), _t("0Q") }) do
            local index = 1
            if self.list_pos ~= i then
                index = 0.4
            end
            local _w, _h = 45, 15 + index * 5
            local X, Y = x1 + i * _w * 1.35 + self.bar_offx, y2 + _h

            SetImageState("white", "", A * 255,
                    255 * index, 255 * index, 255 * index)
            RenderRect("white", X - _w / 2, X + _w / 2, y2 + 2, Y)
            RenderTTF2("pretty_title", ("%s(%d)"):format(str, #self.tooldatas[i]), X, Y - _h * 0.4,
                    0.57 + index * 0.1, Color(255, 0, 0, 0), "centerpoint")
        end
    end--2
end

local function HideUnitInList(list, condition, id)
    for i = #list, 1, -1 do
        if condition and id == list[i].id then
            table.remove(list, i)
            break
        end
    end
end

local Text = TIP
local time = 1 / 60
local clock = os.clock
handbook_menu = stage.New("handbook", false, true)
function handbook_menu:init()

    mask_fader:Do("open")
    self.top_bar = top_bar_Class(self, _t("handbook"))
    self.exit_func = function()
        if self.state == 1 then
            task.New(self, function()
                self.locked = true
                mask_fader:Do("close")
                task.Wait(15)
                stage.Set("none", lastmenu.stage_name)
            end)
        else
            self.state = 1
            local unit = HandBookSubmenu[self.big_pos]
            unit:Out()
            task.New(self, function()
                for i = 1, 15 do
                    self._alpha = i / 15
                    task.Wait()
                end
            end)
        end
    end
    self.choose_func = function()
        PlaySound("ok00")
        if self.state == 1 then
            self.state = 2
            task.New(self, function()
                for i = 1, 15 do
                    self._alpha = 1 - i / 15
                    task.Wait()
                end
            end)
            local unit = HandBookSubmenu[self.selection[self.big_pos].id]
            unit:init(self)
            unit:In()
        end
    end
    self.top_bar:addReturnButton(function()
        self.exit_func()
    end)
    self.selection = {
        { name = _t("waveOverview"),
          pic = "menu_wave_handbook",
          id = 1,
          index = 0 },
        { name = _t("itemOverview"),
          pic = "menu_check_addition",
          id = 2,
          index = 0 },
        { name = _t("wxOverview"),
          pic = "season_icon_full_1",
          id = 3,
          index = 0 },
        { name = _t("activeOverview"),
          pic = "menu_active_handbook",
          id = 4,
          index = 0 },
    }
    --HideUnitInList(self.selection, not scoredata.FirstWeather, 3)
    --HideUnitInList(self.selection, not scoredata.FirstActive, 4)
    self.ox = 0
    self.intervalx = 220
    self.selection_c = #self.selection
    self.big_pos = 1
    self._alpha = 1
    self.alpha = 0
    self.state = 1
    self.x, self.y = 480, 270
    HandBookSubmenu[self.big_pos]:init(self)
    task.New(self, function()
        task.Wait(30)
        while GetKeyState(KEY.Z) do
            task.Wait()
        end
        self.locked = false
    end)

    local loads = {}
    local path = GetDataPath()
    local searchPath = path .. "/wave_pic/"
    for _, v in ipairs(lstg.FileManager.EnumFiles(searchPath, "png")) do

        table.insert(loads, function()
            local path = v[1]
            local name = path:sub(searchPath:len() + 1, -5)
            if name:sub(1, 1) == "W" then
                LoadImageFromFile(name, path, true)
            end
        end)
    end
    if #loads <= 5 then
        for _, f in ipairs(loads) do
            f()
        end
        if self.goto_pos then
            self.big_pos = self.goto_pos
            self.choose_func()
            self.goto_pos = nil
        end
    else
        self.jump = false
        self.loading = true
        self.start_time = clock()
        self.res = loads
        self.index = 1
        self.maxindex = #self.res
        self.textindex = math.random(1, #Text)
        self.text = Text[self.textindex]
        self.settime = self.timer
        self.load_alpha = 1
        self._alpha = 0
        task.New(self, function()
            while not self.jump do
                task.Wait()
            end
            if self.goto_pos then
                self.big_pos = self.goto_pos
                self.choose_func()
                self.goto_pos = nil
            end
            for i = 1, 15 do
                self._alpha = i / 15
                self.load_alpha = 1 - i / 15
                task.Wait()
            end
            self.loading = false
        end)
    end

end
function handbook_menu:frame()
    if self.loading then
        self.timer = int((clock() - self.start_time) * 60)
        if self.timer - self.settime > 150 then
            local t = self.textindex
            while self.textindex == t do
                self.textindex = math.random(1, #Text)
            end
            self.text = Text[self.textindex]
            self.settime = self.timer
        end
        if self.index > self.maxindex then
            self.jump = true
        elseif not self.jump then
            local resFunc
            local start_time, end_time = clock(), clock()
            while end_time - start_time <= time do
                if self.index > self.maxindex then
                    break
                end
                resFunc = self.res[self.index]
                if resFunc then
                    resFunc()
                end
                self.index = self.index + 1
                end_time = clock()
            end
        end
    else
        self.timer = self.timer + 1
        self.ox = self.ox - self.ox * 0.07
        if self.locked then
            return
        end
        local mouse = ext.mouse
        menu:Updatekey()
        self.top_bar:frame()
        if self.state == 1 then
            local function SetPos(pos)
                local t = self.big_pos
                self.big_pos = sp:TweakValue(pos, self.selection_c, 1)
                self.ox = self.ox + (self.big_pos - t) * self.intervalx
                local unit = HandBookSubmenu[self.selection[self.big_pos].id]
                unit:init(self)
                PlaySound('select00', 0.3)

            end
            if mouse._wheel ~= 0 then
                SetPos(self.big_pos - sign(mouse._wheel))
                PlaySound('select00', 0.3)
            end
            if menu:keyLeft() then
                SetPos(self.big_pos - 1)
            end
            if menu:keyRight() then
                SetPos(self.big_pos + 1)
            end
            local Pos = self.big_pos
            for i, u in ipairs(self.selection) do
                local x = self.x + self.ox + (i - Pos) * self.intervalx
                if mouse:isUp(1) then
                    if Dist(mouse.x, mouse.y, x, self.y) < (70 + 50 * u.index) then
                        if i == Pos then
                            self.choose_func()
                        else
                            SetPos(i)
                        end
                        break
                    end
                end
            end--点击包
            if menu:keyYes() then
                self.choose_func()
            end
        else
            HandBookSubmenu[self.big_pos]:frame()

        end
        if menu:keyNo() then
            PlaySound("cancel00")
            self.exit_func()
        end
    end
end
function handbook_menu:render()
    SetViewMode("ui")
    ui:DrawBack(1, self.timer)
    local t = self.timer
    local ui = ui
    local Pos = self.big_pos
    do
        local A = self.load_alpha
        if A and A > 0 then
            local length = min(self.index / self.maxindex, 1)
            local Y = 270
            local x = 480
            local w = 350
            local h = 14
            local x1, x2 = x - w / 2, x + w / 2
            SetImageState("white", "", 255 * A, 255, 255, 255)
            RenderRect("white", x1 - 1, x2 + 1, Y - h / 2 - 1, Y + h / 2 + 1)
            SetImageState("white", "", 255 * A, 0, 0, 0)
            RenderRect("white", x1, x2, Y - h / 2, Y + h / 2)
            SetImageState("white", "",
                    Color(180 * A, 255 - 155 * length, 255 * length, 0 + 100 * length))
            RenderRect("white", x1, x1 + length * w, Y - h / 2, Y + h / 2)
            ui:RenderText("title", ("%0.2f%%"):format(length * 100), x, Y, 0.85,
                    Color(255 * A, 255 * length, 255 - 28 * length, 100 + 32 * length), "centerpoint")
            ui:RenderText("title", _t("loading") .. string.rep(".", int(self.timer / 20 % 6) + 1),
                    480, Y - 50, 1, Color(A * 255, 255, 227, 132), "centerpoint")
            ui:RenderText("small_text", "Tips : " .. self.text,
                    480, Y - 90, 1.15, Color(A * 255, 250, 128, 114 + 50 * sin(self.timer * 2)), "centerpoint")
        end
    end

    do
        local _alpha = self._alpha
        local x
        for i, u in ipairs(self.selection) do
            x = 480 + self.ox + (i - Pos) * self.intervalx
            local cindex = 1
            if i == Pos then
                u.index = u.index + (-u.index + 1) * 0.1

            else
                u.index = u.index + (-u.index) * 0.1
                cindex = cindex * 0.5
            end
            local size = (70 + 50 * u.index)
            SetImageState("menu_circle", "", _alpha * cindex * 255, 200, 200, 200)
            Render("menu_circle", x, self.y, 0, size / 192)
            ui:RenderText("pretty", u.name, x, self.y - size * 1.2, 0.55 + u.index * 0.2,
                    Color(_alpha * cindex * 255, 200, 200, 200), "centerpoint")
            if i == Pos then
                local r, g, b = sp:HSVtoRGB(i * 15 + t / 2 + x / 30, 0.7, 1)
                SetImageState("menu_bright_circle", "mul+add",
                        _alpha * cindex * 255, r * cindex, g * cindex, b * cindex)
                Render("menu_bright_circle", x, self.y, 0, size / 130)
            end
            if u.pic then
                SetImageState(u.pic, "mul+add", _alpha * cindex * 255, 200, 200, 200)
                Render(u.pic, x, self.y, 0, size * 1.6 / GetTextureSize(u.pic))
            end


        end
    end
    HandBookSubmenu[self.big_pos]:render()
    self.top_bar:render()
end