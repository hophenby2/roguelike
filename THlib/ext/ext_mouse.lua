local mouse = { }
---初始化函数
function mouse:init()
    self.last_x, self.last_y = 0, 0
    self.x, self.y = self:get()
    self.dx, self.dy = self.x - self.last_x, self.y - self.last_y
    self._state = { }
    self._record_state = {}
end

---帧逻辑
function mouse:frame()
    self.last_x, self.last_y = self.x, self.y
    self.x, self.y = self:get()
    self.dx, self.dy = self.x - self.last_x, self.y - self.last_y

    self:UpdateState()
    if self:isDown(2) then
        self._click_x = self.x
        self._click_y = self.y
    end
    if self:isPress(2) then
        self._click_flag = true
    else
        self._click_flag = nil
    end
    self._wheel = GetMouseWheelDelta()
end

---渲染逻辑
function mouse:render()
    if not (self._hide) then
        SetImageState(self.img, self.blend, self.color)
        Render(self.img, self.x, self.y, self.rot, self.scale)
    end
end

---获取鼠标位置
function mouse:get()
    local x, y = GetMousePosition()
    x = (x - screen.dx) / screen.scale
    y = (y - screen.dy) / screen.scale
    return x, y
end

---获取拖动距离
---@return number, number
function mouse:getDrag()
    local x, y = 0, 0
    if self._click_flag then
        x = self.x - self._click_x
        y = self.y - self._click_y
    end
    return x, y
end

---获取滚轮滚动量
---@return number
function mouse:getWheel()
    return self._wheel
end

---更新鼠标状态
function mouse:UpdateState()
    local left = GetMouseState(0)
    local center = GetMouseState(1)
    local right = GetMouseState(2)
    self._record_state[1] = self._state[1]
    self._state[1] = left
    self._record_state[2] = self._state[2]
    self._state[2] = center
    self._record_state[3] = self._state[3]
    self._state[3] = right
end

---获取是否按下
---@param button number 按键编号
---@return boolean
function mouse:isPress(button)
    button = button or 1
    return self._state[button]
end

---@param button number 按键编号
---@return boolean
function mouse:isDown(button)
    button = button or 1
    return self._state[button] and not (self._record_state[button])
end

---@param button number 按键编号
---@return boolean
function mouse:isUp(button)
    button = button or 1
    return self._record_state[button] and not (self._state[button])
end

---@class ext.mouse @鼠标控制
ext.mouse = mouse
ext.mouse:init()