local function _t(str)
    return i18n("sth", str) or ""
end

local playdata_menu = stage.New("playdata", false, true)
function playdata_menu:init()
    self.top_bar = top_bar_Class(self, _t("playData"))
    self.exit_func = function()
        task.New(self, function()
            self.locked = true
            mask_fader:Do("close")
            task.Wait(15)
            stage.Set("none", "main")
        end)
    end
    self.top_bar:addReturnButton(self.exit_func)
    mask_fader:Do("open")

    self.x, self.y = 960, 540
    self.alpha = 1
    self.locked = true
    self.offy1 = 0
    self._offy1 = 0
    self.line_h_1 = 25
    self.offy2 = 0
    self._offy2 = 0
    self.line_h_2 = 80
    self.timer = 0
    self:refresh()
    task.New(self, function()
        task.Wait(30)
        while GetKeyState(KEY.Z) do
            task.Wait()
        end
        self.locked = false
    end)
end
function playdata_menu:refresh()

    local data = scoredata
    self.infodata = {
        { _t("playTime"), function()
            local time = data.Duration
            return _t("DayHourMinSec"):format(time[5], time[4], time[3], time[2])
        end },
        { _t("continuousLogin"), function()
            return data.ContinuousLogin
        end },
        { "", function()
            return
        end },
        { _t("totalMiss"), function()
            return data._total_miss
        end },
        { _t("totalBomb"), function()
            return data._total_bomb
        end },
        { _t("totalKillEnemy"), function()
            return data._total_kill_enemy
        end },
        { _t("totalDeath"), function()
            return data._total_death
        end },
        { _t("totalMissEXP"), function()
            return data._total_miss_exp
        end },
        { "", function()
            return
        end },
        { _t("totalGetBenefit"), function()
            return data._total_get_benefit
        end },
        { _t("totalGetTrade"), function()
            return data._total_get_trade
        end },
        { _t("totalGetInfringe"), function()
            return data._total_get_infringe
        end },
        { _t("totalGetItem"), function()
            return data._total_get_item
        end },
        { "", function()
            return
        end },
        { _t("totalFinishedMission"), function()
            return data._total_mission
        end },
        { "", function()
            return
        end },
        { _t("nextGameHaveYHDHY"), function()
            return data.infinite_clock and _t("T") or _t("F")
        end },
    }
    if scoredata.First5Season then
        table.insert(self.infodata, { _t("nextSeasonisInside"), function()
            return ("%d%%"):format(data.inside_pro * 100)
        end })
    end

