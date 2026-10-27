---@class sp.math
local lib = {}
sp.math = lib

---判断是不是真正的数(inf,ind除外)
function lib.IsRealNumber(x)
    if x == 0 then
        return true
    else
        return x % x == 0
    end
end

function lib.SubAngle(a1, a2)
    local a = (a1 - a2) % 360
    if a > 180 then
        a = a - 360
    end
    return a
end

---解决一个2元1次方程组
---ax+by=c
---@param eq1 table
---@param eq2 table
function lib.TwoUnknown(eq1, eq2)
    return
    (eq1[3] * eq2[2] - eq1[2] * eq2[3]) / (eq1[1] * eq2[2] - eq1[2] * eq2[1]),
    (eq1[3] * eq2[1] - eq1[1] * eq2[3]) / (eq1[2] * eq2[1] - eq1[1] * eq2[2])
end

local cos, sin, abs, sqrt = cos, sin, abs, sqrt

---椭圆上的点
function lib.EllipsePoint(x, y, hr, vr, erot, a)
    local x0, y0 = cos(a) * hr, sin(a) * vr
    return
    x + x0 * cos(erot) - y0 * sin(erot),
    y + y0 * cos(erot) + x0 * sin(erot)
end

---等角椭圆上的点
function lib.Ellipse2Point(x, y, hr, vr, erot, a)
    a = a % 360
    if a % 90 ~= 0 then
        local add = 0
        if a > 90 and a < 180 then
            add = 180
        elseif a > 180 and a < 270 then
            add = -180
        end
        a = atan(tan(a) * hr / vr) + add
    end
    local x0, y0 = cos(a) * hr, sin(a) * vr
    return
    x + x0 * cos(erot) - y0 * sin(erot),
    y + y0 * cos(erot) + x0 * sin(erot)
end

---心形上的点
function lib.HeartPoint(x, y, r, hrot, a)
    hrot = hrot - 90---由于0度是正上，为了对齐，调整一下度数
    local c = sin(a)
    local x0 = r * c * c * c
    local y0 = r * cos(a) - r * 0.37 * cos(a * 2) - r * 0.16 * cos(a * 3)--调整形状
    return
    x + x0 * cos(hrot) - y0 * sin(hrot),
    y + y0 * cos(hrot) + x0 * sin(hrot)
end

---正多边形上的点（等角）
---@param d number@半径
---@param n number@边数
function lib.PolygonPoint(x, y, d, n, rrot, a)
    --a = a - rrot
    d = d * cos(180 / n)
    local A
    local da = 360 / n
    local x0, y0
    for o = 0, n - 1 do
        A = (a - o * da) % 360
        if A > 180 then
            A = A - 360
        end
        if A < (da / 2) and A >= -(da / 2) then
            x0, y0 = lib.PolarToRectangular(d / cos(A), A + o * da)
            break
        end
    end
    return
    x + x0 * cos(rrot) - y0 * sin(rrot),
    y + y0 * cos(rrot) + x0 * sin(rrot)
end

---正多边形上的点（等距）
---@param d number@半径
---@param n number@边数
---@param depart number@每边分割成几段
---@param p number@第几点
function lib.PolygonPoint2(x, y, d, n, rrot, depart, p)
    d = d * cos(180 / n)
    local X = 1 / tan((180 - 360 / n) / 2) * d
    rrot = rrot + 360 / n * int(p / depart)
    p = p % depart
    X = X - 2 * X / depart * p
    return
    x + X * cos(rrot) - d * sin(rrot),
    y + X * sin(rrot) + d * cos(rrot)
end

local deg = math.deg
local atan2 = math.atan2
---把(x,y)转成(r,theta)
function lib.RectangularToPolar(x, y)
    return sqrt(x * x + y * y), deg(atan2(y, x))
end

---把(r,theta)转成(x,y)
function lib.PolarToRectangular(r, theta)
    return r * cos(theta), r * sin(theta)
end

---角度迭代器(360/n)
---@param n number@增次
---@param ia number@初始角
---@return fun():number,number
function lib.AngleIterator(ia, n)
    local index = 0
    local da = 360 / n
    ia = ia - da
    return function()
        if index < n then
            index = index + 1
            return ia + da * index, index
        end
    end
end

---椭圆坐标迭代器
---@return fun():number,number,number
function lib.EllipseIterator(ia, n, x, y, hr, vr, erot)
    local index = 0
    local da = 360 / n
    return function()
        if index < n then
            index = index + 1
            return index, lib.EllipsePoint(x, y, hr, vr, erot, ia + da * index)
        end
    end
end

---等角椭圆坐标迭代器
---@return fun():number,number,number
function lib.Ellipse2Iterator(ia, n, x, y, hr, vr, erot)
    local index = 0
    local da = 360 / n
    return function()
        if index < n then
            index = index + 1
            return index, lib.Ellipse2Point(x, y, hr, vr, erot, ia + da * index)
        end
    end
end

