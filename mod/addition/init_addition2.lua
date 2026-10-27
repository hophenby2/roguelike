---一个新的定义tool，和init_addition.lua分开
-------------------------------------------------

local lib = stg_levelUPlib

---@param upl number@当前波所升等级
---@param fixed number@修正倍率
---@param slevel number@裨益自身等级
---@param sattri number@自机当前面板数值
local function GetBENEFITvalue(upl, fixed, slevel, sattri)
    upl = upl or 0
    fixed = fixed or 1
    slevel = slevel or 1
    sattri = sattri or 1
    return (1 + (slevel / 50) ^ 4) * (upl ^ (1.85 * (1.2 - slevel / 80))) * (2 ^ (6 - 50 / slevel)) / (sattri ^ (1 / fixed))
end

local function GetBENEFITLevel()
    if not IsValid(player) then
        return
    end
    local v = lstg.var
    local l = 0
    local dangerM = 1 - 200 / (v.chaos + 500)
    local pl = task.SetMode[1](ran:Float(min(dangerM, l / 200), dangerM))
    return max(int(pl * 80), 1)
end
local BENEFITcolor = {
    { 200, 200, 200 },
    { 66, 157, 70 },
    { 80, 151, 242 },
    { 156, 40, 177 },
    { 255, 151, 0 },
    { 213, 1, 0 },
    { 3, 254, 235 },
    { 60, 60, 234 },
}

---注意，这样的裨益不能失去，否则会出现计算问题
---@param getValueFunc fun(d:number, flag:boolean)
local function NewBENEFIT(id, title, getValueFunc, setValueFunc, otherstr)
    local n = lib.NewSimpleAdditionUnit(id, 0, 1, title, function()
    end, "", function()
        return lstg.var._pathlike
    end)
    n.R, n.G, n.B = 132, 255, 227
    n.spBENEFIT = true
    otherstr = otherstr or "%s%0.2f"
    function n:RefreshFunc()
        self.BENEFIT_level = GetBENEFITLevel() or 1
        self.R, self.G, self.B = unpack(BENEFITcolor[math.ceil(self.BENEFIT_level / 10)])
        local value = getValueFunc(self.BENEFIT_level)
        value = max(0.01, int(value * 100) / 100)
        self.title4 = "【裨益SP】" .. ("(Lv.%d)"):format(self.BENEFIT_level) .. otherstr:format(title, value)
        self._add_value = value
    end
    n.event = function(d)
        if n._add_value and d == 1 then
            setValueFunc(n)
        end
    end
    table.remove(lib.ListByState[1], #lib.ListByState[1])
end
lib.NewBENEFIT = NewBENEFIT


local function DefineBENEFIT()
    NewBENEFIT(174, "攻击力+", function(slevel)
        local upl = lstg.wave.level_up_count
        local fixed = 0.38
        local sattri = player.damage
        return GetBENEFITvalue(upl, fixed, slevel, sattri)
    end, function(self)
        player.dmg_offset = player.dmg_offset + self._add_value
    end)
    NewBENEFIT(176, "移速+", function(slevel)
        local upl = lstg.wave.level_up_count
        local fixed = 0.25
        local sattri = player.cur_hspd, player.cur_lspd
        return GetBENEFITvalue(upl, fixed, slevel, sattri)
    end, function(self)
        player.lspeed_offset = player.lspeed_offset + self._add_value
        player.hspeed_offset = player.hspeed_offset + self._add_value
    end)
    NewBENEFIT(177, "射速+", function(slevel)
        local upl = lstg.wave.level_up_count
        local fixed = 0.65
        local sattri = player.cur_sspeed
        return GetBENEFITvalue(upl, fixed, slevel, sattri)
    end, function(self)
        local ss = player.shoot_set.speed
        ss.offset = ss.offset + self._add_value
    end)
    NewBENEFIT(178, "射程+", function(slevel)
        local upl = lstg.wave.level_up_count
        local fixed = 0.72
        local sattri = player.cur_brange
        return GetBENEFITvalue(upl, fixed, slevel, sattri)
    end, function(self)
        local ss = player.shoot_set.range
        ss.offset = ss.offset + self._add_value
    end)
end
stg_levelUPlib.DefineBENEFIT = DefineBENEFIT