end
function playdata_menu:frame()
    self.timer = self.timer + 1
    if self.locked then
        return
    end
    local mouse = ext.mouse
    menu:Updatekey()
    local alpha = self.alpha
    local x1, x2, y1, y2, h
    x1, x2, y1, y2 = 480 - 180 * alpha, 480 + 180 * alpha, 30, 455
    h = y2 - y1
    self._offy1 = self._offy1 + (-self._offy1 + clamp(self._offy1, 0, max(self.line_h_1 * #self.infodata - h, 0))) * 0.3
    self.offy1 = self.offy1 + (-self.offy1 + self._offy1) * 0.3
    if sp.math.PointBoundCheck(mouse.x, mouse.y, x1, x2, y1, y2) then
        if mouse._wheel ~= 0 then
            self._offy1 = self._offy1 - sign(mouse._wheel) * self.line_h_1 * 4
            PlaySound("select00")
        end
    end
    if menu:keyUp() then
        self._offy1 = self._offy1 - self.line_h_1 * 4
        PlaySound("select00")
    end
    if menu:keyDown() then
        self._offy1 = self._offy1 + self.line_h_1 * 4
        PlaySound("select00")
    end
    --[[
    x1, x2, y1, y2 = 720 - 180 * alpha, 720 + 180 * alpha, 30, 455
    h = y2 - y1
    self._offy2 = self._offy2 + (-self._offy2 + Forbid(self._offy2, 0, max(self.line_h_2 * min(36, #self.stage_list) - h, 0))) * 0.3
    self.offy2 = self.offy2 + (-self.offy2 + self._offy2) * 0.3
    if sp.math.PointBoundCheck(mouse.x, mouse.y, x1, x2, y1, y2) then
        if mouse._wheel ~= 0 then
            self._offy2 = self._offy2 - sign(mouse._wheel) * self.line_h_2 * 1
            PlaySound("select00")
        end
    end--]]
    self.top_bar:frame()
    if menu:keyNo() then
        PlaySound("cancel00")
        self.exit_func()
    end
end
function playdata_menu:render()
    if self.alpha == 0 then
        return
    end
    SetViewMode("ui")
    ui:DrawBack(self.alpha, self.timer)
    do
        local alpha = self.alpha
        local x1, x2, y1, y2, Y

        x1, x2, y1, y2 = 480 - 180 * alpha, 480 + 180 * alpha, 30, 455
        SetImageState("white", "", alpha * 180, 10, 10, 10)
        RenderRect("white", x1, x2, y1, y2)
        SetImageState("white", "", alpha * 255, 255, 255, 255)
        misc.RenderOutLine("white", x1, x2, y2, y1, 0, 2)
        SetRenderRect(x1, x2, y1 - self.offy1, y2 - self.offy1, x1, x2, y1, y2)
        Y = y2
        RenderRect("white", x1, x2, Y - 0.5, Y + 0.5)
        for _, t in ipairs(self.infodata) do
            if Y < y1 - self.offy1 then
                break
            end
            Y = Y - self.line_h_1
            if Y < y2 - self.offy1 then
                local r, g, b = sp:HSVtoRGB(Y, 0.2, 1)
                ui:RenderText("title", t[1] or "", x1 + 3, Y + self.line_h_1 - 3, 0.9, Color(alpha * 255, r, g, b), "top", "left")
                ui:RenderText("title", t[2]() or "", x2 - 3, Y + self.line_h_1 - 3, 0.9, Color(alpha * 255, r, g, b), "top", "right")
                RenderRect("white", x1, x2, Y - 0.5, Y + 0.5)
            end

        end
        SetViewMode("ui")
        --[=[
        SetViewMode("ui")

        ui:RenderText("big_text", "关卡排行", 720, 500, 0.8, Color(alpha * 255, 255, 255, 255), "centerpoint")
        x1, x2, y1, y2 = 720 - 180 * alpha, 720 + 180 * alpha, 30, 455
        SetImageState("white", "", alpha * 180, 10, 10, 10)
        RenderRect("white", x1, x2, y1, y2)
        SetImageState("white", "", alpha * 255, 255, 255, 255)
        misc.RenderOutLine("white", x1, x2, y2, y1, 0, 2)
        SetRenderRect(x1, x2, y1 - self.offy2, y2 - self.offy2, x1, x2, y1, y2)
        Y = y2
        RenderRect("white", x1, x2, Y - 0.5, Y + 0.5)
        local uv1, uv2, uv3, uv4 = { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }
        local col = Color(255 * self.alpha, 255, 255, 255)
        uv1[6], uv2[6], uv3[6], uv4[6] = col, col, col, col
        uv1[4], uv1[5] = 0, 0
        uv2[4], uv2[5] = 256, 0
        uv3[4], uv3[5] = 256, 256
        uv4[4], uv4[5] = 0, 256
        ---@param t list_unit
        for rank, t in ipairs(self.stage_list) do
            if Y < y1 - self.offy2 or rank > 36 then
                break
            end
            Y = Y - self.line_h_2
            if Y < y2 - self.offy2 then
                local r, g, b = sp:HSVtoRGB(55, 1 - rank / min(#self.stage_list, 30) * 0.5, 1)
                if rank > 30 then
                    r, g, b = 180, 180, 180
                end
                RenderRect("white", x1, x2, Y - 0.5, Y + 0.5)
                local _x1, _x2, _y1, _y2 = x2 - self.line_h_2 + 5, x2 - 5, Y + 5, Y + self.line_h_2 - 5
                uv1[1], uv1[2] = _x1, _y2
                uv2[1], uv2[2] = _x2, _y2
                uv3[1], uv3[2] = _x2, _y1
                uv4[1], uv4[2] = _x1, _y1

                RenderTexture(musicList[t.card.bgm][5], "", uv1, uv2, uv3, uv4) --显示不太好的样子
                SetImageState("white", "", alpha * 255, 255, 255, 255)
                misc.RenderOutLine("white", _x1, _x2, _y2, _y1, 1, 0)
                ui:RenderText("title", ("No. %d"):format(rank), x1 + 5, Y + self.line_h_2 - 5,
                        0.9, Color(alpha * 255, r, g, b), "left", "top")

                ui:RenderText("title", ("Rating: %0.2f"):format(t.rating), x1 + 5, Y + self.line_h_2 - 22,
                        0.9, Color(alpha * 255, 250, 128, 114), "left", "top")
                ui:RenderText("title", ("Score: %d"):format(t.music_score), x1 + 5, Y + self.line_h_2 - 39,
                        0.9, Color(alpha * 255, 220, 220, 220), "left", "top")
                local p, g, b, m, pm = t.perfect or 0,
                t.great or 0,
                t.bad or 0,
                t.miss or 0,
                t.playermiss or 0
                local lp, lg, lb, lm, lpm = sp.string(("%d"):format(p)):GetLength(),
                sp.string(("%d"):format(g)):GetLength(),
                sp.string(("%d"):format(b)):GetLength(),
                sp.string(("%d"):format(m)):GetLength(),
                sp.string(("%d"):format(pm)):GetLength()
                local size = 9
                local ptr = x1 + 5

                ui:RenderText("title", ("%d"):format(p), ptr, Y + self.line_h_2 - 56,
                        0.9, Color(alpha * 255, 135, 206, 235), "left", "top")
                ptr = ptr + size * lp
                ui:RenderText("title", (" / "), ptr, Y + self.line_h_2 - 56,
                        0.9, Color(alpha * 255, 220, 220, 220), "left", "top")
                ptr = ptr + size * 1.5
                ui:RenderText("title", ("%d"):format(g), ptr, Y + self.line_h_2 - 56,
                        0.9, Color(alpha * 255, 189, 252, 201), "left", "top")
                ptr = ptr + size * lg
                ui:RenderText("title", (" / "), ptr, Y + self.line_h_2 - 56,
                        0.9, Color(alpha * 255, 220, 220, 220), "left", "top")
                ptr = ptr + size * 1.5
                ui:RenderText("title", ("%d"):format(b), ptr, Y + self.line_h_2 - 56,
                        0.9, Color(alpha * 255, 100, 100, 100), "left", "top")
                ptr = ptr + size * lb
                ui:RenderText("title", (" / "), ptr, Y + self.line_h_2 - 56,
                        0.9, Color(alpha * 255, 220, 220, 220), "left", "top")
                ptr = ptr + size * 1.5
                ui:RenderText("title", ("%d"):format(m), ptr, Y + self.line_h_2 - 56,
                        0.9, Color(alpha * 255, 250, 128, 114), "left", "top")
                ptr = ptr + size * lm
                ui:RenderText("title", (" + "), ptr, Y + self.line_h_2 - 56,
                        0.9, Color(alpha * 255, 220, 220, 220), "left", "top")
                ptr = ptr + size * 2
                ui:RenderText("title", ("%d"):format(pm), ptr, Y + self.line_h_2 - 56,
                        0.9, Color(alpha * 255, 250, 72, 114), "left", "top")
                ptr = ptr + size * lpm

                local tt = sp.string(musicList[t.card.bgm][3])
                if tt:GetLength() > 18 then
                    tt:Set(tt:Sub(1, 12) .. "..." .. tt:Sub(-3, -1))
                end
                ui:RenderText("title", tt._string, _x1 - 5, Y + self.line_h_2 - 5,
                        0.9, Color(alpha * 200, 200, 200, 200), "right", "top")
                --[[ui:RenderText("title", "", _x1 - 5, Y + self.line_h_2 - 25,
                        0.7, Color(alpha * 200, 180, 180, 180), "right", "top")--]]
                ui:RenderText("title", ("%s %s (%0.1f)"):format(diff_group_name[t.card.diff_group], t.card.display_diff or 2, t.card.diff),
                        _x1 - 5, Y + self.line_h_2 - 25, 0.9, Color(alpha * 200, 180, 180, 180), "right", "top")
            end
        end--]=]
    end

    self.top_bar:render()
end