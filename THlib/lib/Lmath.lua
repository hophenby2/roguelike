---=====================================
---luastg math
---=====================================

----------------------------------------
---常量
local math = math
PI = math.pi
PIx2 = math.pi * 2
PI_2 = math.pi * 0.5
PI_4 = math.pi * 0.25
SQRT2 = math.sqrt(2)
SQRT3 = math.sqrt(3)
SQRT2_2 = math.sqrt(0.5)
GOLD = 360 * (math.sqrt(5) - 1) / 2

----------------------------------------
---数学函数

int = math.floor
abs = math.abs
max = math.max
min = math.min
sqrt = math.sqrt

local int = int
local t_ = {  }
for i = 1, 360 do
    table.insert(t_, cos(i))
end


function Cos(t)
    t = (int(t) - 1) % 360 + 1
    return t_[t]
end
function Sin(t)
    t = (int(t) + 89) % 360 + 1
    return t_[t]
end
--不用算的三角函数

local asin, sin = asin, sin
function LineNum(t)
    return asin(sin(t)) / 90
end

---限制数的范围，
---比同时用min,max高效
---比单个min,max低效
function clamp(t, MIN, MAX)
    if MAX and t >= MAX then
        return MAX
    elseif MIN and t <= MIN then
        return MIN
    else
        return t
    end
end

---获得数字的符号(1/-1/0)
function sign(x)
    if x > 0 then
        return 1
    elseif x < 0 then
        return -1
    else
        return 0
    end
end

local sqrt = sqrt
---获得(x,y)向量的模长
function hypot(x, y)
    return sqrt(x * x + y * y)
end

---阶乘，目前用于组合数和贝塞尔曲线
local fac = {}
function Factorial(num)
    if num < 0 then
        error("Can't get factorial of a minus number.")
    end
    if num < 2 then
        return 1
    end
    num = int(num)
    if fac[num] then
        return fac[num]
    end
    local result = 1
    for i = 1, num do
        if fac[i] then
            result = fac[i]
        else
            result = result * i
            fac[i] = result
        end
    end
    return result
end

for i = 1, 6 do
    Factorial(i)
end--先给fac装点要用的

local Factorial = Factorial
---组合数，目前用于贝塞尔曲线
function combinNum(ord, sum)
    if sum < 0 or ord < 0 then
        error("Can't get combinatorial of minus numbers.")
    end
    ord = int(ord)
    sum = int(sum)
    return Factorial(sum) / (Factorial(ord) * Factorial(sum - ord))
end

----------------------------------------
---随机数系统，用于支持replay系统

ran = Rand()
