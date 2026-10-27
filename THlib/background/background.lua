---=====================================
---luastg stage background
---=====================================

----------------------------------------
---background
---@class background
background = Class(object)

function background:init(is_sc_bg)
    self.group = 0
    if is_sc_bg then
        self.layer = -700
        self.alpha = 0
    else
        self.layer = -700 - 0.1
        self.alpha = 1
        if lstg.tmpvar.bg and IsValid(lstg.tmpvar.bg) then
            background.DelBG()
        end
        lstg.tmpvar.bg = self
        background.Capture(self)
    end
end
local lstg, task = lstg, task
---丝滑设置摄像头
---@param para string
---@param pos number
---@param value number
---@param time number
---@param mode number
---@param wait boolean@是否占时间
function background:Move3Dcamera(para, pos, value, time, mode, wait)
    if wait then
        task.SmoothSetValueTo(function()
            return lstg.view3d[para][pos]
        end, value, time, mode, function(s)
            lstg.view3d[para][pos] = s
        end)
    else
        task.New(self, function()
            task.SmoothSetValueTo(function()
                return lstg.view3d[para][pos]
            end, value, time, mode, function(s)
                lstg.view3d[para][pos] = s
            end)
        end)
    end
end

---不保存的随机函数
local rand = math.random
function background:RanFloat(a, b)
    if a > b then
        a, b = b, a
    end
    local c = (a + b) / 2
    return c + (rand() - 0.5) * (b - c) * 2
end
function background:RanInt(a, b)
    if a > b then
        a, b = b, a
    end
    return rand(a, b)
end
function background:RanSign()
    return ({ -1, 1 })[rand(2)]
end

---通过检测是否创建背景来创建背景
---@param bg object
function background.Create(bg)
    if bg then
        if setting.displayBG then
            return New(bg), true
        else
            lstg.tmpvar.bg = {}
            bg.init(lstg.tmpvar.bg)
            setmetatable(lstg.tmpvar.bg, {
                __index = function(t, k)
                    rawset(t, k, 0)
                    return 0
                end,
                __newindex = function(t, k, v)
                    rawset(t, k, v)
                end })
            return lstg.tmpvar.bg, false
        end
    end
end

function background.DelBG()
    local bg = lstg.tmpvar.bg
    if IsValid(bg) then
        Del(bg.Capturer1)
        Del(bg.Capturer2)
        Del(bg)
    end
    lstg.tmpvar.bg = nil
end

function background.ClearToFogColor()
    RenderClearViewMode(lstg.view3d.fog[3])
end

----------------------------------------
---一些效果

CreateRenderTarget("WorldTex1")
CreateRenderTarget("WorldTex2")
function background.Capture(bg)
    bg.Capturer1 = New(Class(object, {
        init = function(self)
            object.init(self, 0, 0, GROUP.GHOST, LAYER.BG + 1)
            bg.Capturer2 = New(self.class.push, self)
            self.master = bg
            self.uv1, self.uv2, self.uv3, self.uv4 = { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }, { [3] = 0.5 }
            local color = Color(255, 255, 255, 255)
            local w = lstg.world
            self.uv1[1], self.uv1[2] = w.l, w.t
            self.uv2[1], self.uv2[2] = w.r, w.t
            self.uv3[1], self.uv3[2] = w.r, w.b
            self.uv4[1], self.uv4[2] = w.l, w.b
            self.uv1[4], self.uv1[5] = WorldToScreen(w.l, w.t)
            self.uv2[4], self.uv2[5] = WorldToScreen(w.r, w.t)
            self.uv3[4], self.uv3[5] = WorldToScreen(w.r, w.b)
            self.uv4[4], self.uv4[5] = WorldToScreen(w.l, w.b)
            self.uv1[6] = color
            self.uv2[6] = color
            self.uv3[6] = color
            self.uv4[6] = color
        end,
        frame = function(self)
            if not IsValid(self.master) then
                object.Del(self)
            end
        end,
        render = function(self)
            lstg.PopRenderTarget("WorldTex1")
            lstg.RenderTexture("WorldTex1", "", self.uv1, self.uv2, self.uv3, self.uv4)
        end,
        push = Class(object, {
            init = function(self, master)
                self.layer = LAYER.BG - 1
                self.group = GROUP.GHOST
                self.master = master
            end,
            frame = function(self)
                if not IsValid(self.master) then
                    object.Del(self)
                end
            end,
            render = function()
                lstg.PushRenderTarget("WorldTex1")
                RenderClear(Color(255, 0, 0, 0))
            end
        }, true),
    }, true))

end

Include 'THlib\\background\\spellcard.lua'
Include 'THlib\\background\\fall_leaf.lua'

Include("THlib\\background\\distortion.lua")
CopyImage("small_leaf", "circle_charge_eff")

----------------------------------------
---一些方便RenderTexture的东西


do
    local index = 1
    local flag
    while true do
        flag = false
        for _, file in ipairs(FindFiles("assets\\background\\" .. index .. "\\", "lua", "")) do
            if GlobalLoading then
                DoFile(file[1])
            else
                table.insert(LoadRes, function()
                    DoFile(file[1])
                end)
            end
            flag = true
        end
        index = index + 1
        if not flag then
            break
        end
    end
end
