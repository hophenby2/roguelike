--[[
LuaSTG Special Plus 系 rep函数库
data by OLC
]]

--[[
本系统使用UTF8编码进行字符串处理
UTF8的编码规则：
    1. 字符的第一个字节范围： 0x00—0x7F(0-127),或者 0xC2—0xF4(194-244); UTF8 是兼容 ascii 的，所以 0~127 就和 ascii 完全一致
    2. 0xC0, 0xC1,0xF5—0xFF(192, 193 和 245-255)不会出现在UTF8编码中 
    3. 0x80—0xBF(128-191)只会出现在第二个及随后的编码中(针对多字节编码，如汉字) 
]]

---@class sp.string
local lib = plus.Class()
sp.string = lib
---@param str string @要处理的字符串
function lib:init(str)
    self:Set(str)
end
---获取设置的字符串
---@return string
function lib:Get()
    return self._string
end
---设置新字符串
---@param str string @要处理的字符串
function lib:Set(str)
    self._string = str
    self.string = self:HandleString(str)
end

---将字符串按字符整理成表
---@param str string @要处理的字符串
---@return table
function lib:HandleString(str)
    local st = {}
    for utfChar in str:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        if utfChar ~= "\r" then
            table.insert(st, utfChar)
        end
    end
    return st
end
---获取字符数
---@return number
function lib:GetCharCount()
    return #self.string
end
---获取占位长度
---@return number
function lib:GetLength()
    local L = 0
    for i = 1, #self.string do
        L = L + ((self.string[i]:len() > 1) and 2 or 1)
    end
    return L
end
---获取字符长度
---@return number
function lib:GetTextLength()
    return #self.string
end
---获取真实长度
---@return number
function lib:GetCurrentLength()
    return self._string:len()
end
---截取字符串
---@param index number @始位标
---@param toindex number @末位标
---@return string
function lib:Sub(index, toindex)
    index = index or 1
    if index < 0 then
        index = self:GetLength() + index + 1
    end
    toindex = toindex or index
    if toindex < 0 then
        toindex = self:GetLength() + toindex + 1
    end
    if index > toindex then
        return ""
    end
    local i = 1
    while i < index do
        index = index - ((self.string[i]:len() > 1) and 1 or 0)
        i = i + 1
    end--处理为真正的index

    local s = ""
    local n = index
    local _n = index
    while _n <= toindex do
        if self.string[n] then
            s = s .. self.string[n]
            _n = _n + ((self.string[i]:len() > 1) and 2 or 1)
        else
            break
        end
        n = n + 1
    end
    return s
end
---获取反转字符串
---@return string
function lib:GetReverse()
    local s = {}
    for i = #self.string, 1, -1 do
        table.insert(s, self.string[i])
    end
    return table.concat(s, "")
end

local characterlist = {
    { -20319, -20284, "A" },
    { -20293, -19776, "B" },
    { -19775, -19219, "C" },
    { -19218, -18711, "D" },
    { -18710, -18527, "E" },
    { -18526, -18240, "F" },
    { -18239, -17923, "G" },
    { -17922, -17418, "H" },
    --{ "I" },
    { -17417, -16475, "J" },
    { -16474, -16213, "K" },
    { -16212, -15641, "L" },
    { -15640, -15166, "M" },
    { -15165, -14923, "N" },
    { -14922, -14915, "O" },
    { -14914, -14631, "P" },
    { -14630, -14150, "Q" },
    { -14149, -14091, "R" },
    { -14090, -13319, "S" },
    { -13318, -12839, "T" },
    -- { "U" },
    --{ "V" },
    { -12838, -12557, "W" },
    { -12556, -11848, "X" },
    { -11847, -11056, "Y" },
    { -11055, -10247, "Z" }
}

---获取字符字母A~z
---@return string,number,number|nil
function lib:GetCharacter(o)
    ---@type string
    local str = self.string[o or 1]
    local byte = str:byte()
    if byte >= 65 and byte <= 90 then
        return str, byte + 32, 1
    end
    if byte >= 97 and byte <= 122 then
        return str, byte, 1
    end
    if byte >= 128 then
        local ascii_str = str
        if type(ascii_str) == "string" then
            local ascid = ascii_str:byte(1) * 256 + ascii_str:byte(2) - 65536
            for _, si in ipairs(characterlist) do

                if ascid >= si[1] and ascid <= si[2] then
                    return si[3], si[3]:byte(), 2
                end
            end
        end
    end
end