---心形坐标迭代器
---@return fun():number,number,number
function lib.HeartIterator(ia, n, x, y, r, hrot)
    local index = 0
    local da = 360 / n
    return function()
        if index < n then
            index = index + 1
            return index, lib.HeartPoint(x, y, r, hrot, ia + da * index)
        end
    end
end

---正多边形坐标迭代器（等角）
---n为边数的倍数最佳，倍数为奇数时无尖角，倍数为偶数时有尖角
---@param pn number@多边形边数
---@param d number@多边形对角线长
---@return fun():number,number,number
function lib.PolygonIterator(ia, n, x, y, d, pn, rrot)
    local index = 0
    local da = 360 / n
    return function()
        if index < n then
            index = index + 1
            return index, lib.PolygonPoint(x, y, d, pn, rrot, ia + da * index)
        end
    end
end

---正多边形坐标迭代器（等距）
---@param pn number@多边形边数
---@param d number@多边形对角线长
---@return fun():number,number,number
function lib.PolygonIterator2(rrot, n, x, y, d, pn)
    local index = 0
    local depart = n / pn
    return function()
        if index < n then
            index = index + 1
            return index, lib.PolygonPoint2(x, y, d, pn, rrot, depart, index)
        end
    end
end
local ipairs = ipairs
local unpack = unpack
local task = task
local select = select
local max = max
---简单循环迭代器
---次数，{初始值，增量}，...
---@param times
function lib.VariableIterator(times, ...)
    local index = 0
    local value = {}
    local incre = {}
    for i, p in ipairs({ ... }) do
        value[i] = p[1] - p[2]
        incre[i] = p[2]
    end
    return function()
        if index < times then
            index = index + 1
            for i = 1, #value do
                value[i] = value[i] + incre[i]
            end
            return unpack(value)
        end
    end
end

---高级循环包
local Advanced = {}
lib.Advanced = Advanced

---高级循环迭代器
---{函数名，参数}
---{"Increment"，初始值，增量}
---{"SetValue"，初始，最终，模式，不包括最终}
---{"TwoValues"，一值，二值}
---{"Oscillation"，一值，二值，初相，增角}
---@param times
function Advanced.Iterator(times, ...)
    local index = 0
    local cache = {}
    local method = {}
    for i, p in ipairs({ ... }) do
        method[i] = Advanced[p[1]](cache, i, select(2, unpack(p)))
    end
    return function()
        if index < times then
            index = index + 1
            for _, Do in ipairs(method) do
                Do(cache, index, times)
            end
            return unpack(cache)
        end
    end
end

function Advanced.Increment(cache, key, init, increment)
    cache[key] = init - increment
    return function(goal)
        goal[key] = goal[key] + increment
    end
end

function Advanced.SetValue(cache, key, init, final, mode, expect_final)
    cache[key] = init
    local value = final - init
    return function(goal, index, times)
        index = index - 1
        if not expect_final then
            times = times - 1
        end
        goal[key] = init + value * task.SetMode[mode](index / max(times, 1))
    end
end

function Advanced.TwoValues(cache, key, one, two)
    cache[key] = one
    local e = one + two
    one = -one + e
    return function(goal)
        one = -one + e
        goal[key] = one
    end
end

function Advanced.Oscillation(cache, key, one, two, phase, omega)
    cache[key] = one
    local _t = (two - one) / 2
    one = one + _t
    phase = phase - omega
    return function(goal)
        phase = phase + omega
        goal[key] = one + _t * sin(phase - 90)
    end
end

---三维投影二维相关
---已知法向量与一点求平面方程
---返回平面(ax+by+cz+d=0)的a,b,c,d
function lib.VectorPointToPlane(vx, vy, vz, px, py, pz)
    return vx, vy, vz, -px * vx - py * vy - pz * vz
end

---三维投影二维相关
---将一点(x,y,z)投影于一个平面ax+by+cz+d=0
---返回投影后的点(x,y,z)
function lib.ProjectionInPlane(x, y, z, pa, pb, pc, pd)
    local t = (pa * x + pb * y + pc * z + pd) / (pa * pa + pb * pb + pc * pc)
    return x - pa * t, y - pb * t, z - pc * t
end

---点到平面的距离
function lib.DistPointToPlane(x, y, z, pa, pb, pc, pd)
    return abs(pa * x + pb * y + pc * z + pd) / sqrt(pa * pa + pb * pb + pc * pc)
end

---简便检测点的出界
function lib.PointBoundCheck(px, py, x1, x2, y1, y2)
    if x1 == x2 or y1 == y2 then
        return false
    end
    if x2 < x1 then
        x1, x2 = x2, x1
    end
    if y2 < y1 then
        y1, y2 = y2, y1
    end
    if px < x1 or px > x2 then
        return false
    end
    if py < y1 or py > y2 then
        return false
    end
    return true
end

---以反比例函数为基底
---@param y0 number@x=0时所需的值
---@param y100 number@x=100时所需的值
function lib.GetNumByInverse(x, maxn, y0, y100)
    y0 = maxn - y0
    y100 = maxn - y100
    local a = (100 * y100 - y0) / (y0 - y100)
    local b = (1 + a) * y0
    return maxn - b / (x + a)
end

