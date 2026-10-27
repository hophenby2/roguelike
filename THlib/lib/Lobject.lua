---=====================================
---luastg object
---=====================================

----------------------------------------
---碰撞组
GROUP = {
    ---0
    GHOST = 0,
    ---1
    ENEMY_BULLET = 1,
    ---2
    ENEMY = 2,
    ---3
    PLAYER_BULLET = 3,
    ---4
    PLAYER = 4,
    ---5
    INDES = 5,
    ---6
    ITEM = 6,
    ---7
    NONTJT = 7,
    ---8
    SPELL = 8, --由OLC添加，可用于自机bomb
    ---9
    CPLAYER = 9,
    ---10
    LASER = 10,
    ---11
    ITEM2 = 11--特殊的item组
}
----------------------------------------
---层次结构
LAYER = {
    --- -700
    BG = -700,
    --- -600
    ENEMY = -600,
    --- -500
    PLAYER_BULLET = -500,
    --- -400
    PLAYER = -400,
    --- -300
    ITEM = -300,
    --- -200
    ENEMY_BULLET = -200,
    --- -100
    ENEMY_BULLET_EF = -100,
    --- 0
    TOP = 0
}
----------------------------------------
---class
local emptyfunc = function()
end
local all_class = {}

---base class of all classes
local object = { 0, 0, 0, 0, 0, 0,
                 is_class = true,
                 ---方便填东西的东西吧应该吧
                 init = function(self, x, y, group, layer)
                     self.x, self.y = x or self.x, y or self.y
                     self.group = group or self.group
                     self.layer = layer or self.layer
                 end,
                 del = emptyfunc,
                 frame = emptyfunc,
                 render = DefaultRenderFunc,
                 colli = emptyfunc,
                 kill = emptyfunc
}
table.insert(all_class, object)
---@class object
_G.object = object

---有用吗
---将目标的回调函数给自己
local function Equivalent(self, target)
    self.init = target.init
    self.del = target.del
    self.frame = target.frame
    self.render = target.render
    self.colli = target.colli
    self.kill = target.kill
end

---有用吗
---对回调函数进行整理，给底层调用
local function ClassSort(class)
    class[1] = class.init
    class[2] = class.del
    class[3] = class.frame
    class[4] = class.render
    class[5] = class.colli
    class[6] = class.kill
end
---定义新类
---@param base object
---@param define table
---@param sort boolean@是否现场整理
---@return object
function Class(base, define, sort)
    base = base or object
    local result = { emptyfunc, emptyfunc, emptyfunc, emptyfunc, emptyfunc, emptyfunc, is_class = true, base = base }
    Equivalent(result, base)
    if type(define) == "table" then
        for k, v in pairs(define) do
            result[k] = v
        end
    end
    if sort then
        ClassSort(result)
    else
        table.insert(all_class, result)
    end
    return result
end

function InitAllClass()
    for _, v in pairs(all_class) do
        ClassSort(v)
    end
    all_class = {}
end

