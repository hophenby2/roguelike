---=====================================
---luastg task
---=====================================

----------------------------------------
---基本函数

---@type task
local task = {}
_G.task = task

task.stack = {}
task.co = {}

local coroutine = coroutine

function task.New(unit, f)
    if not unit.task then
        unit.task = {}
    end
    if f then
        local rt = coroutine.create(f)
        unit.task[#unit.task + 1] = rt
        return rt, #unit.task
    end
end

function task.Do(unit)
    if unit.task then
        for i = #unit.task, 1, -1 do
            local co = unit.task[i]
            if co then
                if coroutine.status(co) ~= 'dead' then
                    task.stack[#task.stack + 1] = unit
                    task.co[#task.co + 1] = co
                    local _, errmsg = coroutine.resume(co)
                    if errmsg then
                        error(tostring(errmsg) ..
                                "\n========== coroutine traceback ==========\n" ..
                                debug.traceback(co) ..
                                "\n========== C traceback ==========")
                    end
                    task.stack[#task.stack] = nil
                    task.co[#task.co] = nil
                else
                    table.remove(unit.task, i)
                end
            end
        end
    end
end

function task.Clear(unit, keepCurtask)
    if keepCurtask then
        local flag = false
        local co = task.co[#task.co]
        for i = 1, #unit.task do
            if unit.task[i] == co then
                flag = true
                break
            end
        end
        unit.task = {}
        if flag then
            unit.task = { co }
        end
    else
        unit.task = {}
    end
end

---等待t帧，在task环境内
---t是非负整数
---@param t number
function task.Wait(t)
    t = max(0, int(t or 1))
    if t == 1 then
        coroutine.yield()
    else
        for _ = 1, t do
            coroutine.yield()
        end
    end
end

---等待t帧，在task环境内
---t可以是小数，处理方法是把小数部分集起来，多出了1再wait1帧
---@param t number
function task.Wait2(unit, t)
    t = max(0, t or 1)
    if t == 1 then
        coroutine.yield()
    else
        for _ = 1, t do
            coroutine.yield()
        end
        unit.task_left_wait = unit.task_left_wait + (t - int(t))
        while unit.task_left_wait >= 1 do
            coroutine.yield()
            unit.task_left_wait = unit.task_left_wait - 1
        end
    end
end

---等待该t的小数部分帧，一般用于执行占用整数帧的命令之后
function task.Wait2_InFrac(unit, t)
    unit.task_left_wait = unit.task_left_wait + (t - int(t))
    while unit.task_left_wait >= 1 do
        coroutine.yield()
        unit.task_left_wait = unit.task_left_wait - 1
    end
end

---初始化小数帧记录
function task.init_left_wait(unit)
    unit.task_left_wait = 0
end

function task.GetSelf()
    local c = task.stack[#task.stack]
    if c.taskself then
        return c.taskself
    else
        return c
    end
end

----------------------------------------
---数值变化模式(单位1)
VALUE_SET = {
    ---0
    NORMAL = 0,
    ---1
    ACCEL = 1,
    ---2
    DECEL = 2,
    ---3
    ACC_DEC = 3,
    ---4
    OVER = 4,
    ---5
    SIN_DEC = 5,
    ---6
    SIN_ACC = 6
}

---boss随机移动模式
WANDER_MODE = {
    ---0
    TO_PLAYER = 0,
    ---1
    TO_PLAYER_X = 1,
    ---2
    TO_PLAYER_Y = 2,
    ---3
    RANDOM = 3
}

---增量模式
INC_MODE = {
    SET = 0,
    ADD = 1,
    MUL = 2
}

task.SetMode = {
    [0] = function(n)
        return n
    end, --线性
    [1] = function(n)
        return n * n
    end, --二指数加速
    [2] = function(n)
        return 2 * n - n * n
    end, --二指数减速
    [3] = function(n)
        if n < 0.5 then
            return 2 * n * n
        else
            return -2 * n * n + 4 * n - 1
        end
    end, --二指数加减速
    [4] = function(n)
        return 2 * n - n * n * n
    end, --3指数超过100%

    [5] = function(n)
        return sin(n * 90)
    end, --正弦减速
    [6] = function(n)
        return 1 - sin(90 - n * 90)
    end, --正弦加速

    [7] = function(n)
        return n * n * n
    end, --三指数加速
    [8] = function(n)
        return n * n * n - 3 * n * n + 3 * n
    end, --三指数减速

    [9] = function(n)
        return n * n * n * n
    end, --四指数加速
    [10] = function(n)
        return -n * n * n * n + 4 * n * n * n - 6 * n * n + 4 * n
    end, --四指数减速
    [11] = function(n)
        n = n - 0.5
        return 4 * n * n * n + 0.5
    end, --三指数减速进入加速退出
    [12] = function(n)
        if n < 1 then
            return n
        else
            return 2 - n
        end
    end--匀速，但是大于1时返回
}
setmetatable(task.SetMode, {
    __index = function(_, k)
        if type(k) == "function" then
            return k
        end
    end
})

---不知道有什么卵用的单独拿出来的smooth
task.Smooth = task.SetMode[3]

function task.MoveTo(x, y, t, mode)
    t = max(1, int(t))
    local self = task.GetSelf()
    local dx = x - self.x
    local dy = y - self.y
    local slast = 0
    for s = 1, t do
        s = task.SetMode[mode](s / t)
        self.vx = (s - slast) * dx
        self.vy = (s - slast) * dy
        slast = s
        coroutine.yield()
    end
    self.vx, self.vy = 0, 0
end

function task.MoveTo(x, y, t, mode)
    t = max(1, int(t))
    local self = task.GetSelf()
    local dx = x - self.x
    local dy = y - self.y
    local slast = 0
    for s = 1, t do
        s = task.SetMode[mode](s / t)
        self.vx = (s - slast) * dx
        self.vy = (s - slast) * dy
        slast = s
        coroutine.yield()
    end
    self.vx, self.vy = 0, 0
end

---强制移动，不受加减速影响
function task.MoveToForce(x, y, t, mode)
    t = max(1, int(t))
    local self = task.GetSelf()
    local dx = x - self.x
    local dy = y - self.y
    local ix, iy = self.x, self.y
    for s = 1, t do
        s = task.SetMode[mode](s / t)
        self.x = ix + s * dx
        self.y = iy + s * dy
        coroutine.yield()
    end
end

function task.MoveToTarget(target, t, mode)
    t = max(1, int(t))
    local self = task.GetSelf()
    local x, y = self.x, self.y
    local xs = self.x
    local ys = self.y
    for s = 1, t do
        if IsValid(target) then
            s = task.SetMode[mode](s / t)
            self.x = xs + s * (target.x - x)
            self.y = ys + s * (target.y - y)
            coroutine.yield()
        end
    end
end

function task.MoveToEx(x, y, t, mode)
    t = max(1, int(t))
    local self = task.GetSelf()
    local dx = x
    local dy = y
    local slast = 0
    for s = 1, t do
        s = task.SetMode[mode](s / t)
        self.vx = (s - slast) * dx
        self.vy = (s - slast) * dy
        coroutine.yield()
        slast = s
    end
    self.vx, self.vy = 0, 0
end

function task.MoveToPlayer(t, x1, x2, y1, y2, dxmin, dxmax, dymin, dymax, mmode, dmode)
    local dirx, diry = ran:Sign(), ran:Sign()
    local self = task.GetSelf()
    local p = player
    if dmode < 2 then
        if self.x > p.x then
            dirx = -1
        else
            dirx = 1
        end
    end
    if dmode == 0 or dmode == 2 then
        if self.y > p.y then
            diry = -1
        else
            diry = 1
        end
    end
    local dx = ran:Float(dxmin, dxmax)
    local dy = ran:Float(dymin, dymax)
    if self.x + dx * dirx < x1 then
        dirx = 1
    end
    if self.x + dx * dirx > x2 then
        dirx = -1
    end
    if self.y + dy * diry < y1 then
        diry = 1
    end
    if self.y + dy * diry > y2 then
        diry = -1
    end
    if t == 0 then
        return self.x + dx * dirx, self.y + dy * diry
    else
        task.MoveTo(self.x + dx * dirx, self.y + dy * diry, t, mmode)
    end
end

---青山写的贝塞尔曲线
function task.BezierMoveTo(t, mode, ...)
    local arg = { ... }
    local self = task.GetSelf()
    t = max(1, int(t))
    local count = (#arg) / 2
    local x = { self.x }
    local y = { self.y }
    for i = 1, count do
        x[i + 1] = arg[i * 2 - 1]
        y[i + 1] = arg[i * 2]
    end
    local com_num = {}
    for i = 0, count do
        com_num[i + 1] = combinNum(i, count)
    end
    local _x, _y, da
    for s = 1, t do
        s = task.SetMode[mode](s / t)
        _x, _y = 0, 0
        for j = 0, count do
            da = com_num[j + 1] * (1 - s) ^ (count - j) * s ^ j
            _x = _x + x[j + 1] * da
            _y = _y + y[j + 1] * da
        end
        self.x = _x
        self.y = _y
        coroutine.yield()
    end
end

---青山写的埃尔金样条
function task.CRMoveTo(t, mode, ...)
    local self = task.GetSelf()
    local arg = { ... }
    local count = (#arg) / 2
    local x = { self.x }
    local y = { self.y }
    for i = 1, count do
        x[i + 1] = arg[i * 2 - 1]
        y[i + 1] = arg[i * 2]
    end
    table.insert(x, 2 * x[#x] - x[#x - 1])
    table.insert(x, 1, 2 * x[1] - x[2])

    table.insert(y, 2 * y[#y] - y[#y - 1])
    table.insert(y, 1, 2 * y[1] - y[2])

    t = max(1, int(t))

    local timeMark = {}
    for i = 1, t do
        timeMark[i] = count * task.SetMode[mode](i / t)
    end
    local s, j, _x, _y, j2, j3
    local st, s1t, s2t, s3t
    for i = 1, t - 1 do
        s = math.floor(timeMark[i]) + 1
        j = timeMark[i] % 1
        j2 = j * j
        j3 = j * j * j
        st = -0.5 * j3 + j2 - 0.5 * j
        s1t = 1.5 * j3 - 2.5 * j2 + 1
        s2t = -1.5 * j3 + 2 * j2 + 0.5 * j
        s3t = 0.5 * j3 - 0.5 * j2
        _x = x[s] * st + x[s + 1] * s1t + x[s + 2] * s2t + x[s + 3] * s3t
        _y = y[s] * st + y[s + 1] * s1t + y[s + 2] * s2t + y[s + 3] * s3t
        self.x = _x
        self.y = _y
        coroutine.yield()
    end
    self.x = x[count + 2]
    self.y = y[count + 2]
    coroutine.yield()
end

---Xiliusha写的二次B样条,过采样点间的中点，为二次曲线
function task.Basis2MoveTo(t, mode, ...)
    --获得基本参数
    local self = task.GetSelf()
    local arg = { ... }
    t = math.max(1, math.floor(t))
    --构造采样点列表
    local count = (#arg) / 2
    local x = { self.x }
    local y = { self.y }
    for i = 1, count do
        x[i + 1] = arg[i * 2 - 1]
        y[i + 1] = arg[i * 2]
    end
    --检查采样点数量，如果不足3个，则插值到3个
    if count < 2 then
        --只有两个采样点时，取中点插值
        x[3] = x[2]
        y[3] = y[2]
        x[2] = x[1] + 0.5 * (x[3] - x[1])
        y[2] = y[1] + 0.5 * (y[3] - y[1])
    elseif count < 1 then
        --只有一个采样点时，只能这样了
        for i = 2, 3 do
            x[i] = x[1]
            y[i] = y[1]
        end
    end
    count = math.max(2, count)
    --储存末点，给末尾使用
    local fx, fy = x[#x], y[#y]
    --对首末采样点特化处理
    do
        x[1] = x[2] + 2 * (x[1] - x[2])
        y[1] = y[2] + 2 * (y[1] - y[2])
        --末点处理
        x[count + 1] = x[count] + 2 * (x[count + 1] - x[count])
        y[count + 1] = y[count] + 2 * (y[count + 1] - y[count])
        --插入尾数据解决越界报错
        x[count + 2] = x[count + 1]
        y[count + 2] = y[count + 1]
    end--首点处理
    --准备采样方式函数
    --开始运动
    local j, se, ct, _x, _y
    local set, se1t, se2t
    for i = 1, t do
        j = (count - 1) * task.SetMode[mode](i / t)--采样方式
        se = math.floor(j) + 1        --3采样选择
        ct = j - math.floor(j)        --切换
        set = 0.5 * (ct - 1) * (ct - 1)
        se1t = 0.5 * (-2 * ct * ct + 2 * ct + 1)
        se2t = 0.5 * ct * ct
        _x = x[se] * set + x[se + 1] * se1t + x[se + 2] * se2t
        _y = y[se] * set + y[se + 1] * se1t + y[se + 2] * se2t
        self.x, self.y = _x, _y
        coroutine.yield()
    end
    --末尾处理，解决曲线采样带来的误差
    self.x, self.y = fx, fy
end

---平滑设置一个对象的变量
---@param valname string|number|function @索引或者一个变量设置函数
---@param y number @增量
---@param t number @持续时间
---@param mode number @参见移动模式
---@param setter function @变量设置函数
---@param starttime number @等待时间
---@param vmode number @INC_MODE.SET, INC_MODE.ADD, INC_MODE.MUL，增量模式
function task.SmoothSetValueTo(valname, y, t, mode, setter, starttime, vmode)
    local self = task.GetSelf()
    task.Wait(starttime or 0)
    t = max(1, int(t))
    local ys = setter and valname() or self[valname]
    local dy = y - ys
    vmode = vmode or 0
    if vmode == 1 then
        dy = y
    elseif vmode == 2 then
        dy = ys * y - ys
    end
    if setter then
        for s = 1, t do
            s = task.SetMode[mode](s / t)
            setter(ys + s * dy)
            coroutine.yield()
        end
    else
        for s = 1, t do
            s = task.SetMode[mode](s / t)
            self[valname] = ys + s * dy
            coroutine.yield()
        end
    end
end

