---boss 符卡
local boss = boss
local Card = {}
boss.card = Card

local default = function()
end
local task = task
---对二人非符的处理
local non = {}
boss.ns_group = non
function non:init()
    self.another = self.otherboss[1] or nil
end
function non:del()
    self.next = true
    if self.another then
        self.another.otherboss = {}
    end
end
function non:nextcard(x, y)
    local b
    if self.another then
        if not (self.another.next and self.next) then
            task.New(self, function()
                b = true
                boss.show_aura(self, false)
                boss.SetUIDisplay(self, false, false, false, false, false)
                task.Wait(60)
                task.MoveToForce(x or 300, y or 100, 60, 2)
            end)
        end
        while not self.another.next do
            task.Wait()
        end
        if not self.otherboss[1] then
            self.otherboss[1] = self.another or nil
        end
    end
    task.Clear(self, true)
    if b then
        boss.SetUIDisplay(self, true, true, true, true, true)
        boss.show_aura(self, true)
    end
end

---创建一个符卡
---不填参数默认为60秒的时非
---@param name @符卡名
---@param t1 number @无敌时间
---@param t2 number @防御时间
---@param t3 number @总时间
---@param hp number @最大生命值
---@return boss.card|boss
function Card.New(name, t1, t2, t3, hp)
    name = name or ""
    t1 = t1 or 60
    t2 = t2 or 60
    t3 = t3 or 60
    if t1 > t2 or t2 > t3 then
        error('t1<=t2<=t3 must be satisfied.')
    end
    ---@class boss.card
    local c = { before = default, init = default, frame = default, render = default, del = default }
    c.name = tostring(name)

    c.t1 = int(t1 * 60)
    c.t2 = int(t2 * 60)
    c.t3 = int(t3 * 60)
    c.hp = hp or 600
    c.is_sc = (c.name ~= '')
    ---是否免疫自机符卡
    c.is_extra = false
    c.is_combat = true
    return c
end

---快速增加一个(逃跑)事件，在关卡中会体现
---@param class table
---@param func fun(self:boss)
function Card.addRunEvent(class, func)
    local sc = Card.New("", 60, 60, 60, 600)
    sc.before = function(self)
        self.colli = false
        self.ui.drawtime = false
        func(self)
        Del(self)
    end
    table.insert(class.cards, sc)
end

---多boss血条联通
---用在frame里
function Card:PublicHP()
    local t = {}
    for _, b in ipairs(boss_group) do
        if b.is_combat then
            table.insert(t, b.hp)
        end
    end
    self.hp = min(math.huge, unpack(t))
end

function Card.add(class, sc)
    table.insert(class.cards, sc)
end