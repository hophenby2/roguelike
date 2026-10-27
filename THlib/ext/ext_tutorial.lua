---@class ext.tutorial
local tutorial = {  }
function tutorial:init()
    self.kill = true
    self.alpha = 0
    self.text_obj = {
    }
    self.timer = 0
    self.mask = 120
end
function tutorial:frame()
    task.Do(self)
    for i = #self.text_obj, 1, -1 do
        local p = self.text_obj[i]
        if p.del then
            table.remove(self.text_obj, i)
        end
    end
end
function tutorial:deltext(n)
    n.del = true
end
function tutorial:render()
    SetViewMode("ui")
    SetImageState("white", "", self.alpha * self.mask, 0, 0, 0)
    RenderRect("white", 0, 960, 0, 540)
    for _, n in ipairs(self.text_obj) do
        ui:RenderTextWithCommand("title", n.text, n.x, n.y, n.size, self.alpha * n.alpha * 200, "centerpoint")
    end
end
---添加文本框事件，变化什么的要自己动手
function tutorial:addtext(text, x, y, size)
    local n = {
        text = text, x = x, y = y, size = size,
        alpha = 0,
    }
    table.insert(self.text_obj, n)
    local id = #self.text_obj
    n.id = id
    return n
end
function tutorial:waitforpress()
    local key = GetLastKey()
    while key == KEY.NULL or key == KEY.ESCAPE or self.forcestop do
        ext.mouse:frame()
        if ext.mouse:isUp(1)  then
            break
        end
        key = GetLastKey()
        task.Wait()
    end
end
---@param func fun(self:ext.tutorial)
function tutorial:event(func)
    task.Clear(self)
    self.kill = false
    self.forcestop = true
    self.text_obj = {}
    self.mask = 120
    task.New(self, function()
        for i = 1, 10 do
            self.alpha = i / 10
            task.Wait()
        end
    end)
    task.New(self, function()
        while GetKeyState(KEY.Z) do
            task.Wait()
        end
        self.forcestop = false
    end)
    task.New(self, function()

        func(self)
        for i = 1, 10 do
            self.alpha = 1 - i / 10
            task.Wait()
        end
        self.kill = true
    end)
end

function tutorial:IsKilled()
    return self.kill
end

ext.tutorial = tutorial
ext.tutorial:init()